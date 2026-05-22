;	OPT C-,O+,D+,L-,W+
;	SECTION YO,CODE_C
;
;	LEA TESTMSG,A0
;	JSR HANDLETEXT
;	RTS
;TESTMSG
;	DC.B	'\s0\f0\K\mc'
;	DC.B	'\X0\Y100\jc\c1\tHow about this folks!!!'
;	DC.B	'\y10\X32\jl\c2\tI mean like...\u\y10\c4\t...colours & space!'
;	DC.B	'\Y200\jc\c31\tWritten in 1992 by P.Kent for ACC!!!'
;	DC.B	'\jc\X0\Y0\c7\f1\tTESTING COLOUR FONTS'
;	DC.B	'\y18\c15\tSTILL TESTING 1!'
;	DC.B	'\y18\c23\tSTILL TESTING 2!'
;	DC.B	'\y18\c31\tSTILL TESTING 3!'
;	DC.B	'\q'
;	EVEN
;
;LP.SCREENS DC.L SCREEN0-LP.SCREENS,0
;SCREEN0								; 5 bit plane PAL screen
;	DC.L	'SCN0'
;	DC.W 40,5,40*5,256
;	LEA TMPSCRN,A3
;	RTS
;
;LP.FONTS DC.L FONT0-LP.FONTS,CFONT-LP.FONTS,0
;FONT0	DC.L 'FNT0'
;		DC.W	1,8,1,8
;		INCBIN 	GFX/METALLION10.8
;		EVEN
;CFONT	DC.L 'FNT0'
;		DC.W	2,16,3,3*2*16
;		INCBIN	GFX/GREYFONT.16*16*3.BLOCK
;		EVEN
;TMPSCRN DS.B 40*256*5
;
;
;	SECTION CODERAMA,CODE
*****************************************
*      TEXT HANDLER V4.0 BY P.KENT      *
*      BASED ON SCREENTYPER V3.0 :      *
* REWRITTEN : SCREENS/FONTS/EASY 2 USE! *
*         SOME ERROR TRAPPING!          *
*   NB: PIXEL POSNs ROUNDED TO BYTES!   *
*CAN BE UPGRADED TO PROPORTIONAL IF REQD*
*****************************************
* SUPPORTED EMBEDDED CODES: >>>NB Case sensitive<<<
* (n = decimal no.)
* \q & \0   Ends text processing.
* \Xn & \Yn Set x,y text position.
* \xn & \yn Adjust x,y position by n amount.
* \taaaaaa  Prints text in current font/colour to 
*           current 'screen'. Upto next '\'
* \fn       Select font no.     \
* \cn       Select colour no.    |- As per global lp.screens/fonts etc.
* \sn       Select screen no.   /
* \jl \jr \jc Set justification : left    : use x pos
*                                 right   : use right hand edge
*                                 centred : centre text on screen
* \u        Update coords use after text if reqd...
* \K        Clear screen - every plane
* \Kn       Clear screen bitplanes colour n
*
* \mo       Select 'or' mode
* \mc       Select 'cookie' mode
* \mw       Select 'wipe' mode
*
*****************************************
THERROR
;A0 IS INVARAIABLY PTR TO TEXT... PRINT 9 BYTES....
	LEA TH.ERR.TXT2(PC),A1
	SUBQ.L	#4,A0
	MOVEQ	#8,D1
THERROR.LP
	MOVE.B (A0)+,D0
	CMP.B #' ',D0
	BCC.S THERROR.OK
	MOVE.B #'*',D0
THERROR.OK
	MOVE.B D0,(A1)+
	DBRA	D1,THERROR.LP
	LEA TH.ERR.TXT(PC),A0
	BRA _ERROR
TH.ERR.TXT	dc.b	'TEXT HANDLER FATAL ERROR : Incorrect formatting!!',$A
			dc.b	'>'
TH.ERR.TXT2 dc.b	'+++++++++<',$A,'^',0
	EVEN

