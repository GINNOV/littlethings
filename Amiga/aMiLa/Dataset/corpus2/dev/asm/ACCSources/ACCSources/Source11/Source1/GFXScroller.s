

; Program to use gfx Text() on a custom bitplane.

; Stage1 : Initialises a RastPort structure, but does not use it.

; Stage2 : Trying to use the RastPort + Text () routines

; Stage3 : Used ScrollRaster to move the displayed text
;	   Also added Forbid() & Permit to lock out OS

; M.Meany 16-3-91
		
		opt		O+
		
		incdir		sys:include/
		include		hardware.i
		include		exec/exec_lib.i
		include		exec/memory.i
		include		graphics/graphics_lib.i
		include		graphics/gfx.i
		include		graphics/rastport.i

Start		move.l		#$dff000,a5	a5->hardware registers

;------	Get memory ( CHIP ) for copper list

		move.l		#CopperSize,d0	size of mem
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1	type of mem
		CALLEXEC	AllocMem	ask for it
		move.l		d0,CopperAddr	save the address
		beq		quit		leave if error

;------	Get memory ( CHIP ) for bit plane

		move.l		#(336/8)*256,d0	size of mem
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1	type of mem
		CALLEXEC	AllocMem	ask for it
		move.l		d0,PlaneAddr	save the address
		beq		quit1		leave if error

;------	Put address of bitplane into copper list

		move.w		d0,pl1l		save low part of address
		swap		d0
		move.w		d0,pl1h		save high part of address

;------	Copy copper list into allocated chip memory

		move.l		CopperAddr,a0	a0->chip mem area
		lea		CopperList(pc),a1 a1->our copper list
		moveq.l		#CopperSize,d0	size of list - 1
		subq.l		#1,d0
.copper_loop	move.b		(a1)+,(a0)+	copy each byte
		dbra		d0,.copper_loop	until all done

;------	Open GFX library and store address of current copper list

		lea		gfxname(pc),a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base pointer
		beq		quit2		leave if not open
		move.l		d0,a0		base addr into a0
		move.l		38(a0),OldCopper save addr of current list

;------	Allocate memory for a bitmap structure

		moveq.l		#bm_SIZEOF,d0	size of mem
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	type of mem
		CALLEXEC	AllocMem	and ask for it
		move.l		d0,BMStruct	save address
		beq		quit3		leave if error
		
		move.l		d0,a3		constant through rest of code

;------	Initialise the bitmap structure

		move.l		d0,a0		addr of structure
		moveq.l		#1,d0		depth
		move.l		#672,d1		width -- a little trick
		move.l		#128,d2		height - for large chars
		CALLGRAF	InitBitMap	and initialise it

;------	Attach bit plane to this structure

		move.l		PlaneAddr,bm_Planes(a3)	attach bitplane

;------	Allocate memory for rastport structure

		moveq.l		#rp_SIZEOF,d0	size of mem
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	type of mem
		CALLEXEC	AllocMem	ask for it
		move.l		d0,RPStruct	save its address
		beq		quit4		leave if error

		move.l		d0,a4		constant through rest of code

;------	Initialise this rastport structure

		move.l		d0,a1		addr of structure
		CALLGRAF	InitRastPort	and initialise it

;------	Attach bit map structure to the rastport structure. The rastport
;	should then be useable for graphics functions, namely Text ().

		move.l		a3,rp_BitMap(a4)	attach bitmap struct

;------	Start our copper list running
		
		CALLEXEC	Forbid		lock out the OS
		move.w		#$0020,DMACON(a5)
		move.l		CopperAddr,COP1LCH(a5)	hit strobe register

;------	Wait for vertical blanking gap

beam_wait	move.l		VPOSR(a5),d2
		and.l		#$0001ff00,d2
		cmp.l		#$00001000,d2
		bne.s		beam_wait

		tst.w		counter
		bne.s		dont_print

		movem.l		a3-a4,-(sp)	save structure pointers
		move.l		#655,d0		x position
		moveq.l		#50,d1		y position
		move.l		a4,a1		a1->rastport struct
		CALLGRAF	Move		set pen position

		move.l		next_char,a0
		moveq.l		#1,d0
		move.l		a4,a1
		CALLGRAF	Text

		movem.l		(sp)+,a3-a4

		move.l		next_char,a0
		addq.l		#1,a0
		tst.b		(a0)
		bne.s		.ok
		lea		scr_text,a0
