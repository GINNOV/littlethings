* Bootblock spécial: Mouse acceleration using input.device
* Coded by Frédéric Bassaler (June 1996)

	Incdir	asm:/Include/
	Include equ.s
	include	exec/types.i
	include	exec/interrupts.i

DEFXFACT=8	;facteur d'accélération par défaut (default accel. factor)

;DBUG=0	;comment this to disable debug mode

Start:
	IFND	DBUG
	dc.b	"DOS",0
	dc.l	0,$370
	ENDC
Main:
	btst	#6,$bfe001	;test leftmousebutton
	beq.w	Init

* allocate buffer for variables
	movem.l	d0-a6,-(sp)
	move.l	#VARSIZE,d0
	move.l	#$10002,d1	;chip+clear
	IFD	DBUG
	move.l	4.w,a6
	ENDC
	jsr	AllocMem(a6)
	move.l	d0,a5
* allouer mémoire pour la structure input-handler
	moveq	#IS_SIZE,d0
	move.l	#$10001,d1
	jsr	AllocMem(a6)
	move.l	d0,handler(a5)
* allouer mémoire pour le programme proprement dit
* du nouvel input-handler (is_code)
	moveq	#CODESIZE,d0
	moveq	#$1,d1
	jsr	AllocMem(a6)
	move.l	d0,handlercode(a5)

* copier les données RAW gfx vers bitplane
* (show a little graphic)
	lea	planes(a5),a2		;adr bitplane
	lea	rawgfx(pc),a0	;source: raw gfx data
	lea	40*60+10(a2),a2	;YStart=60
	moveq	#5-1,d7	;nbre de lignes
.cop0
	move.l	a2,a1
	moveq	#16-1,d0	;nbre d'octets/ligne
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop
	lea	40(a2),a2	;ligne suivante
	dbf	d7,.cop0

	lea	$dff000,a4
	move	2(a4),olddma(a5)
	or	#$8400,olddma(a5)
	move	#$7fff,$96(a4)	;dma off
	lea	coplist(pc),a1
* adresse des bitplanes
	lea	planes(a5),a2
	move.l	a2,d0
	move	d0,lo1-coplist(a1)
	swap	d0
	move	d0,hi1-coplist(a1)
* copier copperlist ds buffer
	lea	mycop(a5),a2
	move.l	a2,a3
	moveq	#(COPSIZE/4)-1,d0
.copy
	move.l	(a1)+,(a2)+
	dbf	d0,.copy

	move.l	a3,$80(a4)
	clr	$88(a4)
	move	#%1000001111000000,$96(a4)	;mon dma

* attendre n 50e de sec.
	move.l	$9c(a6),a6
	moveq	#50,d7
.w
	jsr	WaitTOF(a6)
	dbf	d7,.w

	IFD	DBUG
	move.l	4.w,a6
	bra	FreeHandler
	ENDC

* créer un msgport
	lea	readreply(a5),a1
	move.l	a1,d7
	move.l	4.w,a6
	move.l	276(a6),$10(a1)		;execbase->ThisTask
	jsr	AddPort(a6)
* ouvrir dev. input
OpenDev:
	lea	inputio(a5),a1		;struct iostreq
	move.l	d7,14(a1)		;msg port
	moveq	#0,d0			;unit
	moveq	#0,d1			;flags
	lea	inputname(pc),a0	;device name
	jsr	OpenDevice(a6)
	tst.l	d0
	bne.b	FreeHandler		;si erreur

* installation du nouvel input handler
AddInputHandler:
	move.l	handler(a5),a0
;	move.b	#2,ln_type(a0)	;type: interrupt
;	move.b	#51,ln_pri(a0)
	move	#$0233,LN_TYPE(a0)
	move.l	handlercode(a5),a1
	move.l	a1,IS_CODE(a0)

	lea	NewHandlerCode(pc),a2
	moveq	#CODESIZE-1,d0
.copy	move.b	(a2)+,(a1)+
	dbf	d0,.copy

	lea	inputio(a5),a1
	move	#9,28(a1)	;IND_ADDHANDLER
	move.l	a0,40(a1)	;io_data: Handler
	jsr	DoIO(a6)
.closedev
	lea	inputio(a5),a1
	move.l	14(a1),-(sp)
	jsr	CloseDevice(a6)
	move.l	(sp)+,a1
	jsr	RemPort(a6)
	bra.s	CloseAll

FreeHandler:
	move.l	handlercode(a5),a1
	moveq	#CODESIZE,d0
	jsr	FreeMem(a6)
CloseAll:
	move.l	a5,a1
	move.l	#VARSIZE,d0
	jsr	FreeMem(a6)

restore
;	move	#$7fff,$96(a4)
	move.l	$9c(a6),a0	;execbase->gfxbase
	move.l	38(a0),$80(a4)
	clr	$88(a4)
	move	olddma(a5),$96(a4)

	movem.l	(sp)+,d0-a6
