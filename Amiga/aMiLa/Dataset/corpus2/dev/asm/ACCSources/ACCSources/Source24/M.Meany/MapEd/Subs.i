
; Subroutine file for screen map designer

BlockMenu
MaskMenu
PrefMenu
LoadMenu
SaveMenu
Clear		rts

Quit		move.l		#CLOSEWINDOW,d2
		rts

***************	Render selected block into editor window

ShowBlock	move.l		Edwin.rp(a4),a0		RastPort
		lea		BlockImage,a1		Image
		move.l		ThisBlock(a4),ig_ImageData(a1) point to gfx
		move.l		#171,d0
		move.l		#31,d1
		CALLINT		DrawImage
		
		rts

***************	Move down to next row of blocks

UpBlock		tst.l		TopBlock(a4)		at top already?
		beq		.error			exit if so
		
		sub.l		#10,TopBlock(a4)	else adjust
		bsr		SetGadgets		and redisplay
		
.error		rts

DownBlock	cmp.l		#220,TopBlock(a4)	at the bottom?
		beq.s		.error			exit if so
		
		add.l		#10,TopBlock(a4)	else adjust
		bsr		SetGadgets		and redisplay
		
.error		rts

***************	Render block graphics over gadgets, all 30 of them!

SetGadgets	move.l		TopBlock(a4),d0		1st block to render
		move.l		_Depth(a4),d1		depth of block
		addq.l		#1,d1			bump for blocks mask
		asl.l		#5,d1			x block plane size
		mulu		d1,d0			d0=offset to block
		
		move.l		Blocks(a4),a3		a3->block data
		adda.l		d0,a3			a3->data for 1st blk
		
		moveq.l		#0,d7			line counter
.Outer		move.l		d7,d5
		mulu		#17,d5
		add.l		#14,d5
		moveq.l		#0,d6			gadget counter
.Inner		move.l		d6,d0
		mulu		#17,d0			X
		move.l		d5,d1			Y
		move.l		Edwin.rp(a4),a0		Rastport
		lea		BlockImage,a1		Image
		move.l		a3,ig_ImageData(a1)	set addr of gfx data
		CALLINT		DrawImage		draw this block

		move.l		_Depth(a4),d0
		addq.l		#1,d0
		asl.l		#5,d0
		add.l		d0,a3			a3->next image data

		addq.l		#1,d6			bump X
		cmp.l		#10,d6
		blt.s		.Inner
		addq.l		#1,d7
		cmp.l		#3,d7
		blt		.Outer
		
		rts

***************	Set current block according to activated gadget

SelectBlock	moveq.l		#0,d0			clear register
		move.w		gg_GadgetID(a5),d0	get gadget number
		add.l		TopBlock(a4),d0		add to UL gadg number

		move.l		d0,ThisBlockNum(a4)	save block number
		
		move.l		_Depth(a4),d1		block depth
		addq.l		#1,d1			allow for mask
		asl.l		#5,d1			x plane size
		
		mulu		d1,d0			offset to block data
		add.l		Blocks(a4),d0		addr of block data
		
		move.l		d0,ThisBlock(a4)	save address
		
		bsr		ShowBlock		and display it
		
		moveq.l		#0,d2			not quitting
		
		rts

***************	Stamp a block into the screen

SetBlock	moveq.l		#0,d0
		move.l		d0,d1
		
		move.w		CurX(a4),d0		get screen X position
		asr.l		#4,d0			/16 = block posn
		
		move.w		CurY(a4),d1		get screen Y position
		asr.l		#4,d1			/16 = block posn
		
		add.w		OffsetX(a4),d0
		add.w		OffsetY(a4),d1
		
		move.l		d0,d4			save
		move.l		d1,d5
		
		asl.l		#4,d0			convert to scrn coord
		asl.l		#4,d1			convert to scrn coord
		move.l		window.rp(a4),a0	Rastport
		lea		BlockImage,a1		Image
		move.l		ThisBlock(a4),ig_ImageData(a1) ->gfx data
		CALLINT		DrawImage

