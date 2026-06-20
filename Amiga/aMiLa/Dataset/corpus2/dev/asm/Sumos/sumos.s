; Author 	: Antoine Dubourg
; Version 	: 0.0
; Description 	: SUMOS, the Suboptimal, Useless, Minimalistic Operating System

	bra.s	Start

; Replace $10 by $20 for QWERTY layout. This is for AZERTY layout.

KeyCode
	dc.b	$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$10,$35,$33,$22,$12,$23
Start
	lea	$DFF000,a0
	lea	Code,a1
	lea	KeyCode,a2

; Simplistic hardware takeover
	
	move.w	#$7FFF,$009A(a0)	; Clear interrupt
	move.w	#$7FFF,$0096(a0)	; Clear DMA
	move.w	#$7FFF,$009C(a0)	; Clear request

	moveq	#$0,d4

; Read keyboard	

.readkey
	move.b	$BFEC01,d0
	not.b	d0
	lsr.b	#1,d0
	bcs.s	.handshake

; Decode which key is pressed (Hex range 0..F)

	move.l	#15,d7
.decode	cmp.b	(a2,d7),d0
	bne.s	.next

; LED blink to notice known keystroke (0..F)
 
	bchg	#1,$BFE001

; Are we MSB or LSB? 

	bchg	#0,d4
	bne.s	.noshift
	lsl.b	#4,d7
	move.b	d7,(a1)			; Write MSB
	bra.s	.handshake
.noshift	
	or.b	d7,(a1)+		; Write LSB, next byte
	bra.s	.handshake
.next	
	dbra	d7,.decode

.handshake				; Keyboard handshake
	bset	#6,$BFEE01 
	sf.b	$BFEC01
	moveq	#3,d1
.wait	move.b	$0006(a0),d2
.wait2	cmp.b	$0006(a0),d2
	beq.s	.wait2
	dbf	d1,.wait
	bclr	#6,$BFEE01

; Wait VBL

.vbl	move.l	$0004(a0),d1
	and.l	#$1FF00,d1
	cmpi.l	#256<<8,d1
	bne.s	.vbl

; Press ESCAPE to run what you wrote. PRAY. 

	cmp.b	#$45,d0			; ESCAPE keycode
	bne.s	.readkey		; Here we go!
Code

; Key pressed goes here... 
; Correctly ordered keystroke sequence can give working code. 
