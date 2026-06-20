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
	move.l	#117*240,d0	; Reserve 5 bitplane space
	move.l	#2+(1<<16),d1	; Chip RAM
	jsr	AllocMem(a6)	; Reserve it
	move.l	d0,b1
	beq	quit		; If unavailable quit
	moveq.l	#2,d1		; d1 = no. of bitplanes -1
	lea	ba1,a0		; a0 = place to store address of bpl 1
	lea	b1l,a1		; a1 = place in copper list to put pointers
dobpls	move.l	d0,(a0)+	; Store address in b1,b2,b3 or b4
	move.w	d0,(a1)		; Store address in copper list
	swap	d0
	move.w	d0,4(a1)
	swap	d0
	add.l	#117*40,d0	; Next bpl
	add.l	#8,a1		; Next part in copper list
	dbra	d1,dobpls

	move.l	d0,bb1		; d0=start of Second screen's 1st bpl
	add.l	#117*40,d0
	move.l	d0,bb2		; d0=start of Second screen's 2nd bpl
	add.l	#117*40,d0
	move.l	d0,bb3		; d0=start of Second screen's 3rd bpl

	jsr	Forbid(a6)	; No Multi-tasking

	lea	$dff000,a5

	bsr	vwait		; Switch off sprites
	move.w	#$20,dmacon(a5)
	move.w	#$8400,dmacon(a5)	; Give blitter priority

	move.l	#copper,cop1lch(a5)	; Strobe our copper list
	move.w	#0,copjmp1(a5)
	move.w	#0,$1fc(A5)
ReStart:
	lea	Table,a6	; a6=address of Table of structures
StartNewSet
	move.w	16(a6),Counter	; Counter=no. of rotations to do
	moveq.l	#0,d0		; Turn all colours to black
	bsr	NewColour
	bsr	ClearScreen	; Clear Screen
	bsr	Rotate		; Rotate new structure to where old one was
	bsr	SwapScreens	; Swap screens
	clr.l	d0		; Start at fade stage 0
.loop	bsr	NewColour	; Set new colours
	addq.l	#1,d0		; New stage
	cmp.l	#17,d0		; At full colour yet?
	bne	.loop		; No, do others
	clr.w	Flag		; Clear handler flag (new handler)
	bra	Wait1
Wait
	bsr	vwait		; Wait for vertical blanking
	bsr	SwapScreens	; before swapping screens
Wait1
	bsr	ClearScreen	; Clear the screen

	bsr	Rotate		; Rotate the balls to new position

	tst.w	Return		; Should we rotate or not?
	beq	DontRotate	; No.
	lea	Angles,a0	; a0=address of angles
	move.l	8(a6),a1	; a1=address of number to add to angles
	moveq.l	#2,d0		; 3 angles (-1 for dbra)
.loop1	move.w	(a1)+,d1	; d1=number to add to angle
	add.w	d1,(a0)		; Add it to the angle
	cmp.w	#360,(a0)	; Is new angle>359 ?
	blt	.loop2		; Is so, bring it within 0-359 range
	sub.w	#360,(a0)
.loop2	addq.l	#2,a0		; point a0 to next angle
	dbra	d0,.loop1	; increase (or decrease) other angles
DontRotate:
	subq.w	#1,Counter	; Have we finished this rotation yet?
	bne	MouseWait	; No
	move.l	#16,d0		; Fade out - start at stage 16 (full colour)
FadeOut:
	bsr	NewColour	; Set new colours
	dbra	d0,FadeOut	; Do stages 15-0
	add.l	#18,a6		; a6=address of next structure's info in Table
	tst.l	(a6)		; Was it the last one?
	beq	ReStart		; If so, start from the beginning again
	bra	StartNewSet	; Start new rotation
MouseWait:
	btst	#6,$bfe001		; LMB pressed?
	bne	wait

	move.w	#$8020,dmacon(a5)	; Switch on sprites

free	move.l	4,a6
	jsr	Permit(a6)	; Enable multi-tasking
	move.l	#117*240,d0	; 5 bitplanes space
	move.l	ba1,a1		; Free the memory
	jsr	FreeMem(a6)
	move.l	gfxbase,a1	; Enter old copper list
	move.l	38(a1),cop1lch(a5)
	jmp	CloseLibrary(a6)	; And close the gfx library


