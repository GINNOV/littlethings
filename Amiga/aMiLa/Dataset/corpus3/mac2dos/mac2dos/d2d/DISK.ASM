*****************************************************************
*								*
*		      Mac-2-Dos					*
*								*
*		Mac Disk Driver Routines			*
*								*
*	Copyright (c) 1989 Central Coast Software		*
*	424 Vista Avenue, Golden, CO 80401			*
*	     All rights reserved, worldwide			*
*								*
*****************************************************************

	INCLUDE "MACMAC.ASM"

	XDEF	ReadSector,ReadN,WriteSector,WriteN
	XDEF	FlushTrack,FormatTrack,FORMAT_TRACK
	XDEF	DISK_INIT,DISK_EXIT,DISK_CAL,MotorOff
	XDEF	STORE_D0_D1_TIMES
	XDEF	SetTrkParams,MON,CLR_TPARAM
	XDEF	CheckProtection	

	XDEF	MOTOR_OFF,FLUSH_TRACK
	XDEF	SEC_PER_CYL,SEC_PER_TRACK,NEW_SIDE,NEW_TRACK
	XDEF	WRITE_SECTOR,WRITE_N,READ_SECTOR,READ_N
	XDEF	D2D_TASK

	XDEF	DR_BASE,DRIVE_SEL,SecsPerTrack
	XDEF	MSG_PORT

	XREF	SysBase,GraphicsBase
	XREF	MacFileNbr

* HARDWARE REGISTER DEFINITIONS

DSKPTR	EQU	$DFF020
DSKLEN	EQU	$DFF024
DSKBYTR	EQU	$DFF01A
DSKSYNC	EQU	$DFF07E
CIAA	EQU	$BFE001
CIAB	EQU	$BFD100
INTENAR	EQU	$DFF01C
INTENA	EQU	$DFF09A
INTREQ	EQU	$DFF09C
INTREQR	EQU	$DFF01E
ADKCON	EQU	$DFF09E
ADKCONR	EQU	$DFF010
VHPOSR	EQU	$DFF006

TrkBufSize	EQU	20000		;TRACK BUFFR SIZE IN BYTES
SectorSize	EQU	512		;NUMBER OF BYTES IN A SECTOR (BLOCK)
MaxSectors	EQU	11		;MAX NUMBER OF SECTORS

TR_ADDREQUEST	EQU	9	;TIMER IO REQUEST

DF0		EQU	$08+$10+$20
NONE		EQU	$40+$80+DF0
CA0		EQU	$01+DF0
CA1		EQU	$02+DF0
CA2		EQU	$04+DF0
DrvEnable	EQU	DF0
LSTRB		EQU	$40+DF0		;working as df3
SEL		EQU	$80+DF0
;MTRX		EQU	$80

* Read n physical sectors (blocks).  Block number (0 origin) in D0.
* Number of contiguous blocks in D1.  User's buffer address in A0.

READ_N:
ReadN:	DECW	D1		;FOR DBF
1$:	PUSH	D0-D1/A0
	BSR.S	ReadSector
	POP	D0-D1/A0
	ERROR	2$
	ADDA.L	#512,A0
	INCW	D0		;NEXT BLOCK
	DBF	D1,1$		;DO THEM ALL
	CLC
2$:	RTS

* Read physical sector in D0 (0 origin), buffer address in A0.

READ_SECTOR:
ReadSector:
	BSR	SetTrkParams	;calculate physical track, side, and sector
;	BSR	BuildHeader
	MOVE.B	#10,RetryCount
1$:	IFNZB	InvalidFlg,4$	;invalid data - force track read
	MOVE.B	CurSide,D0	;is current side the one we want?
	CMP.B	NewSide,D0
	BNE.S	5$		;no...force read
	MOVE.B	CurTrack,D0	;is current track the one we want?
	CMP.B	NewTrack,D0
	BEQ.S	3$		;yes...don't read it again
5$:	IFZB	DirtyFlg,4$	;don't need to write out current track
	BSR	FlushTrack	;else write out the current track first
	RTSERR
4$:	BSR	BusyDrives	;sieze disk control hardware
	BSR	SelectDrive	;select drive and check for a diskette
	ERROR	8$		;drive not ready...bail out
	BSR	MotorOn		;make sure drive is spinning
	BSR	Seek		;get us to the right track
	BSR	ReadTrack	;read desired track
	BSR	FreeDrives
	ERROR	2$		;read error
	BSR	DecodeTrack	;decode sectors from track data
	ERROR	2$		;couldn't find sector hdrs...not Amiga disk?
	CLR.B	InvalidFlg
3$:	BSR	MoveSector	;move sector data to user's buffer
	NOERROR	9$
2$:	SETF	InvalidFlg	;force reread
	DECB	RetryCount	;read error...retry?
	BNE.S	1$		;yes
	DispErr	ReadErr.	;else warn op...Mac SECTOR READ ERROR
8$:	BSR	FreeDrives
	STC			;RETURN ERROR FLAG
9$:	RTS

* Write n physical sectors (blocks).  Block number (0 origin) in D0.
* Number of contiguous blocks in D1.  User's buffer address in A0.

WRITE_N:
WriteN:
	DECW	D1		;FOR DBF
1$:	PUSH	D0-D1/A0
	BSR.S	WriteSector
	POP	D0-D1/A0
	ERROR	2$
	ADDA.L	#512,A0
	INCW	D0		;NEXT BLOCK
	DBF	D1,1$		;DO THEM ALL
	CLC
2$:	RTS

* Write physical sector in D0 (0 origin), buffer address in A0.

WRITE_SECTOR:
WriteSector:
	BSR	SetTrkParams	;calculate physical track, side, and sector
	BSR	CheckProtection	;disk write protected?
	RTSERR			;protected...don't write
;	BSR	BuildHeader
	MOVE.B	#10,RetryCount
1$:	IFNZB	InvalidFlg,4$	;invalid data - force track read
	MOVE.B	CurSide,D0	;is current side the one we want?
	CMP.B	NewSide,D0
	BNE.S	5$		;no...force read
	MOVE.B	CurTrack,D0	;else is current track the one we want?
	CMP.B	NewTrack,D0
	BEQ.S	3$		;yes...don't read it again
5$:	IFZB	DirtyFlg,4$	;don't need to write out current track
	BSR	FlushTrack	;else write out the current track first
	RTSERR			;oops...problem writing current track
	CLR.B	DirtyFlg	;current track matches disk
4$:	BSR	BusyDrives	;sieze the disk control hardware
	BSR	SelectDrive	;select drive and check for a diskette
	ERROR	8$
	BSR	MotorOn
	BSR	Seek		;get us to the right track
	BSR	ReadTrack	;read desired track
	ERROR	2$		;read error
	BSR	FindHeaders	;search track for desired sector header
	ERROR	2$		;can't find proper header...not a Mac disk?
	CLR.B	InvalidFlg	;got valid track data
3$:	BSR	EncodeSector	;move data into track from user's buffer
	ERROR	2$		;no sector header
	SETF	DirtyFlg	;this track needs to be written
	BRA.S	9$
2$:	SETF	InvalidFlg	;force reread
	DECB	RetryCount	;read error...retry?
	BNE	1$		;yes
	DispErr	ReadErr.	;else warn op...Mac SECTOR READ ERROR
8$:	STC			;RETURN ERROR FLAG
9$:	RTS

* Reads selected track into track buffer

ReadTrack:
	CALLSYS	Forbid,SysBase
	DISABLE
	MOVE.W	#$9100,ADKCON		;set MFM precomp and 2usec clock
