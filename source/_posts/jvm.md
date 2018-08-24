---
title: JVM虚拟机笔记
date: 2018-08-10
categories: 工作与学习
tags: [jvm]
---

## Java概述
### java技术体系
> SUN 官方定义的JAVA技术体系包含：
* java 程序语言设计
* java vm (各硬件平台)
* class 文件格式
* 第3方类库（商业机构/开源社区）

> 通常把 java程序设计语言，java虚拟机，java API统称为JDK

> 把 javaSE API 子集 和java虚拟机 统称为JRE

### java 发展史重大事件

* 1991年4月，James Gosling 团队开始设计 Oak,为java前身
* 1995年5月23日，Oak改名为java，提出 “一次编写，随处运行”
* 1996年1月23日，JDK 1.0版本发布（基于SUN Classic VM）
* 1996年5月，首届Java One 大会在旧金山召开
* 1998年12月4日,发布一个里程碑版本JDK 1.2 
* 1999年4月27日，发布HotsSpot 虚拟机(收购而来)
* 2006年11月13日，SUN宣布开源，随后建立OpenJDK 
* 2009年04月20日，Oracle收购SUN,Oracle 拥有两大虚拟机技术，JRockit,HotSpot

> Oracle JDK里面包含的JVM是HotSpot VM，HotSpot VM只有非常非常少量的功能没有在OpenJDK里，那部分在Oracle内部的代码库里。这些私有部分都不涉及JVM的核心功能。所以说，Oracle/Sun JDK与OpenJDK其实使用的是同一个代码库。
![](/uploads/jvm/3ad66b5c-2587-3cc6-b23e-bfa0d2b7da30.png)

### 虚拟机介绍

* JDK 1.0 对应的 SUN Classic VM 与Exact VM 
* 1997年收购LongView Technoloiges 或得HotSpot VM 
* SUN 其他的 其他的 如 KVM ; CDC/CLDC ; Squawk 等
* 其他公司的，如 BEA 的 JRockit VM ,IBM 的 J9 VM
* 特定平台的VM， Azul System 公司的 Azul VM，BEA 的liquid VM
* apache harmony /google android dalvik vm /microsoft jvm

###  待实现功能
* 多模块
* 混合语言（jython Groovy JRuby 等）
* 多核并行
* 64位更高性能

### 特别说明
![](/uploads/jvm/c8ea15ce36d3d539811b19e83a87e950352ab0f2.jpg)

> 首先，不是所有JVM都采用编译器和解释器并存的架构，但主流商用虚拟机，都同时包含这两部分。

> JIT编译器，英文写作Just-In-Time Compiler，中文意思是即时编译器。

> JIT并不是JVM的必须部分，JVM规范并没有规定JIT必须存在，更没有限定和指导JIT。但是，JIT性能的好坏、代码优化程度的高低却是衡量一款JVM是否优秀的最关键指标之一，也是虚拟机中最核心且最能体现虚拟机技术水平的部分。

> 解释器 Interpreter解释执行class文件，好像JavaScript执行引擎一样

> HotSpot虚拟机内置了两个即时编译器，分别称为Client Compiler和Server Compiler，习惯上将前者称为C1，后者称为C2



###  案例：编译JDK(Open JDK)

- [x] jvm 是C++写的。 
- [x] java的编译器是java写的。

> 因此要编译java代码 就需要一个可用的jdk 环境，官方称为 Bootstrap JDK 

> 内存大概准备1G，硬盘准备5G 


