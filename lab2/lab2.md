<h1><center>lab2实验报告</center></h1>

## 练习一

First Fit算法的主要思想是维护一个空闲块列表，当有内存请求时，从列表中找到第一个足够大的块来满足请求。

**物理内存分配与回收的过程**：从空闲内存块的链表上查找第一个大小大于所需内存的块，分配出去，回收时会按照地址从小到大的顺序插入链表，并且合并与之相邻且连续的空闲内存块。

**各个函数的作用**：

+ `default_init`：初始化空闲内存块的链表，将空闲块的个数设置为0。
  + 初始化了空闲块列表 `free_list` 以及空闲页面数量 `nr_free`。

+ `default_init_memmap`：用于初始化一个空闲内存块。先查询空闲内存块的链表，按照地址顺序插入到合适的位置，并将空闲内存块个数加n。
  + 首先初始化了每个页面的属性，包括标志位 `flags` 和 `property`，并将页面引用计数设置为0。
  + 然后，它将首个页面的 `property` 设置为块的总数，表示此块中的页面数量。
  + 最后，它将这些页面添加到 `free_list` 中，并更新 `nr_free` 计数。

+ `default_alloc_pages`：用于分配给定大小的内存块。如果剩余空闲内存块大小多于所需的内存区块大小，则从链表中查找大小超过所需大小的页，并更新该页剩余的大小。
  + 遍历空闲块列表，查找第一个满足请求的块（块大小大于等于 `n`）。
  + 如果找到了合适的块，会将块分割成两部分，一部分用于分配，另一部分保留在列表中。
  + 如果分割后剩余的块大小大于 `n`，则更新剩余块的 `property` 并将其添加到列表中。
  + 最后，它减少 `nr_free` 计数，并标记已分配的页面。

+ `default_free_pages`：用于释放内存块。将释放的内存块按照顺序插入到空闲内存块的链表中，并合并与之相邻且连续的空闲内存块。
  + 首先将页面的属性重置，并将页面引用计数设置为0。
  + 然后，将页面添加到空闲块列表中，同时尝试合并相邻的空闲块。
  + 如果释放的页面与前一个页面或后一个页面相邻，会尝试将它们合并为一个更大的空闲块。
  + 最后，更新 `nr_free` 计数。


**改进空间：**

* 更高效的内存块合并策略
* 更快速的空闲块搜索算法
* 支持内存回收策略
* 更灵活的内存分配策略

## 练习二

**设计实现过程**：在分配内存块时，按照顺序查找，遇到第一块比所需内存块大的空闲内存块时，先将该块分配给`page`，之后继续查询，如果查询到大小比分配的内存块小的空闲内存块，将`page`更新为当前的内存块。释放内存块时，按照顺序将其插入链表中，并合并与之相邻且连续的空闲内存块。

核心步骤的实现如下：

```c
while ((le = list_next(le)) != &free_list) {
    struct Page *p = le2page(le, page_link);
    if (p->property >= n && p->property < min_size) {
        page = p;
        min_size = p->property;
    }
}
```

## 扩展练习：buddy system分配算法

### 设计思路

经过测试，发现在ucore系统中需要分配的内存块有31929个，如果使用极简实现中的算法，使用数组存储，最大只能对16384个内存块进行管理，剩余的内存块较多，造成浪费，所以我们采取更经典的算法，**使用11个链表来存储0~1024大小的内存块。**

与之前不同的是，这里的`nr_free`表示的是该大小的内存块的个数，而不是内存块大小。

### 开发文档

首先需要定义最大块的大小，并且创建一个数组，用来存储每种大小的内存块。具体实现方式如下：

```
#define MAX_ORDER 11
free_area_t free_area[MAX_ORDER];
#define free_list(i) free_area[(i)].free_list
#define nr_free(i) free_area[(i)].nr_free
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
```

#### 初始化链表

接着需要初始化各个链表，具体实现如下：

```c
static void
buddy_system_init(void) {
    for(int i = 0; i < MAX_ORDER; i++) {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
    }
}
```

#### 初始化内存

接着需要对可以管理的内存按照大小加入内存中，使连续的内存空间尽可能大。

```c
static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    size_t curr_size = n;
    uint32_t order = MAX_ORDER - 1;
    uint32_t order_size = 1 << order;
    p = base;
    while (curr_size != 0) {
        p->property = order_size;
        SetPageProperty(p);
        nr_free(order) += 1;
        list_add_before(&(free_list(order)), &(p->page_link));
        curr_size -= order_size;
        while(order > 0 && curr_size < order_size) {
            order_size >>= 1;
            order -= 1;
        }
        p += order_size;
    }
}
```

