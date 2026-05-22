*****************************************************************************
*						     			    *
*				ORB-IT					    *
*			© P.H. Douglas  1992			    	    *
*						    			    *
*			  Mod. No. 920825				    *
*						    			    *
*		!! indicates subroutine tested and OK   		    *
*****************************************************************************

	opt		c-

	section		Ultraworld,code_c	chip ram only please!

	incdir		Source:P.Douglas/
	include 	customdff002.i		my hardware include file

ExecBase		equ	4		equates for using AmigaDos
Hardware		equ	$dff002		libraries, only used to
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
HZswitch		equ	$1da		put $0020 or $0000
**************************************************************************

NoPlanes		equ	3
RasterWidth		equ	42			bytes
RasterHeight		equ	208+32			lines
RasterMem		equ	RasterWidth*RasterHeight*NoPlanes

HillMem			equ	300*48

MemNeeded		equ	2*RasterMem+HillMem+1024

RasterStartX		equ	53*16
ScreenTopY		equ	$52
ScreenStart		equ	24
HillStart		equ	160

ShipSpeedY		equ	4
ShipSpeedX		equ	8
MaxShots		equ	3
**************************************************************************
*			START OF SOURCE CODE
**************************************************************************
Start
	bra	TakeSys				bosh AmigaDos and return
StartCode
	lea	Variables(pc),a5		a5 is my variables pointer
	lea	Hardware,a6			a6 is my custom pointer
	bsr	GlobalInitialise
**************************************************************************
**************************************************************************
*			 Main Game Loop 
**************************************************************************
**************************************************************************
MainLoop
	bsr	Wait.Start.Frame

	addq.b	#1,framecount(a5)

.wait1	move.w	vhposr(a6),d0
	and.w	#$ff00,d0
	cmp.w	#$5000,d0
	bne.s	.wait1

	move.w	#$8,color00(a6)

	bsr	Clear.Bobs		clear bobs
	bsr	Clear.Lasers		clear lasers
	bsr	Process.Player		get new ship pos
	bsr	Process.Lasers		handle laser firing
;	bsr	Process.Bobs
	bsr	Draw.Hills		blit still running on exit !!
	bsr	Draw.Bobs		draw bobs
	bsr	Draw.Lasers		draw lasers

;	move.w	#$f00,color00(a6)
;	bsr	Test1
;	move.w	#$f0,color00(a6)
;	bsr	Test2

	move.w	#0,color00(a6)

	bsr	Wait.End.Frame
	bsr	Swap.Buffers


	btst	#LeftMouse,PortA	left mouse button to exit
	bne.s	MainLoop		for testing purposes

.ret	bra	RestoreSys	

Test1	move.w	#400,d0
.tl1	lea	32(a0),a0
	dbf	d0,.tl1
	rts

Test2	move.w	#400,d0
.tl2	add.w	#32,a0
	dbf	d0,.tl2
	rts

**************************************************************************
*		test draw bob routine!!
**************************************************************************
Draw.Bobs
	bsr	Init.Blit.Bob
	lea	TestBob(pc),a2

	move.l	BobY(a5),d0
	addq.l	#1,d0
	cmp.b	#14*16,d0
	bne.s	.skip
	moveq	#0,d0
.skip	move.l	d0,BobY(a5)	
	
	move.w	#RasterStartX+16,d0
	move.l	BobY(a5),d1
	move.w	#(16*3*64+2),d2
	move.l	a2,a0
	bsr	blit.bob
	move.w	#RasterStartX+32,d0
	move.l	BobY(a5),d1
	move.w	#(16*3*64+2),d2
	move.l	a2,a0
	bsr	blit.bob
	move.w	#RasterStartX+67,d0
	move.l	BobY(a5),d1
	move.w	#(16*3*64+2),d2
	move.l	a2,a0
	bsr	blit.bob
	move.w	#RasterStartX+300,d0
	move.l	BobY(a5),d1
	move.w	#(16*3*64+2),d2
	move.l	a2,a0
	bsr	blit.bob

	rts

**************************************************************************
*		init blitter for printing bobs
**************************************************************************
Init.Blit.Bob
	btst.b	#6,(a6)
	bne.s	Init.Blit.Bob
	move.l	#$ffff0000,bltafwm(a6)		set up A mask
	move.w	#-2,bltamod(a6)			set up modulos
	move.w	#-2,bltbmod(a6)
	move.w	#(RasterWidth-4),bltdmod(a6)
	move.w	#(RasterWidth-4),bltcmod(a6)
	rts

