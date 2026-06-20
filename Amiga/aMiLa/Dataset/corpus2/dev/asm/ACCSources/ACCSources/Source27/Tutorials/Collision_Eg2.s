
; Collisions: Example 2 »»» Two moving bobs. Players bob collides with
;			    background, but no bob-bob collisions yet.

; Plane 4 is used as a collision plane. Bits set in this plane indicate that
;the players bob cannot move there.

; by M.Meany, August 1992.

; The required include files to make programming that much easier :')

		incdir		source:Include/
		include		hardware.i		equates
		include		hw_start.i		startup code


Custom		equ		$dff000

*****	Program proper starts here

; Write address of bitplanes into Copper list

Main		lea		CopBpls,a0		->copper list
		move.l		#Screen,d0		bit plane address
		move.w		d0,4(a0)		write address into
		swap		d0			copper list
		move.w		d0,(a0)

		swap		d0
		add.l		#(320/8)*256,d0		calc address
		move.w		d0,12(a0)		write into copper
		swap		d0
		move.w		d0,8(a0)

		swap		d0
		add.l		#(320/8)*256,d0		calc address
		move.w		d0,20(a0)		write into copper
		swap		d0
		move.w		d0,16(a0)

		swap		d0
		add.l		#(320/8)*256,d0		calc address
		move.w		d0,28(a0)		write into copper
		swap		d0
		move.w		d0,24(a0)

; Fill in colour defenitions in copper list

		swap		d0
		add.l		#(320/8)*256,d0		calc address
		move.l		d0,a1			a1->CMAP

		lea		Colours,a0		a0->copper list
		move.l		#$180,d1		1st colour reg addr
		moveq.l		#15,d2			num colours
Cloop		move.w		d1,(a0)+		copy reg number
		move.w		(a1)+,(a0)+		copy colour value
		addq.w		#2,d1			bump reg addr
		dbf		d2,Cloop		for all 15 colours

; Install game Copper list here. Copper DMA not yet enabled, so it wont do
;anything at this stage!

		move.l		#MyCop,COP1LCH(a5)	addr of game list
		move.w		#0,COPJMP1(a5)		strobe to start

; Now set address of vertical blank interrupt handler that will control the
;game play.

		move.l		#NewLevel3,$6c		L3 handler routine

; Game initialisations go here before interrupt is enabled.

		lea		GameVars,a4		a4->variables block
		move.w		#50,PlayerX(a4)		position player
		move.w		#50,PlayerY(a4)
		move.w		#200,EnemyX(a4)		position enemy
		move.w		#150,EnemyY(a4)
		move.l		#MoveTable,T_pos(a4)	reset pointer
		
; Enable level 3 interrupts

		move.w		#SETIT!INTEN!VERTB,INTENA(a5)

; Enable Copper, Blitter and Bitplane DMA

		move.w		#SETIT!DMAEN!BLTEN!COPEN!BPLEN,DMACON(a5)

; Wait for mouse button before quitting

MWait		btst		#6,CIAAPRA
		bne.s		MWait

; All over so return to system

		rts

*****
*****	Level 3 interrupt handler 
*****

NewLevel3	lea		Custom,a5		hardware base
		lea		GameVars,a4		game variable block

; Clear interrupt request bits

		move.w		INTREQR(a5),d0		get bit
		and.w		#$7fff,d0		clear bit 15
		move.w		d0,INTREQ(a5)		clear request

		bsr		RestoreBgrnd		restore background
		bsr		MovePlayer		verify movement
		bsr		MoveEnemy
		bsr		SaveBgrnd		save damage areas
		bsr		BlitPlayer		draw ship
		bsr		BlitEnemy		draw enemy
		
		rte					back to User Mode

*****
*****	Restores background areas destroved by bobs
*****

; First restore background under players bob

RestoreBgrnd	move.l		PlayerAddr(a4),d0	get restore address
		beq.s		.Enemy			exit if nothing to do

		moveq.l		#3,d1			num planes - 1

.QB		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QB			yep, keep waiting

		move.l		#Bgrnd1,BLTAPTH(a5)	addr of saved data

