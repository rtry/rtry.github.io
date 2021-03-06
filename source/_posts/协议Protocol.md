---
title: 协议
date: 2016-11-04
categories: 工作与学习
tags: [协议]
---

## SCTP [百度百科](http://baike.baidu.com/link?url=7KCgn2gL-UfoA6e7qFvHvX6eR8z9yNhwURmPUfN1PatXo1ayiMeNiPrhhSjot2R-a3e0vfv9CbsGCBUgyKMARK)

SCTP(Stream Control Transmission Protocol,流控制传输协议)
是IETF(因特网工程任务组)在2000年定义的一个**传输层**协议


### 协议栈
协议栈是指网络中各层协议的总和，它形象的反映了网络中消息的传输过程：即由上层应用协议到底层协议，再由底层传输协议到上层协议。

### 简介
SCTP是一个面向连接的流传输协议，它可以在两个端点之间提供稳定、有序的数据传递服务。SCTP可以看做是TCP协议的改进，它继承了TCP较为完善的拥塞控制并改进TCP的一些不足之处

1. SCTP与TCP的最大不同之处在于它是多宿主（Multi-homing）连接，而TCP是单地址连接。
2. 一个TCP连接只能支持一个流，一个SCTP连接可以支持多个流（Multi-streaming）。在SCTP协议中，流（Stream）是指从一个SCTP端点到另一端点之间建立的单向逻辑通路，通常情况下所有用户消息在流中按序传递。
3. SCTP有更好的安全性。

### SCTP提供如下服务
1. 确认用户数据的无错误和无复制传输；
2. 数据分段以符合发现路径最大传输单元的大小；
3. 在多数据流中用户信息的有序发送，带有一个选项，用户信息可以按到达顺序发送；
4. 选择性的将多个用户信息绑定到单个SCTP包；
5. 通过关联的一个终端或两个终端多重宿主支持来为网络故障规定容度。



## 网络架构
### OSI七层网络架构
![OSI七层网络架构](/uploads/protocol/wKioL1Oj0Uqwr-3uAAj-G84jJp4039.jpg)
### TCP/IP五层模型的协议
![TCP/IP五层模型的协议](/uploads/protocol/TCP4.jpg)


## 序列化协议
#### 几种格式
> protobuf,thrift,JSON,XML
#### protobuf 定义
>Protocol Buffers是一种以有效并可扩展的格式编码结构化数据的方式

#### protobuf 特点
1.	灵活（方便接口更新）、高效（效率经过google的优化，传输效率比普通的XML，JSON等高很多）；
2.	易于使用；开发人员通过按照一定的语法定义结构化的消息格式，然后送给命令行工具，工具将自动生成相关的类，可以支持java、c++、python等语言环境。通过将这些类包含在项目中，可以很轻松的调用相关方法来完成业务消息的序列化与反序列化工作。
3.	语言支持；原生支持c++,java,python（其他方面也有扩展，比如js）

#### protobuf 场景

1. 内部系统之间的信息交互，并且数据大小敏感
2. 小数据的交互
3. 原生支持java,c++,python
4. 支持向后兼容与向前兼容

#### protobuf 缺点
1. 不能自描述，需要依赖生成的文件
2. 人类不可读，由于是二进制传输，人类无法直接读取

#### thrift 
> 提供了全套RPC解决方案，包括序列化机制、传输层、并发处理框架等

> 原生支持 C++, Java, Python, Ruby, Perl, PHP, C#, Erlang, Haskell



## Web service

#### restful WebService
##### 1.定义
>RESTful 服务遵循REST(Representational State Transfer)的架构风格，中文翻译为：表现层状态转化

##### 2.特点
* 网上的所有事务都可以定义为资源
* 每一个资源都有一个资源标识，对资源的操作不会改变这个标识
* 所有的操作都是无状态的


##### 3.轻量级的架构体系选择（Jax-RS实现）
* Jersey 	+ 	Grizzly
* Jersey 	+ 	Jetty
* Dropwizard
* RESTEasy 	+ 	Netty
* RESTEasy 	+ 	Undertow

