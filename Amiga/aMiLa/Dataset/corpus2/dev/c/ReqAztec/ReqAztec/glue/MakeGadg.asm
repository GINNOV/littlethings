;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_MakeGadget
_MakeGadget:
	move.l	a6,-(sp)
	move.l	_ReqBase,a6
	movem.l	8(sp),a0/a1
	movem.l	16(sp),d0/d1
	jsr	-126(a6)
	move.l	(sp)+,a6
	rts

	end
