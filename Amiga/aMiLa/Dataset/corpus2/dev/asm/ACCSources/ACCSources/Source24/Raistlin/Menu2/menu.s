**
**  THE ALLIANCE BOOK DOX MENU
**
**  CODED BY RAISTLIN 
**
**  ORIGIONAL GRAFIX SUPPLIED BY BLADE AND AZREAL
**
**  DATE FINISHED: BETA VERSION
**
**  
	include	source:include/hardware.i		; Hardware offset
	section	hardware,code		; Public memory
	opt	c- d+

	lea	$dff000,a5		; Hardware offset

	move.l	4,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error

	lea	dosname,a1		
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,dosbase		; Save dos base
	beq	error

; Now get us 2 lots of memory for sine scroller & menu screen
Start	move.l	#(128*40)*2,d0		; D0=Size to allocate (bytes)
	move.l	#2,d1			; D1=Type (Chip)
	jsr	-198(a6)		; Allocate the memory
	move.l	d0,Sscreen		; Save ptr for scroller screen
	beq	error1			; Exit if memory aint been reserved
	move.l	#128*40,d0		; D0=Size to allocate (bytes)
	move.l	#2,d1			; D1=Type (Chip)
	jsr	-198(a6)		; Allocate the memory
	move.l	d0,Mscreen		; Save ptr for menu screen
	beq	error2			; Exit if memory aint been reserved	
; Now reserve a piece of memory for the VU meters screen
	move.l	#46*40,d0		; D0=Size to allocate (bytes)
	move.l	#2,d1			; D1=Type (Chip)
	jsr	-198(a6)		; Allocate the memory
	move.l	d0,Vscreen		; Save ptr for VU screen
	beq	error3			; Exit if memory aunt been reserved
	jsr	-132(a6)		; Permit

; Clear all the allocated memory
Clear	move.l	Sscreen,a0		; A0=Ptr to sine-scroll screen
	move.l	#2559,d0		; D0=Number of long words-1 to clear
.Loop1	move.l	#0,(a0)+		; Clear this long word
	dbra	d0,.Loop1
	move.l	Vscreen,a0		; A0=Ptr to VU screen
	move.l	#459,d0			; D0=Number of long words to clear
.Loop2	move.l	#0,(a0)+		; Clear this long word
	dbra	d0,.Loop2
	move.l	Mscreen,a0		; A0=Ptr to menu screen
	move.l	#1279,d0		; D0=Number of long words to clear-1
.Loop3	move.l	#0,(a0)+
	dbra	d0,.Loop3

	move.l	Sscreen,Sscreena		
	move.l	Sscreena,Sscreenb	; Sscreena=Sscreenb
	add.l	#128*40,Sscreenb	; Sscreenb now equals buffer
	move.l	Mscreen,Mscreen1
	add.l	#8*40,Mscreen1

	move.l	Sscreena,d0		; D0=Address of scroller bitplane
	bsr	SetScrl			; Set-up the scroller bitplane
	move.l	Mscreen,d0		; D0=Address of menu bitplane
	bsr	SetMenu			; Set-up the menu bitplanes
	move.l	Vscreen,d0		; D0=Address of VU screen
	bsr	SetVU			; Set-up the VU bitplanes
	move.l	#ALLlogo,d0		; D0=Address of Logo
	move.l	#UPlogo,d1		; D1=Address of logo
	bsr	SetLogo			; Set-up the Logo screen

************************
* RESET SOME VARIABLES *
************************
	move.l	#ALLlogo,Logoa
	move.l	#UPlogo,Logob
	move.l	#ALLcols,Lcolsa
	move.l	#UPcols,Lcolsb
	move.w	#50*10,LDelay
	move.l	#MenuS,MenuP1
	move.l	#MenuE,MenuP2
	move.b	#$7d,Waity		
	move.b	#0,MasterS
	move.w	#1,Item
	move.w	#0,Inc1
	move.w	#0,Inc2
	move.w	#0,Inc3
	move.w	#0,Inc4
	move.b	#0,PlopC
	move.w	#0,Pause
	move.l	#SineEnd,SineP
; Load the colours tables
	lea	Allcols,a0		; A0=Ptr to colours
	move.l	#Colsa+2,a1		; A1=Ptr to destination
	move.l	#15,d0
.Loop4	move.w	(a0)+,(a1)
	addq.w	#4,a1
	dbra	d0,.Loop4

	lea	UPcols,a0		; A0=Ptr to colours
	move.l	#Colsb+2,a1		; A1=Ptr to destination
	move.l	#15,d0
.Loop5	move.w	(a0)+,(a1)
	addq.w	#4,a1
	dbra	d0,.Loop5

	lea	Bar,a0			; A0=Pointer to bar
	move.b	#$8e,d1			; D1=$8e
	move.l	#5,d0			; D0=Number of vert waits to change-1
.Loop6	move.b	d1,(a0)			; Insert the wait value
	add.w	#12,a0			; Get to next wait
	addq.b	#1,d1			; Increment wait value
	dbra	d0,.Loop6		; Increment ALL wait values


*****************************************************************************
;			  Set-Up Menu
*****************************************************************************
MenuSet	lea	MenuS,a0		; A0=Pointer to menu text
	Move.l	MScreen1,a2		; A2=Pointer to menu screen
	move.l	#13,d0			; D0=Number of lines to print-1

.Loop1	move.l	#39,d1			; D1=Number of characters per line
	move.l	a2,d7			; D7=Mscreen1

.Loop2	move.l	d7,a6
	lea	Chars,a1		; A1=Pointer to character set
	moveq.l	#0,d2			; Clear D2
	move.b	(a0)+,d2		; D2=ASCII code of char to print
	sub.b	#32,d2			; Convert D2
	add.w	d2,a1			; Add to strt of font
	move.l	#4,d3			; D3=Number of lines-1

.Loop3	move.b	(a1),(a6)		; Insert data
	add.w	#68,a1			; Get to next line of data
	add.w	#40,a6			; Get to next line of screen
	dbra	d3,.Loop3	
	addq.l	#1,d7			; Increment screen pointer
	dbra	d1,.Loop2
	add.w	#40*8,a2		; Get to next line of screen
	add.w	#4,a0			; Get to next set of text
	dbra	d0,.Loop1

