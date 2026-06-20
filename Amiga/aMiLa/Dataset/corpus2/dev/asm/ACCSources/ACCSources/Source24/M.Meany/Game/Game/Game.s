
*****	Title		Game
*****	Function	not sure yet!
*****			Uses all sorts of things I've been meaning to try
*****			for ages now:
*****					Legal interrupts to hit hardware
*****					Interleaved Playfields
*****					Interleaved Bobs
*****					Screens built up from map files
*****					Bobs contained in data files
*****			
*****			
*****	Size		<disk> 10572  bytes ( Yo )		22/5/92
*****			<mem>  130700 bytes ( loads to go yet )
*****	Author		Mark Meany
*****	Date Started	May 92
*****	This Revision	
*****	Notes		Thanks for the graphics Paul, though I've scaled
*****			them to 4 planes for my code.
*****			Data file formats are becoming very involved and
*****			the necessity for a screen/block/bob designer will
*****			soon become a priority just for program development

*****	30 May 92	Bouncing bullets and raster timing are switchable.

*****	25 May 92	Added bullet control routines. Bullets 'bounce' off
*****			of background obstacles. 

*****	24 May 92	Added background collision detection using blitter.
*****			A mask is built for a screen, every time a move is
*****			made, a plane of the bobs draw mask is blitted into
*****			the screen mask, channel D off. If result of blit is
*****			zero, the move is legal.

*****	22 May 92	Added fast NT repalyer code

*****			I want this to run on a standard A500 1.2 as well as
*****			the latest version. Main concern is memory, I've set
*****			myself an upper limit of 300K, though this may be a
*****			little ambitious!

*****			As of 22/5/92 program only occupies 120K.

; First a few switches to use during development

BulletBounce	=	1	set = 1 for bouncing bullets
RasterTiming	=	0	set = 1 to measure raster time
Music		=	1	set = 1 for background music

; Now equates used throught the code

ScrnDepth	=	4		depth of screen
ScrnWidth	=	40		40 bytes wide ( = 320 pixels )
ScrnHeight	=	256		256 lines high

; The following are just guesses at present! This code could load in bob
;and screen map files, the buffer sizes are fixed here

StructMemSize	=	10000		c10K for bob structures

DBuffMemSize	=	20000		c20K for bob screen save areas

BobDataMemSize	=	20000		c20K for bobs raw data

BobXStep	=	2		x increment each frame
BobYStep	=	2		y increment each frame

BulletLife	=	40		1/50 secs to display bullets

BulletRepeat	=	10		1/50 secs between bullets

; Macro to turn drive motors off

STOPDRIVES	macro
		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB
		endm



		incdir		Source:include/
		include		hardware.i

;		opt o+

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
		move.l		d0,_GfxBase	open ok?
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

; Init 1st Copper List.

		lea		CopPlanes1,a0	where to fill in plane ptrs
		lea		Screen1,a1	raw data
		lea		CopColours1,a2	where to build colours
		bsr		PutPlanes

; Init 2nd Copper List.

		lea		CopPlanes2,a0	where to fill in plane ptrs
		lea		Screen2,a1	raw data
		lea		CopColours2,a2	where to build colours
		bsr		PutPlanes

; Strobe 1st Copper List

		move.l		#CopList1,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Stop drives 

		STOPDRIVES			use macro

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

		move.l		_GfxBase,a6
		jsr		-$01ce(a6)	DisownBlitter

		move.l		$4.w,a6		a6->SysBase
		move.l		_GfxBase,a1	a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		rts

*****************************************************************************

; Mock up of double buffer control loop -- see development.doc

Main		lea		Level,a0
		bsr		BuildScreen
		
		bsr		Init

.loop		btst		#6,CIAAPRA
		bne.s		.loop

		bsr		DeInit

		rts

*****************************************************************************
**************************** Subroutines ************************************
*****************************************************************************

Init		bsr		InitBobs		complete structure

		jsr		mt_init

		lea		MyInt,a1		Interrupt Structure
		move.b		#20,9(a1)		priority
		move.l		#IntCode,$12(a1)	addr of int sub
		moveq.l		#5,d0			interrupt number
		movea.l		$4,a6			ExecBase
		jsr		-$a8(a6)		AddIntServer

		rts

*****************************************************************************

DeInit		moveq.l		#5,d0			interrupt number
		lea		MyInt,a1		interrupt structure
		movea.l		$4,a6			ExecBase
		jsr		-$ae(a6)		RemIntServer

		jsr		mt_end

		rts

*****************************************************************************

; Level 3, vertical blank interrupt routine -- handles dbuffering & bobs

IntCode		movem.l		a0-a6/d0-d7,-(a7)	Save all registers

; Set hardware register pointer

		lea		$dff000,a5		a5->hardware regs

; Act on state of toggle 'Switch', 0=>Screen1 is visible & -1=>Screen2

		tst.l		Switch			which screen active
		bne.s		.DoScreen1		skip if Screen2

; Activate Screen2 

		move.l		#CopList2,COP1LCH(a5)	display Screen2
		move.w		#0,COPJMP1(a5)

; Update bobs coordinates

		bsr		CalcXY			move it
		bsr		MoveBullets
		bsr		TestFire

; Now blit bobs into Screen1 and exit

		moveq.l		#1,d0			Screen1
		bsr		BlitBobs		blit bobs

		bra.s		.Done

; Activate Screen1

.DoScreen1	move.l		#CopList1,COP1LCH(a5)
		move.w		#0,COPJMP1(a5)

; Update bobs coordinates

		bsr		CalcXY			move it
		bsr		MoveBullets
		bsr		TestFire

; Blit bobs into Screen2

		moveq.l		#2,d0			Screen2
		bsr		BlitBobs		blit bobs

; Toggle flag 

.Done		not.l		Switch			signal interrup

; play some music
		IFNE		Music
		jsr		mt_music		play routine
		ENDC
; Adjust bullet time-out counter

		tst.l		FireRepeat		holding back bullets
		beq.s		.readytofire		skip if not
		
		subq.l		#1,FireRepeat		else dec counter

.readytofire

		IFNE		RasterTiming

		move.w		#$fff,$dff180		for raster timing!

		ENDC
		
		movem.l		(a7)+,a0-a6/d0-d7	Bring back registers
		moveq.l		#1,d0			clear Z flag
		rts					exit

*****************************************************************************

		rsreset
dbuf_RAddr	rs.l		1		restore address in bitplane
dbuf_Save	rs.l		1		background save area
dbuf_SIZEOF	rs.l		0		structure size


		rsreset
bob_Next	rs.l		1		pointer to next bob structure
bob_X		rs.l		1		pixel x-coordinate
bob_Y		rs.l		1		pixel y-coordinate
bob_W		rs.l		1		word width + 1
bob_H		rs.l		1		raster height
bob_Data	rs.l		1		pointer to raw data
bob_DMask	rs.l		1		pointer to bob draw mask
bob_Scrn1	rs.b		dbuf_SIZEOF	Screen1 background save info
bob_Scrn2	rs.b		dbuf_SIZEOF	Screen2 background save info
bob_Active	rs.l		1		0=not blitted
bob_Mod		rs.l		1		screen modulo for this bob
bob_BSize	rs.l		1		BLITSIZE for this bob
bob_HMask	rs.l		1		pointer to collision mask
bob_ID		rs.l		1		bob identifier, see below
bob_Move	rs.l		1		addr of movement routine
bob_Dying	rs.l		1		flag, set if on its way out
bob_MMod	rs.w		1		modulo for collision mask
bob_MBSize	rs.w		1		BLITSIZE for collision mask
bob_SIZEOF	rs.l		0		structure size

; ID flags for various types of bobs. Each type has it's own structure and
;InitBobs intitalises them accordingly!

ID_Player	equ		1<<0		players bob
ID_Bullet	equ		1<<1		bob is a players bullet
ID_Deadly	equ		1<<2		enemy bullet
ID_Points	equ		1<<3		picked up for points
ID_NRG		equ		1<<4		picked up for energy
ID_Power	equ		1<<5		picked up for fire power
ID_Screen	equ		1<<6		part of screen: go under it!



;--------------	Structures for various types of bobs

; Players Bob structure : all images must be same size!

; pl_Dir determines direction of motion and is used by fire routine! It
;contains mask returned by joystick movement routine.

; The image pointers are used to set bob_Data and bob_Mask routines to the
;correct image depending on direction of motion. For the MovePlayer routine
;to work, each bob image must be followed by it's draw mask image and it's
;collision mask image.

pl_Bob		rs.b		bob_SIZEOF	bob structure
pl_Dir		rs.l		1		last move bits
pl_N		rs.l		1		pointer to bobs up image
pl_NMask	rs.l		1
pl_NE		rs.l		1		up-left image
pl_NEMask	rs.l		1
pl_E		rs.l		1		left image
pl_EMask	rs.l		1
pl_SE		rs.l		1		down-left image
pl_SEMask	rs.l		1
pl_S		rs.l		1		down image
pl_SMask	rs.l		1
pl_SW		rs.l		1		down-right image
pl_SWMask	rs.l		1
pl_W		rs.l		1		right image
pl_WMask	rs.l		1
pl_NW		rs.l		1		up-right image
pl_NWMask	rs.l		1
pl_Bullet0	rs.l		1		pointers to bullet structs
pl_Bullet1	rs.l		1
pl_Bullet2	rs.l		1
pl_Bullet3	rs.l		1
pl_Bullet4	rs.l		1
pl_Bullet5	rs.l		1
pl_Bullet6	rs.l		1
pl_Bullet7	rs.l		1
pl_Bullet8	rs.l		1
pl_Bullet9	rs.l		1
pl_SIZEOF	rs.b		0

; Players bullet structure

pb_Bob		rs.b		bob_SIZEOF	bob structure
pb_Dx		rs.l		1		X velocity
pb_Dy		rs.l		1		Y velocity
pb_Term		rs.l		1		life of bullet on screen
pb_TermCount	rs.l		1		internal life counter
pb_SIZEOF	rs.b		0



;--------------	Initialise bob structures

; This routine will fill in the bob_Mod and bob_BSize fields of all bobs in
;a given list. All other fields should already be set up. The idea is to
;allow bob banks to be built up using devpac that would be saved to disk as
;binary files. Different banks could then be read in as required during the
;course a programs execution. The only requirement is that bobs are same
;depth as screen, ALWAYS.

; Entry		a0->1st bob in the list

InitBobs	lea		BobData,a4		a4->loaded raw data
		lea		Structures,a3		a3->structure memory
		lea		BobSaves,a2		a2->DBuff save area

; obtain number of bobs defined in raw data

		move.l		(a4)+,d7		d7=num bobs
		
; clear structure memory.

		move.l		#StructMemSize>>2-1,d0	block size, in longs
		moveq.l		#0,d1			clearing value
		move.l		a3,a0			a0->mem to clear
.loop		move.l		d1,(a0)+		clear next
		dbra		d0,.loop		until all clear

; process next entry in raw data.

.NextEntry	move.l		a4,a0			a0->next entry

; determine bob type.

		move.l		(a4)+,d4		d4=bobs ID

; Deal with an ID_Player entry.

		btst.l		#0,d4			player?
		beq		.TryBullet		skip if not
		
		move.l		(a4)+,d5		d5=word width
		move.l		(a4)+,d6		d6=line height

; save a pointer to this structure for quick reference

		move.l		a3,Player

