*** BootBlock Intro 2 par Frédo!
* avec un scrolling vertical!

* My 2nd BBIntro...

	incdir	asm:/include/
	include	equ.s
	include	exec/types.i
	include	graphics/text.i
	include	graphics/gfx.i
	include	graphics/rastport.i

	rsreset
planes	rs.l	1
;gfxbase	rs.l	1
olddma	rs.w	1
;myfont	rs.l	1
;oldcop1	rs.l	1
;xstart	rs.w	1
;ystart	rs.w	1
txtptr	rs.l	1
scrw	rs.w	1
scrh	rs.w	1
;charw	rs.w	1
;charh	rs.w	1
rast	rs.b	rp_SIZEOF
bmap	rs.b	bm_SIZEOF
VARSIZE	rs.w	0

WIDTH=320*1
HEIGHT=256+10
DEPTH=1
PLSIZE=(WIDTH/8)*HEIGHT
PLANESIZE=PLSIZE*DEPTH

COL0=$665
COL1=$cce
COL2=$66d
COL3=$777

SCRSPEED=1	;vitesse du scrolling
PRSPEED=8/SCRSPEED
CTRTXT=0	;centrage du texte: 0=off, 1=on

;DBUG=0

Start:
	IFND	DBUG
	dc.b	"DOS",1
	dc.l	0,$370
	ENDC
Main:
	movem.l	d0-a6,-(sp)
	lea	-VARSIZE(sp),sp	;on utilise la pile comme base des variables
	move.l	sp,a5		;VarBase en a5

	IFD	DBUG
	move.l	4.w,a6
	ENDC
;	jsr	Forbid(a6)

* Allouer buffer pour les bitplanes & copperlist
	move.l	#BUFSIZE,d0
	move.l	#$10002,d1
	jsr	AllocMem(a6)
	move.l	d0,planes(a5)
	beq.w	fin
	move.l	d0,d4

	lea	rast(a5),a1
	move.l	a1,-(sp)
	move.l	$9c(a6),a6	;execbase->gfxbase
	jsr	InitRastPort(a6)

	lea	bmap(a5),a0
	move.l	a0,-(sp)
* adresse des bitplanes
;	lea	bm_planes(a0),a0
	addq.l	#8,a0
;	moveq	#DEPTH-1,d0
.pl	move.l	d4,(a0)+
;	add	#PLSIZE,d4
;	dbf	d0,.pl
;	move.l	d4,bm_Planes+4(a0)
	move.l	(sp)+,a0
	move.l	(sp)+,a1
	move.l	a0,rp_BitMap(a1)
	moveq	#DEPTH,d0
	move	#WIDTH,d1
	move	#HEIGHT,d2
	movem	d1-d2,scrw(a5)
	jsr	InitBitMap(a6)

	lea	rast(a5),a1
	move.l	a1,a3
	moveq	#1,d0
	jsr	SetAPen(a6)
	move.l	a3,a1
	moveq	#0,d0
	jsr	SetDrMd(a6)

	lea	topaz8(pc),a0
	move.l	154(a6),a1	;gfxbase->defaultfont
	move.l	10(a1),(a0)	;node name->font name
	jsr	OpenFont(a6)
	move.l	d0,-(sp)
	move.l	d0,a1
	jsr	CloseFont(a6)
	move.l	a3,a1
	move.l	(sp)+,a0
	jsr	SetFont(a6)
	move.l	a3,a1
	moveq	#FSF_BOLD,d0
;	moveq	#0,d0
	move.l	d0,d1
	jsr	-90(a6)		;SetSoftStyle()
.nofont
	lea	$dff000,a4
	move	$02(a4),olddma(a5)
	or	#$8000,olddma(a5)
	move	#$7fff,$96(a4)	;dma off
	lea	coplist(pc),a1
* adresse des bitplanes
	move.l	planes(a5),d0
	move.l	d0,a2
	move	d0,lo1-coplist(a1)
	swap	d0
	move	d0,hi1-coplist(a1)
;	lea	PLSIZE(a2),a2
;	move.l	a2,d0
;	move	d0,lo2-coplist(a1)
;	swap	d0
;	move	d0,hi2-coplist(a1)
* copier copperlist ds buffer
	lea	PLSIZE(a2),a2
	move.l	a2,a3
	moveq	#(COPSIZE/4)-1,d0
.copy
	move.l	(a1)+,(a2)+
	dbf	d0,.copy

	move.l	a3,$80(a4)
	clr	$88(a4)
	move	#%1000001111000000,$96(a4)	;mon dma

	lea	scroll.txt(pc),a0
	move.l	a0,txtptr(a5)
	moveq	#PRSPEED,d7
Loop:
	btst	#10,$dff016
	beq.s	.nosc
	bsr.w	Scroll
.nosc
	btst	#6,$bfe001
	bne.s	Loop

CloseAll
	move.l	planes(a5),a1
	move.l	#BUFSIZE,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)
restore
;	move	#$7fff,$96(a4)
	move.l	$9c(a6),a0
	move.l	38(a0),$80(a4)
	clr	$88(a4)
	move	olddma(a5),$96(a4)
