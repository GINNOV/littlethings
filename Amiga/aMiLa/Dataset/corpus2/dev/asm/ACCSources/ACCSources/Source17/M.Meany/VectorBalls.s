
*****	Code now adapted to handle any number of bobs. Just alter the
*	Global variable NUMBOBS and set up the correct coord lists at
*	labels wx, wy and wz. M.Meany, Sept 91.

*****	Here we go! A rotating M with half screen reflection in 8 colours
*	Well 8 shades of grey cause I like being boring!!!

*****	Written by M.Meany
*****	September 1991

*****	Assembles using DevpacII

; This example has the orogin moving around the screen

;		incdir		df1:include/
		incdir		rrd:
		include		hardware.i

X_MAX		EQU		192
X_MIN		EQU		0
Y_MAX		EQU		160
Y_MIN		EQU		0

NUMBOBS		EQU		12+8+8		number of bobs to display

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

		move.l		$4,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#SETIT!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper


; Set up Copper List, 1st bit plane pointers then colour reg.

; This code assumes the colour map is before the raw bpl data.

		lea		BitPlane,a0	a0-> colour data
		lea		Colours,a1	a1-> into Copper List
		move.w		#$180,d0	d0=colour reg offset
		moveq		#7,d1		d1=num of colours - 1

.Colloop	move.w		d0,(a1)+	reg offset into list
		move.w		(a0)+,(a1)+	colour value into list
		addq.w		#2,d0		offset of next reg
		dbra		d1,.Colloop	repeat for all registers

		bsr		PutPlanes	put plane addrs into Copper

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

;		1/ Get bobs new x,y position
;		2/ test LMB, if pressed then quit
;		5/ blit bob into work screen
;		6/ wait for vertical blank
;		7/ switch screens to display bob in new position
;		8/ restore background where bob was last
;		9/ goto 1

.nojoy		move.l		a5,-(sp)	save reg pointer
		bsr		Rotate		update x,y
		bsr		SortBalls	sort Bobs by Z value
		move.l		(sp)+,a5	restore pointer

.not_up		btst		#6,CIAAPRA	lefty ?
		beq		.done		if so, quit!

; Bob has been moved, so plonk it into work screen

.blit		
		lea		MyBob,a4	a4->bob list
		lea		X_Rot,a3	a3->x ord list
		lea		Y_Rot,a2	a2->y ord list
		moveq.l		#NUMBOBS-1,d7	num bobs - 1

.bob_loop	move.l		(a4)+,a0	next bob
		move.l		WorkScrn,a1	screen
		move.w		X_POS,d0	orogin offsets
		move.w		Y_POS,d1
		add.w		(a3)+,d0	d0=x pos
		add.w		(a2)+,d1	d1=y pos
		jsr		DisplayBob	and display it !!!

		dbra		d7,.bob_loop	for all bobs

;		move.w		#$005,$dff180	

; wait for beam to reach line 16

.VBL1		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.VBL1		if not loop back

.VBL2		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$000,d0	is this line 16?
		bne.s		.VBL2		if not loop back

; Switch screens

		bsr		Switch		switch screen to see Bob

; Delete old image of the bob

		moveq.l		#NUMBOBS-1,d7	num bobs - 1

.clear_loop	move.l		-(a4),a0	a0->Bob
		bsr		ClearBob	replace background
		dbra		d7,.clear_loop

		bsr		MoveCentre

		bra		.nojoy		and loop back

; program should shut down here....

.done		bsr		DeInit

		rts

*****************************************************************************
****************************             ************************************
**************************** Subroutines ************************************
****************************             ************************************
*****************************************************************************

; Small routine to move the orogin around the screen. This could be modified
;to read coords from a table created by Raistlins MakeCoords utility!

MoveCentre	move.w		xDir,d0
		add.w		X_POS,d0
		move.w		d0,X_POS
		cmp.w		#250,d0
		blt.s		.check_left
		move.w		#-2,xDir
.check_left	cmp.w		#50,d0
		bgt.s		.do_y
		move.w		#2,xDir
.do_y						;bra.s		.done
		move.w		yDir,d0
		add.w		Y_POS,d0
		move.w		d0,Y_POS
		cmp.w		#160,d0
		bne.s		.check_lefty
		move.w		#-1,yDir
