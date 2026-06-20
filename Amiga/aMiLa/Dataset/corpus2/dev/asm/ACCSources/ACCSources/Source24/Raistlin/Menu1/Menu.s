**
** The Alliance Dox Menu 40chars version.
**
** Coded by Raistlin of Alliance (16.02.92)
**
** NOTE:- This is only a TEST version!!!!
**
**
	include	source:include/hardware.i		; Hardware offset
	section	Startup,code		; Public memory
	opt	c-

*****************************
* This is The Start-Up Code *
*****************************
	lea	$dff000,a5		; Hardware offset

	move.l	4,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error
	
	lea	dosname,a1		; Load dos library
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,dosbase		; Save dos base
 	beq	error
StartUp	
; Try allocating memory for the 3D screen (double buffered)
	move.l	#161*40*3,d0		; Size=161*320*3
	moveq.l	#2,d1			; CHIP memory
	jsr	-198(a6)		; Reserve memroy
	move.l	d0,DScreen		; Save memory
	beq	error			; Exit if no memory
	move.l	#161*40*3,d0		; Size=161*320*3
	moveq.l	#2,d1			; CHIP memory
	jsr	-198(a6)		; Reserve memory
	move.l	d0,LScreen		; Save memory
	beq	error			; Exit if no memory

; Allocate memory for the menu screen
	move.l	#161*40,d0		; Size=161*320
	moveq.l	#2,d1			; CHIP memory
	jsr	-198(a6)		; Reserve memory
	move.l	d0,VMScreen		; Save memory (this pointer for l8r)
	move.l	d0,MScreen		; Save memory (ptr for use)
	beq	error			; Exit if no memory

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
	move.l	#Menu0Text,TextP	; Textpointer=Main menu
	move.b	#1,MenuF		; Signal menu update
	move.b	#0,MenuC		; Menu counter
	move.l	#Text,STextP		; Reset scroll text pointer
	move.b	#0,PlopC		; Reset plop counter

****************************************************************************
;		Load the sprite pointers
****************************************************************************
LoadSpritePointers
.Wait1	btst	#0,vposr(a5)		; Wait for the vertival blank
	bne	.Wait1			; before manipulating
.Wait2	cmpi.b	#55,vhposr(a5)		; the grafix
	bne	.Wait2
	move.l	#Sprite1,d0		; D0=Address of sprite1
	move.w	d0,spl0+2
	swap	d0
	move.w	d0,sph0+2
	move.l	#Sprite2,d0		; D0=Address of sprite2
	move.w	d0,spl1+2
	swap	d0
	move.w	d0,sph1+2
	move.l	#Sprite3,d0		; D0=Address of sprite3
	move.w	d0,spl2+2
	swap	d0
	move.w	d0,sph2+2
	move.l	#SEND,d0		; D0=Dummy sprite data
	move.w	d0,spl3+2
	move.w	d0,spl4+2
	move.w	d0,spl5+2
	move.w	d0,spl6+2
	move.w	d0,spl7+2
	swap	d0
	move.w	d0,sph3+2
	move.w	d0,sph4+2
	move.w	d0,sph5+2
	move.w	d0,sph6+2
	move.w	d0,sph7+2

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************
	move.l	LogoPtr,d0		; D0=Address of logo
	move.w	d0,bpl1L+2
	swap	d0
	move.w	d0,bph1L+2
	swap	d0
	add.l	#40*79,d0
	move.w	d0,bpl2L+2
	swap	d0
	move.w	d0,bph2L+2
	swap	d0
	add.l	#40*79,d0
	move.w	d0,bpl3L+2
	swap	d0
	move.w	d0,bph3L+2
	swap	d0
	add.l	#40*79,d0
	move.w	d0,bpl4L+2
	swap	d0
	move.w	d0,bph4L+2	

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

************************
* SET-UP VBL INTERRUPT * - Naughty routine!
************************
	move.l	$6c,Oldint+2		; Save old interrupt
	move.l	#NewInt,$6c		; Insert mine

*****************************************************************************
;			  Set-Up DMA
*****************************************************************************
DMA
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne	.Wait2
	move.w	#$8400,dmacon(a5)	; Blitter nasty
 	move.l	#Copperlist,cop1lch(a5)	; Insert new copper list
	move.w	#$0,copjmp1(a5)		; Run that copper list
	jsr	mt_init

*****************************************************************************
;			Main Branching Routine
*****************************************************************************
WaitVBL1
	cmpi.b	#$ff,vhposr(a5)		; Wait VBL
	bne	WaitVBL1

;	move.w	#$fff,$180(a5)		; Raster measure
	bsr	DoubleBuffer
	bsr	ScrollText		; Move the Scroll Text
	bsr	MoveCopper		; Move the copper bar
	cmpi.b	#$ff,d0			; Load file?
	beq	Loader			; Load the file
	bsr	Wipeballs		; Wipe the balls
	bsr	Rotate			; Rotate the cords
	bsr	BlitBalls		; Blit the balls
	bsr	NewObject		; Need a new object?
	bsr	LFadeInOut		; Fade the logos in & out
;	move.w	#$000,$180(a5)		; Raster measure

WaitVBL2
	cmpi.b	#$ff,vhposr(a5)		; Wait VBL
	bne	WaitVBL2
	
