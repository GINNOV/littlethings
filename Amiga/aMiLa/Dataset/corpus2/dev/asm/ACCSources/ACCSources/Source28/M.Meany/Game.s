
; We're getting their :-D    
;			     ~    ~
;			     '    '
;
;			       |_
;			   \_______/
;			    \|_|_|/

		incdir		Source:Include/marks/hardware/
		include		source:Include/hardware.i
		include		HW_macros.i
		include		hw_start.i
		include		HW_sound.i

	
Main		lea		Vars,a4
		move.w		#5,UpCounter(a4)
		move.w		#12,BounceHt(a4)

; Set default x,y position for this level

		lea		Player,a0
		move.l		InitialXY,b_X(a0)

		COPBPLC		Cop1Planes,OnScreen,256*320/8,4
;		STARTCOP	#Copper1

; Enable blitter,copper and bitplane DMA

		move.w		#SETIT!DMAEN!BLTEN!COPEN!BPLEN,DMACON(a5)

; Initialise second copper list

		COPBPLC		Cop2Planes,OffScreen,256*320/8,4

; Write new level 3 vector

		move.l		#GameLevel3,$6c

; Enable vert blank interrupts only

		move.w		#SETIT!INTEN!VERTB,INTENA(a5) enable level 3

; Wait for mouse to be pressed

Mouse		btst		#6,CIAAPRA
		bne.s		Mouse

		rts					go home

		*********************************
		*	Level 3 Interrupt	*
		*********************************

GameLevel3	lea		Vars,a4			a4->variables block
		lea		$dff000,a5		set hardware pointer

		bsr		SwapCop			do double buffer

		not.w		Joy(a4)

		move.w		#$0fff,$dff180		**** for timing

		bsr		SmpPlayer		play sound fx

		bsr		Restore

; Movement and collision routines go just here

		bsr		MovePlayer

		bsr		Save
		bsr		Draw

		move.w		#$0000,$dff180		**** for timing

		move.w		#COPER!BLIT!VERTB,INTREQ(a5)
		rte

		*********************************
		*	Swap Copper Lists	*
		*********************************
		
; This routine basically takes care of screen switching for double buffering
;purposes. The address of the screen in 

SwapCop		lea		Copper,a0
		move.l		(a0),$dff080
		move.w		#0,$dff088

		move.l		(a0),d0
		move.l		4(a0),(a0)
		move.l		d0,4(a0)
		
		lea		Screen,a0
		move.l		(a0),d0
		move.l		4(a0),(a0)
		move.l		d0,4(a0)
		
		rts

		*********************************
		*     Restore Backgrounds	*
		*********************************

; Restores any background corrupted by bobs

Restore		move.l		#Player,d0		d0->1st bob
		move.w		#16<<6!2,d4		blitsize
		moveq.l		#36,d5			bob & screen modulo
		move.l		#$09f00000,d6		use A,D: A=D
		moveq.l		#-1,d7			masks

.loop		move.l		d0,a0			a0->1st bob
		move.l		b_Addr1(a0),d3		get address
		beq.s		.NoBlit			skip if not one

		tst.w		b_On(a0)		bob active
		beq.s		.NoBlit			no, so skip it

		QBLITTER				wait for blitter
		
		move.l		b_Save1(a0),BLTAPTH(a5)	source
		move.l		d3,BLTDPTH(a5)		destination
		move.w		#0,BLTAMOD(a5)		modulos
		move.w		d5,BLTDMOD(a5)
		move.l		d6,BLTCON0(a5)		usage
		move.l		d7,BLTAFWM(a5)		masks
		move.w		d4,BLTSIZE(a5)		start the blit

; bump pointer

		add.l		#(320/8)*256,d3		bump to next bpl

; Save 2nd plane

		QBLITTER
		
		move.l		d3,BLTDPTH(a5)		new source
		move.w		d4,BLTSIZE(a5)		start blit

; bump pointer

		add.l		#(320/8)*256,d3		bump to next bpl

; Save 3rd plane

		QBLITTER
		
		move.l		d3,BLTDPTH(a5)		new source
		move.w		d4,BLTSIZE(a5)		start blit

; bump pointer

		add.l		#(320/8)*256,d3		bump to next bpl

