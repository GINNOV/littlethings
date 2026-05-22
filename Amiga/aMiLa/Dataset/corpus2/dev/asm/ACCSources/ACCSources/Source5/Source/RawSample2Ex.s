; rawsample2ex - SK 1st Sep 1990
	opt	c-
	section playsound,code_c		sounddata into chip
	incdir "source5:include/"
	include "macros_MC.i"			Mike`s macros and regs
	include	"my_hardware.i"

ctlw	=	$dff096		dma control
c0thi	=	$dff0a0		table address HI
c0tlo	=	c0thi+2		tabel address LO
c0tl	=	c0thi+4		table length
c0per	=	c0thi+6		read in rate
c0vol	=	c0thi+8		loudness level

run:
	move.l	#sound,c0thi	sound beginning
	move	#13376,c0tl	sound length in words
	move	#400,c0per	read in rate
	move	#40,c0vol	loudness level
	move	#$8201,ctlw	dma/start sound

wait:
	mouse	wait
	move	#1,ctlw		turn off dma
	rts

sound:	incbin	"source5:modules/tune.snd"
