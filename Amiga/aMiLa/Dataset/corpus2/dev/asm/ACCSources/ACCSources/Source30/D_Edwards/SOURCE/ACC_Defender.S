

		opt	d+


* DEFENDER.S : My own version of the arcade classic!


* Features :


* 1) Overwide screen to negate the need for clipping;

* 2) Interleaved bitmap for massively improved speed
*    of blitter object rendering (thanks, Mark Meany!
*    I previously credited Mike Cross with this, so
*    if you're reading this, Mark, I stand corrected!).

* 3) Clever modulo arithmetic to allow objects to live
*    on a super-wide 'virtual screen' (approx 18 real 
*    screens wide!);

* 4) Use of y-table to obviate the need for MULU etc. for
*    computing y-coord to address offset mappings;

* 5) Uses hardware sprites for the scanner. Why let the
*    blitter do all the work?



		include Source:D_Edwards/Includes/MyHardware.i

;		Source:D_Edwards/Includes/MyExec2.i
;		Source:D_Edwards/Includes/MyGraf2.i


* Save some time:this is all of Exec I'm using!!


OpenLibrary	equ	-552
CloseLibrary	equ	-414
AllocMem		equ	-198
FreeMem		equ	-210
Forbid		equ	-132
Permit		equ	-138

MEMF_CHIP	equ	$0002
MEMF_FAST	equ	$0004
MEMF_PUBLIC	equ	$0001
MEMF_CLEAR	equ	$10000

MEMF_VARS	equ	MEMF_PUBLIC+MEMF_CLEAR	;my own def


* This is all of the graphics library I'm using...


OwnBlitter	equ	-456
DisownBlitter	equ	-462


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
DMA_SET2		equ	DMA_SET1+SPREN

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

HHIT		equ	100	;range span for laser strikes

_SLHS		equ	HORG_P-HDIFF	;ship LHS limit
_LLHS		equ	0	;HORG_P-HHIT	;laser LHS limit
_SRHS		equ	HORG_P+HDIFF	;ship RHS limit
_LRHS		equ	320	;HORG_P+HHIT+16	;laser RHS limit

RFXSTART		equ	80	;reverse fire list x start


* Sprite values


MYHSTART		equ	190
MYVSTART		equ	120

SPRHGT		equ	28

SPRDSPACE	equ	SPRHGT*4		;no of bytes, display area

SPRSIZW		equ	SPRHGT*2+4	;size of 1 sprite (words)

SPRSIZB		equ	SPRSIZW*2	;size of 1 sprite (bytes)

NUMSPR		equ	6		;no of sprites being used


* FireList graphics line equates


_FLST_WIDE1	equ	12		;WORDS wide
_FLST_WIDE2	equ	_FLST_WIDE1*2	;BYTES wide


* Animation Flags


_ANF_DISABLED	equ	$80	;don't display this anim AT ALL

_ANF_NOSHOW	equ	$04	;set if Anim is invisible (off screen)
_ANF_REVERSED	equ	$02	;reverse anim direction
_ANF_SAMEFRAME	equ	$01	;don't change frames

_NANF_DISABLED	equ	$FF-$80

_NANF_NOSHOW	equ	$FF-$04
_NANF_REVERSED	equ	$FF-$02
_NANF_SAMEFRAME	equ	$FF-$01


* AlienObject flags


_AOF_DYING	equ	$01	;object in process of dying
_AOF_HIT		equ	$02	;object hit by laser
_AOF_CAUGHT	equ	$04	;body caught by lander
_AOF_HUNTING	equ	$04	;lander looking for body
_AOF_ERUPT	equ	$04	;swarmer erupting from pod
_AOF_SNATCHING	equ	$08	;lander kidnapping body
_AOF_HUNTED	equ	$08	;body being hunted
_AOF_LOSTIT	equ	$10	;Lander just lost Bosy
_AOF_SNATCHED	equ	$10	;body has been snatched
_AOF_TRACKED	equ	$10	;missile tracking Baiter
_AOF_RESCUED	equ	$20	;body has been rescued
_AOF_LOCKED	equ	$20	;missile locked onto Baiter

_NAOF_DYING	equ	$FF-$01
_NAOF_HIT	equ	$FF-$02
_NAOF_CAUGHT	equ	$FF-$04
_NAOF_HUNTING	equ	$FF-$04
_NAOF_ERUPT	equ	$FF-$04
_NAOF_SNATCHING	equ	$FF-$08
_NAOF_HUNTED	equ	$FF-$08
_NAOF_LOSTIT	equ	$FF-$10
_NAOF_SNATCHED	equ	$FF-$10
_NAOF_TRACKED	equ	$FF-$10
_NAOF_RESCUED	equ	$FF-$20
_NAOF_LOCKED	equ	$FF-$20


* Player Flags


_PDF_DEAD	equ	1	;ship has just been hit
_PDF_ALLDEAD	equ	2	;all lives lost


* Mine/Missile Type Specifiers & Other Equates


_MDF_FREE	equ	0
_MDF_MINE	equ	1
_MDF_MISSILE	equ	2
_MDF_END		equ	3

_MA_SIZE		equ	20


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


* Some non-shift key values (hardware keys)


_CSR_LEFT	equ	$4F
_CSR_RIGHT	equ	$4E
_CSR_UP		equ	$4C
_CSR_DOWN	equ	$4D

_ENTER		equ	$44
_SLASH		equ	$3A
_HASH		equ	$2A

_ESC		equ	$45

_HALT		equ	1


* Special key assignments


_REVKEY		equ	_SK_LSHIFT
_THRUSTKEY	equ	_SK_LALT
_FIREKEY		equ	_SK_LAMIGA
_UPKEY		equ	_HASH
_DOWNKEY		equ	_SLASH
_BOMBKEY		equ	_SK_CTRL
_HYPERKEY	equ	$01

_EXPLKEY		equ	$59		;F10

_KLANDER		equ	$50		;F1
_KMUTANT		equ	$51		;F2
_KBOMBER		equ	$53		;F3
_KBAITER		equ	$54		;F4
_KSWARMER	equ	$55		;F5
_KPOD		equ	$56		;F6

_NUMASNKEYS	equ	6

_DTHLSTSZ	equ	320		;size of DeathList


* Bomber list equates


_CURVECOUNT	equ	$200


* Lander kidnap threshold


_KDLIMIT		equ	$7FF	;was $3FFF


* Object types


_AL_CRAFT	equ	0
_AL_FLAME	equ	1
_AL_BODY		equ	2
_AL_LANDER	equ	3
_AL_MUTANT	equ	4
_AL_BOMBER	equ	5
_AL_BAITER	equ	6
_AL_SWARMER	equ	7
_AL_POD		equ	8


* These equates are for advanced features not available when
* playing Classic Defender, but available if user selects from
* options screen the chance to play Defender Plus...


_AL_POWERUP	equ	64	;one of 4 possibles
_AL_MISSILE	equ	65	;anti-Baiter missile


* Powerup types for Defender Plus...


_PU_TURBO	equ	1	;turbo thrust for 10 secs
_PU_SHLD		equ	2	;shield for 5 secs
_PU_MISSILE	equ	4	;anti-Baiter missile on
_PU_MYSTERY	equ	8	;random one of above 3


* Cheat Flags (hah!)


;		Source:D_Edwards/Includes/DefenderCheat1.i


* Miscellaneous equates


CCYC_SHIFT	equ	2
CCYC_MAX		equ	$003F

SCRL_MAXX	equ	$1FFF		;max x screen pos
SCRL_MAXV	equ	$0F		;max x screen scroll speed
BAITERSPD	equ	SCRL_MAXV+6	;max Baiter speed

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

RNG_SY		equ	MAX_SY-MIN_SY

HRNG_SY		equ	RNG_SY/2

ORG_SY		equ	MIN_SY+HRNG_SY


* Variable block. Referenced off A6. A6 MUST be preserved at
* all times other than during library calls!

* Main variable block definitions. ##VARS


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

GenericPtr	rs.l	1	;general-purpose pointer variable...

Generic1		rs.l	1	;more use-for-anything pointers...
Generic2		rs.l	1
Generic3		rs.l	1
Generic4		rs.l	1

DispSCount	rs.l	1	;VBL count at start of title screen

SineVal1		rs.l	1	;pointers to sine tables
SineVal2		rs.l	1

AnimFirst	rs.l	1	;ptr to 1st Anim in list
AnimThis		rs.l	1	;ptr to current Anim
AlienAnims	rs.l	1	;ptr to beasties to kill etc

P1AOList		rs.l	1	;ptr to Player 1 AO_ struct list
P2AOList		rs.l	1	;ptr to Player 2 AO_ struct list
P1AAOList	rs.l	1	;ptr to Player 1 aliens
P2AAOList	rs.l	1	;ptr to Player 2 aliens

ShipImage	rs.l	1	;ptr to ship graphic #1
ShipMask		rs.l	1	;ptr to ship graphic mask #1

SwarmerList	rs.l	1	;ptr to start of swarmer list
SwarmerPtr	rs.l	1	;ptr to current swarmer

BaiterPtr	rs.l	1	;ptr to struct for use by Baiter

BodyList		rs.l	1	;ptr to start of Body list
BodyPtr		rs.l	1	;ptr to current body

PuPtr		rs.l	1	;which struct to use for PowerUp

MsPtr		rs.l	1	;which struct to use for Missile

PuAnFr		rs.l	4	;ptrs to PowerUp AnimFrames

MsAnFrs		rs.l	2	;ptrs to Missile AnimFrames

AlienAnFr	rs.l	6	;ptrs to alien AnimFrames

PuRoutines	rs.l	4	;ptrs to SpecialCodes for Powerups

CollisionList	rs.l	1	;what it says
CurrColl		rs.l	1	;ptr to last free entry

BodyAnFr		rs.l	1	;ptr to body AnimFrames

AWStartup	rs.l	1	;ptr to attack wave startup array
SVStartup	rs.l	1	;ptr to alien startvalues array
SSIStartup	rs.l	1	;ptr to swarmer startup array
BAIStartup	rs.l	1	;ptr to baiter startup array

AnimTailLink	rs.l	1
AnimHeadLink	rs.l	1

ShipAnim		rs.l	1
FlameAnim	rs.l	1

SBGraf		rs.l	1	;Smart Bomb graphic data ptr
SBMask		rs.l	1	;Smart Bomb graphic mask ptr
SBZero		rs.l	1	;Smart Bomb blank

SRevAnFrs	rs.l	2	;reverse AnFr ptrs for ship
FRevAnFrs	rs.l	2	;reverse AnFr ptrs for flame

Player1Data	rs.l	1	;ptr to Player 1 data block
Player2Data	rs.l	1	;ptr to Player 2 data block
CurrentPlayer	rs.l	1	;ptr to current player data block

TDHScore		rs.l	1	;ptr to today's high score list
ATHScore		rs.l	1	;ptr to all time high score list

LList		rs.l	1	;new Laser list ptr

LHSLines		rs.w	16	;plot lines for Laser List
RHSLines		rs.w	16

LListEntry	rs.l	1	;ptr to next free entry

LandScape	rs.l	1	;landscape list ptr
LandOff		rs.l	1	;landscape offset ptr

P1LandL		rs.l	1	;landscape data ptrs, player 1
P1LandO		rs.l	1

P2LandL		rs.l	1	;landscape data ptrs, player 2
P2LandO		rs.l	1

DeathList	rs.l	1	;ptr to ship DeathList

StarField	rs.l	1	;ptr to StarField list

BInitList	rs.l	1	;list for initialising Bombers
BomberList	rs.l	1	;list for processing the Bombers

MineArray	rs.l	1	;ptr to Mine/Missile Array
MineFree		rs.l	1	;ptr to MineFree Array
MineImages	rs.l	2	;ptr to Mine/Missile Images
MineBuffer	rs.l	1	;ptr to Mine plot buffer

ScanArea		rs.l	1	;sprite area ptr for scanner
NullArea		rs.l	1	;sprite ptr for null sprite

ScanPosList	rs.l	1	;for computing scanner pos'n
ScanHList	rs.l	1
ScanVList	rs.l	1

NumStrBuf	rs.l	1	;ptr to buffer for LtoA() etc
KBBufPtr		rs.l	1	;ptr to keyboard buffer
HorizTabs1	rs.l	1	;ptr to Player 1 horiz tabs
HorizTabs2	rs.l	1	;ptr to Player 2 horiz tabs
HorizTabs3	rs.l	1	;ptr to Player 1 ship tabs
HorizTabs4	rs.l	1	;ptr to Player 2 ship tabs
PWList		rs.l	1	;ptr to list of cheat passwords!

UpKeyPtr		rs.l	1	;ptr to 'Up' key variable used
DownKeyPtr	rs.l	1	;ptr to 'Down' key variable used
ThrKeyPtr	rs.l	1	;ptr to 'Thrust' key variable used
FireKeyPtr	rs.l	1	;ptr to 'Fire' key variable used
RevKeyPtr	rs.l	1	;ptr to 'Reverse' key variable used
SBKeyPtr		rs.l	1	;ptr to 'Smart Bomb' key variable used
HyperKeyPtr	rs.l	1	;ptr to 'HyperSpace' key variable used

LandPtrs		rs.l	4	;blitter regs for landscape
LandMods		rs.l	2
LandCon		rs.l	2

LandGraphic	rs.l	3	;graphic ptrs

PUInd1		rs.l	1	;ptrs to PowerUp indicators
PUIRev1		rs.l	1	;and reverse images
PUInd2		rs.l	1
PUIRev2		rs.l	1
PUInd3		rs.l	1
PUIRev3		rs.l	1

CharConvert	rs.l	1	;ptr to char conversion table
CharData		rs.l	1	;ptr to 'font'
CharTmpBuf	rs.l	1	;ptr to tmp blitter buffer
MyKeyMap		rs.l	1	;ptr to my UK keymap

CharSrc		rs.l	1	;blitter precomp ptr to src
CharDst		rs.l	1	;blitter precomp ptr to dst

CharBltCon	rs.w	2	;blitter precomps again
CharBltMsk	rs.w	2

CharAMod		rs.w	1
CharDMod		rs.w	1

CollCount	rs.w	1	;no of entries in CollisionList

DeathCount	rs.w	1	;no of entries in DeathList
DeathTime	rs.w	1	;no of frames for death sequence

TurboCount	rs.w	1	;time for Turbo Thrust
ShieldCount	rs.w	1	;time for Shield on
SMCount		rs.w	1	;no. of missiles on-line

PlayerIndex	rs.w	1	;1 or 2 player game index
PlayerMask	rs.w	1	;1 or 2 player game mask

LandVolume	rs.w	3	;landscape BLTSIZE values

LandSize		rs.w	1	;landscape BLTSIZE value in use

LSCountDown	rs.w	1	;landscape disappearance countdown

MutantStart	rs.w	2	;2 possible Mutant start x posn's

OldIRQ		rs.w	1	;old INTENA value (Exec resurrect)
OldDMA		rs.w	1	;old DMACON value (ditto)

IntExit		rs.w	1	;exit INTREQ value for Int3

CurrXPos		rs.w	1	;current screen X coordinate
CurrXSpeed	rs.w	1	;current screen movement speed
MaxScrPos	rs.w	1	;largest x coordinate allowable
MaxScrSpeed	rs.w	1	;fastest scroll speed
VertSpeed	rs.w	1	;ship up/down speed

PodBasePos	rs.w	1	;initial base position for pods

KDThresh		rs.w	1	;kidnap threshold for Landers

SBCount		rs.w	1	;smart bomb countdown

RevCoords	rs.w	4	;Reverse coords for ship & flame

RevSeq1		rs.w	1	;coord add-on
RevEnd1		rs.w	1	;end coord to aim for
RevSeq2		rs.w	1
RevEnd2		rs.w	1

BomberCount	rs.w	1	;Used by BomberCode()

BLConst1		rs.w	1	;A for MakeBomberList()
BLConst2		rs.w	1	;B for MakeBomberList()
BLConst3		rs.w	1	;C for MakeBomberList()

MineIndex	rs.w	1	;index into mine array

LandXPos		rs.w	1	;X coord for landscape
LandYHgt		rs.w	1	;Y coord for landscape

MoveDir		rs.w	1	;movement direction +/-1
OldMoveDir	rs.w	1

CharXPos		rs.w	1
CharYPos		rs.w	1

ColourCycle	rs.w	1	;cycle counter

DispUnit		rs.w	1	;No of VBL counts in 1 sec

PUCnt1		rs.w	1	;counters for PowerUp indicators
PUCnt2		rs.w	1	;via VBL
PUCnt3		rs.w	1

PUOff1		rs.w	1	;screen offsets for PowerUp
PUOff2		rs.w	1	;indicators
PUOff3		rs.w	1

PUMod1		rs.w	1	;screen moduli for PowerUp
PUMod2		rs.w	1	;indicators
PUMod3		rs.w	1

KillID		rs.w	1	;debug only

KBBufPos		rs.w	1	;keyboard buffer position

AKHoriz		rs.w	1
AKVert		rs.w	1

OrdKey		rs.b	1	;normal key data from int2 handler
ShiftKey		rs.b	1	;shift key data from int2 handler
CharPrt		rs.b	1	;char to print
CharPln		rs.b	1	;char bitplanes

OldBCRA		rs.b	1	;save old CIA-B control registers
OldBCRB		rs.b	1

UpKeyVal		rs.b	1	;'Up' key value
DownKeyVal	rs.b	1	;'Down' key value
ThrKeyVal	rs.b	1	;'Thrust' key value
FireKeyVal	rs.b	1	;'Fire' key value
RevKeyVal	rs.b	1	;'Reverse' key value
SBKeyVal		rs.b	1	;'Smart Bomb' value
HyperKeyVal	rs.b	1	;'Hyperspace' key value 

UpKeyMsk		rs.b	1	;'Up' key mask
DownKeyMsk	rs.b	1	;'Down' key mask
ThrKeyMsk	rs.b	1	;'Thrust' key mask
FireKeyMsk	rs.b	1	;'Fire' key mask
RevKeyMsk	rs.b	1	;'Reverse' key mask
SBKeyMsk		rs.b	1	;'Smart Bomb' key mask
HyperKeyMsk	rs.b	1	;'Hyperspace' key mask

