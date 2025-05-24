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
                <el-form-item label="充电桩名称" prop="chargeId">
                    <el-select
                            filterable
                            v-model="dataList.searchParams.chargeId"
                            placeholder="请选择充电桩名称"
                    >
                        <el-option label="全部" :value="0" />
                        <el-option
                                v-for="item in dataList.chargeList"
                                :label="item.name"
                                :value="item.id"
                                :key="item.id"
                        />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" icon="search" plain @click="getAppointList"
                    >搜索</el-button
                    >
                    <el-button type="danger" icon="refresh" plain @click="resetSearchForm"
                    >重置</el-button
                    >
                </el-form-item>
            </el-form>

            <el-row :gutter="10">
<!--                <el-col :span="1.5">-->
<!--                    <el-button type="primary" icon="Select" plain @click="openStartDialog"-->
<!--                    >开始充电</el-button-->
<!--                    >-->
<!--                </el-col>-->
                <el-col :span="1.5">
                    <el-button
                            type="success"
                            icon="CloseBold"
                            plain
                            @click="openEndDialog"
                    >结束充电</el-button
                    >
                </el-col>
<!--                <el-col :span="1.5">-->
<!--                    <el-button type="info" icon="delete" plain @click="openCancelDialog"-->
<!--                    >取消</el-button-->
<!--                    >-->
<!--                </el-col>-->
<!--                <el-col :span="1.5">-->
<!--                    <el-button type="warning" icon="edit" plain @click="openAppointDialog"-->
<!--                    >修改</el-button-->
<!--                    >-->
<!--                </el-col>-->
<!--                <el-col :span="1.5" v-if="dataList.loginUser.roleId === 2">-->
<!--                    <el-button type="danger" icon="delete" plain @click="openRemoveDialog"-->
<!--                    >删除</el-button-->
<!--                    >-->
<!--                </el-col>-->
            </el-row>

            <el-table
                    border
                    @selection-change="handleSelectionChange"
                    v-adaptive
                    :data="dataList.appointList"
                    empty-text="暂时没查到数据哟🛵"
            >
                <el-table-column type="selection" width="55"> </el-table-column>
                <el-table-column label="序号" prop="id" width="140px"></el-table-column>
                <el-table-column
                        label="充电桩名称"
                        prop="chargeName"
                        width="200px"
                ></el-table-column>
                <el-table-column
                        label="收费价格(元/分钟)"
                        prop="chargePrice"
                        width="150px"
                ></el-table-column>
                <el-table-column label="用户昵称" width="150px">
                    <template #default="scope">
                        <div>
                            {{ scope.row.userDTO.username }}
                        </div>
                    </template>
                </el-table-column>
                <el-table-column label="预约状态" width="100px">
                    <template #default="scope">
                        <div>
                            <span v-if="scope.row.state === 1">待使用</span>
                            <span v-if="scope.row.state === 2">充电中</span>
                            <span v-if="scope.row.state === 3">已完成</span>
                            <span v-if="scope.row.state === 4">已取消</span>
                        </div>
                    </template>
                </el-table-column>
                <el-table-column label="预约日期和时间段" prop="day" width="200px">
                    <template #default="scope">
                        <div v-text="scope.row.day + ' ' + scope.row.time"></div>
                    </template>
                </el-table-column>
                <el-table-column
                        label="开始充电时间"
                        prop="startTime"
                        width="180px"
                ></el-table-column>
                <el-table-column
                        label="结束充电时间"
                        prop="endTime"
                        width="180px"
                ></el-table-column>
                <el-table-column
                        label="预约创建时间"
                        prop="createTime"
                        width="200px"
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

        <Dialog
                ref="confirmDialogRef"
                :width="width"
                :title="title"
                @onConfirm="onConfirm"
        >
            <template #content>
                <div
                        style="display: flex; justify-content: center; font-size: 16px"
                        v-text="confirmDesc"
                ></div>
            </template>
        </Dialog>

        <Dialog ref="appointDialogRef" :title="title" @onConfirm="saveAppoint">
            <template #content>
                <el-form
                        v-loading="loading"
                        :model="dataList.appointForm"
                        label-width="130px"
                >
                    <el-form-item label="充电桩编号">
                        <div v-text="dataList.appointForm.id"></div>
                    </el-form-item>
                    <el-form-item label="充电桩名称">
                        <div v-text="dataList.appointForm.chargeName"></div>
                    </el-form-item>
                    <el-form-item label="预约日期">
                        <el-date-picker
                                v-model="dataList.appointForm.day"
                                type="date"
                                @change="(e) => changeDate()"
                                :disabled-date="disabledDate"
                                placeholder="请选择日期"
                        />
                    </el-form-item>
                    <el-form-item label="预约时间段">
                        <el-select
                                v-model="dataList.appointForm.scheduleId"
                                placeholder="请选择时间段"
                                style="width: 220px"
                        >
                            <el-option
                                    v-for="item in dataList.scheduleOptions"
                                    :key="item.value"
                                    :label="item.label"
                                    :value="item.value"
                                    :disabled="item.disabled"
                            />
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
    import {
        axiosPostRequest,
        getSessionStorage,
        myEventBus,
    } from "@/util/index.js";
    import { format, parse, differenceInMinutes, addDays } from "date-fns";
    const emitter = myEventBus();
    emitter.on("refresh", () => {
        getLoginUser();
    });
    onMounted(() => {
        getLoginUser();
    });

    const searchFormRef = ref();
    const confirmDialogRef = ref();
    const appointDialogRef = ref();
    const title = ref("");
    const confirmDesc = ref("");
    const width = ref("50%");
    const loading = ref(false);

    const paginationProps = reactive({
        current: 1,
        pageSize: 10,
        total: 0,
    });

    // 重置搜索表单
    const resetSearchForm = () => {
        searchFormRef.value.resetFields();
    };

    // 获取当前登录用户
    const getLoginUser = async () => {
        const response = await axiosPostRequest("/user/check_login", {
            token: getSessionStorage(),
        });
        if (response.code === 0) {
            dataList.loginUser = response.data;
            getAppointList();
            getAllCharge();
        } else {
            ElMessage.error(response.msg);
            router.push("/login");
        }
    };

    // 预约日期变化
    const changeDate = () => {
        let timeRange = dataList.appointForm.time.split("-");
        let scheduleId =
            timeRange[0].substring(0, 2) + "-" + timeRange[1].substring(0, 2);
        getAppointDate(scheduleId);
    };

    const dataList = reactive({
        searchParams: {
            username: "",
            chargeId: 0,
        },
        scheduleOptions: [
            {
                label: "00:00-02:00",
                value: "00-02",
                disabled: false,
            },
            {
                label: "02:00-04:00",
                value: "02-04",
                disabled: false,
            },
            {
                label: "04:00-06:00",
                value: "04-06",
                disabled: false,
            },
            {
                label: "06:00-08:00",
                value: "06-08",
                disabled: false,
            },
            {
                label: "08:00-10:00",
                value: "08-10",
                disabled: false,
            },
            {
                label: "10:00-12:00",
                value: "10-12",
                disabled: false,
            },
            {
                label: "12:00-14:00",
                value: "12-14",
                disabled: false,
            },
            {
                label: "14:00-16:00",
                value: "14-16",
                disabled: false,
            },
            {
                label: "16:00-18:00",
                value: "16-18",
                disabled: false,
            },
            {
                label: "18:00-20:00",
                value: "18-20",
                disabled: false,
            },
            {
                label: "20:00-22:00",
                value: "20-22",
                disabled: false,
            },
            {
                label: "22:00-24:00",
                value: "22-24",
                disabled: false,
            },
        ],
        multipleSelection: [],
        chargeList: [],
        loginUser: {
            id: "",
            roleId: 1,
        },
        appointList: [],
        appointForm: {
            time: [],
            id: "",
            chargeId: "",
            chargeName: "",
            day: "",
            state: 1,
            disabledDate: [],
            method: "",
            scheduleId: "",
        },
    });

    // 打开预约充电桩修改的模态框
    const openAppointDialog = () => {
        if (dataList.multipleSelection.length !== 1) {
            ElMessage.warning("请选择一条数据进行修改！");
            return;
        }
        let selectedRow = dataList.multipleSelection[0];
        if (selectedRow.state !== 1) {
            ElMessage.warning("请选择一条待使用的数据进行修改！");
            return;
        }
        let day = parse(selectedRow.day, "yyyy-MM-dd", new Date());
        title.value = "预约充电桩修改";
        let timeRange = selectedRow.time.split("-");
        let scheduleId =
            timeRange[0].substring(0, 2) + "-" + timeRange[1].substring(0, 2);
        getAppointDate(scheduleId);
        dataList.appointForm = JSON.parse(
            JSON.stringify({
                ...selectedRow,
                day,
                scheduleId: scheduleId,
            })
        );
        appointDialogRef.value.openDialog();
    };

    // 打开删除预约的模态框
    const openRemoveDialog = () => {
        if (dataList.multipleSelection.length !== 1) {
            ElMessage.warning("请选择一条数据进行删除！");
            return;
        }
        let selectedRow = dataList.multipleSelection[0];
        confirmDesc.value = "确定要删除此数据吗？";
        title.value = "确认提示";
        width.value = "30%";
        dataList.appointForm = JSON.parse(
            JSON.stringify({ ...selectedRow, method: "delete" })
        );
        confirmDialogRef.value.openDialog();
    };

    // 打开开始充电的模态框
    const openStartDialog = () => {
        if (dataList.multipleSelection.length !== 1) {
            ElMessage.warning("请选择一条数据进行开始充电！");
            return;
        }
        let selectedRow = dataList.multipleSelection[0];
        if (selectedRow.state !== 1) {
            ElMessage.warning("请选择一条待使用的数据进行开始充电！");
            return;
        }
        let time = selectedRow.time.split("-");
        let appointStart = parse(
            selectedRow.day + " " + time[0],
            "yyyy-MM-dd HH:mm",
            new Date()
        );
        let appointEnd;
        if(time[1] !== '24:00') {
            appointEnd = parse(
                selectedRow.day + " " + time[1],
                "yyyy-MM-dd HH:mm",
                new Date()
            );
        } else {
            appointEnd = parse(
                selectedRow.day,
                "yyyy-MM-dd",
                new Date()
            );
            appointEnd = addDays(appointEnd, 1);
        }
        if (
            !(
                new Date().getTime() > appointStart.getTime() &&
                appointEnd.getTime() > new Date().getTime()
            )
        ) {
            ElMessage.warning("开始充电失败，还没到预约时间哦！");
            return;
        }
        confirmDesc.value = "确定要开始充电吗？";
        title.value = "确认提示";
        width.value = "30%";
        dataList.appointForm = JSON.parse(
            JSON.stringify({ ...selectedRow, state: 2 })
        );
        confirmDialogRef.value.openDialog();
    };

    // 确认操作
    const onConfirm = async () => {
        if (dataList.appointForm.method === "delete") {
            // 删除预约信息
            const response = await axiosPostRequest("/appoint/delete", {
                id: dataList.appointForm.id,
            });
            if (response.code === 0) {
                ElMessage.success(response.msg);
                getAppointList();
                confirmDialogRef.value.closeDialog();
            } else {
                ElMessage.error(response.msg);
            }
        } else if (dataList.appointForm.state === 2) {
            // 开始充电
            const response = await axiosPostRequest("/appoint/edit_state", {
                id: dataList.appointForm.id,
                state: 2,
            });
            if (response.code === 0) {
                ElMessage.success("开始充电成功！");
                getAppointList();
                confirmDialogRef.value.closeDialog();
            } else {
                ElMessage.error(response.msg);
            }
        } else if (dataList.appointForm.state === 3) {
            let timeRange = dataList.appointForm.time.split("-");
            let endTime;
            if(timeRange[1] !== '24:00') {
                endTime = parse(
                    dataList.appointForm.day + " " + timeRange[1] + ":00",
                    "yyyy-MM-dd HH:mm:ss",
                    new Date()
                );
            } else {
                endTime = parse(
                    dataList.appointForm.day,
                    "yyyy-MM-dd",
                    new Date()
                );
                endTime = addDays(endTime, 1);
            }
            let appointEnd = endTime;
            if (new Date().getTime() < appointEnd.getTime()) {
                appointEnd = new Date();
            }
            let appointStart = parse(
                dataList.appointForm.startTime,
                "yyyy-MM-dd HH:mm:ss",
                new Date()
            );
            let mins = differenceInMinutes(appointEnd, appointStart);
            // 结束充电
            const response = await axiosPostRequest("/appoint/edit_state", {
                id: dataList.appointForm.id,
                chargeId: dataList.appointForm.chargeId,
                chargeName: dataList.appointForm.chargeName,
                time: mins,
                endTime: format(appointEnd, "yyyy-MM-dd HH:mm:ss"),
                state: 3,
            });
            if (response.code === 0) {
                ElMessage.success(
                    "结束充电成功！共花费：" +
                    response.data +
                    "元，请到订单列表中进行支付！"
                );
                getAppointList();
                confirmDialogRef.value.closeDialog();
            } else {
                ElMessage.error(response.msg);
            }
        } else if (dataList.appointForm.state === 4) {
            // 取消预约
            const response = await axiosPostRequest("/appoint/edit_state", {
                id: dataList.appointForm.id,
                state: 4,
            });
            if (response.code === 0) {
                ElMessage.success("取消预约成功！");
                getAppointList();
                confirmDialogRef.value.closeDialog();
            } else {
                ElMessage.error(response.msg);
            }
        }
    };

    // 打开取消预约的模态框
    const openCancelDialog = () => {
        if (dataList.multipleSelection.length !== 1) {
            ElMessage.warning("请选择一条数据进行取消预约！");
            return;
        }
        let selectedRow = dataList.multipleSelection[0];
        if (selectedRow.state !== 1) {
            ElMessage.warning("请选择一条待使用的数据进行取消预约！");
            return;
        }
        confirmDesc.value = "确定要取消预约吗？";
        title.value = "确认提示";
        width.value = "30%";
        dataList.appointForm = JSON.parse(
            JSON.stringify({ ...selectedRow, state: 4 })
        );
        confirmDialogRef.value.openDialog();
    };

    // 打开结束充电的模态框
    const openEndDialog = () => {
        if (dataList.multipleSelection.length !== 1) {
            ElMessage.warning("请选择一条数据进行结束充电！");
            return;
        }
        let selectedRow = dataList.multipleSelection[0];
        if (selectedRow.state !== 2) {
            ElMessage.warning("请选择一条充电中的数据进行结束充电！");
            return;
        }
        let timeRange = selectedRow.time.split("-");
        let endTime;
        if(timeRange[1] !== '24:00') {
            endTime = parse(
                selectedRow.day + " " + timeRange[1] + ":00",
                "yyyy-MM-dd HH:mm:ss",
                new Date()
            );
        } else {
            endTime = parse(
                selectedRow.day,
                "yyyy-MM-dd",
                new Date()
            );
            endTime = addDays(endTime, 1);
        }
        let appointEnd = endTime;
        if (new Date().getTime() < appointEnd.getTime()) {
            appointEnd = new Date();
        }
        let appointStart = parse(
            selectedRow.startTime,
            "yyyy-MM-dd HH:mm:ss",
            new Date()
        );
        let mins = differenceInMinutes(appointEnd, appointStart);
        confirmDesc.value = "您已充电：" + mins + "分钟，确定要结束充电吗？";
        title.value = "确认提示";
        width.value = "30%";
        dataList.appointForm = JSON.parse(
            JSON.stringify({ ...selectedRow, state: 3 })
        );
        confirmDialogRef.value.openDialog();
    };

    // 禁用日期
    const disabledDate = (date) => {
        if (date.getTime() < Date.now() - 8.64e7) {
            return true;
        }
        return false;
    };

    // 获取已预约的日期
    const getAppointDate = async (selectedTime = "") => {
        loading.value = true;
        dataList.appointForm.scheduleId = "";
        let newScheduleOptions = dataList.scheduleOptions.map((item) => {
            item.disabled = false;
            return item;
        });
        const response = await axiosPostRequest("/appoint/appointed", {
            chargeId: dataList.appointForm.chargeId,
        });
        if (response.code === 0) {
            let timeList = response.data
                .filter(
                    (item) => item.day === format(dataList.appointForm.day, "yyyy-MM-dd")
                )
                .map((item) => item.time);
            newScheduleOptions = newScheduleOptions.map((item) => {
                timeList.forEach((e) => {
                    if (e === item.label) {
                        item.disabled = true;
                    }
                });
                let timeRange = item.value.split("-");
                if (
                    Number(timeRange[0]) <= Number(format(new Date(), "HH")) &&
                    format(dataList.appointForm.day, "yyyy-MM-dd") ===
                    format(new Date(), "yyyy-MM-dd")
                ) {
                    item.disabled = true;
                }
                if (item.value === selectedTime) {
                    item.disabled = false;
                }
                return item;
            });
            dataList.scheduleOptions = newScheduleOptions;
        } else {
            ElMessage.error(response.msg);
        }
        loading.value = false;
    };

    // 保存预约信息
    const saveAppoint = async () => {
        let data = JSON.parse(JSON.stringify(dataList.appointForm));
        data.day = format(data.day, "yyyy-MM-dd");
        let timeRange = data.scheduleId.split("-");
        data.time = timeRange[0] + ":00" + "-" + timeRange[1] + ":00";
        const response = await axiosPostRequest("/appoint/save", {
            day: data.day,
            time: data.time,
            userId: data.userId,
            chargeId: data.chargeId,
            id: data.id,
        });
        if (response.code === 0) {
            ElMessage.success(response.msg);
            getAppointList();
            appointDialogRef.value.closeDialog();
        } else {
            ElMessage.error(response.msg);
        }
    };

    // 分页变化时候
    const onPageChange = (current, pageSize) => {
        paginationProps.current = current;
        paginationProps.pageSize = pageSize;
        getAppointList();
    };

    // 记录表格选中行
    const handleSelectionChange = (val) => {
        dataList.multipleSelection = val;
    };

    // 获取全部充电桩信息
    const getAllCharge = async () => {
        const response = await axiosPostRequest("/charge/all");
        if (response.code === 0) {
            dataList.chargeList = response.data;
        } else {
            ElMessage.error(response.msg);
        }
    };

    // 获取预约信息
    const getAppointList = async () => {
        const response = await axiosPostRequest("/appoint/list", {
            page: paginationProps.current,
            size: paginationProps.pageSize,
            param: {
                userId: dataList.loginUser.roleId === 1 ? dataList.loginUser.id : "",
                username: dataList.searchParams.username,
                chargeId: dataList.searchParams.chargeId,
                type: 2
            },
        });
        if (response.code === 0) {
            dataList.appointList = response.data.list;
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