*****
* HANDLETEXT( A0 )( TEXT )
* Print text using embedded control strings...
*****
HandleText
	MOVEM.L D0-D7/A0-A6,-(A7)
	LEA THVARS(PC),A6
HandleText_Repeat
;Check first letter is '\'
	CMP.B #'\',(A0)
	BNE.S THERROR
;Get control value, process using offset table
	MOVEQ #0,D0
	MOVE.B 1(A0),D0
	LEA ScanTable(PC),A1
	MOVE.L A1,-(A7)					; Save table address
HT_Scanlp
	TST.W (A1)
	BEQ.S THERROR						; Must never reach end of table!
	CMP.W (A1),D0
	BEQ.S HT_ScanOK
	ADDQ.L #4,A1
	BRA.S HT_Scanlp
HT_ScanOK

	MOVE.W 2(A1),D0					; Get offset from table...
	MOVE.L (SP)+,A1
	LEA (A1,D0.W),A1
	JMP (A1)
ScanTable							; List of control values!
									;cmp,offset routine
									; called A0 = '\!aaaa'
	DC.W 'q',T_Quit-ScanTable
	DC.W '0',T_Quit-ScanTable
	DC.W 'X',T_SetX-ScanTable
	DC.W 'Y',T_SetY-ScanTable
	DC.W 's',T_SetScreen-ScanTable
	DC.W 'f',T_SetFont-ScanTable
	DC.W 'c',T_SetColour-ScanTable
	DC.W 'j',T_SetJust-ScanTable
	DC.W 'x',T_AddX-ScanTable
	DC.W 'y',T_Addy-ScanTable
	DC.W 'u',T_Update-ScanTable
	DC.W 't',T_Text-ScanTable
	DC.W 'K',T_Clear-ScanTable
	DC.W 'm',T_Mode-ScanTable
	DC.W 0

T_Quit								; Quit, recovering saved values
	MOVEM.L (A7)+,D0-D7/A0-A6
	RTS	

;Set x,y absolute values...
T_SetX
	ADDQ.L #2,A0
	BSR GrabDecimal
	MOVE.W D0,W.Xpos(A6)
	BRA.S HandleText_repeat
T_SetY
	ADDQ.L #2,A0
	BSR GrabDecimal
	MOVE.W D0,W.Ypos(A6)
	BRA HandleText_repeat
;Set current screen
T_SetScreen
	ADDQ.L #2,A0
	BSR GrabDecimal
	LSL.L #2,D0
	LEA LP.SCREENS,A1
	ADD.L (A1,D0.L),A1
	CMP.L #'SCN0',(A1)
	BNE THERROR
	MOVE.L A1,P.Screen(A6)
	BRA HandleText_repeat

;Set current font
T_SetFont
	ADDQ.L #2,A0
	BSR GrabDecimal
	LSL.L #2,D0
	LEA LP.FONTS,A1
	ADD.L (A1,D0.L),A1
	CMP.L #'FNT0',(A1)
	BNE THERROR

;Can now support colour fonts!
;	CMP.W #1,FNT_NPL(A1)
;	BNE THERROR

	MOVE.L A1,P.Font(A6)
	BRA HandleText_repeat
;Get colour for font
T_SetColour
	ADDQ.L #2,A0
	BSR GrabDecimal
	MOVE.B D0,B.Colour(A6)
	BRA HandleText_Repeat
;Get justification type
T_SetJust
	MOVEQ #0,D0
	MOVE.B 2(A0),D0
	ADDQ.L #3,A0
	CMP.B #'l',D0
	BEQ.S TSJ_Valid
	CMP.B #'r',D0
	BEQ.S TSJ_Valid
	CMP.B #'c',D0
	BEQ.S TSJ_Valid
	BRA THERROR
TSJ_Valid
	MOVE.B D0,B.JUST(A6)
	BRA HandleText_Repeat

;Set x,y delta values...
T_AddX
	ADDQ.L #2,A0
	CMP.B #'-',(A0)					; -ve number ?
	BEQ.S TAX_Minus
	BSR GrabDecimal
