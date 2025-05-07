import Vue from 'vue'
import VueRouter from 'vue-router'
import LogRes from '@/components/MyLogReg'
import user from '@/components/MyUser'
import manage from '@/components/MyManage'

Vue.use(VueRouter)

const router = new VueRouter({
    mode: 'history',
    routes: [
        {
            path: '/',
            name: 'root',
            redirect: '/login',
            meta: {
                title: "智慧云充电平台"
            }
        },
        {
            path: '/login',
            name: 'login',
            component: LogRes,
            meta: {
                title: "登录"
            },
        },
        {
            path: '/user',
            component: user,
            meta: {
                title: "用户界面"
            },
            children: [
                {
                    path: 'charging',
                    name: 'charging',
                    component: () => import('@/components/UserCharging.vue'),
                    meta: { title: "充电状态" }
                },
                {
                    path: 'history',
                    name: 'history',
                    component: () => import('@/components/UserHistory.vue'),
                    meta: { title: "充电记录" }
                }
            ]
        },
        {
            path: '/manage',
            component: manage,
            meta: {
                title: "后台管理界面"
            }
        },
    ]
})

// 路由守卫
router.beforeEach((to, from, next) => {
    // 设置页面标题
    document.title = to.meta.title || '智慧云充电平台'

    // 检查是否需要登录
    const publicPages = ['/', '/login']  // 添加根路径到公开页面
    const authRequired = !publicPages.includes(to.path)
    const token = localStorage.getItem('token')

    if (authRequired && !token) {
        return next('/login')
    }

    next()
})

export default router