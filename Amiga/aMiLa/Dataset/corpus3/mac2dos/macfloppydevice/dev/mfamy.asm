*********************************************************
*							*
*		MacFloppy.device			*
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
	XDEF	BlitBlockComp
	XDEF	WaitForSignal
	XDEF	WriteCurrentTrack
	XDEF	TimeDelay
	XDEF	EncodeSector

	XREF	_AbsExecBase
	XREF	SendReplyMsg
	XREF	ReadTrack,WriteTrack
	XREF	BusyDrives,FreeDrives,Track0,StepHeads,MotorOnOff
	XREF	SetTrkParams

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

AWrite:
	BSET    #0,2(A0)		;write - mark track dirty
	ZAP	D0			;ADOS write
	MOVE.W	NewSec(A3),D0		;get desired sector
	SUB.B   3(A0),D0		;wrap around?
	BPL.S   6$			;no
	ADDI.B  #11,D0			;yes...correct
6$:	MULU    #1088,D0		;mult by size of 1 sector (in MFM bytes)
	LEA     TrackGap(A0),A4		;add in track gap offset
	ADDA.L  D0,A4			;index into track buffer
	BTST    #td_HdrData,TdFlags(A3)	;header data going too?
	BEQ.S   7$			;no
	MOVE.L	LabelBuffer(A3),A0	;else process header data
	MOVE.L  #16,D0			;16 longwords
	LEA     $10(A4),A1		;it goes here in buffer
	BSR	BlitEncode		;encode into MFM and store into buffer
	LEA     8(A4),A0		;header starts here in buffer
	MOVE.W  #40,D1			;64 bytes for checksum
	BSR	CalcCksum
	LEA     $30(A4),A0		;header checksum goes here
	BSR	EncodeLongword		;encode and store
7$:	MOVE.L	UserBuffer(A3),A0	;get user's buffer
	MOVE.L  #SectorSize,D0		;process one full sector
	LEA     $40(A4),A1		;sector data goes here in buffer
	BSR	BlitEncode		;encode into MFM and store into buffer
	LEA     $40(A4),A0		;start here to recalc checksum
	MOVE.W  #1024,D1		;1088 bytes
	BSR	CalcCksum		;calc data checksum
	LEA     $38(A4),A0		;goes here in buffer
	BSR	EncodeLongword		;so store it into buffer
	BRA	RWend			;finished one sector

* Read operation - read ADOS sector from track buffer.  Track buffer
* contains contents of proper track.  Decodes and transfers data from
* desired sector into user's buffer.

ARead:	ZAP	D0			;ADOS read
	MOVE.W	NewSec(A3),D0
	SUB.B   3(A0),D0
	BPL.S   9$
	ADDI.B  #11,D0
9$:	MULU    #1088,D0		;calculate offset into track buffer
	LEA     TrackGap(A0),A4		;skip over track gap
	ADDA.L  D0,A4	
	BTST    #td_HdrData,TdFlags(A3)	;processing header data?
	BEQ.S   10$			;no
	LEA     $10(A4),A1		;header starts here
	MOVE.L	LabelBuffer(A3),A0		;user's header buffer is here
	MOVE.L  #16,D0			;16 longwords
	BSR	BlitMove		;move that data into user's buffer
10$:	LEA     $40(A4),A1		;sector data starts here in buffer
	MOVE.L	UserBuffer(A3),A0	;user's data buffer
	MOVE.L  #SectorSize,D0		;one full sector
	BSR	BlitMove		;move header data

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
	BSR	SendReplyMsg
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
	IFNZB	D0,2$			;error
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
	IFNZB	D0,4$			;seek error

2$:	LEA     TrackGap+4(A2),A0	;leave room for blits
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
7$:	ADDQ.B  #1,ErrorCnt(A3)		;else bump retry count
	MOVE.B  ErrorCnt(A3),D0
	CMP.B   #RetryLimit,D0		;reached retry limit?
	BGT.S   4$			;yes...bail out
	ANDI.B  #3,D0			;allow up to 4 tries without seeking
	BNE.S   2$			;reread without seeking
	MOVE.W  #-1,CurTrk(A3)		;else clobber track number to force seek
	BRA.S   1$
