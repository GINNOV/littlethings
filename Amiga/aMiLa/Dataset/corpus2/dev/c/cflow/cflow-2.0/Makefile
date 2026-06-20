# 
# $Id: Makefile,v 1.7 1995/03/06 14:00:00 leisner Exp leisner $
ifeq "$(origin CC)" "default"
CC=gcc
endif

# use cp backup option if you have gnu cp
CP=cp
CP=cp -b

# where you want to install
ifndef PREFIX
PREFIX=$(HOME)
endif

# which shell do we use for the cflow to script?
# I know it works on bash on unix, it also should work with
# msh on ms-dog
ifndef CFLOW_SHELL
CFLOW_SHELL=/bin/bash
endif

# actual location of prcc
PRCC_LOC=$(PREFIX)/bin/prcc

# actual location of prcg
PRCG_LOC=$(PREFIX)/bin/prcg

# CFLOW_SHELL=/usr/gnu/bin/bash

PROGS=prcc prcg
# I've seen very long names, and it broke badly with them...

DEFS=-DNAME_MAX=50

# Set if you use Gray Watson dmalloc library
# MALLOC_DEBUG=true
ifdef MALLOC_DEBUG
LOADLIBES=-L$(HOME)/lib -ldmalloc
endif

DEBUG=-g
OPT=-O
CFLAGS=-Wall $(DEBUG) $(OPT) $(DEFS)

# set this to where to install
BINDIR=$(PREFIX)/bin

SRCS=cflow.sh prcc.c prcg.c

PROGS=	prcc prcg

all: $(PROGS)  cflow

$(PROGS):	%:	%.o



PROTOTYPES= prcc.prototypes.h prcg.prototypes.h



.PHONY:  $(PROTOTYPES)
prototypes: 	$(PROTOTYPES)


install:	install-cflow  install-bins

install-bins: $(BINDIR)/prcc $(BINDIR)/prcg

install-cflow:	$(BINDIR)/cflow

$(BINDIR)/prcc $(BINDIR)/prcg: $(BINDIR)/%:	%
	$(CP) $^ $@

$(BINDIR)/cflow:	cflow
	$(CP) $^ $@

cflow:	cflow.sh
	sed -e "s;@CFLOW_SHELL@;$(CFLOW_SHELL);g" \
	    -e "s;@PRCC@;$(PRCC_LOC);" \
	    -e "s;@PRCG@;$(PRCG_LOC);" $< >$@
	chmod +x $@


test:	cflow
	./cflow -X 'errno.h stdlib.h' prcc.c >test.prcc
	./cflow -X 'errno.h stdlib.h' -i prcc.c >test.i.prcc
	diff examples/prcc.cflow test.prcc
	diff examples/prcc.i.cflow test.i.prcc
	# if we got this far, remove examples
	rm test.i.prcc test.prcc

$(PROTOTYPES):	%.prototypes.h:	%.c
	cproto -s $^ >$@

clean::
	-rm $(PROGS) *.o test.prcc test.i.prcc


DISTFILES= cflow.lsm $(PROTOTYPES)  TODO  examples cflow.txt cflow.1 $(SRCS) INSTALL  README Makefile

tar:	cflow.txt examples
	tar -czf cflow.tar.gz $(DISTFILES) 
	@rm cflow.txt


shar:	cflow.txt examples 
	shar -T $(DISTFILES)  >cflow.shar
	@rm cflow.txt

.PHONY: examples
examples:
	-mkdir examples
	cflow -X 'errno.h stdlib.h' prcc.c >examples/prcc.cflow
	cflow -X 'errno.h stdlib.h' -i prcc.c >examples/prcc.i.cflow

	
rcsdiff:
	rcsdiff cflow.1 cflow.sh prcc.c prcg.c Makefile


cflow.txt:	cflow.1
	groff -Tascii -mandoc $< >$@

dos-cflow:
	$(MAKE) CFLOW_SHELL=/marty/bin/shdos16 PREFIX=/dos/marty  install-cflow
zip:

