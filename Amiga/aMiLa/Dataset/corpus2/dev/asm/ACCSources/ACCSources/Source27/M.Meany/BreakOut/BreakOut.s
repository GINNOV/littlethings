
; Breakout - Stage 5:	Add code to blit blocks from map. This could allow
;			multi level games to be written ( arrrgh ).

; by M.Meany, August 1992.

; The required include files to make programming that much easier :')

		incdir		Source:Include/
		include		hardware.i		equates
		include		hw_start.i		startup code


Custom		equ		$dff000

;		lea		Custom,a5		a5->debug memory!

*****	Program proper starts here

; Write address of 1st bitplane into Copper list

Main		lea		CopBpls,a0		->copper list
		move.l		#Screen,d0		bit plane address
		move.w		d0,4(a0)		write address into
		swap		d0			copper list
		move.w		d0,(a0)

; and now address of second bitplane

		swap		d0
		add.l		#(320/8)*256,d0		calc address
		move.w		d0,12(a0)		write into copper
		swap		d0
		move.w		d0,8(a0)

; Install game Copper list here. Copper DMA not yet enabled, so it wont do
;anything at this stage!

		move.l		#MyCop,COP1LCH(a5)	addr of game list
		move.w		#0,COPJMP1(a5)		strobe to start

; Now set address of vertical blank interrupt handler that will control the
;game play.

		move.l		#NewLevel3,$6c		L3 handler routine

; Game initialisations go here before interrupt is enabled.

		lea		GameVars,a4		a4->variables block
		move.w		#160,BatX(a4)		set initial bat pos
		move.l		#Screen+(320/8)*256+10000,BatStart(a4)

		move.w		#160,BallX(a4)
		move.w		#240,BallY(a4)
		move.w		#-2,BallDY(a4)
		move.w		#3,BallDX(a4)

		move.w		#0,Dead(a4)

; Enable Blitter DMA so map can be drawn

		move.w		#SETIT!DMAEN!BLTEN,DMACON(a5)
		lea		Map,a0
		bsr		BlitBlocks
		move.w		d2,NumBlocks(a4)

; Enable level 3 interrupts

		move.w		#SETIT!INTEN!VERTB,INTENA(a5)

; Enable Copper, Blitter and Bitplane DMA

		move.w		#SETIT!DMAEN!COPEN!BPLEN,DMACON(a5)


; Wait for mouse button before quitting

MWait		btst		#6,CIAAPRA
		bne.s		MWait

; All over so return to system

		rts

*****	Level 3 interrupt handler --- does not do anything yet!!!

NewLevel3	lea		Custom,a5		hardware base
		lea		GameVars,a4		game variable block

		move.w		INTREQR(a5),d0		get bit
		and.w		#$7fff,d0		clear bit 15
		move.w		d0,INTREQ(a5)		clear request

		bsr		PlaySFX

; Call the move bat routine three times for it to be fast enough 

		bsr		MoveBat
		bsr		BlitBat
		bsr		MoveBat
		bsr		BlitBat
		bsr		MoveBat
		bsr		BlitBat

; Allow ball to be paused using fire button :'D

		tst.b		CIAAPRA
		bpl.s		.NoBall

		bsr		BlitBall
		bsr		CheckBallBlock
		bsr		MoveBall
		bsr		CheckBall

; Clear interrupt bit and exit

.NoBall				
		rte					back to User Mode

*****	Move the bat according to the joystick movement

MoveBat		bsr		TestJoy

; See if attempting to move right

		btst		#0,d2			right?
		beq.s		.TryLeft		no, skip

; User wants to go right, if move is legal update BatX

		cmpi.w		#288,BatX(a4)		at right edge
		bge.s		.Done			yep, exit routine
		addq.w		#1,BatX(a4)		no, bump position
		bra.s		.Done			and exit

; See if attempting to move left

.TryLeft	btst		#1,d2			right?
		beq.s		.Done			no, exit

