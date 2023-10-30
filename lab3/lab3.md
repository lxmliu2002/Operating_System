<h1><center>lab3实验报告</center></h1>

## 练习一

当需要换入页面时，需要调用`swap.c`文件中的`swap_in`。

+ `swap_in`：用于换入页面。首先调用`pmm.c`中的`alloc_page`，申请一块连续的内存空间，然后调用`get_pte`找到或者构建对应的页表项，最后调用`swapfs_read`将数据从磁盘写入内存。
+ `alloc_page`：用于申请页面。通过调用`pmm_manager->alloc_pages`申请一块连继续的内存空间，在这个过程中，如果申请页面失败，那么说明需要换出页面，则调用`swap_out`换出页面，之后再次进行申请。
+ `assert(result!=NULL)`：判断获得的页面是否为`NULL`，只有页面不为`NULL`才能继续。
+ `swap_out`：用于换出页面。首先需要循环调用`sm->swap_out_victim`，对应于`swap_fifo`中的`_fifo_swap_out_victim`。然后调用`get_pte`获取对应的页表项，将该页面写入磁盘，如果写入成功，释放该页面；如果写入失败，调用`_fifo_map_swappable`更新FIFO队列。最后刷新TLB。
  + `free_page`：用于释放页面。通过调用`pmm_manager->free_pages`释放页面。
  + `assert((*ptep & PTE_V) != 0);`：用于判断获得的页表项是否合法。由于这里需要交换出去页面，所以获得的页表项必须是合法的。
  + `swapfs_write`：用于将页面写入磁盘。在这里由于需要换出页面，而页面内容如果被修改过那么就与磁盘中的不一致，所以需要将其重新写回磁盘。
  + `tlb_invalidate`：用于刷新TLB。通过调用`flush_tlb`刷新TLB。
+ `get_pte`：用于获得页表项。
+ `swapfs_read`：用于从磁盘读入数据。
+ `_fifo_swap_out_victim`：用于获得需要换出的页面。查找队尾的页面，作为需要释放的页面。
+ `_fifo_map_swappable`：将最近使用的页面添加到队头。在`swap_out`中调用是用于将队尾的页面移动到队头，防止下一次换出失败。

该页面移动到了链表的末尾时，在下一次有页面换入的时候需要被换出。当需要换出页面时，需要调用`swap.c`文件中的`swap_out`，后续的方法在上面已经给出。

## 练习二

+ **相似的原因**：两者都旨在获取虚拟地址对应的页表项，并在需要时创建新的page以及页表项。第一段代码用于从`GiGa Page`中查找`PDX1`的地址，如果查得的地址不合法则为该页表项分配内存空间；第二段代码用于从`MeGa Page`中查找`PDX0`的地址，如果查得的地址不合法则为该页表项分配内存空间。两次查找的逻辑相同，不同的只有查找的基地址与页表偏移量所在位数。而三种页表管理机制只是虚拟页表的地址长度或页表的级数不同，规定好偏移量即可按照同一规则找出对应的页表项。
+ 这种写法好。因为在大部分情况下，我们只有在获取页表非法的情况下才会创建页表，而且我们也只关心最后一级页表所给出的页，合在一起减少了代码重复和函数调用的开销及深度，使代码更简洁。

## 练习三

- **设计实现过程**：

  + `swap_in(mm,addr,&page)`：首先需要根据页表基地址和虚拟地址完成磁盘的读取，写入内存，返回内存中的物理页。

  + `page_insert(mm->pgdir,page,addr,perm)`：然后完成虚拟地址和内存中物理页的映射。
  + `swap_map_swappable(mm,addr,page,0)`：最后设置该页面是可交换的。

