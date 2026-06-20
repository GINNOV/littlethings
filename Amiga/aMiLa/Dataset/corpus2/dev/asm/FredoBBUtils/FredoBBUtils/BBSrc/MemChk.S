*** Bootblock Spécial:	MEMCHK	1.0
* Coded by Frédéric Bassaler '95

*** Au moment du boot:
* bouton DROIT de la souris  =>	MemChk
*	- examine les vecteurs d'execbase
*	- visualisation de la mémoire
* --> permet donc de détecter la présence d'un virus ou autre code résident

* Si les vecteurs de Reset ne sont pas à 0 au moment du boot,
* alors MemChk apparait

*
* ENGLISH-SPEAKING PEOPLE PLEASE READ MemChk20.S
*

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
Xstart	rs.w	1
Ystart	rs.w	1
diskio	rs.l	1
Offset	rs.l	1
Vectors	rs.l	12
rast	rs.b	rp_SIZEOF
bmap	rs.b	bm_SIZEOF
VARSIZE	rs.w	0

Width=320*2
Height=256
Depth=1
PlaneSize=((Width/8)*Height)*Depth

DMPYStart=54
NCHR=70
NLINES=26
DMPSIZE=NCHR*NLINES

COL0=$b88
COL1=$000

DBUG=0	;1=debug enabled

Start:
	IFEQ	DBUG
	dc.b	"DOS",0
	dc.l	0
	dc.l	$370
	ENDC

	IFEQ	DBUG
	tst.l	46(a6)
	bne.b	MemChk
	tst.l	550(a6)
	bne.b	MemChk
	btst	#10,$dff016
	bne.w	Init
	ENDC
MemChk
	movem.l	d0-a6,-(sp)
	lea	-VARSIZE(sp),sp	;on utilise la pile comme base des variables
	move.l	sp,a5		;VarBase en a5

* éteindre moteur
;	IFEQ	DBUG
;	move.l	a1,DiskIo(a5)
;	bsr.w	MotorOff
;	ENDC

	IFNE	DBUG
	move.l	4.w,a6
	ENDC
*** Mettre en place le contexte graphique
* Allouer buffer pour bitplanes & coplist
	move.l	#BufSize,d0
	moveq	#2,d1
	jsr	AllocMem(a6)
	move.l	d0,(a5)
	move.l	d0,d4

	move.l	$9c(a6),d6		;gfxbase en d6

	lea	rast(a5),a1
	move.l	a1,-(sp)
	move.l	d6,a6
	jsr	InitRastPort(a6)

	lea	bmap(a5),a0
	move.l	d4,bm_Planes(a0)	;adresse des bitplanes
	move.l	(sp)+,a1
	move.l	a0,rp_BitMap(a1)
	moveq	#Depth,d0
	move	#Width,d1
	move	#Height,d2
	jsr	InitBitMap(a6)

	lea	topaz8(pc),a0
	move.l	154(a6),a1
	move.l	10(a1),(a0)	;ln_name: topaz.font
	jsr	OpenFont(a6)
	move.l	d0,a0
	lea	rast(a5),a1
	jsr	SetFont(a6)

	bsr.w	ClrSc
	lea	main.txt(pc),a0
	bsr.w	print

	lea	$dff000,a4
	move	$02(a4),olddma(a5)
	or	#$8000,olddma(a5)
	move	#$7fff,$96(a4)		;bloquer DMA
	lea	coplist(pc),a0
* adresse des bitplanes
	move.l	(a5),d0		;planes(a5)
	move.l	d0,a1
	move	d0,lo1-coplist(a0)
	swap	d0
	move	d0,hi1-coplist(a0)
* copier coplist en mém chip
	lea	PlaneSize(a1),a1
	move.l	a1,a2
	moveq	#(CopSize/4)-1,d0
.cop
	move.l	(a0)+,(a1)+
	dbf	d0,.cop
	move.l	a2,$80(a4)	;adresse de notre coplist
	clr	$88(a4)
	move	#%1000011111010000,$96(a4)	;canaux DMA
