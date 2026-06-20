; TheReq()	NOT CALLABLE FROM C
; TheReq(title, text, controls, positivetext, negativetext);
;         a0	 a1      a2          a3            a5

TR_SIZEOF	equ		46

		xref	_ReqBase

		public	TheRequest
TheRequest
		move.l	_ReqBase,a6		;Load a6 from the data segment _before_ tromping on a4.

		sub.w	#TR_SIZEOF,sp	;get some temporary storage.

		move.l	sp,a4
		moveq	#TR_SIZEOF/2-1,d2	;because the stack is almost never clear.
1$		clr.w	(a4)+
		dbf		d2,1$

		move.l	a1,(sp)				;TR_Text
		move.l	a2,4(sp)			;TR_Controls
		move.l	a3,16(sp)			;TR_PositiveText
		move.l	a5,20(sp)			;TR_NegativeText
		move.l	a0,24(sp)			;TR_Title

		move.w	#$FFFF,28(sp)		;TR_KeyMask

		move.l	sp,a0
		jsr		-174(a6)			;TextRequest

		add.w	#TR_SIZEOF,sp

		movem.l	(sp)+,a2-a6/d2
		rts

		end
