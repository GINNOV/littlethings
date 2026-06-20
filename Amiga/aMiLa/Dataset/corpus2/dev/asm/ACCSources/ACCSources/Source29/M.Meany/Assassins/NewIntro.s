
; Name		Intro v2
; Function	Joystick controlled intro for games compilations
; Assembler	Devpac III
; Programmer	M.Meany
; Date		26 Nov 1992

; Copyright © M.Meany, 1992. Use by written permission only. To date only
;Assassins have this.

; Tested On	wb 1.2, 1.3, 2.04 & 3.0

		**********************************
		* Macros For Easy Initialsiation *
		**********************************

; Alter following macros to define what file is attached to what zone.

; ACC NOTE: the assassin disks is not available, but the code don't crash:-)


		*****	DO NOT DELETE MACROS   *****

F1		macro
		dc.b		'assassins:c/ppmore assassins:Pacman',0
		endm

F2		macro
		dc.b		'assassins:c/ppmore assassins:LeapII',0
		endm

F3		macro
		dc.b		'assassins:c/ppmore assassins:TractorBeam',0
		endm

F4		macro
		dc.b		'assassins:c/ppmore assassins:level1',0
		endm

F5		macro
		dc.b		'assassins:c/ppmore assassins:level2',0
		endm

F6		macro
		dc.b		0
		endm

F7		macro
		dc.b		0
		endm

F8		macro
		dc.b		0
		endm

F9		macro
		dc.b		0
		endm

F10		macro
		dc.b		0
		endm

; The following macros define the zones on the screen. Specify the top left
;and bottom right coordinates of each zone. If a zone is not required, set
;the x coords to values > 320. The zone will never be entered :-)

ZONE1		macro				pacman rectangle
		dc.w		7,9,75,95
		endm
		
ZONE2		macro				Leap II rectangle
		dc.w		86,9,154,95
		endm
		
ZONE3		macro				Tractor Beam rectangle
		dc.w		165,9,233,95
		endm
		
ZONE4		macro				level 1 rectangle
		dc.w		244,45,276,81
		endm
		
ZONE5		macro				level 2 rectangle
		dc.w		279,9,311,44
		endm
		
ZONE6		macro		can never be entered
		dc.w		500,500,500,500
		endm
		
ZONE7		macro		can never be entered
		dc.w		500,500,500,500
		endm
		
ZONE8		macro		can never be entered
		dc.w		500,500,500,500
		endm

ZONE9		macro		can never be entered
		dc.w		500,500,500,500
		endm
		
ZONE10		macro		can never be entered
		dc.w		500,500,500,500
		endm
		
		*********************************
		*	Include Files		*
		*********************************

		incdir		ACC29_A:m.meany/assassins/include/
		include		hardware.i		register equates
		include		hw_macros.i		hardware macros
		include		hw_start.i		startup code

SCROLL_SPEED	equ		4		alter speed of scroll text

		*********************************
		*	Main Source Here	*
		*********************************


; First thing, display the logo:

Main		COPBPLC		CopPlanes1,TopBpl,256*320/8,5
		COPBPL		CopPlanes2,MiddleBpl,100*320/8,5
		COPBPL		CopPlanes3,BottomBpl,50*336/8,1
		STARTCOP	#CList

; Enable blitter, copper and bitplane DMA

		move.w		#SETIT!DMAEN!BLTEN!COPEN!BPLEN,DMACON(a5)

; Initialise the NoiseTracker module

		jsr		mt_init

; Install new level 3 interrupt and permit it

		move.l		#NewLevel3,$6c
		move.w		#SETIT!INTEN!VERTB,INTENA(a5) enable level 3

; Wait for user to press the fire button

GetFire		btst		#6,CIAAPRA
;		bne.s		GetFire		DEVELOPMENT ONLY ********
		bne.s		.NotQuitting

		move.l		#0,PlayGame
		not.w		Repeater
		rts