TAX_Cont
	ADD.W D0,W.Xpos(A6)
	BRA HandleText_repeat
TAX_Minus
	ADDQ.L #1,A0
	BSR GrabDecimal
	NEG.W D0
	BRA.S TAX_Cont
T_AddY
	ADDQ.L #2,A0
	CMP.B #'-',(A0)					; -ve number ?
	BEQ.S TAY_Minus
	BSR GrabDecimal
TAY_Cont
	ADD.W D0,W.Ypos(A6)
	BRA HandleText_repeat
TAY_Minus
	ADDQ.L #1,A0
	BSR GrabDecimal
	NEG.W D0
	BRA.S TAY_Cont

T_Update
	ADDQ.L #2,A0
	MOVE.W W.LastX(A6),W.XPos(A6)
	MOVE.W W.LastY(A6),W.YPos(A6)
	BRA HandleText_repeat

T_Clear								; Clear screen
	ADDQ.L #2,A0
	CMP.B #'\',(A0)					; Any colours specified ?
	BNE.s T_ClearSpec
	MOVE.L P.Screen(A6),A1
	MOVE.W SCN_HGT(A1),D0
	SUBQ.W #1,D0
	MOVE.W SCN_STEP(A1),D1
	SUBQ.W #1,D1
	JSR SCN_GETPTR(A1)				; Now a3 = screen
T_Clearlp1	MOVE.W D1,D2
T_Clearlp2  CLR.B (A3)+
	DBRA D2,T_Clearlp2
	DBRA D0,T_Clearlp1
	BRA HandleText_Repeat

T_ClearSpec
	BSR GrabDecimal
	MOVE.L P.Screen(A6),A1
	JSR SCN_GETPTR(A1)				; Get a3 = screen
	MOVE.W SCN_HGT(A1),D1
	SUBQ.W #1,D1
	MOVE.W SCN_BWID(A1),D2
	MOVE.W SCN_STEP(A1),D3
	SUB.W  D2,D3					; Now d3 = plane offsets
	SUBQ.W #1,D2
T_CPLlp
	MOVE.L A3,A4					; Save ptr
	BTST #0,D0						; CLear plane ?
	BEQ.S   T_Cpl
	MOVE.W D1,D4
T_Nplhlp
	MOVE.W D2,D5
T_Nplwlp
	CLR.B (A4)+						; Clear it...
	DBRA D5,T_Nplwlp
	LEA (A4,D3.W),A4
	DBRA D4,T_Nplhlp
T_Cpl
	LEA (A3,D2.W),A3
	LSR.W #1,D0						; Rotate colour
	TST D0							; Any planes left?
	BNE.S T_Cpllp
	BRA HandleText_Repeat

T_Mode								; Select mode to put text down
	CMP.B #'o',2(A0)
	BNE.S T_MNor
	MOVE.B #OR_MODE,B.Mode(A6)		; Bytes ORed onto screen
T_ModeCont
	ADDQ.L #3,A0
	BRA HandleText_Repeat
T_MNor
	CMP.B #'w',2(A0)
	BNE.S T_MNwipe
	MOVE.B #WIPE_MODE,B.Mode(A6)	; Bytes MOVEd onto screen
	BRA.S T_ModeCont
T_MNWipe
	CMP.B #'c',2(A0)
	BNE THERROR
	MOVE.B #COOKIE_MODE,B.Mode(A6)	; Bytes COOKIEd onto screen
	BRA.S T_ModeCont

T_Text	 							; Print text from 2(a0) to 1(a0)='\'
	ADDQ.L #2,A0
	CMP.B #'\',(A0)
	BEQ HandleText_repeat
;Look at mode of text justifaction...
;-calc x start based on string (->byte width) of string
	CMP.B	#'l',B.Just(A6)
	BNE.s TT_NotJL
	MOVE.W W.XPos(A6),D0			; If left ,just use coords
	MOVE.W W.YPos(A6),D1			;
	BRA.S TT_DoneJ
