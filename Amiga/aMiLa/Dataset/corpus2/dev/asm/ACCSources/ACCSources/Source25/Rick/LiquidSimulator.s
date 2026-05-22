	opt	c-
	section	Treebeard,code
	include source:include/hardware.i

OpenLibrary	equ	-552
CloseLibrary	equ	-414
AllocMem	equ	-198
FreeMem		equ	-210
Forbid		equ	-132
Permit		equ	-138
AutoRequest	equ	-348

DEFDROPS	equ	1000
XORIGIN		equ	160
YORIGIN		equ	1

BLUEWATER	equ	$26c
REDWATER	equ	$c41
BLUEICE		equ	$ccf
REDICE		equ	$c68

STYLE		equ	2
; 0=normal blue only
; 1=blue and red together
; 2=blue and red seperate

***************************************************************************
;				SYSTEM ENTRY CODE
***************************************************************************

	move.w	#DEFDROPS,MaxDrops	; MaxDrops=Default Max Drops
	clr.w	NoOfDrops		; No water to start with
	clr.b	Moving			; Water has not been activated

	ifeq	Style-2			; If seperate waters
	 move.w	#DEFDROPS/2,ColourFlag	; ColourFlag=half no. of drops
	endc				; (counter used to choose colour)

; Reserve space for 4 bitplanes

	move.l	#256*40*2,d0	; Size of 2 bitplanes
	move.l	#1<<16+2,d1	; Clear Chip memory
	move.l	$4.w,a6		; Reserve it
	jsr	AllocMem(a6)
	move.l	d0,FirstBpl	; Save address of memory
	beq	Quit		; Quit if not enough

; Feed addresses of each bitplane into copper list

	move.w	d0,b1l		; Store low word of bpl 1
	swap	d0
	move.w	d0,b1h		; Store high word of bpl 1
	swap	d0
	add.l	#256*40,d0	; Next bpl
	move.w	d0,b2l
	swap	d0
	move.w	d0,b2h

	move.l	FirstBpl,d0
	add.l	#XORIGIN/8+YORIGIN*40,d0
	move.l	d0,BplOrig	; BplOrig=Address of water start

; Reserve memory for drops info

	move.w	MaxDrops,d0	; d0=Max no. of drops
	mulu	#DropLen,d0	; Multiply by length of drop's position data
	moveq.l	#0,d1		; Public memory
	jsr	AllocMem(a6)	; Reserve it
	move.l	d0,FirstDrop
	beq	Quit1
	jsr	Forbid(a6)

; Execute main program

	bsr	MainProgram

; Clean up

	move.l	$4.w,a6
	jsr	Permit(a6)

; Free Drops space

	move.w	MaxDrops,d0
	mulu	#DropLen,d0
	move.l	FirstDrop,a1
	jsr	FreeMem(a6)

; Open graphics library to get address of system copper list

	lea	GfxLib(pc),a1		; a1=gfx library
	moveq.l	#0,d0			; any version
	jsr	OpenLibrary(a6)		; Open it
	move.l	d0,a1			; a1=gfx base
	move.l	38(a1),cop1lch(a5)	; Put in old copper list
	move.w	#0,copjmp1(a5)		; Strobe it
	jsr	CloseLibrary(a6)	; Close library and quit
Quit1	move.l	FirstBpl,a1		; a1=First bitplane
	move.l	#256*40*2,d0		; Two bitplanes size
	jmp	FreeMem(a6)		; Free memory

***************************************************************************
;				INITIALISE
***************************************************************************

MainProgram:
	lea	$dff000,a5		; a5=pointer to hardware
	move.l	#Pointer,d0		; d0=address of pointer
	move.w	d0,s0l			; Put address in copper list
	swap	d0
	move.w	d0,s0h
	clr.l	MouseX			; Start pointer at top left
	move.w	joy0dat,Old0dat		; Get current mouse value
	bsr	VWait			; Wait for vertical blanking

	move.l	#copper,cop1lch(a5)
	move.w	#0,copjmp1(a5)

	move.w	#BLUEWATER,$184(a5)
	move.w	#REDWATER,$186(a5)

	move.b	#1,DelFlag
	clr.b	UDFlag
	clr.b	LRFlag
	move.l	$68.w,Old2+2	; Insert our key interrupt handler
	move.l	#New2,$68.w

