******************************************************************************
**  CODE	 :DRAGONS BORN					          ****
**  CREDITS	 :CODED BY RAISTLIN, GFX BY NOTMAN, SCROLLER BY TREEEBEARD****
**  NOTES	 :This intro MUS be the first thing you run!!             ****
******************************************************************************

	include	source:include/hardware.i		;Get hardware names
	incdir	source:bitmaps/
	opt	c-			;Any case

	lea	$dff000,a5		;a5 is hardware base

	move.l	4,a6			;EXEC base
	jsr	-132(a6)		;Forbid!!
	lea	gfxname,a1		;we're use gfx.lib
	moveq.l	#0,d0			;any version
	jsr	-408(a6)		;And OPEN!!
	tst.l	d0			;dit it open?
	beq	quit			;no
	move.l	d0,gfxbase		;save gfx base address

*************************************************************************
;			DO THE INTRO 
*************************************************************************
;set-up picture
	move.l	#dragon,d0		;Address of intro grafix
;bitplane1
	move.w	d0,bp1l+2		;Load bitplane pointers
	swap	d0
	move.w	d0,bp1h+2
	swap	d0
	add.l	#40*256,d0		;Size of bitplanes
;bitplane2
	move.w	d0,bp2l+2
	swap	d0
	move.w	d0,bp2h+2
	swap	d0
	add.l	#40*256,d0
;bitplane3
	move.w	d0,bp3l+2
	swap	d0
	move.w	d0,bp3h+2
	swap	d0
	add.l	#40*256,d0
;bitplane4
	move.w	d0,bp4l+2
	swap	d0
	move.w	d0,bp4h+2
	swap	d0
	add.l	#40*256,d0
;bitplane5
	move.w	d0,bp5l+2
	swap	d0
	move.w	d0,bp5h+2
	move.l	#copper2,cop1lch(a5)	;Load copper
	clr.w	copjmp1(a5)		;Run copper list

**********************
* Sample Player V1.0 *
* Sample In A0	     *
* Length (Bytes) D0  *
**********************

	move.l	#sample3,a0		;address of sample
	move.w	#17758,d0
	move.w	#1100,d3

PlaySample:
	move.w	#$80,$dff09c
	lsr.w	#1,d0
	move.w	d0,$dff0a4
	move.l	a0,$dff0a0
	move.w	d3,$dff0a6			;Frequency
	move.w	#$40,$dff0a8			;Volume
	move.w	#$8001,$dff096
IRQ_Wait1:
	move.w	$dff01e,d0
	btst	#7,d0
	beq	IRQ_Wait1
	move.w	#$0080,$dff09c
IRQ_Wait2:
	move.w	$dff01e,d0
	btst	#7,d0
	beq	IRQ_Wait2
	move.w	#$0080,$dff09c
	move.w	#$01,$dff096

	move.w	#800,d0				;Amount of time to wait
pause	cmpi.b	#200,$dff006			;Wait vbl
	bne	pause
	dbra	d0,pause

*************************************************************************
;		SET-UP THE PLAYFIELD
*************************************************************************
*Set-up blank in top quarter of screen
	move.l	#screen,d0		;Get address of screen
;biplane 1
	move.w	d0,bpl1+2		;This section
	swap	d0			;sets-up the
	move.w	d0,bph1+2		;bitplane	
	swap	d0			;pointers to the
	add.l	#40*163,d0		;blank screen 
;bitplane 2				;at the top
	move.w	d0,bpl2+2	
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#40*163,d0
;bitplane 3
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
	swap	d0
	add.l	#40*163,d0		;Plane size = 40x163
;bitplane 4
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
	swap	d0
	add.l	#40*163,d0
;bitplane 5
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2

*Set-up logo in bottom quarter of screen
	move.l	#logo1,d0		;Get address of logo piccy
;bitplane 1
	move.w	d0,bpl6+2		;This section
	swap	d0			;sets-up the
	move.w	d0,bph6+2		;bitplane
	swap	d0			;pointers to the
	add.l	#40*93,d0		;logo screen at 
;bitplane 2				;the bottom
	move.w	d0,bpl7+2
	swap	d0
	move.w	d0,bph7+2
	swap	d0
	add.l	#40*93,d0
;bitplane 3
	move.w	d0,bpl8+2
	swap	d0
	move.w	d0,bph8+2
	swap	d0
	add.l	#40*93,d0		;plane size = 40x93
;bitplane 4
	move.w	d0,bpl9+2
	swap	d0
	move.w	d0,bph9+2

**SET-UP SPRITE POINTERS
;sprite ptr 1
	move.l	#sprite,d0
	move.w	d0,spl0+2
	swap	d0
	move.w	d0,sph0+2
;sprite ptr 2
	move.l	#A,d0			;get address of A
	move.w	d0,spl1+2
	swap	d0
	move.w	d0,sph1+2
;sprite ptr 3
	move.l	#C,d0			;get address of 1st C
	move.w	d0,spl2+2
	swap	d0
	move.w	d0,sph2+2
;sprite ptr 4	
	move.l	#CC,d0			;get address of 2nd C
	move.w	d0,spl3+2
	swap	d0
	move.w	d0,sph3+2
;sprite ptr 5	
	move.l	#marvin1,d0		;& finally set-up Marvin
	move.w	d0,spl4+2
	swap	d0
	move.w	d0,sph4+2
;sprite ptr 6
	move.l	#marvin2,d0	
	move.w	d0,spl5+2
	swap	d0	
	move.w	d0,sph5+2
;sprite ptr 7
	move.l	#marvin3,d0	
	move.w	d0,spl6+2
	swap	d0
	move.w	d0,sph6+2
;sprite ptr 8
	move.l	#marvin4,d0	
	move.w	d0,spl7+2
	swap	d0
	move.w	d0,sph7+2

	
**************************************************************************
;		SET-UP INTERRUPTS & LOAD COPPER
**************************************************************************
	move.l	#copperlist,cop1lch(a5)
	move.w	#$0,copjmp1(a5)		;And activate my coppy instrs
	move.w	#$8e30,dmacon(a5)
	move.l	#mytext,tadd
	move.l	#letters,presadd
	move.b	#7,presbit	
	jsr	_init			;Initiate music

	clr.l	d1			;D1 = Piccy counter

**Interrupt
	move.l	$6c,oldint+2		;Save old interrupt
	move.l	#newint,$6c		;Inset mine
	jmp	continue		;next part aint for you!!
Newint
	movem.l	a0-a6/d0-d7,-(sp)	;save all registers
	jsr	_music			;play music
	jsr	scrollacc		;move ACC up & down
	jsr	do_scroll		;Scroll stars
	jsr	movemarvin
	btst	#$a,$dff016		;test for RMB
	beq	pauseT			;If pressed pause text
	jsr	scroll_text		;scroll text
