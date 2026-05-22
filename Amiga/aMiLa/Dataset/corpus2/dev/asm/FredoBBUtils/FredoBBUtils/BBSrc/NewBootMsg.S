*************** Bootblock spécial ********************
* Afficher un nouveau message à la place de l'habituel
* 'Copyright © 1985 Commodore-Amiga ..'

* Will NOT work under 2.0+

	incdir	asm:/Include/
	include	equ.s
	include	exec/types.i
;	include	graphics/text.i
;	include	graphics/gfx.i
;	include	graphics/rastport.i

	rsreset
NewVector rs.l	1
;intbase	rs.l	1
VARSIZE	rs.w	0

;DBUG=0

Start:
	dc.b	"DOS",0
	dc.l	0,$370
Main:
	IFD	DBUG
	move.l	4.w,a6
	ENDC
	movem.l	d0-a6,-(sp)
	lea	-VARSIZE(sp),sp	;on utilise la pile comme base des variables
	move.l	sp,a5		;VarBase en a5

	btst	#6,$bfe001
	beq.s	fin

	move.l	#CodeSize,d0
	moveq	#1,d1
	jsr	AllocMem(a6)
	move.l	d0,NewVector(a5)
	beq.s	fin

	lea	gfxname(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,d7
	beq.s	fin
	move.l	d0,a1
	move	#Text,a0
.v	move.l	NewVector(a5),d0
	jsr	SetFunction(a6)
	lea	OldVector(pc),a0
	move.l	d0,(a0)

	lea	New.Print(pc),a0
	move.l	NewVector(a5),a1
	move	#CodeSize,d0
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop

	move.l	d7,a1
	jsr	CloseLibrary(a6)
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

New.Print:
* restore old Vector
	movem.l	d0-a6,-(sp)
	move	#Text,a0
	move.l	OldVector(pc),d0
	move.l	4.w,a6
	jsr	SetFunction(a6)
	movem.l	(sp)+,d0-a6
* print new text
	lea	new.txt(pc),a0

.jmp	dc.w	$4ef9	;instruction jmp
OldVector:dc.l	0

new.txt:dc.b "Copyright © 1985-96 Frédéric Bassaler, Inc.",$a

CodeSize=*-New.Print

;intname		dc.b	'intuition.library',0
gfxname		dc.b	'graphics.library',0
dos.name	dc.b	'dos.library',0
expansion.name	dc.b	'expansion.library',0

End:
	dcb.b	512,0
