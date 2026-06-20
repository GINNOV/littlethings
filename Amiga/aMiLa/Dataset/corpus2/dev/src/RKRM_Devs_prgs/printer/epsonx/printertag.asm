*
* Copyright (c) 1992 Commodore-Amiga, Inc.
* 
* This example is provided in electronic form by Commodore-Amiga, Inc. for 
* use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
* published by Addison-Wesley (ISBN 0-201-56775-X).
* 
* The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
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
*
**********************************************************************
*
*       printer device dependent code tag
*
**********************************************************************

        SECTION         printer

*------ Included Files -----------------------------------------------

        INCLUDE         "exec/types.i"
        INCLUDE         "exec/nodes.i"
        INCLUDE         "exec/strings.i"

        INCLUDE         "epsonX_rev.i"

        INCLUDE         "devices/prtbase.i"


*------ Imported Names -----------------------------------------------

        XREF            _Init
        XREF            _Expunge
        XREF            _Open
        XREF            _Close
        XREF            _CommandTable
        XREF            _PrinterSegmentData
        XREF            _DoSpecial
        XREF            _Render
        XREF            _ExtendedCharTable

*------ Exported Names -----------------------------------------------

        XDEF            _PEDData


**********************************************************************

                MOVEQ   #0,D0           ; show error for OpenLibrary()
                RTS
                DC.W    VERSION
                DC.W    REVISION
_PEDData:
                DC.L    printerName
                DC.L    _Init
                DC.L    _Expunge
                DC.L    _Open
                DC.L    _Close
                DC.B    PPC_COLORGFX    ;PrinterClass
                DC.B    PCC_YMCB        ; ColorClass
                DC.B    136             ; MaxColumns
                DC.B    10              ; NumCharSets
                DC.W    8               ; NumRows
                DC.L    1632            ; MaxXDots
                DC.L    0               ; MaxYDots
                DC.W    120             ; XDotsInch
                DC.W    72              ; YDotsInch
                DC.L    _CommandTable   ; Commands
                DC.L    _DoSpecial
                DC.L    _Render
                DC.L    30              ; Timeout
                DC.L    _ExtendedCharTable      ; 8BitChars
                DS.L    1               ; PrintMode (reserve space)
                DC.L    0               ; ptr to char conversion function

printerName:
                dc.b    'EpsonX',0

                END
