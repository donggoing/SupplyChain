<template>
    <div>
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item>
                    <i class="el-icon-lx-cascades"></i> 银行
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
                <el-table-column prop="name" label="银行名称"  align="center"></el-table-column>
                <el-table-column prop="address" label="公钥地址" align="center"></el-table-column>

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
    name: 'normalCompanys',
    data() {
        return {
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
            this.$http.get('/normal/allBanks').then(
                res=>{
                    console.log(res.data)
                    this.tableData = res.data;
                    this.pageTotal = this.tableData.length;

                },error=>{
                    this.$message.error("数据获取失败");
                    console.log(error);
                }
            )
        },
  
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
