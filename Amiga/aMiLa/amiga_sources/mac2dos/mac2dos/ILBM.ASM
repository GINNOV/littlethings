*********************************************************
*							*
*		ILBM.ASM				*
*							*
* 	Mac-2-Dos ILBM-->MacPaint Conversion		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	424 Vista Ave, Golden, CO 80401			*
*	All rights reserved, worldwide			*
*********************************************************

;	INCLUDE	"MAC.I"
;	INCLUDE "VD0:MACROS.ASM"
	INCLUDE "PRE.OBJ"

	XDEF	CopyIFFBody
	XDEF	ProcessBMHD,ProcessCAMG,ProcessCMAP

	XDEF	Width,Height,IFFFlags

	XREF	GetDosChar,GetDosWord,GetDosLong
	XREF	PutMacChar

	XREF	SysBase
	XREF	ReadDosBlock,DosBuffer
	XREF	DosBytCnt
	XREF	InputPtr
	XREF	PixelBuffer

FSMax		EQU	3*15		;white
FSThreshold	EQU	FSMax/2		;Floyd-Steinberg threshold
BMHDSize	EQU	20		;just in case...
MacPixelLimit	EQU	576/8
MPScanLines	EQU	720		;MacPaint image is 576x720

* Extracts useful information from the ILBM BMHD IFF chunk.

ProcessBMHD:
	BSR	GetDosLong		;ignore size of bitmap header
	ERROR	8$
	IFNEIL	D0,#BMHDSize,8$,L	;make sure length is OK
	BSR	GetDosWord		;raster width in Pixels
	ERROR	8$
	MOVE.W	D0,Width
	BSR	GetDosWord		;raster height in pixels
	ERROR	8$
	MOVE.W	D0,Height
	BSR	GetDosLong		;ignore pixel position
	ERROR	8$
	BSR	GetDosChar		;number of bitplanes
	ERROR	8$
	IFGTIW	D0,#6,8$		;no more than 6 bitplanes
	MOVE.W	D0,BitPlaneCount	;save number of bit planes
	MOVEQ	#-1,D1
	LSL.W	D0,D1			;shift in 0's
	NOT.W	D1			;complement the bits
	MOVE.B	D1,BitPlaneMask		;save mask
;	LEA	BitPlaneTbl,A0
;	MOVE.B	0(A0,D0.W),BitPlaneMask	;get proper mask based
	BSR	GetDosChar		;masking flag
	ERROR	8$
	MOVE.B	D0,MaskFlag
	BSR	GetDosChar		;compression flag
	ERROR	8$
	MOVE.B	D0,CompFlag		;save it
	BSR	GetDosChar		;skip pad
	ERROR	8$
	BSR	GetDosWord		;transparent color, whatever that is
	ERROR	8$
	MOVE.W	D0,TransColor		;save it for masking??
	BSR	GetDosChar		;pixel aspect ratio...ignore
	ERROR	8$
	BSR	GetDosChar		;ditto
	ERROR	8$
	BSR	GetDosWord		;pagewidth
	ERROR	8$
	MOVE.W	D0,PageWidth
	BSR	GetDosWord		;pageheight
	ERROR	8$
	MOVE.W	D0,PageHeight
	BSET	#0,IFFFlags		;looks good
8$:	RTS

* Defines settings of ColorRegs, which are indexed by pixel bitmap value
* to determine RGB value of each pixel.  There should be 2^n color regs,
* where N is the number of bitplanes.  It takes 3 bytes to define each
* color reg.

ProcessCMAP:
	PUSH	D2-D3/A2
	BSR	GetDosLong		;load length
	MOVE.W	BitPlaneCount,D2	;calc number of color regs
	MOVEQ	#5,D1
	IFLEW	D2,D1,2$		;no more than 5 real bitplanes
	MOVE.W	D1,D2
2$:	MOVEQ	#1,D1
	LSL.W	D2,D1			;color regs=2^nbitplanes
	MOVE.W	D1,D2
	ADD.W	D1,D2
	ADD.W	D1,D2			;*3 bytes per color reg
	IFNEW	D0,D2,8$		;don't let bad iff chunk blow up
;	MOVE.W	D0,D2			;process this many bytes
	LEA	ColorRegs,A2		;point to colormap table
