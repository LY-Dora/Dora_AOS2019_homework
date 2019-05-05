# Mid Project Report
> 2018312572 李媛，与杨松涛组队完成对 µCore 的安全方面改进

## 0x1 实验目标

基于 µCore 进行改进和创新，目标是提高其安全性。

一开始的计划是实现在 µCore 上实现SGX,
对其进行详细的可信性分析以及代码评估后认为这个无法在有限时间内得到有效的成果，至多完成sgx driver部分内容，且难以进行评价。
后发现 µCore 没有实现各类安全机制，故修正目标为实现传统 Linux上的安全机制。

## 0x2 实验进度

### 对 µCore 的熟悉

我通过对 [GitBook](https://chyyuu.gitbooks.io/ucore_os_docs/content/) 和杨松涛本科笔记的学习，基本完成了 µCore 中六个实验的练习与对 µCore 的理解。（ µCore 没有实现challenge）。
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

即使拥有了ASLR以及W^X两个机制，只能防住代码注入攻击。然而攻击者可以通过篡改return address进行代码重用攻击。canary是一种防御缓冲区溢出从而实现代码重用攻击的有效保护。通常需要编译器和kernel共同支持才能够实现。通常由kernel生成随机值，在缓冲区与ebp之间引入从段寄存器获取的随机保护值。如果canary被修改直接触发中断异常。此外，在kernel

4. Mem Init

用户态获得的内存如果不被初始化可能会造成敏感信息泄露等问题，通过Mem Init可以避免此问题的产生。

## 0x3 实验中期总结

我们在定下初步题目后，经过一定的实验准备和分析评估发现其难以完成，并难以在有限时间内给出可展示的成果，故修正实验目标为在 µCore 上实现传统 Linux kernel 的安全机制。我已经完成前六个实验，正在做第七个实验，杨松涛正在完成ASLR安全机制。预计在期末完成两到三个传统的Linux kernel 安全机制。若提前完成预期，或会完成更多的安全机制。

## 0x4 µCore Study 