;	jsr	permit(a6)
fin
	lea	VARSIZE(sp),sp	;restitue la pile
	movem.l	(sp)+,d0-a6

Init:
;	lea	expansion.name(pc),a1
;	moveq	#37,d0
	IFD	DBUG
	move.l	4.w,a6
	ENDC
;	jsr	-552(a6)
;	tst.l	d0
;	beq.b	.err
;	move.l	d0,a1
;	bset	#6,34(a1)
;	jsr	-414(a6)
.err	lea	dos.name(pc),a1
	jsr	FindResident(a6)
	tst.l	d0
	beq.b	.nodos
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
.nodos	moveq	#-1,d0
	rts

*** Sortir une ligne de texte
* txtptr contient l'adresse du texte
PrintLine:
	movem.l	d0-d6/a0-a6,-(sp)
	lea	rast(a5),a3

	move.l	txtptr(a5),a4
	move.l	a4,a0
	moveq	#-1,d0
.len
	addq.l	#1,d0
	cmp.b	#$a,(a0)+
	bne.s	.len
	move.l	a0,txtptr(a5)
.end_of_line
	move.l	d0,d6
	move.l	a4,a0
	tst.b	(a0)
	beq.s	.end_of_scroll
	IFNE	CTRTXT
	move.l	a3,a1
	jsr	TextLength(a6)
	sub	scrw(a5),d0
	not	d0
	asr	#1,d0
	ELSE
	moveq	#0,d0
	ENDC
	move	#256+8,d1
	move.l	a3,a1
	jsr	Move(a6)

	move.l	a4,a0
	move.l	a3,a1
	move.l	d6,d0
	jsr	Text(a6)
	bra.s	.f
.end_of_scroll
	lea	scroll.txt(pc),a0
	move.l	a0,txtptr(a5)
.f
	movem.l	(sp)+,d0-d6/a0-a6
	rts

*** Effacer l'écran
;ClrSc
;	movem.l	d0-a6,-(sp)
;	lea	rast(a5),a1
;	move.l	gfxbase(a5),a6
;	jsr	ClearScreen(a6)
;	movem.l	(sp)+,d0-a6
;	rts

Scroll:
	subq	#1,d7
	bne.s	.sc
	moveq	#PRSPEED,d7
	bsr.b	PrintLine
.sc	lea	rast(a5),a1
	moveq	#0,d0		;dx
	moveq	#SCRSPEED,d1	;dy
	moveq	#0,d2
	moveq	#0,d3
	movem	scrw(a5),d4-d5
	jsr	ScrollRaster(a6)
	jmp	WaitTOF(a6)

*** DATA
LORES=%0001001000000000		;ajuster le nbre de bitplanes
HIRES=LORES!$8000
LACE=4

coplist:
 DC.w $0100,LORES
 dc.w $0102,0
 dc.w $0108,0
 dc.w $008E,$2981
 DC.w $0090,$29c1
 dc.w $0092,$38
 DC.w $0094,$D0
 DC.w $0180,COL0
 dc.w $0182,COL1
; dc.w $0184,COL2
; dc.w $0186,COL3
 dc.w $e0
hi1:dc.w 0
 dc.w $e2
lo1:dc.w 0
; dc.w $e4
;hi2:dc.w 0
; dc.w $e6
;lo2:dc.w 0

 dc.w $FFFF,$FFFE	;fin de la liste copper
COPSIZE=*-coplist
BUFSIZE=PLANESIZE+COPSIZE

topaz8	dc.l	0
	dc.w	8
	dc.b	0
	dc.b	0

dos.name	dc.b	'dos.library',0
;expansion.name	dc.b	'expansion.library',0

scroll.txt
 dc.b "FREDO STRIKES BACK WIZ ANOTHER BOOTINTRO",$A
; DC.B "----------------------------------------",$A
 DC.B "-*- THIS IS BOOTINTRO NUMBER 2 -*-",$A
 DC.B " ",$A
 dc.b "THIS LITTLE THINGY USES A VERTICAL",$a
 dc.b "SCROLLTEXT. IT ISN'T PARTICULARLY",$a
 dc.b "BEAUTIFUL, BUT IT ENABLES YOU",$A
 DC.B "TO WRITE A QUITE LONG MESSAGE...",$A
 DC.B "I KEPT IT SIMPLE TO USE.",$A
 DC.B "PLEASE DON'T FORGET...",$A
 DC.B "MY MOTTO IS: «SIMPLE BUT EFFICIENT!!»",$A
 dc.b " ",$a
 dc.b "NOW THINGS ARE CLEAR!",$A
 DC.B "WATCH OUT FOR MORE BOOTBLOCK INTROS",$A
 DC.B "FROM THE MAD CODE OPTIMIZER - FREDO!",$A
 dc.b " ",$a
 DC.B "AND NOW... PRESS <LMB> TO EXIT...",$A
 dc.b "(<RMB> PAUSES THE SCROLL)",$A
 DC.B " ",$A
 DC.B "- END OF TRANSMISSION -",$A
 DC.B " ",$A
 dc.b 0

End:
	dcb.b	512,0
