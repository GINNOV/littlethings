	opt	c-
	section	Treeb,code_c
	
	include ram:hardware.i

; Create a bitplane

	move.l	4,a6
	lea	library,a1
	jsr	-408(a6)
	move.l	d0,base
	move.l	#40*256*3,d0 Full Sized 3 bitplane screen
	move.l	#2,d1
	jsr	-198(a6)
	move.l	d0,b1
	beq	quit
	move.w	d0,b1l
	swap	d0
	move.w	d0,b1h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b2
	move.w	d0,b2l
	swap	d0
	move.w	d0,b2h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b3
	move.w	d0,b3l
	swap	d0
	move.w	d0,b3h

; Create a workspace

	move.l	#20*128*3,d0	160 x 128 x 3 workspace
	move.l	#2,d2		Chip RAM
	jsr	-198(a6)	Reserve it
	move.l	d0,temp1	d0=temp space
	beq	fail		if it =0 can't go on
	add.l	#128*20,d0	Next bitplane
	move.l	d0,temp2
	add.l	#128*20,d0	and the next
	move.l	d0,temp3
	move.l	b1,d0		BStart is the first byte of the area on
	add.l	#64*40+10,d0	the screen that the workspace is copied
	move.l	d0,bstart	to (64 lines down, 10 across from top left)
	lea	$dff000,a5
	move.l	#copper,cop1lch(a5)
	move.w	#0,copjmp1(a5)
	move.l	b1,a1		Clear the screen
	move.l	#30*256-1,d0
clear	move.l	#0,(a1)+
	dbra	d0,clear
	move.l	#16,a1		a1 = degrees of rotation on horiz axis
	move.l	#0,a2		a2 = degress tilted round centre

; Main section

wait	lea	structs,a0	a0 = address of ball structure
.loop	cmp.b	#255,$dff006	Wait for vertical blanking
	bne.s	.loop		(just to make it slower)
	add.l	#2,a1		Add 2 to h. axis turn
	cmp.l	#72,a1		Turned all 72 degress yet?
	bne.s	.loop1		no, skip
	move.l	#0,a1		start at 0 again
.loop1	add.l	#1,a2		Add 1 to centre rotation
	cmp.l	#72,a2		Has this done all 72 degrees yet?
	bne.s	.loop2
	move.l	#0,a2		If so, reset it
.loop2	bsr	plotimage	plot the balls
	btst	#6,$bfe001	LMB pressed?
	bne.s	wait		no, do more waiting

; Close up routine

	move.l	base,a2
	move.l	38(a2),cop1lch(a5)
	move.l	#128*20*3,d0
	move.l	temp1,a1
	jsr	-210(a6)
fail	move.l	#40*256*3,d0
	move.l	b1,a1
	jmp	-210(a6)
quit	rts

; Wait for blitter (suprise, suprise)

bwait	btst	#14,dmaconr(a5)
	bne.s	bwait
	rts

; Wipes the workspace using blitter

wipetemp
	bsr	bwait
	move.l	temp1,bltdpth(a5)	D = start of workspace
	move.w	#0,bltdmod(a5)		no D modulo
	move.w	#$ffff,bltafwm(a5)	All bits used
	move.w	#$ffff,bltalwm(a5)
	move.w	#%100000000,bltcon0(a5)	Use D and make all bits 0
	move.w	#0,bltcon1(a5)
	move.w	#%110000000001010,bltsize(a5)	10 words by 384 lines
	rts

; Copy the workspace to screen

copytemp
	cmp.b	#255,$dff006	Wait for Vertical blanking
	bne.s	copytemp
	moveq.l	#2,d7		3 bitplanes
	move.l	bstart,d0	d0=address to put workspace onto
	move.l	temp1,d1	d1=address of workspace
.loop	bsr	bwait
	move.l	d1,bltapth(a5)	A=workspace address
	move.l	d0,bltdpth(a5)	D=screen address
	move.w	#0,bltamod(a5)	No workspace modulo
	move.w	#20,bltdmod(a5)	Screen modulo of 20
	move.w	#%100111110000,bltcon0(a5)	Standard A to D blit
	move.w	#0,bltcon1(a5)
	move.w	#%10000000001010,bltsize(a5)	10 words by 128 lines
	add.l	#128*20,d1	Next plane on workspace
	add.l	#256*40,d0	and next bitmap
	dbra	d7,.loop	Do the other 2
	rts

; Entry d3 = x co-ord
;       d4 = y co-ord
;       d5 = colour (0 yellow, 1 red)

; Exit  d0,d1,d2 and d7 altered

; In blitter, since shift values of 0-15 are needed, the size of the bob
; is made 1 word longer than it really is to prevent the wrap around effect.
; The modulo for the ball is -2 so it brings blitter back to the start of
; the next line.   A = ball, B = mask, C = place on workspace to put it,
; and D = C.

