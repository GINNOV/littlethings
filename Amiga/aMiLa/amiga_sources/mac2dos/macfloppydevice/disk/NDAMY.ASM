*********************************************************
*							*
*		Non-device Mac driver			*
*							*
*     mfamy.asm - routines to handle Amiga diskettes	*
*	   and high-level reads and writes		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*							*
*********************************************************

	INCLUDE "vd0:MACROS.ASM"
	INCLUDE "mf.i"

	XDEF	ReadCmd,WriteCmd

	XDEF	CalcTrkSec
	XDEF	Seek
	XDEF	WaitForSignal
	XDEF	WriteCurrentTrack
	XDEF	TimeDelay
	XDEF	BlitBlockComp

	XREF	_AbsExecBase
;	XREF	SendReplyMsg
	XREF	ReadTrack,WriteTrack
	XREF	BusyDrives,FreeDrives,Track0,StepHeads,MotorOnOff
	XREF	SetTrkParams
	XREF	MReadCmd,MWriteCmd,MVerifyTrack,AlignSectors

* Perform high-level sector read/write operations, including reading and
* writing tracks, seeking, encoding/decoding sector data, etc.
* NOTE: These commands merely transfer data between the user's
* buffer and the track buffer.  Note that a WRITE can be forced by a
* read command, if the desired sector is not in the track buffer and the 
* track buffer is "dirty" (needs to be written).

ReadCmd:
WriteCmd:
	PUSH	A2-A4
	MOVE.L	IO_UNIT(A1),A3		;get unit table
	MOVE.L	A1,A2			;save ptr to caller's IOB
	MOVE.L  A2,IORequest(A3)	;save ptr
	MOVE.L  #0,IO_ACTUAL(A2)	;show nothing yet
	MOVE.L  IO_DATA(A2),UserBuffer(A3) ;user's data buffer
	MOVE.L  IO_OFFSET(A2),D0	;offset to desired place on disk
	BSR	CalcTrkSec		;check if valid
	TST.L   D0			;error?
	BMI	RWerr			;yes
	MOVE.W  D0,NewTrk(A3)		;else save new track and sector
	MOVE.W	D1,NewSec(A3)
	MOVE.L  IO_OFFSET(A2),D0	;now check for proper end of read/write
	ADD.L   IO_LENGTH(A2),D0
	BSR	CalcTrkSec		;check end
	TST.L   D0			;okay?
	BMI	RWerr			;no
	BTST    #td_ETD,TdFlags(A3)	;extended command?
	BEQ.S   1$			;no...don't even consider hdr data
	MOVE.L  IOTD_SECLABEL(A2),LabelBuffer(A3) ;else save header buffer ptr
	BEQ.S   1$			;no hdr data ptr
	BSET    #td_HdrData,TdFlags(A3)	;show transferring hdr data
1$:	BTST    #td_DrvEmpty,TdFlags(A3) ;is there a disk loaded?
	BEQ.S   2$			;yes
	MOVE.B  #TDERR_DiskChanged,IO_ERROR(A2)	;no disk loaded, dummy
	BRA	RWexit

2$:	MOVE.W  NewTrk(A3),D0		;get desired track number
	BSR	CheckTrackBuf		;do we have the right track...
	MOVE.L  A0,ReadBuffer(A3)	;...in the TrackBuffer?
	BNE.S   RWSector		;yes...process command
	BSR	GetTrkBuf		;else get write buffer address
	MOVE.L	A0,A2			;to A2
	MOVE.L  A2,ReadBuffer(A3)	;make it the TrackBuffer

* Get to proper track.  May have to write out current track.

RWTrack:
	BTST	#0,2(A2)		;is track buffer dirty?
	BEQ.S   4$			;no...no need to write it out
	BSR	WriteCurrentTrack	;else write out the current track
	TST.L   D0			;errors?
	BEQ.S   4$			;no...ready to read proper track
	MOVE.L	IORequest(A3),A1	;else return error code in D0 to caller
	MOVE.B  D0,IO_ERROR(A1)
	BRA	RWexit

4$:	MOVE.W  NewTrk(A3),0(A2)	;set up track number in track buffer
	BCLR    #0,2(A2)		;clear the track buffer dirty flag
	CLR.B   ErrorCnt(A3)		;no errors yet
	BSR	ReadandVerifyTrk	;seek to track, read it and check errors
	MOVE.B  3(A2),D0		;load possible error code or first sector
	CMP.B	SecsPerTrk(A3),D0	;max sectors per track
	BCS.S   RWSector		;no error...ready to process command
	MOVE.W  #-1,0(A2)		;else return error code to caller
	MOVE.L	IORequest(A3),A1	;tricky way to return error number
	MOVE.B  D0,IO_ERROR(A1)
	BRA	RWexit

