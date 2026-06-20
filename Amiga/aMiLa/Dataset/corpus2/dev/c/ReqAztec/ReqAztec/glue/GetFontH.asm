;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_GetFontHeightAndWidth
_GetFontHeightAndWidth:
	move.l	a6,-(sp)
	move.l	_ReqBase,a6
	jsr		-120(a6)
	move.l	(sp)+,a6
	rts

	end
