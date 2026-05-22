
		LIST
*** Input.i v1.00, by M.Meany ***
		NOLIST


; Returns ASCII code of any key being pressed, 0 if no key

GetChar		lea		KCTable,a0	a0->lookup table

		bsr		GetKey		get raw key code
		move.b		0(a0,d0),d0	convert to ASCII

		rts		


; Waits for a keypress and returns ASCII value in d0

WaitForChar	lea		KCTable,a0	a0->lookup table

GetCharLoop	bsr		GetKey		get raw key code
		move.b		0(a0,d0),d0	convert to ASCII
		beq.s		GetCharLoop	loop if not a legal char

		rts		

; Returns current state of keyboard

GetKey		moveq.l		#0,d0		clear the register
		move.b		CIAASP,d0	get value from CIA chip
		not.b		d0		manipulate it to form raw
		ror.b		#1,d0		key code

		rts

; Subroutine to read joystick movement in port 0. Returns a code in register
;d2 according to the following:

;       bit 0 set = right movement
;       bit 1 set = left movement
;       bit 2 set = down movemwnt
;       bit 3 set = up movement

; Assumes a5 -> hardware registers ( ie a5 = $dff000 ).

; Corrupts d0, d1 and d2.

ReadJoy0        moveq.l         #0,d0                   clear
                move.l          d0,d2
                move.w          JOY0DAT(a5),d0          read stick

                btst            #1,d0                   right ?
                beq.s           J0left                  if not jump!

                or.w            #1,d2                   set right bit

J0left          btst            #9,d0                   left ?
                beq.s           J1updown                if not jump

                or.w            #2,d2                   set left bit

J1updown        move.l          d0,d1                   copy JOY1DAT
                lsr.w           #1,d1                   shift u/d bits
                eor.w           d1,d0                   exclusive or 'em
                btst            #0,d0                   down ?
                beq.s           J1down                  if not jump

                or.w            #4,d2                   set down bit

J1down          btst            #8,d0                   up ?
                beq.s           J1Nojoy                 if not jump

                or.w            #8,d2                   set up bit

J1Nojoy         move.l		d2,d0
		rts


; Subroutine to read joystick movement in port 1. Returns a code in register
;d2 according to the following:

;       bit 0 set = right movement
;       bit 1 set = left movement
;       bit 2 set = down movemwnt
;       bit 3 set = up movement

; Assumes a5 -> hardware registers ( ie a5 = $dff000 ).

; Corrupts d0, d1 and d2.

ReadJoy1        moveq.l         #0,d0                   clear
                move.l          d0,d2
                move.w          JOY1DAT(a5),d0          read stick

                btst            #1,d0                   right ?
                beq.s           Jleft                   if not jump!

                or.w            #1,d2                   set right bit

Jleft           btst            #9,d0                   left ?
                beq.s           Jupdown                 if not jump

                or.w            #2,d2                   set left bit

Jupdown         move.l          d0,d1                   copy JOY1DAT
                lsr.w           #1,d1                   shift u/d bits
                eor.w           d1,d0                   exclusive or 'em
                btst            #0,d0                   down ?
                beq.s           Jdown                   if not jump

                or.w            #4,d2                   set down bit

Jdown           btst            #8,d0                   up ?
                beq.s           JNojoy                  if not jump

                or.w            #8,d2                   set up bit

JNojoy          move.l		d2,d0
		rts

