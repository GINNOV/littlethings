; Master Menu V2.0, by Simon Windmill (MASTER BEAT)
; NB: The RUN command has to be on the disk for the menu to work
; Also, the logo at the top sometimes corrupts. Why?
; Oh, and the Spurious Sprite Data (crap) is sometimes not 
; turned off.....

	SECTION MasterMenu,Code_C	Put t' jobby in t' chip_mem
	OPT	C-			Turn t' case sensitivity off			

**********

	INCDIR	sys:INCLUDE/
	INCLUDE	HARDWARE/CUSTOM.I
	INCLUDE	EXEC/EXEC_LIB.I



bpl1pth:	equ	$e0
bpl1ptl:	equ	$e2
bpl2pth:	equ	$e4
bpl2ptl:	equ	$e6
bpl3pth:	equ	$e8
bpl3ptl:	equ	$ea
bpl4pth:	equ	$ec
bpl4ptl:	equ	$ee
bpl5pth:	equ	$f0
bpl5ptl:	equ	$f2
bpl6pth:	equ	$f4
bpl6ptl:	equ	$f6
TextHeight:	equ	16
Bars		equ	1

**********

START	MOVE.L	A7,STPOINT		SAVE STACK POINTER
	MOVEM.L	A0-A6/D0-D7,-(A7)	SAVE ALL REGISTERS
	MOVE.L	#$DFF000,A5		I USE A5 AS MY HARDWARE OFFSET REG.
	CALLEXEC FORBID			TURN OFF MULTITASKING
	
	LEA	GFXNAME(PC),A1	
	MOVEQ.L	#0,D0
	CALLEXEC OPENLIBRARY		OPEN GFX LIBRARY
	MOVE.L	D0,GFXBASE		SAVE GFX BASE

	LEA	DOSNAME(PC),A1
	MOVEQ.L	#0,D0			ANY VERSION WILL DO, THANKS!
	CALLEXEC OPENLIBRARY		OPEN GFX LIBRARY
	MOVE.L	D0,DOSBASE

	MOVE.W	DMACONR(A5),DMASAVE	SAVE CLI DMA SETTINGS



SET_UP	

	move.l	#$4000*6,d0	* amount of memory	
	move.l	#$10002,d1	* memory type = chip+blank
	CALLEXEC	AllocMem
	beq	bye
	move.l	d0,_Screen	* stor addr (very important!)

WAIT1	BTST	#0,VPOSR(A5)		WAIT FOR VBL
	BNE.S	WAIT1			BEFORE TURNING
WAIT2	CMPI.B	#70,VHPOSR(A5)		SPRITE DMA OFF TO
	BNE.S	WAIT2			PREVENT CRAP APPEARING

	MOVE.W	#$0020,DMACON(A5)	SPRITE DMA OFF!
	MOVE.L	#NEWCOP,COP1LC(A5)	STICK MY NEW COPPER IN...
	MOVE.L	COPJMP1(A5),D0		...AND STROBE IT
	jsr	init_music		Initialise the replay routine	

	clr.w	hcount			} These lines reset the pointers
	clr.l	strtpos			} that control the screen type
	clr.l	linestrt		} routine for the menu

	clr.w	hcount2			} And these lines reset the
	clr.l	strtpos2		} pointers for the credits
	clr.l	linestrt2		} at the bottom

		
***********

BACKG	MOVE.L	#LOGO,D0		SETUP MAIN LOGO
	MOVE.W	D0,PL1L
	SWAP	D0
	MOVE.W	D0,PL1H
	SWAP	D0
	ADD	#1520,D0		NEXT PLANE
	MOVE.W	D0,PL2L
	SWAP	D0
	MOVE.W	D0,PL2H


	
	move.l	#scrollplane,d0	; Get address of our scroll memory.
	move.w	d0,scpl2l		; Move the low word into copper list.
	swap	d0		; Swap the low and high words in d0.
	move.w	d0,scpl2h		; Move the high word into the copper
				; list.


***********

; Let's blit clear the menu area!

	lea screen,a0			; address of menu
blitready:
	btst #14,$dff002		
	bne.s blitready			; wait till blitter ready

	move.l a0,$dff054		; source address
	move.l a0,$dff050		; destination address
	clr.l $dff044			; no FWM/LWM (see hardware manual)
	clr.l $dff064			; no MODULO (see hardware manual)

	move.w #%100000000,$dff040 	; Enable DMA channel D, nothing
					; else, no minterms active. 
	clr.w $dff042			; nothing set in BLTCON1
	move.w #140*64+21,$dff058
					; Window size = 21 words wide
					; 140 lines deep


***************

; The TECH routine for putting the text in...

BEGIN	MOVE.L	#SCREEN,D0		; Address of menu screen
	MOVE.W	D0,TL1L
	SWAP	D0
	MOVE.W	D0,TL1H
	

	MOVEQ.L	#0,D0
	MOVE.L	#TEXT,A0		TEXT ADDRESS --> A0

	MOVE.L	#SCREEN,A2		SCREEN ADDRESS --> A2
	ADDA	#200,A2			POINT TO LOWER DOWN SCREEN
	MOVE.L	A2,STRTPOS		SAVE CURRENT SCREEN POINTER
	MOVE.L	A2,LINESTRT		SAVE LINE START POINTER

LOOP	MOVE.L	#FONT,A1		ADDRESS	OF FONT DATA --> A1

	MOVE.B	(A0)+,D0		READ CHAR
	CMPI.B	#120,D0			IS IT AN "x"?
	BEQ	END			YES: END!

TST_SPD	CMPI.B	#102,D0
	BNE.S	TST_SP2
	MOVE.W	#0,DELAY		FAST TYPING
	BRA	SKIP

TST_SP2	CMPi.B	#115,D0
	BNE.S	SPD_DNE
	MOVE.W	#70,DELAY		SLOW TYPING
	BRA	SKIP

SPD_DNE	CMPI.W	#40,HCOUNT		ADJUST FIRST NUMBER FOR SCREEN WIDTH
	BNE.S	NOT_EOL

	MOVE.W	#0,HCOUNT
	MOVE.L	LINESTRT,A2
	ADDA.L	#40*9,A2
	MOVE.L	A2,STRTPOS
	MOVE.L	A2,LINESTRT

NOT_EOL	CMPI.B	#59,D0
	BGT.S	ALPHA_CHAR		IT'S AN A-Z CHARACTER
	CMPI.B	#31,D0
	BGT.S	PUNC_CHAR		IT'S AN EXTRA CHARACTER
	BRA	SKIP			SKIP IF CHAR IS NOT RECOGNISED

ALPHA_CHAR
	SUBI.L	#65,D0			ASCII --> POINTER
	ADD.L	D0,A1			ADD POINTER TO FONT POINTER
	BRA	STRTPLT			PRINT CHARACTER

PUNC_CHAR
	SUBI	#32,D0			GET PROPER OFFSET
	ADDI.L	#26,D0			SKIP ALPHA CHARS
	ADD.L	D0,A1			AND ADD OFFSET

STRTPLT	MOVE.L	#7,D1			8 DBRA LOOPS