4$:;	BSR	FreeDrives
	POP	A2
	RTS

* Calculate track and sector from byte offset in D0.
* Returns track in D0 (range 0-159) and sector in D1.
* Sector range is 0-10 (ADOS) and 0-11 (Mac).  If track is odd, side=1.
* Returns D0=D1=-1 if offset is out of range.

CalcTrkSec:
	MOVE.L  D0,D1
	ANDI.L  #$1FF,D1		;anything other than full sector?
	BNE.S	8$			;yes...must be on sector boundary
	CMP.L   MaxOffset(A3),D0	;in range for this type of diskette?
	BHI.S	8$			;no
	PUSH	D2-D6
	MOVEQ   #9,D1			;divide to by 512 to get sectors
	LSR.L   D1,D0
	ZAP	D4
	MOVEQ	#11,D1
	MOVE.B	D1,SecsPerTrk(A3)
	DIVU    D1,D0			;divide by sectors per track to get tracks
	ZAP	D1
	SWAP    D0
	MOVE.W  D0,D1			;remainder to D1=sector
	MOVE.W  #0,D0			;WARNING---NO ZAP HERE!
	SWAP    D0			;D0=track (0-159)
	POP	D2-D6
	RTS

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

* Called to encode header data and sector data into buffer.
* A1=data buffer, A0=unencoded sector data, D0=hdr info.

EncodeSector:
	PUSH	D2/A2/A4
	MOVE.L	A1,A4			;encoded data goes here
	MOVE.L	A0,A2			;raw data comes from here
	MOVE.L  D0,D2			;hdr info
	ZAP	D0
	LEA     0(A4),A0		;encode 0 to get $AAAAAAAA
	BSR	EncodeLongword
	MOVE.L  #$44894489,4(A4)	;store sync pattern
	MOVE.L  D2,D0			;hdr info
	LEA     8(A4),A0		;goes here
	BSR	EncodeLongword
	MOVEQ   #3,D2			;store 16 (4*4) longwords of 0
1$:	ZAP	D0
	BSR	EncodeLongword		;this is header data
	DBF     D2,1$
	LEA     8(A4),A0		;header starts here
	MOVEQ   #40,D1			;40 bytes in header
	BSR	CalcCksum		;calc hdr checksum
	LEA     $30(A4),A0		;hdr checksum goes here
	BSR	EncodeLongword
	MOVE.L  #SectorSize,D0		;one full sector of data
	MOVE.L	A2,A0			;raw data ptr
	LEA     $40(A4),A1		;encoded sector data goes here
	BSR	BlitEncode		;encode user's data MFM and store
	LEA     $40(A4),A0		;encoded sector data starts here
	MOVE.W  #SectorSize*2,D1	;512*2 bytes for checksum
	BSR	CalcCksum		;calculate data checksum
	LEA     $38(A4),A0		;data checksum goes here
	BSR	EncodeLongword
	POP	D2/A2/A4
	RTS

* Called to encode raw data as MFM, and move into track buffer.
* A0=raw data ptr, A1=endcoded data ptr, D0=byte count,
* A3=unit table.

BlitEncode:
	LINK    A2,#-$1E		;make room on stack
	MOVE.W  D0,D1			;size of blit
	LSL.W   #2,D1			;number of longwords to process
	ORI.W   #8,D1
	MOVE.W  D1,-$A(A2)		;store into blit block
	MOVEM.L	D0/A0-A1,-$16(A2)	;store remaining params into blit block
	MOVE.L  #BlitRtn5,-$1A(A2)	;blit routine
	MOVE.L  A3,-4(A2)		;port ptr for completion signal
	LEA     -$1E(A2),A1		;ptr to blit structure
	LINKSYS	QBlit,mf_GraphicsBase(A6)
	BSR	WaitForSignal		;wait for blit to complete
	MOVEM.L	-$16(A2),D0/A0-A1
	MOVE.L  D0,D1			;byte number to D1
	MOVE.L	A1,A0			;ptr to beginning of data
	BSR	FixClockBit		;correct border
	ADDA.L  D1,A0
	BSR	FixClockBit
	ADDA.L  D1,A0
	BSR	FixClockBit
	UNLK    A2			;clean up stack
	RTS

