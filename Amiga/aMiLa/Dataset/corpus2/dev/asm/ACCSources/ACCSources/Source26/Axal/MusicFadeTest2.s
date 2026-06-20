
* DATE:	29 June 1992
* TIME:	18:20
* NAME:	Music fade interrupt example
* CODE:	Axal
* NOTE:	Just an example of music fader running under interrupt

*---------------------------------------
	opt	c-,ow+,o+,D+
*---------------------------------------
	incdir	source:include/
	include	hardware.i
	include	axal_lib.i
*---------------------------------------
start
	section	Chipmem,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save the stack address
*---------------------------------------
	callexe	forbid			forbid multi-tasking

	bsr	mt_init			start music

	lea	$dff000,a5		pointer to custom chips
	move.w	intenar(a5),d0		get system interrup enable
	or.w	#$c000,d0		set enable bit
	move.w	d0,systen		save it
	move.w	intreqr(a5),d0		get system interrup request
	or.w	#$8000,d0		set enable
	move.w	d0,systrq		save it

	move.w	#$7fff,d0		set to clear
	move.w	d0,intena(a5)		clear enable
	move.w	d0,intreq(a5)		clear request

	move.l	$6c.w,syslev3		save address
	move.l	#lev3_interrupt,$6c.w	insert my commands

	move.w	#$c020,intena(a5)	vertical set
*---------------------------------------
vertloop
	btst	#6,$bfe001		left mouse button
	bne.s	vertloop

	moveq	#1,d0			set delay
	bsr	mt_initfade		start music fader
.loop
	tst.b	mt_fade			wait until fade ended
	bne.s	.loop
*---------------------------------------
quit_program
	move.w	#$7fff,d0		set to clear
	move.w	d0,intena(a5)		clear enable
	move.w	d0,intreq(a5)		clear request

	move.l	syslev3(pc),$6c.w	restore interrupt
	move.w	systen(pc),intena(a5)	restore system interrup enable
	move.w	systrq(pc),intreq(a5)	restore system interrup request

	bsr	mt_end			stop music

	callexe	enable			enable multi-tasking
*---------------------------------------
gfxerror1
	move.l	stack,sp		restore stack
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	moveq	#0,d0			keep cli happy
	rts
*---------------------------------------
lev3_interrupt
	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	lea	$dff000,a5		custom chips
	move.w	intreqr(a5),d0		get interrupt requests
	and.w	#$20,d0			check for vertical
	beq.s	.no0			branch if not
	bsr	mt_music		play music
.no0
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	move.w	#$70,intreq(a5)		clear vert/copper/blitter
death_init
	rte
*---------------------------------------
stack		ds.l	1
syslev3		ds.l	1
systen		ds.w	1
systrq		ds.w	1
*---------------------------------------
	include	pt11bvol-play.s
*---------------------------------------

mt_data	incbin	source:modules/mod.music