PLOTLP	MOVE.B	(A1),(A2)		MOVE 8 BITS FROM FONT TO SCREEN
	ADDA.L	#52,A1			NEXT FONT LINE
	ADDA.L	#40,A2			NEXT SCREEN LINE

	DBRA	D1,PLOTLP		DO REST OF CHARACTER

SKIP	ADDI.L	#1,STRTPOS		NEXT HORIZONTAL POSITION
	MOVE.L	STRTPOS,A2		RELOAD (NEW) SCREEN POINTER

;	MOVE.W	DELAY,D7		ADJUST FIRST NUMBER FOR DELAY
;WTVBL	CMPI.B	#255,$DFF006
;	BNE.S	WTVBL
;	DBRA	D7,WTVBL

; ( Remove the above colons to see the 'screen type' effect... )
	
	ADDI.W	#1,HCOUNT
	
	BRA	LOOP			KEEP ON GOING!

END	

***************
	
	

	
***************

; Main loop is here -

Main	CMPI.B	#255,$DFF006		Are we at the bottom of the screen?
	BNE.S	Main			Non!			

	jsr	fadedown
	jsr	scrolly			Perform the slow scrolly

	bsr	raw_test		Read the keyboard
	BSR	joy_test		Read Joystick2
	bsr	mouse_test		Read the rodent

	movem.l	d0-d7/a0-a7,-(sp)	Save our registers...
	jsr	play_music		Play the music
	movem.l	(sp)+,d0-d7/a0-a7	....bring 'em back!


	
	btst	#2,$dff016		Is it RMB?
	beq	bye			Yes, then exit menu 

	btst	#6,$bfe001		Is it LMB?
	beq	continue		Yes, so execute chosen command
	
	btst	#7,$BFE001		Is it Joy2 firebutton?
	beq	continue		Yes, so execute chosen command

	bra	Main			Oh wow, deja vu!
	
****************

continue:
	move.l	_Screen,a1		
	move.l	#$4000*6,d0
	CALLEXEC	FreeMem
	jsr	end_music		Sound of silence...
	
	MOVE.L	GFXBASE,A0		JUST REPLACES CLI COPPER,
	MOVE.L	$26(A0),COP1LC(A5)	CLOSES GFX LIBRARY
	CLR.L	D0			& TURNS ON MULTITASKING.
	MOVE.L	GFXBASE,A1
	
	MOVE.W	DMASAVE,D7
	BSET	#$F,D7
	MOVE.W	D7,DMACON(A5)		RESET DMA SETTINGS

	CALLEXEC CLOSELIBRARY		Bloody obvious.....
	CALLEXEC PERMIT



**********


F1	CMP.b	#1,progcount		Where is the menu bar?
	Bne.S	F2			Not here, try next...
	MOVE.L	#COM1,D7		DOS command in D7
	BRA	EXECUTE			And execute it!

F2	cmp.b	#2,progcount
	bne.s	F3
	move.l	#com2,d7
	bra	execute
	
F3	cmp.b	#3,progcount
	bne.s	F4
	move.l	#com3,d7
	bra	execute
	
F4	cmp.b	#4,progcount
	bne.s	F5
	move.l	#com4,d7
	bra	execute
	
F5	cmp.b	#5,progcount
	bne.s	F6
	move.l	#com5,d7
	bra	execute
	
F6	cmp.b	#6,progcount
	bne.s	F7
	move.l	#com6,d7
	bra	execute
	
F7	cmp.b	#7,progcount
	bne.s	F8
	move.l	#com7,d7
	bra	execute
	
F8	cmp.b 	#8,progcount
	bne.s	F9
	move.l	#com8,d7
	bra	execute
	
F9	cmp.b	#9,progcount
	bne.s	F10
	move.l	#com9,d7
	bra	execute
	
F10	cmp.b	#10,progcount
	bne.s	F11
	move.l	#com10,d7
	bra	execute
	
F11	cmp.b	#11,progcount
	bne.s	F12
	move.l	#com11,d7
	bra	execute
	
F12	move.l	#com12,d7


**********

; Run that funky program for us!

EXECUTE	LEA	CONNAM(PC),A1		CONSOLE SETTINGS
	MOVE.L	#1005,D0		ACCESS MODE
	MOVE.L	A1,D1			CONSOLE NAME --> D1
	MOVE.L	D0,D2			ACCESS MODE --> D2
	MOVE.L	DOSBASE,A6
	JSR	-30(A6)			OPEN NEW WINDOW
	MOVE.L	D0,CONHD		SAVE OUR WINDOW HANDLE
	
	MOVE.L	DOSBASE,A6		JUST TO BE `SAFE`!
	MOVE.L	D7,D1			COMMAND --> D1
	MOVEQ.L	#0,D2			NO INPUT
	MOVE.L	CONHD,D3		CONSOLE HANDLE --> D3
	JSR	-222(A6)		EXECUTE OUR COMMAND

	MOVE.L	CONHD,D1
	MOVE.L	DOSBASE,A6
	JSR	-36(A6)			CLOSE OUR WINDOW
	jmp	set_up			Go right back to the
;					beginning of the menu!
	
**********

; It's time to go home.....

Bye:	

	move.l	_Screen,a1		
	move.l	#$4000*6,d0
	CALLEXEC	FreeMem
	jsr	end_music
	MOVE.L	GFXBASE,A0		JUST REPLACES CLI COPPER,
	MOVE.L	$26(A0),COP1LC(A5)	CLOSES GFX LIBRARY
	CLR.L	D0			& TURNS ON MULTITASKING.
	MOVE.L	GFXBASE,A1
	
	MOVE.W	DMASAVE,D7
	BSET	#$F,D7
	MOVE.W	D7,DMACON(A5)		RESET DMA SETTINGS

	CALLEXEC CLOSELIBRARY
	CALLEXEC PERMIT
QUIT	MOVE.L	DOSBASE,A1
	CALLEXEC CLOSELIBRARY		CLOSE DOS LIBRARY


	MOVEM.L	(A7)+,A0-A6/D0-D7	RESTORE REGISTERS...
	MOVE.L	STPOINT,A7		...AND OLD STACK
	RTS				GOODBYE CRUEL WORLD (SOB!)

**********

********************

raw_test
	addq.b	#1,rawcount
	cmpi.b	#3,rawcount
	beq	yesraw_test
	rts

yesraw_test:	
	move.b	#0,rawcount
	move.b	$BFEC01,D0		GET RAW CHAR (THANKS MARK!)
	not	D0
	ror.b	#1,D0
	cmp.b	#$45,D0
	beq	bye
	cmp.b	#$4c,d0
	beq	barup
	cmp.b	#$4d,d0
	beq	bardown
	cmp.b	#$44,d0
	beq	continue
	rts	

joy_test:
	addq.b	#1,joycount
	cmpi.b	#3,joycount
	beq	yesjoy_test
	rts
	