JoyPos		rs.b	1	;joystick position
JoyButton	rs.b	1	;joystick fire button state
ScrSwitch	rs.b	1	;screen switch flag (-1=OFF)
Reversing	rs.b	1	;-1=reverse in progress

InertiaKludge	rs.b	1	;values 0,1,2,3
FireLock		rs.b	1	;=-1 if fire 'key' locked
SBLock		rs.b	1	;=-1 if SB 'key' locked
Brakes		rs.b	1	;=-1 if ship dies (stop dead)

PwrUpEn		rs.b	1	;bits set if power-ups enabled
PwrUpOn		rs.b	1	;bits set if this power-up on

NoLand		rs.b	1	;=-1 if 'end of world'
CheatFlags	rs.b	1	;allows me to cheat...!!

GamePlus		rs.b	1	;=-1 if playing Defender Plus
BAlert		rs.b	1	;=-1 if Baiter active

TmpGamePlus	rs.b	1	;tmp copies of above for
TmpPwrUpEn	rs.b	1	;user selection

PuDropped	rs.b	1	;=-1 if PowerUp dropped
TSSwitch		rs.b	1	;=-1 if forced title screen switch

PUVis1		rs.b	1	;these are -1 if the given
PUVis2		rs.b	1	;PowerUp indicator is visible
PUVis3		rs.b	1

Filler		rs.b	1

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
* SHIP AND FLAME STATIC STRUCTURES IF CHANGES TO THIS STRUCTURE
* DEFINITION ARE MADE!


		rsreset
AO_Anim		rs.b	Anim_Sizeof
AO_Points	rs.w	1		;points scored when hit
AO_XMove		rs.w	1
AO_YMove		rs.w	1
AO_XCnt		rs.w	1		;general-purpose
AO_YCnt		rs.w	1		;coord store
AO_SpecialCode	rs.l	1		;code to run for this
AO_KidnapPtr	rs.l	1		;kidnap ptr for Landers
AO_WhatBody	rs.l	1		;tmp kidnap ptr
AO_BCount	rs.w	1		;for Bombers only
AO_XOff		rs.w	1		;collision detection
AO_YOff		rs.w	1		;offsets
AO_XDisp		rs.w	1		;collision detection
AO_YDisp		rs.w	1		;separations
AO_YLDisp	rs.w	1		;laser separation
AO_Generic	rs.w	1		;generic word
AO_ScanLoc	rs.l	1		;scanner word ptr
AO_ScanBit1	rs.w	1		;scanner bit 1
AO_ScanBit2	rs.w	1		;scanner bit 2
AO_ScanMsk1	rs.w	1		;scanner mask 1
AO_ScanMsk2	rs.w	1		;scanner mask 2
AO_Flags		rs.b	1		;special flags
AO_Dummy		rs.b	1

AO_Sizeof	rs.w	0


* PlayerData structure


		rsreset
pd_WaveNumber	rs.l	1	;attack wave number
pd_Score		rs.l	1	;current score
pd_NewLives	rs.l	1	;exceed this for 1 extra life
pd_NLIncr	rs.l	1	;extra life every xxxx points
pd_NewBombs	rs.l	1	;exceed this for 1 extra s.b.
pd_SBIncr	rs.l	1	;extra s.b. every xxxx points
pd_Lives		rs.w	1	;lives
pd_SBombs	rs.w	1	;smart bombs

pd_Bodies	rs.w	1	;bodies left to save
pd_Landers	rs.w	1	;no of landers left
pd_Mutants	rs.w	1	;no of mutants left
pd_Bombers	rs.w	1	;no of bombers left
pd_Baiters	rs.w	1	;no of baiters left
pd_Swarmers	rs.w	1	;no of swarmers left
pd_Pods		rs.w	1	;no of pods left

pd_DoneAW	rs.w	1	;=0 when attack wave done

pd_LandScape1	rs.l	1	;ptrs to this player's landscape
pd_LandScape2	rs.l	1	;lists

pd_AOList	rs.l	1	;ptr to this player's AO_ structs
pd_BodyList	rs.l	1	;ptr to this player's Bodies
pd_SwarmerList	rs.l	1	;ptr to this player's Swarmers
pd_SwarmerPtr	rs.l	1	;ptr to current Swarmer
pd_PuPtr		rs.l	1	;ptr to PowerUp
pd_MsPtr		rs.l	1	;ptr to Smart Missile

pd_BaiterPtr	rs.l	1	;ptr to Baiter to activate
pd_BaiterClock	rs.l	1	;Baiter time bomb value
pd_BaiterAlarm	rs.l	1	;Baiter alarm setoff value

pd_Name		rs.l	1	;ptr to player's name
pd_Initials	rs.l	1	;player's initials

pd_Turbo		rs.w	1
pd_Shield	rs.w	1
pd_SMCount	rs.w	1

pd_UpKeyPtr	rs.l	1	;Player's own key settings
pd_DownKeyPtr	rs.l	1	;for various keys
pd_ThrKeyPtr	rs.l	1
pd_FireKeyPtr	rs.l	1
pd_RevKeyPtr	rs.l	1
pd_SBKeyPtr	rs.l	1

pd_UpKeyVal	rs.b	1	;More player key setting
pd_DownKeyVal	rs.b	1	;data!
pd_ThrKeyVal	rs.b	1
pd_FireKeyVal	rs.b	1
pd_RevKeyVal	rs.b	1
pd_SBKeyVal	rs.b	1

pd_UpKeyMsk	rs.b	1	;More player key setting
pd_DownKeyMsk	rs.b	1	;data!
pd_ThrKeyMsk	rs.b	1
pd_FireKeyMsk	rs.b	1
pd_RevKeyMsk	rs.b	1
pd_SBKeyMsk	rs.b	1

pd_Flags		rs.b	1	;flags
pd_NoLand	rs.b	1	;whether land on or not

pd_PwrUp		rs.b	1	;this player's powerups
pd_BAlert	rs.b	1	;set if Baiter on line

pd_PUVis1	rs.b	1	;copies of the current
pd_PUVis2	rs.b	1	;Power-Up visibility
pd_PUVis3	rs.b	1	;indicators

pd_Filler	rs.b	1

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


* Mine/Missile Data Structure


		rsreset
md_XPos		rs.w	1
md_YPos		rs.w	1
md_XMove		rs.w	1
md_YMove		rs.w	1
md_Count		rs.w	1
md_Type		rs.b	1
md_Index		rs.b	1
md_Sizeof	rs.w	1


* Some macros


CALLEXEC		macro	\1

		move.l	a6,-(sp)
		move.l	4.w,a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		endm


CALLGRAF		macro	\1

		move.l	a6,-(sp)
		move.l	GrafBase(a6),a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		endm


* Main program starts here


		section	MAIN,CODE


main		move.l	#vars_sizeof,d0	;reserve space for my
		move.l	#MEMF_VARS,d1	;variable block
		CALLEXEC	AllocMem
		tst.l	d0		;got it?
		beq	cock_up_1	;oops-exit NOW!

		move.l	d0,a6		;keep this at ALL times!

		bsr	InitVars		;set up variable block

		bsr	InitYTable	;set up Y-Table

		bsr	InitLaserList
		bsr	InitStarField

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


* Now get PlayerData structures and initialise the constant
* parts of them.


		move.l	#pd_Sizeof,d0
		move.l	#MEMF_VARS,d1
		CALLEXEC	AllocMem
		move.l	d0,Player1Data(a6)	;got it?
		beq	cock_up_6		;oops...

		move.l	d0,a0
		clr.l	pd_WaveNumber(a0)
		lea	_PINST4,a1
		move.l	a1,pd_Name(a0)
		move.l	#$41414100,d0		;"AAA" + EOS
		move.l	d0,pd_Initials(a0)
		move.l	P1AOList(a6),pd_AOList(a0)

		move.l	#pd_Sizeof,d0
		move.l	#MEMF_VARS,d1
		CALLEXEC	AllocMem
		move.l	d0,Player2Data(a6)	;got it?
		beq	cock_up_7		;oops...

		move.l	d0,a0
		clr.l	pd_WaveNumber(a0)
		lea	_PINST5,a1
		move.l	a1,pd_Name(a0)
		move.l	#$41414100,d0		;"AAA" + EOS
		move.l	d0,pd_Initials(a0)
		move.l	P2AOList(a6),pd_AOList(a0)


* Now set initial keyboard/joystick preferences for players
* and set up the MineLists


		bsr	InitPlayerKeys
		bsr	InitMines


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


* Here, use Vandal of Killers' three line disc stopper!


		or.b	#$F8,CIABPRB	;motor OFF
		and.b	#$87,CIABPRB	;select DF0 to DF3
		or.b	#$F8,CIABPRB	;reset state


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
		moveq	#32,d0
;		moveq	#16,d0
;		moveq	#8,d0
		bsr	SetPalette


* Now clear the visible screen


;		move.l	RasterActive(a6),a0
;		bsr	BlitScrClear


* Now initialise the alien Anim data structs for both players


		move.l	P1AAOList(a6),a0
		move.l	a0,AlienAnims(a6)
		move.l	Player1Data(a6),a0
		move.l	pd_AOList(a0),a0
		move.l	a0,ShipAnim(a6)
		move.l	a0,AnimFirst(a6)
		move.l	a0,AnimThis(a6)
		move.l	Anim_Next(a0),a0
		move.l	a0,FlameAnim(a6)
		bsr	InitStructs

		move.l	P2AAOList(a6),a0
		move.l	a0,AlienAnims(a6)
		move.l	Player2Data(a6),a0
		move.l	pd_AOList(a0),a0
		move.l	a0,ShipAnim(a6)
		move.l	a0,AnimFirst(a6)
		move.l	a0,AnimThis(a6)
		move.l	Anim_Next(a0),a0
		move.l	a0,FlameAnim(a6)
		bsr	InitStructs


* Now set off my ints!


main_SK1		nop


* Now hit my main program. First show intro titles.


GameLoop		bsr	DoTitleScreen


* Now create the landscapes for each player, which will be different
* for the different players. Also initialise the player data structures
* once the landscapes are in place (NOT BEFORE!). 


		move.l	Player2Data(a6),a0	;player 2
		clr.l	pd_WaveNumber(a0)
		clr.l	pd_Score(a0)
		clr.b	pd_Flags(a0)
		movem.l	P2LandL(a6),d0-d1		;set up landscape
		movem.l	d0-d1,pd_LandScape1(a0)	;pointers
		movem.l	d0-d1,LandScape(a6)
		bsr	CreateLSList

		move.l	P2AAOList(a6),a0	;ensure no spurious aliens
		move.l	P2AOList(a6),a1	;appear!
		bsr	DisableAliens

		move.l	Player2Data(a6),CurrentPlayer(a6)
		bsr	InitSet
		move.l	CurrentPlayer(a6),a0
		move.l	BaiterPtr(a6),pd_BaiterPtr(a0)

		move.l	Player1Data(a6),a0	;player 1
		clr.l	pd_WaveNumber(a0)
		clr.l	pd_Score(a0)
		clr.b	pd_Flags(a0)
		movem.l	P1LandL(a6),d0-d1		;set up landscape
		movem.l	d0-d1,pd_LandScape1(a0)	;ptrs
		movem.l	d0-d1,LandScape(a6)
		bsr	CreateLSList

		move.l	P1AAOList(a6),a0	;ensure no spurious aliens
		move.l	P1AOList(a6),a1	;appear!
		bsr	DisableAliens

		move.l	Player1Data(a6),CurrentPlayer(a6)
		bsr	InitSet
		move.l	CurrentPlayer(a6),a0
		move.l	BaiterPtr(a6),pd_BaiterPtr(a0)

;		move.l	CurrentPlayer(a6),a0
;		moveq	#15,d0
;		move.l	d0,pd_WaveNumber(a0)
;		bsr	InitSet


* Now configure the keyboard for the current player, and select
* which player's landscape is to be displayed. Also, now that each
* player has his own set of aliens to kill off, set the pointers
* to the relevant AO_ structs in the appropriate main variables.


GameLoop2	move.w	PlayerIndex(a6),d0	;current player no.
		add.w	d0,d0			;longword index
		add.w	d0,d0
		lea	Player1Data(a6),a0
		move.l	0(a0,d0.w),a0		;get player data
		move.l	a0,CurrentPlayer(a6)	;save global ptr


* Having selected which player is active, now set up the global game
* data pointers and other global variables from the Player's own local
* copies.


;		move.l	CurrentPlayer(a6),a0	;configure keyboard
		bsr	GetPlayerKeys		;for this player
		move.l	CurrentPlayer(a6),a0
		movem.l	pd_LandScape1(a0),d0-d1	;configure landscape
		movem.l	d0-d1,LandScape(a6)	;for this player
		move.l	pd_AOList(a0),a1
		move.l	a1,AnimFirst(a6)		;configure animation
		move.l	a1,AnimThis(a6)		;ptrs for this
		move.l	a1,ShipAnim(a6)		;player
		move.l	Anim_Next(a1),a1
		move.l	a1,FlameAnim(a6)
		move.l	Anim_Next(a1),a1
		move.l	a1,AlienAnims(a6)
		move.l	pd_BodyList(a0),d0
		move.l	d0,BodyList(a6)
		move.l	d0,BodyPtr(a6)
		move.l	pd_SwarmerList(a0),d0
		move.l	d0,SwarmerList(a6)
		move.l	pd_SwarmerPtr(a0),d0
		move.l	d0,SwarmerPtr(a6)


* Now configure Baiter pointers and whether or not to allow land for
* this player. Also set up the Defender Plus special variables even if
* they're not needed (after all, it doesn't take much time and is safe
* for when Defender Plus IS being played!).


		move.l	pd_BaiterPtr(a0),BaiterPtr(a6)
		move.b	pd_NoLand(a0),NoLand(a6)

		move.b	pd_PwrUp(a0),PwrUpOn(a6)
		move.b	pd_BAlert(a0),BAlert(a6)
		move.w	pd_Turbo(a0),TurboCount(a6)
		move.w	pd_Shield(a0),ShieldCount(a6)
		move.w	pd_SMCount(a0),SMCount(a6)

		move.l	pd_PuPtr(a0),PuPtr(a6)
		move.l	pd_MsPtr(a0),MsPtr(a6)

		move.b	pd_PUVis1(a0),PUVis1(a6)
		move.b	pd_PUVis2(a0),PUVis2(a6)
		move.b	pd_PUVis3(a0),PUVis3(a6)

		moveq	#10,d0
		move.w	d0,PUCnt1(a6)	;initial PowerUp counters
		move.w	d0,PUCnt2(a6)
		move.w	d0,PUCnt3(a6)



* Allow the player to move etc...


		clr.b	Brakes(a6)	;re-enable movement
		clr.w	CurrXSpeed(a6)	;start at rest

		move.l	ShipAnim(a6),a0
		move.l	FlameAnim(a6),a1

		clr.b	Anim_Flags(a0)	;re-enable the ship &
		clr.b	Anim_Flags(a1)	;flame Anims
		clr.b	AO_Flags(a0)
		clr.b	AO_Flags(a1)


* Inform player to get ready


		bsr	GetReadyScreen

		bsr	MakeDeathList		;create DeathList

		bsr	NewStarField		;create a Starfield