vwait	cmp.b	#255,vhposr(a5)	; Wait for vertical blanking
	bne.s	vwait
quit	rts

bwait	btst	#14,dmaconr(a5)	; Wait for blitter to finish
	bne.s	bwait
	rts

****************************************************************************
;				SWAP SCREENS
****************************************************************************

SwapScreens:
	move.l	b1,d0		; d0=current screen
	cmp.l	ba1,d0		; Which screen are we using now?
	beq	UsingA
	lea	bb1,a0		; a0=address of bpl pointers to put in copper
	move.l	ba1,b1		; b1=new screen to draw balls on
	bra	SwitchScreens	; Put bpl pointers in copper list
UsingA	lea	ba1,a0		; a0=address of bpl pointers to put in copper
	move.l	bb1,b1		; b1=new screen to draw balls on
SwitchScreens:
	moveq.l	#2,d1		; d1=no. of bitplanes
	lea	b1l,a1		; a1=address of bitplanes in copper list
.loop	move.l	(a0)+,d0	; d0=address of next bpl
	move.w	d0,(a1)		; Put low word in bplXptl
	swap	d0
	move.w	d0,4(a1)	; Put high word in bplXpth
	addq.l	#8,a1		; a1=address of next set of pointers
	dbra	d1,.loop	; Do other bitplanes
	rts

****************************************************************************
;				ROTATE BALLS
****************************************************************************

Rotate:
	move.l	(a6),a0		; a0=address of points table
	lea	NewPoints,a1	; a1=address to put rotated points
	lea	Angles,a2	; a2=address of angles (Z, then Y then X)
	move.l	4(a6),d7	; d7=no. of points-1
	bsr	CalcPoints	; Calcuate new points
	move.l	12(a6),a0
	jsr	(a0)
	move.w	d0,Return
	lea	NewPoints,a0	; a0=address of rotated points
	move.l	4(a6),d7	; d7=no. of points-1
	bsr	SortPoints	; Sort points by Z axis

	lea	NewPoints,a0	; a0=address of rotated points
	move.l	4(a6),d7	; d7=no. of points-1
	bsr	DisplayBalls	; Display the balls
	rts

****************************************************************************
;			CALCULATE NEW POSITIONS
****************************************************************************
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
	move.w	d5,2(a1)	; d5=new ypos
	move.w	d4,d2		; d2=xpos
	move.w	4(a0),d3	; d3=zpos
	bsr	CalcNewPos
	move.w	d4,(a1)		; d4=new xpos
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

****************************************************************************
;			SORT POINTS BY Z CO-ORD
****************************************************************************
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

****************************************************************************
;				CLEAR THE SCREEN
****************************************************************************
;	Entry :	d7=no. of balls-1

; The address of each ball has already been saved by the display ball routine
; so this routine just needs to wipe each one in turn

ClearScreen:
	bsr	bwait
	move.l	b1,bltdpth(a5)
	move.w	#0,bltdmod(a5)
	move.w	#$100,bltcon0(a5)
	move.w	#0,bltcon1(a5)
	move.w	#117*64+60,bltsize(a5)
	rts

****************************************************************************
;			DISPLAY THE BALLS
****************************************************************************
;	Entry :	a0 = address of points
;		d7 = no. of balls -1

DisplayBalls:
	bsr	bwait
	move.w	#$ffff,bltafwm(a5)	; No masks
	move.w	#$ffff,bltalwm(a5)
	move.w	#-2,bltamod(a5)		; Ball data only one word wide
	move.w	#0,bltbmod(a5)		; Mask 2 words wide (for shift value)
	move.w	#36,bltcmod(a5)		; Screen 20 words wide
	move.w	#36,bltdmod(a5)
DisplayB1:
	moveq.l	#8,d4		; Default height
	clr.l	d5		; Default offset from top of ball
	move.w	2(a0),d0	; d0=ypos
	add.w	#59,d0		; Add 71 (centre line), -4 (half ball's height)
	bpl	NotOffTop	; Ok, its not off the top of screen
	cmp.w	#-8,d0		; Is some of it on screen?
	ble	NextBall	; No, go to next ball
	add.w	d0,d4		; Adjust height
	sub.w	d0,d5		; Adjust offset
	lsl.l	d5		; Multiply offset by 2 (1 word wide)
	clr.l	d0		; YPos=0
	bra	WithinBounds
