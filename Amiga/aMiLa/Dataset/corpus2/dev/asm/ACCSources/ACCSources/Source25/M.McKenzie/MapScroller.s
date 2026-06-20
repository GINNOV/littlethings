; Map routine by					Martin Mckenzie
;							2 Wardie Road
;							Easterhouse
;							Glasgow
;							G33 4NP
;
;
; This program uses 2 screens, both 320*288
; Firstly, the screen pointers are offset 32 lines down
; the visible screen, then a row of ten blocks (32*32) is
; blitted onto the top of this screen. The bpl pointers are
; then decremented by 1 line at a time for 32 lines,(so the screen
; appears to scroll downwards),then the visible screen is copied to
; the hidden screen. (The picture being offset down 32). The pointers
; are then changed to look at the hidden screen 32 lines down.
; The whole process will now be looped.
;
; Note: If you don't have FAST RAM, then you will need to modify all
; the SECTION commands. sorry!

; Removed _f from sections, MM.

	section	hardware,code		

	opt	c-,o+

	include	source:include/hardware.i		; Hardware offsets


ScreenWidth	equ	320
ScreenHeight	equ	288
Planes		equ	3
BobWidth	equ	48
BobHeight	equ	25

	lea	$dff000,a5		; Custom base

	move.l	4.w,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error
	
	jsr	-132(a6)		; Forbid

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************
; Offset view by 32 lines down (total height of screen=288 lines)

	move.l	#screenA+1280,d0	; Address of screen
	move.l	d0,b1			; Store address pointer
	add.l	#288*40,d0		; Get to next bitplane
	move.l	d0,b2			; Store address pointer
	add.l	#288*40,d0		; Get to next bitplane
	move.l	d0,b3			; Store address pointer
	bsr	Set_pointers

*****************************************************************************
;			  Set-Up DMA
*****************************************************************************

	move.w	dmaconr(A5),dmasave	; Save DMA settings
	move.w	intenar(A5),intensave	; Save INT settings
	move.w	intreqr(A5),intrqsave	; Save INT settings

DMA
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne.s	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne.s	.Wait2

	move.w	#$7FFF,intena(A5)
	move.w	#$20,dmacon(a5)		; Disable sprites

	move.w	#%0000111111110010,d6	; ABCD blit for bob blit
	move.w	#$0,d5			; Reset bltcon1

	jsr	GetSource		; Get the background data
	jsr	Blitter2		; Blit the bob

	lea	table,a3		; A3 points to address table
	lea	map,a6			; A6 points to game map
	move.w	#1,counter
	bsr	ten_blocks		; Blit the row of 10 blocks

SET_UP_INT
	move.l	$6C.w,level3save	; Save old int.
	move.l	#NEWINT,$6C.w		; Use my int.

	move.l	#Copperlist,cop1lch(a5)	; Insert new copper list
	move.w	#$0,copjmp1(a5)		; Run that copper list
	move.w	#%1100000000100000,intena(A5)

*****************************************************************************
;			Main Branching Routine
*****************************************************************************

WaitVBL
	btst	#6,$bfe001		; Test mouse button
	bne.s	WaitVBL			; Quit if its pressed

Quit	bra	CleanUp			; Clean-up system

************************************************************************
*		My Interrupt
************************************************************************

NEWINT
;	MOVEM.L	A0-A6/D0-D7,-(A7)

	jsr	Shift			; Shift the screen
	jsr	Joy1			; Test j/stick and move bob
	jsr	Blitter2		; Blit the bob

;	MOVEM.L	(A7)+,A0-A6/D0-D7
	move.w	#%0000000001110000,intreq(A5)
	rte

****************************************************************************
;		Screen switching
****************************************************************************
; Screen holds the address of the visible screen,
; Screen2 holds the address of the hidden screen.

swapscreens
	cmpi.b	#1,screenc		;Which screen is being shown?
	beq.s	s1			;screen 1
	move.l	#screenB,screen		;Address of second screen in screen
	move.l	#screenA,screen2	;Address of 2nd screen in screen2
	move.b	#1,screenc		;Screen 2 is being shown
	bra.s	continue
