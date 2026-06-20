

		opt	d+


* DEFENDER.S : My own version of the arcade classic!


* Features :

* 1) Overwide screen to negate the need for clipping;

* 2) Interleaved bitmap for massively improved speed
*    of blitter object rendering (thanks, Mike Cross!);

* 3) Clever modulo arithmetic to allow objects to live
*    on a super-wide 'virtual screen' (approx 18 real 
*    screens wide!);

* 4) Use of y-table to obviate the need for MULU etc. for
*    computing y-coord to address offset mappings;



		include	MyHardware.i

		include	MyExec2.i
		include	MyGraf2.i


* Equates. First, the 68000 interrupt vectors:


IPL1		equ	$64
IPL2		equ	$68
IPL3		equ	$6C
IPL4		equ	$70
IPL5		equ	$74
IPL6		equ	$78
IPL7		equ	$7C


* DMA and interrupt values for various activities.


DMA_SET1		equ	SETIT+DMAEN+BPLEN+COPEN+BLTEN

OLD_DMA		equ	SETIT+DMAEN+BPLEN+COPEN+BLTEN+SPREN+DSKEN

INT_SET1		equ	SETIT+INTEN+VERTB+BLIT+PORTS
INT_SET2		equ	SETIT+COPER

OLD_INT1		equ	INTEN+DSKSYNC+BLIT+VERTB
OLD_INT2		equ	COPER+PORTS+SOFT+DSKBLK
OLD_INT		equ	SETIT+OLD_INT1+OLD_INT2


* Screen data

* NOTE:WHEN ALTERING 'NPLANES', CHANGE THE INT3 SCREEN SWITCH STUFF &
* THE BITPLANE INITIALISERS!!!


NPLANES		equ	3
PTOTAL		equ	NPLANES*2
BP_WIDE		equ	44			;bytes wide
BP_TALL		equ	256			;raster lines deep
BP_SIZE		equ	BP_WIDE*BP_TALL

BP_HMOD		equ	BP_WIDE			;modulo for interleave

BP_NEXTLINE	equ	BP_HMOD*NPLANES

BP_PFTALL	equ	160			;playfield height

BP_CLR		equ	BP_TALL*64+BP_WIDE/2	;for old ScrClear()

BP_S1		equ	BP_TALL*NPLANES
BP_S2		equ	BP_S1&$3FF
BP_NEWCLR	equ	BP_S2*64+BP_WIDE/2

BP_NLMOD		equ	BP_WIDE*(NPLANES-1)+4

HORG_P		equ	160	;x origin in pixels
VORG_P		equ	128	;y origin in pixels

HDIFF		equ	120	;max disp from centre for ship

RFXSTART		equ	80	;reverse fire list x start


* Sprite values


MYHSTART		equ	190
MYVSTART		equ	120


* FireList graphics line equates


_FLST_WIDE1	equ	12		;WORDS wide
_FLST_WIDE2	equ	_FLST_WIDE1*2	;BYTES wide


* Animation Flags


_ANF_DISABLED	equ	$80	;don't display this anim

_ANF_NOSHOW	equ	$04	;set if Anim is invisible
_ANF_REVERSED	equ	$02	;reverse anim direction
_ANF_SAMEFRAME	equ	$01	;don't change frame


* AlienObject flags


_AOF_CAUGHT	equ	$01	;body caught by lander


* Animation command words


		rsreset
_ANCMD_NULL	rs.b	1
_ANCMD_ENA	rs.b	1	;enable Anim
_ANCMD_DIS	rs.b	1	;disable Anim
_ANCMD_MOVE	rs.b	1	;set anim movement

_ANCMD_DONE	equ	$FFFF	;signal to caller that cmd free to use


* ShiftKey values


_SK_LSHIFT	equ	$01
_SK_RSHIFT	equ	$02
_SK_CAPS		equ	$04
_SK_CTRL		equ	$08
_SK_LALT		equ	$10
_SK_RALT		equ	$20
_SK_LAMIGA	equ	$40
_SK_RAMIGA	equ	$80


* Special key assignments


_REVKEY		equ	_SK_LSHIFT
_THRUSTKEY	equ	_SK_LALT


* object types


_AL_CRAFT	equ	0
_AL_BODY		equ	1
_AL_LANDER	equ	2
_AL_MUTANT	equ	3
_AL_BOMBER	equ	4
_AL_BAITER	equ	5
_AL_SWARMER	equ	6
_AL_POD		equ	7


* Some key values


_CSR_LEFT	equ	$4F
_CSR_RIGHT	equ	$4E
_CSR_UP		equ	$4C
_CSR_DOWN	equ	$4D

;_REVKEY		equ	$4C
;_THRUSTKEY	equ	$4D

_HALT		equ	1

CCYC_SHIFT	equ	2
CCYC_MAX		equ	$003F

SCRL_MAXX	equ	$1FFF		;max x screen pos
SCRL_MAXV	equ	$0F		;max x screen scroll speed

FONT_BPL		equ	38		;no of bytes in 1 line
FONT_LINES	equ	8
FONT_SIZE	equ	FONT_BPL*FONT_LINES
FONT_DESC	equ	(FONT_LINES-1)*FONT_BPL

DU_PAL		equ	50	;VBLs in 1 sec/PAL
DU_NTSC		equ	60	;VBLs in 1 sec/NTSC

DDLY_STD		equ	6	;standard title screen delay

REVREPOS		equ	21	;X coord reverse value for flame

MIN_SY		equ	70	;min ship y coord

MAX_SY		equ	200	;max ship y coord


* Variable block. Referenced off A6. A6 MUST be preserved at
* all times other than during library calls!

* Main variable block definitions.


		rsreset
GrafBase		rs.l	1	;graphics library base

ScrBase		rs.l	1	;start of Alloc'ed screen RAM

CopActive	rs.l	1	;ptrs to each Copper List to use
CopWaiting	rs.l	1

RasterActive	rs.l	NPLANES	;pointers to bitplanes
RasterWaiting	rs.l	NPLANES	;pointers to bitplanes

OldInts		rs.l	7	;save ALL interrupt vectors!!!

;OldInt3		rs.l	1	;save Exec's int handler ptrs!
;OldInt2		rs.l	1	;Expect Guru otherwise...

GFXCopList	rs.l	1	;save this or else...

SpritePtrs	rs.l	8	;sprite pointers

VBLCounter	rs.l	1	;Counters used by my own
BlitCounter	rs.l	1	;interrupt routines.
CopCounter	rs.l	1
CIACounter	rs.l	1
ScrSwCnt		rs.l	1

Seed		rs.l	1	;PRNG Seed
Magic1		rs.l	1

ColourList	rs.l	1	;list of COLOR07 colours to set

YTable		rs.l	1	;ptr to Y-table

DebugL		rs.l	8

DispSCount	rs.l	1	;VBL count at start of title screen

AnimFirst	rs.l	1	;ptr to 1st Anim in list
AnimThis		rs.l	1	;ptr to current Anim
AlienAnims	rs.l	1	;ptr to beasties to kill

AlienAnFr	rs.l	6	;ptrs to alien AnimFrames

BodyAnFr		rs.l	1	;ptr to body AnimFrames

AWStartup	rs.l	1	;ptr to attack wave startup array

AnimTailLink	rs.l	1
AnimHeadLink	rs.l	1

ShipAnim		rs.l	1
FlameAnim	rs.l	1

SRevAnFrs	rs.l	2	;reverse AnFr ptrs for ship
FRevAnFrs	rs.l	2	;reverse AnFr ptrs for flame

Player1Data	rs.l	1	;ptr to Player 1 data block
Player2Data	rs.l	1	;ptr to Player 2 data block
CurrentPlayer	rs.l	1	;ptr to current player data block

FFireList	rs.l	1	;forward (i.e., L to R) fire list
RFireList	rs.l	1	;reverse (i.e., R to L) fire list

BomberList1	rs.l	1	;lists for processing the
BomberList2	rs.l	1	;Bombers

CharConvert	rs.l	1	;ptr to char conversion table
CharData		rs.l	1	;ptr to 'font'
CharTmpBuf	rs.l	1	;ptr to tmp blitter buffer

CharSrc		rs.l	1	;blitter precomp ptr to src
CharDst		rs.l	1	;blitter precomp ptr to dst

CharBltCon	rs.w	2	;blitter precomps again
CharBltMsk	rs.w	2

CharAMod		rs.w	1
CharDMod		rs.w	1

OldIRQ		rs.w	1	;old INTENA value (Exec resurrect)
OldDMA		rs.w	1	;old DMACON value (ditto)

IntExit		rs.w	1	;exit INTREQ value for Int3

CurrXPos		rs.w	1	;current screen X coordinate
CurrXSpeed	rs.w	1	;current screen movement speed
MaxScrPos	rs.w	1	;largest x coordinate allowable
MaxScrSpeed	rs.w	1	;fastest scroll speed
VertSpeed	rs.w	1	;ship up/down speed

RevCoords	rs.w	4	;Reverse coords for ship & flame

RevSeq1		rs.w	1	;coord add-on
RevEnd1		rs.w	1	;end coord to aim for
RevSeq2		rs.w	1
RevEnd2		rs.w	1

BomberCount	rs.w	1	;Used by BomberCode()

MoveDir		rs.w	1	;movement direction +/-1
OldMoveDir	rs.w	1

CharXPos		rs.w	1
CharYPos		rs.w	1

ColourCycle	rs.w	1	;cycle counter

DispUnit		rs.w	1	;No of VBL counts in 1 sec

OrdKey		rs.b	1	;normal key data from int2 handler
ShiftKey		rs.b	1	;shift key data from int2 handler
CharPrt		rs.b	1	;char to print
CharPln		rs.b	1	;char bitplanes

JoyPos		rs.b	1	;joystick position
JoyButton	rs.b	1	;joystick fire button state
ScrSwitch	rs.b	1	;screen switch flag (-1=OFF)
Reversing	rs.b	1	;-1=reverse in progress
InertiaKludge	rs.b	1	;values 0,1,2,3
FireLock		rs.b	1	;=-1 if fire button locked
;Filler		rs.b	1

vars_sizeof	rs.w	0


* Anim structure definition for interleaved bitmap


		rsreset
Anim_Next	rs.l	1	;list header
Anim_Prev	rs.l	1

Anim_Frames	rs.l	1	;ptr to frame list
Anim_CFrame	rs.l	1	;ptr to current frame list entry

Anim_XPos	rs.w	1	;X & Y base position for the
Anim_YPos	rs.w	1	;Anim

Anim_ID		rs.w	1	;unique ID for controller

Anim_Flags	rs.b	1	;flags
Anim_Filler	rs.b	1

Anim_BltPtr	rs.l	4	;precomputed BLTxPTH/L values
Anim_BltMod	rs.w	4	;precomputed BLTxMOD values
Anim_BltDat	rs.w	3	;precomputed BLTxDAT values if wanted
Anim_BltCon	rs.w	2	;precomputed BLTCON values
Anim_Masks	rs.w	2	;precomputed BLTAxWM values
Anim_Begin	rs.w	1	;precomputed BLTSIZE value

Anim_Sizeof	rs.w	0


* Animation Frame List Entry structure def.


		rsreset
AnFr_Next	rs.l	1	;doubly linked list ptrs
AnFr_Prev	rs.l	1
AnFr_Graphic	rs.l	1	;ptr to graphic
AnFr_Mask	rs.l	1	;ptr to mask
AnFr_Rows	rs.w	1	;no of raster lines
AnFr_Cols	rs.w	1	;width in WORDS
AnFr_XChange	rs.w	1	;amount to move frame by
AnFr_YChange	rs.w	1	;in X & Y directions
AnFr_Sizeof	rs.w	0


* AlienObject data structure. DO NOT FORGET TO UPDATE THE
* SHIP AND FALME STATIC STRUCTURES IF CHANGES TO THIS STRUCTURE
* DEFINITION ARE MADE!


		rsreset
AO_Anim		rs.b	Anim_Sizeof
AO_Points	rs.w	1		;points scored when hit
AO_XMove		rs.w	1
AO_YMove		rs.w	1
AO_XCnt		rs.w	1
AO_YCnt		rs.w	1
AO_SpecialCode	rs.l	1		;code to run for this
AO_BCount	rs.w	1		;for Bombers only
AO_Flags		rs.b	1		;special flags
AO_Dummy		rs.b	1

AO_Sizeof	rs.w	0


* PlayerData structure


		rsreset
pd_WaveNumber	rs.l	1	;attack wave number
pd_Score		rs.l	1	;current score
pd_NewLives	rs.l	1	;exceed this for 1 extra life
pd_NLIncr	rs.l	1	;extra life every xxxx points
pd_Lives		rs.w	1	;lives
pd_SBombs	rs.w	1	;smart bombs

pd_Bodies	rs.w	1	;bodies left to save
pd_Landers	rs.w	1	;no of landers left
pd_Mutants	rs.w	1	;no of mutants left
pd_Bombers	rs.w	1	;no of bombers left
pd_Baiters	rs.w	1	;no of baiters left
pd_Swarmers	rs.w	1	;no of swarmers left
pd_Pods		rs.w	1	;no of pods left

pd_Sizeof	rs.w	0


* FireList entry structure def


		rsreset
fl_Next		rs.l	1	;ptr to next
fl_XPos		rs.w	1	;x coordinate
fl_YPos		rs.w	1	;y coordinate
fl_Size		rs.w	1	;no of words of graphic data
fl_Offset	rs.w	1	;offset into graphic data
fl_Masks		rs.w	2	;BLTAFWM etc
fl_Data		rs.l	1	;ptr to graphic data
fl_Sizeof	rs.w	0


		section	MAIN,CODE


main		move.l	#vars_sizeof,d0		;reserve space for my
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1	;variable block
		CALLEXEC	AllocMem
		tst.l	d0		;got it?
		beq	cock_up_1	;oops-exit NOW!

		move.l	d0,a6		;keep this at ALL times!

		bsr	InitVars		;set up variable block

		bsr	InitYTable	;set up Y-Table

		lea	graf_name(pc),a1
		moveq	#0,d0
		CALLEXEC	OpenLibrary	;get graphics library
		move.l	d0,GrafBase(a6)	;got her address?
		beq	cock_up_2	;oops...

		move.l	#BP_SIZE*PTOTAL,d0	;reserve 2N bitplanes!
		move.l	#MEMF_CHIP,d1
		CALLEXEC	AllocMem
		move.l	d0,ScrBase(a6)	;got it?
		beq	cock_up_3	;exit if not

		move.l	d0,a0			;ptr to start
		move.l	d0,d2
		moveq	#0,d0
		move.w	#BP_SIZE*NPLANES,d0	;size of 1 whole screen
		move.w	#BP_WIDE,d1		;width of 1 bitplane


