*** BOOTBLOCK INTRO numéro 1 ***
* Auteur: Frédéric Bassaler (mai 95)
* Une petite bootblock intro...
* - Utilisation de rasters, de sprites & de bitplanes
* - Routine de ScrollText

* My 1st Bootblock Intro... pretty lame :-)

	incdir	asm:/Include/
	include	equ.s
	include	exec/types.i
	include	graphics/text.i
	include	graphics/gfx.i
	include	graphics/rastport.i

	rsreset
chipbuf	rs.l	1
gfxbase	rs.l	1
olddma	rs.w	1
;xstart	rs.w	1
ystart	rs.w	1
scrw	rs.w	1
scrh	rs.w	1
charw	rs.w	1
charh	rs.w	1
rast	rs.b	rp_SIZEOF
bmap	rs.b	bm_SIZEOF
VARSIZE	rs.w	0

WIDTH=330*1
HEIGHT=266
DEPTH=1
PLANESIZE=((WIDTH/8)*HEIGHT)*DEPTH

COL0=$000
COL1=$fff

SCROLLY=130
SCROLLSPEED=2

;MOUSE=0	;pointeur souris ou non?
;DBUG=0

Start:
	IFND	DBUG
	dc.l	$444f5300
	dc.b	"SUM!"
	dc.l	$370
	ENDC
Main:
	IFD	DBUG
	move.l	4.w,a6
	ENDC
	movem.l	d0-a6,-(sp)
	sub	#VARSIZE,sp	;on utilise la pile comme base des variables
	move.l	sp,a5		;VarBase en a5

	move.l	$9c(a6),gfxbase(a5)	;execbase->gfxbase
* Allouer buffer pour les bitplanes & copperlist
	move.l	#BUFSIZE,d0
	move.l	#$10002,d1
	jsr	AllocMem(a6)
	move.l	d0,(a5)
	beq.w	closegfx
	move.l	d0,d4

	lea	rast(a5),a1
	move.l	a1,-(sp)
	move.l	gfxbase(a5),a6
	jsr	InitRastPort(a6)

	lea	bmap(a5),a0
	move.l	d4,bm_Planes(a0)	;adresse des bitplanes
	move.l	(sp)+,a1
	move.l	a0,rp_BitMap(a1)
	moveq	#DEPTH,d0
	move	#WIDTH,d1
	move	#HEIGHT,d2
	movem	d1-d2,scrw(a5)
	jsr	InitBitMap(a6)

	lea	topaz.textattr(pc),a0
	move.l	154(a6),a1	;gfxbase->default font
	move.l	10(a1),(a0)	;node name
	jsr	OpenFont(a6)

	lea	rast(a5),a1
	move.l	d0,rp_Font(a1)
	move.l	d0,a0
	move	tf_XSize(a0),charw(a5)
	move	tf_YSize(a0),charh(a5)
	jsr	CloseFont(a6)

;	lea	rast(a5),a1
;	moveq	#1,d0
;	jsr	SetAPen(a6)

;	clr	xstart(a5)
	move	#18,ystart(a5)
	lea	texte(pc),a0
	bsr.w	print

;	move.l	4.w,a6
;	jsr	Forbid(a6)

	lea	$dff000,a4
	move	$02(a4),olddma(a5)
	or	#$8000,olddma(a5)
	move	#$7fff,$96(a4)	;dma off
	lea	coplist(pc),a1
* adresse des bitplanes
	move.l	(a5),d0
	move.l	d0,a2
	move	d0,lo1-coplist(a1)
	swap	d0
	move	d0,hi1-coplist(a1)
* copier données Sprite en CHIP MEM
* et initialiser ptrs Sprite
	IFD	MOUSE
	lea	SpriteData(pc),a0
	lea	sprdata(a2),a1
	move.l	a1,d0
	moveq	#(SPRSIZE/4)-1,d1
.copspr	move.l	(a0)+,(a1)+
	dbf	d1,.copspr
	lea	coplist(pc),a1
	move	d0,sprlo-coplist(a1)
	swap	d0
	move	d0,sprhi-coplist(a1)
	ENDIF