*****************************************************************************
;		Convert The Sine Data
*****************************************************************************
Convert	tst.b	repeat			; Has the menu been already run?
	bne	DMA			; Yeah
	move.b	#-1,repeat		; The menu has already been run
	lea	SineData,a0		; A0=Ptr to sine data
.Loop	cmp.l	#SineEnd,a0		; End?
	beq	.End
	moveq.l	#0,d0			; Clear D0
	move.w	(a0),d0			; D0=Sine value
	mulu	#40,d0			; Convert 
	move.w	d0,(a0)+		; Replce sine data
	bra	.Loop
.End

*****************************************************************************
;			  Set-Up DMA
*****************************************************************************
DMA
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne	.Wait2
	move.w	#$8e30,dmacon(a5)	; Rite stuff, rite place, rite time!!
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Insert new copper list
	move.w	#$0,copjmp1(a5)		; Run that copper list
	jsr	mt_init			; Start the music

	move.l	$6c,Oldint+2		; Save old interrupt
	move.l	#NewInt,$6c		; Insert mine

*****************************************************************************
;			Main Branching Routine
*****************************************************************************

; The fisrt VBL loop
WaitVBL1
	cmpi.b	#255,vhposr(a5)		; Wait VBL
	bne	WaitVBL1
	bsr	ChangeLogos
	bsr	VUMeters		; Move the VU meters
	bsr	MoveBar			; Move copper bar
	bsr	Scroller		; Scroll the text
	btst	#$a,potgor(a5)		; Test RMB
	beq	CleanUp			; Exit

; The second VBL loop
WaitVBL2
	cmpi.b	#255,vhposr(a5)
	bne	WaitVBL2
	bsr	DoubleBuffer		; Swap the screens
	bsr	Sine_It			; Move sine-wave
	btst	#6,$bfe001
	bne	waitvbl1

; First lets see if theres anything to load
	move.w	Item,d0			; D0=Item number
	mulu	#44,d0			; Mutlitply by 44 (bytes per line)
	lea	MenuS,a0		; A0=Ptr to MenuS
	add.w	d0,a0			; Add offset
	tst.l	40(a0)			; Is there an address?
	bne	.Load
	bra	WaitVBL1		; bye
.Load	move.l	40(a0),FilePtr		; File ptr=A0
	bra	Loader			; Load The File


*****************************************************************************
;			       Clean Up
*****************************************************************************
CleanUp
	jsr	mt_end
	move.l	Oldint+2,$6c
	move.w	#$83e0,dmacon(a5)	; Enable sprite dma
	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
	move.l	4,a6			; Exec base
	move.l	#46*40,d0		; D0=size to free
	move.l	Vscreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free the memory
error3	move.l	4,a6			; Exec base
	move.l	#128*40,d0		; D0=size to free
	move.l	Mscreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free the memory
error2	move.l	4,a6			; Exec base
	move.l	#128*40*2,d0		; D0=Size to free
	move.l	Sscreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free the memory
error1	move.l	4,a6			; exec base
	move.l	gfxbase,a1
	jsr	-408(a6)		; Close library
	jsr	-138(a6)		; Permit
	moveq.l	#0,d0			; Keep CLI happy
error	rts				; Bye Bye


*****************************************************************************
;		This Is The Loader Routine
*****************************************************************************
Loader
; First clean-up my mess!
	jsr	mt_end			; End d music
	move.l	Oldint+2,$6c		; Restore sys interrupt
	move.w	#$83e0,dmacon(a5)	; Sprites enable
	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
	move.l	4,a6			; Exec base
	move.l	#128*40*2,d0		; D0=Number of bytes to free
	move.l	Sscreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free it
	move.l	4,a6			; Exec base
	move.l	#128*40,d0		; D0=Number of bytes to free
	move.l	Mscreen,a1		; A1=Address to free
	jsr	-210(a6)		; Free it
	move.l	4,a6			; Exec base
	move.l	#46*40,d0		; D0=Number of bytes to free
	move.l	VScreen,a1		; A1=Address to free
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
	jmp	Start			; and start again!



*****************************************************************************
;		Check Mouse & Move The Copper Bar
*****************************************************************************
Movebar	cmpi.b	#1,MasterS		; Is master scroll flag set?
	beq	Upit			; Scroll it UP!
	bgt	Downit			; Scroll it down!
	move.b	joy0dat(a5),d0		; D0=Vertical count
	move.b	d0,d1			; D1=D0
	sub.b	OldV,d0			; Subtract old count with new count
	move.b	d1,OldV			; Store new count
	tst.b	d0			; Test to see if mouse haz been moved
	bmi	Up			; Mouse moved up
	bne	Down			; Mouse moved down
	rts				; Mouse aint been moved, exit

********************
* THE DOWN ROUTINE *
********************
Down	lea	Bar,a0			; A0=Pointer to bar
	cmpi.b	#$e6,(a0)		; Is bar at bottom of screen?
	beq	Scroll_UP		; Scroll the menu up 1 text line
	addq.w	#1,Item			; Increment item counter
	move.l	#5,d0			; D0=Number of vert waits to change-1
.Loop1	addq.b	#8,(a0)			; Increment the wait value
	add.w	#12,a0			; Get to next wait
	dbra	d0,.Loop1		; Increment ALL wait values
	rts				; Exit
Scroll_Up			
	move.l	MenuP2,a0		; A0=Pointer to menu text
	cmpi.l	#-1,44(a0)		; Bottom of menu ??
	beq	Exit
	addq.w	#1,Item			; Increment the item counter
	add.l	#44,MenuP1		; Increment both ptrs by 1 line
	add.l	#44,MenuP2		; Ahum
	move.w	#-1,Scrolly		; Set the scrolly register
	move.b	#1,MasterS		; Set the master scroll flag
	rts				; Lets go home!