;	MOVE.W	#$8300,ADKCON		;APPLE SYNC
;	MOVE.W	#$D5AA,DSKSYNC		;sync on start sequence
	MOVE.W	#$3002,INTREQ		;clear pending ints
;	MOVE.W	#$8400,ADKCON		;ENABLE DMA SYNC
	MOVE.L	ReadBuf,A0
	LEA	1668(A0),A0
	MOVE.L	A0,DSKPTR		;READ INTO TRACK BUFFER
	BSR	AdjustDutyCycle		;adjust track speed, as necessary
	IFZB	NewSide,1$
	MOVE.B	#CA2!SEL,D2		;READ DATA -- UPPER HEAD
	BRA.S	2$
1$:	MOVE.B	#CA2,D2			;READ DATA -- LOWER HEAD
2$:	MOVE.B	D2,D3
	BSET	#6,D3			;turn SELn ON, corresponds to OnDuty
	MOVE.W	ReadLength,D0		;number of words, track dependent
	OR.W	#$8000,D0		;set the GO bit
	MOVE.W	D0,DSKLEN		;START DMA TRANSFER INTO BUFFER
	MOVE.W	D0,DSKLEN
3$:	MOVE.B	D3,(A1)			;SELn ON
	MOVE.W	OnDuty,D1		;slow motor down
5$:	DBF	D1,5$
	MOVE.B	D2,(A1)			;SELn OFF
	MOVE.W	OffDuty,D1		;speed motor up
6$:	DBF	D1,6$
;	MOVE.B	D3,(A1)			;SELn ON
	MOVE.W	INTREQR,D0		;GOT SECTOR?
	BTST	#1,D0
	BEQ.S	3$			;NO
	MOVE.W	#$4000,DSKLEN		;STOP DMA
	MOVE.W	#$3002,INTREQ
;	MOVE.B	#$FF,(A1)		;deselect that sucker
	ENABLE
	CALLSYS	Permit
;	BSR	FreeDrives		;drives busy since motor on
	RTS

* Writes current contents of ReadBuf to disk

FLUSH_TRACK:
FlushTrack:
	PUSH	D0-D7/A0-A6
	MOVE.W	D0,WriteLength		;save size of write
	BSR	BusyDrives		;sieze disk control hardware
	BSR	SelectDrive		;select drive and check for a diskette
	RTSERR				;drive not ready...bail out
	BSR	MotorOn			;make sure drive is spinning
;	BSR	AlignSectors		;move data from ReadBuf to WriteBuf
	CALLSYS	Forbid,SysBase
	DISABLE
;	MOVE.W	#$7500,ADKCON
	MOVE.W	#$9100,ADKCON		;select 2usec, MFM precomp
	MOVE.W	#$3002,INTREQ		;clear pending ints
	BSR	AdjustDutyCycle		;adjust track speed, as necessary
	IFZB	NewSide,1$
	MOVE.B	#CA2!SEL,D2		;select upper head
	BRA.S	2$
1$:	MOVE.B	#CA2,D2			;select lower head
2$:	MOVE.B	D2,D3
	BSET	#6,D3			;turn SELn ON, corresponds to OnDuty
	MOVE.L	ReadBuf,A0
	LEA	4(A0),A0
	MOVE.L	A0,DSKPTR		;write from this buffer
	MOVE.W	WriteLength,D0		;number of words, track dependent
	OR.W	#$C000,D0		;set the GO bit and force write
	MOVE.W	D0,DSKLEN		;START DMA TRANSFER from BUFFER
	MOVE.W	D0,DSKLEN
3$:	MOVE.B	D3,(A1)			;SELn ON
	MOVE.W	OnDuty,D1
5$:	DBF	D1,5$
	MOVE.B	D2,(A1)			;SELn OFF
	MOVE.W	OffDuty,D1
6$:	DBF	D1,6$
;	MOVE.B	D3,(A1)
	MOVE.W	INTREQR,D0		;write complete?
	BTST	#1,D0
	BEQ.S	3$			;NO
	MOVE.W	#$4000,DSKLEN		;STOP DMA
	MOVE.W	#$3002,INTREQ
;	MOVE.B	#$FF,(A1)		;deselect that sucker
	ENABLE
	CALLSYS	Permit
	BSR	FreeDrives
	POP	D0-D7/A0-A6
	RTS

* Sets drive speed to proper range before starting track read/write.

AdjustDutyCycle:
	LEA	CIAB,A1
	MOVE.B	#DrvEnable,(A1)		;prepare to enable speed control
	MOVE.B	#CA0!CA1!CA2!SEL,(A1)	;enable speed control
	MOVE.B	#CA0!CA1!SEL,D2
	MOVE.B	D2,D3
	BSET	#6,D3
	MOVE.W	DelayCount,D0		;adjust drive speed
1$:	MOVE.B	D3,(A1)
	MOVE.W	OnDuty,D1
5$:	DBF	D1,5$
	MOVE.B	D2,(A1)
	MOVE.W	OffDuty,D1
6$:	DBF	D1,6$
;	MOVE.B	D3,(A1)
	NOP
	NOP
	NOP
	NOP
	NOP
	DBF	D0,1$
	RTS

* Copy from ReadBuf to WriteBuf prior to write.  The idea is to move sector 0
* to the front of the buffer and build sector gaps, as necessary.

TrkGapSize	EQU	50	;number of FFs in main gap
HdrSize		EQU	10	;count of bytes in header
HdrGapSize	EQU	10	;count of FFs in gap 'tween hdr and data
RawSectorSize	EQU	709	;count of raw bytes in sector
SecGapSize	EQU	39	;count of FFs between sectors

* Note - this routine DOES NOT follow Mac standard sector interleave

AlignSectors:
	RTS

* CHECKS SELECTED DRIVE FOR WRITE-PROTECTION STATUS, ALERTS
* OPERATOR AND SETS CY IF SO.

CHECK_PROTECTION:
CheckProtection:
	BSR	BusyDrives		;GET CONTROL
	MOVE.B	#$FF,CIAB
	MOVE.B	#NONE,CIAB
	MOVE.B	#DrvEnable,CIAB
	MOVE.B	#SEL!CA0,CIAB		;WRTPRT=write locked
	MOVE.B	CIAA,D0
	PUSH	D0
	BSR	FreeDrives
	POP	D0
	AND.W	#$20,D0
	BNE.S	9$			;write enabled
	DispErr	WrtProt.		;WARN OPERATOR
	STC				;else error
9$:	RTS

* Calculates TRACK AND SECTOR, CALCULATES SIDE, AND SETS UP TRACK PARAMETERS.
* Block IN D0, BUFFER IN A0.

MaxSector	EQU	1760
SecPerTrack	EQU	11

SetTrkParams:
	MOVE.L	A0,DataBuffer	;SAVE BUFFER ADDRESS
	CMP.W	#MaxSector,D0	;sector too large
	BCC.S	8$		;yes
	EXT.L	D0
	DIVU	#SecPerTrack,D0	;find out what track
	MOVE.B	D0,NewTrack	;
	CLR.B	NewSide		;force side 0
	BTST	#0,D0		;odd track?
	BEQ.S	1$		;no...side 0
	SETF	NewSide		;else force side 1
1$:	SWAP	D0		;remainder gives sector and side
	MOVE.B	D0,NewSector
	LEA	TPARAM_TBL,A0	;BASE OF TRACK PARAM TABLE
3$:	MOVE.W	(A0)+,SecsPerTrack ;NUMBER OF SECTORS ON THIS TRACK
	MOVE.W	(A0)+,ReadLength ;NUMBER OF WORDS PER TRACK
	MOVE.W	(A0)+,OnDuty	;INITIAL OffDuty
	MOVE.W	(A0)+,OffDuty	;INITIAL OnDuty
	MOVE.W	#2000,DelayCount
	RTS