; User wants to go left, if move is legal update BatX

		cmpi.w		#1,BatX(a4)		at right edge
		ble.s		.Done			yep, exit routine
		subq.w		#1,BatX(a4)		no, bump position

.Done		rts

*****	Blit the bat into 2nd bit plane

BlitBat		move.w		BatX(a4),d0		bats X coord
		
		and.l		#$f,d0			d0=scroll value
		ror.w		#4,d0			into correct position
		move.l		d0,d1			get a copy
		swap		d0			into high word
		move.w		d1,d0			and low word
		or.l		#$09f00000,d0		bltcon0: A,D: D=A

		move.w		BatX(a4),d1		bats X coord
		asr.w		#4,d1			/16
		add.w		d1,d1			x2 = byte offset

		add.l		BatStart(a4),d1		addr to start blit

.QBlit		btst		#14,DMACONR(a5)		blitter free?
		bne.s		.QBlit			no, keep waiting.

		move.l		#Bat,BLTAPTH(a5)	bat data
		move.l		d1,BLTDPTH(a5)		into bitplane
		move.l		d0,BLTCON0(a5)		control bits
		move.l		#$ffff0000,BLTAFWM(a5)	masks
		move.w		#34,BLTDMOD(a5)		bpl modulo
		move.w		#-2,BLTAMOD(a5)		bob modulo
		move.w		#6<<6!3,BLTSIZE(a5)	size of bat

		rts

*****	Move the ball

MoveBall	tst.w		Dead(a4)		still in play?
		bne.s		.Exit			nope, exit!

		move.w		BallX(a4),d0		get X position
		add.w		BallDX(a4),d0		add X displacement
		bpl.s		.TryRight		skip if in play
		neg.w		BallDX(a4)		reverse direction
		add.w		BallDX(a4),d0		and restore X
		lea		Sample2,a0
		bsr		NewSFX1		

.TryRight	cmp.w		#315,d0
		ble.s		.DoUpDown
		neg.w		BallDX(a4)		reverse direction
		add.w		BallDX(a4),d0		and restore X
		lea		Sample2,a0
		bsr		NewSFX1		

.DoUpDown	move.w		d0,BallX(a4)		save new X position
		move.w		BallY(a4),d0		get Y position
		
		add.w		BallDY(a4),d0		add Y displacement
		bpl.s		.Done			skip if in play
		neg.w		BallDY(a4)		reverse direction
		add.w		BallDY(a4),d0		and restore Y
		lea		Sample2,a0
		bsr		NewSFX1		

.Done		move.w		d0,BallY(a4)		save new Y posn
.Exit		rts

*****	Check ball is still in play

CheckBall	cmpi.w		#252,BallY(a4)		out of play?
		blt.s		.InPlay			nope, carry on!

; If we get here, ball has passed bat so we must die!

		move.w		#1,Dead(a4)		set game over flag
		bra		.Done

; Still in play, see if we have hit the bat, exit if not

.InPlay		cmp.w		#245,BallY(a4)
		blt		.Done

		move.w		BatX(a4),d4
		move.w		d4,d5
		add.w		#30,d5			max X
		subq.w		#1,d4			min X

		cmp.w		BallX(a4),d4		
		bgt.s		.Done
		cmp.w		BallX(a4),d5
		blt.s		.Done

; Must have hit the bat, set the y direction and start a sample

		move.w		#-2,BallDY(a4)
		neg.w		BallDX(a4)		
		lea		Sample1,a0
		bsr		NewSFX0		

; If hit the middle of the bat, increase DY for a more acute bounce :->)

		addq.w		#8,d4			bump min X
		subq.w		#8,d5			bump max X

		cmp.w		BallX(a4),d4		
		bgt.s		.Done
		cmp.w		BallX(a4),d5
		blt.s		.Done

		move.w		#-3,BallDY(a4)
		neg.w		BallDX(a4)				

.Done		rts

*****	Blit the ball onto the screen

; Restore background at previous position
; Save background at new position
; Blit the ball

BlitBall	move.l		BallRestore(a4),d0	get restore address
		beq.s		.DoSave			skip if none

