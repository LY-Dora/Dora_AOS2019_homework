# µCoreS

A secured [µCore](https://github.com/chyyuu/ucore_os_lab) designed by Dora & OnionYST.

## Build & Run

1. Build

~~~sh
make
~~~

2. Run

~~~sh
make qemu-nox
~~~





## `NX`

### How to use `shellcode`

```
>>> from pwn import *
>>> a = u"	/* push 'attacked!' */\n	push 0x0a21\n	push 0x64656b63\n	push 0x61747461\n	/* call write(1, 'esp', 9) */\n	push 1\n	pop ebx\n	mov ecx, esp\n	push 10\n	pop edx\n	push edx\n	push ecx\n	push ebx\n	mov eax, 0x008004f7\n	call eax\n push 0\n mov eax,0x008009cb\n call eax\n"
>>> asm(a)
'h!\n\x00\x00hckedhattaj\x01[\x89\xe1j\nZRQS\xb8\xa9\x02\x80\x00\xff\xd0j\x00\xb8\xcb\t\x80\x00\xff\xd0'
```

- 首先`make`

- 生成二进制文件以后使用 `objdump -d `  查看二进制文件的汇编，确认`vulnerable`函数内的数组首地址与`vulnerable`函数的 `ebp `的偏移

- 源码中的  `*(int *)(s+0x28+0x200)=(int)s; `  其中`0x28+0x200`即为`vulnerable`函数内的数组首地址与`vulnerable`函数`ebp `的偏移+4，这样的话就可以把`return address` 修改成数组的首地址，从而使得 `eip `跳转到栈上执行栈上的 `shellcode `

- 然后查看在这个二进制文件中的 `write `和 `exit ` 函数的首地址，将 `shellcode `中的  `0x008004f7 ` 修改为 `write` 的首地址，将将 `shellcode `中的  `0x008009cb ` 修改为 `exit` 的首地址

- 然后再次`make`

- 然后运行`qemu`，运行该目标程序

- 攻击成功的现象为：终端输出“attack!”再调用`exit`函数退出

  ![img](https://lh5.googleusercontent.com/MZ3xsHNjCNa4wGocZR1PlHo4BW3Bz1aWIZHmWQSFbzV62XlRsr_y7ld4sfW9-63xOLWg-tuZBYkXaKbl9pcIEFPdElZ-DTRLiPtnpmPCMnugYsU1Y3FILVxiMbtkKWHnBF_uXtoJ)



### Test Case

```
.
├── user
|   +--- gcc_data_attack.c
|   +--- gcc_stack_attack.c
|   +--- llvm_data_attack.c
|   +--- llvm_stack_attack.c
|   +--- code_attack.c
```

- `gcc_data_attack.c `和` llvm_data_attack.c `没有什么区别，只是由于编译器的不同，`return address` 的偏移量不同罢了

- `gcc_stack_attack.c `和 `llvm_stack_attack.c` 没有什么区别，只是由于编译器的不同，`return address` 的偏移量不同罢了

- 由于 data段不可改，所以只测试了一次

- `llvm_stack_attack.c` 和` llvm_data_attack.c ` 都是已经加了安全防护的二进制，若想测试编译器是`clang`且在不开启保护的情况，则请将Makefile中的`UCFLAGS += -Xclang -load -Xclang ./CheckPass/build/src/libCheckPass.so` 注释掉。

  - 同时注意 `write `和 `exit ` 函数的首地址，以及`vulnerable`函数内的数组与`return address` 的相对偏移，根据这三个值的改变修改 `shellcode `与目标源文件，并且需要再次编译

  

### Sample

```
.
├── vul_stack_prog
|   +--- gcc_data_attack_sa
|   +--- gcc_stack_attack_sa
|   +--- llvm_stack_attack_sa
|   +--- llvm_stack_attack_defense_sa
```

若学不会如何利用`shellcode`以及如何修改目标程序，一直不能成功产生攻击效果，请在`make`后将`vul_stack_prog`中的二进制文件拷贝进`disk0`文件夹，再运行`qemu`，直接运行这些程序即可获得想要的效果

防御成功的现象为：

![1561750057392](C:\Users\Dora\AppData\Roaming\Typora\typora-user-images\1561750057392.png)



> 该仓库或许会持续更新或修复，若本人能够解决实验报告中提到的尚未解决的问题。