TT_NotJL
	CMP.B   #'r',B.Just(A6)
	BNE.S TT_NotJR
	BSR TTStrLen					; Get string length in d0
	MOVE.L P.Font(A6),a1
	MULU FNT_BWID(A1),D0			; Length in bytes
	NEG.W D0
	MOVE.L P.Screen(A6),A1
	ADD.W SCN_BWID(A1),D0			; Get rh of screen - length bytes = xbpos
	LSL.W #3,D0						; *8 to get pixel posn
	MOVE.W W.YPOS(A6),D1
	BRA.S TT_DoneJ
TT_NotJR
	cmp.b #'c',B.JUST(A6)
	bne THERROR
	BSR TTStrLen					; Get length
	MOVE.L	P.Font(A6),a1
	MULU FNT_BWID(A1),D0			; Byte width
	NEG.W D0
	MOVE.L P.Screen(A6),a1
	ADD.W SCN_BWID(a1),D0
	LSL.W #3-1,D0					; *8/2 to get centre pixel pos
	MOVE.W W.YPos(A6),D1			; Get Y
TT_DoneJ
;now d0/d1 = x,y pixel position for message
	MOVE.L P.Screen(A6),a1
	MOVE.L P.Font(A6),a2
	MOVE.W FNT_BWID(A2),D3
	LSL.W  #3,D3					; PIXEL WIDTH
;print chars until "\"
TT_Strlp
	CMP.B #'\',(A0)
	BEQ.S TT_StrFin
	MOVE.B (A0)+,D2
	BSR.S PutChar
	ADD.W D3,D0
	BRA.S TT_Strlp
TT_StrFin
;save coords then bra handletext_repeat
	MOVE.W D0,W.LASTX(A6)
	MOVE.W D1,W.LASTY(A6)
	BRA HandleText_Repeat

*****
* PutChar (A1 A2 D0 D1 D2) (SCREEN FONT XPOS YPOS CHAR)
* Places character on screen at x,y pixel pos etc...
* NB only byte accurate - but could be upgraded.... x,y are in *PIXELS*
*****
PutChar
	MOVEM.L	A3-A5/D0-D7,-(A7)
	JSR SCN_GETPTR(A1)				; Get a3 = bitmap for screen
;Calc bitmap posn based on screen + x/y
	MULU	SCN_STEP(A1),D1			; Offset...
	ADD.L	D1,A3
	ASR.L	#3,D0					; Only byte accurate at the moment
	ADD.L	D0,A3					; A3 Now TLC of bitmap
	SUB.B	#' ',D2					; De-ascii
	AND.W   #$FF,D2
	MULU	FNT_STEP(A2),D2
	LEA	FNT_RAW(A2,D2.L),A4
;NOW A3=BITMAP POSN
;    A4=RAW POSN

	CMP.W #1,FNT_NPL(A2)
	BNE PC_DoMask					; If its coloured - build mask

;All DREGS free...
	MOVE.B	B.COLOUR(A6),D6
	MOVE.W	SCN_NPL(A1),D7			; No of planes
	SUBQ.W #1,D7
PC_pllp
	MOVEM.L A3/A4,-(A7)				; Save bitmap posn

	MOVE.W FNT_HGT(A2),D1
	SUBQ.W	#1,D1
PC_hlp
	MOVE.L A3,-(A7)
	MOVE.W FNT_BWID(A2),D0
	SUBQ.W #1,D0
PC_wlp
;Put down width of chr according to mode...

	CMP.B #WIPE_MODE,B.Mode(A6)
	BNE.S PC_NWipeM
	BTST #0,D6						; In `WIPE` mode just splat chr onto scrn
	BNE.S PC_Setpllp1
PC_Clrlp1
	CLR.B  (A3)+
;	ADDQ.L #1,A4
	DBRA D0,PC_Clrlp1
	BRA.S PC_PutDone
PC_Setpllp1
	MOVE.B (A4)+,(A3)+
	DBRA D0,PC_Setpllp1
	BRA.S PC_PutDone
