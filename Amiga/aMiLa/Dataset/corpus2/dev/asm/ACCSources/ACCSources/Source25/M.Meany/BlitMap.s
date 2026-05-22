
; Experiment to see how long it takes to build a screen from blocks every VBL
;Also triggers and acknowledges a Copper interrupt.



RasterTiming	=	1	set = 1 to measure raster time

; variables used in game

		rsreset
sysINT		rs.l		1		system Interrupt requests
sysDMA		rs.l		1		system DMA settings
syscop		rs.l		1		addr of system Copper list

Level3		rs.l		1		adde of systems handler

X		rs.l		1		on screen X position
Y		rs.l		1		on screen Y position

pf_X		rs.l		1		playfield X scroll
pf_Y		rs.l		1		playfield Y scroll

Switch		rs.w		1		flag to signal switch
CurrentCop	rs.l		1		flag to indicate which list

vars_SIZEOF	rs.b		0		memory size

; Now equates used throught the code

ScrnDepth	=	4		depth of screen
ScrnWidth	=	80		40 bytes wide ( = 320 pixels )
ScrnHeight	=	512		256 lines high

; Set up screen modulo for interleaved playfield, allowing for horizontal
;scrolling

ScrnMod		=	ScrnWidth-42+ScrnWidth*(ScrnDepth-1)

BobXStep	=	2		x increment each frame
BobYStep	=	2		y increment each frame

; Macro to turn drive motors off

STOPDRIVES	macro
		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB
		endm

; Devpac3 opts only!

;		opt o1+,o2+,o4+,o5+,o6+,o10+,o11+,ow-


		include		followme:include/hardware.i

*****************************************************************************

Start		lea		GameVars,a4	a4->game variables memory

		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error		if so quit now !

		move.l		a4,a6		a6->game vars
		
		bsr		InitMap		convert to addresses

		bsr		PlayLevel	do it!

		move.l		a6,a4
		bsr		SysOn		enable system
		moveq.l		#0,d0		no DOS errors
.error		rts

*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5		a5->hardware

		move.w		DMACONR(a5),sysDMA(a4)	save DMA settings
		move.w		INTENAR(a5),sysINT(a4)	save interrupts
		move.l		$6c.w,Level3(a4)	save level 3 vector

; Open graphics library and stores address of systems Copper list for later.
;Library is then closed.

		lea		grafname,a1		a1->lib name
		moveq.l		#0,d0			any version
		move.l		$4.w,a6			a6->SysBase
		jsr		-$0228(a6)		OpenLibrary
		tst.l		d0			open ok?
		beq		.error			quit if not
		move.l		d0,a0			a6->GfxBase
		move.l		38(a0),syscop(a4)	save addr of sys list
		move.l		d0,a1			a1->Graphics base
		jsr		-$019e(a6)		CloseLibrary

; Opens DOS library to obtain address, then closes it again. We don't need
;it open as OS is about to be killed!

		lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		jsr		-$0228(a6)	OpenLibrary
		move.l		d0,_DOSBase	open ok?
		beq		.error		quit if not
		move.l		d0,a1		a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		move.l		$4.w,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01ef,DMACON(a5) kill all dma
		move.w		#SETIT!DMAEN!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Set up new Level 3 interrupt

		move.w		#$3fff,INTENA(a5)	stop interrupts
		move.l		#NewLevel3,$6c.w	address of server

; Init 1st Copper List for Game proper.

		lea		CopPlanes1,a0	where to fill in plane ptrs
		lea		Screen1,a1	raw data
		lea		CopColours1,a2	where to build colours
		bsr		PutPlanes

; Init 2nd Copper List for Game proper.

		lea		CopPlanes2,a0	where to fill in plane ptrs
		lea		Screen2,a1	raw data
		lea		CopColours2,a2	where to build colours
		bsr		PutPlanes