;	move.w	#$fff,$180(a5)		; Raster measure
	bsr	ScrollText		; Move the Scroll Text
	bsr	MoveCopper		; Update the copper bar
	cmpi.b	#$ff,d0			; Load file?
	beq	Loader			; Load the file
	bsr	ChangeMenu1		; Change the menu (2nd half)
;	move.w	#$000,$180(a5)		; Raster measure

WaitVBL3
	cmpi.b	#$ff,vhposr(a5)		; Wait VBL
	bne	WaitVBL3
	
;	move.w	#$fff,$180(a5)		; Raster measure
	bsr	ScrollText		; Move the Scroll Text
	bsr	ChangeMenu2		; Change the menu (2nd half)
	bsr	MoveCopper		; Update the copper bar
	cmpi.b	#$ff,d0			; Load file?
	beq	Loader			; Load the file

;	move.w	#$000,$180(a5)		; Raster measure


	btst	#7,$bfe001		; Test fire button
	beq	CleanUp			; Exit if pressed (development!)

	bra	WaitVBL1		; Forever & ever!


; Clean-up and exit
CleanUp
	jsr	mt_end			; End d music
	move.l	Oldint+2,$6c		; Restore sys interrupt
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
	move.l	dosbase,a1		
	jsr	-414(a6)		; Close dos
	move.l	gfxbase,a1
	jsr	-414(a6)		; Close gfx
	moveq.l	#0,d0			; Keep CLI happy
	rts				; Byeeeeee

******************************************************************************
;      This Is The Cold Reset Code Recommended By Commodore Amiga
******************************************************************************
; Oh dear!  Wot the fuck went wrong?  Lets reset & try again!
; Magic Reset Code from the Amiga Hardware Reference Manual
error	move.l	4,a6			; Exec base
	lea	MagicResetCode(pc),a5	; Location of code to trap to
	jsr	-30(a6)			; Supervisor mode
	cnop	0,4			; Long word align
MagicResetCode	
	lea	2,a0			; Point to JMP instruction at 
					; start of ROM
	RESET				; All RAM goes away NOW!
	jmp	(a0)			; Rely on prefetch to execute 
					; this instruction

*****************************************************************************
;		This Is The Loader Routine
*****************************************************************************
Loader
; First clean-up my mess!
	jsr	mt_end			; End d music
	move.l	Oldint+2,$6c		; Restore sys interrupt
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
; Now open us a window!	
	move.l	dosbase,a6		; A6=Ptr to dos lib
	move.l	#1005,d0		; D0=Access mode
	move.l	d0,d2			; D2=Access mode
	lea	Conname,a1		; A1=Ptr to console
	move.l	a1,d1			; D1=Console address
	jsr	-30(a6)			; Open the window
	move.l	d0,conhdle		; Store con handle
	
	move.l	FilePtr,d1		; D1=Ptr to file		
	moveq.l	#0,d2			; No input
	move.l	Conhdle,d3		; Console handle
	jsr	-222(a6)		; Run the program

	move.l	Conhdle,d1
	jsr	-36(a6)			; Close the window
	move.l	4,a6			; Exec base
	jsr	-132(a6)		; Forbid Multi-tasking
	jmp	StartUp			; and start again!


*********************
* The VBL Interrupt *
*********************
NewInt	movem.l	a0-a6/d0-d7,-(sp)
	jsr	mt_music		; Play the music
	bsr	MoveStars		; Move the stars
	movem.l	(sp)+,a0-a6/d0-d7
OldInt	jmp	$0			; Perform sys interrupt


*****************************************************************************
;  		This Routine Fades The Logos In/Out
*****************************************************************************
; Decrement delay & fade/alter bpls
LFadeInOut	
	subq.w	#1,LDelay		; Decrement delay
	beq	LogoScreen		; Need a change?
	cmpi.w	#17,LDelay		; A long way togo?
	bgt	.Yeah
	cmpi.w	#0,LDelay		; Need to change screen?
	move.w	LDelay,d0		; D0=LDelay value
	cmpi.w	#-1,d0
	bgt	.Fade			; Fade the logo
	neg	d0			; Make d0 positive
	cmpi.w	#17,d0			; Fully faded in?
	bne	.Fade
	move.w	#50*4,LDelay		; Insert new fade value
.Fade	moveq.l	#14,d7			; D7=Number of cols-1
	lea	LCols,a0		; A0=ptr to cols for fade
	lea	LCCols+6,a1		; A1=ptr to cols in copper
	subq.w	#1,d0			; Decerement delay value
.Loop	moveq.l	#0,d1			; Clear D1
	moveq.l	#0,d2			; Clear D2
	move.b	(a0)+,d1		; D1=Red component
	mulu	d0,d1			; Multiply by colour stage
	lsr.w	#4,d1			; Divide by 16
	move.b	d1,(a1)+		; Insert new red component
	move.b	(a0),d1			; D1=Green,Blue component
	lsr.b	#4,d1			; Put Green in 4 LSB
	mulu	d0,d1			; Multiply by colour stage
	and.b	#$f0,d1			; Mask out crap
	move.b	(a0)+,d2		; D2=Green,Blue component
	and.b	#$f,d2			; Mask out Green component
	mulu	d0,d2			; Multiply by colour stage
	lsr.w	#4,d2			; Divide by 16
	or.w	d2,d1			; OR blue with green
	move.b	d1,(a1)+		; Insert GREEN BLUE
	addq.l	#2,a1			; Get to next colour in copper
	dbra	d7,.Loop