.QBlit		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QBlit			yep, keep waiting

		move.l		d0,BLTDPTH(a5)		addr to restore
		move.l		#-1,BLTAFWM(a5)		no masking
		move.w		#0,BLTAMOD(a5)		no src modulo
		move.w		#36,BLTDMOD(a5)		screen modulo
		move.l		#$09f00000,BLTCON0(a5)	use A,D: D=A
		move.w		#16<<6!2,BLTSIZE(a5)	16x32 pixels
		
		add.l		#(320/8)*256,d0
		dbra		d1,.QBlit

; Now restore background under enemies bob.

.Enemy		move.l		EnemyAddr(a4),d0	get restore address
		beq.s		.Done			exit if nothing to do

		moveq.l		#3,d1			num planes - 1

.QB1		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QB1			yep, keep waiting

		move.l		#Bgrnd2,BLTAPTH(a5)	addr of saved data

.QBlit1		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QBlit1			yep, keep waiting

		move.l		d0,BLTDPTH(a5)		addr to restore
		move.l		#-1,BLTAFWM(a5)		no masking
		move.w		#0,BLTAMOD(a5)		no src modulo
		move.w		#36,BLTDMOD(a5)		screen modulo
		move.l		#$09f00000,BLTCON0(a5)	use A,D: D=A
		move.w		#16<<6!2,BLTSIZE(a5)	16x32 pixels
		
		add.l		#(320/8)*256,d0
		dbra		d1,.QBlit1

.Done		rts


*****
*****	Save background areas about to be destroyed by bobs
*****

SaveBgrnd	moveq.l		#0,d0			clear this register
		move.l		d0,d2			and this one

; From the x position, calculate the number of bytes from left edge of screen
;Note, this must be an even address as the blitter deals with words only

		move.w		PlayerX(a4),d0		get x position
		asr.w		#4,d0			/16
		add.w		d0,d0			byte offset

; From the y position, calculate the number of bytes from the top of the
;screen to the start of the line in which the bob starts

		move.w		PlayerY(a4),d2		get y position
		mulu		#40,d2			x line width

; Add the two offsets together to form number of bytes from top left of
;screen and then add address of screen memory to form address of first byte
;in which the bob will appear.

		add.w		d2,d0			add offsets
		add.l		#Screen,d0		d0=dest addr
		move.l		d0,PlayerAddr(a4)	save this for later

		moveq.l		#3,d1			num planes - 1

.QB		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QB			yep, keep waiting

		move.l		#Bgrnd1,BLTDPTH(a5)

.QBlit		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QBlit			yep, keep waiting

		move.l		d0,BLTAPTH(a5)		addr to restore
		move.l		#-1,BLTAFWM(a5)		no masking
		move.w		#0,BLTDMOD(a5)		no src modulo
		move.w		#36,BLTAMOD(a5)		screen modulo
		move.l		#$09f00000,BLTCON0(a5)	use A,D: D=A
		move.w		#16<<6!2,BLTSIZE(a5)	16x32 pixels
		
		add.l		#(320/8)*256,d0
		dbra		d1,.QBlit

; Now save background under enemy bob

		moveq.l		#0,d0			clear this register
		move.l		d0,d2			and this one

; From the x position, calculate the number of bytes from left edge of screen
;Note, this must be an even address as the blitter deals with words only

		move.w		EnemyX(a4),d0		get x position
		asr.w		#4,d0			/16
		add.w		d0,d0			byte offset

; From the y position, calculate the number of bytes from the top of the
;screen to the start of the line in which the bob starts

		move.w		EnemyY(a4),d2		get y position
		mulu		#40,d2			x line width

; Add the two offsets together to form number of bytes from top left of
;screen and then add address of screen memory to form address of first byte
;in which the bob will appear.

		add.w		d2,d0			add offsets
		add.l		#Screen,d0		d0=dest addr
		move.l		d0,EnemyAddr(a4)	save this for later

		moveq.l		#3,d1			num planes - 1

.QB1		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QB1			yep, keep waiting

		move.l		#Bgrnd2,BLTDPTH(a5)

