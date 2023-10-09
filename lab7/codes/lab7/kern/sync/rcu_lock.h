#ifndef __KERN_SYNC_RCU_LOCK_H__
#define __KERN_SYNC_RCU_LOCK_H__

void rcu_read_lock();   // 加读锁
void rcu_read_unlock(); // 释放读锁
void syncronize_rcu();  // 挂起写者，等待读者退出后修改数据
void* rcu_assign_pointer(); // 读者获取一个被RCU保护的指针
void* rcu_dereference();    // 写者为RCU保护的指针分配一个新的值


#endif /* !__KERN_SYNC_RCU_LOCK_H__ */