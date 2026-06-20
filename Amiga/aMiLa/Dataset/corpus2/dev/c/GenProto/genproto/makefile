# Makefile for genproto under UNIX
# This file is part of genproto v1.2
# Copyright November 1996 by Nicolas Pomarede
# pomarede@isty-info.uvsq.fr


#-----------------------------------------------#
#		C COMPILER FLAGS		#
#-----------------------------------------------#
#	Compiler's name
CC = cc

#	General Flags
FLAG = -Aa

# 	Debug Flags
DEBUG =

# 	Optimisation Flags
OPTIM = -O

#	Include Paths
INCL =

#	Link Flags
LNK =

#	Linker Libraries
LIBS =

#-----------------------------------------------#
# 		OTHER TOOLS			#
#-----------------------------------------------#

LEX = flex
LEXFLAGS =


# default rule for .c files
.c.o:
	$(CC) $(FLAG) $(DEBUG) $(OPTIM) $(INCL) -c $*.c


#-----------------------------------------------#
#	PROJECT DEPENDENT RULES			#
#-----------------------------------------------#


SRC	= main.c proto.l
HEADERS	= proto.h

OBJS	= lex.yy.o main.o
EXE	= genproto

DIST_FILES = $(SRC) $(HEADERS) lex.yy.c $(EXE) makefile smakefile README genproto.readme




all: $(EXE)

$(EXE): $(OBJS)
	$(CC) $(OBJS) $(LNK) $(FLAGS) $(DEBUG) $(OPTIM) $(LIBS) -o $@


lex.yy.c:	proto.l
	$(LEX) $(LEXFLAGS) proto.l

lex.yy.o:	lex.yy.c	proto.h
main.o:		main.c		proto.h


#-----------------------------------------------#
#	EFFACE TOUS LES FICHIERS CREES		#
#-----------------------------------------------#
clean:
	rm $(EXE) $(OBJS) lex.yy.c


#-----------------------------------------------#
#	CREE UNE ARCHIVE DES SOURCES		#
#-----------------------------------------------#
dist:
	tar cvf GenProto.tar $(DIST_FILES)
	gzip GenProto.tar

# END
