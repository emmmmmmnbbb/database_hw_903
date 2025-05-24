// 初始设置表格高度
const setTableHeight = (el, binding) => {
  const top = el.offsetTop;
  const pageHeight = window.innerHeight;
  el.style.height = `${pageHeight - top - 114}px`;
  el.style.overflowY = "auto";
};

const resizeDirective = {
  mounted(el, binding) {
    el.resizeListener = () => {
      requestAnimationFrame(() => {
        setTableHeight(el, binding);
      });
    };

    setTableHeight(el, binding);
    // 监听窗口大小变化事件
    window.addEventListener("resize", el.resizeListener);
  },
  unmounted(el) {
    window.removeEventListener("resize", el.resizeListener);
  },
  updated(el, binding) {
    // 确保更新后重新设置表格高度
    requestAnimationFrame(() => {
      setTableHeight(el, binding);
    });
  },
};

export default resizeDirective;