pauseT	jsr	copperbar		;Scroll the copper bar
	move.b	#1,vbl			;set vbl flag
	movem.l	(sp)+,a0-a6/d0-d7	;Bring back d registers
oldint	jmp	$0			;Keep 68000 happy!!

**End of Interrupt

**************************************************************************
;			MAIN
**************************************************************************
continue	move.w	#200,d0		;Pause length for piccy
main
	cmpi.b	#1,vbl			;test for VBL
	bne	main			;Wait vbl
	move.b	#0,vbl
	bsr	change_piccy?		;Is it time to change piccy?
	bsr	BOB			;blit bobs
	btst	#6,$bfe001
	bne	main			;LMB pressed??
	beq	clean_up		;This guys fed-up!!
change_piccy?
	cmpi.w	#$0,d0			;Is pause over?
	beq	pause_over		;if so do piccy change
	sub.w	#1,d0			;Reduce pause
	rts				;Back to main proggy
pause_over
	move.w	#200,d0			;Restart pause
	cmpi.b	#0,d1			;Are we showing Raistlin?
	beq	Notman			;If so show notman
	cmpi.b	#1,d1			;Are we showing Notman?
	beq	Caramon			;If so show caramon
	cmpi.b	#2,d1			;Are we showing Caramon?
	beq	Marvin			;If so show Marvin
	bra	Raistlin		;We're showing Marv, do Raist

************************************************************************
;		FADE RAISTLIN OUT & FADE NOTMAN IN
************************************************************************
NOTMAN
 	move.l	#logo2,d7		;get address of notman piccy
	move.w	d7,bpl6+2		;And load
	swap	d7			;the correct
	move.w	d7,bph6+2		;bitplane registers
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl7+2
	swap	d7
	move.w	d7,bph7+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl8+2
	swap	d7
	move.w	d7,bph8+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl9+2
	swap	d7
	move.w	d7,bph9+2
	move.b	#1,d1

	move.w	#$000,c1+2		;Load colour registers
	move.w	#$f00,c2+2		;with correct
	move.w	#$f80,c3+2		;colours for
	move.w	#$f50,c4+2		;Notman
	move.w	#$fff,c5+2
	move.w	#$ffe,c6+2
	move.w	#$fec,c7+2
	move.w	#$feb,c8+2
	move.w	#$fea,c9+2
	move.w	#$fd8,c10+2
	move.w	#$fc7,c11+2
	move.w	#$fc6,c12+2
	move.w	#$fb4,c13+2
	move.w	#$fb3,c14+2
	move.w	#$fa1,c15+2
	move.w	#$fa0,c16+2
	bra	main
***************************************************************************
;		FADE NOTMAN OUT & CARAMON IN
***************************************************************************
CARAMON
 	move.l	#logo3,d7		;See notmans explanation
	move.w	d7,bpl6+2
	swap	d7
	move.w	d7,bph6+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl7+2
	swap	d7
	move.w	d7,bph7+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl8+2
	swap	d7
	move.w	d7,bph8+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl9+2
	swap	d7
	move.w	d7,bph9+2
	move.b	#2,d1

	move.w	#$000,c1+2
	move.w	#$f00,c2+2
	move.w	#$fff,c3+2
	move.w	#$222,c4+2
	move.w	#$444,c5+2
	move.w	#$666,c6+2
	move.w	#$888,c7+2
	move.w	#$aaa,c8+2
	move.w	#$fb3,c9+2
	move.w	#$fa3,c10+2
	move.w	#$f92,c11+2
	move.w	#$f82,c12+2
	move.w	#$f71,c13+2
	move.w	#$f61,c14+2
	move.w	#$f40,c15+2
	move.w	#$f30,c16+2

	bra	main
	
***************************************************************************
;		FADE CARAMON OUT & MARVIN IN
***************************************************************************
MARVIN
 	move.l	#logo4,d7		;see notmans explanation
	move.w	d7,bpl6+2
	swap	d7
	move.w	d7,bph6+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl7+2
	swap	d7
	move.w	d7,bph7+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl8+2
	swap	d7
	move.w	d7,bph8+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl9+2
	swap	d7
	move.w	d7,bph9+2
	move.b	#3,d1

	move.w	#$000,c1+2
	move.w	#$777,c2+2
	move.w	#$fff,c3+2
	move.w	#$f60,c4+2
	move.w	#$fff,c5+2
	move.w	#$ff1,c6+2
	move.w	#$00f,c7+2
	move.w	#$2cd,c8+2
	move.w	#$fff,c9+2
	move.w	#$ddd,c10+2
	move.w	#$ccc,c11+2
	move.w	#$aaa,c12+2
	move.w	#$999,c13+2
	move.w	#$777,c14+2
	move.w	#$655,c15+2
	move.w	#$444,c16+2
	bra	main

***************************************************************************
;		FADE MARVIN OUT & CARAMON IN
***************************************************************************
RAISTLIN
 	move.l	#logo1,d7		;see notmans explanation
	move.w	d7,bpl6+2
	swap	d7
	move.w	d7,bph6+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl7+2
	swap	d7
	move.w	d7,bph7+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl8+2
	swap	d7
	move.w	d7,bph8+2
	swap	d7
	add.l	#40*93,d7
	move.w	d7,bpl9+2
	swap	d7
	move.w	d7,bph9+2
	move.b	#0,d1

	move.w	#$000,c1+2
	move.w	#$300,c2+2
	move.w	#$111,c3+2
	move.w	#$044,c4+2
	move.w	#$066,c5+2
	move.w	#$fff,c6+2
	move.w	#$a40,c7+2
	move.w	#$189,c8+2
	move.w	#$d63,c9+2
	move.w	#$98a,c10+2
	move.w	#$f96,c11+2
	move.w	#$bac,c12+2
	move.w	#$7cf,c13+2
	move.w	#$fb9,c14+2
	move.w	#$ace,c15+2
	move.w	#$dcf,c16+2
	bra	main

**************************************************************************
;		BOBS
**************************************************************************
bob	jsr	scrollrbob		;Scroll raist bob
**Do Raistlin BOB
	move.w	#116,a0			;A0 = size of a bob plane
	move.l	#raistbob,d5		;address of bob in d5
	moveq.w	#4,d7			;5 bitplanes -1
	move.l	#screen+817,d6		;address of screen in d6
	add.w	destr,d6		;move bob up/down
	move.w	#%0000100111110000,a1
	move.w	#%11101000010,bobs	;bob size = 29 x 32 (2 words)
	jsr	blitter			;do blit
