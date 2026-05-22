; mc1101.s						; mouse
; from disk1/brev10
; explanation on letter_11 p. 05
; explanation in MW_series 31		

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1101.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j	

start:							; comments from Mark Wrobel
main:							; just a label
	bsr	mouse					; branch to subroutine mouse

	lea.l	mousex,a1			; move mousex address into a1
	lea.l	mousey,a2			; move mousey address into a2

	move.w	(a1),d1				; move value at mousex address into d1
	move.w	(a2),d2				; move value at mousey address into d2
	
	btst	#6,$bfe001			; test left mouse button
	bne	main					; if not pressed goto main
	rts							; return from subroutine - exit program
	
mouse:							; subroutine (mousex, mousey) = mouse()
	movem.l	d0-d7/a0-a6,-(a7)	; save registers on stack
	move.w	$dff00a,d0			; move value in JOY0DAT to d0
	andi.l	#255,d0				; keep lower byte in d0 (mouse x counter) using immidiate AND
	moveq	#0,d2				; move 0 into d2 (lower bound on x)
	move.l	#639,d3				; move 639 into d3 (upper bound on x)
	lea.l	oldx,a1				; move oldx address into a1
	lea.l	mousex,a2			; move mousex address into a2
	bsr.s	calcmouse			; branch to subroutine calcmouse
	move.w	$dff00a,d0			; move value in JOY0DAT to d0
	lsr.w	#8,d0				; shift left 8 bits
	andi.l	#255,d0				; keep lower byte in d0 (mouse y counter) using immidiate AND 
	moveq	#0,d2				; move 0 into d2 (lower bound on y)
	move.l	#511,d3				; move 511 into d3 (upper bound on y)
	lea.l	oldy,a1				; move address of oldy into a1
	lea.l	mousey,a2			; move address of mousey into a2
	bsr.s	calcmouse			; branch to subroutine calcmouse
	movem.l	(a7)+,d0-d7/a0-a6	; load registers from stack
	rts							; return from subroutine
calcmouse:						; subroutine calcmouse(a1=oldCountPtr,a2=newCoordinatePtr,
								; d0=newCount,d2=lowerBound,d3=upperBound)
	moveq	#0,d1				; move 0 into d1
	move.w	(a1),d1				; move value from address in a1 (oldCount) to d1
	move.w	d0,(a1)				; move d0 (newCount) into address pointed to by a1
	move.l	d0,d5				; move d0 (newCount) into d5
	move.l	d1,d6				; move d1 (oldCount) into d6
	sub.w	d0,d1				; subtract word d0 (newCount) from d1 (oldCount) and
								; store result in d1 (countDiff)
	cmp.w	#-128,d1			; compare -128 with d1 (countDiff)
	blt.s	mc_less				; if d1 < -128 goto mc_less
	cmp.w	#127,d1				; compare 127 with d1 (countDiff)
	bgt.s	mc_more				; if d1 > 127 goto mc_more
	cmp.w	#0,d1				; compare 0 with d1 (countDiff)
	blt.s	mc_chk2				; if d1 < 0 goto mc_chk2
mc_chk1:						; label
	cmp.w	d5,d6				; compare d5 (newCount) with d6 (oldCount)
	bge.s	mc_chk1ok			; if d6 > d5 goto mc_chk1ok
	neg.w	d1					; negate d1 (countDiff)
	mc_chk1ok:					; label
	bra.s	mc_storem			; branch always to mc_storem
mc_chk2:						; label
	cmp.w	d5,d6				; compare d5 (newCount) with d6 (oldCount)
	ble.s	mc_chk2ok			; d6 < d5 goto mc_chk2ok
	neg.w	d1					; negate d1 (countDiff)
mc_chk2ok:						; label
	bra.s	mc_storem			; branch always to mc_storem
mc_less:						; label
	add.w	#256,d1				; add 256 to d1 and store in d1 (countDiff)
	bra.s	mc_storem			; branch always to mc_storem
mc_more:						; label
	sub.w	#256,d1				; subtract 256 from d1 and store in d1 (countDiff)
mc_storem:						; label
	neg.w	d1					; negate d1 (countDiff)
	add.w	d1,(a2)				; add d1 (countDiff) to the value pointed to by a2 (newCoordinatePtr)
	move.w	(a2),d0				; move value from address in a2 (newCoordinatePtr) to d0
	cmp.w	d2,d0				; compare d2 (lowerBound) with d0
	blt.s	mc_toosmall			; if d0 < d2 goto mc_toosmall
	cmp.w	d3,d0				; compare d3 (upperBound) with d0
	bgt.s	mc_toolarge			; if d0 > d3 goto mc_toolarge
	rts							; return from subroutine
mc_toosmall:					; label
	move.w	d2,(a2)				; move value in d2 (lowerBound) to address
								; pointed to by a2 (newCoordinatePtr)
	rts							; return from subroutine
mc_toolarge:					; label
	move.w	d3,(a2)				; move value in d3 (upperBound) to address
								; pointed to by a2 (newCoordinatePtr)
	rts							; return from subroutine
oldx:       
	dc.l	$0000				; allocate space for oldx (mouse x counter)
oldy:       
	dc.l	$0000				; allocate soace for oldy (mouse y counter)
mousex:       
	dc.w	$0000				; allocate space for mousex (mouse x coordinate)
mousey:       
	dc.w	$0000				; allocate space for mousey (mouse y coordinate)	

	end
	