* Start clearing screens


		bsr	WaitVBL

		move.l	RasterActive(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear


* Set up the Scanner


		bsr	Scanner

		bsr	InitScanner

		sf	ScrSwitch(a6)
		bsr	WaitVBL		;wait for scrn swap
		st	ScrSwitch(a6)
		bsr	SetSprites	;change sprites
		sf	ScrSwitch(a6)
		bsr	WaitVBL		;wait for scrn swap
		bsr	SetSprites	;do it again

		clr.l	VBLCounter(a6)


* Ensure that mines, missiles, laser shots and ship explosions are
* all quiescent.


		bsr	StopMines	;stop all mine/missile activity
		bsr	ClearLaserList	;stop all laser activity
		clr.w	DeathTime(a6)	;stop all explosion activity


* Now begin playing...


GameLoop3	cmp.b	#_ESC,OrdKey(a6)		;main program
		beq	main_KD			;loop till ESC

		st	ScrSwitch(a6)	;lock out screen switch

;		move.w	#$070,COLOR00(a5)	;debug only:VBL Flicker

;		moveq	#-1,d0		;this is to allow me to
;		bsr	SetTimer		;time the code precisely
;		bsr	TimerOn		;using CIA-B timers

		move.l	RasterWaiting(a6),a0	;clear INACTIVE
		move.w	#61,d0			;playing area
		move.w	#193,d1
		bsr	BlitWipe


* While the blitter is clearing the screen, we can't use it to do
* other things. While busy waiting, use the time to do something
* constructive before busy waiting proper...


		move.l	CollisionList(a6),a0	;renew collision
		move.l	a0,CurrColl(a6)		;list ptrs
		clr.l	(a0)			;& set 1st free slot
		clr.w	CollCount(a6)		;no. of table entries

		move.w	CurrXPos(a6),d0	;change scrn pos
		move.w	CurrXSpeed(a6),d1	;this speed
		muls	MoveDir(a6),d1	;this direction
		add.w	d1,d0
		and.w	MaxScrPos(a6),d0	;limit to range
		move.w	d0,CurrXPos(a6)

		move.l	ShipAnim(a6),a0	;handle ship and flame
		move.l	FlameAnim(a6),a1	;reverse motion
		move.w	Anim_XPos(a0),d0	;sequence
		move.w	Anim_XPos(a1),d1
		add.w	RevSeq1(a6),d0
		add.w	RevSeq1(a6),d1
		cmp.w	RevEnd1(a6),d0	;done reversing?
		beq.s	main_KW1		;skip if so
		tst.b	Brakes(a6)	;ship stopped (dead)?
		bne.s	main_KW1		;skip if so
		move.w	d0,Anim_XPos(a0)	;else update pos'n
		move.w	d1,Anim_XPos(a1)


* PreAnims if they exist


main_KW1		nop

;		bsr	Random

		bsr	ShipUpDown
		bsr	Reverse
		bsr	ScrMove


* PreAnim lines if they exist


* Blitter precomputations


;		moveq	#-1,d0		;this is to allow me to
;		bsr	SetTimer		;time the code precisely
;		bsr	TimerOn		;using CIA-B timers

		bsr	BlitPreComp

;		bsr	TimerOff
;		bsr	CompTime
;		move.l	d0,DebugL(a6)


* Handle laser firing


		bsr	NewFire


* Plot Landscape if enabled (i.e., still have some Bodies left...)


		bsr	PlotLandScape


* Plot graphics


		bsr	BlitPlot


* Plot Laser Shots. This laser code uses the 68000 to plot the image
* and MUST appear after the first blitter plot to prevent it clashing
* with the earlier call to BlitWipe()!


		bsr	MakeLaserList
		bsr	PlotLaserList


* Plot StarField


		bsr	ShowStarField


* Handle Smart Bombs (MUST be after BlitPlot because it
* needs CollCount conditioned!)


		bsr	DetonateSB
		bsr	SmartBomb


* PostAnim lines if they exist


		bsr	PlotDeath

		bsr	DoMines


* PostAnims


		bsr	NewCollision	;collision handler


* Show scores etc


		bsr	ShowScores
		bsr	ShowLives


* Check if it's time to bring on a Baiter


		bsr	BaiterOn


* Check if it's time to destroy the planet...


		bsr	BlastWorld


		bsr	DoPowerUp
		bsr	SetMaxThrust
		bsr	SetShield


* Here go debug calls to ShowLongR() etc if needed during
* program development


;		move.l	DebugL(a6),d0
;		moveq	#10,d1
;		moveq	#60,d2
;		bsr	ShowLongR

;		move.l	DebugL+4(a6),d0
;		moveq	#10,d1
;		moveq	#70,d2
;		bsr	ShowLongR

;		move.l	DebugL+8(a6),d0
;		moveq	#10,d1
;		moveq	#80,d2
;		bsr	ShowLongR

		sf	ScrSwitch(a6)	;enable screen switch

;		bsr	TimerOff
;		bsr	CompTime

;		bsr	WaitMBDown	;debug only:step frame
;		bsr	WaitMBUp		;by frame

;		move.w	#$000,COLOR00(a5)	;debug only:VBL Flicker

Main_DB1		bsr	WaitVBL		;wait for VBL


* Here check for death or end of attack wave, and handle accordingly.


		move.l	CurrentPlayer(a6),a0
		move.b	pd_Flags(a0),d0		;ship dead?
		and.b	#_PDF_DEAD,d0
		bne.s	GameStop2		;skip if so
		tst.w	pd_DoneAW(a0)		;completed?
		beq	GameStop1		;skip if so
		
		bra	GameLoop3	;and back for more


* Come here if the ship is hit by an alien etc.


GameStop2	bsr	ClearScanner	;don't want sprites on...

		clr.b	PUVis1(a6)	;ensure that any Powerup
		clr.b	PUVis2(a6)	;bars aren't visible
		clr.b	PUVis3(a6)
		clr.b	PwrUpOn(a6)

		moveq	#0,d0		;do this in case screen
		move.w	d0,COLOR00(a5)	;flashed for power-up

		bsr	StopMines	;stop all mine/missile activity
		bsr	ClearLaserList	;stop all laser activity
		clr.w	DeathTime(a6)	;stop all explosion activity

		move.l	CurrentPlayer(a6),a0

		move.w	pd_Lives(a0),d0	;any lives left?
;		bne.s	GameStop2b	;continue if so
		bne	GameStop2b	;continue if so


* Come here if ALL of this player's lives are lost!


		moveq	#_PDF_ALLDEAD,d0	;signal that this player
		move.b	d0,pd_Flags(a0)	;is now totally dead

		move.l	pd_AOList(a0),a0	;get this player's Anims
		move.l	Anim_Next(a0),a1

		move.l	Anim_Frames(a0),d0	;this ensures that
		move.l	d0,Anim_CFrame(a0)	;Anim frames are in
		move.l	Anim_Frames(a1),d0	;the right
		move.l	d0,Anim_CFrame(a1)	;sequence

		clr.b	Brakes(a6)	;re-allow thrust

		tst.w	MoveDir(a6)	;reversed?
		bmi.s	GameStop2e	;skip if not

		bsr	_Rev		;reset direction

GameStop2e	move.w	#160,Anim_XPos(a0)	;reset centre position
		move.w	#128,Anim_YPos(a0)	;of ship & flame
		move.w	#153,Anim_XPos(a1)
		move.w	#131,Anim_YPos(a1)

		bsr	GameOverScreen	;tell player it's over

		move.w	PlayerIndex(a6),d0	;change player
		addq.w	#1,d0			;if 2 player
		and.w	PlayerMask(a6),d0		;game
		cmp.w	PlayerIndex(a6),d0	;actually 1 player?
		beq	EndGame			;reset game if so


* Come here if it's a 2-player game. Check if the other player is
* still available to play (i.e., check if the other player has lost
* all available lives also).


		move.w	d0,d1			;copy PlayerIndex
		lea	Player1Data(a6),a0	;ptr to player's data
		add.w	d1,d1			;index on longword
		add.w	d1,d1
		move.l	0(a0,d1.w),a0		;get PlayerData ptr

		move.b	pd_Flags(a0),d1		;check if totally dead
		and.b	#_PDF_ALLDEAD,d1		;is new player dead?
		bne	EndGame			;skip if so


* Come here if other player is still alive. Set up the index variable,
* but DON'T change the actual CurrentPlayer pointer yet - leave that
* for the restarted loop.


		move.w	d0,PlayerIndex(a6)	;change players

;		move.l	CurrentPlayer(a6),a0	;get THIS player
;		bra.s	GameStop2d		;and reset THIS player

		bra	GameLoop2		;& restart new player


* Come here if this player loses life, but has more left.


GameStop2b	subq.w	#1,d0		;lose a life
		move.w	d0,pd_Lives(a0)

		move.l	CurrentPlayer(a6),a0	;reset THIS player's
		clr.b	pd_Flags(a0)		;dead flag

GameStop2d	move.l	pd_AOList(a0),a0	;get this player's Anims
		move.l	Anim_Next(a0),a1

		clr.b	Anim_Flags(a0)	;re-enable the ship &
		clr.b	Anim_Flags(a1)	;flame Anims for this
		clr.b	AO_Flags(a0)	;player
		clr.b	AO_Flags(a1)

		move.l	Anim_Frames(a0),d0	;this ensures that
		move.l	d0,Anim_CFrame(a0)	;Anim frames are in
		move.l	Anim_Frames(a1),d0	;the right
		move.l	d0,Anim_CFrame(a1)	;sequence

		clr.b	Brakes(a6)	;re-allow thrust

		tst.w	MoveDir(a6)	;reversed?
		bmi.s	GameStop2a	;skip if not

		bsr	_Rev		;reset direction

GameStop2a	move.w	#160,Anim_XPos(a0)	;reset centre position
		move.w	#128,Anim_YPos(a0)	;of ship & flame
		move.w	#153,Anim_XPos(a1)
		move.w	#131,Anim_YPos(a1)

		bsr	Random		;change ship position
		move.l	Seed(a6),d0	;randomly for restart
		and.w	MaxScrPos(a6),d0
		move.w	d0,CurrXPos(a6)

		move.w	PlayerIndex(a6),d0	;player index
		addq.w	#1,d0			;next player
		and.w	PlayerMask(a6),d0		;this controls 1/2 pl.
		move.w	d0,d1
		add.w	d1,d1			;convert to longword
		add.w	d1,d1			;index
		lea	Player1Data(a6),a0
		move.l	0(a0,d1.w),a0		;get ptr to Player

		move.b	pd_Flags(a0),d1		;check new player
		and.b	#_PDF_ALLDEAD,d1		;is this one dead?
		bne	GameLoop2		;restart old one if so

;		tst.w	pd_Lives(a0)		;new player dead?
;		beq	GameLoop2		;restart old if so

GameStop2f	move.w	d0,PlayerIndex(a6)	;save new player index

;		move.l	d0,CurrentPlayer(a6)	;choose next player

;		bsr	InitStructs

;		bsr	RemakeSet

;		bra.s	main_KD

		bra	GameLoop2		;and go play!


* Come here if the attack wave has been completed.


GameStop1	bsr	ClearScanner

		moveq	#0,d0		;do this in case screen
		move.w	d0,COLOR00(a5)	;flashed for power-up

		clr.b	PUVis1(a6)	;ensure that any Powerup
		clr.b	PUVis2(a6)	;bars aren't visible
		clr.b	PUVis3(a6)
		clr.b	PwrUpOn(a6)

		bsr	StopMines	;stop all mine/missile activity
		bsr	ClearLaserList	;stop all laser activity
		clr.w	DeathTime(a6)	;stop all explosion activity

		bsr	DoneWaveScreen	;signal wave completed

		move.l	ShipAnim(a6),a0	;these don't need changing
		move.l	FlameAnim(a6),a1	;yet!

		clr.b	Brakes(a6)	;re-allow thrust

		tst.w	MoveDir(a6)	;reversed?
		bmi.s	GameStop1a	;skip if not

		bsr	_Rev		;reset direction

GameStop1a	move.l	Anim_Frames(a0),d0	;correct Anim
		move.l	d0,Anim_CFrame(a0)	;frame pointers
		move.l	Anim_Frames(a1),d0
		move.l	d0,Anim_CFrame(a1)

		move.w	#160,Anim_XPos(a0)	;reset centre position
		move.w	#128,Anim_YPos(a0)	;of ship & flame
		move.w	#153,Anim_XPos(a1)
		move.w	#131,Anim_YPos(a1)

		move.l	CurrentPlayer(a6),a0
		movem.l	pd_LandScape1(a0),d0-d1	;new landscape for
		movem.l	d0-d1,LandScape(a6)	;this player
		bsr	CreateLSList

		bsr	InitSet		;update player
		move.l	CurrentPlayer(a6),a0
		move.l	BaiterPtr(a6),pd_BaiterPtr(a0)

		bra	GameLoop2	;back for next attack wave


* Come here if all players are dead. First check for high scores...


EndGame		bsr	HighScore


* Now go back for a new game.


		bra	GameLoop


* Come here if exiting game altogether via ESC/LMB.


main_KD		nop

		bsr	WaitVBL

;		bsr	WaitMBDown


* Now recover the machine's sanity for a return to Exec.


		move.b	OldBCRA(a6),d0	;reset old CIA-B
		move.b	OldBCRB(a6),d1	;control state
		move.b	d0,CIABCRA
		move.b	d0,CIABCRB

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

		move.w	d0,DeathTime(a6)
		move.w	d0,MineIndex(a6)

		move.b	d0,JoyPos(a6)
		move.b	d0,JoyButton(a6)
		move.b	d0,ShiftKey(a6)
		move.b	d0,Brakes(a6)

		move.l	#$01020304,d0	;magic number for the
		move.l	d0,Magic1(a6)	;PRNG...
		move.l	#$FE291D4B,d0
		move.l	d0,Seed(a6)	;...and initial seed

		move.w	#SCRL_MAXX,d0
		move.w	d0,MaxScrPos(a6)	;set upper screen pos limit
		moveq	#SCRL_MAXV,d0
		move.w	d0,MaxScrSpeed(a6)	;& upper speed limit

		move.w	#BP_NEXTLINE-4,d0		;font dst modulo
		move.w	d0,CharDMod(a6)
		moveq	#FONT_BPL-4,d0		;font src modulo
		move.w	d0,CharAMod(a6)

		moveq	#DU_PAL,d0
		move.w	d0,DispUnit(a6)

		lea	Anim1_1,a0
		move.l	a0,P1AOList(a6)
		lea	Anim2_1,a0
		move.l	a0,P2AOList(a6)

;		lea	Anim1_1,a0	;pointer to list of
;		move.l	a0,AnimFirst(a6)	;Anim structs (actually
;		move.l	a0,AnimThis(a6)	;AO_ structs)
;		move.l	a0,ShipAnim(a6)	;Ship ptr

		move.l	Anim_Frames(a0),a1
		move.l	AnFr_Graphic(a1),a2
		move.l	a2,ShipImage(a6)
		move.l	AnFr_Mask(a1),a2
		move.l	a2,ShipMask(a6)

		move.l	Anim_Next(a0),a0
		move.l	a0,FlameAnim(a6)	;Flame ptr

		lea	Anim1_3,a0
		move.l	a0,P1AAOList(a6)
		lea	Anim2_3,a0
		move.l	a0,P2AAOList(a6)

;		lea	Anim1_3,a0
;		move.l	a0,AlienAnims(a6)	;1st 'Alien' ptr

		lea	CTab1,a0
		move.l	a0,CharConvert(a6)	;this lot is
		lea	NewCSet,a0
		move.l	a0,CharData(a6)		;for BlitPChar()
		lea	CBBuf,a0
		move.l	a0,CharTmpBuf(a6)		;etc
		lea	CTab2,a0
		move.l	a0,MyKeyMap(a6)

		lea	AWArray,a0		;attack wave startup
		move.l	a0,AWStartup(a6)		;array ptr

		lea	SVArray,a0	;start value array for the
		move.l	a0,SVStartup(a6)	;various aliens (ptr again)

		lea	SSIArray,a0	;split swarmer initialiser
		move.l	a0,SSIStartup(a6)	;array

		lea	_BIASet,a0	;Baiter 'alarm clock'
		move.l	a0,BAIStartup(a6)	;initialiser array

		lea	FlashTab,a0	;COLOR07 list for the
		move.l	a0,ColourList(a6)	;VBL colour changer

		lea	AlienAnFr(a6),a0
		lea	A3F1,a1		;set up alien AnFr pointers
		move.l	a1,(a0)+		;lander
		lea	A4F1,a1
		move.l	a1,(a0)+		;mutant
		lea	A5F1,a1
		move.l	a1,(a0)+		;bomber
		lea	A6F1,a1
		move.l	a1,(a0)+		;baiter
		lea	A7F1,a1
		move.l	a1,(a0)+		;swarmer
		lea	A8F1,a1
		move.l	a1,(a0)+		;pod

		lea	A9F1,a0
		move.l	a0,BodyAnFr(a6)	;AnFr ptr for bodies

		lea	A1FF1,a0			;set up reverse
		lea	A1RF1,a1			;AnFr ptrs for
		movem.l	a0-a1,SRevAnFrs(a6)	;ship

		lea	A2FF1,a0
		lea	A2RF1,a1
		movem.l	a0-a1,FRevAnFrs(a6)	;and flame

		lea	ASB1_G,a0	;Smart bomb graphic
		move.l	a0,SBGraf(a6)
		lea	ASB1_M,a0	;Smart bomb mask
		move.l	a0,SBMask(a6)
		lea	ASB1_Z,a0	;Smart bomb blank
		move.l	a0,SBZero(a6)

		moveq	#-REVREPOS,d0		;reverse re-position
		moveq	#REVREPOS,d1		;values for
		swap	d1			;flame Anim
		move.w	d0,d1
		moveq	#0,d0
		movem.l	d0-d1,RevCoords(a6)

		moveq	#-4,d0		;reverse sequence 1
		move.w	#_SLHS,d1	;movement & end coords
		move.w	d0,RevSeq1(a6)
		move.w	d1,RevEnd1(a6)

		moveq	#4,d0		;reverse sequence 2
		move.w	#_SRHS,d1	;movement & end coords
		move.w	d0,RevSeq2(a6)
		move.w	d1,RevEnd2(a6)

		moveq	#-1,d0
		move.w	d0,MoveDir(a6)	;initial direction = L to R
		move.w	d0,KillID(a6)
		move.b	d0,OrdKey(a6)

		move.w	#_KDLIMIT,d0
		move.w	d0,KDThresh(a6)

		lea	TDG_Array,a0	;set up pointers to the
		move.l	a0,TDHScore(a6)	;high score tables
		lea	ATG_Array,a0
		move.l	a0,ATHScore(a6)

		lea	BList1,a0	;this lot is for the
		lea	BList2,a1	;Bombers and their random
		move.l	a0,BInitList(a6)	;flight path
		move.l	a1,BomberList(a6)

		lea	_YTab,a0		;Y-table to save using
		move.l	a0,YTable(a6)	;MULU in blitter code

		lea	__Sine1,a0	;fractional sine table
		lea	__Sine2,a1	;integer sine table
		move.l	a0,SineVal1(a6)
		move.l	a1,SineVal2(a6)

		lea	__LACB,a0
		move.l	a0,NumStrBuf(a6)
		lea	__KBBUF,a0
		move.l	a0,KBBufPtr(a6)

		lea	__TS1,a0
		lea	__TS2,a1
		move.l	a0,HorizTabs1(a6)
		move.l	a1,HorizTabs2(a6)

		lea	__CList,a0
		move.l	a0,CollisionList(a6)	;what it says

		lea	__P1Init,a0
		lea	__P2Init,a1
		move.l	a0,HorizTabs3(a6)
		move.l	a1,HorizTabs4(a6)

		lea	__MYCPW,a0
		move.l	a0,PWList(a6)

		lea	_ScanData,a0	;scanner sprites
		move.l	a0,ScanArea(a6)

		lea	_NulSpr,a0
		move.l	a0,NullArea(a6)

		lea	SpritePtrs(a6),a1	;set up sprite
		move.l	a0,(a1)+		;data pointers
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+
		move.l	a0,(a1)+

		lea	__SPTH,a0
		move.l	a0,ScanHList(a6)
		lea	__SPTV,a0
		move.l	a0,ScanVList(a6)
		lea	__SLst,a0
		move.l	a0,ScanPosList(a6)	;sprite ptrs go here

		lea	__LandL1,a0	;Landscape list ptrs
		move.l	a0,P1LandL(a6)	;for player 1
		lea	__LandL2,a0
		move.l	a0,P1LandO(a6)

		lea	__LandL3,a0	;Landscape list ptrs
		move.l	a0,P2LandL(a6)	;for player 2
		lea	__LandL4,a0
		move.l	a0,P2LandO(a6)

		lea	LAND1,a0
		move.l	a0,LandGraphic(a6)	;graphic ptrs
		lea	LAND2,a0
		move.l	a0,LandGraphic+4(a6)	;for landscape
		lea	LAND3,a0
		move.l	a0,LandGraphic+8(a6)

		moveq	#3,d0
		asl.w	#6,d0
		addq.w	#2,d0
		move.w	d0,LandVolume(a6)		;BLTSIZE values
		moveq	#3*16,d0
		asl.w	#6,d0
		addq.w	#2,d0
		move.w	d0,LandVolume+2(a6)	;for landscape
		move.w	d0,LandVolume+4(a6)

		lea	__DthLst,a0		;death list for
		move.l	a0,DeathList(a6)		;ship explosion

		move.w	#_DTHLSTSZ,d0		;no of entries
		move.w	d0,DeathCount(a6)		;in DeathList

		lea	_MArr1,a0
		lea	_MArr2,a1
		move.l	a0,MineArray(a6)
		move.l	a1,MineFree(a6)

		lea	_MineImg1,a0
		lea	_MineImg2,a1
		movem.l	a0-a1,MineImages(a6)

		lea	_MineBuf,a0
		move.l	a0,MineBuffer(a6)

		lea	XLL,a0
		move.l	a0,LList(a6)	;ptr to LaserList

		lea	LHSLines(a6),a0
		moveq	#-1,d0
		moveq	#16,d1
INIV_1		move.w	d0,(a0)+
		lsr.w	#1,d0
		subq.w	#1,d1
		bne.s	INIV_1

		lea	RHSLines(a6),a0
		move.w	#$8000,d0
		moveq	#16,d1
INIV_2		move.w	d0,(a0)+
		asr.w	#1,d0
		subq.w	#1,d1
		bne.s	INIV_2

		lea	XST,a0
		move.l	a0,StarField(a6)

		lea	PuAnFr(a6),a0	;initialise AnimFrame
		lea	PUF1,a1		;ptrs for Defender Plus
		move.l	a1,(a0)+		;PowerUps
		lea	PUF2,a1
		move.l	a1,(a0)+
		lea	PUF3,a1
		move.l	a1,(a0)+
		lea	PUF4,a1
		move.l	a1,(a0)+

		lea	MsAnFrs(a6),a0	;AnimFrame ptrs for
		lea	MISF,a1		;Defender Plus missiles
		move.l	a1,(a0)+
		lea	MISR,a1
		move.l	a1,(a0)+

		lea	PuRoutines(a6),a0	;ptrs to SpecialCodes
		lea	DoTurbo,a1	;for Powerups
		move.l	a1,(a0)+
		lea	DoShield,a1
		move.l	a1,(a0)+
		lea	DoMissile,a1
		move.l	a1,(a0)+
		lea	DoMystery,a1
		move.l	a1,(a0)+

		clr.b	GamePlus(a6)	;start with Classic Defender
		clr.b	PwrUpEn(a6)	;and no powerups

		move.w	#6616,d0

		move.w	d0,PUOff1(a6)	;set up Offset ptrs
		addq.w	#4,d0
		move.w	d0,PUOff2(a6)
		addq.w	#4,d0
		move.w	d0,PUOff3(a6)

		moveq	#BP_HMOD,d0
		move.w	d0,PUMod1(a6)	;plot moduli for
		move.w	d0,PUMod2(a6)	;PowerUp indicators
		move.w	d0,PUMod3(a6)

		moveq	#-1,d0
		clr.w	d0
		moveq	#0,d1
		move.l	d1,PUIRev1(a6)	;image reversal value
		move.l	d0,PUInd1(a6)	;image value
		lsr.l	#8,d0
		move.l	d1,PUIRev2(a6)
		move.l	d0,PUInd2(a6)
		lsr.l	#8,d0
		move.l	d1,PUIRev3(a6)
		move.l	d0,PUInd3(a6)

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

		move.b	CIABCRA,d0
		move.b	d0,OldBCRA(a6)		;save CIA-B
		move.b	CIABCRB,d0		;control regs
		move.b	d0,OldBCRB(a6)

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

;		move.w	#DMA_SET1,DMACON(a5)	;Activate DMA and
		move.w	#DMA_SET2,DMACON(a5)	;Activate DMA and
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
* then set up body counts from scratch, else leave alone.
* Alter all alien counts at start of attack wave.

* d0-d3/a1-a2 corrupt


InitPlayer	move.l	pd_WaveNumber(a0),d0	;get wave number

		move.w	d0,d3		;copy for Baiter timings
		and.w	#$0F,d3
		add.w	d3,d3

		cmp.l	#15,d0		;too big?
		bls.s	INP_1		;skip if not
		moveq	#15,d0		;else wave 15

INP_1		move.l	d0,d1
		move.l	BAIStartup(a6),a1
		move.w	0(a1,d3.w),d2	;get Baiter Alarm value
		bsr	Random		;make random number
		move.w	Seed(a6),d3	;get random number
		and.w	#$1FF,d3
		sub.w	#$FF,d3
		add.w	d3,d2		;create final alarm value
		swap	d2
		clr.w	d2		;zero out high word
		swap	d2
		move.l	d2,pd_BaiterAlarm(a0)
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,d1
		add.l	d1,d1		;wave number * 12

		move.l	AWStartup(a6),a1
		lea	0(a1,d1.l),a1	;point to attack wave
		lea	pd_Landers(a0),a2	;point to Lander data

		moveq	#0,d2


* This lot computes total alien counts. It initialises each individual
* alien count, and then computes a total. The idea is to allow later
* code to rebuild the Anim lists with the correct number of aliens.


		move.w	(a1)+,d1
		move.w	d1,(a2)+		;pop in data for
		add.w	d1,d2		;numbers of odd bods
		move.w	(a1)+,d1		;and create total
		move.w	d1,(a2)+		;attack wave size
		add.w	d1,d2
		move.w	(a1)+,d1
		move.w	d1,(a2)+
		add.w	d1,d2
		move.w	(a1)+,d1
		move.w	d1,(a2)+
;		add.w	d1,d2		;except for Baiters!
		move.w	(a1)+,d1
		move.w	d1,(a2)+
		add.w	d1,d2
		move.w	(a1)+,d1
		move.w	d1,(a2)+
		add.w	d1,d2

		move.w	d2,pd_DoneAW(a0)

		moveq	#0,d2
		move.b	d2,pd_PwrUp(a0)	;no PowerUps
		move.b	d2,pd_BAlert(a0)	;no Baiter on line
		move.w	d2,pd_Turbo(a0)	;no turbo
		move.w	d2,pd_Shield(a0)	;no shield
		move.w	d2,pd_SMCount(a0)
		move.l	d2,pd_PuPtr(a0)
		move.l	d2,pd_MsPtr(a0)

		move.b	d2,pd_PUVis1(a0)
		move.b	d2,pd_PUVis2(a0)
		move.b	d2,pd_PUVis3(a0)

		tst.l	d0		;1st attack wave?
		bne.s	INP_2		;skip if not

		move.l	d0,pd_Score(a0)	;else init score
		moveq	#3,d1
		move.w	d1,pd_Lives(a0)	;initial lives count
		move.w	d1,pd_SBombs(a0)	;& smart bombs
		clr.b	pd_NoLand(a0)	;start with some land


* This lot below sets up when the first new lives/smart bombs
* appear (after 10,000 points), and when after that they appear
* every extra 10,000 points). In future, this can be user-config-
* urable...


		moveq	#0,d1
		move.w	#10000,d1
		move.l	d1,pd_NewBombs(a0)
		move.l	d1,pd_SBIncr(a0)
		move.l	d1,pd_NewLives(a0)
		move.l	d1,pd_NLIncr(a0)
		moveq	#10,d1
		move.w	d1,pd_Bodies(a0)	;and bodies to save