#### 内存分配

接着需要实现内存分配的算法。如果请求的内存大小大于我们规定的最大内存，将直接返回`NULL`，如果可以分配，就寻找不小于他且最接近的内存大小，从该链表上取下第一个内存块分配出去。如果没有，则会递归的分裂大内存块以获得小的内存块。

* 分裂内存块的方法如下：

```c
static void split_page(int order) {
    if(list_empty(&(free_list(order)))) {
        split_page(order + 1);
    }
    list_entry_t* le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);
    list_del(&(page->page_link));
    nr_free(order) -= 1;
    uint32_t n = 1 << (order - 1);
    struct Page *p = page + n;
    page->property = n;
    p->property = n;
    SetPageProperty(p);
    list_add(&(free_list(order-1)),&(page->page_link));
    list_add(&(page->page_link),&(p->page_link));
    nr_free(order-1) += 2;
    return;
}
```

* 分配内存块的方法如下：

```c
static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > (1 << (MAX_ORDER - 1))) {
        return NULL;
    }
    struct Page *page = NULL;
    uint32_t order = MAX_ORDER - 1;
    while (n < (1 << order)) {
        order -= 1;
    }
    order += 1;
    uint32_t flag = 0;
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
    if(flag == 0) return NULL;
    if(list_empty(&(free_list(order)))) {
        split_page(order + 1);
    }
    if(list_empty(&(free_list(order)))) return NULL;
    list_entry_t *le = list_next(&(free_list(order)));
    page = le2page(le, page_link);
    list_del(&(page->page_link));
    ClearPageProperty(page);
    return page;
}
```

#### 回收内存块

回收内存块时，需要先判断给定的内存块大小是否是2的幂，如果是，就将其按照地址从小到大顺序加入到对应的内存块链表上。接着判断相邻的内存块是否连续，如果连续则递归的向内存大的块合并。

* 添加页面的方法如下：

```c
static void add_page(uint32_t order, struct Page* base) {
    if (list_empty(&(free_list(order)))) {
        list_add(&(free_list(order)), &(base->page_link));
    } 
    else {
        list_entry_t* le = &(free_list(order));
        while ((le = list_next(le)) != &(free_list(order))) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &(free_list(order))) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```

* 合并页面的方法如下：

```c
static void merge_page(uint32_t order, struct Page* base) {
    if (order == MAX_ORDER - 1) {
        return;
    }
    
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &(free_list(order))) {
        struct Page *p = le2page(le, page_link);
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
            if(order != MAX_ORDER - 1) {
                list_del(&(base->page_link));
                add_page(order+1,base);
            }
        }
    }

    le = list_next(&(base->page_link));
    if (le != &(free_list(order))) {
        struct Page *p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
            if(order != MAX_ORDER - 1) {
                list_del(&(base->page_link));
            add_page(order+1,base);
            }
        }
    }
    merge_page(order+1,base);
    return;
}
```

* 回收内存的方法如下：

```c
static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(IS_POWER_OF_2(n));
    assert(n < (1 << (MAX_ORDER - 1)));
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);

    uint32_t order = 0;
    size_t temp = n;
    while (temp != 1) {
        temp >>= 1;
        order++;
    }
    add_page(order,base);
    merge_page(order,base);
}
```

#### 获得块大小

由于我们重新定义了`nr_free`，所以需要重新实现块大小的计算，计算方法为每一个链表的块数量乘以块大小，求和。实现方法如下：

```c
static size_t
buddy_system_nr_free_pages(void) {
    size_t num = 0;
    for(int i = 0; i < MAX_ORDER; i++) {
        num += nr_free(i) << i;
    }
    return num;
}
```

#### 检查模块

对原本的检查程序稍作修改即可。

在`pmm.c`文件中更换页面管理函数指针，进行测试，测试通过。

## 扩展练习：slub分配算法

### 设计思路

slub分配算法是一种任意大小内存分配的算法，主要用于给内核分配小空间的内存。

对于较大的块，可以直接使用原本的页面分配算法，对于小于一页的块，需要将一页的内容划分为小的空间分配，对于每一个分配出去的空间，我们称为slob块，在其头部存在着一个slob块基本信息的结构，用于管理。

### 结构设计

在这里我们定义两种数据类型：

