*******************************************************************************************
* sample_stubs.asm
*
* Stubs match this .fd file:
*
*       ##base _SampleBase
*       ##bias 30
*       ##public
*       Double(n1)(D0)
*       AddThese(n1,n2)(D0/D1)
*       ##end
*
* After assembling,
*   JOIN sample_stubs.o sample_lvos.o AS sample.lib
*
* Apps LINK with LIBRARY sample.lib when calling sample.library functions
*
* If you put all of your stubs in one file, as shown here, then ALL of the stubs will be
* linked into an application that references one stub.  For larger libraries, you should
* place each stub in a separate assembler file, assemble them each separately, then join
* all of the .o's together. That will allow each stub to be independently pulled into the
* application that links with the .lib.
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
* responsibility is assumed.
***************************************************************************

   INCLUDE  "exec/types.i"
   INCLUDE  "exec/libraries.i"

          SECTION data

*----- LIBINIT initializes an LVO value to -30 to skip the first four
*----- 6-byte required library vectors (Open, Expunge, etc)

             LIBINIT

*----- LIBDEF assigns the current LVO value to a label, and then
*----- bumps the LVO value by -6 in preparation for next LVO label

*----- This assigns the value -30 to our first _LVO label

             LIBDEF      _LVODouble     ;-30
             XDEF        _LVODouble

*----- The value -30-6 is asigned to our second _LVO label

             LIBDEF      _LVOAddThese   ;-36
             XDEF        _LVOAddThese

             END

*******************************************************************************************
   INCLUDE  "exec/types.i"
   INCLUDE  "exec/libraries.i"

          section code

*------ Caller declares and initializes SampleBase in their C code

            XREF        _SampleBase

*------ Must externally reference the _LVO labels defined in samplelib_lvos

            XREF        _LVODouble
            XREF        _LVOAddThese

*------ Make C function stubs available to caller

            XDEF        _Double
            XDEF        _AddThese

*------- These stubs move C args from stack to appropriate registers,
*------- call the library function, and return result in d0

_Double:
            MOVE.L      A6,-(SP)           ;Save register(s)
            MOVE.L      8(SP),D0           ;Copy param to register
            MOVE.L      _SampleBase,A6     ;Library base to A6
            JSR         _LVODouble(A6)     ;Go to real routine
            MOVE.L      (SP)+,A6           ;Restore register(s)
            RTS

_AddThese:
            MOVE.L      A6,-(SP)           ;Save register(s)
            MOVEM.L     8(SP),D0/D1        ;Copy params to registers
                                           ;8(SP)  goes into D0
                                           ;12(SP) goes into D1
            MOVE.L      _SampleBase,A6     ;Library base to A6
            JSR         _LVOAddThese(A6)   ;Go to real routine
            MOVE.L      (SP)+,A6           ;Restore register(s)
            RTS

          END

