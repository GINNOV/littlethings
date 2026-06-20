;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_DrawBox
_DrawBox:
	movem.l	a6/d2/d3,-(sp)
	move.l	_ReqBase,a6
	move.l	16(sp),a1
	movem.l	20(sp),d0/d1/d2/d3
	jsr	-96(a6)
	movem.l	(sp)+,a6/d2/d3
	rts

	end
