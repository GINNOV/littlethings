;---------------T-------T---------------T------------------------------------T
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; This source is © Copyright 1992-1995, Jesper Skov.
; Read "GhostRiderSource.ReadMe" for a description of what you may do with
; this source!
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; Please do not abuse! Thanks. Jesper
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»

;----------------------------------------------------
;- Name	: DiskLibrary
;- Description	: Contains all lowlevel disk commands.
;----------------------------------------------------
; Assemble, then save binary image from "s" to "e" to file
; "gri:disklibrary.bin".
;----------------------------------------------------
;- 291192.0000	First version with EntryDisk,ExitDisk and GetBlock.
;-	Should support the development of simple disk routines.
;-	Only read-routines. No error code/handler included.
;- 270893.0001	Included in routine index.
;- 280893.0002	All routines shined up. Now all should work 100%
;-	Removed bug in SeekTrack.
;-	Added InitDriveDOS to be used by DOSroutines (eg dir)
;-	Fixed bug in SeekTrack (CurrentTrack was not updated)
;-	All errors now cause call to PEMO. Relay on pre-call stack!
;- 280893.0003	Sets DiskChanged bit, forcing the system to update diskinfo.
;- 300893.0004	Added Low level savers.
;-	Added RAW write. SyncWord now fetched from BSS area.
;- 310893.0005	Fixed bug in datachecksummer.
;- 081093	Added support for HD disks. Added diskdrive-check. Now
;-	complaints if invalid drive or unknown drivetype.
;- 280794.0010	Put in external library. Now works 100%.
;----------------------------------------------------

LocalAssembly	set	2

b	equr	a5
h	equr	a6
	BASEREG	B,b

	incdir	include:
	include	hardware/custom.i
	include	hardware/dmabits.i
	include	hardware/intbits.i

	include	gr:includes/GRConstants.0003.s
	include	gr:includes/GRStructures.0001.s
	include	gr:includes/GRData.0016.s

	section	NeedfulThings,code

Push            macro                           ;push all or selected regs
                ifc     all,\1                  ;on the stack
                movem.l d0-a6,-(a7)
                else
                movem.l \1,-(a7)
                endc
                endm

Pull            macro                           ;pull all or selected regs
                ifc     all,\1                  ;from the stack
                movem.l (a7)+,d0-a6
                else
                movem.l (a7)+,\1
                endc
                endm

grcall	MACRO
	jsr	_LVO\1(b)
	ENDM

grgo	MACRO
	jmp	_LVO\1(b)
	ENDM

s	


;_LVOInitDrive		jmp	InitDrive
;_LVOInitDriveW		jmp	InitDriveW
;_LVOInitDriveDOS	jmp	InitDriveDOS
;_LVOInitDriveDOSW	jmp	InitDriveDOSW
;_LVOUpdateDisk		jmp	UpdateDisk
;_LVOMotorOff		jmp	MotorOff
;_LVOExitDisk		jmp	ExitDisk
;_LVOLoadTrack		jmp	LoadTrack
;_LVOLoadTrackNDec	jmp	LoadTrackNDec
;_LVOSaveTrack		jmp	SaveTrack
;_LVOSaveTrackAdd	jmp	SaveTrackAdd
;_LVOSaveRawTrack	jmp	SaveRawTrack
;_LVOSaveBlock		jmp	SaveBlock
;_LVOSaveBlockAdd	jmp	SaveBlockAdd
;_LVOGetBlock		jmp	GetBlock
;_LVOGetBlockToAdd	jmp	GetBlockToAdd
;			ReadBatClock
;			Amiga2Date
;			TimerWait0.1ms

;w;
	bra.w	InitDrive
	bra.w	InitDriveW
	bra.w	InitDriveDOS
	bra.w	InitDriveDOSW
	bra.w	UpdateDisk
	bra.w	MotorOff
	bra.w	ExitDisk
	bra.w	LoadTrack
	bra.w	LoadTrackNDec
	bra.w	SaveTrack
	bra.w	SaveTrackAdd
	bra.w	SaveRawTrack
	bra.w	SaveBlock
	bra.w	SaveBlockAdd
	bra.w	GetBlock
	bra.w	GetBlockToAdd
	bra.w	ReadBatClock
	bra.w	Amiga2Date
	bra.w	TimerWait0.1ms

DL_PrintErrorMO	jmp	_LVOPrintErrorMO(b)

DL_PrintError	jmp	_LVOPrintError(b)

;---- Reset disk to pre-entry status
;-- Only takes care of selected drive (DF0:)
;----
ExitDisk	moveq	#3,d2	;reset DF0-3 to entry pos
	lea	SystemTracks(b),a2
	clr.b	SelectedDrive(b);start with df0
.exitdiskloop	moveq	#0,d0
	move.w	(a2)+,d0	;been fiddled with?
	bmi.b	.notused
	bsr.w	SelectDrive
	btst	#2,CIAA_PRA	;skip if disk has been removed
	beq.b	.notused
	move.l	d0,-(a7)
	bsr.w	MotorOn	;but reposition for scumbag coders
	bsr.w	SeekTrackZero
	move.l	(a7)+,d0
	bsr.w	SeekTrack
	bsr.w	MotorOff
.notused	addq.b	#1,SelectedDrive(b);goto next drive
	dbra	d2,.exitdiskloop
	rts

;---- Initialize selected drive for DOS disk action and turn motor on
InitDriveDOSW	moveq	#1,d0
	bra.b	InitDriveDOSM

InitDriveDOS:	moveq	#0,d0
InitDriveDOSM	Push	d2-d4/d6/d7/a0
	moveq	#-1,d6	;signal DOS check
	bra.b	InitDriveMain

;---- Initialize selected drive for disk action and turn motor on
;-- Returns status in d0
;----
InitDriveW	moveq	#1,d0
	bra.b	InitDriveM

InitDrive:	moveq	#0,d0
InitDriveM	Push	d2-d4/d6/d7/a0
	moveq	#0,d6	;signal no DOS check

