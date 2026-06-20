		
********************************************************************
*
*  Gadget structure for coloum 1
*
*********************************************************************

Gadgetlist1:
Gadg1	dc.l	Gadg2		;next gadget
	dc.w	65,45		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border1		;gadget border or image to be rendered
	dc.l	NULL		;alt image to be rendered
	dc.l	IText1		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	NULL		;ptr to user-definable data
Border1
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors1	;ptr to xy vectors
	dc.l	Border1a		;next border in list
BorderVectors1
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
Border1a
	dc.w	1,10		
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	BorderVectors1a
	dc.l	NULL
BorderVectors1a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
IText1
	dc.b	3,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText1	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText1
	dc.b	' Graphic Utils',0
	even

Gadg2	dc.l	Gadg3		;next gadget
	dc.w	65,60		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border2		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText2		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function2		;ptr to user-definable data
Border2
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors2	;ptr to xy vectors
	dc.l	Border2a		;next border in list
BorderVectors2
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border2a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors2a
	dc.l	NULL
BorderVectors2a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText2
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText2	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText2
	dc.b	' DPaint III',0
	even
	
Gadg3	dc.l	Gadg4		;next gadget
	dc.w	65,75		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border3		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText3		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function3		;ptr to user-definable data
Border3
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors3	;ptr to xy vectors
	dc.l	Border3a		;next border in list
BorderVectors3
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border3a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors3a
	dc.l	NULL
BorderVectors3a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
IText3
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText3	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText3
	dc.b	' Brushcon  ',0
	even
Gadg4	dc.l	Gadg5		;next gadget
	dc.w	65,90		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border4		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText4		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function4		;ptr to user-definable data
Border4
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors4	;ptr to xy vectors
	dc.l	Border4a		;next border in list
BorderVectors4
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border4a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors4a
	dc.l	NULL
BorderVectors4a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText4
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText4	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText4
	dc.b	' Iff-Convert  ',0
	even
Gadg5	dc.l	Gadg6		;next gadget
	dc.w	65,105		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border5		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText5		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function5		;ptr to user-definable data
Border5
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors5	;ptr to xy vectors
	dc.l	Border5a		;next border in list
BorderVectors5
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border5a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors5a
	dc.l	NULL
BorderVectors5a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText5
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText5	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText5
	dc.b	' Iffmaster  ',0
	even
Gadg6	dc.l	Gadg7		;next gadget
	dc.w	65,120		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border6		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText6		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function6		;ptr to user-definable data
Border6
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors6	;ptr to xy vectors
	dc.l	Border6a		;next border in list
BorderVectors6
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border6a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors6a
	dc.l	NULL
BorderVectors6a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText6
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText6	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText6
	dc.b	' 3rd Day  ',0
	even

Gadg7	dc.l	Gadg8		;next gadget
	dc.w	65,135		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border7		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText7		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function7		;ptr to user-definable data
Border7
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors7	;ptr to xy vectors
	dc.l	Border7a		;next border in list
BorderVectors7
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border7a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors7a
	dc.l	NULL
BorderVectors7a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText7
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText7	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText7
	dc.b	' TGR ',0
	even

Gadg8	dc.l	Gadg9		;next gadget
	dc.w	65,150		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border8		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText8		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function8		;ptr to user-definable data
Border8
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors8	;ptr to xy vectors
	dc.l	Border8a		;next border in list
BorderVectors8
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border8a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors8a
	dc.l	NULL
BorderVectors8a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText8
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText8	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText8
	dc.b	' MOD_Processor ',0
	even

Gadg9	dc.l	Gadg10		;next gadget
	dc.w	65,165		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border9		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText9		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function9		;ptr to user-definable data
Border9
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors9	;ptr to xy vectors
	dc.l	Border9a		;next border in list
BorderVectors9
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border9a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors9a
	dc.l	NULL
BorderVectors9a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText9
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText9	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText9
	dc.b	' Reset 60hz II ',0
	even
Gadg10	dc.l	Gadg11		;next gadget
	dc.w	65,180		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border10		;gadget border or image to be rendered
	dc.l	NULL		;alt image to be rendered
	dc.l	IText10		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	NULL		;ptr to user-definable data
Border10
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors10	;ptr to xy vectors
	dc.l	Border10a		;next border in list
BorderVectors10
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border10a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors10a
	dc.l	NULL
BorderVectors10a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText10
	dc.b	3,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText10	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText10
	dc.b	' Cli Utils ',0
	even
Gadg11	dc.l	Gadg12		;next gadget
	dc.w	65,195		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border11		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText11		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function11		;ptr to user-definable data
