**
** Intro 3 (Advertising the 'Chi-Cha-Wowwa' Demo)
**
** Code by Raistlin 
**
** Grafix by Notman & Wing
**
** Music by Off The Lip

	include	source:include/hardware.i		; Harware equates
	opt	c-			; Case independant
	section	Scrolling,code		; Use public memory

	lea	$dff000,a5		; Address of DMA in a5

	move.l	4,a6			; A6=Exec base
	lea	gfxname,a1		; address of lib name in a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open the lib
	move.l	d0,gfxbase		; Save base address of gfx lib
	beq	error			; Quit if error found
	
	jsr	-132(a6)		; Forbid

	
****************************************************************************
;		Load the bitplane pointers
****************************************************************************
	move.l	PScreen,d0		; D0=Address of the physical screen

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
	move.w	d0,sph3+2
	move.w	d0,spl3+2
	move.w	d0,sph4+2
	move.w	d0,spl4+2
	move.w	d0,sph5+2
	move.w	d0,spl5+2
	move.w	d0,sph6+2
	move.w	d0,spl6+2
	move.w	d0,sph7+2
	move.w	d0,spl7+2


****************************************************************************
;		Set-Up The Bplcon1 Values In Copper List
****************************************************************************
SetUp_Ripple
	lea	Scrolly,a0		; A0=Address of cop list
	lea	Sine_data,a1		; A1=Address of sine data
	move.w	#$e301,d0		; d0=First wait value
	move.l	#73,d1			; D1=Number of entries-1
.Loopy
	move.w	d0,(a0)+		; Load wait value
	move.w	#$fffe,(a0)+		; Load mask value
	move.w	#bplcon1,(a0)+		; Load bplcon1 value
	move.w	(a1)+,(a0)+		; Load scroll value
	add.w	#$100,d0		; Increment wait value by 1 line
	cmpa.l	#Sine_end,a1		; End of sine table?
	bne	.Nope1
	lea	Sine_data,a1		; Reset sine pointer
.Nope1
	cmpi.w	#$0001,d0		; Pal area?
	bne	.Nope2
	move.w	#$ffe1,(a0)+		; Pal enable
	move.w	#$fffe,(a0)+
.Nope2
	dbra	d1,.Loopy



****************************************************************************
;	          Set-Up The Co-Ordinates Tables
****************************************************************************
Dragon1
; First set-up the co-ordinates table for Dragon Logo 1
	lea	Cords1,a0	; A0=Address of co-ordinates table to transform
.Loopy
	cmpi.w	#$ffff,(a0)	; End of co-ordinates table?
	beq	.End		; If don't transform any more co-ordinates
	move.w	(a0),d7		; D7=X cord
	cmpi.w	#$ff00,d7	; Is X a pause code?
	bls	.NotPause	; If its lower than $ff00 it aint no pause
	add.l	#2,a0		; If it is a pause skip it
.NotPause
	move.l	(a0),d0		; Else D0=X Y  (X in high word)
	move.w	d0,d1		; D1=Low word of d1 (Y value)
	move.w	#0,d0		; Clear low word of d0
	swap	d0		; Put X offset in low word
	mulu	#40,d1		; Turn d0 into correct format
	divu	#16,d0		; D0 now=low word Xoffset high word=shift
	lsl.w	#1,d0		; Turn X offset into bytes
	add.w	d0,d1		; Add X offset to Y offset
	swap	d0		; Put barrel shift into low word
	lsl.w	#4,d0		; 4+8=12
	lsl.w	#8,d0		; Put barrel shift into 4 MSB
	move.w	d0,(a0)+	; Insert shift into 1st word
	move.w	d1,(a0)+	; Insert offset into 2nd word
	bra	.Loopy		; And convert the other co-ordinates
.End

	lea	cords1,a0	; A0=Address of cords
	move.w	2(a0),LastXY1a	; Set-up last XY
	move.w	2(a0),LastXY1b

****************************************************************************
;			Set-Up A VBL Interrupt
****************************************************************************
	move.l	$6c,Oldint+2		; Save old interrupt
	move.l	#NewInt,$6c		; Insert mine


****************************************************************************
; 		Set-up the DMA
****************************************************************************
DMA	move.l	#Copperlist,cop1lch(a5)	; Load my copper list
	move.w	#$0,copjmp1(a5)		; Run my copper list
	jsr	mt_init			; Start the music


****************************************************************************
;		The Main Branching Routine
****************************************************************************
WaitVBL1
	btst	#6,$bfe001		; Test LMB
	beq	clean_up
	cmpi.b	#1,VBLF			; Wait for VBL interrupt 
	bne	WaitVBL1		; to finish
	move.b	#0,VBLF			; Clear VBL flag

;	move.w	#$fff,color00(a5)	; Raster measure

	bsr	ScrollText		; Move The Scroller
	bsr	WipeLogo1		; Wipe the dragon logo
	bsr	Equalizer		; Do the equalizers routine
	bsr	RaiseLogo		; Raise the logos
	bsr	MoveLogo1		; Move Dragon Logo1
	
;	move.w	#$000,color00(a5)	; Raster measure

WaitBuffer
	cmpi.b	#255,vhposr(a5)
	bne	WaitBuffer
;	move.w	#$fff,color00(a5)	; Raster measure
	bsr	DoubleBuffer
;	move.w	#$000,color00(a5)	; Raster measure

	bra	WaitVBL1



****************************************************************************
;		Clean-up the system ready to leave
****************************************************************************
Clean_Up
	jsr	mt_end			; End the music
	move.l	Oldint+2,$6c		; Restore old interrupt
	move.w	#$8e30,dmacon(a5)	; Enable everything
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	; System copper list
	move.w	#$0,copjmp1(a5)		; Run the system copper
	move.l	4,a6			; A6=Exec base
	move.l	gfxbase,a1		; address of gfx lib in a1
	jsr	-408(a6)		; Close the lib
	jsr	-138(a6)		; Permit
error	rts				; End the program




