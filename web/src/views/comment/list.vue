<template>
  <div style="padding: 6px 6px 0 6px">
    <el-card class="card-list" shadow="never">
      <el-form
        ref="searchFormRef"
        :inline="true"
        :model="dataList.searchParams"
      >
        <el-form-item label="用户昵称" prop="username">
          <el-input
            v-model="dataList.searchParams.username"
            placeholder="请输入用户昵称"
            style="width: 200px"
          ></el-input>
        </el-form-item>
        <el-form-item label="留言内容" prop="content">
          <el-input
            v-model="dataList.searchParams.content"
            placeholder="请输入留言内容"
            style="width: 200px"
          ></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="search" plain @click="getCommentList"
            >搜索</el-button
          >
          <el-button type="danger" icon="refresh" plain @click="resetSearchForm"
            >重置</el-button
          >
        </el-form-item>
      </el-form>

      <el-row :gutter="10">
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
        :data="dataList.commentList"
        empty-text="暂时没查到数据哟🛵"
      >
        <el-table-column type="selection" width="55"> </el-table-column>
        <el-table-column label="序号" prop="id" width="140px"></el-table-column>
        <el-table-column label="留言用户" width="150px">
          <template #default="scope">
            <div>
              {{ scope.row.userDTO.username }}
            </div>
          </template>
        </el-table-column>
        <el-table-column
          label="留言内容"
          prop="content"
          width="300px"
        ></el-table-column>
        <el-table-column
          label="留言时间"
          prop="createTime"
          width="170px"
        ></el-table-column>
        <el-table-column
          label="管理员回复内容"
          prop="replyContent"
          :show-overflow-tooltip="true"
        ></el-table-column>
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

    <Dialog ref="commentDialogRef" :title="title" @onConfirm="saveComment">
      <template #content>
        <el-form :model="dataList.commentForm" label-width="130px">
          <el-form-item label="留言内容">
            <el-input
              v-model="dataList.commentForm.content"
              :autosize="{ minRows: 3 }"
              type="textarea"
              placeholder="请输入留言内容"
            />
          </el-form-item>
          <el-form-item
            label="管理员回复内容"
            v-if="dataList.loginUser.roleId === 2"
          >
            <el-input
              v-model="dataList.commentForm.replyContent"
              :autosize="{ minRows: 3 }"
              type="textarea"
              placeholder="请输入管理员回复内容"
            />
          </el-form-item>
        </el-form>
      </template>
    </Dialog>
    <Dialog
      ref="confirmDialogRef"
      :width="width"
      :title="title"
      @onConfirm="removeComment"
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
const commentDialogRef = ref();
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
    username: "",
    content: "",
  },
  loginUser: {
    id: "",
    roleId: 1,
  },
  commentForm: {
    id: "",
    content: "",
    replyContent: "",
  },
  multipleSelection: [],
  commentList: [],
});

// 获取当前登录用户
const getLoginUser = async () => {
  const response = await axiosPostRequest("/user/check_login", {
    token: getSessionStorage(),
  });
  if (response.code === 0) {
    dataList.loginUser = response.data;
    getCommentList();
  } else {
    ElMessage.error(response.msg);
    router.push("/login");
  }
};

// 打开添加留言的模态框
const openAddDialog = () => {
  title.value = "添加留言信息";
  dataList.commentForm = {
    id: "",
    content: "",
    replyContent: "",
  };
  commentDialogRef.value.openDialog();
};

// 打开编辑留言的模态框
const openEditDialog = () => {
  if (dataList.multipleSelection.length !== 1) {
    ElMessage.warning("请选择一条数据进行编辑！");
    return;
  }
  let selectedRow = dataList.multipleSelection[0];
  if (
    dataList.loginUser.roleId === 1 &&
    selectedRow.userId !== dataList.loginUser.id
  ) {
    ElMessage.warning("您不能修改其他人的留言哦！");
    return;
  }
  title.value = "编辑留言信息";
  dataList.commentForm = JSON.parse(JSON.stringify(selectedRow));
  commentDialogRef.value.openDialog();
};

// 打开删除留言的确认弹框
const openRemoveDialog = () => {
  if (dataList.multipleSelection.length !== 1) {
    ElMessage.warning("请选择一条数据进行删除！");
    return;
  }
  let selectedRow = dataList.multipleSelection[0];
  if (
    dataList.loginUser.roleId === 1 &&
    selectedRow.userId !== dataList.loginUser.id
  ) {
    ElMessage.warning("您不能删除其他人的留言哦！");
    return;
  }
  confirmDesc.value = "确定要删除此数据吗？";
  title.value = "确认提示";
  width.value = "30%";
  dataList.commentForm = JSON.parse(JSON.stringify(selectedRow));
  confirmDialogRef.value.openDialog();
};

// 删除留言信息
const removeComment = async () => {
  const response = await axiosPostRequest(
    "/comment/delete",
    dataList.commentForm
  );
  if (response.code === 0) {
    ElMessage.success(response.msg);
    confirmDialogRef.value.closeDialog();
    getCommentList();
  } else {
    ElMessage.error(response.msg);
  }
};

// 保存留言信息
const saveComment = async () => {
  const response = await axiosPostRequest("/comment/save", {
    ...dataList.commentForm,
    userId: dataList.loginUser.id,
  });
  if (response.code === 0) {
    ElMessage.success(response.msg);
    commentDialogRef.value.closeDialog();
    getCommentList();
  } else {
    ElMessage.error(response.msg);
  }
};

// 分页变化时候
const onPageChange = (current, pageSize) => {
  paginationProps.current = current;
  paginationProps.pageSize = pageSize;
  getCommentList();
};

// 记录表格选中行
const handleSelectionChange = (val) => {
  dataList.multipleSelection = val;
};

// 获取留言信息
const getCommentList = async () => {
  const response = await axiosPostRequest("/comment/list", {
    page: paginationProps.current,
    size: paginationProps.pageSize,
    param: {
      username: dataList.searchParams.username,
      content: dataList.searchParams.content,
    },
  });
  if (response.code === 0) {
    dataList.commentList = response.data.list;
    paginationProps.total = response.data.total;
  } else {
    ElMessage.error(response.msg);
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
