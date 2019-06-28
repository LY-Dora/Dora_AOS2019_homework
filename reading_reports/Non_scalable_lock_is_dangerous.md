# Non-scalable locks are dangerous
- **Authors：**  Silas Boyd-Wickizer, M. Frans Kaashoek, Robert Morris, and Nickolai Zeldovich  

- **Paper：** https://pdos.csail.mit.edu/papers/linux:lock.pdf

## Summary of major innovations
### Abstract
这篇论文主要介绍了在多核环境下，非扩展锁会造成系统整体性能崩塌式下降。
为了解释这一现象，作者提出了一个马尔可夫模型，用来模拟系统性能随核数变化的曲线。
其模型的结果很好地吻合了实验结果，从而说明性能崩塌现象是由于非扩展锁的设计本质影响的，而不是其他因素。
紧接着，本文提出了四个扩展锁：与非扩展锁的对比，最后本文使用MCS锁取代Linux自旋锁做性能测试。
测试结果表明，扩展锁能够消除多核环境下系统整体性能崩塌式下降的问题。
本文有以下几个贡献：
- 证明了非扩展锁的性能不佳会导致实际工作负载的性能崩溃，即使非扩展锁只保护内核中非常短的关键部分
- 提出了一种独立的针对非扩展锁行为的综合模型，用来记录所有非扩展锁的操作状态
- 基于X86的多核处理器上确认MCS锁可以提高最大可扩展性

### Background
- What is non-scalable lock or scalable lock?
    - StackOverflow有一个回答是：“可伸缩锁定”或“不可伸缩锁定”一词没有正式定义。它意味着暗示一些锁定算法，技术或实现即使在存在大量争用锁定时也表现得相当好，而有些则没有。
    - 本文提出可扩展锁的特点是：每个获取锁请求导致的cache misses数量都是固定的，不随着核心数增多而增多。这些锁都有一个队列，每个核都在自己队列中的对应队列条目上循环等待。  
- non-scalable lock
    - Ticket lock
        - 锁具有两个字段，正在使用锁的ticket（current_ticket）和等待使用锁的ticket（next_ticket）。如果要竞争锁，则需要在next_ticket上领一个最新的ticket。锁释放的时候 current_ticket+1。然后所有核去看current_ticket是否是自己的ticket，如果是才能去占锁。
        - 这样做的话每一次释放锁机制，等待占锁的核的cache line都失效，要重新访问读取最新的current_ticket，读取是序列化的。因此这个过程是一个线性的过程，每次释放锁都会产生O(N)的成本

- scalable lock
    - MCS lock
        -  MCS锁维护一个明确的qnode结构队列。MCS是在自己的qnode上忙等，前一个qnode在释放时会将负责唤醒/设置下一个qnode的状态。
    - K42 lock
        - K42较MCS的主要区别是通过巧妙的手段，使其结点保存在函数栈中，避免了不必要的内存占用。
    - CLH lock
        - CLH是在前驱的cache line上忙等，自己管自己，释放时只需要改变自己的状态，无需管理其他等待者。这允许服务器队列是隐式的。
    - HCLH lock
        - HCLH是CLH锁的分层变体，支持与当前拥有锁的内核共享L3缓存的内核进行锁定获取，其目标是降低远程内核之间的与当前拥有锁的核心共享L3缓存。

- Markov model
    - 它是随机过程中的一种过程，一个统计模型。在马尔可夫模型中，将来的状态分布只取决于现在，跟过去无关

### Evaluation of non-scalable lock performance
本文用了四个Linux内核中的测试集对non-scalable lock进行测试，从而说明非扩展锁的多核性能。
![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig.png)

### Why does the performance of ticket lock collapse
作者使用马尔可夫模型进行模拟，如下图所示。
![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig2.png)

该图表示n个核心的票证旋转锁定的Markov模型。 状态i表示i核心持有或等待锁定。
ai是已经有i核争用锁的新核的到达率。 si是i + 1核心竞争时的服务率。
一共有n种状态，代表着现在有n个核在等待。
当已经有k个核获取了锁：则有新的核获取锁的概率为：
![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig3.png)

其中1/a代表着一个核获取锁的可能。

释放锁的概率为：
![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig4.png)

其中s代表着cs区域所需要的周期数，c为home directory回复一个request所消耗周期数，k/2是k个request顺利找到下一个ticket平均需要的次数。

