## kAFL: Hardware-Assisted Feedback Fuzzing for OS Kernels
- **Authors：**  Sergej Schumilo, Cornelius Aschermann, Robert Gawlik, Sebastian Schinzel, and Thorsten Holz 

- **Paper：** https://www.usenix.org/system/files/conference/usenixsecurity17/sec17-schumilo.pdf

### Summary of major innovations
#### Abstract
这篇论文所关注的问题是如何对内核进行模糊测试，俗称fuzz。在计算机系统中存在许多内存安全漏洞，而模糊测试是用来寻找并发现这些内存漏洞的有效措施。目前大部分模糊测试仅能够在用户态使用。内核态的内存漏洞与用户态的相比显得更加重要，因为一旦攻击者能够利用内核漏洞就可以获得所有权限。然而由于不能够轻易应用反馈机制，比如说代码覆盖率，因此内核模块很难被fuzz。此外，如果对内核进行fuzz导致内核崩溃从而重启操作系统会严重影响fuzz的性能。

这篇论文使用利用硬件特性的方式处理对内核fuzz可能遇到的问题：这篇论文使用Intel-PT以及VT-x对目标操作系统的内核进行fuzz。这两项技术的结合使用使得作者提出的方案能够独立于目标操作系统，因为只需要一个与目标操作系统交互的小型用户态组件即可。因此，即使在内核崩溃的情况下，kAFL都不会有过多的性能开销。
#### Design && implement 
![img](https://camo.githubusercontent.com/9d3f23dc07bb5a5d8af965a6304e87a43a7b10f2/68747470733a2f2f692e696d6775722e636f6d2f6d363053564e562e706e67)



根据该图我们可以看到，KAFL的实现是模块化的，因此其扩展性好，修改会更加灵活。
从图上可以大致将该方案分为两部分：一部分为Host部分，一部分为VM部分。
Host部分有分为三部分：

- KVM-PT
    - KVM-PT主要是实现了Intel PT的trace功能，用以收集目标内核程序的程序执行流信息，从而方便fuzz逻辑部分对其进行分析生成新的种子
- QEMU-PT
    - 等KVM-PT收集完控制流信息以后，QEMU-PT将其解压，是decoder
    - QEMU-PT还是KVM与kAFL交互的中间部分，KVM-PT与kAFL通过QEMU-PT进行交互
    - KVM-PT先将trace发给QEMU-PT解码，QEMU-PT解码后再将解码后的信息发给kAFL去fuzz生成种子
- KAFL
    - kAFL是本文提出的解决方案中的fuzz逻辑部分，其参考了AFL也以反馈的覆盖率信息为导向，变异生成新的、更加高效的种子/输入。
    - kAFL能够并发fuzz
    - kAFL也用bitmap存储基本块的转换，通过QEMU-PT获取bitmap，然后决定变异生成怎样的种子去触发更“有趣”的路径

VM部分分为两部分：
- Target
    - Target部分是目标内核
- Agent
    - Agent是用以交互的中间件，用以与Target进行交互，做一些必要的操作，例如挂载镜像等。
    - Agent通常是将KVM-PT传过来的hypercalls信息当作目标内核的输入
    - Agent通过调用hypercall的方式与目标内核交互，作为目标内核的输入信息，尝试触发crash。

#### contribution
- 操作系统独立性
    - 通过利用虚拟机管理程序（VMM）进行覆盖，可以使用与操作系统无关的方式实现以反馈机制为驱动的闭源内核的模糊测试。这一方案允许对任意X86操作系统内核或者用户态组件进行模糊测试。
- 硬件特性辅助反馈机制：
    - 本文使用了PT，并只解码使用其采集的部分信息，拥有极小的性能开销。
- 可扩展性和模块化设计：
    - 这篇论文提出的方案模块化设计fuzz组件，这大大提高了该方案的可扩展性。
- kernel AFL
    - 论文作者结合了本文的设计概念，并已经实现KAFL原型，并使用该原型在操作系统的内核组件中找到了几个漏洞，该方案原型方案代码公开到了github上。

### What the problems the paper mentioned?
这篇论文想解决以下几个问题：
- 怎么对闭源操作系统进行fuzz，实现平台无关性
- 怎么解决对内核fuzz流程复杂、效率低、开销大的问题
### How about the important related works/papers?
- 黑盒fuzz
    - 黑盒fuzz对覆盖率较高的输入进行一定的重组、变异产生新的输入。
    - 黑盒fuzz的缺点是耗时
    - 相关工作有Radamsa，zzuf，Peach和Sulley
- 白盒fuzz
    - 白盒fuzz对目标程序进行一定的分析从而找到更加好的种子（或者输入），常常有使用符号执行，约束求解等方法探索复杂路径。或者使用污点分析与动态分析的方法探索发现新的执行路径。
    - 白盒fuzz的缺点是难以并行化，难以在大型程序上落地实现。
    - 相关的工作有BuzzFuzz，Vuzzer和TaintScope
    - 在这篇论文发表之前暂时没有基于内核的白盒fuzz
- 灰盒fuzz
    - 灰盒fuzz想结合黑盒fuzz和白盒fuzz的优点，主要代表是AFL，它使用覆盖率信息作为导向进行fuzz，这样的话不需要在不能触发新路径/行为的输入上浪费时间。
- 内核fuzz
    - syzkaller
        - 第一个公开可用的基于内核的灰盒fuzz
    - IriforceAFL
        - 基于对QEMU的修改，仅能够对类似Linux，FreeBSD等经典类UNIX操作系统起作用，对闭源操作系统支持较差。

### What are some intriguing aspects of the paper?
- 这篇论文比较有新意的点在于使用VT-x和Intel PT这两个硬件特性。
- VT-x是一种用于提高虚拟化效率的技术，这种虚拟化技术能够在控制VM以及VMM操作的时候更加快速、安全、可靠。
- Intel PT技术是一种Trace追踪技术。其可以搜集程序运行时的信息，指令运行时的部分与控制流有关的上下文信息，甚至能够重构整个程序的控制流，获得程序的所有控制流信息。这项技术对于Fuzz而言，能够更好的分析执行程序，获得更好的种子/输入。
- 本文使用Intel PT记录目标内核态进程的运行时信息，作者使用AUTOLOAD MSR的特性避免了冗余数据的记录，此外，本文所提出的方案只记录部分控制流信息，删除无关信息，避免不必要的解码负担。
- 由于本文提出的解决方案能够独立于操作系统，因此不会由于内核崩溃需要重启影响到性能开销，本文作者提出该方案性能开销几乎可以忽略不计。

### How to test/compare/analyze the results?
本文对该方案进行了以下几个方面的测试以及评估：
- 对内核进行fuzz测试
    - Windows
        - 发现一个拒绝服务的漏洞
        - 实现了一个syscall的fuzz测试代理
        - 没有发现任何错误
    - Linux
        - ext4驱动程序中的160个crash和多个已被确认的错误
    - MAC OS
        - 在HFS驱动程序中发现了150个crash
        - 能够手动确认其中三个是导致内核崩溃的唯一错误，可以由非特权用户触发，因此可能被利用为本地拒绝服务攻击
        - 发现一个use after free漏洞，可以完全控制rip寄存器
        - 在APFS中发现220个crash
        - 报告了3个HFS漏洞和多个APFS漏洞
- keyctl测试并发现已有CVE
    - 发现了CVE-2016-0758与另一个以前未知的错误，CVE-2016-8650
- fuzz的效果
    - 能够在3分钟内完成TriforceAFL30分钟完成的同样数量的路径
    - 能够发现大量TriforceAFL 难以到达的路径
    - 10-15分钟后停止fuzz
    - 没有比较syzkaller
- KVM-PT的开销
    - 与未使用PT的程序相比，性能开销低于5%，因此预估大概有5%的内核开销。
    - 在基准测试中，开销在1%-4%
- decoder 开销
    - 解码器是基于libipt实现的
    - 通过删除控制流信息包以外的内容来清理样本，降低开销，避免大量解码
    - 本文实现的解码器速度比intel的解码器快，仅使用56倍的时间，解码250倍的数据。速度提高了25-30倍
    - 这是因为可能包含有大量的循环，而本文提出的这个解码器压根不管这些信息
    - 还有可能是使用capstone作为指令解码后端

### How can the research be improved?
通过对这篇论文discussion部分的阅读我们可以知道这篇论文有以下值得改进的点：
- 这篇论文使用少量依赖于OS ring3代码实现一定的功能，因此OS独立性存在改进空间
- 由于使用Intel-PT以及VT-x，本文的方法仅限于特定的CPU，有特殊的硬件要求
- Intel PT不仅需要控制流信息用以重构控制流，还需要相关程序。因此如果程序在运行时候使用JIT编译器被修改，则PT无法完全恢复运行时的控制流信息。因此本文不支持对内核JIT组件进行fuzz，而内核JIT组件是存在漏洞且比较严重的部分。
- 本文无法有效绕过对输入中的大魔法值的检查。
- 本文只针对内核代码进行fuzz，还可以对ring3进行fuzz

### If you write this paper, then how would you do?
- 本文缺乏与syzkaller等相关内核fuzz工作的实验结果比较，如果是我的话可能会对其进行补充。



