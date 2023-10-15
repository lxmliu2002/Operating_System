#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__

#include <defs.h>

void slub_init(void);

void *slub_alloc(size_t size);
void slub_free(void *objp);
void slub_check();

#endif /* !__KERN_MM_SLUB_MM_H__ */

