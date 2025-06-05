from flask import Flask, jsonify, request
from sqlalchemy import text
from config import BaseConfig
from flask_sqlalchemy import SQLAlchemy
import auth
import datetime
import time
from flask_cors import CORS
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config.from_object(BaseConfig)
db = SQLAlchemy(app)
CORS(app, supports_credentials=True)

# 检查数据库连接
with app.app_context():
    with db.engine.connect() as conn:
        rs = conn.execute(text("SELECT 1"))
        print(rs.fetchone())

# ---------------------------
# 用户相关接口
# ---------------------------
@app.route("/user/login", methods=["POST"])
def user_login():
    try:
        username = request.json.get("username")
        password = request.json.get("password")
        sql = text('''
            SELECT id, username, phone, role_id, head_pic, sex, money
            FROM user
            WHERE username = :username AND password = :password
        ''')
        user = db.session.execute(sql, {"username": username, "password": password}).first()
        if user:
            data = {
                "id": user.id,
                "username": user.username,
                "roleId": user.role_id,
                "phone": user.phone,
                "headPic": user.head_pic,
                "sex": user.sex,
                "money": float(user.money or 0)
            }
            token = auth.generateToken(data)
            return jsonify({"code": 200, "msg": "登录成功", "token": token, "data": data})
        return jsonify({"code": 1, "msg": "用户名或密码错误"})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"登录失败: {str(e)}"})

@app.route("/user/check_login", methods=["POST"])
def check_login():
    try:
        token = request.json.get("token")
        data = auth.decodeToken(token)
        return jsonify({"code": 0, "data": data})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"登录验证失败: {str(e)}"})

# 用户列表接口
@app.route("/user/list", methods=["POST"])
def user_list():
    try:
        form = request.json
        page = form.get("page", 1)
        size = form.get("size", 10)
        param = form.get("param", {})
        username = param.get("username", "")
        role_id = param.get("roleId", 0)

        # 构建查询条件
        sql = '''
            SELECT id, username, phone, role_id, head_pic, sex, money, rate
            FROM user
            WHERE (:username = '' OR username LIKE :username_pattern)
              AND (:role_id = 0 OR role_id = :role_id)
            LIMIT :limit OFFSET :offset
        '''
        count_sql = '''
            SELECT COUNT(*) as total
            FROM user
            WHERE (:username = '' OR username LIKE :username_pattern)
              AND (:role_id = 0 OR role_id = :role_id)
        '''
        params = {
            "username": username,
            "username_pattern": f"%{username}%",
            "role_id": role_id,
            "limit": size,
            "offset": (page - 1) * size,
        }

        # 查询用户列表
        print("Executing SQL for user list:", sql)
        print("With parameters:", params)
        data = db.session.execute(text(sql), params).fetchall()
        users = [{
            "id": row.id,
            "username": row.username,
            "phone": row.phone,
            "roleId": row.role_id,
            "headPic": row.head_pic,
            "sex": row.sex,
            "money": float(row.money or 0),
            "rate": row.rate or 0  # 确保 rate 有默认值
        } for row in data]

        # 查询总数
        print("Executing SQL for user count:", count_sql)
        total = db.session.execute(text(count_sql), params).scalar()

        return jsonify({"code": 0, "data": {"list": users, "total": total}})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取用户列表失败: {str(e)}"})

# 保存用户信息接口
@app.route("/user/save", methods=["POST"])
def user_save():
    try:
        form = request.json
        if not form.get("id"):
            # 新增用户
            user_id = "U" + str(int(time.time() * 1000))  # 生成唯一ID
            sql = text('''
                INSERT INTO user(username, password, phone, role_id, head_pic, sex, money, rate)
                VALUES(:username, :password, :phone, :role_id, :head_pic, :sex, :money, :rate)
            ''')
            db.session.execute(sql, {
                "id": user_id,
                "username": form.get("username"),
                "password": form.get("password"),
                "phone": form.get("phone"),
                "role_id": form.get("roleId"),
                "head_pic": form.get("headPic"),
                "sex": form.get("sex"),
                "money": form.get("money", 0),
                "rate": form.get("rate", 100),
            })
        else:
            # 更新用户
            sql = text('''
                UPDATE user
                SET username = :username, password = :password, phone = :phone,
                    role_id = :role_id, head_pic = :head_pic, sex = :sex,
                    money = :money, rate = :rate
                WHERE id = :id
            ''')
            db.session.execute(sql, {
                "id": form.get("id"),
                "username": form.get("username"),
                "password": form.get("password"),
                "phone": form.get("phone"),
                "role_id": form.get("roleId"),
                "head_pic": form.get("headPic"),
                "sex": form.get("sex"),
                "money": form.get("money", 0),
                "rate": form.get("rate", 100),
            })
        db.session.commit()
        return jsonify({"code": 0, "msg": "用户保存成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"用户保存失败: {str(e)}"})

# ---------------------------
# 电站相关接口
# ---------------------------
@app.route("/station/list", methods=["GET", "POST"])
def station_list():
    try:
        form = request.json
        page = form.get("page", 1)
        size = form.get("size", 10)
        param = form.get("param", {})
        name = param.get("name", "")
        operator_id = param.get("operatorId", 0)

        # 构建查询条件
        sql = '''
            SELECT s.id, s.name, s.location, s.photo, s.charge_num, s.available_charge_num,
                   o.name as operator_name
            FROM station s
            LEFT JOIN operator o ON s.operator_id = o.id
            WHERE (:name = '' OR s.name LIKE :name_pattern)
              AND (:operator_id = 0 OR s.operator_id = :operator_id)
            LIMIT :limit OFFSET :offset
        '''
        count_sql = '''
            SELECT COUNT(*) as total
            FROM station s
            WHERE (:name = '' OR s.name LIKE :name_pattern)
              AND (:operator_id = 0 OR s.operator_id = :operator_id)
        '''
        params = {
            "name": name,
            "name_pattern": f"%{name}%",
            "operator_id": operator_id,
            "limit": size,
            "offset": (page - 1) * size,
        }

        # 查询电站列表
        data = db.session.execute(text(sql), params).fetchall()
        print("Station list data:", data)  # 调试日志
        stations = [{
            "id": row.id,
            "name": row.name,
            "location": row.location,
            "photo": row.photo,
            "charge_num": row.charge_num,
            "available_charge_num": row.available_charge_num,
            "operator_name": row.operator_name
        } for row in data]

        # 查询总数
        total = db.session.execute(text(count_sql), params).scalar()

        return jsonify({"code": 0, "data": {"list": stations, "total": total}})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取电站列表失败: {str(e)}"})

@app.route("/station/all", methods=["GET", "POST"])
def station_all():
    try:
        # 返回电站列表（简要信息，仅供下拉选择使用）
        sql = text('''
            SELECT id, name
            FROM station
        ''')
        data = db.session.execute(sql).fetchall()
        stations = [{"id": row.id, "name": row.name} for row in data]
        return jsonify({"code": 0, "data": stations})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取全部电站失败: {str(e)}"})

@app.route("/station/save", methods=["POST"])
def station_save():
    try:
        form = request.json
        now = datetime.datetime.now()
        # 判断是新增还是更新（依靠 id 是否存在）
        if not form.get("id"):
            # 新增时生成ID，可使用时间戳拼接
            station_id = "S" + str(int(time.time() * 1000))
            sql = text('''
                INSERT INTO station(id, name, location, photo, charge_num, available_charge_num, operator_id)
                VALUES(:id, :name, :location, :photo, 0, 0, :operator_id)
            ''')
            db.session.execute(sql, {
                "id": station_id,
                "name": form.get("name"),
                "location": form.get("location"),
                "photo": form.get("photo"),
                "operator_id": form.get("operatorId")
            })
        else:
            # 更新
            sql = text('''
                UPDATE station
                SET name=:name, location=:location, photo=:photo, operator_id=:operator_id
                WHERE id=:id
            ''')
            db.session.execute(sql, {
                "id": form.get("id"),
                "name": form.get("name"),
                "location": form.get("location"),
                "photo": form.get("photo"),
                "operator_id": form.get("operatorId")
            })
        db.session.commit()
        return jsonify({"code": 0, "msg": "电站保存成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"电站保存失败: {str(e)}"})

@app.route("/station/delete", methods=["POST"])
def station_delete():
    try:
        form = request.json
        station_id = form.get("id")
        sql = text('DELETE FROM station WHERE id=:id')
        db.session.execute(sql, {"id": station_id})
        db.session.commit()
        return jsonify({"code": 0, "msg": "电站删除成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"电站删除失败: {str(e)}"})

# ---------------------------
# 充电桩相关接口
# ---------------------------
@app.route("/charge/list", methods=["GET", "POST"])
def charge_list():
    try:
        # 如果有分页参数，可根据前端传入的 page, size, param 进行过滤，这里简单返回所有数据
        sql = text('''
            SELECT c.id, c.name, c.photo, c.state, c.price, c.description, s.name as station_name
            FROM charge c
            LEFT JOIN station s ON c.station_id = s.id
        ''')
        data = db.session.execute(sql).fetchall()
        # 调试日志
        print("Charge list data:", data)
        charges = [{
            "id": row.id,
            "name": row.name,
            "photo": row.photo,
            "state": row.state,
            "price": float(row.price),
            "description": row.description,
            "station_name": row.station_name
        } for row in data]
        return jsonify({"code": 0, "data": charges})
    except Exception as e:
        print("Error in /charge/list:", str(e))
        return jsonify({"code": 1, "msg": f"获取充电桩列表失败: {str(e)}"})

@app.route("/charge/save", methods=["POST"])
def charge_save():
    try:
        form = request.json
        if not form.get("id"):
            charge_id = "C" + str(int(time.time() * 1000))
            sql = text('''
                INSERT INTO charge(id, name, station_id, photo, state, price, description)
                VALUES(:id, :name, :station_id, :photo, :state, :price, :description)
            ''')
            db.session.execute(sql, {
                "id": charge_id,
                "name": form.get("name"),
                "station_id": form.get("stationId"),
                "photo": form.get("photo"),
                "state": form.get("state"),
                "price": form.get("price"),
                "description": form.get("description")
            })
        else:
            sql = text('''
                UPDATE charge
                SET name=:name, station_id=:station_id, photo=:photo, state=:state, price=:price, description=:description
                WHERE id=:id
            ''')
            db.session.execute(sql, {
                "id": form.get("id"),
                "name": form.get("name"),
                "station_id": form.get("stationId"),
                "photo": form.get("photo"),
                "state": form.get("state"),
                "price": form.get("price"),
                "description": form.get("description")
            })
        db.session.commit()
        return jsonify({"code": 0, "msg": "充电桩保存成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"充电桩保存失败: {str(e)}"})

@app.route("/charge/delete", methods=["POST"])
def charge_delete():
    try:
        form = request.json
        charge_id = form.get("id")
        sql = text('DELETE FROM charge WHERE id=:id')
        db.session.execute(sql, {"id": charge_id})
        db.session.commit()
        return jsonify({"code": 0, "msg": "充电桩删除成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"充电桩删除失败: {str(e)}"})

# ---------------------------
# 运营商相关接口
# ---------------------------
@app.route("/operator/all", methods=["GET", "POST"])
def operator_all():
    try:
        sql = text('SELECT id, name FROM operator')
        data = db.session.execute(sql).fetchall()
        operators = [{"id": row.id, "name": row.name} for row in data]
        return jsonify({"code": 0, "data": operators})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取运营商列表失败: {str(e)}"})

# ---------------------------
# 文件上传（照片上传）接口
# ---------------------------
UPLOAD_FOLDER = os.path.join(os.getcwd(), "uploads")
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route("/photo/upload", methods=["POST"])
def photo_upload():
    try:
        if "photo" not in request.files:
            return jsonify({"code": 1, "msg": "未提供文件"})
        file = request.files["photo"]
        if file.filename == "":
            return jsonify({"code": 1, "msg": "文件名为空"})
        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        # 返回文件名，前端可根据VITE_SERVER地址拼接获取图片
        return jsonify({"code": 0, "msg": "上传成功", "data": filename})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"上传失败: {str(e)}"})

# ---------------------------
# 充电会话相关接口
# ---------------------------
@app.route("/charging/start", methods=["POST"])
def start_charging():
    try:
        user_token = request.headers.get("token")
        user = auth.decodeToken(user_token)
        rq = request.json
        charger_id = rq.get("chargerId")
        session_id = "S" + str(int(time.time() * 1000))
        start_time = datetime.datetime.now()
        # 更新充电桩状态为“充电中”（假设：1-可用，2-充电中）
        sql_update = text('''
            UPDATE charge
            SET state = 2
            WHERE id = :charger_id AND state = 1
        ''')
        result = db.session.execute(sql_update, {"charger_id": charger_id})
        if result.rowcount == 0:
            return jsonify({"code": 1, "msg": "充电桩不可用或正在充电"})
        # 插入充电会话记录（假设表 chargingsession 字段：SessionID, UserID, ChargerID, StartTime, EndTime, EnergyUsed, Cost）
        sql_insert = text('''
            INSERT INTO chargingsession(SessionID, UserID, ChargerID, StartTime, EnergyUsed, Cost)
            VALUES(:session_id, :user_id, :charger_id, :start_time, 0, 0)
        ''')
        db.session.execute(sql_insert, {
            "session_id": session_id,
            "user_id": user["id"],
            "charger_id": charger_id,
            "start_time": start_time
        })
        db.session.commit()
        return jsonify({"code": 0, "msg": "充电开始", "session_id": session_id})
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"开始充电失败: {str(e)}"})

@app.route("/charging/stop", methods=["POST"])
def stop_charging():
    try:
        user_token = request.headers.get("token")
        user = auth.decodeToken(user_token)
        # 查询用户当前未结束的充电会话
        sql_sel = text('''
            SELECT s.SessionID, s.ChargerID, s.StartTime, c.price, c.id as charger_id
            FROM chargingsession s
            JOIN charge c ON s.ChargerID = c.id
            WHERE s.UserID = :user_id AND s.EndTime IS NULL
        ''')
        session_data = db.session.execute(sql_sel, {"user_id": user["id"]}).first()
        if not session_data:
            return jsonify({"code": 1, "msg": "未找到进行中的充电会话"})
        end_time = datetime.datetime.now()
        # 计算充电时长（小时）
        duration = (end_time - session_data.StartTime).total_seconds() / 3600
        # 假设充电功率为 7kW，计算能量（单位：kWh）
        energy_used = duration * 7
        # 计算费用，使用充电桩价格（单位：元/分钟，此处转换为元/小时）
        cost = energy_used * float(session_data.price) * 60
        sql_update = text('''
            UPDATE chargingsession
            SET EndTime = :end_time, EnergyUsed = :energy_used, Cost = :cost
            WHERE SessionID = :session_id
        ''')
        db.session.execute(sql_update, {
            "end_time": end_time,
            "energy_used": energy_used,
            "cost": cost,
            "session_id": session_data.SessionID
        })
        # 更新充电桩状态恢复为“可用”
        sql_charger = text('''
            UPDATE charge
            SET state = 1
            WHERE id = :charger_id
        ''')
        db.session.execute(sql_charger, {"charger_id": session_data.charger_id})
        db.session.commit()
        return jsonify({
            "code": 0,
            "msg": "充电结束",
            "energy_used": round(energy_used, 2),
            "cost": round(cost, 2)
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"结束充电失败: {str(e)}"})

@app.route('/user/logout', methods=['POST'])
def logout():
    # 清除用户会话或令牌
    return jsonify({"code": 0, "msg": "登出成功"})

@app.route('/user/register', methods=['POST'])
def register():
    try:
        data = request.json
        username = data.get("username")
        password = data.get("password")
        phone = data.get("phone")
        head_pic = data.get("headPic", "common/no_image.jpg")  # 默认头像
        sex = data.get("sex", 3)  # 默认性别未知
        role_id = data.get("roleId", 1)  # 默认角色为普通用户
        rate = data.get("rate", 100)  # 默认信誉积分
        money = data.get("money", 0)  # 默认余额

        # 检查必填字段
        if not username or not password or not phone:
            return jsonify({"code": 1, "msg": "用户名、密码和手机号为必填项"})

        # 检查用户名是否已存在
        sql_check = text('SELECT COUNT(*) FROM user WHERE username = :username')
        existing_user_count = db.session.execute(sql_check, {"username": username}).scalar()
        if existing_user_count > 0:
            return jsonify({"code": 1, "msg": "用户名已存在"})

        # 插入用户数据
        # user_id = "U" + str(int(time.time() * 1000))  # 生成唯一用户ID
        sql_insert = text('''
            INSERT INTO user ( username, password, phone)
            VALUES (:username, :password, :phone)
        ''')
        db.session.execute(sql_insert, {
            "username": username,
            "password": password,
            "phone": phone,

        })
        db.session.commit()
        return jsonify({"code": 0, "msg": "注册成功"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"code": 1, "msg": f"注册失败: {str(e)}"})
    
@app.route("/order/list", methods=["POST"])
def order_list():
    try:
        form = request.json
        page = form.get("page", 1)
        size = form.get("size", 10)
        param = form.get("param", {})
        user_id = param.get("userId", "")
        state = param.get("state", 0)

        # 构建查询条件
        sql = '''
            SELECT o.id, o.total_price, o.user_id, o.charge_id, o.create_time, o.state,
                   u.username as userDTO_username
            FROM orders o
            LEFT JOIN user u ON o.user_id = u.id
            WHERE (:user_id = '' OR o.user_id = :user_id)
              AND (:state = 0 OR o.state = :state)
            LIMIT :limit OFFSET :offset
        '''
        count_sql = '''
            SELECT COUNT(*) as total
            FROM orders o
            WHERE (:user_id = '' OR o.user_id = :user_id)
              AND (:state = 0 OR o.state = :state)
        '''
        params = {
            "user_id": user_id,
            "state": state,
            "limit": size,
            "offset": (page - 1) * size,
        }

        # 查询订单列表
        data = db.session.execute(text(sql), params).fetchall()
        orders = [{
            "id": row.id,
            "total_price": float(row.total_price),
            "user_id": row.user_id,
            "charge_id": row.charge_id,
            "create_time": row.create_time.strftime("%Y-%m-%d %H:%M:%S"),
            "state": row.state,
            "userDTO": {
                "username": row.userDTO_username
            }
        } for row in data]

        # 查询总数
        total = db.session.execute(text(count_sql), params).scalar()

        return jsonify({"code": 0, "data": {"list": orders, "total": total}})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取订单列表失败: {str(e)}"})
    
@app.route('/coupon/Myreceive', methods=['POST'])
def my_receive_coupon():
    try:
        user_id = request.json.get("userId")
        sql = text('SELECT * FROM user_coupon WHERE user_id = :user_id')
        coupons = db.session.execute(sql, {"user_id": user_id}).fetchall()
        return jsonify({"code": 0, "data": [dict(row) for row in coupons]})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取优惠券失败: {str(e)}"})
    
@app.route("/appoint/list", methods=["POST"])
def appoint_list():
    try:
        form = request.json
        page = form.get("page", 1)
        size = form.get("size", 10)
        param = form.get("param", {})
        user_id = param.get("userId", "")
        username = param.get("username", "")
        charge_id = param.get("chargeId", 0)

        # 构建查询条件
        sql = '''
            SELECT a.id, a.charge_id, a.charge_name, a.charge_price, a.create_time, a.day, a.time, a.state, a.start_time, a.end_time,
                   u.username as userDTO_username
            FROM appoint a
            LEFT JOIN user u ON a.user_id = u.id
            WHERE (:user_id = '' OR a.user_id = :user_id)
              AND (:username = '' OR u.username LIKE :username_pattern)
              AND (:charge_id = 0 OR a.charge_id = :charge_id)
            LIMIT :limit OFFSET :offset
        '''
        count_sql = '''
            SELECT COUNT(*) as total
            FROM appoint a
            LEFT JOIN user u ON a.user_id = u.id
            WHERE (:user_id = '' OR a.user_id = :user_id)
              AND (:username = '' OR u.username LIKE :username_pattern)
              AND (:charge_id = 0 OR a.charge_id = :charge_id)
        '''
        params = {
            "user_id": user_id,
            "username_pattern": f"%{username}%",
            "charge_id": charge_id,
            "limit": size,
            "offset": (page - 1) * size,
        }

        # 查询预约列表
        data = db.session.execute(text(sql), params).fetchall()
        appoints = [{
            "id": row.id,
            "charge_id": row.charge_id,
            "charge_name": row.charge_name,
            "charge_price": float(row.charge_price),
            "create_time": row.create_time.strftime("%Y-%m-%d %H:%M:%S"),
            "day": row.day.strftime("%Y-%m-%d"),
            "time": row.time,
            "state": row.state,
            "start_time": row.start_time.strftime("%Y-%m-%d %H:%M:%S") if row.start_time else None,
            "end_time": row.end_time.strftime("%Y-%m-%d %H:%M:%S") if row.end_time else None,
            "userDTO": {
                "username": row.userDTO_username
            }
        } for row in data]

        # 查询总数
        total = db.session.execute(text(count_sql), params).scalar()

        return jsonify({"code": 0, "data": {"list": appoints, "total": total}})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取预约列表失败: {str(e)}"})
    
@app.route("/charge/all", methods=["POST"])
def charge_all():
    try:
        sql = '''
            SELECT id, name, station_id, photo, state, price, description
            FROM charge
        '''
        data = db.session.execute(text(sql)).fetchall()
        charges = [{
            "id": row.id,
            "name": row.name,
            "station_id": row.station_id,
            "photo": row.photo,
            "state": row.state,
            "price": float(row.price),
            "description": row.description
        } for row in data]
        return jsonify({"code": 0, "data": charges})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取充电桩列表失败: {str(e)}"})

# 添加 /appoint/all 路由
@app.route("/appoint/all", methods=["POST"])
def appoint_all():
    try:
        sql = '''
            SELECT a.id, a.user_id, a.charge_id, a.charge_price, a.create_time, a.day, a.time, a.state, a.start_time, a.end_time,
                   u.username as user_name, c.name as charge_name
            FROM appoint a
            LEFT JOIN user u ON a.user_id = u.id
            LEFT JOIN charge c ON a.charge_id = c.id
        '''
        data = db.session.execute(text(sql)).fetchall()
        appoints = [{
            "id": row.id,
            "user_id": row.user_id,
            "charge_id": row.charge_id,
            "charge_price": float(row.charge_price),
            "create_time": row.create_time.strftime("%Y-%m-%d %H:%M:%S"),
            "day": row.day.strftime("%Y-%m-%d"),
            "time": row.time,
            "state": row.state,
            "start_time": row.start_time.strftime("%Y-%m-%d %H:%M:%S") if row.start_time else None,
            "end_time": row.end_time.strftime("%Y-%m-%d %H:%M:%S") if row.end_time else None,
            "user_name": row.user_name,
            "charge_name": row.charge_name
        } for row in data]
        return jsonify({"code": 0, "data": appoints})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取预约列表失败: {str(e)}"})

# 添加 /appoint/appointed 路由
@app.route("/appoint/appointed", methods=["POST"])
def appoint_appointed():
    try:
        form = request.json
        user_id = form.get("userId")
        sql = '''
            SELECT a.id, a.charge_id, a.charge_price, a.create_time, a.day, a.time, a.state, a.start_time, a.end_time,
                   c.name as charge_name
            FROM appoint a
            LEFT JOIN charge c ON a.charge_id = c.id
            WHERE a.user_id = :user_id AND a.state = 1
        '''
        data = db.session.execute(text(sql), {"user_id": user_id}).fetchall()
        appoints = [{
            "id": row.id,
            "charge_id": row.charge_id,
            "charge_price": float(row.charge_price),
            "create_time": row.create_time.strftime("%Y-%m-%d %H:%M:%S"),
            "day": row.day.strftime("%Y-%m-%d"),
            "time": row.time,
            "state": row.state,
            "start_time": row.start_time.strftime("%Y-%m-%d %H:%M:%S") if row.start_time else None,
            "end_time": row.end_time.strftime("%Y-%m-%d %H:%M:%S") if row.end_time else None,
            "charge_name": row.charge_name
        } for row in data]
        return jsonify({"code": 0, "data": appoints})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取已预约列表失败: {str(e)}"})

# 添加 /user/rate 路由
@app.route("/user/rate", methods=["POST"])
def user_rate():
    try:
        form = request.json
        user_id = form.get("userId")
        sql = '''
            SELECT rate FROM user WHERE id = :user_id
        '''
        rate = db.session.execute(text(sql), {"user_id": user_id}).scalar()
        return jsonify({"code": 0, "data": {"rate": rate}})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取用户信誉积分失败: {str(e)}"})

# 添加 /order/all 路由
@app.route("/order/all", methods=["POST"])
def order_all():
    try:
        sql = '''
            SELECT o.id, o.total_price, o.user_id, o.charge_id, o.create_time, o.state,
                   u.username as user_name, c.name as charge_name
            FROM orders o
            LEFT JOIN user u ON o.user_id = u.id
            LEFT JOIN charge c ON o.charge_id = c.id
        '''
        data = db.session.execute(text(sql)).fetchall()
        orders = [{
            "id": row.id,
            "total_price": float(row.total_price),
            "user_id": row.user_id,
            "charge_id": row.charge_id,
            "create_time": row.create_time.strftime("%Y-%m-%d %H:%M:%S"),
            "state": row.state,
            "user_name": row.user_name,
            "charge_name": row.charge_name
        } for row in data]
        return jsonify({"code": 0, "data": orders})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取订单列表失败: {str(e)}"})

# 添加 /warn/all 路由
@app.route("/warn/all", methods=["POST"])
def warn_all():
    try:
        sql = '''
            SELECT * FROM warn
        '''
        data = db.session.execute(text(sql)).fetchall()
        warns = [dict(row) for row in data]
        return jsonify({"code": 0, "data": warns})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取警告信息失败: {str(e)}"})

# 添加 /comment/all 路由
@app.route("/comment/all", methods=["POST"])
def comment_all():
    try:
        sql = '''
            SELECT c.id, c.content, c.create_time, c.reply_content, c.user_id, u.username as user_name
            FROM comment c
            LEFT JOIN user u ON c.user_id = u.id
        '''
        data = db.session.execute(text(sql)).fetchall()
        comments = [{
            "id": row.id,
            "content": row.content,
            "create_time": row.create_time.strftime("%Y-%m-%d %H:%M:%S"),
            "reply_content": row.reply_content,
            "user_id": row.user_id,
            "user_name": row.user_name
        } for row in data]
        return jsonify({"code": 0, "data": comments})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取评论列表失败: {str(e)}"})

# 添加 /repair/list 路由
@app.route("/repair/list", methods=["POST"])
def repair_list():
    try:
        form = request.json
        page = form.get("page", 1)
        size = form.get("size", 10)
        param = form.get("param", {})
        user_id = param.get("userId", "")
        charge_id = param.get("chargeId", "")
        state = param.get("state", 0)

        # 构建查询条件
        sql = '''
            SELECT r.id, r.user_id, r.charge_id, r.state, r.create_time, r.description,
                   u.username as user_name, c.name as charge_name
            FROM repair r
            LEFT JOIN user u ON r.user_id = u.id
            LEFT JOIN charge c ON r.charge_id = c.id
            WHERE (:user_id = '' OR r.user_id = :user_id)
              AND (:charge_id = '' OR r.charge_id = :charge_id)
              AND (:state = 0 OR r.state = :state)
            LIMIT :limit OFFSET :offset
        '''
        count_sql = '''
            SELECT COUNT(*) as total
            FROM repair r
            WHERE (:user_id = '' OR r.user_id = :user_id)
              AND (:charge_id = '' OR r.charge_id = :charge_id)
              AND (:state = 0 OR r.state = :state)
        '''
        params = {
            "user_id": user_id,
            "charge_id": charge_id,
            "state": state,
            "limit": size,
            "offset": (page - 1) * size,
        }

        # 查询维修列表
        data = db.session.execute(text(sql), params).fetchall()
        repairs = [{
            "id": row.id,
            "user_id": row.user_id,
            "charge_id": row.charge_id,
            "state": row.state,
            "create_time": row.create_time.strftime("%Y-%m-%d %H:%M:%S"),
            "description": row.description,
            "user_name": row.user_name,
            "charge_name": row.charge_name
        } for row in data]

        # 查询总数
        total = db.session.execute(text(count_sql), params).scalar()

        return jsonify({"code": 0, "data": {"list": repairs, "total": total}})
    except Exception as e:
        return jsonify({"code": 1, "msg": f"获取维修列表失败: {str(e)}"})

if __name__ == "__main__":
    app.run(debug=True, host="127.0.0.1", port=5000)
