#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

#define MAX_ORDER 11

free_area_t free_area[MAX_ORDER];

#define free_list(i) free_area[(i)].free_list
#define nr_free(i) free_area[(i)].nr_free
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static void
buddy_system_init(void) {
    for(int i = 0; i < MAX_ORDER; i++) {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
    }
    
}

static void//从能存放最大内存块的链表开始，将要存放的物理内存放到链表中，若不能继续放入到这个链表中，则进行一步步降低能存放内存块大小的链表，
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

//取出高一级的空闲链表中的一个块，将其分为两个较小的快，大小是order-1，加入到较低一级的链表中，注意nr_free数量的变化
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

//先将块按照地址从小到大的顺序加入到指定序号的链表当中
static void add_page(uint32_t order, struct Page* base) {
    if (list_empty(&(free_list(order)))) {
        list_add(&(free_list(order)), &(base->page_link));
    } else {
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

static void merge_page(uint32_t order, struct Page* base) {
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
        return;
    }
    
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &(free_list(order))) {
        struct Page *p = le2page(le, page_link);
        if (p + p->property == base) {//若是连续内存
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

static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(IS_POWER_OF_2(n));
    assert(n < (1 << (MAX_ORDER - 1)));
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));//确保页面没有被保留且没有属性标志
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);

    uint32_t order = 0;
    size_t temp = n;
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
        temp >>= 1;
        order++;
    }
    add_page(order,base);
    merge_page(order,base);
}

static size_t
buddy_system_nr_free_pages(void) {//计算空闲页面的数量，空闲块*块大小（与链表序号有关）
    size_t num = 0;
    for(int i = 0; i < MAX_ORDER; i++) {
        num += nr_free(i) << i;
    }
    return num;
}

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