; Draw border round side of screen

DrawBorder:
	move.l	FirstBpl,a0	; a0=start of bpl
	move.w	#255,d0		; d0=no. of lines high-1
.loop	or.b	#128,(a0)	; Set leftmost pixel of line
	or.b	#1,39(a0)	; Set rightmost pixel of line
	lea	40(a0),a0	; Next line
	dbra	d0,.loop

	move.l	FirstBpl,a0		; a0=start of bpl
	moveq.w	#9,d0			; d0=width in longwords-1
.loop1	move.l	#$ffffffff,255*40(a0)	; Draw border on top of screen
	move.l	#$ffffffff,(a0)+	; Ditto bottom
	dbra	d0,.loop1 

; Put the dot on the screen to show where the water springs from

	move.l	FirstBpl,a0
	or.b	#$80,XORIGIN/8+256*40(a0)


; Set Timer A in the CIAB port going in continuous mode.  This means we
; can read bit 0 of CIABTALO as a constantly changing register (makes it
; pretty random).

	move.b	#%10101,CIABCRA		; Toggle and continous modes + start

***************************************************************************
;				MAIN LOOP
***************************************************************************

Wait	move.b	$bfec01,d0	; d0=key press
	cmp.b	#$df,d0		; If 'Q' quit now
	beq	Quit
	cmp.b	#$b9,d0		; If 'F' freeze water
	beq	Freeze
	cmp.b	#$d7,d0		; If 'T' thaw water
	beq	Thaw
	cmp.b	#$d9,d0		; If 'R' reset water
	beq	Reset
	cmp.b	#$dd,d0		; If 'W' wipe screen
	beq	Wipe
	cmp.b	#$d1,d0		; If 'I' invert screen
	beq	Invert
	cmp.b	#$bd,d0		; If 'S'...
	bne.s	.loop
	tst.w	NoOfDrops
	bne.s	.loop
	move.w	#BLUEWATER,$184(a5)
	move.w	#REDWATER,$186(a5)
	move.b	#1,Moving	; start water moving

.loop	bsr	MouseMove	; Move mouse (outside interrupt)
	btst	#6,$bfe001	; If LMB pressed, plot a point
	beq.s	.loop1
	btst	#10,$16(a5)	; If RMB pressed...
	bne	.loop2

	move.w	MouseX,d0	; Plot a dot left
	subq.w	#1,d0
	beq	.NoPlot1
	move.w	MouseY,d1
	bsr	Plot
.NoPlot1
	move.w	MouseX,d0	; Plot a dot right
	addq.w	#1,d0
	cmp.w	#319,d0
	beq.s	.NoPlot2
	move.w	MouseY,d1
	bsr	Plot
.NoPlot2
	move.w	MouseX,d0	; Plot a dot above
	move.w	MouseY,d1
	subq.w	#1,d1
	beq.s	.NoPlot3
	bsr	Plot
.NoPlot3
	move.w	MouseX,d0	; Plot a dot below
	move.w	MouseY,d1
	addq.w	#1,d1
	cmp.w	#255,d1
	beq	Wait
	bsr	Plot

.loop1	move.w	MouseX,d0	; d0=X
	move.w	MouseY,d1	; d1=Y
	bsr	Plot		; Plot point
	bra	Wait		; And continue

.loop2	tst.b	Moving		; Has water started yet?
	beq	Wait		; No, loop back
	bra	MoveWater	; Move the water

Quit	move.l	Old2+2,$68.w
	rts

***************************************************************************
;				FREEZE WATER
***************************************************************************

Freeze	tst.w	NoOfDrops		; Can't freeze if no drops to do it!
	beq	Wait
	clr.b	Moving			; Stop the movement
	move.w	#BLUEICE,$184(a5)	; Change the water colours to their
	move.w	#REDICE,$186(a5)	; 'frozen' equivalents
	bra	Wait

***************************************************************************
;				THAW WATER
***************************************************************************

Thaw	move.w	NoOfDrops,d0		; d0=no. of drops
	beq	Wait			; If none, it was never frozen
	move.b	#1,Moving		; Moving again!
	move.w	#BLUEWATER,$184(a5)	; Re-enter unfrozen colours
	move.w	#REDWATER,$186(a5)
	bra	Wait

***************************************************************************
;				CLEAR WATER FROM SCREEN
***************************************************************************

