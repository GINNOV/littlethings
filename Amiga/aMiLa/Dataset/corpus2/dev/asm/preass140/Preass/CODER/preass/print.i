; PRINT V1.0 fuer Preassemblersources
;
; Von : Cyborg
;
; Wird direkt in den Source includet.

PRINT:	movem.l d0-d7/a0-a6,-(SP)	;Regs retten
	move.l 60(SP),D2		;Adresse nach dem JSR PRINT
	move.l d2,a0			;aus dem Stack holen
.label1:move.b (a0)+,d0
	cmpi.b #$00,d0
	bne.b .label1
	lea -1(a0),a0
	move.l a0,d0
	sub.l d2,d0
	move.l d0,OFFSET
	move.l Systemhandle,d1
	move.l d0,d3
	move.l Dosbase,a6
	jsr Write(a6)
	move.l offset,d0
	addq.l #1,d0
	add.l d0,60(SP)
	move.l 60(SP),A0
	cmpi.b #$00,(a0)
	bne o_k
	addi.l #1,60(SP)
o_k:movem.l (SP)+,D0-D7/A0-A6
	RTS
OFFSET:		dc.l 0
SYSTEMHANDLE:	dc.l 0
