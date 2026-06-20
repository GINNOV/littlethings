
.PHONY:
	@echo

default: .PHONY
	@echo " "
	@echo "GAP-Lib (C)1998-1999 Peter Bengtsson"
	@echo " "
	@echo "Target must be one of:"
	@echo "  generic    - Generic version (gcc/egcs)."
	@echo "  unixcc     - Generic version (cc)."
	@echo "  vbcc       - Generic version (vbcc). (Not Amiga.)"
	@echo "  amiga      - Amiga SAS/C version."
	@echo "  m68k       - Motorola m68k gcc/egcs version."
	@echo "  sparc      - Sun Sparc gcc/egcs version."
	@echo "  x86        - Intel x86 gcc/egcs version."
	@echo " "
	@echo "  tests      - Diagnostics for GAPLib (gcc/egcs)."
	@echo " "
	@echo "  examples   - Compile examples (gcc/egcs)."
	@echo "  amigaex    - Compile examples with Amiga SAS/C."
	@echo " "
	@echo "  wizards    - Source wizards (gcc/egcs)."
	@echo "  amigawiz   - Source wizards with Amiga SAS/C."
	@echo " "
	@echo "  clean      - Clean up directories (gmake)."
	@echo " "
	@echo "  check      - Check MD5 checksums for files."
	@echo " "
	@echo "  install    - Quick hack to install GAP-Lib under /usr/local"


generic: .PHONY
	gmake -C gaplib -f Makefile lib

unixcc: .PHONY
	unixcc.sh gaplib lib

amiga: .PHONY
	@execute Amiga.sh gaplib lib

m68k: .PHONY
	gmake -C gaplib -f Makefile.m68k lib

sparc: .PHONY
	gmake -C gaplib -f Makefile.sparc lib

x86: .PHONY
	gmake -C gaplib -f Makefile.x86 lib
	
clean: .PHONY
	gmake -C gaplib -f Makefile clean
	gmake -C wizards -f Makefile clean
	gmake -C diagnostic -f Makefile clean

distclean: clean
	@-rm bin/*
	@-rm lib/*	

wizards: .PHONY
	gmake -C wizards -f Makefile all

tests: .PHONY
	gmake -C diagnostic -f Makefile test

amigawiz: .PHONY
	@execute Amiga.sh wizards all

examples: .PHONY
	gmake -C examples -f Makefile all

amigaex: .PHONY
	@execute Amiga.sh examples all

check: .PHONY
	md5sum -c Checksums

install: lib/libgap.a include/GAP.h
	install lib/libgap.a /usr/local/lib/
	install include/GAP.h /usr/local/include/

#
# Maintainance only.
#

checksums: .PHONY
	@echo "Rebuilding checksums..."
	@delete Checksums\#\?
	@list \#\? all files \>t:check lformat\=\"md5sum \%p\%n\ \>\>Checksums\"
	@echo \>Checksums \"\# MD5 Checksums.\"
	@execute t:check
	pgp -sb Checksums peter
	
docs: .PHONY
	@echo "Rebuilding documentation from autodoc."
	@-delete doc/html/GAP\.html
	@-delete doc/amigaguide/GAP\.guide
	echo >build.tmp "GAP-Lib Function Reference*NGAP.html*N1"
	autodoc2x doc/text/GAP.doc \<build.tmp \>Nil\:
	@rename GAP.html doc/html/ \>Nil\:
	echo >build.tmp "GAP-Lib Function Reference*NGAP.guide*N2"
	autodoc2x doc/text/GAP.doc \<build.tmp \>Nil\:
	@rename GAP.guide doc/amigaguide/ \>Nil\:
	@-delete build.tmp \>Nil\:
