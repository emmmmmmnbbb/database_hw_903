import jwt
import time

# JWT配置
JWT_SECRET = "charging_jwt_secret_2024"  # JWT 密钥
JWT_EXPIRE = 24 * 60 * 60  # token有效期24小时

def generateToken(data):
    """生成token"""
    payload = {
        "user": data,  # 用户数据
        "exp": int(time.time()) + JWT_EXPIRE  # 过期时间
    }
    return jwt.encode(payload, JWT_SECRET, algorithm='HS256')

def decodeToken(token):
    """验证token"""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
        if payload["exp"] < time.time():
            return None
        return payload["user"]
    except:
        return None

