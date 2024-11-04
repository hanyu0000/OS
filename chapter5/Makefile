# 定义编译器和工具变量
NASM = nasm
GCC = gcc
LD = ld
DD = dd
BOCHS = bochs

# 定义路径和选项
BOOT_DIR = boot
KERNEL_DIR = kernel
DISK_IMG = /home/hanyu/OS/HD60.img
BOCHSRC = /home/hanyu/OS/bochsrc.disk
NASM_INCLUDE = $(BOOT_DIR)/include/

# 默认目标
all: mbr loader kernel

# 编译 mbr
mbr: $(BOOT_DIR)/mbr.S
	$(NASM) -I $(NASM_INCLUDE) -o $(BOOT_DIR)/mbr.bin $(BOOT_DIR)/mbr.S
	$(DD) if=$(BOOT_DIR)/mbr.bin of=$(DISK_IMG) bs=512 count=1 conv=notrunc

# 编译 loader
loader: $(BOOT_DIR)/loader.S
	$(NASM) -I $(NASM_INCLUDE) -o $(BOOT_DIR)/loader.bin $(BOOT_DIR)/loader.S
	$(DD) if=$(BOOT_DIR)/loader.bin of=$(DISK_IMG) bs=512 count=2 seek=2 conv=notrunc

# 编译并链接 kernel
kernel: $(KERNEL_DIR)/main.c
	$(GCC) -m32 -c -o $(KERNEL_DIR)/main.o $(KERNEL_DIR)/main.c
	$(LD) -m elf_i386 $(KERNEL_DIR)/main.o -Ttext 0xc0001500 -e main -o $(KERNEL_DIR)/kernel.bin
	$(DD) if=$(KERNEL_DIR)/kernel.bin of=$(DISK_IMG) bs=512 count=200 seek=9 conv=notrunc

# 启动 Bochs
bochs:
	$(BOCHS) -f $(BOCHSRC) -q

# 清理生成的二进制文件
clean:
	rm -f $(BOOT_DIR)/*.bin $(KERNEL_DIR)/*.o $(KERNEL_DIR)/kernel.bin
