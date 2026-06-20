;:ts=8

		section	text,code

		xref	_ReqBase
		xdef	_Format
_Format:
		move.l	a2,-(sp)
		move.l	a6,-(sp)
		move.l	12(sp),a2
		move.l	16(sp),a0
		lea		20(sp),a1
		move.l	_ReqBase,a6
		jsr		-54(a6)			; Format
		move.l	(sp)+,a6
		move.l	(sp)+,a2
		rts
