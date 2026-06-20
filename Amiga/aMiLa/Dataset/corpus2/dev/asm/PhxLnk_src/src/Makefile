INCPATH = ../PhxAss/I
LIBPATH	= /usr/local/vbcc/targets/m68k-amigaos/lib
RM	= rm -f

PhxLnk: PhxLnk.o
	vlink -bamigahunk -s -x -o $@ $< -L$(LIBPATH) -lamiga

PhxLnk.o: PhxLnk.asm
	vasmm68k_mot -Fhunk -o $@ -phxass -I$(INCPATH) $<

clean:
	$(RM) PhxLnk.o PhxLnk
