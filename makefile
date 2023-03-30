ASM = nasm

BOOTSRC_DIR=src/bootmgr
BUILD_DIR=build

$(BUILD_DIR)/floppy.img: $(BUILD_DIR)/bootmgr.bin
	cp $(BUILD_DIR)/bootmgr.bin $(BUILD_DIR)/floppy.img
	truncate -s 1440k $(BUILD_DIR)/floppy.img
	

$(BUILD_DIR)/bootmgr.bin: $(BOOTSRC_DIR)/bootloader.asm
	$(ASM) $(BOOTSRC_DIR)/bootloader.asm -f bin -o $(BUILD_DIR)/bootmgr.bin
