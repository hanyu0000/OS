%include "boot.inc"
SECTION MBR vstart=0x7c00               ;起始地址编译为0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
    mov ax,0xb800
    mov gs,ax

    mov ax,0x600
    mov bx,0x700
    mov cx,0
    mov dx,0x184f

    int 0x10                            ;调用BIOS中断，实现清屏

    ;新增功能：直接操作显存部分
    mov byte [gs:0x00],'1'
    mov byte [gs:0x01],0xA4

    mov byte [gs:0x02],' '
    mov byte [gs:0x03],0xA4

    mov byte [gs:0x04],'M'
    mov byte [gs:0x05],0xA4            ;A表示绿色背景闪烁，4表示前景色为红色

    mov byte [gs:0x06],'B'
    mov byte [gs:0x07],0xA4

    mov byte [gs:0x08],'R'
    mov byte [gs:0x09],0xA4

    mov eax,LOADER_START_SECTOR        ; 起始扇区lba地址
    mov bx,LOADER_BASE_ADDR            ; 写入的地址
    mov cx,4                           ; 待读入的扇区数
    call rd_disk_m_16                  ; 以下读取程序的起始部分（一个扇区）

    jmp LOADER_BASE_ADDR + 0x300
;-----------------------------------
;功能：读取硬盘n个扇区
rd_disk_m_16:
                                    ; eax=LBA 扇区号
                                    ; bx=将数据写入的内存地址
                                    ; cx=读入的扇区数
    mov esi,eax                     ;备份eax
    mov di,cx                       ;备份cx
    ;读写硬盘：
;第1步：设置要读取的扇区数
    mov dx,0x1f2
    mov al,cl
    out dx,al                       ;读取的扇区数
    mov eax,esi                     ;恢复ax

;第2步：将LBA地址存入0x1f3~0x1f6
    ;LBA地址7~0位写入端口0x1f3
    mov dx,0x1f3
    out dx,al

    ;LBA地址15~8位写入端口0x1f4
    mov cl,8
    shr eax,cl
    mov dx,0x1f4
    out dx,al

    ;LBA地址23~16位写入端口0x1f5
    shr eax,cl
    mov dx,0x1f5
    out dx,al

    shr eax,cl
    and al,0x0f                     ;lba第24~27位
    or al,0xe0                      ;设置7~4位为1110，表示lba模式
    mov dx,0x1f6
    out dx,al

;第3步：向0x1f7端口写入读命令,0x20
    mov dx,0x1f7
    mov al,0x20
    out dx,al

;第4步：检测硬盘状态
  .not_ready:
    ;同一端口，写时表示写入命令字，读时表示读入硬盘状态
    nop
    in al,dx
    and al,0x88                     ;第4位为1表示硬盘控制器已准备好数据传输，第7位为1表示硬盘忙
    cmp al,0x08
    jnz .not_ready                  ;若未准备好，继续等

;第5步：从0x1f0端口读数据
    mov ax,di
    mov dx,256
    mul dx
    mov cx,ax                       ;di为要读取的扇区数
    mov dx,0x1f0
  .go_on_read:
    in ax,dx
    mov [bx],ax
    add bx,2
    loop .go_on_read
    ret

    times 510-($-$$) db 0           ; 将512B的剩余部分填充为0
    db 0x55,0xaa