*******************
* THE UP ROUNTINE *
*******************
Up	lea	Bar,a0			; A0=Pointer to bar
	cmpi.b	#$8e,(a0)		; Is bar at top of screen?
	beq	Scroll_Down		; Scroll the menu down 1 text line
	subq.w	#1,Item			; decrement item counter
	move.l	#5,d0			; D0=Number of vert waits to change-1
.Loop1	subq.b	#8,(a0)			; decrement the wait value
	add.w	#12,a0			; Get to next wait
	dbra	d0,.Loop1		; Increment ALL wait values
	rts				; Exit
Scroll_Down
	move.l	MenuP1,a0		; A0=Pointer to menu text
	cmpi.l	#-1,-4(a0)		; Top of menu ??
	beq	Exit
	subq.w	#1,Item			; Decrement the item counter
	sub.l	#44,MenuP1		; Decrement both ptrs by 1 line
	sub.l	#44,MenuP2		; Ahum
	move.w	#-1,Scrolly		; Set the scrolly register
	move.b	#2,MasterS		; Set the master scroll flag
	rts				; Lets go home!

************************************************
* This Is The Routine That Scrolls The Menu UP *
************************************************
; This routine scrolls the 2 menu bpls up & then insert text if necessary
Upit	addq.w	#1,Scrolly		; Increment the scrolly flag
	move.w	#0,d1			; Clear D1 (bltcon1)
	move.l	Mscreen1,a0		; A0=Source
	move.l	a0,a1			; A1=Destination
	add.w	#40,a0			; Increment source by 1	line
	bsr	BlitScroll		; Scroll Up
	cmpi.w	#3,Scrolly		; Need any text?
	blt	Exit			; No text needed
	move.l	MenuP2,a0		; A0=ptr to text
	move.l	Mscreen1,a3
	add.w	#108*40,a3
	move.w	Scrolly,d0		; D0=Scrolly value
	subq.w	#3,d0			; Convert D0
	mulu	#68,d0			; Work out line of font required
	lea	Chars,a1		; A1=Pointer to character set
	add.w	d0,a1			; Get to desired line.
	bsr	PrintTxt
	cmpi.w	#7,Scrolly		; End of scrolly ?
	blt	Exit
	move.b	#0,MasterS		; Reset master scrolly
	rts



**************************************************
* This Is The Routine That Scrolls The Menu Down *
**************************************************
; This routine scrolls the 2 menu bpls down & then insert text if necessary
Downit	addq.w	#1,Scrolly		; Increment the scrolly flag
	move.w	#2,d1			; bltcon1=Decrement mode
	move.l	Mscreen1,a0		; A0=Source
	move.l	a0,a1			; A1=Destination
	add.w	#108*40,a0
	add.w	#109*40,a1
	bsr	BlitScroll		; Scroll Up
	cmpi.w	#3,Scrolly		; Need any text?
	blt	Exit			; No text needed
	move.l	MenuP1,a0		; A0=ptr to text
	move.w	#7,d0			; D0=4 (point to last line of font)
	sub.w	Scrolly,d0		; Convert D0
	mulu	#68,d0			; Work out line of font required
	lea	Chars,a1		; A1=Pointer to character set
	add.w	d0,a1			; Get to desired line.
	move.l	Mscreen1,a3
;	sub.w	#40,a3
	bsr	PrintTxt
	cmpi.w	#7,Scrolly		; End of scrolly ?
	blt	Exit
	move.b	#0,MasterS		; Reset master scrolly
Exit	rts				; Also EXIT for some others

**********************************
* BLITTER ROUTINE TO SCROLL TEXT *
**********************************
BlitScroll
	btst	#14,dmaconr(a5)		; Test blitter
	bne	BlitScroll
	move.l	a0,bltapth(a5)		; A=MScreen?+?
	move.l	a1,bltdpth(a5)		; D=Mscreen?
	move.w	#0,bltamod(a5)		; No A modulo
	move.w	#0,bltdmod(a5)		; No D modulo
	move.w	#$ffff,bltafwm(a5)	; No masks
	move.w	#$ffff,bltalwm(a5)
	move.w	#%100111110000,bltcon0(a5) ; A-D blit
	move.w	d1,bltcon1(a5)		; Ahhhh-tiss-u
	move.w	#(111*64)+20,bltsize(a5); 111*320
	rts

********************************************
* THIS ROUTINE PUTS THE TEXT ON THE SCREEN *
********************************************
PrintTxt
	move.l	#39,d0			; D0=Number of chars per line-1
.Loop1	moveq.l	#0,d1			; Clear D1
	move.b	(a0)+,d1		; D1=Ascii code of character to print
	sub.b	#32,d1			; Convert code
	move.l	a1,a2			; A2=Font set
	add.w	d1,a2			; Get to required data
	move.b	(a2),(a3)+		; Move the data into the screen
	dbra	d0,.Loop1
	rts	

*****************************************************************************
;			The VU meters
*****************************************************************************
VUMeters
	moveq.l	#3,d0			; D0=Number of VU meters
	move.l	#80,d1			; D1=Offset for VU meter
	lea	mt_voice1,a2		; A2=Mt_voice address
	lea	Inc1,a3			; A3=Inc ptr
.VULoop
	cmpi.w	#0,(a2)			; Is channel being used?
	bne	.Fill
	cmpi.w	#1680,(a3)		; Is bar fully decremented ?
	beq	.Endy
	move.l	Vscreen,a0		; A0=Pointer to VU screen
	add.w	d1,a0			; Add the offset
	add.w	(a3),a0			; Add the increment
	add.w	#40,(a3)		
	move.w	#3,d7
.Loop1	move.w	#0,(a0)+
	dbra	d7,.Loop1
	bra	.Endy	

.Fill	move.w	#0,(a3)			; Clear Inc1
	move.l	Vscreen,a0
	add.w	d1,a0			; Get to desired offset
.Wait	btst	#14,dmaconr(a5)		; Test blitter
	bne	.Wait
	move.l	a0,bltdpth(a5)		; Desination=Screen
	move.w	#32,bltdmod(a5)
	move.w	#$ffff,bltafwm(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#%111111111,bltcon0(a5)	; Blit a '1' no matter wot!
	move.w	#$0,bltcon1(a5)		; Fuck that register!
	move.w	#(42*64)+4,bltsize(a5)	; Size=64*42

