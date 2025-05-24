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

// 获取通知列表
const getNoticeList = async () => {
	const response = await axiosPostRequest("/notice/list");
	if (response.code === 0) {
		noticeList.value = response.data;
	} else {
		ElMessage.error(response.msg);
	}
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
