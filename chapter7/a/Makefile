# 变量定义
AS = nasm
CC = gcc
LD = ld
ASFLAGS = -I boot/include/ -f elf
CFLAGS = -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin -fno-stack-protector
LDFLAGS = -m elf_i386 -Ttext 0xc0001500 -e main
BUILD_DIR = build
BOOT_DIR = boot
DEVICE_DIR = device
KERNEL_DIR = kernel
LIB_DIR = lib
OUTPUT_IMG = /home/hanyu/OS/HD60.img
BOCHS_CONFIG = /home/hanyu/OS/bochsrc.disk

# 目标文件
BOOT_OBJS = $(BOOT_DIR)/mbr.bin $(BOOT_DIR)/loader.bin
KERNEL_OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o \
              $(BUILD_DIR)/print.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/timer.o

# 目标规则
.PHONY: all clean run

all: $(OUTPUT_IMG)

# 编译引导程序
$(BOOT_DIR)/mbr.bin: $(BOOT_DIR)/mbr.S
	$(AS) -I $(BOOT_DIR)/include/ -o $@ $<

$(BOOT_DIR)/loader.bin: $(BOOT_DIR)/loader.S
	$(AS) -I $(BOOT_DIR)/include/ -o $@ $<

# 编译 C 源文件
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/timer.o: $(DEVICE_DIR)/timer.c
	$(CC) -m32 -I lib/kernel -c -o $@ $<

# 编译汇编源文件
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.S
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(LIB_DIR)/kernel/%.S
	$(AS) $(ASFLAGS) -o $@ $<

# 链接内核
$(BUILD_DIR)/kernel.bin: $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

# 写入硬盘镜像
$(OUTPUT_IMG): $(BOOT_OBJS) $(BUILD_DIR)/kernel.bin
	dd if=$(BOOT_DIR)/mbr.bin of=$(OUTPUT_IMG) bs=512 count=1 conv=notrunc
	dd if=$(BOOT_DIR)/loader.bin of=$(OUTPUT_IMG) bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$(OUTPUT_IMG) bs=512 count=200 seek=9 conv=notrunc

# 清理生成的文件
clean:
	rm -f $(BUILD_DIR)/* $(BOOT_DIR)/*.bin

# 运行 Bochs 模拟器
run: all
	bochs -f $(BOCHS_CONFIG) -q
