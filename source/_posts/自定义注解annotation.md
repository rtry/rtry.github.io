---
title: 自定义注解
date: 2016-08-19
categories: 工作与学习
tags: [自定义注解]
---
## 元注解
> 4种元注解（用于声明注解的注解,java 1.5之后提供）

### @Inherited	

@Inherited 元注解是一个标记注解，@Inherited阐述了某个被标注的注解类型是可以被继承的。
> 如果一个使用了@Inherited修饰的annotation类型A被用于一个声明在class上，则这个annotation将被用于该class的子类。换句话说，子类相当拥有这个注解A

### @Documented

@Documented用于描述其它类型的annotation应该被作为被标注的程序成员的公共API，因此可以被例如javadoc此类的工具文档化。Documented是一个标记注解，没有成员。

### @Retention
 
1. RetentionPoicy.SOURCE	:	在源文件中有效（即源文件保留）
2. RetentionPoicy.CLASS	    :	在class文件中有效（即class保留）
3. RetentionPoicy.RUNTIME	:	在运行时有效（即运行时保留）
 
### @Target

1. ElementType.CONSTRUCTOR	:	用于描述构造器
2. ElementType.FIELD	    :	用于描述成员变量
3. ElementType.LOCAL_VARIABLE	:	用于描述局部变量
4. ElementType.METHOD	    :	用于描述方法
5. ElementType.PACKAGE	    :	用于描述包
6. ElementType.PARAMETER	:	用于描述参数
7. ElementType.TYPE	        :	用于描述类、接口(包括注解类型) 或enum声明


## 自定义注解

> java.lang.annotation.Annotation (接口，是所有注解（包括元注解）的父接口)

> 注解是对类有效的，跟具体的实例无关


### 公式

```
public @interface 注解名 {定义体}
```


### 注解参数的可支持数据类型：
1. 所有基本数据类型（int,float,boolean,byte,double,char,long,short)
2. String类型
3. Class类型
4. enum类型
5. Annotation类型
6. 以上所有类型的数组

### Annotation类型里面的参数该怎么设定: 

1. 只能用public或默认(default)这两个访问权修饰.例如 String value();这里把方法设为defaul默认类型；　 　

2. 参数成员只能用基本类型byte,short,char,int,long,float,double,boolean八种基本数据类型和 String,Enum,Class,annotations等数据类型,以及这一些类型的数组.例如,String value();这里的参数成员就为String;　

3. 如果只有一个参数成员,最好把参数名称设为"value",后加小括号


## 注解与反射
> 光是定义注解用处不大，注解是会擦除的，需要对注解进行一些解析，那么如何读取注解，用反射

```
class.getDeclaredFields() //返回Class中所有的字段，包括私有字段；
class.getFields()   // 只返回公共字段，即有public修饰的字段
```
