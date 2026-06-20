CC=vc
LD=PhxLnk
CFLAGS=-sc -sd
LDFLAGS=SC SD NOSHORTRELOCS
LIBS=vlib:vcs.lib
DEBUGLIBS=$(LIBS) vlib:amiga.lib vlib:debug.lib

FILES =	xad_AmosSampBank.lha xad_ar.lha xad_ASCII.lha xad_bzip.lha \
	xad_bzip2.lha xad_CAB.lha xad_COP.lha xad_DImp.lha xad_HTMLHelp.lha \
	xad_MakeSFX.lha xad_MSA.lha xad_MS-TNEF.lha xad_RPM.lha \
	xad_Wrapster.lha xad_ZAP.lha

EXTRA =	extheader.c Makefile smakefile ConvertE.c SDI_compiler.h vc.config \
	Install.info 

OPT=

all: $(FILES)

%.dbg: extheader.o %.c
	$(CC) $(CFLAGS) -DDEBUG $(OPT) -o $@.o -c $*.c
	$(LD) $(LDFLAGS) extheader.o $@.o $(DEBUGLIBS) TO $@
%.040: extheader.o %.c
	$(CC) $(CFLAGS) -cpu=68040 $(OPT) -o $@.o -c $*.c
	$(LD) $(LDFLAGS) extheader.o $@.o $(LIBS) TO $@
%.020: extheader.o %.c
	$(CC) $(CFLAGS) -cpu=68020 $(OPT) -o $@.o -c $*.c
	$(LD) $(LDFLAGS) extheader.o $@.o $(LIBS) TO $@
%.000: extheader.o %.c
	$(CC) $(CFLAGS) -cpu=68000 $(OPT) -o $@.o -c $*.c
	$(LD) $(LDFLAGS) extheader.o $@.o $(LIBS) TO $@
extheader.o: extheader.c
	$(CC) $(CFLAGS) -c $<

xad_%.lha: %.000 %.020 %.040 %.c xad_%.readme $(EXTRA)
	-$(RM) $@
	sed s/BASE/$*/ < Install.src > Install
	lha -q a $@ $^ Install

# exceptions to the rules

# ASCII has many source files
xad_ASCII.lha: ASCII.000 ASCII.020 ASCII.040 ASCII.c ASCII-BinHex.c \
	ASCII-btoa.c ASCII-MIME.c ASCII-others.c ASCII-utils.c \
	ASCII-uuencode.c xad_ASCII.readme $(EXTRA)

# COP needs the xadXPK.c source
xad_COP.lha: COP.000 COP.020 COP.040 COP.c xadXPK.c xad_COP.readme $(EXTRA)

clean:
	$(RM) $(FILES) *.0[024]0 *.o Install

.PRECIOUS: %.000 %.020 %.040
