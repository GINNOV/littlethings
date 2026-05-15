*********************************************************
*							*
*		MacFloppy.device			*
*							*
*	mfmac.asm - routines to handle Mac disks	*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*							*
*********************************************************

	INCLUDE "vd0:MACROS.ASM"
	INCLUDE "mf.i"

	XDEF	MReadCmd,MWriteCmd
	XDEF	MVerifyTrack
	XDEF	AlignSectors

* Transfer and decodes data from track buffer into user's buffer.

MReadCmd:
	ZAP	D0
	MOVE.W	NewSec(A3),D0		;read data from this sector
	MOVE.L	UserBuffer(A3),A0	;and store it here
	BSR	DecodeGCRData		;decode and store data
	RTS

* Transfer and encodes data from user's buffer into track buffer.

MWriteCmd:
	ZAP	D0
	MOVE.W	NewSec(A3),D0		;write data into this sector
	MOVE.L	UserBuffer(A3),A0	;from this user buffer
	BSR	EncodeGCRData		;move and encode data
	RTS

* Checks all sectors on track.
* Note: since Mac sectors are rewritten by sector (not track) on a Mac, the
* gaps cannot be predicted, and will vary.

MVerifyTrack:
	PUSH	D2
	BSR.S	FindHeaders		;build table of sector ptrs
	ERROR	8$			;garbage or hdr checksum error
	ZAP	D2			;perform CRC check on sector data
1$:	MOVE.L	D2,D0			;sector number to D0
	MOVE.L	ReadBuffer(A3),A0
	LEA	TrackGap(A0),A0		;save converted data here
	BSR	DecodeGCRData		;check CRC to verify sector data
	ERROR	8$			;oops...sector error
	INCW	D2
	IFLTB	D2,SecsPerTrk(A3),1$	;loop for all sectors on this track
	ZAP	D0
8$:	POP	D2			;error number in D0
	RTS

* Builds table of sector pointers by scanning raw data in track buffer looking
* for sector headers, and performs checksum checks on headers.
* Returns CY=1 if can't find all sectors or header checksum error.
* Register usage: 
*	D0=track buffer loop counter
*	D1=temp data
*	D2=local side/overflow byte
*	D3=local track number (Mac format)
*	D4=sector loop counter
*	D5=format byte from data
*	D6=hdr checksum accumulator
*	D7=sector number from data

FindHeaders:
	PUSH	D2-D7/A2-A5
	MOVEQ	#MaxSectors-1,D0	;clear out existing sector table
	ZAP	D1
	ZAP	D2			;for side/overflow checks
	ZAP	D3			;for track checks
	ZAP	D4			;sector loop counter
	LEA	SectorTable,A0
	MOVE.L	A0,A4
11$:	MOVE.L	D1,(A0)+		;ZAP an entry
	MOVE.L	D1,(A0)+
	DBF	D0,11$
	MOVE.L	ReadBuffer(A3),A0	;scan from start of track buffer
	LEA	MacReadGap(A0),A0	;skip to read area of buffer
	MOVE.L	A0,A5			;limit check
	ADD.L	ReadLength(A3),A5	;ptr to end of buffer
	LEA	GcrToBin-$96,A2
	MOVE.B	SecsPerTrk(A3),D4	;scan for this many secs
	MOVE.W	NewTrk(A3),D3
	LSR.W	#1,D3			;convert to range 0-79, side bit->CY
	BCC.S	4$			;side 0
	BSET	#5,D2			;else should be side 1
4$:	CMP.B	#64,D3			;in range?
	BCS.S	1$			;yes
	SUB.B	#64,D3			;else adjust for range 64-79
	BSET	#0,D2			;and set overflow bit
1$:	MOVE.L	A5,D0			;how many bytes left to check?
	SUB.L	A0,D0
	BMI	8$			;thats it...past end of buffer
