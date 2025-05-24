<template>
  <div class="header">
    <div class="header-left">
      <el-icon
        class="icon-collapse"
        :size="20"
        v-if="!store.isCollapse"
        @click="changeCollapse"
        ><Fold
      /></el-icon>
      <el-icon
        class="icon-collapse"
        :size="20"
        v-if="store.isCollapse"
        @click="changeCollapse"
        ><Expand
      /></el-icon>
      <div class="breadcrumb-box mask-image">
        <el-breadcrumb separator-icon="ArrowRight">
          <transition-group name="breadcrumb">
            <el-breadcrumb-item v-for="item in breadcrumbList" :key="item.path">
              <div class="el-breadcrumb__inner is-link">
                <el-icon class="breadcrumb-icon">
                  <component :is="item.icon"></component>
                </el-icon>
                <span class="breadcrumb-title" v-text="item.name"></span>
              </div>
            </el-breadcrumb-item>
          </transition-group>
        </el-breadcrumb>
      </div>
    </div>
    <div class="header-right">
      <img
        class="header-avatar"
        :src="filterPhoto(data.loginUser.headPic)"
        alt="avatar"
      />
      <el-dropdown
        style="margin-left: 10px"
        :hide-on-click="false"
        @command="handleCommand"
      >
        <div class="header-dropdown">
          <span v-text="data.loginUser.username"></span>
          <el-icon><arrow-down /></el-icon>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="userInfo">个人中心</el-dropdown-item>
            <el-dropdown-item command="logout">退出登录</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
    <Dialog
      ref="userDialogRef"
      title="修改个人信息"
      @onConfirm="saveUser"
      @onCancel="getLoginUser"
    >
      <template #content>
        <el-form :model="data.userForm" label-width="100px">
          <el-form-item label="用户昵称">
            <el-input
              v-model="data.userForm.username"
              placeholder="请输入用户昵称"
            ></el-input>
          </el-form-item>
          <el-form-item label="用户头像">
            <div style="display: flex; align-items: center">
              <el-image
                id="headPic-view"
                :src="filterPhoto(data.userForm.headPic)"
                style="width: 100px; height: 70px; margin-right: 10px"
              />
              <el-button
                type="primary"
                icon="UploadFilled"
                plain
                @click="openUpload"
                >上传图片</el-button
              >
              <input
                type="file"
                id="headPic-file"
                style="display: none"
                @change="uploadPhoto"
              />
            </div>
          </el-form-item>
          <el-form-item label="用户密码">
            <el-input
              type="password"
              v-model="data.userForm.password"
              placeholder="请输入用户昵称"
            ></el-input>
          </el-form-item>
          <el-form-item label="手机号码">
            <el-input
              v-model="data.userForm.phone"
              placeholder="请输入手机号码"
            ></el-input>
          </el-form-item>
          <el-form-item label="用户性别">
            <el-select v-model="data.userForm.sex" placeholder="请选择用户性别">
              <el-option label="男" :value="1" />
              <el-option label="女" :value="2" />
              <el-option label="未知" :value="3" />
            </el-select>
          </el-form-item>
        </el-form>
      </template>
    </Dialog>
  </div>
</template>

<script setup>
import usePiniaStore from "@/store/index.js";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { getBreadcrumbList } from "@/util/index.js";
import Dialog from "@/components/Dialog/index.vue";
import { computed, reactive, onMounted, ref } from "vue";
import {
  axiosPostRequest,
  getSessionStorage,
  myEventBus,
} from "@/util/index.js";
const emitter = myEventBus();
const store = usePiniaStore();
const route = useRoute();
const router = useRouter();
const changeCollapse = () => {
  store.setCollapse(store.isCollapse);
};

emitter.on("refresh", () => {
  getLoginUser();
});

const userDialogRef = ref();

onMounted(() => {
  getLoginUser();
});

// 打开上传图片窗口
const openUpload = () => {
  document.getElementById("headPic-file").click();
};
// 上传图片操作
const uploadPhoto = async () => {
  let fileObj = document.getElementById("headPic-file");
  if (fileObj.value === "") return;
  let config = {
    headers: { "Content-Type": "multipart/form-data" },
  };
  let formData = new FormData();
  formData.append("photo", fileObj.files[0]);
  const response = await axiosPostRequest("/photo/upload", formData, config);
  fileObj.value = "";
  if (response.code === 0) {
    ElMessage.success(response.msg);
    document.getElementById("headPic-view").src =
      import.meta.env.VITE_SERVER + "/photo/view?filename=" + response.data;
    data.userForm.headPic = response.data;
  } else {
    ElMessage.error(response.msg);
  }
};

