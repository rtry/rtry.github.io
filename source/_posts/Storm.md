---
title: Storm
date: 2017-05-11
categories: 工作与学习
tags: [大数据,storm]
---

## Storm 文档

### 1.Storm 简介
- [x]  storm 是一个开源的, 分布式的, **实时的**, 可靠的, 容错的, 大数据*流式处理系统*。

- [x] storm 基于JVM 
- [x] storm 依赖于zk
##### 1.1 Storm版本的变更：
```
storm 0.9.x 
storm 0.10.x
storm 1.x 
前面这些版本里面storm的核心源码是由java+clojule组成的。

storm 2.x
后期这个版本就是全部用java重写了
阿里在很早的时候就对storm进行了重写，提供了jstorm，
后期jstorm也加入到apachestorm负责使用java对storm进行重写，
这就是storm2.x版本的由来
```


> storm 后来加入apache 成为apache的项目后，其底层通信出现变化
	
> 在 0.9.x 之前 使用的是一个 性能卓越的 消息队列 ZeroMQ,在0.9.x 之后添加了netty作为通信基础，当然，这是一个更好的选择，毕竟在安装集群的时候，底层的依赖减少了


##### 1.2  Storm 概述

> 在Storm中，先要设计一个用于实时计算的图状结构，我们称之为拓扑（topology）。这个拓扑将会被提交给集群，由集群中的主控节点（master node）分发代码，将任务分配给工作节点（worker node）执行。一个拓扑中包括spout和bolt两种角色，其中spout发送消息，负责将数据流以tuple元组的形式发送出去；而bolt则负责转换这些数据流，在bolt中可以完成计算、过滤等操作，bolt自身也可以随机将数据发送给其他bolt。由spout发射出的tuple是不可变数组，对应着固定的键值对。

##### 1.3  Storm基础概念
*  Topology : 拓扑结构
*  Stream : 一个没有边界的tuple序列，这些tuples会被以一种分布式的方式并行地创建和处理
*  Spouts : 消息源，是消息生产者，他会从一个外部源读取数据并向topology里面面发出消息：tuple
*  Bolts : 消息处理者，所有的消息处理逻辑被封装在bolts里面，处理输入的数据流并产生输出的新数据流,可执行过滤，聚合，查询数据库等操作
*  Nimbus : 主控节点运行Nimbus守护进程，对节点分配任务，并监视主机故。
*  Supervisor : 工作节点运行Supervisor守护进程,负责监听工作节点上已经分配的主机作业，启动和停止Nimbus已经分配的工作进程<br>
 

> 注：clojure 是基于jre的一个lisp [clojure 中文网](http://clojure-china.org/)

> [zeroMQ](http://zeromq.org/) 是一个高性能通信框架

> [storm 官网](http://storm.apache.org/)
### 2.Storm 集群搭建
* jdk 安装 
* python 安装 (python -V) 系统自带
* zookeeper 集群安装
* 开始安装storm集群
> 1：下载storm的安装包apache-storm-1.0.2.tar.gz
> 
> 2：上传到192.168.1.100这台服务器的/usr/local目录下
> 
> 3：解压，重命名 <br>
	tar -zxvf apache-storm-1.0.2.tar.gz <br> 
	mv apache-storm-1.0.2 storm <br>

> 4：修改配置文件<br>
	cd storm/conf<br>
	vi storm.yaml<br>
storm.zookeeper.servers:<br>
     - "192.168.253.100"<br>
     - "192.168.253.102"<br>
     - "192.168.253.103"<br>
storm.local.dir: "/export/apache-storm-1.1.0/dataDir"<br>
nimbus.seeds: ["192.168.253.100"]<br>

> 5.将配置覆盖到其他节点

> 6.启动
> 192.168.253.100<br>
nimbus：nohup bin/storm nimbus >/dev/null 2>&1 &<br>
ui：nohup bin/storm ui >/dev/null 2>&1 &<br>
logviewer：nohup bin/storm logviewer >/dev/null 2>&1 &

> 192.168.253.102<br>
nimbus：nohup bin/storm nimbus >/dev/null 2>&1 &<br>
logviewer：nohup bin/storm logviewer >/dev/null 2>&1 &<br>
supervisor：nohup bin/storm supervisor >/dev/null 2>&1 &

> 192.168.253.103<br>
supervisor：nohup bin/storm supervisor >/dev/null 2>&1 &<br>
logviewer：nohup bin/storm logviewer >/dev/null 2>&1 &


	http://192.168.253.100:8080  可查看UI

	最完整的属性配置在storm-core.jar中的defaults.yaml文件中
	启动Storm可能会遇到的问题
	如果启动 nimbus 时有显示 ERROR java.net.UnknownHostException 未知的名称或服务，
	或者启动 supervisor 后一会进程就中断了，则需要添加主机名的 ip 映射。执行 sudo vim /etc/hosts，
	增加一行 127.0.0.1 dblab，如下图所示。其中 dblab 为主机名


### 3.Storm 开发
	1. spount 会被周期性的调用，故需要对线程进行控制
	2. 如果spount 出现异常，错误会一直反复的出现，因为它会一直调用
	3. strom不会停止，需要手动关闭这个拓扑
	4. 每个supervisor节点不能直接读取nimbus节点上的数据，故你需要在每个节点上处理数据的写入
	5. supervisor 与nimbus的节点数据进行通信时，可能是使用的nimbus的主机名进行通信，所以在supervisor上，需要能够通过主机名找到nimbus所在，故可能需要在supervisor的hosts文件上陪上主机nimbus的映射
