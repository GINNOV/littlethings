*****************************************
*      SCREEN TYPER V3.0 BY P.KENT      *
*          LAST MOD 5.4.92              *
*NB. XPOS IS OFFSET FOR RIGHT CENTRED!  *
*                                       *
*MOD FOR TANKS: P.DRAWPL NOT #SCREEN    *
* CREDIT TO DEAN ASHTON FOR SOME SOURCE *
*                                       *
*      TEXTHANDLING ROUTINES FOR        *
*     VARIOUS SIZED SCREENS/FONTS       *
*****************************************

*****************************************************
* DOTXTSTRUCT :- Processes linked list of structs   *
*				 A0.L ---> Address of 1st struct    *
*                A2.L ---> Screen ptr               *
*****************************************************

DOTXTSTRUCT
	PUSH	A0-A2/D1-D4
DTSLP
	MOVE.L	TXT_NEXT(A0),-(A7)		; Next struct
	MOVE.W	TXT_JUST(A0),D3
	CMP.W	#'L',D3					; Left just uses x,y...
	BEQ.S	DTS_LJ

;CENTRE/RIGHT CODE HERE!
	MOVE.W	TXT_Y(A0),D2			; Pixel y posn
	MOVE.W	TXT_X(A0),D4
	MOVE.L	TXT_FNT(A0),A1			; Get font struct
	MOVE.l	TXT_PTR(A0),A0			; Get txt ptr

									; Find str length...
	BSR	STR_LEN						; Length in d0

	MULU	FONT_W(A1),D0			; Get message byte graphic length						
	MOVE.L	#PLWIDB,D1
	
	SUB.W	D0,D1					; Right justify it...

	CMP.W	#'R',D3
	BEQ.S	DTS_RJ
	
	LSR.W	#1,D1					; Halve x posn for centred text
	BRA.S	DTS_JOK
DTS_RJ
	ADD.W	D4,D1					; Offset for right centred text
	BRA.S	DTS_JOK	
DTS_LJ	
	MOVE.W	TXT_X(A0),D1			; Byte x posn
	MOVE.W	TXT_Y(A0),D2			; Pixel y posn
	MOVE.L	TXT_FNT(A0),A1			; Get font struct
	MOVE.l	TXT_PTR(A0),A0			; Get txt ptr

DTS_JOK
	BSR.S	PRINTLINE
	MOVE.L	(A7)+,A0
	CMP.L	#0,A0
	BNE.S	DTSLP
	POP	A0-A2/D1-D4
	RTS

*****************************************************
* PRINTLINE :- Prints text string at position X,Y   *
*              A0.L ---> Address of message text    *
*			   A1.L ---> Font Structure             *
*              A2.L ---> Screen ptr                 *		
*              D1.B	---> X position (in characters) *
*              D2.B	---> Y position (in lines)      *
*****************************************************

PRINTLINE
	PUSH	D0-D1/A0				; Stack registers
	MOVEQ	#0,D0					; Make sure D0 is clear
PLLOOP	MOVE.B	(A0)+,D0			; Get next character
	BEQ.S	PLINEEXIT				; End of string ?
	BSR.S	PRINTCHAR				; Print the character
	ADD.W	FONT_W(A1),D1			; Next X position
	BRA.S	PLLOOP					; Back for next one!
PLINEEXIT
	POP		D0-D1/A0				; Retrieve registers
	RTS								; Return to caller
	
***************************************************
* PRINTCHAR :- Prints a character at position X,Y *
* Parameters:- Character Code (ASCII code!)    D0 *
*	     X coordinate (in 8 pixel steps) 	   D1 *
*	     Y coordinate (in 1 pixel steps)       D2 *
*		 Font Structure						   A1 *
*        Screen ptr                            A2 *
***************************************************

PRINTCHAR
	PUSH	D0-D4/A0-A4				; Stack registers
	MOVE.L	A2,A0					; Retrieve screen address
	MOVE.L	#PLWIDB*NPL,D4			; D4 holds line length
	MOVE.L	D4,D3					; We don't want to scrap D4 yet!
	MULU.W	D2,D3 					; D3 now points to correct scanline
	ADD.L	D1,D3					; D3 now points to correct offset
	LEA	(A0,D3.L),A0				; A3 now has the actual screen addr.
	
	MOVE.L	FONT_PTR(A1),A3			; Get font...

	SUB.W	#32,D0					; First character is 'Space'

	MULU	FONT_W(A1),D0			; Multiply by chr length
	MULU	FONT_HGT(A1),D0
	MULU	FONT_NPL(A1),D0
	LEA	(A3,D0.W),A3				; A3 points to correct place in font
	MOVE.W	FONT_W(A1),D1			; Width
	MOVE.W	FONT_NPL(A1),D3			; No of planes
	SUBQ.W	#1,D3					; For dbra...

PRTCHARPLLP							; Planes lp
	MOVE.L  A0,A4					; A4 is font work ptr
	MOVE.W	FONT_HGT(A1),D0			; Font Hgt times
	SUBQ.W	#1,D0					; For dbra...

PRTCHARLNLP							; Line lp
	MOVEQ	#0,D2
PRTCHARWLP							; Line WIDTH lp
	MOVE.B  (A3)+,(A4,D2)			; Move line into screen memory
	ADDQ.W	#1,D2
	CMP.W	D1,D2					; Done width ?
	BNE.S	PRTCHARWLP				; Else loop doing width
	ADD.L	D4,A4					; Add line length from above
	DBRA	D0,PRTCHARLNLP			; Loop back for next screen line

	LEA	PLWIDB(A0),A0				; Next modulo'd plane...	
	DBRA	D3,PRTCHARPLLP			; Loop doing plane
	POP		D0-D4/A0-A4				; Restore registers
	RTS
	
; This subroutine calculates the length of a 0 terminated string of chars
; Entry :  a0 must hold the address of the string
; Exit  :  d0 holds the length of the string
;          a0 saved

str_len
		move.l	a0,-(a7)
		moveq.l	#-1,d0		initialise counter
.loop
		addq.l	#1,d0		bump counter
		tst.b	(a0)+		end of string ?
		bne.s	.loop		if not loop back
		move.l	(a7)+,a0
		rts					all done so return


******************************
* TEXT/FONT STRUCTS FOR V3.0 *
******************************
	RSRESET
TXT_NEXT	RS.L	1	; Next text!
TXT_X		RS.W	1	; X Pos
TXT_Y		RS.W	1	; Y Pos
TXT_JUST	RS.W	1	; Justification -LRC-
TXT_FNT	RS.L	1 		; Font struct ptr
TXT_PTR		RS.L	1	; Ptr to text, 0 terminated.

_TEXT	MACRO
	dc.l	\1			; Ptr to next
	dc.w	\2,\3,\4	; X pos bytes,Y pixels,Just (LRC)
	dc.l	\5			; Font struct
	dc.l	_TEXT\@		; ASCII ptr
	
_TEXT\@	dc.b	\6,0	; Null terminated text
	even
	ENDM

***********************
*   FONT STRUCTURES   *
***********************

	RSRESET
FONT_W		RS.W	1	; Font width,bytes
FONT_HGT	RS.W	1	; Font height, pixels
FONT_NPL	RS.W	1	; No of planes
FONT_PTR	RS.L	1	; Ptr to raw font

_FONT	MACRO			; Name,bwid,pix height,pl,filename
\1	dc.w	\2,\3,\4
	dc.l	_FONT\@
_FONT\@	incbin	\5
	even
	ENDM

