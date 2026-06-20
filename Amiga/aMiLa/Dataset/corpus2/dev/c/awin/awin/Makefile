#
# awindemo makefile for egcs (gcc)
# an example on how to use awin in your own projects
#
# IMPORTANT! Uses SAS/C PPC lib: files to link
#

# -O3 makes 0x0 egcs barf on spilled regs. that's why I need some
# special arrangement with some functions (gccstubs.o).

### 68k assembler defines ###
#ASMC2P = devpac:genam with genam.opts
#ASM = devpac:genam with genam.opts
ASMC2P = phxass symdebug linedebug noexe machine 68040 opt 0
ASM = phxass symdebug linedebug noexe machine 68040 opt 2


### 68k defines ###
#CFLAGS_68K = -noixemul -m68020-60 -msoft-float \
#             -Wall \
#             -O3 -fomit-frame-pointer -funroll-loops -fthread-jumps \
#             -fcse-follow-jumps -fcse-skip-blocks -frerun-loop-opt
CFLAGS_68K = -noixemul -m68020-60 -msoft-float -Wall \
             -O3 -fomit-frame-pointer -funroll-loops

CC_68K = gcc $(CFLAGS_68K) -c
LINK_68K = gcc $(CFLAGS_68K)

AWINOBJS_68K = ddazure2.o gccstubs.o cpu5azure2.o awin68k.o \
               /gg/lib/libnix/swapstack.o
AWINHDRS_68K = ddazure2.h gccstubs.h cpu5azure2.h awin.h
AWINLIBS_68K = -lm


### ppc defines ###
CFLAGS_PPC = -Wall \
             -O3 -fforce-addr -fomit-frame-pointer -fstrength-reduce \
             -fthread-jumps -fcse-follow-jumps -fcse-skip-blocks \
             -fexpensive-optimizations -fschedule-insns \
             -funroll-loops

CC_PPC = ppc-amigaos-gcc -r -noixemul $(CFLAGS_PPC) \
         -I/gg/ppc-amigaos/include/ -I/gg/ppc-amigaos/os-include/ \
         -I/gg/include/ -I/gg/os-include/ -DAW_PPC -c

LINK_PPC = ppc-amigaos-ld -r -noixemul
#LINK_PPC = vlink -b elf32ppcbe -r

AWINOBJS_PPC = awinppc.o
AWINHDRS_PPC = awin.h
#AWINLIBS_PPC = -lmoto -lm
AWINLIBS_PPC = gg:ppc-amigaos/lib/libmoto.a gg:ppc-amigaos/lib/libm.a \
               lib:scppc.a lib:end.o


all: 68k ppc

clean:
	rm -rf awindemo68k awindemoppc *.info *.o *.tmp *.lnk


# this is a custom destination to build aminet release
aminet:
	@echo "# making 68k and ppc"
	$(MAKE) 68k
	$(MAKE) ppc
	@echo "# stripping executables"
	$(MAKE) strip68k
	$(MAKE) stripppc
	cp awindemo.inf awindemo68k.info
	cp awindemo.inf awindemoppc.info
	@echo "# deleting old /work/tosend/awin dir"
	rm -rf /work/tosend/awin/*
	rm -f /work/tosend/awin.lha
	@echo "# copying files..."
	copy "~(#?.(o|tmp|lnk))" to work:tosend/awin/ all clone quiet
	copy awin.readme to work:tosend/ clone quiet
	@echo "# building lha..."
	lha a -r work:tosend/awin.lha work:tosend/ awin awin.info awin.readme
	@echo "# awin.lha and awin.readme ready to ship! ;)"

68k:  awindemo68k

ppc: awindemoppc
	chmod u+x awindemoppc
	ppc-amigaos-objdump -t awindemoppc | grep *UND*

strip68k:
	strip awindemo68k

stripppc:
	ppc-amigaos-strip --strip-debug awindemoppc

# modify stuff after this line

awindemo68k.o: awindemo.c $(AWINHDRS_68K)
	$(CC_68K) awindemo.c -o $@

awindemoppc.o: awindemo.c $(AWINHDRS_PPC)
	$(CC_PPC) awindemo.c -o $@

awindemo68k: $(AWINOBJS_68K) awindemo68k.o
	$(LINK_68K) $(AWINOBJS_68K) awindemo68k.o $(AWINLIBS_68K) -o $@

awindemoppc: $(AWINOBJS_PPC) awindemoppc.o
	$(LINK_PPC) lib:c_ppc.o $(AWINOBJS_PPC) awindemoppc.o $(AWINLIBS_PPC) -o $@

# here are things you don't modify

awsetlnnameinner:
	$(ASM) from $@.ASM to $@.o
	sh odump $@
	rm -f $@.o

awsafewaitinner:
	$(ASM) from $@.ASM to $@.o
	sh odump $@
	rm -f $@.o

awfreepensinner:
	$(ASM) from $@.ASM to $@.o
	sh odump $@
	rm -f $@.o

awremapinner:
	$(ASM) from $@.ASM to $@.o
	sh odump $@
	rm -f $@.o

ddazure2.o:  ddazure2.ASM
	$(ASM) from ddazure2.ASM to $@

gccstubs.o: gccstubs.ASM
	$(ASM) from gccstubs.ASM to $@

cpu5azure2.o: cpu5azure2.ASM
	$(ASMC2P) from cpu5azure2.ASM to $@

awin68k.o: awin.c $(AWINHDRS_68K)
	$(CC_68K) awin.c -o $@

awinppc.o: awin.c $(AWINHDRS_PPC)
	$(CC_PPC) awin.c -o $@
