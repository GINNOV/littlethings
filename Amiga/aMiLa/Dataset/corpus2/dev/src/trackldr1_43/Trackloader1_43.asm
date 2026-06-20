*************************************************************************
*									*
*                 Trackloader coded by Patrik Lundquist                 *
*									*
*                              Version 1.43				*
*									*
*               Copyright (c) 1991-94 by Patrik Lundquist               *
*									*
*									*
* I coded this loader back in 1991 and fixed a bug in May `93, when I	*
* also released version, 1.0. Since people have shown interest I	*
* thought I'd better release a newer vesion.				*
*									*
* The loader accepts blocks in the range of 0-1803 (cylinders 0-81).	*
* I wouldn't recommend using cylinders 80-81 as it's not standard.	*
* You should have this loader running outside your interrupts.		*
* Registers d0-d7/a0-a2 are trashed by Loader.				*
*									*
* These registers are initialized in LoaderInit:			*
*			lea $bfd000,a3					*
*			lea LDR_vars,a4					*
*			lea $dff000,a5					*
*									*
* LoaderInit:								*
* description:	Initializes registers, variables and drives.		*
*    requires:	nothing							*
*	input:	d0.b	- retries, 0-255				*
*      result:	none							*
*									*
* LoaderExit:								*
* description:	Cleans up. Restores registers.				*
*    requires:	lea $bfd000,a3  --  doesn't trash any reg		*
*		lea LDR_vars,a4						*
*		lea $dff000,a5						*
*	input:	none							*
*      result:	none							*
*									*
* Loader:								*
* description:	Loads from disk.					*
*    requires:	lea $bfd000,a3						*
*		lea LDR_vars,a4						*
*		lea $dff000,a5						*
*	input:	d0.l	- startblock, 0-1803				*
*		d1.l	- blocks to read, 1-1804			*
*		d2.b	- drive to use, 0-3				*
*		a0	- destination address				*
*      result:	d0.l	-  0 = Success					*
*			  -1 = Out of boundary sector read		*
*			  -2 = Drive not available			*
*			  -3 = No disk in drive				*
*			  -4 = Sync not found				*
*			  -5 = Checksum error				*
*									*
* LoaderUpdate:								*
* description:	Updates information about inserted disks, DRV_Status.	*
*    requires:	lea $bfd000,a3  --  doesn't trash any reg		*
*	input:	none							*
*      result:	none							*
*									*
* About	LDR_DriveX's DRV_Status:					*
*  Bit set = true.	0  -  Drive available				*
*			1  -  Disk inserted				*
*			2-7   Unused					*
*									*
*									*
* You may use this source partly or in whole for non commercial and	*
* non destructive purposes. I would appreciate credits if you use it.	*
* Think twice before you decide to use a trackloader, most people	*
* have a harddisk nowadays!						*
*									*
* This sourcecode may not be distributed for profit.			*
*									*
* This sourcecode is provided "AS IS" without warranty of any kind,	*
* either expressed or implied. By using this source you agree to accept	*
* the entire risk as to the quality and performance of the source.	*
* I can NOT be held liable for any damaged caused by this sourcecode.	*
*									*
* Changes in version 1.1:						*
*   - Code cleaning, optimizations.					*
*   - Multiple drives supported.					*
*									*
* Changes in version 1.2:						*
*   - Data checksum error check.					*
*   - Retries.								*
*									*
* Changes in version 1.3:						*
*   - Checks for inserted disks.					*
*									*
* Changes in version 1.4:						*
*   - Minor improvements.						*
*									*
* Changes in version 1.41:						*
*   - Much faster checksum calculation.					*
*									*
* Changes in version 1.42:						*
*   - More automatic disk checking.					*
*									*
* Changes in version 1.43:						*
*   - Error codes.							*
*									*
* You can reach me here:						*
*									*
* Internet:	pi92plu@pt.hk-r.se					*
*									*
* IRC:		PatrikL @ #amiga					*
*									*
*************************************************************************

		include	hardware/cia.i

		Section	Demonstration,Code
		Opt	c+,o+,ow2-,u-

DemoStart	lea	$dff000,a5

		move.w	$1c(a5),oldintena	save old interrupt enable
		bset	#7,oldintena
		move.w	$1e(a5),oldintreq	save old interrupt request
		bset	#7,oldintreq

		move.w	#$7fff,d1
		move.w	d1,$9a(a5)		kill all interrupts
		move.w	d1,$9c(a5)

		moveq	#3,d0			Retries, 0-255
		jsr	LoaderInit		Setup loader.

		move.l	#880,d0			Start block, 0-1803
		moveq	#88,d1			Blocks to read, 1-1804
		move.b	#0,d2			Drive 0, 0-3
		lea	DestBuffer,a0		Destination address
		jsr	Loader
		tst.l	d0
		bne.s	Failure

		moveq	#0,d0			Start block, 0-1803
		moveq	#88,d1			Blocks to read, 1-1804
		move.b	#0,d2			Drive 0, 0-3
		lea	DestBuffer,a0		Destination address
		jsr	Loader
		tst.l	d0
		bne.s	Failure

		move.l	#1600,d0		Start block, 0-1803.
		moveq	#88,d1			Blocks to read, 1-1804
		move.b	#1,d2			Drive 1, 0-3
		lea	DestBuffer,a0		Destination address
		jsr	Loader
		tst.l	d0
		bne.s	Failure

DemoExit	jsr	LoaderExit		Restore hardware registers.
		move.w	oldintena(pc),$9a(a5)
		move.w	oldintreq(pc),$9c(a5)
		rts

Failure		MOVE.W	#$F00,$180(A5)
		bra.s	DemoExit

oldintena	ds.w	1
oldintreq	ds.w	1

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*

		Section	DemoDest,BSS

DestBuffer	ds.b	88*512		88 blocks, only for demonstration.

*===========================================================================*

		Section	Trackloader,Code
		Opt	c+,o+

	*	Retries -> d0.b

ldr_SyncWord	equ	$4489

LoaderInit	lea	$bfd000,a3
		lea	LDR_vars(pc),a4
		lea	$dff000,a5

		move.b	ciacra(a3),LDR_oldCRA(a4)
		move.w	$10(a5),LDR_oldADK(a4)
		bset	#7,LDR_oldADK(a4)
		and.w	#$9500,LDR_oldADK(a4)
		move.w	$2(a5),LDR_oldDMA(a4)
		bset	#7,LDR_oldDMA(a4)
		and.w	#$8210,LDR_oldDMA(a4)

		move.w	#ldr_SyncWord,$7e(a5)	DSKSYNC
		move.w	#$9500,$9e(a5)		ADKCON
		move.w	#$4000,$24(a5)		dsklen, disk DMA off
		move.w	#$8210,$96(a5)		Disk DMA
	move.b	#CIACRAF_OUTMODE!CIACRAF_RUNMODE!CIACRAF_SPMODE,ciacra(a3)	Stop, one-shot mode.

		move.b	d0,LDR_Retries(a4)

; Find available drives and init them. DF0: is assumed to always be available.
; Can't get an ID stream from DF0: DD drives anyway.

		move.b	#3,LDR_Drive(a4)	DF0:
		lea	LDR_Drive0(pc),a2
		bset	#0,DRV_Status(a2)
		bsr	ldr_GoToCyl0

		lea	DRV_SIZEOF(a2),a2
		move.b	#4,d3			DF1:
		move.b	#%00001000,d4		DF0:
		move.w	#2,d2
.driveLoop	move.b	d3,LDR_Drive(a4)
		bsr	ldr_MotorOn		Reset serial shifter
		bsr	ldr_MotorOff		by turning motor on and off
		moveq	#0,d5
		move.w	#31,d1
.nextBit	bclr	d3,ciaprb(a3)		Select drive
		btst	#CIAB_DSKRDY,$bfe001
		bne.s	.bitClear		Active when low
		bset	d1,d5			Collect serial bits in d5
.bitClear	bset	d3,ciaprb(a3)		Deselect drive
		dbra	d1,.nextBit
		cmp.l	#-1,d5
		bne.s	.noDrive
		bset	d3,d4
		bset	#0,DRV_Status(a2)
		bsr	ldr_GoToCyl0
.noDrive	addq.b	#1,d3
		lea	DRV_SIZEOF(a2),a2
		dbra	d2,.driveLoop
		move.b	d4,LDR_DrivesAvail(a4)

		bsr.s	LoaderUpdate
		rts

*ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ*

LoaderExit	move.b	LDR_oldCRA(a4),ciacra(a3)
		move.w	#$1500,$9e(a5)
		move.w	LDR_oldADK(a4),$9e(a5)
		move.w	#$0210,$96(a5)
		move.w	LDR_oldDMA(a4),$96(a5)
		rts

*ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ*

LoaderUpdate	movem.l	a2/d2-3,-(sp)
		moveq	#3,d2
		move.b	d2,d3
		lea	LDR_Drive0(pc),a2
.loop		btst	#0,DRV_Status(a2)
		beq.s	.noUnit
		or.b	#$78,ciaprb(a3)		Deselect all drives
		bclr	d3,ciaprb(a3)		Select drive
		btst	#0,DRV_CylPos(a2)
		beq.s	.even
		bsr	ldr_MoveOut
		bra.s	.test
.even		bsr	ldr_MoveIn		
.test		bclr	#1,DRV_Status(a2)
		btst	#CIAB_DSKCHANGE,$bfe001
		beq.s	.noDisk
		bset	#1,DRV_Status(a2)
.noDisk
.noUnit		lea	DRV_SIZEOF(a2),a2
		addq.b	#1,d3
		dbra	d2,.loop
		or.b	#$78,ciaprb(a3)		Deselect all drives
		movem.l	(sp)+,a2/d2-3
		rts

*ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ-ญ*

	*	Control routine.

	*	Start block -> d0.l
	*	Number of blocks -> d1.l
	*	Drive to use -> d2.b
	*	Destination address -> a0

	* Returns success in d0

; What a mess...

Loader		tst.w	d1
		beq	.QuitLoader
		move.l	d0,d3
		add.w	d1,d0
		cmp.w	#1804,d0
		ble.s	.okSectorRange
		moveq	#-1,d0		Out of boundary sector read
		rts

.okSectorRange	lea	LDR_Drive0(pc),a2
		cmp.b	#0,d2
		beq.s	.rightUnit
		lea	DRV_SIZEOF(a2),a2
		cmp.b	#1,d2
		beq.s	.rightUnit
		lea	DRV_SIZEOF(a2),a2
		cmp.b	#2,d2
		beq.s	.rightUnit
		lea	DRV_SIZEOF(a2),a2
		cmp.b	#3,d2
		beq.s	.rightUnit
		moveq	#-2,d0		Drive not available
		rts

.rightUnit	addq.b	#3,d2
		moveq	#0,d0
		bset	d2,d0
		and.b	LDR_DrivesAvail(a4),d0
		bne.s	.driveExists
		moveq	#-2,d0		Drive not available
		rts

.driveExists	move.b	d2,LDR_Drive(a4)
		bsr	LoaderUpdate
		btst	#1,DRV_Status(a2)	Any disk?
		bne.s	.diskInserted
		moveq	#-3,d0		No disk in drive
		rts

.diskInserted	bsr	ldr_MotorOn
		divu.w	#11,d3
		move.b	d3,LDR_StartTrk(a4)
		swap 	d3
		move.b	d3,LDR_StartSec(a4)
		add.w	d3,d1
		swap	d3
		subq.w	#1,d1			End block
		divu.w	#11,d1
		move.b	d1,LDR_Tracks(a4)
		swap 	d1
		addq.w	#1,d1
		move.b	d1,LDR_EndSec(a4)	Amount of sectors to read on last track


		move.b	d3,d1			Start-track in d3.
		move.b	DRV_CylPos(a2),d2
		lsr.b	#1,d1
		cmp.b	d1,d2
		beq.s	.RightCyl		No need to move head.
		blt.s	.MoveInwards
		sub.b	d1,d2			Moving heads outwards.
		bsr	ldr_MoveOut
		subq.b	#1,d2
		beq.s	.RightCyl
		subq.b	#1,d2
		ext.w	d2
.MoveHeadOut	bsr	ldr_MoveHead
		dbra	d2,.MoveHeadOut
		bra.s	.RightCyl

.MoveInwards	sub.b	d2,d1			Moving heads inwards.
		bsr	ldr_MoveIn
		subq.b	#1,d1
		beq.s	.RightCyl
		subq.b	#1,d1
		ext.w	d1
.MoveHeadIn	bsr	ldr_MoveHead
		dbra	d1,.MoveHeadIn
.RightCyl	btst	#0,LDR_StartTrk(a4)		Time to pick side.
		beq.s	.LowerIt
		btst	#CIAB_DSKSIDE,ciaprb(a3)
		beq.s	.RightTrack
		bsr	ldr_Upper
		bra.s	.RightTrack

.LowerIt	btst	#CIAB_DSKSIDE,ciaprb(a3)
		bne.s	.RightTrack
		bsr	ldr_Lower
.RightTrack	move.b	LDR_StartSec(a4),d3	And now, the reading begins.
		move.b	LDR_Tracks(a4),d2
		beq.s	.LastTrack
		moveq	#11,d4
		bsr.s	ldr_Read
		tst.l	d0
		bne.s	.LoaderFail
.NextTrack	moveq	#0,d3
		btst	#CIAB_DSKSIDE,ciaprb(a3)
		bne.s	.NextSide
		bsr	ldr_Lower
		btst	#CIAB_DSKDIREC,ciaprb(a3)
		bne.s	.FirstMoveIn
		bsr	ldr_MoveHead
		bra.s	.NextRead

.FirstMoveIn	bsr	ldr_MoveIn
		bra.s	.NextRead

.NextSide	bsr	ldr_Upper
.NextRead	subq.b	#1,d2
		beq.s	.LastTrack
		bsr.s	ldr_Read
		tst.l	d0
		bne.s	.LoaderFail
		bra.s	.NextTrack

.LastTrack	move.b	LDR_EndSec(a4),d4
		bsr.s	ldr_Read
		tst.l	d0
		bne.s	.LoaderFail
		bsr.s	ldr_MotorOff
.QuitLoader	moveq	#0,d0
		rts

.LoaderFail	bsr.s	ldr_MotorOff
		rts

*===========================================================================*

ldr_MotorOn	move.b	LDR_Drive(a4),d0
		or.b	#$78,ciaprb(a3)	Set bits 3,4,5 and 6,
				;	deselect all drives.
		bclr	#CIAB_DSKMOTOR,ciaprb(a3)	Switch on motor.
		bclr	d0,ciaprb(a3)	Clear drive bit.
		rts

*ญ---------------------------------------------ญ*

ldr_MotorOff	move.b	LDR_Drive(a4),d0
		or.b	#$f8,ciaprb(a3)	Set bits 3,4,5,6 and 7,
				;	deselects all drives, motor off.
		bclr	d0,ciaprb(a3)	Clear drive bit.
		rts

*ญ---------------------------------------------ญ*

ldr_Read	move.b	LDR_Retries(a4),d5
		moveq	#0,d6
.reRead		move.b	#$91,ciatalo(a3)		Timer A low.
		move.b	#$29,ciatahi(a3)		Timer A hi, and starts timer.
.DSKRDY		btst	#CIAB_DSKRDY,$bfe001	Await Disk ready.
		bne.s	.DSKRDY
		bsr	ldr_Timer
		move.w	#2,$9c(a5)		Clear Disk Int. request.
		move.l	#ldr_TrackBuffer,$20(a5)	DSKPT, MFM-buffer.
		move.w	#$9900,$24(a5)		dsklen, read lenght.
		move.w	#$9900,$24(a5)		dsklen
.DMAwait	btst	#1,$1f(a5)		DMA transfer done when high.
		beq.s	.DMAwait	Imagine a sync is never found... Deadlock! :-)
		move.w	#$4000,$24(a5)		Disk DMA off.

		bsr.s	ldr_Decode
		tst.l	d0
		bne.s	.error
		rts
.error
		addq.b	#1,d6
		cmp.b	d6,d5
		bhs.s	.reRead
		rts

*ญ---------------------------------------------ญ*
	*	Destination address -> a0
	*	Start sector -> d3
	*	End sector -> d4

; In case of failure ldr_Decode only tries to decode what's left from last
; try.

ldr_Decode	movem.l	d2/d5-7/a1-2,-(sp)
		move.l	#$55555555,d7		%010101...

.FindSector	lea	ldr_TrackBuffer,a1
		move.l	#ldr_TrackBuffer+$3200-$440,d2
		move.w	#ldr_SyncWord,d5	Sync-word.
.SyncSearch	cmp.l	d2,a1			Check if within track buffer
		ble.s	.withinBuffer
		moveq	#-4,d0			Sync not found
		bra.s	.DecodeFail

.withinBuffer	cmp.w	(a1)+,d5		Check for Sync-word.
		bne.s	.SyncSearch
		cmp.w	(a1),d5			Another Sync-word?
		beq.s	.SyncSearch
		move.l	(a1)+,d0		Get sector we're looking at
		move.l	(a1),d1
		and.w	d7,d0
		add.w	d0,d0	; lsl.w	#1,d0
		and.w	d7,d1
		or.w	d1,d0
		lsr.w	#8,d0
		cmp.b	d3,d0			Correct sector?
		beq.s	.CorrectSctr
		lea	$43a(a1),a1	Move to next sector, 2nd sync word.
		bra.s	.SyncSearch

.CorrectSctr	lea	$30(a1),a1		Skip to Data checksum
		move.l	(a1)+,d6		Get Data-block checksum
		and.l	d7,d6

		moveq	#$7f,d2
		lea	$200(a1),a2
		moveq	#0,d5
.DeCodeLoop	move.l	(a1)+,d0
		and.l	d7,d0
		add.l	d0,d0	; lsl.l	#1,d0
		move.l	(a2)+,d1
		and.l	d7,d1
		or.l	d1,d0
		move.l	d0,(a0)+		Move to Load Address.
		eor.l	d0,d5
		dbra	d2,.DeCodeLoop

		move.l	d5,d1			Checksum control
		lsr.l	#1,d1
		eor.l	d1,d5
		and.l	d7,d5
		cmp.l	d5,d6
		beq.s	.chksumOk
		lea	-512(a0),a0		Step back faulty sector
		moveq	#-5,d0			Checksum error
.DecodeFail	movem.l	(sp)+,d2/d5-7/a1-2
		rts

.chksumOk	addq.b	#1,d3			Add sector we just processed
		cmp.b	d4,d3
		bne.s	.FindSector
		movem.l	(sp)+,d2/d5-7/a1-2
		moveq	#0,d0
		rts

*ญ---------------------------------------------ญ*

ldr_GoToCyl0	move.b	LDR_Drive(a4),d0
		or.b	#$78,ciaprb(a3)		Deselect all drives
		bclr	d0,ciaprb(a3)		Select drive
		btst	#CIAB_DSKTRACK0,$bfe001	Cyl 0 when low.
		beq.s	.AtCylPos0
		bsr.s	ldr_MoveOut
.TowardsCyl0	btst	#CIAB_DSKTRACK0,$bfe001	Cyl 0 when low.
		beq.s	.AtCylPos0
		bclr	#CIAB_DSKSTEP,ciaprb(a3)	Move head.
		bset	#CIAB_DSKSTEP,ciaprb(a3)	Prepare to move head.
		move.b	#$15,ciatalo(a3)	Timer A low.
		move.b	#$0b,ciatahi(a3)	Timer A hi, and starts timer.
		bsr	ldr_Timer		4ms
		bra.s	.TowardsCyl0

.AtCylPos0	clr.b	DRV_CylPos(a2)
		or.b	#$78,ciaprb(a3)		Deselect all drives
		rts

*ญ---------------------------------------------ญ*

ldr_Upper	bclr	#CIAB_DSKSIDE,ciaprb(a3)	Upper side.
		move.b	#$47,ciatalo(a3)	Timer A low.
		clr.b	ciatahi(a3)	Timer A hi, and starts timer.
		bra	ldr_Timer	100ตs

*ญ---------------------------------------------ญ*

ldr_Lower	bset	#CIAB_DSKSIDE,ciaprb(a3)	Lower side.
		move.b	#$47,ciatalo(a3)	Timer A low.
		clr.b	ciatahi(a3)	Timer A hi, and starts timer.
		bra.s	ldr_Timer	100ตs

*ญ---------------------------------------------ญ*

ldr_MoveOut	bset	#CIAB_DSKDIREC,ciaprb(a3)	Head direction outwards.
		bclr	#CIAB_DSKSTEP,ciaprb(a3)	Move head.
		bset	#CIAB_DSKSTEP,ciaprb(a3)	Prepare to move head.
		move.b	#$e1,ciatalo(a3)	Timer A low.
		move.b	#$31,ciatahi(a3)	Timer A hi, and starts timer.
		move.b	#-1,LDR_HeadDir(a4)
		subq.b	#1,DRV_CylPos(a2)
		bra.s	ldr_Timer	18ms

*ญ---------------------------------------------ญ*

ldr_MoveIn	and.b	#$fc,ciaprb(a3)	Clear bits 0 and 1,
		;	which results in diskdirec=inwards, head moved.
		bset	#CIAB_DSKSTEP,ciaprb(a3)	Prepare to move head.
		move.b	#$e1,ciatalo(a3)	Timer A low.
		move.b	#$31,ciatahi(a3)	Timer A hi, and starts timer.
		move.b	#1,LDR_HeadDir(a4)
		addq.b	#1,DRV_CylPos(a2)
		bra.s	ldr_Timer	18ms

*ญ---------------------------------------------ญ*

ldr_MoveHead	bclr	#CIAB_DSKSTEP,ciaprb(a3)	Move head.
		bset	#CIAB_DSKSTEP,ciaprb(a3)	Prepare to move head.
		move.b	#$50,ciatalo(a3)	Timer A low.
		move.b	#$08,ciatahi(a3)	Timer A hi, and starts timer.
		move.b	LDR_HeadDir(a4),d0
		add.b	d0,DRV_CylPos(a2)
;		bra.s	ldr_Timer	3ms

*ญ---------------------------------------------ญ*

ldr_Timer	btst	#CIAICRB_TA,ciaicr(a3)	Await Timer ready.
		beq.s	ldr_Timer
		rts

*ญ---------------------------------------------ญ*

		RSRESET

LDR_oldADK	rs.w	1
LDR_oldDMA	rs.w	1
LDR_oldCRA	rs.b	1

LDR_HeadDir	rs.b	1
LDR_StartTrk	rs.b	1
LDR_StartSec	rs.b	1
LDR_Tracks	rs.b	1
LDR_EndSec	rs.b	1
LDR_DrivesAvail	rs.b	1
LDR_Drive	rs.b	1
LDR_Retries	rs.b	1
LDR_SIZEOF	rs.b	0

LDR_vars	ds.b	LDR_SIZEOF


		RSRESET

DRV_CylPos	rs.b	1
DRV_Status	rs.b	1
DRV_SIZEOF	rs.b	0

LDR_Drive0	dcb.b	DRV_SIZEOF,0
LDR_Drive1	dcb.b	DRV_SIZEOF,0
LDR_Drive2	dcb.b	DRV_SIZEOF,0
LDR_Drive3	dcb.b	DRV_SIZEOF,0

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*

		Section Track,BSS_C

ldr_TrackBuffer	ds.w	$1900		12800 bytes, room for one MFM-track.

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*

		End

*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ*
Operation:				Wait Time:	Timervalue:
ญญญญญญญญญ				ญญญญญญญญญ	ญญญญญญญญญญ
 Motor on				500ms, DSKRDY	$56982
 Diskside stable before reading		100ตs		$47
 Diskside stable before writing		100ตs		$47
 Diskside stable after writing		1.3ms		$39A
 Diskstep				3ms		$850
 Reverse diskstep			18ms		$31E1
 Settle time				15ms		$2991
 Track 00 signal low after step		4ms		$B15
 Track 00 signal hi after step		1ตs		$1
 Step after drive select		1ตs		$1
 Direction select before step		1ตs		$1
 Direction select after step		1ตs		$1
 Keep low signal			1ตs		$1
