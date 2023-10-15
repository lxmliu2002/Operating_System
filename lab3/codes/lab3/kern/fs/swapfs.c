#include <swap.h>
#include <swapfs.h>
#include <mmu.h>
#include <fs.h>
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) { //完成检查并初始化交换文件系统
    static_assert((PGSIZE % SECTSIZE) == 0);//确保交换文件系统操作合理
    if (!ide_device_valid(SWAP_DEV_NO)) {//是否有可用的IDE设备作为交换文件系统的后备存储设备
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);//可以使用的最大交换偏移量
}

int
swapfs_read(swap_entry_t entry, struct Page *page) {//用于从交换文件系统中读取数据
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {//用于向交换文件系统写入数据
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