PC_NWipeM

	CMP.B #OR_MODE,B.Mode(A6)		; In `OR` mode ?
	BNE.S PC_NOrM
	BTST #0,D6
	BNE.S PC_Setpllp2
;PC_Clrlp2
;	ADDQ.L #1,A3
;	ADDQ.L #1,A4
;	DBRA D0,PC_Clrlp2
	BRA.S PC_PutDone
PC_Setpllp2
	MOVE.B (A4)+,D5
	OR.B	D5,(A3)+
	DBRA D0,PC_Setpllp2
	BRA.S PC_PutDone
PC_NOrM

	CMP.B #COOKIE_MODE,B.Mode(A6)	; In `COOKIE` mode ?
	BNE THERROR
	BTST #0,D6
	BNE.S PC_Setpllp3
PC_Clrlp3
	MOVE.B (A4)+,D5					; If plane not set,delete chr under
	NOT.B D5
	AND.B D5,(A3)+
	DBRA D0,PC_Clrlp3
	BRA.S PC_PutDone
PC_Setpllp3
	MOVE.B (A4)+,D5					; Or on new chr plane..
	OR.B	D5,(A3)+
	DBRA D0,PC_Setpllp3
;	BRA.S PC_PutDone


PC_Putdone
	MOVE.L (A7)+,A3
	ADD.W	SCN_STEP(A1),A3
	DBRA	D1,PC_hlp
	MOVEM.L (A7)+,A3/A4
	ADD.W SCN_BWID(A1),A3
	LSR.W #1,D6						; Next plane
	DBRA D7,PC_pllp

	MOVEM.L	(A7)+,A3-A5/D0-D7
	RTS

PC_DoMask
;Build up a mask for the font...
;A2 = font pointer
;A4 = pos in font...
	LEA Fontmask(a6),a5
	MOVE.L A4,-(A7)
	MOVE.W FNT_HGT(A2),D0
	MULU FNT_BWID(A2),D0
	SUBQ.W #1,D0					; Now d0 = no of bytes per plane
	MOVE.W FNT_NPL(A2),D1
	SUBQ.W #1,D1					; For DBRA
	MOVEQ #1,D2						; First time round must replace contents!
PC_BMlp
	MOVE.L A5,-(A7)
	MOVE.W D0,D3
	TST.W D2						; First time ?
	BEQ.S PC_BMORLP
PC_BMMVLP	MOVE.B (A4)+,(A5)+
	DBRA D3,PC_BMMVLP
	MOVEQ #0,D2
	BRA.S PC_BMlpc
PC_BMORLP
	MOVE.B (A4)+,D4
	OR.B D4,(A5)+
	DBRA D3,PC_BMORLP
PC_BMlpc
	MOVE.L (A7)+,A5
	DBRA D1,PC_BMlp
	MOVE.L (A7)+,A4

;Now a3=bitmap posn, a4=raw posn, a5=font mask	
;All DREGS free
;NB> This next lump of code is a tad scrappy! Needs tidying!

	MOVE.B	B.COLOUR(A6),D6
	MOVE.W	SCN_NPL(A1),D7			; No of planes
	SUBQ.W #1,D7
	MOVE.W  FNT_NPL(A2),D5			; No planes in font
CPC_pllp
	MOVEM.L A3/A5,-(A7)				; Save bitmap posn,mask

	MOVE.W FNT_HGT(A2),D1
	SUBQ.W	#1,D1
CPC_hlp
	MOVE.L A3,-(A7)
	MOVE.W FNT_BWID(A2),D0
	SUBQ.W #1,D0
CPC_wlp
;Put down width of chr according to mode...
;If font planes all used, put down mask according to colour
	CMP.B #WIPE_MODE,B.Mode(A6)
	BNE.S CPC_NWipeM
	TST.W	D5
	BNE.S CPC_Setpllp1				; If any font planes left, put down

	BTST #0,D6						; In `WIPE` mode just splat chr onto scrn
	BNE.S CPC_Setpllp1.2