yesjoy_test				;JOYSTICK TEST
	move.b	#0,joycount
	move.w	$DFF00c,d2		;ADDRESS OF STICK 2
	move.w	d2,d1			;COPY TO D1
	lsr.w	#1,d1			;LOGICAL SHIFT RIGHT
	eor.w	d2,d1			;EXCLUSIVE OR D2 WITH D1
	btst	#1,d2			;TEST BIT 1 OF D2 (RIGHT)
	beq	try_left		;IF NOT EQUAL THEN TRY LEFT
; Right routine here
	rts

try_left
	btst	#9,d2			;TEST BIT 9 (LEFT)
	beq	try_down		;IF NOT EQUAL TRY DOWN
; Left Routine here
	rts
	
try_down
	btst	#0,d1			;TEST BIT 0 OF D1
	beq	try_up			;IF NOT EQUAL TRY UP
	bsr	bardown
; Down routine here
	rts

try_up	
	btst	#8,d1			;TEST BIT 8 OF D1
	beq	no_move			;IF NOT EQUAL MUST BE NO MOVE
	bsr	barup
; Up routine here
	rts
no_move

	rts

Mouse_Test:
	addq.b	#1,mousecount
	cmpi.b	#3,mousecount
	beq	yesCheckMouse
	rts
	
yesCheckMouse
	move.b	#0,mousecount
	MOVE.B	OldMouseY,D0		Last Y
	SUB.B	$DFF00A,D0
	BEQ	NoYMov
	BMI.S	DoDown
DoUp	
	bsr	barup		Up Routine Here
	BRA.S	NoYMov
DoDown	
	bsr	BarDown		Down Routine Here

NoYMov  MOVE.B	$DFF00A,OldMouseY	Save Y
	MOVE.B	OldMouseX,D0		Last X
	SUB.B	$DFF00B,D0
NoXMov	MOVE.B	$DFF00B,OldMouseX	Save X
	RTS


*******************

;Move our copper bar down..... 


BarDown:

	cmp.w	#$c101,barcop1		Are we at the bottom?
	beq	leavebar		Yes, so return...
	
	add.b	#1,progcount		Increment the prog counter

	add.w	#$0900,barcop1		Move each bar down 
	add.w	#$0900,barcop2		nine scan lines
	add.w	#$0900,barcop3
	add.w	#$0900,barcop4
	add.w	#$0900,barcop5
	add.w	#$0900,barcop6
	add.w	#$0900,barcop7
	add.w	#$0900,barcop8
	add.w	#$0900,barcop9
	add.w	#$0900,barcop10
	add.w	#$0900,barcop11
	add.w	#$0900,barcop12

	bra	leavebar
	
*****************

; Move our copper bar up

BarUp:

	cmp.w	#$5e01,barcop1		Are we at the top?
	beq	LeaveBar		Yes, so return
	
	sub.b	#1,progcount		Decrease our program counter
	sub.w	#$0900,barcop1		Move our bar up
	sub.w	#$0900,barcop2		nine scan lines
	sub.w	#$0900,barcop3
	sub.w	#$0900,barcop4
	sub.w	#$0900,barcop5
	sub.w	#$0900,barcop6
	sub.w	#$0900,barcop7
	sub.w	#$0900,barcop8
	sub.w	#$0900,barcop9
	sub.w	#$0900,barcop10
	sub.w	#$0900,barcop11
	sub.w	#$0900,barcop12

LeaveBar:
	Rts
	
***************************

; It's fab copper list time!

NEWCOP	DC.W	BPLCON0,$0000		; STANDARD SORT OF
	DC.W	BPLCON1,$0000
	DC.W	DIWSTRT,$2281		; SCREEN SETUP
	DC.W	DIWSTOP,$2cC1
	DC.W	DDFSTRT,$0038		
	DC.W	DDFSTOP,$00D0
	DC.W	BPL1MOD,$0000		
	DC.W	BPL2MOD,$0000
	dc.w	$180,$0000
	
	DC.W	$2909,$FFFE,BPLCON0,$2200 	; 2 Bitplanes 



	DC.W	BPLPT+$00		; SET UP MAIN LOGO BPLANE POINTERS
PL1H	DC.W	0,BPLPT+$02
PL1L	DC.W	0,BPLPT+$04
PL2H	DC.W	0,BPLPT+$06
PL2L	DC.W	0,BPLPT+$08
PL3H	DC.W	0,BPLPT+$0A
PL3L	DC.W	0,BPLPT+$0C
PL4H	DC.W	0,BPLPT+$0E
PL4L	DC.W	0,BPLPT+$10
PL5H	DC.W	0,BPLPT+$12
PL5L	DC.W	0

; Logo colours below....

	dc.w	$0180,$0000,$0182,$0eca,$0184,$0999,$0186,$0fff
	dc.w	$0192,$4ae





	dc.w	$4f09,$fffe,bplcon0,$0200	; Bitplanes off!
	
	dc.w	$5809,$fffe,$180,$f0f		; First purple bar
	dc.w	$5909,$fffe,$180,$222

	DC.W	$5c09,$FFFE,BPLCON0,$1200	; OPEN MAIN MENU SCREEN

	dc.w	$102,$0000
	DC.W	$182,$0999
	
	DC.W	BPLPT+$00			; Pointers for menu
TL1H	DC.W	0,BPLPT+$02
TL1L	DC.W	0


; The copper bar, 12 lines high

barcop1:
	dc.w $5e01
	dc.w $fffe
	dc.w $180,$0222
	dc.w $182,$110
	
barcop2:
	dc.w $5f01
	dc.w $fffe
	dc.w $180,$000f
	dc.w $182,$330

barcop3:
	dc.w $6001
	dc.w $fffe
	dc.w $180
fademe:	dc.w $0f0
	dc.w $182,$550

barcop4:
	dc.w $6101
	dc.w $fffe
;	dc.w $180,$004
	dc.w $182,$770	
barcop5:
	dc.w $6201
	dc.w $fffe
;	dc.w $180,$0004
	dc.w $182,$990

barcop6:
	dc.w $6301
	dc.w $fffe
;	dc.w $180,$0004
	dc.w $182,$bb0
barcop7:
	dc.w $6401
	dc.w $fffe
;	dc.w $180,$0004
	dc.w $182,$dd0

barcop8:
	dc.w $6501
	dc.w $fffe
;	dc.w $180,$0004
	dc.w $182,$ff0
barcop9:
	dc.w $6601
	dc.w $fffe
;	dc.w $180,$0004
	dc.w $182,$dd0

barcop10:
	dc.w $6701
	dc.w $fffe
;	dc.w $180,$0004
	dc.w $182,$bb0
barcop11:
	dc.w $6801
	dc.w $fffe
	dc.w $180,$000f
	dc.w $182,$990

barcop12:
	dc.w $6901
	dc.w $fffe
	dc.w $180,$0222
	dc.w $182,$999


	dc.w	$d409,$fffe,$180,$f0f		; Second purple bar 
	dc.w	$d509,$fffe,$180,$000



	dc.w	bplcon0,%0010010000000000	; 2 bitplanes, dual 
						; playfield (ooohh!)

	dc.w	bplcon2,%0000000001000000	; Bpl2 has priority
	
	dc.w bpl2pth				; Pointers for scroller
