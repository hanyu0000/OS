[bits 32]
%define ERROR_CODE nop                      ;一些中断会自动压入错误码,其他的不会。nop是汇编指令,表示 no operation,不操作。在此占位
%define ZERO push 0                         ;有些中断进入前CPU不会压入错误码,对于这类中断,就自己压入32位的0
extern put_str                              ;声明外部函数，为的是调用put_str

section .data
intr_str db "interrupt occur!", 0xa, 0      ;定义中断信息字符串，内容为 "interrupt occur!"，并以 0 结尾
global intr_entry_table                     ;声明 intr_entry_table 作为全局符号，表示中断向量表的入口
intr_entry_table:                           ;标号，标识所有中断处理程序的入口地址存放在这里

%macro VECTOR 2                             ;汇编中的宏用法,用 macro 定义了名为 VECTOR 的宏，接收两个参数
section .text
intr%1entry:                                ;每个中断处理程序都要压入中断向量号,此标号来表示中断处理程序的入口
    %2                                      ;宏传入的第二个参数，不同中断压入不同的值
    push intr_str
    call put_str
    add esp,4                               ;抛弃put_str的字符串地址参数
                                            ;如果是从片上进入的中断,除了往从片上发送EOI外,还要往主片上发送EOI
    mov al,0x20                             ;中断结束命令EOI
    out 0xa0,al                             ;向主片发送OCW2,其中EOI位为1，告知结束中断
    out 0x20,al                             ;向从片发送OCW2,其中EOI位为1，告知结束中断

    add esp,4                               ;对于会压入错误码的中断会抛弃错误码，对于不会压入错误码的中断，就会抛弃上面push的0
    iret                                    ; 从中断返回,32位下等同指令iretd

section .data                               ;这个段就是存的此中断处理函数的地址
    dd    intr%1entry                       ;存储各个中断入口程序的地址，形成intr_entry_table数组,定义的地址是4字节，32位
%endmacro

;调用之前写好的宏来批量生成中断处理函数，传入参数是中断号码与上面中断宏的%2步骤，这个步骤是什么都不做，还是压入0
VECTOR 0x00,ZERO
VECTOR 0x01,ZERO
VECTOR 0x02,ZERO
VECTOR 0x03,ZERO
VECTOR 0x04,ZERO
VECTOR 0x05,ZERO
VECTOR 0x06,ZERO
VECTOR 0x07,ZERO
VECTOR 0x08,ERROR_CODE
VECTOR 0x09,ZERO
VECTOR 0x0a,ERROR_CODE
VECTOR 0x0b,ERROR_CODE
VECTOR 0x0c,ZERO
VECTOR 0x0d,ERROR_CODE
VECTOR 0x0e,ERROR_CODE
VECTOR 0x0f,ZERO
VECTOR 0x10,ZERO
VECTOR 0x11,ERROR_CODE
VECTOR 0x12,ZERO
VECTOR 0x13,ZERO
VECTOR 0x14,ZERO
VECTOR 0x15,ZERO
VECTOR 0x16,ZERO
VECTOR 0x17,ZERO
VECTOR 0x18,ERROR_CODE
VECTOR 0x19,ZERO
VECTOR 0x1a,ERROR_CODE
VECTOR 0x1b,ERROR_CODE
VECTOR 0x1c,ZERO
VECTOR 0x1d,ERROR_CODE
VECTOR 0x1e,ERROR_CODE
VECTOR 0x1f,ZERO
VECTOR 0x20,ZERO