BlitRtn5:
	MOVE.L  A5,-(A7)
	MOVE.L	A1,A5			;save ptr to blit structure
	BSR	BlitInit		;init blitter
	MOVE.L	A5,A1
	MOVEM.L	8(A1),D0-D1/A5
	MOVE.L  D1,$4C(A0)		;source to sourceB
	MOVE.L  D1,$50(A0)		;source to sourceA
	MOVE.L  A5,$54(A0)		;dest to dest D
	MOVE.W  #$1DB1,$40(A0)		;BLTCON0
	MOVE.W  #0,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn6,4(A1)		;ptr to next function
	MOVE.L	(A7)+,A5
	RTS

BlitRtn6:
	MOVE.L  A5,-(A7)
	MOVEM.L	8(A1),D0-D1/A5
	MOVE.L  A5,$4C(A0)		;sourceB=dest
	MOVE.L  D1,$50(A0)		;sourceA=source
	MOVE.L  A5,$54(A0)		;destD=dest
	MOVE.W  #$2D8C,$40(A0)		;BLTCON0
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn7,4(A1)		;ptr to next function
	MOVE.L	(A7)+,A5
	RTS

BlitRtn7:
	MOVE.L  A5,-(A7)
	MOVEM.L	8(A1),D0-D1/A5
	ADD.L   D0,D1			;ptr to end source
	SUBQ.L  #2,D1			;-2
	ADDA.L  D0,A5
	ADDA.L  D0,A5
	SUBQ.L  #2,A5
	MOVE.L  D1,$4C(A0)		;source B=source end
	MOVE.L  D1,$50(A0)		;source A=source end
	MOVE.L  A5,$54(A0)		;destD=destination-end
	MOVE.W  #$DB1,$40(A0)		;BLTCON0
	MOVE.W  #$1002,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn8,4(A1)		;ptr to next function
	MOVE.L	(A7)+,A5
	RTS

BlitRtn8:
	MOVE.L  A5,-(A7)
	MOVEM.L	8(A1),D0-D1/A5
	ADDA.L  D0,A5			;ptr to end of first part of dest
	MOVE.L  A5,$4C(A0)		;enter from source B
	MOVE.L  D1,$50(A0)		;source A=source
	MOVE.L  A5,$54(A0)		;destD=end of first part of dest
	MOVE.W  #$1D8C,$40(A0)		;BLTCON0
	MOVE.W  #0,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn9,4(A1)		;ptr to next function
	MOVE.L	(A7)+,A5
	RTS

BlitRtn9:
	ZAP	D0
	MOVE.L  D0,4(A1)		;all done...clobber linkage
	MOVE.L	$1A(A1),A1
	BSR	BlitBlockComp		;signal blit complete
	ZAP	D0
	RTS

* Called to decode MFM from track buffer and move to user's data buffer.
* A0=destination addresss, A1=encoded MFM source, D0=byte count.

BlitMove:
	LINK    A2,#-$1E		;set up blit block on stack
	MOVEM.L	D0/A0-A1,-$16(A2)	
	LSL.W   #2,D0
	ORI.W   #8,D0
	MOVE.W  D0,-$A(A2)
	MOVE.L  #BlitRtn10,-$1A(A2)	;blitter function
	MOVE.L  A3,-4(A2)
	LEA     -$1E(A2),A1		;blitter node
	LINKSYS	QBlit,mf_GraphicsBase(A6) ;queue blitter request
	BSR	WaitForSignal		;wait for blit to complete
	MOVEM.L	-$16(A2),D0/A0-A1
	UNLK    A2
	RTS

