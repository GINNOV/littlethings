;
; ### DigiPlayer v 1.00 ###
;
; - Created 880219 by JM -
;
;
; Quack!
;
; Bugs: None known.
;
;
; Edited:
;
; - 880223 by JM -> v0.01	- added comments
; - 880223 by JM -> v0.02	- some cleanup
; - 880427 by JM -> v1.00	- Filename now supplied in the command.
;				- Code compressed.
;
;



MEMF_CHIP	equ	2


AUD0LC		equ	$DFF0A0		;Channel 0 DMA start location
AUD0LEN		equ	$DFF0A4		;Channel 0 DMA length
AUD0VOL		equ	$DFF0A8		;Channel 0 volume
AUD0PER		equ	$DFF0A6		;Channel 0 period
AUD0EN		equ	$01		;Channel 0 enable
AUD1LC		equ	$DFF0B0		;Channel 1 DMA start location
AUD1LEN		equ	$DFF0B4		;Channel 1 DMA length
AUD1VOL		equ	$DFF0B8		;Channel 1 volume
AUD1PER		equ	$DFF0B6		;Channel 1 period
AUD1EN		equ	$02		;Channel 1 enable

SetAud		equ	$08000		;Set bit mask
Clear		equ	0		;Clear bit mask
DMAEN		equ	$0200		;Enable audio DMA 
DMACONW		equ	$DFF096		;DMA control register, write

INTREQ		equ	$DFF09C		;Interrupt request register
INTREQR		equ	$DFF01E		;  same, read
INTENA		equ	$DFF09A		;Interrupt enable register
INTENAR		equ	$DFF01C		;  same, read


		xref	_LVOOpenLibrary
		xref	_LVOCloseLibrary
		xref	_LVOOpen
		xref	_LVOClose
		xref	_LVOOutput
		xref	_LVORead
		xref	_LVOWrite
		xref	_LVODelay
		xref	_LVOAllocMem
		xref	_LVOFreeMem

		include "JMPLibs.i"


Start		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a0,_CMDBuf
		clr.b	-1(a0,d0.l)		add null

		openlib Dos,cleanup

		print	<'DigiPlayer (c) Jukka Marin 1988',13,10>

		move.l	_CMDBuf(pc),a0
		tst.b	(a0)
		bne	name_not_null
		print	<'*** No file name ***',13,10>
		bra	cleanup

name_not_null	move.l	BYTES(pc),d0
		asl.l	#1,d0			we need two buffers
		move.l	#MEMF_CHIP,d1
		lib	Exec,AllocMem
		move.l	d0,mychip
		bne	mem_ok
		print	<'*** No CHIP RAM ***',13,10>
		bra	cleanup

mem_ok		move.l	_CMDBuf(pc),d1
		move.l	#1005,d2
		lib	Dos,Open
		move.l	d0,fileptr
		bne	looppi
		print	<'*** File not found ***',13,10>
		bra	cleanup

looppi		move.l	fileptr(pc),d1
		move.l	mychip(pc),d2
		move.l	BYTES,d3
		lib	Dos,Read
		move.l	d0,nextlen

		move.l	mychip(pc),a0
		lsr.l	#1,d0
		bsr	PlayABlock

wintti1		bsr	wait_aud

		move.l	nextlen(pc),d0
		cmp.l	BYTES(pc),d0
		bne	endoffile

		move.l	fileptr(pc),d1
		move.l	mychip(pc),d2
		move.l	BYTES(pc),d3
		add.l	d3,d2
		lib	Dos,Read
		move.l	d0,nextlen

		move.l	mychip(pc),a0
		add.l	BYTES(pc),a0
		lsr.l	#1,d0
		bsr	PlayABlock

wintti2		bsr	wait_aud

		move.l	nextlen(pc),d0
		cmp.l	BYTES(pc),d0
		beq	looppi

endoffile	move.l	#1,d1
		lib	Dos,Delay
		move.w	INTREQR,d0
		and.w	#%0000011110000000,d0
		beq	endoffile

		move.w	#(Clear+AUD0EN+AUD1EN),DMACONW
		move.w	#%0000011110000000,INTREQ

cleanup		move.l	fileptr(pc),d1
		beq	clean10
		lib	Dos,Close

clean10		move.l	mychip(pc),d0
		beq	clean11
		move.l	d0,a1
		move.l	BYTES(pc),d0
		asl.l	#1,d0			free both buffers
		lib	Exec,FreeMem

clean11		closlib	Dos
		movem.l	(sp)+,D2-D7/A2-A6
		rts




wait_aud	move.l	#1,d1
		lib	Dos,Delay
		move.w	INTREQR,d0
		and.w	#%0000011110000000,d0
		beq	wait_aud
		move.w	#%0000011110000000,INTREQ
		rts



; *****************************************************************
; 
;  This routine sets parameters for Audio DMA channels #0 and #1.
;  It initializes data length from D0 and data address from A0.
;
; *****************************************************************

PlayABlock	move.l	A0,AUD0LC		;Set parameters for voice #0
		move.w	D0,AUD0LEN
		move.w	#64,AUD0VOL
		move.w	TimePeriod(pc),AUD0PER

		move.l	A0,AUD1LC		;Set parameters for voice #1
		move.w	D0,AUD1LEN
		move.w	#64,AUD1VOL
		move.w	TimePeriod(pc),AUD1PER

		move.b	Flaggie(pc),D1
		cmp.b	#255,D1			;Initializing cycle?
		bne	ABlockExit

		;Set Audio DMA:

		move.w	#(SetAud+DMAEN+AUD0EN+AUD1EN),DMACONW
		clr.b	Flaggie


ABlockExit	rts


TimePeriod	dc.w	430	;sample time / 279 ns
BYTES		dc.l	50000	;buffers in CHIP RAM
Flaggie		dc.b	255	;my little Flaggie!
pad		dc.b	0
nextlen		dc.l	0
fileptr		dc.l	0
mychip		dc.l	0
_CMDBuf		dc.l	0

		libnames

		end

