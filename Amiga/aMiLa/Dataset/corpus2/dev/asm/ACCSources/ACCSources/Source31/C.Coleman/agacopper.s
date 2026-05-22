;	Source Code:	AGACopper.s
;
;	Produce AGA copperlist
;	graduated background blue-cyan
;	in  256 shades
;	Written by Chris Colman
;	August 1993

	INCLUDE	Registers.s


; ** Initialization **

Start:
	move.l	Execbase,a6
	jsr	Disable(a6)		; Stop Multitasking
	lea	$dff000,a5
	move.w	#$03e0,DMACON(a5)	; Turn off DMA	
					; except disk and audio
	lea.l	Graduate,a1		; Ready to make Copperlist
	move.l	#255,d0			; 256 lines / shades
MakeBack:
	move.l	#290,d1			
	move.l	#255,d2
	sub.l	d0,d2			; Increase green 0 - 255
	sub.l	d0,d1	
	move.l	d1,d4			; Beam posn 35 - 290
	move.b	d1,(a1)+		; Wait for Beam y posn.
	move.b	#$0f,(a1)+		; Horizontal blanking
	move.w	#$fffe,(a1)+		; Mask
	move.l	#$01060c40,(a1)+	; Select high 12 bits
	move.w	#$0180,(a1)+		; Color 0
	move.l	d2,d1
	and.l	#$f0,d1			; Get 4 MSB of green
	add.w	#$f,d1			; Add pure blue
	move.w	d1,(a1)+		; Put in copperlist 
	move.l	#$01060e40,(a1)+	; Low 12 bits
	move.w	#$0180,(a1)+	
	move.l	d2,d1
	and.l	#$f,d1			; Get 4 LSB of green
	lsl.l	#4,d1			; Green = bits 4-7
	add.w	#$f,d1			; Add pure blue
	move.w	d1,(a1)+		; Put in copperlist
	cmp.l	#$ff,d4			; Have we just done line
	bne	Not255			; 255 ? If so then need
	move.l	#$ffdffffe,(a1)+	; delay before line 0
Not255:	dbra	d0,MakeBack		; Next line
	move.l	#Copperlist,COP1LC(a5)	; Load copper and
	clr.w	COPJMP1(a5)		; Strobe !
	move.w	#$8280,DMACON(a5)	; Re-enable copper DMA

mouse:	btst	#6,CIAAPRA		; Left button please
	bne	mouse

	move.l	#GRname,a1
	clr.l	d0
	jsr	OpenLibrary(a6)		; Get address of old
	move.l	d0,a4			; Copperlist (WB)
	move.l	StartList(a4),COP1LC(a5)
	clr.w	COPJMP1(a5)		; Strobe it !
	move.w	#$8360,DMACON(a5)	; Re-enable all DMA
	jsr	Enable(a6)		; Tasks on

End:
	clr.l	d0
	rts				; That's all folks

	even


CLadr:		dc.l	0
GRname:		dc.b	"graphics.library",0
Copperlist:	dc.w 	$2201,$fffe,$106,$c40
		dc.w	$180,$f,$106,$e40	; Start blue
		dc.w	$180,$f
Graduate:	ds.w	2562			; 256*10 words+2
		dc.w	$ffff,$fffe	; to skip line 256
		end
