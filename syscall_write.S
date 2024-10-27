;数据段，存储常量字符串
section .date
str_c_lib: db "c library says: hello world!",0xa        ;0xa表示换行
str_c_lib_len equ $-str_c_lib                           ;equ $-str_c_lib 计算当前地址$和str_c_lib的地址差值
                                                        ;表示字符串的字节数
str_syscall: db "syscall says: hello world!",0xa
str_syscall_len equ $-str_syscall

;代码段，存储可执行指令
section .text
global _start                                           ;声明 _start 为全局符号，告诉链接器这是程序的入口点
_start:

;1.模仿c语言中的系统调用库函数
push str_c_lib_len                                      ;将字符串 str_c_lib_len 的长度压入栈，作为第 3 个参数
push str_c_lib                                          ;将字符串 str_c_lib 的地址压入栈，作为第 2 个参数
push 1                                                  ;将文件描述符 1 (标准输出) 压入栈，作为第 1 个参数

call simu_write 
add esp,12                                              ;将 esp 恢复到调用 simu_write 前的状态

;2.直接进行系统调用
mov eax,4                                               ;将 4 号子功能 write 系统调用加载到 eax 寄存器
mov ebx,1                                               ;将文件描述符 1（标准输出）加载到 ebx 寄存器
mov ecx,str_syscall                                     ;将要写入的字符串地址 str_syscall 加载到 ecx
mov edx,str_syscall_len                                 ;将字符串长度 str_syscall_len 加载到 edx
int 0x80                                                ;发起中断，执行 write 系统调用

;退出程序
mov eax,1                                               ;第 1 号子功能是 exit,加载 exit 系统调用号 1 到 eax 寄存器
int 0x80                                                ;触发 0x80 中断，执行 exit 系统调用，结束程序

;模拟 C 库中系统调用函数 write
simu_write:
push ebp                                                ;将当前 ebp 压入栈，以便后续恢复
mov ebp,esp                                             ;将 esp 赋给 ebp，以便通过 ebp 定位参数
mov eax,4                                               ;将 write 系统调用号 4 放入 eax，准备调用 write
mov ebx,[ebp+8]                                         ;第 1 个参数（文件描述符 1），存到 ebx
mov ecx,[ebp+12]                                        ;第 2 个参数（字符串地址 str_c_lib），存到 ecx
mov edx,[ebp+16]                                        ;第 3 个参数字符串长度 str_c_lib_len），存到 edx
int 0x80                                                ;发起 write 系统调用
pop ebp                                                 ;恢复 ebp
ret                                                     ;从函数返回，恢复 _start 中的执行流程