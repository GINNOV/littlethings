
; A working Copper list program. Cop_eg1.s

		incdir		df1:include/
		include		hardware.i
		include		colours.i

		bsr		SysOff		disable system, set a5
		bsr		Main		do da
		bsr		SysOn		enable system
		rts

Main		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#$81C0,DMACON(a5) enable copper,bpl,blit

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

;loop initalisation

		move.b		#$78,d5		initial y pos
		move.b		#1,d6		step size
		lea		WaitPos,a4	a4->Copper Wait command

; wait for beam to reach line 16

VBL		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		VBL		if not loop back


		btst		#6,CIAAPRA	lefty ?
		bne.s		VBL		if not loop back

; program should shut down here....

		rts

*****************************************************************************
*****************************************************************************
**************************** Subroutines ************************************
*****************************************************************************
*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5	a5->hardware

		move.w		DMACONR(a5),sysDMA	save DMA settings

		lea		grafname,a1	a1->lib name
		moveq.l		#0,d0		any version
		move.l		$4.w,a6		a6->SysBase
		jsr		-$0228(a6)	OpenLibrary
		tst.l		d0		open ok?
		beq		.error		quit if not
		move.l		d0,a0		a0->GfxBase
		move.l		38(a0),syscop	save addr of sys list
		move.l		d0,a1		a1->GfxBase
		jsr		-$019E(a6)	CloseLibrary		

		jsr		-$0084(a6)	Forbid

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

		rts


*****************************************************************************
*****************************************************************************
***************************** Data ******************************************
*****************************************************************************
*****************************************************************************


grafname	dc.b		'graphics.library',0
		even
sysDMA		ds.l		1
syscop		ds.l		1


*****************************************************************************
*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************
*****************************************************************************

		section		cop,data_c

CopList		dc.w		COLOR00,black
WaitPos		dc.w		$7801,$fffe
		dc.w		COLOR00,white
		dc.w		$ffff,$fffe

