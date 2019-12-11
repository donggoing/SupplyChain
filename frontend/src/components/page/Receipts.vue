<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item>
                    <i class="el-icon-lx-cascades"></i> 账单
                </el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class="container">
            <div class="handle-box">
                <el-button class="el-icon-refresh" @click="getData"></el-button>
                    
                <el-button type="primary" v-if="usertype == 'Company'" icon="el-icon-circle-plus" @click="handleAddRec">新增</el-button>
            </div>
            <el-table
                :data="tableData"
                border
                class="table"
                header-cell-class-name="table-header"
            >
                <el-table-column prop="recIndex" label="Id" width="55" align="center"></el-table-column>
                <el-table-column prop="coreCompanyAdd" label="核心企业公钥" align="center"></el-table-column>
                <el-table-column prop="lenderAddress" label="发起者公钥" align="center"></el-table-column>
                <el-table-column prop="bankAddress" label="银行公钥" align="center"></el-table-column>
                <el-table-column prop="amount" label="账款" align="center"></el-table-column>
                <el-table-column prop="sTime" label="发起时间" align="center">
                </el-table-column>
                <el-table-column prop="eTime" label="应还款时间" align="center">
                </el-table-column>
                <el-table-column  label="详情" align="center">
                    <template slot-scope="scope">
                        <el-button
                                type="text"
                                icon="el-icon-edit" @click="getDetail(scope.$index, scope.row)"
                            >获取</el-button>
                    </template>
                </el-table-column>
                <el-table-column label="核心企业已审理" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.signed?'success':'danger'"
                        >{{scope.row.signed}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="核心企业确认" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.confirmed?'success':'danger'"
                        >{{scope.row.confirmed}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="银行已审理" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.checkByBank?'success':'danger'"
                        >{{scope.row.checkByBank}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="银行受理" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.accepted?'success':'danger'"
                        >{{scope.row.accepted}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="已还款" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.settled?'success':'danger'"
                        >{{scope.row.settled}}</el-tag>
                    </template>
                </el-table-column>
               
                <el-table-column v-if="usertype != 'Company'" label="操作"  width="180" align="center">
                    <template slot-scope="scope">
                        <el-button
                            type="text"
                            icon="el-icon-edit" v-if="(usertype=='CoreCompany'&&!scope.row.signed)||(usertype=='Bank'&&scope.row.confirmed&&!scope.row.checkByBank)"
                            @click="handleAccept(scope.$index, scope.row)"
                        >确认</el-button>
                        <el-button
                            type="text"
                            icon="el-icon-delete"
                            class="red" v-if="(usertype=='CoreCompany'&&!scope.row.signed)||(usertype=='Bank'&&scope.row.confirmed&&!scope.row.checkByBank)"
                            @click="handleRefuse(scope.$index, scope.row)"
                        >拒绝</el-button>
                        <el-button
                            type="text"
                            icon="el-icon-edit"
                            v-if="(usertype=='Bank'&&scope.row.accepted&&!scope.row.settled)"
                            @click="handleSettle(scope.$index, scope.row)"
                        >确认还款</el-button>
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

            <el-dialog title="详情" :visible.sync="detailVisible" width="30%">
            {{RecDetail}}
            </el-dialog>

        </div>

        
    </div>
</template>

<script>
export default {
    name: 'basetable',
    data() {
        return {
            usertype: localStorage.getItem('usertype'),
            query: {
                address: '',
                name: '',
                pageIndex: 1,
                pageSize: 10
            },
            detailVisible:false,
            RecDetail:'',
            tableData: [],
            multipleSelection: [],
            delList: [],
            editVisible: false,
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
            this.$http.get('/normal/myOwnRec').then(
                res=>{
                    console.log(res.data)
                    // let result = res.data
                    for(let i =0; i < res.data.length; i++){
                        res.data[i].sTime = new Date(parseInt(res.data[i].sTimeStamp)).toLocaleString().replace(/:\d{1,2}$/,' ');
                        res.data[i].eTime = new Date(parseInt(res.data[i].eTimeStamp)).toLocaleString().replace(/:\d{1,2}$/,' ');     
                    }
                    this.tableData = res.data;
                    this.pageTotal = this.tableData.length;

                },error=>{
                    console.log("数据获取失败");
                }
            )
        },
        handleRefuse(index, row) {

            this.$confirm('确定拒绝吗？', '提示', {
                type: 'warning'
            })
                .then(() => {
                   if(this.usertype == 'CoreCompany'){
                            this.$http.patch('/cc/signRec',{"index":row.recIndex,acceptOrNot:false}).then(res=>{
                                if(res.data&&res.data.success)                        
                                    this.$message.success('成功拒绝');
                                else this.$message.error('拒绝失败，请稍后再试');
                                this.getData();
                            })
                        }
                        else {
                            this.$http.patch('/bank/acceptRec',{"index":row.recIndex,acceptOrNot:false}).then(res=>{
                                if(res.data&&res.data.success)                        
                                    this.$message.success('成功接受');
                                else this.$message.error('接受失败，请稍后再试');
                                this.getData();
                            })
                        }
                })
                .catch((err) => {console.log(err);});
        },
        // 编辑操作
        handleAccept(index, row) {
            this.$confirm('确定接受吗？', '提示', {
                type: 'warning'
            })
                .then(
                    () => {
                        if(this.usertype == 'CoreCompany'){
                            this.$http.patch('/cc/signRec',{"index":row.recIndex,acceptOrNot:true}).then(res=>{
                                if(res.data&&res.data.success)                        
                                    this.$message.success('成功接受');
                                else this.$message.error('接受失败，请稍后再试');
                                this.getData();
                            })
                        }
                        else {
                            this.$http.patch('/bank/acceptRec',{"index":row.recIndex,acceptOrNot:true}).then(res=>{
                                if(res.data&&res.data.success)                        
                                    this.$message.success('成功接受');
                                else this.$message.error('接受失败，请稍后再试');
                                this.getData();
                            })
                        }
                    // this.tableData.splice(index, 1);
                })
                .catch((err) => {console.log(err);});
        },
        handleSettle(index,row){
            this.$confirm('确定已还？', '提示', {
                type: 'warning'
            })
                .then(
                    () => {
                        this.$http.patch('/bank/settleRec',{"index":row.recIndex}).then(res=>{
                            if(res.data&&res.data.success)                        
                                this.$message.success('处理成功');
                            else this.$message.error('处理失败，请稍后再试');
                            this.getData();
                        })
                    })
                    // this.tableData.splice(index, 1);
                .catch((err) => {console.log(err);});
        },
        handleAddRec(){
            this.$router.push('/newReceipt');
        },

        getDetail(index, row){
            this.RecDetail = '';
            this.detailVisible = true;
            this.$http.get('/normal/recDetail',{params:{"index":row.recIndex}}).then(res=>{
                this.RecDetail = res.data.detail;   
            },error=>{
                this.$message.error('获取失败');
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
/* .el-table /deep/ .el-table-column{
    text-align : center
} */

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
