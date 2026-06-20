# $Header: /home/amb/cxref/RCS/Makefile 1.34 1997/11/20 19:55:33 amb Exp $
#
# C Cross Referencing & Documentation tool. Version 1.4a.
#
# Program Makefile.
#
# Written by Andrew M. Bishop
#
# This file Copyright 1995,96 Andrew M. Bishop
# It may be distributed under the GNU Public License, version 2, or
# any higher version.  See section COPYING of the GNU Public license
# for conditions under which this file may be redistributed.
#

# Standard definitions, edit Makefile.config not this one.
include ./Makefile.config

########

INCLUDE=
LIBRARY=

COMPILE=$(CC) -c $(CFLAGS)

LINK=$(LD) $(LDFLAGS)

########

programs : cxref-cpp cxref cxref-query
	@

docs : readme faq-html
	cd doc && $(MAKE)

all : programs docs
	@

########

OBJ_FILES=func.o type.o var.o preproc.o comment.o file.o \
          slist.o memory.o \
          xref.o \
          warn-raw.o latex.o latex-style.o \
          html.o \
          parse-lex.o parse-yacc.o

cxref : cxref.o $(OBJ_FILES)
	$(LINK) cxref.o $(OBJ_FILES) -o $@ $(LIBRARY)

cxref-inst : cxref-inst.o $(OBJ_FILES)
	$(LINK) cxref-inst.o $(OBJ_FILES) -o $@ $(LIBRARY)

####

cxref-cpp : cpp/Makefile.cpp
	cd cpp && $(MAKE) cxref-cpp

cpp/Makefile.cpp :
	touch cpp/Makefile.cpp
	cd cpp && $(MAKE) configure

####

cxref-query :
	cd query && $(MAKE) cxref-query

########

faq-html : FAQ FAQ-html.pl
	-[ $(PERL) ] && $(PERL) FAQ-html.pl < FAQ > FAQ.html

####

readme : cxref cxref-cpp README.c
	./cxref -Odoc -NREADME -xref README.c
	./cxref -Odoc -NREADME -xref README.c -html -latex
	cp doc/README.c.html README.c.html
	cp doc/README.c.tex  README_c.tex
	-[ $(LATEX) ] && $(LATEX) README.tex > /dev/null 2>&1
	-[ $(LATEX) ] && $(LATEX) README.tex
	-[ $(DVIPS) ] && $(DVIPS) README.dvi -o README.ps
	@rm -f README.aux README.log README.toc doc/README.*

########

install : programs cxref-inst
	$(INSTALL) -d $(INSTDIR)/bin
	$(INSTALL) -m 755 cxref-inst $(INSTDIR)/bin/cxref
	-@rm cxref-inst
	$(INSTALL) -m 755 query/cxref-query $(INSTDIR)/bin
	[ ! -x cpp/cxref-cpp ] || $(INSTALL) -m 755 cpp/cxref-cpp $(INSTDIR)/bin
	$(INSTALL) -d $(INSTDIR)/man/man1
	$(INSTALL) -m 644 README.man $(INSTDIR)/man/man1/cxref.1
	$(INSTALL) -m 644 query/README.man $(INSTDIR)/man/man1/cxref-query.1
	[ ! -x cpp/cxref-cpp ] || $(INSTALL) -m 644 cpp/README.man $(INSTDIR)/man/man1/cxref-cpp.1

########

clean :
	-rm -f cxref core *.o *~ \
	lex.*.c y.tab.* latex-style.c \
	README.dvi README.ps

####

allclean realclean : clean
	cd doc && $(MAKE) clean
	cd cpp && $(MAKE) clean
	cd query && $(MAKE) clean

########

parse-yacc.c : parse.y
	$(YACC) -d parse.y
	-@mv y.tab.c  parse-yacc.c
	@echo Created parse-yacc.c

