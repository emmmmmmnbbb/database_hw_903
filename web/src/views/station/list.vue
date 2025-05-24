<template>
  <div style="padding: 6px 6px 0 6px">
    <el-card class="card-list" shadow="never">
      <el-form
        ref="searchFormRef"
        :inline="true"
        :model="dataList.searchParams"
      >
        <el-form-item label="电站名称" prop="name">
          <el-input
            v-model="dataList.searchParams.name"
            placeholder="请输入电站名称"
            style="width: 200px"
          ></el-input>
        </el-form-item>
        <el-form-item label="所属运营商" prop="operatorId">
          <el-select
            filterable
            v-model="dataList.searchParams.operatorId"
            placeholder="请选择所属运营商"
          >
            <el-option label="全部" :value="0" />
            <el-option
              v-for="item in dataList.operatorList"
              :label="item.name"
              :value="item.id"
              :key="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="search" plain @click="getStationList"
            >搜索</el-button
          >
          <el-button type="danger" icon="refresh" plain @click="resetSearchForm"
            >重置</el-button
          >
        </el-form-item>
      </el-form>

      <el-row :gutter="10" v-if="dataList.loginUser.roleId === 2">
        <el-col :span="1.5">
          <el-button type="primary" icon="plus" plain @click="openAddDialog"
            >新增</el-button
          >
        </el-col>
        <el-col :span="1.5">
          <el-button type="success" icon="edit" plain @click="openEditDialog"
            >修改</el-button
          >
        </el-col>
        <el-col :span="1.5">
          <el-button type="danger" icon="delete" plain @click="openRemoveDialog"
            >删除</el-button
          >
        </el-col>
      </el-row>

      <el-table
        border
        @selection-change="handleSelectionChange"
        v-adaptive
        :data="dataList.stationList"
        empty-text="暂时没查到数据哟🛵"
      >
        <el-table-column type="selection" width="55"> </el-table-column>
        <el-table-column label="序号" prop="id" width="140px"></el-table-column>
        <el-table-column
          label="电站名称"
          prop="name"
          width="200px"
        ></el-table-column>
        <el-table-column label="电站图片" width="145px">
          <template #default="scope">
            <div>
              <el-image
                :preview-teleported="true"
                :preview-src-list="[filterPhoto(scope.row.photo)]"
                style="width: 120px; height: 80px"
                :src="filterPhoto(scope.row.photo)"
              />
            </div>
          </template>
        </el-table-column>
        <el-table-column
          label="电站地址"
          prop="location"
          width="200px"
        ></el-table-column>
        <el-table-column
          label="充电桩总数量"
          width="130px"
          prop="chargeNum"
        ></el-table-column>
        <el-table-column
          label="可用充电桩数量"
          width="130px"
          prop="availableChargeNum"
        ></el-table-column>
        <el-table-column label="所属运营商" :show-overflow-tooltip="true">
          <template #default="scope">
            <span>{{ scope.row.operator_name }}</span>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        background
        v-model:current-page="paginationProps.current"
        v-model:page-size="paginationProps.pageSize"
        :page-sizes="[10, 20, 50, 100, 200]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="paginationProps.total"
        @change="onPageChange"
      />
    </el-card>

    <Dialog ref="stationDialogRef" :title="title" @onConfirm="saveStation">
      <template #content>
        <el-form :model="dataList.stationForm" label-width="100px">
          <el-form-item label="电站名称">
            <el-input
              v-model="dataList.stationForm.name"
              placeholder="请输入电站名称"
            ></el-input>
          </el-form-item>
          <el-form-item label="电站图片">
            <div style="display: flex; align-items: center">
              <el-image
                id="photo-view"
                :src="filterPhoto(dataList.stationForm.photo)"
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
                id="photo-file"
                style="display: none"
                @change="uploadPhoto"
              />
            </div>
          </el-form-item>
          <el-form-item label="所属运营商">
            <el-select
              filterable
              v-model="dataList.stationForm.operatorId"
              placeholder="请选择所属运营商"
            >
              <el-option
                v-for="item in dataList.operatorList"
                :label="item.name"
                :value="item.id"
                :key="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="电站地址">
            <el-input
              v-model="dataList.stationForm.location"
              :autosize="{ minRows: 2 }"
              type="textarea"
              placeholder="请输入电站地址"
            />
          </el-form-item>
        </el-form>
      </template>
    </Dialog>
    <Dialog
      ref="confirmDialogRef"
      :width="width"
      :title="title"
      @onConfirm="removeStation"
    >
      <template #content>
        <div
          style="display: flex; justify-content: center; font-size: 16px"
          v-text="confirmDesc"
        ></div>
      </template>
    </Dialog>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage } from "element-plus";
import Dialog from "@/components/Dialog/index.vue";
import {
  axiosPostRequest,
  getSessionStorage,
  myEventBus,
} from "@/util/index.js";
const emitter = myEventBus();
emitter.on("refresh", () => {
  getLoginUser();
});
onMounted(() => {
  getLoginUser();
});

