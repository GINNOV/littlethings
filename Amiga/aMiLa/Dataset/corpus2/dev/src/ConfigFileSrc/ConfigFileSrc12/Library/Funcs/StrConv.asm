*
*  $PROJECT: ConfigFile.library
*  $FILE: StrConv.asm
*  $DESCRIPTION:  String converting functions.
*
*  (C) Copyright 1997 Marcel Karas
*      All Rights Reserved.
*

	SECTION	text,CODE

_MC68020		EQU	1

	XREF	_CType

CTB_LOWER	EQU	0
CTB_HEX		EQU	7

*--------------------------------------------------------------------------*

* LongToDecStr -- converting a long to a decimal string
*
* A0  - Pointer to the storage string
* D0  - Long
* >A0 - New pointer
*
	XDEF	_LongToDecStr
_LongToDecStr:

	BTST		#31,D0
	BEQ.B		NoSign
	NEG.L		D0
	MOVE.B	#'-',(A0)+
NoSign:

* LongToUnDecStr -- converting a long to a unsigned decimal string
*
* A0  - Pointer to the storage string
* D0  - Long
* >A0 - New pointer
*

*	XDEF	_LongToUnDecStr
*_LongToUnDecStr:

	IFD		_MC68020

	EXG		D2,A1
	BCLR		#1,D2
	BSR.B		ConvDec
	BTST		#1,D2
	BNE.B		ConvDecEnd
	MOVE.B	#'0',(A0)+

ConvDecEnd:
	EXG		D2,A1
*	MOVE.B	#0,(A0)
	MOVE.L	A0,D0
	RTS

ConvDec:

	CMP.L		#$FF,D0
	BLS.S		TinyConv

	CMP.L		#$FFFF,D0
	BLS.B		SmallConv

	DIVUL.L	#1000000000,D1:D0
	BSR.B		ConvDigit

	DIVUL.L	#100000000,D1:D0
	BSR.B		ConvDigit

	DIVUL.L	#10000000,D1:D0
	BSR.B		ConvDigit

	DIVUL.L	#1000000,D1:D0
	BSR.B		ConvDigit

	DIVUL.L	#100000,D1:D0
	BSR.B		ConvDigit

SmallConv:
	DIVUL.L	#10000,D1:D0
	BSR.B		ConvDigit

	DIVUL.L	#1000,D1:D0
	BSR.B		ConvDigit

TinyConv:
	DIVUL.L	#100,D1:D0
	BSR.B		ConvDigit

	DIVUL.L	#10,D1:D0
	BSR		ConvDigit

ConvDigit:
	TST.B		D0
	BNE.B		DecNoNull
	BTST		#1,D2
	BEQ.B		DecNoNull2

DecNoNull:
	ADD.L		#$30,D0
	MOVE.B	D0,(A0)+
	BSET		#1,D2
DecNoNull2:
	MOVE.L	D1,D0
	RTS

	ELSE

	MOVEM.L	D2/D3/D4,-(SP)
	BCLR		#1,D4
	BSR.B		ConvDec
	BTST		#1,D4
	BNE.B		ConvDecEnd
	MOVE.B	#'0',(A0)+

ConvDecEnd:
	MOVEM.L	(SP)+,D2/D3/D4
*	MOVE.B	#0,(A0)
	MOVE.L	A0,D0
	RTS

ConvDec:

	CMP.L		#$FF,D0
	BLS.S		TinyConv

	CMP.L		#$FFFF,D0
	BLS.S		SmallConv

	MOVE.L	#1000000000,D1
	BSR.B		UDivMod32Full
	BSR.B		ConvDigit

	MOVE.L	#100000000,D1
	BSR.B		UDivMod32Full
	BSR.B		ConvDigit

	MOVE.L	#10000000,D1
	BSR.B		UDivMod32Full
	BSR.B		ConvDigit

	MOVE.L	#1000000,D1
	BSR.B		UDivMod32Full
	BSR.B		ConvDigit

	MOVE.L	#100000,D1
	BSR.B		UDivMod32Full
	BSR.B		ConvDigit

SmallConv:
	MOVE.L	#10000,D1
	BSR.B		UDivMod32Small
	BSR.B		ConvDigit

	MOVE.L	#1000,D1
	BSR.B		UDivMod32Small
	BSR.B		ConvDigit

TinyConv:
	MOVE.L	#100,D1
	BSR.B		UDivMod32Small
	BSR.B		ConvDigit

	MOVE.L	#10,D1
	BSR.B		UDivMod32Small
	BSR		ConvDigit

