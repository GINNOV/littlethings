
	SECTION	EDIT,CODE_C

DeInitLevels
	lea	lp.maplist,a1
DeInitLevels_lp
	tst.l	(a1)
	beq.s	DeInitLevelsFin
	lea	MP_Level(a1),a2
	move.w	#NUMBLOCKS-1,d1			; Level size
DeInitLevels_ilp
	MOVEQ	#0,D2
	MOVE.W	(A2),D2
	LSR.W	#5,D2					; /32 = length of 1 plane of block
	MOVE.W	D2,(A2)+
	DBRA	D1,DeInitLevels_ilp
	lea	MP_LEN(a1),a1					; Skip levptr & colptr
	bra.s	DeInitLevels_lp
DeInitLevelsFin
	rts

EDIT
	CLR.W	W.CURLEVEL(A5)
EDIT2
	CLR.W	E.CURSX
	CLR.W	E.CURSY
	LEA	E.CSAVE,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	BSR	E_PRINTCURL					; PRINT LEVEL
	BSR	E_PRINTCURS					; PRINT CURSOR
E_LOOP
	TST.B	KEYMAP+$45				; ESC QUITS
	BNE.s	E_QUIT

	TST.B	KEYMAP+$51				; F2 UP LEVEL
	BNE.s	E_ULEV
	TST.B	KEYMAP+$50				; F1 DOWN LEVEL
	BNE.s	E_DLEV

	BSR.S	CHECKDOMOVE
	BSR	CHECKADV
	BSR	CHECKPOSMOD
	BSR	E_BLOCKGET
	BSR	E_BLOCKPUT
	BSR	E_LEVELGET
	BSR	E_LEVELPUT
	BSR	E_BLANKPUT
	BRA.S	E_LOOP

;QUIT : FADECOLOURS ETC
E_QUIT	TST.B	KEYMAP+$45				; WAIT FOR ESC RELEASE
	BNE.S	E_QUIT
E_FADEOUT	
	MOVE.L	#LW.BLACKCOLS,plw.Cols(a5)
	MOVEQ	#1,D0
	JSR	FadeCols
	RTS

E_ULEV	TST.B	KEYMAP+$51			; F2 UP LEVEL
	BNE.S	E_ULEV
	MOVE.W	w.CurLevel(a5),D0		; all levels done
	CMP.W	w.NumLevels(a5),d0
	BEQ.S	E_LOOP
	ADDQ.W	#1,W.Curlevel(a5)
	BRA	EDIT2

E_DLEV	TST.B	KEYMAP+$50			; F1 DOWN LEVEL
	BNE.S	E_DLEV
	TST.W	w.CurLevel(a5)
	BEQ.S	E_LOOP
	SUBQ.W	#1,w.Curlevel(a5)
	BRA	EDIT2

CHECKDOMOVE
	LEA	KEYMAP,A4
	LEA	CHECKLIST,A3

CHDMLP
	MOVE.W	(A3)+,D0
	BPL.S	CHDMOK		; -VE ENDOF LIST
	RTS
CHDMOK
	TST.B	(A4,D0.W)
	BNE.S	CHDMGOT
	ADDQ.L	#4,A3
	BRA.S	CHDMLP

CHDMGOT	TST.B	(A4,D0.W)
	BNE.S	CHDMGOT

	MOVE.W	E.CURSX,D0
	MOVE.W	E.CURSY,D1
	ADD.W	(A3)+,D0
	ADD.W	(A3)+,D1

	CMP.W	#-1,D0
	BNE.S	CHDMX1OK
	MOVEQ	#0,D0
CHDMX1OK
	CMP.W	#20,D0
	BNE.S	CHDMX2OK
	MOVEQ	#19,D0
CHDMX2OK

	CMP.W	#-1,D1
	BNE.S	CHDMY1OK
	MOVEQ	#0,D1
CHDMY1OK
	CMP.W	#16,D1
	BNE.S	CHDMY2OK
	MOVEQ	#15,D1
CHDMY2OK
	MOVE.W	D0,E.CURSX
	MOVE.W	D1,E.CURSY
	BSR	E_PRINTCURS
	RTS

CHECKADV
	LEA	KEYMAP,A4	;HELP $5F DEL$46
	TST.B	$5F(A4)
	BNE.S	CAD_UP
	TST.B	$46(A4)
	BNE	CAD_DOWN
	LEA	CADITTAB,A3
