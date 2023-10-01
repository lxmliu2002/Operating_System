#ifndef __LIBS_LIST_H__
#define __LIBS_LIST_H__

#ifndef __ASSEMBLER__

#include <defs.h>

/*
 * 简单的双向链表实现。
 * 一些内部函数（以 "__" 开头的函数）在操作整个链表而不是单个元素时很有用，
 * 因为有时我们已经知道下一个/前一个元素，可以直接使用它们而不是使用通用的单个元素函数。
*/

struct list_entry {
    struct list_entry *prev, *next;
};

typedef struct list_entry list_entry_t;

static inline void list_init(list_entry_t *elm) __attribute__((always_inline));
static inline void list_add(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
static inline void list_add_before(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
static inline void list_add_after(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
static inline void list_del(list_entry_t *listelm) __attribute__((always_inline));
static inline void list_del_init(list_entry_t *listelm) __attribute__((always_inline));
static inline bool list_empty(list_entry_t *list) __attribute__((always_inline));
static inline list_entry_t *list_next(list_entry_t *listelm) __attribute__((always_inline));
static inline list_entry_t *list_prev(list_entry_t *listelm) __attribute__((always_inline));
//下面两个函数仅在内部使用， 不对外开放作为接口。
static inline void __list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) __attribute__((always_inline));
static inline void __list_del(list_entry_t *prev, list_entry_t *next) __attribute__((always_inline));

/* *
 * list_init - 初始化一个新的条目
 * @elm:        要初始化的新条目
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
}

/* *
 * list_add - 添加一个新的条目
 * @listelm:    要添加到之后的列表头
 * @elm:        要添加的新条目
 *
 * 在已经在列表中的元素 @listelm 之后插入新元素 @elm。
 * */
static inline void
list_add(list_entry_t *listelm, list_entry_t *elm) {
    list_add_after(listelm, elm);
}

/* *
 * list_add_before - 添加一个新的条目
 * @listelm:    要添加到之前的列表头
 * @elm:        要添加的新条目
 *
 * 在已经在列表中的元素 @listelm 之前插入新元素 @elm。
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
}

/* *
 * list_add_after - 添加一个新的条目
 * @listelm:    要添加到之后的列表头
 * @elm:        要添加的新条目
 *
 * 在已经在列表中的元素 @listelm 之后插入新元素 @elm。
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
}

/* *
 * list_del - 从列表中删除条目
 * @listelm:    要从列表中删除的元素
 *
 * 注意：在此之后，对 @listelm 的 list_empty() 不会返回 true，该条目处于未定义状态。
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
}

/* *
 * list_del_init - 从列表中删除条目并重新初始化
 * @listelm:    要从列表中删除的元素。
 *
 * 注意：在此之后，对 @listelm 的 list_empty() 将返回 true。
 * */
static inline void
list_del_init(list_entry_t *listelm) {
    list_del(listelm);
    list_init(listelm);
}

/* *
 * list_empty - 测试列表是否为空
 * @list:       要测试的列表
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
}

/* *
 * list_next - 获取下一个条目
 * @listelm:    列表头
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
}

/* *
 * list_prev - 获取前一个条目
 * @listelm:    列表头
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
}

/* *
 * 在两个已知连续条目之间插入新条目。
 *
 * 这仅用于已知 prev/next 条目的内部列表操作！
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
    elm->next = next;
    elm->prev = prev;
}

/* *
 * 通过使 prev/next 条目相互指向对方来删除列表条目。
 *
 * 这仅用于已知 prev/next 条目的内部列表操作！
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
    next->prev = prev;
}

#endif /* !__ASSEMBLER__ */

#endif /* !__LIBS_LIST_H__ */
