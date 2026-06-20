*********************************************************
*							*
*		MACFILES.ASM				*
*							*
* 	Mac-2-Dos Mac file system routines		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	424 Vista Ave, Golden, CO 80401			*
*	All rights reserved, worldwide			*
*********************************************************

	INCLUDE	"MAC.I"
	INCLUDE "VD0:MACROS.ASM"

	XDEF	CopyIFFBody
	XDEF	ProcessBMHD,ProcessCAMG,ProcessCMAP

	XDEF	Width,Height,IFFFlags

	XREF	SysBase
	XREF	ReadDosBlock
	XREF	DosBytCnt
	XREF	InputPtr

FSMax		EQU	3*16		;white
FSThreshold	EQU	FSMax/2		;Floyd-Steinberg threshold

ScanLineBufCnt	EQU	6		;Amiga max bit planes

* Extracts useful information from the ILBM BMHD IFF chunk.

ProcessBMHD:
	BSR	GetDosLong		;ignore size of bitmap header
	ERROR	8$
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
	MOVE.W	BitPlaneCount		;save number of bit planes
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
	BSR	GetDosByte		;pixel aspect ratio...ignore
	ERROR	8$
	BSR	GetDosByte		;ditto
	ERROR	8$
	BSR	GetDosWord		;pagewidth
	ERROR	8$
	MOVE.W	DO,PageWidth
	BSR	GetDosWord		;pageheight
	ERROR	8$
	MOVE.W	D0,PageHeight
	BSET	#0,IFFFlags		;looks good
8$:	RTS

ProcessCMAP:
	PUSH	D2-D3/A2
	BSR	GetDosLong		;load length
	MOVE.W	D0,D2			;process this many bytes
	LEA	ColorMap,A2		;point to colormap table
1$:	IFLTIW	D2,#3,2$		;thats all folks
	BSR	GetColorMapValue	;get 3 bytes
	MOVE.W	D3,(A2)+		;store colormap entry
	SUB.W	#3,D2			;just processed 3 bytes
	BMI.S	2$			;went negative...trouble
	BNE.S	1$			;still more to process
	BSET	#1,IFFFlags		;went to 0 properly...good exit
2$:	POP	D2-D3/A2
	RTS

* Builds colormap value from 3 successive bytes from IFF file.  Colormap
* info is LEFT-JUSTIFIED in byte.
* Bytes loaded in this order: R, G, B
* Returns value in D0 or CY on error

GetColorMapValue:
	PUSH	D2-D3
	ZAP	D3
	MOVEQ	#2,D2
1$:	BSR	GetDosChar		;get color map char
	ERROR	8$
	LSR.W	#4,D0			;shift color info to low end
	AND.W	#$F,D0			;just in case...
	LSL.W	#4,D3			;make room for new color
	MOVE.B	D0,D3
	DBF	D2,1$
	MOVE.W	D3,D0
8$:	POP	D2-D3
	RTS

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
	PUSH	D2
	BSET	#2,IFFFlags		;was there a CAMG chunk?
	BNE.S	2$			;YES...it gives viewmode
	IFNEIB	BitPlaneCount,#6,2$	;not 6 bit planes...normal mode
	MOVE.W	#$800,ViewMode		;else force HAM mode	
2$:	ZAP	D0
	MOVE.W	Width,D0		;image width in pixels
	ADD.W	#15,D0			;gotta round up to words
	LSR.L	#4,D0			;divide by 16 to get words/scan line
	LSL.L	#1,D0			;back to bytes/scan line
	MOVE.L	D0,D2
	MOVE.W	BitPlaneCount,D1
	IFZB	MaskFlag,3$		;no mask plane
	INCW	D1			;add a bitplane for mask
3$:	MULU	D1,D0			;calc size of buffer needed
	MOVE.L	D0,ScanLineBufSize	;save for later release
	ZAP	D1
	CALLSYS	AllocateMem,SysBase	;get a buffer
	MOVE.L	D0,ScanLineBuffer	;buffer goes here
	BEQ	8$			;no buffer...
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
	IFZB	MaskFlag,4$		;no mask buffer
	MOVE.L	D0,MaskBuffer		;else aet up ptr
4$:	MOVE.W	Height,D2		;number of scan lines to process
	DECW	D2			;make it easy to find last line
	BSR	FillValueBuffer		;fill value buffer
	ERROR	9$
	BSR	CorrectForMode		;fix line if HAM or HB modes
