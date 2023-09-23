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

+ **相似的原因**：第一段代码用于从`GiGa Page`中查找`PDX1`的地址，如果查得的地址不合法则为该页表项分配内存空间；第二段代码用于从`MeGa Page`中查找`PDX0`的地址，如果查得的地址不合法则为该页表项分配内存空间。两次查找的逻辑相同，不同的只有查找的基地址与页表偏移量所在位数。而三种页表管理机制只是虚拟页表的地址长度或页表的级数不同，规定好偏移量即可按照同一规则找出对应的页表项。
+ 这种写法好。因为在大部分情况下，我们只有在获取页表非法的情况下才会创建页表，而且我们也只关心最后一级页表所给出的页，合在一起可以减少函数的调用深度。

## 练习三

- **设计实现过程**：

  + `swap_in(mm,addr,&page)`：首先需要根据页表基地址和虚拟地址完成磁盘的读取，写入内存，返回内存中的物理页。

  + `page_insert(mm->pgdir,page,addr,perm)`：然后完成虚拟地址和内存中物理页的映射。
  + `swap_map_swappable(mm,addr,page,0)`：最后设置该页面是可交换的。

+ **潜在用处**：页目录项和页表项中的合法位可以用来判断该页面是否存在，还有一些其他的权限位，比如可读可写，可以用于CLOCK算法或LRU算法。修改位可以决定在换出页面时是否需要写回磁盘。
+ **页访问异常**：
  + 首先保存当前异常原因，根据`stvec`的地址跳转到中断处理程序，即`trap.c`文件中的`trap`函数。
  + 接着跳转到`exception_handler`中的`CAUSE_LOAD_ACCESS`处理缺页异常。
  + 然后跳转到`pgfault_handler`，再到`do_pgfault`具体处理缺页异常。
  + 如果处理成功，则返回到发生异常处继续执行。
+ **对应关系**：有对应关系。如果页表项映射到了物理地址，那么这个地址对应的就是`Page`中的一项。

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

+ **优势**：内存访问次数少，只需要访问一次内存即可得到物理地址。
+ **劣势**：页表项必须连续，占用内存过大。

## 扩展练习

**设计思路**：将新加入的页面或刚刚访问的页插入到链表头部，这样每次换出页面时只需要将链表尾部的页面取出即可。

