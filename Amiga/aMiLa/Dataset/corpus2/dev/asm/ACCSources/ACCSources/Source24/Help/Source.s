

; Small source that demonstrates how to get ascii gfx into a display.

; Writes one line using the blitter, the other using the 68000.

; Graphics for each letter is 32x31 stored consecutively in memory. Each
;character is four planes deep.

* include file containing all hardware register offsets

		include		source:include/hardware.i

* Disable multi-tasking

Start		move.l		$4,a6			a6->sysbase
		jsr		-$0084(a6)		Forbid()

; Before setting our display up, we need to save the DMA settings in use by
;the system and also the address of the systems Copper List. This will allow
;a graceful exit to the system later!

* Set pointer to hardware registers and save current DMA settings

		lea		$DFF000,a5		a5->hardware
		move.w		DMACONR(a5),sysDMA	save DMA settings

; The address of the Copper List being used by the system can be found in
;the base structure of the graphics library. To access this the library must
;be opened first and then closed when weve finished with it.

* Open graphics library

		lea		grafname,a1		a1->lib name
		moveq.l		#0,d0			any version
		move.l		$4.w,a6			a6->SysBase
		jsr		-$0228(a6)		OpenLibrary
		tst.l		d0			open ok?
		beq		Error			quit if not

* Save address of systems Copper List

		move.l		d0,a6			a6->gfxbase
		move.l		38(a6),syscop		save addr of sys list

* Close graphics library

		move.l		$4.w,a6			a6->SysBase
		move.l		d0,a1			a1->Graphics base
		jsr		-$019e(a6)		CloseLibrary

; We now need to initialise a Copper List for use in our program. The display
;will be 320x256x4, so we need to set 4 pairs of bitplane pointers and 16
;colour registers up.

* Write bitplane pointers into the Copper List

		lea		CopPlanes,a0		a0->into Copper List
		move.l		#Screen,d0		d0=addr of scrn mem
		move.l		#(320/8)*256,d1		d1=size of 1 plane

* write high part of address of 1st bitplane pointer in Copper List

		swap		d0			high part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

* write low part of address of 1st bitplane pointer in Copper List

		swap		d0			low part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

* bump d0 so it holds address of the next bitplane

		add.l		d1,d0			d0=addr of next plane

* write high part of address of 2nd bitplane pointer in Copper List

		swap		d0			high part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

* write low part of address of 2nd bitplane pointer in Copper List

		swap		d0			low part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

* bump d0 so it holds address of the next bitplane

		add.l		d1,d0			d0=addr of next plane

* write high part of address of 3rd bitplane pointer in Copper List

		swap		d0			high part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

* write low part of address of 3rd bitplane pointer in Copper List

		swap		d0			low part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

* bump d0 so it holds address of the next bitplane

		add.l		d1,d0			d0=addr of next plane

* write high part of address of 4th bitplane pointer in Copper List

		swap		d0			high part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

* write low part of address of 4th bitplane pointer in Copper List

		swap		d0			low part into d0.w
		move.w		d0,(a0)			write into list
		adda.l		#4,a0			a0->next position

; Now set up colour registers in the Copper List. I have used a loop to do
;this. It writes the color register offset into the Copper List first and
;then copies a colour from a table of colour values saved using an
;IFFConverter utility.

		lea		CopColours,a0		a0->into Copper List
		lea		ColourMap,a1		a1->colour table
		move.l		#$180,d0		color00 offset
		move.l		#15,d1			colour counter

BuildCols	move.w		d0,(a0)+		write reg offset
		addq.w		#2,d0			d0=next reg offset
		move.w		(a1)+,(a0)+		copy colour value
		dbra		d1,BuildCols		for all 16 colours

; List is now ready for use. Before starting it, specify what DMA activity
;this program requires: Copper, Bitplane and Blitter. Once this is done, the
;Copper list can be started.

* Specify DMA requirements

		move.w		#$01e0,DMACON(a5) 	kill all dma
		move.w		#SETIT!COPEN!BPLEN!BLTEN,DMACON(a5) enable

* Stobe the Copper List into action

		move.l		#copList,COP1LCH(a5)	addr of our list
		move.w		#0,COPJMP1(a5)		and start it!

* We can now start drawing things etc. All this is done in two subroutines:

		bsr		DisplayLine1		write 1st text
		
		bsr		DisplayLine2		write 2nd text

* Wait for user to click the left mouse button before finishing

Mouse		btst		#6,CIAAPRA		test button
		bne.s		Mouse			loop if not pressed

; Time to restore the systems DMA settings and Copper List

* Restore DMA

		move.w		#$8000,d0		set bit 15 of d0
		or.w		sysDMA,d0		add DMA flags
		move.w		d0,DMACON(a5)		enable systems DMA

* Restore Copper List

		move.l		syscop,COP1LCH(a5)	addr of sys List
		move.w		#0,COPJMP1(a5)		restart system list

; finally restore multitasking and exit

* Restore multi-tasking

Error		move.l		$4.w,a6			a6->SysBase
		jsr		-$008A(a6)		Permit

* Exit program

		rts