**Do Notman BOB
	move.w	#124,a0			;A0 = size of bob plane
	move.l	#notbob,d5		;address of bob in d5
	moveq.w	#4,d7			;5 bitplanes -1
	move.l	#screen+2632,d6		;address of screen in d6
	add.w	destn,d6		;Move bob up/down
	move.w	#%0000100111110000,a1
	move.w	#%11111000010,bobs 	;bob size = 31 x 32 
	jsr	blitter			;do blit
**Do Caramon BOB
	move.w	#116,a0			;A0 = size of bob plane
	move.l	#carabob,d5		;address of bob in d5
	moveq.w	#4,d7			;5 bitplanes -1
	move.l	#screen+1825,d6		;address of screen + offset in d6
	add.w	destc,d6		;Move bob up/down
	move.w	#%0000100111110000,a1
	move.w	#%11101000010,bobs	;bob size = 29 x 32 (2 words)
	jsr	blitter			;do blit
	rts				;Return to main routine
*****************************************************************************
;		SCROLL RAISTLIN UP OR DOWN?
*****************************************************************************

scrollrbob
	cmpi.w	#0,destr		;At top?
	beq	down
	cmpi.w	#2480,destr		;At bottom?
	beq	up
bobmove
	cmpi.b	#1,destrf		;Up or down?
	beq	bdown			;down!
	sub.w	#40,destr		;UP!!
	bra	scrollnbob		;Back to main interrupt
bdown	add.w	#40,destr
	bra	scrollnbob		;Back to main interrupt
down	move.b	#1,destrf		;Set scroll flag to dwon
	bra	bobmove
up	move.b	#0,destrf		;Set scroll flag to up
	bra 	bobmove

***************************************************************************
;		SCROLL NOTMAN UP OR DOWN?
***************************************************************************
scrollnbob
	cmpi.w	#-1800,destn		;At top?
	beq	ndown
	cmpi.w	#680,destn		;At bottom?
	beq	nup
nbobmove
	cmpi.b	#1,destnf		;Up or down?
	beq	nbdown			;down!
	sub.w	#40,destn		;UP!!
	bra	scrollcbob		;Back to main interrupt
nbdown	add.w	#40,destn
	bra	scrollcbob		;Back to main interrupt
ndown	move.b	#1,destnf		;Set scroll flag to dwon
	bra	nbobmove
nup	move.b	#0,destnf		;Set scroll flag to up
	bra 	nbobmove

***************************************************************************
;		SCROLL CARAMON UP OR DOWN?
***************************************************************************
scrollcbob
	cmpi.w	#-1000,destc		;At top?
	beq	downc
	cmpi.w	#1480,destc		;At bottom?
	beq	upc
cbobmove
	cmpi.b	#1,destcf		;Up or down?
	beq	cbdown			;down!
	sub.w	#40,destc		;UP!!
	rts				;Back to main interrupt
cbdown	add.w	#40,destc
	rts
downc	move.b	#1,destcf		;Set scroll flag to dwon
	bra	cbobmove
upc	move.b	#0,destcf		;Set scroll flag to up
	bra 	cbobmove

***************************************************************************
;		BLITTER!! (I 8 this chip)
***************************************************************************
BLITTER
	jsr	boby			;do current bobplane
	dbra	d7,blitter		;decrease bitplane
	rts				;end of blit

boby	btst	#14,dmaconr(a5)		;is blitter busy?
	bne	boby			;Lazy git!!
	move.l	d5,bltapth(a5)		;d5 = blit source
	move.l	d6,bltdpth(a5)		;d6 = blit destination
	clr.w	bltamod(a5)		;no source modulo
	move.w	#36,bltdmod(a5)		;36 D modulo
	move.w	#$ffff,bltafwm(a5)	;no mask
	move.w	#$ffff,bltalwm(a5)	;no mask
	move.w	a1,bltcon0(a5)		;Why use a1? not needed!!
	move.w	#$0,bltcon1(a5)		;unused
	move.w	bobs,bltsize(a5)	;Blitter size = 32*??
	add.l	#40*163,d6		;Get to next screen plane
	add.l	a0,d5			;Get to next bob plane
	rts				;BLIT OVER
	

****************************************************************************
;		Scroll the stars
****************************************************************************
do_scroll
	moveq.w	#$e,d2			;counter
	move.l	#sprite,a0		;address of stars
doit	addq.b	#$1,1(a0)		;first star plane to scroll
	addq.b	#$2,9(a0)		;scroll 2nd star plane
	addq.b	#$3,17(a0)		;scroll 3rd star plane
	add.l	#24,a0			;get to next set of stars
	sub	#1,d2			;decrement counter
	bne	doit			;keep scrolling stars
	rts				;finished scrolling stars

****************************************************************************
;		SCROLL 'ACC' UP & DOWN
****************************************************************************
scrollacc
	lea	a,a3			;get address of A sprite
	cmpi.b	#$36,(a3)		;Is sprite at top?
	beq	ACCCdown
	cmpi.b	#$81,(a3)		;Is sprite at bottom?
	beq	ACCCup
ACC1	cmpi.b	#1,scrollfa		;scroll which way?
	beq	accdown
accup	sub.b	#1,(a3)
	sub.b	#1,2(a3)		;correct VSTOP
	bra	ACC2
accdown	add.b	#1,(a3)
	add.b	#1,2(a3)		;correct VSTOP
	bra	ACC2
ACCCDOWN
	move.b	#1,scrollfa
	bra	acc1
acccup	move.b	#0,scrollfa
	bra	acc1

ACC2
	lea	c,a3
	cmpi.b	#$36,(a3)		;Is sprite at top?
	beq	ACCCdown2
	cmpi.b	#$81,(a3)		;Is sprite at bottom?
	beq	ACCCup2
ACC3	cmpi.b	#1,scrollfc		;scroll which way?
	beq	accdown2
accup2	sub.b	#1,(a3)
	sub.b	#1,2(a3)		;correct VSTOP
	bra	acc4
accdown2	
	add.b	#1,(a3)
	add.b	#1,2(a3)		;correct VSTOP
	bra	acc4
ACCCDOWN2	
	move.b	#1,scrollfc
	bra	acc3
acccup2	
	move.b	#0,scrollfc
	bra	acc3


ACC4
	lea	cc,a3
	cmpi.b	#$36,(a3)		;Is sprite at top?
	beq	ACCCdown3
	cmpi.b	#$81,(a3)		;Is sprite at bottom?
	beq	ACCCup3
ACC5	cmpi.b	#1,scrollfcc		;scroll which way?
	beq	accdown3
accup3	sub.b	#1,(a3)
	sub.b	#1,2(a3)		;correct VSTOP
	rts
accdown3	add.b	#1,(a3)
	add.b	#1,2(a3)		;correct VSTOP
	rts