Border11
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors11	;ptr to xy vectors
	dc.l	Border11a		;next border in list
BorderVectors11
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border11a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors11a
	dc.l	NULL
BorderVectors11a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText11
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText11	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText11
	dc.b	' Guru-info ',0
	even

Gadg12	dc.l	Gadg13		;next gadget
	dc.w	65,210		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border12		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText12		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function12		;ptr to user-definable data
Border12
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors12	;ptr to xy vectors
	dc.l	Border12a		;next border in list
BorderVectors12
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border12a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors12a
	dc.l	NULL
BorderVectors12a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText12
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText12	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText12
	dc.b	' Pal-Install ',0
	even

Gadg13	dc.l	Gadg14		;next gadget
	dc.w	65,225		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border13		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText13		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function13		;ptr to user-definable data
Border13
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors13	;ptr to xy vectors
	dc.l	Border13a		;next border in list
BorderVectors13
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border13a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors13a
	dc.l	NULL
BorderVectors13a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText13
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText13	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText13
	dc.b	' Blank-Disc ',0
	even

Gadg14	dc.l	Gadg15		;next gadget
	dc.w	65,240		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border14		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText14		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function14		;ptr to user-definable data
Border14
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors14	;ptr to xy vectors
	dc.l	Border14a		;next border in list
BorderVectors14
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border14a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors14a
	dc.l	NULL
BorderVectors14a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText14
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText14	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText14
	dc.b	' Bootwriter ',0
	even
	
	
********************************************************************
*
*  Gadget structure for coloum 2
*
*********************************************************************


Gadg15	dc.l	Gadg16		;next gadget
	dc.w	235,45		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border15		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText15		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function15		;ptr to user-definable data
Border15
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors15	;ptr to xy vectors
	dc.l	Border15a		;next border in list
BorderVectors15
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
Border15a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors15a
	dc.l	NULL
BorderVectors15a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
IText15
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText15	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText15
	dc.b	' Dc.b Convert ',0
	even

Gadg16	dc.l	Gadg17		;next gadget
	dc.w	235,60		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border16		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText16		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function16		;ptr to user-definable data
Border16
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors16	;ptr to xy vectors
	dc.l	Border16a		;next border in list
BorderVectors16
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border16a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors16a
	dc.l	NULL
BorderVectors16a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText16
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText16	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText16
	dc.b	' Convert.txt ',0
	even
	
Gadg17	dc.l	Gadg18		;next gadget
	dc.w	235,75		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border17		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText17		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function17		;ptr to user-definable data
Border17
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors17	;ptr to xy vectors
	dc.l	Border17a		;next border in list
BorderVectors17
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border17a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors17a
	dc.l	NULL
BorderVectors17a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
IText17
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText17	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText17
	dc.b	' QuickRam ',0
	even
	
Gadg18	dc.l	Gadg19		;next gadget
	dc.w	235,90		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border18		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText18		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function18		;ptr to user-definable data
Border18
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors18	;ptr to xy vectors
	dc.l	Border18a		;next border in list
BorderVectors18
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border18a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors18a
	dc.l	NULL
BorderVectors18a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText18
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText18	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText18
	dc.b	' PPtype ',0
	even
	
Gadg19	dc.l	Gadg20		;next gadget
	dc.w	235,105		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border19		;gadget border or image to be rendered
	dc.l	NULL		;alt image to be rendered
	dc.l	IText19		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	NULL		;ptr to user-definable data
Border19
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors19	;ptr to xy vectors
	dc.l	Border19a		;next border in list
BorderVectors19
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border19a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors19a
	dc.l	NULL
BorderVectors19a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText19
	dc.b	3,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText19	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText19
	dc.b	' Disk Utils ',0
	even
	
Gadg20	dc.l	Gadg21		;next gadget
	dc.w	235,120		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border20		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText20		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function20		;ptr to user-definable data
Border20
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors20	;ptr to xy vectors
	dc.l	Border20a		;next border in list
BorderVectors20
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border20a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors20a
	dc.l	NULL
BorderVectors20a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText20
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText20	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText20
	dc.b	' DiskMaster ',0
	even

Gadg21	dc.l	Gadg22		;next gadget
	dc.w	235,135		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border21		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText21		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function21		;ptr to user-definable data
Border21
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors21	;ptr to xy vectors
	dc.l	Border21a		;next border in list
BorderVectors21
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border21a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors21a
	dc.l	NULL
BorderVectors21a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText21
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText21	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText21
	dc.b	' Fix-Disk',0
	even

