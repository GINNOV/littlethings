;	opt	c-
	include hardware.i

; Some library functions:

OpenLibrary	=-552
CloseLibrary	=-414
AllocMem	=-198
FreeMem		=-210
Forbid		=-132
Permit		=-138

	move.l	4,a6
	lea	gfxname,a1	; Open Gfx library
	moveq.l	#0,d0		; Any version
	jsr	OpenLibrary(a6)
	move.l	d0,gfxbase	; Store its base
	move.l	#256*120,d0	; Reserve 5 bitplane space
	move.l	#2+(1<<16),d1	; Chip RAM
	jsr	AllocMem(a6)	; Reserve it
	tst.l	d0		; Check if available
	beq	quit		; If unavailable quit
	moveq.l	#2,d1		; d1 = no. of bitplanes -1
	lea	b1,a0		; a0 = place to store address of bpl 1
	lea	b1l,a1		; a1 = place in copper list to put pointers
dobpls	move.l	d0,(a0)+	; Store address in b1,b2,b3 or b4
	move.w	d0,(a1)		; Store address in copper list
	swap	d0
	move.w	d0,4(a1)
	swap	d0
	add.l	#256*40,d0	; Next bpl
	add.l	#8,a1		; Next part in copper list
	dbra	d1,dobpls

	jsr	Forbid(a6)	; No Multi-tasking

	lea	$dff000,a5

	bsr	vwait		; Switch off sprites
	move.w	#$20,dmacon(a5)
	move.w	#$8400,dmacon(a5)	; Give blitter priority

	move.l	#copper,cop1lch(a5)	; Strobe our copper list
	move.w	#0,copjmp1(a5)
	move.w	#0,$1fc(a5)
wait
	lea	Points,a0		; a0=address of points table
	lea	NewPoints,a1		; a1=address to put rotated points
	lea	Angles,a2		; a2=address of angles (Z, then Y then X)
	move.l	#NoOfPoints-1,d7	; d7=no. of points-1
	bsr	CalcPoints		; Calcuate new points

	lea	NewPoints,a0		; a0=address of rotated points
	move.l	#NoOfPoints-1,d7	; d7=no. of points-1
	bsr	SortPoints		; Sort points by Z axis

	tst.b	FirstOne		; Is this the first rotation?
	beq	.loop			; If so, we've got nowt to wipe
	move.l	#NoOfPoints-1,d7	; d7=no. of points-1
	bsr	ClearBalls		; Wipe the balls

.loop	move.b	#1,FirstOne		; Next time, we will wipe the balls
	lea	NewPoints,a0		; a0=address of rotated points
	move.l	#NoOfPoints-1,d7	; d7=no. of points-1
	bsr	DisplayBalls		; Display the balls

	lea	Angles,a0		; a0=address of angles
	lea	AngleIncs,a1		; a1=address of number to add to angles
	moveq.l	#2,d0			; 3 angles (-1 for dbra)
.loop1	move.w	(a1)+,d1		; d1=number to add to angle
	add.w	d1,(a0)			; Add it to the angle
	cmp.w	#360,(a0)		; Is new angle>359 ?
	blt	.loop2			; Is so, bring it within 0-359 range
	sub.w	#360,(a0)
.loop2	addq.l	#2,a0			; point a0 to next angle
	dbra	d0,.loop1		; increase (or decrease) other angles

	btst	#6,$bfe001		; LMB pressed?
	bne	wait

	move.w	#$8020,dmacon(a5)	; Switch on sprites

free	move.l	4,a6
	jsr	Permit(a6)	; Enable multi-tasking
	move.l	#256*120,d0	; 5 bitplanes space
	move.l	b1,a1		; Free the memory
	jsr	FreeMem(a6)
	move.l	gfxbase,a1	; Enter old copper list
	move.l	38(a1),cop1lch(a5)
	jmp	CloseLibrary(a6)	; And close the gfx library


vwait	cmp.b	#255,vhposr(a5)	; Wait for vertical blanking
	bne.s	vwait
quit	rts

bwait	btst	#14,dmaconr(a5)
	bne.s	bwait
	rts

******* Calculate x/y positions
;	Entry :	a0 = Table of original co-ord
;		a1 = Space for new table
;		a2 = Address of angles (Z,Y,X)
;		d7 = No. of points-1

