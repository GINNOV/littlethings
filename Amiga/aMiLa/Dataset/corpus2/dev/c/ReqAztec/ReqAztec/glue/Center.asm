;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_Center
_Center:
	move.l	a6,-(sp)
	move.l	_ReqBase,a6
	move.l	8(sp),a0
	movem.l	12(sp),d0/d1
	jsr	-30(a6)
	move.l	(sp)+,a6
	rts

	end
