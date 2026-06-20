;---------Window border Def's.
;	  This is just to give the window a smart look.

Frame
	dc.w		10,15			;xy origin relative to container topleft
	dc.b		2,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		330,0			;x,y pos lines
	dc.w		0,0
	dc.w		0,120
.Border2
	dc.w		10,15		
	dc.b		1,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		Frame2
.BorderVectors2
	dc.w		0,120
	dc.w		330,120
	dc.w		330,0
	even

;------------Second set of border Co-ordinates for window 

Frame2	
	dc.w		10,15			;xy origin relative to container topleft
	dc.b		2,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		329,1			;x,y pos lines
	dc.w		1,1
	dc.w		1,119
.Border2
	dc.w		10,15		
	dc.b		1,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		1,119
	dc.w		329,119
	dc.w		329,1
	even
