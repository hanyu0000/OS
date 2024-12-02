#include "sync.h"
#include "list.h"
#include "global.h"
#include "debug.h"
#include "interrupt.h"

//用于初始化信号量，传入参数就是指向信号量的指针与初值
void sema_init(struct semaphore* psema,uint8_t value){
    psema->value = value;//为信号量赋初值
    list_init(&psema->waiters);//初始化信号量的等待队列
}