ACCCDOWN3	move.b	#1,scrollfcc
	bra	acc5
acccup3	move.b	#0,scrollfcc
	bra	acc5

**************************************************************************
;			MOVE MARVIN
**************************************************************************
movemarvin
	move.w	marvin1,d4		;Put marvs control word in d0
	and.w	#$ff00,d4		;Mask out horizontal data
	cmpi.w	#$b600,d4		;at top?
	beq	marvdown		
	cmpi.w	#$de00,d4
	beq	marvupy
marv	cmpi.b	#$0,marvf		;Which way
	beq	marvup
	sub.b	#1,marvin1
	sub.b	#1,marvin1+2		;Make marvin move up
	sub.b	#1,marvin2
	sub.b	#1,marvin2+2
	sub.b	#1,marvin3
	sub.b	#1,marvin3+2
	sub.b	#1,marvin4
	sub.b	#1,marvin4+2
	bra	marvhoriz
marvup	add.b	#1,marvin1		;Make marvin move down
	add.b	#1,marvin1+2
	add.b	#1,marvin2
	add.b	#1,marvin2+2
	add.b	#1,marvin3
	add.b	#1,marvin3+2
	add.b	#1,marvin4
	add.b	#1,marvin4+2
marvhoriz	
	add.b	#1,marvin1+1		;Make marvin move right
	add.b	#1,marvin2+1
	add.b	#1,marvin3+1
	add.b	#1,marvin4+1
	rts
marvdown	
	move.b	#0,marvf
	bra	marv			;set down scroll flag
marvupy	move.b	#1,marvf
	bra	marv			;set up scroll flag


**************************************************************************
;		SCROLL COPPER BAR
**************************************************************************
copperbar
	cmpi.w	#$2a01,w1		;Is bar at top?
	beq	copdown		
	cmpi.w	#$5b01,w7		;Is bar at bottom?
	beq	copup	
cops	cmpi.b	#0,copscroll		;which way
	beq	cup
cdown	
	add.w	#$0200,w1		;Scroll bar
	add.w	#$0200,w2		;down screen
	add.w	#$0200,w3
	add.w	#$0200,w4
	add.w	#$0200,w5
	add.w	#$0200,w6
	add.w	#$0200,w7
	bra	bar2			;Return to main progry!
cup	
	sub.w	#$0200,w1		;Scroll bar
	sub.w	#$0200,w2		;up screen
	sub.w	#$0200,w3
	sub.w	#$0200,w4
	sub.w	#$0200,w5
	sub.w	#$0200,w6
	sub.w	#$0200,w7
	bra	bar2			;Return to main progy!
copdown	move.b	#$1,copscroll		;set scroll flag to up
	bra	cops
copup	move.b	#$0,copscroll		;set scroll flag to down
	bra	cops

bar2
	cmpi.w	#$5d01,w8		;Is bar at top?
	beq	copdown1		
	cmpi.w	#$9c01,w14		;Is bar at bottom?
	beq	copup1	
cops1	cmpi.b	#0,copscroll1		;which way
	beq	cup1
cdown1	
	add.w	#$0200,w8		;Scroll bar
	add.w	#$0200,w9		;down screen
	add.w	#$0200,w10
	add.w	#$0200,w11
	add.w	#$0200,w12
	add.w	#$0200,w13
	add.w	#$0200,w14
	rts				;Return to main progry!
cup1	
	sub.w	#$0200,w8		;Scroll bar
	sub.w	#$0200,w9		;up screen
	sub.w	#$0200,w10
	sub.w	#$0200,w11
	sub.w	#$0200,w12
	sub.w	#$0200,w13
	sub.w	#$0200,w14
	rts				;Return to main progy!
copdown1	move.b	#$1,copscroll1	;set scroll flag to up
	bra	cops1
copup1	move.b	#$0,copscroll1	;set scroll flag to down
	bra	cops1
	

*************************************************************************
;	SCROLL TEXT-coded by Hearwig, this part is a MESS!!(-Raist)
*************************************************************************
scroll_text
	movem.l	d0-d7/a0-a6,-(sp)	Save regs
	lea	screen,a1	address of start of bitplane
	add.l	#40*$7c+38,a1	end of first line of text `window'
	moveq.l	#6,d1		7 lines
doline	moveq.l	#17,d0		window is 8 words long
	asl.w	(a1)		shift last word left once
doone	roxl.w	-(a1)		and shift the others left too, with a1 having a word subtracted from it.  roxl is used to get old bit which was knocked off from last instruction to be shifted into present word
	dbra	d0,doone	do it 8 times
	add.l	#76,a1		add 56 to get to end of window next line down (40=length of window, shifted 2 left 8 times, 40+16=56)
	dbra	d1,doline	do this 7 times
	lea	screen,a1	same offset as before
	add.l	#40*$7c+38,a1
	move.l	presadd,a2	load address of data for current letter
	move.l	#6,d0		letter=7 lines
	move.b	presbit,d1	keeps tally of bit to mask
testit	btst	d1,(a2)+	is relevant bit in letter set?
	beq	nextone		No, then nothing should be printed
	or.b	#1,(a1)		put a 1 in bit 0 of last byte of window
nextone	add.l	#40,a1		add 40 to a1 to get to next line
	dbra	d0,testit	do it 7 times
	subq.b	#1,presbit	next bit to the right is wanted for next letter
	bpl.s	getout		if not all bits of letter have been displayed go to getout
	move.l	tadd,a1		get address of place in text
return	clr.l	d1		clear d1
	move.b	(a1)+,d1	get the ascii number of letter and point a1 to next letter
	bne	notend		if 0, then it is the end of the text.  If not, go to notout
	lea	mytext,a1	start again from the beginning
	move.b	(a1)+,d1	get ascii number of letter and point a1 to next letter
notend	move.l	a1,tadd		put a1 back into tadd, contains address of next letter
	sub.l	#32,d1		subtract 32 from ascci number so space=0, !=1. etc
	bmi	return		;detects for a carrige return
	mulu	#7,d1		multiply by 7 - each letter takes up 7 bytes
	add.l	#letters,d1	add it to the start of letter data
	move.l	d1,presadd	and this is the address of letter to print
	move.b	#7,presbit	start from bit 7 of letter again
getout	movem.l	(SP)+,d0-d7/a0-a6	Restore regs
	rts
	even
