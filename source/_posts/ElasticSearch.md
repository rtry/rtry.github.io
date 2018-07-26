---
title: ElasticSearch
date: 2017-05-07
categories: 工作与学习
tags: [ElasticSearch]
---

# ElasticSearch

> Elasticsearch是一个开源的实时搜索引擎，基于 Apache Lucene ，使用java编写，隐藏Lucene的复杂性，提供一套简单的RESTful API.

> you know ,for search!
## 单机安装
### 基本软件
1. 下载安装包，直接解压，有几个前提
	* 1.x ,2.x --> java 1.7x
	* 5.x	--> java 1.8x
2. 解压后，bin/elasticsearch -d 后台启动
3. 不能直接用root账户启动，所以需要

		useradd esearch  
		#自动增加esearch 用户与用户组
 
		chown -R esearch:esearch  elasticsearch  
		#更改elasticsearch文件夹内部文件的所属用户及组为esearch:esearch

		su esearch
		#由root用户切换到创建的用户 esearch
		
		bin/elasticsearch -d
		#后台启动

4. Centos启动的过程中，可能会出现以下问题

		ERROR: bootstrap checks failed
		[1] max file descriptors [65535] for elasticsearch process likely too low, increase to at least [65536]
		[2] memory locking requested for elasticsearch process but memory is not locked
		[3] max number of threads [1024] for user [jason] likely too low, increase to at least [2048]
		[4] max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]
		[5] system call filters failed to install; check the logs and fix your configuration or disable system call filters at your own risk

	处理方式
		
		> vim /etc/security/limits.conf
		# 末尾加上
		*       soft    noproc  65536
		*       hard    noproc  65536
		*       soft    nofile  65536
		*       hard    nofile  65536
		# 针对 max file descriptors
		# 针对 max number of threads

		>vim  /etc/security/limits.d/90-nproc.conf 
		# 将1024改为2048 
		*          soft    nproc     2048
		# 以上重新登录有效

		> vim /etc/sysctl.conf
		# 末尾加上
		vm.max_map_count=262144          
		# 针对 max virtual memory areas
 		> sysctl -p
 		
		> vim /etc/elasticsearch/elasticsearch.yml
		# 末尾加上
		bootstrap.system_call_filter: false   
		# 针对 system call filters failed to install,

5. 配置 config/elasticsearch.yml 
	* 端口 
	* network.host: 0.0.0.0  外网可访问，同时注意防火墙
	* cluster.name: my-es
 

### 插件安装

1. head插件
	> 可以用来快速查看elasticsearch中的数据概况以及非全量的数据，也支持控件化查询和rest请求，但是体验都不是很好

2. sense 插件
	> 可以方便的执行rest请求，但是中文输入的体验不是很好

3. marvel 插件
	> 可以帮助使用者监控elasticsearch的运行状态，不过这个插件需要license。安装完license后可以安装marvel的agent，agent会收集elasticsearch的运行状态
	
注： sense 与 marvel 会自动集成到kibana中


概念对比
    

```
Relational DB -> Databases -> Tables -> Rows -> Columns
Elasticsearch -> Indices   -> Types  -> Documents -> Fields
```


## 集群安装

...待完善

### ElasticSearch的Java Client类型

* Node  Client

    1.客户端节点本身也是Elasticsearch节点
    
    2.也进入集群，和其他Elasticsearch节点一样
    
    3.升级维护麻烦（词库、配置等等）

* TransportClient (后续开发准备删除)

    1.更加轻量级
    
    2.客户端socket连接到es集群
    
    3.早起版本需要完全一致

* 官网提供的rest api 
    >  分为高级与低级版本，使用http协议代替elastic 协议

* jest客户端
    >  第三方开发的 基于http协议的连接工具

### ELasticSearch 集群状态处理


