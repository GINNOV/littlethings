
*	Very simple `Blitter Cookie Cut example' 
*	By Mike Cross, September 1990

*	Bob size : 96 x 93 x 1

*	This program sets up a standard 1 plane screen covered with an
*	8 x 8 grid. The blitter first copies a piece of the background
*	grid into a buffer and then combines the bob and background back
*	onto the screen.

*	Copy the Hw_examples.i file into your include/hardware directory.

*	Try experimenting with different minterms and see just how 
*	important the `cookie cut' function is!



	incdir	include/			* Official Hardware include file
	include	hardware/hw_examples.i
	
	
	lea	$dff000,a5		* Use A5 as hardware base
	
	movea.l	$4.w,a6			
	jsr	-132(a6)
	
	jsr	OpenGfx			* Get Gfx pointers
	jsr	Setup			* Put grid on screen

	move.w	#$0020,dmacon(a5)		* Disable sprite nasties
	
	jmp	Main
			
Setup	move.l	#Screen,d0
	move.w	d0,Bh12
	swap	d0
	move.w	d0,Bh1
	rts
	
OpenGfx	lea	Gfxname,a1		* Library to open
	movea.l	$4.w,a6			* ExecBase
	jsr	-408(a6)			* OpenLibrary
	move.l	d0,Gfxbase		* Save GFx Structure
	rts
	
Main	move.l	#Copper,cop1lc(a5)	* Insert my list
	clr.w	copjmp1(a5)		* And Strobe it

	move.l	$6c,OldInt+2		* Save old IRQ
	move.l	#NewInt,$6c		* And insert my new one
	jmp	Wait
	
NewInt	movem.l	a0-a6/d0-d7,-(a7)
	
	
	jsr	Cookies			* Anyone for cookies ?


Exit	movem.l	(a7)+,a0-a6/d0-d7

OldInt	jmp	$00000000		* OOOOH! - How naughty.
					* You get V2.0 next time!
Wait	btst	#6,$bfe001	
	beq.s	Quit
	bne.s	Wait
	
Quit	move.l	OldInt+2,$6c
	move.l	Gfxbase,a0
	move.l	38(a0),cop1lc(a5)	* Get old screen
	move.w	#$8e30,dmacon(a5)	* Restore DMA
	
Out	move.l	Gfxbase,a1
	movea.l	$4.w,a6
	jsr	-414(a6)			* CloseLibrary()
	jsr	-138(a6)			* Permit()
	moveq.l	#0,d0
	rts
	
	
	
Cookies	bsr	Blit
	
	lea	Screen,a0				
	adda.w	#3014,a0
		
	move.l	a0,bltapt(a5)			* Source
	move.l	#Buffer,bltdpt(a5)		* Destination
	move.w	#28,bltamod(a5)
	clr.w	bltdmod(a5)	
	move.w	#%1111111111111111,bltafwm(a5)	* No masking
	move.w	#%1111111111111111,bltalwm(a5)
	move.w	#%0000000000000000,bltcon1(a5)
	move.w	#%0000100111110000,bltcon0(a5)	* D = A
	move.w	#%0001011101000110,bltsize(a5)	* Size = 96x93
	
	bsr	Blit
	move.l	#Bob,bltapt(a5)			* A Source
	move.l	#Buffer,bltbpt(a5)		* B Source
	move.l	a0,bltdpt(a5)			* Destination
	clr.w	bltamod(a5)			* Clear Modulo`s
	clr.w	bltbmod(a5)
	move.w	#28,bltdmod(a5)			* Except this one!
	
	move.w	#%0000110111111100,bltcon0(a5)	* D = AB
	move.w	#%0001011101000110,bltsize(a5)	* Same size as before
	rts
	
	
Blit	btst	#14,dmaconr(a5)			* Test BBusy
	bne.s	Blit				* Loop if blitter not ready
	rts
	
	
	Section	Server,code_c
	
Copper	dc.w	diwstrt,$2c81			* Standard 320 x 256 screen
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bplcon0,$1200			* 1 Plane
	dc.w	bpl1mod,$0000
	dc.w	bpl2mod,$0000
	dc.w	color+$00,$0000			* Black
	dc.w	color+$02,$0fff			* White

	dc.w	bplpt+$00			* Plane address
Bh1	dc.w	$0000,bplpt+$02
Bh12	dc.w	$0000

	dc.l	$fffffffe			* End cop list
		
	
Gfxbase	dc.l	0

Gfxname	dc.b	"graphics.library",0

	even

Screen	incbin	source6:bitmaps/Grid.Raw			* Read grid from disk

	even
	
Bob	incbin	source6:bitmaps/Face_Bob.Raw		* Same for bob		
	
Buffer	dcb.b	1116,0				* Storage for 
						* background graphic
						