; Save 4th plane

		QBLITTER
		
		move.l		d3,BLTDPTH(a5)		new source
		move.w		d4,BLTSIZE(a5)		start blit

.NoBlit		move.l		(a0),d0			get ptr to next bob
		bne		.loop			and loop while valid
		
		rts

		*********************************
		*       Save Backgrounds	*
		*********************************

; Calculates the address at which a bob is to be blitted and saves a copy
;of the background at this address.

Save		move.l		#Player,d3		d3->bob

		move.w		#16<<6!2,d4		blitsize
		moveq.l		#36,d5			bob & screen modulo
		move.l		#$09f00000,d6		use A,D: A=D
		moveq.l		#-1,d7			masks

.loop		move.l		d3,a0			a0->1st bob

; Clear last restore address

		clr.l		b_Addr1(a0)		clear current addr

; See if new address needs calculating

		tst.w		b_On(a0)		bob active
		beq		.NoBlit			no, so skip it

; Calculate new address for x,y position.

		moveq.l		#0,d0			clear registers
		move.l		d0,d1
		move.w		b_X(a0),d0
		asr.w		#4,d0			X / 16
		move.w		b_Y(a0),d1
		asl.w		#2,d1			Y x 4
		TIMES10		d1			Y x 40
		add.w		d0,d1
		add.w		d0,d1
		add.l		Screen,d1		d1=new address
		move.l		d1,b_Addr1(a0)		save in structure

		moveq.l		#3,d0			loop counter

.Bloop		QBLITTER				wait for blitter

; Save 1st plane
		
		move.l		d1,BLTAPTH(a5)		source
		move.l		b_Save1(a0),BLTDPTH(a5)	destination
		move.w		d5,BLTAMOD(a5)		modulos
		move.w		#0,BLTDMOD(a5)
		move.l		d6,BLTCON0(a5)		usage
		move.l		d7,BLTAFWM(a5)		masks
		move.w		d4,BLTSIZE(a5)		start the blit

; bump pointer

		add.l		#(320/8)*256,d1		bump to next bpl

; Save 2nd plane

		QBLITTER
		
		move.l		d1,BLTAPTH(a5)		new source
		move.w		d4,BLTSIZE(a5)		start blit

; bump pointer

		add.l		#(320/8)*256,d1		bump to next bpl

; Save 3rd plane

		QBLITTER
		
		move.l		d1,BLTAPTH(a5)		new source
		move.w		d4,BLTSIZE(a5)		start blit

; bump pointer

		add.l		#(320/8)*256,d1		bump to next bpl

; Save 4th plane

		QBLITTER
		
		move.l		d1,BLTAPTH(a5)		new source
		move.w		d4,BLTSIZE(a5)		start blit

.NoBlit		move.l		(a0),d3			get ptr to next bob
		bne		.loop			and loop while valid
		
		rts


		*********************************
		*     Blit Bobs Onto Screen	*
		*********************************

; Address at which to blit the bob has already been calculated. If this is
;zero, the bob is not drawn. The background save pointers are swapped by
;this routine to account for double buffering.

Draw		move.l		#Player,d7		d7->the player

.loop		move.l		d7,a0			a0->bob

; swap restore address, retaining a copy of the screen address

		move.l		b_Addr1(a0),d6		we need this addr
		move.l		b_Addr2(a0),b_Addr1(a0)	
		move.l		d6,b_Addr2(a0)

; swap the pointers to the save memory block, no need to keep pointer

		move.l		b_Save1(a0),d0		
		move.l		b_Save2(a0),b_Save1(a0)	
		move.l		d0,b_Save2(a0)

; calculate scroll value for this bob from it's x coordinate

		moveq.l		#0,d0
		move.w		b_X(a0),d0		get X
		and.w		#$f,d0			mask unwanted bits
		ror.w		#4,d0			into high nibble
		move.w		d0,d1
		swap		d0
		move.w		d1,d0
		or.l		#$0fca0000,d0		and minterm and usage

; blit the bob, through it's draw mask

		move.l		b_Data(a0),d2		bob gfx
		move.l		b_Mask(a0),d3		bob mask
		moveq.l		#3,d4			loop counter

