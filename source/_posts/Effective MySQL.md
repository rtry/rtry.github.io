---
title: effective mysql  读书笔记
date: 2017-09-21
categories: 工作与学习
tags: [数据存储,mysql]
---
## 第一章：分析命令
### 查询当前进程
	SHOW FULL PROCESSLIST;

### 添加索引
	ALTER TABLE book ADD INDEX (price);

### 查看建表语句
	SHOW CREATE TABLE book;

### 查看表基础状态
	SHOW TABLE STATUS LIKE 'book';

### 解释执行计划 QPE
	EXPLAIN PARTITIONS SELECT * FROM book   WHERE price = 249742299;

### 查询索引
	SHOW INDEXES FROM book;

### 调整表引擎
	ALTER TABLE book ENGINE = INNODB;
	
### 查看状态
	用户可以从：	informatin_schema.GLOBAL_STATUS
				informatin_schema.SESSION_STATUS 
	查看到相同的数据
	SHOW GLOBAL  STATUS LIKE 'Created_tmp_%tables';
	SHOW SESSION STATUS LIKE 'Created_tmp_%tables';


## 第二章 QPE 各指标详细说明
	执行：explain select bookId from book where bookId =2014 \G
	*************************** 1. row ***************************
	           id: 1
	  select_type: SIMPLE
	        table: book
	         type: const
	possible_keys: PRIMARY
	          key: PRIMARY
	      key_len: 4
	          ref: const
	         rows: 1
	        Extra: Using index


注：

* id: 执行序列
* key：列出优化器选择的索引
* rows : mysql优化器的预估值
* key_len: 列出了用于SQL语句的连接的键的长度，对确认索引的有效性及多列索引中用到的列的数目很有效

		key_leng:4 //int not null
		key_leng:5 //int null
		key_leng:30 //char(30) not null
		key_leng:32 //varchar(30) not null
		key_leng:92 //varchar(30) null charset=utf8
* table: 单独行的唯一标示，可能是表名，表别名，或者查询临时表标识符等
* select_type:列出了各种表示table列应用的使用方式的类型，
常见值: 
	* simple : 不包含子查询及其他负债语句的简单查询
	* primary:为更复杂的查询而创建的首要表（也就是最外层的表），
这个类型可以在 derived 和 union混合使用时见到
	* derived 当一个表不是物理表时
	* union
* extra
	* using where:表示查询使用了where语句来处理结果，
	* using temporary 使用了内部临时表
		* 使用了distinct 或者使用了不同的order by 和group by 列
	* using filesort 这就是order by 语句的结果，cpu密集型的过程
	* using index  强调只需要使用索引就可以满足需求，不需要访问数据
	* using join buffer 强调在获取连接条件时没有使用索引，如果出现这个值，需要更加具体情况改进性能
	* impossible where 强调where语句会导致没有符合条件的行
	* select tabls optimized away 通过使用索引，优化器可能仅从聚合函数结果中返回一行
> 尽管explain命令不会执行SQL语句，但是当执行计划确定时，它会执行from语句中的子查询

## 第三章：深入理解索引
### Mysql 索引各种可能的用途
* 保证数据完整性
	* 主键（每个表只能有一个主键，不能包含null值，通过主键可获取表中任何特定列，如果定义了auto increment 列则必然是主键的一部分）
	* 唯一性（可有多个唯一性，可包含null，但是null值唯一）
* 优化数据访问性能
* 改进表的连接操作（join）
* 对结果进行排序
* 简化聚合数据操作
#### 索引的类型
* 空/normal：一般索引 
* Unique ：唯一索引
* Full Text ：全文索引
> 如果为主键，默认是有索引的
#### 索引方式
* Btree
* hash
###理解各种索引数据结构理论
* B-tree
* B+tree
* 散列
* 通信 R-tree
* 全文本
###各种存储引擎的索引实现方式
* MyISAM 的B-tree
* InnoDB的 B+tree
* InnoDB的 B-tree
* 内存散列索引
* 内存B-tree索引
* InnoDB 内部散列索引
###分区的MySQL索引
* 略


## 第四章：创建索引

### 基本索引类型，包含单列和多列索引
### 单例索引
1.	语法

		alert table <table> 
			add primary key [index-name] (<column>)

		alert table  <table>
			add  [unique/fulltext] index|key [index] (<column>)
	> 创建非主码索引时，key 和index可互换，创建主码时，只能有key
	> 当 QEP显示 type:all key：null,可判断扫描了整张表

		drop index [index-name]