.NotQuitting	tst.b		CIAAPRA
		bmi.s		GetFire

; Fire button pressed, so disable interrupts so nothing naughty happens :-)

		move.w		#VERTB,INTENA(a5)

; Find out what zone were in, loop if not one!

		move.l		PointerX,d0
		move.l		PointerY,d1
		bsr		GetZone
		tst.l		d0
		bne.s		.DoSelection

; Not a valid zone, re-enable interrupts and keep waiting

		move.w		#SETIT!INTEN!VERTB,INTENA(a5) enable level 3
		bra.s		GetFire
		
; d0 now contains raw key code, decide if it is a valid function key.

.DoSelection	subq.b		#1,d0			zone to offset
		asl.w		#2,d0			x4, long words
		lea		FunctionTable,a0	a0->offset table
		add.l		d0,a0
		move.l		(a0),a0			a0->filename
		tst.b		(a0)
		bne.s		.IsValid

; Not a valid entry, re-enable interrupts and keep waiting

		move.w		#SETIT!INTEN!VERTB,INTENA(a5) enable level 3
		bra.s		GetFire
		
.IsValid	move.l		a0,PlayGame		set name of file

; Stop interrupts

		move.w		#VERTB,INTENA(a5)

; Kill module

		jsr		mt_end

; Return to system

		rts					go home

		*********************************
		*	Level 3 Interrupt	*
		*********************************

; Level 3 interupts can be caused by the Vertical Blank, Blitter and Copper.
;For the time being, we are only interested in Vertical Blank interrupts, so
;we ignore all the others.

NewLevel3	lea		$dff000,a5
		move.w		INTREQR(a5),d0
		and.w		#VERTB,d0
		beq		.IntDone

		bsr		ScrollTop

		bsr		DrawPointer

		bsr		TestJoy

; First thing to do is call the NoisTracker player

		jsr		mt_music
		lea		$dff000,a5		nt-replay corrupts!

; Now scroll the text across the bottom of the screen

		moveq.l		#SCROLL_SPEED-1,d7
.ScrollLoop	bsr		AmScrl
		dbra		d7,.ScrollLoop

; Scroll colour bars above and below text

		bsr		ScrlColrBars

; Wobble reflected text -- looks best called twice!

		bsr		WobbleText
		bsr		WobbleText

; Clear interrupt requests to prevent nesting and repeat calls

.IntDone	move.w		#VERTB!COPER!BLIT,INTREQ(a5)

; Exit back to user mode, SuperState is no fun anyway.

		rte

		*********************************
		*  Do Scrolly On Top Of Display	*
		*********************************

; Top of display is a huge pic of which only 110 lines are visible at any one
;time. This routine scrolls the pic up and down through the window.

ScrollTop	tst.w		ScrollPause
		beq.s		.doScroll
		subq.w		#1,ScrollPause
		bra		.done	

.doScroll	tst.w		ScrollDir		determine dir of scrl
		bne.s		.ScrollDown		branch if going down
		
		move.l		ScrollCount,d0		get offset
		addq.w		#1,d0			bump it
		cmp.w		#145,d0			last line?
		bne.s		.NoChange		no, don't worry
		not.w		ScrollDir		else reverse dirn
		move.w		#200,ScrollPause
.NoChange	move.l		d0,ScrollCount		save offset

		mulu		#40,d0			calc line offset
		add.l		#TopBpl,d0		calc start address
		
		RCOPBPL		CopPlanes1,d0,256*320/8,5
		bra		.done

.ScrollDown	move.l		ScrollCount,d0		get offset
		subq.w		#1,d0			bump it
		bne.s		.NoChange1		skip if not top
		not.w		ScrollDir		else reverse dirn
		move.w		#200,ScrollPause	set pause
.NoChange1	move.l		d0,ScrollCount		save offset

		mulu		#40,d0			calc line offset
		add.l		#TopBpl,d0		calc start address
		
		RCOPBPL		CopPlanes1,d0,256*320/8,5