scpl2h:
	dc.w 0

	dc.w bpl2ptl				; Bitplane low word.
scpl2l:
	dc.w 0
	
	
	
	dc.w	$ffe1,$fffe			; PAL enable, doesn't
;						  NTSC piss you off?


	dc.w	$0f01,$fffe
	dc.w	bplcon0,$0200			; Get out, bitplanes!
	
	dc.w	$1501,$fffe,$180,$f0f
	dc.w	$1601,$fffe,$180,$000

**********


*	Future Composer Replay Routine. V1.0 - 1.3

*	Improved by hand from crappy Seka version

*	by Zaphod of Pendle Europa, July 1990

  
*  Jsr Init_Music  at start
*  Jsr Play_Music  in IRQ
*  Jsr End_Music   at end



Play_Music
        bra.w Play

End_Music
        clr.w onoff
        clr.l $dff0a6
        clr.l $dff0b6
        clr.l $dff0c6
        clr.l $dff0d6
        move.w #$000f,$dff096
        bclr #1,$bfe001
        rts

Init_Music
        move.w #1,onoff
        bset #1,$bfe001
        lea Module,a0
        lea 100(a0),a1
        move.l a1,SEQpoint
        move.l a0,a1
        add.l 8(a0),a1
        move.l a1,PATpoint
        move.l a0,a1
        add.l 16(a0),a1
        move.l a1,FRQpoint
        move.l a0,a1
        add.l 24(a0),a1
        move.l a1,VOLpoint
        move.l 4(a0),d0
        divu #13,d0

        lea 40(a0),a1
        lea Sound_Info+4(pc),a2
        moveq #10-1,d1
initloop:
        move.w (a1)+,(a2)+
        move.l (a1)+,(a2)+
        addq.w #4,a2
        dbf d1,initloop
        moveq #0,d2
        move.l a0,d1
        add.l 32(a0),d1
        sub.l #WaveForms,d1
        lea Sound_Info(pc),a0
        move.l d1,(a0)+
        moveq #9-1,d3
initloop1:
        move.w (a0),d2
        add.l d2,d1
        add.l d2,d1
        addq.w #6,a0
        move.l d1,(a0)+
        dbf d3,initloop1

        move.l SEQpoint(pc),a0
        moveq #0,d2
        move.b 12(a0),d2		;Get rePlay speed
        bne.s speedok
        move.b #3,d2			;Set default speed
speedok:
        move.w d2,respcnt		;Init repspeed counter
        move.w d2,repspd
INIT2:
        clr.w audtemp
        move.w #$000f,$dff096		;Disable audio DMA
        move.w #$0780,$dff09a		;Disable audio IRQ
        moveq #0,d7
        mulu #13,d0
        moveq #4-1,d6			;Number of soundchannels-1
        lea V1data(pc),a0		;Point to 1st voice data area
        lea Silent(pc),a1
        lea o4a0c8(pc),a2
initloop2:
        move.l a1,10(a0)
        move.l a1,18(a0)
        clr.l 14(a0)
        clr.b 45(a0)
        clr.b 47(a0)
        clr.w 8(a0)
        clr.l 48(a0)
        move.b #$01,23(a0)
        move.b #$01,24(a0)
        clr.b 25(a0)
        clr.l 26(a0)
        clr.w 30(a0)
        moveq #$00,d3
        move.w (a2)+,d1
        move.w (a2)+,d3
        divu #$0003,d3
        move.b d3,32(a0)
        mulu #$0003,d3
        andi.l #$00ff,d3
        andi.l #$00ff,d1
        addi.l #$dff0a0,d1
        move.l d1,a6
        move.l #$0000,(a6)
        move.w #$0100,4(a6)
        move.w #$0000,6(a6)
        move.w #$0000,8(a6)
        move.l d1,60(a0)
        clr.w 64(a0)
        move.l SEQpoint(pc),(a0)
        move.l SEQpoint(pc),52(a0)
        add.l d0,52(a0)
        add.l d3,52(a0)
        add.l d7,(a0)
        add.l d3,(a0)
        move.w #$000d,6(a0)
        move.l (a0),a3
        move.b (a3),d1
        andi.l #$00ff,d1
        lsl.w #6,d1
        move.l PATpoint(pc),a4
        adda.w d1,a4
        move.l a4,34(a0)
        clr.l 38(a0)
        move.b #$01,33(a0)
        move.b #$02,42(a0)
        move.b 1(a3),44(a0)
        move.b 2(a3),22(a0)
        clr.b 43(a0)
        clr.b 45(a0)
        clr.w 56(a0)
        adda.w #$004a,a0	;Point to next voice's data area
        dbf d6,initloop2
        rts


Play:
        lea pervol(pc),a6
        tst.w onoff
        bne.s music_on
        rts
music_on:
        subq.w #1,respcnt		;Decrease rePlayspeed counter
        bne.s nonewnote
        move.w repspd(pc),respcnt	;Restore rePlayspeed counter
        lea V1data(pc),a0		;Point to voice1 data area
        bsr.w New_Note
        lea V2data(pc),a0		;Point to voice2 data area
        bsr.w New_Note
        lea V3data(pc),a0		;Point to voice3 data area
        bsr.w New_Note
        lea V4data(pc),a0		;Point to voice4 data area
        bsr.w New_Note
nonewnote:
        clr.w audtemp
        lea V1data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea V2data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea V3data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea V4data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea pervol(pc),a6
        move.w audtemp(pc),d0
	ori.w #$8000,d0			;Set/        clr bit = 1
        move.w d0,-(a7)
        moveq #0,d1
        move.l start1(pc),d2		;Get samplepointers
        move.w offset1(pc),d1		;Get offset
        add.l d1,d2			;        add offset
        move.l start2(pc),d3
        move.w offset2(pc),d1
        add.l d1,d3
        move.l start3(pc),d4
        move.w offset3(pc),d1
        add.l d1,d4
        move.l start4(pc),d5
        move.w offset4(pc),d1
        add.l d1,d5
        move.w ssize1(pc),d0		;Get sound lengths
        move.w ssize2(pc),d1
        move.w ssize3(pc),d6
        move.w ssize4(pc),d7
        move.w (a7)+,$dff096		;Enable audio DMA
chan1:
        lea V1data(pc),a0
        tst.w 72(a0)
        beq.w chan2
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s chan2
        clr.w 72(a0)
        move.l d2,$dff0a0		;Set soundstart
        move.w d0,$dff0a4		;Set soundlength
chan2:
        lea V2data(pc),a0
        tst.w 72(a0)
        beq.s chan3
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s chan3
        clr.w 72(a0)
        move.l d3,$dff0b0
        move.w d1,$dff0b4
chan3:
        lea V3data(pc),a0
        tst.w 72(a0)
        beq.s chan4
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s chan4
        clr.w 72(a0)
        move.l d4,$dff0c0
        move.w d6,$dff0c4
chan4:
        lea V4data(pc),a0
        tst.w 72(a0)
        beq.s setpervol
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s setpervol
        clr.w 72(a0)
        move.l d5,$dff0d0
        move.w d7,$dff0d4
