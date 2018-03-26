---
title: Dubbo
date: 2017-10-06
categories: 工作与学习
tags: [Dubbo,java]
---


### 背景
1. 单一应用架构  
	* 将所有功能集中在一个服务中，关键在于数据库ORM
2. 垂直应用架构
	* 将数据拆分成不相干的各个独立系统，关键在于前段MVC
3. 分布式服务架构
	* 各系统之间不再独立，通信存在必然，抽离出基础服务等，关键在于RPC框架
4. 流动计算架构
	* 服务大量增加，服务的浪费，需要得到治理，关键在于SOA服务治理


---
### 目的
一个服务治理框架

#### 解决问题
在大规模服务化之前，应用可能只是通过RMI或Hessian等工具，简单的暴露和引用远程服务，通过配置服务的URL地址进行调用，通过F5等硬件进行负载均衡。

*  当服务越来越多时，服务URL配置管理变得非常困难，F5硬件负载均衡器的单点压力也越来越大。

此时**需要**一个服务注册中心，动态的注册和发现服务，使服务的位置透明。
并通过在消费方获取服务提供方地址列表，实现软负载均衡和Failover，降低对F5硬件负载均衡器的依赖，也能减少部分成本。

* 当进一步发展，服务间依赖关系变得错踪复杂，甚至分不清哪个应用要在哪个应用之前启动，架构师都不能完整的描述应用的架构关系。

这时，**需要**自动画出应用间的依赖关系图，以帮助架构师理清理关系。

* 接着，服务的调用量越来越大，服务的容量问题就暴露出来，这个服务需要多少机器支撑？什么时候该加机器？

为了解决这些问题，**需要**：第一步，要将服务现在每天的调用量，响应时间，都统计出来，作为容量规划的参考指标。
其次，要可以动态调整权重，在线上，将某台机器的权重一直加大，并在加大的过程中记录响应时间的变化，直到响应时间到达阀值，记录此时的访问量，再以此访问量乘以机器数反推总容量。

以上是Dubbo最基本的几个需求


---
### 配置方式

#### XML方式
1. 消费者

		<?xml version="1.0" encoding="UTF-8"?>
		<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
			xsi:schemaLocation="http://www.springframework.org/schema/beans	
			http://www.springframework.org/schema/beans/spring-beans.xsd 
			http://code.alibabatech.com/schema/dubbo 
			http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
		
			<!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->
			<dubbo:application name="C1" />
			
			<!-- 使用ZK -->
			<dubbo:registry address="zookeeper://192.168.253.100:2181" />
		
			<!-- 生成远程服务代理，可以和本地bean一样使用demoService -->
			<dubbo:reference id="demoService" 	interface="sicau.edu.cn.dubbo.common.service.DemoService" />
			<dubbo:reference id="randomService"  interface="sicau.edu.cn.dubbo.common.service.RandomService" />
		</beans>

1. 提供者

		<?xml version="1.0" encoding="UTF-8"?>
		<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
			xsi:schemaLocation="http://www.springframework.org/schema/beans 
			http://www.springframework.org/schema/beans/spring-beans.xsd        
		    http://code.alibabatech.com/schema/dubbo   
		    http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
			<!-- 提供方应用信息，用于计算依赖关系 -->
			<dubbo:application name="P1" />
			
			<!-- 使用multicast广播注册中心暴露服务地址 -->
			<!-- <dubbo:registry address="multicast://224.5.6.7:1234" /> -->
			<!-- 使用ZK -->
			<dubbo:registry address="zookeeper://192.168.253.100:2181" />
			
			<!-- 用dubbo协议在20880端口暴露服务 -->
			<dubbo:protocol name="dubbo" port="20880" />
			
			<!-- 暴露服务 -->
			<dubbo:service interface="sicau.edu.cn.dubbo.common.service.DemoService" ref="demoServiceInte"></dubbo:service>
			<dubbo:service interface="sicau.edu.cn.dubbo.common.service.RandomService" ref="randomService"></dubbo:service>
			
			<!-- spring bean 实例初始化 -->
			<bean id="demoServiceInte" 	class="sicau.edu.cn.dubbo.provider.service.impl.DemoServiceImpl"></bean>
			<bean id="randomService" 	class="sicau.edu.cn.dubbo.provider.service.impl.RandomServiceImpl"></bean>
		
		</beans>