* Ready to process user's read/write command.

RWSector:
	MOVE.L	IORequest(A3),A2	;ptr to callers IOB
	MOVE.W  IO_COMMAND(A2),D0	;get the command code
	MOVE.L	ReadBuffer(A3),A0	;reads and writes use the same buffer
	CMPI.B  #CMD_WRITE,D0		;write command?
	BNE	ARead			;no, read

* Write operation - transfers and encodes data from user's buffer into
* proper sector in track buffer.  Track buffer already contains raw data
* from proper track.  Note that writing to disk does NOT occur
* immediately, unless the number of sectors wraps around past the end of
* the current track.

AWrite:	BSET	#0,2(A0)		;mark the track "dirty"
	BSR	MWriteCmd		;else do a Mac write
	BRA	RWend

* Read operation - read ADOS sector from track buffer.  Track buffer
* contains contents of proper track.  Decodes and transfers data from
* desired sector into user's buffer.

ARead:	BSR	MReadCmd		;else perform Mac read

* Read or write has transferred one sector of possible multi-sector
* operation.  Now we update the IOB and check if there are more sectors.

RWend:
	MOVE.L  #SectorSize,D1		;move a full sector
	ADD.L   D1,UserBuffer(A3)	;bump user's data address by one sector
	MOVE.L  IO_ACTUAL(A2),D0	;the amount we have moved so far
	ADD.L   D1,D0			;add length of this sector
	MOVE.L  D0,IO_ACTUAL(A2)	;amount moved counting this sector
	BTST    #td_HdrData,TdFlags(A3)	;doing header data?
	BEQ.S   1$			;no
	ADDI.L  #16,LabelBuffer(A3)	;else bump header buffer ptr
1$:	CMP.L   IO_LENGTH(A2),D0	;have we done it all?
	BCC.S   RWexit			;yes

	ADD.L	IO_OFFSET(A2),D0	;offset to desired place on disk
	BSR	CalcTrkSec		;find out if track has changed
	TST.L   D0			;error?
	BMI.S	RWerr			;yes
	MOVE.W	D1,NewSec(A3)		;this is proper next sector
	CMP.W	NewTrk(A3),D0		;track changed?
	BEQ	RWSector		;no...process next sector on this track
	MOVE.W	D0,NewTrk(A3)		;else update track number
	MOVE.L	ReadBuffer(A3),A2	;reload A2
	BRA	RWTrack			;write out this trk, read next trk

RWerr	MOVE.L	IORequest(A3),A1	;error
	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A1)

RWexit:	MOVE.L	IORequest(A3),A1	;else reply to caller...read complete
;	BSR	SendReplyMsg
	POP	A2-A4
	RTS

* Writes contents of track buffer to disk.

WriteCurrentTrack:
	PUSH	D2/A2
	MOVE.L	ReadBuffer(A3),A2	;get buffer to be written
	MOVEQ   #1,D0			;motor "on"
	BSR	MotorOnOff
	ZAP	D0
	MOVE.W  0(A2),D0		;get track number from buffer
	BSR	Seek			;seek to that track
	IFNZB	D0,2$			;seek error
	BSR	AlignSectors		;Mac format...fix up sectors
	LEA     4(A2),A0		;skip over first longword
	MOVE.L  WriteLength(A3),D0	;write this many bytes
	BSR	WriteTrack
2$:	POP	D2/A2
	RTS

* Seeks to NewTrk, reads that track, and verifies the integrity of the data.

ReadandVerifyTrk:
	PUSH	A2
	MOVE.L	ReadBuffer(A3),A2	;get buffer to read into
	MOVEQ   #1,D0			;motor "on"
	BSR	MotorOnOff
1$:	ZAP	D0
	MOVE.W  NewTrk(A3),D0		;read this track
	BSR	Seek			;seek to that track
	MOVE.B  D0,3(A2)		;clobber sector # with error code
	BNE.S	4$			;seek error

2$:	LEA	MacReadGap(A2),A0	;Mac reads start way down the buffer
	MOVE.L  ReadLength(A3),D0	;read this many bytes
	BSR	ReadTrack		;read the selected track
	TST.L   D0			;error?
	BEQ.S   3$			;no
	MOVE.B  D0,3(A2)		;clobber sector # with error code
	BRA	4$
3$:	BSR	VerifyTrack		;check format and checksums
	MOVE.B  D0,3(A2)		;save first sector into buffer
	CMPI.B  #11,D0			;some kind of error?
	BCS.S   4$			;no