Init:
	lea	dosname(pc),a1
	IFD	DBUG
	move.l	4.w,a6
	ENDC
	jsr	FindResident(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts

;RemInputHandler:
;	lea	inputio(pc),a1
;	move	#10,28(a1)	;IND_REMHANDLER
;	lea	NewHandler(pc),a0
;	move.l	a0,40(a1)	;io_data: adr handler
;do_io	move.l	4.w,a6
;	jmp	DoIO(a6)

*** Datas à installer en mémoire: nouvel input handler
;NewHandler:
;	dc.l	0,0	;ln_succ,ln_pred
;	dc.b	2	;ln_type: nt_interrupt
;	dc.b	51	;ln_pri
;	dc.l	NewHandlerName ;ln_name
;	dc.l	NewHandlerData,NewHandlerCode	;is_data, is_code
;NewHandlerName	dc.b "MouseAccel boot v1.0 by F.BASSALER",0
;NewHandlerData:

*** Programme du Handler
NewHandlerCode:
	movem.l	d0-a6,-(sp)
	move.b	4(a0),d2	;ie_class
	cmp.b	#2,d2		;rawmouse?
	beq.b	.mousemov
	cmp.b	#1,d2		;rawkey?
	bne.b	.no
	movem	6(a0),d0-d1	;ie_code, ie_qualifier
	cmp.b	#$10,d1		;left ALT
	bne.b	.no
	and	#$ff,d0
	sub.b	#$50,d0
;	tst.b	d0
	bcs.b	.no
	cmp.b	#7,d0
	bhi.b	.no
	addq	#1,d0
	lea	xfact(pc),a1
	move	d0,(a1)		;->accel.
	bra.b	.no
.mousemov
	movem	10(a0),d0-d1	;deltaX, deltaY
* on accélère !
	moveq	#0,d7
	move	xfact(pc),d7	;facteur d'accel.
	muls	d7,d0
	muls	d7,d1
	movem	d0-d1,10(a0)
.no
	movem.l	(sp)+,d0-a6
	move.l	a0,d0
	rts
xfact	dc.w DEFXFACT	;facteur d'accélération

NewHandlerEnd:
CODESIZE=*-NewHandlerCode

*** DATA
LORES=%0001001000000000		;ajuster le nbre de bitplanes
HIRES=LORES!$8000
LACE=4

coplist:
 DC.w $0100,LORES
 dc.w $008E,$2981
 DC.w $0090,$29c1
 dc.w $0092,$0038
 DC.w $0094,$00d0
 dc.w $0180,$000
 dc.w $0182,$fff
 dc.w $00e0
hi1:dc.w 0
 dc.w $00e2
lo1:dc.w 0
 dc.w $FFFF,$FFFE	;fin de la liste copper
COPSIZE=*-coplist

* données IFF converties en RAW par GFXCONV
rawgfx:
	DC.B	$89,$92,$6F,$31,$CE,$F4,$04,$18
	DC.B	$39,$10,$F3,$8C,$66,$64,$7B,$80
	DC.B	$DA,$52,$88,$4A,$10,$84,$0C,$24
	DC.B	$24,$A0,$82,$52,$88,$94,$42,$40
	DC.B	$AA,$52,$4E,$7A,$10,$E4,$04,$24
	DC.B	$38,$40,$E3,$9E,$44,$F4,$73,$80
	DC.B	$8A,$52,$28,$4A,$10,$84,$04,$24
	DC.B	$24,$40,$82,$52,$22,$94,$42,$40
	DC.B	$89,$8C,$CF,$49,$CE,$F7,$0E,$98
	DC.B	$38,$40,$8B,$92,$CC,$97,$7A,$40
rawsize=*-rawgfx

inputname	dc.b "input.device",0
dosname		dc.b "dos.library",0

 dc.b " MOUSE-ACCELERATOR BOOT 1.0 BY F.B - "
 DC.B "PRESS <LMB> DURING BOOT TO CANCEL INSTALLATION. "
 dc.b "USE THE LEFT ALT KEY + F1...F8 TO CHANGE ACCEL.FACTOR. "
 DC.B "FOR CODING-SWAPPING IDEAS & BOOTPRGS, WRITE TO: "
 DC.B "FREDERIC BASSALER - LA SERRE - 19500 COLLONGES - FRANCE"
 dc.b ". SPREAD THIS BOOTBLOCK!!"

End:
	dcb.b	512*2,0

	rsreset
handler		rs.l	1
handlercode	rs.l	1
olddma		rs.w	1
inputio	 	rs.b	48
readreply 	rs.b	34
planes		rs.b	(320/8)*256
mycop		rs.b	COPSIZE
VARSIZE		rs.w	0
