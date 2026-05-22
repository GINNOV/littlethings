#
# Simple makefile & doc for NullHandler & TestNull
#
# $VER: Makefile 37.1 (12.8.92) -- Makefile for NullHandler & TestNull
#
# Exception handler example
#
# Copyright (C) 1992 Compos Mentis Software Systems -- Jesper Kehlet
#
# May be freely redistributed and reused as long as archive is kept in it's
# entirety -- that includes:
#
# Makefile      - This is what you're reading            - 2672 bytes
# NullHandler   - The division by zero exception handler -  216 bytes
# NullHandler.o - The exception handler object file      -  232 bytes
# NullHandler.a - -   -         -       source file      - 3374 bytes
# TestNull      - A small TRAP #5 test program           -   44 bytes
# TestNull.o    - TestNull object file                   -   52 bytes
# TestNull.a    - -        source -                      -  856 bytes
#
# NullHandler is an example of how easy it is to set up an exception
# handler that can be removed without doing an immense amount of work with
# setting up ports etc.
#
# It is, of course, not bullet-proof, but if you choose an IDENT string
# made up from something like your cat or something -- sure Dave would
# choose IGGY -- it should be fairly unique to any other exception handler,
# that may be installed after this one.
#
# It does not check whether or not we get the memory we want, but since
# it's only 58 bytes, it's not a healthy system if we don't get it, so who
# cares then?
#
# When this handler is installed, it saves the address of the original
# code, so everything is restored properly when run the second time.
#
# When run a second time, it removes itself (if possible), and returns
# WARN to tell you it's no longer there.
#
# So an installation script would be:
#
# NullHandler
# If WARN
#   NullHandler
# EndIf
#
# And you can be fairly sure it's installed...
#
# So, if you decide to install some other exception handlers for the same
# vector after this one, you must remove those before this one can find
# itself.  This ONLY looks at the currently installed one.  That's a
# drawback, but then again, it's small and you don't really install that
# many exception handlers, do you?
#
# This was done with the SAS 5.10b assembler
#
# If you want to port to a68k or something:
# -----------------------------------------
# The assembler flag -m2 suppresses the 68020+ opcode warnings
# -   -         -    -i specifies a path to your include files.
#
# The lvo/ directory I use is for my _LVO-files made by GetLVO.
#

AS	= Asm
AFLAGS	= -m2 -iAINCLUDE:
LN	= BLink
ASRC	= NullHandler.a TestNull.a

all:	NullHandler.o TestNull.o
	$(LN) NullHandler.o
	$(LN) TestNull.o

.a.o:	NullHandler.a TestNull.a
	$(AS) $(AFLAGS) $*
