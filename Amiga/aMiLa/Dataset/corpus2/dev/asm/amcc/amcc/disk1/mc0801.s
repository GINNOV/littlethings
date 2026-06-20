; mc0801.s 				; play a sample
; from disk1/brev08
; explanation on letter_08.pdf / p.06
; from Mark Wrobel course letter 23			

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0801.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>sample
; BEGIN>sample
; END>
; SEKA>j

start:							; comments from Mark Wrobel	
	move.w	#$0001,$dff096		; DMACON disable audio channel 0

	lea.l	sample,a1			; move sample address into a1
	move.l	a1,$dff0a0			; AUD0LCH/AUD0LCL set audio channel 0 location to sample address
	move.w	#48452,$dff0a4		; AUD0LEN set audio channel 0 length to 48452 words
	move.w	#700,$dff0a6		; AUD0PER set audio channel 0 period to 700 clocks (less is faster)
	move.w	#0,$dff0a8			; AUD0VOL set audio channel 0 volume to 0

	move.w	#$8001,$dff096		; DMACON enable audio channel 0

	moveq	#0,d1				; quick move 0 into d1 (volume level)
	move.l	#700,d2				; move 700 into d2 (period clock)
	moveq	#64,d7				; quick move 64 into d7 (loop counter)

up:								; begin up loop
	bsr	wait					; branch to subroutine wait 1/50th of a second
	bsr	wait					; branch to subroutine wait 1/50th of a second
	move.w	d1,$dff0a8			; AUD0VOL set to volume level stored in d1
	move.w	d2,$dff0a6			; AUD0PER set to period clock stored in d2
	addq.l	#1,d1				; increment volume level in d1 by 1
	subq.l	#8,d2				; decrease period clock in d2 by 8 (makes it play faster)
	dbra	d7,up				; check loop counter - if > -1 goto up

waitmouse:						; wait for mouse button press
	btst	#6,$bfe001			; test CIAAPRA FIR0 is pressed
	bne	waitmouse				; if not goto waitmouse

	moveq	#64,d7				; set loop counter d7 to 64

down:							; begin down loop
	bsr	wait					; branch to subroutine wait 1/50th of a second
	bsr	wait					; branch to subroutine wait 1/50th of a second
	move.w	d1,$dff0a8			; AUD0VOL set to volume level stored in d1
	move.w	d2,$dff0a6			; AUD0PER set to period clock stored in d2
	subq.l	#1,d1				; decrease volume level in d1 by 1
	addq.l	#8,d2				; increase period clock in d2 by 8 (makes it play slower)
	dbra	d7,down				; check loop counter - if > -1 goto up

	move.w	#$0001,$dff096		; DMACON disable audio channel 0
	rts							; return from subroutine

wait:							; wait subroutine - waits 1/50th of a second
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0			; add mask - preserve 9 LSB
	cmp.w	#200,d0				; check if we reached line 200
	bne	wait					; if not goto wait

wait2:							; second wait - part of the wait subroutine
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0			; add mask - preserve 9 LSB
	cmp.w	#201,d0				; check if we reached line 201
	bne	wait2					; if not goto wait2

	rts							; return from wait subroutine

sample:
	blk.w	48452,0				; allocate 48452 words and set them to zero
	; incbin "sample"
	end

;------------------------------------------------------------------------------	
start:							; comments from letter_08.pdf / p. 06
	move.w	#$0001,$dff096		; 96	DMACON		Line 1: This switches off the DMA for audio channel 0 (if it should be set). See also
								; setup DMACON in issue III.
	lea.l	sample,a1			; Line 3: Load the effective address of the "sample" into the A1.
	move.l	a1,$dff0a0			; a0	AUD0PTH		Line 4: Moving the address of the "sample" (A1) into $DFF0A0
	move.w	#48452,$dff0a4		; a4	AUD0LEN		Line 5: Move the value 48452 into $DFF0A4 (AUD0LEN) which represents the length
								; in words so the sample we should play is 48452 * 2 = 96,904 bytes long
								; (approx. 95 kb).
	move.w	#700,$dff0a6		; a6	AUD0PER		Line 6: Sets the replay-speed to 700 (AUD0PER).
	move.w	#0,$dff0a8			; a8	AUD0VOL		Line 7: Sets the volume (intensity) to 0 (AUD0VOL).
							
	move.w	#$8001,$dff096		; 96	DMACON		Line 9: Switch on the DMA for audio channel 0.
								; Program lines 11-22 gradually increase the volume to full strength and the replay-speed is
								; also increased gradually from 700 to normal speed. The normal play speed is 180. This effect
								; makes it sound like a turntable, which needs a little time until it reaches normal speed.
								; Program lines 28-37 do the opposite. The velocity and volume is lowered gradually, so it
								; sounds as if you suddenly pull the plug while the turn table still plays.
	moveq	#0,d1				; Line 11: Moves 0 into D1. D1 is used as to increase the volume gradually.
	move.l	#700,d2				; Line 12: Moves 700 into D2. D2 is used here to increase the replay-speed gradually
								; down to 180 (i.e., increase speed).
	moveq	#64,d7				; Line 13: Moves 64 into register D7 (this register is used as a loop-counter). The loop
								; therefore is performed 65 times (REMEMBER: 0 to 64).
