;					Martin Mckenzie
;					2 Wardie Road
;					Easterhouse
;					Glasgow
;					G33 4NP

** High Score Table Printing + Sorting Routine **
; This program is not finished yet. Currently 10 names
; and scores are held in data statements. The program
; will read these and sort them into Highest to lowest
; top 10 order. I am now adding the option to give the
; program a name and score which will be checked to see
; if its worthy of getting into the top ten, if it is, then
; it will be added to the table and sorted as required.
; The code for this is in this version of the program, but
; it doesnt work properly yet.

ExecBase	equ	4
OpenLib		equ	-30-378
closelib	equ	-414

read		equ	-30-12
open		equ	-30
close		equ	-30-6
write		equ	-48
IoErr		equ	-132
mode_old	equ	1005

_custom		equ	$dff000

*********************************************************
*		Start-up Routine			*
*********************************************************

	move.l	ExecBase,a6
	lea	dosname(pc),a1
	moveq	#0,d0
	jsr	OpenLib(a6)
	move.l	d0,dosbase
	beq	error

	lea	consolname(pc),a1
	move.l	#mode_old,d0
	bsr	openfile
	beq	error
	move.l	d0,conhandle

	move.l	(ExecBase).w,a6

*********************************************************
*		Main Routine				*
*********************************************************

;	lea	H_S_Val,a0	; Table address
;	move.l	#Names,a1	; Name address
;	move.l	#3500,d7	; Players last score
;	move.l	#HighName,a5
;	bsr	ChkScr		; Is score good enough?


	move.l	#H_S_Val,a1	; Table address
	move.l	#Names,a4	; Name address
	bsr	Sort		; Sort them

	move.l	#title,d0	; High score headline
	bsr	pmsg		; Print it
	bsr	pclrf		; Print blank line
	bsr	pclrf		; Print blank line

	lea	H_S_Val,a0	; High score values
	lea	Names,a1	; High score names
	move.w	#9,d1		; No. of names -1

loopy:	move.l	a1,d0		; Get name
	bsr	pmsg		; Print it
	add.l	#10,a1		; Point to next name
	move.w	(a0)+,d6	; Move score into d6
	bsr	display_reg	; Translate score into ASCII
	move.l	#Plr1Scr,d0	; Point to score (now in ASCII)
	bsr	pmsg		; Print it
	bsr	pclrf		; Take a new line

	dbra	d1,loopy	; Do rest of table

finish:
	bsr	pclrf		; Take a new line
	move.l	#presskey,d0	; Text to print
	bsr	pmsg		; Print it
	bsr	waitkey		; Wait for return key

*********************************************************
*		Close down program			*
*********************************************************

	move.l	conhandle,d1
	move.l	dosbase,a6
	jsr	close(a6)

	move.l	dosbase,a1
	move.l	ExecBase,a6
	jsr	closelib(a6)
	rts

*********************************************************
*		Score check Routine			*
*********************************************************

ChkScr	move.l	18(a0),d1	; Players No. 10 score
	cmp	d7,d1
	bls	Move_at_11
	rts
Move_at_11
	move.w	d7,18(a0)	; Move score in position 10
	move.l	(a5)+,90(a1)	; Move score in position 10
	move.l	(a5)+,94(a1)	; Move score in position 10

	rts

*********************************************************
*		Sort Routine				*
*********************************************************
; On entry:	A0 = Base address of Table
;		A4 = Base address of Names

Sort:	move.l	a1,a0		; Copy Table address
	move.l	a4,a3		; Copy Name address

	move.l	#10,d2		; Number in counter
	move.l	d2,d0		; Copy No. of elements
	subq	#2,d0		; Correct counter value
	clr	d1		; Erase flag

loop:	move	2(a0),d3	; Next value in D3
	cmp	(a0),d3		; Compare Values
	bls	noswap		; Branch if < or =

doswap:	move	(a0),d1		; Save first Table value
	move.l	(a3),d4		; Save first Name value
	move.l	4(a3),d5	; Save first Name value

	move	2(a0),(a0)	; Copy second into first
	move.l	10(a3),(a3)	; Copy second into first
	move.l	14(a3),4(a3)	; Copy second into first

	move	d1,2(a0)	; Move first into second
	move.l	d4,10(a3)	; Move first into second
	move.l	d5,14(a3)	; Move first into second

	moveq	#1,d1		; Set flag

noswap:	addq.l	#2,a0		; Pointer+2
	dbra	d0,loop		; Keep looping
	tst	d1		; Test flag
	bne	Sort		; Not finished sorting yet!
	rts			; Otherwise return

*********************************************************
*		Printing routines			*
*********************************************************

pmsg:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,a0
	move.l	a0,d2
	clr.l	d3
ploop:
	tst.b	(a0)+
	beq	pmsg2
	addq.l	#1,d3
	bra	ploop
pmsg2:
	move.l	conhandle,d1
	move.l	dosbase,a6
	jsr	write(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

pclrf:
	move	#10,d0
	bsr	pchar
	move	#13,d0
pchar:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	conhandle,d1
pch1:
	lea	outline,a1
	move.b	d0,(a1)
	move.l	a1,d2
	move.l	#1,d3
	move.l	dosbase,a6
	jsr	write(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

error:
	move.l	dosbase,a6
	jsr	IoErr(a6)
	move.l	d0,d5
	move.l	#-1,d7

waitkey:
	move.l	#1,d3
	move.l	conhandle,d1
	lea	inbuff,a1
	move.l	a1,d2
	move.l	dosbase,a6
	jsr	read(a6)
	clr.l	d0
	move.b	inbuff,d0
	rts


openfile:
	move.l	a1,d1

	move.l	d0,d2
	move.l	dosbase,a6
	jsr	open(a6)
	tst.l	d0
	rts

	include	OutputReg.i

*********************************************************
*		Variables				*
*********************************************************

consolname:
	dc.b	'CON:0/0/640/256/** Checker **',0
dosname	dc.b	'dos.library',0,0
inbuff:	ds.b	8
	even
outline		dc.w	0
dosbase		dc.l	0
conhandle	dc.l	0
	even

*********************************************************
*		Text					*
*********************************************************

presskey:
	dc.b	'Press the RETURN key to continue.',0
title:	dc.b	'** The top ten high scores **',0
Plr1Scr:dc.b	'00000',0
	even

H_S_Val	dc.w	40000,65535,30000,20000,10000,8000,6000
	dc.w	4000,2000,1000
	even

Names	dc.b	'Player U ',0,'Player 2 ',0,'Player 3 ',0
	dc.b	'Player 1 ',0,'Player 5 ',0,'Player 6 ',0
	dc.b	'Player 7 ',0,'Player 8 ',0,'Player 10',0
	dc.b	'Player 9 ',0
	even
HighName	dc.b	'Martin_Mc',0
	even

	end

