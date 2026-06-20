;----------This is the linked list of Gadget Def's.

Gadgets
Gadg1	dc.l		Gadg2			;next gadget
	dc.w		15,140			;xy of hit box relt to win topleft
	dc.w		60,10			;hit box width and height
	dc.w		GADGHIMAGE		;gadget flags
	dc.w		RELVERIFY		;activation flags
	dc.w		BOOLGADGET		;gadget type flags
	dc.l		.Border			;gadget border or image to be rendered
	dc.l		Altborder2		;alt image to be rendered
	dc.l		.IText			;first intuitext struct
	dc.l		NULL			;gadget mutual-exclude long word
	dc.l		NULL			;specialinfo struct
	dc.w		NULL			;user-definable data
	dc.l		Reset1			;ptr to user-definable data
.Border
	dc.w		-1,-1			;xy origin relative to container topleft
	dc.b		1,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		0,10			;x,y pos lines
	dc.w		0,0
	dc.w		60,0
.Border2
	dc.w		1,10		
	dc.b		2,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		0,0
	dc.w		60,0
	dc.w		60,-10
.IText
	dc.b		3,0,RP_JAM2,0		;front and back text pen,drawmode and fill byte
	dc.w		1,1			;xy origin relative to container topleft
	dc.l		NULL			;font ptr or null for default
	dc.l		.ITextText		;ptr to text
	dc.l		NULL			;next intuitext struct
.ITextText
	dc.b	' RESET',0
	even
	
;-----------Def's for Next gadget

Gadg2	dc.l		Gadg3			;next gadget
	dc.w		85,140			;xy of hit box relt to win topleft
	dc.w		60,10			;hit box width and height
	dc.w		GADGHIMAGE		;gadget flags
	dc.w		RELVERIFY		;activation flags
	dc.w		BOOLGADGET		;gadget type flags
	dc.l		.Border			;gadget border or image to be rendered
	dc.l		Altborder2		;alt image to be rendered
	dc.l		.IText			;first intuitext struct
	dc.l		NULL			;gadget mutual-exclude long word
	dc.l		NULL			;specialinfo struct
	dc.w		NULL			;user-definable data
	dc.l		Clear_Vectors		;ptr to user-definable data
.Border
	dc.w		-1,-1			;xy origin relative to container topleft
	dc.b		1,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		0,10			;x,y pos lines
	dc.w		0,0
	dc.w		60,0
.Border2
	dc.w		1,10		
	dc.b		2,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		0,0
	dc.w		60,0
	dc.w		60,-10
.IText
	dc.b		3,0,RP_JAM2,0		;front and back text pen,drawmode and fill byte
	dc.w		1,1			;xy origin relative to container topleft
	dc.l		NULL			;font ptr or null for default
	dc.l		.ITextText		;ptr to text
	dc.l		NULL			;next intuitext struct
.ITextText
	dc.b	' CLEAR ',0
	even


Gadg3	dc.l		Gadg4			;next gadget
	dc.w		155,140			;xy of hit box relt to win topleft
	dc.w		50,10			;hit box width and height
	dc.w		GADGHIMAGE		;gadget flags
	dc.w		RELVERIFY		;activation flags
	dc.w		BOOLGADGET		;gadget type flags
	dc.l		.Border			;gadget border or image to be rendered
	dc.l		Altborder		;alt image to be rendered
	dc.l		.IText			;first intuitext struct
	dc.l		NULL			;gadget mutual-exclude long word
	dc.l		NULL			;specialinfo struct
	dc.w		NULL			;user-definable data
	dc.l		Scan_Vectors		;ptr to user-definable data
.Border
	dc.w		-1,-1			;xy origin relative to container topleft
	dc.b		1,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		0,10			;x,y pos lines
	dc.w		0,0
	dc.w		50,0
.Border2
	dc.w		1,10		
	dc.b		2,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		0,0
	dc.w		50,0
	dc.w		50,-10
