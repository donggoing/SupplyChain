<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item>
                    <i class="el-icon-lx-cascades"></i> 转让记录
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
                <el-table-column label="收/让" width="55"  align="center">
                    <template slot-scope="scope">
                        <el-tag 
                            :type="scope.row.checked?'danger':'success'"
                        >{{scope.row.from==address?"让":"收"}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="prevToken" label="原TokenId"  align="center"></el-table-column>
                <el-table-column prop="curToken" label="现TokenId" align="center"></el-table-column>
                <el-table-column prop="from" label="转让者公钥" align="center"></el-table-column>
                <el-table-column prop="to" label="接收者公钥" align="center"></el-table-column>
                <el-table-column prop="amount" label="Token数量" align="center"></el-table-column>


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


    </div>
</template>

<script>
export default {
    name: 'transferRecords',
    data() {
        return {
            usertype: localStorage.getItem('usertype'),
            address: localStorage.getItem('address'),
            query: {
                address: '',
                name: '',
                pageIndex: 1,
                pageSize: 10
            },
            tableData: [],
            transferToken: '',
            transferTokenIndex :'',
            transferAmount: 0,
            receiver:'',
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
            this.$http.get('/normal/allTransferRecord').then(
                res=>{
                    console.log(res.data)
                    // "prevToken": any;
                    // "curToken": any;
                    // "amount": any;
                    // "from": any;
                    // "to"
                    this.tableData = res.data;
                    this.pageTotal = this.tableData.length;

                },error=>{
                    this.$message.error("数据获取失败");
                    console.log(error);
                }
            )
        },
        
        // handleRefuse(index, row) {

        //     this.$confirm('确定拒绝吗？', '提示', {
        //         type: 'warning'
        //     })
        //         .then(() => {
        //            if(this.usertype == 'CoreCompany'){
        //                     this.$http.patch('/cc/signRec',{"index":row.recIndex,acceptOrNot:false}).then(res=>{
        //                         if(res.data&&res.data.success)                        
        //                             this.$message.success('成功接受');
        //                         else this.$message.error('接受失败，请稍后再试');
        //                         this.getData();
        //                     })
        //                 }
        //                 else {
        //                     this.$http.patch('/bank/acceptRec',{"index":row.recIndex,acceptOrNot:false}).then(res=>{
        //                         if(res.data&&res.data.success)                        
        //                             this.$message.success('成功接受');
        //                         else this.$message.error('接受失败，请稍后再试');
        //                         this.getData();
        //                     })
        //                 }
        //         })
        //         .catch((err) => {console.log(err);});
        // },
        // // 编辑操作
        // handleAccept(index, row) {
        //     this.$confirm('确定接受吗？', '提示', {
        //         type: 'warning'
        //     })
        //         .then(
        //             () => {
        //                 if(this.usertype == 'CoreCompany'){
        //                     this.$http.patch('/cc/signRec',{"index":row.recIndex,acceptOrNot:true}).then(res=>{
        //                         if(res.data&&res.data.success)                        
        //                             this.$message.success('成功接受');
        //                         else this.$message.error('接受失败，请稍后再试');
        //                         this.getData();
        //                     })
        //                 }
        //                 else {
        //                     this.$http.patch('/bank/acceptRec',{"index":row.recIndex,acceptOrNot:true}).then(res=>{
        //                         if(res.data&&res.data.success)                        
        //                             this.$message.success('成功接受');
        //                         else this.$message.error('接受失败，请稍后再试');
        //                         this.getData();
        //                     })
        //                 }
        //             // this.tableData.splice(index, 1);
        //         })
        //         .catch((err) => {console.log(err);});
        // },
        // handleSettle(index,row){
        //     this.$confirm('确定已还？', '提示', {
        //         type: 'warning'
        //     })
        //         .then(
        //             () => {
        //                     this.$http.patch('/bank/settleRec',{"index":row.recIndex}).then(res=>{
        //                         if(res.data&&res.data.success)                        
        //                             this.$message.success('处理成功');
        //                         else this.$message.error('处理失败，请稍后再试');
        //                         this.getData();
        //                     })
        //                 })
        //             // this.tableData.splice(index, 1);
        //         .catch((err) => {console.log(err);});
        // },
        // handleAddRec(){
        //     this.$router.push('/newReceipt');
        // }

        // // 分页导航
        // handlePageChange(val) {
        //     this.$set(this.query, 'pageIndex', val);
        //     this.getData();
        // }
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
