*	Subroutine to initialise and load a screen into the
*	bitplane pointers,  Mike Cross 1991

*	Entry :
*	a0 Screen base - value returned from AllocMem or a pointer to
*		  raw graphical data
*	a1 Cop -the plane pointers in the copper list, (note: the
*		  pointer points to the $0000 part and not the
*		  bplpt+$00)
*	d1 no planes
*	d2 plane size


LoadPointers
	movem.l	a0/a1/d0/d1,-(a7)
	subq.l	#1,d1
NxtPlane move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,(a1)			* Low word
	move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,4(a1) 		* High word
	add.w 	d2,a0
	adda.w	#8,a1
	dbra	d1,NxtPlane
	movem.l	(a7)+,a0/a1/d0/d1
	RTS