.Endy	add.w	#28,a2
	add.w	#10,d1
	tst.w	(a3)+			; Increment A3
	dbra	d0,.VULoop
	rts

*****************************************************************************
;		       THE SINE SCROLLER
*****************************************************************************
Scroller
	cmpi.w	#0,Pause		; Need a pause?
	beq	.No
	sub.w	#1,Pause		; Decrement pause
	rts
.No	cmpi.b	#0,PlopC		; Need a new character?
	bne	Scroll
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
	lea	Font,a0			; A0=Address of font
	add.w	d0,a0			; Add offset
	lea	Buffer,a1		; A1=Ptr to scroller buffer
	add.w	#42,a1			; Get to desired offset
.Wait	btst	#14,dmaconr(a5)		; Test blitter
	bne	.Wait
	move.l	a0,bltapth(a5)		; A=character
	move.l	a1,bltdpth(a5)		; D=Screen
	move.w	#118-2,bltamod(a5)	; 116 A modulo
	move.w	#46-2,bltdmod(a5)	; 44 D modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%100111110000,bltcon0(a5) ; A-D blit
	move.w	#$0,bltcon1(a5)		; clear
	move.w	#(16*64)+1,bltsize(a5)	; 15*16
	move.b	#8,PlopC		; Reset plop counter
Scroll
	lea	buffer,a0
	move.l	a0,a1
	sub.w	#2,a1
.Wait	btst	#14,dmaconr(a5)		; Wait blitter
	bne	.Wait
	move.l	a0,bltapth(a5)		; A Source=Scroller
	move.l	a1,bltdpth(a5)		; D Source=Scroller-2
	move.w	#0,bltamod(a5)		; No modulos
	move.w	#0,bltdmod(a5)
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%1100100111110000,bltcon0(a5) ; A-D blit 14 shift
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#(16*64)+23,bltsize(a5)	; 368*16
	subq.b	#2,PlopC		; Decrement plop counter
	rts

*****************************************************************************	
;     This Routine Converts The Normal Scroller Into A Sine-Scroller
*****************************************************************************
Sine_It
; First lets delete the last frame
.Wait	btst	#14,dmaconr(a5)
	bne	.Wait
	move.l	Sscreenb,bltdpth(a5)	; Destination=Sine screen
	move.w	#0,bltdmod(a5)		; No modulo
	move.w	#%100000000,bltcon0(a5)	; Wipe blit
	move.w	#$0,bltcon1(a5)		; Oki-doke
	move.w	#(128*64)+20,bltsize(a5); 128*320

; Now lets DO IT!
; Set-up the constant blitter registers for speed
.Wait1	btst	#14,dmaconr(a5)
	bne	.Wait1
	move.w	#%110111111100,bltcon0(a5) ; D=A+B
	move.w	#0,bltcon1(a5)		; Clear
	move.w	#46-2,bltamod(a5)	; 44 A modulo
	move.w	#40-2,bltbmod(a5)	; 38 B modulo
	move.w	#40-2,bltdmod(a5)	; 38 D modulo
	move.w	#$ffff,bltafwm(a5)	; No FWM

	move.l	#19,d0			; D0=Number of words/screen-1
	move.w	#$8000,d1		; Mask to rotate
	move.l	#15,d2			; Pixels per word-1
	lea	Buffer,a2		; A2=Pointer to buffer
	move.l	Sscreenb,a3		; A3=Pointer to screen	

	move.l	SineP,a6		; A6=Pointer to sine table
	subq.l	#2,SineP		; Decrement sine pointer
	cmpi.l	#SineData,sineP
	bne	BigLoop	
	move.l	#SineEnd,SineP

; Heres is the BIG loop.  It is executed 320 timers per frame!!!
BigLoop	move.l	a3,a4			; A4=Copy of screen pointer

	cmpi.w	#$ffff,(a6)		; End of sine table?
	bne	.Nope
	lea	Sinedata,a6		; Reset pointer
.Nope	add.w	(a6)+,a4		; Add to screen address
.Wait	btst	#14,dmaconr(a5)
	bne	.Wait
	move.l	a2,bltapth(a5)		; A=Buffer
	move.l	a4,bltbpth(a5)		; B=Destination
	move.l	a4,bltdpth(a5)		; D=Destination
	move.w	d1,bltalwm(a5)		; Insert the LWM
	move.w	#(16*64)+1,bltsize(a5)	; Blit the line!
	lsr.w	d1			; Rotate the mask
	dbra	d2,BigLoop
	
	addq.l	#2,a2			; Increment buffer pointer
	addq.l	#2,a3			; Increment screen pointer
	move.l	#15,d2			; Reload pixels per word-1
	move.w	#$8000,d1		; Re-load mask
	dbra	d0,BigLoop
	rts
	
*****************************************************************************
;		Double Buffer
*****************************************************************************
DoubleBuffer
	move.l	Sscreena,a0
	move.l	Sscreenb,a1
	move.l	a0,Sscreenb
	move.l	a1,Sscreena
	move.l	a1,d0
	bra	SetScrl

*****************************************************************************
;		Routine To Change The Logos
*****************************************************************************
ChangeLogos
	cmpi.w	#0,LDelay
	beq	.Change
	subq.w	#1,LDelay
	rts

.Change	cmpi.b	#$2c,Waity		; Reached top of screen?
	beq	.Top
	subq.b	#$1,Waity		; Decrement Waity
	rts

.Top	move.b	#$7d,Waity		; Reset the wait Value
	move.w	#50*10,LDelay		; Reset the delay value

	move.l	Logoa,d1		; D1=Logoa
	move.l	Logob,d0		; D0=Logob
	move.l	d0,Logoa
	move.l	d1,Logob
	bsr	SetLogo			; Change the logos

	move.l	LColsa,d0
	move.l	LColsb,d1
	move.l	d0,LColsb
	move.l	d1,LColsa

	move.l	LColsa,a0		; A0=Ptr to colours
	move.l	#Colsa+2,a1		; A1=Ptr to destination
	move.l	#15,d0
