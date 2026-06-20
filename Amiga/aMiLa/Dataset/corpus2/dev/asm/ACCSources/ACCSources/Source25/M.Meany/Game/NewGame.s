
*****	Title		Game
*****	Function	Enjoyment!
*****			
*****			
*****	Size		530K
*****	Author		Mark Meany
*****	Date Started	
*****	This Revision	June 92
*****	Notes		At present requires 1 Meg CHIP memory!
*****			й M.Meany, 1992.


; The source for this game was contained in numerous files, but to fit it on
;this issue of ACC it was necessary to bring all these together into one
;file. Sorry if this makes for hard reading, it's the best I could do!

*****	Requires 1 Meg of CHIP memory to run at present. Even then it may be
*	neceessary to reset and boot the game!

RasterTiming	=	0	set = 1 to measure raster time


*****************************************************************************
; the structure used by sound effects driver

		rsreset
ch_New		rs.w		1		set to play new sound
ch_Active	rs.w		1		set if sound is playing
ch_Addr		rs.l		1		addr of raw data
ch_Len		rs.w		1
ch_Count	rs.w		1		vbl to allow it to play
ch_SIZEOF	rs.b		0

; variables used in game

		rsreset
sysINT		rs.l		1
sysDMA		rs.l		1
syscop		rs.l		1

Level3		rs.l		1

IntroOver	rs.w		1		main flag
IntroFlag	rs.w		1		clear interrupt flag
IntroCur	rs.l		1		set cursor status
IntroChar	rs.l		1		set addr of text
IntroX		rs.l		1		reset X position
IntroY		rs.l		1		reset Y position

Player		rs.l		1		->players bob structure
Enemy		rs.l		1		->1st enemy
Explosion	rs.l		1		->1st explosion

PlayerDead	rs.w		1		cleared when hit by NME
Cloak		rs.w		1		invincibility counter
LevelClear	rs.w		1		set when level complete
GotData		rs.w		1		set when module retrieved
CountDown	rs.w		1		level countdown timer
BounceOn	rs.w		1		set for bouncing bullets
BulletCount	rs.w		1		number of bullets left
BulletRate	rs.w		1		delay vbls between bullets
BulletPower	rs.w		1		damage done by a bullet

LevelNum	rs.l		1	1	current level
Score		rs.l		1		players score
Lives		rs.l		1	4	lives remaining
Bonus		rs.l		1		levels bonus points


CollTemp	rs.l		1		following two used 
HitMe		rs.l		1

X		rs.l		1		on screen X position
Y		rs.l		1		on screen Y position

pf_X		rs.l		1		playfield X scroll
pf_Y		rs.l		1		playfield Y scroll

Switch		rs.w		1		flag to signal switch
CurrentCop	rs.l		1		flag to indicate which list

NextChar	rs.l		1	ScrollText

ScrollCount	rs.b		2	1,0

MyInt		rs.b		22		Interrupt structure

FireRepeat	rs.w		1	1	bullet time-out counter

Channel0	rs.b		ch_SIZEOF	audio struct

Channel1	rs.b		ch_SIZEOF	audio struct

vars_SIZEOF	rs.b		0		memory size

; screen double buffer structure

		rsreset
dbuf_RAddr	rs.l		1		restore address in bitplane
dbuf_Save	rs.l		1		background save area
dbuf_SIZEOF	rs.l		0		structure size

; generic blitter object structure

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
bob_Draw	rs.l		1		flag set if bob is visible
bob_Mod		rs.l		1		screen modulo for this bob
bob_BSize	rs.l		1		BLITSIZE for this bob
bob_HMask	rs.l		1		collision mask - can hit!
bob_ID		rs.l		1		bob identifier, see below
bob_Move	rs.l		1		addr of movement routine
bob_Dying	rs.l		1		flag, set if on its way out
bob_Points	rs.l		1		points gained if killed
bob_MMod	rs.w		1		modulo for collision mask
bob_MBSize	rs.w		1		BLITSIZE for collision mask
bob_SIZEOF	rs.l		0		structure size

; ID flags for various types of bobs. Each type has it's own structure and
;InitBobs intitalises them accordingly!

ID_Player	equ		1<<0		players bob
ID_Bullet	equ		1<<1		bob is a players bullet
ID_Deadly	equ		1<<2		something 'hittable'
ID_PowerUp	equ		1<<3!ID_Deadly	power up bullets
ID_SpeedUp	equ		1<<4!ID_Deadly	speed up bullets
ID_Refil	equ		1<<5!ID_Deadly	reload guns
ID_Bounce	equ		1<<6!ID_Deadly	bouncing bullets
ID_FollowMe	equ		1<<7!ID_Deadly	a homing enemy
ID_Repeater	equ		1<<8!ID_Deadly	an enemy that follows a path
ID_Cload	equ		1<<9!ID_Deadly	invincible
ID_Data		equ		1<<10!ID_Deadly	levels data module
ID_Lives	equ		1<<11!ID_Deadly	extra life
ID_Bomb		equ		1<<12!ID_Deadly	level detenator
ID_Exit		equ		1<<13!ID_Deadly	levels Exit
ID_Dripper	equ		1<<14!ID_Deadly	an enemy that can vanish
ID_Explode	equ		1<<15		exploding bob

;--------------	Structures for various types of bobs

; Players Bob structure : all images must be same size!

; pl_Dir determines direction of motion and is used by fire routine! It
;contains mask returned by joystick movement routine.

; The image pointers are used to set bob_Data and bob_Mask routines to the
;correct image depending on direction of motion. For the MovePlayer routine
;to work, each bob image must be followed by it's draw mask image and it's
;collision mask image.

		rsreset
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

		rsreset
pb_Bob		rs.b		bob_SIZEOF	bob structure
pb_Dx		rs.l		1		X velocity
pb_Dy		rs.l		1		Y velocity
pb_Term		rs.l		1		life of bullet on screen
pb_TermCount	rs.l		1		internal life counter
pb_SIZEOF	rs.b		0

; 'Follow me' bob structure ... An enemy that homes in on the player

		rsreset
efm_Bob		rs.b		bob_SIZEOF	bob structure
efm_Dx		rs.l		1		x increment
efm_Dy		rs.l		1		y increment
efm_Dir		rs.l		1		last move bits
efm_N		rs.l		1		pointer to bobs up image
efm_NMask	rs.l		1
efm_NE		rs.l		1		up-left image
efm_NEMask	rs.l		1
efm_E		rs.l		1		left image
efm_EMask	rs.l		1
efm_SE		rs.l		1		down-left image
efm_SEMask	rs.l		1
efm_S		rs.l		1		down image
efm_SMask	rs.l		1
efm_SW		rs.l		1		down-right image
efm_SWMask	rs.l		1
efm_W		rs.l		1		right image
efm_WMask	rs.l		1
efm_NW		rs.l		1		up-right image
efm_NWMask	rs.l		1
efm_SIZEOF	rs.b		0		size of structure

; ' Repeater ' bob structure .... An enemy that follows a predefined path

; Path is contained in epp_Table, a maximum of 20 long words. Each long word
;contains 4 bytes of move data:

; dx,dy,count,imageoffset

; dx		= X increment per vblank
; dy		= Y increment per vblank
; count		= number of VBlanks to use these values
; imageoffset	= 0,8,16,32,40,48,56,64 (N,NE,E,SE,S,SW,W,NW) gfx to use

		rsreset
epp_Bob		rs.b		bob_SIZEOF	bob structure
epp_Dx		rs.l		1		x increment
epp_Dy		rs.l		1		y increment
epp_Counter	rs.w		1		move counter
epp_Pointer	rs.l		1		position in move table
epp_N		rs.l		1		pointer to bobs up image
epp_NMask	rs.l		1
epp_NE		rs.l		1		up-left image
epp_NEMask	rs.l		1
epp_E		rs.l		1		left image
epp_EMask	rs.l		1
epp_SE		rs.l		1		down-left image
epp_SEMask	rs.l		1
epp_S		rs.l		1		down image
epp_SMask	rs.l		1
epp_SW		rs.l		1		down-right image
epp_SWMask	rs.l		1
epp_W		rs.l		1		right image
epp_WMask	rs.l		1
epp_NW		rs.l		1		up-right image
epp_NWMask	rs.l		1
epp_Table	rs.l		1		pointer to move table

epp_SIZEOF	rs.b		0		size of structure

; PowerUps. A number of bobs are covered by this structure. They each have
;a unique ID though.

		rsreset
pu_Bob		rs.b		bob_SIZEOF	bob structure
pu_Data		rs.w		1		special data
pu_SIZEOF	rs.b		0

; Structure for an explosion

		rsreset
exp_Bob		rs.b		bob_SIZEOF	bob structure
exp_Action	rs.w		1		0=>none, else powerup number
exp_Frame	rs.w		1		frame number
exp_Counter	rs.w		1		delay between frames
exp_N		rs.l		1		pointer to bobs up image
exp_NMask	rs.l		1
exp_NE		rs.l		1		up-left image
exp_NEMask	rs.l		1
exp_E		rs.l		1		left image
exp_EMask	rs.l		1
exp_SE		rs.l		1		down-left image
exp_SEMask	rs.l		1
exp_S		rs.l		1		down image
exp_SMask	rs.l		1
exp_SW		rs.l		1		down-right image
exp_SWMask	rs.l		1
exp_W		rs.l		1		right image
exp_WMask	rs.l		1
exp_NW		rs.l		1		up-right image
exp_NWMask	rs.l		1
exp_SIZEOF	rs.b		0		structure size

; Structure for a levels exit bob.

		rsreset
ex_Bob		rs.b		bob_SIZEOF	bob structure
ex_SIZEOF	rs.b		0		that's it!

*****************************************************************************

; Now equates used throught the code

ScrnDepth	=	4		depth of screen
ScrnWidth	=	80		40 bytes wide ( = 320 pixels )
ScrnHeight	=	512		256 lines high

; Set up screen modulo for interleaved playfield, allowing for horizontal
;scrolling

ScrnMod		=	ScrnWidth-42+ScrnWidth*(ScrnDepth-1)

; The following are just guesses at present! This code could load in bob
;and screen map files, the buffer sizes are fixed here

StructMemSize	=	10000		c10K for bob structures

DBuffMemSize	=	20000		c20K for bob screen save areas

BobDataMemSize	=	20000		c20K for bobs raw data

BobXStep	=	2		x increment each frame
BobYStep	=	2		y increment each frame

BulletLife	=	50		1/50 secs to display bullets

BulletRepeat	=	7		1/50 secs between bullets

; Macro to turn drive motors off

STOPDRIVES	macro
		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB
		endm

; Following opts for Devpac3 only. 

;		opt o1+,o2+,o4+,o5+,o6+,o10+,o11+,ow-


		include		FollowMe:Include/hardware.i

Start		lea		GameVars,a4	a4->game variables memory

		move.l		#1,LevelNum(a4)		start level
		move.l		#4,Lives(a4)		4 lives
		move.l		#ScrollText,NextChar(a4) addr of text
		move.w		#$0100,ScrollCount(a4)	 byte counter
		move.w		#1,FireRepeat(a4)	 not implemented
		

		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error		if so quit now !

		move.l		a4,a6		a6->game vars
		bsr		Main		do da

		move.l		a6,a4
		bsr		SysOn		enable system
		moveq.l		#0,d0		no DOS errors
.error		rts

*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5		a5->hardware

		move.w		DMACONR(a5),sysDMA(a4)	save DMA settings
		move.w		INTENAR(a5),sysINT(a4)	save interrupts
		move.l		$6c.w,Level3(a4)	save level 3 vector

; Open graphics library and stores address of systems Copper list for later.
;Library is then closed.

		lea		grafname,a1		a1->lib name
		moveq.l		#0,d0			any version
		move.l		$4.w,a6			a6->SysBase
		jsr		-$0228(a6)		OpenLibrary
		tst.l		d0			open ok?
		beq		.error			quit if not
		move.l		d0,a0			a6->GfxBase
		move.l		38(a0),syscop(a4)	save addr of sys list
		move.l		d0,a1			a1->Graphics base
		jsr		-$019e(a6)		CloseLibrary