.check_lefty	cmp.w		#60,d0
		bne.s		.done
		move.w		#1,yDir
.done		rts
*****************************************************************************

; Two screens need to be initialised as I'm using a double-buffered display!

Init		lea		BitPlane,a0	screen data address
		lea		16(a0),a0	skip colour map
		move.l		#320,d0		width
		move.l		#256,d1		height
		move.l		#3,d2		depth
		jsr		InitScreen	and build structure
		move.l		d0,DispScrn	save screen pointer

		lea		BitPlane1,a0	screen data address
		lea		16(a0),a0	skip colour map
		move.l		#320,d0		width
		move.l		#256,d1		height
		move.l		#3,d2		depth
		jsr		InitScreen	and build structure
		move.l		d0,WorkScrn	save screen pointer

; Now for the bobs. 

		lea		MyBob,a4	a4->bob list
		moveq.l		#NUMBOBS-1,d7	num of bobs - 1

.bobloop	lea		MyImage,a0	a0->Bob
		lea		ImageMask,a1	a1->mask
		moveq.l		#2,d0		width in words
		moveq.l		#9,d1		height in lines
		moveq.l		#3,d2		depth
		jsr		InitBob		and build Bob struct
		move.l		d0,(a4)+	save bob pointer
		dbra		d7,.bobloop	for all bobs

		rts

*****************************************************************************

DeInit		lea		MyBob,a4	a4->bob list
		moveq.l		#NUMBOBS-1,d7	num of bobs - 1

.bobloop	move.l		(a4)+,a0	a0->bob structure
		jsr		FreeBob		and free it
		dbra		d7,.bobloop	for all bobs

		move.l		WorkScrn,a0	a0->screen structure
		jsr		FreeScreen

		move.l		DispScrn,a0	a0->screen structure
		jsr		FreeScreen

		rts

*****************************************************************************

; Subroutine to switch screens in a double buffered display. Only call during
;the vertical blanking period.

Switch		move.l		WorkScrn,a0		a0 -> Work screen
		move.l		DispScrn,WorkScrn	switch screens
		move.l		a0,DispScrn		display Work screen
		move.l		(a0),a0			a0->bpl data
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

; This routine will sort the coordinate list by desending z values as
;required for 3D effect. +ve z is taken as going into the screen! The
;method adopted is a tweaked bubble sort.

; M.Meany, Sept 91.

SortBalls	lea		Z_Rot,a0	a0->z ord list
		lea		X_Rot,a1	a1->x od list
		lea		Y_Rot,a2	a2->y ord list
		move.l		#NumBalls-2,d1	counter
		moveq.l		#0,d0		flag

.inner		lea		2(a2),a2	bump pointer
		lea		2(a1),a1	bump pointer
		move.w		(a0)+,d2	get next val
		cmp.w		(a0),d2		is successor bigger
		bge.s		.no_swap	if not skip

		move.w		(a0),d2		swap z vals
		move.w		-2(a0),(a0)
		move.w		d2,-2(a0)

		move.w		(a1),d2		swap x vals
		move.w		-2(a1),(a1)
		move.w		d2,-2(a1)

		move.w		(a2),d2		swap y vals
		move.w		-2(a2),(a2)
		move.w		d2,-2(a2)

		moveq.l		#1,d0		set flag = not finished

.no_swap	dbra		d1,.inner

		tst.l		d0		did we swap ?
		bne.s		SortBalls	if so loop back again

		rts

*****************************************************************************

; Routine adapted from Mini-Intro.s by Marcus Glynn ( Shadow ), found on 
;Dec 89 Amiga Computing coverdisc. Cheers again Marcus!


Rotate		move.w		Z_Angle,d0	d0=z angle of rotation
		jsr		Trig		get Sine and CoSine 
		move.w		d1,Z_Sin	save these in 
		move.w		d2,Z_Cos	appropriate registers
		move.w		Y_Angle,d0	do same for y angle
		jsr		Trig
		move.w		d1,Y_Sin
		move.w		d2,Y_Cos
		move.w		X_Angle,d0	and for x angle
		jsr		Trig
		move.w		d1,X_Sin
		move.w		d2,X_Cos
		lea		wx,a0		a0-> x ord list
		lea		wy,a1		a1-> y ord list
		lea		wz,a2		a2-> z ord list
		lea		X_Rot,a3	a3->rotated x ord list
		lea		Y_Rot,a4	a4->rotated y ord list
		lea		Z_Rot,a5	a5->rotated z ord list
		move.w		numpoints,d0	d0=number of coordinates
