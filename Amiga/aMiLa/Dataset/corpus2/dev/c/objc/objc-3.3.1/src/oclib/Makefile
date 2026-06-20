
#
# Portable Object Compiler
# $Id: Makefile.in,v 1.3 2015/12/25 18:09:18 stes Exp $
#

#
# This Makefile should work with UNIX make's (like SysV, BSD, GNU make)
#

OBJC=objc -q
RM=rm -f
CP=cp -p
AR=ar cr
FINAL_AR=echo
RANLIB=ranlib

DBG_MFLAGS=-DDEBUG -g
OPT_MFLAGS=-DNDEBUG -O2
OBJSUFFIX=o
LIBSUFFIX=a
IFLAGS=-noI -I../../include/objcrt -I../../include/objpak
MFLAGS=$(OPT_MFLAGS)

.SUFFIXES: .m 

LIBRARY=oclib.$(LIBSUFFIX)

OBJFILES=\
    node.$(OBJSUFFIX)\
    stkframe.$(OBJSUFFIX)\
    symbol.$(OBJSUFFIX)\
    stclass.$(OBJSUFFIX)\
    cppdirec.$(OBJSUFFIX)\
    type.$(OBJSUFFIX)\
    options.$(OBJSUFFIX)\
    stmt.$(OBJSUFFIX)\
    ifstmt.$(OBJSUFFIX)\
    whilstmt.$(OBJSUFFIX)\
    switstmt.$(OBJSUFFIX)\
    lblstmt.$(OBJSUFFIX)\
    rtrnstmt.$(OBJSUFFIX)\
    dfltstmt.$(OBJSUFFIX)\
    casestmt.$(OBJSUFFIX)\
    compstmt.$(OBJSUFFIX)\
    exprstmt.$(OBJSUFFIX)\
    gotostmt.$(OBJSUFFIX)\
    contstmt.$(OBJSUFFIX)\
    forstmt.$(OBJSUFFIX)\
    dostmt.$(OBJSUFFIX)\
    decl.$(OBJSUFFIX)\
    pointer.$(OBJSUFFIX)\
    arydecl.$(OBJSUFFIX)\
    fundecl.$(OBJSUFFIX)\
    precdecl.$(OBJSUFFIX)\
    bflddecl.$(OBJSUFFIX)\
    pfixdecl.$(OBJSUFFIX)\
    initdecl.$(OBJSUFFIX)\
    keywdecl.$(OBJSUFFIX)\
    namedecl.$(OBJSUFFIX)\
    stardecl.$(OBJSUFFIX)\
    var.$(OBJSUFFIX)\
    aryvar.$(OBJSUFFIX)\
    scalar.$(OBJSUFFIX)\
    expr.$(OBJSUFFIX)\
    listxpr.$(OBJSUFFIX)\
    keywxpr.$(OBJSUFFIX)\
    condxpr.$(OBJSUFFIX)\
    castxpr.$(OBJSUFFIX)\
    unyxpr.$(OBJSUFFIX)\
    deref.$(OBJSUFFIX)\
    addrof.$(OBJSUFFIX)\
    sizeof.$(OBJSUFFIX)\
    typeof.$(OBJSUFFIX)\
    pfixxpr.$(OBJSUFFIX)\
    indexxpr.$(OBJSUFFIX)\
    binxpr.$(OBJSUFFIX)\
    dotxpr.$(OBJSUFFIX)\
    arrowxpr.$(OBJSUFFIX)\
    msgxpr.$(OBJSUFFIX)\
    blockxpr.$(OBJSUFFIX)\
    selxpr.$(OBJSUFFIX)\
    precxpr.$(OBJSUFFIX)\
    commaxpr.$(OBJSUFFIX)\
    constxpr.$(OBJSUFFIX)\
    identxpr.$(OBJSUFFIX)\
    assign.$(OBJSUFFIX)\
    relxpr.$(OBJSUFFIX)\
    funcall.$(OBJSUFFIX)\
    btincall.$(OBJSUFFIX)\
    def.$(OBJSUFFIX)\
    fundef.$(OBJSUFFIX)\
    methdef.$(OBJSUFFIX)\
    funbody.$(OBJSUFFIX)\
    method.$(OBJSUFFIX)\
    selector.$(OBJSUFFIX)\
    gasmop.$(OBJSUFFIX)\
    gasmstmt.$(OBJSUFFIX)\
    dasmstmt.$(OBJSUFFIX)\
    gattrib.$(OBJSUFFIX)\
    gatrdecl.$(OBJSUFFIX)\
    compdef.$(OBJSUFFIX)\
    datadef.$(OBJSUFFIX)\
    globdef.$(OBJSUFFIX)\
    structsp.$(OBJSUFFIX)\
    classdef.$(OBJSUFFIX)\
    enumtor.$(OBJSUFFIX)\
    enumsp.$(OBJSUFFIX)\
    parmdef.$(OBJSUFFIX)\
    parmlist.$(OBJSUFFIX)\
    util.$(OBJSUFFIX)\
    trlunit.$(OBJSUFFIX)

.m.$(OBJSUFFIX):
	$(OBJC) -c $*.m $(MFLAGS) $(IFLAGS)
	$(AR) $(LIBRARY) $@ 

$(LIBRARY) : $(OBJFILES)
	$(FINAL_AR) $(LIBRARY) $(OBJFILES)
	$(RANLIB) $(LIBRARY)

install :

cleantmp :
	-$(RM) *.P
	-$(RM) *.c
	-$(RM) *.i

clean : cleantmp
	-$(RM) *.$(OBJSUFFIX)
	-$(RM) *.$(LIBSUFFIX)

distclean : clean
	-$(RM) Makefile 
	-$(RM) config.h 

