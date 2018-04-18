---
title: Linux
date: 2017-07-03
categories: 工作与学习
tags: [linux]
---

## 些许命令
*	du -h 	/export   
	>	列出/export 文件夹下面 所有文件/文件夹的大小

*	du -hs  /export   
	>	列出/export 这个文件夹的总大小

*	netstart -apn
	>	列出所有进程与端口使用情况

*   kill -9 xx 
	>	强制杀死某进程

*   telnet 110.101.101.101 80
	>	测试远程主机端口是否打开

*   cat /etc/issue     或者 uname -a
	>	查看系统版本

*  yum install  -y lrzsz

		安装 rz sz 工具

*  yum -y install vim*

		安装 vim

*  修改系统path，vim /etc/profile ,然后 source  /etc/profile

		export MAVEN_HOME=/usr/local/apache-maven-3.3.9
		export MONGODB_HOME=/export/mongodb-3.4.4
		export PATH=${MAVEN_HOME}/bin:${PATH}


* ulimit -n 

		系统打开文件描述符的最大值，进行调优时，可修改
		/etc/security/limits.conf

* date 设置时间和日期 /查看系统时间
	
		例如：将系统日期设定成2009年11月3日的命令
		
		命令 ： "date -s 11/03/2009"
		
		将系统时间设定成下午5点55分55秒的命令
		
		命令 ： "date -s 17:55:55"

* win 追踪域名  tracert www.baidu.com


* ll -h  /ll -k

		以合适阅读大小的方式 列表展示文件及文件夹

* vim 中 u 
		表示返回上一步操作

* linux 同步系统时间
```
#命令
//查看时间
date        
//查看硬件时间
hwclock     
//查看是否安装
rpm -qa| grep ntp 
//安装
yum install ntpdate
//同步
ntpdate ntp.api.bz
//将系统时间写入到硬件时间
hwclock -w
```

-----
## Linux Kernel sendfile


现在的web服务器中如nginx中都提供了sendfile来提高性能，Kernel 2.0+的版本提供的一个系统调用

### 传统流程
	read(file, tmp_buf, len);      
    write(socket, tmp_buf, len);  
* 调用read 函数，文件数据被copy到内核缓冲区
* read函数返回，文件数据从内核缓冲区copy到用户缓冲区
* write函数调用，文件从用户缓存区copy到内核与socket相关的缓存区
* 数据从socket缓冲区copy到相关的协议引擎


### 分析说明
1.	系统调用 read() 产生一个上下文切换：从 user mode 切换到 kernel mode，然后 DMA 执行拷贝，把文件数据从硬盘读到一个 kernel buffer 里。
2.	数据从 kernel buffer 拷贝到 user buffer，然后系统调用 read() 返回，这时又产生一个上下文切换：从kernel mode 切换到 user mode。
3.	系统调用 write() 产生一个上下文切换：从 user mode 切换到 kernel mode，然后把步骤2读到 user buffer 的数据拷贝到 kernel buffer（数据第2次拷贝到 kernel buffer），不过这次是个不同的 kernel buffer，这个 buffer 和 socket 相关联。
4.	系统调用 write() 返回，产生一个上下文切换：从 kernel mode 切换到 user mode（第4次切换了），然后 DMA 从 kernel buffer 拷贝数据到协议栈（第4次拷贝了）。

	
> 上面4个步骤有4次上下文切换，有4次拷贝，我们发现如果能减少切换次数和拷贝次数将会有效提升性能。在kernel 2.0+ 版本中，系统调用 sendfile() 就是用来简化上面步骤提升性能的。sendfile() 不但能减少切换次数而且还能减少拷贝次数。


### sendfile 
sendfile系统调用则提供了一种减少以上多次copy，提升文件传输性能的方法。Sendfile系统调用是在2.1版本内核时引进的：

	sendfile(socket, file, len);  

运行流程如下：

1.	sendfile系统调用，文件数据被copy至内核缓冲区
2.	再从内核缓冲区copy至内核中socket相关的缓冲区
3.	最后再socket相关的缓冲区copy到协议引擎

> 相较传统read/write方式，2.1版本内核引进的sendfile已经减少了内核缓冲区到user缓冲区，再由user缓冲区到socket相关 缓冲区的文件copy，而在内核版本2.4之后，文件描述符结果被改变，sendfile实现了更简单的方式，系统调用方式仍然一样，细节与2.1版本的 不同之处在于，当文件数据被复制到内核缓冲区时，不再将所有数据copy到socket相关的缓冲区，而是仅仅将记录数据位置和长度相关的数据保存到 socket相关的缓存，而实际数据将由DMA模块直接发送到协议引擎，再次减少了一次copy操作。


----


## NC (netcat)

### netcat 安装
> 配置可访问的yum源，推荐雅虎163的yum,配置地址 /etc/yum.repos.d/CentOS-Base.repo 将链接服务器地址改到163上

```
[base163]
name=CentOS-$releasever - Base - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#released updates 
[updates]
name=CentOS-$releasever - Updates - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6
```

* yum install -y nc 安装完成


### chat
* nc -lp 9999  		
 
		192.168.253.100 上 以后台形式监听9999端口

* nc 192.168.253.100 9999
	
		然后（两边输入）的内容就可以在各自端上显示

### 文件传输
Server

	nc -lp 20000 < file.txt

Client

	nc -n 192.168.1.1 20000 > file.txt

> 注： 服务器打开监听后，如果有连接上来，那么这个连接断开后，自身监听也会移除


-----


