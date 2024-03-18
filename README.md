## 项目说明
该项目是区块链供应链金融系统，学期结束前可访问个人服务器(地址见报告)进行访问。

前后端分别使用Vue和Express开发，与FISCO-BCOS联盟链的交互使用官方提供的Nodejs-SDK。


## 使用演示
使用演示视频见：[项目演示视频](./项目演示视频.mp4)
<video src="https://private-user-images.githubusercontent.com/29890210/313571103-147274a5-0358-480d-a445-c285245d7d6c.mp4?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTA3NDM2OTUsIm5iZiI6MTcxMDc0MzM5NSwicGF0aCI6Ii8yOTg5MDIxMC8zMTM1NzExMDMtMTQ3Mjc0YTUtMDM1OC00ODBkLWE0NDUtYzI4NTI0NWQ3ZDZjLm1wND9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDAzMTglMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwMzE4VDA2Mjk1NVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTQ0MzI2YzdlOTg2ZjZiNDczN2U0ODJmMWI4ODllMzFiZWYwNzYwYWUxMzE1ZjZhNGQxOTUwNzYxMjgyOTVlNDYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.BZk44CO2GE5kVs-ttrbTmi3_qAOwUmnrlz1V7V9jlkA">

## 节点连接配置
连接新节点需要配置backend\api\conf\config.json下的节点地址和RPC通讯端口,并替换backend\api\conf\key,backend\api\conf\ca,backend\api\conf\cert下的证书。
```
"nodes": [
    {
        "ip": "127.0.0.1",
        "port": "20200"
    }
]
```

## 添加新账户方法

将根目录下get_account.sh生成的私钥文件置于\api\conf\accounts\目录下
并修改\api\conf\config.json文件的privateKey项,添加新增项,添加格式如：
```
"华为":{ 
    "type": "pem",
    "value":"./accounts/0x43ed12399576540c80b3be1525e15897318ee044.pem"
},
```

## 启动项目
若前端无改动，则直接在backend目录下：
```
npm install         // 安装项目依赖

// 开启服务器，浏览器访问 http://localhost:3000
npm start

```

## 合约部署
由于WeBase对部署合约Gas有限制，因此根目录下的[SupplyChain](./SupplyChain.sol)文件在本地部署。