.Loop1	move.w	(a0)+,(a1)
	addq.w	#4,a1
	dbra	d0,.Loop1

	move.l	LColsb,a0		; A0=Ptr to colours
	move.l	#Colsb+2,a1		; A1=Ptr to destination
	move.l	#15,d0
.Loop2	move.w	(a0)+,(a1)
	addq.w	#4,a1
	dbra	d0,.Loop2
	rts

*****************************************************************************
;		Routine To Set-Up The Bitplanes
*****************************************************************************
SetLogo	move.w	d0,Lbpl1+2		; Insert low word
	swap	d0
	move.w	d0,Lbph1+2
	swap	d0
	add.l	#40,d0
	move.w	d0,Lbpl2+2
	swap	d0
	move.w	d0,Lbph2+2
	swap	d0
	add.l	#40,d0
	move.w	d0,Lbpl3+2
	swap	d0
	move.w	d0,Lbph3+2
	swap	d0
	add.l	#40,d0
	move.w	d0,Lbpl4+2
	swap	d0
	move.w	d0,Lbph4+2

	move.w	d1,Lbpl1a+2		; Insert low word
	swap	d1
	move.w	d1,Lbph1a+2
	swap	d1
	add.l	#40,d1
	move.w	d1,Lbpl2b+2
	swap	d1
	move.w	d1,Lbph2b+2
	swap	d1
	add.l	#40,d1
	move.w	d1,Lbpl3c+2
	swap	d1
	move.w	d1,Lbph3c+2
	swap	d1
	add.l	#40,d1
	move.w	d1,Lbpl4d+2
	swap	d1
	move.w	d1,Lbph4d+2
	rts
SetScrl	move.w	d0,Mbpl1+2		
	swap	d0
	move.w	d0,Mbph1+2	
	rts
SetMenu	move.w	d0,Mbpl2+2
	swap	d0
	move.w	d0,Mbph2+2
	rts
SetVu	move.w	d0,Vbpl1+2		; Insert low word
	swap	d0
	move.w	d0,Vbph1+2
	rts

*****************
* The Interrupt *
*****************
NewInt	movem.l	d0-d7/a0-a6,-(sp)	; Save registers
	jsr	mt_music		; Play muzak
	movem.l	(sp)+,d0-d7/a0-a6	; Restore registers
Oldint	jmp	$0			; Do system interrupt

*****************************************************************************
;			Copper List
*****************************************************************************
	section	copper,data_c		; Chip data
Copperlist
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fect stop

************************
* THE LOGO COPPER LIST *
************************
	dc.w	bplcon0,%0100001000000000 ; 4 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,120		; 120 modulo (odd)
	dc.w	bpl2mod,120		; 120 modulo (even)
; Bitplane pointers
Lbph1	dc.w	bpl1pth,$0	
Lbpl1	dc.w	bpl1ptl,$0
Lbph2	dc.w	bpl2pth,$0	
Lbpl2	dc.w	bpl2ptl,$0
Lbph3	dc.w	bpl3pth,$0	
Lbpl3	dc.w	bpl3ptl,$0
Lbph4	dc.w	bpl4pth,$0	
Lbpl4	dc.w	bpl4ptl,$0
; Colours
Colsa	dc.w	$180,$000,$182,$aaa,$184,$625,$186,$626
	dc.w	$188,$637,$18a,$648,$18c,$659,$18e,$737
	dc.w	$190,$848,$192,$78a,$194,$b7b,$196,$dad
	dc.w	$198,$614,$19a,$ece,$19c,$dde,$19e,$fff

Waity   dc.w	$7d01,$fffe

; Bitplane pointers
Lbph1a	dc.w	bpl1pth,$0	
Lbpl1a	dc.w	bpl1ptl,$0
Lbph2b	dc.w	bpl2pth,$0	
Lbpl2b	dc.w	bpl2ptl,$0
Lbph3c	dc.w	bpl3pth,$0	
Lbpl3c	dc.w	bpl3ptl,$0
Lbph4d	dc.w	bpl4pth,$0	
Lbpl4d	dc.w	bpl4ptl,$0
; Colours
Colsb	dc.w	$180,$000,$182,$577,$184,$dee,$186,$cdd
	dc.w	$188,$bcc,$18a,$9bc,$18c,$8ab,$18e,$79a
	dc.w	$190,$689,$192,$578,$194,$467,$196,$356
	dc.w	$198,$245,$19a,$234,$19c,$123,$19e,$fff

**************************************
* THE MENU/SINE-SCROLLER COPPER LIST *
**************************************
	dc.w	$7e01,$fffe		; Wait before changing screen
	dc.w	bplcon0,%0010001000000000 ; 2 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,0		; No modulo (odd)
	dc.w	bpl2mod,0		; No modulo (even)
; Bitplane pointers
Mbph1	dc.w	bpl1pth,$0	
Mbpl1	dc.w	bpl1ptl,$0
Mbph2	dc.w	bpl2pth,$0	
Mbpl2	dc.w	bpl2ptl,$0


; Colours
	dc.w	$182,$cff	; Sine scroll
; Fade the text in
	dc.w	$8501,$fffe,$184,$111,$186,$000
	dc.w	$8601,$fffe,$184,$111,$186,$111
	dc.w	$8701,$fffe,$184,$222,$186,$222
	dc.w	$8801,$fffe,$184,$333,$186,$333
	dc.w	$8901,$fffe,$184,$444,$186,$444
	dc.w	$8a01,$fffe,$184,$555,$186,$555
	dc.w	$8b01,$fffe,$184,$666,$186,$666
	dc.w	$8c01,$fffe,$184,$777,$186,$777
	dc.w	$8d01,$fffe,$184,$888,$186,$888

Bar	dc.w	$8e01,$fffe,$184,$f00,$186,$f00
	dc.w	$8f01,$fffe,$184,$f20,$186,$f20
	dc.w	$9001,$fffe,$184,$f50,$186,$f50
	dc.w	$9101,$fffe,$184,$f80,$186,$f80
	dc.w	$9201,$fffe,$184,$fa0,$186,$fa0
	dc.w	$9301,$fffe,$184,$888,$186,$888