BlitRtn10:
	MOVE.L  A5,-(A7)
	MOVE.L	A1,A5			;save ptr to blitter node
	BSR	BlitInit		;init blitter
	MOVE.L	A5,A1
	MOVEM.L	8(A1),D0-D1/A5
	ADDA.L  D0,A5
	SUBQ.L  #1,A5
	MOVE.L  A5,$50(A0)		;sourceA
	ADDA.L  D0,A5
	MOVE.L  A5,$4C(A0)		;sourceB
	ADD.L   D0,D1
	SUBQ.L  #1,D1
	MOVE.L  D1,$54(A0)		;destD
	MOVE.W  #$1DD8,$40(A0)		;BLTCON0
	MOVE.W  #2,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn11,4(A1)	;next blitter function
	MOVE.L	(A7)+,A5
	RTS

BlitRtn11:
	ZAP	D0
	MOVE.L  D0,4(A1)		;clobber linkage
	MOVE.L	$1A(A1),A1
	BSR	BlitBlockComp		;signal blit complete
	ZAP	D0
	RTS

* Encodes longword in D0 into MFM data stored in 2 longwords
* into buffer at A0.

EncodeLongword:
	PUSH	D2-D3
	MOVE.L  D0,D3
	LSR.L   #1,D0
	BSR	AddClockStore
	MOVE.L  D3,D0
	BSR	AddClockStore
	BSR	FixClockBit
	POP	D2-D3
	RTS

AddClockStore:
	ANDI.L  #$55555555,D0
	MOVE.L  D0,D2
	EORI.L  #$55555555,D2
	MOVE.L  D2,D1
	LSL.L   #1,D2
	LSR.L   #1,D1
	BSET    #$1F,D1
	AND.L   D2,D1
	OR.L    D1,D0
	BTST    #0,-1(A0)
	BEQ.S   1$
	BCLR    #$1F,D0
1$:	MOVE.L  D0,(A0)+
	RTS

* Loads MFM data at A0 and decodes it into D0.

DecodeLongword:
	MOVE.L  (A0)+,D0
	MOVE.L  (A0)+,D1
	ANDI.L  #$55555555,D0
	ANDI.L  #$55555555,D1
	LSL.L   #1,D0
	OR.L    D1,D0
	RTS

* Calculates checksum of MFM encoded data at A0 for D1 bytes.  Returns 
* resulting checksum in D0.

CalcCksum:
	MOVE.L  D2,-(A7)
	LSR.W   #2,D1
	SUBQ.W  #1,D1
	ZAP	D0
1$:	MOVE.L  (A0)+,D2
	EOR.L   D2,D0
	DBF     D1,1$
	ANDI.L  #$55555555,D0
	MOVE.L  (A7)+,D2
	RTS

FixClockBit:
	MOVE.B  (A0),D0
	BTST    #0,-1(A0)
	BNE.S   1$
	BTST    #6,D0
	BNE.S   3$
	BSET    #7,D0
	BRA.S   2$
1$:	BCLR    #7,D0
2$:	MOVE.B  D0,(A0)
3$:	RTS

* Scans track data looking for header sync pattern, which may be shifted.
* It determines the amount of shift which must be applied to decode the data.
* A0=track buffer ptr, D0=count of WORDS to scan.  Returns A0 pointing to
* start of sync pattern and D0 contains number of bits to shift.  A0=-1 on
* no match.

ScanForHdr:
	PUSH	D2-D4/A2
	MOVE.W  #$AAAA,D3		;normal sync pattern
	MOVE.W  #$5555,D4		;shifted sync pattern
	MOVE.L	A0,A2			;save ptr to buffer
	ADDA.L  D0,A2			;point to end of buffer
1$:	MOVE.W  (A0)+,D2		;check a word
	CMP.W   D3,D2			;matches normal sync pattern?
	BEQ.S   7$			;yes
	CMP.W   D4,D2			;else matches shifted sync pattern?
	BEQ.S   3$			;yes
	CMP.L	A0,A2			;else check for end of buffer
	BHI.S   1$			;not end...loop
