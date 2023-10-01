#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

#define MAX_ORDER 11

// 定义空闲内存区域的数据结构
free_area_t free_area[MAX_ORDER];

// 定义获取某一阶段空闲列表和空闲页面数量的宏
#define free_list(i) free_area[(i)].free_list
#define nr_free(i) free_area[(i)].nr_free

// 判断一个数是否是2的幂
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

// 初始化伙伴系统
static void
buddy_system_init(void) {
    for(int i = 0; i < MAX_ORDER; i++) {
        // 初始化每一阶段的空闲列表和空闲页面数量
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
    }
}

// 初始化伙伴系统的内存映射
static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    // 遍历基地址base到base + n - 1的所有页框
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p)); // 确保页框已被保留，不应该被分配

        // 清空当前页框的标志和属性信息，并将页框的引用计数设置为0
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }

    size_t curr_size = n;
    uint32_t order = MAX_ORDER - 1;
    uint32_t order_size = 1 << order;
    p = base;

    // 遍历内存区域，设置伙伴系统的数据结构
    while (curr_size != 0) {
        // 设置当前页框的属性为当前阶段的大小
        p->property = order_size;
        SetPageProperty(p);
        
        // 增加当前阶段的空闲页框数量
        nr_free(order) += 1;

        // 将当前页框添加到对应阶段的空闲列表之前
        list_add_before(&(free_list(order)), &(p->page_link));

        // 减少当前剩余内存的大小
        curr_size -= order_size;

        // 根据当前剩余内存的大小，递减阶段号以确定下一个阶段的大小
        while(order > 0 && curr_size < order_size) {
            order_size >>= 1;
            order -= 1;
        }

        // 移动到下一个阶段的第一个页框
        p += order_size;
    }
}


static void split_page(int order) {
    if(list_empty(&(free_list(order)))) {
        // 如果当前阶段的空闲列表为空，尝试拆分更高阶段的页面
        split_page(order + 1);
    }

    // 获取当前阶段的第一个空闲页面
    list_entry_t* le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);

    // 从当前阶段的空闲列表中移除该页面
    list_del(&(page->page_link));

    // 减少当前阶段的空闲页面数量
    nr_free(order) -= 1;

    // 计算拆分后的页面大小
    uint32_t n = 1 << (order - 1);

    // 计算与当前页面相邻的伙伴页面的地址
    struct Page *p = page + n;

    // 设置当前页面和伙伴页面的属性
    page->property = n;
    p->property = n;
    SetPageProperty(p);

    // 将当前页面添加到较低阶段的空闲列表中
    list_add(&(free_list(order-1)),&(page->page_link));

    // 将当前页面和伙伴页面添加到较高阶段的空闲列表中
    list_add(&(page->page_link),&(p->page_link));

    // 增加较低阶段的空闲页面数量
    nr_free(order-1) += 2;

    return;
}


static struct Page *buddy_system_alloc_pages(size_t n) {
    assert(n > 0);

    // 检查是否请求的页面数超出最大阶段的限制
    if (n > (1 << (MAX_ORDER - 1))) {
        return NULL;
    }

    struct Page *page = NULL;
    uint32_t order = MAX_ORDER - 1;

    // 根据需求的页面数确定所需的阶段
    while (n > (1 << order)) {
        order -= 1;
    }
    order += 1;

    uint32_t flag = 0;

    // 计算高阶段的空闲页面总数
    for (int i = order; i < MAX_ORDER; i++) {
        flag += nr_free(i);
    }

    // 如果高阶段没有足够的空闲页面，无法满足需求，返回NULL
    if (flag == 0) {
        return NULL;
    }

    // 如果当前阶段的空闲列表为空，尝试拆分更高阶段的页面
    if (list_empty(&(free_list(order)))) {
        split_page(order + 1);
    }

    // 如果当前阶段的空闲列表仍为空，无法满足需求，返回NULL
    if (list_empty(&(free_list(order)))) {
        return NULL;
    }

    // 从当前阶段的空闲列表中取出一个页面
    list_entry_t *le = list_next(&(free_list(order)));
    page = le2page(le, page_link);

    // 从当前阶段的空闲列表中删除该页面
    list_del(&(page->page_link));

    // 清除页面的属性标志，表示已分配
    ClearPageProperty(page);

    return page;
}


// 添加一个页面到指定阶段的空闲列表中
static void add_page(uint32_t order, struct Page* base) {
    // 检查指定阶段的空闲列表是否为空
    if (list_empty(&(free_list(order)))) {
        // 如果为空，直接将页面添加到该阶段的空闲列表头部
        list_add(&(free_list(order)), &(base->page_link));
    } 
    else {
        // 如果不为空，需要在适当的位置插入页面，以保持列表的有序性

        list_entry_t* le = &(free_list(order));

        // 遍历该阶段的空闲列表
        while ((le = list_next(le)) != &(free_list(order))) {
            struct Page* page = le2page(le, page_link);

            // 如果当前页面的地址小于要添加的页面，继续遍历
            if (base < page) {
                // 在当前位置之前插入要添加的页面
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &(free_list(order))) {
                // 如果已经到达列表尾部，将页面添加到尾部
                list_add(le, &(base->page_link));
            }
        }
    }
}


