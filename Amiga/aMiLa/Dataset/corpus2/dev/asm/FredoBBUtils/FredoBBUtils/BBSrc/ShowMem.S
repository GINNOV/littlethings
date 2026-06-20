*** ShowMem	V1.0	by Frédo'96 !
* Visualise la mémoire CHIP à l'aide du Blitter
*
* View chip memory's contents using the blitter (system-friendly)
*
* Keys: space, del, arrows, keypad +, keypad -
*	Rightmouse to quit
*

	incdir	ASM:/Include/
	include	equ.s
	include	exec/types.i
	include	graphics/text.i
	include	graphics/gfx.i
	include	graphics/rastport.i

	rsreset
planes	rs.l	1
gfxbase	rs.l	1
himem	rs.l	1
olddma	rs.w	1
copadr	rs.l	1
xstart	rs.w	1
ystart	rs.w	1
scrw	rs.w	1
scrh	rs.w	1
charw	rs.w	1
charh	rs.w	1
src	rs.l	1
modulo	rs.w	1
myres	rs.b	1
lastkey	rs.b	1
rast	rs.b	rp_SIZEOF
bmap	rs.b	bm_SIZEOF
strbuf:	rs.b	64
VARSIZE	rs.w	0

WIDTH=320*2
HEIGHT=256
DEPTH=1
PLSIZE=(WIDTH/8)*HEIGHT
PLANESIZE=PLSIZE*DEPTH

LORES=%0001001000000000		;ajuster le nbre de bitplanes
HIRES=LORES!$8000
LACE=4

COL0=$000
COL1=$fff
COL2=$66d
COL3=$777

DEFSRC=$0
DEFMOD=80
VAL=80*10
LOVAL=2

;BOOT=1
DBUG=0

Start:
	IFND	DBUG
	dc.b	"DOS",0
	dc.l	0,880
	ENDC
