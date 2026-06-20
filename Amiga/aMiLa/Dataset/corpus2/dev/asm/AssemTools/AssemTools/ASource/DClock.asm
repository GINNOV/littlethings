;
; ### DigiClock by JM & TM v 1.51 ###
;
; - Created 880612 by JM & TM -
;
;
; Program written for the 'C' Magazine.  Segment drawing by TM.
; Code is not very beautiful but we wanted to keep it as short as
; possible.
;
; Bugs: None alive.
;
;
; Edited:
;
; - 880612 by JM,TM -> v0.50	- Works.
; - 880613 by JM    -> v1.00	- Code compressed.
; - 880613 by JM    -> v1.10	- Close button added; code compressed.
; - 880613 by JM,TM -> v1.40	- Code still compressed.  Length was 952
;				  bytes but was then cut down to 816 bytes.
; - 880725 by JM    -> v1.41	- IDCMP corrected.  CLOSEWINDOW must be
;				  checked with CMP.L!
; - 881106 by JM    -> v1.50	- Re-run enabled (doesn't modify itself)
; - 890312 by JM    -> v1.51	- Short branches, A68k compatibility
;
;



		xref	_LVOOpenLibrary
		xref	_LVOCloseLibrary
		xref	_LVOAllocMem
		xref	_LVOFreeMem
		xref	_LVODisable
		xref	_LVOEnable
		xref	_LVOWait
		xref	_LVOGetMsg
		xref	_LVOReplyMsg

		xref	_LVOExecute
		xref	_LVOOpen
		xref	_LVOClose
		xref	_LVOOutput
		xref	_LVORead
		xref	_LVOWrite
		xref	_LVODelay
		xref	_LVODateStamp

		xref	_LVOMove
		xref	_LVODraw
		xref	_LVOText
		xref	_LVOSetAPen
		xref	_LVOSetBPen
		xref	_LVOSetDrMd
		xref	_LVOSetRast
		xref	_LVOLoadRGB4
		xref	_LVOVBeamPos

		xref	_LVOScreenToFront
		xref	_LVOScreenToBack
		xref	_LVOOpenScreen
		xref	_LVOCloseScreen
		xref	_LVOOpenWindow
		xref	_LVOCloseWindow
		xref	_LVOMoveScreen
		xref	_LVOOpenFont
		xref	_LVOCloseFont
		xref	_LVOOpenDiskFont
		xref	_LVORectFill

		xdef	main

		include "JMPLibs.i"
		include "intuition.i"

		BITDEF	MEM,PUBLIC,0
		BITDEF	MEM,CHIP,1
		BITDEF	MEM,FAST,2
		BITDEF	MEM,CLEAR,16
		BITDEF	MEM,LARGEST,17

LF		equ	10


tool_dclock
main		openlib Dos,cleanup_dos		open Dos library
		openlib	Gfx,cleanup_gfx
		openlib	Intuition,cleanup_int

		clr.l	oldtime

		lea	ClWindow(pc),a0
		lib	Intuition,OpenWindow
		move.l	d0,d6			window ptr
		beq	cleanup
		move.l	d0,a0
		move.l	wd_RPort(a0),a5		rastport

		moveq.l	#2,d0			Fill background
		move.l	a5,a1
		lib	Gfx,SetAPen
		move.l	a5,a1
		moveq.l	#2,d0
		moveq.l	#10,d1
		move.l	#311,d2
		moveq.l	#77,d3
		flib	Gfx,RectFill

Colon		moveq.l	#2,d0			Toggle colon color
		bchg	#0,col_col
		beq.s	Colon_off
		addq.l	#1,d0
Colon_off	move.l	a5,a1			Set color black/orange
		lib	Gfx,SetAPen
		move.l	a5,a1			Draw colon (upper dot)
		move.l	#152,d0
		moveq.l	#30,d1
		move.l	d0,d2
		addq.w	#8,d2
		moveq.l	#34,d3
		flib	Gfx,RectFill

		move.l	a5,a1			Draw colon (lower dot)
		move.l	#152,d0
		moveq.l	#52,d1
		moveq.l	#56,d3
		flib	Gfx,RectFill

Main		lea	TimeBuf(pc),a0		read time
		move.l	a0,d1
		lib	Dos,DateStamp

		move.l	TimeBuf+4(pc),d2
		cmp.w	oldtime(pc),d2
		beq.s	Sleep
		move.w	d2,oldtime
		divu.w	#60,d2			convert to hours/minutes
		move.l	d2,d3			save minutes
		moveq.l	#-68,d0			reset x-coord
		bsr	draw2
		swap	d3
		move.l	d3,d2
		bsr.s	draw2

Sleep		moveq.l	#24,d4
WaitTicks	moveq.l	#1,d1			Sleep for a while
		lib	Dos,Delay
		move.l	d6,a0			windowptr
		move.l	wd_UserPort(a0),a4
		move.l	a4,a0			port*
		lib	Exec,GetMsg		Check if a message received
GetMsgLoop	move.l	d0,d2			message*
		beq.s	Colonize		No msg received
		move.l	d2,a1			IntuiMessage *
		move.l	im_Class(a1),d3		Class
		lib	Exec,ReplyMsg
		move.l	a4,a0			port
		flib	Exec,GetMsg
		tst.l	d0
		bne	GetMsgLoop
		cmp.l	#CLOSEWINDOW,d3
		beq.s	cleanup
Colonize	dbf	d4,WaitTicks
		bra	Colon


cleanup		move.l	d6,d0
		beq.s	clean90
		move.l	d0,a0
		lib	Intuition,CloseWindow

clean90		closl	Intuition
cleanup_int	closl	Gfx
cleanup_gfx	closl	Dos
cleanup_dos	rts


draw2		and.l	#$ffff,d2
		divu.w	#10,d2
		move.b	d2,d1		10 hours
		add.w	#88,d0		xcoord
		bsr.s	drawdigit
		swap	d2		get hours
		move.b	d2,d1
		add.w	#68,d0		inc x

drawdigit	push	all		save registers
		move.l	d0,d2		x-coordinate of the digit
		lea	digitdata(pc),a0
		ext.w	d1
		move.b	0(a0,d1.w),d3	segment data
		lsl.b	#1,d3
		moveq.l	#6,d4
		lea	segment(pc),a2
drawdigit1	moveq.l	#2,d0
		lsl.b	#1,d3
		bcc.s	drawsegment1
		moveq.l	#3,d0
drawsegment1	move.l	a5,a1
		lib	Gfx,SetAPen
		moveq.l	#3,d7
drawsegment2	moveq.l	#0,d0
		move.l	d0,d1
		move.b	(a2)+,d0
		bmi.s	drawline1
		move.b	(a2)+,d1
		add.w	d2,d0
		move.l	a5,a1
		flib	Gfx,Move
		moveq.l	#0,d0
		move.l	d0,d1
		move.b	(a2)+,d0
		move.b	(a2)+,d1
		add.w	d2,d0
		move.l	a5,a1
		flib	Gfx,Draw
drawline1	dbf	d7,drawsegment2
		dbf	d4,drawdigit1
		pull	all		restore registers
		rts

segment				; segment coordinates
		dc.b	2,20,45,20,3,21,44,21,4,22,43,22,-1
				; segment A
		dc.b	47,22,47,41,46,23,46,40,45,24,45,39,44,25,44,38
				; segment B
		dc.b	47,45,47,65,46,46,46,64,45,47,45,63,44,48,44,62
				; segment C
		dc.b	2,67,45,67,3,66,44,66,4,65,43,65,-1
				; segment D
		dc.b	0,45,0,65,1,46,1,64,2,47,2,63,3,48,3,62
				; segment E
		dc.b	0,22,0,41,1,23,1,40,2,24,2,39,3,25,3,38
				; segment F
		dc.b	4,42,43,42,2,43,45,43,4,44,43,44,-1
				; segment G

digitdata	dc.b	%1111110	; maaritellaan 7-segmenttinayton
		dc.b	%0110000	; numeroissa palavat segmentit
		dc.b	%1101101
		dc.b	%1111001
		dc.b	%0110011
		dc.b	%1011011
		dc.b	%1011111
		dc.b	%1110000
		dc.b	%1111111
		dc.b	%1111011


		cnop	0,4			osoite 4:lla jaolliseksi

TimeBuf		dc.l	0
		dc.l	0
		dc.l	0

oldtime		dc.l	0
		dc.l	0
		dc.l	0

col_col		dc.w	0

ClWindow	dc.w	0,0,314,79		upper x,y , x,y-size
		dc.b	2,1			detailpen, blockpen
		dc.l	CLOSEWINDOW		IDCMPFlags
		dc.l	WINDOWDRAG!WINDOWDEPTH!WINDOWCLOSE	Flags
		dc.l	0			gadgets
		dc.l	0			checkmark
		dc.l	MyWinTitle		title
		dc.l	0			screen
		dc.l	0			bitmap
		dc.w	320,256,320,256		min-max size
		dc.w	WBENCHSCREEN		type

MyWinTitle	dc.b	'DigiCLOCK v1.51',0

		libnames			kirjastojen nimet&osoittimet

		end

