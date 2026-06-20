*****************************************************************************
*						    			    *
*				~Dogs In Space~				    *
*			© P.H. Douglas  June/July 1991		    	    *
*			few modifications early 1992   			    *
*				Mod. No. 910728    			    *
*						    			    *
*		!! indicates subroutine tested and OK   		    *
*****************************************************************************

			section	YG,code_c	chip ram only please!
			opt	o+,ow-,c-	optimising on please

			incdir	Source:P_Douglas/Source/DogsInSpace/
			include custom.i	hardware include file


ExecBase		equ	4		equates for using AmigaDos
Hardware		equ	$dff000		libraries, only used to
OpenLibrary		equ	-552		start up game!
CloseLibrary		equ	-414		Didn't use Dos Includes to 
AllocMem		equ	-198		speed up Assembly times
FreeMem			equ	-210
SystemCopper1		equ	$26
SystemCopper2		equ	$32
PortA			equ	$bfe001		Fire butts and filter
IcrA			equ	$bfed01		cia-a interrupt reg.
LeftMouse		equ	6
JoyFire			equ	7

**************************************************************************
LastWave		equ	4		Number of attack waves
StartWave		equ	0		first wave 

PlayerFireSpeed		equ	5		how fast fire pixels/frame
PFireAnimSpeed		equ	6		anim speed for player fire
PFireHitAnimSpeed	equ	6		explosion anim speed
PBaseHitAnimSpeed	equ	6		player hit anim speed
InvFireAnimCount	equ	6		invader fire anim speed
PlayerXmin		equ	$90		left max pos of player base
PlayerXmax		equ	$90+$10*17	right max
PlayerYPos		equ	$11a		player base y co-ord
MshipXmin		equ	$80-$20-$18	Mothership max/min co-ords
MshipXmax		equ	$1d8
MshipFireCount		equ	18		shots before mothership comes
InvMinXabs		equ	$0280		invader min/max x co-ords
InvMaxXabs		equ	InvMinXabs+64

BuildingStart		equ	256		y pos of buildings
BuildingAbsStart	equ	BuildingStart-16

***************************************************************************

BufFlag1		equ	0	FLAGS	flag for double buffering
IntDone1		equ	1
AlienSpriteBuffer1	equ	2
FireButton1		equ	3

InvLanded2		equ	0	these are bit positions in a byte
LevelFinished2		equ	1	on hindsight perhaps coulda
GameOver2		equ	2	used bytes for each flag

PlayerEnable3		equ	0	flag 3 stuff
PlayerBaseMoveEnable3	equ	1
PlayerBaseHit3		equ	2
PlayerInvincible3	equ	3
PlayerFireEnable3	equ	4
PlayerFireHit3		equ	5
PlayerFireGo3		equ	6


AlienSpritesEnable4	equ	0
InvaderMoveEnable4	equ	1

**************************************************************************

ScreenHeight		equ	248		height  in pixels	
ScreenWordsWide		equ	20		words!

PanelHeight		equ	24		size score panel
PanelDepth		equ	2		number bitplanes for panel

InvaderPlaneHeight	equ	224		displayed height
InvaderPlaneDepth	equ	3		mem heit = 256

MemNeeded		equ	((256*40)*7)+1024

ScreenStart		equ	44
InvaderYstart		equ	ScreenStart+24	where Invaders start Y co-ord

**************************************************************************
*			START OF SOURCE CODE
**************************************************************************
Start
	bra	TakeSys				bosh AmigaDos and return
StartCode
	lea	Variables(pc),a5		a5 is my variables pointer
	bsr	InitialiseAll			initialise copperlist etc
**************************************************************************
*			Game Attract
**************************************************************************
GameAttract
	bsr	SetUpGameAttract	game attract What game attract??
	bsr	Randomise		seed random generator
	bsr	SetUpGame		initialise game

**************************************************************************
**************************************************************************
*			 Main Game Loop 
**************************************************************************
**************************************************************************
MainLoop
	move.w	vhposr(a6),d0		wait a bit before starting
	and.w	#$ff00,d0		
	cmp.w	#$4000,d0
	bne.s	MainLoop

	bsr	ProcessCollisions
	bsr	ProcessInvaders
	bsr	ProcessSprites
	bsr	WipeBuildings
	bsr	TestRandomBounds
	bsr	GameEvents		died? invaders landed? wave complete?
	tst.b	d0
	bne.s	GameAttract		if d0 non zero then end
	bsr	WaitInterrupt		wait for copper initiated int to happen

	btst	#LeftMouse,PortA	left mouse button to exit
	bne	MainLoop		for testing purposes
	bra	RestoreSys	
RandStart
**************************************************************************
*	Handle end of game etc etc
**************************************************************************
GameEvents
	btst.b	#GameOver2,flag2(a5)
	beq.s	.next
	bsr	GameOver
	moveq	#1,d0
	rts
.next	btst.b	#InvLanded2,flag2(a5)
	beq.s	.next2
	bsr	InvadersLanded
	moveq	#1,d0
	rts
.next2	btst.b	#LevelFinished2,flag2(a5)
	beq	.ret
	bclr.b	#AlienSpritesEnable4,flag4(a5)
	addq.b	#1,Wave(a5)
	cmp.b	#LastWave,Wave(a5)
	bne	.nL
	clr.b	Wave(a5)
	addq.b	#8,YstartOffSet(a5)
	cmp.b	#32,Ystartoffset(a5)
	bcs	.nL
	move.b	#32,YstartOffset(a5)
.nL	moveq	#50,d0
.loop	bsr	WaitInterrupt
	dbf	d0,.loop
	bsr	GetNewLevel
	bset.b	#AlienSpritesEnable4,flag4(a5)
.ret	moveq	#0,d0
	rts

**************************************************************************
*		Game Over routine
**************************************************************************
GameOver
	bclr.b	#AlienSpritesEnable4,flag4(a5)
	bclr.b	#PlayerEnable3,flag3(a5)
	moveq	#125,d0
.loop	bsr	WaitInterrupt
	dbf	d0,.loop
	rts

**************************************************************************
*		Invaders Landed routine
**************************************************************************
InvadersLanded
	bclr.b	#AlienSpritesEnable4,flag4(a5)
	bclr.b	#PlayerEnable3,flag3(a5)
	moveq	#125,d0
.loop	bsr	WaitInterrupt
	dbf	d0,.loop

	rts

**************************************************************************
*		Player Finished Game routine
**************************************************************************
PlayerFinishedGame
	rts				Oh dear nowt here what a lazy git!

**************************************************************************
**************************************************************************
*!!		handle collisions for previous frame
**************************************************************************
**************************************************************************
ProcessCollisions
	move.w	CollisionData(a5),d7	all collisions are detected with
.test1	btst.l	#1,d7			amiga hardware!!
	beq.s	.test2			this tests what if anything has
	bsr	S01HitInv		collided with whatever
.test2	btst.l	#2,d7			and calls appropriate routine
	beq.s	.test3			On hindsight coulda used a
	bsr	S23HitInv		vector table for routines
.test3	btst.l	#3,d7
	beq.s	.test5
	bsr	PBaseHitInv
.test5	btst.l	#5,d7
	beq.s	.test6
	bsr	S01HitDef	!!
.test6	btst.l	#6,d7
	beq.s	.test8
	bsr	S23HitDef	!!
.test8	btst.l	#8,d7
	beq.s	.test10
	bsr	PFireHitDef	!!
.test10	btst.l	#10,d7
	beq.s	.test11
	bsr	S0123HitBase	!!
.test11	btst.l	#11,d7
	beq.s	.test12
	bsr	S01HitPFire
.test12	btst.l	#12,d7
	beq.s	.test13
	bsr	S0123HitBase	!!
.test13	btst.l	#13,d7
	beq.s	.test4
	bsr	S23HitPFire
.test4	btst.l	#4,d7
	beq.s	.ret
	bsr	PFireHitInv
.ret	rts
	
*************************************************************************
*!!	Sprite 0,1,2,3 hit base
*************************************************************************
S0123HitBase
	btst.b	#PlayerInvincible3,flag3(a5)
	bne	.ret
	btst.b	#PlayerBaseHit3,flag3(a5)
	bne	.ret
	move.b	#PBaseHitAnimSpeed,PlayerBaseCount(a5)
	move.b	#1,PBaseAnim(a5)
	bset.b	#PlayerBaseHit3,flag3(a5)
	bclr.b	#PlayerFireEnable3,flag3(a5)
	move.w	PlayerXpos(a5),d0
	lea	BaseExplosionAudioData,a0
	bsr	StartSample32
.ret	rts

*************************************************************************
*!!		sprite 0 or 1 hit defences
*************************************************************************
S01HitDef
	lea	InvFireStruct(a5),a3
	bsr	InvFireHitDef
	rts

*************************************************************************
*!!		sprite 2 or 3 hit defences
*************************************************************************
S23HitDef
	lea	InvFireStruct+24(a5),a3
	bsr	InvFireHitDef
	rts

*************************************************************************
*!!		Invader fire hit defences 
*************************************************************************
InvFireHitDef
	tst.b	(a3)			is missile active?
	beq	.next			if not get next missile
	bsr	InvFireHitDef2
.next	adda.w	#12,a3
	tst.b	(a3)			is missile 2 active
	beq	.ret			if not return sub.
	bsr	InvFireHitDef2
.ret	rts

**************************************************************************
*!!	And mask of missile with defences if non zero then wipe!
**************************************************************************
InvFireHitDef2
	move.w	10(a3),d0		get Ypos
	moveq	#0,d1
	move.b	3(a3),d1
	sub.w	d1,d0			get last Y pos
	addq.w	#3,d0
	sub.w	#BuildingAbsStart,d0	check if near defences
	bcs	.ret
	cmp.w	#32,d0
	bcc	.ret
	mulu	#40,d0			get lines down
	move.w	8(a3),d1		get X pos of missile
	sub.w	#$70,d1			sub sprite screen offset
	move.w	d1,d2
	and.b	#$0f,d2			get shift value in d2
	lsl.b	#4,d2			shift 12 places left
	lsl.w	#8,d2
	and.w	#$01f0,d1
	lsr.w	#3,d1			get bytes to add
	lea	BuildingsAbs,a0
	adda.w	d1,a0			got pos along
	adda.w	d0,a0			got lines down
	lea	InvFireMaskData,a1	get mask of missile
	moveq	#0,d0
	move.b	1(a3),d0		get anim number
	lsl.w	#6,d0			each is 64 bytes
	adda.w	d0,a1
	move.w	#0,bltamod(a6)		set up blitter stuff
	move.w	#36,bltdmod(a6)
	move.w	#36,bltcmod(a6)
	move.l	a0,bltcpt(a6)		points to defence data
	move.l	a1,bltapt(a6)		points to mask of missile
	move.w	d2,d3			save shift value
	or.w	#$0aa0,d3		use a,c d=a.c	Dest OFF
	move.w	d3,bltcon0(a6)
	move.w	#(16*64+2),bltsize(a6)		blitsize h16 w2
	btst.b	#6,dmaconr(a6)
.wb1	btst.b	#6,dmaconr(a6)
	bne	.wb1
	btst.b	#5,dmaconr(a6)		test blitter Zero flag
	bne	.ret			return if result zero
	move.l	a0,bltdpt(a6)		points to defences data
	move.l	a0,bltcpt(a6)
	move.l	a1,bltapt(a6)		points to missile mask
	or.w	#$0b0a,d2
	move.w	d2,bltcon0(a6)		use a,c,d  d=a(bar).c
	move.w	#(16*64+2),bltsize(a6)	start blit h16 w2
	clr.b	(a3)			make missile non-active
	btst.b	#6,dmaconr(a6)
.wb2	btst.b	#6,dmaconr(a6)
	bne	.wb2
;	btst.b	#5,MshipStatus(a5)	no audio if Mship moving
;	bne.s	.ret
;	move.w	8(a3),d0
;	lea	ExplosionAudioData,a0
;	bsr	StartSample01
.ret	rts

*************************************************************************
*!!		player fire hit defences
*************************************************************************
PFireHitDef
	btst.b	#PlayerFireGo3,flag3(a5)
	beq	.ret
	bclr.b	#PlayerFireGo3,flag3(a5)
	move.w	PlayerFireX(a5),d5
	moveq	#0,d0			hit type 0
	addq.w	#7,d5			get pos of missile tip
	sub.w	#$70,d5
	move.w	d5,d3
	and.b	#$07,d3			get shift value 0-7
	moveq	#7,d4
	sub.b	d3,d4
	lsr.w	#3,d5			get bytes to add
	lea	BuildingsScreen+16*40,a0
	adda.w	d5,a0			got pos along
	moveq	#40,d1
	moveq	#16,d0			find first set bit in
.loop	btst.b	d4,(a0)			defences
	bne	.gotSB
	suba.l	d1,a0			get next row up
	dbf	d0,.loop
	bra.s	.ret			ret if didnt hit
.gotSB	bclr.b	d4,(a0)
	bclr.b	d4,-40(a0)
	bclr.b	d4,-80(a0)
	move.b	d4,d3
	move.l	a0,a1
	tst.b	d4			clear bits to right
	beq	.d4z
	subq.b	#1,d4
	bra.s	.okr
.d4z	addq.l	#1,a0
	moveq	#7,d4
.okr	bclr.b	d4,-40(a0)
	cmp.b	#7,d3			clear bits to left
	beq	.d3s
	addq.b	#1,d3
	bra.s	.okl
.d3s	subq.l	#1,a1
	moveq	#0,d3
.okl	bclr.b	d3,(a1)
;	move.w	PlayerFireX(a5),d0
;	lea	ExplosionAudioData,a0
;	bsr	StartSample32
.ret	rts

*************************************************************************
*		sprite 0 or 1 hit invaders
*************************************************************************
S01HitInv
	rts				return cos it dont mean diddly

*************************************************************************
*		sprite 2 or 3 hit invaders
*************************************************************************
S23HitInv
	rts				;likewise above Sprites 0,1,2,3
					;are invader fire thats why
*************************************************************************
*		player base has been hit by invaders
*************************************************************************
PBaseHitInv
	btst.b	#PlayerInvincible3,flag3(a5)
	bne	.ret
	btst.b	#PlayerBaseHit3,flag3(a5)
	bne	.ret
	move.b	#PBaseHitAnimSpeed,PlayerBaseCount(a5)
	move.b	#1,PBaseAnim(a5)
	bset.b	#PlayerBaseHit3,flag3(a5)
	bclr.b	#PlayerFireEnable3,flag3(a5)
	move.w	PlayerXpos(a5),d0
	lea	BaseExplosionAudioData,a0
	bsr	StartSample32
.ret	rts