; Write bottom bitplane addresses into both Copper Lists.

		move.l		#(336/8)*64,d1	plane size
		moveq.l		#3,d2		num planes-1

		move.l		#BitPlane,d0
		lea		BotPlane1,a0
		lea		BotPlane2,a1

.BplLoop	swap		d0
		move.w		d0,(a0)
		move.w		d0,(a1)

		swap		d0
		move.w		d0,4(a0)
		move.w		d0,4(a1)
		add.l		d1,d0
		adda.l		#8,a0
		adda.l		#8,a1
		dbra		d2,.BplLoop

; Stop drives 

		STOPDRIVES			use macro

		moveq.l		#1,d0
.error		rts

*****************************************************************************

;--------------	Bring back the operating system

SysOn		move.l		syscop(a4),COP1LCH(a5)
		move.w		#0,COPJMP1(a5)	restart system list

		move.w		#SETIT!DMAEN,d0	set bit 15 of d0
		or.w		sysDMA(a4),d0	add DMA flags
		move.w		d0,DMACON(a5)	enable systems DMA

		move.w		#VERTB,INTENA(a5)	stop interrupt
		move.l		Level3(a4),$6c.w	reset system
		move.w		sysINT(a4),d0		get system bits
		or.w		#SETIT!INTEN,d0
		move.w		d0,INTENA(a5)	set old 

		move.l		$4.w,a6		a6->SysBase
		jsr		-$008A(a6)	Permit

		rts

*****************************************************************************

; This subroutine sets up planes for a 320x256x4 display and sets up the
;colour. Assumes raw data saved as CMAP BEHIND.

;Entry		a0->start of Copper List
;		a1->start of bitplane data
;		a2->position in list to store colour data.

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#ScrnDepth-1,d0	num of planes -1
		moveq.l		#ScrnWidth,d1	size of each bitplane
		move.l		a1,d2		d2=addr of 1st bitplane
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane
		dbra		d0,.PlaneLoop	repeat for all planes

		move.l		#$180,d0	color00 offset
		moveq.l		#(1<<ScrnDepth)-1,d1	colour counter
		lea		CMAP,a1 	a1->CMAP
.colourloop	move.w		d0,(a2)+	set colour register
		move.w		(a1)+,(a2)+	and the RGB value
		addq.l		#2,d0		bump colour register
		dbra		d1,.colourloop	for all 16 colours

		rts

*****************************************************************************

; Initialisation routine that resets everything ready for a new game!

; Note that DMA and interrupts should be OFF on entry

PlayLevel	
; Set up Game interrupt
		move.w		#0,Switch(a6)

		move.w		#$3fff,INTENA(a5)	stop interrupts
		move.l		#NewLevel3,$6c.w	address of server

; Set up Game DMA

		move.w		#$01ef,DMACON(a5) 	kill all dma
		move.w		#SETIT!DMAEN!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Strobe Games Copper List

		move.l		#CopList1,COP1LCH(a5)
		move.w		#0,COPJMP1(a5)

; Start the interrupt

		move.w		#SETIT!INTEN!VERTB,INTENA(a5)


.CopWait	move.w		INTREQR(a5),d0
		btst		#4,d0			Copper interrupt?
		beq.s		.mouse
		move.w		#COPER,INTREQ(a5)	yep! clear it
;		move.w		#$00f,COLOR00(a5)	and signal so.....

.mouse		btst		#6,CIAAPRA
		bne.s		.CopWait


		rts

*****************************************************************************

NewLevel3	move.w		#$2700,SR		priority to 7

		lea		$dff000,a5
		lea		GameVars,a6

		bsr.s		IntCode

.done		move.w		#VERTB,INTREQ(a5)	clear request
		rte

*****************************************************************************

; Level 3, vertical blank interrupt routine -- handles dbuffering

IntCode		

; Act on state of toggle 'Switch', 0=>Screen1 is visible & -1=>Screen2

		tst.w		Switch(a6)		which screen active
		bne.s		.DoScreen1		skip if Screen2

