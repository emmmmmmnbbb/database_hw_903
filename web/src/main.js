import { createApp } from "vue";
import App from "./App.vue";
import * as ElementPlusIconsVue from "@element-plus/icons-vue";
import Router from "./router/index.js";
import mitt from 'mitt' 
// 引入styles
import "@/styles/index.scss";
// 引入pinia
import { createPinia } from "pinia";
// 引入animate动画库
import "animate.css";
// 引入自定义指令
import directive from "@/directive/index";
import zhCn from "element-plus/dist/locale/zh-cn.mjs";
import ElementPlus from "element-plus";
import { changeThemeColor } from "@/util/index";
changeThemeColor("#20a162");
const pinia = createPinia();
const app = createApp(App);
//全局注册Element Icon
for (let iconName in ElementPlusIconsVue) {
  app.component(iconName, ElementPlusIconsVue[iconName]);
}
// 事件总线
app.config.globalProperties.emitter = mitt();
// 注册ElementPlus
app.use(ElementPlus, {
  locale: zhCn,
});
app.use(pinia);
app.use(Router);
app.use(directive);
app.mount("#app");
