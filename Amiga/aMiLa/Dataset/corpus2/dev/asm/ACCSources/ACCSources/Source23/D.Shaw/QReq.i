;This will be the new quit requester for the menu system because 
;(AutoRequest) looks so cheap.This will be inserted in the main file 
;as a include.

;----- Requester structure.

QuitReq
	dc.l		Null		OlderRequester
	dc.w		15,15		Container
	dc.w		252,51		width & height
	dc.w		Null		relleft
	dc.w		Null		reltop
	dc.l		RGlist		Gadgets to be rendered
	dc.l		RBorder		Borders to be rendered
	dc.l		RText		The text for requester
	dc.w		Null		IDCMP
	dc.b		Null		Backfill
	dc.b		Null		Kludgefill00
	dc.l		Null		Reqlayer
	ds.b		32		Reqpad1 (32 Bytes)
	dc.l		Null		Custom Bitmap
	dc.l		Null		Reqwindow
	ds.b		32		Reqpad2 (32 Bytes)
	even
	
;------ The text for the requester.

RText	dc.b		1,0,RP_JAM2	Front & back pen,drawmode
	dc.w		40,15		Text position
	dc.l		Null		Default font
	dc.l		.IText		The text
	dc.l		Null		Next text structure
	
.IText	dc.b		'QUIT, are you sure?',0
	even
	
;------ Border to enclose requester.

RBorder
	dc.w		0,0		xy origin
	dc.b		1,0,RP_JAM2	Front & back pen,drawmode
	dc.b		5		Number xy vectors
	dc.l		.Bordervectors	Ptr to xy vectors
	dc.l		Null		Next border
	
.Bordervectors
	dc.w		0,0
	dc.w		250,0
	dc.w		250,50		x,y pos lines
	dc.w		0,50
	dc.w		0,0
	
;------ Gadgets for requester.
RGlist
RGadg1	dc.l		RGadg2		;next gadget
	dc.w		15,35		;xy of hit box relt to win topleft
	dc.w		50,10		;hit box width and height
	dc.w		GADGHIMAGE	;gadget flags
	dc.w		RELVERIFY	;activation flags
	dc.w		BOOLGADGET+REQGADGET	;gadget type flags
	dc.l		GBorder		;gadget border or image to be rendered
	dc.l		GAltBorder	;alt image to be rendered
	dc.l		.IText		;first intuitext struct
	dc.l		Null		;gadget mutual-exclude long word
	dc.l		Null		;specialinfo struct
	dc.w		1		;Gadget ID
	dc.l		Null		;ptr to user-definable data
	
.IText
	dc.b		1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w		1,1		;xy origin relative to container topleft
	dc.l		Null		;font ptr or null for default
	dc.l		.ITextText	;ptr to text
	dc.l		Null		;next intuitext struct
.ITextText
	dc.b		' QUIT',0
	even

;------ Second gadget for requester.

RGadg2	dc.l		Null		;next gadget
	dc.w		185,35		;xy of hit box relt to win topleft
	dc.w		50,10		;hit box width and height
	dc.w		GADGHIMAGE	;gadget flags
	dc.w		RELVERIFY	;activation flags
	dc.w		BOOLGADGET+REQGADGET	;gadget type flags
	dc.l		GBorder		;gadget border or image to be rendered
	dc.l		GAltBorder	;alt image to be rendered
	dc.l		.IText		;first intuitext struct
	dc.l		Null		;gadget mutual-exclude long word
	dc.l		Null		;specialinfo struct
	dc.w		2		;Gadget ID
	dc.l		Null		;ptr to user-definable data

.IText
	dc.b		1,0,RP_JAM2,0	;front and back text pen,drawmode and fill byte
	dc.w		1,1		;xy origin relative to container topleft
	dc.l		Null		;font ptr or null for default
	dc.l		.ITextText	;ptr to text
	dc.l		Null		;next intuitext struct
.ITextText
	dc.b		' CONT',0
	even

;------ Shared primary border for gadgets.

GBorder	
	dc.w		-1,-1		;xy origin relative to container topleft
	dc.b		1,0,RP_JAM2	;front pen,back pen and draw mode
	dc.b		3		;number of xy vectors
	dc.l		.BorderVectors	;ptr to xy vectors
	dc.l		.Border2	;next border in list
.BorderVectors	
	dc.w		0,10		;x,y pos lines
	dc.w		0,0
	dc.w		50,0
.Border2	
	dc.w		1,10		
	dc.b		2,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		Null
.BorderVectors2
	dc.w		0,0
	dc.w		50,0
	dc.w		50,-10
	
;------ Shared secondary border for gadgets.

GAltBorder
	dc.w		-1,-1		;xy origin relative to container topleft
	dc.b		2,0,RP_JAM2	;front pen,back pen and draw mode
	dc.b		3		;number of xy vectors
	dc.l		.BorderVectors	;ptr to xy vectors
	dc.l		.Border2	;next border in list
.BorderVectors
	dc.w		0,10		;x,y pos lines
	dc.w		0,0
	dc.w		50,0
.Border2
	dc.w		1,10		
	dc.b		1,0,RP_JAM2
	dc.b		3
	dc.l		.BorderVectors2
	dc.l		Null
.BorderVectors2
	dc.w		0,0
	dc.w		50,0
	dc.w		50,-10