.done		rts

		*********************************
		*	Display Pointer		*
		*********************************

; Start by restoring background

DrawPointer	
;		lea		TestVars,a5		debug only

		move.l		PointerAddr,d3		restore address
		beq		.NoRestore		skip if NULL

; Initialise size of blit. Bob is 1 word wide, but were scrolling so use a
;width of 2 words.

		move.w		#16<<6!2,d4		size of blit
		moveq.l		#5-1,d0			plane counter

		QBLITTER

; Restore 1st plane

		move.l		#PointerSave,BLTAPTH(a5) source address
		move.w		#0,BLTAMOD(a5)		no source modulo
		move.w		#36,BLTDMOD(a5)		screen modulo
		move.l		#$09f00000,BLTCON0(a5)	use A & D: D=A
		move.l		#-1,BLTAFWM(a5)		no masking

.RestoreLoop	move.l		d3,BLTDPTH(a5)		dest addresss
		move.w		d4,BLTSIZE(a5)		start blit
		
; bump restore address

		add.l		#(320/8)*100,d3		bump to next plane

; Wait for Blitter and then loop

		QBLITTER

		dbra		d0,.RestoreLoop
		
; Now the background at the current position can be saved prior to blitting
;the pointer itself.

; Calculate addr in 1st bitplane at which to start saving

.NoRestore	move.w		#16<<6!2,d4		size of blit
		move.l		PointerX,d0		X
		move.l		PointerY,d1		Y
		asr.w		#4,d0			X / 16
		mulu.w		#40,d1			Y x bitplane width
		add.w		d0,d1
		add.w		d0,d1
		add.l		#MiddleBpl,d1		d1 = new addr
		
		move.l		d1,PointerAddr		save this addr
		moveq.l		#5-1,d0			plane counter

; Save planes

		QBLITTER				wait for blitter

		move.l		#PointerSave,BLTDPTH(a5) dest address
		move.w		#36,BLTAMOD(a5)		screen modulo
		move.w		#0,BLTDMOD(a5)
		move.l		#$09f00000,BLTCON0(a5)	use A & D: D=A
		move.l		#-1,BLTAFWM(a5)		no masking

.SaveLoop	move.l		d1,BLTAPTH(a5)		source address
		move.w		d4,BLTSIZE(a5)		start the blit

; bump plane pointer

		add.l		#(320/8)*100,d1		bump plane pointer
		
; Wait for Blitter to finish and then loop for all 5 planes

		QBLITTER				wait for blitter
		dbra		d0,.SaveLoop

; We can now stuff the bob into the display. To start with we must calculate
;the required scroll value.

		move.l		PointerAddr,d6		get dest address

		move.l		PointerX,d0		X
		and.w		#$f,d0			mask unwanted bits
		ror.w		#4,d0			into high nibble
		move.w		d0,d1
		swap		d0
		move.w		d1,d0			into both words
		or.l		#$0fca0000,d0		minterm and usage
		
		move.l		#Pointer,d2		bob gfx
		move.l		#PointerMask,d3		bab mask
		moveq.l		#5-1,d4			plane counter

.DLoop		
		QBLITTER
		move.l		#$ffff0000,BLTAFWM(a5)	mask out last word
		move.w		#-2,BLTAMOD(a5)
		move.w		#-2,BLTBMOD(a5)
		move.w		#36,BLTCMOD(a5)
		move.w		#36,BLTDMOD(a5)
		move.l		d0,BLTCON0(a5)
.DrawLoop	move.l		d3,BLTAPTH(a5)		bob mask
		move.l		d2,BLTBPTH(a5)		bob gfx
		move.l		d6,BLTCPTH(a5)		playfield
		move.l		d6,BLTDPTH(a5)		playfield
		move.w		#16<<6!2,BLTSIZE(a5)