parse-yacc.h : parse-yacc.c
	-@if cmp -s parse-yacc.h y.tab.h ; then : ; else \
	   if [ -f y.tab.h ] ; then \
	      cp y.tab.h parse-yacc.h ; \
	      echo Created parse-yacc.h ; \
	   fi \
	fi

####

parse-lex.c : parse.l
	$(LEX) parse.l
	-@mv lex.yy.c parse-lex.c
	@echo Created parse-lex.c

####

latex-style.c : doc/fonts.style doc/page.style doc/cxref.style
	@echo '/** The style files needed for LaTeX. **/' >  latex-style.c
	@echo ''                                          >> latex-style.c
	@echo '/*+ The fonts style file as a string. +*/' >> latex-style.c
	@echo 'char *latex_fonts_style='                  >> latex-style.c
	@sed 's/\\/\\\\/g' doc/fonts.style \
	|awk '{print "\"" $$0 "\\n\""}'                   >> latex-style.c
	@echo ';'                                         >> latex-style.c
	@echo ''                                          >> latex-style.c
	@echo '/*+ The page style file as a string. +*/'  >> latex-style.c
	@echo 'char *latex_page_style='                   >> latex-style.c
	@sed 's/	CONFIG-ONLY PAGE=$(LATEX_PAGE)//g' doc/page.style \
	|grep -v 'CONFIG-ONLY' \
	|sed 's/\\/\\\\/g' \
	|awk '{print "\"" $$0 "\\n\""}'                   >> latex-style.c
	@echo ';'                                         >> latex-style.c
	@echo ''                                          >> latex-style.c
	@echo '/*+ The cxref style file as a string. +*/' >> latex-style.c
	@echo 'char *latex_cxref_style='                  >> latex-style.c
	@sed 's/\\/\\\\/g' doc/cxref.style \
	|awk '{print "\"" $$0 "\\n\""}'                   >> latex-style.c
	@echo ';'                                         >> latex-style.c
	@echo Created latex-style.c

####

%.o:%.c
	$(COMPILE) $< -o $@ $(INCLUDE)

cxref.o      : cxref.c      cxref.h datatype.h   memory.h parse-yy.h
	[ ! -x cpp/cxref-cpp ] || $(COMPILE) cxref.c -o $@ $(INCLUDE) "-DCXREF_CPP=\"$$PWD/cpp/cxref-cpp -C -dD -dI\""
	[   -x cpp/cxref-cpp ] || $(COMPILE) cxref.c -o $@ $(INCLUDE)

cxref-inst.o : cxref.c      cxref.h datatype.h   memory.h parse-yy.h
	[ ! -x cpp/cxref-cpp ] || $(COMPILE) cxref.c -o $@ $(INCLUDE) '-DCXREF_CPP="cxref-cpp -C -dD -dI"'
	[   -x cpp/cxref-cpp ] || $(COMPILE) cxref.c -o $@ $(INCLUDE)

func.o       : func.c       cxref.h datatype.h   memory.h
type.o       : type.c       cxref.h datatype.h   memory.h
var.o        : var.c        cxref.h datatype.h   memory.h
comment.o    : comment.c    cxref.h datatype.h   memory.h
file.o       : file.c       cxref.h datatype.h   memory.h
preproc.o    : preproc.c    cxref.h datatype.h   memory.h

slist.o      : slist.c      cxref.h datatype.h   memory.h
memory.o     : memory.c                          memory.h

xref.o       : xref.c       cxref.h datatype.h   memory.h
warn-raw.o   : warn-raw.c   cxref.h datatype.h   memory.h
latex.o      : latex.c      cxref.h datatype.h   memory.h
latex-style.o: latex-style.c
html.o       : html.c       cxref.h datatype.h   memory.h

parse-yacc.o : parse-yacc.c cxref.h parse-yacc.h memory.h parse-yy.h
parse-lex.o  : parse-lex.c  cxref.h parse-yacc.h memory.h parse-yy.h

########
