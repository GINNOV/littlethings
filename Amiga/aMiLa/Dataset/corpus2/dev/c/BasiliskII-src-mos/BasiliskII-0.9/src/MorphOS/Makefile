# MorphOS makefile for Basilisk II

## System specific configuration
STRIP = strip
CC = g++ -noixemul
CXX = g++ -noixemul
CXXFLAGS = -g -O3 -funroll-loops -finline-functions -ffast-math -mcpu=750 -mstring -mmultiple -Wall -Wno-multichar
CPPFLAGS = -I../include -I../uae_cpu -I.
DEFS =
LDFLAGS = -noixemul
LIBS =
AS = as
ASFLAGS =
CATCOMP = catcomp

ECHO = echo
ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

## Files
CPUSRCS = ../uae_cpu/basilisk_glue.cpp ../uae_cpu/newcpu.cpp ../uae_cpu/memory.cpp	\
	../uae_cpu/readcpu.cpp ../uae_cpu/fpu/fpu_uae.cpp cpustbl.cpp cpudefs.cpp cpuemu.cpp

SRCS = ../main.cpp main_morphos.cpp guithread.cpp ../prefs.cpp ../prefs_items.cpp \
    prefs_morphos.cpp sys_morphos.cpp ../rom_patches.cpp \
    ../slot_rom.cpp ../rsrc_patches.cpp ../emul_op.cpp \
    ../macos_util.cpp ../xpram.cpp xpram_morphos.cpp ../timer.cpp \
    timer_morphos.cpp clip_morphos.cpp ../adb.cpp ../serial.cpp \
    serial_morphos.cpp ../ether.cpp ether_morphos.cpp ../sony.cpp ../disk.cpp \
    ../cdrom.cpp ../scsi.cpp scsi_morphos.cpp ../video.cpp video_morphos.cpp \
    ../audio.cpp audio_morphos.cpp ../extfs.cpp extfs_morphos.cpp \
    ../user_strings.cpp user_strings_morphos.cpp prefs_editor_morphos.cpp mui.cpp \
	$(CPUSRCS)

APP = BasiliskII

## Rules
.PHONY: clean distclean
.SUFFIXES:
.SUFFIXES: .c .cpp .asm .o .h

all: $(APP)

OBJ_DIR = obj
$(OBJ_DIR)::
	@[ -d $(OBJ_DIR) ] || mkdir $(OBJ_DIR) > /dev/null 2>&1

define SRCS_LIST_TO_OBJS
	$(addprefix $(OBJ_DIR)/, $(addsuffix .o, $(foreach file, $(SRCS), \
	$(basename $(notdir $(file))))))
endef
OBJS = $(SRCS_LIST_TO_OBJS)

SRC_PATHS += $(sort $(foreach file, $(SRCS), $(dir $(file))))
VPATH :=
VPATH += $(addprefix :, $(subst  ,:, $(filter-out $($(subst, :, ,$(VPATH))), $(SRC_PATHS))))

$(APP): $(OBJ_DIR) $(OBJS)
	$(LINKING)
	@$(CXX) -o $(APP).db $(LDFLAGS) $(OBJS) $(LIBS)
	$(STRIPPING)
	@$(STRIP) --remove-section=.comment $(APP).db -o $(APP)
	@protect $(APP) +e

clean:
	rm -f $(APP) $(OBJ_DIR)/* *.db *.s obj.0000.*

dump:
	objdump --disassemble BasiliskII.db >BasiliskII.s

locale: locale/locale.c locale/locale.h

locale/basilisk.ct: locale/basilisk.cd
	@$(CATCOMP) locale/basilisk.cd CTFILE locale/basilisk.ct

locale/locale.h: locale/basilisk.cd locale/basilisk.ct
	@$(CATCOMP) locale/basilisk.cd CFILE locale/locale.h NOSTRINGS NOARRAY NOBLOCK NOCODE

locale/locale.c: locale/basilisk.cd locale/basilisk.ct
	@$(CATCOMP) locale/basilisk.cd CFILE locale/locale.c NOBLOCK NOCODE

distclean: clean
	rm -rf $(OBJ_DIR)

$(OBJ_DIR)/%.o : %.cpp
	$(COMPILING)
	@$(CXX) $(CPPFLAGS) $(DEFS) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o : %.c
	$(COMPILING)
	@$(CC) -noixemul $(CPPFLAGS) $(DEFS) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/cpuopti: $(OBJ_DIR)/cpuopti.o
	$(COMPILING)
	@$(CC) $(LDFLAGS) -o $(OBJ_DIR)/cpuopti $(OBJ_DIR)/cpuopti.o
$(OBJ_DIR)/build68k: $(OBJ_DIR)/build68k.o
	$(COMPILING)
	@$(CC) $(LDFLAGS) -o $(OBJ_DIR)/build68k $(OBJ_DIR)/build68k.o
$(OBJ_DIR)/gencpu: $(OBJ_DIR)/gencpu.o $(OBJ_DIR)/readcpu.o $(OBJ_DIR)/cpudefs.o
	$(COMPILING)
	@$(CC) $(LDFLAGS) -o $(OBJ_DIR)/gencpu $(OBJ_DIR)/gencpu.o $(OBJ_DIR)/readcpu.o $(OBJ_DIR)/cpudefs.o
cpudefs.cpp: $(OBJ_DIR)/build68k ../uae_cpu/table68k
	$(COMPILING)
	@$(OBJ_DIR)/build68k <../uae_cpu/table68k >cpudefs.cpp
cpuemu.cpp: $(OBJ_DIR)/gencpu
	$(COMPILING)
	@$(OBJ_DIR)/gencpu

cpustbl.cpp: cpuemu.cpp
cputbl.h: cpuemu.cpp

$(OBJ_DIR)/cpuemu1.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_1 $(CXXFLAGS) -c $< -o $@
$(OBJ_DIR)/cpuemu2.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_2 $(CXXFLAGS) -c $< -o $@
$(OBJ_DIR)/cpuemu3.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_3 $(CXXFLAGS) -c $< -o $@
$(OBJ_DIR)/cpuemu4.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_4 $(CXXFLAGS) -c $< -o $@
$(OBJ_DIR)/cpuemu5.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_5 $(CXXFLAGS) -c $< -o $@
$(OBJ_DIR)/cpuemu6.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_6 $(CXXFLAGS) -c $< -o $@
$(OBJ_DIR)/cpuemu7.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_7 $(CXXFLAGS) -c $< -o $@
$(OBJ_DIR)/cpuemu8.o: cpuemu.cpp
	$(CXX) $(CPPFLAGS) $(DEFS) -DPART_8 $(CXXFLAGS) -c $< -o $@

#cpufast.s: cpuemu.cpp $(OBJ_DIR)/cpuopti
#	$(CXX) $(INCLUDES) -S $(CFLAGS) $< -o cputmp.s
#	$(OBJ_DIR)/cpuopti <cputmp.s >$@ || mv cputmp.s $@
#	rm -f cputmp.s

#-------------------------------------------------------------------------
# DO NOT DELETE THIS LINE -- make depend depends on it.
