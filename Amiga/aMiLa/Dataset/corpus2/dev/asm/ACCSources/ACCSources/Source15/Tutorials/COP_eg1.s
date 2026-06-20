
; A working Copper list program. Cop_eg1.s

		incdir		source:include/
		include		hardware.i
		include		colours.i

		bsr		SysOff		disable system, set a5

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

Wait		btst		#6,CIAAPRA
		bne.s		Wait

		bsr		SysOn

		rts


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


;--------------	Bring back the operating system

SysOn		move.l		syscop,COP1LCH(a5)
		clr.w		COPJMP1		restart system list

		move.w		#$8000,d0	set bit 15 of d0
		or.w		sysDMA,d0	add DMA flags
		move.w		d0,DMACON(a5)	enable systems DMA

		move.l		$4.w,a6		a6->SysBase
		jsr		-$008A(a6)	Permit

		rts

grafname	dc.b		'graphics.library',0
		even
sysDMA		ds.l		1
syscop		ds.l		1


		section		cop,data_c

CopList		dc.w		COLOR00,black
		dc.w		$7801,$fffe
		dc.w		COLOR00,white
		dc.w		$ffff,$fffe

