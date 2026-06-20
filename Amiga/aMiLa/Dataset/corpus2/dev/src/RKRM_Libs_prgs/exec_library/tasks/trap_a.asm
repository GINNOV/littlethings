* trap_a.asm - Example trap handling code (leaves D0 intact).  Entered
* in supervisor mode with the following on the supervisor stack:
*    0(sp).l = trap#
*    4(sp) Processor dependent exception frame
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

    INCLUDE "exec/types.i"
    INCLUDE "libraries/dos.i"

        XDEF _trapa
        XREF _countdiv0
        XREF _oldTrapCode

        CODE
_trapa:                                 ; our trap handler entry
        CMPI.L  #5,(SP)                 ; is this a divide by zero ?
        BNE.S   notdiv0                 ; no
        ADD.L   #1,_countdiv0           ; yes, increment our div0 count
endtrap:
        ADDQ    #4,SP                   ; remove exception number from SSP
        RTE                             ; return from exception
notdiv0:
        TST.L   _oldTrapCode            ; is there another trap handler ?
        BEQ.S   endtrap                 ; no, so we'll exit
        MOVE.L  _oldTrapCode,-(SP)      ; yes, go on to old TrapCode
        RTS                             ; jumps to old TrapCode

        END