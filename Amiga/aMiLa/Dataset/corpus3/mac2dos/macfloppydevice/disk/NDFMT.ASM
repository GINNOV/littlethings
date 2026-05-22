*********************************************************
*							*
*		MacFloppy.device			*
*							*
*	mffmt.asm - amy and mac format routines		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*							*
*********************************************************

	INCLUDE "vd0:MACROS.ASM"
	INCLUDE "mf.i"

	XDEF	FormatCmd

	XREF	TimeDelay
	XREF	CalcTrkSec,Seek
	XREF	EncodeSector
	XREF	WriteCurrentTrack,WriteTrack
;	XREF	SendReplyMsg
	XREF	MotorOnOff
	XREF	EncodeGCRData
	XREF	InitTrackGap
	XREF	AlignSectors

	XREF	SectorTable
	XREF	BinToGcr

* Formats one track.  IO_OFFSET translates to proper track (must be
* track boundary, and IO_LENGTH must be 11*512.  IO_DATA points to
* data written with the format.

FormatCmd:
	PUSH	D2-D3/A3-A4
	MOVE.L	A1,A4			;caller's iob to A4
	MOVE.L	IO_UNIT(A4),A3		;unit table
	MOVE.L	IO_DATA(A4),UserBuffer(A3)			;GEC 1/18/90
	MOVEQ   #1,D0			;turn motor on
	BSR	MotorOnOff
	IFNZL	D0,1$			;motor was on
	MOVE.L  #300000,D0		;wait 300MS for motor to spin up
	BSR	TimeDelay
1$:	MOVE.L	WriteBuffer(A3),A0	;get write buffer
	MOVE.L	A0,ReadBuffer(A3)
	BCLR    #0,2(A0)		;clear dirty flag
	BEQ.S   2$			;it wasn't dirty
	BSR	WriteCurrentTrack	;else write out current track
	IFZL	D0,2$			;no error
	MOVE.B  D0,IO_ERROR(A4)		;else return error to caller
	BRA	6$
2$:	IFZB	DiskType(A3),10$	;ADOS
	MOVE.B	#1,DiskType(A3)		;force single-sided
	IFLEIL	IO_LENGTH(A4),#12*512,10$	;it is single-sided Mac
	MOVE.B	#2,DiskType(A3)		;else force double-sided
10$:	MOVE.L  IO_OFFSET(A4),D0	;offset tells us what track
	BSR	CalcTrkSec		;check it out
	MOVE.L  D0,D2			;save starting track number
	TST.L   D1			;sector better be 0 (whole track)
	BNE	7$			;no...can't format track
	MOVE.L  IO_LENGTH(A4),D0	;figure out how many tracks
	MOVE.W	D2,D1			;starting with this track
	BSR	CheckLength		;better be whole tracks
	ERROR	7$			;not proper length
	MOVE.L  D0,D3			;number of tracks to format to D3
	BEQ	6$			;oops...zero tracks: nothing to do
	ADD.L   D2,D0			;add number to format to starting track
	CMP.L   #MaxTracks,D0		;too many for disk?
	BHI.L   7$			;yes...too bad
8$:	MOVE.L  D2,D0			;format this track
	BSR	Seek			;step to proper track
	BSR	InitTrackGap		;init gap to proper type
	BSR	MacTrack		;else build Mac track

4$:	MOVE.L	WriteBuffer(A3),A0	;write this buffer to disk
	LEA     4(A0),A0		;skip first longword
	MOVE.L  WriteLength(A3),D0	;write this many bytes
	BSR	WriteTrack		;write track now
	IFZL	D0,5$			;no error
	MOVE.B  D0,IO_ERROR(A4)		;else return error
	BRA.S   6$			
5$:	ADDQ.L  #1,D2			;bump track number
	SUBQ.L  #1,D3			;track loop counter
	BNE.S   8$			;loop for all tracks
	MOVE.L	WriteBuffer(A3),A1	;get buffer ptr
	MOVE.W  #-1,0(A1)		;mark contents unknown
6$:	MOVE.L	A4,A1
;	BSR	SendReplyMsg
	POP	D2-D3/A3-A4
	RTS

7$:	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A4)	;format error
	BRA.S   6$