假设P0,P1…,PnP0,P1…,Pn为整个稳态系统处于各个状态的概率，则有以下等式：

Pk∗ak=Pk+1∗Sk+1

所有P加起来为1，可以推出来
![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig5.png)

因此可以知道一个锁有少核心等待的概率，并算出期望值：
![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig6.png)

由上可知，当整个系统具有n-w内核时，可以达到最大加速。因此，当核数超过n-w时，其性能不会再上升。

此外，如下图所示：

![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig7.png)

![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig8.png)



第一个测试是选用了固定的cs区域内周期数与非临界区周期数，并选用不同的比例进行测试。
第二个测试是固定临界区所占比例不变，改变临界区的周期数。观察不同的临界区长度对

由图可知，马尔可夫模型能够较好的和实验数据进行拟合，该结果说明使用非扩展锁在多核情况下性能断崖式下坠并不是硬件的问题，而是非扩展锁本身设计的问题。

### Evaluation of scalable lock performance
作者又使用MCS锁做了与ticket lock同样的性能测试，其结果如下。该结果说明了扩展锁能够避免性能急剧下降。
![image](https://github.com/LY-Dora/Dora_AOS2019_homework/raw/master/reading_reports/non-scalable_lock/fig9.png)




### Conclusion
- 不可扩展的锁可能会导致多核系统的性能不佳
- 不可扩展锁可能会导致多核系统性能出现崩塌式下降的现象，这与不可扩展锁的设计有关，与其他的因素无关
- 只保护内核中非常短的关键部分也可能导致性能的崩塌式下降
- 可扩展锁可以避免性能的急剧下降，但是这只是一个缓解措施并不是最终解决方案
- 或许无锁设计才是这类问题的最终解决方案

## What the problems the paper mentioned?
本文涉及的问题就是多个操作系统依靠不可扩展锁进行序列化，比如说linux内核中使用ticket lock机制。然而不可扩展锁可能会导致实际的工作性能急剧下降，即使只对非常短的关键部分使用该锁机制。作者需要通过实验以及理论去证明这个现象，从而说明扩展锁更适合用于多核操作系统。

## How about the important related works/papers?
- 原文引用[1,7,9]说明不可扩展锁例如简单的自旋锁在高度竞争时性能较差。
- 引用[9]提出MCS锁，引用[8]提出HCLH锁
- 引用[6]提出的针对非扩展锁行为的综合模型与原文不同

## What are some intriguing aspects of the paper?
我认为本文的亮点是用马尔可夫模型对非扩展锁在多核情况下的性能进行模拟。
对非扩展锁做性能测试以及对扩展锁做性能测试是常规操作。
但是使用马尔可夫模型做模拟从理论的角度说明性能崩塌现象是非扩展锁自身设计的问题，与其他因素无关是这篇论文的亮点，也是强有力的论据。

## How to test/compare/analyze the results?
- 本文使用四个Linux内核的测试集：FOPS，MEMPOP，PFIND和EXIM对非扩展锁进行多核性能测试。
- 本文使用马尔可夫模型对非扩展锁的多核性能情况进行，与真实的实验数据做对比，从而说明非扩展锁导致的性能崩塌式下降是与其设计本质有关，与其他因素无关。
- 本文将非扩展锁ticket lock以及四个扩展锁占核以及释放核的吞吐量进行对比，在多核情况下。实验对比图可以看出四个扩展锁的吞吐量都明显高于非扩展锁ticket lock的吞吐量。
- 本文使用同样的四个测试集对扩展锁MCS锁做性能测试，将MCS锁和ticket lock的性能曲线做对比，从而说明扩展锁能够避免性能急剧下降。

## How can the research be improved?
- 这篇论文创新性不够，扩展锁和非扩展锁的问题早就被提出。

## If you write this paper, then how would you do?
- 首先我会把背景介绍的更加翔实，比如说对非扩展锁、扩展锁和马尔可夫链的介绍。
- 其次我会探讨一下为什么扩展锁的性能会更好，而不是仅仅复述和分析实验数据。
    - 我认为MCS锁的性能会比ticket lock的性能好的原因是在ticket lock中是所有的核都去读一个变量去判断自己是否能够占锁。而MCS是正在用的锁释放时通知下一个核。所以每个核都在自己的qnode上自旋，不需要去全局读取某一个cache line，这样性能会比较好