; Go through each drop and delete it

Reset:
	move.w	NoOfDrops,d0		; d0=number of drops
	beq	Wait			; Quit if none to reset
	move.l	FirstDrop,a4		; a4=First drop
.loop	move.l	(a4),a0			; a0=Address of drop
	move.b	DropShift(a4),d1	; d1=bit number in a0
	addq.l	#DropLen,a4		; Go onto next drop
	btst	d1,256*40(a0)
	beq.s	.ok
	bclr	d1,(a0)			; Clear drop in both bitplanes
	bclr	d1,256*40(a0)
.ok	subq.w	#1,d0			; Do other drops
	bne.s	.loop
	clr.b	Moving			; Stop!
	clr.w	NoOfDrops		; No drops in existance
	ifeq	Style-2			; If seperate waters
	 move.w	#DEFDROPS/2,ColourFlag	; ColourFlag=half no. of drops
	endc				; (counter used to choose colour)
	bra	Wait

***************************************************************************
;				WIPE STRUCTURE
***************************************************************************

; Wipe screen

Wipe:
	move.l	FirstBpl,a0	; a0=start of first bitplane
	move.w	#256*20-1,d0	; d0=size of 2 bitplanes -1
.loop	clr.l	(a0)+		; Clear it!
	dbra	d0,.loop

; Redraw all the drops

Redraw:
	move.w	NoOfDrops,d0	; d0=number of drops
	beq	DrawBorder	; If none out, redraw screen border
	move.l	FirstDrop,a4	; a4=first drop
.loop	move.l	(a4)+,a0	; a0=address of drop on bitplane
	move.b	(a4)+,d1	; d1=bit number in byte pointed to by a0
	bset	d1,256*40(a0)	; Set bit in 2nd bpl
	btst	#0,(a4)+	; Test colour
	beq.s	.ok
	bset	d1,(a0)		; Clear/Set accordingly
	bra.s	.ok1
.ok	bclr	d1,(a0)
.ok1	subq.w	#1,d0		; Do other drops
	bne.s	.loop
	bra	DrawBorder	; Redraw border

***************************************************************************
;				INVERT SCREEN
***************************************************************************

; Invert the entire screen, then redraw the drops so their colour isn't
; changed (needed especially if it has been frozen)

Invert:
	cmp.b	#$d1,$bfec01	; Wait for I to be released
	beq.s	Invert
	move.l	FirstBpl,a0	; a0=start of first bitplane
	move.w	#256*10-1,d0	; Size of 2 bitplanes
.loop	not.l	(a0)+		; Invert longword
	dbra	d0,.loop	; Do rest
	bra.s	Redraw		; Redraw drops

***************************************************************************
;				WAIT ROUTINES
***************************************************************************

; Wait for vertical blanking

VWait:	btst	#0,vposr(a5)
	bne.s	VWait
	cmp.b	#$2c,vhposr(a5)
	bne.s	VWait
	rts

; Wait for the blitter to finish

BWait:	btst	#14,dmaconr(a5)
	bne.s	BWait
	rts

***************************************************************************
;			   WATER-MOVING ROUTINE
***************************************************************************

MoveWater:
	move.l	$6c.w,oldint+2		; Put mouse-controller in interrupt
	move.l	#Interrupt,$6c.w	; - don't care where mouse is.

; If possible, add another drop to the list

	move.w	NoOfDrops,d0	; d0=no. of drops
	cmp.w	MaxDrops,d0	; Running at maximum already?
	beq.s	NoNewDrop
	move.l	BplOrig,a0	; a0=place where drop would be put
	tst.b	(a0)		; Is pixel blank?
	bmi.s	NoNewDrop	; --nope
	tst.b	256*40(a0)
	bmi.s	NoNewDrop	; --again no
	mulu	#DropLen,d0	; multiply no of drops by length of drop info
	add.l	FirstDrop,d0	; Add start of list to get address of new drop
	move.l	d0,a4
	move.l	a0,(a4)		; Put address of drop's start in DropAddr
	move.b	#7,DropShift(a4)	; Start at leftmost pixel of byte

	ifeq	Style			; If normal water...
	 move.b	#0,DropFlags(a4)	; Colour is blue
	endc

	ifeq	Style-1			; If mixed water...
	 move.b	ColourFlag,DropFlags(a4)	; ColourFlag=colour
	 eor.b	#1,ColourFlag			; Change colour of next drop
	endc

	ifeq	Style-2			; If seperate water...
	 subq.w	#1,ColourFlag		; Subtract 1 from count
	 bmi.s	.loop			; If -ve it is red
	 move.b	#0,DropFlags(a4)	; If +ve it is blue
	 bra	.loop1
