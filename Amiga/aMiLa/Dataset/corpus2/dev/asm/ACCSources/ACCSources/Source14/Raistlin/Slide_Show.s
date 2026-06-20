
; Source Code Slide Show
 
; The grafix where ripped from a Fraxion slide show

; All coding by Raistlin

; The slide show uses Nicos pplib so piccys may be crunched

; 1991 Dragon Masters prduction in association with Unity

; *NB  If this was a real attempt at a slide show the sprite
;      data, blank screen data, etc. should have memory allocated
;      for them. 






; Tab settings = 8
	
	opt	c-
	
	incdir	sys:include/
	include	source:include/hardware.i
	include	exec/types.i
	include	source:include/ppbase.i
	include	source:include/powerpacker_lib.i
	
; A macro that simplifies calling Nico's library.
		
CALLNICO	macro
	move.l		_PPBase,a6
	jsr		_LVO\1(a6)
	endm

***************************************************************************
;			Start Of Source Code 
***************************************************************************
	lea	$dff000,a5		; Offset in a5

	move.l	4,a6			; Exec base in a6

;Load GraphicsLibrary
	lea	gfxname,a1		; name of lib to load in a1
	move.l	#0,d0			; Any version
	jsr	-552(a6)		; Open gfx lib
	move.l	d0,gfxbase	
	beq	quit1
;Load PowerPacker Libary
	lea	PPName,a1		; a1->library name
	moveq.l	#0,d0			; any version
	jsr	-552(a6)		; open the library
	move.l	d0,_PPBase		; save base pointer
	beq	quit1			; leave if no library

	jsr	-132(a6)		; Forbid

***************************************************************************
;			Blank the screen
***************************************************************************
Load_Bitplane_Pointers
	move.l	#screen,d0		; Address of screen in d0
	
	move.w	d0,bpl1+2		; Load the bitplane pointers
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
	swap	d0
	add.l	#256*40,d0

; Load the sprite pointers
	move.l	#spritee,d0		; Dummy sprite in d0
	move.w	d0,sp1l+2		; All sprite channels 
	move.w	d0,sp2h+2		; zeroed (no sprites)
	move.w	d0,sp2l+2
	move.w	d0,sp2h+2
	move.w	d0,sp3l+2
	move.w	d0,sp3h+2
	move.w	d0,sp4l+2
	move.w	d0,sp4h+2
	move.w	d0,sp5l+2
	move.w	d0,sp5h+2
	move.w	d0,sp6l+2
	move.w	d0,sp6h+2
	move.w	d0,sp7l+2
	move.w	d0,sp7h+2
	move.w	d0,sp8l+2
	move.w	d0,sp8h+2

***************************************************************************		
;		Set-up DMA the way I like it!
***************************************************************************
	move.w	#$8e30,dmacon(a5)	; Enable sprites
	move.l	#Copperlist,cop1lch(a5)	; Insert my copper list
	move.w	#0,copjmp1(a5)		; Run my copper list


***************************************************************************
;   Set-up parameters to pass to multi-load routine for 1st piccy
***************************************************************************
Start
	move.l	DECR_NONE,d0		; Decruunch options in d0
	move.l	#2,d1			; D1=Memory type (chip)
	move.l	#pic1name,filename	; filename=Address containing name
					; of file to load
	move.l	#pic1,buffer		; Buffer=Address to load file
	move.l	#pic1length,length	; Length=Length of file loaded
 				
	jsr	Multi_Load		; Load the gfx
	cmpi.l	#0,d7			; Error code present?
	beq	clean_up		; If so exit

	move.l	pic1,d0			; Address of gfx in d0
	add.l	#256*40*5,d0		; Offset for colour map in d0
	bsr	Make_Palette		; Get piccys colour palette

; Blit tiles for picture1
	move.l	#Offset1,a0		; Address of the offsets in a0
	move.l	pic1,tiles		; Address of picture in tiles
	bsr	tiler			; Blit the tiles


; Give-up memory help for gfx
	move.l	pic1length,d0		; D0=Length of buffer
	move.l	pic1,a1			; A1=Address of buffer
	jsr	Freememory		; Free the memory


***************************************************************************
;   Set-up parameters to pass to multi-load routine for 2nd piccy
***************************************************************************
	move.l	DECR_NONE,d0		; Decruunch options in d0
	move.l	#2,d1			; D1=Memory type
	move.l	#pic2name,filename	; filename=Address containing name
					; of file to load
	move.l	#pic2,buffer		; Buffer=Address to load file
	move.l	#pic2length,length	; Length=Length of file loaded
 				
	jsr	Multi_Load		; Load the gfx
	cmpi.l	#0,d7			; Any errors?
	beq	clean_up		; If so exit

