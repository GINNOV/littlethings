****************************************************************************
*** CODE    : OPTIONS SCREEN
*** AUTHOR  : RAISTLIN
*** DATE    : 5.4.91
*** NOTES   :
;	     
;	     
****************************************************************************

	include	source:include/hardware.i	;Get dem hardware equates
	opt	c-			;Any case
	section	options,code		;Public memory for now

	lea	$dff000,a5		;A5 = hardware offset

	move.l	4,a6			;EXEC base
	jsr	-132(a6)		;Forbid!
	lea	gfxname,a1		;Name of lib in a1
	moveq.l	#0,d0			;Any version
	jsr	-552(a6)		;Open 
	tst.l	d0			;Is everything o.k.?
	beq	quit			;If not get out quick!
	move.l	d0,gfxbase		;else save dat address

***Set-Up Playfields		
	move.l	#picture,d0		;Address of picy in d0
	move.w	d0,bpl1+2		;And load dem ptrs
	swap	d0			
	move.w	d0,bph1+2

***Set-Up Hardware
	move.w	#$20,dmacon(a5)		;Sod-off sprites!
	move.l	#copperlist,cop1lch(a5)	;Insert my cop list
	move.w	#0,copjmp1(a5)		;And run it

Main
	move.b	$bfec01,d0		;Address to get fkey status
	not	d0			;Invert
	ror.b	#1,d0			
	cmpi.b	#$50,d0			;Is it F1?
	beq	F1
	cmpi.b	#$51,d0			;F2?
	beq	F2
	cmpi.b	#$52,d0			;F3?
	beq	F3
	btst	#6,$bfe001		;Test LMB
	bne	main			
	bra	clean_up		;Exit if pressed

F1	
	cmpi.b	#1,d5			;Which icon is showing now?
	beq	F1On
	move.b	#1,d5			;Set status (On or Off)
	move.l	#40*102,d4		;Offset of screen pos to place
	move.l	#bob1,bob		;Bob to be writen to screen (on or off)
	bra	blitter			;And blit it
F1On	move.b	#0,d5			;Set status
	move.l	#40*102,d4		;Offset
	move.l	#bob2,bob		;Address of bob (off) in bob
	bra	blitter			;Blit

F2
	cmpi.b	#1,d6			;See above
	beq	F2On
	move.b	#1,d6
	move.l	#40*114,d4
	move.l	#bob1,bob
	bra	blitter
F2On	move.b	#0,d6
	move.l	#40*114,d4
	move.l	#bob2,bob
	bra	blitter

F3
	cmpi.b	#1,d7			;See above
	beq	F3On
	move.b	#1,d7
	move.l	#40*126,d4
	move.l	#bob1,bob
	bra	blitter
F3On	move.b	#0,d7
	move.l	#40*126,d4
	move.l	#bob2,bob
	bra	blitter
	

***************************************************************************
;			BLITTER
***************************************************************************
Blitter
	cmpi.b	#200,$dff006		;test VBL
	bne	blitter			
	lea	picture,a0		;Address of screen in a0
	add.l	d4,a0			;Add offset
	add.l	#34,a0			;blitting on right of screen
	move.l	bob,bltapth(a5)		;Source is bob
	move.l	a0,bltdpth(a5)		;Destination is screen
	move.w	#0,bltamod(a5)		;No A modulo
	move.w	#36,bltdmod(a5)		;36 D modulo
	move.w	#$ffff,bltafwm(a5)	;No mask
	move.w	#$ffff,bltalwm(a5)	;No mask
	move.w	#%0000100111110000,bltcon0(a5)
	move.w	#%1011000010,bltsize(a5)
	bra	pause			;Do a pause

Pause
	move.b	#140,d3			;140 pause wait
Ploop
	dbra	d3,ploop		;Delete pause counter
	bra	main			;And continue
	

Clean_up		
	move.w	#$8e30,dmacon(a5)	;Re-enable sprites
	move.l	gfxbase,a1		
	move.l	38(a1),cop1lch(a5)	;Restore sys copper
	move.w	#$0,copjmp1(a5)		;Run it
	move.l	4,a6			;EXEC
	jsr	-138(a6)		;Permit
	move.l	gfxbase,a1	
	jsr	-414(a6)		;Close gfx lib
	move.l	#0,d0			;Keep CLI happy
quit	rts				;Bye!


***************************************************************************
;			COPPER LIST
***************************************************************************
	section	copper,code_c		;Chip mem please!
copperlist
	dc.w	diwstrt,$2c81		;Dreary stuff!
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0001001000000000
	dc.w	bplcon1,$0

	dc.w	color00,$04e		;Pritty colours!
	dc.w	color01,$fff

bph1	dc.w	bpl1pth,$0		;Boring!
bpl1	dc.w	bpl1ptl,$0

	dc.w	$ffff,$fffe		;Eternity is spent looking for this!


;Program Variables
gfxname	dc.b	'graphics.library',0	;what library is it?
	even
gfxbase	ds.l	1			;And its address is?
	
bob	ds.l	1			;The bob lives at?
	
bob1	incbin	source:bitmaps/On		;Where do I find on?
	even
bob2	incbin	source:bitmaps/off		;Where do I find off?
	even
picture	incbin	source:bitmaps/trainer	;The actual screen data