2$:	MOVEQ   #-1,D0			;end...no match found
	MOVE.L	D0,A0
	BRA.S   8$			;exit
3$:	MOVEQ   #15,D0			;16 entries -1
	LEA     SyncTbl1,A1		;shifted pattern
4$:	CMP.L	A0,A2			;end?
	BLS.S   2$			;yes
	MOVE.W  (A0)+,D1		;else load data word
	CMP.W   D2,D1			;still getting pattern?
	BEQ.S   4$			;yes
	SUBQ.L  #2,A0			;no...backup 1 word
	MOVE.L  (A0),D1			;load longword
5$:	CMP.L   (A1)+,D1		;match pair of words from table?
	BEQ.S   6$			;yes...found shifted sync pattern
	SUBQ.L  #2,D0			;treat entries as pairs
	BGE.S   5$			;loop
	BRA.S   1$			;end of table...keep on going
6$:	SUBQ.L  #4,A0			;back up to start of sync pattern
8$:	POP	D2-D4/A2
	RTS
7$:	MOVEQ   #14,D0			;last entry is trivial
	LEA     SyncTbl2,A1		;use normal sync table
	BRA.S   4$

* This is the 55555555 table.  It is generated by taking AAAA44894489 and
* shifting by 1 to get 55552244, etc.

SyncTbl1:
	DC.W	$2244,$A244
	DC.W	$4891,$2891 
	DC.W	$5224,$4A24 
	DC.W	$5489,$1289 
	DC.W	$5522,$44A2 
	DC.W	$5548,$9128 
	DC.W	$5552,$244A 
	DC.W	$5554,$8912 

* This is the AAAAAAAA table.  It is generated by taking AAAA44894489 and
* shifting by 2 to get 2AAA9122, etc.

SyncTbl2:
	DC.W	$9122,$5122 
	DC.W	$A448,$9448 
	DC.W	$A912,$2512 
	DC.W	$AA44,$8944 
	DC.W	$AA91,$2251 
	DC.W	$AAA4,$4894 
	DC.W	$AAA9,$1225 
	DC.W	$4489,$4489 

