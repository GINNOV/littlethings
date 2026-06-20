
; Basic hardware startup code. Sprites disables ( cheers Raistlin ! ).

; A 320x256x1 bitplane is set up with black and white colours.

; M.Meany, Aug 1991.


		incdir		sys:include/
		include		hardware.i

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
		move.l		d0,grafbase	open ok?
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

; Write bitplane addresses into Copper List.

		move.l		#BitPlane,d0
		lea		CopPlanes,a0
		move.w		d0,4(a0)
		swap		d0
		move.w		d0,(a0)

; Strobe our list

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Stop drives ( Thanks to Vandal of Killers for this hint )

		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB

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

		move.l		grafbase,a6
		jsr		-$01ce(a6)	DisownBlitter

		move.l		$4.w,a6		a6->SysBase
		move.l		grafbase,a1	a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		rts

*****************************************************************************
*****************************************************************************
*****************************************************************************

Main		bsr		Init	

; wait for beam to reach line 16

VBL		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		VBL		if not loop back

*****************************************************************************

**		MAIN PROGRAM GOES HERE

*****************************************************************************

		btst		#6,CIAAPRA	lefty ?
		bne.s		VBL		if not loop back

; program should shut down here....

		bsr		DeInit

		rts

*****************************************************************************
*****************************************************************************
**************************** Subroutines ************************************
*****************************************************************************
*****************************************************************************

*****************************************************************************

Init		rts

*****************************************************************************

DeInit		rts

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************



*****************************************************************************
*****************************************************************************
***************************** Data ******************************************
*****************************************************************************
*****************************************************************************


grafname	dc.b		'graphics.library',0
		even
grafbase	ds.l		1
sysDMA		ds.l		1
syscop		ds.l		1


*****************************************************************************
*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************
*****************************************************************************

		section		cop,data_c

CopList		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$1200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,0			No modulo

		dc.w COLOR00,$0000		black background
		dc.w COLOR01,$0fff		white foreground
 
		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes	dc.w 0,BPL1PTL          
		dc.w 0

		dc.w		$ffff,$fffe		end of list


BitPlane	ds.b		(320/8)*256