+ **潜在用处**：页目录项和页表项中的合法位可以用来判断该页面是否存在，还有一些其他的权限位，比如可读可写，可以用于CLOCK算法或LRU算法。修改位可以决定在换出页面时是否需要写回磁盘。
+ **页访问异常**：trap--> trap_dispatch-->pgfault_handler-->do_pgfault
  + 首先保存当前异常原因，根据`stvec`的地址跳转到中断处理程序，即`trap.c`文件中的`trap`函数。
  + 接着跳转到`exception_handler`中的`CAUSE_LOAD_ACCESS`处理缺页异常。
  + 然后跳转到`pgfault_handler`，再到`do_pgfault`具体处理缺页异常。
  + 如果处理成功，则返回到发生异常处继续执行。
  + 否则输出`unhandled page fault`。
+ **对应关系**：有对应关系。如果页表项映射到了物理地址，那么这个地址对应的就是`Page`中的一项。`Page` 结构体数组的每一项代表一个物理页面，并且可以通过页表项间接关联。页表项存储物理地址信息，这可以用来索引到对应的 `Page` 结构体，从而允许操作系统管理和跟踪物理内存的使用。

## 练习四

- **设计实现过程**：

  + 初始化需要初始化链表、当前节点指针和`mm`的成员`sm_priv`指针：

    ```c
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;
    mm->sm_priv = &pra_list_head;
    ```

  + 设置页面可交换，表示当前页面正要被使用，需要将其添加到链表尾部并设置`visited`：

    ```c
    list_add_before((list_entry_t*) mm->sm_priv,entry);
    page->visited = 1;
    ```

  + 遍历链表，如果下一个指针是`head`，则将其指向为下一个指针。如果依然是`head`，说明该链表为空，返回`NULL`，否则构造页面，判断是否最近被使用过，如果没有则重置`visited`，直到找到一个`visited = 0`的页面为止。

    ```c
    curr_ptr = list_next(curr_ptr);
    if(curr_ptr == head) {
        curr_ptr = list_next(curr_ptr);
        if(curr_ptr == head) {
            *ptr_page = NULL;
            break;
        }
    }
    struct Page* page = le2page(curr_ptr, pra_page_link);
    if(!page->visited) {
        *ptr_page = page;
        list_del(curr_ptr);
        cprintf("curr_ptr %p\n",curr_ptr);
        //curr_ptr = head;
        break;
    } else {
        page->visited = 0;
    }
    ```

- **不同：**

  + Clock算法：每次添加新页面时会将页面添加到链表尾部。每次换出页面时都会遍历查找最近没有使用的页面。

  + FIFO算法：将链表看成队列，每次添加新页面会将页面添加到链表头部（队列尾部）。每次换出页面时不管队头的页面最近是否访问，均将其换出。

## 练习五

+ **优势**：内存访问次数少，只需要访问一次内存即可得到物理地址； 可以映射更多的连续内存空间；减少 TLB 缺失；简化操作系统的页表管理。
+ **劣势**：页表项必须连续，占用内存过大； 使用大页可能导致内部碎片；不适用于小内存系统；可能需要更多的页表维护工作。

## 扩展练习

### 设计思路

将新加入的页面或刚刚访问的页插入到链表头部，这样每次换出页面时只需要将链表尾部的页面取出即可。

为了知道访问了哪个页面，可以在建立页表项时将每个页面的权限全部设置为不可读，这样在访问一个页面的时候会引发缺页异常，将所有页的页表项的权限设置为不可读，之后将该页放到链表头部，设置页面为可读。

### 代码实现

在`do_pgfault`中添加如下代码：

```c
pte_t* temp = NULL;
temp = get_pte(mm->pgdir, addr, 0);
if(temp != NULL && (*temp & (PTE_V | PTE_R))) {
    return lru_pgfault(mm, error_code, addr);
}
```

在为`perm`设置完权限之后，移除读权限：

```c
perm &= ~PTE_R;
```

`lru`的异常处理部分：

