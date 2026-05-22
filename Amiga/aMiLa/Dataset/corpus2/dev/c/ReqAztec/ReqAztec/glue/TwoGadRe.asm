
		public	_ReqBase
		public	TheRequest

		cseg

SureText	dc.b	" Yes ",0
CancelText	dc.b	"No Way",0

		even

		public	_TwoGadRequest
_TwoGadRequest:
		move.l	4(sp),a0
		move.l	8(sp),a1
		lea		12(sp),a2
		movem.l	a3-a5/d2,-(sp)
		lea.l	SureText,a3
		lea.l	CancelText,a5
		jmp		TheRequest