8$:	DispErr	SecRng.
	STC
	RTS

* SELECT DRIVE, AND CALIBRATE TO TRACK 0.

HomeDisk:
	BSR	Track0
	NOERROR	9$
	CLR.B	DIR			;first step away from track 0
	MOVEQ	#2,D2
2$:	BSR	STEP
	DBF	D2,2$			;loop
	MOVE.B	#$20,DIR		;direction=toward TRACK 0
1$:	BSR	Track0
	NOERROR	9$
	BSR	STEP
	BRA.S	1$
9$:	ZAP	D0
	MOVE.B	D0,CurTrack		;SITTING AT HOME
	MOVE.B	D0,CurSector
	MOVE.B	D0,CurSide
	RTS

* Sets stepping direction according to DIR: 0=away from trk 0, 1=toward 0.

SetDirection:
	MOVE.B	#CA0!CA1,CIAB
	TST.B	DIR			;toward track 0?
	BEQ.S	1$			;no...away
	MOVE.B	#CA2,CIAB
	MOVE.B	#CA2!LSTRB,CIAB		;toward 0
	NOP
	NOP
	MOVE.B	#CA2,CIAB
	BRA.S	2$
1$:	MOVE.B	#LSTRB,CIAB		;away from 0
	NOP
	NOP
;	MOVE.B	#NONE,CIAB
2$:	MOVE.B	#CA0!CA1,CIAB
	RTS

* Checks for head over track 0.

Track0:	MOVE.B	#SEL!CA1,CIAB		;TK0
	MOVE.B	CIAA,D0
	AND.W	#$20,D0
	BEQ.S	9$			;at track 0
	STC				;else error
9$:	RTS

DISK_CAL:
	BSR	BusyDrives
	BSR	MotorOn			;TURN MOTOR ON
	BSR	HomeDisk		;get it to track 0
	CLR.B	CurTrack		;SHOW DISK NOW AT TRACK 0
	SETF	InvalidFlg		;nothing in buffer
	BSR	FreeDrives
	RTS

* CLEARS TRACK SPEED VALUES FROM TPARAM_TBL.

CLR_TPARAM:
	LEA	TPARAM_TBL,A0		;ZAP THE SPEED TABLE
	ZAP	D0
	MOVEQ	#4,D1			;5 GROUPS OF TRACKS
1$:	MOVE.L	D0,12(A0)		;ZAP ACTUAL OffDuty, OnDuty
	ADD.L	#TPAR_LEN,A0		;POINT TO NEXT ENTRY
	DBF	D1,1$
	RTS

* Select drive and check for disk in drive

SelectDrive:
	MOVE.B	#$FF,CIAB
	MOVE.B	#NONE,CIAB
	MOVE.B	#DrvEnable,CIAB
	MOVE.B	#SEL,CIAB		;CSTIN=disk in place
	MOVE.B	CIAA,D0
	AND.W	#$20,D0
	BEQ.S	9$
	DispErr	DrvNotRdy.
	STC
9$:	RTS

* SeekS TO PROPER TRACK, IF NECESSARY.  ASSUMES THAT DRIVE ALREADY
* SELECTED, AND MOTOR ON.

Seek:	PUSH	D2
	ZAP	D0
	ZAP	D2
	MOVE.B	CurTrack,D2
	MOVE.B	NewTrack,D0
	CLR.B	NewSide			;force side 0
	BTST	#0,D0			;odd track?
	BEQ.S	5$			;no, even
	SETF	NewSide			;else side 1
5$:	CMP.B	D0,D2			;already on correct track?
	BEQ.S	9$			;yes
	LSR.W	#1,D2
	LSR.W	#1,D0
	SUB.W	D0,D2			;calc which way to move
	BCS.S	1$
	BHI.S	4$
	BRA.S	9$

4$:	SETF	DIR			;MOVE TOWARD TRACK 0
	BRA.S	2$
1$:	CLR.B	DIR			;MOVE TOWARD SPINDLE
	NEG.W	D2
	BRA.S	2$
3$:	BSR	STEP			;DO IT
2$:	DBF	D2,3$			;LOOP TILL WE GET THERE
	MOVE.L	#15000,D0		;15MS HEAD SETTLING DELAY
	BSR	DELAY
9$:	MOVE.B	NewTrack,CurTrack	;NOW MAKE NEW TRACK CURRENT TRACK
	MOVE.B	NewSide,CurSide
	MOVE.B	NewSector,CurSector
	POP	D2
	RTS

* STEP THE HEADS

STEP:	BSR	SetDirection
	MOVE.B	#CA0!CA1,CIAB		;now issue step command
	MOVE.B	#CA0!CA2,CIAB		;start with CA2=1
	MOVE.B	#CA0!CA2!LSTRB,CIAB
	NOP
	NOP
	MOVE.B	#CA0!CA2,CIAB
	MOVE.B	#CA0!CA1,CIAB		;change CA2=0 to force the step
	MOVE.B	#CA0,CIAB
	MOVE.B	#CA0!LSTRB,CIAB
	NOP
	NOP
	MOVE.B	#CA0,CIAB
	MOVEQ	#-1,D1
1$:	MOVE.B	CIAA,D0
	AND.W	#$20,D0
	BNE.S	2$
	DBF	D1,1$
	STC
2$:	RTS

* TIME DELAY USING EXEC TIMER.  DELAY IN D0, UNITS OF USECS.

DELAY:
	PUSH	D2
	MOVE.L	D0,TB_USEC		;SAVE DELAY VALUE IN USECS
;	BSR	FreeDrives		;GIVE UP DRIVES DURING DELAY
	LEA	TIMER_BLOCK,A1
	MOVE.W	#TR_ADDREQUEST,TB_CMD	;SIMPLE TIMER REQUEST
	CLR.L	TB_SECS			;SET SECONDS TO 0
	CALLSYS	DoIO,SysBase
;	BSR	BusyDrives		;GET DRIVES AGAIN
	POP	D2
;	MOVE.B	DRIVE_SEL,CIAB		;RESELECT DRIVE
	RTS

* FORMATS A SINGLE TRACK, DEFINED IN D1.  RANGE: 1 TO 70.

* WARNING - CHECK PROTECTION SOMEWHERE!

* Starting track number in D0, number of tracks in D1

FORMAT_TRACK:
FormatTrack:
	PUSH	D2-D7/A2-A6
	MOVE.L	A0,DataBuffer
	MOVE.L	D0,D2		;starting track number
	MOVE.L	D1,D3		;number of tracks
	LEA	TPARAM_TBL,A0	;BASE OF TRACK PARAM TABLE
	MOVE.W	(A0)+,SecsPerTrack ;NUMBER OF SECTORS ON THIS TRACK
	MOVE.W	(A0)+,ReadLength ;NUMBER OF WORDS PER TRACK
	MOVE.W	(A0)+,OnDuty	;INITIAL OffDuty
	MOVE.W	(A0)+,OffDuty	;INITIAL OnDuty
	MOVE.W	#2000,DelayCount
3$:	MOVE.B	D2,NewTrack	;seek to this track
	BSR	Seek		;get to the right track ***
	MOVE.L	DataBuffer,A5	;user's data buffer
	MOVE.L	ReadBuf,A2	;use read buffer for writes
	LEA	4(A2),A2	;skip first long word
	MOVE.W	#4095,D0
	MOVE.L	#$AAAAAAAA,D1
1$:	MOVE.L	D1,(A2)+	;fill in track gap area
	DBF	D0,1$
	MOVE.L	ReadBuf,A2
	LEA	1664(A2),A2	;point past track gap
	MOVEQ	#11,D4		;11 sectors per track
	ZAP	D5