InitDriveMain	moveq	#0,d2
	move.b	SelectedDrive(b),d2
	moveq	#0,d4	;check diskID
	moveq	#31,d1
	and.b	#$7f,CIAB_PRB
	move.w	d2,d4
	moveq	#0,d3
	addq.b	#3,d2
	bset	d2,d3
	moveq	#-1,d2
	eor.w	d3,d2

	and.b	d2,CIAB_PRB
	or.b	d3,CIAB_PRB
	or.b	#$80,CIAB_PRB
	and.b	d2,CIAB_PRB
	or.b	d3,CIAB_PRB

.getid	and.b	d2,CIAB_PRB
	add.l	d4,d4
	btst	#5,CIAA_PRA
	beq.b	.no
	bset	#0,d4
.no	or.b	d3,CIAB_PRB
	dbra	d1,.getid

;$00000000 DD
;$AAAAAAAA HD
;$FFFFFFFF N/A

	moveq	#11,d1
	tst.l	d4
	beq.b	.secsok
	moveq	#22,d1
	cmp.l	#$aaaaaaaa,d4
	beq.b	.secsok
	moveq	#EV_NOTAVALIDDRIVENO,d1;drive not present
	cmp.l	#-1,d4
	beq.w	.TrackError
	moveq	#EV_UNKNOWNDRIVETYPE,d1;unknown type
	bra.w	.TrackError

.secsok	move.b	d1,DiskSectors(b)
	lea	DiskSectorsTab(b),a0
	move.b	d1,(a0,d4.w)
	moveq	#0,d2
	move.b	SelectedDrive(b),d2
	add.w	d2,d2
	lea	TrackLenTab(b),a0
	cmp.b	#11,d1
	beq.b	.dddisk
	lea	TrackLenHTab(b),a0
.dddisk	move.w	(a0,d2.w),TrackLen(b)
	add.w	d2,d2
	lea	DiskSyncTab(b),a0
	move.l	(a0,d2.w),DiskSyncs(b)

	move.w	#880,d2	;calc ROOT-block
	cmp.b	#11,d1
	beq.b	.dddisk2
	add.w	d2,d2
.dddisk2	move.w	d2,ROOTBlock(b)
	add.w	d2,d2	;and the highest block#
	move.w	d2,MaxBlock(b)

	bsr.w	SelectDrive
	moveq	#0,d2
	move.b	SelectedDrive(b),d2
	btst	#2,CIAA_PRA	;have disk been removed
	beq.w	.CheckNewDisk

.DiskInDrive	tst.w	d0	;check WP?
	beq.b	.NoWPCheck
	btst	#3,CIAA_PRA	;write protected?
	bne.b	.NoWPCheck
	moveq	#EV_DISKWRITEPROTECTED,d1
	bra.w	.TrackError

.NoWPCheck	bsr.w	MotorOn
	move.w	CurrentTrack(b),d1
	bmi.b	.ExamineDisk
	tst.w	d6	;system?
	beq.w	.TrackOK	;if not simply exit
	tst.b	DOSFormat(b)	;else check DOS format
	bpl.w	.TrackOK	;and exit if OK. Else try to read
			;bootblock again
.ExamineDisk	st.b	DOSFormat(b)
	bsr.w	SeekTrackZero
	lea	FirstAccess(b),a0;check for first access
	tst.b	(a0,d2.w)
	bne.b	.first
	st.b	(a0,d2.w)	;flag not first access
	add.w	d2,d2	;if first access, save system track
	lea	SystemTracks(b),a0
	move.w	d7,(a0,d2.w)

.first	tst.w	d6	;exit if not a system call
	beq.b	.TrackOK

	moveq	#0,d0
	move.b	SelectedDrive(b),d0
	add.w	d0,d0
	lea	CDTable(b),a0
	move.w	ROOTBlock(b),(a0,d0.w);set default CD to ROOT
	move.w	ROOTBlock(b),8(a0,d0.w);set backup CD to ROOT
;	move.w	ROOTBlock(b),CurrentDir(b)

	moveq	#0,d0
	bsr.w	LoadTrack	;get track 0 (bootblock)
	bmi.b	.TrackError

	moveq	#0,d1
	move.l	_LSOTrackBuffer(b),a0
	move.l	(a0),d0

	clr.b	FastFileSystem(b);clr FFS flag
	btst	#0,d0	;FFS?
	beq.b	.OFS
	st.b	FastFileSystem(b);flag FFS
.OFS	move.b	d0,DOSFormat(b)	;set DOS format
	move.b	d0,d2
	bmi.b	.illegalDOS
	clr.b	d0
	cmp.l	#'DOS'<<8,d0	;check DOSx
	bne.b	.illegalDOS
	cmp.b	#5,d2	;check DOS0-5
	ble.b	.TrackOK

.illegalDOS	st.b	DOSFormat(b)	;signal illegal format
	moveq	#EV_NOTAMIGADOSFORMAT,d1
.TrackError	tst.b	DiskInfoFlag(b)
	bne.b	.TrackExit
	Pull	d2-d4/d6/d7/a0
	addq.w	#4,a7	;skip caller
	bra.w	DL_PrintErrorMO	;kill motor if not a valid DOS

.TrackOK	moveq	#0,d1	;let motor run
.TrackExit	Pull	d2-d4/d6/d7/a0
	tst.w	d1
	rts

.CheckNewDisk	movem.l	d0/a0,-(a7)
	move.w	#10,CurrentTrack(b);fool stepper to allow step
	btst	#4,CIAA_PRA	;check for new disk by stepping heads
	beq.b	.trackzero	;if not over trk0
	moveq	#-1,d0
	bsr.w	StepHeads	;step out (towards trk0)
	moveq	#0,d0
	bsr.w	StepHeads
	bra.b	.stepped

.trackzero	moveq	#0,d0
	bsr.w	StepHeads	;if trk0 step in and out
	moveq	#-1,d0
	bsr.w	StepHeads
