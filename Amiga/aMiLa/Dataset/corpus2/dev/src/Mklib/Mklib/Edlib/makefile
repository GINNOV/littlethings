# makefile for the edlib library source directory
# copyright 1988 Edwin Hoogerbeets
#
# make sure that lb is in your path or make will give you an exec failure

.c.o:
        cc +L -o $*.o $*.c

OBJS= bintoint.o dectoint.o getopt.o hextoint.o isbdigit.o \
      iscsym.o iscsymf.o isodigit.o stolower.o stoupper.o  \
      strcspn.o strpbrk.o strpos.o strrpos.o strspn.o      \
      strtok.o toint.o strrpbrk.o stricmp.o strnicmp.o

ed32.lib: $(OBJS)
        lb ed32.lib $(OBJS)

test: test.o
        ln test.o -led -lc -o test

