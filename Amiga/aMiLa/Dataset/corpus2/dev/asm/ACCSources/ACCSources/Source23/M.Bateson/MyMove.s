

** CODE		BOB_MOVE
** CODER	MARC.B, adapted by Marm.M!

; I have added code to handle x directional movement to this version.

; To do this I have altered the mouse reading routines very slightly, the
;blitter routine very slightly and the erase bob routine very slightly.

; I still think that hitting the hardware is a pain in the rear!

; Congratulations Marc! Writing code that's not that hard to follow aint easy. 

*****************************************
*	   SYSTEM OFFSETS		*
*****************************************

execbase	equ	4
openlibrary	equ	-408
closelibrary	equ	-414
allocmem	equ	-198
freemem		equ	-210
forbid		equ	-132
permit		equ	-138
copymem		equ	-624


*********************************
*	 CONSTANTS		*
*********************************

chip		equ	2
clear		equ	$10000
bob_size	equ	96*5
plane_size	equ	320/8*256

*********************************
*	INCLUDE FILES		*
*********************************

	include	source:include/hardware.i

	lea	$dff000,a5			;custom base address
	move.l	#0,JOYTEST(a5)


**********************************************************
*	OPEN GFX LIBRARY AND SAVE SYSTEM COPPER		 *
**********************************************************

	move.l	execbase,a6
	move.l	#gfxname,a1
	moveq	#0,d0
	jsr	openlibrary(a6)
	tst	d0			;check if o.k
	beq	the_end			;no then end
	move.l	d0,gfxbase		;save gfxbase
	move.l	d0,a0			;put gfxbase in a0 
	move.l	38(a0),systemcopper	;save the copper address 


****************************************************
*	ALLOCATE MEMORY FOR BIT PLANES		   *
****************************************************

; the 96 extra bytes added to the bit plane memory
; is to be used as an empty bob plane to erase the old
; bob before blitting it in its new position


	move.l	execbase,a6
	move.l	#plane_size*5+96,d0	;memory for 5 bitplanes
	move.l	#chip+clear,d1		;chip memory 
	jsr	allocmem(a6)
	tst	d0			;fail 
	beq	exit			;yep then exit
	move.l	d0,bitbase		;save  pointer
	add.l	#plane_size*5,d0	;find address of blank memory
	move.l	d0,bob_mask		;to use as bob eraser


*****************************************************************
*	LOAD BITPLANE  POINTERS INTO COPPER LIST  	        *
*****************************************************************

	move.l	bitbase,d0
	lea	copper,a0
	move.w	d0,6(a0)	;load bitplane pointers into c list
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#$2800,d0
	move.w	d0,14(a0)
	swap	d0
	move.w	d0,10(a0)
	swap d0
	add.l	#$2800,d0
	move.w	d0,22(a0)
	swap	d0
	move.w	d0,18(a0)
	swap d0
	add.l	#$2800,d0
	move.w	d0,30(a0)
	swap	d0
	move.w	d0,26(a0)
	swap d0
	add.l	#$2800,d0
	move.w	d0,38(a0)
	swap	d0
	move.w	d0,34(a0)
	clr.l	d0
	

***************************************************************
*		START CUSTOM COPPER LIST		      *
***************************************************************	

	move.l	#copper,COP1LCH(a5)
	move.l	#0,COPJMP1(a5)
	move.l	execbase,a6
	jsr	forbid(a6)
	
*************************************************************
*		    MAIN CODE LOOP    			    *
*************************************************************

	move.w	#100,x_pos		;load x position counter
	move.w	#100,y_pos		;load bob destination
	bsr	blitter			;100 lines down and 20 bytes in
wait
	move.l	VPOSR(a5),d0		;read current beam position
	and.l	#$0001ff00,d0		;mask all but the vertical pos
	lsr.l	#8,d0		
	cmp.w	#$0106,d0		;wait for end of display
	bne	wait
	btst	#6,CIAAPRA		;check left mouse button
	beq	clean_up		;end if pressed
	bsr	test_mouse_y
	bsr	test_mouse_x
	cmp.b	#1,bob_moved		;check movement flag
	beq	blitter_ops	
	bra	wait

blitter_ops
	bsr	erase_bob		;wipe old bob
	bsr	blitter			;blit new one
	clr.b	bob_moved		;clear flag
	bra	wait		


**********************************************************
*			RESTORE SYSTEM 			 *
**********************************************************

clean_up
	
	move.l	systemcopper,COP1LCH(a5)
	move.l	#0,COPJMP1(a5)
	move.l	execbase,a6
	jsr	permit(a6)
	move.l	execbase,a6		  
	move.l	execbase,a6		;free bitplane memory
	move.l	#plane_size*5+96,d0
	move.l	bitbase,a1
	jsr	freemem(a6)