ConvDigit:
	TST.B		D0
	BNE.B		DecNoNull
	BTST		#1,D4
	BEQ.B		DecNoNull2

DecNoNull:
	ADD.L		#$30,D0
	MOVE.B	D0,(A0)+
	BSET		#1,D4
DecNoNull2:
	MOVE.L	D1,D0
	RTS

UDivMod32Full:
	MOVE.L	D1,D3
	MOVE.L	D0,D1
	CLR.W		D1
	SWAP		D0
	SWAP		D1
	CLR.W		D0
	MOVEQ		#$F,D2
.Loop:
	ADD.L		D0,D0
	ADDX.L	D1,D1
	CMP.L		D1,D3
	BHI.B		.LoopEnd
	SUB.L		D3,D1
	ADDQ.W	#1,D0
.LoopEnd:
	DBRA		D2,.Loop
	RTS

UDivMod32Small:
	MOVE.L	D1,D3
	SWAP		D0
	MOVE.W	D0,D3
	BEQ.B		SmallDiv
	DIVU		D1,D3
	MOVE.W	D3,D0
SmallDiv:
	SWAP		D0
	MOVE.W	D0,D3
	DIVU		D1,D3
	MOVE.W	D3,D0
	SWAP		D3
	MOVE.W	D3,D1
	RTS

	ENDC

*--------------------------------------------------------------------------*

* LongToHexStr -- converting a long to a hexa decimal string
*
* A0  - Pointer to the storage string
* D0  - Long
* >A0 - New pointer
*
	XDEF	_LongToHexStr
_LongToHexStr:

	MOVE.L	D2,-(SP)
	MOVEQ		#7,D2
	CLR.L		D1
	LEA		HexArry(PC),A1
	MOVE.B	#'$',(A0)+

	CMP.L		#$FFFF,D0
	BHI.B		HexInLoop
	MOVEQ		#3,D1

	CMP.L		#$FF,D0
	BHI.B		HexInLoop
	MOVEQ		#1,D1

HexInLoop:
	ROL.L		#4,D0
	MOVE.B	D0,D1
	AND		#$0F,D1
	TST.B		D1
	BNE.B		NoNull
	BTST		#31,D1
	BEQ.B		NoNull2

NoNull:
	MOVE.B	0(A1,D1),D1
	MOVE.B	D1,(A0)+
	BSET		#31,D1
NoNull2:
	DBRA		D2,HexInLoop

	BTST		#31,D1
	BNE.B		HexConvEnd
	MOVE.B	#'0',(A0)+

HexConvEnd:

	MOVE.L	(SP)+,D2
*	MOVE.B	#0,(A0)
	MOVE.L	A0,D0
	RTS

HexArry:
	DC.B		'0123456789ABCDEF'

*--------------------------------------------------------------------------*

* LongToBinStr -- converting a long to a binary string
*
* A0  - Pointer to the storage string
* D0  - Long
* >A0 - New pointer
*
	XDEF	_LongToBinStr
_LongToBinStr:

	MOVE.B	#'%',(A0)+
	MOVEQ		#31,D1

	CMP.L		#$FFFF,D0
	BHI.B		BitInLoop
	MOVEQ		#15,D1

	CMP.L		#$FF,D0
	BHI.B		BitInLoop
	MOVEQ		#7,D1

BitInLoop:
	BTST		D1,D0
	BEQ.B		BitIsNull

	MOVE.B	#'1',(A0)+
	BSET		#31,D0
	BRA.B		LastBitCheck

BitIsNull:
	BTST		#31,D0
	BEQ.B		LastBitCheck
	MOVE.B	#'0',(A0)+

LastBitCheck:
	DBF		D1,BitInLoop

	BTST		#31,D0
	BNE.B		BinConvEnd
	MOVE.B	#'0',(A0)+

BinConvEnd:
*	MOVE.B	#0,(A0)
	MOVE.L	A0,D0
	RTS

*--------------------------------------------------------------------------*

* LongToOctStr -- converting a long to a octal string

*--------------------------------------------------------------------------*

* DecStrToLong -- converting a decimal string to a long
*
* A0  - Pointer to the hex string
* A1  - Storage pointer for the Long
* >A1 - Store Long
* >A0 - New pointer
*

	XDEF	_DecStrToLong
_DecStrToLong:
	IFD		_MC68020

	MOVE.L	D2,-(SP)
	CLR.L		D0
	CLR.L		D1
	MOVE.B	(A0),D2
	CMPI.B	#'-',D2
	BNE.B		DecConv
	ADDQ		#1,A0