.Yeah	rts
; Set-up the logo screen
LogoScreen
	move.l	Logobak,d0		; D0=Ptr to next logo
	move.l	LogoPtr,d1		; D1=Ptr to current Logo
	move.l	d0,LogoPtr		; Swap ptrs
	move.l	d1,Logobak
	move.w	d0,bpl1L+2		
	swap	d0
	move.w	d0,bph1L+2
	swap	d0
	add.l	#79*40,d0	
	move.w	d0,bpl2L+2
	swap	d0
	move.w	d0,bph2L+2
	swap	d0
	add.l	#79*40,d0
	move.w	d0,bpl3L+2
	swap	d0
	move.w	d0,bph3L+2
	swap	d0
	add.l	#79*40,d0
	move.w	d0,bpl4L+2
	swap	d0
	move.w	d0,bph4L+2
	rts
	


*****************************************************************************
;		The Scroll Text Routine
*****************************************************************************
ScrollText
	cmpi.w	#0,Pause		; Need a pause?
	beq	.No
	sub.w	#1,Pause		; Decrement pause
	rts
.No	cmpi.b	#0,PlopC		; Need a new character?
	bne	Scroller
	move.l	STextP,a0		; A0=Character to blit
.Check	cmpi.b	#'x',(a0)		; Termination character?
	bne	.Nope
	lea	Text,a0
.Nope	cmpi.b	#$0a,(a0)		; Character Return?
	bne	.Nope1
	addq.l	#1,a0			; Incrmement a0
	bra	.Check
.Nope1	cmpi.b	#'p',(a0)		; Pause code?
	bne	.Nope2
	addq.l	#1,a0			; Increment a0
	move.w	#50*5,Pause		; Save pause value
	move.l	a0,STextP		; Save text pointer
	rts
.Nope2	moveq.l	#0,d0			; Clear d0
	move.b	(a0)+,d0		; D0=Character to blit
	move.l	a0,STextP		; Save text ptr
	sub.b	#32,d0			; convert
	add.l	d0,d0			; Double D0 value
	lea	Font2,a0		; A0=Address of font
	add.w	d0,a0			; Add offset
.Wait	btst	#14,dmaconr(a5)		; Test blitter
	bne	.Wait
	move.l	a0,bltapth(a5)		; A=character
	move.l	SScreen3,bltdpth(a5)	; D=Screen
	move.w	#118-2,bltamod(a5)	; 116 A modulo
	move.w	#46-2,bltdmod(a5)	; 44 D modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%100111110000,bltcon0(a5) ; A-D blit
	move.w	#$0,bltcon1(a5)		; clear
	move.w	#(15*64)+1,bltsize(a5)	; 15*16
	move.b	#8,PlopC		; Reset plop counter

Scroller
	btst	#14,dmaconr(a5)		; Wait blitter
	bne	Scroller
	move.l	SScreen1,bltapth(a5)	; A Source=Scroller
	move.l	SScreen2,bltdpth(a5)	; D Source=Scroller-2
	move.w	#0,bltamod(a5)		; No modulos
	move.w	#0,bltdmod(a5)
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%1110100111110000,bltcon0(a5) ; A-D blit 14 shift
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#(15*64)+23,bltsize(a5)	; 368*16
	subq.b	#1,PlopC		; Decrement plop counter
	rts

*****************************************************************************
;    This Routine Moves The Copper Bar And Tests For A Mouse But Press
*****************************************************************************
MoveCopper
	move.w	joy0dat(a5),d0		; D0=Vert/Horiz
	lsr.w	#8,d0			; Put horiz in Low Byte
	move.b	d0,d1			; D1=Copy of Vert count
	sub.b	OldV,d0			; Subtract old vertical count
	move.b	d0,d2			; D2=Copy of d0
	asr.b	#4,d0			; Lets make it less sensitive!	
	neg.b	d2			; Make D2 positive
	asr.b	#4,d2			; Lets make it less sensitive!

	tst.b	d0			; Wor woz it?
	beq	TestButs
	bgt	Down
	tst.b	d2			; Try down
	bne	Up			; If result is negative move bar up
	bra	TestButs

Down	move.b	d1,OldV			; Save this vertical count
	lea	Bar,a0			; A0=Pointer to the bar structure
	cmpi.b	#$f4,(a0)		; Already at bottom?
	beq	TestButs
	moveq.l	#8,d0			; D0=Initial increment
Downy1	moveq.l	#0,d1			; Clear D1
	move.b	(a0),d1			; D1=Vert bar value	
	add.l	d0,d1			; Increment value
	cmpi.b	#$fc,d1			; Reached bottom?
	beq	TestButs		; Ok, sod it!
	sub.l	#$7c,d1			; Convert Vert position
	lsr.l	#3,d1			; Divide by 8
	mulu	#40,d1			; Multiply by number of chars per line
	moveq.l	#0,d2			; Dlear D2
	move.b	MenuC,d2		; D2=Menu number
	mulu	#16*40,d2
	add.l	d1,d2			
	lea	Menu0Text,a1		; A1=Ptr to menu
	add.w	d2,a1			; Add offset
	moveq.l	#39,d7			; Counter
.Loop	cmpi.b	#32,(a1)+		; Space?
	bne	downy2			; Exit if not
	dbra	d7,.Loop
	addq.l	#8,d0		
	move.b	(a0),d6			; D6=Next vert value	
	add.l	d0,d6
	bra	Downy1
