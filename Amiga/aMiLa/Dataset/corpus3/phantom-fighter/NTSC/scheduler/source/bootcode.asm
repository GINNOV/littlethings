*******************************************
*               BOOTCODE.ASM
* This is the code that boots.asm loads in
* It should complete the construction of OUR
* machine and launch the game.
*
* Written by Brian Kelly 22-September-88
*

		include	'include.i:custom.i'

StackSize	equ	4096


BootCode	
		bra.l	OverThere

SendString	macro
		movem.l	a1/d0/d1,-(sp)
                lea.l	\1,a1
		bsr	SS
		movem.l	(sp)+,a1/d0/d1
		endm
                
                include	'diskio.asm'
                include	'memman.asm'

SS
1$              move.b	(a1)+,d0
                beq.s	2$
                bsr	SendChar
                bra.s	1$
2$		rts

FileName1	dc.b	'test.obj',0,0
		dc.w	0
FileName2	dc.b	'test1.obj',0,0
		dc.w	0
MyMsg		dc.b	'Hello world',10,13,0
		dc.w	0
OverThere	lea.l	TempStack(PC),sp
		move.w	#$2700,SR
 		move.w	#$7fff,_custom+intena
 		move.w	#$7fff,_custom+intreq
		move.w	#$1e0,_custom+dmacon * No Interrupts at all at all
		lea.l	IntHandler(PC),a0
		lea.l	$8,a1
                moveq	#28,d0
000$            move.l	a0,(a1)+
                dbra	d0,000$
		lea.l	TrapHandler(PC),a0 * Address of our trap Handler
		move.l	a0,$80		* Fill it in
		bsr	SetBaud		* Serial Communication is OK
                SendString	MyMsg(PC)
		lea.l	End(PC),a0	* Where our FreeSpace starts
                move.l	#$80000,d0	* Have we 512K
                sub.l	a0,d0		* Nope we have this much
                bsr	InitMem		* We have now setup everything
                move.l	#StackSize,d0	* Stack Space                
                moveq	#0,d1
                trap	#0
                addi.l	#StackSize,d0	* Stack grows down
                movea.l	d0,SP		* Stack Setup
		move.l	#(TRACK_LENGTH*2)+8,d0 * We want this much
                moveq	#0,d1
                trap	#0
                lea.l	TrackBuff(PC),a1 * This is where we need it
                move.l	d0,(a1)		* So put it there
                move.l	#(EntrySize*NoEntries)+4,d0
                moveq	#0,d1
                trap	#0
                lea.l	DirectoryCache(PC),a0
                move.l	d0,(a0)
                move.l	#DIRECTORY_TRACK,d0
                bsr	ReadATrack
                move.l	#(EntrySize*NoEntries)+4-1,d0
                movea.l	TrackBuff(PC),a1
                movea.l	DirectoryCache(PC),a0
003$            move.b	(a1)+,(a0)+
                dbra	d0,003$
                bsr	ShowLong
                lea.l	LocalVars(PC),a6 * Lets keep everybody happy
                lea.l	FileName1(PC),a0	* Let's execute this file
                bsr	Execute		* Whopee
                lea.l	LocalVars(PC),a6 * Lets keep everybody happy
                lea.l	FileName2(PC),a0	* Let's execute this file
                bsr	Execute		* Whopee
999$            bra.l	OverThere

* This is the Trap #0 handler that handles ALL our os functions
* as called from a C Program
* The hook code is held in d1 and all return values are returned in d0
*

TMsg		dc.b	'Trap Handler called ',13,10,0
		dc.w	0

TrapFuncs	dc.l	AllocMem-*
		dc.l	FreeMem-*
                dc.l	AvailMem-*
                dc.l	OpenRead-*
                dc.l	CloseRead-*
                dc.l	Fread-*
                dc.l	Fseek-*
                dc.l	kprintf-*
                dc.l	GMemBase-*

TrapHandler	lea.l	LocalVars(PC),a6
		lea.l	TrapFuncs(PC),a1
		lsl.l	#2,d1
                adda.l	d1,a1
                adda.l	(a1),a1
*                SendString	TMsg(PC)
                jsr	0(a1)
                rte