exit
	move.l	gfxbase,a1		;close the graphics library
	move.l	execbase,a6
	jsr	closelibrary(a6)
	
the_end
	rts				;exit from program

**********************************************************
*			TEST MOUSE			 *
**********************************************************


test_mouse_y

	move.b	new_y,old_y
	move.w	JOY0DAT(a5),d1		;read mouse counter
	and.w	#$ff00,d1		;keep y count only
	lsr.w	#8,d1			;move into first byte
	move.b	d1,new_y		;save position
	sub.b	d1,old_y		;find direction
	beq	no_change		;mouse not moved
	bmi	down
	bpl	up

no_change
	rts

test_mouse_x

	move.b	new_x,old_x
	move.w	JOY0DAT(a5),d1		;read mouse counter
	and.w	#$00ff,d1		;keep x count only
	move.b	d1,new_x		;save position
	sub.b	d1,old_x		;find direction
	beq	no_change_x		;mouse not moved
	bmi	right
	bpl	left

no_change_x
	rts

****************************************
*		MOVE UP		       *
****************************************

up
	tst.w	y_pos
	beq	no_up
	move.b	#1,bob_moved		;set movement flag
	sub.w	#1,y_pos		;move up by 3 lines
	rts
no_up
	rts
	
****************************************
*		MOVE DOWN	       *
****************************************

down
	
	cmpi.w	#200,y_pos		;check for max down pos
	beq	no_down
	move.b	#1,bob_moved		;set move flag
	add.w	#1,y_pos		;move down 3 lines
	rts
no_down
	rts


***************************************
*		LEFT		      *
***************************************

left
	tst.w	x_pos			;reached side of screen
	beq	no_left
	sub.w	#1,x_pos		;decrement counter
	move.b	#1,bob_moved		;set moved flag	
	rts

no_left
	rts


***************************************
*		RIGHT		      *
***************************************

right
	cmp.w	#280,x_pos		;reached side of screen
	bge	no_right
	add.w	#1,x_pos		;increment counter
	move.b	#1,bob_moved		;set flag
	rts

no_right
	rts

************************************************************
*		BLITTER OPERATION			   *
************************************************************

blitter
	lea	bob,a2			;base address of bob
	

	move.l	#4,d7			number of planes
	move.l	bitbase,a3		;base address of screen	
	move.w		x_pos,d0	x pixel position of bob
	move.w		y_pos,d1	y pixel position of bob
	
	move.w		d0,oldx_pos	save this position
	move.w		d1,oldy_pos	for erase routine!

blitter1
	
; d0=X, d1=Y, a3->the start of bitmap

	mulu		#40,d1		Y times screen byte width
	ror.l		#4,d0		X divided by 16
	add.w		d0,d1		line offset + word offset
	add.w		d0,d1		
	add.l		d1,a3		add offset to bitbase
	rol.l		#4,d0		get scroll into d0
	move.l		#$9f000000,d1	minterm value ( shifted 4 left )
	or.b		d0,d1
	ror.l		#4,d1		add scroll to minterm
	move.l		d1,BLTCON0(a5)	set up blit

blitter_loop
	bsr 	blit_bob
	add.l	#96,a2			;find next bob plane
	add.l	#plane_size,a3		;find next screen plane
	dbra	d7,blitter_loop		;do 'till end
	rts

blit_bob
	bsr	blitter_busy		;check blitter status
	move.l	a2,BLTAPTH(a5)		;DMA a pointer (bob)
	move.l	a3,BLTDPTH(a5)		;DMA d pointer (screen)
	move.w	#-2,BLTAMOD(a5)		;no bob offset
	move.w	#40-6,BLTDMOD(a5)	;set screen offset
	move.w	#0,BLTCON1(a5)
	move.w	#$ffff,BLTAFWM(a5)	;no mask
	move.w	#$0000,BLTALWM(a5)	;no mask
	move.w	#$603,BLTSIZE(a5)	;start blitter
	rts

blitter_busy
	btst	#14,DMACONR(a5)		;blitter working ?
	bne	blitter_busy		;yes then wait......
	rts				;no GET ON WITH IT !!!


**********************************************
*		ERASE BOB		     *
**********************************************


erase_bob

	lea		nullbob,a2	;base address of bob eraser
	

	move.l		#4,d7		number of planes
	move.l		bitbase,a3	;base address of screen	
	
	move.w		oldx_pos,d0	save this position
	move.w		oldy_pos,d1	for erase routine!
	
	bsr		blitter1
	rts
	
