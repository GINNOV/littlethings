************************************************************************
*  alibtest.asm -- Asm example that calls the Sample.library functions
*
*  Linkage Info:
*  FROM     Astartup.obj, alibtest.o
*  LIBRARY  LIB:amiga.lib, LIB:sample.lib
*  TO       ALibTest
*
*
* Copyright (c) 1992 Commodore-Amiga, Inc.
*
* This example is provided in electronic form by Commodore-Amiga, Inc. for
* use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
* published by Addison-Wesley (ISBN 0-201-56774-1).
*
* The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
* information on the correct usage of the techniques and operating system
* functions presented in these examples.  The source and executable code
* of these examples may only be distributed in free electronic form, via
* bulletin board or as part of a fully non-commercial and freely
* redistributable diskette.  Both the source and executable code (including
* comments) must be included, without modification, in any copy.  This
* example may not be published in printed form or distributed with any
* commercial product.  However, the programming techniques and support
* routines set forth in these examples may be used in the development
* of original executable software products for Commodore Amiga computers.
*
* All other rights reserved.
*
* This example is provided "as-is" and is subject to change; no
* warranties are made.  All use is at your own risk. No liability or
************************************************************************

   INCLUDE   "exec/types.i"
   INCLUDE   "exec/libraries.i"

   INCLUDE   "/sampleinclude/asmsupp.i"
   INCLUDE   "/sampleinclude/samplebase.i"

ABSEXECBASE  EQU  4

   XDEF   _main

   XREF   _printf
   XREF   _LVODouble
   XREF   _LVOAddThese

   XLIB   OpenLibrary
   XLIB   CloseLibrary

        section code
_main:
   ;------ open the test library: this will bring it in from disk
   move.l   ABSEXECBASE,a6
   lea      sampleName(pc),a1
   moveq    #0,d0
   jsr      _LVOOpenLibrary(a6)

   tst.l    d0
   bne.s    1$

   ;------ couldn't find the library
   pea      sampleName(pc)
   pea      nolibmsg(pc)
   jsr      _printf
   addq.l   #8,sp

   bra      main_end

1$:
   move.l   d0,a6    ;sample.library base to a6

   ;------ print the library name, version, and revision
   clr.l    d0
   move.w   LIB_REVISION(a6),d0
   move.l   d0,-(sp)
   move.w   LIB_VERSION(a6),d0
   move.l   d0,-(sp)
   move.l   LN_NAME(a6),-(sp)
   pea      verRevMsg(pc)
   jsr      _printf           ;call Amiga.lib printf
   adda.l   #16,sp            ;fix 4 long stack pushes

   ;------ call the first test function
   moveq    #-7,d0
   jsr      _LVODouble(a6)
   move.l   d0,-(sp)
   pea      doubleMsg(pc)
   jsr      _printf
   lea      8(sp),sp          ;fix 2 long stack pushes

   ;------ call the second test function
   moveq    #21,d0
   moveq    #4,d1
   jsr      _LVOAddThese(a6)
   move.l   d0,-(sp)
   pea      addTheseMsg(pc)
   jsr      _printf
   lea      8(sp),sp

   ;------ close the library
   move.l   a6,a1
   move.l   ABSEXECBASE,a6
   jsr      _LVOCloseLibrary(a6)

main_end:
            rts

sampleName:  SAMPLENAME
nolibmsg:    dc.b   'can not open library "%s"',10,0
doubleMsg:   dc.b   'Function Double(-7) returned %ld',10,0
addTheseMsg: dc.b   'Function AddThese(21,4) returned %ld',10,0
verRevMsg:   dc.b   '%s   Version %ld   Revision %ld',10,0
   END