letters	dc.b	0,0,0,0,0,0,0			Letters, starting from space up to Z including all ascii characters between
	dc.b	$10,$10,$10,$10,$10,0,$10
	dc.b	$14,$14,0,0,0,0,0
	dc.b	0,$12,$3f,$12,$12,$3f,$12
	dc.b	$08,$1c,$20,$1c,$a,$1c,$08
	dc.b	$21,$52,$24,8,$12,$25,$42
	dc.b	$30,$48,$48,$39,$46,$44,$3d
	dc.b	8,8,16,0,0,0,0
	dc.b	4,8,16,16,16,8,4
	dc.b	16,8,4,4,4,8,16
	dc.b	0,$15,$0e,$1f,$0e,$15,0
	dc.b	0,8,8,$3e,8,8,0
	dc.b	0,0,0,0,0,8,16
	dc.b	0,0,0,$1c,0,0,0
	dc.b	0,0,0,0,0,0,8
	dc.b	1,2,4,8,16,32,64
	dc.b	$1c,$22,$22,$22,$22,$22,$1c
	dc.b	$08,$18,$08,$08,$08,$08,$3e
	dc.b	$1c,$22,$02,$04,$08,$10,$3e
	dc.b	$1c,$22,$02,$0c,$02,$22,$1c
	dc.b	$04,$0c,$14,$24,$3f,$02,$02
	dc.b	$3e,$20,$20,$3c,$02,$22,$1c
	dc.b	$1c,$22,$20,$3c,$22,$22,$1c
	dc.b	$3e,$02,$04,$08,$10,$30,$30
	dc.b	$1c,$22,$22,$1c,$22,$22,$1c
	dc.b	$1c,$22,$22,$1e,$02,$02,$1c
	dc.b	0,0,8,0,8,0,0
	dc.b	0,0,8,0,8,16,0
	dc.b	4,8,16,32,16,8,4
	dc.b	0,0,$3e,0,$3e,0,0
	dc.b	32,16,8,4,8,16,32
	dc.b	$18,$24,4,8,16,16,0
	dc.b	$3c,$42,$99,$a5,$a5,$9e,$40
	dc.b	$1c,$22,$22,$3e,$22,$22,$22
	dc.b	$3c,$22,$22,$3c,$22,$22,$3c
	dc.b	$1c,$22,$20,$20,$20,$22,$1c
	dc.b	$3c,$22,$22,$22,$22,$22,$3c
	dc.b	$3e,$20,$20,$38,$20,$20,$3e
	dc.b	$3e,$20,$20,$3e,$20,$20,$20
	dc.b	$1c,$20,$20,$26,$22,$22,$1c
	dc.b	$22,$22,$22,$3e,$22,$22,$22
	dc.b	$1c,8,8,8,8,8,$1c
	dc.b	2,2,2,2,2,$22,$1c
	dc.b	$22,$24,$28,$30,$28,$24,$22
	dc.b	32,32,32,32,32,32,$3f
	dc.b	$22,$36,$2a,$2a,$22,$22,$22
	dc.b	$22,$32,$2a,$26,$22,$22,$22
	dc.b	$1c,$22,$22,$22,$22,$22,$1c
	dc.b	$3c,$22,$22,$3c,$20,$20,$20
	dc.b	$1c,$22,$22,$22,$2a,$3c,2
	dc.b	$3c,$22,$22,$3c,$28,$24,$22
	dc.b	$1c,$22,$20,$1c,2,$22,$1c
	dc.b	$3e,8,8,8,8,8,8
	dc.b	$22,$22,$22,$22,$22,$22,$1e
	dc.b	$22,$22,$22,$14,$14,8,8
	dc.b	$22,$22,$22,$2a,$2a,$2a,$14
	dc.b	$22,$14,$14,8,$14,$14,$22
	dc.b	$22,$22,$22,$1e,2,2,$1c
	dc.b	$3e,2,4,8,16,32,$3e
	even
mytext	INCBIN	Source:source/SCROLLTEXT
	dc.b	0
	even
presadd	dc.l	0	address of letter data which is being printed
tadd	dc.l	0	address of position in text
presbit	dc.b	0	and bit number which is to be displayed
	even		;Line-up clean_up. Try it without!!

****************************************************************************
;		CLEAN-UP & BYE,BYE!!
****************************************************************************
clean_up
	move.l	oldint+2,$6c		;Restore interrupt
	jsr	_end			;End the music
	move.l	gfxbase,a1	
	move.l	38(a1),cop1lch(a5)	;Restore system copper
	move.w	#$0,copjmp1(a5)		;& run sys copper
	move.l	4,a6			;EXEC base
	jsr	-138(a6)		;Permit!!
	move.l	gfxbase,a1		;gfx to close
	jmp	-414(a6)		;and close!!
quit	rts				;BYE!BYE!

****************************************************************************
;		COPPER LIST
****************************************************************************
	section	chips,code_c	;Need chip mem
copperlist
	dc.w	diwstrt,$2c81	;Screen set-up
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0101001000000000	
	dc.w	bplcon1,$0
**Top part of screen
	dc.w	color00,$000	;Black background!!
bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0	;Load bitplane pointers
bph2	dc.w	bpl2pth,$0	;for backgroun piccy
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0
bph5	dc.w	bpl5pth,$0
bpl5	dc.w	bpl5ptl,$0
**Sprites
	dc.w	color16,$fff	;stars are white!!
	dc.w	color17,$fff	;yep same here
sph0	dc.w	spr0pth,$0	;Stars
spl0	dc.w	spr0ptl,$0	;Stars
sph1	dc.w	spr1pth,$0	;A
spl1	dc.w	spr1ptl,$0	;sprite
sph2	dc.w	spr2pth,$0	;C
spl2	dc.w	spr2ptl,$0	;sprite
sph3	dc.w	spr3pth,$0	;C
spl3	dc.w	spr3ptl,$0	;sprite
sph4	dc.w	spr4pth,$0	;Marvin
spl4	dc.w	spr4ptl,$0	;sprite
sph5	dc.w	spr5pth,$0	;Marvin
spl5	dc.w	spr5ptl,$0	;sprite
sph6	dc.w	spr6pth,$0	;Marvin
spl6	dc.w	spr6ptl,$0	;sprite
sph7	dc.w	spr7pth,$0	;Marvin
spl7	dc.w	spr7ptl,$0	;sprite
**BOB COLOURS			
	dc.w	color00,$000	;Raistlins colours
	dc.w	color01,$300
	dc.w	color02,$111
	dc.w	color03,$044
	dc.w	color04,$066
	dc.w	color05,$000
	dc.w	color06,$a40
	dc.w	color07,$1a9
	dc.w	color08,$d63
	dc.w	color09,$9aa
	dc.w	color10,$f96
	dc.w	color11,$bac
	dc.w	color12,$7cf
	dc.w	color13,$fb9
	dc.w	color14,$ace
	dc.w	color15,$dcf
	dc.w	color16,$f00	;notmans colours
	dc.w	color17,$aaa	;stars (light grey)
	dc.w	color18,$777	;stars (grey)
	dc.w	color19,$444	;stars (dark grey)
	dc.w	color20,$fff
	dc.w	color21,$aaa	;CC=grey
	dc.w	color22,$fec
	dc.w	color23,$feb
	dc.w	color24,$fda
	dc.w	color25,$fd8
	dc.w	color26,$fc7
	dc.w	color27,$fc6
	dc.w	color28,$fb4
	dc.w	color29,$fb3
	dc.w	color30,$fa1
	dc.w	color31,$fa0
	
	dc.w	$2001,$fffe	;Dummy wait
