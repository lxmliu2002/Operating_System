#ifndef __KERN_SYNC_CHEK_DEADLOCK_H__
#define __KERN_SYNC_CHEK_DEADLOCK_H__

#include <proc.h>
#include <sem.h>
#include <defs.h>

struct proc_node {
    struct proc_struct* proc;
    struct sem_node* wait_sem;
    list_entry_t sem_list;
    int visited;
    int help_visited;
    list_entry_t proc_node_link;
};

struct sem_node {
    semaphore_t* sem;
    list_entry_t proc_list;
    struct proc_node* proc_node;
    int visited;
    int help_visited;
    list_entry_t sem_node_link;
    list_entry_t sem_node_for_proc;
};

struct proc_sem_graph_t {
    list_entry_t proc_nodes;
    list_entry_t sem_ndoes;
};

#define PORC_WAIT_SEM 0
#define SEM_SUB_PROC 1


#define le2procnode(le, member)          \
    to_struct((le), struct proc_node, member)

#define le2semnode(le, member)          \
    to_struct((le), struct sem_node, member)

extern struct proc_sem_graph_t proc_sem_graph, *psgp = &proc_sem_graph;

void check_deadlock_init();
void check_deadlock();
void add_link(struct proc_struct* proc, semaphore_t* sem, int type);
void remove_link(struct proc_struct* proc, semaphore_t* sem, int type);

#endif /* !__KERN_SYNC_CHEK_DEAD_LOCK_H__ */