s1	move.l	#screenA,screen		;Address of first screen in screen
	move.l	#screenB,screen2	;Address of 2nd screen in screen2
	move.b	#0,screenc		;Screen 1 is being shown
continue		
	move.l	screen,d0		;Address of screen in d0
	move.l	d0,b1
	add.l	#288*40,d0		; Get to next bitplane
	move.l	d0,b2			; Store address pointer
	add.l	#288*40,d0		; Get to next bitplane
	move.l	d0,b3			; Store address pointer
	bsr.s	Set_pointers
	rts

*****************************************************************************
;			Set pointers
*****************************************************************************

Set_pointers
	move.l	b1,d0			; Address of plane 1
	move.w	d0,bpl1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bph1+2
	move.l	b2,d0			; Address of plane 2
	move.w	d0,bpl2+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bph2+2
	move.l	b3,d0			; Address of plane 2
	move.w	d0,bpl3+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bph3+2
	rts

************************************************************************
*		Shift Bpl Ptrs
************************************************************************
; This section will decrease the bpl pointers for 32
; lines, then copy the visible screen to the hidden.
Shift
	cmpi	#32,counter		; Have we scrolled 32 lines ?
	beq.s	fix_it			; Yes, now fix it

	bsr	clearsource		; Replace background graphic
	addq.w	#1,counter		; Increase counter
	sub.l	#40,b1			; Scroll down BPL1
	sub.l	#40,b2			; Scroll down BPL2
	sub.l	#40,b3			; Scroll down BPL3
	sub.l	#(screenwidth/8),offset	; Update bob position
	bsr	getsource		; Grab background data

	bsr.s	Set_pointers		; Set pointers in copper
	rts

fix_it	move.w	#1,counter		; Reset counterr
;	bsr	clearsource		; Replace background graphic
	add.l	#(screenwidth/8)*31,offset	; Update bob position
	bsr.s	MoveScr			; Move the screen
	bsr	getsource		; Grab background data
	rts

************************************************************************
*		Move Screen
************************************************************************
; This section will copy the visible screen onto the hidden
; screen, then swap the bpl pointers to the hidden screen
; and offset them 32 lines down. A new row of blocks will
; then be blitted to the screen.

MoveScr
	move.l	screen,a0		; Visible screen = source

	move.l	screen2,a2
	add.l	#1280,a2		; Point to end of hidden screen
	bsr	Move_scr		; Blit screen down 32 lines

	bsr	swapscreens

	move.l	screen,b1		; Plane 1
	add.l	#1280,b1		; Point to 32 lines down

	move.l	screen,b2		; Plane 2
	add.l	#12800,b2		; Point to 32 lines down

	move.l	screen,b3		; Plane 3
	add.l	#24320,b3		; Point to 32 lines down

;	bsr	Set_pointers		; Set pointers in copper

	bsr.s	Ten_blocks		; Blit a new row

	rts

*****************************************************************************
;			Blit Ten blocks
*****************************************************************************
; On entry :-	A6 points to map data (i.e. what block should be used)
;		A3 points to address list (i.e. the address of the blocks)
; This section will blit a row of ten blocks onto the top of
; the current screen. 

Ten_blocks
	move.w	(a6),d3			; Get block number into d3
	cmpi	#255,d3			; Is it 255?
	beq.s	Fix_Map			; Yes, fix it

	move.l	screen,a2		; Screen address
	move.w	#9,d3			; No. of blocks in row -1

tbl	move.w	(a6)+,d2		; Move block No. into D2
	move.l	(a3,d2),a0		; Move block address into A0
	bsr	blitter			; Blit the chosen block
	addq.l	#4,a2			; Point to next screen address
	dbra	d3,tbl			; Do all the blocks
	rts

Fix_Map	lea	map,a6			; Put map address in A6
	rts