.Loop
		QBLITTER
		
		move.l		d3,BLTAPTH(a5)		mask
		move.l		d2,BLTBPTH(a5)		gfx
		move.l		d6,BLTCPTH(a5)		playfield
		move.l		d6,BLTDPTH(a5)		playfield
		move.l		#$ffff0000,BLTAFWM(a5)	blitter masks
		move.w		#-2,BLTAMOD(a5)
		move.w		#-2,BLTBMOD(a5)
		move.w		#36,BLTCMOD(a5)
		move.w		#36,BLTDMOD(a5)
		move.l		d0,BLTCON0(a5)
		move.w		#16<<6!2,BLTSIZE(a5)
		
		add.l		#(320/8)*256,d6		bump plane pointer
		add.l		#(16/8)*16,d2		bump gfx pointer
		add.l		#(16/8)*16,d3		bump mask pointer
		dbra		d4,.Loop
		
		move.l		(a0),d7			next bob
		bne		.loop			loop if valid
		
		rts

		*********************************
		*  Check if player is falling	*
		*********************************

; Complicated one this! If player is not moving left or right, which is
;defined by a preset path, then a check is made to see if he is falling.
;If he's not falling, he must be rising so a joystick test is preformed
;to see if he wants to go left or right.

; Each move routine takes care of collisions appropriate to the direction
;of motion. The players x,y cordinates returned by the appropriate
;routines will always be valid screen positions, each routine calls an
;appropriate clipping routine to ensure the player bounces off the edge of
;the play area.

; The variable P_Move contains a pointer to the relevant movement routine.
;A number of routines are supplied to allow a wide variety of movement
;patterns. The standard routine, 'BouncePlyr', simply moves the players
;bob up and down on the spot. 'BigBounce' temporarily alters the height
;bounced to by the palyer, thus allowing the fire button to initiate higher
;than normal bounces -- these use NRG!

; See if a preset routine is being used, if so call it and exit.

MovePlayer	move.l		P_Move,d0		get address
		beq.s		.DoUpDown		not a preset
		move.l		d0,a0			a0->subroutine
		jsr		(a0)			jump to routine
		rts

; Determine direction in which player is moving

.DoUpDown	lea		Player,a0		a0->players bob
		tst.w		GoingUp(a4)		flag set
		bne.s		.GoUp			yep, don't fall!

; Player is falling, decrease y coordinate and test for collision. If no
;collision occurs, y coord is updated else it stays the same.

		moveq.l		#0,d1			clear
		move.l		d0,d2			these
		move.w		b_X(a0),d1
		move.w		b_Y(a0),d2
		addq.l		#2,d2
		bsr		Background		can we fall?
		tst.w		d0
		bne.s		.tryBounce
		move.w		d2,b_Y(a0)		update Y
		rts

; Hit something, see if we can bounce

.tryBounce	bsr		DownBounce

; If we get here, player has hit something on the way down. Reverse direction
;and play a 'boing' sample.

.done_down	move.w		BounceHt(a4),UpCounter(a4)
		move.w		#1,GoingUp(a4)
		lea		Bounce,a0
		moveq.l		#0,d0
		bsr		PlaySample

; If fire button is pressed, allow player to bounce higher

		moveq.l		#12,d0
		tst.b		CIAAPRA
		bmi.s		.reallydone
		moveq.l		#40,d0
		
.reallydone	move.w		d0,UpCounter(a4)
		rts

; Player is moving up. Bump y coordinate and check for collision

.GoUp		moveq.l		#0,d1			clear
		move.l		d0,d2			these
		move.w		b_X(a0),d1
		move.w		b_Y(a0),d2
		subq.l		#2,d2
		bsr		Background		can we fall?
		tst.w		d0
		bne.s		.done_up
		subq.w		#1,UpCounter(a4)
		beq.s		.done_up1
		move.w		d2,b_Y(a0)		update Y
		bra		.DoLeftRight

; If hit something going up play a sample and reverse direction

.done_up	bsr		UpBounce

		lea		Crash,a0
		moveq.l		#1,d0
		bsr		PlaySample

.done_up1	move.w		#0,GoingUp(a4)
		rts

; See if while moving up, player wants to go left or right

.DoLeftRight	bsr		DoStick

		btst		#0,d2			going right?
		beq.s		.TryLeft		no, try left
		move.l		#MoveRight,P_Move	else set subroutine
		move.l		#LR_Table,TablePos	and move table
		rts					and return

