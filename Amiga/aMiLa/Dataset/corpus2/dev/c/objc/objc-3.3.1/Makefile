
#
# Portable Object Compiler (c) 1996, 97, 2015. All Rights Reserved.
# $Id: Makefile.in,v 1.12 2015/12/25 21:08:06 stes Exp $
#

CD=cd
RM=rm

MKDIR=mkdir
INSTALLDIR=/usr/local
INSTALL=/bin/install -c
HDRDIR=/usr/local/include
MANDIR=/usr/local/man

default ::
	$(MAKE) compiler
	$(MAKE) cakit

compiler : objcrt objpak oclib objc

runtimer : objcrtr objpakr cakitr

objcrt ::
	$(CD) src; $(CD) objcrt; $(MAKE)

objcrtr ::
	$(CD) src;$(CD) objcrt; $(MAKE) OBJC="objc -q -refcnt" LIBRARY=objcrtr.a

objpak ::
	$(CD) src; $(CD) objpak; $(MAKE)

objpakr ::
	$(CD) src;$(CD) objpak; $(MAKE) OBJC="objc -q -refcnt" LIBRARY=objpakr.a

oclib ::
	$(CD) src; $(CD) oclib;  $(MAKE)

objc ::
	$(CD) src; $(CD) objc;   $(MAKE)

cakit ::
	$(CD) src; $(CD) cakit;  $(MAKE)

cakitr ::
	$(CD) src;$(CD) cakit;$(MAKE) OBJC="objc -q -refcnt" LIBRARY=cakitr.a

browse ::
	objc -browse tmp browse.h
	cd tmp;cursel Menu.main

shlib ::
	$(CD) src; $(CD) objcrt; $(MAKE) shlib
	$(CD) src; $(CD) objpak; $(MAKE) shlib

#
# tags file (vi -t isEqual , for example, brings you to isEqual)
# control-] for a classname also works.
#

tags :
	gawk -f ctags.awk src/objcrt/*.m src/objpak/*.m src/oclib/*.m > tags

#
# UNIX install.
#

MAN1PAGES=cvtimport.1 objc.1 postlink.1 vici.1
MAN3PAGES=Array.3 Message.3 Polynomial.3 Term.3 AsciiFiler.3 Dictionary.3 Monomial.3 Rectangle.3 Text.3 BadVersion.3 Exception.3 NotFound.3 RunArray.3 TextAttribute.3 Bag.3 Float.3 Object.3 Sequence.3 TextStyle.3 BigInt.3 Fraction.3 OrdCltn.3 Set.3 TypeInconsistency.3 Block.3 IdArray.3 OutOfBounds.3 SortCltn.3 UnknownType.3 CAObject.3 IntArray.3 OutOfMemory.3 Stack.3 Vector.3 Cltn.3 IntegerModp.3 Paragraph.3 String.3 Complex.3 Matrix.3 Point.3 Symbol.3 

CAKITHDRS=cakit.h cfloat.h intmodp.h polynom.h vector.h ccltn.h cobject.h fraction.h matrix.h symbol.h ccomplex.h cseq.h integer.h monomial.h term.h
PPIHDRS=Array.h Filer.h IdArray.h mivarargs.h SortCltn.h vectors.h Assoc.h Graph.h IntArray.h OrdCltn.h StringCl.h ICpak101.h IPSequence.h Sequence.h String.h
OBJCRTHDRS=Block.h Exceptn.h Message.h objc.h objcrt.h Object.h OutOfMem.h
OBJPAKHDRS=array.h objpak.h paragrph.h set.h typeinc.h ascfiler.h dictnary.h ocstring.h point.h sortcltn.h unknownt.h badvers.h idarray.h octext.h rectangl.h stack.h bag.h intarray.h ordcltn.h runarray.h txtattr.h cltn.h notfound.h outofbnd.h sequence.h txtstyle.h

install : compiler cakit
	test -d $(INSTALLDIR) || $(MKDIR) $(INSTALLDIR)
	test -d $(MANDIR) || $(MKDIR) $(MANDIR)
	test -d $(MANDIR)/man1 || $(MKDIR) $(MANDIR)/man1
	test -d $(MANDIR)/man3 || $(MKDIR) $(MANDIR)/man3
	test -d $(HDRDIR) || $(MKDIR) $(HDRDIR)
	test -d $(HDRDIR)/ppi    || $(MKDIR) $(HDRDIR)/ppi
	test -d $(HDRDIR)/objcrt || $(MKDIR) $(HDRDIR)/objcrt
	test -d $(HDRDIR)/objpak || $(MKDIR) $(HDRDIR)/objpak
	test -d $(HDRDIR)/cakit  || $(MKDIR) $(HDRDIR)/cakit
	-$(CD) src; $(CD) objcrt; $(MAKE) install
	-$(CD) src; $(CD) objpak; $(MAKE) install
	-$(CD) src; $(CD) objc;   $(MAKE) install
	-$(CD) src; $(CD) cakit;  $(MAKE) install
	-$(CD) man; $(CD) man1; $(INSTALL) $(MAN1PAGES) $(MANDIR)/man1
	-$(CD) man; $(CD) man3; $(INSTALL) $(MAN3PAGES) $(MANDIR)/man3
	-$(CD) include; $(CD) ppi; $(INSTALL) $(PPIHDRS) $(HDRDIR)/ppi
	-$(CD) include; $(CD) objcrt; $(INSTALL) $(OBJCRTHDRS) $(HDRDIR)/objcrt
	-$(CD) include; $(CD) objpak; $(INSTALL) $(OBJPAKHDRS) $(HDRDIR)/objpak
	-$(CD) include; $(CD) cakit; $(INSTALL) $(CAKITHDRS) $(HDRDIR)/cakit

cleantmp :
	-$(CD) src; $(CD) objcrt; $(MAKE) cleantmp
	-$(CD) src; $(CD) objpak; $(MAKE) cleantmp
	-$(CD) src; $(CD) oclib;  $(MAKE) cleantmp
	-$(CD) src; $(CD) objc;   $(MAKE) cleantmp
	-$(CD) src; $(CD) cakit;  $(MAKE) cleantmp
	-$(CD) examples;          $(MAKE) cleantmp
	-$(CD) words;             $(MAKE) cleantmp

cleanruntime :
	-$(CD) src; $(CD) objcrt; $(MAKE) clean
	-$(CD) src; $(CD) objpak; $(MAKE) clean
	-$(CD) src; $(CD) cakit;  $(MAKE) clean

clean : cleanruntime
	-$(CD) src; $(CD) oclib;  $(MAKE) clean
	-$(CD) src; $(CD) objc;   $(MAKE) clean
	-$(CD) examples;          $(MAKE) clean
	-$(CD) words;             $(MAKE) clean

distclean :
	-$(RM) Makefile tags
	-$(RM) config.h config.cache config.log config.status
	-$(CD) src; $(CD) objcrt; $(MAKE) distclean
	-$(CD) src; $(CD) objpak; $(MAKE) distclean
	-$(CD) src; $(CD) oclib;  $(MAKE) distclean
	-$(CD) src; $(CD) objc;   $(MAKE) distclean
	-$(CD) src; $(CD) cakit;  $(MAKE) distclean
	-$(CD) examples;          $(MAKE) distclean
	-$(CD) words;             $(MAKE) distclean