; calculate address of 1st bullet structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		pl_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; fill in players bullet structure pointers

		move.l		a0,pl_Bullet0(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet1(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet2(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet3(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet4(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet5(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet6(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet7(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet8(a3)
		lea		pb_SIZEOF(a0),a0

		move.l		a0,pl_Bullet9(a3)

; Now get initial x,y and activation values from raw data

		move.l		(a4)+,bob_X(a3)		set initial X value
		move.l		(a4)+,bob_Y(a3)		set initial Y value
		move.l		#1,bob_Active(a3)	set activation

; Set width, height and depth of the bob

		move.l		d5,d0
		addq.l		#1,d0			width+1
		move.l		d0,bob_W(a3)		set width
		move.l		d6,bob_H(a3)		set height
		
; set screen save memory address

		lea		bob_Scrn1(a3),a0	a0->1st DBuf info
		move.l		a2,dbuf_Save(a0)	write 1st buff addr
		
		lea		bob_Scrn2(a3),a0	a0->2nd DBuf info
		
		asl.l		#1,d0			d0=byte width
		mulu		d6,d0			d0=WxH
		mulu		#ScrnDepth,d0		d0=WxHxD
		add.l		d0,a2			a2->next save area
		move.l		a2,dbuf_Save(a0)	write 2nd buff addr
		add.l		d0,a2			bump a2 to next buff

; set address of bob data and bob mask pointers

		move.l		d5,d0			word width
		asl.l		#1,d0			byte width
		mulu		d6,d0			WxH
		mulu		#ScrnDepth,d0		WxHxD

		lea		pl_N(a3),a0		a0->1st entry
		moveq.l		#7,d1			eight directions
.dmloop		move.l		a4,(a0)+
		add.l		d0,a4			a4->next image
		move.l		a4,(a0)+
		add.l		d0,a4			a4->next image
		
		dbra		d1,.dmloop

; set initial bob data and mask and exit player

		move.l		pl_N(a3),bob_Data(a3)	data pointer
		move.l		pl_NMask(a3),bob_DMask(a3)
		bra.s		.DoNext

; Deal with an ID_Bullet entry.

.TryBullet	btst.l		#1,d4			bullet?
		beq		.TryNME			skip if not
		
		move.l		(a4)+,d5		d5=word width
		move.l		(a4)+,d6		d6=line height


; calculate address of next structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		pb_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; Set width and height of the bob

		move.l		d5,d0
		addq.l		#1,d0			width+1
		move.l		d0,bob_W(a3)		set width
		move.l		d6,bob_H(a3)		set height
		
; set screen save memory address

		lea		bob_Scrn1(a3),a0	a0->1st DBuf info
		move.l		a2,dbuf_Save(a0)	write 1st buff addr
		
		lea		bob_Scrn2(a3),a0	a0->2nd DBuf info
		
		asl.l		#1,d0			d0=byte width
		mulu		d6,d0			d0=WxH
		mulu		#ScrnDepth,d0		d0=WxHxD
		add.l		d0,a2			a2->next save area
		move.l		a2,dbuf_Save(a0)	write 2nd buff addr
		add.l		d0,a2			bump a2 to next buff

; set address of bob data and bob mask pointers

		move.l		d5,d0			word width
		asl.l		#1,d0			byte width
		mulu		d6,d0			WxH
		mulu		#ScrnDepth,d0		WxHxD

		move.l		a4,bob_Data(a3)		addr of raw gfx
		add.l		d0,a4			a4->bobs mask
		move.l		a4,bob_DMask(a3)
		add.l		d0,a4			addr next data

; set default life of bullet and ID

		move.l		#BulletLife,pb_Term(a3)	life in 1/50ths sec
		move.l		#ID_Bullet,bob_ID(a3)	bobs ID
		bra.s		.DoNext			and onto the next

; *************

.TryNME		nop

; *************

.DoNext		subq.l		#1,d7
		beq		.Mods
		
		move.l		bob_Next(a3),a3
		bra		.NextEntry

.Mods		move.l		#0,bob_Next(a3)		end the chain
	
		lea		Structures,a0		a0->1st bob
		
; calculate modulo for this bob.


.modloop	move.l		bob_W(a0),d0		d0=word width
		asl.l		#1,d0			d0=byte width
		neg.l		d0			d0=-width
		add.l		#ScrnWidth,d0		C & D's modulos
		move.l		d0,bob_Mod(a0)		save modulo

; calculate modulo for collision mask

		move.l		bob_W(a0),d0		bob word width + 1
		subq.l		#1,d0			bobs word width
		asl.l		#1,d0			bobs byte width
		
		move.l		#ScrnDepth,d1		bob depth
		mulu		d0,d1			byte width x depth
		sub.l		d0,d1			width x depth - width
		subq.l		#2,d1			adjust for -ve modulo
		move.w		d1,bob_MMod(a0)		save mask modulo

; calculate blitsize for current bob.

		move.l		bob_H(a0),d0		d0=bob height
		mulu		#ScrnDepth,d0		d0=blit height
		asl.l		#6,d0			into correct position
		or.l		bob_W(a0),d0		d0=blit size
		move.l		d0,bob_BSize(a0)	save BLITSIZE

; calculate blitsize for this bobs collision mask

		move.l		bob_H(a0),d0		bob height
		asl.l		#6,d0			into correct position
		or.l		bob_W(a0),d0		add bob height
		move.w		d0,bob_MBSize(a0)	and save

; step on to next bob, exit when all done.

		move.l		(a0),d0			d0=addr of next bob
		beq.s		.done			exit if NULL
		move.l		d0,a0			a4->next bob
		bra		.modloop		and loop

.done		rts

*****************************************************************************

;--------------	Blit Bobs onto Screen

; The following routine is intended to be called during vertical blank
;interrupt. It is a generic bob routine for use with bobs saved in
;interleaved format being blitted into a bitplane saved in interleaved
;format.

; Screen dimensions should be declared using following equates:

;					eq:320x256x4 display
; ScrnWidth	width in bytes		ScrnWidth  equ 40
; ScrnHeight	Height in raster lines	ScrnHeight equ 256
; ScrnDepth	number of bitplanes	ScrnDepth  equ 4

; If bob is not active, background replace still checked -- it may have just
;been killed!

; No collision detection in this code, yet.

; This routine should be called after the joystick read routine in the
;interrupt.

; Entry		a0->first bob in list to blit
;		d0=screen number -- always 1 if not double buffering
;				    else alternate 1,2,1,2,1,2,1......

;		Screen1	equ address of 1st screen
;		Screen2 equ address of 2nd screen

; Size		378 bytes

BlitBobs	movem.l		d0-d7/a2-a4,-(sp)	save

		lea		Structures,a0
		move.l		a0,a4			a0->1st bob

		lea		bob_Scrn1,a2		dbuff info offset
		move.l		#Screen1,d1		d1=bitplane address
		subq.l		#1,d0			was it screen 1?
		beq.s		.RestoreLoop		yes, continue!
		
		lea		bob_Scrn2,a2		dbuff info offset
		move.l		#Screen2,d1		d1=bitplane address

; Replace all backgrounds in Screen1, at same time calculate bobs next
;destination address from bob_X and bob_Y ready for stages 2 and 3.

.RestoreLoop	move.l		a2,d0			d0=dbuf offset
		lea		(a0,d0),a3		a3->dbuf info

		move.l		dbuf_RAddr(a3),d7	d7=restore address

		move.l		#0,dbuf_RAddr(a3)	clear
		
		move.l		bob_Y(a0),d2		d2=Y
		mulu		#ScrnWidth*ScrnDepth,d2	d2=line offset
		move.l		bob_X(a0),d0		d0=X
		ror.l		#4,d0			d0=X/16
		add.w		d0,d2			d2=start word offset
		add.w		d0,d2
		add.l		d1,d2			d2=new address
		
		tst.l		bob_Active(a0)		bob enabled?
		beq.s		.Skip			skip if not!
		
		move.l		d2,dbuf_RAddr(a3)	save new address

.Skip		tst.l		d7			got restore address?
		beq.s		.DontRestore		skip if not!

; Prepare values to stuff into blitter. Chances are, the blitter is still
;blitting the last background when this code executes --- get it done before
;'busy-waiting'!

		move.l		dbuf_Save(a3),d6	SourceA

		moveq.l		#-1,d5			A mask value

		move.l		bob_Mod(a0),d4		A and D modulo's

		move.l		#$09f00000,d3		use A and D: D=A

		move.l		bob_BSize(a0),d2	d2=blit size

; Note that following blitter stuff uses long words to stuff two registers
;in one go. Those affected are: AFWM & ALWM, AMOD & DMOD, CON0 & CON1

; Since screen is interleaved, backrgound can be restored with just one blit.
;The blit size will be: Height=ScrnDepth*BobHeight, Width=Bob Width

.BWait1		btst		#14,DMACONR(a5)		blitter finished yet
		bne.s		.BWait1			wait if not

		move.l		d6,BLTAPTH(a5)		source A
		move.l		d7,BLTDPTH(a5)		destination
		move.l		d5,BLTAFWM(a5)		masks
		move.l		d4,BLTAMOD(a5)		write A and D modulos
		move.l		d3,BLTCON0(a5)		use A & D: D=A
		move.w		d2,BLTSIZE(a5)		start blit

; Get pointer to next bob structure & loop while not NULL. When NULL, end of
;list has been reached, so start saving backgrounds!

.DontRestore	move.l		(a0),d0			d0=addr of next bob
		beq.s		.StartSaving		skip if all done
		
		move.l		d0,a0			a0->next bob
		bra		.RestoreLoop		and loop

; All backgrounds have now been restored and bobs new dest addr has been
;calculated. Start saving backgrounds for active bobs!

.StartSaving	move.l		a4,a0			a0->1st bob

		tst.l		bob_Active(a0)		bob enabled?
		bne.s		.SaveLoop		skip if so!

; This bob is switched off. Clear the restore address and skip to next bob.

		move.l		#0,dbuf_RAddr(a3)	clear field
		bra.s		.DontSave		and skip

; Pre calculate blitter values, this takes place while blitter is still in
;action. Address of word to start saving from has already been calculated
;and stored in the bob_RAddr1 field.

.SaveLoop	move.l		a2,d0			d0=dbuf offset
		lea		(a0,d0),a3		a3->dbuf info

		move.l		dbuf_RAddr(a3),d7	SourceA
		move.l		dbuf_Save(a3),d6	destination
		moveq.l		#-1,d5			A mask value

		move.l		bob_Mod(a0),d4		d4=word width
		swap		d4			in correct order

		move.l		#$09f00000,d3		use A and D: D=A

		move.l		bob_BSize(a0),d2	d2=blit size

; Note that following blitter stuff uses long words to stuff two registers
;in one go. Those affected are: AFWM & ALWM, AMOD & DMOD, CON0 & CON1

; Since screen is interleaved, backrgound can be saved with just one blit.
;The blit size will be: Height=ScrnDepth*BobHeight, Width=Bob Width

.BWait2		btst		#14,DMACONR(a5)		blitter finished yet
		bne.s		.BWait2			wait if not

		move.l		d7,BLTAPTH(a5)		source A
		move.l		d6,BLTDPTH(a5)		destination
		move.l		d5,BLTAFWM(a5)		masks
		move.l		d4,BLTAMOD(a5)		write A and D modulos
		move.l		d3,BLTCON0(a5)		use A & D: D=A
		move.w		d2,BLTSIZE(a5)		start blit

; Get pointer to next bob structure & loop while not NULL. When NULL, end of
;list has been reached, so start blitting the bobs!

.DontSave	move.l		(a0),d0			d0=addr of next bob
		beq.s		.StartBlit		skip if all done
		
		move.l		d0,a0			a0->next bob
		bra		.SaveLoop		and loop

; All backgrounds have now been saved. Start blitting the bobs. Register a4
;is no longer required, so use it instead of copying into a0.

.StartBlit	tst.l		bob_Active(a4)		bob enabled?
		beq.s		.DontBlit		skip if not

; Precalculate values to stuff into the blitter. Need to determine the scroll
;values this time as well! Because bob and bitplane are interleaved, the bob
;mask MUST be same depth as the bitplane.

; Channel Usage:	A=bobs mask: background shows through bits set to 0.
;			B=bobs data
;			C=bitplane
;			D-bitplane
; Minterm Used:		D=B+aC

.BlitLoop	move.l		a2,d0			d0=dbuf offset
		lea		(a4,d0),a3		a3->dbuf info

		move.l		bob_DMask(a4),d7	source A
		move.l		bob_Data(a4),d6		source B
		move.l		dbuf_RAddr(a3),d5	source C + D
		move.l		#$ffff0000,d4		masks

		move.l		bob_Mod(a4),d3		screen modulo
		swap		d3
		move.w		#-2,d3			A & B's modulos


		move.l		bob_X(a4),d2		x-coordinate
		and.l		#$f,d2			d0=scroll value
		ror.w		#4,d2			into correct position
		move.l		d2,d1			get a copy
		swap		d2			into high word
		move.w		d1,d2			and low word
		or.l		#$0fca0000,d2	bltcon0: A,B,C,D: D=AB+aC

		move.l		bob_BSize(a4),d1	d1=blit size

; Note that following blitter stuff uses long words to stuff two registers
;in one go. Those affected are: AFWM & ALWM, AMOD & DMOD, CON0 & CON1

; Since screen is interleaved, backrgound can be restored with just one blit.
;The blit size will be: Height=ScrnDepth*BobHeight, Width=Bob Width

.BWait3		btst		#14,DMACONR(a5)		blitter finished yet
		bne.s		.BWait3			wait if not

		move.l		d7,BLTAPTH(a5)		source A, bob mask
		move.l		d6,BLTBPTH(a5)		source B, bob data
		move.l		d5,BLTCPTH(a5)		source C, bitplane
		move.l		d5,BLTDPTH(a5)		destination, bitplane
		move.l		d4,BLTAFWM(a5)		masks
		move.l		d3,BLTCMOD(a5)		C & B's modulos
		swap		d3			reverse
		move.l		d3,BLTAMOD(a5)		A & D's modulos
		move.l		d2,BLTCON0(a5)		use A & D: D=A
		move.w		d1,BLTSIZE(a5)		start blit

; Get pointer to next bob structure & loop while not NULL. When NULL, end of
;list has been reached, so start saving backgrounds!

.DontBlit	move.l		(a4),d0			d0=addr of next bob
		beq.s		.Done			skip if all done
		
		move.l		d0,a4			a4->next bob
		bra		.BlitLoop		and loop

.Done		movem.l		(sp)+,d0-d7/a2-a4	restore
		rts

*****************************************************************************

; Updates players bobs X and Y position according to condition of joystick.
;Also calls a routine that checks the validity of the move. Should be called
;during VBlank interrupt.

CalcXY		bsr		TestJoy

		tst.l		d2			any movement?
		beq		.NoGo

		move.l		Player,a0		bob structure

		move.l		d2,pl_Dir(a0)		save direction

		move.l		bob_X(a0),d6		X
		move.l		bob_Y(a0),d7		Y

		btst		#0,d2			right?
		beq.s		.checkleft
		cmp.l		#304-BobXStep,d6
		bge.s		.checkdown
		addq.l		#BobXStep,d6
		
.checkleft	btst		#1,d2			left?
		beq.s		.checkdown
		cmp.l		#BobXStep,d6
		blt.s		.checkdown
		subq.l		#BobXStep,d6
		
.checkdown	btst		#2,d2			down?
		beq.s		.checkup
		cmp.l		#237-BobYStep,d7
		bge.s		.done
		addq.l		#BobYStep,d7
		
.checkup	btst		#3,d2			Up?
		beq.s		.done
		cmp.l		#BobYStep,d7
		blt.s		.done
		subq.l		#BobYStep,d7

; Now check move is valid

.done		move.l		d6,d0			X
		move.l		d7,d1			Y
		bsr		CheckPlyr		check move
		tst.l		d0			background collision?
		bne.s		.doupdate		skip if not

; Collision has occurred. See if keeping old X will help!

		move.l		bob_X(a0),d0		X
		move.l		d7,d1			Y
		bsr		CheckPlyr		check adjusted move
		tst.l		d0			collision still?
		beq.s		.tryY			skip if there was!
		move.l		bob_X(a0),d6		set new X value
		bra.s		.doupdate

; Changing X had no effect, try changing Y

.tryY		move.l		d6,d0			X
		move.l		bob_Y(a0),d1		Y
		bsr		CheckPlyr
		tst.l		d0
		beq.s		.doimage
		move.l		bob_Y(a0),d7		set new Y value
		
.doupdate	move.l		d6,bob_X(a0)		update position
		move.l		d7,bob_Y(a0)		

; Now set bobs image and mask
		
.doimage	cmp.b		#%00001000,d2			North
		bne.s		.I1
		move.l		pl_N(a0),bob_Data(a0)
		move.l		pl_NMask(a0),bob_DMask(a0)
		bra		.NoGo

.I1		cmp.b		#%00001001,d2			North-East
		bne.s		.I2
		move.l		pl_NE(a0),bob_Data(a0)
		move.l		pl_NEMask(a0),bob_DMask(a0)
		bra		.NoGo

.I2		cmp.b		#%00000001,d2			East
		bne.s		.I3
		move.l		pl_E(a0),bob_Data(a0)
		move.l		pl_EMask(a0),bob_DMask(a0)
		bra		.NoGo
		
.I3		cmp.b		#%00000101,d2			South-East
		bne.s		.I4
		move.l		pl_SE(a0),bob_Data(a0)
		move.l		pl_SEMask(a0),bob_DMask(a0)
		bra		.NoGo

.I4		cmp.b		#%00000100,d2			South
		bne.s		.I5
		move.l		pl_S(a0),bob_Data(a0)
		move.l		pl_SMask(a0),bob_DMask(a0)
		bra		.NoGo

.I5		cmp.b		#%00000110,d2			South-West
		bne.s		.I6
		move.l		pl_SW(a0),bob_Data(a0)
		move.l		pl_SWMask(a0),bob_DMask(a0)
		bra		.NoGo

.I6		cmp.b		#%00000010,d2			West
		bne.s		.I7
		move.l		pl_W(a0),bob_Data(a0)
		move.l		pl_WMask(a0),bob_DMask(a0)
		bra		.NoGo

.I7		cmp.b		#%00001010,d2			North-West
		bne.s		.NoGo
		move.l		pl_NW(a0),bob_Data(a0)
		move.l		pl_NWMask(a0),bob_DMask(a0)

.NoGo		rts

*****************************************************************************

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

*****************************************************************************

; Subroutine that blits one plane of bobs draw mask into the background mask.
;If a collision occurs, returns d0=0.


; Entry		d0=X
;		d1=Y
;		a0->bob structure

; Exit		d0=0 if collision

; Uses the top plane of draw mask and blits this into the screen mask bitplane
;If result of blit is zero, then no collision occured.

CheckPlyr	movem.l		d1-d7,-(sp)

		moveq.l		#0,d7
		move.l		d7,d6

; get byte offset into register d7. Also leaves scroll in highest nibble of
;register d0

		ror.l		#4,d0			/16
		move.l		d0,d7			word offset
		add.w		d0,d7			byte offset

; calculate bltcon0 and bltcon1, into register d6

		swap		d0
		and.w		#$f000,d0		isolate scroll
		move.l		#$0aa0,d6		use A & C; d=AC
		or.w		d0,d6
		swap		d6

; finish calculating dest address of blit

		mulu		#ScrnWidth,d1		line offset
		add.l		d1,d7			add to byte offset
		add.l		#Scene,d7		add start address

; Wait for blitter, busy-busy-wait-wait

.Bloop		btst		#14,DMACONR(a5)
		bne.s		.Bloop
		
		move.l		bob_DMask(a0),BLTAPTH(a5)  source1 = bob
		move.l		d7,BLTCPTH(a5)		  source2 = screen
		move.w		bob_MMod(a0),BLTAMOD(a5)  bob modulo
		move.w		bob_Mod+2(a0),BLTCMOD(a5) screen modulo
		move.l		#$ffff0000,BLTAFWM(a5)	  masks
		move.l		d6,BLTCON0(a5)		  control bits
		move.w		bob_MBSize(a0),BLTSIZE(a5) blit it

; Wait for blit to finish

.Bloop1		btst		#14,DMACONR(a5)
		bne.s		.Bloop1

; Check status of the blit to see if collision occurred

		moveq.l		#0,d0			default = collision
		btst		#13,DMACONR(a5)		test blit
		beq.s		.done			got a collision, exit
		moveq.l		#1,d0			flag no collision

.done		movem.l		(sp)+,d1-d7
		rts

*****************************************************************************

; Subroutine that checks if the player has pressed fire. If so checks if
;there is a free bullet. If so sets bullet bob in motion!

TestFire	tst.l		FireRepeat		can we fire yet?
		bne		.nonefree		exit if not

		tst.b		CIAAPRA			joystick fire button
		bmi		.nonefree		skip if not
		
; fire button pressed, see if there is a bullet free for use.

		move.l		Player,a1		a1->bob struct	
		move.l		pl_Dir(a1),d2		last direction
		
		move.l		pl_Bullet0(a1),a0	a0->bullet strct ptrs
		moveq.l		#9,d0			num bullets - 1
		
.Loop		tst.l		bob_Active(a0)		bullet in use?
		beq.s		.FoundOne		exit loop if not
		
		move.l		(a0),a0			next bullet
		dbra		d0,.Loop		and loop
		bra.s		.nonefree		exit if none free

; found a free bullet, give it the same X,Y as players bob

.FoundOne	move.l		#BulletRepeat,FireRepeat  set time-out

		move.l		#1,bob_Active(a0)	fire it
		move.l		bob_X(a1),bob_X(a0)	set X
		add.l		#6,bob_X(a0)
		move.l		bob_Y(a1),bob_Y(a0)	set Y
		add.l		#6,bob_Y(a0)
		
; Set speed to double that of ship

		moveq.l		#0,d0			dx
		moveq.l		#0,d1			dy

		btst		#3,d2			going up?
		beq.s		.trydown
		move.l		#-BobYStep*2,d1		dy
		
.trydown	btst		#2,d2			going down?
		beq.s		.tryleft
		move.l		#BobYStep*2,d1		dy
		
.tryleft	btst		#1,d2			going left?
		beq.s		.tryright
		move.l		#-BobXStep*2,d0		dx
		
.tryright	btst		#0,d2			going right?
		beq.s		.notright
		move.l		#BobXStep*2,d0		dx

.notright	move.l		d0,pb_Dx(a0)		set Dx
		move.l		d1,pb_Dy(a0)		set Dy

		move.l		pb_Term(a0),pb_TermCount(a0) set life		
		
.nonefree	rts

*****************************************************************************

; Routine to move all bullets. Bullets bounce off of background features!

MoveBullets	move.l		Player,a1		players bob structure
		lea		pl_Bullet0(a1),a1	1st bullet pointer
		moveq.l		#9,d4			num bullets - 1
		
.loop		move.l		(a1)+,a0		a0->next bullet strct
		tst.l		bob_Active(a0)		in use?
		beq.s		.notfired		skip if not

		subq.l		#1,pb_TermCount(a0)	dec life
		bne.s		.stillgoing		skip if still alive
		move.l		#0,bob_Active(a0)	else disable
		bra		.notfired		and skip

.stillgoing	move.l		bob_X(a0),d6		X
		move.l		bob_Y(a0),d7		Y
		add.l		pb_Dx(a0),d6		X = X + dx
		add.l		pb_Dy(a0),d7		Y = Y + dy

;		bra		.domove			*** DEBUG

; Now check move is valid

		move.l		d6,d0			X
		move.l		d7,d1			Y
		bsr		CheckPlyr		check move
		tst.l		d0			background collision?
		bne.s		.domove			skip if not

		IFNE		BulletBounce

; Collision has occurred. See if keeping old X will help!

		move.l		bob_X(a0),d0		X
		move.l		d7,d1			Y
		bsr		CheckPlyr		check adjusted move
		tst.l		d0			collision still?
		beq.s		.tryY			skip if there was!
		move.l		bob_X(a0),d6		set new X value
		neg.l		pb_Dx(a0)		reverse direction
		bra.s		.domove

; Changing X had no effect, try changing Y

.tryY		move.l		d6,d0			X
		move.l		bob_Y(a0),d1		Y
		bsr		CheckPlyr
		tst.l		d0
		beq.s		.notfired
		move.l		bob_Y(a0),d7		set new Y value
		neg.l		pb_Dy(a0)		negate direction

		ENDC

		IFEQ		BulletBounce
		
		move.l		#0,bob_Active(a0)	disable bullet

		ENDC

.domove		move.l		d6,bob_X(a0)		update position
		move.l		d7,bob_Y(a0)		


.notfired	dbra		d4,.loop		for all 10 bullets
		rts

*****************************************************************************


; Subroutine that waits for the left mouse button to be pressed and then
;released before returning. Use this to pause a program while the user looks
;at screen displays etc.	

LeftMouse	btst		#6,$bfe001
		bne		LeftMouse
.loop		btst		#6,$bfe001
		beq		.loop
		rts

; Subroutine that waits for the right mouse button to be pressed and then
;released before returning. Use this to pause a program while the user looks
;at screen displays etc.	

RightMouse	btst		#2,$dff016
		bne.s		RightMouse
.Again		btst		#2,$dff016
		beq.s		.Again
		rts

*****************************************************************************

; This subroutine sets up planes for a 320x256x4 display and sets up the
;colour. Assumes raw data saved as CMAP BEHIND.

;Entry		a0->start of Copper List
;		a1->start of bitplane data
;		a2->position in list to store colour data.

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#ScrnDepth-1,d0	num of planes -1
		move.l		#ScrnWidth,d1	size of each bitplane
		move.l		a1,d2		d2=addr of 1st bitplane
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		add.l		d1,d2		point to next plane
		dbra		d0,.PlaneLoop	repeat for all planes

		move.l		#$180,d0	color00 offset
		moveq.l		#(1<<ScrnDepth)-1,d1	colour counter
		lea		CMAP,a1 	a1->CMAP
.colourloop	move.w		d0,(a2)+	set colour register
		move.w		(a1)+,(a2)+	and the RGB value
		addq.l		#2,d0		bump colour register
		dbra		d1,.colourloop	for all 16 colours

		rts

*****************************************************************************

;--------------	Builds a screen from screen block data

; Each block must be 16pixels x 16lines x same depth as display, saved in
;continuous memory using interleaved format.

; Each mask must be 16pixels x 16pixels in one bitplane, saved in continuous
;memory.

; This sub uses blitter busy-wait loops, but since it is only called during
;screen initialisation and not during game-play this should not make much
;difference!

; Entry		a0->Screen Data ( block info )

; Also		a5->dff000 -- standard!
;		ScrnWidth = byte width of screen  ( ie ScrnWidth equ 40 )
;		ScrnHeight= raster height of screen ( ie ScrnHeight equ 256 )
;		ScrnDepth = number of bitplanes ( ie ScrnDepth equ 4 )

BuildScreen	moveq.l		#0,d6			init X counter
		move.l		d6,d7			and Y counter
		
; calculate source address

.BuildLoop	moveq.l		#0,d0			clear
		move.b		(a0)+,d0		block number
		asl.l		#5,d0			x block size (16x2)
		mulu		#ScrnDepth+1,d0		x depth
		add.l		#Blocks,d0		+ blocks start addr

		move.l		d0,-(sp)		save block addr

; calculate destination address

		move.l		d7,d2			y
		mulu		#ScrnWidth*ScrnDepth,d2	line offset
		add.l		d6,d2
		add.l		d6,d2			add word offset
		move.l		d2,d1
		add.l		#Screen1,d1		add start address

; blit this block into screen 1

.BBusy		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		.BBusy			if so wait
		
		move.l		d0,BLTAPTH(a5)		A
		move.l		d1,BLTDPTH(a5)		D
		move.l		#-1,BLTAFWM(a5)		mask values
		move.l		#$09f00000,BLTCON0(a5)	use A & D, D=A
		move.l		#ScrnWidth-2,BLTAMOD(a5) modulo values
		move.w		#1!ScrnDepth<<10,BLTSIZE(a5) size of blit

; blit this block into screen2

		move.l		d2,d1
		add.l		#Screen2,d1			add start address

; blit this block into screen 2

.BBusy1		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		.BBusy1			if so wait
		
		move.l		d0,BLTAPTH(a5)		A
		move.l		d1,BLTDPTH(a5)		D
		move.l		#-1,BLTAFWM(a5)		mask values
		move.l		#$09f00000,BLTCON0(a5)	use A & D, D=A
		move.l		#ScrnWidth-2,BLTAMOD(a5) modulo values
		move.w		#1!ScrnDepth<<10,BLTSIZE(a5) size of blit

; Calculate address of mask

		move.l		(sp)+,d0		block addr
		add.l		#32*ScrnDepth,d0	mask address
				
; calculate destination address

		move.l		d7,d1			y
		mulu		#ScrnWidth,d1		line offset
		add.l		d6,d1
		add.l		d6,d1			add word offset
		add.l		#Scene,d1		add start address

; blit this block

.BBusy2		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		.BBusy2			if so wait
		
		move.l		d0,BLTAPTH(a5)		A
		move.l		d1,BLTDPTH(a5)		D
		move.l		#-1,BLTAFWM(a5)		mask values
		move.l		#$09f00000,BLTCON0(a5)	use A & D, D=A
		move.l		#ScrnWidth-2,BLTAMOD(a5) modulo values
		move.w		#1!1<<10,BLTSIZE(a5)	size of blit


; bump counters and loop while still valid

		addq.l		#1,d6			bump X counter
		cmp.l		#ScrnWidth>>1,d6	end of line?
		blt		.BuildLoop		loop back if not

		moveq.l		#0,d6			reset x counter
		add.l		#16,d7			bump y counter
		cmp.l		#ScrnHeight,d7		end of screen
		blt		.BuildLoop		loop back if not

; All done, so return

		rts

*****************************************************************************
***************************** Data ******************************************
*****************************************************************************

grafname	dc.b		'graphics.library',0
		even
_GfxBase	ds.l		1
sysDMA		ds.l		1
syscop		ds.l		1

Player		dc.l		0

Switch		dc.l		0		flag to signal switch
CurrentCop	dc.l		0		flag to indicate which list

MyInt		ds.b		22		Interrupt structure

FireRepeat	ds.l		1		bullet time-out counter

*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************

		section		cop,data_c

CopList1	dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,ScrnWidth*(ScrnDepth-1) Modulos for interleaved
		dc.w BPL2MOD,ScrnWidth*(ScrnDepth-1) bitplane data

CopColours1	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout1	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes1	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w	$ffff,$fffe		end of list

CopList2	dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,ScrnWidth*(ScrnDepth-1) Modulos for interleaved
		dc.w BPL2MOD,ScrnWidth*(ScrnDepth-1) bitplane data

CopColours2	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout2	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes2	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w	$ffff,$fffe		end of list

; The Bob graphics: interleaved, various sizes.

		incdir		source:m.meany/game/game/

; Raw gfx data for all bobs, includes masks

BobData		incbin		'bobs.bm',0
		even

; Raw data for tiless that form levels. Each tile is interleaved and followed
;by a single mask plane used for collision detection. 

; Using designer : 20 x 16 blocks, Depth = 4, saved Interleaved and Mask On.

Blocks		incbin		'blocks.bm',0
		even

; Data that defines which blocks used to build this level. As saved by Screen
;designer.

Level		incbin		'Map.bm',0
		even

; Colours to stuff into Copper Lists

CMAP		include		'ColourMap.i',0

; BSS hunks used to minimise disk space occupied by program

; Followind CHIP BSS hunk used for screens, screen masks and bob background
;save areas
		section		screens,BSS_C

Scene		ds.b		ScrnWidth*ScrnHeight
Screen1		ds.b		ScrnWidth*ScrnHeight*ScrnDepth
Screen2		ds.b		ScrnWidth*ScrnHeight*ScrnDepth
BobSaves	ds.b		DBuffMemSize

; Following BSS hunk used to build linked bob structures in

		section		other,BSS

Structures	ds.b		StructMemSize

		section		music,code_c

;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 8 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used registers: d0-d3/a0-a7|	=INTENA н
;н  Mahoney & Kaktus - (C) E.A.S. 1990  н
;нннннннннннннннннннннннннннннннннннннннн
	section	music,code			; Public code
mt_init:lea	mt_data,a0
	lea	mt_mulu(pc),a1
	move.l	#mt_data+$c,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4:move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,mt_lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.w	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,mt_lop3

	move.l	$78.w,mt_oldirq-mt_samplestarts-$7c(a1)
	or.b	#2,$bfe001
	move.b	#6,mt_speed-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,mt_songpos-mt_samplestarts-$7c(a1)
	move.b	d0,mt_counter-mt_samplestarts-$7c(a1)
	move.w	d0,mt_pattpos-mt_samplestarts-$7c(a1)
	rts


mt_end:	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts


mt_music:
	lea	mt_data,a0
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_counter-mt_voice1(a4)
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	moveq	#0,d0
	move.b	d0,mt_counter-mt_voice1(a4)
	move.w	d0,mt_dmacon-mt_voice1(a4)
	lea	mt_data,a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1

	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	lea	mt_playvoice(pc),a6
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	jsr	(a6)

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma

	lea	$bfd000,a3
	move.b	#$7f,$d00(a3)
	move.w	#$2000,$dff09c
	move.w	#$a000,$dff09a
	move.l	#mt_irq1,$78.w
	moveq	#0,d0
	move.b	d0,$e00(a3)
	move.b	#$a8,$400(a3)
	move.b	d0,$500(a3)
	or.w	#$8000,mt_dmacon-mt_voice4(a4)
	move.b	#$11,$e00(a3)
	move.b	#$81,$d00(a3)

mt_nodma:
	add.w	#$10,mt_pattpos-mt_voice4(a4)
	cmp.w	#$400,mt_pattpos-mt_voice4(a4)
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos-mt_voice4(a4)
	clr.b	mt_break-mt_voice4(a4)
	addq.b	#1,mt_songpos-mt_voice4(a4)
	and.b	#$7f,mt_songpos-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos-mt_voice4(a4)
mt_exit:tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_nonew:
	lea	$dff0a0,a5
	lea	mt_com(pc),a6
	jsr	(a6)
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	jsr	(a6)
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	jsr	(a6)
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	jsr	(a6)
	tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_irq1:tst.b	$bfdd00
	move.w	mt_dmacon(pc),$dff096
	move.l	#mt_irq2,$78.w
	move.w	#$2000,$dff09c
	rte

mt_irq2:tst.b	$bfdd00
	movem.l	a3/a4,-(a7)
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)
	movem.l	(a7)+,a3/a4
	move.b	#0,$bfde00
	move.b	#$7f,$bfdd00
	move.l	mt_oldirq(pc),$78.w
	move.w	#$2000,$dff09c
	move.w	#$2000,$dff09a
	rte

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	mt_oldinstr

	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	move.l	mt_mulu(pc,d2.w),a3
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	moveq	#0,d3
	move.w	(a3)+,d3
	beq	mt_noloop
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:dcb.l	$20,0

mt_noloop:
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)
	move.w	$12(a4),8(a5)

mt_oldinstr:
	move.w	(a4),d3
	and.w	#$fff,d3
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	d3,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0
	or.w	d0,mt_dmacon-mt_playvoice(a6)
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:moveq	#0,d0
	move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	move.b	d0,3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_normper
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	lea	mt_periods(pc),a0
mt_arp3:cmp.w	(a0)+,d1
	blt.s	mt_arp3
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	beq.s	mt_arp
	cmp.b	#6,d0
	beq.s	mt_volvib
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:move.w	$12(a4),8(a5)
	rts

mt_com2:move.b	2(a4),d0
	and.b	#$f,d0
	beq	mt_rts
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break-mt_playvoice(a6)
	rts

mt_songjmp:
	move.b	#1,mt_break-mt_playvoice(a6)
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos-mt_playvoice(a6)
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed-mt_playvoice(a6)
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	13,0
		dc.w	1
mt_voice2:	dcb.w	13,0
		dc.w	2
mt_voice3:	dcb.w	13,0
		dc.w	4
mt_voice4:	dcb.w	13,0
		dc.w	8
mt_oldirq:	dc.l	0

	section	modul,data_c			; Chip data
mt_data	incbin	'Source:modules/mod.music'
