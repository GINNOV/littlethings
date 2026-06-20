


		opt	d+


		include	source:include/hardware.i

		include	source:include/my_exec.i
		include	source:include/my_graf.i


* Variable block. Referenced off A6. A6 MUST be preserved at
* all times other than during library calls!


* Equates. First, AnimLock(a6) values for the interrupt system.


LOCK_DISABLE	equ	0
LOCK_SAVE	equ	1
LOCK_PLOT	equ	2
LOCK_REPLACE	equ	3
LOCK_HOLD	equ	4
LOCK_KILL	equ	-1


* Blitter node types


BT_FREE		equ	0	;free node
BT_PLOT		equ	1	;plot rectangular graphic node
BT_LINE		equ	2	;draw line node
BT_CLEAR		equ	3	;clear memory area
BT_LOCKED	equ	-1	;prevent int routine freeing it


* DMA and interrupt values for various activities.


DMA_SET1		equ	SETIT+DMAEN+BPLEN+COPEN+BLTEN

OLD_DMA		equ	SETIT+DMAEN+BPLEN+COPEN+BLTEN+SPREN+DSKEN

INT_SET1		equ	SETIT+INTEN+VERTB+BLIT+PORTS
INT_SET2		equ	SETIT+COPER

OLD_INT1		equ	INTEN+DSKSYNC+BLIT+VERTB
OLD_INT2		equ	COPER+PORTS+SOFT+DSKBLK
OLD_INT		equ	SETIT+OLD_INT1+OLD_INT2

* Animation flags


* AF_DISABLED	equ	$80	;This anim disabled if set
* AF_REVERSED	equ	$40	;This anim direction reversed


* Screen data


NPLANES		equ	4
BP_WIDE		equ	40	;bytes wide
BP_TALL		equ	256
BP_SIZE		equ	BP_WIDE*BP_TALL
BP_CLR		equ	BP_TALL*64+BP_WIDE/2	;BLTSIZE for Scr Clear


* Main variable block definitions.


		rsreset
graf_base	rs.l	1	;graphics library base

ScrBase		rs.l	1	;start of Alloc'ed screen RAM

CopActive	rs.l	1	;ptrs to each Copper List to use
CopWaiting	rs.l	1

RasterActive	rs.l	NPLANES	;pointers to bitplanes
RasterWaiting	rs.l	NPLANES	;pointers to bitplanes

OldInt3		rs.l	1	;save Exec's int handler ptrs!
OldInt2		rs.l	1	;Expect Guru otherwise...

GFXCopList	rs.l	1	;save this or else...

VBLCounter	rs.l	1	;Counters used by my own
BlitCounter	rs.l	1	;interrupt routines.
CopCounter	rs.l	1
CIACounter	rs.l	1
ScrSwCnt		rs.l	1

AnimLock		rs.w	1	;Animation Lock-VITAL!

AnimList		rs.l	1	;ptr to first Anim
AnimThis		rs.l	1	;ptr to current Anim
AnimRep		rs.l	1	;ptr to 1st Replace Anim
AnimThat		rs.l	1	;ptr to current Replace Anim

AnimComm		rs.w	1	;ID of Anim to communicate to

AnimXV		rs.w	1	;velocity changes to
AnimYV		rs.w	1	;institute

BgndSize		rs.l	1	;amount of memory to reserve for bgnds
BgndArea		rs.l	1	;pointer to said area

WhichPlane	rs.w	1	;current plane no.

IntExit		rs.w	1	;exit INTREQ value for Int3

OrdKey		rs.b	1	;normal key data from int2 handler
ShiftKey		rs.b	1	;shift key data from int2 handler
ScrSwitch	rs.b	1	;screen switch flag (-1=OFF)
Filler		rs.b	1

vars_sizeof	rs.w	0


* Animation structure definitions


		rsreset
Anim_Next	rs.l	1	;ptr to next Anim
Anim_Prev	rs.l	1	;ptr to prev Anim

Anim_Bgnd1	rs.l	1	;ptr to bgnd save area #1
Anim_Bgnd2	rs.l	1	;ptr to bgnd save area #2

Anim_BgSz	rs.l	1	;size of bgnd save area needed

Anim_Bob		rs.l	1	;ptr to 1st Bob struct (below)

Anim_Offset	rs.l	1	;blitter precomp

Anim_XShift	rs.w	1	;blitter precomp

Anim_XPos	rs.w	1	;base x & y coordinates of the
Anim_YPos	rs.w	1	;main Animation object

Anim_XVel	rs.w	1	;base x & y velocities of the
Anim_YVel	rs.w	1	;main Animation object

Anim_FNum	rs.w	1	;Current animation frame no.
Anim_FCnt	rs.w	1	;max no. of Animation frames

Anim_ID		rs.w	1	;ID for alteration within interrupt

Anim_MaxPlanes	rs.b	1	;max no of bitplanes used
Anim_Flags	rs.b	1	;usage flags

Anim_sizeof	rs.w	0


* Bob structure for actual graphics data.


		rsreset
Bob_Next		rs.l	1	;ptr to next Bob
Bob_Prev		rs.l	1	;ptr to previous Bob

Bob_Data		rs.l	1	;ptr to actual graphic data
Bob_Mask		rs.l	1	;ptr to mask to use

Bob_Rows		rs.w	1	;no of raster lines
Bob_Cols		rs.w	1	;no of WORDS across

Bob_XChg		rs.w	1	;position changes for this
Bob_YChg		rs.w	1	;animation frame

Bob_Planes	rs.b	1	;no of planes
Bob_Filler	rs.b	1

Bob_sizeof	rs.w	0


		section	MAIN,CODE