7$:	IFEQIB	D0,#-1,4$		;timer problem...bail out
	ADDQ.B  #1,ErrorCnt(A3)		;else bump retry count
	MOVE.B  ErrorCnt(A3),D0
	CMP.B   #RetryLimit,D0		;reached retry limit?
	BGT.S   4$			;yes...bail out
	ANDI.B  #3,D0			;allow up to 4 tries without seeking
	BNE.S   2$			;reread without seeking
	MOVE.W  #-1,CurTrk(A3)		;else clobber track number to force seek
	BRA.S   1$
4$:	POP	A2
	RTS

* Calculate track and sector from byte offset in D0.
* Returns track in D0 (range 0-159) and sector in D1.
* Sector range is 0-10 (ADOS) and 0-11 (Mac).  If track is odd, side=1.
* Returns D0=D1=-1 if offset is out of range.

CalcTrkSec:
	MOVE.L  D0,D1
	ANDI.L  #$1FF,D1		;anything other than full sector?
	BNE	8$			;yes...must be on sector boundary
	CMP.L   MaxOffset(A3),D0	;in range for this type of diskette?
	BHI	8$			;no
	PUSH	D2-D6
	MOVEQ   #9,D1			;divide to by 512 to get sectors
	LSR.L   D1,D0
	ZAP	D4
	MOVE.B	DiskType(A3),D4
	DECL	D4			;shift count (0 or 1)
	ZAP	D2
	MOVE.W	#800,D2			;single-sided size
	LSL.W	D4,D2			;shift to get 800 or 1600
	MOVEQ	#112,D3			;112+16=128 blocks in last band
	LSL.W	D4,D3			;yields 112 or 224
	MOVEQ	#16,D5			;tracks per single-sided band
	LSL.W	D4,D5			;16 or 32
2$:	ADD.W	D5,D3			;128 (256), 144 (288), 160 (320), etc.
	SUB.L	D3,D2			;work from smallest band backwards
	IFLTL	D0,D2,2$		;loop until we find which band
	LSR.W	#4,D3			;divide by 16 to get blocks per cyl
	MOVEQ	#-1,D5			;start track counter at -1
3$:	ADD.W	D3,D2
	INCW	D5			;count track
	IFGEW	D0,D2,3$		;loop until we find proper cyl in band
	LSR.W	D4,D3			;number of blocks per track (8-12)
	MOVE.B	D3,SecsPerTrk(A3)
	MOVEQ	#12,D6			;max blocks per track
	SUB.W	D3,D6			;0-4
	LSL.W	#4,D6			;mulitply by 16 (0, 16, 32,48, 64)
	ADD.W	D6,D5			;yields track number in D5, range 0-79
	SUB.W	D3,D2
	IFGEL	D0,D2,4$		;D2 set properly
	SUB.W	D3,D2			;else correct D2...
	ZAP	D4			;...and force side 0
4$:	ADD.W	D5,D5			;convert to ADOS track numbering scheme
	IFZB	D4,6$			;side 0
	INCW	D5			;add 1 to force side 1
	BTST	#Mac_TwoSided,MacFlags(A3) ;double-sided drive?
	BEQ.S	7$			;oops...drive can't do it
	
6$:	MOVE.W	D5,D1			;save track number
	SUB.W	D2,D0			;sector on this track
	EXG	D0,D1			;swap to get trk in D0, sector in D1
	POP	D2-D6
	RTS	

7$:	POP	D2-D6
8$:	MOVEQ   #-1,D0			;error
	MOVEQ   #-1,D1
	RTS

* Positions head to track 0.

CalibrateDrive:
	PUSH	D2
;	BSR	BusyDrives
	BCLR	#Mac_Side,MacFlags(A3)		;force side 0
	BSR	Track0				;already on track 0?
	ERROR	3$				;no...no need to step away
	BCLR	#Mac_StepDir,MacFlags(A3)	;first step away from track 0
	MOVEQ	#4,D2
2$:	BSR	StepHeads
	DBF	D2,2$				;loop
3$:	BSET	#Mac_StepDir,MacFlags(A3)	;direction=toward TRACK 0
	CLR.W	CurTrk(A3)
	MOVE.W	#MaxTracks/2,D2			;max cyls
	ADDQ.W	#8,D2				;a little more, for good measure
1$:	BSR	Track0				;are we there?
	NOERROR	4$				;yes
	BSR	StepHeads			;else step one cyl
	DBF	D2,1$				;loop looking for track 0
;	BSR	FreeDrives			;oops...something is wrong
	MOVEQ	#TDERR_SeekError,D0		;didn't find track 0
	BRA.S	9$
