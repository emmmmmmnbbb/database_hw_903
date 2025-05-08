<template>
    <div class="login-container">
        <div class="login-box">
            <div class="title">智慧云充PRO</div>
            <el-tabs v-model="activeTab">
                <el-tab-pane label="登录" name="login">
                    <el-form :model="loginForm" :rules="loginRules" ref="loginForm">
                        <el-form-item prop="username">
                            <el-input v-model="loginForm.username" prefix-icon="el-icon-user" placeholder="用户名">
                            </el-input>
                        </el-form-item>
                        <el-form-item prop="password">
                            <el-input v-model="loginForm.password" prefix-icon="el-icon-lock" type="password"
                                placeholder="密码">
                            </el-input>
                        </el-form-item>
                        <el-form-item class="login-type">
                            <el-radio-group v-model="loginForm.type">
                                <el-radio label="user">用户登录</el-radio>
                                <el-radio label="admin">管理员登录</el-radio>
                            </el-radio-group>
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" class="submit-btn" @click="handleLogin">登录</el-button>
                        </el-form-item>
                    </el-form>
                </el-tab-pane>
                <el-tab-pane label="注册" name="register">
                    <el-form :model="registerForm" :rules="registerRules" ref="registerForm">
                        <el-form-item prop="username">
                            <el-input v-model="registerForm.username" prefix-icon="el-icon-user" placeholder="用户名">
                            </el-input>
                        </el-form-item>
                        <el-form-item prop="password">
                            <el-input v-model="registerForm.password" prefix-icon="el-icon-lock" type="password"
                                placeholder="密码">
                            </el-input>
                        </el-form-item>
                        <el-form-item prop="confirmPassword">
                            <el-input v-model="registerForm.confirmPassword" prefix-icon="el-icon-lock" type="password"
                                placeholder="确认密码">
                            </el-input>
                        </el-form-item>
                        <el-form-item prop="phone">
                            <el-input v-model="registerForm.phone" prefix-icon="el-icon-phone" placeholder="手机号">
                            </el-input>
                        </el-form-item>
                        <el-form-item prop="carPlate">
                            <el-input v-model="registerForm.carPlate" prefix-icon="el-icon-truck" placeholder="车牌号">
                            </el-input>
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" class="submit-btn" @click="handleRegister">注册</el-button>
                        </el-form-item>
                    </el-form>
                </el-tab-pane>
            </el-tabs>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        // 验证密码一致性
        const validateConfirmPassword = (rule, value, callback) => {
            if (value !== this.registerForm.password) {
                callback(new Error('两次输入的密码不一致'));
            } else {
                callback();
            }
        };
        // 验证手机号
        const validatePhone = (rule, value, callback) => {
            if (!/^1[3-9]\d{9}$/.test(value)) {
                callback(new Error('请输入正确的手机号'));
            } else {
                callback();
            }
        };
        // 验证车牌号
        const validateCarPlate = (rule, value, callback) => {
            if (!/^[A-Z]\d{4}$/.test(value)) {
                callback(new Error('请输入正确的车牌号（一个大写字母加四位数字）'));
            } else {
                callback();
            }
        };

        return {
            activeTab: 'login',
            loginForm: {
                username: '',
                password: '',
                type: 'user'
            },
            registerForm: {
                username: '',
                password: '',
                confirmPassword: '',
                phone: '',
                carPlate: ''
            },
            loginRules: {
                username: [
                    { required: true, message: '请输入用户名', trigger: 'blur' }
                ],
                password: [
                    { required: true, message: '请输入密码', trigger: 'blur' }
                ]
            },
            registerRules: {
                username: [
                    { required: true, message: '请输入用户名', trigger: 'blur' }
                ],
                password: [
                    { required: true, message: '请输入密码', trigger: 'blur' }
                ],
                confirmPassword: [
                    { required: true, message: '请确认密码', trigger: 'blur' },
                    { validator: validateConfirmPassword, trigger: 'blur' }
                ],
                phone: [
                    { required: true, message: '请输入手机号', trigger: 'blur' },
                    { validator: validatePhone, trigger: 'blur' }
                ],
                carPlate: [
                    { required: true, message: '请输入车牌号', trigger: 'blur' },
                    { validator: validateCarPlate, trigger: 'blur' }
                ]
            }
        }
    },
    methods: {
        handleLogin() {
            this.$refs.loginForm.validate(valid => {
                if (valid) {
                    this.$axios.post('/login', this.loginForm).then(res => {
                        if (res.data.status === 200) {
                            localStorage.setItem('token', res.data.token);
                            localStorage.setItem('userType', this.loginForm.type);
                            this.$message.success('登录成功');
                            if (this.loginForm.type === 'user') {
                                this.$router.push('/user');
                            } else {
                                this.$router.push('/manage');
                            }
                        } else {
                            this.$message.error(res.data.message);
                        }
                    });
                }
            });
        },
        handleRegister() {
            this.$refs.registerForm.validate(valid => {
                if (valid) {
                    this.$axios.post('/register', this.registerForm).then(res => {
                        if (res.data.status === 200) {
                            this.$message.success('注册成功，请登录');
                            this.activeTab = 'login';
                        } else {
                            this.$message.error(res.data.message);
                        }
                    });
                }
            });
        }
    }
}
</script>

<style scoped>
.login-container {
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #f5f5f5;
}

.login-box {
    width: 400px;
    padding: 30px;
    background-color: #fff;
    border-radius: 4px;
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.title {
    text-align: center;
    font-size: 24px;
    font-weight: bold;
    margin-bottom: 30px;
    color: #409EFF;
}

.submit-btn {
    width: 100%;
}

.login-type {
    text-align: center;
    margin-bottom: 20px;
}
</style>