2$:	MOVE.L	#$FF000000,D0	;start with ADOS format code in hdr info
	MOVE.L	D5,D1		;sector number to low byte
	LSL.L	#8,D1		;swab sector
	OR.L	D1,D0		;sector into hdr info
	OR.L	D4,D0		;number of sectors to gap
	MOVE.L	D2,D1		;track number to D1
	SWAP	D1		;get track number to proper position
	OR.L	D1,D0		;track number into hdr info
	MOVE.L	A2,A1		;encoded data to go here
	MOVE.L	A5,A0		;user's data to be encoded into buffer
	BSR	EncodeSector	;encode users data into buffer
	ADDQ.L	#1,D5		;did one sector
	ADD.L	#1088,A2	;point past sector data
	ADD.L	#512,A5		;point to next data in buffer
	SUBQ.L	#1,D4		;completed one sector...any more?
	BNE.S	2$		;yes...loop for all sectors of track
	MOVE.L	ReadBuf,A0	;write data from here
	LEA	4(A0),A0
	MOVE.W	#6815,D0	;word count for write
	BSR	FlushTrack	;write the track to the disk
	ERROR	9$		;write failed...bail out
	ADDQ.L	#1,D2		;advance to next track
	SUBQ.L	#1,D3		;any more tracks to do?
	BNE	3$		;loop for remaining tracks
	CLC
9$:	POP	D2-D7/A2-A6
	RTS

* Encodes one sector.  Data to be encoded in A0, stored via A1.
* Header info bytes in D0.

EncodeSector:
	PUSH	D2/A2/A4
	MOVE.L	A1,A4		;ptr to where encoded data to be stored
	MOVE.L	A0,A2		;ptr to unencoded data from user's buffer
	MOVE.L	D0,D2		;save hdr info bytes
	ZAP	D0
	LEA	0(A4),A0	;encode data here
	BSR	EncodeLongword	;encode zero's as $AAAAAAAA
	MOVE.L	#$44894489,4(A4) ;followed by sync pattern
	MOVE.L	D2,D0		;hdr info bytes
	LEA	8(A4),A0	;point past hdr
	BSR	EncodeLongword
	MOVEQ	#3,D2		;store 16 bytes of 0
1$:	ZAP	D0
	BSR	EncodeLongword
	DBF	D2,1$
	LEA	8(A4),A0	;point to header
	MOVEQ	#40,D1		;40 bytes in hdr
	BSR	CalcCksum	;calculate hdr checksum
	LEA	48(A4),A0	;point to hdr checksum in hdr
	BSR	EncodeLongword	;store hdr checksum in buffer
	MOVE.L	#512,D0		;number of data bytes
	MOVE.L	A2,A0		;pointer to unencoded user's data
	LEA	64(A4),A1	;point to where data goes in buffer
	BSR	BlitEncode	;encode user's data and move into buffer
	LEA	64(A4),A0	;point to data area of block
	MOVE.W	#1024,D1	;512*2 bytes for checksum
	BSR	CalcCksum	;calculate data checksum
	LEA	56(A4),A0	;this is where data checksum goes
	BSR	EncodeLongword	;store data checksum
	POP	D2/A2/A4
	RTS

* Moves user's data into buffer, then encodes it with clock.
* Length to process in D0, source data ptr in A0, destination ptr in A1.

BlitEncode:
	LINK	A2,#-30		;make room on stack
	MOVE.W	D0,D1		;size of blit
	LSL.W	#2,D1		;number of longwords to process
	ORI.W	#8,D1
	MOVE.W	D1,-10(A2)	;store into blit block
	MOVEM.L	D0/A0-A1,-22(A2)	;store remaining params into blit block
	MOVE.L	#BlitRtn5,-26(A2)	;blit routine
;	MOVE.L	A3,-4(A2)		;port ptr for completion
	BSR	MarkBlitBusy		;blitter busy
	LEA	-30(A2),A1		;ptr to structure
	CALLSYS	QBlit,GraphicsBase	;
	BSR	WaitBlit		;wait for completion
	MOVEM.L	-22(A2),D0/A0-A1
	MOVE.L	D0,D1			;byte number to D1
	MOVE.L	A1,A0			;ptr to beginning of data
	BSR	FixClockBit		;correct border
	ADD.L	D1,A0			;ptr to next seam
	BSR	FixClockBit		
	ADD.L	D1,A0
	BSR	FixClockBit
	UNLK	A2			;fix stack
	RTS

* A0 contains $DFF000, A1 points to Blit structure.

BlitRtn5:
	PUSH	A5
	MOVE.L	A1,A5			;save ptr to blit structure
	BSR	BlitInit		;init blitter
	MOVE.L	A5,A1
	MOVEM.L	8(A1),D0-D1/A5
	MOVE.L	D1,76(A0)		;source to source B
	MOVE.L	D1,80(A0)		;source to source A
	MOVE.L	A5,84(A0)		;dest to dest D
	MOVE.W	#$1DB1,64(A0)		;BLTCON0
	MOVE.W	#0,66(A0)		;BLTCON1
	MOVE.W	20(A1),88(A0)		;start blitter...blit size
	MOVE.L	#BlitRtn6,4(A1)		;ptr to next function
	POP	A5
	RTS

BlitRtn6:
	PUSH	A5
	MOVEM.L	8(A1),D0-D1/A5
	MOVE.L	A5,76(A0)		;source B=dest
	MOVE.L	D1,80(A0)		;source A=source
	MOVE.L	A5,84(A0)		;dest D=dest
	MOVE.W	#$2D8C,64(A0)		;BLTCON0
	MOVE.W	20(A1),88(A0)		;set Blitsize and start
	MOVE.L	#BlitRtn7,4(A1)
	POP	A5
	RTS

BlitRtn7:
	PUSH	A5
	MOVEM.L	8(A1),D0-D1/A5
	ADD.L	D0,D1			;ptr to end source
	SUBQ.L	#2,D1			;-2
	ADD.L	D0,A5			;ptr to end of dest
	ADD.L	D0,A5
	SUBQ.L	#2,A5
	MOVE.L	D1,76(A0)		;source B=source end
	MOVE.L	D1,80(A0)		;source A=source end
	MOVE.L	A5,84(A0)		;dest D=destination-end
	MOVE.W	#$DB1,64(A0)		;BLTCON0
	MOVE.W	#$1002,66(A0)		;BLTCON1
	MOVE.W	20(A1),88(A0)		;blit size, start blit
	MOVE.L	#BlitRtn8,4(A1)
	POP	A5
	RTS

BlitRtn8:
	PUSH	A5
	MOVEM.L	8(A1),D0-D1/A5
	ADD.L	D0,A5		;ptr to end of first part of dest
	MOVE.L	A5,76(A0)	;enter from source B
	MOVE.L	D1,80(A0)	;source A=source
	MOVE.L	A5,84(A0)	;dest D=end of first part of dest
	MOVE.W	#$1D8C,64(A0)	;BLTCON0
	MOVE.W	#0,66(A0)	;BLTCON1
	MOVE.W	20(A1),88(A0)	;blit size, start blit
	MOVE.L	#BlitRtn9,4(A1)
	POP	A5
	RTS

BlitRtn9:
	ZAP	D0
	MOVE.L	D0,4(A1)
;	MOVE.L	26(A1),A1
	BSR	BlitComplete
	ZAP	D0
	RTS

MoveSector:
	RTS

STORE_D0_D1_TIMES:
	DECW	D1
1$:	MOVE.B	D0,(A2)+
	DBF	D1,1$
	RTS

