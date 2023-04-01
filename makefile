ASM=nasm

BOOTSRC_DIR=src/bootmgr
KERNELSRC_DIR=src/kernel
BUILD_DIR=build

.PHONY: all floppy_image kernel bootmgr clean always 

#
# Floppy image
#
floppy_image: $(BUILD_DIR)/main_floppy.img


$(BUILD_DIR)/main_floppy.img: bootmgr kernel
	cp $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/main_floppy.img
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img

#
# Bootloader
#
bootmgr: $(BUILD_DIR)/bootmgr.bin

$(BUILD_DIR)/bootmgr.bin: always
	$(ASM) $(BOOTSRC_DIR)/bootloader.asm -f bin -o $(BUILD_DIR)/bootmgr.bin

	
#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(KERNELSRC_DIR)/kernel.asm -f bin -o $(BUILD_DIR)/kernel.bin

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)
#
# Clean
#
clean:
	rm -rf $(BUILD_DIR)/*
