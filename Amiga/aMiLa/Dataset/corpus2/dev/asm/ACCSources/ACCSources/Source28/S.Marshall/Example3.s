****************************************************************************
*
*	Program to show how audio dma wait loops can be
*	reduced by writing 1 into the audio period register.
*	Compile then run this program. A sample will play
*	continuously. Pressing the left mousebutton should
*	retrigger the sample from the start. Now comment out
*	the marked line, compile and run again. You will find
*	that you will have to increase the delay loop considerably
*	before the program will run correctly again. To terminate
*	the program hold down the right mousebutton then press the
*	left mousebutton. Sorry about this code being fairly crude,
*	but it does show that retriggering samples is not as simple
*	as it could be, and how a simple trick can improve matters.
*
*	By Steve Marshall
* 
****************************************************************************

;------	Just to save using includes
AUD0LCH		equ	$a0
AUD0LEN		equ	$a4
AUD0PER		equ	$a6
AUD0VOL		equ	$a8
AUD1LCH		equ	$b0
AUD1LEN		equ	$b4
AUD1PER		equ	$b6
AUD1VOL		equ	$b8
INTREQ		equ	$9c
INTREQR		equ	$1e
DMACON		equ	$96

	lea		$dff000,a5

start	
	move.w		#$01,DMACON(a5)
**************************************************************************	
	move.w		#1,AUD0PER(a5)		;this is the magic line!
**************************************************************************	
;	When the above line is commented out you will need to increase
;	the value below (loop index) for the program to operate correctly
	moveq		#60,d0	
lp
	dbf		d0,lp
	move.w		#$80,INTREQ(a5)
	move.w		#SmplSize,AUD0LEN(a5)
	move.l		#Smpl,AUD0LCH(a5)
	move.w		#$40,AUD0VOL(a5)
	move.w		#800,AUD0PER(a5)
	move.w		#$8001,DMACON(a5)
		
loop:
	btst		#6,$bfe001		;check for left mouseclick
	beq.s		loop 
	
loop2:
	btst		#6,$bfe001		;check for left mouseclick
	bne.s		loop 
	
	btst 		#2,$16(a5)		;check for right mouseclick
	bne.s		start 			

IRQ_Wait1:
	move.w		INTREQR(a5),D0
	btst		#7,D0
	beq.s		IRQ_Wait1

	move.w		#$0080,INTREQ(a5)
		
IRQ_Wait2:
	move.w		INTREQR(a5),D0
	btst		#7,D0
	beq.s		IRQ_Wait2
	move.w		#$0080,INTREQ(a5)
	move.w		#$01,DMACON(a5)
Error:
	rts

	section		sound,DATA_C

Smpl	incbin	'monobass'

SmplSize	equ	(*-Smpl)/2

