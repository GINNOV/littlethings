;*******************************************************
;*    SystemStartUp example that opens a screen and    *
;*          enables you to read the keyboard           *
;*                                                     *
;*      AsmOne example coded by Rune Gram-Madsen       *
;*                                                     *
;*       All rights reserved. Copyright (c) 1990       *
;*******************************************************

; This will draw a Julia fractal picture. This has been implemented
; just to show something beautifull on the screen. Remove that from
; the source and insert your own routines here instead.

; This example could have been coded shorter using includefiles. But
; I think it is nice to have it all in one single program.

; Write 200 here if you live in the US..!!!

ScreenHeight = 256	; 200 if in US

IECLASS_RAWKEY = $01
OPENLIB =	-408
CLOSELIB =	-414
OPENSCREEN =	-198
CLOSESCREEN =	-66
OPENWINDOW =	-204
CLOSEWINDOW =	-72
OPENDEVICE =	-444
CLOSEDEVICE =	-450
RAWKEYCONVERT=	-$30
FINDTASK =	-294
WAITPORT =	-384
REPLYMSG =	-378
GETMSG =	-372
LOADRGB4 = 	-192

RAWKEY  	=	$00000400

BACKDROP	=	$00000100
BORDERLESS	=	$00000800
ACTIVATE	=	$00001000
RMBTRAP		=	$00010000

CUSTOMSCREEN	=	$000F

V_HIRES		=	$8000
NULL		=	0

;********************************
;*    System startup routine    *
;********************************

J	BSR.S	STARTUP
	BEQ.S	.ERROR		; An error ?

;---  Place your main routine here  ---

	BSR.L	JULIA_DRAW	; Draw the graphics

.LOOP1:	BSR.L	KEYB_GETKEY	; Get a keypression
	CMP.B	#' ',D0		; A space ??
	BNE.S	.LOOP1		; No again

	BRA.S	CLOSEDOWN	; Closedown
.ERROR:	RTS

;********  Open up system structures  ********

STARTUP:
	MOVE.L	A7,ERROR_STACK	; Save stack pointer if an error
	BSR.L	TASK_FIND
	BSR.L	INTULIB_OPEN
	BSR.L	GRAPHLIB_OPEN
	BSR.L	SCREEN_OPEN
	BSR.L	WINDOW_OPEN
	BSR.L	KEYB_INIT
	BSR.L	COLORS_SET
	MOVEQ	#-1,D0		; Set ok value
	RTS

;--- An error has occured ---

STARTUP_ERROR:
	MOVE.L	ERROR_STACK,A7	; Restore old stackpointer
	MOVEQ	#0,D0		; Set error value
	RTS			; Return to main to main routine

;*******  Close down system structures  *********

CLOSEDOWN:
	BSR.S	KEYB_EXIT
	BSR.L	WINDOW_CLOSE
	BSR.L	SCREEN_CLOSE
	BSR.L	GRAPHLIB_CLOSE
	BRA.S	INTULIB_CLOSE

;*******  Find our task  *******

TASK_FIND:
	SUB.L	A1,A1		; a1 = 0 Our task
	MOVE.L	$4.W,A6		; Exec pointer	
	JSR	FINDTASK(A6)	; Call Findtask
	MOVE.L	D0,TASK_PTR	; Store the pointer for our task
	RTS

;*******  Set the screen colors *******

COLORS_SET:
	MOVE.L	SCREEN_HANDLE(PC),A0	; Get screen handle
	LEA.L	44(A0),A0		; Get the screens viewport

	MOVE.L	GRAPHICS_BASE(PC),A6
	LEA.L	COLORS(PC),A1		; Pointer to the color list
	MOVEQ	#32,D0			; 32 colors to set
	JMP	LOADRGB4(A6)		; Set the colors

;****** Initialize keyboardroutine *******

KEYB_INIT:
	MOVE.L	$4.W,A6
	LEA	CONSOLE_NAME(PC),A0	; Pointer to "Console.Device"
	LEA	IO_REQUEST(PC),A1	; Io Buffer
	MOVEQ	#-1,D0			; Flags
	MOVEQ	#0,D1			; Unit
	JSR	OPENDEVICE(A6)		
	TST.L	D0			; An error
	BNE.S	STARTUP_ERROR		; Error quit !!

	MOVE.L	IO_REQUEST+20,CONSOLE_DEVICE	; Get console device
	MOVE.L	WINDOW_HANDLE(PC),A0	; Window Handle
	MOVE.L	$56(A0),KEY_PORT	; Get this windows keyport
	RTS