// 合并相邻的空闲页面
static void merge_page(uint32_t order, struct Page* base) {
    // 如果当前阶段已经是最大阶段，无法再进行合并，直接返回
    if (order == MAX_ORDER - 1) {
        return;
    }
    
    // 尝试合并前一个页面
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &(free_list(order))) {
        struct Page *p = le2page(le, page_link);
        // 如果前一个页面与当前页面是连续的
        if (p + p->property == base) {
            // 合并两个页面的空闲块大小
            p->property += base->property;
            // 清除当前页面的属性标记，表示不再是空闲页面
            ClearPageProperty(base);
            // 从空闲列表中删除当前页面
            list_del(&(base->page_link));
            // 将当前页面指向合并后的页面
            base = p;

            // 如果当前阶段不是最大阶段，还需要从当前阶段的空闲列表中删除
            // 合并后的页面，并将其添加到下一个阶段的空闲列表中
            if(order != MAX_ORDER - 1) {
                list_del(&(base->page_link));
                add_page(order+1,base);
            }
        }
    }

    // 尝试合并后一个页面
    le = list_next(&(base->page_link));
    if (le != &(free_list(order))) {
        struct Page *p = le2page(le, page_link);
        // 如果后一个页面与当前页面是连续的
        if (base + base->property == p) {
            // 合并两个页面的空闲块大小
            base->property += p->property;
            // 清除后一个页面的属性标记，表示不再是空闲页面
            ClearPageProperty(p);
            // 从空闲列表中删除后一个页面
            list_del(&(p->page_link));

            // 如果当前阶段不是最大阶段，还需要从当前阶段的空闲列表中删除
            // 合并后的页面，并将其添加到下一个阶段的空闲列表中
            if(order != MAX_ORDER - 1) {
                list_del(&(base->page_link));
                add_page(order+1,base);
            }
        }
    }

    // 继续尝试合并更高阶段的页面
    merge_page(order+1,base);
    return;
}


// 释放页面到伙伴系统
static void
buddy_system_free_pages(struct Page *base, size_t n) {
    // 确保要释放的页面数量大于0
    assert(n > 0);
    // 确保要释放的页面数量是2的幂次方
    assert(IS_POWER_OF_2(n));
    // 确保要释放的页面数量不超过最大阶段的页面数量
    assert(n < (1 << (MAX_ORDER - 1)));

    // 遍历要释放的页面范围
    struct Page *p = base;
    for (; p != base + n; p ++) {
        // 确保要释放的页面既不是保留页面也不是属性页面
        assert(!PageReserved(p) && !PageProperty(p));
        // 清除页面的标志位
        p->flags = 0;
        // 将页面的引用计数设置为0
        set_page_ref(p, 0);
    }
    // 设置要释放的页面的属性为释放的页面
    base->property = n;
    SetPageProperty(base);

    // 计算要释放的页面所在的阶段
    uint32_t order = 0;
    size_t temp = n;
    while (temp != 1) {
        temp >>= 1;
        order++;
    }
    // 将要释放的页面添加到对应阶段的空闲列表中
    add_page(order, base);
    // 尝试合并相邻的空闲页面
    merge_page(order, base);
}


// 获取伙伴系统中的空闲页面数量
static size_t
buddy_system_nr_free_pages(void) {
    size_t num = 0;
    // 遍历每个阶段
    for (int i = 0; i < MAX_ORDER; i++) {
        // 计算当前阶段的空闲页面数量，并将其乘以2的阶段数次方累加到总数中
        num += nr_free(i) << i;
    }
    // 返回计算得到的总的空闲页面数量
    return num;
}


// 基本检查函数
static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);
    for(int i = 0; i < MAX_ORDER; i++) {
        list_init(&(free_list(i)));
        assert(list_empty(&(free_list(i))));
    }
    
    for(int i = 0; i < MAX_ORDER; i++) {
        list_init(&(free_list(i)));
        assert(list_empty(&(free_list(i))));
    }
    for(int i = 0; i < MAX_ORDER; i++) nr_free(i) = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(buddy_system_nr_free_pages() == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    for(int i = 0; i < 0; i++) assert(!list_empty(&(free_list(i))));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(buddy_system_nr_free_pages() == 0);

    free_page(p);
    free_page(p1);
    free_page(p2);
}

static void
buddy_system_check(void) {}

//这个结构体在
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "default_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};

