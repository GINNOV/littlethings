** CODE   : Raistlins magic
** AUTHOR : Raistlin
** SIZE   : 31415 bytes (including piccy)
** NOTES  :
;	 This program loads a 4 bitplane piccy (raw format), then sets up
; a star field in the top part of the screen reusing 1 sprite channel.
; The interupt gives smooth scrolling (1/50th of a second). However this
; is not the correct way to use interupts!    
; This prog is for those that cant get to grips with ints

init	SECTION	piccyview,code_c
	include	source10:include/hardware.i	;get custom chip offsets
	opt	c-		;Any case, not fussy!	
	lea	$dff000,a5	;start of hardware
	move.l	4,a6		;exec base
	jsr	-132(a6)		;forbid
	move.l	#$0,$3000		;dummy sprite data


;Setup-sprite
	move.l	#sprite,d0	;Address of sprite data in d0
	swap	d0		;Get high word
	move.w	d0,sprh		;Load it into spr0pth
	swap	d0		;Get low word
	move.w	d0,sprl		;Load it into spr0ptl

********************************************************************************
;			Set-up bitplanes
*****************************************************************************
	move.l	#picture,d0	;get graphics from disk
plane1
	move.w	d0,pl1l		;Load first plane/low pointer
	swap	d0
	move.w	d0,pl1h		;High pointer
	swap	d0
	add.l	#$2800,d0		;Get to next plane
plane2
	move.w	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap	d0
	add.l	#$2800,d0		;Get to next plane
plane3
	move.w	d0,pl3l	
	swap	d0
	move.w	d0,pl3h
	swap	d0
	add.l	#$2800,d0		;Get to COLOUR PALETTE

******************************************************************************
;		Get colours from disk
****************************************************************************
;Colour platte
	lea	colours,a3		
	move.l	d0,a4		;D0 points to colout table
	move.w	#$180,d0		;colour register 00
	moveq.l	#7,d5		;15 colours/ excluding $180 to load
colloop				;colour loop	
	move.w	d0,(a3)+		;Move first colour in & increment pointer
	move.w	(a4)+,(a3)+	;And repeat for all colours
	addq.l	#2,d0		;By adding 2 to all registers- 2 = 1 word
	dbra	d5,colloop	;Exit loop when done

	move.w	#$0fff,color17(a5)	;Stars are white, arent they?

****************************************************************************
;	This section does the businees (oo-er)
*******************************************************************************
	lea	Gfxname,a1	;Get library name
	moveq	#0,d0		;Any version
	jsr	-408(a6)		;open the library
	tst.l	d0		;Was it okay?
	beq	quit		;If not - fast exit
	move.l	d0,a1		;Save GFX base address
	move.l	38(a1),old	;Save old copper address
	move.l	4,a6		;Get EXEC base
	jsr	-414(a6)		;Close graphics lib
	move.w	#$8020,dmacon(a5)	;Enable sprites
	move.l	#Copperlist,cop1lch(a5)	;Insert new copper data	

*****************************************************************************
;	SET-UP INTERUPT TO SCROLL & WAIT FOR LMB
******************************************************************************
;initialize interupts
	move.l	$6c,oldint+2	;save old interupt
	move.l	#newint,$6c	;insert mine
	jmp	wait		;continue with program
newint	
	movem.l	a0-a6/d0-d7,-(sp)	;save registers
	jsr	scroll		;interupt scroll
	movem.l	(sp)+,a0-a6/d0-d7	;bring back registers
oldint	jmp	$0		;run old interupt!	


;---------------------------------------------------------------------------------
;mouse wait
wait
	btst	#6,$bfe001
	bne	wait		;Wait for mouse

*******************************************************************************
;		CLEAN-UP
******************************************************************************
;clean up
	move.l	oldint+2,$6c	;restore old interupt
	move.l	old,cop1lch(a5)	;Restore old copper
	move.w	#$83e0,dmacon(a5)	;Restore DMA
Quit	move.l	4,a6
	jsr	-138(a6)		;Restore multi-tasking
	rts			;end

****************************************************************************
;		Scroll the stars
****************************************************************************
scroll
	move.w	#7,d2		;7 lots of stars to scroll
	move.l	#sprite,a0	;get address of sprite data 
doit	addq.b	#$1,1(a0)		;add 1 to get 1st plane
	addq.b	#$2,9(a0)		;add 2 to get 2nd plane
	addq.b	#$3,17(a0)	;add 3 to get 3rd plane
	add.l	#24,a0		;add 24 to get to next set of stars
	sub	#1,d2		;are we finished
	bne	doit		;no!
	rts			;return to main

****************************************************************************
;		Copper list data
****************************************************************************
Copperlist
	dc.w	diwstrt,$2c81	;Top left of screen
	dc.w	diwstop,$2cc1	;Bottom right of screen
	dc.w	ddfstrt,$38	;Data fetch start
	dc.w	ddfstop,$d0	;Data fetch stop
	dc.w	bplcon0,%0011001000000000
;		         5432109876543210
	dc.w	bplcon1,0		;No horizontal offset
	dc.w	color01,$fff	
Colours	ds.w	16		;Space for 16 colour registers
	dc.w	bpl1pth		;plane pointers
pl1h	dc.w	0,bpl1ptl
pl1l	dc.w	0,bpl2pth
pl2h	dc.w	0,bpl2ptl
pl2l	dc.w	0,bpl3pth
pl3h	dc.w	0,bpl3ptl
pl3l	dc.w	0

	dc.w	spr0pth
sprh	dc.w	0,spr0ptl
sprl	dc.w	0

	dc.w	spr1pth,$0003
	dc.w	spr1ptl,$0000
	dc.w	spr2pth,$0003
	dc.w	spr2ptl,$0000
	dc.w	spr3pth,$0003
	dc.w	spr3ptl,$0000
	dc.w	spr4pth,$0003
	dc.w	spr4ptl,$0000
	dc.w	spr5pth,$0003
	dc.w	spr5ptl,$0000
	dc.w	spr6pth,$0003
	dc.w	spr6ptl,$0000
	dc.w	spr7pth,$0003
	dc.w	spr7ptl,$0000

	dc.w	$ffff,$fffe	;End of copper list

**************************************************************************
;		Sprite data
***************************************************************************

;The sprite data is taken from ?s source

SPRITE:   dc.w      $307A,$3100,$1000,$0000,$32C0,$3300,$1000,$0000
          dc.w      $3442,$3500,$1000,$0000,$36A2,$3700,$1000,$0000			
          dc.w      $38DA,$3900,$1000,$0000,$3A5A,$3B00,$1000,$0000
          dc.w      $3CC5,$3D00,$1000,$0000,$3EB8,$3F00,$1000,$0000
          dc.w      $5082,$5100,$1000,$0000,$52D0,$5300,$1000,$0000
          dc.w      $547A,$5500,$1000,$0000,$56C0,$5700,$1000,$0000
	dc.w      $5842,$5900,$1000,$0000,$5AA2,$5B00,$1000,$0000
	dc.w      $5CDA,$5D00,$1000,$0000,$5E5A,$5F00,$1000,$0000
	dc.w      $60C5,$6100,$1000,$0000,$62B8,$6300,$1000,$0000
	dc.w      $6482,$6500,$1000,$0000,$66D0,$6700,$1000,$0000
          dc.w      $687A,$6900,$1000,$0000
SPRITEE:  dc.w      $0000,$0000
	

;program variables		

old	dc.l	0		;Storage point
picture	incbin	"source10:bitmaps/pic"	;Calls the raw data from disk
Gfxname	dc.b	'graphics.library',0
