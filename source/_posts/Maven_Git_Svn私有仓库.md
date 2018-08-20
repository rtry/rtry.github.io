---
title: Maven_Git_Svn私有仓库
date: 2018-04-18
categories: 工作与学习
tags: [linux]
---
## Nexus Maven 私有仓库
### 安装
> Nexus Maven 需要jdk1.8的环境

> Sonatype Nexus 提供两种版本Nexus Repository Pro （企业版）/Nexus Repository OSS （社区版）

```
//下载社区版免费
wgete https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.10.0-04-unix.tar.gz
//or在迅雷(有缓存节点)中下载好之后上传到Centos中

//解压
tar -zxvf nexus-3.10.0-04-unix.tar.gz
//解压后两个文件夹nexus-3.10.0-04 ，sonatype-work

//启动
cd nexus-3.10.0-04
# bin: 启动脚本和启动时的配置文件
# data: 数据存储目录
# etc: 配置文件
# lib: Apache Karaf的二进制包
# public: 公共资源
# system: 系统依赖的组件和插件

//启动
bin/nexus start
# start：在后台启动服务，不在界面上打印任何启动或者运行时信息。
# run：启动服务，但是在界面上打印出启动信息以及运行时信息以及日志信息。
# stop：关闭服务
# status：查看nexus运行状态
# restart：重启服务
# force-reload：强制重载一遍配置文件，然后重启服务

//访问
http://localhost:8081 (admin/admin123)


//设置开机启动
从根目录进入/etc/目录，找到rc.local这个文件,编辑rc.local,添加nexus的启动信息，保存退出
/export/nexus-server/nexus-3.10.0-04/bin/nexus start

//如果有防火墙设置，请打开8081端口
```

### 配置
> 配置端口，什么的，略

#### 仓库类型
* hosted    （宿主）：宿主仓库主要用于存放项目部署的构件，或者第三方构件用于下载
* proxy     （代理）：代理仓库就是对远程仓库的一种代理，从远程仓库下载构件或插件，然后缓存到Nexus仓库中
* group     （仓库组）：对我们已经配置完了的仓库的一种组策略


#### Nexus内置的几种仓库说明
* maven-central：策略为Release、代理中央仓库、只会下载和缓存中央仓库中的发布版本构件。
* maven-releases：策略为Release的宿主仓库、用来部署组织内部的发布版本内容。
* maven-snapshots：策略为Snapshot的宿主仓库、用来部署组织内部的快照版本内容。
* maven-public：**该仓库将上述所有策略为Release的仓库聚合并通过一致的地址提供服务。**
* nuget-hosted：用来部署nuget构件的宿主仓库
* nuget.org-proxy：代理nuget远程仓库，下载和缓冲nuget构件。
* nuget-group：**该仓库组将nuget-hosted与nuget.org-proxy仓库聚合并通过一致的地址提供服务。**

配置访问的地址一般为 maven-public 组

> maven-public 为对我们开发中提供的url,点击copy,会出现访问地址
http://192.168.253.104:8081/repository/maven-public

#### 配置一个新的aliyun-proxy仓库
由于阿里的maven仓库比maven central的要快很多，所以我们可以配置一个新的仓库
http://maven.aliyun.com/nexus/content/groups/public 这个是阿里的仓库地址


然后再public组里面讲这个aliyun-proxy仓库加入，排在maven-central之前即可。


配置文件存储Blob Stores 可供仓库上传文件使用

#### 本地setting.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

	<!-- 本地仓库地址 -->
	<localRepository>F:\apache-maven-3.3.9\repository_104</localRepository>
	
	<!-- 服务 -->
	<servers>
		<server>
			<id>releases</id>
			<username>admin</username>
			<password>admin123</password>
		</server>
		<server>
			<id>snapshots</id>
			<username>admin</username>
			<password>admin123</password>
		</server>
	</servers>

	<mirrors>
		<mirror>
			<id>nexus</id>
			<mirrorOf>*</mirrorOf>
			<url>http://192.168.253.104:8081/repository/maven-public/</url>
		</mirror>
	</mirrors>

	<profiles>
		<profile>
			<id>dev</id>
			<repositories>
				<repository>
					<id>Nexus</id>
					<url>http://192.168.253.104:8081/repository/maven-public/</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>true</enabled>
						<updatePolicy>always</updatePolicy>
					</snapshots>
				</repository>
			</repositories>
			<activation>
				<activeByDefault>true</activeByDefault>
				<jdk>1.8</jdk>
			</activation>
			<properties>
				<maven.compiler.source>1.8</maven.compiler.source>
				<maven.compiler.target>1.8</maven.compiler.target>
				<maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
			</properties>
		</profile>
	</profiles>
	<activeProfiles>
		<activeProfile>dev</activeProfile>
	</activeProfiles>

</settings>
 
```

#### 项目中配置
> 一般而言，项目中使用经过以上配置的本地maven,在进行包依赖下载的时候，会自动从192.168.253.104上进行下载，如果104上没有，那么104会从远程仓库中获取，然后供内网下载

* 发布本地项目到私有仓库中
1. distributionManagement 节点中，有两个子节点repository/snapshotRepository 一个是快照仓库，一个是正式仓库，在项目中添加了distributionManagement，项目在调用mvn:deploy 的时候就会更加当前项目的版本（判断项目版本号是否包含-SNAPSHOT）发布到不同的仓库中
2. 两个子仓库的地址来源于私有仓库中，快照，正式地址，id必须跟setting中配置的server一致
3. 如果项目是快照版本，deploy时，会根据时间戳生成jar,不用该版本号
4. 如果项目是releases版本，生成的jar,默认是不允许被覆盖的，所以可通过修改版本号发布

```
<project>

	<!-- 发布项目到私有仓库，供团体其他人使用 -->
	<distributionManagement>
		<repository>
			<id>releases</id>
			<name>Nexus Release Repository</name>
			<url>http://192.168.253.104:8081/repository/maven-releases/</url>
		</repository>
		<snapshotRepository>
			<id>snapshots</id>
			<name>Nexus Snapshot Repository</name>
			<url>http://192.168.253.104:8081/repository/maven-snapshots/</url>
		</snapshotRepository>
	</distributionManagement>
	
</project>
```

* 如果需要发布源码到私有仓库
> 在plugins中，增加两个插件，然后默认的deploy,会同时将源码发布到私有库中
```
<!-- 编译源代码插件 -->
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-compiler-plugin</artifactId>
	<version>3.1</version>
	<configuration>
		<source>1.8</source>
		<target>1.8</target>
		<encoding>${project.build.sourceEncoding}</encoding>
	</configuration>
</plugin>

<!-- 打包源代码插件 -->
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-source-plugin</artifactId>
	<version>2.2.1</version>
	<configuration>
		<attach>true</attach>
	</configuration>
	<executions>
		<execution>
			<phase>compile</phase>
			<goals>
				<goal>jar</goal>
			</goals>
		</execution>
	</executions>
</plugin>
```
## Git 私有仓库安装
