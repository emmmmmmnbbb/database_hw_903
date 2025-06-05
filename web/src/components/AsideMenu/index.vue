<template>
  <template v-for="item in filteredMenuList" :key="item.path">
    <el-sub-menu v-if="item?.children && item.children.length" :index="item.path">
      <template #title>
        <el-icon>
          <component :is="item.icon"></component>
        </el-icon>
        <span v-text="item.name"></span>
      </template>
      <AsideMenu :menuList="item.children"></AsideMenu>
    </el-sub-menu>
    <el-menu-item v-else :index="item.path" @click="clickMenuItem(item)">
      <el-icon>
        <component :is="item.icon"></component>
      </el-icon>
      <template #title>
        <span v-text="item.name"></span>
      </template>
    </el-menu-item>
  </template>
</template>
<script setup>
import AsideMenu from "@/components/AsideMenu/index.vue";
import { useRoute, useRouter } from "vue-router";
import { computed } from "vue";

// 获取当前用户信息（请根据你的实际项目调整获取方式）
const userInfo = JSON.parse(localStorage.getItem("userInfo") || "{}");
const roleId = userInfo?.roleId ?? 1; // 默认为1，普通用户

const props = defineProps(["menuList"]);
const router = useRouter();

const filterMenu = (list, roleId) => {
  return list
    .filter(item => !item.roles || item.roles.includes(roleId))
    .map(item => ({
      ...item,
      children: item.children ? filterMenu(item.children, roleId) : undefined
    }))
    .filter(item => !item.children || item.children.length > 0); // 没有子菜单的父菜单不显示
};

const filteredMenuList = computed(() => filterMenu(props.menuList, roleId));

const clickMenuItem = (value) => {
  router.push(value.path);
};
</script>
<style lang="scss" scoped>
.el-menu-item {
  height: 40px;
  margin-bottom: 3px;
  font-weight: 500;
  color: #000;
  user-select: none;
  border-left: 6px solid #fff;
  border-radius: 6px;
  i {
    transform: translate(-8px); // 图标偏移
  }
  span {
    transform: translate(-8px); // 文字偏移
  }

  &:hover {
    background: var(--el-color-primary-light-8);
    border-left: 6px solid var(--el-color-primary);
    border-radius: 6px;
    i {
      color: var(--el-color-primary);
    }
  }
  &.is-active {
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-8);
    border-left: 6px solid var(--el-color-primary);
  }
}
:deep(.el-sub-menu__title) {
  height: 40px;
  padding-right: 0;
  margin-bottom: 3px;
  font-weight: 500;
  color: #000000;
  user-select: none;
  border-left: 6px solid #fff;
  border-radius: 6px;

  i {
    transform: translate(-8px); // 图标偏移
  }
  span {
    transform: translate(-8px); // 文字偏移
  }

  &:hover {
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-8);
    border-left: 6px solid var(--el-color-primary);
  }
  &:active {
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-8);
    border-left: 6px solid var(--el-color-primary);
  }
}
</style>