**************************************************************************
*		print a bob	16 pixels wide!
**************************************************************************
Blit.Bob
;entry	d0  x coord.w
;	d1  y coord.l	make sure bits 31-16 are zero!!
;	a0  address of grafix mask then 3 bitplanes
;	d2  blitsize of bob

	mulu.w	#(RasterWidth*3),d1
	sub.w	#RasterStartX,d0
	move.b	d0,d3
	and.w	#$07ff,d0
	asr.w	#3,d0
	add.w	d0,d1
	add.l	RasterMbase(a5),d1	get dest addr
	and.w	#$000f,d3		get shift value
	ror.w	#4,d3			into bits 15-12

	move.l	BobClearMpt(a5),a1	store dest and blitsize
	move.l	d1,(a1)+		for clearance purposes
	move.w	d2,(a1)+
	move.l	a1,BobClearMpt(a5)
	addq.w	#1,BobClearMCount(a5)

.wb0	btst.b	#6,(a6)
	bne.s	.wb0
	move.w	d3,bltcon1(a6)		put shift values
	or.w	#$0fca,d3		and minterm
	move.w	d3,bltcon0(a6)
	move.l	a0,bltbpt(a6)		gfx addr
	lea	96(a0),a0
	move.l	a0,bltapt(a6)		mask addr
	move.l	d1,bltcpt(a6)		dest addr
	move.l	d1,bltdpt(a6)
	move.w	d2,bltsize(a6)
	rts

**************************************************************************
*		clear screen of all bobs
**************************************************************************
Clear.Bobs
	lea	bltdpt(a6),a0		get addr used directly
	lea	bltsize(a6),a1
	moveq	#6,d6			
	move.l	BobClearM(a5),a2
	move.w	BobClearMCount(a5),d7	how many clearances
.wb	btst.b	d6,(a6)
	bne.s	.wb
	move.l	#$01000000,bltcon0(a6)	D=0 only please
	move.w	#RasterWidth-4,bltdmod(a6)
	bra.s	.end

.loop	btst.b	d6,(a6)			wait for blitter!
	bne.s	.loop
	move.l	(a2)+,(a0)		get dest addr
	move.w	(a2)+,(a1)		get blitsize
.end	dbf	d7,.loop

	move.l	BobClearM(a5),BobClearMpt(a5)	reset pointer
	clr.w	BobClearMCount(a5)		and counter
	rts

**************************************************************************
*		wait for start of frame
**************************************************************************
Wait.Start.Frame
	move.w	Intreqr(a6),d0
	btst.l	#4,d0
	bne.s	Wait.Start.Frame
	rts

**************************************************************************
*		wait for end of frame
**************************************************************************
Wait.End.Frame
	move.w	Intreqr(a6),d0
	btst.l	#4,d0
	beq.s	Wait.End.Frame
	rts

**************************************************************************
*			Swap Buffers etc etc
**************************************************************************
Swap.Buffers
	lea	SprAddr(a5),a2		Update sprite pointers first
	lea	SprCW(a5),a1
	lea	CLSprite0+2(pc),a0
	moveq	#7,d7
.loop	move.l	(a2)+,a3
	move.l	(a1)+,(a3)
	move.l	a3,d0
	bsr	PutPointerInCLM
	dbf	d7,.loop

	move.l	RasterMbase(a5),d0		now update BP pointers
	add.l	#((16*RasterWidth*3)+2),d0	add clip offset
	lea	CLBPP+2(pc),a0
	moveq	#RasterWidth,d1
	bsr	PutPointerInCLM
	add.l	d1,d0
	bsr	PutPointerInCLM
	add.l	d1,d0
	bsr	PutPointerInCLS

	lea	RasterMbase(a5),a3		swap 5 long words
	lea	RasterDbase(a5),a4
	movem.l	(a3)+,d0-d4		
	movem.l	(a4)+,d5-d7/a0-a1
	movem.l	d5-d7/a0-a1,-(a3)
	movem.l	d0-d4,-(a4)

	rts

**************************************************************************
*			Process Player stuff
**************************************************************************
Process.Player
	bsr	GetJoyInput		get Joystick Input in d0
	
	move.b	ShipYvector(a5),d2	Do Up-down first
	move.b	ShipY(a5),d1

	btst.l	#8,d0			test for up
	bne.s	.doup			branch if set
	btst.l	#0,d0			test for down
	bne.s	.dodown			
	tst.b	d2			if no input
	beq.s	.skipUD			then push vector to 0
	bpl.s	.sub
	addq.b	#1,d2
	bra.s	.skipUD
.sub	subq.b	#1,d2
	bra.s	.skipUD

.doup	subq.b	#2,d2
	cmp.b	#-(ShipSpeedY),d2	modify vector
	bgt.s	.skipUD
	move.b	#-(ShipSpeedY),d2
	bra.s	.skipUD

.dodown	addq.b	#2,d2
	cmp.b	#(ShipSpeedY),d2	modify vector
	blt.s	.skipUD
	move.b	#(ShipSpeedY),d2

.skipUD	move.b	d2,d3
	add.b	d3,d1			add vector/2 to position
	cmp.b	#16,d1			check bounds
	bhs.s	.ok1UD			top/bottom
	moveq	#16,d1		
	moveq	#0,d2			reset vector if at bound
.ok1UD	cmp.b	#210,d1
	blo.s	.ok2UD
	moveq.l	#210,d1
	moveq	#0,d2
.ok2UD	move.b	d1,ShipY(a5)
	move.b	d2,ShipYvector(a5)


	move.w	ShipXvector(a5),d2	Do left-right now
	move.w	ShipX(a5),d1
	clr.w	ScrollValue(a5)		zero scroll value 
	st	ShipThrust(a5)
	btst.l	#9,d0			test for up
	bne.s	.doL			branch if set
	btst.l	#1,d0			test for down
	bne.s	.doR
	sf	ShipThrust(a5)
	tst.w	d2			if no input
	beq.s	.skipLR			then push vector to 0
	bpl.s	.sublr
	addq.w	#1,d2
	bra.s	.skipLR
.sublr	subq.w	#1,d2
	bra.s	.skipLR

.doL	sf	ShipDir(a5)
	subq.w	#2,d2
.sL	cmp.w	#-(ShipSpeedX*8),d2	modify vector
	bgt.s	.skipLR
	move.w	#-(ShipSpeedX*8),d2
	bra.s	.skipLR

.doR	st	ShipDir(a5)
	addq.w	#2,d2
.sR	cmp.w	#(ShipSpeedX*8),d2	modify vector
	blt.s	.skipLR
	move.w	#(ShipSpeedX*8),d2

.skipLR	move.w	d2,ShipXVector(a5)
	asr.w	#3,d2
	add.w	d2,ScrollValue(a5)

	move.w	ShipX(a5),d0
	sub.w	#(RasterStartX+160),d0
	move.w	d0,d2
	bpl.s	.sneg
	neg.w	d2
.sneg	asr.w	#3,d2
	moveq	#0,d1
	lea	Turn.LUT,a0
	tst.b	ShipDir(a5)
	beq.s	.left
.right	cmp.w	#-90,d0
	beq.s	.done
	move.b	0(a0,d2.w),d1
	sub.w	d1,ShipX(a5)
	add.w	d1,ScrollValue(a5)
	bra.s	.done
.left	cmp.w	#90,d0
	beq.s	.done
	move.b	0(a0,d2.w),d1
	add.w	d1,ShipX(a5)
	sub.w	d1,ScrollValue(a5)
.done	move.w	ScrollValue(a5),d0	get new hill position
	add.w	d0,HillXat0(a5)		
	bsr	Get.Ship.Spr.CW
	rts

**************************************************************************
*		handle ship sprites at pos x,y
**************************************************************************
Get.Ship.Spr.CW
	moveq	#0,d1
	move.b	ShipY(a5),d1
	move.w	ShipX(a5),d0
	moveq	#8,d2			spr.height
	bsr	GetControlWords		get sprite control words

	lea	SprCW(a5),a0		and store
	moveq.l	#$80,d0
	move.l	d7,(a0)+
	or.b	d0,d7			set attach
	move.l	d7,(a0)+
	eor.b	d0,d7			reset
	add.l	#$00080000,d7		add 16 pix
	move.l	d7,(a0)+		do again
	or.b	d0,d7
	move.l	d7,(a0)+

	lea	Shipsprites,a0		store addresses of sprites
	tst.b	ShipDir(a5)		get direction
	bne.s	.skip1
	lea	(10*4*4*2)(a0),a0
.skip1	tst.b	ShipThrust(a5)
	beq.s	.skip2
	btst.b	#1,Framecount(a5)
	beq.s	.skip2
	lea	(10*4*4)(a0),a0

.skip2	lea	SprAddr(a5),a1
	moveq	#3,d0
.loop	move.l	a0,(a1)+
	lea	(10*4)(a0),a0
	dbf	d0,.loop
	rts

**************************************************************************
*			Process	lasers
**************************************************************************
Process.Lasers
	lea	LaserFireStruct(pc),a0
	move.w	#(RasterStartX+16),d5		left edge co-ord
	move.w	#(RasterStartX+16+320),d6	right edge co-ord

	moveq	#MaxShots-1,d7			
.loop	tst.b	(a0)			is it active
	beq.s	.next			if not skip processing

	tst.b	1(a0)			left or right?
	beq.s	.left
.right	add.w	#16,4(a0)		fire right
	cmp.w	4(a0),d6		if X.left is at edge
	bne.s	.okr			make inactive
	sf	(a0)
.okr	add.w	#32,6(a0)
	cmp.w	6(a0),d6
	bhi.s	.next
	move.w	d6,6(a0)
	bra.s	.next
.left	sub.w	#16,6(a0)		fire left			
	cmp.w	6(a0),d5		if X.right at left edge
	bne.s	.okl			then make inactive
	sf	(a0)
.okl	sub.w	#32,4(a0)		if X.left < left edge
	cmp.w	4(a0),d5		then make = left edge
	blo.s	.next
	move.w	d5,4(a0)
.next	addq.l	#8,a0
	dbf	d7,.loop

	bsr	NewLaser
	rts

**************************************************************************
*			do we draw a new laser?
**************************************************************************
NewLaser
	btst.b	#JoyFire,PortA		get fire button
	beq.s	.presed			return if not pressed
.up	sf	OldFire(a5)
.ret	rts
.presed	tst.b	OldFire(a5)
	bne.s	.ret
	st	OldFire(a5)
	

	lea	LaserFireStruct(pc),a0	search for a
	moveq	#MaxShots-1,d0		non active slot
.loop	tst.b	(a0)
	beq.s	.found
	addq.l	#8,a0
	dbf	d0,.loop
	rts				ret if all full

.found	st	(a0)			now active
	move.b	ShipY(a5),3(a0)		get Y co-ord
	addq.b	#5,3(a0)
	move.b	Framecount(a5),d0	get color
	and.b	#$07,d0
	bne.s	.ok
	addq.b	#1,d0			add 1 if 0
.ok	move.b	d0,2(a0)
	move.w	ShipX(a5),d0		get x co-ord
	move.b	ShipDir(a5),1(a0)	get direction
	beq.s	.left
.right	add.w	#32,d0			init x co-ords
	and.w	#$07f0,d0		at 16 pix res
	move.w	d0,4(a0)
	add.w	#32,d0
	move.w	d0,6(a0)
	rts
.left	addq.w	#8,d0
	and.w	#$07f0,d0		get 16 pix res
	move.w	d0,6(a0)
	sub.w	#32,d0
	move.w	d0,4(a0)
	rts

**************************************************************************
*			draw lasers
**************************************************************************
Draw.Lasers
	lea	LaserFireStruct,a0
	move.l	LaserClearM(a5),a1
	moveq	#MaxShots-1,d7
.wbs	btst.b	#6,(a6)			init blitter
	bne.s	.wbs
	move.w	#0,bltcon1(a6)
.loop	tst.b	(a0)
	beq.s	.next
	moveq	#0,d0
	move.b	3(a0),d0		get y pos
	mulu.w	#RasterWidth*3,d0
	add.l	RasterMbase(a5),d0	get addr down
	move.l	d0,a4
	move.w	4(a0),d1
	move.w	6(a0),d2
	sub.w	d1,d2
	lsr.w	#4,d2			get length in words
	or.b	#$40,d2			get blitsize
	sub.w	#RasterStartX,d1
	lsr.w	#3,d1
	add.w	d1,a4			get addr to put blit
	move.l	a4,(a1)+
	addq.w	#1,LaserClearMc(a5)
	move.b	2(a0),d3		get the color of fire
	moveq	#2,d4			3 bitplanes
.wb	btst.b	#6,(a6)			wait for blitter
	bne.s	.wb	
	move.l	a4,bltdpt(a6)		put addr
	btst	d4,d3
	bne.s	.fill
.clear	move.w	#$0100,bltcon0(a6)	D=0
	move.w	d2,bltsize(a6)
	bra.s	.nextc
.fill	move.w	#$01ff,bltcon0(a6)	D=1
	move.w	d2,bltsize(a6)
.nextc	lea	RasterWidth(a4),a4
	dbf	d4,.wb

.next	addq.l	#8,a0
	dbf	d7,.loop
	rts

**************************************************************************
*		clear screen of all bobs
**************************************************************************
Clear.Lasers
	lea	bltdpt(a6),a0		get addr used directly
	lea	bltsize(a6),a1
	move.l	LaserClearM(a5),a2
	move.w	LaserClearMc(a5),d7	how many clearances
	moveq	#6,d6			blit finish bit
	move.w	#(3*64+16),d5		blitsize
.wb	btst.b	d6,(a6)
	bne.s	.wb
	move.l	#$01000000,bltcon0(a6)		D=0 minterm
	move.w	#(RasterWidth-32),bltdmod(a6)
	bra.s	.end
.loop	btst.b	d6,(a6)			wait for blitter!
	bne.s	.loop
	move.l	(a2)+,(a0)		get dest addr
	move.w	d5,(a1)			get blitsize
.end	dbf	d7,.loop
	clr.w	LaserClearMc(a5)	wipe counter
	rts

**************************************************************************
*!!		draw hills into screen area
**************************************************************************
Draw.Hills
	move.l	RasterMbase(a5),a0		get screen addr
	add.l	#(RasterWidth*HillStart*3),a0	get addr to put

	move.w	HillXat0(a5),d0
	add.w	#RasterStartX,d0
	move.w	d0,d1
	and.w	#$07f0,d0		get words*16
	lsr.w	#3,d0			get no. bytes
	move.l	Hillbase(a5),a1
	add.w	d0,a1			get pos in hill.gfx

	and.b	#$0f,d1			get pixels
	beq.s	.skip			if have to scroll
	addq.l	#2,a1			add 2 to pointer
.skip	moveq	#16,d0
	sub.b	d1,d0
	lsl.w	#6,d0
	lsl.w	#6,d0
	or.w	#$09f0,d0
	swap	d0

.wb	btst.b	#6,(a6)
	bne.s	.wb
	move.l	a0,bltdpt(a6)		
	move.l	a1,bltapt(a6)
	move.l	d0,bltcon0(a6)		
	moveq.l	#-1,d0
	move.l	d0,bltafwm(a6)		
	move.w	#(2*RasterWidth),bltdmod(a6)
	move.w	#(300-42),bltamod(a6)
	move.w	#(48*64+21),bltsize(a6)
	rts

**************************************************************************
**************************************************************************
*		initialise once only stuff
**************************************************************************
**************************************************************************
GlobalInitialise
	move.w	#$8640,dmacon(a6)	enable blitter
	move.l	membase(a5),a0
	move.l	a0,Hillbase(a5)		get addr of hill grafix
	add.w	#((300*48)+256),a0
	move.l	a0,RasterStart(a5)	
	move.l	a0,RasterMbase(a5)
	add.l	#RasterMem,a0
	move.l	a0,RasterDbase(a5)

;	bsr	InitKeyboard
	bsr	InitAudio

	bsr	InitSprites
	bsr	InitClearTables

	bsr	InitPanel
	bsr	PutPanelColors
	bsr	Build.Hills

	bsr	PutSpriteColors

	bsr	ClearRasterMem


	move.w	#(RasterStartX+160),ShipX(a5)

	lea	GameCL,a0		init copper pointer
	move.l	a0,cop1lc(a6)
	move.w	d0,copjmp1(a6)		strobe
	move.w	#$87ef,dmacon(a6)	start dma

	rts

**************************************************************************
*!!		build hills into alloc mem
**************************************************************************
Build.Hills
	move.l	Hillbase(a5),a0		clear mem first
	move.w	#(300*64+24),d0
	bsr	BlitClear
.wb	btst.b	#6,(a6)
	bne.s	.wb
	move.l	a0,a1
	lea	Hill.table(pc),a0
	add.w	#(48*300),a1		get to bottom
	sf	d5			last block type 0 down -1 up
	move.w	#(300*8),d4		offset up/down
	move.w	#300,d3			one scan line
	moveq	#31,d7			number of bytes
.loop2	moveq	#7,d6			bit counter
.loop1	btst.b	d6,(a0)
	beq.s	.down
.up	sub.w	d4,a1			block is up /
	tst.b	d5
	beq.s	.pu
	sub.w	d4,a1
.pu	bsr	.putup
	st	d5			last block up
	bra.s	.skip
.down	tst.b	d5			block is down \
	beq.s	.pd
	sub.w	d4,a1			get next gfx addr
.pd	bsr	.putdown
	sf	d5			last block down
.skip	addq.l	#1,a1			move along gfx 1 place
	dbf	d6,.loop1
	addq.l	#1,a0			get next hill.table byte
	dbf	d7,.loop2

	move.l	Hillbase(a5),a0		get source
	move.l	a0,a1
	add.w	#256,a1			get dest
	
	move.w	#(300-44),d0		modulos
	move.w	d0,d1
	move.w	#(48*64+22),d2		blitsize
	bsr	BlitCopy		copy start to scroll end
	rts

.putup	lea	Hill.gfx(pc),a4
	bra.s	.putgfx
.putdown
	lea	Hill.gfx+8(pc),a4
.putgfx	moveq	#7,d0
.pl	move.b	(a4)+,(a1)
	add.w	d3,a1
	dbf	d0,.pl
	rts

*************************************************************************
*		Clear the raster memory
*************************************************************************
ClearRasterMem
	move.l	RasterStart(a5),a0
	move.w	#(RasterHeight*3*64+42),d0
	bsr	BlitClear
.wb	btst.b	#6,(a6)
	bne.s	.wb
	rts