; Fade the text out
	dc.w	$ee01,$fffe,$184,$777,$186,$666
	dc.w	$ef01,$fffe,$184,$666,$186,$555
	dc.w	$f001,$fffe,$184,$555,$186,$444
	dc.w	$f101,$fffe,$184,$444,$186,$333
	dc.w	$f201,$fffe,$184,$333,$186,$222
	dc.w	$f301,$fffe,$184,$222,$186,$111
	dc.w	$f401,$fffe,$184,$111,$186,$000

; Just clear the crap!!
	dc.w	$188,$000,$18a,$000,$18c,$000,$18e,$000	  
	dc.w	$fd01,$fffe,$182,$000	

*****************************
* THE VU-METERS COPPER LIST *
*****************************
	dc.w	$ffe1,$fffe		; Wait before changing screen
	dc.w	bplcon0,%0001001000000000 ; 1 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,0		; No modulo (odd)
	dc.w	bpl2mod,0		; No modulo (even)
; Bitplane pointers
Vbph1	dc.w	bpl1pth,$0	
Vbpl1	dc.w	bpl1ptl,$0
; Colours
	dc.w	$180,$000
	dc.w	$0201,$fffe,$182,$ff0	; Fading for the VU meters
	dc.w	$0301,$fffe,$182,$ff0
	dc.w	$0401,$fffe,$182,$fe0
	dc.w	$0501,$fffe,$182,$fe0
	dc.w	$0601,$fffe,$182,$fd0
	dc.w	$0701,$fffe,$182,$fd0
	dc.w	$0801,$fffe,$182,$fc0
	dc.w	$0901,$fffe,$182,$fc0
	dc.w	$0a01,$fffe,$182,$fb0
	dc.w	$0b01,$fffe,$182,$fb0
	dc.w	$0c01,$fffe,$182,$fa0
	dc.w	$0d01,$fffe,$182,$fa0
	dc.w	$0e01,$fffe,$182,$f90
	dc.w	$0f01,$fffe,$182,$f90
	dc.w	$1001,$fffe,$182,$f80
	dc.w	$1101,$fffe,$182,$f80
	dc.w	$1201,$fffe,$182,$f70
	dc.w	$1301,$fffe,$182,$f70
	dc.w	$1401,$fffe,$182,$f60
	dc.w	$1501,$fffe,$182,$f60
	dc.w	$1601,$fffe,$182,$f50
	dc.w	$1701,$fffe,$182,$f50
	dc.w	$1801,$fffe,$182,$f40
	dc.w	$1901,$fffe,$182,$f40
	dc.w	$1a01,$fffe,$182,$f30
	dc.w	$1b01,$fffe,$182,$f30
	dc.w	$1c01,$fffe,$182,$f20
	dc.w	$1d01,$fffe,$182,$f20
	dc.w	$1e01,$fffe,$182,$f10
	dc.w	$1f01,$fffe,$182,$f10
	dc.w	$2001,$fffe,$182,$f00
	dc.w	$2101,$fffe,$182,$f00
	dc.w	$2201,$fffe,$182,$e00
	dc.w	$2301,$fffe,$182,$e00
	dc.w	$2401,$fffe,$182,$d00
	dc.w	$2501,$fffe,$182,$d00
	dc.w	$2601,$fffe,$182,$c00
	dc.w	$2701,$fffe,$182,$c00
	dc.w	$2801,$fffe,$182,$b00
	dc.w	$2901,$fffe,$182,$b00
	dc.w	$2a01,$fffe,$182,$a00
	dc.w	$2b01,$fffe,$182,$a00
	dc.w	$2c01,$fffe,$182,$900
	dc.w	$2d01,$fffe,$182,$900
	dc.w	$ffff,$fffe		; Wait for lufc to win something!


*****************************************************************************
;			     Variables
*****************************************************************************
	section	variables,data		; Public
repeat	dc.b	0
gfxname	dc.b	'graphics.library',0
dosname	dc.b	'dos.library',0
	even
gfxbase	dc.l	0			; Space for gfx base address
dosbase	dc.l	0			; Space for dos base address
Mscreen dc.l	0			; Screen pointers
MScreen1 dc.l	0
Sscreen  dc.l	0
Sscreena dc.l	0
Sscreenb dc.l	0
Vscreen	dc.l	0
Logoa	dc.l	ALLlogo
Logob	dc.l	UPlogo
LColsa	dc.l	ALLCols
LColsb	dc.l	UPCols
LDelay	dc.w	50*10

; Shit for the menu
MenuP1	dc.l	menuS			; Pointer to menu
MenuP2	dc.l	MenuE
	include	'source:raistlin/menu2/misc/menu.txt'	; Include the menu
	include	'source:raistlin/menu2/misc/proggie.txt'	
	even
Conhdle	dc.l	0
FilePtr	dc.l	0				; Pointer to file
Conname	dc.b	'CON:0/10/640/36/ALLIANCE....',0

; Shit for the mouse & menu bar
Oldv	dc.b	0			; Hold the mouse vert cords
MasterS	dc.b	0			; Master scroll flag
	even
Item	dc.w	1			; Menu item select ID
Scrolly	dc.w	0			; Current menu item highlited!!

; Shit for the VU meters
Inc1	dc.w	0			; Offset for VU meter 1
Inc2	dc.w	0			; Offset for VU meter 2
Inc3	dc.w	0			; Dito 3
Inc4	dc.w	0			; dito 4

; Colours for the alliance logo
ALLcols	dc.w	$000,$aaa,$625,$626,$637,$648,$659,$737
	dc.w	$848,$78a,$b7b,$dad,$614,$ece,$dde,$fff
; Colours for the unknown pleasures logo
UPCols	dc.w	$000,$577,$dee,$cdd,$bcc,$9bc,$8ab,$79a
	dc.w	$689,$578,$467,$356,$245,$234,$123,$fff

