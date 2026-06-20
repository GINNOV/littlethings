*******	Build and display a text string using RawDoFmt

; Entry		a0->format string

; Exit		Nothing Useful

; Corrupt	a6 possibly

RDFPrint	PUSH		d0-d4/a0-a4

		lea		DStream,a1
		lea		_PC,a2
		lea		BuiltText,a3
		CALLEXEC	RawDoFmt
		
		lea		BuiltText,a0
		bsr		DOSPrint
		
		PULL		d0-d4/a0-a4
		rts

_PC		move.b		d0,(a3)+
		rts