rloop		move.w		Z_Sin,d1	sin(z)
		move.w		Z_Cos,d2	cos(z)
		move.w		(a0),d3		x
		muls.w		d3,d2		d2=x.cos(z)
		move.w		(a1),d3		y
		muls.w		d3,d1		d1=y.sin(z)
		sub.l		d1,d2		d2=x.cos(z)-y.sin(z)
		lsr.l		#8,d2		divide by 16384 to
		lsr.l		#6,d2		correct trig 
		move.w		d2,d5		save in safe reg
		move.w		Z_Sin,d1	sin(z)
		move.w		Z_Cos,d2	cos(z)
		move.w		(a0)+,d3	d3=x & bump pointer
		muls.w		d3,d1		d1=x.sin(z)
		move.w		(a1)+,d3	d3=y & bump pointer
		muls.w		d3,d2		d2=y.cos(z)
		add.l		d1,d2		d2=x.sin(z)+y.cos(z)
		lsr.l		#8,d2		divide by 16384
		lsr.l		#6,d2
		move.w		d2,d6		save in a safe reg
		move.w		Y_Sin,d1	sin(y)
		move.w		Y_Cos,d2	cos(y)
		move.w		(a2),d3		z
		muls.w		d3,d2		d2=z.cos(y)
		move.w		d5,d3		d3=
		muls.w		d3,d1
		sub.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d7
		move.w		Y_Sin,d1
		move.w		Y_Cos,d2
		move.w		(a2)+,d3
		muls.w		d3,d1
		move.w		d5,d3
		muls.w		d3,d2
		add.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d5
		move.w		X_Sin,d1
		move.w		X_Cos,d2
		move.w		d6,d4		
		move.w		d6,d3
		muls.w		d3,d2
		move.w		d7,d3
		muls.w		d3,d1
		sub.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d6
		move.w		X_Sin,d1
		move.w		X_Cos,d2
		move.w		d4,d3
		muls.w		d3,d1
		move.w		d7,d3
		muls.w		d3,d2
		add.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d7
		move.w		d5,(a3)+
		move.w		d6,(a4)+
		move.w		d7,(a5)+
		dbra		d0,rloop

BP1		lea		X_Angle,a0
		lea		X_AngleAdd,a1
		move.l		#360,d1

		move.w		(a1)+,d0		bump x angle
		add.w		d0,(a0)+
		cmp.w		-2(a0),d1		> 360 ?
		bgt.s		.ok1
		sub.w		d1,-2(a0)

.ok1		move.w		(a1)+,d0		bump y angle
		add.w		d0,(a0)+
		cmp.w		-2(a0),d1		> 360 ?
		bgt.s		.ok2
		sub.w		d1,-2(a0)
		

.ok2		move.w		(a1)+,d0		bump z angle
		add.w		d0,(a0)+
		cmp.w		-2(a0),d1		> 360 ?
		bgt.s		.done
		sub.w		d1,-2(a0)

.done		rts

*********************************************************
*		data lists for x,y,z coordinate lists	*
*********************************************************

wx		dc.w -49,-49,-49,-42,-42,-35,-35,-28,-28,-21,-21,-21
		dc.w -7,-7,0,0,7,7,14,14
		dc.w 28,28,35,35,42,42,49,49
number		equ		*-wx

wy		dc.w -14,-7,0,-21,-7,-28,-7,-21,-7,-14,-7,0
		dc.w -14,-7,-21,0,-21,0,-21,0
		dc.w -14,-7,-21,0,-21,0,-21,0


wz		dc.w -5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5
		dc.w -5,-5,-5,-5,-5,-5,-5,-5
		dc.w -5,-5,-5,-5,-5,-5,-5,-5

NumBalls	equ		number/2     number of pointe forming object

X_Angle		dc.w		0
Y_Angle		dc.w		0
Z_Angle		dc.w		0

X_AngleAdd	dc.w		5
Y_AngleAdd	dc.w		2
Z_AngleAdd	dc.w		3
		