;****** Exit keyboard ******

KEYB_EXIT:
	LEA	IO_REQUEST(PC),A1
	MOVE.L	$4.W,A6
	JMP	CLOSEDEVICE(A6)

;******* Open Intution-Library *******

INTULIB_OPEN:
	MOVE.L	$4.W,A6
	LEA	INTUITION_NAME(PC),A1	; Pointer to "intuition.library"
	JSR	OPENLIB(A6)
	MOVE.L	D0,INTUITION_BASE	; Store pointer
	BEQ.L	STARTUP_ERROR		; If error jump
	RTS

;******* Close intution-library *******

INTULIB_CLOSE:
	MOVE.L	$4.W,A6
	MOVE.L	INTUITION_BASE(PC),A1
	JMP	CLOSELIB(A6)

;******* Open Graphics-Library *******

GRAPHLIB_OPEN:
	MOVE.L	$4.W,A6
	LEA	GRAPHICS_NAME(PC),A1	; Pointer to "graphics.library"
	JSR	OPENLIB(A6)
	MOVE.L	D0,GRAPHICS_BASE	; Store pointer
	BEQ.L	STARTUP_ERROR		; If error jump
	RTS

;******* Close Graphics-library *******

GRAPHLIB_CLOSE:
	MOVE.L	$4.W,A6
	MOVE.L	GRAPHICS_BASE(PC),A1
	JMP	CLOSELIB(A6)

;******* Open Main Screen *******

SCREEN_OPEN:
	LEA.L	SCREEN_DEFS(PC),A0	; Pointer to screen definitions
	MOVE.L	INTUITION_BASE(PC),A6	; Get intuition base
	JSR	OPENSCREEN(A6)		; Open the screen
	MOVE.L	D0,SCREEN_HANDLE
	BEQ.L	STARTUP_ERROR		; If not opened => error
	MOVE.L	D0,A0
	LEA.L	$C0(A0),A0		; Get bitplane pointers
	LEA.L	BITPLANE1_PTR(PC),A1
	MOVE.L	(A0)+,(A1)+		; Bitplane 1
	MOVE.L	(A0)+,(A1)+		; Bitplane 2
	MOVE.L	(A0)+,(A1)+		; Bitplane 3
	MOVE.L	(A0)+,(A1)+		; Bitplane 4
	MOVE.L	(A0)+,(A1)+		; Bitplane 5
	RTS

;******* Close Main Screen *******

SCREEN_CLOSE:
	MOVE.L	SCREEN_HANDLE(PC),A0
	MOVE.L	INTUITION_BASE(PC),A6
	JMP	CLOSESCREEN(A6)

;******* OPEN MAIN WINDOW *******

WINDOW_OPEN:
	MOVE.L	INTUITION_BASE(PC),A6	; Pointer to intuition library
	LEA	WINDOW_DEFS(PC),A0	; Pointer to window definitions
	JSR	OPENWINDOW(A6)
	MOVE.L	D0,WINDOW_HANDLE	; Store window handle
	BEQ.L	STARTUP_ERROR		; Error jump
	MOVE.L	TASK_PTR(PC),A0		; Get task pointer
	MOVE.L	$B8(A0),TASK_OLDWINDOW	; Store the old window
	MOVE.L	D0,$B8(A0)		; Make Reguesters turn up on this
	RTS				; Window
	
;******* CLOSE MAIN WINDOW *******

WINDOW_CLOSE:
	MOVE.L	TASK_PTR(PC),A0		; Get task ptr
	MOVE.L	TASK_OLDWINDOW(PC),$B8(A0)	; Restore old window
	MOVE.L	INTUITION_BASE(PC),A6
	MOVE.L	WINDOW_HANDLE(PC),A0
	JMP	CLOSEWINDOW(A6)

;******* GET KEY PRESS *******

KEYB_GETKEY:
	MOVE.W	KEYB_OUTBUFFER(PC),D0	; Buffer output pointer
	CMP.W	KEYB_INBUFFER(PC),D0	; Is buffer empty
	BNE.S	KEYB_STILLKEYSINBUFFER	; No ??
	BSR.L	KEYB_GETKEYS		; Empty, Wait on a key from
	BRA.S	KEYB_GETKEY		; the keyboard

