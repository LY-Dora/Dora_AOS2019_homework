## Multiprogramming a 64 kB Computer Safely and Efficiently 
- **Authors：**  Amit,Bradford Campbell,Branden Ghena,Daniel B. Giffin,Pat Pannuto,Prabal Dutta,Philip Levis   

- **Paper：** https://sing.stanford.edu/site/publications/levy17-tock.pdf
### Summary of major innovations
 这篇论文提出了一种用于低功耗嵌入式平台的新操作系统Tock，这个新操作系统有以下功能：
 - 隔离软件故障
 - 提供内存保护
 - 可为应用程序请求动态分配内存
 - 满足长期运行应用程序的可靠性要求
 
Tock：一个微控制器操作系统
- 使用Rust语言编写内核，隔离驱动程序
    -  Rust语言是一种类型安全的语言，其内存效率和性能接近于C。Rust允许Tock用类型安全的接口封装其大部分内核。
- Tock的组成部分/隔离机制
    -   Capsules
        -   Capsules由Rust语言编写，不同功能的Capsules有着不同的类型。Capsules在编译时强制执行隔离，capsules之间的隔离可以使得部分capsules出现错误行为或者存在bug时保护其他的capsules。Capsules只能访问部分被授权的资源，常用于设备驱动程序，协议和计时器等。此外，Capsules消耗最少的内存并且具有可忽略的开销或没有计算开销。
        -   Tock有两种capsules，一种是值得信赖的，该capsules使用Rust语言编写，链接到内核，另外一种是完全不可信的，用于处理任何语言。可信的capsule本质上是一个使用共享栈的Rust模块事件驱动。
        -   Capsules无法生成新事件。它们通过正常的控制流直接与内核的其余部分进行交互。这有两个好处。首先，它减少了开销，因为使用事件需要Capsules之间的每次交互都要通过事件调度程序。其次，Tock可以静态分配事件队列，因为在编译时已知事件数。与TinyOS如何管理其任务队列类似，这可以防止有问题的Capsules排队许多事件，填充队列，并通过耗尽队列资源来损害可靠性
    -   Process
        -  Tock中的进程概念与其他系统中的进程概念很像。进程提供应用程序与内核之间的内存和CPU资源的完全隔离，允许开发人员用C或任何其他语言编写程序。Tock中每一个进程的栈是独立的，而内核的栈是共享的。
        - 虽然类似于Linux等系统中的进程，但Tock进程在两个重要方面有所不同。首先，因为微控制器仅支持绝对物理地址，所以Tock不会通过虚拟内存提供无限内存的错觉，也不会通过共享库共享代码。其次，在Tock中，进程与Kenrel交换的方式也是系统调用，其系统调用内核的API是非阻塞的。
        - 因为它们是硬件隔离的而不是类型系统的沙箱，所以它们可以用任何语言编写。因此，它们可以方便地使用和合并用其他语言编写的现有库，例如C.其次，它们是预先安排的，因此它们可以安全地执行长时间运行的计算，例如加密或信号处理
    -   Grants
        - Tock用称为grants的内核抽象避免在内存效率和并发性之间进行权衡。grants是位于每个进程的内存空间中的内核堆的独立部分以及用于访问它们的API。 grants充当动态内核堆，与普通内核堆分配不同，一个进程的grant不会影响内核为其他进程分配的能力。虽然堆内存仍然有限，但当一个进程耗尽其grants内存并失败时，系统的其余部分将继续运行。此外，如果进程终止或被替换，grants可以保证进程的所有资源可以立即安全地释放。此方法允许每个进程动态地捐赠其可用内存，以便执行特定时刻所需的任何并发请求。它还避免了在内核中预先分配的请求结构的需要。尽管内核本身仅使用静态分配以保证连续操作，但此功能同时允许灵活配置应用程序并有效使用宝贵的内存。
        

### What the problems the paper mentioned?
之前的嵌入式系统只需要运行单个程序，因此低功耗嵌入式操作系统将应用程序和操作系统本身混在一起，使用相同的内存区域，将应用程序与内核合并可以轻松地在两者之间共享指针，并提供对低级功能的有效过程调用访问。这种单片方法通常需要将设备的应用程序和操作系统一起编译和安装或替换为一个单元。所以，低功耗微控制器缺少一些支持多编程系统的硬件特性和存储器资源。

