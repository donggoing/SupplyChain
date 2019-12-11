<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item>
                    <i class="el-icon-lx-cascades"></i> 提现记录
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
                <el-table-column prop="index" label="Id"  align="center"></el-table-column>
                <el-table-column prop="tokenIndex" label="TokenId"  align="center"></el-table-column>
                <el-table-column prop="applyer" label="申请者公钥" align="center"></el-table-column>
                <el-table-column prop="bank" label="申请银行公钥" align="center"></el-table-column>
                <el-table-column prop="amount" label="提现Token数" align="center"></el-table-column>
                <el-table-column label="银行审理" align="center">
                    <template slot-scope="scope" align="center">
                        <el-tag
                            :type="scope.row.checked?'success':'danger'"
                        >{{scope.row.checked}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" v-if="usertype == 'Bank'" width="180" align="center">
                    <template slot-scope="scope">
                        <el-button
                            type="text"
                            icon="el-icon-edit" v-if="(!scope.row.checked)"
                            @click="handleAccept(scope.$index, scope.row)"
                        >受理</el-button>
                        <el-button
                            type="text"
                            icon="el-icon-delete"
                            class="red" v-if="(!scope.row.checked)"
                            @click="handleRefuse(scope.$index, scope.row)"
                        >拒绝</el-button>
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

    </div>
</template>

<script>
export default {
    name: 'withdraws',
    data() {
        return {
            usertype: localStorage.getItem('usertype'),
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
            this.$http.get('/normal/allAp4Withdraws').then(
                res=>{
                    console.log(res.data)
                    // "tokenIndex","amount","applyer","applyRate","bank","checked","confirmed"
                    this.tableData = res.data;
                    this.pageTotal = this.tableData.length;

                },error=>{
                    this.$message.error("数据获取失败");
                    console.log(error);
                }
            )
        },

        handleRefuse(index, row) {
            this.$confirm('确定拒绝吗？', '提示', {
                type: 'warning'
            }).then(() => {
                    this.$http.patch('/bank/ap4Withdraw',{index:row.index,acceptOrNot:false}).then(res=>{
                        if(res.data&&res.data.success)                        
                            this.$message.success('成功拒绝');
                        else this.$message.error(res.data.message?res.data.message:"拒绝失败，请稍后再试");
                        this.getData();
                    })
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
                        this.$http.patch('/bank/ap4Withdraw',{index:row.index,acceptOrNot:true}).then(res=>{
                            if(res.data&&res.data.success)                        
                                this.$message.success('成功接受');
                            else this.$message.error('接受失败，请稍后再试');
                            this.getData();
                        })
                    // this.tableData.splice(index, 1);
                })
                .catch((err) => {console.log(err);});
        },

    }
};
</script>

<style scoped>
body .el-table th.gutter{
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