#### Annotation 方式

1. 消费者
		
		<?xml version="1.0" encoding="UTF-8"?>
		<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
			xmlns:context="http://www.springframework.org/schema/context"
			xsi:schemaLocation="http://www.springframework.org/schema/beans 
			http://www.springframework.org/schema/beans/spring-beans.xsd  
			http://www.springframework.org/schema/context   
			http://www.springframework.org/schema/context/spring-context-2.5.xsd       
			http://code.alibabatech.com/schema/dubbo    
			http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
		
			<context:component-scan base-package="sicau.edu.cn.dubbo.consumer.action" />
		
			<dubbo:application name="Annotation-C1" />
		
			<dubbo:registry address="zookeeper://192.168.253.100:2181" />
		
			<dubbo:annotation package="sicau.edu.cn.dubbo.consumer.action"></dubbo:annotation>
		
		</beans>

2. 提供者

		<?xml version="1.0" encoding="UTF-8"?>
		<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
			xmlns:context="http://www.springframework.org/schema/context"
			xsi:schemaLocation="http://www.springframework.org/schema/beans 
			http://www.springframework.org/schema/beans/spring-beans.xsd  
				http://www.springframework.org/schema/context   
				http://www.springframework.org/schema/context/spring-context-2.5.xsd       
		    	http://code.alibabatech.com/schema/dubbo    
		    	http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
		
		
			<!-- 提供方应用信息，用于计算依赖关系 -->
			<dubbo:application name="Annotation_P1" />
		
			<!-- 使用ZK -->
			<dubbo:registry address="zookeeper://192.168.253.100:2181" />
		
			<!-- 用dubbo协议在20880端口暴露服务 -->
			<dubbo:protocol name="dubbo" port="20880" />
		
			<dubbo:annotation package="sicau.edu.cn.dubbo.provider.service.annotation"></dubbo:annotation>
			<context:component-scan
				base-package="sicau.edu.cn.dubbo.provider.service.annotation" />
		</beans>

#### 属性方式与API方式 

	略


> 注1： 
> 
> 注解中，服务提供者，使用的@Service(version = "0.0.1") 消费者使用依赖使用的是@Reference(version = "0.0.1")，上面两个是扩展spring来写的，其具体实例是经过重新处理的，非原来本类
> 
> 注2：
>
> dubbo 是弱依赖spring的，比如在 2.5.3 版本中，其默认依赖spring 2.x 版本，可直接升级移除2.x的依赖，自己主动加入4.x等的依赖，同时需要注意的是jdk的版本问题
> 
> 注3：
> 
> 注解时，游览包需要两者 1.spring的 context:component-scan 2.dubbo扩展的dubbo:annotation 两者都需要路径来声明


---

### 启动检查

	1. 关闭单个服务检查
	<dubbo:reference interface="com.foo.BarService" check="false" />
	2. 关闭所有服务检查
	<dubbo:consumer check="false" />
	3. 关闭启动中心检查
	<dubbo:registry check="false" />


----


### 集群容错




> 警告: 多个不同应用注册了相同服务，请检查aaa-provider和bbb-provider中是否有误暴露
> 
> 解决方法： 提供同一个服务的不同provider应该将dubbo.application.name=base-service-provider **改成同一个名字** 
> 
> 警告： 相同服务，横向扩展时，需要注意
>  
> 1. applaction.name 相同
> 
> 2. 每一个横向服务dubbo:protocol 的端口需要修改不同
> 
> 警告: 如果提供者直接粗暴断开，会造成zk中数据不一致