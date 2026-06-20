
* THIS IS AN EXAMPLE OF HOW TO USE THE MUSIC FADER WITHOUT
* USING INTERRUPTS.  IT'S QUITE SIMPLE TO FOLLOW!

* CODE BY ME
* MUSIC BY TROOPER

	opt c-

	include	axal_lib.i

	section d,data_c
start
	callexe	forbid			no multitasking

	bsr	mt_init			get music going, clear fade options
.loop
	cmp.b	#$ff,$dff006
	bne.s	.loop			wait for vertical blank
	bsr	mt_music		play the music
	btst	#6,$bfe001
	bne.s	.loop			loop until left button pressed

	moveq	#3,d0			set delay time (0 -> 255)
	bsr	mt_initfade		set up music fade
.loop2
	cmp.b	#$ff,$dff006		wait for vertical blank
	bne.s	.loop2
	bsr	mt_music		play the music
	tst.b	mt_fade			keep playing until mt_fade = 0
	bne.s	.loop2

	bsr	mt_end			kill music
	callexe	enable			enable multitasking
	rts				and quit

	include	pt11bvol-play.s

mt_data	incbin	source:modules/mod.music


