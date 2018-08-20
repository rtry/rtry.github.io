---
title: Spring Boot
date: 2018-02-07
categories: 工作与学习
tags: [spring,java]
---

## STS
> spring 官方提供的一个便于开发spring项目的定制版eclipse 
* 内置了一些常用的插件
* 对spring 的支持与调试良好

#### 目录结构
> 从官网上下载sts 后解压

``` java
--- legal //法律文件
--- pivotal-tc-server-developer-3.2.8.RELEASE  //tc-server 定制版的tomcat
--- sts-3.9.1.RELEASE  //STS 定制版的eclipse
```



## Spring Boot

### 项目优点
* 自动配置：针对很多spring应用中常见的功能，提供自动的配置
* 起步依赖：直接告诉spring boot 需要什么，它能自动依赖
* 命令行界面：写完代码即可，不用额外关心构建与部署
* Actuator: 深入了解运行中的Spring Boot程序

### 入门介绍 
###### 1. POM结构
1. 直接继承

```
<parent>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-parent</artifactId>
	<version>2.0.0.RELEASE</version>
	<relativePath />
</parent>
```

2. dependencyManagement 配置依赖（可实现多继承）
```
<dependencyManagement>
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-parent</artifactId>
			<version>2.0.0.RELEASE</version>
			<type>pom</type>
			<scope>import</scope>
		</dependency>
	</dependencies>
</dependencyManagement>
```
###### 2.启动
> main 方法自动启动
```
@SpringBootApplication
public class App {
	public static void main(String[] args) {
		 SpringApplication.run(App.class, args);

	}
}
```

###### 3. 配置
> 配置可以完全写到application.properties里面，也可以写到自定义的文件里面

1. 直接读取配置
> 属性上声明即可
```
@Value("${pdName}")
```
2. 配置转换成具体的实例
> 需要的地方自动注入即可
```
@Configuration
@ConfigurationProperties(prefix = "user.config")
```
3. 属性之间间接引用，随机数等

```
com.dudu.name="AAA"
com.dudu.want="祝大家鸡年大吉吧"
com.dudu.yearhope=${com.dudu.name}在此${com.dudu.want}


dudu.secret=${random.value}
dudu.number=${random.int}
dudu.bignumber=${random.long}
dudu.uuid=${random.uuid}
dudu.number.less.than.ten=${random.int(10)}
dudu.number.in.range=${random.int[1024,65536]}

```

4. 配置写到其他文件时，需要额外加上
```
@PropertySource("classpath:test.properties")
```

5. SpringBoot中有许多的key是具有默认值的 比如server.port,user.name等，从这点可以看出，配置文件读取
    * 多个地方可配置
    * 配置是有先后的

6. SpringBoot 多环境配置文件名需要满足application-{profile}.properties的格式，其中{profile}对应你的环境标识，比如
```
application-dev.properties：#开发环境
application-prod.properties：#生产环境
```
具体使用哪一个配置，在任何配置地方（vim，cmd,配置文件，等）配置spring.profiles.active=dev/prod即可

7. SpringBoot 的Maven插件

```
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```
> 会将项目打包成一个超级jar,一个可执行的jar ( java -jar xxxxx.jar --spring.profiles.active=dev)
> 打包命令（mvn clean package spring-boot:repackage） 或者在插件中配好

### 启动原理解析

```
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```
* @SpringBootApplication
* SpringApplication.run()

TODO

### Spring Boot 与web开发
> Spring Boot 在web开发的过程中，个人的理解，应该是以微服务的形式存在最佳，那么在打包的选择上，倾向于直接打成一个可执行的jar包，当然不是说不可以打成war包。在Spring Boot的独有的启动方式上我们看出，纯java的启动显然是更加的方便

> 如果是打成war包，（外部运行）需要注意下面几点
* Spring Boot 默认是内嵌Servlet容器的（tomcat）,需要手动移除
* Spring Boot 编译的时候需要 servlet api 等，运行的时候，外部容器中会存在

