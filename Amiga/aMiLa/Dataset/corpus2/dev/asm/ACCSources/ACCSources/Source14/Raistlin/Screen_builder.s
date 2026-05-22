********************************************
** Coder: Raistlin                        **
** Code : Screen Builder		  **
** Date : 25th June 1991		  **
** Notes: See the doc file for more info  **
********************************************

	include	source:include/hardware.i
	opt	c-
	section	ScreenBuilder,code
	
	lea	$dff000,a5

	move.l	4,a6			; Exec base in a6

	lea	gfxname,a1		; Name of lib in a1
	move.l	#0,d0			; Any version
	jsr	-552(a6)		; Open lib
	move.l	d0,gfxbase		; Store base address
	beq	error			; Branch if error

	jsr	-132(a6)		; Forbid

	
*****************************************************************************
;		Make the blank screen
*****************************************************************************
	move.l	#screen,d0		; Address of screen in d0
	
	move.w	d0,bpl1+2		; Load the bpl pointers
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2
	
; Load my copper list & deactivate sprites
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#copperlist,cop1lch(a5)	; Load my copper list
	move.w	#$0,copjmp1(a5)		; Run my cop list


*****************************************************************************
;		Load in the piccy to blit tiles from
*****************************************************************************
	move.l	#pic1,tiles		; tiles=address of picture1
	move.l	tiles,d0		; Address of piccy in d0
	add.l	#256*40*5,d0		; Offset for its colour map
;Load colours into table
	lea	colours,a3		; Address of colours in CList
	move.l	d0,a4			; Address of colours in file
	move.w	#$180,d0		; d0=Colorregister 0
	moveq.l	#31,d5			; D5=Number of colours to load

Colloop
	move.w	d0,(a3)+		; Insert color register into a3
	move.w	(a4)+,(a3)+		; Color into a3
	addq.l	#2,d0			; Next colour register in d0
	dbra	d5,colloop		; Keep loading colours until end
	

; Blit tiles for picture1

	move.l	#Offset1,a0		; Address of the offsets in a0
	move.l	#79,d0			; Amount of offsets -1
	move.l	#256*40,Bobsize		; size of each plane of picture 
	move.w	#36,Amodulo
Tiler_Loop	
	bsr	pause			; Pause
	bsr	blitter			; blit tile
	dbra	d0,Tiler_Loop		; Decrease d0

Wait
	btst	#6,$bfe001
	bne	wait			; Wait for LMB

; This part blanks the screen again
	move.w	#$0,Amodulo		; No A modulo
	move.l	#Blanktile,tiles	; Address of tile in tiles
	move.l	#0,bobsize		; Only one plane for tile
	move.l	#79,d0			; Amount of offsets -1
	move.l	#offset1,a0		; Address of offsets in a0
blanker_Loop
	bsr	pause			; Pause
	bsr	blitter			; Blit tile
	dbra	d0,blanker_loop		; Decrease d0


*****************************************************************************
;		Mouse_Wait
*****************************************************************************
mouse_Wait
	btst	#6,$bfe001		; Test for LMB
	bne	mouse_wait		
	bra	clean_up

*****************************************************************************
; Slow down the tile bliting
*****************************************************************************
pause
	move.l	#50,d2			; Length of pause
pausey
	cmpi.b	#200,$dff006		; Check for VBL
	bne	pausey
	dbra	d2,pausey		; Decrement pause
	rts


*****************************************************************************
;			Clean Up the mess!!
*****************************************************************************
clean_up
	move.w	#$8e30,dmacon(a5)	; Enable sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run the sys copper list
	move.l	4,a6			; A6=Exec base
	move.l	gfxbase,a1
	jsr	-408(a6)		; Close the gfx lib
	jsr	-138(a6)		; Permit
error	rts


