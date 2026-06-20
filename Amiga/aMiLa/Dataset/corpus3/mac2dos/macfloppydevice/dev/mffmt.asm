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
	XREF	SendReplyMsg
	XREF	MotorOnOff
	XREF	InitTrackGap

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
2$:	MOVE.L  IO_OFFSET(A4),D0	;offset tells us what track
	BSR	CalcTrkSec		;check it out
	MOVE.L  D0,D2			;save starting track number
	TST.L   D1			;sector better be 0 (whole track)
	BNE	7$			;no...can't format track
	MOVE.L  IO_LENGTH(A4),D0	;figure out how many tracks
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
	BSR	DosTrack		;build ADOS track
	MOVE.L	WriteBuffer(A3),A0	;write this buffer to disk
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
	BSR	SendReplyMsg
	POP	D2-D3/A3-A4
	RTS

7$:	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A4)	;format error
	BRA.S   6$

* Builds one ADOS track.
* Warning--watch register usage...you'll step on the calling routine.
* D2/A3-A4 already set...don't touch.

DosTrack:
;;	PUSH	D4-D5/A2/A5					;gec 2/9/90
	PUSH	D4-D5/A2					;gec 2/9/90
	MOVE.L	WriteBuffer(A3),A2	;write buffer
	LEA     $680(A2),A2		;encode data here
;;	MOVE.L	IO_DATA(A4),A5		;get user's data	;gec 2/9/90
	MOVEQ   #11,D4			;sectors per track
	ZAP	D5			;start with sector 0

* Sector loop.  First builds sector header, then sector data.

1$:	MOVE.L  #$FF000000,D0		;start with ADOS format code
	MOVE.L  D5,D1			;sector number to low byte
	LSL.L   #8,D1			;swab D1
	OR.L    D1,D0			;sector into hdr info
	OR.L    D4,D0			;number of sectors to gap
	MOVE.L  D2,D1			;track number to D1
	SWAP    D1			;get trk nmber to proper position
	OR.L    D1,D0			;into hdr info
	MOVE.L	A2,A1			;encoded hdr data goes here
;;	MOVE.L	A5,A0			;ptr to user's data	;gec 2/9/90
	MOVE.L	UserBuffer(A3),A0	;encode this data	;gec 2/9/90
	BSR	EncodeSector		;encode one sector
	ADDQ.L  #1,D5			;one more sector completed
	ADDA.L  #1088,A2		;bump buffer ptr
;;	ADDA.L  #512,A5			;bump user's data ptr	;gec 2/9/90
	ADD.L	#512,UserBuffer(A3)	;bump user's data ptr	;gec 2/9/90
	SUBQ.L  #1,D4			;loop counter
	BNE.S   1$			;loop for all sectors
;;	POP	D4-D5/A2/A5					;gec 2/9/90
	POP	D4-D5/A2					;gec 2/9/90
	RTS


* Checks IO_LENGTH in D0 to ensure that it is a multiple of the track
* length.  Returns number of tracks in D0 or CY=1.

CheckLength:
	PUSH	D2-D4
	ZAP	D2
	MOVE.B	SecsPerTrk(A3),D2
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

	END

