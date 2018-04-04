---
title: Https 相关扩展
date: 2018-04-01
categories: 工作与学习
tags: [Https,证书,非对称加密]
---


### 概念
* HTTPS（HyperText Transfer Protocol over Secure Socket Layer）
* HTTPS 可以理解为HTTP+SSL/TLS， 即 HTTP 下加入 SSL 层，HTTPS 的安全基础是 SSL，因此加密的详细内容就需要 SSL，用于安全的 HTTP 数据传输。
* SSL (Secure Sockets Layer 安全套接层)，及其继承者传输安全层(Transport Layer Secure ,TLS),是为网络通信提供 安全及数据完整性的一种安全协议，TLS与SSL在传输层对网络连接进行加密

### 服务器类
1. Tomcat
2. Nginx
3. IIS
4. Apache
5. ....

### 加密算法
* 对称加密
> 有流式和分组两种，加密与解密都是使用的同一个密钥，常用的有 **DES AES**
* 非对称加密
> 加密与解密使用不同密钥，分别称为公钥，私钥，其中公钥与算法都是公开的，私钥是保密的，非对称加密算法性能较低，但安全性高，当然其加密的数据长度有限，常用有 **RSA DSA ECDSA DH** 等
* Hash算法
> 是一种摘要算法，将任意长度的数据，转换成固定长度的值，一般用于验证数据是否变动，常用的有  **MD5 SHA-1 SHA-2 SHA-256**

### Https 流程

