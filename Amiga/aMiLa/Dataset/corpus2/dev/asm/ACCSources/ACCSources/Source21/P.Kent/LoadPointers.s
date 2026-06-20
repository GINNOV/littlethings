*	Subroutine to initialise and load a screen into the
*	bitplane pointers,  Mike Cross 1991
*	MOD 28/1/92 P.KENT TIDIED REG USAGE

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
	move.l	a0,d0
NxtPlane
	move.w	d0,4(a1)		* Low word
	swap	d0
	move.w	d0,(a1) 		* High word
	swap	d0
	add.l 	d2,d0
	addq.l	#8,a1
	dbra	d1,NxtPlane
	movem.l	(a7)+,a0/a1/d0/d1
	RTS