; Opens DOS library to obtain address, then closes it again. We don't need
;it open as OS is about to be killed!

		lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		jsr		-$0228(a6)	OpenLibrary
		move.l		d0,_DOSBase	open ok?
		beq		.error		quit if not
		move.l		d0,a1		a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		move.l		$4.w,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01ef,DMACON(a5) kill all dma
		move.w		#SETIT!DMAEN!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Set up new Level 3 interrupt

		move.w		#$3fff,INTENA(a5)	stop interrupts
		move.l		#NewLevel3,$6c.w	address of server

; Init 1st Copper List for Game proper.

		lea		CopPlanes1,a0	where to fill in plane ptrs
		lea		Screen1,a1	raw data
		lea		CopColours1,a2	where to build colours
		bsr		PutPlanes

; Init 2nd Copper List for Game proper.

		lea		CopPlanes2,a0	where to fill in plane ptrs
		lea		Screen2,a1	raw data
		lea		CopColours2,a2	where to build colours
		bsr		PutPlanes

; Write bottom bitplane addresses into both Copper Lists.

		move.l		#(336/8)*64,d1	plane size
		moveq.l		#3,d2		num planes-1

		move.l		#BitPlane,d0
		lea		BotPlane1,a0
		lea		BotPlane2,a1

.BplLoop	swap		d0
		move.w		d0,(a0)
		move.w		d0,(a1)

		swap		d0
		move.w		d0,4(a0)
		move.w		d0,4(a1)
		add.l		d1,d0
		adda.l		#8,a0
		adda.l		#8,a1
		dbra		d2,.BplLoop

; Init the Introduction Copper List.

		move.l		#Screen1+6000,d0
		lea		IntroPlanes,a0

		swap		d0
		move.w		d0,(a0)
		swap		d0
		move.w		d0,4(a0)

; Stop drives 

		STOPDRIVES			use macro

		moveq.l		#1,d0
.error		rts

*****************************************************************************

;--------------	Bring back the operating system

SysOn		move.l		syscop(a4),COP1LCH(a5)
		move.w		#0,COPJMP1(a5)	restart system list

		move.w		#SETIT!DMAEN,d0	set bit 15 of d0
		or.w		sysDMA(a4),d0	add DMA flags
		move.w		d0,DMACON(a5)	enable systems DMA

		move.w		#VERTB,INTENA(a5)	stop interrupt
		move.l		Level3(a4),$6c.w	reset system
		move.w		sysINT(a4),d0		get system bits
		or.w		#SETIT!INTEN,d0
		move.w		d0,INTENA(a5)	set old 

		move.l		$4.w,a6		a6->SysBase
		jsr		-$008A(a6)	Permit

		rts

*****************************************************************************

; This subroutine sets up planes for a 320x256x4 display and sets up the
;colour. Assumes raw data saved as CMAP BEHIND.

;Entry		a0->start of Copper List
;		a1->start of bitplane data
;		a2->position in list to store colour data.

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#ScrnDepth-1,d0	num of planes -1
		moveq.l		#ScrnWidth,d1	size of each bitplane
		move.l		a1,d2		d2=addr of 1st bitplane
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
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
;Main program control loop

Main		move.l		#introtext,d7		text file name
		bsr		Intro			game introduction

		bsr		ResetVars		reset vars/pointers

NextLevel	bsr		LoadNextLevel

		bsr		PlayLevel		do it!

.loop		btst		#2,$dff016		RMB?
		beq.s		.GameOver		nope, so loop!

; Check for level cleared 

		tst.w		LevelClear(a6)
		beq.s		.SeePlayer

; Need a display screen here to pause between levels

		bsr		BumpLevel
		bra.s		NextLevel

; See if player has been killed off

.SeePlayer	tst.w		PlayerDead(a6)
		bne.s		.loop

; Player has been killed, check lives counter and act accordingly

		tst.l		Lives(a6)		killed off?
		beq.s		.CheckHigh		yep, restart!
		bsr		Restart			nope, loose a life!
		bra.s		.loop		

; No more lives left, do the high score bit!

.CheckHigh	bsr		DoHighScore		check it out!
		bra.s		Main

.GameOver	rts

*****************************************************************************

; After player has been killed, freezes everything and waits for LMB. When
;pressed, restarts the level.

Restart		move.w		#VERTB,INTENA(a5)	stop interrupt

		subq.l		#1,Lives(a6)		loose a life
		move.w		#5,Cloak(a6)		invincible
		move.w		#1,PlayerDead(a6)	restart!
		move.l		Player(a6),a0
		move.l		#1,bob_Active(a0)
		move.l		#3,bob_Dying(a0)

		move.w		#SETIT!INTEN!VERTB,INTENA(a5)
		rts

*****************************************************************************

ResetVars	move.l		#0,pf_X(a6)
		move.l		#0,pf_Y(a6)

; Reset flags and counters

		move.w		#1,PlayerDead(a6)
		move.w		#0,Cloak(a6)
		move.l		#0,Score(a6)
		move.l		#4,Lives(a6)

; Reset level filenames

		moveq.l		#'0',d0
		move.b		d0,MapFInc
		move.b		d0,MapFInc+1
		move.b		d0,BobFInc
		move.b		d0,BobFInc+1
		move.b		d0,ImagesFInc
		move.b		d0,ImagesFInc+1
		move.b		d0,LevelTextInc
		move.b		d0,LevelTextInc+1

; Kill sounds
		move.w		#0,AUD0VOL(a5)
		move.w		#0,AUD1VOL(a5)
		move.w		#0,AUD2VOL(a5)
		move.w		#0,AUD3VOL(a5)
		move.w		#AUD3EN!AUD2EN!AUD1EN!AUD0EN,DMACON(a5)
		rts

*****************************************************************************

; Bumps on all file names ready for next level. Max 0->99!

BumpLevel	Lea		MapFInc,a0
		move.b		(a0)+,d0
		move.b		(a0)+,d1
		addq.b		#1,d1
		cmp.b		#'9'+1,d1
		bne.s		.Done
		moveq.l		#'0',d1			reset
		addq.b		#1,d0			bump 10's

.Done		move.b		d1,-(a0)
		move.b		d0,-(a0)
		move.b		d0,BobFInc
		move.b		d1,BobFInc+1
		move.b		d0,ImagesFInc
		move.b		d1,ImagesFInc+1
		move.b		d0,LevelTextInc
		move.b		d1,LevelTextInc+1
		rts

*****************************************************************************

; Load and initialise data for this level

; Enable system DMA, minus the sprites!

LoadNextLevel	move.w		#SETIT!DMAEN,d0	set bit 15 of d0
		or.w		sysDMA(a6),d0	add DMA flags
		and.b		#$df,d0		mask out sprites
		move.w		d0,DMACON(a5)	enable systems DMA

; Enable system interrupts

		move.w		#VERTB,INTENA(a5)	stop interrupt
		move.l		Level3(a6),$6c.w	reset system
		move.w		sysINT(a6),d0	get system bits
		or.w		#SETIT!INTEN,d0
		move.w		d0,INTENA(a5)	set old 

; Load a new map file

		move.l		#MapFName,d1	filename
		move.l		#Level,d5	buffer
		move.l		#1300,d6	size
		bsr		DOSLoad		load map

; Load a new image file

		move.l		#ImagesFName,d1	filename
		move.l		#Images,d5	buffer
		move.l		#10000,d6	size ( max 10000K )
		bsr		DOSLoad		load images

; Load a new bob file

		move.l		#BobFName,d1	filename
		move.l		#BobData,d5	buffer
		move.l		#3000,d6	size
		bsr		DOSLoad		load bob data

		move.w		#0,LevelClear(a6) clear flag

		rts

*****************************************************************************

; Initialisation routine that resets everything ready for a new game!

; Note that DMA and interrupts should be OFF on entry

PlayLevel	lea		Level,a0
		bsr		BuildScreen

		bsr		InitImages
		bsr		InitBobs		complete structure
		move.w		#1,PlayerDead(a6)	were alive!
		move.w		#0,Cloak(a6)		no cloaking device
		move.w		#0,LevelClear(a6)	clear level flag
		move.w		#0,GotData(a6)		clear data flag
		move.w		#0,CountDown(a6)	clear counter
		move.w		#0,BounceOn(a6)		no bounce
		move.w		#50,BulletCount(a6)	full arsenal
		move.w		#10,BulletRate(a6)	default delay
		move.w		#1,BulletPower(a6)	default hit points

; Set up Game interrupt

		move.w		#$3fff,INTENA(a5)	stop interrupts
		move.l		#NewLevel3,$6c.w	address of server

; Set up Game DMA

		move.w		#$01ef,DMACON(a5) 	kill all dma
		move.w		#SETIT!DMAEN!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Strobe Games Copper List

		move.l		#CopList1,COP1LCH(a5)
		move.w		#0,COPJMP1(a5)

; Start the interrupt

		move.w		#SETIT!INTEN!VERTB,INTENA(a5)

		rts

*****************************************************************************

NewLevel3	lea		$dff000,a5
		lea		GameVars,a6

		bsr		IntCode

		move.w		#VERTB,INTREQ(a5)	clear request
		rte

*****************************************************************************

; Level 3, vertical blank interrupt routine -- handles dbuffering & bobs

IntCode		movem.l		a0-a6/d0-d7,-(a7)	Save all registers

; Act on state of toggle 'Switch', 0=>Screen1 is visible & -1=>Screen2

		tst.w		Switch(a6)		which screen active
		bne.s		.DoScreen1		skip if Screen2

; Activate Screen2 

		move.l		#CopList2,COP1LCH(a5)	display Screen2
		move.w		#0,COPJMP1(a5)

; Scroll playfield

		lea		CopPlanes2,a0
		lea		Screen2,a1
		bsr		SetScroll

; Update bobs coordinates

		bsr		CalcXY			move it
		bsr		MoveHomers
		bsr		MoveRepeaters
		bsr		MoveBullets
		bsr		TestFire

		bsr		CheckBobs
		bsr		KillEnemy
		bsr		KillMe
		bsr		DoExplosions
				
; Now blit bobs into Screen1 and exit

		moveq.l		#1,d0			Screen1
		bsr		BlitBobs		blit bobs

		bra.s		.Done

; Activate Screen1

.DoScreen1	move.l		#CopList1,COP1LCH(a5)
		move.w		#0,COPJMP1(a5)

; Scroll playfield

		lea		CopPlanes1,a0
		lea		Screen1,a1
		bsr.s		SetScroll

; Update bobs coordinates

		bsr		CalcXY			move it
		bsr		MoveHomers
		bsr		MoveRepeaters
		bsr		MoveBullets
		bsr		TestFire

		bsr		CheckBobs

		bsr		KillEnemy
		bsr		KillMe
		bsr		DoExplosions

; Blit bobs into Screen2

		moveq.l		#2,d0			Screen2
		bsr		BlitBobs		blit bobs

; Toggle flag 

.Done		not.w		Switch(a6)		signal interrup

; Call sample player

		bsr		PlaySFX

; Adjust bullet time-out counter

		tst.w		FireRepeat(a6)		holding back bullets
		beq.s		.readytofire		skip if not

		subq.w		#1,FireRepeat(a6)	else dec counter

.readytofire	
		bsr		ScrlTxtLine		scroll text in bot
		bsr		PrintScore		print details

		tst.l		Bonus(a6)
		beq.s		.NoBonus
		subq.l		#1,Bonus(a6)
		
.NoBonus	tst.w		BounceOn(a6)
		beq.s		.NoBounce
		subq.w		#1,BounceOn(a6)		dec counter

.NoBounce		

		IFNE		RasterTiming

		move.w		#$fff,$dff180		for raster timing!

		ENDC

		movem.l		(a7)+,a0-a6/d0-d7	Bring back registers
		moveq.l		#1,d0			clear Z flag
		rts					exit