* Don't forget:do ONLY as many of this lot as you have bitplanes
* for each of the 2 screens otherwise the saved exception vectors
* get scribbled over!!! CHANGE THIS EVERY TIME NPLANES IS CHANGED
* TO GET THE CORRECT EFFECT!!! Note also the add.l d0,a0 to stop
* sign-extension (else runaway copperlist due to blitter overwrite
* upon executing BlitScrClrear()!!)


		lea	RasterActive(a6),a5	;ptr to these vars

		move.l	a0,(a5)+		;save bp ptr #0 scrn 1
		add.w	d1,a0
		move.l	a0,(a5)+		;save bp ptr #1 scrn 1
		add.w	d1,a0
		move.l	a0,(a5)+		;save bp ptr #2 scrn 1

		move.l	d2,a0		;ptr to top of scrn 1
		add.l	d0,a0		;ptr to top of scrn 2

		move.l	a0,(a5)+		;save bp ptr #0, scrn 2
		add.w	d1,a0
		move.l	a0,(a5)+		;save bp ptr #1, scrn 2
		add.w	d1,a0
		move.l	a0,(a5)+		;save bp ptr #2, scrn 2


		moveq	#32,d0		;now I want a Copper List
		add.l	d0,d0
		add.l	d0,d0
		move.l	#MEMF_CHIP,d1
		CALLEXEC	AllocMem
		move.l	d0,CopActive(a6)	;got one?
		beq	cock_up_4	;oops...

		moveq	#32,d0		;now I want a Copper List
		add.l	d0,d0
		add.l	d0,d0
		move.l	#MEMF_CHIP,d1
		CALLEXEC	AllocMem
		move.l	d0,CopWaiting(a6)	;got one?
		beq	cock_up_5	;oops...


* Now get PlayerData structures


		move.l	#pd_Sizeof,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l	d0,Player1Data(a6)	;got it?
		beq	cock_up_6		;oops...

		move.l	d0,a0
		clr.l	pd_WaveNumber(a0)

		move.l	#pd_Sizeof,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l	d0,Player2Data(a6)	;got it?
		beq	cock_up_7		;oops...

		move.l	d0,a0
		clr.l	pd_WaveNumber(a0)


* And now we're ready to go...


		move.l	GrafBase(a6),a0	;ptr to GFXBase struct

		move.l	38(a0),GFXCopList(a6)	;save old Copper List

		move.l	CopActive(a6),a0
		lea	RasterActive(a6),a1	;create 1st of my
		bsr	MakeCopper		;Copper Lists

		move.l	CopWaiting(a6),a0
		lea	RasterWaiting(a6),a1	;create 2nd of my
		bsr	MakeCopper		;Copper Lists

		st	OrdKey(a6)	;ensure predefined key state
		sf	ShiftKey(a6)	;for normal & shift keys

		st	ScrSwitch(a6)	;prevent scrn switching

		moveq	#0,d0
		move.l	d0,BlitCounter(a6)
		move.l	d0,CopCounter(a6)
		move.l	d0,VBLCounter(a6)
		move.l	d0,CIACounter(a6)
		move.l	d0,ScrSwCnt(a6)

whoa		nop

		CALLGRAF	OwnBlitter	;seize control of Blitter

		CALLEXEC	Forbid		;kill multitasking

		lea	$DFF000,a5	;and point to custom chips


* From here on, A5 and A6 MUST be left alone! A6 MUST point to my
* allocated variable block, and A5 MUST point to the custom chips!

* Now set up my own interrupts. Wait for picture beam to drop below bottom
* of screen before killing off sprites-prevents the spurious sprite video
* data problem...


		bsr	KillSys		;kill Exec off

		bsr	MakeMyInts	;set my own IRQ vectors


* Now activate my 1st Copper List and the various required
* interrupts/DMA channels. Also set up bitplane control and the
* other screen parameters.


		bsr	SetupScreen


* Now set my palette


		lea	Palette(pc),a0
;		moveq	#16,d0
		moveq	#8,d0
		bsr	SetPalette


* Now clear the visible screen


;		move.l	RasterActive(a6),a0
;		bsr	BlitScrClear


* Now initialise the alien Anim data structs


		bsr	InitStructs


* Now set off my ints!


main_SK1		nop


