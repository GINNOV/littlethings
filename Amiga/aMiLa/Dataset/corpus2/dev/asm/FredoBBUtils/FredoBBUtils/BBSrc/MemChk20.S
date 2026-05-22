*** Bootblock Spécial:	MEMCHK	2.0
* Coded by Frédéric Bassaler '95

* Version 2.0: utilise une interface intuition.
* (uses an Intuition screen rather than a non-system display)

*** Au moment du boot:
* bouton DROIT de la souris  =>	MemChk
*	- examine les vecteurs d'execbase
*	- visualisation de la mémoire
* --> permet donc de détecter la présence d'un virus ou autre code résident

* Si les vecteurs de Reset ne sont pas à 0 au moment du boot,
* alors MemChk apparait

* FOR THE ENGLISH-SPEAKING:
*	This bootblock is some kind of 'Memory Check & Display' bootblock
*	It will only tell if a resident program is found in memory
*	and then you'll be able to check by yourself...
*
*	I used it on my system (write-protected) disk so it could tell
*	if a virus (or any other resident module) was in memory at boot time 
*
* HOLD RIGHT-MOUSE during boot to enter the program

	incdir	asm:/Include/
	include	equ.s
	include	exec/types.i
	include	graphics/text.i
	include	graphics/gfx.i
	include	graphics/rastport.i

	rsreset
intbase	rs.l	1
Scr	rs.l	1
rast	rs.l	1
XStart	rs.w	1
YStart	rs.w	1
diskio	rs.l	1
Offset	rs.l	1
Vectors	rs.l	12
TextPtr	rs.b	2000
VARSIZE	rs.w	0

DMPYStart=52
NCHR=70
NLINES=26
DMPSIZE=NCHR*NLINES

DBUG=0		;put 0 instead of 1 to disable DEBUG MODE

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
*** Mettre en place le contexte graphique (set up screen)
	move.l	4.w,a6
	move.l	$9c(a6),d6		;gfxbase

	lea	intname(pc),a1
	jsr	-408(a6)
	move.l	d0,intbase(a5)
	move.l	d0,a6
	lea	New.Screen(pc),a0
	jsr	OpenScreen(a6)
	move.l	d0,Scr(a5)
	move.l	d0,a0
	lea	84(a0),a0
	move.l	a0,rast(a5)

	move.l	d6,a6

	lea	topaz8(pc),a0
	move.l	154(a6),a1
	move.l	10(a1),(a0)	;ln_name: topaz.font
	jsr	OpenFont(a6)
	move.l	d0,a0
	move.l	d0,-(sp)
	move.l	rast(a5),a1
	jsr	SetFont(a6)
	move.l	(sp)+,a1
	jsr	CloseFont(a6)

	moveq	#10,d0
	moveq	#10,d1
	movem	d0-d1,XStart(a5)
	lea	main.txt(pc),a0
	bsr.w	print
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

;do a system reset (this is a dirty method!)
	move.l	#$f80000,$80.w
	trap	#0
; You should use ColdReboot() under 2.0+ systems

*** libérer tout
CloseAll:
	move.l	Scr(a5),a0
	move.l	intbase(a5),a6
	jsr	CloseScreen(a6)
	move.l	a6,a1
	move.l	4.w,a6
	jsr	CloseLibrary(a6)
fin
	lea	VARSIZE(sp),sp	;restitue la pile
	movem.l	(sp)+,d0-a6
Init
	IFEQ	DBUG
	move	#$f00,$dff180	;écran rouge pour avertir
	lea	dosname(pc),a1
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
	lea	TextPtr(a5),a3
	move.l	a3,-(sp)
	move.l	4.w,a6
	jsr	-522(a6)
	move.l	(sp)+,a0
*** Sortir du texte
* <-- a0: adr texte (terminé par 0)
print
	movem.l	d0-a6,-(sp)
	movem	XStart(a5),d0-d1
	move.l	d6,a6
	move.l	rast(a5),a3
readchr
	move.b	(a0)+,d7
	beq.b	printend
	cmp.b	#$a,d7			linefeed
	beq.b	lf
	bsr.b	prnt
	addq	#8,d0
	bra.b	readchr
lf
	addq	#8,d1
	move	XStart(a5),d0
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
printend
	movem	d0-d1,XStart(a5)
	movem.l	(sp)+,d0-a6
	rts

*** MemDump Ascii
* <-- a0: adresse de début
MemDmp:
	movem.l	d0-a6,-(sp)
	move.l	a0,Offset(a5)
.pr
	move.l	rast(a5),a3
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
	bsr.b	.txt
	move.l	a4,a0
	moveq	#NCHR,d4
	bsr.b	.txt
	add.l	d4,a0
	moveq	#0,d0
	addq	#8,d1
	bsr.b	Mov
	dbf	d5,.prlop

	movem.l	(sp)+,d0-a6
	rts
.txt
	movem.l	d0/d1/a0,-(sp)
	move.l	d4,d0
	bra.b	Txt

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

*** DATA
New.Screen:
	dc.w	0,0,640,-1,1,-1,$8000,$101
	dc.l	0,0,0,0

topaz8	dc.l	0
	dc.w	8
	dc.b	0,0

intname	dc.b "intuition.library",0
dosname	dc.b "dos.library",0

main.txt
 DC.B "MemChk 2.0 © F. Bassaler * "
 dc.b "LMB=Exit\ESC=ClrMem\Up,Down",$a,$a
 dc.b 0
vector.txt
 dc.b "Cold    %lx Cool %lx Warm %lx",$a
 dc.b "KickMem %lx Tag  %lx Chk  %lx",$a
 dc.b "VBL %lx"
 dc.b 0

 dc.b "WHEN BOOTING,HOLD <RMB> TO ENTER MEMCHK"

End:
	dcb.b	512*2,0
