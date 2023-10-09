<h1><center>lab7实验报告</center></h1>

## 练习一

### 内核级信号量设计描述

内核级信号量的结构如下：

```c
typedef struct {
    int value;
    wait_queue_t wait_queue;
} semaphore_t;
```

它包含两个属性：

+ `value`：该值为正代表可以获取该信号量的线程个数，该值为负代表等待获取该信号量的线程个数
+ `wait_queue`：等待获取该信号量的线程队列

有两个与之相关的方法：

+ `down`：用于线程获取一个信号量，获取资源
+ `up`：用与线程释放资源，从等待队列中唤醒线程获取资源

### 内核级信号量的执行流程

我们将每个哲学家看作一个线程，同时只能有一个哲学家在尝试拿起筷子或者放下筷子，使用信号量`mutex`保证该条件。每个哲学家本身也是一个信号量。

每一个哲学家都要经过四次以下过程：

``` 
思考 -> 拿起筷子 -> 吃饭 -> 放下筷子
```

当一个哲学家需要拿起筷子时，需要获得信号量`mutex`，将自己的状态设置为`HUNGRY`，再尝试获取筷子。如果他的左右邻居都没有在吃饭，则将自己的状态设置为`EATING`（这种情况下该哲学家的信号量的等待队列应为空），释放`mutex`后获取自己的信号量，进入吃饭状态。如果有人在吃饭，那么获取自己的信号量不成功，于是进入等待队列。

当一个哲学家放下筷子时，需要获得信号量`mutex`，将自己的状态设置为`THINKING`，判断左右邻居是否能吃饭。如果可以，则唤醒等待该信号量的进程，使其对应的哲学家进入吃饭状态。

### 为什么不会出现死锁

因为在这里定义了一个信号量`mutex`，保证同时只能有一个哲学家检测是否可以拿起筷子，且每个哲学家都必须在两侧的筷子均空闲的情况下才能拿起筷子，所以不会出现死锁（所有哲学家均拿起一侧的筷子或两个哲学家同时拿起一个筷子）的情况。

### 用户态信号量的设计方案（待完善）

用户态需要维护一个所有线程都能访问的信号量，也就是需要创建一个所有进程共享的地址空间。

## 练习二

### 内核级条件变量设计描述

条件变量的结构体如下：

```c
typedef struct condvar{
    semaphore_t sem;        
    int count;              
    monitor_t * owner;      
} condvar_t;
```

它包含三个属性：

+ `sem`：该条件变量的信号量
+ `count`：等待该条件变量的线程个数
+ `owner`：该条件变量所属的管程

有两个与之相关的方法：

+ `cond_signal`：发送一个条件变量的信号，代表该条件成立，如果有在等待该条件变量的进程，则唤醒该线程，将自己加入`next`的等待队列中，挂起自己的线程
+ `cond_wait`：等待一个条件变量的信号，将自己的线程加入到一个条件变量的信号量的等待队列中，如果`next`的等待队列中有线程，则唤醒其中的线程，否则释放`mutex`，使下一个线程可以进入管程

### 内核级条件变量执行流程

我们将每个哲学家吃饭看作一个线程，这五个哲学家吃饭的过程看作是一个管程，管程里有五个条件变量，分别代表一个哲学家能否吃饭。同时只能有一个哲学家在尝试拿起筷子或者放下筷子，管程中有一个信号量`mutex`用于保证该条件。

每一个哲学家都要经过四次以下过程：

``` 
思考 -> 拿起筷子 -> 吃饭 -> 放下筷子
```

当一个哲学家需要拿起筷子时，需要获得管程的互斥量`mutex`进入管程，将当前状态设置为`HUNGRY`，再尝试获取筷子。如果他的左右邻居都没有获取筷子，则代表他可以吃饭，这个时候他会将自己的状态设置为`EATING`（这种情况下该条件变量对应的信号量的等待队列应为空），之后离开管程；如果他无法吃饭，则会调用`cond_wait`等待自己可以吃饭的信号。离开管程时，会判断是否有线程需要进入管程，如果有，则使下一个线程进入管程；如果没有，则释放`mutex`。

当一个哲学家吃完饭放下筷子后，需要获得管程的互斥量`mutex`进入管程，然后检测左右邻居是否需要并且可以吃饭，若是，则调用`cond_signal`发送一个可以吃饭的信号，使处于`cond_wait`的他们可以吃饭。离开管程时，会判断是否有线程需要进入管程，如果有，则使下一个线程进入管程；如果没有，则释放`mutex`。

### 用户态条件变量的设计



### 能否不基于信号量实现条件变量



## 扩展练习一

通过判断图是否有环来判断是否有死锁。

### 数据结构

图中有两种节点，分别代表线程和信号量：

```c
struct proc_node {
    struct proc_struct* proc;	// 对应的线程
    struct sem_node* wait_sem;	// 线程等待的信号量
    list_entry_t sem_link;		// 持有的信号量对应节点链表
    int visited;
    int help_visited;
    list_entry_t proc_node_link;
};

struct sem_node {
    semaphore_t* sem;			// 对应的信号量
    list_entry_t proc_list;		// 持有该信号量的线程链表
    struct proc_node* proc_node; // 等待该信号量的线程
    int visited;
    int help_visited;
    list_entry_t sem_node_link;
    list_entry_t sem_node_for_proc;
};
```