Downy2	add.b	d0,(a0)			; Increment all 8 waits
	add.b	d0,8(a0)
	add.b	d0,16(a0)
	add.b	d0,24(a0)
	add.b	d0,32(a0)
	add.b	d0,40(a0)
	bra	TestButs

; The Up routine
Up	move.b	d1,OldV			; Save this vertical count
	lea	Bar,a0			; A0=Ptr to bar structure
	cmpi.b	#$7c,(a0)		; Already at top?
	beq	TestButs
	moveq.l	#8,d0			; D0=Initial increment
Upy1	moveq.l	#0,d1			; Clear D1
	move.b	(a0),d1			; D1=Vert bar value	
	sub.l	d0,d1			; Decrement value
	cmpi.b	#$74,d1			; Reached top?
	beq	TestButs		; Ok, sod it!
	sub.l	#$7c,d1			; Convert Vert position
	lsr.l	#3,d1			; Divide by 8
	mulu	#40,d1			; Multiply by number of chars per line
	moveq.l	#0,d2			; Dlear D2
	move.b	MenuC,d2		; D2=Menu number
	mulu	#16*40,d2
	add.l	d1,d2			
	lea	Menu0Text,a1		; A1=Ptr to menu
	add.w	d2,a1			; Add offset
	moveq.l	#39,d7			; Counter
.Loop	cmpi.b	#32,(a1)+		; Space?
	bne	Upy2			; Exit if not
	dbra	d7,.Loop
	addq.l	#8,d0		
	move.b	(a0),d6			; D6=Next vert value	
	sub.l	d0,d6
	bra	Upy1
Upy2	sub.b	d0,(a0)			; Increment all 8 waits
	sub.b	d0,8(a0)
	sub.b	d0,16(a0)
	sub.b	d0,24(a0)
	sub.b	d0,32(a0)
	sub.b	d0,40(a0)

; Now test for the mouse buttons
TestButs
	btst	#$a,potgor(a5)		; RMB pressed?
	bne	TestLeft
	move.l	#Menu0Text,TextP	; Text ptr=menu 1
	move.b	#1,MenuF		; Display new menu
	move.b	#0,MenuC		; Where displaying menu 1
	moveq.l	#0,d0			; Clear D0
	rts
TestLeft
	btst	#6,$bfe001		; Test left mouse button
	bne	.Release?
	move.b	#$ff,LMB		; Store press code
	moveq.l	#0,d0			; Clear D0
	rts				; Exit
.Release?
	and.b	#$ff,LMB		; Mask out numbers
	bne	.Ok			; Exit if not set
	moveq.l	#0,d0			; Clear D0
	rts
.Ok	move.b	#0,LMB			; Clear
	cmpi.b	#0,MenuC		; Are we on menu page?
	beq	NewMenu			; If so set-up new menu

; This Routine Finds The File To Load 
LoadFile
	moveq.l	#0,d0			; Clear d0
	move.b	bar,d0			; D0=Vertical wait value of bar
	sub.b	#$74,d0			; Convert number into multiple fo eight
	lsr.l	#3,d0			; Convert into file number (1-16)
	subq.l	#1,d0			

	moveq.l	#0,d1			; Clear d1
	move.b	MenuC,d1		; D1=Menu number
	subq.l	#1,d1			
	lsl.l	#4,d1			; Multiply by 16 (16 files per menu)

	add.l	d0,d1			; D1=Offset to file 
	lsl.l	#2,d1			; Multiply by 4 (ptrs are long words)

	lea	FileStart,a4		; A4=Ptr to file ptrs
	add.w	d1,a4			; Add the offset
	move.l	(a4),a4			; A4=Pointer to file name
	cmpi.b	#$0,(a4)		; File disabled?
	bne	.Ok
	moveq.b	#0,d0			; Clear D0
	rts				; File is disabled
.Ok	move.l	a4,FilePtr		; Save pointer to file
	move.b	#$ff,d0			; Set LOAD flag
	rts				; Exit

; This Routine Sets-up a new menu 
NewMenu
	moveq.l	#0,d0			; Clear d0
	move.b	bar,d0			; D0=Copper bar vertical wait
	sub.b	#$74,d0			; Convert number into multiple of 8
	lsr.l	#3,d0			; Convert into menu number (ie 1-16)
	move.l	MenuSet,d1		; D1=Menu statuss'
	btst.l	d0,d1			; Is this menu set?
	bne	.Ok			; Hey, no probs
	moveq.l	#0,d0			; Clear D0
	rts				; OI This menu aint set, LAMER!
.Ok	move.b	d0,MenuC		; MenuC=Menu number to view
	mulu	#16*40,d0		; Find offset from menu start
	lea	Menu0Text,a0		; A0=Start address of all menu text
	add.w	d0,a0			; A0=Ptr to menu text
	move.l	a0,TextP		; TextP=pointer to text
	move.b	#1,MenuF		; Signal that menu is to be updated
	moveq.l	#0,d0			; Clear D0
	rts				; Ext

*****************************************************************************
;		This Routine Moves The New Menus In And Out
*****************************************************************************
; For a 40 character per line menu the menu must be built in two halves or
; else the routine is too slow!
ChangeMenu1
	cmpi.b	#0,MenuF		; Do we need a change?
	bne	.Yep
	rts