Main:
	lea	dosname(pc),a1
	IFD	DBUG
	move.l	4.w,a6
	ENDC
	jsr	-96(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0

	movem.l	d0-a6,-(sp)
	suba	#VARSIZE,sp
	move.l	sp,a5
	IFD	DBUG
	move.l	4.w,a6
	ENDC
	move.l	62(a6),d0
	subq.l	#1,d0
	move.l	d0,himem(a5)
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
.pladr	move.l	d4,(a0)+
	add	#PLSIZE,d4
	dbf	d0,.pladr
	move.l	d4,bm_Planes+4(a0)
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
	jsr	SetBPen(a6)
	move.l	a3,a1
	moveq	#1,d0
	jsr	SetDrMd(a6)

	lea	topaz8(pc),a0
	move.l	154(a6),a1
	move.l	10(a1),(a0)
	jsr	OpenFont(a6)
	move.l	d0,-(sp)
	move.l	d0,a1
	jsr	CloseFont(a6)
	move.l	a3,a1
	move.l	(sp)+,a0
	jsr	SetFont(a6)
;	move.l	a3,a1
;	moveq	#FSF_BOLD,d0
;	moveq	#0,d0
;	move.l	d0,d1
;	jsr	-90(a6)		;SetSoftStyle()
.nofont
	clr	xstart(a5)
	move	#30,ystart(a5)

	lea	$dff000,a4
	move	$02(a4),olddma(a5)
	or	#$8000,olddma(a5)
	move	#$7fff,$96(a4)	;dma off

	lea	coplist(pc),a1
* adresse des bitplanes
	move.l	a1,-(sp)
	lea	planesptr(pc),a1
	move.l	planes(a5),d0
	move.l	d0,a2
	move	#$e0,d3
	moveq	#DEPTH-1,d1
.pl
	move	d3,(a1)+
	addq	#2,d3
	swap	d0
	move	d0,(a1)+
	move	d3,(a1)+
	addq	#2,d3
	swap	d0
	move	d0,(a1)+
	lea	PLSIZE(a2),a2
	move.l	a2,d0
	dbf	d1,.pl
	clr.l	(a1)
* copier copperlist ds buffer
	move.l	(sp)+,a1
	lea	PLSIZE(a2),a2
	move.l	a2,a3
;	moveq	#(COPSIZE/2)-1,d0
.copy	move.l	(a1)+,(a2)+
	bne.b	.copy
	moveq	#-2,d0
	move.l	d0,-4(a2)
;	dbf	d0,.copy

	move.l	a3,copadr(a5)
	move.l	a3,$80(a4)
	clr	$88(a4)
	move	#%1000011111000000,$96(a4)	;mon dma

	clr.l	src(a5)		;src=$0
	move	#DEFMOD,modulo(a5)
	st	myres(a5)	;res=HIRES

WaitLoop:
	btst	#10,$dff016	;rightmousebutton pressed?
	beq.w	CloseAll	;if yes, quit

	bsr.w	GetRawKey
	cmp.b	#$40,d0		;space
	beq.b	.switch_res
	cmp.b	#$46,d0		;del
	beq.b	.reset_modulo
	cmp.b	#$4a,d0		;-
	beq.b	.mod_down
	cmp.b	#$5e,d0		;+
	beq.b	.mod_up
	cmp.b	#$4c,d0		;arrow Up
	beq.b	.adr_up
	cmp.b	#$4d,d0		;	down
	beq.b	.adr_down
	cmp.b	#$4f,d0		;	left
	beq.b	.adr_down2
	cmp.b	#$4e,d0		;	right
	beq.b	.adr_up2
	bra.b	loop
.mod_down
	subq	#2,modulo(a5)
	bra.b	loop
.mod_up
	addq	#2,modulo(a5)
	bra.b	loop
.adr_up
	add.l	#VAL-LOVAL,src(a5)
.adr_up2
	addq.l	#LOVAL,src(a5)
	bra.b	loop
.adr_down
	sub.l	#VAL-LOVAL,src(a5)
.adr_down2
	subq.l	#LOVAL,src(a5)	
	bra.b	loop
.reset_modulo
	clr	modulo(a5)
	bra.b	loop
.switch_res
	bsr.w	SwitchRes

loop:
	move.l	himem(a5),d0
	cmp.l	src(a5),d0
	bge.b	.ok0
	moveq	#0,d0
	bra.s	.ok
.ok0	tst.l	src(a5)
	bhi.b	.ok1
.ok	move.l	d0,src(a5)
.ok1
	lea	info.txt(pc),a0
	lea	src(a5),a1
	moveq	#0,d0
	moveq	#10,d1
	bsr.w	printf

	move.l	src(a5),a0	;source: mémoire chip
	moveq	#0,d0
	move	modulo(a5),d1
	moveq	#0,d2			;x
	moveq	#20,d3			;y
	move	#WIDTH,d4		;Largeur de l'img a copier
	move	#230,d5			;Hauteur
	lea	rast(a5),a1		;Cible RastPort
	move.l	gfxbase(a5),a6
	jsr	BltTemplate(a6)
	jsr	WaitTOF(a6)
	bra.w	WaitLoop

CloseAll:
	move.l	planes(a5),a1
	move.l	#BUFSIZE,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)
restore
;	move	#$7fff,$96(a4)
	move.l	gfxbase(a5),a0
	move.l	38(a0),$80(a4)		;old coplist
	clr	$88(a4)
	move	olddma(a5),$96(a4)
fin	add	#VARSIZE,sp
	movem.l	(sp)+,d0-a6
	rts

GetRawKey:
	move.b	$bfec01,d0
	ror.b	#1,d0
	not.b	d0
	rts
SwitchRes:
	move.l	copadr(a5),a0
	clr.b	myres(a5)
	btst	#15,2(a0)
	bne.b	lo_res
	st	myres(a5)
	bra.b	hi_res
lo_res
	move.l	copadr(a5),a0
	move	#$38,ddfstart-coplist(a0)
	move	#$d0,ddfstop-coplist(a0)
	eor	#$8000,2(a0)
	rts
hi_res
	move.l	copadr(a5),a0
	move	#$3c,ddfstart-coplist(a0)
	move	#$d4,ddfstop-coplist(a0)
	or	#$8000,2(a0)
	rts

printf:
	movem.l	d0-a6,-(sp)
	lea	.pchr(pc),a2
	lea	strbuf(a5),a3
	move.l	a3,-(sp)
	movem	d0-d1,-(sp)
	move.l	4.w,a6
	jsr	RawDoFmt(a6)
	lea	rast(a5),a3
	move.l	a3,a1
	movem	(sp)+,d0-d1
	move.l	gfxbase(a5),a6
	jsr	Move(a6)
	move.l	(sp)+,a0
	move.l	a0,a1
	moveq	#-1,d0
.len	addq.l	#1,d0
	tst.b	(a0)+
	bne.b	.len
	move.l	a1,a0
	move.l	a3,a1
	jsr	Text(a6)
	movem.l	(sp)+,d0-a6
	rts
.pchr	move.b	d0,(a3)+
	rts

;ShowHelp:
;	bsr.b	hi_res		;on se met en Hires pour afficher le texte
;	lea	help.txt(pc),a0
;	bsr.b	print
;.w	btst	#6,$bfe001
;	bne.b	.w
;	bsr.b	cls
;	bra.w	WaitLoop

*** Sortir du texte
* <-- a0: adr texte (terminé par 0)
	IFD	BOOT
print
	movem.l	d0-a6,-(sp)
	move.l	a0,a4
	move.l	gfxbase(a5),a6
	lea	rast(a5),a3
	move.l	rp_Font(a3),a1
	move	tf_XSize(a1),charw(a5)
	move	tf_YSize(a1),charh(a5)
	addq	#1,charw(a5)
	addq	#2,charh(a5)

.bcl	move.l	a4,a0
	moveq	#-1,d0
.len	addq.l	#1,d0
	move.b	(a4)+,d1
	beq.b	.ret
	cmp.b	#$c,d1
	beq.b	.cls
	cmp.b	#$a,d1
	bne.b	.len
	bsr.b	Txt
	movem	xstart(a5),d0-d1
	bsr.b	Mov
	bra.b	.bcl
.ret	movem.l	(sp)+,d0-a6
	rts
.cls	bsr.b	Cls
	bra.b	.bcl

Mov:
	movem	d0-d1,xstart(a5)
	lea	rast(a5),a1
	move.l	gfxbase(a5),a6
	jsr	Move(a6)
	move	charh(a5),d0
	add	d0,ystart(a5)
	rts
Txt:
	lea	rast(a5),a1
	move.l	gfxbase(a5),a6
	jmp	Text(a6)
Cls:
	moveq	#0,d0
	moveq	#0,d1
	bsr.b	Mov
ClrSc:
	lea	rast(a5),a1
	move.l	gfxbase(a5),a6
	jmp	ClearScreen(a6)
	ENDC

*** DATA
coplist:
 DC.w $0100
res:
 dc.w HIRES
 dc.w $008E,$2981
 DC.w $0090,$29c1
 dc.w $0092
ddfstart:
 dc.w $3c
 DC.w $0094
ddfstop:
 dc.w $D4

 dc.w $0102,0
 dc.w $0108,0

 DC.w $0180,COL0
 dc.w $0182,COL1
 dc.w $0184,COL2
 dc.w $0186,COL3
planesptr:
 dc.w $00e0
hi1:dc.w 0
 dc.w $00e2
lo1:dc.w 0
 dc.w $00e4
hi2:dc.w 0
 dc.w $00e6
lo2:dc.w 0
 dc.w $00e8
hi3:dc.w 0
 dc.w $00ea
lo3:dc.w 0
 dc.w $00ec
hi4:dc.w 0
 dc.w $00ee
lo4:dc.w 0
 dc.w $00f0
hi5:dc.w 0
 dc.w $00f2
lo5:dc.w 0
 dc.w $00f4
hi6:dc.w 0
 dc.w $00f6
lo6:dc.w 0

 dc.w $FFFF,$FFFE	;fin de la liste copper
COPSIZE=*-coplist
BUFSIZE=PLANESIZE+COPSIZE

topaz8	dc.l	0
	dc.w	8
	dc.b	0
	dc.b	0

dosname:	dc.b "dos.library",0
info.txt:	dc.b "ShowMem 1.0 by F.BASSALER - Addr:%08lx Mod:%04x",0

End:
	dcb.b	512*2
