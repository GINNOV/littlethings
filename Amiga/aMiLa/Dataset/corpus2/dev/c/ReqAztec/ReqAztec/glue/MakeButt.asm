;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_MakeButton
_MakeButton:
	movem.l	a6/a2/d2,-(sp)
	move.l	_ReqBase,a6
	movem.l	16(sp),a0/a1/a2
	movem.l	28(sp),d0/d1/d2
	jsr	-102(a6)
	movem.l	(sp)+,a6/a2/d2
	rts

	end