.stepped
	moveq	#0,d0
	move.b	SelectedDrive(b),d0
	add.w	d0,d0
	lea	CDTable(b),a0
	move.w	ROOTBlock(b),(a0,d0.w);set default CD to ROOT
	move.w	ROOTBlock(b),8(a0,d0.w);set backup CD to ROOT
;	move.w	ROOTBlock(b),CurrentDir(b)

	movem.l	(a7)+,d0/a0

	move.w	#-1,CurrentTrack(b);Clear all disk flags
	clr.b	TrackInBuffer(b)
	clr.b	TrackModified(b)
	btst	#2,CIAA_PRA	;check for no-disk
	bne.w	.DiskInDrive
	moveq	#EV_NODISK,d1
	bra.w	.TrackError	;return error

;---- Turn ON the selected drive
MotorOn
;Do some (gaining rotation speed) flash :)

	st.b	CurrentSector(b);sector display inactive
	st.b	HeaderDiskInfo(b);start header updates
	st.b	IRQSecPos(b)

	bsr.b	SelectDrive
	Push	d0/d1
	moveq	#500/5-1,d1	;motor guaranteed to be spinning after 500ms
.MotorWait	moveq	#5,d0	;test motor spin signal each 5ms
	bsr.w	TimerWaitMS
	btst	#5,CIAA_PRA	;wait for full spin
	beq.b	.spinning
	dbra	d1,.MotorWait
.spinning	Pull	d0/d1
	rts

;---- Select selected drive
SelectDrive	Push	d0/d1
	move.b	SelectedDrive(b),d1;get selected drive number
	addq.b	#3,d1
	move.b	#$87,d0
	bset	d1,d0
	or.b	#$f9,CIAB_PRB	;motor=off,deselect df0-3
	and.b	d0,CIAB_PRB	;select all but selected so they see motor
	or.b	#$78,CIAB_PRB	;deselect df0-3
	and.b	#$7f,CIAB_PRB	;motor=on
	moveq	#-1,d0
	bclr	d1,d0	;fix mask
	and.b	d0,CIAB_PRB	;select selected drive
	Pull	d0/d1
	rts

;---- Turn OFF all drives
MotorOff	or.b	#$f8,CIAB_PRB	;motor=off, deselect df0-3
	and.b	#$87,CIAB_PRB	;select df0-3 so they see motor
	or.b	#$f8,CIAB_PRB	;deselect df0-3

	clr.b	HeaderDiskInfo(b);stop header updates
	st.b	ReprintHeader(b);and request header reprint

	rts

;---- Step Heads
;-- Input:	D0	0=step inward (inc). -1=step outward (dec) (track 0)
;-- If track -1 or 160 is reached -> Freeze (RED)
;----
StepHeads	moveq	#2,d1
	and.w	d0,d1
	beq.b	.TrackInc
	subq.w	#2,CurrentTrack(b)
	bpl.b	.StepOK
	addq.w	#2,CurrentTrack(b);return without stepping!
.IllegalStep	moveq	#DE_ILLEGALTRACK,d1
	bra.w	DL_PrintErrorMO

.TrackInc	cmp.w	#158,CurrentTrack(b);Ok to step in?
	bge.b	.IllegalStep
	addq.w	#2,CurrentTrack(b);yeah

.StepOK	cmp.b	LastStepDir(b),d1;last direction=request
	beq.b	.continue
	move.b	d1,LastStepDir(b);no, set last direction=req

	moveq	#SettleDelay,d0
	bsr.b	TimerWaitMS	;and wait for settle delay

.continue	bclr	#1,CIAB_PRB	;set direction
	or.b	d1,CIAB_PRB

	bclr	#0,CIAB_PRB	;and send step pulse
	bset	#0,CIAB_PRB

	moveq	#StepDelay,d0
	bsr.b	TimerWaitMS	;wait for step-delay
	moveq	#0,d1
	rts

;---- Wait specified time
;-- INPUT:	d0.w -	Time in miliseconds
;----
TimerWaitMS	mulu	#10,d0
TimerWaitMS10	subq.w	#1,d0
.WaitLoop	bsr.b	TimerWait0.1ms	;only 1/10 ms at a time to prevent
	dbra	d0,.WaitLoop	;too much conflict with vblank
	rts

TimerWait0.1ms	move.w	d0,-(a7)
	move.w	#$4000,intena(h)
	move.b	#$7f,CIAB_ICR	;clr irq requests
	and.b	#~(5<<1!1<<1),CIAB_CRA;count full cycles (2pi <> 1pi) ! No CPU output
	or.b	#1<<3,CIAB_CRA	;oneshot

	move.w	Delay0.1ms(b),d0
	move.b	d0,CIAB_TALO
	lsr.w	#8,d0
	move.b	d0,CIAB_TAHI

.HangOn	btst	#0,CIAB_ICR	;wait for timer
	beq.b	.HangOn

	move.b	#$7f,CIAB_ICR

	move.w	#$c000,intena(h)

	move.w	(a7)+,d0

	rts

;---- Seek outwards until Track Zero is found
;-- Output:	D7 -	Previous position (track 0-159)
;----
SeekTrackZero	move.b	#'S',DiskDMADirection(b)
	moveq	#0,d7
	move.w	#200,CurrentTrack(b);fool StepHeads to OK step out
.SeekTZLoop	btst	#4,CIAA_PRA
	beq.b	.TrackZeroFound
	moveq	#-1,d0	;step outwards
	bsr.w	StepHeads
	addq.w	#2,d7	;count the steps (=2*track)
	bra.b	.SeekTZLoop

.TrackZeroFound	move.b	CIAB_PRB,d0
	btst	#2,d0	;also find side
	bne.b	.side0
	bset	#0,d7