* Now hit my main program


		bsr	DoTitleScreen

		move.l	Player1Data(a6),CurrentPlayer(a6)
		bsr	InitSet

		move.l	CurrentPlayer(a6),a0
		moveq	#15,d0
		move.l	d0,pd_WaveNumber(a0)
		bsr	InitSet

		move.l	RasterActive(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		bsr	Scanner

;		bsr	MakeTestSprite

main_KW		cmp.b	#$45,OrdKey(a6)		;main program
		beq	main_KD			;loop till ESC

		st	ScrSwitch(a6)	;lock out screen switch

		move.w	CurrXPos(a6),d0	;change scrn pos
		move.w	CurrXSpeed(a6),d1	;this speed
		muls	MoveDir(a6),d1	;this direction
		add.w	d1,d0
		and.w	MaxScrPos(a6),d0	;limit to range
		move.w	d0,CurrXPos(a6)

		move.l	ShipAnim(a6),a0
		move.l	FlameAnim(a6),a1
		move.w	Anim_XPos(a0),d0
		move.w	Anim_XPos(a1),d1
		add.w	RevSeq1(a6),d0
		add.w	RevSeq1(a6),d1
		cmp.w	RevEnd1(a6),d0
		beq.s	main_KW1
		move.w	d0,Anim_XPos(a0)
		move.w	d1,Anim_XPos(a1)

main_KW1		nop

;		move.w	#$0A0,COLOR00(a5)		;debug only

		move.l	RasterWaiting(a6),a0	;clear INACTIVE
		move.w	#61,d0			;playing area
		move.w	#193,d1
		bsr	BlitWipe

		move.w	CurrXPos(a6),d0
		moveq	#4,d1
		moveq	#80,d2
		bsr	ShowWord

		move.w	CurrXSpeed(a6),d0
		moveq	#4,d1
		moveq	#90,d2
		bsr	ShowWord

		move.w	VertSpeed(a6),d0
		moveq	#4,d1
		moveq	#100,d2
		bsr	ShowWord

		move.b	JoyPos(a6),d0
		rol.w	#8,d0
		move.b	JoyButton(a6),d0
		moveq	#4,d1
		moveq	#110,d2
		bsr	ShowWord

		nop			;preAnims

		bsr	ShipUpDown
		bsr	Reverse
		bsr	ScrMove

		nop			;preAnim lines

		bsr	BlitPreComp

;		move.l	FFireList(a6),a0	;handle laser shots
		bsr	SetFire
		bsr	DoFireLists

		bsr	BlitPlot

		nop			;postAnim lines

		nop			;postAnims

		sf	ScrSwitch(a6)	;enable screen switch

;		move.w	#$FFF,COLOR00(a5)	;debug only

		bsr	WaitVBL		;wait for VBL
		
		bra	main_KW		;and back for more

main_KD		nop

		bsr	WaitVBL

		bsr	WaitMBDown


* Now recover the machine's sanity for a return to Exec.


;		move.l	OldInt2(a6),$68	;recover old interrupt
;		move.l	OldInt3(a6),$6C	;vectors

		lea	OldInts(a6),a0	;recover old IRQ
		lea	IPL1,a1		;vectors

		move.l	(a0)+,(a1)+	;IPL1 to
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+	;IPL7

		move.l	GFXCopList(a6),COP1LCH(a5)	;get old screen
		move.w	#0,COPJMP1(a5)		;back!

		move.w	OldIRQ(a6),INTENA(a5)
		move.w	OldDMA(a6),DMACON(a5)

		CALLEXEC	Permit		;recover multitasking

		CALLGRAF	DisownBlitter	;release control of Blitter

cock_up_8	move.l	Player2Data(a6),a1	;free PlayerData
		move.l	#pd_Sizeof,d0		;structure
		CALLEXEC	FreeMem

cock_up_7	move.l	Player1Data(a6),a1	;free PlayerData
		move.l	#pd_Sizeof,d0		;structure
		CALLEXEC	FreeMem

cock_up_6	move.l	CopWaiting(a6),a1	;release 2nd Copper List
		moveq	#32,d0
		add.l	d0,d0
		add.l	d0,d0
		CALLEXEC	FreeMem

cock_up_5	move.l	CopActive(a6),a1	;release 1st Copper List
		moveq	#32,d0
		add.l	d0,d0
		add.l	d0,d0
		CALLEXEC	FreeMem

cock_up_4	move.l	ScrBase(a6),a1		;free screen RAM
		move.l	#BP_SIZE*PTOTAL,d0
		CALLEXEC	FreeMem

cock_up_3	move.l	GrafBase(a6),a1	;relinquish use of
		CALLEXEC	CloseLibrary	;graphics lib

cock_up_2	move.l	a6,a1		;release my
		move.l	#vars_sizeof,d0	;variable block
		CALLEXEC	FreeMem

cock_up_1	moveq	#0,d0		;keep CLI happy
		rts


* InitVars(a6)
* a6 = ptr to main program variables

* Set up the main variable table and various pointers.

* d0-d1/a0-a1 corrupt


InitVars		moveq	#0,d0

		move.w	d0,CurrXPos(a6)
		move.w	d0,CurrXSpeed(a6)

		move.w	d0,ColourCycle(a6)

		move.b	d0,JoyPos(a6)
		move.b	d0,JoyButton(a6)

		move.l	#$01020304,d0	;magic number for the
		move.l	d0,Magic1(a6)	;PRNG...
		move.l	#$FE291D4B,d0
		move.l	d0,Seed(a6)	;...and initial seed

		move.w	#SCRL_MAXX,d0
		move.w	d0,MaxScrPos(a6)	;set upper screen limit
		moveq	#SCRL_MAXV,d0
		move.w	d0,MaxScrSpeed(a6)

		move.w	#BP_NEXTLINE-4,d0		;font dst modulo
		move.w	d0,CharDMod(a6)
		moveq	#FONT_BPL-4,d0		;font src modulo
		move.w	d0,CharAMod(a6)

		moveq	#DU_PAL,d0
		move.w	d0,DispUnit(a6)

		lea	Anim1,a0
		move.l	a0,AnimFirst(a6)
		move.l	a0,AnimThis(a6)
		move.l	a0,ShipAnim(a6)
		move.l	Anim_Next(a0),a0
		move.l	a0,FlameAnim(a6)

		lea	Anim3,a0
		move.l	a0,AlienAnims(a6)

		lea	CTab1,a0
		move.l	a0,CharConvert(a6)
		lea	NewCSet,a0
		move.l	a0,CharData(a6)
		lea	CBBuf,a0
		move.l	a0,CharTmpBuf(a6)

		lea	AWArray,a0
		move.l	a0,AWStartup(a6)

		lea	FlashTab,a0
		move.l	a0,ColourList(a6)

		lea	AlienAnFr(a6),a0
		lea	A3F1,a1
		move.l	a1,(a0)+		;set up alien AnFr pointers
		lea	A4F1,a1
		move.l	a1,(a0)+
		lea	A5F1,a1
		move.l	a1,(a0)+
		lea	A6F1,a1
		move.l	a1,(a0)+
		lea	A7F1,a1
		move.l	a1,(a0)+
		lea	A8F1,a1
		move.l	a1,(a0)+

		lea	A9F1,a0
		move.l	a0,BodyAnFr(a6)

		lea	A1FF1,a0			;set up reverse
		lea	A1RF1,a1			;AnFr ptrs for
		movem.l	a0-a1,SRevAnFrs(a6)	;ship

		lea	A2FF1,a0
		lea	A2RF1,a1
		movem.l	a0-a1,FRevAnFrs(a6)	;and flame

		moveq	#-REVREPOS,d0		;reverse re-position
		moveq	#REVREPOS,d1		;values for
		swap	d1			;flame Anim
		move.w	d0,d1
		moveq	#0,d0
		movem.l	d0-d1,RevCoords(a6)

		moveq	#-4,d0		;reverse sequence 1
		move.w	#HORG_P-HDIFF,d1	;movement & end coords
		move.w	d0,RevSeq1(a6)
		move.w	d1,RevEnd1(a6)

		moveq	#4,d0		;reverse sequence 2
		move.w	#HORG_P+HDIFF,d1	;movement & end coords
		move.w	d0,RevSeq2(a6)
		move.w	d1,RevEnd2(a6)

		moveq	#-1,d0
		move.w	d0,MoveDir(a6)

		lea	BList1,a0
		lea	BList2,a1
		move.l	a0,BomberList1(a6)
		move.l	a1,BomberList2(a6)

		lea	LSF_Spr1,a0
		lea	LSR_Spr1,a1
		move.l	a0,FFireList(a6)
		move.l	a1,RFireList(a6)

		lea	_YTab,a0
		move.l	a0,YTable(a6)
		rts


* InitYTable(a6)
* a6 = ptr to main program variables

* Initialise Y-Table (offsets from top of screen for y=0 to y=255).

* d0-d1/a0 corrupt


InitYTable	moveq	#0,d0			;counter/offset
		move.w	#BP_NEXTLINE,d1		;displ. for 1 line
		move.l	YTable(a6),a0

IYT_L1		swap	d0		;get Y-Table entry
		move.w	d0,(a0)+		;write it in
		add.w	d1,d0		;create next entry
		swap	d0		;get counter
		addq.b	#1,d0		;256 of them
		bne.s	IYT_L1		;trick-work it out!
		rts


* KillSys(a6)
* a6 = ptr to main program variables

* Kill off Exec etc., for the duration of the game
* d0 corrupt


KillSys		cmp.b	#255,VHPOSR(a5)		;wait for beam
		bne.s	KillSys			;to hit bottom


* NOTE : don't forget to set the SETIT bit of the Exec IRQ and
* DMA enables beforehand! Else writing them will DISABLE the
* functions (SETIT = 0)!


		move.w	INTENAR(a5),d0		;save Exec IRQ
		bset	#15,d0
		move.w	d0,OldIRQ(a6)		;enables

		move.w	DMACONR(a5),d0		;and Exec DMA
		bset	#15,d0
		move.w	d0,OldDMA(a6)		;enables

		move.w	#$7FFF,d0

		move.w	d0,DMACON(a5)		;kill DMA
		move.w	d0,INTENA(a5)		;disable ints
		move.w	d0,INTREQ(a5)		;cancel IRQs

		rts


* SetupScreen(a6)
* a6 = ptr to my main variables

* Set up my 3-bitplane interleaved bitmap screen, and then
* activate the copper list.

* d0 corrupt


SetupScreen	move.w	#$3200,BPLCON0(a5)	;3 bitplanes
		move.w	#0,BPLCON1(a5)		;no scroll values
		move.w	#0,BPLCON2(a5)		;no special priority

		move.w	#BP_NLMOD,d0		;special bitplane
		move.w	d0,BPL1MOD(a5)		;modulos for overwide
		move.w	d0,BPL2MOD(a5)		;interleaved screen

		move.w	#$2C81,DIWSTRT(a5)	;display window
		move.w	#$2CC1,DIWSTOP(a5)	;raster beam pos

		move.w	#$38,DDFSTRT(a5)		;data fetch values
		move.w	#$D0,DDFSTOP(a5)

		move.w	#DMA_SET1,DMACON(a5)	;Activate DMA and
		move.w	#INT_SET1,INTENA(a5)	;interrupts

;		move.b	#$88,CIAAICR	;set CIA interrupt ctrl
;		move.b	#$20,CIAACRA	;and main control

		move.l	CopActive(a6),COP1LCH(a5)	;activate Copper
		move.w	#0,COPJMP1(a5)		;List

		rts


* MakeMyInts(a6)
* a6 = ptr to main program variables

* Save old Exec interrupt vectors, and replace them with my own

* a0-a1 corrupt.


MakeMyInts	lea	OldInts(a6),a0	;ptr to save area
		lea	IPL1,a1		;ptr to 680x0 interrupt vectors

		move.l	(a1)+,(a0)+	;save IPL1
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+	;to IPL7

		lea	NullInt(pc),a0	;now NullInt() out the
		lea	IPL1,a1		;interrupt vectors

		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+

		lea	Int2Handler(pc),a0	;CIA-A interrupt
		move.l	a0,IPL2			;handler

		lea	Int3Handler(pc),a0	;handle VBL, Copper
		move.l	a0,IPL3			;& Blitter ints

		rts


* InitPlayer(a0)
* a0 = ptr to PlayerData structure to initialise

* Set up PlayerData structure. If initial wave number = 0,
* then set it up from scratch, else alter existing values.

* NOTE:doesn't yet replace lost bodies if body count drops to 0!

* d0-d1/a1-a2 corrupt


InitPlayer	move.l	pd_WaveNumber(a0),d0	;get wave number

		cmp.l	#15,d0		;too big?
		bls.s	INP_1		;skip if not
		moveq	#15,d0		;else wave 15

INP_1		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,d1
		add.l	d1,d1		;wave number * 12

		move.l	AWStartup(a6),a1
		lea	0(a1,d1.l),a1	;point to attack wave
		lea	pd_Landers(a0),a2	;point to Lander data

		move.w	(a1)+,(a2)+	;pop in data for
		move.w	(a1)+,(a2)+	;numbers of odd bods
		move.w	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		move.w	(a1)+,(a2)+

		tst.l	d0		;1st attack wave?
		bne.s	INP_2		;skip if not

		move.l	d0,pd_Score(a0)	;else init score
		moveq	#3,d1
		move.w	d1,pd_Lives(a0)	;initial lives count
		move.w	d1,pd_SBombs(a0)	;& smart bombs

		moveq	#0,d1
		move.w	#10000,d1
		move.l	d1,pd_NewLives(a0)
		move.l	d1,pd_NLIncr(a0)
		moveq	#10,d1
		move.w	d1,pd_Bodies(a0)	;and bodies to save

INP_2		addq.l	#1,pd_WaveNumber(a0)	;attack wave NNNN

		rts


* InitStructs(a6)
* a6 = ptr to main program variables

* Initialise alien Anim structs:create the complete list of structs
* & link them to the two structs for the player object (note:doubly
* linked list!).

* d0-d2/a1-a3 corrupt


InitStructs	move.l	AnimFirst(a6),a1
		move.l	a1,AnimTailLink(a6)	;_Next for final...
		move.l	Anim_Next(a1),a1
		move.l	a1,AnimHeadLink(a6)	;_Prev for 1st alien

		move.l	AlienAnims(a6),a2		;1st alien Anim

		moveq	#102,d0			;number to do

		move.l	a2,a3			;copy ptr to this

INS_1		add.w	#AO_Sizeof,a3		;make ptr to next

		move.l	a3,Anim_Next(a2)		;ptr to next
		move.l	a1,Anim_Prev(a2)		;ptr to prev

		move.b	#_ANF_DISABLED,Anim_Flags(a2)

		clr.l	AO_SpecialCode(a2)	;kill code ptr

		move.l	a2,a1			;old this => new prev
		move.l	a3,a2			;old next => new this

		subq.w	#1,d0			;done them all?
		bne.s	INS_1			;back for more if not

		move.l	a1,a2			;this = last alien
		move.l	AnimTailLink(a6),a1
		move.l	a1,Anim_Next(a2)		;next(lastalien)=1st
		move.l	a2,Anim_Prev(a1)		;prev(1st)=lastalien

		move.l	AnimHeadLink(a6),a1
		move.l	AlienAnims(a6),a2
		move.l	a2,Anim_Next(a1)		;next(2nd)=1stalien
		rts


* InitSet(a6)
* a6 = ptr to main program variables

* Initialise game state for given player.

* d0-d4/a0-a3 corrupt


InitSet		move.l	CurrentPlayer(a6),a0
		bsr	InitPlayer

		clr.w	BomberCount(a6)

		move.l	AlienAnims(a6),a1		;ptr to 1st Anim

		move.w	pd_Bodies(a0),d0		;any Bodies?
		beq.s	IST_1			;skip if not

		move.l	BodyAnFr(a6),d1		;get Anim frame ptr

IST_L1		move.l	d1,Anim_Frames(a1)	;pop in AnFr ptrs
		move.l	d1,Anim_CFrame(a1)
		bsr	Random
		move.l	Seed(a6),d2
		and.w	MaxScrPos(a6),d2
		move.w	d2,Anim_XPos(a1)		;random X position
		move.w	#180,Anim_YPos(a1)	;fixed Y position
		move.w	#_AL_BODY,Anim_ID(a1)	;object ID
		clr.b	Anim_Flags(a1)		;enable Anim

		move.l	Anim_Next(a1),a1		;next struct
		subq.w	#1,d0			;done them all?
		bne.s	IST_L1			;back if not

IST_1		lea	AlienAnFr(a6),a2	;ptr to array of AnFr ptr
		lea	pd_Landers(a0),a3	;ptr to alien count array
		lea	SVArray,a0	;ptr to SpecialValues array
		moveq	#_AL_LANDER,d3
		moveq	#6,d4		;no. to do

IST_L3		move.l	(a2)+,d1		;get Anim frame ptr

		move.w	(a3)+,d0		;any aliens?
		beq.s	IST_2		;skip if not


IST_L2		move.l	d1,Anim_Frames(a1)	;set up AnFr's
		move.l	d1,Anim_CFrame(a1)
		move.w	d3,Anim_ID(a1)		;set type
		clr.b	Anim_Flags(a1)		;enable Anim

		move.w	(a0),AO_Points(a1)
		move.w	2(a0),AO_XMove(a1)
		move.w	4(a0),AO_YMove(a1)
		move.l	6(a0),AO_SpecialCode(a1)

IST_3		clr.b	AO_Flags(a1)

		move.l	Anim_Next(a1),a1		;next struct
		subq.w	#1,d0			;done them all?
		bne.s	IST_L2			;back if not

IST_2		nop

		add.w	#10,a0		;next SVArray entry

		addq.w	#1,d3		;next type
		subq.w	#1,d4		;done all types?
		bne.s	IST_L3		;back for more if not

		rts


* Random(a6)
* a6 = ptr to main program variables
* Generate pseudo-random number using one of my famous PRNGs.
* Steor result in vars pointed to by A6.

* no registers corrupt


Random		movem.l	d0-d1,-(sp)	;save work registers
		move.l	Seed(a6),d0	;get seed
		move.l	d0,d1		;copy it
		move.b	#$AA,d1		
		ror.l	d0,d0		;do this to copy 1
		add.l	Magic1(a6),d0
		eor.l	d1,d0
		addq.l	#1,d0
		move.l	d0,Seed(a6)	;and save for next call
		movem.l	(sp)+,d0-d1	;recover work regs
		rts


* MakeCopper(a0,a1)
* a0 = ptr to desired Copper List
* a1 = ptr to list of bitplane pointers

* Generate a Copper list. Generates bitplane instructions,
* then puts a WAIT $FFFE instruction at the end.

* d0-d2/a0-a2 corrupt


MakeCopper	move.w	#BPL1PTH,d0	;1st bitplane ptr reg no.

		moveq	#NPLANES,d1	;3 bitplanes???

MCList_1		move.l	(a1)+,d2		;get a bitplane pointer
		addq.l	#2,d2		;take account of overwide!
		swap	d2		;high word of addr
		move.w	d0,(a0)+		;create Copper MOVE
		move.w	d2,(a0)+		;with this value
		addq.w	#2,d0		;now get PTL reg no
		swap	d2		;low word of addr
		move.w	d0,(a0)+		;create Copper MOVE
		move.w	d2,(a0)+		;with this value
		addq.w	#2,d0		;now next PTH reg no

		subq.w	#1,d1		;done them all?
		bne.s	MCList_1		;back for more if not

		moveq	#-2,d0		;WAIT $FFFE
		move.l	d0,(a0)		;and finish Copper list

		rts


* LtoA(d0,a0,a1) -> a0
* d0 = long integer to convert to string
* a0 = buffer for the string
* a1 = null terminated list of LONGs (powers of 10)

* Returns a0 = ptr to numeric ASCII string

* Convert a long integer (unsigned) to an ASCIIZ string.
* Note that this can be of ANY base provided that the
* pointer to a list of ULONG powers of N, where N is
* the base. Normal usage is to point a1 at a list of
* powers of 10. If creating Octals, then use a table of
* powers of 8...table MUST be in DECREASING order!

* d1-d2/a2 corrupt

LtoA		tst.l	d0		;X = 0?
		bne.s	LtoA_1		;skip if not
		move.w	#$3000,(a0)	;else make string "0"
		rts			;and done

LtoA_1		move.l	a0,a2		;copy string buffer ptr

LtoA_2		move.l	(a1)+,d1		;get P = power of N
		cmp.l	d1,d0		;while X < P
		bcs.s	LtoA_2		;back for next P


* Now, we've found a P such that X >=P. Now begin conversion proper.


LtoA_3		moveq	#0,d2		;value of this digit

LtoA_4		cmp.l	d1,d0		;X < P?
		bcs.s	LtoA_5		;skip if X < P
;		beq.s	LtoA_6		;and if X = P
		addq.b	#1,d2		;digit = digit + 1
		sub.l	d1,d0		;X = X - P
		bra.s	LtoA_4		;and resume test

;LtoA_6		sub.l	d1,d0		;X = X - P
;		addq.b	#1,d2

LtoA_5		add.b	#"0",d2		;make ASCII digit
		move.b	d2,(a2)+		;store in string buffer

		move.l	(a1)+,d1		;get next P
		bne.s	LtoA_3		;back for more P <> 0

		clr.b	(a2)		;append EOS

		rts			;done!!!
		

* Powers of 10 for use with above routine. Note if ANY power table is
* used, it MUST end in a zero longword!


Base10		dc.l	1000000000,100000000,10000000
		dc.l	1000000,100000,10000,1000,100,10,1
		dc.l	0


* StrLen(a0) -> d7
* a0 = ptr to ASCIIZ string to find length of
* returns no. of chars (excluding terminating NULL) in d7

* no other registers corrupt


StrLen		move.l	a0,-(sp)		;save string ptr
		moveq	#0,d7		;char count

StrLen_1		tst.b	(a0)+		;EOS hit?
		beq.s	StrLen_2		;exit if so
		addq.l	#1,d7		;else update char count
		bra.s	StrLen_1		;and back for more

StrLen_2		move.l	(sp)+,a0		;recover string ptr
		rts			;and done


* ShipUpDown(a6)
* a6 = ptr to main program variables

* Set ship up/down speed according to the values read from
* the joystick. Assumes joystick in gameport 1, which is
* read via the VBL interrupt.

* d0-d2/a0-a1 corrupt

ShipUpDown	move.b	JoyPos(a6),d0

		move.b	d0,d1
		and.b	#1,d1		;joystick up?
		beq.s	SUP_1		;skip if not

		move.w	VertSpeed(a6),d0	;up/down speed
		addq.w	#1,d0		;increase it
		cmp.w	#4,d0		;too big?
		bhi.s	SUP_1a		;skip if so
		move.w	d0,VertSpeed(a6)	;else set it

SUP_1a		move.l	ShipAnim(a6),a0	;ptrs to ship &
		move.l	FlameAnim(a6),a1	;flame Anims
		move.w	VertSpeed(a6),d0

		move.w	Anim_YPos(a0),d1	;get Y coords
		move.w	Anim_YPos(a1),d2

		sub.w	d0,d1		;change y coords
		cmp.w	#MIN_SY,d1	;too small?
		bls.s	SUP_1b		;skip if so
		move.w	d1,Anim_YPos(a0)	;else change ship pos
		sub.w	d0,d2
		move.w	d2,Anim_YPos(a1)	;and flame pos
		
SUP_1b		rts			;and done

SUP_1		move.b	d0,d1		;joystick down?
		and.b	#2,d1
		beq.s	SUP_2		;skip if not

		move.w	VertSpeed(a6),d0	;up/down speed
		addq.w	#1,d0		;increase it
		cmp.w	#4,d0		;too big?
		bhi.s	SUP_2a		;skip if so
		move.w	d0,VertSpeed(a6)	;else set it

SUP_2a		move.l	ShipAnim(a6),a0	;ptrs to ship &
		move.l	FlameAnim(a6),a1	;flame Anims
		move.w	VertSpeed(a6),d0

		move.w	Anim_YPos(a0),d1	;get Y coords
		move.w	Anim_YPos(a1),d2

		add.w	d0,d1		;change y coords
		cmp.w	#MAX_SY,d1	;too big?
		bcc.s	SUP_2b		;skip if so
		move.w	d1,Anim_YPos(a0)	;else change ship pos
		add.w	d0,d2
		move.w	d2,Anim_YPos(a1)	;and flame pos
		
SUP_2b		rts			;and done

SUP_2		tst.w	VertSpeed(a6)	;already zero?
		beq.s	SUP_Done		;skip if so

		subq.w	#1,VertSpeed(a6)	;else reduce it

SUP_Done		rts


* ScrMove(a6)
* a6 = ptr to main program variables

* Set scroll speed for screen.
* If key is pressed & held down, speed is increased until it
* hits a predetermined maximum. Once key is released, the speed
* is progressively reduced to zero.

* Note extra code to maintain inertia while reversing!

* d0-d4/a0 corrupt


ScrMove		move.l	FlameAnim(a6),a0		;ptr to flame Anim

		or.b	#_ANF_NOSHOW,Anim_Flags(a0)

;		move.b	OrdKey(a6),d1	;get key
;		cmp.b	#_THRUSTKEY,d1	;cursor left?
;		bne.s	ScrM_1		;skip if not

		move.b	ShiftKey(a6),d1
		and.b	#_THRUSTKEY,d1
		beq.s	ScrM_1

		move.w	MaxScrSpeed(a6),d0	;upper speed

		move.w	CurrXSpeed(a6),d1	;current speed
		addq.w	#1,d1		;increase speed
		cmp.w	d0,d1		;too fast?
		bhi.s	ScrM_1a		;skip if so
		move.w	d1,CurrXSpeed(a6)	;else update

ScrM_1a		clr.b	Anim_Flags(a0)

		rts

ScrM_1		tst.w	CurrXSpeed(a6)	;current speed
		beq.s	ScrM_1b		;skip if already zero

		move.b	InertiaKludge(a6),d0
		subq.b	#1,d0
		and.b	#1,d0
		move.b	d0,InertiaKludge(a6)
		bne.s	ScrM_1b

		subq.w	#1,CurrXSpeed(a6)	;else reduce it

ScrM_1b		rts


* Reverse(a6)
* a6 = ptr to main program variables

* Reverse the direction of the ship.

* d0-d5/a0-a1 corrupt


Reverse		nop

		tst.b	Reversing(a6)		;last reverse done?
		bne	RevDone			;no-don't do it yet

;		move.b	OrdKey(a6),d0		;get key
;		cmp.b	#_REVKEY,d0		;reverse key?
;		bne.s	RevDone			;skip if not

		move.b	ShiftKey(a6),d0
		and.b	#_REVKEY,d0
		beq.s	RevDone

		move.l	ShipAnim(a6),a0		;ptr to ship Anim
		move.l	FlameAnim(a6),a1		;ptr to flame Anim

		move.l	Anim_Frames(a1),d0	;check which AnFr
		cmp.l	Anim_CFrame(a1),d0	;frame #1?
		bne.s	RevDone			;don't reverse!

		movem.l	SRevAnFrs(a6),d0-d1	;get ship AnFr seqs
		exg	d0,d1
		movem.l	d0-d1,SRevAnFrs(a6)	;swap around

		movem.l	FRevAnFrs(a6),d2-d3	;get flame AnFr seqs
		exg	d2,d3
		movem.l	d2-d3,FRevAnFrs(a6)	;swap around

		movem.l	FFireList(a6),d4-d5
		exg	d4,d5
		movem.l	d4-d5,FFireList(a6)

		movem.l	RevCoords(a6),d4-d5	;get coords
		swap	d4
		swap	d5
		movem.l	d4-d5,RevCoords(a6)

		move.l	d0,Anim_Frames(a0)	;change image
		move.l	d0,Anim_CFrame(a0)	;of ship

		move.l	d2,Anim_Frames(a1)	;change image
		move.l	d2,Anim_CFrame(a1)	;of flame

		add.w	d4,Anim_XPos(a0)		;change frame
		add.w	d5,Anim_XPos(a1)		;plot positions

		movem.l	RevSeq1(a6),d0-d1
		exg	d0,d1
		movem.l	d0-d1,RevSeq1(a6)

		neg.w	MoveDir(a6)		;change direction

		st	Reversing(a6)		;signal in progress

RevDone		rts


* NullInt()

* This is a NULL interrupt handler to kill off Exec interrupt
* handling by accident. It does nothing except an RTE, just in
* case an interrupt of this type DOES occur (but it shouldn't).


NullInt		move.w	d0,-(sp)		;save this

		move.w	INTREQR(a5),d0	;do this to keep the
		and.w	#$7FFF,d0
		move.w	d0,INTREQ(a5)	;4703 happy

		move.w	(sp)+,d0		;and recover this
		rte			;done!!


* Int2Handler()
* Handle Level 2 interrupt (CIA-A)
* Get key value etc


Int2Handler	movem.l	d0-d5/a6,-(sp)

		move.w	#$2200,SR	;prevent interrupt nesting

		move.w	INTREQR(a5),d0
		bclr	#15,d0		;ensure IRQ acknowledge
		bclr	#3,d0		;of CIA interrupt
		move.w	d0,INTREQ(a5)	;and tell 4703 about it

		move.b	CIAAICR,d1	;check CIA source
		bclr	#7,d1

		addq.l	#1,CIACounter(a6)	;one of many counters...

		move.b	CIAASP,d2	;get key press
		or.b	#$40,CIAACRA	;pull KCLK low (SPMODE output)

		not.b	d2
		ror.b	#1,d2		;get correct key code

		move.b	d2,d3		;copy key code
		bclr	#7,d3		;clear keyup bit of copy
		cmp.b	#$60,d3		;is it a shift-type key?
		bcc.s	Int2_3		;yes

		tst.b	d2		;key up?
		bmi.s	Int2_4		;yes
		move.b	d3,OrdKey(a6)	;else save ordinary key
		bra.s	Int2_2		;and exit Int2

Int2_4		st	OrdKey(a6)	;keyup so 'clear' it
		clr.b	Reversing(a6)	;and ship reverse flag

;		clr.b	ShiftKey(a6)	;and the shifts??
		bra.s	Int2_2		;and exit Int2

Int2_3		moveq	#0,d4		;shift key state to record
		move.b	ShiftKey(a6),d5	;shifts already gotten
		sub.b	#$60,d3		;get shift bit no
		bset	d3,d4		;& set the shift bit
		clr.b	Reversing(a6)	;and ship reverse flag

		tst.b	d2		;is it keyup?
		bmi.s	Int2_5		;yes
		or.b	d4,d5		;else add a new one
		move.b	d5,ShiftKey(a6)	;and set it
		bra.s	Int2_2		;and exit Int2

Int2_5		not.b	d4		;subtract a shift state
		and.b	d4,d5
		move.b	d5,ShiftKey(a6)	;signal new shift state

Int2_2		nop

		moveq	#4,d2		;wait for 75 microsecs
Int2_6		subq.w	#1,d2
		bne.s	Int2_6

		and.b	#$BF,CIAACRA	;SPMODE=input again

Int2_1		movem.l	(sp)+,d0-d5/a6
		rte


* Int3Handler()
* Handle Level 3 Interrupt
* a5 MUST point to custom chips!

* Handles Copper, Blitter and Vertical Blank interrupts.

* Note : Joystick read on vertical blank!!!

* Also : VBL handler will eventually read Mouse/Joystick. It al-
* ready switches screens. For interleaved bitmaps, only ONE bit-
* plane pointer needs to be swapped around & is thus quicker.


Int3Handler	movem.l	d0-d7/a0-a6,-(sp)	;save these

;		move.w	#$2300,SR	;prevent interrupt nesting
		move.w	#$2700,SR	;prevent interrupt nesting

		clr.w	IntExit(a6)	;ensure no extra IRQs

		move.w	INTREQR(a5),d0	;check which int occurred
		bclr	#15,d0		;signal IRQ acknowledge
		move.w	d0,INTREQ(a5)	;and tell 4703 about it

		btst	#6,d0		;Blitter?
		beq.s	Int3_1		;no

		addq.l	#1,BlitCounter(a6)	;add to blitter counter

Int3_1		btst	#5,d0		;VBL?
		beq	Int3_2		;no

		addq.l	#1,VBLCounter(a6)	;add to VBL counter

		move.l	VBLCounter(a6),d1	;cycle colour 7 for the
		lsr.l	#CCYC_SHIFT,d1	;special effect
		and.l	#CCYC_MAX,d1
		move.w	d1,ColourCycle(a6)	;cycle no
		move.l	ColourList(a6),a0		;cycle table
		add.l	d1,d1			;WORD offset
		move.w	0(a0,d1.l),d1		;this entry
		move.w	d1,COLOR07(a5)		;set colour!

		tst.b	ScrSwitch(a6)	;screen switching allowed?
		bne.s	Int3_JR		;skip if not

		st	ScrSwitch(a6)	;prevent unwanted screen switch

		lea	CopActive(a6),a0	;point to screen/Copper
		movem.l	(a0),d1-d2	;variables
		exg	d1,d2		;prepare screen switch
		movem.l	d1-d2,(a0)	;replace them swapped around

		move.l	d1,COP1LCH(a5)	;do screen switch

		move.w	#0,COPJMP1(a5)	;NOW!!!!

		move.l	RasterActive(a6),d1	;change the screen
		move.l	RasterWaiting(a6),d2	;pointers for the
		exg	d1,d2			;Anim system
		move.l	d1,RasterActive(a6)
		move.l	d2,RasterWaiting(a6)

		addq.l	#1,ScrSwCnt(a6)	;count screen switches


* Now read joystick. Read JOY1DAT once, do up/down test only for
* this game.


Int3_JR		move.w	JOY1DAT(a5),d1	;get value
		move.w	d1,d2		;copy value read
		add.w	d2,d2		;move bits 0/8 to bits 1/9
		eor.w	d1,d2		;for up/down check
		moveq	#0,d3		;JoyPos var value
		moveq	#1,d4		;up/down bit

		btst	#9,d2		;joystick up?
		beq.s	Int3_JR1		;skip if not
		or.w	d4,d3		;else set UP bit
Int3_JR1		add.w	d4,d4		;now make DOWN bit
		btst	#1,d2		;joystick down?
		beq.s	Int3_JR2		;skip if not
		or.w	d4,d3		;else set DOWN bit

Int3_JR2		move.b	d3,JoyPos(a6)	;signal value

		moveq	#-1,d2		;JoyButton var value
		move.b	CIAAPRA,d1	;get joystick fire button
		bpl.s	Int3_JR3		;skip if button pressed
		not.b	d2		;else signal released
		clr.b	FireLock(a6)	;and unlock fire button
Int3_JR3		move.b	d2,JoyButton(a6)

Int3_2		btst	#4,d0		;Copper?
		beq.s	Int3_3		;no

		addq.l	#1,CopCounter(a6)	;add to Copper counter

Int3_3		move.w	IntExit(a6),d0	;see if any blitter routine
		beq.s	Int3_Done	;wants BLIT int restarting

		move.w	d0,INTREQ(a5)	;come here if it does

Int3_Done	movem.l	(sp)+,d0-d7/a0-a6
		rte


* This lot of routines handles the Blitter. Two sets of routines
* are needed, one for plotting animated objects (and animating them)
* and one for drawing various lines (which have to be done on a sin-
* gle bitplane strip first and then rendered in)

* Note:major problem is masks. In interleaved format, they need to be
* the SAME SIZE as the graphic (instead of being only 1 bitplane deep).

* First routine is BlitPreComp() which precomputes all of the
* Blitter register values for all Anims. Then, BlitPlot() plots
* all Anims and changes Animation frames for the next round.

* Calling synopsis:

* 1) Lock out screen switching;

* 2) Call BlitScrClear() for the INACTIVE screen;

