
*****	Example 3:

*****		How to blit an interleaved bob into an interleaved playfield
*****		at any position. NOTE, does not blend bob into background for
*****		sake of simplicity!

ScrnDepth	=	4		depth of screen
ScrnWidth	=	40		40 bytes wide ( = 320 pixels )
ScrnHeight	=	256		256 lines high

; Macro to turn drive motors off

STOPDRIVES	macro
		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB
		endm



		include		source:include/hardware.i


Start		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error		if so quit now !
		bsr		Main		do da
		bsr		SysOn		enable system
.error		rts

*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5	a5->hardware

		move.w		DMACONR(a5),sysDMA	save DMA settings

		lea		grafname,a1	a1->lib name
		moveq.l		#0,d0		any version
		move.l		$4.w,a6		a6->SysBase
		jsr		-$0228(a6)	OpenLibrary
		move.l		d0,_GfxBase	open ok?
		beq		.error		quit if not
		move.l		d0,a6		a6->GfxBase
		move.l		38(a6),syscop	save addr of sys list

		jsr		-$01c8(a6)	OwnBlitter

		move.l		$4,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#SETIT!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Init Copper List.

		lea		CopPlanes,a0	where to fill in plane ptrs
		lea		Screen,a1	raw data
		lea		CopColours,a2	where to build colours
		bsr		PutPlanes

; Strobe Copper List

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Stop drives 

		STOPDRIVES			use macro

		moveq.l		#1,d0
.error		rts

*****************************************************************************

;--------------	Bring back the operating system

SysOn		move.l		syscop,COP1LCH(a5)
		clr.w		COPJMP1		restart system list

		move.w		#$8000,d0	set bit 15 of d0
		or.w		sysDMA,d0	add DMA flags
		move.w		d0,DMACON(a5)	enable systems DMA

		move.l		$4.w,a6		a6->SysBase
		jsr		-$008A(a6)	Permit

		move.l		_GfxBase,a6
		jsr		-$01ce(a6)	DisownBlitter

		move.l		$4.w,a6		a6->SysBase
		move.l		_GfxBase,a1	a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		rts

*****************************************************************************

; Blit interleaved bob at position (0,0)

; bob dimensions: 16x18x4.

; blitter window = (18x4) by 1
;		 = 72 by 1

Main		move.l		#150,d0		bobs X coordinate
		move.l		#128,d1		bobs Y coordinate
		move.l		#$09f0,d2	use A&D, A=D
		lea		Screen,a0	a0->playfield bitplane data

; Entry		d0.l=x
;		d1.l=y
;		d2.w=Blitter usage and minterm
;		a0->start of interleaved playfields bitplane data

		ror.l		#4,d0		x/16, MOD16(x) into high word
		asl.l		#1,d0		(x/16)*2
		mulu		#ScrnWidth*ScrnDepth,d1 y*w*d
		add.w		d0,d1		(x/16)*2 + y*w*d
		add.l		a0,d1		gfx + (x/16)*2 + y*w*d
		rol.l		#4,d0		MOD16(x)
		asl.w		#8,d0		into high nibble
		asl.w		#4,d0
		or.w		d0,d2		set A scroll value
		swap		d2		BLTCON0 into high word
		move.w		d0,d2		BLTCON1 into low word

; Exit		d1.l=destination address
;		d2.l=ready to write into BLTCON0

		
		move.l		#Bob,BLTAPTH(a5)	source address
		move.l		d1,BLTDPTH(a5)		destination address
		move.w		#-2,BLTAMOD(a5)		bob modulo
		move.w		#ScrnWidth-4,BLTDMOD(a5) screen modulo
		move.l		#$ffff0000,BLTAFWM(a5)	mask out 2nd word
		move.l		d2,BLTCON0(a5)		use A&D, D=A
		move.w		#72<<6!2,BLTSIZE(a5)	start blit

.loop		btst		#6,CIAAPRA
		bne.s		.loop

		rts

*****************************************************************************

; This subroutine sets up planes for an interleaved display

;Entry		a0->start of Copper List
;		a1->start of bitplane data
;		a2->position in list to store colour data.

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#ScrnDepth-1,d0	num of planes -1
		move.l		#ScrnWidth,d1	size of each bitplane
		move.l		a1,d2		d2=addr of 1st bitplane
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		add.l		d1,d2		point to next plane
		dbra		d0,.PlaneLoop	repeat for all planes

		move.l		#$180,d0	color00 offset
		moveq.l		#(1<<ScrnDepth)-1,d1	colour counter
		adda.l		#(ScrnWidth)*ScrnHeight*ScrnDepth,a1 a1->CMAP
.colourloop	move.w		d0,(a2)+	set colour register
		move.w		(a1)+,(a2)+	and the RGB value
		addq.l		#2,d0		bump colour register
		dbra		d1,.colourloop	for all 16 colours

		rts

*****************************************************************************
***************************** Data ******************************************
*****************************************************************************

grafname	dc.b		'graphics.library',0
		even
_GfxBase	ds.l		1
sysDMA		ds.l		1
syscop		ds.l		1



*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************

		section		cop,data_c

CopList		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,ScrnWidth*(ScrnDepth-1) Modulos for interleaved
		dc.w BPL2MOD,ScrnWidth*(ScrnDepth-1) bitplane data

CopColours	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w	$ffff,$fffe		end of list

Screen		incbin		'intscreen1.bm'

Bob		incbin		'N.bm'