Mouse_wait1
	btst	#6,$bfe001		; Wait for LMB
	bne	Mouse_wait1

	bsr	blanker			; Blank the current screen

	move.l	pic2,d0			; Address of gfx in d0
	add.l	#256*40*5,d0		; Add offset for piccys colour palette
	bsr	Make_Palette		; Get piccys colour palette

; Blit tiles for picture2
	move.l	#Offset1,a0		; Address of the offsets in a0
	move.l	pic2,tiles		; Address of picture in tiles
	bsr	tiler			; Blit the tiles


; Give-up memory help for gfx
	move.l	pic2length,d0		; D0=Length of buffer
	move.l	pic2,a1			; A1=Address of buffer
	jsr	Freememory		; Free the memory



***************************************************************************
;   Set-up parameters to pass to multi-load routine for 3rd piccy
***************************************************************************
	move.l	DECR_NONE,d0		; Decruunch options in d0
	move.l	#2,d1			; D1=Memory type
	move.l	#pic3name,filename	; filename=Address containing name
					; of file to load
	move.l	#pic3,buffer		; Buffer=Address to load file
	move.l	#pic3length,length	; Length=Length of file loaded
 				
	jsr	Multi_Load		; Load the gfx
	cmpi.l	#0,d7			; Error code
	beq	clean_up

Mouse_wait3
	btst	#6,$bfe001		; Wait for LMB
	bne	Mouse_wait3

	bsr	blanker			; Blank the current screen

	move.l	pic3,d0			; Address of gfx in d0
	add.l	#256*40*5,d0		; Add offset for piccys colour palette
	bsr	Make_Palette		; Get piccys colour palette

; Blit tiles for picture3
	move.l	#Offset1,a0		; Address of the offsets in a0
	move.l	pic3,tiles		; Address of picture in tiles
	bsr	tiler			; Blit the tiles

Mouse_wait4
	btst	#$6,$bfe001		; Wait for LMB
	bne	Mouse_wait4

	bsr	blanker			; Blank the screen

; Give-up memory help for gfx
	move.l	pic3length,d0		; D0=Length of buffer
	move.l	pic3,a1			; A1=Address of buffer
	jsr	Freememory		; Free the memory
	bra	clean_up		; Tidy up ready to evacuate


***************************************************************************
;			Blit tiles
***************************************************************************
Tiler
	move.l	#spritee,d0		; Dummy sprite in d0
	move.w	d0,sp1l+2		; Point sprite pointer
	move.w	d0,sp1h+2		; at dummy address
	move.l	#79,d0			; Amount of offsets -1
	move.l	#256*40,Bobsize		; size of each plane of picture 
	move.w	#36,Amodulo		; A Modulo
	move.l	#50,pausey		; Pause time
Tiler_Loop	
	bsr	pause			; Pause
	bsr	blitter			; blit tile
	dbra	d0,Tiler_Loop		; Decrease d0
	rts


; This part blanks the screen again
Blanker
	move.l	#spritee,d0		; Dummy sprite in d0
	move.w	d0,sp1l+2		; Point sprite pointer
	move.w	d0,sp1h+2		; at dummy address
	move.w	#$0,Amodulo		; No A modulo
	move.l	#Blanktile,tiles	; Address of tile in tiles
	move.l	#0,bobsize		; Only one plane for tile
	move.l	#79,d0			; Amount of offsets -1
	move.l	#offset1,a0		; Address of offsets in a0
	move.l	#10,pausey		; Reduce pause time
blanker_Loop
	bsr	pause			; Pause
	bsr	blitter			; Blit tile
	dbra	d0,blanker_loop		; Decrease d0
	rts


*****************************************************************************
; 		Slow down the tile bliting
*****************************************************************************
pause
	move.l	pausey,d2		; Length of pause
paused
	cmpi.b	#200,$dff006		; Check for VBL
	bne	paused
	dbra	d2,paused		; Decrement pause
	rts


***************************************************************************
;		This is the clean-up section
***************************************************************************
Clean_up
quit3	move.w	#$8e30,dmacon(a5)	; En-able sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	; Insert sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
quit2	move.l	4,a6			; A6=Exec base
	move.l	_PPBase,a1		; a1=Base address of PPlibrary
	jsr	-408(a6)		; Close PP library
quit1	move.l	4,a6			; Exec base in a6
	move.l	gfxbase,a1		; A1=Address of gfx base
	jsr	-408(a6)		; Close gfx lib
	jsr	-138(a6)		; Permit
quit	rts				; Quit


; A sub-routine to free the memory
Freememory
	move.l	4,a6
	jsr	-210(a6)		; release memory
	rts


****************************************************************************
;		This part is the actual multi-load
****************************************************************************
Multi_Load
	move.l	filename,a0		; a0->name of loadfile
	move.l	buffer,a1		; a1->space for buf addr
	move.l	length,a2		; a2->space for len
	move.l	#0,a3			; a3=> no password
	CALLNICO ppLoadData		; load the file
	tst.l	d0			; test for error
	bne	error			; leave if found
	move.l	#1,d7			; No errors
	move.l	#sprite,d0		; D0=address of 'R' sprite
	move.w	d0,sp1l+2		; Point sprite pointers
	swap	d0			; at 'R' sprite
	move.w	d0,sp1h+2
	rts				; and resturn

