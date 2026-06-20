
GAP-Lib, a Genetic Algorith Programming Library.

To compile:
	Type "make <target>" where <target> is one of
	the targets listed if you type just "make".

To install: (You might have to ask your system administrator to do this)
	First compile, then copy include/GAP.h to wherever
	your includes reside and copy lib/libhal.a to somewhere
	in your library search path.

Amiga & SAS/C:
	Compile as usual (target=amiga), copy include/GAP.h to include:
	and lib/GAP.lib to lib:. Note that the default configuration
	of GAP-Lib for Amiga requires a FPU (Floating Point Unit).

The contents of this directory should be as follows:

README.TXT	- This file.

README.StormC	- Explaining why I do not support StormC (Amiga).

Checksums	- MD5 Checksums for all files except
		  "Checksums" and "Checksums.sig".

Checksums.sig	- PGP signature for "Checksums".

doc		- This directory contains Documentation and an Introduction.
		  The docs are in Text (ISO-8859-1), PostScript(tm), 
		  AmigaGuide(tm) and HTML format.

examples	- Example sources.

gaplib		- Library sources.

genomes		- Example genomes.

include		- Library includes.

lib		- Compiled libraries.

diagnostic	- Diagnostic sources (For testing GAP-Lib functions).

Amiga.sh	- Make utility-script.

Makefile	- Standard makefile.

Makefile.info	- Amiga(tm) Icon file.

unixcc.sh	- Make utility-script.

utility		- Utility sources for GAP-Lib (Report file generation).

wrapper		- C++ Wrapper class for GAP-Lib.

images		- Visualizations of some functions found in the
		  examples directory.

wizards		- Magic programs to automate some tasks which you thought
		  were horribly complicated.

