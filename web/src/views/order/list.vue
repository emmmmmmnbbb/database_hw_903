<template>
	<div style="padding: 6px 6px 0 6px">
		<el-card class="card-list" shadow="never">
			<el-form ref="searchFormRef" :inline="true" :model="dataList.searchParams">
				<el-form-item label="订单编号" prop="id">
					<el-input v-model="dataList.searchParams.id" placeholder="请输入订单编号" style="width: 200px"></el-input>
				</el-form-item>
				<el-form-item label="用户昵称" prop="username">
					<el-input v-model="dataList.searchParams.username" placeholder="请输入用户昵称" style="width: 200px"></el-input>
				</el-form-item>
				<el-form-item label="订单状态" prop="state">
					<el-select v-model="dataList.searchParams.state" placeholder="请选择订单状态">
						<el-option label="全部" :value="0" />
						<el-option label="未支付" :value="1" />
						<el-option label="已支付" :value="2" />
					</el-select>
				</el-form-item>
				<el-form-item>
					<el-button type="primary" icon="search" plain @click="getOrderList">搜索</el-button>
					<el-button type="danger" icon="refresh" plain @click="resetSearchForm">重置</el-button>
				</el-form-item>
			</el-form>

			<el-row :gutter="10">
				<el-col :span="1.5">
					<el-button type="warning" icon="AlarmClock" plain @click="openPayDialog">支付</el-button>
				</el-col>
			</el-row>

			<el-table border @selection-change="handleSelectionChange" v-adaptive :data="dataList.orderList" empty-text="暂时没查到数据哟🛵">
				<el-table-column type="selection" width="55"> </el-table-column>
				<el-table-column label="序号" prop="id" width="140px"></el-table-column>
				<el-table-column label="充电桩名称" prop="chargeName" width="200px"></el-table-column>
				<el-table-column label="用户昵称" width="200px">
					<template #default="scope">
						<div>
							{{ scope.row.userDTO.username }}
						</div>
					</template>
				</el-table-column>
				<el-table-column label="订单总价格" prop="totalPrice" width="150px"></el-table-column>
				<el-table-column label="订单状态" width="100px">
					<template #default="scope">
						<div>
							<span style="color: red" v-if="scope.row.state === 1">未支付</span>
							<span style="color: green" v-if="scope.row.state === 2">已支付</span>
						</div>
					</template>
				</el-table-column>
				<el-table-column label="订单创建时间" prop="createTime" :show-overflow-tooltip="true"></el-table-column>
			</el-table>

			<el-pagination
				background
				v-model:current-page="paginationProps.current"
				v-model:page-size="paginationProps.pageSize"
				:page-sizes="[10, 20, 50, 100, 200]"
				layout="total, sizes, prev, pager, next, jumper"
				:total="paginationProps.total"
				@change="onPageChange" />
		</el-card>

		<Dialog ref="confirmDialogRef" :width="width" :title="title" @onConfirm="onConfirm">
			<template #content>
				<div style="display: flex; flex-direction: column; align-items: center; font-size: 16px">
					<div v-text="confirmDesc"></div>
					<div v-if="dataList.orderForm.method === 'pay'" style="margin-top: 15px; width: 100%">
						<el-form :model="paymentInfo" label-width="80px">
							<el-form-item label="支付方式">
								<el-radio-group v-model="paymentInfo.payMethod">
									<el-radio :label="'normal'">普通支付</el-radio>
									<el-radio :label="'coupon'" :disabled="!myCouponList.length">使用优惠券</el-radio>
									<el-radio :label="'points'" :disabled="rate <= 0">使用积分</el-radio>
								</el-radio-group>
							</el-form-item>
							<el-form-item v-if="paymentInfo.payMethod === 'coupon'" label="选择优惠券">
								<el-select v-model="paymentInfo.selectedCoupon" placeholder="请选择优惠券" style="width: 100%">
									<el-option label="不使用优惠券" :value="null" />
									<el-option v-for="coupon in myCouponList" :key="coupon.id" :label="coupon.title" :value="coupon" />
								</el-select>
							</el-form-item>
							<el-form-item v-if="paymentInfo.selectedCoupon">
								<div style="color: #f56c6c">优惠金额: {{ paymentInfo.selectedCoupon.money }}元</div>
							</el-form-item>
							<el-form-item v-if="paymentInfo.payMethod === 'points'" label="使用积分">
								<div>
									<div>当前积分: {{ rate }}</div>
									<div>兑换比例: 10积分 = 1元</div>
									<el-slider
										v-model="xhjf"
										:max="Math.min(rate, dataList.orderForm.totalPrice * 10)"
										:step="10"
										:marks="{ 0: '0', [Math.min(rate, dataList.orderForm.totalPrice * 10)]: Math.min(rate, dataList.orderForm.totalPrice * 10) }"
										show-input>
									</el-slider>
									<div style="color: #f56c6c">抵扣金额: {{ xhjf / 10 }}元</div>
								</div>
							</el-form-item>
							<el-form-item>
								<div style="font-weight: bold">最终支付金额: {{ calculateFinalPrice() }}元</div>
							</el-form-item>
						</el-form>
					</div>
				</div>
			</template>
		</Dialog>

		<Dialog ref="orderDialogRef" :title="title" @onConfirm="saveOrder">
			<template #content>
				<el-form :model="dataList.orderForm" label-width="130px">
					<el-form-item label="订单编号">
						<div v-text="dataList.orderForm.id"></div>
					</el-form-item>
					<el-form-item label="订单状态">
						<el-select v-model="dataList.orderForm.state" placeholder="请选择订单状态">
							<el-option label="未支付" :value="1" />
							<el-option label="已支付" :value="2" />
						</el-select>
					</el-form-item>
				</el-form>
			</template>
		</Dialog>
	</div>
</template>
<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage } from "element-plus";
import Dialog from "@/components/Dialog/index.vue";
import { axiosPostRequest, getSessionStorage, myEventBus } from "@/util/index.js";
const emitter = myEventBus();

emitter.on("refresh", () => {
	getLoginUser();
});
onMounted(() => {
	getLoginUser();
});
// 我的优惠券列表
const myCouponList = ref([]);
// 获取我的优惠券列表
const getMyCouponList = async () => {
	const response = await axiosPostRequest("/coupon/Myreceive");
	if (response.code == 0) {
		myCouponList.value = response.data.filter((item) => item.status == 0);
		console.log(myCouponList.value);
	}
};
getMyCouponList();

const userInfo = ref({});
userInfo.value = JSON.parse(localStorage.getItem("userInfo"));
// 积分
const rate = ref(0);
rate.value = userInfo.value.rate;
const searchFormRef = ref();
const confirmDialogRef = ref();
const orderDialogRef = ref();
const title = ref("");
const confirmDesc = ref("");
const width = ref("50%");

const paginationProps = reactive({
	current: 1,
	pageSize: 10,
	total: 0
});

// 获取当前登录用户
const getLoginUser = async () => {
	const response = await axiosPostRequest("/user/check_login", {
		token: getSessionStorage()
	});
	if (response.code === 0) {
		dataList.loginUser = response.data;
		getOrderList();
	} else {
		ElMessage.error(response.msg);
		router.push("/login");
	}
};

// 重置搜索表单
const resetSearchForm = () => {
	searchFormRef.value.resetFields();
};

const dataList = reactive({
	searchParams: {
		username: "",
		id: "",
		state: 0
	},
	loginUser: {
		id: "",
		roleId: 1
	},
	multipleSelection: [],
	orderList: [],
	orderForm: {
		id: "",
		state: 1,
		method: ""
	}
});

// 打开编辑订单的模态框
const openEditDialog = () => {
	if (dataList.multipleSelection.length !== 1) {
		ElMessage.warning("请选择一条数据进行编辑！");
		return;
	}
	let selectedRow = dataList.multipleSelection[0];
	title.value = "编辑订单信息";
	dataList.orderForm = JSON.parse(JSON.stringify(selectedRow));
	orderDialogRef.value.openDialog();
};

// 修改订单信息
const saveOrder = async () => {
	const response = await axiosPostRequest("/order/edit_state", {
		id: dataList.orderForm.id,
		state: dataList.orderForm.state
	});
	if (response.code === 0) {
		ElMessage.success("保存成功！");
		orderDialogRef.value.closeDialog();
		getOrderList();
	} else {
		ElMessage.error(response.msg);
	}
};

// 支付相关信息
const paymentInfo = reactive({
	selectedCoupon: null,
	payMethod: "normal" // 默认普通支付
});