* copier copperlist en CHIP MEM
	lea	PLANESIZE(a2),a2
	move.l	a2,a3
	moveq	#((COPSIZE-DEGSIZE)/4)-1,d0
.copy
	move.l	(a1)+,(a2)+
	dbf	d0,.copy
* construction d'un dégradé avec le copper
DEGSIZE=4096*2
COL=$000
INC=$101
.deg
	moveq	#22,d0		;YStart
	move	#COL,d1
	move	#INC,d2
	moveq	#-2,d4
.dg0
	move	#$0180,(a2)+
	move	d1,(a2)+
	move	d1,d3
	add	d2,d1
	move	#$0182,(a2)+
	neg	d3
	sub	d2,d3
	move	d3,(a2)+
.dg1
	move.b	d0,(a2)+
	addq.b	#1,d0
	move.b	#$0f,(a2)+
	move	d4,(a2)+	;$fffe (Wait)

	cmp.b	#255,d0
	bcs.b	.dg0

	move.l	d4,(a2)		;$ffff,$fffe = fin coplist

	move.l	a3,$80(a4)	;start coplist
	clr	$88(a4)
* initialisation des canaux dma
	IFD	MOUSE
	move	#%1000001111100000,$96(a4)
	ELSE
	move	#%1000001111000000,$96(a4)
	ENDC

	lea	scroll.txt(pc),a3
	move	charw(a5),d7
	lsr	#1,d7
;	moveq	#4,d7

.w	btst	#6,$bfe001
	beq.s	.end
.waitvbl
	move.l	gfxbase(a5),a6
	jsr	WaitTOF(a6)

	btst	#10,$dff016
	beq.b	.stop
	bsr.w	scroll
.stop
* réactualiser la position de Sprite
* (pointeur de la souris)
	IFD	MOUSE
.getmousecoord
	move	$a(a4),d0	;joy0dat
	move	d0,d1
	and	#$ff,d0
	lsr	#8,d1
	add	#150,d0
	add	#30,d1
.setspritecoord
	move	d0,d3
	and	#1,d3
	lsr	#1,d0
	move	d0,d2
	and	#$ff,d2
	move	d1,d0
	add	#16,d0
	rol	#8,d1
	bcc.b	.noE8
	bset	#2,d3
.noE8	or	d1,d2
	rol	#8,d0
	bcc.b	.noL8
	bset	#1,d3
.noL8	or	d0,d3
	move.l	(a5),a0
	movem	d2-d3,sprdata(a0)
	ENDIF

	bra.s	.w
.end

Restore
;	move	#$7fff,$96(a4)
	move.l	4.w,a6
	move.l	$9c(a6),a0		;execbase->gfxbase
	move.l	38(a0),$80(a4)		;coplist système
	clr	$88(a4)			;restore coplist
	move	olddma(a5),$96(a4)	;restore DMA
.free
	move.l	(a5),a1
	move.l	#BUFSIZE,d0
	jsr	FreeMem(a6)
;	jsr	Permit(a6)
closegfx
fin
	add	#VARSIZE,sp	;restitue la pile
	movem.l	(sp)+,d0-a6
BootUp:
	lea	dosname(pc),a1
