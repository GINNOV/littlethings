** CODE  :   BLITTER1
** AUTHOR:   HEARWIG (RICK SANDIFORD)
** NOTES :
;	I'm afraid Rick doesn't document his source so I had to do it
;-Raistlin. Note Rick left of the section code_c as hes only got 512k.
; Please dont do this as its bad for us 1meg+ owners!

	SECTION	RAISTLIN,CODE_C	;This is all that it needed!
	
	opt 	c-
	include	source10:include/hardware.i
	
	lea	library,a1	;gfx lib
	clr.l	d0		;any version
	move.l	4,a6
	jsr	-408(a6)		;open sesamy
	move.l	d0,base		;save base address
reserve	move.l	#40*256*2,d0	;size of screen (2 planes)
	move.l	#2,d1		;chip mem
	jsr	-198(a6)		;allocate
	move.l	d0,b1		;save address
	move.w	d0,bpl1		;set-up bitplane ptrs
	swap	d0
	move.w	d0,bpl1h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b2
	move.w	d0,bpl2
	swap	d0
	move.w	d0,bpl2h
	move.l	b1,a1		;clear the screen
	move.l	#20*256,d0
clear	move.l	#0,(a1)+
	dbra	d0,clear
	lea	$dff000,a5
	move.w	#$20,dmacon(a5)	;disable sprites
	move.l	#list,cop1lch(a5)	;load copper
	move.w	#0,copjmp1(a5)	
	bsr	Blitter		;do blit
button	btst	#6,$bfe001
	bne	button		;wait LMB
	move.w	#$8020,dmacon(a5)
	move.l	base,a4
	move.l	38(a4),cop1lch(a5)
	move.l	b1,a1
	move.l	#40*256*2,d0	;freemem
	jsr	-210(a6)
	move.l	base,a1
	jmp	-414(a6)		;exit. Note Ricks use of jmp instead of jsr
	even			;saves memory. Is it naughty?
library	dc.b	'graphics.library',0,0
	even
b1	dc.l	0		;ptr to bitplane1
b2	dc.l	0		; '   '    '    2
base	dc.l	0		gfx base

***************************************************************************
;			COPER LIST

list	dc.w	BPL1PTL
bpl1	dc.w	0,BPL1PTH
bpl1h	dc.w	0,BPL2PTL
bpl2	dc.w	0,BPL2PTH
bpl2h	dc.w	0
	dc.w	BPLCON0,%10001000000000
	dc.w	BPLCON1,0
	dc.w	BPLCON2,0
	dc.w	DIWSTRT,$2981
	dc.w	DIWSTOP,$29c1
	dc.w	DDFSTRT,$3d
	dc.w	DDFSTOP,$d0
	dc.w	COLOR00,0
	dc.w	$ffff,$fffe

******
******BLITTER
******
Blitter	move.l	#myblit,BLTAPTh(a5)		;address of bob
	move.l	b1,d0			;address of bitplane
	add.l	#$120,d0			;offset to middle of scn
	move.l	d0,BLTDPTh(a5)		;load D register
	clr.w	BLTAMOD(a5)		;no A modulo
	move.w	#36,BLTDMOD(a5)		;36 D modulo (stops corrutption of bob)
	move.w	#$ffff,BLTAFWM(a5)		;no mask
	move.w	#$ffff,BLTALWM(a5)		;no mask
	move.w	#%100111110000,BLTCON0(a5)	;A & D registers to be used
	clr.w	BLTCON1(a5)
	move.w	#%10011000010,BLTSIZE(a5)	;2 words long * 19 pixels high
	rts

**Bob data

myblit	dc.b	%11111100,%00011111,%11000011,%11111000
	dc.b	%11111110,%00011111,%11000111,%11111100
	dc.b	%11100111,%00001111,%10001110,%00001110
	dc.b	%11100111,%00000111,%00001110,%00001110
	dc.b	%11100011,%10000111,%00011100,%00000000
	dc.b	%11100011,%10000111,%00011100,%00000000
	dc.b	%11100011,%10000111,%00011100,%00000000
	dc.b	%11100111,%00000111,%00111000,%00000000
	dc.b	%11100111,%00000111,%00111000,%00000000
	dc.b	%11111110,%00000111,%00111000,%00000000
	dc.b	%11111000,%00000111,%00111000,%00000000
	dc.b	%11111100,%00000111,%00111000,%00000000
	dc.b	%11111100,%00000111,%00011100,%00000000
	dc.b	%11101110,%00000111,%00011100,%00000000
	dc.b	%11101110,%00000111,%00011100,%00000000
	dc.b	%11100111,%00000111,%00001110,%00001110
	dc.b	%11100111,%00001111,%10001110,%00001110
	dc.b	%11100011,%10011111,%11000111,%11111100
	dc.b	%11100011,%10011111,%11000011,%11111000