main		move.l	#vars_sizeof,d0	;reserve space for my
		move.l	#MEMF_PUBLIC,d1	;variable block
		CALLEXEC	AllocMem
		tst.l	d0		;got it?
		beq	cock_up_1	;oops-exit NOW!

		move.l	d0,a6		;keep this at ALL times!

		lea	graf_name(pc),a1
		moveq	#0,d0
		CALLEXEC	OpenLibrary	;get graphics library
		move.l	d0,graf_base(a6)	;got her address?
		beq	cock_up_2	;oops...

		lea	RasterActive(a6),a5	;ptr to these vars

		move.l	#BP_SIZE*8,d0	;reserve 8 bitplanes worth
		move.l	#MEMF_CHIP,d1
		CALLEXEC	AllocMem
		move.l	d0,ScrBase(a6)	;got it?
		beq	cock_up_3	;exit if not

		move.l	d0,a0		;ptr to start
		move.w	#BP_SIZE,d0	size of 1 bitplane

		move.l	a0,(a5)+		;save bitplane pointers
		add.w	d0,a0
		move.l	a0,(a5)+		;save bitplane pointers
		add.w	d0,a0
		move.l	a0,(a5)+		;save bitplane pointers
		add.w	d0,a0
		move.l	a0,(a5)+		;save bitplane pointers
		add.w	d0,a0
		move.l	a0,(a5)+		;save bitplane pointers
		add.w	d0,a0
		move.l	a0,(a5)+		;save bitplane pointers
		add.w	d0,a0
		move.l	a0,(a5)+		;save bitplane pointers
		add.w	d0,a0
		move.l	a0,(a5)+		;save bitplane pointers

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

		lea	Anim1,a0		;No PC rel-separate sects

		move.l	a0,AnimList(a6)	;pointers for bgnd save and
		move.l	a0,AnimThis(a6)	;plotting

		move.l	Anim_Prev(a0),a0

		move.l	a0,AnimRep(a6)	;pointers for bgnd replace
		move.l	a0,AnimThat(a6)	;in reverse order

		bsr	ScanAnims	;get bgnd save space size

		move.l	BgndSize(a6),d0
		move.l	#MEMF_CHIP,d1
		CALLEXEC	AllocMem		;get area
		move.l	d0,BgndArea(a6)	;got it?
		beq	cock_up_6	;oops...

		bsr	InitAnims	;now set up Anims

		clr.w	WhichPlane(a6)	;initialise interrupt Anim
whoa		nop			;system

		move.l	graf_base(a6),a0	;ptr to GFXBase struct

		move.l	38(a0),GFXCopList(a6)	;save old Copper List

		move.l	CopActive(a6),a0
		lea	RasterActive(a6),a1	;create 1st of my
		bsr	MakeCopper		;Copper Lists

		move.l	CopWaiting(a6),a0
		lea	RasterWaiting(a6),a1	;create 2nd of my
		bsr	MakeCopper		;Copper Lists

		st	ScrSwitch(a6)	;initial disable screen switch

		st	OrdKey(a6)	;ensure predefined key state
		sf	ShiftKey(a6)	;for normal & shift keys

		moveq	#0,d0
		move.l	d0,BlitCounter(a6)
		move.l	d0,CopCounter(a6)
		move.l	d0,VBLCounter(a6)
		move.l	d0,CIACounter(a6)
		move.l	d0,ScrSwCnt(a6)

		CALLGRAF	OwnBlitter	;seize control of Blitter

		CALLEXEC	Forbid		;kill multitasking

		move.l	$68,OldInt2(a6)	;save old interrupt
		move.l	$6C,OldInt3(a6)	;vectors

		lea	$DFF000,a5	;and point to custom chips


* From here on, A5 and A6 MUST be left alone! A6 MUST point to my
* allocated variable block, and A5 MUST point to the custom chips!

* Now set up my own interrupts. Wait for picture beam to drop below bottom
* of screen before killing off sprites-prevents the spurious sprite video
* data problem...


main_WBPos	cmp.b	#255,VHPOSR(a5)		;wait for beam
		bne.s	main_WBPos		;to hit bottom

		move.w	#$7FFF,d0

		move.w	d0,DMACON(a5)		;kill DMA
		move.w	d0,INTENA(a5)		;disable ints
		move.w	d0,INTREQ(a5)		;cancel IRQs

		lea	Int2_Handler(pc),a0	;CIA-A interrupt
		move.l	a0,$68			;handler

		lea	Int3_Handler(pc),a0	;handle VBL, Copper
		move.l	a0,$6C			;& Blitter ints


* Now activate my 1st Copper List and the various required
* interrupts/DMA channels. Also set up bitplane control and the
* other screen parameters.


		move.w	#$4200,BPLCON0(a5)	;4 bitplanes
;		move.w	#$2200,BPLCON0(a5)
		move.w	#0,BPLCON1(a5)
		move.w	#0,BPLCON2(a5)

		move.w	#0,BPL1MOD(a5)
		move.w	#0,BPL2MOD(a5)

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

		move.w	#LOCK_KILL,AnimLock(a6)	;halt animations


* Now set my palette


		lea	Palette(pc),a0
		moveq	#16,d0
		bsr	SetPalette


* Now clear the bitplanes


;		bra.s	main_SK1

		lea	RasterActive(a6),a1	;ptr to bp ptrs
		moveq	#8,d7			;no. to do

main_SCL		move.l	(a1)+,a0		;get bitplane pointer
		bsr	BlitScrClear	;clear it
		subq.w	#1,d7		;done them all?
		bne.s	main_SCL		;back for more if not


* Now set off my ints!

;		move.l	RasterActive(a6),a0	;debug
;		move.w	#-1,(a0)

main_SK1		nop

;		move.w	#LOCK_DISABLE,AnimLock(a6)	;init animations

;		move.w	#SETIT+BLIT,INTREQ(a5)	;start them up

;		move.w	#INT_SET2,INTENA(a5)	;enable copper irq

		sf	ScrSwitch(a6)		;allow scr switch


* Now hit my main program


main_KW		cmp.b	#$45,OrdKey(a6)		;main program
		beq	main_KD			;loop till ESC

;		move.b	OrdKey(a6),d0
;		moveq	#4,d1
;		moveq	#10,d2
;		bsr	ShowByte

;		move.b	ShiftKey(a6),d0
;		moveq	#8,d1
;		moveq	#10,d2
;		bsr	ShowByte

;		move.w	#SETIT+BLIT,INTREQ(a5)

;		move.l	RasterWaiting(a6),a0
;		not.w	(a0)

		move.b	OrdKey(a6),d0
		cmp.b	#$4C,d0		;cursor up?
		bne.s	main_K1

		move.w	#$0001,d0	;Anim ID
		move.w	#0,d1		;new x vel
		move.w	#-1,d2		;new y vel

		movem.w	d0-d2,AnimComm(a6)
		bra	main_KW

main_K1		cmp.b	#$4D,d0		;cursor down?
		bne.s	main_K2

		move.w	#$0001,d0	;Anim ID
		move.w	#0,d1		;new x vel
		move.w	#1,d2		;new y vel

		movem.w	d0-d2,AnimComm(a6)
		bra	main_KW

main_K2		cmp.b	#$4E,d0		;cursor right?
		bne.s	main_K3

		move.w	#$0001,d0	;Anim ID
		move.w	#1,d1		;new x vel
		move.w	#0,d2		;new y vel

		movem.w	d0-d2,AnimComm(a6)
		bra	main_KW