; Formula for address on workspace to blit to is:

; X / 16 * 2 + Y * 20 + temp1
; and the shift value for blitter is X MOD 16

plotball
	move.l	d5,d1		Get ball no.
	mulu	#96,d1		Each ball takes up 96 bytes, so *96 to get offset from ball1
	add.l	#ball1,d1	add ball1 to get to start of the ball
	move.l	d4,d0		Get y co-ord
	mulu	#20,d0		*20 (width of workspace area)
	move.l	d3,d2		Get x co-ord
	lsr.l	#4,d2		/16 to get no. of words
	lsl	d2		and *2 to get bytes (not /8 -even no. needed)
	add.l	d2,d0		add x offset and y offset together to get total offset
	add.l	temp1,d0	add it to the start of the workspace
	move.l	d3,d2		Get x co-ord again
	lsl.l	#8,d2		shift left 12 times so that shift value
	lsl.l	#4,d2		is where blitter needs it for bltcon 0 and 1

; The shift value is, as said above, the low 4 bits of X, and so if X is
; shifted left 12 times the other bits will be outside the low word of d2 (X)

	move.w	d2,scroll	d2 now equals bltcon1 (B shift value)
	or.w	#%111111100010,d2	Or d2 with cookie-cut minterms to get bltcon0
	moveq.l	#2,d7		3 bitplanes
doball	bsr	bwait		wait for blitter
	move.l	d1,bltapth(a5)	A = ball address
	move.l	#ballmask,bltbpth(a5)	B = ball mask
	move.l	d0,bltcpth(a5)	C and D = place on workspace
	move.l	d0,bltdpth(a5)
	move.w	#-2,bltamod(a5)
	move.w	#0,bltbmod(a5)
	move.w	#16,bltcmod(a5)	Blit 4 bytes long, workspace 20 bytes so C
	move.w	#16,bltdmod(a5)	and D modulos are 16
	move.w	d2,bltcon0(a5)	already worked out bltcon0 value
	move.w	scroll,bltcon1(a5)	ditto bltcon1
	move.w	#$ffff,bltafwm(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#%10000000010,bltsize(a5)	Size = 2 words by 16 pixels)
	add.l	#20*128,d0	Get to next plane on workspace
	add.l	#32,d1		And same for ball
	dbra	d7,doball	and do other 2 planes
	rts

; multiplies d1 by sine d0.  The angle is 1 for every 5 degrees, so 72
; is a full circle, and 18=90°.  It uses the table sines.  Works by
; multipling d0 by a number and dividing it by another, so as to avoid
; the need for numbers with decimal points.  

; the length (d1) is a byte number

; Since a sine wave is just one curve reflected four ways (90-180° is
; a reflection of 0-90°, 270-360° is a reflection 180-270° etc.) then
; just the values for 0-18 (0-90°) are given and if it is in range 90°
; to 180°, the value used is 180-d1, etc.

sine	movem.l	d2/a0,-(sp)
	divu	#72,d0		bring angle into a range of 0-71 by
	clr.w	d0		dividing by 72 and using the remainder
	swap	d0
	ext.w	d1		make length a word number
	move.l	d0,d2
	cmp.b	#36,d2		Is angle<180°? If not, just take 36 (180°)
	bcs	.loop		from the angle and at the end make negate
	sub.b	#36,d2		length
.loop	cmp.b	#19,d2		angle<95°? If not, since sine 90-180° are
	bcs	.loop1		a mirror image of sine 0-90°, make angle
	move.b	d2,-(sp)	36-d0 (180°-angle) - Push d2 onto stack
	move.b	#36,d2
	sub.b	(sp)+,d2	and pull it off again to subtract it from 36
.loop1	lsl.l	#2,d2		d2=angle*4 (each entry in the table is two words)
	add.l	#sines,d2	add the start of the table to get to numbers needed
	move.l	d2,a0		move it into an address register
	muls	(a0)+,d1	multiply d1 by first word
	divs	(a0)+,d1	and divide it by second
	ext.l	d1		Make d1 a word (otherwise the remainder stays in the high word)
	cmp.b	#36,d0		Was angle>=180°
	bcs	.loop2
	neg.l	d1		Yes then negate d1
.loop2	movem.l	(sp)+,d2/a0	and exit
	rts

; a0=address of image
; a1=horizontal rotation
; a2=rotation round centre point

; Between 270° and 90°, the first ball in the structure is in the front, so
; it has to be put on last.  This means that between these angles the ball
; values must be taken from the end of the structure and work back to the
; front.  Outside this range the last ball is infront, so the balls can be
; taken in the order they are in the structure.

plotimage
	bsr	wipetemp	wipe workspace
	move.l	(a0)+,d6	Get no. of balls in structure
	clr.l	d3		Clear the registers
	clr.l	d4
	clr.l	d5
	cmp.l	#18,a1		<90° or >=270°, start at back
	bcs	.loop1
	cmp.l	#54,a1
	bcc	.loop1
