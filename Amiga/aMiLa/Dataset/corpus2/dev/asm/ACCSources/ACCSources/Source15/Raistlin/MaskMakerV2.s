; MaskMaker Version 2.1  by Raistlin of DragonMasters
; This second version of MaskMaker was designed by me to get greater speed
; out of the routine.  It now blanks out the old data and allows modulo
; values incase your gfx is in a row.  The extra speed and option costs
; more memory.  So if memory is more important use version 1 (an estimated
; 50 or 60 bytes smaller.

; Just added a mask routine, this is extremely usefull when using the
; cookie cut routine as there is no bltalwm!!

; *Note  As I did you will probably altered this routine considerably to
;        get the best use out of it (in my latest demo its about 3x bigger)



	move.l	MModulo,d4		; D4=modulo
	move.l	Bob,a0			; A0=Address of the bob data
	move.l	BobMask,a1		; A1=Address of where mask will
					; go
	move.w	#$ffff,d5		; D6=Last Word Mask
	

	move.l	Mwidth,d0		; Width of bob in words-1
	move.l	Mheight,d1		; Height of bob in lines-1
MLoop1
	move.w	(a0)+,d3		; Copy bob data into d3
	move.w	d3,(a1)+		; Mask out old data and build new
	dbra	d0,MLoop1		; Keep building
	
	and.w	d5,-2(a1)		; Mask last word

	move.l	Mwidth,d0		; Reset width counter
	add.l	d4,a0			; Add the modulo value
	dbra	d1,Mloop1		; Keep building	
	


	move.l	Mwidth,d0		; width of bob in words-1
	move.l	Mheight,d1		; Height of bob in lines-1
	move.l	Mbpls,d2		; Amount of bitplanes-2
MaskLoop
	move.w	(a0)+,d3		; Copy bob data into d3
	or.w	d3,(a1)+		; Build the mask
	dbra	d0,MaskLoop	
	
	and.w	d5,-2(a1)		; Last word mask

	move.l	Mwidth,d0		; Reset width counter
	add.l	d4,a0			; Add the modulo value
	dbra	d1,Maskloop		; Decrease height counter

	move.l	Mwidth,d0		; Reset width counter
	move.l	MHeight,d1		; Reset height counter
	move.l	#BobMask,a1		; Reset mask pointer
	dbra	d2,MaskLoop		; Decrement bitplane counter

