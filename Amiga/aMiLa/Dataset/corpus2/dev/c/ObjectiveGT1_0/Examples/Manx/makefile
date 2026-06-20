# MakeFile for MANX 5.2a
#
##

CFLAGS = -ps -wdrunpo0q -so
LLIBS = -lOGTglue -lc16

.c.o:
   cc:cc $(CFLAGS) -o $@ $*.c

all: demogadget1 demogadget2 demoPosition demoGfx gadshow viewfile viewfile_wrong


demogadget1: demogadget1.o OGTglue.lib
   cc:ln $(LFLAGS) -o $@ $*.o $(LLIBS)

demogadget2: demogadget2.o OGTglue.lib
   cc:ln $(LFLAGS) -o $@ $*.o $(LLIBS)

demoPosition: demoPosition.o OGTglue.lib
   cc:ln $(LFLAGS) -o $@ $*.o $(LLIBS)


demoGfx: demoGfx.o OGTglue.lib
   cc:ln $(LFLAGS) -o $@ $*.o $(LLIBS)

gadshow: gadshow.o OGTglue.lib
   cc:ln $(LFLAGS) -o $@ $*.o $(LLIBS)


viewfile: viewfile.o OGTglue.lib
   cc:ln $(LFLAGS) -o $@ $*.o $(LLIBS)

viewfile_wrong: viewfile_wrong.o OGTglue.lib
   cc:ln $(LFLAGS) -o $@ $*.o $(LLIBS)