; Activate Screen2 

		move.l		#CopList2,COP1LCH(a5)	display Screen2
		move.w		#0,COPJMP1(a5)

; Rebuild the display

		lea		Screen1,a1
		bsr		RenewScreen

; Scroll playfield

		lea		CopPlanes1,a0
		lea		Screen1,a1
		bsr		SetScroll

; Update coordinates

		bsr		CalcXY			move it
		bra.s		.Done

; Activate Screen1

.DoScreen1	move.l		#CopList1,COP1LCH(a5)
		move.w		#0,COPJMP1(a5)


; Rebuild the display

		lea		Screen2,a1
		bsr		RenewScreen

; Scroll playfield

		lea		CopPlanes2,a0
		lea		Screen2,a1
		bsr.s		SetScroll


		bsr		CalcXY			move it

; Toggle flag 

.Done		not.w		Switch(a6)		signal interrup


		IFNE		RasterTiming

		move.w		#$fff,$dff180		for raster timing!

		ENDC

		rts					exit

*****************************************************************************

; a0->position in Copper List to write bitplane pointers
; a1->start of playfield

SetScroll	move.l		pf_X(a6),d0		x offset in pixels
		and.w		#$f,d0			pixel offset
		moveq.l		#15,d1
		sub.b		d0,d1			as required
		move.l		d1,d0
		asl.b		#4,d0			into high nibble
		or.b		d1,d0			and low nibble
		move.w		d0,-4(a0)		set BPLCON1

		move.l		pf_Y(a6),d1		Y
		and.w		#$f,d1
		mulu		#44*ScrnDepth,d1	line offset
		adda.l		d1,a1			a1->address if pf

		moveq.l		#44,d1		size of each bitplane
		move.l		a1,d2		d2=addr of 1st bitplane

		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane
		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane
		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane
		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane

		rts

*****************************************************************************

; Routine to rebuild visible portion of display. This may be slow, but will
;enable massive play areas and should allow game to run on a 1/2 meg Amiga.

; a1 = bitplane start address

RenewScreen	move.l		#Level,d0		map start
		move.l		pf_X(a6),d1		X
		asr.w		#4,d1
		asl.w		#2,d1			long offset
		add.l		d1,d0			add X offset
		move.l		pf_Y(a6),d1
		asr.w		#4,d1
		mulu		#4*40,d1		x block width
		add.w		d1,d0
		move.l		d0,a0			a0->1st block

		moveq.l		#0,d6			init X counter
		move.l		d6,d7			and Y counter
		move.l		d6,d5

.BBusy		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		.BBusy			if so wait

		move.l		#-1,BLTAFWM(a5)		mask values
		move.l		#$09f00000,BLTCON0(a5)	use A & D, D=A
		move.l		#42,BLTAMOD(a5)		modulo values
		move.w		#1!ScrnDepth<<10,d2	BLITSIZE
		moveq.l		#22,d3			block width

		move.w		#SETIT!BLTPRI,DMACON(a5)	Blitter Hog

; calculate source address

.BuildLoop	move.l		(a0)+,d0		get block addr

; calculate destination address

		move.l		d5,d1			line offset
		add.w		d6,d1
		add.w		d6,d1			add word offset
		add.l		a1,d1			add start address

; blit this block into screen 1

.BBusy1		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		.BBusy1			if so wait

		move.l		d0,BLTAPTH(a5)		A
		move.l		d1,BLTDPTH(a5)		D
		move.w		d2,BLTSIZE(a5)		size of blit

; bump counters and loop while still valid

		addq.w		#1,d6			bump X counter
		cmp.b		d3,d6			end of line?
		blt.s		.BuildLoop		loop back if not

		add.w		#16*44*ScrnDepth,d5
		moveq.l		#0,d6			reset x counter
		lea		18*4(a0),a0
		add.w		#16,d7			bump y counter
		cmp.w		#208,d7			end of screen
		blt.s		.BuildLoop		loop back if not