NotOffTop:
	cmp.w	#110,d0		; Is it off bottom of screen?
	blt	WithinBounds	; No
	cmp.w	#117,d0		; All of it off screen?
	bge	NextBall	; Yep, do next ball
	add.w	#109,d4		; Adjust height
	sub.w	d0,d4
WithinBounds:
	mulu	#40,d0		; No. of bytes on each line of screen
	clr.l	d1		; d1=xpos
	move.w	(a0),d1
	add.w	#152,d1		; Add 160 (centre pixel), -8 (half ball's width)
	bmi	NextBall	; If off screen, don't display it
	cmp.w	#310,d1		; Right boundary of screen
	bge	NextBall	; Go to next one if off screen
	divu	#16,d1		; Low word =xpos in words
				; High word=shift value for dbra
	lsl.w	d1		; d1=d1*2 (get xpos in bytes)
	add.w	d1,d0		; Add to ypos
	
	add.l	b1,d0		; Add start of bitplane
	swap	d1		; Get shift value in low word
	lsl.l	#6,d1		; Shift left 12 times for blitter
	lsl.l	#6,d1
	move.w	d1,d3		; d3=bltcon1
	or.w	#%111111100010,d1	; d1=bltcon0 (standard cookie cut)
	move.w	6(a0),d2	; d2=ball colour
	mulu	#8*6,d2		; d2=d2*size of each ball
	add.l	#Balls,d2	; Add start of ball data
	add.l	d5,d2		; Add offset from top of ball
	lsl.l	d5		; Mask 2 words wide
	add.l	#Mask,d5	; d5=address of mask
	lsl.l	#6,d4		; Get height*64 (for bltsize)
	addq.l	#2,d4		; Add width in words
	bsr	bwait		; Wait for blitter
	move.w	d1,bltcon0(a5)	; Store values already worked out
	move.w	d3,bltcon1(a5)
	moveq.l	#2,d3		; d2=no. of bitplanes, -1 for dbra
.loop	bsr	bwait		; Wait for blitter
	move.l	d2,bltapth(a5)	; A=address of ball data
	move.l	d5,bltbpth(a5)	; B=ball mask
	move.l	d0,bltcpth(a5)	; C=address on screen
	move.l	d0,bltdpth(a5)	; D=C
	move.w	d4,bltsize(a5)	; Size of ball (1 word widere for shift)
	add.l	#16,d2
	add.l	#117*40,d0	; Point d0 to next bpl
	dbra	d3,.loop	; Do other bitplanes
NextBall
	add.l	#8,a0		; Point a0 to next ball's data
	dbra	d7,DisplayB1	; Do other balls
	rts

; Entry: d0=colour stage
; Go from d0=0 to d0=16 to fade in and d0=16 to d0=0 to fade out

NewColour:
	moveq.l	#7,d1		; No. of colours
	lea	MainColours,a0	; a0=table of colours
	lea	CopperColours+2,a1	; Address of colour settings in copper
.loop	bsr	vwait		; Wait for vertical blanking
.loop1	move.b	(a0)+,d3	; d3=Red component
	bsr	GetColour	; Alter it
	move.b	d3,(a1)+	; Save new red component
	move.b	(a0),d3		; d3=Low byte of colour
	lsr.b	#4,d3		; d3=Green component
	bsr	GetColour	; Alter it
	lsl.l	#4,d3		; Shift result to green component's position
	move.b	d3,d2		; d2=Green component
	move.b	(a0)+,d3	; d3=Blue component
	bsr	GetColour	; Alter it
	or.b	d3,d2		; OR it with green component
	move.b	d2,(a1)+	; Save low byte of new colour
	addq.l	#2,a1		; a1=address of next colour (skip colour reg)
	dbra	d1,.loop1	; Do other colours
	rts
GetColour
	and.w	#15,d3		; AND out irrelevant bits
	mulu	d0,d3		; Multiply by colour stage
	lsr.l	#4,d3		; And divide by 16
	rts