1$:	IFLTIW	D2,#3,9$		;thats all folks
	BSR	GetColorMapValue	;get 3 bytes
	ERROR	9$			;oops
	MOVE.W	D0,(A2)+		;store colormap entry
	SUB.W	#3,D2			;just processed 3 bytes
	BMI.S	8$			;went negative...trouble
	BNE.S	1$			;still more to process
	BSET	#1,IFFFlags		;went to 0 properly...good exit
	BRA.S	9$
8$:	STC
9$:	POP	D2-D3/A2
	RTS

* Builds colormap value from 3 successive bytes from IFF file.  Colormap
* info is LEFT-JUSTIFIED in byte.  Bytes loaded in this order: R, G, B
* Returns ColorReg value in D0 or CY on error

GetColorMapValue:
	PUSH	D2-D3
	ZAP	D3
	MOVEQ	#2,D2
1$:	BSR	GetDosChar		;get color map char
	ERROR	8$
	LSR.W	#4,D0			;shift color info to low end
	AND.W	#$F,D0			;just in case...
	LSL.W	#4,D3			;make room for new color
	OR.B	D0,D3
	DBF	D2,1$
	MOVE.W	D3,D0
8$:	POP	D2-D3
	RTS

* This chunk is Commodore specific, and defines the viewmode in effect.
* All we care about are $80 (Half-bright) and $800 (HAM).

ProcessCAMG:
	BSR	GetDosLong		;length
	BSR	GetDosLong		;get viewmode param
	AND.L	#$880,D0		;mask down to HAM/HB flags
	MOVE.W	D0,ViewMode		;save viewmode of image
	BSET	#2,IFFFlags
	RTS

* Processes BODY chunk, and applies Floyd-Steinberg dithering algorithm.
* Works with all standard IFF ILBM formats (including HAM and half-bright).
* Size of image in pixels in Width and Height, respectively.
* Input pointer sitting at first pixel data in BODY chunk.

CopyIFFBody:
	PUSH	D2-D3/A2
	LEA	MPFileHdr,A2
	MOVE.W	#511,D2
5$:	MOVE.B	(A2)+,D0
	BSR	PutMacChar		;header char to buffer
	DBF	D2,5$			;loop
	BSET	#2,IFFFlags		;was there a CAMG chunk?
	BNE.S	2$			;YES...it defines viewmode
	IFNEIW	BitPlaneCount,#6,2$	;not 6 bit planes...normal mode
	MOVE.W	#$800,ViewMode		;else force HAM mode	
2$:	ZAP	D0
	MOVE.W	Width,D0		;image width in pixels
	ADD.W	#15,D0			;gotta round up to words
	LSR.L	#4,D0			;divide by 16 to get words/scan line
	LSL.L	#1,D0			;back to bytes/scan line
	MOVE.L	D0,D2			;size of each scanline buf in bytes
	MOVE.W	BitPlaneCount,D1
	IFNEIB	MaskFlag,#1,3$		;no mask plane
	INCW	D1			;add a bitplane for mask
3$:	MULU	D1,D0			;calc size of buffer needed
	MOVE.L	D0,ScanLineBufSize	;save for later release
	ZAP	D1
	CALLSYS	AllocMem,SysBase	;get a buffer
	MOVE.L	D0,ScanLineBuffer	;buffer goes here
	BEQ	8$			;no scanline buffer...
	MOVE.L	D0,BP1Buffer
	ADD.L	D2,D0
	MOVE.L	D0,BP2Buffer
	ADD.L	D2,D0
	MOVE.L	D0,BP3Buffer
	ADD.L	D2,D0
	MOVE.L	D0,BP4Buffer
	ADD.L	D2,D0
	MOVE.L	D0,BP5Buffer
	ADD.L	D2,D0
	MOVE.L	D0,BP6Buffer
	ADD.L	D2,D0
	IFNEIB	MaskFlag,#1,4$		;no mask buffer
	MOVE.L	D0,MaskBuffer		;else set up ptr
4$:	ZAP	D0
	MOVE.W	Width,D0
	MOVE.L	D0,IntBufSize		;save the size
	ZAP	D1
	CALLSYS	AllocMem
	MOVE.L	D0,IntensityBuffer
	BEQ	8$			;oops
	MOVE.W	Height,D2		;number of scan lines to process
	MOVE.W	#MPScanLines,D0
	IFLEW	D2,D0,6$		;need to fill
	MOVE.W	D0,D2			;else clip to MacPaint limit