const searchFormRef = ref();
const stationDialogRef = ref();
const confirmDialogRef = ref();
const title = ref("");
const confirmDesc = ref("");
const width = ref("50%");

const paginationProps = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

// 重置搜索表单
const resetSearchForm = () => {
  searchFormRef.value.resetFields();
};

const dataList = reactive({
  searchParams: {
    name: "",
    operatorId: 0,
  },
  stationForm: {
    id: "",
    name: "",
    location: "",
    operatorId: "",
    photo: "common/no_image.jpg",
  },
  loginUser: {
    id: "",
    roleId: 1,
  },
  multipleSelection: [],
  stationList: [], // 初始化为空数组
  operatorList: [],
});

// 获取当前登录用户
const getLoginUser = async () => {
  const response = await axiosPostRequest("/user/check_login", {
    token: getSessionStorage(),
  });
  if (response.code === 0) {
    dataList.loginUser = response.data;
    getStationList();
    getAllOperator();
  } else {
    ElMessage.error(response.msg);
    router.push("/login");
  }
};

const filterPhoto = computed(() => (photo) => {
  return import.meta.env.VITE_SERVER + "/photo/view?filename=" + photo;
});

// 打开上传图片窗口
const openUpload = () => {
  document.getElementById("photo-file").click();
};
// 上传图片操作
const uploadPhoto = async () => {
  let fileObj = document.getElementById("photo-file");
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
    document.getElementById("photo-view").src =
      import.meta.env.VITE_SERVER + "/photo/view?filename=" + response.data;
    dataList.stationForm.photo = response.data;
  } else {
    ElMessage.error(response.msg);
  }
};

// 打开添加电站的模态框
const openAddDialog = () => {
  title.value = "添加电站信息";
  dataList.stationForm = {
    id: "",
    name: "",
    location: "",
    operatorId: "",
    photo: "common/no_image.jpg",
  };
  stationDialogRef.value.openDialog();
};

// 打开编辑电站的模态框
const openEditDialog = () => {
  if (dataList.multipleSelection.length !== 1) {
    ElMessage.warning("请选择一条数据进行编辑！");
    return;
  }
  title.value = "编辑电站信息";
  dataList.stationForm = JSON.parse(
    JSON.stringify(dataList.multipleSelection[0])
  );
  stationDialogRef.value.openDialog();
};

// 打开删除电站的确认弹框
const openRemoveDialog = () => {
  if (dataList.multipleSelection.length !== 1) {
    ElMessage.warning("请选择一条数据进行删除！");
    return;
  }
  confirmDesc.value = "确定要删除此数据吗？";
  title.value = "确认提示";
  width.value = "30%";
  dataList.stationForm = JSON.parse(
    JSON.stringify(dataList.multipleSelection[0])
  );
  confirmDialogRef.value.openDialog();
};

// 删除电站信息
const removeStation = async () => {
  const response = await axiosPostRequest(
    "/station/delete",
    dataList.stationForm
  );
  if (response.code === 0) {
    ElMessage.success(response.msg);
    confirmDialogRef.value.closeDialog();
    getStationList();
  } else {
    ElMessage.error(response.msg);
  }
};

// 保存电站信息
const saveStation = async () => {
  const response = await axiosPostRequest(
    "/station/save",
    dataList.stationForm
  );
  if (response.code === 0) {
    ElMessage.success(response.msg);
    stationDialogRef.value.closeDialog();
    getStationList();
  } else {
    ElMessage.error(response.msg);
  }
};

// 分页变化时候
const onPageChange = (current, pageSize) => {
  paginationProps.current = current;
  paginationProps.pageSize = pageSize;
  getStationList();
};

// 记录表格选中行
const handleSelectionChange = (val) => {
  dataList.multipleSelection = val;
};

// 获取全部运营商信息
const getAllOperator = async () => {
  const response = await axiosPostRequest("/operator/all");
  if (response.code === 0) {
    dataList.operatorList = response.data;
  } else {
    ElMessage.error(response.msg);
  }
};

// 获取电站列表
const getStationList = async () => {
  try {
    const response = await axiosPostRequest("/station/list");
    console.log('Station list response:', response); // 添加调试日志
    
    if (response.code === 0) {
      // 处理返回的数据
      dataList.stationList = response.data.map(item => ({
        ...item,
        chargeNum: item.charge_num || 0,
        availableChargeNum: item.available_charge_num || 0,
        operator_name: item.operator_name || '未知运营商'
      }));
      paginationProps.total = response.data.length;
    } else {
      ElMessage.error(response.msg || '获取电站列表失败');
    }
  } catch (error) {
    console.error('Get station list error:', error);
    ElMessage.error('获取电站列表失败');
  }
};
</script>
<style lang="scss" scoped>
.card-list {
  border-radius: 0.375rem;
  .el-table {
    margin-top: 20px;
  }
  .el-pagination {
    margin-top: 20px;
  }
}
</style>