****************************************************************************
; 				ROTATION HANDLERS
****************************************************************************

; Bogus handler (just returns a non-zero, ie. lets it rotate)

NoHandler:
	moveq.l	#1,d0		; Rotate
	rts

; Complicated (and the effect isn't that good for it either)

; Variables used:
; 	FLAG	- 0=Normal mode, 1=Firing
;	FALLADD	- If falling, =amount to add to get gravity effect
;	BULLETY	- If falling, =amount bullet has fallen

; Remember that this routine is called when the points have been worked
; out and stored in the table NewPoints, but haven't been sorted or
; displayed

GunHandler:
	tst.w	Flag		; Are we firing a bullet?
	bne	FireGun		; If so, do bullet handler
	clr.l	d0		; d0=counter
	move.w	Counter,d0
	divu	#100,d0		; Start bullet every 100 counts
	swap	d0		; So is remainder 0?
	tst.w	d0
	bne	DoneGun		; Nope?
	move.w	#1,Flag		; If so, time to start firing
FireGun	lea	NewPoints+(Bullet-GunBalls),a1	; a1=address of bullet
				; in Newpoints table
	subq.w	#8,Bullet	; move bullet left 4 (out of barrel)
	tst.w	BulletY		; Are we falling?
	beq	.ok		; Nope
	addq.w	#1,FallAdd	; Fall 1 extra this time
	move.w	FallAdd,d0	; Add FallAdd to BulletY
	lsr.w	d0
	add.w	d0,BulletY
	move.w	BulletY,d0	; d0=BulletY

; This finds out which angle is closest to 90°.  We want to know this because
; the ball should appear to fall slower if it has been fired away from the
; screen.  To decide how far it does fall, the angle furthest from 90° is
; taken as its inclination (only an approximation - no mathematical basis
; for it)

	move.w	#90,d1		; d1=90-XAngle
	move.w	d1,d2		; d2=90-YAngle
	sub.w	XAngle,d1
	sub.w	YAngle,d2
	cmp.w	d1,d2		; If YAngle is closer, use XAngle as angle
	bgt	.UseX
	clr.l	d1		; else use YAngle
	move.w	YAngle,d2
	bra	.ok1
.UseX	clr.l	d1
	move.w	XAngle,d2
.ok1	lsl.l	d1		; Get angle*2 (Sinetable in words)
	lea	SineTable,a0	; d1=sine value
	move.w	(a0,d1),d1

; We want to multiply the Fall (d0) by a number between 0-1, 0 if -90° and
; 1 if +90°.  This is [Sin(X)+1]/2.  However, since sine values in table
; are *16384, it is treated as [Sin(X)+16384]/(16384*2).

	add.l	#16384,d1	; d1=Sin(X)+16384
	mulu	d1,d0		; Multiply Fall Value by d1
	asr.l	#8,d0		; d1=New fall value/16384/2 (>>15)
	asr.l	#7,d0
	add.w	d0,2(a1)	; Add it to current Y value for bullet
	cmp.w	#58,2(a1)	; Off bottom of screen?
	bgt	StopFire	; Yes, put bullet back in barrel, etc.
	bra	GunStop		; No, don't rotate yet
.ok	moveq.l	#2,d0		; Get X²+Y²+Z² and see if its more than 110²
	clr.l	d1		; d1=Total value
.loop	move.w	(a1),d2		; d2=X,Y or Z value
	muls	(a1)+,d2	; Square it
	add.l	d2,d1		; Add it to total value
	dbra	d0,.loop	; Do Y and Z
	cmp.w	#12100,d1	; Is result>110²?
	bge	StartFall	; Yes, start the ball falling.
GunStop:
	addq.w	#1,Counter	; Freeze counter - is subracted by 1 every time
	clr.l	d0		; Don't rotate them next time
	rts
StartFall:
	move.w	#1,BulletY	; Fall by 1
	move.w	#1,FallAdd	; Set fall counter to 1
	bra	GunStop		; Don't rotate
StopFire:
	clr.w	Bullet		; Reset Bullet's X value (only one that's changed)
	clr.w	Flag		; Not firing now
	clr.w	FallAdd		; Not falling now
	clr.w	BulletY		; Not falling now
