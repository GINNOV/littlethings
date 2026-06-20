# $Id: makefile,v 1.1 2007/01/03 01:35:56 cvsu-ilkleht Exp $

STRIP		= strip
CC			= gcc -noixemul
CDEFS 	= -DUSE_INLINE_STDARG
CFLAGS	= $(CDEFS) -O3 -mcpu=750 -mmultiple -mstring -Wall
TARGET	= empty-handler.elf

OBJS  = empty.c misc.c

ECHO = echo
ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

%.o: %.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -o $@ -c $*.c

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LINKING)
	@$(CC) $(OBJS) -nostartfiles -o $@.db
	$(STRIPPING)
	@$(STRIP) --remove-section=.comment $@.db -o $@

dump:
	objdump --disassemble-all $(TARGET).db >$(TARGET).s

clean: 
	@rm -f *.o *.s $(TARGET)
