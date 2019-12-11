import Vue from 'vue';
import Router from 'vue-router';

Vue.use(Router);

const router = new Router({
    routes: [
        {
            path: '/',
            redirect: '/dashboard'
        },
        {
            path: '/',
            component: () => import(/* webpackChunkName: "home" */ '../components/common/Home.vue'),
            meta: { title: '自述文件' },
            children: [
                {
                    path: '/dashboard',
                    component: () => import(/* webpackChunkName: "dashboard" */ '../components/page/Dashboard.vue'),
                    meta: { title: '系统首页' }
                },
                {
                    path: '/finances',
                    component: () => import(/* webpackChunkName: "finances" */ '../components/page/Finances.vue'),
                    meta: { title: '融资' }
                },
                {
                    path: '/withdraws',
                    component: () => import(/* webpackChunkName: "withdraws" */ '../components/page/Withdraws.vue'),
                    meta: { title: '提现' }
                },
                {
                    path: '/coreCompanys',
                    component: () => import(/* webpackChunkName: "corecompanys" */ '../components/page/CoreCompanys.vue'),
                    meta: { title: '核心企业' }
                },
                {
                    path: '/banks',
                    component: () => import(/* webpackChunkName: "banks" */ '../components/page/Banks.vue'),
                    meta: { title: '银行清单' }
                },
                {
                    path: '/normalCompanys',
                    component: () => import(/* webpackChunkName: "normalcompanys" */ '../components/page/NormalCompanys.vue'),
                    meta: { title: '一般企业' }
                },
                {
                    path: '/receipts',
                    component: () => import(/* webpackChunkName: "receipts" */ '../components/page/Receipts.vue'),
                    meta: { title: '账单' }
                },
                {
                    path: '/tokens',
                    component: () => import(/* webpackChunkName: "Tokens" */ '../components/page/Tokens.vue'),
                    meta: { title: '所有Token' }
                },
                {
                    path: '/transfers',
                    component: () => import(/* webpackChunkName: "Transfers" */ '../components/page/Transfers.vue'),
                    meta: { title: '转让记录' }
                },
                {
                    path: '/newreceipt',
                    component: () => import(/* webpackChunkName: "form" */ '../components/page/NewReceipt.vue'),
                    meta: { title: '提交账单' }
                },
                {
                    path: '/404',
                    component: () => import(/* webpackChunkName: "404" */ '../components/page/404.vue'),
                    meta: { title: '404' }
                },
                {
                    path: '/403',
                    component: () => import(/* webpackChunkName: "403" */ '../components/page/403.vue'),
                    meta: { title: '403' }
                }
            ]
        },
        {
            path: '/login',
            component: () => import(/* webpackChunkName: "login" */ '../components/page/Login.vue'),
            meta: { title: '登录' }
        },
        {
            path: '*',
            redirect: '/404'
        }
    ]
});

//使用钩子函数对路由进行登录跳转
router.beforeEach((to, from, next) => {
    document.title = `${to.meta.title} | SupplyChain System`;
    const role = localStorage.getItem('usertype');
    if (!role && to.path !== '/login') {
        next('/login');
    } 
    else next()
});

export default router;