6$:	DECW	D2			;for DBF
	ZAP	D3			;y param
1$:	BSR	FillIntBuffer		;calc intensity value for each pixel
	ERROR	9$			;eof
	MOVE.W	D3,D0			;pass y param
	BSR	DitherOneLine		;dither current line
	BSR	MacFlushScanLine	;compress and output scan line
	ERROR	9$
	INCW	D3
	DBF	D2,1$
	MOVE.W	#MPScanLines,D2
	SUB.W	Height,D2		;do we need to fill?
	BLE.S	7$			;no
	LEA	PixelBuffer,A0
	MOVE.L	A0,A2
	MOVE.W	#MacPixelLimit-1,D1
	ZAP	D0
10$:	MOVE.B	D0,(A0)+
	DBF	D1,10$
	DECW	D2
11$:	BSR	MacFlushScanLine
	DBF	D2,11$
7$:	MOVE.L	ScanLineBuffer,A1
	IFZL	A1,9$
	MOVE.L	ScanLineBufSize,D0
	CALLSYS	FreeMem,SysBase
	MOVE.L	IntensityBuffer,A1
	IFZL	A1,9$
	MOVE.L	IntBufSize,D0
	CALLSYS	FreeMem
	BRA.S	9$
8$:	DispErr	NoMem.
	STC
9$:	POP	D2-D3/A2		;done
	RTS

* Loads bit plane buffers, then IntensityBuffer with pixel intensity data
* from bit plane buffers and color regs.

FillIntBuffer:
	PUSH	D2-D4/A2-A3
	CLR.W	SavedColor
	BSR	LoadBitPlaneBufs	;load bit plane data from IFF file
	ERROR	9$			;eof
	MOVE.W	ViewMode,D4		;for checking mode
	LEA	ColorRegs,A3
	MOVE.L	IntensityBuffer,A2	;intensity values go here
	MOVE.W	Width,D2		;number of pixels per scan line
	DECW	D2			;for dbf
	BSR	InitBitPlanePtrs	;set up to convert bitplanes
1$:	BSR	GetPixelColor		;get pixel color value
	BTST	#11,D4			;HAM mode?
	BEQ.S	2$			;no...HB or normal
	MOVE.W	D0,D1			;save color index value
	AND.W	#$F,D0			;HAM mode uses lower 4 bits
	LSR.W	#3,D1			;word index into color mask
	AND.W	#6,D1			;get rid of possible garbage
	BEQ.S	2$			;"normal" color index
	LEA	ColorMask,A0		;ptr to
	MOVE.W	6(A0,D1.W),D1		;get shift count
	LSL.W	D1,D0			;shift bits to proper position
	MOVE.W	0(A0,D1.W),D1		;get proper color mask
	MOVE.W	SavedColor,D3		;RGB color of previous pixel
	AND.W	D1,D3			;get rid of old R/G/B value
	OR.W	D3,D0			;mix in 'held' colors
	MOVE.W	D0,SavedColor		;save this color for next time
	BSR	ConvertRGB		;now get intensity
	BRA.S	3$

2$:;	AND.W	BitPlaneMask,D0		;limit color reg index
	LSL.W	#1,D0
	MOVE.W	0(A3,D0.W),D0		;get pixel RGB color
	BSR	ConvertRGB		;convert to intensity
	BTST	#5,D4			;half bright specified for this pixel?
	BEQ.S	3$			;no...just store value
	LSR.W	#1,D0			;else cut value in half
3$:	MOVE.B	D0,(A2)+		;store into intensity buffer
	DBF	D2,1$			;loop for all pixels on line
	CLC
9$:	POP	D2-D4/A2-A3
	RTS

* Convert normal RGB value in D0 to intensity in D0.
* Uses YIQ conversion from Procedural Elements for Computer Graphics, p. 399.
* Intensity=0.299R+0.587G+0.114B 
* Color reg format: 0000RRRRGGGGBBBB

