
; A program that experiments with animated bobs.

; Uses a dual-playfield display to preserve background.

; © M.Meany, Oct 91.

		incdir		source:include/
;		incdir		rrd:
		include		hardware.i

		opt o+,ow-

Start		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error		if so quit now !
		bsr		Main		do da
		bsr		SysOn		enable system
.error		moveq.l		#0,d0		no DOS errors
		rts

*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5	a5->hardware

;		lea		REG,a5		DEBUG ONLY

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

		move.l		$4.w,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#SETIT!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Init copper list data for action screen.

		lea		BitPlane,a0	a0-> colour data
		lea		Colours,a1	a1-> into Copper List
		move.w		#$180,d0	d0=colour reg offset
		moveq		#7,d1		d1=num of colours - 1

.Colloop	move.w		d0,(a1)+	reg offset into list
		move.w		(a0)+,(a1)+	colour value into list
		addq.w		#2,d0		offset of next reg
		dbra		d1,.Colloop	repeat for all registers

		bsr		PutPlanes	put plane addrs into Copper

; Init copper list data for backdrop screen.

		lea		BitPlane2,a0	a0-> colour data
		lea		Colours1,a1	a1-> into Copper List
		move.w		#$190,d0	d0=colour reg offset
		moveq		#7,d1		d1=num of colours - 1

.Colloop1	move.w		d0,(a1)+	reg offset into list
		move.w		(a0)+,(a1)+	colour value into list
		addq.w		#2,d0		offset of next reg
		dbra		d1,.Colloop1	repeat for all registers
		
		moveq.l		#2,d0		num of planes -1
		move.l		#(320/8)*256,d1	size of each bitplane
		move.l		a0,d2		d2=addr of 1st bitplane
		lea		CopPlanes1,a0	a0-> into Copper List
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		add.l		d1,d2		point to next plane
		dbra		d0,.PlaneLoop	repeat for all planes

; Strobe our list

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Switch drives off ( thanks to Vandal of Killers for this )

		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB

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


; This is the start of the control loop which takes the following format:


.the_loop	btst		#6,CIAAPRA	lefty ?
		beq		.done		if so, quit!

;		move.w		#$333,$dff180	

;		bsr		Chase
		bsr		Follow
		bsr		BlitBobs
		bsr		Animate
		bsr		TestJoy

;		move.w		#$999,$dff180	


.VBL1		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$000,d0	is this line 0?
		bne.s		.VBL1		if not loop back

; Switch screens

		bsr		Switch		switch screen to see Bob

; Delete old image of the bob

		bsr		ClearBobs

		bra		.the_loop	and loop back

; program should shut down here....

.done		bsr		DeInit

		rts

*****************************************************************************
****************************             ************************************
**************************** Subroutines ************************************
****************************             ************************************
*****************************************************************************
*****************************************************************************

; Two screens need to be initialised as I'm using a double-buffered display!

Init		

		rts

*****************************************************************************

DeInit		
		rts

*****************************************************************************

; Subroutine to switch screens in a double buffered display. Only call during
;the vertical blanking period.

Switch		move.l		WorkScrn,a0		a0 -> Work screen
		move.l		DispScrn,WorkScrn	switch screens
		move.l		a0,DispScrn		display Work screen
		bsr		PutPlanes		put into CopperList
		rts					and finish

*****************************************************************************

;--------------	Routine to plonk bitplane pointers into copper list

; This subroutine sets up planes for a 320x256x3 display, but only
;requires minor mods to work for any size display!

;Entry		a0=start address of bitplane

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#2,d0		num of planes -1
		move.l		#(320/8)*256,d1	size of each bitplane
		move.l		a0,d2		d2=addr of 1st bitplane
		lea		CopPlanes,a0	a0-> into Copper List
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		add.l		d1,d2		point to next plane
		dbra		d0,.PlaneLoop	repeat for all planes
		rts

*****************************************************************************

; All bobs play 'jnfollow the leader'. Call BEFORE TestJoy!

Follow		movem.l		d0-d5/a0-a5,-(sp)

		lea		FirstBob,a1
		
		move.l		bob_x(a1),d0
		move.l		bob_y(a1),d1

.loopy		move.l		bob_next(a1),a1		next bob in list
		move.l		bob_x(a1),d2
		move.l		bob_y(a1),d3
		move.l		d0,bob_x(a1)
		move.l		d1,bob_y(a1)
		move.l		d2,d0
		move.l		d3,d1
		tst.l		bob_next(a1)
		bne.s		.loopy

.done		movem.l		(sp)+,d0-d5/a0-a5
		rts

*****************************************************************************


Chase		movem.l		d0-d5/a0-a5,-(sp)

		tst.w		timer
		beq.s		.no_time

		btst.b		#7,$bfe001		fire ?
		bne.s		.no_time		if so pause aliens

		subq.w		#1,timer		and dec timer
		bra		.done

.no_time	lea		FirstBob,a1
		move.l		bob_next(a1),a1
		move.w		X_POS,d0
		move.w		Y_POS,d1

.loopy		tst.w		bob_count(a1)		counter zero
		bne		.next			if not skip bob & dec

		move.w		bob_movecounter(a1),bob_count(a1)

		lea		bob_x(a1),a0

		cmp.w		(a0)+,d0
		beq		.do_y
		bgt		.go_right

		subq.w		#1,-2(a0)
		bra		.do_y

.go_right	addq.w		#1,-2(a0)

.do_y		cmp.w		(a0)+,d1
		beq		.next
		bgt		.go_down

		subq.w		#1,-2(a0)
		bra		.next

.go_down	addq.w		#1,-2(a0)

.next		subq.w		#1,bob_count(a1)
		tst.l		bob_next(a1)
		beq.s		.done
		move.l		bob_next(a1),a1
		bra		.loopy

.done		movem.l		(sp)+,d0-d5/a0-a5
		rts

*****************************************************************************

; Modified this to update X_POS and Y_POS!

; Subroutine to read joystick movement in port 1. Returns a code in register
;d2 according to the following:

;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement

; Assumes a5 -> hardware registers ( ie a5 = $dff000 ).

; Corrupts d0, d1 and d2.

; M.Meany, Aug 91.


TestJoy		moveq.l		#0,d0			clear
		move.l		d0,d2
		move.w		JOY1DAT(a5),d0		read stick

		btst		#1,d0			right ?
		beq.s		.test_left		if not jump!

		cmp.w		#304,X_POS
		bge		.test_left

		addq.w		#6,X_POS
;		or.w		#1,d2			set right bit

.test_left	btst		#9,d0			left ?
		beq.s		.test_updown		if not jump

		cmp.w		#10,X_POS
		ble		.test_updown

		subq.w		#6,X_POS
;		or.w		#2,d2			set left bit

.test_updown	move.l		d0,d1			copy JOY1DAT
		lsr.w		#1,d1			shift u/d bits
		eor.w		d1,d0			exclusive or 'em
		btst		#0,d0			down ?
		beq.s		.test_down		if not jump

		cmp.w		#240,Y_POS
		bge		.test_down

		addq.w		#6,Y_POS
;		or.w		#4,d2			set down bit

.test_down	btst		#8,d0			up ?
		beq.s		.no_joy			if not jump

		cmp.w		#10,Y_POS
		ble		.no_joy

		subq.w		#6,Y_POS
;		or.w		#8,d2			set up bit

.no_joy		rts

*****************************************************************************

; Routine to step all bobs through their animation sequence.

Animate		movem.l		d0-d7/a0-a7,-(sp)

		lea		FirstBob,a0

.anim_loop	tst.w		bob_animcount(a0)
		bne.s		.dec_count

		move.w		bob_animrate(a0),bob_animcount(a0) reset

		move.l		bob_anim(a0),a1		current image
		lea		8(a1),a1		next image
		tst.l		(a1)			NULL ?
		bne.s		.next_frame		if not skip
		lea		bob_Im1(a0),a1		else reset

.next_frame	move.l		a1,bob_anim(a0)		and store
		move.l		(a1)+,bob_data(a0)	set image
		move.l		(a1),bob_mask(a0)	and mask

.dec_count	subq.w		#1,bob_animcount(a0)	dec counter

		tst.l		(a0)			end of list
		beq.s		.done			if so quit

		move.l		bob_next(a0),a0		else get next bob
		bra		.anim_loop		and loop back

.done		movem.l		(sp)+,d0-d7/a0-a7
		rts

*****************************************************************************

; Routine to blit a bob onto the screen

; Assumes image from 2 frames ago is cleared!

BlitBobs	movem.l		d0-d7/a0,-(sp)

		lea		FirstBob,a0	a0->start of bob list

		move.w		#$0242,d7	blit size ( 2wrdsx9lines )
		move.w		#36,d6

