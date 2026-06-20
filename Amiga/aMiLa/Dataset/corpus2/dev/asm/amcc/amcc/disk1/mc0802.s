; mc0802.s 					; play a sample with various period and volume
; from disk1/brev08
; explanation on letter_08.pdf / p.08
; from Mark Wrobel course letter 24			

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0802.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:						; comments from Mark Wrobel	
	move.w	#$0001,$dff096  ; DMACON disable audio channel 0
                        
	lea.l	sample,a1       ; move sample address into a1
	move.l	a1,$dff0a0      ; AUD0LCH/AUD0LCL set audio channel 0 location to sample address
	move.w	#8,$dff0a4      ; AUD0LEN set audio channel 0 length to 48452 words
	move.w	#0,$dff0a6      ; AUD0PER set audio channel 0 period to 700 clocks (less is faster)
	move.w	#0,$dff0a8      ; AUD0VOL set audio channel 0 volume to 0
                        
	move.w	#$8001,$dff096  ; DMACON enable audio channel 0

	lea.l	music,a1        ; move music address into a1

mainloop:					; begin mainloop
	bsr	wait				; branch to subroutine wait

	move.w	(a1)+,d1        ; move value pointed to by a1 into d1 and increment a1 (word)
	move.w	d1,$dff0a6      ; set AUD0PER to d1
	move.w	(a1)+,d2        ; move value pointed to by a1 into d2 and increment a1 (word)
	move.w	d2,$dff0a8      ; set AUD0VOL to d2

	cmp.w	#0,d1           ; compare 0 with value in d1
	bne	mainloop			; if d1 != 0 goto mainloop
	cmp.w	#0,d2           ; compare 0 with value in d2
	bne	mainloop			; if d2 != 0 goto mainloop

	move.w	#$0001,$dff096  ; DMACON disable audio channel 0
	rts                     ; return from subroutine (exit program)

wait:						; wait subroutine - waits 5/50th of second
	moveq	#4,d1			; set wait counter to 4

wait2:						; wait subroutine - waits 1/50th of a second 
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#200,d0			; check if we reached line 200
	bne	wait2				; if not goto wait
                      
wait3:						; second wait - part of the wait subroutine
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	andi.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#201,d0			; check if we reached line 201
	bne	wait3				; if not goto wait2

	dbra	d1,wait2		; if wait counter > -1 goto wait2

	rts						; return from wait subroutine

sample:						; sample of a sine wave defined by 16 values
	dc.b	0,40,90,110,127,110,90,40,0,-40,-90,-110,-127,-110,-90,-40

music:                ; pairs of period and volume - wait 1/10th second between pairs
	dc.w	428,64,428,64         ; C2, C2 at max volume
	dc.w	428,0                 ; C2 at min volume
	dc.w	381,64,381,64         ; D2, D2 at max volume
	dc.w	381,0                 ; D2 at min volume
	dc.w	339,64,339,64         ; E2, E2 at max volume
	dc.w	339,0                 ; E2 at min volume 
	dc.w	320,64,320,64         ; F2, F2 at max volume
	dc.w	320,0                 ; F2 at min volume
	dc.w	285,64,285,64         ; G2, G2 at max volume
	dc.w	285,0                 ; G2 at min volume
	dc.w	254,64,254,64         ; A2, A2 at max volume
	dc.w	254,0                 ; A2 at min volume
	dc.w	226,64,226,64         ; H2, H2 at max volume
	dc.w	226,0                 ; H2 at min volume
	dc.w	214,64,214,64,214,64  ; C3, C3, C3 at max volume
	dc.w	214,0,214,0,214,0     ; C3, C3, C3 at min volume

	dc.w	214,64                ; C3 at max volume
	dc.w	226,64                ; H2 at max volume
	dc.w	254,64                ; A2 at max volume
	dc.w	285,64                ; G2 at max volume
	dc.w	320,64                ; F2 at max volume
	dc.w	339,64                ; E2 at max volume
	dc.w	381,64                ; D2 at max volume
	dc.w	428,64,428,64,428,64  ; C2, C2, C2 at max volume

	dc.w	428,0,428,0,428,0     ; C2, C2, C2 at min volume
	dc.w	856,64,856,64,856,64  ; C1, C1, C1 at max volume 

	dc.w	0,0				; end of music is set by the zero pair
	
	end


;------------------------------------------------------------------------------
start:							; comments from letter_08.pdf / p. 08
	move.w	#$0001,$dff096		; 96	DMACON		Line 1: Turns off DMA for audio channel 0.
							
	lea.l	sample,a1			; Line 3: Loads the effective address of the "sample" into A1.
	move.l	a1,$dff0a0			; a0	AUD0PTH		Line 4: Moves the address in A1 into $DFF0A0 (pointer to audio channel 0).
	move.w	#8,$dff0a4			; a4	AUD0LEN		Line 5: Sets the length of the sample to 8 WORD (16 bytes).
	move.w	#0,$dff0a6			; a6	AUD0PER		Line 6: Moves 0 into $DFF0A6 (AUD0PER).
	move.w	#0,$dff0a8			; a8	AUD0VOL		Line 7: Moves 0 into $DFF0A8 (AUD0VOL).
							
	move.w	#$8001,$dff096		; 96	DMACON		Line 9: Turns on DMA for audio channel 0.
							
	lea.l	music,a1			; Line 11: Loads the effective address of "music" into the A1.
								;			
