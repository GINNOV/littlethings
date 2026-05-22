************* Bootblock spécial *****************
* - affiche un texte sur un fond de copper	*
* - attend un clic de souris			*
**************** by  Frédo!! ********************
*
* Generic Bootblock Example:
* - setup graphic environment
* - draw copper list
* - print a text
* All system-friendly (I hope!!)

	incdir	asm:/Include/
	include	equ.s
	include	exec/types.i
	include	graphics/text.i
	include	graphics/gfx.i
	include	graphics/rastport.i

	rsreset
planes	rs.l	1
gfxbase	rs.l	1
olddma	rs.w	1
;myfont	rs.l	1
;oldcop1	rs.l	1
xstart	rs.w	1
ystart	rs.w	1
scrw	rs.w	1
scrh	rs.w	1
charw	rs.w	1
charh	rs.w	1
rast	rs.b	rp_SIZEOF
bmap	rs.b	bm_SIZEOF
VARSIZE	rs.w	0

WIDTH=320*1
HEIGHT=256
DEPTH=2
PLSIZE=(WIDTH/8)*HEIGHT
PLANESIZE=PLSIZE*DEPTH

COL0=$422
COL1=$338
COL2=$76d
COL3=$777

;DBUG=0		;uncomment this for debug mode

Start:
	IFND	DBUG
	dc.b	"DOS",1
	dc.l	0,$370
	ENDC
Main:
	IFD	DBUG
	move.l	4.w,a6
	ENDC
	movem.l	d0-a6,-(sp)
	lea	-VARSIZE(sp),sp	;on utilise la pile comme base des variables
	move.l	sp,a5		;VarBase en a5

	move.l	$9c(a6),gfxbase(a5)
* Allouer buffer pour les bitplanes & copperlist
	move.l	#BUFSIZE,d0
	move.l	#$10002,d1
	jsr	AllocMem(a6)
	move.l	d0,planes(a5)
	beq.w	fin
	move.l	d0,d4

	lea	rast(a5),a1
	move.l	a1,-(sp)
	move.l	gfxbase(a5),a6
	jsr	InitRastPort(a6)

	lea	bmap(a5),a0
	move.l	a0,-(sp)
* adresse des bitplanes
;	lea	bm_Planes(a0),a0
	addq.l	#8,a0
	moveq	#DEPTH-1,d0
.pl	move.l	d4,(a0)+
	add	#PLSIZE,d4
	dbf	d0,.pl
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
	moveq	#0,d0
	moveq	#60,d1
	movem	d0-d1,xstart(a5)
	lea	texte(pc),a0
	bsr.w	print

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
	lea	PLSIZE(a2),a2
	move.l	a2,d0
	move	d0,lo2-coplist(a1)
	swap	d0
	move	d0,hi2-coplist(a1)
* copier copperlist ds buffer
	lea	PLSIZE(a2),a2
	move.l	a2,a3
	move	#(COPSIZE/4)-1,d0
.copy
	move.l	(a1)+,(a2)+
	dbf	d0,.copy

	move.l	a3,$80(a4)
	clr	$88(a4)
	move	#%1000011111000000,$96(a4)	;mon dma

.w	btst	#6,$bfe001
	bne.s	.w

closeall
	move.l	planes(a5),a1
	move.l	#BUFSIZE,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)
restore
	move.l	$9c(a6),a0
	move.l	38(a0),$80(a4)
	clr	$88(a4)
	move	olddma(a5),$96(a4)
fin
	lea	VARSIZE(sp),sp	;restitue la pile
	movem.l	(sp)+,d0-a6

Init:
	IFND	DBUG
	lea	expansion.name(pc),a1
	moveq	#37,d0
	jsr	-552(a6)
	tst.l	d0
	beq.b	.err
	move.l	d0,a1
	bset	#6,34(a1)
	jsr	-414(a6)
.err	lea	dos.name(pc),a1
	jsr	-96(a6)
	tst.l	d0
	beq.b	.nodos
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
.nodos	moveq	#-1,d0
	ENDC
	rts

*** Sortir du texte
* <-- a0: adr texte (terminé par 0)
print
	movem.l	d0-a6,-(sp)
	movem	xstart(a5),d0-d1