main_K3		cmp.b	#$4F,d0		;cursor left?
		bne.s	main_K4

		move.w	#$0001,d0	;Anim ID
		move.w	#-1,d1		;new x vel
		move.w	#0,d2		;new y vel

		movem.w	d0-d2,AnimComm(a6)
		bra	main_KW

main_K4		cmp.b	#$01,d0		;' key?
		bne	main_KW

		move.w	#$0001,d0	;Anim ID
		move.w	#0,d1		;new x vel
		move.w	#0,d2		;new y vel

		movem.w	d0-d2,AnimComm(a6)
		bra	main_KW

main_KD		bsr	WaitMBDown

		move.w	#LOCK_KILL,AnimLock(a6)

		bsr	WaitVBL


* Now recover the machine's sanity for a return to Exec.


		move.l	OldInt2(a6),$68	;recover old interrupt
		move.l	OldInt3(a6),$6C	;vectors

		move.l	GFXCopList(a6),COP1LCH(a5)	;get old screen
		move.w	#0,COPJMP1(a5)		;back!

		move.w	#OLD_INT,INTENA(a5)	;recover old ints
		move.w	#OLD_DMA,DMACON(a5)	;recover old DMA

		CALLEXEC	Permit		;recover multitasking

		CALLGRAF	DisownBlitter	;release control of Blitter

cock_up_7	move.l	BgndArea(a6),a1	;release bgnd save areas
		move.l	BgndSize(a6),d0	
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

cock_up_4	move.l	ScrBase(a6),a1	;free screen RAM
		move.l	#BP_SIZE*8,d0
		CALLEXEC	FreeMem

cock_up_3	move.l	graf_base(a6),a1	;relinquish use of
		CALLEXEC	CloseLibrary	;graphics lib

cock_up_2	move.l	a6,a1		;release my
		move.l	#vars_sizeof,d0	;variable block
		CALLEXEC	FreeMem

cock_up_1	moveq	#0,d0		;keep CLI happy
		rts


* MakeCopper(a0,a1)
* a0 = ptr to desired Copper List
* a1 = ptr to list of bitplane pointers

* Generate a Copper list. Generates bitplane instructions,
* then puts a WAIT $FFFE instruction at the end.

* d0-d2/a0-a1 corrupt


MakeCopper	move.w	#BPL1PTH,d0	;1st bitplane ptr reg no.

		moveq	#4,d1		;4 bitplanes

MCList_1		move.l	(a1)+,d2		;get a bitplane pointer
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

;		move.w	#$C801,(a0)+	;WAIT (0,200)
;		move.w	#$FF00,(a0)+

;		move.w	#COLOR00,(a0)+	;MOVE $777,COLOR00
;		move.w	#$777,(a0)+

;		move.w	#$FF01,(a0)+	;WAIT (0,255)
;		move.w	#$FF00,(a0)+

;		move.w	#COLOR00,(a0)+	;MOVE $000,COLOR00
;		move.w	#0,(a0)+

;;		move.w	#INTREQ,(a0)+	;MOVE #SETIT+COPER,
;;		move.w	#INT_SET2,(a0)+	;INTREQ

		moveq	#-2,d0		;WAIT $FFFE
		move.l	d0,(a0)		;and finish Copper list

		rts


* Int2_Handler()
* Handle Level 2 interrupt (CIA-A)
* Get key value etc


Int2_Handler	movem.l	d0-d5/a6,-(sp)

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

;		clr.b	ShiftKey(a6)	;and the shifts??
		bra.s	Int2_2		;and exit Int2

Int2_3		moveq	#0,d4		;shift key state to record
		move.b	ShiftKey(a6),d5	;shifts already gotten
		sub.b	#$60,d3		;get shift bit no
		bset	d3,d4		;& set the shift bit

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


* Int3_Handler()
* Handle Level 3 Interrupt
* a5 MUST point to custom chips!

* Note:blitter animation code handled via interrupts. Relies upon a
* variable AnimLock to determine which animation phase is currently
* on line. States are:

* LOCK_REPLACE	: cause Int3 to replace saved backgrounds
*		  using pre-saved screen pointers etc
* LOCK_SAVE	: cause Int3 to save new backgrounds plus the
*		  screen pointers to ease replacement
* LOCK_PLOT	: cause Int3 to plot graphics
* LOCK_DISABLE	: cause Int3 to do blitter precomputations
*		  for above routines, PLUS handle movement.

* The interrupt methodology has been redesigned to take account of a
* double-buffered screen. Methodology is now:

* 1) Replace bgnds if pre-saved bgnds exist (they won't on first 2 passes)
*	on the INACTIVE screen.

* 2) Save new bgnds on the INACTIVE screen.

* 3) Plot graphics on the INACTIVE screen.

* 4) Do the blitter precomps for the next round.

* 5) Switch screens! Here identity of inactive screen changes!

* 6) go back to 1).


Int3_Handler	movem.l	d0-d7/a0-a6,-(sp)	;save these

;		move.w	#$2300,SR	;prevent interrupt nesting
		move.w	#$2700,SR	;prevent interrupt nesting

		clr.w	IntExit(a6)	;ensure no extra IRQs

		move.w	INTREQR(a5),d0	;check which int occurred
		bclr	#15,d0		;signal IRQ acknowledge
		move.w	d0,INTREQ(a5)	;and tell 4703 about it

		btst	#6,d0		;Blitter?
		beq.s	Int3_1		;no

		addq.l	#1,BlitCounter(a6)	;add to blitter counter

Int3_Anim	move.l	d0,-(sp)		;save INTREQR status

		move.w	AnimLock(a6),d0	;get Animation Lock
		bne.s	Int3_Able	;skip if not LOCK_DISABLE

		bsr	BlitPreComp	;precompute for next round
		sf	ScrSwitch(a6)	;re-allow screen switch

		move.w	#LOCK_HOLD,AnimLock(a6)	;wait for next

		bra.s	Int3_Blitted	;and skip

Int3_Able	cmp.w	#LOCK_REPLACE,d0
		bne.s	Int3_DoneRep	;skip if not LOCK_REPLACE

		bsr	BlitRep		;else replace old bgnds

		bra.s	Int3_Blitted	;and done

Int3_DoneRep	cmp.w	#LOCK_SAVE,d0
		bne.s	Int3_DoneSave	;skip if not LOCK_SAVE

		bsr	BlitSave	;else save new bgnds

		bra.s	Int3_Blitted	;and done

Int3_DoneSave	cmp.w	#LOCK_PLOT,d0
		bne.s	Int3_Blitted	;skip if not LOCK_PLOT

		bsr	BlitPlot	;else plot graphics

Int3_Blitted	move.l	(sp)+,d0	;recover INTREQR status

