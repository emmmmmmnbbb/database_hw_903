<template>
    <div>
        <div class="header">
            &nbsp;&nbsp; 智慧云充电平台---后台管理
        </div>
        <div class="body">
            <div class="liner">
                <el-menu default-active="1" class="el-menu-vertical-demo" background-color="#545c64" text-color="#fff"
                    active-text-color="#ffd04b" @select="handleselect">

                    <el-menu-item index="1">
                        <i class="el-icon-s-shop"></i>
                        <span slot="title">充电站管理</span>
                    </el-menu-item>

                    <el-submenu>
                        <template slot="title">
                            <i class="el-icon-s-data"></i>
                            <span>充电记录管理</span>
                        </template>
                        <el-menu-item-group>
                            <el-menu-item index="2">充电中记录</el-menu-item>
                            <el-menu-item index="3">历史记录</el-menu-item>
                        </el-menu-item-group>
                    </el-submenu>
                </el-menu>
            </div>
            <div class="main">
                <div id="manageshop" v-show="active == 1">
                    <manageshop></manageshop>
                </div>

                <div id="charging" v-show="active == 2">
                    <charging-records></charging-records>
                </div>

                <div id="history" v-show="active == 3">
                    <history-records></history-records>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import manageshop from '@/components/ManageStation.vue'
import chargingRecords from '@/components/ChargingRecords.vue'
import historyRecords from '@/components/HistoryRecords.vue'

export default {
    components: {
        manageshop,
        chargingRecords,
        historyRecords
    },
    data() {
        return {
            active: 1,
        }
    },
    methods: {
        handleselect(index) {
            this.active = index;
        }
    },
}
</script>

<style scoped>
.header {
    width: 100%;
    height: 10vh;
    /* text-align: center; */
    line-height: 10vh;
    font-size: 25px;
    font-weight: 800;
    background-color: #e3e3e3;
    /* padding-left: 100px; */
}

.body {
    width: 100%;
    height: 648px;
    display: flex;
    justify-content: space-around;
}

.liner {
    width: 15%;
    height: 100%;
    background-color: #545c64;
}

.main {
    width: 85%;
}
</style>