而现在的嵌入式系统的要求更高，发展成了软件平台，有许多类似进程的组件交替运行。这些受限制的特征使得多程序设计变得困难。如果没有内存隔离，所有代码必须绝对可信，任何行为不当的组件都会威胁到整个系统。即使故障以某种方式被捕获，系统和应用程序组件通过共享指针的连接意味着可能没有一种安全的方法来在运行时仅关闭故障组件。

此外，嵌入式设备需要长时间运行且无故障运行。为此，这些平台的软件通常静态分配所有内存。这避免了由于动态应用程序行为导致的难以预测的内存耗尽。在严重受内存限制的环境中，即使堆碎片也会对内存可用性构成严重威胁。所以即使内存隔离和动态内存管理具有明显的软件工程和性能优势，但用于低功耗嵌入式平台的软件系统大多提供了更简单，更易于实现的应用程序执行模型。

综上所述，基于微控制器的操作系统没有提供诸如故障隔离，动态内存分配和灵活并发等重要功能。
### How about the important related works/papers?
- TinyOS
    - paper：https://people.eecs.berkeley.edu/~pister/290Q/Papers/levis06tinyos.pdf
    - TinyOS是一种广泛使用的传感器节点操作系统，它提供并发性和灵活性，同时遵守稀缺资源的限制。TinyOS被认为是传感器网络中强大，具创新性，能源效率高且广泛使用的操作系统。 
- FreeRTOS
    - link：https://www.freertos.org/
    - FreeRTOS是一个热门的嵌入式设备操作系统，FreeRTOS可以实现多线程、互斥锁、信号量等功能。此外，FreeRTOS号称具有最小的ROM，RAM和处理开销。但是根据TockOS的实验结果来看，TockOS的处理开销明显低于FreeRTOS。

### What are some intriguing aspects of the paper?
- 这篇论文提出的操作系统一个特色是大部分代码使用Rust语言编写，利用Rust的安全性在保障内存安全的同时可以在性能方面获得一些优势

### How to test/compare/analyze the results?
由于Tock探索了嵌入式内核设计空间的新观点，无法与具有不同设计考虑因素的现有系统进行定量比较，因此这篇论文从以下四个方面对Tock进行定量评估：
- 使用capsules隔离的成本是多少？ 
- 使用capsules与仅使用过程分离相比如何？ 
    - Memory overhead
    - Communication overhead
- 与备用解决方案相比，grants的内存量是多少？ 
- 使用grants的成本是多少？

### How can the research be improved?
- 我觉得Tock在资源消耗方面可以有进一步的改善，其资源消耗与TinyOS相比，还是相对消耗得更多，存在进步空间

### If you write this paper, then how would you do?
- 如果我写这篇论文，我大概会在评价体系中加入一部分关于安全的分析或实验，因为这篇论文提出了做出了内存保护，论文的理论部分也是具有说服力的，但是既然论文标题写明了safely，我觉得需要在evaluation部分加入对这个操作系统的安全性的分析或者有实验更好。

### Give the survey paper list in the same area of the paper your reading.
[1]HAN,C.-C.,KUMAR,R.,SHEA,R.,KOHLER,E.,ANDSRIVASTAVA, M. A dynamic operating system for sensor nodes. InProceedings of the3rdInternationalConferenceonMobileSystems,Applications,and Services(New York, NY, USA, 2005), MobiSys ’05, ACM, pp. 163– 176. 

[2] LEVIS, P., MADDEN, S., POLASTRE, J., SZEWCZYK, R., WHITEHOUSE,
K., WOO, A., GAY, D., HILL, J., WELSH, M., BREWER, E.,
AND CULLER, D. Ambient Intelligence. Springer Berlin Heidelberg,
Berlin, Heidelberg, 2005, ch. TinyOS: An Operating System for Sensor
Networks, pp. 115–148.

[3] KLUES, K., LIANG, C.-J. M., PAEK, J., MUS ̆ ALOIU-E, R., LEVIS, P., TERZIS, A., AND GOVINDAN, R. TOSThreads: Thread-safe and Non-invasive Preemption in TinyOS. InProceedings of the 7th ACM Conference on Embedded Networked Sensor Systems(New York, NY, USA, 2009), SenSys ’09, ACM, pp. 127–140. 

[4] MCCARTNEY, W. P. SimplifyingConcurrentProgramminginSensor-nets with Threading. PhD thesis, Cleveland State University, 2006