Int3_1		btst	#5,d0		;VBL?
		beq.s	Int3_2		;no

		addq.l	#1,VBLCounter(a6)	;add to VBL counter

		tst.b	ScrSwitch(a6)	;screen switching allowed?
		bne.s	Int3_2		;skip if not

		st	ScrSwitch(a6)	;prevent unwanted screen switch

		lea	CopActive(a6),a0	;point to screen/Copper
		movem.l	(a0),d1-d2		;variables
		exg	d1,d2			;prepare screen switch
		movem.l	d1-d2,(a0)		;replace them swapped around

		move.l	d1,COP1LCH(a5)	;do screen switch

		move.w	#0,COPJMP1(a5)

		lea	RasterActive(a6),a0	;ptr to bp pointers

		movem.l	(a0),d1-d4	;swap bitplane pointers
		movem.l	16(a0),a1-a4	;around
		movem.l	d1-d4,16(a0)
		movem.l	a1-a4,(a0)

		move.w	#LOCK_REPLACE,AnimLock(a6)	;re-enable Anims
		move.w	#SETIT+BLIT,IntExit(a6)	;& start up Anims

		addq.l	#1,ScrSwCnt(a6)	;count screen switches

Int3_2		btst	#4,d0		;Copper?
		beq.s	Int3_3		;no

		addq.l	#1,CopCounter(a6)	;add to Copper counter


* Programmer can insert his own Copper interrupt code from here on
* up to the label Int3_3.


Int3_3		move.w	IntExit(a6),d0	;see if any blitter routine
		beq.s	Int3_Done	;wants BLIT int restarting

		move.w	d0,INTREQ(a5)	;come here if it does

Int3_Done	movem.l	(sp)+,d0-d7/a0-a6
		rte


* WaitVBL()
* Wait for VBL to pass by
* d0 corrupt


WaitVBL		move.l	VBLCounter,d0
WaitVBL_1	cmp.w	VBLCounter,d0
		beq.s	WaitVBL_1
		rts

* WaitAnim()
* Wait for anim routine to set LOCK_DISABLE. Then it is
* safe to do a whole host of other things.
* d0/d1 corrupt


WaitAnim		move.w	#LOCK_DISABLE,d0
WaitAnim_1	move.w	AnimLock(a6),d1
		cmp.w	d0,d1
		bne.s	WaitAnim_1
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


* ScanAnims(a6)
* a6 = ptr to main variable block.

* Determine amount of memory needed for the background save areas
* for all of the Anims. This MUST be CHIP RAM!

* d0-d3/a0-a2 corrupt


ScanAnims	move.l	AnimList(a6),a0	;get ptr to 1st Anim

		moveq	#0,d3

SCA_L1		move.l	Anim_Bob(a0),a1	;ptr to 1st Bob for Anim

		moveq	#0,d0		;initial row count
		moveq	#0,d1		;initial col count

		move.l	a1,a2		;copy pointer

SCA_L2		move.w	Bob_Rows(a2),d2	;get rows count
		cmp.w	d0,d2		;bigger than init rows?
		bcs.s	SCA_1		;no
		move.w	d2,d0		;else update
SCA_1		move.w	Bob_Cols(a2),d2	;get WORD cols count
		cmp.w	d1,d2		;bigger than init cols?
		bcs.s	SCA_2		;no
		move.w	d2,d1		;else update
SCA_2		move.l	Bob_Next(a2),a2	;next Bob
		cmp.l	a1,a2		;back to start of list?
		bne.s	SCA_L2

		addq.w	#1,d1		;WORDS +1
		mulu	d0,d1		;create bgnd save area size
		add.l	d1,d1		;make it BYTES!
		addq.l	#6,d1		;+ extra space for pointer etc

		move.l	d1,Anim_BgSz(a0)	;keep size needed for 1 bitplane

		move.b	Anim_MaxPlanes(a0),d2	;bitplane count

SCA_L3		add.l	d1,d3		;create total memory size
		subq.b	#1,d2		;for all bitplanes of
		bne.s	SCA_L3		;this anim

		addq.l	#2,d3		;safety margin, Laurence blit

		move.l	Anim_Next(a0),a0	;get next anim
		cmp.l	AnimList(a6),a0	;done them all?
		bne.s	SCA_L1		;no, back for more

		add.l	d3,d3		;need enough for 2 areas/anim

		move.l	d3,BgndSize(a6)	;save it

		rts


* InitAnims(a6)
* a6 = ptr to main program variables

* Initialise all of the Anim structures. Create pointers to
* background save areas & initialise pointer entries within
* these areas.

* d0/a0-a2 corrupt


InitAnims	move.l	AnimList(a6),a0	;ptr to 1st Anim

		move.l	BgndArea(a6),a1	;ptr to bgnd save areas

IA_L1		move.l	Anim_BgSz(a0),d0	;get bgnd area size

		move.b	Anim_MaxPlanes(a0),d1	;plane count

		move.l	a1,Anim_Bgnd1(a0)	;save ptr to 1st area

IA_L2		clr.l	(a1)		;clear pointer area
		add.l	d0,a1		;next area
		subq.b	#1,d1		;done all bitplanes?
		bne.s	IA_L2		;back for more if not

		addq.l	#2,a1		;safety for Laurence Blit

		move.b	Anim_MaxPlanes(a0),d1

		move.l	a1,Anim_Bgnd2(a0)	;save ptr to 2nd area

IA_L3		clr.l	(a1)		;clear pointer area
		add.l	d0,a1		;next area
		subq.b	#1,d1		;done all bitplanes?
		bne.s	IA_L3		;back for more if not

		addq.l	#2,a1		;safety for Laurence Blit

		move.l	Anim_Next(a0),a0	;get next Anim
		cmp.l	AnimList(a6),a0	;done them all?
		bne.s	IA_L1		;no

		rts


* BlitPreComp(a6)
* a6 = ptr to main program variables

* Performs precomputation of certain important values
* for the other blitter interrupt routines. Called when
* AnimLock is set to LOCK_DISABLE and performs the
* precomputation for ALL Anims in the list. Note also that
* if any Anims have movement associated with them, then
* this routine should be called AFTER the movement has
* been performed to reflect the new position (data for
* recovering backgrounds at previous positions saved with
* those backgrounds).

* Also enables screen switch once completed. VBL handler
* disables it again after switching until blitter interrupt
* calls this code on next round & re-enables switching.

* Also handles synchronised velocity and position changes!

* NOTE : if changing an Anim's speeds, use MOVEM to make the
* operation atomic-interrupt might hiccup slightly otherwise.


* d0-d1/a0-a1 corrupt


BlitPreComp	move.l	AnimList(a6),a0	;get ptr to 1st Anim

