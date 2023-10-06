<h1><center>lab6实验报告</center></h1>

## 练习零

在`alloc_proc`中添加初始化

```c
proc->rq = NULL;
list_init(&(proc->run_link));
proc->time_slice = 0;
skew_heap_init(&(proc->lab6_run_pool));
proc->lab6_stride = 0;
proc->lab6_priority = 0;
```

这里的`lab6_priority`由于之后设置该值都是通过`lab6_set_priority`，如果该值为0则直接置1，所以这里设置为0即可。

## 练习一

### 比较函数

原函数：

```c
void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
        }
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}

```

改动后的函数

```c
void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
                sched_class_enqueue(proc);
            }
        }
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
```

改动之后多了将线程入调度队列的步骤。在这之前是遍历整个线程链表进行调度。如果没有这个步骤，就无法对线程进行调度。

### 函数指针的用法

+ `void (*init)(struct run_queue *rq);`：用于初始化一个调度器
+ `void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);`：用于将线程加入线程调度的队列
+ `void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);`：用于从线程调度队列中删除一个线程
+ `struct proc_struct *(*pick_next)(struct run_queue *rq);`：用于选择下一个调度的线程
+ `void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);`：用于更新一个线程的时间片

### 线程调度方法

每次调度时，如果当前线程已经准备就绪，则将其加入到线程的调度队列的末尾，并从队头中取出一个线程执行。在每次中断的时候会将当前线程的时间片减一，如果当前线程的时间片已耗尽，则会将其标识为需要调度，之后会调用`shedule`将其重新入队并设置时间片，取出另一个线程继续执行。

### 函数指针调用

+ 在初始化调度器时，会调用`init`函数指针初始化调度
+ 在每次调度时，如果当前线程状态为`PROC_RUNNABLE`，就会调用`enqueue`函数指针将其入队
+ 在每次调度时，会调用`pick_next`选择下个一执行的线程，调用`dequeue`将其出队
+ 在每次时钟中断时，会调用`proc_tick`函数指针，更新当前线程的时间片

## 练习二

当一个优先级较低的线程的运行一次时，该线程的`stride`会更新为一个较高的数值，而优先级较高的线程在`stride`比这个数低时会一直执行。而如果它也想达到这个数，由于它的步进值较低，所以需要执行的次数大于优先级低的线程。

由于步进值与线程优先级成反比，所以前进相同的距离所需的执行次数（时间片数）与优先级成正比，所以在经过足够多的时间片之后，每个进程分配到的时间片数目和优先级成正比。

## 扩展练习一

原版的CFS调度算法是用红黑树查找最小的虚拟运行时间，在这里仅做简单实现，使用优先队列作为调度队列的存储方式。

### 实际运行时间的计算

在原本的计算公式中：

```
 实际运行时间 = 调度周期 * 当前进程权重 / 所有进程权重总和
```

在这里为了和当前的体系适配，我们使用如下公式计算每个线程分配的时间片：

```c
实际运行时间片 = 调度时间片数量 * 当前进程权重 / 所有进程权重总和
```

这里的调度周期被我们改为分配的时间片数量，我们将其定义为：

```c
rq->max_time_slice * SCHEDULE_PERIOD
```

其中`SCHEDULE_PERIOD`的定义如下：

```c
#define SCHEDULE_PERIOD 10
```

我们还需要定义一个优先级权重的数组：

```c
const int sched_prio_to_weight[40] = {
 /* -20 */     88761,     71755,     56483,     46273,     36291,
 /* -15 */     29154,     23254,     18705,     14949,     11916,
 /* -10 */      9548,      7620,      6100,      4904,      3906,
 /*  -5 */      3121,      2501,      1991,      1586,      1277,
 /*   0 */      1024,       820,       655,       526,       423,
 /*   5 */       335,       272,       215,       172,       137,
 /*  10 */       110,        87,        70,        56,        45,
 /*  15 */        36,        29,        23,        18,        15,
}; 
```

为`rq`添加一个属性`total_weight`用于记录所有线程权重之和。

### 虚拟时间的计算

首先需要定义基准的权重：

```c
#define NICE_0_LOAD 1024
```

计算虚拟时间的公式为：

```c
 vruntime = 调度周期 * 1024 / 所有进程总权重
```

我们将其改为：

```
vruntime = 调度时间片数量 * 1024 / 所有进程总权重
```

为了尽量减少改动，我们使用`lab6_stride`来记录这里的`vruntime`。

### 代码实现

在`stride`调度算法的基础上，我们进行如下改动：

+ 在初始化的过程中，增加对线程总权重的初始化：

  ```c
  static void
  CFS_init(struct run_queue *rq) {
      list_init(&(rq->run_list));
      rq->lab6_run_pool = NULL;
      rq->proc_num = 0;
      rq->total_weight = 0;
  }
  ```

+ 在入队时，我们修改了增加时间片的公式，且确保其至少为1：

  ```c
  static void
  CFS_enqueue(struct run_queue *rq, struct proc_struct *proc) {
      assert(list_empty(&(proc->run_link)));
      rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
      list_add_before(&(rq->run_list), &(proc->run_link));
      int proc_weight = sched_prio_to_weight[proc->lab6_priority];
      rq->total_weight += proc_weight;
      if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice * SCHEDULE_PERIOD) {
          proc->time_slice = rq->max_time_slice * SCHEDULE_PERIOD * proc_weight / rq->total_weight;
          if(proc->time_slice < 1)
              proc->time_slice = 1;
      }
      proc->rq = rq;
      rq->proc_num ++;
  }
  ```

+ 在出队时，需要更新总权重：

  ```c
  static void
  CFS_dequeue(struct run_queue *rq, struct proc_struct *proc) {
      assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
      rq->lab6_run_pool =  skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
      list_del_init(&(proc->run_link));
      rq->proc_num --;
      rq->total_weight -= sched_prio_to_weight[proc->lab6_priority];
  }
  ```

+ 在选择下一个线程时，我们更新了计算`stride`的公式，且确保其至少增加1：

  ```c
  static struct proc_struct *
  CFS_pick_next(struct run_queue *rq) {
      if(rq->lab6_run_pool == NULL)
          return NULL;
      struct proc_struct* proc = le2proc(rq->lab6_run_pool, lab6_run_pool);
      uint32_t step = rq->max_time_slice * SCHEDULE_PERIOD * NICE_0_LOAD / rq->total_weight;
      if(step < 1)
          step = 1;
      proc->lab6_stride += step;
      return proc;
  }
  ```

### 运行输出

实际运行输出如下：

```c
kernel_execve: pid = 2, name = "priority".
Breakpoint
set priority to 6
main: fork ok,now need to wait pids.
set priority to 5
set priority to 4
set priority to 3
set priority to 2
set priority to 1
child pid 5, acc 748000, time 2010
child pid 6, acc 476000, time 2010
child pid 7, acc 408000, time 2010
child pid 3, acc 1612000, time 2010
child pid 4, acc 936000, time 2020
main: pid 3, acc 1612000, time 2020
main: pid 4, acc 936000, time 2020
main: pid 5, acc 748000, time 2020
main: pid 6, acc 476000, time 2020
main: pid 0, acc 408000, time 2020
main: wait pids over
stride sched correct result: 1 1 0 0 0
all user-mode processes have quit.
init check memory pass.
kernel panic at kern/process/proc.c:491:
    initproc exit.
```

## 扩展练习二