setpervol:
        lea $dff0a6,a5
        move.w (a6)+,(a5)	;Set period
        move.w (a6)+,2(a5)	;Set volume
        move.w (a6)+,16(a5)
        move.w (a6)+,18(a5)
        move.w (a6)+,32(a5)
        move.w (a6)+,34(a5)
        move.w (a6)+,48(a5)
        move.w (a6)+,50(a5)
        rts

New_Note:
        moveq #0,d5
        move.l 34(a0),a1
        adda.w 40(a0),a1
        cmp.w #64,40(a0)
        bne.w samepat
        move.l (a0),a2
        adda.w 6(a0),a2		;Point to next sequence row
        cmpa.l 52(a0),a2	;Is it the end?
        bne.s notend
        move.w d5,6(a0)		;yes!
        move.l (a0),a2		;Point to first sequence
notend:
        moveq #0,d1
        addq.b #1,spdtemp
        cmpi.b #4,spdtemp
        bne.s nonewspd
        move.b d5,spdtemp
        move.b -1(a1),d1	;Get new rePlay speed
        beq.s nonewspd
        move.w d1,respcnt	;store in counter
        move.w d1,repspd
nonewspd:
        move.b (a2),d1		;Pattern to Play
        move.b 1(a2),44(a0)	;Transpose value
        move.b 2(a2),22(a0)	;Soundtranspose value

        move.w d5,40(a0)
        lsl.w #6,d1
        add.l PATpoint(pc),d1	;Get pattern pointer
        move.l d1,34(a0)
        addi.w #$000d,6(a0)
        move.l d1,a1
samepat:
        move.b 1(a1),d1		;Get info byte
        move.b (a1)+,d0		;Get note
        bne.s ww1
        andi.w #%11000000,d1
        beq.s noport
        bra.s ww11
ww1:
        move.w d5,56(a0)
ww11:
        move.b d5,47(a0)
        move.b (a1),31(a0)

		;31(a0) = PORTAMENTO/INSTR. info
			;Bit 7 = portamento on
			;Bit 6 = portamento off
			;Bit 5-0 = instrument number
		;47(a0) = portamento value
			;Bit 7-5 = always zero
			;Bit 4 = up/down
			;Bit 3-0 = value
t_porton:
        btst #7,d1
        beq.s noport
        move.b 2(a1),47(a0)	
noport:
        andi.w #$007f,d0
        beq.w nextnote
        move.b d0,8(a0)
        move.b (a1),9(a0)
        move.b 32(a0),d2
        moveq #0,d3
        bset d2,d3
	or.w d3,audtemp
        move.w d3,$dff096
        move.b (a1),d1
        andi.w #$003f,d1	;Max 64 instruments
        add.b 22(a0),d1
        move.l VOLpoint(pc),a2
        lsl.w #6,d1
        adda.w d1,a2
        move.w d5,16(a0)
        move.b (a2),23(a0)
        move.b (a2)+,24(a0)
        move.b (a2)+,d1
        andi.w #$00ff,d1
        move.b (a2)+,27(a0)
        move.b #$40,46(a0)
        move.b (a2)+,d0
        move.b d0,28(a0)
        move.b d0,29(a0)
        move.b (a2)+,30(a0)
        move.l a2,10(a0)
        move.l FRQpoint(pc),a2
        lsl.w #6,d1
        adda.w d1,a2
        move.l a2,18(a0)
        move.w d5,50(a0)
        move.b d5,26(a0)
        move.b d5,25(a0)
nextnote:
        addq.w #2,40(a0)
        rts

Effects:
        moveq #0,d7
testsustain:
        tst.b 26(a0)		;Is sustain counter = 0
        beq.s sustzero
        subq.b #1,26(a0)	;if no, decrease counter
        bra.w VOLUfx
sustzero:		;Next part of effect sequence
        move.l 18(a0),a1	;can be executed now.
        adda.w 50(a0),a1
testEffects:
        cmpi.b #$e1,(a1)	;E1 = end of FREQseq sequence
        beq.w VOLUfx
        cmpi.b #$e0,(a1)	;E0 = loop to other part of sequence
        bne.s testnewsound
        move.b 1(a1),d0		;loop to start of sequence + 1(a1)
        andi.w #$003f,d0
        move.w d0,50(a0)
        move.l 18(a0),a1
        adda.w d0,a1
testnewsound:
        cmpi.b #$e2,(a1)	;E2 = set waveform
        bne.s o49c64
        moveq #0,d0
        moveq #0,d1
        move.b 32(a0),d1
        bset d1,d0
	or.w d0,audtemp
        move.w d0,$dff096
        move.b 1(a1),d0
        andi.w #$00ff,d0
        lea Sound_Info(pc),a4
        add.w d0,d0
        move.w d0,d1
        add.w d1,d1
        add.w d1,d1
        add.w d1,d0
        adda.w d0,a4
        move.l 60(a0),a3
        move.l (a4),d1
        add.l #WaveForms,d1
        move.l d1,(a3)
        move.l d1,68(a0)
        move.w 4(a4),4(a3)
        move.l 6(a4),64(a0)
	swap d1
        move.w #$0003,72(a0)
        tst.w d1
        bne.s o49c52
        move.w #$0002,72(a0)
o49c52:
        clr.w 16(a0)
        move.b #$01,23(a0)
        addq.w #2,50(a0)
        bra.w o49d02
o49c64:
        cmpi.b #$e4,(a1)
        bne.s testpatjmp
        move.b 1(a1),d0
        andi.w #$00ff,d0
        lea Sound_Info(pc),a4
        add.w d0,d0
        move.w d0,d1
        add.w d1,d1
        add.w d1,d1
        add.w d1,d0
        adda.w d0,a4
        move.l 60(a0),a3
        move.l (a4),d1
        add.l #WaveForms,d1
        move.l d1,(a3)
        move.l d1,68(a0)
        move.w 4(a4),4(a3)
        move.l 6(a4),64(a0)

	swap d1
        move.w #$0003,72(a0)
        tst.w d1
        bne.s o49cae
        move.w #$0002,72(a0)
o49cae:
        addq.w #2,50(a0)
        bra.s o49d02
testpatjmp:
        cmpi.b #$e7,(a1)
        bne.s testnewsustain
        move.b 1(a1),d0
        andi.w #$00ff,d0
        lsl.w #6,d0
        move.l FRQpoint(pc),a1
        adda.w d0,a1
        move.l a1,18(a0)
        move.w d7,50(a0)
        bra.w testEffects
testnewsustain:
        cmpi.b #$e8,(a1)	;E8 = set sustain time
        bne.s o49cea
        move.b 1(a1),26(a0)
        addq.w #2,50(a0)
        bra.w testsustain
o49cea:
        cmpi.b #$e3,(a1)
        bne.s o49d02
        addq.w #3,50(a0)
        move.b 1(a1),27(a0)
        move.b 2(a1),28(a0)
