---
title: Servlet 
date: 2017-04-20
categories: 工作与学习
tags: [java,收藏夹软件]
---

> Servlet 大版本发布情况

Servlet版本 |      发布日期|JAVA EE/JDK版本|WebSocket 支持 |tomcat 版本|
---         |           ---|           ---|            ---|        ---|
Servlet 1.0	|    1997年06月|           ---|            ---|        ---|
Servlet 2.2|	1999年08月|	J2EE 1.2, J2SE 1.2  |---|3.3.x|
Servlet 2.3|	2001年08月|	J2EE 1.3, J2SE 1.2  |---|4.1.x|
Servlet 2.5|	2005年10月|	JavaEE 5, JavaSE 5	|---|6.0.x|
Servlet 3.0|	2009年12月|	JavaEE 6, JavaSE 6	|1.1|7.0.x| 
Servlet 3.1|	2013年05月|JavaEE 7		        |1.1|8.5.x|


* servlet2.2 ： 引入了 self-contained Web applications 的概念。
* servlet2.3 ： Servlet API 2.3中最重大的改变是增加了 filters
* servlet2.4 ： 增加了新的最低需求，新的监测 request 的方法，新的处理 response 的方法，新的国际化支持，RequestDispatcher 的几个处理，新的 request listener 类，session 的描述，和一个新的基于 Schema 的并拥有 J2EE 元素的发布描述符。这份文档规范全面而严格的进行了修订，除去了一些可能会影响到跨平台发布的模糊不清的因素。总而言之，这份规范增加了四个新类，七个新方法，一个新常量，不再推荐使用一个类

* servlet2.5 
1) 基于最新的 J2SE 5.0 开发的。
2) 支持 annotations 。
3) web.xml 中的几处配置更加方便。
4) 去除了少数的限制。
5) 优化了一些实例

* servlet3.0 ： 作为 Java EE 6 规范体系中一员，随着 Java EE 6 规范一起发布。该版本在前一版本(Servlet 2.5)的基础上提供了若干新特性用于简化 Web 应用的开发和部署。

* servlet4.0草案 ： 
从3.1到4.0将是对Servlet 协议的一次大改动，而改动的关键之处在于对HTTP/2的支持。HTTP2将是是继上世纪末HTTP1.1协议规范化以来首个HTTP协议新版本，相对于HTTP1.1，HTTP2将带来许多的增强。在草案提议中，Shing Wai列举出了一些HTTP2的新特性，而这些特性也正是他希望在Servlet 4.0 API中实现并暴露给用户的新功能，这些新特性如下:
1. 请求/响应复用(Request/Response multiplexing)
2. 流的优先级(Stream Prioritization)
3. 服务器推送(Server Push)
4. HTTP1.1升级(Upgrade from HTTP 1.1)

Servlet 3.0特性
* 异步处理支持
> 有了该特性，Servlet 线程不再需要一直阻塞，直到业务处理完毕才能再输出响应，最后才结束该 Servlet 线程。在接收到请求之后，Servlet 线程可以将耗时的操作委派给另一个线程来完成，自己在不生成响应的情况下返回至容器。针对业务处理较耗时的情况，这将大大减少服务器资源的占用，并且提高并发处理速度
1. 对于使用传统的部署描述文件 (web.xml) 配置 Servlet 和过滤器的情况，Servlet 3.0 为 <servlet> 和 <filter> 标签增加了 <async-supported> 子标签，该标签的默认取值为 false，要启用异步处理支持，则将其设为 true 即可。以 Servlet 为例，其配置方式如下所示：

```
<servlet> 
    <servlet-name>DemoServlet</servlet-name> 
    <servlet-class>footmark.servlet.Demo Servlet</servlet-class> 
    <async-supported>true</async-supported> 
</servlet>
```
2. 对于使用 Servlet 3.0 提供的 @WebServlet 和 @WebFilter 进行 Servlet 或过滤器配置的情况，这两个注解都提供了 asyncSupported 属性，默认该属性的取值为 false，要启用异步处理支持，只需将该属性设置为 true 即可。以 @WebFilter 为例，其配置方式如下所示：

