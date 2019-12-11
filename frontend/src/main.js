import Vue from 'vue';
import App from './App.vue';
import axios from 'axios'
import router from './router';
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css'; // 默认主题
// import './assets/css/theme-green/index.css'; // 浅绿色主题
import './assets/css/icon.css';
import './components/common/directives';
import 'babel-polyfill';

Vue.use(ElementUI, {
    size: 'small'
});


Vue.config.productionTip = false
axios.defaults.baseURL = 'http://ydchen.top:3000'
Vue.prototype.$http = axios
Vue.prototype.$http.defaults.withCredentials = true

new Vue({
    router,
    render: h => h(App)
}).$mount('#app');