将这两种节点分别维护一个链表，形成图的结构如下：

```c
struct proc_sem_graph_t {
    list_entry_t proc_nodes;
    list_entry_t sem_ndoes;
};
```

虽然这个图维护的是双向的边，但是遍历只会按照一种方向进行。

### 添加与删除节点

在`proc_struct`种添加属性`sem_link`。

定义两种操作类型：

```c
#define PORC_WAIT_SEM 0	// 线程等待信号量
#define SEM_SUB_PROC 1	// 信号量被线程持有
```

添加节点时，需要分别查找线程和信号量，如果没有则调用`kmalloc`分配新的节点，按照操作类型决定二者之间的指向关系：

```c
void add_link(struct proc_struct* proc, semaphore_t* sem, int type) {
    struct proc_node* procn = NULL, *proc_temp = NULL;
    struct sem_node* semn = NULL, *sem_temp = NULL;
    // 查找链表中是否存在该线程
    list_entry_t* list = &(psgp->proc_nodes), *le;
    le = list;
    while ((le = list_next(le)) != list) {
        proc_temp = le2procnode(le, proc_node_link);
        if(proc_temp == proc) {
            procn = proc_temp;
            break;
        }
    }
    // 查找链表中是否存在该信号量
    list = &(psgp->sem_ndoes);
    le = list;
    while ((le = list_next(le)) != list) {
        sem_temp = le2semnode(le, sem_node_link);
        if(sem_temp == sem) {
            semn = sem_temp;
            break;
        }
    }
    // 如果不存在，新建节点
    if(procn == NULL) {
        procn = kmalloc(sizeof(struct proc_node));
        procn->proc = proc;
        procn->help_visited = 0;
        procn->visited = 0;
        procn->wait_sem = NULL;
        list_init(&(procn->sem_list));
    }
    if(semn == NULL) {
        semn = kmalloc(sizeof(struct sem_node));
        semn->sem = sem;
        semn->visited = 0;
        semn->help_visited = 0;
        semn->proc_node = NULL;
        list_init(&(semn->proc_list));
    }
    if(type == PORC_WAIT_SEM) {
        procn->wait_sem = semn;
        semn->proc_node = procn;
    } 
    else if(type == SEM_SUB_PROC) {
        list_add(&(semn->proc_list), &(proc->sem_link));
        list_add(&(procn->sem_list), &(semn->sem_node_for_proc));
    }
    else{
        panic("insert type erorr\n");
    }
}
```

删除节点时，需要考虑移除节点时的条件：

```c
void remove_link(struct proc_struct* proc, semaphore_t* sem, int type) {
    struct proc_node* procn = NULL;
    struct sem_node* semn = NULL;
    list_entry_t* proc_le, *sem_le;
    // 查找链表中是否存在该线程
    list_entry_t* list = &(psgp->proc_nodes), *le;
    le = list;
    while ((le = list_next(le)) != list) {
        procn = le2procnode(le, proc_node_link);
        if(procn == proc) {
            break;
        }
    }
    proc_le = le;
    assert(procn != NULL);
    
    // 查找链表中是否存在该信号量
    list = &(psgp->sem_ndoes);
    le = list;
    while ((le = list_next(le)) != list) {
        semn = le2semnode(le, sem_node_link);
        if(semn == sem) {
            break;
        }
    }
    assert(semn != NULL);
    sem_le = le;
    if(type == PORC_WAIT_SEM) {
        procn->wait_sem = NULL;
        semn->proc_node = NULL;
        
    } 
    else if(type == SEM_SUB_PROC) {
        list_entry_t* proc_list = &(psgp->proc_nodes), *ple;
        struct proc_struct* temp_proc;
        while ((ple = list_next(ple)) != proc_list) {
            temp_proc = le2proc(ple, sem_link);
            if(temp_proc == proc)
                break;
        }
        list_del(ple);
        list_entry_t* sem_list = &(procn->sem_list), *sle;
        struct sem_node* temp_node;
        while ((sle = list_next(sle)) != sem_list) {
            temp_node = le2semnode(sle, sem_node_for_proc);
            if(temp_node == semn)
                break;
        }
        assert(temp_node != NULL);
        list_del(sle);

        
    }
    else {
        panic("delete tpe error\n");
    }
    if(list_empty(&(procn->sem_list)) && procn->wait_sem == NULL) {
        list_del(proc_le);
        kfree(procn);
    }
    if(list_empty(&(semn->proc_list)) && semn->proc_node == NULL) {
        list_del(le);
        kfree(semn);
    }
}
```

### 判断死锁

遍历图，使用DFS判断图中是否有环：



## 扩展练习二

RCU的思想是在读一个变量时加上RCU读锁，不阻塞其他线程；在需要写该变量时会将该变量复制一份并在复制的内存中修改，为分配一个新的指针指向修改后的内容，在所有读的线程释放读锁之后将旧的指针替换为新的指针。

需要实现的方法如下：

```c
void rcu_read_lock();   // 加读锁
void rcu_read_unlock(); // 释放读锁
void syncronize_rcu();  // 挂起写者，等待读者退出后修改数据
void* rcu_assign_pointer(); // 读者获取一个被RCU保护的指针
void* rcu_dereference();    // 写者为RCU保护的指针分配一个新的值
```

### 具体内容待实现

