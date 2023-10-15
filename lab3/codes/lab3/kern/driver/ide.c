#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}

#define MAX_IDE 2
#define MAX_DISK_NSECS 56 //最大扇区数
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;//数据在 ide 数组中的偏移量
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);//从ide数组中的iobase位置开始的数据复制到目的地址dst，nsecs * SECTSIZE 表示要复制的总字节数
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,//ideno: 假设挂载了多块磁盘， 选择哪一块磁盘这里我们其实只有一块“ 磁盘” ， 这个参数就没用到
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}
