import axios from "axios"

const api = axios.create({
    // 使用相对路径，让代理配置生效
    baseURL: "/api",
    timeout: 5000
})

// 请求拦截器
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.token = token;
    }
    return config;
});

// 响应拦截器
api.interceptors.response.use(
    response => {
        return response;
    },
    error => {
        if (error.response.status === 401) {
            // 未授权，跳转到登录页
            localStorage.removeItem('token');
            localStorage.removeItem('userType');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

// 用户相关接口
export const userApi = {
    login: (data) => api.post('/login', data),
    register: (data) => api.post('/register', data),
    updateProfile: (data) => api.put('/user/profile', data),
    changePassword: (data) => api.put('/user/password', data)
};

// 充电站相关接口
export const stationApi = {
    getStations: () => api.get('/stations'),
    getStationDetail: (id) => api.get(`/stations/${id}`),
    getAvailablePiles: (stationId) => api.get(`/stations/${stationId}/piles`),
    // 管理端接口
    addStation: (data) => api.post('/manager/stations', data),
    updateStation: (id, data) => api.put(`/manager/stations/${id}`, data),
    deleteStation: (id) => api.delete(`/manager/stations/${id}`)
};

// 充电记录相关接口
export const chargingApi = {
    // 用户端接口
    startCharging: (data) => api.post('/charging/start', data),
    stopCharging: () => api.post('/charging/stop'),
    getCurrentStatus: () => api.get('/charging/status'),
    getUserHistory: () => api.get('/charging/history'),
    // 管理端接口
    getActiveRecords: () => api.get('/manager/charging/active'),
    getHistoryRecords: () => api.get('/manager/charging/history')
};

export default api;