o49d02:
        move.l 18(a0),a1
        adda.w 50(a0),a1
        move.b (a1),43(a0)
        addq.w #1,50(a0)
VOLUfx:
        tst.b 25(a0)
        beq.s o49d1e
        subq.b #1,25(a0)
        bra.s o49d70
o49d1e:
        subq.b #1,23(a0)
        bne.s o49d70
        move.b 24(a0),23(a0)
o49d2a:
        move.l 10(a0),a1
        adda.w 16(a0),a1
        move.b (a1),d0
        cmpi.b #$e8,d0
        bne.s o49d4a
        addq.w #2,16(a0)
        move.b 1(a1),25(a0)
        bra.s VOLUfx
o49d4a:
        cmpi.b #$e1,d0
        beq.s o49d70
        cmpi.b #$e0,d0
        bne.s o49d68
        move.b 1(a1),d0
        andi.l #$003f,d0
        subq.b #5,d0
        move.w d0,16(a0)
        bra.s o49d2a
o49d68:
        move.b (a1),45(a0)
        addq.w #1,16(a0)
o49d70:
        move.b 43(a0),d0
	bmi.s o49d7e
        add.b 8(a0),d0
        add.b 44(a0),d0
o49d7e:
        andi.w #$007f,d0
        lea PERIODS(pc),a1
        add.w d0,d0
        move.w d0,d1
        adda.w d0,a1
        move.w (a1),d0
        move.b 46(a0),d7
        tst.b 30(a0)
        beq.s o49d9e
        subq.b #1,30(a0)

        bra.s o49df4
o49d9e:
        move.b d1,d5
        move.b 28(a0),d4
        add.b d4,d4
        move.b 29(a0),d1
        tst.b d7
	bpl.s o49db4
        btst #0,d7
        bne.s o49dda
o49db4:
        btst #5,d7
        bne.s o49dc8
        sub.b 27(a0),d1
	bcc.s o49dd6
        bset #5,d7
        moveq #0,d1
        bra.s o49dd6
o49dc8:
        add.b 27(a0),d1
        cmp.b d4,d1
	bcs.s o49dd6
        bclr #5,d7
        move.b d4,d1
o49dd6:
        move.b d1,29(a0)
o49dda:
	lsr.b #1,d4
        sub.b d4,d1
	bcc.s o49de4
        subi.w #$0100,d1
o49de4:
        addi.b #$a0,d5
	bcs.s o49df2
o49dea:
        add.w d1,d1
        addi.b #$18,d5
	bcc.s o49dea
o49df2:
        add.w d1,d0
o49df4:
	eori.b #$01,d7
        move.b d7,46(a0)

; DO THE PORTAMENTO THING
        moveq #0,d1
        move.b 47(a0),d1	;get portavalue
        beq.s a56d0		;0=no portamento
        cmpi.b #$1f,d1
	bls.s portaup
portadown: 
        andi.w #$1f,d1
	neg.w d1
portaup:
        sub.w d1,56(a0)
a56d0:
        add.w 56(a0),d0
o49e3e:
        cmpi.w #$0070,d0
	bhi.s nn1
        move.w #$0071,d0
nn1:
        cmpi.w #$06b0,d0
	bls.s nn2
        move.w #$06b0,d0
nn2:
        moveq #0,d1
        move.b 45(a0),d1
        rts



pervol: dcb.b 16,0	;Periods & Volumes temp. store
respcnt: dc.w 0		;RePlay speed counter 
repspd:  dc.w 0		;RePlay speed counter temp
onoff:   dc.w 0		;Music on/off flag.
firseq:	 dc.w 0		;First sequence
lasseq:	 dc.w 0		;Last sequence
audtemp: dc.w 0
spdtemp: dc.w 0

V1data:  dcb.b 64,0	;Voice 1 data area
offset1: dcb.b 02,0	;Is         added to start of sound
ssize1:  dcb.b 02,0	;Length of sound
start1:  dcb.b 06,0	;Start of sound

V2data:  dcb.b 64,0	;Voice 2 data area
offset2: dcb.b 02,0
ssize2:  dcb.b 02,0
start2:  dcb.b 06,0

V3data:  dcb.b 64,0	;Voice 3 data area
offset3: dcb.b 02,0
ssize3:  dcb.b 02,0
start3:  dcb.b 06,0

V4data:  dcb.b 64,0	;Voice 4 data area
offset4: dcb.b 02,0
ssize4:  dcb.b 02,0
start4:  dcb.b 06,0

o4a0c8: dc.l $00000000,$00100003,$00200006,$00300009
SEQpoint: dc.l 0
PATpoint: dc.l 0
FRQpoint: dc.l 0
VOLpoint: dc.l 0


        even
Silent  dc.w $0100,$0000,$0000,$00e1

PERIODS dc.w $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
	dc.w $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
	dc.w $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
	dc.w $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
	dc.w $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
	dc.w $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
	dc.w $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
	dc.w $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
	dc.w $10d0,$0fe0,$0f00,$0e28

Sound_Info:
;Offset.l , Sound-length.w , Start-offset.w , Repeat-length.w 

;Reserved for samples
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
;Reserved for synth sounds
	dc.w $0000,$0000,$0010,$0000,$0010 
	dc.w $0000,$0020,$0010,$0000,$0010 
	dc.w $0000,$0040,$0010,$0000,$0010 
	dc.w $0000,$0060,$0010,$0000,$0010 
	dc.w $0000,$0080,$0010,$0000,$0010 
	dc.w $0000,$00a0,$0010,$0000,$0010 
	dc.w $0000,$00c0,$0010,$0000,$0010 
	dc.w $0000,$00e0,$0010,$0000,$0010 
	dc.w $0000,$0100,$0010,$0000,$0010 
	dc.w $0000,$0120,$0010,$0000,$0010 
	dc.w $0000,$0140,$0010,$0000,$0010 
	dc.w $0000,$0160,$0010,$0000,$0010 
	dc.w $0000,$0180,$0010,$0000,$0010 
	dc.w $0000,$01a0,$0010,$0000,$0010 
	dc.w $0000,$01c0,$0010,$0000,$0010 
	dc.w $0000,$01e0,$0010,$0000,$0010 
	dc.w $0000,$0200,$0010,$0000,$0010 
	dc.w $0000,$0220,$0010,$0000,$0010 
	dc.w $0000,$0240,$0010,$0000,$0010 
	dc.w $0000,$0260,$0010,$0000,$0010 
	dc.w $0000,$0280,$0010,$0000,$0010 
	dc.w $0000,$02a0,$0010,$0000,$0010 
	dc.w $0000,$02c0,$0010,$0000,$0010 
	dc.w $0000,$02e0,$0010,$0000,$0010 
	dc.w $0000,$0300,$0010,$0000,$0010 
	dc.w $0000,$0320,$0010,$0000,$0010 
	dc.w $0000,$0340,$0010,$0000,$0010 
	dc.w $0000,$0360,$0010,$0000,$0010 
	dc.w $0000,$0380,$0010,$0000,$0010 
	dc.w $0000,$03a0,$0010,$0000,$0010 
	dc.w $0000,$03c0,$0010,$0000,$0010 
	dc.w $0000,$03e0,$0010,$0000,$0010 
	dc.w $0000,$0400,$0008,$0000,$0008 
	dc.w $0000,$0410,$0008,$0000,$0008 
	dc.w $0000,$0420,$0008,$0000,$0008 
	dc.w $0000,$0430,$0008,$0000,$0008 
	dc.w $0000,$0440,$0008,$0000,$0008
	dc.w $0000,$0450,$0008,$0000,$0008
	dc.w $0000,$0460,$0008,$0000,$0008
	dc.w $0000,$0470,$0008,$0000,$0008
	dc.w $0000,$0480,$0010,$0000,$0010
	dc.w $0000,$04a0,$0008,$0000,$0008
	dc.w $0000,$04b0,$0010,$0000,$0010
	dc.w $0000,$04d0,$0010,$0000,$0010
	dc.w $0000,$04f0,$0008,$0000,$0008
	dc.w $0000,$0500,$0008,$0000,$0008
	dc.w $0000,$0510,$0018,$0000,$0018
 

