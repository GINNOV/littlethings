**
** The Alliance Dox Menu 40chars version.
**
** Coded by Raistlin of Alliance (16.02.92)
**
** NOTE:- This is only a TEST version!!!!
**
**

; firebutton to exit

	incdir	""
	include	hardware.i		; Hardware offset
	section	Startup,code		; Public memory
;	opt	c-

*****************************
* This is The Start-Up Code *
*****************************
	lea	$dff000,a5		; Hardware offset

	move.l	4,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
;	beq	error
	
StartUp	
; Try allocating memory for the 3D screen (double buffered)
	move.l	#161*40*3,d0		; Size=161*320*3
	moveq.l	#2,d1			; CHIP memory
	jsr	-198(a6)		; Reserve memroy
	move.l	d0,DScreen		; Save memory
;	beq	error			; Exit if no memory
	move.l	#161*40*3,d0		; Size=161*320*3
	moveq.l	#2,d1			; CHIP memory
	jsr	-198(a6)		; Reserve memory
	move.l	d0,LScreen		; Save memory
;	beq	error			; Exit if no memory

; Allocate memory for the menu screen
	move.l	#161*40,d0		; Size=161*320
	moveq.l	#2,d1			; CHIP memory
	jsr	-198(a6)		; Reserve memory
	move.l	d0,VMScreen		; Save memory (this pointer for l8r)
	move.l	d0,MScreen		; Save memory (ptr for use)
;	beq	error			; Exit if no memory

; Alocate memory for scoller screen
	move.l	#19*46,d0		; Size =19*368
	moveq.l	#2,d1			; CHIP memory
	jsr	-198(a6)		; Reserve memory
	move.l	d0,VSScreen		; Save meory (this ptr 4 l8r)
	move.l	d0,SScreen1		; Save memory (ptr for use)
	move.l	d0,SScreen2		; Save ptr
	move.l	d0,SScreen3		; Save ptr
	jsr	-132(a6)		; Permit

******************
; Clear the memory
******************
ClearDMemory
	move.l	DScreen,a0		; A0=Ptr to 3D screen
	move.l	#4829,d0		; D0=Number of long words to clear-1
.Loop	move.l	#0,(a0)+		; Clear the memory
	dbra	d0,.Loop		
ClearLMemory
	move.l	LScreen,a0		; A0=Ptr to 3D screen
	move.l	#4829,d0		; D0=Number of long words to clear-1
.Loop	move.l	#0,(a0)+		; Clear the memory
	dbra	d0,.Loop		
ClearMenuMemory
	move.l	MScreen,a0		; A0=Ptr to menu screen
	move.l	#1609,d0		; D0=Number of long words to clear-1
.Loop	move.l	#0,(a0)+		; Clear the memory
	dbra	d0,.Loop
ClearScrollerMemory
	move.l	SScreen1,a0		; A0=Ptr to scroller screen
	move.l	#436,d0			; D0=Number of words to clear-1
.Loop	move.w	#0,(a0)+		; Clear the memory
	dbra	d0,.Loop

; Reset some variables

****************************************************************************
;		Load the sprite pointers
****************************************************************************
LoadSpritePointers

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************

	move.l	DScreen,d0		; Address of 3D screen
	move.w	d0,bplD1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bphD1+2
	swap	d0
	add.l	#40,d0
	move.w	d0,bplD2+2
	swap	d0
	move.w	d0,bphD2+2
	swap	d0
	add.l	#40,d0
	move.w	d0,bpld3+2
	swap	d0
	move.w	d0,bphD3+2

	move.l	MScreen,d0		; Menu screen
	move.w	d0,bplm1+2
	move.w	d0,bplm2+2
	swap	d0
	move.w	d0,bphm1+2
	move.w	d0,bphm2+2

	move.l	SScreen1,d0		; Scroller screen
	move.w	d0,bplS1+2
	swap	d0
	move.w	d0,bphS1+2

	add.l	#40*3,MScreen		; Set-up for menu
	move.l	MScreen,Mscreen2
	add.l	#40*64,Mscreen2
	add.l	#46,SScreen1		; Set-up for scroller
	add.l	#44,SScreen2		; Set-up for scroller
	add.l	#86,SScreen3		; Set-up for scroller

