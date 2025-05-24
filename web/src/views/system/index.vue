<template>
  <div
    style="
      padding: 6px;
      display: flex;
      flex-direction: column;
      height: calc(100% - 12px);
    "
  >
    <el-card class="card" shadow="hover" style="flex-shrink: 0; flex-grow: 0">
      <div
        class="user"
        v-waterMarker="{ text: 'Welcome', textColor: '#D9D9D9' }"
      >
        <img
          class="user-img"
          :src="getLocalLogo"
          alt="avatar"
        />
        <div style="padding-left: 20px">
          <div class="user-info">
            <span v-text="data.loginUser.username"></span>
            <span
              v-if="data.loginUser.roleId === 1"
              style="color: rgb(64 158 255)"
              >[普通用户]</span
            >
            <span
              v-if="data.loginUser.roleId === 2"
              style="color: rgb(64 158 255)"
              >[管理员]</span
            >
          </div>
          <div class="user-info" style="padding-bottom: 0">
            欢迎来到充电桩管理系统🛵
          </div>
        </div>
      </div>
    </el-card>
    <el-row :gutter="20" style="margin-top: 5px; flex-shrink: 0; flex-grow: 0">
      <el-col :span="6" :lg="6" :md="12" :sm="12" :xs="24">
        <el-card class="card" shadow="hover">
          <div class="data-status">
            <span class="title" v-if="data.loginUser.roleId === 1"
              >我的预约数</span
            >
            <span class="title" v-if="data.loginUser.roleId === 2"
              >全部预约数</span
            >
            <el-tag type="info">总数</el-tag>
          </div>
          <div class="value" v-text="data.appointList.length"></div>
        </el-card>
      </el-col>
      <el-col :span="6" :lg="6" :md="12" :sm="12" :xs="24">
        <el-card class="card" shadow="hover">
          <div class="data-status">
            <span class="title" v-if="data.loginUser.roleId === 1"
              >我的告警数</span
            >
            <span class="title" v-if="data.loginUser.roleId === 2"
              >全部告警数</span
            >
            <el-tag type="success">总数</el-tag>
          </div>
          <div class="value" v-text="data.warnList.length"></div>
        </el-card>
      </el-col>
      <el-col :span="6" :lg="6" :md="12" :sm="12" :xs="24">
        <el-card class="card" shadow="hover">
          <div class="data-status">
            <span class="title" v-if="data.loginUser.roleId === 1"
              >我的订单数</span
            >
            <span class="title" v-if="data.loginUser.roleId === 2"
              >全部订单数</span
            >
            <el-tag type="warning">总数</el-tag>
          </div>
          <div class="value" v-text="data.orderList.length"></div>
        </el-card>
      </el-col>
      <el-col :span="6" :lg="6" :md="12" :sm="12" :xs="24">
        <el-card class="card" shadow="hover">
          <div class="data-status">
            <span class="title" v-if="data.loginUser.roleId === 1"
              >我的留言数</span
            >
            <span class="title" v-if="data.loginUser.roleId === 2"
              >全部留言数</span
            >
            <el-tag type="danger">总数</el-tag>
          </div>
          <div class="value" v-text="data.commentList.length"></div>
        </el-card>
      </el-col>
    </el-row>
    <el-row
      :gutter="20"
      style="margin-top: 5px; flex-shrink: 1; flex-grow: 1; overflow-y: auto"
    >
      <el-col
        :span="12"
        :lg="12"
        :md="12"
        :sm="24"
        :xs="24"
        style="height: 100%"
      >

      </el-col>
      <el-col :span="12" :lg="12" :md="12" :sm="24" :xs="24">
        <el-card class="card" shadow="hover">
          <el-calendar>
            <template #date-cell="{ data }">
              <div>
                <div>
                  {{ data.day.split("-").slice(2).join("-") }}
                  <div
                    v-if="getAppointedNum(data.day) > 0"
                    style="
                      font-size: 10px;
                      margin-top: 5px;
                      color: rgb(64 158 255);
                    "
                  >
                    {{ getAppointedNum(data.day) }}个预约
                  </div>
                </div>
              </div>
            </template>
          </el-calendar>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage } from "element-plus";
