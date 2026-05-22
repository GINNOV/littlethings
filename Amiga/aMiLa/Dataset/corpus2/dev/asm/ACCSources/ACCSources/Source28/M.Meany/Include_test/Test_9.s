
; Test the interrupt driven sample player and sample declaration macro.

		incdir		Source:Include/
		include		hardware.i
		include		Marks/Hardware/HW_Macros.i
		include		Marks/Hardware/HW_start.i
		include		Marks/Hardware/HW_Sound.i
	
; Write new level 3 vector

Main		move.l		#Level3Code,$6c

; Enable vert blank interrupts only

		move.w		#SETIT!INTEN!VERTB,INTENA(a5) enable level 3

; Wait for mouse to be pressed

Mouse		btst		#6,CIAAPRA
		bne.s		Mouse

		rts					go home

*****************************************************************************

;---
;---	level 3 interrupt handler
;---


Level3Code	PUSH		a0-a6/d0-d7		Save all registers

		lea		$dff000,a5		hardware registers

; Call sample player

		bsr		SmpPlayer

; See if new sample is required

		bsr		TestFire

; Clear interrupt request bits now

		move.w		#BLIT!VERTB!COPER,INTREQ(a5) clear L3 bits

.Done		PULL		a0-a6/d0-d7		restore registers
		rte					what, no handler!

*****************************************************************************

; When fire button is pressed, a counter is activated. Further presses are
;ignored until counter reaches zero. This gives a sample a chance to start
;playing before repeating due to user holding down fire button.

TestFire	tst.w		vbl_count		counter clear?
		beq.s		.DoFire			yep! ok to start snd
		
		subq.w		#1,vbl_count		dec counter
		bra.s		.done			and exit

.DoFire		tst.b		CIAAPRA			fire button pressed?
		bmi.s		.done			skip if not

		lea		Sample1,a0		sample
		moveq.l		#0,d0			channel
		bsr		PlaySample		play it

		move.w		#4,vbl_count

.done		rts					and exit

*****************************************************************************

; Counter used to disable fire checking

vbl_count	dc.w		0		disable fire checks temp

*****************************************************************************

		section		sounds,DATA_C

		incdir		Source:M.Meany/Gfx/

		SETSAMPLE	Sample1,'bang.snd'

