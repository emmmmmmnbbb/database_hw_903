<template>
	<div class="notice-list">
		<!-- 新增 -->
		<el-button style="margin-bottom: 20px" type="primary" @click="addNotice">新增</el-button>
		<el-card>
			<el-table :data="noticeList" style="width: 100%">
				<el-table-column prop="title" label="标题" />
				<el-table-column prop="content" label="内容" />
				<el-table-column prop="addTime" label="创建时间" />
				<el-table-column label="操作" width="180">
					<template #default="scope">
						<el-button type="primary" size="small" @click="editNotice(scope.row)">编辑</el-button>
						<el-button type="danger" size="small" @click="deleteNotice(scope.row)">删除</el-button>
					</template>
				</el-table-column>
			</el-table>
		</el-card>

		<!-- 新增/编辑弹框 -->
		<el-dialog v-model="dialogVisible" :title="isEdit ? '编辑通知' : '新增通知'" width="500px">
			<el-form :model="form" label-width="80px" ref="formRef">
				<el-form-item label="标题" prop="title">
					<el-input v-model="form.title" placeholder="请输入标题"></el-input>
				</el-form-item>
				<el-form-item label="内容" prop="content">
					<el-input v-model="form.content" type="textarea" rows="4" placeholder="请输入内容"></el-input>
				</el-form-item>
			</el-form>
			<template #footer>
				<span class="dialog-footer">
					<el-button @click="dialogVisible = false">取消</el-button>
					<el-button type="primary" @click="submitForm">确定</el-button>
				</span>
			</template>
		</el-dialog>
	</div>
</template>

<script setup>
import { axiosPostRequest } from "@/util/index.js";
import { ref, reactive } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";

// /notice/list
const noticeList = ref([]);
const dialogVisible = ref(false);
const isEdit = ref(false);
const form = reactive({
	id: "",
	title: "",
	content: ""
});

const getNoticeList = async () => {
  // 使用虚拟数据替代API调用
  noticeList.value = [
    {
      id: 1,
      title: "关于充电桩系统维护的通知",
      content: "尊敬的用户，我们计划于2025年6月10日凌晨2:00-4:00进行系统维护，期间充电桩预约功能将暂停使用。给您带来不便，敬请谅解。",
      addTime: "2025-06-05 10:30:00"
    },
    {
      id: 2,
      title: "东门新增充电桩设施公告",
      content: "为满足日益增长的充电需求，我校东门已新增1个快速直流充电桩，即日起可通过系统预约使用。",
      addTime: "2025-06-03 14:15:30"
    },
    {
      id: 3,
      title: "充电价格调整通知",
      content: "根据最新电价政策，从2025年7月1日起，普通充电桩价格调整为2.0元/度，快充桩价格调整为2.5元/度。",
      addTime: "2025-06-02 09:45:12"
    }
  ];
};

// 打开新增弹框
const addNotice = () => {
	isEdit.value = false;
	form.id = "";
	form.title = "";
	form.content = "";
	dialogVisible.value = true;
};

// 打开编辑弹框
const editNotice = (row) => {
	isEdit.value = true;
	form.id = row.id;
	form.title = row.title;
	form.content = row.content;
	dialogVisible.value = true;
};

// 删除通知
const deleteNotice = (row) => {
	ElMessageBox.confirm("确认删除该通知吗？", "提示", {
		confirmButtonText: "确定",
		cancelButtonText: "取消",
		type: "warning"
	})
		.then(async () => {
			const response = await axiosPostRequest("/notice/delete?id=" + row.id);
			if (response.code === 0) {
				ElMessage.success("删除成功");
				getNoticeList();
			} else {
				ElMessage.error(response.msg);
			}
		})
		.catch(() => {
			// 取消删除操作
		});
};

// 提交表单
const submitForm = async () => {
	if (!form.title || !form.content) {
		ElMessage.warning("请填写完整信息");
		return;
	}

	const params = {
		title: form.title,
		content: form.content
	};

	if (isEdit.value) {
		params.id = form.id;
	}

	const response = await axiosPostRequest("/notice/add", params);
	if (response.code === 0) {
		ElMessage.success(isEdit.value ? "编辑成功" : "新增成功");
		dialogVisible.value = false;
		getNoticeList();
	} else {
		ElMessage.error(response.msg);
	}
};

getNoticeList();
</script>

<style lang="scss" scoped>
.notice-list {
	margin-top: 20px;
	padding: 20px;
}
</style>