.bob_loop	moveq.l		#2,d5		bob depth-1

		move.l		bob_con0(a0),bob_lastcon0(a0)	save last con0
		move.l		bob_dpth(a0),bob_lastdpth(a0)	and dpth

		moveq.l		#0,d0		clear register
		move.l		d0,d1		and this one
		move.w		bob_x(a0),d0	d0 = x pos
		move.w		bob_y(a0),d1	d1 = y pos

		move.l		d0,d4		working X Pos
		asr.l		#3,d4		div by 8
		mulu		#40,d1		line offset ( yx64 )
		add.l		d4,d1		d1= offset to blit dest
		add.l		WorkScrn,d1	d1= addr of dest
		move.l		d1,bob_dpth(a0)	save this value of dpth

* now the scroll values ( soon be there !!!!! )

		moveq.l		#28,d3		num of bits to shift
		asl.l		d3,d0		scrl into highbits
		move.l		d0,d3
		swap		d0
		move.w		d0,d3		set B scrl = A scrl
		or.l		#$0fce0000,d3	use A,B,C,D D=B+aC minterm
		move.l		d3,bob_con0(a0) save this value of con0

		move.l		bob_data(a0),BLTBPTH(a5)
		move.w		#0,BLTAMOD(a5)
		move.w		#0,BLTBMOD(a5)
		move.w		d6,BLTCMOD(a5)		  scrn modulo
		move.w		d6,BLTDMOD(a5)		  scrn modulo
		move.l		#$ffff0000,BLTAFWM(a5)
		move.l		d3,BLTCON0(a5)

.loop3		move.l		d1,BLTCPTH(a5)			set src
		move.l		d1,BLTDPTH(a5)
		move.l		bob_mask(a0),BLTAPTH(a5)
		move.w		d7,BLTSIZE(a5)	and go
.wait4		btst		#14,DMACONR(a5)
		bne.s		.wait4
		add.l		#(320/8)*256,d1
		dbra		d5,.loop3

		tst.l		bob_next(a0)
		beq.s		.done
		move.l		bob_next(a0),a0
		bra		.bob_loop

.done		movem.l		(sp)+,d0-d7/a0
		rts


ClearBobs	movem.l		d0-d7/a0,-(sp)

		lea		FirstBob,a0	a0->start of bob list

		move.w		#$0242,d7	blit size ( 2wrdsx9lines )
		move.w		#36,d6

.bob_loop	moveq.l		#2,d5		bob depth-1

		move.l		bob_lastdpth(a0),d1
		beq		.done			quit if 1st time

* now the scroll values ( soon be there !!!!! )

		move.l		bob_lastcon0(a0),d3	
		and.l		#$f000ffff,d3	clear minterm
		or.l		#$09f00000,d3	set to D=A minterm

		move.l		#ClearBob,BLTAPTH(a5)
		move.w		#0,BLTAMOD(a5)
		move.w		d6,BLTDMOD(a5)		  scrn modulo
		move.l		#$ffff0000,BLTAFWM(a5)
		move.l		d3,BLTCON0(a5)

.loop3		move.l		d1,BLTDPTH(a5)			set src
		move.w		d7,BLTSIZE(a5)	and go
.wait4		btst		#14,DMACONR(a5)
		bne.s		.wait4
		add.l		#(320/8)*256,d1
		dbra		d5,.loop3

		tst.l		bob_next(a0)
		beq.s		.done
		move.l		bob_next(a0),a0
		bra		.bob_loop

.done		movem.l		(sp)+,d0-d7/a0
		rts


*****************************************************************************
*****************************      ******************************************
***************************** Data ******************************************
*****************************      ******************************************
*****************************************************************************


grafname	dc.b		'graphics.library',0
		even
grafbase	ds.l		1
sysDMA		ds.l		1
syscop		ds.l		1

WorkScrn	dc.l		p1
DispScrn	dc.l		p2

timer		dc.w		5*52		5 seconds of pause!

;REG		ds.w		$300		DEBUG ONLY


*****************************************************************************
*****************************          **************************************
***************************** Bob List ******************************************
*****************************          **************************************
*****************************************************************************


; Bob Structure:

		rsreset
bob_next	rs.l		1		ptr to next bob
bob_x		rs.w		1		x position
bob_y		rs.w		1		y_position
bob_con0	rs.l		1		bltcon0 1 frame back
bob_dpth	rs.l		1		bltdpth 1 frame back
bob_lastcon0	rs.l		1		bltcon0 2 frames back
bob_lastdpth	rs.l		1		bltdpth 2 frames back
bob_data	rs.l		1		pointer to imagery
bob_mask	rs.l		1		pointer to mask
bob_animrate	rs.w		1		1/50th's of sec between anim
bob_animcount	rs.w		1		system counter
bob_anim	rs.l		1		pointer to current image
bob_movecounter	rs.w		1		time between moves
bob_count	rs.w		1		system counter
bob_Im1		rs.l		1		anim image 1
bob_Msk1	rs.l		1		anim mask 1
bob_Im2		rs.l		1		anim image 2
bob_Msk2	rs.l		1		anim mask 2
bob_Im3		rs.l		1		anim image 3
bob_Msk3	rs.l		1		anim mask 3
bob_Im4		rs.l		1		anim image 4
bob_Msk4	rs.l		1		anim mask 4
bob_blank	rs.l		1		end of anim list
bob_Size	rs.b		0		


