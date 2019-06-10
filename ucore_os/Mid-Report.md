# Mid Project Report
> 2018312572 李媛，与杨松涛组队完成对 µCore 的安全方面改进

## 0x1 实验目标

基于 µCore 进行改进和创新，目标是提高其安全性。

一开始的计划是实现在 µCore 上实现SGX,
对其进行详细的可信性分析以及代码评估后认为这个无法在有限时间内得到有效的成果，至多完成sgx driver部分内容，且难以进行评价。
后发现 µCore 没有实现各类安全机制，故修正目标为实现传统 Linux上的安全机制。

## 0x2 实验进度

### 对 µCore 的熟悉

我通过对 [GitBook](https://chyyuu.gitbooks.io/ucore_os_docs/content/) 和杨松涛本科笔记的学习，基本实现了 µCore 中六个实验的代码练习与对其的理解。（ µCore 没有实现challenge）。
后我将在**0x4小节**阐述对 µCore 的理解和具体分析，以及附上代码链接[µCore](https://github.com/LY-Dora/Dora_AOS2019_homework/tree/master/ucore_os)。

### 对 SGX 移植的评估
#### 可行性分析
Intel SGX 在 µCore 上运行的需要的步骤如下：
- 使用 [Qemu-SGX](https://github.com/intel/qemu-sgx) 替代默认的 Qemu，以通过 `-cpu host` 应用主机上的 SGX 硬件。
- Qemu-SGX需要一个支持SGX的操作系统或者内核例如[SGX-driver](https://github.com/intel/linux-sgx-driver) 为上层代码逻辑提供sgx驱动。
- 需要移植[SGX SDK](https://github.com/intel/linux-sgx/tree/master/sdk)，为用户程序提供必要的动态链接库（例如trts和utrts）

#### 代码评估
我们完成了Qemu-SGX的编译和运行。
- [sgx-v3.1.0-r1](https://github.com/intel/qemu-sgx/releases/tag/sgx-v3.1.0-r1)
- Intel SGX 2.0.1
- Ubuntu 16.04 LTS

在实现Qemu-SGX的基础上我们需要实现SGX driver以及SGX SDK。

SGX driver 代码量为 2k 行左右，我们需要通过实现相关的Linux 系统库接口使其与µCore适配。这个尚可在有限时间内实现。

SGX SDK 依赖众多Linux Lib，实现一个普通的SGX SampleEnclave需要做适配工作就非常庞大。
结合两人的代码能力以及课业压力，其完成时间难以估计。
因此我们将目标改为在 µCore 上实现传统的 Linux 安全机制，使其更安全。

### 对 Linux 传统保护特性的分析

1. ASLR

Address Space Layout Randomization (ASLR) 是Linux kernel上最常见的安全防御机制。其通过对堆、栈、共享库基址的页面进行初始化从而防止攻击者直接利用某次泄露的地址进行攻击 (例如syscall的地址)。攻击者难以知道目标地址的精确地址，增大攻击者的攻击难度。其通过在栈基址、`brk` 和 `mmp`中加入随机偏移来实现。
- 0 - 表示关闭进程地址空间随机化。
- 1 - 表示将mmap的基址，stack和vdso页面随机化。
- 2 - 表示在1的基础上增加heap的随机化。

我们将实现ASLR所有功能。此外，PIE可以在ASLR的基础上对代码段和数据段做随机化，这需要编译器的支持。PIE将作为我们的**challenge part**。

2. W^X

如果代码页可写，则攻击者可以通过直接纂改代码页完成攻击。因此W^X为最常见的防御方案，其禁止可写页面拥有可执行权限，同时禁止可执行页面拥有可写权限。其通过在page上引入标志位进行标记实现。

此外，NX可以在W^X上实现禁止栈上代码被执行，以防御攻击代码注入栈上完成攻击操作。NX需要编译器的支持。NX将作为我们的**challenge part**。

3. Canary

即使拥有了ASLR以及W^X两个机制，只能防住代码注入攻击。然而攻击者可以通过篡改return address进行代码重用攻击。canary是一种防御缓冲区溢出从而实现代码重用攻击的有效保护。通常需要编译器和kernel共同支持才能够实现。通常由kernel生成随机值，在缓冲区与ebp之间引入从段寄存器获取的随机保护值。如果canary被修改直接触发中断异常。

4. Mem Init

用户态获得的内存如果不被初始化可能会造成敏感信息泄露等问题，通过Mem Init可以避免此问题的产生。

## 0x3 实验中期总结

我们在定下初步题目后，经过一定的实验准备和分析评估发现其难以完成，并难以在有限时间内给出可展示的成果，故修正实验目标为在 µCore 上实现传统 Linux kernel 的安全机制。我已经完成前六个实验，正在做第七个实验，杨松涛正在完成ASLR安全机制。预计在期末完成两到三个传统的Linux kernel 安全机制。若提前完成预期，或会完成更多的安全机制。

## 0x4 µCore Study 
### LAB 1
lab1是一个简单的操作系统，其需要填空的部分有`kern/debug/kdebug.c`和`kern/trap/trap.c`。lab1主要是需要了解操作系统的一些基础机制，例如栈结构和中断初始化以及中断处理。

#### [kern/debug/kdebug.c](https://github.com/LY-Dora/Dora_AOS2019_homework/blob/750d2049858b1931f6fd48e8a7751dc8f616cf4d/ucore_os/labcodes/lab1/kern/debug/kdebug.c#L305)

这部分主要是熟悉栈结构。其功能是打印栈信息。

其基本思路为
- 获取当前的 ebp 指针和 eip 指针
- 上溯到栈顶，重复以下过程
    - 打印ebp，eip 
    - 打印压栈传参的前四个值（也有可能没有传四个参，输出的是其他栈信息，比如局部变量。）
    - 打印当前 eip 所在的源代码信息
    - 上溯栈帧。
首先通过 `read_ebp` 取得当前 ebp 值后，将其转换为数组起始地址，然后按下标依次取得 ebp，Return Address，args……等数据。而 `eip-1`是因为，eip 总是指向下一条要执行的指令地址。实现与参考答案逻辑一样，具体细节不同。

#### [kern/trap/trap.c](https://github.com/LY-Dora/Dora_AOS2019_homework/blob/750d2049858b1931f6fd48e8a7751dc8f616cf4d/ucore_os/labcodes/lab1/kern/trap/trap.c#L49)
这部分是对所有中断入口进行初始化。

首先得到 `__vectors` 数组。然后遍历数组进行设置。`[T_SWITCH_TOK]` 的 `dpl` 需要特别设置，因此循环结束后再次设置`idt[T_SWITCH_TOK]`。`GD_KTEXT` 指 kernel text，为 8；`DPL_KERNEL` 和 `DPL_USER` 分别代表内核态和用户态的 DPL 级别，即 `(0)` 和 `(3)` 。
最后调用 `lidt ` 函数设置 IDT。

#### [kern/trap/trap.c](https://github.com/LY-Dora/Dora_AOS2019_homework/blob/750d2049858b1931f6fd48e8a7751dc8f616cf4d/ucore_os/labcodes/lab1/kern/trap/trap.c#L156)
这部分是对时钟中断部分进行处理。

`ticks` 是定义在 **kern/driver/clock.c** 中的 `size_t` 变量，在 **kern/driver/clock.h** 中进行了 extern。每当这个数值达到一次 100 的倍数（亦即又触发了 100 次 timer 中断），调用 `print_ticks` 函数进行信息输出。

### LAB 2
lab2的重点是对物理内存管理的掌握，其需要填空的部分有`kern/mm/default_pmm.c`和`kern/mm/pmm.c`

#### `kern/mm/default_pmm.c`
这部分需要修改所有的初始化内存页、内存页和释放内存页的函数，实现 first-fit 连续物理内存分配算法。

##### 初始化内存页

首先检查了 `n > 0` ，确保参数正确。然后遍历需要初始化的页，检查每一个页已经事先被 `Reserved` 标记过，处于合法约定状态；因此清空状态后，标记 `Property` 并将 First-Fit 算法中所需要的“其后块内连续空余页数量” `property` 在“并非块首的页”上置 `0` 、在“块首页”上置 `n` ，将页引用数 `ref` 置 `0` ，再全部加到空闲页管理列表 `free_list` 中。最后，空闲页总数的记录值增加 `n` 。

>这部分的实现和答案完全不同，导致后面两个的实现也和答案完全不同。我的答案是将n个内存页都加到了空闲页管理列表中。而答案是将n个页看作一个整体，将第一个页加到空闲页管理列表中。相当于，我的答案是每个同学的信息都加入管理档案，而github提供的答案是将班长的信息加入管理档案，由班长代替整个班。

##### 分配内存页

首先是参数检查，确保需要分配的个数大于 0。并且对于在一开始就知道不可能完成的“需分配数量大于空余物理空间数量”，直接返回 NULL。

接下来从表中空置节点 `&free_list` 开始按时刻维护的“地址增加顺序”从低到高顺序依次查找块首页。当查到第一个块内空间足够分配的块首页时，依次将自其开始的所需数量页进行处理，处理指针移向下一个节点，并从列表中去除当前节点。处理包括：进行 `Reserved` 标记表示已保留占用，清除 `Property` 标记表示不再空闲（至于 `property` 参数不必置 0，目前来看是因为后续使用过程中并没有影响，而到释放时又必将再次处理，故不必在此时做）。

若进行分配的块空间大于所需（通过 `p->property > n` 进行判断），那么需要将余下的部分切分下来单独成块。`Property` 标记已经存在，故仅需将 `property` 参数置为减去 `n` 后的原块页数即可。最后将空闲页总数记录值减去 `n` ，并返回分配出去的连续页的首页指针。

倘若遍历后未能找到符合要求的块，说明这一次分配在 First-Fit 算法中无法实现，返回 NULL 以示失败。

##### 释放内存页

首先进行参数检查，确保释放的页数量大于 0，并且所要分配的块有 `Reserved` 标记。

然后进行了三个节点的查找：**第一个地址高于所需释放页地址的页节点 `le`**（由于 First-Fit 算法内存分配的连续性，这也一定是一个块首页，或者查找失败时为 `&free_list` 空节点；用于在前插入和检查向后合并），**这个节点之前的一个页节点 `insert_prev`**（也可能为 `&free_list` ；用于检查向前合并）和**之前的最后一个块首页节点 `last_head`**（也可能为 `&free_list` ；用于向前合并）。

然后对页进行释放。首先确保 `base` 页的引用数清零。在 `le` 节点前依次执行 `list_add_before` 可以按地址增加顺序将所需释放的页加入到列表中，此前各页节点需要进行的处理操作包括：清除 `Reserved` 标记，添加 `Property` 标记，`property` 参数置 0。这些确保加入到列表中的页处于正确的可分配状态。

接下来考虑合并块。

首先考虑向前（低地址区）合并。倘若 `last_head == &free_list` ，说明释放的页已经处于地址的最低处，`base` 即成为新的块首页。而当 `last_head != &free_list` 时，倘若 `(le2page(insert_prev, page_link)) != base - 1` ，即虽然 `base` 之前有块，但地址并不连续，不能进行合并，`base` 仍然成为一个新的块首页。这样，`base` 置 `property` 为 `n` 。倘若上二条件均不满足，即 `base` 前既有块且地址连续，说明可以和之前的块进行合并。因此在查找到的 `last_head` 上将 `property` 加上 `n` 即可。这里用一个指针 `block_header` 指向合并后的块首页，便于之后操作。

然后考虑向后（高地址区）合并，这边就简单一些。由于插入点之后的节点 `le` 对应的一定是一个块首页，因此只要地址连续（ `le_page == base + n` ），就可以合并。将 `le` 的 `property` 置 `0` ，`block_header` 的 `property` 加上 `n` 即可。

最后将空闲页总数记录增加 `n` 。

#### `kern/mm/pmm.c`
这部分主要是实现寻找虚拟地址对应的页表项,以及删除页表项

##### get_pte()
函数首先通过 `PDX` 这个宏：

~~~c
// kern/mm/mmu.h
#define PDXSHIFT 22
#define PDX(la) ((((uintptr_t)(la)) >> PDXSHIFT) & 0x3FF)
~~~

取得了虚拟地址 `la` 对应的 PDE 在 PDT 内的偏移（22~31 位），并通过 `pgdir` 拿到了 PDE 的地址。然后检查其中的第 0 位（ `PTE_P` ）是否为 1。如果不是的话，说明对应 PT 没有建立映射关系。

假如参数 `create` 并不要求进行创建，那么可以直接返回 NULL。假如要求进行创建，但是分配页时失败，也返回 NULL。在分配成功的情形下，对页进行设置：置引用数为 1，取其实际物理地址并清空页，然后置标记 `PTE_USER` 并赋给 PDE。如此完成了 PT 的建立。

现在 PT 存在，那么返回对应的 PTE。

~~~c
// kern/mm/mmu.h
#define PTXSHIFT 12
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x3FF)
~~~

利用 `PTX` 宏取得 `la` 对应的 PTE 在 PT 内的偏移（12~21 位），并在

~~~c
// kern/mm/mmu.h
#define PTE_ADDR(pte) ((uintptr_t)(pte) & ~0xFFF)
#define PDE_ADDR(pde) PTE_ADDR(pde)
~~~

通过 `PDE_ADDR` 获得的清除了低 12 位标记的 PDE 物理地址值对应的 PT 虚拟地址（ `KADDR` ）所对应的 PT 中进行查找，得到 PTE，并返回地址。

##### page_remove_pte()
函数首先检查所给定的 PTE 对应的物理页是否存在（PTE_P）。假如确实存在，那么取得这个物理页，使其引用数减一（若引用数已经减至 0，那么释放这个页）。而在 PT 这边，对应 PTE 置 0（映射取消），并在 TLB 中使这一对应关系无效即可。

### LAB 3
lab3的考察重点是虚拟内存管理，其需要填空的部分有`kern/mm/vmm.c`和`kern/mm/swap_fifo`.

#### `kern/mm/vmm.c`
这部分主要是给未被映射的地址映射上物理页

当触发了 Page Fault 之后，经过 `do_pgfault` 函数前部的一些过滤，在设定好预先的权限信息 `perm` 和返回码 `ret` 后，开始分析缺页的具体情况。

首先取页表项，并对无法查找页表项的情况报错。然后检查页表项的内容，看是否曾经分配了对应的页。假如没有分配过，那么尝试分配一个新的物理页，并对无法分配物理页的情况进行报错；不然（分配过），那么这个物理页就是已经被 swap 出去了，需要 swap 回来。

补充完成基于 FIFO 的页面替换算法
接上文分析。此时已经确定 PTE 对应的页被 swap 了出去，需要换回来。

首先检查 `swap_init_ok` 判断 `swap_manager` 是否被正确初始化了，然后尝试 `swap_in` 虚拟地址对应的页面（如果返回非零则报错退出）。拿到换进来的页面后，将其插入物理页列表，并将其置于 FIFO 访问列表的首位（即最近访问过），然后设定物理页与虚拟地址的对应关系。

#### `kern/mm/swap_fifo`
这部分主要是对页替换算法FIFO的了解

`_fifo_map_swappable` 函数将 swap 进来的页面进行基于 FIFO 的管理，将其置于最近访问列表的首位。

`_fifo_swap_out_victim` 函数则基于 FIFO 选择需要被换出去的页，即最近访问列表的尾部元素。只要该列表非空，那么取最后一个元素对应的页并将其从列表中删除，返回以便于调用者将其 swap 出去。



### LAB 4
lab4主要对内核线程管理进行考核，其需要填空的部分有`kern/process/proc.c`

#### 分配并初始化一个进程控制块 alloc_proc()
这部分完成了对一个 `struct proc_struct` 的分配和初始化工作。其实现基本可以认为是全部赋初值，大部分是零，少部分是特殊定义的值。
| Param |    Value    |  Meaning   |
| :---: | :---------: | :--------: |
| state | PROC_UNINIT | 未初始化完成的状态  |
|  pid  |     -1      | 未分配 pid 的值 |
|  cr3  |  boot_cr3   |  内核页目录基址   |

#### 为新创建的内核线程分配资源 do_fork()

函数首先分配一个新的PCB，并和原内核线程建立父子关系。然后，分配内核栈，再复制（或仅共享，用于 COW。不过内核线程由于本身一定共享内存信息，所以并不复制）一份到这个内核栈中。假如出错，则逐步执行对应的撤销回收措施。

接下来，将中断帧置于内核栈顶，并设置对应的上下文信息，再透过保护锁将这个新的内核线程加入到列表中（包括分配一个新的 pid，建立 hash ，加入到列表中，计数+1）。然后，唤醒该内核线程，并设置返回值为子内核线程的 pid。

### LAB 5
lab5的主要目的是熟悉用户进程管理，其需要填空的部分有`kern/mm/vmm.c`,`kern/mm/pmm.c`,`kern/trap/trap.c`和`kern/process/proc.c`
#### `kern/process/proc.c`
该部分主要是加载应用程序并执行
在 `load_icode` 函数中，当完成 vma 和 mm 的建立后，需要建立用户进程的执行现场。为此，清空中断帧后再次进行赋值，将代码段、数据段、堆栈等设置好，并将中断开关打开。

#### `kern/trap/trap.c`
这部分内容主要是在lab1的基础上进行更新。其目的是让用户进程调用系统调用从而使用µCore。所以需要在此设置系统调用中断门。

#### `kern/mm/vmm.c`
这部分主要是需要更新do_pgfault()函数，也是因为用户进程的原因。

#### `kern/mm/pmm.c`
父进程复制自己的内存空间给子进程
在 `copy_range` 函数中，根据二级页表不断复制整个内存空间到子进程对应处。复制时，分配好空间后，分别取两内存页的内核虚拟地址，执行复制操作，并建立与线性地址的映射关系。


### LAB 6
lab6的侧重点是进程调度，其需要填空的部分有`kern/schedule/default_sched.c`，`kern/trap/trap.c` 和`kern/process/proc.c`

#### `kern/schedule/default_sched.c`
这部分是为了实现Stride Scheduling 调度算法
主要遵照 **kern/schedule/default_sched_stride_c** 文件内的指导，按 **skew_heap** 的方案进行实现。
1. init

初始化调度器。需要做的是初始化`rq->run_list`，将 skew_heap 指针 `lab6_run_pool` 置为 NULL，并将 `proc_num` 计数器设为 0，rq->run_list。

2. enqueue

入队时，和 RR 一样设置时间片，然后将 proc 加入优先级队列，并使计数器加一。

3. dequeue

出队时，从优先级队列中删除对应 proc，并使计数器减一。

4. pick_next

选择时，若队列为空则返回 NULL。不然，取队首即可，依 priority 计算 pass 并更新 stride，并返回 proc。

5. proc_tick

当触发 timer，和 RR 一样更新时间片数据并视情况置 need_resched。

此外，为保证溢出时正常计算，需设定 `BIG_STRIDE` 为对应位数的有符号数最大值，即 `0x7fffffff`。


#### `kern/process/proc.c`
这部分主要是更新lab5的内容，将分配进程的进程结构初始化内容增加。
主要是要初始化以下内容

|    Value    |  Meaning   |
| :---------: | :--------: |
| struct run_queue *rq | running queue contains Process |
| list_entry_t run_link | the entry linked in run queue |
| int time_slice |  time slice for occupying the CPU   |
| skew_heap_entry_t lab6_run_pool | the entry in the run pool |
| uint32_t lab6_stride | the current stride of the process |
| uint32_t lab6_priority |  the priority of process   |

