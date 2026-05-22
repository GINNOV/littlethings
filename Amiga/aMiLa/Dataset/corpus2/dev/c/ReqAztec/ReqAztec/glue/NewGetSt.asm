;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_NewGetString
_NewGetString:
	move.l	a6,-(sp)
	move.l	_ReqBase,a6
	move.l	8(sp),a0
	jsr	-198(a6)
	move.l	(sp)+,a6
	rts

	end