; All done, so return

		rts


*****************************************************************************

; Updates players bobs X and Y position according to condition of joystick.
;Also calls a routine that checks the validity of the move. Should be called
;during VBlank interrupt.

CalcXY		bsr		TestJoy

		tst.w		d2			any movement?
		beq		.NoGo

		move.l		X(a6),d6		on-screen X coord
		move.l		Y(a6),d7		on-screen Y coord

		moveq.l		#BobXStep,d4
		moveq.l		#BobYStep,d5

		btst		#0,d2			right?
		beq.s		.checkleft
		cmp.w		#304-BobXStep,d6
		bge.s		.checkdown
		add.w		d4,d6

.checkleft	btst		#1,d2			left?
		beq.s		.checkdown
		cmp.w		d4,d6
		blt.s		.checkdown
		sub.w		d4,d6

.checkdown	btst		#2,d2			down?
		beq.s		.checkup
		cmp.w		#237-BobYStep,d7
		bge.s		.done
		add.w		d5,d7

.checkup	btst		#3,d2			Up?
		beq.s		.done
		cmp.w		d5,d7
		blt.s		.done
		sub.w		d5,d7


; determined where we are moving to. See if playfield needs scrolling, if it
;does correct (X,Y) accordingly.

.done		cmp.w		#100,d7			scroll up?
		ble.s		.tryDown		no, see if down!

		btst		#2,d2			moving down?
		beq.s		.tryDown		no, skip

		cmp.w		#317,pf_Y+2(a6)		at the bottom?
		bge.s		.tryLeft		yes, then skip

		sub.w		d5,d7			correct on-screen Y
		add.w		d5,pf_Y+2(a6)		update scroll
		bra.s		.tryLeft		and skip

.tryDown	cmp.w		#80,d7			scroll down?
		bge.s		.tryLeft		skip if not

		btst		#3,d2			moving up?
		beq.s		.tryLeft		skip if not

		tst.w		pf_Y+2(a6)		at the top?
		beq.s		.tryLeft		yes, then skip

		add.w		d5,d7			correct on-screen Y
		sub.w		d5,pf_Y+2(a6)		update scroll

.tryLeft	cmp.w		#220,d6			scroll left?
		ble.s		.tryRight		no, see if right!

		btst		#0,d2			moving right?
		beq.s		.tryRight		no, skip

		cmp.w		#318,pf_X+2(a6)		at the bottom?
		bge.s		.setit			yes, then skip

		sub.w		d4,d6			correct on-screen Y
		add.w		d4,pf_X+2(a6)		update scroll
		bra.s		.setit			and skip

.tryRight	cmp.w		#100,d6			scroll right?
		bge.s		.setit			skip if not

		btst		#1,d2			moving left?
		beq.s		.setit			skip if not

		tst.w		pf_X+2(a6)		at the top?
		beq.s		.setit			yes, then skip

		add.w		d4,d6			correct on-screen Y
		sub.l		d4,pf_X(a6)		update scroll

.setit		move.l		d6,X(a6)		update position
		move.l		d7,Y(a6)		

		add.w		pf_Y+2(a6),d7
		add.w		pf_X+2(a6),d6

; Now set bobs image and mask

.NoGo		rts

*****************************************************************************

; Subroutine to read joystick movement in port 1. Returns a code in register
;d2 according to the following:

;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement

; Assumes a5 -> hardware registers ( ie a5 = $dff000 ).

; Corrupts d0, d1 and d2.

; M.Meany, Aug 91.


TestJoy		moveq.l		#0,d2			clear
		move.w		JOY1DAT(a5),d0		read stick

		btst		#1,d0			right ?
		beq.s		.test_left		if not jump!

		or.w		#1,d2			set right bit

.test_left	btst		#9,d0			left ?
		beq.s		.test_updown		if not jump

		or.w		#2,d2			set left bit