> 注：
>
* [Jersey 官网](https://jersey.java.net)，[Grizzly官网](https://grizzly.java.net/)，[dropwizard](http://www.dropwizard.io/)
* jersey 是基于Java的一个轻量级RESTful风格的Web Services框架。
* JAX-RS 是JAVA EE6引入的一个新技术，全称：Java API fro RESTful Web Wervices ,是一个java语言的应用程序接口，支持REST风格的web服务。JAX-RS使用了JAX-RS 使用了Java SE5引入的标注来简化开发（@Path，@Produces ...）
* 基于JAX-RS实现的框架有 Jersey,RESTEasy 等，可很方便的部署到Servlet容器中（Tomcat，Jboss）
* Grizzly 是一个应用程序框架，专门解决编写成千上万用户访问服务器时产生的各种问题，使用java nio作为基础，并隐藏其复杂性，当然更重要的你可以把他当成一个NIO框架(当然它是一个应用程序框架)
* Jetty 是一个开源的servlet容器，使用java编写，可嵌入性与精简性（相对于Tomcat），Jetty 属于eclipse
* **dropwizard** is a java framework for developing ops-friendly,high-preformance,Restful web service. (一个完整的服务框架，实际上集成了Jersey+Jetty)
* Undertow 嵌入式服务器

##### 4.轻量级的架构体系选择（非Jax-RS实现）
* Spring Boot
* 纯Netty
* Vert.x


> 注：
>
* [vert.x](http://vertx.io/) ,属于Eclipse ，is a tool-kit for building reactive application on the JVM 
* vert.x底层使用Netty,可以使用Java 8 Lambda语法
* AWS (亚马逊公司旗下云计算服务平台类同阿里云)
* 测试工具（Dubbo Remoting Performance Test Report
）
* 测试工具 wrk（modern http benchmarking tool）
[wrk](https://github.com/wg/wrk)
* [GCViewer](https://github.com/chewiebug/GCViewer)
##### 5.较重量级的服务器
springmvc/cxf + tomcat/Jboss 等


#### 3.4.5 比较结论：
* RESTEasy的性能要好于Jersey
* Jersey+Grizzly2和Jersey+Jetty, dropwizard性能差别不大
* 纯netty的性能远远高于其它框架
* Vert.x 性能看起来不是太好，而且随着并发量增大吞吐率也随之下降


#### SOAP WebService




## RPC框架



## 安全协议

### ssh 介绍
* openssl 不是协议，而是对协议的实现，SSL/TLS　才是协议。
* openssh 利用 openssl 提供的库。openssl 中也有个叫做 openssl 的工具，是 openssl 中的库的命令行接口。

### openssh版本协议 
* openssh V1:存在安装漏洞，现已不再采用 
* openssh V2:现在推出的RHEL系列版本默认采用的版本协议

### openssh命令
* ssh -V （查看版本号）
* ssh root@192.168.253.102 (ssh 远程登录，需要密码验证)
* service sshd restar/stop/start
* 

### ssh 配置文件
* 位置：/etc/ssh/sshd_config
* 修改端口：Port 22（默认为22,建议自定义）

### scp (两台主机直接复制数据,加密传输)
* rpm -qf `which scp`  (检查是否安装)
* scp hhh.text root@192.168.253.102:/export/ (将本地当前目录下的hhh.text 文件复制到远程/export/)


### ssh 免密码登录
>  ssh-keygen -t rsa
>   <br> 
> 该命令会在客户机 root/.ssh/ 下面生成id_rsa（私钥） id_rsa.pub（公钥） 
> <br> 
>  ssh-copy-id -i id_rsa.pub nick@192.168.2.29
>  <br>
>  该命令将公钥上传到待访问机器上
>  <br>
>  chmod 700 ~/.ssh 
>  <br>
>  chmod 600 ~/.ssh/authorized_keys 
>  <br>
>  修改 服务器中访问权限



注： 登录日志可查看的文件 /var/log/secure


### Git 之 ssh 




### JSR 
*	JSR是Java Specification Requests的缩写，意思是Java 规范提案。是指向JCP(Java Community Process)提出新增一个标准化技术规范的正式请求。任何人都可以提交JSR，以向Java平台增添新的API和服务。JSR已成为Java界的一个重要标准。
* [JSR](https://jcp.org/en/home/index)

#### 常用的标准

* 从Spring 3.0开始，Spring开始支持JSR-330标准的注解（依赖注入）。这些注解和Spring注解扫描的方式是一致的
* JSR 303 - Bean Validation （Hibernate Validator）
* Java API for RESTful Web Services (JAX-RS) 1.1 (JSR 311)
* Common Annotations for the Java Platform 1.1 (JSR 250)
* JSR 370: JavaTM API for RESTful Web Services (JAX-RS 2.1) Specification



---------
### 数学
#### 对数

* log表示对数。
* 如果a^n = b（a>0，且a≠1），那么数n叫做以a为底b的对数，记做n=log(a)b，【a是下标】
* 其中，a叫做“底数”，b叫做“真数”。　　
* 相应地，函数y=logaX叫做对数函数。对数函数的定义域是（0，+∞）。零和负数没有对数。
* 底数a为常数，其取值范围是（0，1）∪（1，+∞）。
* 当a=10时，写作：y=lgx【常用对数】。
* 当a=e【自然对数的底数】时，写作y=lnx
* 例：2^3 =8
* 那么 log(2) 8 = 3

#### 二叉搜索树

* 二叉搜索树的特点是，小的值在左边，大的值在右边，即

![2](/uploads/protocol/11182147-200b853b8a954defab784cc653e96402.jpg)

* 如实例：

![2](/uploads/protocol/11182519-1c215a72b08142ae90b4f7143d83e84c.jpg)

可以非常方便的获取最大值，最小值，某元素的前驱，某元素的后驱

* 最大值：树的最右节点。

* 最小值：树的最左节点。

* 某元素前驱：左子树的最右。

* 某元素的后继：右子树的最左。

由上可知，二叉搜索树的dictionary operation（包括search、insertion、deletion）的时间复杂度均与O(h)相关，h为树的高度（log n），如果按照上述的insertion方法构建树，那么构建出来的树的形状各异，特别是当输入序列有序时，更会退化到链表的程度。所以，如果能用某种方法，将树的高度降低到最小，那么其dictionary operation的时间开销均可以降低，不过相对而言构建树的开销将增大。为了降低二叉搜索树的高度而提出了平衡二叉树（Balanced Binary Tree）的概念。它要求左右两个子树的高度差的绝对值不超过1，并且左右两个子树都是一棵平衡二叉树。这样就可以将搜索树的高度尽量减小。常用算法有红黑树、AVL、Treap、伸展树等。

#### btree索引的常见误区

以 index(a,b,c) 为例,(注意和顺序有关)

* where a=2 可以用到索引
* where a=1 and b=2 可以用到索引
* where a=1 and b=2 and c=3 可以用到索引
* where b=1 / c=1 不能用到索引
* where a=1 and c=1 a可以发挥索引，c不能使用到索引
* where a=1 and b>10 and c=1 a可以发挥索引，b也可以发挥索引，c不能发挥索引
* where a=1 and b like 'xxx%' and c=1 a可以发挥索引，b可以发挥索引，c不能发挥索引

> i386 简单理解就是是32位的amd64 是64位的版本，因为是amd把64位率先引进桌面系统的，英特尔也是要追随amd并且保持兼容，一般在软件包里包含这样的字符