import {
  axiosPostRequest,
  getSessionStorage,
  myEventBus,
} from "@/util/index.js";
import { useRouter } from "vue-router";
import logoImage from "@/assets/logo.png"; //导入本地图片
const router = useRouter();
const emitter = myEventBus();
emitter.on("refresh", () => {
  getLoginUser();
});
onMounted(() => {
  getLoginUser();
});

const data = reactive({
  loginUser: {
    id: "",
    // headPic: "common/no_image.jpg",
    username: "",
    roleId: 1,
  },
  appointedList: [],
  appointList: [],
  rateList: [],
  warnList: [],
  orderList: [],
  commentList: [],
});

// 替换原来的 filterPhoto 计算属性
const getLocalLogo = () => {
  return logoImage;
};

// const filterPhoto = computed(() => (photo) => {
//   return import.meta.env.VITE_SERVER + "/photo/view?filename=" + photo;
// });

// 获取当前登录用户
const getLoginUser = async () => {
  const response = await axiosPostRequest("/user/check_login", {
    token: getSessionStorage(),
  });
  if (response.code === 0) {
    data.loginUser = response.data;
    getAppointList();
    getAppointedList();
    getRateList();
    getOrderList();
    getWarnList();
    getCommentList();
  } else {
    ElMessage.error(response.msg);
    router.push("/login");
  }
};



// 获取当前登录用户的预约数据
const getAppointList = async () => {
  // 使用模拟数据
  data.appointList = [
    { id: 1, userId: data.loginUser.id, station: "充电站A", time: "2025-05-14 10:00", status: "待充电" },
    { id: 2, userId: data.loginUser.id, station: "充电站B", time: "2025-05-15 14:30", status: "已完成" },
    { id: 3, userId: data.loginUser.id, station: "充电站C", time: "2025-05-16 09:15", status: "已取消" }
  ];
};

// 获取日历上预约数据
const getAppointedList = async () => {
  // 使用模拟数据
  const today = new Date();
  const formatDate = (date) => {
    return date.toISOString().split('T')[0];
  };
  
  // 为接下来7天创建模拟预约数据
  data.appointedList = [];
  for (let i = 0; i < 7; i++) {
    const date = new Date();
    date.setDate(today.getDate() + i);
    const count = Math.floor(Math.random() * 3) + 1; // 1-3个预约
    
    data.appointedList.push({
      day: formatDate(date),
      count: count
    });
  }
};

// 获取当前登录用户的积分明细
const getRateList = async () => {
  // 使用模拟数据
  data.rateList = [
    { id: 1, userId: data.loginUser.id, points: 100, description: "充电完成", date: "2025-05-10" },
    { id: 2, userId: data.loginUser.id, points: 50, description: "按时充电", date: "2025-05-12" },
    { id: 3, userId: data.loginUser.id, points: -20, description: "迟到", date: "2025-05-13" }
  ];
};

// 获取当前登录用户的告警数据
const getWarnList = async () => {
  // 使用模拟数据
  data.warnList = [
    { id: 1, userId: data.loginUser.id, type: "充电异常", description: "充电过程中断", time: "2025-05-14 10:30" },
    { id: 2, userId: data.loginUser.id, type: "设备异常", description: "设备温度过高", time: "2025-05-13 15:45" }
  ];
};

// 获取当前登录用户的订单数据
const getOrderList = async () => {
  // 使用模拟数据
  data.orderList = [
    { id: 101, userId: data.loginUser.id, amount: 50, status: "已支付", time: "2025-05-14 11:00" },
    { id: 102, userId: data.loginUser.id, amount: 30, status: "已支付", time: "2025-05-12 13:20" },
    { id: 103, userId: data.loginUser.id, amount: 45, status: "待支付", time: "2025-05-15 09:45" }
  ];
};

