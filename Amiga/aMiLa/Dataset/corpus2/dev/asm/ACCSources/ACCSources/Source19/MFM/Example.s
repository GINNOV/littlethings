
; This variation on hardstart.s uses a loadfile subroutine to read modules
;from disc. A list of module names is maintained, pressing the RIGHT mouse
;button will step you through the list, pressing left will quit the proggy.

; Note that the routines in replayer.s require both DOS and graphics
;libraries to be open and their base pointers stored at the correct labels.

; Because the DOS file reading routines utalise the blitter it is essential
;that the program does not call OwnBlitter. Also, any bobs running under
;true interrupt may be affected while a file is being loaded, I cannot see
;a way round this yet! The same applies to scroll-texts using the blitter,
;it depends if the DOS routines are blitting when the interrupt occurs.

; You could always implement your 68000 blitting routines to get round this
;problem while a file is being loaded!!!

; M.Meany, Dec 91.


		XDEF		_PPBase,_GfxBase     *** required by Play.o


		XREF		IntOn,IntOff,LoadAndPlay  *** supplied by
							  *** Play.o

		include		source:include/hardware.i

; The code starts by opening powerpacker library.

Start		lea		dosname,a1
		move.l		#0,d0
		move.l		$4,a6
		jsr		-$0228(a6)	OpenLibrary
		move.l		d0,_DOSBase
		beq.s		.error

		lea		ppname,a1
		move.l		#0,d0
		move.l		$4,a6
		jsr		-$0228(a6)	OpenLibrary
		move.l		d0,_PPBase
		beq.s		.error1


		jsr		IntOn		*** enable CIA interrupt

		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error2		if so quit now !

		bsr		Main		do da
		bsr		SysOn		enable system

		jsr		IntOff		*** disable CIA Interrupt

.error2		move.l		$4.w,a6		a6->SysBase
		move.l		_PPBase,a1	a1->powerpacker base
		jsr		-$019e(a6)	CloseLibrary

.error1		move.l		$4.w,a6		a6->SysBase
		move.l		_DOSBase,a1	a1->DOS base
		jsr		-$019e(a6)	CloseLibrary

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

		move.l		$4,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#SETIT!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Write bitplane addresses into Copper List.

		move.l		#BitPlane,d0
		lea		CopPlanes,a0
		move.w		d0,4(a0)
		swap		d0
		move.w		d0,(a0)

; Strobe our list

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Stop drives ( Thanks to Vandal of Killers for this hint )

		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB

; Init the music!

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

		move.l		$4.w,a6		a6->SysBase
		move.l		_GfxBase,a1	a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		rts

*****************************************************************************
*****************************************************************************
*****************************************************************************

Main		bsr		LoadNextModule	start playing first module

; wait for beam to reach line 16

VBL		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		VBL		if not loop back

*****************************************************************************

**		MAIN PROGRAM GOES HERE

*****************************************************************************

mousey		btst		#2,$dff016	right mouse?
		bne.s		.try_left	if not test left

		bsr		LoadNextModule	else play next module

.try_left	btst		#6,CIAAPRA	lefty ?
		bne.s		mousey		if not loop back

; program should shut down here....

		bsr		DeInit

		rts

*****************************************************************************
*****************************************************************************
**************************** Subroutines ************************************
*****************************************************************************
*****************************************************************************

*****************************************************************************

Init		rts

*****************************************************************************

DeInit		rts

*****************************************************************************

*****************************************************************************

; Blaine, this is an example subroutine that demonstrates how to step through
;a list of modules. Provision has been made for PowerPacked modules, though
;this also means powerpacker.library needs to be open!

; You could insert your keyboard scan routine here and load any module you
;wished.... Sorry, your latest was a copper bar menu system, I forgot!

; Note that even though the interrupt is not disabled, the replay code is
;skipped by setting music_flag to 0 while initialising the next module. As
;this takes only a fraction of a second to do, not much a of pause will be
;noticed! The next module is loaded before the switch takes place.

; Mark.

LoadNextModule	move.l		CurrentMod,a0		a0->module name list

		move.l		(a0),a0			a0->filename

		jsr		LoadAndPlay		*** start it playing

.error		move.l		CurrentMod,a0		get list pointer
		lea		4(a0),a0		bump
		tst.l		(a0)			end of list
		bne.s		.no_reset
		lea		Modules,a0		if so reset to top
.no_reset	move.l		a0,CurrentMod		and save new position

		rts					and return

CurrentMod	dc.l		Modules

OldAddr		dc.l		0
OldSize		dc.l		0
NewAddr		dc.l		0
NewSize		dc.l		0

Modules		dc.l		mod1
		dc.l		mod2
		dc.l		mod3
		dc.l		0

mod1		dc.b		'df1:modules/mod.music',0
		even
mod2		dc.b		'df1:modules/mod.2',0
		even
mod3		dc.b		'df1:modules/mod.3',0
		even


*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************



*****************************************************************************
*****************************************************************************
***************************** Data ******************************************
*****************************************************************************
*****************************************************************************


grafname	dc.b		'graphics.library',0
		even
_GfxBase	ds.l		1

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

ppname		dc.b		'powerpacker.library',0
		even
_PPBase		dc.l		0

sysDMA		ds.l		1
syscop		ds.l		1


*****************************************************************************
*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************
*****************************************************************************

		section		cop,data_c

CopList		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$1200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,0			No modulo

		dc.w COLOR00,$0000		black background
		dc.w COLOR01,$0fff		white foreground
 
		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes	dc.w 0,BPL1PTL          
		dc.w 0

		dc.w		$ffff,$fffe		end of list


BitPlane	ds.b		(320/8)*256
		even