2$:	CMP.B	#$D5,(A0)+		;check for header codes
	DBEQ	D0,2$			;FAST loop scanning for $D5
	BNE	8$			;NE = loop limit hit...no $D5 found
	MOVEA.L	A0,A1			;save pointer to possible header
	CMP.B	#$AA,(A0)+
	BNE.S	1$
	CMP.B	#$96,(A0)+
	BNE.S	1$
	MOVE.B	(A0)+,D1		;get track number
	MOVE.B	0(A2,D1.W),D1
	MOVE.B	D1,D6			;start hdr checksum calc
	CMP.B	D3,D1			;desired track?
	BNE.S	1$			;no...problems
	MOVE.B	(A0)+,D1		;get sector number
	MOVE.B	0(A2,D1.W),D1		;convert to binary
	CMP.B	SecsPerTrk(A3),D1
	BGE.S	1$			;sec nbr too large for this track
	MOVE.W	D1,D7			;save sector number
	EOR.B	D1,D6			;add to checksum
	MOVE.B	(A0)+,D1		;get overflow/side flag
	MOVE.B	0(A2,D1.W),D1
	EOR.B	D1,D6
	EOR.B	D2,D1			;same side/overflow?
	BNE	1$			;no...big problems
	MOVE.B	(A0)+,D1		;get format byte
	MOVE.B	0(A2,D1.W),D1
	MOVE.B	D1,D5			;save format byte for later check
	EOR.B	D1,D6
	MOVE.B	(A0)+,D1		;get hdr checksum
	MOVE.B	0(A2,D1.W),D1
	EOR.B	D1,D6			;should be 0
	BNE	1$			;checksum invalid...ignore this hdr

* Good hdr checksum...add this one to sector table.

	MOVE.B	#1,DiskType(A3)		;show this is Mac diskette
	CMP.B	#$22,D5			;double-sided?
	BNE.S	5$			;no
	MOVE.B	#2,DiskType(A3)		;yes...mark it so
5$:	LSL.W	#3,D7			;mult sec by 8 for table index
	DECL	A1
	MOVE.L	A1,0(A4,D7.W)		;save ptr to $D5 byte of header
	MOVEQ	#20,D0			;sector had better be right close
3$:	CMP.B	#$D5,(A0)+		;now find start of sector data
	DBEQ	D0,3$			;FAST scan for $D5
	BNE	1$			;NE means loop limit...problems
	CMP.B	#$AA,(A0)+
	BNE.S	3$
	CMP.B	#$AD,(A0)+
	BNE.S	3$
	MOVE.L	A0,4(A4,D7.W)		;store ptr to sector data into sec tbl
	DECW	D4
	BNE	1$			;loop for next sector
	BRA.S	9$			;found all sectors
8$:	MOVEQ	#TDERR_BadHdrSum,D0
	STC				;didn't find enough good sector hdrs
9$:	POP	D2-D7/A2-A5
	RTS


* Decodes GCR sector data and verifies sector checksum.  
* On exit, CY=1 on checksum error, CY=0 for good data.
* D0=desired sector to check (range 0-11, depending on track).
* A0=databuffer (for CRC check, moves data into write area of track buffer).
* Tag data goes into Tagbuffer (one per sector).

DecodeGCRData:
	PUSH	D2-D7/A2-A4
	LEA	SectorTable,A4
;	ZAP	D0
;	MOVE.W	NewSec(A3),D0
	LSL.W	#3,D0			;index sector table by long
	MOVE.L	4(A4,D0.W),D1		;get pointer to sector data
	BEQ	8$			;no entry...header missing
	MOVE.L	D1,A4
	LSL.W	#1,D0			;index for TagBuf table
	LEA	TagBuf,A1
	ADD.W	D0,A1			;point to proper tab buffer entry
	LEA	GcrToBin-$96,A2
	ZAP	D3
	ZAP	D5
	ZAP	D6
	ZAP	D7
	MOVE.L	#$C0,D0			;BIT MASK
	MOVE.L	#$1FE000A,D4		;BYTE COUNTS
;	LEA	TagBuf,A1
	MOVE.B	(A4)+,D3
	MOVE.B	0(A2,D3.W),(A1)+	;SECTOR NUMBER