*************************************************************************
*		player fire hit invaders
*************************************************************************
PFireHitInv
	btst.b	#PlayerFireGo3,Flag3(a5)	is PFire a missile
	beq	.ret
	move.w	PlayerFireX(a5),d5
	move.w	PlayerFireY(a5),d4
	add.w	#PlayerFireSpeed,d4		get pos 1 frame ago!
	move.w	Inv00Xold(a5),d3
	add.w	#$0208,d5
	sub.w	d3,d5
	bcs	.ret
	and.w	#$00f0,d5			get column of invader*16
	move.w	Inv00Yold(a5),d3
	sub.w	d3,d4
	bcs.s	.ret
	and.w	#$00f0,d4		get row of invader*16
	cmp.w	#$00a0,d4
	bcc	.ret			test bounds
	lea	InvaderLevelData,a4
	move.w	d4,d0
	move.w	d5,d1
	lsl.w	#4,d4			get row no. *256 ie row*16*16
	adda.w	d4,a4
	adda.w	d5,a4
	tst.b	(a4)			if invader not active then ret
	beq	.ret
	add.w	Inv00Y(a5),d0		set up pos of explosion
	move.w	d0,PFireHitY(a5)
	add.w	Inv00X(a5),d1
	sub.w	#$200,d1
	move.w	d1,PFireHitX(a5)
	bsr	InvaderHit
	bset.b	#PlayerFireHit3,flag3(a5)	set up explosion etc
	bclr.b	#PlayerFireGo3,flag3(a5)
	move.b	#PFireHitAnimSpeed,PFHCounter(a5)
	move.b	#1,PFHAnim(a5)
.ret	rts

**************************************************************************
*		Invader hit  adr of Inv Struct in a4 on entry
**************************************************************************
InvaderHit
	moveq	#0,d0			bits 31-16 of d0 cleared
	move.w	10(a4),d0		get score of dead invader.w in d0
	move.l	a4,-(sp)		save my struct addr
	bsr	IncrementScore		add score
	move.l	(sp)+,a4		
	move.w	#38,bltdmod(a6)		set up blitter
	move.w	#0,bltamod(a6)		to clear invader from screen
	move.w	#$09f0,bltcon0(a6)	D=A ,no specials,shifts
	move.w	#(16*64+1),d3		blitsize h=16 w=1
	move.l	B1Grafix(a5),a0		addr of grafix dest.
	lea	InvaderGrafix,a1	addr of grafix source
	moveq	#0,d1
	move.b	12(a4),d1		get next anim number
	mulu.w	#192,d1			2 anims = 2*96 =192 bytes
	adda.w	d1,a1			get addr of grafix source
	adda.w	14(a4),a0		get addr of grafix dest
	move.l	a1,bltapt(a6)
	moveq	#5,d1			copy 6 planes ie 2 buffers
	move.w	#(256*40),d0
.loop	move.l	a0,bltdpt(a6)
	move.w	d3,bltsize(a6)		start Blit
	btst.b	#6,dmaconr(a6)		waits for blitter
.wb	btst.b	#6,dmaconr(a6)		to finish
	bne	.wb
	adda.w	d0,a0			get next plane
	dbf	d1,.loop

	move.w	PFireHitX(a5),d0	Set up Audio
	lea	ExplosionAudioData,a0
	bsr	StartSample32
	tst.b	12(a4)			if another invader appears
	beq.s	.none			then return now
	bsr	GetNewInvStructure
	rts
.none	bsr	DeleteInvader
	rts

**************************************************************************
*		delete an invader and modify lists etc
**************************************************************************
DeleteInvader
	subq.b	#1,NumberInvaders(a5)
	bne	.ok
	bset.b	#LevelFinished2,flag2(a5)
.ok	moveq	#0,d0
	move.b	d0,(a4)			make non-active!!
	move.b	13(a4),d0		get number of inv
	move.l	d0,d1
	and.b	#$0f,d0			get column number
	lsr.b	#4,d1			get row number
	lea	InvaderCols(a5),a0	modify column counters
	adda.l	d0,a0
	tst.b	(a0)
	beq.s	.noC
	subq.b	#1,(a0)
.noC	lea	InvaderRows(a5),a0	modify row counters
	adda.l	d1,a0
	tst.b	(a0)
	beq.s	.noR
	subq.b	#1,(a0)
.noR	bsr	CalcInvBounds		calculate new boundarys
	bsr	GetInvadersFiring	which invaders firing now?
	bsr	GetNewInvSpeed		new speed needed?
.ret	rts

*************************************************************************
*		get new invader structure
*************************************************************************
GetNewInvStructure
	moveq	#0,d0
	move.b	12(a4),d0		get next invader type
	lsl.w	#4,d0
	addq.l	#1,a4			skip status byte as we wish to keep it
	lea	InvaderStructures+1,a0
	adda.l	d0,a0			get to new structure
	moveq	#11,d0			copy 12 bytes
.loop	move.b	(a0)+,(a4)+
	dbf	d0,.loop
	rts

*************************************************************************
*	get new speed and animation speed info
*************************************************************************
GetNewInvSpeed
	move.b	InvadersCmp(a5),d0
	beq	.ret
	cmp.b	NumberInvaders(a5),d0
	bcs	.ret
	moveq	#0,d0
	addq.b	#1,SpeedUpCount(a5)
	move.b	SpeedUpCount(a5),d0
	add.b	d0,d0
	add.b	SpeedUpCount(a5),d0	multiply by 3
	lea	SpeedLD(a5),a0
	add.w	d0,a0
	move.b	(a0)+,d0		get speed pixels/frames
	move.b	d0,d1
	lsr.b	#4,d0			get speed pix
	subq.b	#1,d0
	move.b	d0,SpeedPixels(a5)
	and.b	#$0f,d1			get speed frames
	move.b	d1,Speedframes(a5)
	move.b	d1,SpeedCount(a5)
	move.b	(a0),AnimCount(a5)
	move.b	(a0)+,AnimFrames(a5)
	move.b	(a0),InvadersCmp(a5)
.ret	rts

*************************************************************************
*!!		player fire hit sprite 0 or 1
*************************************************************************
S01HitPFire
	bsr	HitMotherShip		weve either hit Mothership
	lea	InvFireStruct(a5),a3	or some invader missile
	bsr	PFireHitInvFire		dont know which cos sprites 0,1,2,3
	rts				are multiplexed to display both 

*************************************************************************
*!!		player fire hit sprite 2 or 3
*************************************************************************
S23HitPFire
	bsr	HitMotherShip			see above
	lea	InvFireStruct+24(a5),a3
	bsr	PFireHitInvFire
	rts

*************************************************************************
*!!		check if player fire hit invader fire
*************************************************************************
PFireHitInvFire
	tst.b	(a3)
	beq	.next
	bsr	PFireHitInvFire2
.next	adda.w	#12,a3
	tst.b	(a3)
	beq	.ret
	bsr	PFireHitInvFire2
.ret	rts

*************************************************************************
*!!		check if player missile hit this invader missile
*************************************************************************
PFireHitInvFire2
	btst.b	#PlayerFireGo3,flag3(a5)
	beq.s	.ret
	move.w	PlayerFireY(a5),d1	check vertical bounds!
	addq.w	#4,d1			add a bit for last movement
	moveq	#0,d0
	move.b	3(a3),d0
	add.w	d0,d1			get last frames positions
	sub.w	10(a3),d1
	bcs.s	.ret
	cmp.w	#12,d1
	bcc.s	.ret
	move.w	PlayerFireX(a5),d2	get x pos of player fire
	move.w	8(a3),d0		get xpos of invader fire
	sub.w	d2,d0
	beq.s	.hit
	bcs.s	.neg
	cmp.w	#3,d0
	bcc.s	.ret
	bra.s	.hit
.neg	neg.w	d0
	cmp.w	#3,d0
	bcc.s	.ret
.hit	clr.b	(a3)
	bclr.b	#PlayerFireGo3,flag3(a5)
	bset.b	#PlayerFireHit3,flag3(a5)
	move.b	#PFireHitAnimSpeed,PFHCounter(a5)
	move.b	#2,PFHAnim(a5)
	move.w	PlayerFireY(a5),PFireHitY(a5)
	move.w	PlayerFireX(a5),PFireHitX(a5)
	lea	ExplosionQuietAudioData,a0
	move.w	PlayerFireX(a5),d0
	bsr	StartSample32
.ret	rts

**************************************************************************
*!!	Playerfire hit the mothership 
**************************************************************************
HitMothership
	cmp.w	#InvaderYstart-10,PlayerFireY(a5)
	bcc	.ret
	bclr.b	#PlayerFireGo3,flag3(a5)
	move.b	MshipStatus(a5),d0
	btst	#4,d0				have we already hit it?
	bne	.ret
	bset	#4,d0				set hit flag
	bclr	#3,d0				reset moving flag
	move.b	d0,MshipStatus(a5)
	move.b	#1,MshipAnim(a5)
	clr.b	PlayerFireCount(a5)
	move.b	#4,MshipCount(a5)		set up explosion etc
	move.w	MShipXpos(a5),d0		Set up Audio
	lea	ExplosionAudioData,a0
	bsr	StartSample32
	bclr.b	#5,MshipStatus(a5)		clear repeat audio bit
.ret	rts

**************************************************************************
**************************************************************************
*!!		Process sprites - MotherShip, InvaderFire, Specials
**************************************************************************
**************************************************************************
ProcessSprites
	bsr	ProcessMotherShip	all these do is update positions
	bsr	ProcessInvaderFire	and crap like that
	bsr	BuildSpriteDataList
	rts

**************************************************************************
*!!		modify mothership position etc
**************************************************************************
ProcessMotherShip
	move.b	MShipStatus(a5),d7
	btst	#2,d7			is Mship active
	beq	.retW
	btst	#3,d7			is Mship Moving
	bne	.moving
	btst	#4,d7			is Mship Hit
	bne	.hit
.waiting
	cmpi.b	#MShipFireCount,PlayerFireCount(a5)
	bcs	.retW
	and.b	#$03,d7			get speed
	beq.s	.s1
	cmp.b	#1,d7
	beq.s	.s2
	cmp.b	#2,d7
	beq.s	.s3
.s4	moveq	#2,d0			pixels
	moveq	#1,d1			frame count
	move.w	#216,d2			222=16Khz
	bra.s	.putS
.s1	moveq	#1,d0
	moveq	#2,d1
	move.w	#222,d2
	bra.s	.putS
.s2	moveq	#1,d0
	moveq	#1,d1
	move.w	#220,d2
	bra.s	.putS
.s3	moveq	#2,d0
	moveq	#1,d1
	move.w	#218,d2
.putS	move.b	d1,MshipCount(a5)	init counter
	move.b	d1,MshipCmax(a5)	init counter reset value
	clr.b	MshipAnim(a5)
	bset.b	#3,Mshipstatus(a5)
	btst.b	#0,frames(a5)
	beq	.initr

.initl	neg.w	d0			going left
	move.w	d0,MShipAdd(a5)
	move.w	#MshipXmax,MshipXpos(a5)
	bsr	SetUpMshipAudio		set up mothership Audio
.retW	rts
.initR	move.w	d0,MShipAdd(a5)		going right
	move.w	#MshipXmin,MshipXpos(a5)
	bsr	SetUpMShipAudio
	rts

**************************************************************************

.moving
	subq.b	#1,MshipCount(a5)
	bne.s	.retM
	move.b	MshipCMax(a5),MShipCount(a5)
	move.w	MShipAdd(a5),d0
	add.w	d0,MShipXpos(a5)
	btst	#7,d0				test direction
	beq.s	.right
	cmpi.w	#MShipXmin,MShipXpos(a5)
	bcc.s	.audio
.stop	andi.b	#$04,MShipStatus(a5)		reset speed ,reset move flag
	clr.b	PlayerFireCount(a5)
	bclr.b	#5,MShipStatus(a5)		stop sample repeating
.retM	rts					reset moving bit
.right cmpi.w	#MShipXmax,MShipXpos(a5)
	bcc	.stop
.audio	move.w	MShipXpos(a5),d0		update audio volumes
	bsr	GetAudioVolume
	move.w	d1,aud0+ac_vol(a6)
	move.w	d2,aud1+ac_vol(a6)
	rts

**************************************************************************

.hit	subq.b	#1,MshipCount(a5)
	bne	.retH
	move.b	Mshipanim(a5),d1
	addq.b	#1,d1				get next anim number
	cmp.b	#5,d1				6 is anim of 1st bonus?
	beq	.setUpB
	bcc	.endB
	move.b	d1,Mshipanim(a5)
	move.b	#4,MshipCount(a5)		ExplosionCount
.retH	rts

.EndB	bclr.b	#4,MshipStatus(a5)		reset hit bit
	clr.b	Mshipanim(a5)			make anim normal
	clr.w	MshipXpos(a5)			point Mship off screen
	cmp.b	#6,d1
	bne.s	.500
	move.w	#$250,d0
	bra.s	.addB			get scores to add
.500	cmp.b	#7,d1				when Mship has been
	bne.s	.1000				hit
	move.w	#$500,d0
	bra.s	.addB
.1000	cmp.b	#8,d1
	bne.s	.2000
	move.w	#$1000,d0
	bra.s	.addB
.2000	move.w	#$2000,d0
.addB	bsr	IncrementScore
	rts	

.setupB	move.b	#35,MshipCount(a5)		BonusCount
	and.b	#$03,d7				get speed
	add.b	d7,d1				add to anim no.
	cmp.b	#3,d7				is speed = 3, if not
	beq.s	.nextS				add #1 to speed
	addq.b	#1,MshipStatus(a5)
.nextS	move.b	d1,Mshipanim(a5)
	rts

*************************************************************************
*		set up the mothership audio
*************************************************************************
SetUpMShipAudio
	lea	MShipAudioData,a0
	move.w	d2,(a0)				put period in sample
	move.w	MShipXpos(a5),d0
	bsr	StartSample01			Yo Pistel activate the bass
	bset.b	#5,Mshipstatus(a5)		turn on repeat audio bit
	rts

**************************************************************************
*!!		Find which Invaders firing
**************************************************************************
ProcessInvaderFire
	bsr	UpdateInvFireStruct
	btst.b	#AlienSpritesEnable4,Flag4(a5)
	beq.s	.ret
	bsr	PIsubc			subtract 1 from each counter
	tst.b	d1			d1 is no. inv firing
	beq.s	.ret			if none return
	bsr	GetRandomRange
	bsr	GetToInvaderFiring
	tst.b	7(a4)			fire exclude counter
	bne.s	.ret			return if non zero
	bsr	StartInvFiring
.ret	rts

**************************************************************************
*!!		update the invader fire structures
**************************************************************************
UpdateInvFireStruct
	lea	InvFireStruct(a5),a3
	move.w	PlayerXpos(a5),d5
	moveq	#3,d7
	moveq	#12,d6
.loop	tst.b	(a3)		test if active or not
	beq	.nextS
	move.w	10(a3),d0	get ypos
	moveq	#0,d1
	move.b	3(a3),d1
	add.w	d1,10(a3)	add Vspeed to Ypos
	cmp.w	#(ScreenStart+250),10(a3)
	bcs	.ok
	clr.b	(a3)		missile off bottom of screen!!
	bra	.nextS
.ok	subq.b	#1,2(a3)
	bne	.animok
	move.b	#InvFireAnimCount,2(a3)
	bchg.b	#0,1(a3)		change anim!!
.animok	tst.b	5(a3)			test if tracker
	beq	.nextS
	subq.b	#1,6(a3)
	bne	.nextS
	move.b	5(a3),6(a3)		restore Hframe count
	move.w	8(a3),d0		get fire xpos
	moveq	#0,d1
	move.b	4(a3),d1		get hspeed pix
.track	cmp.w	d0,d5			d5 is PlayerXpos
	beq.s	.tfin			if same finish tracking
	bcc	.trackr
	subq.w	#1,d0
	bra.s	.nt
.trackr	addq.w	#1,d0
.nt	dbf	d1,.track
.tfin	move.w	d0,8(a3)
.nextS	adda.l	d6,a3			get to next structure
	dbf	d7,.loop
	rts

**************************************************************************
*!!	subtract fire exclude counters for invaders firing
**************************************************************************
;returns no. Invaders firing in d0.b
PIsubc
	lea	InvaderLevelData,a4
	moveq	#16,d0
	moveq	#0,d1
	move.w	#159,d7
.loop	btst.b	#2,(a4)			test fire bit of all
	beq.s	.noFir			invaders
	addq.b	#1,d1			count number firing
	tst.b	7(a4)
	beq.s	.noFir
	subq.b	#1,7(a4)
.noFir	adda.l	d0,a4			get to next invader
	dbf	d7,.loop
	rts

**************************************************************************
*!!	get random number from 1 to d1 in d0,  d1 must be non zero!!
**************************************************************************
GetRandomRange
	moveq	#0,d0
	bsr	GetRandom	gets random 0-255 in d0
	move.w	d0,d2		get random word
	lsl.w	#5,d2
	or.w	d2,d0		get a random word in d0
	divu	d1,d0		get d0/d1 in d0
	swap	d0		get remainder	ie range 0 to d1-1
	addq.b	#1,d0
	rts

**************************************************************************
*	get to invader firing in d0
**************************************************************************
GettoInvaderFiring
	lea	InvaderLevelData,a4
	moveq	#16,d1
.nexti	btst.b	#2,(a4)		test firing bit
	beq	.notFir		if set
	subq.b	#1,d0		sub #1 from d0
	beq	.got		if zero then got to Inv firing
.notFir	adda.l	d1,a4
	bra.s	.nexti
.got	rts

**************************************************************************
*		start a invader firing!!
**************************************************************************
StartInvFiring
	move.b	6(a4),7(a4)		refresh exclude counter
	bsr	GetRandom		test out agression stuff
	cmp.b	AgressionLD(a5),d0
	bcc.s	.ret
	lea	InvFireStruct(a5),a3
	moveq	#3,d0
	moveq	#12,d1
.test	tst.b	(a3)			test if missile active
	beq	.putf			if not	put new structure in
	adda.l	d1,a3
	dbf	d0,.test
	rts
.putf	bsr	GetNewFireStruct
.ret	rts

**************************************************************************
*		get a missile structure from invader structure
**************************************************************************
GetNewFireStruct
;a4 points to invader structure
;a3 points to missile structure	
	move.b	#1,(a3)			make active
	move.b	#InvFireAnimCount,2(a3)
	move.b	2(a4),d1		get anim number
	move.b	3(a4),d2		get vspeed
	tst.b	4(a4)
	beq	.normal
	bsr	GetRandom
	cmp.b	5(a4),d0		is this missile a tracker ?
	bcc	.tracker
.normal	lsr.b	#4,d1			get Anim normal
	lsr.b	#4,d2			get Vspeed Normal
	clr.w	4(a3)			make tracker stuff zero
	bra.s	.getXY
.tracker
	and.b	#$0f,d1			get anim tracker
	and.b	#$0f,d2			get vspeed tracker
	move.b	4(a4),d0		get Hspeed
	move.b	d0,d3
	lsr.b	#4,d0			get HspeedPix
	subq.b	#1,d0			sub #1
	move.b	d0,4(a3)
	and.b	#$0f,d3			get Hspeedframes
	move.b	d3,5(a3)
	move.b	d3,6(a3)
.getXY	lsl.b	#1,d1
	move.b	d1,1(a3)		put anim number
	move.b	d2,3(a3)		put vspeed
	moveq	#0,d0
	move.b	13(a4),d0		get invader no.
	move.w	d0,d1
	lsl.b	#4,d0			get col no. *16
	move.w	Inv00X(a5),d2	
	add.w	d0,d2			get Xpos
	sub.w	#$0200,d2		subtract the InvXoffset
	move.w	d2,8(a3)		store xpos
	and.b	#$f0,d1			get row no. *16
	move.w	Inv00Y(a5),d2
	add.w	d1,d2
	add.w	#12,d2			get Ypos
	move.w	d2,10(a3)		store ypos
	rts

**************************************************************************
*	draw invader sprites into list and get control words
**************************************************************************
BuildSpriteDataList
	move.w	#0,bltdmod(a6)			
	move.w	#0,bltamod(a6)
	move.w	#$09f0,bltcon0(a6)		D=A ,no specials,shifts
	lea	InvSprites0(a5),a4		get the buffer Not
	btst.b	#AlienSpriteBuffer1,Flag1(a5)	being displayed
	bne	.ok
	lea	InvSprites1(a5),a4
.ok	bsr	BuildMship
	bsr	BuildInvFire
	bchg.b	#AlienSpriteBuffer1,Flag1(a5)	swap sprite buffers
	rts

**************************************************************************
*!!		build mothership sprite list
**************************************************************************
BuildMship
	move.l	a4,a0				Mothership is 2 attached 
	moveq	#0,d0				sprites ie Sprites 0,1,2,3
	move.b	MShipAnim(a5),d0		get mship anim no.
	lsl.w	#8,d0				multiply by 256
	lea	MShipGrafix,a1
	adda.l	d0,a1				get to addr of grafix
	moveq	#3,d7				data list

	move.l	a1,bltapt(a6)			source of grafix
.loopM	move.l	(a0)+,bltdpt(a6)		destination
	move.w	#(1*64+32),bltsize(a6)		start blit
	btst	#14,dmaconr(a6)			waits for blitter
.wb1	btst	#14,dmaconr(a6)			to finish
	bne	.wb1
	dbf	d7,.loopM			copy 4 sprites

	move.l	(a4),a0
	move.w	MShipXpos(a5),d7		get xpos
	moveq	#53,d6				get ypos
	bsr	GetSpriteCW
	move.l	d5,(a0)				put control words
	bset	#7,d5				set attach bit
	move.l	d5,132(a0)
	move.w	MshipXpos(a5),d7		get xpos
	add.w	#16,d7				add 16 for sprite
	moveq	#53,d6				4 and 5
	bsr	GetSpriteCW
	move.l	d5,132*2(a0)
	bset	#7,d5				set attach bit
	move.l	d5,132*3(a0)
	rts

**************************************************************************
*!!		build sprite data for invader fire
**************************************************************************
BuildInvFire

	move.l	(a4),a2				get pointer to sprite list
	adda.w	#64,a2				where to put fire inv data
	lea	InvFireStruct(a5),a0
	lea	InvFireGrafix,a1
	moveq	#3,d4
.loopI	move.l	a1,a3
	moveq	#0,d5
	tst.b	(a0)				test if active
	beq	.putd5
.active	move.b	1(a0),d5			get anim number
	lsl.w	#6,d5				multiply by 64
	adda.l	d5,a3				get addr of grafix
	move.l	a3,Bltapt(a6)
	move.l	a2,bltdpt(a6)			destination	
	move.w	#(1*64+32),bltsize(a6)		32 words, 64 bytes
	move.w	8(a0),d7			get xpos
	move.w	10(a0),d6			get ypos
	bsr	GetSpriteCW
.wb2	btst	#14,dmaconr(a6)			wait for blitter
	bne	.wb2
.putd5	move.l	d5,(a2)				put CW in list
	adda.w	#132,a2				next sprite
	adda.w	#12,a0
	dbf	d4,.loopI
	rts

**************************************************************************
*!!		test random pointer bounds
**************************************************************************
TestRandomBounds
	move.l	RandAdrPtr(a5),a0
	cmp.l	RandAdrMax(a5),a0
	bcs	.ok
	move.l	RandAdrMin(a5),RandAdrPtr(a5)
.ok	rts

**************************************************************************
**************************************************************************
*		COPPER INTERRUPT  executed every frame
**************************************************************************
**************************************************************************
	cnop	0,4	Longword Align
Intterupt
	movem.l	d0-d7/a0-a4,-(sp)		save registers
	move.w	#$0010,intreq(a6)		turn off request
	bset	#IntDone1,Flag1(a5)		signal interrupt done
	addq.b	#1,frames(a5)			inc frame counter
	move.w	clxdat(a6),CollisionData(a5)	get Hardware collision data
	bsr	AudioHandler			do audio
	bsr	ModifyPlayerBase		do all player stuff
	bsr	ModifyPlayerFire		under interrupt
	bsr	PutAlienSpritePointers		convoluted? not me guv!
	bsr	UBackGround			update background
	bsr	UForeground			update foreground
	movem.l	(sp)+,d0-d7/a0-a4		restore registers	
	rte					return to main prog

**************************************************************************
*		handle player movement 
**************************************************************************
ModifyPlayerBase
	btst.b	#PlayerEnable3,flag3(a5)
	beq.s	.getspr
.Penab	btst.b	#PlayerBaseHit3,Flag3(a5)	is base hit
	beq.s	.testi
	bsr	PlayerBaseHit
	rts
.testi	btst.b	#PlayerInvincible3,flag3(a5)	is base invincible
	beq.s	.normal
	bsr	CycleBaseColor
.normal	clr.b	PbaseAnim(a5)
	bsr	GetPlayerBasePos
	moveq	#0,d0
.getspr	bsr	GetPlayerBaseSprite
	rts

**************************************************************************
*			Player Base hit
**************************************************************************
PlayerBaseHit
	moveq	#0,d0
	subq.b	#1,PlayerBaseCount(a5)
	bne.s	.gets
	move.b	PBaseAnim(a5),d0
	addq.b	#1,d0
	move.b	d0,PBaseAnim(a5)
	cmp.b	#5,d0
	beq.s	.subL
	move.b	#PBaseHitAnimSpeed,PlayerBaseCount(a5)
	bra.s	.gets

.subL	subq.b	#1,Lives(a5)			sub 1 from lives
	bne.s	.ContG				if zero Game Over
	bset.b	#GameOver2,Flag2(a5)
	bclr.b	#PlayerEnable3,Flag3(a5)
.ContG	
	bsr	PrintLives
	move.b	#80,PlayerBaseCount(a5)		make base invinc
	bset.b	#PlayerInvincible3,Flag3(a5)	player invincible
	bclr.b	#PlayerBaseHit3,flag3(a5)	player not hit
	bset.b	#PlayerFireEnable3,flag3(a5)
	move.b	#$a0,PlayerBaseColor(a5)
	move.w	#PlayerXMin,PlayerXpos(a5)	reset base Xpos
	clr.b	PBaseAnim(a5)
.gets	bsr	GetPlayerBaseSprite
.ret	rts

**************************************************************************
*		player base invincible
**************************************************************************
CycleBaseColor
	subq.b	#1,PlayerBaseCount(a5)	
	bne	.stilli				if counter zero
	move.w	#$0c0,color+50(a6)		restore color!
	bclr.b	#PlayerInvincible3,flag3(a5)	clear inv bit
	bset.b	#PlayerFireEnable3,flag3(a5)
.ret	rts
.stilli	move.b	PlayerBaseCount(a5),d0
	moveq	#0,d0
	move.b	PlayerBaseColor(a5),d0
	btst	#0,d0
	beq	.goup
.godown
	cmp.b	#$81,d0
	bne	.okd	
	bclr	#0,d0
	bra.s	.putCd
.okd	sub.b	#$10,d0
.putCd	move.b	d0,PlayerBaseColor(a5)
	lsl.w	#4,d0
	move.w	d0,color+50(a6)
	rts
.goup
	cmp.b	#$f0,d0
	bne	.oku
	bset	#0,d0
	bra.s	.putCu
.oku	add.b	#$10,d0
.putCu	move.b	d0,PlayerBaseColor(a5)
	lsl.w	#4,d0
	move.w	d0,color+50(a6)
	rts

**************************************************************************
*		get new position of player ship
**************************************************************************
GetPlayerBasePos
	btst.b	#PlayerBaseMoveEnable3,Flag3(a5)
	beq	.nomove
	move.w	Joy1dat(a6),d1
	move.w	PlayerXpos(a5),d0
	btst.l	#9,d1			move left?
	beq	.testr
	subq.w	#1,d0
	cmp.w	#PlayerXmin,d0
	bcc	.testr
	move.w	#PlayerXmin,d0
.testr	btst.l	#1,d1			move right?
	beq	.gotpos
	addq.w	#1,d0
	cmp.w	#PlayerXmax,d0
	bcs	.gotpos
	move.w	#PlayerXmax,d0
.gotpos	move.w	d0,PlayerXpos(a5)
.nomove	rts

**************************************************************************
*		put sprite control words etc for Player
**************************************************************************
GetPlayerBaseSprite
	btst.b	#PlayerEnable3,Flag3(a5)
	bne	.ok
	lea	BlankSprite,a0		If player disabled
	move.l	a0,d0			point sprites 4,5,6
	lea	CLsprite4+2(pc),a0	to blank
	bsr	PutPointerInCopperM
	bsr	PutPointerInCopperM
	bsr	PutPointerInCopperS
	rts
.ok	moveq	#0,d0
	move.b	PBaseAnim(a5),d0
	lea	PlayerBaseSpriteData,a0
	lsl.w	#6,d0				each sprite 64 bytes
	adda.w	d0,a0
	move.w	PlayerXpos(a5),d7
	move.w	#PlayerYpos,d6
	bsr	GetSpriteCW
	move.l	d5,(a0)
	moveq	#0,d0
	move.l	d0,64(a0)			sprite end words
	move.l	a0,d0
	lea	CLsprite4+2(pc),a0
	bsr	PutPointerInCopperS
	rts

**************************************************************************
*		handle player firing etc
**************************************************************************
ModifyPlayerFire
	btst.b	#PlayerEnable3,Flag3(a5)
	beq.s	.blank
	btst.b	#PlayerFireEnable3,Flag3(a5)
	bne.s	.hit
.blank	lea	BlankSprite,a0		if fire disabled then
	move.l	a0,d0
	lea	CLsprite5+2(pc),a0
	bsr	PutPointerInCopperM
	bsr	PutPointerInCopperS
	rts

.hit	btst.b	#PlayerFireHit3,flag3(a5)	do explosions stuff
	beq.s	.fire
	bsr	PlayerFireHit
.fire	btst.b	#PlayerFireGo3,flag3(a5)
	beq.s	.wait
	bsr	PlayerFireGo
	rts
.wait	move.w	PlayerXpos(a5),PlayerFireX(a5)
	move.w	#PlayerYpos,PlayerFireY(a5)
	bsr	GetJoyFire		Z set if fire pressed
	beq.s	.testb
	bset.b	#FireButton1,Flag1(a5)
	bra.s	.fireW
.testb	btst.b	#FireButton1,Flag1(a5)	test for fire off then on!!
	bclr.b	#FireButton1,Flag1(a5)
	beq.s	.fireW
	bset	#PlayerFireGo3,flag3(a5)
	addq.b	#1,PlayerFireCount(a5)
	move.w	PlayerXpos(a5),d0		Set up Audio
	lea	FireAudioData,a0
	bsr	StartSample32
	bsr	PlayerFireGo
	rts
.fireW	bsr	GetPlayerFireSprite
	rts

**************************************************************************
*		Player Fire hit invader 
**************************************************************************
PlayerFireHit
	subq.b	#1,PFHCounter(a5)
	bne	.ret
	move.b	#PFireHitAnimSpeed,PFHCounter(a5)
	move.b	PFHAnim(a5),d0
	addq.b	#1,d0
	move.b	d0,PFHAnim(a5)
	cmp.b	#4,d0
	bne.s	.ret
	bclr.b	#PlayerFireHit3,flag3(a5)
	clr.b	PFHAnim(a5)
.ret	rts

**************************************************************************
*		Player Fire moving
**************************************************************************
PlayerFireGo
	subq.b	#1,PFCounter(a5)
	bne	.getpos
	bchg.b	#0,PFAnim(a5)
	move.b	#PFireAnimSpeed,PFCounter(a5)
.getpos	subq.w	#PlayerFireSpeed,PlayerFireY(a5)
	cmp.w	#ScreenStart-10,PlayerFireY(a5)
	bcc	.fireok
	bclr.b	#PlayerFireGo3,flag3(a5)
.fireok	bsr	GetPlayerFireSprite
	rts

**************************************************************************
*		put sprite control words etc for Player fire
**************************************************************************
GetPlayerFireSprite
	moveq	#0,d0
	move.b	PFAnim(a5),d0
	lea	PlayerFireSpriteData,a0
	lsl.w	#6,d0				each sprite 64 bytes
	adda.w	d0,a0
	move.w	PlayerFireX(a5),d7
	move.w	PlayerFireY(a5),d6
	bsr	GetSpriteCW
	move.l	d5,(a0)
	moveq	#0,d0
	move.l	d0,64(a0)			sprite end words
	move.l	a0,d0			put addr in Spr Pointer
	lea	CLsprite6+2(pc),a0
	bsr	PutPointerInCopperS
	moveq	#0,d0				put player fire
	move.b	PFHanim(a5),d0			explosion sprite
	lea	PlayerFireHitSpriteData,a0	into copper etc
	lsl.w	#6,d0
	adda.w	d0,a0
	move.w	PFireHitX(a5),d7
	move.w	PFireHitY(a5),d6
	bsr	GetSpriteCW
	move.l	d5,(a0)
	moveq	#0,d0
	move.l	d0,64(a0)
	move.l	a0,d0
	lea	CLsprite5+2(pc),a0
	bsr	PutPointerInCopperS
	rts
	
**************************************************************************
*!!		put invader sprite pointers in custom regs
**************************************************************************
PutAlienSpritePointers
	lea	CLsprite0+2(pc),a0
	moveq	#3,d1
	btst.b	#AlienSpritesEnable4,Flag4(a5)
	bne	.ok
	lea	BlankSprite,a1
	move.l	a1,d0
.put1	bsr	PutPointerInCopperM
	dbf	d1,.put1		blanks if fire disabled
	rts
.ok	lea	InvSprites0(a5),a1
	btst.b	#AlienSpriteBuffer1,Flag1(a5)
	beq	.put2
	lea	InvSprites1(a5),a1
.put2	move.l	(a1)+,d0		put buffer into custom reg
	bsr	PutPointerInCopperM
	dbf	d1,.put2
	rts

*************************************************************************
*!!		update background bitplane pointers
*************************************************************************
UBackground
	move.l	BGplane1pos(a5),d0
	add.l	#80,d0
	cmp.l	BGplane1max(a5),d0	test if at max pos
	bne	.notmax1
	move.l	BGplane1min(a5),d0
.notmax1
	move.l	d0,BGplane1pos(a5)	store new pos
	lea	BgBpp1+2(pc),a0
	bsr	PutPointerInCopperS

	move.l	BGplane2pos(a5),d0
	add.l	#40,d0
	cmp.l	BGplane2max(a5),d0	test if at max pos
	bne	.notmax2
	move.l	BGplane2min(a5),d0
.notmax2
	move.l	d0,BGplane2pos(a5)	store new pos
	lea	BgBpp2+2(pc),a0
	bsr	PutPointerInCopperS
	rts

**************************************************************************
*!!	update invader screen pointers and scroll values etc
**************************************************************************
UForeGround
	move.l	BDPointer(a5),a0
	suba.w	InvOffset(a5),a0
	move.l	a0,d0
	lea	InvaderBPP+2(pc),a0
	bsr	PutPointerInCopperM
	add.l	#(256*40),d0
	bsr	PutPointerInCopperM
	add.l	#(256*40),d0
	bsr	PutPointerInCopperS
	move.b	InvScroll(a5),d0
	ext.w	d0
	move.w	d0,(InvaderScroll+2)
	rts

**************************************************************************
*!!		handle audio stuff
**************************************************************************
AudioHandler
	move.l	MemBase(a5),a0
	lea	Aud0(a6),a1
	moveq	#$10,d0			offset for audio structures
	moveq	#2,d1			new length value

	btst.b	#5,MShipStatus(a5)	is repeat sample bit set?
	bne.s	.skip0			if so then dont point next sample
	move.l	a0,(a1)			to blank
	move.w	d1,4(a1)		if sample is single shot
.skip0	add.l	d0,a1			then point to clear mem
	btst.b	#5,MShipStatus(a5)	is repeat sample bit set?
	bne.s	.skip1
	move.l	a0,(a1)			audio channels 0,1 are for mothership
	move.w	d1,4(a1)		and the THUD THUD of invaders moving
.skip1	add.l	d0,a1			works in stereo!!
	move.l	a0,(a1)
	move.w	d1,4(a1)		audio channels 2,3 are for player
	add.l	d0,a1			firing explosions etc also in stereo
	move.l	a0,(a1)			as ya move left it gets louder out
	move.w	d1,4(a1)		the left speaker. See elsewhere
	rts				for how its smeggin done!!

**************************************************************************
**************************************************************************
*		move invaders on screen
**************************************************************************
**************************************************************************

ProcessInvaders
	subq.b	#1,AnimCount(a5)
	bne	.noanim
	move.b	AnimFrames(a5),AnimCount(a5)
	bsr	SwapBuffers
	bsr	InvMoveSample
.noanim
	subq.b	#1,SpeedCount(a5)
	bne	.ret
	move.b	SpeedFrames(a5),SpeedCount(a5)
	moveq	#0,d7
	move.b	SpeedPixels(a5),d7
	move.w	Inv00X(a5),d4
	move.w	Inv00Y(a5),d5
	move.w	InvYoff(a5),d6
	move.w	d4,Inv00Xold(a5)
	move.w	d5,Inv00Yold(a5)
.npix	bsr	MoveInvaders
	dbf	d7,.npix
	move.w	d4,Inv00X(a5)
	move.w	d5,Inv00Y(a5)
	move.w	d6,InvYoff(a5)
	bsr	GetInvaderOffset
.ret	rts

**************************************************************************
*		set up audio for invaders moving
**************************************************************************
InvMoveSample
	btst.b	#5,MshipStatus(a5)
	bne	.ret
	btst.b	#BufFlag1,flag1(a5)
	beq	.ret
	move.w	Inv00X(a5),d5
	move.w	d5,d4
	moveq	#16,d0				get left pos
	lea	InvaderCols(a5),a0		of invaders
.tc1	add.w	d0,d5				get pixel pos of 
	tst.b	(a0)+				leftmost invader
	beq.s	.tc1
	add.w	#160,d4
	lea	InvaderCols+16(a5),a0			get right pos
.tc2	sub.w	d0,d4				get pixel pos of
	tst.b	-(a0)				right most invader
	beq.s	.tc2
	sub.w	#$200,d5
	sub.w	#$200,d4
	moveq	#0,d1
	moveq	#0,d2
	lea	AudioVolumeTable,a0
	lsr.w	#2,d5
	bclr.l	#0,d5
	move.b	0(a0,d5.w),d1			get left volume
	lsr.w	#2,d4
	bclr.l	#0,d4
	move.b	1(a0,d4.w),d2			get right volume
	lea	InvMoveAudioData,a0
	move.w	#$0003,dmacon(a6)		turn off Audio DMA Channel 0,1
	move.w	#300,d0
.wait	tst.b	d0				wait a bit!!
	dbf	d0,.wait
	move.w	(a0),aud0+ac_per(a6)		set up period
	move.w	(a0)+,aud1+ac_per(a6)
	move.w	(a0),aud0+ac_len(a6)		set up length
	move.w	(a0)+,aud1+ac_len(a6)
	move.l	a0,Aud0+ac_ptr(a6)		put pointers
	move.l	a0,Aud1+ac_ptr(a6)
	move.w	d1,aud0+ac_vol(a6)		put volume
	move.w	d2,aud1+ac_vol(a6)
	move.w	#$8003,dmacon(a6)		turn on DMA channels 0,1
.ret	rts

**************************************************************************
*		move invaders
**************************************************************************
MoveInvaders
	moveq	#0,d0
	move.b	MovePointer(a5),d0	get current anim byte
	lea	AnimLD(a5),a0
	adda.l	d0,a0
	move.b	(a0)+,d3		in d3
	move.b	InvDirection(a5),d0
	cmp.b	#3,d0
	bhi	MoveInvAcross		test direction of invader move
MoveInvSide
	btst	#7,d3
	beq	.moved
	subq.w	#1,d5
	sub.w	#40,d6	
	bsr	TestTBound
	bra.s	.sk1
.moved	addq.w	#1,d5
	add.w	#40,d6
	bsr	TestBBound
.sk1	subq.b	#1,movecount(a5)
	bne	.ret
	move.b	InvDirection(a5),d0
	cmp.b	#$2,d0
	bne	.gol
	move.b	#0,MovePointer(a5)
	move.b	AnimLD(a5),d3
	and.b	#$0f,d3
	move.b	d3,MoveCount(a5)
	move.b	#$4,InvDirection(a5)
	rts
.gol	move.b	#20,MovePointer(a5)
	move.b	AnimLD+20(a5),d3
	and.b	#$0f,d3
	move.b	d3,MoveCount(a5)
	move.b	#$8,InvDirection(a5)
.ret	rts

MoveInvAcross
	btst	#7,d3
	beq	.testr
	subq.w	#1,d4
	bsr	TestLBound
.testr	btst	#6,d3
	beq	.testu
	addq.w	#1,d4
	bsr	TestRBound
.testu	btst	#5,d3
	beq	.testd
	subq.w	#1,d5
	sub.w	#40,d6
	bsr	TestTBound
.testd	btst	#4,d3
	beq	.done
	addq.w	#1,d5
	add.w	#40,d6
	bsr	TestBBound
.done	subq.b	#1,MoveCount(a5)
	bne	.ret
	move.b	(a0),d3	
	cmp.b	#$ff,d3
	beq	.loops		branch if end of structure
	and.b	#$0f,d3
	move.b	d3,Movecount(a5)
	addq.b	#1,Movepointer(a5)
.ret	rts
	
.loops	move.b	InvDirection(a5),d0
	cmp.b	#$8,d0
	beq	.gol
.gor	move.b	#0,MovePointer(a5)
	move.b	AnimLD(a5),d3
	and.b	#$0f,d3
	move.b	d3,MoveCount(a5)
	rts
.gol	move.b	#20,MovePointer(a5)
	move.b	AnimLD+20(a5),d3
	and.b	#$0f,d3
	move.b	d3,MoveCount(a5)
	rts

**************************************************************************
*		test for top boundary hit
**************************************************************************
TestTBound
	cmp.w	#InvaderYstart,d5
	bhs	.ret
	move.w	#InvaderYstart,d5
	move.w	#(InvaderYstart*40),d6
.ret	rts

**************************************************************************
*		test for bottom boundary hit ie Invader Landed
**************************************************************************
TestBBound
	cmp.w	InvMaxY(a5),d5
	blo	.ret
	bset	#InvLanded2,Flag2(a5)
	move.w	InvMaxY(a5),d5
	move.w	d5,d6
	mulu	#40,d6
.ret	rts

**************************************************************************
*		test for left edge hit by invader
**************************************************************************
TestLBound
	cmp.w	InvMinX(a5),d4
	bne	.ret
	move.b	#39,MovePointer(a5)
	move.b	AnimLD+39(a5),d3
	and.b	#$7f,d3
	addq.b	#1,d3
	move.b	d3,MoveCount(a5)
	move.b	#$2,InvDirection(a5)
.ret	rts

**************************************************************************
*		test for right edge hit by invader
**************************************************************************
TestRBound
	cmp.w	InvMaxX(a5),d4
	bne	.ret
	move.b	#19,MovePointer(a5)
	move.b	AnimLD+19(a5),d3
	and.b	#$7f,d3
	addq.b	#1,d3
	move.b	d3,MoveCount(a5)
	move.b	#$1,InvDirection(a5)
.ret	rts

**************************************************************************
*	wipe out buildings where invaders touch!!
**************************************************************************
WipeBuildings
	move.l	BDBuildings(a5),a0
	suba.w	InvOffset(a5),a0
	lea	BuildingsScreen+6,a1

	moveq	#8,d0
	move.w	d0,bltamod(a6)		set up modulos
	move.w	d0,bltbmod(a6)
	move.w	d0,bltcmod(a6)
	move.w	d0,bltdmod(a6)
	move.b	InvScroll(a5),d0
	ext.w	d0
	lsl.w	#6,d0
	lsl.w	#6,d0
	move.w	d0,bltcon1(a6)		set up shift value
	or.w	#$0f02,d0		minterm=$01
	move.w	d0,bltcon0(a6)		set a shift etc

	move.l	a1,bltdpt(a6)		buildings grafix
	move.l	a1,bltcpt(a6)		buildings grafix
	move.l	a0,bltapt(a6)		invader grafix plane1
	adda.w	#(256*40),a0
	move.l	a0,bltbpt(a6)		invader grafix plane2
	move.w	#(16*64+16),bltsize(a6)		width=15 h=16
	btst	#14,dmaconr(a6)			waits for blitter
.wb1	btst	#14,dmaconr(a6)			to finish
	bne	.wb1

	move.l	a1,bltdpt(a6)		buildings grafix
	move.l	a1,bltcpt(a6)		buildings grafix
	adda.w	#(256*40),a0
	move.l	a0,bltapt(a6)		invader grafix plane3
	move.l	a0,bltbpt(a6)		point a and b to same
	move.w	#(16*64+16),bltsize(a6)
	btst	#14,dmaconr(a6)			waits for blitter
.wb2	btst	#14,dmaconr(a6)			to finish
	bne	.wb2
	move.w	#0,bltcon1(a6)
	rts

*************************************************************************
*	wait for line 50
*************************************************************************
WaitLine50
	btst.b	#0,vposr+1(a6)		test for upper part of display
	bne.s	WaitLine50
	move.w	Vhposr(a6),d0
	and.w	#$fe00,d0		test for $32,xx
	cmp.w	#$3800,d0
	bne.s	WaitLine50
	rts

************************************************************************
*!!		Draw Defences into screen
************************************************************************
BlitDefences
	lea	BuildingData,a0
	lea	BuildingsScreen+8,a1
	move.w	#0,bltamod(a6)			set up blitter
	move.w	#36,bltdmod(a6)
	move.w	#$09f0,bltcon0(a6)		d=a
	moveq	#3,d0
.loop	move.l	a0,bltapt(a6)
	move.l	a1,bltdpt(a6)
	move.w	#(16*64+2),bltsize(a6)
	btst.b	#6,dmaconr(a6)
.wb1	btst.b	#6,dmaconr(a6)
	bne.s	.wb1
	addq.l	#8,a1
	dbf	d0,.loop
	rts

*************************************************************************
*!!		Wait for end of display
*************************************************************************
WaitInterrupt
	btst.b	#IntDone1,Flag1(a5)		waits for interrupt
	beq	WaitInterrupt			to happen
	bclr.b	#IntDone1,Flag1(a5)		if it doesnt get lock out!
	rts

**************************************************************************
*		Set up game variables DMA screens etc
**************************************************************************
SetUpGame
	bsr	SetUpVariables
	moveq	#20,d0
.wait	bsr	waitInterrupt
	dbf	d0,.wait
	bsr	SetUpPlayer
	bsr	GetNewLevel

	rts

**************************************************************************
*		Set up game variables
**************************************************************************
SetUpVariables
	moveq	#0,d0
	move.b	d0,Flag1(a5)			clear flags
	move.b	d0,Flag2(a5)
	move.b	d0,Ystartoffset(a5)
	move.b	#startwave,Wave(a5)
	move.l	d0,Score(a5)			clear score
	bsr	PrintScore
	move.b	#4,Lives(a5)
	bsr	PrintLives
	rts

**************************************************************************
*		Set up Player etc
**************************************************************************
SetUpPlayer
	move.w	#PlayerXMin,PlayerXpos(a5)
	move.b	#$a0,playerbasecolor(a5)
	bclr.b	#PlayerFireEnable3,flag3(a5)
	bset.b	#PlayerEnable3,flag3(a5)
	bset.b	#PlayerBaseMoveEnable3,flag3(a5)	
	move.w	#PlayerXMin,PlayerXpos(a5)
	rts

**************************************************************************
*			Get a New Level
**************************************************************************
GetNewLevel
	bsr	ClearBuffers
	bsr	SetUpLevelData
	bsr	SetUpRCcount
	bsr	GetInvStartPos
	bsr	GetInvadersFiring
	bsr	CalcInvBounds
	bsr	SetUpAnimSpeed
	bsr	BlitDefences
	bsr	PrintInvaders
	bsr	SwapBuffers
	bsr	SetUpAlienSprites
	bsr	ResetVariables
	rts

**************************************************************************
*		set up new level variables etc etc
**************************************************************************
ResetVariables
	moveq	#0,d0
	move.b	d0,InvFireStruct(a5)
	move.b	d0,InvFireStruct+12(a5)	clear inv fire active flags
	move.b	d0,InvFireStruct+24(a5)
	move.b	d0,InvFireStruct+36(a5)
	move.b	d0,PFHanim(a5)
	move.b	d0,PlayerFireCount(a5)
	move.w	d0,MshipXpos(a5)
	move.b	d0,flag2(a5)

	bset.b	#AlienSpritesEnable4,flag4(a5)	alien sprites on!!
	move.b	#%00000100,MShipStatus(a5)	mship active
	bset.b	#PlayerFireEnable3,flag3(a5)
	move.w	#$0c0,color+50(a6)
	rts

**************************************************************************
*	set up alien sprites etc
**************************************************************************
SetUpAlienSprites
	move.b	#%00000100,MshipStatus(a5)
	clr.b	MshipAnim(a5)
	bset.b	#AlienSpritesEnable4,flag4(a5)
	rts

**************************************************************************
*			Set Up the new level data
**************************************************************************
SetUpLevelData
	moveq	#0,d0
	move.b	wave(a5),d0		attack wave number
	lea	LevelsData,a0		address of levels data
	lsl.w	#8,d0			multiply by 256, length of each level data
	adda.l	d0,a0			get addr of new wave
	moveq	#63,d0			copy 256 bytes = 64 longwords
	lea	InvadersLD(a5),a1
	move.l	a1,a2
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy		copy level data to vars area

	lea	InvaderLevelData,a3	addr of invader structures
	lea	InvaderStructures,a0	look up table
	move.w	#159,d2			insert relevant structures
.copy2	move.l	a0,a1			in invader table
	moveq	#0,d0
	move.b	(a2)+,d0
	lsl.w	#4,d0			multiply by 16 to
	adda.w	d0,a1			get relevant structure
	moveq	#12,d1
.cop13	move.b	(a1)+,(a3)+		copy 13 bytes	last 3 constant
	dbf	d1,.cop13
	addq.l	#3,a3			add 3 to dest pointer
	dbf	d2,.copy2
	rts

**************************************************************************
*		set up row and column counters
**************************************************************************
SetUpRCcount
	lea	InvaderRows(a5),a0	set up row counters
	lea	InvaderLevelData,a1
	moveq	#9,d1
	moveq	#0,d3
.lhr	moveq	#15,d0
	moveq	#0,d2
.lrt	tst.b	(a1)			test if enabled
	beq	.noInvr
	addq.b	#1,d2
	addq.b	#1,d3
.noInvr	adda.w	#16,a1			get next structure along
	dbf	d0,.lrt
	move.b	d2,(a0)+
	dbf	d1,.lhr	
	move.b	d3,NumberInvaders(a5)

	lea	InvaderCols(a5),a0	set up column counters
	lea	InvaderLevelData,a1
	moveq	#15,d0
.lwc	moveq	#9,d1
	move.l	a1,a2
	moveq	#0,d2
.lhc	tst.b	(a2)
	beq	.noInvC
	addq.b	#1,d2
.noInvC	adda.w	#(16*16),a2		get next structure down
	dbf	d1,.lhc
	adda.w	#16,a1			next structure along
	move.b	d2,(a0)+
	dbf	d0,.lwc
	rts

**************************************************************************
*	get invader starting position
**************************************************************************
GetInvStartPos
	moveq	#0,d0			get x and y starting
	move.b	StartPosLD(a5),d0	values for invader screen
	add.w	#$0280,d0
	move.w	d0,Inv00X(a5)
	moveq	#0,d0
	move.b	StartPosLD+1(a5),d0
	add.w	#InvaderYstart,d0
	moveq	#0,d1
	move.b	Ystartoffset(a5),d1
	add.w	d1,d0
	move.w	d0,Inv00Y(a5)
	mulu.w	#40,d0
	move.w	d0,InvYoff(a5)
	bsr	GetInvaderOffset
	rts	

*************************************************************************
*		Set up which invaders firing
*************************************************************************
GetInvadersFiring
	lea	(InvaderLevelData+(9*16*16)),a4	get to last invader in
	move.l	#(16*16),d0			first column
	moveq	#16,d1
	moveq	#15,d7
.loopC	move.l	a4,a0
	moveq	#9,d6
.testA	btst.b	#0,(a0)			is invader enabled
	beq.s	.InvNA			if not skip
	bset.b	#2,(a0)			set fire bit
	moveq	#0,d6			stop column loop
.InvNA	suba.l	d0,a0			get to next inv up
	dbf	d6,.testA
.nextC	adda.l	d1,a4			get to next column along
	dbf	d7,.loopC
	rts

*************************************************************************
*		Set up anim and speed stuff
*************************************************************************
SetUpAnimSpeed
	moveq	#0,d0
	move.b	d0,MovePointer(a5)
	move.b	d0,SpeedUpCount(a5)
	lea	SpeedLD(a5),a0
	move.b	(a0)+,d0
	move.b	d0,d1
	lsr.b	#4,d0
	subq.b	#1,d0
	move.b	d0,SpeedPixels(a5)
	and.b	#$0f,d1
	move.b	d1,Speedframes(a5)
	move.b	d1,SpeedCount(a5)
	move.b	(a0),AnimCount(a5)
	move.b	(a0)+,AnimFrames(a5)
	move.b	(a0),InvadersCmp(a5)

	move.b	AnimLD(a5),d0
	and.b	#$0f,d0
	move.b	d0,MoveCount(a5)
	move.b	#$4,InvDirection(a5)	start going right
	rts
	
**************************************************************************
*		Calculate Boundaries of invader movement
**************************************************************************
CalcInvBounds
	moveq	#16,d0					get left pos
	lea	InvaderCols(a5),a0			of invaders
	move.w	#InvMinXabs+16,d1
.tc1	sub.w	d0,d1
	tst.b	(a0)+
	beq.s	.tc1
	move.w	d1,InvMinX(a5)

	lea	InvaderCols+16(a5),a0			get right pos
	move.w	#InvMaxXabs-16,d1			of invaders
.tc2	add.w	d0,d1
	tst.b	-(a0)
	beq.s	.tc2
	move.w	d1,InvMaxX(a5)

	lea	InvaderRows+10(a5),a0			get bottom Y
	move.w	#(ScreenStart+248-160)-16,d1		pos of Invaders
.tr1	add.w	d0,d1
	tst.b	-(a0)
	beq.s	.tr1
	move.w	d1,InvMaxY(a5)
	rts

**************************************************************************
*!!		Print the invaders into B1 and B2
**************************************************************************
PrintInvaders
	move.w	#38,bltdmod(a6)			set up blitter
	move.w	#0,bltamod(a6)
	move.l	#$09f00000,bltcon0(a6)		D=A ,no specials,shifts
	move.w	#(16*64+1),d3			blitsize h=16 w=1

	move.l	B1Grafix(a5),a0		addr of grafix dest.
	lea	InvaderLevelData,a1	invader structure table
	lea	InvaderGrafix,a2	addr of grafix source
	moveq	#16,d4			length of invader structures
	moveq	#(14-8),d5		bit to test for blit finish
	move.w	#159,d0			Number of invaders
.nextI	move.l	a2,a3
	move.l	a0,a4
	moveq	#0,d1
	move.b	1(a1),d1		get anim number
	mulu.w	#192,d1			2 anims = 2*96 =192 bytes
	adda.w	d1,a3			get addr of grafix source
	adda.w	14(a1),a4		get addr of grafix dest

	move.l	a3,bltapt(a6)
	moveq	#5,d1			copy 6 planes ie 2 buffers

.loop	move.l	a4,bltdpt(a6)
	move.w	d3,bltsize(a6)		start Blit
	btst	d5,dmaconr(a6)		waits for blitter
.wb	btst	d5,dmaconr(a6)		to finish
	bne	.wb
	adda.w	#(256*40),a4		get next plane
	dbf	d1,.loop
	adda.w	d4,a1
;	bsr	WaitInterrupt
	dbf	d0,.nextI
	rts

**************************************************************************
*		set up the game attract sequence
**************************************************************************
SetUpGameAttract
;	move.w	#$000f,dmacon(a6)	all audio off
	moveq	#0,d0
	move.b	d0,Flag1(a5)	switch off all game functions
	move.b	d0,Flag2(a5)	such as invader fire etc etc
	move.b	d0,Flag3(a5)
	move.b	d0,flag4(a5)
	move.b	d0,MshipStatus(a5)

	move.b	d0,InvScroll(a5)
	move.w	#((invaderYstart*40)+80),InvOffset(a5)

	bsr	ClearBuildings
	bsr	ClearBuffers
.GAloop
	bsr	PrintGAScreen1

	move.w	#(50*10),d0
.wait1	bsr	WaitInterrupt
	bsr	GetJoyFire
	bne.s	.wait1
.game	rts

**************************************************************************
*		print game attract screen
**************************************************************************
PrintGAScreen1
	lea	Title,a0
	move.l	BDGrafix(a5),a1			destination addr
	adda.w	#((50*40)+8),a1
	move.w	#0,bltamod(a6)			set up blitter
	move.w	#16,bltdmod(a6)
	move.w	#$09f0,bltcon0(a6)		d=a
	moveq	#2,d0
	move.l	a0,bltapt(a6)
.loop	move.l	a1,bltdpt(a6)
	move.w	#(15*64+12),bltsize(a6)		h=15,w=12
	btst.b	#6,dmaconr(a6)
.wb1	btst.b	#6,dmaconr(a6)
	bne.s	.wb1
	adda.w	#(40*256),a1
	dbf	d0,.loop

	lea	GameAttractText,a1
	move.l	BDGrafix(a5),a0
	add.l	#(40*256*2),a0
	moveq	#40,d7
	bsr	PrintText
	bsr	PrintText


	rts

**************************************************************************
*!!		Initialise once only stuff
**************************************************************************
InitialiseAll
	move.w	#$8640,dmacon(a6)	enable blitter+nasty
	move.w	#$00ff,adkcon(a6)	Audio,No modulation
	moveq.l	#$ff,d0			blitter constants
	move.l	d0,bltafwm(a6)
	move.w	#0,bltcon1(a6)
	bsr	InitialiseMemory
	bsr	InitialiseVariables
	bsr	InitRandom
	bsr	InitSpriteBuffers
	bsr	InitInvaderTable
	bsr	InitialiseScreens
	bsr	InitialisePanel
	bsr	BlankSprites
	bsr	InitColors
	bsr	StartDMA
	rts

**************************************************************************
*!!		Initialise Memory etc
**************************************************************************
InitialiseMemory
	move.l	Membase(a5),a0			get allocmem address
	moveq	#0,d0
	adda.w	#(256*40),a0
	move.l	a0,B1Grafix(a5)		buffer 1, plane 1
	adda.w	#(256*40*3),a0		buffer 2, plane 1
	move.l	a0,B2Grafix(a5)

	move.l	B2Grafix(a5),a0		set up Invader buffer pointers
	adda.w	#((InvaderYstart*40)+78),a0
	move.l	a0,B2pointer(a5)
	move.l	B1Grafix(a5),a0
	adda.w	#((InvaderYstart*40)+78),a0
	move.l	a0,B1pointer(a5)

	move.l	B2Grafix(a5),a0		set up  buffer pointers
	adda.w	#((256*40)+78+6),a0
	move.l	a0,B2Buildings(a5)
	move.l	B1Grafix(a5),a0
	adda.w	#((256*40)+78+6),a0
	move.l	a0,B1Buildings(a5)

	lea	B1Grafix(a5),a0		set up Display and Modify
	lea	BDGrafix(a5),a1		pointers
	moveq	#5,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	
	rts

**************************************************************************
*!!		Initialise random generator
**************************************************************************
InitRandom
	lea	RandStart(pc),a0
	move.l	a0,RandAdrMin(a5)
	move.l	a0,RandAdrPtr(a5)
	lea	RandFinish(pc),a0
	move.l	a0,RandAdrMax(a5)
	rts	

**************************************************************************
*!!		Initialise sprite data buffer for Spr23456
**************************************************************************
InitSpriteBuffers
	lea	SprDataBuffer0,a0
	move.w	#(16*64+33),d0
	bsr	BlitClear		clear sprite data buffers

	lea	InvSprites0(a5),a1
	moveq	#7,d0
.loop	move.l	a0,(a1)+
	adda.w	#132,a0			length of each sprite data list
	dbf	d0,.loop
	bsr	BlankSprites
	rts				cos we dont use it!!

**************************************************************************
*		Initialise Variables
**************************************************************************
InitialiseVariables
	moveq	#0,d0
	move.b	d0,frames(a5)
	move.l	d0,score(a5)
	move.l	d0,scratch(a5)
	move.b	#PFireanimspeed,PFCounter(a5)
	rts

**************************************************************************
*!!		Initialise Panel, Backdrops etc
**************************************************************************
InitialiseScreens
	lea	BGGrafix,a0		Data for stars
	move.l	a0,a1
	move.l	a0,BGPlane1pos(a5)	current pos
	move.l	a0,BGPlane1min(a5)
	adda.w	#(512*40),a0		512 lines scrolled before
	move.l	a0,BGPlane1max(a5)	restarting
	adda.w	#20,a1			2nd screen offset Can be altered
	move.l	a1,BGPlane2pos(a5)
	move.l	a1,BGPlane2min(a5)
	adda.w	#(512*40),a1
	move.l	a1,BGPlane2max(a5)
	bsr	UBackground		puts BG pointers in copper

;	lea	BGGround,a1		set up MoonScape
;	move.l	a1,d0
;	lea	StaticBGBpp+2(pc),a0
;	bsr	PutPointerinCopperM
;	add.l	#(40*40),d0
;	bsr	PutPointerinCopperS

	lea	BuildingsScreen,a1	set up defences screen
	move.l	a1,d0
	lea	BuildingsBPP+2(pc),a0
	bsr	PutPointerInCopperS
	bsr	ClearBuildings

	move.l	Membase(a5),d0
	lea	InvaderBPP+2(pc),a0
	bsr	PutPointerInCopperM
	bsr	PutPointerInCopperM
	bsr	PutPointerInCopperS

	rts

**************************************************************************
*!!		point all sprite pointers to blank
**************************************************************************
BlankSprites
	lea	BlankSprite,a0		initialise all sprites
	move.l	a0,d0			to a blank!!
	lea	CLSprite0+2(pc),a0
	moveq	#7,d1
.loop	bsr	PutPointerInCopperM
	dbf	d1,.loop
	rts

**************************************************************************
*!!			Initialise Score Panel
**************************************************************************
InitialisePanel
	lea	PanelBPP+2(pc),a0	Put panel addr in copper
	lea	Panel1(pc),a1
	move.l	a1,d0
	bsr	PutPointerInCopperM
	add.l	#(25*40),d0		get addr of next plane
	bsr	PutPointerInCopperS
	lea	Panel1+(25*40),a0	print text into panel
	lea	PanelText,a1
	moveq	#40,d7
	bsr	PrintText
	bsr	PrintText
	bsr	PrintText
	moveq	#0,d0
	move.b	d0,lives(a5)
	bsr	PrintLives
	move.l	d0,HighScore(a5)
	move.l	d0,Scratch(a5)
	move.l	#$880,Score(a5)
	bsr	PrintScore
	move.l	#0,Score(a5)
	move.l	#$10250,HighScore(a5)
	bsr	PrintScore
	rts

************************************************************************
*!!		Initialise InvaderLevelData table
************************************************************************
InitInvaderTable
	lea	InvaderLevelData,a0	addr of InvaderStructure table
	moveq	#0,d4			Put constants in Invader table
	moveq	#0,d0
	moveq	#9,d3			no. Invaders high
.looph	moveq	#15,d2			no. Invaders wide
.loopw	adda.w	#13,a0			get to constant part
	move.b	d0,(a0)+		invaders number
	move.w	d4,(a0)+		offset to print pos	
	addq.b	#1,d0
	addq.w	#2,d4
	dbf	d2,.loopw
	add.w	#((15*40)+8),d4
	dbf	d3,.looph
	rts

**************************************************************************
*		Initialise all colors 
**************************************************************************
InitColors
	moveq	#31,d1
	lea	Palette,a1
	lea	color(a6),a0
.ic	move.w	(a1)+,(a0)+
	dbf	d1,.ic
	rts

**************************************************************************
*		Initialise all DMA stuff
**************************************************************************
StartDMA
	move.w	#-2,bpl1mod(a6)			set up display constants
	move.w	#-2,bpl2mod(a6)
	move.w	#$0030,ddfstrt(a6)
	move.w	#$00d0,ddfstop(a6)
	move.w	#$2c81,diwstrt(a6)
	move.w	#$24c1,diwstop(a6)
	move.w	#$3c30,clxcon(a6)		collisions etc

	lea	GameCopper(pc),a0		get copper address
	move.l	a0,cop1lc(a6)			write to cop loc reg
	move.w	d0,copjmp1(a6)			strobe copper jump addr
	lea	Intterupt(pc),a0		store addr of interrupt
	move.l	a0,$6c.w			routine in Level 3 vector
	move.w	#$c010,intena(a6)		enable interrupt
	move.w	#$87e0,dmacon(a6)		DMA enable Yeah!

	rts

**************************************************************************
*!!	get offset for invaderBPP and scroll value
**************************************************************************
GetInvaderOffset
	move.w	Inv00X(a5),d0
*	subq.w	#1,d0
	move.b	d0,d1
	and.b	#$f0,d0			mask out scroll value
	lsr.w	#3,d0
	add.w	InvYoff(a5),d0
	move.w	d0,InvOffset(a5)
	and.b	#$0f,d1			get scroll value 0-f
	move.b	d1,InvScroll(a5)
	rts

**************************************************************************
*!!		swap buffer being displayed
**************************************************************************
SwapBuffers
	lea	BMGrafix(a5),a0		swaps BM and BD pointers
	lea	BDGrafix(a5),a1
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
	bchg.b	#BufFlag1,Flag1(a5)	change flag bit!!
	rts

**************************************************************************
*!!		clears contiguous area of memory using blitter
**************************************************************************
; On entry	a0.l	pointer to mem to clear
;		d0.w	blit size  Heit*64+WidthInWords
BlitClear
	move.w	#0,bltdmod(a6)
	move.l	a0,bltdpt(a6)
	move.l	#$01000000,bltcon0(a6)		D=0 ,no specials
	move.w	d0,bltsize(a6)
	btst	#14,dmaconr(a6)			waits for blitter
.wb	btst	#14,dmaconr(a6)			to finish
	bne	.wb
	rts

**************************************************************************
*!!		Clear Buffer1 and Buffer2 using blitter
**************************************************************************
ClearBuffers
	move.l	MemBase(a5),a0
	move.w	#(896*64+40),d0		clears 7*256*20 words
	bsr	BlitClear
	rts

**************************************************************************
*!!		Clear Buildings Screen using blitter
**************************************************************************
ClearBuildings
	lea	BuildingsScreen,a0
	move.w	#(16*64+20),d0		h=16, w=20 words
	bsr	BlitClear
	rts

**************************************************************************
*!!		Randomise the random counter uses frame count
**************************************************************************
Randomise
	moveq	#0,d0
	move.b	frames(a5),d0
	move.l	RandAdrMin(a5),a0
	adda.l	d0,a0
	move.l	a0,RandAdrPtr(a5)
	rol.b	#4,d0
	eor.b	d0,Random(a5)
	rts

**************************************************************************
*!!		get a new random number in d0
**************************************************************************
GetRandom
	move.l	RandAdrPtr(a5),a0
	addq.l	#1,a0
	move.b	(a0),d0
	rol.b	#1,d0
	eor.b	d0,Random(a5)
	move.l	a0,RandAdrPtr(a5)
	move.b	Random(a5),d0
	rts

**************************************************************************
*		start sample playing channels 0,1
**************************************************************************
;entry	d0.w  pixel position of sound for Stereo
;	a0.l  pointer to sample data
StartSample01
	move.w	#$0003,dmacon(a6)	turn off Audio DMA Channel 0,1
	move.w	#300,d1
.wait	tst.b	d1			wait a bit!!
	dbf	d1,.wait
	move.w	(a0),aud0+ac_per(a6)		set up period
	move.w	(a0)+,aud1+ac_per(a6)
	move.w	(a0),aud0+ac_len(a6)		set up length
	move.w	(a0)+,aud1+ac_len(a6)
	move.l	a0,Aud0+ac_ptr(a6)		put pointers
	move.l	a0,Aud1+ac_ptr(a6)
	bsr	GetAudioVolume
	move.w	d1,aud0+ac_vol(a6)		put volume
	move.w	d2,aud1+ac_vol(a6)
	move.w	#$8003,dmacon(a6)	turn on DMA channels 0,1
	rts

**************************************************************************
*		start sample playing channels 3,2
**************************************************************************
;entry	d0.w  pixel position
;	a0.l  pointer to sample data
StartSample32
	move.w	#$000c,dmacon(a6)	turn off Audio DMA Channel 0,1
	move.w	#300,d1
.wait	tst.b	d1			wait a bit!!
	dbf	d1,.wait
	move.w	(a0),aud3+ac_per(a6)		set up period
	move.w	(a0)+,aud2+ac_per(a6)
	move.w	(a0),aud3+ac_len(a6)		set up length
	move.w	(a0)+,aud2+ac_len(a6)
	move.l	a0,Aud3+ac_ptr(a6)		put pointers
	move.l	a0,Aud2+ac_ptr(a6)
	bsr	GetAudioVolume
	move.w	d1,aud3+ac_vol(a6)		put volume
	move.w	d2,aud2+ac_vol(a6)
	move.w	#$800c,dmacon(a6)	turn on DMA channels 0,1
	rts

*************************************************************************
*		get volumes for paticular position on screen
*************************************************************************
;	entry; 	d0-pixel pos		trashes a0
;	exit	d1 left volume
;		d2 right volume
GetAudioVolume
	moveq	#0,d1
	moveq	#0,d2
	lea	AudioVolumeTable,a0
	lsr.w	#2,d0
	bclr.l	#0,d0
	adda.w	d0,a0
	move.b	(a0)+,d1
	move.b	(a0),d2
	rts

**************************************************************************
*!! 		Routine to read joystick fire button
**************************************************************************
GetJoyFire
	btst.b	#7,PortA	exit	Z set if fire
	rts				Z reset if no fire

**************************************************************************
*!!		Get sprite control words from x,y
**************************************************************************
;input 	d6.w  Y position	exit:  d5.l control words 
;	d7.w  X position	trashs d0

GetSpriteCW
	moveq	#0,d5			Get sprite control words
	move.w	d6,d0
	add.w	#15,d0			get vstop ie add sprite height
	lsl.w	#8,d6			high bit in extend
	bcc	.nohb			this routine inefficient see
	bset.l	#2,d5			version on ORBIT for better method
.nohb	lsr.w	#1,d7			low bit in extend
	bcc	.nolb
	bset.l	#0,d5
.nolb	swap	d5
	or.w	d7,d5
	or.w	d6,d5
	swap	d5
	lsl.w	#8,d0			vstop high bit in extend
	bcc	.nohbs
	bset.l	#1,d5
.nohbs	or.w	d0,d5
	rts

*************************************************************************
*!!		Put a longword pointer in copperlist
*************************************************************************
PutPointerInCopperM
;		entry:	d0.l pointer
;			a0.l address of Low word in copper
;		exit	d0.l as entry
;			a0.l points to next Low if in sequence!
	move.w	d0,(a0)
	addq	#4,a0
	swap	d0
	move.w	d0,(a0)
	addq	#4,a0
	swap	d0
	rts

*************************************************************************
*!!		Put a longword pointer in copperlist
*************************************************************************
PutPointerInCopperS
;		entry:	d0.l pointer	
;			a0.l address of Low word in copper
;		exit	d0.l swapped
;			a0.l as entry plus 4
	move.w	d0,(a0)
	addq	#4,a0
	swap	d0
	move.w	d0,(a0)
	rts

**************************************************************************
*!!		Simple Text printing routine
**************************************************************************
;On entry	a0.l address of screen bitplane		trashs:	d012
;		a1.l address of text				a23
;		d7.l screen width in bytes
;On Exit	a1.1 points to byte after text null

PrintText
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a1)+,d0	x start in bytes +128 for Y high bit
	move.b	(a1)+,d1	y start in pixels
	mulu	d7,d1		get offset from screen start
	btst	#7,d0
	beq	.ok
	swap	d7
	add.l	d7,d1		add 256 scan lines
	swap	d7
	bclr	#7,d0
.ok	add.l	d0,d1
	move.l	a0,d2		preserve a0
	add.l	d1,d2		address to print text at
.nextchar
	lea	AsciiData(pc),a3	addr of Ascii BP data
	move.l	d2,a2		a2 address to put char
	moveq	#0,d0
	move.b	(a1)+,d0
	beq	.ret		Null terminates text
	sub.b	#32,d0
	beq	.skip		non destructive space character
	lsl.w	#3,d0
	adda.w	d0,a3
	moveq	#7,d1
.nextL	move.b	(a3)+,(a2)	put 8 bytes of character into screen
	add.l	d7,a2
	dbf	d1,.nextL
.skip	addq.l	#1,d2
	bra	.nextchar
.ret	rts

**************************************************************************
*!!		add value to score
**************************************************************************
;entry d0.w BCD value to add to score allows +9999 in one go

IncrementScore
	andi.b	#$0f,ccr		clear Xtend flag Not a good way
	move.w	d0,scratch+2(a5)	of doing it! use sub  d1,d1 or similar
	lea	Score+4(a5),a0		anyway all my scores are held
	lea	Scratch+4(a5),a1	in BCD -Binary Coded Decimal
	abcd.b	-(a1),-(a0)		which is easy to convert for printing
	abcd.b	-(a1),-(a0)		without loadsa Divide by 10 stuff
	abcd.b	-(a1),-(a0)
	abcd.b	-(a1),-(a0)
	bsr	PrintScore
	rts