; following bit is redundant now MM

erase_loop
	bsr 	blit_bob
	add.l	#plane_size,a3		;find next screen plane
	dbra	d7,erase_loop		;do 'till end
	rts


***********************************************************
*		   CUSTOM COPPER LIST			  *
***********************************************************


	SECTION		copper.list,CODE_C

copper
	dc.w	BPL1PTH,0000		;next 4 blank words
	dc.w	BPL1PTL,0000		;are where we load
	dc.w	BPL2PTH,0000		;the bitplane pointers
	dc.w	BPL2PTL,0000
	dc.w	BPL3PTH,0000
	dc.w	BPL3PTL,0000
	dc.w	BPL4PTH,0000
	dc.w	BPL4PTL,0000
	dc.w	BPL5PTH,0000
	dc.w	BPL5PTL,0000
	dc.w	SPR0PTH,0000
	dc.w	SPR0PTL,0000		;sprite 0 pointer
	dc.w	SPR1PTH,0000
	dc.w	SPR1PTL,0000		;sprite 1 pointer
	dc.w	SPR2PTH,0000
	dc.w	SPR2PTL,0000		;sprite 2 pointer
	dc.w	SPR3PTH,0000
	dc.w	SPR3PTL,0000		;sprite 3 pointer
	dc.w	SPR4PTH,0000
	dc.w	SPR4PTL,0000		;sprite 4 pointer
	dc.w	SPR5PTH,0000
	dc.w	SPR5PTL,0000		;sprite 5 pointer
	dc.w	SPR6PTH,0000
	dc.w	SPR6PTL,0000		;sprite 6 pointer
	dc.w	SPR7PTH,0000
	dc.w	SPR7PTL,0000		;sprite 7 pointer
	dc.l 	$2b01fffe		;wait for line 43
	dc.w	DIWSTRT,$2c81		;where we start displaying
	dc.w	DIWSTOP,$2cc1		;where we stop!
	dc.w	BPLCON0,$5200		;this is for Amiga 1000 owners
	dc.w	BPLCON2,$0024		
	dc.w	DDFSTRT,$0038		;where to start the horizontal display
	dc.w	DDFSTOP,$00d0		;and where we stop
	dc.w	BPLCON1,$0000
	dc.w	BPL1MOD,$0000		;not a scroller
	dc.w	BPL2MOD,$0000		;so these are blank

color_map
	dc.w	COLOR00,$0000		;background colour black
	dc.w	COLOR01,$0fff		;colour 1 
	dc.w	COLOR02,$0e00		;colour 2 
	dc.w	COLOR03,$00a1		;colour 3 
	dc.w	COLOR04,$0d80
	dc.w	COLOR05,$0c70
	dc.w	COLOR06,$0c71
	dc.w	COLOR07,$0b61
	dc.w	COLOR08,$0b62
	dc.w	COLOR09,$0a52
	dc.w	COLOR10,$0a52
	dc.w	COLOR11,$0000
	dc.w	COLOR12,$001d
	dc.w	COLOR13,$0f00
	dc.w	COLOR14,$0f32
	dc.w	COLOR15,$0f53
	dc.w	COLOR16,$0000
	dc.w	COLOR17,$0888
	dc.w	COLOR18,$06f8
	dc.w	COLOR19,$0fca
	dc.w	COLOR20,$0333
	dc.w	COLOR21,$0444
	dc.w	COLOR22,$0555
	dc.w	COLOR23,$0666
	dc.w	COLOR24,$0777
	dc.w	COLOR25,$0888
	dc.w	COLOR26,$0999
	dc.w	COLOR27,$0aaa
	dc.w	COLOR28,$0ccc
	dc.w	COLOR29,$0ddd
	dc.w	COLOR30,$0eee
	dc.w	COLOR31,$06f8
	
	
	dc.l	$fffffffe		;wait for the impossible
endcopper

copperlen	equ	endcopper-copper


	

	
************************************************************
*			VARIABLES	 		   *
************************************************************


gfxbase		dc.l 0
bitbase		dc.l 0
systemcopper	dc.l 0
bob_mask	dc.l 0
bob_dest	dc.l 0
bob_old		dc.l 0
new_x		dc.b 0
old_x		dc.b 0
new_y		dc.b 0
old_y		dc.b 0
bob_moved	dc.b 0
x_pos		dc.w 0
y_pos		dc.w 0
oldx_pos	dc.w 0
oldy_pos	dc.w 0
gfxname		dc.b 'graphics.library',0

bob	incbin 	graphics/alien.s

		even
nullbob		ds.b	4*40*4+6

end
	
