<template>
	<div style="padding: 20px">
		<el-card shadow="always" :body-style="{ padding: '20px' }">
			<el-table :data="myCouponList" style="width: 100%">
				<el-table-column prop="id" label="ID" />
				<el-table-column prop="title" label="名称" />
				<el-table-column prop="money" label="金额" />
				<el-table-column prop="status" label="状态">
					<template #default="scope">
						<el-tag v-if="scope.row.status == 1" type="success">已使用</el-tag>
						<el-tag v-else type="warning">未使用</el-tag>
					</template>
				</el-table-column>
			</el-table>
		</el-card>
	</div>
</template>

<script setup>
import { axiosPostRequest } from "@/util/index.js";
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";

// 我的优惠券列表
const myCouponList = ref([]);
// 获取我的优惠券列表
const getMyCouponList = async () => {
	const response = await axiosPostRequest("/coupon/Myreceive");
	if (response.code === 0) {
		myCouponList.value = response.data;
		localStorage.setItem("myCouponList", JSON.stringify(response.data.filter((item) => item.status == 0)));
	}
};

onMounted(() => {
	getMyCouponList();
});
</script>

<style lang="scss" scoped></style>
