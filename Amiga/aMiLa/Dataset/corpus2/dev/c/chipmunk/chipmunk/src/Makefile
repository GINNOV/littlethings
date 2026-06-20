TARGET = chipmunk.library

CC = ppc-morphos-g++
CC2 = ppc-morphos-gcc
LD = ppc-morphos-gcc
AR = ppc-morphos-ar

CINCS   =
CDEFS	  = -DAROS_ALMOST_COMPATIBLE
CFLAGS  = -noixemul $(CDEFS) -mcpu=750 -mstring -mmultiple -mresident32 -Wall -O3
CFLAGS2 = -noixemul $(CDEFS) -mcpu=750 -mstring -mmultiple -Wall -O3

OBJS = AMIGA/Library.o AMIGA/Startup.o AMIGA/Table.o chipmunk.o cpArbiter.o cpArray.o cpBB.o cpBody.o \
	cpCollision.o cpHashSet.o cpJoint.o cpPolyShape.o cpShape.o cpSpace.o cpSpaceHash.o \
	cpVect.o

ECHO = echo
ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

all: $(TARGET)

lib: Developer/lib/libchipmunk.a

headers:
	@-mkdir -p Developer/include/ppcinline Developer/include/inline Developer/include/proto
	cvinclude.pl --fd Developer/include/fd/chipmunk_lib.fd --clib Developer/include/clib/chipmunk_protos2.h --inlines Developer/include/ppcinline/chipmunk.h --vbccinlines Developer/include/inline/chipmunk_protos.h --proto Developer/include/proto/chipmunk.h

Library.o: Library.c Library.h
	$(COMPILING)
	@$(CC2) $(CFLAGS2) -c $< -o $@ 

Startup.o: Startup.c Startup.h
	$(COMPILING)
	@$(CC2) $(CFLAGS) -c $< -o $@ 

%.o : %.c Library.h
	$(COMPILING)
	@$(CC) $(CFLAGS) $(CINCS) -c $*.c -o $*.o

$(TARGET): $(OBJS)
	$(LINKING)
	@$(LD) -noixemul -nostartfiles -mresident32 -Wl,-Map=file.map -o $@.db $(OBJS)
	$(STRIPPING)
	@ppc-morphos-strip -o $@ --remove-section=.comment $@.db

dump:
	objdump --disassemble-all --reloc $(TARGET).db >$(TARGET).s

AMIGA/libchipmunk.o: AMIGA/libchipmunk.c
	$(COMPILING)
	@$(CC2) -noixemul -mcpu=750 -mstring -mmultiple -Wall -O3 -o $@ -c AMIGA/libchipmunk.c

libchipmunk_glue.a: Developer/include/clib/chipmunk_protos.h Developer/include/fd/chipmunk_lib.fd Developer/include/ppcinline/chipmunk.h
	@cvinclude.pl --fd=Developer/include/fd/chipmunk_lib.fd --clib=Developer/include/clib/chipmunk_protos2.h --gluelib=libchipmunk_glue.a

Developer/lib/libchipmunk.a: AMIGA/libchipmunk.o libchipmunk_glue.a
	$(ARCHIVING)
	@-rm -f $@
	@cp libchipmunk_glue.a $@
	@$(AR) cru $@ AMIGA/libchipmunk.o
	@ppc-morphos-ranlib $@

clean:
	-rm -f *.o $(TARGET) $(TARGET).db *.a *.map *.s