.Yep	move.l	TextP,a0		; A0=Ptr to text
	move.l	MScreen,a2		; A2=Ptr to screen
	moveq.l	#0,d6			; Clear line counter
	move.l	#(20*16)-1,d7		; D7=Number of characters to print
.MainLoop
	moveq.l	#0,d0			; Clear d0
	move.b	(a0)+,d0		; D0=Character to print
	sub.b	#32,d0			; Convert
	move.l	a2,a3			; A3=Backup ptr to screen
	lea	font,a1			; A1=Ptr to font
	add.w	d0,a1			; Get to offset for character
	moveq.l	#4,d1			; D1=Number of lines per character-1
.Loop	move.b	(a1),(a3)		; move character into screen
	add.w	#68,a1			; Get to next line of font
	add.w	#40,a3			; Get to next line of screen
	dbra	d1,.Loop		; Display all 5 lines of character

	addq.w	#1,a2			; Point to next pos to display char
	addq.l	#1,d6			; Increment line counter
	cmpi.b	#40,d6			; New line?
	bne	.Nope
	moveq.l	#0,d6			; Clear line counter
	add.l	#7*40,a2		; Point to next line
.Nope	dbra	d7,.MainLoop		; Display whole menu
	move.l	a0,TextP		; Save text pointer
	rts

ChangeMenu2
	cmpi.b	#0,MenuF		; Do we need a change?
	bne	.Yep
	rts
.Yep	move.b	#0,MenuF		; Clear menu flag
	move.l	TextP,a0		; A0=Ptr to text
	move.l	MScreen2,a2		; A2=Ptr to screen
	moveq.l	#0,d6			; Clear line counter
	move.l	#(20*16)-1,d7		; D7=Number of characters to print
.MainLoop
	moveq.l	#0,d0			; Clear d0
	move.b	(a0)+,d0		; D0=Character to print
	sub.b	#32,d0			; Convert
	move.l	a2,a3			; A3=Backup ptr to screen
	lea	font,a1			; A1=Ptr to font
	add.w	d0,a1			; Get to offset for character
	moveq.l	#4,d1			; D1=Number of lines per character-1
.Loop	move.b	(a1),(a3)		; move character into screen
	add.w	#68,a1			; Get to next line of font
	add.w	#40,a3			; Get to next line of screen
	dbra	d1,.Loop		; Display all 5 lines of character

	addq.w	#1,a2			; Point to next pos to display char
	addq.l	#1,d6			; Increment line counter
	cmpi.b	#40,d6			; New line?
	bne	.Nope
	moveq.l	#0,d6			; Clear line counter
	add.l	#7*40,a2		; Point to next line
.Nope	dbra	d7,.MainLoop		; Display whole menu
	rts

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
.ok1	addq.l	#8,a0		; a0=address of next entry to sort
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

**************************
* Section 1 The SarField *
**************************
Movestars
	lea	Sprite1,a0		; A0=Address of star field 1
	lea	Sprite2,a1		; A1=Address of star field 2
	lea	Sprite3,a2		; A2=Address of star field 3
	move.l	#55,d0			; D0=Number of stars to move-1
ScrollStars
.Loopy1
	addq.b	#1,1(a0)		; Move stars
	addq.b	#2,1(a1)
	addq.b	#3,1(a2)
	addq.w	#8,a0
	addq.w	#8,a1
	addq.w	#8,a2
	dbra	d0,.Loopy1
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
dosname	dc.b	'dos.library',0
	even
gfxbase	dc.l	0			; Space for gfx base address
dosbase	dc.l	0			; Space for dos base address
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
Logoptr	dc.l	Logo1
Logobak	dc.l	Logo2
LDelay	dc.w	50*4
LCols	dc.w	$fff,$ddd,$bbb,$999,$777,$555,$666
	dc.w	$0b6,$0dd,$0af,$07c,$00f,$70f,$800,$c08
***********************
; Copper move variables
***********************
OldV	dc.b	0			; Holds old mouse V count
LMB	dc.b	0			; Stores LMB press $ff
	even
**************************************************
;-*-* The menu pointers, counters, text etc...*-*-
**************************************************
TextP	dc.l	Menu0Text			; Ptr to menu text
Conhdle	dc.l	0
FilePtr	dc.l	0				; Pointer to file
Conname	dc.b	'CON:0/10/640/36/ALLIANCE....',0
MenuF	dc.b	1				; 1 =Signal to update menu
MenuC	dc.b	0				; Menu number -1
	include	'source:raistlin/menu1/misc/menus.i'	; Sart of menu text
	include	'source:raistlin/menu1/misc/files.i'	; The file list of file names!
	even
