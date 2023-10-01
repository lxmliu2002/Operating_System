#include <clock.h>
#include <defs.h>
#include <sbi.h>
#include <stdio.h>
#include <riscv.h>

volatile size_t ticks;

static inline uint64_t get_cycles(void) {
#if __riscv_xlen == 64
    uint64_t n;
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    return n;
#else
    uint32_t lo, hi, tmp;
    __asm__ __volatile__(
        "1:\n"
        "rdtimeh %0\n"
        "rdtime %1\n"
        "rdtimeh %2\n"
        "bne %0, %2, 1b"
        : "=&r"(hi), "=&r"(lo), "=&r"(tmp));
    return ((uint64_t)hi << 32) | lo;
#endif
}

// Hardcode timebase
static uint64_t timebase = 100000;

/* *
 * clock_init - 初始化8253时钟，以每秒100次中断的频率工作，
 * 然后启用IRQ_TIMER中断。
 * */
void clock_init(void) {
    // 在sie中启用定时器中断
    set_csr(sie, MIP_STIP); //这行代码通过设置 Control and Status Register (CSR) 的 sie 字段中的 MIP_STIP 位，启用了计时器中断。它告诉处理器在定时器中断发生时触发中断
    // 当使用Spike（2MHz）时，除以500
    // 当使用QEMU（10MHz）时，除以100
    // 时间基准 = sbi_timebase() / 500;
    clock_set_next_event(); //设置下一个时钟中断的触发时间

    // 初始化时间计数器 'ticks' 为零
    ticks = 0; //跟踪系统的运行时间，每次时钟中断时会递增

    cprintf("++ setup timer interrupts\n");
}


void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