up:								;		
	bsr	wait					; Line 16-17: Jumps to routine "wait". This is done 2 times. In this way we get a break of 1 /
	bsr	wait					; 25 seconds (2/50 seconds).



	move.w	d1,$dff0a8			; a8	AUD0VOL		Line 18: Moves the value of D1 into $DFF0A8 (AUD0VOL).
	move.w	d2,$dff0a6			; a6	AUD0PER		Line 19: Moves the value in D2 into $DFF0A6 (AUD0PER).
	addq.l	#1,d1				; Line 20: Adds 1 to the value in register D1 to increase the volume.
	subq.l	#8,d2				; Line 21: Subtract 8 from the value in D2 to increase replay-speed.
	dbra	d7,up				; Line 22: Subtracts 1 from D0. If D0 is larger -1, jump up again to the "up" label.
								;			
waitmouse:						;			
	btst	#6,$bfe001			; CIA		Line 25-26: Waiting until left mouse button is pressed.
	bne	waitmouse				;			
								;			
	moveq	#64,d7				; Line 28: The value 64 is moved to D7 so that we are ready for a new loop.
								;		
down:							;			
	bsr	wait					; Line 31-32: Jumps to twice toe the subroutine "wait to get a break of 1/25 second.
	bsr	wait					
	move.w	d1,$dff0a8			; a8	AUD0VOL		Line 33: Moves the value of D1 into $DFF0A8 (AUD0VOL).
	move.w	d2,$dff0a6			; a6	AUD0PER		Line 34: Moves the value of D2 into $DFF0A6 (AUD0PER).
	subq.l	#1,d1				; Line 35: Subtracts 1 from D1 (volume-count) to gradually decrease volume.
	addq.l	#8,d2				; Line 36: Adds 8 to D2 (speed counter) to gradually decrease replay-speed.
	dbra	d7,down				; Line 37: Subtracts 1 from D0. If D0 is larger than -1 jump up again to the "down" label.
							
	move.w	#$0001,$dff096		; 96	DMACON		Line 39: Turns off DMA for audio channel 0.
							
	rts							; Line 41: Ends the program.
								;			
wait:							; Line 43-55: These should be known by now, but you might wonder why we use both line
	move.l	$dff004,d0			; 04	VPOSR		 200 and line 201? This is because the routine is called twice in succession.
	asr.l	#8,d0				; Imagine that we had removed the program, lines 50-55. First walk through
	and.l	#$1ff,d0			; would go well. But the second time just immediately after the electron gun will
	cmp.w	#200,d0				; stop draw line 200, so that the routine will be completed premature.
	bne	wait					
							
wait2:							
	move.l	$dff004,d0			; 04	VPOSR		
	asr.l	#8,d0					
	and.l	#$1ff,d0					
	cmp.w	#201,d0					
	bne	wait2					
							
	rts						
							
sample:	
	;incbin "sample"				; for asmone						
	blk.w	48452				; Line 60: Here we reserved space for the sample-data which is on the course disk. 1.
								; Before the program can be run, it must be assembled, then read file "SAMPLE" in which is in
								; the directory "issue 08" on the course-disk and finally start program with "j".
								; Seka> a
								; OPTIONS
								; No errors
								; Seka> ri
								; FILENAME> brev08/sample
								; BEGIN> sample
								; END>
								; Seka> j
	end