*****************************************************************************
;			Table of addresses
*****************************************************************************
; These data statements point to the block addresses on the block
; screen. The block screen is 320*255. Each block is 32*32 pixels.

	even
Table	dc.l	block_screen+0		; block 1  (row 1)
	dc.l	block_screen+4		; block 2   "   "
	dc.l	block_screen+8		; block 3   "   "
	dc.l	block_screen+12		; block 4   "   "
	dc.l	block_screen+16		; block 5   "   "
	dc.l	block_screen+20		; block 6   "   "
	dc.l	block_screen+24		; block 7   "   "
	dc.l	block_screen+28		; block 8   "   "
	dc.l	block_screen+32		; block 9   "   "
	dc.l	block_screen+36		; block 10  "   "

	dc.l	block_screen+1280	; block 11  (row 2)
	dc.l	block_screen+1284	; block 12   "   "
	dc.l	block_screen+1288	; block 13   "   "
	dc.l	block_screen+1292	; block 14   "   "
	dc.l	block_screen+1296	; block 15   "   "
	dc.l	block_screen+1300	; block 16   "   "
	dc.l	block_screen+1304	; block 17   "   "
	dc.l	block_screen+1308	; block 18   "   "
	dc.l	block_screen+1312	; block 19   "   "
	dc.l	block_screen+1316	; block 20   "   "

	dc.l	block_screen+2560	; block 21  (row 3)
	dc.l	block_screen+2564	; block 22   "   "
	dc.l	block_screen+2568	; block 23   "   "
	dc.l	block_screen+2572	; block 24   "   "
	dc.l	block_screen+2576	; block 25   "   "
	dc.l	block_screen+2580	; block 26   "   "
	dc.l	block_screen+2584	; block 27   "   "
	dc.l	block_screen+2588	; block 28   "   "
	dc.l	block_screen+2592	; block 29   "   "
	dc.l	block_screen+2596	; block 30   "   "
	even

; The actual game level map data

Map	dc.w	48,48,40,44,48,48,48,48,72,76
	dc.w	48,48,48,48,48,48,48,48,32,36
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	0,4,48,48,8,12,12,72,76,48
	dc.w	48,48,24,48,48,48,48,32,36,48
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	48,48,52,56,60,48,48,48,48,48
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	48,20,48,48,48,48,48,48,20,48
	dc.w	48,48,48,48,48,8,0,4,48,48
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	48,48,24,48,48,48,48,48,48,48
	dc.w	48,48,48,48,20,48,48,48,48,48
	dc.w	48,16,48,48,48,48,48,24,48,48
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	48,48,48,48,48,48,48,48,48,48
	dc.w	255			; 255 signals the end of map

	even

*****************************************************************************
;			Blitter Routine
*****************************************************************************
; On entry, A0=Address of source data
;           A2=Address of destination area (screen)
;           (D1=Number of BitPlanes to Blit -1)
; This will blit the block onto the screen

Blitter	move.w	#2,d1			; No. of planes -1
	move.l	a2,a4			; Save register A2
lop	bsr.s	bltbusy			; Test for blit busy
	bsr.s	blt_main		; Do the blit
	dbra	d1,lop			; Do all the planes
	move.l	a4,a2			; Restore register A2
	rts

bltbusy	btst	#14,dmaconr(a5)		; Is blitter working?
	bne.s	bltbusy
	rts

blt_main
	move.l	a0,d0			; Address of source data
	move.w	d0,bltaptl(a5)		; Load source pointers
	swap	d0
	move.w	d0,bltapth(a5)

	move.l	a2,d0			; Address of destination
	move.w	d0,bltdptl(a5)		; Load destination pointers
	swap	d0
	move.w	d0,bltdpth(a5)

	move.w	#36,bltamod(a5)		; Source modulo
	move.w	#36,bltdmod(a5)		; Destination modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%0000100111110000,bltcon0(a5)	;straight A>D blit
	clr.w	bltcon1(a5)
	move.w	#%0000100000000010,bltsize(a5)	; A 32*32 pixel blit

	add.l	#11520,a2		; Point to next screen plane
	add.l	#10240,a0		; Point to next block plane
	rts