w1	dc.w	$2a01,$fffe	;Purple scrolling copper bar
	dc.w	color00,$707
w2	dc.w	$2b01,$fffe	;wait values
	dc.w	color00,$909	;colour values
w3	dc.w	$2c01,$fffe
	dc.w	color00,$c0c
w4	dc.w	$2d01,$fffe
	dc.w	color00,$f0f
w5	dc.w	$2f01,$fffe
	dc.w	color00,$c0c
w6	dc.w	$3001,$fffe
	dc.w	color00,$707
w7	dc.w	$3101,$fffe
	dc.w	color00,$000

w8	dc.w	$5501,$fffe	;Green scrolling bar
	dc.w	color00,$070
w9	dc.w	$5601,$fffe
	dc.w	color00,$090
w10	dc.w	$5701,$fffe
	dc.w	color00,$0c0
w11	dc.w	$5801,$fffe
	dc.w	color00,$0f0
w12	dc.w	$5a01,$fffe
	dc.w	color00,$0c0
w13	dc.w	$5b01,$fffe
	dc.w	color00,$070
w14	dc.w	$5c01,$ffe
	dc.w	color00,$000
				
	dc.w	$9f01,$fffe	;This section
	dc.w	color00,$800	;does ye olde
	dc.w	$a001,$fffe	;copper bars
	dc.w	color00,$c00	;Havent done any
	dc.w	$a101,$fffe	;copper bars for ages!!
	dc.w	color00,$f00
	dc.w	$a301,$fffe	;PS these r d red uns
	dc.w	color00,$c00
	dc.w	$a401,$fffe
	dc.w	color00,$800
	dc.w	$a501,$fffe
	dc.w	color00,$000	
	dc.w	$a801,$fffe
	dc.w	color01,$ff0
	dc.w	$a901,$fffe
	dc.w	color01,$cc0
	dc.w	$aa01,$fffe
	dc.w	color01,$aa0
	dc.w	$ab01,$fffe
	dc.w	color01,$880
	dc.w	$ac01,$fffe
	dc.w	color01,$660
	dc.w	$ad01,$fffe
	dc.w	color01,$550
	dc.w	$ae01,$fffe
	dc.w	color01,$440	
	dc.w	$b001,$fffe
	dc.w	color00,$800
	dc.w	$b101,$fffe
	dc.w	color00,$c00
	dc.w	$b201,$fffe
	dc.w	color00,$f00
	dc.w	$b401,$fffe
	dc.w	color00,$c00
	dc.w	$b501,$fffe
	dc.w	color00,$800	;all that code for those
	dc.w	$b601,$fffe	;measily things!!
	dc.w	color00,$000	

**************************************************************************
;		SCREEN FOR LOGO
**************************************************************************
	dc.w	bplcon0,%0100001000000000	;New bplcon0 for logo
;colours for logo			
c1	dc.w	color00,$000	;colours for Raistlin(initialy)
c2	dc.w	color01,$300	;as Raistlin is the first one shown
c3	dc.w	color02,$111
c4	dc.w	color03,$044
c5	dc.w	color04,$066
c6	dc.w	color05,$fff
c7	dc.w	color06,$a40
c8	dc.w	color07,$189
c9	dc.w	color08,$d63
c10	dc.w	color09,$98a
c11	dc.w	color10,$f96
c12	dc.w	color11,$bac
c13	dc.w	color12,$7cf
c14	dc.w	color13,$fb9
c15	dc.w	color14,$ace
c16	dc.w	color15,$dcf

;Colours for Marvin sprite
	dc.w	color16,$000,color17,$000,color18,$fff
	dc.w	color19,$f60,color20,$fff,color21,$ff1
	dc.w	color22,$00f,color23,$fff,color24,$ddd
	dc.w	color25,$ccc,color26,$aaa,color27,$999
	dc.w	color28,$777,color29,$655,color30,$444
	dc.w	color31,$a40

;Set-up bitplane ptrs for logo
	dc.w	$cf01,$fffe	;Wait pointing bitplanes ptrs
				;to LOGO!!
bph6	dc.w	bpl1pth,$0	;Set-up bitplane
bpl6	dc.w	bpl1ptl,$0	;pointers for
bph7	dc.w	bpl2pth,$0	;logo 
bpl7	dc.w	bpl2ptl,$0
bph8	dc.w	bpl3pth,$0
bpl8	dc.w	bpl3ptl,$0
bph9	dc.w	bpl4pth,$0
bpl9	dc.w	bpl4ptl,$0
	dc.w	$ffff,$fffe	;End of copper list

************************************************************************
;			SECOND COPPER LIST
************************************************************************
copper2

	dc.w	dmacon,$20		
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0

;colours
	dc.w	color00,$000,color01,$200,color02,$400,color03,$040
	dc.w	color04,$221,color05,$421,color06,$233,color07,$711
	dc.w	color08,$642,color09,$940,color10,$644,color11,$03b
	dc.w	color12,$654,color13,$15b,color14,$a34,color15,$42b
	dc.w	color16,$864,color17,$26c,color18,$a64,color19,$876
	dc.w	color20,$988,color21,$49d,color22,$d95,color23,$bc4
	dc.w	color24,$ba7,color25,$ba9,color26,$ed7,color27,$cbb
	dc.w	color28,$adc,color29,$dca,color30,$dec,color31,$ffe

bp1h	dc.w	bpl1pth,$0
bp1l	dc.w	bpl1ptl,$0
bp2h	dc.w	bpl2pth,$0
bp2l	dc.w	bpl2ptl,$0
bp3h	dc.w	bpl3pth,$0
bp3l	dc.w	bpl3ptl,$0
bp4h	dc.w	bpl4pth,$0
bp4l	dc.w	bpl4ptl,$0
bp5h	dc.w	bpl5pth,$0
bp5l	dc.w	bpl5ptl,$0
	dc.w	$ffff,$fffe