****************************************************************************
;	This Routine Ripples The Reflection In The Water
****************************************************************************
WaterRipple
.NoNeed	 
	lea	Scrolly,a0		; A0=Address of srolly values
	addq.l	#6,a0			; Get to sine value
	move.w	(a0),Sine_save		; Save the sine value
	lea	Scrolly,a1		; A1=Address of scrolly valuee
	add.l	#14,a1			; Get to second sine value
	move.l	#72,d1			; D1=Number of values to swap-1
.Loopy
	move.w	(a1),(a0)		; Swap the sine values
	addq.l	#8,a0			; Get to next sine value
	addq.l	#8,a1			; Get to next sine value
	cmpi.w	#$fffe,(a1)		; Has the pal enable rouined routine?
	bne	.TryA0
	addq.l	#4,a1
.TryA0	cmpi.w	#$fffe,(a0)		; Has the pal enable rouined routine?
	bne	.Nope
	addq.l	#4,a0
.Nope	dbra	d1,.Loopy		
	move.w	Sine_save,Scrollyend-2
	rts

****************************************************************************
;		    The ScrollText Routine
****************************************************************************
Scrolltext
	btst	#$a,$dff016		; RMB?
	beq	TransferIt
	cmpi.b	#0,Pause		; Pause?
	bne	DecPause		; If so pause the text

	cmpi.b	#0,Plop			; Need a new character?
	bne	ScrollIt		; If not scroll the text
	lea	Font,a0			; Else A0=address of font
	move.l	TextP,a6		; A6=The text pointer
***********************************
* This Section Obtains Characters *
*      To Print In Scroll Text 	  *
***********************************
GetChar
	cmpi.b	#$0a,(a6)		; Return code?
	bne	.Nope1
	add.l	#1,a6
	bra	GetChar
.Nope1
	cmpi.b	#'a',(a6)		; Pause code?
	beq	SetPause		; If so create a pause
	cmpi.b	#'b',(a6)		; End of text? 
	bne	.Nope2
	lea	Text,a6			; Re-load text pointer
.Nope2	moveq.l	#0,d0			; Clear D0
	move.b	(a6)+,d0		; D0=Character to blit
	move.l	a6,TextP		; Save text pointer
	cmpi.b	#'3',d0			; Line 1?
	bls	Line1
	cmpi.b	#'G',d0			; Line 2?
	bls	Line2
	cmpi.b	#'[',d0			; Line 3?
	bls	Line3
	bra	Line4
Line1	sub.b	#32,d0			; Find characters place in font
	add.l	d0,d0			; Multiply by 2
	add.l	d0,a0			; Add to start address of font
	bra	PlopIt			; And plop the character
Line2	sub.b	#52,d0
	add.l	d0,d0
	add.l	#640,d0
	add.l	d0,a0
	bra	PlopIt
Line3	sub.b	#72,d0
	add.l	d0,d0
	add.l	#1280,d0
	add.l	d0,a0
	bra	PlopIt
Line4	sub.b	#92,d0
	add.l	d0,d0
	add.l	#1920,d0
	add.l	d0,a0
	bra	PlopIt
********************
* The Plop Routine *
********************
PlopIt
	bsr	BlitterBusy		; Check blitter status
	move.l	a0,bltapth(a5)		; Source=Character to blit
	move.l	#Buffer+42,bltdpth(a5)	; Destination=Buffer+offset
	move.w	#38,bltamod(a5)		; 40-2
	move.w	#44,bltdmod(a5)		; 46-2
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#%100111110000,bltcon0(a5) ; A-D
	move.w	#(16*64)+1,bltsize(a5)	; 16*16
	move.b	#8,Plop			; Set the plop counter
**********************************
* The Routine To Scroll The Text *
**********************************
ScrollIt
	bsr	BlitterBusy		; Check the blitters status
	lea	Buffer,a0		; A0=Address of buffer
	move.l	a0,bltapth(a5)		; Source=Buffer
	subq.l	#2,a0
	move.l	a0,bltdpth(a5)		; Dest=Buffer-2
	move.w	#0,bltamod(a5)		; 0
	move.w	#0,bltdmod(a5)		; 0
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#%1110100111110000,bltcon0(a5) ; A-D blit   14 barrel shift
	move.w	#(16*64)+23,bltsize(a5) ; 368*16
	subq.b	#1,Plop
	bra	TransferIt		; Transfer the scrolltext

; These are the pause routines
DecPause
	subq.b	#1,Pause		; Decrement the pause
	bra	TransferIt
SetPause	
	move.b	#200,Pause		; Set the pause
	addq.l	#1,a6			; Get to next character
	move.l	a6,TextP		; Save text pointer
****************************************************************************
;   This Section Contains The Different ScrollText Transformation Routines
****************************************************************************
TransferIt
	lea	Buffer,a1		; A1=Address of buffer
	move.l	LScreen,a4		; A4=Address of logical screen
	move.w	#6,AModulo		; 46-40
	move.w	#0,DModulo		; 40-40
	move.w	#$ffff,FWMask		; No mask
	move.w	#$ffff,LWMask		; No mask
	move.w	#%100111110000,d5	; AD blit
	move.w	#(16*64)+20,d7		; D7=Blit size (16*40)
	bra	AD_Blit			; Blit the scroll text

****************************************************************************
;		The Main Equalizer Routine
****************************************************************************
Equalizer
; This routine fills the VU bars
	move.l	#VUGrid,a1
	move.l	LScreen,a4		; A4=address of logical screen
	add.w	#40*16,a4		; Add offset
	move.w	#0,AModulo		; No A modulo
	move.w	#0,DModulo		; 40-40
	move.w	#$ffff,LWMask		; No mask
	move.w	#$ffff,FWMask		; No mask
	move.w	#%100111110000,d5	; A-D blit
	move.w	#(166*64)+20,d7		; Size=166*320
	bsr	AD_Blit

***************
* Equalizer 1 *
***************
; This routine deletes the bar
	cmpi.w	#5,VU1Size		; No blit?
	beq	No1
	move.l	LScreen,a4		; A4=Destination address
	add.w	#40*16,a4		; Get to offset
	move.w	#30,DModulo		; 40-10
	move.w	#%100000000,d5		; D wipe blit
	move.w	VU1Size,d7		; D7=size to clear
	bsr	D_Blit			; Clear bar exit
	cmpi.w	#(180*64)+5,VU1Size	; Bar cleared?
	bge	Equalizer2
