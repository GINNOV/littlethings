
		*****************************************
		*	  SPrintF Function		*
		*****************************************

; Allow formatted text to be printed into a buffer. See RawDoFmt() details
;for more details of format string and data stream. MM.

; Entry		a0->Format String
;		a1->DataStream
;		a2->DestBuffer

; Exit		None

; Corrupt	None

_SPrintF	movem.l		d0-d2/a0-a6,-(sp)

		move.l		a2,a3
		lea		.PutC,a2
		CALLEXEC	RawDoFmt

		movem.l		(sp)+,d0-d2/a0-a6
		rts

.PutC		move.b		d0,(a3)+
		rts