// 计算最终价格
const calculateFinalPrice = () => {
	const originalPrice = dataList.orderForm.totalPrice || 0;

	if (paymentInfo.payMethod === "coupon" && paymentInfo.selectedCoupon) {
		const discountAmount = paymentInfo.selectedCoupon.money || 0;
		return Math.max(originalPrice - discountAmount, 0);
	} else if (paymentInfo.payMethod === "points" && xhjf.value > 0) {
		// 积分抵扣
		const discountAmount = xhjf.value / 10; // 10积分 = 1元
		return Math.max(originalPrice - discountAmount, 0);
	}
	return originalPrice;
};
const xhjf = ref(0);

// 确认操作
const onConfirm = async () => {
	if (dataList.orderForm.method === "pay") {
		let obj={
			id: dataList.orderForm.id,
			state: 2,
			userCouponId: paymentInfo.payMethod === "coupon" && paymentInfo.selectedCoupon ? paymentInfo.selectedCoupon.id : null,
			finalPrice: calculateFinalPrice(),
			totalPrice:calculateFinalPrice(),
			jifen: paymentInfo.payMethod === "points" ? xhjf.value : 0
		};
		console.log(obj);
		// 支付订单
		const response = await axiosPostRequest("/order/edit_state", obj);
		if (response.code === 0) {
			ElMessage.success("支付成功！");
			getOrderList();
			confirmDialogRef.value.closeDialog();
			// 如果使用了优惠券，将其状态更新
			if (paymentInfo.payMethod === "coupon" && paymentInfo.selectedCoupon) {
				await updateCouponStatus(paymentInfo.selectedCoupon.id);
				getMyCouponList(); // 刷新优惠券列表
			}
		} else {
			ElMessage.error(response.msg);
		}
	} else if (dataList.orderForm.method === "delete") {
		// 结束充电
		const response = await axiosPostRequest("/order/delete", {
			id: dataList.orderForm.id
		});
		if (response.code === 0) {
			ElMessage.success(response.msg);
			getOrderList();
			confirmDialogRef.value.closeDialog();
		} else {
			ElMessage.error(response.msg);
		}
	}
};

// 更新优惠券状态
const updateCouponStatus = async (couponId) => {
	try {
		await axiosPostRequest("/coupon/update_status", {
			id: couponId,
			status: 1 // 已使用状态
		});
	} catch (error) {
		console.error("更新优惠券状态失败", error);
	}
};

// 打开删除订单确认框
const openRemoveDialog = () => {
	if (dataList.multipleSelection.length !== 1) {
		ElMessage.warning("请选择一条数据进行删除！");
		return;
	}
	let selectedRow = dataList.multipleSelection[0];
	confirmDesc.value = "确定要删除此数据吗？";
	title.value = "确认提示";
	width.value = "30%";
	dataList.orderForm = JSON.parse(JSON.stringify({ ...selectedRow, method: "delete" }));
	confirmDialogRef.value.openDialog();
};

// 支付订单
const openPayDialog = () => {
	if (dataList.multipleSelection.length !== 1) {
		ElMessage.warning("请选择一条数据进行支付！");
		return;
	}
	let selectedRow = dataList.multipleSelection[0];
	if (selectedRow.state !== 1) {
		ElMessage.warning("请选择一条未支付的数据进行支付！");
		return;
	}
	confirmDesc.value = "订单金额：" + selectedRow.totalPrice + "元";
	title.value = "订单支付";
	width.value = "40%";
	dataList.orderForm = JSON.parse(JSON.stringify({ ...selectedRow, method: "pay" }));
	// 重置支付信息
	paymentInfo.selectedCoupon = null;
	paymentInfo.payMethod = "normal";
	xhjf.value = 0;
	confirmDialogRef.value.openDialog();
};

// 分页变化时候
const onPageChange = (current, pageSize) => {
	paginationProps.current = current;
	paginationProps.pageSize = pageSize;
	getOrderList();
};

// 记录表格选中行
const handleSelectionChange = (val) => {
	dataList.multipleSelection = val;
};

// 获取订单信息
const getOrderList = async () => {
	const response = await axiosPostRequest("/order/list", {
		page: paginationProps.current,
		size: paginationProps.pageSize,
		param: {
			username: dataList.searchParams.username,
			id: dataList.searchParams.id,
			userId: dataList.loginUser.roleId === 1 ? dataList.loginUser.id : "",
			state: dataList.searchParams.state
		}
	});
	if (response.code === 0) {
		dataList.orderList = response.data.list;
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