KEYB_STILLKEYSINBUFFER:
	ADDQ.B	#1,KEYB_OUTBUFFER+1	; Increase out pointer
	LEA	KEYB_BUFFER(PC),A0	; Pointer to buffer
	MOVE.B	(A0,D0.W),D0		; Get the oldest key
	RTS

;******* GET KEY STRING *******

KEYB_GETKEYS:
	MOVE.L	KEY_PORT(PC),A5	; Our key port
	MOVE.L	A5,A0
	MOVE.L	$4.W,A6
	JSR	WAITPORT(A6)	; Wait for message on the port
	MOVE.L	A5,A0
	JSR	GETMSG(A6)	; Get the message
	MOVE.L	D0,KEY_MSG
	BEQ.S	KEYB_GETKEYS	; No message, strange, jump again

	MOVE.L	D0,A3		; Msg now in A3
	MOVE.L	20(A3),D3	; Get message type

;---  Check if raw key  ---

	MOVE.L	D3,D1
	AND.L	#RAWKEY,D1	; Was it a raw key ??
	BEQ.L	KEYB_ANSWER	; If no just answer

;---  Key Recieved  ---

	MOVE.W	24(A3),D4	; Key code
	BTST	#7,D4		; Bit 7 - Key release
	BNE.L	KEYB_ANSWER		; We dont need them
	MOVE.W	26(A3),D5	; QUALIFIER
	MOVE.L	28(A3),D6	; IADDRESS
	MOVE.W	D4,IECODE	; TRANSFER CODE
	MOVE.W	D5,IEQUAL	; QUALIFIERS
	MOVE.L	D6,IEADDR	; AND POINTER TO OLD KEYS

;---  Convert to ascii  ---

	LEA	MY_EVENT,A0	; Pointer to event structure
	LEA	KEY_BUFFER,A1	; Convert buffer
	MOVEQ	#80,D1		; Max 80 characters
	SUB.L	A2,A2		; A2 = 0 Keymap - Default
	MOVE.L	CONSOLE_DEVICE,A6
	JSR	RAWKEYCONVERT(A6) ; Convert the rawkey into Ascii

;---  Copy keys to buffer  ---

; d0 = number of chars in the convert buffer

KEYB_COPY_D0_CHARS:
	SUBQ.W	#1,D0
	BMI.S	KEYB_ANSWER		; No chars ??
	LEA	KEY_BUFFER(PC),A1
	LEA	KEYB_BUFFER(PC),A0
	MOVE.W	KEYB_INBUFFER,D1
.LOOP:	MOVE.B	(A1)+,(A0,D1.W)		; Copy the keys to the normal
	ADDQ.B	#1,D1			;  buffer.
	DBF	D0,.LOOP
	MOVE.W	D1,KEYB_INBUFFER
	BRA.L	KEYB_ANSWER		; Answer

;******* ANSWER KEYPRESS *******

KEYB_ANSWER:
	MOVE.L	KEY_MSG(PC),A1
	MOVE.L	$4.W,A6
	JMP	REPLYMSG(A6)		; Reply the message

SCREEN_DEFS:
	DC.W	0,0		; X-Y position
	DC.W	320		; Width
	DC.W	ScreenHeight		; Hight
	DC.W	5		; Depth
	DC.B	0,1		; Pen colors
	DC.W	0		; V_HIRES
	DC.W	CUSTOMSCREEN
	DC.L	FONT_ATTR	; use Topaz 8 as standard font
	DC.L	SCREEN_NAME
	DC.L	0
	DC.L	0

;***  Window structure  ***

WINDOW_DEFS:
	dc.w	0,0		; X-Y position
	dc.w	320		; Current width
	dc.w	ScreenHeight		; Current higth
	dc.b	0,1
	dc.l	RAWKEY		; Report only raw keys
	dc.l	BACKDROP+BORDERLESS+ACTIVATE+RMBTRAP
	dc.l	NULL
	dc.l	NULL
	DC.L	REQUESTER_NAME	; Window name
SCREEN_HANDLE:
	dc.l	NULL	;custom screen pointer
	dc.l	NULL
	dc.w	320		; Min width 
	dc.w	ScreenHeight		; Min higth
	dc.w	320		; Max width
	dc.w	ScreenHeight		; Max higth
	dc.w	CUSTOMSCREEN	; A normal window
	EVEN