*****************************************************************************

; a0->position in Copper List to write bitplane pointers
; a1->start of playfield

SetScroll	move.l		pf_X(a6),d0		x offset in pixels
		and.w		#$f,d0			pixel offset
		moveq.l		#15,d1
		sub.b		d0,d1			as required
		move.l		d1,d0
		asl.b		#4,d0			into high nibble
		or.b		d1,d0			and low nibble
		move.w		d0,-4(a0)		set BPLCON1

		move.l		pf_X(a6),d0		X
		asr.w		#4,d0			x/16
		move.l		pf_Y(a6),d1		Y
		mulu		#ScrnWidth*ScrnDepth,d1	line offset
		add.w		d0,d1
		add.w		d0,d1
		adda.l		d1,a1			a1->address if pf

		moveq.l		#ScrnWidth,d1	size of each bitplane
		move.l		a1,d2		d2=addr of 1st bitplane

		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane
		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane
		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane
		swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		addq.l		#4,a0		point to next pos in list
		add.l		d1,d2		point to next plane

		rts

*****************************************************************************

; Disables bobs that are not visible from being blitted. Background saves and
;movement still operate however. Just clears or sets the bob_Draw flag.

CheckBobs	move.l		Player(a6),d0		1st bob

.CheckLoop	move.l		d0,a3			a3->bob
		moveq.l		#0,d3			default not visible
		tst.w		bob_Active+2(a3)	bob enabled?
		beq.s		.Next			skip it if not

		move.l		bob_X(a3),d6		X
		move.l		bob_Y(a3),d7		Y
		sub.w		pf_X+2(a6),d6		calc screen X
		bmi.s		.Next			exit if off left

		cmp.w		#320,d6			off right
		bge.s		.Next			exit if so

		sub.w		pf_Y+2(a6),d7		calc screen Y
		bmi.s		.Next			exit if off top

		cmp.w		#195,d7			off bottom?
		bge.s		.Next			exit if so

		moveq.l		#1,d3			bob is visible

.Next		move.w		d3,bob_Draw+2(a3)	activate it
		move.l		(a3),d0			next bob
		bne.s		.CheckLoop		loop

		rts

*****************************************************************************

; Check if a bullet has collided with an enemy. If it has, blow the enemy up
;and start a sound fx in motion.

KillEnemy	move.l		Player(a6),a2		player
		lea		pl_Bullet0(a2),a2	1st bullet
		moveq.l		#9,d7			bullet count

; See if bullet has hit an enemy

.Check		move.l		(a2),a0			bullet pointer
		tst.w		bob_Active+2(a0)	fired?
		beq		.Next			nope, so skip!
		move.l		Enemy(a6),a1		enemy list
		bsr		Bob2Bob			check 'em
		tst.l		d0			hit one?
		beq.s		.Next			no, so skip!

; It has, so kill the bullet

		move.l		(a2),a0			bullet
		move.w		#0,bob_Active+2(a0)	switch off


; Now dec the enemys life counter, kill it if count = 0

		move.l		d0,a1			enemy we hit
		subq.l		#1,bob_Dying(a1)	dec counter
		bne.s		.Next
		move.w		#0,bob_Active+2(a1)	kill it if 0

; bump score as enemy was killed

		move.l		Score(a6),d0
		add.l		bob_Points(a1),d0
		move.l		d0,Score(a6)

; start a sound fx

		lea		Sample2,a0		sample
		move.l		a1,-(sp)		save bob ptr
		bsr		NewSFX1			set it up!
		move.l		(sp)+,a1		restore bob ptr

; now initialise an explosion - visuals extrodinaire!

		move.l		Explosion(a6),d0	first explode bob

.exploop	move.l		d0,a0			a1->explode bob
		tst.w		bob_Active+2(a0)	bob active?
		bne.s		.NextExp		yep, skip it!

; found a free explosion, initialise and activate it!

		move.l		bob_X(a1),bob_X(a0)	set X
		move.l		bob_Y(a1),bob_Y(a0)	AND Y
		move.w		#0,exp_Frame(a0)	set frame number
		move.w		#1,exp_Counter(a0)	and frame counter
		lea		exp_N(a0),a1		1st image
		move.l		(a1)+,bob_Data(a0)	set 1st image
		move.l		(a1),bob_DMask(a0)	and 1st mask
		move.w		#1,bob_Active+2(a0)	activate it
		bra.s		.Next

.NextExp	move.l		(a0),d0			next explosion
		bne.s		.exploop

.Next		addq.l		#4,a2			next bullet
		dbra		d7,.Check		

		rts

*****************************************************************************

KillMe		tst.w		Cloak(a6)
		beq.s		.Go
		subq.w		#1,Cloak(a6)
		bra.s		.Done

.Go		move.l		Player(a6),a2		player

; See if I have hit something.

		move.l		a2,a0
		move.l		Enemy(a6),a1		enemy list
		bsr		Bob2Bob			check 'em
		tst.l		d0			hit one?
		beq.s		.Done			no, so skip!

; I have, so figure out what and act on it. I've attempted to order these
;checks so the most frequent collisions get handled first

		move.l		d0,a1			a1->bob I hit
		move.l		bob_ID(a1),d1		get bobs ID
		move.w		d1,d0
		and.w		#1<<7!1<<8,d0
		beq.s		.TryPUp			nope, skip it!

		subq.w		#1,bob_Dying+2(a2)	dec counter
		bne.s		.Done
		move.w		#0,bob_Active+2(a2)	kill it if 0

		lea		Sample2,a0		sample
		bsr		NewSFX1			set it up!
		move.w		#0,PlayerDead(a6)	signal death!

.Done		rts

; Sound effects need to be added to all the following routines

;---- See if we hit a power up.

.TryPUp		btst		#3,d1			power up
		beq.s		.TrySUp			nope, skip it

; Was a power-up, set bullet to full power ( damage = 2 )

		move.w		#2,BulletPower(a6)	set max power
		move.w		#0,bob_Active+2(a1)	kill power-up
		rts					and exit

;---- See if we hit a speed-up

.TrySUp		btst		#4,d1			speed up?
		beq.s		.TryReload		nope, skip

; Was a speed-up, reduce fire repeat delay

		subq.w		#2,BulletRate(a6)	dec repeat delay
		move.w		#0,bob_Active+2(a1)	kill speed-up
		rts					and exit

;---- See if we hit a reload

.TryReload	btst		#5,d1			reload?
		beq.s		.TryBounce		nope, skip it

; Was a reload. Add number of bullets contained in pu_Data field

		move.w		BulletCount(a6),d0	get current value
		add.w		pu_Data(a1),d0		add 'em
		move.w		d0,BulletCount(a6)	and save value
		move.w		#0,bob_Active+2(a1)	kill reloader
		rts					and exit

;---- See if we hit a 'bounce'

.TryBounce	btst		#6,d1			bounce?
		beq.s		.TryCloak		nope, skip

; We hit a bounce, toggle flag

		move.w		pu_Data(a1),BounceOn(a6) set timer
		move.w		#0,bob_Active+2(a1)	kill bounce
		rts					and exit

;---- See if we hit a cloaking device

.TryCloak	btst		#9,d1			cloak?
		beq.s		.TryData		nope, skip it!

; We hit a cloaking device, set counter accordingly

		move.w		pu_Data(a1),Cloak(a6)	activate cloak
		move.w		#0,bob_Active+2(a1)	kill speed-up
		rts					and exit

;---- See if we hit levels data module

.TryData	btst		#10,d1			data module?
		beq.s		.TryBomb		nope, skip!

; We hit the data module, wipe it out and bump score

		add.l		#500,Score(a6)		bump score for this
		move.w		#1,GotData(a6)		set flag
		move.w		#0,bob_Active+2(a1)	kill speed-up
		rts					and exit

;---- See if we have hit a level detonator

.TryBomb	btst		#12,d1
		beq.s		.TryExit

