---
title: docker笔记
date: 2017-10-08
categories: 工作与学习
tags: [docker]
---
## Docker
#### 初认识
> 1. build, ship, and run any app, anywhere
> 2. 镜像，容器，仓库
> 3. 集装箱，标准化，隔离

#### docker架构

![docker架构](http://hainiubl.com/images/2016/architecture.jpg?_=6822905)

### 镜像 images 
- [x] 就是一个只读的模板，可以用来创建容器，可包含多个容器
- [x] 使用 unionfs(Union File System) 来实现文件管理

![images](http://hainiubl.com/images/2016/image_ufs.png?_=6822905)

### 容器 container
- [x] 容器是从镜像中创建的运行实例，每个容器相互隔离

![container](http://hainiubl.com/images/2016/container-ufs.png?_=6822905)


### 仓库 repository
- [x] 仓库（Repository）是集中存放镜像文件的场所



### Centos 6.5 安装Docker

```java
//1. 查看系统内核版本，需升级内核至3.x
uname -r 
2.6.32-431.el6.x86_64

//2.下载yum源，然后升级系统内核
cd /etc/yum.repos.d/
wget http://www.hop5.in/yum/el6/hop5.repo
yum install kernel-ml-aufs kernel-mk-aufs-devel

//3.修改/etc/grub.conf中default=0
vim /etc/grub.conf

//4.重启    
reboot

//5.安装docker
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
yum -y install docker-io

//6.修改/etc/sysconfig/selinux文件，将SELINUX的值设置为disabled。
vim /etc/sysconfig/selinux
service docker start
chkconfig docker on

//7.检查是否安装完成
docker version
reboot
```


### Docker 使用命令
1. docker images
2. docker ps
3. docker pull hello-world
4. docker run -d
5. docker exec -it xxx bash


### 私有镜像搭建