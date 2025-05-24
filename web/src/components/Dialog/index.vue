<template>
  <el-dialog
    :model-value="visible"
    :title="title"
    :width="width"
    :close-on-click-modal="false"
    append-to-body
    draggable
    :destroy-on-close="true"
    :footerHidden="footerHidden"
  >
    <div class="container">
      <!-- 具名插槽 -->
      <slot name="content"></slot>
    </div>
    <template #footer v-if="!footerHidden">
      <span class="dialog-footer">
        <el-button type="primary" @click="onConfirm">{{
          confirmText
        }}</el-button>
        <el-button type="danger" @click="onCancel">{{ cancelText }}</el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
// 模态框是否显示
const visible = ref(false);

defineProps({
  title: {
    type: String,
    default: "-",
  },
  width: {
    type: String,
    default: "50%",
  },
  confirmText: {
    type: String,
    default: "确定",
  },
  cancelText: {
    type: String,
    default: "取消",
  },
  footerHidden: {
    type: Boolean,
    default: false,
  },
});

// 打开模态框
const openDialog = () => {
  visible.value = true;
};

// 关闭模态框
const closeDialog = () => {
  visible.value = false;
};

// 当前组件获取父组件传递的事件方法
const emits = defineEmits(["onConfirm", "onCancel"]);
// 模态框的确定事件
const onConfirm = () => {
  emits("onConfirm");
};

// 模态框的取消事件
const onCancel = () => {
  closeDialog();
  emits("onCancel");
};

defineExpose({
  openDialog,
  closeDialog,
});
</script>
<style lang="scss" scope>
.container {
  overflow-x: initial;
  overflow-y: auto; // 超出部分则滚动
  .el-dialog {
    border-top-left-radius: 8px !important;
    border-top-right-radius: 8px !important;

    // 标题头部
    .el-dialog__header {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 50px !important;
      padding: 0;
      margin-right: 0 !important;
      border-top-left-radius: 8px !important;
      border-top-right-radius: 8px !important;
      .el-dialog__title {
        font-family: YouYuan;
        font-size: 18px;
        font-weight: 500;
      }
    }
    .el-dialog__body {
      padding: 15px;
    }
    .el-dialog__footer {
      padding: 10px;
    }
    .el-dialog__headerbtn {
      padding-bottom: 10px !important;
      .el-dialog__close {
        border: 1px solid;
        border-radius: 10px;
      }
    }
  }
}
</style>