1$:	MOVE.B	(A4)+,D3
	MOVE.B	0(A2,D3.W),D1
	ROL.B	#2,D1
	MOVE.B	D1,D2
	AND.B	D0,D2
	MOVE.B	(A4)+,D3
	OR.B	0(A2,D3.W),D2
	MOVE.B	D7,D3
	ADD.B	D7,D3
	ROL.B	#1,D7
	EOR.B	D7,D2
	MOVE.B	D2,(A1)+		;store tag byte
	ADDX.B	D2,D5
	ROL.B	#2,D1
	MOVE.B	D1,D2
	AND.B	D0,D2
	MOVE.B	(A4)+,D3
	OR.B	0(A2,D3.W),D2
	EOR.B	D5,D2
	MOVE.B	D2,(A1)+		;store tag byte
	ADDX.B	D2,D6
	ROL.B	#2,D1
	AND.B	D0,D1
	MOVE.B	(A4)+,D3
	OR.B	0(A2,D3.W),D1
	EOR.B	D6,D1
	MOVE.B	D1,(A1)+		;store tag byte
	ADDX.B	D1,D7
	SUBQ.W	#3,D4			;LOOP COUNT
	BPL	1$
	SWAP	D4			;SO USE OTHER COUNT
2$:	MOVE.B	(A4)+,D3
	MOVE.B	0(A2,D3.W),D1
	ROL.B	#2,D1
	MOVE.B	D1,D2
	AND.B	D0,D2
	MOVE.B	(A4)+,D3
	OR.B	0(A2,D3.W),D2
	MOVE.B	D7,D3
	ADD.B	D7,D3
	ROL.B	#1,D7
	EOR.B	D7,D2
	MOVE.B	D2,(A0)+		;STORE A DATA BYTE
	ADDX.B	D2,D5
	ROL.B	#2,D1
	MOVE.B	D1,D2
	AND.B	D0,D2
	MOVE.B	(A4)+,D3
	OR.B	0(A2,D3.W),D2
	EOR.B	D5,D2
	MOVE.B	D2,(A0)+		;STORE DATA BYTE
	ADDX.B	D2,D6
	TST.W	D4			;DONE?
	BEQ.S	3$			;YES...CHECK CRC
	ROL.B	#2,D1
	AND.B	D0,D1
	MOVE.B	(A4)+,D3
	OR.B	0(A2,D3.W),D1
	EOR.B	D6,D1
	MOVE.B	D1,(A0)+		;STORE DATA BYTE
	ADDX.B	D1,D7
	SUBQ.W	#3,D4			;JUST PROCESSED 3 BYTES
	BRA.S	2$
3$:	MOVE.B	(A4)+,D3		;NOW CHECK CRC BYTES
	MOVE.B	0(A2,D3.W),D1
	BMI.S	8$			;CRC GCR ERROR
	ROL.B	#2,D1
	MOVE.B	D1,D2
	AND.B	D0,D2
	MOVE.B	(A4)+,D3
	MOVE.B	0(A2,D3.W),D3
	BMI.S	8$			;CRC GCR ERROR
	OR.B	D3,D2
	CMP.B	D2,D5			;FIRST CRC BYTE
	BNE.S	8$			;CRC ERROR
	ROL.B	#2,D1
	MOVE.B	D1,D2
	AND.B	D0,D2
	MOVE.B	(A4)+,D3
	MOVE.B	0(A2,D3.W),D3
	BMI.S	8$			;CRC GCR ERROR
	OR.B	D3,D2
	CMP.B	D2,D6			;SECOND CRC BYTE
	BNE.S	8$			;CRC ERROR
	ROL.B	#2,D1
	AND.B	D0,D1
	MOVE.B	(A4)+,D3
	MOVE.B	0(A2,D3.W),D3
	BMI.S	8$			;CRC GCR ERROR
	OR.B	D3,D1
	CMP.B	D1,D7
	BEQ.S	9$			;VALID CRC
8$:	MOVEQ	#TDERR_BadSecSum,D0
	STC
9$:	POP	D2-D7/A2-A4
	RTS


* Encodes user data block into GCR format, and stores into
* proper sector of trackbuffer.  Sector to process in D0.

EncodeGCRData:
	PUSH	D2-D7/A2/A4
	LEA	SectorTable,A4
	MOVE.B	D0,D2
	LSL.W	#3,D0
	MOVE.L	4(A4,D0.W),D1		;get pointer to sector data
	BNE.S	11$
	STC				;just in case...
	BRA	9$			;bail out
