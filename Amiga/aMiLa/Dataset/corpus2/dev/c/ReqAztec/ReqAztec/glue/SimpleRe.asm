
		public	_ReqBase
		public	TheRequest

		cseg

ResumeText	dc.b	"Resume",0

		even

		public	_SimpleRequest
_SimpleRequest:
		move.l	4(sp),a0
		move.l	8(sp),a1
		lea		12(sp),a2
		movem.l	a3-a5/d2,-(sp)
		suba.l	a3,a3
		lea.l	ResumeText,a5
		jmp		TheRequest
