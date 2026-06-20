
; Data and service routine for an Integer gadget. The service routine sets
;the screen and window titles to whatever was entered into the Integer
;gadget. Also demonstrates how to re activate a string gadget after it
;has been de-activated.

; The text string entered can be found in the text buffer, labeled Buffer
;in the example below. The text will always be 0 terminated.

; The long word integer value can be read directly from the gadgets 
;SpecialInfo structure at the point LongInt. This is not demonstrated
;in this example, but the value is not used. To convince yourself you 
;could use Monam to set a breakpoint at the end of this subroutine and
;then examine the contents of d0.
;

Service		move.l		window.ptr,a0
		lea		Buffer,a1
		lea		Buffer,a2
		CALLINT		SetWindowTitles
		
; now reactivate the string gadget.

		move.l		window.ptr,a1
		lea		Gadg,a0
		sub.l		a2,a2		not a requester
		CALLINT		ActivateGadget
		
; now get the long word value into d0, but this routine does not use it!
; a5 still holds the address of the gadget structure at this point.

		move.l		gg_SpecialInfo(a5),a0
		move.l		si_LongInt(a0),d0
		
		rts	

;--------------	The Gadget structure

Gadg		dc.l		0		next gadget
		dc.w		52,45		origin XY of hit box
		dc.w		207,11		hit box width and height
		dc.w		0		gadget flags
		dc.w	RELVERIFY+STRINGCENTER+LONGINT	activation flags
		dc.w		STRGADGET	gadget type flags
		dc.l		Border1		gadget border
		dc.l		0		no alternate imagery
		dc.l		0		no text
		dc.l		0		no mutual-exclude
		dc.l		GadgSInfo	SpecialInfo structure
		dc.w		0		user-definable data
		dc.l		Service		address of service subroutine

;--------------	The assosiated StringInfo structure

GadgSInfo	dc.l		Buffer		buffer where text will be edited
		dc.l		UndoBuffer	optional undo buffer
		dc.w		0		char position in buffer
		dc.w		20		max number of chars
		dc.w		0		first displayed char position
		dc.w		0,0,0,0,0	Intuition variables
		dc.l		0		Rastport of gadget
		dc.l		0		init value for int gadgets
		dc.l		0		standard keymap

;--------------	The text buffers

Buffer		ds.b		20		buffer for text
		even
UndoBuffer	ds.b		20		undo buffer for text
		even

;--------------	The Border structure

Border1		dc.w		-2,-1		relative XY origin
		dc.b		3,0,RP_JAM1	front pen,back pen,drawmode
		dc.b		5		number of XY vectors
		dc.l		BordVectors	pointer to XY vectors
		dc.l		0		next border in list

;--------------	The Border Vectors or Verticies.

BordVectors	dc.w		0,0
		dc.w		210,0
		dc.w		210,12
		dc.w		0,12
		dc.w		0,0

