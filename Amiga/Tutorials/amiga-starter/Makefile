# ===== Amiga m68k (vbcc) Makefile — fixed for standalone ASM exe =====

VBCC    ?= /opt/vbcc
VC      := $(VBCC)/bin/vc +aos68k
VAS     := $(VBCC)/bin/vasmm68k_mot

NDK_H   ?= /opt/amiga-ndk-3.9/NDK_3.9/Include/include_h
NDK_I   ?= /opt/amiga-ndk-3.9/NDK_3.9/Include/include_i

CFLAGS  ?= -O1 -I"$(NDK_H)" -I"$(NDK_I)"
ASFLAGS ?= -quiet -nowarn=62 -devpac -I"$(NDK_I)"
ASFLAGS_EXE ?= -quiet -Fhunkexe -nowarn=62 -devpac -I"$(NDK_I)"
LDFLAGS ?= -lamiga

SRC_DIR := src
OBJ_DIR := build/obj
BIN_DIR := build
BIN_EXT := .exe

PROGRAMS_C   := dos_hello reaction_hello
PROGRAMS_ASM := asm_sample
PROGRAMS     := $(PROGRAMS_C) $(PROGRAMS_ASM)

BINS := $(addprefix $(BIN_DIR)/,$(addsuffix $(BIN_EXT),$(PROGRAMS)))
OBJ_C := $(addprefix $(OBJ_DIR)/,$(addsuffix .o,$(PROGRAMS_C)))

.SECONDARY: $(OBJ_C)

all: $(BINS)

# --- C programs ---
$(BIN_DIR)/%$(BIN_EXT): $(OBJ_DIR)/%.o | $(BIN_DIR)
	$(VC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(VC) $(CFLAGS) -c $< -o $@

# --- ASM programs built directly to exe ---
$(BIN_DIR)/%$(BIN_EXT): $(SRC_DIR)/%.s | $(BIN_DIR)
	$(VAS) $(ASFLAGS_EXE) $< -o $@

$(BIN_DIR)/%$(BIN_EXT): $(SRC_DIR)/%.asm | $(BIN_DIR)
	$(VAS) $(ASFLAGS_EXE) $< -o $@

# --- Dirs ---
$(OBJ_DIR) $(BIN_DIR):
	mkdir -p $@

# --- Convenience ---
.PHONY: clean info $(PROGRAMS)
$(PROGRAMS): %: $(BIN_DIR)/%$(BIN_EXT)

clean:
	rm -rf $(BIN_DIR)

info:
	@echo "PROGRAMS_C   = $(PROGRAMS_C)"
	@echo "PROGRAMS_ASM = $(PROGRAMS_ASM)"
	@echo "BINS         = $(BINS)"