* Build table of sector pointers by scanning raw data in track buffer looking
* for sector headers.

FindHeaders:
	RTS

* Decodes one sector and stores the data in users buffer.

DecodeSector:
	RTS



* Called to verify raw data in the track buffer read from the floppy.
* Checks headers and data for checksum errors, moves data to front of
* buffer (following track gap) and returns the first sector number in D0.
* Data in buffer still has MFM format (with embedded clock) but has been
* shifted to correct for bit misalignment.

DecodeTrack:
	PUSH	D2-D6/A2
	LINK	A4,#-16
;	MOVE.L	A7,A4
	MOVE.L	ReadBuf,A2
	LEA	1664(A2),A2	;skip past permanent track gap data
	MOVE.L	A2,A0
	ADDQ.L	#2,A0
	MOVE.L	#2748,D0
	BSR	ScanForHdr	;search for header pattern
	CMP.L	#-1,A0		;found a header?
	BEQ	CantFindSecHdr	;no
	MOVE.L	A0,D5		;else save ptr in D5
	MOVE.L	D0,D2		;number of bits to be shifted to D2
	ADDQ.L	#8,A0		;skip past sync
	MOVEQ	#9,D4		;counter for checksum
	ZAP	D6		;checksum accumulator
	IFNZL	D2,1$		;need to shift header
	MOVE.L	(A0),-8(A4)	;no shift needed...store header bytes
	MOVE.L	4(A0),-4(A4)	;ditto
	MOVE.L	#$55555555,D1	;clock bit filter
2$:	MOVE.L	(A0)+,D0	;get longword
	AND.L	D1,D0		;filter clock bits
	EOR.L	D0,D6		;form hdr checksum
	DBF	D4,2$		;loop for 40 bytes
	MOVE.L	(A0)+,-16(A4)	;store header checksum
	MOVE.L	(A0),-12(A4)	;store data checksum
	BRA.S	3$

1$:	BSR	LoadShiftMFM	;shift header as necessary
	MOVE.L	D0,-8(A4)	;store corrected header bytes
	BSR	LoadShiftMFM	;shift header as necessary
	MOVE.L	D0,-4(A4)	;store corrected header bytes
	MOVE.L	D5,A0		;sync address to A0
	ADDQ.L	#8,A0		;point to header
4$:	BSR	LoadShiftMFM
	ANDI.L	#$55555555,D0	;get rid of clock
	EOR.L	D0,D6		;form hdr checksum
	DBF	D4,4$		;loop for 40 bytes
	BSR	LoadShiftMFM	;load and shift hdr checksum
	MOVE.L	D0,-16(A4)	;store
	BSR	LoadShiftMFM	;load and shift data checksum
	MOVE.L	D0,-12(A4)	;store

* When we get here we have manually decoded the first header we found in
* the buffer.

3$:	LEA	-16(A4),A0	;load MFM hdr checksum from header
	BSR	DecodeLongWord
	CMP.L	D0,D6		;same as we calculated?
	BNE	CantReadSecHdr	;nope...header cksum error
	LEA	-8(A4),A0	;else load 4 info bytes
	BSR	DecodeLongWord
	MOVE.L	D0,D3		;save
	MOVE.L	D3,-(A7)
	CMPI.B	#-1,0(A7)	;AmigaDOS format code $FF?
	BNE	CantReadSecHdr	;no...ADOS format byte missing
	MOVE.B	1(A7),D0	;get track number
	CMP.B	NewTrack,D0	;is this the one we expected?
	BNE	CantReadSecHdr	;not the right track
	MOVE.L	(A7)+,D3
	ZAP	D0
	MOVE.B	D3,D0		;number of blocks to gap
	MULU	#1088,D0	;bytes per block, including hdr
	MOVE.L	D5,A0		;set A0 to sync
	MOVE.L	A2,A1		;saved ptr to beginning of data
	MOVE.L	D2,D1		;number of bits to shift
	MOVE.L	D0,D4		;distance to gap...length of blit
	BSR	BlitMove	;move blks up to gap to top of buffer & shift
	ZAP	D2
	MOVE.B	D3,D2		;number of blocks to gap
	SUBI.L	#11,D2		;calc number after gap
	NEG.L	D2
	BEQ.S	5$		;none...got 'em all
	ADD.L	D4,D5		;determine address of gap
	MOVE.L	#1660,D0	;max number of bytes to search
	MOVE.L	D5,A0		;address of gap
	ADDQ.L	#2,A0
	BSR	ScanForHdr	;search gap for sector hdr pattern
	CMP.L	#-1,A0		;find another header?
	BEQ	TooFewSec	;no...header not found after gap
	MOVE.L	D0,D1		;number of bits to be shifted
	MOVE.L	A2,A1		;data buffer to A1
	ADD.L	D4,A1		;point to end of first blit
	MOVE.L	D2,D0		;number of blocks after gap
	MULU	#1088,D0	;calculate length of blit
	BSR	BlitMove	;move blks after gap to end of other blocks
5$:	MOVE.L	A2,A0		;buffer address to A0
	ADD.L	D4,A0		;newly copied data starts here
	BSR	FixClockBit	;correct possible clock bit error caused by move
	LEA	11968(A2),A0	;pointer to end of data
	MOVE.W	#$AAA8,D0	;value for end marking
	BTST	#0,-1(A0)	;test last data bit
	BEQ.S	6$		;no fix needed
	BCLR	#15,D0		;else correct first bit of end marking
6$:	MOVE.W	D0,(A0)		;store end mark
	MOVE.W	#$AAAA,(A2)	;store beginning sync mark

* If we get here, the blocks have been moved to the front of the
* data buffer (following the permanent track gap area), the gap has been 
* moved to the end, and the data has been bit-shifted, as necessary.
* The blocks are ready for decoding.  Now we check for 11 valid blocks, 
* checking hdr and data checksums.

	ZAP	D4		;used to count bytes of data checked
	MOVEQ	#11,D2		;this many sectors per track...loop count
	MOVE.W	D3,D5		;first hdr info bytes to D5
	LSR.W	#8,D5		;first sector number to low byte

SectorLoop:
	CMPI.L	#$2AAAAAAA,0(A2,D4.W)	;look for proper sector sync pattern
	BEQ.S	7$			;found it
	CMPI.L	#$AAAAAAAA,0(A2,D4.W)	;alternate pattern
	BNE	BadSecPreamble		;oops...garbage