**************************************************************************
*		Initialise bob.clear tables
**************************************************************************
InitClearTables
	moveq	#0,d0
	lea	BobClearTable(pc),a0	
	move.l	a0,BobClearM(a5)
	move.l	a0,BobClearMpt(a5)
	lea	(8*128)(a0),a0
	move.l	a0,BobClearD(a5)
	move.l	a0,BobClearDpt(a5)
	move.w	d0,BobClearDCount(a5)
	move.w	d0,BobClearMCount(a5)

	lea	LaserClearTable(pc),a0
	move.l	a0,LaserClearM(a5)
	lea	(4*MaxShots)(a0),a0
	move.l	a0,LaserClearD(a5)
	move.w	d0,LaserClearMc(a5)
	move.w	d0,LaserClearDc(a5)
	rts

**************************************************************************
*		Initialise sprites to blanks
**************************************************************************
InitSprites
	lea	BlankSprite(pc),a0
	lea	SprAddr(a5),a1
	lea	SprCW(a5),a2
	moveq	#0,d0
	moveq	#7,d1
.loop	move.l	a0,(a1)+
	move.l	d0,(a2)+
	dbf	d1,.loop
	rts

**************************************************************************
*		initialise the audio DMA
**************************************************************************
InitAudio
	lea	BlankSprite(pc),a0	let all audio channels run at
	move.l	a0,aud0lc(a6)		approx 16khz
	move.l	a0,aud1lc(a6)		so we know how much dma time
	move.l	a0,aud2lc(a6)		we have!!
	move.l	a0,aud3lc(a6)
	moveq	#1,d0
	move.w	d0,aud0len(a6)
	move.w	d0,aud1len(a6)
	move.w	d0,aud2len(a6)
	move.w	d0,aud3len(a6)
	move.w	#256,d0
	move.w	d0,aud0per(a6)
	move.w	d0,aud1per(a6)
	move.w	d0,aud2per(a6)
	move.w	d0,aud3per(a6)
	rts

**************************************************************************
*!!		initialise panel etc
**************************************************************************
InitPanel
	lea	Panel.gfx(pc),a1
	move.l	a1,d0
	lea	CLBPPPanel+2(pc),a0
	move.l	#(36*18),d1
	bsr	PutPointerInCLM
	add.l	d1,d0
	bsr	PutPointerInCLM
	add.l	d1,d0
	bsr	PutPointerInCLS
	rts

**************************************************************************
*		put colors in copperlist for panel
**************************************************************************
PutPanelColors
	lea	Panel.colors(pc),a0		put play area colors
	lea	CLcolorsPanel+2(pc),a1
	moveq	#7,d0
.loop	move.w	(a0)+,(a1)+
	addq.l	#2,a1
	dbra	d0,.loop
	rts

**************************************************************************
*		put sprite colors directly
**************************************************************************
PutSpriteColors
	lea	Sprite.Colors(pc),a0
	lea	Color16(a6),a1
	moveq	#15,d0
.loop	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts

**************************************************************************
**************************************************************************
*		General purpose routines
**************************************************************************
**************************************************************************


**************************************************************************
*		general blit copy
**************************************************************************
BlitCopy
;INPUT	a0  source addr
;	a1  dest   addr
;	d0  source modulo
;	d1  dest   modulo
;	d2  blitsize

.waitb	btst.b	#6,(a6)			wait if blit already running
	bne.s	.waitb
	move.w	d0,bltamod(a6)		put modulos
	move.w	d1,bltdmod(a6)
	move.l	a0,bltapt(a6)		put pointers
	move.l	a1,bltdpt(a6)
	moveq.l	#-1,d0
	move.l	d0,bltafwm(a6)		no mask
	move.l	#$09f00000,bltcon0(a6)
	move.w	d2,bltsize(a6)		and Blit!
	rts

**************************************************************************
*		general memory clear using de blitter
**************************************************************************
BlitClear
;INPUT	a0  start addr
;	d0  blit size

.waitb	btst.b	#6,(a6)			wait if blit already running
	bne.s	.waitb
	move.w	#0,bltdmod(a6)
	move.l	#$01000000,bltcon0(a6)
	move.l	a0,bltdpt(a6)		put pointers
	move.w	d0,bltsize(a6)		and Blit!
	rts

**************************************************************************
*!!		put pointer in copperlist
**************************************************************************
;entry  d0 pointer
;	a0 copper addr 
PutPointerInCLM
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	rts

**************************************************************************
*!!		put pointer in copperlist
**************************************************************************
;entry  d0 pointer
;	a0 copper addr 
PutPointerInCLS
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	rts

