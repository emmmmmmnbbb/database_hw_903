class BaseConfig:
    # 数据库配置
    DIALCT = "mysql"
    DRIVER = "pymysql"  # 使用 pymysql 驱动
    HOST = '127.0.0.1'
    PORT = "3306"
    USERNAME = "root"
    PASSWORD = "123456"
    DBNAME = 'charge_sql'

    # 构建 SQLAlchemy URI
    SQLALCHEMY_DATABASE_URI = f"{DIALCT}+{DRIVER}://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}"
    
    REDIS_HOST = '127.0.0.1'
    REDIS_PORT = 6379

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JSON_AS_ASCII = False