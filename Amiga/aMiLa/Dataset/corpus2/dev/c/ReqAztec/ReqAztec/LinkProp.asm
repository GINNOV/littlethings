
		public	_ReqBase
		public	_LinkPropGadget

_LinkPropGadget:
		movem.l	a3/a6/d2-d4,-(sp)
		move.l	_ReqBase,a6
		movem.l	24(sp),a0/a3
		movem.l	32(sp),d0-d4
		jsr		-156(a6)
		movem.l	(sp)+,a3/a6/d2-d4
		rts

		end
