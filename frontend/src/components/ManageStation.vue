<template>
    <div>
        <div class="header">
            充电站管理
        </div>
        <div class="body">
            <el-table :data="tableData" style="width: 89%" class="table">
                <el-table-column prop="station_name" label="充电站名称" width="200" align="center">
                </el-table-column>
                <el-table-column prop="price_per_kwh" label="每度电价格" width="200" align="center">
                </el-table-column>
                <el-table-column prop="monthly_usage" label="月使用量" width="200" align="center">
                </el-table-column>
                <el-table-column prop="operate" label="操作" width="200" align="center">
                    <template slot-scope="scope">
                        <el-button size="small" type="warning" @click="showdia_chg(scope.row)">修改
                        </el-button>

                        <el-button size="small" type="danger" @click="showdia_dlt(scope.row)">删除
                        </el-button>
                    </template>
                </el-table-column>
                <el-table-column width="120" align="center">
                    <template slot="header">
                        <el-button icon="el-icon-plus" size="small" type="success" @click="showdia_add()">添加充电站
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <el-dialog title="添加充电站" :visible.sync="dia_add" width="30%">
                <el-form ref="add_form" :model="add_form" label-width="100px" :rules="add_form_rules">
                    <el-form-item label="充电站名称：" prop="station_name">
                        <el-input v-model="add_form.station_name"></el-input>
                    </el-form-item>
                    <el-form-item label="每度电价格：" prop="price_per_kwh">
                        <el-input v-model="add_form.price_per_kwh"></el-input>
                    </el-form-item>
                    <el-form-item label="月使用量：" prop="monthly_usage">
                        <el-input v-model="add_form.monthly_usage"></el-input>
                    </el-form-item>
                </el-form>
                <div style="text-align: center;">
                    <el-button type="primary" @click="addstation()">
                        添加
                    </el-button>
                </div>
            </el-dialog>

            <el-dialog title="修改充电站" :visible.sync="dia_chg" width="30%">
                <el-form ref="form" :model="chg_form" label-width="100px">
                    <el-form-item label="充电站名称：">
                        <span>{{ chg_form.station_name }}</span>
                    </el-form-item>
                    <el-form-item label="每度电价格：">
                        <el-input v-model="chg_form.price_per_kwh"></el-input>
                    </el-form-item>
                    <el-form-item label="月使用量：">
                        <el-input v-model="chg_form.monthly_usage"></el-input>
                    </el-form-item>
                </el-form>
                <div style="text-align: center;">
                    <el-button type="primary" @click="changestation()">
                        修改
                    </el-button>
                </div>
            </el-dialog>
            <el-dialog title="删除充电站" :visible.sync="dia_dlt" width="30%">
                <div>
                    确定删除此充电站吗？
                </div>
                <div style="text-align: center;">
                    <el-button type="primary" @click="deletestation()">
                        确定
                    </el-button>
                </div>
            </el-dialog>
        </div>
    </div>
</template>

<script>
export default {
    created() {
        this.getdata()
    },
    data() {
        return {
            tableData: [],
            dia_add: false,
            dia_chg: false,
            dia_dlt: false,
            add_form: {
                station_name: '',
                price_per_kwh: '',
                monthly_usage: '',
                action: "add",
            },
            chg_form: {
                station_name: '',
                price_per_kwh: '',
                monthly_usage: '',
                action: "change",
            },
            want_delete: '',
            add_form_rules: {
                station_name: [{ required: true, message: '必填项', trigger: 'blur' }],
                price_per_kwh: [{ required: true, message: '必填项', trigger: 'blur' }],
                monthly_usage: [{ required: true, message: '必填项', trigger: 'blur' }]

            }
        }
    },
    methods: {
        getdata() {
            this.$axios.get("/api/manager/station").then((res) => {
                console.log(res.data);
                if (res.data.status == 200) {
                    this.tableData = res.data.tabledata;
                }
            })
        },
        showdia_add() {
            this.dia_add = true;
        },
        addstation() {
            this.$refs.add_form.validate(valid => {
                if (!valid)
                    return;
                else //验证通过再发送请求
                    this.$axios.post("/api/manager/station", this.add_form).then((res) => {
                        console.log(res.data);
                        if (res.data.status == 200) {
                            this.$message({
                                message: "添加成功",
                                type: "success"
                            })
                            this.dia_add = false;
                            this.getdata();
                        } else {
                            this.$message({
                                message: res.data.msg,
                                type: "error"
                            })
                        }
                    })
            })


        },
        showdia_chg(row) {
            this.chg_form.station_name = row.station_name;
            this.chg_form.price_per_kwh = row.price_per_kwh;
            this.chg_form.monthly_usage = row.monthly_usage;
            this.dia_chg = true;
        },
        changestation() {
            this.$axios.post("/api/manager/station", this.chg_form).then((res) => {
                console.log(res.data);
                if (res.data.status == 200) {
                    this.$message({
                        message: "修改成功",
                        type: "success"
                    })
                    this.dia_chg = false;
                    this.getdata();
                }
            })
        },
        showdia_dlt(row) {
            this.want_delete = row.station_name;
            this.dia_dlt = true;
        },
        deletestation() {
            this.$axios.delete("/api/manager/station", { data: { want_delete: this.want_delete } }).then((res) => {
                if (res.data.status == 200) {
                    this.$message({
                        message: res.data.msg,
                        type: "success"
                    })
                    this.getdata()
                    this.dia_dlt = false;
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