; The sine scroller variables
PlopC	dc.b	0
Text	dc.b	32
	incbin	'source:raistlin/menu2/misc/ScrollText.i'
	dc.b	'x'
	even
Pause	dc.w	0
STextP	dc.l	Text
SineP	dc.l	SineEnd
SineData
	dc.w 55,57,60,62,64,66,68,70,72,74,76,78,80,81,83,84,86,87
	dc.w 88,89,90,91,92,93,93,94,94,95,95,95,95,95,95,95,95,95
	dc.w 94,94,94,93,93,92,92,91,91,90,90,89,89,88,88,88,87,87
	dc.w 87,86,86,86,86,86,86,86,86,86,86,87,87,87,88,88,88,89
	dc.w 89,90,90,91,91,92,92,93,93,94,94,95,95,95,96,96,96,96
	dc.w 96,96,96,96,96,95,95,95,94,94,93,92,91,91,90,89,88,87
	dc.w 86,84,83,82,81,79,78,77,76,74,73,72,70,69,68,67,66,65
	dc.w 64,63,62,61,60,60,59,59,58,58,58,58,58,58,58,58,58,59
	dc.w 59,60,60,61,62,63,63,64,65,66,67,68,70,71,72,73,74,75
	dc.w 76,77,78,79,80,81,82,82,83,84,84,85,85,85,86,86,86,86
	dc.w 86,85,85,85,84,84,83,82,82,81,80,79,78,77,76,75,74,73
	dc.w 72,71,69,68,67,66,65,64,63,62,61,60,59,58,57,57,56,56
	dc.w 55,55,54,54,54,53,53,53,53,53,53,54,54,54,54,55,55,55
	dc.w 56,56,57,57,57,58,58,59,59,59,60,60,60,60,61,61,61,61
	dc.w 61,61,60,60,60,59,59,58,58,57,56,56,55,54,53,52,51,50
	dc.w 49,48,47,46,45,44,42,41,40,39,38,37,36,35,35,34,33,32
	dc.w 32,31,31,30,30,30,30,30,30,30,30,30,31,31,32,32,33,34
	dc.w 34,35,36,37,38,39,40,41,42,43,44,45,46,48,49,50,50,51
	dc.w 52,53,54,54,55,56,56,56,57,57,57,57,57,57,57,56,56,56
	dc.w 55,54,54,53,52,51,50,49,48,47,46,44,43,42,41,39,38,37
	dc.w 35,34,33,32,30,29,28,27,26,25,24,24,23,22,22,21,21,20
	dc.w 20,20,19,19,19,19,19,20,20,20,21,21,21,22,22,23,24,24
	dc.w 25,25,26,27,27,28,28,29,30,30,31,31,31,32,32,32,33,33
	dc.w 33,33,33,33,33,33,33,32,32,32,32,31,31,30,30,30,29,29
	dc.w 28,28,27,27,27,26,26,26,25,25,25,25,25,25,25,25,26,26
	dc.w 26,27,28,28,29,30,31,32,33,34,36,37,38,40,41,43,45,46
	dc.w 48,50,52,54,55,57,59,61,63,65,66,68,70,71,73,74,76,77
	dc.w 79,80,81,82,83,84,85,85,86,86,87,87,87,87,87,87,87,86
	dc.w 86,85,85,84,83,82,82,81,80,79,78,77,75,74,73,72,71,70
	dc.w 69,68,67,66,64,64,63,62,61,60,59,59,58,57,57,56,56,56
	dc.w 55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,56,56,56
	dc.w 56,56,56,56,56,56,56,56,56,56,55,55,54,54,54,53,52,52
	dc.w 51,50,49,48,47,46,45,44,43,42,41,40,39,37,36,35,34,33
	dc.w 31,30,29,28,27,26,25,25,24,23,23,22,22,21,21,21,21,21
	dc.w 21,21,22,22,23,23,24,25,25,26,27,28,30,31,32,33,35,36
	dc.w 37,39,40,42,43,45,46,48,49,50,52,53,54,56,57,58,59,60
	dc.w 61,62,62,63,63,64,64,65,65,65,65,65,65,65,65,64,64,63
	dc.w 63,62,62,61,60,60,59,58,58,57,56,55,55,54,53,52,52,51
	dc.w 51,50,50,49,49,49,49,48,48,48,48,48,49,49,49,50,50,50
	dc.w 51,52,52,53,54,54,55,56,57,58,58,59,60,61,62,62,63,64
	dc.w 65,65,66,66,67,67,68,68,68,68,69,69,69,69,68,68,68,68
	dc.w 67,67,66,66,65,65,64,63,62,62,61,60,59,59,58,57,56,56
	dc.w 55,54,54,53,52,52,51,51,51,51,50,50,50,50,51,51,51,51
	dc.w 52,52,53,54,54,55,56,57,58,59,60,61,62,63,65,66,67,68
	dc.w 69,70,72,73,74,75,76,77,78,78,79,80,80,81,81,82,82,82
	dc.w 82,82,82,82,82,82,81,81,80,79,78,78,77,76,75,74,72,71
	dc.w 70,69,68,66,65,64,62,61,60,58,57,56,55,54,52,51,50,50
	dc.w 49,48,47,46,46,45,45,45,44,44,44,44,44,44,44,44,45,45
	dc.w 45,46,46,47,47,48,48,49,49,50,51,51,52,52,53,53,54,54
	dc.w 55,55,56,56,56,56,56,57,57,57,57,56,56,56,56,55,55,55
	dc.w 54,54,53,53,52,51,51,50,50,49,48,48,47,47,46,46,45,45
	dc.w 45,44,44,44,44,44,44,44,45,45,45,46,46,47,48,48,49,50
	dc.w 51,52,53,54,56,57,58,59,61,62,64,65,66,68,69,70,72,73
	dc.w 74,76,77,78,79,80,81,82,83,83,84,84,85,85,85,85,85,85
	dc.w 85,85,84,84,83,83,82,81,80,79,78,77,76,74,73,72,70,69
	dc.w 67,66,64,63,61,60,58,57,55,54,53,51,50,49,47,46,45,44
	dc.w 43,42,42,41,40,40,39,39,38,38,38,37,37,37,37,37,37,37
	dc.w 37,37,38,38,38,38,38,38,39,39,39,39,39,39,39,39,39,39
	dc.w 39,39,39,38,38,38,37,37,36,36,35,35,34,33,32,32,31,30
	dc.w 29,28,28,27,26,25,24,24,23,22,21,21,20,20,19,19,19,18
	dc.w 18,18,18,18,18,19,19,19,20,21,21,22,23,24,25,26,28,29
	dc.w 30,32,33,35,36,38,40,41,43,45,46,48,50,52,53,55,56,58
	dc.w 60,61,62,64,65,66,67,69,70,70,71,72,73,73,73,74,74,74
	dc.w 74,74,74,74,74,73,73,72,72,71,71,70,69,69,68,67,66,65
	dc.w 64,64,63,62,61,61,60,59,59,58,57,57,56,56,56,56,55,55
	dc.w 55,55,55,55,55,56,56,56,57,57,58,58,59,59,60,60,61,61
	dc.w 62,63,63,64,64,65,65,66,66,67,67,67,68,68,68,68,68,68
	dc.w 68,67,67,67,66,66,65,65,64,63,63,62,61,60,59,58,57,56
	dc.w 55,54,53,52,51,50,49,48,47,46,45,44,43,43,42,41,41,40
	dc.w 40,39,39,39,39,39,39,39,39,40,40,40,41,41,42,43,43,44
	dc.w 45,46,47,48,48,49,50,51,52,53,54,55,55,56,57,57,58,59
	dc.w 59,59,60,60,60,60,60,60,60,60,59,59,58,58,57,56,56,55
	dc.w 54,53,52,50,49,48,47,45,44,43,41,40,38,37,36,34,33,31
	dc.w 30,29,28,27,26,25,24,23,22,21,20,20,19,19,19,18,18,18
	dc.w 18,18,18,19,19,19,20,20,21,21,22,23,23,24,25,26,26,27
	dc.w 28,29,30,30,31,32,32,33,34,34,35,35,36,36,37,37,37,37
	dc.w 38,38,38,38,38,38,37,37,37,37,36,36,36,36,35,35,34,34
	dc.w 34,34,33,33,33,33,32,32,32,32,32,32,33,33,33,34,34,35
	dc.w 35,36,37,38,39,40,41,42,43,44,46,47,48,50,51,53,54,56
	dc.w 57,59,61,62,64,65,67,68,70,71,72,73,75,76,77,78,79,79
	dc.w 80,81,81,81,82,82,82,82,82,82,82,81,81,80,79,79,78,77
	dc.w 76,75,74,73,72,71,69,68,67,66,65,63,62,61,60,58,57,56
	dc.w 55,54,53,52,52,51,50,50,49,48,48,48,48,47,47,47,47,47
	dc.w 48,48,48,49,49,50,50,51,51,52,52,53,54,55,55,56,57,57
	dc.w 58,59,59,60,60,61,61,62,62,62,63,63,63,63,63,63,63,63
	dc.w 63,63,63,62,62,62,62,61,61,61,60,60,59,59,59,58,58,58
	dc.w 57,57,57,57,57,57,57,57,57,58,58,58,59,60,60,61,62,63
	dc.w 64,65,66,67,68,70,71,72,74,75,77,79,80,82,84,85,87,89
	dc.w 90,92,94,95,97,98,100,101,102,104,105,106,107,108,109
	dc.w 110,110,111,111,112,112,112,112,112,112,111,111,111,110
	dc.w 109,109,108,107,106,105,104,103,102,101,99,98,97,95,94
	dc.w 93,91,90,89,88,86,85,84,83,82,81,80,79,78,77,76,75,75
	dc.w 74,74,73,73,72,72,72,72,72,72,71,71,71,72,72,72,72,72
	dc.w 72,72,72,72,72,72,72,72,72,72,72,71,71,71,70,70,69,69
	dc.w 68,68,67,66,65,64,63,62,61,60,58,57,56,55,53,52,50,49
	dc.w 48,46,45,43,42,41,39,38,37,35,34,33,32,31,30,29,28,28
	dc.w 27,26,26,26,25,25,25,25,25,25,25,25,25,26,26,27,27,28
	dc.w 28,29,30,30,31,32,33,33,34,35,35,36,37,37,38,38,39,39
	dc.w 39,40,40,40,40,40,40,39,39,39,38,38,37,36,36,35,34,33
	dc.w 32,31,30,28,27,26,25,23,22,21,19,18,17,15,14,13,11,10
	dc.w 9,8,7,6,5,4,3,3,2,1,1,1,0,0,0,0,0,0,0,1,1,2,2,3,3,4,5
	dc.w 6,7,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,23
	dc.w 24,25,25,26,26,27,27,27,28,28,28,28,28,28,28,28,28,28
	dc.w 28,27,27,27,27,27,26,26,26,26,26,26,26,25,25,26,26,26
	dc.w 26,26,27,27,28,28,29,29,30,31,32,33,34,35,36,37,38,40
	dc.w 41,42,44,45,47,48,50,51,53
SineEnd	dc.w $ffff
*************************
* Chip Data & Variables *
*************************
	section	gfxstuff,data_c
Font	incbin	'source:raistlin/menu2/gfx/Font.gfx'
UPlogo	incbin	'source:raistlin/menu2/gfx/UPLogo.gfx'
ALLlogo	incbin	'source:raistlin/menu2/gfx/Alliance.gfx'
Chars	incbin	'source:raistlin/menu2/gfx/Chars.gfx'
	dcb.b	46,0
Buffer	dcb.b	16*46,0				; Buffer for sine scroller

;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 8 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used registers: d0-d3/a0-a7|	=INTENA н
;н  Mahoney & Kaktus - (C) E.A.S. 1990  н
;нннннннннннннннннннннннннннннннннннннннн
	section	ALLIANCE,code		
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


	section	Alliance,code_c
mt_data	incbin	'df1:modules/mod.music''


