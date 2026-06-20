	opt	o+,c-
;MENU CONTROL CODE FOR TANKS!!!
;
;
;SETS NUM PLAYERS ETC+
;control =  0 stick
;        =  1 Keys 1
;        = -1 Keys 2
;	ST	b.player0control(a5)		; Keys
;	SF	b.player1control(a5)		; Stick #1
;	SF	b.player2control(a5)		; Stick #2 (4player)
;	SF	b.player3control(a5)		; Stick #3 (4player)

Menu
	BSR	CLS
	BSR	WAITVBL
	BSR	SwapCop

	Lea	Menu.txt,a0
	MOve.l	p.showpl(a5),a2
;    add.l #plwidb*(npl-1),a2
	Bsr	DoTxtStruct					; Print menu
;
	bsr GimmeLogoShow
;
	BSR PrintP0ControlTxts
	BSR PrintP1ControlTxts
	BSR PrintP2ControlTxts
	BSR PrintP3ControlTxts

	move.l #lw.logocols,plw.cols(a5)
	MOVEQ	#2,D0							; Fast fade in
	BSR	FadeCols


	MOVE.L	p.showpl(a5),a2
;	add.l	#plwidb*(npl-1),a2
Menu_lp1
	Lea Keymap,a4
;CHECK F2-F4 : START GAME ETC...
	TST.B	$51(A4)
	BNE.S	Mn_Gotp2
	TST.B	$52(A4)
	BNE.S	Mn_Gotp3
	TST.b	$53(a4)
	bne.S	Mn_Gotp4
	TST.B	$01(A4)
	BNE.S	MN_Tg1
	TST.B	$02(A4)
	BNE	MN_Tg2
	TST.B	$03(A4)
	BNE	MN_Tg3
	TST.B	$04(A4)
	BNE	MN_Tg4
	TST.B	$13(A4)					; `R`
	BNE	MN_Redefine

	IFD	EDITOR
	TST.B	$12(A4)					; 'E'
	BNE	MN_Edit
	ENDC

	TST.B	$45(A4)					; ESC > QUIT PRG
	BNE.S	Mn_DOS	
	BRA.S	Menu_lp1

;Start a game, set number of players
Mn_Gotp2	Move.w	#1,w.numplayers(a5)
	BRA.S	Mn_Play
Mn_Gotp3	Move.w	#2,w.numplayers(a5)
	BRA.S	Mn_Play
Mn_Gotp4	Move.w	#3,w.numplayers(a5)
Mn_Play
	MOVEQ	#1,D0					; Start game!
	BRA.S	Mn_Quit
;Quit back to dos....
Mn_DOS	MOVEQ	#0,D0
Mn_Quit

	MOVE.L	D0,-(A7)
	MOVE.L	#lw.BlackCols,plw.COls(A5)	; Always fade to black!
	MOVEQ	#0,D0						; fast fade out!
	BSR	FadeCols
	BSR	SwapCop
	MOVE.L	(A7)+,D0					; recover return code...
	RTS

Mn_TG1
	TST.B	b.player0control(a5)		; 0>1>-1>0...
	BNE.S	2$
	move.b	#1,b.player0control(a5)
	BRA.S	3$
2$	cmp.b	#1,b.player0control(a5)
	BNE.S	4$
	move.b	#-1,b.player0control(a5)
	BRA.S	3$
4$	MOVE.B	#0,b.player0control(a5)
3$
	BSR PrintP0ControlTxts
1$	TST.B	$01(a4)
	bne.s	1$
	BRA menu_lp1

Mn_TG2
	TST.B	b.player1control(a5)		; 0>1>-1>0...
	BNE.S	2$
	move.b	#1,b.player1control(a5)
	BRA.S	3$
2$	cmp.b	#1,b.player1control(a5)
	BNE.S	4$
	move.b	#-1,b.player1control(a5)
	BRA.S	3$
4$	MOVE.B	#0,b.player1control(a5)
3$

	BSR PrintP1ControlTxts
1$	TST.B	$02(a4)
	bne.s	1$
	BRA menu_lp1
Mn_TG3
	TST.B	b.player2control(a5)		; 0>1>-1>0...
	BNE.S	2$
	move.b	#1,b.player2control(a5)
	BRA.S	3$
2$	cmp.b	#1,b.player2control(a5)
	BNE.S	4$
	move.b	#-1,b.player2control(a5)
	BRA.S	3$
4$	MOVE.B	#0,b.player2control(a5)
3$

	BSR PrintP2ControlTxts