**************************************************************************
*!!		get joystick movement
**************************************************************************
GetJoyInput
	move.w	joy1dat(a6),d0		;on exit in d0.w
	and.w	#$0303,d0		left	9
	move.w	d0,d1			right	1
	lsr.w	#1,d1			up	8
	eor.w	d1,d0			down	0
	btst.b	#JoyFire,PortA		get fire button
	bne.s	.ret
	or.b	#$04,d0			set fire bit 2
.ret	rts

**************************************************************************
*		get Control Words for sprites 
**************************************************************************
GetControlWords
;entry 	d0 X screen co-ord
;	d1 Y screen co-ord
;	d2 sprite height
;exit	d7 control words

	moveq	#0,d7			return longword in d7
	add.w	#($71-RasterStartX),d0	add offset horizontal
	add.w	#($52-16),d1		add vertical offset
	add.w	d1,d2			get end vertical		
	lsl.w	#8,d1			Y into bits 8-15
	roxl.b	#1,d7			put sv8
	swap	d7
	move.w	d1,d7			put sv7-sv0
	swap	d7
	lsl.w	#8,d2
	roxl.b	#1,d7			put ev8
	or.w	d2,d7			put ev7-ev0
	lsr.w	#1,d0
	roxl.b	#1,d7			put sh0
	swap	d7
	move.b	d0,d7			put sh8-sh1
	swap	d7
.ret	rts

*************************************************************************
*************************************************************************
*		Keyboard handling routines
*************************************************************************
*************************************************************************
KeyboardInterrupt
	move.l	d0,-(a7)			save registers
	move.b	$bfed01,d0			handshake cia int.
	move.b	$bfec01,Variables+KeyIn		get the keycode
	or.b	#$40,$bfee01			set spmode as output
	moveq	#10,d0				wait 75 us
.wait	subq.b	#1,d0
	bne.s	.wait
	and.b	#$bf,$bfee01			spmode = input
	move.w	#$0008,intreq(a6)		handshake int.
	move.l	(a7)+,d0			restore regs
	rte

*************************************************************************
InitKeyboard
	move.b	#$88,$bfed01		enable serial port int
	move.b	#$20,$bfee01		inmode = CNT
	lea	KeyboardInterrupt(pc),a0
	move.l	a0,$68.w
	move.w	#$c008,intena(a6)	enable KB int.
	clr.b	KeyIn(a5)
	rts

**************************************************************************
*		handle keyboard input
**************************************************************************
Keyboard.Input
	move.b	KeyIn(a5),d0
	beq.s	.ret
	cmp.b	#$D6,d0		T upcode
	bne.s	.ret
	lea	TestColors(a5),a0
	moveq	#15,d1
	tst.w	(a0)
	beq.s	.copy2
	moveq	#0,d2
.loop1	move.w	d2,(a0)+
	dbf	d1,.loop1
	bra.s	.ret
.copy2	lea	TestColorsList(pc),a1
.loop2	move.w	(a1)+,(a0)+
	dbf	d1,.loop2
.ret	clr.b	KeyIn(a5)
	rts

TestColorsList	dc.w	$fff,$f00,$0f0,$00f,$ff0,$0ff,$888,$f42
		dc.w	$2e2,$22e,$ee4,$4ee,$333,$f0f,$a8f,$18f


**************************************************************************
***********************    Variables	********************************** 
**************************************************************************

		RSReset
Membase		rs.l	1	base of free memory		Global Constant
Hillbase	rs.l	1					GC
RasterStart	rs.l	1	addr of screens start		GC

RasterMbase	rs.l	1	variables assoc with double buffer
BobClearM	rs.l	1	variables used in clearing
BobClearMpt	rs.l	1	the screen
BobClearMCount	rs.w	1
LaserClearM	rs.l	1
LaserClearMc	rs.w	1

RasterDbase	rs.l	1
BobClearD	rs.l	1
BobClearDpt	rs.l	1
BobClearDCount	rs.w	1
LaserClearD	rs.l	1
LaserClearDc	rs.w	1

SprAddr		rs.l	8	addresses of sprites
SprCW		rs.l	8	control words for sprites

ScrollValue	rs.w	1	pix to scroll each frame
HillXat0	rs.w	1	how far into hills at 0,0

ShipX		rs.w	1	ship co-ords 
ShipY		rs.b	1


ShipDir		rs.b	1	-1 if facing left
ShipThrust	rs.b	1
ShipXvector	rs.w	1
ShipYvector	rs.b	1
OldFire		rs.b	1	-1 if fire pressed


BobY		rs.l	1


FrameCount	rs.b	1
KeyIn		rs.b	1	keyboard input
TestColors	rs.w	16	routine test colors

vars.length	rs.b	0
		Even
variables	ds.b	vars.length
		Even
