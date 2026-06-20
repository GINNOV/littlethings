; ===================================================================
;
;                             AGAC.soslibrary
;   
;                            AGA Color Library
;
;                                 V 1.0
;
;
;                             include-datei
;
; ===================================================================

; Library Offsets

_CopyAgaCop32	equ	-48
_InitAgaCop32	equ	-42
_DoAgaFade	equ	-36
_InitAgaFade	equ	-30
_CopyAgaHard	equ	-24
_CopyAgaCopper	equ	-18
_InitAgaCopper	equ	-12

; ===================================================================
;
;  AGACBase
;
; ===================================================================

		rsreset
		rs.b	LIB_SIZEOF
AGACB_BPLCON3D	rs.w	1	; Default
AGACB_BPLCON3	rs.w	1	; Used

; If you need another initialisation for BPLCON3, change AGACB_BPLCON3
; to your desired value (AND $1dff) before using any InitAgaCopper() or
; CopyAgaHard() function and be shure to reset it with the value given
; in AGACB_BPLCON3D (Default) before your effect terminates to enshure
; that subsequent effects run properly.

AGACB_SIZEOF	rs.w	0

; ===================================================================
;
;  AGA color structures
;
; ===================================================================

; AGAColors-structure
; $00rrggbb ... 256 times
; each longword one color.

AGAColSIZE	equ	256*4		; Size of register set


AGACopSIZE	equ	(256+8)*2*4	; Size of Copperlist for

AGACop32SIZE	equ	(32+1)*2*4	; Size of Copperlist for
					; setting Colors
AGAFadeSIZE	equ	256*16		; Buffer for fade-routine

; ===================================================================
;
;  AGA ugrade macros
;
; ===================================================================

******* AGAC.library/AGABEGIN **********************************************
*
*   NAME
*	AGABEGIN -- Begin AGA adeption
*
*   SYNOPSIS
*	AGABEGIN    (MACRO)
*
*   FUNCTION
*	AGABEBIN, AGAEND and AGAMODIFY should be used to 
*	automatically adept an OCS/ECS copperlist for advanced AGA
*	fetchmodes.
*
*	Example:
*
*	      AGABEGIN
*	      AGAMODIFY  Cop094,#$d8-$20
*	      AGAMODIFY  Cop1fc,#$3
*	      AGAEND
*
*	The AGABEGIN checks if AGA is enabled. If it is not, it skips to
*	AGAEND. It it is, all commands between AGABEGIN and AGAEND are
*	executed.
*	The above example would upgrade a standard copperlist.
*	Special commands for easiert update of important registers are
*	available.
*	Since AGABEGIN and AGAEND use local labels, you must not use
*	global labels inside the block, and you must set at least
*	one global label between two blocks.
*
*   BUGS
*
*   SEE ALSO
*	AGABEGIN, AGAEND, AGAMODIFY.
*
****************************************************************************

******* AGAC.library/AGAEND ************************************************
*
*   NAME
*	AGAEND -- End AGA adeption block
*
*   SYNOPSIS
*	AGAEND   (MACRO)
*
*   FUNCTION
*	Marks the end of an AGA adeption block
*
*   EXAMPLE
*	see AGABEGIN
*
*   BUGS
*
*   SEE ALSO
*	AGABEGIN, AGAEND, AGAMODIFY.
*
****************************************************************************

******* AGAC.library/AGAMODIFY *********************************************
*
*   NAME
*	AGAMODIFY -- Modify register in copperlist
*
*   SYNOPSIS
*	AGAMODIFY Label,#Value    (MACRO)
*
*   FUNCTION
*	The Label will be interpreted as the label before a copperlist
*	instruction. The Value will be copied in the value-field of
*	the copperlist-instruction, i.e. Label+2.
*
*   INPUTS
*	Label  - Label of the copperlist-instruction
*	Value  - Value to copy, including # for immediate values.
*
*   EXAMPLE
*	see AGABEGIN
*
*   BUGS
*
*   SEE ALSO
*	AGABEGIN, AGAEND, AGAMODIFY.
*
****************************************************************************

