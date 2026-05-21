# Windows version of VBCC requires absolute path in all .h files
# e.g. timer manager has to refer to timer.h by absolute path

# TODO: refactor so 'make' without args won't recompile whole ACE

# Multi-platform
ifdef ComSpec
	# Windows
	RM = del
	CP = copy
	SLASH = \\
	CURR_DIR=$(shell chdir)
	ECHO = @echo
	NEWLINE = @echo.
	QUIETCOPY = > NUL
else
	# Linux/Amiga
	RM = rm
	CP = cp
	SLASH = /
	CURR_DIR = .
	ECHO = @echo
	NEWLINE = @echo " "
	QUIETCOPY =
endif
SL= $(strip $(SLASH))
SRC_DIR = $(CURR_DIR)$(SL)src

# Directories
TMP_DIR = build
ACE_DIR = ..$(SL)ace
ACE_INC_DIR = $(ACE_DIR)$(SL)include

OF_CC ?= vc

TARGET ?= release
TARGET_DEFINES=
ifeq ($(TARGET), debug)
	TARGET_DEFINES += -DGAME_DEBUG -DACE_DEBUG
endif

INCLUDES = -I$(SRC_DIR) -I$(ACE_DIR)/include
ifeq ($(OF_CC), vc)
	CC_FLAGS = +kick13 -c99 $(INCLUDES) -DAMIGA
	AS_FLAGS = +kick13 -c
	OBJDUMP =
else ifeq ($(OF_CC), m68k-amigaos-gcc)
	CC_FLAGS = -std=gnu11 $(INCLUDES) -DAMIGA -noixemul -Wall -Wextra -fomit-frame-pointer -O3 -fbbb=abcfilmprsz
	AS_FLAGS = -quiet -x -m68010 -Faout
	OBJDUMP = m68k-amigaos-objdump -S -d $@ > $@.dasm
endif
CC_FLAGS += $(TARGET_DEFINES)

# File list
OF_MAIN_FILES = $(wildcard $(SRC_DIR)/*.c)
OF_MAIN_OBJS = $(addprefix $(TMP_DIR)$(SL), $(notdir $(OF_MAIN_FILES:.c=.o)))

OF_GS_GAME_AI_FILES = $(wildcard $(SRC_DIR)/gamestates/game/ai/*.c)
OF_GS_GAME_AI_OBJS = $(addprefix $(TMP_DIR)$(SL)gsgame_ai_, $(notdir $(OF_GS_GAME_AI_FILES:.c=.o)))

OF_GS_GAME_FILES = $(wildcard $(SRC_DIR)/gamestates/game/*.c)
OF_GS_GAME_OBJS = $(addprefix $(TMP_DIR)$(SL)gsgame_, $(notdir $(OF_GS_GAME_FILES:.c=.o)))

OF_GS_MENU_FILES = $(wildcard $(SRC_DIR)/gamestates/menu/*.c)
OF_GS_MENU_OBJS = $(addprefix $(TMP_DIR)$(SL)gsmenu_, $(notdir $(OF_GS_MENU_FILES:.c=.o)))

OF_GS_PRECALC_FILES = $(wildcard $(SRC_DIR)/gamestates/precalc/*.c)
OF_GS_PRECALC_OBJS = $(addprefix $(TMP_DIR)$(SL)gsprecalc_, $(notdir $(OF_GS_PRECALC_FILES:.c=.o)))

ACE_OBJS = $(wildcard $(ACE_DIR)/build/*.o)
ACE_OBJS_CP = $(addprefix $(TMP_DIR)$(SL), $(notdir $(ACE_OBJS:.c=.o)))
OF_FILES = $(OF_MAIN_FILES) $(OF_GS_GAME_FILES) $(OF_GS_GAME_AI_FILES) $(OF_GS_MENU_FILES) $(OF_GS_PRECALC_FILES)
OF_OBJS = $(OF_MAIN_OBJS) $(OF_GS_GAME_OBJS) $(OF_GS_GAME_AI_OBJS) $(OF_GS_MENU_OBJS) $(OF_GS_PRECALC_OBJS)
OF_SU = $(OF_OBJS:.o=.su)
#

oface: ace of

of: $(OF_OBJS) $(ACE_OBJS_CP)
	$(NEWLINE)
	@echo Linking...
	@$(OF_CC) $(CC_FLAGS) -lamiga -o $@ $^

ace: $(ACE_OBJS)
	$(MAKE) -C $(ACE_DIR) all ACE_CC=$(OF_CC) TARGET=$(TARGET)
	$(NEWLINE)
	@echo Copying ACE objs...
	@$(CP) $(ACE_DIR)$(SL)build$(SL)*.o $(TMP_DIR) $(QUIETCOPY)

stack_usage: $(OF_SU)
	@rm $@
	@for file in $^; do \
		cat $$file; \
	done | sort -nrk 2 > $@

# Main files
$(TMP_DIR)$(SL)%.o: $(SRC_DIR)/%.c
	@echo Building $<
	@$(OF_CC) $(CC_FLAGS) -c -o $@ $<

# Game
$(TMP_DIR)$(SL)gsgame_%.o: $(SRC_DIR)/gamestates/game/%.c
	@echo Building $<
	@$(OF_CC) $(CC_FLAGS) -c -o $@ $<

# Game AI
$(TMP_DIR)$(SL)gsgame_ai_%.o: $(SRC_DIR)/gamestates/game/ai/%.c
	@echo Building $<
	@$(OF_CC) $(CC_FLAGS) -c -o $@ $<

# Menu
$(TMP_DIR)$(SL)gsmenu_%.o: $(SRC_DIR)/gamestates/menu/%.c
	@echo Building $<
	@$(OF_CC) $(CC_FLAGS) -c -o $@ $<

# Precalc
$(TMP_DIR)$(SL)gsprecalc_%.o: $(SRC_DIR)/gamestates/precalc/%.c
	@echo Building $<
	@$(OF_CC) $(CC_FLAGS) -c -o $@ $<

all: clean ace of stack_usage

clean:
	$(ECHO) "a" > $(TMP_DIR)$(SL)foo.o
	@$(RM) $(TMP_DIR)$(SL)*.o