* 3) Do all pre-Anim code;

* 4) Call any pre-Anim line drawing routines;

* 5) Call BlitPreComps();

* 6) Call BlitPlot();

* 7) Call any post-Anim line drawing routines;

* 8) Do all other post-Anim code;

* 9) Allow screen switching & wait for VBL before
*	performing next round.


* BlitPreComp(a6)
* a6 = ptr to main program variables

* Perform blitter register value precomputations for use by BlitPlot().

* d0-d6/a0-a3 corrupt


BlitPreComp	move.l	AnimFirst(a6),a0		;ptr to 1st Anim struct

BPC_L1		move.b	Anim_Flags(a0),d0		;check if disabled
		move.b	d0,d1
		and.b	#_ANF_DISABLED,d0		;is it?
		bne	BPC_1			;skip if disabled


* Here, execute the SpecialCode for each of the objects if
* required. DON'T TRASH A0!!


		move.l	AO_SpecialCode(a0),d0	;code pointer exists?
		beq.s	BPC_X1			;skip if not
		move.l	d0,a1
		jsr	(a1)			;else execute it


* Here, handle the x coordinates of the object relative to the screen.
* If it's one of the non-scolling Anims, don't bother!


BPC_X1		tst.w	Anim_ID(a0)		;non-scroller?
		beq.s	BPC_2
		and.b	#$FF-_ANF_NOSHOW,d1	;temp visible enable
		move.b	d1,Anim_Flags(a0)

		move.w	CurrXPos(a6),d0
		move.w	Anim_XPos(a0),d1
		add.w	d0,d1		;updated x position
		move.w	MaxScrPos(a6),d2
		and.w	d2,d1		;constrain to screen limits
		sub.w	#16,d2

		cmp.w	#320,d1		;on screen?
		bcs.s	BPC_2		;skip if on screen RHS

		cmp.w	d2,d1		;on screen?
		bhi.s	BPC_2		;skip if on screen LHS


* Here, it's off screen so make it invisible...


BPC_X2		or.b	#_ANF_NOSHOW,Anim_Flags(a0)


* DON'T RESTORE X COORD! AGH BUG! if 1st round = 160, keep it 160
* because test above performed on object x PLUS screen x!!!

* Now animate using the AnFr_XChange vars if needed, not forgetting to
* prevent off-screen vertical movements...


BPC_2		move.l	Anim_CFrame(a0),a1	;ptr to Anim Frame
		move.w	AnFr_XChange(a1),d1	;get velocity
		move.w	AnFr_YChange(a1),d2
		move.w	Anim_XPos(a0),d3		;get position
		move.w	Anim_YPos(a0),d4

		add.w	d1,d3		;change x position
		move.w	d3,Anim_XPos(a0)	;and save back

		add.w	d2,d4		;change y position
		bmi.s	BPC_Ena		;skip if off screen
		move.w	#256,d5
		sub.w	AnFr_Rows(a1),d5
		cmp.w	d5,d4
		bhi.s	BPC_Ena		;skip if off screen
		move.w	d4,Anim_YPos(a0)	;else save y position back

;		add.w	d1,Anim_XPos(a0)
;		add.w	d2,Anim_YPos(a0)

		move.b	Anim_Flags(a0),d1
		and.b	#_ANF_NOSHOW,d1		;invisible?
		bne	BPC_1			;skip if invisible


* Here, we've got an enabled Anim. So do its precomps. Don't forget that
* the order within multiple RS defs is CBAD!


BPC_Ena		move.l	Anim_CFrame(a0),a1	;get current frame
		move.l	AnFr_Graphic(a1),d5	;point to graphic
		move.l	AnFr_Mask(a1),d6		;and mask

		move.l	RasterWaiting(a6),a2	;ptr to scr base
;		move.l	RasterActive(a6),a2
		addq.l	#2,a2			;overwide screen

		moveq	#0,d0
		move.w	Anim_YPos(a0),d0
		move.l	YTable(a6),a3		;use y-table lookup-
		add.w	d0,d0			;far faster than a
		move.w	0(a3,d0.w),d0		;multiply
;		mulu	#BP_NEXTLINE,d0
		add.l	d0,a2
		move.w	Anim_XPos(a0),d0		;starting x position
		tst.w	Anim_ID(a0)		;non-scrolling Anims?
		beq.s	BPC_B1			;skip if so
		add.w	CurrXPos(a6),d0		;plus screen pos
		move.w	MaxScrPos(a6),d1
		sub.w	#16,d1			;off LHS?
		cmp.w	d1,d0
		bls.s	BPC_B1
		sub.w	MaxScrPos(a6),d0		;handle part offscreen