INP_2		addq.l	#1,pd_WaveNumber(a0)	;attack wave NNNN

		clr.l	pd_BaiterClock(a0)


* Now we see if there is land to fly over. If not, swap the Lander & Mutant
* counts around, to initialise the wave properly for landscape-less attack
* waves...


		tst.w	pd_Bodies(a0)	;no Bodies left?
		bne.s	INP_3		;skip if some left

		move.l	pd_WaveNumber(a0),d0
		moveq	#3,d1
		and.l	d1,d0		;wavenumber mod 4 = 0?
		bne.s	INP_4		;skip if not


* Here, we're back to normal. Re-initialise the Body count, and re-enable
* the Landscape.


		moveq	#10,d0
		move.w	d0,pd_Bodies(a0)	;re-initialise Bodies
		clr.b	pd_NoLand(a0)	;re-enable LandScape
		clr.w	LSCountDown(a6)	;and stop countdown

INP_3		rts


* Come here if we're stuck with no landscape.


INP_4		move.l	pd_Landers(a0),d0	;exchange Lander
		swap	d0		;and Mutant counts
		move.l	d0,pd_Landers(a0)

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

		moveq	#110,d0			;number to do

		move.l	a2,a3			;copy ptr to this

INS_1		add.w	#AO_Sizeof,a3		;make ptr to next

		move.l	a3,Anim_Next(a2)		;ptr to next
		move.l	a1,Anim_Prev(a2)		;ptr to prev

		move.b	#_ANF_DISABLED,Anim_Flags(a2)

		clr.l	AO_SpecialCode(a2)	;kill code ptr
		clr.l	AO_ScanLoc(a2)

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


InitSet		bsr	MakeBomberList		;create Bomber List

		move.l	CurrentPlayer(a6),a0	;set up player
		bsr	InitPlayer		;variables

		moveq	#0,d0
		move.w	d0,BomberCount(a6)
		move.l	d0,SwarmerList(a6)
		move.l	d0,SwarmerPtr(a6)
		move.l	d0,pd_SwarmerList(a0)
		move.l	d0,pd_SwarmerPtr(a0)

		bsr	Random
		move.l	Seed(a6),d0		;create start pos
		and.w	#$3FF,d0			;for pods
		sub.w	#$1FF,d0
		move.w	d0,PodBasePos(a6)

		bsr	Random			;create 2 start pos'ns
		move.l	Seed(a6),d0		;for Mutants on
		and.w	#$1FF,d0			;waves without a
		add.w	#600,d0			;landscape
		move.w	d0,MutantStart(a6)
		swap	d0
		and.w	#$1FF,d0
		move.w	MaxScrPos(a6),d1
		lsr.w	#1,d1
		add.w	d1,d0
		move.w	d0,MutantStart+2(a6)


* Now fall through to...


* RemakeSet(a6)
* a6 = ptr to main program variables

* Initialise the Anim structs whenever the game is to be
* restarted (after either death or attack wave completion).

* d0-d4/a0-a3 corrupt


RemakeSet	move.l	CurrentPlayer(a6),a0	;ptr to Player
;		move.l	AlienAnims(a6),a1		;ptr to 1st Anim

		move.l	pd_AOList(a0),a1
		move.l	Anim_Next(a1),a1		;ptr to 1st
		move.l	Anim_Next(a1),a1		;Alien anim

		move.w	pd_Bodies(a0),d0		;any Bodies?
		beq.s	RST_1			;skip if not

		move.l	a1,BodyList(a6)		;ptr to Body list
		move.l	a1,BodyPtr(a6)		;current Body
		move.l	a1,pd_BodyList(a0)	;player's local copy

		move.l	BodyAnFr(a6),d1		;get Anim frame ptr
		lea	BodyInit(pc),a2

RST_L1		move.l	d1,Anim_Frames(a1)	;pop in AnFr ptrs
		move.l	d1,Anim_CFrame(a1)
		bsr	Random
		move.l	Seed(a6),d2
		and.w	MaxScrPos(a6),d2
		move.w	d2,Anim_XPos(a1)		;random X position
		move.w	#180,Anim_YPos(a1)	;fixed Y position
		move.w	#_AL_BODY,Anim_ID(a1)	;object ID
		clr.b	Anim_Flags(a1)		;enable Anim
		clr.b	AO_Flags(a1)		;no special status
;		clr.l	AO_SpecialCode(a1)	;no SpecialCode
		move.l	a2,AO_SpecialCode(a1)
		moveq	#-1,d2
		clr.w	d2
		move.l	d2,AO_ScanMsk1(a1)

		move.l	Anim_Next(a1),a1		;next struct
		subq.w	#1,d0			;done them all?
		bne.s	RST_L1			;back if not

RST_1		lea	AlienAnFr(a6),a2	;ptr to array of AnFr ptr
		lea	pd_Landers(a0),a3	;ptr to alien count array
		move.l	SVStartup(a6),a0	;ptr to SpecialValues array
		moveq	#_AL_LANDER,d3	;Alien ID number
		moveq	#6,d4		;no. of alien types to do

RST_L3		move.l	(a2)+,d1		;get Anim frame ptr

		move.w	(a3)+,d0		;any aliens?
		beq.s	RST_2		;skip if not

RST_L2		move.l	d1,Anim_Frames(a1)	;set up AnFr's
		move.l	d1,Anim_CFrame(a1)
		move.w	d3,Anim_ID(a1)		;set type
;		clr.b	Anim_Flags(a1)		;enable Anim

		move.b	#_ANF_SAMEFRAME,Anim_Flags(a1)
		clr.b	AO_Flags(a1)


* Optimise here when finished! Also, AO_SpecialCode is ALWAYS LAST
* unless order in SpecialValues array changed!!!


		move.w	(a0),AO_Points(a1)
		move.w	2(a0),AO_XMove(a1)
		move.w	4(a0),AO_YMove(a1)
		move.w	6(a0),AO_XOff(a1)
		move.w	8(a0),AO_YOff(a1)
		move.w	10(a0),AO_XDisp(a1)
		move.w	12(a0),AO_YDisp(a1)
		move.w	14(a0),AO_YLDisp(a1)
		move.w	16(a0),AO_ScanMsk1(a1)
		move.w	18(a0),AO_ScanMsk2(a1)

		move.l	20(a0),AO_SpecialCode(a1)

RST_3		clr.b	AO_Flags(a1)

		move.l	Anim_Next(a1),a1		;next struct
		subq.w	#1,d0			;done them all?
		bne.s	RST_L2			;back if not

RST_2		nop

		add.w	#24,a0		;next SVArray entry

		addq.w	#1,d3		;next alien type
		subq.w	#1,d4		;done all types?
		bne.s	RST_L3		;back for more if not


* Here, A1 points to the next AO_ struct to initialise. Use this
* for the Baiters. allow up to four of them (gulp...).


		move.l	a1,BaiterPtr(a6)		;set Baiter ptr
		lea	BaiterCode(pc),a2

		move.b	#_ANF_DISABLED,Anim_Flags(a1)
		move.w	#_AL_BAITER,Anim_ID(a1)
		move.l	a2,AO_SpecialCode(a1)
		move.l	Anim_Next(a1),a1

		move.b	#_ANF_DISABLED,Anim_Flags(a1)
		move.w	#_AL_BAITER,Anim_ID(a1)
		move.l	a2,AO_SpecialCode(a1)
		move.l	Anim_Next(a1),a1

		move.b	#_ANF_DISABLED,Anim_Flags(a1)
		move.w	#_AL_BAITER,Anim_ID(a1)
		move.l	a2,AO_SpecialCode(a1)
		move.l	Anim_Next(a1),a1

		move.b	#_ANF_DISABLED,Anim_Flags(a1)
		move.w	#_AL_BAITER,Anim_ID(a1)
		move.l	a2,AO_SpecialCode(a1)
		move.l	Anim_Next(a1),a1


* Don't forget to point to the first free one above!


* Below, don't terminate the list unless another call to InitStructs()
* is envisaged!


* Now that all the Anims that need to be set up have been,
* ensure that the list is properly terminated!


;		move.l	Anim_Prev(a1),a1	;this is last actual struct

;		move.l	ShipAnim(a6),a2

;		move.l	a2,Anim_Next(a1)	;next(last)=first
;		move.l	a1,Anim_Prev(a2)	;prev(first)=last


		rts


* DisableAliens(a0,a1)
* a0 = ptr to 1st Alien anim for player
* a1 = ptr to Ship anim for player

* Disables all Alien Anim structs to prevent spurious objects
* appearing in subsequent games.

* d0/a0-a1 corrupt


DisableAliens	moveq	#_ANF_DISABLED,d0	;Disable anim flag value

DAL_1		move.b	d0,Anim_Flags(a0)	;disable anim
		move.l	Anim_Next(a0),a0	;ptr to next
		cmp.l	a1,a0		;hit the ship anim?
		bne.s	DAL_1		;back for more if not

		rts			;else done


* Random(a6)
* a6 = ptr to main program variables
* Generate pseudo-random number using one of my famous PRNGs.
* Store result in vars pointed to by A6.

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
* then puts a WAIT $FFFE instruction at the end. Also points
* sprite ptrs to point to a null sprite.

* d0-d2/a0-a2 corrupt


MakeCopper	move.w	#SPR0PTH,d0	;1st sprite ptr reg number
		move.l	NullArea(a6),d1	;null sprite ptr
		moveq	#8,d2		;no. to do

MCList_2		swap	d1		;get high word
		move.w	d0,(a0)+		;do copper MOVE
		move.w	d1,(a0)+		;using this data
		addq.w	#2,d0		;next reg number
		swap	d1		;get low word
		move.w	d0,(a0)+		;repeat copper MOVE
		move.w	d1,(a0)+		;for sprite 0
		addq.w	#2,d0		;next reg no.

		subq.w	#1,d2		;done them all?
		bne.s	MCList_2		;back for more if not

		move.w	#BPL1PTH,d0	;1st bitplane ptr reg no.

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


* LtoA10(d0,a0) -> a0
* d0 = long integer to convert to string
* a0 = ptr to string buffer

* Performs LtoA() below using Base 10 table. Gets ptr to
* table and falls through to LtoA() below.

* d1-d2/a1-a2 corrupt


LtoA10		lea	Base10(pc),a1


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
;		move.w	#$3000,(a0)	;else make string "0"
		move.b	#"0",(a0)	;this is the safer way
		clr.b	1(a0)		;of doing it-no Gurus
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

* Set ship up/down speed.
* Once used joystick. Now configurable!

* d0-d2/a0-a1 corrupt


ShipUpDown	move.l	UpKeyPtr(a6),a0		;get which key/stick
		move.b	(a0),d0			;get var value
		and.b	UpKeyMsk(a6),d0		;ensure var masked!
		cmp.b	UpKeyVal(a6),d0		;correct one?
		beq.s	SUP_x			;skip if so

		move.l	DownKeyPtr(a6),a0		;get which key/stick
		move.b	(a0),d0			;get var value
		and.b	DownKeyMsk(a6),d0		;ensure var masked!
		cmp.b	DownKeyVal(a6),d0		;correct one?
		beq.s	SUP_y			;skip if so

		tst.w	VertSpeed(a6)	;already zero?
		beq.s	SUP_Done		;skip if so

		subq.w	#1,VertSpeed(a6)	;else reduce it

