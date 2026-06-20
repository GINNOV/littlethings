	IFND LIBRARIES_GHOSTRIDER_I
LIBRARIES_GHOSTRIDER_I SET 1
**
**	$VER: ghostrider.i 37.1 (29.04.94)
**
**	ghostrider.library constants
**
**	(C) Copyright 1994 Jesper Skov
**	    All Rights Reserved
**

* Make sure that GhostRider was loaded with the DeckRunner before calling
* functions in the library or you will get the gr_grnotfound error.

	IFND EXEC_TYPES_I
	INCLUDE 'exec/types.i'
	ENDC


******* Entry Types *********************************************************

	BITDEF	GRET,mbutton,0		; Middle mouse button.
	BITDEF	GRET,rbutton,1		; Right mouse button.
	BITDEF	GRET,lbutton,2		; Left mouse button.

; The three mouse button bits function as a qualifier mask,
; but may not be mixed with the RAWKEY entry type.

	BITDEF	GRET,rawkey,3		; Entry by RAWKEY event.

; The key code and qualifier bits match the definitions of the keyboard
; device. The RAWKEY entry type may not be mixed with the mouse button
; entry types.


******* Library Error Codes *************************************************

gr_ok		EQU	0		; Function succesful.
gr_grnotfound 	EQU	-2		; GhostRider was not found in memory.

;---- Codes returned by _LVOGRSetBreakPoint
gr_sbp_fail	EQU	-1		; Address could not be accessed.
gr_sbp_full	EQU	1		; Breakpoint table is full.
gr_sbp_isset	EQU	2		; Address already have a breakpoint.

;---- Codes returned by _LVOGRClrBreakPoint
gr_cbp_notset	EQU	-1		; Address does not have a breakpoint.


******* Library Name ********************************************************

GHOSTRIDERNAME	MACRO
		dc.b "ghostrider.library",0
		ENDM


	ENDC	; LIBRARIES_GHOSTRIDER_I
