
** Program to demonstrate double buffering

	include	source:include/hardware.i		;Get hardware equates
	opt	c-			;Any case	
	section	Double_buffering,code_c	;Put into chip RAM

	lea	$dff000,a5		;A5=Hardware offset

	move.l	4,a6			;EXEC in a6
	jsr	-132(a6)		;Forbid!
	moveq.l	#0,d0			;Any version
	lea	gfxname,a1		;Gfxname in a1
	jsr	-408(a6)		;open
	tst.l	d0			;O.K.?
	beq	quit			;Nope!
	move.l	d0,gfxbase		;Save the gfx base

***************************************************************************
;			SET-UP BITPLANE PTRS
***************************************************************************
	move.l	#screen1,d0		;Get address of screen
;bitplane1
	move.w	d0,bpl1+2		;And set-up bitplane
	swap	d0			;pointers
	move.w	d0,bph1+2
	swap	d0
	add.l	#40*256,d0		;Size of screen
;bitplane2
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2

	move.w	#$20,dmacon(a5)			;Disable sprites
	move.l	#copper1,cop1lch(a5)		;Insert my copper list
	move.w	#$0,copjmp1(a5)			;Runlist

****************************************************************************
;			VBL INTERRUPT
****************************************************************************
	move.l	$6c,oldint+2			;Save old interrupt
	move.l	#newint,$6c			;Insert mine
	jmp	Mouse_wait

Newint	movem.l	a0-a6/d0-d7,-(sp)		;Save registers
	bsr	swapscreens			;Swap d screens
	movem.l	(sp)+,a0-a6/d0-d7		;restore registers

oldint	jmp	$0				;Run system interrupt

*****************************************************************************
;		Wait LMB & Clean_up
*****************************************************************************

mouse_wait
	btst	#6,$bfe001			;test LMB
	bne	mouse_wait

clean_up
	move.l	oldint+2,$6c			;Restore old int
	move.w	#$8e30,dmacon(a5)		;Restore sprites
	move.l	gfxbase,a1			;Put gfx base in a1
	move.l	38(a1),cop1lch(a5)		;Insert sys copper
	move.w	#$0,copjmp1(a5)			;Run sys copper
	move.l	4,a6				
	move.l	gfxbase,a1	
	jsr	-414(a6)			;close gfx lib
	jsr	-138(a6)			;Permit
quit	rts					;Quit


****************************************************************************
;		SCREEN SWOPPING
****************************************************************************
swapscreens
	cmpi.b	#1,screenc		;Which screen is being shown?
	beq	s1			;screen 1
	move.l	#screen2,screen		;Address of second screen in screen
	move.b	#1,screenc		;Screen 2 is being shown
	bra	continue		;get on with it!!
s1	move.l	#screen1,screen		;Address of first screen in screen
	move.b	#0,screenc		;Screen 1 is being shown
continue		
	move.l	screen,d0		;Address of screen in d0
;bitplane1
	move.w	d0,bpl1+2		;And update bitplane
	swap	d0			;pointers
	move.w	d0,bph1+2
	swap	d0
	add.l	#40*256,d0
;bitplane2
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	rts				;And return

*****************************************************************************
;			COPPER LIST
*****************************************************************************
copper1
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0001001000000000
	dc.w	bplcon1,$0

	dc.w	color00,$000
	dc.w	color01,$fff

bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0

	dc.w	$ffff,$fffe			;End


;Program variables	
gfxbase	dc.l	0				;Space for gfx address
gfxname	dc.b	'graphics.library',0		
	even
screen1	dcb.b	40*256,%00110011		;Screen data
screen2 dcb.b	40*256,%00110011		;change this line to 0 to
	even					;see double buffering
screen	dc.l	0				;Address of screen to be
						;shown goes here
screenc	dc.b	0				;Simple screen counter