1$:	BSR	MoveScanValue		;move next scan value to cur scan value
	BSR	FillValueBuffer		;fill value buffer again
	ERROR	9$
	BSR	CorrectForMode		;fix line if HAM or HB modes
	BSR	DitherOneLine		;dither current line
	BSR	CompressScanLine	;compress and output scan line
	ERROR	9$
	DECW	D2
	BNE.S	1$			;loop till last scan line
	BSR	MoveScanValue		;move last line data up
	BSR	DitherOneLine		;dither the last line
	BSR	CompressScanLine	;compress and output scan line
	MOVE.L	ScanLineBuffer,A1
	IFZL	A1,9$
	MOVE.L	ScanLineBufSize,D0
	CALLSYS	FreeMem,SysBase
	BRA.S	9$
8$:	STC
9$:	POP	D2			;done
	RTS

* Loads bit plane buffers, then NextScanValue buffer with pixel intensity data
* from bit plane buffers and color regs.

FillValueBuffer:
	PUSH	D2-D4/A2
	BSR	LoadBitPlaneBufs	;load bit plane data from IFF file
	ERROR	??
	MOVE.L	ViewMode,D4		;for checking mode
	LEA	NextScanValue,A2	;values go here
	MOVE.W	Width,D2		;nmber of pixels per scan line
	DECW	D2
	BSR	InitBitPlanePtrs	;set up to convert bitplanes
1$:	BSR.S	GetPixelColor		;get pixel color value
	MOVE.W	D0,D1			;save original value
	TST.L	D4			;special viewmode?
	BEQ.S	2$			;no...normal mode
	BTST	#7,D4			;else is it half-brite?
	BEQ.S	4$			;no...must be HAM
	AND.W	#$1F,D0			;get rid of HB bit
	MOVEW	0(A0,D0.W),D0		;get pixel RGB color
	BSR	ConvertRGB		;get RGB value based on reg nmber
	BTST	#5,D1			;half bright specified for this pixel?
	BEQ.S	3$			;no...just store value
	LSR.W	#1,D0			;else cut value in half
	BRA.S	3$			;and then store it
4$:	AND.W	#$F,D0			;just 4 bits in HAM mode
	MOVE.W	0(A0,D0.W),D0		;get new RGB value
	LSR.W	#4,D1			;this is index into color mask
	LEA	ColorMask,A0
	MOVE.W	0(A0,D1.W),D1		;get proper color mask
	MOVE.W	SavedColor,D3		;color of previous pixel
	AND.W	D1,D3
	NOT.W	D1
	AND.W	D1,D0			;mask out proper color
	OR.W	D3,D0			;mix in 'held' colors
	BSR	ConvertRGB		;now get intensity
	BRA.S	3$
2$:	AND.W	BitPlaneMask,D0		;limit color reg index
	MOVE.W	0(A0,D0.W),D0		;get pixel RGB color
	BSR	ConvertRGB
3$:	MOVE.B	D0,(A2)+		;store into intensity buffer
	DBF	D2,1$			;loop for all pixels on line
	CLC
	POP	D2-D4/A2
	RTS

* Convert notmal RGB value to intensity.  Colors are additive.

ConvertRGB:
	MOVE.B	D0,D3
	AND.B	#$F,D0
	LSR.B	#4,D3
	MOVE.B	D3,D1
	AND.B	#$F,D1
	ADD.B	D1,D0
	LSR.B	#4,D3
	MOVE.B	D3,D1
	AND.B	#$F,D1
	ADD.B	D1,D0
	RTS

* Loads bitplane scan line buffers from IFF file.  Returns CY=1 on
* EOF or failure.

LoadBitPlaneBufs:
	PUSH	D2-D3
	MOVE.L	ScanLineBufSize,D3
1$:	MOVE.L	DosBytCnt,D2		;anything in the buffer?
	BNE.S	2$			;yes...use it
	BSR	ReadDosBlock		;else read another
	ERROR	9$
	LEA	DosBuffer,A0		;source
	MOVE.L	A0,InputPtr
	MOVE.L	DosBytCnt,D2		;anything in the buffer?
2$:	IFLTL	D2,D3,3$		;use all available in Dos block
	MOVE.L	D3,D2			;else use just what we need