FileStart 
	dc.l	m1a,m1b,m1c,m1d,m1e,m1f,m1g,m1h,m1i,m1j,m1k,m1l,m1m,m1n,m1o,m1p
	dc.l	m2a,m2b,m2c,m2d,m2e,m2f,m2g,m2h,m2i,m2j,m2k,m2l,m2m,m2n,m2o,m2p
	dc.l	m3a,m3b,m3c,m3d,m3e,m3f,m3g,m3h,m3i,m3j,m3k,m4l,m3m,m3n,m3o,m3p
	dc.l	m4a,m4b,m4c,m4d,m4e,m4f,m4g,m4h,m4i,m4j,m4k,m4l,m4m,m4n,m4o,m4p
	dc.l	m5a,m5b,m5c,m5d,m5e,m5f,m5g,m5h,m5i,m5j,m5k,m5l,m5m,m5n,m5o,m5p
	dc.l	m6a,m6b,m6c,m6d,m6e,m6f,m6g,m6h,m6i,m6j,m6k,m6l,m6m,m6n,m6o,m6p
	dc.l	m7a,m7b,m7c,m7d,m7e,m7f,m7g,m7h,m7i,m7j,m7k,m7l,m7m,m7n,m7o,m7p
	dc.l	m8a,m8b,m8c,m8d,m8e,m8f,m8g,m8h,m8i,m8j,m8k,m8l,m8m,m8n,m8o,m8p
	dc.l	m9a,m9b,m9c,m9d,m9e,m9f,m9g,m9h,m9i,m9j,m9k,m9l,m9m,m9n,m9o,m9p
	dc.l	m10a,m10b,m10c,m10d,m10e,m10f,m10g,m10h,m10i,m10j,m10k,m10l,m10m,m10n,m10o,m10p
	dc.l	m11a,m11b,m11c,m11d,m11e,m11f,m11g,m11h,m11i,m11j,m11k,m11l,m11m,m11n,m11o,m11p
	dc.l	m12a,m12b,m12c,m12d,m12e,m12f,m12g,m12h,m12i,m12j,m12k,m12l,m12m,m12n,m12o,m12p
	dc.l	m13a,m13b,m13c,m13d,m13e,m13f,m13g,m13h,m13i,m13j,m13k,m13l,m13m,m13n,m13o,m13p
	dc.l	m14a,m14b,m14c,m14d,m14e,m14f,m14g,m14h,m14i,m14j,m14k,m14l,m14m,m14n,m14o,m14p
	dc.l	m15a,m15b,m15c,m15d,m15e,m15f,m15g,m15h,m15i,m15j,m15k,m15l,m15m,m15n,m15o,m15p
	dc.l	m16a,m16b,m16c,m16d,m16e,m16f,m16g,m16h,m16i,m16j,m16k,m16l,m16m,m16n,m16o,m16p

*************************************
;      The Scroller Variables
*************************************
STextP	dc.l	Text
Pause	dc.w	0				; Pause value
PlopC	dc.b	0
Text	dc.b	32				; Start with space
	incbin	'source:raistlin/menu1/misc/ScrollText.i'
	dc.b	'x'				; End code
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
font	incbin	'source:raistlin/menu1/gfx/chars.gfx'
Font2	incbin	'source:raistlin/menu1/gfx/font.gfx'
Vectorbob incbin 'source:raistlin/menu1/gfx/vectorball.gfx'
Vectormask incbin 'source:raistlin/menu1/gfx/vectorball.mask'
Logo1	incbin	'source:raistlin/menu1/gfx/Alliance.gfx'
Logo2	incbin	'source:raistlin/menu1/gfx/UpLogo.gfx'

*************************************
* The Sprite Data For The StarField *
*************************************
Sprite1	
	dc.w	$3006,$3100,$1000,$0000,$3444,$3500,$1000,$0000
	dc.w	$3988,$3a00,$1000,$0000,$3d7e,$3e00,$1000,$0000
	dc.w	$4055,$4100,$1000,$0000,$442c,$4500,$1000,$0000
	dc.w	$49cc,$4a00,$1000,$0000,$4d55,$4e00,$1000,$0000
	dc.w	$508b,$5100,$1000,$0000,$5421,$5500,$1000,$0000
	dc.w	$592d,$5a00,$1000,$0000,$5d53,$5e00,$1000,$0000
	dc.w	$6031,$6100,$1000,$0000,$64a6,$6500,$1000,$0000
	dc.w	$695f,$6a00,$1000,$0000,$6d73,$6e00,$1000,$0000
	dc.w	$7032,$7100,$1000,$0000,$74fb,$7500,$1000,$0000
	dc.w	$7923,$7a00,$1000,$0000,$7d40,$7e00,$1000,$0000
	dc.w	$806c,$8100,$1000,$0000,$84d5,$8500,$1000,$0000
	dc.w	$89c2,$8a00,$1000,$0000,$8ddd,$8e00,$1000,$0000
	dc.w	$90a0,$9100,$1000,$0000,$94ca,$9500,$1000,$0000
	dc.w	$9973,$9a00,$1000,$0000,$9dff,$9e00,$1000,$0000
	dc.w	$a0db,$a100,$1000,$0000,$a4b7,$a500,$1000,$0000
	dc.w	$a97c,$aa00,$1000,$0000,$ad36,$ae00,$1000,$0000
	dc.w	$b095,$b100,$1000,$0000,$b41a,$b500,$1000,$0000
	dc.w	$b9fa,$ba00,$1000,$0000,$bdc0,$be00,$1000,$0000
	dc.w	$c0ef,$c100,$1000,$0000,$c47f,$c500,$1000,$0000
	dc.w	$c91d,$ca00,$1000,$0000,$cdae,$ce00,$1000,$0000
	dc.w	$d0e9,$d100,$1000,$0000,$d40f,$d500,$1000,$0000
	dc.w	$d93f,$da00,$1000,$0000,$de5a,$df00,$1000,$0000
	dc.w	$e344,$e400,$1000,$0000,$e703,$e800,$1000,$0000
	dc.w	$ee42,$ef00,$1000,$0000,$f339,$f400,$1000,$0000
	dc.w	$f913,$fa00,$1000,$0000,$fd67,$fe00,$1000,$0000
	dc.w	$0575,$0606,$1000,$0000,$0a56,$0b06,$1000,$0000
	dc.w	$0f23,$1006,$1000,$0000,$1701,$1806,$1000,$0000
	dc.w	$1b87,$1c06,$1000,$0000,$1f45,$2006,$1000,$0000