+ `slob_t`：slob块，即小空间的内存

  ```c
  struct slob_block {
      int units;					// slob块大小，单位是SLOB_UNIT（即slob_t结构体的大小）
      struct slob_block *next;	 // 下一个slob块
  };
  typedef struct slob_block slob_t;
  ```

+ `bigblock_t`：大块，即整页的内存

  ```c
  struct bigblock {
  	int order;				// 大块的大小
  	void *pages;			// 起始页
  	struct bigblock *next;	 // 下一个大块
  };
  typedef struct bigblock bigblock_t;
  ```

我们还需要维护一些全局变量：

```c
static slob_t arena = { .next = &arena, .units = 1 };	// 初始的空闲slob块
static slob_t *slobfree = &arena;					  // 空闲slob块链表，设计为单向循环链表
static bigblock_t *bigblocks;						 // 大块链表，设计为单向链表
```


### 算法实现

#### 分配内存

在slub分配算法中，对于小内存的分配我们需要在其头部加上一个`slob_t`结构体，所以需要分两种情况讨论：

+ 如果待分配的大小没有超过`PGSIZE - SLOB_UNIT`，调用`slob_alloc`为其分配`size + SLOB_UNIT`大小的空间（因为要算上头部的`slob_t`）
+ 如果超过了`PGSIZE - SLOB_UNIT`，调用`alloc_pages`为其分配一个大于且最接近这个大小的连续的若干页，并申请一个`bigblock_t`大小的空间管理该页面，将其加入到`bigblocks`链表中

```c
void *slub_alloc(size_t size)
{
	slob_t *m;
	bigblock_t *bb;

	if (size < PGSIZE - SLOB_UNIT) {
		m = slob_alloc(size + SLOB_UNIT);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t));
	if (!bb)
		return 0;

	bb->order = ((size-1) >> PGSHIFT) + 1;
	bb->pages = (void *)alloc_pages(bb->order);

	if (bb->pages) {
		bb->next = bigblocks;
		bigblocks = bb;
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));
	return 0;
}
```

对于slob块的分配，由于这里只使用了单向循环链表，所以需要额外记录一下上一个节点的地址。遍历空闲块的链表，比较空闲块的大小与分配的大小关系：

+ 如果大小相等，直接分配出去，更新链表
+ 如果空闲块较大，则将多出的空间合并到下一个slub块中，将当前的块分配出去，更新链表
+ 如果没有合适的空间，分配一页，调用`slub_free`将其加入到链表的合适位置，重新遍历

```c
static void *slob_alloc(size_t size)
{
  	assert(size < PGSIZE);

	slob_t *prev, *cur;
	int  units = SLOB_UNITS(size);

	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
		if (cur->units >= units) { 

			if (cur->units == units)
				prev->next = cur->next;
			else {
				prev->next = cur + units;
				prev->next->units = cur->units - units;
				prev->next->next = cur->next;
				cur->units = units;
			}
			slobfree = prev;
			return cur;
		}
		if (cur == slobfree) {
			if (size == PGSIZE)
				return 0;
			cur = (slob_t *)alloc_pages(1);
			if (!cur)
				return 0;
			slob_free(cur, PGSIZE);
			cur = slobfree;
		}
	}
}
```

#### 释放内存

在释放内存时，也需要分两种情况讨论：

+ 如果页面大于一页，那么该页存在于大页链表中，需要在链表中找到管理该页的`bigblock_t`，调用`free_pages`释放该页，并调用`slob_free`释放`bigblock_t`
+ 如果页面小于一页，则调用`slob_free`释放内存，由于在分配出去的时候我们将其加一以获得实际可以使用的内存地址，所以在这里我们需要将其减一以获得`slob_t`

```c
void slub_free(void *block)
{
	bigblock_t *bb, **last = &bigblocks;

	if (!block)
		return;

	if (!((unsigned long)block & (PGSIZE-1))) {
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
			if (bb->pages == block) {
				*last = bb->next;
				free_pages((struct Page *)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
```

对于slob块的释放，需要经过以下步骤：

+ 在空闲块链表中查找该块应处的位置
+ 检查是否能与前后块合并，如果可以，则合并
+ 更新`slobfree`

```c
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	if (!block)
		return;
	if (size)
		b->units = SLOB_UNITS(size);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur;
}
```

### 算法测试

编写测试样例如下：

```c
int slobfree_len()
{
    int len = 0;
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
        len ++;
    return len;
}

void slub_check()
{
    cprintf("slub check begin\n");
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p3);
    cprintf("slobfree len: %d\n", slobfree_len());
    cprintf("slub check end\n");
}
```

