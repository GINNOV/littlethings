***************************************************************************
* sample_lvos.asm   _LVO definitions
*
*  This is the .fd file for our sample library:
*
* Note - the slash in (D0/D1) means that a stub-maker can use MOVEM.L to
* load these registers from the stack, rather than using a separate MOVE
* instruction for each register. Alternately, something like  (A0,D2) would
* show that a separate MOVE instruction is needed for each load.
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

