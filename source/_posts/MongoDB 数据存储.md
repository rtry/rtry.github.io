---
title: Mongo
date: 2017-02-26
categories: 工作与学习
tags: [数据存储,Mongo]
---

## 背景
* [MongoDB 官网](https://www.mongodb.com),[中文社区](http://mongoing.com/)
* MongoDB 下载分为企业版与社区版，大体差异只是安全认证，系统认证方面
![差异](/uploads/mongodb/20141013115135831.jpg)
* MongoDB推出DaaS解决方案Altas
* MongoDB 除了社区版/企业版的下载之外，还有OPS Manager/Compass/Connector for BI

## 安装
### 单机安装 
1. 下载社区版 
2. 解压文件，创建配置文件
3. 配置环境变量PATH（可选）
4. 启动 mongod -f x/x/x.conf
5. 关闭 
	*  kill 
	* 登录数据库后，db.shutdownServer()
	* mongod --shutdown --dbpath /export/mongodb-3.4.4/db/

### 集群安装
待完成


### 编码使用

```
<dependency>
	<groupId>org.mongodb</groupId>
	<artifactId>mongo-java-driver</artifactId>
	<version>3.2.2</version>
</dependency>
```
> 官网提供的jar，其本身就具有池化功能

### 认证
* 确认一点：用户是跟库一起走的
* 创建一个读写first库的用户
		
		use first
		db.createUser(
		{
			user:"first1",
			pwd:"123456",
			roles:[{role:"readWrite",db:"first"}]
		})
* 默认角色有：

	* Read：允许用户读取指定数据库
	* readWrite：允许用户读写指定数据库
	* dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
	* userAdmin：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
	* clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
	* readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
	* readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
	* userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
	* dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
	* root：只在admin数据库中可用。超级账号，超级权限
	* __system ： 超级角色
	