.loop	 move.b	#1,DropFlags(a4)
.loop1
	endc

	bset	#7,256*40(a0)		; Plot dot
	btst	#0,DropFlags(a4)	; If blue don't plot in 1st bpl
	beq.s	.ok			; (blue is colour 2)
	bset	#7,(a0)
.ok	addq.w	#1,NoOfDrops		; bump counter

; Now the main drop movement:

NoNewDrop:
	move.w	NoOfDrops,d7		; d7=no. of drops
	beq	Wait			; There aren't any!
	move.l	FirstDrop,a4		; a4=First drop
DoDrop	move.l	(a4),a0			; a0=address of first drop
	move.b	DropShift(a4),d0	; d0=bit no. in byte pointed to by a0
	btst	d0,256*40(a0)		; If drop has been covered, skip it
	bne.s	.ok
	btst	d0,(a0)
	bne	MoveOn
.ok	bclr	d0,(a0)			; Wipe droplet
	bclr	d0,256*40(a0)

; First try to go downwards...

	btst	d0,40(a0)	; Test pixel 1 down in first bpl
	bne.s	NoDown
	btst	d0,257*40(a0)	; Test pixel in second bpl
	bne.s	NoDown
	add.l	#40,(a4)	; Can go down-add width of screen to pointer
	bra.s	NextDrop	; Plot drop and move onto next

; Left and right movement.  a1/d1 are the address and bit no. of the drop if
; it moves left and a2/d2 are these values if it moves right.

NoDown:
	move.l	a0,a1	; a1=address of drop
	move.b	d0,d1	; d1=bit no.
	addq.b	#1,d1	; Move left in byte
	and.b	#7,d1	; Make it range 0-7
	bne.s	.ok	; If it =0 then we have moved left 1 byte
	subq.l	#1,a1	;  so subtract 1 from a1

.ok	move.l	a0,a2	; a2=address of drop
	move.b	d0,d2	; d2=bit no.
	subq.b	#1,d2	; Move right in byte
	bcc.s	.ok1	; If result is -1 then we have moved right 1 byte
	moveq.b	#7,d2	;  so make new bit no. 7
	addq.l	#1,a2	;  and move right 1 byte
.ok1	btst	d1,(a1)		; Can we move left?
	bne.s	NoLeft		; --nope
	btst	d1,256*40(a1)
	bne.s	NoLeft		; --nope
	btst	d2,(a2)		; Can we move right?
	bne.s	MoveLeft	; --no, move left
	btst	d2,256*40(a2)
	bne.s	MoveLeft	; --no, move left

; The drop is free to move left or right so use bit 0 of CIABTALO to decide
; for us

	btst	#0,CIABTALO	; Test bit of Timer A
	beq.s	MoveRight	; If clear, move right

; Move drop left

MoveLeft:
	move.l	a1,(a4)		; Save address and bit no. that have already
	move.b	d1,DropShift(a4)	; been calculated
	bra.s	NextDrop		; Display drop

; Can't move left, but check if we can move right

NoLeft:
	btst	d2,(a2)		; Can we move right?
	bne.s	NoRight		; --no
	btst	d2,256*40(a2)
	bne.s	NoRight		; --no

; Move droplet right

MoveRight:
	move.l	a2,(a4)		; The new address and bit no. have already
	move.b	d2,DropShift(a4)	; been worked out
	bra.s	NextDrop		; Display drop

; If blocked left and right, the water could move up

NoRight:
	btst	d0,-40(a0)	; Test pixel 1 up from drop
	bne.s	NextDrop
	btst	d0,255*40(a0)
	bne.s	NextDrop
	sub.l	#40,(a4)	; Can move up
NextDrop:
	move.l	(a4),a0			; a0=address of drop
	move.b	DropShift(a4),d0	; d0=bit no. in byte of drop
	bset	d0,256*40(a0)		; Set pixel in second bpl
	btst	#0,DropFlags(a4)	; If colour=3 then set it in first
	beq.s	MoveOn			;  bpl too
	bset	d0,(a0)
