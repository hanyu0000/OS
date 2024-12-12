# 变量定义
BUILD_DIR = build
BOOT_DIR = boot
KERNEL_DIR = kernel
DEVICE_DIR = device
LIB_DIR = lib
THREAD_DIR = thread
OUTPUT_IMG = /home/hanyu/OS/HD60.img
BOCHS_CONFIG = /home/hanyu/OS/bochsrc.disk
ENTRY_POINT = 0xc0001500

AS = nasm
CC = gcc
LD = ld
ASFLAGS = -I $(BOOT_DIR)/include/ -f elf
CFLAGS = -m32 -I $(LIB_DIR)/kernel/ -I $(LIB_DIR)/ -I $(KERNEL_DIR)/ \
         -c -fno-builtin -fno-stack-protector
LDFLAGS = -m elf_i386 -Ttext $(ENTRY_POINT) -e main

BOOT_OBJS = $(BUILD_DIR)/mbr.bin $(BUILD_DIR)/loader.bin
KERNEL_OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/interrupt.o $(BUILD_DIR)/init.o \
              $(BUILD_DIR)/timer.o $(BUILD_DIR)/debug.o $(BUILD_DIR)/memory.o \
              $(BUILD_DIR)/bitmap.o $(BUILD_DIR)/list.o $(BUILD_DIR)/string.o \
              $(BUILD_DIR)/thread.o $(BUILD_DIR)/print.o $(BUILD_DIR)/switch.o \
              $(BUILD_DIR)/kernel.o

# 目标规则
.PHONY: all clean run

all: $(OUTPUT_IMG)

# 编译引导程序
$(BUILD_DIR)/mbr.bin: $(BOOT_DIR)/mbr.S
	$(AS) -I $(BOOT_DIR)/include/ -o $@ $<

$(BUILD_DIR)/loader.bin: $(BOOT_DIR)/loader.S
	$(AS) -I $(BOOT_DIR)/include/ -o $@ $<

# 编译 C 源文件
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(DEVICE_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(LIB_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(LIB_DIR)/kernel/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(THREAD_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

# 编译汇编源文件
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.S
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(LIB_DIR)/kernel/%.S
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(THREAD_DIR)/%.S
	$(AS) $(ASFLAGS) -o $@ $<

# 链接内核
$(BUILD_DIR)/kernel.bin: $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

# 写入硬盘镜像
$(OUTPUT_IMG): $(BOOT_OBJS) $(BUILD_DIR)/kernel.bin
	dd if=$(BUILD_DIR)/mbr.bin of=$(OUTPUT_IMG) bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/loader.bin of=$(OUTPUT_IMG) bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$(OUTPUT_IMG) bs=512 count=200 seek=9 conv=notrunc

# 清理生成的文件
clean:
	rm -f $(BUILD_DIR)/*

# 运行 Bochs 模拟器
run: all
	bochs -f $(BOCHS_CONFIG) -q
