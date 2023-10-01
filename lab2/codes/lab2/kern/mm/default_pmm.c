#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/* 
  在首次适配算法中，分配器维护一个空闲块的列表（称为空闲列表），当接收到内存请求时，它会沿着列表扫描，寻找足够大以满足请求的第一个块。
  如果选择的块比请求的块大得多，那么通常会将其分割，并将剩余部分添加到列表中作为另一个空闲块。
  请参阅严蔚敏的中文书籍《数据结构 - C语言描述》第196~198页，第8.2节。
*/
// 您应该重写以下函数：default_init, default_init_memmap, default_alloc_pages, default_free_pages
/*
 * FFMA的详细信息
 * （1）准备：为了实现首次适配内存分配（FFMA），我们应该使用一些列表来管理空闲内存块
 *      结构体free_area_t用于管理空闲内存块。首先，您应该熟悉list.h中的结构体list。
 *      结构体list是一个简单的双向链表实现。您应该了解如何使用list_init、list_add（list_add_after）、list_add_before、list_del、list_next、list_prev等操作。
 *      另一个棘手的方法是将通用的列表结构转换为特定的结构体（例如struct page）：您可以找到一些宏：le2page（在memlayout.h中），（在以后的实验中：le2vma（在vmm.h中），le2proc（在proc.h中）等。
 * (2) default_init：您可以重用演示的default_init函数来初始化free_list并将nr_free设置为0
 *      free_list用于记录空闲内存块。nr_free是空闲内存块的总数
 * (3) default_init_memmap:  CALL GRAPH: kern_init --> pmm_init-->page_init-->init_memmap--> pmm_manager->init_memmap
 *      此函数用于初始化一个空闲块（具有参数：addr_base，page_number）。
 *      首先，您应该初始化此空闲块中的每个页面（在memlayout.h中），包括：
 *          p->flags应该设置PG_property位（表示此页面有效。在pmm_init函数（在pmm.c中）中，p->flags中设置了PG_reserved位）。
 *          如果此页面是空闲的且不是空闲块的第一页，则p->property应设置为0。
 *          如果此页面是空闲的且是空闲块的第一页，则p->property应设置为块的总数。
 *          p->ref应为0，因为现在p是空闲的，没有引用。
 *          我们可以使用p->page_link将此页面链接到free_list中（例如：list_add_before(&free_list, &(p->page_link)); ）。
 *      最后，我们应该计算空闲内存块的数量：nr_free += n
 * (4) default_alloc_pages：在free_list中搜索找到第一个空闲块（块大小> = n）并调整空闲块的大小，返回已分配块的地址
 *       (4.1) 因此，您应该像这样搜索freelist:
 *                  list_entry_t le = &free_list;
 *                  while((le=list_next(le)) != &free_list) {
 *                  ....
 *              （4.1.1）在while循环中，获取struct page并检查p->property（记录空闲块的数量）> = n吗？
 *                       struct Page *p = le2page(le, page_link);
 *                       if(p->property >= n){ ...
 *              （4.1.2）如果找到了此p，那么意味着我们找到了一个空闲块（块大小> = n），并且前n个页面可以分配。
 *                       应设置此页面的某些标志位：PG_reserved = 1，PG_property = 0
 *                       从free_list中取消链接这些页面
 *                  （4.1.2.1）如果（p->property> n），则应重新计算此空闲块的其余部分的数量，
 *                            （例如：le2page（le，page_link））->property = p->property - n; ）
 *              （4.1.3）重新计算nr_free（所有空闲块的其余部分的数量）
 *               (4.1.4)  return p
 *       (4.2) 如果找不到空闲块（块大小> = n），则返回NULL
 * (5) default_free_pages：重新链接页面到free_list，可能将小的空闲块合并为大的空闲块。
 *      （5.1）根据撤回块的基址，在free_list中搜索，找到正确的位置（从低地址到高地址），并插入页面。
 *            （可能使用list_next、le2page、list_add_before）
 *      （5.2）重置页面的字段，例如p->ref、p->flags（PageProperty）
 *      （5.3）尝试合并低地址或高地址的块。注意：应正确更改某些页面的p->property。
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    // 初始化空闲列表 free_list 和空闲页面数量 nr_free
    list_init(&free_list);
    nr_free = 0;
}

static void
default_init_memmap(struct Page *base, size_t n) {
    // 初始化内存映射，将一块内存区域分成多个页面，并加入到空闲列表中

    assert(n > 0);  // 确保页面数量大于0

    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));  // 确保页面是保留页面（不能被分配）
        
        // 初始化页面的属性
        p->flags = p->property = 0;  // 将页面标志和属性清零
        set_page_ref(p, 0);  // 设置页面引用计数为0
    }

    // 将第一个页面（base）的属性设置为块的总数，表示整个块的页面数量
    base->property = n;
    SetPageProperty(base);  // 标记页面为“属性”页面
    nr_free += n;  // 增加空闲页面的数量

    if (list_empty(&free_list)) {
        // 如果空闲列表为空，则直接将该块加入列表
        list_add(&free_list, &(base->page_link));
    } else {
        // 否则，需要找到合适的位置将该块插入到空闲列表中
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                // 如果找到一个页面的地址大于当前块的地址，则插入当前位置之前
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                // 如果已经遍历到了空闲列表的末尾，则直接将块加入末尾
                list_add(le, &(base->page_link));
            }
        }
    }
}


static struct Page *
default_alloc_pages(size_t n) {
    // 分配 n 个连续的物理页面
    assert(n > 0);  // 确保分配的页面数量大于0

    if (n > nr_free) {
        // 如果需要的页面数量大于当前空闲页面的数量，无法分配，返回NULL
        return NULL;
    }

    struct Page *page = NULL;  // 用于保存分配到的页面指针
    list_entry_t *le = &free_list;  // 从空闲列表的头部开始遍历

    while ((le = list_next(le)) != &free_list) {
        // 遍历空闲列表中的每个页面
        struct Page *p = le2page(le, page_link);

        if (p->property >= n) {
            // 如果当前页面的属性（即页面数量）大于等于需要的页面数量n，可以分配
            page = p;
            break;
        }
    }

    if (page != NULL) {
        // 找到了可分配的页面
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));  // 从空闲列表中删除该页面

        if (page->property > n) {
            // 如果该页面的属性（即页面数量）大于需要的页面数量n，
            // 则需要将剩余的页面（属性减去n）重新加入到空闲列表
            struct Page *p = page + n;
            p->property = page->property - n;  // 更新剩余页面的属性
            SetPageProperty(p);  // 标记为“属性”页面
            list_add(prev, &(p->page_link));  // 加入到空闲列表中
        }

        nr_free -= n;  // 更新空闲页面数量
        ClearPageProperty(page);  // 清除页面的“属性”标志
    }

    return page;  // 返回分配到的页面指针（如果成功分配），否则返回NULL
}


static void
default_free_pages(struct Page *base, size_t n) {
    // 释放 n 个物理页面
    assert(n > 0);  // 确保要释放的页面数量大于0
    struct Page *p = base;

    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        // 确保要释放的页面既不是保留页面也不是属性页面
        p->flags = 0;  // 清除页面的标志
        set_page_ref(p, 0);  // 将页面的引用计数设置为0
    }

    base->property = n;  // 更新基础页面的属性为释放的页面数量
    SetPageProperty(base);  // 标记基础页面为“属性”页面
    nr_free += n;  // 更新空闲页面数量

    if (list_empty(&free_list)) {
        // 如果空闲列表为空，将基础页面加入到空闲列表
        list_add(&free_list, &(base->page_link));
    } else {
        // 否则，遍历空闲列表，找到适当的位置将基础页面插入
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                // 找到了合适的位置，将基础页面插入到该位置之前
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                // 已经到达列表末尾，将基础页面插入到末尾
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) {
            // 尝试合并低地址的块
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            // 尝试合并高地址的块
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}


static size_t
default_nr_free_pages(void) {
    // 获取当前系统中的空闲物理页面数量
    return nr_free;
}

static void
basic_check(void) {
    // 基本内存分配和释放的检查

    // 分配三个页面，并确保它们不为空
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    // 确保分配的三个页面不相同，并且它们的引用计数都为0
    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    // 确保页面的物理地址在合理范围内
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    // 备份当前的空闲列表和空闲页面数量
    list_entry_t free_list_store = free_list;
    list_init(&free_list);  // 初始化空闲列表为空
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // 尝试分配一个页面，但应该返回NULL，因为没有空闲页面
    assert(alloc_page() == NULL);

    // 释放之前分配的三个页面
    free_page(p0);
    free_page(p1);
    free_page(p2);

    // 确保空闲页面数量为3
    assert(nr_free == 3);

    // 再次分配三个页面，并确保它们不为空
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    // 尝试分配一个页面，但应该返回NULL，因为没有空闲页面
    assert(alloc_page() == NULL);

    // 释放 p0 页面，并确保空闲列表不为空
    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    
    // 再次尝试分配页面，应该得到之前释放的 p0 页面
    assert((p = alloc_page()) == p0);

    // 再次尝试分配页面，但应该返回NULL，因为没有空闲页面
    assert(alloc_page() == NULL);

    // 确保空闲页面数量为0
    assert(nr_free == 0);

    // 恢复原始的空闲列表和空闲页面数量
    free_list = free_list_store;
    nr_free = nr_free_store;

    // 释放 p 页面以及之前分配的 p1 和 p2 页面
    free_page(p);
    free_page(p1);
    free_page(p2);
}


// LAB2：下面的代码用于检查首次适配内存分配算法
// 注意：您不应更改 basic_check 和 default_check 函数!

static void default_check(void) {
    // 使用首次适配算法的内存分配和释放的检查

    int count = 0, total = 0;

    // 遍历空闲列表，计算总空闲页面数和页面数量
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count++, total += p->property;
    }

    // 确保计算的总空闲页面数与函数 default_nr_free_pages 返回值相等
    assert(total == nr_free_pages());

    // 执行基本内存分配和释放的检查
    basic_check();

    // 分配 5 个连续页面，并确保它们不是空闲块
    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    // 备份当前的空闲列表和清空空闲列表
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    // 尝试分配一个页面，但应该返回NULL，因为没有空闲页面
    assert(alloc_page() == NULL);

    // 备份当前的空闲页面数量，并将其设置为0
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // 释放 p0 的第三个页面，然后尝试分配 4 个页面，应返回NULL
    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);

    // 确保 p0 的第三个页面的属性为 3
    assert(PageProperty(p0 + 2) && p0[2].property == 3);

    // 再次分配 3 个页面，并确保它们不为空
    assert((p1 = alloc_pages(3)) != NULL);

    // 尝试分配一个页面，但应该返回NULL，因为没有空闲页面
    assert(alloc_page() == NULL);

    // 确保 p1 是 p0 的第三个页面
    assert(p0 + 2 == p1);

    // 计算 p2 的地址，然后释放 p0、p1、p2 的页面
    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);

    // 确保 p0 的属性为 1，p1 的属性为 3
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    // 再次尝试分配页面，应返回 p2 的前一个页面
    assert((p0 = alloc_page()) == p2 - 1);

    // 释放 p0，然后再次分配 2 个页面，应该得到 p2 的下一个页面
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    // 释放 p0 的 2 个页面
    free_pages(p0, 2);

    // 释放 p2
    free_page(p2);

    // 再次尝试分配 5 个页面，并确保它们不为空
    assert((p0 = alloc_pages(5)) != NULL);

    // 尝试分配一个页面，但应该返回NULL，因为没有空闲页面
    assert(alloc_page() == NULL);

    // 确保当前的空闲页面数量为0
    assert(nr_free == 0);

    // 恢复原始的空闲列表和空闲页面数量
    nr_free = nr_free_store;
    free_list = free_list_store;

    // 释放 p0 的 5 个页面
    free_pages(p0, 5);

    // 遍历空闲列表，计算总空闲页面数和页面数量
    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
    }

    // 确保计算的总空闲页面数和页面数量均为0
    assert(count == 0);
    assert(total == 0);
}

// 定义默认的内存管理器结构体
const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};


