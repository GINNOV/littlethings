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
* Sample autoboot code fragment
*
**********************************************************************

**
**
** These are the calling conventions for the Diag routine
**
** A7 -- points to at least 2K of stack
** A6 -- ExecBase
** A5 -- ExpansionBase
** A3 -- your board's ConfigDev structure
** A2 -- Base of diag/init area that was copied
** A0 -- Base of your board
**
** Your Diag routine should return a non-zero value in D0 for success.
** If this value is NULL, then the diag/init area that was copied
** will be returned to the free memory pool.
**

            INCLUDE "exec/types.i"
            INCLUDE "exec/nodes.i"
            INCLUDE "exec/resident.i"
            INCLUDE "libraries/configvars.i"

            ; LVO's resolved by linking with library amiga.lib
            XREF   _LVOFindResident

ROMINFO     EQU      1
ROMOFFS     EQU     $0

* ROMINFO defines whether you want the AUTOCONFIG information in
* the beginning of your ROM (set to 0 if you instead have PALS
* providing the AUTOCONFIG information instead)
*
* ROMOFFS is the offset from your board base where your ROMs appear.
* Your ROMs might appear at offset 0 and contain your AUTOCONFIG
* information in the high nibbles of the first $40 words ($80 bytes).
* Or, your autoconfig ID information may be in a PAL, with your
* ROMs possibly being addressed at some offset (for example $2000)
* from your board base.  This ROMOFFS constant will be used as an
* additional offset from your configured board address when patching 
* structures which require absolute pointers to ROM code or data.

*----- We'll store Version and Revision in serial number
VERSION		EQU	37		; also the high word of serial number
REVISION	EQU	1		; also the low word of serial number

* See the Addison-Wesley Amiga Hardware Manual for more info.

MANUF_ID	EQU	2011		; CBM assigned (2011 for hackers only)
PRODUCT_ID	EQU	1		; Manufacturer picks product ID

BOARDSIZE       EQU     $40000          ; How much address space board decodes
SIZE_FLAG	EQU     3		; Autoconfig 3-bit flag for BOARDSIZE
					;   0=$800000(8meg)  4=$80000(512K)
					;   1=$10000(64K)    5=$100000(1meg)
					;   2=$20000(128K)   6=$200000(2meg)
					;   3=$40000(256K)   7=$400000(4meg)

            CODE


*******  RomStart  ***************************************************
**********************************************************************

RomStart:

	IFGT    ROMINFO
;
;   ExpansionRom structure
;
;   Note - If you implement your ExpansionRom and ExpansionControl
;   with PALS, then you can comment out everything until DiagStart:
;   (ie. Make ROMID EQU 0)

*    ; High nibbles of first two words ($00,$02) are er_Type (not inverted)
						; er_Type
		dc.w	$D000			;   11xx normal board type
						;   xx0x not in memory free list
						;   xxx1 Diag valid (has driver)
		dc.w	(SIZE_FLAG<<12)&$7000	;   0xxx not chained
						;   xnnn flags board size

*    ; High nibbles of next two words are er_Product
*    ; These are inverted (~), as are all other words except $40 and $42

						; er_Product
		dc.w	(~(PRODUCT_ID<<8))&$f000,(~(PRODUCT_ID<<12))&$f000

						; er_Flags
		dc.w	(~$C000)&$f000		;   ~1xxx board is moveable
						;   ~x1xx board can't be shut up
		dc.w	(~0)&$f000		;

		dc.w	(~0)&$f000,(~0)&$f000	; er_Reserved03

						; er_Manufacturer
		dc.w	(~(MANUF_ID))&$f000,(~(MANUF_ID<<4))&$f000
		dc.w	(~(MANUF_ID<<8))&$f000,(~(MANUF_ID<<12))&$f000

						; er_SerialNumber
		dc.w	(~(VERSION))&$f000,(~(VERSION<<4))&$f000
		dc.w	(~(VERSION<<8))&$f000,(~(VERSION<<12))&$f000
		dc.w	(~(REVISION))&$f000,(~(REVISION<<4))&$f000
		dc.w	(~(REVISION<<8))&$f000,(~(REVISION<<12))&$f000

						; er_InitDiagVec
		dc.w	(~((DiagStart-RomStart)))&$f000
		dc.w	(~((DiagStart-RomStart)<<4))&$f000
		dc.w	(~((DiagStart-RomStart)<<8))&$f000
		dc.w	(~((DiagStart-RomStart)<<12))&$f000

		dc.w	(~0)&$f000,(~0)&$f000	; er_Reserved0c
		dc.w	(~0)&$f000,(~0)&$f000	; er_Reserved0d
		dc.w	(~0)&$f000,(~0)&$f000	; er_Reserved0e
		dc.w	(~0)&$f000,(~0)&$f000	; er_Reserved0f

	IFNE	*-RomStart-$40
	FAIL	"ExpansionRom structure not the right size"
	ENDC

		;Note: nibbles $40 and $42 are not to be inverted
		dc.w	(0)&$f000,(0)&$f000	; ec_Interrupt (no interrupts)
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved11
		dc.w	(~0)&$f000,(~0)&$f000	; ec_BaseAddress (write only)
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Shutup (write only)
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved14
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved15
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved16
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved17
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved18
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved19
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved1a
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved1b
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved1c
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved1d
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved1e
		dc.w	(~0)&$f000,(~0)&$f000	; ec_Reserved1f

	IFNE	*-RomStart-$80
	FAIL	"Expansion Control structure not the right size"
	ENDC

	ENDC	;ROMINFO