11$:	DECL	D1			;back up to $AD
	MOVE.L	D1,A4
	LSL.W	#1,D0
	LEA	TagBuf,A1
	ADD.W	D0,A1
	MOVE.B	D2,(A1)			;save sector number
	ZAP	D2
	ZAP	D3
	MOVE.L	#$2010009,D4		;load byte counts
	ZAP	D5
	ZAP	D6
	ZAP	D7
	LEA	BinToGcr,A2		;GCR conversion table	
	MOVEQ	#11,D1
	MOVE.B	(A1)+,D2		;binary sector number from TagBuf
	BRA.S	4$
2$:	MOVE.L	UserBuffer(A3),A1	;switch to user's data buffer
3$:	ADDX.B	D2,D7
	EOR.B	D6,D2
	MOVE.B	D2,D3
	LSR.W	#6,D3
	MOVE.B	0(A2,D3.W),(A4)+
	SUB.W	#3,D4
	MOVE.B	D7,D3
	ADD.B	D7,D3
	ROL.B	#1,D7
	ANDI.B	#$3F,D0
	MOVE.B	0(A2,D0.W),(A4)+
4$:	MOVE.B	(A1)+,D0		;get a data byte
	ADDX.B	D0,D5
	EOR.B	D7,D0
	MOVE.B	D0,D3
	ROL.W	#2,D3
	ANDI.B	#$3F,D1
	MOVE.B	0(A2,D1.W),(A4)+
	MOVE.B	(A1)+,D1
	ADDX.B	D1,D6
	EOR.B	D5,D1
	MOVE.B	D1,D3
	ROL.W	#2,D3
	ANDI.B	#$3F,D2
	MOVE.B	0(A2,D2.W),(A4)+
	MOVE.B	(A1)+,D2
	TST.W	D4		;done?
	BNE.S	3$		;no...loop
	SWAP	D4
	BNE.S	2$		;if not done, switch from tag data to user data
	CLR.B	D3		;else output CRC bytes
	LSR.W	#6,D3
	MOVE.B	0(A2,D3.W),(A4)+
	MOVE.B	D5,D3
	ROL.W	#2,D3
	MOVE.B	D6,D3
	ROL.W	#2,D3
	ANDI.B	#$3F,D0
	MOVE.B	0(A2,D0.W),(A4)+
	ANDI.B	#$3F,D1
	MOVE.B	0(A2,D1.W),(A4)+
	MOVE.B	D7,D3
	LSR.W	#6,D3
	MOVE.B	0(A2,D3.W),(A4)+
	ANDI.B	#$3F,D5
	MOVE.B	0(A2,D5.W),(A4)+
	ANDI.B	#$3F,D6
	MOVE.B	0(A2,D6.W),(A4)+
	ANDI.B	#$3F,D7
	MOVE.B	0(A2,D7.W),(A4)+
	LEA	SecTrailer,A2
	MOVEQ	#3,D2			;4 bytes in trailer
5$:	MOVE.B	(A2)+,(A4)+		;move trailer byte into buffer
	DBF	D2,5$			;loop
	CLC
9$:	POP	D2-D7/A2/A4
	RTS

SecLeader	DC.B	$FF,$3F,$CF,$F3,$FC,$FF
SecTrailer	DC.B	$DE,$AA,$FF,$FF

* Copy from ReadBuf to WriteBuf prior to write.  The idea is to move sector 0
* to the front of the buffer and build sector gaps, as necessary.
* Note: gaps must be a bit larger, since Amiga clock speed is about 2%
* faster than Mac, causing sectors to be physically closer together.  This
* leaves too little room when the Mac rewrites these sectors later.
* Remember, Mac rewrites sectors, not whole tracks.

TrkGapSize	EQU	65	;number of FFs in main gap
HdrSize		EQU	10	;bytes in header, $D5 to $AA
HdrGapSize	EQU	12	;count of FFs in gap 'tween hdr and data (6)
RawSectorSize	EQU	709	;raw bytes of sector data, $D5 to $AA
SecGapSize	EQU	54	;count of FFs between sectors (37)