********************************************************
	move.l	4.w,a6
	lea	Vectors(a5),a0
	move.l	a0,a1
	move.l	a0,a3
	lea	42(a6),a2
	REPT	3
	move.l	(a2)+,(a0)+
	ENDR

	lea	546(a6),a2
	REPT	3
	move.l	(a2)+,(a0)+
	ENDR
	move.l	144(a6),(a0)+	;IntVector: VertBlank Interrupt
	moveq	#-1,d0		;-1=fin
	move.l	d0,(a0)
	lea	vector.txt(pc),a0
	bsr.w	RawPrint

*** AsciiDump de la mémoire 'occupée' par le code résident
	move.l	46(a6),d0	;coolcapture: pointeur sur prg résident
	bne.b	.dmp
	move.l	550(a6),d0	;kicktagptr
	bne.b	.dmp
	moveq	#0,d0
.dmp	move.l	d0,a0
dmp
	bsr.w	MemDmp
MainLoop:
.z
	move.l	Offset(a5),a0
	move.b	$bfec01,d0
	ror.b	#1,d0
	not.b	d0		;code rawkey
;	cmp.b	#$17,d0		;I
;	bne.b	.z1
;	bsr.w	Install
;	bra.b	.z
.z1	btst	#6,$bfe001
	beq.b	CloseAll
;	cmp.b	#$40,d0
;	beq.b	.next_vec
	cmp.b	#$45,d0		;Esc
	beq.b	Reset
	cmp.b	#$4d,d0
	beq.b	.more
	cmp.b	#$4c,d0
	bne.b	.z
.less
	sub	#DMPSIZE,a0
	bra.b	dmp
.more
	add	#DMPSIZE,a0
	bra.b	dmp
;.next_vec
;	move.l	(a3)+,d0
;	moveq	#-1,d1
;	cmp.l	d0,d1
;	bne.b	.nxt
;	lea	Vectors(a5),a3
;	bra.b	.z
;.nxt	move.l	d0,a0
;	bra.b	dmp
*** Effacer les vecteurs de reset & rebooter
Reset:
	clr.l	46(a6)		;coolcapture
	clr.l	546(a6)		;kickmemptr
	clr.l	550(a6)		;kicktagptr
	clr.l	554(a6)		;kickchecksum
Reset2
	IFNE	DBUG
	bra.b	CloseAll
	ENDC
	move.l	#$f80000,$80.w
	trap	#0
*** libérer tout
CloseAll:
	move.l	(a5),a1
	move.l	#BufSize,d0
	jsr	FreeMem(a6)
	move.l	d6,a1
	move.l	38(a1),$80(a4)
	clr	$88(a4)
	move	olddma(a5),$96(a4)
fin
	lea	VARSIZE(sp),sp	;restitue la pile
	movem.l	(sp)+,d0-a6
Init
	IFEQ	DBUG
	move	#COL0,$dff180
	lea	dosname(pc),a1
