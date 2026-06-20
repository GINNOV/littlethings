TARGET	 = IRA.elf
GUITARGET = iraGUIMain.elf
PTARGET   = irapost.elf
CC			 = gcc -noixemul
CDEFS		 = -DUSE_INLINE_STDARG -DAROS_ALMOST_COMPATIBLE
INCS		 =
CFLAGS	 = $(CDEFS) $(INCS) -O2 -mcpu=750 -mstring -mmultiple -Wall

LDFLAGS	 =
LIBS		 =

DEPINCLUDES = $(INCS)
DEPFILE = .depend.morphos
DEPOPTS = -noixemul
COBJS_NODEP_DIRS =

include Makefile.objs

ALLOBJS = $(OBJS) $(GUIOBJS) $(POSTOBJS)

ECHO = echo
ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

.PHONY: all
ifeq ($(wildcard $(DEPFILE)),$(DEPFILE))
# nope
all: .depend.check $(TARGET)
else
# yes
all: depend
	@$(MAKE) --no-print-directory $(TARGET) $(GUITARGET)
endif

.depend.check: makefile.objs
	@$(MAKE) --no-print-directory -s depend

.PHONY: depend
depend:
	@echo "generating dependencies (takes about a minute)"
	@sh mkdep.sh -f $(DEPFILE) $(DEPOPTS) $(DEPINCLUDES) $(patsubst %.o,%.c, $(ALLOBJS))
	@touch .depend.check

-include $(DEPFILE)

$(ODIR)%.o: %.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(LINKING)
	@$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) $(LIBS) -o $@.db
	$(STRIPPING)
	@strip --remove-section=.comment $@.db -o $@
	@protect $(TARGET) +e

$(GUITARGET): $(GUIOBJS)
	$(LINKING)
	@$(CC) $(CFLAGS) $(LDFLAGS) $(GUIOBJS) $(LIBS) -o $@.db
	$(STRIPPING)
	@strip --remove-section=.comment $@.db -o $@
	@protect $@ +e

$(PTARGET): $(POSTOBJS)
	$(LINKING)
	@$(CC) $(CFLAGS) $(LDFLAGS) $(POSTOBJS) $(LIBS) -o $@.db
	$(STRIPPING)
	@strip --remove-section=.comment $@.db -o $@
	@protect $@ +e

dump:
	objdump --section-headers --all-headers --reloc --syms --disassemble-all $(TARGET).db >$(TARGET).s

clean:
	@-rm *.o $(TARGET) $(TARGET).db $(TARGET).s