.side0	bset	#2,d0	;and then force side to 0
	move.b	d0,CIAB_PRB	;(track 0)
	clr.w	CurrentTrack(b)
	clr.b	TrackInBuffer(b)
	move.b	#2,LastStepDir(b);signal last step waz outwards
	rts

;---- Seek Track
;-- Input:	D0 -	Track to seek (0-159)
;----
SeekTrack	move.b	#'S',DiskDMADirection(b)
	Push	d0-d3
	move.b	CIAB_PRB,d1
	lsr.w	#1,d0
	scc.b	d2
	moveq	#%100,d3
	and.w	d3,d2	;wanted bit state
	and.w	d1,d3	;actual bit state
	cmp.w	d2,d3	;equal?
	beq.b	.SelectSide
	bchg	#2,d1	;if not, change side

	move.l	d0,d3
	moveq	#13,d0
	bsr.w	TimerWaitMS10	;wait 1.3 ms as stated in RKM

	move.b	d1,CIAB_PRB	;change side

	moveq	#1,d0
	bsr.w	TimerWaitMS10	;wait 0.1 ms as stated in RKM
	move.l	d3,d0

;Above actually only needed when writing data, but what the hell?

;	bset	#2,d1	;head 0
;	lsr.w	#1,d0
;	bcc.b	.SelectSide
;	bclr	#2,d1	;change head

.SelectSide	moveq	#0,d3	;seek inwards (inc)
	move.w	CurrentTrack(b),d2
	lsr.w	#1,d2
	sub.b	d2,d0
	beq.b	.TrackFound	;exit if equ tracknumbers!

	bpl.b	.SeekDirOk	;if CT<D0 direction ok
	moveq	#-1,d3	;else, change to outwards (dec)
	neg.b	d0

.SeekDirOk	and.w	#$ff,d0
	move.w	d0,d2
	subq.w	#1,d2
.SeekLoop	move.w	d3,d0
	bsr.w	StepHeads
	dbra	d2,.SeekLoop

.TrackFound	Pull	d0-d3
	move.w	d0,CurrentTrack(b)
	rts

;---- Load Track
;-- Input:	D0 -	Track number (0-159)
;-- 	d1 -	0=decode track
;----
LoadTrack:	moveq	#0,d1
LoadTrackNDec	Push	d2-a4
	move.w	d1,d2

	cmp.w	CurrentTrack(b),d0;same track?
	beq.b	.SameTrack

	bsr.b	SeekTrack	;go to rigth track
	clr.b	TrackInBuffer(b);track can't be in buffer now

.SameTrack	tst.b	TrackInBuffer(b);track loaded?
	bne.b	.TrackLoaded

	clr.b	DiskErrRetries(b)

.Retry	move.w	#$4000,dsklen(h);Init disk
	move.w	DiskSyncs(b),dsksync(h)
	move.w	#$7f00,adkcon(h)
	move.w	#$9500,d0	;precomp value = %00 = 0 ns
	cmp.w	#80,CurrentTrack(b)
	bls.b	.ChangePrecomp
	or.w	#$2000,d0	;precomp value = %01 = 140 ns
.ChangePrecomp	move.w	d0,adkcon(h)
	move.w	#$0002,intreq(h)

	move.b	#'R',DiskDMADirection(b)

	move.l	ChipMem(b),d0;and load track to buffer
	add.l	_LSODiskBuffer(b),d0
	move.l	d0,dskpt(h)
	moveq	#0,d0
	bsr.w	StartDisk	;read track
	bmi.b	.diskerror

	tst.w	d2
	bne.b	.TrackOK	;fast exit if no decode
	bsr.b	DecodeTrack	;and decode
	beq.b	.TrackOK

.diskerror	move.w	#$f00,$dff180

	addq.b	#1,DiskErrRetries(b);inc error counter

	move.b	pr_DiskRetries(b),d0
	cmp.b	DiskErrRetries(b),d0
	bne.b	.Retry

	tst.b	DiskInfoFlag(b)
	beq.w	DL_PrintErrorMO
	tst.w	d1
	bra.b	.TrackLoaded

.TrackOK	st.b	TrackInBuffer(b);track is now in buffer!
	st.b	DiskDMADirection(b)

	moveq	#0,d1
.TrackLoaded
	Pull	d2-a4
	rts

DecodeTrack:	lea	EyeSectorTable(b),a4;eye cream!
	clr.b	IRQSecPos(b)

	clr.l	SectorCount(b)
	move.l	ChipMem(b),a0	;call 1st with d5=-1
	add.l	_LSODiskBuffer(b),a0;Decode Track
	move.l	a0,a1
	add.w	TrackLen(b),a1	;buffer-end
	move.l	_LSOTrackBuffer(b),a2
	move.l	FiveLong(pc),d7
	moveq	#0,d5	;find xx sectors
	move.b	DiskSectors(b),d5
	subq.w	#1,d5
	move.w	DiskSyncs(b),d4
.FindSectors	cmp.l	a1,a0
	bge.w	.NotAllSectors
	cmp.w	(a0)+,d4
	bne.b	.FindSectors
	cmp.w	(a0),d4	;check for more syncs in serie
	beq.b	.FindSectors

.SectorFound	move.l	(a0)+,d0	;check first long
	move.l	(a0)+,d1
	and.l	d7,d0
	and.l	d7,d1
	add.l	d0,d0
	or.l	d1,d0
	swap	d0

	cmp.b	CurrentTrack+1(b),d0;track # match?
	bne.w	.SeekError

	move.w	#$ff00,d1	;amiga format
	and.w	d1,d0
	cmp.w	d1,d0
	bne.w	.BadSectorID
	clr.w	d0
	swap	d0
	and.w	d1,d0	;sector number
	bmi.w	.IllegalSector

	subq.w	#8,a0
	moveq	#(48-8)/4-1,d6
	moveq	#0,d3
