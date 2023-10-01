<h1><center>lab2实验报告</center></h1>

## 练习一

算法的主要思想是维护一个空闲块列表，当有内存请求时，从列表中找到第一个足够大的块来满足请求。

**物理内存分配过程**：从空闲内存块的链表上查找第一个大小大于所需内存的块，分配出去，回收时会按照地址从小到大的顺序插入链表，并且合并与之相邻且连续的空闲内存块。

**各个函数的作用**：

+ `default_init`：初始化空闲内存块的链表，将空闲块的个数设置为0。
  + 初始化了空闲块列表 `free_list` 以及空闲页面数量 `nr_free`。

+ `default_init_memmap`：用于初始化一个空闲内存块。他会查询空闲内存块的链表，按照地址顺序插入到合适的位置，并将空闲内存块个数加n。
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
    if (p->property >= n) {
        if(page == NULL || page->property > p->property)
            page = p;
    }
}
```

## 扩展练习：buddy system分配算法

### 设计思路

经过测试，发现在ucore系统中需要分配的内存块有31929个，如果使用极简实现中的算法，使用数组存储，最大只能对16384个内存块进行管理，剩余的内存块较多，造成浪费，所以我们采取更经典的算法，使用11个链表来存储0~1024大小的内存块。

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

接着需要对可以管理的内存按照大小加入内存中。使连续的内存空间尽可能大。

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
    while (n > (1 << order)) {
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



## 扩展练习：可用物理内存获取

* 可以分段检测物理内存是否被占用，获得未被占用的物理内存。
* 向内存中写入并读取数据，如果超过内存范围，那么不管写入什么，再读取都会返回零。
* 利用BIOS的终端功能：BIOS终端会提供一个检索内存的功能，会返回一个结构体到指定位置。

## 重点内容

* 多级页表管理
  * 课程中仅涉及二级页表，但实验中设计使用了三级页表
* 多种内存分配算法
* 缺页等异常处理操作