BPC_L1		move.w	Anim_ID(a0),d0	;get anim ID
		cmp.w	AnimComm(a6),d0	;changing this one?
		bne.s	BPC_B1

		move.w	AnimXV(a6),d0	;get velocity message
		move.w	AnimYV(a6),d1

		move.w	d0,Anim_XVel(a0)	;and change this Anim's
		move.w	d1,Anim_YVel(a0)	;velocities

BPC_B1		move.w	Anim_XVel(a0),d0	;get Anim velocities
		move.w	Anim_YVel(a0),d1

		add.w	d0,Anim_XPos(a0)	;add to positions!
		add.w	d1,Anim_YPos(a0)

		move.l	Anim_Bob(a0),a1	;ptr to Bob struct

		move.w	Bob_XChg(a1),d0	;anim frame position
		move.w	Bob_YChg(a1),d1	;changes

		add.w	d0,Anim_XPos(a0)	;change actual plot
		add.w	d1,Anim_YPos(a0)	;position accordingly

		sub.l	a1,a1		;initial offset value
		move.w	Anim_XPos(a0),d0
		move.w	d0,d1
		and.w	#$F,d1
		ror.w	#4,d1
		move.w	d1,Anim_XShift(a0)	;save this for blitter

		asr.w	#4,d0		;int(X/16)
		add.w	d0,d0
		add.w	d0,a1		;X position address offset

		move.w	Anim_YPos(a0),d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0		;this is y*40

		add.w	d0,a1		;Y position address offset

		move.l	a1,Anim_Offset(a0)	;save total offset

		movem.l	Anim_Bgnd1(a0),d0-d1	;swap bgnd save area
		exg	d0,d1			;ptrs around for the
		movem.l	d0-d1,Anim_Bgnd1(a0)	;screen switch!

		move.l	Anim_Next(a0),a0
		cmp.l	AnimList(a6),a0	;done all Anim objects?
		bne	BPC_L1		;back for more if not

		moveq	#-1,d0
		move.w	d0,AnimComm(a6)	;prevent unwanted movement

		rts			;done!


* BlitSave(a6)
* a6 = ptr to main program variables

* Perform background-saving operation for Anim objects.
* Does the hard work of computing & storing bitplane pointers
* then blitting the background into the buffer after the
* pointer and X shift data is saved there too.

* d0-d5/a0-a2 corrupt


BlitSave	move.l	AnimThis(a6),a0	;get current Anim

		tst.b	Anim_Flags(a0)	;disabled anim?
		bpl.s	BS_Ena		;skip if not

		move.w	#SETIT+BLIT,IntExit(a6)	;else force IRQ
		bra	BS_New			;and get new Anim

BS_Ena		move.w	WhichPlane(a6),d0	;current bitplane no
		move.w	d0,d1			;copy it

		lea	RasterWaiting(a6),a1	;ptr to bp ptrs
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,a1
		move.l	(a1),a1			;get bitplane ptr

		move.l	Anim_BgSz(a0),d0
		mulu	d1,d0			;offset to req'd save area
		add.l	Anim_Bgnd1(a0),d0	;ptr to area

		move.w	Anim_XShift(a0),d2	;X shift

		add.l	Anim_Offset(a0),a1	;create true addr pos


* Here, A1 = BLTAPTH/L, D0 = BLTDPTH/L.


		move.l	d0,a2			;ptr to save area
		move.l	a1,(a2)+		;save recovery ptr
		move.w	d2,(a2)+		;save frac(X/16)
		move.l	a1,d0			;save it for blitter
		move.l	Anim_Bob(a0),a1		;get ptr to Bob
		move.w	Bob_Rows(a1),d3
		move.w	Bob_Cols(a1),d4
		moveq	#0,d2
		move.w	d2,d1		;d2 = BLTCON1
		or.w	#$09F0,d1	;this is BLTCON0 (D = A)
		moveq	#-1,d5

		move.l	d0,BLTAPTH(a5)
		move.l	a2,BLTDPTH(a5)
		move.w	d1,BLTCON0(a5)
		move.w	d2,BLTCON1(a5)
		move.l	d5,BLTAFWM(a5)

		move.w	d4,d0
		addq.w	#1,d0		;word cols +1:Laurence #2
		neg.w	d0
		add.w	d0,d0
		add.w	#BP_WIDE,d0	;BLTAMOD
		move.w	d0,BLTAMOD(a5)
		moveq	#0,d0
		move.w	d0,BLTDMOD(a5)

		move.w	d3,d0
		and.w	#$3FF,d0
		lsl.w	#6,d0
		move.w	d4,d1
		addq.w	#1,d1
		and.w	#$3F,d1
		add.w	d1,d0
		move.w	d0,BLTSIZE(a5)	;start Blitter!

		move.w	WhichPlane(a6),d0
		addq.w	#1,d0
		cmp.b	Bob_Planes(a1),d0	;done all planes?
		beq.s	BS_Next			;skip if so
		move.w	d0,WhichPlane(a6)	;else save new plane no
		rts				;and exit

BS_Next		clr.w	WhichPlane(a6)		;new plane no.

BS_New		move.l	Anim_Next(a0),d0	;get next Anim

		cmp.l	AnimList(a6),d0		;done all Anims?
		bne.s	BS_StillSave		;skip if no

		move.w	#LOCK_PLOT,AnimLock(a6)	;change int function

BS_StillSave	move.l	d0,AnimThis(a6)		;change current Anim
		rts


* BlitRep(a6)
* a6 = ptr to main program variables

* Perform background-replacing operation for Anim objects.
* Uses the saved pointers from the BlitSave() function.

* NOTE : BACKGROUND REPLACEMENT MUST BE IN THE REVERSE ORDER FROM
* BACKGROUND SAVING AND ANIMATION FRAME PLOTTING!!!! ALL HELL BREAKS
* LOOSE OTHERWISE!!!

* d0-d5/a0-a2 corrupt


BlitRep		move.l	AnimThat(a6),a0		;get current Replace Anim

		tst.b	Anim_Flags(a0)		;disabled anim?
		bpl.s	BR_Ena			;skip if not

		move.w	#SETIT+BLIT,IntExit(a6)	;else force IRQ
		bra	BR_New			;and get new Anim

BR_Ena		move.w	WhichPlane(a6),d1	;current bitplane no

		move.l	Anim_BgSz(a0),d0
		mulu	d1,d0			;offset to req'd save area
		add.l	Anim_Bgnd1(a0),d0	;ptr to area