GMemBase	move.l	FreeMemRoot(PC),d0
		rts                

Guru		dc.b	10,13,'Guru type function called ooooopppppsssss *#@!!!',0
IntHandler      SendString	Guru(PC)
10$		bra.s	10$
		rte

kprintf		SendString	0(a0)
		rts
* This function loads and executes a file wh'e name is
* passed as a pointer in a0

NumRelocs	equ	0
RelocStuff	equ	4
CodeLength	equ	8
CodeAddress	equ	12

ExLocal		dc.l	0,0,0,0

Msg9		dc.b	'go for fread',13,10,0
Msg0		dc.b	'Loaded code OK',13,10,0
Msg1		dc.b	'Loaded relocs OK',13,10,0
CHK1		dc.b	10,13,'Checksum ==',0
		dc.w	0

Execute		move.l	d0,-(sp)
		SendString	0(a0)
		lea.l	ExLocal(PC),a5
                moveq	#3,d1
                trap	#0
*		bsr	OpenRead
                bsr	ShowLong
                lea.l	CodeLength(a5),a0
                moveq	#4,d0
                moveq	#5,d1
                trap	#0
*                bsr	Fread
                move.l	CodeLength(a5),d0
                bsr	ShowLong
		moveq	#0,d1
                trap	#0
                move.l	d0,CodeAddress(a5)
                movea.l	d0,a0
                move.l	CodeLength(a5),d0
                SendString	Msg9(PC)
                moveq	#5,d1
                trap	#0
*                bsr	Fread
                SendString	CHK1(PC)
                bsr	ShowLong
                SendString	Msg0(PC)
                lea.l	NumRelocs(a5),a0
                moveq	#4,d0
                moveq	#5,d1
                trap	#0
*                bsr	Fread
                move.l	NumRelocs(a5),d0
                lsl.l	#2,d0
                bsr	ShowLong
		moveq	#0,d1
                trap	#0
*                bsr	AllocMem
                bsr	ShowLong
                move.l	d0,RelocStuff(a5)
                movea.l	d0,a0
                move.l	NumRelocs(a5),d0
                lsl.l	#2,d0
                moveq	#5,d1
                trap	#0
*                bsr	Fread
                moveq	#4,d1
                trap	#0
*                bsr	CloseRead
                SendString	Msg1(PC)
                move.l	NumRelocs(a5),d0
                bsr	ShowLong
                movea.l	CodeAddress(a5),a0
                move.l	a0,d2
                movea.l	RelocStuff(a5),a1
                bra.s	10$
5$		move.l	(a1)+,d1
		add.l	d2,0(a0,d1.l)
10$             dbra	d0,5$
		move.l	(sp)+,d0
		movem.l	d1-d7/a0-a6,-(sp)
                move.l	d0,-(sp)
                jsr	(a0)
                addq.l	#4,sp
                movem.l	(sp)+,d1-d7/a0-a6
                move.l	d0,-(sp)
                move.l	CodeLength(a5),d0
                movea.l	CodeAddress(a5),a0
                moveq	#1,d1
                trap	#0
*                bsr	FreeMem
                move.l	NumRelocs(a5),d0
                lsl.l	#2,d0
                movea.l	RelocStuff(a5),a0
                moveq	#1,d1
                trap	#0
*                bsr	FreeMem
		move.l	(sp)+,d0
                rts
                
C_R		dc.b	13,10,0,0

CR		SendString	C_R(PC)
		rts

ShowLong	movem.l	d0-d3/a0-a3,-(sp)
		move.l	d0,-(sp)
		move.b	#'$',d0
                bsr	SendChar
                move.w	(sp),d0
                lsr.w	#8,d0
		bsr 	SendHex
                move.w	(sp),d0
		bsr	SendHex
                move.w	2(sp),d0
                lsr.w	#8,d0
		bsr 	SendHex
                move.l	(sp)+,d0
		bsr	SendHex
                bsr	CR
                movem.l	(sp)+,d0-d3/a0-a3
		rts
   
		dc.l	0,0,0,0,0,0,0,0,0

TempStack	dc.w	0
End		dc.w	0