3$:	MOVE.L	D2,D0
	MOVE.L	InputPtr,A0
	MOVE.L	ScanLineBuffer,A1
	DECW	D0
4$:	MOVE.B	(A0)+,(A1)+		;move scan line data into buffer
	DBF	D0,4$
	MOVE.L	A0,InputPtr
	SUB.L	D2,DosBytCnt		;used up this many
	SUB.L	D2,D3			;loaded this many...need more?
	BNE.S	1$			;yes...loop
9$:	POP	D2-D3
	RTS

* Process one scan line, applying FS algorithm.

DitherOneLine:
	PUSH	D2-D4/A3-A5
	MOVE.W	Width,D4		;number of pixels on each scan line
	DECW	D4
	LEA	CurScanValue,A4		;current line pixel intensity table
	LEA	NextScanValue,A5	;next line pixel intensity table
	MOVEQ	#7,D3			;start with high bit in output
	LEA	ScanBuffer,A3		;this is where the bits go
	MOVEQ	#FSMax,D2		;White value

1$:	MOVE.B	(A4),D0			;get intensity of pixel
	IFGEIB	D0,#FSThreshold,2$	;pixel to be white
;	SUBQ	#0,D0			;error=intensity-black
	BSET	D3,(A3)			;set pixel black (1)
	BRA.S	3$
2$:	BCLR	D3,(A3)			;set pixel white (0)
	SUB.B	D2,D0			;error=intensity-white
3$:	LSR.B	#2,D0			;divide by 4
	ADD.B	D0,1(A5)		;add error/4 to I(x+1,y+1)
	MOVE.B	D0,D1
	LSL.B	#1,D1
	ADD.B	D1,D0			;d0=d0*3
	LSR.B	#1,D0			;d0=3*error/8
	ADD.B	D0,1(A4)		;add (3*error)/8 to (x+1,y)
	ADD.B	D0,(A5)			;add (3*error)/8 to (x,y+1)
	DECB	D3			;next lower pixel
	BPL.S	4$			;still in same byte
	INCL	A3			;else advance to next byte
	MOVEQ	#7,D3			;reset to highest pixel
	INCL	A4			;advance to next pixel value
	INCL	A5			;and pixel on next line
	DBF	D4,1$			;loop for all pixels on line
	POP	D2-D4/A3-A5
	RTS

InitBitPlanePtrs:
	PUSH	D2-D7/A2-A6
	ZAP	D7		;start with nothing in regs
	LEA	ColorRegs,A0
	MOVE.L	BP1Buffer,A1
	MOVE.L	BP2Buffer,A2
	MOVE.L	BP3Buffer,A3
	MOVE.L	BP4Buffer,A4
	MOVE.L	BP5Buffer,A5
	MOVE.L	BP6Buffer,A6
	MOVEM.L	D1-D7/A0-A6,SavePtrs	
	POP	D2-D7/A2-A6
	RTS

* Builds color register value from bitplane data.

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
	NOVEM.L	D1-D7/A0-A6,SavePtrs	;save bitplane ptrs
;	AND.B	BitPlaneMask,D0		;limit color reg index
;	MOVE.W	0(A0,D0.W),D0		;get pixel RGB color
	POP	D2-D7/A2-A6
	RTS

MoveScanValue:
1$:	LEA	CurScanValue,A1
	LEA	NextScanValue,A0
	MOVE.W	Width,D0
	DECW	D0
2$:	MOVE.B	(A0)+,(A1)+		;move values for next line
	DBF	D0,2$			;to the current line
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
Width		DC.W	0		;image width in pixels
Height		DC.W	0		;image height in pixels
PageWidth	DC.W	0		;raster width in pixels
PageHeight	DC.W	0		;raster height in pixels
ViewMode	DC.W	0		;Amiga viewmode

ColorRegs	DCB.W	32,0		;32 color regs
ColorMask	DC.W	0		;HAM color mask none
		DC.W	$F00		;RED mask
		DC.W	$0F0		;BLUE mask
		DC.W	$00F		;GREEN mask
BitPlaneCount	DC.W	0		;count of bitplanes in image
BitPlaneMask	DC.B	0		;bitplanes in mask format
IFFFlags	DC.B	0		;IFF file flags
MaskFlag	DC.B	0		;1=mask bitplane

	END
