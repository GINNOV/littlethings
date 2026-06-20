
; Example 14: A Poor Excuse of a Game. Nothing new has been used!

		include		int_start.i

; Initialise the BitMap structure

Main		lea		MyBitMap,a0		a0->BitMap struct
		move.l		#1,d0			Depth
		move.l		#320,d1			Width
		move.l		#256,d2			height
		CALLGRAF	InitBitMap		initialise structure

; Link bitplane memory into BitMap structure

		lea		MyBitMap,a0		a0->BitMap
		lea		bm_Planes(a0),a0	a0->bm_Planes field
		
		lea		bitplanes,a1		a1->start of mem block

; Write first bitplane start address into structure
    
    		move.l		a1,(a0)			write bitplane addr
    
; Link BitMap structure to NewScreen structure

		lea		MyScreen,a0		a0->NewScreen
		move.l		#MyBitMap,ns_CustomBitMap(a0) link BitMap

; Set screens type

		move.w		#CUSTOMBITMAP!CUSTOMSCREEN,ns_Type(a0)

; Open the Custom Screen

		lea		MyScreen,a0		NewScreen struct
		CALLINT		OpenScreen		open it
		move.l		d0,screen.ptr		save pointer
		beq		error			quit if error

; Set scroll counter and collision flag

		move.l		#5,ScrollCount		init counter
		move.l		#0,HitFlag		clear flag

; Wait for mouse press

MWait		btst		#2,$dff016
		beq		AllDone

; Check for collision

		tst.l		HitFlag
		bne		AllDone			exit if set

; Wait for vertical blanking period

		CALLGRAF	WaitTOF

; Update counter

		subq.l		#1,ScrollCount		dec counter
		bne.s		NoPlot

; Plot next asteroid and reset counter

		bsr		RND			get random position
		bsr		PlotAsteroid		plot asteroid
		move.l		#5,ScrollCount		reset counter
		
; Scroll display down a line

NoPlot		lea		bitplanes,a0		bitplane to scroll
		bsr		ScrollDown		scroll it

; Plot the ship

		bsr		MoveShip		check movements
		move.l		ShipX,d0		x pixel position
		bsr		PlotShip		plot the ship

; And loop back
		
		bra		MWait			loop

; Freeze screen for player to see collision

AllDone		bsr		LeftMouse
		
; Close the screen

		move.l		screen.ptr,a0		a0->screen struct
		CALLINT		CloseScreen		close it

error		rts					and exit

;-------------- Scroll Down

; scroll screen down 1 line

; Entry		a0->start of bitplane memory

; Exit		Nothing special

; corrupt	a0-a2,d0

ScrollDown	adda.l		#(320/8)*249,a0		1st long past bitplane
		move.l		a0,a1
		suba.l		#40,a1			1st long. last line
		move.l		#2369,d0		number of longs

; The scroll loop

.loop		move.l		-(a1),-(a0)		copy long word
		dbra		d0,.loop		for whole display

; And exit

		rts					exit

;--------------	Plot an asteroid

; Entry		d0=x byte position

PlotAsteroid	lea		bitplanes+440,a0	a0->top line free
		add.l		d0,a0			a0->addr to plot at
		lea		Asteroid,a1		a1->data
		
		move.b		(a1)+,(a0)		copy 1st line
		lea		40(a0),a0		a0->next addr
		move.b		(a1)+,(a0)		copy 2nd line
		lea		40(a0),a0		a0->next addr
		move.b		(a1)+,(a0)		copy 3rd line
		lea		40(a0),a0		a0->next addr
		move.b		(a1)+,(a0)		copy 4th line
		lea		40(a0),a0		a0->next addr
		move.b		(a1)+,(a0)		copy 5th line
		lea		40(a0),a0		a0->next addr
		move.b		(a1)+,(a0)		copy 6th line
		
		rts

;--------------	Plot The Ship

; Entry		d0=x pixel position

; Corrupt	a0,a1,d0,d1

PlotShip	lea		bitplanes+249*40,a0	a0->Ships top line

		divu		#16,d0
		swap		d0
		move.w		d0,d1			d1=bit scroll
		move.w		#0,d0
		swap		d0
		asl.l		#1,d0			force even
		
		add.l		d0,a0			a0->addr to plot at
		lea		Ship,a1			a1->data

; Check for collision

		move.l		-40(a0),d0		get data above ship
		asl.l		d1,d0			correct
		and.l		#$f0000000,d0		test bits
		beq.s		.DoPlot			skip if no collision
		move.l		#-1,HitFlag		signal collision

