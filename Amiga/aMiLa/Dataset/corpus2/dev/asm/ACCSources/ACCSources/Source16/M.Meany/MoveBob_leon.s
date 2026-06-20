
*****	HW_Bob.i test routine demonstrating double-buffered cookie-cut Bobs
*****	Written by M.Meany
*****	September 1991

*****	Assembles using DevpacII



; Well here's a little demo of the HW_Bob.i routines in action using a
;predefined movement table ( courtesy of Raistlin ). Sorry I never modified
;your routine Raistlin, was toooo busy removing bugs from these routines.
; Hope you agree that the Bob routines were worth the effort. Next stage is
;to add optional animation of bobs, up to 8 frames each. If you look, the
;bob structures are already prepared for this, just the BlitBob routine
;that will need modifying! The logo's are defined as two seperate Bobs and
;both are 4 bpl's deep. Opinions and bug reports please.

; Feel free to add more bobs if you so wish.

; Anyone using the Bobs and assosiated screen switching routines, please let
;me know. If they are useful I will continue their development!

; Other ideas I've had are: Give bobs a priority so they can be drawn
;in any order and a collision detection system based on the masks.

; By the way Raistlin, I find it easier to add a blank word to the end of
;each line of a bob and use 0 modulos. What's a few bytes????

; Check out that cookie-cut !!!!! 

; Not wishing to take sides ( Blaine/Raistlin ) I've done my own initialisation
;code!

; M.Meany, Aug 1991.


		incdir		source:include/
		include		hardware.i

X_MAX		EQU		192
X_MIN		EQU		0
Y_MAX		EQU		160
Y_MIN		EQU		0


Start		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error		if so quit now !
		bsr		Main		do da
		bsr		SysOn		enable system
.error		rts

*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5	a5->hardware

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
		moveq		#15,d1		d1=num of colours - 1

.Colloop	move.w		d0,(a1)+	reg offset into list
		move.w		(a0)+,(a1)+	colour value into list
		addq.w		#2,d0		offset of next reg
		dbra		d1,.Colloop	repeat for all registers

		bsr		PutPlanes	put plane addrs into Copper

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

; Plonk Bob into work screen

		move.l		MyBob,a0	bob
		move.l		DispScrn,a1	screen
		move.l		XPOS,d0		x = 100
		move.l		YPOS,d1		y = 20
		jsr		DisplayBob	and display it !!!

		move.l		MyBob1,a0	bob
		move.l		DispScrn,a1	screen
		move.l		#X_MAX,d0		x = 100
		sub.l		XPOS,d0
		move.l		YPOS,d1		y = 20
		jsr		DisplayBob	and display it !!!

; This is the start of the control loop which takes the following format:

;		1/ Get bobs new x,y position
;		2/ test LMB, if pressed then quit
;		5/ blit bob into work screen
;		6/ wait for vertical blank
;		7/ switch screens to display bob in new position
;		8/ restore background where bob was last
;		9/ goto 1

.nojoy		bsr		NextPosition	update x,y

.not_up		btst		#6,CIAAPRA	lefty ?
		beq		.done		if so, quit!

; Bob has been moved, so plonk it into work screen

.blit		move.l		MyBob,a0	bob
		move.l		WorkScrn,a1	screen
		move.l		XPOS,d0		x = 100
		move.l		YPOS,d1		y = 20
		jsr		DisplayBob	and display it !!!

		move.l		MyBob1,a0	bob
		move.l		WorkScrn,a1	screen
		move.l		#X_MAX,d0		x = 100
		sub.l		XPOS,d0
		move.l		YPOS,d1		y = 20
		jsr		DisplayBob	and display it !!!

; wait for beam to reach line 16

.VBL1		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.VBL1		if not loop back

; Switch screens

		bsr		Switch		switch screen to see Bob