SEnd	dc.w	$0000,$000
Sprite2	
	dc.w	$3106,$3200,$1000,$0000,$3544,$3600,$1000,$0000
	dc.w	$3a88,$3b00,$1000,$0000,$3e7e,$3f00,$1000,$0000
	dc.w	$4155,$4200,$1000,$0000,$452c,$4600,$1000,$0000
	dc.w	$4acc,$4b00,$1000,$0000,$4e55,$4f00,$1000,$0000
	dc.w	$518b,$5200,$1000,$0000,$5521,$5600,$1000,$0000
	dc.w	$5a2d,$5b00,$1000,$0000,$5e53,$5f00,$1000,$0000
	dc.w	$6131,$6200,$1000,$0000,$65a6,$6600,$1000,$0000
	dc.w	$6a5f,$6b00,$1000,$0000,$6e73,$6f00,$1000,$0000
	dc.w	$7132,$7200,$1000,$0000,$75fb,$7600,$1000,$0000
	dc.w	$7a23,$7b00,$1000,$0000,$7e40,$7f00,$1000,$0000
	dc.w	$816c,$8200,$1000,$0000,$85d5,$8600,$1000,$0000
	dc.w	$8ac2,$8b00,$1000,$0000,$8edd,$8f00,$1000,$0000
	dc.w	$91a0,$9200,$1000,$0000,$95ca,$9600,$1000,$0000
	dc.w	$9a73,$9b00,$1000,$0000,$9eff,$9f00,$1000,$0000
	dc.w	$a1db,$a200,$1000,$0000,$a5b7,$a600,$1000,$0000
	dc.w	$aa7c,$ab00,$1000,$0000,$ae36,$af00,$1000,$0000
	dc.w	$b195,$b200,$1000,$0000,$b51a,$b600,$1000,$0000
	dc.w	$bafa,$bb00,$1000,$0000,$bed0,$bf00,$1000,$0000
	dc.w	$c127,$c200,$1000,$0000,$c57f,$c600,$1000,$0000
	dc.w	$ca1d,$cb00,$1000,$0000,$ce6e,$cf00,$1000,$0000
	dc.w	$d1e9,$d200,$1000,$0000,$d50f,$d600,$1000,$0000
	dc.w	$da3f,$db00,$1000,$0000,$de5a,$df00,$1000,$0000
	dc.w	$e344,$e400,$1000,$0000,$e703,$e800,$1000,$0000
	dc.w	$ee42,$ef00,$1000,$0000,$f339,$f400,$1000,$0000
	dc.w	$f923,$fa00,$1000,$0000,$fdf7,$fe00,$1000,$0000
	dc.w	$0535,$0606,$1000,$0000,$0ae6,$0b06,$1000,$0000
	dc.w	$0f83,$1006,$1000,$0000,$17d1,$1806,$1000,$0000
	dc.w	$1b47,$1c06,$1000,$0000,$1fc5,$2006,$1000,$0000
	dc.w	$0000,$0000
Sprite3
	dc.w	$3306,$3400,$1000,$0000,$3744,$3800,$1000,$0000
	dc.w	$3c88,$3d00,$1000,$0000,$3f7e,$4000,$1000,$0000
	dc.w	$4355,$4400,$1000,$0000,$472c,$4800,$1000,$0000
	dc.w	$4ccc,$4d00,$1000,$0000,$4f55,$5000,$1000,$0000
	dc.w	$538b,$5400,$1000,$0000,$5721,$5800,$1000,$0000
	dc.w	$5c2d,$5d00,$1000,$0000,$5f53,$6000,$1000,$0000
	dc.w	$6331,$6400,$1000,$0000,$67a6,$6800,$1000,$0000
	dc.w	$6c5f,$6d00,$1000,$0000,$6f73,$7000,$1000,$0000
	dc.w	$7332,$7400,$1000,$0000,$77fb,$7800,$1000,$0000
	dc.w	$7c23,$7d00,$1000,$0000,$7f40,$8000,$1000,$0000
	dc.w	$836c,$8400,$1000,$0000,$87d5,$8800,$1000,$0000
	dc.w	$8cc2,$8d00,$1000,$0000,$8fdd,$9000,$1000,$0000
	dc.w	$93a0,$9400,$1000,$0000,$97ca,$9800,$1000,$0000
	dc.w	$9c73,$9d00,$1000,$0000,$9fff,$a000,$1000,$0000
	dc.w	$a3db,$a400,$1000,$0000,$a7b7,$a800,$1000,$0000
	dc.w	$acac,$ad00,$1000,$0000,$af36,$b000,$1000,$0000
	dc.w	$b395,$b400,$1000,$0000,$b71a,$b800,$1000,$0000
	dc.w	$bcfa,$bd00,$1000,$0000,$bf00,$c000,$1000,$0000
	dc.w	$c327,$c400,$1000,$0000,$c77f,$c800,$1000,$0000
	dc.w	$cccd,$cd00,$1000,$0000,$cf6e,$d000,$1000,$0000
	dc.w	$d3e9,$d400,$1000,$0000,$d70f,$d800,$1000,$0000
	dc.w	$dc3f,$dd00,$1000,$0000,$df5a,$e000,$1000,$0000
	dc.w	$e344,$e400,$1000,$0000,$e703,$e800,$1000,$0000
	dc.w	$ee42,$ef00,$1000,$0000,$f339,$f400,$1000,$0000
	dc.w	$f913,$fa00,$1000,$0000,$fd67,$fe00,$1000,$0000
	dc.w	$0575,$0606,$1000,$0000,$0a56,$0b06,$1000,$0000
	dc.w	$0f93,$1006,$1000,$0000,$17c1,$1806,$1000,$0000
	dc.w	$1bcd,$1c06,$1000,$0000,$1fe5,$2006,$1000,$0000
	dc.w	$0000,$0000


