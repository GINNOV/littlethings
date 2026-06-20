; mc0201.s				; first copperlist
; from disk1/brev02
; explanation on letter_02 p. 13
; from Mark Wrobel course letter 08, 10

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0201.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:
	move.w	#$01A0,$DFF096		; disable sprite, copper, and bitplane DMA's 
	lea.l	copperlist,A1		; put the address of the copperlist into a1
	move.l	A1,$DFF080			; move data in a1 into the copper first location register
	move.w	#$8080,$DFF096		; enable copper DMA

wait:
	btst	#6,$BFE001			; busy wait until left mouse is pressed
	bne	wait

	move.w	#$0080,$DFF096		; disable the copper DMA
	move.l	$04,A6				; ? ... Something with bringing back the workbench
	move.l	156(A6), A1			; ? ... 
	move.l	38(A1),$DFF080		; ? ... 
	move.w	#$81A0,$DFF096		; enable sprite, copper and bitplane DMA's
	rts							; return from subroutine, go back to the call site

; This is our own copper list, which forms a red, white, blue, white and red line.
copperlist:
	dc.w	$9001,$FFFE			; wait for line 144
	dc.w	$0180,$0F00			; move red color to $DFF180
	dc.w	$A001,$FFFE			; wait for line 160
	dc.w	$0180,$0FFF			; move white color to $DFF180
	dc.w	$A401,$FFFE			; wait for line 164
	dc.w	$0180,$000F			; move blue color to $DFF180
	dc.w	$AA01,$FFFE			; wait for line 170
	dc.w	$0180,$0FFF			; move white color to $DFF180
	dc.w	$AE01,$FFFE			; wait for line 174 
	dc.w	$0180,$0F00			; move red color to $DFF180
	dc.w	$BE01,$FFFE			; wait for line 190
	dc.w	$0180,$0000			; move black color to $DFF180
	dc.w	$FFFF,$FFFE			; end of copper list
	
	end


line 1:		move.w	#$01a0,$dff096	?$01a0	=	0000 0001 1010 0000			bit 15 = 0 (Clr)
								bit 8=1 (bitplane DMA) ,bit 7=1 (copper DMA) und bit 5 = 1 (sprite DMA) --> turn off
								
line 4:		move.w	#$8080,$dff096	?$8080	=	1000 000 1000 0000			bit 15 = 1 (Set)
								bit 7 = (copper DMA) --> turn on
								
line 10:	move.w	#$0080,$dff096	?$0080	=	0000 000 1000 0000			bit 15 = 0 (Clr)
								bit 7 = (copper DMA) --> turn off
								
line 14:	move.w	#$81a0,$dff096	?$81a0	=	1000 0001 1010 0000			bit 15 = 1 (Set)
								bit 8=1 (bitplane DMA) ,bit 7=1 (copper DMA) und bit 5 = 1 (sprite DMA) --> turn on

;----------------------------------------------------

	move.l	$04,a6				; Exec-Base	
	move.l	156(a6),a1			; _LVOUserState
