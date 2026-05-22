	XDEF __sprintf
	XREF _AbsExecBase
	XREF _LVORawDoFmt

	csect	text,0,,2,2

__sprintf
save	equ	16
	movem.l	a2/a3/a6/d2,-(a7)	; save bytes copied to stack

	move.l	save+8(a7),a0
	lea	save+12(a7),a1
	lea	copychar(pc),a2
	move.l	save+4(a7),a3
	move.l	a3,d2

	move.l	_AbsExecBase,a6
	jsr	_LVORawDoFmt(a6)
	move.l	a3,d0			; # of characters printed
	sub.l	d2,d0

	movem.l	(a7)+,a2/a3/a6/d2
	rts
	
copychar
	move.b	d0,(a3)+
	rts

	end
