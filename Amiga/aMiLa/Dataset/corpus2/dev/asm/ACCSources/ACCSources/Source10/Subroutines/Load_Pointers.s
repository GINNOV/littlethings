*	Sub-routine to initialise and load a screen into the
*	bitplane pointers,  Mike Cross 1991

*	Entry :
*	Scr_Base	- value returned from AllocMem or a pointer to
*		  raw graphical data
*	plane	- the plane pointers in the copper list, (note: the
*		  pointer points to the $0000 part and not the 
		  bplpt+$00)
*	pl_Size	- plane size


No_Planes	equ	5

	move.l	Scr_Base(pc),a0		* Gfx into planes
	lea	plane,a1
	moveq.l	#No_Planes-1,d1		
NxtPlane	move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,(a1)			* Low word
	move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,4(a1)			* High word
	adda.w	#Pl_Size,a0			
	adda.w	#8,a1
	dbeq	d1,NxtPlane
	