;	move.l	#' dos',(a1)
;	addq.l	#1,a1
	jsr	-96(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	ENDC
	moveq	#0,d0
	rts

PutChr	move.b	d0,(a3)+
	rts
*** Formatage & sortie de texte
* <-- a0: format a1: data
RawPrint:
	lea	PutChr(pc),a2
	move.l	(a5),a3
	lea	TextPtr(a3),a3
	move.l	a3,-(sp)
	move.l	4.w,a6
	jsr	-522(a6)
	move.l	(sp)+,a0
*** Sortir du texte
* <-- a0: adr texte (terminé par 0)
print
	movem.l	d0-a6,-(sp)
	movem	Xstart(a5),d0-d1
	move.l	d6,a6
	lea	rast(a5),a3
readchr
	move.b	(a0)+,d7
	beq.b	PrintEnd
	cmp.b	#$a,d7			linefeed
	beq.b	lf
	bsr.b	prnt
	addq	#8,d0
	bra.b	readchr
lf
	addq	#8,d1
	move	Xstart(a5),d0
	bsr.b	Mov
	bra.b	readchr
prnt
	bsr.b	Mov
	movem.l	a0/d0/d1,-(sp)
	subq.l	#1,a0
	moveq	#1,d0
Txt	move.l	a3,a1
	jsr	Text(a6)
	bra.b	movf
Mov
	movem.l	a0/d0/d1,-(sp)
	move.l	a3,a1
	jsr	Move(a6)
movf	movem.l	(sp)+,a0/d0/d1
	rts
PrintEnd
	movem	d0-d1,Xstart(a5)
	movem.l	(sp)+,d0-a6
	rts
*** Effacer l'écran
ClrSc
	movem.l	d0-a6,-(sp)
	move.l	(a5),a0		;planes(a5)
	move	#(PlaneSize/4)-1,d0
.clr	clr.l	(a0)+
	dbf	d0,.clr
	moveq	#10,d0		;Xstart
	moveq	#10,d1		;Ystart
	bra.b	PrintEnd

*** MemDump Ascii
* <-- a0: adresse de début
MemDmp:
	movem.l	d0-a6,-(sp)
	move.l	a0,Offset(a5)
.pr
	lea	rast(a5),a3
	moveq	#0,d0
	moveq	#DMPYStart,d1
	move.l	d6,a6
	bsr.b	Mov

	move.l	a0,a4
	moveq	#NLINES-1,d5
.prlop
	moveq	#9,d4
	move.l	(a5),a1
	lea	TextPtr(a1),a1
	move.l	a1,-(sp)
	move.l	a0,d7
	bsr.b	Long2Hex
	move.b	#$20,(a1)+
	move.l	(sp)+,a1
	move.l	a0,a4
	move.l	a1,a0
	bsr.b	.Txt
	move.l	a4,a0
	moveq	#NCHR,d4
	bsr.b	.Txt
	lea	NCHR(a0),a0
	moveq	#0,d0
	addq	#8,d1
	bsr.b	Mov
	dbf	d5,.prlop

	movem.l	(sp)+,d0-a6
	rts
.Txt
	movem.l	d0/d1/a0,-(sp)
	move.l	d4,d0
	bra.w	Txt

*** Hex --> HexString
* <-- d7: long, a1: outputstr
Long2Hex:
	movem.l	d0-d2/a0,-(sp)
	moveq	#7,d2
.bcl	rol.l	#4,d7
	move	d7,d1
	and.b	#$0f,d1
	add.b	#$30,d1
	cmp.b	#$3a,d1
	bcs.b	.ok
	addq.b	#7,d1
.ok	move.b	d1,(a1)+
	dbf	d2,.bcl
	movem.l	(sp)+,d0-d2/a0
	rts

;Install:
;	move.l	diskio(a5),a1
;	move	#3,28(a1)
;	bsr.b	ins
;	move	#4,28(a1)
;	bsr.b	ins
;MotorOff:
;	move	#9,28(a1)
;	clr.l	36(a1)
;	jmp	DoIo(a6)
;ins
;	lea	Start(pc),a0
;	move.l	a0,40(a1)
;	move.l	#$400,36(a1)
;	clr.l	44(a1)
;	move.l	4.w,a6
;	jmp	DoIo(a6)

*** DATA
LORES=$1200
HIRES=LORES!$8000
LACE=4

coplist:
 DC.w $100,HIRES
 dc.w $8E,$2981
 DC.w $90,$29c1
 dc.w $92,$3c
 DC.w $94,$D4
 DC.w $180,COL0
 dc.w $182,COL1
 dc.w $e0
hi1:
 dc.w 0
 dc.w $e2
lo1:
 dc.w 0
; dc.w $580f,$fffe
; dc.w $180,$0777
; dc.w $182,$0fff
; dc.w $ffdf,$fffe
; dc.w $ff0f,$fffe
; dc.w $180,COL0
 dc.w $FFFF,$FFFE	;fin de la liste copper
CopSize=*-coplist
TextPtr=PlaneSize+CopSize
BufSize=TextPtr+6000	;buffer pour les sorties texte

topaz8	dc.l	0
	dc.w	8
	dc.b	0,0
;gfxname	dc.b "grap"
dosname	dc.b "dos.library",0

main.txt
 DC.B "MemChk 1.0 by Frédéric Bassaler.  "
 dc.b "LMB=Exit/ESC=CLR MEM/Up,Down",$a,$a
 dc.b 0
vector.txt
 dc.b "Cold=%lx Cool=%lx Warm=%lx",$a
 dc.b "KickMem=%lx Tag=%lx Chk=%lx",$a
 dc.b "VertB=%lx"
 dc.b 0

 dc.b "WHILE BOOTING: RMB = MEMCHK"

End:
	dcb.b	512*2,0
