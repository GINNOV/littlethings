# ===== Amiga m68k (vbcc) Makefile =====

# Toolchain roots (override with environment if you like)
VBCC    ?= /opt/vbcc

# Compilers/Tools
VC      := $(VBCC)/bin/vc +aos68k
VAS     := $(VBCC)/bin/vasmm68k_mot

# NDK include paths (override if yours live elsewhere)
NDK_H   ?= /opt/amiga-ndk-3.9/NDK_3.9/Include/include_h
NDK_I   ?= /opt/amiga-ndk-3.9/NDK_3.9/Include/include_i

# Flags
CFLAGS  ?= -O1 -I"$(NDK_H)" -I"$(NDK_I)"
ASFLAGS ?= -quiet -Fhunk -nowarn=62 -devpac -I"$(NDK_I)"
LDFLAGS ?= -lamiga

# Folders
SRC_DIR := src
OBJ_DIR := build/obj
BIN_DIR := build

# Programs to build (add more .c files and they’ll get a matching binary)
PROGRAMS := dos_hello reaction_hello
BINS     := $(addprefix $(BIN_DIR)/,$(PROGRAMS))

# Common objects (optional)
OBJS_COMMON := $(OBJ_DIR)/asm_sample.o

# Per-program objects (1:1 with the .c file)
OBJ_C := $(addprefix $(OBJ_DIR)/,$(addsuffix .o,$(PROGRAMS)))

# All objects
OBJS  := $(OBJS_COMMON) $(OBJ_C)

# Default
all: $(BINS)

# --- Link rules (each program links its own .o + common objs) ---
$(BIN_DIR)/%: $(OBJ_DIR)/%.o $(OBJS_COMMON) | $(BIN_DIR)
	$(VC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

# --- Compile rules ---
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(VC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(VAS) $(ASFLAGS) $< -o $@

# --- Dirs ---
$(OBJ_DIR) $(BIN_DIR):
	mkdir -p $@

# --- Convenience targets ---
.PHONY: clean info $(PROGRAMS)
$(PROGRAMS): %: $(BIN_DIR)/%

clean:
	rm -rf $(BIN_DIR)

info:
	@echo "VC       = $(VC)"
	@echo "VAS      = $(VAS)"
	@echo "NDK_H    = $(NDK_H)"
	@echo "NDK_I    = $(NDK_I)"
	@echo "PROGRAMS = $(PROGRAMS)"
	@echo "BINS     = $(BINS)"
	@echo "OBJS     = $(OBJS)"