; Got an address to restore at

.QBlit		btst		#14,DMACONR(a5)		blitter free
		bne.s		.QBlit			wait if not

		move.l		#BallS,BLTAPTH(a5)	data to restore
		move.l		d0,BLTDPTH(a5)		restore address
		move.l		#$09f00000,BLTCON0(a5)	control bits
		move.l		#$ffffffff,BLTAFWM(a5)	masks
		move.w		#36,BLTDMOD(a5)		bpl modulo
		move.w		#0,BLTAMOD(a5)		bob modulo
		move.w		#5<<6!2,BLTSIZE(a5)	size of ball

; Save background at present position. To do this the destination address
;must be calculated.

.DoSave		moveq.l		#0,d0			clear
		move.w		BallX(a4),d0		ball X coord
		asr.w		#4,d0			/16
		add.w		d0,d0			x2 = byte offset
		move.w		BallY(a4),d1		get y position
		mulu		#40,d1			x bytes/line
		add.l		#Screen+(320/8)*256,d1	add bpl start address
		add.l		d1,d0			d0 = dest addr
		move.l		d0,BallRestore(a4)	save for later
		
.QBlit1		btst		#14,DMACONR(a5)		blitter free
		bne.s		.QBlit1			wait if not

		move.l		d0,BLTAPTH(a5)		data to restore
		move.l		#BallS,BLTDPTH(a5)	restore address
		move.l		#$09f00000,BLTCON0(a5)	control bits
		move.l		#$ffffffff,BLTAFWM(a5)	masks
		move.w		#0,BLTDMOD(a5)		bpl modulo
		move.w		#36,BLTAMOD(a5)		bob modulo
		move.w		#5<<6!2,BLTSIZE(a5)	size of ball
		
; Now blit the ball through a mask onto the screen

		moveq.l		#0,d1			clear
		move.w		BallX(a4),d1		get x coord
		and.l		#$f,d1			scroll value
		ror.w		#4,d1			into high nibble
		move.w		d1,-(sp)
		swap		d1
		move.w		(sp)+,d1
		move.l		d1,old_scroll(a4)
		or.l		#$0fca0000,d1		A,B,C,D: D=AB+aC

.QBlit2		btst		#14,DMACONR(a5)		blitter free
		bne.s		.QBlit2			wait if not

		move.l		#Ball,BLTAPTH(a5)	ball gfx
		move.l		#BallM,BLTBPTH(a5)	ball mask
		move.l		d0,BLTCPTH(a5)		dest bit plane
		move.l		d0,BLTDPTH(a5)
		move.l		#$ffff0000,BLTAFWM(a5)	mask values
		move.w		#-2,BLTAMOD(a5)
		move.w		#-2,BLTBMOD(a5)
		move.w		#36,BLTCMOD(a5)
		move.w		#36,BLTDMOD(a5)
		move.l		d1,BLTCON0(a5)		control bits
		move.w		#5<<6!2,BLTSIZE(a5)	do it
		
		rts

*****	Check for ball-block collisions

CheckBallBlock	cmp.w		#200,BallY(a4)		below block?
		bge		.NoCollision		yep, skip routine

; 1. Blit ball into block plain -- if zero no collision
; 2. if collision, remove the block now
; 3. blit R, T, B and L Mask into ball plane --- 1st one to score => that
;    side was hit. Take appropriate action!
; 4. Dec num blocks remaining
; 5. exit

		move.l		old_scroll(a4),d5		bltcon0
		or.l		#$0aa00000,d5		usage & minterm

		move.l		BallRestore(a4),d0
		sub.l		#(320/8)*256,d0

.QBlit1		btst		#14,DMACONR(a5)
		bne.s		.QBlit1
		
		move.l		#BallCM,BLTAPTH(a5)		ball mask
		move.l		d0,BLTCPTH(a5)	screen
		move.w		#0,BLTAMOD(a5)			ball mod
		move.w		#36,BLTCMOD(a5)			scrn mod
		move.l		#$ffff0000,BLTAFWM(a5)		masks
		move.l		d5,BLTCON0(a5)			scrll & use
		move.w		#5<<6!2,BLTSIZE(a5)	do it
		