*****************************************************************************
;			Move screen
*****************************************************************************
; On entry, A0=Address of source data
;           A2=Address of destination area (screen)
;           (D1=Number of BitPlanes to Blit -1)
; This routine will copy the current screen onto the hidden screen
; (the destination address will be offsetted down 32 lines to allow
; for the next row of ten blocks to be blitted)

Move_scr
	move.w	#2,d1			; No. of planes -1
	move.l	a2,a4			; Save register A2
pol	bsr.s	bltbusy			; Test blitter busy
	bsr.s	main_blt		; Do the blit
	dbra	d1,pol			; Do all planes
	move.l	a4,a2			; Restore register A2
	rts

main_blt
	move.l	a0,d0			; Address of source data
	move.w	d0,bltaptl(a5)		; Load source pointers
	swap	d0
	move.w	d0,bltapth(a5)

	move.l	a2,d0			; Address of destination
	move.w	d0,bltdptl(a5)		; Load destination pointers
	swap	d0
	move.w	d0,bltdpth(a5)

	move.w	#0,bltamod(a5)		; Source modulo
	move.w	#0,bltdmod(a5)		; Destination modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%0000100111110000,bltcon0(a5)	; Straight A>D blit
	clr.w	bltcon1(a5)
	move.w	#%0100000000010100,bltsize(a5)	; A 320*256 pixel blit

	add.l	#11520,a2		; Point to next screen plane
	add.l	#11520,a0		; Point to next block plane
	rts

*****************************************************************************
;			       Clean Up
*****************************************************************************

CleanUp
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne.s	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne.s	.Wait2

	move.l	level3save,$6C.w	; Restore level3
	move.w	intensave,D7
	or.w	#$C000,D7
	move.w	D7,intena(A5)		; Restore intena
	move.w	intrqsave,D7
	bset	#$F,D7
	move.w	D7,intreq(A5)		; Restore intreq

	move.w	#$83e0,dmacon(a5)	; Enable sprite dma
	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
	move.l	4.w,a6			; Exec base
	move.l	gfxbase,a1
	jsr	-408(a6)		; Close library
	jsr	-138(a6)		; Permit
	moveq.l	#0,d0			; Keep CLI happy
Error	rts				; Bye Bye

*****************************************************************************
;			Joystick Routine
*****************************************************************************
; This section will test the joystick, and move the bob in
; the desired direction.

JOY1
	move.b	$dff00c,d7		; Get left/up movement
	beq.s	nolu			; No l/u movement if it =0, so skip all l/u routine

	btst	#1,d7			; Bit 1 is set if it is going left or left and up
	beq.s	up			; So if its clear, test for up

	move.w	d6,d4			; Bltcon values	
	and.w	#%1111000000000000,d4	; Get rid of lower 12bits
	cmpi.w	#%0000000000000000,d4	; End of barrel shift
	beq.s	.IncDest
	sub.w	#%0001000000000000,d6	; Increment A & B shift values
	sub.w	#%0001000000000000,d5	
	bra.s	up
.IncDest
	or.w	#%1111000000000000,d6	; Insert all shift values
	or.w	#%1111000000000000,d5	; Leave the rest alone
	bsr	ClearSource		; Replace background
	subq.l	#2,Offset		; Add 2 to the offset
	bsr	GetSource		; Get the background data

up	subq.b	#1,d7			; Take 1 from joystick position
	btst	#1,d7			; Now bit 1 is 0 if it is going up or up and left
	bne.s	nolu			; If it ain't, go to right/down movement

	bsr.s	scroll_u

nolu	move.b	$dff00d,d7		; Get right/down position
	beq.s	over			; If its 0, there's no movement so go away
	btst	#1,d7			; Bit 1 is set if joystick going right or right and down
	beq.s	down			; So if its clear, test for down

	move.w	d6,d4			; Bltcon values	
	and.w	#%1111000000000000,d4	; Get rid of lower 12bits
	cmpi.w	#%1111000000000000,d4	; End of barrel shift
	beq.s	.IncDest
	add.w	#%0001000000000000,d6	; Increment A & B shift values
	add.w	#%0001000000000000,d5	
	bra.s	down