*****************************************************************************
;			  Set-Up DMA
*****************************************************************************
DMA
.Wait1	btst	#0,vposr(a5)		; Wait VBL
;	bne	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne	.Wait2
	move.w	#$8400,dmacon(a5)	; Blitter nasty
 	move.l	#Copperlist,cop1lch(a5)	; Insert new copper list
	move.w	#$0,copjmp1(a5)		; Run that copper list
	move.w	#0,$1fc(a5)
;	jsr	mt_init

*****************************************************************************
;			Main Branching Routine
*****************************************************************************
WaitVBL1
	cmpi.b	#$ff,vhposr(a5)		; Wait VBL
	bne	WaitVBL1

;	move.w	#$fff,$180(a5)		; Raster measure
	bsr	DoubleBuffer
;	bsr	ScrollText		; Move the Scroll Text
;	bsr	MoveCopper		; Move the copper bar
	cmpi.b	#$ff,d0			; Load file?
;	beq	Loader			; Load the file
	bsr	Wipeballs		; Wipe the balls
	bsr	Rotate			; Rotate the cords
	bsr	BlitBalls		; Blit the balls
	bsr	NewObject		; Need a new object?
;	bsr	LFadeInOut		; Fade the logos in & out
;	move.w	#$000,$180(a5)		; Raster measure

WaitVBL2
	cmpi.b	#$ff,vhposr(a5)		; Wait VBL
	bne	WaitVBL2
	
;	move.w	#$fff,$180(a5)		; Raster measure
;	bsr	ScrollText		; Move the Scroll Text
;	bsr	MoveCopper		; Update the copper bar
	cmpi.b	#$ff,d0			; Load file?
;	beq	Loader			; Load the file
;	bsr	ChangeMenu1		; Change the menu (2nd half)
;	move.w	#$000,$180(a5)		; Raster measure

WaitVBL3
	cmpi.b	#$ff,vhposr(a5)		; Wait VBL
	bne	WaitVBL3
	
;	move.w	#$fff,$180(a5)		; Raster measure
;	bsr	ScrollText		; Move the Scroll Text
;	bsr	ChangeMenu2		; Change the menu (2nd half)
;	bsr	MoveCopper		; Update the copper bar
	cmpi.b	#$ff,d0			; Load file?
;	beq	Loader			; Load the file

;	move.w	#$000,$180(a5)		; Raster measure


	btst	#6,$bfe001		; Test fire button
	beq	CleanUp			; Exit if pressed (development!)

	bra	WaitVBL1		; Forever & ever!


; Clean-up and exit
CleanUp
;	jsr	mt_end			; End d music
;	move.l	Oldint+2,$6c		; Restore sys interrupt
	move.w	#$0400,dmacon(a5)	; Blitter nice
	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
	move.l	4,a6			; Exec base
	move.l	#19*46,d0		; D0=Number of bytes to free
	move.l	VSScreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free it
	move.l	4,a6			; Exec base
	move.l	#161*40,d0		; D0=Number of bytes to free
	move.l	VMScreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free it
	move.l	4,a6			; Exec base
	move.l	#161*40*3,d0		; D0=Number of bytes to free
	move.l	LScreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free the memory
	move.l	4,a6			; Exec base
	move.l	#161*40*3,d0		; D0=Number of bytes
	move.l	DScreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free the memory
	jsr	-138(a6)		; Permit multi-tasking
	move.l	4,a6
	move.l	gfxbase,a1
	jsr	-414(a6)		; Close gfx
	moveq.l	#0,d0			; Keep CLI happy
	rts				; Byeeeeee



*****************************************************************************
;		New Objects -Changes object & fades in & out
*****************************************************************************
NewObject
	subi.w	#1,VDelay		; Decrement the delay
	cmpi.w	#0,VDelay		; Need new object?
	beq	Change			; Branch if yes
	blt	Fade			; Fade in the colours
	cmpi.w	#17,VDelay		; Fade out colours?
	blt	Fade			; Fade out colours
Decre	cmpi.w	#-17,VDelay		; Faded in?
	bne	.Exit
	move.w	#5*50,VDelay		; Reset delay
.Exit	rts				; Exit

; Change the object
Change	move.l	ObjectP,a0		; A0=Pointer to objects
	cmpi.l	#-1,(a0)		; No object
	bne	.Ok
	lea	Objects,a0		; Reset objects pointer
.Ok	move.l	(a0)+,StructP		; Insert new object ptr
	move.l	a0,ObjectP		; Save current object pointer
	rts				; exit