Gadg22	dc.l	Gadg23		;next gadget
	dc.w	235,150		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border22		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText22		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function22		;ptr to user-definable data
Border22
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors22	;ptr to xy vectors
	dc.l	Border22a		;next border in list
BorderVectors22
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border22a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors22a
	dc.l	NULL
BorderVectors22a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText22
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText22	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText22
	dc.b	' SetKey',0
	even

Gadg23	dc.l	Gadg24		;next gadget
	dc.w	235,165		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border23		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText23		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function23		;ptr to user-definable data
Border23
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors23	;ptr to xy vectors
	dc.l	Border23a		;next border in list
BorderVectors23
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border23a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors23a
	dc.l	NULL
BorderVectors23a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText23
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText23	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText23
	dc.b	' Tx-Ed',0
	even
Gadg24	dc.l	Gadg25		;next gadget
	dc.w	235,180		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border24		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText24		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function24		;ptr to user-definable data
Border24
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors24	;ptr to xy vectors
	dc.l	Border24a		;next border in list
BorderVectors24
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border24a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors24a
	dc.l	NULL
BorderVectors24a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText24
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText24	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText24
	dc.b	' DiskX',0
	even
	
Gadg25	dc.l	Gadg26		;next gadget
	dc.w	235,195		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border25		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText25		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function25		;ptr to user-definable data
Border25
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors25	;ptr to xy vectors
	dc.l	Border25a		;next border in list
BorderVectors25
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border25a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors25a
	dc.l	NULL
BorderVectors25a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText25
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText25	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText25
	dc.b	' NewZap',0
	even

Gadg26	dc.l	Gadg27		;next gadget
	dc.w	235,210		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border26		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText26		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function26		;ptr to user-definable data
Border26
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors26	;ptr to xy vectors
	dc.l	Border26a		;next border in list
BorderVectors26
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border26a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors26a
	dc.l	NULL
BorderVectors26a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText26
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText26	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText26
	dc.b	' Preferences',0
	even

Gadg27	dc.l	Gadg28		;next gadget
	dc.w	235,225		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border27		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText27		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function27		;ptr to user-definable data
Border27
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors27	;ptr to xy vectors
	dc.l	Border27a		;next border in list
BorderVectors27
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border27a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors27a
	dc.l	NULL
BorderVectors27a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText27
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText27	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText27
	dc.b	' X-Copy',0
	even

Gadg28	dc.l	Gadg29		;next gadget
	dc.w	235,240		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border28		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText28		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function28		;ptr to user-definable data
Border28
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors28	;ptr to xy vectors
	dc.l	Border28a		;next border in list
BorderVectors28
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border28a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors28a
	dc.l	NULL
BorderVectors28a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText28
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText28	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText28
	dc.b	' D-Copy',0
	even

********************************************************************
*
*  Gadget structure for coloum 3
*
*********************************************************************


Gadg29	dc.l	Gadg30		;next gadget
	dc.w	405,45		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border29		;gadget border or image to be rendered
	dc.l	NULL		;alt image to be rendered
	dc.l	IText29		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	NULL		;ptr to user-definable data
Border29
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors29	;ptr to xy vectors
	dc.l	Border29a		;next border in list
BorderVectors29
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
Border29a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors29a
	dc.l	NULL
BorderVectors29a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
IText29
	dc.b	3,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText29	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText29
	dc.b	' Crunchers',0
	even

Gadg30	dc.l	Gadg31		;next gadget
	dc.w	405,60		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border30		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText30		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function30		;ptr to user-definable data
Border30
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors30	;ptr to xy vectors
	dc.l	Border30a		;next border in list
BorderVectors30
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border30a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors30a
	dc.l	NULL
BorderVectors30a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText30
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText30	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText30
	dc.b	' PowerPacker',0
	even
	
Gadg31	dc.l	Gadg32		;next gadget
	dc.w	405,75		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border31		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText31		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function31		;ptr to user-definable data
Border31
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors31	;ptr to xy vectors
	dc.l	Border31a		;next border in list
BorderVectors31
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border31a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors31a
	dc.l	NULL
BorderVectors31a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
IText31
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText31	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText31
	dc.b	' Imploder',0
	even
	
Gadg32	dc.l	Gadg33		;next gadget
	dc.w	405,90		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border32		;gadget border or image to be rendered
	dc.l	NULL		;alt image to be rendered
	dc.l	IText32		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	NULL		;ptr to user-definable data
Border32
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors32	;ptr to xy vectors
	dc.l	Border32a		;next border in list
