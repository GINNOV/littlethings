;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_SetSize
_SetSize:
	move.l	a6,-(sp)
	move.l	_ReqBase,a6
	movem.l	8(sp),d0/d1
	jsr	-36(a6)
	move.l	(sp)+,a6
	rts

	end