AlignSectors:
	PUSH	D3-D4/A4
	LEA	SectorTable,A4		;point to table of sector headers
	MOVE.L	WriteBuffer(A3),A0	;here is where result must go
	LEA	TrackGap(A0),A0		;skip over gap area of FFs
	ZAP	D3
	MOVE.B	SecsPerTrk(A3),D3	;this many sectors to process
	DECW	D3			;secs-1=7-11
	MOVE.W	D3,D4
	LSR.W	#1,D4			;divide to get 3-5
	INCW	D4			;add 1 to get 4-6 (interleave)
	SWAP	D4			;interleave to high word
	CLR.W	D4			;start with sector 0
2$:	MOVE.W	D4,D0			;move this sector
	BSR	MoveOneSector
	INCW	D4
	SWAP	D4			;switch to interleave sectors
	DBF	D3,2$
	MOVE.L	A0,D0			;calc size of write buffer w/trk gap
	SUB.L	WriteBuffer(A3),D0
	MOVE.L	D0,WriteLength(A3)	;write this many bytes
	POP	D3-D4/A4
	RTS

* Moves one sector from Readbuffer to Writebuffer
* A0 points to place to store data.  Sector number in D0.

MoveOneSector:
	PUSH	D2-D3
	MOVEQ	#-1,D3			;gap filler char
	MOVEQ	#SecGapSize-9,D2	;sector gap, less 2 trailer and 6 hdr
4$:	MOVE.B	D3,(A0)+
	DBF	D2,4$
	LEA	SecLeader,A1		;use special sync sequence
	MOVEQ	#5,D2
5$:	MOVE.B	(A1)+,(A0)+
	DBF	D2,5$
	LSL.W	#3,D0
	MOVE.L	0(A4,D0.W),A1		;points to $D5 of sector hdr
	MOVEQ	#HdrSize-1,D2		;move $D5 $AA $96 ... $DE $AA
1$:	MOVE.B	(A1)+,(A0)+		;move in byte of header
	DBF	D2,1$
	MOVEQ	#HdrGapSize-1,D2
2$:	MOVE.B	D3,(A0)+		;use filler char in gap
	DBF	D2,2$
	MOVE.W	#RawSectorSize-3,D2	;stick on $DE $AA after move
	MOVE.L	4(A4,D0.W),A1
	SUBQ.L	#3,A1			;back up to start with $D5 $AA $AD
3$:	MOVE.B	(A1)+,(A0)+
	DBF	D2,3$
	MOVE.B	#$DE,(A0)+		;make sure sector data ends properly
	MOVE.B	#$AA,(A0)+
	MOVE.B	D3,(A0)+		;force 2 trailing $FFs
	MOVE.B	D3,(A0)+
	POP	D2-D3
	RTS

* Binary to 6 + 2 GCR conversion table 

BinToGcr:
	DC.B	$96	;0
	DC.B	$97	;1
	DC.B	$9A	;2
	DC.B	$9B	;3
	DC.B	$9D	;4
	DC.B	$9E	;5
	DC.B	$9F	;6
	DC.B	$A6	;7
	DC.B	$A7	;8
	DC.B	$AB	;9
	DC.B	$AC	;A
	DC.B	$AD	;B
	DC.B	$AE	;C
	DC.B	$AF	;D
	DC.B	$B2	;E
	DC.B	$B3	;F
	DC.B	$B4	;10
	DC.B	$B5	;11
	DC.B	$B6	;12
	DC.B	$B7	;13
	DC.B	$B9	;14
	DC.B	$BA	;15
	DC.B	$BB	;16
	DC.B	$BC	;17
	DC.B	$BD	;18
	DC.B	$BE	;19
	DC.B	$BF	;1A
	DC.B	$CB	;1B
	DC.B	$CD	;1C
	DC.B	$CE	;1D
	DC.B	$CF	;1E
	DC.B	$D3	;1F
	DC.B	$D6	;20
	DC.B	$D7	;21
	DC.B	$D9	;22
	DC.B	$DA	;23
	DC.B	$DB	;24
	DC.B	$DC	;25
	DC.B	$DD	;26
	DC.B	$DE	;27
	DC.B	$DF	;28
	DC.B	$E5	;29
	DC.B	$E6	;2A
	DC.B	$E7	;2B
	DC.B	$E9	;2C
	DC.B	$EA	;2D
	DC.B	$EB	;2E
	DC.B	$EC	;2F
	DC.B	$ED	;30
	DC.B	$EE	;31
	DC.B	$EF	;32
	DC.B	$F2	;33
	DC.B	$F3	;34
	DC.B	$F4	;35
	DC.B	$F5	;36
	DC.B	$F6	;37
	DC.B	$F7	;38
	DC.B	$F9	;39
	DC.B	$FA	;3A
	DC.B	$FB	;3B
	DC.B	$FC	;3C
	DC.B	$FD	;3D
	DC.B	$FE	;3E
	DC.B	$FF	;3F