.QBlit2		btst		#14,DMACONR(a5)
		bne.s		.QBlit2

; See if a collision occurred

		btst		#13,DMACONR(a5)		check blitter Z flag
		bne		.NoCollision		nope!

; Collision has occurred. Wipe the block!

		moveq.l		#0,d0
		moveq.l		#0,d1
		move.w		BallX(a4),d0
		addq.w		#2,d0			X center of ball
		move.w		BallY(a4),d1
		addq.w		#2,d1			Y center of ball

		asr.w		#4,d0			/16 ( block width )
		add.w		d0,d0			byte offset

		divu		#10,d1
		and.l		#$0000ffff,d1
		mulu		#10,d1
		
		add.w		d1,d1
		move.l		d1,d2
		asl.w		#2,d2
		add.w		d2,d1
		asl.w		#2,d1			x40 = byte offset

		add.w		d1,d0
		add.l		#Screen,d0		addr of block

		move.l		d0,BLTDPTH(a5)		addr
		move.w		#38,BLTDMOD(a5)		modulo
		move.l		#$01000000,BLTCON0(a5)	control
		move.w		#10<<6!1,BLTSIZE(a5)	block size!

; Initiate a sample for reward!!!


		lea		Sample3,a0
		bsr		NewSFX0		

; We must now decide which side of the block has been hit. To do this 4
;masks, one for each side of the block, are blitted into the balls bitplane.
;If one of these 'hits' the ball then we assume that side of the bat has
;been hit -- if there is a cock-up and no mask hit's the ball, the ball
;carries on the way it was going!

		add.l		#(320/8)*256,d0		correct plane addr

.QBlit3		btst		#14,DMACONR(a5)
		bne.s		.QBlit3
;top of block
		move.l		#T_Mask,BLTAPTH(a5)		Mask
		move.l		d0,BLTCPTH(a5)	screen
		move.w		#0,BLTAMOD(a5)			Mask mod
		move.w		#38,BLTCMOD(a5)			scrn mod
		move.l		#$ffffffff,BLTAFWM(a5)		masks
		move.l		#$0aa00000,BLTCON0(a5)		useage
		move.w		#10<<6!1,BLTSIZE(a5)	do it
		
.QBlit4		btst		#14,DMACONR(a5)
		bne.s		.QBlit4

; See if a collision occurred

		btst		#13,DMACONR(a5)		check blitter Z flag
		bne.s		.QBlit5			nope!

		neg.w		BallDY(a4)		bounce
		bra.s		.QBlit7

.QBlit5		btst		#14,DMACONR(a5)
		bne.s		.QBlit5
;bottom of block
		move.l		#B_Mask,BLTAPTH(a5)		Mask
		move.l		d0,BLTCPTH(a5)	screen
		move.w		#0,BLTAMOD(a5)			Mask mod
		move.w		#38,BLTCMOD(a5)			scrn mod
		move.l		#$ffffffff,BLTAFWM(a5)		masks
		move.l		#$0aa00000,BLTCON0(a5)		useage
		move.w		#10<<6!1,BLTSIZE(a5)	do it
		
.QBlit6		btst		#14,DMACONR(a5)
		bne.s		.QBlit6

; See if a collision occurred

		btst		#13,DMACONR(a5)		check blitter Z flag
		bne.s		.QBlit7			nope!

		neg.w		BallDY(a4)		bounce

.QBlit7		btst		#14,DMACONR(a5)
		bne.s		.QBlit7
;left side of block
		move.l		#L_Mask,BLTAPTH(a5)		Mask
		move.l		d0,BLTCPTH(a5)	screen
		move.w		#0,BLTAMOD(a5)			Mask mod
		move.w		#38,BLTCMOD(a5)			scrn mod
		move.l		#$ffffffff,BLTAFWM(a5)		masks
		move.l		#$0aa00000,BLTCON0(a5)		useage
		move.w		#10<<6!1,BLTSIZE(a5)	do it
		
