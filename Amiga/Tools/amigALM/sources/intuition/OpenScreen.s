OpenLibrary	= -552
CloseLibrary	= -414
OpenScreen	= -198
CloseScreen	= -66

;--------------------------------------;

	bsr.b	OpenInt
	bsr.b	OpenScn
	bsr.b	WaitMse
	bsr.b	ClseScn
	bsr.b	ClseInt
	moveq	#0,d0
	rts

;--------------------------------------;

WaitMse	btst	#2,$dff016
	bne.b	WaitMse
	rts

;--------------------------------------;

OpenInt	move.l	4.w,a6
	moveq	#0,d0
	lea	IntName(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,IntBase
	rts

ClseInt	move.l	4.w,a6
	move.l	IntBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenScn	move.l	IntBase(pc),a6
	lea	ScnDef1(pc),a0
	jsr	OpenScreen(a6)
	move.l	d0,ScnHD1
	rts

ClseScn	move.l	IntBase(pc),a6
	move.l	ScnHD1(pc),a0
	jsr	CloseScreen(a6)
	rts

;--------------------------------------;

ScnHD1	dc.l	0
ScnDef1	dc.w	0,0			;X & Y
	dc.w	320,256			;Width & Height
	dc.w	2			;Bitplanes
	dc.b	2,1			;Colours
	dc.w	0			;Mode
	dc.w	0			;Type
	dc.l	0			;Font
	dc.l	Title			;Title
	dc.l	0			;Gadget
	dc.l	0			;Bitmap
Title	dc.b	"Title",0

;--------------------------------------;

IntName	dc.b	"intuition.library",0
IntBase	dc.l	0