;---  Topaz font  ---

FONT_ATTR:
	DC.L	FONT_NAME	; Name
	DC.W	8		; Size
	DC.B	0
	DC.B	0
	DC.W	8		; Size

COLORS:
	DC.W	$0000,$000F,$000E,$000D
	DC.W	$000C,$000B,$000A,$0009
	DC.W	$0008,$0007,$0106,$0205
	DC.W	$0304,$0403,$0502,$0611
	DC.W	$0720,$0831,$0942,$0A53
	DC.W	$0B64,$0C75,$0D86,$0C97
	DC.W	$0BA8,$0A9A,$098B,$0879
	DC.W	$0767,$0555,$0343,$0131

FONT_NAME:		DC.B	'topaz.font',0
CONSOLE_NAME:		DC.B	'console.device',0,0
REQUESTER_NAME:		DC.B	'My Requester',0
SCREEN_NAME:		DC.B	'ASM-One example - <SPACE> to quit',0
INTUITION_NAME:		DC.B	'intuition.library',0
GRAPHICS_NAME:		DC.B	'graphics.library',0
	even
CONSOLE_DEVICE:		DC.L	0
INTUITION_BASE:		DC.L	0
GRAPHICS_BASE:		DC.L	0
TASK_OLDWINDOW:		DC.L	0

BITPLANE1_PTR:		DC.L	0
BITPLANE2_PTR:		DC.L	0
BITPLANE3_PTR:		DC.L	0
BITPLANE4_PTR:		DC.L	0
BITPLANE5_PTR:		DC.L	0

TASK_PTR:		DC.L	0

KEYB_BUFFER:		DCB.B	256,0
KEYB_OUTBUFFER:		DC.W	0
KEYB_INBUFFER:		DC.W	0

ERROR_STACK:		DC.W	0

IO_REQUEST:		DCB.B	32,0
KEY_BUFFER:		DCB.B	80,0
KEY_PORT:		DC.L	0
KEY_MSG:		DC.L	0

MY_EVENT:	DC.L	0	; Insert after each event
EVENT_IECLASS:	DC.B	IECLASS_RAWKEY
		DC.B	0	; SUBCLASS - A Joke
IECODE:		DC.W	0	; RAWKEY - Inserted
IEQUAL:		DC.W	0	; QUALIFIER - SHIFT, CTRL, ETC.
IEADDR:		DC.L	0	; IAddress
		DC.L	0
		DC.L	0	; TimeStamp
WINDOW_HANDLE:	DC.L	0


;*********************************************
;*       Little Julia drawing routine        *
;*********************************************

ZOOM1 = 4	; ZOOM = ZOOM1/ZOOM2
ZOOM2 = 3

MANDEL_ON = 0	; 0 = JULIA, 1 = MANDELBROT

	IF	MANDEL_ON
CENTERX = -$400
CENTERY = $0
	ELSE
CENTERX = $0
CENTERY = $0
	ENDC

JULIA_DRAW:
	MOVE.L	BITPLANE1_PTR(PC),A0
	MOVE.L	BITPLANE2_PTR(PC),A1
	MOVE.L	BITPLANE3_PTR(PC),A2
	MOVE.L	BITPLANE4_PTR(PC),A3
	MOVE.L	BITPLANE5_PTR(PC),A4
	MOVE.W	#11*40,D0
	ADD.W	D0,A0
	ADD.W	D0,A1
	ADD.W	D0,A2
	ADD.W	D0,A3
	ADD.W	D0,A4

	SUB.L	A6,A6		; J
	MOVE.W	#CENTERY-($2000*ZOOM2/ZOOM1),CORDY
LOOP1:
	SUB.L	A5,A5		; I
	MOVE.W	#CENTERX-($2000*ZOOM2/ZOOM1)-($2000*ZOOM2/ZOOM1)*(320-(ScreenHeight-11))/320,CORDX
LOOP2:
	MOVE.W	CORDX,D0
	MOVE.W	CORDY,D1

	MOVE.W	#30,D7

	IF	MANDEL_ON
	MOVE.W	D0,D4
	MOVE.W	D1,D5
	ELSE
	MOVE.W	#$600,D4	; Start X	- Try to change to $5c
	MOVE.W	#-$100,D5	; Start Y	- Try to change to -$10
	ENDC

	MOVE.W	D0,D2
	MOVE.W	D1,D3
	BRA	BEGIN1

