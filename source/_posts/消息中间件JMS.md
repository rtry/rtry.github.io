---
title: 消息中间件
date: 2017-03-14
categories: 工作与学习
tags: [JMS规范,MQ]
---

## JMS规范说明

###  定义
java 消息服务（java message service） JMS，是一个java 平台面向消息中间件的API，用于在两个系统之间，或分布式系统中发送、接受消息，进行异步通信

###  概念
* 提供者：实现JMS规范的消息中间件服务器
* 客户端：发送或接受消息的应用程序
* 生产者/发布者：创建并发送消息的客服端
* 消费者/订阅者：接受并处理消息的客服端
* 消息：传递内容
* 消息模式：传递方式，JMS中定义了主题与队列两种


###  消息模式

####  队列模式
1. 客服端包括生产者与消费者
2. 队列中的消息只能被一个消费者消费
3. 消费者可以随时消费队列中的消息

####  主题模式
1. 客服端包含发布者和订阅者
2. 主题中消息可以被所有的订阅者消费
3. 消费者不能消费订阅之前就发送到主题中的消息



### JMS 编码接口


编码接口            | 含义
---                 |---
ConnectionFactory   | 创建连接到消息中间件的连接工厂
Connection          | 代表连接通信链路
Destination         | 指消息发布和接收的地点，包括队列和主题
Session             | 代表一个单线程上下文，用于发送与接收消息
MessageConsumer     | 由会话创建，用户接收消息
MessageProducer     |  由会话创建，用于发送消息
Message             | 消息对象，消息头，一组消息属性，一个消息体


## ActiveMQ编码

