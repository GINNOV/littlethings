************* Bootblock spécial *****************
* AmigaDOS PAL Window boot

	incdir	asm:/Include/
	include	equ.s
	include	exec/types.i
	include	exec/libraries.i
	include	intuition/intuition.i
;	include	graphics/text.i
;	include	graphics/gfx.i
;	include	graphics/rastport.i

	rsreset
newvector rs.l	1
;intbase	rs.l	1
VARSIZE	rs.w	0

;DBUG=0

Start:
	dc.b	"DOS",0
	dc.l	0,$370
Main:
	movem.l	d0-a6,-(sp)
	lea	-VARSIZE(sp),sp	;on utilise la pile comme base des variables
	move.l	sp,a5		;VarBase en a5

	IFD	DBUG
	move.l	4.w,a6
	ENDC

	btst	#6,$bfe001
	beq.s	fin

	move.l	#CODESIZE,d0
	moveq	#1,d1
	jsr	AllocMem(a6)
	move.l	d0,newvector(a5)
	beq.s	fin

	lea	intname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,d7
	beq.s	fin
	move.l	d0,a1
	move	#OpenWindowTagList,a0
	cmp	#36,LIB_VERSION(a1)	;OS 2.0+ ?
	bge.s	.v
	move	#OpenWindow,a0
.v	lea	Vector(pc),a2
	move	a0,(a2)
	move.l	newvector(a5),d0
	jsr	-420(a6)	;SetFunction()
	lea	OldVector(pc),a0
	move.l	d0,(a0)

	lea	new.open(pc),a0
	move.l	newvector(a5),a1
	move	#CODESIZE,d0
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop

	move.l	d7,a1
	jsr	-414(a6)
fin
	lea	VARSIZE(sp),sp	;restitue la pile
	movem.l	(sp)+,d0-a6

Init:
	lea	expansion.name(pc),a1
	moveq	#37,d0
	move.l	4.w,a6
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
	rts

new.open:
;	movem.l	a0/a1,-(sp)
;	move.l	nw_Title(a0),a0
;	lea	oldname(pc),a1
;	bsr.s	StrCmp
;	movem.l	(sp)+,a0/a1
;	tst.l	d0
;	bne.s	.jmp
	move	#256,nw_Height(a0)
	pea	newname(pc)
	move.l	(sp)+,nw_Title(a0)

	movem.l	d0-a6,-(sp)
	move	Vector(pc),a0
	move.l	OldVector(pc),d0
	move.l	a6,a1
	move.l	4.w,a6
	jsr	SetFunction(a6)
	movem.l	(sp)+,d0-a6
.jmp
	dc.w	$4ef9	;jmp
OldVector:dc.l	0
Vector:	dc.w 0

;StrCmp:
;	movem.l	d1-d2/a0-a1,-(sp)
;	moveq	#0,d0
;.loop	move.b	(a0)+,d1
;	beq.s	.eos1
;	move.b	(a1)+,d2
;	beq.s	.sup
;	cmp.b	d2,d1
;	beq.s	.loop
;	bcs.s	.inf
;.sup	moveq	#1,d0
;	bra.s	.ret
;.eos1	tst.b	(a1)+
;	beq.s	.ret
;.inf	moveq	#-1,d0
;.ret	movem.l	(sp)+,d1-d2/a0-a1
;	rts

;oldname:dc.b "AmigaDOS",0
newname:dc.b "AmigaDOS (PAL Window boot 1.0 by F.BASSALER)",0
CODESIZE=*-new.open

intname		dc.b	'intuition.library',0
dos.name	dc.b	'dos.library',0
expansion.name	dc.b	'expansion.library',0

 DC.B " AMIGADOS PAL WINDOW BOOT V1.0, "
 DC.B "CODED BY FREDERIC BASSALER."
 dc.b " THIS BOOTBLOCK FORCES THE INITIAL CLI "
 DC.B "TO OPEN A PAL (256 PIXELS HEIGHT) WINDOW. "
 DC.B "PRESS THE LEFTMOUSEBUTTON DURING BOOT TO CANCEL THIS. "
 DC.B "IF YOU ARE INTERESTED IN CODING & SWAPPING BOOTPROGRAMS, "
 DC.B "WRITE TO: FREDERIC BASSALER - LA SERRE - 19500 COLLONGES - "
 DC.B "FRANCE.     "

End:
	dcb.b	512,0