MoveOn	addq.l	#DropLen,a4		; Next drop
	subq.w	#1,d7			; Subtract 1 from count
	bne	DoDrop

FinishWater:
	move.l	oldint+2,$6c.w		; Restore old interrupt
	bra	Wait			; And go back to main loop

***************************************************************************
;				PLOT A POINT
***************************************************************************

; This plots a point at the specified position.  The colour of the dot
; is the number contained in DelFlag, which can be 0 or 1.

; d0=X Pos
; d1=Y Pos

Plot:	mulu	#40,d1		; d1=vertical offset into screen of dot
	move.w	d0,d2		; d2=horiz positional
	lsr.w	#3,d0		; d0=position in bytes
	add.w	d0,d1		; Add to offset
	add.l	FirstBpl,d1	; Add address of screen
	move.l	d1,a0		; Move into an address register
	not.w	d2		; Get bit no. from 7 (MSB) to 0 (LSB)
	bclr	d2,256*40(a0)	; Clear dot in second bpl
	tst.b	DelFlag		; Set/Clear dot in first bpl according to
	beq.s	.Clr		;  DelFlag
	bset	d2,(a0)
	rts
.Clr	bclr	d2,(a0)
.Next	rts

***************************************************************************
;			POINTER INTERRUPT ROUTINE
***************************************************************************
; LEVEL 3 INTERRUPT
; Controls mouse pointer - Much improved version

Interrupt:
	movem.l	d0-2/a0-1,-(sp)
	bsr	MouseMove
	movem.l	(sp)+,d0-2/a0-1
OldInt	jmp	$0
MouseMove:
	lea	Old0dat(pc),a0	; a0 points to old Joy0dat
	lea	Pointer,a1	; a1 points to mouse pointer

; Up/Down movement

	move.b	$bfec01,d2
	move.b	joy0dat+$dff000,d0	; d0=new mouse y pos
	move.b	(a0),d1		; d1=old mouse y pos
	move.b	d0,(a0)		; Save new y pos
	tst.b	LRFlag
	bne.s	.LeftRight
	sub.b	d1,d0		; Subtract old y pos
	beq	.LeftRight	; If not moved, look at left/right movement
	ext.w	d0		; Make it a long word
	add.w	MouseY,d0	; Add Mouse Y pos to movement
	cmp.w	#1,d0
	bge	.OkUp		; If pointer off top of screen...
	moveq.w	#1,d0		; make y pos 0
.OkUp	cmp.w	#254,d0		; If pointer off bottom of screen...
	ble	.OkDown		; make y pos 255
	move.w	#254,d0
.OkDown	move.w	d0,MouseY	; Save new y pos
	add.w	#$2c,d0		; Add raster line of screen start
	move.b	d0,(a1)		; Save least significant byte of y pos
	and.b	#$f9,3(a1)	; Mask out vertical MSBs in 3rd byte
	btst	#8,d0		; Save most significant bit of y pos
	beq	.DoEnd
	or.b	#4,3(a1)	; in bit 2 of control byte
.DoEnd	add.w	#14,d0		; Add height of sprite
	move.b	d0,2(a1)	; Save least significant byte of y end
	btst	#8,d0		; Save most significant bit of y end
	beq	.LeftRight
	or.b	#2,3(a1)	; In bit 1 of control byte

; Left/Right movement

.LeftRight
	move.b	Joy0dat+$dff001,d0	; d0=new mouse x pos
	move.b	1(a0),d1	; d1=old mouse x pos
	move.b	d0,1(a0)	; Save old x pos
	tst.b	UDFlag
	bne.s	EndInt
	sub.b	d1,d0		; Get left/right movement
	beq	EndInt		; Quit if none
	ext.w	d0		; Make movement a word
	add.w	MouseX,d0	; Add Mouse X pos to movement
	cmp.w	#1,d0
	bge	.OkLeft		; Keep it within 1-318 limit
	moveq.w	#1,d0
.OkLeft	cmp.w	#318,d0
	ble	.OkRight
	move.w	#318,d0
.OkRight
	move.w	d0,MouseX	; Save new mouse X
	and.b	#$fe,3(a1)	; Mask out LSB of x pos
	lsr.w	d0		; Divide by 2
	bcc	.ok
	or.b	#1,3(a1)	; Least significant bit of x pos