1$	TST.B	$03(a4)
	bne.s	1$
	BRA menu_lp1
Mn_TG4
	TST.B	b.player3control(a5)		; 0>1>-1>0...
	BNE.S	2$
	move.b	#1,b.player3control(a5)
	BRA.S	3$
2$	cmp.b	#1,b.player3control(a5)
	BNE.S	4$
	move.b	#-1,b.player3control(a5)
	BRA.S	3$
4$	MOVE.B	#0,b.player3control(a5)
3$

	BSR.S PrintP3ControlTxts
1$	TST.B	$04(a4)
	bne.s	1$
	BRA menu_lp1

PrintP0ControlTxts						;PRINT player control type texts!
	LEA	P0J.TXT,A0
	MOVE.B	b.player0control(a5),D0
	BEQ.S	PPCT_0
	CMP.B	#1,D0
	BNE.S	PPCT_01
	LEA	P0K1.txt,a0
	BRA.S	PPCT_0
PPCT_01	LEA	P0K2.txt,a0
PPCT_0	BSR	DoTxtStruct
	RTS
PrintP1ControlTxts						;PRINT player control type texts!
	LEA	P1J.TXT,A0
	MOVE.B	b.player1control(a5),D0
	BEQ.S	PPCT_1
	CMP.B	#1,D0
	BNE.S	PPCT_11
	LEA	P1K1.txt,a0
	BRA.S	PPCT_1
PPCT_11	LEA	P1K2.txt,a0
PPCT_1	BSR	DoTxtStruct
	RTS
PrintP2ControlTxts						;PRINT player control type texts!
	LEA	P2J.TXT,A0
	MOVE.B	b.player2control(a5),D0
	BEQ.S	PPCT_2
	CMP.B	#1,D0
	BNE.S	PPCT_21
	LEA	P2K1.txt,a0
	BRA.S	PPCT_2
PPCT_21	LEA	P2K2.txt,a0
PPCT_2	BSR	DoTxtStruct
	RTS
PrintP3ControlTxts						;PRINT player control type texts!
	LEA	P3J.TXT,A0
	MOVE.B	b.player3control(a5),D0
	BEQ.S	PPCT_3
	CMP.B	#1,D0
	BNE.S	PPCT_31
	LEA	P3K1.txt,a0
	BRA.S	PPCT_3
PPCT_31	LEA	P3K2.txt,a0
PPCT_3	BSR	DoTxtStruct
	RTS

	IFD	EDITOR
MN_EDIT
	MOVE.L	#'EDIT',D0
	BRA	Mn_Quit
	ENDC

Mn_redefine
;REDEFINE PLAYERS KEYS!
	MOVE.L	#lw.blackcols,plw.cols(a5)
	MOVEQ	#1,D0
	BSR	FADECOLS
	BSR	CLS
	LEA	MNRED.TXT,A0
	MOVE.L	P.DRAWPL(A5),A2
;	add.l	#plwidb*(npl-1),a2
	BSR	DOTXTSTRUCT

;PRINT CURRENTKEYS!
	LEA	LL.KEYLIST,A4				; List of longwords: ypos,ptr
	LEA	ANY.TXT,A0
	MOVE.W	#'C',TXT_JUST(A0)		; Centred text
	MOVE.W	#0,TXT_X(A0)
PVERTLP
	MOVE.L	(A4)+,D0
	BEQ.S	PVERTFIN
	MOVE.W	D0,TXT_Y(A0)
	MOVE.L	(A4)+,A3				; Get ptr
	MOVEQ	#0,D0
	MOVE.B	(A3),D0					; Recover keyvalue,convert
	BSR	DECODE						; Return a1=string
	MOVE.L	A1,TXT_PTR(A0)
	BSR	DOTXTSTRUCT
	BRA.S	PVERTLP
PVERTFIN
	BSR GimmeLogoDraw
	BSR	SWAPCOP
	MOVE.L	#lw.logocols,PLW.COLS(A5)
	MOVEQ	#2,D0
	BSR	FADECOLS

	LEA	KEYMAP,A4
MNRD_SAFE	TST.B	$13(A4)					; WAIT FOR USER TO RELEASE KEY! (R)
	BNE.S	MNRD_SAFE

	LEA	LL.KEYLIST,A4
	LEA	QMARK.TXT,A3
	LEA	ANY.TXT,A0
	MOVE.W	#'R',TXT_JUST(A0)
	MOVE.W	#-10,TXT_X(A0)	;OFFSET!
	