; bump pointers

		add.l		#(320/8)*100,d6		bump plane pointer
		add.l		#(16/8)*16,d2		bump gfx pointer
		add.l		#(16/8)*16,d3		bump mask pointer
		
; Wait for Blitter and loop for all 5 planes

		QBLITTER
		dbra		d4,.DrawLoop		for all 5 planes
		
		rts

		*********************************
		*	Read Joystick Moves	*
		*********************************

; Subroutine to read joystick movement in port 1. Updates Pointers X,Y pos
;if within screen limits!

; Assumes a5 -> hardware registers ( ie a5 = $dff000 ).

; Corrupts d0, d1 

; M.Meany, Aug 91.


TestJoy		moveq.l		#0,d0			clear
		move.w		JOY1DAT(a5),d0		read stick

		btst		#1,d0			right ?
		beq.s		.test_left		if not jump!

		cmp.l		#303,PointerX
		bgt.s		.test_left
		addq.l		#2,PointerX

.test_left	btst		#9,d0			left ?
		beq.s		.test_updown		if not jump

		cmp.l		#2,PointerX
		blt.s		.test_updown
		subq.l		#2,PointerX
		
.test_updown	move.l		d0,d1			copy JOY1DAT
		lsr.w		#1,d1			shift u/d bits
		eor.w		d1,d0			exclusive or 'em
		btst		#0,d0			down ?
		beq.s		.test_down		if not jump

		cmp.l		#83,PointerY
		bgt.s		.test_down
		addq.l		#1,PointerY

.test_down	btst		#8,d0			up ?
		beq.s		.no_joy			if not jump

		cmp.l		#1,PointerY
		blt.s		.no_joy
		subq.l		#1,PointerY

.no_joy		rts

		*********************************
		*	Scroll Text Routine	*
		*********************************

; Scroll strip 16 lines high 1 pixel to the left. If AmPause is set, no
;scroll takes place and the value held is decreased. This allows a pause
;to be entered in the scroll text. No Blitter operations used. MM.

AmScrl		tst.w		AmPause			are we paused?
		beq.s		.DoScroll		no, get scrolling
		subq.w		#1,AmPause		dec pause counter
		bra.s		.done			and exit

; No pause, so scroll strip

.DoScroll	move.l		AmBplAddr,a0		a0->1st byte of strip
		lea		42*16+2(a0),a0		a0->last byte
		move.l		#42*16/2,d0		word counter
		move.w		#0,ccr			clear extend flag
.loop		roxl.w		-(a0)			scroll
		dbra		d0,.loop		for all 16 lines

; After scrolling left 16 pixels, print a new character

		tst.w		AmBitCount		sixteen pixels yet?
		bne.s		.nochar			no, don't print!
		move.w		#16,AmBitCount		else reset counter
		bsr		AmPChar			and print next char

.nochar		subq.w		#1,AmBitCount		dec scroll counter

.done		rts					and exit

;		******************************
;		Write next character on screen
;		******************************

; Gets ASCII code for next character and prints it just off right side of
;visible display. Again, no Blitter operations used!

AmPChar		move.l		AmCharPtr,a0		a0->next char
		moveq.l		#0,d0			clear reg
		move.b		(a0)+,d0		get ASCII
		tst.b		(a0)			end of text?
		bne.s		.NextPtr		no, so print!
		lea		AmText,a0		else wrap to start
.NextPtr	move.l		a0,AmCharPtr		save new pointer

; If the byte 1 is encountered in a scroll text it causes a pause!

		cmp.b		#1,d0			pause ?
		bne.s		.DoPrint		no, get and print it!
		move.w		#350,AmPause		else set pause timer
		move.w		#' ',d0

; The ASCII code must be converted to an offset into the font data. The font
;data starts with the space character and each character occupies 32 bytes.

