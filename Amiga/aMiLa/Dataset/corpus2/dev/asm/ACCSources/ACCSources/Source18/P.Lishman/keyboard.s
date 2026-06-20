CIATL	equ	$bfe401		;CIA-A, timer low byte
CIATH	equ	$bfe501		;CIA-A, timer high byte
KDAT	equ	$bfec01		;Keyboard data shift register
ICRA	equ	$bfed01		;Interrupt Control Reg, CIA-A
TCTLA	equ	$bfee01		;Timer Control, CIA-A, timer A

kb_setup
	move.l	#kbd_int,$68.w	;load interrupt to Level 2 68000 autovector
	move.b	#$88,ICRA	;set keyboard interrupt-shift data interrupt
	move.w	#$7FFF,$dff09a	;clear all interrupts
	move.w	#$C008,$dff09a	;set PORTS to interrupt
	move.b	#1,CIATL	;timer low byte, set to 1
	move.b	#0,CIATH	;timer high byte, set to 0
	rts			;end kb setup routine

kbd_int	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$0008,$dff09c	;clear interrupt request
	btst	#3,ICRA		;is Serial Port interrupt flagged?
	beq	not_kb		;no, so keyboard is not originator
	moveq.b	#0,d0		;clear d0
	move.b	KDAT,d0		;read keyboard data
	not.b	d0		;
	ror.b	#1,d0		;shift up-down bit to bit 7
	move.b	d0,kb_data	;make available to other routines
	move.b	#$57,TCTLA	;start timer A, CIA-A
	clr.b	KDAT		;
h_loop	btst	#3,ICRA		;test SP flag
	beq	h_loop		;repeat until flagged

	moveq.l	#50,d0
p_loop	dbra	d0,p_loop	;wait for handshake to complete

	clr.b	TCTLA		;stop timer A
not_kb	movem.l	(sp)+,d0-d7/a0-a6
	rte			;finish interrupt

kb_data	dc.b	0
