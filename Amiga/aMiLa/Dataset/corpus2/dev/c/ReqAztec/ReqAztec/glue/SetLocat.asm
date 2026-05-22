;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_SetLocation
_SetLocation:
	movem.l	a6/d2,-(sp)
	move.l	_ReqBase,a6
	movem.l	12(sp),d0/d1/d2
	jsr	-42(a6)
	movem.l	(sp)+,a6/d2
	rts

	end
