* samplebase.i
*
********************************************************************************************
* definition of sample.library base
*******************************************************************************************
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

   IFND  SAMPLE_BASE_I
SAMPLE_BASE_I SET 1


   IFND  EXEC_TYPES_I
   INCLUDE  "exec/types.i"
   ENDC   ; EXEC_TYPES_I

   IFND  EXEC_LIBRARIES_I
   INCLUDE  "exec/libraries.i"
   ENDC   ; EXEC_LIBRARIES_I

;--------------------------
; library data structures
;--------------------------

;  Note that the library base begins with a library node

   STRUCTURE SampleBase,LIB_SIZE
   UBYTE   sb_Flags
   UBYTE   sb_pad
   ;We are now longword aligned
   ULONG   sb_SysLib
   ULONG   sb_DosLib
   ULONG   sb_SegList
   LABEL   SampleBase_SIZEOF


SAMPLENAME   MACRO
      DC.B   'sample.library',0
      ENDM

   ENDC  ;SAMPLE_BASE_I

