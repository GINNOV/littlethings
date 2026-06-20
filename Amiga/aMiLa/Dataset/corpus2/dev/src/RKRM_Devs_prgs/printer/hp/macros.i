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
*       printer device macro definitions
*
**********************************************************************

*------ external definition macros -----------------------------------

XREF_EXE        MACRO
        XREF            _LVO\1
                ENDM

XREF_DOS        MACRO
        XREF            _LVO\1
                ENDM

XREF_GFX        MACRO
        XREF            _LVO\1
                ENDM

XREF_ITU        MACRO
        XREF            _LVO\1
                ENDM

*------ library dispatch macros --------------------------------------

CALLEXE         MACRO
                CALLLIB _LVO\1
                ENDM

LINKEXE         MACRO
                LINKLIB _LVO\1,_SysBase
                ENDM

LINKDOS         MACRO
                LINKLIB _LVO\1,_DOSBase
                ENDM

LINKGFX         MACRO
                LINKLIB _LVO\1,_GfxBase
                ENDM

LINKITU         MACRO
                LINKLIB _LVO\1,_IntuitionBase
                ENDM