CHECKADV_LP
	MOVE.W	(A3),D6
	BMI.S	CHECKADV_LPF
	MOVE.W	2(A3),D7
	TST.B	(A4,d6.w)
	BNE	CAD_IT
	ADDQ.L	#4,A3
	BRA.S	CHECKADV_LP
CHECKADV_LPF
	RTS
CADITTAB
	DC.W	1,0,2,1,3,2,4,3,5,4,6,5,7,6,8,7,9,8,10,9,11,10,12,11,13,12
	DC.W	16,13,17,14,18,15,19,16
	DC.W	-1,-1

CAD_UP
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MULU	#MP_LEN,D0
	LEA	MP_Level(A1,D0.W),A0
;
	MOVE.W	#-1,MP_ModSig-Mp_Level(a0)
;
	MOVE.W	E.CURSY,D0
	MULU	#40,D0
	ADD.W	E.CURSX,D0
	ADD.W	E.CURSX,D0
	LEA	(A0,D0.L),A1

	CMP.W	#(MAXMAPBLOCKS-1)*32,(A1)
	BEQ.S	CAD_UPLP
	ADD.W	#32,(A1)
	BSR	EPRINTLEVEL
	LEA	E.CSAVE,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	BSR	E_PRINTCURS					; PRINT CURSOR
CAD_UPLP	TST.B	$5F(A4)
	BNE.S	CAD_UPLP
	RTS

CAD_DOWN
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MULU	#MP_LEN,D0
	LEA	MP_Level(A1,D0.W),A0
;
	MOVE.W	#-1,MP_ModSig-Mp_Level(a0)
;
	MOVE.W	E.CURSY,D0
	MULU	#40,D0					;20*2BYTES
	ADD.W	E.CURSX,D0				;1 WORD PER ENTRY
	ADD.W	E.CURSX,D0
	LEA	(A0,D0.L),A1

	CMP.W	#0,(A1)
	BEQ.S	CAD_DOWNLP
	SUB.W	#32,(A1)
	BSR	EPRINTLEVEL
	LEA	E.CSAVE,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	BSR	E_PRINTCURS					; PRINT CURSOR
CAD_DOWNLP	TST.B	$5F(A4)
	BNE.S	CAD_DOWNLP
	RTS

CAD_IT
;KEYCODE TO CHECK D6
;LINE IN D7
	MULU	#32*20,D7
	CMP.W	#(MAXMAPBLOCKS-1)*32,D7
	BMI.S	CAD_ITOK
	MOVE.W	#(MAXMAPBLOCKS-1)*32,D7
CAD_ITOK
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MULU	#MP_LEN,D0
	LEA	MP_Level(A1,D0.W),A0
;
	MOVE.W	#-1,MP_ModSig-Mp_Level(a0)
;
	MOVE.W	E.CURSY,D0
	MULU	#40,D0					;20*2BYTES
	ADD.W	E.CURSX,D0				;1 WORD PER ENTRY
	ADD.W	E.CURSX,D0
	LEA	(A0,D0.L),A1
	MOVE.W	D7,(A1)
	BSR	EPRINTLEVEL
	LEA	E.CSAVE,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	BSR	E_PRINTCURS					; PRINT CURSOR
CAD_NOLP	TST.B	(A4,D6.W)
	BNE.S	CAD_NOLP
	RTS
	
CHECKLIST
	DC.W	$4C,0,-1	;KEY,DX,DY
	DC.W	$4D,0,1
	DC.W	$4E,1,0
	DC.W	$4F,-1,0
	DC.W	-1

CHECKPOSLIST	;KEY,BACKG COL, OFFSET
	DC.W	$1D,$F00,MP_Starts					; PLAYER STARTS
	DC.W	$1E,$00F,MP_Starts+4
	DC.W	$1F,$FF0,MP_Starts+8
	DC.W	$2D,$F0F,MP_Starts+12

	DC.W	$2E,$444,MP_Bonus					; BONUS POSNS
	DC.W	$2F,$666,MP_Bonus+4
	DC.W	$3D,$888,MP_Bonus+8
	DC.W	$3E,$AAA,MP_Bonus+12
	DC.W	-1
CHECKPOSMOD							; CHECK FOR PLAYER/BONUS START POSNS!
	LEA	KEYMAP,A4
	LEA	CHECKPOSLIST,A3

CHPMLP
	MOVE.W	(A3)+,D0
	BPL.S	CHPMOK		; -VE ENDOF LIST
	RTS
CHPMOK	TST.B	(A4,D0.W)
	BNE.S	CHPMGOT
	ADDQ.L	#4,A3
	BRA.S	CHPMLP
