#ifndef __KERN_SYNC_SYNC_H__ /*头文件保护机制，用于防止头文件被多次包含*/
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {          /*检查当前 CPU 的中断使能状态，如果中断已启用，则禁用中断并返回1，否则返回0*/
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {   /*根据传入的参数 flag 来恢复中断状态，如果 flag 是1，则重新启用中断*/
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)                     /*创建一个代码块（block），该代码块包含了一系列语句，并使用 do-while 结构将它们包装在一起。
                                      这个结构的主要目的是为了确保宏的使用在语法上是合法的，并且可以在需要的地方作为一个单一的语句使用。
                                    */
#define local_intr_restore(x) __intr_restore(x); 

#endif /* !__KERN_SYNC_SYNC_H__ */