SUP_Done		rts

SUP_x		move.w	VertSpeed(a6),d0	;up/down speed
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


SUP_y		move.w	VertSpeed(a6),d0	;up/down speed
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


* ScrMove(a6)
* a6 = ptr to main program variables

* Set scroll speed for screen.
* If key is pressed & held down, speed is increased until it
* hits a predetermined maximum. Once key is released, the speed
* is progressively reduced to zero.

* Uses Amiga shift-type key.

* Note extra code to maintain inertia while reversing!

* d0-d4/a0-a1 corrupt


ScrMove		move.l	FlameAnim(a6),a0		;ptr to flame Anim

		or.b	#_ANF_NOSHOW,Anim_Flags(a0)

		tst.b	Brakes(a6)		;stopped?
		bne.s	ScrM_1b			;exit if so

		move.l	ThrKeyPtr(a6),a1		;get which key/stick
		move.b	(a1),d0			;get var value
		and.b	ThrKeyMsk(a6),d0		;ensure var masked!
		cmp.b	ThrKeyVal(a6),d0		;correct one?
		bne.s	ScrM_1			;skip if not

		move.w	MaxScrSpeed(a6),d0	;upper speed

		move.w	CurrXSpeed(a6),d1	;current speed
		addq.w	#1,d1		;increase speed
		cmp.w	d0,d1		;too fast?
		bls.s	ScrM_1a		;skip if not
		move.w	d0,d1		;else set speed to maximum
ScrM_1a		move.w	d1,CurrXSpeed(a6)	;update speed

		and.b	#_NANF_NOSHOW,Anim_Flags(a0)

		rts

ScrM_1		tst.w	CurrXSpeed(a6)	;current speed
		beq.s	ScrM_1b		;skip if already zero

		move.b	InertiaKludge(a6),d0	;handle inertia
		subq.b	#1,d0			;when slowing down
		and.b	#1,d0
;		and.b	#3,d0
		move.b	d0,InertiaKludge(a6)
		bne.s	ScrM_1b

		subq.w	#1,CurrXSpeed(a6)	;else reduce it

ScrM_1b		rts


* Reverse(a6)
* a6 = ptr to main program variables

* Reverse the direction of the ship. Once used 
* an Amiga shift key. Now configurable!

* d0-d5/a0-a1 corrupt


Reverse		tst.b	Reversing(a6)		;last reverse done?
		bne	RevDone			;no-don't do it yet

		tst.b	Brakes(a6)		;stopped dead?
		bne	RevDone			;skip if so

		move.l	RevKeyPtr(a6),a0		;get which key/stick
		move.b	(a0),d0			;get var value
		and.b	RevKeyMsk(a6),d0		;ensure var masked!
		cmp.b	RevKeyVal(a6),d0		;correct one?
		bne.s	RevDone			;skip if not

		move.l	ShipAnim(a6),a0		;ptr to ship Anim
		move.l	FlameAnim(a6),a1		;ptr to flame Anim

		move.l	Anim_Frames(a1),d0	;check which AnFr
		cmp.l	Anim_CFrame(a1),d0	;frame #1?
		bne.s	RevDone			;don't reverse!

_Rev		movem.l	SRevAnFrs(a6),d0-d1	;get ship AnFr seqs
		exg	d0,d1
		movem.l	d0-d1,SRevAnFrs(a6)	;swap around

		movem.l	FRevAnFrs(a6),d2-d3	;get flame AnFr seqs
		exg	d2,d3
		movem.l	d2-d3,FRevAnFrs(a6)	;swap around

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


* NOTES ABOUT TIMERS!

* CIA-A Timer A can't be used as a free timer, because it's used to
* synchronise the keyboard!

* Using the timer code:

* to find out how many E clock pulses elapses during a given piece
* of code:do the following:

* 1) MOVEQ #-1,D0 followed by BSR SetTimer

* 2) BSR TimerOn to start the timer

* 3) Code to be timed follows immediately

* 4) At end of code, do BSR TimerOff

* 5) Then do BSR CompTime. D0 contains elapsed time.

* TimerOn()
* Turns on CIA-B timer, using timers A & B as a 32-bit timer.

* d0 corrupt


TimerOn		move.b	CIABCRB,d0	;get current control
		and.b	#%10000010,d0	;leave unused bits alone
		or.b	#%01010001,d0	;TB reacts to TA, continous
		move.b	d0,CIABCRB	;set it up
		
		move.b	CIABCRA,d0	;get current control
		and.b	#%11000111,d0	;TA counts 02 pulses
		or.b	#%0001,d0	;TA on, no PB6, continuous
		move.b	d0,CIABCRA	;set it up
		rts


* TimerOff()
* Turns off CIA-B timer. Stops both timers A and B

* d0 corrupt

TimerOff		move.b	CIABCRA,d0
		and.b	#%01111110,d0	;stop TA
		move.b	d0,CIABCRA

		move.b	CIABCRB,d0
		and.b	#$FE,d0		;stop TB
		move.b	d0,CIABCRB
		rts


* SetTimer(d0,d1)
* d0 = timer start value

* Initialise CIA-B timers

* d0 corrupt


SetTimer		swap	d0		;get timer B (high word)
		move.b	d0,CIABTBLO	;load low byte first
		lsr.w	#8,d0
		move.b	d0,CIABTBHI	;high byte transfers latch
		swap	d0		;now timer A (low word)
		move.b	d0,CIABTALO	;load low byte first
		lsr.w	#8,d0
		move.b	d0,CIABTAHI	;high byte transfers latch
		rts


* CompTime() -> d0
* recover CIA-B timer value after a TimerOff() call,
* then perform subtraction to work out true timer
* elapsed value in terms of E clock. Elapsed time
* in terms of cycles is 10 * E clock time.

* Don't call before calling TimerOff() or the result
* will be wrong!

* Returns elapsed E clock time in d0.

* no other registers corrupt


CompTime		move.l	d1,-(sp)		;save so we can use it
		moveq	#-1,d0

		move.b	CIABTBHI,d1	;note:swap for high word
		lsl.w	#8,d1		;of timer plus lsl.w for
		move.b	CIABTBLO,d1	;each individual timer
		swap	d1		;faster than three lsl.l's
		move.b	CIABTAHI,d1	;and more elegant!
		lsl.w	#8,d1
		move.b	CIABTALO,d1

		sub.l	d1,d0		;compute elapsed time
		move.l	(sp)+,d1		;recover scratched reg
		rts


* Int2Handler()
* Handle Level 2 interrupt (CIA-A)
* Get key value etc

* NOTE : CIA-A Timer A MUST be left alone for the keyboard to
* function! CIA-A TA counts 02 clock pulses from 68000 E pin.


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
;		clr.b	Reversing(a6)	;and ship reverse flag

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
Int2_6		subq.w	#1,d2		;on a 68000:change it
		bne.s	Int2_6		;for 68020 etc!

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


* This is the VBL Handler. ##VBL.


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


* This is game-specific. Handle the PowerUp indicators for
* Defender Plus.


		move.b	PwrUpOn(a6),d1	;power-up indicator

		move.l	RasterWaiting(a6),a1	;ptr to screen
		move.w	PUOff1(a6),d2
		add.w	d2,a1			;true scrn addr

		lsr.b	#1,d1		;get turbo thrust bit
		bcs.s	Int3_PU1		;skip if set
		sf	PUVis1(a6)	;else set not visible
		bra.s	Int3_PU1b	;and skip

Int3_PU1		move.w	PUCnt1(a6),d2	;countdown hits zero?
		subq.w	#1,d2
		bne.s	Int3_PU1a	;skip if not

		not.b	PUVis1(a6)	;else change state

		moveq	#10,d2		;reset count

Int3_PU1a	move.w	d2,PUCnt1(a6)	;store count back

Int3_PU1b	moveq	#0,d2
		move.b	PUVis1(a6),d2	;visible yes/no byte
		ext.w	d2
		add.w	d2,d2		;convert to longword offset
		add.w	d2,d2
		lea	PUIRev1(a6),a0	;point to image data ptrs
		move.l	0(a0,d2.w),d3	;get correct image data
		moveq	#0,d4		;set for Lt. Blue
		move.l	d3,d5

		move.w	PUMod1(a6),d2	;add-on modulo

		move.l	d3,(a1)		;plot image
		add.w	d2,a1
		move.l	d4,(a1)
		add.w	d2,a1
		move.l	d5,(a1)
		add.w	d2,a1
		move.l	d3,(a1)
		add.w	d2,a1
		move.l	d4,(a1)
		add.w	d2,a1
		move.l	d5,(a1)
		add.w	d2,a1

		move.l	RasterWaiting(a6),a1	;ptr to screen
		move.w	PUOff2(a6),d2
		add.w	d2,a1			;true scrn addr

		lsr.b	#1,d1		;get shield bit
		bcs.s	Int3_PU2		;skip if set
		sf	PUVis2(a6)	;else set not visible
		bra.s	Int3_PU2b	;and skip

Int3_PU2		move.w	PUCnt2(a6),d2	;countdown hits zero?
		subq.w	#1,d2
		bne.s	Int3_PU2a	;skip if not

		not.b	PUVis2(a6)	;else change state

		moveq	#10,d2		;reset count

Int3_PU2a	move.w	d2,PUCnt2(a6)	;store count back

Int3_PU2b	moveq	#0,d2
		move.b	PUVis2(a6),d2	;visible yes/no byte
		ext.w	d2
		add.w	d2,d2		;convert to longword offset
		add.w	d2,d2
		lea	PUIRev2(a6),a0	;point to image data ptrs
		move.l	0(a0,d2.w),d5	;get correct image data
		moveq	#0,d4		;set for Green
		move.l	d4,d3

		move.w	PUMod2(a6),d2	;add-on modulo

		move.l	d3,(a1)		;plot image
		add.w	d2,a1
		move.l	d4,(a1)
		add.w	d2,a1
		move.l	d5,(a1)
		add.w	d2,a1
		move.l	d3,(a1)
		add.w	d2,a1
		move.l	d4,(a1)
		add.w	d2,a1
		move.l	d5,(a1)
		add.w	d2,a1

		move.l	RasterWaiting(a6),a1	;ptr to screen
		move.w	PUOff3(a6),d2
		add.w	d2,a1			;true scrn addr

		lsr.b	#1,d1		;get smart missile bit
		bcs.s	Int3_PU3		;skip if set
		sf	PUVis3(a6)	;else set not visible
		bra.s	Int3_PU3b	;and skip

Int3_PU3		move.w	PUCnt3(a6),d2	;countdown hits zero?
		subq.w	#1,d2
		bne.s	Int3_PU3a	;skip if not

		not.b	PUVis3(a6)	;else change state

		moveq	#10,d2		;reset count

Int3_PU3a	move.w	d2,PUCnt3(a6)	;store count back

Int3_PU3b	moveq	#0,d2
		move.b	PUVis3(a6),d2	;visible yes/no byte
		ext.w	d2
		add.w	d2,d2		;convert to longword offset
		add.w	d2,d2
		lea	PUIRev3(a6),a0	;point to image data ptrs
		move.l	0(a0,d2.w),d4	;get correct image data
		moveq	#0,d3		;set for Red
		move.l	d3,d5

		move.w	PUMod3(a6),d2	;add-on modulo

		move.l	d3,(a1)		;plot image
		add.w	d2,a1
		move.l	d4,(a1)
		add.w	d2,a1
		move.l	d5,(a1)
		add.w	d2,a1
		move.l	d3,(a1)
		add.w	d2,a1
		move.l	d4,(a1)
		add.w	d2,a1
		move.l	d5,(a1)
		add.w	d2,a1


* Here handle any Copper interrupts.


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
		and.b	#_ANF_DISABLED,d0		;is it?
		bne	BPC_2d			;skip if disabled


* Here, execute the SpecialCode for each of the objects if
* required. DON'T TRASH A0!!


		move.l	AO_SpecialCode(a0),d0	;code pointer exists?
		beq.s	BPC_X1			;skip if not
		move.l	d0,a1
		jsr	(a1)		;execute SpecialCode


* Here, handle the x coordinates of the object relative to the screen.
* If it's one of the non-scolling Anims, don't bother!


