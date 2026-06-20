;
; ### ASCII v 1.70 ###
;
; - Created 880808 by TM -
;
;
; This program helps you to find the ASCII codes of different characters.
; It also 'knows' the control characters (NUL, BEL, LF, CR etc.).
;
; Original code by Tomi Marin, comments by Jukka Marin.
;
; Bugs: Not very well commented.  Sorry.  Not easy to write comments to a
;	proggie that's not written by me.
;
;
; Edited:
;
; - 881020 by TM -> v1.50	- Code compressed
; - 881020 by JM -> v1.60	- Code compressed and commented.
;				  Code size dropped from 1408 to 856 bytes!
; - 881021 by JM,TM -> v1.70	- Code still compressed.  Some features added.
;				  Code size is now 856 bytes.
;
;


CSI	equ	$9b			; control sequence introducer


	xref	_LVOOpen		; external references
	xref	_LVOOpenLibrary
	xref	_LVOClose
	xref	_LVOCloseLibrary
	xref	_LVORead
	xref	_LVOWrite
	xref	_LVOOutput
	xref	_LVOExecute
	xref	_LVOWaitForChar


	include "jmplibs.i"		; contains some useful macros




start	openlib	Dos,clean2		; open dos.library
	openlib	Intuition,clean2	; open intuition.library

	lea	ibuf(pc),a3		; address of input buffer (1 byte)

	move.l	#name1,d1		; raw window file
	move.l	#1005,d2
	lib	Dos,Open
	move.l	d0,d5			; put filehandle in d5
	bne	fileok

cleanup	move.l	d5,d1
	beq	clean1
	flib	Dos,Close		; close file (=window)
clean1	closl	Dos
	closl	Intuition
clean2	moveq.l	#0,d0
	rts

fileok	move.l	_IntuitionBase(pc),a0
	move.l	52(a0),a0		; pointer to active window
	lea	16(a0),a0
	move.l	#(250<<16)+77,d0	; set window size -> no sizing allowed
	move.l	d0,(a0)+
	move.l	d0,(a0)

	lea	INIT(pc),a2		; print initializing string
	move.b	#' ',(a3)		; number of first char displayed
	bsr	output

jumppi	move.b	(a3),d4
	subq.b	#4,d4
syppi	lea	CLEAR(pc),a2		; clear window
wyppi	bsr	output
	move.b	d4,d7
	moveq.l	#6,d6
	bra	sup2
sup1	lea	LINEF(pc),a2		; print line feed
	bsr	output
sup2	addq.b	#1,d7
	move.b	d7,d0
	bsr	fprint
	move.l	d5,d1
	moveq	#3,d2
	flib	Dos,WaitForChar		; check if a key pressed
	tst.l	d0
	dbne	d6,sup1			; loop to print all lines

ph	move.l	d5,d1			; read a char from keyboard
	move.l	a3,d2
	moveq.l	#1,d3
	flib	Dos,Read
	cmp.b	#27,(a3)		; if ESC, then exit
	beq	cleanup
	cmp.b	#CSI,(a3)		; check for cursor keys
	bne	jumppi
phii	move.l	d5,d1
	move.l	a3,d2
	moveq.l	#1,d3
	flib	Dos,Read
	cmp.b	#'?',(a3)
	bls	phii
	cmp.b	#'A',(a3)
	bne	ph1
	lea	HOME(pc),a2		; scroll & cursor home
	bsr	output
	move.b	d4,d0
	bsr	fprint
	subq.b	#1,d4
	bra	ph
ph1	cmp.b	#'B',(a3)
	bne	ph2
	lea	BOTTOM(pc),a2		; scroll & cursor to the bottommost line
	bsr	output
	move.b	d4,d0
	addq.b	#8,d0
	bsr	fprint
	addq.b	#1,d4
ph2	bra	ph


fprint	lea	buffer+2(pc),a2		; build one line into output buffer
	moveq	#' ',d2
	move.b	d0,d1
	and.b	#127,d1
	cmp.b	d2,d1
	bhs	fprin2
	move.b	d0,d1
	bpl	fprin1
	moveq	#'*',d2
fprin1	and.w	#31,d1
	mulu.w	#3,d1
	lea	sohi(pc),a0
	move.b	0(a0,d1.w),(a2)		; copy 'NUL' etc.
	move.b	1(a0,d1.w),1(a2)
	move.b	2(a0,d1.w),2(a2)
	bra	fprin3
fprin2	move.b	#'"',(a2)
	move.b	d0,1(a2)
	move.b	#'"',2(a2)
fprin3	lea	hextable(pc),a0		; convert to hexadecimal
	move.b	d0,d1
	and.w	#15,d1
	move.b	d2,3(a2)
	move.b	0(a0,d1.w),d2		; low nybble
	move.b	d2,12(a2)
	move.b	d0,d1
	lsr.b	#4,d1
	move.b	0(a0,d1.w),d2		; high nybble
	move.b	d2,11(a2)

	moveq.l	#0,d1			; convert to decimal
	move.b	d0,d1
	divu	#10,d1
	swap	d1
	or.b	#'0',d1
	move.b	d1,7(a2)		; 1's
	moveq.l	#0,d2
	clr.w	d1
	swap	d1
	divu	#10,d1
	swap	d1			; get 10's in d1[0...3]
	or.b	#'0',d1			; convert to ASCII
	move.b	d1,d2			; save it
	swap	d1			; remainder = 100's
	or.b	#'0',d1
	cmp.b	#'0',d1
	bne	fprin4
	moveq.l	#' ',d1			; blank leading zeros
	cmp.b	#'0',d2
	bne	fprin4
	move.b	d1,d2
fprin4	move.b	d2,6(a2)		; 10's
	move.b	d1,5(a2)		; 100's

	move.b	d0,d2			; convert to octal
	and.b	#7,d2
	or.b	#'0',d2
	move.b	d2,18(a2)		; lsd
	lsr.b	#3,d0
	move.b	d0,d2
	and.b	#7,d2
	or.b	#'0',d2
	move.b	d2,17(a2)		; isd
	lsr.b	#3,d0
	and.b	#7,d0
	or.b	#'0',d0
	move.b	d0,16(a2)		; msd
	subq.w	#2,a2

output	printa	a2,d5			; print a string at a2 to file in d5
	rts


hextable dc.b	'0123456789ABCDEF'

		;012345678901234567890
buffer	dc.b	'  "C"  DEC  $HX  &OCT',0
name1	dc.b	'Raw:0/0/250/77/Ascii Table'
ibuf	dc.b	0
LINEF	dc.b	10,0
INIT	dc.b	CSI,'7t',CSI,'0 p',0
CLEAR	dc.b	12,0
HOME	dc.b	CSI,$54,CSI,'0;0H',0
BOTTOM	dc.b	CSI,$53,CSI,'8;0H',0

sohi	dc.b	'NULSOHSTXETXEOTENQACKBEL BSTAB LF'
	dc.b	' VT FF CR SO SIDLEDC1DC2DC3DC4NAK'
	dc.b	'SYNETBCAN EMSUBESC FS GS RS US'

	libnames

	end