CalcPoints:
	lea	SineTable,a3	; a2=address of sine table

; Calculate current X,Y and Z positions

CalcXYZ:
	move.w	(a0),d2		; d2=xpos
	move.w	2(a0),d3	; d3=ypos
	bsr	CalcNewPos
	move.w	d4,(a1)		; d4=new xpos
	move.w	d5,2(a1)	; d5=new ypos
	move.w	d4,d2		; d2=xpos
	move.w	4(a0),d3	; d3=zpos
	bsr	CalcNewPos
	move.w	d4,(a1)		; d4=new xpos
	move.w	d5,4(a1)	; d5=nw zpos
	move.w	d5,d2		; d2=zpos
	move.w	2(a1),d3	; d3=ypos
	bsr	CalcNewPos
	move.w	d4,4(a1)	; d4=new zpos
	move.w	d5,2(a1)	; d5=new ypos
	move.w	6(a0),6(a1)	; Copy colour from orig points to new ones
	addq.l	#8,a0		; a0=address of next original point
	addq.l	#8,a1		; a1=address of next rotated point
	subq.l	#6,a2		; Point a2 back to start of angles
	dbra	d7,CalcXYZ
	rts
CalcNewPos:
	move.w	(a2)+,d0	; Get angle from list
	ext.l	d0		; make it a long word
	lsl.l	d0		; Multiply by 2 (sine table in words)
	move.w	(a3,d0),d1	; d1=sine value for angle

; Cos(X) = Sin (90+X)
; All things added/subtracted are *2 since sine table is in words

	add.l	#180,d0		; Add 90 to angle
	cmp.l	#720,d0		; If angle>359, bring it within 0-359 range
	blt	.ok
	sub.l	#720,d0		; By subtracting 360 from it
.ok	move.w	(a3,d0),d0	; d0=cos value for angle

	move.l	d2,d4		; d4=d2
	move.l	d3,d5		; d5=d3
	muls	d0,d4		; d4=d4 * cos(X)
	muls	d1,d3		; d3=d3 * sin(X)
	sub.l	d3,d4		; Subtract d3 from d4 to get first value
	muls	d0,d5		; d5=d5 * cos(X)
	muls	d1,d2		; d2=d2 * sin(X)
	add.l	d2,d5		; Add d2 to d5 to get second value
	asr.l	#7,d4		; Divide each value by 16384 since each sine
	asr.l	#7,d4		; number was multiplied by this in the first
	asr.l	#7,d5		; place
	asr.l	#7,d5
	rts

******* Sort points by Z co-ord
;	Entry :	a0 = address of points
;		d7 = no. of points-1