7$:	CMPI.L	#$44894489,4(A2,D4.W)	;rest of pattern
	BNE	BadSecPreamble		;cant find sync pattern
	LEA	8(A2,D4.W),A0	;sync ok...point to data area in header
	MOVEQ	#40,D1		;40 bytes in hdr
	BSR	CalcCksum	;calc header checksum
	MOVE.L	D0,D6		;save it
	LEA	$30(A2,D4.W),A0	;point to hdr checksum (MFM)
	BSR	DecodeLongWord	;decode hdr checksum from MFM
	CMP.L	D6,D0		;checksum match?
	BNE	BadHdrCksum	;no
	LEA	8(A2,D4.W),A0	;else point to hdr again
	BSR	DecodeLongWord	;decode four-byte sector info
	MOVE.L	D0,-(A7)
	CMP.B	#-1,0(A7)	;AmigaDOS format $FF
	BNE	BadSecID	;bad format code
	MOVE.B	1(A7),D1	;get track number
	CMP.B	NewTrack,D1	;is this right track?
	BNE.S	BadSecID	;oops...bad track number from header
	MOVE.B	2(A7),D1	;get sector number
	CMP.B	D5,D1		;is this correct sector? (must be in sequence)
	BNE.S	BadSecID	;nope...sector numbers don't match
	MOVE.B	D2,3(A7)	;insert number of sectors to gap in hdr (gap at end)
	MOVE.L	(A7)+,D0
	LEA	8(A2,D4.W),A0	;point to hdr again
	BSR	EncodeLongword	;encode corrected hdr info and store into hdr
	LEA	8(A2,D4.W),A0	;point to hdr again
	MOVEQ	#40,D1
	BSR	CalcCksum	;calc new checksum for hdr with changes
	LEA	$30(A2,D4.W),A0	;point to checksum in hdr
	BSR	EncodeLongword	;encode new checksum and store into buffer
	LEA	$40(A2,D4.W),A0	;ptr to beginning of data block
	MOVE.W	#1024,D1	;calc block checksum
	BSR	CalcCksum
	MOVE.L	D0,D6		;save it
	LEA	$38(A2,D4.W),A0	;point to data checksum in hdr
	BSR	DecodeLongWord	;decode it
	CMP.L	D6,D0		;data checksum ok?
	BNE	BadSecCksum	;no...data error in sector
	SUBQ.L	#1,D2		;else found another good sector
	ADDQ.B	#1,D5		;bump sector counter
	CMPI.B	#11,D5		;was that the last sector of track?
	BLT.S	8$		;no...D5 still ok
	ZAP	D5		;else reset to sector 0
8$:	ADDI.W	#1088,D4	;bump past current sector data
	CMPI.W	#11968,D4	;end of track data?
	BNE	SectorLoop	;no...loop for next sector

* If we get here, all 11 blocks of the track have passed the checks.

	MOVE.L	D3,D1		;info field of first hdr in buffer
	LSR.L	#8,D1		;get sector number to low byte
	ZAP	D0
	MOVE.B	D1,D0		;number of first sector in buffer to D0
ErExit:	UNLK	A4		;reset stack and restore A4
	POP	D2-D6/A2
	RTS

CantFindSecHdr:
	BRA.S	ErCom
CantReadSecHdr:
	BRA.S	ErCom
TooFewSec:
	BRA.S	ErCom
BadSecPreamble:
	BRA.S	ErCom
BadHdrCksum:
	BRA.S	ErCom
BadSecID:
	BRA.S	ErCom
BadSecCksum:
	NOP
ErCom:	NOP
	STC
	BRA.S	ErExit

* Searches for sector header pattern, and determines amount of bit
* shift which must be applied to data.
* Buffer ptr in A0, count of words to scan in D0.
* Returns A0 pointing to start of sync pattern and D0 contains
* required bit shift to be applied.  A0=-1 on no match.

ScanForHdr:
	PUSH	D2-D4/A2
	MOVE.W	#$AAAA,D3	;sync pattern
	MOVE.W	#$5555,D4	;shifted sync pattern
	MOVE.L	A0,A2		;save ptr to end of buffer
	ADD.L	D0,A2		;end of buffer
1$:	MOVE.W	(A0)+,D2	;check a word
	CMP.W	D3,D2		;one sync code?
	BEQ.S	7$		;yes
	CMP.W	D4,D2		;else shifted sync code?
	BEQ.S	3$		;yes
	CMP.L	A0,A2		;else end of buffer?
	BHI.S	1$		;no...loop
2$:	MOVEQ	#-1,D0		;else set A0=-1
	MOVE.L	D0,A0		;-1 to A0
	BRA.S	6$		;return

3$:	MOVEQ	#15,D0		;16 entries in table
	LEA	Table1,A1
4$:	CMP.L	A0,A2
	BLS.S	2$		;oops...end of data
	MOVE.W	(A0)+,D1	;scan past sync codes
	CMP.W	D2,D1
	BEQ.S	4$
	SUBQ.L	#2,A0		;else back up A0
	MOVE.L	(A0),D1		
8$:	CMP.L	(A1)+,D1	;compare with table entry
	BEQ.S	5$		;found match
	SUBQ.L	#2,D0		;no...done?
	BGE.S	8$		;no...loop
	BRA.S	1$		;yes...go on searching
5$:	SUBQ.L	#4,A0		;else adjust A0
6$:	POP	D2-D4/A2
	RTS

7$:	MOVEQ	#14,D0		;15 entries in this table
	LEA	Table2,A1
	BRA.S	4$


* Sync pattern shift tables.  Entries are sequential pairs of words which 
* are the possible data patterns which can occur when the sync data is 
* shifted.  The depth of the match indicates the degree of shifting.
* Shift table 1 applies to $5555 sync pattern.
* Shift table 2 applies to $AAAA sync pattern.

Table1:	DC.W	$2244,$A244,$4891,$2891,$5224,$4A24,$5489,$1289
	DC.W	$5522,$44A2,$5548,$9128,$5552,$244A,$5554,$8912

Table2:	DC.W	$9122,$5122,$A448,$9448,$A912,$2512,$AA44,$8944
	DC.W	$AA91,$2251,$AAA4,$4894,$AAA9,$1225,$4489,$4489

* Loads MFM data at A0 and corrects shift by count in D2.
* Result returned in D0.

LoadShiftMFM:
	MOVE.L	(A0)+,D0	;load raw MFM longword
	MOVE.W	(A0),D1		;also following 16 bits (may be needed)
	MOVEQ	#16,D3		;max of 16 bits to shift
	SUB.L	D2,D3		;shift count in D2
	LSL.L	D3,D0		;do the necessary shifting
	LSR.W	D2,D1
	OR.W	D1,D0		;combine results
	RTS

* Move data blocks and shift data.  Params in D0, D1, A0, and A1.
* Dest address in A0, source in A1, byte count in D0, shift count in D1.

BlitMove:
	LINK	A2,#-30
	MOVE.B	D1,-8(A2)		;save shift count
	TST.L	D1
	BEQ.S	1$			;no shift required
	ADDQ.L	#2,D0			;else adjust move by 2 bytes
1$:	MOVE.L	D0,D1			;byte count
	ADDI.L	#$3F,D1
	ANDI.W	#$FFC0,D1
	ORI.W	#$20,D1
	MOVE.W	D1,-10(A2)
	MOVEM.L	D0/A0-A1,-22(A2)
	MOVE.L	#BlitRtn1,-26(A2)
	BSR	MarkBlitBusy
	LEA	-30(A2),A1
	CALLSYS	QBlit,GraphicsBase	;queue blitter request
	BSR	WaitBlit		;wait till blitter finishes
	UNLK	A2
	RTS

* Called by blitter queue controller with ptr to param block (blit node) in A1 
* and ptr to hardware regs in A0 ($DFF000).

BlitRtn1:
	PUSH	A5
	MOVE.L	A1,A5			;A1 clobbered by BlitInit
	BSR	BlitInit
	MOVE.B	22(A5),D0
	MOVEQ	#12,D1
	LSL.W	D1,D0
	MOVE.W	#$5CC,$40(A0)		;blitter control reg 0
	MOVE.W	D0,$42(A0)		;blitter control reg 1
	MOVEM.L	8(A5),D0-D1/A1
	MOVE.L	D1,$4C(A0)		;load source B blitter ptr (18 bits)
	MOVE.L	#BlitRtn4,4(A5)
	TST.B	22(A5)
	BEQ.S	1$
	SUBQ.L	#2,A1
	MOVE.L	#BlitRtn3,4(A5)
1$:	MOVE.L	A1,$54(A0)		;load dest blitter ptr (18 bits)
	MOVE.W	(A1),24(A5)
	MOVE.W	20(A5),$58(A0)		;blitter start and size
	POP	A5
	RTS

* Blitter cleanup routines

