;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_MakeString
_MakeString:
	movem.l	a6/a2/d2/d3,-(sp)
	move.l	_ReqBase,a6
	movem.l	20(sp),a0/a1/a2
	movem.l	32(sp),d0/d1/d2/d3
	jsr	-132(a6)
	movem.l	(sp)+,a6/a2/d2/d3
	rts

	end
