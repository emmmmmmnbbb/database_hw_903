<template>
    <div>
        <div class="header">
            &nbsp;&nbsp; 智慧云充电平台
        </div>
        <div class="body">
            <div class="liner">
                <el-menu default-active="1" class="el-menu-vertical-demo" background-color="#545c64" text-color="#fff"
                    active-text-color="#ffd04b" @select="handleselect">

                    <el-menu-item index="1">
                        <i class="el-icon-location"></i>
                        <span slot="title">充电站</span>
                    </el-menu-item>

                    <el-submenu>
                        <template slot="title">
                            <i class="el-icon-s-data"></i>
                            <span>我的充电</span>
                        </template>
                        <el-menu-item-group>
                            <el-menu-item index="2">充电中</el-menu-item>
                            <el-menu-item index="3">历史记录</el-menu-item>
                        </el-menu-item-group>
                    </el-submenu>

                    <el-submenu>
                        <template slot="title">
                            <i class="el-icon-user"></i>
                            <span>个人中心</span>
                        </template>
                        <el-menu-item-group>
                            <el-menu-item index="4">个人信息</el-menu-item>
                            <el-menu-item index="5">修改密码</el-menu-item>
                        </el-menu-item-group>
                    </el-submenu>

                </el-menu>
            </div>
            <div class="main">
                <div id="stations" v-show="active == 1">
                    <charging-stations></charging-stations>
                </div>

                <div id="charging" v-show="active == 2">
                    <my-charging></my-charging>
                </div>

                <div id="history" v-show="active == 3">
                    <charging-history></charging-history>
                </div>

                <div id="profile" v-show="active == 4">
                    <user-profile></user-profile>
                </div>

                <div id="changepwd" v-show="active == 5">
                    <change-password></change-password>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import chargingStations from '@/components/StationList.vue'
import myCharging from '@/components/UserCharging.vue'
import chargingHistory from '@/components/UserHistory.vue'
import userProfile from '@/components/UserProfile/IndiMsg.vue'
import changePassword from '@/components/UserProfile/ChPwd.vue'

export default {
    components: {
        chargingStations,
        myCharging,
        chargingHistory,
        userProfile,
        changePassword
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
    }
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