.TryLeft	btst		#2,d2			going left?
		beq.s		.all_done		no, exit!
		move.l		#MoveLeft,P_Move	else set subroutine
		move.l		#LR_Table,TablePos	and move table
.all_done	rts					and exit


*****

; Player was moving down and hit something. See if a slant was hit and if so
;cause player to jump away from it!

; Entry		d1=Proposed x coordinate
;		d2=Proposed y coordinate

DownBounce	moveq.l		#0,d5			clear flag

; See if we can bounce right

		addq.w		#2,d1
		bsr		Background
		tst.w		d0
		bne.s		.Tryleft
		moveq.l		#1,d5

.Tryleft	subq.w		#4,d1
		bsr		Background
		tst.w		d0
		bne.s		.Decide
		or.w		#2,d5

; When we get here, bits 0 and 1 of d5 will be set according to available
;directions to bounce. If both bits are the same do nothing, otherwise
;bounce in direction of no collision!

.Decide		tst.w		d5
		bne.s		.tryboth
		rts

.tryboth	cmp.w		#3,d5
		bne.s		.BounceLeft
		rts
		
.BounceLeft	btst		#0,d5
		beq.s		.BounceRight
		tst.b		CIAAPRA
		bpl.s		.FirePressed
		bsr		DoStick
		btst		#2,d2
		bne.s		.thanks1
		move.l		#MoveRight,P_Move	else set subroutine
		move.l		#LR_Table,TablePos	and move table
.thanks1	rts					and return

.BounceRight	tst.b		CIAAPRA
		bpl.s		.FirePressed
		bsr		DoStick
		btst		#0,d2
		bne.s		.thanks2		
		move.l		#MoveLeft,P_Move	else set subroutine
		move.l		#LR_Table,TablePos	and move table
.thanks2	rts					and return

.FirePressed	move.w		#1,GoingUp(a4)
		rts

*****

; Player was moving up and hit something. See if a slant was hit and if so
;cause player to jump away from it!

; Entry		d1=Proposed x coordinate
;		d2=Proposed y coordinate

UpBounce	moveq.l		#0,d5			clear flag

; See if we can bounce right

		addq.w		#2,d1
		bsr		Background
		tst.w		d0
		bne.s		.Tryleft
		moveq.l		#1,d5

.Tryleft	subq.w		#4,d1
		bsr		Background
		tst.w		d0
		bne.s		.Decide
		or.w		#2,d5

; When we get here, bits 0 and 1 of d5 will be set according to available
;directions to bounce. If both bits are the same do nothing, otherwise
;bounce in direction of no collision!

.Decide		tst.w		d5
		bne.s		.tryboth
		rts

.tryboth	cmp.w		#3,d5
		bne.s		.BounceLeft
		rts
		
.BounceLeft	btst		#0,d5
		beq.s		.BounceRight
		move.l		#MoveRight,P_Move	else set subroutine
		move.l		#LR_Table,TablePos	and move table
.thanks1	rts					and return

.BounceRight	move.l		#MoveLeft,P_Move	else set subroutine
		move.l		#LR_Table,TablePos	and move table
.thanks2	rts					and return

*****

MoveRight	lea		Player,a0
		move.l		TablePos,a1		a1->move table
		moveq.l		#0,d1
		move.l		d1,d2
				
		move.w		b_X(a0),d1
		move.w		b_Y(a0),d2
		
		addq.w		#2,d1
		add.w		(a1)+,d2
		
		bsr		Background
		tst.w		d0
		bne.s		.crash

		move.w		d1,b_X(a0)
		move.w		d2,b_Y(a0)
		
		move.l		a1,TablePos
		cmp.l		#10,(a1)
		bne.s		.done
		
.crash		move.l		#0,P_Move		clear subroutine
		move.w		#0,GoingUp(a4)		clear up flag

.done		rts

MoveLeft	lea		Player,a0
		move.l		TablePos,a1		a1->move table
		moveq.l		#0,d1
		move.l		d1,d2
				
		move.w		b_X(a0),d1
		move.w		b_Y(a0),d2
		
		subq.w		#2,d1
		add.w		(a1)+,d2
		
		bsr		Background
		tst.w		d0
		bne.s		.crash

		move.w		d1,b_X(a0)
		move.w		d2,b_Y(a0)
		
		move.l		a1,TablePos
		cmp.l		#10,(a1)
		bne.s		.done
		