DoneGun:
	moveq.l	#1,d0		; Can rotate them next time
	rts
	

****************************************************************************
;			 SINE TABLE (Mark's)
****************************************************************************

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

****************************************************************************
;				BALL STRUCTURES
****************************************************************************

; Original position of each point

; XPOS, YPOS, ZPOS and Colour

TRBalls:
	dc.w	0,0,0,2
	dc.w	8,0,0,2
	dc.w	16,0,0,2
	dc.w	-8,0,0,2
	dc.w	-16,0,0,2
	dc.w	0,0,8,2
	dc.w	0,0,16,2
	dc.w	0,0,-8,2
	dc.w	0,0,-16,2
	dc.w	0,0,-24,1
	dc.w	0,8,-24,1
	dc.w	0,16,-24,1
	dc.w	0,-8,-24,1
	dc.w	0,-16,-24,1
	dc.w	-8,-16,-24,1
	dc.w	-16,-16,-24,1
	dc.w	8,-16,-24,1
	dc.w	16,-16,-24,1
	dc.w	0,16,24,1
	dc.w	0,8,24,1
	dc.w	0,0,24,1
	dc.w	0,-8,24,1
	dc.w	0,-16,24,1
	dc.w	-8,-16,24,1
	dc.w	-16,-16,24,1
	dc.w	8,-16,24,1
	dc.w	16,-16,24,1
	dc.w	24,-4,13,0
	dc.w	24,0,8,0
	dc.w	24,0,0,0
	dc.w	24,0,-8,0
	dc.w	24,-8,-8,0
	dc.w	24,-16,-8,0
	dc.w	24,-16,0,0
	dc.w	24,-16,8,0
	dc.w	24,-12,13,0
	dc.w	24,8,-8,0
	dc.w	24,16,-8,0
	dc.w	24,8,10,0
	dc.w	24,16,10,0
	dc.w	-24,-4,13,0
	dc.w	-24,0,8,0
	dc.w	-24,0,0,0
	dc.w	-24,0,-8,0
	dc.w	-24,-8,-8,0
	dc.w	-24,-16,-8,0
	dc.w	-24,-16,0,0
	dc.w	-24,-16,8,0
	dc.w	-24,-12,13,0
	dc.w	-24,8,-8,0
	dc.w	-24,16,-8,0
	dc.w	-24,8,10,0
	dc.w	-24,16,10,0

TRPoints	=	(*-TRBalls)/8

GunBalls:
	dc.w	0,-8,0,0
	dc.w	0,8,0,0
	dc.w	0,-4,7,0
	dc.w	0,4,7,0
	dc.w	0,-4,-7,0
	dc.w	0,4,-7,0
	dc.w	-8,-8,0,0
	dc.w	-8,8,0,0
	dc.w	-8,-4,7,0
	dc.w	-8,4,7,0
	dc.w	-8,-4,-7,0
	dc.w	-8,4,-7,0
	dc.w	-16,-8,0,0
	dc.w	-16,8,0,0
	dc.w	-16,-4,7,0
	dc.w	-16,4,7,0
	dc.w	-16,-4,-7,0
	dc.w	-16,4,-7,0
	dc.w	-24,-8,0,0
	dc.w	-24,8,0,0
	dc.w	-24,-4,7,0
	dc.w	-24,4,7,0
	dc.w	-24,-4,-7,0
	dc.w	-24,4,-7,0
	dc.w	8,-8,0,0
	dc.w	8,8,0,0
	dc.w	8,-4,7,0
	dc.w	8,4,7,0
	dc.w	8,-4,-7,0
	dc.w	8,4,-7,0
	dc.w	16,-8,0,0
	dc.w	16,8,0,0
	dc.w	16,-4,7,0
	dc.w	16,4,7,0
	dc.w	16,-4,-7,0
	dc.w	16,4,-7,0
	dc.w	24,-8,0,1
	dc.w	24,8,0,1
	dc.w	24,-4,7,1
	dc.w	24,4,7,1
	dc.w	24,-4,-7,1
	dc.w	24,4,-7,1
	dc.w	24,0,0,1
	dc.w	32,-8,0,1
	dc.w	32,8,0,1
	dc.w	32,-4,7,1
	dc.w	32,4,7,1
	dc.w	32,-4,-7,1
	dc.w	32,4,-7,1
	dc.w	32,0,0,1
	dc.w	39,-4,-4,1
	dc.w	39,-4,4,1
	dc.w	39,4,-4,1
	dc.w	39,4,4,1
	dc.w	39,12,-4,1
	dc.w	39,12,4,1
	dc.w	31,12,-4,1
	dc.w	31,12,4,1
	dc.w	39,18,0,1
	dc.w	31,18,0,1
	dc.w	46,2,0,1
	dc.w	46,10,0,1
	dc.w	46,18,0,1
	dc.w	46,26,0,1
	dc.w	38,26,0,1
	dc.w	23,18,0,2
	dc.w	15,18,0,2
	dc.w	11,12,0,2
Bullet:
	dc.w	0,0,0,2

GunPoints	=	(*-GunBalls)/8

; Place to put rotated points

NewPoints:
	ds.w	4*GunPoints


; Angles to rotate at

Angles:
ZAngle	dc.w	0
YAngle	dc.w	0
XAngle	dc.w	0

; Angles to add after each time structure is displayed

AngleIncs1:
	dc.w	1
	dc.w	4
	dc.w	5

AngleIncs2:
	dc.w	3
	dc.w	1
	dc.w	2

AngleIncs3:
	dc.w	2
	dc.w	5
	dc.w	1
AngleIncs4:
	dc.w	3
	dc.w	4
	dc.w	5

; Table of info on each screen:

; Address of structure, no. of points-1, Address of AngleInc table,
; Address of handler and no. of times to rotate (word)

Table:
	dc.l	GunBalls,GunPoints-1,AngleIncs3,GunHandler
	dc.w	550
	dc.l	TRBalls,TRPoints-1,AngleIncs4,NoHandler
	dc.w	400
	dc.l	0

gfxbase	dc.l	0
b1	dc.l	0
ba1	dc.l	0
ba2	dc.l	0
ba3	dc.l	0
bb1	dc.l	0
bb2	dc.l	0
bb3	dc.l	0
Counter	dc.w	0
Flag	dc.w	0
Return	dc.w	0
FallAdd	dc.w	0
BulletY	dc.w	0
gfxname	dc.b	'graphics.library',0
	even

****************************************************************************
;				COPPER LIST
****************************************************************************

	Section	ChipStuff,data_c

; $26,$138,$25c

copper	dc.w	bplcon0,%011001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$5e81
	dc.w	diwstop,$d3c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0,bpl2ptl
b2l	dc.w	0,bpl2pth
b2h	dc.w	0,bpl3ptl
b3l	dc.w	0,bpl3pth
b3h	dc.w	0
	dc.w	$180,0
	dc.w	$5801,$fffe,$180,$26
	dc.w	$5901,$fffe,$180,$139
	dc.w	$5a01,$fffe,$180,$25c
	dc.w	$5c01,$fffe,$180,$139
	dc.w	$5d01,$fffe,$180,$26
	dc.w	$5e01,$fffe

; Ignore the colours values in the copper list, they are never used

CopperColours
	dc.w	$0180,$0555,$0182,$0000,$0184,$0039,$0186,$005b
	dc.w	$0188,$0eb0,$018a,$0ed5,$018c,$0080,$018e,$0496

	dc.w	$d301,$fffe,$180,$26
	dc.w	$d401,$fffe,$180,$139
	dc.w	$d501,$fffe,$180,$25c
	dc.w	$d701,$fffe,$180,$139
	dc.w	$d801,$fffe,$180,$26
	dc.w	$d901,$fffe,$180,0

	dc.w	$ffff,$fffe

; This table contains the real colours

MainColours
	dc.w	$0777,$0000,$0039,$005b
	dc.w	$0eb0,$0ed5,$0080,$0496

****************************************************************************
;				MASKS AND BALLS
****************************************************************************

Balls	incbin	VectorBalls1
Mask	dc.w	%0011110000000000,0
	dc.w	%0111111000000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%0111111000000000,0
	dc.w	%0011110000000000,0