1. 编译Open JDK，首先获取源代码
    1. mercurial 获取Repository 地址
    2. 下载源码包 [地址](http://jdk.java.net/java-se-ri/8)
    3. 源码结构
    ```
    THIRD_PARTY_README  
    README-builds.html  
    README              
    Makefile            
    LICENSE             
    ASSEMBLY_EXCEPTION  
    get_source.sh       
    configure           
    common/             
    test/               
    make/               
    corba/              #source code for the OpenJDK Corba functionality
    hotspot/            #source code and make files for building the OpenJDK Hotspot Virtual Machine
    jaxp/               #source code for the OpenJDK JAXP functionality
    jaxws/              #source code for the OpenJDK JAX-WS functionality
    jdk/                #source code and make files for building the OpenJDK runtime libraries and misc files
    langtools/          #source code for the OpenJDK javac and language tools
    nashorn/            #source code for the OpenJDK JavaScript implementation
    
    ```

2. 环境配置

* configure需要执行权限

    ```
    chmod +x openjdk/ -R
    ```

* 启动需要bootstrap jdk ,要低于编译目标的版本，所有安装jdk 1.7
    > su -c "yum install java-1.7.0-openjdk" The java-1.7.0-openjdk package contains just the Java Runtime Environment. If you want to develop Java programs then install the java-1.7.0-openjdk-devel package.

* ./configure 查看依赖是否完全安装 

    ```
    yum install g++
    yum install gcc-c++
    yum install libXtst-devel libXt-devel libXrender-devel
    yum install cups-devel
    yum install freetype-devel
    yum install alsa-lib-devel
    ```

* make all 完成安装

    ```
    cd build/linux-x86_64-normal-server-release/ 
    ./java -version
    ./javac
    ```
* 编译完成后，将机器上的jdk 替换为编译后的jdk

    ```
    rpm -e 所有jdk包
    #/etc/profile
    export JAVA_HOME=/export/openjdk/build/linux-x86_64-normal-server-release/jdk
    export CLASSPATH=.:$JAVA_HOME/lib
    export PATH=$JAVA_HOME/bin:$PATH
    source /etc/profile
    ```




## 自动内存管理机制

### 运行时数据区域
> Java 虚拟机在执行java程序时，会把他所管理的内存划分为若果不同的区域

![](/uploads/jvm/919151-20160709211942186-561340585.png)

* 程序计数器

> 线程私有，字节码解释器工作时就是通过改变这个计数器的值来取下一条需要执行的字节码。分支,循环，跳转，异常处理，线程恢复都是依赖这个，在虚拟机规范中没有规定任何Outofmemoryerror

* java (虚拟机)栈(Stack)

> 线程私有，生命周期与线程同步，每个方法执行时，都会创建一个栈帧（Stack-Frame）,
用于存储局部变量表，操作数栈，动态链接，方法出口等，每一个方法从调用到执行完成的过程就是一个栈帧在虚拟机中入栈到出栈的过程

    1. 如果线程请求的栈深度大于虚拟机所允许的深度，将抛出StrackOverFlowError,现在大部分虚拟机允许动态扩展
    2. 如果扩展时，得不到足够的内存，会抛出OutOfMemoryError 

* 本地方法栈(Stack)

> 同Java虚拟机栈类似，只不过这是为Native方法服务的，有的虚拟机会将Java 虚拟机栈与本地方法栈合二为一
    
* java堆（Heap）

> 线程共享区域，同时可以分配出多个线程私有化的分配缓冲区。是Java虚拟机管理的内存中最大的一块区域，在虚拟机启动时创建，此内存区域的唯一目的就是存放实例(随着技术成熟,如栈上分配，标量替换优化技术，所有对象都分配在堆上也不那么绝对)

> java堆是垃圾收集器管理的主要区域，称为GC堆，（可记忆为 垃圾堆，垃圾回收堆内存）

> 堆可细分为
    * 新生代
    * 老年代

> 新生代再细分为
    * Eden空间
    * From Survivor 空间
    * To Surivivor 空间

![](/uploads/jvm/1018541-20170308200940484-1226739905.jpg)

* 有关新生代的JVM参数

    * -XX:NewSize和-XX:MaxNewSize

    用于设置年轻代的大小，建议设为整个堆大小的1/3或者1/4,两个值设为一样大。

    * -XX:SurvivorRatio

    用于设置Eden和其中一个Survivor的比值，这个值也比较重要。

    * -XX:+PrintTenuringDistribution

    这个参数用于显示每次Minor GC时Survivor区中各个年龄段的对象的大小。

    * -XX:InitialTenuringThreshol和-XX:MaxTenuringThreshold

    用于设置晋升到老年代的对象年龄的最小值和最大值，每个对象在坚持过一次Minor GC之后，年龄就加1。


> 'java 虚拟机规范' 中，Java堆 可以在物理机上不连续的内存空间，在实现时，既可以固定大小，也可以扩展，当前主流的虚拟机都是按照可扩展实现的（通过 -Xmx 和-Xms控制）。 如果堆内存无法完成实例分配，并且无法扩展，抛出OutOfMemoryError

* 方法区

> 线程共享，用于存储类信息，常量，静态变量，及时编译后的代码，很多人称为永久代 （-XX:MaxPermSize 设计上限）

> 运算时常量池，是方法区的一部分，存放生成的各种字面量

> 另：“直接内存” 并不是虚拟机运算时数据区的一部分，也不是java虚拟机规范的定义区域，在JDK 1.4 新加入的NIO，引入了基于通道（Chanel）与缓冲区（Buffer） 它可以直接使用Native 函数库直接分配**堆外内存**，然后通过一个存储在Java堆中DirectByteBuffer对象作为这块内存的引用进行操作，避免了Java堆和Native堆来回复制数据的，它的大小**不受Java堆大小的限制**

### HotSpot 虚拟机对象探秘

* 创建
    1. 如果常量池中没有定位到这个类的符号使用,需要先执行类加载
    2. 然后分配内存（一种为指针碰撞，一种为空闲列表）,再后进行初始化为零
    3. 对对象进行必要的设置，class 信息，哈希码，GC年代分布，这些信息存放到对象的对象头当中，
    4. 执行程序定义的初始化逻辑

* 布局
    1. 对象头（Header）
    2. 实例数据（Instance Date）
    3. 对齐填充(Padding)

* 访问定位
    1. 句柄访问
    
    ![](/uploads/jvm/6631371230911268170.png)

    2. 指针访问
    
    ![](/uploads/jvm/6631240389027564366.png)

### 案例1：对象分配及回收时GC日志

> -XX:+HeapDumpOnOutOfMemoryError  (当出现OOM时，保存堆转存文件)

> -XX:HeapDumpPath=/opt/imhistory/heapdump.hprof (可以指定生成的堆转存文件)

> -XX:+PrintGCDetails  打印GC 详细日志

> -verbose:class (打印加载的类信息)

> -Xms20m -Xmx20m 

> -Xss128k

> -XX:PermSize=10M -XX:MaxPermSize=10M (方法区/永久代，需要JVM支持 1.6以下版本都支持)

> -XX:MetaspaceSize=10M -XX:MaxMetaspaceSize=10M  (元空间，要JVM支持，1.7以上)

> -XX:+PrintGCDateStamps 输出GC的时间戳（以日期的形式，如 2013-05-04T21:53:59.234+0800）

> -Xloggc:../logs/gc.log 日志文件的输出路径


### 案例2：OOM 情况
> OOM (outofmemoryerror 内存溢出) 注意: 内存泄漏（内存无法被回收）/ 内存溢出（对象太多，撑爆了）

* java堆(heap)内存溢出 -Xms20m -Xmx20m -XX:+HeapDumpOnOutOfMemoryError  (-Xms20m -Xmx20m 堆内存的最大值与最小值设置为20M)
    

* 虚拟机栈和本地方法栈(stack)内存溢出  -Xss128k (将栈的内存容量设置为128k)

* 方法区(PermGen)内存溢出 -XX:PermSize=10M -XX:MaxPermSize=10M  (将显著方法去的大小)
    > 运行时常量,必须要在jre <=1.6（运行时常量存放永久代）的情况
    

* 本地直接溢出 

* 关于永久代（Permanent Generation ）的替代者：元空间（Metaspace）的信息

    * java8的时候去除PermGen，将其中的方法区移到non-heap中的Metaspace
    * Metaspace与PermGen之间最大的区别在于：Metaspace并不在虚拟机中，而是使用本地内存。
    * -XX:MetaspaceSize，初始空间大小，达到该值就会触发垃圾收集进行类型卸载，同时GC会对该值进行调整：如果释放了大量的空间，就适当降低该值；如果释放了很少的空间，那么在不超过MaxMetaspaceSize时，适当提高该值
    * -XX:MaxMetaspaceSize，最大空间，默认是没有限制的。
    * 将常量池从PermGen剥离到heap中，将元数据从PermGen剥离到Metaspace



## 垃圾收集器与内存分配策略

### 判断死亡

* 引用计数算法
    > 定义：定义一个计数器，在引用成功时+1，失败时-1，任何时候 计数器为0的时候，表示对象不能再使用

    > 效率很高的算法，但是主流的java虚拟机却没有使用，因为这种算法不能处理之间相互引用

* 可达性分析算法

    > 通过一系列 “GC Roots” 做为起始点，从这些节点往下搜索，搜索所走过的路径叫 引用链，当一个对象到GC Roots没有任何引用链，则该对象不可用

    > 可作为GC Roots 的对象包括：
        1. 虚拟机栈中引用的对象
        2. 本地方法栈中JNI引用的对象
        3. 方法区中静态属性引用的对象
        4. 方法区中常量的引用对象

* 引用级别
    > JDK 1.2之后，引用进行了扩充，分为
    1. 强引用
        > Object obj = new Object();
    2. 软引用
        > SoftReference来实现
    3. 弱引用
        > WeakReference来实现    
    4. 虚引用
        > PhantomReference 来实现

* 回收方法区
    > 永久代的垃圾收集主要收集废弃常量，与无用的类，判断一个废弃常量相对容易，判断一个无用的类需满足
    1. 该类所有的实例都已回收，
    2. 加载该类的ClassLoader 已经回收
    3. 该类对应的java.lang.Class 对象没有被任何地方引用

    > 在大量拥有反射，动态代理，CGLib 等byteCode框架时，都需要虚拟机具备类卸载功能，以保障永久代不会被溢出

### 垃圾收集算法
* 标记-清除算法 （mark-sweep）

> 缺点，1.标记，清除效率太低，2.清除后产生大量不连续的内存碎片，而碎片过多，导致后面如果要分配大的对象，无法找到足够的连续内存，而不得不再次触发回收

* 复制算法 (copying)

> 将内存分为两等分，当其中一块用完后，将该块还存活的对象复制到另一块。缺点就是内存只有1半

> 现在主流的虚拟机都是使用这种算法，将内存分为Eden空间与Suvior空间（2块），比例为 8：1：1，每次使用Eden,和Suvior的一块，当用完后，将这两块复制到另一个Suvior上，保证了内存的90%使用

* 标记-整理算法 （mark-compact）

> 同标记清除类似，只是最后将所有存活对象向前移动

* 分代收集算法
 
### 垃圾回收实现(HotSpot 实现)

> 要实现垃圾回收，第一个问题是要判断 对象是否已经死亡，判断依据前文已经说明，可使用可达性分析，但是可达性分析的 GC Roots 节点 在大的应用程序中，是很多的（现在很多程序光方法区就数百M）另外还有一个文件，就是执行GC时，程序必然要出现一个现象，叫stop the word ,而且**无法避免**
> hotspot 采用 OopMap的数据结构来确定哪些被引用，不用通篇扫描GC Roots ，在OopMap的协助下，在SafePoint时执行GC，


### 垃圾收集器详解

![](/uploads/jvm/20180509131928506189.png)

* serial 收集器 (串行GC)

> serial收集器是一个新生代收集器，单线程执行，使用复制算法。它在进行垃圾收集时，它不仅只会使用一个CPU或者一条收集线程去完成垃圾收集作，而且必须暂停其他所有的工作线程(用户线程),直到它收集完成。

> 是Jvm client模式下默认的新生代收集器。对于限定单个CPU的环境来说，简单高效，serial收集器由于没有线程交互的开销，专心做垃圾收集自然可以获得最高的单线程收集效率，因此是运行在Client模式下的虚拟机的不错选择（比如桌面应用场景）。

* parnew 收集器 (并行GC)

> parNew收集器其实就是serial收集器的多线程版本，使用复制算法。除了使用多条线程进行垃圾收集之外，其余行为与serial收集器一样。

> 是运行在Service模式下虚拟机中首选的新生代收集器，其中一个与性能无关的原因就是除了serial收集器外，目前只有parNew收集器能与CMS收集器配合工作。

> preNew收集器在单CPU环境中绝对没有serial的效果好，由于存在线程交互的开销，该收集器在超线程技术实现的双CPU中都不能一定超过Serial收集器。默认开启的垃圾收集器线程数就是CPU数量，可通过-XX：parallelGCThreads参数来限制收集器线程数


* parallel scavenge 收集器

> parallel Scavenge收集器也是一个新生代收集器，它也是使用复制算法的收集器，又是并行多线程收集器。parallel Scavenge收集器的特点是它的关注点与其他收集器不同，CMS等收集器的关注点是尽可能地缩短垃圾收集时用户线程的停顿时间，而parallel Scavenge收集器的目标则是达到一个可控制的吞吐量。吞吐量= 程序运行时间/(程序运行时间 + 垃圾收集时间)，虚拟机总共运行了100分钟。其中垃圾收集花掉1分钟，那吞吐量就是99%。

> 短停顿时间适合和用户交互的程序，体验好。高吞吐量适合高效利用CPU，主要用于后台运算不需要太多交互。


* serial old 收集器

> Serial Old是Serial收集器的老年代版本，它同样是一个单线程收集器，使用标记整理算法。这个收集器的主要意义也是在于给Client模式下的虚拟机使用

* parallel old 收集器

> parallel Old 是parallel Scavenge收集器的老年代版本，使用多线程和“标记-整理”算法。这个收集器在1.6中才开始提供。

* cms 收集器

> CMS(Concurrent Mark Sweep)收集器是一种以获取最短回收停顿时间为目标的收集器。目前很大一部分的Java应用集中在互联网站或者B/S系统的服务端上，这类应用尤其重视服务器的响应速度，希望系统停顿时间最短，以给用户带来较好的体验。CMS收集器就非常符合这类应用的需求

> CMS收集器主要优点：并发收集，低停顿。

> CMS 缺点：
    1. CMS收集器对CPU资源非常敏感。CPU个数少于4个时，CMS对于用户程序的影响就可能变得很大
    2. CMS收集器无法处理浮动垃圾
    3. CMS是基于“标记-清除”算法实现的收集器，手机结束时会有大量空间碎片产生。空间碎片过多，可能会出现老年代还有很大空间剩余，但是无法找到足够大的连续空间来分配当前对象，不得不提前出发FullGC

* g1 收集器

> G1优势
    1. 并行与并发
    2. 分代收集
    3. 空间整理
    4. 可预测停顿   

> 使用G1收集器时，Java堆的内存布局是整个规划为多个大小相等的独立区域（Region）,虽然还保留有新生代和老年代的概念，但新生代和老年代不再是物理隔离的了，它们都是一部分Region的集合。

### 内存分配与回收策略
> java 提倡的自动内存管理，可归纳为给对象分配内存，回收分配给对象的内存。

* 对象优先在Eden分配

> 大多数情况下，对象在新生代Eden区中分配，当Eden区没有足够的空间时，虚拟机就会触发一次Minor GC

> 虚拟机提供了 -XX:+PrintGCDetails 这个收集器日志参数

> 新生代GC（Minor GC） 指发生在新生代的垃圾收集动作，频率较高，速度快

> 老年代GC（Major GC /Full GC）指发生在老生代的垃圾收集动作，速度慢

* 大对象直接进入老年代

> 大对象指需要大量连续空间的Java对象，最典型的就是很长的字符串，及数组。

> -XX:+PretenureSizeThreshold参数，另大于这个值的对象直接分配到老年代中，目的避免在Eden区及两个Survivor区之间发生大量复制

* 长期存活对象将进入老年代

> 虚拟机为每个对象定义了一个年龄Age计数器

* 动态对象年龄判断

* 空间分配担保

### 案例：远程服务器连接 Java VisualVM
1. VisualVM 的插件地址已经更改
    > 根据版本选择 https://visualvm.github.io/pluginscenters.html

    > 安装visual GC 插件

2. 一种方式是开启jstatd服务（如果命令不能直接执行，请到jdk的bin下手动执行）
    
    *  bin 目录下创建 jstatd.all.policy，然后赋权
    ```
    grant codebase "file:/usr/java/jdk1.7.0_79/lib/tools.jar" {
         permission java.security.AllPermission;
    };
    
    ```

    *  执行（前端执行，最好不要后端执行，不用了就退出来，切记将端口也关闭，安全第一）
    ```
    ./jstatd -J-Djava.security.policy=jstatd.all.policy -J-Djava.rmi.server.logCalls=true -J-Dja.rmi.server.hostname=192.168.253.100 -p 3344
    ```
    *  开临时端口（3344为指定，但其实jstatd是开启了两个端口，如果是开启防火墙的情况，需查明另一个随机端口）
    ```
    #查
    netstat -apn | grep jstatd
    #临时加
    iptables -I INPUT -p tcp --dport 3344 -j ACCEPT
    # 查看加成没
    iptables -L -n
    ```
    * 在结束调试时，请关闭端口
    ```
    #简单重启
    service iptables restart
    ```

3. 一种方式是开启jmx(在启动环境中加入)

    > 如tomcat  vim bin/catalina.sh
    
    ```
    # 开启JMX
    JAVA_OPTS='-Dcom.sun.management.jmxremote.port=8999 -Dcom.sun.management.jmxremote.rmi.port=8999 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=192.168.253.100'  
    # 然后再启动服务就可
    # 缺点在于需要改动启动的服务
    ```


## 虚拟机性能监视与故障处理工具

### JDK命令行工具
> 所有命令都是在jdk bin下，请确认是否加入环境变量中

* jps:java进程查看，比ps更好用(数字为pid)
    ```
    [root@localhost bin]# ./jps 
    2373 Bootstrap
    6048 Jps
    ```

* jstat:虚拟机统计工具

* jinfo：java配置信息工具
    > 它能通过-flag选项动态修改指定的Java进程中的某些JVM flag的值,虽然这样的flag数量有限
    * 可先通过jps 查看到进程ID
    
    ```
    # 查看那些可以动态修改
    java -XX:+PrintFlagsFinal -version|grep manageable 
    # 查看当前有哪些进程
    jps
    # 动态修改参数
    jinfo -flag +PrintGCDetails 12278
    jinfo -flag +PrintGC 12278
    # 关闭动态参数
    jinfo -flag -PrintGCDetails 12278
    jinfo -flag -PrintGC 12278
    ```


* jmap：内存映射工具
* jhat:虚拟机堆转存储快照
* jstack:堆栈跟踪工具
* hsdis:jit生成代码反汇编

### 可视化工具

* jconsole:java监控与管理工具
* visualvm:多合一故障处理
* eclipse MAT 第3方工具

### 案例1：通过工具分析与调优

* GC 日志阅读

    ```
    # -XX:+PrintGCDetails -XX:+PrintGCDateStamps
    # 下面是一条GC日志
    2018-08-23T10:33:13.006+0800: [GC (Allocation Failure) [PSYoungGen: 5624K->480K(6144K)] 5624K->5321K(19968K), 0.0268830 secs] [Times: user=0.00 sys=0.00, real=0.02 secs] 
    
    # 解读
      2018-08-23T10:33:13.006+0800（发生时间）: [GC (Allocation Failure)（gc的类型，发生的原因） [PSYoungGen（年轻代使用收集器）: 5624K（回收前大小）->480K（年轻代回收后）(6144K（年轻代总大小）)] 5624K->5321K(19968K), 0.0268830 secs] [Times: user=0.00（用户态消耗CPU时间） sys=0.00（内核态消耗CPU时间）, real=0.02（从开始到结束的墙钟时间） secs] 
    # 多核的话CPU时间会重叠，墙钟时间包括非CPU（如IO）
    ```

* visualvm 分析正在进行的jvm 
* visualvm 分析堆转存文件

* 高性能硬件上程序部署策略
> 情况：文档查看类站，单机，性能高，堆内存设置大，单Full GC 时间很长，大对象直接进入老年代
> 处理：可采用在单机上实现逻辑集群，前加载一个负载均衡服务。将收集器改为CMS
* 集群间同步
> 情况：JBOSSCache 缺陷导致内存溢出，无堆转存文件。
> 处理：
* 堆外内存溢出
> 情况：普通pc机，由于设置过大的堆内存，使用了CometD 框架，存在大量NIO操作，Direct Memory 不够导致
> 处理：减少点堆内存设置
* 外部系统访问等待
> 情况：普通服务器，服务情况正常，宿主服务器CPU消耗异常，Runtime.getRuntime().exec() 频繁调用
> 处理：去掉shell,改用java api等获取数据
* 服务器JVM进程崩溃
> 情况：调用另外系统，响应时间过长，异步调用，大量调用，产生大量等待的Socket
> 处理：可改为消息队列
* 不恰当数据结构占用过大
> 情况：一个80M的文件到内存中形成一个100万的HashMap<Long,Long>
> 处理：改进数据结构


### 案例2：调优Eclipse

## Class 文件结构

* Byte与bit

> 数据存储是以“字节”（Byte）为单位，数据传输大多是以“位”（bit，又名“比特”）为单位，一个位就代表一个0或1（即二进制），每8个位（bit，简写为b）组成一个字节（Byte，简写为B），是最小一级的信息单位。

* 字符与字节

> ASCII码：一个英文字母（不分大小写）占一个字节的空间，一个中文汉字占两个字节的空间。一个二进制数字序列，在计算机中作为一个数字单元，一般为8位二进制数，换算为十进制。最小值-128，最大值127。如一个ASCII码就是一个字节。

> UTF-8编码：一个英文字符等于一个字节，一个中文（含繁体）等于三个字节。中文标点占三个字节，英文标点占一个字节

> Unicode编码：一个英文等于两个字节，一个中文（含繁体）等于两个字节。中文标点占两个字节，英文标点占两个字节

* java中数据类型占用字节

类型    | 字节
---     |---
byte    | 1字节
short   | 2字节
int     | 4字节
long    | 8字节
char    | 2字节
float   | 4字节
double  | 8字节
boolean | 1字节

> 字节码（Byte-code）是一种包含执行程序,由一序列 op 代码/数据对组成的二进制文件。字节码是一种中间码，它比机器码更抽象

> 一个字节占八位，用十六进制表示当然为两个数字了

> 根据Java虚拟机规范，Class文件格式采用一种类似C语言结构体的伪结构来存储数据
    * 无符号数: 属于基本的数据类型。u1,u2,u4,u8来描述1个字节，2个字节，4个字节，8个字节的无符号数，可用来描述数字，索引引用，数量值或按照UTF-8编码构成的字符串
    * 表: 由多个无符号数，或者字体表构成，所有表都已 _info 结尾
    
### 魔数与class文件版本
* 前4个字节，CA FE BA BE 固定，第5，6 为次版本号 ，第7，8 为主版本号，从45开始

### 结构详情 

> 从第9位开始

* 访问标记

* 索引集合

* 字段表集合

* 方法表集合

* 属性表集合

### 字节码指令简介

* 加载与存储指令
* 运算指令
* 类型转换指令
* 对象创建与访问指令
* 操作数栈管理指令
* 控制转移指令
* 方法调用与返回指令
* 异常处理指令
* 同步指令

> java 虚拟机规范描述了Java虚拟机应有的共同程序的存储格式:class文件格式及字节指令集，这些与硬件，操作系统完全独立，因此可以看着交流的标准，具体的虚拟机实现完全由作者自定义，目前有两种比较主流的实现方案

* 将输入的java虚拟机代码在加载或执行时，翻译成另外一种虚拟机指令
* 将输入的java虚拟机代码在加载或执行时，翻译成宿主CPU的本地指令（JIT代码生成技术）

> class 文件格式基本稳定，变化很小



## 类加载机制

> 类从被加载到虚拟机内存开始，到卸载出内存为止，它的生命周期分为： 加载,验证，准备，解析，初始化，使用和卸载。

![](/uploads/jvm/144324_BSaw_26712.jpg)


* 加载

> 通过一个类的全限定名来获取此类的二进制字节流，放到Java虚拟机外部实现，实现这个动作的代码模块称为 “类加载器”

> 可以通过以下途径获取

    * 从zip包读取       如 jar，ear,war 等
    * 从网络获取        如 Applet
    * 运行时计算生成    如 动态代理
    * 由其他文件生成    如 jsp 页面
    * 数据库读取        如 SAP NetWeaver
    * ...

> 开发人员可以通过自定义的类加载器去控制类字节流的获取方式（重写一个类加载器的loadClass()方法） 
> 数组本身不通过类加载器加载，但是数组中元素的是需要靠类加载器加载的

* 验证

> 验证是连接的第一步，确保class文件字节流符合当前虚拟机要求，并且不会危害虚拟机安全
    * 文件格式验证： 魔数，版本号，常量池等
    * 元数据验证：语义分析，是否有父类，接口，重载等
    * 字节码验证： 通过数据流和控制流分析，确认程序语义是否合法，符合逻辑。 
    * 符号引用验证：

* 准备

> 是正式为类变量分配内存，并设置类变量初始值的阶段，这些变量所使用的内存都将在方法区中进行分配。

* 解析

> 是虚拟机将常量池内的符号引用替换为直接引用的过程
    * 类或接口接卸
    * 字段解析
    * 类方法解析
    * 接口方法解析
    
* 初始化
> 对初始化的规定
    1. 遇到 new, getstatic, putstatic 或invokestatic 4条 如果类没有初始化，则触发初始化
    2. 使用 java.lang.reflect 进行反射调用，如没有初始，则初始
    3. 初始一个类，如其父类未初始，先触发父类初始
    4. 当虚拟机启动，用户需要执行主类（main 那个类），先初始这个类
    5. jdk1.7 动态语言


### 类与类加载器

> 通过一个类的全限定名来获取此类的二进制字节流，放到Java虚拟机外部实现，实现这个动作的代码模块称为 “类加载器”

> 对于任意一个类，都需要由**它的类加载器**和**这个类本身**一同确定其在java虚拟机中的唯一性

> 从虚拟机的角度讲，加载器分为2类，一种是启动加载器，由虚拟机自己实现(C++，不同虚拟机不同)，是虚拟机的一部分，另外一个是其他所有加载器，由java语言实现，独立于虚拟机外部，并且全部继承ClassLoader

### 双亲委派模型

> 定义： 如果一个类加载器收到类加载请求，它首先不会自己去尝试加载这个类，而是把这个请求委派给父类加载器去完成，没一层次的类加载器都是如此，因此所有的类加载器请求最终都应该传送到顶层的启动加载器中，只有当父级加载器反馈无法完成加载时(搜索范围内没有找到所需要的类)。子类加载器才会直接加载

![](/uploads/jvm/921e8b5310d910ac78a627d207bee2f7.png)

    1. 启动类加载器：（Bootstrap classLoader） ,加载java_home\lib 下面的
    2. 扩展类加载器：（Extension ClassLoader）,加载java_home\lib\ext
    3. 应用程序类加载器：（Aapplication ClassLoader）,负责加载用户类路径（classpath）上的
    
> 自定义类加载器  （继承 java.lang.ClassLoader 类即可，然后重写loadClass方法，如果本身不能处理。请给它的父类。而它的父类就是sun.misc.Launcher$AppClassLoader）


### 破坏双亲委派模型

> 父类加载器请求子类加载器完成加载动作（java中所有涉及SPI的加载动作基本如此，如JNDI,JDBC,JCE,JAXB 等）

> JNID (java命名和目录接口，是一组在java应用中访问命名和目录的接口)
    * 解耦：通过注册、查找JNDI服务，可以直接使用服务，而无需关心服务提供者，这样程序不至于与访问的资源耦合！
    * 在J2EE容器（如weblogic、websphere、jboss等）中使用
    
> SPI的全名为Service Provider Interface
    * 当服务的提供者，提供了服务接口的一种实现之后，在jar包的META-INF/services/目录里同时创建一个以服务接口命名的文件。该文件里就是实现该服务接口的具体实现类。而当外部程序装配这个模块的时候，就能通过该jar包META-INF/services/里的配置文件找到具体的实现类名，并装载实例化，完成模块的注入。    
    * java的spi运行流程是运用java.util.ServiceLoader这个类的load方法去在src/META-INF/services/寻找对应的全路径接口名称的文件，然后在文件中找到对应的实现方法并注入实现，然后你可以运用了

> 对于动态性的追求（代码热替换HotSwap，板块热部署HotDeployment）典型的 如 osgi 

### 案例：动态实现远程执行功能

## 虚拟机字节码执行引擎

### 运行时栈帧结构

* 局部变量表
* 操作数栈
* 动态连接
* 方法返回地址
* 附加信息

### 方法调用

* 解析
* 分派
* 动态类型语言支持

### 基于栈字节码解释执行请求

* 解释执行
* 基于栈指令集与基于寄存器的指令集
* 基于栈的解释器执行过程


## 程序编译与代码优化

### 编译器优化
* javac 编译器
* java 语法糖
* 实战：插入式注解处理器

### 运行期优化
* HotSpot 虚拟机内的即使编译器
* 编译优化计数