DecConv:
	MOVE.B	(A0)+,D0
	SUBI.B	#'0',D0

DecInLoop:
	CLR.B		D1
	MOVE.B	(A0)+,D1
	SUBI.B	#'0',D1

	CMPI.B	#10,D1
	BCC.B		DecInOk
	MULU.L	#10,D0
	ADD.L		D1,D0
	BRA.B		DecInLoop

DecInOk:
	SUBQ		#1,A0
	CMPI.B	#'-',D2
	BNE.B		DecEnd
	NEG.L		D0

DecEnd:

	MOVE.L	(SP)+,D2
	MOVE.L	D0,(A1)
	MOVE.L	A0,D0
	RTS

	ELSE

	CLR.L		D0
	MOVEM.L	D2/D3/D4/D5,-(SP)

	MOVE.B	(A0),D4
	CMPI.B	#'-',D4
	BNE.B		DecConv
	ADDQ		#1,A0

DecConv:
	MOVE.B	(A0)+,D0
	SUBI.W	#'0',D0

DecInLoop:
	CLR.L		D1
	MOVE.B	(A0)+,D1
	SUBI.W	#'0',D1

	CMPI.W	#10,D1
	BCC.B		DecInOk

** UMult32 **
	MOVE.L	#10,D5
	CLR.L		D2
	CLR.L		D3

	** ad **
	MOVE.W	D5,D3
	SWAP.W	D0
	MULU.W	D0,D3

	** bc **
	SWAP.W	D0
	MOVE.W	D0,D2
	SWAP.W	D5
	MULU.W	D5,D2

	** (ad + bc)^16 **
	ADD.L		D3,D2
	SWAP.W	D2
	CLR.W		D2

	** bd + (ad + bc)^16 **
	SWAP.W	D5
	MULU.W	D5,D0
	ADD.L		D2,D0
** UMult32 **

	ADD.L		D1,D0
	BRA.B		DecInLoop

DecInOk:
	SUBQ		#1,A0
	CMPI.B	#'-',D4
	BNE.B		DecEnd
	NEG.L		D0
DecEnd:
	MOVEM.L	(SP)+,D2/D3/D4/D5
	MOVE.L	D0,(A1)
	MOVE.L	A0,D0
	RTS

	ENDC
*--------------------------------------------------------------------------*

* HexStrToLong -- converting a hexadecimal string to a long
*
* A0  - Pointer to the hex string
* A1  - Storage pointer for the Long
* >A1 - Store Long
* >A0 - New pointer
*

	XDEF	_HexStrToLong
_HexStrToLong:

	MOVE.L	A1,-(SP)
	MOVEQ		#0,D0
	MOVEQ		#0,D1
	LEA		_CType(A4),A1

HexStrLoop:
	ADDQ		#1,A0
	MOVE.B	(A0),D1
	BTST		#CTB_HEX,0(A1,D1)
	BEQ.B		HexStrEnd

	BTST		#6,D1
	BEQ.B		IsNum

	ANDI.B	#$0F,D1
	ADDI.B	#$09,D1
	LSL.L		#4,D0
	OR.B		D1,D0
	BRA.B		HexStrLoop

IsNum:
	ANDI.B	#$0F,D1
	LSL.L		#4,D0
	OR.B		D1,D0
	BRA.B		HexStrLoop

HexStrEnd:

	MOVE.L	(SP)+,A1
	MOVE.L	D0,(A1)
	MOVE.L	A0,D0
	RTS

*--------------------------------------------------------------------------*

* BinStrToLong -- converting a binary string to a long
*
* A0  - Pointer to the binary string
* A1  - Storage pointer for the Long
* >A1 - Store Long
* >A0 - New pointer
*
	XDEF	_BinStrToLong
_BinStrToLong:

	CLR.L		D0

BinStrLoop:
	ADDQ		#1,A0
	CMPI.B	#'1',(A0)
	BNE.B		CharIsNull
	LSL.L		#1,D0
	BSET		#0,D0
	BRA.B		BinStrLoop

CharIsNull:
	CMPI.B	#'0',(A0)
	BNE.B		BinStrEnd
	LSL.L		#1,D0
	BRA.B		BinStrLoop

BinStrEnd:
	MOVE.L	D0,(A1)
	MOVE.L	A0,D0
	RTS

*--------------------------------------------------------------------------*

* OctStrToLong -- converting a octal string to a long

*--------------------------------------------------------------------------*

	END
