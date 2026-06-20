RM	= delete force quiet

#vasm
AS	= vasmm68k_mot
ASOPTS	= -quiet -Fhunk -phxass -align -nosym -nowarn=2028 -I I
DO_AS	= $(AS) $(ASOPTS) -o $@ $<

#phxass
#AS	= PhxAss
#ASOPTS	= NOEXE I I OPT * DL DS
#DO_AS	= $(AS) $(ASOPTS) TO $@ $<

#linker
LD	= vlink
LDOPTS	= -bamigahunk -s -x


OBJECTS	= AssMain.o Assemble.o AssCode.o AssObject.o AssExtra.o AssTexts.o


all: PhxAss

clean:
	$(RM) $(OBJECTS) PhxAss

PhxAss: $(OBJECTS)
	$(LD) $(LDOPTS) -o $@ $(OBJECTS)


AssMain.o: AssMain.asm AssDefs.i
	$(AS) $(ASOPTS) -o $@ $<

Assemble.o: Assemble.asm AssDefs.i
	$(AS) $(ASOPTS) -o $@ $<

AssCode.o: AssCode.asm AssDefs.i
	$(AS) $(ASOPTS) -o $@ $<

AssObject.o: AssObject.asm AssDefs.i
	$(AS) $(ASOPTS) -o $@ $<

AssExtra.o: AssExtra.asm AssDefs.i
	$(AS) $(ASOPTS) -o $@ $<

AssTexts.o: AssTexts.asm
	$(AS) $(ASOPTS) -o $@ $<