.QBlit8		btst		#14,DMACONR(a5)
		bne.s		.QBlit8

; See if a collision occurred

		btst		#13,DMACONR(a5)		check blitter Z flag
		bne.s		.QBlit9			nope!

		neg.w		BallDX(a4)		bounce
		bra.s		.NoCollision

.QBlit9		btst		#14,DMACONR(a5)
		bne.s		.QBlit9
;right side of block
		move.l		#R_Mask,BLTAPTH(a5)		Mask
		move.l		d0,BLTCPTH(a5)	screen
		move.w		#0,BLTAMOD(a5)			Mask mod
		move.w		#38,BLTCMOD(a5)			scrn mod
		move.l		#$ffffffff,BLTAFWM(a5)		masks
		move.l		#$0aa00000,BLTCON0(a5)		useage
		move.w		#10<<6!1,BLTSIZE(a5)	do it
		
.QBlit10	btst		#14,DMACONR(a5)
		bne.s		.QBlit10

; See if a collision occurred

		btst		#13,DMACONR(a5)		check blitter Z flag
		bne.s		.NoCollision		nope!

		neg.w		BallDX(a4)		bounce

.NoCollision	rts

*****	Check joystick left/right

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

*****	Sample player

; Vertical blank interrupt driven sample player.

; At present only one channel is used, but a seperate structure could be
;maintained on all four channels if required.

PlaySFX		lea		Channel0(a4),a0		a0->struct

; See if a new sample has been requested

		tst.w		ch_New(a0)		new sample?
		beq.s		.Try1			skip if not
		
; New sample, start playing it!

		move.l		ch_Addr(a0),AUD0LCH(a5) set new address
		move.w		ch_Len(a0),AUD0LEN(a5)	set new length
		move.w		#64,AUD0VOL(a5)		set volume
		move.w		#$12c,AUD0PER(a5)	set period
		move.w		#SETIT!AUD0EN,DMACON(a5) start playing

; When audio DMA channel is ready for next sample it will generate a level 4
;interrupt. Wait for this interrupt and then write address of ' quiet '
;sample. This will ensure sample only plays once that we can hear. I am
;assuming there is not a Level 4 interrupt enabled!

		move.w		#AUD0,INTREQ(a5)	clear bit

.WaitL4		btst		#7,INTREQR+1(a5)	wait for acceptance
		beq.w		.WaitL4

		move.l		#NullSample,AUD0LCH(a5)	quiet sound
		move.w		#4,AUD0LEN(a5)		it's length

		move.w		#0,ch_New(a0)		clear flag

.Try1		lea		Channel1(a4),a0		a0->struct

; See if a new sample has been requested

		tst.w		ch_New(a0)		new sample?
		beq.s		.Done			skip if not
		
; New sample, start playing it!

		move.l		ch_Addr(a0),AUD1LCH(a5) set new address
		move.w		ch_Len(a0),AUD1LEN(a5)	set new length
		move.w		#64,AUD1VOL(a5)		set volume
		move.w		#$12c,AUD1PER(a5)	set period
		move.w		#SETIT!AUD1EN,DMACON(a5) start playing

; When audio DMA channel is ready for next sample it will generate a level 4
;interrupt. Wait for this interrupt and then write address of ' quiet '
;sample. This will ensure sample only plays once that we can hear. I am
;assuming there is not a Level 4 interrupt enabled!

		move.w		#AUD1,INTREQ(a5)	clear bit

.WWaitL4	btst		#0,INTREQR(a5)		wait for acceptance
		beq.w		.WWaitL4

		move.l		#NullSample,AUD1LCH(a5)	quiet sound
		move.w		#4,AUD1LEN(a5)		it's length

		move.w		#0,ch_New(a0)		clear flag

.Done		rts

*****	request a sample on channel 0

; Present a new sample to sample player. This stops current sample so channel
;is free at start of next vert blank.

; Entry		a0->raw sample structure

