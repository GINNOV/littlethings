
#
# Portable Object Compiler
#

#
# This Makefile should work with UNIX make (like SysV, BSD, GNU make)
#

LEX=flex
LEXYYC=lex.yy.c
RM=rm -f
CP=cp -p
OBJC=objc -q
DBG_MFLAGS=-DDEBUG -g
OPT_MFLAGS=-DNDEBUG -O2

MFLAGS = $(DBG_MFLAGS) -inlinecache -postlink -retain

PROGRAM=words
OBJFILES = token.o words.o

.SUFFIXES: .m .lm

.m.o:
	$(OBJC) -c $*.m $(MFLAGS)

.lm.o:
	$(LEX) $*.lm
	-$(CP) $(LEXYYC) $*.m
	$(OBJC) -c $(MFLAGS) $(IFLAGS) $*.m
	-$(RM) $*.m

$(PROGRAM) : $(OBJFILES)
	$(OBJC) $(MFLAGS) $(OBJFILES) -o $(PROGRAM)

cleantmp :
	-$(RM) *.P
	-$(RM) *.c
	-$(RM) *.i

clean : cleantmp
	-$(RM) *.o
	-$(RM) postlink.map token.m
	-$(RM) $(PROGRAM)

distclean : clean
	-$(RM) Makefile 