.IText
	dc.b		1,0,RP_JAM2,0		;front and back text pen,drawmode and fill byte
	dc.w		1,1			;xy origin relative to container topleft
	dc.l		NULL			;font ptr or null for default
	dc.l		.ITextText		;ptr to text
	dc.l		NULL			;next intuitext struct
.ITextText
	dc.b	' SCAN ',0
	even
	
Gadg4	dc.l		Gadg5			;next gadget
	dc.w		215,140			;xy of hit box relt to win topleft
	dc.w		50,10			;hit box width and height
	dc.w		GADGHIMAGE		;gadget flags
	dc.w		RELVERIFY		;activation flags
	dc.w		BOOLGADGET		;gadget type flags
	dc.l		.Border			;gadget border or image to be rendered
	dc.l		Altborder		;alt image to be rendered
	dc.l		.IText			;first intuitext struct
	dc.l		NULL			;gadget mutual-exclude long word
	dc.l		NULL			;specialinfo struct
	dc.w		NULL			;user-definable data
	dc.l		Infomsg			;ptr to user-definable data
.Border
	dc.w		-1,-1			;xy origin relative to container topleft
	dc.b		1,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		0,10			;x,y pos lines
	dc.w		0,0
	dc.w		50,0
.Border2
	dc.w		1,10		
	dc.b		2,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		0,0
	dc.w		50,0
	dc.w		50,-10
.IText
	dc.b		1,0,RP_JAM2,0		;front and back text pen,drawmode and fill byte
	dc.w		1,1			;xy origin relative to container topleft
	dc.l		NULL			;font ptr or null for default
	dc.l		.ITextText		;ptr to text
	dc.l		NULL			;next intuitext struct
.ITextText
	dc.b	' INFO ',0
	even
	
Gadg5	dc.l		Null			;next gadget
	dc.w		275,140			;xy of hit box relt to win topleft
	dc.w		50,10			;hit box width and height
	dc.w		GADGHIMAGE		;gadget flags
	dc.w		RELVERIFY		;activation flags
	dc.w		BOOLGADGET		;gadget type flags
	dc.l		.Border			;gadget border or image to be rendered
	dc.l		Altborder		;alt image to be rendered
	dc.l		.IText			;first intuitext struct
	dc.l		NULL			;gadget mutual-exclude long word
	dc.l		NULL			;specialinfo struct
	dc.w		NULL			;user-definable data
	dc.l		Exit			;ptr to user-definable data
.Border
	dc.w		-1,-1			;xy origin relative to container topleft
	dc.b		1,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		0,10			;x,y pos lines
	dc.w		0,0
	dc.w		50,0
.Border2
	dc.w		1,10		
	dc.b		2,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		0,0
	dc.w		50,0
	dc.w		50,-10
.IText
	dc.b		1,0,RP_JAM2,0		;front and back text pen,drawmode and fill byte
	dc.w		1,1			;xy origin relative to container topleft
	dc.l		NULL			;font ptr or null for default
	dc.l		.ITextText		;ptr to text
	dc.l		NULL			;next intuitext struct
.ITextText
	dc.b	' QUIT ',0
	even

;----------Alternative border Def's for gadget's.

AltBorder
	dc.w		-1,-1			;xy origin relative to container topleft
	dc.b		2,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		0,10			;x,y pos lines
	dc.w		0,0
	dc.w		50,0
.Border2
	dc.w		1,10		
	dc.b		1,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		0,0
	dc.w		50,0
	dc.w		50,-10
	even
	
AltBorder2
	dc.w		-1,-1			;xy origin relative to container topleft
	dc.b		2,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b		3			;number of xy vectors
	dc.l		.BorderVectors		;ptr to xy vectors
	dc.l		.Border2		;next border in list
.BorderVectors
	dc.w		0,10			;x,y pos lines
	dc.w		0,0
	dc.w		60,0
.Border2
	dc.w		1,10		
	dc.b		1,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		NULL
.BorderVectors2
	dc.w		0,0
	dc.w		60,0
	dc.w		60,-10
	even