BPC_B1		move.w	d0,d1
		asr.w	#4,d1			;int(x/16)
		add.w	d1,d1			;WORD offset
		add.w	d1,a2
		move.l	a2,d4			;BLTCPTH/L
		move.l	a2,d7			;BLTDPTH/L

		and.w	#$F,d0			;frac(x/16)
		ror.w	#4,d0
		move.w	d0,d1			;BLTCON1
		or.w	#$FCA,d0			;BLTCON0
		swap	d0
		move.w	d1,d0

		moveq	#-1,d1			;BLTAFWM/LWM
		clr.w	d1			;LT Part 2

		moveq	#-2,d2			;BLTAMOD/BLTBMOD
		move.w	d2,d3			;LT Part 1
		swap	d3			;BLTAMOD here
		move.w	AnFr_Cols(a1),d3
		addq.w	#1,d3			;LT Part 2
		add.w	d3,d3			;BYTE modulo
		neg.w	d3
		add.w	#BP_HMOD,d3		;=BLTCMOD/BLTDMOD
		swap	d2
		move.w	d3,d2
		swap	d2			;all MODs in place

		movem.l	d4-d7,Anim_BltPtr(a0)	;Now store all the
		movem.l	d2-d3,Anim_BltMod(a0)	;precomputed
		movem.l	d0-d1,Anim_BltCon(a0)	;blitter values

		move.w	AnFr_Cols(a1),d0		;this lot computes
		addq.w	#1,d0			;BLTSIZE
		and.w	#$3F,d0			;including LT Part 3
		move.w	AnFr_Rows(a1),d1
		move.w	d1,d2
		add.w	d1,d2		;don't forget-3 bitplanes
		add.w	d1,d2		;worth!
		and.w	#$3FF,d2
		asl.w	#6,d2
		add.w	d0,d2
		move.w	d2,Anim_Begin(a0)


* Here, get next Anim, and if hit end of list, move on to next function


BPC_1		move.l	Anim_Next(a0),a0		;get next Anim struct
		move.l	a0,AnimThis(a6)		;set for next call

		cmp.l	AnimFirst(a6),a0		;back to start of list?
		bne	BPC_L1			;back if not

;		sf	ScrSwitch(a6)		;& enable scrswitch

		rts


* BlitPlot(a6)
* a6 = ptr to main program variables

* Plot the blitter objects and change animation frames once plotted.

* d0-d3/a0-a1 corrupt


BlitPlot		move.l	AnimFirst(a6),a0		;ptr to 1st Anim

BPL_L1		move.b	Anim_Flags(a0),d0		;disabled?
		move.b	d0,d1
		and.b	#_ANF_DISABLED,d0
		bne.s	BPL_1			;skip if so

		and.b	#_ANF_NOSHOW,d1		;invisible?
		bne.s	BPL_1			;skip if invisible


* Here, plot the object using the blitter precomps...


BPL_Ena		btst	#6,DMACONR(a5)

BPL_BW1		btst	#6,DMACONR(a5)	;busy wait (sigh)...
		bne.s	BPL_BW1

		movem.l	Anim_BltPtr(a0),d0-d3
		movem.l	d0-d3,BLTCPTH(a5)
		movem.l	Anim_BltCon(a0),d0-d1
		movem.l	d0-d1,BLTCON0(a5)
		movem.l	Anim_BltMod(a0),d0-d1
		movem.l	d0-d1,BLTCMOD(a5)
		move.w	Anim_Begin(a0),BLTSIZE(a5)


* Here, change Anim frame of current Anim once it's plotted, then get
* next Anim in sequence. ONLY CHANGE ANIM FRAME AFTER CURRENT ANIM FRAME
* PLOTTING IS STARTED OFF!!!


BPL_1		move.b	Anim_Flags(a0),d0
		move.b	d0,d1
		and.b	#_ANF_SAMEFRAME,d0	;animated?
		bne.s	BPL_3			;skip if not
		move.l	Anim_CFrame(a0),a1	;else current frameptr
		move.l	AnFr_Next(a1),d2		;this is next frame
		move.l	AnFr_Prev(a1),d3		;this is prev frame
		and.b	#_ANF_REVERSED,d1		;reversed?
		beq.s	BPL_4			;skip if not
		exg	d2,d3			;else swap
BPL_4		move.l	d2,Anim_CFrame(a0)	;swap frame

BPL_3		move.l	Anim_Next(a0),a0		;get next Anim struct

		cmp.l	AnimFirst(a6),a0		;back to start of list?
		bne.s	BPL_L1			;skip if not

		rts


* BlitPChar(a6)
* a6 = ptr to main program variables

* Print a char from the 'font' using the blitter.

* Requires the following variables preset:

* CharPrt.B (ALWAYS)
* CharPln (ALWAYS)
* CharXPos.W (1st call:updated from this point on)
* CharYPos.W (1st call)
* CharDMod.W (Preset by InitVars = BP_WIDE-4)
* CharAMod.W (Preset by InitVars = -2)
* CharTmpBuf.L (Preset by InitVars)

* Note : performs TWO blits. First, shifts font data into a buffer
* prior to moving to the screen, THEN blits the buffer to the screen
* using the required shift.

* d0-d5/a0-a1/a3 corrupt


BlitPChar	btst	#6,DMACONR(a5)		;busy wait (sigh)

BPLC_W1		btst	#6,DMACONR(a5)
		bne.s	BPLC_W1

		move.l	CharConvert(a6),a0	;char convert table
		moveq	#0,d0
		move.b	CharPrt(a6),d0		;char to convert
		sub.b	#" ",d0			;realign
		move.b	0(a0,d0.w),d0		;get converted char

		moveq	#0,d1			;create word offset
		move.b	d0,d1			;to req'd character
		and.w	#$FFFE,d1
		moveq	#8,d2			;shift value
		moveq	#0,d3
		st	d3
		swap	d3			;and BLTAxWM's

		btst	#0,d0			;odd char number?
		bne.s	BPLC_1			;skip if so
		moveq	#0,d2			;else even shift no.
		rol.l	#8,d3			;and different masks

BPLC_1		move.l	CharData(a6),a0		;ptr to Font
		add.w	d1,a0			;ptr to char
		move.l	CharTmpBuf(a6),a1		;ptr to dst
		ror.w	#4,d2			;create BLTCONx
		move.w	d2,d1
		or.w	#$9F0,d1			;BLTCON0
		swap	d1
		move.w	d2,d1			;BLTCON1
		or.w	#2,d1			;DESC mode!
		move.w	#FONT_DESC,d2
		add.w	d2,a0			;for DESC mode!
		add.w	#16,a1			;for DESC mode!

		move.w	CharAMod(a6),d2		;BLTAMOD
		moveq	#-2,d4			;BLTDMOD

		move.w	#FONT_LINES*64+2,d5	;BLTSIZE

		move.l	a0,BLTAPTH(a5)		;now set up the
		move.l	a1,BLTDPTH(a5)		;blitter and
		move.l	d1,BLTCON0(a5)		;start it off!
		move.l	d3,BLTAFWM(a5)
		move.w	d2,BLTAMOD(a5)
		move.w	d4,BLTDMOD(a5)
		move.w	d5,BLTSIZE(a5)


* From here on the character has been copied from the font bitmap
* into a 1-char wide buffer and left-justified. Now copy the 1-char
* buffer and shift right the appropriate no. of places.


BPLC_X		move.w	CharXPos(a6),d0		;create word X offset
		move.w	d0,d2
		asr.w	#4,d0
		add.w	d0,d0
		ext.l	d0			;and this is it
		moveq	#0,d1
		move.w	CharYPos(a6),d1		;now compute
		move.l	YTable(a6),a3		;use y-table lookup-
		add.w	d1,d1			;far faster than a
		move.w	0(a3,d1.w),d1		;multiply
;		mulu	#BP_NEXTLINE,d1		;Y offset
		add.l	d1,d0			;total offset
		and.w	#$F,d2			;frac(x/16)
		ror.w	#4,d2			;for BLTCONx
		moveq	#0,d1
		move.w	d2,d1
		or.w	#$7CA,d1		;USEB/C/D, Minterm $CA
		swap	d1
		move.w	d2,d1		;BLTCONx
		moveq	#0,d2
		st	d2
		ror.l	#8,d2		;BLTAxWM

		move.l	RasterWaiting(a6),a0
		addq.l	#2,a0
		add.l	d0,a0		;BLTDPTH/L
		move.l	CharTmpBuf(a6),a1	;BLTBPTH/L

		moveq	#-2,d3		;BLTBMOD
		move.w	CharDMod(a6),d4	;BLTDMOD

		move.w	#FONT_LINES*64+2,d5	;BLTSIZE

		moveq	#3,d0		;no of bitplanes
		swap	d0
		move.b	CharPln(a6),d0	;which planes??

BPLC_L1		ror.b	#1,d0		;this plane?
		bcc.s	BPLC_2		;skip if not

		btst	#6,DMACONR(a5)		;busy wait (sigh)

BPLC_W2		btst	#6,DMACONR(a5)
		bne.s	BPLC_W2

		movem.l	d0-d5/a0-a1,-(sp)	;save this lot

		move.l	a0,BLTDPTH(a5)	;now set off the second
		move.l	a0,BLTCPTH(a5)	;blit...
		move.l	a1,BLTBPTH(a5)
		move.l	d1,BLTCON0(a5)
		move.l	d2,BLTAFWM(a5)
		move.w	#-1,BLTADAT(a5)
		move.w	d3,BLTBMOD(a5)
		move.w	d4,BLTDMOD(a5)
		move.w	d4,BLTCMOD(a5)
		move.w	d5,BLTSIZE(a5)

		movem.l	(sp)+,d0-d5/a0-a1	;and recover this lot

BPLC_2		add.w	#BP_HMOD,a0	;next screen bitplane
		swap	d0
		subq.w	#1,d0		;done all planes?
		beq.s	BPLC_3		;exit loop if so
		swap	d0
		bra.s	BPLC_L1

BPLC_3		addq.w	#8,CharXPos(a6)		;next char position

		rts


* BlitPString(a0,a6,d0,d1,d2)
* a0 = ptr to ASCIIZ string (ending in NULL byte!)
* a6 = ptr to main program variables
* d0 = starting x coord
* d1 = starting y coord
* d2 = colour

* Print a string at the specified coords

* d0-d5/a0 corrupt


BlitPString	move.b	d2,CharPln(a6)
		move.w	d0,CharXPos(a6)		;set position
		move.w	d1,CharYPos(a6)

BPS_1		move.b	(a0)+,d0			;get char
		beq.s	BPS_2			;EOS hit-exit
		move.b	d0,CharPrt(a6)		;this char
		move.l	a0,-(sp)			;save string ptr
		bsr	BlitPChar		;print char
		move.l	(sp)+,a0			;recover string ptr
		bra.s	BPS_1			;and do some more

BPS_2		rts				;done!


* BlitLogo(a0,a1,d0,d1,d2,d3)

* a0 = ptr to logo to blit
* a1 = ptr to screen to blit to
* d0 = no of lines
* d1 = width in WORDS
* d2 = x position
* d3 = y position

* Do a basic D=A blit of logos onto the screen at the specified positions.

* d2-d7/a1/a3 corrupt


BlitLogo		btst	#6,DMACONR(a5)		;busy wait (sigh)

BLG_W		btst	#6,DMACONR(a5)
		bne.s	BLG_W

		addq.l	#2,a1		;overwide screen correction

		moveq	#0,d4
		move.w	d3,d4
		move.l	YTable(a6),a3	;use y-table lookup-
		add.w	d4,d4		;far faster than a
		move.w	0(a3,d4.w),d4	;multiply
;		mulu	#BP_NEXTLINE,d4	;compute Y offset
		add.l	d4,a1		;add to screen base
		moveq	#0,d4
		move.w	d2,d4
		ext.l	d4
		asr.l	#4,d4		;compute x offset
		add.l	d4,d4
		add.l	d4,a1		;1st screen loc

		and.w	#$F,d2
		ror.w	#4,d2		;make BLTCON0
		or.w	#$09F0,d2	;USEA/D, D=A
		swap	d2
		clr.w	d2		;BLTCON1

		moveq	#-1,d3
		clr.w	d3		;BLTALWM zero:LT Part 2

		move.w	d1,d4
		addq.w	#1,d4		;WORDS + 1:LT Part 3
		add.w	d4,d4		;BYTE offset
		neg.w	d4
		add.w	#BP_WIDE,d4	;BLTDMOD
		moveq	#-2,d5		;BLTAMOD:LT Part 1

		move.w	d0,d6		;create BLTSIZE
		and.w	#$3FF,d6
		lsl.w	#6,d6
		move.w	d1,d7
		addq.w	#1,d7
		and.w	#$3F,d7
		add.w	d7,d6

		movem.l	d2-d3,BLTCON0(a5)	;now set off the
		move.l	a0,BLTAPTH(a5)	;blitter...
		move.l	a1,BLTDPTH(a5)
		move.w	d4,BLTDMOD(a5)
		move.w	d5,BLTAMOD(a5)
		move.w	d6,BLTSIZE(a5)

		rts


* AlineObject SpecialCodes go here.

* VERY IMPORTANT:ALL of these routines MUST PRESERVE A0!

* Also, the COMPLETE operational SpecialCodes will be in two parts:
* an initialiser for the alien, and a controller to be linked in
* once initialisation is completed.

* LanderCode(a0,a6)
* a0 = ptr to AlienObject structure (Anim header!)
* a6 = ptr to main program variables
* Perform Lander operation. For now, just initialise and then
* move the lander.

* d0/a1 corrupt


