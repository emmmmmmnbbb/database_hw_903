<template>
  <el-container class="layout-container">
    <el-aside
      class="layout-aside"
      :style="{ width: !store.isCollapse ? '220px' : '70px' }"
    >
      <div class="logo">
        <img src="@/assets/logo.png" class="logo-img" />
        <div
          class="logo-title animate__animated animate__fadeInLeft"
          v-show="!store.isCollapse"
        >
          充电桩管理系统
        </div>
      </div>
      <el-scrollbar class="layout-scrollbar">
        <!-- :unique-opened="true" 子菜单不能同时展开 -->
        <el-menu
          :router="false"
          :default-active="route.path"
          :collapse="store.isCollapse"
          :collapse-transition="false"
          class="animate__animated animate__fadeInLeft"
        >
          <AsideMenu :menuList="store.menuList"></AsideMenu>
        </el-menu>
      </el-scrollbar>
    </el-aside>
    <el-container>
      <el-header class="layout-header">
        <Header></Header>
      </el-header>
      <el-main class="layout-main">
        <router-view />
      </el-main>
      <el-footer class="layout-footer">
      </el-footer>
    </el-container>
  </el-container>
</template>

<script setup>
import AsideMenu from "@/components/AsideMenu/index.vue";
import Header from "@/components/Header/index.vue";
import usePiniaStore from "@/store/index.js";
import { useRoute, useRouter } from "vue-router";
const route = useRoute();
const store = usePiniaStore();
</script>

<style lang="scss" scoped>
.layout-container {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  .layout-aside {
    z-index: 10;
    padding-right: 2px;
    padding-left: 2px;
    background-color: #fff;
    border-right: none;
    box-shadow: 2px 0 12px #1d23290d;
    // transition-property: all;
    // transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    // transition-duration: 150ms;
  }
  .layout-header {
    height: 56px;
    background-color: #fff;
  }
  .layout-main {
    box-sizing: border-box;
    padding: 0;
    overflow-x: hidden;
    background-color: #fff;
  }
  .layout-footer {
    height: 40px;
    display: flex;
    justify-content: center;
    align-items: center;
    font-weight: bold;
  }
}
.el-menu {
  border-right: none;
}
.layout-scrollbar {
  width: 100%;
  height: calc(100vh - 56px);
}
.logo {
  display: flex;
  align-items: center;
  width: 100%;
  height: 56px;
  line-height: 56px;
  text-align: center;
  .logo-title {
    font-weight: bold;
    font-size: 18px;
    user-select: none;
  }
  .logo-img {
    height: 34px;
    width: 34px;
    margin-left: 12px;
    margin-right: 15px;
  }
}

.el-menu--collapse {
  width: 70px;
}
</style>
