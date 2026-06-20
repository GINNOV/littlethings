
		public	_ReqBase
		public	_Format

_Format:
		movem.l	a2/a6,-(sp)
		move.l	12(sp),a2
		move.l	16(sp),a0
		lea		20(sp),a1
		move.l	_ReqBase,a6
		jsr		-54(a6)			; Format
		move.l	(sp)+,a2/a6
		rts