.crash		move.l		#0,P_Move		clear subroutine
		move.w		#0,GoingUp(a4)		clear up flag

.done		rts

		*********************************
		*       Background Check	*
		*********************************

; Blits a bob into the background to see if it has hit something!

; Entry		a0->bob
;		d1=X position
;		d2=Y position

; Exit		d0=0 if no collision occurred.

; Corrupt	d0

Background	PUSH		d1-d3/a0

		move.l		d1,d0			copy X position

; From the x position, calculate the number of bytes from left edge of screen
;Note, this must be an even address as the blitter deals with words only

		asr.w		#4,d0			/16
		add.w		d0,d0			byte offset

; From the y position, calculate the number of bytes from the top of the
;screen to the start of the line in which the bob starts

		asl.w		#2,d2			x 4
		TIMES10		d2			x 40 (Y*line width)

; Add the two offsets together to form number of bytes from top left of
;screen and then add address of screen memory to form address of first byte
;in which the bob will appear.

		add.w		d2,d0			add offsets
		add.l		Screen,d0		add scrn start addr
		add.l		#(320/8)*256*3,d0	add offset to bpl4

; Must now form bltcon0.

; usage:	A=mask, C=collision plane		($a)
; minterm	AC (note no destination)		($a0)

		and.w		#$f,d1			isolate scroll bits
		ror.w		#4,d1			into high nibble
		move.w		d1,-(sp)		save
		swap		d1
		move.w		(sp)+,d1
		or.l		#$0aa00000,d1		minterm & usage

; To check move, one plane of draw mask will be blitted into plane 4 of
;playfields screen memory

		QBLITTER
		
		move.l		b_Mask(a0),BLTAPTH(a5)	mask
		move.l		d0,BLTCPTH(a5)		collision plane
		move.w		#-2,BLTAMOD(a5)
		move.w		#36,BLTCMOD(a5)
		move.l		#$ffff0000,BLTAFWM(a5)	blitter mask
		move.l		d1,BLTCON0(a5)		control bits
		move.w		#16<<6!2,BLTSIZE(a5)	size of mask

; We must wait for blitter to finish before testing BZERO flag in DMACONR.

		QBLITTER
		
; Now see if result of operation was zero, if not a collision must have
;occurred. Since this is a background test, the move will be nullified.

		moveq.l		#0,d0			return code
		btst		#13,DMACONR(a5)		blit zero?
		bne.s		.done			yep, ignore it

		moveq.l		#1,d0			set for collision

.done		PULL		d1-d3/a0
		rts

		*********************************
		*    Check Joystick In Port2	*
		*********************************

; Subroutine to read joystick movement in port 1. Returns a code in register
;d2 according to the following ( bits set in a clockwise direction ):

;	bit 0 set = right movement
;	bit 1 set = down movement
;	bit 2 set = left movemwnt
;	bit 3 set = up movement

; Assumes a5 -> hardware registers ( ie a5 = $dff000 ).

; Corrupts d0, d1 and d2.

; M.Meany, Aug 91.


DoStick		moveq.l		#0,d2
		move.w		JOY1DAT(a5),d0		read stick

		btst		#1,d0			right ?
		beq.s		.test_left		if not jump!

		or.w		#1,d2			set right bit

.test_left	btst		#9,d0			left ?
		beq.s		.test_updown		if not jump

		or.w		#4,d2			set left bit

.test_updown	move.w		d0,d1			copy JOY1DAT
		lsr.w		#1,d1			shift u/d bits
		eor.w		d1,d0			exclusive or 'em
		btst		#0,d0			down ?
		beq.s		.test_down		if not jump

		or.w		#2,d2			set down bit

.test_down	btst		#8,d0			up ?
		beq.s		.no_joy			if not jump

		or.w		#8,d2			set up bit

.no_joy		rts

		*********************************
		*     Structure Defenitions	*
		*********************************

*** Basic Bob structure

; All bobs will be 16x16x4, so BLITSIZE etc will remain constant.

		rsreset
