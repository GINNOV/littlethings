;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_GetString
_GetString:
	movem.l	a6/a2,-(sp)
	move.l	_ReqBase,a6
	movem.l	12(sp),a0/a1/a2
	movem.l	24(sp),d0/d1
	jsr	-162(a6)
	movem.l	(sp)+,a6/a2
	rts

	end