BlitRtn3:
	MOVE.L	16(A1),A0
	MOVE.W	24(A1),-2(A0)
BlitRtn4:
	ZAP	D0
	MOVE.L	D0,4(A1)
	BSR	BlitComplete		;blitter finished
	ZAP	D0			;signal blitter controller all done
	RTS

BlitInit:
	ZAP	D0
	LEA	$44(A0),A1		;point to BLTAFWM
	MOVE.L	#-1,(A1)		;store -1 in source A 1st word mask
	LEA	$62(A0),A1		;point to B blitter modulo reg
	MOVE.L	D0,(A1)+		;zap modulo regs for B and A
	MOVE.W	D0,(A1)+		;ditto for D
	ADDQ.L	#8,A1
	MOVE.W	#$5555,(A1)		;store $5555 into source C data reg
	RTS

MarkBlitBusy:
	SETF	BlitBusy
	RTS

BlitComplete:
	CLR.B	BlitBusy
	RTS

WaitBlit:
	IFNZB	BlitBusy,WaitBlit
	RTS

* Corrects first clock bit on current byte at A0.

FixClockBit:
	MOVE.B	(A0),D0		;get current byte
	BTST	#0,-1(A0)	;last bit on prev byte set?
	BNE.S	1$		;yes...reset clock bit
	BTST	#6,D0		;was next data bit set?
	BNE.S	3$		;yes...ok
	BSET	#7,D0		;else set clock bit
	BRA.S	2$
1$:	BCLR	#7,D0		;clear clock bit
2$:	MOVE.B	D0,(A0)
3$:	RTS

* Encodes longword in D0 to 2 MFM longwords and stores at A0.

EncodeLongword:
	PUSH	D2-D3
	MOVE.L	D0,D3		;longword to D3
	LSR.L	#1,D0
	BSR	AddClockStore	;encode odd bits with clock and store
	MOVE.L	D3,D0		;restore original longword
	BSR	AddClockStore	;encode even bits with clock and store
	BSR	FixClockBit	;correct first clock bit based on previous
	POP	D2-D3
	RTS

* Encode longword in D0 with clock to form MFM and store at A0.

AddClockStore:
	ANDI.L	#$55555555,D0	;filter off odd bits
	MOVE.L	D0,D2		;save
	EORI.L	#$55555555,D2	;determine clock bits
	MOVE.L	D2,D1		;result to D1
	LSL.L	#1,D2		
	LSR.L	#1,D1
	BSET	#31,D1
	AND.L	D2,D1
	OR.L	D1,D0		;set clock bits
	BTST	#0,-1(A0)	;did previous end with null bit?
	BEQ.S	1$		;yes...bits are ok
	BCLR	#31,D0		;else reset clock bit
1$:	MOVE.L	D0,(A0)+	;store MFM encoded data
	RTS

* Calculates checksum for block of data pointed to by A0, for byte count in D1.
* Returns checksum in D0.

CalcCksum:
	PUSH	D2
	LSR.W	#2,D1		;operate on longwords, not bytes
	SUBQ.W	#1,D1		;for dbf
	ZAP	D0		;zap cksum accumulator
1$:	MOVE.L	(A0)+,D2	;get a longword
	EOR.L	D2,D0		;xor with accumulated cksum
	DBF	D1,1$		;loop
	ANDI.L	#$55555555,D0	;remove invalid bits
	POP	D2
	RTS

* Decodes 2 MFM longwords at A0 into a single longword in D0.

DecodeLongWord:
	MOVE.L	(A0)+,D0
	MOVE.L	(A0)+,D1
	ANDI.L	#$55555555,D0
	ANDI.L	#$55555555,D1
	LSL.L	#1,D0
	OR.L	D1,D0
	RTS

* SEARCHES THE TRACK BUFFER LOOKING FOR ENCODED SECTOR ID DATA.  THEN PUTS
* SECTOR ID AND OFFSET TO DATA INTO SECTOR ENTRY IN SECTOR_TABLE.
* CAN BE CALLED UP TO 9 TIMES PER TRACK.
* A3 POINTS TO CURRENT ENTRY IN SECTOR TABLE.

FIND_SECTOR:
	RTS

BLITTER_ENCODE:
	RTS

* SETS AMIGA-DOS DISK DRIVES BUSY FOR DURATION OF DISK OPERATION.

BusyDrives:
	CLR.B	HdwBusyFlg
	PUSH	A0-A1
1$:	MOVE.L	DR_BASE,A6	;ASK AMIGA-DOS POLITELY...
	LEA	DISK_BLOCK,A1
	MOVE.L	D2D_TASK,MP_TASK
	CALL	DR_GetUnit(A6)	;...FOR THE DISK CONTROLLER
	TST.L	D0
	BNE	2$		;got control of disk controller
	LEA	MSG_PORT,A0
	CALLSYS	WaitPort,SysBase ;WILL SEND REPLY TO DRU PORT
	LEA	MSG_PORT,A0
	CALLSYS	GetMsg		;UNQUEUE REPLY
	BRA.S	1$		;NOW TRY FOR IT AGAIN
2$:	SETF	HdwBusyFlg	;show we own disk control hardware now
	POP	A0-A1
	RTS

* FREES AMIGA-DOS DISK DRIVES AFTER DISK OPERATION.

FreeDrives:
	NOERROR	2$
	BSR.S	2$
	STC
	RTS
2$:	IFZB	HdwBusyFlg,1$
	MOVE.L	DR_BASE,A6
	JSR	DR_GiveUnit(A6)
	CLR.B	HdwBusyFlg	;hardware is free now
1$:	RTS



DISK_INIT:
	MOVE.L	#TrkBufSize,D0		;GRAB A BUNCH
	MOVEQ	#2,D1			;SPECIFY CHIP MEMORY
	CALLSYS	AllocMem,SysBase	;GRAB A HUNK OF CHIP MEMORY
	TST.L	D0			;GOT ANY?
	BEQ	9$			;NO...GIVE UP
	MOVE.L	D0,ReadBuf		;POINTER TO TRACK BUFFER
	MOVE.L	#TrkBufSize,D0		;GRAB A BUNCH
	MOVEQ	#2,D1			;SPECIFY CHIP MEMORY
	CALLSYS	AllocMem,SysBase	;GRAB A HUNK OF CHIP MEMORY
	TST.L	D0			;GOT ANY?
	BEQ	9$			;NO...GIVE UP
	MOVE.L	D0,WriteBuf		;POINTER TO TRACK BUFFER
	LEA	DiskResource,A1		;SET UP POINTER TO DISK RESOURCE
	CALLSYS	OpenResource
	MOVE.L	D0,DR_BASE		;POINTER TO DISK RESOURCE BLOCK
	BEQ	9$			;DIDN'T FIND IT
	MOVE.L	#0,A1
	CALLSYS	FindTask		;GET D2D TASK POINTER
	MOVE.L	D0,D2D_TASK		;SAVE FOR SEIZING DISK
	BEQ	9$			;OOPS...PROBLEM
	LEA	TIMER.,A0
	ZAP	D0			;USEC
	LEA	TIMER_BLOCK,A1
	ZAP	D1
	CALLSYS	OpenDevice		;OPEN THE TIMER
	BNE.S	9$			;CANT GET TIMER
	CLC
	RTS
9$:	STC
	RTS

DISK_EXIT:
	LEA	TIMER_BLOCK,A1		;FREE THE TIMER
	CALLSYS	CloseDevice,SysBase
	MOVE.L	ReadBuf,D0
	BEQ.S	1$
	MOVE.L	D0,A1			;BASE OF ALLOCATED MEMORY
	MOVE.L	#TrkBufSize,D0
	CALLSYS	FreeMem			;RETURN TO POOL
