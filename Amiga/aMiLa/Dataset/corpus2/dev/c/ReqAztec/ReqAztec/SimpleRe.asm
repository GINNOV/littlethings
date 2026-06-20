
		public	_ReqBase
		public	TheRequest

		cseg

ResumeText	dc.b	"Resume",0

		even

		public	_SimpleRequest
_SimpleRequest:
		movem.l	a2-a6/d2,-(sp)
		move.l	28(sp),a0
		move.l	32(sp),a1
		lea		36(sp),a2
		suba.l	a3,a3
		lea.l	ResumeText,a5
		jmp		TheRequest
