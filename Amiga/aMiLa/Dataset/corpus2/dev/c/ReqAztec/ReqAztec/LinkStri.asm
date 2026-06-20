
		public	_ReqBase
		public	_LinkStringGadget

_LinkStringGadget:
		movem.l	a6/a2/a3/d2/d3,-(sp)
		move.l	_ReqBase,a6
		movem.l	24(sp),a0-a3
		movem.l	40(sp),d0-d3
		jsr		-150(a6)
		movem.l	(sp)+,a6/a2/a3/d2/d3
		rts

		end