**************************************************************************
**************************************************************************
*******			COPPERLIST for Game			**********
**************************************************************************
**************************************************************************
GameCL
		dc.w	$1001,$fffe		Wait a little bit	
		dc.w	intreq+2,$0010
		dc.w	bplcon0+2,$3200,bplcon1+2,$0000,bplcon2+2,$0024
		dc.w	diwstrt+2,$3e91,diwstop+2,$22c1
		dc.w	ddfstrt+2,$0040,ddfstop+2,$00c8
		dc.w	bpl1mod+2,$0000,bpl2mod+2,$0000

CLcolorsPanel	dc.w	color00+2,0,color01+2,0
		dc.w	color02+2,0,color03+2,0
		dc.w	color04+2,0,color05+2,0
		dc.w	color06+2,0,color07+2,0
CLBPPPanel	dc.w	bpl1ptl+2,0,bpl1pth+2,0		Panel BP pointers
		dc.w	bpl2ptl+2,0,bpl2pth+2,0	
		dc.w	bpl3ptl+2,0,bpl3pth+2,0	

CLSprite0	dc.w	spr0ptl+2,0,spr0pth+2,0		Sprite pointers
CLSprite1	dc.w	spr1ptl+2,0,spr1pth+2,0
CLSprite2	dc.w	spr2ptl+2,0,spr2pth+2,0
CLSprite3	dc.w	spr3ptl+2,0,spr3pth+2,0
CLSprite4	dc.w	spr4ptl+2,0,spr4pth+2,0
CLSprite5	dc.w	spr5ptl+2,0,spr5pth+2,0
CLSprite6	dc.w	spr6ptl+2,0,spr6pth+2,0
CLSprite7	dc.w	spr7ptl+2,0,spr7pth+2,0

		dc.w	$5001,$ff00			Wait end of panel
		dc.w	bplcon0+2,$0200			turn off BP DMA

CLBPP		dc.w	bpl1ptl+2,0,bpl1pth+2,0		Game BP pointers
		dc.w	bpl2ptl+2,0,bpl2pth+2,0	
		dc.w	bpl3ptl+2,0,bpl3pth+2,0	
		dc.w	bpl1mod+2,86,bpl2mod+2,86
		dc.w	ddfstrt+2,$0038,ddfstop+2,$00d0
		dc.w	diwstrt+2,$3e81,diwstop+2,$22c1
CLcolors	dc.w	color01+2,$e00,color02+2,$0e0
		dc.w	color03+2,$00e,color04+2,$ee0
		dc.w	color05+2,$e0e,color06+2,$0ee
		dc.w	color07+2,$eee

		dc.w	$5201,$ff00
		dc.w	bplcon0+2,$3200			turn BP DMA on

		dc.w	$ffe1,$fffe
		dc.w	$2c01,$ff00			wait end of display
		dc.w	intreq+2,$8010			set int. flag
		dc.w	$ffff,$fffe

**************************************************************************
**************************************************************************
*			GRAFIX  SFX etc etc
**************************************************************************
**************************************************************************

Panel.gfx	incbin	panel.raw
Panel.colors	dc.w	$000		background
		dc.w	$aaa		score 
		dc.w	$ba9		ship,bomb
		dc.w	$048		box outlines
		dc.w	$002		scanner background
		dc.w	$fed		scanner alien dots
		dc.w	$e00		scanner   pod dots
		dc.w	$e00		scanner   pod dots


Game.colors	dc.w	$e00,$000,$000,$000,$000,$000,$000

Sprite.colors	dc.w	$000,$fed,$c00,$f60,$dd0,$ddd,$aaa,$888
		dc.w	$5af,$000,$000,$000,$58d,$000,$000,$000


hill.gfx	dc.b	$01,$02,$04,$08,$10,$20,$40,$80		/up
		dc.b	$80,$40,$20,$10,$08,$04,$02,$01		\down

hill.table	dc.b	%11111100,%01001001,%10100010,%10111011
		dc.b	%10011101,%00100001,%01100111,%11001000
		dc.b	%11000110,%00101011,%01011010,%01110110
		dc.b	%11001001,%10001001,%10011101,%10010100
		dc.b	%10001011,%00101101,%10101100,%10111011
		dc.b	%00101000,%10010110,%01001111,%10110000
		dc.b	%00101011,%01100111,%01101100,%01001011
		dc.b	%10110001,%01010010,%01110001,%10010010

BlankSprite	dc.w	0,0

ShipSprites	include	ships.spr.s

Turn.LUT	dc.b	4,4,4,4,4,4,4,3
		dc.b	3,2,1,1


BobClearTable	ds.w	4*128*2		could be done with allocmem!!
LaserClearTable	ds.w	MaxShots*4	


Laserfirestruct	ds.w	4*MaxShots


TestBob		incbin	testbob.raw

**************************************************************************
		EVEN
		include	SysBosher.s

		END	