;	move.l	#' dos',(a1)
;	addq.l	#1,a1
	jsr	FindResident(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts

*** Afficher les lignes de titre (avec centrage du texte)
* <-- a0: adr texte (terminé par 0)
print
	movem.l	d0-a6,-(sp)
	moveq	#0,d0
	move	ystart(a5),d1
;	movem	xstart(a5),d0-d1
;	move.l	gfxbase(a5),a6
	lea	rast(a5),a3
.readchars
	moveq	#0,d4
	move.b	(a0)+,d4
	beq.b	.f
	subq	#1,d4
	move	scrw(a5),d0
	move.l	d4,d3
	mulu	charw(a5),d3
	sub.l	d3,d0
	asr.l	#1,d0
	bsr.b	.pr
	add.l	d4,a0
;	move	xstart(a5),d0
	move	charh(a5),d2
	asl	#1,d2
	add	d2,d1
	bra.b	.readchars
.f
;	movem	d0-d1,xstart(a5)
	movem.l	(sp)+,d0-a6
	rts
.pr
	movem.l	a0/d0/d1,-(sp)
	move.l	a3,a1
	jsr	Move(a6)
	movem.l	(sp)+,a0/d0/d1
	movem.l	a0/d0/d1,-(sp)
	move.l	a3,a1
	move.l	d4,d0
	jsr	Text(a6)
	movem.l	(sp)+,a0/d0/d1
	rts

*** Effacer l'écran
;ClrSc
;	movem.l	d0-a6,-(sp)
;	lea	rast(a5),a1
;	move.l	gfxbase(a5),a6
;	jsr	ClearScreen(a6)
;	movem.l	(sp)+,d0-a6
;	rts

*** Routine de Scrolling de texte
scroll:
	lea	rast(a5),a2
.letter
	move.b	(a3),d0
	bne.b	.nxt
.restart
	lea	scroll.txt(pc),a3
.nxt
	subq	#1,d7
	bne.b	.sc

	move.l	a2,a1
	move	scrw(a5),d0
	subq	#8,d0
	move	#SCROLLY,d1
	jsr	Move(a6)
	move.l	a2,a1
	move.l	a3,a0
	moveq	#1,d0
	jsr	Text(a6)

	addq.l	#1,a3
;	moveq	#4,d7
	move	charw(a5),d7
	lsr	#1,d7
.sc
	move.l	a2,a1
	moveq	#SCROLLSPEED,d0	;delta x
	moveq	#0,d1		;delta y
	moveq	#0,d2		;x1
	move	#SCROLLY,d3	;y1
	move	d3,d5
	sub	charh(a5),d3
	move	scrw(a5),d4	;x2
	addq	#8,d4
	add	charh(a5),d5	;y2
	jmp	ScrollRaster(a6)

*** DATA
LORES=$1200
HIRES=LORES!$8000
LACE=4

coplist:
 DC.w $0100,LORES
 dc.w $0102,$0000
 dc.w $0108,$0000
 dc.w $008E,$2c70	$2981
 DC.w $0090,$2cc1	$29c1
 dc.w $0092,$0038
 DC.w $0094,$00d5
; DC.w $0180,COL0
; dc.w $0182,COL1
 dc.w $00e0
hi1:dc.w 0
 dc.w $00e2
lo1:dc.w 0
	IFD	MOUSE
 dc.w $0120
sprhi:dc.w 0
 dc.w $0122
sprlo:dc.w 0
* couleurs du ptr de la souris (sprite)
 dc.w $01a2,$410	;color17
 dc.w $01a4,$720	;color18
 dc.w $01a6,$f30	;color19
; dc.w $104,$0000
	ENDIF
; dc.w $FFFF,$FFFE	;fin de la liste copper
COPSIZE=*-coplist+DEGSIZE

spritedata:
	IFD	MOUSE
	incdir	SrcII:mouseptr/
	incbin	handptr.dat
	ENDIF
SPRSIZE=*-spritedata
SprData=PLANESIZE+COPSIZE

BUFSIZE=PLANESIZE+COPSIZE+SPRSIZE

topaz.textattr:
	dc.l	0
	dc.w	8
	dc.b	0,0
	even
;gfxname dc.b "grap"
dosname dc.b "dos.library",0

texte
l0
; dc.b l1-l0," "
l1
 DC.B l2-l1,"-*- BootIntro #1 -*-"
l2
 dc.b l3-l2,"Coded by Frédo !"
l3
; dc.b l4-l3,"**************"
l4
; DC.B l5-l4," "
l5
; dc.b l6-l5," "
l6
 dc.b 0
scroll.txt
 dc.b "This intro uses rasters, bitplanes..."
 dc.b " and is 100% system-friendly "
 dc.b " -> optimized code!"
 dc.b " You can put more than 200 bytes of scrolltext!!"
 dc.b " -*- "
 dc.b 0

End:
	dcb.b	512*2,0