ConvertRGB:
	PUSH	D3
	MOVE.W	D0,D3
	AND.W	#$F,D0		;blue already in low nibble
	MULU	#29,D0
	LSR.W	#4,D3
	MOVE.W	D3,D1
	AND.W	#$F,D1
	MULU	#150,D1
	ADD.W	D1,D0		;green
	LSR.W	#4,D3
	MOVE.W	D3,D1
	AND.W	#$F,D1
	MULU	#77,D1
	ADD.W	D1,D0		;red
	ADD.W	#128,D0		;round up
	LSR.W	#8,D0		;divide by 256
	POP	D3
	RTS

* Process one scan line, applying ordered dithering.
* y (scan line number) in D0
* Dither algorithm: matrix position=((y&3)*4+(x&3))

DitherOneLine:
	PUSH	D2-D4/A3-A5
	AND.W	#3,D0
	LSL.W	#2,D0			;(y&3)*2
	MOVE.W	D0,D2			;index into dither matrix
	ZAP	D4			;x
	MOVE.L	IntensityBuffer,A4	;current line pixel intensity table
	MOVEQ	#7,D3			;start with high bit in output
	LEA	PixelBuffer,A3		;this is where the bits go
	LEA	DitherMatrix,A5
	ADD.W	D2,A5			;proper index given y
1$:	MOVE.B	(A4),D0			;get intensity of pixel
	MOVE.W	D4,D1
	AND.W	#3,D1
	CMP.B	0(A5,D1.W),D0		;compare intensities
	BLE.S	2$
	BCLR	D3,(A3)			;make it white on Mac
	BRA.S	3$
2$:	BSET	D3,(A3)			;make it black on Mac
3$:	DECB	D3			;next lower pixel
	BPL.S	4$			;still in same byte
	INCL	A3			;else advance to next byte
	MOVEQ	#7,D3			;reset to highest pixel
4$:	INCL	A4			;advance to next pixel intensity
	INCW	D4			;next pixel
	IFGTW	Width,D4,1$		;loop for all pixels
	POP	D2-D4/A3-A5
	RTS

InitBitPlanePtrs:
	PUSH	D2-D7/A2-A6
	ZAP	D7		;start with nothing in regs
	MOVE.L	BP1Buffer,A1
	MOVE.L	BP2Buffer,A2
	MOVE.L	BP3Buffer,A3
	MOVE.L	BP4Buffer,A4
	MOVE.L	BP5Buffer,A5
	MOVE.L	BP6Buffer,A6
	MOVEM.L	D1-D7/A0-A6,SavePtrs	
	POP	D2-D7/A2-A6
	RTS

* Builds color register value in D0 from bitplane data.

GetPixelColor:
	PUSH	D2-D7/A2-A6
	MOVEM.L	SavePtrs,D1-D7/A0-A6
	IFNZB	D7,1$
	MOVE.B	(A1)+,D1
	MOVE.B	(A2)+,D2
	MOVE.B	(A3)+,D3
	MOVE.B	(A4)+,D4
	MOVE.B	(A5)+,D5
	MOVE.B	(A6)+,D6
	MOVEQ	#8,D7
1$:	ZAP	D0		;build pixel color index from bitplanes
	ROXL.B	#1,D6		;bitplane 6
	ROXL.B	#1,D0
	ROXL.B	#1,D5		;bitplane 5
	ROXL.B	#1,D0
	ROXL.B	#1,D4		;bitplane 4
	ROXL.B	#1,D0
	ROXL.B	#1,D3		;bitplane 3
	ROXL.B	#1,D0
	ROXL.B	#1,D2		;bitplane 2
	ROXL.B	#1,D0
	ROXL.B	#1,D1		;bitplane 1
	ROXL.B	#1,D0
	DECW	D7
	MOVEM.L	D1-D7/A0-A6,SavePtrs	;save bitplane ptrs
	AND.B	BitPlaneMask,D0		;limit color reg index
	POP	D2-D7/A2-A6
	RTS

;* Copies NextLineIntBuf into IntensityBuffer.
;
;MoveIntBuffer:
;1$:	MOVE.L	IntensityBuffer,A1
;	MOVE.L	NextLineIntBuf,A0
;	MOVE.W	Width,D0
;	DECW	D0
;2$:	MOVE.B	(A0)+,(A1)+		;move values for next line
;	DBF	D0,2$			;to the current line
;	RTS