4$:;	BSR	FreeDrives
	MOVE.L  #SetDelay,D0			;settling delay
	BSR	TimeDelay
	ZAP	D0				;no error
9$:	POP	D2
	RTS

* Steps head to desired track.
* Desired track in D0.  Note: range 0-159
* Returns D0<>0 on seek or other problem.

Seek:	PUSH	D2-D3
	MOVE.W  CurTrk(A3),D2		;check current track
	BPL.L   1$			;don't need to calibrate
	MOVE.L  D0,D2			;else save desired track
	BSR	CalibrateDrive
	TST.L   D0			;error?
	BNE	8$			;yes
	EXG     D2,D0			;else get back desired track
1$:	CMP.W   D0,D2			;same as we are on?
	BEQ	7$			;yes...all done
	MOVE.L  D0,D3			;else save desired track
	BCLR	#Mac_Side,MacFlags(A3)	;side 0
	BTST	#0,D3			;odd track?
	BEQ.S	2$			;no, even=side 0
	BSET	#Mac_Side,MacFlags(A3)	;else odd=side 1
2$:	MOVE.W  D3,CurTrk(A3)		;this is our new current track
	LSR.W   #1,D2			;divide to get cyls
	LSR.W   #1,D3			;ditto
	SUB.W   D3,D2			;figure out which way to step
	BCS.S   3$			;toward spindle (higher tracks)
	BHI.S   4$			;toward track 0
	BRA.S   7$			;already there...no steps needed
3$:	BCLR	#Mac_StepDir,MacFlags(A3)
	NEG.W   D2			;correct step count
	BRA.S   66$
4$:	BSET	#Mac_StepDir,MacFlags(A3)
66$:;	BSR	BusyDrives
	BRA.S   6$
5$:	BSR	StepHeads
6$:	DBF     D2,5$			;loop till we get there
;	BSR	FreeDrives
	MOVE.L  #SetDelay,D0		;settling delay
	BSR	TimeDelay
7$:	BSR	SetTrkParams		;set proper params for new track
	ZAP	D0			;good seek
8$:	POP	D2-D3
	RTS

* Delay in usecs in D0.

TimeDelay:
	PUSH	A0-A1
	LEA     ShortTimer(A3),A1	;get timer request
	CLR.L   IO_SIZE+TV_SECS(A1)	;set seconds to 0
	MOVE.L  D0,IO_SIZE+TV_MICRO(A1)	;set usecs to proper delay
	LINKSYS	DoIO,mf_SysBase(A6)	;wait for delay to expire
	POP	A0-A1
	RTS

CheckTrackBuf:
	MOVE.L  WriteBuffer(A3),D1	;get ptr to write buffer
	TST.L   D1			;is there a buffer?
	BEQ.S   1$			;no
	MOVE.L	D1,A0
	CMP.W   0(A0),D0		;is desired track in buffer?
	BEQ.S   2$			;yes...buffer in D1
1$:	ZAP	D0			;no...zap D0
	MOVE.L	D0,A0
2$:	RTS

GetTrkBuf:
	MOVE.L	WriteBuffer(A3),A0
	RTS

* Called after reading a track to verify the raw data in the track buffer 
* read from the floppy.  Checks headers and data for valid checksum errors, moves
* data to the front of the buffer (following the track gap AAAA's) and returns the 
* first sector number of the buffer in D0.  Data in buffer still is in MFM 
* format (with embedded clock) but has been shifted to correct for bit 
* misalignment.

VerifyTrack:
	BSR	MVerifyTrack		;else Mac
	RTS

* This is the disk complete/blitter complete ISR.  It is called by
* the system with A1 set to the proper unit table based on the current
* "owner" of the hardware, which is maintained by the Disk Resource
* routine.  The vector is through the unit table disk complete vector.
* This routine sends a msg to the sleeping task to wake it up.
* NOTE: this interrupt is "registered" with disk resource by an offset
* from the PrivateMsg which is passed on the GetUnit disk resource call.

BlitBlockComp:
	LEA     PrivatePort(A1),A0	;this is the port to use
	LEA     ShortTimer(A1),A1	;use the timer message
	LINKSYS	PutMsg,_AbsExecBase
	RTS

* Unit task waits in this routine until signalled by routine above.

WaitForSignal:
	MOVE.L  #$400,D0		;signal bit to wait for
	MOVE.L  A6,-(A7)
	CALLSYS	Wait,mf_SysBase(A6)
	LEA     PrivatePort(A3),A0	;get a msg at this port
	CALLSYS	GetMsg
	MOVE.L	(A7)+,A6
	IFZL	D0,WaitForSignal	;no msg...loop
	RTS

	END

