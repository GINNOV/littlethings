
; Example of a BOOLEAN toggle gadget with a border and no special imagery.
; M.Meany Jan 91

;--------------	First the service subroutine called when this gadget is hit.

; The state of the gadget can be determined by inspecting the SELECTED flag
;in the gadgets structure. Register a5 still holds the address of this
;structure on entering this subroutine. If gadget is in selected state then
;screen flashes, otherwise nothing happens.

Service		move.w		gg_Flags(a5),d0	get gadgets flags
		and.w		#SELECTED,d0	mask out selected flag
		beq.s		.do_nothing	branch if not set
		sub.l		a0,a0		clear a0
		CALLINT		DisplayBeep	do something !
.do_nothing	rts

;--------------	The gadget data structure.

Gadg		dc.l		0		next gadget
		dc.w		81,63		origin XY of hit box
		dc.w		166,29		hit box width and height
		dc.w		0		gadget flags
		dc.w	TOGGLESELECT+RELVERIFY	activation flags
		dc.w		BOOLGADGET	gadget type flags
		dc.l		GadgBorder	gadget border
		dc.l		0		imagery for selection
		dc.l		0		first IntuiText structure
		dc.l		0		mutual-exclude long word
		dc.l		0		SpecialInfo structure
		dc.w		0		user-definable data
		dc.l		Service		address of service subroutine

GadgBorder	dc.w		-2,-1		relative XY origin
		dc.b		3,0,RP_JAM1	front pen,back pen,drawmode
		dc.b		5		number of XY vectors
		dc.l		BordVectors	pointer to XY vectors
		dc.l		0		next border in list

BordVectors	dc.w		0,0
		dc.w		169,0
		dc.w		169,30
		dc.w		0,30
		dc.w		0,0
