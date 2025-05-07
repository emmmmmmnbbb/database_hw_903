<template>
    <div>
        <div class="header">
            充电历史记录
        </div>
        <div class="body">
            <el-table :data="tableData" style="width: 89%" class="table">
                <el-table-column prop="order_id" label="充电订单号" width="180" align="center">
                </el-table-column>
                <el-table-column prop="user_name" label="用户名" width="120" align="center">
                </el-table-column>
                <el-table-column prop="station_name" label="充电站" width="180" align="center">
                </el-table-column>
                <el-table-column prop="charging_pile" label="充电桩号" width="120" align="center">
                </el-table-column>
                <el-table-column prop="start_time" label="开始时间" width="180" align="center">
                </el-table-column>
                <el-table-column prop="end_time" label="结束时间" width="180" align="center">
                </el-table-column>
                <el-table-column prop="duration" label="充电时长(分钟)" width="120" align="center">
                </el-table-column>
                <el-table-column prop="power" label="充电量(度)" width="120" align="center">
                </el-table-column>
                <el-table-column prop="fee" label="费用(元)" width="120" align="center">
                </el-table-column>
                <el-table-column prop="status" label="状态" width="120" align="center">
                    <template>
                        <el-tag type="success">已完成</el-tag>
                    </template>
                </el-table-column>
            </el-table>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            tableData: []
        }
    },
    created() {
        this.getHistoryRecords()
    },
    methods: {
        getHistoryRecords() {
            this.$axios.get("/api/manager/charging/history").then((res) => {
                if (res.data.status == 200) {
                    this.tableData = res.data.records;
                }
            })
        }
    }
}
</script>

<style scoped>
.header {
    width: 100%;
    height: 10%;
    text-align: center;
    line-height: 64px;
    font-size: 20px;
    font-weight: 800;
    border-bottom: 1px solid #e3e3e3;
}

.body {
    width: 80%;
    margin: auto;
    margin-top: 30px;
}
</style>