.QBlit1		btst		#14,DMACONR(a5)		blitter busy
		bne.s		.QBlit1			yep, keep waiting

		move.l		d0,BLTAPTH(a5)		addr to restore
		move.l		#-1,BLTAFWM(a5)		no masking
		move.w		#0,BLTDMOD(a5)		no src modulo
		move.w		#36,BLTAMOD(a5)		screen modulo
		move.l		#$09f00000,BLTCON0(a5)	use A,D: D=A
		move.w		#16<<6!2,BLTSIZE(a5)	16x32 pixels
		
		add.l		#(320/8)*256,d0
		dbra		d1,.QBlit1

		rts
*****
*****	Blit Players ship onto the screen
*****

BlitPlayer	move.l		PlayerAddr(a4),d0	get dest addr

; The scroll value to use can now be gained from the copy of the x position.
;This scroll value needs to be in the high nibble of bltcon0 and the high
;nibble of bltcon1. Since both these registers can be written in one
;operation, the scroll value must be copied accordingly.

		moveq.l		#0,d1			clear this register
		move.w		PlayerX(a4),d1		get x position
		and.w		#$f,d1			mask out unwanted bits
		ror.w		#4,d1			into high nibble
		move.w		d1,-(sp)		save
		swap		d1			into high nibble
		move.w		(sp)+,d1		

; Add minterm and usage bits to the scroll values

; usage:	A=bob, B=Mask, C=playfield, D=Playfield		($f)
; minterm:	D=AB+bC						($ca)

		or.l		#$0fca0000,d1		merge minterm & usage

; Now blit the bat

		move.l		#Player,d2
		move.l		#PlayerM,d3
		moveq.l		#3,d5			num planes - 1

QBlit		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		QBlit			yep, keep waiting

		move.l		d3,BLTAPTH(a5)		mask
		move.l		d2,BLTBPTH(a5)		gfx
		move.l		d0,BLTCPTH(a5)		playfield
		move.l		d0,BLTDPTH(a5)		playfield
		move.w		#$ffff,BLTAFWM(a5)	blitter masks
		move.w		#$0000,BLTALWM(a5)
		move.w		#-2,BLTAMOD(a5)
		move.w		#-2,BLTBMOD(a5)
		move.w		#36,BLTCMOD(a5)
		move.w		#36,BLTDMOD(a5)
		move.l		d1,BLTCON0(a5)
		move.w		#16<<6!2,BLTSIZE(a5)	size=16x16pixels
		
		add.l		#(320/8)*256,d0		address of next bpl
		add.l		#(16/8)*16,d2
		add.l		#(16/8)*16,d3
		dbra		d5,QBlit

		rts

*****
*****	Blit Enemies ship onto the screen
*****

BlitEnemy	move.l		EnemyAddr(a4),d0	get dest addr

; The scroll value to use can now be gained from the copy of the x position.
;This scroll value needs to be in the high nibble of bltcon0 and the high
;nibble of bltcon1. Since both these registers can be written in one
;operation, the scroll value must be copied accordingly.

		moveq.l		#0,d1			clear this register
		move.w		EnemyX(a4),d1		get x position
		and.w		#$f,d1			mask out unwanted bits
		ror.w		#4,d1			into high nibble
		move.w		d1,-(sp)		save
		swap		d1			into high nibble
		move.w		(sp)+,d1		

; Add minterm and usage bits to the scroll values

; usage:	A=bob, B=Mask, C=playfield, D=Playfield		($f)
; minterm:	D=AB+bC						($ca)

		or.l		#$0fca0000,d1		merge minterm & usage

; Now blit the bat

		move.l		#Enemy,d2
		move.l		#EnemyM,d3
		moveq.l		#3,d5			num planes - 1

.QBlit		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		.QBlit			yep, keep waiting

		move.l		d3,BLTAPTH(a5)		mask
		move.l		d2,BLTBPTH(a5)		gfx
		move.l		d0,BLTCPTH(a5)		playfield
		move.l		d0,BLTDPTH(a5)		playfield
		move.w		#$ffff,BLTAFWM(a5)	blitter masks
		move.w		#$0000,BLTALWM(a5)
		move.w		#-2,BLTAMOD(a5)
		move.w		#-2,BLTBMOD(a5)
		move.w		#36,BLTCMOD(a5)
		move.w		#36,BLTDMOD(a5)
		move.l		d1,BLTCON0(a5)
		move.w		#16<<6!2,BLTSIZE(a5)	size=16x16pixels
		
		add.l		#(320/8)*256,d0		address of next bpl
		add.l		#(16/8)*16,d2
		add.l		#(16/8)*16,d3
		dbra		d5,.QBlit

		rts