NewSFX0		move.w		#AUD0EN,DMACON(a5)	Kill current sound
		lea		Channel0(a4),a1		a1->channel struct
		move.w		(a0)+,ch_Len(a1)	set sample length
		move.l		a0,ch_Addr(a1)		set address
		move.w		#1,ch_New(a1)		signal new sample
		rts					and exit

*****	request a sample on channel 1

; Present a new sample to sample player. This stops current sample so channel
;is free at start of next vert blank.

; Entry		a0->raw sample structure

NewSFX1		move.w		#AUD1EN,DMACON(a5)	Kill current sound
		lea		Channel1(a4),a1		a1->channel struct
		move.w		(a0)+,ch_Len(a1)	set sample length
		move.l		a0,ch_Addr(a1)		set address
		move.w		#1,ch_New(a1)		signal new sample
		rts					and exit

*****	Draw the blocks according to the map

; Entry	a0->map data

; Exit	d2=number of blocks drawn - use as a counter for end of game!!

BlitBlocks	move.l		#Screen,d7		1st line of blocks
		moveq.l		#9,d5			line counter ( -1 )
		move.l		#Block,d6		data address
		moveq.l		#0,d2			block counter

; prep blitter registers that are not going to change

		move.w		#0,BLTAMOD(a5)
		move.w		#38,BLTDMOD(a5)
		move.l		#-1,BLTAFWM(a5)
		move.l		#$09f00000,BLTCON0(a5)	use A,D: D=A

.Outer		moveq.l		#0,d3			byte offset

		moveq.l		#19,d4			blocks/line ( -1 )

.Inner		move.l		d3,d0			byte offset
		addq.w		#2,d3			bump for next time
		add.l		d7,d0			+ start address
		
		move.l		#Blank,d1		default blank
		tst.w		(a0)+			blit a block?
		beq.s		.Blit			no, so skip

		move.l		#Block,d1		tile gfx
		addq.w		#1,d2			bump counter
		
.Blit		btst		#14,DMACONR(a5)		blitter free
		bne.s		.Blit			no, keep waiting
		
		move.l		d1,BLTAPTH(a5)
		move.l		d0,BLTDPTH(a5)
		move.w		#10<<6!1,BLTSIZE(a5)
		
		dbra		d4,.Inner
		
		add.w		#40*10,d7
		dbra		d5,.Outer
		
		rts

*****	CHIP memory 

		section		gxf,data_c

; Games copper list

MyCop	dc.w		DIWSTRT,$2c81		Top left of screen
	dc.w		DIWSTOP,$2cc1		Bottom right of screen (PAL)
	dc.w		DDFSTRT,$38		Data fetch start
	dc.w		DDFSTOP,$d0		Data fetch stop
	dc.w		BPLCON0,$2200		Select lo-res 2 colours
	dc.w		BPLCON1,0		No horizontal offset
	dc.w		BPL1MOD,0		No modulo
	dc.w		BPL2MOD,0		No modulo

	dc.w		COLOR00,$0000		black background
	dc.w 		COLOR01,$0d00		red   ( block )
	dc.w		COLOR02,$000f		blue  ( bat )
	dc.w		COLOR03,$0fff		white ( ball )

	dc.w 		BPL1PTH			Plane pointers for 1st plane
CopBpls	dc.w 		0,BPL1PTL          
	dc.w		0
	dc.w		BPL2PTH			Plane pointers for 2nd plane
	dc.w		0,BPL2PTL
	dc.w		0

	dc.w		$ffff,$fffe		end of list

; bat gfx data. 16 pixels wide and 6 pixels high. Will appear only in second
;bitplane!

Bat	dc.w		$7fff,$fffe
	dc.w		$7fff,$fffe
	dc.w		$7fff,$fffe
	dc.w		$7fff,$fffe
	dc.w		$7fff,$fffe
	dc.w		$7fff,$fffe

Ball	dc.w		%0000000000000000	ball gfx
	dc.w		%0011000000000000
	dc.w		%0111100000000000
	dc.w		%0011000000000000
	dc.w		%0000000000000000