CHPMGOT	MOVE.W	(A3),COLOR00(A6)
	TST.B	(A4,D0.W)
	BNE.S	CHPMGOT
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MULU	#MP_LEN,D0
	LEA		(A1,D0.W),A1
;
	MOVE.W	#-1,MP_ModSig(a1)
;
	MOVE.W	2(A3),D0
	MOVE.W	E.CURSX,D1
	LSL.W	#4,D1
	MOVE.W	E.CURSY,D2
	LSL.W	#4,D2
	MOVE.W	D1,(A1,D0.W)
	MOVE.W	D2,2(A1,D0.W)
	RTS
	
	
E_BLOCKPUT
	TST.B	$0F+KEYMAP				; NK0
	BEQ.S	E_BPN
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MULU	#MP_LEN,D0
	LEA	MP_Level(A1,D0.W),A0
;
	MOVE.W	#-1,MP_ModSig-Mp_Level(a0)
;
	MOVE.W	E.CURSY,D0
	MULU	#40,D0					;20*2BYTES
	ADD.W	E.CURSX,D0				;1 WORD PER ENTRY
	ADD.W	E.CURSX,D0
	LEA	(A0,D0.L),A1
	MOVE.W	E.BLOCK,(A1)
	BSR	EPRINTLEVEL
	LEA	E.CSAVE,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	BSR	E_PRINTCURS					; PRINT CURSOR
E_BPLP	TST.B	$F+KEYMAP
	BNE.S	E_BPLP
E_BPN
	RTS


E_BLOCKGET
	TST.B	$3C+KEYMAP				; NK.
	BEQ.S	E_BGN
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MULU	#MP_LEN,D0
	LEA	Mp_Level(A1,D0.W),A0
	MOVE.W	E.CURSY,D0
	MULU	#40,D0					;20*2BYTES
	ADD.W	E.CURSX,D0				;1 WORD PER ENTRY
	ADD.W	E.CURSX,D0
	LEA	(A0,D0.L),A1
	MOVE.W	(A1),E.BLOCK
E_BGLP	TST.B	$3C+KEYMAP
	BNE.S	E_BPLP
E_BGN
	RTS

E_LEVELGET
	TST.B	$5B+KEYMAP				; NK)
	BEQ.S	E_LGN
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),E.SAVELEV
E_LGLP
	MOVE.W	#$F00,$DFF180
	TST.B	$5B+KEYMAP
	BNE.S	E_LGLP
E_LGN	RTS