* Here, D0 = BLTAPTH/L. Make A2 = BLTAPTH/L and D0 = BLTDPTH/L.

		move.l	d0,a2			;ptr to save area
		move.l	(a2)+,d0		;get BLTDPTH/L ptr
		bne.s	BR_Doit			;exists so replace bgnd

		move.w	#SETIT+BLIT,IntExit(a6)	;else force IRQ
		bra	BR_New			;and get out

BR_Doit		move.w	(a2)+,d2		;get X/16 for shift
		move.l	Anim_Bob(a0),a1		;get ptr to Bob
		move.w	Bob_Rows(a1),d3
		move.w	Bob_Cols(a1),d4
		moveq	#0,d2
		move.w	d2,d1			;d2 = BLTCON1
		or.w	#$09F0,d1		;this is BLTCON0 (D = A)
		moveq	#-1,d5

		move.l	d0,BLTDPTH(a5)	;set up these blitter
		move.l	a2,BLTAPTH(a5)	;registers
		move.w	d1,BLTCON0(a5)
		move.w	d2,BLTCON1(a5)
		move.l	d5,BLTAFWM(a5)

		move.w	d4,d0
		addq.w	#1,d0		;word cols +1:Laurence #2
		neg.w	d0
		add.w	d0,d0
		add.w	#BP_WIDE,d0	;BLTDMOD
		move.w	d0,BLTDMOD(a5)
		moveq	#0,d0
		move.w	d0,BLTAMOD(a5)	;modulo -2:Laurence #1

		move.w	d3,d0
		and.w	#$3FF,d0
		move.w	d4,d1
		addq.w	#1,d1
		and.w	#$3F,d1
		lsl.w	#6,d0
		add.w	d1,d0
		move.w	d0,BLTSIZE(a5)	;start Blitter!

		move.w	WhichPlane(a6),d0
		addq.w	#1,d0
		cmp.b	Bob_Planes(a1),d0	;done all planes?
		beq.s	BR_Next			;skip if so
		move.w	d0,WhichPlane(a6)	;else save new plane no
		rts				;and exit

BR_Next		clr.w	WhichPlane(a6)		;new plane no.

BR_New		move.l	Anim_Prev(a0),d0	;get next Replace Anim
		cmp.l	AnimRep(a6),d0		;done all Replace Anims?
		bne.s	BR_StillSave		;skip if no

		move.w	#LOCK_SAVE,AnimLock(a6)	;change int function

BR_StillSave	move.l	d0,AnimThat(a6)		;change current Replace Anim

BR_Done		rts


* BlitPlot(a6)
* a6 = ptr to main program variables
* perform actual plotting of blitter graphic once
* backgrounds have been saved.

* ONLY THIS ROUTINE SHOULD CHANGE THE ANIMATION FRAME POINTERS AND
* FRAME COUNTERS! MAJOR BUG REMOVED BY TAKING THE FRAME CHANGE CODE
* OUT OF THE OTHER BLITTER ROUTINES!

* d0-d7/a0-a2 corrupt


BlitPlot	move.l	AnimThis(a6),a0		;get current Anim

		tst.b	Anim_Flags(a0)		;disabled anim?
		bpl.s	BP_Ena			;skip if not

		move.w	#SETIT+BLIT,IntExit(a6)	;else force IRQ
		bra	BP_New			;and get new Anim

BP_Ena		move.w	WhichPlane(a6),d1	;current bitplane no

		move.l	Anim_BgSz(a0),d0	;size of 1 save area
		mulu	d1,d0			;offset to req'd save area
		add.l	Anim_Bgnd1(a0),d0	;ptr to area


* Here, D0 = ptr to bgnd save area. Get true BLTCPTH/L and
* BLTDPTH/L from here, and get BLTAPTH/L and BLTBPTH/L from
* Bob data structure.


		move.l	d0,a2			;ptr to save area
		move.l	(a2)+,d0		;get BLTDPTH/L ptr
		bne.s	BP_Doit			;continue blit if exists

		move.w	#SETIT+BLIT,IntExit(a6)	;else force IRQ
		bra	BP_New			;and get out

BP_Doit		move.w	(a2)+,d2		;get X/16
		move.l	Anim_Bob(a0),a1		;get ptr to Bob
		move.w	Bob_Rows(a1),d3
		move.w	Bob_Cols(a1),d4
		move.w	d2,d1		;BLTCON1
		or.w	#$0FCA,d1	;this is BLTCON0 (cookie cut)
		moveq	#-1,d5
		clr.w	d5		;this is BLTAFWM/LWM

		move.l	Bob_Data(a1),d6		;ptr to graphic area
		move.w	d3,d7
		mulu	d4,d7
		add.l	d7,d7			;size of 1 bitplane
		mulu	WhichPlane(a6),d7	;offset to bitplane
		add.l	d7,d6			;ptr to graphic bitplane
		
		move.l	d6,BLTBPTH(a5)
		move.l	Bob_Mask(a1),BLTAPTH(a5)

		move.l	d0,BLTDPTH(a5)
		move.l	d0,BLTCPTH(a5)
		move.w	d1,BLTCON0(a5)
		move.w	d2,BLTCON1(a5)
		move.l	d5,BLTAFWM(a5)

		move.w	d4,d0
		addq.w	#1,d0		;word cols +1:Laurence #2
		neg.w	d0
		add.w	d0,d0
		add.w	#BP_WIDE,d0	;BLTCMOD/DMOD
		move.w	d0,BLTDMOD(a5)
		move.w	d0,BLTCMOD(a5)
		moveq	#-2,d0
		move.w	d0,BLTAMOD(a5)	;modulo -2:Laurence #1
		move.w	d0,BLTBMOD(a5)

		move.w	d3,d0
		and.w	#$3FF,d0
		lsl.w	#6,d0
		move.w	d4,d1
		addq.w	#1,d1
		and.w	#$3F,d1
		add.w	d1,d0
		move.w	d0,BLTSIZE(a5)	;start Blitter!

		move.w	WhichPlane(a6),d0
		addq.w	#1,d0
		cmp.b	Bob_Planes(a1),d0	;done all planes?
		beq.s	BP_Next			;skip if so
		move.w	d0,WhichPlane(a6)	;else save new plane no
		rts				;and exit

BP_Next		clr.w	WhichPlane(a6)		;new plane no.

		move.b	Anim_Flags(a0),d0
		asl.b	#1,d0			;reversed anim object?
		bmi.s	BP_Rev			;skip if so

		move.w	Anim_FNum(a0),d0	;get current frame num.
		addq.w	#1,d0			;select next frame
		cmp.w	Anim_FCnt(a0),d0	;over the limit?
		bcs.s	BP_FwdOk		;no
		clr.w	d0			;else reset to 0