FirstBob	dc.l		bob1
X_POS		dc.w		150
Y_POS		dc.w		100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,10		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob1		dc.l		bob2
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,1		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 2nd frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob2		dc.l		bob3
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,3		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 3 frames
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob3		dc.l		bob4		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob4		dc.l		bob5		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob5		dc.l		bob6		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob6		dc.l		bob7		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob7		dc.l		bob8		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob8		dc.l		bob9		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob9		dc.l		bob10		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob10		dc.l		bob11		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob11		dc.l		bob12		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob12		dc.l		bob13		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob13		dc.l		bob14		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob14		dc.l		bob15		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob15		dc.l		bob16		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob16		dc.l		bob17		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob17		dc.l		bob18		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims


bob18		dc.l		bob19		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob19		dc.l		bob20		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob20		dc.l		bob21
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,1		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 2nd frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob21		dc.l		bob22
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,3		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 3 frames
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob22		dc.l		bob23		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob23		dc.l		bob24		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob24		dc.l		bob25		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob25		dc.l		bob26		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob26		dc.l		bob27		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob27		dc.l		bob28		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob28		dc.l		bob29		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob29		dc.l		bob30		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob30		dc.l		bob31		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob31		dc.l		bob32		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob32		dc.l		bob33		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob33		dc.l		bob34		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob34		dc.l		bob35		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob35		dc.l		bob36		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob36		dc.l		bob37		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob37		dc.l		bob38		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob38		dc.l		bob39		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob39		dc.l		bob40		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob40		dc.l		bob42
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,1		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 2nd frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob42		dc.l		bob43
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,3		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 3 frames
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob43		dc.l		bob44		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob44		dc.l		bob45		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob45		dc.l		bob46		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob46		dc.l		bob47		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob47		dc.l		bob48		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob48		dc.l		bob49		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob49		dc.l		bob50		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob50		dc.l		bob51		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob51		dc.l		bob52		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob52		dc.l		bob53		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob53		dc.l		bob54		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob54		dc.l		bob55		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob55		dc.l		bob56		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob56		dc.l		bob57		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob57		dc.l		bob58		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims


bob58		dc.l		bob59		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob59		dc.l		bob60		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob60		dc.l		bob61
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,1		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 2nd frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob61		dc.l		bob62
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,3		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every 3 frames
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob62		dc.l		bob63		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob63		dc.l		bob64		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob64		dc.l		bob65		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob65		dc.l		bob66		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob66		dc.l		bob67		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob67		dc.l		bob68		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob68		dc.l		bob69		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob69		dc.l		bob70		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob70		dc.l		bob71		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob71		dc.l		bob72		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob72		dc.l		bob73		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob73		dc.l		bob74		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob74		dc.l		bob75		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob75		dc.l		bob76		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob76		dc.l		bob77		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob77		dc.l		bob78		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

bob78		dc.l		0		no more bobs
		dc.w		150,100
		dc.l		0,0
		dc.l		0,0
		dc.l		TestBob
		dc.l		TestMask
		dc.w		10,7		animate every 10th frame
		dc.l		.here
		dc.w		1,1		move every frame
.here		dc.l		TestBob,TestMask	1st anim image
		dc.l		TestBob1,TestMask1	2nd anim image
		dc.l		TestBob2,TestMask2	3rd anim image
		dc.l		TestBob3,TestMask3	4th anim image
		dc.l		0			end of anims

*****************************************************************************
*****************************           *************************************
***************************** CHIP Data *************************************
*****************************           *************************************
*****************************************************************************

		section		cop,data_c


CopList		dc.w DIWSTRT,$2c81	Top left of screen
		dc.w DIWSTOP,$2cc1	Bottom right of screen - NTSC ($2cc1 for PAL)
		dc.w DDFSTRT,$38	Data fetch start
		dc.w DDFSTOP,$d0	Data fetch stop
		dc.w BPLCON0,$6600	Select lo-res, 8 colour, DBLPF.
		dc.w BPLCON1,0		No horizontal offset
		dc.w BPL1MOD,0		No modulo at top of screen
		dc.w BPL2MOD,0