.DoPrint	sub.b		#' ',d0			ASCII to offset
		asl.w		#5,d0			x32 bytes/char
		lea		Font,a0			a0->1st char data
		add.l		d0,a0			a0->char data
		move.l		AmBplAddr,a1
		lea		40(a1),a1		a1->dest addr

; Used direct copying as opposed to a loop as it's faster.

		move.w		(a0)+,(a1)		copy data to bpl
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0)+,(a1)
		lea		42(a1),a1
		move.w		(a0),(a1)
		
.done		rts

		*********************************
		*	Scroll Colour Bars	*
		*********************************

; Scrolls the colours in the two copper bars, one above and one below the
;scroll text itself! Also changes colour of scroll text.

ScrlColrBars	move.l		ColourPos,a0		a0->colour data
		lea		Bar1,a1			a1->into Copper list
		addq.l		#2,a1
		moveq.l		#50-1,d0		counter
		move.l		a0,a2			keep a safe copy

.Rloop		cmp.w		#$ffff,(a0)		last colour?
		bne.s		.CopyRColour		no, use it!
		lea		BarColours,a0		else reset to start

.CopyRColour	move.w		(a0)+,(a1)		colour into Copper
		addq.l		#4,a1			a1->next register
		dbra		d0,.Rloop		for all 50 of 'em
		
		move.l		a2,a0			a0->colour data
		lea		Bar2,a1			a1->into Copper list
		subq.l		#2,a1			
		moveq.l		#50-1,d0		counter

.Lloop		cmp.w		#$ffff,(a0)		last colour?
		bne.s		.CopyLColour		no, use it!
		lea		BarColours,a0		else reset to start

.CopyLColour	move.w		(a0)+,(a1)		colour into Copper
		subq.l		#4,a1			a1->next register
		dbra		d0,.Lloop		for all 50 of 'me
		
		addq.l		#2,a2			bump pointer
		cmp.w		#$ffff,(a2)		end of table
		bne.s		.CanSet			no, set new pointer
		lea		BarColours,a2		else reset pointer
.CanSet		move.l		a2,ColourPos		save for next time!

; Now fart around with the colours of the scroll text itself. Makes it more
;interesting! MM.

		move.w		(a2),d0
		move.w		d0,BackColour+2		change text backgrnd
		not.w		d0			scramble colour
		and.w		#$0fff,d0		mask out colour
		move.w		d0,TextColour+2		set text to this:-)

		rts					and exit

		*********************************
		*     Wobble Reflected Text	*
		*********************************

; The scroll text is reflected in the bottom half of the screen. This routine
;wobbles it for that special effect.

WobbleText	move.l		WobblePos,a0		a0->sine data
		lea		WobbleStrip,a1		a1->copper list
		addq.l		#2,a1
		moveq.l		#19-1,d0		counter
		move.l		a0,a2			save a copy

.loop		tst.w		(a0)			end of table?
		bpl.s		.SetWobble		no, do the buis
		lea		Sinus,a0		else reset pointer
.SetWobble	move.w		(a0)+,(a1)		copy data
		addq.l		#8,a1			next reg
		dbra		d0,.loop		for all 19 lines
		
		addq.l		#2,a2			bump through sinus
		tst.w		(a2)			end of table?
		bpl.s		.GotPos			no, use it
		lea		Sinus,a2		else reset pointer
.GotPos		move.l		a2,WobblePos		and save position

		rts

		*********************************
		*	Zone Detection Code	*
		*********************************

; Zone checking subroutine. We will want to monitor the position of the mouse
;when a button is being pressed, ie where on the screen is it. This routine
;relies on a table of 'zones', defined by the top left and bottom right
;corner of an imaginary rectangle. Supply an x,y coordinate and this routine
;will return a zone number if the mouse is within one, or zero otherwise.
;Look at this as laymans gadgets:-)

; If zones overlap at the position supplied, only the first is reported.

;The routine can also be used in hardware bashing programs to simulate
;gadgets on any display, it does not rely on mouse, joystick or sprites!

; M.Meany, October '92.