b_Next		rs.l		1		pointer to next bob
b_X		rs.w		1		x position on screen
b_Y		rs.w		1		y position on screen
b_ID		rs.w		1		bobs ID
b_On		rs.w		1		0=>don't blit this bob!
b_Data		rs.l		1		pointer to bobs data
b_Mask		rs.l		1		pointer to bobs mask
b_Save1		rs.l		1		pointer to bgrnd save 1
b_Addr1		rs.l		1		addr to restore
b_Save2		rs.l		1		pointer to bgrnd save 2
b_Addr2		rs.l		1		addr to restore
b_Special	rs.l		1		extension pointer
b_SIZEOF	rs.w		0		size of structure

		*********************************
		*	   Static Data		*
		*********************************

;Dummy		ds.w		512

Screen		dc.l		OnScreen
		dc.l		OffScreen

Copper		dc.l		Copper1
		dc.l		Copper2

Player		dc.l		0		next
		dc.w		100		X
		dc.w		100		Y
		dc.w		1		ID
		dc.w		1		blit it
		dc.l		Player_Gfx	Data
		dc.l		Player_Mask	Mask
		dc.l		P_Save1		Save1
		dc.l		0		Addr1
		dc.l		P_Save2		Save2
		dc.l		0		Addr2
		dc.l		0		Special

TablePos	dc.l		0		table offsett
P_Move		dc.l		0		address of move routine

LR_Table	dc.w		-3
		dc.w		-2
		dc.w		-1
		dc.w		0
		dc.w		0
		dc.w		1
		dc.w		2
		dc.w		3
		dc.l		10

		*********************************
		*	 Static CHIP Data	*
		*********************************


*** Raw screen data. Two copies as it will be double buffered.

		section		gfx,DATA_C

		incdir		Source:M.Meany/Gfx/

InitialXY	dc.w		100,100

OnScreen	incbin		screen.bm

OffScreen	incbin		screen.bm

CollisionMap	ds.b		3*48*2			3words x 48lines

*** Copper Lists

Copper1		CMOVE		DIWSTRT,$2c81		bpl initialisation
		CMOVE		DIWSTOP,$2cc1
		CMOVE		DDFSTRT,$0038
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPLCON0,$4200
		CMOVE		BPLCON1,$0000
		CMOVE		BPL1MOD,$0000
		CMOVE		BPL2MOD,$0000
		CWAIT		0,20			wait for line 20
		
Cop1Planes	CMOVE		BPL1PTH,0		bpl pointers
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		CMOVE		BPL3PTH,0
		CMOVE		BPL3PTL,0
		CMOVE		BPL4PTH,0
		CMOVE		BPL4PTL,0

		ds.w		16*2			space for colours

		CEND					end of list

Copper2		CMOVE		DIWSTRT,$2c81		bpl initialisation
		CMOVE		DIWSTOP,$2cc1
		CMOVE		DDFSTRT,$0038
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPLCON0,$4200
		CMOVE		BPLCON1,$0000
		CMOVE		BPL1MOD,$0000
		CMOVE		BPL2MOD,$0000
		CWAIT		0,20			wait for line 20
		
Cop2Planes	CMOVE		BPL1PTH,0		bpl pointers
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		CMOVE		BPL3PTH,0
		CMOVE		BPL3PTL,0
		CMOVE		BPL4PTH,0
		CMOVE		BPL4PTL,0

		ds.w		16*2			space for colours

		CEND					end of list

*** Sound samples

		SETSAMPLE	Bounce,'bounce.snd'

		SETSAMPLE	Crash,'crash.snd'

*** Graphics, mask and save areas for players bob

SAVESIZE	=		6*16*4		3words x 16 lines x 4planes

Player_Gfx	incbin		ball.bm
sizeA		equ		*-Player_Gfx

Player_Mask	incbin		ball_mask.bm

P_Save1		ds.b		SAVESIZE
P_Save2		ds.b		SAVESIZE

		*********************************
		*	    Variables		*
		*********************************

		section		variables,BSS

		rsreset
PlayerDx	rs.w		1
PlayerDy	rs.w		1
GoingUp		rs.w		1		set if player jumping
MovingLR	rs.w		1
UpCounter	rs.w		1		vbls to jump for
BounceHt	rs.w		1		how high to bounce
Joy		rs.w		1	
var_size	rs.b		0

Vars		ds.b		var_size