.IncDest
	and.w	#%0000111111111111,d6
	and.w	#%0000111111111111,d5	; Scrub shift values (keep rest)
	bsr	ClearSource		; Replace background
	addq.l	#2,Offset		; Add 2 to the offset
	bsr	GetSource		; Get the background data

down	subq.b	#1,d7			; Take 1 from r/d position
	btst	#1,d7			; Is bit 1 clear
	bne.s	over			; No, then not going down, so quit
	bsr.s	scroll_d
over	rts

****************************************************************************
;		Scroll Bob
****************************************************************************
; Offset holds the current position of the main ship on
; the screen, So this needs to be modified whenever the
; screen is scrolled.

scroll_d
	bsr	clearsource		; Replace background
	add.l	#(screenwidth/8)*2,offset	; Update bob
	bsr	getsource		; Get background
	rts

scroll_u
	bsr	clearsource		; Replace background
	sub.l	#(screenwidth/8),offset	; Update bob
	bsr	getsource		; Get background
	rts

****************************************************************************
;		Blitter Operations
****************************************************************************
; Blit (cookie cut) the bob to the screen

Blitter2
	movem.l	A0-A6/D0-D7,-(A7)

	lea	Bob,a0			; A0=Address of bob
	lea	BobMask,a1		; A1=Mask
	lea	Backgr,a2		; A2=Saved background data
	move.l	#Screen,a3		; A3=Address of screen + offset
	move.l	(a3),a4
	add.l	Offset,a4
	move.l	a4,a3

	
	moveq.l	#(Planes-1),d0		; D0=Number of bitplanes-1
.BlitLoop
	bsr	BltBusy			; Check the blitter status
	bsr.s	.BlitBob		; Blit the bob	
	add.l	#(BobWidth/8)*BobHeight,a0	; Get to next bob plane
	add.l	#(BobWidth/8)*BobHeight,a2	; Get to next saved data plane
	add.l	#(Screenwidth/8)*ScreenHeight,a3	; Get to next screen plane
	dbra	d0,.BlitLoop		; Keep blitting them planes!
	movem.l	(A7)+,A0-A6/D0-D7
	rts

.BlitBob
	move.l	a0,bltapth(a5)		; A=bob data
	move.l	a1,bltbpth(a5)		; B=Mask data
	move.l	a2,bltcpth(a5)		; C=Saved background data
	move.l	a3,bltdpth(a5)		; D=Screen
	move.w	#$0,bltamod(a5)		; Clear A's modulo
	move.w	#$0,bltbmod(a5)		; Clear B's modulo
	move.w	#$0,bltcmod(a5)		; Clear C's modulo
	move.w	#(ScreenWidth-BobWidth)/8,bltdmod(a5)		; D modulo=20
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	d6,bltcon0(a5) 		; ABCD blit
	move.w	d5,bltcon1(a5)
	move.w	#%0000011001000011,bltsize(a5) ;48*25
	rts

; Copy the destination area into a safe place
GetSource
	movem.l	A0-A6/D0-D7,-(A7)

	move.l	#Screen,a0		; A0=Address of screen + offset
	move.l	(a0),a2
	add.l	offset,a2
	move.l	a2,a0

	lea	Backgr,a1		; Address of destination

	moveq.l	#(Planes-1),d0		; D0=number of bitplanes -1
.BlitLoop
	bsr	BltBusy			; Check blitter status
	bsr.s	.BlitBob		; Blit the bob
	add.l	#ScreenHeight*(ScreenWidth/8),a0	; Get to next screen plane
	add.l	#(BobWidth/8)*BobHeight,a1
	dbra	d0,.BlitLoop		; Keep blitting them planes!	
	movem.l	(A7)+,A0-A6/D0-D7
	rts

