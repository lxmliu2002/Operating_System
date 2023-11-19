<h1><center>lab4实验报告</center></h1>

## 练习一

### 代码实现

根据手册里的提示，将`state`设为`PROC_UNINIT`，`pid`设为`-1`，`cr3`设置为`boot_cr3`，其余需要初始化的变量中，指针设为`NULL`，变量设置为`0`，具体实现方式如下：

```c
proc->state = PROC_UNINIT;
proc->pid = -1;
proc->runs = 0;
proc->kstack = 0;
proc->need_resched = 0;
proc->parent = NULL;
proc->mm = NULL;
memset(&(proc->context), 0, sizeof(struct context));
proc->tf = NULL;
proc->cr3 = boot_cr3;
proc->flags = 0;
memset(proc->name, 0, PROC_NAME_LEN + 1);
```

### 问题解答

**成员变量含义和作用：**

+ `struct context context`：保存进程执行的上下文，也就是关键的几个寄存器的值。用于进程切换中还原之前的运行状态。在通过`proc_run`切换到CPU上运行时，需要调用`switch_to`将原进程的寄存器保存，以便下次切换回去时读出，保持之前的状态。
+ `struct trapframe *tf`：保存了进程的中断帧（32个通用寄存器、异常相关的寄存器）。在进程从用户空间跳转到内核空间时，系统调用会改变寄存器的值。我们可以通过调整中断帧来使的系统调用返回特定的值。比如可以利用`s0`和`s1`传递线程执行的函数和参数；在创建子线程时，会将中断帧中的`a0`设为`0`。

## 练习二

### 代码实现

按照实验手册上的流程，逐步调用相关函数，补充各参数。这里额外添加了一些必要的步骤：

+ `proc->parent = current;`：将新线程的父线程设置为`current`
+ `proc->pid = pid;`：将获取的线程`pid`赋给新线程的`pid`
+ `nr_process++;`：线程数量自增1

```c
proc = alloc_proc();
proc->parent = current;
setup_kstack(proc);
copy_mm(clone_flags, proc);
copy_thread(proc, stack, tf);
int pid = get_pid();
proc->pid = pid;
hash_proc(proc);
list_add(&proc_list, &(proc->list_link));
nr_process++;
proc->state = PROC_RUNNABLE;
ret = proc->pid;
```

### 问题解答

`ucore`能做到给每个新`fork`的线程一个唯一的`id`。在这里通过`get_pid`分配`id`，它的原理是对于一个可能分配出去的`last_id`，遍历线程链表，判断是否有`id`与之相等的线程，如果有，则将`last_id`自增1，且保证自增之后不会与当前查询过的线程`id`冲突，并且其不会超过最大的线程数，重新从头开始遍历链表。如果没有，则更新下一个可能冲突的线程`id`。

通过这种算法，只有一个`id`在与所有线程链表中的`id`均不相同时才能分配出去，所以可以做到给每个新`fork`的线程一个唯一的`id`。

## 练习三

### 代码实现

参考`schedule`函数里面的禁止和启用中断的过程，实现如下：

```c
bool intr_flag;
struct proc_struct *prev = current, *next = proc;
local_intr_save(intr_flag);
{
    current = proc;
    lcr3(next->cr3);
    switch_to(&(prev->context), &(next->context));
}
local_intr_restore(intr_flag);
```

### 问题解答

在本实验中创建并运行了两个内核线程：0号线程`idleproc`和1号线程`initproc`。

## 扩展练习

相关定义如下：

```c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);
```

当调用`local_intr_save`时，会读取`sstatus`寄存器，判断`SIE`位的值，如果该位为1，则说明中断是能进行的，这时需要调用`intr_disable`将该位置0，并返回1，将`intr_flag`赋值为1；如果该位为0，则说明中断此时已经不能进行，则返回0，将`intr_flag`赋值为0。以此保证之后的代码执行时不会发生中断。

当需要恢复中断时，调用`local_intr_restore`，需要判断`intr_flag`的值，如果其值为1，则需要调用`intr_enable`将`sstatus`寄存器的`SIE`位置1，否则该位依然保持0。以此来恢复调用`local_intr_save`之前的`SIE`的值。

## 关键知识点

+ 内核线程是一种特殊的进程，内核线程与用户进程的区别有：

  + 内核线程只运行在内核态
  + 用户进程会在内核态和用户态交替运行
  + 所有内核线程共用ucore内存空间，不需要为每个内核线程维护单独的内存空间
  + 而用户进程需要维护各自的用户内存空间

+ 平时所写的源代码，经过编译器编译就变成了可执行文件，这个可执行文件就叫做程序，这个程序被用户或操作系统启动，分配资源，装载进内存开始执行后，它就成为了一个进程 ，进程、程序以及线程的区别如下：

  + 进程：正在运行的实体
    程序：静态的文件
    进程包含程序中的内容，也包括一些在运行时在可以体现出来的信息
  + 只剥离出正在运行的部分，就变成线程，一个进程可以对应多个线程，线程之间往往具有相同的代码，共享一块内存，但是却有不同的 CPU执行状态
  + 在进程资源管理体中，线程是可以被调度的最小单元

+ `kstack`：每个线程都有一个内核栈，运行程序使用的栈

  + 切换进程时，需要根据 `kstack `的值正确的设置好` tss`，以便发生中断使用正确的栈
  + 内核栈位于内核地址空间，并且是不共享的
    + 好处：方便调试，快速定位
    + 不好：不受到` mm `的管理，内核对溢出不敏感
  + 在内存栈里为中断帧分配空间

+ `idleproc`是第0个要创建的线程，表示空闲线程，空闲进程是一个特殊的进程，它的主要目的是在系统没有其他任务需要执行时，占用 CPU 时间，同时便于进程调度的统一化
  `kern_init` 函数调用了` proc.c::proc_init `函数，`proc_init `函数启动了创建内核线程的步骤，在这里面有创建`idleproc`的过程：

  + 初始化进程控制块链表
  + 调用` alloc_proc `函数来通过 `kmalloc `函数获得` proc_struct` 结构的一块内存块，对进程控制块进行初步初始化
  + 进行进一步初始化，其中`idleproc->need_resched = 1`，因为这个线程是一个空闲线程，所以不执行他，调用 schedule 函数要求调度器切换其他进程执行

  第0 个内核线程主要工作是完成内核中各个子系统的初始化

+ 调用用` kernel_thread` 函数来创建`initproc` 内核线程，`kernel_thread` 函数通过调用 `do_fork `函数最终完成了内核线程的创建工作，`do_fork`做的事：

  + 分配线程控制块
  + 分配并初始化内核栈
  + 根据` clone_flags `决定是复制还是共享内存管理系统
  + 设置中断帧和上下文
  + 讲进程加入线程
  + 将新建的进程设为就绪态
  + 将返回值设为线程 id

+ 调度过程：

  + 设置当前内核线程 `current->need_resched` 为 0
  + 在` proc_list `队列中查找下一个处于“就绪”态的线程或进程
  + 找到后，调用` proc_run `函数，将指定的进程切换到 CPU 上运行，使用 switch_to 进行上下文切换

