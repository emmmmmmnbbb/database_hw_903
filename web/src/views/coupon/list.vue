<template>
	<div style="padding: 20px">
		<el-card>
			<el-button v-if="userInfo.roleId == 2" style="margin-bottom: 20px" type="primary" @click="addCoupon">新增</el-button>
			<el-table :data="couponList" style="width: 100%">
				<el-table-column prop="id" label="ID" />
				<el-table-column prop="title" label="名称" />
				<el-table-column prop="money" label="金额" />
				<!-- 操作 -->
				<el-table-column label="操作">
					<template #default="scope">
						<el-button v-if="userInfo.roleId == 2" type="danger" size="small" @click="deleteCoupon(scope.row)">删除</el-button>
						<!-- 领取 -->
						<el-button v-if="userInfo.roleId === 1" type="primary" size="small" @click="receiveCoupon(scope.row)">领取</el-button>
					</template>
				</el-table-column>
			</el-table>
			<!-- 新增/编辑弹框 -->
			<el-dialog v-model="dialogVisible" :title="isEdit ? '编辑优惠券' : '新增优惠券'" width="500px">
				<el-form :model="form" label-width="80px" ref="formRef">
					<el-form-item label="名称" prop="title">
						<el-input v-model="form.title" placeholder="请输入名称"></el-input>
					</el-form-item>
					<el-form-item label="金额" prop="money">
						<el-input v-model="form.money" placeholder="请输入金额"></el-input>
					</el-form-item>
				</el-form>
				<template #footer>
					<span class="dialog-footer">
						<el-button @click="dialogVisible = false">取消</el-button>
						<el-button type="primary" @click="submitForm">确定</el-button>
					</span>
				</template>
			</el-dialog>
		</el-card>
	</div>
</template>

<script setup>
import { axiosPostRequest } from "@/util/index.js";
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
const userInfo = JSON.parse(localStorage.getItem("userInfo"));

// 优惠券列表
const couponList = ref([]);
const dialogVisible = ref(false);
const isEdit = ref(false);
const form = reactive({
	id: "",
	title: "",
	money: ""
});

// 获取优惠券列表
const getCouponList = async () => {
	const response = await axiosPostRequest("/coupon/list");
	if (response.code === 0) {
		couponList.value = response.data;
		console.log(couponList.value);
	}
};

// 新增优惠券
const addCoupon = () => {
	dialogVisible.value = true;
	isEdit.value = false;
};

// 删除优惠券
const deleteCoupon = async (row) => {
	const response = await axiosPostRequest("/coupon/delete?id=" + row.id);
	if (response.code === 0) {
		ElMessage.success("删除成功");
		getCouponList();
	}
};

// 提交表单
const submitForm = async () => {
	if (!form.title || !form.money) {
		ElMessage.warning("请填写完整信息");
		return;
	}

	const response = await axiosPostRequest("/coupon/add", form);
	if (response.code === 0) {
		ElMessage.success("新增成功");
		getCouponList();
		dialogVisible.value = false;
	}
};

// 领取优惠券
const receiveCoupon = async (row) => {
	const response = await axiosPostRequest("/coupon/receive", {
		couponId: row.id,
		title: row.title,
		money: row.money
	});
	if (response.code === 0) {
		ElMessage.success("领取成功");
	} else {
		ElMessage.error(response.msg);
	}
};

onMounted(() => {
	getCouponList();
});
</script>

<style lang="scss" scoped></style>
