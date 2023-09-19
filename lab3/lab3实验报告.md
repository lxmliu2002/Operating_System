<h1><center>lab3实验报告</center></h1>

## 练习一

当需要换入页面时，需要调用`swap.c`文件中的`swap_in`。

+ `swap_in`：用于换入页面。首先调用`pmm.c`中的`alloc_page`，申请一块连续的内存空间，然后调用`get_pte`找到或者构建对应的页表项，最后调用`swapfs_read`将数据从磁盘写入内存。
+ `alloc_page`：用于申请页面。通过调用`pmm_manager->alloc_pages`申请一块连继续的内存空间，在这个过程中，如果申请页面失败，那么说明需要换出页面，则调用`swap_out`换出页面，之后再次进行申请。
+ `assert(result!=NULL)`：判断获得的页面是否为`NULL`，只有页面不为`NULL`才能继续。
+ `swap_out`：用于换出页面。首先需要循环调用`sm->swap_out_victim`，对应于`swap_fifo`中的`_fifo_swap_out_victim`。然后调用`get_pte`获取对应的页表项，将该页面写入磁盘，如果写入成功，释放该页面；如果写入失败，调用`_fifo_map_swappable`更新FIFO队列。最后刷新TLB。
  + `free_page`：用于释放页面。通过调用`pmm_manager->free_pages`释放页面。
  + `swapfs_write`：用于将页面写入磁盘。在这里由于需要换出页面，而页面内容如果被修改过那么就与磁盘中的不一致，所以需要将其重新写回磁盘。
  + `tlb_invalidate`：用于刷新TLB。通过调用`flush_tlb`刷新TLB。
+ `get_pte`：用于获得页表项。
+ `swapfs_read`：用于从磁盘读入数据。
+ `_fifo_swap_out_victim`：用于获得需要换出的页面。查找队尾的页面，作为需要释放的页面。
+ `_fifo_map_swappable`：将最近使用的页面添加到队头。在`swap_out`中调用是用于将队尾的页面移动到队头，防止下一次换出失败。

该页面移动到了链表的末尾时，在下一次有页面换入的时候需要被换出。当需要换出页面时，需要调用`swap.c`文件中的`swap_out`，后续的方法在上面已经给出。

## 练习二



## 练习三



## 练习四



## 练习五



## 扩展练习



