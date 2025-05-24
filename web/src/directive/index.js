import adaptive from "./modules/adaptive";
import waterMarker from "./modules/waterMarker";
const directivesList = {
  adaptive,
  waterMarker,
};

const directives = {
  install: function (app) {
    Object.keys(directivesList).forEach((key) => {
      // 注册所有自定义指令
      app.directive(key, directivesList[key]);
    });
  },
};

export default directives;