************************************************************************
;			SPRITE DATA
************************************************************************
*STARS
SPRITE  dc.w    $307A,$3100,$0000,$1000,$32C0,$3300,$0000,$1000
        dc.w    $3442,$3500,$1000,$0000,$36A2,$3700,$0000,$1000			
        dc.w    $38DA,$3900,$1000,$0000,$3A5A,$3B00,$0000,$1000
        dc.w    $3CC5,$3D00,$1000,$0000,$3EB8,$3F00,$0000,$1000
        dc.w    $5082,$5100,$1000,$1000,$52D0,$5300,$1000,$0000
        dc.w    $547A,$5500,$1000,$0000,$56C0,$5700,$1000,$0000
	dc.w    $5842,$5900,$1000,$0000,$5AA2,$5B00,$1000,$0000
	dc.w    $5CDA,$5D00,$1000,$0000,$5E5A,$5F00,$1000,$0000
	dc.w    $60C5,$6100,$0000,$0001,$62B8,$6300,$1000,$1000
	dc.w    $6482,$6500,$1000,$0000,$66D0,$6700,$1000,$0000
        dc.w    $687A,$6900,$1000,$0000
	dc.w	$6A0A,$6B00,$1000,$0000,$6C7d,$6D00,$0000,$0001
	dc.w	$6E55,$6F00,$0000,$0001,$7023,$7100,$1000,$0000
	dc.w	$723a,$7300,$0000,$0001,$74ff,$7500,$1000,$0000
	dc.w	$7600,$7700,$1000,$0000
	dc.w	$780A,$7900,$0000,$0001,$7a7d,$7b00,$0000,$1000
	dc.w	$7c55,$7d00,$1000,$0000,$7e23,$7f00,$1000,$0000
	dc.w	$803a,$8100,$1000,$0000,$82ff,$8300,$1000,$1000
	dc.w	$8400,$8500,$1000,$0000
	dc.w	$860A,$8700,$1000,$1000,$887d,$8900,$1000,$0000
	dc.w	$8a55,$8b00,$1000,$0000,$8c23,$8d00,$1000,$1000
	dc.w	$8e3a,$8f00,$0000,$0001,$90ff,$9100,$1000,$0000
	dc.w	$9200,$9300,$1000,$0000
SPRITEE	dc.w    $0000,$0000
	
A	dc.w	$364f,$4200	;Control Words
	dc.w	$03e4,$0000,$07fc,$0000,$0c1c,$0000,$19ac,$0000
	dc.w	$12cc,$0000,$108c,$0000,$090c,$0000,$03fc,$0000
	dc.w	$040c,$0000,$0f4e,$0000,$1384,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	
C	dc.w	$4b59,$5f00	;Control Words
	dc.w	$0000,$0000,$0240,$0000,$04e2,$0000,$097c,$0000
	dc.w	$1338,$0000,$3700,$0000,$3300,$0000,$3300,$0000
	dc.w	$1a02,$0000,$0e04,$0000,$07f8,$0000,$03f0,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000 ,$0000,$0000,$0000,$0000,$0000,0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000

CC	dc.w	$6063,$7100	;Control Words
	dc.w	$0000,$0000,$0240,$0000,$04e2,$0000,$097c,$0000
	dc.w	$1338,$0000,$3700,$0000,$3300,$0000,$3300,$0000
	dc.w	$1a02,$0000,$0e04,$0000,$07f8,$0000,$03f0,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000 ,$0000,$0000,$0000,$0000,$0000,0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000

Marvin1	dc.w	$c062,$de00	;Control Words
	dc.w	$f800,$0000,$f800,$0000,$ffff,$2000,$e000,$1fff
	dc.w	$e000,$1fff,$3fff,$1fff,$2000,$1fff,$2000,$1fff
	dc.w	$3fff,$0000,$1010,$0000,$3030,$0000,$2fff,$1030
	dc.w	$2fff,$1058,$21f8,$1ec7,$20c0,$1f3f,$2fff,$1fff
	dc.w	$2fff,$1fff,$2007,$0000,$2fff,$1000,$2fff,$1000
	dc.w	$2020,$1fdf,$6000,$1fff,$c000,$0000,$bfff,$7fff
	dc.w	$ffff,$0000,$8000,$7fff,$c000,$0000,$4000,$3fff
	dc.w	$4000,$3fff,$7fff,$0000
Marvin2	dc.w	$c062,$de80	;Control Words
	dc.w	$0000,$0000,$0000,$0000,$2000,$2000,$1000,$1fff
	dc.w	$1fff,$1fff,$0000,$1fff,$1000,$1fff,$1fff,$1fff
	dc.w	$0000,$0000,$0000,$0fef,$0000,$0fcf,$1030,$1fb7
	dc.w	$1058,$1f5b,$10c0,$1ec7,$1000,$1f3f,$1000,$1fff
	dc.w	$1000,$1fff,$1ff8,$1ff8,$1f87,$1f87,$1fdf,$1fdf
	dc.w	$1fdf,$1fdf,$1fff,$1fff,$0000,$3fff,$4000,$7fff	
	dc.w	$7fff,$7fff,$7fff,$7fff,$3fff,$3fff,$0000,$3fff
	dc.w	$3fff,$3fff,$0000,$0000
Marvin3	dc.w	$c069,$de00	;Control Words
	dc.w	$0000,$0000,$0000,$0000,$fffc,$0000,$0004,$fff8
	dc.w	$0004,$fff8,$fffc,$fff8,$0004,$fff8,$0004,$fff8
	dc.w	$fffc,$0000,$0808,$0000,$1c0c,$0800,$fff4,$0c08
	dc.w	$fff4,$1a08,$1f84,$e378,$0304,$fcf8,$fff4,$fff8
	dc.w	$fff4,$fff8,$e004,$0080,$fff4,$0008,$fff4,$0008
	dc.w	$0404,$fbf8,$0006,$fff8,$0003,$0000,$fffd,$fffe
	dc.w	$ffff,$0000,$0001,$fffe,$0003,$0000,$0002,$fffc
	dc.w	$0002,$fffc,$fffe,$0000
Marvin4	dc.w	$c069,$de80	;Control Words
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0008,$fff8
	dc.w	$fff8,$fff8,$0000,$fff8,$0008,$fff8,$fff8,$fff8
	dc.w	$0000,$0000,$0000,$f7f0,$0800,$ebf0,$0c08,$edf8
	dc.w	$1a08,$daf8,$0308,$e378,$0008,$fcf8,$0008,$fff8
	dc.w	$0008,$fff8,$1ff8,$1ff8,$e1f8,$e1f8,$fbf8,$fbf8
	dc.w	$fbf8,$fbf8,$fff8,$fff8,$0000,$fffc,$0000,$fffe
	dc.w	$fffe,$fffe,$fffe,$fffe,$fffc,$fffc,$0000,$fffc
	dc.w	$fffc,$fffc,$0000,$0000


****************************************************************************
;		PROGRAM VARIABLES (HOW INTERESTING)
****************************************************************************
gfxname	dc.b	'graphics.library',0		;Load gfx lib
	even
