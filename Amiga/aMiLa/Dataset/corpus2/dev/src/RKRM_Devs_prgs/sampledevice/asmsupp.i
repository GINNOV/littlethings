*************************************************************************
*
*	Copyright (C) 1985, Commodore Amiga Inc.  All rights reserved.
*	Permission granted for non-commercial use
*
* asmsupp.i -- random low level assembly support routines
*	       used by the Commodore sample Library & Device
*
*************************************************************************
CLEAR	MACRO		;quick way to clear a D register on 68000
	MOVEQ	#0,\1
	ENDM

;BHS	 MACRO
;	 BCC.\0  \1 ;\0 is the extension used on the macro (such as ".s")
;	 ENDM
;BLO	 MACRO
;	 BCS.\0  \1
;	 ENDM
;EVEN	 MACRO		 ; word align code stream
;	 DS.W	 0
;	 ENDM

LINKSYS MACRO		; link to a library without having to see a _LVO
	MOVE.L	A6,-(SP)
	MOVE.L	\2,A6
	JSR	_LVO\1(A6)
	MOVE.L	(SP)+,A6
	ENDM

CALLSYS MACRO		; call a library via A6 without having to see _LVO
	JSR	_LVO\1(A6)
	ENDM

XLIB	MACRO		; define a library reference without the _LVO
	XREF	_LVO\1
	ENDM
;
; Put a message to the serial port at 9600 baud.  Used as so:
;
;     PUTMSG   30,<'%s/Init: called'>
;
; Parameters can be printed out by pushing them on the stack and
; adding the appropriate C printf-style % formatting commands.
;
		XREF	KPutFmt
PUTMSG: 	MACRO	* level,msg

		IFGE	INFO_LEVEL-\1

		PEA	subSysName(PC)
		MOVEM.L A0/A1/D0/D1,-(SP)
		LEA	msg\@(pc),A0    ;Point to static format string
		LEA	4*4(SP),A1      ;Point to args
		JSR	KPutFmt
		MOVEM.L (SP)+,D0/D1/A0/A1
		ADDQ.L	#4,SP
		BRA.S	end\@

msg\@		DC.B	\2
		DC.B	10
		DC.B	0
		DS.W	0
end\@
		ENDC
		ENDM