mainloop:						; Line 13: Here begins the routine, which plays different samples.
	bsr	wait					; Line 14: Branches to routine "wait". This routine will create a break of 5/50 seconds (a
								;			 tenth of a second).
	move.w	(a1)+,d1			; Line 16: Moves the value, the address in A1 points to, into register D1, then increase the
								; address in A1 by 2 (Remember: MOVE.W => + increases by 2 bytes).
	move.w	d1,$dff0a6			; a6	AUD0PER		Line 17: Moves the value of D1 into $DFF0A6 (AUD0PER).
	move.w	(a1)+,d2			; Line 18: Move the next value in the "music" table to D2.
	move.w	d2,$dff0a8			; a8	AUD0VOL		Line 19: Moves the value in D2 into $DFF0A8 (AUDOVOL).
							
	cmp.w	#0,d1				; Line 21: Compares D1 with 0.
	bne	mainloop				; Line 22: If D1 is not 0, jump back to the "main loop" label.
	cmp.w	#0,d2				; Line 23 Compares D2 0.
	bne	mainloop				; Line 24: If D2 is not 0, jump back to the "main loop" label
								; So: If both D1 and D2 are equal to 0, the program will continue until the 26th line.
	move.w	#$0001,$dff096		; 96	DMACON		Line 26: Turns off DMA for audio channel 0.
	rts							; Line 27: Ends the program.
							
wait:							; Line 29: Here begins the routine that creates a pause of 5/50 seconds (a 10th of a second).
	moveq	#4,d1				; Line 30: Move the constant value 4 quickly to D1. D1 is used as a counter (the
								; "waiting" 1/50 seconds 5 times).
wait2:							
	move.l	$dff004,d0			; 04	VPOSR		Line 33-37: Waiting until the electronic beam has reached line 200.
	asr.l	#8,d0					
	and.l	#$1ff,d0					
	cmp.w	#200,d0					
	bne	wait2					
							
wait3:							
	move.l	$dff004,d0			; 04	VPOSR		Line 40-44: Waiting until the electron beam has reached screen line 201. The reason why
	asr.l	#8,d0				; we should expect both display lines 200 and 201 are explained in the review of
	andi.l	#$1ff,d0			; example MC0801.
	cmp.w	#201,d0				;			
	bne	wait3					;			
								;			
	dbra	d1,wait2			; Line 46: Subtracts 1 from the value in Dl. Check if Dl is -1, if not, branch back again to
								; the "wait2" label. So: Program lines 33-44 are performed 5 times (5 * 1/50
								; seconds delay).
	rts							; Line 48: Branches back to the calling instance. Here return to the program line 14 and
								; continues from there.
sample:							;			
	dc.b	0,40,90,110,127,110,90,40,0,-40,-90,-110,-127,-110,-90,-40		; Line 51: Here is the sample which is replayed. These data represent a sine wave. Notice
								; that the DMA automatically replays the sample data on and on again so that
music:							; there will be an infinitely long sine-wave.
	dc.w	428,64,428,64		; Line 54-83: Here is the data which controls the tones to be played.
	dc.w	428,0				; The first value must be loaded into AUD0PER register. The second value is introduced in
	dc.w	381,64,381,64		; AUD0VOL register. The third value is introduced in AUDOPER register, and so on until all
	dc.w	381,0				; data (tones) are played.
	dc.w	339,64,339,64		; What happens when the program runs is that the first two values will be entered into
	dc.w	339,0				; AUD0PER and AUD0VOL respectively and then a delay of a 10th of a second will take place.
	dc.w	320,64,320,64		; After this delay the next two values are put into AUD0PER and AUD0VOL.and another delay
	dc.w	320,0				; of a 10th of a second takes place. This continues until 0 it is loaded both into AUDOPER and
	dc.w	285,64,285,64		; AUDOVOL, indicating that the table is finished, and the program ends.
	dc.w	285,0				; So the program lines 54-55 will play the tone "C" in 2 tenths of a seconds, then will come to
	dc.w	254,64,254,64		; halt (volume set to 0) at a tenth of a second before the next note is played.
	dc.w	254,0				; At the back of this issue you find a table containing the values of the different tones in the
	dc.w	226,64,226,64		; scale. Try to put your own tones as you like.
	dc.w	226,0				; In this chapter we have reviewed how to play a sample ready-made, and then how to make a
	dc.w	214,64,214,64,214,64		; single sound program that can play different tones. Now it's your turn. Remember Practice
	dc.w	214,0,214,0,214,0			; makes perfect.
							
	dc.w	214,64					
	dc.w	226,64					
	dc.w	254,64					
	dc.w	285,64					
	dc.w	320,64					
	dc.w	339,64					
	dc.w	381,64					
	dc.w	428,64,428,64,428,64					
							
	dc.w	428,0,428,0,428,0					
	dc.w	865,64,865,64,865,64					
							
	dc.w	0,0					

	end
