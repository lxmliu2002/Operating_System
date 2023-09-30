<h1><center>lab3实验报告</center></h1>

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
+ `struct trapframe *tf`：保存了进程的中断帧（32个通用寄存器、异常相关的寄存器）。在进程从用户空间跳转到内核空间时，系统调用会改变寄存器的值。我们可以通过调整中断帧来世的系统调用返回特定的值。比如可以利用`s0`和`s1`传递线程执行的函数和参数；在创建子线程时，会将中断帧中的`a0`设为`0`。

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