MNRD_LPIT	
	MOVE.L	(A4)+,D0
	BEQ.S	MNRD_LPITFIN
	MOVE.W	D0,TXT_Y(A0)

	MOVE.B	#'?',(A3)		;PUT IN QMARK
	MOVE.L	A3,TXT_PTR(A0)	;PTR TO QMARK
	BSR.S	DOTXTSTRUCT			;PRINT QMARK
	CLR.B	B.ORDKEY
MNRD_WAIT
	TST.B	B.ORDKEY	;WAIT UNTIL KEY PRESSED
	BEQ.S	MNRD_WAIT
	MOVEQ	#0,D0
	MOVE.B	B.ORDKEY,D0
	MOVE.L	(A4)+,A1
	CMP.B	#$45,D0			;ESC? : USE LAST KEY!
	BNE.S	MNRD_NESC
	MOVE.B	(A1),D0			; REPLACE NEW KEY VALUE WITH OLD...
	BRA.S	MNRD_CONTOLD
MNRD_NESC
	MOVE.B	D0,(A1)			; PUT IN NEW KEY
MNRD_CONTOLD
	BSR	DECODE				; DECODE KEY
	MOVE.L	A1,TXT_PTR(A0)	; PUT IN PTR...
MNRD_SHOW
	BSR.S	DOTXTSTRUCT			; PRINT TEXT
	BRA.S	MNRD_LPIT
MNRD_LPITFIN
	MOVE.L	#lw.blackcols,plw.cols(a5)
	MOVEQ	#1,D0
	BSR	FADECOLS
	BRA	MENU

	INCLUDE	INCLUDES/SCREENTYPER4.S
	EVEN
CLS
	MOVE.L	p.drawpl(a5),a0		; Clear draw plane...
	MOVE.W	#(PLWIDB*PLHGT*NPL/4)-1,D0
ClS_lp	CLR.L	(A0)+
	DBRA	D0,ClS_lp
	RTS

DECODE	;D0=KEYCODE RETURN: A1=ASCII STRING (NULL TERMED) FOR CHR
	LEA	l.decodetab,a1
Decode_lp
	Cmp.b	(a1),D0
	beq.s	Dec_got
	Cmp.b	#-1,d0
	beq.s	Decode_error
decode_lp2	tst.b	(a1)+
	bne.s	decode_lp2	
	BRA.S	Decode_lp
Dec_got
	ADDQ.L	#1,A1
	RTS
Decode_error
	MOVE.W	#-1,D0
decerrlp	move.w	d0,color00(a6)
	dbra	d0,decerrlp
	LEA	Decode.Unkn,a1
	rts
Decode.Unkn	dc.b	'ERROR',0
	even
l.decodetab	;in form code,text,0 (code=-1 termed)
	INCBIN	INCLUDES/DecodeTable.bin
	even

Menu.txt
	_TEXT	MT1,0,248,'L',systemfont,<'V1.0A'>
MT1	_TEXT	MT2,0,110+5,'C',systemfont,<'GAME CODING BY PAUL KENT'>
MT2 _TEXT	MT3,0,120+5,'C',systemfont,<'GRAPHICS BY STUART SMITH'>
MT3 _TEXT	MT4,0,130+5,'C',systemfont,<'THANKS TO: A.HOGG/M.MEANY/D.EDWARDS'>

MT4 _TEXT   MT5,0,218+5,'C',systemfont,<'PRESS F2-F4 TO START GAME'>
MT5	_TEXT	MT6,0,226+5,'C',systemfont,<'1-4 TOGGLES CONTROLS; R REDEFINES KEYS'>
MT6	_TEXT	MT7,0,234+5,'C',systemfont,<'R TO RE-DEFINE KEYS'>
MT7	_TEXT	MT8,0,242+5,'C',systemfont,<'ESCAPE QUITS BACK TO DOS'>

MT8	_TEXT	MT9,0,148+5,'C',systemfont,<'*** CURRENT CONTROL SETTINGS ***'>
MT9 _TEXT	0,0,200+5,'C',systemfont,<'(*) - REQUIRES 4 PLAYER ADAPTOR'>
P0K1.txt	_TEXT	0,0,160+5,'C',systemfont,<'PLAYER 1 : KEYBOARD 1'>
P0K2.txt	_TEXT	0,0,160+5,'C',systemfont,<'PLAYER 1 : KEYBOARD 2'>
P0J.txt		_TEXT	0,0,160+5,'C',systemfont,<' PLAYER 1 : JOYSTICK '>

