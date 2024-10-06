# 定义汇编器和目标文件名
NASM = nasm
DD = dd
DISK_IMG = /home/hanyu/bochs/HD60.img

# 目标文件
MBR_BIN = mbr.bin
LOADER_BIN = loader.bin

# 默认目标
all: write_mbr write_loader

# 编译 MBR
$(MBR_BIN): 
	$(NASM) -I $(INCLUDE_DIR) -o $@ $(MBR_SRC)

# 编译 Loader
$(LOADER_BIN): 
	$(NASM) -I $(INCLUDE_DIR) -o $@ $(LOADER_SRC)

# 写入 MBR 到磁盘映像
write_mbr: $(MBR_BIN)
	$(DD) if=$(MBR_BIN) of=$(DISK_IMG) bs=512 count=1 conv=notrunc

# 写入 Loader 到磁盘映像
write_loader: $(LOADER_BIN)
	$(DD) if=$(LOADER_BIN) of=$(DISK_IMG) bs=512 count=1 seek=2 conv=notrunc

# 清理生成的文件
clean:
	rm -f $(MBR_BIN) $(LOADER_BIN)

# 伪目标
.PHONY: all clean write_mbr write_loader