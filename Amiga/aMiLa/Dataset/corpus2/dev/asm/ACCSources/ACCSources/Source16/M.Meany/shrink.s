
; This is a shrink/enlarge routine. The masks need some work to produce
;a decent effect, and true to form I've only used two colours.

; M.Meany, Aug 1991.


		incdir		df1:include/
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

SysOff		lea		$dff000,a5	a5->hardware

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

		moveq.l		#0,d7		initial scaling factor
		moveq.l		#1,d6		step size ( + or - one )

; wait for beam to reach line 16

VBL		moveq.l		#50,d5

.VBL		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.VBL		if not loop back

		dbra		d5,.VBL
*****************************************************************************

		bsr		FillBuf
		bsr		DrawBuf
		bsr		ClearBuf
		add.l		d6,d7
		cmpi.l		#5,d7
		bne.s		.ok
		neg.l		d6		change direction
		bra.s		.ok1

.ok		tst.l		d7
		bne.s		.ok1
		neg.l		d6	
*****************************************************************************

.ok1		btst		#6,CIAAPRA	lefty ?
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
; Clear the image buffer

ClearBuf	lea		ImBuf,a0
		moveq.l		#0,d0
		move.l		d0,(a0)
		move.l		d0,4(a0)
		move.l		d0,8(a0)
		move.l		d0,12(a0)
		rts

*****************************************************************************
; Copy contents of buffer onto the screen at a predefined position

DrawBuf		lea		ImBuf,a0
		lea		BitPlane,a1
		lea		40*10+20(a1),a1		x=20, y=40

		move.w		(a0)+,(a1)
		move.w		(a0)+,40(a1)
		move.w		(a0)+,80(a1)
		move.w		(a0)+,120(a1)
		move.w		(a0)+,160(a1)
		move.w		(a0)+,200(a1)
		move.w		(a0)+,240(a1)
		move.w		(a0)+,280(a1)
		rts

*****************************************************************************
; Shrink image into buffer

; Entry		d7=level, 0 to 5

; Exit		buffer is filled with shrunken image

; Corrupt	d1-d3, a2-a3

FillBuf		move.l		d7,d3		copy of level
		asl.w		#1,d3		x2 for offset

		lea		HMask0,a3	a3->horizontal masks
		move.w		0(a3,d3),d1	d1=horizontal mask

		lea		VMask0,a3	a3->vertical masks
		move.w		0(a3,d3),d2	d2=vertical mask

		lea		Image,a2	a2->image
		lea		ImBuf,a3	a3->buffer
		moveq.l		#7,d3		d3=image line counter

.loop		move.w		(a2)+,d0	d0=next line of image
		asr.w		#1,d2		scroll vert mask
		bcc.s		.dontcopy	if clear jump

		bsr		Shrink		else shrink this line

		move.w		d0,(a3)+	and save result

.dontcopy	dbra		d3,.loop	for all 8 lines

		rts

*****************************************************************************
; Entry		d0= word of data to shrink
;		d1= shrinking mask

; Exit		d0= shrunken word

; Corrupt	d0

;						Comment		Timing

Shrink		movem.l		d1-d4,-(sp)	save regs	48
		moveq.l		#0,d2		zero var	4
		move.l		d2,d3		zero var	4
		moveq.l		#15,d4		counter 16-1	4
		
.loop		asl.w		#1,d1		shift mask	8
		bcc.s		.no_copy	jmp if bit clr	10 T, 8 F
		roxl.w		#1,d0		else copy a	8
		roxl.w		#1,d2		bit into result	8
		addq.l		#1,d3		bump counter	8
		bra		.next		for all bits	10

.no_copy	rol.w		#1,d0		ignore bit	8	
.next		dbra		d4,.loop	for all 16 bits	10,12,14

		neg.w		d3		-ve		4
		add.w		#16,d3		bits left	8
		asr.w		#1,d3		div by 2	8

		rol.w		d3,d2		centralise	6+2 x value
		move.w		d2,d0		result into d0	4
		movem.l		(sp)+,d1-d4	restore		44

		rts				and return	16
		


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

;REG		ds.w		$300		for debug only

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

; A very simple image to work with

;Image		dc.w		%0000000000000000
		dc.w		%0000001111000000
		dc.w		%0000111111110000
		dc.w		%0001111111111000
		dc.w		%0001111111111000
		dc.w		%0001111111111000
		dc.w		%0000111111110000
		dc.w		%0000001111000000

Image		dc.w		%0000000000000000
		dc.w		%0011100000011100
		dc.w		%0011111001111100
		dc.w		%0011100110011100
		dc.w		%0011100110011100
		dc.w		%0011100000011100
		dc.w		%0011100000011100
		dc.w		%0000000000000000

; Buffer to store image in

ImBuf		dc.w		0,0,0,0,0,0,0,0

; A sample set of scroll masks

; horizontal ( For the best effect, make right 8 bits=reflection of left 8)

HMask0		dc.w		%1111111111111111
HMask1		dc.w		%1011110110111101
Hmask2		dc.w		%0111011111101110
HMask3		dc.w		%1011010101101101
Hmask4		dc.w		%0101010110111010
Hmask5		dc.w		%1001000110001001
HMask6		dc.w		0

; vertical

VMask0		dc.w		%11111111
VMask1		dc.w		%01111110
VMask2		dc.w		%01101110
VMask3		dc.w		%01011010
VMask4		dc.w		%01010010
VMask5		dc.w		%01010010
VMask6		dc.w		0