No1	add.w	#64*8,VU1Size		; Subtract 8 lines
**********
Equalizer2
**********
; This routine deletes the bar
	cmpi.w	#5,VU2Size		; No blit?
	beq	No2
	move.l	LScreen,a4		; A4=Destination address
	add.w	#40*16,a4		; Get to offset
	add.w	#10,a4
	move.w	#30,DModulo		; 40-10
	move.w	#%100000000,d5		; D wipe blit
	move.w	VU2Size,d7		; D7=size to clear
	bsr	D_Blit			; Clear bar exit
	cmpi.w	#(180*64)+5,VU2Size	; Bar cleared?
	bge	Equalizer3
No2	add.w	#64*8,VU2Size		; Subtract 8 lines
**********
Equalizer3
**********
; This routine deletes the bar
	cmpi.w	#5,VU3Size		; No blit?
	beq	No3
	move.l	LScreen,a4		; A4=Destination address
	add.w	#40*16,a4		; Get to offset
	add.w	#20,a4
	move.w	#30,DModulo		; 40-10
	move.w	#%100000000,d5		; D wipe blit
	move.w	VU3Size,d7		; D7=size to clear
	bsr	D_Blit			; Clear bar exit
	cmpi.w	#(180*64)+5,VU3Size	; Bar cleared?
	bge	Equalizer4
No3	add.w	#64*8,VU3Size		; Subtract 8 lines
**********
Equalizer4
**********
; This routine deletes the bar
	cmpi.w	#5,Vu4Size		; No blit?
	beq	No4
	move.l	LScreen,a4		; A4=Destination address
	add.w	#40*16,a4		; Get to offset
	add.w	#30,a4
	move.w	#30,DModulo		; 40-10
	move.w	#%100000000,d5		; D wipe blit
	move.w	VU4Size,d7		; D7=size to clear
	bsr	D_Blit			; Clear bar exit
	cmpi.w	#(180*64)+5,VU4Size	; Bar cleared?
	bge	Quit
No4	add.w	#64*8,VU4Size		; Subtract 8 lines
Quit	rts

****************************************************************************
;		Routine To Raise The Logos
****************************************************************************
; The first bitplane is blitted using the cookie-cut routine so that the VU
; bars are not erased.  However for speed the last 3 bitplanes are blitted
; using AD
RaiseLogo
	cmpi.b	#1,LogoF		; Which	 logo?
	blt	Credits			; The Credits logo
	beq	Raistlin		; Raistlin logo
	cmpi.b	#2,LogoF
	beq	GodZilla		; Godzilla logo
	bra	Notman			; Notman logo

*******
CREDITS
*******
	lea	CredLogo,a1		; A1=Source A address
	lea	CredMask,a2		; A2=Source B address
	move.l	LScreen,a3		; A3=Source C address
	add.w	#3010,a3		; Add the offset
	add.w	COffset,a3		; Add the offset
	move.l	LScreen,a4		; A4=Dest D address
	add.w	#3010,a4		; Add the offset
	add.w	COffset,a4		; Add the offset
	move.w	#$0,AModulo		; No A modulo
	move.w	#$0,Bmodulo		; No B modulo
	move.w	#20,CModulo		; 40-20
	move.w	#20,DModulo		; 40-20
	move.w	#$ffff,FWMask		; No mask
	move.w	#$ffff,LWMask		; No mask
	move.w	#%111111110010,d5	; ABC-D blit
	moveq.w	#$0,d6			; Clear bltcon1
	move.w	CSize,d7		; Size=1*160 - 107*160
	bsr	ABCD_Blit		; Blit this bitplane
	move.w	#%100111110000,d5	; A-D blit
	moveq.l	#2,d0			; Number of bitplanes-1
.Loopy	add.w	#107*20,a1		; Get to next bob plane
	add.w	#256*40,a4		; Get to next screen plane
	bsr	AD_Blit			; Blit last 3 planes using A-D
	dbra	d0,.Loopy		; Keep blitting

; This part decides which way to move the logo
MoveCLogo
	cmpi.w	#$0,Delay		; Any delay?
	beq	.NoDelay
	sub.w	#1,Delay		; Decrement delay
	rts				; And return
.NoDelay
	cmpi.b	#1,CFlag		; Going up or down?
	beq	.Down
.Up	cmpi.w	#0,COffset		; Fully up?
	bne	.Nope1
	move.b	#1,CFlag		; Set the down flag
	move.w	#$1ff,Delay		; Set delay flag
	rts
.Nope1	add.w	#1*64,CSize		; Increase size
	sub.w	#40,COffset		; Decrease offset
	rts				; And return
.Down	cmpi.w	#4240,COffset		; Fully down?
	bne	.Nope2
	move.b	#0,CFlag		; Set up flag
	move.b	#1,LogoF		; Set Raistlins flag
	lea	RaistCols,a0		; A0=Address of Raistlins colours
	lea	LogoCols+2,a1		; A1=Address to place cols
	moveq.l	#13,d0			; 14 colours to move
.Loopy	move.w	(a0)+,(a1)		; Transfer colours
	add.w	#4,a1			; Get to next colour register
	dbra	d0,.Loopy
	rts
.Nope2	sub.w	#1*64,CSize		; Decrease size
	add.w	#40,COffset		; Increase offset
	rts

********
RAISTLIN
********
	lea	RaistLogo,a1		; A1=Source A address
	lea	RaistMask,a2		; A2=Source B address
	move.l	LScreen,a3		; A3=Source C address
	add.w	#1617,a3		; Add the offset
	add.w	ROffset,a3		; Add the offset
	move.l	LScreen,a4		; A4=Dest D address
	add.w	#1617,a4		; Add the offset
	add.w	ROffset,a4		; Add the offset
	move.w	#$0,AModulo		; No A modulo
	move.w	#$0,Bmodulo		; No B modulo
	move.w	#30,CModulo		; 40-10
	move.w	#30,DModulo		; 40-10
	move.w	#$ffff,FWMask		; No mask
	move.w	#$ffff,LWMask		; No mask
	move.w	#%111111110010,d5	; ABC-D blit
	moveq.w	#$0,d6			; Clear bltcon1
	move.w	RSize,d7		; Size=1*80 - 142*80
	bsr	ABCD_Blit		; Blit this bitplane
	move.w	#%100111110000,d5	; A-D blit
	moveq.l	#2,d0			; Number of bitplanes-1