; Sorted by a simple sort technique (don't know its offical name).  Take
; 1st value in list, and see if any values following it are smaller.  If
; so, swap the 1st value with smallest value.  Go to the second and do
; the same, the third, and so on so that when you get to the last value
; the list is in order.

; In this case the Z co-ord is the one we're interested in, but of course
; we need to swap all of the information for each point (X, Y, Z co-ords
; and colour)

SortPoints:
	subq.l	#1,d7	; On 1st sort, look at (no. of points-1) after 1st,
			; -1 for dbra
Sort1:
	move.l	d7,d6	; Keep d7 the same, use d6 instead
	move.l	a0,a1	; Ditto a0 and a1
	addq.l	#8,a1	; Start searching in entry after current one
	sub.l	a2,a2	; No smaller value found so far
	move.w	4(a0),d0	; d0=value to compare each entry with
.loop	cmp.w	4(a1),d0	; Is this entry<d0 ?
	ble	.ok		; Nope
	move.w	4(a1),d0	; d0=this entry
	move.l	a1,a2		; a2=address of this entry
.ok	addq.l	#8,a1		; Search others for smaller entry
	dbra	d6,.loop
	cmp.l	#0,a2		; Was a smaller value found?
	beq	.ok1		; Nope
	move.l	(a0),d0		; Swap first four bytes
	move.l	(a2),(a0)
	move.l	d0,(a2)+
	move.l	4(a0),d0	; Swap secound four bytes
	move.l	(a2),4(a0)
	move.l	d0,(a2)+
.ok1	addq.l	#8,a0		; a0=address of next entry to sort
	dbra	d7,Sort1	; sort other entries
	rts

******* Wipe all the balls
;	Entry :	d7=no. of balls-1

; The address of each ball has already been saved by the display ball routine
; so this routine just needs to wipe each one in turn

ClearBalls:
	lea	Addresses,a1		; a1=address of balls' addresses
	bsr	bwait			; Wait for blitter
	move.w	#$100,bltcon0(a5)	; Wipe D whatever
	move.w	#0,bltcon1(a5)
	move.w	#36,bltdmod(a5)
	bsr	vwait			; Wait for vertical blanking
.loop	move.l	(a1)+,d0		; d0=address of ball to clear
	moveq.l	#2,d1			; 3 bitplanes, -1 for dbra
.loop1	bsr	bwait			; Wait for blitter
	move.l	d0,bltdpth(a5)		; D=address of ball
	move.w	#15*64+2,bltsize(a5)	; Ball 15 lines high, max 2 words wide
	add.l	#256*40,d0		; address of ball in next bpl
	dbra	d1,.loop1		; Do other bitplanes
	dbra	d7,.loop		; Do other balls
	rts

******* Display the balls
;	Entry :	a0 = address of points
;		d7 = no. of balls -1

DisplayBalls:
	lea	Addresses,a1	; a1=address to store each ball's address
DisplayB1
	move.w	2(a0),d0	; d0=ypos
	add.w	#120,d0		; Add 128 (centre line), -8 (half ball's height)
	mulu	#40,d0		; No. of bytes on each line of screen
	clr.l	d1		; d1=xpos
	move.w	(a0),d1
	add.w	#152,d1		; Add 160 (centre pixel), -8 (half ball's width)
	divu	#16,d1		; Low word =xpos in words
				; High word=shift value for dbra
	lsl.w	d1		; d1=d1*2 (get xpos in bytes)
	add.w	d1,d0		; Add to ypos
	add.l	b1,d0		; Add start of bitplane
	move.l	d0,(a1)+	; Store address of ball for ClearBalls
	swap	d1		; Get shift value in low word
	lsl.l	#6,d1		; Shift left 12 times for blitter
	lsl.l	#6,d1
	move.w	d1,d3		; d3=bltcon1
	or.w	#%111111100010,d1	; d1=bltcon0 (standard cookie cut)
	move.w	6(a0),d2	; d2=ball colour
	mulu	#15*6,d2	; d2=d2*size of each ball
	add.l	#Balls,d2	; Add start of ball data
	bsr	bwait		; Wait for blitter
	move.w	d1,bltcon0(a5)	; Store values already worked out
	move.w	d3,bltcon1(a5)
	move.w	#$ffff,bltafwm(a5)	; No masks
	move.w	#$ffff,bltalwm(a5)
	move.w	#-2,bltamod(a5)		; Ball data only one word wide
	move.w	#0,bltbmod(a5)		; Mask 2 words wide (for shift value)
	move.w	#36,bltcmod(a5)		; Screen 20 words wide
	move.w	#36,bltdmod(a5)
	move.l	d2,bltapth(a5)		; A=address of ball data
	moveq.l	#2,d2			; d2=no. of bitplanes, -1 for dbra
.loop	bsr	bwait			; Wait for blitter
	move.l	#Mask,bltbpth(a5)	; B=ball mask
	move.l	d0,bltcpth(a5)		; C=address on screen
	move.l	d0,bltdpth(a5)		; D=C
	move.w	#15*64+2,bltsize(a5)	; Size of ball (1 word widere for shift)
	add.l	#256*40,d0		; Point d0 to next bpl
	dbra	d2,.loop		; Do other bitplanes
	add.l	#8,a0			; Point a0 to next ball's data
	dbra	d7,DisplayB1		; Do other balls
	rts

******* Sine table (Mark's)

SineTable:
	dc.w 0,286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516
	dc.w 4790,5063,5334,5604,5872,6138,6402,6664
	dc.w 6924,7182,7438,7692,7943,8192,8438,8682		
	dc.w 8923,9162,9397,9630,9860,10087,10311,10531
	dc.w 10749,10963,11174,11381,11585,11786,11982,12176
	dc.w 12365,12551,12733,12911,13085,13255,13421,13583
	dc.w 13741,13894,14044,14189,14330,14466,14598,14726
	dc.w 14849,14968,15082,15191,15296,15396,15491,15582
	dc.w 15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374
	dc.w 16382,16384
	dc.w 16382
	dc.w 16374,16362,16344,16322,16294,16262,16225,16182
	dc.w 16135,16083,16026,15964,15897,15826,15749,15668		
	dc.w 15582,15491,15396,15296,15191,15082,14967,14849
	dc.w 14726,14598,14466,14330,14189,14044,13894,13741		
	dc.w 13583,13421,13255,13085,12911,12733,12551,12365
	dc.w 12176,11982,11786,11585,11381,11174,10963,10749
	dc.w 10531,10311,10087,9860,9630,9397,9162,8923
	dc.w 8682,8438,8192,7943,7692,7438,7182,6924
	dc.w 6664,6402,6138,5872,5604,5334,5063,4790
	dc.w 4516,4240,3964,3686,3406,3126,2845,2563
	dc.w 2280,1997,1713,1428,1143,857,572,286,0
	dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682		
	dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	dc.w -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
	dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	dc.w -16382,-16384
	dc.w -16382
	dc.w -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
	dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668		
	dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
	dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741		
	dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

; Original position of each points

; Order is:	X,Y,Z,Colour (0=yellow, 1=green, 2=blue)

Points:
	dc.w	0,0,0,0
	dc.w	0,15,0,1
	dc.w	0,30,0,0
	dc.w	0,45,0,0
	dc.w	0,60,0,0
	dc.w	15,45,0,0
	dc.w	-15,45,0,0
	dc.w	15,30,0,2
	dc.w	-15,30,0,2
	dc.w	30,30,0,0
	dc.w	-30,30,0,0
	dc.w	30,15,0,2
	dc.w	-30,15,0,2
	dc.w	0,-15,0,1
	dc.w	0,-30,0,0
	dc.w	0,-45,0,1
	dc.w	0,-60,0,0
	dc.w	15,0,0,2
	dc.w	30,0,0,0
	dc.w	45,0,0,2
	dc.w	-15,0,0,2
	dc.w	-30,0,0,0
	dc.w	-45,0,0,2
	dc.w	0,0,-15,2
	dc.w	0,0,-30,1
	dc.w	0,0,15,2
	dc.w	0,0,30,1
NoOfPoints	=	(*-points)/8

NewPoints:
	ds.w	NoOfPoints*4

Addresses:
	ds.l	NoOfPoints

; Angles to rotate at

Angles:
ZAngle	dc.w	0
YAngle	dc.w	0
XAngle	dc.w	0

; Angles to add after each time structure is displayed

AngleIncs:
ZInc	dc.w	2
YInc	dc.w	1
XInc	dc.w	3

gfxbase	dc.l	0
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
b4	dc.l	0
b5	dc.l	0
gfxname	dc.b	'graphics.library',0
FirstOne
	dc.b	0
	even

	Section	ChipStuff,data_c

copper	dc.w	bplcon0,%011001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0,bpl2ptl
b2l	dc.w	0,bpl2pth
b2h	dc.w	0,bpl3ptl
b3l	dc.w	0,bpl3pth
b3h	dc.w	0
	dc.w	$0180,$0eca,$0182,$0000,$0184,$0039,$0186,$005b
	dc.w	$0188,$0eb0,$018a,$0ed5,$018c,$0080,$018e,$0496
	dc.w	$ffff,$fffe

Balls	incbin	VectorBalls
Mask	dc.w	%0000011111000000,0
	dc.w	%0001111111110000,0
	dc.w	%0011111111111000,0
	dc.w	%0111111111111100,0
	dc.w	%0111111111111100,0
	dc.w	%1111111111111110,0
	dc.w	%1111111111111110,0
	dc.w	%1111111111111110,0
	dc.w	%1111111111111110,0
	dc.w	%1111111111111110,0
	dc.w	%0111111111111100,0
	dc.w	%0111111111111100,0
	dc.w	%0011111111111000,0
	dc.w	%0001111111110000,0
	dc.w	%0000011111000000,0
