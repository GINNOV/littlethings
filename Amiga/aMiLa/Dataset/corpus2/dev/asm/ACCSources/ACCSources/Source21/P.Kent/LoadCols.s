*	Subroutine to load colours into copper,in direct register order.
*	P.Kent 10.1.92
*	Entry :
*	a0 colours base 
*	a1 Cop -the plane pointers in the copper list, (note: the
*		  pointer points to the $0000 part and not the
*		  COLOR)
*	d1 no cols
*	Exit :
*	NO REGS AFFECTED 

LoadCols
	movem.l	a0/a1/d0/d1,-(a7)
	subq.l	#1,d1
NxtCols
	move.w	(a0)+,(a1)
	addq.L	#4,A1	
	dbra	d1,NxtCols
	movem.l	(a7)+,a0/a1/d0/d1
	RTS