WaveForms:
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $3f37,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c037,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b027,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a017,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9007,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8007,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9017,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a027,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$b037
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$817f,$7f7f
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$7f7f
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$807f
        dc.w $8080,$8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
        dc.w $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
        dc.w $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070
        dc.w $4545,$797d,$7a77,$7066,$6158,$534d,$2c20,$1812
        dc.w $04db,$d3cd,$c6bc,$b5ae,$a8a3,$9d99,$938e,$8b8a
        dc.w $4545,$797d,$7a77,$7066,$5b4b,$4337,$2c20,$1812
        dc.w $04f8,$e8db,$cfc6,$beb0,$a8a4,$9e9a,$9594,$8d83
        dc.w $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
        dc.w $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
        dc.w $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
        dc.w $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
        dc.w $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070


	
sinscroll:

; first blit clear the scrolly

	lea scrollplane+10*40,a0		; visible bitplane
blitclear2:
	btst #14,$dff002		
	bne.s blitclear2		; wait till blitter ready

	move.l a0,$dff054		; source address
	move.l a0,$dff050		; destination address
	clr.l $dff044			; no FWM/LWM (see hardware manual)
	clr.l $dff064			; no MODULO (see hardware manual)

	move.w #%100000000,$dff040 	; Enable DMA channel D, nothing
					; else, no minterms active. 
	clr.w $dff042			; nothing set in BLTCON1
	move.w #40*64+21,$dff058
					; Window size = 21 words wide
					; 32 lines deep

continuesine:
	move.l sinpt,a3
	subq.l #1,a3
	move.b (a3),d0
	cmp.b #255,d0
	bne.s notendofsine
	lea sintabend(pc),a3
notendofsine:
	move.l a3,sinpt

	moveq #19,d0
	lea scplane2,a0
	lea scrollplane+10*40,a1

sloop3:

	bsr getsinval

blitready2
	btst #14,$dff002
	bne.s blitready2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l #$f000f000,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #%0000100111110000,$dff040
	clr.w $dff042
	move.w #TextHeight*64+1,$dff058

	bsr getsinval

zonk2:
	btst #14,$dff002
	bne zonk2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f00,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
 	clr.w $dff042
	move.w #TextHeight*64+1,$dff058

	bsr getsinval
zonk3:
	btst #14,$dff002
	bne zonk3

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f0,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #TextHeight*64+1,$dff058

	bsr getsinval
zonk4:
	btst #14,$dff002
	bne zonk4
	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #TextHeight*64+1,$dff058



	addq.l #2,a0
LOAD	addq.l #2,a1
	dbra d0,sloop3

rts

getsinval:
	moveq #0,d1
	move.b (a3)+,d1
	move.b (a3),d2
	cmp.b #255,d2
	bne okyar
	move.l #sintab,a3
okyar:
	lsr.b #2,d1
	bclr #0,d1
	mulu #20,d1
	move.l a1,a2
	add.l d1,a2

	rts

scrolly: 
	
	bsr	sinscroll	; Perform sine movement 

yesscrolly:
	move.b pause,d0
	cmp.b #0,d0		; Is the pause over?
	beq gopast		; Yes, then move scroll left
	subq.b #1,d0
	move.b d0,pause
	bra gopast2
gopast:
	move.l #scplane2,a0
	move.l #scplane2+2,a1

blitready3:
	btst #14,$dff002
	bne blitready3
	move.l a0,$dff054
	move.l a1,$dff050
	move.l #-1,$dff044
	clr.l $dff064
	move.w #%1100100111110000,$dff040
	clr.w $dff042
	move.w #TextHeight*64+23,$dff058
gopast2:
	move.b pause,d0
	cmp.b #0,d0		; Is the pause over?
	bne iuo			; No, then return

	move.b countdown,d0
	subq.b #1,d0
	cmp.b #0,d0
	beq mfc
	move.b d0,countdown
iuo:
	rts
	

mfc:
	move.b #4,countdown
	clr.w scplane2+40
	clr.w scplane2+82
	move.l #scplane2+124,a1
	bsr CHARADDRESS

	moveq #15,d0
zonkin:
	move.w (a0),(a1)
	lea 40(a0),a0
	lea 42(a1),a1
	dbf d0,zonkin

	rts
CHARADDRESS:
	move.l mesptr,a0
	moveq #0,d0
	move.l d0,d1
	move.l d0,d2
	move.b (a0)+,d0
	cmp.b #$0a,d0
	bne wizy
	move.b #32,d0
wizy:
	cmp.b #120,d0		; Is it an 'x'?
	bne wazy		; No, then continue
	move.l #message,a0	; Restart the scroll
	move.b #32,d0		; Put a space in first...
wazy:
	cmp.b #97,d0		; Is it an 'a'?
	bne wozy		; No, then continue
	move.b #32,d0
	move.b #$60,pause	; Set the countdown to $60...
wozy:
	move.l a0,mesptr

	sub.b #32,d0 
 	moveq #0,d1
 	divu #20,d0  		; 20 chars on each line
 	move.b d0,d1 
 	clr.w d0
 	swap d0  
	move.l #fnt2,a0
	mulu #640,d1
	add.l d0,d0
	add.l d0,a0
	add.l d1,a0

	rts

*****************

; Fade the copper bar bit.....

fadedown:			; Every 5 frames

	add.b	#1,fadecount
	cmp.b	#5,fadecount
	beq	yesfadedown
	rts
	
yesfadedown:
	move.b	#0,fadecount
	cmp.b	#1,fadeflag
	bne	fadeup

	sub.w	#$010,fademe	; Darken the bar
	
	cmp.w	#$000,fademe	; Is it black?	
	bne	leavefade	; No, so return
	move.b	#0,fadeflag
	bra	leavefade


fadeup:
	add.w	#$010,fademe	; Lighten the bar
	cmp.w	#$0a0,fademe	; Is it at its brightest?
	bne	leavefade	; No, so return
	move.b	#1,fadeflag

leavefade:
	rts

*******************

; Let's have some variables etc. to finish with...