; Subroutine that returns X and Y increment values for Mouse in Port 0. The
;values may need to be scaled ( ie asl.w #1,Dn ) for sensible values on a
;low resolution screen. This routine must be called every VBI if used, else
;the tracked mouse values make no sense! You could simply test if the values
;are +ve or -ve and move 1 pixel accordingly, though this may make mouse
;moves a little slow!

; Exit		d0.w= X increment value
;		d1.w= Y increment value

; Corrupt	d0,d1,d2,d3 and d4

SeeMouse	move.w		JOY0DAT(a5),d0		get movement counters

		move.w		d0,d1			copy
		
		and.w		#$ff,d0			isolate x counter
		and.w		#$ff00,d1		isolate y counter
		lsr.w		#8,d1			y count into low byte

		move.w		SMmx,d2			get last x counter
		move.w		SMmy,d3			get last y counter

		move.w		d0,SMmx			save current x count
		move.w		d1,SMmy			save current y count

		move.w		d2,d4			x counter
		sub.b		d0,d4			x - Old x
		bsr		DoDiff			over/under flow adjust
		move.w		d4,d0			d0 = x inc value
		
		move.w		d3,d4			y counter
		sub.b		d1,d4			y - Old y
		bsr		DoDiff			over/under flow adjust
		move.w		d4,d1			d1 = y inc value
		
SMDone		rts					exit!

; Routine to correct for overflow and underflow

DoDiff		move.w		d4,d2			get difference
		bpl.s		SMPos			skip if +ve
		neg.b		d2			else make it +ve

SMPos		cmp.b		#127,d2			over/under flow?
		ble.s		SMNoAdjust		skip if not
		add.b		#255,d4			else adjust!

SMNoAdjust	ext.w		d4			extend to word value
		neg.w		d4			correct sign
		rts					and exit

SMmx		dc.w		0
SMmy		dc.w		0

; Raw key code to ASCII lookup table. Use raw key code to act as offset into
;this table. Any non-alphanumeric value will get a 0 return which implies an
;invalid keystroke. See comments for raw codes of special keys, such as
;the function keys, Esc, Del etc.

KCTable	dc.b	"'"	$00
	dc.b	'1'	$01
	dc.b	'2'	$02
	dc.b	'3'	$03
	dc.b	'4'	$04
	dc.b	'5'	$05
	dc.b	'6'	$06
	dc.b	'7'	$07
	dc.b	'8'	$08
	dc.b	'9'	$09
	dc.b	'0'	$0A
	dc.b	'-'	$0B
	dc.b	'='	$0C
	dc.b	'\'	$0D
	dc.b	0	$0E
	dc.b	'0'	$0F	numeric keypad
	dc.b	'Q'	$10	
	dc.b	'W'	$11
	dc.b	'E'	$12
	dc.b	'R'	$13
	dc.b	'T'	$14
	dc.b	'Y'	$15
	dc.b	'U'	$16
	dc.b	'I'	$17
	dc.b	'O'	$18
	dc.b	'P'	$19
	dc.b	'['	$1A
	dc.b	']'	$1B
	dc.b	0	$1C
	dc.b	'1'	$1D	numeric keypad
	dc.b	'2'	$1E	numeric keypad
	dc.b	'3'	$1F	numeric keypad
	dc.b	'A'	$20
	dc.b	'S'	$21
	dc.b	'D'	$22
	dc.b	'F'	$23
	dc.b	'G'	$24
	dc.b	'H'	$25
	dc.b	'J'	$26
	dc.b	'K'	$27
	dc.b	'L'	$28
	dc.b	';'	$29
	dc.b	'#'	$2A
	dc.b	0	$2B	BLANK KEY ON A1200 NEAR RETURN
	dc.b	0	$2C
	dc.b	'4'	$2D	numeric keypad
	dc.b	'5'	$2E	numeric keypad
	dc.b	'6'	$2F	numeric keypad
	dc.b	0	$30	BLANK KEY ON A1200 NEAR Caps Lock
	dc.b	'Z'	$31
	dc.b	'X'	$32
	dc.b	'C'	$33
	dc.b	'V'	$34
	dc.b	'B'	$35
	dc.b	'N'	$36
	dc.b	'M'	$37
	dc.b	','	$38
	dc.b	'.'	$39
	dc.b	'/'	$3A
	dc.b	0	$3B
	dc.b	'.'	$3C	numeric keypad
	dc.b	'7'	$3D	numeric keypad
	dc.b	'8'	$3E	numeric keypad
	dc.b	'9'	$3F	numeric keypad
	dc.b	' '	$40
	dc.b	0	$41	Backspace
	dc.b	$09	$42	TAB
	dc.b	$0a	$43	Enter on numeric keypad
	dc.b	$0a	$44	Return
	dc.b	0	$45	Esc
	dc.b	0	$46	Del
	dc.b	0	$47
	dc.b	0	$48
	dc.b	0	$49
	dc.b	'-'	$4A	numeric keypad
	dc.b	0	$4B
	dc.b	0	$4C	Up Arrow
	dc.b	0	$4D	Down Arrow
	dc.b	0	$4E	Right Arrow
	dc.b	0	$4F	Left Arrow
	dc.b	0	$50	F1
	dc.b	0	$51	F2
	dc.b	0	$52	F3
	dc.b	0	$53	F4
	dc.b	0	$54	F5
	dc.b	0	$55	F6
	dc.b	0	$56	F7
	dc.b	0	$57	F8
	dc.b	0	$58	F9
	dc.b	0	$59	F10
	dc.b	'('	$5A	numeric keypad
	dc.b	')'	$5B	numeric keypad
	dc.b	'/'	$5C	numeric keypad
	dc.b	'*'	$5D	numeric keypad
	dc.b	'+'	$5E	numeric keypad
	dc.b	0	$5F	Help
	dc.b	0	$60	Left Shift Key
	dc.b	0	$61	Right Shift Key
	dc.b	0	$62	Caps Lock
	dc.b	0	$63	Ctrl
	dc.b	0	$64	Left Alt
	dc.b	0	$65	Right Alt
	dc.b	0	$66	Left Amiga
	dc.b	0	$67	Right Amiga
	dc.b	0	$68
	dc.b	0	$69
	dc.b	0	$6A
	dc.b	0	$6B
	dc.b	0	$6C
	dc.b	0	$6D
	dc.b	0	$6E
	dc.b	0	$6F
	dc.b	0	$70
	dc.b	0	$71
	dc.b	0	$72
	dc.b	0	$73
	dc.b	0	$74
	dc.b	0	$75
	dc.b	0	$76
	dc.b	0	$77
	dc.b	0	$78
	dc.b	0	$79
	dc.b	0	$7A
	dc.b	0	$7B
	dc.b	0	$7C
	dc.b	0	$7D
	dc.b	0	$7E
	dc.b	0	$7F
	dc.b	0	$80
	dc.b	0	$81
	dc.b	0	$82
	dc.b	0	$83
	dc.b	0	$84
	dc.b	0	$85
	dc.b	0	$86
	dc.b	0	$87
	dc.b	0	$88
	dc.b	0	$89
	dc.b	0	$8A
	dc.b	0	$8B
	dc.b	0	$8C
	dc.b	0	$8D
	dc.b	0	$8E
	dc.b	0	$8F
	dc.b	0	$90
	dc.b	0	$91
	dc.b	0	$92
	dc.b	0	$93
	dc.b	0	$94
	dc.b	0	$95
	dc.b	0	$96
	dc.b	0	$97
	dc.b	0	$98
	dc.b	0	$99
	dc.b	0	$9A
	dc.b	0	$9B
	dc.b	0	$9C
	dc.b	0	$9D
	dc.b	0	$9E
	dc.b	0	$9F
	dc.b	0	$A0
	dc.b	0	$A1
	dc.b	0	$A2
	dc.b	0	$A3
	dc.b	0	$A4
	dc.b	0	$A5
	dc.b	0	$A6
	dc.b	0	$A7
	dc.b	0	$A8
	dc.b	0	$A9
	dc.b	0	$AA
	dc.b	0	$AB
	dc.b	0	$AC
	dc.b	0	$AD
	dc.b	0	$AE
	dc.b	0	$AF
	dc.b	0	$B0
	dc.b	0	$B1
	dc.b	0	$B2
	dc.b	0	$B3
	dc.b	0	$B4
	dc.b	0	$B5
	dc.b	0	$B6
	dc.b	0	$B7
	dc.b	0	$B8
	dc.b	0	$B9
	dc.b	0	$BA
	dc.b	0	$BB
	dc.b	0	$BC
	dc.b	0	$BD
	dc.b	0	$BE
	dc.b	0	$BF
	dc.b	0	$C0
	dc.b	0	$C1
	dc.b	0	$C2
	dc.b	0	$C3
	dc.b	0	$C4
	dc.b	0	$C5
	dc.b	0	$C6
	dc.b	0	$C7
	dc.b	0	$C8
	dc.b	0	$C9
	dc.b	0	$CA
	dc.b	0	$CB
	dc.b	0	$CC
	dc.b	0	$CD
	dc.b	0	$CE
	dc.b	0	$CF
	dc.b	0	$D0
	dc.b	0	$D1
	dc.b	0	$D2
	dc.b	0	$D3
	dc.b	0	$D4
	dc.b	0	$D5
	dc.b	0	$D6
	dc.b	0	$D7
	dc.b	0	$D8
	dc.b	0	$D9
	dc.b	0	$DA
	dc.b	0	$DB
	dc.b	0	$DC
	dc.b	0	$DD
	dc.b	0	$DE
	dc.b	0	$DF
	dc.b	0	$E0
	dc.b	0	$E1
	dc.b	0	$E2	Caps Lock OFF
	dc.b	0	$E3
	dc.b	0	$E4
	dc.b	0	$E5
	dc.b	0	$E6
	dc.b	0	$E7
	dc.b	0	$E8
	dc.b	0	$E9
	dc.b	0	$EA
	dc.b	0	$EB
	dc.b	0	$EC
	dc.b	0	$ED
	dc.b	0	$EE
	dc.b	0	$EF
	dc.b	0	$F0
	dc.b	0	$F1
	dc.b	0	$F2
	dc.b	0	$F3
	dc.b	0	$F4
	dc.b	0	$F5
	dc.b	0	$F6
	dc.b	0	$F7
	dc.b	0	$F8
	dc.b	0	$F9
	dc.b	0	$FA
	dc.b	0	$FB
	dc.b	0	$FC
	dc.b	0	$FD
	dc.b	0	$FE
	even