.Loopy	add.w	#142*10,a1		; Get to next bob plane
	add.w	#256*40,a4		; Get to next screen plane
	bsr	AD_Blit			; Blit last 3 planes using A-D
	dbra	d0,.Loopy		; Keep blitting
; This part decides which way to move the logo
MoveRLogo
	cmpi.w	#$0,Delay		; Any delay?
	beq	.NoDelay
	sub.w	#1,Delay		; Decrement delay
	rts				; And return
.NoDelay
	cmpi.b	#1,RFlag		; Going up or down?
	beq	.Down
.Up	cmpi.w	#0,ROffset		; Fully up?
	bne	.Nope1
	move.b	#1,RFlag		; Set the down flag
	move.w	#$1ff,Delay		; Set delay flag
	rts
.Nope1	add.w	#1*64,RSize		; Increase size
	sub.w	#40,ROffset		; Decrease offset
	rts				; And return
.Down	cmpi.w	#5640,ROffset		; Fully down?
	bne	.Nope2
	move.b	#0,RFlag		; Set up flag
	move.b	#2,LogoF		; Set GodZillas flag
	lea	ZillaCols,a0		; A0=Address of Godzillas colours
	lea	LogoCols+2,a1		; A1=Address to place cols
	moveq.l	#13,d0			; 14 colours to move
.Loopy	move.w	(a0)+,(a1)		; Transfer colours
	add.w	#4,a1			; Get to next colour register
	dbra	d0,.Loopy
	rts
.Nope2	sub.w	#1*64,RSize		; Decrease size
	add.w	#40,ROffset		; Increase offset
	rts

********
GODZILLA
********
	lea	ZillaLogo,a1		; A1=Source A address
	lea	ZillaMask,a2		; A2=Source B address
	move.l	LScreen,a3		; A3=Source C address
	add.w	#2770,a3		; Add the offset
	add.w	ZOffset,a3		; Add the offset
	move.l	LScreen,a4		; A4=Dest D address
	add.w	#2770,a4		; Add the offset
	add.w	ZOffset,a4		; Add the offset
	move.w	#$0,AModulo		; No A modulo
	move.w	#$0,Bmodulo		; No B modulo
	move.w	#20,CModulo		; 40-20
	move.w	#20,DModulo		; 40-20
	move.w	#$ffff,FWMask		; No mask
	move.w	#$ffff,LWMask		; No mask
	move.w	#%111111110010,d5	; ABC-D blit
	moveq.w	#$0,d6			; Clear bltcon1
	move.w	ZSize,d7		; Size=1*160 - 113*160
	bsr	ABCD_Blit		; Blit this bitplane
	move.w	#%100111110000,d5	; A-D blit
	moveq.l	#2,d0			; Number of bitplanes-1
.Loopy	add.w	#113*20,a1		; Get to next bob plane
	add.w	#256*40,a4		; Get to next screen plane
	bsr	AD_Blit			; Blit last 3 planes using A-D
	dbra	d0,.Loopy		; Keep blitting
; This part decides which way to move the logo
MoveZLogo
	cmpi.w	#$0,Delay		; Any delay?
	beq	.NoDelay
	sub.w	#1,Delay		; Decrement delay
	rts				; And return
.NoDelay
	cmpi.b	#1,ZFlag		; Going up or down?
	beq	.Down
.Up	cmpi.w	#0,ZOffset		; Fully up?
	bne	.Nope1
	move.b	#1,ZFlag		; Set the down flag
	move.w	#$1ff,Delay		; Set delay flag
	rts
.Nope1	add.w	#1*64,ZSize		; Increase size
	sub.w	#40,ZOffset		; Decrease offset
	rts				; And return
.Down	cmpi.w	#4480,ZOffset		; Fully down?
	bne	.Nope2
	move.b	#0,ZFlag		; Set up flag
	move.b	#3,LogoF		; Set Nots flag
	lea	NotCols,a0		; A0=Address of Notmans colours
	lea	LogoCols+2,a1		; A1=Address to place cols
	moveq.l	#13,d0			; 14 colours to move
.Loopy	move.w	(a0)+,(a1)		; Transfer colours
	add.w	#4,a1			; Get to next colour register
	dbra	d0,.Loopy
	rts
.Nope2	sub.w	#1*64,ZSize		; Decrease size
	add.w	#40,ZOffset		; Increase offset
	rts

******
NOTMAN
******
	lea	NotLogo,a1		; A1=Source A address
	lea	NotMask,a2		; A2=Source B address
	move.l	LScreen,a3		; A3=Source C address
	add.w	#2693,a3		; Add the offset
	add.w	NOffset,a3		; Add the offset
	move.l	LScreen,a4		; A4=Dest D address
	add.w	#2693,a4		; Add the offset
	add.w	NOffset,a4		; Add the offset
	move.w	#$0,AModulo		; No A modulo
	move.w	#$0,Bmodulo		; No B modulo
	move.w	#22,CModulo		; 40-18
	move.w	#22,DModulo		; 40-18
	move.w	#$ffff,FWMask		; No mask
	move.w	#$ffff,LWMask		; No mask
	move.w	#%111111110010,d5	; ABC-D blit
	moveq.w	#$0,d6			; Clear bltcon1
	move.w	NSize,d7		; Size=1*144 - 115*144
	bsr	ABCD_Blit		; Blit this bitplane
	move.w	#%100111110000,d5	; A-D blit
	moveq.l	#2,d0			; Number of bitplanes-1
