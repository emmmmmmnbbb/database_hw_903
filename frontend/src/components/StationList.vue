<template>
    <div>
        <div class="header">
            充电站列表
        </div>
        <div class="body">
            <el-row :gutter="20">
                <el-col :span="8" v-for="station in stations" :key="station.id">
                    <el-card class="station-card">
                        <div class="station-info">
                            <h3>{{ station.station_name }}</h3>
                            <div class="info-item">
                                <i class="el-icon-location"></i>
                                <span>{{ station.address }}</span>
                            </div>
                            <div class="info-item">
                                <i class="el-icon-money"></i>
                                <span>{{ station.price_per_kwh }}元/度</span>
                            </div>
                            <div class="info-item">
                                <i class="el-icon-s-data"></i>
                                <span>充电桩状态:</span>
                            </div>
                            <div class="pile-status">
                                <el-tag type="success">空闲: {{ station.availablePiles }}</el-tag>
                                <el-tag type="danger">占用: {{ station.busyPiles }}</el-tag>
                                <el-tag type="warning">维护: {{ station.maintenancePiles }}</el-tag>
                            </div>
                            <div class="info-item">
                                <i class="el-icon-time"></i>
                                <span>预计等待时间: {{ station.estimatedWaitTime }}分钟</span>
                            </div>
                            <div class="info-item">
                                <i class="el-icon-data-line"></i>
                                <span>今日充电量: {{ station.todayPower }}度</span>
                            </div>
                            <el-button type="primary" :disabled="station.availablePiles === 0"
                                @click="showChargingDialog(station)">
                                开始充电
                            </el-button>
                        </div>
                    </el-card>
                </el-col>
            </el-row>
        </div>

        <!-- 充电设置对话框 -->
        <el-dialog title="充电设置" :visible.sync="chargingDialog" width="30%">
            <el-form :model="chargingForm" :rules="chargingRules" ref="chargingForm" label-width="100px">
                <el-form-item label="充电站" prop="station_name">
                    <span>{{ selectedStation.station_name }}</span>
                </el-form-item>
                <el-form-item label="充电桩" prop="pile_id">
                    <el-select v-model="chargingForm.pile_id" placeholder="请选择充电桩">
                        <el-option v-for="pile in availablePiles" :key="pile.id"
                            :label="pile.name + ' - ' + getPileStatusText(pile)" :value="pile.id"
                            :disabled="pile.status !== 'available'">
                        </el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="充电金额" prop="amount">
                    <el-input-number v-model="chargingForm.amount" :min="10" :max="500" :step="10">
                    </el-input-number>
                    <span class="amount-hint">元（最少10元）</span>
                </el-form-item>
                <div class="charging-info" v-if="selectedPile">
                    <p>预计可充电: {{ getEstimatedPower }}度</p>
                    <p>预计充电时间: {{ getEstimatedTime }}分钟</p>
                </div>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="chargingDialog = false">取消</el-button>
                <el-button type="primary" @click="startCharging">确定</el-button>
            </div>
        </el-dialog>
    </div>
</template>

<script>
export default {
    data() {
        return {
            stations: [],
            chargingDialog: false,
            selectedStation: {},
            availablePiles: [],
            chargingForm: {
                pile_id: '',
                amount: 10
            },
            chargingRules: {
                pile_id: [
                    { required: true, message: '请选择充电桩', trigger: 'change' }
                ],
                amount: [
                    { required: true, message: '请设置充电金额', trigger: 'blur' }
                ]
            }
        }
    },
    computed: {
        selectedPile() {
            return this.availablePiles.find(pile => pile.id === this.chargingForm.pile_id);
        },
        getEstimatedPower() {
            if (!this.selectedStation.price_per_kwh || !this.chargingForm.amount) return 0;
            return (this.chargingForm.amount / this.selectedStation.price_per_kwh).toFixed(2);
        },
        getEstimatedTime() {
            if (!this.selectedPile || !this.getEstimatedPower) return 0;
            // 假设充电功率为每小时7度电
            return Math.ceil(this.getEstimatedPower * 60 / 7);
        }
    },
    created() {
        this.getStations();
        // 每60秒刷新一次充电站状态
        this.timer = setInterval(() => {
            this.getStations();
        }, 60000);
    },
    beforeDestroy() {
        if (this.timer) {
            clearInterval(this.timer);
        }
    },
    methods: {
        getStations() {
            this.$axios.get('/api/stations').then(res => {
                if (res.data.status === 200) {
                    this.stations = res.data.stations;
                }
            })
        },
        showChargingDialog(station) {
            this.selectedStation = station;
            this.getAvailablePiles(station.id);
            this.chargingDialog = true;
        },
        getAvailablePiles(stationId) {
            this.$axios.get(`/api/stations/${stationId}/piles`).then(res => {
                if (res.data.status === 200) {
                    this.availablePiles = res.data.piles;
                }
            })
        },
        getPileStatusText(pile) {
            const statusMap = {
                'available': '空闲中',
                'busy': '使用中',
                'maintenance': '维护中'
            };
            return statusMap[pile.status] || '未知状态';
        },
        startCharging() {
            this.$refs.chargingForm.validate(valid => {
                if (valid) {
                    this.$axios.post('/api/charging/start', {
                        station_id: this.selectedStation.id,
                        pile_id: this.chargingForm.pile_id,
                        amount: this.chargingForm.amount,
                        estimated_power: this.getEstimatedPower,
                        estimated_time: this.getEstimatedTime
                    }).then(res => {
                        if (res.data.status === 200) {
                            this.$message.success('充电已开始');
                            this.chargingDialog = false;
                            this.$router.push('/user/charging');
                        } else {
                            this.$message.error(res.data.message);
                        }
                    })
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

.station-card {
    margin-bottom: 20px;
}

.station-info {
    text-align: center;
}

.info-item {
    margin: 15px 0;
    color: #606266;
}

.info-item i {
    margin-right: 5px;
}

.amount-hint {
    margin-left: 10px;
    color: #909399;
    font-size: 14px;
}

.pile-status {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin: 10px 0;
}

.charging-info {
    margin-top: 15px;
    padding: 10px;
    background-color: #f5f7fa;
    border-radius: 4px;
}

.charging-info p {
    margin: 5px 0;
    color: #606266;
    font-size: 14px;
}
</style>