BorderVectors32
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border32a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors32a
	dc.l	NULL
BorderVectors32a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText32
	dc.b	3,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText32	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText32
	dc.b	' Virus Utils',0
	even
	
Gadg33	dc.l	Gadg34		;next gadget
	dc.w	405,105		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border33		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText33		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function33		;ptr to user-definable data
Border33
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors33	;ptr to xy vectors
	dc.l	Border33a		;next border in list
BorderVectors33
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border33a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors33a
	dc.l	NULL
BorderVectors33a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText33
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText33	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText33
	dc.b	' VirusExpert',0
	even
	
Gadg34	dc.l	Gadg35		;next gadget
	dc.w	405,120		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border34		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText34		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function34		;ptr to user-definable data
Border34
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors34	;ptr to xy vectors
	dc.l	Border34a		;next border in list
BorderVectors34
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border34a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors34a
	dc.l	NULL
BorderVectors34a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText34
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText34	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText34
	dc.b	' VirusX',0
	even

Gadg35	dc.l	Gadg36		;next gadget
	dc.w	405,135		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border35		;gadget border or image to be rendered
	dc.l	NULL		;alt image to be rendered
	dc.l	IText35		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	NULL		;ptr to user-definable data
Border35
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors35	;ptr to xy vectors
	dc.l	Border35a		;next border in list
BorderVectors35
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border35a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors35a
	dc.l	NULL
BorderVectors35a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText35
	dc.b	3,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText35	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText35
	dc.b	' Monitor Utils',0
	even

Gadg36	dc.l	Gadg37		;next gadget
	dc.w	405,150		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border36		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText36		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function36		;ptr to user-definable data
Border36
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors36	;ptr to xy vectors
	dc.l	Border36a		;next border in list
BorderVectors36
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border36a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors36a
	dc.l	NULL
BorderVectors36a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText36
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText36	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText36
	dc.b	' ArtMon',0
	even

Gadg37	dc.l	Gadg38		;next gadget
	dc.w	405,165		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border37		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText37		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function37		;ptr to user-definable data
Border37
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors37	;ptr to xy vectors
	dc.l	Border37a		;next border in list
BorderVectors37
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border37a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors37a
	dc.l	NULL
BorderVectors37a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText37
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText37	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText37
	dc.b	' Xoper',0
	even
	
Gadg38	dc.l	Gadg39		;next gadget
	dc.w	405,180		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border38		;gadget border or image to be rendered
	dc.l	NULL		;alt image to be rendered
	dc.l	IText38		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	NULL		;ptr to user-definable data
Border38
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors38	;ptr to xy vectors
	dc.l	Border38a		;next border in list
BorderVectors38
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border38a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors38a
	dc.l	NULL
BorderVectors38a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText38
	dc.b	3,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText38	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText38
	dc.b	' Other',0
	even
	
Gadg39	dc.l	Gadg40		;next gadget
	dc.w	405,195		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border39		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText39		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function39		;ptr to user-definable data
Border39
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors39	;ptr to xy vectors
	dc.l	Border39a		;next border in list
BorderVectors39
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border39a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors39a
	dc.l	NULL
BorderVectors39a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText39
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText39	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText39
	dc.b	' Greets.Doc',0
	even

Gadg40	dc.l	Gadg41		;next gadget
	dc.w	405,210		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border40		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText40		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function40		;ptr to user-definable data
Border40
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors40	;ptr to xy vectors
	dc.l	Border40a		;next border in list
BorderVectors40
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border40a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors40a
	dc.l	NULL
BorderVectors40a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText40
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1	;xy origin relative to container topleft
	dc.l	NULL	;font ptr or null for default
	dc.l	ITextText40	;ptr to text
	dc.l	NULL	;next intuitext struct
ITextText40
	dc.b	' PowerPacker.Doc',0
	even

Gadg41	dc.l	Gadg42		;next gadget
	dc.w	405,225		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border41		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText41		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function41		;ptr to user-definable data
Border41
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors41	;ptr to xy vectors
	dc.l	Border41a		;next border in list
BorderVectors41
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border41a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors41a
	dc.l	NULL
BorderVectors41a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText41
	dc.b	1,0,RP_JAM1,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1		;xy origin relative to container topleft
	dc.l	NULL		;font ptr or null for default
	dc.l	ITextText41		;ptr to text
	dc.l	NULL		;next intuitext struct
ITextText41
	dc.b	' 3rd Day.Info',0
	even