fadeflag:	dc.b	1
fadecount:	dc.b	0
mesptr: dc.l message
message:
      
        ;012345678901234567890
        ; Lowercase 'a' to pause
        ; Lowercase 'x' to finish.....
       
 DC.B	"     MASTER BEAT     a   PRESENTS.......      "
 DC.B	"   THE MASTER MENU   a  WITH 3 METHODS OF INPUT  -  "
 DC.B	"MOUSE : LEFT BUTTON SELECTS, RIGHT BUTTON QUITS     "
 DC.B	"JOYSTICK : FIRE BUTTON SELECTS, 'ESC' KEY QUITS     "
 DC.B	"KEYBOARD : CURSOR UP & DOWN, 'RETURN' SELECTS, 'ESC' KEY "
 DC.B	"QUITS.       CREDITS : LE CODING ET LE GFX PAR MOI, AVEC LA MUSIQUE "
 DC.B	"PAR LE REBELS.   THANKS TO NEIL JOHNSTON, MARK FLEMANS, AND BLAINE EVANS "
 DC.B	"BECAUSE I HAVE USED SNIPPETS OF THEIR CODE.  (HAH! SNIPPETS!)     "
 DC.B	"ANYWAY, I WON'T WAFFLE ON, SO STAY COOL, HAVE FUN, UNITY IN '91!         "    
 DC.B 	"               x"
 	even

scrollplane: 	ds.b 4000
scplane2: 	ds.b 2500

_Screen	dc.l	0

GFXNAME		DC.B	'graphics.library',0
		EVEN
DOSNAME		DC.B	'dos.library',0
		EVEN
GFXBASE		DC.L	0
DOSBASE		DC.L	0
STPOINT		DC.L	0
DMASAVE		DC.W	0
INTENSAVE	DC.W	0
INTRQSAVE	DC.W	0
DELAY		DC.W	0
HCOUNT		DC.W	0
STRTPOS		DC.L	0
LINESTRT	DC.L	0
DELAY2		DC.W	0
HCOUNT2		DC.W	0
STRTPOS2	DC.L	0
LINESTRT2	DC.L	0
progcount	dc.b	1
OldMouseY	Dc.b	0
OldMouseX	Dc.b	0
mousecount	dc.b	0	
joycount	dc.b	0
rawcount	dc.b	0

		EVEN


CONHD	DC.L	0
	EVEN
CONNAM	DC.B	"CON:0/10/640/236/Stay cool, have fun, UNITY in'91...",0
	EVEN
FKEY	DC.B	0
	EVEN

;	THIS IS THE LIST OF COMMANDS TO BE EXECUTED. PUT WHATEVER NAMES
;	YOU WANT IN HERE!

; 	'0' = end of string, '10' = return, eg:
;	"balls",10,"bobs",0  would run "balls" then "bobs"
 
COM1	DC.B	"1",0
	EVEN		
COM2	DC.B	"2",0
	EVEN
COM3	DC.B	"3",0
	EVEN
COM4	DC.B	"4",0
	EVEN
COM5	DC.B	"5",0
	EVEN
COM6	DC.B	"6",0
	EVEN
COM7	DC.B	"7",0
	EVEN
COM8	DC.B	"8",0
	EVEN
COM9	DC.B	"9",0
	EVEN
COM10	DC.B	"10",0
	EVEN
COM11	DC.B	"11",0
	EVEN
COM12	DC.B	"12",0
	EVEN
	


**********

; The Menu text....

*	REMEMBER: SMALL FUNCTION CHARS WILL APPEAR AS SPACES ON SCREEN.

*	COMMANDS: 	'f' --> FAST
*			's' --> SLOW
*			'x' --> END TEXT
*	ENTER ALL TEXT IN CAPITALS!
**********

* TEXT WIDTH:	'1234567890123456789012345678901234567890'

TEXT	
	DC.B	'f           PROGRAM ONE                 '
	DC.B	'            PROGRAM TWO                 '
	DC.B	'            PROGRAM THREE               '
	DC.B	'            PROGRAM FOUR                '	
	DC.B	'            PROGRAM FIVE                '
	DC.B	'            PROGRAM SIX                 '
	DC.B	'            PROGRAM SEVEN               '
	DC.B	'            PROGRAM EIGHT               '
	DC.B	'            PROGRAM NINE                '
	DC.B	'            PROGRAM TEN                 '
	dc.b	'            PROGRAM ELEVEN              '
	dc.b	'            PROGRAM TWELVE              '
	dc.b	'                                        '
	dc.b	'                                        '
	dc.b	'----------------------------------------'
	dc.b	'                                        '
	dc.b	'     THIS IS A UNITY RELEASE IN 1991    '
	dc.b	'                                        '
	dc.b	'----------------------------------------'
	dc.b	'                                       x'
	EVEN

	
**********


SCREEN	DCB.B	8000,0
	EVEN

countdown:
	dc.b 4,0

sinpt: 	dc.l sintabend		
sinpt2: dc.l sintab2

eqtab	ds.b 40

 	dc.b 255

sintab:			; As calculated by Cosaque


	dc.b	-56,-56,-57,-58,-59,-61,-63,-66
	dc.b	-68,-72,-75,-79,-83,-88,-92,-97
	dc.b	-102,-108,-113,-119,-125,125,119,113
	dc.b	106,100,94,87,81,75,69,63
	dc.b	57,52,46,41,36,32,27,23
	dc.b	19,16,12,10,7,5,3,2
	dc.b	1,0,0,0,1,2,3,5
	dc.b	7,10,12,16,19,23,27,32
	dc.b	36,41,46,52,57,63,69,75
	dc.b	81,87,94,100,106,113,119,125
	dc.b	-125,-119,-113,-108,-102,-97,-92,-88
	dc.b	-83,-79,-75,-72,-68,-66,-63,-61
	dc.b	-59,-58,-57,-56


sintabend:
 dc.b -56,255		; The first value is the end for the
 			; above table


sintab2:		; Don't know what this does......??

 dc.b $2D,$31,$34,$38,$3B,$3E,$41,$45,$47,$4A,$4D,$4F,$51,$53,$55,$57
 dc.b $58,$59,$59,$5A,$5A,$5A,$59,$59,$58,$57,$55,$53,$51,$4F,$4D,$4A
 dc.b $47,$45,$41,$3E,$3B,$38,$34,$31,$2D,$29,$26,$22,$1F,$1C,$19,$15
 dc.b $13,$10,$D,$B,$9,$7,$5,$3,$2,$1,$1,$0,$0,$0,$1,$1,$2,$3,$5,$7,$9
 dc.b $B,$D,$10,$13,$15,$19,$1C,$1F,$22,$26,$29,$ff

pause: 	dc.b 0
sinmodulo:
	dc.b 0
 	even

*****************

; The binaries......

Module	incbin	source:modules/rebels
LOGO	INCBIN	source:bitmaps/mblogo9		Main 2 Bitplane logo
fnt2 	incbin 	source:fonts/16font3		
font	INCBIN	source:fonts/nice8x8font

	EVEN
	
*****************