.SumHeaderLoop	move.l	(a0)+,d2
	eor.l	d2,d3
	dbra	d6,.SumHeaderLoop
	and.l	d7,d3	;get rid of clock bits
	move.l	(a0)+,d2	;get header checksum
	move.l	(a0)+,d6
	and.l	d7,d2
	and.l	d7,d6
	add.l	d2,d2
	or.l	d6,d2
	cmp.l	d2,d3	;checksums match?
	bne.w	.BadHeaderSum

	move.w	d0,d6
	lsr.w	#8,d6
	cmp.b	DiskSectors(b),d6;0-10/0-21
	bge.w	.IllegalSector

	move.b	d6,CurrentSector(b)
;	move.b	d6,(a4)+

	add.w	d0,d0
	move.l	SectorCount(b),d2
	bset	d6,d2
	move.l	d2,SectorCount(b)

	lea	(a2,d0.w),a3	;pointer to sector block
;	add.w	#40,a0
	move.l	(a0)+,d6
	move.l	(a0)+,d0
	and.l	d7,d6
	and.l	d7,d0
	add.l	d6,d6
	or.l	d0,d6	;block checksum
	moveq	#512/4-1,d2	;decode 512 bytes
	moveq	#0,d3
.DeCodeSector	move.l	512(a0),d1
	move.l	(a0)+,d0
	and.l	d7,d0
	and.l	d7,d1

	eor.l	d0,d3	;make checksum
	eor.l	d1,d3

	add.l	d0,d0
	or.l	d1,d0

	move.l	d0,(a3)+
	dbra	d2,.DeCodeSector
	and.l	d7,d3	;checksum correct?
	cmp.l	d3,d6
	bne.b	.ChecksumError
	lea	512(a0),a0	;skip 2nd part of decoded sector
	dbra	d5,.FindSectors	;find all sectors

	move.l	SectorCount(b),d0

	move.l	#%11111111111,d2
	move.w	d0,d1
	and.w	d2,d1
	cmp.w	d2,d1	;all low sectorbits must be valid
	bne.b	.NotAllSectors	;else fail

	moveq	#11,d1
	lsr.l	d1,d0	;rol out low 11 sectorbits
	cmp.l	d2,d0
	beq.b	.okexit	;return ok if all upper bits set
	tst.l	d0	;if not HD, all must be zero
	bne.b	.NotAllSectors	;else missing sectors on HD

.okexit	moveq	#EV_OK,d1
.exit	st.b	CurrentSector(b)
	clr.l	SectorCount(b)	;only do sectorcount for header info
	tst.w	d1
	rts

.NotAllSectors	moveq	#EV_NOTALLSECTORS,d1;less than 11 sectors found
	bra.b	.exit

.SeekError	moveq	#EV_SEEKERROR,d1;track# not correct
	bra.b	.exit

.BadSectorID	moveq	#EV_BADSECID,d1;not amiga format-code
	bra.b	.exit

.IllegalSector	moveq	#EV_BADUNITNUM,d1;illegal sector number
	bra.b	.exit

.ChecksumError	moveq	#EV_BADSECSUM,d1;sector checksum error
	bra.b	.exit

.BadHeaderSum	moveq	#EV_BADHDRSUM,d1;header checksum error
	bra.b	.exit


;---- Start Disk DMA and wait for it to finish
;-- Input:	d0 -	disklen+$8000
;----
StartDisk	Push	d2
	move.w	TrackLen(b),d0
	lsr.w	#1,d0
	or.w	#$8000,d0
	move.l	d0,d2	;test for write
	bpl.b	.load
	or.w	#$4000,d0	;or writeflag
.load	move.w	#$0002,intreq(h)
	move.w	d0,dsklen(h)	;start disk DMA
	move.w	d0,dsklen(h)

	moveq	#400/4-1,d1	;max wait 400 milisecs for read to finish
	cmp.b	#22,DiskSectors(b)
	bne.b	.DiskWait
	add.w	d1,d1	;half speed drive

;---- Wait for disk dma to finish
.DiskWait	btst	#1,intreqr+1(h)
	bne.b	.DiskDone
	tst.l	d2	;reading?
	bmi.b	.DiskWait	;if saving, wait dead loop

	moveq	#4,d0
	bsr.w	TimerWaitMS

	dbra	d1,.DiskWait
	move.w	#$4000,dsklen(h)
	Pull	d2
	moveq	#EV_NOSECHDR,d1
	rts

.save
.DiskDone	move.w	#$4000,dsklen(h);disable disk DMA
	move.w	#$0002,intreq(h);and kill IRQR
	grcall	FlushCache

	Pull	d2
	moveq	#0,d1
	rts

;---- Save RAW track to disk
;- d0 - tracknumber
;- data in diskbuffer+chip
;----
SaveRawTrack	bsr.b	.glue
	clr.b	TrackInBuffer(b);no data in buffer!
	rts

.glue	Push	d0-a4
	bra.b	STRawEntry

;---- Save track to disk
;- a0 - Data pointer
;- d0 - tracknumber
;----
SaveTrack:	move.l	_LSOWriteBuffer(b),a0
	move.b	#'W',DiskDMADirection(b)
SaveTrackAdd	Push	d0-a4
	move.l	a0,a1	;copy to input buffer
	move.l	_LSOTrackBuffer(b),a2
	move.w	#512*11/4/4-1,d1
	cmp.b	#22,DiskSectors(b)
	bne.b	.copydata
	add.w	d1,d1
	addq.w	#1,d1
.copydata	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	dbra	d1,.copydata

	move.w	d0,-(a7)
	bsr.w	EncodeTrack
	move.w	(a7)+,d0
STRawEntry	move.w	d0,-(a7)
	grcall	FlushCache
	move.w	(a7)+,d0
	clr.b	TrackInBuffer(b)

	cmp.w	CurrentTrack(b),d0;same track?
	beq.b	.SameTrack

	bsr.w	SeekTrack	;else go to rigth track