.Loopy	add.w	#116*18,a1		; Get to next bob plane
	add.w	#256*40,a4		; Get to next screen plane
	bsr	AD_Blit			; Blit last 3 planes using A-D
	dbra	d0,.Loopy		; Keep blitting
; This part decides which way to move the logo
MoveNLogo
	cmpi.w	#$0,Delay		; Any delay?
	beq	.NoDelay
	sub.w	#1,Delay		; Decrement delay
	rts				; And return
.NoDelay
	cmpi.b	#1,NFlag		; Going up or down?
	beq	.Down
.Up	cmpi.w	#0,NOffset		; Fully up?
	bne	.Nope1
	move.b	#1,NFlag		; Set the down flag
	move.w	#$1ff,Delay		; Set delay flag
	rts
.Nope1	add.w	#1*64,NSize		; Increase size
	sub.w	#40,NOffset		; Decrease offset
	rts				; And return
.Down	cmpi.w	#4560,NOffset		; Fully down?
	bne	.Nope2
	move.b	#0,NFlag		; Set up flag
	move.b	#0,LogoF		; Set Credits flag
	lea	CreditCols,a0		; A0=Address of Credit colours
	lea	LogoCols+2,a1		; A1=Address to place cols
	moveq.l	#13,d0			; 14 colours to move
.Loopy	move.w	(a0)+,(a1)		; Transfer colours
	add.w	#4,a1			; Get to next colour register
	dbra	d0,.Loopy
	rts
.Nope2	sub.w	#1*64,NSize		; Decrease size
	add.w	#40,NOffset		; Increase offset
	rts
	


****************************************************************************
;		The Routine To Move Dragon Logo 1
****************************************************************************
WipeLogo1
; This routine wipes the old dragon logo image
	move.l	LScreen,a4		; A4=Destination
	add.w	LastXY1a,a4		; Offset
	move.w	#22,DModulo		; 40-18
	move.w	#%100000000,d5		; D wipe blit
	move.w	#(31*64)+9,d7		; 31*144
	moveq.l	#4,d0			; Number of bitplanes-1
.Loopy	bsr	D_Blit			; Wipe plane
	add.w	#256*40,a4		; Next plane
	dbra	d0,.Loopy
	rts

*******************************
* Actual Bob Movement Routine *
*******************************
MoveLogo1
; Find out where to blit the bob next
	move.l	cord1,a6		; A6=Pointer to next co-ordinates
	cmpi.w	#$ffff,(a6)		; Are we at end of cords table?
	bne	.NotEnd1
	lea	Cords1,a6		; Re-load cords table
.NotEnd1
	move.w	(a6)+,d1		; D1=Barrel shift
	move.w	(a6)+,d2		; D2=Offset
	move.l	a6,Cord1		; Save the cords pointer
Pausey
	move.w	LastXY1b,LastXY1a
	move.w	d2,LastXY1b		; Save LastXY pos
; Blit The Bob
	lea	Logo1,a1		; A1=Address of bob to blit
	lea	Mask1,a2		; A2=Address of mask
	move.l	LScreen,a3		; A3=Address of screen
	move.l	LScreen,a4		; A4=Address of screen
	add.l	d2,a3			; Add the bob offset
	add.l	d2,a4			; Add the bob offset
	moveq.l	#4,d3			; D3=Number of bitplanes-1
	move.w	#-2,AModulo		; Actual bob size-Bltsize
	move.w	#0,BModulo		; No modulo
	move.w	#22,CModulo		; 40-18
	move.w	#22,Dmodulo		; 40-18
	move.w	#$ffff,FWMask		; No first word mask
	move.w	#$0000,LWMask		; Full last word mask
	move.w	#%111111110010,d5	; D5=ABCD blit
	or.w	d1,d5			; Add the shift value
	moveq.w	#$0,d6			; D6=Bltcon0 value (cleared)
	or.w	d1,d6			; Add the shift value
	move.w	#(31*64)+9,d7		; D7=Bltsize
.Loopy3
	bsr	ABCD_Blit		; Do the blit
	add.l	#31*16,a1		; Get to next bob plane
	add.l	#256*40,a3		; Get to next saved data plane
	add.l	#256*40,a4		; Get to next screen plane
	dbra	d3,.Loopy3		; Keep blitting
	rts



****************************************************************************
;	This Section Contains General Blitter Operations 
****************************************************************************
; Note: This section contains 4 specialised routines instead of 1 general
; to speed up operation, & it don't take-up too much extra memory.
********************
* A D Blit Routine *
********************
D_Blit
	bsr	BlitterBusy
	move.l	a4,bltdpth(a5)		; A5=Address of source A
	move.w	DModulo,bltdmod(a5)	; DModulo=value of D modulo
	move.w	d5,bltcon0(a5)		; D5=Value of bltcon0
	move.w	d7,bltsize(a5)		; D7=Value of bltsize
	rts
***********************
* An A-D Blit Routine *
***********************
AD_Blit
	bsr	BlitterBusy
	move.l	a1,bltapth(a5)		; A3=Address of Source A
	move.l	a4,bltdpth(a5)		; A4=Address of Destination
	move.w	AModulo,bltamod(a5)	; AModulo=value of A modulo
	move.w	DModulo,bltdmod(a5)	; DModulo=value of D modulo
	move.w	FWMask,bltafwm(a5)	; FWMask=value of first word mask
	move.w	LWMask,bltalwm(a5)	; LWMask=value of last word mask
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	d5,bltcon0(a5)		; D5=Value of bltcon0
	move.w	d7,bltsize(a5)		; D7=Value of bltsize
	rts	
***********************
* An AB-D Blit Routine *
***********************
ABD_Blit
	bsr	BlitterBusy
	move.l	a1,bltapth(a5)		; A3=Address of Source A
	move.l	a2,bltbpth(a5)		; A3=Address of source B
	move.l	a4,bltdpth(a5)		; A4=Address of Destination
	move.w	AModulo,bltamod(a5)	; AModulo=value of A modulo
	move.w	BModulo,bltbmod(a5)	; BModulo=value of B modulo
	move.w	DModulo,bltdmod(a5)	; DModulo=value of D modulo
	move.w	FWMask,bltafwm(a5)	; FWMask=value of first word mask
	move.w	LWMask,bltalwm(a5)	; LWMask=value of last word mask
	move.w	d5,bltcon0(a5)		; D5=Value of bltcon0
	move.w	d6,bltcon1(a5)		; D6=Value of bltcon1
	move.w	d7,bltsize(a5)		; D7=Value of bltsize
	rts	