1$:	MOVE.L	WriteBuf,D0
	BEQ.S	2$
	MOVE.L	D0,A1			;BASE OF ALLOCATED MEMORY
	MOVE.L	#TrkBufSize,D0
	CALLSYS	FreeMem			;RETURN TO POOL
2$:	RTS

MOTOR_OFF:
MotorOff:
	IFZB	MotorFlg,MEND	;MOTOR OFF?
	BSR	BusyDrives	;WAIT TILL DRIVES NOT BUSY
MOFF:
	MOVE.B	#$FF,CIAB
	MOVE.B	#NONE,CIAB
	MOVE.B	#DrvEnable,CIAB
	MOVE.B	#CA0!CA1,CIAB
	MOVE.B	#CA1,CIAB
	MOVE.B	#CA1!CA2,CIAB
	MOVE.B	#CA1!CA2!LSTRB,CIAB	;OFF
	NOP
	NOP
	MOVE.B	#CA1!CA2,CIAB
	MOVE.B	#$FF,CIAB
	CLR.B	MotorFlg	;MOTOR OFF NOW
	BSR	FreeDrives
MEND:	RTS


MOTOR_ON:
MotorOn:
	BSR	MON		;TURN MOTOR ON, CHECK FOR DRIVE READY
	RTS

* Turns MAC drive motor on using Apple procedures.

MON:	IFNZB	MotorFlg,9$	;motor already on
;	BSR	BusyDrives	;else turn it on
;	MOVE.B	#$FF,CIAB
	MOVE.B	#NONE,CIAB
	MOVE.B	#DrvEnable,CIAB
	MOVE.B	#CA0!CA1,CIAB
	MOVE.B	#CA1,CIAB
	MOVE.B	#CA1!LSTRB,CIAB
	NOP
	NOP
	MOVE.B	#CA1,CIAB
;	MOVE.B	#SEL,CIAB	;is there a diskette loaded?
;	MOVE.B	CIAA,D0
;	AND.W	#$20,D0
;	BEQ.S	9$		;yes
;	STC			;no...drive not ready
9$:	RTS

Eject:
	MOVE.B	#DrvEnable,CIAB
	MOVE.B	#CA0!CA1,CIAB
	MOVE.B	#CA0!CA1!CA2,CIAB
	MOVE.B	#CA0!CA1!CA2!LSTRB,CIAB
	NOP
	NOP
	MOVE.B	#CA0!CA1,CIAB
	RTS

	XREF	DISP..
DISP_ERR:
	JMP	DISP..


* Binary to 6 + 2 GCR conversion table 

BinToGcr:

* GCR to binary conversion table.  ($96 OFFSET)

GcrToBin:

* TRACK PARAMETER TABLE
* IN ORDER: SECTORS/TRACK, WORDS/TRACK, OnDuty, OffDuty
* words=((sectors+1)*724)/2

TPAR_LEN EQU	8	;LENGTH OF TABLE ENTRY

TPARAM_TBL
	DC.W	11,7358,300,02 	;0-15, slowest track, most data
	DC.W	11,7358,300,02	;16-31
	DC.W	11,7358,300,02	;32-47
	DC.W	11,7358,300,02	;48-63
	DC.W	11,7358,300,02	;64-79, fastest track, least data


MACTRK	DC.W	0,191,367,527,671,799
MACSEC	DC.W	12,11,10,9,8

IMAGE_TBL


DrvNotRdy. 	DC.B	20,'Mac drive not ready.',0
ReadErr. 	DC.B	21,'Mac drive read error.',0
WriteErr.	DC.B	22,'Mac drive write error.',0
WrtProt.	DC.B	25,'Mac disk write protected.',0
SecRng.		DC.B	17,'Sector too large.'
DiskResource	DC.B	'disk.resource',0
TIMER.		DC.B	'timer.device',0


SectorTable	DCB.L	MaxSectors*2,0

D2D_TASK	DC.L	0	;TASK POINTER
DR_BASE		DC.L	0	;DISK RESOURCE POINTER
DataBuffer	DC.L	0	;caller's sector buffer
SectorBuf	DC.L	0	;ptr to actual sector data
ReadBuf		DC.L	0	;contains raw track data as read from disk
WriteBuf	DC.L	0	;contains raw track data to be written to disk
ReadLength	DC.W	0	;WORD count for DMA read of current track
WriteLength	DC.W	0	;word count for DMA write of WriteBuf
DelayCount	DC.W	0	;Slowdown loop count
SEC_PER_CYL
SEC_PER_TRACK
SecsPerTrack	DC.W	0	;SECTORS PER TRACK
OffDuty		DC.W	0	;ACTUAL OnDuty COUNT
OnDuty		DC.W	0	;ACTUAL OffDuty COUNT

CKSUM		DC.B	0	;CHECKSUM ACCUMULATOR
SaveD0		DC.B	0	;SAVED DRIVE SELECT, SIDE, DIRECTION
MotorFlg	DC.B	0	;1=MOTOR ON, 0=OFF
DRIVE_SEL	DC.B	0	;C/C DRIVE, CODED FOR AMIGA
CurTrack	DC.B	0	;CURRENT TRACK
CurSide		DC.B	0	;CURRENT SIDE (4=SIDE 0, 0=SIDE 1)
CurSector	DC.B	0	;CURRENT SECTOR
NEW_TRACK
NewTrack	DC.B	0	;REQUESTED TRACK
NEW_SIDE
NewSide		DC.B	0	;REQUESTED SIDE
NewSector	DC.B	0	;REQUESTED SECTOR
RetryCount	DC.B	0	;READ RETRY COUNTER
SlowMode	DC.B	0	;initial slowing period
DIR		DC.B	0	;stepping direction
InvalidFlg	DC.B	0	;1=data in track buffer is invalid
DirtyFlg	DC.B	0	;1=track data must be written to disk
HdwBusyFlg	DC.B	0	;1=we own disk control hardware, 0=we don't
FirstSector	DC.B	0	;not needed?
BlitBusy	DC.B	0	;1=waiting for blitter, 0=not

* DISK RESOURCE UNIT STRUCTURE

INT_STRUCT MACRO
	NODE 2,0,0
	DC.L	0
	DC.L	0
	ENDM

	CNOP	0,4

DISK_BLOCK
	NODE	5,0,0
DB_PORT DC.L	MSG_PORT
	DC.W	DB_MLEN
	INT_STRUCT
	INT_STRUCT
	INT_STRUCT
DB_MLEN EQU *-DISK_BLOCK

TIMER_BLOCK
	NODE	5,0,0
TB_PORT	DC.L	MSG_PORT
	DC.W	TB_MLEN
	DC.L	0,0		;DEV, UNIT
TB_CMD	DC.W	0,0		;COMMAND, FLAGS, ERROR
TB_SECS	DC.L	0		;SECONDS
TB_USEC	DC.L	0		;MICROSECONDS
	DC.L	0,0,0,0		;STANDARD IO REQ EXT
TB_MLEN	EQU *-TIMER_BLOCK

MSG_PORT:
	NODE	4,0,0
	DC.B	0		;FLAGS=SIGNAL
	DC.B	8		;SIGNAL 8
MP_TASK DC.L	0		;MY TASK
MP_HEAD DC.L	MP_TAIL 	;HEAD
MP_TAIL DC.L	0		;TAIL
	DC.L	MP_HEAD 	;TAIL PRED
	DC.B	5		;TYPE
	DC.B	0		;PAD

HdrBuf	DCB.B	16,0		;SECTOR HEADER
TagBuf	DCB.B	16,0		;SECTOR TAG BUFFER

	END