* Builds one Mac track in WriteBuffer.
* Track number (0-159) in D2.
* WARNING -- Dont step on D2/A3-A4.

MacTrack:
	PUSH	D4/A2
	LEA	SectorTable,A2		;set up some headers
	MOVE.L	WriteBuffer(A3),A0
	MOVE.W	D2,(A0)			;save track number into buffer
	LEA	MacReadGap(A0),A0	;point beyond write area
	ZAP	D4			;start with sector 0
1$:	MOVE.L	A0,(A2)+		;sector header starts here
	MOVE.L	D4,D0			;sector number
	BSR	EncodeHeader		;returns ptr in A0
	MOVE.L	A0,(A2)+		;data starts here
	MOVE.L	D4,D0			;pass sector number
	BSR	EncodeGCRData		;returns ptr in A0
	ADD.L	#512,UserBuffer(A3)	;advance user's ptr
	INCB	D4
	IFLTB	D4,SecsPerTrk(A3),1$	;loop for all sectors
	BSR	AlignSectors		;now build the write buffer
	POP	D4/A2
	RTS

EncodeHeader:
	PUSH	D2-D6/A2-A3
	LEA	HdrTrl,A1
	MOVEQ	#2,D1
1$:	MOVE.B	(A1)+,(A0)+		;$D5 $AA $96
	DBF	D1,1$
	LEA	BinToGcr,A2
	ZAP	D3			;side/overflow
	LSR.W	#1,D2			;conv to 0-79, side bit->cy
	BCC.S	2$			;side 0
	BSET	#5,D3			;side 1
2$:	CMP.B	#64,D2			;in range?
	BCS.S	3$			;yes
	SUB.B	#64,D2			;else adjust for range 64-79
	BSET	#0,D3			;and set overflow bit
3$:	MOVE.B	D2,D6			;start hdr checksum
	MOVE.B	0(A2,D2.W),(A0)+	;convert and store track
	EOR.B	D0,D6
	MOVE.B	0(A2,D0.W),(A0)+	;ditto sector
	EOR.B	D3,D6
	MOVE.B	0(A2,D3.W),(A0)+	;overflow/side
	MOVEQ	#2,D0			;format byte
	IFEQIB	DiskType(A3),#1,4$	;single-sided format
	MOVEQ	#$22,D0			;else double-sided format
4$:	EOR.B	D0,D6
	MOVE.B	0(A2,D0.W),(A0)+	;format byte
	MOVE.B	0(A2,D6.W),(A0)+	;hdr checksum
5$:	MOVE.B	(A1)+,(A0)+		;$DE $AA $D5 $AA $AD
	BNE.S	5$
	DECL	A0			;backup to trailing 0
	POP	D2-D6/A2-A3
	RTS

* Checks IO_LENGTH in D0 to ensure that it is a multiple of the track
* length.  Track number in D1,  Returns number of tracks in D0 or CY=1.

CheckLength:
	PUSH	D2-D4
	LSR.W	#5,D1			;divide to get band number
	MOVEQ	#12,D2
	SUB.W	D1,D2			;get secs per track
	MOVE.B	D2,SecsPerTrk(A3)
;	ZAP	D2
;	MOVE.B	SecsPerTrk(A3),D2
	MOVEQ	#9,D3
	LSL.L	D3,D2			;number of bytes per track
	MOVE.L	D0,D4
	ZAP	D0
1$:	INCL	D0			;one track
	SUB.L	D2,D4
	BHI.S	1$			;not there yet
	BEQ.S	9$			;must end up even
	STC				;else not mult of track size
9$:	POP	D2-D4
	RTS


HdrTrl	DC.B	$D5,$AA,$96,$DE,$AA,$D5,$AA,$AD,0

	END