; The fade routine
Fade	move.l	StructP,a0		
	sub.w	#4,a0			; Get pointer to colour
	move.l	(a0),a0			; A0=Ptr to colours
	lea	VCols+2,a1		; A1=Ptr to copper
	moveq.l	#6,d0			; D0=Number of colours
	moveq.l	#0,d1			; Clear D1
	move.w	VDelay,d1		; D1=VDelay
	btst	#15,d1			; Is the number negative?
	beq	.Ok
	neg.w	d1			; Make D1 positive
.Ok	sub.w	#1,d1			; Turn into stage value
.Loop	moveq.l	#0,d2			; Clear D2
	moveq.l	#0,d3			; Clear D3
	move.b	(a0)+,d2		; D2=Red value
	mulu	d1,d2			; Multiply by stage value
	lsr.l	#4,d2			; Divide by 16
	move.b	d2,(a1)+		; Insert colour into copper
	move.b	(a0),d3			; D3=Green value
	lsr.b	#4,d3			; Put green value in low 4 bits
	mulu	d1,d3			; Multiply by stage value
	move.b	(a0)+,d2		; D2=Blut value
	and.w	#$f,d2			; Mask out green value
	mulu	d1,d2			; Multiply by stage value
	lsr.l	#4,d2			; Divide by 16
	and.w	#$f0,d3			; Mask out crap (keep green)
	or.b	d3,d2			; Or in green value
	move.b	d2,(a1)			; Insert value into copper
	addq.w	#3,a1			; Point to next value
	dbra	d0,.Loop
	bra	Decre

*****************************************************************************
;		This Routine Rotates The Vector Bobs
*****************************************************************************
Rotate
	move.l	StructP,a0		; A0=Pointer to structure
	lea	NewPoints,a1		; A1=Pointer to new structure space
	lea	Angles,a2		; A2=Ptr to angles of rotation
	lea	SineTable,a3		; A3=Ptr to sine table
	move.l	#25,d0			; D0=Number of balls to rotate
; D1=a  D2=b  D3=a  D4=b  D6=sin  D7=cos
; First find X1 Y1
RotLoop	move.w	(a0),d1			; D1=X
	move.w	2(a0),d2		; D2=Y
	move.w	d1,d3			; D3=X
	move.w	d2,d4			; D4=Y
	move.w	(a2),d6			; D6=Z angle of rotation
	move.w	d6,d7			; D7=Z angle of rotation
	add.w	#90,d7			; Add 90 for cos
	cmpi.w	#360,d7			; Exceeded 360 range?
	blt	.Nope
	sub.w	#360,d7			; Bring back into 360 range
.Nope	add.l	d6,d6			; Sine table in words
	add.l	d7,d7			; Sine table in words
	move.w	(a3,d6),d6		; D6=Sine value
	move.w	(a3,d7),d7		; D7=cos value
	
	muls	d7,d1			; D1=X.cos(0)
	muls	d6,d2			; D2=Y.sin(0)
	sub.l	d2,d1			; D1=X.cos(0) - Y.sin(0)
	asr.l	#7,d1			
	asr.l	#7,d1			; D1=X1
	muls	d7,d4			; D4=Y.cos(0)
	muls	d6,d3			; D3=X.sin(0)
	add.l	d4,d3			; D3=Y.cos(0) + X.sin(0)
	asr.l	#7,d3
	asr.l	#7,d3			; D3=Y1
	move.w	d3,2(a1)		; Save Y1
FindX2Z1
; Find X2 Z1
	move.w	4(a0),d2		; D2=Z
	move.w	d1,d3			; D3=X1
	move.w	d2,d4			; D4=Z
	move.w	2(a2),d6		; D6=Y angle of rotation
	move.w	d6,d7			; D7=Y angle of rotation
	add.w	#90,d7			; Add 90 for cos
	cmpi.w	#360,d7			; Exceeded 360 range?
	blt	.Nope
	sub.w	#360,d7			; Bring back into 360 range
