class BaseConfig(object):
    # 数据库配置
    DIALCT = "mysql"
    DRIVER = "pymysql"
    HOST = '127.0.0.1'
    PORT = "3306"
    USERNAME = "root"
    PASSWORD = "123456"  # 数据库密码
    DBNAME = 'charge_sql'  # 充电平台数据库名

    REDIS_HOST = '127.0.0.1'
    REDIS_PORT = 6379

    SQLALCHEMY_DATABASE_URI = f"{DIALCT}+{DRIVER}://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}?charset=utf8"
    SQLALCHEMY_TRACK_MODIFICATIONS = True

    # JWT密钥
    # SECRET_KEY = 'charging_platform_secret_key'