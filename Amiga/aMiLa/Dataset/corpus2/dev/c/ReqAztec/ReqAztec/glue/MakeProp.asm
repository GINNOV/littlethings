;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_MakeProp
_MakeProp:
	movem.l	a6/d2,-(sp)
	move.l	_ReqBase,a6
	move.l	12(sp),a0
	movem.l	16(sp),d0/d1/d2
	jsr	-138(a6)
	movem.l	(sp)+,a6/d2
	rts

	end
