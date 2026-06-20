
		public	_ReqBase
		public	TheRequest

		cseg

SureText	dc.b	" Yes ",0
CancelText	dc.b	"No Way",0

		even

		public	_TwoGadRequest

_TwoGadRequest:
		movem.l	a2-a6/d2,-(sp)
		move.l	28(sp),a0
		move.l	32(sp),a1
		lea		36(sp),a2
		lea.l	SureText,a3
		lea.l	CancelText,a5
		jmp		TheRequest