LanderCode	move.w	#160,Anim_YPos(a0)	;set Y Position
		bsr	Random
		move.l	Seed(a6),d0
		and.w	MaxScrPos(a6),d0
		move.w	d0,Anim_XPos(a0)		;set X Position

		lea	DoLander(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		tst.b	Seed(a6)		;top byte <0?
		bpl.s	LanderSet	;skip if not

		neg.w	AO_XMove(a0)	;else change direction

LanderSet	rts

DoLander		move.w	Anim_XPos(a0),d0	;current x coord
		add.w	AO_XMove(a0),d0	;movement value
		and.w	MaxScrPos(a6),d0	;constrain to screen
		move.w	d0,Anim_XPos(a0)	;replace x coord

		rts


* MutantCode(a0,a6)
* a0 = ptr to AO_ struct for mutant
* a6 = ptr to main program vars

* Initialise Mutant position etc.


MutantCode	bsr	SetPos		;set position

		lea	DoMutant(pc),a1		;mutant controller
		move.l	a1,AO_SpecialCode(a0)	;point to it

		rts


DoMutant		bsr	Random		;new random number

		move.l	Seed(a6),d0	;get random number
		and.w	#$0F,d0
		subq.w	#8,d0		;this is X add-on
		swap	d0
		and.w	#$0F,d0
		subq.w	#8,d0		;this is y add-on

		move.w	Anim_YPos(a0),d1	;get Y position
		add.w	d0,d1		;test addition
		cmp.w	#MIN_SY,d1	;off top of screen?
		bcc.s	Mutant_1		;skip if not
		neg.w	d1		;else bring back on
Mutant_1		cmp.w	#MAX_SY,d1	;off bottom of screen?
		bls.s	Mutant_2		;skip if not
		neg.w	d1		;else bring back on
Mutant_2		add.w	d1,Anim_YPos(a0)	;alter Y Position
		swap	d0		;get x add-on
		move.w	Anim_XPos(a0),d1	;get X position
		add.w	d0,d1		;update it
		and.w	MaxScrPos(a6),d1	;constrain to screen limits
		move.w	d1,Anim_XPos(a0)	;& store back

		rts


BomberCode	bsr	SetPos

		lea	tmpDoBomber(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		rts

tmpDoBomber	nop
		rts


BaiterCode	bsr	SetPos

		lea	DoBaiter(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		rts

DoBaiter		nop
		rts


SwarmerCode	bsr	SetPos		;set swarmer position

		bsr	Random		;new random number
		move.l	Seed(a6),d0	;get it
		moveq	#2,d1		;x movement
		move.w	d1,d2		;y movement
		tst.l	d0		;direction change?
		bpl.s	SwrC_1		;don't change if positive
		neg.w	d1
SwrC_1		move.w	d1,AO_XMove(a0)	
		tst.w	d0		;direction change?
		bpl.s	SwrC_2		;don't change if positive
		neg.w	d2
SwrC_2		move.w	d2,AO_YMove(a0)

		lea	DoSwarmer(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		rts

DoSwarmer	move.w	Anim_XPos(a0),d0	;current x coord
		add.w	AO_XMove(a0),d0	;movement value
		and.w	MaxScrPos(a6),d0	;constrain to screen
		move.w	d0,Anim_XPos(a0)	;replace x coord

		move.w	Anim_YPos(a0),d0	;change y position
		add.w	AO_YMove(a0),d0
		cmp.w	#MIN_SY,d0	;too small?
		bcc.s	DoSwr_1		;skip if not
		move.w	#MAX_SY,d0	;else vertical wrap around

DoSwr_1		cmp.w	#MAX_SY,d0	;too large?
		bls.s	DoSwr_2		;skip if not
		move.w	#MIN_SY,d0	;else vertical wrap around

DoSwr_2		move.w	d0,Anim_YPos(a0)	;else set it

		rts


PodCode		bsr	SetPos
		bsr	Random

		moveq	#1,d0
		move.w	d0,AO_YMove(a0)
		moveq	#4,d0
		move.w	d0,AO_XMove(a0)	;pod movement speed=(+4,+1)

		move.l	Seed(a6),d0
		tst.l	d0		
		bpl.s	PodC_1
		neg.w	AO_XMove(a0)	;negate x & y speeds according
PodC_1		tst.w	d0		;to random seed value
		bpl.s	PodC_2
		neg.w	AO_YMove(a0)
PodC_2		lea	DoPod(pc),a1
		move.l	a1,AO_SpecialCode(a0)	;now change PodCode

		rts

DoPod		nop
		rts


		move.w	AO_XCnt(a0),d0
		addq.w	#1,d0
		and.w	#1,d0
		move.w	d0,AO_XCnt(a0)
		beq.s	DoPod_C

		rts

DoPod_C		move.w	Anim_XPos(a0),d0	;change X position
		add.w	AO_XMove(a0),d0
		and.w	MaxScrPos(a6),d0	;constrain to screen limits
		move.w	d0,Anim_XPos(a0)

		move.w	Anim_YPos(a0),d0	;change y position
		add.w	AO_YMove(a0),d0
		cmp.w	#MIN_SY,d0	;too small?
		bcc.s	DoPod_1		;skip if not
		move.w	#MAX_SY,d0	;else vertical wrap around

DoPod_1		cmp.w	#MAX_SY,d0	;too large?
		bls.s	DoPod_2		;skip if not
		move.w	#MIN_SY,d0	;else vertical wrap around

DoPod_2		move.w	d0,Anim_YPos(a0)	;else set it
		rts


* SetPos(a0)
* a0 = ptr to AO_ structure

* Initialise starting position of object.

* d0 corrupt

SetPos		bsr	Random
		move.l	Seed(a6),d0	;get random value
		and.w	MaxScrPos(a6),d0	;create random X position
		swap	d0
		and.w	#$7F,d0
		add.w	#MIN_SY+2,d0	;create random Y position
		move.w	d0,Anim_YPos(a0)	;save it
		swap	d0
		move.w	d0,Anim_XPos(a0)	;and the X position too
		rts			;byeee!


* MakeSprCTL(d0,d1) -> d2,d3

* d0 = (ULONG) x & y positions in order X|Y (X high word, Y low word)
* d1 = (UWORD) sprite height

* Create sprite control words from the supplied data. CTL0 = sprite
* control word 0, CTL1 = sprite control word 1.

* CTL0	=	E7 E6 E5 E4 E3 E2 E1 E0 H8 H7 H6 H5 H4 H3 H2 H1

* CTL1	=	L7 L6 L5 L4 L3 L2 L1 L0 AT 0  0  0  0  E8 L8 H0

* d1 corrupt


MakeSprCTL	moveq	#0,d2	;1st control word
		moveq	#0,d3	;2nd control word

		move.b	d0,d2	;get E7-E0 bits
		rol.w	#8,d2	;pop in proper place, CTL0
		move.b	d1,d3	;get L7-L0 bits
		rol.w	#8,d3	;pop in proper place, CTL1
		swap	d0	;get H8-H0 bits
		ror.w	#1,d0	;get H8-H1 bits
		move.b	d0,d2	;pop in proper place, CTL0
		rol.w	#1,d0	;get H0 bit back
		and.b	#1,d0	;mask off all other bits
		or.b	d0,d3	;pop into CTL1
		swap	d0
		ror.w	#6,d0	;get E8 bit in correct place
		and.b	#4,d0
		or.b	d0,d3	;pop into CTL1
		ror.w	#7,d1	;get L8 bit in correct place
		and.b	#2,d1
		or.b	d1,d3	;pop into CTL1
		rts		;and done!!


* SetFire(a6)
* a6 = ptr to main vars

* if fire button pressed, then initialise the fire sequence.

* d0-d4/a1 corrupt


SetFire		tst.b	FireLock(a6)	;fire button locked?
		bne	SFire_Done	;exit NOW if so

		tst.b	JoyButton(a6)	;joystick fire button pressed?
		beq	SFire_Done	;exit if not

		move.l	FFireList(a6),a0		;get firelist ptrs

;		tst.w	MoveDir(a6)		;L to R?
;		bmi.s	SFire_3			;skip if L to R
;		exg	a0,a1			;else change ptr

;SFire_3		

		move.l	ShipAnim(a6),a1
		move.l	Anim_XPos(a1),d0
		addq.w	#6,d0		;y=y+6
		swap	d0
		move.w	d0,d1		;copy x
		add.w	#32,d0		;x=x+16
		swap	d0
		move.l	d0,fl_XPos(a0)
		moveq	#_FLST_WIDE1,d4	;max size for later
		moveq	#-1,d2		;masks
		tst.w	MoveDir(a6)	;which direction?
		bpl.s	SFire_1		;skip if R to L


* Here, ship's direction is L to R. Generate appropriate FireList values
* for a left to right ship.


		move.w	d1,d3
		and.w	#$F,d3		;mask shift value
		beq.s	SFire_1a		;unless it's zero...
		lsr.l	d3,d2		;...else shift masks
SFire_1a		move.w	#HORG_P+HDIFF,d3
		sub.w	d1,d3		;coord difference
		lsr.w	#4,d3		;word difference
		bne.s	SFire_1b		;skip if nonzero
		moveq	#1,d3		;else use this
SFire_1b		cmp.w	d4,d3		;too big?
		bls.s	SFire_1c		;skip if not
		move.w	d4,d3		;else use this
SFire_1c		sub.w	d3,d4		;create offset
		move.l	d2,fl_Masks(a0)
		move.w	d3,fl_Size(a0)
		move.w	d4,fl_Offset(a0)
		bra.s	SFire_2


* Here, ship's direction is R to L, so generate the values appropriate
* to this direction.

SFire_1		move.w	d1,d3
		and.w	#$F,d3
		beq.s	SFire_1d
		lsl.l	d3,d2
SFire_1d		moveq	#0,d3
		move.w	d0,fl_Offset(a0)
		move.w	#HORG_P-HDIFF,d3
		sub.w	d3,d1
		lsr.w	#4,d1
		bne.s	SFire_1e
		moveq	#1,d1
SFire_1e		cmp.w	d4,d1
		bls.s	SFire_1f
		move.w	d4,d1
SFire_1f		move.w	d1,fl_Size(a0)
		move.l	d2,fl_Masks(a0)
		moveq	#RFXSTART,d3
		move.w	d3,fl_XPos(a0)

SFire_2		st	FireLock(a6)	;lock fire button till release

SFire_Done	rts			;and done


* DoFireLists(a6)
* a6 = ptr to main program variables

* Display all fire list entries with non-zero coordinates
* and ripple-process the coordinate lists. The idea is to
* display laser fire in stages, with the position of the
* required stage

* Note:there are various 'magic numbers' based upon the size of
* the fire list (see equates at top). Change _FLST_WIDE1 (no of
* words in firelist graphic entry) and all others change as well.

* NOTE : Because of the busy waits below, ONLY call this routine AFTER
* BlitPreComp()! Calling before causes the screen to judder as the plotting
* time leaps beyond 1 video frame cycle!

* First do the 'reverse' fire list, then the 'forward' fire list. The
* exact order gets changed by the Reverse() routine!

* d0-d6/a0-a1 corrupt


DoFireLists	move.l	RFireList(a6),a0

		moveq	#0,d0		;coords
		move.l	d0,d1		;size & offset
		move.l	d0,d2		;masks

DFL_1		move.w	fl_XPos(a0),d3
		or.w	fl_YPos(a0),d3	;coords zero?
		beq.s	DFL_2		;skip this entry if so

		move.w	fl_YPos(a0),d3
		add.w	d3,d3
		move.l	YTable(a6),a1
		move.w	0(a1,d3.w),d3	;get offset

		move.l	RasterWaiting(a6),a1
		add.w	d3,a1
		move.w	fl_XPos(a0),d3
		move.w	d3,d4
		asr.w	#4,d3
		add.w	d3,d3
		add.w	d3,a1		;screen offset = BLTDPTH/L

		and.w	#$0F,d4
		ror.w	#4,d4		;BLTCON0
		or.w	#$0BFA,d4	;USEA/C/D, D = A + ~AC
		swap	d4
		clr.w	d4		;BLTCONx
		move.l	fl_Masks(a0),d5	;BLTAFWM/LWM
		move.l	fl_Data(a0),a2	;BLTAPTH/L

		moveq	#64,d6
		add.w	fl_Size(a0),d6	;this is BLTSIZE


* Note:only one line of data so moduli don't matter!


		btst	#6,DMACONR(a5)	;wait for blitter
DFL_3		btst	#6,DMACONR(a5)	;to finish
		bne.s	DFL_3

		move.l	a1,BLTDPTH(a5)
		move.l	a1,BLTCPTH(a5)
		move.l	a2,BLTAPTH(a5)
		movem.l	d4-d5,BLTCON0(a5)
		move.w	d6,BLTSIZE(a5)	;fire up the blitter!

DFL_2		movem.l	fl_XPos(a0),d3-d5	;get 'old' coords etc
		movem.l	d0-d2,fl_XPos(a0)	;insert 'new' coords
		move.l	d3,d0		;'new' become 'old'
		move.l	d4,d1		;for next ripple entry
		move.l	d5,d2
		move.l	fl_Next(a0),d3	;is there a next entry?
		beq.s	DFL_4		;skip if not
		move.l	d3,a0		;else point to it
		bra	DFL_1		;and repeat

DFL_4		move.l	FFireList(a6),a0

		moveq	#0,d0		;coords
		move.l	d0,d1		;size & offset
		move.l	d0,d2		;masks

DFL_5		move.w	fl_XPos(a0),d3
		or.w	fl_YPos(a0),d3	;coords zero?
		beq.s	DFL_6		;skip this entry if so

		move.w	fl_YPos(a0),d3
		add.w	d3,d3
		move.l	YTable(a6),a1
		move.w	0(a1,d3.w),d3	;get offset

		move.l	RasterWaiting(a6),a1
		add.w	d3,a1
		move.w	fl_XPos(a0),d3
		move.w	d3,d4
		asr.w	#4,d3
		add.w	d3,d3
		add.w	d3,a1		;screen offset = BLTDPTH/L

		and.w	#$0F,d4
		ror.w	#4,d4		;BLTCON0
		or.w	#$0BFA,d4	;USEA/C/D, D = A + ~AC
		swap	d4
		clr.w	d4		;BLTCONx
		move.l	fl_Masks(a0),d5	;BLTAFWM/LWM
		move.l	fl_Data(a0),a2	;BLTAPTH/L

		moveq	#64,d6
		add.w	fl_Size(a0),d6	;this is BLTSIZE


* Note:only one line of data so moduli don't matter!


		btst	#6,DMACONR(a5)	;wait for blitter
DFL_7		btst	#6,DMACONR(a5)	;to finish
		bne.s	DFL_7

		move.l	a1,BLTDPTH(a5)
		move.l	a1,BLTCPTH(a5)
		move.l	a2,BLTAPTH(a5)
		movem.l	d4-d5,BLTCON0(a5)
		move.w	d6,BLTSIZE(a5)	;fire up the blitter!

DFL_6		movem.l	fl_XPos(a0),d3-d5	;get 'old' coords etc
		movem.l	d0-d2,fl_XPos(a0)	;insert 'new' coords
		move.l	d3,d0		;'new' become 'old'
		move.l	d4,d1		;for next ripple entry
		move.l	d5,d2
		move.l	fl_Next(a0),d3	;is there a next entry?
		beq.s	DFL_8		;skip if not
		move.l	d3,a0		;else point to it
		bra	DFL_5		;and repeat

DFL_8		rts			;done!


* DoTitleScreen(a6)
* a6 = ptr to main program variables

* Blit various data to title screen, then display it.
* Repeat for all title screens until a key is pressed.

* Note : uses VBL counter to determine display time. Timings
* computed for a 50Hz PAL Amiga. Change the InitVars() variable
* assignments to the display period variables to alter the
* timings for NTSC machines.

* d2-d7/a0-a2 corrupt


DoTitleScreen	cmp.b	#$FF,OrdKey(a6)	;key held down?
		bne.s	DoTitleScreen	;wait till released

		st	ScrSwitch(a6)		;kill screen switching


* First, prepare page 1 on inactive screen...


		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo1,a0
		moveq	#24*3,d0		;24 lines deep
		moveq	#15,d1		;15 words wide
		moveq	#47,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		move.l	RasterWaiting(a6),a1
		lea	Logo2,a0
		moveq	#29*3,d0		;29 lines deep
		moveq	#12,d1		;12 words wide
		moveq	#65,d2		;x position
		moveq	#40,d3		;y position
		bsr	BlitLogo		;pop on logo

		move.l	RasterWaiting(a6),a1
		lea	Logo3,a0
		move.w	#45*3,d0		;45 lines deep
		moveq	#7,d1		;7 words wide
		moveq	#107,d2		;x position
		moveq	#90,d3		;y position
		bsr	BlitLogo		;pop on logo

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		move.w	#140,d3		;y position
		bsr	BlitLogo		;pop on logo


* ...now switch the screen in. Prepare page 2 on inactive screen...


		sf	ScrSwitch(a6)	;reallow screen switch
		bsr	WaitVBL		;Wait for VBL
		st	ScrSwitch(a6)	;now lock out screen switch

DTS_Rst		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		lea	ScannerImg,a0
		move.l	RasterWaiting(a6),a1
		move.w	#61*3,d0
		moveq	#20,d1
		moveq	#0,d2
		moveq	#0,d3
		bsr	BlitLogo

		lea	A1F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#11*3,d0
		moveq	#1,d1
		moveq	#58,d2
		moveq	#70,d3
		bsr	BlitLogo

		lea	Txt1_1,a0
		moveq	#42,d0
		moveq	#90,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt1_2,a0
		moveq	#38,d0
		moveq	#100,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A2F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#12*3,d0
		moveq	#1,d1
		move.w	#150,d2
		moveq	#70,d3
		bsr	BlitLogo

		lea	Txt2_1,a0
		move.w	#132,d0
		moveq	#90,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt2_2,a0
		move.w	#128,d0
		moveq	#100,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A3F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#7*3,d0
		moveq	#1,d1
		move.w	#240,d2
		moveq	#70,d3
		bsr	BlitLogo

		lea	Txt3_1,a0
		move.w	#222,d0
		moveq	#90,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt3_2,a0
		move.w	#218,d0
		moveq	#100,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A4F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#3*3,d0
		moveq	#1,d1
		moveq	#60,d2
		move.w	#140,d3
		bsr	BlitLogo

		lea	Txt4_1,a0
		moveq	#42,d0
		move.w	#160,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt4_2,a0
		moveq	#38,d0
		move.w	#170,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A5F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#5*3,d0
		moveq	#1,d1
		move.w	#152,d2
		move.w	#140,d3
		bsr	BlitLogo

		lea	Txt5_1,a0
		move.w	#128,d0
		move.w	#160,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt5_2,a0
		move.w	#128,d0
		move.w	#170,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A6F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#11*3,d0
		moveq	#1,d1
		move.w	#240,d2
		move.w	#140,d3
		bsr	BlitLogo

		lea	Txt6_1,a0
		move.w	#234,d0
		move.w	#160,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt6_2,a0
		move.w	#214,d0
		move.w	#170,d1
		moveq	#1,d2
		bsr	BlitPString


* ...now wait for 5 secs or a key press...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_1		cmp.b	#$FF,OrdKey(a6)	;any key hit?
		bne	DTS_Done		;exit if hit

		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bne.s	DTS_1		;back if not


* Now switch in page 2, prepare page 3 on inactive screen...


		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)

		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	HDG_4,a0
		moveq	#112,d0
		moveq	#60,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_1,a0
		moveq	#58,d0
		moveq	#80,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_2,a0
		move.w	#208,d0
		moveq	#80,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_3,a0
		moveq	#50,d0
		moveq	#90,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_3,a0
		move.w	#208,d0
		moveq	#90,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	TDG_Array,a2
		moveq	#110,d0		;1st Y pos
		moveq	#10,d1		;no to do

DTS_L1		move.l	(a2)+,d2		;get 1st number
		movem.l	d0/d1/a2,-(sp)	;save important values
		move.l	d2,d0
		lea	XBuf,a0
		lea	Base10(pc),a1
		bsr	LtoA		;long int to ASCII convert
		bsr	StrLen		;no of chars in d7
		movem.l	(sp),d0/d1/a2	;recover & preserve values
		neg.w	d7
		add.w	#9,d7		;9 chars max
		add.w	d7,d7
		add.w	d7,d7
		add.w	d7,d7
		add.w	#10,d7		;leftmost print pos
		move.w	d0,d1
		move.w	d7,d0
		moveq	#7,d2
		bsr	BlitPString
		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		move.l	a2,a0		;point to string
		addq.l	#4,a2		;point to next entry
		movem.l	d0/d1/a2,-(sp)	;save new values

		move.w	d0,d1		;y coord
		moveq	#90,d0		;x coord
		moveq	#7,d2
		bsr	BlitPString	;print string

		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		add.w	#12,d0		;next y pos

		subq.l	#1,d1		;done them all?
		bne.s	DTS_L1		;back if not

		lea	ATG_Array,a2
		moveq	#110,d0		;1st Y pos
		moveq	#10,d1		;no to do

DTS_L2		move.l	(a2)+,d2		;get 1st number
		movem.l	d0/d1/a2,-(sp)	;save important values
		move.l	d2,d0
		lea	XBuf,a0
		lea	Base10(pc),a1
		bsr	LtoA		;long int to ASCII convert
		bsr	StrLen		;no of chars in d7
		movem.l	(sp),d0/d1/a2	;recover & preserve values
		neg.w	d7
		add.w	#9,d7		;9 chars max
		add.w	d7,d7
		add.w	d7,d7
		add.w	d7,d7
		add.w	#168,d7		;leftmost print pos
		move.w	d0,d1
		move.w	d7,d0
		moveq	#7,d2
		bsr	BlitPString
		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		move.l	a2,a0		;point to string
		addq.l	#4,a2		;point to next entry
		movem.l	d0/d1/a2,-(sp)	;save new values

		move.w	d0,d1		;y coord
		move.w	#246,d0		;x coord
		moveq	#7,d2
		bsr	BlitPString	;print string

		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		add.w	#12,d0		;next y pos

		subq.l	#1,d1		;done them all?
		bne.s	DTS_L2		;back if not


* ...now wait for 5 secs or a key press...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_2		cmp.b	#$FF,OrdKey(a6)	;any key hit?
		bne.s	DTS_Done		;exit if hit

		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bne.s	DTS_2		;back if not


* ...now switch in page 3...


		sf	ScrSwitch(a6)	;allow screen switching
		bsr	WaitVBL		;wait for VBL
		st	ScrSwitch(a6)	;forbid it again

		bra	DTS_Rst


* ...now wait for 5 secs or a key press...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_3		cmp.b	#$FF,OrdKey(a6)	;any key hit?
		bne.s	DTS_Done		;exit if hit

		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bne.s	DTS_3		;back if not


* ...now repeat the whole cycle!!!


		bra	DTS_Rst

DTS_Done		rts


* Scanner(a6)
* a6 = ptr to main program variables

* Display the scanner.

* corrupt


Scanner		lea	ScannerImg,a0
		move.l	RasterWaiting(a6),a1
		move.w	#61*3,d0
		moveq	#20,d1
		moveq	#0,d2
		moveq	#0,d3
		bsr	BlitLogo

		lea	ScannerImg,a0
		move.l	RasterActive(a6),a1
		move.w	#61*3,d0
		moveq	#20,d1
		moveq	#0,d2
		moveq	#0,d3
		bsr	BlitLogo

		rts


* Within MonAm, call this using ptr to blitter routine in A4,
* and any other data in other regs needed. Trouble if A4/A5
* needed!


Go		CALLGRAF	OwnBlitter

		lea	$DFF000,a5
		jsr	(a4)

		CALLGRAF	DisownBlitter

Halt		nop

		bra.s	Go


* WaitVBL()
* Wait for VBL to pass by
* d0 corrupt


WaitVBL		move.l	VBLCounter(a6),d0
WaitVBL_1	cmp.l	VBLCounter(a6),d0
		beq.s	WaitVBL_1
		rts


* BlitWait()
* Wait for blitter done
* d0 corrupt

BlitWait		move.l	BlitCounter(a6),d0
BlitWait_1	cmp.l	BlitCounter(a6),d0
		beq.s	BlitWait_1
		rts


* WaitMBDown()
* Wait for mouse button to be PRESSED.

* NOTHING CORRUPT!


WaitMBDown	btst	#6,CIAAPRA
		bne.s	WaitMBDown
		rts


* WaitMBUp()
* Wait for mouse button to be RELEASED.

* NOTHING CORRUPT!


WaitMBUp		btst	#6,CIAAPRA
		beq.s	WaitMBUp
		rts


* SetPalette(a0,d0)
* a0 = ptr to palette to set
* d0 = no of colours
* d0/a1 corrupt


SetPalette	lea	COLOR00(a5),a1

SetPal_1		move.w	(a0)+,(a1)+
		subq.w	#1,d0
		bne.s	SetPal_1
		rts


* BlitScrClear(a0)
* a0 = ptr to raster bitplanes to clear

* This new version clears the lot, for interleaved bitplanes!
* Put ptr to start of scrn in A0. Assumptions about no. of bit-
* planes set in NPLANES equate above.

* d0 corrupt


BlitScrClear	btst	#6,DMACONR(a5)
BSCWait		btst	#6,DMACONR(a5)		;busy wait (sigh)
		bne.s	BSCWait

		move.l	a0,BLTDPTH(a5)		;ptr to plane to clear
		moveq	#0,d0
		move.w	d0,BLTADAT(a5)		;data to fill with
;		move.w	#-1,BLTADAT(a5)

		move.w	d0,BLTDMOD(a5)

		move.w	d0,BLTCON1(a5)		;no special control
		move.w	#$01F0,BLTCON0(a5)	;USED, D=A
		moveq	#-1,d0
		move.l	d0,BLTAFWM(a5)		;masks
		move.w	#BP_NEWCLR,BLTSIZE(a5)	;start it up

		rts


* BlitWipe(a0,d0,d1)
* a0 = ptr to area to clear
* d0 = 1st raster line to clear from
* d1 = no of raster lines to clear

* Perform a clear-out of the screen area specified by the
* parameters.

* d0-d3/a3 corrupt


BlitWipe		moveq	#0,d2
		move.w	d0,d2
		move.l	YTable(a6),a3		;use y-table lookup-
		add.w	d2,d2			;far faster than a
		move.w	0(a3,d2.w),d2		;multiply
;		mulu	#BP_NEXTLINE,d2	;offset
		add.l	d2,a0		;ptr to start of area
		move.w	d1,d2
		add.w	d2,d2		;3 bitplanes again!!!
		add.w	d1,d2		;no of total lines to clear
		and.w	#$3FF,d2		;within blitter limits

		move.w	#BP_HMOD,d3
		asr.w	#1,d3
		and.w	#$3F,d3		;within blitter limits

		moveq	#0,d0
		move.w	#$01F0,d0	;BLTCON0:USED, D=A
		swap	d0		;BLTCON1
		moveq	#-1,d1		;BLTAxWM

		btst	#6,DMACONR(a5)
BWW_1		btst	#6,DMACONR(a5)		;busy wait (sigh)
		bne.s	BWW_1

		move.l	a0,BLTDPTH(a5)
		move.w	d0,BLTDMOD(a5)
		move.w	d0,BLTADAT(a5)
		movem.l	d0-d1,BLTCON0(a5)
		asl.w	#6,d2
		add.w	d3,d2
		move.w	d2,BLTSIZE(a5)

		rts


* Debug data show routines


* ShowLong(d0,d1,d2)

* See ShowByte() for parms etc except that this time
* d0.L = LONG to show and d1 corrupt also


ShowLong		move.l	d0,-(sp)		;save longword
		swap	d0		;get high word
		bsr.s	ShowWord		;show it
		addq.w	#2,d1		;move 2 chars right
		move.l	(sp)+,d0		;recover longword
		bsr.s	ShowWord		;show low word
		rts


* ShowWord(d0,d1,d2)

* See ShowByte() for parms etc except that this time
* d0.W = WORD to show and d1 corrupt also


ShowWord		move.w	d0,-(sp)		;save word
		lsr.w	#8,d0		;get high byte
		bsr.s	ShowByte		;show it
		addq.w	#2,d1		;move 2 chars right
		move.w	(sp)+,d0		;recover word
		bsr.s	ShowByte		;show low byte
		rts


* ShowByte(d0,d1,d2)

* d0.B = byte value to show
* d1 = x position (char pos from 0 to 39)
* d2 = y position (raster line from 0 to 255)

* d3-d4/a0-a1/a3 corrupt


ShowByte		move.l	RasterActive(a6),a0
		moveq	#NPLANES,d3		;no of bitplanes
		mulu	#BP_HMOD,d3		;bytes per raster line
		move.w	d3,d4
		mulu	d2,d4			;y offset
		add.l	d4,a0			;y address
		add.w	d1,a0			;x+y address

		lea	CharSet,a1		;ptr to charset
		moveq	#0,d4
		move.b	d0,d4			;byte value
		lsr.b	#4,d4			;get high nibble
		add.w	d4,d4			;make index into
		add.w	d4,d4			;charset
		add.w	d4,d4
		add.w	d4,a1			;ptr to char

		move.l	a0,d4			;save scrn ptr

		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line

		move.l	d4,a0			;recover scrn ptr
		addq.l	#1,a0			;next char pos

		lea	CharSet,a1		;ptr to charset
		moveq	#0,d4
		move.b	d0,d4			;byte value
		and.b	#$F,d4			;get low nibble
		add.w	d4,d4			;make index into
		add.w	d4,d4			;charset
		add.w	d4,d4
		add.w	d4,a1			;ptr to char

		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line
		add.w	d3,a0			;next raster line
		move.b	(a1)+,(a0)		;pop in char line

		rts


* Palette : black, white, red, yellow, green, cyan, blue, magenta


Palette:

		dc.w	$0000,$0FFF,$0D00,$0FD0
		dc.w	$00B0,$00CC,$024C,$0D2D


* Library names (actually just one)...


graf_name	dc.b	"graphics.library",0
		even


* Here put data includes. Ensure that graphics data, sound data
* etc., goes into CHIP RAM!


* CHIP RAM data


		section	CUSTOM,DATA_C

		incdir	source:d.edwards/

A1F1_G		incbin	data/landerv2.blit	;10x11

A2F1_G		incbin	data/mutantv2.blit	;10x12

A3F1_G		incbin	data/bomberv2.blit	;7x7

A4F1_G		incbin	data/baiterv2.blit	;12x3

A5F1_G		incbin	data/swarmerv2.blit	;6x5

A6F1_G		incbin	data/podv2.blit	;11x11

A7F1_G		incbin	data/body.blit	;4x9

ASF1_G		incbin	data/shipf1.blit	;14x8

ASF2_G		incbin	data/shipf2.blit	;14x8

ASF3_G		incbin	data/shipf3.blit	;14x8

ASR1_G		incbin	data/shipr1.blit	;14x8

ASR2_G		incbin	data/shipr2.blit	;14x8

ASR3_G		incbin	data/shipr3.blit	;14x8

AFF1_G		incbin	data/flamef1.blit	;5x3

AFF2_G		incbin	data/flamef2.blit	;7x5

AFR1_G		incbin	data/flamer1.blit	;5x3

AFR2_G		incbin	data/flamer2.blit	;7x5


A1F1_M		incbin	data/landerv2.bmsk	;10x11

A2F1_M		incbin	data/mutantv2.bmsk	;10x12

A3F1_M		incbin	data/bomberv2.bmsk	;7x7

A4F1_M		incbin	data/baiterv2.bmsk	;12x3

A5F1_M		incbin	data/swarmerv2.bmsk	;6x5

A6F1_M		incbin	data/podv2.bmsk	;11x11

A7F1_M		incbin	data/body.bmsk	;4x9

ASF_M		incbin	data/shipf.bmsk	;14x8

ASR_M		incbin	data/shipr.bmsk	;14x8

AFF1_M		incbin	data/flamef1.bmsk	;5x3

AFF2_M		incbin	data/flamef2.bmsk	;7x5

AFR1_M		incbin	data/flamer1.bmsk	;5x3

AFR2_M		incbin	data/flamer2.bmsk	;7x5


Logo1		incbin	data/logo1.blit	;225x24

Logo2		incbin	data/logo2.blit	;189x29

Logo3		incbin	data/logo3.blit	;106x45

Logo4		incbin	data/logo4.blit	;240x43

ScannerImg	incbin	data/scanner.blit	;320x61

NewCSet		incbin	data/CHARSET2.blit	;296x8

		dc.w	0	;safety for DESC mode Laurence blit

CBBuf		ds.w	32	;char blit buffer


* Laser fire graphic data in L to R order.


LSF_X1		dc.w	-1,-1,0,0
		dc.w	0,0,0,0
		dc.w	0,0,0,0

LSF_X2		dc.w	-1,-1,-1,-1
		dc.w	0,0,0,0
		dc.w	0,0,0,0

LSF_X3		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,0,0
		dc.w	0,0,0,0

LSF_X4		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,-1,-1
		dc.w	0,0,0,0

LSF_X5		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,0,0

LSF_X6		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,-1,-1

LSF_X7		dc.w	0,0,-1,-1
		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,-1,-1

LSF_X8		dc.w	0,0,0,0
		dc.w	-1,-1,-1,-1
		dc.w	-1,-1,-1,-1

LSF_X9		dc.w	0,0,0,0
		dc.w	0,0,-1,-1
		dc.w	-1,-1,-1,-1

LSF_X10		dc.w	0,0,0,0
		dc.w	0,0,0,0
		dc.w	-1,-1,-1,-1

LSF_X11		dc.w	0,0,0,0
		dc.w	0,0,0,0
		dc.w	0,0,-1,-1


* "Don't Care Where" data


		section	STRUCTS,DATA


Anim1		dc.l	Anim2
		dc.l	Anim2

		dc.l	A1FF1,A1FF1

		dc.w	160,128
		dc.w	_AL_CRAFT	;ship ID = 0
		dc.b	0,0
		
		dc.l	0,0,0,0		;blitprecomps
		dc.w	0,0,0,0
		dc.w	0,0,0
		dc.w	0,0,0,0
		dc.w	0

		dc.w	0		;score
		dc.w	0,0		;movement
		dc.w	0,0		;cnts
		dc.l	0		;SpecialCode
		dc.w	0		;Bomber
		dc.b	0,0		;flags & dummy


Anim2		dc.l	Anim1
		dc.l	Anim1

		dc.l	A2FF1,A2FF1

		dc.w	153,131
		dc.w	_AL_CRAFT	;flame ID = 0
		dc.b	0,0
		
		dc.l	0,0,0,0		;blitprecomps
		dc.w	0,0,0,0
		dc.w	0,0,0
		dc.w	0,0,0,0
		dc.w	0

		dc.w	0		;score etc
		dc.w	0,0
		dc.w	0,0
		dc.l	0
		dc.w	0
		dc.b	0,0


Anim3		ds.b	AO_Sizeof*120


* Ship animation frames:forward set


A1FF1		dc.l	A1FF2,A1FF3

		dc.l	ASF1_G
		dc.l	ASF_M

		dc.w	8,1
		dc.w	0,0

A1FF2		dc.l	A1FF3,A1FF1

		dc.l	ASF2_G
		dc.l	ASF_M

		dc.w	8,1
		dc.w	0,0

A1FF3		dc.l	A1FF1,A1FF2

		dc.l	ASF3_G
		dc.l	ASF_M

		dc.w	8,1
		dc.w	0,0


* Ship animation frames:reverse set


A1RF1		dc.l	A1RF2,A1RF3

		dc.l	ASR1_G
		dc.l	ASR_M

		dc.w	8,1
		dc.w	0,0

A1RF2		dc.l	A1RF3,A1RF1

		dc.l	ASR2_G
		dc.l	ASR_M

		dc.w	8,1
		dc.w	0,0

A1RF3		dc.l	A1RF1,A1RF2

		dc.l	ASR3_G
		dc.l	ASR_M

		dc.w	8,1
		dc.w	0,0


* Flame animation frames:forward set


A2FF1		dc.l	A2FF2,A2FF2

		dc.l	AFF1_G
		dc.l	AFF1_M

		dc.w	3,1
		dc.w	2,1

A2FF2		dc.l	A2FF1,A2FF1

		dc.l	AFF2_G
		dc.l	AFF2_M

		dc.w	5,1
		dc.w	-2,-1


* Flame animation frames:reverse set


A2RF1		dc.l	A2RF2,A2RF2

		dc.l	AFR1_G
		dc.l	AFR1_M

		dc.w	3,1
		dc.w	0,1

A2RF2		dc.l	A2RF1,A2RF1

		dc.l	AFR2_G
		dc.l	AFR2_M

		dc.w	5,1
		dc.w	0,-1


* Various creature animframes



A3F1		dc.l	A3F1,A3F1

		dc.l	A1F1_G		;lander
		dc.l	A1F1_M

		dc.w	11,1
		dc.w	0,0


A4F1		dc.l	A4F1,A4F1

		dc.l	A2F1_G		;mutant
		dc.l	A2F1_M

		dc.w	12,1
		dc.w	0,0


A5F1		dc.l	A5F1,A5F1

		dc.l	A3F1_G		;bomber
		dc.l	A3F1_M

		dc.w	7,1
		dc.w	0,0

A6F1		dc.l	A6F1,A6F1

		dc.l	A4F1_G		;baiter
		dc.l	A4F1_M

		dc.w	3,1
		dc.w	0,0

A7F1		dc.l	A7F1,A7F1

		dc.l	A5F1_G		;swarmer
		dc.l	A5F1_M

		dc.w	5,1
		dc.w	0,0

A8F1		dc.l	A8F1,A8F1

		dc.l	A6F1_G		;pod
		dc.l	A6F1_M

		dc.w	11,1
		dc.w	0,0


A9F1		dc.l	A9F1,A9F1

		dc.l	A7F1_G		;body
		dc.l	A7F1_M

		dc.w	9,1
		dc.w	0,0


* This is the conversion table for ASCII chars to charset chars
* starting at ASCII 32


CTab1		dc.b	36,36,36,36	;32
		dc.b	36,36,36,36	;36
		dc.b	36,36,36,36	;40
		dc.b	36,36,36,36	;44
		dc.b	0,1,2,3		;48
		dc.b	4,5,6,7		;52
		dc.b	8,9,36,36	;56
		dc.b	36,36,36,36	;60
		dc.b	36,10,11,12	;64
		dc.b	13,14,15,16	;68
		dc.b	17,18,19,20	;72
		dc.b	21,22,23,24	;76
		dc.b	25,26,27,28	;80
		dc.b	29,30,31,32	;84
		dc.b	33,34,35,36	;88
		dc.b	36,36,36,36	;92
		dc.b	36,10,11,12	;96
		dc.b	13,14,15,16	;100
		dc.b	17,18,19,20	;104
		dc.b	21,22,23,24	;108
		dc.b	25,26,27,28	;112
		dc.b	29,30,31,32	;116
		dc.b	33,34,35,36	;120
		dc.b	36,36,36,36	;124


* Colour cycles


FlashTab		dc.w	$0C4C,$0C5C,$0C6C,$0C7C
		dc.w	$0C8C,$0C9C,$0CAC,$0CBC

		dc.w	$0CCC,$0CCB,$0CCA,$0CC9
		dc.w	$0CC8,$0CC7,$0CC6,$0CC5

		dc.w	$0CC4,$0CB4,$0CA4,$0C94
		dc.w	$0C84,$0C74,$0C64,$0C54

		dc.w	$0C44,$0B45,$0A46,$0947
		dc.w	$0848,$0749,$064A,$054B

		dc.w	$044C,$045C,$046C,$047C
		dc.w	$048C,$049C,$04AC,$04BC

		dc.w	$04CC,$04CB,$04CA,$04C9
		dc.w	$04C8,$04C7,$04C6,$04C5

		dc.w	$04C4,$05C4,$06C4,$07C4
		dc.w	$08C4,$09C4,$0AC4,$0BC4

		dc.w	$0CC4,$0CB5,$0CA6,$0C97
		dc.w	$0C88,$0C79,$0C6A,$0C5B


* SpecialValues array for InitSet(). Contains:

* Points, XMove, YMove, SpecialCodePtr

* in that order.


SVArray		dc.w	100,2,0
		dc.l	LanderCode
		dc.w	150,2,0
		dc.l	MutantCode
		dc.w	250,2,0
		dc.l	BomberCode
		dc.w	200,2,0
		dc.l	BaiterCode
		dc.w	150,2,0
		dc.l	SwarmerCode
		dc.w	1000,2,0
		dc.l	PodCode


* Bomber Lists. 1st list = list of starting positions and starting
* speeds, plus BCount values.


BList1		dc.w	500,135,2,0,8
		dc.w	500,191,2,2,10
		dc.w	500,105,2,-2,5
		dc.w	500,160,2,0,7
		dc.w	1000,135,-2,-4,3
		dc.w	1000,135,-2,2,10
		dc.w	1000,135,-2,-2,5
		dc.w	1000,135,-2,4,12


BList2		dc.w	-7,-6,-5,-4
		dc.w	-3,-2,-1,0
		dc.w	0,1,2,3
		dc.w	4,5,6,7

		dc.w	7,6,5,4
		dc.w	3,2,1,0
		dc.w	0,-1,-2,-3
		dc.w	-4,-5,-6,-7


* Y-table for y-coordinate to address offset computations.
* Initialised algorithmically.


_YTab		ds.w	256


* Attack Wave array. Numbers are. in the following order:

* landers, mutants, bombers, baiters, swarmers, pods

* NOTE : swarmers are initially disabled. They only become
* active once the pod has been hit.

* Highest attack wave = 15.


AWArray		dc.w	10,0,0,0,0,0
		dc.w	10,0,0,0,0,0
		dc.w	12,0,3,0,10,1
		dc.w	14,0,5,0,30,3
		dc.w	16,0,5,0,30,3
		dc.w	18,0,5,0,30,3
		dc.w	20,0,5,0,30,3
		dc.w	20,0,5,0,30,3

		dc.w	22,0,7,0,50,5
		dc.w	24,0,7,0,50,5
		dc.w	26,0,7,0,50,5
		dc.w	26,0,7,0,50,5
		dc.w	28,0,7,0,50,5
		dc.w	28,0,7,0,50,5
		dc.w	30,0,7,0,50,5
		dc.w	30,0,7,0,50,5


* FireLists.

* This lot is the laser fire lists.
* First list is for firing left to right.


LSF_Spr1		dc.l	LSF_Spr2		;ptr to next
		dc.w	0,0		;x & y coords
		dc.w	0,0		;size, offset
		dc.w	0,0		;masks
		dc.l	LSF_X1		;ptr to graphic data

LSF_Spr2		dc.l	LSF_Spr3
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X2

LSF_Spr3		dc.l	LSF_Spr4
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X3

LSF_Spr4		dc.l	LSF_Spr5
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X4

LSF_Spr5		dc.l	LSF_Spr6
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X5

LSF_Spr6		dc.l	LSF_Spr7
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X6

LSF_Spr7		dc.l	LSF_Spr8
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X7

LSF_Spr8		dc.l	LSF_Spr9
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X8

LSF_Spr9		dc.l	LSF_Spr10
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X9

LSF_Spr10	dc.l	LSF_Spr11
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X10

LSF_Spr11	dc.l	0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X11


* This is the reverse fire list.


LSR_Spr1		dc.l	LSR_Spr2		;ptr to next
		dc.w	0,0		;x & y coords
		dc.w	0,0		;size, offset
		dc.w	0,0		;masks
		dc.l	LSF_X11

LSR_Spr2		dc.l	LSR_Spr3
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X10

LSR_Spr3		dc.l	LSR_Spr4
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X9

LSR_Spr4		dc.l	LSR_Spr5
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X8

LSR_Spr5		dc.l	LSR_Spr6
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X7

LSR_Spr6		dc.l	LSR_Spr7
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X6

LSR_Spr7		dc.l	LSR_Spr8
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X5

LSR_Spr8		dc.l	LSR_Spr9
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X4

LSR_Spr9		dc.l	LSR_Spr10
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X3

LSR_Spr10	dc.l	LSR_Spr11
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X2

LSR_Spr11	dc.l	0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.l	LSF_X1



* Today's Greatest High Scores


TDG_Array	dc.l	2500
		dc.b	"DWE",0
		dc.l	2250
		dc.b	"M M",0
		dc.l	2000
		dc.b	"MJC",0
		dc.l	1750
		dc.b	"S M",0
		dc.l	1500
		dc.b	"ABC",0
		dc.l	1000
		dc.b	"XYZ",0
		dc.l	750
		dc.b	"PIG",0
		dc.l	600
		dc.b	"NUT",0
		dc.l	500
		dc.b	"ACE",0
		dc.l	400
		dc.b	"BIN",0


* All Time Greatest High Scores


ATG_Array	dc.l	2500
		dc.b	"DWE",0
		dc.l	2250
		dc.b	"M M",0
		dc.l	2000
		dc.b	"MJC",0
		dc.l	1750
		dc.b	"S M",0
		dc.l	1500
		dc.b	"ABC",0
		dc.l	1000
		dc.b	"XYZ",0
		dc.l	750
		dc.b	"PIG",0
		dc.l	600
		dc.b	"NUT",0
		dc.l	500
		dc.b	"ACE",0
		dc.l	400
		dc.b	"BIN",0


Txt1_1		dc.b	"lander",0
Txt1_2		dc.b	"100 pts",0

Txt2_1		dc.b	"Mutant",0
Txt2_2		dc.b	"150 pts",0

Txt3_1		dc.b	"bomber",0
Txt3_2		dc.b	"250 pts",0

Txt4_1		dc.b	"baiter",0
Txt4_2		dc.b	"200 pts",0

Txt5_1		dc.b	"swarmer",0
Txt5_2		dc.b	"150 pts",0

Txt6_1		dc.b	"pod",0
Txt6_2		dc.b	"1000 pts",0

HDG_1		dc.b	"todays",0
HDG_2		dc.b	"all time",0
HDG_3		dc.b	"greatest",0
HDG_4		dc.b	"hall of fame",0

XBuf		ds.b	32

CharSet		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000110
		dc.b	%01001010
		dc.b	%01010010
		dc.b	%01100010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00001000
		dc.b	%00011000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00000100
		dc.b	%00001000
		dc.b	%00010000
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00001100
		dc.b	%00001100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00001000
		dc.b	%00011000
		dc.b	%00101000
		dc.b	%01111100
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01111100
		dc.b	%00000010
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000000
		dc.b	%01111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%00000010
		dc.b	%00000100
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00111110
		dc.b	%00000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01111110
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111000
		dc.b	%01000100
		dc.b	%01111100
		dc.b	%01000100
		dc.b	%01000010
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01110000
		dc.b	%01110000
		dc.b	%01000000
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01110000
		dc.b	%01110000
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%00000000