LOOP3:	SUB.L	D3,D2		; X^2-Y^2
	LSL.L	#4,D2
	SWAP	D2
	ADD.W	D4,D2		; X1

	MOVE.W	D1,D3
	MULS	D0,D3		; X*2*Y
	LSL.L	#5,D3
	SWAP	D3

	ADD.W	D5,D3		; Y1

	MOVE.W	D2,D0
	MOVE.W	D3,D1

BEGIN1:	MULS	D2,D2
	MULS	D3,D3
	MOVE.L	D2,D6
	ADD.L	D3,D6

	CMP.L	#$4000000,D6		; ESKAPISTISK ?
	BHI.S	NOTDRAW
	DBF	D7,LOOP3
NOTDRAW:

;*****  PLOT  *****

	MOVE.L	A5,D2
	MOVE.W	D2,D3
	NOT.W	D3
	LSR.W	#3,D2
	ADD.W	A6,D2

	ADD.W	D7,D7
	ADD.W	JUMP_TABEL(PC,D7.W),D7
	JMP	JUMP_TABEL(PC,D7.W)

	DR.W	PIXEL_00000
JUMP_TABEL:
	DR.W	PIXEL_11111
	DR.W	PIXEL_11110
	DR.W	PIXEL_11101
	DR.W	PIXEL_11100
	DR.W	PIXEL_11011
	DR.W	PIXEL_11010
	DR.W	PIXEL_11001
	DR.W	PIXEL_11000
	DR.W	PIXEL_10111
	DR.W	PIXEL_10110
	DR.W	PIXEL_10101
	DR.W	PIXEL_10100
	DR.W	PIXEL_10011
	DR.W	PIXEL_10010
	DR.W	PIXEL_10001
	DR.W	PIXEL_10000

	DR.W	PIXEL_01111
	DR.W	PIXEL_01110
	DR.W	PIXEL_01101
	DR.W	PIXEL_01100
	DR.W	PIXEL_01011
	DR.W	PIXEL_01010
	DR.W	PIXEL_01001
	DR.W	PIXEL_01000
	DR.W	PIXEL_00111
	DR.W	PIXEL_00110
	DR.W	PIXEL_00101
	DR.W	PIXEL_00100
	DR.W	PIXEL_00011
	DR.W	PIXEL_00010
	DR.W	PIXEL_00001

DOTSET:	MACRO
PIXEL_\1:
	IF	[%\1>>0]&1
	BSET	D3,(A0,D2.W)
	ENDC
	IF	[%\1>>1]&1
	BSET	D3,(A1,D2.W)
	ENDC
	IF	[%\1>>2]&1
	BSET	D3,(A2,D2.W)
	ENDC
	IF	[%\1>>3]&1
	BSET	D3,(A3,D2.W)
	ENDC
	IF	[%\1>>4]&1
	BSET	D3,(A4,D2.W)
	ENDC
	BRA	MAIN_LOOP
	ENDM

	DOTSET	00000
	DOTSET	00001
	DOTSET	00010
	DOTSET	00011
	DOTSET	00100
	DOTSET	00101
	DOTSET	00110
	DOTSET	00111
	DOTSET	01000
	DOTSET	01001
	DOTSET	01010
	DOTSET	01011
	DOTSET	01100
	DOTSET	01101
	DOTSET	01110
	DOTSET	01111

	DOTSET	10000
	DOTSET	10001
	DOTSET	10010
	DOTSET	10011
	DOTSET	10100
	DOTSET	10101
	DOTSET	10110
	DOTSET	10111
	DOTSET	11000
	DOTSET	11001
	DOTSET	11010
	DOTSET	11011
	DOTSET	11100
	DOTSET	11101
	DOTSET	11110
	DOTSET	11111

;*** MAIN LOOP ***

MAIN_LOOP:
	ADDQ.W	#1,A5
	ADD.W	#$4000*ZOOM2/ZOOM1/(ScreenHeight-11),CORDX
	CMP.W	#320,A5		; 320
	BNE.L	LOOP2
	ADD.W	#$4000*ZOOM2/ZOOM1/(ScreenHeight-11),CORDY
	ADD.W	#40,A6
	CMP.W	#(ScreenHeight-11)*40,A6	; 189
	BNE.L	LOOP1
END:
	RTS

CORDX:	DC.W	0
CORDY:	DC.W	0