BPC_X1		move.w	Anim_ID(a0),d0	;non-scroller (i.e., ship
		cmp.w	#_AL_BODY,d0	;or flame)?
		bcs.s	BPC_2c		;skip if so
		move.b	Anim_Flags(a0),d0	;get flags
		move.b	d0,d3		;DON'T TRASH THIS!
		and.b	#_ANF_DISABLED,d0	;disabled by SpecialCode?
		bne	BPC_2d		;skip if so

		and.b	#_NANF_NOSHOW,d3	;temp visible enable

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


BPC_X2		or.b	#_ANF_NOSHOW,d3


* DON'T RESTORE X COORD! AGH BUG! if 1st round = 160, keep it 160
* because test above performed on object x PLUS screen x!!!

* also, don't forget to skip this next lot if invisible! Saves
* 90 cycles or so per loop that I was wasting beforehand!


BPC_2		move.b	d3,Anim_Flags(a0)		;set flags-d3 ok now
		and.b	#_ANF_NOSHOW,d3		;invisible?
		bne	BPC_1			;skip if so


* Now animate using the AnFr_XChange vars if needed, not forgetting to
* prevent off-screen vertical movements.


BPC_2c		move.l	Anim_CFrame(a0),a1	;ptr to Anim Frame
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
		add.l	d0,a2
		move.w	Anim_XPos(a0),d0		;starting x position
		move.w	Anim_ID(a0),d1		;non-scrolling Anims?
		cmp.w	#_AL_BODY,d1
		bcs.s	BPC_B1			;skip if so
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


* Here, handle the scanner. Blank out old dots, pop in new dots.


BPC_1		move.w	Anim_ID(a0),d0	;flame object?
		cmp.w	#_AL_FLAME,d0
		beq.s	BPC_2d		;skip if so


* Here, we're not dealing with the Flame object, so alter the
* scanner dots.


		move.l	AO_ScanLoc(a0),d0	;ptr exists?
		beq.s	BPC_2b		;skip if not
		move.l	d0,a1		;else set pointer

		moveq	#-1,d0
		move.l	AO_ScanBit1(a0),d2	;get scanner bits

		eor.l	d2,d0		;mask out unwanted bits
		and.l	d0,(a1)		;clear points

BPC_2b		move.l	ScanHList(a6),a2	;ptr to horiz table
		move.w	Anim_XPos(a0),d0	;get x coord
		tst.w	Anim_ID(a0)	;ship object?
		beq.s	BPC_2h		;skip if so
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0
BPC_2h		lsr.w	#4,d0		;x/16 = index into table
		move.b	0(a2,d0.w),d0	;get bitnum:offset
		ror.l	#4,d0		;save offset
		moveq	#0,d2		;clear this
		bset	d0,d2		;make set bits
		swap	d2		;for updating scanner
		bset	d0,d2		;and keep this...

		and.l	AO_ScanMsk1(a0),d2	;change dot colours!

		rol.l	#4,d0		;recover offset
		and.w	#7,d0		;and constrain to limits
		add.w	d0,d0		;expand for longword
		add.w	d0,d0		;indexing

		move.l	ScanPosList(a6),a2
		move.l	0(a2,d0.w),d0	;get scanner base loc

		move.w	Anim_YPos(a0),d1	;y coord
		sub.w	#MIN_SY,d1	;table index
		move.l	ScanVList(a6),a2
		move.b	0(a2,d1.w),d1	;get offset
		move.l	d0,a2		;get base ptr
		and.b	#$FF,d1		;constrain to limits
		add.w	d1,d1		;longword to byte
		add.w	d1,d1		;offset
		add.w	d1,a2		;this is final addr

		move.l	a2,AO_ScanLoc(a0)
		move.l	d2,AO_ScanBit1(a0)

		or.l	d2,(a2)		;set scanner bits


* Here, get next Anim, and if hit end of list, move on to next function


BPC_2d		move.l	Anim_Next(a0),a0		;get next Anim struct
		move.l	a0,AnimThis(a6)		;set for next call

		cmp.l	AnimFirst(a6),a0		;back to start of list?
		bne	BPC_L1			;back if not

		rts



* BlitPlot(a6)
* a6 = ptr to main program variables

* Plot the blitter objects and change animation frames once plotted.
* Also handles object deaths and extra lives/smart bombs!

* d0-d3/a0-a1 corrupt


BlitPlot		move.l	AnimFirst(a6),a0		;ptr to 1st Anim

BPL_L1		move.b	Anim_Flags(a0),d0		;disabled?
		move.b	d0,d1
		and.b	#_ANF_DISABLED,d0
		bne.s	BPL_1			;skip if so

		and.b	#_ANF_NOSHOW,d1		;invisible?
		bne.s	BPL_1			;skip if invisible


* Here, plot the object using the blitter precomps...also handle the
* collisions between aliens and other objects here.


BPL_Ena		move.w	Anim_ID(a0),d0	;get Anim ID
		cmp.w	#_AL_BODY,d0	;one of the Aliens/Bodies?
		bcs.s	BPL_NoCol	;don't do collision if not

		move.l	CurrColl(a6),a1	;this table entry
		move.l	a0,(a1)+		;this is the collider
		move.l	a1,CurrColl(a6)	;update array
		clr.l	(a1)		;mark fresh table end
		addq.w	#1,CollCount(a6)	;update table size

BPL_NoCol	btst	#6,DMACONR(a5)

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
		exg	d2,d3			;else swap these
BPL_4		move.l	d2,Anim_CFrame(a0)	;swap frame

BPL_3		move.w	Anim_ID(a0),d0		;non-scroller?
		cmp.w	#_AL_BODY,d0
		bcs.s	BPL_5			;skip if so

		move.b	AO_Flags(a0),d0		;check object status
		and.b	#_AOF_DYING,d0		;dying off?
		beq.s	BPL_5			;skip if not

		move.b	#_ANF_DISABLED,Anim_Flags(a0)	;else kill it
		and.b	#_NAOF_DYING,AO_Flags(a0)

		move.l	AO_ScanLoc(a0),a1		;clear out
		move.l	AO_ScanBit1(a0),d1	;scanner dots for
		not.l	d1			;dead object
		and.l	d1,(a1)

BPL_8		move.l	CurrentPlayer(a6),a1	;get current player
		move.l	pd_Score(a1),d0		;score for killing
		moveq	#0,d1			;alien
		move.w	AO_Points(a0),d1		;add total points
		add.l	d1,d0
		move.l	d0,pd_Score(a1)		;put back score
		move.w	Anim_ID(a0),d1
		cmp.w	#_AL_BAITER,d1		;hit a Baiter?
		beq.s	BPL_5			;skip if so
		cmp.w	#_AL_BODY,d1		;hit a Body?
		beq.s	BPL_5			;skip if so
		subq.w	#1,pd_DoneAW(a1)		;1 less to go...

BPL_5		move.l	Anim_Next(a0),a0		;get next Anim struct

		cmp.l	AnimFirst(a6),a0		;back to start of list?
		bne	BPL_L1			;skip if not

		move.l	CurrentPlayer(a6),a1

		move.l	pd_Score(a1),d0		;score
		cmp.l	pd_NewLives(a1),d0	;extra life?
		bcs.s	BPL_6			;skip if not
		addq.w	#1,pd_Lives(a1)		;1 extra life

		move.l	pd_NewLives(a1),d1	;new life cmp val
		add.l	pd_NLIncr(a1),d1		;add this to it
		move.l	d1,pd_NewLives(a1)	;and replace

BPL_6		cmp.l	pd_NewBombs(a1),d0	;extra smart bomb?
		bcs.s	BPL_7			;skip if not
		addq.w	#1,pd_SBombs(a1)

		move.l	pd_NewBombs(a1),d1	;new s.b. cmp val
		add.l	pd_SBIncr(a1),d1		;add this to it
		move.l	d1,pd_NewBombs(a1)	;and replace

BPL_7		rts


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


* Landscape drawing/handling routines


* CreateLSList(a6)
* a6 = ptr to main program variables

* Create landscape list using new algorithm that randomly
* selects landscape features from a list.

* d0-d3/a0-a3 corrupt


CreateLSList	move.l	LandScape(a6),a0	;ptr to 1st landscape list
		move.l	a0,a1		;copy ptr
		moveq	#0,d0		;'flat land' byte
		move.w	#512,d1		;no. of entries in list

CLSL_1		move.b	d0,(a1)+		;create flat land
		subq.w	#1,d1		;done whole landscape?
		bne.s	CLSL_1		;back for more if not


* Now, use random numbers to select a landscape feature from the
* feature list, and insert it into the landscape.


;		bsr	Random		;make random no.
;		move.l	Seed(a6),d0	;get it
;		and.w	#7,d0		;value from 0 to 7
;		addq.w	#4,d0		;value from 4 to 11
;		move.w	Seed(a6),d1
;		and.w	#3,d1
;		add.w	d1,d0		;value from 4 to 14


* Now set initial landscape feature position & prepare to insert


		moveq	#0,d1		;initial position
		move.l	a0,a1		;ptr to landscape list
		lea	LSFeatures(pc),a2	;ptr to feature list

CLSL_2		bsr	Random		;make random no.
		move.l	Seed(a6),d3	;get value
		and.w	#$F,d3		;value from 0 to 15
		addq.w	#8,d3		;value from 8 to 23
;		addq.w	#6,d3		;value from 14 to 29


* Having created distance to feature, now select feature to insert


		add.w	d3,d1		;position in list
		cmp.w	#511-6,d1	;wrapping around?
		bcc.s	CLSL_7		;branch if so
		move.w	Seed(a6),d3	;random number again
		and.w	#7,d3		;select feature number
		move.w	d3,d2

		add.w	d2,d2		;this is a quick multiply
		add.w	d3,d2		;by 6-feature table con-
		add.w	d2,d2		;tains 6-byte entries

		lea	0(a2,d2.w),a3	;point to feature
		moveq	#6,d2		;no. of feature bytes


* Here insert feature


CLSL_3		and.w	#511,d1		;wrap-around feature position
		move.b	(a3)+,d3		;get feature byte
		move.b	d3,0(a1,d1.w)	;insert feature byte in list
		addq.w	#1,d1		;next list position
		subq.w	#1,d2		;done all feature bytes?
		bne.s	CLSL_3		;back for more if not

;		subq.w	#1,d0		;done all features?
;		bne.s	CLSL_2		;back for more if not

		bra.s	CLSL_2


* Now select initial 'ride height' a la Citroen CX...


CLSL_7		move.w	#180,d0		;initial LandYHgt

		move.l	YTable(a6),a1
		add.w	d0,d0
		move.w	0(a1,d0.w),d0	;memory offset
		move.w	d0,LandYHgt(a6)	;save it

		move.l	LandOff(a6),a1	;ptr to offset list

		move.w	#512,d0		;no of entries
		moveq	#0,d1		;initial offset


* Below we create the offset list. These offsets are added to the blitter
* data pointers to position hills correctly on screen. The magic '2112'
* equals 44*16*3, for a 44-byte wide interleaved screen, 3 bitplanes deep,
* and a vertical displacement of 16 lines per hillside unit.


CLSL_4		move.b	(a0)+,d2		;get landscape byte
		cmp.b	#2,d2		;uphill land?
		bne.s	CLSL_5		;skip if not
		sub.w	#2112,d1		;else move offset up

CLSL_5		move.w	d1,(a1)+		;pop in offset byte
		cmp.b	#1,d2		;was it downhill?
		bne.s	CLSL_6		;skip if not
		add.w	#2112,d1		;else move offset down for next

CLSL_6		subq.w	#1,d0		;done them all?
		bne.s	CLSL_4		;back for more if not

		rts


LSFeatures	dc.b	2,2,2,1,1,1	;large hill
		dc.b	0,1,0,0,2,0	;crater
		dc.b	0,0,2,1,0,0	;small hill
		dc.b	0,2,0,0,1,0	;plateau
		dc.b	1,1,0,0,2,2	;deep crater
		dc.b	2,2,0,0,1,1	;volcano
		dc.b	0,1,2,2,1,0	;fault #1
		dc.b	0,2,1,1,2,0	;fault #2

		even


* PlotLandScape(a6)
* a6 = ptr to main program variables

* Plot the landscape.

* d0-d3/a0-a2 corrupt


PlotLandScape	tst.b	NoLand(a6)	;landscape enabled?
		beq.s	PLS_1		;skip if so
		rts			;else leave...

PLS_1		move.l	LandScape(a6),a0	;ptr to landscape table

		moveq	#-2,d0		;blitter mods
		move.w	d0,LandMods+2(a6)	;BLTBMOD
		move.w	d0,LandMods+4(a6)	;BLTAMOD
		moveq	#40,d0		;modulo for interleaved screen
		move.w	d0,LandMods(a6)	;BLTCMOD
		move.w	d0,LandMods+6(a6)	;BLTDMOD

		move.w	MaxScrPos(a6),d0
		move.w	CurrXPos(a6),d1
		addq.w	#1,d0
		sub.w	d1,d0
		and.w	#$F,d1		;get ASHx/BSHx for blitter

		move.w	d1,d3		;save here for now
		ror.w	#4,d1		;into proper place
		move.w	d1,LandCon+2(a6)	;BLTCON1
		or.w	#$FCA,d1		;BLTCON0 - cookie-cut
		move.w	d1,LandCon(a6)
		moveq	#-1,d1
		clr.w	d1
		move.l	d1,LandCon+4(a6)	;BLTAFWM/LWM

		move.l	RasterWaiting(a6),a1
		addq.l	#2,a1
;		moveq	#16,d1
		moveq	#0,d1
		sub.w	d3,d1		;true start screen x pos
		move.w	d1,LandXPos(a6)	;save it
		tst.w	d3		;ASHx zero?
		sne	d1		;make -1 if so
		ext.w	d1		;word sized!

		add.w	d1,d1		;make it -2
		add.w	d1,a1		;true scrn plot location

		move.l	a1,LandPtrs(a6)		;BLTCPTH/L
		move.l	a1,LandPtrs+12(a6)	;BLTDPTH/L

		lsr.w	#4,d0		;get index into table

PLS_L1		move.b	0(a0,d0.w),d1	;get landscape byte
		moveq	#0,d3
		move.w	d0,d2		;vertical offset index
		move.b	d1,d3		;graphic ptr index
		add.w	d2,d2		;index into word table
		add.w	d3,d3		;in each case
		lea	LandVolume(a6),a1
		move.w	0(a1,d3.w),LandSize(a6)
		move.l	LandOff(a6),a1
		move.w	0(a1,d2.w),d4	;get vertical memory offset
		add.w	LandYHgt(a6),d4
		ext.l	d4		;this is total vertical offset
		add.w	d3,d3
		lea	LandGraphic(a6),a1
		move.l	0(a1,d3.w),a1		;get graphic ptr
		move.l	a1,LandPtrs+4(a6)		;BLTBPTH/L
		move.l	a1,LandPtrs+8(a6)		;BLTAPTH/L
		movem.w	d0-d1,-(sp)		;save index/groundbyte

		btst	#6,DMACONR(a5)	;busy wait for
PLS_B1		btst	#6,DMACONR(a5)	;blitter
		bne.s	PLS_B1

		movem.l	LandPtrs(a6),d0-d3	;set up blitter
		add.l	d4,d0
		add.l	d4,d3
		movem.l	d0-d3,BLTCPTH(a5)		;for a plot
		movem.l	LandMods(a6),d0-d1
		movem.l	d0-d1,BLTCMOD(a5)
		movem.l	LandCon(a6),d0-d1
		movem.l	d0-d1,BLTCON0(a5)

		move.w	LandSize(a6),d0	;now go do the plot!
		move.w	d0,BLTSIZE(a5)

		addq.l	#2,LandPtrs(a6)		;next screen locs
		addq.l	#2,LandPtrs+12(a6)

		movem.w	(sp)+,d0-d1

PLS_B2		addq.w	#1,d0
		and.w	#$1FF,d0
		move.w	LandXPos(a6),d1	;move on to next
		add.w	#16,d1		;landscape X position
		move.w	d1,LandXPos(a6)
		cmp.w	#320,d1		;off RHS of actual screen?
;		cmp.w	#321,d1
		bcs	PLS_L1		;go back for more if not

		rts			;else done!


* MakeDeathList(a6)
* a6 = ptr to main program variables
* Construct the Death List for the ship when hit.

* d0-d3/a0 corrupt


MakeDeathList	move.l	DeathList(a6),a0		;ptr to DeathList

		move.w	DeathCount(a6),d0	;no. of entries
		move.w	d0,(a0)+		;list header

MDL_1		bsr	Random		;make random number

		move.l	Seed(a6),d1	;get random number
		move.w	d1,d2		;make copy
		and.w	#$F,d2		;restrict value to 0-31
		move.w	d2,d3		;copy again
		asl.w	#7,d3		;quick * 128
		add.w	d2,d2
		add.w	d2,d2
		add.w	d2,d3		;quick * 132
		sub.w	#8*132,d3	;make vertical offset
		move.w	d3,(a0)+		;save offset addon
		move.w	d3,(a0)+		;save offset total
		swap	d1		;get rest of random number
		and.w	#$E,d1		;shift value 0-14 and EVEN!
		move.w	d1,d2		;copy it
		lsl.w	#8,d2		;shift low byte -> high byte
		move.b	d1,d2		;2 copies per byte
		move.w	d2,(a0)+		;save last field of entry

		subq.w	#1,d0		;done them all?
		bne.s	MDL_1		;back for more if not

		rts


* PlotDeath(a6)
* a6 = ptr to main program variables
* Plot the ship death sequence on screen.

* d0-d7/a0-a3 corrupt


PlotDeath	move.w	DeathTime(a6),d0	;get no of remaining frames

		bne.s	PDTH_OK		;skip if still some to do
		rts			;else exit NOW.

PDTH_OK		subq.w	#1,d0		;1 less to do
		move.w	d0,DeathTime(a6)	;save frame counter

		move.l	ShipAnim(a6),a0	;ptr to Ship Anim struct

		move.w	Anim_XPos(a0),d0	;get X position
		move.w	Anim_YPos(a0),d1	;get Y position
		add.w	d1,d1		;word indexing!

		move.l	YTable(a6),a0	;get Y table
		moveq	#0,d2
		move.w	0(a0,d1.w),d2	;get y actual offset

		moveq	#0,d3
		move.l	d3,d4
		move.w	#MIN_SY,d3
		add.w	d3,d3
		move.w	0(a0,d3.w),d3	;get offset for MIN_SY
		move.w	#MAX_SY+1,d4
		add.w	d4,d4
		move.w	0(a0,d4.w),d4	;get offset for MAX_SY+1

		move.l	RasterWaiting(a6),a0
		move.l	a0,a1

		add.l	d2,a0		;scrnbase + vert offset
		move.w	d0,d2		;copy X coordinate
		and.w	#$F,d2		;get 'blitter shift' bits
		sne	d2		;make -1 if not zero
		ext.w	d2		;make word
		neg.w	d2		;make +1 if not zero
		addq.w	#1,d2		;correct for TLC
		asr.w	#4,d0
		add.w	d2,d0		;correct horiz offset
		add.w	d0,d0
		add.w	d0,a0		;screen plot pos

		move.l	a1,a2		;copy screen base
		add.l	d3,a2		;create minimum ptr
		move.l	a2,d6		;and save it
		move.l	a1,a2
		add.l	d4,a2		;create maximum ptr
		move.l	a2,d7		;and save it

		moveq	#3,d4		;2 set pixels


* Now we have the central plot position for the explosion. Now we scan the
* DeathList, get the data, and construct the 'shrapnel' to plot on to the
* screen. The 68000 can do this plotting-it's a waste of time setting up
* the blitter to plot 4 pixels at a time...


		move.l	DeathList(a6),a1	;ptr to DeathList

		move.w	(a1)+,d0		;get no. of entries

PDTH_1		move.w	d4,d5		;copy pixel pattern
		move.l	a0,a2		;copy base screen ptr
		move.w	(a1)+,d1		;get offset addon
		move.l	a1,a3		;copy DeathList current ptr
		move.w	(a1)+,d2		;get offset total
		add.w	d2,a2		;create new plot pointer
		add.w	d2,d1

		move.w	(a1)+,d2		;get horiz data
		move.w	d0,d3		;copy counter
		and.w	#1,d3		;odd or even?
		bne.s	PDTH_2		;skip if odd


* Here, we've got an even-numbered entry. The shift value is to
* the LEFT.


		moveq	#0,d3
		move.b	d2,d3		;horiz. offset total
		beq.s	PDTH_4		;zero-no shift
		rol.w	d3,d5		;rotate the pixels

PDTH_4		cmp.l	d6,a2		;ptr too small?
		bcs.s	PDTH_8		;don't plot if so
		cmp.l	d7,a2		;ptr too high?
		bcc.s	PDTH_8		;don't plot if so

		or.w	d5,(a2)		;plot pixels
		or.w	d5,44(a2)	;in colour 7 (3 bitplanes)
		or.w	d5,88(a2)	;and on 2 raster lines
		or.w	d5,132(a2)
		or.w	d5,176(a2)
		or.w	d5,220(a2)

PDTH_8		move.w	d2,d5		;horizdata
		lsr.w	#8,d5		;get offset addon
		add.b	d5,d2		;new offset total

		move.b	d2,d5		;check total
		and.b	#$F0,d5		;less than 16?
		beq.s	PDTH_5		;skip if so
		subq.w	#2,d1		;else memory offset to left
		and.w	#$0F0F,d2	;and constrain to limits

PDTH_5		move.w	d1,(a3)+		;save new offset total
		move.w	d2,(a3)+		;and new horizdata

		bra.s	PDTH_3		;skip now all's done


* Here, we've got an odd-numbered entry. The shift value is to
* the RIGHT.


PDTH_2		moveq	#0,d3
		move.b	d2,d3		;horiz. offset total
		beq.s	PDTH_6		;zero-no shift
		ror.w	d3,d5		;rotate the pixels

PDTH_6		cmp.l	d6,a2		;ptr too small?
		bcs.s	PDTH_9		;don't plot if so
		cmp.l	d7,a2		;ptr too high?
		bcc.s	PDTH_9		;don't plot if so

		or.w	d5,(a2)		;plot pixels
		or.w	d5,44(a2)	;in colour 7 (3 bitplanes)
		or.w	d5,88(a2)	;and on 2 raster lines
		or.w	d5,132(a2)
		or.w	d5,176(a2)
		or.w	d5,220(a2)

PDTH_9		move.w	d2,d5		;horizdata
		lsr.w	#8,d5		;get offset addon
		add.b	d5,d2		;new offset total

		move.b	d2,d5		;check total
		and.b	#$F0,d5		;less than 16?
		beq.s	PDTH_7		;skip if so
		addq.w	#2,d1		;else memory offset to right
		and.w	#$0F0F,d2	;and constrain to limits

PDTH_7		move.w	d1,(a3)+		;save new offset total
		move.w	d2,(a3)+		;and new horizdata

PDTH_3		subq.w	#1,d0		;done them all?
		bne	PDTH_1		;back for more if not

		rts


* ShowScores(a6)
* a6 = ptr to main program variables

* Show player scores.

* d0-d2/d7/a0-a2 corrupt


ShowScores	move.l	Player1Data(a6),a0	;Player 1

		move.l	pd_Score(a0),d0		;get score
		move.l	NumStrBuf(a6),a0		;ptr to buffer
		bsr	LtoA10			;Long Int to ASCII

		bsr	StrLen		;get length
		subq.w	#1,d7
		add.w	d7,d7
		move.l	HorizTabs1(a6),a0	;which horiz tab?
		move.w	0(a0,d7.w),d0	;get it

		move.l	NumStrBuf(a6),a0	;ptr to string
		moveq	#48,d1		;vert pos
		moveq	#1,d2
		bsr	BlitPString	;print it

		move.l	Player2Data(a6),a0

		move.l	pd_Score(a0),d0		;get score
		move.l	NumStrBuf(a6),a0		;ptr to buffer
		bsr	LtoA10			;Long Int to ASCII

		bsr	StrLen		;get length
		subq.w	#1,d7
		add.w	d7,d7
		move.l	HorizTabs2(a6),a0	;which horiz tab?
		move.w	0(a0,d7.w),d0	;get it

		move.l	NumStrBuf(a6),a0	;ptr to string
		moveq	#48,d1		;vert pos
		moveq	#1,d2
		bsr	BlitPString	;print it

		rts


* ShowLives(a6)
* a6 = ptr to main program variables

* Show lives & smart bombs.

* d0-d3/a0-a2 corrupt


ShowLives	move.l	Player1Data(a6),a0	;player 1

		move.w	pd_Lives(a0),d0		;how many lives?
		beq.s	SHL_1			;skip if none left

		move.l	HorizTabs3(a6),a1	;ptr to tab table

SHL_L1		move.w	d0,-(sp)		;save counter
		move.w	(a1)+,d2		;get tab value
		bne.s	SHL_B1		;continue if it exists
		move.w	(sp)+,d0		;else tidy stack
		bra.s	SHL_1		;and leave the loop

SHL_B1		move.l	a1,-(sp)		;save updated pointer
		moveq	#20,d3		;vertical value
		moveq	#8*3,d0		;lines deep
		moveq	#1,d1		;words across
		move.l	ShipImage(a6),a0	;image to display
		move.l	ShipMask(a6),a1	;mask to use

		move.l	RasterWaiting(a6),a2

		bsr	BlitLogoCC	;show it

		move.l	(sp)+,a1		;can't use movem!
		move.w	(sp)+,d0		;get counter
		subq.w	#1,d0		;done them all?
		bne.s	SHL_L1		;back for more if not

SHL_1		move.l	Player1Data(a6),a0
		move.w	pd_SBombs(a0),d0	;no. of smart bombs

		moveq	#4,d1		;loop counter
		moveq	#0,d2		;initial HorizTab entry

SHL_L2		movem.w	d0-d2,-(sp)	;save these

		move.l	HorizTabs3(a6),a0	;ptr to tab table
		add.w	d2,d2
		lea	0(a0,d2.w),a0	;ptr to entry
		move.w	(a0),d2		;get entry
		moveq	#40,d3		;vertical pos
		move.l	SBGraf(a6),a0	;actual SB graphic
		move.l	SBZero(a6),a1	;blank SB
		tst.w	d0		;done all SBs?
		bne.s	SHL_B2		;skip if not
		move.l	a1,a0		;else use blank graphics
SHL_B2		move.l	SBMask(a6),a1	;mask
		moveq	#7*3,d0		;lines deep
		moveq	#1,d1		;words across

		move.l	RasterWaiting(a6),a2

		bsr	BlitLogoCC	;show smart bomb

		movem.w	(sp)+,d0-d2
		addq.w	#1,d2		;next horiztab entry
		tst.w	d0		;any more smart bombs?
		beq.s	SHL_B3		;skip if not
		subq.w	#1,d0		;dec smart bomb count
SHL_B3		subq.w	#1,d1		;done all display entries?
		bne.s	SHL_L2		;back for more if not

SHL_2		move.l	Player2Data(a6),a0	;player 1

		move.w	pd_Lives(a0),d0		;how many lives?
		beq.s	SHL_3			;skip if none left

		move.l	HorizTabs4(a6),a1	;ptr to tab table

SHL_L3		move.w	d0,-(sp)		;save counter
		move.w	(a1)+,d2		;get tab value
		bne.s	SHL_B4		;continue if it exists
		move.w	(sp)+,d0		;else tidy stack
		bra.s	SHL_3		;and leave the loop

SHL_B4		move.l	a1,-(sp)		;save updated pointer
		moveq	#20,d3		;vertical value
		moveq	#8*3,d0		;lines deep
		moveq	#1,d1		;words across
		move.l	ShipImage(a6),a0	;image to display
		move.l	ShipMask(a6),a1	;mask to use

		move.l	RasterWaiting(a6),a2

		bsr	BlitLogoCC	;show it

		move.l	(sp)+,a1		;can't use movem!
		move.w	(sp)+,d0		;get counter
		subq.w	#1,d0		;done them all?
		bne.s	SHL_L3		;back for more if not

SHL_3		move.l	Player2Data(a6),a0
		move.w	pd_SBombs(a0),d0	;no. of smart bombs

		moveq	#4,d1		;loop counter
		moveq	#0,d2		;initial HorizTab entry

SHL_L4		movem.w	d0-d2,-(sp)	;save these

		move.l	HorizTabs4(a6),a0	;ptr to tab table
		add.w	d2,d2
		lea	0(a0,d2.w),a0	;ptr to entry
		move.w	(a0),d2		;get entry
		moveq	#40,d3		;vertical pos
		move.l	SBGraf(a6),a0	;actual SB graphic
		move.l	SBZero(a6),a1	;blank
		tst.w	d0		;done all SBs?
		bne.s	SHL_B5		;skip if not
		move.l	a1,a0		;else use blank graphics
SHL_B5		move.l	SBMask(a6),a1	;mask
		moveq	#7*3,d0		;lines deep
		moveq	#1,d1		;words across

		move.l	RasterWaiting(a6),a2

		bsr	BlitLogoCC	;show smart bomb

		movem.w	(sp)+,d0-d2
		addq.w	#1,d2		;next horiztab entry
		tst.w	d0		;any more smart bombs?
		beq.s	SHL_B6		;skip if not
		subq.w	#1,d0		;dec smart bomb count
SHL_B6		subq.w	#1,d1		;done all display entries?
		bne.s	SHL_L4		;back for more if not

SHL_4		rts


* BlitLogo(a0,a1,d0,d1,d2,d3)

* a0 = ptr to logo to blit
* a1 = ptr to screen to blit to
* d0 = no of lines
* d1 = width in WORDS
* d2 = x position
* d3 = y position

* Do a basic D=A blit of logos onto the screen at the specified positions.
* NOTE : lines deep MUST be (lines for 1 bitplane) * (no of bitplanes)
* for a 3-bitplane blit to the interleaved screen!

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


* BlitLogoCC(a0,a1,a2,d0,d1,d2,d3)
* a0 = ptr to image
* a1 = ptr to mask
* a2 = ptr to screen to write to
* d0 = lines deep
* d1 = WORDS wide
* d2 = x position
* d3 = y position

* Performs a cookie-cut blit (hence 'CC' designation) of a logo.

* d0-d7/a2-a3 corrupt

BlitLogoCC	btst	#6,DMACONR(a5)		;busy wait (sigh)

BLCC_W		btst	#6,DMACONR(a5)
		bne.s	BLCC_W

		addq.l	#2,a2		;overwide screen correction

		moveq	#0,d4
		move.w	d3,d4
		move.l	YTable(a6),a3	;use y-table lookup-
		add.w	d4,d4		;far faster than a
		move.w	0(a3,d4.w),d4	;multiply
		add.l	d4,a2		;add to screen base
		moveq	#0,d4
		move.w	d2,d4
		ext.l	d4
		asr.l	#4,d4		;compute x offset
		add.l	d4,d4
		add.l	d4,a2		;1st screen loc

		and.w	#$F,d2
		ror.w	#4,d2		;make BLTCON0
		move.w	d2,d4
		or.w	#$0FCA,d2	;USEA-D, D = AB + aC
		swap	d2
		move.w	d4,d2		;BLTCON1

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
		move.l	a0,BLTBPTH(a5)	;blitter...
		move.l	a1,BLTAPTH(a5)	;blitter...
		move.l	a2,BLTCPTH(a5)
		move.l	a2,BLTDPTH(a5)
		move.w	d4,BLTDMOD(a5)
		move.w	d4,BLTCMOD(a5)
		move.w	d5,BLTAMOD(a5)
		move.w	d5,BLTBMOD(a5)
		move.w	d6,BLTSIZE(a5)

		rts


* AlienObject SpecialCodes go here.

* VERY IMPORTANT:ALL of these routines MUST PRESERVE A0!

* Also, the COMPLETE operational SpecialCodes will be in two parts:
* an initialiser for the alien, and a controller to be linked in
* once initialisation is completed.

* One SpecialCode being added is for Bodies. If captured by lander,
* they rise with it. If lander hits top & Body snatch complete,
* body dies. If lander killed while carrying snatched body, then
* Body falls to Earth. If Body hits ground too hard, Body dies,
* else Body lives.


		include Source:D_Edwards/Includes/Defender2.i


* MakeBomberList(a6)
* a6 = ptr to main program variables

* Create curve along which bombers are to fly. Uses the fast trig function
* TrigValues() below. Computes the following:

* y = A sin(x) + B sin(2x) + C sin(3x)

* where A, B, C are randomly chosen. Result normalised to create a
* curve that fits within the screen region within which the Bombers
* are to move. Saves digitised 

* A, B and C are random numbers between 0 and 15 inclusive.

* To scale the curve to occupy the entire screen, we perform the
* following:

* D = H - (A+B+C) (where H = half the play area height)

* A = A + D/2

* B = B + D/3

* C = C + D/6

* before computing the values of y

* d0-d4/a0-a1 corrupt


MakeBomberList	bsr	Random			;Random number!
		move.l	Seed(a6),d0
		swap	d0
		and.w	#$F,d0
		move.w	d0,BLConst1(a6)		;create A
		swap	d0
		and.w	#$F,d0
		move.w	d0,BLConst2(a6)		;create B
		bsr	Random
		move.l	Seed(a6),d0
		and.w	#$F,d0
		move.w	d0,BLConst3(a6)		;create C

		add.w	BLConst2(a6),d0
		add.w	BLConst1(a6),d0		;A+B+C

		moveq	#0,d1
		move.w	#HRNG_SY,d1
		sub.w	d0,d1		;D = H - (A+B+C)
		moveq	#0,d0
		move.w	d1,d0
		lsr.w	#1,d0
		add.w	d0,BLConst1(a6)	;A = A + D/2

		moveq	#0,d0
		move.w	d1,d0
		divu	#3,d0
		add.w	d0,BLConst2(a6)	;B = B + D/3
		lsr.w	#1,d0
		add.w	d0,BLConst3(a6)	;C = C + D/6


* For debug, use A = H, B = C = 0


;		moveq	#HRNG_SY,d0
;		move.w	d0,BLConst1(a6)
;		moveq	#0,d0
;		move.w	d0,BLConst2(a6)
;		move.w	d0,BLConst3(a6)

		move.l	BomberList(a6),a1		;point to list

		moveq	#0,d2			;initial angle
		move.w	#_CURVECOUNT,d2		;no of entries


* Note:use of SWAP to save angle in upper half of D2, loop counter in
* lower half of D2. Beginner's corner stuff!


MBL_L1		swap	d2		;save loop counter, get angle
		move.w	d2,d0		;counter=angle x
		bsr	TrigValues	;compute sin(x) etc
		move.w	BLConst1(a6),d1	;A
		moveq	#0,d3		;dest for A sin(x)
		bra.s	MBL_A2		;take account of A=0!

MBL_L2		add.l	d0,d3		;compute A sin(x)
MBL_A2		dbra	d1,MBL_L2	;back if not finished

		move.l	d3,d4		;total

		move.w	d2,d0		;counter * 2
		add.w	d0,d0		;= angle x
		bsr	TrigValues	;compute sin(2x)
		move.w	BLConst2(a6),d1	;B
		moveq	#0,d3		;dest for B sin(2x)
		bra.s	MBL_A3		;take account of B=0!

MBL_L3		add.l	d0,d3		;compute B sin(2x)
MBL_A3		dbra	d1,MBL_L3	;back if not finished

		add.l	d3,d4		;total

		move.w	d2,d0		;counter * 3
		add.w	d0,d0
		add.w	d2,d0		;= angle x
		bsr	TrigValues	;compute sin(3x)
		move.w	BLConst3(a6),d1	;C
		moveq	#0,d3		;dest for C sin(3x)
		bra.s	MBL_A4		;take account of C=0!

MBL_L4		add.l	d0,d3		;compute C sin(3x)
MBL_A4		dbra	d1,MBL_L4	;back if not finished

		add.l	d3,d4		;A sin(x)+B sin(2x)+C sin(3x)
		swap	d4		;get int part of result

		add.w	#ORG_SY,d4	;curve point created!

		move.w	d4,(a1)+		;save Y position in curve
		addq.w	#1,d2		;next angle
		swap	d2		;get loop counter
		subq.w	#1,d2		;done all entries?
		bne.s	MBL_L1		;back for more if not

		rts


* NOTES:

* SAF = Standard Angle Format. 1 unit of SAF = 360/512 deg.
* Hence: $000 = 0 deg, $080 = 90 deg $100 = 180 deg, $180 = 270 deg.
* Stored as WORD.

* SCF = Standard Coordinate Format. Stored as LONGWORD.
* upper word = integer part, lower word = fractional part.


* TrigValues(d0) -> d0,d1
* d0 = angle in SAF
* Compute sin(X) and cos(X) in one go

* Needs pointers to sine tables in the main variable table
* off register A6.

* NOTE : The sine tables I'm using are values of 32768*sin(x).
* I need 65536*sin(x), but to maintain word sized table entries
* I'll multiply the fractional entries by 2 in the code to cre-
* ate the required values.

* Returns:

* d0 = sin(X), d1=cos(X) in SCF

* a0 corrupt


TrigValues	moveq	#0,d1
		move.w	d0,d1		;copy angle x1
		move.l	d1,d0		;ensure SCF int part clear
		and.w	#$7F,d1		;is it a multiple of 90 deg?
		bne.s	TVL_1		;skip if not

		lsr.w	#7,d0		;get no of 90 deg's
		move.w	d0,d1		;copy this
		addq.w	#1,d1		;x2 = x1 + 90 deg
		and.w	#3,d0		;constrain angles to
		and.w	#3,d1		;0-360 deg range

		move.l	SineVal2(a6),a0	;integer sine table

		add.w	d0,d0
		move.w	0(a0,d0.w),d0	;get sin(x)
		add.w	d1,d1
		move.w	0(a0,d1.w),d1	;get cos(x)

		swap	d0		;convert to SCF
		swap	d1
		rts

TVL_1		move.w	d0,d1		;copy angle x1
		add.w	#$80,d1		;x2 = x1 + 90 deg
		and.w	#$1FF,d0		;constrain angles to
		and.w	#$1FF,d1		;0-360 deg range

		move.l	SineVal1(a6),a0	;fractional sine table
TVL_2		add.w	d0,d0
		move.w	0(a0,d0.w),d0	;get sin(x)
		add.w	d1,d1
		move.w	0(a0,d1.w),d1	;get cos(x)

		ext.l	d0
		ext.l	d1

		add.l	d0,d0
		add.l	d1,d1

		rts


* DetonateSB(a6)
* a6 = ptr to main program variables
* detonate the smart bomb & start killing things off.

* Note:SBLock variable introduced to stop bug whereby
* holding down smart bomb key set the lot off. Also it
* checks for one already set off, and if the player
* has any left. Basically, detonate ONLY IF:

* 1) correct key pressed;
* 2) not locked (i.e., key released after last press);
* 3) last smart bomb has finished detonating;
* 4) player has any left to set off.

