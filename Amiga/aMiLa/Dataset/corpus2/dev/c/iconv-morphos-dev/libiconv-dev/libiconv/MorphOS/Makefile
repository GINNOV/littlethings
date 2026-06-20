TARGET = iconv.library

CC = ppc-morphos-gcc
LD = ppc-morphos-gcc
AR = ppc-morphos-ar


CDEFS			= -DAROS_ALMOST_COMPATIBLE
CFLAGS		= -noixemul $(CDEFS) -mcpu=750 -mstring -mmultiple -Wall -O2 #-mresident32
CFLAGS2		= -noixemul $(CDEFS) -mcpu=750 -mstring -mmultiple -Wall -O2
CFLAGS_IX	= $(CDEFS) -mcpu=750 -mstring -mmultiple -Wall -O3
INCLUDES	= -I./include
LIBS			= -liconv -ldebug

OBJS = Library.o Library_stubs.o Startup.o

ECHO = echo
ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

all: check $(TARGET) lib/libiconv.a libb32/libiconv.a ixemul/libiconv.a

headers:
	@mkdir -p include/proto include/ppcinline include/inline
	cvinclude.pl --fd include/fd/iconv_lib.fd --clib include/clib/iconv_protos.h --inlines include/ppcinline/iconv.h --vbccinlines include/inline/iconv_protos.h --proto include/proto/iconv.h --root=iconv

include/proto: headers

include/iconv.h: ../include/iconv.h.inst
	@cp $< $@

check: include/fd/iconv_lib.fd include/clib/iconv_protos.h include/proto #include/iconv.h

libiconv-startup.h: include/proto
	@cat include/ppcinline/iconv.h | sed -e "s/#define \(.*\) \\\\/#define call_\1 \\\\/g" >$@

libiconv-ixemul.o: libiconv-startup.c libiconv-startup.h
	$(COMPILING)
	@$(CC) $(CFLAGS_IX) -DBUILD_IXEMUL_LIB $(INCLUDES) -c $< -o $@ 

Library.o: Library.c Library.h
	$(COMPILING)
	@$(CC) $(CFLAGS2) -c $< -o $@ 

%.o : %.c Library.h
	$(COMPILING)
	@$(CC) $(CFLAGS) -c $*.c -o $*.o

$(TARGET): $(OBJS)
	$(LINKING)
	@$(LD) -noixemul -nostartfiles -Wl,-Map=iconv.map -L../lib -L../lib/.libs -o $@.db $(OBJS) $(LIBS) #-mresident32
	$(STRIPPING)
	@ppc-morphos-strip -o $@ --remove-section=.comment $@.db

libiconv-startup.o: libiconv-startup.c libiconv-startup.h
	$(COMPILING)
	@$(CC) -noixemul -mcpu=750 -mstring -mmultiple -Wall -O3 $(INCLUDES) -o $@ -c libiconv-startup.c

libiconv-startup-brel.o: libiconv-startup.c libiconv-startup.h
	$(COMPILING)
	@$(CC) -noixemul -mresident32 -mcpu=750 -mstring -mmultiple -Wall -O3 $(INCLUDES) -o $@ -c libiconv-startup.c

libiconv_glue.a: include/clib/iconv_protos.h include/fd/iconv_lib.fd include/ppcinline/iconv.h include/proto/iconv.h
	@cvinclude.pl --fd=include/fd/iconv_lib.fd --clib=include/clib/iconv_protos.h --gluelib=libiconv_glue.a

libiconv_brelglue.a: include/clib/iconv_protos.h include/fd/iconv_lib.fd include/ppcinline/iconv.h include/proto/iconv.h
	@cvinclude.pl --fd=include/fd/iconv_lib.fd --clib=include/clib/iconv_protos.h --brelgluelib=libiconv_brelglue.a

lib/libiconv.a: libiconv-startup.o
	$(ARCHIVING)
	@mkdir -p lib
	@-rm -f lib/libiconv.a
	@$(AR) cru lib/libiconv.a libiconv-startup.o
	@ppc-morphos-ranlib lib/libiconv.a

libb32/libiconv.a: libiconv-startup-brel.o
	$(ARCHIVING)
	@mkdir -p libb32
	@-rm -f libb32/libiconv.a
	@$(AR) cru libb32/libiconv.a libiconv-startup-brel.o
	@ppc-morphos-ranlib libb32/libiconv.a

ixemul/libiconv.a: libiconv-ixemul.o
	$(ARCHIVING)
	@mkdir -p ixemul
	@-rm -f ixemul/libiconv.a
	@$(AR) cru ixemul/libiconv.a libiconv-ixemul.o
	@ppc-morphos-ranlib ixemul/libiconv.a

install: all
	@mkdir -p /mossys/libs/ /usr/local/lib/libnix /usr/local/lib/libb32/libnix
	cp $(TARGET) /mossys/libs/iconv.library
	cp lib/libiconv.a /usr/local/lib/libnix
	cp libb32/libiconv.a /usr/local/lib/libb32/libnix
	cp ixemul/libiconv.a /usr/local/lib
	@-flushlib $(TARGET)

install-iso: all
	 mkdir -p $(ISOPATH)MorphOS/Libs
	 cp $(TARGET) $(ISOPATH)MorphOS/Libs/iconv.library

clean:
	@-rm -f $(TARGET) $(TARGET).db *.map *.o *.a $(TARGET).dump lib/* libb32/* ixemul/* include/proto/* include/ppcinline/* include/inline/*
	@-rm -rf lib libb32 ixemul include/proto include/ppcinline include/inline

dump:
	objdump --disassemble-all --reloc $(TARGET).db >$(TARGET).dump