*****
*****	Move the enemy
*****

MoveEnemy	tst.w		T_count(a4)
		bne.s		.no_advance
		
		move.l		T_pos(a4),a0
		move.w		(a0)+,T_dx(a4)
		move.w		(a0)+,T_dy(a4)
		move.w		(a0)+,T_count(a4)
		move.l		a0,T_pos(a4)
		tst.l		(a0)
		bne.s		.no_advance
		move.l		#MoveTable,T_pos(a4)	reset pointer

.no_advance	move.w		EnemyX(a4),d0
		add.w		T_dx(a4),d0
		move.w		d0,EnemyX(a4)
		
		move.w		EnemyY(a4),d0
		add.w		T_dy(a4),d0
		move.w		d0,EnemyY(a4)

		subq.w		#1,T_count(a4)

		rts
*****
*****	Move the player
*****

; Players X,Y position is copied into temporary registers. If the move is
;allowed, then the actual X,Y position is updated otherwise the movement is
;ignored.

MovePlayer	move.w		PlayerX(a4),NewX(a4)
		move.w		PlayerY(a4),NewY(a4)

; Read joystick

		bsr		TestJoy

; See if attempting to move right

		btst		#0,d2			right?
		beq.s		.TryLeft		no, skip

; User wants to go right, if move is legal update PalyerX

		cmpi.w		#300,NewX(a4)	at right edge
		bge.s		.TryUp			yep, exit routine
		addq.w		#2,NewX(a4)		no, bump position
		bra.s		.TryUp			and exit

; See if attempting to move left

.TryLeft	btst		#1,d2			right?
		beq.s		.TryUp			no, skip

; User wants to go left, if move is legal update PalyerX

		cmpi.w		#1,NewX(a4)		at right edge
		ble.s		.TryUp			yep, exit routine
		subq.w		#2,NewX(a4)		no, bump position

; See if attempting to move up

.TryUp		btst		#3,d2			up?
		beq.s		.TryDown		no, skip

; User wants to move up, if move is legal update PlayerY

		cmpi.w		#1,NewY(a4)
		ble.s		.Done
		subq.w		#2,NewY(a4)
		bra.s		.Done

; See if attempting to move down

.TryDown	btst		#2,d2			down?
		beq.s		.Done			no, exit

; User wants to move down, if move is valid update PlayerY

		cmpi.w		#238,NewY(a4)	at bottom?
		bge.s		.Done			yep. exit
		addq.w		#2,NewY(a4)

.Done		bsr		CheckBgrnd		see if hit bgrnd

		move.w		NewX(a4),PlayerX(a4)	update position
		move.w		NewY(a4),PlayerY(a4)

		rts

*****
*****	Check joystick left/right
*****

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

*****
*****	Check for background collision
*****

CheckBgrnd	moveq.l		#0,d0			clear this register
		move.l		d0,d2			and this one

; From the x position, calculate the number of bytes from left edge of screen
;Note, this must be an even address as the blitter deals with words only

		move.w		NewX(a4),d0		get x position
		move.l		d0,d1			save a copy
		asr.w		#4,d0			/16
		add.w		d0,d0			byte offset

; From the y position, calculate the number of bytes from the top of the
;screen to the start of the line in which the bob starts

		move.w		NewY(a4),d2		get y position
		mulu		#40,d2			x line width

; Add the two offsets together to form number of bytes from top left of
;screen and then add address of screen memory to form address of first byte
;in which the bob will appear.

		add.w		d2,d0			add offsets
		add.l		#Screen+(320/8)*256*3,d0 d0=addr of bpl4

; Must now form bltcon0.

; usage:	A=maks, C=collision plane		($a)
; minterm	AC (note no destination)		($a0)

		and.w		#$f,d1			isolate scroll bits
		ror.w		#4,d1			into high nibble
		move.w		d1,-(sp)		save
		swap		d1
		move.w		(sp)+,d1
		or.l		#$0aa00000,d1		minterm & usage

; To check move, one plane of draw mask will be blitted into plane 4 of
;playfields screen memory

