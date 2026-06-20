; shoogly loader by Kyzer/CSG
; for developing trackmo routines

FETCHMODE=1
NO_MESSAGES=1
NO_VBLSERVER=1
NO_FILESYSTEM=1
PREDEMO=1
POSTDEMO=1
	include	cados.asm

	get.l	seg,a6
	add.l	a6,a6
	add.l	a6,a6
	jmp	4(a6)

_PreDemo
	getbase	dos
	get.l	arg_ptr,a0
	move.l	a0,d1
	jsr	-150(a6)	; _LVOLoadSeg
	move.l	d0,seg
	beq.s	.none
	moveq	#0,d0
	rts
.none	moveq	#-1,d0
	rts

_PostDemo
	move.l	seg,d1
	getbase	dos
	jmp	-156(a6)	; _LVOUnLoadSeg

seg	dc.l	0