**********************************************
* Now An ABCD Blit Routine For The Cooki-Cut *
**********************************************
ABCD_Blit
	bsr	BlitterBusy
	move.l	a1,bltapth(a5)		; A1=Address of source A
	move.l	a2,bltbpth(a5)		; A2=Address of source B
	move.l	a3,bltcpth(a5)		; A3=Address of source C
	move.l	a4,bltdpth(a5)		; A4=Address of destination
	move.w	Amodulo,bltamod(a5)	; AModulo=Modulo to use
	move.w	BModulo,bltbmod(a5)	; BModulo=Modulo to use
	move.w	CModulo,bltcmod(a5)	; CModulo=Modulo to use
	move.w	DModulo,bltdmod(a5)	; DModulo=Modulo to use
	move.w	FWMask,bltafwm(a5)	; FWMask=value of first word mask
	move.w	LWMask,bltalwm(a5)	; LWMask=value of last word mask
	move.w	d5,bltcon0(a5)		; D5=Bltcon0
	move.w	d6,bltcon1(a5)		; D6=Bltcon1
	move.w	d7,bltsize(a5)		; D7=Bltsize
	rts
***********
BlitterBusy
***********
	btst	#14,dmaconr(a5)		; What the Beast upto?
	bne	BlitterBusy		; Masacering some memory!
	rts				; Fuck all!


****************************************************************************
;		This Sections Contains The 3 Sprite Effects
****************************************************************************
Background
**************************
* Section 1 The SarField *
**************************
	lea	Sprite1,a0		; A0=Address of star field 1
	lea	Sprite2,a1		; A1=Address of star field 2
	lea	Sprite3,a2		; A2=Address of star field 3
	move.l	#43,d0			; D0=Number of stars to move-1
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

****************************************************************************
;			My New Interrupt
****************************************************************************
NewInt
	movem.l	a0-a6/d0-d7,-(sp)	; Save old registers

	bsr	Background		; Do the background effect
	bsr	WaterRipple		; Ripple the water
	jsr	mt_music
	move.b	#1,VBLF

	movem.l	(sp)+,a0-a6/d0-d7	; Restore registers

Oldint	jmp	$0			; Old interrupt


****************************************************************************
;		The Double Buffering Routine  -My first one!!!
****************************************************************************
; Because theres so much heppening on the screen I've had to double buffer.
; Seeing as this is my first double buffering sorry if its lame!  Anyway heres
; some info on how it works (for me as well as you!)
; There are two screen pointers, PScreen which points to the physical screen
; & LScreen which points to the logical screen.  All the manipulation is
; performed on the logical screen, while the phyiscal screen is the one 
; displayed.  After all graphical manipulation is done the screens are
; swapped.  Back1 & Back11 point to the saved background data for screena
; and screenb.  Every frame these pointers are swapped so the bob routine
; gets the right backgroud!  Also two variables hold the LASTXY offsets,
; this is so the data is correctly placed in  screens a & b,  these variables
; are also swapped every frame but in the actual bob routine rather than
; in the VBL, no particular reason for that.
DoubleBuffer
	move.l	PScreen,d0		; D0=Physical screen
	move.l	LScreen,d1		; D1=Logical screen
	move.l	d0,LScreen		; Swap the screen
	move.l	d1,PScreen		; Pointers


	move.l	PScreen,d0		; D0=Address of the physical screen
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
	rts


****************************************************************************
;			THE COPPER LIST
****************************************************************************
	section	copperlist,code_c	; Chip memory
Copperlist	
	dc.w	diwstrt,$2c81		; Window start
	dc.w	diwstop,$2cc1		; Window stop
	dc.w	ddfstrt,$38		; Data fetch start
	dc.w	ddfstop,$d0		; Data fetch stop
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0
Pri	dc.w	bplcon2,$0		; Bitplane priority (over sprites)
	dc.w	bpl1mod,0,bpl2mod,0

bph1	dc.w	bpl1pth,$0		; The bitplane pointers
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0
bph5	dc.w	bpl5pth,$0
bpl5	dc.w	bpl5ptl,$0

sph0	dc.w	spr0pth,$0		; The sprite pointers
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

	dc.w	$180,$000,$1a2,$fff,$1aa,$fff  	; Sprite & background colours
bobCols					
	dc.w	$1a0,$000,$1a4,$e00,$1a6,$e30	; Colours for Dragon logo
	dc.w	$1a8,$e60,$1ac,$fc0,$1ae,$ff0
	dc.w	$1b0,$050,$1b4,$070,$1b6,$090
	dc.w	$1b8,$0a0,$1ba,$0b0,$1bc,$f80
; Colours For Scroller
	dc.w	$2901,$fffe,$182,$ff0,$2a01,$fffe,$182,$fe0
	dc.w	$2b01,$fffe,$182,$fd0,$2c01,$fffe,$182,$fc0
	dc.w	$2d01,$fffe,$182,$fb0,$2e01,$fffe,$182,$fa0
	dc.w	$2f01,$fffe,$182,$f90,$3001,$fffe,$182,$f80
	dc.w	$3101,$fffe,$182,$f70,$3201,$fffe,$182,$f60
	dc.w	$3301,$fffe,$182,$f50,$3401,$fffe,$182,$f40
	dc.w	$3501,$fffe,$182,$f30,$3601,$fffe,$182,$f20
	dc.w	$3701,$fffe,$182,$f10,$3801,$fffe,$182,$f00
	dc.w	$3901,$fffe,$182,$e00,$3a01,$fffe,$182,$d00

; The Colours For Rising Logos
LogoCols
	dc.w	$184,$080,$186,$aaa
	dc.w	$188,$fa0,$18a,$e90,$18c,$d80,$18e,$b70
	dc.w	$190,$fff,$192,$cdf,$194,$abf,$196,$79f
	dc.w	$198,$56a,$19a,$235,$19c,$000,$19e,$fff