.ok	add.b	#$40,d0		; Add raster value of left edge of screen
	move.b	d0,1(a1)	; Save most significant byte of x pos
EndInt	rts

; LEVEL 2 INTERRUPT
; Handles DEL, right shift and direction keys

New2	move.l	d0,-(sp)
	move.b	$bfec01,d0	; d0=keypress
	cmp.b	#$3d,d0		; Is it a right shift press?
	beq.s	.ok		; Change delete status if so
	cmp.b	#$3c,d0		; Same for a right shift release
	beq.s	.ok
	cmp.b	#$73,d0		; and a DEL press
	bne.s	TestUD
.ok	eor.b	#1,DelFlag	; Toggle delete status
	eor.w	#$004e,sprcol	; Toggle mouse colour between blue and black
	bra.s	GotKey		; Key handled
TestUD	cmp.b	#$64,d0		; Is it an up/down press/release?-Stop Press!
	bcs.s	TestLR
	cmp.b	#$68,d0		; If >$68, it isn't a key we want
	bcc.s	GotKey
	and.b	#1,d0		; Mask out press/release bit
	move.b	d0,UDFlag	; Set UDFlag accordingly (0=release, 1=press)
	bra.s	GotKey
TestLR	cmp.b	#$60,d0		; Is it a left/right press or release
	bcs.s	GotKey
	and.b	#1,d0		; Again, mask out press/release bit
	move.b	d0,LRFlag	; And keep record in LRFlag
GotKey	move.l	(sp)+,d0
Old2	jmp	$0

***************************************************************************
;				VARIABLES
***************************************************************************

; Drop info - each drop has its individual copy of this

		rsreset
DropAddr	rs.l	1	; Address on bitplane of dot
DropShift	rs.b	1	; Bit number drop occupied (7 MSB to 0 LSB)
DropFlags	rs.b	1	; Flags (at moment just colour)
DropLen		rs.b	0

FirstBpl	dc.l	0	; First bitplane
BplOrig		dc.l	0	; Address of the water source
FirstDrop	dc.l	0	; Address of memory containing drop info
MaxDrops	dc.w	0	; Maximum number of drops
NoOfDrops	dc.w	0	; Current number of drops
MouseX		dc.w	0	; Mouse's X position
MouseY		dc.w	0	; Mouse's Y position
Old0dat		dc.w	0	; Old joy0dat
ColourFlag	dc.w	0	; Used for styles 1 and 2
Moving		dc.b	0	; 0=water not moving, 1=water moving
UDFlag		dc.b	0	; 1=Restrict mouse to Up/Down movement
LRFlag		dc.b	0	; 1=Restrict mouse to Left/Right movement
DelFlag		dc.b	0	; 0=Delete off, 1=Delete on
GfxLib		dc.b	'graphics.library',0

***************************************************************************
;				COPPER LIST
***************************************************************************

	Section	Copper,code_c

copper	dc.w	bplcon0,%010001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,$10
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
b2h	dc.w	0,spr0ptl
s0l	dc.w	0,spr0pth
s0h	dc.w	0
	dc.w	spr1ptl,0
	dc.w	spr1pth,0
	dc.w	spr2ptl,0
	dc.w	spr2pth,0
	dc.w	spr3ptl,0
	dc.w	spr3pth,0
	dc.w	spr4ptl,0
	dc.w	spr4pth,0
	dc.w	spr5ptl,0
	dc.w	spr5pth,0
	dc.w	spr6ptl,0
	dc.w	spr6pth,0
	dc.w	spr7ptl,0
	dc.w	spr7pth,0
	dc.w	$0180,$0000,$0182,$0ea4
	dc.w	$01a0,$0000,$01a2
sprcol	dc.w	$004e,$01a4,$003b,$01a6,$047d
	dc.w	$ffff,$fffe

***************************************************************************
;				GFX DATA
***************************************************************************

; Sprite pointer

Pointer	dc.l	0
	dc.w	$8000,$c000,$c000,$b000,$7000,$4e00,$7e00,$41e0
	dc.w	$3f80,$2040,$3f00,$2080,$3f00,$2080,$1f80,$1040
	dc.w	$1fc0,$1630,$19f0,$190c,$10f0,$1088,$00e0,$0090
	dc.w	$0040,$0060,$0040,$0040,$0000,$0000


