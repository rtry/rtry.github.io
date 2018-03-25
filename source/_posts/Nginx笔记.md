---
title: Nginx 笔记
date: 2016-07-21
categories: 工作与学习
tags: [Nginx]
---

## Nginx 

### 一：安装
> 一般我们都需要先装pcre, zlib，前者为了重写rewrite，后者为了gzip压缩


1.选定源码目录

	cd /usr/local/

2.安装PCRE库
	
	cd /usr/local/
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.21.tar.gz
	tar -zxvf pcre-8.21.tar.gz
	cd pcre-8.21
	./configure
	make
	make install

3.安装zlib库

	cd /usr/local/ 
	wget http://zlib.net/zlib-1.2.8.tar.gz
	tar -zxvf zlib-1.2.8.tar.gz cd zlib-1.2.8
	./configure
	make
	make install

4.安装ssl （或者yum install openssl）

	cd /usr/local/
	wget http://www.openssl.org/source/openssl-1.0.1c.tar.gz
	tar -zxvf openssl-1.0.1c.tar.gz
	./config --prefix=/usr/local/ssl shared zlib-dynamicmake
	make install

5.安装nginx
	
	cd /usr/local/
	wget http://nginx.org/download/nginx-1.2.8.tar.gz
	tar -zxvf nginx-1.2.8.tar.gz
	cd nginx-1.2.8
	./configure --user=nobody --group=nobody --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_gzip_static_module --with-http_realip_module --with-http_sub_module --with-http_ssl_module
	make
	make install

6.启动及命令
	
	/usr/local/nginx/sbin/nginx
	sbin/nginx -s reload|reopen|stop|quit  #重新加载配置|重启|停止|退出 nginx
	sbin/nginx -t   #测试配置是否有语法错误

