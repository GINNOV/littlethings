
*	Use Blitter to Display a 16 colour logo

*	Code ©1990 Mike Cross, Gfx by John Lomax

*	For a full tutorial on using the blitter, read the
*	article on Club Disk 6.

*	Appologies for lack of a good example, but I have put
*	all my creativity into the tutorial this month, read it,
*	it is the best yet.

*	Bob size = 272 x 57 x 4

*	Set Tabs to 9
 
*	Copy the hardware_examples include file into your hardware
*	include directory.

	
	
	incdir	:include/			
	include	hardware/hw_examples.i
	
	
	
	lea	$dff000,a5		* Use A5 as hardware base
	
	movea.l	$4.w,a6
	jsr	-132(a6)			* Forbid()
	
	move.w	#$0020,dmacon(a5)
			
	move.l	#Screen1,d0
	move.w	d0,Bh12
	swap	d0
	move.w	d0,Bh1
	swap	d0
	add.w	#2280,d0
	move.w	d0,Bh22
	swap	d0
	move.w	d0,Bh2
	swap	d0
	add.w	#2280,d0
	move.w	d0,Bh32
	swap	d0
	move.w	d0,Bh3
	swap	d0
	add.w	#2280,d0
	move.w	d0,Bh42
	swap	d0
	move.w	d0,Bh4

	lea	Gfxname,a1		* Library to open
	movea.l	$4.w,a6			* ExecBase
	jsr	-408(a6)			* OpenLibrary
	beq.s	QuickX
	move.l	d0,Gfxbase		* Save GFx Structure
	
	move.l	#Copper,cop1lc(a5)	* Insert my list
	move.w	#0,copjmp1(a5)		* And Strobe it

	bsr	BlitBob

Wait	andi.b	#64,$bfe001		* Test for mouse
	bne.s	Wait
		
	move.l	Gfxbase,a0
	move.l	38(a0),cop1lc(a5)		* Get old screen
	move.w	#$8e30,dmacon(a5)		* Restore DMA
	
	move.l	Gfxbase,a1
	movea.l	$4.w,a6
	jsr	-414(a6)			* CloseLibrary()
	jsr	-138(a6)			* Permit()
	moveq.l	#0,d0
QuickX	rts
	
	
	
BlitBob	lea	Bob,a0			
	lea	Screen1,a1
	addq	#2,a1			* Offset for centre of screen		
	
	moveq	#3,d0			* Number of planes to blit -1
Loopy	jsr	Blit			* By putting this line in a 
	dbra	d0,Loopy			* loop, we can call it 4 times
	rts				* (1 for each plane)
	
Blit	btst	#14,$dff002		* Test for BBusy
	bne.s	Blit
	move.l	a0,bltapt(a5)		* Get Bob from A0
	move.l	a1,bltdpt(a5)		* And screen from A1
	clr.w	bltamod(a5)		* No source Modulo
	move.w	#6,bltdmod(a5)		* Add 6 words to dest
	move.w	#$ffff,bltafwm(a5)	* No Masking
	move.w	#$ffff,bltalwm(a5)
	clr.w	bltcon1(a5)
	move.w	#%0000100111110000,bltcon0(a5)	* D=A
	move.w	#%0000111001010001,bltsize(a5)	* 272 x 57
	add.w	#1938,a0			* Access next bob plane
	add.w	#2280,a1			* Access next screen plane
	rts
	
	Section	Copper_List,code_c
		
Copper	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bplcon0,$0200
	dc.w	bpl1mod,$0000
	dc.w	bpl2mod,$0000
	
	dc.l	$6009fffe
	dc.w	bplcon0,$4200
	
	dc.w	bplpt+$00
Bh1	dc.w	$0000,bplpt+$02
Bh12	dc.w	$0000,bplpt+$04
Bh2	dc.w	$0000,bplpt+$06
Bh22	dc.w	$0000,bplpt+$08
Bh3	dc.w	$0000,bplpt+$0a
Bh32	dc.w	$0000,bplpt+$0c
Bh4	dc.w	$0000,bplpt+$0e
Bh42	dc.w	$0000

	dc.l	$01800000,$01820fff,$01840ed2,$01860fff
	dc.l	$01880b91,$018a0a81,$018c0960,$018e0850
	dc.l	$01900ff3,$01920741,$01940ca0,$0196068c
	dc.l	$01980356,$019a0960,$019c0850,$019e0ffa
	
	dc.l	$9909fffe
	dc.w	bplcon0,$0000

	dc.l	$fffffffe			* End cop list
		
	
Gfxbase	dc.l	0

Gfxname	dc.b	"graphics.library",0

Screen1	dcb.b	9120,0

Bob	incbin	source6:bitmaps/PE-Logo.Raw