2. 利用索引限制查询读取的行数
	>  一个全表扫描的查询，在建立索引后，读取行数会明细减少
	
3. 使用索引连接表
	> 索引能有效提高关联表操作的性能

4. 理解索引的基数
	> 当一个查询中使用不止一个索引的时候，Mysql会试图找到一个最高效的索引，它通过分析每条索引内部数据分布的统计信息来做到这一点。判断谁拥有更高的基数

5. 使用索引进行模式匹配 like 'Quee%'
	> 如果经常要以通配符开通来查询， 常用的方法是在数据库中保证需要查询的值的反序值
	> 
	> email like reverse('%qq.com') 
	
6. 结果排序
	> 索引可以用来对查询结果进行排序

	> using filesort 表示mysql内部使用了sort_buffe来对结果进行排序
### 多列索引
1. 。。。。


### 添加索引对性能造成的影响
1. DML影响
	> 写性能降低
2. DDL影响
	> alert 语句执行更慢
	
3. 磁盘空间

> 注：
> 
> DML 需要提交的 如 insert，update,delete merge 等
> 
> DDL 是数据定义语言，如 drop alert create truncate
###各种MYSQL索引的限制于不足


## 第五章：创建更好的索引
### 覆盖索引
> 覆盖索引得名于它满足了查询中给定表用到的所有的列，你想包含where，order by ,group by ,select 中的列
> 
> 有很多理由可以说服用户不要使用 select * ，而覆盖索引就是其中之一
> 
> 生产环节中并不理想 
### 局部索引
	-- 计算部分索引平均值
	SELECT COUNT(DISTINCT t.show_sentence)/COUNT(1) from t_user_show t;
	
	-- 找出部分索引最佳长度（得到结果与平均值相近）
	SELECT COUNT(DISTINCT LEFT(t.show_sentence,10) )/COUNT(*) as sel10,
	COUNT(DISTINCT LEFT(t.show_sentence,20) )/COUNT(*) as sel20,
	COUNT(DISTINCT LEFT(t.show_sentence,30) )/COUNT(*) as sel30,
	COUNT(DISTINCT LEFT(t.show_sentence,40) )/COUNT(*) as sel40 from t_user_show t;
	
	平均值  == 得到结果与平均值相近
	
	
	-- 建部分索引语句
	ALTER TABLE t_user_show add key (show_sentence(40));


## 第六章：MYSQL配置选项
### 内存相关的系统变量
1. 全局内存缓冲区
					
		key_buffer_size	： 定义MyISAM索引码缓冲区的大小，通常叫做码缓存
		innodb_buffer_pool_size ：定义InnoDB缓冲池的大小
		innodb_additionnal_mem_pool_size	：数据字典及内部数据结构缓冲区大小
		quey_cache_size	: 查询缓存大小

2. 全局/会话内存缓冲区

		max_heap_table_size	: 定义一个memory存储引擎表的最大容量
		tmp_table_size	: 内存临时表最大容器，与max_heap_table_szie 密切相关

3. 会话缓冲区

		join_buffer_size	: 定义当索引无法满足连接时，在两个表之间做全表连接操作时，能够使用的内存缓冲区的大小
		sort_buffer_size	: 定义当索引无法满足排序时，对结果进行排序使用的内存缓冲区的大小
		read_buffer_size	: 定义连续数据扫描时，能够使用的内存缓冲区大小
		read_md_buffer_size	: 定义了有序数据扫描时，能够使用的内存缓冲区大小

### 日志和工具系统变量
1. 基础工具的变量
		
		show_query_log	： 布尔值，确定是否记录执行缓慢的查询
		slow_query_log_file	： 慢查询日志输入文件
		long_query_time	： 慢查询定义时间
		general_log	：布尔值，确认是否需要记录所有查询
		general_log_file	： 查询日志输出文件
		log_output	: 定义慢查询和全查询日志的类型
		profiling	: 定义了分析每个线程的语句

### 查询相关的系统变量

		optmizer_switch	: 决定优化器中那个高级索引合并功能被启用
		default_storage_engine	: 默认存储引擎
		max_allowed_packet	： 定义结果集最大容量
		sql_mode	: SQL模式
		innodb_strict_mode	： innoDB的SQL级别


