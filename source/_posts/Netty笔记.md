---
title: Netty笔记
date: 2017-12-12
categories: 工作与学习
tags: [java,Netty]
---
## Netty 

### 框架定义

netty 是一个用于快速开发可维护的**高性能**协议服务器和客户端的异步的事件驱动网络应用框架

 netty 的架构方法和设计原理同它的技术内容一样重要

 netty 的核心组件

  * Channels （Java NIO的一个基本抽象）
  * Callbacks （提供给另一个的方法的引用）
  * Futures （提供了另一个当操作完成时如何通知应用的方法）
  * Events和handlers （events来通知我们状态的变化或者操作的状况）

 Netty和Mina是Java世界非常知名的通讯框架。它们都出自同一个作者，Mina诞生略早，属于Apache基金会，而Netty开始在Jboss名下，后来出来自立门户netty.io。 Netty目前有两个分支：4.x和3.x，(5.x已经废弃) 4.0分支重写了很多东西，并对项目进行了分包


### netty 在一个高度上做了两件事情（技术上/结构上）
 
1. 它的异步和事件驱动基于Java NIO实现，在高负载下能保证最好的应用性能和可扩展性
2. 它包含了一系列用来解耦应用逻辑和网络层的设计模式，简化了开发的同时最大限度地提升了可测试性，模块化和可重用性。

### IO/NIO/Netty 比较
###### IO
 1. 在多数情况下，大部分的线程是休眠的，资源的浪费
 2. 线程需要额外分配不同的栈内存
 3. 在JVM物理上可支持的最大线程数未到之前，线程的切换已成问题
 
###### NIO 优点
 
 1. 一个单独的线程可处理多个并发的连接
 2. 内存的管理与上下文的切换优化明显
 3. 当没有IO需要处理的时候，可以被指派其他任务
 
###### NIO 缺点
> 要安全地使用并且正确无误并非易事。特别在高负载下，可靠并且高效地在处理和指派I/O是一项困难和容易出错的任务
 
###### Netty
 * 设计
	
	用于多种传输类型的统一API，包括阻塞和非阻塞。简单但是强大的线程模型真正的无连接数据报
	socket支持链式的支持复用的逻辑组件(Chaining of logic components to support reuse)

 * 易用性
 
	大量的文档(Javadoc)和例子库除了JDK1.6+没有别的依赖（一些可选特性可能需要Java 1.7+和/或 额外的依赖）

 * 性能 

	比core Java APIs更好的吞吐量和低延迟，因为池化和复用，减少了资源消耗，尽可能小的内存拷贝

 * 鲁棒性
	
	没有因为慢连接，快连接或者超载连接造成的OutOfMemeoryError。 在高速的网络上消除了NIO应用不公平的读/写比例
 * 安全
 
	完整的SSL/TLS和StartTLS的支持。 适用于受限的环境比如Applet或者OSGI中


## Netty 使用

### ChannelHandlers
接口 ChannelInboundHandler --> 子类 ChannelInboundHandlerAdapter

1. channelRead()—每次收到消息时被调用
2. channelReadComplete()—用来通知handler上一个ChannelRead()是被这批消息中的最后一个消息调用 
3. exceptionCaught()—在读操作异常被抛出时被调用

### ChannelHandlers 要点
1. ChannelHandlers被不同类型的event调用
2. 应用程序通过实现或扩展ChannelHandlers来挂钩event的生命周期，提供定制的业务逻辑
3. 在结构上ChannelHandlers解耦了你的业务逻辑与网络代码，因为业务逻辑会变，但网络通信不会


### 客户端 SimpleChannelInbondHandler
1. channelActive()—和服务器的连接建立起来后被调用
2. channelRead0()—从服务器收到一条消息时被调用
3. exceptionCaught()—处理过程中异常发生时被调用


### Netty 网络抽象
1. Channel—Sockets
2. EventLoop—控制流，多线程，并发
3. ChannelFuture—异步通知

 Channels，EventLoops和EventLoopGroups 的关系图
![网络抽象](http://ifeve.com/wp-content/uploads/2016/06/f3-1.jpg)

#### ChannelFuture
> netty所有的IO都是异步的，因此一个操作可能不会立即返回，我们需要一个方法稍后来判断他的结果，netty提供ChanelFuture ,他的addListener方法注册一个ChanelFutureLiitener,当操作完成时，可接受通知（必然接收）



		 	<filter>   
		    <filter-name>shiroFilter</filter-name>   
		    <filter-class>   
		       org.springframework.web.filter.DelegatingFilterProxy    
		    </filter-class>    
			</filter>    
			<filter-mapping>    
			    <filter-name>shiroFilter</filter-name>    
			    <url-pattern>/*</url-pattern>    
			</filter-mapping>

>注： 该filter 会依赖于WebApplicationContext ,如果在springmvc中，不启动WebApplicationContext，直接从server 启动  Initializing Spring FrameworkServlet 'spring',那么如果有上面这个filter，则在容器请求时，会报错
>java.lang.IllegalStateException: No WebApplicationContext found: no ContextLoaderListener registered?  