Z_Sin		dc.w		0
Z_Cos		dc.w		0
Y_Sin		dc.w		0
Y_Cos		dc.w		0
X_Sin		dc.w		0
X_Cos		dc.w		0

numpoints	dc.w NumBalls-1

X_Rot		ds.w NumBalls		
Y_Rot		ds.w NumBalls		
Z_Rot		ds.w NumBalls		

**************************************************
*		get sin/cos value for angle in d0*
**************************************************

Trig		tst		d0
		bpl.s		.noadd
		add		#360,d0
.noadd		lea		sintab,a1
		move.l		d0,d2
		lsl		#1,d0
		move		0(a1,d0),d1
		cmp		#270,d2
		blt.s		.plus9
		sub		#270,d2
		bra.s		.sendsin
.plus9		add		#90,d2
.sendsin	lsl		#1,d2
		move		0(a1,d2),d2
		rts
		
*************************************************
*		data for sintable				*
*************************************************

sintab		dc.w 0,286,572,857,1143,1428,1713,1997,2280
		dc.w 2563,2845,3126,3406,3686,3964,4240,4516
		dc.w 4790,5063,5334,5604,5872,6138,6402,6664
		dc.w 6924,7182,7438,7692,7943,8192,8438,8682		
		dc.w 8923,9162,9397,9630,9860,10087,10311,10531
		dc.w 10749,10963,11174,11381,11585,11786,11982,12176
		dc.w 12365,12551,12733,12911,13085,13255,13421,13583
		dc.w 13741,13894,14044,14189,14330,14466,14598,14726
		dc.w 14849,14968,15082,15191,15296,15396,15491,15582
		dc.w 15668,15749,15826,15897,15964,16026,16083,16135
		dc.w 16182,16225,16262,16294,16322,16344,16362,16374
		dc.w 16382,16384
		dc.w 16382
		dc.w 16374,16362,16344,16322,16294,16262,16225,16182
		dc.w 16135,16083,16026,15964,15897,15826,15749,15668		
		dc.w 15582,15491,15396,15296,15191,15082,14967,14849
		dc.w 14726,14598,14466,14330,14189,14044,13894,13741		
		dc.w 13583,13421,13255,13085,12911,12733,12551,12365
		dc.w 12176,11982,11786,11585,11381,11174,10963,10749
		dc.w 10531,10311,10087,9860,9630,9397,9162,8923
		dc.w 8682,8438,8192,7943,7692,7438,7182,6924
		dc.w 6664,6402,6138,5872,5604,5334,5063,4790
		dc.w 4516,4240,3964,3686,3406,3126,2845,2563
		dc.w 2280,1997,1713,1428,1143,857,572,286,0
		dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
		dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
		dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
		dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682		
		dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
		dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
		dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
		dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
		dc.w -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
		dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
		dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
		dc.w -16382,-16384
		dc.w -16382
		dc.w -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
		dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668		
		dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
		dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741		
		dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
		dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
		dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
		dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
		dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
		dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
		dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0



*****************************************************************************

; Hardware Bob Support Routines.  v1.0

; Started 21-8-91
; UpDate  22-8-91	InitScreen, FreeScreen, InitBob, FreeBob and
;			DisplayBob working.

; UpDate  22-9-91	Code now corrected and tested on double buffered
;			displays. Some bugs removed.

; © M.Meany

; The following include files are required and should be specified by
;the main program:

;		hardware.i
;		exec_lib.i

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm


*****************************************************************************

;-----	Initialise a screen for use by routines.

; Entry		a0-> The screen data
;		d0 = Width of screen in pixels
;		d1 = Height of screen in raster lines
;		d2 = Depth of screen ( number of bitplanes )

; Exit		d0 = Address of Screens structure or 0 if an error occurred

; Corrupted	d0-d1, a0-a1

InitScreen	movem.l		d2-d7/a2-a6,-(sp)	save registers