>  注意
>  
* 正向代理，反向代理
	*	两者的区别在于代理的对象不一样：正向代理代理的对象是客户端，反向代理代理的对象是服务端	[知乎](https://www.zhihu.com/question/24723688)


### 二：功能
1. Http代理，反向代理
2. 负载均衡 
	* 内置策略 
		* 轮询
		* 加权
		* ip hash
	* 扩展策略
		* 天马行空

3. web缓存

		Nginx可以对不同的文件做不同的缓存处理，配置灵活，并且支持FastCGI_Cache，
		主要用于对FastCGI的动态程序进行缓存。配合着第三方的ngx_cache_purge，对制定的URL缓存内容可以的进行增删管理。

### 三：文件结构
		
		...              #全局块
		
		events {         #events块
		   ...
		}
		
		http      #http块
		{
		    ...   #http全局块
		    server        #server块
		    { 
		        ...       #server全局块
		        location [PATTERN]   #location块
		        {
		            ...
		        }
		        location [PATTERN] 
		        {
		            ...
		        }
		    }
		    server
		    {
		      ...
		    }
		    ...     #http全局块
		}

1. 全局块：配置影响nginx全局的指令。一般有运行nginx服务器的用户组，nginx进程pid存放路径，日志存放路径，配置文件引入，允许生成worker process数等

2. events块：配置影响nginx服务器或与用户的网络连接。有每个进程的最大连接数，选取哪种事件驱动模型处理连接请求，是否允许同时接受多个网路连接，开启多个网络连接序列化等

3. http块：可以嵌套多个server，配置代理，缓存，日志定义等绝大多数功能和第三方模块的配置。如文件引入，mime-type定义，日志自定义，是否使用sendfile传输文件，连接超时时间，单连接请求数等

4. server块：配置虚拟主机的相关参数，一个http中可以有多个server块。 

5. location块：配置请求的路由，以及各种页面的处理情况。 一个server可以有多个location块


### 四： Nginx配置示例

########### 每个指令必须有分号结束。#################

		#user administrator administrators;  #配置用户或者组，默认为nobody nobody。
		#worker_processes 2;  #允许生成的进程数，默认为1
		#pid /nginx/pid/nginx.pid;   #指定nginx进程运行文件存放地址
		error_log log/error.log debug;  #制定日志路径，级别。这个设置可以放入全局块，http块，server块，级别以此为：debug|info|notice|warn|error|crit|alert|emerg
		events {
		    accept_mutex on;   #设置网路连接序列化，防止惊群现象发生，默认为on
		    multi_accept on;  #设置一个进程是否同时接受多个网络连接，默认为off
		    #use epoll;      #事件驱动模型，select|poll|kqueue|epoll|resig|/dev/poll|eventport
		    worker_connections  1024;    #最大连接数，默认为512
		}
		http {
		    include       mime.types;   #文件扩展名与文件类型映射表
		    default_type  application/octet-stream; #默认文件类型，默认为text/plain
		    #access_log off; #取消服务日志    
		    log_format myFormat '$remote_addr–$remote_user [$time_local] $request $status $body_bytes_sent $http_referer $http_user_agent $http_x_forwarded_for'; #自定义格式
		    access_log log/access.log myFormat;  #combined为日志格式的默认值
		    sendfile on;   #允许sendfile方式传输文件，默认为off，可以在http块，server块，location块。
		    sendfile_max_chunk 100k;  #每个进程每次调用传输数量不能大于设定的值，默认为0，即不设上限。
		    keepalive_timeout 65;  #连接超时时间，默认为75s，可以在http，server，location块。
		
		    upstream mysvr {   
		      server 127.0.0.1:7878;
		      server 192.168.10.121:3333 backup;  #热备
		    }
		    error_page 404 https://www.baidu.com; #错误页
		    server {
		        keepalive_requests 120; #单连接请求上限次数。
		        listen       4545;   #监听端口
		        server_name  127.0.0.1;   #监听地址       
		        location  ~*^.+$ {       #请求的url过滤，正则匹配，~为区分大小写，~*为不区分大小写。
		           #root path;  #根目录
		           #index vv.txt;  #设置默认页
		           proxy_pass  http://mysvr;  #请求转向mysvr 定义的服务器列表
		           deny 127.0.0.1;  #拒绝的ip
		           allow 172.18.5.54; #允许的ip           
		        } 
		    }
		}


> 注： log_format
> 
> 1. $remote_addr 与$http_x_forwarded_for 用以记录客户端的ip地址； 
> 2. $remote_user ：用来记录客户端用户名称； 
> 3. $time_local ： 用来记录访问时间与时区；
> 4. $request ： 用来记录请求的url与http协议；
> 5. $status ： 用来记录请求状态；成功是200， 
> 6. $body_bytes_sent ：记录发送给客户端文件主体内容大小；
> 7. $http_referer ：用来记录从那个页面链接访问过来的； 
> 8. $http_user_agent ：记录客户端浏览器的相关信息；



* 另：Nginx 设置忽略favicon.ico文件的404错误日志(关闭favicon.ico不存在时记录日志)

	在 server { … }内添加如下信息.

		location = /favicon.ico {
			log_not_found off;
			access_log off;
		}
　

### 五： nginx 支持https

* 利用openssl生成RSA密钥及证书

> 生成一个RSA密钥（felicity.key）
>  
	$ openssl genrsa -des3 -out felicity.key 1024
 
> 拷贝一个不需要输入密码的密钥文件（felicity_nopass.key）
>	
	$ openssl rsa -in felicity.key -out felicity_nopass.key 
 
> 生成一个证书请求（felicity.csr）
> 
	$ openssl req -new -key felicity.key -out felicity.csr
 
> 自己签发证书（felicity.crt）
> 
	$ openssl x509 -req -days 365 -in felicity.csr -signkey felicity.key -out felicity.crt

> 编辑nginx 配置文件 (需要nginx 支持 --with-http_ssl_module) 
> 
	server {
		listen 443;
        server_name  localhsot;
        ssl on;
        ssl_certificate /export/safe/felicity.crt;
        ssl_certificate_key /export/safe/felicity_nopass.key;
	    # 若ssl_certificate_key使用33iq.key，则每次启动Nginx服务器都要求输入key的密码。
    }

> 重启nginx  
> 
	sbin/nginx -s reload

* 另 可申请免费的证书，https://www.startcomca.com/

#### HTTPS基础
* HTTPS 其实是由两个部分组成，HTTP + SSL / TLS，也就是在HTTP上又加了一层处理加密信息的模块。服务端和客户端的信息传输都会通过TLS进行加密，所以传输的数据都是加密后的数据。
* HTTPS是一种基于SSL/TLS的Http协议，所有的http数据都是在SSL/TLS协议封装之上传输的。也属于应用层协议。
* HTTP协议运行在TCP之上，所有传输的内容都是明文，客户端和服务器端都无法验证对方的身份。
* HTTPS是运行在SSL/TLS之上的HTTP协议，SSL/TLS运行在TCP之上。所有传输的内容都经过加密，加密采用对称加密，但对称	加密的密钥用服务器方的证书进行了非对称加密。

![](http://images2015.cnblogs.com/blog/292888/201703/292888-20170316180309010-1175498769.png)
#### HTTPS 认证方式(单/双认证)
![](http://img.blog.csdn.net/20160310160503593) 
![](http://img.blog.csdn.net/20160310160519781)

### 六： API接口设计原理
* 安全第一
	* 身份认证
	* 权限控制
	* 安全传输
* 易用性
	* 学习成本
	* 开发成本
	* 迁移成本
	* 开放成本
* 适用性
	* web页面端
		* js跨域
	* 智能平板

#### 一般常用的设计方式
HTTP + 请求签名
HTTP + 参数加密
HTTPS + 访问令牌