; Entry		d0=x
;		d1=y

; Exit		d0=zone

; Corrupt	d0

GetZone		move.l		a0,-(sp)		save

		lea		ZoneTable,a0		a0->zone defs
		moveq.l		#1,d2			first zone

; See if x is within limits

.loop		cmp.w		(a0),d0			check lower limit
		blt.s		.NextZone		out of bounds!
		
		cmp.w		4(a0),d0		check upper limit
		bgt.s		.NextZone		out of bounds

; X is ok, check y

		cmp.w		2(a0),d1		check lower limit
		blt.s		.NextZone		out of bounds
		
		cmp.w		6(a0),d1		check upper limit
		bgt.s		.NextZone		out of bounds

; The coordinate supplied is within bounds, exit now!

		move.w		d2,d0			set return code
		bra.s		.Done			and exit

; Step through zone table. Last entry has an x,y coordinate of -1.

.NextZone	addq.l		#8,a0			bump to next zone
		addq.w		#1,d2			bump zone ID
		cmpi.l		#-1,(a0)		end of table?
		bne.s		.loop			no, keep checking

; The coordinate supplied was not in any of the zones, return error!

		moveq.l		#0,d0			signal not in a zone
		
.Done		move.l		(sp)+,a0		restore
		rts

		*********************************
		*	Variables & Data	*
		*********************************

ScrollPause	dc.w		200		display logo for 2 secs
ScrollDir	dc.w		0		0=>scroll up, 1=>scroll down
ScrollCount	dc.l		0		amount to add/subtract

PointerX	dc.l		10		position of pointer on scrn
PointerY	dc.l		10
PointerAddr	dc.l		0		addr to restore

AmBplAddr	dc.l		BottomBpl+5*42	pointer to printing strip
AmBitCount	dc.w		0		pixel counter
AmCharPtr	dc.l		AmText		pointer to text itself
AmPause		dc.w		0		pause counter for scroll text

ColourPos	dc.l		BarColours	pointer to colours
WobblePos	dc.l		Sinus		pointer to sine data

;TestVars	ds.w		500		debug only

FunctionTable	dc.l		FKey1
		dc.l		FKey2
		dc.l		FKey3
		dc.l		FKey4
		dc.l		FKey5
		dc.l		FKey6
		dc.l		FKey7
		dc.l		FKey8
		dc.l		FKey9
		dc.l		FKey10

FKey1		F1
		even

FKey2		F2
		even

FKey3		F3
		even

FKey4		F4
		even

FKey5		F5
		even

FKey6		F6
		even

FKey7		F7
		even

FKey8		F8
		even

FKey9		F9
		even

FKey10		F10
		even

		*********************************
		*    	Zone Data Table		*
		*********************************

ZoneTable	
		ZONE1
		ZONE2
		ZONE3
		ZONE4
		ZONE5
		ZONE6
		ZONE7
		ZONE8
		ZONE9
		ZONE10
		dc.l		-1			end of zone data
		
		*********************************
		*    Colours For Copper Bars	*
		*********************************

BarColours	dc.w		$f00,$e00,$d00,$c00,$b00,$a00,$900,$800
		dc.w		$700,$600,$500,$400,$300,$200,$100,$111
		dc.w		$222,$333,$444,$555,$666,$777,$888,$999
		dc.w		$aaa,$bbb,$ccc,$ddd,$eee,$fff,$eee,$ddd
		dc.w		$ccc,$bbb,$aaa,$999,$888,$777,$666,$555
		dc.w		$444,$333,$222,$111,$001,$002,$003,$004
		dc.w		$005,$006,$007,$008,$009,$00a,$009,$00a
		dc.w		$00b,$00c,$00d,$00e,$00f,$00e,$00d,$00c
		dc.w		$00b,$00a,$009,$008,$007,$006,$005,$004
		dc.w		$003,$002,$001,$100,$200,$300,$400,$500
		dc.w		$600,$700,$800,$900,$a00,$a00,$b00,$c00
		dc.w		$d00,$e00,$ffff

		*********************************
		*     Sine Data For Wobble	*
		*********************************

