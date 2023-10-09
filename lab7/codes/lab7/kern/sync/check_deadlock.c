#include <check_deadlock.h>
#include <assert.h>
#include <kmalloc.h>

void check_deadlock_init() {
    list_init(&(psgp->proc_nodes));
    list_init(&(psgp->sem_ndoes));
}

void check_deadlock() {

}

static int
DFS() {

}

void add_link(struct proc_struct* proc, semaphore_t* sem, int type) {
    struct proc_node* procn = NULL, *proc_temp = NULL;
    struct sem_node* semn = NULL, *sem_temp = NULL;
    // 查找链表中是否存在该线程
    list_entry_t* list = &(psgp->proc_nodes), *le;
    le = list;
    while ((le = list_next(le)) != list) {
        proc_temp = le2procnode(le, proc_node_link);
        if(proc_temp == proc) {
            procn = proc_temp;
            break;
        }
    }
    // 查找链表中是否存在该信号量
    list = &(psgp->sem_ndoes);
    le = list;
    while ((le = list_next(le)) != list) {
        sem_temp = le2semnode(le, sem_node_link);
        if(sem_temp == sem) {
            semn = sem_temp;
            break;
        }
    }
    // 如果不存在，新建节点
    if(procn == NULL) {
        procn = kmalloc(sizeof(struct proc_node));
        procn->proc = proc;
        procn->help_visited = 0;
        procn->visited = 0;
        procn->wait_sem = NULL;
        list_init(&(procn->sem_list));
    }
    if(semn == NULL) {
        semn = kmalloc(sizeof(struct sem_node));
        semn->sem = sem;
        semn->visited = 0;
        semn->help_visited = 0;
        semn->proc_node = NULL;
        list_init(&(semn->proc_list));
    }
    if(type == PORC_WAIT_SEM) {
        procn->wait_sem = semn;
        semn->proc_node = procn;
    } 
    else if(type == SEM_SUB_PROC) {
        list_add(&(semn->proc_list), &(proc->sem_link));
        list_add(&(procn->sem_list), &(semn->sem_node_for_proc));
    }
    else{
        panic("insert type erorr\n");
    }
}

void remove_link(struct proc_struct* proc, semaphore_t* sem, int type) {
    struct proc_node* procn = NULL;
    struct sem_node* semn = NULL;
    list_entry_t* proc_le, *sem_le;
    // 查找链表中是否存在该线程
    list_entry_t* list = &(psgp->proc_nodes), *le;
    le = list;
    while ((le = list_next(le)) != list) {
        procn = le2procnode(le, proc_node_link);
        if(procn == proc) {
            break;
        }
    }
    proc_le = le;
    assert(procn != NULL);
    
    // 查找链表中是否存在该信号量
    list = &(psgp->sem_ndoes);
    le = list;
    while ((le = list_next(le)) != list) {
        semn = le2semnode(le, sem_node_link);
        if(semn == sem) {
            break;
        }
    }
    assert(semn != NULL);
    sem_le = le;
    if(type == PORC_WAIT_SEM) {
        procn->wait_sem = NULL;
        semn->proc_node = NULL;
        
    } 
    else if(type == SEM_SUB_PROC) {
        list_entry_t* proc_list = &(psgp->proc_nodes), *ple;
        struct proc_struct* temp_proc;
        while ((ple = list_next(ple)) != proc_list) {
            temp_proc = le2proc(ple, sem_link);
            if(temp_proc == proc)
                break;
        }
        list_del(ple);
        list_entry_t* sem_list = &(procn->sem_list), *sle;
        struct sem_node* temp_node;
        while ((sle = list_next(sle)) != sem_list) {
            temp_node = le2semnode(sle, sem_node_for_proc);
            if(temp_node == semn)
                break;
        }
        assert(temp_node != NULL);
        list_del(sle);

        
    }
    else {
        panic("delete tpe error\n");
    }
    if(list_empty(&(procn->sem_list)) && procn->wait_sem == NULL) {
        list_del(proc_le);
        kfree(procn);
    }
    if(list_empty(&(semn->proc_list)) && semn->proc_node == NULL) {
        list_del(le);
        kfree(semn);
    }
}