* GCR to binary conversion table.  ($96 OFFSET)

GcrToBin:
	DC.B	0	;96
	DC.B	1	;97
	DC.B	-1	;98
	DC.B	-1	;99
	DC.B	2	;9A
	DC.B	3	;9B
	DC.B	-1	;9C
	DC.B	4	;9D
	DC.B	5	;9E
	DC.B	6	;9F
	DC.B	-1	;A0
	DC.B	-1	;A1
	DC.B	-1	;A2
	DC.B	-1	;A3
	DC.B	-1	;A4
	DC.B	-1	;A5
	DC.B	7	;A6
	DC.B	8	;A7
	DC.B	-1	;A8
	DC.B	-1	;A9
	DC.B	-1	;AA
	DC.B	9	;AB
	DC.B	$A	;AC
	DC.B	$B	;AD
	DC.B	$C	;AE
	DC.B	$D	;AF
	DC.B	-1	;B0
	DC.B	-1	;B1
	DC.B	$E	;B2
	DC.B	$F	;B3
	DC.B	$10	;B4
	DC.B	$11	;B5
	DC.B	$12	;B6
	DC.B	$13	;B7
	DC.B	-1	;B8
	DC.B	$14	;B9
	DC.B	$15	;BA
	DC.B	$16	;BB
	DC.B	$17	;BC
	DC.B	$18	;BD
	DC.B	$19	;BE
	DC.B	$1A	;BF
	DC.B	-1	;C0
	DC.B	-1	;C1
	DC.B	-1	;C2
	DC.B	-1	;C3
	DC.B	-1	;C4
	DC.B	-1	;C5
	DC.B	-1	;C6
	DC.B	-1	;C7
	DC.B	-1	;C8
	DC.B	-1	;C9
	DC.B	-1	;CA
	DC.B	$1B	;CB
	DC.B	-1	;CC
	DC.B	$1C	;CD
	DC.B	$1D	;CE
	DC.B	$1E	;CF
	DC.B	-1	;D0
	DC.B	-1	;D1
	DC.B	-1	;D2
	DC.B	$1F	;D3
	DC.B	-1	;D4
	DC.B	-1	;D5
	DC.B	$20	;D6
	DC.B	$21	;D7
	DC.B	-1	;D8
	DC.B	$22	;D9
	DC.B	$23	;DA
	DC.B	$24	;DB
	DC.B	$25	;DC
	DC.B	$26	;DD
	DC.B	$27	;DE
	DC.B	$28	;DF
	DC.B	-1	;E0
	DC.B	-1	;E1
	DC.B	-1	;E2
	DC.B	-1	;E3
	DC.B	-1	;E4
	DC.B	$29	;E5
	DC.B	$2A	;E6
	DC.B	$2B	;E7
	DC.B	-1	;E8
	DC.B	$2C	;E9
	DC.B	$2D	;EA
	DC.B	$2E	;EB
	DC.B	$2F	;EC
	DC.B	$30	;ED
	DC.B	$31	;EE
	DC.B	$32	;EF
	DC.B	-1	;F0
	DC.B	-1	;F1
	DC.B	$33	;F2
	DC.B	$34	;F3
	DC.B	$35	;F4
	DC.B	$36	;F5
	DC.B	$37	;F6
	DC.B	$38	;F7
	DC.B	-1	;F8
	DC.B	$39	;F9
	DC.B	$3A	;FA
	DC.B	$3B	;FB
	DC.B	$3C	;FC
	DC.B	$3D	;FD
	DC.B	$3E	;FE
	DC.B	$3F	;FF

SectorTable	DCB.L	MaxSectors*2,0

TagBuf	DCB.B	12*16,0		;SECTOR TAG BUFFER, 12 max
HdrBuf	DCB.B	16,0		;local hdr buffer

	END