BP_FwdOk	move.w	d0,Anim_FNum(a0)	;and set it
		move.l	Anim_Bob(a0),a1
		move.l	Bob_Next(a1),Anim_Bob(a0)	;set next frame
		bra.s	BP_New				;and do a new Anim

BP_Rev		move.w	Anim_FNum(a0),d0	;get current frame num.
		subq.w	#1,d0			;select prev frame
		bpl.s	BP_RevOk		;under the limit?
		move.w	Anim_FCnt(a0),d0	;select max if yes
		subq.w	#1,d0
BP_RevOk	move.w	d0,Anim_FNum(a0)	;and set it
		move.l	Anim_Bob(a0),a1
		move.l	Bob_Prev(a1),Anim_Bob(a0)	;set prev frame

BP_New		move.l	Anim_Next(a0),d0	;get next Anim

		cmp.l	AnimList(a6),d0		;done all Anims?
		bne.s	BP_StillSave		;skip if no

		move.w	#LOCK_DISABLE,AnimLock(a6)	;change int function

BP_StillSave	move.l	d0,AnimThis(a6)		;change current Anim

BP_Done		rts


* BlitScrClear(a0)
* a0 = ptr to raster bitplane to clear

* d0 corrupt


BlitScrClear	move.l	a0,BLTDPTH(a5)		;ptr to plane to clear
		moveq	#0,d0
		move.w	d0,BLTADAT(a5)		;data to fill with
;		move.w	#-1,BLTADAT(a5)
		move.w	d0,BLTDMOD(a5)		;modulo=0
		move.w	d0,BLTCON1(a5)		;no special control
		move.w	#$01F0,BLTCON0(a5)	;USED, D=A
		moveq	#-1,d0
		move.l	d0,BLTAFWM(a5)		;masks
		move.w	#BP_CLR,BLTSIZE(a5)	;start it up

		btst	#6,DMACONR(a5)
BSCWait		btst	#6,DMACONR(a5)		;busy wait (sigh)
		bne.s	BSCWait

		rts


* Debug data show routines


* ShowLong(d0,d1,d2)

* See ShowByte() for parms etc except that this time
* d0.L = LONG to show and d1 corrupt also


ShowLong	move.l	d0,-(sp)	;save longword
		swap	d0		;get high word
		bsr.s	ShowWord	;show it
		addq.w	#2,d1		;move 2 chars right
		move.l	(sp)+,d0	;recover longword
		bsr.s	ShowWord	;show low word
		rts


* ShowWord(d0,d1,d2)

* See ShowByte() for parms etc except that this time
* d0.W = WORD to show and d1 corrupt also


ShowWord	move.w	d0,-(sp)	;save word
		lsr.w	#8,d0		;get high byte
		bsr.s	ShowByte	;show it
		addq.w	#2,d1		;move 2 chars right
		move.w	(sp)+,d0	;recover word
		bsr.s	ShowByte	;show low byte
		rts


* ShowByte(d0,d1,d2)

* d0.B = byte value to show
* d1 = x position (char pos from 0 to 39)
* d2 = y position (raster line from 0 to 255)

* d3-d4/a0-a1 corrupt


ShowByte	move.l	RasterActive(a6),a0	;point to bitplane 0

		add.w	d1,a0		;x offset

		move.w	d2,d3
		move.w	d2,d4
		add.w	d4,d4
		add.w	d4,d4
		add.w	d3,d4
		add.w	d4,d4
		add.w	d4,d4
		add.w	d4,d4
		add.w	d4,a0		;+ y offset*40

		moveq	#0,d3
		move.b	d0,d3
		lsr.b	#4,d3		;get high nibble
		add.w	d3,d3
		add.w	d3,d3
		add.w	d3,d3		;number * 8
		lea	CharSet,a1
		add.w	d3,a1		;ptr to char bit pattern

		moveq	#BP_WIDE,d4		;screen across size

		move.l	a0,d3		;save scr ptr

		move.b	(a1)+,(a0)	;print char
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0

		move.l	d3,a0		;recover scr ptr
		addq.l	#1,a0		;next char pos along

		moveq	#0,d3
		move.b	d0,d3
		and.b	#$F,d3		;gt low nibble
		add.w	d3,d3
		add.w	d3,d3
		add.w	d3,d3		;value * 8
		lea	CharSet,a1
		add.w	d3,a1		;ptr to char bit pattern

		moveq	#BP_WIDE,d4	;across size of screen

		move.b	(a1)+,(a0)	;print char
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0
		move.b	(a1)+,(a0)
		add.w	d4,a0

		rts


* Palette (borrowed from CrossWord program!)

Palette:

		dc.w	$0000,$0fff,$0555,$0666
		dc.w	$0777,$0999,$0AAA,$0CCC
		dc.w	$0C00,$0900,$0FE0,$0CB0
		dc.w	$007E,$0630,$0840,$0A50


		dc.w	$0777,$0FFF,$004B,$008C
		dc.w	$0070,$0FF0,$0B00,$0630
		dc.w	$0741,$0951,$0A72,$0B84
		dc.w	$0DA5,$0AAA,$0777,$0555


* Library names (actually just one)...


graf_name	dc.b	"graphics.library",0
		even


* Here put data includes. Ensure that graphics data, sound data
* etc., goes into CHIP RAM!


* CHIP RAM data


		section	CUSTOM,DATA_C


ship		incbin	source:D.Edwards/Graphics/ship1.blit
		even

ship_m		incbin	source:D.Edwards/Graphics/ship1.mask
		even

cargo		incbin	source:D.Edwards/Graphics/cargo1.blit
		even

cargo_m		incbin	source:D.Edwards/Graphics/cargo1.mask
		even

flame1		incbin	source:D.Edwards/Graphics/flame1.blit
		even

flame1_m	incbin	source:D.Edwards/Graphics/flame1.mask
		even

flame2		incbin	source:D.Edwards/Graphics/flame2.blit
		even

flame2_m	incbin	source:D.Edwards/Graphics/flame2.mask
		even

flame3		incbin	source:D.Edwards/Graphics/flame3.blit
		even

flame3_m	incbin	source:D.Edwards/Graphics/flame3.mask
		even

flame4		incbin	source:D.Edwards/Graphics/flame4.blit
		even

flame4_m	incbin	source:D.Edwards/Graphics/flame4.mask
		even

saucer		incbin	source:D.Edwards/Graphics/ufo.blit
		even

saucer_m	incbin	source:D.Edwards/Graphics/ufo.mask
		even

airplane	incbin	source:D.Edwards/Graphics/plane.blit
		even

airplane_m	incbin	source:D.Edwards/Graphics/plane.mask
		even


* "Don't Care Where" data


		section	STRUCTS,DATA


