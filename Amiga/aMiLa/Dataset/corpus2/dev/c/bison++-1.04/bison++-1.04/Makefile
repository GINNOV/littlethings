# Makefile for bison++
#   Copyright (C) 1990, 1991 Larry M. Augustin
#   Copyright (C) 1984, 1989 Bob Corbett and Free Software Foundation, Inc.
# 
# This file is part of Bison, the GNU Compiler Compiler.
# 
# Bison is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or (at your option)
# any later version.
# 
# Bison is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bison; see the file COPYING.  If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

# For sysV, you must uncomment the following lines
#CFLAGS = -g -DUSG
#LIBS = -lPW
#and comment out the assignment of CFLAGS below.
#Also, if getopt.c gives any trouble, delete it from OBJECTS.
#so the system's getopt will be used.

# where the installed binary goes
BINDIR = C:

# where the parsers go
PARSERDIR = S:

# names of parser files (not needed by the Amiga version)
#PFILE = S:bison++.simple.cc
#PFILE1 = S:bison++.hairy.cc

# for parallel make on a sequent, use PARALLEL=&
#PARALLEL=

CFLAGS = NOMULTIPLEINCLUDES NOICONS OPT

#PFILES = -DXPFILE=\"$(PARSERDIR)/$(PFILE)\" \
#	 -DXPFILE1=\"$(PARSERDIR)/$(PFILE1)\"

OBJECTS = LR0.o allocate.o closure.o conflicts.o derives.o files.o	\
	  getargs.o gram.o lalr.o lex.o					\
	  main.o nullable.o output.o print.o reader.o reduce.o symtab.o	\
	  warshall.o version.o						\
	  getopt.o

LIBS = lib:sc.lib lib:amiga.lib

VERSION="1.04"

start: bison++

clean:
	rm -f *.o core bison++ *.tar *~

install: bison++
	install -c bison++ $(BINDIR)
	-cd $(PARSERDIR); rm -f $(PFILE) $(PFILE1)
	cp $(PFILE) $(PFILE1) $(PARSERDIR)

bison++: $(PARALLEL) $(OBJECTS)
        slink lib:c.o $(OBJECTS) to "bison++" lib $(LIBS) NOICONS
#	$(CC) $(LDFLAGS) -o bison++ $(OBJECTS) $(LIBS)

dist:	bison++-$(VERSION).tar bison++-$(VERSION).tar.Z

.PHONY: bison++-$(VERSION).tar
bison++-$(VERSION).tar:
	-rm -rf bison++-$(VERSION)
	mkdir bison++-$(VERSION)
	ln  COPYING ChangeLog Makefile REFERENCES \
	    bison++.simple.cc bison++.hairy.cc \
	    LR0.c allocate.c closure.c conflicts.c derives.c \
	    files.c getargs.c gram.c lalr.c lex.c main.c nullable.c \
	    output.c print.c reader.c reduce.c symtab.c version.c \
	    warshall.c files.h gram.h lex.h machine.h new.h state.h \
	    symtab.h types.h bison++.cld build.com vmsgetargs.c vmshlp.mar \
	    README \
	  bison++-$(VERSION)
	cp getopt.c bison++-$(VERSION)

	tar chvf bison++-$(VERSION).tar bison++-$(VERSION)

bison++-$(VERSION).tar.Z: bison++-$(VERSION).tar
	compress < bison++-$(VERSION).tar > bison++-$(VERSION).tar.Z

TAGS: *.c *.h
	etags *.c *.h

# This file is different to pass the parser file names
# to the compiler.
files.o: files.c files.h new.h gram.h
	$(CC) $(CFLAGS) $(PFILES) files.c

LR0.o: machine.h new.h gram.h state.h
closure.o: machine.h new.h gram.h
conflicts.o: machine.h new.h files.h gram.h state.h
derives.o: new.h types.h gram.h
getargs.o: files.h
lalr.o: machine.h types.h state.h new.h gram.h
lex.o: files.h symtab.h lex.h
main.o: machine.h
nullable.o: types.h gram.h new.h
output.o: machine.h new.h files.h gram.h state.h
print.o: machine.h new.h files.h gram.h state.h
reader.o: files.h new.h symtab.h lex.h gram.h
reduce.o: files.h new.h machine.h gram.h
symtab.o: new.h symtab.h gram.h
warshall.o: machine.h
