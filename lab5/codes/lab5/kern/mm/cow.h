#ifndef __KERN_MM_COW_H__
#define __KERN_MM_COW_H__

#include <proc.h>

int cow_copy_mm(struct proc_struct *proc);
int cow_copy_mmap(struct mm_struct *to, struct mm_struct *from);
int cow_copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end);
int cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);



#endif 