**************************************************************************
*!!		Print Score and High if high score is current
**************************************************************************
PrintScore
	move.l	Score(a5),d1
	move.l	HighScore(a5),d2
	cmp.l	d2,d1
	ble	.nohigh
	move.l	d1,HighScore(a5)
	move.l	d1,d2
.nohigh	lea	PanelScore+1+5,a3	addr of score last digit
	lea	(AsciiData+(16*8)),a4	addr of 0-9 data
	moveq	#40,d0			Screen width
	bsr	PrintIt			print score
	lea	PanelHigh+1+5,a3
	move.l	d2,d1
	bsr	PrintIt			print the high score
	rts
PrintIt
	moveq	#5,d3			No. of chars
.loop	move.l	d1,d4
	move.l	a4,a0			save addr of 0-9 data
	move.l	a3,a1
	and.w	#$000f,d4		get BCD
	lsl.b	#3,d4			times by 8
	add.w	d4,a0			get addr of data
	moveq	#7,d7			Print Char
.putB	move.b	(a0)+,(a1)
	adda.w	d0,a1
	dbf	d7,.putB
	subq.l	#1,a3
	lsr.l	#4,d1			get next digit in BCD
	dbf	d3,.loop
	rts

**************************************************************************
*!!			Print Number of Lives
**************************************************************************
PrintLives
	moveq	#0,d0
	move.b	Lives(a5),d0
	cmp.b	#9,d0			dont print higher than 9 lives
	ble	.ok			dogs 'n' cats you see??!!??
	moveq	#9,d0
.ok	lea	PanelLives+1,a0
	lea	(AsciiData+(16*8)),a1
	lsl.b	#3,d0
	adda	d0,a1
	moveq	#7,d1
	moveq	#40,d2
.loop	move.b	(a1)+,(a0)
	adda	d2,a0
	dbf	d1,.loop
	rts


RandFinish

**************************************************************************
***********************    Variables	********************************** 
**************************************************************************

		RSReset
Flag1		rs.b	1	Flag registers for game
Flag2		rs.b	1	
Flag3		rs.b	1
Flag4		rs.b	1
Random		rs.b	1	random number
Lives		rs.b	1	number of lives left
Wave		rs.b	1	current attack wave-1, ie starts at 0
Frames		rs.b	1	counter for frames
InvScroll	rs.b	1	scroll value for Invader PF 0-f
AnimCount	rs.b	1	counter
AnimFrames	rs.b	1	how many frames before swap buffers?
SpeedCount	rs.b	1	counter
SpeedFrames	rs.b	1	how many frames before moving?
SpeedPixels	rs.b	1	how many pixels to move?
SpeedUpCount	rs.b	1
MoveCount	rs.b	1
NumberInvaders	rs.b	1	Number of Invaders on screen
InvadersCmp	rs.b	1	number of inv before next speedup
InvDirection	rs.b	1	direction of invader movement 8L 4R 2LS 1RS
MovePointer	rs.b	1	pointer to how far in structure
PlayerBaseCount	rs.b	1	counter for player
PBaseAnim	rs.b	1	animation number of base
PlayerBaseColor	rs.b	1
PFCounter	rs.b	1	counter for player fire animation
PFAnim		rs.b	1	number of fire anim
PFHCounter	rs.b	1
PFHAnim		rs.b	1
PlayerFireCount	rs.b	1	counts number of player missiles fired
MShipStatus	rs.b	1	mothership stuff
MShipAnim	rs.b	1	animation number for mship
MShipCount	rs.b	1	mothership move counter
MshipCmax	rs.b	1	mothership move counter rest value
Ystartoffset	rs.b	1
InvaderRows	rs.b	10
InvaderCols	rs.b	16


PlayerXpos	rs.w	1	X position of player ship
PlayerFireX	rs.w	1	co-ords of player missile
PlayerFireY	rs.w	1
PFireHitX	rs.w	1
PFireHitY	rs.w	1
MShipXpos	rs.w	1	x position of mothership
MshipAdd	rs.w	1	number to add to Xpos
Inv00X		rs.w	1	X value of Invader 0,0 +$0200
Inv00Y		rs.w	1	Y value of Invader 0,0
Inv00Xold	rs.w	1	last frames values of above!
Inv00Yold	rs.w	1
InvYoff		rs.w	1	Y offset = inv00Y*40
InvOffset	rs.w	1	offset from pointer to BPP 
InvMinX		rs.w	1	maximum and minimum positions 
InvMaxX		rs.w	1	   invaders can scroll
InvMaxY		rs.w	1
CollisionData	rs.w	1	store for clxdat after each frame
InvFireStruct	rs.w	6*4	structures for sprites 0123 each 12 bytes
InvadersLD	rs.w	80	Invader number structure
AnimLD		rs.w	20	animation structure
SpeedLD		rs.w	24	speed structure
AgressionLD	rs.w	3
StartposLD	rs.w	1	start X pixels offset

Score		rs.l	1	current score
HighScore	rs.l	1	high score
Scratch		rs.l	1	used for adding for scores

MemBase		rs.l	1

InvSprites0	rs.l	4	pointers to sprite data structures
InvSprites1	rs.l	4

B1Grafix	rs.l	1	base addr for invader grafix
B1Pointer	rs.l	1	base pointer for invader offset
B1Buildings	rs.l	1	base pointer for building offset
B2Grafix	rs.l	1
B2Pointer	rs.l	1
B2Buildings	rs.l	1

BDGrafix	rs.l	1	base addr for invader grafix
BDPointer	rs.l	1	pointer for copper
BDBuildings	rs.l	1
BMGrafix	rs.l	1
BMPointer	rs.l	1
BMBuildings	rs.l	1

RandAdrMin	rs.l	1
RandAdrMax	rs.l	1
RandAdrPtr	rs.l	1

BgPlane1min	rs.l	1	min pos before reseting scroll
BgPlane2min	rs.l	1
BgPlane1max	rs.l	1	max position before reseting scroll
BgPlane2max	rs.l	1
BgPlane1pos	rs.l	1	current position in background
BgPlane2pos	rs.l	1

vars.length	rs.b	0
		Even
variables	ds.b	vars.length



**************************************************************************
**************************************************************************
*******			COPPERLIST for Game			**********
**************************************************************************
**************************************************************************

GameCopper	dc.w	$1001,$ff00	wait for 30,0
		dc.w	color,$111	reset BG color
		dc.w	bplcon0,$4600	4 planes dual playfield
		dc.w	bplcon1,$0000	no scroll
		dc.w	bplcon2,$0020	video priority for panel

PanelBPP	dc.w	bplpt+2,0	Score panel bitplane pointers
		dc.w	bplpt+0,0	Low word first!!!!
		dc.w	bplpt+10,0
		dc.w	bplpt+8,0	

BgBpp1		dc.w	bplpt+6,0	background bitplane pointers
		dc.w	bplpt+4,0	
BgBpp2		dc.w	bplpt+14,0
		dc.w	bplpt+12,0	

CLPanelColors	dc.w	color+2,$f00	Numerals
		dc.w	color+4,$f	descriptors


CLSprite0	dc.w	sprpt+2,0	pointers for sprite channels
		dc.w	sprpt+0,0	low word then high word
CLSprite1	dc.w	sprpt+6,0	format
		dc.w	sprpt+4,0
CLSprite2	dc.w	sprpt+10,0	sprites 0-3 are for
		dc.w	sprpt+8,0	MotherShip and Invader fire
CLSprite3	dc.w	sprpt+14,0
		dc.w	sprpt+12,0
CLSprite4	dc.w	sprpt+18,0	Player Base sprite
		dc.w	sprpt+16,0
CLSprite5	dc.w	sprpt+22,0	Player fire explosions
		dc.w	sprpt+20,0
CLSprite6	dc.w	sprpt+26,0	Player fire sprite
		dc.w	sprpt+24,0
CLSprite7	dc.w	sprpt+30,0	Disabled init. to blank
		dc.w	sprpt+28,0

***************************************************************************
;Display Invaders
		dc.w	((InvaderYstart-1)*256)+1,$ff00
InvaderScroll	dc.w	bplcon1,0	invader screen scroll value
		dc.w	bplcon2,$0024	video priority

InvaderColors	dc.w	color+2,$fdb	Playfield 1, Invader  colors
		dc.w	color+4,$aaa

		dc.w	((InvaderYstart)*256)+1,$ff00	wait end of panel

InvaderBPP	dc.w	bplpt+2,0	3 bitplaanes
		dc.w	bplpt+0,0	Low word first!
		dc.w	bplpt+10,0
		dc.w	bplpt+8,0
		dc.w	bplpt+18,0
		dc.w	bplpt+16,0
		dc.w	bplcon0,$5600	set to 5 planes Dual PF

****************************************************************************
;		dc.w	$fc01,$ff00	wait til split BG
;StaticBGBpp	dc.w	bplpt+6,0	bitplane pointers for
;		dc.w	bplpt+4,0	static background
;		dc.w	bplpt+14,0
;		dc.w	bplpt+12,0	
;		dc.w	color+22,$333

;		dc.w	$fe01,$ff00
;		dc.w	color,$444
****************************************************************************
;Display Buildings
		dc.w	$ffe1,$fffe			wait (255,last col)
;		dc.w	$0001,$ff00	WAIT til buildings displayed
BuildingsBPP	dc.w	bplpt+22,0	low word
		dc.w	bplpt+20,0	high word
		dc.w	bplcon0,$6600	set to 6 planes Dual PF

****************************************************************************
;Switch off Building display
		dc.w	$1001,$ff00	Wait til buildings been displayed
		dc.w	bplcon0,$5600	set back to 5 planes Dual PF

****************************************************************************
;End of display
		dc.w	$2401,$ff00	wait first line after display
		dc.w	color,$ccc
		dc.w	$2601,$ff00
		dc.w	color,$aaa
		dc.w	$2801,$ff00
		dc.w	color,$888
		dc.w	$2a01,$ff00
		dc.w	color,$666
		dc.w	$2c01,$ff00
		dc.w	color,$444
		dc.w	intreq,$8010	Set Interrupt Bit
		dc.w	$2e01,$ff00
		dc.w	color,$222
		dc.w	$ffff,$fffe	End copperlist

****************************************************************************

*COLORSReference
*		dc.w	color+0,0	Background color
*
*		dc.w	color+2,0	Playfield 1 colors
*		dc.w	color+4,0	invaders and score panel
*		dc.w	color+6,0
*		dc.w	color+8,0
*		dc.w	color+10,0
*		dc.w	color+12,0
*		dc.w	color+14,0
*
*		dc.w	color+16,0	NOT NEEDED transparent!
*	
*		dc.w	color+18,0	Playfield 2 colors
*		dc.w	color+20,0	backdrops and buildings
*		dc.w	color+22,0
*		dc.w	color+24,0
*		dc.w	color+26,0
*		dc.w	color+28,0
*		dc.w	color+30,0
*
*		dc.w	color+32,0	NOT NEEDED transparent!
*
*		dc.w	color+34,0	SPRITE 0,1
*		dc.w	color+36,0
*		dc.w	color+38,0
*
*		dc.w	color+40,0	NOT NEEDED transparent!
*
*		dc.w	color+42,0	Sprite 2,3
*		dc.w	color+44,0
*		dc.w	color+46,0
*
*		dc.w	color+48,0	NOT NEEDED transparent!
*
*		dc.w	color+50,0	Sprite 4,5
*		dc.w	color+52,0
*		dc.w	color+54,0
*
*		dc.w	color+56,0	NOT NEEDED transparent!
*
*		dc.w	color+58,0	Sprite 6,7
*		dc.w	color+60,0	S7 disabled due to prefetch!
*		dc.w	color+62,0


**************************************************************************
*		Routines to take and restore AmigaDos
**************************************************************************

TakeSys
	lea	GraphicsName(pc),a1		open the graphics library
	move.l	ExecBase,a6			to find the system copper
	clr.l	d0				so we can restore it!
	jsr	OpenLibrary(a6)
	move.l	d0,GraphicsBase

*	lea	DOSName(pc),a1			open the DOS library to allow
*	clr.l	d0				the loading of data before
*	jsr	OpenLibrary(a6)			killing the system ( OPT )
*	move.l	d0,DOSBase

	move.l	#MemNeeded,d0			allocate loadsa chipmem
	moveq.l	#2,d1
	jsr	AllocMem(a6)
	tst.l	d0
	beq	MemError			Oh Dear! no chipmem avail!!
	move.l	d0,(Variables+MemBase).l	store memory start address
	move.l	#Hardware,a6			harware base address in a6
	move.w	intenar(a6),SystemInts		save system interupts
	move.w	dmaconr(a6),SystemDMA		and DMA settings
	bsr	WaitDrive
	move.w	#$7fff,intena(a6)		kill interupts
.wait	btst.b	#0,vposr(a6)
	bne.s	.wait				wait for line 0
	tst.b	vhposr(a6)			before disabling
	bne.s	.wait				DMA else sprite corruption
	move.w	#$7fff,dmacon(a6)		kill all DMA
	move.b	#%01111111,IcrA			kill CIA-A interupts
	move.l	$68.w,Level2Vector		store sys interupt vectors
	move.l	$6c.w,Level3Vector
	bra	StartCode

WaitDrive
	move.w	#$fff,d1			this bit just hangs
.l2	move.w	#300,d0				around for a bit flashing
.l1	move.w	d1,color+2(a6)			color 1 . this is to allow
	dbf	d0,.l1				ADos time to turn off 
	dbf	d1,.l2				disk drive 
	rts

**************************************************************************

RestoreSys
	move.l	Level2Vector,$68.w
	move.l	Level3Vector,$6c.w
	move.l	GraphicsBase,a1	
	move.l	SystemCopper1(a1),Hardware+cop1lc	replace system
	move.l	SystemCopper2(a1),Hardware+cop2lc	copperlists
	move.w	SystemInts,d0				restore system
	or.w	#$c000,d0				interupts
	move.w	d0,intena(a6)
	move.w	SystemDMA,d0				and system DMA
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)			finally CIA-A interupts
	move.w	#$000f,dmacon(a6)
	move.b	#%10011011,Icra			ie Keyboard,exec timing
	move.l	ExecBase,a6			get execbase in a6
	move.l	(Variables+MemBase).l,a1
	move.l	#MemNeeded,d0			free the chipmem we took
	jsr	FreeMem(a6)
Memerror
*	move.l	DOSBase,a1			finally close DOS lib
*	jsr	CloseLibrary(a6)
	move.l	GraphicsBase,a1			close grafix lib
	jsr	CloseLibrary(a6)
	clr.l	d0
	rts					back to where we came from
***************************************************************************