```
@WebFilter(urlPatterns = "/demo",asyncSupported = true) 
public class DemoFilter implements Filter{...}
```

一个简单的模拟异步处理的 Servlet 示例如下：

```
@WebServlet(urlPatterns = "/demo", asyncSupported = true)
public class AsyncDemoServlet extends HttpServlet {
    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp)
    throws IOException, ServletException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println("进入Servlet的时间：" + new Date() + ".");
        out.flush();
 
        //在子线程中执行业务调用，并由其负责输出响应，主线程退出
        AsyncContext ctx = req.startAsync();
        new Thread(new Executor(ctx)).start();
 
        out.println("结束Servlet的时间：" + new Date() + ".");
        out.flush();
    }
}
 
public class Executor implements Runnable {
    private AsyncContext ctx = null;
    public Executor(AsyncContext ctx){
        this.ctx = ctx;
    }
 
    public void run(){
        try {
            //等待十秒钟，以模拟业务方法的执行
            Thread.sleep(10000);
            PrintWriter out = ctx.getResponse().getWriter();
            out.println("业务处理完毕的时间：" + new Date() + ".");
            out.flush();
            ctx.complete();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```
除此之外，Servlet 3.0 还为异步处理提供了一个监听器，使用 AsyncListener 接口表示。它可以监控如下四种事件：
* 异步线程开始时，调用 AsyncListener 的 onStartAsync(AsyncEvent event) 方法；
* 异步线程出错时，调用 AsyncListener 的 onError(AsyncEvent event) 方法；
* 异步线程执行超时，则调用 AsyncListener 的 onTimeout(AsyncEvent event) 方法；
* 异步执行完毕时，调用 AsyncListener 的 onComplete(AsyncEvent event) 方法；
* 要注册一个 AsyncListener，只需将准备好的 AsyncListener 对象传递给 AsyncContext 对象的 addListener() 方法即可，如下所示：

```
AsyncContext ctx = req.startAsync(); 
ctx.addListener(new AsyncListener() { 
    public void onComplete(AsyncEvent asyncEvent) throws IOException { 
        // 做一些清理工作或者其他
    } 
    ... 
});
```


* 新增的注解支持
> 新增的注解支持：该版本新增了若干注解，用于简化Servlet、过滤器（Filter）和监听器（Listener）的声明，这使得 web.xml 部署描述文件从该版本开始不再是必选的了。

@WebServlet
@WebInitParam
@WebFilter
@WebListener
@MultipartConfig

* 可插性支持
> 使用该特性，现在我们可以在不修改已有 Web 应用的前提下，只需将按照一定格式打成的 JAR 包放到 WEB-INF/lib 目录下，即可实现新功能的扩充，不需要额外的配置

> Servlet 3.0 引入了称之为“Web 模块部署描述符片段”的 web-fragment.xml 部署描述文件，该文件必须存放在 JAR 文件的 META-INF 目录下，该部署描述文件可以包含一切可以在 web.xml 中定义的内容。JAR 包通常放在 WEB-INF/lib 目录下，除此之外，所有该模块使用的资源，包括 class 文件、配置文件等，只需要能够被容器的类加载器链加载的路径上，比如 classes 目录等。

编写一个类继承自 HttpServlet，将该类打成 JAR 包，并且在 JAR 包的 META-INF 目录下放置一个 web-fragment.xml 文件，该文件中声明了相应的 Servlet 配置。web-fragment.xml 文件示例如下：
示例：

