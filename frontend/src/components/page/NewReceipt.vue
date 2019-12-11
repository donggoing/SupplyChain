<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item>
                    <i class="el-icon-lx-calendar"></i> 账单
                </el-breadcrumb-item>
                <el-breadcrumb-item>新账单</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="form-box">
                <el-form ref="form" :model="form" label-width="110px">
                    <el-form-item label="核心企业公钥">
                        <!-- <el-input v-model="form.compAddress"></el-input> -->
                        <el-select v-model="form.compAddress" placeholder="请选择">
                            <el-option
                                v-for="item in coreCompanys"
                                :key="item.address"
                                :label="item.label"
                                :value="item.address">
                            </el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="受理银行公钥">
                        <!-- <el-input v-model="form.bankAddress"></el-input> -->
                        <el-select v-model="form.bankAddress" placeholder="请选择">
                            <el-option
                                v-for="item in banks"
                                :key="item.address"
                                :label="item.label"
                                :value="item.address">
                            </el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="账款">
                        <el-input v-model="form.amount"></el-input>
                    </el-form-item>

                    <el-form-item label="账款应还日">
                        <el-col :span="11">
                            <el-date-picker
                                type="datetime"
                                placeholder="选择时间"
                                v-model="form.returnTimeStamp"
                                format="yyyy-MM-dd HH:mm:ss" value-format="timestamp"
                                style="width: 100%;"
                            ></el-date-picker>
                        </el-col>

                    </el-form-item>
                    <el-form-item label="详情（隐秘信息）">
                        <el-input rows="15" type="textarea" v-model="form.detail"></el-input>
                    </el-form-item>

                    <el-form-item>
                        <el-button type="primary" @click="onSubmit">表单提交</el-button>
                        <el-button>取消</el-button>
                    </el-form-item>
                </el-form>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'NewReceipt',
    data() {
        return {
            form: {
                compAddress: '',
                bankAddress: '',
                amount: '',
                returnTimeStamp: '',
                detail:''
            },
            coreCompanys:[],
            banks:[]
        };
    },
    created() {
        this.getBankAndCC();
    },
    methods: {
        onSubmit() {
            this.$http.post('/normal/receipt',this.form).then(res=>{
                res = res.data;
                console.log(res);
                if(res.success)
                    this.$message.success('提交成功！账单为:'+res.index+"号");
                else{
                    this.$message.error(res.detail);
                }
            }),
            error=>{
                this.$message.error("提交失败")
            }
        },
        getBankAndCC(){
            this.$http.get('/normal/allCorecompanys').then(res=>{
                try{
                    res = res.data;
                    for(let i =0; i < res.length; i++){
                        res[i].label=`${res[i].name}(${res[i].address})`;
                    }
                    this.coreCompanys = res;
                }catch(err){
                    this.$message.error('核心企业获取失败');
                }
            })
            this.$http.get('/normal/allBanks').then(res=>{
                try{
                    res = res.data;
                    for(let i =0; i < res.length; i++){
                        res[i].label=`${res[i].name}(${res[i].address})`;
                    }
                    this.banks = res;
                }catch(err){
                    this.$message.error('银行信息获取失败');
                }
            })
        }
    }
};
</script>