.Nope	add.l	d6,d6			; Sine table in words
	add.l	d7,d7			; Sine table in words
	move.w	(a3,d6),d6		; D6=Sine value
	move.w	(a3,d7),d7		; D7=cos value
	
	muls	d7,d1			; D1=X1.cos(0)
	muls	d6,d2			; D2=Z.sin(0)
	sub.l	d2,d1			; D1=X1.cos(0) - Z.sin(0)
	asr.l	#7,d1			
	asr.l	#7,d1			; D1=X2
	muls	d7,d4			; D4=Z.cos(0)
	muls	d6,d3			; D3=X1.sin(0)
	add.l	d4,d3			; D3=Z.cos(0) + X1.sin(0)
	asr.l	#7,d3
	asr.l	#7,d3			; D3=Z1
	move.w	d1,(a1)			; Save X2
FindZ2Y2
; Find Y2 Z2
	move.w	2(a1),d2		; D2=Y1
	move.w	d3,d1			; D1=Z1
	move.w	d2,d4			; D4=Y1
	move.w	4(a2),d6		; D6=X angle of rotation
	move.w	d6,d7			; D7=X angle of rotation
	add.w	#90,d7			; Add 90 for cos
	cmpi.w	#360,d7			; Exceeded 360 range?
	blt	.Nope
	sub.w	#360,d7			; Bring back into 360 range
.Nope	add.l	d6,d6			; Sine table in words
	add.l	d7,d7			; Sine table in words
	move.w	(a3,d6),d6		; D6=Sine value
	move.w	(a3,d7),d7		; D7=cos value
	
	muls	d7,d1			; D1=Z1.cos(0)
	muls	d6,d2			; D2=Y1.sin(0)
	sub.l	d2,d1			; D1=Z1.cos(0) - Y1.sin(0)
	asr.l	#7,d1			
	asr.l	#7,d1			; D1=Z2
	muls	d7,d4			; D4=Y1.cos(0)
	muls	d6,d3			; D3=Z1.sin(0)
	add.l	d4,d3			; D3=Z1.cos(0) + Y1.sin(0)
	asr.l	#7,d3
	asr.l	#7,d3			; D3=Y2
	move.w	d1,4(a1)		; Save Z2
	move.w	d3,2(a1)		; Save Y2

	addq.w	#8,a0			; Get to next ball point
	addq.w	#8,a1			; Get to next ball point
	dbra	d0,RotLoop		; Rotate all balls

	addq.w	#2,(a2)			; Increment Z angle by 1
	cmpi.w	#360,(a2)		; Still in 360 range?
	blt	.DoY
	sub.w	#360,(a2)		; Bring back into 360 range
.DoY	addq.w	#4,2(a2)		; Increment Y angle by 3
	cmpi.w	#360,2(a2)		; Still in 360 range?
	blt	.DoX
	sub.w	#360,2(a2)		; Bring back into 360 range
.DoX	addq.w	#3,4(a2)		; Increment X angle by 2
	cmpi.w	#360,4(a2)		; Still in 360 range?
	blt	SortBalls
	sub.w	#360,4(a2)		; Bring back into 360 range

********* 
SortBalls
*********
; *NB  Sort routine coded by Treebeard of ALLIANCE!!!
	lea	NewPoints,a0
	move.l	#25,d7
	subq.l	#1,d7		; On 1st sort, look at (no. of points-1) after 1st,
				; -1 for dbra
Sort1
	move.l	d7,d6		; Keep d7 the same, use d6 instead
	move.l	a0,a1		; Ditto a0 and a1
	addq.l	#8,a1		; Start searching in entry after current one
	sub.l	a2,a2		; No smaller value found so far
	move.w	4(a0),d0	; d0=value to compare each entry with
.loop	cmp.w	4(a1),d0	; Is this entry<d0 ?
	ble	.ok		; Nope
	move.w	4(a1),d0	; d0=this entry
	move.l	a1,a2		; a2=address of this entry
.ok	addq.l	#8,a1		; Search others for smaller entry
	dbra	d6,.loop
	cmp.l	#0,a2		; Was a smaller value found?
	beq	.ok1		; Nope
	move.l	(a0),d0		; Swap first four bytes
	move.l	(a2),(a0)
	move.l	d0,(a2)+
	move.l	4(a0),d0	; Swap secound four bytes
	move.l	(a2),4(a0)
	move.l	d0,(a2)+
.ok1:
	addq.w	#8,a0		; a0=address of next entry to sort
	dbra	d7,Sort1	; sort other entries
	rts

**********************************************
* This Routine Blits The Balls To The Screen *
**********************************************
; Now blit the balls to the screen
BlitBalls	
	lea	NewPoints,a0		; A0=Address of new points
	move.l	#25,d0			; D0=Number of balls to blit
