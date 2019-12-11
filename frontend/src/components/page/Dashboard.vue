<template>
    <div style="min-width:1200px">
        
        <el-card shadow="hover" class="mgb20" style="float: left;height:600px; min-width:300px">
            <div class="user-info">
                <img src="../../assets/img/img.jpg" class="user-avator" alt />
                <div class="user-info-cont">
                    <div class="user-info-name">{{name}}</div>
                    <div>{{usertype}}</div>
                </div>
            </div>
            <div class="mgb20">
            <el-button class="el-icon-refresh" @click="refreshTime"></el-button>
            </div>
            <div class="user-info-list">
                时间
                <span>{{currentTime}}</span>
            </div>
            <div class="user-info-list">
                时间戳
                <span>{{currentTimeStamp}}</span>
            </div>
        </el-card>
        <el-card style="float: left;width:33%; margin:10px" shadow="hover" :body-style="{padding: '0px'}">
            <div class="grid-content grid-con-1">
                <i class="el-icon-lx-goods grid-con-icon"></i>
                <div class="grid-cont-right">
                    <div ><el-button type="text" @click="$router.push('/receipts')" class="grid-num">{{receiptNumber}}</el-button></div>
                    <div>Receipts</div>
                </div>
            </div>
        </el-card>
    
        <el-card style="float: left;width:33%; margin:10px" shadow="hover" :body-style="{padding: '0px'}">
            <div class="grid-content grid-con-2">
                <i class="el-icon-lx-goods grid-con-icon"></i>
                <div class="grid-cont-right">
                    <div ><el-button type="text" @click="$router.push('/tokens')" class="grid-num">{{tokenNumber}}</el-button></div>
                    <div>Token</div>
                </div>
            </div>
        </el-card>
    
        <el-card style="float: left;width:33%; margin:10px" shadow="hover" :body-style="{padding: '0px'}">
            <div class="grid-content grid-con-2">
                <i class="el-icon-lx-goods grid-con-icon"></i>
                <div class="grid-cont-right">
                    <div ><el-button type="text" @click="getCash" class="grid-num">{{cash}}</el-button></div>
                    <div>模拟现金</div>
                </div>
            </div>
        </el-card>
    
            <el-card style="float: left;width:33%; margin:10px" shadow="hover" :body-style="{padding: '0px'}">
                <div class="grid-content grid-con-3">
                    <i class="el-icon-lx-goods grid-con-icon"></i>
                    <div class="grid-cont-right">
                        <div ><el-button type="text" @click="$router.push('/finances')" class="grid-num">{{ap4FinanceNumber}}</el-button></div>
                        <div v-if="usertype == 'Bank'">融资申请</div>
                        <div v-else>融资记录</div>
                    </div>
                </div>
            </el-card>
        
        <el-card style="float: left;width:33%; margin:10px" shadow="hover" :body-style="{padding: '0px'}">
            <div class="grid-content grid-con-3">
                <i class="el-icon-lx-goods grid-con-icon" style="background:blueviolet"></i>
                <div class="grid-cont-right">
                    <div ><el-button type="text" @click="$router.push('/withdraws')" class="grid-num">{{ap4WithdrawNumber}}</el-button></div>
                    <div v-if="usertype == 'Bank'">提款申请</div>
                    <div v-else>提现记录</div>
                </div>
            </div>
        </el-card>
        <el-card v-if="usertype == 'Company'" style="float: left;width:33%; margin:10px" shadow="hover" :body-style="{padding: '0px'}">
            <div class="grid-content grid-con-3">
                <i class="el-icon-lx-goods grid-con-icon"  style="background:darkcyan"></i>
                <div class="grid-cont-right">
                    <div ><el-button type="text" @click="$router.push('/newreceipt')" class="method">提交账单</el-button></div>
                </div>
            </div>
        </el-card>
        <el-card style="float: left;width:33%; margin:10px" shadow="hover" :body-style="{padding: '0px'}">
            <div class="grid-content grid-con-3">
                <i class="el-icon-lx-goods grid-con-icon" style="background:aqua"></i>
                <div class="grid-cont-right">
                    <div ><el-button type="text" @click="$router.push('/transfers')" class="method">Token转让记录</el-button></div>
                </div>
            </div>
        </el-card>
    
        <el-card style="float: left;width:33%; margin:10px" v-if="usertype == 'Bank' || usertype == 'CoreCompany'" shadow="hover" :body-style="{padding: '0px'}">
            <div class="grid-content grid-con-3">
                <i class="el-icon-lx-goods grid-con-icon" style="background:aqua"></i>
                <div class="grid-cont-right">
                    <div ><el-button type="text" @click="inviteVisible = true" class="method">邀请新企业</el-button></div>
                </div>
            </div>
        </el-card>
    
        <el-dialog title="邀请新企业" style="text-align:center;"  :visible.sync="inviteVisible" width="30%">
            <el-form ref="form" label-width="70px">
                <el-form-item label="邀请公司公钥" >
                    <el-input v-model="inviteAddress" >
                    </el-input>
                    <!-- <el-input v-model="form.name" auto-complete="off"></el-input> -->
                </el-form-item>
                <el-form-item label="公司名称" >
                    <el-input v-model="inviteName" >
                    </el-input>
                </el-form-item>
                
                <el-button @click="inviteVisible = false">取 消</el-button>
                <el-button type="primary" @click="submitInvite">确 定</el-button>
            </el-form>
        </el-dialog>
    </div>
</template>