const data = reactive({
  loginUser: {
    id: "",
    headPic: "common/no_image.jpg",
    username: "",
    roleId: 1,
  },
  userForm: {
    id: "",
    username: "",
    password: "",
    headPic: "common/no_image.jpg",
    phone: "",
    sex: 3,
  },
});

const filterPhoto = computed(() => (photo) => {
  return import.meta.env.VITE_SERVER + "/photo/view?filename=" + photo;
});

// 获取当前登录用户
const getLoginUser = async () => {
  const response = await axiosPostRequest("/user/check_login", {
    token: getSessionStorage(),
  });
  if (response.code === 0) {
    data.loginUser = response.data;
    data.userForm = JSON.parse(JSON.stringify(response.data));
  } else {
    ElMessage.error(response.msg);
    router.push("/login");
  }
};

// 退出登录操作
const handleLogout = async () => {
  const response = await axiosPostRequest("/user/logout", {
    token: getSessionStorage(),
  });
  if (response.code === 0) {
    ElMessage.success(response.msg);
    router.push("/login");
  } else {
    ElMessage.error(response.msg);
  }
};

// 下拉框选项点击监听
const handleCommand = (command) => {
  if (command === "logout") {
    handleLogout();
  } else if (command === "userInfo") {
    userDialogRef.value.openDialog();
  }
};

// 保存用户信息
const saveUser = async () => {
  const response = await axiosPostRequest("/user/save", {
    ...data.userForm,
    token: getSessionStorage(),
  });
  if (response.code === 0) {
    ElMessage.success(response.msg);
    userDialogRef.value.closeDialog();
    emitter.emit("refresh");
  } else {
    ElMessage.error(response.msg);
  }
};

// 获取面包屑数据
const breadcrumbList = computed(() => {
  return getBreadcrumbList(
    store.menuList,
    route.matched.length > 0
      ? route.matched[route.matched.length - 1].path
      : "",
    []
  );
});
onMounted(() => {});
</script>
<style lang="scss" scoped>
.breadcrumb-enter-active {
  transition: all 0.2s;
}
.breadcrumb-enter-from,
.breadcrumb-leave-active {
  opacity: 0;
  transform: translateX(10px);
}
.header {
  display: flex;
  justify-content: space-between;
  height: 56px;
  .header-left {
    display: flex;
    align-items: center;
    overflow: hidden;
    white-space: nowrap;
    .icon-collapse {
      color: #303133;
      outline: none;
      &:hover {
        color: #20a162;
        cursor: pointer;
      }
    }
    .breadcrumb-box {
      display: flex;
      align-items: center;
      margin-left: 20px;
      overflow: hidden;
      user-select: none;
      .el-breadcrumb {
        white-space: nowrap;
        .el-breadcrumb__item {
          position: relative;
          display: inline-block;
          float: none;
          .breadcrumb-title {
            font-weight: 600;
          }
          .el-breadcrumb__inner {
            display: inline-flex;
            &.is-link {
              color: #303133;
              &:hover {
                color: #20a162;
              }
            }
            .breadcrumb-icon {
              margin-top: 1px;
              margin-right: 6px;
              font-size: 16px;
            }
            .breadcrumb-title {
              margin-top: 2px;
            }
          }
          &:last-child .el-breadcrumb__inner,
          &:last-child .el-breadcrumb__inner:hover {
            color: #606266;
          }
          :deep(.el-breadcrumb__separator) {
            transform: translateY(-1px);
          }
        }
      }
    }
    .mask-image {
      padding-right: 50px;
      mask-image: linear-gradient(
        90deg,
        #000000 0%,
        #000000 calc(100% - 50px),
        transparent
      );
    }
  }
  .header-right {
    display: flex;
    align-items: center;
    .header-avatar {
      width: 34px;
      height: 34px;
      user-select: none;
      border-radius: 50%;
    }
    .header-dropdown {
      color: var(--el-color-primary);
      white-space: nowrap;
      cursor: pointer;
      outline: none; // 去除伪元素
    }
  }
}
</style>