BlitLoop
	moveq.l	#0,d1			; Clear D1
	move.w	(a0),d1			; D1=X pos
	ext.l	d1			; Make D1 long
	add.l	#160,d1			; Add middle of screen
	divu	#16,d1			; Convert
	moveq.l	#0,d3			; Clear D3
	move.w	2(a0),d3		; D3=Y pos
	ext.l	d3			; Make D3 long
	add.l	#80,d3			; Add Y centre
	mulu	#40*3,d3		; Convert Y
	moveq.l	#0,d4			; Clear D4
	move.w	d1,d4			; D4=X offset
	add.l	d4,d4			; Turn X offset into bytes
	add.l	d4,d3			; Add X to Y
	add.l	LScreen,d3		; Add start of screen to X Y
	swap	d1	
	lsl.w	#8,d1			; Put shift in 4 MSB
	lsl.w	#4,d1
	move.w	#%111111110010,d2	; D2=Bltcon0 value
	or.w	d1,d2			; OR shift value
.Wait	btst	#14,dmaconr(a5)		; Wait for blitter
	bne	.Wait
	move.l	#Vectorbob,bltapth(a5)	; Source=Vector bob
	move.l	#VectorMask,bltbpth(a5)	; Source=Vector bob mask
	move.l	d3,bltcpth(a5)		; Source=Screen
	move.l	d3,bltdpth(a5)		; Destination=Screen
	move.w	#-2,bltamod(a5)		; 2-4
	move.w	#0,bltbmod(a5)		; 4-4
	move.w	#40-4,bltcmod(a5)
	move.w	#40-4,bltdmod(a5)
	move.w	#$ffff,bltafwm(a5)	; No FWM
	move.w	#$0000,bltalwm(a5)	; Full LWM
	move.w	d2,bltcon0(a5)
	move.w	d1,bltcon1(a5)
	move.w	#(16*64*3)+2,bltsize(a5) ; 16*32
	addq.w	#8,a0			; Point to next balls cords
	dbra	d0,BlitLoop		; Blit all balls
	rts
*****************************
* The Double Buffer Routine *
*****************************
DoubleBuffer
	move.l	LScreen,d0		; D0=LScreen
	move.l	DScreen,d1		; D1=Pscreen
	move.l	d0,DScreen		; D0=PScreen
	move.l	d1,LScreen		; D1=LScreen
	move.w	d0,bplD1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bphD1+2
	swap	d0
	add.w	#40,d0
	move.w	d0,bplD2+2
	swap	d0
	move.w	d0,bphD2+2
	swap	d0
	add.w	#40,d0
	move.w	d0,bpld3+2
	swap	d0
	move.w	d0,bphD3+2
	rts
**********************************************
* This Routine Wipes The Balls On The Screen *
**********************************************
WipeBalls
	btst	#14,dmaconr(a5)		; Wait for blitter to finish
	bne	WipeBalls
	move.l	LScreen,bltdpth(a5)	; Destination=Logical screen
	move.w	#$0,bltdmod(a5)		; No modulo
	move.w	#%100000000,bltcon0(a5)	; Wipe blit (D only)
	move.w	#(161*64*3)+20,bltsize(a5) ; 161x64*3
	rts


*****************************************************************************
;			Copper List
*****************************************************************************
	section	copper,data_c		; Chip data
Copperlist
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fect stop
	dc.w	bplcon0,%0100001000000000 ; 4 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,0		; No modulo (odd)
	dc.w	bpl2mod,0		; No modulo (even)