* Anim structures for my custom animation system


Anim1		dc.l	Anim2
		dc.l	Anim6

		dc.l	0,0	;bgnd ptrs

		dc.l	0	;bgnd size needed

		dc.l	A1Bob1	;ptr to Bob struct

		dc.l	0	;precomp Offset

		dc.w	0	;precomp XShift

		dc.w	180,64	;position
		dc.w	0,0	;velocity

		dc.w	0,1	;frame count data

		dc.w	$0001	;ID

		dc.b	4	;max 4 bitplane anim
		dc.b	0	;flags


Anim2		dc.l	Anim3
		dc.l	Anim1

		dc.l	0,0	;bgnd ptrs

		dc.l	0	;bgnd size needed

		dc.l	A2Bob1	;ptr to Bob struct

		dc.l	0	;precomp Offset

		dc.w	0	;precomp XShift

		dc.w	200,74	;position
		dc.w	0,0	;velocity

		dc.w	0,8	;frame count data

		dc.w	$0001	;ID

		dc.b	4	;max 4 bitplane anim
		dc.b	0	;flags


Anim3		dc.l	Anim4
		dc.l	Anim2

		dc.l	0,0	;bgnd ptrs

		dc.l	0	;bgnd size needed

		dc.l	A3Bob1	;ptr to Bob struct

		dc.l	0	;precomp Offset

		dc.w	0	;precomp XShift

		dc.w	238,77	;position
		dc.w	0,0	;velocity

		dc.w	0,2	;frame count data

		dc.w	$0001	;ID

		dc.b	4	;max 4 bitplane anim
		dc.b	0	;flags


Anim4		dc.l	Anim5
		dc.l	Anim3

		dc.l	0,0	;bgnd ptrs

		dc.l	0	;bgnd size needed

		dc.l	A4Bob1	;ptr to Bob struct

		dc.l	0	;precomp Offset

		dc.w	0	;precomp XShift

		dc.w	100,60	;position
		dc.w	0,0	;velocity

		dc.w	0,1	;frame count data

		dc.w	$0002	;ID

		dc.b	4	;max 4 bitplane anim
		dc.b	0	;flags


Anim5		dc.l	Anim6
		dc.l	Anim4

		dc.l	0,0	;bgnd ptrs

		dc.l	0	;bgnd size needed

		dc.l	A5Bob1	;ptr to Bob struct

		dc.l	0	;precomp Offset

		dc.w	0	;precomp XShift

		dc.w	100,140	;position
		dc.w	0,0	;velocity

		dc.w	0,1	;frame count data

		dc.w	$0003	;ID

		dc.b	4	;max 4 bitplane anim
		dc.b	0	;flags


Anim6		dc.l	Anim1
		dc.l	Anim5

		dc.l	0,0	;bgnd ptrs

		dc.l	0	;bgnd size needed

		dc.l	A6Bob1	;ptr to Bob struct

		dc.l	0	;precomp Offset

		dc.w	0	;precomp XShift

		dc.w	176,149	;position
		dc.w	0,0	;velocity

		dc.w	0,2	;frame count data

		dc.w	$0003	;ID

		dc.b	4	;max 4 bitplane anim
		dc.b	0	;flags


* Bob structures for the above Anims


A1Bob1		dc.l	A1Bob1
		dc.l	A1Bob1

		dc.l	ship	;graphic data ptr
		dc.l	ship_m	;mask ptr

		dc.w	41,4	;41 rows, 4 cols (58x41)

		dc.w	0,0	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob1		dc.l	A2Bob2
		dc.l	A2Bob8

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols (21x13)

		dc.w	0,-2	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob2		dc.l	A2Bob3
		dc.l	A2Bob1

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols

		dc.w	0,-2	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob3		dc.l	A2Bob4
		dc.l	A2Bob2

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols

		dc.w	0,-2	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob4		dc.l	A2Bob5
		dc.l	A2Bob3

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols

		dc.w	0,-2	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob5		dc.l	A2Bob6
		dc.l	A2Bob4

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols

		dc.w	0,2	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob6		dc.l	A2Bob7
		dc.l	A2Bob5

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols

		dc.w	0,2	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob7		dc.l	A2Bob8
		dc.l	A2Bob6

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols

		dc.w	0,2	;Anim position changes

		dc.b	4	;4 planes
		even


A2Bob8		dc.l	A2Bob1
		dc.l	A2Bob7

		dc.l	cargo	;graphic data ptr
		dc.l	cargo_m	;mask ptr

		dc.w	13,2	;13 rows, 2 cols

		dc.w	0,2	;Anim position changes

		dc.b	4	;4 planes
		even


A3Bob1		dc.l	A3Bob2
		dc.l	A3Bob2

		dc.l	flame1	;graphic data ptr
		dc.l	flame1_m	;mask ptr

		dc.w	15,1	;15 rows, 1 cols (15x15)

		dc.w	0,0	;Anim position changes

		dc.b	4	;4 planes
		even


A3Bob2		dc.l	A3Bob1
		dc.l	A3Bob1

		dc.l	flame2	;graphic data ptr
		dc.l	flame2_m	;mask ptr

		dc.w	15,1	;15 rows, 1 cols (11x15)

		dc.w	0,0	;Anim position changes

		dc.b	4	;4 planes
		even


A4Bob1		dc.l	A4Bob1
		dc.l	A4Bob1

		dc.l	saucer	;graphic data ptr
		dc.l	saucer_m	;mask ptr

		dc.w	15,3	;15 rows, 1 cols (42x15)

		dc.w	0,0	;Anim position changes

		dc.b	4	;4 planes
		even


A5Bob1		dc.l	A5Bob1
		dc.l	A5Bob1

		dc.l	airplane		;graphic data ptr
		dc.l	airplane_m	;mask ptr

		dc.w	20,5	;20 rows, 5 cols (76x20)

		dc.w	0,0	;Anim position changes

		dc.b	4	;4 planes
		even


A6Bob1		dc.l	A6Bob2
		dc.l	A6Bob2

		dc.l	flame3		;graphic data ptr
		dc.l	flame3_m		;mask ptr

		dc.w	11,2	;11 rows, 2 cols (17x11)

		dc.w	0,0	;Anim position changes

		dc.b	4	;4 planes
		even


A6Bob2		dc.l	A6Bob1
		dc.l	A6Bob1

		dc.l	flame4		;graphic data ptr
		dc.l	flame4_m		;mask ptr

		dc.w	11,2	;11 rows, 2 cols (17x11)

		dc.w	0,0	;Anim position changes

		dc.b	4	;4 planes
		even


CharSet		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
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




