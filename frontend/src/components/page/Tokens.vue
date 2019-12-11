<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item>
                    <i class="el-icon-lx-cascades"></i> Token
                </el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-button class="el-icon-refresh" @click="getData"></el-button>
            </div>
            <el-table
                :data="tableData"
                border
                class="table"
                header-cell-class-name="table-header"
            >
                <!-- <el-table-column type="selection" width="55" align="center"></el-table-column> -->
                <el-table-column prop="tokenIndex" label="Id"  align="center"></el-table-column>
                <el-table-column prop="recIndex" label="账单Id" align="center"></el-table-column>
                <el-table-column prop="from" label="转让者公钥" align="center"></el-table-column>
                <el-table-column prop="source" label="还款核企公钥" align="center"></el-table-column>
                <el-table-column prop="publisher" label="发行银行公钥" align="center"></el-table-column>
                <el-table-column prop="amount" label="金额" align="center"></el-table-column>
                <el-table-column prop="returnTime" label="理论可提款时间" align="center">

                </el-table-column>
                <el-table-column label="核企已还款" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.hasSettled?'success':'danger'"
                        >{{scope.row.hasSettled}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="可提款" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.couldWithdraw?'success':'danger'"
                        >{{scope.row.couldWithdraw}}</el-tag>
                    </template>
                </el-table-column>

                <el-table-column label="操作"  width="180" align="center">
                    <template slot-scope="scope">

                        <el-button
                            type="text"
                            icon="el-icon-upload2"
                            @click="handleTransfer(scope.$index, scope.row)"
                        >转让</el-button>
                        <el-button
                            type="text"
                            icon="el-icon-d-caret" :disabled="Date.now()>scope.row.returnTimeStamp"
                            @click="handleFinance(scope.$index, scope.row)"
                        >融资</el-button>
                        <el-button
                            type="text"
                            icon="el-icon-d-caret" :disabled="!scope.row.couldWithdraw"
                            @click="handleWithdraw(scope.$index, scope.row)"
                        >提现</el-button>
                        
                    </template>
                </el-table-column>
            </el-table>
            <div class="pagination">
                <!-- <el-pagination
                    background
                    layout="total, prev, pager, next"
                    :current-page="query.pageIndex"
                    :page-size="query.pageSize"
                    :total="pageTotal"
                    @current-change="handlePageChange"
                ></el-pagination> -->
                <el-pagination
                    background
                    layout="total,pager"
                    :current-page="query.pageIndex"
                    :page-size="query.pageSize"
                    :total="pageTotal"
                ></el-pagination>
            </div>
        </div>

        <!-- 编辑弹出框 -->
        <el-dialog title="转让Token" :visible.sync="transferVisible" width="30%" style="text-align:center;">
            <el-form ref="form" label-width="70px">
                <el-form-item label="TokenID" >
                    <el-input v-model="transferToken"  :disabled="true">
                    </el-input>
                    <!-- <el-input v-model="form.name" auto-complete="off"></el-input> -->
                </el-form-item>
                <el-form-item label="接收者公钥" >
                    <el-input v-model="receiver" >
                    </el-input>
                </el-form-item>
                <el-form-item label="转让金额" >
                    <el-input v-model="transferAmount">
                    </el-input>
                </el-form-item>
                
            </el-form>
                <el-button @click="transferVisible = false">取 消</el-button>
                <el-button type="primary" @click="submitTransfer">确 定</el-button>
        </el-dialog>

        <el-dialog title="申请融资Token" :visible.sync="financeVisible" width="35%" style="text-align:center;">
            <el-form ref="form" label-width="70px">
                <el-form-item label="TokenID" >
                    <el-input v-model="financeToken"  :disabled="true">
                    </el-input>
                    <!-- <el-input v-model="form.name" auto-complete="off"></el-input> -->
                </el-form-item>
                <el-form-item label="银行公钥" style="text-align:left;" >
                    <el-select v-model="financeBank" placeholder="请选择">
                            <el-option
                                v-for="item in banks"
                                :key="item.address"
                                :label="item.label"
                                :value="item.address">
                            </el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="融资Token数量" >
                    <el-input v-model="financeAmount">
                    </el-input>
                </el-form-item>
                <el-form-item label="融资费率" >
                    <el-input v-model="financeRate">
                    </el-input>
                </el-form-item>
                
            </el-form>
                <el-button @click="financeVisible = false">取 消</el-button>
                <el-button type="primary" @click="submitFinance">确 定</el-button>
        </el-dialog>

         <el-dialog title="Token提现" :visible.sync="withdrawVisible" width="30%" style="text-align:center;">
            <el-form ref="form" label-width="70px">
                <el-form-item label="TokenID" >
                    <el-input v-model="withdrawToken"  :disabled="true">
                    </el-input>
                    <!-- <el-input v-model="form.name" auto-complete="off"></el-input> -->
                </el-form-item>
                <el-form-item label="提取金额" >
                    <el-input v-model="withdrawAmount">
                    </el-input>
                </el-form-item>
                
            </el-form>
                <el-button @click="withdrawVisible = false">取 消</el-button>
                <el-button type="primary" @click="submitWithdraw">确 定</el-button>
        </el-dialog>
    </div>
</template>

<script>
export default {
    name: 'tokens',
    data() {
        return {
            // usertype: localStorage.getItem('usertype'),
            query: {
                address: '',
                name: '',
                pageIndex: 1,
                pageSize: 10
            },
            tableData: [],
            transferToken: '',
            transferTokenIndex :'',
            transferAmount: '',
            receiver:'',
            transferVisible: false,
            financeVisible: false,
            banks:[],
            financeToken: '',
            financeBank: '',
            financeAmount: '',
            financeRate: '',
            withdrawToken: '',
            withdrawAmount: '',
            withdrawVisible: false,
            pageTotal: 0,
            form: {},
            idx: -1,
            id: -1
        };
    },
    created() {
        this.getData();
    },
    methods: {
        getData() {
            this.$http.get('/normal/allTokenInfo').then(
                res=>{
                    console.log(res.data)
                    // "recIndex": any;
                    // "owner": any;
                    // "from": any;
                    // "source": any;
                    // "publisher": any;
                    // "amount": any;
                    // "returnTimestamp": any;
                    // "hasSettled": any;
                    for(let i =0; i < res.data.length; i++){
                        res.data[i].returnTime = new Date(parseInt(res.data[i].returnTimeStamp)).toLocaleString().replace(/:\d{1,2}$/,' ');     
                        res.data[i].couldWithdraw = res.data[i].hasSettled&&res.data[i].returnTimeStamp<Date.now();
                    }
                    this.tableData = res.data;
                    this.pageTotal = this.tableData.length;

                },error=>{
                    this.$message.error("数据获取失败");
                    console.log(error);
                }
            )
        },
        handleTransfer(index, row){
            this.transferToken = row.tokenIndex;
            this.transferTokenIndex = index;
            this.transferVisible = true;
        },
        handleFinance(index, row){
            this.getBank();
            this.financeToken = row.tokenIndex;
            this.financeVisible = true;
        },
        handleWithdraw(index, row){
            this.withdrawToken = row.tokenIndex;
            this.withdrawVisible = true;
        },
        submitTransfer(){
            this.$http.post('/normal/transfer',
            {'receiver':this.receiver,'index':this.transferToken,'amount':this.transferAmount})
            .then(res=>{
                if(!(res.data&&res.data.success))
                    throw Error("Fail");
                this.$message.success("转让成功!");
                this.getData();
                this.transferVisible = false;
            }).catch(error=>{
                this.$message.error("转让失败");
                console.log(error);
            })
        },
        submitFinance(){
            this.$http.post('/normal/applyFinance',
            {index:this.financeToken,amount:this.financeAmount,bank:this.financeBank,rate:this.financeRate})
            .then(res=>{
                if(!(res.data&&res.data.success))
                    throw Error("Fail");
                this.$message.success("发起成功!");
                this.getData();
                this.financeAmount = '';
                this.financeRate = '';
                this.financeBank = '';
                this.transferVisible = false;
            }).catch(error=>{
                this.$message.error("发起失败");
                console.log(error);
            })
        },
        submitWithdraw(){
            this.$http.post('/normal/applyWithdraw',
            {index:this.withdrawToken,amount:this.withdrawAmount})
            .then(res=>{
                if(!(res.data&&res.data.success))
                    throw Error("Fail");
                this.$message.success("发起成功!");
                this.getData();
                this.withdrawAmount = '';
                this.withdrawVisible = false;
            }).catch(error=>{
                this.$message.error("发起失败");
                console.log(error);
            })
        },
        getBank(){
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

<style scoped>
body .el-table /deep/ th.gutter{
    display: table-cell!important;
}
.handle-box {
    margin-bottom: 10px;
    text-align:right
}

.handle-select {
    width: 120px;
}

.handle-input {
    width: 300px;
    display: inline-block;
}
.table {
    width: 100%;
    font-size: 14px;
}
.red {
    color: #ff0000;
}
.mr10 {
    margin-right: 10px;
}
.table-td-thumb {
    display: block;
    margin: auto;
    width: 40px;
    height: 40px;
}
</style>
