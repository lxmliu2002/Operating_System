<h1><center>lab8实验报告</center></h1>

## 练习零

在`alloc_proc`中添加初始化：

```c
proc->filesp = NULL;
```

在`proc_run`中修改如下：

```c
bool intr_flag;
struct proc_struct *prev = current, *next = proc;
local_intr_save(intr_flag);
{
    current = proc;
    lcr3(next->cr3);
    flush_tlb();
    switch_to(&(prev->context), &(next->context));
}
local_intr_restore(intr_flag);
```

## 练习一

该部分需要分为三部分分别进行读取：起始块、中间块和末尾块。

### 起始块

当起始的偏移量不是`SFS_BLKSIZE`的倍数时，该块不需要全部读取，所以在使用`sfs_bmap_load_nolock`获取`ino`之后，使用`sfs_buf_op`从指定位置读取指定大小的数据，更新`alen`：

```c
blkoff = offset % SFS_BLKSIZE;
if(blkoff != 0) {
    size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
    ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino);
    if(ret != 0) goto out;
    ret = sfs_buf_op(sfs, buf, size, ino, blkoff);
    if(ret != 0) goto out;
    alen += size;
    buf += size;
    if(nblks == 0)
        goto out;
    blkno++;
    nblks--;
}
```

为了方便后续的处理，在读取完成之后，作如下处理：

+ 将`buf`指针向后移动`size`个字节，代表下一次读取或写入的缓冲区
+ `blkno`自增，代表下一块需要读取或写入的块号
+ `nblks`减1，代表剩余需要读取或写入的块数

### 中间块

中间的块都是连续读取的，所以可以直接使用`sfs_block_op`连续读取若干块，读取完毕之后也要更新相关变量：

```c
if(nblks > 0) {
    ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino);
    if(ret != 0) goto out;
    ret = sfs_block_op(sfs, buf, blkno, nblks);
    if(ret != 0) goto out;
    alen += nblks * SFS_BLKSIZE;
    buf += nblks * SFS_BLKSIZE;
    blkno += nblks;
    nblks = 0;
}
```

### 末尾块

当结束的偏移量不是`SFS_BLKSIZE`的整数倍时，与起始块一样需要使用`sfs_buf_op`读取：

```c
size = endpos % SFS_BLKSIZE;
if(size != 0) {
    ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino);
    if(ret != 0) goto out;
    ret = sfs_buf_op(sfs, buf, size, ino, 0);
    if(ret != 0) goto out;
    alen += size;
}
```

## 练习二

在本次实验中主要做的修改分为下面几个部分。

### `elf`
在原本的程序中，`elf`的定义为：

```c
struct elfhdr *elf = (struct elfhdr*)binary;
```

由于在此处需要从磁盘中读取文件，所以需要根据`fd`获取`elf`头部的内容：

```c
struct elfhdr __elf, *elf = &__elf;
load_icode_read(fd, (void*)elf, sizeof(struct elfhdr), 0);
```

这里是定义了变量`__elf`，再为指针`elf`赋值，这种方式写可以省去`kmalloc`再`kfree`的步骤。

### `ph`
在原的程序中，`ph`的定义如下：

```c
struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
```

这里可以发现与起始位置的偏移是`elf->e_phoff`，后面需要对`ph`进行遍历，于是可以改写为

```c
struct proghdr __ph, * ph = &__ph;
for (ph_index = 0; ph_index < elf->e_phnum; ph_index ++) {
//(3.4) find every program section headers
    off_t ph_off = elf->e_phoff + sizeof(struct proghdr) * ph_index;
    load_icode_read(fd, (void*)ph, sizeof(struct proghdr), ph_off);
    // ...
}
```

### 读取文件内容

读取文件内容使用

```c
load_icode_read(fd, page2kva(page) + off, size, total_off);
```

### 关闭文件

由于在`do_execve`中打开了文件，所以需要在这里关闭文件：

```c
sysfile_close(fd);
```

### 设置参数

+ 在计算长度时需要考虑每一个字符串末尾的`\0`。
+ 由于用户函数执行需要参数`argc`和`argv`，所以需要在用户的栈中加入这两个参数，其中`argc`在`argv`之上。而`argv`中的每一项都需要从内核内存空间中拷贝到用户内存空间中，所以需要在栈中也为他们预留空间。

```c
uint32_t argv_size=0, i;
for (i = 0; i < argc; i ++) {
    argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
}

uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
char** uargv=(char **)(stacktop  - argc * sizeof(char *));

argv_size = 0;
for (i = 0; i < argc; i ++) {
    uargv[i] = strcpy((char *)(stacktop + argv_size ), kargv[i]);
    argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
}

stacktop = (uintptr_t)uargv - sizeof(int);
*(int *)stacktop = argc;
```

最后还需要更新栈顶：

```c
tf->gpr.sp = stacktop;
```

## 扩展练习一

### 数据结构和接口

管道的结构体定义如下：

```c
struct pipe_t {
    semaphore_t sem;	// 信号量
    off_t start;	// 数据起始偏移
    off_t end;		// 数据终点偏移
    size_t len;		// 数据长度
    condvar_t write;// 条件变量
    condvar_t read; // 条件变量
}
```

接口定义如下：

```c
void pipe_create(uint32_t* ino);
int pipe_read(void* buf, size_t len);
int pipe_write(void* buf, size_t len);
void pipe_delete(uint32_t* ino);
```

### 设计方案

管道用于两个线程之间的通信，我们使用一个临时的 VFS 索引节点作为管道。

在这里我们先定义一个宏`PIPE_SIZE`，设计为`PIPE`的最大容量。将`PIPE`设计为环形的结构，当写到管道尾部时继续向管道头部写入。

+ 在创建管道时，需要新建一个临时的索引节点。
+ 在写入数据的过程中，需要首先获取该结构的信号量`sem`。写入的长度为`len`，写入的数据为`buf`，如果写入的长度大于管道中剩余的长度，则挂起当前线程，等待条件变量`read`。写入完成，会发送条件变量`write`。最后释放`sem` 。
+ 在读取数据的过程中，需要首先获取该结构的信号量`sem`。读取的长度为`len`，读取的数据放到`buf`中，如果读取的长度大于管道中数据的长度，则挂起当前线程，等待条件变量`waite`。读取完成，会发送条件变量`read`。最后释放`sem` 。
+ 当所有线程管道操作完成之后，删除该索引节点。

## 扩展练习二

+ 软连接会增加一个`inode`，通过这个节点找到相应的文件路径，再去找源文件的`inode`
+ 硬连接相当于一个指针，指向他的目的文件的`inode`

### 数据结构和接口

接口如下:

```c
void create_soft_link(char* target, char* src);
void remove_soft_link(char* path);
void create_hard_link(char* target, char* src);
void remove_hard_link(char* path);
```

###  设计方案

+ 创建软连接，参数为目标路径和源路径，通过`vop_lookup`解析路径，新建一个`inode`节点，在目标地址新建一个`file`，将其指向该节点，内容为源路径，将其指向源地址的`inode`节点
+ 移除软连接，参数为软连接的路径，移除`inode`节点
+ 创建硬连接，参数为目标路径和源路径，通过`vop_lookup`解析路径，在目标地址新建一个`file`，文件内容为源路径
+ 移除硬连接，参数为硬连接的路径，删除该文件