### ActiveMQ 两种模式(主题/队列)独立编码
> 代码 [pt-jms](https://git.coding.net/testfelicity/pt.git) 


### ActiveMQ 与Spring 整合编码
编码接口            | 含义
---                 |---
ConnectionFactory   | spring提供的管理连接的连接池(SingleConnectionFactory和CachingConnectionFactory)
JmsTemplate         | 用于发送和接收消息的模板类(spring 容器中注入该类就可以使用)
MessageListerner    | 消息监听器(实现onmessage方法就可以)

> 代码 [pt-spring-jms](https://git.coding.net/testfelicity/pt.git)



## ActiveMQ  集群
> 为实现高可用(一个挂掉，另一个立即顶上，消息不丢失)，负载均衡 （压力不用集中在一个节点上）

* ActiveMQ 的cilent-to-broker的连接，叫做传输连接(Transport connectors)
* ActiveMQ 的broker-to-broker间的连接，叫做网络连接(Network connectors)
* ActiveMQ支持许多种客户端与服务器的传输连接。分别是TCP，NIO，UDP，SSL，HTTP(S)，VM，AMQP，MQTT，Peer，Multicast，WebSockets。

配置：
```
<transportConnectors>  
    <transportConnector name="openwire" uri="tcp://localhost:61616" />  
    <transportConnector name="ssl" uri="ssl://localhost:61617"/>  
    <transportConnector name="stomp" uri="stomp://localhost:61613"/>  
    <transportConnector name="ws" uri="ws://localhost:61614/" />  
    <transportConnector name="amqp+ssl" uri="amqp+ssl://localhost:5671/" />  
</transportConnectors> 
```


###  集群方式
* 客户端集群： 让多个消费者消费同一个队列
* Broker cluster ：多个Broker之间同步消息
* Master Slave ：实现高可用


> * 集群使用时需要对客户端进行配置
> *  ActiveMQ 失效转移
> * failover:(uri1,...,uriN)?transportOptions

#### Broker cluster 
> 节点之间通过网络连接器实现节点通信
> 网络连接器：静态连接器/动态连接器

* 示例图

![](/uploads/jms/27612-20160326151335604-951843855.png)

* 配置activemq-1
```
<beans
        xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
  http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">

  <bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
    <property name="locations">
      <value>file:${activemq.conf}/credentials.properties</value>
    </property>
  </bean>

  <broker xmlns="http://activemq.apache.org/schema/core" brokerName="activemq-1">
    <networkConnectors>
      <networkConnector uri="static:(tcp://127.0.0.1:61626)"/>
    </networkConnectors>
    <persistenceAdapter>
      <kahaDB directory="${activemq.data}/kahadb"/>
    </persistenceAdapter>
    <transportConnectors>
      <transportConnector name="openwire"
                          uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
    </transportConnectors>
  </broker>

  <import resource="jetty.xml"/>
</beans>
```
* 配置activemq-2
```
<beans
        xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
  http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">

    <bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
        <property name="locations">
            <value>file:${activemq.conf}/credentials.properties</value>
        </property>
    </bean>

    <broker xmlns="http://activemq.apache.org/schema/core" brokerName="activemq-2">
        <networkConnectors>
            <networkConnector uri="static:(tcp://127.0.0.1:61616)"/>
        </networkConnectors>
        <persistenceAdapter>
            <kahaDB directory="${activemq.data}/kahadb"/>
        </persistenceAdapter>
        <transportConnectors>
            <transportConnector name="openwire"
                                uri="tcp://0.0.0.0:61626?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
        </transportConnectors>
    </broker>

    <import resource="jetty.xml"/>
</beans>
```
详细配置将[ Broker cluster](http://www.cnblogs.com/yjmyzz/p/activemq-ha-using-networks-of-brokers.html)

> 各节点之间的数据可以完整访问（consele，lisetener）
 

#### Master Slave  集群的三种方式


Master/Slave集群类型|	要求    |	好处    |	需要考虑的因素
---                 | ---       |---        |---
Share File System Master Slave  |	共享文件系统如SAN|		可运行任意多个salves，自动恢复老的master|		需要共享文件系统
JDBC Master Slave	|	公用数据库|		同上|		需要一个公用数据库，较慢因为不能使用高性能日志
Replicated LevelDB Store|		Zookeeper|		同上 + 非常快|		需要Zookeeper服务器

>  当前状态有且只有一个可以被当做master，同时比如web控制台也只有一个，他们的监听端口什么的 都只会有一个有效，在切换master的时候，会有卡顿的情况

##### Share File System Master

```
<persistenceAdapter>  
        <!--<kahaDB directory="${activemq.data}/kahadb"/>-->  
    <kahaDB directory="E:/activeMQ/sharedb"/>  
</persistenceAdapter
```

```
ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory("failover:(tcp://127.0.0.1:61616,tcp://127.0.0.1:61617)");  
```
#####  JDBC Master Slave


```
 <persistenceAdapter>  

        <!-- jdbc -->  
        <jdbcPersistenceAdapter dataDirectory="${activemq.data}" dataSource="#oracle-ds"/>  
        </persistenceAdapter>  
```


```
	<bean id="oracle-ds" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
		<property name="driverClassName" value="oracle.jdbc.driver.OracleDriver"/>
		<property name="url" value="jdbc:oracle:thin:@localhost:1521:mqtest"/>
		<property name="username" value="activemq"/>
		<property name="password" value="123456"/>
		<property name="poolPreparedStatements" value="true"/>
	</bean>
```
#####  Replicated LevelDB Store
略

以上3中配置见[ Master Slave  集群的三种方式](http://blog.csdn.net/andyxuq/article/details/38231961)


####  两种集群方式的对比 
 ~              | 高可用 | 负载均衡
---             | ---    |---
Master Slave    | 是     |否
Broker cluster  | 否     |是

## 完美集群方案
Master Slave + Broker cluster

服务端口    |   管理端口    |  jetty端口|  存储   |   网络连接器  |   用途
---         |---            |---        |---      |   ---         |   ---
node-a      |61617          |8162       |自存储   |node-b,node-c  |消费者
node-b      |61618          |8163       |共享存储 |node-a         |生产者，消费者
node-c      |61619          |8164       |共享存储 |node-a         |生产者，消费者

按顺序启动ABC

>  3台单独服务器，配置方案，以共享文件系统

服务端口    |   管理端口    |   jetty   |   网络连接器  |   用途
---         |---            |---        |---            |   ---
node-a (192.168.253.104)|61620          |8170       |自存储   |node-b,node-c  |消费者
node-b (192.168.253.105)|61620          |8170       |共享存储 |node-a         |生产者，消费者
node-c (192.168.253.106)|61620          |8170       |共享存储 |node-a         |生产者，消费者

> 安装nfs共享文件系统


## 企业实践

### 需要解决的问题
1. 不同业务系统分别处理同一个消息，同一业务系统负载处理同类消息
2. 处理消息发送时的一致性问题
3. 解决消息处理时的幂等性问题
4. 基于消息机制建立事件总线

FIX 1: 使用ActiveMQ的虚拟主题解决方法
* 发布者：将消息发布到一个主题中，主题名以VirtualTopic.Test开头
* 消费者：从队列中获取，在队列中表明身份，Consumer.A.VirtualTopic.Test

FIX 2：弱一致性
1.使用消息表的本地事务解决（数据库）
2.使用内存日志

FIX 3: 幂等性
1.使用消息表的本地事务解决（数据库）
2.使用内存日志


##  其他补充

### 什么是AMQP

 AMQP （advanced message queuing protocol） 是一个提供统一消息服务的应用层标准协议，基于此协议的客户端与消息中间件可传递消息，并不受客户端/中间件不同产品，不同开发语言等条件限制
 
### 什么是ActiveMQ
  是apache出品的，最流行，能力强劲的开源消息总线，完整支持JMS1.1 和J2EE 1.4规范的JMS Provider 实现

 特点：
* 多语言和协议编写客户端，语言支持：java,c,c++,Ruby.php等，应用协议：Openwire，Stomp Rest，XMPP，AMQP 等
* 完全支持JMS1.1 和J2EE 1.4规范（持久化，XA消息，事务）
* 虚拟主题，组合目的，镜像队列

### 什么是RabbitMQ
    一个开源的AMQP实现（pivotal 公司），服务端用Wralang语言编写，用于在分布式系统中存储转发消息
 特点：
* 支持多客户端：如 python,java，jms,c ,php 等
* AMQP完整实现
* 事务支持/发布确认
* 消息持久化

### 什么是Kafka

 一种高吞吐量的分布式发布订阅消息系统

 特点：
* 通过O(1) 的磁盘数据结构提供消息的持久化，这种结构对于即使数以TB的消息存储也能保证稳定性
* 高吞吐量