.DoPlot		move.l		(a1)+,d0		get line of data
		asr.l		d1,d0			scroll it
		move.l		d0,(a0)			and draw this line
		lea		40(a0),a0		a0->next scrn addr
		move.l		(a1)+,d0		get line of data
		asr.l		d1,d0			scroll it
		move.l		d0,(a0)			and draw this line
		lea		40(a0),a0		a0->next scrn addr
		move.l		(a1)+,d0		get line of data
		asr.l		d1,d0			scroll it
		move.l		d0,(a0)			and draw this line
		lea		40(a0),a0		a0->next scrn addr
		move.l		(a1)+,d0		get line of data
		asr.l		d1,d0			scroll it
		move.l		d0,(a0)			and draw this line
		lea		40(a0),a0		a0->next scrn addr
		move.l		(a1)+,d0		get line of data
		asr.l		d1,d0			scroll it
		move.l		d0,(a0)			and draw this line
		lea		40(a0),a0		a0->next scrn addr
		move.l		(a1)+,d0		get line of data
		asr.l		d1,d0			scroll it
		move.l		d0,(a0)			and draw this line
		lea		40(a0),a0		a0->next scrn addr
		
		rts

;--------------	Generate a random number in range 1->specified number<65535

; Entry		None
; Exit		d0=random number between 1 and 39
; Corrupt	d0,d1

RND		moveq.l		#39,d0		max value, <65535!
		move.l		d0,d1
		
		move.l		d1,-(sp)
		move.l		a0,-(sp)

		move.l		Seed,d0		get seed
		rol.l		d0,d0		scramble bits
		move.l		d0,d1
		and.l		#$7fffe,d1	create random ptr into CHIP
		move.l		d1,a0
		add.l		(a0),d0		add onto scrambled bits
		add.l		d0,Seed		save value

		move.l		(sp)+,a0
		move.l		(sp)+,d1

		and.l		#$ffff,d0
		mulu		d1,d0
		divu		#$ffff,d0
		and.l		#$ffff,d0
		rts

;--------------	Check for ship movement

MoveShip	bsr		TestJoy			get joystick data
		btst		#0,d2			check right
		beq.s		.CheckLeft		skip if not

; moving right, check is legal and update if so!

		move.l		ShipX,d0		x coordinate
		cmp.l		#310,d0			at right edge?
		beq.s		.DoneMoving		exit if so!
		addq.l		#1,d0			update
		move.l		d0,ShipX		save
		bra.s		.DoneMoving		and exit!

; See if moving left, exit if not!

.CheckLeft	btst		#1,d2			check left
		beq.s		.DoneMoving		exit if not
		move.l		ShipX,d0		x coordinate
		beq.s		.DoneMoving		exit if 0
		subq.l		#1,d0			update
		move.l		d0,ShipX		and save

; Done moving, so exit!

.DoneMoving	rts
;--------------	Read the joystick

; Subroutine to read joystick movement in port 1. Returns a code in register
;d2 according to the following:

;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement

; Assumes a5 -> hardware registers ( ie a5 = $dff000 ).

; Corrupts a5, d0, d1 and d2.

; M.Meany, Aug 91.

JOY1DAT		equ		$00c

TestJoy		lea		$dff000,a5		a5->hardware reg
		moveq.l		#0,d0			clear
		move.l		d0,d2
		move.w		JOY1DAT(a5),d0		read stick

		btst		#1,d0			right ?
		beq.s		.test_left		if not jump!

		or.w		#1,d2			set right bit

.test_left	btst		#9,d0			left ?
		beq.s		.test_updown		if not jump

		or.w		#2,d2			set left bit

.test_updown	move.l		d0,d1			copy JOY1DAT
		lsr.w		#1,d1			shift u/d bits
		eor.w		d1,d0			exclusive or 'em
		btst		#0,d0			down ?
		beq.s		.test_down		if not jump

		or.w		#4,d2			set down bit

.test_down	btst		#8,d0			up ?
		beq.s		.no_joy			if not jump

		or.w		#8,d2			set up bit

.no_joy		rts





; Static Intuition structures and variables

MyBitMap	ds.b		bm_SIZEOF	space for BitMap structure

MyScreen
	dc.w	0,0		;screen XY origin relative to View
	dc.w	320,256		;screen width and height
	dc.w	1		;screen depth (number of bitplanes)
	dc.b	1,0		;detail and block pens
	dc.w	0		;display modes for this screen
	dc.w	0		;screen type
	dc.l	0		;pointer to default screen font
	dc.l	.Title		;pointer to screen title
	dc.l	0		;first in list of custom screen gadgets
	dc.l	0		;pointer to custom BitMap structure

.Title	dc.b	'           This is fun???',0
	even

screen.ptr	dc.l		0

ShipX		dc.l		100
HitFlag		dc.l		0
Seed		dc.l		15

ScrollCount	dc.l		0

; CHIP MEM section for graphics!

Asteroid	dc.b		%00000000
		dc.b		%01011010
		dc.b		%00111100
		dc.b		%01111110
		dc.b		%00111100
		dc.b		%01011010
		even

Ship		dc.b		%01111110,0,0,0
		dc.b		%01000010,0,0,0
		dc.b		%00100100,0,0,0
		dc.b		%00100100,0,0,0
		dc.b		%00011000,0,0,0
		dc.b		%00011000,0,0,0


; BSS CHIP MEM section for bitplane memory

		section		gfx,BSS_C

bitplanes	ds.b		(320/8)*256
		ds.b		200		safety margin!
		