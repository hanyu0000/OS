# 定义编译器和工具
NASM = nasm
GCC = gcc
LD = ld
DD = dd
BOCHS = bochs
DISK_IMG = /home/hanyu/OS/HD60.img
BOCHSRC = /home/hanyu/OS/bochsrc.disk
BOOT_DIR = boot
LIB_DIR = lib/kernel
KERNEL_DIR = kernel
NASM_INCLUDE = $(BOOT_DIR)/include/

# 默认目标
all: mbr loader print kernel

# 编译 mbr
mbr: $(BOOT_DIR)/mbr.S
	$(NASM) -I $(NASM_INCLUDE) -o $(BOOT_DIR)/mbr.bin $(BOOT_DIR)/mbr.S
	$(DD) if=$(BOOT_DIR)/mbr.bin of=$(DISK_IMG) bs=512 count=1 conv=notrunc

# 编译 loader
loader: $(BOOT_DIR)/loader.S
	$(NASM) -I $(NASM_INCLUDE) -o $(BOOT_DIR)/loader.bin $(BOOT_DIR)/loader.S
	$(DD) if=$(BOOT_DIR)/loader.bin of=$(DISK_IMG) bs=512 count=2 seek=2 conv=notrunc

# 编译 print
print: $(LIB_DIR)/print.S
	$(NASM) -f elf -o $(LIB_DIR)/print.o $(LIB_DIR)/print.S

# 编译并链接 kernel
kernel: $(KERNEL_DIR)/main.c $(LIB_DIR)/print.o
	$(GCC) -m32 -I $(LIB_DIR) -c -o $(KERNEL_DIR)/main.o $(KERNEL_DIR)/main.c
	$(LD) -m elf_i386 -Ttext 0xc0001500 -e main -o $(KERNEL_DIR)/kernel.bin $(KERNEL_DIR)/main.o $(LIB_DIR)/print.o
	$(DD) if=$(KERNEL_DIR)/kernel.bin of=$(DISK_IMG) bs=512 count=200 seek=9 conv=notrunc

# 启动 Bochs
bochs:
	$(BOCHS) -f $(BOCHSRC) -q

# 清理生成的二进制文件
clean:
	rm -f $(BOOT_DIR)/*.bin $(LIB_DIR)/*.o $(KERNEL_DIR)/*.o $(KERNEL_DIR)/kernel.bin