* Loads bitplane scan line buffers from IFF file.  Returns CY=1 on
* EOF or failure.

LoadBitPlaneBufs:
	IFNZB	CompFlag,LoadCompressed	;compressed image
	PUSH	D2/A2
	MOVE.L	ScanLineBufSize,D2
	MOVE.L	ScanLineBuffer,A2
	DECW	D2
1$:	BSR	GetDosChar
	ERROR	9$
	MOVE.B	D0,(A2)+
	DBF	D2,1$
9$:	POP	D2/A2
	RTS

* Loads compressed IFF file into scan line buffers.

LoadCompressed:
	PUSH	D2/A2-A3
	MOVE.L	ScanLineBuffer,A2
	MOVE.L	A2,A3
	ADD.L	ScanLineBufSize,A3	;point to end of line for input
1$:	BSR	GetDosChar	;now fill scanline buffer
	ERROR	9$,L
	TST.B	D0		;replicate?
	BPL.S	3$		;no...literal string

	NEG.B	D0
	MOVE.W	D0,D2		;use for DBF as is (+1, -1)
	MOVE.L	A2,D0
	ADD.L	D2,D0		;check if data will fit
	IFLTL	D0,A3,6$	;OKAY
	MOVE.L	A3,D2
	SUB.L	A2,D2
	DECW	D2		;only process this many
6$:	BSR	GetDosChar	;get replicated char
	ERROR	9$
2$:	MOVE.B	D0,(A2)+	;replicate the char
	DBF	D2,2$
	BRA.S	5$

3$:	MOVE.W	D0,D2		;use as is for DBF
	MOVE.L	A2,D0
	ADD.L	D2,D0		;check if data will fit
	IFLTL	D0,A3,4$	;OKAY
	MOVE.L	A3,D2
	SUB.L	A2,D2
	DECW	D2		;only process this many
4$:	BSR	GetDosChar	
	ERROR	9$
	MOVE.B	D0,(A2)+
	DBF	D2,4$
5$:	IFLTL	A2,A3,1$,L	;buffer yet full
9$:	POP	D2/A2-A3
	RTS

* Outputs scanline data to MacPaint file.
* Clips image at 576-pixels to match MacPaint format.
* Compresses 576-pixel scanline data for MacPaint format.

MacFlushScanLine:
	PUSH	D2-D3/A2-A3
	LEA	PixelBuffer,A2
	MOVE.L	A2,A3
	ADD.L	#MacPixelLimit,A3
1$:	MOVE.L	A2,A0		;save ptr to literal string
	MOVE.B	(A2)+,D2	;get control byte
	IFGEL	A2,A3,7$,L	;oops...last byte by itself
	MOVE.B	(A2)+,D0	;get next byte
	CMP.B	D0,D2		;next byte identical?
	BNE.S	5$		;no...building literal string
	MOVEQ	#1,D1		;got a run of 2 bytes (n+1)
2$:	IFGEL	A2,A3,4$	;end of buffer...stop
	CMP.B	(A2)+,D2	;another match?
	BNE.S	3$		;NO...output replication
	INCL	D1		;else count it
	BRA.S	2$		;and loop for length of replication
3$:	DECW	A2		;back up to non-matching char
4$:	MOVE.W	D1,D0
;	DECW	D1
	NEG.W	D0		;negative byte count for replicate
	BSR	PutMacChar	;into Dos buffer
	MOVE.B	D2,D0	
	BSR	PutMacChar	;store replicated char
	IFLTL	A2,A3,1$	;not end of buffer...loop
	BRA.S	9$		;look for next string

5$:	MOVE.B	D0,D2		;save byte
	IFGEL	A2,A3,7$	;no more data
	MOVE.B	(A2)+,D0	;get next one
	CMP.B	D0,D2
	BNE.S	5$		;loop until matching pair
	SUBQ.L	#2,A2		;backup to first of matching pair
7$:	MOVE.L	A2,D2		;calc length of literal string
	SUB.L	A0,D2
	DECW	D2		;adjust per algorithm and for DBF
	MOVE.L	A0,A2		;ptr to literal string
	MOVE.B	D2,D0
	BSR	PutMacChar	;store length of run
