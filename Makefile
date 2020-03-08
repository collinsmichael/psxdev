# **************************************************************************** #
# Top Level Makefile simply includes submakes (Makefiles) from sub directories #
# And then builds those files accordingly.                                     #
# **************************************************************************** #
BIN_DIR:=bin
SRC_DIR:=src
INC_DIR:=inc
OBJ_DIR:=obj
ELF+=$(OBJ_DIR)/game.elf
BIN+=$(OBJ_DIR)/game.bin
TRG+=$(BIN_DIR)/game.prg
HDR+=$(SRC_DIR)/psx.hdr
ISO+=game.iso

CC:=mips-linux-gnu-gcc
AS:=mips-linux-gnu-as
LD:=mips-linux-gnu-ld
DUMP:=mips-linux-gnu-objdump
COPY:=mips-linux-gnu-objcopy
MKISO:=genisoimage
CC_FLAGS:=-c -s -EL -mabi=32 -nostartfiles -nostdlib
AS_FLAGS:=
LD_FLAGS:=-EL 

# **************************************************************************** #
# These variables are populated by makefiles from sub directories. Once these  #
# are populated we generate a list of outputs (sorted by language/compiler).   #
# **************************************************************************** #
include $(shell find $(SRC_DIR) -name *.mk)

OBJ += $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.c.o, $(CC_SRC))
OBJ += $(patsubst $(SRC_DIR)/%.s, $(OBJ_DIR)/%.s.o, $(AS_SRC))

CLEAN += $(TRG)
CLEAN += $(BIN)
CLEAN += $(ISO)
CLEAN += $(shell find $(BIN_DIR) -name *.prg)
CLEAN += $(shell find $(OBJ_DIR) -name *.elf)
CLEAN += $(shell find $(OBJ_DIR) -name *.o)

# **************************************************************************** #
# This section contains the build rules. The naming convention is used so that #
# we can target asm/c/c++ without introducing complexity to the build process. #
# **************************************************************************** #
.PHONY: all clean test
all: $(ISO) $(TRG) $(ELF)

help:
	@echo "make targets are as follows"
	@echo "    make clean                   ... Clean everything"
	@echo "    make all [debug]             ... Build everything (default)"
	@echo "    make iso                     ... Build cd image"
	@echo "    make test                    ... Build tests"

clean:
	rm -rf $(CLEAN)

$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	mkdir -p $(dir $@)
	$(CC) -o $@ -c $< $(CC_FLAGS)

$(OBJ_DIR)/%.s.o: $(SRC_DIR)/%.s
	mkdir -p $(dir $@)
	$(AS) $(AS_FLAGS) $< -o $@

# **************************************************************************** #
# Link                                                                         #
# **************************************************************************** #
$(ISO): $(TRG)
	$(MKISO) -o $@ $(BIN_DIR)

$(TRG): $(ELF)
	mkdir -p $(dir $@)
	$(COPY) $? -O binary $(BIN)
	cat $(HDR) $(BIN) > $@

$(ELF): $(OBJ)
	mkdir -p $(dir $@)
	$(LD) -o $@ $? $(LD_FLAGS) -T $(SRC_DIR)/main.ld

