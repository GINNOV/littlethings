	

; ©1991 Mask Maker Version 1.0    by Raistlin of DragonMasters/Unity

; To get the best results from this sub-routine you will probably want
; to optimise the code, feel free.


	move.l	#Bob,a0			; A0=Address of the bob data
	move.l	#BobMask,a1		; A1=Address of where mask will
					; go
	move.l	width,d0		; width of bob in words
	move.l	height,d1		; Height of bob in lines-1
	move.l	bpls,d2			; Amount of bitplanes-1
MaskLoop
	move.w	(a0)+,d3		; Copy bob data into d3
	or.w	d3,(a1)+		; Build the mask
	
	dbra	d0,MaskLoop	
	
	move.l	width,d0		; Reset width counter
	dbra	d1,Maskloop		; Decrease height counter

	move.l	width,d0		; Reset width counter
	move.l	Height,d1		; Reset height counter
	move.l	#BobMask,a1		; Reset mask pointer
	dbra	d2,MaskLoop		; Decrement bitplane counter


Width	dc.l	10			; Width in words-1
Height	dc.l	54			; Height-1
bpls	dc.l	3			; Amount of bitplanes-1

