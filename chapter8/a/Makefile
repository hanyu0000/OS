# 变量定义
NASM = nasm
GCC = gcc
LD = ld
DD = dd
BOCHS = bochs
IMG = /home/hanyu/OS/HD60.img

# 编译参数
NASMFLAGS = -I boot/include/
GCCFLAGS = -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin -fno-stack-protector
LDFLAGS = -m elf_i386 -Ttext 0xc0001500 -e main

# 文件路径
MBR = boot/mbr.bin
LOADER = boot/loader.bin
KERNEL_BIN = build/kernel.bin
BOCHSRC = /home/hanyu/OS/bochsrc.disk

# 编译和链接目标文件
OBJ = build/main.o build/init.o build/interrupt.o build/print.o build/kernel.o build/timer.o

.PHONY: all clean run bochs

all: $(IMG)

# 编译MBR
$(MBR): boot/mbr.S
	$(NASM) $(NASMFLAGS) -o $@ $<

# 编译Loader
$(LOADER): boot/loader.S
	$(NASM) $(NASMFLAGS) -o $@ $<

# 编译内核模块
build/%.o: %.c
	$(GCC) $(GCCFLAGS) -o $@ $<

# 编译汇编内核模块
build/%.o: %.S
	$(NASM) -f elf -o $@ $<

# 链接内核
$(KERNEL_BIN): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ)

# 将 MBR、Loader 和内核写入到镜像文件
$(IMG): $(MBR) $(LOADER) $(KERNEL_BIN)
	$(DD) if=$(MBR) of=$(IMG) bs=512 count=1 conv=notrunc
	$(DD) if=$(LOADER) of=$(IMG) bs=512 count=4 seek=2 conv=notrunc
	$(DD) if=$(KERNEL_BIN) of=$(IMG) bs=512 count=200 seek=9 conv=notrunc

# 运行 bochs
bochs: $(IMG)
	$(BOCHS) -f $(BOCHSRC) -q

# 清理生成的文件
clean:
	rm -f boot/*.bin build/*.o $(KERNEL_BIN)
