#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <slub_pmm.h>
#include <pmm.h>
#include <stdio.h>

struct slob_block {
	int units;//块的大小
	struct slob_block *next;//下一个slot块
};
typedef struct slob_block slob_t;

#define SLOB_UNIT sizeof(slob_t)
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)

struct bigblock {
	int order;
	void *pages;
	struct bigblock *next;
};
typedef struct bigblock bigblock_t;

static slob_t arena = { .next = &arena, .units = 1 };
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size)
{
    assert(size < PGSIZE);

	slob_t *prev, *cur;
	int  units = SLOB_UNITS(size);

	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
		if (cur->units >= units) {

			if (cur->units == units)
				prev->next = cur->next;
			else {
				prev->next = cur + units;
				prev->next->units = cur->units - units;
				prev->next->next = cur->next;
				cur->units = units;
			}
			slobfree = prev;
			return cur;
		}
		if (cur == slobfree) {
			if (size == PGSIZE)
				return 0;
			cur = (slob_t *)alloc_pages(1);
			if (!cur)
				return 0;
			slob_free(cur, PGSIZE);
			cur = slobfree;
		}
	}
}

static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	if (!block)
		return;
	if (size)
		b->units = SLOB_UNITS(size);

	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur;
}

void 
slub_init(void) {
    cprintf("slub_init() succeeded!\n");
}

void *slub_alloc(size_t size)
{
	slob_t *m;
	bigblock_t *bb;

	if (size < PGSIZE - SLOB_UNIT) {
		m = slob_alloc(size + SLOB_UNIT);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t));
	if (!bb)
		return 0;

	bb->order = ((size-1) >> PGSHIFT) + 1;
	bb->pages = (void *)alloc_pages(bb->order);

	if (bb->pages) {
		bb->next = bigblocks;
		bigblocks = bb;
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));
	return 0;
}


void slub_free(void *block)
{
	bigblock_t *bb, **last = &bigblocks;

	if (!block)
		return;

	if (!((unsigned long)block & (PGSIZE-1))) {
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
			if (bb->pages == block) {
				*last = bb->next;
				free_pages((struct Page *)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}

unsigned int slub_size(const void *block)
{
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
		return 0;

	if (!((unsigned long)block & (PGSIZE-1))) {
		for (bb = bigblocks; bb; bb = bb->next)
			if (bb->pages == block) {
				return bb->order << PGSHIFT;
			}
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
}

int slobfree_len()
{
    int len = 0;
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
        len ++;
    return len;
}

void slub_check()
{
    cprintf("slub check begin\n");
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p3);
    cprintf("slobfree len: %d\n", slobfree_len());
    cprintf("slub check end\n");
}