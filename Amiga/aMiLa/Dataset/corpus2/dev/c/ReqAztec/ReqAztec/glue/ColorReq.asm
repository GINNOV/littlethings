;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_ColorRequester
_ColorRequester:
	move.l	a6,-(sp)
	move.l	_ReqBase,a6
	move.l	8(sp),d0
	jsr	-90(a6)
	move.l	(sp)+,a6
	rts

	end