```
<?xml version="1.0" encoding="UTF-8"?>
<web-fragment
    xmlns=http://java.sun.com/xml/ns/javaee
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0"
    xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
    http://java.sun.com/xml/ns/javaee/web-fragment_3_0.xsd"
    metadata-complete="true">
    <servlet>
        <servlet-name>fragment</servlet-name>
        <servlet-class>footmark.servlet.FragmentServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>fragment</servlet-name>
        <url-pattern>/fragment</url-pattern>
    </servlet-mapping>
</web-fragment>
```
>从上面的示例可以看出，web-fragment.xml 与 web.xml 除了在头部声明的 XSD 引用不同之外，其主体配置与 web.xml 是完全一致的。
由于一个 Web 应用中可以出现多个 web-fragment.xml 声明文件，加上一个 web.xml 文件，加载顺序问题便成了不得不面对的问题。Servlet 规范的专家组在设计的时候已经考虑到了这个问题，并定义了加载顺序的规则。

* ServletContext性能增强
> 该对象支持在运行时动态部署 Servlet、过滤器、监听器，以及为 Servlet 和过滤器增加 URL 映射等
* HttpServletRequest 对上次文件的支持
> HttpServletRequest 提供了两个方法用于从请求中解析出上传的文件

```
Part getPart(String name)
Collection<Part> getParts()
```
使用：

```
Part photo = request.getPart("photo"); 
photo.write("/tmp/photo.jpg"); 
// 可以将两行代码简化为 
request.getPart("photo").write("/tmp/photo.jpg") 一行。
```
> 需要注意的是，如果请求的 MIME 类型不是 multipart/form-data，则不能使用上面的两个方法，否则将抛异常。



### WEB 3大组件
- [x] Servlet   
- [x] Filter        [翻译：过滤器]
- [x] Listener      [翻译：监听器]

#### 1. 概念
* Servlet ：动态的处理业务请求，完成响应
* Filter ：可复用代码，在Servlet处理请求之前按规则进行拦截，可用来转换Http请求头，修改响应等
* Listener ：监听容器某些动作执行或操作，通俗来说，及session，application，request等对象的创建消亡，键值的添加，删除的监听
    > * 第一类：与servletContext有关的listner接口。包括：ServletContextListener、ServletContextAttributeListener
    > *  第二类：与HttpSession有关的Listner接口。包括：HttpSessionListner、HttpSessionAttributeListener、HttpSessionBindingListener、                      HttpSessionActivationListener；
    > *  第三类：与ServletRequest有关的Listener接口，包括：ServletRequestListner、ServletRequestAttributeListener

#### 2. 生命周期
* Servlet：servlet的生命周期始于它被装入web服务器的内存时，并在web服务器终止或重新装入servlet时结束。servlet一旦被装入web服务器，一般不会从web服务器内存中删除，直至web服务器关闭或重新结束。(单例,extends HttpServlet)
![](http://img.my.csdn.net/uploads/201301/29/1359424209_4366.png)
* Filter：一定要实现javax.servlet包的Filter接口的三个方法init()、doFilter()、destroy()，空实现也行 (启动服务器初始 implements Filter)
* Listener:针对不同监听，继承/实现某些类 生命周期类似Filter

> 特别说明，Filter执行流程，是会 **来回执行** 的 ，如下图
> 特别说明，chain.doFilter() 链式传递
![](http://img.my.csdn.net/uploads/201301/29/1359428942_1310.png)


附录：

* [JavaWeb三大组件（Servlet、Filter、Listener）](http://blog.csdn.net/xiaojie119120/article/details/73274759)

* [servlet/filter/listener区别与联系](http://blog.csdn.net/sundenskyqq/article/details/8549932)

#### 3. Interceptor [翻译：拦截器]
> 功能类似于Filter,如Springmvc中 HandlerInterceptorAdapter

```
public abstract class HandlerInterceptorAdapter implements AsyncHandlerInterceptor {

	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
		throws Exception {
		return true;
	}

	
	@Override
	public void postHandle(
			HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView)
			throws Exception {
	}


	@Override
	public void afterCompletion(
			HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex)
			throws Exception {
	}

	
	@Override
	public void afterConcurrentHandlingStarted(
			HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {
	}

}

```
区别可以见下图
![](http://img.blog.csdn.net/20150323232841282?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY2hlbmxlaXhpbmc=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)