![](http://files.jb51.net/file_images/article/201212/2012121714270132.png)
> 整体可分为8部分，前提需要服务器端准备证书（其实就是公钥与私钥）

1. 客户端发出请求，（输入https://www.domain.com）
2. 服务器端准备证书,当然可以自己制作或者机构申请，区别就是在客户端验证的时候，如果是机构申请的话，可以直接验证通过，而自己制作的则需要手动同意
3. 服务器端向客服端传输证书（其实传递的是证书公钥,当然还包含其他的信息，例如过期时间，机构名称等）  
4. 客服端验证证书，验证不通过（比如时间过期等，机构不合格等）给予用户警告，验证通过，先生成一个随机数g，用接受到的公钥加密生成c，待用
5. 客服端像服务器传输加密值c
6. 服务器端用私钥解密刚才接受c,解密结果为g,使用g作为秘钥，加密需要返回给客服端的数据，
7. 服务器端向客服端传输加密后的响应正文
8. 客服端使用生成的g,解密接受到的密文

> 以上说明是，https的单向认证（及只有服务器端有证书，客服端没有），你完全可以在客户端也生成一个证书，这就是双向认证



### Https 证书制作

#### Java自带工具生成
> 使用java 自带工具keytool 生成证书

```
keytool -genkey -keystore "D:\localhost.keystore" -alias localhost -keyalg RSA
```

#### linux openssl 工具生成

> openssl 是目前最流行的SSL密码工具，其提供一个通用的，健壮，功能完善的工具套件，用以支持SSL/TLS协议实现

> x509证书一般会用到三类文，key，csr，crt。

* key 是私钥，公钥，默认的存储扩展名，通常用RSA算法
* csr 是证书申请文件，用于申请证书，在制作csr文件时，必须使用自己的私钥来签署申请，同时可以设置一个密码
* crt 是CA认证后的证书文，签署人用他自己的key给你签署的凭证

##### 构成部分

* 密码算法库
* 秘钥和证书封装管理功能
* SSL通信API接口

##### 用途

* 建立 RSA, DH, DSA key 参数
* 建立 X.509证书
* 计算消息摘要
* 使用各种加解密
* SSL/TLS  测试

##### 证书生成操作

> 默认情况下， openssl 输出格式为 PKCS#1-PEM 
> 默认情况下，生成的 公钥，私钥，csr, crt 文件存放于  /etc/ssl/certs

* 生成RSA私钥（无加密）
```
openssl genrsa -out rsa_private.key 2048
//rsa_private.key 为私钥文件
```

* 生成RSA 公钥
```
openssl rsa -in rsa_private.key -pubout -out rsa_public.key
//rsa_public.key是与rsa_private.key 配对的共有文件
```

* 生成RSA私钥（使用aes256加密）
```
openssl genrsa -aes256 -passout pass:111111 -out rsa_aes_private.key 2048
```

* 生成RSA公钥
```
openssl rsa -in rsa_aes_private.key -passin pass:111111 -pubout -out rsa_public.key
```

* 生成签名请求（csr）
```
// 非加密的
openssl req -sha256 -new -key rsa_private.key -out server.csr
// or
openssl req -sha256 -new -key rsa_private.key -out server.csr -subj "/C=CN/ST=Jiangsu/L=Yangzhou/O=Your Company Name/OU=wangye.org/CN=wangye.org"

// 自定义
openssl req -new -key rsa_private.key -out server.csr -subj "/C=CN/ST=Jiangsu/L=Yangzhou/O=Your Company Name/OU=localhost/CN=localhost"

openssl req  -sha256 -new -key rsa_private.key -out server.csr -subj "/C=CN/ST=Jiangsu/L=Yangzhou/O=Your Company Name/OU=cms.felicity.com/CN=cms.felicity.com"

// 使用rsa_private.key 私钥来生成签名请求（csr）server.csr
// 这里/C表示国家(Country)，只能是国家字母缩写，如CN、US等；/ST表示州或者省(State/Provice)；/L表示城市或者地区(Locality)；/O表示组织名(Organization Name)；/OU其他显示内容，一般会显示在颁发者这栏。
// 需要注意的是，如果是自签名证书，这里生成的签名请求csr,的C,ST,L,O最好保持一致

// 加密的
openssl req -new -key rsa_private.key -passin pass:111111 -out server.csr -subj "/C=CN/ST=Jiangsu/L=Yangzhou/O=Your Company Name/OU=wangye.org/CN=wangye.org"
```

* 生成crt
> CSR文件(server.csr)必须有CA的签名才可形成证书，可将此文件发送到verisign等地方由它验证，要交一大笔钱，何不自己做CA呢。

* 自签名

1. 如果没有ca.key,ca.crt, /etc/pki/CA/ 文件夹下没有index.txt，serial 文件，需先手动生成
```
//建ca.key 私钥
openssl genrsa -out ca.key 2048
//建ca.crt 证书
openssl req  -sha256 -new -x509 -days 3650 -key ca.key -out ca.crt -subj \
"/C=CN/ST=Jiangsu/L=Yangzhou/O=Your Company Name/OU=Your Root CA"

//建缺少文件
cd /etc/pki/CA/
touch index.txt
echo '01' > serial
```

2. 使用ca.crt根证书，自签名
```
openssl ca -in server.csr -out  server.crt -cert ca.crt -keyfile ca.key 
//签发完成的是以sha1 为签名算法
//or
openssl x509 -req -sha256 -in server.csr  -out server.crt   -signkey rsa_private.key  -CA ca.crt -CAkey ca.key -CAcreateserial  -days 990
//签发完成的是以sha256 为签名算法
```

> 好了，现在目录下有两个服务器需要的SSL证书及相关文件了，分别是server.crt和rsa_private.key，接下来就可以利用它们配置你的服务器软件了。

> 需要注意的是由于是自签名证书，所以客户端需要安装根证书，将刚才第2步创建的根证书ca.crt下载到客户端，然后双击导入，否则会提示不受信任的证书发布商问题。

> 通常情况下私人或者内部用的话，自建证书已经绰绰有余了，但是如果你的产品面向的是大众，那就花点银子去买正规的SSL证书吧，可不能学某售票系统强制要求安装自建的根证书哦。

> CER和CRT其实是一样的，只是一般Linux下面叫CRT多，Windows下面叫CER多

### Https 证书申请

> 略，到各大网站上申请就是


### Https 安装证书到nginx

> nginx 配置，需要将秘钥与服务证书放到指定位置即可
```
 #cms 接口
     server {
        listen 80;
        listen 443 ssl;
        server_name  cms.felicity.com;
        ssl on;
        ssl_certificate /export/safe/cmsSafe/server.crt;
        ssl_certificate_key /export/safe/cmsSafe/rsa_private.key;

        location / {
         proxy_pass http://192.168.253.1:8080;
        }

        location = /favicon.ico {
            log_not_found off;
            access_log off;
        }

    }

```
* IE 游览器只要安装了根证书，就可以解除游览器提示
* Chrome 会校验加密的强弱，（-sha1）会给予提示，更换为-sha256，即可消除提示

### Https 安装证书到Tomcat

> 直接将keystore 文件放入到配置中即可

> 访问 https://localhost:8443 即可

```
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol" SSLEnabled="true"
maxThreads="150" scheme="https" secure="true"
clientAuth="false" sslProtocol="TLS"
keystoreFile="D:\localhost.keystore" keystorePass="123456"/>

```
### 证书类型转换

> 略，使用场景较少