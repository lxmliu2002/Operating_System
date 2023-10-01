#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }//启用中断
                                                         //具体来说，它使用 set_csr 函数将 SSTATUS（Supervisor Status Register） 寄存器的 SIE 位设置为1，以允许中断

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