测试结果如下：

```
slub_init() succeeded!
slub check begin
slobfree len: 0
slobfree len: 1
slobfree len: 1
slobfree len: 2
slobfree len: 1
slub check end
```

**对测试结果的解释**：

初始情况下由于链表中有一个表头，但是这个我们在这里不计入长度，所以长度为0。首先分配了一个大内存，slub会为之分配一个页，但是由于在这里需要创建一个`bigblock_t`项，会向slub申请一个小内存，所以申请完成之后`slobfree`的长度增加，后续两次申请时都会从原本的一个大页中取下一部分，所以长度不变。在释放`p2`时，由于其与后一项中间隔了一个`p3`，无法合并，所以`slob`变成了2，之后释放`p3`时会合并，最终变为1。

## 扩展练习：可用物理内存获取

* 可以分段检测物理内存是否被占用，获得未被占用的物理内存。
* 向内存中写入并读取数据，如果超过内存范围，那么不管写入什么，再读取都会返回零。
* 利用BIOS的终端功能：BIOS终端会提供一个检索内存的功能，会返回一个结构体到指定位置。

## 重点内容

* 以页为单位管理物理内存
  页表存储在内存中，由若干个固定大小的页表项组成

  页表项的固定格式是，在sv39中，页表项的大小是占8字节（64位），第53-10位为物理页号（56为地址，最后12位是偏移量，同一位置的物理地址与虚拟地址的偏移量是一样的，所以可不用记录，所以用44位来表示物理页号），9-0位共10位描述状态信息：

  + RSW：2位，留给S态的应用程序
  + D：自被清零后，有虚拟地址通过此页表项进行写入
  + A：自被清零后，有虚拟地址通过此页表项进行读、写入、取值
  + G：全局，所有页表都包含这个页表项
  + U：用户态的程序通过此页表项进行映射，S Mode不一定通过U=1的页表项及逆行映射，S Mode都不允许执行U=1的页表里包含的指令
  + R、W、X：可读、可写、可执行

* 多级页表管理
  
  * 每个一级页表项控制一个虚拟页号，即控制 4KB 虚拟内存；
  * 每个二级页表项则控制 9 位虚拟页号，总计控制 4KB×2^9 =2MB 虚拟内存；
  * 每个三级页表项控制18 位虚拟页号，总计控制 2MB×2^9 =1GB 虚拟内存；
  
  39位的虚拟地址，前27位中9位代表三级页号，9位代表三级页号中的偏移量（二级页号）、9位代表二级页号中的偏移量（一级页号），一级页号中的页表项对应一个4KB的虚拟页号，后12位是虚拟页号中的偏移量。也就是说**有512（2 的 9 次方）个大大页**，每个大大页里有 **512 个大页**，每个大页里有 **512 个页**，每个页里有 4096 个字节。整个虚拟内存空间里就有 512∗512∗512∗4096 个字节，是 512GB 的地址空间。
  
  Sv39 的多级页表在逻辑上是一棵树，它的每个叶子节点（直接映射 4KB 的页的页表项）都对应内存的一页，其根节点的物理地址（最高级页表的物理页号）存放在satp寄存器中；
  
* **进入虚拟内存访问方式的步骤：**
  
  + 分配页表所在内存空间并初始化页表
  + 设置好基址寄存器（指向页表起始地址）
  + 刷新TLB
  
* 多种内存分配算法：

  + First Fit算法：当需要分配页面时，它会从空闲页块链表中找到第一个适合大小的空闲页块，然后进行分配；当释放页面时，它会将释放的页面添加回链表，并在必要时合并相邻的空闲页块，以最大限度地减少内存碎片；
  + Best Fit算法：在分配内存块时，按照顺序查找，遇到第一块比所需内存块大的空闲内存块时，先将该块分配给`page`，之后继续查询，如果查询到大小比分配的内存块小的空闲内存块，将`page`更新为当前的内存块。释放内存块时，按照顺序将其插入链表中，并合并与之相邻且连续的空闲内存块；
  + buddy system分配算法：是一种内存分配策略，用于管理和分配物理内存页面，使用11个链表来存储0~1024大小的内存块；
  + slub分配算法：slub分配算法是一种任意大小内存分配的算法，主要用于给内核分配小空间的内存。
    对于较大的块，可以直接使用原本的页面分配算法，对于小于一页的块，需要将一页的内容划分为小的空间分配，对于每一个分配出去的空间，我们称为slob块，在其头部存在着一个slob块基本信息的结构，用于管理。