; Now set block number in the screen map

		move.l		_Width(a4),d0		pixel width
		asr.l		#4,d0			/16 = block width
		
		mulu		d5,d0			x Y
		add.l		d4,d0			YxWidth+X
		
		move.l		Scrn(a4),a0	
		add.l		d0,a0
		
		move.l		ThisBlockNum(a4),d0	block number
		move.b		d0,(a0)			save
		
		rts

***************	Scroll visible portion of display down

DownScrn	tst.w		OffsetY(a4)		at top?
		beq		.done

		subq.w		#1,OffsetY(a4)		scroll up
		
		moveq.l		#0,d0			dx=0
		moveq.l		#-16,d1			dy=-16
		bsr		SlideLayer		scroll display
		
		moveq.l		#0,d2			not quitting
		
.done		rts

***************	Scroll visible portion of display up

UpScrn		moveq.l		#0,d0			clear
		move.w		MaxOffsetY(a4),d0	get max Y value
		
		cmp.w		OffsetY(a4),d0		are we there yet?
		ble.s		.done			skip if so
		
		addq.w		#1,OffsetY(a4)		bump Y position
		
		moveq.l		#0,d0			dx=0
		moveq.l		#16,d1			dy=16
		bsr		SlideLayer		scroll display
		
		moveq.l		#0,d2			not quitting

.done		rts

***************	Scroll visible portion of display right

RightScrn	tst.w		OffsetX(a4)		at start?
		beq		.done

		subq.w		#1,OffsetX(a4)		scroll left
		
		moveq.l		#-16,d0			dx=-16
		moveq.l		#0,d1			dy=0
		bsr		SlideLayer		scroll display
		
		moveq.l		#0,d2			not quitting
		
.done		rts

***************	Scroll visible portion of display left

LeftScrn	moveq.l		#0,d0			clear
		move.w		MaxOffsetX(a4),d0	get max X value
		
		cmp.w		OffsetX(a4),d0		are we there yet?
		ble.s		.done			skip if so
		
		addq.w		#1,OffsetX(a4)		bump X position
		
		moveq.l		#16,d0			dx=16
		moveq.l		#0,d1			dy=0
		bsr		SlideLayer		scroll display
		
		moveq.l		#0,d2			not quitting

.done		rts

***************	Scroll the SuperBitMap window

;Entry	d0= x scroll value (dx)
;	d1= y scroll value (dy)

SlideLayer	suba.l		a0,a0			dummy = 0
		move.l		window.lyr(a4),a1	Layer
		CALLLAYERS	ScrollLayer		slide screen
		rts

***************	Render block graphics from Scrn buffer into display

BuildScreen	move.l		_Depth(a4),d7		screen depth
		addq.l		#1,d7			bump for mask
		
		move.l		_Width(a4),d6		pixel width
		asr.l		#4,d6			/16 = block width
		
		move.l		_Height(a4),d5		pixel height
		asr.l		#4,d5			/16 = block height
		
		move.l		Scrn(a4),a3		a3->map data
		
		moveq.l		#0,d3			Y counter
.Outer		moveq.l		#0,d4			X counter

.Inner		moveq.l		#0,d0			clear
		move.b		(a3)+,d0		next block number
		asl.l		#5,d0			x32 ( plane size )
		mulu		d7,d0			x num planes
		add.l		Blocks(a4),d0		addr of gfx
		
		move.l		window.rp(a4),a0	RastPort
		lea		BlockImage,a1		Image
		move.l		d0,ig_ImageData(a1)	-> to gfx
		
		move.l		d4,d0			block X pos
		asl.l		#4,d0			pixel X pos
		
		move.l		d3,d1			block Y pos
		asl.l		#4,d1			pixel Y pos
		
		CALLINT		DrawImage		draw it
		
		addq.l		#1,d4			bump X
		cmp.l		d4,d6			line done
		bne.s		.Inner			loop if not
		
		addq.l		#1,d3			bump Y
		cmp.l		d3,d5			screen done
		bne.s		.Outer			loop if not
		
		rts