; Reserve space to set up colour registers. 1st for action screen.

Colours		ds.w 16			Space for 8 colour registers

; Now the backdrop screen.

Colours1	ds.w 16			Space for 8 colour registers
 
; Now set all plane pointers. 1st the action screen!

		dc.w	BPL1PTH		Plane pointers for 6 planes          
CopPlanes	dc.w	0,BPL1PTL          
		dc.w	0,BPL3PTH
		dc.w	0,BPL3PTL
		dc.w	0,BPL5PTH
		dc.w	0,BPL5PTL
		dc.w	0

; Now the backdrop screen.

		dc.w	BPL2PTH
CopPlanes1	dc.w	0,BPL2PTL
		dc.w	0,BPL4PTH
		dc.w	0,BPL4PTL
		dc.w	0,BPL6PTH
		dc.w	0,BPL6PTL
		dc.w	0

		dc.w		$ffff,$fffe		end of list


*****************************************************************************
;		Bob Datas
*****************************************************************************

TestBob		
		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0100000100000000,0
		dc.w		%0100000100000000,0
		dc.w		%0100000100000000,0
		dc.w		%0010001000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0100000100000000,0
		dc.w		%0100000100000000,0
		dc.w		%0100000100000000,0
		dc.w		%0010001000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0100000100000000,0
		dc.w		%0100000100000000,0
		dc.w		%0100000100000000,0
		dc.w		%0010001000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

TestMask	dc.w		%0001110000000000,0	1
		dc.w		%0011111000000000,0	2
		dc.w		%0111111100000000,0	3
		dc.w		%1111111110000000,0	4
		dc.w		%1111111110000000,0	5
		dc.w		%1111111110000000,0	6
		dc.w		%0111111100000000,0	7
		dc.w		%0011111000000000,0	8
		dc.w		%0001110000000000,0	9

TestBob1
		dc.w		0,0
		dc.w		%0000000000000000,0
		dc.w		%0001110000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0001110000000000,0
		dc.w		%0000000000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0000000000000000,0
		dc.w		%0001110000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0001110000000000,0
		dc.w		%0000000000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0000000000000000,0
		dc.w		%0001110000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0010001000000000,0
		dc.w		%0001110000000000,0
		dc.w		%0000000000000000,0
		dc.w		0,0

TestMask1	dc.w		%0001110000000000,0	1
		dc.w		%0011111000000000,0	2
		dc.w		%0111111100000000,0	3
		dc.w		%1111111110000000,0	4
		dc.w		%1111111110000000,0	5
		dc.w		%1111111110000000,0	6
		dc.w		%0111111100000000,0	7
		dc.w		%0011111000000000,0	8
		dc.w		%0001110000000000,0	9

TestBob2	
		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0110101100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011011000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0110101100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011011000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0110101100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011011000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

TestMask2	dc.w		%0001110000000000,0	1
		dc.w		%0011111000000000,0	2
		dc.w		%0111111100000000,0	3
		dc.w		%1111111110000000,0	4
		dc.w		%1111111110000000,0	5
		dc.w		%1111111110000000,0	6
		dc.w		%0111111100000000,0	7
		dc.w		%0011111000000000,0	8
		dc.w		%0001110000000000,0	9

TestBob3		
		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0110101100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011111000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0110101100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011111000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0110101100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011111000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

TestMask3	dc.w		%0001110000000000,0	1
		dc.w		%0011111000000000,0	2
		dc.w		%0111111100000000,0	3
		dc.w		%1111111110000000,0	4
		dc.w		%1111111110000000,0	5
		dc.w		%1111111110000000,0	6
		dc.w		%0111111100000000,0	7
		dc.w		%0011111000000000,0	8
		dc.w		%0001110000000000,0	9


ClearBob	dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0

		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0
		dc.w		0,0

*****************************************************************************
;		Screen Datas
*****************************************************************************


;		incdir	df1:bitmaps/
;		incdir	rrd:


BitPlane	dc.w	$000,$fff,$d00,$fb0	black,white,red,orange
		dc.w	$bf0,$0db,$6fe,$999	green,aqua,blue,grey

p1		
		dcb.w	(320/16)*256*3,$0	screen data


BitPlane1	dc.w	$000,$fff,$d00,$fb0	black,white,red,orange
		dc.w	$bf0,$0db,$6fe,$999	green,aqua,blue,grey

p2		
		dcb.w	(320/16)*256*3,$0	screen data

BitPlane2	incbin	colpic.bm


