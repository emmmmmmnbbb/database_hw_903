<template>
    <div>
        <div class="header">
            当前充电状态
        </div>
        <div class="body">
            <div v-if="!hasActiveCharging" class="no-charging">
                <el-empty description="暂无充电中的订单"></el-empty>
            </div>
            <div v-else class="charging-status">
                <el-card class="status-card">
                    <div slot="header">
                        <span>充电详情</span>
                    </div>
                    <div class="info-item">
                        <span class="label">充电站：</span>
                        <span>{{ chargingData.station_name }}</span>
                    </div>
                    <div class="info-item">
                        <span class="label">充电桩号：</span>
                        <span>{{ chargingData.charging_pile }}</span>
                    </div>
                    <div class="info-item">
                        <span class="label">开始时间：</span>
                        <span>{{ chargingData.start_time }}</span>
                    </div>
                    <div class="info-item">
                        <span class="label">已充时长：</span>
                        <span>{{ chargingData.duration }}分钟</span>
                    </div>
                    <div class="info-item">
                        <span class="label">已充电量：</span>
                        <span>{{ chargingData.current_power }}度</span>
                    </div>
                    <div class="info-item">
                        <span class="label">预计费用：</span>
                        <span>{{ chargingData.estimated_fee }}元</span>
                    </div>
                    <div class="actions">
                        <el-button type="danger" @click="stopCharging">结束充电</el-button>
                    </div>
                </el-card>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            hasActiveCharging: false,
            chargingData: {
                station_name: '',
                charging_pile: '',
                start_time: '',
                duration: 0,
                current_power: 0,
                estimated_fee: 0
            }
        }
    },
    created() {
        this.getChargingStatus()
    },
    methods: {
        getChargingStatus() {
            this.$axios.get("/api/user/charging/status").then((res) => {
                if (res.data.status == 200) {
                    this.hasActiveCharging = true;
                    this.chargingData = res.data.charging;
                } else {
                    this.hasActiveCharging = false;
                }
            })
        },
        stopCharging() {
            this.$confirm('确定要结束充电吗?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.$axios.post("/api/user/charging/stop").then((res) => {
                    if (res.data.status == 200) {
                        this.$message({
                            type: 'success',
                            message: '已结束充电'
                        });
                        this.getChargingStatus();
                    }
                })
            }).catch(() => { })
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

.no-charging {
    margin-top: 100px;
}

.charging-status {
    display: flex;
    justify-content: center;
}

.status-card {
    width: 400px;
}

.info-item {
    margin: 15px 0;
    font-size: 16px;
}

.label {
    display: inline-block;
    width: 100px;
    color: #606266;
}

.actions {
    margin-top: 30px;
    text-align: center;
}
</style>