*****************************************************************************
;		The Blitter Operations
*****************************************************************************
Blitter
	lea	Screen,a1		; Address of the screen in a1
	move.l	Tiles,a2		; Address of the tiles screen in a2
	
	cmpi.l	#blanktile,tiles	; Is tile blank
	beq	NoTileOffset		; If so give it no offset

	add.l	(a0),a2			; Add offset to tiles (source)
NoTileOffset
	add.l	(a0)+,a1		; Add offset to screen (destination)
					; And increment to next offset

	move.l	#4,d1			; D1=number of bitplanes-1
Blit_Loop
	bsr	BlitterBusy		; Check blitter status
	bsr	Blit_Tiles 		; Blit the tile
	add.l	#256*40,a1		; Offset to second bitplane of screen
	add.l	bobsize,a2		; Offset to second bitplane of bob
	dbra	d1,Blit_Loop		; Keep blitting them tiles
	rts				; End of blitting

Blit_Tiles
	move.l	a2,bltapth(a5)		; Source 
	move.l	a1,bltdpth(a5)		; Destination
	move.w	Amodulo,bltamod(a5)		; 36 Source modulo
	move.w	#36,bltdmod(a5)		; 36 Destination moulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#$0,bltcon1(a5)
	move.w	#%0000100111110000,bltcon0(a5)	; Normal A-D blit
	move.w	#%100000000010,bltsize(a5)	; Bob size = 32x32
	rts

BlitterBusy
	btst	#14,$dff002		; Test blitter busy
	bne	BlitterBusy
	rts
		
*****************************************************************************
;			COPPER LIST
*****************************************************************************
	section	copper,data_c		; Chip RAM for chip & gfx data
copperlist
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0
	
colours	ds.w	64			; Reserve memory to build colours
					; into
bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0
bph5	dc.w	bpl5pth,$0
bpl5	dc.w	bpl5ptl,$0

	dc.w	$ffff,$fffe

*****************************************************************************
;			VARIABLES
*****************************************************************************
;Variables
gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0


blanktile dcb.b	32*4,0			; Data for a blank tile
screen	dcb.b	256*40*5,0		; Data for blank screen
Amodulo	dc.w	0			; Size of the source modulo
bobsize	dc.l	0			; Size of each picture plane
tiles	dc.l	0			; Holds address of picture to use
					; as tiles

pic1	incbin	source:bitmaps/necromancer.gfx	; Picture to use as tiles






Offsets					; Determine where block is blitted
; The offsets
; The screen is viewed as:-
; 0	4	8	12	16	20	24	28	32
;32x40	32x40+4	32x40+8	32x40+12 etc....etc.....etc....etc.....etc
;64x40  64x40+4 64*40+8
; etc............................................................

Offset1
	dc.l	0,4,8,12,16,20,24,28,32,36		
	dc.l	32*40+36,32*40+32,32*40+28,32*40+24,32*40+20,32*40+16,32*40+12,32*40+8,32*40+4,32*40+0
	dc.l	64*40+0,64*40+4,64*40+8,64*40+12,64*40+16,64*40+20,64*40+24,64*40+28,64*40+32,64*40+36
	dc.l	96*40+36,96*40+32,96*40+28,96*40+24,96*40+20,96*40+16,96*40+12,96*40+8,96*40+4,96*40+0
	dc.l	128*40+0,128*40+4,128*40+8,128*40+12,128*40+16,128*40+20,128*40+24,128*40+28,128*40+32,128*40+36
	dc.l	160*40+36,160*40+32,160*40+28,160*40+24,160*40+20,160*40+16,160*40+12,160*40+8,160*40+4,160*40+0
	dc.l	192*40+0,192*40+4,192*40+8,192*40+12,192*40+16,192*40+20,192*40+24,192*40+28,192*40+32,192*40+36
	dc.l	224*40+36,224*40+32,224*40+28,224*40+24,224*40+20,224*40+16,224*40+12,224*40+8,224*40+4,224*40+0
	dc.l	256*40+0,256*40+4,256*40+8,256*40+12,256*40+16,256*40+20,256*40+24,256*40+28,256*40+32,256*40+36