*** Allocate mem for the screen structure

		movem.l		d0-d2/a0,-(sp)	save entry parameters

		moveq.l		#Scrn_SIZEOF,d0		size
		move.l		#$10001,d1		PUBLIC + CLEAR
		CALLEXEC	AllocMem		get mem
		move.l		d0,d7			save addr

		movem.l		(sp)+,d0-d2/a0	restore entry parameters

		tst.l		d7		block allocated ?
		beq.s		.error		if not then quit

		move.l		d7,a1			a1->block

		move.l		d0,d3			get working copy
		asr.l		#3,d3			d3= byte width
		mulu		d1,d3			x height
		move.l		d3,Scrn_BPLSize(a1)	save bpl byte size

		asr.w		#4,d0			div width by 16
		move.w		d0,Scrn_Width(a1)	store width
		move.w		d1,Scrn_Height(a1)	store height
		move.w		d2,Scrn_Depth(a1)	store depth
		move.l		a0,Scrn_Data(a1)	store bpl addr

.error		move.l		d7,d0			get return code
		movem.l		(sp)+,d2-d7/a2-a6	restore registers
		rts					and return

*****************************************************************************

;-----	Free a screen used by routines.

; Entry		a0-> The screens structure ( returned by InitScreen )

; Exit		Nothing useful

; Corrupted	d0-d1, a0-a1

FreeScreen	move.l		a0,a1		block address into a1
		moveq.l		#Scrn_SIZEOF,d0	address of block
		CALLEXEC	FreeMem		and release it
		rts

*****************************************************************************

;-----	Initialise a Bob for use by routines.

; Entry		a0-> The Bob data
;		a1-> The Bobs Mask, set to 0 for no mask (not yet supported)
;		d0 = Width of Bob in WORDS
;		d1 = Height of Bob in raster lines
;		d2 = Depth of Bob

; Exit		d0 = Address of Bob structure or 0 if an error occurred

; Corrupted	d0-d2, a0-a1

InitBob		movem.l		d3-d7/a2-a6,-(sp)	save registers

		movem.l		d0-d2/a0-a1,-(sp)	save parameters

*****	Get memory for Bob structure

		move.l		#Bob_SIZEOF,d0		size
		move.l		#$10001,d1		PUBLIC + CLEAR
		CALLEXEC	AllocMem		get block
		move.l		d0,d7			save addr

		movem.l		(sp)+,d0-d2/a0-a1	get parameters

		tst.l		d7			block allocated ?
		beq.s		.ok			if not quit

*****	Store entry parameters in this

		move.l		d7,a4			a4->Bob struct
		move.w		d0,Bob_Width(a4)	store width
		move.w		d1,Bob_Height(a4)	store height
		move.w		d2,Bob_Depth(a4)	store depth
		move.l		a1,Bob_ASRC(a4)		store mask addr
		move.l		a0,Bob_BSRC(a4)		store data addr

***** Calculate BlitSize value. See page 136 of Abacus System Programmers Guide

		move.l		d0,d3			d3 = width
		move.w		d1,d4			d4 = height
		and.w		#$3ff,d4		mask off high bits
		asl.w		#6,d4			x64
		and.w		#$3f,d3			mask off high bits
		add.w		d4,d3			form BLITSIZE
		move.w		d3,Bob_BlitSize(a4)	and save it

*****	Allocate a block of memory to store background in

		asl.l		#1,d0			x 2 for byte width
		mulu		d1,d0			x height
		mulu		d2,d0			x depth
		move.l		d0,Bob_DamageSize(a4)	store size of block

		move.l		#$10002,d1		CHIP + CLEAR
		CALLSYS		AllocMem		get the block
		move.l		d0,Bob_DamageAddr(a4)	store its addr
		bne.s		.ok			jump if allocated!

		move.l		d7,a1			a1->mem block
		move.l		#Bob_SIZEOF,d0		size of block
		CALLSYS		FreeMem			and free it
		moveq.l		#0,d7			set for error
		bra.s		.ok1			and quit

.ok		move.l		Bob_DamageSize(a4),d0	size
		move.l		#$10002,d1		CHIP + CLEAR
		CALLSYS		AllocMem		get the block
		move.l		d0,Bob_DamageAddr1(a4)	store its addr
		bne.s		.ok1

		move.l		Bob_DamageAddr(a4),a1
		move.l		Bob_DamageSize(a4),d0
		CALLSYS		FreeMem

		move.l		d7,a1			a1->mem block
		move.l		#Bob_SIZEOF,d0		size of block
		CALLSYS		FreeMem			and free it
		moveq.l		#0,d7			set for error

