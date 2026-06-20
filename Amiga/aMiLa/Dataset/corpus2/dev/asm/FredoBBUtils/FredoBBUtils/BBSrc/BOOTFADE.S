************* Bootblock spécial *****************
* - affiche un gfx au format RAW (cf.GFXCONV)	*
* - attend un clic de souris			*
**************** Par Frédo!! ********************

* Another bootblock example:
* with a color fading routine

	incdir	ASM:/Include/
	include	equ.s
	include	exec/types.i
	include	graphics/text.i
	include	graphics/gfx.i
	include	graphics/rastport.i

	rsreset
planes	rs.l	1
gfxbase	rs.l	1
coplistptr rs.l	1
olddma	rs.w	1
scrw	rs.w	1
scrh	rs.w	1
rast	rs.b	rp_SIZEOF
bmap	rs.b	bm_SIZEOF
VARSIZE	rs.w	0

WIDTH=320*1
HEIGHT=256
DEPTH=1
BYTESPERROW=WIDTH/8
PLSIZE=(BYTESPERROW)*HEIGHT
PLANESIZE=PLSIZE*DEPTH

COL0=$789
COL1=$f14

;coordonnées dessin
X=100
Y=50

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
* copier les données RAW vers bitplane
	lea	rawdata(pc),a0
	move.l	planes(a5),a2	;adr bitplane
	add	#(Y*BYTESPERROW)+(X/8),a2
	moveq	#6-1,d7	;nbre de lignes
.cop0
	move.l	a2,a1
	moveq	#(RAWSIZE/6)-1,d0	;octets/ligne = rawsize/#lignes
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop
	add	#BYTESPERROW,a2		;ligne suivante
	dbf	d7,.cop0

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
* copier copperlist ds buffer
	add	#PLSIZE,a2
	move.l	a2,a3
	moveq	#(COPSIZE/4)-1,d0
.copy
	move.l	(a1)+,(a2)+
	dbf	d0,.copy

	move.l	a3,$80(a4)
	move.l	a3,coplistptr(a5)
	clr	$88(a4)
	move	#%1000011111000000,$96(a4)	;mon dma

.w	btst	#6,$bfe001
	bne.s	.w

	bsr.b	fade

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

init
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


; routine de fading de couleurs
fade:
	lea	cpal(pc),a0
	moveq	#2,d0

	moveq	#15,d5	;compteur
.debut
	move.l	a0,a4
	move.l	d0,d4
.coul_suiv
	tst	d0
	beq.s	.prochain_tour
	subq	#1,d0
	move	(a0)+,d1
	beq.s	.coul_suiv
.fade_coul
	move.b	d1,d3
	and.b	#$0f,d3		;composante bleue en d3
	lsr	#4,d1
	move.b	d1,d2
	and.b	#$0f,d2		;composante verte en d2
	lsr	#4,d1
	and	#$000f,d1	;composante rouge en d1
.rouge
	tst.b	d1
	beq.s	.vert
	subq.b	#1,d1
.vert
	tst.b	d2
	beq.s	.bleu
	subq.b	#1,d2
.bleu
	tst.b	d3
	beq.s	.save_coul
	subq.b	#1,d3
.save_coul
	lsl	#8,d1
	lsl	#4,d2
	or	d2,d1
	or.b	d3,d1
	and	#$0fff,d1
	move	d1,-2(a0)
	bra.s	.coul_suiv

.prochain_tour
	move.l	d4,d0
	move.l	a4,a0

; insérer ici les routines:
;  - d'actualisation de la palette. ex: LoadRGB4() etc...
;  - de delai (WaitVBL)
	movem.l	d0-a6,-(sp)
	move.l	gfxbase(a5),a6
	moveq	#3,d7
.waitvbl
	jsr	WaitTOF(a6)
	dbf	d7,.waitvbl
	move.l	coplistptr(a5),a0
	move	(a4),col0ptr-coplist(a0)
	move	2(a4),col1ptr-coplist(a0)
	movem.l	(sp)+,d0-a6

	dbf	d5,.debut

.fin
	rts

*** DATA
LORES=(DEPTH<<12)!$200
HIRES=LORES!$8000
LACE=4

RES=LORES

coplist:
 DC.w $0100,RES
 dc.w $0108,$0000
 dc.w $008E,$2981
 DC.w $0090,$29c1
 IF RES=LORES
 dc.w $0092,$0038
 DC.w $0094,$00D0
 ELSE
 dc.w $0092,$003c
 dc.w $0094,$00d4
 ENDC
 DC.w $0180
col0ptr:
 dc.w COL0
 dc.w $0182
col1ptr:
 dc.w COL1
 dc.w $00e0
hi1:dc.w 0
 dc.w $00e2
lo1:dc.w 0
 dc.w $FFFF,$FFFE	;fin de la liste copper
COPSIZE=*-coplist
BUFSIZE=PLANESIZE+COPSIZE

cpal	dc COL0,COL1

dos.name	dc.b	'dos.library',0
expansion.name	dc.b	'expansion.library',0

* RAW gfx data
rawdata:
 dc.b %01111111,%01111100,%01111110,%11111100,%01111110,%00011000
 dc.b %11000000,%11000010,%11000000,%11000010,%11000011,%00111100
 dc.b %11000000,%11000010,%11000000,%11000010,%11000011,%00111100
 dc.b %11111100,%11111100,%11111100,%11000010,%11000011,%00011000
 dc.b %11000000,%11000010,%11000000,%11000010,%11000011,%00000000
 dc.b %11000000,%11000010,%01111110,%11111100,%01111110,%00011000
RAWSIZE=*-rawdata

End:
	dcb.b	512*2,0
