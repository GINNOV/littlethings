;-------------T----------T
start:	bsr.b	CalcShadeTones
	bsr.b	CalcShadeTable
	rts
;;=============================================================================
CalcShadeTable:
; this routine is SERIOUSLY unoptimised!!!
; and uses simple multiplication to calculate darker tones, should be
; REAL brightness with brigther tones also available!

	lea.l	OrigPalette,a0
	lea.l	ShadeTones,a1
	lea.l	ShadeTable,a2

	move.w	#256-1,d7
.lopy:	swap	d7
	move.l	a0,a3
	move.w	#256-1,d7
	move.w	(a1)+,d2	; current tone
.lopx:
	move.l	(a3)+,d0	; current color

	move.l	d0,d1		; current color
	and.l	#$ff,d1	; blue
	mulu	d2,d1
	lsr.l	#8,d1
	move.l	d1,d3

	move.l	d0,d1
	lsr.l	#8,d1
	and.l	#$ff,d1	; green
	mulu	d2,d1
	lsr.l	#8,d1
	ror.l	#8,d3
	move.b	d1,d3

	move.l	d0,d1
	swap	d1
	and.l	#$ff,d1	; red
	mulu	d2,d1
	lsr.l	#8,d1
	ror.l	#8,d3
	move.b	d1,d3
	swap	d3		; 0rgb

	move.l	d3,(a2)+

	dbf	d7,.lopx
	swap	d7
	dbf	d7,.lopy
	rts
;;=============================================================================
CalcShadeTones:
; this table should be editable by the user... REAL brightness should be used
; instead of just multiply shading!
	move.l	#$00000001,d0
	move.l	#$00020002,d1
	lea.l	ShadeTones,a0
	move.w	#256/2-1,d7
.lop:	move.l	d0,(a0)+
	add.l	d1,d0
	dbf	d7,.lop
	rts
;;=============================================================================
OrigPalette:	incbin	'backup:!ArtPRO/texture.pal'
; the textures original palette!
ShadeTones:	ds.w	256		; brightness, or?
; the shading tones, these shouldn't just be multiply, but real BRIGHTNESS
; (I don't know the procedure behind REAL brightness ajustments)
ShadeTable:	ds.l	256*256	; 256colors,256tones,24bit 
; RGB CHUNKY, 256x256, 0rgb

; this is the output shading table used by the routine to find the resulting
; color to a brightness operation by a simple lookup!
; this table is calculated in 24bit, and should be rendered into 256 colors
; pal+chunky and the palette is the one used in the routine... the original
; palette is ignored!
; 
; it is used in this way:
;
; lea.l     shadingtable,a0
; bsr.b     Pal.SetPalette	; use palette in a0
; lea.l     chunkyscreen,a0
; lea.l     texture+256*4,a1 ; ignore palette
; lea.l     shadingtable+256*4,a2 ; skip shading palette
; move.w    #tone<<8,d0		; store tone in upper byte
; move.b    (a1)+,d0		; store texture entry number in lower byte
; move.b    (a2,d0.l),(a0)+	; this could be reduced to d0.w by scrambling
;			; the shadetable.
;
; hope you can figure this out... otherwise just complain and I'll explain
; again! =)