```
# 查看所有的索引状态，注意是否有red
curl -XGET 192.168.253.104:9200/_cluster/health?pretty=1&level=indices

# 查看那些分片不可用
curl -XGET 192.168.253.104:9200/_cat/shards?pretty=1 | grep  UNASSIGNED
索引名|分片号|p是主分片，r是副本|是否分配
bookmark 0 r UNASSIGNED                             
weather  2 r UNASSIGNED                             
weather  1 r UNASSIGNED 

# yellow表示所有主分片可用，但不是所有副本分片都可用，最常见的情景是单节点时，
#由于es默认是有1个副本，主分片和副本不能在同一个节点上，所以副本就是未分配unassigned

# 手动分配 官方不建议
curl -XPOST '192.168.253.104:9200/_cluster/reroute?pretty' -d '{
    "commands" : [ {
          "allocate" : {
              "index" : "article",
              "shard" : 1,
              "node" : "my-es",
              "allow_primary" : true
          }
        }
    ]
}'
```

> Index Templates 与mapping 的区别在于，前者定义一个模板，后者定义一个具体的映射，如果符合规则，在定义具体的映射的时候，会继承模板中定义的mapping 

 
### ElasticSearch的Suggesters
Elasticsearch里设计了4种类别的Suggester，分别是:
* Term Suggester
* Phrase Suggester
* Completion Suggester
* Context Suggester

```
#插入映射
curl -XPUT 192.168.253.104:9200/blogs/ -d'
{
  "mappings": {
    "tech": {
      "properties": {
        "body": {
          "type": "text"
        }
      }
    }
  }
}
'

#插入数据

curl -XPUT 192.168.253.104:9200/_bulk/?refresh=true -d'
{ "index" : { "_index" : "blogs", "_type" : "tech" } }
{ "body": "Lucene is cool"}
{ "index" : { "_index" : "blogs", "_type" : "tech" } }
{ "body": "Elasticsearch builds on top of lucene"}
{ "index" : { "_index" : "blogs", "_type" : "tech" } }
{ "body": "Elasticsearch rocks"}
{ "index" : { "_index" : "blogs", "_type" : "tech" } }
{ "body": "Elastic is the company behind ELK stack"}
{ "index" : { "_index" : "blogs", "_type" : "tech" } }
{ "body": "elk rocks"}
{ "index" : { "_index" : "blogs", "_type" : "tech" } }
{  "body": "elasticsearch is rock solid"}
'

#测试分词
curl -XGET 192.168.253.104:9200/blogs/_analyze?pretty=1 -d'
Elastic is the company behind ELK s
'

#term分析
curl -XPOST 192.168.253.104:9200/blogs/_search?pretty -d'
{ 
  "suggest": {
    "my-suggestion": {
      "text": "lucne rock",
      "term": {
        "suggest_mode": "missing",
        "field": "body"
      }
    }
  }
}
'

curl -XPOST 192.168.253.104:9200/blogs/_search?pretty -d'
{ 
  "suggest": {
    "my-suggestion": {
      "text": "lucne rock",
      "term": {
        "suggest_mode": "popular",
        "field": "body"
      }
    }
  }
}
'

#Phrase分析
curl -XPOST 192.168.253.104:9200/blogs/_search?pretty -d'
{
  "suggest": {
    "my-suggestion": {
      "text": "elassearch is  solid",
      "phrase": {
        "field": "body",
        "highlight": {
          "pre_tag": "<em>",
          "post_tag": "</em>"
        }
      }
    }
  }
}
'

```

### 分词器

```
 curl -XPOST '192.168.253.104:9200/bookmark/_analyze?pretty=1&analyzer=ik_max_word' -d'
联想召回thinkpads 304笔记本电源线'

curl -XPOST '192.168.253.104:9200/bookmark/_analyze?pretty=1&analyzer=standard' -d'
联想召回thinkpads 304笔记本电源线'

curl -XPOST '192.168.253.104:9200/bookmark/_analyze?pretty=1&analyzer=english' -d'
联想召回thinkpads 304笔记本电源线'

curl -XPOST '192.168.253.104:9200/bookmark/_analyze?pretty=1&analyzer=chinese' -d'
联想召回thinkpads 304笔记本电源线'

```
## Lucene
> a jar for search

### 创建索引
* 创建Directory
* 创建IndexWriter
* 创建Document对象
* 为Document添加Field
* 通过IndexWriter添加文档到索引中
 

