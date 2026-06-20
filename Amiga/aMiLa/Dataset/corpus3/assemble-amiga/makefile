SFLAGS = -l -d -o+ -o1-
AS = bin:asm
LD = slink
LISTE01 = asm.o doea68k.o fpu68k.o eval68k.o evone68k.o patch68k.o amigfile.o \
	tree68k.o perror.o amg_ienv.o sprintf.o amgflush.o 
asm:	$(LISTE01)
	$(LD) from $(LISTE01) to asm

install:	$(LISTE01)
	$(LD) from $(LISTE01) to bin:asm NODEBUG

asm.o:	comequ.s asm.s line68k.s si.s memory.s qsort.s mm.s ins68k.s \
	tbl68k.s prep.s amig_equ.s
	$(AS) $(SFLAGS) asm.s
perror.o:	comequ.s perror.s
	$(AS) $(SFLAGS) perror.s
eval68k.o:	comequ.s eval68k.s
	$(AS) $(SFLAGS) eval68k.s
evone68k.o:	comequ.s evone68k.s
	$(AS) $(SFLAGS) evone68k.s
patch68k.o: comequ.s patch68k.s amig_equ.s
	$(AS) $(SFLAGS) patch68k.s
amgflush.o:	comequ.s amgflush.s amig_equ.s
	$(AS) $(SFLAGS) amgflush.s
amigfile.o:	comequ.s amigfile.s amig_equ.s
	$(AS) $(SFLAGS) amigfile.s
sprintf.o:	sprintf.s
	$(AS) $(SFLAGS) sprintf.s
tree68k.o:	tree68k.s
	$(AS) $(SFLAGS) tree68k.s
doea68k.o:	bldea68k.s getea68k.s doea68k.s comequ.s
	$(AS) $(SFLAGS) doea68k.s
amg_ienv.o: amg_ienv.s comequ.s amig_equ.s
	$(AS) $(SFLAGS) amg_ienv.s
fpu68k.o: fpu68k.s comequ.s
	$(AS) $(SFLAGS) fpu68k.s