.loop	lea	firstback,a4	a4=code which gets numbers from front
	bra	.loop2
.loop1	move.l	d6,d0		Get end of structure (a0+(d0+1)*3)
	mulu	#3,d0
	add.l	#3,d0
	add.l	d0,a0
	lea	lastback,a4	a4=code which gets numbers from back
.loop2	clr.l	d2		Clear regs
	clr.l	d7
	jsr	(a4)		Get the code

; On return, d7=distance from centre, d2=angle ball is at and d5=colour

	add.l	a2,d2		Add the a2 rotation to the degrees ball is
;				at to get real angle
	move.l	d2,d0		Get d7 x SIN (d2)
	move.l	d7,d1
	bsr	sine

; The number returned is relative to the centre, so the get the actual 
; X co-ordinate we must add 64 (half the width of the workspace)

	add.l	#64,d1
	move.l	d1,d3		d3 = X co-ordinate

; This next bit is more complicated.  COS x = SIN ( x-90 ). So to get
; the Y co-ordinate, we take 18 away (which is the same as adding 54,
; since 18+54=72 -- This is better - prevents negative numbers).  The
; sine routine can handle numbers more than 71 so the number can go
; outside 0-71 range.  Once this is done, the distance is then timesd
; by SIN (a1) to get the actual Y value (see doc).  64 is again added
; since the result is relative to centre

	move.l	d2,d0		Add 54 to d0
	add.l	#54,d0
	move.l	d7,d1
	bsr	sine		and so work out d7 x COS (d2)
	move.l	a1,d0		and x d0 by SIN (a1)
	bsr	sine
	add.l	#64,d1		Get Y position
	move.l	d1,d4		put it in d4
	bsr	plotball	plot the ball
	dbra	d6,.loop2	and do the rest
.loop3	bra	copytemp	copy the image to the screen
	rts

firstback
	move.b	(a0)+,d7
	move.b	(a0)+,d2
	move.b	(a0)+,d5
	rts

lastback
	move.b	-(a0),d5
	move.b	-(a0),d2
	move.b	-(a0),d7
	rts

	even
copper	dc.w	bplcon0,%11001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2981
	dc.w	diwstop,$29c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0,bpl2ptl
b2l	dc.w	0,bpl2pth
b2h	dc.w	0,bpl3ptl
b3l	dc.w	0,bpl3pth
b3h	dc.w	0
	dc.w	color00,$000
	dc.w	color01,$c90
	dc.w	color02,$bbb
	dc.w	color03,$000
	dc.w	color04,$b60
	dc.w	color05,$f40
	dc.w	color06,$c30
	dc.w	color07,$0ef
	dc.w	$ffff,$fffe
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
temp1	dc.l	0
temp2	dc.l	0
temp3	dc.l	0
scroll	dc.w	0
bstart	dc.l	0
base	dc.l	0
library	dc.b	'graphics.library',0,0
	even
ball1	incbin	source:bitmaps1/balls

; Mask for balls to use with blitter

ballmask
	dc.w	%0000111110000000,0
	dc.w	%0011111111100000,0
	dc.w	%0111111111110000,0
	dc.w	%0111111111110000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%0111111111110000,0
	dc.w	%0111111111110000,0
	dc.w	%0011111111100000,0
	dc.w	%0000111110000000,0,0,0,0,0,0

sines
	dc.w	0,1
	dc.w	210,2409
	dc.w	167,962
	dc.w	85,328
	dc.w	38,111
	dc.w	168,398
	dc.w	1,2
	dc.w	68,119
	dc.w	56,81
	dc.w	99,140
	dc.w	94,123
	dc.w	50,61
	dc.w	45,52
	dc.w	64,71
	dc.w	31,33
	dc.w	29,30
	dc.w	66,67
	dc.w	262,263
	dc.w	1,1

structs
	dc.l	25
	dc.b	50,63,0
	dc.b	50,9,0
	dc.b	40,63,1
	dc.b	40,9,1
	dc.b	30,63,0
	dc.b	30,9,0
	dc.b	20,63,1
	dc.b	20,9,1
	dc.b	10,63,0
	dc.b	10,9,0
	dc.b	50,54,0
	dc.b	40,54,1
	dc.b	30,54,0
	dc.b	20,54,1
	dc.b	10,54,0
	dc.b	0,0,1
	dc.b	10,18,0
	dc.b	20,18,1
	dc.b	30,18,0
	dc.b	40,18,1
	dc.b	50,18,0
	dc.b	10,36,0
	dc.b	20,36,1
	dc.b	30,36,0
	dc.b	40,36,1
	dc.b	50,36,0

	even
spare	dc.l	0
spare2	dc.l	0
spare3	dc.l	0
