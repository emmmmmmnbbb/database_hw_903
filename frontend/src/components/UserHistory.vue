<template>
    <div>
        <div class="header">
            我的充电记录
        </div>
        <div class="body">
            <el-table :data="tableData" style="width: 89%" class="table">
                <el-table-column prop="order_id" label="充电订单号" width="180" align="center">
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
            </el-table>

            <div class="pagination">
                <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" :page-size="pageSize"
                    layout="total, prev, pager, next" :total="total">
                </el-pagination>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            tableData: [],
            currentPage: 1,
            pageSize: 10,
            total: 0
        }
    },
    created() {
        this.getHistoryRecords()
    },
    methods: {
        getHistoryRecords() {
            this.$axios.get("/api/user/charging/history", {
                params: {
                    page: this.currentPage,
                    pageSize: this.pageSize
                }
            }).then((res) => {
                if (res.data.status == 200) {
                    this.tableData = res.data.records;
                    this.total = res.data.total;
                }
            })
        },
        handleCurrentChange(val) {
            this.currentPage = val;
            this.getHistoryRecords();
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

.pagination {
    margin-top: 20px;
    text-align: center;
}
</style>