CPC_Clrlp1
	CLR.B  (A3)+
	DBRA D0,CPC_Clrlp1
	BRA.S CPC_PutDone

CPC_Setpllp1.2	MOVE.B (A5)+,(A3)+	; If colour set, put down *mask*
	DBRA D0,CPC_Setpllp1.2
	BRA.S CPC_PutDone

CPC_Setpllp1
	MOVE.B (A4)+,(A3)+
	DBRA D0,CPC_Setpllp1
	BRA.S CPC_PutDone
CPC_NWipeM

	CMP.B #OR_MODE,B.Mode(A6)		; In `OR` mode ?
	BNE.S CPC_NOrM
	TST.W	D5						; Any planes left ? put down...
	BNE.S CPC_Setpllp2.1
	BTST #0,D6
	BNE.S CPC_Setpllp2
;CPC_Clrlp2
;	ADDQ.L #1,A3
;	ADDQ.L #1,A4
;	DBRA D0,CPC_Clrlp2
	BRA.S CPC_PutDone
CPC_Setpllp2.1
	MOVE.B (A4)+,D2
	OR.B	D2,(A3)+
	DBRA D0,CPC_Setpllp2.1
	BRA.S CPC_PutDone
CPC_Setpllp2
	MOVE.B (A5)+,D2
	OR.B	D2,(A3)+
	DBRA D0,CPC_Setpllp2
	BRA.S CPC_PutDone
CPC_NOrM

	CMP.B #COOKIE_MODE,B.Mode(A6)	; In `COOKIE` mode ?
	BNE THERROR
	TST.W	D5						; Any planes left ? put down...
	BNE.S CPC_Setpllp3.1
	BTST #0,D6
	BNE.S CPC_Setpllp3
CPC_Clrlp3
	MOVE.B (A5)+,D2					; If plane not set,delete chr under
	NOT.B D2
	AND.B D2,(A3)+
	DBRA D0,CPC_Clrlp3
	BRA.S CPC_PutDone
CPC_Setpllp3.1
	MOVE.B	(A5)+,D2				; Mask off underneath
	NOT.B	D2
	AND.B   D2,(A3)
	MOVE.B (A4)+,D2
	OR.B	D2,(A3)+
	DBRA D0,CPC_Setpllp3.1
	BRA.S CPC_PutDone
CPC_Setpllp3
	MOVE.B (A5)+,D2
	OR.B	D2,(A3)+
	DBRA D0,CPC_Setpllp3
;	BRA.S CPC_PutDone


CPC_Putdone
	MOVE.L (A7)+,A3
	ADD.W	SCN_STEP(A1),A3
	DBRA	D1,CPC_hlp
	MOVEM.L (A7)+,A3/A5
	ADD.W SCN_BWID(A1),A3
	LSR.W #1,D6						; Next plane
	TST.W D5
	BEQ.S CPC_FntX
	SUBQ.W #1,D5					; Another font plane done
CPC_FntX
	DBRA D7,CPC_pllp
	MOVEM.L	(A7)+,A3-A5/D0-D7
	RTS

