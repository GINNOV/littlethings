*** BootBlock Intro 3 par Frédo!
* affiche un message en tapant lettre par lettre
* (cf. INFECT bootblock intro)

* another simpler one...

	incdir	asm:/Include/
	include	equ.s
	include	exec/types.i
	include	graphics/text.i
	include	graphics/gfx.i
	include	graphics/rastport.i

	rsreset
planes	rs.l	1
;gfxbase	rs.l	1
olddma	rs.w	1
;xstart	rs.w	1
;ystart	rs.w	1
scrw	rs.w	1
scrh	rs.w	1
charw	rs.w	1
charh	rs.w	1
xc	rs.w	1
yc	rs.w	1
rast	rs.b	rp_SIZEOF
bmap	rs.b	bm_SIZEOF
txtptr	rs.b	2
VARSIZE	rs.w	0

WIDTH=320*1
HEIGHT=256
DEPTH=1
PLSIZE=(WIDTH/8)*HEIGHT
PLANESIZE=PLSIZE*DEPTH

COL0=$666
COL1=$f77
COL2=$66d
COL3=$777

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
;	lea	bm_Planes(a0),a0
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
	move	tf_XSize(a1),charw(a5)
	move	tf_YSize(a1),charh(a5)
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
	move	2(a4),olddma(a5)
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

	lea	intro.txt(pc),a3
	moveq	#0,d0
	moveq	#10,d1
	movem	d0-d1,xc(a5)
loop:
	btst	#6,$bfe001
	beq.s	closeall

	move.b	(a3)+,d7
	beq.s	.end_of_txt
	cmp.b	#$a,d7
	beq.s	.lf
.ty
	lea	rast(a5),a1
	movem	xc(a5),d0-d1
	move	d0,d2
	add	charw(a5),d2
	move	d2,xc(a5)
	jsr	Move(a6)
	lea	txtptr(a5),a0
	move.b	d7,(a0)
	lea	rast(a5),a1
	moveq	#1,d0
	jsr	Text(a6)

	jsr	WaitTOF(a6)

	bra.s	loop

.lf	clr	xc(a5)
	move	charh(a5),d0
	add	yc(a5),d0
	move	d0,yc(a5)
	bra.s	loop
.end_of_txt
	subq.l	#1,a3
	bra.s	loop

closeall
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

Init
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
	jsr	-96(a6)
	tst.l	d0
	beq.b	.nodos
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
.nodos	moveq	#-1,d0
	rts

*** Effacer l'écran
;ClrSc
;	movem.l	d0-a6,-(sp)
;	lea	rast(a5),a1
;	move.l	gfxbase(a5),a6
;	jsr	ClearScreen(a6)
;	movem.l	(sp)+,d0-a6
;	rts

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

intro.txt
 DC.B "________________________________________",$A,$a
 dc.b "FREDO'S BACK AGAIN WIZ ANOTHER BOOTINTRO",$A,$a
 DC.B "     THIS IS BOOTINTRO NUMBER 3",$A,$a
 dc.b "THIS LITTLE THINGY USES A FUNNY",$a
 dc.b "TEXT-TYPING ROUTINE, AS YOU CAN SEE...",$A
 dc.b "YOU CAN WRITE A QUITE LONG TEXT.",$A,$a
 DC.B "PLEASE DON'T FORGET...",$A
 DC.B "MY MOTTO IS: «SIMPLE BUT EFFICIENT!!»",$A
 dc.b "NOW THINGS ARE CLEAR!",$A
 DC.B "WATCH OUT FOR MORE BOOTBLOCK INTROS",$A
 DC.B "FROM THE MAD CODE OPTIMIZER - FREDO!",$A,$a
 DC.B "________________________________________",$A
 dc.b 0

End:
	dcb.b	512,0