* d0 corrupt


DetonateSB	move.l	SBKeyPtr(a6),a0		;get which key/stick
		move.b	(a0),d0			;get var value
		and.b	SBKeyMsk(a6),d0		;ensure var masked!
		cmp.b	SBKeyVal(a6),d0		;correct one?
		beq.s	DSB_1			;skip if so

		clr.b	SBLock(a6)	;don't clear unless key let go!

		rts			;else waste no more time

DSB_1		tst.b	SBLock(a6)	;smart bomb locked?
		beq.s	DSB_2		;skip if not
		rts

DSB_2		tst.w	SBCount(a6)	;one still going off?
		beq.s	DSB_3		;skip if not
		rts			;else exit

DSB_3		move.l	CurrentPlayer(a6),a0	;check this player
		move.w	pd_SBombs(a0),d0		;got any left?
		bne.s	DSB_4			;skip if so
		rts				;else done

DSB_4		st	SBLock(a6)	;lock out key hold-down
		subq.w	#1,d0		;smart bombs - 1
		move.w	d0,pd_SBombs(a0)	;save new amount

		move.w	CollCount(a6),d0
		move.w	d0,SBCount(a6)

		rts


* SmartBomb(a6)
* a6 = ptr to main program variables

* Kill off all things currently on screen using the smart bomb.
* Now corrected so that Bodies aren't killed, AND it now allows
* Pods to be cracked open in classic Defender fashion by extend-
* ing the Smart bomb's lethal duration if a Pod is split.

* d0-d4/a0-a1 corrupt


SmartBomb	move.w	SBCount(a6),d0	;get countdown
		bne.s	SBM_1		;still killing!
		rts			;else bye-bye

SBM_1		subq.w	#1,d0
		move.w	d0,SBCount(a6)

		move.l	CollisionList(a6),a0


* Below are some constants. Keep in registers for speed.


		move.b	#_AOF_HIT,d0	;hit flag value
		moveq	#_AL_BODY,d2	;Body ID value
		moveq	#_AL_POD,d3	;Pod ID value
		moveq	#_ANF_DISABLED,d4	;disabled Anim flag value


* Now check if we're destroying any Aliens.


SBM_2		move.l	(a0)+,d1		;get alien ptr
		beq.s	SBM_3		;no more-leave
		move.l	d1,a1		;get pointer to alien
		move.b	AO_Flags(a1),d1	;check if already hit
		and.b	d0,d1		;already hit?
		bne.s	SBM_2		;back for next if so
		move.b	Anim_Flags(a1),d1	;now check if dead
		and.b	d4,d1		;dead?
		bne.s	SBM_2		;back for next if so
		move.w	Anim_ID(a1),d1	;get ojbect ID
		cmp.w	d2,d1		;Body object?
		bls.s	SBM_2		;don't destroy if so
		cmp.w	d3,d1		;Pod object?
		bne.s	SBM_4		;skip if not
		move.w	Seed(a6),d1	;else get random number
		and.w	#$07,d1		;limit value
		add.w	d1,SBCount(a6)	;& make smart bomb last longer