; Delete old image of the bob

		move.l		MyBob1,a0
		bsr		ClearBob

		move.l		MyBob,a0	a0->Bob
		bsr		ClearBob	replace background

		bra		.nojoy		and loop back

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

Init		lea		BitPlane,a0	screen data address
		lea		32(a0),a0	skip colour map
		move.l		#320,d0		width
		move.l		#256,d1		height
		move.l		#4,d2		depth
		jsr		InitScreen	and build structure
		move.l		d0,DispScrn	save screen pointer

		lea		BitPlane1,a0	screen data address
		lea		32(a0),a0	skip colour map
		move.l		#320,d0		width
		move.l		#256,d1		height
		move.l		#4,d2		depth
		jsr		InitScreen	and build structure
		move.l		d0,WorkScrn	save screen pointer

; Now for the bobs. Being lazy, I'v used the same image data for both!

		lea		MyImage,a0	a0->Bob
		move.l		a0,a1		
		lea		3392(a1),a1	a1->mask
		moveq.l		#8,d0		width in words
		moveq.l		#53,d1		height in lines
		moveq.l		#4,d2		depth
		jsr		InitBob		and build Bob struct
		move.l		d0,MyBob	save bob pointer

		lea		MyImage,a0	a0->Bob
		move.l		a0,a1		
		lea		3392(a1),a1	a1->mask
		moveq.l		#8,d0		width in words
		moveq.l		#53,d1		height in lines
		moveq.l		#4,d2		depth
		jsr		InitBob		and build Bob struct
		move.l		d0,MyBob1	save bob pointer

		rts

*****************************************************************************

DeInit		move.l		MyBob,a0	a0->bob structure
		jsr		FreeBob

		move.l		MyBob1,a0	a0->bob structure
		jsr		FreeBob

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

; This subroutine sets up planes for a 320x200x5 display, but only
;requires minor mods to work for any size display!

;Entry		a0=start address of bitplane

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#3,d0		num of planes -1
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

; This routine updates each bobs x,y position according to a table generated
;using Raistlins little utility on this disc.

NextPosition	move.l		PosPtr,a0	a0->table
		cmp.l		#$ffffffff,(a0)	end of table?
		bne.s		.ok		if not skip the next bit

		lea		MoveTable,a0	reset to start of table
.ok		move.w		(a0)+,XPOS+2	get x position
		move.w		(a0)+,YPOS+2	get y position
		move.l		a0,PosPtr	save new pointer
		rts				and return

*****************************************************************************

; Hardware Bob Support Routines.  v1.0

; Started 21-8-91
; UpDate  22-8-91	InitScreen, FreeScreen, InitBob, FreeBob and
;			DisplayBob working.

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

FreeBob		move.l		a0,a4		save bob structure address

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

MyBob		ds.l		1
MyBob1		ds.l		1
WorkScrn	ds.l		1
DispScrn	ds.l		1

XPOS		dc.l		0
YPOS		dc.l		0

PosPtr		dc.l		MoveTable

MoveTable	include		source:m.meany/table.s
		dc.l		$ffffffff

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
		dc.w BPLCON0,$4200	Select lo-res 16 colour 
		dc.w BPLCON1,0		No horizontal offset

; Reserve space to set up colour registers

Colours		ds.w 32			Space for 32 colour registers 
 
; Now set all plane pointers

		dc.w	BPL1PTH		Plane pointers for 4 planes          
CopPlanes	dc.w	0,BPL1PTL          
		dc.w	0,BPL2PTH
		dc.w	0,BPL2PTL
		dc.w	0,BPL3PTH
		dc.w	0,BPL3PTL
		dc.w	0,BPL4PTH
		dc.w	0,BPL4PTL
		dc.w	0

		dc.w		$ffff,$fffe		end of list


		incdir	source:bitmaps/

MyImage		Incbin Logo.bm

BitPlane	Incbin pic.bm

BitPlane1	Incbin pic.bm	Calls the raw data from disk 