.ok1		move.l		d7,d0			get return value
		movem.l		(sp)+,d3-d7/a2-a6	restore registers
		rts					and return

*****************************************************************************

;-----	Free a Bob used by routines.

; Entry		a0-> The Bob structure ( returned by InitBob )

; Exit		Nothing useful

; Corrupted	d0-d1, a0-a1

FreeBob		move.l		a4,-(sp)
		move.l		a0,a4		save bob structure address

*****	Free memory used to store background

		move.l		Bob_DamageSize(a0),d0	size of damage region
		move.l		Bob_DamageAddr(a0),a1	addr of block
		CALLEXEC	FreeMem			and free it

		move.l		Bob_DamageSize(a4),d0	size of damage region
		move.l		Bob_DamageAddr1(a4),a1	addr of block
		CALLEXEC	FreeMem			and free it

*****	Free memory used for the Bobs structure

		move.l		a4,a1		addr of structure
		move.l		#Bob_SIZEOF,d0	size of block
		CALLSYS		FreeMem		and free it

		move.l		(sp)+,a4
		rts

*****************************************************************************

;-----	Clear a bob.

; Restores a screen by blitting portion of bitplanes corrupted by the Bob.
;Effectively removes the Bob from the display.

; Entry		a0-> Bob structure

; Exit		Nothing useful

; Corrupted	NONE

*****	Replace the background

ClearBob	movem.l		d4/d6/d7,-(sp)
		moveq.l		#0,d4			clear this
		move.w		Bob_Depth(a0),d4	d4=depth
		subq.l		#1,d4			adjust for dbra

		move.w		Bob_BlitSize(a0),d7	d7=size of blit
		move.l		Bob_DamageDest1(a0),d6	d6=addr of dest

.wait		btst		#14,DMACONR(a5)
		bne.s		.wait

		move.l		Bob_DamageAddr1(a0),BLTAPTH(a5)	set src
		move.w		#0,BLTAMOD(a5)			set src mod
		move.w		Bob_PlaneMod(a0),BLTDMOD(a5)	set scrn mod
		move.l		#$ffffffff,BLTAFWM(a5)		no masks
		move.l		#$09f00000,BLTCON0(a5)		use a,d  d=a

.loop1		move.l		d6,BLTDPTH(a5)			set dest
		move.w		d7,BLTSIZE(a5)			and blit it
		add.l		Bob_PlaneSize(a0),d6		point to next

.wait1		btst		#14,DMACONR(a5)
		bne.s		.wait1

		dbra		d4,.loop1			for all planes

		movem.l		(sp)+,d4/d6/d7
		rts

*****************************************************************************

;-----	Display a Bob

; This routine makes use of the fact that the blitter increments the data
;address registers during each blit. So if a data for several planes lies
;in consecutive memory locations, there is no need to reset these pointers
;before each blit!

; Entry		a0-> Bob structure
;		a1-> Destination screens structure
;		d0 = X position ( in pixels from top left )
;		d1 = Y position ( in lines from top left )

; Exit		Nothing useful

; Corrupted	NONE

DisplayBob	movem.l		d0-d7/a0-a6,-(sp)

* First the destination address
		moveq.l		#0,d5			clear this
		move.w		Bob_Depth(a0),d5	d4=depth
		subq.l		#1,d5			adjust for dbra

		move.w		Bob_BlitSize(a0),d7	d7=size of blit
		move.l		Bob_DamageDest(a0),Bob_DamageDest1(a0)	d6=addr of dest
		move.l		Bob_DamageAddr(a0),d4
		move.l		Bob_DamageAddr1(a0),Bob_DamageAddr(a0)
		move.l		d4,Bob_DamageAddr1(a0)

		move.l		d0,d4		working X Pos
		asr.l		#3,d4		div by 16
		asl.l		#1,d1		x2 since scrn width in words
		mulu		Scrn_Width(a1),d1 d1= line offset
		add.l		d4,d1		d1= offset to blit dest
		add.l		Scrn_Data(a1),d1 d1= addr of dest
		move.l		d1,Bob_DamageDest(a0) save for restore next time