##### ① 使用thymeleaf作为模板引擎（spring boot 推荐）
###### 引入依赖

```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```
> spring-boot-starter-thymeleaf 是spring 使用thymeleaf作为模板引擎的依赖，会自动依赖（web与基础模块）
> spring boot web 开发，在引入依赖后，默认的内嵌Servlet容器是tomcat,一般而言，可选 jetty,undertow,其中以undertow的性能最为出彩

```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-thymeleaf</artifactId>
	<exclusions>
		<exclusion>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-tomcat</artifactId>
		</exclusion>
	</exclusions>
</dependency>

<!-- 修改SpringBoot 内嵌容器Tomcat变成undertow -->
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-undertow</artifactId>
</dependency>

```
###### Controller
> Spring Boot 关于MVC的一些发现：对@Controller有一个处理，会根据请求头中的 Accept:text/html, 来满足返回，也就是说，如果有些请求有异常，或者没找到，Spring Boot可以返回漂亮的JSON

* 对应静态资源的处理 (/resources下/static) URL上不需要声明/static,会自动在该文件下找
* 对于webjar的处理 
* 联合Spring MVC 对静态资源版本的管理

> Spring Boot Theamleaf所有的View(html) 是放在/resources下面的，在它自己提供的打包工具中，会将所有的资源统一打包处理，实现一个一个jar的web


##### ② 使用jsp作为模板引擎（spring boot 不推荐）
简单的说明下注意事项:
* jsp页码不能像thymeleaf那样，将页面放到resource下，需要放到webapp下面
* 由上引起的问题就是，在打jar包时，webapp的东西是会被忽略的


#### Spring Boot 静态资源，拦截器等
> 关键对象，一个WebMvcConfigurerAdapter 需要继承，实现某些方法

##### ① 静态资源路径的默认与自定义
###### Spring Boot 默认静态资源存放位置 优先级顺序为
* classpath:/META-INF/resources
* classpath:/resources
* classpath:/static
* classpath:/public

```
# 默认值映射配置为 /**
spring.mvc.static-path-pattern=
# 及URL访问 /1.png, 会自动在上面4个路径中搜索1.png
# 可修改 /aa/**
```

###### 扩展自定义资源映射

```
/**
 * 增加 静态资源访问规则
 */
@Override
public void addResourceHandlers(ResourceHandlerRegistry registry) {
	//URL中请求/mystatic/** 的静态资源，会映射到当前项目中 /myst/下
	registry.addResourceHandler("/mystatic/**").addResourceLocations("classpath:/myst/");
	super.addResourceHandlers(registry);
}
```
> 通过上述设置，系统会在默认4个映射路径之后，添加一个新的静态资源映射规则



##### ② 页面跳转简化
> 以前写SpringMVC的时候，如果需要访问一个页面，必须要写Controller类，然后再写一个方法跳转到页面，感觉好麻烦，其实重写WebMvcConfigurerAdapter中的addViewControllers方法即可达到效果了


```
/**
 * 增加简单跳转规则
 */
@Override
public void addViewControllers(ViewControllerRegistry registry) {
	registry.addViewController("/").setViewName("login");
	registry.addViewController("/login").setViewName("login");
	super.addViewControllers(registry);
}
```


##### ③ 自定义拦截器

1. 继承类 ，重写方法
```
public class MyInterceptor implements HandlerInterceptor {

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		HttpSession session = request.getSession();
		Object o = session.getAttribute(ConstantPrefix.SESSION_USER);
		System.out.println("进去拦截器");
		if (o != null)
			return true;
		else{
			response.sendRedirect("/login");
			return false;
		}
	}

	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {
	}

	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex)
			throws Exception {
	}

}
```

2. 添加拦截规则
```
@Override
public void addInterceptors(InterceptorRegistry registry) {
	registry.addInterceptor(new MyInterceptor()).addPathPatterns("/**").excludePathPatterns("/login/**");
	super.addInterceptors(registry);
}
```


#### Spring Boot 日志

![](/uploads/spring boot & sts/sringboot7-2.png)