Sinus	dc.w	$55,$66,$66,$77,$77,$77,$88,$88,$88,$99,$99,$99,$99,$aa,$aa
	dc.w	$aa,$aa,$aa,$99,$99,$99,$99,$88,$88,$88,$77,$77,$77,$66,$66
	dc.w	$55,$44,$44,$33,$33,$33,$22,$22,$22,$11,$11,$11,$11,$00,$00
	dc.w	$00,$00,$00,$11,$11,$11,$11,$22,$22,$22,$33,$33,$33,$44
	dc.w	$ffff

		*********************************
		*	Scrolly Message		*
		*********************************

;			 01234567890123456789

AmText		dc.b	'    The Assassins   ',1

		dc.b	'  Proudly Present:  ',1

		dc.b	'Game Compact No. 41 ',1

		dc.b	'                    '
		dc.b	'Use joystick to move',1
		
		dc.b	'  pointer and press ',1
		
		dc.b	'  fire to play game ',1
		dc.b	'                    '

		dc.b	'  Press LMB to exit ',1
		dc.b	'                    '

		dc.b	'    Hi ACC Reader   ',1
		
		dc.b	"  Heres a new Intro ",1
		dc.b	'                    '

		dc.b	'This intro is compatible with ALL operating system releases'
		dc.b	' to date. No self-modifying code, no naughty ram '
		dc.b	'tricks, just good clean fun!'
		dc.b	'                    '
		dc.b	'This menu may be used as long as the following '
		dc.b	'text is left in -------> '
		dc.b	'                    '
		dc.b	' Menu programmed by ',1
		dc.b	'   Amiganuts PD     ',1
		dc.b	'   12 Hinkler Road  ',1
		dc.b	'     Southampton    ',1
		dc.b	"        Hant's      ",1
		dc.b	"       SO2 6FT      ",1
		dc.b	'         <-------- '

		dc.b	'Of course you can rip what you like from the source '
		dc.b	'and abuse as you so wish ..... '

		dc.b	'This is the first time I have used my Zone checking '
		dc.b	'code, I knew it would come in useful oneday.'
		dc.b	'                    '
		
		dc.b	'Forget Hip Hop, lets wrap ( or should that be rap?'
		dc.b	'??? )          ..................           '
		dc.b	0

		*****************************************
		*      NoisetrackerV2.0 FASTreplay	*
		*   Uses lev6irq - takes 8 rasterlines	*
		*  Do not disable Master irq in $dff09a	*
		*  Used registers: d0-d3/a0-a7|	=INTENA	*
		*   Mahoney & Kaktus - (C) E.A.S. 1990	*
		*****************************************

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
	lea	$2a(a0),a0
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
	clr.b	mt_songpos                <------ Bug Fix by MASTER BEAT!
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

		*********************************
		*	CHIP memory data	*
		*********************************

		section		copper,data_c

; The copper list, compatible with all versions of operating system. Using
;my own macros to define copper instructions, soooo much easier to follow:-)

; Start by defining the top section of the display

CList		CMOVE		DIWSTRT,$2c81
		CMOVE		DIWSTOP,$2cc1
		CMOVE		DDFSTRT,$0038
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPLCON0,$5200		5 planes, lores
		CMOVE		BPLCON1,$0000
		CMOVE		BPL1MOD,$0000
		CMOVE		BPL2MOD,$0000
		CWAIT		0,40			20 lines for scroller

CopPlanes1	CMOVE		BPL1PTH,0		bpl pointers
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		CMOVE		BPL3PTH,0
		CMOVE		BPL3PTL,0
		CMOVE		BPL4PTH,0
		CMOVE		BPL4PTL,0
		CMOVE		BPL5PTH,0
		CMOVE		BPL5PTL,0

