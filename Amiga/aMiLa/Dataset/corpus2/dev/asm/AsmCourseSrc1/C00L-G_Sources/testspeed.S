
	**************************************
	**  SpeedTest - written by Cool-G   **
	** Compares the speed of 2 op-codes **
	**************************************

	lea.l	main(pc),a0
	move.l	a0,$80.w
	trap	#$0
	rts

main:	move.l	$4.w,a6
	jsr	-132(a6)
	lea	$dff000,a5
	move.w	#%0000000100010000,$96(a5)		; dma out
	move.w	#%1000000000100000,$9a(a5)		; interr set
	move.w	#%1000000000100000,$9c(a5)		; interr set
	move.l	$6c.w,oldint+2				; new interr
	move.l	#int,$6c
mouse:	btst	#6,$bfe001				; wait
	bne.s	mouse
	move.l	oldint+2,$6c.w				; restore everything
	move.l	$4.w,a6
	move.w	#%1000000100010000,$96(a5)		; dma on
	jsr	-138(a6)
	rte
		
*******************************************************

int:	movem.l	d0/a5,-(a7)
wait:	cmp.b	#70,6(a5)
	bne.s	wait
	move.w	#$005,$180(a5)		;change color: start of routine

	move.l	#2000,d7		;number of times to repeat

	btst	#10,$dff016		;right mousebutton to switch to l2
	beq.s	loop2




*********************************	routine without right button
loop:	add.l	d6,d0
	dbf	d7,loop
	bra.s	end
*********************************	routine with right button
loop2:	asl.l	#2,d0
	dbf	d7,loop2
	bra.s	end
*********************************	



	nop
end:	move.w	#$22a,$180(a5)		;change color: end of routine
	movem.l	(a7)+,d0/a5
oldint:	jmp	$0