Level2Vector		dc.l	0	variable area used in
Level3Vector		dc.l	0	boshing system
SystemInts		dc.w	0
SystemDMA		dc.w	0
DOSBase			dc.l	0
GraphicsBase		dc.l	0
			Even
GraphicsName		dc.b	'graphics.library',0
			Even
DOSName			dc.b	'dos.library',0

************************************************************************
*		Grafix, Sound, Level data etc
************************************************************************
		even
InvaderLevelData	ds.b	160*16		160 = Max number of Invaders


;Panel grafix data 40 pixels high, 2 bitplanes
Panel1		dc.w	0	extra word for prefetch
		ds.w	40
		dc.w	0,0,0
PanelScore	dc.w	0,0,0,0,0,0,0,0
PanelLives	dc.w	0,0,0,0,0
PanelHigh	dc.w	0,0,0,0
		ds.w	22*20

Panel2		ds.w	25*20

BuildingData	dc.w	04095,65520,08191,65528,16383,65532,32767,65534
		dc.w	32767,65534,32767,65534,32767,65534,32767,65534
		dc.w	32767,65534,32752,04094,32736,02046,32736,02046
		dc.w	32736,02046,32736,02046,32736,02046,32736,02046

BuildingsAbs	ds.w	16*20		buffer at top
BuildingsScreen	dc.w	0		extra word for prefetch
		ds.w	16*20		actual building data
		ds.w	20*20		buffer at bottom

BlankSprite	dc.w	0,0

SprDataBuffer0	ds.w	66*4	132 bytes for each spr channel

SprDataBuffer1	ds.w	66*4

Palette		dc.w	$111,$fdb,$aaa,$000,$0a0,$dc0,$e00,$08f	Fground
		dc.w	$000,$666,$444,$eee,$0a0,$0a0,$0a0,$0a0	Bground
		dc.w	$000,$f00,$ee0,$f80,$000,$f00,$ee0,$f80	Spr0123
		dc.w	$0c0,$0c0,$e00,$fa0,$fa0,$f60,$f00,$fa0	Spr4567

		Even
PanelText	dc.b	3,2,'SCORE:',0
		dc.b	19,2,'LIVES:',0
		dc.b	30,2,'HIGH:',0

		Even
GameAttractText	dc.b	10,85,64,' Paul Douglas,1991',0
		dc.b	10,105,'Press Fire To Start',0	

		Even
InvaderGrafix	IncBin	raw/InvaderGrafix.raw

		Even
PlayerBaseSpriteData
		include	sourcedata/PlayerBase.dat
		dc.w	0,0

		Even
PlayerFireSpriteData
		include	sourcedata/PlayerFire.dat
		dc.w	0,0

		Even
PlayerFireHitSpriteData
		include	sourcedata/PFireHit.dat
		dc.w	0,0

		Even
MShipGrafix	include	sourcedata/Mships.dat

		Even
InvFireGrafix	include	sourcedata/InvFire.dat

		Even
InvFireMaskData	
		ds.w	64
		incbin	raw/InFireMask.raw

AudioVolumeTable
		include	sourcedata/AudioVolume.Dat

		Even
AsciiData	IncBin	raw/PHDfont.raw

BGGrafix	dc.w	0
		IncBin	raw/BGG3.raw

;BGGRound	dc.w	0
;		IncBin	raw/bgground.raw
;		Even


MShipAudioData
		dc.w	222,1600		period value,length
		IncBin	raw/MShipAudio.raw

		Even
ExplosionAudioData
		dc.w	1418,535
		IncBin	raw/InvExplosionAudio.raw

		Even
ExplosionQuietAudioData
		dc.w	1418,535
		IncBin	raw/InvExplosionAudioQuiet.raw

		even
FireAudioData	
		dc.w	222,1401
		IncBin	raw/FireAudio.raw

		Even
InvMoveAudioData
		dc.w	220,485
		IncBin	raw/InvMoveAudio.raw

		Even
BaseExplosionAudioData
		dc.w	1500,1340
		IncBin	raw/PlayerExplosionAudio.raw

		Even
Title		IncBin	raw/title.raw

		Even
InvaderStructures
**************************************************************************
**************************************************************************
*			InvaderStructures.dat
*	details how each type of Invader behaves etc
*
**************************************************************************
**************************************************************************
;Invader Structures
; byte 	0	flag byte indicates dead special etc	 See Below
; byte 	1	animation number defines what it looks like
; byte 	2	Fire:	animNorm/AnimTracker 
; byte 	3	}	VspeedNorm/VspeedTracker
; byte 	4	}	HspeedPix/HSpeedFrames:	set to 0 for no tracking
; byte 	5	}	Random for tracker:  Higher less likely tracker
; byte 	6	}	CounterMax	  how long before can fire again	
; byte 	7	}	CounterValue
; byte 	8	Hit:		blank
; byte 	9	}		blank
; byte 10	}	Points When Hit
; byte 11	}      	    ditto
; byte 12	} 	Next Invader Number, 0 for none
; byte 13	define as 0	invader number 
; byte 14	define as 0	invader print pos
; byte 15	define as 0	    ditto

;Byte 0
; Bit 0		Active ie alive		set to 1
; Bit 1		Invader Hit		set to 0 not needed??
; Bit 2		Shooting activated	set to 0
; Bit 3		    Not Used
; Bit 4			~	
; Bit 5			~
; Bit 6			~
; Bit 7			~
**************************************************************************

;InvaderStructure 0	this is a blank!!
	dc.b	0,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0
	dc.b	0,0,0
;InvaderStructure 1
	dc.b	1,1			1,Animation number
	dc.b	$22,$12,$18,180,8,7		fire structure
	dc.b	0,0,$0,$10,0		hit structure
	dc.b	0,0,0			blanks
;2
	dc.b	1,2
	dc.b	$22,$12,$18,180,8,7
	dc.b	0,0,0,$10,0
	dc.b	0,0,0
;3
	dc.b	1,3
	dc.b	$22,$12,$18,180,8,7
	dc.b	0,0,0,$10,0
	dc.b	0,0,0
;4
	dc.b	1,4
	dc.b	$22,$12,$18,180,8,7
	dc.b	0,0,0,$10,0
	dc.b	0,0,0
;5
	dc.b	1,5
	dc.b	$22,$12,$1c,200,12,11
	dc.b	0,0,0,$20,0
	dc.b	0,0,0
;6
	dc.b	1,6
	dc.b	$22,$12,$1c,200,12,11
	dc.b	0,0,0,$20,0
	dc.b	0,0,0
;7
	dc.b	1,7
	dc.b	$22,$12,$1c,200,12,11
	dc.b	0,0,0,$20,0
	dc.b	0,0,0
;8
	dc.b	1,8
	dc.b	$22,$12,$1c,200,12,11
	dc.b	0,0,0,$20,0
	dc.b	0,0,0
;9
	dc.b	1,9
	dc.b	$22,$12,$1f,220,16,15
	dc.b	0,0,0,$40,0
	dc.b	0,0,0
;10
	dc.b	1,10
	dc.b	$22,$12,$1f,220,16,15
	dc.b	0,0,0,$40,0
	dc.b	0,0,0
;11
	dc.b	1,11
	dc.b	$22,$12,$1f,220,16,15
	dc.b	0,0,0,$40,0
	dc.b	0,0,0
;12
	dc.b	1,12
	dc.b	$22,$12,$1f,220,16,15
	dc.b	0,0,0,$40,0
	dc.b	0,0,0
;13
	dc.b	1,13
	dc.b	$22,$11,0,0,25,24
	dc.b	0,0,0,$50,14
	dc.b	0,0,0
;14
	dc.b	1,14
	dc.b	$22,$32,$12,160,4,3
	dc.b	0,0,$02,$50,0
	dc.b	0,0,0
;15
	dc.b	1,15
	dc.b	$33,$42,$11,150,10,9
	dc.b	0,0,0,$50,0
	dc.b	0,0,0

***************************************************************************
***************************************************************************
*			LevelsData.dat
*		data for each level takes 256 bytes
*		
***************************************************************************
***************************************************************************
LevelsData
;structure
;Base+0
;160 bytes for invader info
;	16 invaders wide by 10 deep
;	1 byte per invader InvaderStructures.dat determines type etc
;
;
;Base+160
;40 bytes for animation info
;	Anim+0; 19 bytes for move right 
;	Anim+19;1 byte move up/down at right edge
;	Anim+20;19 bytes for move left 
;	Anim+39;1 byte move up/down at left edge
;		Structure for move left/right
;			bits 7-4 :direction
;				$8x left	$Ax left up
;				$4x right	$9x left down
;				$2x up		$6x right up
;				$1x down	$5x right down
;				$0x stationary
;				$ff End of anim structure
;			bits 3-0 :number of pixels  to move
;		Structure for move up/down
;			bit 7 direction bit
;				Set; Up
;			bits 6-0 :number of pixels to move
;
;
;Base+200
;48 bytes for speed info
;	1st byte; speed info 
;			bits 7-4 determine number of pixels range 1-15
;			bits 3-0 determine number of frames range 1-15
;			IE (pixels*16)+frames
;	2nd byte; how many frames before swap buffer?
;	3rd byte; no of invaders at which next structure starts
;Base+248
;1 byte for level ferocity
;
;Base+254
;	Xstart.b  ;Xstart position of Invaders screen pos offset pixels
;Base+255
;	Ystart.b  ;Ystart pos:   InvaderYstart+no. scan lines offset
;

**************************************************************************

;Level 0

	dc.b	2,13,2,13,2,13,2,13,2,13,2,0,0,0,0,0
	dc.b	1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
	dc.b	7,7,7,7,7,7,7,7,7,7,7,0,0,0,0,0
	dc.b	8,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0
	dc.b	9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0

	dc.b	10,10,10,10,10,10,10,10,10,10,10,0,0,0,0,0
	dc.b	12,12,12,12,12,12,12,12,12,12,12,0,0,0,0,0
	dc.b	9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.b	$48,$48,$ff,0,0,0,0,0,0,0		anim right
	dc.b	0,0,0,0,0,0,0,0,0
	dc.b	8				anim right side
	dc.b	$88,$88,$ff,0,0,0,0,0,0,0		anim left
	dc.b	0,0,0,0,0,0,0,0,0	
	dc.b	8				anim left side

	dc.b	$1c,$c,70,$1a,$a,40			speed info
	dc.b	$18,$8,25,$14,$7,8
	dc.b	$12,$5,4,$11,$4,2
	dc.b	$21,$3,1,$31,$2,0

	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0

	dc.b	240,0,0,0,0,0			ferocity!!

	dc.b	30,10				X,Y relative offsets

***************************************************************************
;Level 1
	dc.b	2,2,2,13,2,2,2,13,2,2,2,13,2,2,2,0
	dc.b	1,1,1,13,1,1,1,13,1,1,1,13,1,1,1,0
	dc.b	7,7,7,13,7,7,7,13,7,7,7,13,7,7,7,0
	dc.b	8,8,8,13,8,8,8,13,8,8,8,13,8,8,8,0
	dc.b	9,9,9,13,9,9,9,13,9,9,9,13,9,9,9,0

	dc.b	10,10,10,13,10,10,10,13,10,10,10,13,10,10,10,0
	dc.b	12,12,12,13,12,12,12,13,12,12,12,13,12,12,12,0
	dc.b	9,9,9,13,9,9,9,13,9,9,9,13,9,9,9,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.b	$48,$48,$ff,0,0,0,0,0,0,0		anim right
	dc.b	0,0,0,0,0,0,0,0,0
	dc.b	8				anim right side
	dc.b	$88,$88,$ff,0,0,0,0,0,0,0		anim left
	dc.b	0,0,0,0,0,0,0,0,0	
	dc.b	8				anim left side


	dc.b	$1c,$c,70,$1a,$a,50			speed info
	dc.b	$18,$8,36,$16,$6,22
	dc.b	$15,$8,14,$14,$7,8
	dc.b	$12,$5,4,$11,$4,2

	dc.b	$21,$3,1,$41,$2,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0

	dc.b	244,0,0,0,0,0			ferocity!!

	dc.b	30,10				X,Y relative offsets

**************************************************************************
;level 2
	dc.b	0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,3,3,3,3,0,0,0,0,0,0
	dc.b	0,0,0,0,1,1,1,15,15,1,1,1,0,0,0,0
	dc.b	0,0,6,6,6,6,15,15,15,15,6,6,6,6,0,0
	dc.b	5,5,5,5,5,15,15,15,15,15,15,5,5,5,5,5

	dc.b	8,8,8,8,8,13,13,13,13,13,13,8,8,8,8,8
	dc.b	10,10,10,10,10,0,0,0,0,0,0,11,11,11,11,11
	dc.b	9,9,9,9,9,0,0,0,0,0,0,10,10,10,10,10
	dc.b	12,12,12,12,12,0,0,0,0,0,0,12,12,12,12,12
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.b	$5a,$5a,$6a,$6a,$ff,0,0,0,0,0		anim right
	dc.b	0,0,0,0,0,0,0,0,0
	dc.b	6				anim right side
	dc.b	$9a,$9a,$aa,$aa,$ff,0,0,0,0,0		anim left
	dc.b	0,0,0,0,0,0,0,0,0	
	dc.b	6				anim left side

	dc.b	$1c,$c,70,$1a,$a,50			speed info
	dc.b	$18,$8,36,$16,$6,22
	dc.b	$15,$8,14,$14,$7,8
	dc.b	$12,$5,4,$11,$4,2

	dc.b	$21,$3,1,$41,$2,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0

	dc.b	254,0,0,0,0,0			ferocity!!

	dc.b	30,0				X,Y relative offsets

**************************************************************************
;Level 3

	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
	dc.b	7,15,15,15,7,15,7,15,7,15,15,7,7,0,0,0
	dc.b	8,15,8,15,8,15,8,15,8,15,8,15,8,0,0,0
	dc.b	6,15,15,15,6,15,15,15,6,15,6,15,6,0,0,0
	dc.b	9,15,9,9,9,15,9,15,9,15,9,15,9,0,0,0
	dc.b	10,15,10,10,10,15,10,15,10,15,15,10,10,0,0,0
	dc.b	12,12,12,12,12,12,12,12,12,12,12,12,12,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.b	$48,$42,$51,$ff,0,0,0,0,0,0		anim right
	dc.b	0,0,0,0,0,0,0,0,0
	dc.b	6				anim right side
	dc.b	$88,$82,$91,$ff,0,0,0,0,0,0		anim left
	dc.b	0,0,0,0,0,0,0,0,0	
	dc.b	6				anim left side

	dc.b	$1c,$c,70,$1a,$a,40			speed info
	dc.b	$18,$8,25,$14,$7,8
	dc.b	$12,$5,4,$11,$4,2
	dc.b	$21,$3,1,$31,$2,0

	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	0,0,0,0,0,0

	dc.b	250,0,0,0,0,0			ferocity!!

	dc.b	30,8				X,Y relative offsets





		END