error
	move.l	#0,d7			; My personel error code
	rts



; Load colours into table
Make_Palette
	lea	colours,a3		; Address of colours in CList
	move.l	d0,a4			; Address of colours in file
	move.w	#$180,d0		; d0=Colorregister 0
	moveq.l	#31,d5			; D5=Number of colours to load

Colloop
	move.w	d0,(a3)+		; Insert color register into a3
	move.w	(a4)+,(a3)+		; Color into a3
	addq.l	#2,d0			; Next colour register in d0
	dbra	d5,colloop		; Keep loading colours until end
	rts



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





***************************************************************************
;		This is the copperlist
***************************************************************************
	Section	CopperList,data_c	; Chip ram
Copperlist
	dc.w	diwstrt,$2c81	
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
planes	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0
	
colours	
	dc.w	color00,$000,color01,$000,color02,$000,color03,$000
	dc.w	color04,$000,color05,$000,color06,$000,color07,$000
	dc.w	color08,$000,color09,$000,color10,$000,color11,$000
	dc.w	color12,$000,color13,$000,color14,$000,color15,$000
	dc.w	color16,$000,color17,$000,color18,$000,color19,$000
	dc.w	color20,$000,color21,$000,color22,$000,color23,$000
	dc.w	color24,$000,color25,$000,color26,$000,color27,$000
	dc.w	color28,$000,color29,$000,color30,$000,color31,$000	

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
	
sp1h	dc.w	spr0pth,$0
sp1l	dc.w	spr0ptl,$0
sp2h	dc.w	spr1pth,$0
sp2l	dc.w	spr1ptl,$0
sp3h	dc.w	spr2pth,$0	
sp3l	dc.w	spr2ptl,$0
sp4h	dc.w	spr3pth,$0
sp4l	dc.w	spr3ptl,$0	
sp5h	dc.w	spr4pth,$0
sp5l	dc.w	spr4ptl,$0
sp6h	dc.w	spr5pth,$0	
sp6l	dc.w	spr5ptl,$0
sp7h	dc.w	spr6pth,$0
sp7l	dc.w	spr6ptl,$0
sp8h	dc.w	spr7pth,$0
sp8l	dc.w	spr7ptl,$0


	dc.w	$ffff,$fffe


***************************************************************************
;			The Sprite Data
***************************************************************************
sprite
	dc.w	$35ca,$4100	SPRxPOS,SPRxCTL
	dc.w	$0f98,$0000
	dc.w	$3f2c,$0000
	dc.w	$624c,$0000
	dc.w	$848c,$0000
	dc.w	$0908,$0000
	dc.w	$1b10,$0000
	dc.w	$1b20,$0000
	dc.w	$1bc0,$0000
	dc.w	$1b38,$0000
	dc.w	$1b0c,$0000
	dc.w	$130c,$0000
	dc.w	$020c,$0000
	dc.w	$3c0e,$0000
	dc.w	$4e4c,$0000
	dc.w	$8388,$0000
	dc.w	$8000,$0000
	dc.w	$6000,$0000
spritee	dc.w	$0000,$0000	Sprite End



***************************************************************************
			; Variables
***************************************************************************
; Variables for librarys
PPName	PPNAME
	even
_PPBase	dc.l	0


gfxbase	dc.l	0

gfxname	dc.b	'graphics.library',0

; Variables for multi-load
length	dc.l	0			; space to store buffer length
filename dc.l	0			
buffer	dc.l	0			; Address of where to load file


; Data for picture 1 file
pic1name dc.b	'source:bitmaps/Fellowship.gfx',0
pic1length dc.l	0
pic1	dc.l	0

; Data for picture 2 file
pic2name dc.b	'source:bitmaps/dwafs.gfx',0	; oops, should be dwarfs
pic2length dc.l	0
pic2	dc.l	0


; Data for picture 3 file
pic3name dc.b	'source:bitmaps/necromancer.gfx',0
pic3length dc.l	0
pic3	dc.l	0



pausey	dc.l	50			; Pause length (1 second)
blanktile dcb.b	32*4,0			; Data for a blank tile
screen	dcb.b	256*40*5,0		; Data for blank screen
Amodulo	dc.w	0			; Size of the source modulo
bobsize	dc.l	0			; Size of each picture plane
tiles	dc.l	0			; Holds address of picture to use
					; as tiles


Offsets					; Determine where block is blitted
; The offsets
; The screen is viewed as:-
; 0	4	8	12	16	20	24	28	32
;32x40	32x40+4	32x40+8	32x40+12 etc....etc.....etc....etc.....etc
;64x40  64x40+4 64*40+8

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