SBM_4		or.b	d0,AO_Flags(a1)	;signal alien hit
		bra.s	SBM_2		;and back for more

SBM_3		rts


		include Source:D_Edwards/Includes/Defender1.i


* ClearScanner(a6)
* a6 = ptr to main program variables
* Wipe the scanner clean.

* d0-d2/a0-a1 corrupt


ClearScanner	lea	SpritePtrs(a6),a0	;ptr to sprite ptrs
		moveq	#6,d2		;no. of sprites

CSC_1		move.l	(a0)+,a1		;ptr to sprite area
		addq.l	#4,a1		;point past ctrl words
		moveq	#0,d0		;clear value
		moveq	#SPRHGT,d1	;no of longwords

CSC_2		move.l	d0,(a1)+		;clear scanner column
		subq.w	#1,d1		;done it all?
		bne.s	CSC_2		;back for more if not

		subq.w	#1,d2		;done all sprites?
		bne.s	CSC_1		;back for more if not
		rts			;done!


* InitScanner(a6)
* a6 = ptr to main program variables

* Set up the area for the sprites to be used by the
* scanner, including control words. Then set the sprite
* data pointers up.

* d0-d3/a0-a3 corrupt


InitScanner	move.l	ScanArea(a6),a0	;ptr to scanner area
		move.l	a0,a1

		move.w	#240,d0		;initial X position
		swap	d0
		move.w	#66,d0		;initial Y position
		moveq	#SPRHGT,d1	;sprite height

		movem.l	d0-d1,-(sp)
		bsr	MakeSprCTL	;make control words
		movem.l	(sp)+,d0-d1
		movem.w	d2-d3,(a1)	;and insert them
		add.w	#SPRSIZB,a1
		clr.l	-4(a1)		;end control words

		swap	d0
		add.w	#16,d0		;next sprite:x+16
		swap	d0
		movem.l	d0-d1,-(sp)
		bsr	MakeSprCTL
		movem.l	(sp)+,d0-d1
		movem.w	d2-d3,(a1)	;repeat procedure...
		add.w	#SPRSIZB,a1
		clr.l	-4(a1)

		swap	d0
		add.w	#16,d0		;next sprite:x+32
		swap	d0
		movem.l	d0-d1,-(sp)
		bsr	MakeSprCTL
		movem.l	(sp)+,d0-d1
		movem.w	d2-d3,(a1)	;repeat procedure...
		add.w	#SPRSIZB,a1
		clr.l	-4(a1)

		swap	d0
		add.w	#16,d0		;next sprite:x+48
		swap	d0
		movem.l	d0-d1,-(sp)
		bsr	MakeSprCTL
		movem.l	(sp)+,d0-d1
		movem.w	d2-d3,(a1)	;repeat procedure...
		add.w	#SPRSIZB,a1
		clr.l	-4(a1)

		swap	d0
		add.w	#16,d0		;next sprite:x+64
		swap	d0
		movem.l	d0-d1,-(sp)
		bsr	MakeSprCTL
		movem.l	(sp)+,d0-d1
		movem.w	d2-d3,(a1)	;repeat procedure...
		add.w	#SPRSIZB,a1
		clr.l	-4(a1)

		swap	d0
		add.w	#16,d0		;next sprite:x+80
		swap	d0
		movem.l	d0-d1,-(sp)
		bsr	MakeSprCTL
		movem.l	(sp)+,d0-d1
		movem.w	d2-d3,(a1)	;final set
		add.w	#SPRSIZB,a1
		clr.l	-4(a1)


* Now, set up the sprite pointers.


		lea	SpritePtrs(a6),a1
		move.l	a0,a2

		move.l	a2,(a1)+		;sprite 0 ptr
		add.w	#SPRSIZB,a2
		move.l	a2,(a1)+		;sprite 1 ptr
		add.w	#SPRSIZB,a2
		move.l	a2,(a1)+		;sprite 2 ptr
		add.w	#SPRSIZB,a2
		move.l	a2,(a1)+		;sprite 3 ptr
		add.w	#SPRSIZB,a2
		move.l	a2,(a1)+		;sprite 4 ptr
		add.w	#SPRSIZB,a2
		move.l	a2,(a1)+		;sprite 5 ptr


* Now transfer them to the ScanPosList...


		lea	SpritePtrs(a6),a1
		move.l	ScanPosList(a6),a0

		move.l	(a1)+,d0
		addq.l	#4,d0
		move.l	d0,(a0)+		;Instead of storing ptr to
		move.l	(a1)+,d0		;sprite proper, store ptr
		addq.l	#4,d0		;to the actual sprite graphic
		move.l	d0,(a0)+		;data in each case-reduces
		move.l	(a1)+,d0		;tedious mucking about!
		addq.l	#4,d0
		move.l	d0,(a0)+
		move.l	(a1)+,d0
		addq.l	#4,d0
		move.l	d0,(a0)+
		move.l	(a1)+,d0
		addq.l	#4,d0
		move.l	d0,(a0)+
		move.l	(a1)+,d0
		addq.l	#4,d0
		move.l	d0,(a0)+


* Now zero out the sprite image areas.


		lea	SpritePtrs(a6),a1

		move.l	(a1)+,a0
		moveq	#SPRHGT,d0
		bsr	ZeroSpriteImg

		move.l	(a1)+,a0
		moveq	#SPRHGT,d0
		bsr	ZeroSpriteImg

		move.l	(a1)+,a0
		moveq	#SPRHGT,d0
		bsr	ZeroSpriteImg

		move.l	(a1)+,a0
		moveq	#SPRHGT,d0
		bsr	ZeroSpriteImg

		move.l	(a1)+,a0
		moveq	#SPRHGT,d0
		bsr	ZeroSpriteImg

		move.l	(a1)+,a0
		moveq	#SPRHGT,d0
		bsr	ZeroSpriteImg

		rts


* Scanner(a6)
* a6 = ptr to main program variables

* Display the scanner.

* d0-d7/a0-a1/a3 corrupt


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


* MakeSprCTL(d0,d1) -> d2,d3

* d0 = (ULONG) x & y positions in order X|Y (X high word, Y low word)
* d1 = (UWORD) sprite height

* Create sprite control words from the supplied data. CTL0 = sprite
* control word 0, CTL1 = sprite control word 1.

* CTL0	=	E7 E6 E5 E4 E3 E2 E1 E0 H8 H7 H6 H5 H4 H3 H2 H1

* CTL1	=	L7 L6 L5 L4 L3 L2 L1 L0 AT 0  0  0  0  E8 L8 H0

* Returns CTL0 in d2, CTL1 in d3.

* d1 corrupt


MakeSprCTL	moveq	#0,d2	;1st control word
		moveq	#0,d3	;2nd control word

		add.w	d0,d1	;create L8-L0 bits
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


* ZeroSpriteImg(a0,d0)
* a0 = ptr to sprite image to clear
* d0 = height of sprite

* Clear sprite image data area. DO NOT AFFECT CONTROL WORDS
* OR SPRITE TERMINATORS!

* d0-d1/a0 corrupt


ZeroSpriteImg	addq.l	#4,a0	;point past control words
;		moveq	#-1,d1	;zero value
		moveq	#0,d1	;zero value
		clr.w	d1
ZSI_L1		move.l	d1,(a0)+	;clear image area
		subq.w	#1,d0	;done it?
		bne.s	ZSI_L1	;back if not
		rts


* SetSprites(a6)
* a6 = ptr to main program variables

* Set sprite pointers into copper list for INACTIVE screen.
* Call twice at the beginning of the main game screen ONLY!

* Only does 6 sprites because I'm only using 6 for the moment.

* d0/a0-a1 corrupt


SetSprites	move.l	CopWaiting(a6),a0	;ptr to INACTIVE copperlist
		lea	SpritePtrs(a6),a1	;ptr to sprite ptrs

		move.l	(a1)+,d0		;get sprite ptr
		swap	d0		;get high word
		move.w	d0,2(a0)		;insert into copperlist
		swap	d0		;get low word
		move.w	d0,6(a0)		;insert into copperlist
		addq.l	#8,a0		;sprite 0 done-next one

		move.l	(a1)+,d0
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0		;sprite 1 done

		move.l	(a1)+,d0
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0		;sprite 2 done

		move.l	(a1)+,d0
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0		;sprite 3 done

		move.l	(a1)+,d0
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0		;sprite 4 done

		move.l	(a1)+,d0
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0		;sprite 5 done

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


* WaitKey(d0)
* d0 = key to wait for

* Wait for key to be pressed AND THEN RELEASED.

* Nothing corrupt


WaitKey		cmp.b	OrdKey(a6),d0	;key pressed?
		bne.s	WaitKey		;wait until it it
WaitKey1		cmp.b	#$FF,OrdKey(a6)	;key released?
		bne.s	WaitKey1		;wait until it is
		rts


* GetAKey(a6) -> d0
* a6 = ptr to main program variables
* get key press, convert to ASCII char using my table,
* and then return the ASCII code in d0.
* If no key pressed, then $FF returned in d0.
* Some keys also mapped to $FF!

* d1/a0 corrupt


GetAKey		move.b	OrdKey(a6),d0	;check key press
		cmp.b	#$FF,d0		;got a key press?
		beq.s	GAK_2		;exit if not

GAK_3		cmp.b	#$FF,OrdKey(a6)	;wait for key to be
		bne.s	GAK_3		;released

		move.l	MyKeyMap(a6),a0	;rawkey to ASCII table
		and.w	#$7F,d0
		move.b	0(a0,d0.w),d0	;get ASCII code
		move.l	KBBufPtr(a6),a0	;keyboard type-ahead buffer
		move.w	KBBufPos(a6),d1
		move.b	d0,0(a0,d1.w)	;store in buffer
		cmp.b	#$0D,d0		;return/enter key?
		beq.s	GAK_1		;skip if so
		addq.w	#1,d1
		and.w	#$3F,d1		;update buffer pos
		move.w	d1,KBBufPos(a6)

		rts

GAK_1		clr.b	0(a0,d1.w)	;append EOS to buffer
		moveq	#0,d1
		move.w	d1,KBBufPos(a6)	;reset key buffer

GAK_2		rts


* CheckPW(a6)
* a6 = ptr to main program variables

* Check if a cheat password is entered during the title
* screen sequence...

* d0/a0-a1 corrupt


CheckPW		move.l	PWList(a6),a0	;password list
		moveq	#1,d0		;password number

CPW_1		cmp.b	#$FF,(a0)	;last password?
		beq.s	CPW_6		;exit if so

CPW_2		move.l	KBBufPtr(a6),a1	;get keyboard buffer ptr

CPW_3		tst.b	(a0)		;passwords match?
		beq.s	CPW_4		;skip if so
		cmp.b	(a0)+,(a1)+	;this character matches?
		beq.s	CPW_3		;back for next if so

CPW_5		tst.b	(a0)+		;look for next password
		bne.s	CPW_5
		addq.w	#1,d0		;next password number
		bra.s	CPW_1		;and try again

CPW_4		and.w	#3,d0
		add.w	d0,d0
		lea	__PWColours,a0
		move.w	0(a0,d0.w),d0
		move.w	d0,COLOR00(a5)

CPW_6		rts


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

* NOTE:SB2 entry point for the RasterWaiting versions!


ShowByte		move.l	RasterActive(a6),a0
SB2		moveq	#NPLANES,d3		;no of bitplanes
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


* ShowByteR(d0,d1,d2)


ShowByteR	move.l	RasterWaiting(a6),a0
		bra	SB2


* ShowWordR(d0,d1,d2)


ShowWordR	move.w	d0,-(sp)		;save word
		lsr.w	#8,d0		;get high byte
		bsr.s	ShowByteR	;show it
		addq.w	#2,d1		;move 2 chars right
		move.w	(sp)+,d0		;recover word
		bsr.s	ShowByteR	;show low byte
		rts


* ShowLongR(d0,d1,d2)


ShowLongR	move.l	d0,-(sp)		;save longword
		swap	d0		;get high word
		bsr.s	ShowWordR	;show it
		addq.w	#2,d1		;move 2 chars right
		move.l	(sp)+,d0		;recover longword
		bsr.s	ShowWordR	;show low word
		rts


* Palette : black, white, red, yellow, green, cyan, blue, magenta


Palette:

		dc.w	$0000,$0FFF,$0D00,$0FD0
		dc.w	$00B0,$00CC,$024C,$0D2D
		dc.w	$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000

		dc.w	$0000,$0FFF,$00F0,$0F00
		dc.w	$0000,$0FFF,$00F0,$0F00
		dc.w	$0000,$0FFF,$00F0,$0F00
		dc.w	$0000,$0FFF,$00F0,$0F00


* Library names (actually just one)...


graf_name	dc.b	"graphics.library",0
		even


* Here put data includes. Ensure that graphics data, sound data
* etc., goes into CHIP RAM!

* Note : .blit = graphic, .bmsk = mask data

* Next note:graphics all piled into huge 'graphics.bin' file to save
* disc space. Note how the offsets are compiled in each case!


* CHIP RAM data


		section	CUSTOM,DATA_C


ASB1_Z		ds.w	7*3			;blank sbomb!

_Graphics	incbin	Source:D_Edwards/INCLUDES/newgraphics.bin

AAMF_G		equ	_Graphics

AAMF_M		equ	AAMF_G+42

AAMR_G		equ	AAMF_M+42

AAMR_M		equ	AAMR_G+42

POWG1		equ	AAMR_M+42

POWG2		equ	POWG1+42

POWG3		equ	POWG2+42

POWG4		equ	POWG3+42

POWM		equ	POWG4+42

A1F1_G		equ	POWM+42

A2F1_G		equ	A1F1_G+66

A3F1_G		equ	A2F1_G+72

A4F1_G		equ	A3F1_G+42

A5F1_G		equ	A4F1_G+18

A6F1_G		equ	A5F1_G+30

A7F1_G		equ	A6F1_G+66

ASF1_G		equ	A7F1_G+54

ASF2_G		equ	ASF1_G+48

ASF3_G		equ	ASF2_G+48

ASR1_G		equ	ASF3_G+48

ASR2_G		equ	ASR1_G+48

ASR3_G		equ	ASR2_G+48

AFF1_G		equ	ASR3_G+48

AFF2_G		equ	AFF1_G+18

AFR1_G		equ	AFF2_G+30

AFR2_G		equ	AFR1_G+18

ASB1_G		equ	AFR2_G+30

;ASB1_Z		ds.w	7*3			;blank sbomb!


A1F1_M		equ	ASB1_G+42

A2F1_M		equ	A1F1_M+66

A3F1_M		equ	A2F1_M+72

A4F1_M		equ	A3F1_M+42

A5F1_M		equ	A4F1_M+18

A6F1_M		equ	A5F1_M+30

A7F1_M		equ	A6F1_M+66

ASF_M		equ	A7F1_M+54

ASR_M		equ	ASF_M+48

AFF1_M		equ	ASR_M+48

AFF2_M		equ	AFF1_M+18

AFR1_M		equ	AFF2_M+30

AFR2_M		equ	AFR1_M+18

ASB1_M		equ	AFR2_M+30


* 'Explosion' graphics go here


XPL1_1G		equ	ASB1_M+42

XPL1_2G		equ	XPL1_1G+66

XPL1_3G		equ	XPL1_2G+54

XPL1_4G		equ	XPL1_3G+42

XPL1_5G		equ	XPL1_4G+30

XPL2_1G		equ	XPL1_5G+18

XPL2_2G		equ	XPL2_1G+66

XPL2_3G		equ	XPL2_2G+54

XPL2_4G		equ	XPL2_3G+42

XPL2_5G		equ	XPL2_4G+30

XPL3_1G		equ	XPL2_5G+18

XPL3_2G		equ	XPL3_1G+42

XPL3_3G		equ	XPL3_2G+42

XPL3_4G		equ	XPL3_3G+42

XPL3_5G		equ	XPL3_4G+42

XPL4_1G		equ	XPL3_5G+42

XPL4_2G		equ	XPL4_1G+30

XPL4_3G		equ	XPL4_2G+42

XPL4_4G		equ	XPL4_3G+6

XPL5_1G		equ	XPL4_4G+6

XPL5_2G		equ	XPL5_1G+30

XPL5_3G		equ	XPL5_2G+30

XPL5_4G		equ	XPL5_3G+30


XPL1_1M		equ	XPL5_4G+30

XPL1_2M		equ	XPL1_1M+66

XPL1_3M		equ	XPL1_2M+54

XPL1_4M		equ	XPL1_3M+42

XPL1_5M		equ	XPL1_4M+30

XPL2_1M		equ	XPL1_5M+18

XPL2_2M		equ	XPL2_1M+66

XPL2_3M		equ	XPL2_2M+54

XPL2_4M		equ	XPL2_3M+42

XPL2_5M		equ	XPL2_4M+30

XPL3_4M		equ	XPL2_5M+18

XPL3_5M		equ	XPL3_4M+42

XPL4_1M		equ	XPL3_5M+42

XPL4_2M		equ	XPL4_1M+30

XPL4_3M		equ	XPL4_2M+42

XPL4_4M		equ	XPL4_3M+6


* Landscape graphics go here


LAND1		equ	XPL4_4M+6

LAND2		equ	LAND1+6

LAND3		equ	LAND2+96


* Logos & other stuff go here


Logo1		equ	LAND3+96

Logo2		equ	Logo1+2160

Logo3		equ	Logo2+2088

Logo4		equ	Logo3+1890

ScannerImg	equ	Logo4+3870

NewCSet		equ	ScannerImg+7320

		dc.w	0	;safety for DESC mode Laurence blit

CBBuf		ds.w	32	;char blit buffer


* Mine/Missile Graphics (don't need to be here because they're
* put on by the 68000, not the blitter!).


_MineImg1	dc.l	$40000000
		dc.l	$E0000000
		dc.l	$40000000

_MineImg2	dc.l	$A0000000
		dc.l	$40000000
		dc.l	$A0000000

_MineBuf		dc.l	0,0,0


* Scanner data for sprites


_NulSpr		dc.w	0,0		;null sprite

_ScanData	ds.w	SPRSIZW*NUMSPR

		dc.w	0,0


* "Don't Care Where" data


		section	STRUCTS,DATA


		include Source:D_Edwards/Includes/Defender3.i




