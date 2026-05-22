****************************************************************************
*                                                                          *
*              This Trackloader was coded by Patrik Lundquist              *
*                                                                          *
*                               Version 1.0                                *
*                                                                          *
*                Copyright (C) 1991-93 by SnurgelGmurf Soft                *
*                                                                          *
*                                                                          *
* I coded this loader back in 1991 and fixed a bug in May `93.             *
* The reason why I release this loader is that I'm tired of all            *
* loaders that won't work on accelerated Amigas.                           *
*                                                                          *
* The loader accepts blocks in the range of 0-1803 (cylinders 0-81).       *
* I wouldn't recommend using cylinders 80-81 as it's not standard.         *
* No error checking is done. It's quite easy to implement checksum check.  *
* You can have this loader running outside your interrupts and             *
* don't need to worry about it. You must have $dff000 in a5 when you       *
* jump to Loader. Registers d0-7/a0-1 are modified in Loader.              *
*                                                                          *
* You may use this source partly or in whole in any way you want EXCEPT    *
* for destructive purposes like viruses.                                   *
* I would appreciate credits if you use it.                                *
*                                                                          *
* This sourcecode may not be distributed for a profit.                     *
*                                                                          *
* This sourcecode is provided "AS IS" without warranty of any kind, either *
* expressed or implied. By using this source you agree to accept the       *
* entire risk as to the quality and performance of the program. I can NOT  *
* be held liable for any damaged caused by this sourcecode.                *
*                                                                          *
*                                                                          *
* You can reach me here:                                                   *
*                                                                          *
* Internet:     pi92plu@pt.hk-r.se                                         *
*                                                                          *
* IRC:          Look for 'PatrikL' on #amiga channel.                      *
*                                                                          *
****************************************************************************


		Section	Trackloader,Code
		Opt	c+,o+


SyncWord	Equ	$4489			Standard sync value.
AdkCon		Equ	$9500


		Bsr.s	Init			Setup hardware registers.

		Move.l	#880,d0			Start block, 0-1803.
		Moveq	#88,d1			Number of blocks to read.
		Lea	DestBuffer,a0		Destination address.
		Bsr	Loader

		Moveq	#0,d0			Start block, 0-1803.
		Moveq	#88,d1			Number of blocks to read.
		Lea	DestBuffer,a0		Destination address.
		Bsr	Loader

		Move.l	#1600,d0		Start block, 0-1803.
		Moveq	#88,d1			Number of blocks to read.
		Lea	DestBuffer,a0		Destination address.
		Bsr	Loader

		Bsr	Exit			Restore hardware registers.
		Rts

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*

Init		Lea	$dff000,a5		customchip-base into a5

		Move.b	$bfde00,CIA_B		Save tmr A Control reg
		Move.w	$2(a5),OldDMA		save dma channels
		Bset	#7,OldDMA
		Move.b	$10(a5),OldADKCON	save old ADKCON
		Bset	#7,OldADKCON
		Move.w	$1c(a5),oldintena	save old interrupt enable
		Bset	#7,oldintena
		Move.w	$1e(a5),oldintreq	save old interrupt request
		Bset	#7,oldintreq

		Move.w	#$7fff,d1
		Move.w	d1,$9a(a5)		kill all interrupts
		Move.w	d1,$9c(a5)
		Move.w	d1,$96(a5)

		Move.w	#SyncWord,$7e(a5)	DSKSYNC
		Move.w	#AdkCon,$9e(a5)		ADKCON
		Move.w	#$8200,$96(a5)
		Move.b	#%01001100,$bfde00	Stop, one-shot mode.

		Bsr.s	SelDF0MotOn
		Bsr	GoToTrack00
		Bsr	SelDF0MotOff
		Rts

*ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ*

Exit		Move.w	OldDMA(pc),$96(a5)	Restore old dma.
		Move.b	CIA_B(pc),$bfde00	Restore tmr A Control reg.
		Move.b	OldADKCON(pc),$9e(a5)
		Move.w	oldintena(pc),$9a(a5)	Restore old interrupt enable.
		Move.w	oldintreq(pc),$9c(a5)
		Moveq	#0,d0
		Rts

*===========================================================================*

SelDF0MotOn	Or.b	#$78,$bfd100	Set bits 3,4,5 and 6,
				;	deselect all drives.
		Bclr	#7,$bfd100	Switch on motor.
		Nop
		Nop
		Bclr	#3,$bfd100	Clear bit 3, DF0
		Rts

*ญ---------------------------------------------ญ*

	*	Control routine.

	*	Start block -> d0
	*	Number of blocks -> d1
	*	Destination address -> a0

Loader		Tst.l	d1
		Beq	ExitLR
		Bmi	ExitLR
		Tst.l	d0
		Bmi	ExitLR			Boundary check.
		Move.l	d1,d2
		Add.l	d0,d2
		Cmp.l	#1804,d2
		Bgt	ExitLR

		Bsr.s	SelDF0MotOn
		Divu	#11,d0
		Move.b	d0,StartTrack
		Move.l	d0,d2
		Swap 	d2
		Move.b	d2,StartSector
		Add.b	d2,d1
		Divu	#11,d1
		Move.l	d1,d2
		Swap 	d2
		Tst.b	d2
		Bne.s	EqualTrack
		Subq.b	#1,d1
		Move.b	#11,d2
EqualTrack	Move.b	d1,Tracks
		Move.b	d2,EndSector

		Move.b	d0,d1			Start-track in d0.
		Move.b	Position(pc),d2
		Lsr.b	#1,d1
		Lsr.b	#1,d2
		Cmp.b	d1,d2
		Beq.s	RightCyl		No need to move head.
		Blt.s	MoveHeadIn
		Sub.b	d1,d2			Moving head outwards.
		Bsr	MoveOutwards
		Subq.b	#1,d2
		Beq.s	RightCyl
		Subq.b	#1,d2
		Ext.w	d2
.MoveHeadOut	Bsr	MoveHead
		Dbra	d2,.MoveHeadOut
		Bra.s	RightCyl
MoveHeadIn	Sub.b	d2,d1			Moving head inwards.
		Bsr	MoveInwards
		Subq.b	#1,d1
		Beq.s	RightCyl
		Subq.b	#1,d1
		Ext.w	d1
.MoveHeadIn	Bsr	MoveHead
		Dbra	d1,.MoveHeadIn
RightCyl	Btst	#0,StartTrack		Time to choose side.
		Beq.s	.LowerIt
		Btst	#2,$bfd100
		Beq.s	RightTrack
		Bsr	Upper
		Bra.s	RightTrack
.LowerIt	Btst	#2,$bfd100
		Bne.s	RightTrack
		Bsr	Lower
RightTrack	Move.b	StartSector(pc),d3	And now, the reading begins.
		Move.b	Tracks(pc),d2
		Beq.s	LastTrack
		Moveq	#11,d4
		Bsr.s	Read
NextTrack	Moveq	#0,d3
		Btst	#2,$bfd100
		Bne.s	NextSide
		Bsr	Lower
		Btst	#1,$bfd100
		Bne.s	.FirstMoveIn
		Bsr	MoveHead
		Bra.s	NextRead
.FirstMoveIn	Bsr	MoveInwards
		Bra.s	NextRead
NextSide	Bsr	Upper
NextRead	Subq.b	#1,d2
		Beq.s	LastTrack
		Bsr.s	Read
		Bra.s	NextTrack
LastTrack	Move.b	EndSector(pc),d4
		Bsr.s	Read
		Bsr.s	SelDF0MotOff
ExitLR		Rts

*ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ*

SelDF0MotOff	Or.b	#$f8,$bfd100	Set bits 3,4,5,6 and 7,
		Nop			deselects all drives, motor off.
		Nop
		Bclr	#3,$bfd100	Clear bit 3, select drive 0.
		Rts

*ญ---------------------------------------------ญ*

Read		Btst	#5,$bfe001		Await Disk ready.
		Bne.s	Read
		Move.b	#$91,$bfd400		Timer A low.
		Move.b	#$29,$bfd500		Timer A hi, and starts timer.
		Bsr	Timer
		Move.w	#2,$9c(a5)		Clear Disk Intrequest.
		Move.l	#TrackBuffer,$20(a5)	DSKPT, MFM-buffer.
		Move.w	#$8010,$96(a5)		Disk DMA on.
		Move.w	#$4000,$24(a5)		dsklen
		Move.w	#$9900,$24(a5)		dsklen, read lenght.
		Move.w	#$9900,$24(a5)		dsklen
.DMAwait	Btst	#1,$1f(a5)		DMA transfer done when high.
		Beq.s	.DMAwait
		Move.w	#$4000,$24(a5)
		Move.w	#$0010,$96(a5)		Disk DMA off.

*ญ---------------------------------------------ญ*
	*	Destination address -> a0
	*	Start sector -> d3
	*	End sector -> d4

Decode		Move.w	#SyncWord,d5		Sync-word.
		Move.l	#$55555555,d7		%010101...

FindSector	Lea	TrackBuffer,a1		Move Buffer-address.
SyncSearch	Cmp.w	(a1)+,d5		Check for Sync-word.
		Bne.s	SyncSearch
		Cmp.w	(a1),d5			Another Sync-word?
		Beq.s	SyncSearch
		Move.l	(a1),d0
		Move.l	4(a1),d1
		And.l	d7,d0
		Asl.l	#1,d0
		And.l	d7,d1
		Or.l	d1,d0
		Ror.l	#8,d0
		Cmp.b	d3,d0			Correct sector?
		Beq.s	SectorOK
		Lea	$43E(a1),a1		Add to next sector.
		Bra.s	SyncSearch

SectorOK	Addq.b	#1,d3
		Lea	$38(a1),a1		Skip InfoBytes.
		Moveq	#$7f,d6
DeCodeLoop	Move.l	$200(a1),d1
		Move.l	(a1)+,d0
		And.l	d7,d0
		Asl.l	#1,d0
		And.l	d7,d1
		Or.l	d1,d0
		Move.l	d0,(a0)+		Move to Load Address.
		Dbra	d6,DeCodeLoop
		Cmp.b	d4,d3
		Bne.s	FindSector
		Rts

*ญ---------------------------------------------ญ*

GoToTrack00	Btst	#4,$bfe001	Track 00 when low.
		Beq.s	Pos00
		Bsr.s	MoveOutwards
TowardsTrack00	Btst	#4,$bfe001	Track 00 when low.
		Beq.s	Pos00
		Bclr	#0,$bfd100	Move head.
		Nop
		Nop
		Bset	#0,$bfd100	Prepare to move head.
		Move.b	#$69,$bfd400	Timer A low.
		Move.b	#$0e,$bfd500	Timer A hi, and starts timer.
		Bsr.s	Timer		5.2ms
		Bra.s	TowardsTrack00
Pos00		Clr.b	Position
		Rts

*ญ---------------------------------------------ญ*

Upper		Bclr	#2,$bfd100	Upper side.
		Move.b	#$47,$bfd400	Timer A low.
		Move.b	#$00,$bfd500	Timer A hi, and starts timer.
		Bra.s	Timer		100ตs

*ญ---------------------------------------------ญ*

Lower		Bset	#2,$bfd100	Lower side.
		Move.b	#$47,$bfd400	Timer A low.
		Move.b	#$00,$bfd500	Timer A hi, and starts timer.
		Bra.s	Timer		100ตs

*ญ---------------------------------------------ญ*

MoveOutwards	Bset	#1,$bfd100	Head direction outward.
		Bclr	#0,$bfd100	Move head.
		Nop
		Nop
		Bset	#0,$bfd100	Prepare to move head.
		Move.b	#$e1,$bfd400	Timer A low.
		Move.b	#$31,$bfd500	Timer A hi, and starts timer.
		Move.b	#-2,Direction
		Add.b	#-2,Position	18ms

*ญ---------------------------------------------ญ*

Timer		Move.b	$bfdd00,d0	Await Timer ready.
		Btst	#0,d0
		Beq.s	Timer
Rts		Rts

*ญ---------------------------------------------ญ*

MoveInwards	And.b	#$fc,$bfd100	Clear bits 0 and 1,
		Nop	which results in diskdirec=inwards, head moved.
		Nop
		Bset	#0,$bfd100	Prepare to move head.
		Move.b	#$e1,$bfd400	Timer A low.
		Move.b	#$31,$bfd500	Timer A hi, and starts timer.
		Move.b	#2,Direction
		Addq.b	#2,Position
		Bra.s	Timer		18ms

*ญ---------------------------------------------ญ*

MoveHead	Bclr	#0,$bfd100	Move head.
		Nop
		Nop
		Bset	#0,$bfd100	Prepare to move head.
		Move.b	#$50,$bfd400	Timer A low.
		Move.b	#$08,$bfd500	Timer A hi, and starts timer.
		Move.b	Direction(pc),d0
		Add.b	d0,Position
		Bra.s	Timer		3ms

*ญ---------------------------------------------ญ*

oldintena	Ds.w	1
oldintreq	Ds.w	1
OldDMA		Ds.w	1
CIA_B		Ds.b	1
OldADKCON	Ds.b	1

Position	Ds.b	1
Direction	Ds.b	1
StartTrack	Ds.b	1
StartSector	Ds.b	1
Tracks		Ds.b	1
EndSector	Ds.b	1

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*

	Section Track,BSS_C

TrackBuffer	Ds.w	$1900		Room for one MFM-track.

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*

	Section	Destination,BSS

DestBuffer	Ds.b	512*88		This is for test purpose.

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*

		End

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*
Operation:				WaitTime:	Timervalue:
ญญญญญญญญญ				ญญญญญญญญ	ญญญญญญญญญญ
 Motor on				500ms, DSKRDY	$56982
 Diskside stable before reading		100ตs		$47
 Diskside stable before writing		100ตs		$47
 Diskside stable after writing		1.3ms		$39A
 Diskstep				3ms		$850
 Reverse diskstep			18ms		$31E1
 Settle time				15ms		$2991
 Track 00 signal low after step		2.2ms		$619
 Track 00 signal hi after step		1ตs		$1
 Step after drive select		1ตs		$1
 Direction select before step		1ตs		$1
 Direction select after step		1ตs		$1
 Keep low signal			1ตs		$1