.test_updown	move.w		d0,d1			copy JOY1DAT
		lsr.w		#1,d1			shift u/d bits
		eor.w		d1,d0			exclusive or 'em
		btst		#0,d0			down ?
		beq.s		.test_down		if not jump

		or.w		#4,d2			set down bit

.test_down	btst		#8,d0			up ?
		beq.s		.no_joy			if not jump

		or.w		#8,d2			set up bit

.no_joy		rts


*****************************************************************************

; Maps start life as tile numbers. This routine converts a tile number into
;the address of the block graphics to allow for quick reference later.


InitMap		lea		Level,a0		a0->Map
		lea		Blocks,a1		a1->first block gfx
		move.l		#40*32-1,d1		num blocks -1

.loop		move.l		(a0),d0			get tile number
		mulu		#2*16*5,d0		x size of block
		add.l		a1,d0			form address
		move.l		d0,(a0)+		and save it!
		dbra		d1,.loop		for all blocks
		
		rts


*****************************************************************************
***************************** Data ******************************************
*****************************************************************************

grafname	dc.b		'graphics.library',0
		even

dosname		dc.b		'dos.library',0
		even

		even
Level		incbin		longmap00

CMAP		dc.w	$000,$A9B,$553,$600,$324,$436,$547,$557
		dc.w	$863,$EA0,$A97,$659,$77A,$213,$DCC,$FFF
		dc.w	$000,$D22,$000,$FDB,$444,$555,$666,$777
		dc.w	$888,$999,$AAA,$BBB,$CCC,$DDD,$00E,$F00


		section		variables,BSS

_DOSBase	ds.l		1

GameVars	ds.b		vars_SIZEOF


*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************

		section		cop,data_c

CopList1	dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$30		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPL1MOD,134		Modulos for interleaved
		dc.w BPL2MOD,134		bitplane data

CopColours1	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout1	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPLCON1,$ff		No horizontal offset

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes1	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w $ed05,$fffe
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$0200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,2			No modulo
		dc.w BPL2MOD,2			No modulo

		dc.w BPL1PTH			Plane pointers for 1 plane
BotPlane1	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH
		dc.w 0,BPL2PTL
		dc.w 0,BPL3PTH
		dc.w 0,BPL3PTL
		dc.w 0,BPL4PTH
		dc.w 0,BPL4PTL
		dc.w 0

		dc.w $ee05,$fffe
		dc.w BPLCON0,$4200

; Generate a copper interrupt at this point!

		dc.w INTREQ,SETIT!COPER

		dc.w	$ffff,$fffe		end of list

CopList2	dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$30		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPL1MOD,134		Modulos for interleaved
		dc.w BPL2MOD,134		bitplane data

CopColours2	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout2	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPLCON1,$ff			No horizontal offset

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes2	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w $ed05,$fffe
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$0200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,2			No modulo
		dc.w BPL2MOD,2			No modulo

		dc.w BPL1PTH			Plane pointers for 1 plane
BotPlane2	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH
		dc.w 0,BPL2PTL
		dc.w 0,BPL3PTH
		dc.w 0,BPL3PTL
		dc.w 0,BPL4PTH
		dc.w 0,BPL4PTL
		dc.w 0

		dc.w $ee05,$fffe
		dc.w BPLCON0,$4200

; Generate a copper interrupt at this point!

		dc.w INTREQ,SETIT!COPER

		dc.w	$ffff,$fffe		end of list

BitPlane	incbin		followme:m.meany/game/bottom.bm

; Using designer : 20 x 16 blocks, Depth = 4, saved Interleaved and Mask On.

Blocks		incbin		followme:m.meany/game/blocks.bm
		even

; BSS hunks used to minimise disk space occupied by program

; Followind CHIP BSS hunk used for screens, screen masks and bob background
;save areas
		section		screens,BSS_C

Screen1		ds.b		44*208*ScrnDepth
Screen2		ds.b		44*208*ScrnDepth