*****************************************************************************

***************
***************	Write a line of text using the 68000
***************

DisplayLine1	lea		Text1,a4		a4->text
		move.l		#Screen,d7		address

DrawLoop1	moveq.l		#0,d0
		move.b		(a4)+,d0		get char
		beq.s		DrawDone1		exit if all text done
		move.l		d7,a0			address
		bsr		DrawLetter		draw this letter
		add.l		#4,d7			next screen position
		bra.s		DrawLoop1		and loop

DrawDone1	rts
		

***************	Copy a character into the display using 68000.

;	d0 = letter to draw into display
;	a0 = address in display

DrawLetter	sub.b		#'A',d0			calculate offset
		mulu		#31*4,d0
		add.l		#Letters,d0		calc addr in gfx pl1

		move.l		d0,a2			a2->gfx address
		move.l		a0,a3			a3->display address

* Outer loop controlling bitplanes

;	a2 = address of 1st plane of gfx data
;	a3 = address in 1st plane of display

		moveq.l		#3,d1			num planes -1
loop2		move.l		a2,a0			a0->gfx
		move.l		a3,a1			a1->display

* Inner loop controlling lines in a bitplane

;	a0 = address of graphic data
;	a1 = address in display bitplane

		moveq.l		#30,d0			num lines -1
loop		move.l		(a0)+,(a1)		copy line of gfx
		adda.l		#40,a1			next line of display
		dbra		d0,loop			for all lines

		adda.l		#4*832,a2			a2->next gfx plane
		adda.l		#40*256,a3		a3->next screen plane

		dbra		d1,loop2

		rts

***************
***************	Write a line of text using the Blitter
***************

DisplayLine2	lea		Text2,a4		a4->text
		move.l		#Screen+32*40,d7	address

DrawLoop2	moveq.l		#0,d0
		move.b		(a4)+,d0		get char
		beq.s		DrawDone2		exit if all text done
		move.l		d7,a0			address
		bsr		BlitChar		draw this letter
		add.l		#4,d7			next screen position
		bra.s		DrawLoop2		and loop

DrawDone2	rts
		
***************	Copy a character into the display using the Blitter.

; Entry		d0=ascii code of character
;		a0=address in bitplane, MUST BE AN EVEN ADDRESS

BlitChar	sub.b		#'A',d0			letter offset
		mulu		#4*31,d0		into gfx data
		add.l		#Letters,d0		gfx start address

		move.l		a0,d1			get dest in data reg

; The blitter will copy one plane at a time, so we need to set up a loop so
;all 4 planes get copied.

		moveq.l		#3,d2			num planes - 1

; Before writing into Blitter registers, make sure Blitter is idle

BBusy		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		BBusy			if so wait

; Now we can set blitter up to blit a bitplane from letter gfx into display

		move.l		d0,BLTAPTH(a5)		Source=letter gfx
		move.l		d1,BLTDPTH(a5)		Dest=screen memory
		move.w		#0,BLTAMOD(a5)		no source modulo

; The destination modulo = Screen Width - Letter Width

		move.w		#40-4,BLTDMOD(a5)	screen modulo
		move.w		#$09f0,BLTCON0(a5)	use A & D, D=A
		move.w		#0,BLTCON1(a5)		no scroll
		move.l		#-1,BLTAFWM(a5)		no masking

; Writing BLITSIZE will start the Blitter. The blit is 31 lines by 2 words:

		move.w		#31<<6!2,BLTSIZE(a5)	start blit
		
; Now update source and dest address to point to next bitplane in the letter
;and screen respectively and loop back to blit next plane.

		add.l		#(320/8)*256,d1		next screen bitplane
		add.l		#(32/8)*832,d0		next letter bitplane

		dbra		d2,BBusy		for all 4 planes

		rts

*****************************************************************************

; Data

syscop		dc.l		0			addr of system list
sysDMA		dc.w		0			system DMA settings

grafname	dc.b		'graphics.library',0
		even

ColourMap:	dc.w	$000,$BFF,$AEE,$9DE,$8CD,$7BC,$6AB,$59B
		dc.w	$58A,$479,$369,$358,$247,$236,$135,$125

Text1		dc.b	'MARTIN',0
		even
Text2		dc.b	'THORPE',0
		even

*****************************************************************************

; CHIP data. Copper List and graphics for the Blitter MUST be in CHIP memory

		section		cop,data_c

copList		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,0			No modulo
		dc.w BPL2MOD,0			No modulo

CopColours	ds.w 32				space to build colour ptrs

		dc.w BPL1PTH			BitPlane pointers for 4planes
CopPlanes	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH
		dc.w 0,BPL2PTL
		dc.w 0,BPL3PTH
		dc.w 0,BPL3PTL
		dc.w 0,BPL4PTH
		dc.w 0,BPL4PTL
		dc.w 0

		dc.w $ffff,$fffe		end of list

Letters		incbin		fontletters.bm

*****************************************************************************

; Bitplane Memory, defined in a CHIP BSS hunk to keep disc space to minimum

		section screen,BSS_C

Screen		ds.b (320/8)*256*4
