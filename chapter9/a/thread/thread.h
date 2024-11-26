#ifndef __THREAD_THREAD_H
#define __THREAD_THREAD_H
#include "stdint.h"

//定义一种thread_fun的函数类型，返回值是空，参数是一个地址(用来指向自己的参数)
//这样定义，这个类型就能够具有很大的通用性，很多函数都是这个类型
typedef void thread_func(void*);

//进程或者线程的状态
enum task_status {
    TASK_RUNNING,
    TASK_READY,
    TASK_BLOCKED,
    TASK_WAITING,
    TASK_HANGING,
    TASK_DIED
};

/***************   中断栈 intr_stack   ***************
* 此结构用于中断发生时保护程序（线程或进程）的上下文环境:
* 进程或线程被外部中断或软中断打断时，会按照此结构压入上下文
* 寄存器，intr_exit 中的出栈操作是此结构的逆操作
* 此栈在线程自己的内核栈中位置固定，所在页的最顶端
*****************************************************/
struct  intr_stack{
    uint32_t vec_no;        //kernel.S 宏VECTOR中 %1压入的中断号
    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t esp_dummy;     //虽然 pushad 把 esp 也压入，但 esp 是不断变化的，所以会被 popad 忽略
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
    uint32_t gs;
    uint32_t fs;
    uint32_t es;
    uint32_t ds;


//以下由 cpu 从低特权级进入高特权级时压入
    uint32_t err_code;      //err_code 会被压入在 eip 之后
    void (*eip) (void);
    uint32_t cs;
    uint32_t eflags;
    void* esp;
    uint32_t ss;
};

/***************   线程栈 thread_stack   ***************
* 线程自己的栈，用于存储线程中待执行的函数
* 此结构在线程自己的内核栈中位置不固定
* 仅用在 switch_to 时保存线程环境
* 实际位置取决于实际运行情况
******************************************************/
struct thread_stack{
    uint32_t ebp;
    uint32_t ebx;
    uint32_t edi;
    uint32_t esi;

//这个位置会放一个名叫eip,返回void的函数指针(*epi的*决定了这是个指针),该函数传入的参数是一个thread_func类型的函数指针与函数的参数地址,该线程第一次执行时,eip指向待调用的函数kernel_thread,其他时候,eip是指向switch_to的返回地址
    void (*eip)(thread_func* func, void* func_arg);

/********** 以下仅供第一次被调度上 cpu 时使用 **********/
//参数 unused_ret 只为占位置充数为返回地址
    void (*unused_retaddr);
    thread_func* function;          //由 kernel_thread 所调用的函数地址
    void* func_arg;                 //由 kernel_thread 所调用的函数参数地址
};

//进程或线程的pcb,程序控制块,此结构体用于存储线程的管理信息
struct task_struct {
    uint32_t* self_kstack;          //各内核线程都用自己的内核栈
    enum task_status status;
    uint8_t priority;               //线程优先级
    char name[16];
    uint32_t stack_magic;           //栈的边界标记，用于检测栈的溢出
};
void thread_create(struct task_struct* pthread, thread_func function, void* func_arg);
void init_thread(struct task_struct* pthread, char* name, int prio);
struct task_struct* thread_start(char* name, int prio, thread_func function, void* func_arg);
#endif