*******  DiagStart  **************************************************
DiagStart:  ; This is the DiagArea structure whose relative offset from
            ; your board base appears as the Init Diag vector in your
            ; autoconfig ID information.  This structure is designed
            ; to use all relative pointers (no patching needed).
            dc.b    DAC_WORDWIDE+DAC_CONFIGTIME    ; da_Config
            dc.b    0                              ; da_Flags
            dc.w    EndCopy-DiagStart              ; da_Size
            dc.w    DiagEntry-DiagStart            ; da_DiagPoint
            dc.w    BootEntry-DiagStart            ; da_BootPoint
            dc.w    DevName-DiagStart              ; da_Name
            dc.w    0                              ; da_Reserved01
            dc.w    0                              ; da_Reserved02

*******  Resident Structure  *****************************************
Romtag:
            dc.w    RTC_MATCHWORD      ; UWORD RT_MATCHWORD
rt_Match:   dc.l    Romtag-DiagStart   ; APTR  RT_MATCHTAG
rt_End:     dc.l    EndCopy-DiagStart  ; APTR  RT_ENDSKIP
            dc.b    RTW_COLDSTART      ; UBYTE RT_FLAGS
            dc.b    VERSION            ; UBYTE RT_VERSION
            dc.b    NT_DEVICE          ; UBYTE RT_TYPE
            dc.b    20                 ; BYTE  RT_PRI
rt_Name:    dc.l    DevName-DiagStart  ; APTR  RT_NAME
rt_Id:      dc.l    IdString-DiagStart ; APTR  RT_IDSTRING
rt_Init:    dc.l    Init-RomStart      ; APTR  RT_INIT


******* Strings referenced in Diag Copy area  ************************
DevName:    dc.b    'abc.device',0                      ; Name string
IdString    dc.b    'abc ',48+VERSION,'.',48+REVISION   ; Id string
  
DosName:    dc.b    'dos.library',0                ; DOS library name

DosDevName: dc.b    'ABC',0        ; dos device name for MakeDosNode()
                                   ;   (dos device will be ABC:)

            ds.w    0              ; word align

*******  DiagEntry  **************************************************
**********************************************************************
*
*   success = DiagEntry(BoardBase,DiagCopy, configDev)
*   d0                  a0         a2                  a3
*
*   Called by expansion architecture to relocate any pointers
*   in the copied diagnostic area.   We will patch the romtag.
*   If you have pre-coded your MakeDosNode packet, BootNode, 
*   or device initialization structures, they would also need
*   to be within this copy area, and patched by this routine.
*
**********************************************************************

DiagEntry:
            lea      patchTable-RomStart(a0),a1   ; find patch table
            adda.l   #ROMOFFS,a1                  ; adjusting for ROMOFFS

* Patch relative pointers to labels within DiagCopy area
* by adding Diag RAM copy address.  These pointers were coded as
* long relative offsets from base of the DiagArea structure.
* 
dpatches:
            move.l   a2,d1           ;d1=base of ram Diag copy
dloop:
            move.w   (a1)+,d0        ;d0=word offs. into Diag needing patch
            bmi.s    bpatches        ;-1 is end of word patch offset table
            add.l    d1,0(a2,d0.w)   ;add DiagCopy addr to coded rel. offset
            bra.s    dloop

* Patches relative pointers to labels within the ROM by adding
* the board base address + ROMOFFS.  These pointers were coded as
* long relative offsets from RomStart.
bpatches:
            move.l   a0,d1           ;d1 = board base address
            add.l    #ROMOFFS,d1     ;add offset to where your ROMs are
rloop:
            move.w   (a1)+,d0        ;d0=word offs. into Diag needing patch
            bmi.s   endpatches       ;-1 is end of patch offset table
            add.l   d1,0(a2,d0.w)    ;add ROM address to coded relative offset
            bra.s   rloop

endpatches:
            moveq.l #1,d0           ; indicate "success"
            rts


*******  BootEntry  **************************************************
**********************************************************************

BootEntry:  lea     DosName(PC),a1          ; 'dos.library',0
            jsr     _LVOFindResident(a6)    ; find the DOS resident tag
            move.l  d0,a0                   ; in order to bootstrap
            move.l  RT_INIT(A0),a0          ; set vector to DOS INIT
            jsr     (a0)                    ; and initialize DOS
            rts

*
* End of the Diag copy area which is copied to RAM
*
EndCopy:
*************************************************************************

*************************************************************************
*
*   Beginning of rom driver code and data that is accessed only in
*   the rom space.  This must all be position-independent.
*

patchTable:
* Word offsets into Diag area where pointers need Diag copy address added
            dc.w   rt_Match-DiagStart
            dc.w   rt_End-DiagStart
            dc.w   rt_Name-DiagStart
            dc.w   rt_Id-DiagStart
            dc.w   -1

* Word offsets into Diag area where pointers need boardbase+ROMOFFS added
            dc.w   rt_Init-DiagStart
            dc.w   -1

*******  Romtag InitEntry  **********************************************
*************************************************************************

Init:       ; After Diag patching, our romtag will point to this 
            ; routine in ROM so that it can be called at Resident
            ; initialization time.
            ; This routine will be similar to a normal expansion device
            ; initialization routine, but will MakeDosNode then set up a
            ; BootNode, and Enqueue() on eb_MountList. 
            ;
            rts

            ; Rest of your position-independent device code goes here.

            END