; The Sprite Pointers
sph0	dc.w	spr0pth,$0		
spl0	dc.w	spr0ptl,$0
sph1	dc.w	spr1pth,$0
spl1	dc.w	spr1ptl,$0
sph2	dc.w	spr2pth,$0
spl2	dc.w	spr2ptl,$0
sph3	dc.w	spr3pth,$0
spl3	dc.w	spr3ptl,$0
sph4	dc.w	spr4pth,$0
spl4	dc.w	spr4ptl,$0
sph5	dc.w	spr5pth,$0
spl5	dc.w	spr5ptl,$0
sph6	dc.w	spr6pth,$0
spl6	dc.w	spr6ptl,$0
sph7	dc.w	spr7pth,$0
spl7	dc.w	spr7ptl,$0
; Bitplane pointers
bph1L	dc.w	bpl1pth,$0	
bpl1L	dc.w	bpl1ptl,$0
bph2L	dc.w	bpl2pth,$0	
bpl2L	dc.w	bpl2ptl,$0
bph3L	dc.w	bpl3pth,$0	
bpl3L	dc.w	bpl3ptl,$0
bph4L	dc.w	bpl4pth,$0	
bpl4L	dc.w	bpl4ptl,$0
; Colours
; First 16 colours for the logo
LCCols	dc.w	$180,$000,$182,$fff,$184,$ddd,$186,$bbb
	dc.w	$188,$999,$18a,$777,$18c,$555,$18e,$666
	dc.w	$190,$0b6,$192,$0dd,$194,$0af,$196,$07c
	dc.w	$198,$00f,$19a,$70f,$19c,$800,$19e,$c08
; Last 16 colours for sprites	
	dc.w	$1a0,$000,$1a2,$ccc,$1a4,$ccc,$1a6,$ccc
	dc.w	$1a8,$000,$1aa,$ccc,$1ac,$ccc,$1ae,$ccc
	dc.w	$1b0,$000,$1b2,$ccc,$1b4,$ccc,$1b6,$ccc
*************
* 3D SCREEN *
*************
	dc.w	$7901,$fffe			; Wait
	dc.w	bplcon0,%0101011000000000	; 5 bitplanes (dual playfield)
	dc.w	bplcon1,$0			; Clear scroll register
	dc.w	bplcon2,%1000000		; Clear priority register
	dc.w	bpl1mod,80			; modulo 80 (odd)
	dc.w	bpl2mod,0			; No modulo (even)
; Bitplane pointers
bphd1	dc.w	bpl1pth,$0
bpld1	dc.w	bpl1ptl,$0
bphm1	dc.w	bpl2pth,$0
bplm1	dc.w	bpl2ptl,$0
bphd2	dc.w	bpl3pth,$0
bpld2	dc.w	bpl3ptl,$0
bphm2	dc.w	bpl4pth,$0
bplm2	dc.w	bpl4ptl,$0
bphd3	dc.w	bpl5pth,$0
bpld3	dc.w	bpl5ptl,$0
; Vector ball colours
	dc.w	$180,$000
VCols	dc.w	$182,$ebf,$184,$c8d,$186,$b6c	
	dc.w	$188,$a4a,$18a,$829,$18c,$717,$18e,$606

	dc.w	$196				; Menu colour
Wizcat	dc.w	$06f				; Colour of text
; Herz the copper bar that ya move up & down
Bar	dc.w	$bc01,$fffe,$196,$070
	dc.w	$bd01,$fffe,$196,$0a0
	dc.w	$be01,$fffe,$196,$0d0
	dc.w	$bf01,$fffe,$196,$0a0
	dc.w	$c001,$fffe,$196,$070
	dc.w	$c201,$fffe,$196
Wizcat2	dc.w	$06f

*******************
* SCROLLER SCREEN *
*******************
	dc.w	$ffe1,$fffe			; Pal wait
	dc.w	$1901,$fffe
	dc.w	bplcon0,%0001001000000000 	; 0 bitplanes
	dc.w	bplcon1,$0			; Clear scroll register
	dc.w	bplcon2,$0			; Clear priority register
	dc.w	bpl1mod,6			; 6 modulo (odd)
	dc.w	bpl2mod,6			; 6 modulo (even)
; Bitplane pointers
bphS1	dc.w	bpl1pth,$0	
bplS1	dc.w	bpl1ptl,$0
; Colours
	dc.w	$180,$000
	dc.w	$1a01,$fffe,$182,$20b		; Fade behind scroller
	dc.w	$1b01,$fffe,$182,$13b
	dc.w	$1c01,$fffe,$182,$16a
	dc.w	$1d01,$fffe,$182,$26c
	dc.w	$1e01,$fffe,$182,$47f
	dc.w	$1f01,$fffe,$182,$68f
	dc.w	$2001,$fffe,$182,$8ae
	dc.w	$2101,$fffe,$182,$bce
	dc.w	$2201,$fffe,$182,$eee
	dc.w	$2301,$fffe,$182,$7f7
	dc.w	$2401,$fffe,$182,$0b0
	dc.w	$2501,$fffe,$182,$0a1
	dc.w	$2601,$fffe,$182,$092
	dc.w	$2701,$fffe,$182,$082
	dc.w	$2801,$fffe,$182,$071
	dc.w	$2901,$fffe,$182,$051	

	dc.w	$ffff,$fffe		; Wait for lufc to win something!

