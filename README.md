# 智慧云充pro：一个电动车充电桩管理软件

## 项目简介
智慧充电管理系统是一个基于 Vue.js 和 Flask 的全栈项目，旨在提供充电桩管理、用户预约、订单管理、维修管理等功能，支持用户友好的界面和高效的后台服务。

## 项目结构
```
.
├── backend/                # 后端代码目录
│   ├── app.py             # Flask 主应用文件
│   ├── auth.py            # 用户认证模块
│   ├── config.py          # 配置文件
│   ├── main.py            # 后端入口文件
│   ├── requirements.txt   # 后端依赖
│   └── uploads/           # 文件上传目录
├── database/              # 数据库文件目录
│   └── charge_db.sql      # 数据库初始化脚本
├── web/                   # 前端代码目录
│   ├── index.html         # 前端入口文件
│   ├── package.json       # 前端依赖
│   ├── src/               # 前端源码
│   │   ├── App.vue        # Vue 主组件
│   │   ├── main.js        # Vue 入口文件
│   │   ├── components/    # 公共组件
│   │   ├── directive/     # 自定义指令
│   │   ├── router/        # 路由配置
│   │   ├── store/         # Vuex 状态管理
│   │   ├── styles/        # 样式文件
│   │   ├── util/          # 工具函数
│   │   └── views/         # 页面组件
│   └── vite.config.js     # Vite 配置文件
└── README.md              # 项目说明文件
```

## 功能模块
1. **用户管理**
   - 用户注册、登录、登出
   - 用户积分和优惠券管理

2. **充电桩管理**
   - 充电桩状态管理
   - 充电桩预约和充电会话

3. **订单管理**
   - 订单创建、支付、删除
   - 支持优惠券和积分支付

4. **维修管理**
   - 充电桩报修和状态更新

5. **通知和评论**
   - 用户评论管理
   - 系统通知

## 技术栈
- **前端**：Vue.js 3、Element Plus、Vite
- **后端**：Flask、SQLAlchemy、Flask-CORS
- **数据库**：MySQL

## 安装与运行

### 1. 克隆项目
```bash
git clone https://github.com/emmmmmmnbbb/database_hw_903.git
cd zhyc_pro
```

### 2. 后端配置
1. 安装依赖：
   ```bash
   cd backend
   pip install -r requirements.txt
   ```
2. 初始化数据库：
   ```bash
   mysql -u root -p < database/charge_db.sql
   ```
3. 启动后端服务：
   ```bash
   python app.py
   ```


### 3. 前端配置
1. 安装依赖：
   ```bash
   cd web
   npm install
   ```
2. 启动前端服务：
   ```bash
   npm run dev
   ```

### 4. 访问项目
- 前端地址：`http://localhost:7777`
- 后端地址：`http://localhost:5000`
- 前端可以使用默认浏览器自动跳转，后端没有做可视化处理因此什么东西都没有

## 数据库设计
数据库设计包括以下主要表：
- `user`：用户表
- `charge`：充电桩表
- `appoint`：预约表
- `chargingsession`：充电会话表
- `orders`：订单表
- `repair`：维修表
- `comment`：评论表
- `station`：充电站表

## 贡献
欢迎提交 Issue 或 Pull Request 来改进本项目。

## 许可证
本项目采用 MIT 许可证。