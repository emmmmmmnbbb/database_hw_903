import axios from "axios";
import { getCurrentInstance } from "vue";
const BASE_URL = import.meta.env.VITE_WEB_BASE_API;
// const BASE_URL = 'http://192.168.13.2:8085';
const SESSION_KEY_LOGIN = "SESSION_KEY_LOGIN";

// 获取面包屑数据
export const getBreadcrumbList = (menuList, path, result) => {
  for (const item of menuList) {
    if (item?.children) {
      let childrenResult = getBreadcrumbList(item.children, path, result);
      if (childrenResult.length > 0) {
        childrenResult.unshift(item);
        return childrenResult;
      }
    } else if (item.path === path) {
      result.unshift(item);
      return result;
    }
  }

  return result;
};

/**
 * @description hex颜色转rgb颜色
 * @param {String} str 颜色值字符串
 * @returns {String} 返回处理后的颜色值
 */
export const hexToRgb = (str) => {
  let hex = "";
  let reg = /^\#?[0-9A-Fa-f]{6}$/;
  str = str.replace("#", "");
  hex = str.match(/../g);
  for (let i = 0; i < 3; i++) hex[i] = parseInt(hex[i], 16);
  return hex;
};

/**
 * @description rgb颜色转Hex颜色
 * @param {*} r 代表红色
 * @param {*} g 代表绿色
 * @param {*} b 代表蓝色
 * @returns {String} 返回处理后的颜色值
 */
export const rgbToHex = (r, g, b) => {
  let hex = [r.toString(16), g.toString(16), b.toString(16)];
  for (let i = 0; i < 3; i++) if (hex[i].length == 1) hex[i] = `0${hex[i]}`;
  return `#${hex.join("")}`;
};

/**
 * @description 变浅颜色值
 * @param {String} color 颜色值字符串
 * @param {Number} level 加深的程度，限0-1之间
 * @returns {String} 返回处理后的颜色值
 */
export const getLightColor = (color, level) => {
  let rgb = hexToRgb(color);
  for (let i = 0; i < 3; i++)
    rgb[i] = Math.round(255 * level + rgb[i] * (1 - level));
  return rgbToHex(rgb[0], rgb[1], rgb[2]);
};

// 计算主题颜色变化
export const changeThemeColor = (val) => {
  document.documentElement.style.setProperty("--el-color-primary", val);
  for (let i = 1; i <= 9; i++) {
    const primaryColor = getLightColor(val, i / 10);
    document.documentElement.style.setProperty(
      `--el-color-primary-light-${i}`,
      primaryColor
    );
  }
};

// axios封装工具类
export const axiosPostRequest = (url, data = {}, config = {}) => {
  config = {
    ...config,
    headers: {
      token: getSessionStorage(),
    },
  };
  return new Promise((resolve, reject) => {
    axios
      .post(BASE_URL + url, data, config)
      .then((response) => {
        resolve(response.data);
      })
      .catch((error) => {
        reject(error);
      });
  });
};

// 缓存设置
export const setSessionStorage = (data) => {
  let params = {
    data: data,
    time: Date.parse(new Date()) + 60 * 1000 * 60,
  };
  sessionStorage.setItem(SESSION_KEY_LOGIN, JSON.stringify(params));
};

// 缓存获取
export const getSessionStorage = () => {
  let v = sessionStorage.getItem(SESSION_KEY_LOGIN);
  if (v && typeof v !== "undefined" && v !== "undefined") {
    let params = JSON.parse(v);
    if (params.time) {
      if (params.time > Date.parse(new Date())) {
        return params.data;
      }
      sessionStorage.removeItem(SESSION_KEY_LOGIN);
    }
  }
};

// 事件总线
export const myEventBus = () => {
  const internalInstance = getCurrentInstance();
  const emitter = internalInstance.appContext.config.globalProperties.emitter;
  return emitter;
};