.BlitBob
	move.l	a0,bltapth(a5) 		; A=Screen
	move.l	a1,bltdpth(a5)		; D=Memory to hold data
	move.w	#(ScreenWidth-BobWidth)/8,bltamod(a5)		; A's modulo=20
	move.w	#$0,bltdmod(a5)		; D's modulo=0
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	#%0000100111110000,bltcon0(a5) ; A-D blit
	move.w	$0.w,bltcon1(a5)	; B's barrel shift
	move.w	#%0000011001000011,bltsize(a5) ;48*25
	rts

; Clear the bob from screen by replacing background
ClearSource
	movem.l	A0-A6/D0-D7,-(A7)

	lea	Backgr,a0		; Address of Source
	move.l	#Screen,a1		; A1=Address of screen + offset
	move.l	(a1),a2
	add.l	Offset,a2
	move.l	a2,a1

	moveq.l	#(Planes-1),d0		; D0=number of bitplanes -1
.BlitLoop
	bsr	BltBusy			; Check blitter status
	bsr.s	.BlitBob		; Blit the bob
	add.l	#ScreenHeight*(ScreenWidth/8),a1	; Get to next screen plane
	add.l	#(BobWidth/8)*BobHeight,a0
	dbra	d0,.BlitLoop		; Keep blitting them planes!	
	movem.l	(A7)+,A0-A6/D0-D7
	rts

.BlitBob
	move.l	a0,bltapth(a5) 		; A=Source
	move.l	a1,bltdpth(a5)		; D=screen
	move.w	#0,bltamod(a5)		; A's modulo=20
	move.w	#(ScreenWidth-BobWidth)/8,bltdmod(a5)		; D's modulo=0
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	#%0000100111110000,bltcon0(a5) ;A-D blit
	move.w	#$0,bltcon1(a5)
	move.w	#%0000011001000011,bltsize(a5) ;48*25
	rts

*****************************************************************************
;			Copper List
*****************************************************************************

	section	copper,data_c		; Chip data
Copperlist
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fetch stop
	dc.w	bplcon0,%0011001000000000 ; 3 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,$0		; No modulo (odd)
	dc.w	bpl2mod,$0		; No modulo (even)
	
	dc.w $2c09,$fffe
	
bph1	dc.w	bpl1pth,$0		; Bitplane pointers
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0

	dc.w	$180,$000,$182,$fb7	; Colours
	dc.w	$184,$407,$186,$b50
	dc.w	$188,$d60,$18a,$f82
	dc.w	$18c,$f94,$18e,$00a
	
	dc.w	$ffff,$fffe		; Wait

*****************************************************************************
;			     Variables
*****************************************************************************

	section	variables,data		; Fast
gfxname		dc.b	'graphics.library',0
screenc		dc.b	0		; Simple screen counter
		even
counter		dc.w	0
dmasave		dc.w	0
intensave	dc.w	0
intrqsave	dc.w	0

gfxbase		dc.l	0		; Space for gfx base address
b1		dc.l	0		; Bitplane pointers
b2		dc.l	0
b3		dc.l	0
level3save	dc.l	0
Screen		dc.l	screena		;Address of actual screen
Screen2		dc.l	screenb		;Address of hidden screen
Offset		dc.l	(ScreenWidth/8)*100	; Bob start position
		even

*************************
* Graphics		*
*************************

		section	gfxstuff,data_c

bob		incbin	'source:M.McKenzie/bitmaps/ship2.raw'
bobmask		incbin	'source:M.McKenzie/bitmaps/ship2.mask'
block_screen	incbin	"source:M.McKenzie/bitmaps/xen.raw"
Backgr		dcb.b	(BobWidth/8)*(BobHeight)*(Planes),0	; Space to save background
screenA		dcb.b	(ScreenHeight)*(ScreenWidth/8)*(planes),0		;Screen data
screenB 	dcb.b	(ScreenHeight)*(ScreenWidth/8)*(planes),0

		even