<script>
import bus from '../common/bus';
export default {
    name: 'dashboard',
    data() {
        return {
            name: localStorage.getItem('username'),
            usertype: localStorage.getItem('usertype'),
            currentTime:"",
            currentTimeStamp : "",
            ap4WithdrawNumber: "NAN",
            ap4FinanceNumber: "NAN",
            tokenNumber: "NAN",
            receiptNumber: "NAN",
            cash: "NAN",
            inviteVisible: false,
            inviteName: "",
            inviteAddress: ""
        };
    },

    created() {
        // this.handleListener();
        // this.changeDate();
        this.refreshTime();
        this.getReceiptNum();
        this.getTokenNum();
        this.getApNum();
        this.getCash();
    },
    methods: {
        changeDate() {
            const now = new Date().getTime();
            this.data.forEach((item, index) => {
                const date = new Date(now - (6 - index) * 86400000);
                item.name = `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
            });
        },
        refreshTime(){
            var date=new Date();   
            var year=date.getFullYear(); //获取当前年份   
            var mon=date.getMonth()+1; //获取当前月份   
            var da=date.getDate(); //获取当前日   
            var day=date.getDay(); //获取当前星期几   
            var h=date.getHours(); //获取小时   
            var m=date.getMinutes(); //获取分钟   
            var s=date.getSeconds(); //获取秒   
            this.currentTime = year+'年'+mon+'月'+da+'日'+'星期'+day+' '+h+':'+m+':'+s;
            this.currentTimeStamp = Date.now();
        },
        getReceiptNum(){
            if(this.usertype=="Company"||this.usertype=="CoreCompany"){
                this.$http.get('/normal/compRecepits').then(res=>{
                    this.receiptNumber = res.data.recIndexs.length;
                },error=>{
                    this.receiptNumber = "NAN"
                })
            }else if(this.usertype=="Bank"){
                this.$http.get('/bank/allRec4Bank').then(res=>{
                    this.receiptNumber = res.data.settledRec.length
                                        +res.data.unsettledRec.length
                                        +res.data.pendingRec.length;
                },error=>{
                    this.receiptNumber = "NAN"
                })
            }
        },
        
        getTokenNum(){
            this.$http.get('/normal/allTokensIndex').then(res =>{
                this.tokenNumber = res.data.length;
            },error=>{
                this.tokenNumber = "NAN"
            })
        },
        getCash(){
            this.$http.get('/normal/cash').then(res =>this.cash = res.data.cash,error=>this.cash = "NAN")
        },
        getApNum(){
            if(this.usertype=="Company"||this.usertype == "CoreCompany"){
                this.$http.get('/normal/application').then(res =>{
                    this.ap4WithdrawNumber = res.data.ap4Withdraw.length;
                    this.ap4FinanceNumber = res.data.ap4Finance.length;
                },error=>{
                    this.ap4WithdrawNumber = "NAN";
                    this.ap4FinanceNumber = "NAN";
                })
            }
            else if(this.usertype == "Bank"){
                this.$http.get('/bank/application').then(res =>{
                    this.ap4WithdrawNumber = res.data.PendingAp4Withdraw.length;
                    this.ap4FinanceNumber = res.data.PendingAp4Finance.length;
                },error=>{
                    this.ap4WithdrawNumber = "NAN";
                    this.ap4FinanceNumber = "NAN";
                })
            }
        },
        submitInvite(){
            this.$http.post('/invite',{address:this.inviteAddress,name:this.inviteName }).then(
                res=>{
                    res = res.data;
                    console.log(res);
                    if(res.success)
                        this.$message.success('邀请成功！');
                    else{
                        this.$message.error(res.detail);
                    }
                },
                error=>{
                    this.$message.error("邀请失败")
                }
            )
        }

    }
};
</script>


<style scoped>
.el-row {
    margin-bottom: 20px;
}

.grid-content {
    display: flex;
    align-items: center;
    height: 100px;
}

.grid-cont-right {
    flex: 1;
    text-align: center;
    font-size: 14px;
    color: #999;
}

.grid-num {
    font-size: 30px;
    font-weight: bold;
}

.grid-con-icon {
    font-size: 50px;
    width: 100px;
    height: 100px;
    text-align: center;
    line-height: 100px;
    color: rgb(255, 255, 255);
}

.grid-con-1 .grid-con-icon {
    background: rgb(45, 140, 240);
}

.grid-con-1 .grid-num {
    color: rgb(45, 140, 240);
}

.grid-con-2 .grid-con-icon {
    background: rgb(100, 213, 114);
}

.grid-con-2 .grid-num {
    color: rgb(45, 140, 240);
}

.grid-con-3 .grid-con-icon {
    background: rgb(242, 94, 67);
}

.grid-con-3 .grid-num {
    color: rgb(242, 94, 67);
}

.grid-con-3 .method{
    color:darkcyan;
    font-size:23px
}

.user-info {
    display: flex;
    align-items: center;
    padding-bottom: 20px;
    border-bottom: 2px solid #ccc;
    margin-bottom: 20px;
}

.user-avator {
    width: 120px;
    height: 120px;
    border-radius: 50%;
}

.user-info-cont {
    padding-left: 50px;
    flex: 1;
    font-size: 14px;
    color: #999;
}

.user-info-cont div:first-child {
    font-size: 30px;
    color: #222;
}

.user-info-list {
    font-size: 14px;
    color: #999;
    line-height: 25px;
}

.user-info-list span {
    margin-left: 10px;
}

.mgb20 {
    margin-bottom: 20px;
}

</style>