* Spring Boot 默认提供日志支持，是用的logback 来作为日志的实现的

* Spring Boot 采用默认的统一日志框架 SLF4j作为日志门面

* 在引入 spring-boot-starter 自动引起了依赖（如上图所示）

* 配置文件默认名称如下

    * Logback   ：logback-spring.xml, logback-spring.groovy, logback.xml, logback.groovy
    * Log4j     ：log4j-spring.properties, log4j-spring.xml, log4j.properties, log4j.xml
    * Log4j2    ：log4j2-spring.xml, log4j2.xml
    * JDK (Java Util Logging)：logging.properties

> Spring Boot官方推荐优先使用带有-spring的文件名作为你的日志配置（如使用logback-spring.xml，而不是logback.xml），命名为logback-spring.xml的日志配置文件，spring boot可以为它添加一些spring boot特有的配置项（多环境日志输出）

> 根据不同环境（prod:生产环境，test:测试环境，dev:开发环境）来定义不同的日志输出，在 logback-spring.xml中使用 springProfile 节点来定义，方法如下：

> 文件名称不是logback.xml，想使用spring扩展profile支持，要以logback-spring.xml命名
    
    ```
    <!-- 测试环境+开发环境. 多个使用逗号隔开. -->
    <springProfile name="test,dev">
        <logger name="com.dudu.controller" level="info" />
    </springProfile>
    <!-- 生产环境. -->
    <springProfile name="prod">
        <logger name="com.dudu.controller" level="ERROR" />
    </springProfile>
    ```


* 编码

```
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

// 引入标准，全部依赖于SLF4j，如果需要调整日志实现，不用更好代码
private Logger logger = LoggerFactory.getLogger(BookController.class);
```

###### 使用logback 作为日志实现