; Equalizer Shading
	dc.w	$3c01,$fffe,$182,$fff,$3d01,$fffe,$182,$f00
	dc.w	$4201,$fffe,$182,$000
	dc.w	$4401,$fffe,$182,$fff,$4501,$fffe,$182,$f10
	dc.w	$4a01,$fffe,$182,$000
	dc.w	$4c01,$fffe,$182,$fff,$4d01,$fffe,$182,$f30
	dc.w	$5201,$fffe,$182,$000
	dc.w	$5401,$fffe,$182,$fff,$5501,$fffe,$182,$f50
	dc.w	$5a01,$fffe,$182,$000
	dc.w	$5c01,$fffe,$182,$fff,$5d01,$fffe,$182,$f60
	dc.w	$6201,$fffe,$182,$000
	dc.w	$6401,$fffe,$182,$fff,$6501,$fffe,$182,$f70
	dc.w	$6a01,$fffe,$182,$000
	dc.w	$6c01,$fffe,$182,$fff,$6d01,$fffe,$182,$f90
	dc.w	$7201,$fffe,$182,$000
	dc.w	$7401,$fffe,$182,$fff,$7501,$fffe,$182,$fb0
	dc.w	$7a01,$fffe,$182,$000
	dc.w	$7c01,$fffe,$182,$fff,$7d01,$fffe,$182,$fc0
	dc.w	$8201,$fffe,$182,$000
	dc.w	$8401,$fffe,$182,$fff,$8501,$fffe,$182,$fd0
	dc.w	$8a01,$fffe,$182,$000
	dc.w	$8c01,$fffe,$182,$fff,$8d01,$fffe,$182,$ff0
	dc.w	$9201,$fffe,$182,$000
	dc.w	$9401,$fffe,$182,$fff,$9501,$fffe,$182,$df0
	dc.w	$9a01,$fffe,$182,$000
	dc.w	$9c01,$fffe,$182,$fff,$9d01,$fffe,$182,$cf0
	dc.w	$a201,$fffe,$182,$000
	dc.w	$a401,$fffe,$182,$fff,$a501,$fffe,$182,$bf0
	dc.w	$aa01,$fffe,$182,$000
	dc.w	$ac01,$fffe,$182,$fff,$ad01,$fffe,$182,$9f0
	dc.w	$b201,$fffe,$182,$000
	dc.w	$b401,$fffe,$182,$fff,$b501,$fffe,$182,$8f0
	dc.w	$ba01,$fffe,$182,$000
	dc.w	$bc01,$fffe,$182,$fff,$bd01,$fffe,$182,$6f0
	dc.w	$c201,$fffe,$182,$000
	dc.w	$c401,$fffe,$182,$fff,$c501,$fffe,$182,$5f0
	dc.w	$ca01,$fffe,$182,$000
	dc.w	$cc01,$fffe,$182,$fff,$cd01,$fffe,$182,$3f0
	dc.w	$d201,$fffe,$182,$000
	dc.w	$d401,$fffe,$182,$fff,$d501,$fffe,$182,$2f0
	dc.w	$da01,$fffe,$182,$000
	dc.w	$dc01,$fffe,$182,$fff,$dd01,$fffe,$182,$0f0
; The Water
	dc.w	$180,$00a
	dc.w	$e201,$fffe		; Wait
	dc.w	bpl1mod,-80,bpl2mod,-80
Scrolly	ds.w	298
Scrollyend
	dc.w	$ffff,$fffe





****************************************************************************
;			Variables
****************************************************************************
	section	fast_variables,data
gfxname	dc.b	'graphics.library',0	; Name of lib to load
	even
gfxbase	dc.l	0			; Space for libs address

VBLF	dc.b	0			; The VBL flag
	even
Amodulo	dc.w	0			; Space for A modulo
BModulo	dc.w	0			; Space for B modulo
CModulo	dc.w	0			; Space for C modulo
DModulo	dc.w	0			; Space for D modulo
FWMask	dc.w	0			; Space for first word mask
LWMask	dc.w	0			; Space for last word mask

******************************
* The Water Ripple Variables *
******************************
sine_data
	dc.w	$88,$aa,$bb,$dd,$dd,$ee,$ff,$ff,$ff,$ff
	dc.w	$ff,$ff,$ff,$ee,$dd,$dd,$bb,$aa,$88,$66
	dc.w	$55,$33,$22,$11,$00,$00,$00,$00,$00,$00
	dc.w	$00,$11,$22,$33,$55,$66,$88
sine_end
sine_save dc.w	0

*****************************
* The Scroll Text Variables *
*****************************
Plop	dc.b	0
Pause	dc.b	0
TextP	dc.l	Text
Text	dc.b	' HI ONE AND ALL!  WELL IF YOU ARE READING THIS ON ACC THEN I GUESS '
	dc.b	'IT MUST BE CHRISTMAS, SO MERRY CHRISTMAS & HAPPY NEW YEAR. '
	dc.b	'CHRIMBO GREETS TO:-  FM , TECH , MASTER BEAT , MIKE CROSS , MARK MEANY , '
	dc.b	'DAVE EDWARDS , STEVE MARSHALL , NIPPER , TREEBEARD , NOTMAN , OFF THE LIP , '
	dc.b	'KROME , DAVE SHAW , GARY WRIGHT , CHRIS , ANDREW JACKSON  AND ALL OTHERS IVE '
	dc.b	'FORGOTTEN TO MENTION.................RAISTLIN 91                     b'

************************************************
* The Co-Ordinates Variables For Dragon Logo 1 *
************************************************
LastXY1a dc.w	0			; Last offset 
LastXY1b dc.w	0			; Last offset, but one
Cord1	dc.l	Cords1			; Pointer to cords table
Cords1	include	'Table1'
	dc.w	$ffff			; End of cords table