* Now the screen modulo and plane size (needed to restore background next time)

		move.l		Scrn_BPLSize(a1),Bob_PlaneSize(a0)
		move.w		Scrn_Width(a1),d4
		sub.w		Bob_Width(a0),d4
		asl.w		#1,d4			x2 to get byte value
		move.w		d4,Bob_PlaneMod(a0)	D4 = PLANE MODULO

* now the scroll values ( soon be there !!!!! )

		moveq.l		#28,d3		num of bits to shift
		asl.l		d3,d0		scrl into highbits
		move.l		d0,d3
		swap		d0
		move.w		d0,d3		set B scrl = A scrl
		or.l		#$0fce0000,d3	use A,B,C,D D=B+aC minterm

** All calculations are done, so save the background

; May be an idea to get all results into registers, do the blitting and then
;save results into structure. This way, the values get saved while last blit
;is still in operation!!!

		move.l		d1,d0			copy of scrn addr
		move.l		d5,d6			copy plane counter

.wait2		btst		#14,DMACONR(a5)
		bne.s		.wait2

		move.l		Bob_DamageAddr(a0),BLTDPTH(a5)	set dest
		move.w		d4,BLTAMOD(a5)			set scrn mod
		move.w		#0,BLTDMOD(a5)			set dest mod
		move.l		#$ffffffff,BLTAFWM(a5)		no masks
		move.l		#$09f00000,BLTCON0(a5)		use a,d  d=a
		
.loop2		move.l		d0,BLTAPTH(a5)			set src
		move.w		d7,BLTSIZE(a5)			and go
.wait3		btst		#14,DMACONR(a5)
		bne.s		.wait3
		add.l		Scrn_BPLSize(a1),d0
		dbra		d6,.loop2

** Background is saved, so blit the bob!

; Note the mask is assumed to be only 1 bitplane deep as there is no point in
;defining one for each plane. This means that the BLTAPTH register needs to
;be reset for each plane blitted.

		move.l		Bob_BSRC(a0),BLTBPTH(a5)
		move.w		#0,BLTAMOD(a5)
		move.w		#0,BLTBMOD(a5)
		move.w		d4,BLTCMOD(a5)
		move.w		d4,BLTDMOD(a5)
		move.l		#$ffff0000,BLTAFWM(a5)
		move.l		d3,BLTCON0(a5)

.loop3		move.l		d1,BLTCPTH(a5)			set src
		move.l		d1,BLTDPTH(a5)
		move.l		Bob_ASRC(a0),BLTAPTH(a5)
		move.w		d7,BLTSIZE(a5)	and go
.wait4		btst		#14,DMACONR(a5)
		bne.s		.wait4
		add.l		Scrn_BPLSize(a1),d1
		dbra		d5,.loop3

		movem.l		(sp)+,d0-d7/a0-a6
		rts


*****************************************************************************
*******************************            **********************************
******************************* STRUCTURES **********************************
*******************************            **********************************
*****************************************************************************

*****	Screen Structure

		rsreset
Scrn_Data	rs.l		1		address of bpl data
Scrn_Width	rs.w		1		width of screen in WORDS
Scrn_Height	rs.w		1		height of screen in lines
Scrn_Depth	rs.w		1		depth of screen 
Scrn_BPLSize	rs.l		1		num of bytes per bitplane

Scrn_SIZEOF	rs.w		0		structure size

*****	Bob Structure  ( May change in the future )

		rsreset
Bob_Toggle	rs.w		1		double buffer flag!
Bob_Width	rs.w		1		Width of bob in WORDS
Bob_Height	rs.w		1		Height of bob in lines
Bob_Depth	rs.w		1		Depth of Bob
Bob_ASRC	rs.l		1		Address of Bob Mask
Bob_BSRC	rs.l		1		Address of Bob Data
Bob_BlitSize	rs.w		1		Size of the blit
Bob_PlaneSize	rs.l		1		Dest bpl size in bytes
Bob_PlaneMod	rs.w		1		Modulo value for bpl
Bob_DamageSize	rs.l		1		size of this region
Bob_DamageAddr	rs.l		1		addr of damage region
Bob_DamageDest	rs.l		1		addr to restore damage
Bob_DamageAddr1	rs.l		1		addr of damage region
Bob_DamageDest1	rs.l		1		addr to restore damage
Bob_Anim	rs.w		1		1-8, frame number being shown
Bob_Frames	rs.w		1		frames left to display it
Bob_Anim1	rs.w		1		frame address
Bob_Frames1	rs.w		1		frames to display it for
Bob_Anim2	rs.w		1		frame address
Bob_Frames2	rs.w		1		frames to display it for
Bob_Anim3	rs.w		1		frame address
Bob_Frames3	rs.w		1		frames to display it for
Bob_Anim4	rs.w		1		frame address
Bob_Frames4	rs.w		1		frames to display it for
Bob_Anim5	rs.w		1		frame address
Bob_Frames5	rs.w		1		frames to display it for
Bob_Anim6	rs.w		1		frame address
Bob_Frames6	rs.w		1		frames to display it for
Bob_Anim7	rs.w		1		frame address
Bob_Frames7	rs.w		1		frames to display it for
Bob_Anim8	rs.w		1		frame address
Bob_Frames8	rs.w		1		frames to display it for

