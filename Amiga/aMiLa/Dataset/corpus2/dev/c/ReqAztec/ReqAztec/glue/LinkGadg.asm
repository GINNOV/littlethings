;:ts=8

	section	text,code

	xref	_ReqBase
	xdef	_LinkGadget
_LinkGadget:
	movem.l	a6/a3,-(sp)
	move.l	_ReqBase,a6
	movem.l	12(sp),a0/a1/a3
	movem.l	24(sp),d0/d1
	jsr	-144(a6)
	movem.l	(sp)+,a6/a3
	rts

	end