P1K1.txt	_TEXT	0,0,170+5,'C',systemfont,<'PLAYER 2 : KEYBOARD 1'>
P1K2.txt	_TEXT	0,0,170+5,'C',systemfont,<'PLAYER 2 : KEYBOARD 2'>
P1J.txt		_TEXT	0,0,170+5,'C',systemfont,<' PLAYER 2 : JOYSTICK '>

P2K1.txt	_TEXT	0,0,180+5,'C',systemfont,<' PLAYER 3 : KEYBOARD 1 '>
P2K2.txt	_TEXT	0,0,180+5,'C',systemfont,<' PLAYER 3 : KEYBOARD 2 '>
P2J.txt		_TEXT	0,0,180+5,'C',systemfont,<'PLAYER 3 : JOYSTICK (*)'>

P3K1.txt	_TEXT	0,0,190+5,'C',systemfont,<' PLAYER 4 : KEYBOARD 1 '>
P3K2.txt	_TEXT	0,0,190+5,'C',systemfont,<' PLAYER 4 : KEYBOARD 2 '>
P3J.txt		_TEXT	0,0,190+5,'C',systemfont,<'PLAYER 4 : JOYSTICK (*)'>

MNRED.TXT
	_TEXT	MRTT,0,110+5,'C',systemfont,<'*** RE-DEFINE PLAYERS KEYS ***'>
MRTT	_TEXT	MRT1,0,118+5,'C',systemfont,<'PRESS NEW KEY OR ESCAPE TO KEEP OLD'>

MRT1	_TEXT	MRT2,0,130+5,'C',systemfont,<'KEY SET 1'>
MRT2	_TEXT	MRT3,0,138+5,'L',systemfont,<' LEFT -'>
MRT3	_TEXT	MRT4,0,146+5,'L',systemfont,<'RIGHT -'>
MRT4	_TEXT	MRT5,0,154+5,'L',systemfont,<'   UP -'>
MRT5	_TEXT	MRT6,0,162+5,'L',systemfont,<' DOWN -'>
MRT6	_TEXT   MRT12,0,170+5,'L',systemfont,<' FIRE -'>

MRT12	_TEXT	MRT22,0,182+5,'C',systemfont,<'KEY SET 2'>
MRT22	_TEXT	MRT32,0,190+5,'L',systemfont,<' LEFT -'>
MRT32	_TEXT	MRT42,0,198+5,'L',systemfont,<'RIGHT -'>
MRT42	_TEXT	MRT52,0,206+5,'L',systemfont,<'   UP -'>
MRT52	_TEXT	MRT62,0,214+5,'L',systemfont,<' DOWN -'>
MRT62	_TEXT   MRTIT,0,222+5,'L',systemfont,<' FIRE -'>
MRTIT	_TEXT	0,0,247,'C',systemfont,<'** BEWARE KEYBOARD CLASHES : SEE DOC **'>
QMark.txt	dc.b	'?',0
Any.txt
				dc.l	0			;Next
				dc.w	0,0,'C'		;XYPos,just
				dc.l	systemfont,0	;font,ptr

LL.Keylist
	dc.l	138+5,lb.kbdp0
	dc.l	146+5,lb.kbdp0+1
	dc.l	154+5,lb.kbdp0+2
	dc.l	162+5,lb.kbdp0+3
	dc.l	170+5,lb.kbdp0+4

	dc.l	190+5,lb.kbdp1
	dc.l	198+5,lb.kbdp1+1
	dc.l	206+5,lb.kbdp1+2
	dc.l	214+5,lb.kbdp1+3
	dc.l	222+5,lb.kbdp1+4
	dc.l	0

ColourFont	dc.w	1,9,5
		dc.l CFont
CFont	incbin gfx/font.8*9.32
		even
SystemFont	dc.w	1,8,1
			dc.l	font

*****
* GimmeLogoShow/Draw()
* Prints Martin's logo at top of draw/show planes
* No regs scrunged
* Logo is an IRAWC
*****
GimmeLogoShow
	PUSH A0/A1/D0
	MOVE.L p.showpl(a5),a0
	BRA.S GimmeLogo_1
GimmeLogoDraw
	PUSH A0/A1/D0
	MOVE.L p.drawpl(a5),a0
GimmeLogo_1
	MOVE.L #LOGO_LEN,D0
	LEA LOGO,A1
GL_lp
	rept 10
	move.l (a1)+,(a0)+
	endr
	add.l  #plwidb-40,a0
	sub.l #40,d0
	bne.s GL_lp
	POP	a0/a1/d0
	RTS

