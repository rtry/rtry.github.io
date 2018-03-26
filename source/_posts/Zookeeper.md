---
title: Zookeeper 
date: 2017-08-26
categories: 工作与学习
tags: [java,Zookeeper]
---
## Zookeeper 简介
zk 是一个由java语言编写的软件。

解决问题：面向分布式系统，提供一个高性能的 **协调** 作用的服务器

从设计模式上看：是一个基于观察者模式的分布式服务管理框架。它负责存储和管理大家都关系的数据，然后接受观察者注册，一旦数据的状态发生变化，它负责通知各观察者做出响应。

## 提供服务：

1.	统一命名服务（Name Service）
2.	配置管理（Configuration Management）
3.	集群管理（Group Membership）

## 安装与应用 [官网](http://zookeeper.apache.org/)

### 单机安装
1. wget http://www.bizdirusa.com/mirrors/apache/ZooKeeper/stable/zookeeper3.4.5.tar.gz
2. tar xzvf zookeeper3.4.5.tar.gz
3. cd zookeeper3.4.5 
4. vim conf/zoo.cfg

		tickTime=2000
		
		dataDir=/var/lib/zookeeper
		
		clientPort=2181
5. bin/zkServer.sh (start|stop) （启动，停止命令）
6. bin/zkCli.sh -server 127.0.0.1:2181  （连接命令）

7. 连接成功后使用以下命令：

    ```
    get path [watch]
    ls path [watch]
    set path data [version]
    delquota [-n|-b] path
    quit
    printwatches on|off
    createpath data acl
    stat path [watch]
    listquota path
    history
    setAcl path acl
    getAcl path
    sync path
    redo cmdno
    addauth scheme auth
    delete path [version]
    setquota -n|-b val path 
    ```



### 集群安装

* 注意默认配置位置为 conf/zoo.cfg  无则配置（配置 server 1，2，3）
	
		dataDir=/var/lib/mydata
		server.1=zoo1:2888:3888
		server.2=zoo2:2888:3888
		server.3=zoo3:2888:3888
* 注意mydata位置 ，下 myid 文件 为集群机的序号（1，2，3）