// 获取当前登录用户的留言数据
const getCommentList = async () => {
  // 使用模拟数据
  data.commentList = [
    { id: 201, userId: data.loginUser.id, content: "服务很满意", time: "2025-05-13 12:00", reply: "感谢您的支持" },
    { id: 202, userId: data.loginUser.id, content: "充电速度很快", time: "2025-05-10 14:30", reply: "" }
  ];
};

// 获取预约数
const getAppointedNum = computed(() => (day) => {
  const appointmentOnDay = data.appointedList.find(item => item.day === day);
  return appointmentOnDay ? appointmentOnDay.count : 0;
});


// // 获取预约数
// const getAppointedNum = computed(() => (day) => {
//   let count = 0;
//   data.appointedList.forEach((item) => {
//     if (item.day === day) {
//       count++;
//     }
//   });
//   return count;
// });

// // 获取当前登录用户的预约数据
// const getAppointList = async () => {
//   const response = await axiosPostRequest("/appoint/all", {
//     userId: data.loginUser.roleId === 1 ? data.loginUser.id : "",
//   });
//   if (response.code === 0) {
//     data.appointList = response.data;
//   } else {
//     ElMessage.error(response.msg);
//   }
// };

// // 获取日历上预约数据
// const getAppointedList = async () => {
//   const response = await axiosPostRequest("/appoint/appointed", {
//     userId: data.loginUser.id,
//   });
//   if (response.code === 0) {
//     data.appointedList = response.data;
//   } else {
//     ElMessage.error(response.msg);
//   }
// };

// // 获取当前登录用户的积分明细
// const getRateList = async () => {
//   const response = await axiosPostRequest("/user/rate", {
//     id: data.loginUser.id,
//   });
//   if (response.code === 0) {
//     data.rateList = response.data;
//   } else {
//     ElMessage.error(response.msg);
//   }
// };

// // 获取当前登录用户的告警数据
// const getWarnList = async () => {
//   const response = await axiosPostRequest("/warn/all", {
//     userId: data.loginUser.roleId === 1 ? data.loginUser.id : "",
//   });
//   if (response.code === 0) {
//     data.warnList = response.data;
//   } else {
//     ElMessage.error(response.msg);
//   }
// };

// // 获取当前登录用户的订单数据
// const getOrderList = async () => {
//   const response = await axiosPostRequest("/order/all", {
//     userId: data.loginUser.roleId === 1 ? data.loginUser.id : "",
//   });
//   if (response.code === 0) {
//     data.orderList = response.data;
//   } else {
//     ElMessage.error(response.msg);
//   }
// };

// // 获取当前登录用户的留言数据
// const getCommentList = async () => {
//   const response = await axiosPostRequest("/comment/all", {
//     userId: data.loginUser.roleId === 1 ? data.loginUser.id : "",
//   });
//   if (response.code === 0) {
//     data.commentList = response.data;
//   } else {
//     ElMessage.error(response.msg);
//   }
// };
</script>
<style lang="scss" scoped>
.card {
  border-radius: 0.375rem;
  .user {
    display: flex;
    align-items: center;
    .user-img {
      user-select: none;
      width: 60px;
      height: 60px;
      border-radius: 50%;
    }
    .user-info {
      white-space: nowrap;
      padding-bottom: 8px;
      font-weight: bold;
    }
  }
  .data-status {
    display: flex;
    justify-content: space-between;
    .title {
      font-size: 0.875rem;
      line-height: 1.25rem;
    }
  }
  .value {
    font-size: 1.5rem;
    line-height: 2rem;
  }
  :deep(.el-calendar-day) {
    height: 50px !important;
    p {
      margin: 0 !important;
    }
  }
  :deep(.el-calendar__body) {
    padding: 0 20px;
  }
  :deep(.el-calendar__header) {
    padding: 0 20px 12px 20px;
  }
}
</style>