```
<?xml version="1.0" encoding="UTF-8"?>
<!-- 是否支持自动扫描 -->
<configuration debug="false" scan="true">
	<!-- 引入默认格式 -->
	<include resource="org/springframework/boot/logging/logback/defaults.xml" />

	<property name="APP_NAME" value="sb" />
	<property name="LOG_HOME" value="/export/logs/${APP_NAME}" />

	<!--Appeder 1： 控制台输出 -->
	<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
			<charset>utf8</charset>
		</encoder>
	</appender>

	<!-- Appender 2.0: 普通日志文件 -->
	<appender name="FILE.INFO"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern>${LOG_HOME}/info.log.%d{yyyy-MM-dd}.log
			</FileNamePattern>
			<MaxHistory>7</MaxHistory>
		</rollingPolicy>
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
		</encoder>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>ERROR</level>
			<onMatch>DENY</onMatch>
			<onMismatch>ACCEPT</onMismatch>
		</filter>
		<triggeringPolicy
			class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
			<MaxFileSize>10MB</MaxFileSize>
		</triggeringPolicy>
	</appender>
	<!-- Appender 2.0: 普通日志文件 -->
	<appender name="FILE.ERROR"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern>${LOG_HOME}/error.log.%d{yyyy-MM-dd}.log
			</FileNamePattern>
			<MaxHistory>14</MaxHistory>
		</rollingPolicy>
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
		</encoder>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>ERROR</level>
			<onMatch>ACCEPT</onMatch>
			<onMismatch>DENY</onMismatch>
		</filter>
		<triggeringPolicy
			class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
			<MaxFileSize>10MB</MaxFileSize>
		</triggeringPolicy>
	</appender>

	<!-- Appender 2.1: 用户INFO日志 -->
	<appender name="FILE.USER.INFO"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern>${LOG_HOME}/user/info.log.%d{yyyy-MM-dd}.log
			</FileNamePattern>
			<MaxHistory>7</MaxHistory>
		</rollingPolicy>
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
		</encoder>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>ERROR</level>
			<onMatch>DENY</onMatch>
			<onMismatch>ACCEPT</onMismatch>
		</filter>
		<triggeringPolicy
			class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
			<MaxFileSize>10MB</MaxFileSize>
		</triggeringPolicy>
	</appender>
	<!-- Appender 2.1: 用户ERROR日志 -->
	<appender name="FILE.USER.ERROR"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern>${LOG_HOME}/user/error.log.%d{yyyy-MM-dd}.log
			</FileNamePattern>
			<MaxHistory>14</MaxHistory>
		</rollingPolicy>
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
		</encoder>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>ERROR</level>
			<onMatch>ACCEPT</onMatch>
			<onMismatch>DENY</onMismatch>
		</filter>
		<triggeringPolicy
			class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
			<MaxFileSize>10MB</MaxFileSize>
		</triggeringPolicy>
	</appender>


	<!-- Appender 2.2: BUSINESS INFO日志 -->
	<appender name="FILE.BUSINESS.INFO"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern>${LOG_HOME}/business/info.log.%d{yyyy-MM-dd}.log
			</FileNamePattern>
			<MaxHistory>7</MaxHistory>
		</rollingPolicy>
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
		</encoder>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>ERROR</level>
			<onMatch>DENY</onMatch>
			<onMismatch>ACCEPT</onMismatch>
		</filter>
		<triggeringPolicy
			class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
			<MaxFileSize>10MB</MaxFileSize>
		</triggeringPolicy>
	</appender>
	<!-- Appender 2.2: BUSINESS INFO日志 -->
	<appender name="FILE.BUSINESS.ERROR"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern>${LOG_HOME}/business/error.log.%d{yyyy-MM-dd}.log
			</FileNamePattern>
			<MaxHistory>14</MaxHistory>
		</rollingPolicy>
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
		</encoder>
		<filter class="ch.qos.logback.classic.filter.LevelFilter">
			<level>ERROR</level>
			<onMatch>ACCEPT</onMatch>
			<onMismatch>DENY</onMismatch>
		</filter>
		<triggeringPolicy
			class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
			<MaxFileSize>10MB</MaxFileSize>
		</triggeringPolicy>
	</appender>

	<!-- Appender 2.3: 线上临时DEBUG日志 -->
	<appender name="FILE.TEMPORARY.DEBUG"
		class="ch.qos.logback.core.rolling.RollingFileAppender">
		<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
			<FileNamePattern>${LOG_HOME}/temporary/all.log.%d{yyyy-MM-dd}.log
			</FileNamePattern>
			<MaxHistory>7</MaxHistory>
		</rollingPolicy>
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
			<pattern>${CONSOLE_LOG_PATTERN}</pattern>
		</encoder>
		<triggeringPolicy
			class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
			<MaxFileSize>10MB</MaxFileSize>
		</triggeringPolicy>
	</appender>


	<!-- 测试环境 -->
	<springProfile name="test,dev">
		<!-- 根：日志输出级别 -->
		<root level="INFO">
			<appender-ref ref="STDOUT" />
		</root>
	</springProfile>

	<!-- 正式环境 -->
	<springProfile name="prod">
		<root level="INFO">
			<appender-ref ref="FILE.INFO" />
			<appender-ref ref="FILE.ERROR" />
		</root>
		<!-- 节点：interceptor -->
		<logger name="interceptor" level="INFO" additivity="false">
			<appender-ref ref="STDOUT" />
		</logger>

		<!-- bus 模块日志 -->
		<logger name="pt.sicau.edu.cn.springboot.start03.bus" level="INFO"
			additivity="false">
			<appender-ref ref="FILE.BUSINESS.INFO" />
			<appender-ref ref="FILE.BUSINESS.ERROR" />
		</logger>

		<!-- use 模块日志 -->
		<logger name="pt.sicau.edu.cn.springboot.start03.user" level="INFO"
			additivity="false">
			<appender-ref ref="FILE.USER.INFO" />
			<appender-ref ref="FILE.USER.ERROR" />
		</logger>
	</springProfile>

</configuration>
```
> **启动时，需要指明运行环境**

###### 使用log4j 作为日志实现
* pom 移除jar，添加jar 
* 调整配置文件（代码不用调整）




