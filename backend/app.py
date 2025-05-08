from flask import Flask, jsonify, request
from sqlalchemy import text
from config import BaseConfig
from flask_sqlalchemy import SQLAlchemy
import auth
import datetime
import time
# from redis import StrictRedis  # 暂时注释掉Redis
from flask_cors import CORS
from flask_cors import cross_origin

# 注释掉Redis相关代码
# redis_store = StrictRedis(host=BaseConfig.REDIS_HOST, port=BaseConfig.REDIS_PORT, decode_responses=True)

app = Flask(__name__)

# 添加配置数据库
app.config.from_object(BaseConfig)
# 初始化数据库ORM
db = SQLAlchemy(app)
# 启用CORS
CORS(app, supports_credentials=True)

# 检查数据库连接
with app.app_context():
    with db.engine.connect() as conn:
        rs = conn.execute(text("select 1"))
        print(rs.fetchone())

# 修改所有路由，去掉/api前缀
# 用户登录
@app.route("/login", methods=["POST"])
@cross_origin()
def user_login():
    username = request.json.get("username").strip()
    password = request.json.get("password").strip()
    user_type = request.json.get("type")
    
    try:
        # 使用参数化查询防止SQL注入
        sql = text('SELECT * FROM user WHERE UserName = :username AND Password = :password AND Role = :role')
        data = db.session.execute(sql, {
            'username': username, 
            'password': password,
            'role': 0 if user_type == 'admin' else 1
        }).first()
        
        if data:
            user = {
                'id': data.UserID,
                'username': data.UserName,
                'role': data.Role,
                'location': data.Location
            }
            token = auth.encode_func(user)
            return jsonify({"status": 200, "msg": "登录成功", "token": token})
        else:
            # 打印调试信息
            print(f"Login failed for username: {username}, type: {user_type}")
            return jsonify({"status": 1000, "msg": "用户名或密码错误"})
            
    except Exception as e:
        print(f"Login error: {str(e)}")
        return jsonify({"status": 1000, "msg": f"登录失败: {str(e)}"})