;	move.l	gfxbase(a5),a6
	lea	rast(a5),a3
	move.l	rp_Font(a3),a1
	move	tf_XSize(a1),charw(a5)
	move	tf_YSize(a1),charh(a5)
	addq	#1,charw(a5)
	addq	#2,charh(a5)
.readchars
	move.b	(a0)+,d7
	beq.w	.f
	cmp.b	#9,d7			tab
	beq.b	.tab
	cmp.b	#$a,d7			linefeed
	beq.b	.lf
	cmp.b	#$c,d7			cls
	beq.b	.clrsc
	bsr.b	.pr
	add	charw(a5),d0
	bra.b	.readchars
.tab
	moveq	#8,d2
	mulu	charw(a5),d2
	add	d2,d0
	bra.b	.readchars
.lf
	add	charh(a5),d1
	move	xstart(a5),d0
	bsr.b	.mov
	bra.b	.readchars
.clrsc
	bsr.b	ClrSc
	move	xstart(a5),d0
	move	ystart(a5),d1
	bra.b	.readchars
.pr
	bsr.b	.mov
	bsr.b	.tx
	movem.l	a0/d0/d1,-(sp)
	move.l	a3,a1
	moveq	#2,d0
	jsr	SetAPen(a6)
	movem.l	(sp)+,a0/d0/d1
	movem.l	d0-d1,-(sp)
	addq	#2,d0
	subq	#2,d1
	bsr.b	.mov
	movem.l	(sp)+,d0-d1
.tx
	movem.l	a0/d0/d1,-(sp)
	subq.l	#1,a0
	move.l	a3,a1
	moveq	#1,d0
	jsr	Text(a6)
	move.l	a3,a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	bra.b	.ok1
.mov
	cmp	scrw(a5),d0
	blt.b	.ok
	clr	d0
	add	charh(a5),d1
	cmp	scrh(a5),d1
	blt.b	.ok
	bsr.b	ClrSc
	move	xstart(a5),d0
	move	ystart(a5),d1
.ok
	movem.l	a0/d0/d1,-(sp)
	move.l	a3,a1
	jsr	Move(a6)
.ok1	movem.l	(sp)+,a0/d0/d1
	rts

.f
	movem	d0-d1,xstart(a5)
	movem.l	(sp)+,d0-a6
	rts
*** Effacer l'écran
ClrSc
	movem.l	d0-a6,-(sp)
	lea	rast(a5),a1
	move.l	gfxbase(a5),a6
	jsr	ClearScreen(a6)
	movem.l	(sp)+,d0-a6
	rts

*** DATA
LORES=(DEPTH<<12)!$200
HIRES=LORES!$8000
LACE=4

RES=LORES

coplist:
 DC.w $0100,RES
 dc.w $008E,$2981
 DC.w $0090,$29c1
 IF RES=LORES
 dc.w $0092,$003c
 DC.w $0094,$00D4
 ELSE
 dc.w $0092,$0038
 DC.w $0094,$00D0
 ENDC
 DC.w $0180,COL0
 dc.w $0182,COL1
 dc.w $0184,COL2
 dc.w $0186,COL3
 dc.w $00e0
hi1:dc.w 0
 dc.w $00e2
lo1:dc.w 0
 dc.w $00e4
hi2:dc.w 0
 dc.w $00e6
lo2:dc.w 0

col set $000
yst set 26
n=7
 REPT n
 dc.w $180,col
 dc.b yst,$0f
 dc.w -2
col set col+$111
yst set yst+12
 ENDR
 REPT n
col set col-$111
 dc.w $180,col
 dc.b yst+2,$0f
 dc.w -2
yst set yst+12
 ENDR
 dc.w $FFFF,$FFFE	;fin de la liste copper
COPSIZE=*-coplist
BUFSIZE=PLANESIZE+COPSIZE

topaz8	dc.l	0
	dc.w	8
	dc.b	0
	dc.b	0

dos.name	dc.b	'dos.library',0
expansion.name	dc.b	'expansion.library',0

texte
 dc.b "FREDO's *ASM-SOURCES* VOL. III",$a
 dc.b 0

End:
	dcb.b	512,0
