TARGET = intl.library

CC = ppc-morphos-gcc
LD = ppc-morphos-gcc
AR = ppc-morphos-ar


CDEFS		= -DAROS_ALMOST_COMPATIBLE -Iusr:local/include
CFLAGS	= -noixemul $(CDEFS) -mcpu=750 -mstring -mmultiple -mresident32 -Wall -O2
CFLAGS2	= -noixemul $(CDEFS) -mcpu=750 -mstring -mmultiple -Wall -O3
CFLAGS3	= -noixemul $(CDEFS) -mcpu=750 -mstring -mmultiple -Wall -O3 -DHAVE_CONFIG_H -DIN_LIBINTL -I../../
LIBS		= -lintl -liconv

OBJS = Library.o Startup.o
LIBOBJS = printf.o vasnprintf.o

ECHO = echo
ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

all: $(TARGET) lib/libintl.a libb32/libintl.a ixemul/libintl.a

headers:
	cvinclude.pl --fd include/fd/intl_lib.fd --clib include/clib/intl_protos.h --inlines include/ppcinline/intl.h --vbccinlines include/inline/intl_protos.h --proto include/proto/intl.h --root=intl

Library.o: Library.c Library.h
	$(COMPILING)
	@$(CC) $(CFLAGS2) -c $< -o $@

%.o : %.c Library.h
	$(COMPILING)
	@$(CC) $(CFLAGS) -c $*.c -o $*.o

printf.o: ../printf.c
	$(COMPILING)
	@$(CC) $(CFLAGS3) -c ../printf.c -o $@

vasnprintf.o: ../vasnprintf.c ../vasnprintf.h
	$(COMPILING)
	@$(CC) $(CFLAGS3) -c ../vasnprintf.c -o $@

$(TARGET): $(OBJS)
	$(LINKING)
	@$(LD) -noixemul -nostartfiles -mresident32 -Wl,-Map=intl.map -L../.libs -o $@.db $(OBJS) $(LIBS)
	$(STRIPPING)
	@ppc-morphos-strip -o $@ --remove-section=.comment $@.db

libintl-startup.o: libintl-startup.c
	$(COMPILING)
	@$(CC) -noixemul -mcpu=750 -mstring -mmultiple -Wall -O3 $(INCLUDES) -o $@ -c libintl-startup.c

libintl-startup-brel.o: libintl-startup.c
	$(COMPILING)
	@$(CC) -noixemul -mresident32 -mcpu=750 -mstring -mmultiple -Wall -O3 $(INCLUDES) -o $@ -c libintl-startup.c

libintl_glue.a: include/clib/intl_protos.h include/fd/intl_lib.fd include/ppcinline/intl.h include/proto/intl.h
	@cvinclude.pl --fd=include/fd/intl_lib.fd --clib=include/clib/intl_protos.h --gluelib=libintl_glue.a

libintl_brelglue.a: include/clib/intl_protos.h include/fd/intl_lib.fd include/ppcinline/intl.h include/proto/intl.h
	@cvinclude.pl --fd=include/fd/intl_lib.fd --clib=include/clib/intl_protos.h --brelgluelib=libintl_brelglue.a

lib/libintl.a: libintl-startup.o libintl_glue.a $(LIBOBJS)
	$(ARCHIVING)
	@-rm -f lib/libintl.a
	@cp libintl_glue.a lib/libintl.a
	@$(AR) cru lib/libintl.a libintl-startup.o $(LIBOBJS)
	@ppc-morphos-ranlib lib/libintl.a

libb32/libintl.a: libintl-startup-brel.o libintl_brelglue.a
	$(ARCHIVING)
	@-rm -f libb32/libintl.a
	@cp libintl_brelglue.a libb32/libintl.a
	@$(AR) cru libb32/libintl.a libintl-startup-brel.o
	@ppc-morphos-ranlib libb32/libintl.a

ixemul/libintl.a: libintl-ixemul.o
	$(ARCHIVING)
	@-rm -f ixemul/libintl.a
	@$(AR) cru ixemul/libintl.a libintl-ixemul.o
	@ppc-morphos-ranlib ixemul/libintl.a

clean:
	@-rm $(TARGET) $(TARGET).db *.map *.o *.a