CopColours	ds.w		32*2			space for 32 colours

; Define the middle section, still in 5 planes.

		CWAIT		112,154			Wait for middle

CopPlanes2	CMOVE		BPL1PTH,0		bpl pointers
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		CMOVE		BPL3PTH,0
		CMOVE		BPL3PTL,0
		CMOVE		BPL4PTH,0
		CMOVE		BPL4PTL,0
		CMOVE		BPL5PTH,0
		CMOVE		BPL5PTL,0

; Define the bottom section, only 1 bitplane this time.

		CWAIT		112,255			wait for bottom
		CMOVE		BPLCON0,$1200		1 plane, lores
		CMOVE		BPLCON1,$0000
		CMOVE		BPL1MOD,$0002		scrolling here!
		CMOVE		BPL2MOD,$0002
CopPlanes3	CMOVE		BPL1PTH,0		bpl pointers
		CMOVE		BPL1PTL,0

; The following defines the copper bar above the scroll text

		CWAIT	7,1
Bar1	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000

		CWAIT	0,2
		CMOVE	COLOR00,0
		
; Ensure background is black where scroll text appears

		CWAIT	0,3
BackColour	CMOVE	COLOR00,$0000
TextColour	CMOVE	COLOR01,$0000

; Reflect the scroll text

		CWAIT		0,21
		CMOVE		BPL1MOD,-82
		CMOVE		BPL2MOD,-82

; Set up screen wobble for the reflection

WobbleStrip	CMOVE		BPLCON1,$44
		CWAIT		0,22
		CMOVE		BPLCON1,$66
		CWAIT		0,23
		CMOVE		BPLCON1,$77
		CWAIT		0,24
		CMOVE		BPLCON1,$88
		CWAIT		0,25
		CMOVE		BPLCON1,$88
		CWAIT		0,26
		CMOVE		BPLCON1,$77
		CWAIT		0,27
		CMOVE		BPLCON1,$66
		CWAIT		0,28
		CMOVE		BPLCON1,$44
		CWAIT		0,29
		CMOVE		BPLCON1,$22
		CWAIT		0,30
		CMOVE		BPLCON1,$11
		CWAIT		0,31
		CMOVE		BPLCON1,$00
		CWAIT		0,32
		CMOVE		BPLCON1,$00
		CWAIT		0,33
		CMOVE		BPLCON1,$11
		CWAIT		0,34
		CMOVE		BPLCON1,$22
		CWAIT		0,35
		CMOVE		BPLCON1,$44
		CWAIT		0,36
		CMOVE		BPLCON1,$66
		CWAIT		0,37
		CMOVE		BPLCON1,$77
		CWAIT		0,38
		CMOVE		BPLCON1,$88
		CWAIT		0,39
		CMOVE		BPLCON1,$88
		

; The following defines the Copper bar below the scroll text

		CWAIT	0,40
		CMOVE	COLOR00,0

		CWAIT	7,41
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	        dc.w    $180,$000,$180,$000,$180,$000,$180,$000,$180,$000
Bar2

		CWAIT		0,42
		CMOVE		COLOR00,$0000
		CMOVE		BPL1MOD,2
		CMOVE		BPL2MOD,2

		CEND

; Include all raw data at this point. Would save loads-a-ram reading this
;from disk as the program boots!!!!! This would allow larger games to run
;on low memory Amigas. If required, write and ask.

		incdir		acc29_a:m.meany/assassins/raw/
		
TopBpl		incbin		Pic1.bm		320x256x5, CMAP behind.

MiddleBpl	incbin		Pic2.bm		320x100x5, no CMAP.

BottomBpl	ds.b		(336/8)*50		bitplane for scroller

Pointer		incbin		pointer.bm

PointerMask	incbin		pointermask.bm

PointerSave	ds.b		4*16*5

Font		incbin		font.bm

mt_data		incbin		mod.music