```c
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    cprintf("lru page fault at 0x%x\n", addr);
    // 设置所有页面不可读
    if(swap_init_ok) 
        unable_page_read(mm);
    // 将需要获得的页面设置为可读
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
    *ptep |= PTE_R;
    if(!swap_init_ok) 
        return 0;
    struct Page* page = pte2page(*ptep);
    // 将该页放在链表头部
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
    while ((le = list_prev(le)) != head)
    {
        struct Page* curr = le2page(le, pra_page_link);
        if(page == curr) {
            
            list_del(le);
            list_add(head, le);
            break;
        }
    }
    return 0;
}
```

设置所有页面不可读，原理是遍历链表，转换为`page`，根据`pra_vaddr`获得页表项，设置不可读：

```c
static int
unable_page_read(struct mm_struct *mm) {
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
    while ((le = list_prev(le)) != head)
    {
        struct Page* page = le2page(le, pra_page_link);
        pte_t* ptep = NULL;
        ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
        *ptep &= ~PTE_R;
    }
    return 0;
}
```

其余部分与`FIFO`算法差异不大，罗列如下：

```c
static int
_lru_init_mm(struct mm_struct *mm)
{     

    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    list_add((list_entry_t*) mm->sm_priv,entry);
    return 0;
}
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}
```

### 测试

设计额外的测试如下：

```c
static void
print_mm_list() {
    cprintf("--------begin----------\n");
    list_entry_t *head = &pra_list_head, *le = head;
    while ((le = list_next(le)) != head)
    {
        struct Page* page = le2page(le, pra_page_link);
        cprintf("vaddr: %x\n", page->pra_vaddr);
    }
    cprintf("---------end-----------\n");
}
static int
_lru_check_swap(void) {
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    return 0;
}
```

与测试有关的测试结果如下：

```c
set up init env for check_swap over!
--------begin----------
vaddr: 0x4000
vaddr: 0x3000
vaddr: 0x2000
vaddr: 0x1000
---------end-----------
write Virt Page c in lru_check_swap
Store/AMO page fault
page fault at 0x00003000: K/W
lru page fault at 0x3000
--------begin----------
vaddr: 0x3000
vaddr: 0x4000
vaddr: 0x2000
vaddr: 0x1000
---------end-----------
write Virt Page a in lru_check_swap
Store/AMO page fault
page fault at 0x00001000: K/W
lru page fault at 0x1000
--------begin----------
vaddr: 0x1000
vaddr: 0x3000
vaddr: 0x4000
vaddr: 0x2000
---------end-----------
write Virt Page b in lru_check_swap
Store/AMO page fault
page fault at 0x00002000: K/W
lru page fault at 0x2000
--------begin----------
vaddr: 0x2000
vaddr: 0x1000
vaddr: 0x3000
vaddr: 0x4000
---------end-----------
write Virt Page e in lru_check_swap
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
Store/AMO page fault
page fault at 0x00005000: K/W
lru page fault at 0x5000
--------begin----------
vaddr: 0x5000
vaddr: 0x2000
vaddr: 0x1000
vaddr: 0x3000
---------end-----------
write Virt Page b in lru_check_swap
Store/AMO page fault
page fault at 0x00002000: K/W
lru page fault at 0x2000
--------begin----------
vaddr: 0x2000
vaddr: 0x5000
vaddr: 0x1000
vaddr: 0x3000
---------end-----------
write Virt Page a in lru_check_swap
Store/AMO page fault
page fault at 0x00001000: K/W
lru page fault at 0x1000
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x5000
vaddr: 0x3000
---------end-----------
write Virt Page b in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x5000
vaddr: 0x3000
---------end-----------
write Virt Page c in lru_check_swap
Store/AMO page fault
page fault at 0x00003000: K/W
lru page fault at 0x3000
--------begin----------
vaddr: 0x3000
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x5000
---------end-----------
write Virt Page d in lru_check_swap
Store/AMO page fault
page fault at 0x00004000: K/W
swap_out: i 0, store page in vaddr 0x5000 to disk swap entry 6
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
Store/AMO page fault
page fault at 0x00004000: K/W
lru page fault at 0x4000
--------begin----------
vaddr: 0x4000
vaddr: 0x3000
vaddr: 0x1000
vaddr: 0x2000
---------end-----------
write Virt Page e in lru_check_swap
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
Store/AMO page fault
page fault at 0x00005000: K/W
lru page fault at 0x5000
--------begin----------
vaddr: 0x5000
vaddr: 0x4000
vaddr: 0x3000
vaddr: 0x1000
---------end-----------
write Virt Page a in lru_check_swap
Load page fault
page fault at 0x00001000: K/R
lru page fault at 0x1000
--------begin----------
vaddr: 0x1000
vaddr: 0x5000
vaddr: 0x4000
vaddr: 0x3000
---------end-----------
```