.SameTrack	move.w	#$4000,dsklen(h);Init disk

	move.l	ChipMem(b),d0	;and save track
	add.l	_LSODiskBuffer(b),d0
	move.l	d0,dskpt(h)

	move.w	DiskSyncs(b),dsksync(h)
	move.w	#$7f00,adkcon(h)
	move.w	#$9100,d0	;precomp value = %00 = 0 ns
	cmp.w	#80,CurrentTrack(b)
	bls.b	.ChangePrecomp
	or.w	#$2000,d0	;precomp value = %01 = 140 ns
.ChangePrecomp	move.w	d0,adkcon(h)

	moveq	#-1,d0
	bsr.w	StartDisk	;write track

	Pull	d0-a4

	tst.b	DiskVerify(b)
	beq.b	.NoVerify

	Push	d0-a4

	move.b	DiskInfoFlag(b),d7
	st.b	DiskInfoFlag(b)	;don't complain!

	bsr.w	LoadTrack	;reload track from disk

	move.b	d7,DiskInfoFlag(b)

	tst.w	d1
	bne.b	.VerifyFail	;if track not loaded

	move.l	_LSOTrackBuffer(b),a1
	moveq	#0,d1
	move.b	DiskSectors(b),d1
	asl.w	#9-2,d1	;*512/4
	subq.w	#1,d1
.CompareData	cmpm.l	(a0)+,(a1)+
	bne.b	.VerifyFail	;D0 must contain track no
	dbra	d1,.CompareData

	Pull	d0-a4

.NoVerify	st.b	DiskDMADirection(b)
	st.b	TrackInBuffer(b);readbuffer valid if diskIO OK
	moveq	#0,d1	;get Z return flag (no error)
	rts

.VerifyFail	Pull	d0-a4
	grgo	HandleVerifyE
	;This routine should either return fail (!Z) so the calling
	;routine can stop, or JMP to SaveTrackAdd to retry.
	; D0 - contain track #, A0 - Data pointer

;- a0 - data (11*256)
;- d0 - track
EncodeTrack:	move.l	ChipMem(b),a4
	add.l	_LSODiskBuffer(b),a4

	moveq	#0,d2	;rest with plain $aa
	move.w	TrackLen(b),d2
	move.w	#11*$440,d1
	cmp.b	#22,DiskSectors(b)
	bne.b	.hd
	add.w	d1,d1
.hd	sub.w	d1,d2
	lsr.w	#2,d2
	subq.w	#1+1,d2	;sub one for the last AAAA long
	move.l	AAAALong(pc),d4	;put AAAA longs in the start
.fillgap	move.l	d4,(a4)+
	dbra	d2,.fillgap

	move.l	a0,a2
	
	moveq	#0,d7	;sec #
	move.w	d0,d7	;trac #
	moveq	#0,d6	;do
	move.b	DiskSectors(b),d6;11/22 sectors

.BuildMFMLoop	move.b	d7,CurrentSector(b)

	moveq	#0,d0
	move.l	a4,a0
	bsr.w	.WriteLong

	move.l	DiskSyncs(b),4(a4);sync marks

	move.w	d7,d0	;build info. first track #
	or.w	#$ff00,d0	;amiga format
	swap	d0
	swap	d7
	move.w	d7,d0	;sec #
	asl.w	#8,d0
	move.b	d6,d0	;gap dist
	addq.w	#1,d7	;inc sec# for next loop
	swap	d7

	lea	8(a4),a0
	bsr.b	.WriteLong

	moveq	#3,d2
.ClrFreeArea	moveq	#0,d0
	bsr.b	.WriteLong
	dbra	d2,.ClrFreeArea

	lea	8(a4),a0
	moveq	#$28,d1
	bsr.w	.ChecksumArea

	lea	48(a4),a0
	bsr.b	.WriteLong

	moveq	#$200/4-1,d3
	lea	64(a4),a1

.EncodeDataLoop	move.l	(a2)+,d0
	move.l	d0,d4
	lsr.l	#1,d0
	move.l	a1,a0
	bsr.b	.CodeLong
	bsr.b	.CorrectNext	;needs only be done at border!
	lea	$200(a1),a0
	move.l	d4,d0
	bsr.b	.CodeLong
	bsr.b	.CorrectNext	;needs only be done at border!
	addq.w	#4,a1
	dbra	d3,.EncodeDataLoop

	lea	64(a4),a0
	move.w	#$400,d1
	bsr.b	.ChecksumArea
	lea	56(a4),a0
	bsr.b	.WriteLong

	add.w	#$440,a4
	subq.w	#1,d6
	bne.b	.BuildMFMLoop

	moveq	#0,d0
	move.l	a4,a0
	bsr.b	.WriteLong

	st.b	CurrentSector(b)

	rts


.WriteLong	Push	d2/d3
	move.l	d0,d3
	lsr.l	#1,d0
	bsr.b	.CodeLong
	move.l	d3,d0
	bsr.b	.CodeLong
	bsr.b	.CorrectNext
	Pull	d2/d3
	rts

.CodeLong	and.l	FiveLong(pc),d0
	move.l	d0,d2
	eor.l	#$55555555,d2
	move.l	d2,d1
	lsl.l	#1,d2
	lsr.l	#1,d1
	bset	#31,d1
	and.l	d2,d1
	or.l	d1,d0
	btst	#0,-1(a0)
	beq.b	.BitNULL
	bclr	#31,d0
.BitNULL	move.l	d0,(a0)+
	rts

.CorrectNext	move.b	(a0),d0
	btst	#0,-1(a0)
	bne.b	.BitSet
	btst	#6,d0
	bne.b	.Done
	bset	#7,d0
	bra.b	.SetByte

.BitSet	bclr	#7,d0
.SetByte	move.b	d0,(a0)
.Done	rts


.ChecksumArea	move.l	d2,-(a7)
	lsr.w	#2,d1
	subq.w	#1,d1
	moveq	#0,d0
.SumLoop	move.l	(a0)+,d2
	eor.l	d2,d0
	dbra	d1,.SumLoop
	and.l	FiveLong(pc),d0
	move.l	(a7)+,d2
	rts