******* AGAC.library/AGAMODIFY *********************************************
*
*   NAME
*	AGAMODIFY -- Modify register in copperlist
*
*   SYNOPSIS
*	AGAMODIFY Label,#Value    (MACRO)
*
*   FUNCTION
*	The Label will be interpreted as the label before a copperlist
*	instruction. The Value will be copied in the value-field of
*	the copperlist-instruction, i.e. Label+2.
*
*   INPUTS
*	Label  - Label of the copperlist-instruction
*	Value  - Value to copy, including # for immediate values.
*
*   EXAMPLE
*	see AGABEGIN
*
*   BUGS
*
*   SEE ALSO
*	AGABEGIN, AGAEND, AGAMODIFY.
*
****************************************************************************

******* AGAC.library/AGAFETCH **********************************************
*
*   NAME
*	AGAFETCH -- Modify fetchmode-register
*
*   SYNOPSIS
*	AGAFETCH Label   (MACRO)
*
*   FUNCTION
*	This macro will set the maximum fetchmode
*
*   INPUTS
*	Label  - Label of the copperlist-instruction for Fetchmode
*
*   EXAMPLE
*	see AGADDFSTOP
*
*   BUGS
*
*   SEE ALSO
*	AGABEGIN, AGAEND, AGAMODIFY.
*
****************************************************************************

******* AGAC.library/AGADDFSTOP ********************************************
*
*   NAME
*	AGADDFSTOP -- Modify ddfstop-register
*
*   SYNOPSIS
*	AGADDFSTOP Label,#Value   (MACRO)
*
*   FUNCTION
*	This macro will subtract the value from the copperlist-instruction
*	This is usefull for the DDFSTOP-Register, since you usually 
*	must subtract $20 from it when switching on the Fetchmode.
*
*   INPUTS
*	Label  - Label of the copperlist-instruction for Fetchmode
*	Value  - Value to subtract, including # for immediate values.
*
*   EXAMPLE
*	a slightly shorter version of the example in AGABEGIN
*	
*	      AGABEGIN
*	      AGAFETCH   Cop1fc
*	      AGADDFSTOP Cop094,#$20
*	      AGAEND
*
*   BUGS
*
*   SEE ALSO
*	AGABEGIN, AGAEND, AGAMODIFY.
*
****************************************************************************

AGABEGIN	MACRO
		jsr	_GetPISS(a6)
		cmp.b	#3,PISS_Level(a0)
		bne	.agabegin_noaga
		ENDM

AGAEND		MACRO
.agabegin_noaga:
		ENDM

AGAMODIFY	MACRO
		move.w	\2,2+\1
		ENDM

AGAFETCH	MACRO
		move.w	#3,2+\1
		ENDM

AGADDFSTOP	MACRO
		sub.w	\2,2+\1
		ENDM


******* AGAC.library/AGAEND ************************************************
*
*   NAME
*	AGAEND -- End AGA adeption block
*
*   SYNOPSIS
*	AGAEND   (MACRO)
*
*   FUNCTION
*	Marks the end of an AGA adeption block
*
*   EXAMPLE
*	see AGABEGIN
*
*   BUGS
*
*   SEE ALSO
*	AGABEGIN, AGAEND, AGAMODIFY.
*
****************************************************************************

******* AGAC.library/AGAOFF ************************************************
*
*   NAME
*	AGAOFF -- Disable AGA Chipset
*
*   SYNOPSIS
*	AGAOFF
*
*   FUNCTION
*	Change the PISS so that no AGA has been recognised
*	This macro has "HACK"-Status and is debug only!
*
****************************************************************************

AGAOFF		MACRO
		jsr	_GetPISS(a6)
		move.b	#0,PISS_Level(a0)
		ENDM