BallM	dc.w		%0011000000000000	ball draw mask
	dc.w		%0111100000000000
	dc.w		%1111110000000000
	dc.w		%0111100000000000
	dc.w		%0011000000000000

BallCM	dc.w		%0000000000000000	ball collision mask
	dc.w		%0000000000000000
	dc.w		%0011000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000

BallS	dc.w		0,0,0,0,0,0,0,0,0,0	ball background save area

Block	dc.w		%0000000000000000
	dc.w		%0111111111111110
	dc.w		%0111111111111110
	dc.w		%0111111111111110
	dc.w		%0111111111111110
	dc.w		%0111111111111110
	dc.w		%0111111111111110
	dc.w		%0111111111111110
	dc.w		%0111111111111110
	dc.w		%0000000000000000

; The following collision masks are used to determine which side of a block
;the ball has hit!

T_Mask	dc.w		%0000000000000000
	dc.w		%0111111111111110
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000

R_Mask	dc.w		%0000000000000000
	dc.w		%0000000000000010
	dc.w		%0000000000000010
	dc.w		%0000000000000010
	dc.w		%0000000000000010
	dc.w		%0000000000000010
	dc.w		%0000000000000010
	dc.w		%0000000000000010
	dc.w		%0000000000000010
	dc.w		%0000000000000000

B_Mask	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0000000000000000
	dc.w		%0111111111111110
	dc.w		%0000000000000000

L_Mask	dc.w		%0000000000000000
	dc.w		%0100000000000000
	dc.w		%0100000000000000
	dc.w		%0100000000000000
	dc.w		%0100000000000000
	dc.w		%0100000000000000
	dc.w		%0100000000000000
	dc.w		%0100000000000000
	dc.w		%0100000000000000
	dc.w		%0000000000000000

Blank	dc.w		0,0,0,0,0,0,0,0,0,0

;Map	dc.w		1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;	dc.w		1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1
;	dc.w		1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1
;	dc.w		1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1
;	dc.w		1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1
;	dc.w		1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1
;	dc.w		1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1
;	dc.w		1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1
;	dc.w		1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1
;	dc.w		1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

Map	dc.w		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w		0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0
	dc.w		0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0
	dc.w		0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
	dc.w		0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
	dc.w		0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
	dc.w		0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
	dc.w		0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0
	dc.w		0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0
	dc.w		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Sample1		dc.w		SMP1LEN>>1	word length of sample
SMP1		incbin		bounce.sam	sample itself
SMP1LEN		equ		*-SMP1

Sample2		dc.w		SMP2LEN>>1	word length of sample
SMP2		incbin		bounce1.sam	sample itself
SMP2LEN		equ		*-SMP2

Sample3		dc.w		SMP3LEN>>1	word length of sample
SMP3		incbin		bounce2.sam	sample itself
SMP3LEN		equ		*-SMP3

NullSample	ds.w		4


*****	CHIP BSS data - minimise disk usage

		section		bpls,BSS_C

Screen	ds.b		(320/8)*256*2

;Custom	ds.w		256

*****	Game variables

		section		vars,BSS

		rsreset
ch_New		rs.w		1		set to play new sound
ch_Addr		rs.l		1		addr of raw data
ch_Len		rs.w		1		length of sample
ch_SIZEOF	rs.b		0

		rsreset
BatX		rs.w		1		bats X pixel position
BatStart	rs.l		1		start of raster line for bat
BallX		rs.w		1
BallY		rs.w		1
BallDX		rs.w		1
BallDY		rs.w		1
BallRestore	rs.l		1		address to restore
old_scroll	rs.l		1		BLTCON0 scroll values
NumBlocks	rs.w		1		blocks on a level
Dead		rs.w		1		flag, non zero => dead!
Channel0	rs.b		ch_SIZEOF	audio struct
Channel1	rs.b		ch_SIZEOF	audio struct

var_size	rs.b		0

GameVars	ds.b		var_size