* Called after reading a track to verify the raw data in the track buffer 
* read from the floppy.  Checks headers and data for valid checksum errors, moves
* data to the front of the buffer (following the track gap AAAA's) and returns the 
* first sector number of the buffer in D0.  Data in buffer still is in MFM 
* format (with embedded clock) but has been shifted to correct for bit 
* misalignment.

VerifyTrack:
	PUSH	D2-D6/A2
	LINK    A4,#-$10		;create work area on stack
	MOVE.L	ReadBuffer(A3),A2	;read buffer
	LEA     TrackGap(A2),A2		;skip over track gap (written, never read)
	MOVE.L	A2,A0			;buffer to A0
	ADDQ.L  #2,A0			;skip over track number
	MOVE.L  #2748,D0		;scan this many words
	BSR	ScanForHdr		;search raw data for hdr sync pattern
	CMP.L	#-1,A0			;find a header?
	BEQ	CantFindSecHdr		;no
	MOVE.L  A0,D5			;else save ptr to sync pattern
	MOVE.L  D0,D2			;and shift count
	ADDQ.L  #8,A0			;skip past sync
	MOVEQ   #9,D4			;counter for checksum
	ZAP	D6			;init checksum accumulator
	TST.L   D2			;need to shift header?
	BNE.S   2$			;yes
	MOVE.L  (A0),-8(A4)		;no...store header bytes 
	MOVE.L  4(A0),-4(A4)
	MOVE.L  #$55555555,D1		;clock bit filter
1$:	MOVE.L  (A0)+,D0		;get a longword
	AND.L   D1,D0			;filter clock bits
	EOR.L   D0,D6			;form checksum
	DBF     D4,1$			;loop for all header bytes
	MOVE.L  (A0)+,-$10(A4)		;store header checksum
	MOVE.L  (A0),-$C(A4)		;store data checksum
	BRA.S   4$
2$:	BSR	LoadShiftMFM		;load and shift header, as necessary
	MOVE.L  D0,-8(A4)		;store corrected header bytes
	BSR	LoadShiftMFM		;ditto
	MOVE.L  D0,-4(A4)
	MOVE.L	D5,A0			;sync address to A0
	ADDQ.L  #8,A0			;jump ahead to next header bytes
3$:	BSR	LoadShiftMFM		;load and shift as necessary
	ANDI.L  #$55555555,D0		;get rid of clock bits
	EOR.L   D0,D6			;form checksum
	DBF     D4,3$			;loop for all bytes
	BSR	LoadShiftMFM		;load and shift hdr checksum
	MOVE.L  D0,-$10(A4)		;store it
	BSR	LoadShiftMFM		;load and shift data checksum
	MOVE.L  D0,-$C(A4)		;store it

* When we get here we have manually shifted the first header we found in
* the buffer.

4$:	LEA     -$10(A4),A0		;load MFM hdr checksum
	BSR	DecodeLongword		;decode it
	CMP.L   D0,D6			;checksums match?
	BNE	CantReadSecHdr		;no...bad header
	LEA     -8(A4),A0		;load 4 info bytes
	BSR	DecodeLongword		;decode hdr info
	MOVE.L  D0,D3			;save
	MOVE.L  D3,-(A7)		;cute way to check a byte
	CMPI.B  #-1,0(A7)		;ADOS format code?
	BNE	CantReadSecHdr		;no...not ADOS format
	MOVE.B  1(A7),D0		;get track number
	CMP.B   NewTrk+1(A3),D0		;match track we wanted to read?
	BNE	CantReadSecHdr		;no...
	MOVE.L  (A7)+,D3		;restore info
	ZAP	D0
	MOVE.B  D3,D0			;get number of sectors to the gap
	MULU    #1088,D0		;multiply by full size of sector in MFM bytes
	MOVE.L	D5,A0			;set A0 to sync bytes
	MOVE.L	A2,A1			;saved ptr to beginning of data
	MOVE.L  D2,D1			;bit shift required
	MOVE.L  D0,D4			;distance to gap...length of blit
	BSR	BlitMoveShift		;move data up to front and shift
	ZAP	D2
	MOVE.B  D3,D2			;number of blocks to gap
	SUBI.L  #11,D2			;calc number remaining after gap
	NEG.L   D2
	BEQ.S   5$			;none...get 'em all
	ADD.L   D4,D5			;determine address of gap in buffer
	MOVE.L  #1660,D0		;max number of words to search after gap
	MOVE.L	D5,A0			;address of gap
	ADDQ.L  #2,A0
	BSR	ScanForHdr		;search gap for sector sync pattern
	CMP.L	#-1,A0			;found header?
	BEQ	TooFewSec		;no...problems
	MOVE.L  D0,D1			;number of bits to shift
	MOVE.L	A2,A1			;data buffer to A1
	ADDA.L  D4,A1			;point to end of first blit
	MOVE.L  D2,D0			;number of sectors after gap
	MULU    #1088,D0		;calculate length of second blit
	BSR	BlitMoveShift		;do it
5$:	MOVE.L	A2,A0			;buffer address to A0
	ADDA.L  D4,A0			;newly copied data starts here
	BSR	FixClockBit		;correct possible clock bit error
	LEA     11968(A2),A0		;point to end of data
	MOVE.W  #$AAA8,D0		;value for marking end
	BTST    #0,-1(A0)		;test last data bit
	BEQ.S	6$			;no fix needed
	BCLR    #15,D0			;else correct first bit of end marker
6$:	MOVE.W  D0,(A0)			;store it
	MOVE.W  #$AAAA,(A2)		;store beginning sync mark

* If we get here, the sectors have been moved to the front of the track buffer
* (following the track gap area), the gap has been moved to the end, and the
* data has been bit-shifted, as necessary.  The sectors are ready for error
* checking and decoding.  Now we check for 11 valid sectors, computing the
* header and data checksums.

	ZAP	D4			;used to count bytes of data checked
	MOVEQ   #11,D2			;this many sectors to check
	MOVE.W  D3,D5			;first header info bytes to D5
	LSR.W   #8,D5			;first sector number to low byte

SectorLoop:
	CMPI.L  #$2AAAAAAA,0(A2,D4.W)	;look for proper sector sync pattern
	BEQ.S   1$			;found it
	CMPI.L  #$AAAAAAAA,0(A2,D4.W)	;alternate sync pattern
	BNE	BadSecPreamble		;oops...garbage
1$:	CMPI.L  #$44894489,4(A2,D4.W)	;check for rest of pattern
	BNE	BadSecPreamble		;cant find sector sync pattern
	LEA     8(A2,D4.W),A0		;found sync...point to hdr data
	MOVEQ   #40,D1			;40 bytes total in hdr
	BSR	CalcCksum		;calc header checksum
	MOVE.L  D0,D6			;save it
	LEA     $30(A2,D4.W),A0		;point to hdr checksum in MFM
	BSR	DecodeLongword		;decode it
	CMP.L   D6,D0			;hdr chekcsums match?
	BNE	BadHdrCksum		;no
	LEA     8(A2,D4.W),A0		;point to hdr again
	BSR	DecodeLongword		;decode hdr info bytes
	MOVE.L  D0,-(A7)		;cute way to test a byte
	CMPI.B  #-1,0(A7)		;ADOS format code?
	BNE	BadSecID		;no...not ADOS format
	MOVE.B  1(A7),D1		;get track number
	CMP.B   NewTrk+1(A3),D1		;match the track we want?
	BNE	BadSecID		;no...
	MOVE.B  2(A7),D1		;get sector number
	CMP.B   D5,D1			;is this sector we expected (no interleave)
	BNE	BadSecID		;no...interleave not allowed
	MOVE.B  D2,3(A7)		;insert adjusted count of secs to gap
	MOVE.L  (A7)+,D0		;into D0
	LEA     8(A2,D4.W),A0		;info bytes go here
	BSR	EncodeLongword		;encode and store into hdr
	LEA     8(A2,D4.W),A0		;hdr starts here
	MOVEQ   #40,D1			;40 bytes in hdr checksum
	BSR	CalcCksum		;recalc hdr checksum
	LEA     $30(A2,D4.W),A0		;hdr checksum goes here
	BSR	EncodeLongword		;encode and store new hdr checksum
	LEA     $40(A2,D4.W),A0		;data starts here
	MOVE.W  #SectorSize*2,D1	;512*2 bytes in MFM
	BSR	CalcCksum		;calc data checksum
	MOVE.L  D0,D6			;save it
	LEA     $38(A2,D4.W),A0		;data checksum is here
	BSR	DecodeLongword		;decode it
	CMP.L   D6,D0			;checksums match?
	BNE	BadSecCksum		;no...data error
	SUBQ.L  #1,D2			;sector ok...decrement sector count
	ADDQ.B  #1,D5			;bump expected sector number
	CMPI.B  #11,D5			;need to wrap?
	BLT.S   2$			;no
	ZAP	D5			;else reset to sector 0
2$:	ADDI.W  #1088,D4		;bump data ptr past this sector
	CMPI.W  #11968,D4		;gone far enough?
	BNE	SectorLoop		;no...loop

* If we get here, all 11 sectors look good.

	MOVE.L  D3,D1			;info field of first hdr in buffer
	LSR.L   #8,D1			;sector number to low byte
	ZAP	D0
	MOVE.B  D1,D0			;first sector in buffer to D0

DecodeTrkExit:
	UNLK    A4			;clean up stack
	POP	D2-D6/A2
	RTS

DecodeError:
	NOP
	BRA	DecodeTrkExit

CantFindSecHdr:
	MOVEQ   #TDERR_NoSecHdr,D0
	BRA.S   DecodeError

CantReadSecHdr:
	MOVEQ   #TDERR_BadSecHdr,D0
	BRA.S   DecodeError

BadSecPreamble:
	MOVEQ   #TDERR_BadSecPreamble,D0
	BRA.S   DecodeError

BadSecID:
	MOVEQ   #TDERR_BadSecID,D0
	BRA.S   DecodeError

BadHdrCksum:
	MOVEQ   #TDERR_BadHdrSum,D0
	BRA.S   DecodeError

BadSecCksum:
	MOVEQ   #TDERR_BadSecSum,D0
	BRA.S   DecodeError

TooFewSec:
	MOVEQ   #TDERR_TooFewSecs,D0
	BRA.S   DecodeError

LoadShiftMFM:
	MOVE.L  (A0)+,D0
	MOVE.W  (A0),D1
	MOVEQ   #16,D3
	SUB.L   D2,D3
	LSL.L   D3,D0
	LSR.W   D2,D1
	OR.W    D1,D0
	RTS

* Moves data blocks and shifts data at the same time.
* A0=destination, A1=source, D0=byte count, D1=shift count.

BlitMoveShift:
	LINK    A2,#-$1E		;blitter node
	MOVE.B  D1,-8(A2)		;save shift count
	TST.L   D1
	BEQ.S   1$			;no shift required
	ADDQ.L  #2,D0
1$:	MOVE.L  D0,D1
	ADDI.L  #$3F,D1
	ANDI.W  #-$40,D1
	ORI.W   #$20,D1
	MOVE.W  D1,-$A(A2)
	MOVEM.L	D0/A0-A1,-$16(A2)
	MOVE.L  #BlitRtn1,-$1A(A2)	;blitter function
	MOVE.L  A3,-4(A2)
	LEA     -$1E(A2),A1
	LINKSYS	QBlit,mf_GraphicsBase(A6) ;queue blitter request
	BSR	WaitForSignal		;wait for blit complete
	UNLK    A2			;clean up stack
	RTS

BlitRtn1:
	MOVE.L  A5,-(A7)
	MOVE.L	A1,A5
	BSR	BlitInit
	MOVE.B  $16(A5),D0
	MOVEQ   #$C,D1
	LSL.W   D1,D0
	MOVE.W  #$5CC,$40(A0)		;BLTCON0
	MOVE.W  D0,$42(A0)		;BLTCON1
	MOVEM.L	8(A5),D0-D1/A1
	MOVE.L  D1,$4C(A0)		;source B
	MOVE.L  #BlitRtn4,4(A5)		;next blitter function
	TST.B   $16(A5)
	BEQ.S   1$
	SUBQ.L  #2,A1
	MOVE.L  #BlitRtn3,4(A5)		;alternate blitter function
1$:	MOVE.L  A1,$54(A0)		;destD
	MOVE.W  (A1),$18(A5)
	MOVE.W  $14(A5),$58(A0)		;start blitter
	MOVE.L	(A7)+,A5
	RTS

BlitRtn3:
	MOVE.L	$10(A1),A0
	MOVE.W  $18(A1),-2(A0)
BlitRtn4:
	ZAP	D0
	MOVE.L  D0,4(A1)		;clobber linkage
	MOVE.L	$1A(A1),A1
	BSR	BlitBlockComp		;blitter finished
	ZAP	D0
	RTS

* Blitter initialization

BlitInit:
	ZAP	D0
	LEA     $44(A0),A1
	MOVE.L  #-1,(A1)
	LEA     $62(A0),A1
	MOVE.L  D0,(A1)+
	MOVE.W  D0,(A1)+
	ADDQ.L  #8,A1
	MOVE.W  #$5555,(A1)
	RTS

* This is the disk complete/blitter complete ISR.  It is called by
* the system with A1 set to the proper unit table based on the current
* "owner" of the hardware, which is maintained by the Disk Resource
* routine.  The vector is through the unit table disk complete vector.
* This routine sends a msg to the sleeping task to wake it up.

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