.ok		move.l		a0,next_char
		move.w		#4,counter


;------	Scroll the text

dont_print	move.l		a4,a1		a1->rastport structure
		moveq.l		#2,d0		dx ( 1 pixel left )
		moveq.l		#0,d1		dy
		move.l		#336,d2		x start
		moveq.l		#41,d3		y start
		move.l		#670,d4		x stop
		moveq.l		#51,d5		y stop
		CALLGRAF	ScrollRaster	scroll the rectangle

		sub.w		#1,counter

;------	Wait for LMB to be pressed

		btst		#6,CIAAPRA	test LMB
		bne		beam_wait	loop back if not pressed

;------	Restore original copper list

		move.l		OldCopper,COP1LCH(a5)	hit strobe register
		move.w		#$83e0,DMACON(a5)
		CALLEXEC	Permit

;------	Release rastport structure memory

		move.l		a4,a1		a1->mem block
		moveq.l		#rp_SIZEOF,d0	d0=size of block
		CALLEXEC	FreeMem		and release it

;------	Release bitmap structure memory

quit4		move.l		a3,a1		a1->mem block
		moveq.l		#bm_SIZEOF,d0	d0=size of block
		CALLEXEC	FreeMem		and release it

;------	Close GFX library

quit3		move.l		_GfxBase,a1	a1=base addr of library
		CALLEXEC	CloseLibrary	and close it

;------	Release bit plane memory

quit2		move.l		PlaneAddr,a1	a1->mem block
		move.l		#(336/8)*256,d0	d0=size of block
		CALLEXEC	FreeMem		and release it

;------	Release copper list memory

quit1		move.l		CopperAddr,a1	a1->mem block
		move.l		#CopperSize,d0	d0=size of block
		CALLEXEC	FreeMem		and release it

;------	Finish

quit		rts


CopperList	dc.w		DIWSTRT,$2c81	Top left of screen
		dc.w		DIWSTOP,$2cc1	Bottom right of screen (PAL)
		dc.w		DDFSTRT,$38	Data fetch start
		dc.w		DDFSTOP,$d0	Data fetch stop
		dc.w		BPLCON0,$1200	lo-res, 1 bitplane
		dc.w		BPLCON1,0	No horizontal offset
		dc.w		BPL1MOD,$0002	2 bytes ( 16 pixels )
		dc.w		COLOR00,$0000	black background
		dc.w		COLOR01,$0fff	white foreground
 
		dc.w		BPL1PTH		Plane pointers
pl1h		dc.w		0,BPL1PTL
pl1l		dc.w		0

		dc.w		$ffff,$fffe	End of copper list
CopperSize	equ		*-CopperList

;------- Variables

gfxname		dc.b		'graphics.library',0
		even

_GfxBase	dc.l		0
CopperAddr	dc.l		0
PlaneAddr	dc.l		0
OldCopper	dc.l		0
BMStruct	dc.l		0
RPStruct	dc.l		0

counter		dc.w		0
next_char	dc.l		scr_text

scr_text	dc.b	'Well here is my contribution to the growing number of text scrollers'
		dc.b	' appearing on this disc. This uses the GFX library to display and scroll '
		dc.b	'this text. None of those nasty mega memory eating raw fonts and I can '
		dc.b	'position this text anywhere on the screen with no problems. As is customary '
		dc.b	'in scroll texts here is a quick list of greets .............. Zaphod ( bet '
		dc.b	'you hate this HeHeHe ), Steve Marshall , Dave Edwards , Nipper , Neil , Raistlin '
		dc.b	' Dave Shaw ( both of you ), Ronnie "The General" James, Wizard and all you others '
		dc.b	'who I have missed ..... SORRY !!!!!!! I hate typing shit like this in !!!! ...'
		dc.b	'...... Here is a quick ( and flash ) font display !£$%^&*()_+=\|@#;/?.,å°©®®þ¤µððß¹²³¢¼¢½¾¾·«»-='
		dc.b	'    If you are still reading this guess what ---- time to restart >>>>>>>>>>>>>>>>> ',0
		even


		even

; M.MEANY-END
