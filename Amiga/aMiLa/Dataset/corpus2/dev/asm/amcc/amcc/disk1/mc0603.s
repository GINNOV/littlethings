; mc0603.s						; move the mouse and the look on the power-led
; not on disk
; explanation on letter_06 p. 02
; no explanation in MW_series		

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0603.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j			
	
start:							; comments from letter_06 p. 02
	move.w	#$4000,$dff09a		; 9a		INTENA		Line 1: Turn off all interrupts.
							
mainloop:							
	bset	#1,$bfe001			; CIA		Line 4: Set bit 1 of $BFE001 to "1" which turns off the power led.
	bsr	wait1					;			Line 5: Branch to the "wait1" label.
	bclr	#1,$bfe001			; CIA		Line 6: Sets bit 1 of $ BFE001 to "0" which turns on the power led.
	bsr	wait2					;			Line 7: Branch to the "wait2" label.
							
	btst	#6,$bfe001			; CIA		Line 9-10: Check if the mouse button is pressed. If not, branch back to "main loop". If it is
	bne	mainloop				;			it pressed, then continue to execute instructions at lines 12 and 13.
							
	move.w 	#$c000,$dff09a		; 9a		INTENA		Line 12: Enable all interrupt again.
	rts							;			Line 13: Return to the calling instance – here, return back to K-Seka (i.e. quit program).
							
wait1:							
	move.w 	$dff00a,d0			; 0a		JOY0DAT		Line 16: Fetches the position of the mouse-pointer and put it into D0.
	and.l	#$ff,d0				;			Line 17: Performs a logical AND with D0 so that we again only get BIT 0-7 (BIT 8-31
								;			set "0" – i.e. masked out). With this instruction we mask out "not relevant bits"
								;			so that only the mouse x-position is left
waitloop1:						;			Line 18-19: This loop is used as a delay it runs through the loop as many times as the value
	dbra	d0,waitloop1		;	    	in register D0 (mouse position).
	rts							;			Line 20: Return to the program line 6
							
wait2:							
	move.w 	$dff00a,d0			; 0a		JOY0DAT		Line 23: Move the mouse position into D0.
	and.l	#$ff,d0				;			Line 24: Mask out all bits except bit 0-7
	not.b	d0					;			Line 25: Invert (i.e. 0 becomes 1 and vice versa) bit 0-7 in D0. Only the bits 0-7 are
waitloop2:						;			inverted because we use ".b" in the instruction (a byte is eight bits).
	dbra	d0,waitloop2		;			Lines 26-27: Again a delay loop it runs through the loop the number of times stored in D0.
	rts							;			Line 28: Return to the program line 9

	end
							The above example works so that when you move the mouse from side to side, the POWER
							led is switched on and off. The whole secret is that if you turn on and off the power led you
							would not notice the change because it is done so fast.
							Try to find out how it works as it does before you read on.
							Did you find out, probably not. It is not that easy to behind the functionality by yourself. But
							when you read the explanation below so you understand it - surely!
							If we let the led be lit as long as it is off, we will experience it as if the led is lit with a half its
							intensity. If we leave the led switched off for 90% of time and turned on 10% of the time, we
							experience it as if the intensity is 10% of full- therefore its light emission is very low. This
							regulation is performed at the routines "wait1" and "wait2".