AAAALong	dc.l	$aaaaaaaa
FiveLong	dc.l	$55555555

;---- Save block to disk
;- d0 - block # (data in BlockBuffer)
SaveBlock:	move.l	_LSOBlockBuffer(b),a0
SaveBlockAdd	Push	d0-a4
	moveq	#0,d7	;clear top bits
	move.w	d0,d7
	move.l	d7,d0

	moveq	#0,d1
	move.b	DiskSectors(b),d1
	divu	d1,d0
	tst.w	WriteTrackNo(b)	;no update if empty
	bmi.b	.NoUpdate
	cmp.w	WriteTrackNo(b),d0;no update if same track
	beq.b	.NoUpdate

	Push	d0/a0
	bsr.b	UpdateDisk
	Pull	d0/a0

.NoUpdate	move.w	d0,WriteTrackNo(b)
	swap	d0
	lea	SectorTable(b),a1
	st.b	(a1,d0.w)	;flag sector data
	mulu	#512,d0	;find sector entry
	move.l	_LSOWriteBuffer(b),a1
	add.w	d0,a1
	moveq	#512/4-1,d0
.copydata	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra	d0,.copydata	
	moveq	#0,d1
	Pull	d0-a4
	rts

;---- Write to disk if data in buffer
UpdateDisk:	Push	d0/d1/d7/a0/a1
	move.w	WriteTrackNo(b),d0
	bmi.b	.NoUpdate
	move.l	d0,d7
	moveq	#0,d1
	move.b	DiskSectors(b),d1
	mulu	d1,d0
	lea	SectorTable(b),a1
	move.l	_LSOWriteBuffer(b),a0
	subq.w	#1,d1
.checkload	tst.b	(a1)
	bne.b	.countup
	Push	d0/d1/a0/a1	;if empty
	bsr.b	GetBlockToAdd	;load block
	Pull	d0/d1/a0/a1
.countup	clr.b	(a1)+	;clear sector flag
	addq.w	#1,d0	;count block up
	lea	$200(a0),a0	;add to writebuffer
	dbra	d1,.checkload

	move.l	d7,d0	;now save track
	bsr.w	SaveTrack
	move.w	#-1,WriteTrackNo(b)

.NoUpdate	Pull	d0/d1/d7/a0/a1
	rts

;---- Load Block to BlockBuffer
;-- Input:	D0 -	Block Number (0-1759)
;----
GetBlock:	move.l	_LSOBlockBuffer(b),a0

;---- Load block to address
;-- Input:	D0 -	Block Number (upper word will be cleared)
;--	A0 -	Address
;----
GetBlockToAdd	moveq	#EV_ILLEGALBLOCK,d1
	Push	d0/d2-d3/d7/a0/a1

	swap	d0	;allow "lazy" blocknumbers (.w)
	clr.w	d0
	swap	d0

	move.w	#1760,d2
	moveq	#0,d3
	move.b	DiskSectors(b),d3
	cmp.b	#11,d3
	beq.b	.dd
	add.w	d2,d2
.dd	tst.l	d0
	bmi.w	DL_PrintErrorMO
	cmp.w	d2,d0
	bge.w	DL_PrintErrorMO

	divu	d3,d0	;get track number
	swap	d0
	move.w	d0,d7
	clr.w	d0
	swap	d0

	bsr.w	LoadTrack	;and load it!

	moveq	#9,d0
	asl.w	d0,d7	;copy wanted sector to address
	move.l	_LSOTrackBuffer(b),a1
	add.w	d7,a1
	moveq	#512/4-1,d0
.copy	move.b	(a1)+,(a0)+	;copy bytes to support ODD addresses
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbra	d0,.copy

	Pull	d0/d2-d3/d7/a0/a1
	moveq	#0,d1	;return ok
	rts

;---- Kernal's Amiga2Date algorithm
Amiga2Date	movem.l	d2/d3,-(sp)
	moveq	#$3C,d1
	grcall	UDivMod32
	move.w	d1,(a0)
	moveq	#$3C,d1
	grcall	UDivMod32
	move.w	d1,2(a0)
	moveq	#$18,d1
	grcall	UDivMod32
	move.w	d1,4(a0)
	addi.l	#$B05D6,d0
	move.l	d0,-(sp)
	move.l	d0,d2
	addq.l	#3,d0
	moveq	#7,d1
	grcall	UDivMod32
	move.w	d1,12(a0)
	move.l	d2,d0
	addq.l	#1,d0
	move.l	#$23AB1,d1
	grcall	UDivMod32
	sub.l	d0,d2
	move.l	d2,d0
	move.l	#$8EAC,d1
	grcall	UDivMod32
	add.l	d0,d2
	move.l	d2,d0
	addq.l	#1,d0
	move.l	#$5B5,d1
	grcall	UDivMod32
	sub.l	d0,d2
	move.l	d2,d0
	move.l	#$16D,d1
	grcall	UDivMod32
	move.l	(sp)+,d2
	move.l	d0,-(sp)
	move.l	d0,d3
	moveq	#$64,d1
	lsl.l	#2,d1
	grcall	UDivMod32
	sub.l	d0,d2
	move.l	d3,d0
	moveq	#$64,d1
	grcall	UDivMod32
	add.l	d0,d2
	move.l	d3,d0
	lsr.l	#2,d0
	sub.l	d0,d2
	move.l	d3,d0
	move.l	#$16D,d1
	grcall	UMult32
	sub.l	d0,d2
	move.l	d2,d0
	moveq	#$66,d1
	not.b	d1
	grcall	UDivMod32
	moveq	#10,d0
	grcall	UMult32
	move.l	#$131,d1
	grcall	UDivMod32
	move.l	d0,d3
	move.l	d2,d0
	moveq	#$66,d1
	not.b	d1
	grcall	UDivMod32
	move.l	d0,d1
	lsl.l	#2,d1
	add.l	d0,d1
	add.l	d1,d3
	move.l	#$132,d0
	move.l	d3,d1
	grcall	UMult32
	addq.l	#5,d0
	moveq	#10,d1
	grcall	UDivMod32
	addq.l	#1,d2
	sub.l	d0,d2
	move.w	d2,6(a0)
	move.l	d3,d0
	addq.l	#2,d0
	moveq	#12,d1
	grcall	UDivMod32
	addq.l	#1,d1
	move.w	d1,8(a0)
	add.l	(sp)+,d0
	move.w	d0,10(a0)
	movem.l	(sp)+,d2/d3
	rts