可以看到每次访问页面时都会产生缺页异常，将该页面添加到链表头部，需要移除页面时都从链表尾部删除页面。

## 知识点补充

+ 虚拟内存管理：**虚拟内存是程序员和CPU访问的地址**，不是所有的虚拟地址都有对应的物理地址，若有，则地址不相等
  物理地址->虚拟地址：内存地址虚拟化的过程
  通过设置页表项来限定软件运行时的访问空间，（有些虚拟地址不对应物理地址），确保软件运行不越界，完成**内存访问保护功能**
  建立虚拟内存到物理内存的页映射关系——**按需分页**把不经常访问的数据写入磁盘上（放入虚拟空间中），用到时在读入内存中——**页的换入与换出**

+ 整个实验以ucore的总控函数init为起点

  + 物理内存管理初始化：调用pmm_init函数
  + 执行中断和异常相关初始化工作：调用pic_init函数和idi_init函数
  + 虚拟内存管理初始化：调用vmm_init函数（主要建立虚拟地址到物理地址的映射关系）
  + 对用于页面换入换出磁盘（成为swap磁盘）的初始化工作
  + 初始化页面置换算法：调用swap_init函数

+ 我们要明确的是，**qemu这个模拟器并没有模拟硬盘**，而在这个实验里，我们要用到硬盘来进行对页进行换入与换出，所以我们可以**取出内存中的一小块空间当作硬盘**，本来硬盘与内存的区别就是一个非易失、一个易失，一个访问慢一个访问快，其实没啥区别

+ 实现页面映射，要实现两个接口：

  + page_insert（）：在页表里增加一个映射
  + page_remove（）：在页表里删除一个映射

  均在`kern/mm/pmm.c`中实现：

  + 建立映射关系
  + 新增一个映射关系和删除一个映射关系

  一个程序通常包含以下几段：

  + .text段：可读、可执行、不可写
  + .rodata段：只读、不可写、不可执行
  + .data段：存放初始化后的数据，可读、可写
  + .bss段：存放经过零初始化后的数据，可读、可写

+ 页面置换算法：

  + FIFO（先进先出）：淘汰最先进入内存的页
    把一个应用程序在执行过程中已调入内存的页按先后次序链接成一个队列，这样需要淘汰页时，从队列头很容易查找到需要淘汰的页
    FIFO 算法只是在**应用程序按线性顺序访问地址空间时效果才好**，否则效率不高。
    它有一种异常现象（**Belady 现象**），即在增加放置页的物理页帧的情况下，反而使页访问异常次数增多。
  + LRU（最近未被使用）
  + Clock页替换算法：
    把各个页面组织成环形链表的形式，然后把一个指针（简称当前指针）指向最先进来的一个页面，
    时钟算法需要在页表项（PTE）中**设置了一位访问位**来表示此页表项对应的页当前**是否被访问过**
    该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”
    当操作系统需要淘汰页时，对当前指针指向的所对应的页表项进行查询，若访问位为0，则淘汰，若为1，则要置零，继续访问下一个页
  + 改进的时钟页替换算法：增加一位引用位和一位修改位
    当该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”。当该页被“写”时，CPU 中的 MMU 硬件将把修改位置“1”