*****************************************************************************
;			     Variables
*****************************************************************************
	section	variables,data		; Public
gfxname	dc.b	'graphics.library',0

	even
gfxbase	dc.l	0			; Space for gfx base address
DScreen	dc.l	0			; Physical Pointer
LScreen	dc.l	0			; Logical Pointer
MScreen	dc.l	0
MScreen2 dc.l	0
VMScreen dc.l	0
SScreen1 dc.l	0
SScreen2 dc.l	0
SScreen3 dc.l	0
VSScreen dc.l	0

; Variables for logos
;Logoptr	dc.l	Logo1
;Logobak	dc.l	Logo2
LDelay	dc.w	50*4
LCols	dc.w	$fff,$ddd,$bbb,$999,$777,$555,$666
	dc.w	$0b6,$0dd,$0af,$07c,$00f,$70f,$800,$c08
	even
*************************************
;-*-*- The Vector bob variables -*-*-
*************************************
Purple	dc.w	$ebf,$c8d,$b6c			; 4 colours of vector bobs
	dc.w	$a4a,$829,$717,$606
Blue	dc.w	$8ff,$6de,$5bd
	dc.w	$39c,$27c,$15b,$03a
Green	dc.w	$8f3,$6d2,$4c2
	dc.w	$3a1,$281,$170,$050
Gold	dc.w	$ff0,$ec0,$da0
	dc.w	$c70,$c50,$b40,$a20
; Pointers
ObjectP	dc.l	Objects				; Next object ptr
StructP	dc.l	Square			; Pointer to objects struct
Objects	dc.l	Spiral,Cube,Pyramid,Square,-1	; Objects
NewPoints	dcb.w	26*4,0			; Space for rotated balls
VDelay	dc.w	5*50				; 20 second delay
Angles
Z	dc.w	0				; Z angle
Y	dc.w	0				; Y angle
X	dc.w	0				; X angle
***********************
* THE BALL STRUCTURES *
***********************
; Structure for the square
;	Form of   X,  Y,  Z,  Null
	dc.l	Purple				; Colour=Blue
Square	dc.w	-32,-40,000,0			
	dc.w	-16,-40,000,0
	dc.w	000,-40,000,0
	dc.w	016,-40,000,0
	dc.w	032,-40,000,0
	dc.w	-32,-24,000,0
	dc.w	-16,-24,000,0
	dc.w	000,-24,000,0
	dc.w	016,-24,000,0
	dc.w	032,-24,000,0
	dc.w	-32,-08,000,0
	dc.w	-16,-08,000,0
	dc.w	000,-08,000,0
	dc.w	016,-08,000,0
	dc.w	032,-08,000,0
	dc.w	-32,008,000,0
	dc.w	-16,008,000,0
	dc.w	000,008,000,0
	dc.w	016,008,000,0
	dc.w	032,008,000,0
	dc.w	-32,024,000,0
	dc.w	-16,024,000,0
	dc.w	000,024,000,0
	dc.w	016,024,000,0
	dc.w	032,024,000,0
	dc.w	032,024,000,0		; 26th ball
; Structure for the cube
;	Form of   X,  Y,  Z,  Null
	dc.l	Green				; Colour=Green
Cube	dc.w	-16,-24,-16,0
	dc.w	000,-24,-16,0
	dc.w	016,-24,-16,0
	dc.w	-16,-08,-16,0
	dc.w	000,-08,-16,0
	dc.w	016,-08,-16,0
	dc.w	-16,008,-16,0
	dc.w	000,008,-16,0
	dc.w	016,008,-16,0
	dc.w	-16,-24,000,0
	dc.w	000,-24,000,0
	dc.w	016,-24,000,0
	dc.w	-16,-08,000,0
	dc.w	016,-08,000,0
	dc.w	-16,008,000,0
	dc.w	000,008,000,0
	dc.w	016,008,000,0
	dc.w	-16,-24,016,0
	dc.w	000,-24,016,0
	dc.w	016,-24,016,0
	dc.w	-16,-08,016,0
	dc.w	000,-08,016,0
	dc.w	016,-08,016,0
	dc.w	-16,008,016,0
	dc.w	000,008,016,0
	dc.w	016,008,016,0