Gadg42	dc.l	sleepgadg		;next gadget
	dc.w	405,240		;xy of hit box relt to win topleft
	dc.w	150,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Border42		;gadget border or image to be rendered
	dc.l	AltBorder		;alt image to be rendered
	dc.l	IText42		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	function42		;ptr to user-definable data
Border42
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	BorderVectors42	;ptr to xy vectors
	dc.l	Border42a		;next border in list
BorderVectors42
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
	
	
	
Border42a
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	BorderVectors42a
	dc.l	NULL
BorderVectors42a
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	

	
		
IText42
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1		;xy origin relative to container topleft
	dc.l	NULL		;font ptr or null for default
	dc.l	ITextText42		;ptr to text
	dc.l	NULL		;next intuitext struct
ITextText42
	dc.b	' QuickRam.Doc',0
	even

sleepgadg	dc.l	aboutgadg		;next gadget
	dc.w	10,15		;xy of hit box relt to win topleft
	dc.w	60,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	slpborder		;gadget border or image to be rendered
	dc.l	Altslpborder	;alt image to be rendered
	dc.l	IText43		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	snooze		;ptr to user-definable data
slpborder
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	SlpBorderVectors	;ptr to xy vectors
	dc.l	SlpBordera		;next border in list
SlpBorderVectors
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	63,0
	
	
	
SlpBordera
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	SlpBorderVectorsa
	dc.l	NULL
SlpBorderVectorsa
	dc.w	0,0
	dc.w	63,0
	dc.w	63,-10
	

Altslpborder
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	2,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	AltSlpBorderVectors	;ptr to xy vectors
	dc.l	AltSlpBordera	;next border in list
AltSlpBorderVectors
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	63,0
	
	
AltSlpBordera
	dc.w	1,10		
	dc.b	1,0,RP_JAM1
	dc.b	3
	dc.l	AltSlpBorderVectorsa
	dc.l	NULL
AltSlpBorderVectorsa
	dc.w	0,0
	dc.w	63,0
	dc.w	63,-10
	
	
IText43
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1		;xy origin relative to container topleft
	dc.l	NULL		;font ptr or null for default
	dc.l	ITextText43		;ptr to text
	dc.l	NULL		;next intuitext struct
ITextText43
	dc.b	' SLEEP',0
	even
	

aboutgadg	dc.l	NULL		;next gadget
	dc.w	10,30		;xy of hit box relt to win topleft
	dc.w	60,9		;hit box width and height
	dc.w	GADGHIMAGE		;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	AbtBorder		;gadget border or image to be rendered
	dc.l	AltAbtBorder	;alt image to be rendered
	dc.l	IText44		;first intuitext struct
	dc.l	NULL		;gadget mutual-exclude long word
	dc.l	NULL		;specialinfo struct
	dc.w	NULL		;user-definable data
	dc.l	disp_about		;ptr to user-definable data
AbtBorder
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	1,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	AbtBorderVectors	;ptr to xy vectors
	dc.l	AbtBordera		;next border in list
AbtBorderVectors
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	63,0
AbtBordera
	dc.w	1,10		
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	AbtBorderVectorsa
	dc.l	NULL
AbtBorderVectorsa
	dc.w	0,0
	dc.w	63,0
	dc.w	63,-10
	
	
AltAbtBorder
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	2,0,RP_JAM1		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	AltAbtBorderVectors	;ptr to xy vectors
	dc.l	AltAbtBordera	;next border in list
AltAbtBorderVectors
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	63,0
	
		
AltAbtBordera
	dc.w	1,10		
	dc.b	1,0,RP_JAM1
	dc.b	3
	dc.l	AltAbtBorderVectorsa
	dc.l	NULL
AltAbtBorderVectorsa
	dc.w	0,0
	dc.w	63,0
	dc.w	63,-10
	
		
IText44
	dc.b	1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w	1,1		;xy origin relative to container topleft
	dc.l	NULL		;font ptr or null for default
	dc.l	ITextText44		;ptr to text
	dc.l	NULL		;next intuitext struct
ITextText44
	dc.b	' ABOUT',0
	even

		
********************************************************************
*
*  Gadget structure for alternative images
*
*********************************************************************

AltBorder
	dc.w	-1,-1		;xy origin relative to container topleft
	dc.b	2,0,RP_JAM2		;front pen,back pen and draw mode
	dc.b	3		;number of xy vectors
	dc.l	AltBorderVectors	;ptr to xy vectors
	dc.l	AltBordera		;next border in list
AltBorderVectors
	dc.w	0,10		;x,y pos lines
	dc.w	0,0
	dc.w	153,0
AltBordera
	dc.w	1,10		
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	AltBorderVectorsa
	dc.l	NULL
AltBorderVectorsa
	dc.w	0,0
	dc.w	153,0
	dc.w	153,-10
	even


