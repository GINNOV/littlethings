* Bootblock Spécial:	BootDir V2.0
* Coded by Frédo (June '95)
*
* ESC pour sortir (boot normal)
* ESPACE/RETOUR pour Avancer/Reculer
* RETURN pour lire le répertoire racine (on peut changer de disk)
*
* Maintenir le bouton GAUCHE de la souris pendant le boot pour ne pas
* exécuter le programme
*
*
* FOR THE ENGLISH-SPEAKING:
* this bootblock displays the root directory of the disk it's installed on.
* this appeared useful to me, especially when i had no harddisk.
* It was coded to be as system-friendly as possible.
* Display may be buggy when filenames are too long, and some other bugs
* may exist.
*
* the keys:
* ESC to exit, SPACE/BACKSPACE to "navigate" through the pages
* RETURN to reread the directory (you can even change the disk before that)
* Hold the LEFT mouse button to skip the program.

	incdir	asm:/Include/
	include	equ.s

	rsreset
diskio	rs.l	1
gfxbase	rs.l	1
intbase	rs.l	1
scrhd	rs.l	1
scrwidth rs.w	1
scrheight rs.w	1
rport	rs.l	1
font	rs.l	1
fonty	rs.w	1
fontx	rs.w	1
buf	rs.l	1
lastblk	rs.l	1
VARSIZE	rs.w	0

BUFSIZE=$800
XSTART=1
YSTART0=18
YSTART=YSTART0+8
STATX=400
VOLPEN=2
DIRPEN=3
FILEPEN=1


;DBUG=0	;comment this to disable debug mode (when installing the bootblock)

	IFD	DBUG
	move.l	4.w,a6
	move.l	$9c(a6),d7	;execbase->gfxbase
	bra	RootDir
	ENDC

Start:
	dc.b	"DOS",0
	dc.b	"SUM",0
root	dc.l	$370	;rootblock

Main:
	btst	#6,$bfe001	;Lefmousebutton held?
	beq.s	Init		;if yes, skip dir

	movem.l	d0-a6,-(sp)
;	move.l	$9c(a6),a6	;execbase->gfxbase
;	move.l	a6,d7
;	moveq	#40,d6
;.wait	jsr	WaitTOF(a6)
;	dbf	d6,.wait

	bsr.s	RootDir
	movem.l	(sp)+,d0-a6
Init
	lea	dosname(pc),a1
	move.l	#"dos.",(a1)
	jsr	FindResident(a6)
;	tst.l	d0
;	beq.b	.err
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
;.err	moveq	#-1,d0
;	rts

* Directory du bloc racine en utilisant le trackdisk.device
* Display the root directory of the disk, using trackdisk.device
RootDir:
	move.l	a1,a4		;disk ioreq en A1
	lea	-VARSIZE(sp),sp	;alloc. variables on the stack
	move.l	sp,a5
	move.l	a4,(a5)		;sauver ioreq

	IFD	DBUG
	lea	diskport(pc),a1
	move.l	a1,a4
	move.l	4.w,a6
	move.l	276(a6),$10(a1)
	jsr	AddPort(a6)
	lea	diskreq(pc),a1
	move.l	a1,(a5)
	move.l	a4,14(a1)
	moveq	#0,d0
	moveq	#0,d1
	lea	trackname(pc),a0
	jsr	OpenDevice(a6)
	tst.l	d0
	bne.w	.FreeVars
	ENDC

.openint
	move.l	$9c(a6),d7	;execbase->gfxbase
	move.l	d7,gfxbase(a5)
	lea	intname(pc),a1
	move.l	4.w,a6
	jsr	-408(a6)
	move.l	d0,intbase(a5)
	move.l	d0,a6
* Ouvrir écran, charger palette..
* set up screen
.openscr
	lea	newscr(pc),a0
	pea	title(pc)
	move.l	(sp)+,20(a0)
	jsr	OpenScreen(a6)
	move.l	d0,scrhd(a5)
	beq.w	.clint
	move.l	d0,a3
	lea	44(a3),a0
	lea	mypal(pc),a1	;my palette
	moveq	#4,d0		;colorcount
	move.l	d7,a6
	jsr	LoadRGB4(a6)
	move.l	a3,a0
	move.l	12(a0),scrwidth(a5)
	lea	84(a0),a1
	move.l	a1,rport(a5)
	move.l	a1,a3
	moveq	#0,d0
	move.l	d0,d1
	jsr	SetDrMd(a6)
	lea	topaz.textattr(pc),a0
	move.l	154(a6),a1	;gfxbase DefaultFont
	move.l	10(a1),(a0)	;font name
	jsr	OpenFont(a6)
	move.l	d0,font(a5)
	beq.s	.nofont
.ok	move.l	d0,a0
	move	20(a0),fonty(a5)
	move	24(a0),fontx(a5)
	move.l	a3,a1
	jsr	SetFont(a6)
.nofont
* allocate buffer and display directory
.dir
	move.l	#BUFSIZE,d0
	move.l	#$10002,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,buf(a5)
	beq.w	.nobuf
.getroot
	move.l	root(pc),d0	;root blk
	bsr.w	ReadBlk
	bne.w	.clall		;err?

	move.l	buf(a5),a0
	move.l	a0,a4
	moveq	#2,d0		;type: short
	cmp.l	(a0),d0
	bne.w	.clall
	moveq	#1,d0		;sec.type: root
	cmp.l	508(a0),d0
	bne.w	.clall
	move.l	12(a0),d0	;hashtable size-1
	subq.l	#1,d0
	lea	24(a0),a0
	move.l	buf(a5),a3
	lea	$200(a3),a3
	move.l	a3,a2
	moveq	#0,d7
.cop	move.l	(a0)+,d1
	beq.b	.no
	move.l	d1,(a3)+
	addq	#1,d7		;nbre d'entrées
.no	dbf	d0,.cop
	subq	#1,d7
	move.l	a4,a3
* écrire nom du disk (print diskname)
	moveq	#XSTART,d5
	moveq	#YSTART,d6

	lea	$1b0(a4),a4
	moveq	#0,d3
	move.b	(a4)+,d3
	move	d5,d0
	moveq	#YSTART0,d1
	moveq	#VOLPEN,d2		;pen
	bsr.w	print

	move.l	a2,lastblk(a5)
.exam
	moveq	#$45,d4		;ESC=exit
	bsr.w	GetRawCode
	cmp.b	d0,d4
	beq.w	.abort

	move.l	(a2)+,d0	;block #
.chain
	bsr.w	ReadBlk		;read block
	bne.w	.clall		;si read err -> fin
* afficher les noms de fichiers
* display filenames
.aff
	move.l	buf(a5),a0
	moveq	#-3,d0
	moveq	#2,d1
	cmp.l	(a0),d1
	bne.b	.nofilesysblk
	cmp.l	508(a0),d0
	beq.b	.file
	moveq	#DIRPEN,d2		;pen color for dirs
	bra.b	.aff2
.file
	moveq	#FILEPEN,d2		;pen color for files
.aff2
	lea	$1b0(a0),a4
	moveq	#0,d3
	move.b	(a4)+,d3	;name length in d3
	move	d5,d0
	move	d6,d1
	bsr.w	print		;print name
	moveq	#29,d1
	mulu	fontx(a5),d1
	add	d1,d5
	cmp	scrwidth(a5),d5
	ble.b	.nxtline
	moveq	#XSTART,d5
	add	fonty(a5),d6
	move	scrheight(a5),d0	;screen height
	sub	fonty(a5),d0
	cmp	d0,d6
;	cmp	#100,d6
	ble.b	.nxtline
	bsr.w	Clr
	moveq	#-1,d0
	cmp.l	d0,d4
	beq.b	.abort
.nxtline
	move.l	$1f0(a3),d0	;hash chain?
	bne.b	.chain
	dbf	d7,.exam
.nofilesysblk
	bsr.w	MotOff		;stop drive's motor

* wait for a key
.wait
	bsr.b	GetRawCode
	cmp.b	#$44,d0		;RETURN
	bne.b	.back
;re-read dir
	moveq	#YSTART0,d1
	bsr.w	Clr2
	bra.w	.getroot
.back
	cmp.b	#$41,d0		;BACKSPACE
	bne.b	.esc
	moveq	#YSTART,d1
	bsr.w	Clr2
	move.l	lastblk(a5),a2
	bra.w	.exam
.esc	cmp.b	d0,d4
	bne.b	.wait
.abort
	bsr.w	MotOff

* close and free all
.clall
	move.l	buf(a5),a1
	move.l	#BUFSIZE,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)
.nobuf
.clfnt
	move.l	font(a5),d0
	beq.b	.clscr
	move.l	d0,a1
	move.l	gfxbase(a5),a6
	jsr	CloseFont(a6)
.clscr
	move.l	scrhd(a5),a0
	move.l	intbase(a5),a6
	jsr	CloseScreen(a6)
.clint
	move.l	intbase(a5),a1
	move.l	4.w,a6
	jsr	CloseLibrary(a6)

	IFD	DBUG
	move.l	(a5),a1
	move.l	14(a1),a4
	jsr	CloseDevice(a6)
	move.l	a4,a1
	jsr	RemPort(a6)
	ENDC
.FreeVars
	lea	VARSIZE(sp),sp	;restore stack
.end	rts

* get raw keycode
GetRawCode
	move.b	$bfec01,d0
	ror.b	#1,d0
	not.b	d0
	rts

Clr:
	movem.l	d0-d3/a0-a6,-(sp)
	move.l	a2,d4
	move	d5,d0
	move	d6,d1
	lea	moretxt(pc),a4
	moveq	#VOLPEN,d2
	moveq	#MORETXTLEN,d3
	bsr.b	print
	bsr.w	MotOff
.w	bsr.b	GetRawCode
	cmp.b	#$40,d0		;SPACE
	beq.b	.done
	cmp.b	#$45,d0		;ESC
	beq.b	.exit
	cmp.b	#$41,d0		;BACKSPACE
	bne.b	.w
	move.l	lastblk(a5),d4
	bra.b	.done
.exit
	moveq	#-1,d4
.done
	moveq	#YSTART,d1
	bsr.b	Clr2
.f	movem.l	(sp)+,d0-d3/a0-a6
	move.l	d4,a2
	rts
Clr2
	movem.l	d0-a6,-(sp)
	moveq	#0,d0
	bsr.b	Mov
	jsr	ClearScreen(a6)
	movem.l	(sp)+,d0-a6
	moveq	#YSTART,d6
	rts
* Ecrire une ligne avec Text()
* dans la couleur de son choix
* <- a4: adr texte	d0: x	d1: y	d2: pen	d3: nbre de caract.
print:
	movem.l	d0-a6,-(sp)
	bsr.b	Mov
	move.l	a3,a1
	move.l	d2,d0
	jsr	SetAPen(a6)
	move.l	a4,a0
	move.l	d3,d0
	move.l	a3,a1
	jsr	Text(a6)
	movem.l	(sp)+,d0-a6
	rts
Mov:
	move.l	rport(a5),a1
	move.l	a1,a3
	move.l	gfxbase(a5),a6
	jmp	Move(a6)

* Lire un block (read 1 disk block)
* <-- d0: n° de block (block number)
ReadBlk:
	movem.l	d1-a6,-(sp)
	move.l	(a5),a1
	move.l	d0,d4
	move	#2,28(a1)
	move.l	#$200,36(a1)	;io_length: 1 blk
	move.l	buf(a5),40(a1)	;io_data
	moveq	#9,d1
	lsl.l	d1,d4		;io_offset=n°blk*512
	move.l	d4,44(a1)
	move.l	4.w,a6
	jsr	DoIO(a6)
	movem.l	(sp)+,d1-a6
	tst.l	d0
	rts
* turn drive's motor off
MotOff
	move.l	(a5),a1
	move	#9,28(a1)
	clr.l	36(a1)
	move.l	4.w,a6
	jmp	DoIO(a6)

*** DATA
newscr:
	dc.w	0,0
	dc.w	640,-1
	dc.w	2
	dc.b	0,1
	dc.w	$8000
	dc.w	$1	;type
	dc.l	0	;topaz.textattr
	dc.l	0	;title
	dc.l	0
	dc.l	0
mypal	dc.w	$bb9,$0,$fff,$0f0
topaz.textattr
	dc.l	0
	dc.w	8
	dc.b	0,0

intname	dc.b "intuit"
dosname	dc.b "ion.library",0
moretxt	dc.b "<BACK/SPACE> "
MORETXTLEN=*-moretxt
title	dc.b "BBDir 2.0 ©1995 Frédéric Bassaler",0

 dc.b "HOLD LEFTMOUSE DURING BOOT TO SKIP DIR."

	IFD	DBUG
trackname	dc.b	"trackdisk.device",0
	even
diskport	dcb.b	34,0
diskreq		dcb.b	56,0
	ENDC

End:
	dcb.b 512*2,0