; Structure for the spiral
;	Form of   X,  Y,  Z,  Null
	dc.l	Blue				; Colour=Blue
Spiral	
	dc.w	012,000,-36,0
	dc.w	024,000,-33,0
	dc.w	036,-12,-30,0
	dc.w	036,-24,-27,0
	dc.w	023,-36,-24,0
	dc.w	012,-36,-21,0
	dc.w	000,-24,-18,0
	dc.w	000,-12,-15,0
	dc.w	012,000,-12,0
	dc.w	024,000,-09,0
	dc.w	036,-12,-06,0
	dc.w	036,-24,-03,0
	dc.w	024,-36,000,0
	dc.w	012,-36,003,0
	dc.w	000,-24,006,0
	dc.w	000,-12,009,0
	dc.w	012,000,012,0
	dc.w	024,000,015,0
	dc.w	036,-12,018,0
	dc.w	036,-24,021,0
	dc.w	024,-36,024,0
	dc.w	012,-36,027,0
	dc.w	000,-24,030,0
	dc.w	000,-12,033,0
	dc.w	000,-24,030,0
	dc.w	000,-12,033,0
; Structure for the pyramid
;	Form of   X,  Y,  Z,  Null
	dc.l	Gold				; Colour=Blue
Pyramid	dc.w	-24,-24,-24,0
	dc.w	-08,-24,-24,0
	dc.w	008,-24,-24,0
	dc.w	024,-24,-24,0
	dc.w	-16,-08,-24,0
	dc.w	000,-08,-24,0
	dc.w	016,-08,-24,0
	dc.w	-08,008,-24,0	
	dc.w	008,008,-24,0	
	dc.w	000,024,-24,0	
	dc.w	-16,-16,-08,0
	dc.w	000,-16,-08,0
	dc.w	016,-16,-08,0
	dc.w	-08,000,-08,0
	dc.w	008,000,-08,0
	dc.w	000,016,-08,0
	dc.w	-08,-08,008,0
	dc.w	008,-08,008,0
	dc.w	000,008,008,0
	dc.w	000,000,024,0
	dc.w	-08,000,-08,0
	dc.w	008,000,-08,0
	dc.w	000,016,-08,0
	dc.w	-08,-08,008,0
	dc.w	008,-08,008,0
	dc.w	000,008,008,0

; Sine table for 3D routine.. 
SineTable ;(Mark Meany)
	dc.w 0,286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516
	dc.w 4790,5063,5334,5604,5872,6138,6402,6664
	dc.w 6924,7182,7438,7692,7943,8192,8438,8682		
	dc.w 8923,9162,9397,9630,9860,10087,10311,10531
	dc.w 10749,10963,11174,11381,11585,11786,11982,12176
	dc.w 12365,12551,12733,12911,13085,13255,13421,13583
	dc.w 13741,13894,14044,14189,14330,14466,14598,14726
	dc.w 14849,14968,15082,15191,15296,15396,15491,15582
	dc.w 15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374
	dc.w 16382,16384
	dc.w 16382
	dc.w 16374,16362,16344,16322,16294,16262,16225,16182
	dc.w 16135,16083,16026,15964,15897,15826,15749,15668		
	dc.w 15582,15491,15396,15296,15191,15082,14967,14849
	dc.w 14726,14598,14466,14330,14189,14044,13894,13741		
	dc.w 13583,13421,13255,13085,12911,12733,12551,12365
	dc.w 12176,11982,11786,11585,11381,11174,10963,10749
	dc.w 10531,10311,10087,9860,9630,9397,9162,8923
	dc.w 8682,8438,8192,7943,7692,7438,7182,6924
	dc.w 6664,6402,6138,5872,5604,5334,5063,4790
	dc.w 4516,4240,3964,3686,3406,3126,2845,2563
	dc.w 2280,1997,1713,1428,1143,857,572,286,0
	dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682		
	dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	dc.w -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
	dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	dc.w -16382,-16384
	dc.w -16382
	dc.w -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
	dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
	dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
	dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
	dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

*************************
* Chip Data & Variables *
*************************
	section	gfxstuff,data_c

Vectorbob:
	incbin 'vectorball.gfx'
Vectormask:
	incbin 'vectorball.mask'