gfxbase	dc.l	0				;Gfx base address goes here
	even
sample3	incbin	df1:modules/sample3		;Load sample
	even				
screen	dcb.b	40*163*5,0			;Blank for top part 
	even					;of screen
copscroll	ds.b	1			;scroll flag for cop bar
copscroll1
	dc.b	1
scrollfa	ds.b	1			;A scroll flag
scrollfc	ds.b	1			;C scroll flag
scrollfcc	ds.b	1			;CC scroll flag
marvf		ds.b	1			;
***********************************
*logos are 3 bitplanes 320x93 size*
***********************************
logo1	incbin	raistlin			;Logo of Raistlin
logo2	incbin	notman				;Logo of Notman
logo3	incbin	caramon				;Logo of Caramon
logo4	incbin	marvin				;Logo of Marvin
dragon	incbin	dragonlogo.r
*************************************
*Bobs are 32x?? and 5 bitplanes deep*
*************************************
vbl	ds.b	1				;vbl flag
bobs	ds.w	1				;Space for blitter size
destr	ds.w	1				;Destination of bob
destrf	ds.w	1				;scroll flag
destn	ds.w	1
destnf	ds.w	1
destc	ds.w	1
destcf	ds.w	1
raistbob incbin	raistbob	;Call bob graphics
notbob	incbin	notbob
carabob	incbin	caramonbob

*	PLAY ROUTINE			;BY MIKE CROSS!!

		
_init 	lea	Module,a0		* Initialise Music
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
_init1 
	move.l	d1,d2
	subq.w	#1,d0
_init2 
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	_init1
	dbf	d0,_init2
	addq.b	#1,d2

_init3 
	lea	Module,a0
	lea	_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
_init4 
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,_init4

	lea	_sample1(PC),a0
	moveq	#0,d0
_clear 
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	_partnrplay
	clr.l	_partnote
	clr.l	_partpoint

	move.b	Module+$3b6,_maxpart+1
	rts

* call '_end' to switch the sound off

_end 	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

* the playroutine - call this every frame

_music 
	addq.w	#1,_counter
_cool cmp.w	#6,_counter
	bne.s	_notsix
	clr.w	_counter
	bra	_rout2

_notsix 
	lea	_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp1
	lea	$dff0a0,a5		
	bsr.s	_arprout
_arp1 lea	_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp2
	lea	$dff0b0,a5
	bsr.s	_arprout
_arp2 lea	_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp3
	lea	$dff0c0,a5
	bsr.s	_arprout
_arp3 lea	_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp4
	lea	$dff0d0,a5
	bra.s	_arprout
_arp4 rts

_arprout 
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	_arpegrt
	cmp.b	#$01,d0
	beq.s	_portup
	cmp.b	#$02,d0
	beq.s	_portdwn
	cmp.b	#$0a,d0
	beq.s	_volslide
	rts

_portup 
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	_ok1
	move.w	#$71,22(a6)
_ok1 	move.w	22(a6),6(a5)
	rts

_portdwn 
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	_ok2
	move.w	#$538,22(a6)
_ok2 	move.w	22(a6),6(a5)
	rts

_volslide 
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	_ok3
	move.w	#64,18(a6)
_ok3 	move.w	18(a6),8(a5)
	rts
_voldwn 
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	_ok4
	clr.w	18(a6)
_ok4 	move.w	18(a6),8(a5)
	rts

_arpegrt 
	move.w	_counter(PC),d0
	cmp.w	#1,d0
	beq.s	_loop2
	cmp.w	#2,d0
	beq.s	_loop3
	cmp.w	#3,d0
	beq.s	_loop4
	cmp.w	#4,d0
	beq.s	_loop2
	cmp.w	#5,d0
	beq.s	_loop3
	rts

_loop2 
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	_cont
_loop3 
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	_cont
_loop4 
	move.w	16(a6),d2
	bra.s	_endpart
_cont 
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	_arpeggio(PC),a0
_loop5 
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	_endpart
	addq.l	#2,a0
	bra.s	_loop5
_endpart 
	move.w	d2,6(a5)
	rts

_rout2 
	lea	Module,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	_partnote(PC),d1
	move.l	d1,_partpoint
	clr.w	_dmacon

	lea	$dff0a0,a5
	lea	_aud1temp(PC),a6
	bsr	_playit
	lea	$dff0b0,a5
	lea	_aud2temp(PC),a6
	bsr	_playit
	lea	$dff0c0,a5
	lea	_aud3temp(PC),a6
	bsr	_playit
	lea	$dff0d0,a5
	lea	_aud4temp(PC),a6
	bsr	_playit
	move.w	#$01f4,d0
_rls 	dbf	d0,_rls

	move.w	#$8000,d0
	or.w	_dmacon,d0
	move.w	d0,$dff096

	lea	_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
_voice3 
	lea	_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
_voice2 
	lea	_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
_voice1 
	lea	_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
_voice0 
	move.l	_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,_partnote
	cmp.l	#$400,d0
	bne.s	_stop
_higher 
	clr.l	_partnote
	addq.l	#1,_partnrplay
	moveq	#0,d0
	move.w	_maxpart(PC),d0
	move.l	_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	_stop
	clr.l	_partnrplay
	
_stop tst.w	_status
	beq.s	_stop2
	clr.w	_status
	bra.s	_higher
_stop2 
	rts

_playit 
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	_nosamplechange

	moveq	#0,d3
	lea	_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	_nosamplechange

_displace 
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
_nosamplechange 
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,_dmacon

_retrout 
	tst.w	(a6)
	beq.s	_nonewper
	move.w	(a6),22(a6)

_nonewper 
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	_posjmp
	cmp.b	#$0c,d0
	beq.s	_setvol
	cmp.b	#$0d,d0
	beq.s	_break
	cmp.b	#$0e,d0
	beq.s	_setfil
	cmp.b	#$0f,d0
	beq.s	_setspeed
	rts

_posjmp 
	not.w	_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,_partnrplay
	rts

_setvol 
	move.b	3(a6),8(a5)
	rts

_break 
	not.w	_status
	rts

_setfil 
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

_setspeed 
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	_back
	clr.w	_counter
	move.b	d0,_cool+3
_back rts

_aud1temp 
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
_aud2temp 
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
_aud3temp 
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
_aud4temp 
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

_partnote 	dc.l	0
_partnrplay 	dc.l	0
_counter 	dc.w	0
_partpoint 	dc.l	0
_samples 	dc.l	0
_sample1 	dcb.l	31,0
_maxpart 	dc.w	0
_dmacon 	dc.w	0
_status 	dc.w	0

_arpeggio 
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

Module 	incbin	"df1:modules/mod.popcorn"