**************************************
* The Variables For The Rising Logos *
**************************************
; The offsets
ROffset dc.w	5640
NOffset	dc.w	4560
ZOffset	dc.w	4480
COffset	dc.w	4240
RSize	dc.w	(1*64)+5		; The logo sizes
NSize	dc.w	(1*64)+9
ZSize	dc.w	(1*64)+10
CSize	dc.w	(1*64)+10
RFlag	dc.b	0			; Logo flags
NFlag	dc.b	0
ZFlag	dc.b	0
CFlag	dc.b	0
LogoF	dc.b	1			; Master logo flag
	even
Delay	dc.w	$0			; Delay variable
; The colours
NotCols	
	dc.w	$000,$666,$fff,$333,$ff0,$0f0,$f00
	dc.w	$fd8,$fc7,$fc6,$fb4,$fb3,$fa1,$fa0
RaistCols
	dc.w	$080,$aaa,$fa0,$e90,$d80,$b70,$fff
	dc.w	$cdf,$abf,$79f,$56a,$235,$000,$fff
ZillaCols
	dc.w	$000,$fff,$0f0,$0d0,$0b0,$090,$080
	dc.w	$060,$f00,$f88,$777,$fa0,$d90,$c80
CreditCols
	dc.w	$080,$777,$3a0,$4b0,$5c0,$7e0,$c00
	dc.w	$fd0,$ed8,$f90,$79f,$808,$000,$fff
	



******************************
* The double buffer pointers *
******************************
PScreen	dc.l	screena			; Pointer to physical screen
LScreen	dc.l	screenb			; Pointer to logical screen

***********************
* Equalizer Variables *
***********************
VU1Size	dc.w	(166*64)+5
VU2Size	dc.w	(166*64)+5
VU3Size	dc.w	(166*64)+5
VU4Size	dc.w	(166*64)+5
*****************************************************************************
;        		The Gfx Data In Chip Mem 		            
*****************************************************************************
	section	chip_variables,data_c
screena	dcb.b	256*40*5,0
screenb	dcb.b	256*40*5,0
Font	incbin	'Font.gfx'
buffer	dcb.b	15*46,0			; Buffer for scrolltext
bufferend dcb.b 46,0			; Last line of buffer

VUGrid	incbin	'EqualizerGrid'


*****************************
* Gfx data for Dragon Logo1 *
*****************************
Logo1	incbin	'Dragon.Logo1
Mask1	incbin	'Dragon.Mask1

*********************************
* Gfx data for the Credits Logo *
*********************************
CredLogo  incbin 'credits.gfx'
CredMask  incbin 'credits.Mask'

******************************
* Gfx data for Raistlin Logo *
******************************
RaistLogo incbin 'Raistlin.gfx'
RaistMask incbin 'Raistlin.Mask'

****************************
* Gfx data for Notman Logo *
****************************
NotLogo	  incbin 'Notman.gfx'
NotMask   incbin 'Notman.Mask'

******************************
* Gfx data for Godzilla Logo *
******************************
ZillaLogo incbin 'Zilla.gfx'
ZillaMask incbin 'Zilla.Mask'

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
	dc.w	$b9fa,$ba00,$1000,$0000,$bd00,$be00,$1000,$0000
	dc.w	$c027,$c100,$1000,$0000,$c47f,$c500,$1000,$0000
	dc.w	$c91d,$ca00,$1000,$0000,$cd6e,$ce00,$1000,$0000
	dc.w	$d0e9,$d100,$1000,$0000,$d40f,$d500,$1000,$0000
	dc.w	$d93f,$da00,$1000,$0000,$dd5a,$de00,$1000,$0000
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
	dc.w	$bafa,$bb00,$1000,$0000,$be00,$bf00,$1000,$0000
	dc.w	$c127,$c200,$1000,$0000,$c57f,$c600,$1000,$0000
	dc.w	$ca1d,$cb00,$1000,$0000,$ce6e,$cf00,$1000,$0000
	dc.w	$d1e9,$d200,$1000,$0000,$d50f,$d600,$1000,$0000
	dc.w	$da3f,$db00,$1000,$0000,$de5a,$df00,$1000,$0000
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
	dc.w	$ac7c,$ad00,$1000,$0000,$af36,$b000,$1000,$0000
	dc.w	$b395,$b400,$1000,$0000,$b71a,$b800,$1000,$0000
	dc.w	$bcfa,$bd00,$1000,$0000,$bf00,$c000,$1000,$0000
	dc.w	$c327,$c400,$1000,$0000,$c77f,$c800,$1000,$0000
	dc.w	$cc1d,$cd00,$1000,$0000,$cf6e,$d000,$1000,$0000
	dc.w	$d3e9,$d400,$1000,$0000,$d70f,$d800,$1000,$0000
	dc.w	$dc3f,$dd00,$1000,$0000,$df5a,$e000,$1000,$0000
	dc.w	$0000,$0000


;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 8 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used registers: d0-d3/a0-a7|	=INTENA н
;н  Mahoney & Kaktus - (C) E.A.S. 1990  н
;нннннннннннннннннннннннннннннннннннннннн
	section	Music,Code
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
	bsr	newroutine			; Equalizer routine
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

newroutine
	bsr	Voice_1			; Check the channels for sound
	bsr	Voice_2
	bsr	Voice_3
	bsr	Voice_4
	rts
Voice_1
	cmpi.l	#$0000,mt_voice1	; is voice 1 active?
	beq	No_sound		; no, then return
	move.w	#$5,VU1Size		; VU meter1 size=full
	rts
Voice_2
	cmpi.l	#$0000,mt_voice2	; is voice 2 active?
	beq	No_sound		; no, then return
	move.w	#$5,VU2Size		; VU meter2 size=full
	rts
Voice_3
	cmpi.l	#$0000,mt_voice3	; is voice 3 active?
	beq	No_sound		; no, then return
	move.w	#$5,VU3Size		; VU meter3 size=full
	rts
Voice_4
	cmpi.l	#$0000,mt_voice4	; is voice 4 active?
	beq	No_sound		; no, then return
	move.w	#$5,VU4Size		; VU meter4 size=full
	rts
No_Sound
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


	section	music,data_c
mt_data	incbin	'df1:Modules/mod.dan-st'