; We have hit a detonator, start countdown ( 30 secs = 30*50 = 1500 vbl's)

		move.w		#1500,CountDown(a6)	activate timer
		move.w		#0,bob_Active+2(a1)	kill speed-up
		rts					and exit

;---- See if we have reached the exit

.TryExit	btst		#13,d1			exit?
		beq.s		.GodKnows		nope, skip

; At the exit, see if data module retrieved

		tst.w		GotData(a6)		got the module?		
		beq.s		.GodKnows		nope, skip!

; Got the data, flag level complete

		move.w		#1,LevelClear(a6)	flag level complete
		move.l		Score(a6),d0		get remaining bonus
		add.l		Bonus(a6),d0
		move.w		d0,Score(a6)		add it to score
		move.w		#0,bob_Active+2(a1)	kill speed-up
		move.w		#0,bob_Active+2(a2)	kill player for fun
.GodKnows	rts					and exit

*****************************************************************************

; Updates players bobs X and Y position according to condition of joystick.
;Also calls a routine that checks the validity of the move. Should be called
;during VBlank interrupt.

CalcXY		bsr		TestJoy

		tst.w		d2			any movement?
		beq		.NoGo

		move.l		Player(a6),a0		bob structure

		move.l		d2,pl_Dir(a0)		save direction

		move.l		X(a6),d6		on-screen X coord
		move.l		Y(a6),d7		on-screen Y coord

		moveq.l		#BobXStep,d4
		moveq.l		#BobYStep,d5

		btst		#0,d2			right?
		beq.s		.checkleft
		cmp.w		#304-BobXStep,d6
		bge.s		.checkdown
		add.w		d4,d6

.checkleft	btst		#1,d2			left?
		beq.s		.checkdown
		cmp.w		d4,d6
		blt.s		.checkdown
		sub.w		d4,d6

.checkdown	btst		#2,d2			down?
		beq.s		.checkup
		cmp.w		#237-BobYStep,d7
		bge.s		.done
		add.w		d5,d7

.checkup	btst		#3,d2			Up?
		beq.s		.done
		cmp.w		d5,d7
		blt.s		.done
		sub.w		d5,d7

; Now check move is valid

.done		move.l		d6,d0			X
		move.l		d7,d1			Y
		add.w		pf_Y+2(a6),d1
		add.w		pf_X+2(a6),d0
		bsr		CheckPlyr		check move
		tst.l		d0			background collision?
		bne.s		.doupdate		skip if not

; Collision has occurred. See if keeping old X will help!

		move.l		X(a6),d0		X
		move.l		d7,d1			Y
		add.w		pf_Y+2(a6),d1
		add.w		pf_X+2(a6),d0
		bsr		CheckPlyr		check adjusted move
		tst.l		d0			collision still?
		beq.s		.tryY			skip if there was!
		move.w		X+2(a6),d6		set new X value
		bra.s		.doupdate

; Changing X had no effect, try changing Y

.tryY		move.l		d6,d0			X
		move.l		Y(a6),d1		Y
		add.w		pf_Y+2(a6),d1
		add.w		pf_X+2(a6),d0
		bsr		CheckPlyr
		tst.l		d0
		beq		.doimage
		move.w		Y+2(a6),d7		set new Y value

; determined where we are moving to. See if playfield needs scrolling, if it
;does correct (X,Y) accordingly.

.doupdate	cmp.w		#100,d7			scroll up?
		ble.s		.tryDown		no, see if down!

		btst		#2,d2			moving down?
		beq.s		.tryDown		no, skip

		cmp.w		#317,pf_Y+2(a6)		at the bottom?
		bge.s		.tryLeft		yes, then skip

		sub.w		d5,d7			correct on-screen Y
		add.w		d5,pf_Y+2(a6)		update scroll
		bra.s		.tryLeft		and skip

.tryDown	cmp.w		#80,d7			scroll down?
		bge.s		.tryLeft		skip if not

		btst		#3,d2			moving up?
		beq.s		.tryLeft		skip if not

		tst.w		pf_Y+2(a6)		at the top?
		beq.s		.tryLeft		yes, then skip

		add.w		d5,d7			correct on-screen Y
		sub.w		d5,pf_Y+2(a6)		update scroll

.tryLeft	cmp.w		#220,d6			scroll left?
		ble.s		.tryRight		no, see if right!

		btst		#0,d2			moving right?
		beq.s		.tryRight		no, skip

		cmp.w		#318,pf_X+2(a6)		at the bottom?
		bge.s		.setit			yes, then skip

		sub.w		d4,d6			correct on-screen Y
		add.w		d4,pf_X+2(a6)		update scroll
		bra.s		.setit			and skip

.tryRight	cmp.w		#100,d6			scroll right?
		bge.s		.setit			skip if not

		btst		#1,d2			moving left?
		beq.s		.setit			skip if not

		tst.w		pf_X+2(a6)		at the top?
		beq.s		.setit			yes, then skip

		add.w		d4,d6			correct on-screen Y
		sub.l		d4,pf_X(a6)		update scroll

.setit		move.l		d6,X(a6)		update position
		move.l		d7,Y(a6)		

		add.w		pf_Y+2(a6),d7
		add.w		pf_X+2(a6),d6

		move.w		d6,bob_X+2(a0)
		move.w		d7,bob_Y+2(a0)

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
		bra.s		.NoGo

.I2		cmp.b		#%00000001,d2			East
		bne.s		.I3
		move.l		pl_E(a0),bob_Data(a0)
		move.l		pl_EMask(a0),bob_DMask(a0)
		bra.s		.NoGo

.I3		cmp.b		#%00000101,d2			South-East
		bne.s		.I4
		move.l		pl_SE(a0),bob_Data(a0)
		move.l		pl_SEMask(a0),bob_DMask(a0)
		bra.s		.NoGo

.I4		cmp.b		#%00000100,d2			South
		bne.s		.I5
		move.l		pl_S(a0),bob_Data(a0)
		move.l		pl_SMask(a0),bob_DMask(a0)
		bra.s		.NoGo

.I5		cmp.b		#%00000110,d2			South-West
		bne.s		.I6
		move.l		pl_SW(a0),bob_Data(a0)
		move.l		pl_SWMask(a0),bob_DMask(a0)
		bra.s		.NoGo

.I6		cmp.b		#%00000010,d2			West
		bne.s		.I7
		move.l		pl_W(a0),bob_Data(a0)
		move.l		pl_WMask(a0),bob_DMask(a0)
		bra.s		.NoGo

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


*****************************************************************************

; Subroutine that checks if the player has pressed fire. If so checks if
;there is a free bullet. If so sets bullet bob in motion!

TestFire	tst.w		FireRepeat(a6)		can we fire yet?
		bne		.nonefree		exit if not

		tst.b		CIAAPRA			joystick fire button
		bmi		.nonefree		skip if not

; fire button pressed, see if there is a bullet free for use.

		move.l		Player(a6),a1		a1->bob struct	
		move.l		pl_Dir(a1),d2		last direction

		move.l		pl_Bullet0(a1),a0	a0->bullet strct ptrs
		moveq.l		#9,d0			num bullets - 1

.Loop		tst.l		bob_Active(a0)		bullet in use?
		beq.s		.FoundOne		exit loop if not

		move.l		(a0),a0			next bullet
		dbra		d0,.Loop		and loop
		bra.s		.nonefree		exit if none free

; found a free bullet, give it the same X,Y as players bob

.FoundOne	move.w		#BulletRepeat,FireRepeat(a6)  set time-out

		move.w		#1,bob_Active+2(a0)	fire it
		move.l		bob_X(a1),bob_X(a0)	set X
		addq.l		#6,bob_X(a0)
		move.l		bob_Y(a1),bob_Y(a0)	set Y
		addq.l		#6,bob_Y(a0)

; Set speed to double that of ship

		moveq.l		#0,d0
		move.l		d0,d1

		btst		#3,d2			going up?
		beq.s		.trydown
		moveq.l		#-BobYStep*2,d1		dy

.trydown	btst		#2,d2			going down?
		beq.s		.tryleft
		moveq.l		#BobYStep*2,d1		dy

.tryleft	btst		#1,d2			going left?
		beq.s		.tryright
		moveq.l		#-BobXStep*2,d0		dx

.tryright	btst		#0,d2			going right?
		beq.s		.notright
		moveq.l		#BobXStep*2,d0		dx

.notright	move.l		d0,pb_Dx(a0)		set Dx
		move.l		d1,pb_Dy(a0)		set Dy

		move.l		pb_Term(a0),pb_TermCount(a0) set life		

		lea		Sample1,a0		sample
		bsr		NewSFX0			set it up!

.nonefree	rts

*****************************************************************************

; Routine to move all bullets. Bullets bounce off of background features!

MoveBullets	move.l		Player(a6),a1		players bob structure
		lea		pl_Bullet0(a1),a1	1st bullet pointer
		moveq.l		#9,d4			num bullets - 1

.loop		move.l		(a1)+,a0		a0->next bullet strct
		tst.w		bob_Active+2(a0)	in use?
		beq.s		.notfired		skip if not

		subq.w		#1,pb_TermCount+2(a0)	dec life
		bne.s		.stillgoing		skip if still alive
		move.w		#0,bob_Active+2(a0)	else disable
		bra.s		.notfired		and skip

.stillgoing	move.l		bob_X(a0),d6		X
		move.l		bob_Y(a0),d7		Y
		add.l		pb_Dx(a0),d6		X = X + dx
		add.l		pb_Dy(a0),d7		Y = Y + dy

; Now check move is valid

		move.l		d6,d0			X
		move.l		d7,d1			Y
		bsr		CheckPlyr		check move
		tst.l		d0			background collision?
		bne.s		.domove			skip if not

; Hit the background, check for bounce or delete

		tst.w		BounceOn(a6)		bullets bouncing
		bne.s		.DoBounce		yep, do it!
		move.w		#0,bob_Active+2(a0)	disable bullet
		bra.s		.domove			and skip		

; Bounce: See if keeping old X will help!

.DoBounce	move.l		bob_X(a0),d0		X
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

.domove		move.w		d6,bob_X+2(a0)		update position
		move.w		d7,bob_Y+2(a0)		


.notfired	dbra		d4,.loop		for all 10 bullets
		rts

*****************************************************************************

MoveHomers	move.l		Player(a6),a1		player bob struct
		move.l		bob_X(a1),d6		Player X
		move.l		bob_Y(a1),d7		Player Y
		move.l		Enemy(a6),d0		1st enemy structure

.MoveLoop	move.l		d0,a0			a0->Enemy
		move.w		bob_ID+2(a0),d0		get ID
		and.w		#1<<7,d0		is it a homer?
		beq		.Next			skip if not
		move.l		bob_X(a0),d4		Enemy X
		move.l		bob_Y(a0),d5		Eneny Y
		moveq.l		#-1,d3	-BobXStep,d3		dx
		move.l		d4,d0
		sub.l		d6,d0			seperation
		beq.s		.DoY
		bpl.s		.CheckX
		neg.l		d0			ABS(seperation)
		neg.l		d3			reverse direction
.CheckX		cmp.w		#300,d0			in range?
		bgt.s		.DoY			skip if not
		add.l		d3,d4			bump Enemy X
		move.l		d4,d0			X
		move.l		d5,d1			Y
		bsr		CheckPlyr		hit background?
		tst.w		d0
		bne.s		.DoY			no, so skip
		move.w		bob_X+2(a0),d4		else reset X

.DoY		moveq.l		#-1,d3	-BobYStep,d3		dy
		move.l		d5,d0
		sub.l		d7,d0			seperation
		beq.s		.MoveDone
		bpl.s		.CheckY
		neg.l		d0			ABS(seperation)
		neg.l		d3			reverse direction
.CheckY		cmp.w		#256,d0			in range?
		bgt.s		.MoveDone		skip if not
		add.l		d3,d5			bump Enemy Y
		move.l		d4,d0			X
		move.l		d5,d1			Y
		bsr		CheckPlyr		hit background?
		tst.w		d0
		bne.s		.MoveDone		no, so skip
		move.w		bob_Y+2(a0),d5		else reset X

.MoveDone	move.w		d4,bob_X+2(a0)		set X
		move.w		d5,bob_Y+2(a0)		set Y

		moveq.l		#0,d2			clear
		cmp.l		d6,d4
		beq.s		.CheckUD
		bgt.s		.isR
		or.b		#$01,d2
		bra.s		.CheckUD
.isR		or.b		#$02,d2

.CheckUD	cmp.l		d7,d5
		beq.s		.SetDir
		bgt.s		.isD
		or.b		#$04,d2
		bra.s		.SetDir
.isD		or.b		#$08,d2

.SetDir		tst.w		d2
		beq		.Next

		cmp.b		#%00001000,d2			North
		bne.s		.I1
		move.l		efm_N(a0),bob_Data(a0)
		move.l		efm_NMask(a0),bob_DMask(a0)
		bra		.Next

.I1		cmp.b		#%00001001,d2			North-East
		bne.s		.I2
		move.l		efm_NE(a0),bob_Data(a0)
		move.l		efm_NEMask(a0),bob_DMask(a0)
		bra.s		.Next

.I2		cmp.b		#%00000001,d2			East
		bne.s		.I3
		move.l		efm_E(a0),bob_Data(a0)
		move.l		efm_EMask(a0),bob_DMask(a0)
		bra.s		.Next

.I3		cmp.b		#%00000101,d2			South-East
		bne.s		.I4
		move.l		efm_SE(a0),bob_Data(a0)
		move.l		efm_SEMask(a0),bob_DMask(a0)
		bra.s		.Next

.I4		cmp.b		#%00000100,d2			South
		bne.s		.I5
		move.l		efm_S(a0),bob_Data(a0)
		move.l		efm_SMask(a0),bob_DMask(a0)
		bra.s		.Next

.I5		cmp.b		#%00000110,d2			South-West
		bne.s		.I6
		move.l		efm_SW(a0),bob_Data(a0)
		move.l		efm_SWMask(a0),bob_DMask(a0)
		bra.s		.Next

.I6		cmp.b		#%00000010,d2			West
		bne.s		.I7
		move.l		efm_W(a0),bob_Data(a0)
		move.l		efm_WMask(a0),bob_DMask(a0)
		bra.s		.Next

.I7		cmp.b		#%00001010,d2			North-West
		bne.s		.Next
		move.l		efm_NW(a0),bob_Data(a0)
		move.l		efm_NWMask(a0),bob_DMask(a0)

.Next		move.l		(a0)+,d0		next bob
		bne		.MoveLoop		loop while not NULL
		rts

*****************************************************************************

; Repeaters follow a predefined path containing upto 19 direction changes.
;The path MUST be cyclic so the bob always follows same path else the bob
;will simply run amok through memory! No background collisions tested!

MoveRepeaters	move.l		Enemy(a6),d0		start of list
		move.l		#$100,d4		ones we want

.Loop		move.l		d0,a1			a1->next bob
		move.l		d4,d0
		and.l		bob_ID(a1),d0		Repeater?
		beq		.Next			nope, so skip it!

		tst.w		bob_Active+2(a1)	alive?
		beq		.Next			nope, so skip it!

; Is an active Repeater, move it.

		move.l		bob_X(a1),d0
		add.l		epp_Dx(a1),d0		bump X
		move.l		d0,bob_X(a1)

		move.l		bob_Y(a1),d0
		add.l		epp_Dy(a1),d0		bump Y
		move.l		d0,bob_Y(a1)

		subq.w		#1,epp_Counter(a1)	dec counter
		bne		.Next			skip while not 0

; Counter expired, change direction.

		move.l		epp_Pointer(a1),a0	next table entry
		move.l		(a0)+,d0		fetch entry
		bne.s		.StillGoing		skip if not 0
		move.l		epp_Table(a1),a0	reset to start
		move.l		(a0)+,d0		fetch entry
.StillGoing	move.l		a0,epp_Pointer(a1)	save new position
		moveq.l		#0,d1			clear
		move.b		d0,d1			image offset
		lea		epp_N(a1),a0		get data address
		add.l		d1,a0
		move.l		(a0)+,bob_Data(a1)	set it!
		move.l		(a0),bob_DMask(a1)	set Mask address
		asr.w		#8,d0			count
		move.w		d0,epp_Counter(a1)	set it!
		move.w		#0,d0
		swap		d0
		move.b		d0,d1			Dy
		ext.w		d1
		ext.l		d1
		move.l		d1,epp_Dy(a1)		set it!
		asr.w		#8,d0			Dx
		ext.w		d0
		ext.l		d0
		move.l		d0,epp_Dx(a1)		set it!

.Next		move.l		bob_Next(a1),d0		next entry
		bne		.Loop

		rts

*****************************************************************************

; Explode any destroyed bobs! This requires stepping all active explosions
;through a sequence of animation, currently four frames.

DoExplosions	move.l		Explosion(a6),d0	1st explosion

.Loop		move.l		d0,a1			a1->next bob
		move.l		bob_ID(a1),d0		get ID
		btst		#15,d0			Explosion?
		beq.s		.Done			no, so skip

		tst.w		bob_Active+2(a1)	exploding?
		beq.s		.Next			nope, so skip it

; found an exploding bob, work on animation

		subq.w		#1,exp_Counter(a1)	dec counter
		bne.s		.Next			skip if frame valid

; frame time-out, move onto next or deactivate if all done

		moveq.l		#0,d0			clear
		move.w		exp_Frame(a1),d0	get frame counter
		addq.w		#8,d0			bump image
		cmp.b		#32,d0			all done?
		bne.s		.StillGoin		nope, so continue
		move.w		#0,bob_Active+2(a1)	else kill bob

; Activate power-up at this stage

		bra.s		.Next			and loop

; step to next frame of explosion

.StillGoin	move.w		d0,exp_Frame(a1)	save frame offset
		lea		exp_N(a1),a0		a0->1st frame
		adda.l		d0,a0			a0->current frame
		move.l		(a0)+,bob_Data(a1)	set gfx pointer
		move.l		(a0),bob_DMask(a1)	set mask pointer
		move.w		#10,exp_Counter(a1)	reset counter

.Next		move.l		(a1),d0
		bne.s		.Loop
		
.Done		rts

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
		subq.w		#1,d0			was it screen 1?
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

		tst.l		bob_Draw(a0)		bob on screen?
		beq.s		.Skip			skip if not
				
		move.l		d2,dbuf_RAddr(a3)	save new address

.Skip		tst.l		d7			got restore address?
		beq.s		.DontRestore		skip if not!

; Note that following blitter stuff uses long words to stuff two registers
;in one go. Those affected are: AFWM & ALWM, AMOD & DMOD, CON0 & CON1

; Since screen is interleaved, backrgound can be restored with just one blit.
;The blit size will be: Height=ScrnDepth*BobHeight, Width=Bob Width

.BWait1		btst		#14,DMACONR(a5)		blitter finished yet
		bne.s		.BWait1			wait if not

		move.l		dbuf_Save(a3),BLTAPTH(a5)	source A
		move.l		d7,BLTDPTH(a5)			destination
		move.l		#-1,BLTAFWM(a5)			masks
		move.l		bob_Mod(a0),BLTAMOD(a5)		A, D modulos
		move.l		#$09f00000,BLTCON0(a5)		A & D: D=A
		move.w		bob_BSize+2(a0),BLTSIZE(a5)	start blit

; Get pointer to next bob structure & loop while not NULL. When NULL, end of
;list has been reached, so start saving backgrounds!

.DontRestore	move.l		(a0),d0			d0=addr of next bob
		beq.s		.StartSaving		skip if all done

		move.l		d0,a0			a0->next bob
		bra.s		.RestoreLoop		and loop

; All backgrounds have now been restored and bobs new dest addr has been
;calculated. Start saving backgrounds for active bobs!

.StartSaving	move.l		a4,a0			a0->1st bob

; Pre calculate blitter values, this takes place while blitter is still in
;action. Address of word to start saving from has already been calculated
;and stored in the bob_RAddr1 field.

.SaveLoop	move.l		a2,d0			d0=dbuf offset
		lea		(a0,d0),a3		a3->dbuf info

		tst.l		dbuf_RAddr(a3)		bob enabled?
		beq.s		.DontSave		nope, so skip it!

		move.l		bob_Mod(a0),d4		d4=word width
		swap		d4			in correct order

; Note that following blitter stuff uses long words to stuff two registers
;in one go. Those affected are: AFWM & ALWM, AMOD & DMOD, CON0 & CON1

; Since screen is interleaved, backrgound can be saved with just one blit.
;The blit size will be: Height=ScrnDepth*BobHeight, Width=Bob Width

.BWait2		btst		#14,DMACONR(a5)		blitter finished yet
		bne.s		.BWait2			wait if not

		move.l		dbuf_RAddr(a3),BLTAPTH(a5)	source A
		move.l		dbuf_Save(a3),BLTDPTH(a5)	destination
		move.l		#-1,BLTAFWM(a5)			masks
		move.l		d4,BLTAMOD(a5)			A and D modulos
		move.l		#$09f00000,BLTCON0(a5)		A & D: D=A
		move.w		bob_BSize+2(a0),BLTSIZE(a5)	start blit

; Get pointer to next bob structure & loop while not NULL. When NULL, end of
;list has been reached, so start blitting the bobs!

.DontSave	move.l		(a0),d0			d0=addr of next bob
		beq.s		.BlitLoop		skip if all done

		move.l		d0,a0			a0->next bob
		bra.s		.SaveLoop		and loop

; All backgrounds have now been saved. Start blitting the bobs. Register a4
;is no longer required, so use it instead of copying into a0.
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

		tst.l		dbuf_RAddr(a3)		bob enabled?
		beq.s		.DontBlit		nope, so skip it!

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

; Note that following blitter stuff uses long words to stuff two registers
;in one go. Those affected are: AFWM & ALWM, AMOD & DMOD, CON0 & CON1

; Since screen is interleaved, backrgound can be restored with just one blit.
;The blit size will be: Height=ScrnDepth*BobHeight, Width=Bob Width

.BWait3		btst		#14,DMACONR(a5)		blitter finished yet
		bne.s		.BWait3			wait if not

		move.l		bob_DMask(a4),BLTAPTH(a5)  source A, bob mask
		move.l		bob_Data(a4),BLTBPTH(a5)   source B, bob data
		move.l		dbuf_RAddr(a3),BLTCPTH(a5) source C, bitplane
		move.l		dbuf_RAddr(a3),BLTDPTH(a5) dest, bitplane
		move.l		#$ffff0000,BLTAFWM(a5)		masks
		move.l		d3,BLTCMOD(a5)		C & B's modulos
		swap		d3			reverse
		move.l		d3,BLTAMOD(a5)		A & D's modulos
		move.l		d2,BLTCON0(a5)		use A & D: D=A
		move.w		bob_BSize+2(a4),BLTSIZE(a5)	start blit

; Get pointer to next bob structure & loop while not NULL. When NULL, end of
;list has been reached, so start saving backgrounds!

.DontBlit	move.l		(a4),d0			d0=addr of next bob
		beq.s		.Done			skip if all done

		move.l		d0,a4			a4->next bob
		bra.s		.BlitLoop		and loop

.Done		movem.l		(sp)+,d0-d7/a2-a4	restore
		rts


*****************************************************************************

; Check for bob-bob collisions. A collision condition is only considered for
;bobs that are on screen, ID's are matched in HitMask of bob being checked
;and are within one width of the bob being checked.

; The bob being checked is blitted into an empty bitplane. The list of bobs
;supplied is then checked, any bob in a possible collision condition is
;AND'd with the bitplane using the Blitter. A non-zero result implies a
;collision has occurred. When a collision occurs, or the end of the list is
;reached, the bob is removed from the bitplane leaving it clear for next
;time.

; Entry		a0->struct for bob to check
;		a1->position in bob list to start checking from

; Exit		d0=0 if no collision, else d0= struct addr of bob hit

; Corrupt	d0-d6,a1

Bob2Bob		move.l		d7,-(sp)

		move.l		#0,HitMe(a6)		clear store var

; get bob details, constant through the loop

		moveq.l		#16,d7			horiz seperation
		move.l		d7,d6			vert seperation
		move.l		bob_X(a0),d5		X
		move.l		bob_Y(a0),d4		Y
		move.l		bob_HMask(a0),d3	Hit Mask

; Blit the bobs mask into empty bitplane

		move.l		d5,d0			X
		move.l		d4,d1			Y
		ror.l		#4,d0			/16
		asl.w		#1,d0			x2
		move.l		d0,d2			save scroll
		and.l		#$0000ffff,d0		mask out scroll
		mulu		#ScrnWidth,d1
		add.l		d1,d0
		add.l		#Collision,d0		source A
		move.l		d0,CollTemp(a6)		save for later
		move.w		#0,d2
		or.l		#$09f00000,d2		use A & D; D=A

.Bloop		btst		#14,DMACONR(a5)		busy?
		bne.s		.Bloop			yep, so wait!

		move.l		bob_DMask(a0),BLTAPTH(a5)
		move.l		d0,BLTDPTH(a5)
		move.w		bob_MMod(a0),BLTAMOD(a5)
		move.w		bob_Mod+2(a0),BLTDMOD(a5)
		move.l		#$ffff0000,BLTAFWM(a5)
		move.l		d2,BLTCON0(a5)
		move.w		bob_MBSize(a0),BLTSIZE(a5)

; Scan bob list testing for collision condition

		move.l		a1,d0			preperation
.CheckLoop	move.l		d0,a1			Enemy

; first see if bob is visible

		tst.w		bob_Draw+2(a1)		visible?
		beq		.Next			nope, skip it!

; now see if it's ID matches HitMask of bob being checked

		move.l		bob_ID(a1),d0		ID
		and.l		d3,d0			can we hit it?
		beq		.Next			nope, skip it!

; see if horizontally close enough to hit us

		move.l		d5,d0			X
		sub.l		bob_X(a1),d0		seperation
		bpl.s		.ok
		neg.l		d0			ABS(seperation)
.ok		cmp.w		d7,d0			in range?
		bge		.Next			nope, skip it!

; see if vertically close enough to hit us

		move.l		d4,d0			Y
		sub.l		bob_Y(a1),d0		seperation
		bpl.s		.ok1
		neg.l		d0			ABS(seperation)
.ok1		cmp.w		d6,d0			in range?
		bge		.Next			nope, skip it!

; Possible collision, blit bob to check

		move.l		bob_X(a1),d0
		move.l		bob_Y(a1),d1

		ror.l		#4,d0			/16
		asl.w		#1,d0			x2 = byte offset
		move.l		d0,d2			for scroll
		and.l		#$ffff,d0		mask out scroll

		mulu		#ScrnWidth,d1		line offset
		add.l		d1,d0			add to byte offset
		add.l		#Collision,d0		add start address

		move.w		#0,d2			isolate scroll
		or.l		#$0aa00000,d2		add usage & minterm

; Wait for blitter, busy-busy-wait-wait

.Bloop1		btst		#14,DMACONR(a5)
		bne.s		.Bloop1

		move.l		bob_DMask(a1),BLTAPTH(a5)  source1 = bob
		move.l		d0,BLTCPTH(a5)		  source2 = screen
		move.w		bob_MMod(a1),BLTAMOD(a5)  bob modulo
		move.w		bob_Mod+2(a1),BLTCMOD(a5) screen modulo
		move.l		#$ffff0000,BLTAFWM(a5)	  masks
		move.l		d2,BLTCON0(a5)		  control bits
		move.w		bob_MBSize(a1),BLTSIZE(a5) blit it

; Wait for blit to finish

.Bloop2		btst		#14,DMACONR(a5)
		bne.s		.Bloop2

; Check status of the blit to see if collision occurred

		btst		#13,DMACONR(a5)		test blit
		bne.s		.Next			no collision, loop!

; Collision has occurred, prepare to exit

		move.l		a1,HitMe(a6)		save bob addr
		bra.s		.Done			and exit


; No collision, keep stepping through the list

.Next		move.l		(a1),d0			next bob
		bne		.CheckLoop		loop

; Clear bobs mask from bitplane

.Done		move.l		CollTemp(a6),BLTDPTH(a5) D
		move.w		bob_Mod+2(a0),BLTDMOD(a5)	modulo
		move.l		#$01000000,BLTCON0(a5)		control
		move.w		bob_MBSize(a0),BLTSIZE(a5)	clear it!

		move.l		HitMe(a6),d0
		move.l		(sp)+,d7
		rts

*****************************************************************************

; Subroutine that blits one plane of bobs draw mask into the background mask.
;If a collision occurs, returns d0=0.

; Entry		d0=X
;		d1=Y
;		a0->bob structure

; Exit		d0=0 if collision

; Uses the top plane of draw mask and blits this into the screen mask bitplane
;If result of blit is zero, then no collision occured.

CheckPlyr	move.l		d6,-(sp)

		ror.l		#4,d0			/16
		asl.w		#1,d0			x2 = byte offset
		move.l		d0,d6			for scroll
		and.l		#$ffff,d0		mask out scroll

		mulu		#ScrnWidth,d1		line offset
		add.l		d1,d0			add to byte offset
		add.l		#Scene,d0		add start address

		move.w		#0,d6			isolate scroll
		or.l		#$0aa00000,d6		add usage & minterm

; Wait for blitter, busy-busy-wait-wait

.Bloop		btst		#14,DMACONR(a5)
		bne.s		.Bloop

		move.l		bob_DMask(a0),BLTAPTH(a5)  source1 = bob
		move.l		d0,BLTCPTH(a5)		  source2 = screen
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

.done		move.l		(sp)+,d6
		rts

*****************************************************************************
; Vertical blank interrupt driven sample player.

PlaySFX		lea		Channel0,a0		a0->struct

; See if a new sample has been requested

		tst.w		ch_New(a0)		new sample?
		beq.s		.NoNewSample0		skip if not

; New sample, start playing it!

		move.l		ch_Addr(a0),AUD0LCH(a5) set address
		move.w		ch_Len(a0),AUD0LEN(a5)	set length
		move.w		#64,AUD0VOL(a5)		set volume
		move.w		#$12c,AUD0PER(a5)	set period
		move.w		#SETIT!AUD0EN,DMACON(a5) start playing
		move.w		#1,ch_Active(a0)	signal started
		move.w		#0,ch_New(a0)		clear flag
		bra.s		.Do1

; See if a sample is playing. If it is dec it's counter and stop it when
;the counter reaches 0.

.NoNewSample0	tst.w		ch_Active(a0)		sample playing?
		beq.s		.Do1			nope, so skip

		subq.w		#1,ch_Count(a0)		dec counter
		bne.s		.Do1			skip if not over

		move.w		#0,ch_Active(a0)	signal stopped
		move.w		#AUD0EN,DMACON(a5)	stop sound

.Do1		lea		Channel1,a0		a0->struct

; See if a new sample has been requested

		tst.w		ch_New(a0)		new sample?
		beq.s		.NoNewSample1		skip if not

; New sample, start playing it!

		move.l		ch_Addr(a0),AUD1LCH(a5) set address
		move.w		ch_Len(a0),AUD1LEN(a5)	set length
		move.w		#64,AUD1VOL(a5)		set volume
		move.w		#$12c,AUD1PER(a5)	set period
		move.w		#SETIT!AUD1EN,DMACON(a5) start playing
		move.w		#1,ch_Active(a0)	signal started
		move.w		#0,ch_New(a0)		clear flag
		bra.s		.Done

; See if a sample is playing. If it is dec it's counter and stop it when
;the counter reaches 0.

.NoNewSample1	tst.w		ch_Active(a0)		sample playing?
		beq.s		.Done			nope, so skip

		subq.w		#1,ch_Count(a0)		dec counter
		bne.s		.Done			skip if not over

		move.w		#0,ch_Active(a0)	signal stopped
		move.w		#AUD1EN,DMACON(a5)	stop sound

.Done		rts

*****************************************************************************

; Present a new sample to sample player for channel 0

; Entry		a0->raw sample structure

NewSFX0		lea		Channel0,a1		a1->channel struct
		move.w		(a0)+,ch_Count(a1)	set vbl count
		move.w		(a0)+,ch_Len(a1)	set sample length
		move.l		a0,ch_Addr(a1)		set address
		move.w		#1,ch_New(a1)		signal new sample
		rts					and exit

; Present a new sample to sample player for channel 1

; Entry		a0->raw sample structure

NewSFX1		lea		Channel1,a1		a1->channel struct
		move.w		(a0)+,ch_Count(a1)	set vbl count
		move.w		(a0)+,ch_Len(a1)	set sample length
		move.l		a0,ch_Addr(a1)		set address
		move.w		#1,ch_New(a1)		signal new sample
		rts					and exit


*****************************************************************************
; Print the players score, lives and level being attacked.

PrintScore	lea		.buffer,a1
		move.l		LevelNum(a6),d0
		moveq.l		#3,d1
		bsr		DecAscii

		move.l		Score(a6),d0
		moveq.l		#8,d1
		bsr		DecAscii

		move.l		Lives(a6),d0
		moveq.l		#1,d1
		bsr		DecAscii

		move.l		Bonus(a6),d0
		moveq.l		#4,d1
		bsr		DecAscii

		lea		BitPlane+175,a2
		moveq.l		#2,d3
		lea		.buffer,a3

.loop1		moveq.l		#0,d0
		move.b		(a3)+,d0
		move.l		a2,a1
		bsr		PChar
		addq.l		#1,a2
		dbra		d3,.loop1

		lea		BitPlane+595,a2
		moveq.l		#7,d3

.loop2		moveq.l		#0,d0
		move.b		(a3)+,d0
		move.l		a2,a1
		bsr		PChar
		addq.l		#1,a2
		dbra		d3,.loop2

		lea		BitPlane+979,a1
		moveq.l		#0,d0
		move.b		(a3)+,d0
		bsr		PChar

		lea		BitPlane+203,a2
		moveq.l		#3,d3

.loop3		moveq.l		#0,d0
		move.b		(a3)+,d0
		move.l		a2,a1
		bsr		PChar
		addq.l		#1,a2
		dbra		d3,.loop3

		rts

.buffer		ds.b		18

*****************************************************************************

;	a1->buildup buffer
;	d0=value
;	d1=count

DecAscii	lea		.temp,a0		buffer
		adda.l		d1,a0			starting point
		subq.l		#1,d1			dbra adjust
		move.l		d1,d2

.loop		divu		#10,d0
		swap		d0			remainder
		add.b		#'0',d0			to ASCII
		move.b		d0,-(a0)		save in buffer
		move.b		#0,d0			clear it
		swap		d0
		dbra		d1,.loop

		lea		.temp,a0		ascii
.loop1		move.b		(a0)+,(a1)+		copy it
		dbra		d2,.loop1

		rts

.temp		ds.b		10

*****************************************************************************

; Scroll text routine for bottom of display, rate = 1 pixel per second!

ScrlTxtLine	subq.b		#1,ScrollCount(a6)
		bne.s		.JustScroll
		bsr		PrintChar
		move.b		#8,ScrollCount(a6)

.JustScroll	lea		BitPlane+2604,a0
		moveq.l		#7,d1			lines - 1

.Outer		moveq.l		#20,d0
		move.w		#0,ccr			clear extend

.Inner		roxl.w		-(a0)
		dbra		d0,.Inner

		dbra		d1,.Outer

		rts

*****************************************************************************

; Print a character off right side of bottom of display

PrintChar	move.l		NextChar(a6),a0
		tst.b		(a0)
		bne.s		.GotChar
		lea		ScrollText,a0	reset
.GotChar	moveq.l		#0,d0
		move.b		(a0)+,d0
		move.l		a0,NextChar(a6)
		lea		BitPlane+2308,a1	line 54, byte 40

; Entry d0.b = ASCII char code, a1->destination

PChar		sub.b		#' ',d0
		asl.w		#3,d0
		lea		Font,a0
		adda.l		d0,a0

		move.b		(a0)+,(a1)
		add.l		#42,a1
		move.b		(a0)+,(a1)
		add.l		#42,a1
		move.b		(a0)+,(a1)
		add.l		#42,a1
		move.b		(a0)+,(a1)
		add.l		#42,a1
		move.b		(a0)+,(a1)
		add.l		#42,a1
		move.b		(a0)+,(a1)
		add.l		#42,a1
		move.b		(a0)+,(a1)
		add.l		#42,a1
		move.b		(a0)+,(a1)

		rts


*****************************************************************************
; Routine to load a data file into memory

; Entry		d1=addr of filename
;		d5=addr of buffer
;		d6=bytes to load

; Exit		d0=0 if no data loaded

DOSLoad		move.l		a6,a4			save global pointer

		move.l		#1005,d2		MODE_OLDFILE
		move.l		_DOSBase,a6
		jsr		-$1e(a6)		Open() it
		move.l		d0,d4			handle
		beq.s		.error			quit on failure

		move.l		d0,d1			handle
		move.l		d5,d2
		move.l		d6,d3
		jsr		-$2a(a6)		Read() data

		move.l		d4,d1			handle
		jsr		-$24(a6)		Close() it

		STOPDRIVES

.error		move.l		a4,a6			restore global ptr
		move.l		d4,d0			set return code
		rts

*****************************************************************************

; Routine to save a data file

; Entry		d1=addr of filename
;		d2=addr of buffer
;		d3=bytes to load

; Exit		d0=0 if no data loaded

DOSSave		move.l		a6,a4			save global ptr
		
		move.l		_DOSBase,a6
		jsr		-$1e(a6)		Open() it
		move.l		d0,d4			handle
		beq.s		.error			quit on failure

		move.l		d0,d1			handle
		jsr		-$30(a6)		Write() data

		move.l		d4,d1			handle
		jsr		-$24(a6)		Close() it

		STOPDRIVES

.error		move.l		a4,a6			restore global ptr

		move.l		d4,d0
		rts

**************************** Intro Code  ************************************

; Pre-game introduction module. Plays some music and writes some text. Will
;oneday display a nice piccy!


; Entry		d7=address of text filename containing text to print

; Ensure screen is black

Intro		move.w		#VERTB,INTENA(a5)	stop interrupt

		move.l		#BlackList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Clear text memory

		lea		Screen1,a0		buffer
		moveq.l		#0,d1			clearing byte
		moveq.l		#151,d0			counter, 600 bytes

.ClrTxtBuf	move.l		d1,(a0)+
		dbra		d0,.ClrTxtBuf

; Clear bitplane memory

		lea		Screen1+6000,a0		address of bitplane
		move.l		#(336*256)/32,d0	size of bitplane

.ClearLoop	move.l		d1,(a0)+		clear a LONG
		dbra		d0,.ClearLoop		loop!

; Enable system DMA, minus the sprites!

		move.w		#$000f,DMACON(a5)	Kill audio DMA
		move.w		#SETIT!DMAEN,d0		set bit 15 of d0
		or.w		sysDMA(a6),d0		add DMA flags
		and.b		#$d0,d0			mask out sprites
		move.w		d0,DMACON(a5)		enable systems DMA

; Enable system interrupts

		move.w		#VERTB,INTENA(a5)	stop interrupt
		move.l		Level3(a6),$6c.w	reset system
		move.w		sysINT(a6),d0		get system bits
		or.w		#SETIT!INTEN,d0
		move.w		d0,INTENA(a5)		set old 

; Load a module

		move.l		#intromodname,d1	filename
		move.l		#Screen2,d5		buffer
		move.l		#50000,d6		size
		bsr		DOSLoad			load map

; Load a text file

		move.l		d7,d1			filename
		move.l		#Screen1,d5		buffer
		move.l		#600,d6			size
		bsr		DOSLoad			load map

; Strobe Intro's Copper List 

		move.w		#$fff,IntroCols

		move.l		#IntroList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Stop drives

		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB

; Initialise the typer

		move.w		#1,IntroOver(a6)	set main flag
		move.w		#0,IntroFlag(a6)	clear interrupt flag
		move.l		#'* + ',IntroCur(a6)	set cursor status
		move.l		#Screen1,IntroChar(a6)	set addr of text
		move.l		#0,IntroX(a6)		reset X position
		move.l		#0,IntroY(a6)		reset Y position

; Set up Intro DMA

		move.w		#$01ef,DMACON(a5) kill all dma
		move.w		#SETIT!DMAEN!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Set up Intro interrupt

		move.w		#$3fff,INTENA(a5)	stop interrupts
		move.l		#IntroL3,$6c.w		address of handler

; Initialise the module replayer

		jsr		mt_init

; Start the interrupt

		move.w		#SETIT!INTEN!VERTB,INTENA(a5)

; Wait for user to quit and fade to complete

.Wait		tst.w		IntroOver(a6)	Quit yet
		bne.s		.Wait		nope, loop back

; Ensure screen is black

		move.l		#BlackList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Stop all interrupts

		move.w		#$3fff,INTENA(a5)	stop interrupts

; Kill module

		jsr		mt_end


.Done		rts

;--------------
;-------------- The level 3 interrupt routine for the introduction!
;--------------

IntroL3		movem.l		a0-a6/d0-d7,-(a7)	Save all registers

; Clear interrupt request bit

		lea		GameVars,a6

		move.w		#VERTB,INTREQ(a5)	clear request

		tst.w		IntroFlag(a6)
		beq.s		.Print
		sub.w		#$111,IntroCols
		addq.w		#1,IntroFlag(a6)
		cmp.w		#13,IntroFlag(a6)
		bne.s		.Done
		move.w		#0,IntroOver(a6)
		bra.s		.Done

.Print		bsr		IntroPrinter

		tst.b		CIAAPRA			joystick fire button
		bmi		.Done			skip if not

		move.w		#1,IntroFlag(a6)

.Done		jsr		mt_music

		movem.l		(a7)+,a0-a6/d0-d7	restore registers
		rte

;--------------
;-------------- Intro printer routine
;--------------

IntroPrinter	move.l		IntroChar(a6),a1
		tst.b		(a1)
		beq.s		.Done

		move.l		IntroCur(a6),d0
		ror.l		#8,d0
		move.l		d0,IntroCur(a6)

		cmpi.b		#'*',d0
		beq.s		.DoLetter
		and.l		#$ff,d0
		lea		Screen1+6000,a1
		add.l		IntroX(a6),a1
		add.l		IntroY(a6),a1
		bsr		PChar
		bra.s		.Done
	
.DoLetter	moveq.l		#0,d0
		move.b		(a1)+,d0
		move.l		a1,IntroChar(a6)	save pointer
		cmpi.b		#$0a,d0			EOL?
		bne.s		.DoChar
		move.l		#0,IntroX(a6)
		add.l		#8*42,IntroY(a6)					
		bra.s		.Done

.DoChar		lea		Screen1+6000,a1
		add.l		IntroX(a6),a1
		add.l		IntroY(a6),a1
		add.l		#1,IntroX(a6)
		bsr		PChar

.Done		rts

*****************************************************************************

; This code makes sure that a playfield is not visible while data is being
;loaded into it.

KillColours	lea		$dff180,a0		colour registers
		moveq.l		#0,d0			BLACK!
		moveq.l		#15,d1			16 colours

.loop		move.w		d0,(a0)+		next colour = BLACK
		dbra		d1,.loop		loop!

		rts


*****************************************************************************

; Will soon allow entering of name into high-score table.

DoHighScore	move.l		#gameovertext,d7
		bsr		Intro

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

		move.l		#9999,Bonus(a6)		initialise bonus

; All done, so return

		rts

*****************************************************************************

; All raw gfx for bobs must be built into a linked Image list for later.

InitImages	lea		Images,a0

.Loop		move.l		4(a0),d0		word width
		asl.l		#1,d0			byte width
		mulu.w		10(a0),d0		WxH
		mulu.w		#ScrnDepth,d0		WxHxD
		asl.l		#4,d0			16 images per entry
		add.l		#12,d0			+structure size
		tst.l		(a0)			last image?
		beq.s		.Done			yep, so exit!

		add.l		a0,d0			d0=addr of next image
		move.l		d0,(a0)			write
		move.l		d0,a0
		bra.s		.Loop

.Done		rts


*****************************************************************************

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

; determine bob type.

.NextEntry	move.l		(a4)+,d4		d4=bobs ID

; Deal with an ID_Player entry.

		btst.l		#0,d4			player?
		beq		.TryBullet		skip if not

; save a pointer to this structure for quick reference

		move.l		a3,Player(a6)

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

		move.l		(a4),bob_X(a3)		set initial X value
		move.l		(a4)+,X(a6)		=initial on-screen X
		move.l		(a4),bob_Y(a3)		set initial Y value
		move.l		(a4)+,Y(a6)		=initial on-screen Y

		move.l		#1,bob_Active(a3)	set activation

; Set width, height and depth of the bob

		lea		Images,a1		a1->image list
		move.l		(a4)+,d0		Image Number
		beq.s		.gotptr			skip if 0
		subq.l		#1,d0			dbra adjust
.ptrLoop	move.l		(a1),a1			step through list
		dbra		d0,.ptrLoop

.gotptr		move.l		4(a1),d5		Word Width
		move.l		8(a1),d6		Line Height
		lea		12(a1),a1		->bob gfx

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
.dmloop		move.l		a1,(a0)+
		add.l		d0,a1			a4->next image
		move.l		a1,(a0)+
		add.l		d0,a1			a4->next image

		dbra		d1,.dmloop

; set initial bob data and mask and exit player

		move.l		pl_N(a3),bob_Data(a3)	data pointer
		move.l		pl_NMask(a3),bob_DMask(a3)

		move.l		#ID_Deadly,bob_HMask(a3) what hits us!
		move.l		#3,bob_Dying(a3)

		bra		.DoNext

; *************

; Deal with an ID_Bullet entry.

.TryBullet	btst.l		#1,d4			bullet?
		beq		.TryFollow		skip if not

; calculate address of next structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		pb_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; Set width and height of the bob

		lea		Images,a1		a1->image list
		move.l		(a4)+,d0		Image Number
		beq.s		.gotptr1		skip if 0
		subq.l		#1,d0			dbra adjust
.ptrLoop1	move.l		(a1),a1			step through list
		dbra		d0,.ptrLoop1

.gotptr1	move.l		4(a1),d5		Word Width
		move.l		8(a1),d6		Line Height
		lea		12(a1),a1		->bob gfx

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

		move.l		a1,bob_Data(a3)		addr of raw gfx
		add.l		d0,a1			a4->bobs mask
		move.l		a1,bob_DMask(a3)
		add.l		d0,a1			addr next data

; set default life of bullet and ID

		move.l		#BulletLife,pb_Term(a3)	life in 1/50ths sec
		move.l		#ID_Bullet,bob_ID(a3)	bobs ID
		move.l		#ID_Deadly,bob_HMask(a3) what hits us!

		bra		.DoNext			and onto the next

; *************

; Deal with an ID_FollowMe entry.

.TryFollow	btst.l		#7,d4			bullet?
		beq		.TryRepeat			skip if not

; If Enemy has not been set, set it now

		tst.l		Enemy(a6)		pointer set
		bne.s		.DoFollow		skip if so

		move.l		a3,Enemy(a6)		else set pointer

; Now get initial x,y and activation values from raw data

.DoFollow	move.l		(a4)+,bob_X(a3)		set initial X value
		move.l		(a4)+,bob_Y(a3)		set initial Y value

		move.l		#1,bob_Active(a3)	set activation

; calculate address of next structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		efm_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; Set width and height of the bob

		lea		Images,a1		a1->image list
		move.l		(a4)+,d0		Image Number
		beq.s		.gotptr2		skip if 0
		subq.l		#1,d0			dbra adjust
.ptrLoop2	move.l		(a1),a1			step through list
		dbra		d0,.ptrLoop2

.gotptr2	move.l		4(a1),d5		Word Width
		move.l		8(a1),d6		Line Height
		lea		12(a1),a1		->bob gfx

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

		lea		efm_N(a3),a0		a0->1st entry
		moveq.l		#7,d1			eight directions
.efmloop	move.l		a1,(a0)+
		add.l		d0,a1			a4->next image
		move.l		a1,(a0)+
		add.l		d0,a1			a4->next image

		dbra		d1,.efmloop

; set initial bob data and mask and exit player

		move.l		efm_N(a3),bob_Data(a3)	data pointer
		move.l		efm_NMask(a3),bob_DMask(a3)

; set bobs ID

		move.l		#ID_FollowMe,bob_ID(a3)	bobs ID
		move.l		#5,bob_Dying(a3)	takes 5 hits to kill
		move.l		#1500,bob_Points(a3)	kill value

		bra		.DoNext			and onto the next

; *************

; Deal with an ID_Repeater entry.

.TryRepeat	btst.l		#8,d4			Repeater?
		beq		.TryBounce		skip if not

; If Enemy has not been set, set it now

		tst.l		Enemy(a6)		pointer set
		bne.s		.DoRepeat		skip if so

		move.l		a3,Enemy(a6)		else set pointer

; Now get initial x,y and activation values from raw data

.DoRepeat	move.l		(a4)+,bob_X(a3)		set initial X value
		move.l		(a4)+,bob_Y(a3)		set initial Y value

		move.l		#1,bob_Active(a3)	set activation

; calculate address of next structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		epp_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; Set width and height of the bob

		lea		Images,a1		a1->image list
		move.l		(a4)+,d0		Image Number
		beq.s		.gotptr3		skip if 0
		subq.l		#1,d0			dbra adjust
.ptrLoop3	move.l		(a1),a1			step through list
		dbra		d0,.ptrLoop3

.gotptr3	move.l		4(a1),d5		Word Width
		move.l		8(a1),d6		Line Height
		lea		12(a1),a1		->bob gfx

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

		lea		epp_N(a3),a0		a0->1st entry
		moveq.l		#7,d1			eight directions
.epploop	move.l		a1,(a0)+
		add.l		d0,a1			a4->next image
		move.l		a1,(a0)+
		add.l		d0,a1			a4->next image

		dbra		d1,.epploop

; set initial bob data and mask and exit

		move.l		epp_N(a3),bob_Data(a3)	data pointer
		move.l		epp_NMask(a3),bob_DMask(a3)

; Set pointer to move data table

		move.l		a4,epp_Table(a3)	set table pointer
		move.l		a4,epp_Pointer(a3)
		move.w		#1,epp_Counter(a3)
		lea		80(a4),a4		step over table

; set bobs ID

		move.l		#ID_Repeater,bob_ID(a3)	bobs ID
		move.l		#8,bob_Dying(a3)	takes 8 hits to kill
		move.l		#2000,bob_Points(a3)	kill value

		bra		.DoNext			and onto the next

; *************

; Deal with an ID_Bounce entry.

.TryBounce	btst.l		#6,d4			Bounce power-up?
		beq		.TryData		skip if not

; Get initial x,y values from raw data

		move.l		(a4)+,bob_X(a3)		set initial X value
		move.l		(a4)+,bob_Y(a3)		set initial Y value

		move.l		#1,bob_Active(a3)	set activation

; calculate address of next structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		pu_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; Set width and height of the bob

		lea		Images,a1		a1->image list
		move.l		(a4)+,d0		Image Number
		beq.s		.gotptr4		skip if 0
		subq.l		#1,d0			dbra adjust
.ptrLoop4	move.l		(a1),a1			step through list
		dbra		d0,.ptrLoop4

.gotptr4	move.l		4(a1),d5		Word Width
		move.l		8(a1),d6		Line Height
		lea		12(a1),a1		->bob gfx

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

; calculate offset for this 'power-up' image

		move.l		d0,d1			image size
		asl.l		#1,d1			image+mask size
		asl.l		#2,d1			x4= image offset
		adda.l		d1,a1			->image data

		lea		bob_Data(a3),a0		
		move.l		a1,(a0)+		image
		add.l		d0,a1			
		move.l		a1,(a0)+		mask

; Set bounce timer value

		move.w		(a4)+,pu_Data(a3)	set timer

; set bobs ID

		move.l		#ID_Bounce,bob_ID(a3)	bobs ID
		move.l		#1,bob_Dying(a3)	takes 1 hit to kill
		move.l		#100,bob_Points(a3)	kill value

		bra		.DoNext			and onto the next

; *************

; Deal with an ID_Data entry.

.TryData	btst.l		#10,d4			Data module?
		beq		.TryExplode		skip if not

; Get initial x,y values from raw data

		move.l		(a4)+,bob_X(a3)		set initial X value
		move.l		(a4)+,bob_Y(a3)		set initial Y value

		move.l		#1,bob_Active(a3)	set activation

; calculate address of next structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		pu_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; Set width and height of the bob

		lea		Images,a1		a1->image list
		move.l		(a4)+,d0		Image Number
		beq.s		.gotptr5		skip if 0
		subq.l		#1,d0			dbra adjust
.ptrLoop5	move.l		(a1),a1			step through list
		dbra		d0,.ptrLoop5

.gotptr5	move.l		4(a1),d5		Word Width
		move.l		8(a1),d6		Line Height
		lea		12(a1),a1		->bob gfx

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

; calculate offset for this 'power-up' image

		move.l		d0,d1			image size
		asl.l		#1,d1			image+mask size
		mulu		#7,d1			x4= image offset
		adda.l		d1,a1			->image data

		lea		bob_Data(a3),a0		
		move.l		a1,(a0)+		image
		add.l		d0,a1			
		move.l		a1,(a0)+		mask

; Set points value

		move.w		(a4)+,pu_Data(a3)	set points

; set bobs ID

		move.l		#ID_Data,bob_ID(a3)	bobs ID
		move.l		#1,bob_Dying(a3)	takes 1 hit to kill
		move.l		#100,bob_Points(a3)	kill value

		bra		.DoNext			and onto the next

; *************

; Deal with an ID_Explode entry.

.TryExplode	btst.l		#15,d4			explosion?
		beq		.TryNME			skip if not

; If Enemy has not been set, set it now

		tst.l		Explosion(a6)		pointer set
		bne.s		.DoExplode		skip if so

		move.l		a3,Explosion(a6)	else set pointer

; activation value

.DoExplode	move.l		#0,bob_Active(a3)	not active yet

; calculate address of next structure and save in bob_Next field.

		move.l		a3,a0			a0->this structure
		lea		exp_SIZEOF(a0),a0	a0->next structure
		move.l		a0,bob_Next(a3)		set pointer

; Set width and height of the bob

		lea		Images,a1		a1->image list
		move.l		(a4)+,d0		Image Number
		beq.s		.gotptr6		skip if 0
		subq.l		#1,d0			dbra adjust
.ptrLoop6	move.l		(a1),a1			step through list
		dbra		d0,.ptrLoop6

.gotptr6	move.l		4(a1),d5		Word Width
		move.l		8(a1),d6		Line Height
		lea		12(a1),a1		->bob gfx

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

		lea		exp_N(a3),a0		a0->1st entry
		moveq.l		#7,d1			eight directions
.exploop	move.l		a1,(a0)+
		add.l		d0,a1			a4->next image
		move.l		a1,(a0)+
		add.l		d0,a1			a4->next image

		dbra		d1,.exploop

; set initial bob data and mask and exit player

		move.l		exp_N(a3),bob_Data(a3)	data pointer
		move.l		exp_NMask(a3),bob_DMask(a3)

; set bobs ID

		move.l		#ID_Explode,bob_ID(a3)	bobs ID
		move.l		#5,bob_Dying(a3)	takes 5 hits to kill
		move.l		#0,bob_Points(a3)	kill value

		bra		.DoNext			and onto the next

; *************

.TryNME		nop

; *************

.DoNext		subq.l		#1,d7
		beq.s		.Mods

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

		moveq.l		#ScrnDepth,d1		bob depth
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
		bra.s		.modloop		and loop

.done		rts


*****************************************************************************
***************************** Data ******************************************
*****************************************************************************

grafname	dc.b		'graphics.library',0
		even

dosname		dc.b		'dos.library',0
		even

intromodname	dc.b		'FollowMe:Modules/mod.follow1',0
		even

introtext	dc.b		'FollowMe:M.Meany/Game/IntroText',0
		even

gameovertext	dc.b		'FollowMe:M.Meany/Game/GameOverText',0
		even

; Name of map file for this level

MapFName	dc.b		'FollowMe:M.Meany/Game/Map'
MapFInc		dc.b		'00',0
		even

; Name of bob data file for this level

BobFName	dc.b		'FollowMe:M.Meany/Game/Bobs'
BobFInc		dc.b		'00',0
		even

; Name of bob image file for this level

ImagesFName	dc.b		'FollowMe:M.Meany/Game/Images'
ImagesFInc	dc.b		'00',0
		even
LoadingText	dc.b		'Proceeding To '
LevelText	dc.b		'Level: '
LevelTextInc	dc.b		'00'
LevelTextTerm	dc.b		0,'Cleared',0
		even

ScrollText	

	dc.b	'This game was programmed by Mark Meany, May-June 1992 ------------- '
	dc.b	'Time to send greets, in no particular order, to : Blaine Evans * Mike Cross'
	dc.b	' * Leon Skeldon * Richard Sandiford * Paul Kent * Steve Marshall * '
	dc.b	'Axal * Trog * Artwerk * Marc Bateson * Ray Burt-Frost * Mark Flemans * '
	dc.b	'Trevor Mensa * Assasins * Timeworks * John Kennedy * Kefrens for the Font '
	dc.b	'Editor * Neil Johnston * Steve Suitor * Simon Knipe * Phil Boyce '
	dc.b	'* Peter Wilson * Dave Shaw * Dave Shaw '
	dc.b	'* and all the others my addled brain has forgotten :-)                            ',0

		even

		incdir		FollowMe:M.Meany/Game/

Font		incbin		Font.bm

CMAP		dc.w	$000,$A9B,$553,$600,$324,$436,$547,$557
		dc.w	$863,$EA0,$A97,$659,$77A,$213,$DCC,$FFF
		dc.w	$000,$D22,$000,$FDB,$444,$555,$666,$777
		dc.w	$888,$999,$AAA,$BBB,$CCC,$DDD,$00E,$F00

BobData		ds.b		3000


		section		variables,BSS

_DOSBase	ds.l		1

Structures	ds.b		StructMemSize

Level		ds.b		1300

GameVars	ds.b		vars_SIZEOF


*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************

		section		cop,data_c

CopList1	dc.w DMACON,SPREN		kill sprites
		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$30		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPL1MOD,ScrnMod		Modulos for interleaved
		dc.w BPL2MOD,ScrnMod		bitplane data

CopColours1	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout1	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPLCON1,$ff		No horizontal offset

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes1	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w $ed05,$fffe
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$0200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,2			No modulo
		dc.w BPL2MOD,2			No modulo

		dc.w BPL1PTH			Plane pointers for 1 plane
BotPlane1	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH
		dc.w 0,BPL2PTL
		dc.w 0,BPL3PTH
		dc.w 0,BPL3PTL
		dc.w 0,BPL4PTH
		dc.w 0,BPL4PTL
		dc.w 0

		dc.w $ee05,$fffe
		dc.w BPLCON0,$4200

		dc.w	$ffff,$fffe		end of list

CopList2	dc.w DMACON,SPREN		kill sprites
		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$30		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPL1MOD,ScrnMod		Modulos for interleaved
		dc.w BPL2MOD,ScrnMod		bitplane data

CopColours2	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout2	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPLCON1,$ff			No horizontal offset

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes2	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w $ed05,$fffe
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$0200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,2			No modulo
		dc.w BPL2MOD,2			No modulo

		dc.w BPL1PTH			Plane pointers for 1 plane
BotPlane2	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH
		dc.w 0,BPL2PTL
		dc.w 0,BPL3PTH
		dc.w 0,BPL3PTL
		dc.w 0,BPL4PTH
		dc.w 0,BPL4PTL
		dc.w 0

		dc.w $ee05,$fffe
		dc.w BPLCON0,$4200

		dc.w	$ffff,$fffe		end of list

; Copper List used for introduction

IntroList	dc.w DMACON,SPREN		kill sprites
		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$1200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,2			No modulo
		dc.w BPL2MOD,2			No modulo

		dc.w	COLOR00,$000
		dc.w	COLOR01
IntroCols	dc.w	$fff

		dc.w BPL1PTH			Plane pointers for 1 plane
IntroPlanes	dc.w 0,BPL1PTL          
		dc.w 0

		dc.w		$ffff,$fffe		end of list

BlackList	dc.w DMACON,SPREN		kill sprites
		dc.w BPLCON0,0			bitplanes off
		dc.w BPLCON1,0			No horizontal offset
		dc.w COLOR00,0
		dc.w COLOR01,0
		dc.w COLOR02,0
		dc.w COLOR03,0
		dc.w COLOR04,0
		dc.w COLOR05,0
		dc.w COLOR06,0
		dc.w COLOR07,0
		dc.w COLOR08,0
		dc.w COLOR09,0
		dc.w COLOR10,0
		dc.w COLOR11,0
		dc.w COLOR12,0
		dc.w COLOR13,0
		dc.w COLOR14,0
		dc.w COLOR15,0
		dc.w $ffff,$fffe


BitPlane	incbin		bottom.bm

; Raw gfx data for all bobs, includes masks

Images		ds.b		15000

; Raw data for tiles that form levels. Each tile is interleaved and followed
;by a single mask plane used for collision detection. 

; Using designer : 20 x 16 blocks, Depth = 4, saved Interleaved and Mask On.

Blocks		incbin		'blocks.bm',0
		even

Sample1		dc.w		5		vbl count
		dc.w		SMP1LEN>>1	word length of sample
SMP1		incbin		Shot.snd	sample itself
SMP1LEN		equ		*-SMP1

Sample2		dc.w		15		vbl count
		dc.w		SMP2LEN>>1	word length of sample
SMP2		incbin		Boom.snd	sample itself
SMP2LEN		equ		*-SMP2

; BSS hunks used to minimise disk space occupied by program

; Followind CHIP BSS hunk used for screens, screen masks and bob background
;save areas
		section		screens,BSS_C

Screen1		ds.b		ScrnWidth*ScrnHeight*ScrnDepth
Screen2		ds.b		ScrnWidth*ScrnHeight*ScrnDepth
BobSaves	ds.b		DBuffMemSize

		section		collisions,BSS_C

Scene		ds.b		ScrnWidth*ScrnHeight
Collision	ds.b		ScrnWidth*ScrnHeight


;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 8 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used registers: d0-d3/a0-a7|	=INTENA н
;н  Mahoney & Kaktus - (C) E.A.S. 1990  н
;нннннннннннннннннннннннннннннннннннннннн
	section	music,code			; Public code
mt_init:lea	Screen2,a0
	lea	mt_mulu(pc),a1
	move.l	#Screen2+$c,d0
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
	lea	Screen2,a0
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_counter-mt_voice1(a4)
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	moveq	#0,d0
	move.b	d0,mt_counter-mt_voice1(a4)
	move.w	d0,mt_dmacon-mt_voice1(a4)
	lea	Screen2,a0
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