Bob_SIZEOF	rs.b		0		structure size


*****************************************************************************

*****************************************************************************



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

MyBob		ds.l		NUMBOBS		space for bob pointers
WorkScrn	ds.l		1
DispScrn	ds.l		1

xDir		dc.w		1
yDir		dc.w		1
X_POS		dc.w		150
Y_POS		dc.w		100

;REG		ds.w		$300		DEBUG ONLY

*****************************************************************************
*****************************           *************************************
***************************** CHIP Data *************************************
*****************************           *************************************
*****************************************************************************

		section		cop,data_c


CopList		dc.w DIWSTRT,$2c81	Top left of screen
		dc.w DIWSTOP,$2fc1	Bottom right of screen - NTSC ($2cc1 for PAL)
		dc.w DDFSTRT,$38	Data fetch start
		dc.w DDFSTOP,$d0	Data fetch stop
		dc.w BPLCON0,$3200	Select lo-res 8 colour 
		dc.w BPLCON1,0		No horizontal offset
		dc.w BPL1MOD,0		No modulo at top of screen
		dc.w BPL2MOD,0
; Reserve space to set up colour registers

Colours		ds.w 16			Space for 8 colour registers 
 
; Now set all plane pointers

		dc.w	BPL1PTH		Plane pointers for 4 planes          
CopPlanes	dc.w	0,BPL1PTL          
		dc.w	0,BPL2PTH
		dc.w	0,BPL2PTL
		dc.w	0,BPL3PTH
		dc.w	0,BPL3PTL
		dc.w	0

;		dc.w	$bc09,$fffe	wait for line 150
;		dc.w	BPL1MOD,-80	and reflect
;		dc.w	BPL2MOD,-80
;		dc.w	COLOR00,$6ce	light blue

		dc.w		$ffff,$fffe		end of list


		incdir	df1:bitmaps/
;		incdir	rrd:

; Simple ball for vector ball design. 2x9.

MyImage		
		dc.w		0,0
		dc.w		0,0	%0001110000000000,0
		dc.w		0,0	%0011111000000000,0
		dc.w		0,0	%0111111100000000,0
		dc.w		0,0	%0111111100000000,0
		dc.w		0,0	%0111111100000000,0
		dc.w		0,0	%0011111000000000,0
		dc.w		0,0	%0001110000000000,0
		dc.w		0,0
		dc.w		0,0	
		dc.w		0,0	%0001110000000000,0
		dc.w		0,0	%0011111000000000,0
		dc.w		0,0	%0111111100000000,0
		dc.w		0,0	%0111111100000000,0
		dc.w		0,0	%0111111100000000,0
		dc.w		0,0	%0011111000000000,0
		dc.w		0,0	%0001110000000000,0
		dc.w		0,0
		dc.w		0,0
		dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011111000000000,0
		dc.w		%0001110000000000,0
		dc.w		0,0

ImageMask	dc.w		%0001110000000000,0
		dc.w		%0011111000000000,0
		dc.w		%0111111100000000,0
		dc.w		%1111111110000000,0
		dc.w		%1111111110000000,0
		dc.w		%1111111110000000,0
		dc.w		%0111111100000000,0
		dc.w		%0011111000000000,0
		dc.w		%0001110000000000,0


BitPlane	Incbin colpic.bm

BitPlane1	Incbin colpic.bm	Calls the raw data from disk 

