# $Header: /home/amb/cxref/doc/RCS/Makefile 1.9 1996/10/29 19:52:36 amb Exp $
#
# C Cross Referencing & Documentation tool. Version 1.3.
#
# Documentation Makefile.
#
# Written by Andrew M. Bishop
#
# This file Copyright 1995,96 Andrew M. Bishop
# It may be distributed under the GNU Public License, version 2, or
# any higher version.  See section COPYING of the GNU Public license
# for conditions under which this file may be redistributed.
#

# Standard definitions, edit ../Makefile.config not this one.
include ../Makefile.config

########

SOURCE_FILES= \
cxref.c       \
cxref.h       \
datatype.h    \
comment.c     \
file.c        \
func.c        \
preproc.c     \
type.c        \
var.c         \
xref.c        \
warn-raw.c    \
latex.c       \
latex-style.c \
html.c        \
slist.c       \
memory.h      \
memory.c      \
parse-yy.h    \
parse-yacc.h  \
parse-lex.c   \
parse-yacc.c 

########

all : sources docs
	@

########

sources :
#
# Create the cross reference files
#
	@for file in $(SOURCE_FILES) ; do \
	   echo Cross referencing $$file ; \
	   ( cd .. ; ./cxref -xref -Odoc -Ncxref $$file ) ; \
	done
#
# Create the source files using cxref
#
	@for file in $(SOURCE_FILES) ; do \
	   echo Documenting $$file ; \
	   ( cd .. ; ./cxref -warn-xref -xref -Odoc -Ncxref -latex -html $$file ) ; \
	done
#
# Create the index using cxref
#
	@echo Indexing
	@( cd .. ; ./cxref -index-all -Odoc -Ncxref -latex -html )

########

docs :
#
# Create the final output using latex
#
	-[ $(LATEX) ] && $(LATEX) cxref.tex > /dev/null 2>&1
#
# Create the cross references using latex
#
	-[ $(LATEX) ] && $(LATEX) cxref.tex

########

clean :
	-rm -f *~ \
	*.sty *.tex *.html \
	cxref.function cxref.include cxref.typedef cxref.variable \
	cxref.aux cxref.dvi cxref.log cxref.toc

########
