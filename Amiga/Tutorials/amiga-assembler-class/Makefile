VAS ?= vasmm68k_mot
NDK_I ?= /opt/amiga-ndk-3.9/NDK_3.9/Include/include_i

SRC_DIR := src
BUILD_DIR := build

PROGRAMS := \
	00_minimal \
	01_registers \
	02_memory_labels \
	03_branches_loop \
	04_stack_subroutine \
	05_dos_print \
	06_conditions \
	07_record_offsets

ASFLAGS := -quiet -Fhunkexe -nowarn=62 -devpac -I"$(NDK_I)"

BINS := $(addprefix $(BUILD_DIR)/,$(addsuffix .exe,$(PROGRAMS)))

.PHONY: all clean lesson list

all: $(BINS)

lesson:
	@test -n "$(LESSON)" || (echo "Usage: make lesson LESSON=03_branches_loop" && exit 1)
	$(MAKE) "$(BUILD_DIR)/$(LESSON).exe"

list:
	@printf "%s\n" $(PROGRAMS)

$(BUILD_DIR)/%.exe: $(SRC_DIR)/%.s | $(BUILD_DIR)
	$(VAS) $(ASFLAGS) $< -o $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