6$:	MOVE.B	(A2)+,D0	;get byte of run
	BSR	PutMacChar	;store literal char
	DBF	D2,6$		;loop
	IFLTL	A2,A3,1$,L	;go until scanline completed

9$:	POP	D2-D3/A2-A3
	RTS

SavePtrs	DCB.L	14,0		;14 working regs
BP1Buffer	DC.L	0		;ptr to BitPlane 1 ScanLine buffer
BP2Buffer	DC.L	0		;ptr to BitPlane 2 ScanLine buffer
BP3Buffer	DC.L	0		;ptr to BitPlane 3 ScanLine buffer
BP4Buffer	DC.L	0		;ptr to BitPlane 4 ScanLine buffer
BP5Buffer	DC.L	0		;ptr to BitPlane 5 ScanLine buffer
BP6Buffer	DC.L	0		;ptr to BitPlane 6 ScanLine buffer
MaskBuffer	DC.L	0		;ptr to mask buffer
ScanLineBuffer	DC.L	0		;buffer for n scan lines
ScanLineBufSize	DC.L	0		;scan line size in bytes
IntensityBuffer	DC.L	0		;ptr to scan line intensity buffer
;NextLineIntBuf	DC.L	0		;ptr to next scan line int buffer
IntBufSize	DC.L	0		;size of intensity buffers
Width		DC.W	0		;image width in pixels
Height		DC.W	0		;image height in pixels
PageWidth	DC.W	0		;raster width in pixels
PageHeight	DC.W	0		;raster height in pixels
ViewMode	DC.W	0		;Amiga viewmode

DitherMatrix	DC.B	00,08,02,10	;From Procedural Elements of
		DC.B	12,04,14,06	;Computer Graphics, p. 107
		DC.B	03,11,01,09
		DC.B	14,07,13,05

ColorRegs	DCB.W	32,0		;32 color regs
ColorMask	DC.W	0		;HAM color mask none
		DC.W	$FF0		;BLUE mask
		DC.W	$0FF		;RED mask
		DC.W	$F0F		;GREEN mask
		DC.W	0		;blue shift=0
		DC.W	8		;red shift=8
		DC.W	4		;green shift=4
TransColor	DC.W	0		;transparent color
SavedColor	DC.W	0		;HAM mode previous pixel color
BitPlaneCount	DC.W	0		;count of bitplanes in image
BitPlaneMask	DC.B	0		;bitplanes in mask format
IFFFlags	DC.B	0		;IFF file flags
MaskFlag	DC.B	0		;1=mask bitplane
CompFlag	DC.B	0		;1=IFF file is compressed

NoMem.	TEXTZ	<'Out of memory...cannot copy file.'>

		CNOP	0,4
MPFileHdr
	DC.L	$00000002,$FFFFFFFF,$FFFFFFFF,$DDFF77FF
	DC.L	$DDFF77FF,$DD77DD77,$DD77DD77,$AA55AA55
	DC.L	$AA55AA55,$55FF55FF,$55FF55FF,$AAAAAAAA
	DC.L	$AAAAAAAA,$EEDDBB77,$EEDDBB77,$88888888
	DC.L	$88888888,$B130031B,$D8C00C8D,$80100220
	DC.L	$01084004,$FF888888,$FF888888,$FF808080
	DC.L	$FF080808,$80000000,$00000000,$80402000
	DC.L	$02040800,$82443944,$82010101,$F8742247
	DC.L	$8F172271,$55A04040,$550A0404,$14224994
	DC.L	$29924428,$BF00BFBF,$B0B0B0B0,$00000000
	DC.L	$00000000,$80000800,$80000800,$88002200
	DC.L	$88002200,$88228822,$88228822,$AA00AA00
	DC.L	$AA00AA00,$FF00FF00,$FF00FF00,$11224488
	DC.L	$11224488,$FF000000,$FF000000,$01020408
	DC.L	$10204080,$AA008000,$88008000,$FF808080
	DC.L	$80808080,$081C22C1,$80010204,$88142241
	DC.L	$8800AA00,$40A00000,$040A0000,$03844830
	DC.L	$0C020101,$8080413E,$080814E3,$102054AA
	DC.L	$FF020408,$77898F8F,$7798F8F8,$0008142A
	DC.L	$552A1408,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000


	END
