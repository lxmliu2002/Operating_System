<h1><center>lab0.5实验报告</center></h1>

## 一、实验过程

使用`make gdb`调试，输入指令`x/10i $pc`查看接下来执行的10条指令，其中在地址为`0x1010`的指令处会跳转，故实际执行的为以下指令：

```assembly
0x1000:      auipc   t0,0x0     # t0 = pc + 0 << 12 = 0x1000
0x1004:      addi    a1,t0,32   # a1 = t0 + 32 = 0x1020
0x1008:      csrr    a0,mhartid # a0 = mhartid = 0
0x100c:      ld      t0,24(t0)  # t0 = [t0 + 24] = 0x80000000
0x1010:      jr      t0		    # 跳转到地址0x80000000
```

输入`si`单步执行，使用形如`info r t0`的指令查看涉及到的寄存器结果。

之后会跳转到地址`0x80000000`处继续执行。该地址处加载的是作为bootloader的`OpenSBI.bin`，该处的作用为加载操作系统内核并启动操作系统的执行。部分代码如下：

```assembly
0x80000000:  csrr    a6,mhartid
0x80000004:  bgtz    a6,0x80000108
0x80000008:  auipc   t0,0x0
0x8000000c:  addi    t0,t0,1032
......
```

接着输入指令`break kern_entry`，输出如下：

```assembly
Breakpoint 1 at 0x80200000: file kern/init/entry.S, line 7.
```

地址`0x80200000`由`kernel.ld`中定义的`BASE_ADDRESS`（加载地址）所决定，标签`kern_entry`是在`kernel.ld`中定义的`ENTRY`（入口点）

`kernel_entry`标志的汇编代码及解释如下：

+  `la sp, bootstacktop`：将`bootstacktop`的地址赋给`sp`，作为栈
+ `tail kern_init`：尾调用，调用函数`kern_init`

输入指令`x/5i 0x80200000`，查看汇编代码：

```assembly
0x80200000 <kern_entry>:     auipc   sp,0x3
0x80200004 <kern_entry+4>:   mv      sp,sp
0x80200008 <kern_entry+8>:   j       0x8020000c <kern_init>
0x8020000c <kern_init>:      auipc   a0,0x3
0x80200010 <kern_init+4>:    addi    a0,a0,-4
```

可以看到在`kern_entry`之后，紧接着就是`kern_init`

输入`continue`，debug输出如下：

```
OpenSBI v0.4 (Jul  2 2019 11:53:53)
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name          : QEMU Virt Machine
Platform HART Features : RV64ACDFIMSU
Platform Max HARTs     : 8
Current Hart           : 0
Firmware Base          : 0x80000000
Firmware Size          : 112 KB
Runtime SBI Version    : 0.1

PMP0: 0x0000000080000000-0x000000008001ffff (A)
PMP1: 0x0000000000000000-0xffffffffffffffff (A,R,W,X)
```

这说明OpenSBI此时已经启动。

接着输入指令`break kern_init`，输出如下：

```assembly
Breakpoint 2 at 0x8020000c: file kern/init/init.c, line 8.
```

这里就指向了之前显示为`<kern_init>`的地址`0x8020000c`

> 补充一些寄存器：
>
> + `ra`：返回地址
> + `sp`：栈指针
> + `gp`：全局指针
> + `tp`：线程指针

输入`continue`，接着输入`disassemble kern_init`查看反汇编代码：

```assembly
0x000000008020000c <+0>:     auipc   a0,0x3
0x0000000080200010 <+4>:     addi    a0,a0,-4 # 0x80203008
0x0000000080200014 <+8>:     auipc   a2,0x3
0x0000000080200018 <+12>:    addi    a2,a2,-12 # 0x80203008
0x000000008020001c <+16>:    addi    sp,sp,-16
0x000000008020001e <+18>:    li      a1,0
0x0000000080200020 <+20>:    sub     a2,a2,a0
0x0000000080200022 <+22>:    sd      ra,8(sp)
0x0000000080200024 <+24>:    jal     ra,0x802004ce <memset>
0x0000000080200028 <+28>:    auipc   a1,0x0
0x000000008020002c <+32>:    addi    a1,a1,1208 # 0x802004e0
0x0000000080200030 <+36>:    auipc   a0,0x0
0x0000000080200034 <+40>:    addi    a0,a0,1232 # 0x80200500
0x0000000080200038 <+44>:    jal     ra,0x80200058 <cprintf>
0x000000008020003c <+48>:    j       0x8020003c <kern_init+48>
```

可以看到这个函数最后一个指令是`j 0x8020003c <kern_init+48>`，也就是跳转到自己，所以代码会在这里一直循环下去。

输入`continue`，debug窗口出现以下输出：

```
(THU.CST) os is loading ...


```

## 二、练习1回答

1. RISCV加电后的指令在地址`0x1000`到地址`0x1010`。
2. 完成的功能如下：
   + `auipc t0,0x0`：用于加载一个20bit的立即数，`t0`中保存的数据是`(pc)+(0<<12)`。用于PC相对寻址。

   + `addi a1,t0,32`：将`t0`加上`32`，赋值给`a1`。

   + `csrr a0,mhartid`：读取状态寄存器`mhartid`，存入`a0`中。`mhartid`为正在运行代码的硬件线程的整数ID。

   + `ld t0,24(t0)`：双字，加载从`t0+24`地址处读取8个字节，存入`t0`。

   + `jr t0`：寄存器跳转，跳转到寄存器指向的地址处（此处为`0x80000000`）。

## 三、本实验重要知识点（待补充）

+ 程序执行流程：加电，从`0x1000`开始执行->跳转到`0x80000000`，启动`OpenSBI`->跳转到`0x80200000`，运行`kern_entry`(`kern/init/entry.S`)->进入`kern_init()`函数(`kern_init/init.c`)->调用`cprintf()`输出一行信息->进入循环
+ `kernel.ld`的链接
+ `entry.S`的含义（内存布局）