;---- Kernal's Date2Amiga algorithm
Date2Amiga	movem.l	d2/d3,-(sp)
	moveq	#0,d0
	move.w	10(a0),d0
	moveq	#0,d1
	move.w	8(a0),d1
	moveq	#0,d2
	move.w	6(a0),d2

	move.l	d2,-(sp)
	move.l	d0,d2
	moveq	#9,d0
	add.l	d1,d0
	moveq	#12,d1
	grcall	UDivMod32
	add.l	d0,d2
	move.l	#$132,d0
	grcall	UMult32
	addq.l	#5,d0
	moveq	#10,d1
	grcall	UDivMod32
	move.l	d0,-(sp)
	subq.l	#1,d2
	move.l	d2,d0
	moveq	#$64,d1
	lsl.l	#2,d1
	grcall	UDivMod32
	move.l	d0,-(sp)
	move.l	d2,d0
	moveq	#$64,d1
	grcall	UDivMod32
	move.l	d0,-(sp)
	move.l	d2,d1
	lsr.l	#2,d2
	move.l	#$16D,d0
	grcall	UMult32
	add.l	d2,d0
	sub.l	(sp)+,d0
	add.l	(sp)+,d0
	add.l	(sp)+,d0
	move.l	(sp)+,d2
	add.l	d2,d0
	subq.l	#1,d0

	moveq	#0,d1
	move.w	(a0),d1
	moveq	#0,d2
	move.w	2(a0),d2
	moveq	#0,d3
	move.w	4(a0),d3
	subi.l	#$B05D6,d0
	move.l	d1,-(sp)
	moveq	#$18,d1
	grcall	UMult32
	add.l	d3,d0
	moveq	#$3C,d1
	grcall	UMult32
	add.l	d2,d0
	moveq	#$3C,d1
	grcall	UMult32
	move.l	(sp)+,d1
	add.l	d1,d0
	movem.l	(sp)+,d2/d3
	rts

;---- BeerMon's readbatteryclock
ReadBatClock	movem.l	d0-d3/a0/a1,-(sp)
	clr.l	Time00(b)
	clr.l	Time01(b)
	clr.l	Time02(b)
	lea	$DC0000,a0
	moveq	#15,d1
	move.b	$3F(a0),d0
	and.b	d1,d0
	subq.b	#4,d0
	beq.b	lbC000068
	clr.b	$3F(a0)
	clr.b	$3B(a0)
	move.b	#9,$37(a0)
	move.b	#5,$33(a0)
	move.b	$33(a0),d0
	and.b	d1,d0
	bne.b	lbC00008E
	move.b	$37(a0),d0
	and.b	d1,d0
	cmpi.b	#9,d0
	bne.b	lbC00008E
	move.b	$2B(a0),d0
	btst	#0,d0
	beq.b	lbC00008E
	sf	$37(a0)
	moveq	#4,d0
	lea	$34(a0),a0
	bsr.b	lbC000094
	move.b	#9,$37(a0)
	bra.b	lbC00008E

lbC000068	moveq	#1,d0
	move.w	#$190,d1
lbC00006E	move.b	d0,$37(a0)
	btst	d0,$37(a0)
	beq.b	lbC000082
	sf	$37(a0)
	dbra	d1,lbC00006E
	bra.b	lbC00008E

lbC000082	moveq	#0,d0
	lea	$30(a0),a0
	bsr.b	lbC000094
	sf	$37(a0)
lbC00008E	movem.l	(sp)+,d0-d3/a0/a1
	rts

lbC000094	bsr.b	lbC000104
	subi.w	#$4E,d2
	bcc.b	lbC0000A2
	addi.w	#$64,d2
lbC0000A2	move.l	d2,d3
	mulu.w	#$16D,d3
	addq.l	#1,d2
	divu.w	#4,d2
	add.w	d2,d3
	swap	d2
	lea	lbW000116(pc),a1
	move.b	#$1C,1(a1)	;lbW000116+1
	cmpi.b	#3,d2
	bne.b	lbC0000C2
	addq.b	#1,1(a1)	;lbW000116+1
lbC0000C2	bsr.b	lbC000104
lbC0000C8	subq.b	#1,d2
	beq.b	lbC0000D2
	move.b	(a1)+,d1
	add.w	d1,d3
	bra.b	lbC0000C8

lbC0000D2	bsr.b	lbC000104
	subq.l	#1,d2
	add.w	d2,d3
	move.l	d3,Time00(b)
	suba.w	d0,a0
	bsr.b	lbC000104
	divu.w	#$28,d2
	clr.w	d2
	swap	d2
	move.l	d2,d3
	lsl.l	#4,d3
	sub.l	d2,d3
	lsl.l	#2,d3
	bsr.b	lbC000104
	add.l	d2,d3
	move.l	d3,Time01(b)
	bsr.b	lbC000104
	mulu.w	#$32,d2
	move.l	d2,Time02(b)
	rts

lbC000104	moveq	#15,d1
	and.l	-(a0),d1
	moveq	#15,d2
	and.l	-(a0),d2
	add.l	d1,d2
	add.l	d1,d2
	lsl.l	#3,d1
	add.l	d1,d2
	rts

lbW000116	dc.w	$1F1C
	dcb.w	$2,$1F1E
	dc.w	$1F1F
	dcb.w	$2,$1E1F
e
