#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <buddy_system_pmm.h>
#include <slub_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <../sync/sync.h>
#include <riscv.h>

// virtual address of physical page array
struct Page *pages;
// amount of physical memory (in pages)
size_t npage = 0;
// the kernel image is mapped at VA=KERNBASE and PA=info.base
uint64_t va_pa_offset;
// memory starts at 0x80000000 in RISC-V
// DRAM_BASE defined in riscv.h as 0x80000000
const size_t nbase = DRAM_BASE / PGSIZE;//(npage - nbase)表示物理内存的页数

// virtual address of boot-time page directory
uintptr_t *satp_virtual = NULL;
// physical address of boot-time page directory
uintptr_t satp_physical;

// physical memory management
const struct pmm_manager *pmm_manager;


static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &best_fit_pmm_manager;
    // pmm_manager = &buddy_system_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *alloc_pages(size_t n) { //分配一连串的物理页面
    struct Page *page = NULL; //存储分配的物理页面的起始地址
    bool intr_flag; //保存当前中断状态的标志位
    local_intr_save(intr_flag); //调用 local_intr_save 宏，保存当前的中断状态，并禁用中断
    {
        page = pmm_manager->alloc_pages(n); //调用 pmm_manager 指针指向的物理内存管理器的 alloc_pages 函数来分配 n 个物理页面。分配的结果（起始地址）将被赋给 page 变量
    }
    local_intr_restore(intr_flag); //调用 local_intr_restore 宏，根据之前保存的中断状态 intr_flag 来恢复中断状态
    return page; //返回分配的物理页面的起始地址。如果分配失败，将返回NULL
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) { //释放一连串的物理页面
    bool intr_flag; //保存当前中断状态的标志位
    local_intr_save(intr_flag); //调用 local_intr_save 宏，保存当前的中断状态，并禁用中断
    {
        pmm_manager->free_pages(base, n); //调用 pmm_manager 指针指向的物理内存管理器的 free_pages 函数来释放从 base 起始的 n 个物理页面
    }
    local_intr_restore(intr_flag); //调用 local_intr_restore 宏，根据之前保存的中断状态 intr_flag 来恢复中断状态
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) of current free memory
size_t nr_free_pages(void) { //获取当前系统中的空闲物理页面数量
    size_t ret; //存储获取到的空闲物理页面数量
    bool intr_flag; //保存当前中断状态的标志位
    local_intr_save(intr_flag); //调用 local_intr_save 宏，保存当前的中断状态，并禁用中断
    {
        ret = pmm_manager->nr_free_pages(); //调用 pmm_manager 指针指向的物理内存管理器的 nr_free_pages 函数来获取当前系统中的空闲物理页面数量
    }
    local_intr_restore(intr_flag); //调用 local_intr_restore 宏，根据之前保存的中断状态 intr_flag 来恢复中断状态
    return ret; //返回获取到的空闲物理页面数量
}

static void page_init(void) { //建立物理内存的映射，创建空闲页面列表以便后续的内存分配，以及标记内核已经占用的内存块
    va_pa_offset = PHYSICAL_MEMORY_OFFSET; // 设置虚拟地址和物理地址的偏移量，通常用于处理虚拟地址和物理地址之间的转换
                                           //硬编码0xFFFFFFFF40000000
    //通过硬编码方式设置了物理内存的起始地址、总大小、结束地址
    uint64_t mem_begin = KERNEL_BEGIN_PADDR;//硬编码0x80200000
    uint64_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;
    uint64_t mem_end = PHYSICAL_MEMORY_END; //硬编码取代 sbi_query_memory()接口
                                            //硬编码0x88000000

    cprintf("physcial memory map:\n");//输出物理内存的信息，包括内存大小、起始和结束地址
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin, mem_end - 1);

    uint64_t maxpa = mem_end; //可用物理内存的最大地址

    if (maxpa > KERNTOP) {//如果 maxpa 超过了内核地址空间的顶部 KERNTOP，则将 maxpa 设置为 KERNTOP
        maxpa = KERNTOP;
    }

    extern char end[]; //表示内核代码段的结束地址

    npage = maxpa / PGSIZE; //表示总的页面数。计算方式是将 maxpa 除以页面大小 PGSIZE。PGSIZE = 4096
    //kernel在end[]结束, pages是剩下的页的开始
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE); //表示剩余的可用页面的起始地址。这些页面将用于构建空闲页面列表
                                                         //把pages指针指向内核所占内存空间结束后的第一页
    //一开始把所有页面都设置为保留给内核使用的， 之后再设置哪些页面可以分配给其他程序
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);//将前面计算得到的 npage - nbase 个页面标记为已保留状态（Reserved）
    }

    //从这个地方开始才是我们可以自由使用的物理内存
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));//表示剩余的可用内存的起始物理地址，即空闲页面列表的起始
    //按照页面大小PGSIZE进行对齐, ROUNDUP, ROUNDDOWN是在libs/defs.h定义的
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    if (freemem < mem_end) {
        //初始化我们可以自由使用的物理内存
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);//初始化内存映射，将从 freemem 到 mem_end 之间的内存块映射为一系列空闲页面。这些页面将用于后续的动态内存分配
    }
}

/* pmm_init - 初始化物理内存管理 */
void pmm_init(void) {
    // 我们需要分配/释放物理内存（粒度为4KB或其他大小）。
    // 因此，在 pmm.h 中定义了物理内存管理器的框架（struct pmm_manager）。
    // 首先，我们应该基于这个框架来初始化一个物理内存管理器（pmm）。
    // 然后，pmm 可以分配/释放物理内存。
    // 目前，有第一适应（first_fit）、最佳适应（best_fit）、最差适应（worst_fit）和伙伴系统（buddy_system）的物理内存管理器可用。
    init_pmm_manager();

    // 检测物理内存空间，保留已使用的内存，然后使用 pmm->init_memmap 来创建空闲页面列表
    page_init();//建立物理内存的映射，创建空闲页面列表以便后续的内存分配，以及标记内核已经占用的内存块

    // 使用 pmm->check 来验证物理内存管理器中分配/释放函数的正确性
    check_alloc_page();

    extern char boot_page_table_sv39[]; //把汇编里定义的页表所在位置的符号声明进来
    satp_virtual = (pte_t*)boot_page_table_sv39; 
    satp_physical = PADDR(satp_virtual); //输出页表所在的地址
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}


static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