# 用户注册
@app.route("/register", methods=["POST"])
@cross_origin()
def user_register():
    rq = request.json
    username = rq.get("username")
    password = rq.get("password")
    phone = rq.get("phone")
    location = rq.get("location", "未知")
    
    # 检查用户是否已存在
    data = db.session.execute(text('select * from user where UserName="{0}" or Phone="{1}"'.format(username, phone))).fetchall()
    if data:
        return jsonify({"status": 1000, "msg": "用户名或手机号已存在"})
    
    # 生成用户ID
    user_id = f"U{int(time.time()*1000)}"
    
    # 创建新用户
    sql = '''insert into user(UserID, UserName, Phone, Role, Password, Location) 
            values("{0}", "{1}", "{2}", 1, "{3}", "{4}")'''.format(
            user_id, username, phone, password, location)
    try:
        db.session.execute(text(sql))
        db.session.commit()
        return jsonify({"status": 200, "msg": "注册成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"注册失败: {str(e)}"})

# 获取充电站列表
@app.route("/stations", methods=["GET"])
@cross_origin()
def get_stations():
    data = db.session.execute(text('''
        SELECT c.Location, 
            COUNT(CASE WHEN c.Status = 0 THEN 1 END) as available_piles,
            COUNT(CASE WHEN c.Status = 1 THEN 1 END) as busy_piles,
            COUNT(CASE WHEN c.Status = 2 THEN 1 END) as maintenance_piles,
            AVG(c.PricePerKWh) as avg_price
        FROM charger c
        GROUP BY c.Location
    ''')).fetchall()
    
    stations = []
    for row in data:
        station = {
            'id': len(stations) + 1,  # 生成临时ID
            'location': row.Location,
            'price_per_kwh': float(row.avg_price),
            'availablePiles': row.available_piles or 0,
            'busyPiles': row.busy_piles or 0,
            'maintenancePiles': row.maintenance_piles or 0,
            'estimatedWaitTime': (row.busy_piles or 0) * 30  # 简单估算等待时间
        }
        stations.append(station)
    
    return jsonify({"status": 200, "stations": stations})

# 获取充电桩状态
@app.route("/stations/<string:location>/piles", methods=["GET"])
@cross_origin()
def get_station_piles(location):
    data = db.session.execute(text('''
        SELECT * FROM charger 
        WHERE Location = :location
    '''), {"location": location}).fetchall()
    
    piles = []
    for row in data:
        pile = {
            'id': row.ChargerID,
            'location': row.Location,
            'status': row.Status,  # 0=正常，1=充电中，2=损坏
            'price_per_kwh': float(row.PricePerKWh)
        }
        piles.append(pile)
    
    return jsonify({"status": 200, "piles": piles})

# 开始充电
@app.route("/charging/start", methods=["POST"])
@cross_origin()
def start_charging():
    rq = request.json
    user = auth.decode_func(request.headers.get('token'))
    
    # 生成会话ID
    session_id = f"S{int(time.time()*1000)}"
    
    try:
        # 更新充电桩状态
        db.session.execute(text('''
            UPDATE charger 
            SET Status = 1
            WHERE ChargerID = :charger_id
        '''), {"charger_id": rq['charger_id']})
        
        # 创建充电会话记录
        db.session.execute(text('''
            INSERT INTO chargingsession(SessionID, UserID, ChargerID, StartTime, EnergyUsed, Cost)
            VALUES(:session_id, :user_id, :charger_id, :start_time, 0, 0)
        '''), {
            "session_id": session_id,
            "user_id": user['id'],
            "charger_id": rq['charger_id'],
            "start_time": datetime.datetime.now()
        })
        
        db.session.commit()
        return jsonify({"status": 200, "msg": "充电开始", "session_id": session_id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"操作失败: {str(e)}"})

# 结束充电
@app.route("/charging/stop", methods=["POST"])
@cross_origin()
def stop_charging():
    user = auth.decode_func(request.headers.get('token'))
    
    # 获取当前充电会话
    data = db.session.execute(text('''
        SELECT s.*, c.PricePerKWh
        FROM chargingsession s
        JOIN charger c ON s.ChargerID = c.ChargerID
        WHERE s.UserID = :user_id AND s.EndTime IS NULL
    '''), {"user_id": user['id']}).first()
    
    if not data:
        return jsonify({"status": 1000, "msg": "没有进行中的充电"})
    
    end_time = datetime.datetime.now()
    duration = (end_time - data.StartTime).total_seconds() / 3600  # 小时
    energy_used = duration * 7  # 假设充电功率为7kW/h
    cost = energy_used * float(data.PricePerKWh)
    
    try:
        # 更新充电会话
        db.session.execute(text('''
            UPDATE chargingsession 
            SET EndTime = :end_time,
                EnergyUsed = :energy_used,
                Cost = :cost
            WHERE SessionID = :session_id
        '''), {
            "end_time": end_time,
            "energy_used": energy_used,
            "cost": cost,
            "session_id": data.SessionID
        })
        
        # 更新充电桩状态
        db.session.execute(text('''
            UPDATE charger 
            SET Status = 0
            WHERE ChargerID = :charger_id
        '''), {"charger_id": data.ChargerID})
        
        db.session.commit()
        return jsonify({
            "status": 200, 
            "msg": "充电已结束",
            "energy_used": round(energy_used, 2),
            "cost": round(cost, 2)
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"操作失败: {str(e)}"})

# 获取用户当前充电状态
@app.route("/charging/status", methods=["GET"])
@cross_origin()
def get_charging_status():
    user = auth.decode_func(request.headers.get('token'))
    
    data = db.session.execute(text('''
        SELECT s.*, c.Location, c.PricePerKWh
        FROM chargingsession s
        JOIN charger c ON s.ChargerID = c.ChargerID
        WHERE s.UserID = :user_id AND s.EndTime IS NULL
    '''), {"user_id": user['id']}).first()
    
    if not data:
        return jsonify({"status": 1000, "msg": "没有进行中的充电"})
    
    duration = (datetime.datetime.now() - data.StartTime).total_seconds() / 3600  # 小时
    energy_used = duration * 7  # 假设充电功率为7kW/h
    
    charging = {
        'session_id': data.SessionID,
        'location': data.Location,
        'start_time': data.StartTime.strftime('%Y-%m-%d %H:%M:%S'),
        'duration': int(duration * 60),  # 转换为分钟
        'energy_used': round(energy_used, 2),
        'estimated_cost': round(energy_used * float(data.PricePerKWh), 2)
    }
    
    return jsonify({"status": 200, "charging": charging})

# 获取用户充电历史
@app.route("/charging/history", methods=["GET"])
@cross_origin()
def get_charging_history():
    user = auth.decode_func(request.headers.get('token'))
    
    data = db.session.execute(text('''
        SELECT s.*, c.Location, c.PricePerKWh
        FROM chargingsession s
        JOIN charger c ON s.ChargerID = c.ChargerID
        WHERE s.UserID = :user_id AND s.EndTime IS NOT NULL
        ORDER BY s.StartTime DESC
    '''), {"user_id": user['id']}).fetchall()
    
    records = []
    for row in data:
        duration = (row.EndTime - row.StartTime).total_seconds() / 3600  # 小时
        record = {
            'session_id': row.SessionID,
            'location': row.Location,
            'start_time': row.StartTime.strftime('%Y-%m-%d %H:%M:%S'),
            'end_time': row.EndTime.strftime('%Y-%m-%d %H:%M:%S'),
            'duration': int(duration * 60),  # 转换为分钟
            'energy_used': float(row.EnergyUsed),
            'cost': float(row.Cost)
        }
        records.append(record)
    
    return jsonify({"status": 200, "records": records})

# 更新用户个人信息
@app.route("/user/profile", methods=["PUT"])
@cross_origin()
def update_profile():
    user = auth.decode_func(request.headers.get('token'))
    rq = request.json
    
    try:
        # 更新用户信息
        db.session.execute(text('''
            UPDATE user 
            SET Phone = :phone,
                Location = :location
            WHERE UserID = :user_id
        '''), {
            "phone": rq.get('phone'),
            "location": rq.get('location'),
            "user_id": user['id']
        })
        
        db.session.commit()
        return jsonify({"status": 200, "msg": "个人信息更新成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"更新失败: {str(e)}"})

# 修改密码
@app.route("/user/password", methods=["PUT"])
@cross_origin()
def change_password():
    user = auth.decode_func(request.headers.get('token'))
    rq = request.json
    old_password = rq.get('oldPassword')
    new_password = rq.get('newPassword')
    
    # 验证原密码
    data = db.session.execute(text('''
        SELECT * FROM user 
        WHERE UserID = :user_id AND Password = :password
    '''), {
        "user_id": user['id'],
        "password": old_password
    }).first()
    
    if not data:
        return jsonify({"status": 1000, "msg": "原密码错误"})
    
    try:
        # 更新密码
        db.session.execute(text('''
            UPDATE user 
            SET Password = :new_password
            WHERE UserID = :user_id
        '''), {
            "new_password": new_password,
            "user_id": user['id']
        })
        
        db.session.commit()
        return jsonify({"status": 200, "msg": "密码修改成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"修改失败: {str(e)}"})

# 管理端API
# 获取所有进行中的充电记录
@app.route("/manager/charging/active", methods=["GET"])
@cross_origin()
def get_active_records():
    data = db.session.execute(text('''
        SELECT s.*, u.UserName, c.Location
        FROM chargingsession s
        JOIN user u ON s.UserID = u.UserID
        JOIN charger c ON s.ChargerID = c.ChargerID
        WHERE s.EndTime IS NULL
        ORDER BY s.StartTime DESC
    ''')).fetchall()
    
    records = []
    for row in data:
        duration = (datetime.datetime.now() - row.StartTime).total_seconds() / 3600  # 小时
        energy_used = duration * 7  # 假设充电功率为7kW/h
        
        record = {
            'session_id': row.SessionID,
            'user_name': row.UserName,
            'location': row.Location,
            'start_time': row.StartTime.strftime('%Y-%m-%d %H:%M:%S'),
            'duration': int(duration * 60),  # 转换为分钟
            'energy_used': round(energy_used, 2)
        }
        records.append(record)
    
    return jsonify({"status": 200, "records": records})

# 获取所有历史充电记录
@app.route("/manager/charging/history", methods=["GET"])
@cross_origin()
def get_history_records():
    data = db.session.execute(text('''
        SELECT s.*, u.UserName, c.Location
        FROM chargingsession s
        JOIN user u ON s.UserID = u.UserID
        JOIN charger c ON s.ChargerID = c.ChargerID
        WHERE s.EndTime IS NOT NULL
        ORDER BY s.StartTime DESC
    ''')).fetchall()
    
    records = []
    for row in data:
        record = {
            'session_id': row.SessionID,
            'user_name': row.UserName,
            'location': row.Location,
            'start_time': row.StartTime.strftime('%Y-%m-%d %H:%M:%S'),
            'end_time': row.EndTime.strftime('%Y-%m-%d %H:%M:%S'),
            'duration': int((row.EndTime - row.StartTime).total_seconds() / 60),  # 转换为分钟
            'energy_used': float(row.EnergyUsed),
            'cost': float(row.Cost)
        }
        records.append(record)
    
    return jsonify({"status": 200, "records": records})

# 管理端：添加充电站
@app.route("/manager/stations", methods=["POST"])
@cross_origin()
def add_station():
    user = auth.decode_func(request.headers.get('token'))
    if user['role'] != 0:  # 检查是否是管理员
        return jsonify({"status": 403, "msg": "无权限执行此操作"})
    
    rq = request.json
    # 生成充电桩ID
    charger_id = f"C{int(time.time()*1000)}"
    
    try:
        # 添加新充电桩
        db.session.execute(text('''
            INSERT INTO charger(ChargerID, Manager, Location, Status, PricePerKWh)
            VALUES(:charger_id, :manager_id, :location, 0, :price)
        '''), {
            "charger_id": charger_id,
            "manager_id": user['id'],
            "location": rq.get('location'),
            "price": rq.get('pricePerKWh')
        })
        
        db.session.commit()
        return jsonify({"status": 200, "msg": "充电站添加成功", "charger_id": charger_id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"添加失败: {str(e)}"})

# 管理端：更新充电站信息
@app.route("/manager/stations/<string:charger_id>", methods=["PUT"])
@cross_origin()
def update_station(charger_id):
    user = auth.decode_func(request.headers.get('token'))
    if user['role'] != 0:
        return jsonify({"status": 403, "msg": "无权限执行此操作"})
    
    rq = request.json
    try:
        # 更新充电站信息
        db.session.execute(text('''
            UPDATE charger 
            SET Location = :location,
                PricePerKWh = :price,
                Status = :status
            WHERE ChargerID = :charger_id
        '''), {
            "location": rq.get('location'),
            "price": rq.get('pricePerKWh'),
            "status": rq.get('status'),
            "charger_id": charger_id
        })
        
        db.session.commit()
        return jsonify({"status": 200, "msg": "充电站信息更新成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"更新失败: {str(e)}"})

# 管理端：删除充电站
@app.route("/manager/stations/<string:charger_id>", methods=["DELETE"])
@cross_origin()
def delete_station(charger_id):
    user = auth.decode_func(request.headers.get('token'))
    if user['role'] != 0:
        return jsonify({"status": 403, "msg": "无权限执行此操作"})
    
    try:
        # 检查是否有进行中的充电
        active_session = db.session.execute(text('''
            SELECT * FROM chargingsession 
            WHERE ChargerID = :charger_id AND EndTime IS NULL
        '''), {"charger_id": charger_id}).first()
        
        if active_session:
            return jsonify({"status": 1000, "msg": "该充电桩正在使用中，无法删除"})
        
        # 删除充电桩
        db.session.execute(text('''
            DELETE FROM charger 
            WHERE ChargerID = :charger_id
        '''), {"charger_id": charger_id})
        
        db.session.commit()
        return jsonify({"status": 200, "msg": "充电站删除成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": 1000, "msg": f"删除失败: {str(e)}"})

# 获取充电站详细信息
@app.route("/stations/<string:station_id>", methods=["GET"])
@cross_origin()
def get_station_detail(station_id):
    data = db.session.execute(text('''
        SELECT c.*, a.AdminName as manager_name
        FROM charger c
        LEFT JOIN admin a ON c.Manager = a.AdminID
        WHERE c.ChargerID = :station_id
    '''), {"station_id": station_id}).first()
    
    if not data:
        return jsonify({"status": 404, "msg": "充电站不存在"})
    
    station = {
        'id': data.ChargerID,
        'location': data.Location,
        'status': data.Status,
        'pricePerKWh': float(data.PricePerKWh),
        'manager': {
            'id': data.Manager,
            'name': data.manager_name
        }
    }
    
    return jsonify({"status": 200, "station": station})

if __name__ == '__main__':
    @app.route("/", methods=["GET"]) 
    @cross_origin()
    def index():
        return jsonify({
            "status": 200,
            "msg": "API服务运行中"
        })

    app.run(debug=True, host='127.0.0.1', port=5000)
