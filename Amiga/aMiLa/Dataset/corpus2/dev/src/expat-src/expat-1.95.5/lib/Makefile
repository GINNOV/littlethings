CC	= gcc
CPU = -m68020-60
CFLAGS	= -O2 -noixemul $(CPU) -I.. -fstrength-reduce -fomit-frame-pointer -fbaserel -fexceptions -Wall -Wmissing-prototypes -Wstrict-prototypes
LDFLAGS	= -noixemul -nostartfiles -fbaserel -s
LDLIBS	=
OBJS = StartUp.o LibInit.o xmlparse.o xmltok.o xmlrole.o
CP=copy

all:	expat.library

expat.library: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

StartUp.o: StartUp.c
	$(CC) $(CFLAGS) -fno-force-mem -c StartUp.c

LibInit.o: LibInit.c
	$(CC) $(CFLAGS) -c LibInit.c

xmlparse.o: xmlparse.c expat.h xmlrole.h xmltok.h
	$(CC) $(CFLAGS) -c xmlparse.c

xmltok.o: xmltok.c xmltok_impl.c xmltok_ns.c ascii.h asciitab.h iasciitab.h \
	latin1tab.h nametab.h utf8tab.h xmltok.h xmltok_impl.h
	$(CC) $(CFLAGS) -c xmltok.c

xmlrole.o: xmlrole.c ascii.h xmlrole.h
	$(CC) $(CFLAGS) -c xmlrole.c

clean:
	rm -f *.o expat.library

install:
	$(CP) expat.library libs: 
