<template>
    <div class="login-wrap">
        <div class="ms-login">
            <div class="ms-title" style="color:black">供应链金融系统</div>
            <el-form ref="login" label-width="0px" class="ms-content">
                <el-radio-group style="position:relative width:290px" v-model="user">
                    <el-radio-button v-for = "(value,key) in users" style=" display:block" @click.native.prevent="login(key)" :key="key" :label="value.value1"></el-radio-button>
                    <!-- <el-radio-button label="北京"></el-radio-button>
                    <el-radio-button label="广州"></el-radio-button>
                    <el-radio-button label="深圳"></el-radio-button> -->
                </el-radio-group>
                
                <!-- <div class="login-btn">
                    <el-button type="primary" @click="submitForm()">登录</el-button>
                </div> -->
                <p class="login-tips" style="color:black">Tips : 私钥文件应保存于后台工程目录\api\conf\accounts下并配置\api\conf\config.json文件</p>
            </el-form>
        </div>
    </div>
</template>

<script>
export default {
    data: function() {
        return {
            param: {
            },
            users: {},
            user: ""
        };
    },
    created(){
        this.$http.get('/accounts').then(
            res=>{
                console.log(res.data)
                this.users = res.data
                for(var key in this.users){
                    this.users[key].value = this.users[key].value.substr(11,30)
                    this.users[key].value1 = `${key}(${this.users[key].value}...)`
                }
            },
            err=>{
                this.users = {};
                console.log(err)
            }
        )
    },
    methods: {

        login(username){
            this.$http.post('/login',{user:username}).then(res=>{
                res = res.data;
                localStorage.setItem('username',username);
                localStorage.setItem('usertype', res.usertype);
                localStorage.setItem('address',this.users[username].value);
                // console.log(res)
                this.$message.success("登录成功");
                this.$router.push('/');
            },error=>{
                console.log(error)
                this.$message.error("登录失败")
            }
            )
        }
    },
};
</script>

<style scoped>
.login-wrap {
    position: relative;
    width: 100%;
    height: 100%;
    background-image: url(../../assets/img/login-bg.jpg);
    background-size: 100%;
}
.ms-title {
    width: 100%;
    line-height: 50px;
    text-align: center;
    font-size: 20px;
    color: #fff;
    border-bottom: 1px solid #ddd;
}
.ms-login {
    position: absolute;
    left: 50%;
    top: 50%;
    width: 350px;
    margin: -190px 0 0 -175px;
    border-radius: 5px;
    background: rgba(255, 255, 255, 0.3);
    overflow: hidden;
}
.ms-content {
    padding: 30px 30px;
}
.login-btn {
    text-align: center;
}
.login-btn button {
    width: 100%;
    height: 36px;
    margin-bottom: 10px;
}
.login-tips {
    font-size: 12px;
    line-height: 30px;
    color: #fff;
}

.el-radio-group /deep/ .el-radio-button:focus{
    box-shadow: 0 0 0 0 !important;
    -webkit-box-shadow: 0 0 0 0 !important
}

.el-radio-group /deep/ .el-radio-button .el-radio-button__inner{
    width:100%;
    margin:3px
}

.el-radio-group /deep/ .el-radio-button .el-radio-button__inner:hover{
    width:100%;
    color:white;
    background-color: #409EFF
}
</style>