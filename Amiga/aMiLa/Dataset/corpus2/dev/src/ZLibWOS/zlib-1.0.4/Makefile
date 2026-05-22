# Makefile for zlib
# Copyright (C) 1995-1996 Jean-loup Gailly.
# For conditions of distribution and use, see copyright notice in zlib.h 

# To compile and test, type:
#   ./configure; make test
# The call of configure is optional if you don't have special requirements

# To install /usr/local/lib/libz.* and /usr/local/include/zlib.h, type:
#    make install
# To install in $HOME instead of /usr/local, use:
#    make install prefix=$HOME

CC=cc

CFLAGS=+z -O -Aa -D_HPUX_SOURCE
#CFLAGS=-O -DMAX_WBITS=14 -DMAX_MEM_LEVEL=7
#CFLAGS=-g -DDEBUG
#CFLAGS=-O3 -Wall -Wwrite-strings -Wpointer-arith -Wconversion \
#           -Wstrict-prototypes -Wmissing-prototypes

SHLIB = libz.sl
ARLIB = libz.a

LDSHARED=ld -b -s

VER=1.0.4
LIBS=libz.a libz.sl

AR=ar rc
RANLIB=/bin/true
TAR=tar

prefix=/opt/zlib-1.0.4
exec_prefix =/opt/zlib-1.0.4

incdir=$(prefix)/include
libdir=$(prefix)/lib
LDFLAGS=-L$(libdir) -lz

OBJS = adler32.o compress.o crc32.o gzio.o uncompr.o deflate.o trees.o \
       zutil.o inflate.o infblock.o inftrees.o infcodes.o infutil.o inffast.o

TEST_OBJS = example.o minigzip.o

DISTFILES = README INDEX ChangeLog configure Make*[a-z0-9] descrip.mms \
	    zlib.def zlib.rc algorithm.doc  *.[ch]

all: $(LIBS)

test: example minigzip
	./example
	echo hello world | ./minigzip | ./minigzip -d 

$(ARLIB): $(OBJS)
	$(AR) $@ $(OBJS)

$(SHLIB): $(OBJS)
	$(LDSHARED) -o $@ $(OBJS)

example: example.o install_shlib install_arlib
	$(CC) $(CFLAGS) -o $@ example.o $(LDFLAGS)

minigzip: minigzip.o install_shlib install_arlib
	$(CC) $(CFLAGS) -o $@ minigzip.o $(LDFLAGS)

install: install_arlib install_shlib install_incs

install_shlib: $(SHLIB)
	-mkdir -p $(libdir)
	-cp $(SHLIB) $(libdir)
	-chmod 755 $(libdir)/$(SHLIB) $(libdir)

install_arlib: $(ARLIB)
	-mkdir -p $(libdir)
	-cp $(ARLIB) $(libdir)
	-chmod 644 $(libdir)/$(ARLIB)

install_incs:
	-mkdir -p $(incdir)
	-chmod 755 $(incdir)
	-cp zlib.h zconf.h $(incdir)
	-chmod 644 $(incdir)/*.h

uninstall:
	cd $(exec_prefix)/lib; rm -f $(LIBS); \
	if test -f libz.so; then \
	 v=`sed -n '/VERSION "/s/.*"\(.*\)".*/\1/p'<$(prefix)/include/zlib.h`;\
	 rm -f libz.so.$$v libz.so; \
	fi
	cd $(prefix)/include; rm -f zlib.h zconf.h

clean:
	rm -f *.o *~ example minigzip libz.a libz.sl libz.so* foo.gz ztest*.c

zip:
	mv Makefile Makefile~; cp -p Makefile.in Makefile
	v=`sed -n -e 's/\.//g' -e '/VERSION "/s/.*"\(.*\)".*/\1/p' < zlib.h`;\
	zip -ul9 zlib$$v $(DISTFILES)
	mv Makefile~ Makefile

dist:
	mv Makefile Makefile~; cp -p Makefile.in Makefile
	d=zlib-`sed -n '/VERSION "/s/.*"\(.*\)".*/\1/p' < zlib.h`;\
	rm -f $$d.tar.gz; \
	if test ! -d ../$$d; then rm -f ../$$d; ln -s `pwd` ../$$d; fi; \
	files=""; \
	for f in $(DISTFILES); do files="$$files $$d/$$f"; done; \
	cd ..; \
	GZIP=-9 $(TAR) chofz $$d/$$d.tar.gz $$files; \
	if test ! -d $$d; then rm -f $$d; fi
	mv Makefile~ Makefile

tags:	
	etags *.[ch]

depend:
	makedepend -- $(CFLAGS) -- *.[ch]

# DO NOT DELETE THIS LINE -- make depend depends on it.

adler32.o: zlib.h zconf.h
compress.o: zlib.h zconf.h
crc32.o: zlib.h zconf.h
deflate.o: deflate.h zutil.h zlib.h zconf.h
example.o: zlib.h zconf.h
gzio.o: zutil.h zlib.h zconf.h
infblock.o: infblock.h inftrees.h infcodes.h infutil.h zutil.h zlib.h zconf.h
infcodes.o: zutil.h zlib.h zconf.h
infcodes.o: inftrees.h infblock.h infcodes.h infutil.h inffast.h
inffast.o: zutil.h zlib.h zconf.h inftrees.h
inffast.o: infblock.h infcodes.h infutil.h inffast.h
inflate.o: zutil.h zlib.h zconf.h infblock.h
inftrees.o: zutil.h zlib.h zconf.h inftrees.h
infutil.o: zutil.h zlib.h zconf.h infblock.h inftrees.h infcodes.h infutil.h
minigzip.o:  zlib.h zconf.h 
trees.o: deflate.h zutil.h zlib.h zconf.h 
uncompr.o: zlib.h zconf.h
zutil.o: zutil.h zlib.h zconf.h  