E_LEVELPUT
	TST.B	$5A+KEYMAP				; NK(
	BEQ.S	E_LPN
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MOVE.W	E.SAVELEV,D1
	MULU	#MP_LEN,D0
	MULU	#MP_LEN,D1
	LEA	Mp_Level(A1,D0.W),A0
;
	MOVE.W	#-1,MP_ModSig-Mp_Level(a0)
;
	MOVE.L	A0,A2
	LEA	Mp_Level(A1,D1.W),A3
	MOVE.W	#NUMBLOCKS-1,D2			; Loop count -1
E_LPCLP	MOVE.W	(A3)+,(A2)+
	DBRA	D2,E_LPCLP
	BSR	EPRINTLEVEL
	LEA	E.CSAVE,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	BSR	E_PRINTCURS					; PRINT CURSOR
E_LPLP
	MOVE.W	#$F00,$DFF180
	TST.B	$5A+KEYMAP
	BNE.S	E_LPLP
E_LPN	RTS


E_BLANKPUT
	TST.B	$41+KEYMAP				; <- DEL
	BEQ.S	E_BLPN
	LEA	LP.MAPLIST,A1
	MOVE.W	W.CURLEVEL(A5),D0
	MULU	#MP_LEN,D0
	LEA	MP_Level(A1,D0.W),A0
;
	MOVE.W	#-1,MP_ModSig-Mp_Level(a0)
;
	MOVE.W	E.CURSY,D0
	MULU	#40,D0					;20*2BYTES
	ADD.W	E.CURSX,D0				;1 WORD PER ENTRY
	ADD.W	E.CURSX,D0
	LEA	(A0,D0.L),A1
	MOVE.W	#$E*32,(A1)
	BSR.S	EPRINTLEVEL
	LEA	E.CSAVE,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	BSR.S	E_PRINTCURS					; PRINT CURSOR
E_BLPLP	TST.B	$41+KEYMAP
	BNE.S	E_BLPLP
E_BLPN
	RTS

E_PRINTCURL
	lea	lp.maplist,a1
	move.w	w.CurLevel(a5),d0
	mulu	#MP_LEN,d0					; *MAPLIST_LEN 'modulo' on table
	LEA	(A1,D0.W),A1
	move.l	a1,-(a7)
	lea	mp_level(a1),a0
	Bsr.S	EPrintLevel				; Print level
	move.l	(a7)+,a1	
	Move.l	MP_Cols(a1),plw.Cols(a5)
	moveq	#0,d0
	Jsr	FadeCols
	rts
;Print cursor (bullet) AT E.CURSX*16+4,E.CUSRY*16+4

E_printcurs
	Lea	E.CSave,a2					; Delete previous...
	Jsr	RecoBob
	MOVE.W	E.CURSX,D0				; Get posns
	MULU	#16,D0
	MOVE.W	E.CURSY,D1
	MULU	#16,D1
	ADDQ.W	#4,D0
	ADDQ.W	#4,D1
	moveq	#0,d2
	MOVE.L	p.showpl(a5),a1
	LEA	Player0_Bullets,a0
	Lea	E.CSave,a2
	JMP	DoBob						; Print bob

EPRINTLEVEL
	JSR	PRINTLEVEL
;PRINT LEVEL NUM...
	move.l	p.showpl(a5),a0
	lea	dectab,a1
	lea	font,a2
	moveq	#0,d0
	MOVE.W	w.Curlevel(a5),d0
	lsl.w	#3,d0
	JMP	PSPERC

E.CURSX	DC.W	0					; Cursor posn in *blocks*
E.CURSY	DC.W	0					; -/-
E.CSAVE	DS.B	BULLETSAVE_LEN
E.BLOCK	DS.W	1					; Buffer for block^2 no.
E.SAVELEV	DS.W	1				; Saved level no for copy

EDIT_SAVE

	lea	lp.maplist,a5
	lea	sname,a0
es_lp
	tst.l	(a5)
	beq.s	esFin
;
	TST.W	MP_ModSig(a5)
	BEQ.S	es_cont
	CLR.W	MP_ModSig(a5)
;
	lea	MP_Starts(a5),a1
	move.l	#MP_len-Mp_starts,D1	; DOnt save cols ptr!
	bsr.s	_SaveFile
es_cont
	addq.b	#1,5(a0)
	cmp.b	#':',5(a0)
	bne.s   es_fok
	move.b	#'0',5(a0)
	addq.b	#1,4(a0)
es_fok
	lea	MP_LEN(a5),a5			; Skip levptr & colptr
	bra.s	es_lp
esFin
	rts
sname	dc.b	'ram:00.LEVPAK',0
	EVEN
DOSNAME	DC.B	'dos.library',0
	even

;	Function: d0 = _SaveFile(a0,a1,d1)
;	a0 = file name
;	a1 = source data
;   d1 = save length

;	d0 = 0 ERROR, Non-zero save OK

_SaveFile
	movem.l a0-a6/d2-d6,-(sp)
	moveq	#0,d6			;d6 = return code
	move.l  a0,a4			;a4 = file name
	move.l	a1,a5
	move.l	d1,d5			;d5 = save length

	movea.l 4.w,a6
	lea     dosname(pc),a1
	jsr     -$198(a6)		;OldOpenLibrary()
	tst.l   d0
	beq.s     xsm1
	move.l  d0,a3			;a3 = DOSBase
	move.l  d0,a6
	move.l  a4,d1			;name = d1
	move.l  #1006,d2		;accessmode = MODE_NEWFILE
	jsr     -$1e(a6)		;Open()
	move.l  d0,d4			;d4 = file handle
	beq.s     xsm2

	move.l  d4,d1			;file
	move.l  a5,d2			;buffer
	move.l  d5,d3	;length
	move.l	a3,a6
	jsr     -$30(a6)		;Write()

	moveq	#1,d6			;return code... no error
	cmp.l	d5,d0			;check if saved ok...
	beq.s	xsne
	moveq	#0,d6			;error!
xsne

	move.l  a3,a6			;close the file
	move.l  d4,d1
	jsr     -$24(a6)		;Close(fhandle)
xsm2
	move.l  a3,a1			;close dos.library
	movea.l 4.w,a6
	jsr     -$19e(a6)
xsm1
	move.l  d6,d0			;push return value
	movem.l (sp)+,a0-a6/d2-d6	;restore registers
	rts						;and exit...