## 第七章：SQL的生命周期
### 截取SQL语句
1. 全面查询日志
2. 慢查询日志
3. 二进制日志
4. 进程列表 -- 通过State的值为Locked判断
5. 引擎状态
6. mysql 连接器
7. 应用程序代码
8. infomation_schema
9. performance_schema
10. SQL 语句统计插件
11. Mysql 代理
12. TCP/IP 
		
		sudo tcpdump -l -i eth0 -w -src or dst port 3306 -c 1000 | strings
		
### 识别并分类有问题的SQL语句
1. 最慢的SQL，执行频率高的SQL
### 确认SQL语句的当前操作
### 分析SQL语句和辅助信息
### 优化SQL
### 验证SQL优化效果


## 第八章：MYSQL优化小技巧

### 整合DDL语句
> alert 语句是阻塞的，所以可以把多个alert合并到一个
### 去除重复索引
重复索引主要有两个影响
	1. 所有的DML会很忙，因为需要做更多的工作来保证索引的一致性
	2. 磁盘占用更大
> 可以从 索引列表中判断，一般为 多列索引 与单列索引之间的重复
### 找到没有被使用的或者无效的索引
> 无用索引一般可以冲QEP 中key_len来辅助判断
### 改进索引
1. 数据类型
	* bigint 和 int
	> 一般 一个主码 被定义为 bigint auto_increment 时，可以变革为 int unsigned auto_increment  原因是 从8字节减少到4字节，可以显著的提高索引的存储空间
	
	* datetime 和 timestamp
	> 同样的原因，由8字节变成了4字节
		
	* enum 如果是静态的代码值，如性别
	> gender enum('Male,'Female') not null default 'Male'
	> 
	> 有3个优点
	> 
	> 1. 隐式检查数据完整性
	> 2. 存储空间为1字节，来存储255个状态
	> 3. 更可读，索引更紧凑
	>
	> 注: 但实际的开发过程中，枚举类型的查询操作，是需要加''的，映射成java类，必然是String,操作上不是很方便
	> 。所以通常情况下，使用 tinyint 来代替它，占用1个字节 

	
	* NUll与not null
	> 最好把一列定义 为 not null 
	
	* 连表的隐含转换
	> 当你为表连接选择一个索引时，一定要确保这个数据类型是相同的对于 整数类型，要确保 signed 与 unsigned 统一
	
	* IP地址
	> 可以将ipv4地址定义为 int unsigned 类型占用4个字节，而定义为varchar(15)	则要占用12个，效果明显
	> 
	> inet_aton() 与 inet_ntoa（) 可以方便的在ip与字符串之间转换
	
	* MD5
	> 用char(32) 来存储MD5 是一种常见的技巧,适用于定长逻辑
	> 
	> md5() unhex() hex() length() 函数 
	> 
	
	
### 减少SQL语句
1. N+1 问题 合并 为 In 
### 简化SQL语句
1. 改进列
2. 改进连接
3. 重写子查询
4. 理解试图带来的影响 --> 优化视图查询，必须优化到视图对应的表
### 缓存选项

1. 当普通数据的变化率相对较低时，缓存SQL结果，能为你带来性能提升
但是对写操作大于读操作的系统会造成性能退化
2. 可适用应用程序缓存


### 应尽量避免在查询条件where中使用 where name is null ,会使得优化器放弃索引，而使用全表扫描，可使用默认值为0


## 附：
* mysql 中的utf-8 与utf-8mb4的区别
> mysql 在5.5.3之后新增的 utf-8mb4编码，为utf-8的超集，如无特殊存储要求（如 emoji表情），用utf-8就够了
> 
> 
> 

MySQL 整型存储范围与占用字节
![](http://img.blog.csdn.net/20151223141453904)
 

> JAVA中整型存储范围与占用字节
> 
> * byte的取值范围为-128~127，占用1个字节（-2的7次方到2的7次方-1） 
> * short的取值范围为-32768~32767，占用2个字节（-2的15次方到2的15次方-1） 
> * int的取值范围为（-2147483648~2147483647），占用4个字节（-2的31次方到2的31次方-1） 
> * long的取值范围为（-9223372036854774808~9223372036854774807），占用8个字节（-2的63次方到2的63次方-1）