;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 8 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used registers: d0-d3/a0-a7|	=INTENA н
;н  Mahoney & Kaktus - (C) E.A.S. 1990  н
;нннннннннннннннннннннннннннннннннннннннн
	section	music,code			; Public code
mt_init:lea	mt_data,a0
	lea	mt_mulu(pc),a1
	move.l	#mt_data+$c,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4:move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,mt_lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.w	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,mt_lop3

	move.l	$78.w,mt_oldirq-mt_samplestarts-$7c(a1)
	or.b	#2,$bfe001
	move.b	#6,mt_speed-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,mt_songpos-mt_samplestarts-$7c(a1)
	move.b	d0,mt_counter-mt_samplestarts-$7c(a1)
	move.w	d0,mt_pattpos-mt_samplestarts-$7c(a1)
	rts


mt_end:	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts


mt_music:
	lea	mt_data,a0
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_counter-mt_voice1(a4)
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	moveq	#0,d0
	move.b	d0,mt_counter-mt_voice1(a4)
	move.w	d0,mt_dmacon-mt_voice1(a4)
	lea	mt_data,a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1

	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	lea	mt_playvoice(pc),a6
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	jsr	(a6)

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma

	lea	$bfd000,a3
	move.b	#$7f,$d00(a3)
	move.w	#$2000,$dff09c
	move.w	#$a000,$dff09a
	move.l	#mt_irq1,$78.w
	moveq	#0,d0
	move.b	d0,$e00(a3)
	move.b	#$a8,$400(a3)
	move.b	d0,$500(a3)
	or.w	#$8000,mt_dmacon-mt_voice4(a4)
	move.b	#$11,$e00(a3)
	move.b	#$81,$d00(a3)

mt_nodma:
	add.w	#$10,mt_pattpos-mt_voice4(a4)
	cmp.w	#$400,mt_pattpos-mt_voice4(a4)
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos-mt_voice4(a4)
	clr.b	mt_break-mt_voice4(a4)
	addq.b	#1,mt_songpos-mt_voice4(a4)
	and.b	#$7f,mt_songpos-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos-mt_voice4(a4)
mt_exit:tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_nonew:
	lea	$dff0a0,a5
	lea	mt_com(pc),a6
	jsr	(a6)
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	jsr	(a6)
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	jsr	(a6)
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	jsr	(a6)
	tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_irq1:tst.b	$bfdd00
	move.w	mt_dmacon(pc),$dff096
	move.l	#mt_irq2,$78.w
	move.w	#$2000,$dff09c
	rte

mt_irq2:tst.b	$bfdd00
	movem.l	a3/a4,-(a7)
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)
	movem.l	(a7)+,a3/a4
	move.b	#0,$bfde00
	move.b	#$7f,$bfdd00
	move.l	mt_oldirq(pc),$78.w
	move.w	#$2000,$dff09c
	move.w	#$2000,$dff09a
	rte

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	mt_oldinstr

	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	move.l	mt_mulu(pc,d2.w),a3
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	moveq	#0,d3
	move.w	(a3)+,d3
	beq	mt_noloop
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:dcb.l	$20,0

mt_noloop:
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)
	move.w	$12(a4),8(a5)

mt_oldinstr:
	move.w	(a4),d3
	and.w	#$fff,d3
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	d3,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0
	or.w	d0,mt_dmacon-mt_playvoice(a6)
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:moveq	#0,d0
	move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	move.b	d0,3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_normper
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	lea	mt_periods(pc),a0
mt_arp3:cmp.w	(a0)+,d1
	blt.s	mt_arp3
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	beq.s	mt_arp
	cmp.b	#6,d0
	beq.s	mt_volvib
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:move.w	$12(a4),8(a5)
	rts

mt_com2:move.b	2(a4),d0
	and.b	#$f,d0
	beq	mt_rts
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break-mt_playvoice(a6)
	rts

mt_songjmp:
	move.b	#1,mt_break-mt_playvoice(a6)
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos-mt_playvoice(a6)
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed-mt_playvoice(a6)
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	13,0
		dc.w	1
mt_voice2:	dcb.w	13,0
		dc.w	2
mt_voice3:	dcb.w	13,0
		dc.w	4
mt_voice4:	dcb.w	13,0
		dc.w	8
mt_oldirq:	dc.l	0

	section	modul,data_c			; Chip data
mt_data	incbin	'df1:modules/mod.music'


