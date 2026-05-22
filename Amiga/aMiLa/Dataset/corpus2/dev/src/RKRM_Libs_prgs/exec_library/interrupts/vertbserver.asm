* vertbserver.asm. Example simple interrupt server for vertical blank
*
* Assembled with Howesoft Adapt 680x0 Macro Assembler Rel. 1.0
* hx68 from: vertbserver.asm to vertbserver.o INCDIR include:
* blink from lib:c.o vertb.o vertbserver.o to vertb lib lib:lc.lib lib:amiga.lib
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
    INCLUDE "hardware/custom.i"
    INCLUDE "hardware/intbits.i"

        XDEF    _VertBServer

* Entered with:       A0 == scratch (execpt for highest pri vertb server)
*  D0 == scratch      A1 == is_Data
*  D1 == scratch      A5 == vector to interrupt code (scratch)
*                     A6 == scratch
*
    section code

_VertBServer:
        ADDI.L  #1,(a1)           ; increments counter is_Data points to
        MOVEQ.L #0,d0             ; set Z flag to continue to process other vb-servers
        RTS                       ;return to exec
        END
