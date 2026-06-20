;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_LinkPropGadget
_LinkPropGadget:
	movem.l	a6/a3/d2/d3/d4,-(sp)
	move.l	_ReqBase,a6
	movem.l	24(sp),a0/a3
	movem.l	32(sp),d0/d1/d2/d3/d4
	jsr	-156(a6)
	movem.l	(sp)+,a6/a3/d2/d3/d4
	rts

	end