.QBlit		btst		#14,DMACONR(a5)
		bne.s		.QBlit

		move.l		#PlayerM,BLTAPTH(a5)	mask
		move.l		d0,BLTCPTH(a5)		collision plane
		move.w		#-2,BLTAMOD(a5)
		move.w		#36,BLTCMOD(a5)
		move.l		#$ffff0000,BLTAFWM(a5)	blitter mask
		move.l		d1,BLTCON0(a5)		control bits
		move.w		#16<<6!2,BLTSIZE(a5)	size of mask

; We must wait for blitter to finish before testing BZERO flag in DMACONR.

.QB		btst		#14,DMACONR(a5)
		bne.s		.QB

; Now see if result of operation was zero, if not a collision must have
;occurred. Since this is a background test, the move will be nullified.

		btst		#13,DMACONR(a5)		blit zero?
		bne.s		.ok			yep, ignore it

		move.w		PlayerX(a4),NewX(a4)
		move.w		PlayerY(a4),NewY(a4)

.ok		rts

*****
*****	Move data for enemy
*****

MoveTable	dc.w		0,-2,50		u100	dx,dy,count
		dc.w		2,0,12		r24
		dc.w		0,2,20		d40
		dc.w		2,0,20		r40
		dc.w		0,2,30		d60
		dc.w		-2,0,32		l64
		dc.w		0,0,0			end of table

*****
*****	CHIP memory 
*****

		section		gxf,data_c

; Games copper list

MyCop	dc.w		DIWSTRT,$2c81		Top left of screen
	dc.w		DIWSTOP,$2cc1		Bottom right of screen (PAL)
	dc.w		DDFSTRT,$38		Data fetch start
	dc.w		DDFSTOP,$d0		Data fetch stop
	dc.w		BPLCON0,$4200		Select lo-res 16 colours
	dc.w		BPLCON1,0		No horizontal offset
	dc.w		BPL1MOD,0		No modulo
	dc.w		BPL2MOD,0		No modulo

Colours	ds.b		16*2*2			space for colour defenitions

	dc.w 		BPL1PTH			Plane pointers for 1st plane
CopBpls	dc.w 		0,BPL1PTL          
	dc.w		0
	dc.w		BPL2PTH			Plane pointers for 2nd plane
	dc.w		0,BPL2PTL
	dc.w		0
	dc.w		BPL3PTH			Plane pointers for 3rd plane
	dc.w		0,BPL3PTL
	dc.w		0
	dc.w		BPL4PTH			Plane pointers for 4th plane
	dc.w		0,BPL4PTL
	dc.w		0

	dc.w		$ffff,$fffe		end of list


Player		incbin		player.bm
		even

PlayerM		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16

		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16

		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16

		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16

Enemy		incbin		enemy.bm
		even

EnemyM		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16

		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16

		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16

		dc.w		%0000111111110000	1
		dc.w		%0001111111111000	2
		dc.w		%0011111111111100	3
		dc.w		%0111111111111110	4
		dc.w		%1111111111111111	5
		dc.w		%1111111111111111	6
		dc.w		%1111111111111111	7
		dc.w		%1111111111111111	8
		dc.w		%1111111111111111	9
		dc.w		%1111111111111111	10
		dc.w		%1111111111111111	11
		dc.w		%1111111111111111	12
		dc.w		%0111111111111110	13
		dc.w		%0011111111111100	14
		dc.w		%0001111111111000	15
		dc.w		%0000111111110000	16


Bgrnd1		ds.w		(32/8)*16*4
Bgrnd2		ds.w		(32/8)*16*4

Screen		incbin		screen.bm

*****
*****	Game variables
*****

		section		vars,BSS

		rsreset
PlayerX		rs.w		1
PlayerY		rs.w		1
PlayerAddr	rs.l		1
NewX		rs.w		1
NewY		rs.w		1
EnemyX		rs.w		1
EnemyY		rs.w		1
EnemyAddr	rs.l		1

T_pos		rs.l		1
T_dx		rs.w		1
T_dy		rs.w		1
T_count		rs.w		1

Dead		rs.w		1		set if hit an enemy

var_size	rs.b		0

GameVars	ds.b		var_size