*****
* D0 = TTStrLen (A0) (STRING)
* Returns length of my `\` terminated strings!
*****
TTStrLen
	MOVEM.L a0/a1,-(A7)
	move.l a0,a1
TTSLlp
	cmp.b #'\',(a1)+
	bne.s TTSLlp
	sub.l a0,a1
	move.l a1,d0
	subq.l #1,d0
	MOVEM.L (A7)+,a0/a1
	rts

*****
* D0 = TOLOWER ( D0 ) (ASCII VALUE)
* RETURNS: D0 = Lower case value
* CORRUPTS: No regs
* Converts ascii(A>Z) to lower case
*****
ToLower
	cmp.b #'A',d0
	bcs.s TL_fin
	cmp.b #'Z',d0
	bhi.s TL_fin
	add.b #'a'-'A',d0
TL_fin
	RTS

*****
* D0 = GRABDECIMAL( A0 ) ( DECIMAL ASCII)
* RETURNS: d0 = no. converted, a0 points to '\' at end of string
* CORRUPTS: No other regs
* Grab decimal no from a0 : terminated with a backslash '\'
*****
GrabDecimal
	MOVE.L D1,-(A7)
	MOVEQ #0,D0						; Count so far
GD_lp
	CMP.B #'\',(A0)					; End of string ?
	BEQ.S GD_lpfin

;Multiply d0 by ten...
	MOVE.L D0,D1
	ADD.L D0,D0
	ADD.L D0,D0						; d0 * 4
	ADD.L D1,D0						; d0 * 5
	ADD.L D0,D0						; d0 * 10

	MOVEQ #0,D1
	MOVE.B (A0)+,D1
	SUB.B #'0',D1
	ADD.L D1,D0
	BRA.S GD_lp
GD_lpfin
	MOVE.L (A7)+,D1
	RTS

*****
* TH_SAVEVARS()
* BACKUP ALL TEXT CONTROL VARS
*****
TH_SAVEVARS
	MOVEM.L A0/A1/D0,-(A7)
	LEA THVARS(PC),A0
	LEA THVARS_BAK(PC),A1
	MOVE.W #THVARS_LEN-FONTMASK_LEN-1,D0
THSV_lp
	MOVE.B (A0)+,(A1)+
	DBRA D0,THSV_lp
	MOVEM.L (A7)+,A0/A1/D0
	RTS

*****
* TH_RECOVARS()
* RECOVER ALL TEXT CONTROL VARS
*****
TH_RECOVARS
	MOVEM.L A0/A1/D0,-(A7)
	LEA THVARS_BAK(PC),A0
	LEA THVARS(PC),A1
	MOVE.W #THVARS_LEN-FONTMASK_LEN-1,D0
THRV_lp
	MOVE.B (A0)+,(A1)+
	DBRA D0,THRV_lp
	MOVEM.L (A7)+,A0/A1/D0
	RTS

			RSRESET
W.XPOS		RS.W 1					; Absolute x,y 'cursor' posns...
W.YPOS		RS.W 1
W.LASTX 	RS.W 1					; Last position for updates!
W.LASTY 	RS.W 1
B.JUST		RS.B 1					; Justification  'l'/'c'/'r'
B.COLOUR	RS.B 1					; Colour for font
B.MODE		RS.B 1					; Mode for putting text on screen
			RS.B 1
P.SCREEN	RS.L 1					; Ptr to screen
P.FONT		RS.L 1					; Ptr to font

FontMask 	rs.b 6*2*16				; Can Handle up to 16*16 6pl fonts
FontMask_len = 6*2*16				; Increase for larger fonts :-)

THVARS_LEN	RS.W 1
THVARS		DS.B THVARS_LEN
			EVEN
;Backup buffer to save options if reqd - handy for debugging etc.
THVARS_BAK  DS.B THVARS_LEN-FONTMASK_LEN
			EVEN

;MODES FOR PUTTING DOWN TEXT
			RSRESET
OR_MODE		RS.B 1
WIPE_MODE	RS.B 1
COOKIE_MODE RS.B 1

;OFFSETS FOR SCREENS
	RSRESET
SCN_ID		RS.L	1				; SCN0
SCN_BWID	RS.W	1
SCN_NPL		RS.W	1
SCN_STEP	RS.W	1				; NPL*BWID
SCN_HGT		RS.W	1
SCN_GETPTR	RS.W	1				; CODE RETURNS A3=SCREEN PTR

;OFFSETS FOR FONTS
	RSRESET
FNT_ID	 RS.L 1                     ; FNT0
FNT_BWID RS.W 1						; Byte width of font
FNT_HGT  RS.W 1						; Pixel height of font
FNT_NPL  RS.W 1						; No of planes in font
FNT_STEP RS.W 1						; npl*hgt*bwid : step between letters
FNT_RAW  RS.W 1						; Raw from here...

