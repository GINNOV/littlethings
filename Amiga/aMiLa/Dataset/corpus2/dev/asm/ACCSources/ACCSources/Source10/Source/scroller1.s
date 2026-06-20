** CODE	: RAISTLINS FIRST SCROLLER
** AUTHOR : GUESS?
** TIME   : 2:20am
** COMMENT:
;	 At last! I've had loads of problems with this little demo. Fitstly
; I couldn't detect which way the piccy was going. Then I added to the piccy
; & when I came to re-convert it I unwittingly kept making it too small. A 
; note to beginners make sure your piccy is the correct size!! mine is 319x399
; but who cares? While the progie runs press right mouse button to pause & 
; left to quit. Can anyone help in fitting music?

	include	source10:include/hardware.i
	opt	c-
	section	woooo!,code_c
	
********************************************************************************
;		INITIALISATION
***********************************************************************************
	lea	$dff000,a5	;hardware offset in a5
	move.l	4,a6		;exec offset in a6
	jsr	forbid(a6)	;guess?
	lea	gfxname,a1	;gfx.lib to load
	moveq.l	#0,d0		;any version
	jsr	openlib(a6)	;open gfx lib
	tst.l	d0		;is is o.k.?
	beq	quit		;christ, whats up?
	move.l	d0,gfxbase	;save it quick! before it gets away

******************************************************************************
;			START
*********************************************************************************
	move.l	#picture,d0	;get address of gfx data
;plane1	
	move.w	d0,bpl1+2		;set-up pointers
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#400*40,d0	;get next plane
;plane2	
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#400*40,d0
;plane3	
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
	swap	d0
	add.l	#400*40,d0
;plane4
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
	swap	d0
	add.l	#400*40,d0
;plane5
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2
	swap	d0
	add.l	#400*40,d0	;get colour palette		

;----------------------------------------------------------------------------
*WON'T WORK. I'VE LOADED THE COLOURS MANUALY. THIS SAVE MEMORY!! BUT IS BORING!
;colour registers loading routine
*	lea	colours,a3	;get address of where colours r 2 go
*	move.w	d0,a4		;address of colours in a4
*	move.w	#$180,d0		;first colour register in d0
*	moveq.w	#31,d5		;No. of colours to load -1
*colloop
*	move.w	d0,(a3)+		;colour register in a3
*	move.w	(a4)+,(a3)+	;load colours into correct registers
*	addq.w	#2,d0		;get next colour register
*	dbra	d5,colloop	;keep going untill all colours are
*				;all in the correct registers
;-------------------------------------------------------------------------------


*****************************************************************************
;   LOAD COPPER PC. ACTIVATE OUR COPPER. DISABLE SPRITES. WAIT FOR LMB
******************************************************************************
;general start-up of DMA
spriteoff	cmpi.b	#200,$dff006	;wait for vbl
	bne	spriteoff		;this prevents mouse ptr corruption
	move.w	#$20,dmacon(a5)	;disable sprites
	move.l	#copperlist,cop1lch(a5)
	move.w	#0,copjmp1(a5)	;activate our copper list
mouse_wait
pause	btst	#$a,$dff016	;test right mouse button
	beq	pause		;pause (a loop)
	bsr	scroll		;do scroll
	btst	#6,$bfe001	;test mouse
	bne	mouse_wait	;pressed?
	beq	cleanup


**********************************************************************************
;		SCROLL
******************************************************************************
scroll
	cmpi.b	#200,$dff006	;wait vbl
	bne	scroll

	cmpi.w	#140,counter	;have we reached the top?
	beq	setd		;if so scroll down
	cmpi.w	#-1,counter	;have we reached the bottom?
	beq	setu		;if so scroll up

test	cmpi.b	#1,scrollf	;which way are we scrolling?
	beq	scrolldown	;down
scrollup
	add.w	#$1,counter	;increment counter
	add.w	#40,bpl1+2	;increment bitplanes
	add.w	#40,bpl2+2
	add.w	#40,bpl3+2
	add.w	#40,bpl4+2
	add.w	#40,bpl5+2
	rts			;return
scrolldown
	sub.w	#$1,counter	;decrement counter
	sub.w	#40,bpl1+2	;decrement bitplanes
	sub.w	#40,bpl2+2
	sub.w	#40,bpl3+2
	sub.w	#40,bpl4+2
	sub.w	#40,bpl5+2
	rts			;return

setd	move.b	#$1,scrollf	;set scroll flag
	move.w	#140,counter	;initialise counter for down
	bra	test		;carry on as usual
setu	move.b	#$0,scrollf	;clear scroll flag
	move.w	#-1,counter	;initialise counter for up
	bra	test		;carry on as usual

***********************************************************************************
;		CLEAN-UP & EXIT
******************************************************************************
cleanup	
	move.w	#$83e0,dmacon(a5)	;enable sprites
	move.l	gfxbase,a4	;gfxbase into a4
	move.l	startlist(a4),cop1lch(a5)	;insert system copper
	move.w	#0,copjmp1(a5)	;restore system copper list
	move.l	gfxbase,a1	;get gfx base
	jsr	closelib(a6)	;close the gfx.lib
	jsr	permit(a6)	;enable mutli-tasking
	move.w	#$0,counter	;these 2 lines r simply for us coders
	move.w	#$0,scrollf	;it means we dont have to keep 
;re-assembling. Try without them if u dont understand. Take out for lamer use!
quit	rts			;bye,bye!


******************************************************************************
;			COPPER LIST
******************************************************************************
copperlist
	dc.w	diwstrt,$2c81	;window start
	dc.w	diwstop,$2cc1	;window stop
	dc.w	ddfstrt,$38	;data fetch start
	dc.w	ddfstop,$d0	;data fetch stop
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0

*colours	ds.l	32			;space for colours

	dc.w	color00,$000,color01,$fff	;colours manualy loaded !!!
	dc.w	color02,$00f,color03,$01f,color04,$02f
	dc.w	color05,$03f,color06,$04f,color07,$05f
	dc.w	color08,$06f,color09,$07f,color10,$08f
	dc.w	color11,$09f,color12,$0af,color13,$fd0
	dc.w	color14,$f00,color15,$800,color16,$008
	dc.w	color17,$0b0,color18,$b52,color19,$fca
	dc.w	color20,$000,color21,$444,color22,$555
	dc.w	color23,$666,color24,$777,color25,$888
	dc.w	color26,$999,color27,$aa0,color28,$ccc
	dc.w	color29,$ddd,color30,$eed,color31,$fff

bph1	dc.w	bpl1pth,$0	;These are the bitplane pointers
bpl1	dc.w	bpl1ptl,$0	;Hearwig, is there any advantage
bph2	dc.w	bpl2pth,$0	;setting up the pointers your way
bpl2	dc.w	bpl2ptl,$0	;i.e. instead of unsing bpl+2
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0
bph5	dc.w	bpl5pth,$0
bpl5	dc.w	bpl5ptl,$0

end	dc.w	$ffff,$fffe	;wait for the impossibe?


;program variables			;eee where would we be without these?

forbid	equ	-132
permit	equ	-138
openlib	equ	-408
closelib	equ	-414
startlist	equ	38

gfxname	dc.b	'graphics.library',0
	even
gfxbase	ds.l	1
	even
scrollf	dc.b	$0		;reserve memory for scroll flag
counter	dc.w	$0		;reserve memory for counter
	even
picture	incbin	'df1:bitmaps/megapic.p'	;call raw graphics from disk!
