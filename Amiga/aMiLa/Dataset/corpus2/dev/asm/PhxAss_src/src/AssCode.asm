; $VER: AssCode.asm 4.46 (30.12.14)
; **********************************************
;
;             PhxAss Macro Assembler
;
;        Written by Frank Wille, 1991-2014
;
;                Code-Generation
;
; **********************************************

	far				; Large Code/Data-Model

	include	"AssDefs.i"		; Strukturen und Definitionen einlesen

	ttl	"PhxAss - Code Generation routines"


; ************
; CODE-Segment
; ************

	section	PHXAss,code


; *** Cross-References ***

; ** XREFs **
; von AssMain.o
	xref	Error			; d0=ErrNum (Rest wird gerettet)
	xref	Warning			; a1=WarnText (Rest wird gerettet)
	xref	FatalError		; (wie oben), kehrt aber nicht zurueck
	xref	OutofMemError
	xref	GetIncNestList,GetIncludeList,GetHunkReloc ; ->d0=MemPtr
	xref	GetCnopTab,GetRepTab,GetRegRefList ; ->d0=MemPtr
	xref	AddString		; a0=String, ->d0=NewStringPtr (buffered)
	xref	AddLongFloat		; d0=FloatPointer, ->d0=NewFloatPtr (buffered)
	xref	FileSize		; a0=FileName
	xref	printf			; a0=FormatString, a1=DataStream
	xref	fprintf			; d0=FileHandle, a0=FormatString, a1=DataStream
	xref	sprintf			; a0=Buf, a1=FmtString, a2=DataStream
	xref	GetOptFlags		; a1=FlagsString
	xref	BuildStringTable	; a0=StringTable, a1=Strings
	xref	setOPTC

; von Assemble.o
	xref	FindSymbol,FindLocalSymbol,FindGorLSymbol ; a0=Name, ->d0=Symbol
	xref	LineParts,ListSourceLine
	xref	StrLen			; a0 =String
	xref	UCaseStrCmp,StrCmp	; a0=Str1, a1=Str2 ->Z-Flag
	xref	GetRegList		; a0=InputStream, ->d0=RegList, ->a0=NewInputPos
	xref	GetRegister		; a0=Input, ->d0=Reg, d1=NumRegs, ->a0=NewInput
	xref	GetValue		; a0=InputStream, d0=Value-Width, ->d0=Minuend,d1=Subt.
	; -> d2=DeclHunk|Type, a0=NewInputStreamPos
	xref	AddDistance,ReplaceDistance ; a1=DistAddr, d0=Minuend,d1=Subtrahend
	xref	ShiftLastDists		; d0=AddrOffset, d1=FPOffset
	xref	DelLastDists
	xref	AddReference		; a0=Symbolstruct, d0=RefType, d1=RefAddr
	xref	ChangeLastRefs		; d0=NewRefType, d1=RefAddrOffset
	xref	DelLastRefs
	xref	ShiftPC			; d0=ShiftDelta, BaseAddr wird aus PC-ShiftDelata ber.
	xref	ShiftRelocs		; a0=BaseAddr, d0=ShiftDelta
	xref	ShiftRelocsNoOpt	; a0=BaseAddr, d0=ShiftDelta
	xref	AddSymbol,AddGorLSymbol	; a0=Name, d0=Type, d1=Value
	xref	AddRegName		; a0=RegName, d0=Register
	xref	OpenLocalPart		; ->d0=FirstSymbolTab
	xref	ReadArgument		; a0=SrcBuf, a1=DestBuf, d0=DestBufSize, ->d0=ReadBytes
	xref	AddByte,AddWord,AddLong	; d0=Byte/Word/Longword
	xref	AddDouble,AddExtended	; d0=Zeiger auf 64/96-Bit Fliesskomma
	xref	AddCount		; d0=NumBytes
	xref	AddHunkData
	xref	MakeSection		; a0=SecName, d0=Type, ->a0=Section
	xref	AddLineDebug		; d2.l=Offset, d3.l=Line
	xref	FindRegName		; a0=RegName, d0=Len, -> d0=Reg,d1


; ** XDEFs **
	xdef	GetEscSym		; d0=EscSym, ->d0=Code
	xdef	CSeg
	xdef	GetSectionPtr		; d2=SecNum, ->a0=Section
	xdef	MakeMnemonicTab
	xdef	VerboseInfo,ShowVDepth


	IFD	DBMODE
STARTTIMER macro
	sf	$bfde00
	sf	$bfdf00
	st	$bfd400
	st	$bfd500
	st	$bfd600
	st	$bfd700
	move.b	#$51,$bfdf00
	move.b	#$11,$bfde00
	endm
STOPTIMER macro
	move.l	d0,-(sp)
	sf	$bfde00
	sf	$bfdf00
	move.b	$bfd700,d0
	lsl.l	#8,d0
	move.b	$bfd600,d0
	lsl.l	#8,d0
	move.b	$bfd500,d0
	lsl.l	#8,d0
	move.b	$bfd400,d0
	not.l	d0
	add.l	d0,\1
	move.l	(sp)+,d0
	endm
	ENDC



; *** Wichtig ***
; Wenn nicht anders vermerkt, wird bei allen Aufrufen immer angenommen, dass
; a5 auf PhxAssVars zeigt und a6 die ExecBase enthaelt.

OutofRange:
	moveq	#68,d0			; Out of Range
	bra	Error

IllegalInstr:
	moveq	#92,d0			; Instruction not implemented in your machine
	bra	Error

UndefSym:
	; Undefined symbol
	moveq	#36,d0
	bra	Error

MissingReg:
	moveq	#37,d0			; Missing register
	bra	Error

NeedDReg:
	moveq	#38,d0			; Need data-register
	bra	Error

NeedAReg:
	moveq	#39,d0			; Need address-register
	bra	Error

IllegalMode:
	moveq	#34,d0			; Addressing Mode not supported
	bra	Error

SyntaxErr:
	moveq	#41,d0			; Syntax error in operand
	bra	Error

RelocError:
	moveq	#42,d0			; Relocatability error
	bra	Error

LargeDist:
	; Too large distance for this mode
	moveq	#43,d0
	bra	Error

NeedDisplace:
	; Displacement expected
	moveq	#44,d0
	bra	Error

NoAddress:
	; Valid address expected
	moveq	#45,d0
	bra	Error

MissingArg:
	; Missing argument
	moveq	#46,d0
	bra	Error

AddrError:
	; No address allowed here
	moveq	#81,d0
	bra	Error

ImmedSize:
	; Immediate operand size error
	moveq	#97,d0
	bra	Error

MissingLabel:
	moveq	#28,d0			; Missing label
Error2:
	bra	Error

FatalError2:
	bra	FatalError

GetValue2:
	bra	GetValue

OutofMemError2:
	bra	OutofMemError


	IFND	FREEASS
	cnop	0,4
ShowVDepth:
; Einrücken für Verbose-Mode
	move.l	d2,-(sp)
	moveq	#0,d2
	move.b	VDepth(a5),d2
	beq.s	2$
	add.w	d2,d2
	move.w	d2,d0
	subq.w	#1,d0
	addq.w	#4,d2
	and.w	#$fffc,d2		; Platz für VDepth-Blanks und $00 (Long-Align)
	sub.l	d2,sp
	move.l	sp,a0
	moveq	#' ',d1
1$:	move.b	d1,(a0)+
	dbf	d0,1$
	clr.b	(a0)
	move.l	sp,a0
	bsr	printf			; Einrück-Blanks ausgeben
	add.l	d2,sp
2$:	move.l	(sp)+,d2
	rts


	cnop	0,4
VerboseInfo:
; Im Verbose-Mode Name des nächsten Include-Files oder Macros ausgeben
; a0 = INCLUDE/MACRO StrPtr
	IFND	GIGALINES
	move.w	AbsLine(a5),-(sp)
	clr.w	-(sp)
	ELSE
	move.l	AbsLine(a5),-(sp)
	ENDC
	move.l	AssModeName(a5),-(sp)
	move.l	a0,-(sp)
	bsr.s	ShowVDepth
	lea	VerboseTxt(pc),a0
	move.l	sp,a1
	bsr	printf
	lea	12(sp),sp
	addq.b	#1,VDepth(a5)
	rts

VerboseTxt:
	dc.b	"%s \"%s\" (%ld) {\n",0
	ENDC


	cnop	0,4
SplitOperand:
; Teilt den Operand in maximal 3 Teile auf
; a3 = OperandBuffer
; -> a3 = FirstOperand, a2 = SecondOperand, a1 = ThirdOperand
	movem.l	d2-d6/a3,-(sp)
	moveq	#'(',d2
	moveq	#')',d3
	moveq	#',',d4
	move.l	#$00220027,d5
	moveq	#ESCSYM,d6
	lea	DestOperBuffer(a5),a2
	clr.b	(a2)
	IFND	SMALLASS
	lea	ThirdOperBuffer(a5),a1
	clr.b	(a1)
	ENDC
	move.l	a3,a0
	bsr.s	2$
	beq.s	1$
	clr.b	(a0)
	move.l	a2,a0
	bsr.s	2$
	IFND	SMALLASS
	beq.s	1$
	clr.b	(a0)
	move.l	a1,a0
	bsr.s	2$
	ENDC
1$:	clr.b	(a0)
	movem.l	(sp)+,d2-d6/a3
	rts

	cnop	0,4
2$:	moveq	#0,d1			; Klammerebenen-Zaehler
3$:	move.b	(a3)+,d0
	beq.s	9$
	move.b	d0,(a0)+
	cmp.b	d4,d0			; ',' ?
	beq.s	8$
	cmp.b	d5,d0			; String?
	beq.s	5$
	swap	d5
	cmp.b	d5,d0
	beq.s	5$
	cmp.b	d2,d0			; (
	bne.s	4$
	addq.w	#1,d1
	bra.s	3$
4$:	cmp.b	d3,d0			; )
	bne.s	3$
	subq.w	#1,d1
	bpl.s	3$
	move.l	d0,-(sp)
	moveq	#32,d0			; Mehr )-Klammern als (
	bsr	Error
	move.l	(sp)+,d0
	moveq	#0,d1
	bra.s	3$
8$:	tst.w	d1
	bne.s	3$
	subq.l	#1,a0
	moveq	#-1,d0
9$:	rts
5$:	move.b	(a3)+,d0		; String kopieren
	beq.s	9$
	move.b	d0,(a0)+
	cmp.b	d6,d0			; Escape-Zeichen ?
	beq.s	12$
	swap	d5
	cmp.b	d5,d0			; anderer Stringbegrenzer?
	beq.s	10$
	swap	d5
	cmp.b	d5,d0			; echter Stringbegrenzer?
	bne.s	5$
	cmp.b	(a3),d5			; "" oder '' ?
	bne	3$
	bra.s	11$
10$:	swap	d5
	cmp.b	(a3),d0			; "" oder '' ?
	bne.s	5$
11$:	move.b	d6,-1(a0)		; durch \" bzw. \' ersetzen
12$:	move.b	(a3)+,(a0)+
	bra.s	5$


	cnop	0,4
InstrSize:
; Bestimmt, wieviel Bytes eine Instruction benoetigt. Bei 68020 Base- und
; Outer-Displacement wird, falls nicht anders moeglich, der
; schlimmstmoegliche Fall angenommen.
; Der PC in d6 wird hierbei automatisch weitergezaehlt
; a3 = OperandBuffer
; d1 = LSW: Bit 15 = Test for USP,SR,CCR  |  Bit7-5 = Op1-3 Ignore
	move.w	d1,d3
	bsr	SplitOperand
SplittedInstrSize:
; a1,a2,a3 Operand3,2,1
; d3 = siehe d1
	move.l	d7,-(sp)
	move.l	a1,d5
	move.b	Machine(a5),d7
	subq.b	#2,d7			; d7 negativ: dann 68000 oder 68010
	addq.l	#2,d6			; 2 Bytes fuer Opcode sind's immer
	add.b	d3,d3
	bcs.s	1$
	bsr.s	OperandSize
	bne.s	4$
1$:	add.b	d3,d3
	bcs.s	2$
	move.l	a2,a3
	bsr.s	OperandSize
	bne.s	4$
2$:
	IFND	SMALLASS
	add.b	d3,d3
	bcs.s	3$
	move.l	d5,a3
	bsr.s	OperandSize
	bne.s	4$
	ENDC
3$:	move.l	(sp)+,d7
	rts
4$:	move.l	(sp)+,d7
	bra	Error


	cnop	0,4
OperandSize:
	move.l	a3,OperStart(a5)	; Startadresse des Oper. retten
	moveq	#0,d4			; noch keinen Ausdruck gelesen
	move.b	(a3),d0
	beq.s	1$			; gar kein Operand da?
	cmp.b	#'#',d0			; Immediate?
	bne.s	2$
	moveq	#0,d0
	move.b	OpcodeSize(a5),d0	; Speicherverbrauch fuer Immediate-Type
	move.b	99$(pc,d0.w),d0
	add.l	d0,d6
1$:	moveq	#0,d0
	rts
99$:	dc.b	2			; Byte
	dc.b	2			; Word
	dc.b	4			; Long
	IFND	SMALLASS
	dc.b	4			; FastFloatingPoint
	dc.b	4			; SinglePrecision
	dc.b	8			; DoublePrecision
	dc.b	12			; ExtendedPrecision
	dc.b	12			; PackedBCD
	dc.b	8			; QuadWord
	ENDC
	even
2$:	cmp.b	#'-',d0			; erstes Minus ignorieren
	bne.s	4$
	addq.l	#1,a3
	move.l	a3,OperStart(a5)
	cmp.b	#'(',(a3)		; kein -( . Dann muss es ein Ausdruck sein
	bne.s	5$
	addq.l	#1,a3
	move.l	a3,a0			; -(Rn ? Ob Dn oder An wird in Pass2 gecheckt
	bsr	GetRegister
	bmi	12$
	bra.s	1$			; ok
4$:	cmp.b	#'(',d0			; Klammerterm?
	beq.s	6$
	move.l	a3,a0			; Dn oder An direct?
	bsr	GetRegister
	bpl.s	1$			; ok
	tst.w	d3
	bpl.s	5$			; nicht nach USP,CCR,SR pruefen?
	move.l	a3,a0
	lea	adrmod_USP(pc),a1	; USP ?
	bsr	UCaseStrCmp
	beq.s	1$
	move.l	a3,a0
	lea	adrmod_CCR(pc),a1	; CCR ?
	bsr	UCaseStrCmp
	beq.s	1$
	move.l	a3,a0
	lea	adrmod_SR(pc),a1	; SR ?
	bsr	UCaseStrCmp
	beq.s	1$
5$:	bsr	ToLastTerm		; zum letzten Term springen (falls vorhanden)
	bne.s	10$
	addq.l	#4,d6			; Absolute Adressierung liegt vor
	cmp.b	#'.',-3(a3)
	bne.s	9$
	moveq	#-$21,d0
	and.b	-2(a3),d0
	cmp.b	#'W',d0			; Absolute Short?
	bne.s	9$
	subq.l	#2,d6
9$:	moveq	#0,d0
	rts
6$:	addq.l	#1,a3
	move.l	a3,OperStart(a5)
	bra.s	100$
10$:	move.l	a3,d4
	subq.l	#1,d4
100$:	move.l	a3,a0			; Klammerterm untersuchen
	bsr	GetRegister		; (An ?
	IFD	SMALLASS
	bpl	15$
	ELSE
	bmi.s	11$
	tst.b	d7			; 68020-Mode?
	bmi	150$
	subq.b	#8,d0			; Auf BaseRegisterSuppress testen
	bmi	17$			; (Dn ?
	moveq	#-'*',d0
	add.b	(a0),d0			; (An* ?
	beq	17$
	subq.b	#4,d0			; (An. ?
	beq	17$
	addq.b	#2,d0			; ',' : index vorhanden?
	bne	15$
	tst.l	d4
	bne	15$
	addq.l	#1,a0
	move.l	a0,a3
	bsr	GetRegister		; index register or outer displ.?
	bpl	18$			; indexed = + 2 bytes
	move.l	a3,OperStart(a5)	; macht OuterDispl. zu BaseDispl.
	bsr	ToEndOfTerm		; Term überspringen
	move.l	a0,d4
	subq.l	#1,d4
	bra	15$
	ENDC
11$:	bsr	CheckPC
	bmi.s	111$
	beq.s	15$			; d(PC) oder d(PC,Rn) - teste 020 Ext.
	IFND	SMALLASS
	bra.s	16$			; ZPC - Zero PC
	ELSE
	bra	33$			; Unknown Addressing Mode
	ENDC
111$:
	IFND	SMALLASS
	tst.b	d7
	bmi.s	12$
	cmp.b	#'[',(a3)		; ([  kann 68020 Memory-Indirect anzeigen
	beq	20$
	bsr	GetZReg			; (ZAn.. oder (ZDn..
	bpl.s	17$			; Zero-Mode braucht immer ein Format-Word
	ENDC
12$:	tst.l	d4
	beq.s	120$			; expr(expr... wäre absolute Addressierung
	addq.l	#1,a3
	bra	5$
120$:	moveq	#'(',d1
	moveq	#1,d2
13$:	move.b	(a3)+,d0		; Ausdruck bis zu ')' oder ',' ueberlesen
	beq.s	41$			; Klammer-zu fehlt!
	sub.b	d1,d0			; '(' - neue Klammerebene
	bne.s	130$
	addq.w	#1,d2
	bra.s	13$
130$:	subq.b	#1,d0			; ')'
	bne.s	131$
	subq.w	#1,d2			; letzte Klammerebene geschlossen ?
	beq	5$
	bra.s	13$
131$:	subq.b	#3,d0			; ','
	bne.s	13$
	bra	10$			; Zeichen nach "(expr," behandeln
15$:	tst.b	d7
	bmi.s	150$
	bsr.s	50$			; 020 base displacement prüfen
	beq.s	150$
	bpl.s	18$
	bra.s	41$
150$:	cmp.b	#')',(a0)		; kein Index?
	bne.s	18$
	tst.l	d4
	beq.s	19$			; und kein Ausdruck vor dem Adr.Reg.? = (An)
	bra.s	18$			; Displacement defaults to 16 bit
	IFND	SMALLASS
16$:	tst.b	d7			; 68020-Mode?
	bmi.s	33$
17$:	bsr.s	50$			; 020-Format-Word Mode - teste bd
	bmi.s	41$
	ENDC
18$:	addq.l	#2,d6			; 1 Word fuer Displacement, bzw. Format
19$:	moveq	#0,d0
	rts
33$:	moveq	#33,d0			; "Unknown addressing mode"
	rts
41$:	moveq	#41,d0			; "Syntax error"
	rts
; 020 base displacement prüfen
50$:	tst.l	d4
	beq.s	51$
	move.l	d4,a0
	sub.l	OperStart(a5),d4
	subq.l	#3,d4			; Mind. 3 Char. um auf ".X" zu testen
	bmi.s	19$
	cmp.b	#'.',-2(a0)		; (expr.X,Rn ...)  or  expr.X(Rn ...)
	bne.s	19$			; return mit Z=1
	moveq	#-$21,d0
	and.b	-1(a0),d0
	cmp.b	#'W',d0			; 16-bit displacement?
	bne.s	52$
	addq.l	#2,d6
	moveq	#0,d0
51$:	rts
52$:	cmp.b	#'L',d0			; 32-bit displacement?
	bne.s	53$
	addq.l	#4,d6
	moveq	#0,d0
	rts
53$:	moveq	#-1,d0
	rts


	IFND	SMALLASS
20$:					; Auf 68020 Memory-Indirect prüfen ([x],od)
	move.l	d4,EarlyOD(a5)
	addq.l	#2,d6			; Format-Word
	addq.l	#1,a3
	move.l	a3,a0
	bsr	GetRegister
	bpl.s	21$			; kein BaseDisplacement vorhanden?
	bsr	CheckPC
	bpl.s	21$
	bsr	GetZReg
	bpl.s	21$
	addq.l	#4,d6
21$:	moveq	#'[',d1
	moveq	#']',d2
	moveq	#1,d4
22$:	move.b	(a3)+,d0		; Ende des MemoryIndirect-Bereichs suchen
	beq.s	41$
	cmp.b	d1,d0
	bne.s	23$
	addq.w	#1,d4
	bra.s	22$
23$:	cmp.b	d2,d0
	bne.s	22$
	subq.w	#1,d4
	bne.s	22$
	tst.l	EarlyOD(a5)		; Early Outer-Displacement?
	bne.s	28$
	moveq	#',',d2
	cmp.b	(a3)+,d2		; hängt noch was dran?  ([xxx], ...
	bne.s	29$
	move.l	a3,a0
	bsr	GetRegister		; Index?
	bpl.s	24$
	bsr	GetZReg
	bmi.s	28$
24$:	move.b	(a0)+,d0		; OuterDisp. nach Index?  ([xxx],Rn,od) ?
	beq.s	29$
	cmp.b	d2,d0
	bne.s	24$
28$:	addq.l	#4,d6			; Outer Displacement
29$:	moveq	#0,d0
	rts
	ENDC

adrmod_SR:
	dc.b	"SR",0
adrmod_CCR:
	dc.b	"CCR",0
adrmod_USP:
	dc.b	"USP",0
	even


	cnop	0,4
ToLastTerm:
; Stringpointer auf den Anfang des letzten Klammerterms setzen
; a3 = Stringptr
; -> a3 = NewStringptr, Z-Flag = kein Klammerterm da
	moveq	#'(',d1
	sub.l	a0,a0
1$:	move.b	(a3)+,d0
	beq.s	2$
	cmp.b	d1,d0
	bne.s	1$
	move.l	a3,a0
	bra.s	1$
2$:	move.l	a0,d0
	beq.s	3$
	move.l	d0,a3
3$:	rts


	cnop	0,4
ToEndOfTerm:
; Ende eines Terms ')' finden, weitere Verschachtelungen beachten
; a0 = Streamptr
; -> a0 = NewStreamptr, nach Term-Ende
	move.l	d2,a1
	moveq	#1,d2
	moveq	#'(',d1
1$:	move.b	(a0)+,d0
	beq.s	3$
	sub.b	d1,d0
	bne.s	2$
	addq.l	#1,d2
	bra.s	1$
2$:	subq.b	#1,d0			; ')'
	bne.s	1$
	subq.l	#1,d2
	bne.s	1$
3$:	move.l	a1,d2
	rts


	cnop	0,4
CheckPC:
; Testet auf 'PC)' oder 'PC,' und setzt gegenenfalls den
; Stringpointer auf das ')' , ']' oder ','.
; Ein 'ZPC' wird ebenfalls erkannt und dann ignoriert
; a3 = Stringpointer
; -> a3 = NewStrPointer, falls es PC war
; -> d0 = -1(no PC), 0(PC), 1(ZPC)
	move.l	a3,a0
	moveq	#-$21,d1
	move.b	(a0)+,d0
	and.b	d1,d0
	cmp.b	#'P',d0			; PC ?
	bne.s	2$
	move.b	(a0)+,d0
	and.b	d1,d0
	cmp.b	#'C',d0
	bne.s	4$
	move.b	(a0),d0
	sub.b	#')',d0
	beq.s	1$
	subq.b	#3,d0			; ','
	beq.s	1$
	cmp.b	#']'-',',d0		;']'
	bne.s	4$
1$:	move.l	a0,a3
	moveq	#0,d0
	rts
2$:
	IFND	SMALLASS
	cmp.b	#'Z',d0			; ZPC ?
	bne.s	4$
	move.b	(a0)+,d0
	and.b	d1,d0
	cmp.b	#'P',d0			; PC ?
	bne.s	4$
	move.b	(a0)+,d0
	and.b	d1,d0
	cmp.b	#'C',d0
	bne.s	4$
	move.b	(a0),d0
	sub.b	#')',d0
	beq.s	3$
	subq.b	#3,d0			; ','
	beq.s	3$
	cmp.b	#']'-',',d0		;']'
	bne.s	4$
3$:	move.l	a0,a3
	moveq	#1,d0
	rts
	ENDC
4$:	moveq	#-1,d0
	rts


	IFND	SMALLASS
	cnop	0,4
GetZReg:
; Testet auf Zero-Register ZA0-ZA7 sowie ZD0-ZD7 und setzt den
; Stringpointer auf das nachfolgende Zeichen
; a3 = Stringpointer
; -> a0 = NewStringPointer
; -> a3 = a0, wenn es ein Zero-Register war
; -> d0 = Register 0-7, oder -1 wenn kein Register
	move.l	a3,a0
	moveq	#-$21,d0
	and.b	(a0)+,d0
	cmp.b	#'Z',d0
	bne.s	2$
	moveq	#8,d0
	moveq	#-$21,d1
	and.b	(a0)+,d1
	sub.b	#'A',d1			; ZAn ?
	beq.s	1$
	moveq	#0,d0
	subq.b	#3,d1			; ZDn ?
	bne.s	2$
1$:	move.b	(a0)+,d1
	sub.b	#'0',d1
	blo.s	2$
	cmp.b	#7,d1
	bhi.s	2$
	move.l	a0,a3
	add.b	d1,d0
	rts
2$:	moveq	#-1,d0
	rts


	cnop	0,4
GetCpOper:
; wie GetOperand. Der Opcode benoetigt allerdings ein Extension-Word.
; PC und ListFileOff werden deshalb erst angepasst.
	addq.l	#2,d6
	addq.w	#5,ListFileOff(a5)
	nop
	ENDC

GetOperand:
; d0 = MSW: erlaubte Adr.arten (Op1) , erlaubte Adr.arten (Op2)
; d1 = MSW: erlaubte Adr.arten (Op3)
;      LSW: Bit 15 = Test for USP,SR,CCR  |  Bit7-5 = Op1-3 Ignore
; d6 = ProgramCounter
; a3 = OperandBuffer
; -> a3 = FirstOperand, a2 = SecondOpernad, a1 = ThirdOperand
	movem.l	d4/d7,-(sp)
	move.l	d0,d5			; d5 = erlaubte Adr.arten fuer Op1 und Op2
	move.l	d1,d7			; d7 = erlaubte Adr.arten Op3 und Flags
	bsr	SplitOperand
GetSplittedOper:
; d5 = MSW: erlaubte Adr.arten (Op1) , erlaubte Adr.arten (Op2)
; d7 = MSW: erlaubte Adr.arten (Op3)
;      LSW: Bit 15 = Test for USP,SR,CCR  |  Bit7-5 = Op1-3 Ignore
; a3..a1 = Oper1,..Oper3
	movem.l	a1-a3,-(sp)
	addq.l	#2,d6			; PC auf ersten Operanden-adresse
	st	RefFlag(a5)		; Referenzen ab jetzt vermerken
	clr.w	oper1+opType1(a5)	; Alle Operanden-Typen auf normal setzen
	clr.w	oper2+opType1(a5)
	IFND	SMALLASS
	clr.w	oper3+opType1(a5)
	ENDC
	swap	d5
	add.b	d7,d7
	bcs.s	1$
	lea	oper1(a5),a2
	bsr.s	ProcessOperand
	bne.s	6$
	btst	d1,d5
	beq.s	5$
1$:	addq.b	#1,TryPC(a5)		; Durch TryPC = -2 lassen sich auch Ziel-
	swap	d5			;  operanden nach (PC) optimieren!
	add.b	d7,d7
	bcs.s	2$
	move.l	4(sp),a3
	lea	oper2(a5),a2
	bsr.s	ProcessOperand
	bne.s	6$
	btst	d1,d5
	beq.s	5$
2$:
	IFND	SMALLASS
	add.b	d7,d7
	bcs.s	3$
	clr.b	TryPC(a5)
	move.l	(sp),a3
	lea	oper3(a5),a2
	bsr.s	ProcessOperand
	bne.s	6$
	swap	d7
	btst	d1,d7
	beq.s	5$
	ENDC
3$:	moveq	#0,d0
4$:	movem.l	(sp)+,a1-a3
	movem.l	(sp)+,d4/d7
	rts
5$:	moveq	#34,d0			; Addressing mode not supported
6$:	bsr	Error
	moveq	#-1,d0
	bra.s	4$


	cnop	0,4
ProcessOperand:
; a2 = operN struct-Pointer
; a3 = Operand-Part
; d6 = PrgCounter
; -> Z-Flag (d0) = no error
; -> d1 = EA-Mode
	moveq	#0,d4			; noch keinen Ausdruck gelesen
	move.l	a2,a0
	clr.l	(a0)+			; Operanden-Struktur initialisieren
	clr.l	(a0)+
	clr.l	(a0)
	move.b	(a3),d0
	beq.s	11$			; gar kein Operand da?
	sub.b	#'#',d0			; Immediate?
	bne	proc_checkpredec
	lea	1(a3),a0
	move.b	OpcodeSize(a5),d4
	ext.w	d4
	moveq	#-1,d0
	bsr	GetValue
	move.l	d0,opVal1(a2)
	tst.b	(a0)
	bne.s	12$
14$:	tst.w	d2
	bmi.s	13$
	bne.s	2$
	swap	d2
	move.b	d2,opInfo1(a2)		; XREF, NREF oder Absolute
	bra	7$
11$:	moveq	#94,d0			; Missing Operand
	rts
12$:	cmp.b	#'{',(a0)
	beq.s	14$
	moveq	#41,d0			; Syntax Error
	rts
13$:	moveq	#36,d0			; Undefined Symbol
	rts
2$:	tst.b	d2
	bpl.s	6$
	cmp.b	#os_LONG,d4		; Programmadr. MUSS Long sein
	bne	proc_relocerr
	move.w	ListFileOff(a5),d2
	swap	d2			; Relocation setzen, falls Objectfile
	move.b	d2,opInfo1(a2)
	addq.b	#1,opInfo1(a2)
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	3$
	ENDC
	move.l	d0,d3
	move.l	d6,d0
	move.w	d2,d1
	bsr	AddRelocation
	move.l	d3,d0
3$:	cmp.w	SecNum(a5),d2
	bne.s	4$
	subq.b	#1,opType1(a2)		; nur korrigieren, wenn aus dieser Section
4$:	moveq	#0,d1			; 0-Distanz
	move.l	d6,a1
	moveq	#os_LONG,d3
	bsr	AddDistance
	bra.s	10$
6$:	subq.b	#8,opInfo1(a2)
	move.w	ListFileOff(a5),d2
	move.l	d6,a1			; Distanz setzen
	moveq	#0,d3
	move.b	d4,d3
	bne.s	1$
	addq.l	#1,a1			; Bei .b steht der Wert im LoByte
	addq.w	#2,d2
1$:	swap	d2
	bsr	AddDistance
	move.l	d1,opVal1(a2)
	addq.b	#1,opType1(a2)
	tst.b	DistChkDisable(a5)
	bne.s	10$
7$:	move.b	d4,d3
	subq.b	#os_LONG,d3
	bpl.s	10$			; Byte- und Word-Immediates die Range prüfen
	tst.l	d0
	bpl.s	8$
	not.l	d0
	add.l	d0,d0
8$:	addq.b	#1,d3
	beq.s	9$
	st	opImmedByte(a2)
	clr.b	d0			; Byte-Range?
	tst.l	d0
	beq.s	10$
	bra.s	99$
9$:	swap	d0			; Word-Range?
	tst.w	d0
	beq.s	10$
99$:	bsr	ImmedSize		; Immediate operand size error
10$:	add.w	d4,d4
	add.w	d4,d4
	movem.w	20$(pc,d4.w),d0-d1	; ListFileOff und opSize lesen
	add.w	d0,ListFileOff(a5)
	move.b	d1,opSize1(a2)
	add.w	d1,d1
	add.l	d1,d6			; PC weitersetzen
	move.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),opMode(a2)
	moveq	#ea_Immediate,d1
	moveq	#0,d0
	rts
20$:	dc.w	5,1			; Byte
	dc.w	5,1			; Word
	dc.w	9,2			; Long
	IFND	SMALLASS
	dc.w	9,2			; FastFloatingPoint
	dc.w	9,2			; SinglePrecision
	dc.w	17,4			; DoublePrecision
	dc.w	25,6			; ExtendedPrecision
	dc.w	25,6			; PackedBCD
	dc.w	17,4			; QuadWord
	ENDC

proc_checkpredec:
	subq.b	#5,d0			; '(' Klammerterm?
	beq	proc_xpar
	subq.b	#5,d0			; '-' Operand beginnt mit Minuszeichen?
	beq.s	2$

	move.l	a3,a0			; Dn oder An direct?
	bsr	GetRegister
	bmi.s	4$
	move.b	(a0),d1
	bne.s	30$
20$:	clr.b	opMode(a2)		; DReg-Direct
	moveq	#ea_Ddirect,d1
	bclr	#3,d0
	beq.s	3$
	addq.b	#1,opMode(a2)		; AReg-Direct
	moveq	#ea_Adirect,d1
3$:	move.b	d0,opReg(a2)
	moveq	#0,d0
	rts
30$:	cmp.b	#'{',d1
	beq.s	20$
	moveq	#41,d0			; syntax error
	rts

1$:	moveq	#39,d0			; Need address register
	rts
11$:	cmp.b	#'{',d1
	beq.s	12$
10$:	moveq	#41,d0			; syntax error
	rts
2$:	cmp.b	#'(',1(a3)		; kein -( . Dann muss es ein Ausdruck sein
	bne.s	5$
	lea	2(a3),a0		; -(An ?
	bsr	GetRegister
	bmi.s	5$			; -(expr... ueberspringen
	subq.w	#8,d0
	bmi.s	1$			; -(Dn  gibt's nicht!
	cmp.b	#')',(a0)+
	bne.s	10$
	move.b	(a0),d1
	bne.s	11$
12$:	move.b	d0,opReg(a2)
	moveq	#ea_AindPreDec,d1
	move.b	d1,opMode(a2)
	moveq	#0,d0
	rts

4$:	tst.w	d7
	bpl.s	5$			; nicht nach USP,CCR,SR pruefen?
	move.b	#ea_SpecialMode,opMode(a2)
	move.l	a3,a0
	lea	adrmod_USP(pc),a1	; USP ?
	bsr	UCaseStrCmp
	bne.s	41$
	moveq	#ea_USP&7,d1
40$:	move.b	d1,opReg(a2)
	addq.b	#8,d1
	moveq	#0,d0
	rts
41$:	move.l	a3,a0
	lea	adrmod_CCR(pc),a1	; CCR ?
	bsr	UCaseStrCmp
	bne.s	42$
	clr.b	OpcodeSize(a5)		; os_BYTE (fuer CCR)
	moveq	#ea_SR&7,d1
	bra.s	40$
42$:	move.l	a3,a0
	lea	adrmod_SR(pc),a1	; SR ?
	bsr	UCaseStrCmp
	bne.s	5$
	move.b	#os_WORD,OpcodeSize(a5)	; os_WORD (fuer SR)
	moveq	#ea_SR&7,d1
	bra.s	40$

5$:	move.l	a3,d4
proc_skipexpr:
	bsr	ToLastTerm		; zum letzten Term springen (falls vorhanden)
	bne	proc_parenth
	cmp.b	#'.',-3(a3)
	bne.s	proc_AbsLong
	moveq	#-$21,d0
	and.b	-2(a3),d0
	cmp.b	#'W',d0			; Absolute Short?
	beq.s	1$
	cmp.b	#'L',d0
	bne.s	proc_AbsLong
	bra.s	proc_AbsLong0

1$:	clr.b	-3(a3)			; Extension von der Expression abtrennen
	move.l	d4,a0
	moveq	#os_WORD,d0		; xx.W  Absolute-Short
	bsr	GetValue
	tst.b	(a0)
	bne	6$
5$:	tst.w	d2
	bmi.s	proc_undefsym
	IFND	FREEASS
	beq.s	2$
	tst.b	AbsCode(a5)		; Im Objectfile-Mode (relocatable) kann
	beq.s	proc_relocerr		;  AbsShort kein Reloc-Symbol enthalten
	tst.b	d2			; Differenz kann keine Adresse sein
	bpl.s	proc_noaddr
	move.w	ListFileOff(a5),d2
	swap	d2
	move.b	d2,opInfo1(a2)
	addq.b	#1,opInfo1(a2)
	cmp.w	SecNum(a5),d2
	bne.s	4$
	subq.b	#1,opType1(a2)		; Adr. aus dieser Section korrigieren
4$:	moveq	#0,d1
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	ELSE
	bne.s	proc_relocerr
	ENDC
2$:	move.l	d0,opVal1(a2)
	bpl.s	3$
	not.l	d0
3$:	cmp.l	#$7fff,d0		; Adresse im Word-Bereich (-$8000 .. $7fff) ?
	bls.s	proc_short
	moveq	#68,d0			; Out of range
	rts
6$:	cmp.b	#'{',(a0)
	beq	5$
	bra	proc_syntax
proc_short:
	addq.w	#5,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
	move.w	#(ea_SpecialMode<<8)+(ea_AbsShort&7),opMode(a2)
	moveq	#ea_AbsShort,d1
	moveq	#0,d0
	rts
proc_noaddr:
	moveq	#45,d0			; Valid address expected
	rts
proc_undefsym:
	moveq	#36,d0			; Undefined symbol
	rts
proc_relocerr:				; Reloc error
	moveq	#42,d0
	rts

proc_syntaxcheck:
	cmp.b	#'{',(a0)
	beq.s	proc_valgot
	bra	proc_syntax
proc_AbsLong0:
	clr.b	-3(a3)			; Extension von der Expression abtrennen
proc_AbsLong:				; xxxx.L  Absolute-Long
	move.l	d4,a0
	moveq	#os_LONG,d0
	bsr	GetValue
	move.l	d0,opVal1(a2)
	tst.b	(a0)
	bne.s	proc_syntaxcheck
proc_valgot:
	tst.w	d2
	bmi.s	proc_undefsym
	bne.s	6$			; Programm-Adresse ?
	swap	d2
	move.b	d2,opInfo1(a2)
	addq.w	#1,d2
	bmi	43$			; NREF
	bne.s	7$
	bra	1$			; XREF
7$:	btst	#of_Normal,OptFlag(a5)
	beq	1$
	bsr	WordLimits		; AbsLong wuerde auch in AbsShort passen?
	bne	1$
	moveq	#-2,d0
	move.l	d6,a0
	addq.l	#2,a0
	bsr	ShiftRelocs		; das bringt 2 Bytes
	bra.s	proc_short
6$:	tst.b	d2			; Differenz kann keine Adresse sein
	bpl.s	proc_noaddr
	move.w	ListFileOff(a5),d2
	swap	d2
	move.b	d2,opInfo1(a2)
	addq.b	#1,opInfo1(a2)
	cmp.w	SecNum(a5),d2
	bne.s	5$
	subq.b	#1,opType1(a2)		; Adr. aus dieser Section korrigieren
5$:	tst.b	Model(a5)
	bmi	4$			; NEAR-Data Model ?
	bsr	GetSectionPtr		; Zeiger auf Section Nummer d2 holen
	tst.b	sec_Near(a0)		; ist diese NEAR zu adressieren?
	beq	4$
	move.l	d0,d1
	sub.l	sec_Origin(a0),d1	; Offset auf Section-BaseAddress
	swap	d1
	tst.w	d1			; Adresse im Near-Bereich ?
	bne	4$			;  wenn nicht: PC-Displace versuchen
	move.l	sec_Origin(a0),d1
	move.l	d2,-(sp)
	moveq	#-$80,d3		; Subtrahend static (nicht verschiebbar)
	swap	d3
	move.w	#os_NEARWORD,d3
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	45$
	addq.l	#4,sp			; SecNum fuer NearReloc nicht benoetigt
	add.l	#$7ffe,d1
	move.w	#os_WORD,d3
	ENDC
45$:	move.l	d6,a1
	bsr	AddDistance		; Near-Adressierung als Distanz merken
	neg.b	opType1(a2)
	beq.s	42$
	move.l	d1,opVal1(a2)
	bra.s	46$
42$:	move.w	d0,opVal1+2(a2)
46$:
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	43$
	ENDC
	move.l	d6,d0
	move.l	(sp)+,d1
	bsr	AddNearReloc
43$:	addq.l	#2,d6
	move.l	d6,a0
	moveq	#-2,d0			; Code wird dadurch um 2 Bytes kuerzer
	bsr	ShiftRelocs
	addq.w	#5,ListFileOff(a5)
	addq.b	#1,opSize1(a2)
	move.w	#ea_AindDispl<<8,d0
	move.b	Model(a5),d0
	move.w	d0,opMode(a2)
	moveq	#ea_AindDispl,d1
	moveq	#0,d0
	rts
4$:	btst	#of_Relative,OptFlag(a5)
	beq.s	3$
	tst.b	TryPC(a5)		; Umwandlung AbsLong->PCdispl erlaubt ?
	bpl.s	3$
	tst.b	opType1(a2)		; und AbsLong liegt in dieser Section
	bpl.s	3$
	move.l	d0,d3
	sub.l	d6,d3			; Distanz-Wert auf Word-Grenzen checken
	move.l	#$7fff,d1
	cmp.l	d1,d3
	bgt.s	3$
	not.l	d1
	cmp.l	d1,d3
	blt.s	3$
	move.b	#1,opType1(a2)
	move.l	d6,a1			; WORD-Distance in DList aufnehmen
	move.l	d6,d1
	moveq	#os_WORD,d3
	bsr	AddDistance
	move.l	d1,opVal1(a2)		; Zeiger auf Distance-Entry
	addq.l	#2,d6
	move.l	d6,a0
	moveq	#-2,d0			; 2 Bytes gewonnen
	bsr	ShiftRelocs
	addq.w	#5,ListFileOff(a5)
	addq.b	#1,opSize1(a2)
	move.w	#(ea_SpecialMode<<8)+(ea_PCdisplace&7),opMode(a2)
	moveq	#ea_PCdisplace,d1
	moveq	#0,d0
	rts
3$:
	IFND	FREEASS
	tst.b	AbsCode(a5)		; Im Objectfile-Mode in Reloc32 aufnehmen
	bne.s	2$
	ENDC
	move.l	d0,d3
	move.l	d6,d0			; RelocAddr
	move.w	d2,d1			; BaseHunk
	bsr	AddRelocation
	move.l	d3,d0
2$:	moveq	#0,d1
	moveq	#os_LONG,d3		; In DistanceList aufnehmen
	move.l	d6,a1
	bsr	AddDistance
1$:	add.w	#9,ListFileOff(a5)
	addq.l	#4,d6
	addq.b	#2,opSize1(a2)
	move.w	#(ea_SpecialMode<<8)+(ea_AbsLong&7),opMode(a2)
	moveq	#ea_AbsLong,d1
	moveq	#0,d0
	rts

proc_xpar:
	addq.l	#1,a3
proc_parenth:
	; (... Klammerterm untersuchen
	IFND	SMALLASS
	move.b	Machine(a5),d2
	ENDC
	move.l	a3,a0
	bsr	GetRegister		; (Rn ?
	IFD	SMALLASS
	bpl.s	2$
	ELSE
	bmi.s	3$
	st	-1(a3)
	subq.b	#2,d2			; 68020?
	blo.s	2$
	subq.b	#8,d0
	bmi.s	1$			; (Dn ?
	moveq	#-'*',d1
	add.b	(a0),d1			; (An* ?
	beq.s	1$
	subq.b	#4,d1			; (An. ?
	bne.s	20$
1$:	addq.b	#8,d0			; (ZA0,Rn ..
	bra	proc_ZA0020
	ENDC
3$:	bsr	CheckPC
	IFND	SMALLASS
	bmi.s	4$
	ELSE
	bmi.s	5$
	ENDC
	beq	proc_pc
	IFND	SMALLASS
	subq.b	#2,d2			; 68020?
	bhs	proc_ZPC020		; (ZPC - Zero-PC mode
	ENDC
	bra	proc_notimpl
	IFND	SMALLASS
4$:	subq.b	#2,d2
	blo.s	5$
	cmp.b	#'[',(a3)		; ([  kann 68020 Memory-Indirect anzeigen
	beq	proc_memindir020
	bsr	GetZReg
	bmi.s	5$
	st	-1(a3)
	subq.b	#8,d0
	bmi.s	41$
	moveq	#-'*',d1
	add.b	(a0),d1			; (ZAn* ?
	beq.s	41$
	subq.b	#4,d1			; (ZAn. ?
	bne	proc_ZAn020		; (ZAn - Zero Base Register mode
41$:	addq.b	#8,d0			; (ZA0,ZRn ..
	bra	proc_ZA0Zindex
	ENDC

2$:
	IFD	SMALLASS
	st	-1(a3)
	ENDC
	subq.b	#8,d0			; (Dn,.. gibt's nicht bei 68000,68010
	bmi.s	proc_notimpl
20$:	move.l	a0,a3
	move.b	d0,opReg(a2)
	bra.s	proc_chkindex

5$:	tst.l	d4
	beq.s	50$			; expr(expr... müsste absolute sein
	addq.l	#1,a3
	bra	proc_skipexpr
50$:	moveq	#'(',d1
	moveq	#1,d2
	move.l	a3,d4
6$:	move.b	(a3)+,d0		; Ausdruck bis zu ')' oder ',' ueberlesen
	beq.s	proc_syntax		; Klammer-zu fehlt!
	sub.b	d1,d0
	bne.s	61$
	addq.w	#1,d2			; '(' - noch eine Klammerebene
	bra.s	6$
61$:	subq.b	#1,d0			; ')' - zum letzten Term springen?
	bne.s	62$
	subq.w	#1,d2
	bne.s	6$
	subq.l	#1,d4
	bra	proc_skipexpr
62$:	subq.b	#3,d0			; ',' - Indirekter Adressierungsmodus
	bne.s	6$
	bra	proc_parenth		; Zeichen nach "(expr," behandeln
proc_notimpl:
	moveq	#92,d0			; Instruction not implemented
	rts
proc_syntax:
	moveq	#41,d0			; Syntax error
	rts

proc_chkindex:				; "(An" oder "(expr,An" oder "expr(An"
	move.b	(a3)+,d0
	sub.b	#')',d0
	beq.s	1$
	subq.b	#3,d0			; ','
	beq	proc_indexed
	bra.s	proc_syntax
1$:	tst.l	d4
	bne.s	proc_chkdispl

	moveq	#ea_Aind,d1
	move.b	(a3),d0
	beq.s	2$
	cmp.b	#'+',d0			; (An) oder (An)+ ?
	bne.s	3$
	moveq	#ea_AindPostInc,d1
2$:	move.b	d1,opMode(a2)
	moveq	#0,d0
	rts
3$:
	IFND	SMALLASS
	cmp.b	#'{',d0			; (An){...} ist auch möglich
	beq.s	2$
	ENDC
	bra.s	proc_syntax

proc_chkdispl2:
	IFND	SMALLASS
	cmp.b	#'{',d0			; d16(An){...} ist auch möglich
	beq.s	proc_displace
	ENDC
	bra.s	proc_syntax
proc_chkdispl:
	move.b	(a3),d0
	bne.s	proc_chkdispl2
proc_displace:				; d16(An)
	move.l	d4,a0
	moveq	#os_WORD,d0
	bsr	GetValue
	move.l	a0,a3
	moveq	#0,d3
	move.l	d0,opVal1(a2)
	tst.w	d2
	bmi	proc_undefsym
	beq.s	1$			; kein Reloc-Symbol enthalten ?
	tst.b	d2
	bmi.s	proc_chknear
	subq.b	#8,opInfo1(a2)		; Distanzen nicht wegoptimieren!
	move.w	ListFileOff(a5),d2
	swap	d2
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	move.l	d1,opVal1(a2)
	addq.b	#1,opType1(a2)
1$:	cmp.b	#'.',(a3)		; .W/.L fuehrt immer zu (bd,An,ZRn)
	beq	proc_absbd
	bsr	WordLimits		; Distanz passt in 16 Bit?
	bne	proc_absbd
	swap	d2
	addq.w	#1,d2			; XREF?
	beq.s	d16_xref
	btst	#of_Normal,OptFlag(a5)
	beq.s	d16_exit
	tst.w	d0
	bne.s	d16_exit		; wenn d=0 ist, wird d(An) zu (An) optimiert
	tst.w	d3			; schon in DistList aufgenommen => keine Opt.
	bne.s	d16_exit
proc_Opt2Aind:
	move.l	d6,a0
	moveq	#-2,d0			; Code wird dadurch um 2 Bytes kuerzer
	bsr	ShiftRelocs
	moveq	#ea_Aind,d1
	move.b	d1,opMode(a2)
	moveq	#0,d0
	rts
d16_xref:
	move.b	Model(a5),d0
	bmi.s	d16_exit		; NEAR-Data Model aktiv?
	cmp.b	opReg(a2),d0		; mit richtigem Near-Register?
	bne.s	d16_exit
	move.w	#EXT_DEXT16,d0		; Dann muesste es eigentl. eine NearRef. sein
	moveq	#0,d1
	bsr	ChangeLastRefs
d16_exit:
	addq.w	#5,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
	moveq	#ea_AindDispl,d1
	move.b	d1,opMode(a2)
	moveq	#0,d0
	rts

nearoutofrange:
	dc.b	"(<near>,An) out of range",0
	cnop	0,4

proc_chknear:				; (relocAddr,An) in Near-Section?
	move.w	ListFileOff(a5),d2
	swap	d2
	move.b	d2,opInfo1(a2)
	addq.b	#1,opInfo1(a2)
	cmp.w	SecNum(a5),d2
	bne.s	1$
	subq.b	#1,opType1(a2)		; Adr. aus dieser Section korrigieren
1$:	move.b	Model(a5),d1
	bmi	10$			; NEAR-Data Model aktiv?
	cmp.b	opReg(a2),d1		; mit richtigem Near-Register?
	bne	10$
	bsr	GetSectionPtr		; Zeiger auf Section Nummer d2 holen
	tst.b	sec_Near(a0)		; ist diese NEAR zu adressieren?
	beq	10$
	move.l	d0,d1
	sub.l	sec_Origin(a0),d1	; Offset auf Section-BaseAddress
	swap	d1
	tst.w	d1			; Adresse im Near-Bereich ?
	bne.s	9$			;  wenn nicht: (bd,An) versuchen
	move.l	sec_Origin(a0),d1
	move.l	d2,-(sp)
	moveq	#-$80,d3		; Subtrahend static (nicht verschiebbar)
	swap	d3
	move.w	#os_NEARWORD,d3
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	4$
	addq.l	#4,sp			; SecNum fuer NearReloc nicht benoetigt
	add.l	#$7ffe,d1
	move.w	#os_WORD,d3
	ENDC
4$:	move.l	d6,a1
	bsr	AddDistance		; Near-Adressierung als Distanz merken
	neg.b	opType1(a2)
	beq.s	5$
	move.l	d1,opVal1(a2)
	bra.s	6$
5$:	move.w	d0,opVal1+2(a2)
6$:
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	7$
	ENDC
	move.l	d6,d0
	move.l	(sp)+,d1
	bsr	AddNearReloc
7$:	addq.l	#2,d6
	addq.w	#5,ListFileOff(a5)
	addq.b	#1,opSize1(a2)
	moveq	#ea_AindDispl,d1
	move.b	d1,opMode(a2)
	moveq	#0,d0
	rts
9$:					; Adresse außerhalb Near-Bereich
	cmp.b	#2,Machine(a5)
	blo.s	proc_relocbd
	lea	nearoutofrange(pc),a1
	bsr	Warning
	bra.s	proc_relocbd

10$:					; check BASEREG addressing mode
	move.b	BaseRegNo(a5),d1	; BASEREG aktiv?
	bmi.s	proc_relocbd
	cmp.b	opReg(a2),d1		; mit richtigem Base-Register?
	bne.s	proc_relocbd
	cmp.b	BaseSecNo(a5),d2	; Ref. auf Sym. aus BaseReg-Section?
	bne.s	proc_relocbd
	move.l	d0,d1
	sub.l	BaseSecOffset(a5),d1
	cmp.l	#$7fff,d1		; Adresse im 16Bit-Bereich ?
	bgt.s	9$
	cmp.l	#-$8000,d1
	blt.s	9$
	move.l	BaseSecOffset(a5),d1
	moveq	#-$80,d3		; Subtrahend static (nicht verschiebbar)
	swap	d3
	move.w	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	neg.b	opType1(a2)
	beq.s	11$
	move.l	d1,opVal1(a2)
	bra	7$
11$:	move.w	d0,opVal1+2(a2)
	bra	7$

proc_relocbd:			; (bd,An) mit 32-bit BaseDisplacement (68020)
	addq.l	#2,d6			; Format-Word
	swap	d2
	addq.w	#5,d2
	swap	d2			; Relocation setzen, falls Objectfile
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	1$
	ENDC
	move.l	d0,d3
	move.l	d6,d0
	move.w	d2,d1
	bsr	AddRelocation
	move.l	d3,d0
1$:	moveq	#0,d1			; 0-Distanz
	move.l	d6,a1
	moveq	#os_LONG,d3
	bsr	AddDistance
	bsr	CheckSize
	move.b	d1,d4
	bra.s	proc_abslongbd
proc_absbd:
	addq.l	#2,d6			; Format-Word
	tst.b	opType1(a2)		; Distance?
	beq.s	2$
	move.l	LastDistance(a5),a0	; Longword-Distance
	addq.l	#2,dist_Addr-dist_HEAD(a0)
	IFND	FREEASS
	tst.l	dist_ListFilePointer-dist_HEAD(a0)
	beq.s	1$
	addq.l	#5,dist_ListFilePointer-dist_HEAD(a0) ; ListFilePointer
	ENDC
1$:	bsr	CheckSize
	move.b	d1,d4
	beq.s	4$
	bmi.s	4$			; long BD ?
	bra.s	3$
2$:	bsr	CheckSize
	move.b	d1,d4
	beq.s	proc_abslongbd
	bmi.s	proc_abslongbd
3$:	moveq	#EXT_REF16,d0
	moveq	#2,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	5$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#2,d0			; Code wird um 2 Bytes laenger
	bsr	ShiftRelocsNoOpt
5$:	move.w	#$0160,d3		; Word-Basedisplacement
	moveq	#1,d0
	moveq	#10,d1
	bra.s	proc_anbd
4$:	addq.b	#1,dist_Width-dist_HEAD(a0) ; os_LONG Distance
proc_abslongbd:
	moveq	#EXT_REF32,d0
	moveq	#2,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	1$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#4,d0			; Code wird um 4 Bytes laenger
	bsr	ShiftRelocsNoOpt
1$:	move.w	#$0170,d3		; Long-Basedisplacement
	moveq	#2,d0
	moveq	#14,d1
proc_anbd:
	move.w	d3,opFormat(a2)
	add.w	d1,ListFileOff(a5)
	add.l	d0,d6
	add.l	d0,d6
	move.b	d0,opSize1(a2)
	moveq	#ea_AindIndex,d1
	move.b	d1,opMode(a2)
	cmp.b	#2,Machine(a5)
	blo.s	proc_largedist
	moveq	#0,d0
	rts
proc_largedist:
	tst.b	DistChkDisable(a5)
	beq.s	1$
	moveq	#0,d0			; Distance ignorieren
	rts
1$:	moveq	#43,d0			; Distance too large
	rts
proc_missreg:
	moveq	#37,d0			; Missing register
	rts

proc_indexed:				; ...(An,Rn
	move.l	a3,a0
	bsr	GetRegister
	bpl.s	3$
	IFND	SMALLASS
	tst.b	d2
	bmi.s	1$			; 68020 vorhanden?
	bsr	GetZReg			; (An,ZRn ?
	bmi.s	1$
	btst	#of_Special,OptFlag(a5)
	beq.s	2$
	tst.l	d4
	bne	proc_displace		; (disp,An,ZRn) -> (disp,An) optimieren
	bra	proc_Opt2Aind		; (An,ZRn) -> (An) optimieren
2$:	move.b	#ea_AindIndex,opMode(a2)
	move.w	#$0140,d3		; Index-Suppress (disp,An,ZRn)
	tst.l	d4
	beq	proc_index020
	movem.l	d0/a0,-(sp)
	move.l	d6,a0
	moveq	#4,d0
	bsr	ShiftRelocsNoOpt
	movem.l	(sp)+,d0/a0
	bra	proc_index020
	ENDC
1$:	tst.l	d4
	bne.s	proc_missreg
	move.l	a3,d4			; (An,d) -> (d,An)
	bra	proc_displace
3$:	moveq	#0,d3
	bsr	GetRnFormat
	bne.s	9$
	move.w	d3,opVal1+2(a2)
	cmp.b	#')',(a0)+
	bne.s	15$
	move.b	(a0),d0
	bne.s	14$
13$:	tst.l	d4			; displacement angegeben?
	beq.s	5$
	move.l	d4,a0
	moveq	#os_BYTE,d0
	bsr	GetValue
	move.l	a0,a3
	tst.w	d2
	bmi	proc_undefsym
	beq.s	4$
	tst.b	d2
	bmi.s	proc_relocbdindex	; (bd,An,Rn)
	move.w	ListFileOff(a5),d2
	addq.w	#2,d2
	swap	d2
	moveq	#os_BYTE,d3
	move.l	d6,a1
	addq.l	#1,a1
	bsr	AddDistance
	move.l	d1,opVal2(a2)		; Distancepointer
	addq.b	#2,opType1(a2)		; AindIndex Distance Mode = 2
4$:	cmp.b	#'.',(a3)		; (bd.W/L ?  Fuehrt immer zu (bd,An,Rn)
	beq.s	proc_absbdindex
	moveq	#127,d1			; Distanz-Wert auf Byte-Grenzen checken
	cmp.l	d1,d0
	bgt.s	proc_absbdindex
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	proc_absbdindex
	move.b	d0,opVal1+3(a2)
5$:	addq.w	#5,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
	moveq	#ea_AindIndex,d1
	move.b	d1,opMode(a2)
	moveq	#0,d0
9$:	rts
14$:
	IFND	SMALLASS
	cmp.b	#'{',d0
	beq.s	13$
	ENDC
15$:	moveq	#41,d0			; Syntax Error
	rts

proc_relocbdindex:			; (bd,An,Rn)  mit 16 oder 32 Bit BaseDisp.
	IFND	SMALLASS
	move.l	opVal1(a2),-(sp)
	move.l	d0,opVal1(a2)
	addq.l	#2,d6			; Format-Word
	move.w	ListFileOff(a5),d2
	addq.w	#5,d2
	swap	d2			; Relocation setzen, falls Objectfile
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	1$
	ENDC
	move.l	d0,d3
	move.l	d6,d0
	move.w	d2,d1
	bsr	AddRelocation
	move.l	d3,d0
1$:	cmp.w	SecNum(a5),d2
	bne.s	2$
	subq.b	#1,opType1(a2)		; nur korrigieren, wenn aus dieser Section
2$:	moveq	#0,d1			; 0-Distanz
	move.l	d6,a1
	moveq	#os_LONG,d3
	bsr	AddDistance
	move.l	(sp)+,d3
	bra.s	proc_abslongbdindex
	ENDC
proc_absbdindex:
	IFND	SMALLASS
	addq.l	#2,d6			; Format-Word
	tst.b	opType1(a2)
	beq.s	2$
	subq.b	#1,opType1(a2)		; 16/32-bit Distanz
	move.w	opVal1+2(a2),d3		; Format
	move.l	opVal2(a2),opVal1(a2)	; Distancepointer uebertragen
	move.l	LastDistance(a5),a0
	addq.l	#1,dist_Addr-dist_HEAD(a0)
	tst.l	dist_ListFilePointer-dist_HEAD(a0)
	beq.s	4$
	addq.l	#3,dist_ListFilePointer-dist_HEAD(a0) ; ListFilePointer
4$:	bsr	CheckSize		; .W / .L ?
	move.b	d1,d4
	beq.s	5$
	bmi.s	1$
	bra.s	6$
5$:	bsr	WordLimits
	bne.s	1$
6$:	addq.b	#1,dist_Width-dist_HEAD(a0) ; os_WORD
	bra.s	3$
1$:	addq.b	#2,dist_Width-dist_HEAD(a0) ; os_LONG
	bra.s	proc_abslongbdindex
2$:	move.w	opVal1+2(a2),d3
	move.l	d0,opVal1(a2)
	bsr	CheckSize		; .W / .L ?
	move.b	d1,d4
	beq.s	7$
	bmi.s	proc_abslongbdindex
	bra.s	3$
7$:	bsr	WordLimits
	bne.s	proc_abslongbdindex
3$:	moveq	#EXT_REF16,d0
	moveq	#1,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	8$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#2,d0			; Code wird um 2 Bytes laenger
	bsr	ShiftRelocsNoOpt
8$:	or.w	#$0120,d3		; Word-Basedisplacement
	moveq	#1,d0
	moveq	#10,d1
	bra.s	proc_bdindex
	ENDC
proc_abslongbdindex:
	IFND	SMALLASS
	moveq	#EXT_REF32,d0
	moveq	#1,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	1$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#4,d0			; Code wird um 4 Bytes laenger
	bsr	ShiftRelocsNoOpt
1$:	or.w	#$0130,d3		; Long-Basedisplacement
	moveq	#2,d0
	moveq	#14,d1
	ENDC
proc_bdindex:
	IFND	SMALLASS
	move.w	d3,opFormat(a2)
	add.w	d1,ListFileOff(a5)
	add.l	d0,d6
	add.l	d0,d6
	move.b	d0,opSize1(a2)
	moveq	#ea_AindIndex,d1
	move.b	d1,opMode(a2)
	cmp.b	#2,Machine(a5)
	blo	proc_largedist
	moveq	#0,d0
	rts
	ELSE
	bra	proc_largedist
	ENDC

proc_pc:				; expr(PC
	st	-1(a3)
	move.w	#(ea_SpecialMode<<8)+(ea_PCdisplace&7),opMode(a2)
	move.b	(a3)+,d0
	sub.b	#')',d0			; expr(PC) ?
	beq.s	1$
	subq.b	#3,d0
	beq	proc_pcindex		; expr(PC,Rn) ?
	bra.s	3$

2$:
	IFND	SMALLASS
	cmp.b	#'{',d0
	beq.s	proc_pcdisp
	ENDC
3$:	moveq	#41,d0			; Syntax Error
	rts
1$:	move.b	(a3),d0
	bne.s	2$
proc_pcdisp:				; d16(PC) oder (d16,PC)
	tst.l	d4
	bne.s	proc_pcdispok		; kein Displacement angegeben? (=0)
	clr.w	opVal1+2(a2)
	bra.s	pcdisp_exit
proc_pcdispok:
	move.l	d4,a0
	moveq	#os_WORD,d0
	bsr	GetValue
	move.l	a0,a3
	move.l	d0,opVal1(a2)
	tst.w	d2
	bmi	proc_undefsym
	tst.b	d2
	bmi.s	3$
	beq.s	2$
	move.w	ListFileOff(a5),d2	; Distance
	swap	d2
	bra.s	4$
2$:	swap	d2
	addq.w	#1,d2
	bpl.s	5$
	bra	proc_relocerr		; NREF nicht moeglich
3$:	move.w	ListFileOff(a5),d2	; Reloc-Addr
	swap	d2
	cmp.w	SecNum(a5),d2		; muss in aktueller Section liegen
	bne	proc_relocerr
	move.l	d6,d1
4$:	move.l	d6,a1			; Word-Distance in DistanceList aufnehmen
	moveq	#os_WORD,d3
	bsr	AddDistance
	move.l	d1,opVal1(a2)
	addq.b	#1,opType1(a2)
	moveq	#-1,d2
5$:	cmp.b	#'.',(a3)		; .W/.L fuehrt immer zu (bd,PC,ZRn)
	beq.s	6$
	bsr	WordLimits		; Distance passt in 16 Bit?
	beq.s	pcdisp_exit
6$:	tst.w	d2
	bne.s	proc_pcbd
	addq.l	#2,opVal1(a2)		; XREF benötigt +2 wegen Format-Word
	bra.s	proc_pcbd
pcdisp_exit:
	addq.w	#5,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
	moveq	#ea_PCdisplace,d1
	moveq	#0,d0
	rts

proc_pcbd:
	IFND	SMALLASS
	addq.l	#2,d6			; Format-Word
	tst.b	opType1(a2)		; Distance?
	beq.s	2$
	move.l	LastDistance(a5),a0	; Longword-Distance
	addq.l	#2,dist_Addr-dist_HEAD(a0)
	tst.l	dist_ListFilePointer-dist_HEAD(a0)
	beq.s	1$
	addq.l	#5,dist_ListFilePointer-dist_HEAD(a0) ; ListFilePointer
1$:	bsr	CheckSize
	move.b	d1,d4
	beq.s	4$
	bmi.s	4$			; long BD ?
	bra.s	3$
2$:	bsr	CheckSize
	move.b	d1,d4
	beq.s	5$
	bmi.s	5$
3$:	moveq	#EXT_RELREF16,d0
	moveq	#2,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	7$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#2,d0			; Code wird um 2 Bytes laenger
	bsr	ShiftRelocsNoOpt
7$:	move.w	#$0160,d3		; Word-Basedisplacement
	moveq	#1,d0
	moveq	#10,d1
	bra.s	6$
4$:	addq.b	#1,dist_Width-dist_HEAD(a0) ; os_LONG Distance
5$:	moveq	#EXT_RELREF32,d0
	moveq	#2,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	8$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#4,d0			; Code wird um 4 Bytes laenger
	bsr	ShiftRelocsNoOpt
8$:	move.w	#$0170,d3		; Long-Basedisplacement
	moveq	#2,d0
	moveq	#14,d1
6$:	move.w	d3,opFormat(a2)
	add.w	d1,ListFileOff(a5)
	add.l	d0,d6
	add.l	d0,d6
	move.b	d0,opSize1(a2)
	addq.b	#1,opReg(a2)		; PC Indexed Mode
	moveq	#ea_PCindex,d1
	moveq	#0,d0
	cmp.b	#2,Machine(a5)
	blo	proc_largedist
	moveq	#0,d0
	rts
	ELSE
	bra	proc_largedist
	ENDC


proc_pcindex:				; d8(PC,Rn)  oder  (d8,PC,Rn*size)
	move.l	a3,a0
	bsr	GetRegister
	bpl	3$
	IFND	SMALLASS
	subq.b	#2,d2			; 68020?
	blo.s	1$
	bsr	GetZReg			; (PC,ZRn ?
	bmi.s	1$
	btst	#of_Special,OptFlag(a5)
	bne	proc_pcdisp		; (disp,PC,ZRn) -> (disp,PC) optimieren
	move.w	#(ea_SpecialMode<<8)+(ea_PCindex&7),opMode(a2)
	move.w	#$0140,d3
	tst.l	d4			; Index-Suppress (disp,PC,ZRn)
	beq	proc_index020
	move.w	d3,d2
	bsr.s	4$			; Rn-Extension checken (GetRnFormat)
	bne.s	40$
	or.w	d2,opVal1+2(a2)		; Index-Suppressed Mode
	move.l	d4,a0
	moveq	#os_BYTE,d0
	bsr	GetValue
	move.l	a0,a3
	tst.w	d2
	bmi	proc_undefsym
	swap	d2
	move.b	d2,opInfo1(a2)
	swap	d2
	tst.b	d2
	beq	proc_pcbdindex
	bmi.s	10$
	move.w	ListFileOff(a5),d2	; Distance
	addq.w	#2,d2
	swap	d2
	bra.s	11$
10$:	move.w	ListFileOff(a5),d2	; Reloc-Addr
	addq.w	#2,d2
	swap	d2
	cmp.w	SecNum(a5),d2		; muss in aktueller Section liegen
	bne	proc_relocerr
	move.l	d6,d1
11$:	move.l	d6,a1			; Byte-Distance in DistanceList aufnehmen
	addq.l	#1,a1
	moveq	#os_BYTE,d3
	bsr	AddDistance
	move.l	d1,opVal2(a2)		; Distancepointer
	addq.b	#2,opType1(a2)		; AindIndex Distance Mode = 2
	bra	proc_pcbdindex
	ENDC
1$:	tst.l	d4
	bne	proc_missreg
	move.l	a3,d4			; (PC,d) -> (d,PC)
	bra	proc_pcdispok
4$:	moveq	#0,d3			; prüft Syntax von "Rn.size*scale)" | "..){"?
	bsr	GetRnFormat
	bne.s	40$
	move.w	d3,opVal1+2(a2)
	cmp.b	#')',(a0)+
	bne.s	42$
	move.b	(a0),d0
	bne.s	41$
40$:	rts
41$:
	IFND	SMALLASS
	cmp.b	#'{',d0
	beq.s	40$
	ENDC
42$:	moveq	#41,d0			; Syntax Error
	rts
3$:	addq.b	#1,opReg(a2)		; PC-Indexed Mode
	bsr.s	4$			; Rn-Extension checken (GetRnFormat)
	bne.s	40$
	tst.l	d4			; displacement angegeben?
	beq.s	8$
	move.l	d4,a0
	moveq	#os_BYTE,d0
	bsr	GetValue
	move.l	a0,a3
	tst.w	d2
	bmi	proc_undefsym
	tst.b	d2
	beq.s	7$
	bmi.s	5$
	move.w	ListFileOff(a5),d2	; Distance
	addq.w	#2,d2
	swap	d2
	bra.s	6$
5$:	move.w	ListFileOff(a5),d2	; Reloc-Addr
	addq.w	#2,d2
	swap	d2
	cmp.w	SecNum(a5),d2		; muss in aktueller Section liegen
	bne	proc_relocerr
	move.l	d6,d1
6$:	move.b	d2,opInfo1(a2)
	move.l	d6,a1			; Byte-Distance in DistanceList aufnehmen
	addq.l	#1,a1
	moveq	#os_BYTE,d3
	bsr	AddDistance
	move.l	d1,opVal2(a2)		; Distancepointer
	addq.b	#2,opType1(a2)		; AindIndex Distance Mode = 2
	cmp.b	#'.',(a3)
	beq.s	proc_pcbdindex
	moveq	#127,d1			; Distanz-Wert auf Byte-Grenzen checken
	cmp.l	d1,d0
	bgt.s	proc_pcbdindex
	moveq	#-128,d1
	cmp.l	d1,d0
	bge.s	8$
	bra.s	proc_pcbdindex
7$:	swap	d2
	move.b	d2,opInfo1(a2)
	addq.w	#1,d2
	bmi	proc_relocerr		; NREF nicht moeglich
	cmp.b	#'.',(a3)
	beq.s	proc_pcbdindex
	moveq	#127,d1
	cmp.l	d1,d0
	bgt.s	proc_pcbdindex
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	proc_pcbdindex
	move.b	d0,opVal1+3(a2)
8$:	addq.w	#5,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
	moveq	#ea_PCindex,d1
	moveq	#0,d0
	rts


proc_pcbdindex:
	IFND	SMALLASS
	addq.l	#2,d6			; Format-Word
	tst.b	opType1(a2)
	beq.s	2$
	subq.b	#1,opType1(a2)		; 16/32-bit Distanz
	move.w	opVal1+2(a2),d3		; Format
	move.l	opVal2(a2),opVal1(a2)	; Distancepointer uebertragen
	move.l	LastDistance(a5),a0
	addq.l	#1,dist_Addr-dist_HEAD(a0)
	tst.l	dist_ListFilePointer-dist_HEAD(a0)
	beq.s	6$
	addq.l	#3,dist_ListFilePointer-dist_HEAD(a0) ; ListFilePointer
6$:	bsr	CheckSize		; .W / .L ?
	move.b	d1,d4
	beq.s	7$
	bmi.s	1$
	bra.s	8$
7$:	bsr	WordLimits
	bne.s	1$
8$:	addq.b	#1,dist_Width-dist_HEAD(a0) ; os_WORD
	bra.s	3$
1$:	addq.b	#2,dist_Width-dist_HEAD(a0) ; os_LONG
	bra.s	4$
2$:	move.w	opVal1+2(a2),d3
	tst.b	opInfo1(a2)
	bpl.s	12$
	addq.l	#2,d0			; XREF benötigt +2 wegen Format-Word
12$:	move.l	d0,opVal1(a2)
	bsr	CheckSize		; .W / .L ?
	move.b	d1,d4
	beq.s	9$
	bmi.s	4$
	bra.s	3$
9$:	bsr	WordLimits
	bne.s	4$
3$:	moveq	#EXT_RELREF16,d0
	moveq	#1,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	10$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#2,d0			; Code wird um 2 Bytes laenger
	bsr	ShiftRelocsNoOpt
10$:	or.w	#$0120,d3		; Word-Basedisplacement
	moveq	#1,d0
	moveq	#10,d1
	bra.s	5$
4$:	moveq	#EXT_RELREF32,d0
	moveq	#1,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	11$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#4,d0			; Code wird um 4 Bytes laenger
	bsr	ShiftRelocsNoOpt
11$:	or.w	#$0130,d3		; Long-Basedisplacement
	moveq	#2,d0
	moveq	#14,d1
5$:	move.w	d3,opFormat(a2)
	add.w	d1,ListFileOff(a5)
	add.l	d0,d6
	add.l	d0,d6
	move.b	d0,opSize1(a2)
	moveq	#ea_PCindex,d1
	cmp.b	#2,Machine(a5)
	blo	proc_largedist
	moveq	#0,d0
proc_rts:
	rts
	ELSE
	bra	proc_largedist
	ENDC

	IFND	SMALLASS
proc_ZAn020:				; expr(ZAn
	move.b	#ea_AindIndex,opMode(a2)
	move.b	d0,opReg(a2)
	bra.s	proc_getBSindex

proc_ZPC020:				; expr(ZPC
	move.w	#(ea_SpecialMode<<8)+(ea_PCindex&7),opMode(a2)
proc_getBSindex:
	st	-1(a3)
	move.w	#$0180,d3		; BaseReg. (PC) Suppress
	cmp.b	#',',(a3)+		; Index vorhanden?
	bne.s	1$
	move.l	a3,a0
	bsr	GetRegister		; Index lesen
	bpl.s	proc_index020
	or.w	#$0040,d3		; Index Suppress
	bsr	GetZReg			; Zero-Index?
	bpl.s	proc_index020
	bra	proc_missreg
1$:	or.w	#$0040,d3		; Index Suppress
	addq.l	#2,d6
	bra.s	proc_BS020

proc_ZA0Zindex:
	; (expr,ZRn.x*s)
	move.w	#ea_AindIndex<<8,opMode(a2)
	move.w	#$01c0,d3		; Base und Index Suppress
	bra.s	proc_index020

proc_ZA0020:
	; expr(Rn.x*s) bzw. (expr,ZA0,Rn.x*s)
	move.w	#ea_AindIndex<<8,opMode(a2)
	move.w	#$0180,d3		; BaseReg. (An) Suppress

proc_index020:
	addq.l	#2,d6			; FormatWord
	bsr	GetRnFormat
	bne.s	proc_rts
proc_BS020:
	moveq	#$10,d0
	move.w	d3,opFormat(a2)
	tst.l	d4
	bne.s	2$			; noch kein BaseDisplacement gefunden
	move.b	(a0)+,d1
	sub.b	#')',d1
	beq	7$			; Null Basedisplacement
	subq.b	#3,d1
	bne	proc_syntax
	tst.b	d3			; Base Suppressed ?
	bpl	proc_xaddrmode
	move.l	a0,d4			; ([0,ZAn],Rn,disp) -> (disp,ZAn,Rn)
	move.l	d6,a0
	moveq	#4,d0
	bsr	ShiftRelocsNoOpt
	bra.s	3$
2$:	cmp.b	#')',(a0)
	bne	proc_syntax
3$:	move.l	d4,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Basedispl. lesen
	move.l	a0,a3
	move.l	d0,opVal1(a2)
	tst.w	d2
	bmi	proc_undefsym
	beq.s	5$
	tst.b	d2
	bpl.s	4$
	move.w	ListFileOff(a5),d2
	addq.w	#5,d2
	swap	d2			; Relocation setzen, falls Objectfile
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	31$
	ENDC
	move.l	d0,d3
	move.l	d6,d0
	move.w	d2,d1
	bsr	AddRelocation
	move.l	d3,d0
31$:	cmp.w	SecNum(a5),d2
	bne.s	32$
	subq.b	#1,opType1(a2)		; nur korrigieren, wenn aus dieser Section
32$:	moveq	#0,d1			; 0-Distanz
	move.l	d6,a1
	moveq	#os_LONG,d3
	bsr	AddDistance
	moveq	#$30,d0			; Long Basedisplacement
	moveq	#14,d1
	bra.s	6$
4$:	move.w	ListFileOff(a5),d2
	addq.w	#5,d2
	swap	d2
	move.l	d0,a1
	move.l	d1,d3
	sub.l	d1,d0
	bsr	CheckSize		; .W / .L ?
	move.b	d1,d4
	beq.s	40$
	bmi.s	42$
	bra.s	41$
40$:	bsr	WordLimits
	bne.s	42$
41$:	move.l	a1,d0			; Distanz passt in Word-BD
	move.l	d3,d1
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	move.l	d1,opVal1(a2)
	addq.b	#1,opType1(a2)
	bra.s	50$
42$:	move.l	a1,d0			; Distanz muss in Long-BD
	move.l	d3,d1
	moveq	#os_LONG,d3
	move.l	d6,a1
	bsr	AddDistance
	move.l	d1,opVal1(a2)
	addq.b	#1,opType1(a2)
	bra.s	51$
5$:	bsr	CheckSize		; .W / .L
	move.b	d1,d4
	beq.s	52$
	bmi.s	51$
	bra.s	50$
52$:	bsr	WordLimits		; Absolute-BD passt in Word?
	bne.s	51$
50$:	moveq	#EXT_REF16,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	tst.b	d4
	bne.s	53$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#2,d0			; Code wird um 2 Bytes laenger
	bsr	ShiftRelocsNoOpt
53$:	moveq	#$20,d0
	moveq	#10,d1
	bra.s	6$
51$:	tst.b	d4
	bne.s	54$			; Code-Länge war bekannt?
	move.l	d6,a0
	moveq	#4,d0			; Code wird um 4 Bytes laenger
	bsr	ShiftRelocsNoOpt
54$:	moveq	#$30,d0
	moveq	#14,d1
6$:	add.w	d1,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
	cmp.b	#$20,d0
	beq.s	7$
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
7$:	or.w	d0,opFormat(a2)
	moveq	#ea_SpecialMode,d0
	cmp.b	opMode(a2),d0		; Adressreg. oder PC indexed ?
	bne.s	9$
	moveq	#ea_PCindex,d1
	moveq	#0,d0
	rts
9$:	moveq	#ea_AindIndex,d1
	moveq	#0,d0
	rts
proc_xaddrmode:
	moveq	#33,d0			; Unknown addressing mode
	rts

proc_memindir020:			; 68020 FullFormat - Memory Indirection
	move.l	d4,EarlyOD(a5)		; expr([...]) bzw. (expr,[...])
	moveq	#0,d4			;  wird als OuterDisp. anerkannt
	addq.l	#1,a3
	move.b	#ea_AindIndex,opMode(a2)
	move.w	#$0100,d3		; FullFormat
	addq.l	#2,d6
	addq.w	#5,ListFileOff(a5)
1$:	move.l	a3,a0			; Testen ob BaseDisplacement fehlt
	bsr	GetRegister
	bpl.s	10$			; An
	bsr	CheckPC
	bmi.s	3$
	beq.s	2$			; PC
	or.w	#$0080,d3		; ZPC - BaseReg. Suppress
2$:	move.w	#(ea_SpecialMode<<8)+(ea_PCindex&7),opMode(a2)
	bra.s	15$
3$:	bsr	GetZReg
	bmi.s	40$			; ZAn oder ZDn ?
	or.w	#$00c0,d3		; Base und Index-Suppress annehmen
	subq.b	#8,d0
	bmi.s	11$			; ZA0, ZRn - Base und Index Suppress
	moveq	#-'*',d1
	add.b	(a0),d1			; (ZAn* ?
	beq.s	11$
	subq.b	#4,d1			; (ZAn. ?
	beq.s	11$
	and.w	#$ffbf,d3		; bisher noch kein Index-Suppress
	bra.s	14$
40$:	move.l	a3,d4			; d4 = Zeiger auf BaseDisplacement
	moveq	#'[',d1
	moveq	#1,d2
4$:	move.b	(a3)+,d0
	beq	proc_syntax
	cmp.b	#',',d0			; Expression zuende ?
	beq.s	1$
	sub.b	d1,d0
	bne.s	5$
	addq.w	#1,d2			; neue Klammerebene
	bra.s	4$
5$:	subq.b	#2,d0			; ']' ?
	bne.s	4$
	subq.w	#1,d2
	bne.s	4$			; ([expr].. ohne BaseRegister oder Index
	or.w	#$0080,d3
	bra.s	proc_memindOuter
10$:	subq.b	#8,d0
	bpl.s	12$
11$:	addq.b	#8,d0
	clr.b	opReg(a2)
	or.w	#$0080,d3		; BaseReg. Suppress
	bra.s	20$
12$:	moveq	#-'*',d1
	add.b	(a0),d1			; (An* ?
	beq.s	11$
	subq.b	#4,d1			; (An. ?
	beq.s	11$
14$:	move.l	a0,a3
	move.b	d0,opReg(a2)

15$:	move.b	(a3)+,d0		; Testen ob PreIndexed ([bd,An/PC,Rn]..
	cmp.b	#',',d0
	beq.s	16$
	cmp.b	#']',d0
	beq.s	proc_memindOuter
	bra.s	17$
16$:	move.l	a3,a0
	bsr	GetRegister		; IndexRegister lesen
	bpl.s	20$
	bsr	GetZReg			; Zero-Index ?
	bpl.s	19$
17$:	moveq	#37,d0			; Missing Register
18$:	rts
19$:	or.w	#$0040,d3		; ZRn - Index Suppress
20$:	bsr	GetRnFormat		; Size und Scale lesen
	bne.s	18$
	move.l	a0,a3
	cmp.b	#']',(a3)+		; MemIndir-Feld muss jetzt zuende sein!
	beq.s	proc_memindOD
	bra	proc_xaddrmode

proc_memindOuter:
	cmp.b	#',',(a3)+
	bne.s	2$
	move.l	a3,a0
	bsr	GetRegister		; Versuche Rn-Postindexed zu lesen
	bpl.s	3$
	bsr	GetZReg			; Zero-Index ?
	bmi.s	2$			; -scheint eher das OuterDisplacement zu sein
	or.w	#$0040,d3		; Index-Suppress
	bra.s	4$
3$:	addq.w	#4,d3			; Indirect Postindexed
4$:	bsr	GetRnFormat
	bne.s	1$
	move.l	a0,a3
	bra.s	proc_memindOD
1$:	rts
2$:	or.w	#$0040,d3		; Index Suppress
	subq.l	#1,a3

proc_memindOD:
	move.w	d3,opFormat(a2)		; Format-Word retten
	tst.l	d4			; Jetzt erst das BaseDisplacement verarbeiten
	bne.s	1$			;  Gar keins vorhanden?
	or.w	#$0010,opFormat(a2)
	bra	proc_memindGetOD
1$:	move.l	d4,a0
	moveq	#os_LONG,d0
	bsr	GetValue
	move.l	a0,d4
	move.l	d0,opVal1(a2)
	tst.w	d2
	bmi	proc_undefsym
	tst.b	d2
	beq	5$
	bpl	4$
	move.b	opMode(a2),d1
	subq.b	#ea_SpecialMode,d1
	bne.s	2$
	tst.b	d3
	bpl	3$			; PC-Indirect ?

2$:	move.w	ListFileOff(a5),d2	; AdrReg.-Indir. mit reloc. BaseDisp.
	swap	d2
	move.b	d2,opInfo1(a2)
	addq.b	#1,opInfo1(a2)
	cmp.w	SecNum(a5),d2
	bne.s	22$
	subq.b	#1,opType1(a2)		; Adr. aus dieser Section korrigieren
22$:	tst.b	d1			; ZPC? Dann kein NearMode versuchen
	beq	20$
	move.b	Model(a5),d1
	bmi	20$			; NEAR-Data Model aktiv?
	tst.b	d3			; Base Register Suppressed? ([near])
	bmi.s	27$
	cmp.b	opReg(a2),d1		; mit richtigem Near-Register?
	bne	20$
27$:	bsr	GetSectionPtr		; Zeiger auf Section Nummer d2 holen
	tst.b	sec_Near(a0)		; ist diese NEAR zu adressieren?
	beq	20$
	move.l	d0,d1
	sub.l	sec_Origin(a0),d1	; Offset auf Section-BaseAddress
	swap	d1
	tst.w	d1			; Adresse im Near-Bereich ?
	bne	20$			;  wenn nicht: einfach ([reloc,An])
	tst.b	d3			; Base Register Suppressed? ([near])
	bpl.s	28$
	and.w	#$ff7f,opFormat(a2)	; richtiges Base-Reg. reaktivieren
	move.b	Model(a5),opReg(a2)
28$:	move.l	sec_Origin(a0),d1
	move.l	d2,-(sp)
	moveq	#-$80,d3		; Subtrahend static (nicht verschiebbar)
	swap	d3
	move.w	#os_NEARWORD,d3
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	23$
	addq.l	#4,sp			; SecNum fuer NearReloc nicht benoetigt
	add.l	#$7ffe,d1
	move.w	#os_WORD,d3
	ENDC
23$:	move.l	d6,a1
	bsr	AddDistance		; Near-Adressierung als Distanz merken
	neg.b	opType1(a2)
	beq.s	24$
	move.l	d1,opVal1(a2)
	bra.s	25$
24$:	move.w	d0,opVal1+2(a2)
25$:
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	26$
	ENDC
	move.l	d6,d0
	move.l	(sp)+,d1
	bsr	AddNearReloc
26$:	bra	51$
20$:					; 32-Bit Reloc Displacement
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	21$
	ENDC
	move.l	d0,d3
	move.l	d6,d0
	move.w	d2,d1
	bsr	AddRelocation
	move.l	d3,d0
21$:	moveq	#0,d1			; 0-Distanz
	move.l	d6,a1
	moveq	#os_LONG,d3
	bsr	AddDistance
	moveq	#$30,d0			; Long Basedisplacement
	moveq	#9,d1
	bra	6$

3$:	move.l	d6,d1			; PC-Distanz erzeugen
	subq.l	#2,d1			; bezieht sich auf Adr. des Format-Words (!)
4$:	move.w	ListFileOff(a5),d2
	swap	d2
	move.l	d0,a1
	move.l	d1,d3
	sub.l	d1,d0
	exg	d4,a3
	bsr	CheckSize		; .W / .L ?
	move.l	d4,a3
	beq.s	40$
	bmi.s	41$
	bra.s	42$
40$:	bsr	WordLimits
	bne.s	41$
42$:	move.l	a1,d0			; Distanz passt in Word-BD
	move.l	d3,d1
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	move.l	d1,opVal1(a2)
	addq.b	#1,opType1(a2)
	bra.s	51$
41$:	move.l	a1,d0			; Distanz muss in Long-BD
	move.l	d3,d1
	moveq	#os_LONG,d3
	move.l	d6,a1
	bsr	AddDistance
	move.l	d1,opVal1(a2)
	addq.b	#1,opType1(a2)
	moveq	#$30,d0
	moveq	#9,d1
	bra.s	6$
5$:	swap	d2
	addq.w	#1,d2
	bmi	proc_relocerr		; NREF nicht moeglich
	bne.s	7$
	cmp.b	#ea_SpecialMode,opMode(a2)
	bne.s	7$
	tst.b	opFormat+1(a2)
	bmi.s	7$			; PC-Relatives XREF ?
	addq.l	#2,opVal1(a2)		; +2, bedingt durch das Format-Word
	moveq	#EXT_RELREF32,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
7$:	exg	d4,a3
	bsr	CheckSize		; .W / .L ?
	move.l	d4,a3
	beq.s	50$
	bmi.s	52$
	bra.s	51$
50$:	bsr	WordLimits		; Absolute-BD passt in Word?
	beq.s	51$
52$:	moveq	#$30,d0
	moveq	#9,d1
	bra.s	6$
51$:	moveq	#EXT_REF16,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	move.l	d6,a0			; dadurch sind 2 Bytes gewonnen
	moveq	#-2,d0
	bsr	ShiftRelocsNoOpt
	moveq	#$20,d0
	moveq	#5,d1

6$:	or.w	d0,opFormat(a2)
	add.w	d1,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)
	cmp.b	#$20,d0
	beq.s	proc_memindGetOD
	addq.l	#2,d6
	addq.b	#1,opSize1(a2)

proc_memindGetOD:
	move.b	(a3)+,d0
	cmp.b	#',',d0
	beq.s	1$			; OuterDisplacement scheint vorhanden
	cmp.b	#')',d0
	bne	proc_syntax
	move.l	EarlyOD(a5),d0		; (od,[...]) ?
	bne.s	11$
	addq.w	#1,opFormat(a2)		; Null OuterDisplacement
	bra	proc_memindOk
11$:	move.l	d0,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Early-Outerdispl. lesen
	subq.l	#1,a3
	bra.s	10$
1$:	tst.l	EarlyOD(a5)		; Doppeltes Outerdisp. ?
	bne	proc_xaddrmode
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Outerdispl. lesen
	move.l	a0,a3
10$:	move.l	d0,opVal2(a2)
	tst.w	d2
	bmi	proc_undefsym
	beq.s	5$
	tst.b	d2
	bpl.s	4$
	move.w	ListFileOff(a5),d2
	swap	d2			; Relocation setzen, falls Objectfile
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	31$
	ENDC
	move.l	d0,d3
	move.l	d6,d0
	move.w	d2,d1
	bsr	AddRelocation
	move.l	d3,d0
31$:	cmp.w	SecNum(a5),d2
	bne.s	32$
	subq.b	#1,opType2(a2)		; nur korrigieren, wenn aus dieser Section
32$:	moveq	#0,d1			; 0-Distanz
	move.l	d6,a1
	moveq	#os_LONG,d3
	bsr	AddDistance
	moveq	#3,d0			; Long Basedisplacement
	moveq	#9,d1
	bra.s	6$
4$:	move.w	ListFileOff(a5),d2
	swap	d2
	move.l	d0,a1
	move.l	d1,d3
	sub.l	d1,d0
	bsr	CheckSize		; .W / .L ?
	beq.s	40$
	bmi.s	42$
	bra.s	41$
40$:	bsr	WordLimits
	bne.s	42$
41$:	move.l	a1,d0			; Distanz passt in Word-BD
	move.l	d3,d1
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	move.l	d1,opVal2(a2)
	addq.b	#1,opType2(a2)
	bra.s	50$
42$:	move.l	a1,d0			; Distanz muss in Long-BD
	move.l	d3,d1
	moveq	#os_LONG,d3
	move.l	d6,a1
	bsr	AddDistance
	move.l	d1,opVal2(a2)
	addq.b	#1,opType2(a2)
	bra.s	51$
5$:	bsr	CheckSize		; .W / .L ?
	beq.s	52$
	bmi.s	51$
	bra.s	50$
52$:	bsr	WordLimits		; Absolute-BD passt in Word?
	bne.s	51$
50$:	moveq	#EXT_REF16,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	move.l	d6,a0			; dadurch sind 2 Bytes gewonnen
	moveq	#-2,d0
	bsr	ShiftRelocsNoOpt
	moveq	#2,d0
	moveq	#5,d1
	bra.s	6$
51$:	moveq	#3,d0
	moveq	#9,d1
6$:	cmp.b	#')',(a3)+
	bne.s	proc_ffsyntax
	or.w	d0,opFormat(a2)
	add.w	d1,ListFileOff(a5)
	addq.l	#2,d6
	addq.b	#1,opSize2(a2)
	subq.b	#2,d0
	beq.s	proc_memindOk
	addq.l	#2,d6
	addq.b	#1,opSize2(a2)
proc_memindOk:
	move.b	(a3),d0
	bne.s	2$
3$:	cmp.b	#ea_AindIndex,opMode(a2) ; Adressreg. oder PC indexed ?
	beq.s	1$
	moveq	#ea_PCindex,d1
	moveq	#0,d0
	rts
1$:	moveq	#ea_AindIndex,d1
	moveq	#0,d0
	rts
2$:	cmp.b	#'{',d0
	beq.s	3$
proc_ffsyntax:
	moveq	#41,d0			; Syntax Error
	rts
	ENDC


	cnop	0,4
GetRnFormat:
; a0 = Stringpos nach Rn
; d0 = Rn (0-15)
; d3 = FormatWord
; -> a0 = NewStringpos
; -> d3 = NewFormatWord
; -> d0 = 0 oder ErrorCode
	ror.w	#4,d0
	or.w	d0,d3
	moveq	#-'*',d0
	add.b	(a0),d0			; Rn*size ?
	beq.s	2$
	subq.b	#4,d0			; Rn.x ?
	bne.s	9$
	addq.l	#1,a0
	moveq	#-$21,d0
	and.b	(a0)+,d0
	cmp.b	#'L',d0			; Rn.L
	bne.s	1$
	or.w	#$0800,d3
1$:	cmp.b	#'*',(a0)
	bne.s	9$
2$:	addq.l	#1,a0
	moveq	#0,d0
	bsr	GetValue		; Scaling-Wert lesen
	tst.w	d2
	bmi.s	4$
	tst.b	d2
	beq.s	5$
	moveq	#81,d0			; No address allowed here
	rts
3$:	moveq	#93,d0			; Illegal scale factor
	rts
4$:	moveq	#36,d0			; Unknown Symbol
	rts
5$:	cmp.w	#8,d0
	bhi.s	3$
	move.b	10$(pc,d0.w),d0
	bmi.s	3$
	ror.w	#7,d0
	or.w	d0,d3
	cmp.b	#2,Machine(a5)		; Scaling erst ab 68020!
	blo.s	3$
9$:	moveq	#0,d0
	rts

10$:	dc.b	-1,0,1,-1,2,-1,-1,-1,3,-1


	cnop	0,4
WordLimits:
; d0 = long-Value
; -> Z-Flag = ok
	move.l	#$7fff,d1
	cmp.l	d1,d0
	bgt.s	1$
	not.l	d1
	cmp.l	d1,d0
	blt.s	1$
	moveq	#0,d1
	rts
1$:	moveq	#-1,d1
	rts


	cnop	0,4
CheckSize:
; d0 = long Value
; a3 = Zeiger auf moegliche .W / .L Extension
; An der Stelle des Punktes wird dabei ein $ff-Byte eingefügt
; -> a3 Zeiger steht hinter der Extension, falls vorhanden
; -> d1 Z-Flag = keine Extension
; ->	N-Flag = Long (sonst Word)
	cmp.b	#'.',(a3)
	bne.s	1$
	moveq	#-$21,d1
	and.b	1(a3),d1
	cmp.b	#'W',d1
	beq.s	2$
	cmp.b	#'L',d1
	bne.s	1$			; 3$
5$:	; .L
; clr.b   (a3)
	st	(a3)
	addq.l	#2,a3
	moveq	#-1,d1
	rts
2$:	; .W
	cmp.l	#$7fff,d0
	bgt.s	4$
	cmp.l	#-$8000,d0
	blt.s	4$
; clr.b   (a3)
	st	(a3)
	addq.l	#2,a3
	moveq	#1,d1
	rts
4$:	move.l	d0,d1
	bsr	OutofRange
	move.l	d1,d0
	bra.s	5$
;3$:
; move.l  d0,d1
; bsr	  SyntaxErr
; move.l  d1,d0
1$:	moveq	#0,d1
	rts


	cnop	0,4
ShiftLastRelocs:
; Die in der aktuellen Section zuletzt eingetragene Relocations um d0-Bytes
; verschieben
; d0 = ShiftDelta(long) *** wird nicht veraendert!!!
	lea	LastRelocs(a5),a1
	move.w	LastRelocCnt(a5),d1
	bra.s	2$
1$:	move.l	(a1)+,a0
	add.l	d0,(a0)
2$:	dbf	d1,1$
	rts


	cnop	0,4
DelLastRelocs:
; In der aktuellen Section zuletzt eingetragene Relocationen entfernen
	lea	LastRelocs(a5),a1
	moveq	#-1,d0
	move.w	LastRelocCnt(a5),d1
	bra.s	2$
1$:	move.l	(a1)+,a0
	move.l	d0,(a0)+		; ungueltige Addr.
	move.w	d0,(a0)			; ungueltige Section
2$:	dbf	d1,1$
	rts


	cnop	0,4
AddNearReloc:
; d0 = RelativeAddress in this Hunk
; d1 = Add BaseAddr of Hunk d1
	move.l	CurrentSec(a5),a0
	move.l	sec_HunkNearReloc(a0),a0
	bra.s	add_to_hrel

	cnop	0,4
AddRelocation:
; d0 = RelativeAddress in this Hunk
; d1 = Add BaseAddr of Hunk d1
	move.l	CurrentSec(a5),a0
	move.l	sec_HunkReloc(a0),a0
	tst.b	Relocatable(a5)
	bne	RelocError		; keine Relocs erlaubt

add_to_hrel:
	movem.l	d2-d3/a2,-(sp)
	move.l	d0,d2
	move.w	d1,d3
	move.l	a0,d0			; BSS oder OFFSET Segment?
	beq.s	5$
	move.l	a0,a2			; erster HunkReloc-Chunk
1$:	move.l	(a2),d0			; letzten Chunk suchen
	beq.s	2$
	move.l	d0,a2
	bra.s	1$
2$:	move.w	hrel_Entries(a2),d0
	bpl.s	3$			; Noch ein Eintrag frei ?
	bsr	GetHunkReloc		; Neuer HunkReloc Chunk
	move.l	d0,(a2)
	move.l	d0,a2
	moveq	#0,d0
3$:	move.w	d0,d1			; *6 (Groesse eines HunkReloc-Eintrages)
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,d0
	lea	hrel_HEAD(a2,d0.l),a0	; Freier Eintrag
	lea	LastRelocs(a5),a1
	move.w	LastRelocCnt(a5),d0
	cmp.w	#MAXLASTRELOCS,d0
	bhs.s	4$
	add.w	d0,d0
	add.w	d0,d0
	move.l	a0,(a1,d0.w)		; Alle Relocs einer Zeile merken
	addq.w	#1,LastRelocCnt(a5)
4$:	move.l	d2,(a0)+		; Reloc_Offset
	move.w	d3,(a0)			; Reloc_HunkNum
	addq.w	#1,d1
	move.w	d1,hrel_Entries(a2)
	cmp.w	#HUNKRELOCBLK/hrelSIZE,d1 ; ist der Chunk jetzt voll ?
	blo.s	5$
	move.w	#-1,hrel_Entries(a2)	; naechstesmal neuen HunkReloc beschaffen
5$:	movem.l	(sp)+,d2-d3/a2
	rts


	cnop	0,4
GetSectionPtr:
; d2 = SecNum
; -> a0 = Section
; ** kein weiteres Register wird zerstoert **
	movem.l	d0-d1/a1,-(sp)
	moveq	#0,d1
	move.b	d2,d1			; d1 gesuchte Section * 4
	add.w	d1,d1
	add.w	d1,d1
	move.l	SecTabPtr(a5),d0	; 1st SecList
1$:	move.l	d0,a0
	lea	secl_HEAD(a0),a1	; Zeiger auf ersten Section-Zeiger
	move.l	secl_FreeEntry(a0),d0
	beq.s	2$
	sub.l	a1,d0
	bra.s	3$
2$:	move.w	#SECLISTBLK,d0
3$:	cmp.w	d0,d1
	blo.s	4$			; gefunden
	sub.w	d0,d1
	move.l	(a0),d0
	bne.s	1$			; naechster SecList-Chunk
	moveq	#95,d0
	bra	FatalError		; Section doesn't exist
4$:	move.l	(a1,d1.w),a0		; Section-Pointer
	movem.l	(sp)+,d0-d1/a1
	rts


	IFND	SMALLASS
	cnop	0,4
WriteCPEA:
; Opcode mit Standard EA und ein zusaetzliches (Coprozessor) Opcode-Extension
; Word schreiben
; d4 = Opcode(raw), d5 = Opcode-Extension(ok)
; d2 = Bit7-5 Oper1-3 ignorieren
; a2 = Operand-struct
	moveq	#0,d0
	move.b	opMode(a2),d0
	lsl.b	#3,d0
	or.b	opReg(a2),d0
	or.w	d4,d0
	bsr	AddWord
	move.w	d5,d0
	bsr	AddWord
	bra.s	WriteExt
	ENDC

	cnop	0,4
WriteStdEA:
; Opcode mit Standard EA und Extension-Words schreiben
; d4 = Opcode(raw), d2 = Bit7-5 Oper1-3 ignorieren
; a2 = Operand-struct
	moveq	#0,d0
	move.b	opMode(a2),d0
	lsl.b	#3,d0
	or.b	opReg(a2),d0
	or.w	d4,d0
	bsr	AddWord

WriteExt:
; Extension-Words fuer alle Operanden schreiben schreiben
; d2 = Bit7-5 Oper1-3 ignorieren
	subq.b	#os_LONG,OpcodeSize(a5)
	bhi.s	5$			; .s .d .x .p	  nur für Float erlaubt
4$:	add.b	d2,d2
	bcs.s	1$
	lea	oper1(a5),a2
	bsr.s	WriteOperExt
1$:	add.b	d2,d2
	bcs.s	2$
	lea	oper2(a5),a2
	bsr.s	WriteOperExt
2$:
	IFND	SMALLASS
	add.b	d2,d2
	bcs.s	3$
	lea	oper3(a5),a2
	bsr.s	WriteOperExt
	ENDC
3$:	rts
5$:	moveq	#20,d0			; Illegal Opcode Extension
	bsr	Error
	bra.s	4$

	cnop	0,4
WriteOperExt:
; Extension-Words fuer einen Operanden schreiben
; a2 = Operand-Structure
	IFND	SMALLASS
	move.w	opFormat(a2),d0		; Format-Word schreiben?
	bne.s	WriteFullFormat
	ENDC
	move.l	opVal1(a2),d0
	subq.b	#1,opType1(a2)
	bmi.s	2$
	beq.s	1$
	move.l	opVal2(a2),a0		; Adr.Reg-Indirect-Indexed-Distance-Mode
	move.l	(a0)+,d1
	sub.l	(a0),d1
	move.b	d1,d0			; als 8-bit displacement eintragen
	moveq	#$3f,d1
	and.b	9(a0),d1		; shifted Distance?
	beq.s	2$
	bra.s	5$
1$:	move.l	d0,a0			; normale Distanz
	move.l	(a0)+,d0
	sub.l	(a0),d0
	moveq	#$3f,d1
	and.b	9(a0),d1		; shifted Distance?
	bne.s	7$
2$:	subq.b	#1,opSize1(a2)
	bpl.s	3$
	rts
3$:	beq	AddWord
	bra	AddLong
5$:	bclr	#5,d1
	bne.s	6$
	asl.b	d1,d0
	bra.s	2$
6$:	asr.b	d1,d0
	bra.s	2$
7$:	bclr	#5,d1
	bne.s	8$
	asl.l	d1,d0
	bra.s	2$
8$:	asr.l	d1,d0
	bra.s	2$


	IFND	SMALLASS
	cnop	0,4
read_distOper:
	; Distanz lesen und auch shifted dist. prüfen
	move.l	d0,a0
	move.l	(a0)+,d0
	sub.l	(a0),d0
	moveq	#$3f,d1
	and.b	9(a0),d1
	bne.s	1$
	rts
1$:	bclr	#5,d1
	bne.s	2$
	asl.l	d1,d0
	rts
2$:	asr.l	d1,d0
	rts


	cnop	0,4
WriteFullFormat:
	bsr	AddWord			; Format-Word schreiben
	move.l	opVal1(a2),d0
	subq.b	#1,opType1(a2)
	bmi.s	11$
	bsr.s	read_distOper		; BaseDisplacement als Distanz
11$:	subq.b	#1,opSize1(a2)
	bmi.s	13$
	bne.s	12$
	bsr	AddWord			; 16-bit BaseDisplacement
	bra.s	13$
12$:	bsr	AddLong			; 32-bit BaseDisplacement
13$:	move.l	opVal2(a2),d0
	subq.b	#1,opType2(a2)
	bmi.s	14$
	bsr.s	read_distOper		; OuterDisplacement als Distanz
14$:	subq.b	#1,opSize2(a2)
	bpl.s	15$
	rts
15$:	beq	AddWord
	bra	AddLong


	cnop	0,4
WritePMMUEA:
; d4 = Opcode-Extension
	lea	oper1(a5),a2
WritePMMUa2:
	move.w	#$f000,d0
	bra.s	wr_cpea

	cnop	0,4
WriteFPEA:
; d4 = Opcode-Extension
	moveq	#0,d0
	move.b	FPUid(a5),d0
	bne.s	1$
	bsr	IllegalInstr		; Warnung ausgeben: FPU nicht angemeldet!
	moveq	#1,d0
1$:	ror.w	#7,d0
	or.w	#$f000,d0
	lea	oper1(a5),a2
wr_cpea:
	move.b	opMode(a2),d0
	lsl.b	#3,d0
	or.b	opReg(a2),d0
	bsr	AddWord			; FPU Opcode
	move.w	d4,d0
	bsr	AddWord			; und Extension schreiben
	move.w	opFormat(a2),d0		; Format-Word schreiben?
	bne.s	WriteFullFormat
	move.l	opVal1(a2),d0
	subq.b	#1,opType1(a2)
	bmi.s	2$
	beq.s	1$
	move.l	opVal2(a2),a0		; Adr.Reg-Indirect-Indexed-Distance-Mode
	move.l	(a0)+,d1
	sub.l	(a0),d1
	move.b	d1,d0			; als 8-bit displacement eintragen
	moveq	#$3f,d1
	and.b	9(a0),d1		; shifted Distance?
	beq.s	2$
	bra.s	5$
1$:	move.l	d0,a0			; normale Distanz
	move.l	(a0)+,d0
	sub.l	(a0),d0
	moveq	#$3f,d1
	and.b	9(a0),d1		; shifted Distance?
	bne.s	7$
2$:	move.b	opSize1(a2),d2
	bne.s	4$
3$:	rts
5$:	bclr	#5,d1
	bne.s	6$
	asl.b	d1,d0
	bra.s	2$
6$:	asr.b	d1,d0
	bra.s	2$
7$:	bclr	#5,d1
	bne.s	8$
	asl.l	d1,d0
	bra.s	2$
8$:	asr.l	d1,d0
	bra.s	2$
4$:	subq.b	#1,d2
	beq	AddWord			; Byte oder Word
	subq.b	#1,d2
	beq	AddLong			; Long, SinglePrecision oder FFP
	move.l	d0,a2
	move.l	(a2)+,d0		; DoublePrecision (Zeiger auf 8 Bytes)
	bsr	AddLong
	move.l	(a2)+,d0
	bsr	AddLong
	subq.b	#2,d2
	bls.s	3$
	move.l	(a2),d0			; ExtendedPrecision oder PackedBCD (12 Bytes)
	bra	AddLong
	ENDC



; *** Spezialprogramme fuer die verschiedenen Mnemonics ***

NoOp:
	; Befehl wird erkannt, aber nicht ausgef.
	nop
	nop
	rts


Single:
	; Einzelbefehl, z.B.: NOP, RESET, ILLEGAL,..
	jmp	Sing2(pc)
	addq.l	#2,d6
	rts
Sing2:
	move.w	d4,d0
	addq.l	#2,d6
	bra	AddWord


	cnop	0,4
DConst:
	; DC.x value1[,value2]... oder DC.x "string"
	jmp	DConst2(pc)
	moveq	#0,d4
	move.b	OpcodeSize(a5),d4
	beq.s	11$
	btst	#sw_ALIGN,Switches(a5)	; Auto-Align ?
	beq.s	11$
	addq.l	#1,d6
	and.b	#$fe,d6
	move.l	d6,LineAddr(a5)
11$:	moveq	#',',d3
	move.l	#$00270022,d2		; ' und "
	moveq	#0,d1
	move.b	DCMem(pc,d4.w),d1	; Speicherbedarf fuer ein value
	tst.b	(a3)			; Ueberhaupt ein value vorhanden ?
	beq	MissingArg
1$:	move.b	(a3)+,d0
	beq.s	7$
	cmp.b	d2,d0			; String ?
	beq.s	2$
	swap	d2
	cmp.b	d2,d0
	beq.s	2$
	cmp.b	d3,d0			; Komma ?
	bne.s	1$
	add.l	d1,d6			; Speicherbedarf fuer ein value addieren
	bra.s	1$
7$:	add.l	d1,d6
8$:	rts
2$:	moveq	#0,d5			; Zaehlt die Zeichen im String
	moveq	#ESCSYM,d3
	swap	d2
4$:	addq.w	#1,d5
	move.b	(a3)+,d0
	beq.s	50$
	swap	d2
	cmp.b	d2,d0			; echter Stringbegrenzer?
	beq.s	5$
	swap	d2
	cmp.b	d3,d0			; Escape-Zeichen
	beq.s	3$
	cmp.b	d2,d0			; anderer Stringbegrenzer?
	bne.s	4$
	cmp.b	(a3),d2			; "" oder '' ?
	bne.s	4$
3$:	addq.l	#1,a3
	bra.s	4$
50$:	subq.l	#1,a3
	moveq	#-1,d0
5$:	swap	d2
	cmp.b	(a3),d0			; "" oder '' ?
	beq.s	3$
	subq.w	#1,d5
	moveq	#0,d0
	move.b	DCMasks(pc,d4.w),d0
	bmi.s	6$
	add.l	d0,d5			; string align
	not.l	d0
	and.l	d0,d5
	add.l	d5,d6			; Programmzaehler verschieben
	moveq	#',',d3
51$:	move.b	(a3)+,d0
	beq.s	8$
	cmp.b	d3,d0			; Komma ?
	bne.s	51$
	bra	1$
6$:	moveq	#63,d0			; Not a byte-, word- or long-string!
	bra	Error
	IFND	SMALLASS
DCMem:
	dc.b	1,2,4,4,4,8,12,12,8
DCMasks:
	dc.b	0,1,3,-1,-1,-1,-1,-1,-1	; String ist nur mit .b,.w,.l moeglich
	ELSE
DCMem:
	dc.b	1,2,4
DCMasks:
	dc.b	0,1,3
	ENDC

	cnop	0,4
DConst2:
	moveq	#0,d4
	move.b	OpcodeSize(a5),d4	; d4 = OpcodeSize
	beq.s	1$
	btst	#sw_ALIGN,Switches(a5)	; Auto-Align ?
	beq.s	1$
	btst	#0,d6
	beq.s	1$
	addq.l	#1,d6
	moveq	#0,d0			; 0-Byte eingfuegen
	bsr	AddByte
	addq.l	#1,LineAddr(a5)
1$:	moveq	#0,d5
	move.b	DCMem(pc,d4.w),d5	; d5 = BytesPerValue
	move.l	d4,a2
	add.l	a2,a2
	add.l	a2,a2
	tst.b	(a3)			; wenigstens EIN value da ?
	beq	DC2_exit
	st	RefFlag(a5)
DC2_Loop:
	move.l	a3,a0
	move.b	(a3)+,d0
	moveq	#$22,d2
	cmp.b	d2,d0			; Ist es ein String ?
	beq.s	DC2string
	moveq	#$27,d2
	cmp.b	d2,d0
	beq.s	DC2string
DC2_GetVal:
	moveq	#-2,d0
	bsr	GetValue		; value einlesen
	move.l	a0,a3
	tst.w	d2
	bmi	UndefSym
	beq.s	2$			; normales value ?
	tst.b	d2
	bpl.s	1$			; Distanz ?
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	1$			; Neuer Eintrag fuer Reloc32 bei Objectfile
	ENDC
	move.l	d0,d3
	move.l	d6,d0
	swap	d2
	move.w	d2,d1
	swap	d2
	bsr	AddRelocation
	move.l	d3,d0
	moveq	#0,d1
1$:	clr.w	d2
	IFND	FREEASS
	cmp.b	#ASSLINECOLUMN,Columns(a5)
	bne.s	21$
	addq.w	#7,d2
	ENDC
21$:	move.l	d1,-(sp)
	swap	d2
	moveq	#0,d3
	move.b	d4,d3
	move.l	d6,a1
	bsr	AddDistance
	tst.l	(sp)+
	beq.s	3$
	tst.b	DistChkDisable(a5)
	bne.s	3$
2$:	bsr	DC_RangeCheck
3$:	jsr	DC2Tab(pc,a2.l)
	add.l	d5,d6
22$:	move.b	(a3)+,d0
	beq.s	DC2_exit
	cmp.b	#',',d0
	beq	DC2_Loop
	cmp.b	#'.',d0			; .x Extension hinter dem Value?
	bne	SyntaxErr
	tst.b	(a3)+
	bne.s	22$
	bra	SyntaxErr
DC2_exit:
	rts

	cnop	0,4
DC2string:
	moveq	#ESCSYM,d3
	moveq	#%101,d0
	eor.b	d2,d0
	swap	d2
	move.b	d0,d2			; d2 = echter Begrenzer | anderer Begrenzer
	jmp	1$(pc,a2.l)
	cnop	0,4
1$:	jmp	DC2bstr(pc)
	jmp	DC2wstr(pc)
	jmp	DC2lstr(pc)
	IFND	SMALLASS
	jmp	DC2_exit(pc)
	jmp	DC2_exit(pc)
	jmp	DC2_exit(pc)
	jmp	DC2_exit(pc)
	jmp	DC2_exit(pc)
	jmp	DC2_exit(pc)
	ENDC

DC2Tab:
	jmp	AddByte(pc)
	jmp	AddWord(pc)
	jmp	AddLong(pc)
	IFND	SMALLASS
	jmp	AddLong(pc)
	jmp	AddLong(pc)
	jmp	AddDouble(pc)
	jmp	AddExtended(pc)
	jmp	AddExtended(pc)
	jmp	AddDouble(pc)
	ENDC

DC2lstr:
	; Long-String dc.l "x..."
	moveq	#3,d1
	moveq	#0,d0
1$:	lsl.l	#8,d0
	move.b	(a3),d0
	beq.s	3$
	addq.l	#1,a3
	cmp.b	d2,d0			; anderer String-Begrenzer?
	bne.s	6$
	cmp.b	(a3),d2			; "" / '' ?
	beq.s	7$
6$:	swap	d2
	cmp.b	d2,d0			; String-Ende ?
	beq.s	3$
	swap	d2
	cmp.b	d3,d0			; Escape-Zeichen
	bne.s	2$
	move.b	(a3)+,d0
	bsr	GetEscSym
2$:	dbf	d1,1$			; Longword fertig?
	bset	#31,d3
	beq.s	21$
20$:	addq.l	#4,d6
	bsr	AddLong
	bra.s	DC2lstr
21$:	swap	d2
	cmp.b	(a3),d2			; String nach 4 Zeichen zuende?
	bne.s	22$
	cmp.b	1(a3),d2
	bne	DC2_GetVal		; dann GetValue() verwenden
22$:	swap	d2
	bra.s	20$
7$:	addq.l	#1,a3
	bra.s	2$
3$:	swap	d2
	cmp.b	(a3),d0			; "" \ '' ?
	beq.s	7$
	tst.l	d3			; <= 4 Zeichen, dann mit GetValue() lesen
	bpl	DC2_GetVal
	subq.b	#3,d1			; Longword hört 'aligned' auf?
	beq.s	4$
	lsr.l	#8,d0
	addq.l	#4,d6
	bsr	AddLong
4$:	move.b	(a3)+,d0
	beq.s	5$
	cmp.b	#',',d0			; Komma ?
	beq	DC2_Loop
	bra	SyntaxErr
5$:	rts

	cnop	0,4
DC2wstr:
	; Word-String dc.w "x..."
	moveq	#1,d1
	moveq	#0,d0
1$:	lsl.w	#8,d0
	move.b	(a3),d0
	beq.s	3$
	addq.l	#1,a3
	cmp.b	d2,d0			; anderer String-Begrenzer?
	bne.s	6$
	cmp.b	(a3),d2			; "" / '' ?
	beq.s	7$
6$:	swap	d2
	cmp.b	d2,d0			; String-Ende ?
	beq.s	3$
	swap	d2
	cmp.b	d3,d0			; Escape-Zeichen
	bne.s	2$
	move.b	(a3)+,d0
	bsr	GetEscSym
2$:	dbf	d1,1$			; word fertig?
	bset	#31,d3
	beq.s	21$
20$:	addq.l	#2,d6
	bsr	AddWord
	bra.s	DC2wstr
21$:	swap	d2
	cmp.b	(a3),d2			; String nach 2 Zeichen zuende?
	bne.s	22$
	cmp.b	1(a3),d2
	bne	DC2_GetVal		; dann GetValue() verwenden
22$:	swap	d2
	bra.s	20$
7$:	addq.l	#1,a3
	bra.s	2$
3$:	swap	d2
	cmp.b	(a3),d0			; "" \ '' ?
	beq.s	7$
	tst.l	d3			; <= 4 Zeichen, dann mit GetValue() lesen
	bpl	DC2_GetVal
	subq.b	#1,d1			; word hört 'aligned' auf?
	beq.s	4$
	lsr.w	#8,d0
	addq.l	#2,d6
	bsr	AddWord
4$:	move.b	(a3)+,d0
	beq.s	5$
	cmp.b	#',',d0			; Komma ?
	beq	DC2_Loop
	bra	SyntaxErr
5$:	rts

	cnop	0,4
DC2bstr:
	; Byte-String dc.b "x..."
	move.b	(a3)+,d0
	beq.s	2$
	cmp.b	d2,d0			; anderer String-Begrenzer?
	bne.s	5$
	cmp.b	(a3),d2			; "" / '' ?
	bne.s	5$
	addq.l	#1,a3
5$:	swap	d2
	cmp.b	d2,d0			; String-Ende ?
	beq.s	3$
	cmp.b	d3,d0			; Escape-Zeichen
	bne.s	1$
	move.b	(a3)+,d0
	bsr.s	GetEscSym
1$:	bset	#31,d3
	beq.s	7$
6$:	swap	d2
	addq.l	#1,d6
	bsr	AddByte
	bra.s	DC2bstr
7$:	cmp.b	(a3),d2			; String hat nur ein Zeichen?
	bne.s	6$
	cmp.b	1(a3),d2
	beq.s	6$
	bra	DC2_GetVal		; dann GetValue() verwenden
2$:	subq.l	#1,a3
3$:	move.b	(a3)+,d0
	beq.s	4$
	cmp.b	d2,d0			; "" \ '' ?
	beq.s	1$
	cmp.b	#',',d0			; Komma ?
	beq	DC2_Loop
	bra	SyntaxErr
4$:	rts


	cnop	0,4
GetEscSym:
; wandelt Escape-Symbol in den zugehoerigen Code um
; ** Nur d0 wird veraendert! **
; d0 = ESC-Sym
; -> d0 = Code
	cmp.b	#'@',d0
	blo.s	2$
	move.l	d0,-(sp)
	and.w	#$1f,d0
	move.b	1$(pc,d0.w),3(sp)
	move.l	(sp)+,d0
	rts
1$:	dc.b	$40,$41,$08,$9b,$44,$1b,$0c,$47,$48,$49,$4a,$4b,$4c,$4d,$0a,$4f
	dc.b	$50,$51,$0d,$53,$09,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f
2$:	cmp.b	#'0',d0			; \0
	bne.s	3$
	clr.b	d0
3$:	rts


	cnop	0,4
DStor:	; DCB.x oder BLK.x count[,val] oder DS.x count
	jmp	DStor2(pc)
	tst.b	(a3)
	beq	MissingArg
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Zahl der zu reservierenden Worte
	tst.w	d2
	beq.s	1$
	bmi	UndefSym
	bra	AddrError		; Programmadr. (oder Dist.) sind nicht erlaubt
1$:	moveq	#0,d1
	move.b	OpcodeSize(a5),d1
	beq.s	5$
	tst.l	d0
	bmi	OutofRange		; keine negativen Werte!
	beq.s	6$			; DS.? 0  (Align)
	btst	#sw_ALIGN,Switches(a5)	; Auto-Align ?
	beq.s	7$
	addq.l	#1,d6			; Adresse erst begradigen (falls nicht '.b')
	and.b	#$fe,d6
	move.l	d6,LineAddr(a5)
7$:
	IFND	SMALLASS
	cmp.b	#os_FFP,d1		; Fliesskomma ?
	blo.s	4$
	subq.b	#os_DOUBLE,d1
	blo.s	3$
	beq.s	2$
	lsl.l	#2,d0			; *12 fuer .x und .p
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	bra.s	5$
2$:	moveq	#3,d1			; *8 fuer .d (und .q)
	bra.s	4$
3$:	moveq	#2,d1			; *4 fuer .f und .s
	ENDC
4$:	lsl.l	d1,d0
5$:	add.l	d0,d6			; benoetigter Speicher fuer Block
	rts
6$:	moveq	#0,d2			; DS.x 0
	moveq	#0,d3
	move.b	DSMem-1(pc,d1.w),d2
	bra	ds_cnop1

	IFND	SMALLASS
DSMem:
	dc.b	2,4,4,4,8,12,12,8
	ELSE
DSMem:
	dc.b	2,4
	ENDC


	cnop	0,4
DStor2:
	tst.b	(a3)
	beq	4$
	st	RefFlag(a5)
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Zahl der zu reservierenden Worte
	move.l	d0,d5
	bmi	OutofRange		; keine negativen Werte!
	tst.w	d2
	bne	4$			; Fehler ?
	moveq	#0,d3			; Default-Fuellwert = 0
	move.b	(a0)+,d0
	beq.s	1$			; hängt noch was dran?
	tst.w	d4
	bne.s	11$			; DS.x ?
	cmp.b	#',',d0
	bne.s	11$
	moveq	#-2,d0
	bsr	GetValue		; Fuell-Wert lesen
	tst.w	d2
	beq.s	2$
	bmi	UndefSym		; Programmadr. (oder Dist.) als Fuellw. illegal
	bra	AddrError
11$:	bra	SyntaxErr
12$:	moveq	#0,d2			; DS.x 0
	moveq	#0,d3
	move.b	DSMem-1(pc,d4.w),d2
	bra	ds_cnop2
2$:	bsr	DC_RangeCheck
	move.l	d0,d3
1$:	move.l	d5,d2
	moveq	#0,d4
	move.b	OpcodeSize(a5),d4
	beq.s	6$
	tst.l	d2			; DS.x 0 ?  (Align)
	beq.s	12$
	btst	#sw_ALIGN,Switches(a5)	; Auto-Align ?
	beq.s	5$
	btst	#0,d6			; Adresse erst begradigen ?
	beq.s	5$
	addq.l	#1,d6
	moveq	#0,d0
	bsr	AddByte			; 0-Byte einfuegen
	addq.l	#1,LineAddr(a5)
5$:
	IFND	SMALLASS
	cmp.b	#os_FFP,d4		; Fliesskomma ?
	blo.s	54$
	subq.b	#os_DOUBLE,d4
	blo.s	53$
	tst.b	d4
	beq.s	52$
	lsl.l	#2,d2			; *12 fuer .x und .p
	move.l	d2,d1
	add.l	d2,d2
	add.l	d1,d2
	moveq	#4,d4
	bra.s	6$
52$:	moveq	#3,d4			; *8 fuer .d (und .q)
	bra.s	54$
53$:	moveq	#2,d4			; *4 fuer .f und .s
	ENDC
54$:	lsl.l	d4,d2
6$:	add.l	d2,d6			; Programmzaehler weitersetzen
	tst.l	d5
	beq.s	4$
	tst.l	d3			; Füllwert=0 ?
	beq.s	7$
	add.w	d4,d4
	add.w	d4,d4
	move.l	10$(pc,d4.w),a2		; AddByte/Word/Long/FFP/etc. - Funktion
3$:	move.l	d3,d0
	jsr	(a2)			; Speicher fuellen
	subq.l	#1,d5
	bne.s	3$
4$:	rts
7$:	move.l	d2,d0
	bra	AddCount		; AddCount ist schneller für 0
10$:	dc.l	AddByte,AddWord,AddLong
	IFND	SMALLASS
	dc.l	AddDouble,AddExtended
20$:	dc.l	0,0,0
	ENDC


DC_RangeCheck:
; d0 = Longword to check
	movem.l	d0-d1,-(sp)
	move.b	OpcodeSize(a5),d1
	subq.b	#os_LONG,d1
	bpl.s	4$			; Byte- und Word-Immediates die Range prüfen
	tst.l	d0
	bpl.s	1$
	not.l	d0
	add.l	d0,d0
1$:	addq.b	#1,d1
	beq.s	2$
	clr.b	d0			; Byte-Range?
	tst.l	d0
	beq.s	4$
	bra.s	3$
2$:	swap	d0			; Word-Range?
	tst.w	d0
	beq.s	4$
3$:	moveq	#68,d0			; Out of range!
	bsr	Error
4$:	movem.l	(sp)+,d0-d1
	rts


	IFND	FREEASS
	cnop	0,4
RSreset:
	; RSRESET, CLRSO
	nop
	nop
	moveq	#0,d0
	bra.s	rs_set


	cnop	0,4
RSset:
	; RSSET/SETSO [count]
	nop
	nop
	moveq	#0,d0
	tst.b	(a3)
	beq.s	rs_set
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; count-Expression lesen
	tst.w	d2
	beq.s	rs_set
	bmi	UndefSym
	bra	AddrError		; Programmadr. (oder Dist.) sind nicht erlaubt
rs_set:
	move.l	d0,RScounter(a5)
	move.l	sym__RS(a5),a0		; __RS und __SO ebenfalls setzen
	move.l	sym__SO(a5),a1
	move.l	d0,sym_Value(a0)
	move.l	d0,sym_Value(a1)
	IFND	GIGALINES
	move.w	AbsLine(a5),sym_DeclLine(a0)
	move.w	AbsLine(a5),sym_DeclLine(a1)
	ELSE
	move.l	AbsLine(a5),sym_DeclLine(a0)
	move.l	AbsLine(a5),sym_DeclLine(a1)
	ENDC
	clr.b	(a2)
	bra	RemEQULine


	cnop	0,4
FOreset:
	; CLRFO
	nop
	nop
	moveq	#0,d0
	bra.s	fo_set


	cnop	0,4
FOset:
	; SETFO [count]
	nop
	nop
	moveq	#0,d0
	tst.b	(a3)
	beq.s	fo_set
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; count-Expression lesen
	tst.w	d2
	beq.s	fo_set
	bmi	UndefSym
	bra	AddrError		; Programmadr. (oder Dist.) sind nicht erlaubt
fo_set:
	move.l	d0,FOcounter(a5)
	move.l	sym__FO(a5),a0		; __FO ebenfalls setzen
	move.l	d0,sym_Value(a0)
	IFND	GIGALINES
	move.w	AbsLine(a5),sym_DeclLine(a0)
	ELSE
	move.l	AbsLine(a5),sym_DeclLine(a0)
	ENDC
	clr.b	(a2)
	bra	RemEQULine


	cnop	0,4
RS:
	; [label] RS.x/SO.x [count]
	nop
	nop
	tst.b	(a2)			; kein Label gegeben ?
	beq.s	1$
	moveq	#T_EQU,d0
	move.l	a2,a0
	move.l	RScounter(a5),d1	; Dem Label den aktuellen RScounter zuweisen
	bsr	AddGorLSymbol
	clr.b	(a2)			; Label loeschen
1$:	bsr.s	calcOffsetCount		; Offset bestimmen
	add.l	d0,RScounter(a5)	; RScounter weitersetzen
	move.l	sym__RS(a5),a0
	move.l	sym__SO(a5),a1
	add.l	d0,sym_Value(a0)
	add.l	d0,sym_Value(a1)
	IFND	GIGALINES
	move.w	AbsLine(a5),sym_DeclLine(a0)
	move.w	AbsLine(a5),sym_DeclLine(a1)
	ELSE
	move.l	AbsLine(a5),sym_DeclLine(a0)
	move.l	AbsLine(a5),sym_DeclLine(a1)
	ENDC
	rts


	cnop	0,4
FO:
	; [label] FO.x [count]
	nop
	nop
	bsr.s	calcOffsetCount		; Offset bestimmen
	sub.l	d0,FOcounter(a5)	; FOcounter weitersetzen
	move.l	FOcounter(a5),d1
	move.l	sym__FO(a5),a0
	move.l	d1,sym_Value(a0)	; und __FO ebenfalls
	IFND	GIGALINES
	move.w	AbsLine(a5),sym_DeclLine(a0)
	ELSE
	move.l	AbsLine(a5),sym_DeclLine(a0)
	ENDC
	tst.b	(a2)			; kein Label gegeben ?
	beq.s	1$
	moveq	#T_EQU,d0
	move.l	a2,a0
	bsr	AddGorLSymbol		; Dem Label den aktuellen FOcounter zuweisen
	clr.b	(a2)			; Label loeschen
1$:	rts


	cnop	0,4
calcOffsetCount:
; Bestimmt den Structure- bzw. Frame-Offset für RS, SO und FO.
; a3 = Operand
; -> d0 = Offset in Bytes
	bsr	RemEQULine		; im naechsten Pass nicht mehr beachten
	tst.b	(a3)			; offset angegeben?
	beq.s	1$
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; count-Expression lesen
	tst.w	d2
	beq.s	2$
	bmi.s	7$
	bsr	AddrError		; Programmadr. (oder Dist.) sind nicht erlaubt
	bra.s	1$
7$:	bsr	UndefSym
1$:	moveq	#0,d0
	rts
2$:	moveq	#0,d1
	move.b	OpcodeSize(a5),d1
	beq.s	6$
	IFND	SMALLASS
	cmp.b	#os_FFP,d1		; Fliesskomma ?
	blo.s	5$
	subq.b	#os_DOUBLE,d1
	blo.s	4$
	beq.s	3$
	lsl.l	#2,d0			; *12 fuer .x und .p
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	rts
3$:	moveq	#3,d1			; *8 fuer .d (und .q)
	bra.s	5$
4$:	moveq	#2,d1			; *4 fuer .f und .s
	ENDC
5$:	lsl.l	d1,d0
6$:	rts
	ENDC				;FREEASS


	cnop	0,4
Equate:					; label EQU.x <Expression>
	nop
	nop				; bei EQU.F-.P wird nach FLOAT konvertiert
	move.l	a3,a0
	moveq	#os_LONG,d0
	IFND	SMALLASS
	move.b	OpcodeSize(a5),d4
	cmp.b	#os_FFP,d4
	blo.s	11$
	move.b	d4,d0
	ENDC
11$:	bsr	GetValue		; Expression ausrechnen
	tst.w	d2
	bpl.s	1$			; Konnte berechnet werden ?
	tst.b	d5
	beq.s	10$
12$:	bsr	UndefSym		; Falls Pass 2, dann:  Undefined symbol !
	bra.s	5$
1$:	beq.s	2$			; keine Progr.Adresse darin enthalten ?
	tst.b	d2
	bmi.s	25$			; normale ABS-Definition (ohne Subtrahend)
	move.l	d2,d4
	clr.w	d2
	swap	d2
	moveq	#0,d3
	subq.w	#1,d3
	move.w	d3,a1			; als EQU-Distance eintragen
	bsr	AddDistance
	move.l	d4,d2
	move.w	#T_DIST,d0
	bra.s	6$
2$:	tst.l	d2
	bmi.s	12$			; XREF nicht erlaubt
	IFND	SMALLASS
	cmp.b	#os_FFP,d4
	IFND	FREEASS
	blo.s	30$
	ELSE
	blo.s	26$
	ENDC
	cmp.b	#os_DOUBLE,d4
	blo.s	21$
	bsr	AddLongFloat		; 64 oder 96-Bit Zahl in StringBuf schreiben
21$:	move.l	d0,d1
	ext.w	d4
	add.w	d4,d4
	move.w	22$-2*os_FFP(pc,d4.w),d0 ; Type
	bra.s	3$
22$:	dc.w	T_FFP,T_SINGLE,T_DOUBLE,T_EXTENDED,T_PACKED
	ENDC
25$:	move.l	d0,d1
	moveq	#T_ABS,d0
6$:	tst.b	(a2)			; kein Label gegeben ?
	beq.s	28$
	move.w	SecNum(a5),d4
	move.l	CurrentSec(a5),a3
	swap	d2
	move.w	d2,SecNum(a5)
	bsr	GetSectionPtr		; Zeiger auf Section Nummer d2 holen
	move.l	a0,CurrentSec(a5)
	move.l	a2,a0
	bsr	AddGorLSymbol
	move.w	d4,SecNum(a5)
	move.l	a3,CurrentSec(a5)
	bra.s	5$
26$:	move.l	d0,d1
27$:	moveq	#T_EQU,d0
3$:	tst.b	(a2)			; kein Label gegeben ?
	bne.s	4$
28$:	bsr	MissingLabel
	bra.s	5$
4$:	move.l	a2,a0
	bsr	AddGorLSymbol
5$:	bsr	RemEQULine		; im naechsten Pass nicht mehr beachten
9$:	clr.b	(a2)			; Label loeschen
	rts
10$:	tst.b	Local(a5)		; Symbol in Pass 1 noch unbekannt
	beq.s	9$
	bsr	OpenLocalPart		; Leeren LocalPart kuenstlich offen halten
	bra.s	9$
	IFND	FREEASS
30$:	move.l	ListFileHandle(a5),d4
	beq.s	26$
	tst.b	ListEn(a5)
	beq.s	26$
	movem.l	d0/a6,-(sp)
	tst.b	d5
	bne.s	31$
	move.l	DosBase(a5),a6
	move.l	d4,d1
	move.l	FPOffset(a5),d2
	moveq	#OFFSET_CURRENT,d3
	jsr	Seek(a6)		; Pass1: Seek zum Anfang der Zeile zurück
	move.l	d0,d2
31$:	move.l	sp,a1
	lea	33$(pc),a0
	move.l	d4,d0
	bsr	fprintf			; EQU-Wert als Adresse im Lst.File ausg.
	tst.b	d5
	bne.s	32$
	move.l	d4,d1
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)		; Pass1: Filepointer zurücksetzen
32$:	movem.l	(sp)+,d1/a6
	bra.s	27$
33$:	dc.b	"#$%08lx",0
	ENDC


	cnop	0,4
Mov:
	; MOVE.x ea,ea (auch MOVEA, CCR, SR, USP)
	jmp	Mov2(pc)
	move.w	#$8020,d1		; USP,SR,CCR testen, Operand 3 ignorieren
	bra	InstrSize
	nop
Mov_exit:
	rts

	cnop	0,4
Mov2:
	move.l	#%01111111011111110110001101111111,d0
	move.w	#$8020,d1
	bsr	GetOperand
	bmi.s	Mov_exit
Mov_start:
	move.w	oper1+opMode(a5),d0
	move.w	oper2+opMode(a5),d1
	cmp.w	#(ea_SpecialMode<<8)+(ea_USP&7),d0
	bhs	MovUSPorSR		; SourceOperand = SR, CCR oder USP ?
	cmp.w	#(ea_SpecialMode<<8)+(ea_USP&7),d1
	bhs	MovtoUSPorSR		; DestOperand = SR, CCR oder USP ?

	btst	#of_PeaLea,OptFlag(a5)	; Wandlung von #Long nach PEA/LEA erlaubt ?
	beq.s	Mov_normal
	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),d0
	bne.s	Mov_normal
	cmp.b	#os_LONG,OpcodeSize(a5)
	bne.s	Mov_normal
	cmp.b	#ea_Adirect,oper2+opMode(a5) ; MOVE.l #xxxx,An  -> LEA xxxx,An
	beq	Mov2Lea
	cmp.w	#(ea_AindPreDec<<8)+7,d1 ; MOVE.l #xxxx,-(A7)  ->  PEA xxxx
	beq	Mov2Pea

Mov_normal:
	moveq	#0,d3
	move.b	OpcodeSize(a5),d3
	bne.s	1$
	moveq	#ea_Adirect,d2		; Address register direct ist nicht erlaubt
	cmp.b	oper1+opMode(a5),d2	;  fuer move.b - Befehle
	beq	IllegalMode
	cmp.b	oper2+opMode(a5),d2
	beq	IllegalMode
1$:	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),d0
	bne	6$
	tst.b	oper1+opInfo1(a5)	; Absolut Immediate ?
	bne	5$
	btst	#of_Normal,OptFlag(a5)
	beq	2$
	cmp.b	#os_LONG,OpcodeSize(a5)	; Long-Move.. ?
	blo	2$
	move.b	oper2+opMode(a5),d0	; ..nach  Dn ?
	bne.s	21$
	move.l	oper1+opVal1(a5),d2
	moveq	#-128,d0		; #xxxx liegt zwischen -128 und 127 ?
	cmp.l	d0,d2
	blt	5$
	moveq	#127,d0
	cmp.l	d0,d2
	bgt	5$
	move.w	#$7000,d4		; ** MOVE.l zu MOVEQ optimieren **
	ror.w	#7,d1
	or.w	d1,d4
	move.b	d2,d4
	moveq	#-4,d0
	bsr	ShiftPC			; dadurch 4 Bytes gewonnen
	move.w	d4,d0
	bra	AddWord
21$:	subq.b	#ea_Adirect,d0		; Long-Move nach An ?
	bne.s	2$
	move.l	oper1+opVal1(a5),d0
	beq.s	22$
	bsr	WordLimits		; und #xxxx liegt zwischen -$8000 und $7fff ?
	bne.s	2$
	moveq	#-2,d0
	bsr	ShiftPC			; -> move.w #xxxx,An bringt 2 Bytes
	subq.b	#1,oper1+opSize1(a5)
	subq.b	#1,d3
	bra	6$
22$:	; MOVE.L #0,An  zu  SUB.L An,An  optimieren
	moveq	#-4,d0
	bsr	ShiftPC
	move.w	#$91c8,d0
	move.b	oper2+opReg(a5),d1
	or.b	d1,d0
	add.w	d1,d1
	lsl.w	#8,d1
	or.w	d1,d0
	bra	AddWord
2$:	btst	#of_Special,OptFlag(a5)
	beq.s	5$
	move.l	oper1+opVal1(a5),d0
	bne.s	4$			; MOVE.x #0,ea ?
	cmp.b	#ea_Adirect,oper2+opMode(a5)
	beq.s	4$			; CLR An  gibt's nicht!
	moveq	#-2,d0
	moveq	#-5,d1
	cmp.b	#os_LONG,d3		; Umwandlung in CLR.x ea bringt 2 oder 4 Bytes
	bne.s	3$
	moveq	#-4,d0
	moveq	#-9,d1
3$:	bsr	ShiftLastDists
	move.l	d0,d1
	moveq	#0,d0
	bsr	ChangeLastRefs
	move.l	d1,d0
	bsr	ShiftLastRelocs
	bsr	ShiftPC
	move.w	#$4200,d4
	ror.b	#2,d3
	or.b	d3,d4
	lea	oper2(a5),a2
	move.w	#$00a0,d2
	bra	WriteStdEA
4$:	addq.b	#1,d0
	bne.s	5$
	tst.b	d3			; MOVE.b #-1,ea ?
	bne.s	5$
	moveq	#-2,d1			; ->  st ea  bringt 2 Bytes
	moveq	#0,d0
	bsr	ChangeLastRefs
	moveq	#-2,d0
	moveq	#-5,d1
	bsr	ShiftLastDists
	bsr	ShiftLastRelocs
	bsr	ShiftPC
	move.w	#$50c0,d4
	lea	oper2(a5),a2
	move.w	#$00a0,d2
	bra	WriteStdEA
5$:	tst.b	oper1+opImmedByte(a5)	; #Immediate-Byte?
	beq.s	6$
	clr.b	oper1+opVal1+2(a5)
6$:	add.w	d3,d3
	move.w	MovOpcode(pc,d3.w),d4	; OpcodeBase fuer move.b, move.w oder move.l
	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	lsl.b	#3,d0
	or.b	oper2+opMode(a5),d0
	lsl.w	#6,d0
	move.b	oper1+opMode(a5),d4
	lsl.b	#3,d4
	or.b	oper1+opReg(a5),d4
	or.w	d4,d0
	bsr	AddWord
	moveq	#$20,d2
	bra	WriteExt
MovOpcode:
	dc.w	$1000,$3000,$2000


Mov2Lea:
	move.w	#$41c0,d4		; MOVE.l #xxxx,An  ->	   LEA xxxx,An
	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	lea	oper1(a5),a2
	move.b	#ea_AbsLong&7,opReg(a2)
	tst.b	opInfo1(a2)
	bne	PeaLeaOpt
	move.l	opVal1(a2),d0
	bne.s	Mov2Wchk		; LEA 0,An ?
	btst	#of_Normal,OptFlag(a5)
	beq.s	Mov2W
	bsr	DelLastRefs
	moveq	#-4,d0			; Durch  LEA 0,An -> SUBA.L An,An  4 Bytes gew.
	bsr	ShiftPC
	move.w	#$91c8,d0
	move.b	oper2+opReg(a5),d1
	or.b	d1,d0
	add.w	d1,d1
	lsl.w	#8,d1
	or.w	d1,d0
	bra	AddWord

Mov2Pea:
	move.w	#$4840,d4
	lea	oper1(a5),a2
	move.b	#ea_AbsLong&7,opReg(a2)
	tst.b	opInfo1(a2)
	bne.s	PeaLeaOpt
	move.l	opVal1(a2),d0
	bne.s	Mov2Wchk		; PEA 0 ?
	btst	#of_Special,OptFlag(a5)
	beq.s	Mov2W
	bsr	DelLastRefs
	moveq	#-4,d0			; Durch  PEA 0  ->  CLR.L -(SP)  4 Bytes gew.
	bsr	ShiftPC
	move.w	#$42a7,d0
	bra	AddWord
Mov2Wchk:
	bsr	WordLimits
	bne.s	PeaLeaOpt
Mov2W:
	subq.b	#1,opReg(a2)		; PEA xxxx.L  nach PEA xxxx.W	wandeln
	subq.b	#1,opSize1(a2)
	moveq	#EXT_REF16,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	moveq	#-2,d0			; 2 Bytes gewonnen
	bsr	ShiftPC
	moveq	#$60,d2
	bra	WriteStdEA

PeaLeaOpt:
; d4 = Opcode, a2 = oper1
	cmp.w	#(ea_SpecialMode<<8)+(ea_AbsLong&7),opMode(a2)
	bne.s	9$
	btst	#of_Normal,OptFlag(a5)
	beq.s	9$
	tst.b	opType1(a2)		; PEA/LEA Reloc aus aktueller Section?
	bpl.s	4$
	move.l	opVal1(a2),d0
	move.l	d0,d2
	sub.l	d6,d0
	addq.l	#4,d0
	bsr	WordLimits		; nach PC-Displace wandeln waere moeglich?
	bne.s	4$
	moveq	#EXT_REF16,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	bsr	DelLastRelocs
	move.l	d2,d0
	move.l	d6,d1
	subq.l	#4,d1
	moveq	#0,d2
	moveq	#os_WORD,d3
	move.l	d1,a1
	bsr	ReplaceDistance
	move.l	d1,opVal1(a2)
	move.b	#1,opType1(a2)
	subq.b	#1,opSize1(a2)
	addq.b	#1,opReg(a2)
	moveq	#-2,d0
	bsr	ShiftPC
9$:	moveq	#$60,d2
	bra	WriteStdEA
4$:	tst.b	Model(a5)		; NEAR-Mode aktiv?
	bmi.s	9$
	move.b	opInfo1(a2),d2
	beq.s	9$
	subq.b	#1,d2			; DeclSection des Symbols
	bsr	GetSectionPtr		; Zeiger auf Section Nummer d2 holen
	tst.b	sec_Near(a0)		; ist diese NEAR zu adressieren?
	beq.s	9$
	move.l	opVal1(a2),d0
	move.l	d0,d1
	sub.l	sec_Origin(a0),d1	; Offset auf Section-BaseAddress
	swap	d1
	tst.w	d1			; Adresse im Near-Bereich ?
	bne.s	9$			;  wenn nicht: PC-Displace versuchen
	move.l	sec_Origin(a0),d1
	move.w	d2,d5
	moveq	#-$80,d3		; Subtrahend static (nicht verschiebbar)
	move.w	#os_NEARWORD,d3
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	45$
	add.l	#$7ffe,d1		; SecNum fuer NearReloc nicht benoetigt
	move.w	#os_WORD,d3
	ENDC
45$:	moveq	#0,d2
	move.l	d6,a1
	subq.l	#4,a1
	bsr	ReplaceDistance		; Near-Adressierung als Distanz merken
	neg.b	opType1(a2)
	beq.s	42$
	move.l	d1,opVal1(a2)
	bra.s	46$
42$:	move.w	d0,opVal1+2(a2)
46$:
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	43$
	ENDC
	bsr	DelLastRelocs
	move.l	d6,d0
	subq.l	#4,d0
	move.w	d5,d1
	bsr	AddNearReloc
43$:	moveq	#EXT_DEXT16,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	moveq	#-2,d0			; Code wird dadurch um 2 Bytes kuerzer
	bsr	ShiftPC
	subq.b	#1,opSize1(a2)
	move.w	#ea_AindDispl<<8,d0
	move.b	Model(a5),d0
	move.w	d0,opMode(a2)
	moveq	#$60,d2
	bra	WriteStdEA


MovtoUSPorSR:
	cmp.w	#(ea_SpecialMode<<8)+(ea_USP&7),d1
	bne.s	MovtoSRorCCR
	cmp.b	#ea_Adirect,oper1+opMode(a5)
	bne	IllegalMode		; MOVE Ax,USP - SrcOperand muss Adirect sein
	move.w	#$4e60,d0
	or.b	oper1+opReg(a5),d0
	bra	AddWord			; Opcode speichern

MovtoSRorCCR:
	; MOVE ea,SR oder MOVE ea,CCR
	cmp.b	#ea_Adirect,oper1+opMode(a5)
	beq	IllegalMode		; 'ea' darf nicht 'An' sein
	move.b	OpcodeSize(a5),d5
	cmp.b	#os_LONG,d5		; Size darf nicht Long sein
	bhs	IllegalMode
	move.w	#$44c0,d0		; Opcode fuer MOVE ea,CCR
	tst.b	d5			; MOVE ea,SR ?
	beq.s	1$
	or.w	#$0200,d0
1$:	move.b	oper1+opMode(a5),d1
	lsl.b	#3,d1
	or.b	oper1+opReg(a5),d1
	or.b	d1,d0
	bsr	AddWord			; Opcode speichern
	moveq	#$60,d2
	bra	WriteExt

MovUSPorSR:
	cmp.w	#(ea_SpecialMode<<8)+(ea_USP&7),d0
	bne.s	MovSRorCCR
	cmp.b	#ea_Adirect,oper2+opMode(a5)
	bne	IllegalMode		; MOVE USP,Ax - DestOperand muss Adirect sein
	move.w	#$4e68,d0
	or.b	d1,d0
	bra	AddWord			; Opcode speichern

MovSRorCCR:
	; MOVE SR,ea  oder  MOVE CCR,ea (68010)
	cmp.b	#ea_Adirect,oper2+opMode(a5)
	beq	IllegalMode		; 'ea' darf weder Adirect noch PC-relativ sein
	cmp.w	#(ea_SpecialMode<<8)+(ea_AbsLong&7),d1
	bhi	IllegalMode
	move.b	OpcodeSize(a5),d5
	cmp.b	#os_WORD,d5		; Die opcode-size muss Word-Breite haben
	beq.s	3$
	bhi	IllegalMode
	tst.b	Machine(a5)		; MOVE CCR,ea	  ist erst ab 68010 erlaubt
	beq	IllegalInstr
3$:	move.w	#$40c0,d0		; Opcode fuer MOVE SR,ea
	tst.b	d5			; MOVE CCR,ea ?
	bne.s	4$
	or.w	#$0200,d0
4$:	move.b	oper2+opMode(a5),d1
	lsl.b	#3,d1
	or.b	oper2+opReg(a5),d1
	or.b	d1,d0
	bsr	AddWord			; Opcode speichern
	move.w	#$a0,d2
	bra	WriteExt


	cnop	0,4
MovQ:
	; MOVEQ #x,Dy
	jmp	MovQ2(pc)
	addq.l	#2,d6
	rts
MovQ2:
	move.l	a3,a0
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	st	RefFlag(a5)
	moveq	#os_BYTE,d0
	bsr	GetValue
	tst.w	d2
	bmi	UndefSym
	beq.s	4$			; Normales #x ?
	tst.b	d2			; Nur Programm-Distanzen sind erlaubt
	bmi	AddrError
	move.w	#9,d2
	swap	d2
	moveq	#os_BYTE,d3
	move.l	d6,a1
	addq.l	#1,a1
	bsr	AddDistance
4$:	move.l	d0,d2			; #x auf Byte-Grenzen checken -$80 bis $ff
	bpl.s	6$
	not.l	d2
	add.l	d2,d2
	clr.b	d2
	tst.l	d2
	beq.s	1$			; -128 .. -1 ?
5$:	tst.b	DistChkDisable(a5)
	bne.s	1$
	move.b	d0,d1
	bsr	ImmedSize		; Immediate operand size error
	move.b	d1,d0
	bra.s	1$
6$:	move.b	d2,d1
	clr.b	d2
	tst.l	d2
	bne.s	5$			; 0 .. 255
	add.b	d1,d1
	bcc.s	1$			; 128 .. 255 ?
	lea	movqwarn(pc),a1
	bsr	Warning
1$:	move.b	d0,d4			; x im Opcode einsetzen
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0			; Ay ?
	beq.s	2$
	bsr	NeedDReg
2$:	add.w	d0,d0
	lsl.w	#8,d0
	or.w	d4,d0			; Opcode fertig
	addq.l	#2,d6
	bra	AddWord

movqwarn:
	dc.b	"moveq > 127",0


	cnop	0,4
MovM:	; MOVEM.x RegList,ea / ea,RegList
	jmp	MovM2(pc)
	bsr	SplitOperand
	cmp.b	#':',(a3)		; :RegList,ea ?
	beq.s	3$
	move.l	a3,a0
	bsr	GetRegister
	bmi.s	1$			; RegList,ea ?
3$:	addq.l	#2,d6
	move.w	#$00a0,d3
	bra	SplittedInstrSize
1$:	cmp.b	#':',(a2)		; ea,:RegList ?
	beq.s	4$
	move.l	a2,a0
	bsr	GetRegister
	bmi.s	2$			; ea,RegList ?
4$:	addq.l	#2,d6
	moveq	#$60,d3
	bra	SplittedInstrSize
2$:	subq.l	#2,d6
	moveq	#$20,d3			; unknown,unknown (= InstrSize - 2)
	bra	SplittedInstrSize

MovM2:
	st	RefFlag(a5)
	addq.l	#2,d6
	addq.w	#5,ListFileOff(a5)	; LFO hinter die RegMask setzen
	move.l	a3,a0
	bsr	MovMcolon		; :RegList,ea ?
	bpl.s	1$
	move.l	a3,a0
	bsr	GetRegList		; RegList im SourceOperand?
	bpl.s	1$
	move.l	a3,a0
	lea	Buffer(a5),a2
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; vermutlichen RegList-Symbolnamen lesen
	move.l	a2,a0
	cmp.b	#'$',(a3,d0.w)
	IFND	DOTNOTLOCAL
	beq.s	5$
	cmp.b	#'.',(a0)
	ENDIF
	bne.s	3$
5$:	bsr	FindLocalSymbol
	beq.s	MovM3
	bra.s	4$
3$:	bsr	FindSymbol		; ist es ein RegList-Symbol?
	beq.s	MovM3
4$:	move.l	d0,a0
	cmp.w	#T_REG,sym_Type(a0)
	bne.s	MovM3
	move.l	d6,d5
	bsr	RegListRef		; Referenz eintragen, Register zaehlen
1$:	movem.l	d0-d1,-(sp)
	move.w	#%0000001101110100,d0
	move.w	#$00a0,d1
	bsr	GetOperand		; Dest.Operand auswerten
	bpl.s	2$
	addq.l	#8,sp
	rts
2$:	movem.l	(sp)+,d0-d1
	move.w	#$4880,d4
	lea	oper2(a5),a2
	lea	oper1(a5),a3
	cmp.b	#ea_AindPreDec,opMode(a2)
	bne.s	MovM4
	swap	d0			; Inverse RegMask fuer -(An) Mode
	bra.s	MovM4
MovM3:
	move.l	d6,-(sp)
	move.l	#%00001111011011000000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand		; SourceOperand auswerten
	bpl.s	1$
	addq.l	#4,sp
	rts
1$:	move.l	(sp)+,d5
	tst.b	(a2)
	beq.s	4$			; Zieloperand fehlt?
	move.l	a2,a0
	bsr	MovMcolon		; ea,:RegList ?
	bpl.s	3$
5$:	move.l	a2,a0
	bsr	GetRegList		; RegList muss jetzt aber im Dest.Oper sein
	bpl.s	3$
	move.l	a2,a0
	bsr	FindGorLSymbol		; ist es ein RegList-Symbol?
	beq	UndefSym
	move.l	d0,a0
	cmp.w	#T_REG,sym_Type(a0)
	beq.s	2$
	moveq	#27,d0			; Bad register list
	bra	Error
4$:	moveq	#94,d0			; Missing Operand
	bra	Error
2$:	bsr	RegListRef		; Referenz eintragen, Register zaehlen
3$:	move.w	#$4c80,d4
	lea	oper1(a5),a2
	lea	oper2(a5),a3

MovM4:
	clr.w	opSize1(a3)
	clr.w	opFormat(a3)
	move.w	d0,d2			; d2 RegMask
	btst	#of_MoveM,OptFlag(a5)
	beq.s	5$
	subq.w	#1,d1
	bpl.s	1$			; ueberhaupt kein Register in der RegList ?
	bsr	DelLastRefs		; movem-Befehl vollstaendig entfernen
	bsr	DelLastRelocs
	bsr	DelLastDists
	moveq	#-2,d0
	sub.b	opSize1(a2),d0
	sub.b	opSize2(a2),d0
	add.w	d0,d0
	bra	ShiftPC
1$:	bne.s	5$			; nur 1 Register in der RegList ?
	tst.b	Movem2MoveOpt(a5)	; MOVEM -> MOVE Dn Optimierung erlaubt?
	beq.s	5$
	moveq	#15,d3
2$:	add.w	d0,d0			; Einzel-Register bestimmen -> d3
	dbcs	d3,2$
	cmp.b	#ea_AindPreDec,opMode(a2)
	bne.s	3$
	eor.w	#15,d3			; Invertieren bei Preindexed-Mode -(An)
3$:	moveq	#ea_Adirect,d2
	bclr	#3,d3			; Adressregister?
	bne.s	4$
	moveq	#ea_Ddirect,d2
4$:	moveq	#-2,d0			; RegMask wird nicht mehr benoetigt
	bsr	ShiftPC
	moveq	#0,d0
	moveq	#-2,d1
	bsr	ChangeLastRefs		; Referenzen verschieben
	moveq	#-2,d0
	moveq	#-5,d1
	bsr	ShiftLastDists		; Distanzen verschiben
	moveq	#-2,d0
	bsr	ShiftLastRelocs
	move.b	d2,opMode(a3)		; normalen MOVE-Befehl basteln
	move.b	d3,opReg(a3)
	bra	Mov_start
5$:	cmp.b	#os_WORD,OpcodeSize(a5)
	blo	IllegalMode		; MOVEM.b ?
	beq.s	6$
	or.w	#$0040,d4
6$:	moveq	#0,d0
	move.b	opMode(a2),d0
	lsl.b	#3,d0
	or.b	opReg(a2),d0
	or.w	d4,d0
	bsr	AddWord			; OpCode
	move.w	d2,d0
	bsr	AddWord			; RegMask
	moveq	#$20,d2
	bra	WriteExt

RegListRef:
; a0 = RegList-Symbol
; d5 = RegMask-Addr
; scratch: d2,d3,d4
; -> d0 = Value
; -> d1 = usedRegs
	move.l	sym_Value(a0),d0	; RegList fuer Source und Dest.
	moveq	#0,d1
	moveq	#15,d2
	move.l	d0,d3
	moveq	#0,d4
1$:	add.w	d0,d0			; benutzte Register zaehlen
	addx.w	d1,d4
	dbf	d2,1$
	moveq	#REF_REGLIST,d0
	move.l	d5,d1
	bsr	AddReference		; REG-Symbolreferenz vermerken
	move.l	d3,d0
	move.w	d4,d1
	rts

MovMcolon:
; a0 = Operand
; -> d0 = SrcDest RegList
; -> d1 = NumRegs
; N-Flag = Error
	cmp.b	#':',(a0)+
	bne.s	12$
	moveq	#os_WORD,d0
	bsr	GetValue		; :RegList Konstante bestimmen
	tst.w	d2
	beq.s	1$
	bmi.s	10$
	bra.s	11$
1$:	movem.l	d2-d3,-(sp)
	moveq	#0,d1
	moveq	#15,d2
	move.w	d0,d3
	swap	d0
	clr.w	d0
2$:	add.w	d3,d3
	bcc.s	3$
	addq.w	#1,d0
	addq.b	#1,d1
3$:	ror.w	#1,d0
	dbf	d2,2$
	movem.l	(sp)+,d2-d3
	swap	d0
	tst.w	d1
	rts
10$:	bsr	UndefSym
	bra.s	12$
11$:	bsr	AddrError
12$:	moveq	#-1,d1
	rts


	cnop	0,4
AS:					; ADD.x ea,Dn / SUB.x ea,Dn  oder  Dn,ea
	jmp	AS2(pc)
	moveq	#$20,d1
	bra	InstrSize
AS2:
	move.l	#%00011111011111110000001101111111,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	lea	oper1(a5),a2
	lea	oper2(a5),a3
	move.b	OpcodeSize(a5),d5
	move.b	opMode(a3),d1
	cmp.b	#ea_Adirect,d1
	beq	ASA_start		; ADDA/SUBA.x ea,An ?
	move.b	opMode(a2),d0
	beq.s	ASfromD			; Dn,ea ?
	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),opMode(a2)
	beq.s	2$
	tst.b	d1
	beq.s	AStoD			; ea,Dn ?
	bra	IllegalMode

2$:	tst.b	d1			; #x,Dn ?
	bne.s	5$
	moveq	#(1<<of_Quick)|(1<<of_Normal),d2
	and.b	OptFlag(a5),d2		; Optimierungsversuch?
	beq.s	AStoD
	tst.b	opInfo1(a2)		; Absolute-Immediate?
	bne.s	AStoD
	move.l	opVal1(a2),d3		; #x
	beq.s	AStoD
	and.b	#1<<of_Quick,d2
	beq.s	AStoD
	moveq	#8,d2
	cmp.l	d2,d3			; ADDI/SUBI #1..8,ea ?
	bhi.s	AStoD
	pea	ASI_QOpt(pc)
	bra.s	10$
5$:	pea	ASI_start(pc)
10$:	exg	a2,a3
	and.w	#$4000,d4
	bne.s	11$
	move.w	#$0400,d4		; SUBI
	or.b	d5,d4
	rts
11$:	move.w	#$0600,d4		; ADDI
	or.b	d5,d4
	rts

ASfromD:
	tst.b	d1
	beq.s	AStoD			; Dn,Dn ?
	cmp.b	#ea_Adirect,d1
	beq	ASA_start		; ADDA.x Dn,An ?
	or.w	#$0100,d4
	move.w	#$a0,d2
	exg	a2,a3
	bra.s	AS3
AStoD:
	moveq	#$60,d2
	tst.b	d5
	bne.s	AS3
	cmp.b	#ea_Adirect,d0
	beq	IllegalMode		; ADD.b An,Dn	     ist illegal

AS3:
	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),opMode(a2)
	bne.s	AS4
	tst.b	opInfo1(a2)		; Absolute-Immediate?
	bne.s	AS4
	btst	#of_Quick,OptFlag(a5)	; optimieren ?
	beq.s	4$
	move.l	opVal1(a2),d3
	beq.s	4$			; #0 ?
	moveq	#8,d1
	cmp.l	d1,d3
	bhi.s	4$
	moveq	#-2,d0
	cmp.b	#os_LONG,d5
	bne.s	2$
	moveq	#-4,d0
2$:	bsr	ShiftPC			; Speicher fuer Immediate wird nicht benoetigt
	moveq	#7,d0
	and.w	d3,d0
	ror.w	#7,d0
	or.w	#$5000,d0		; ADDQ/SUBQ zusammensetzen
	and.w	#$4000,d4
	bne.s	3$
	or.w	#$0100,d0		; SUBQ
3$:	ror.b	#2,d5
	move.b	d5,d0			; Size einsetzen
	or.b	opReg(a3),d0		; Dn
	bra	AddWord
4$:	tst.b	opImmedByte(a2)		; #Immediate-Byte?
	beq.s	AS4
	clr.b	opVal1+2(a2)
AS4:
	moveq	#0,d0
	move.b	opReg(a3),d0
	ror.w	#7,d0
	or.w	d0,d4
	ror.b	#2,d5
	move.b	d5,d4
	bra	WriteStdEA


	cnop	0,4
ASA:					; ADDA.x ea,An / SUBA.x ea,An
	jmp	ASA2(pc)
	moveq	#$60,d1
	bra	InstrSize
ASA2:
	move.l	#%00011111011111110000000000000010,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	move.b	OpcodeSize(a5),d5
	lea	oper1(a5),a2
ASA_start:
	cmp.b	#os_WORD,d5
	blo	IllegalMode		; .b ist nicht erlaubt
	beq.s	1$
	or.w	#$0100,d4
1$:	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),opMode(a2)
	bne.s	2$
	tst.b	opInfo1(a2)		; Absolute-Immediate?
	beq.s	3$
2$:	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	or.w	#$00c0,d4
	moveq	#$60,d2
	bra	WriteStdEA

3$:	move.l	opVal1(a2),d2		; ADDA optimieren
	bne.s	5$			; ADDA.x #0,An  wird vollstaendig entfernt
	btst	#of_Special,OptFlag(a5)
	beq.s	2$
	moveq	#-4,d0
	subq.b	#os_LONG,d5
	bne.s	4$
	moveq	#-6,d0
4$:	bsr	ShiftPC
	bra	DelLastRefs
5$:	moveq	#8,d0			; ADD/SUB #1..8,An ?
	cmp.l	d0,d2
	bls.s	7$
	moveq	#-8,d0
	cmp.l	d0,d2
	blo.s	6$
	neg.w	d2			; ADD #-n -> SUB #n (oder umgekehrt)
	eor.w	#$4000,d4
	bra.s	7$
6$:	cmp.b	#os_WORD,d5		; ADD/SUB.w #x,An IMMER nach LEA optimieren!
	beq.s	10$
	move.l	#$7fff,d0		; ADD/SUB #9..32767,An ?
	cmp.l	d0,d2
	bls.s	10$
	not.l	d0
	cmp.l	d0,d2			; ADD/SUB #-9..-32768,An ?
	blo.s	2$
	bra.s	10$
7$:	btst	#of_Quick,OptFlag(a5)
	beq.s	6$
	moveq	#-2,d0
	subq.b	#os_WORD,d5
	beq.s	8$
	moveq	#-4,d0
8$:	bsr	ShiftPC
	moveq	#7,d0
	and.w	d2,d0
	ror.w	#7,d0
	or.w	#$5088,d0		; ADDQ.l/SUBQ.l zusammensetzen
	and.w	#$4000,d4
	bne.s	9$
	or.w	#$0100,d0		; SUBQ.l
9$:	or.b	oper2+opReg(a5),d0	; An
	bra	AddWord
10$:	btst	#of_Normal,OptFlag(a5)
	beq	2$
	subq.b	#os_WORD,d5
	beq.s	11$
	moveq	#-2,d0			; ADD/SUB.L #x,An -> LEA x(An) bringt 2 Bytes
	bsr	ShiftPC
11$:	and.w	#$4000,d4
	bne.s	12$
	neg.w	d2			; bei SUB das Displacement negieren
12$:	moveq	#0,d0			; LEA d(An),An zusammensetzen
	move.b	oper2+opReg(a5),d1
	move.b	d1,d0
	ror.w	#7,d0
	or.w	#$41e8,d0
	or.b	d1,d0
	bsr	AddWord			; Opcode
	move.w	d2,d0
	bra	AddWord			; Displacement


ASQ:					; ADDQ.x #x,ea / SUBQ.x #x,ea
	jmp	ASQ2(pc)
	move.w	#$a0,d1
	bra	InstrSize
ASQ2:
	move.l	#%00010000000000000000001101111111,d0
	move.w	#$a0,d1
	bsr	GetOperand
	bpl.s	9$
	rts
9$:	tst.b	(a1)
	bne	SyntaxErr
	lea	oper2(a5),a2
	move.b	OpcodeSize(a5),d4
	bne.s	1$
	cmp.b	#ea_Adirect,opMode(a2)
	beq	IllegalMode		; ADDQ.b/SUBQ.b #x,An	     ist illegal
1$:	ror.b	#2,d4
	move.l	a3,a0
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	moveq	#os_BYTE,d0
	bsr	GetValue		; #x lesen
	tst.w	d2
	bmi	UndefSym
	bne	AddrError		; muss Absolute-Immediate sein
	move.l	d0,d1
	bne.s	3$			; #x im Bereich von 1-8 ?
2$:	bra	ImmedSize
3$:	bmi.s	2$
	subq.l	#8,d1
	bhi.s	2$
	ror.w	#7,d0
	or.w	d0,d4
	move.w	#$a0,d2
	bra	WriteStdEA


	cnop	0,4
Bra:					; Bcc displacement  (branch conditionally)
	jmp	Bra2(pc)
	addq.l	#2,d6
	move.b	OpcodeSize(a5),d0
	beq.s	1$			; .B (8-Bit Branch)
	subq.b	#os_SINGLE,d0		; .S (8-Bit Branch)
	beq.s	1$
	addq.l	#2,d6
	IFND	SMALLASS
	addq.b	#os_SINGLE-os_WORD,d0	; .W (16-Bit Branch)
	beq.s	1$
	cmp.b	#2,Machine(a5)		; 68020 ? Dann ist .L auch 16-Bit
	blo.s	1$
	addq.l	#2,d6			; .L (32-Bit Branch 020+)
	ENDC
1$:	rts

	cnop	0,4
Bra2:
	st	RefFlag(a5)
	move.b	OpcodeSize(a5),d5
	cmp.b	#os_SINGLE,d5		; .s = ShortBranch(.b)
	bne.s	1$
	moveq	#0,d5
	clr.b	OpcodeSize(a5)
1$:	addq.l	#2,d6
	move.l	a3,a0
	moveq	#os_WORD,d0
	bsr	GetValue
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	tst.b	d2
	bpl.s	2$			; Sprungmarke muss vom Type Reloc
	clr.w	d2
	swap	d2
	cmp.w	SecNum(a5),d2		;  aus derselben Section
	beq.s	4$
	moveq	#48,d0			; "Displacement outside of section"
	bra	Error
2$:	bne	NoAddress
	swap	d2
	addq.w	#1,d2			;   oder vom Typ XREF sein
	bne	NoAddress
	moveq	#-1,d2
	move.l	d0,d3
	subq.b	#1,d5
	bmi	BraShort2
	IFND	SMALLASS
	beq	Bra16
	cmp.b	#2,Machine(a5)		; 68020 Long-Branch moeglich?
	bhs.s	Bra32
	ENDC
	bra	Bra16
4$:	move.l	d0,d3
	subq.b	#1,d5
	bmi	BraShort
	IFND	SMALLASS
	beq.s	BraLong
	cmp.b	#2,Machine(a5)		; 68020 Long-Branch moeglich?
	blo.s	BraLong

	btst	#of_Branches,OptFlag(a5)
	beq.s	Bra32
	sub.l	d6,d0
	bsr	WordLimits		; Pruefen ob auch als 16-bit Branch moeglich
	bne.s	Bra32
	moveq	#-2,d0
	bsr	BraShift
	bra.s	BraLong2
Bra32:
	moveq	#EXT_RELREF32,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	move.w	d4,d0
	st	d0
	bsr	AddWord
	move.l	d3,d0
	tst.w	d2
	bmi.s	2$
	move.l	d6,d1
	moveq	#os_LONG,d3
	move.l	d6,a1
	tst.b	TotalBccOpt(a5)		; Totale Branch-Optimierung durchführen?
	beq.s	1$
	cmp.l	d1,d0
	bls.s	1$
	btst	#of_Branches,OptFlag(a5)
	beq.s	1$
	moveq	#os_BRANCH+os_LONG,d3
1$:	bsr	AddDistance
2$:	addq.l	#4,d6
	bra	AddLong
	ENDC

BraLong:
	sub.l	d6,d0
	bsr	WordLimits		; Prüfen ob Bcc.w in 16-Bit Grenzen
	beq.s	BraLong2
	IFND	SMALLASS
	btst	#of_Branches,OptFlag(a5)
	beq.s	BraLErr			; Bcc.w in Bcc.l ändern erlaubt?
BraLong020:
	cmp.b	#2,Machine(a5)
	blo	BraAutoNcc
	moveq	#2,d0			; ab 68020 in Bcc.l ändern
	bsr	BraShift
	bra.s	Bra32
	ENDC
BraLErr:
	tst.b	DistChkDisable(a5)
	beq	LargeDist
BraLong2:
	btst	#of_Branches,OptFlag(a5)
	beq.s	Bra16
	move.l	d3,d0
	sub.l	d6,d0
	beq.s	Bra16			; 0-Displacement nicht optimieren!
	moveq	#127,d1			; Prüfen ob auch als Short-Branch möglich
	cmp.l	d1,d0
	bgt.s	Bra16
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	Bra16
	subq.l	#2,d0			; Nicht zu 0-Displace optimieren!
	beq.s	1$
;*-bug	subq.l	#4,d0			; Nicht zu 0-Displace optimieren!
;*-bug	bls.s	1$
	moveq	#-2,d0
	bsr.s	BraShift
	bra	BraShort2
1$:	btst	#of_Special,OptFlag(a5)	; B<cc> in Folgezeile auflösen?
	beq.s	Bra16
	bsr	DelLastRefs
	bsr	DelLastDists
	move.l	d6,a0
	subq.l	#2,d6
	moveq	#-4,d0
	bra	ShiftRelocs
Bra16:
	move.w	d4,d0
	bsr	AddWord
	move.l	d3,d0
	tst.w	d2			; XREF?
	bmi.s	2$
	move.l	d6,d1
	moveq	#os_WORD,d3
	move.l	d6,a1
	tst.b	TotalBccOpt(a5)		; Totale Branch-Optimierung durchfuehren?
	beq.s	3$
	cmp.l	d1,d0
	bls.s	3$
	btst	#of_Branches,OptFlag(a5)
	beq.s	3$
	moveq	#os_BRANCH+os_WORD,d3
3$:	bsr	AddDistance
2$:	addq.l	#2,d6
	bra	AddWord

BraShift:
	; Verschiebt den folgenden Code um d0 Bytes
	move.l	d3,oper1+opVal1(a5)
	st	oper1+opType1(a5)
	move.l	d6,a0
	bsr	ShiftRelocs
	move.l	oper1+opVal1(a5),d3
	rts

Bra0:
	; Bcc.B *+2 in Bcc.W *+4 umwandeln
	moveq	#2,d0
	move.l	d6,a0
	bsr	ShiftRelocs
	addq.l	#2,d3
	bra.s	Bra16
BraShort:
	sub.l	d6,d0			; Bcc.B *+2 ist verboten!
	beq.s	Bra0
	moveq	#127,d1			; Pruefen ob Bcc.s in 8-Bit Grenzen
	cmp.l	d1,d0
	bgt.s	1$
	moveq	#-128,d1
	cmp.l	d1,d0
	bge.s	BraShort2
1$:	btst	#of_Branches,OptFlag(a5)
	beq.s	2$			; Bcc.b in Bcc.w aendern erlaubt?
	moveq	#2,d0
	bsr.s	BraShift
	move.l	d3,d0
	sub.l	d6,d0
	bsr	WordLimits		; Passt es denn auch in Bcc.w ?
	beq.s	Bra16
	IFND	SMALLASS
	bra	BraLong020
	ELSE
	bra	BraLErr
	ENDC
2$:	tst.b	DistChkDisable(a5)
	beq	LargeDist
BraShort2:
	moveq	#EXT_REF8,d0
	moveq	#-1,d1
	bsr	ChangeLastRefs
	move.l	d3,d0
	move.l	d6,d1
	swap	d2			; XREF?
	bmi.s	1$
	move.w	#9,d2
	swap	d2
	move.l	#((1<<6)<<16)|os_BYTE,d3 ; create ShortBranch distance
	move.l	d6,a1
	subq.l	#1,a1
	bsr	AddDistance
1$:	move.b	d0,d4
	move.w	d4,d0
	bra	AddWord


BraAutoNcc:
	cmp.w	#$6200,d4		; BRA/BSR? - direkt in JMP/JSR ändern
	blo.s	1$
	moveq	#4,d0			; Bcc.w -> B!cc.b *+6 und JMP
	bsr	BraShift
	eor.w	#$0100,d4		; B!cc erzeugen
	move.w	d4,d0
	addq.w	#6,d0
	bsr	AddWord
	moveq	#0,d4
	moveq	#2,d1
	addq.l	#2,d6
	bra.s	2$
1$:	; JMP/JSR label
	moveq	#2,d0
	bsr	BraShift
	moveq	#0,d1
2$:	moveq	#EXT_REF32,d0
	bsr	ChangeLastRefs
	move.w	#$4eb9,d0
	btst	#8,d4			; bra oder bsr?
	bne.s	3$
	move.w	#$4ef9,d0
3$:	bsr	AddWord
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	4$			; Neuer Eintrag fuer Reloc32 bei Objectfile
	ENDC
	move.l	d6,d0
	move.w	d2,d1
	bsr	AddRelocation
4$:	move.l	d3,d4
	move.l	d3,d0
	moveq	#0,d1
	moveq	#os_LONG,d3
	move.l	d6,a1
	bsr	AddDistance
	addq.l	#4,d6
	move.l	d4,d0
	bra	AddLong


DBra:					; DBcc Dn,displacement
	jmp	DBra2(pc)
	addq.l	#4,d6
	rts
DBra2:
	st	RefFlag(a5)
	move.l	a3,a0
	bsr	GetRegister		; Dn bestimmen
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedDReg
	move.l	a0,a3
	or.w	d4,d0
	addq.l	#2,d6
	bsr	AddWord			; Opcode
	cmp.b	#',',(a3)+
	bne	SyntaxErr
	move.l	a3,a0
	moveq	#os_WORD,d0
	bsr	GetValue		; displacement lesen
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	tst.b	d2
	bpl.s	1$			; displacement muss vom Type Reloc
	clr.w	d2
	swap	d2
	cmp.w	SecNum(a5),d2		;  aus derselben Section
	beq.s	2$
	moveq	#48,d0			; "Displacement outside of section"
	bra	Error
1$:	bne	NoAddress
	swap	d2
	addq.w	#1,d2			;   oder vom Typ XREF sein
	bne	NoAddress
	moveq	#-1,d2
2$:	move.l	d0,d3
	sub.l	d6,d0
	bsr	WordLimits		; Sprungmarke in Reichweite?
	beq.s	3$
	tst.b	DistChkDisable(a5)
	beq	LargeDist
3$:	move.l	d3,d0
	move.l	d6,d1
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	addq.l	#2,d6
	bra	AddWord


Pea:					; PEA ea
	jmp	Pea2(pc)
	moveq	#$60,d1
	bra	InstrSize
Pea2:
	move.l	#%00001111011001000000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a2)
	bne	SyntaxErr
	lea	oper1(a5),a2
	btst	#of_Special,OptFlag(a5)
	beq.s	3$
	tst.l	opVal1(a2)		; PEA 0? (0,An) (0,PC) 0.w 0.l etc...
	bne.s	3$
	moveq	#-2,d0			; PEA 0.w -> CLR.L -(SP)  2 Bytes
	move.w	opMode(a2),d1
	cmp.w	#(ea_SpecialMode<<8)+(ea_AbsShort&7),d1
	beq.s	2$
	cmp.w	#(ea_SpecialMode<<8)+(ea_AbsLong&7),d1
	bne.s	3$
	moveq	#-4,d0			; PEA 0  ->  CLR.L -(SP)  4 Bytes
2$:	tst.b	opInfo1(a2)		; relocatable?
	bne.s	3$
	bsr	ShiftPC
	bsr	DelLastRefs
	move.w	#$42a7,d0
	bra	AddWord
3$:	moveq	#$60,d2
	bra	WriteStdEA


Jmp:					; JMP ea  /  JSR ea
	jmp	Jmp2(pc)
	moveq	#$60,d1
	bra	InstrSize

Jmp2:
	btst	#of_Branches,OptFlag(a5)
	seq	TryPC(a5)
	move.l	#%00001111011001000000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a2)
	bne	SyntaxErr
	lea	oper1(a5),a2
	moveq	#$60,d2
	cmp.w	#(ea_SpecialMode<<8)+(ea_AbsLong&7),opMode(a2)
	bne	WriteStdEA		; nur JMP/JSR x.L  kann optimiert werden
	btst	#sw_NEARCODE,Switches(a5)
	beq.s	3$
	cmp.b	#-1,opInfo1(a2)		; Sprung auf ein XREF-Symbol?
	bne.s	3$
	moveq	#EXT_REF16,d0		; nach PC-Indirekt wandeln
	moveq	#0,d1
	bsr	ChangeLastRefs
	moveq	#-2,d0			; AbsLong->PC-Displace gewinnt 2 Bytes
	bsr	ShiftPC
	subq.b	#1,opSize1(a2)
	addq.b	#1,opReg(a2)
2$:	bra	WriteStdEA
3$:	btst	#of_Branches,OptFlag(a5) ; Jump-Branch Optimierung erlaubt?
	beq.s	2$
	tst.b	opType1(a2)		; Reloc-Sprung innerhalb dieser Section?
	bpl.s	2$
	move.l	opVal1(a2),d0
	sub.l	d6,d0
	addq.l	#4,d0
	bsr	WordLimits		; Sprung innerhalb von 32K Abstand?
	bne.s	2$
	move.w	#$6000,d5		; JMP->BRA , JSR->BSR
	and.w	#$0040,d4
	bne.s	4$
	or.w	#$0100,d5
4$:	moveq	#127,d1			; oder sogar innerhalb von 128 Bytes?
	cmp.l	d1,d0
	bgt.s	5$
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	5$
	subq.w	#4,d0			; Mögliches BRA/BSR.s *+0 ?
	blo.s	5$
	beq.s	7$
	bsr	DelLastRelocs
	moveq	#EXT_REF8,d0
	moveq	#1,d1
	bsr	ChangeLastRefs
	moveq	#-4,d0			; AbsLong->ShortBranch gewinnt 4 Bytes
	bsr	ShiftPC
	move.l	opVal1(a2),d0		; Neue Distance setzen
	move.l	d6,d1
	moveq	#-3,d2
	move.l	#((1<<6)<<16)|os_BYTE,d3 ; ShortBranch-Distance!
	move.l	d1,a1
	subq.l	#1,a1
	bsr	ReplaceDistance
	move.b	d0,d5
	move.w	d5,d0
	bra	AddWord
7$:	subq.l	#2,opVal1(a2)		; Spezialfall: JMP *+6 -> BRA.W *+4
5$:	move.w	d5,d0
	bsr	AddWord
	bsr	DelLastRelocs
	moveq	#EXT_REF16,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	moveq	#-2,d0			; AbsLong->LongBranch gewinnt 2 Bytes
	bsr	ShiftPC
	move.l	opVal1(a2),d0		; Neue Distance setzen
	move.l	d6,d1
	subq.l	#2,d1
	moveq	#0,d2
	moveq	#os_WORD,d3
	move.l	d1,a1
	tst.b	TotalBccOpt(a5)		; Totale Branch-Optimierung durchführen?
	beq.s	6$
	cmp.l	d1,d0
	bls.s	6$
	moveq	#os_BRANCH+os_WORD,d3
6$:	bsr	ReplaceDistance
	bra	AddWord


Lea:					; LEA ea,Ax
	jmp	Lea2(pc)
	moveq	#$60,d1
	bra	InstrSize

Lea2:
	move.l	#%00001111011001000000000000000010,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
Lea_start:
	lea	oper1(a5),a2
	tst.b	opInfo1(a2)
	bne.s	10$
	move.b	opReg(a2),d0
	cmp.b	oper2+opReg(a5),d0	; Gleiches Register auf beiden Seiten?
	bne.s	10$
	cmp.b	#ea_Aind,opMode(a2)
	bne.s	2$			; LEA (An),An ?
	btst	#of_Special,OptFlag(a5)
	beq.s	10$
	moveq	#-2,d0			; ausloeschen - 2 Bytes
1$:	bsr	ShiftPC
	bra	DelLastRefs
2$:	cmp.b	#ea_AindDispl,opMode(a2)
	bne.s	10$			; LEA x(An),An ?
	move.l	opVal1(a2),d2
	bne.s	3$			; LEA 0(An),An ausloeschen - 4 Bytes
	btst	#of_Special,OptFlag(a5)
	beq.s	10$
	moveq	#-4,d0
	bra.s	1$
3$:	btst	#of_Quick,OptFlag(a5)
	beq.s	10$
	moveq	#8,d1
	cmp.l	d1,d2
	bhi.s	4$			; LEA 1..8(An),An  ->	  ADDQ.L #1..8,An
	move.w	#$5088,d4
	bra.s	5$
4$:	moveq	#-8,d1
	cmp.l	d1,d2
	blo.s	10$			; LEA -1..-8(An),An ->  SUBQ.L #1..8,An
	move.w	#$5188,d4
	neg.w	d2
5$:	bsr	DelLastRefs
	moveq	#-2,d0
	bsr	ShiftPC			; 2 Bytes gewonnen
	moveq	#7,d0
	and.w	d2,d0
	ror.w	#7,d0
	or.w	d4,d0
	or.b	opReg(a2),d0
	bra	AddWord
10$:	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	moveq	#$60,d2
	bra	WriteStdEA


	cnop	0,4
Cmp:				; CMP ea,Dn  CMPA ea,An  CMPI #xx,ea  CMPM ...
	jmp	Cmp2(pc)
	moveq	#$20,d1
	bra	InstrSize
Cmp2:
	move.l	#%00011111011111110000111101111111,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	lea	oper1(a5),a2
	move.w	opMode(a2),d2
	move.w	d2,d0
	lsr.w	#8,d0
	move.b	oper2+opMode(a5),d1
	beq.s	Cmp3			; CMP ea,Dn ?
	cmp.b	#ea_Adirect,d1		; CMPA ea,An ?
	beq.s	2$
	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),d2 ; CMPI ?
	beq.s	3$
	moveq	#ea_AindPostInc,d2
	cmp.b	d2,d0			; CMPM (An)+,(An)+ ?
	bne	IllegalMode
	cmp.b	d2,d1
	bne	IllegalMode
	move.w	#$b108,d4
	bra	CmpM_start
2$:	move.w	#$b0c0,d4
	bra	CmpA_start
3$:	move.w	#$0c00,d4
	bra	CmpI_start
Cmp3:
	move.b	OpcodeSize(a5),d4
	bne.s	1$
	cmp.b	#ea_Adirect,d0		; CMP.b An,Dn existiert nicht
	beq	IllegalMode
	tst.b	opImmedByte(a2)		; #Immediate-Byte?
	beq.s	1$
	clr.b	opVal1+2(a2)
1$:	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),d2 ; CMPI ?
	bne.s	2$
	btst	#of_Normal,OptFlag(a5)	; Optimierung versuchen?
	bne.s	4$
2$:	ror.b	#2,d4
	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	moveq	#$60,d2
	bra	WriteStdEA
4$:	tst.l	opVal1(a2)		; CMPI #0 ?
	bne.s	2$
	tst.b	opInfo1(a2)		; Absolute-Immediate?
	bne.s	2$
	lea	oper2(a5),a2
	bra	CmpI_TstOpt


CmpA:					; CMPA ea,An
	jmp	CmpA2(pc)
	moveq	#$60,d1
	bra	InstrSize
CmpA2:
	move.l	#%00011111011111110000000000000010,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	lea	oper1(a5),a2
CmpA_start:
	cmp.b	#os_WORD,OpcodeSize(a5)
	blo	IllegalMode		; CMPA.b ist illegal
	beq.s	1$
	or.w	#$0100,d4		; CMPA.l
1$:	btst	#of_Normal,OptFlag(a5)	; optimieren ?
	beq.s	2$
	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),opMode(a2)
	bne.s	2$
	tst.b	opInfo1(a2)		; Absolute-Immediate?
	bne.s	2$
	tst.l	opVal1(a2)		; CMPA #0 ?
	bne.s	2$
	cmp.b	#2,Machine(a5)		; kann bei 020+ zu TST optimiert werden
	bhs.s	3$
2$:	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	moveq	#$20,d2
	bra	WriteStdEA

3$:	move.w	#$4a88,d5		; 2/4 Bytes für CMPA #0 -> TST.L
	moveq	#-2,d0
	btst	#8,d4
	beq.s	4$
	moveq	#-4,d0
4$:	bsr	ShiftPC
	move.w	d5,d0
	or.b	oper2+opReg(a5),d0
	bra	AddWord


CmpM:					; CMPM (Ay)+,(Ax)+
	jmp	CmpM2(pc)
	addq.l	#2,d6
	rts
CmpM2:
	move.l	#%00000000000010000000000000001000,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
CmpM_start:
	move.b	OpcodeSize(a5),d0
	ror.b	#2,d0
	or.b	d0,d4
	moveq	#0,d0
	move.b	oper2+opReg(a5),d0	; Ax
	ror.w	#7,d0
	or.w	d4,d0
	or.b	oper1+opReg(a5),d0	; Ay
	bra	AddWord


Swap:					; SWAP Dn
	jmp	Swap2(pc)
	addq.l	#2,d6
	rts
Swap2:
	st	RefFlag(a5)
	move.l	a3,a0
	bsr	GetRegister
	bmi.s	1$
	bclr	#3,d0
	beq.s	2$
1$:	bra	NeedDReg
2$:	tst.b	(a0)
	bne	SyntaxErr
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord			; Opcode


Clr:					; CLR ea
	jmp	Clr2(pc)
	moveq	#$60,d1
	bra	InstrSize
Clr2:
	clr.b	TryPC(a5)
	move.l	#%00000011011111010000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a2)
	bne	SyntaxErr
Clr_start:
	lea	oper1(a5),a2
	move.b	OpcodeSize(a5),d4
	ror.b	#2,d4
	bpl.s	2$
	btst	#of_Normal,OptFlag(a5)	; optimieren ?
	beq.s	2$
	tst.b	opMode(a2)		; CLR.l Dn ?
	bne.s	2$
	move.w	#$0038,d0		; in MOVEQ #0,Dn verwandeln
	or.b	opReg(a2),d0
	ror.w	#7,d0
	bra	AddWord
2$:	moveq	#$60,d2
	bra	WriteStdEA


Negs:					; NEGX / NEG / NOT ea
	jmp	Negs2(pc)
	moveq	#$60,d1
	bra	InstrSize
Negs2:
	clr.b	TryPC(a5)
	move.l	#%00000011011111010000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a2)
	bne	SyntaxErr
	lea	oper1(a5),a2
	move.b	OpcodeSize(a5),d4
	ror.b	#2,d4
	moveq	#$60,d2
	bra	WriteStdEA


	cnop	0,4
Tst:					; TST ea
	IFND	SMALLASS
	jmp	Tst2(pc)
	ELSE
	jmp	Negs2(pc)
	ENDC
	moveq	#$60,d1
	bra	InstrSize
	IFND	SMALLASS
Tst2:
	cmp.b	#2,Machine(a5)		; ab 68020: Immediate, PC-Indir, AReg-Direct
	blo.s	Negs2
	move.l	#%00011111011111110000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a2)
	bne	SyntaxErr
	lea	oper1(a5),a2
	move.b	OpcodeSize(a5),d4
	bne.s	2$
	cmp.b	#ea_Adirect,opMode(a2)	; TST.b An  nicht erlaubt
	beq	IllegalMode
2$:	ror.b	#2,d4
	moveq	#$60,d2
	bra	WriteStdEA
	ENDC


Ext:					; EXT Dn, EXTB Dn
	jmp	Ext2(pc)
	addq.l	#2,d6
	rts
Ext2:
	st	RefFlag(a5)
	IFND	SMALLASS
	cmp.w	#$49c0,d4		; EXTB ?
	bne.s	4$
	cmp.b	#2,Machine(a5)		; erst ab 68020
	bhs.s	1$
	bra	IllegalInstr
	ENDC
4$:	cmp.b	#os_WORD,OpcodeSize(a5)
	beq.s	1$
	bhi.s	5$
	moveq	#20,d0			; Illegal Opcode Extension
	bsr	Error
5$:	or.w	#$0040,d4
1$:	move.l	a3,a0
	bsr	GetRegister
	bmi.s	2$
	bclr	#3,d0
	beq.s	3$
2$:	bra	NeedDReg
3$:	tst.b	(a0)
	bne	SyntaxErr
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord			; Opcode


Btst:					; BTST #x,ea  oder  BTST Dn,ea
	jmp	Btst2(pc)
	clr.b	OpcodeSize(a5)		; Immer 2 Bytes fuer #x belegen
	moveq	#$20,d1
	bra	InstrSize
Btst2:
	move.b	#os_WORD,OpcodeSize(a5)	; WORD-Referenzen auf #x erzwingen
	move.b	#-2,TryPC(a5)
	move.l	#%00010000000000010001111101111101,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	Bitcmd
	rts
Bitcmd:
	tst.b	(a1)
	bne	SyntaxErr
	lea	oper2(a5),a2
	tst.b	oper1+opMode(a5)	; BTST Dn,ea ?
	beq.s	2$
	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),opMode(a2)
	beq	IllegalMode
	moveq	#8,d0
	tst.b	opMode(a2)
	bne.s	1$
	moveq	#32,d0
1$:	cmp.l	oper1+opVal1(a5),d0	; #x im erlaubten Bereich (0-31 oder 0-7) ?
	bls.s	4$
3$:	or.w	#$0800,d4		; BTST #x,ea
	moveq	#$20,d2
	bra	WriteStdEA
2$:	move.w	#$8000,d0
	move.b	oper1+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	move.w	#$a0,d2
	bra	WriteStdEA
4$:	lea	btstwarn(pc),a1
	bsr	Warning
	bra.s	3$

btstwarn:
	dc.b	"Bit manipulation out of range",0
	even

Bit:					; BCHG/BCLR/BSET Dx,ea
	jmp	Bit2(pc)		; BCHG/BCLR/BSET #x,ea
	clr.b	OpcodeSize(a5)		; immer 2 Bytes fuer #x belegen
	moveq	#$20,d1
	bra	InstrSize
Bit2:
	move.b	#os_WORD,OpcodeSize(a5)	; WORD-Referenzen auf #x erzwingen
	move.l	#%00010000000000010000001101111101,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	Bitcmd
	rts


	IFND	SMALLASS
GetOffsetWidth:
; Das {Offset:Width} - Feld von BitField Befehlen auswerten
; VORSICHT!  a3/d2 werden zerstoert!
; a0 = Operand
; -> d5 = Bitfield Extensionword
; -> d0 = Error-code
	moveq	#0,d5
	moveq	#'{',d1
	lea	1(a0),a3
1$:	move.b	(a3)+,d0
	beq.s	9$
	cmp.b	d1,d0
	bne.s	1$
	move.l	a3,a0
	bsr	GetRegister		; Offset ist ein Register?
	bmi.s	4$
	bclr	#3,d0
	beq.s	3$
2$:	moveq	#38,d0			; Need data register
	rts
3$:	moveq	#$20,d5
	or.b	d0,d5
	bra.s	10$
4$:	move.l	a3,a0			; Offset als Value von 0-31 lesen
	moveq	#os_BYTE,d0
	bsr	GetValue
	tst.w	d2
	bpl.s	9$
5$:	moveq	#36,d0			; Undefined Symbol
	rts
6$:	moveq	#81,d0			; No address allowed
	rts
7$:	moveq	#42,d0			; Reloc error
	rts
8$:	moveq	#68,d0			; Out of range
	rts
9$:	tst.b	d2
	bne.s	6$
	swap	d2
	addq.w	#1,d2			; Adressen und XREFs sind nicht erlaubt
	beq.s	7$
	moveq	#31,d1
	cmp.l	d1,d0
	bhi.s	8$
	move.w	d0,d5
10$:	; Offset und Do auf Position schieben
	lsl.w	#6,d5
	move.l	a0,a3
	cmp.b	#':',(a3)+
	beq.s	11$
	moveq	#41,d0			; Syntax error
	rts
11$:	move.l	a3,a0
	bsr	GetRegister		; Width ist ein Register
	bmi.s	12$
	bclr	#3,d0
	bne.s	2$
	or.b	d0,d5
	or.b	#$20,d5
	moveq	#0,d0
	rts
12$:	move.l	a3,a0			; Width als Value von 0-31 lesen
	moveq	#os_BYTE,d0
	bsr	GetValue
	tst.w	d2
	bmi.s	5$
	tst.b	d2
	bne.s	6$
	swap	d2
	addq.w	#1,d2			; Adressen und XREFs sind nicht erlaubt
	beq.s	7$
	tst.l	d0
	beq.s	8$
	moveq	#32,d1
	cmp.l	d1,d0
	bhi.s	8$
	and.b	#31,d0
	or.b	d0,d5
	moveq	#0,d0
	rts


BFPCea:					; BFTST ea{o:w} (68020)
	jmp	BFPCea2(pc)
	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
BFPCea2:
	move.l	#%00001111011001010000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper
	bpl.s	BFea3
	rts

BFea:					; BFCHG,BFCLR,BFSET ea{o:w} (68020)
	jmp	BFea2(pc)
	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
BFea2:
	clr.b	TryPC(a5)
	move.l	#%00000011011001010000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper
	bpl.s	BFea3
	rts
BFea3:
	tst.b	(a2)
	bne	SyntaxErr
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	move.l	a3,a0
	bsr	GetOffsetWidth
	bne.s	1$
	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteCPEA
1$:	bra	Error


BFtoD:					; BFEXTS,BFEXTU,BFFFO ea{o:w},Dn (68020)
	jmp	BFtoD2(pc)
	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
BFtoD2:
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	move.l	#%00001111011001010000000000000001,d0
	moveq	#$20,d1
	bsr	GetCpOper
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	move.l	a3,a0
	bsr	GetOffsetWidth
	bne.s	2$
	move.b	oper2+opReg(a5),d0
	ror.w	#4,d0
	or.w	d0,d5
	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteCPEA
2$:	bra	Error


BFins:					; BFINS Dn,ea{o:w} (68020)
	jmp	BFins2(pc)
	addq.l	#2,d6
	move.w	#$a0,d1
	bra	InstrSize
BFins2:
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	move.l	#%00000000000000010000001101100101,d0
	moveq	#$20,d1
	bsr	GetCpOper
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	move.l	a2,a0
	bsr	GetOffsetWidth
	bne.s	2$
	move.b	oper1+opReg(a5),d0
	ror.w	#4,d0
	or.w	d0,d5
	lea	oper2(a5),a2
	move.w	#$a0,d2
	bra	WriteCPEA
2$:	bra	Error
	ENDC


AOr:					; AND/OR ea,Dn  oder  AND/OR Dn,ea
	jmp	AOr2(pc)
	move.w	#$8020,d1
	bra	InstrSize
AOr2:
	move.l	#%00011111011111010100001101111101,d0
	move.w	#$8020,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	lea	oper1(a5),a2
	lea	oper2(a5),a3
	tst.b	opMode(a3)
	beq.s	4$			; ea,Dn ?
	tst.b	opMode(a2)
	beq.s	3$			; oder Dn,ea ?
	cmp.w	#(ea_SpecialMode<<8)+(ea_Immediate&7),opMode(a2)
	bne	IllegalMode		; oder ANDI / ORI #x,ea
	and.w	#$4000,d4
	bne.s	2$
	moveq	#0,d4			; ORI
	bra	OAE_start
2$:	move.w	#$0200,d4		; ANDI
	bra	OAE_start
3$:	or.w	#$0100,d4		; Dn,ea
	exg	a2,a3
4$:	cmp.w	#(ea_SpecialMode<<8)+(ea_SR&7),opMode(a2)
	beq	IllegalMode
	move.b	OpcodeSize(a5),d4
	ror.b	#2,d4
	moveq	#0,d0
	move.b	opReg(a3),d0
	ror.w	#7,d0
	or.w	d0,d4
	moveq	#$20,d2
	bra	WriteStdEA


ExOr:					; EOR Dn,ea  (auch: EOR #x,ea -> EORI)
	jmp	ExOr2(pc)
	move.w	#$8020,d1
	bra	InstrSize
ExOr2:
	move.l	#%00010000000000010100001101111101,d0
	move.w	#$8020,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	tst.b	oper1+opMode(a5)
	beq.s	2$
	move.w	#$0a00,d4
	bra	OAE_start		; EORI
2$:	lea	oper2(a5),a2
	cmp.w	#(ea_SpecialMode<<8)+(ea_SR&7),opMode(a2)
	beq	IllegalMode
	move.b	OpcodeSize(a5),d4
	ror.b	#2,d4
	moveq	#0,d0
	move.b	oper1+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	move.w	#$a0,d2
	bra	WriteStdEA


Shift:					; ASR/ASL/LSR/LSL/ROXR/ROXL/ROR/ROL  #x/Dn/ea
	jmp	Shift2(pc)
	cmp.b	#'#',(a3)		; #x,Dn ?
	beq.s	1$
	move.l	a3,a0
	bsr	GetRegister		; Dm,Dn ?
	bpl.s	1$
	moveq	#$60,d1
	bra	InstrSize
1$:	addq.l	#2,d6			; #x und Dn braucht immer nur 2 Bytes
	rts
Shift2:
	st	RefFlag(a5)
	move.w	#$e000,d5
	cmp.b	#'#',(a3)		; #x,Dn ?
	beq.s	Shift_imm
	move.l	a3,a0
	bsr	GetRegister		; Dm,Dn ?
	bmi.s	1$
	bclr	#3,d0
	bne	NeedDReg
	or.w	#$0020,d5
	bra	Shift_dreg
1$:	cmp.b	#os_WORD,OpcodeSize(a5)
	bne	IllegalMode		; gibt nur .w
	clr.b	TryPC(a5)
	move.l	#%00000011011111000000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand		; shift <ea>
	bpl.s	2$
	rts
2$:	tst.b	(a2)
	bne	SyntaxErr		; kein zweiter Operand erlaubt
	lsl.w	#6,d4
	or.w	#$e0c0,d4
	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteStdEA

Shift_imm:
	lea	1(a3),a0
	moveq	#os_BYTE,d0
	bsr	GetValue		; #x bestimmen
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	moveq	#0,d1
	cmp.l	d1,d0
	ble	ImmedSize
	moveq	#8,d1
	cmp.l	d1,d0			; 1-8 ist erlaubt
	bhi	ImmedSize
	move.w	d0,d3
	and.w	#7,d0
	ror.w	#7,d0
	or.w	d0,d5
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	bsr	GetRegister		; Dn
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedDReg
	or.w	d0,d5
	moveq	#$001c,d1
	and.w	d4,d1
	cmp.w	#$000c,d1		; LSL-Befehl ?
	beq.s	2$
	cmp.w	#$0004,d1		; ASL-Befehl ?
	bne	Shift_gen
	moveq	#of_Normal,d1		; Normal: Optimierung ASL -> ADD
	bra.s	3$
2$:	moveq	#of_Shifts,d1		; Shifts: Optimierung LSL -> ADD
3$:	btst	d1,OptFlag(a5)
	beq	Shift_gen
	subq.w	#1,d3			; xSL #1,Dn  ->  ADD Dn,Dn  optimieren
	bne.s	Shift_gen
	move.w	d0,d1
	or.w	#$d000,d0
	ror.w	#7,d1
	or.w	d1,d0
	move.b	OpcodeSize(a5),d1
	ror.b	#2,d1
	or.b	d1,d0
	addq.l	#2,d6
	bra	AddWord
Shift_dreg:
	ror.w	#7,d0
	or.w	d0,d5
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	bsr	GetRegister		; Dn
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedDReg
	or.w	d0,d5
Shift_gen:
	move.b	OpcodeSize(a5),d0	; Rest des Shift-Opcodes zusammensetzen
	ror.b	#2,d0
	or.b	d0,d5
	bclr	#2,d4
	beq.s	1$
	or.w	#$0100,d5		; Left-Shift
1$:	or.w	d4,d5
	move.w	d5,d0
	addq.l	#2,d6
	bra	AddWord


Lnk:					; LINK An,#x
	jmp	Lnk2(pc)
	addq.l	#4,d6
	IFND	SMALLASS
	cmp.b	#os_LONG,OpcodeSize(a5)
	bne.s	1$
	addq.l	#2,d6
	ENDC
1$:	rts
Lnk2:
	st	RefFlag(a5)
	move.l	a3,a0
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	move.b	d0,d5
	addq.l	#2,d6
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	moveq	#os_WORD,d0
	bsr	GetValue
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	beq.s	1$
	tst.b	d2
	bmi	AddrError
	move.l	d6,a1
	moveq	#os_WORD,d3
	move.w	#12,d2
	swap	d2
	bsr	AddDistance
	move.l	d0,d2
	cmp.b	#os_LONG,OpcodeSize(a5)
	bne.s	4$
	bra.s	2$
1$:	move.l	d0,d2
	cmp.b	#os_LONG,OpcodeSize(a5)
	bne.s	4$
	btst	#of_Normal,OptFlag(a5)
	beq.s	2$
	bsr	WordLimits		; LINK.L passt auch in LINK.w ?
	bne.s	2$
	moveq	#-2,d0			;  dann 2 Bytes gewonnen
	move.l	d6,a0
	bsr	ShiftRelocs
	bra.s	5$
2$:
	IFND	SMALLASS
	cmp.b	#2,Machine(a5)		; ansonsten gibt's LINK.L erst ab 68020!
	blo	IllegalMode
	moveq	#EXT_REF32,d0
	moveq	#0,d1
	bsr	ChangeLastRefs
	tst.w	LastDistCnt(a5)
	beq.s	3$
	move.l	LastDistance(a5),a0
	move.b	#os_LONG,dist_Width-dist_HEAD(a0)
3$:	move.w	#$4808,d0
	or.b	d5,d0
	bsr	AddWord
	addq.l	#4,d6
	move.l	d2,d0
	bra	AddLong
	ELSE
	bra	IllegalMode
	ENDC
4$:	move.l	#$7fff,d0
	cmp.l	d0,d2
	bgt	ImmedSize
	not.l	d0
	cmp.l	d0,d2
	bge.s	5$
	bra	ImmedSize
5$:	move.w	#$4e50,d0		; LINK.w
	or.b	d5,d0
	bsr	AddWord
	addq.l	#2,d6
	move.w	d2,d0
	bra	AddWord


Unlk:					; UNLK An
	jmp	Unlk2(pc)
	addq.l	#2,d6
	rts
Unlk2:
	st	RefFlag(a5)
	move.l	a3,a0
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	tst.b	(a0)
	bne	SyntaxErr
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord


MD:					; MULU / MULS / DIVU / DIVS  ea,Dn/Dn:Dm
	jmp	MD2(pc)
	IFND	SMALLASS
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	1$
	addq.l	#2,d6
1$:
	ENDC
	moveq	#$60,d1
	bra	InstrSize
MD2:
	IFND	SMALLASS
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	1$
	addq.l	#2,d6			; 1 Word mehr fuer Long-Form
	addq.w	#5,ListFileOff(a5)
1$:
	ENDC
	move.l	#%00011111011111010000000000000001,d0
	moveq	#$60,d1
	bsr	GetOperand		; <ea> auswerten
	bpl.s	2$
	rts
2$:	cmp.b	#os_WORD,OpcodeSize(a5)
	IFND	SMALLASS
	bhi.s	MD3			; Long-Form ausgewaehlt?
	ELSE
	bhi	IllegalMode
	ENDC
	move.l	a2,a0
	bsr	GetRegister		; Dest.Register
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedDReg
	ror.w	#7,d0
	or.w	#$80c0,d0
	add.w	d4,d4
	bcc.s	3$
	or.w	#$4000,d0
3$:	add.w	d4,d4
	bcc.s	4$
	or.w	#$0100,d0
4$:	add.w	d4,d4
	bcs	IllegalMode		; DIVUL.W oder DIVSL.W gibt's nicht!
	move.w	d0,d4
	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteStdEA
	IFND	SMALLASS
MD3:
	cmp.b	#2,Machine(a5)		; Long-Formen erst ab 68020
	blo	IllegalMode
	moveq	#0,d5
	move.l	a2,a0
	bsr	GetRegister		; erstes Dest.Register
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedDReg
	move.w	d0,d2
	move.b	(a0)+,d1		; Dn:Dm ?
	beq.s	2$
	cmp.b	#':',d1
	bne	SyntaxErr
	bclr	#13,d4
	bne.s	1$
	move.w	#$0400,d5		; Size=1 (ausser bei DIV?L.L)
1$:	bsr	GetRegister		; zweites Dest.Register
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedDReg
	tst.b	(a0)
	bne	SyntaxErr
2$:	ror.w	#4,d0			; Dq bzw. Dl
	or.w	d0,d5
	or.b	d2,d5			; Dr bzw. Dh
	move.w	#$4c00,d0
	move.b	oper1+opMode(a5),d0
	lsl.b	#3,d0
	or.b	oper1+opReg(a5),d0
	add.w	d4,d4
	bcs.s	3$
	or.w	#$0040,d0
3$:	bsr	AddWord			; Opcode schreiben
	move.w	d5,d0
	add.w	d4,d4
	bcc.s	4$
	or.w	#$0800,d0
4$:	bsr	AddWord			; Register/Size Extension
	moveq	#$60,d2
	bra	WriteExt		; EA-Extension
	ENDC


Exg:					; EXG Dm,Dn  EXG Am,An  EXG Am,Dn
	jmp	Exg2(pc)
	addq.l	#2,d6
	rts
Exg2:
	st	RefFlag(a5)
	move.l	a3,a0
	bsr	GetRegister
	move.w	d0,d5
	bmi	MissingReg
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	bsr	GetRegister
	bmi	MissingReg
	tst.b	(a0)
	bne	SyntaxErr
	bclr	#3,d5
	bne.s	1$
	bclr	#3,d0
	bne.s	2$
	or.w	#$0040,d4		; Dm,Dn
	bra.s	3$
1$:	bclr	#3,d0
	beq.s	4$
	or.w	#$0048,d4		; Am,An
	bra.s	3$
4$:	exg	d0,d5			; Am,Dn -> Dm,An
2$:	or.w	#$0088,d4		; Dm,An
3$:	or.w	d4,d0
	ror.w	#7,d5
	or.w	d5,d0
	addq.l	#2,d6
	bra	AddWord


SCC:					; Scc ea
	jmp	SCC2(pc)
	moveq	#$60,d1
	bra	InstrSize
SCC2:
	clr.b	TryPC(a5)
	move.l	#%00000011011111010000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a2)
	bne	SyntaxErr
	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteStdEA


Trp:					; TRAP #x
	jmp	Trp2(pc)
	addq.l	#2,d6
	rts
Trp2:
	st	RefFlag(a5)
	move.l	a3,a0
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	moveq	#os_BYTE,d0
	bsr	GetValue		; TrapNummer
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	tst.l	d0
	bmi.s	1$
	moveq	#16,d1
	cmp.l	d1,d0
	bhs.s	1$
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord
1$:	bra	ImmedSize


ASB:					; ABCD/SBCD
	jmp	ASX_nosize(pc)		; ist bis auf die Op.Size mit ADDX/SUBX
	addq.l	#2,d6			;  identisch
	rts


ASX:					; ADDX/SUBX Dn,Dm  oder  ADDX/SUBX -(An),-(Am)
	jmp	ASX2(pc)
	addq.l	#2,d6
	rts
ASX2:
	move.b	OpcodeSize(a5),d4
	ror.b	#2,d4
ASX_nosize:				; Einsprungpunkt wird von ABCD/SBCD genutzt
	st	RefFlag(a5)
	move.l	a3,a0
	cmp.b	#'-',(a0)
	beq.s	1$
	bsr	GetRegister		; Dn,Dm
	bmi.s	11$
	bclr	#3,d0
	bne	NeedDReg
	or.w	d0,d4
	cmp.b	#',',(a0)+
	bne.s	10$
	bsr	GetRegister
	bmi.s	11$
	tst.b	(a0)
	bne	SyntaxErr
	bclr	#3,d0
	bne	NeedDReg
	ror.w	#7,d0
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord

9$:	dc.b	"),-("
10$:	bra	SyntaxErr
11$:	bra	MissingReg
1$:	addq.w	#8,d4			; -(An),-(Am)
	addq.l	#1,a0
	cmp.b	#'(',(a0)+
	bne.s	10$
	bsr	GetRegister
	bmi.s	11$
	bclr	#3,d0
	beq	NeedAReg
	or.w	d0,d4
	lea	9$(pc),a1
	cmp.b	(a1)+,(a0)+
	bne.s	10$
	cmp.b	(a1)+,(a0)+
	bne.s	10$
	cmp.b	(a1)+,(a0)+
	bne.s	10$
	cmp.b	(a1)+,(a0)+
	bne.s	10$
	bsr	GetRegister
	bmi.s	11$
	bclr	#3,d0
	beq	NeedAReg
	cmp.b	#')',(a0)+
	bne.s	10$
	tst.b	(a0)
	bne.s	10$
	ror.w	#7,d0
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord


OAE:					; ORI #x,ea  / ANDI #x,ea  /  EORI #x,ea
	jmp	OAE2(pc)
	move.w	#$8020,d1
	bra	InstrSize
OAE2:
	move.l	#%00010000000000000100001101111101,d0
	move.w	#$8020,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
OAE_start:
	lea	oper2(a5),a2
	move.b	OpcodeSize(a5),d4
	ror.b	#2,d4
	cmp.w	#(ea_SpecialMode<<8)+(ea_SR&7),opMode(a2)
	bne.s	1$			; Destination = SR oder CCR ?
	cmp.b	#os_LONG,OpcodeSize(a5)
	beq	IllegalMode
	moveq	#$003c,d0
	or.w	d4,d0
	bsr	AddWord
	moveq	#$60,d2
	bra	WriteExt
1$:	tst.b	oper1+opImmedByte(a5)
	beq.s	2$
	clr.b	oper1+opVal1+2(a5)
2$:	moveq	#$20,d2
	bra	WriteStdEA


CmpI:					; CMPI #x,ea
	jmp	CmpI2(pc)
	moveq	#$20,d1
	bra	InstrSize
CmpI2:
	clr.b	TryPC(a5)
	IFND	SMALLASS
	cmp.b	#2,Machine(a5)
	blo.s	1$
	subq.b	#2,TryPC(a5)
1$:
	ENDC
	move.l	#%00010000000000000000111101111101,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	2$
	rts
2$:	tst.b	(a1)
	bne	SyntaxErr
CmpI_start:
	lea	oper2(a5),a2
	cmp.w	#(ea_SpecialMode<<8)+(ea_PCdisplace&7),opMode(a2)
	blo.s	3$
	IFND	SMALLASS
	cmp.b	#2,Machine(a5)		; CMPI #x,d(PC...) gibt's erst ab 68020
	blo	IllegalMode
	ELSE
	bra	IllegalMode
	ENDC
3$:	move.b	OpcodeSize(a5),d4
	btst	#of_Normal,OptFlag(a5)	; Optimierung versuchen?
	bne.s	4$
1$:	tst.b	oper1+opImmedByte(a5)
	beq.s	2$
	clr.b	oper1+opVal1+2(a5)
2$:	ror.b	#2,d4
	moveq	#$20,d2
	bra	WriteStdEA
4$:	tst.l	oper1+opVal1(a5)	; CMPI #0 ?
	bne.s	1$
	tst.b	oper1+opInfo1(a5)	; Absolute-Immediate?
	bne.s	1$
CmpI_TstOpt:
	moveq	#-2,d0			; 2/4 Bytes fuer CMPI
	moveq	#-5,d1
	cmp.b	#os_LONG,d4
	bne.s	1$
	moveq	#-4,d0
	moveq	#-9,d1
1$:	bsr	ShiftLastDists		; Distanzen und Relocs vom <ea>-Operanden
	move.l	d0,d1			;  verschieben
	moveq	#0,d0
	bsr	ChangeLastRefs
	move.l	d1,d0
	bsr	ShiftLastRelocs
	move.l	d6,a0			; Speicher fuer Immed. wird nicht benoetigt
	add.l	d0,d6
	subq.l	#2,a0
	bsr	ShiftRelocs
	ror.b	#2,d4
	and.w	#$00ff,d4
	or.w	#$4a00,d4		; CMPI #0 -> TST
	move.w	#$a0,d2
	bra	WriteStdEA


ASI:					; SUBI #x,ea / ADDI #x,ea
	jmp	ASI2(pc)
	moveq	#$20,d1
	bra	InstrSize
ASI2:
	clr.b	TryPC(a5)
	move.l	#%00010000000000000000001101111101,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	move.b	OpcodeSize(a5),d4
	tst.b	(a1)
	bne	SyntaxErr
ASI_start:
	lea	oper2(a5),a2
	moveq	#(1<<of_Quick)|(1<<of_Normal),d0
	and.b	OptFlag(a5),d0		; Optimierungsversuch?
	bne	2$
1$:	tst.b	oper1+opImmedByte(a5)
	beq.s	6$
	clr.b	oper1+opVal1+2(a5)
6$:	ror.b	#2,d4
	moveq	#$20,d2
	bra	WriteStdEA
7$:	and.b	#1<<of_Normal,d0
	beq.s	1$
	bra	CmpI_TstOpt		; nach TST optimieren
2$:	tst.b	oper1+opInfo1(a5)	; Absolute-Immediate?
	bne.s	1$
	move.l	oper1+opVal1(a5),d3	; #x
	beq.s	7$
	and.b	#1<<of_Quick,d0
	beq.s	1$
	moveq	#8,d0
	cmp.l	d0,d3			; ADDI/SUBI #1..8,ea ?
	bls.s	ASI_QOpt
	moveq	#-8,d0
	cmp.l	d0,d3			; ADDI/SUBI #-1..-8,ea ?
	blo.s	1$
	neg.w	d3
	eor.w	#$0200,d4		; ADDI - SUBI tauschen
ASI_QOpt:
	moveq	#-2,d0			; 2/4 Bytes fuer ADDI/SUBI -> ADDQ/SUBQ
	moveq	#-5,d1
	cmp.b	#os_LONG,d4
	bne.s	1$
	moveq	#-4,d0
	moveq	#-9,d1
1$:	bsr	ShiftLastDists		; Distanzen und Relocs vom <ea>-Operanden
	move.l	d0,d1			;  verschieben
	moveq	#0,d0
	bsr	ChangeLastRefs
	move.l	d1,d0
	bsr	ShiftLastRelocs
	bsr	ShiftPC			; Speicher fuer Immediate wird nicht benoetigt
	moveq	#7,d0
	and.w	d3,d0			; ADDQ/SUBQ zusammensetzen
	ror.w	#7,d0
	or.w	#$5000,d0
	ror.b	#2,d4
	move.b	d4,d0
	and.w	#$0200,d4
	bne.s	2$
	or.w	#$0100,d0
2$:	move.w	d0,d4
	move.w	#$a0,d2
	bra	WriteStdEA


MovP:					; MOVEP d(Ay),Dx   MOVEP Dx,d(Ay)
	jmp	MovP2(pc)
	addq.l	#4,d6
	rts
MovP2:
	move.l	#%00000000001000010000000000100001,d0
	moveq	#$20,d1
	clr.b	OptFlag(a5)		; 0(Ay) NICHT zu (Ay) optimieren!
	bsr	GetOperand
	move.l	CurrentSec(a5),a0
	move.b	sec_Flags(a0),OptFlag(a5)
	tst.w	d0
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	move.b	oper1+opMode(a5),d0
	cmp.b	oper2+opMode(a5),d0	; die Modi muessen verschieden sein
	beq	IllegalMode
	cmp.b	#os_WORD,OpcodeSize(a5)
	blo	IllegalMode		; .b existiert nicht
	beq.s	2$
	or.w	#$0040,d4
2$:	moveq	#0,d1
	move.b	oper1+opReg(a5),d1
	moveq	#0,d2
	move.b	oper2+opReg(a5),d2
	tst.b	d0			; Dx,d(Ay) ?
	bne.s	3$
	or.w	#$0080,d4
	exg	d1,d2
3$:	move.w	d2,d0
	ror.w	#7,d0
	or.w	d1,d0
	or.w	d4,d0
	bsr	AddWord
	moveq	#$20,d2
	bra	WriteExt


	IFND	SMALLASS
MovC:					; MOVEC Rc,Rn  MOVEC Rn,Rc  (68010)
	jmp	MovC2(pc)
	addq.l	#4,d6
	rts
MovC2:
	tst.b	Machine(a5)		; existiert nicht auf MC68000
	beq	IllegalInstr
	st	RefFlag(a5)
	addq.l	#2,d6
	move.l	a3,a0
	bsr	GetRegister
	move.w	d0,d5			; d5 = General Register (d0-d7/a0-a7)
	bmi.s	MovC3
	addq.w	#1,d4			; MOVEC Rn,Rc
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	bsr.s	GetControlReg
	bra.s	MovCStore
MovC3:
	move.l	a3,a0			; MOVEC Rc,Rn
	bsr.s	GetControlReg
	move.w	d0,d5
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	bsr	GetRegister
	bmi	MissingReg
	exg	d0,d5
MovCStore:
	ror.w	#4,d5
	or.w	d0,d5
	move.w	d4,d0
	bsr	AddWord
	addq.l	#2,d6
	move.w	d5,d0
	bra	AddWord

GetControlReg:				; SFC,DFC,USP,VBR (68010)
; a0=Input				  CACR,CAAR,MSP,ISP (68020/68030)
; -> d0=ControlReg-Code, a0=NewInput	  TC,ITT0,ITT1,DTT0,DTT1,
; a3/d2/d3 werden zerstoert	       	  MMUSR,URP,SRP (68040)
	move.l	a0,a3			; PCR,BUSCR (68060)
	moveq	#',',d1
	moveq	#-$21,d2
	moveq	#'a',d3
1$:	move.b	(a0),d0
	beq.s	2$
	cmp.b	d1,d0
	beq.s	2$
	cmp.b	d3,d0
	blo.s	11$
	and.b	d2,d0
11$:	move.b	d0,(a0)+
	bra.s	1$
2$:	move.b	d0,d2			; Stringbegrenzer merken
	clr.b	(a0)
	move.l	a0,-(sp)
	moveq	#0,d3
	move.l	a3,a0
	lea	creg_SFC(pc),a1
	bsr	StrCmp			; SFC ?
	beq	99$
	lea	creg_DFC(pc),a1
	bsr	CmpCReg			; DFC ?
	beq	99$
	lea	creg_CACR(pc),a1
	bsr	CmpCReg			; CACR (68020) ?
	bne.s	3$
	cmp.b	#2,Machine(a5)
	bhs	99$
	bsr	IllegalInstr
	bra	99$
3$:	lea	creg_TC(pc),a1
	bsr	CmpCReg			; TC (68040) ?
	bne.s	5$
4$:	cmp.b	#4,Machine(a5)
	bhs	99$
	bsr	IllegalInstr
	bra	99$
5$:	lea	creg_ITT0(pc),a1	; ITT0 (68040) ?
	bsr	CmpCReg
	beq.s	4$
	lea	creg_ITT1(pc),a1	; ITT1 (68040) ?
	bsr	CmpCReg
	beq.s	4$
	lea	creg_DTT0(pc),a1	; DTT0 (68040) ?
	bsr	CmpCReg
	beq.s	4$
	lea	creg_DTT1(pc),a1	; DTT1 (68040) ?
	bsr	CmpCReg
	beq.s	4$
	lea	creg_BUSCR(pc),a1	; BUSCR (68060) ?
	bsr	CmpCReg
	bne.s	50$
	cmp.b	#6,Machine(a5)
	blo.s	6$
	bra	99$
50$:	move.w	#$0800,d3
	move.l	a3,a0
	lea	adrmod_USP(pc),a1
	bsr	StrCmp			; USP ?
	beq	99$
	lea	creg_VBR(pc),a1
	bsr	CmpCReg			; VBR ?
	beq.s	99$
	cmp.b	#2,Machine(a5)		; Die folgenden sind erst ab 68020 moeglich
	blo.s	6$
	lea	creg_CAAR(pc),a1
	bsr	CmpCReg			; CAAR ?
	bne.s	7$
	cmp.b	#4,Machine(a5)		; nur fuer 68020 und 68030
	blo.s	99$
6$:	bsr	IllegalInstr
	bra.s	99$
7$:	lea	creg_MSP(pc),a1
	bsr	CmpCReg			; MSP ?
	beq.s	8$
	lea	creg_ISP(pc),a1
	bsr	CmpCReg			; ISP ?
	bne.s	9$
8$:	cmp.b	#4,Machine(a5)		; Nicht für 68060
	bls.s	99$
	bra.s	6$
9$:	cmp.b	#4,Machine(a5)		; Die folgenden gibt es erst ab 68040
	blo.s	6$
	lea	creg_MMUSR(pc),a1	; MMUSR
	bsr	CmpCReg
	bne.s	10$
	cmp.b	#4,Machine(a5)		; nur fuer 68040
	beq.s	99$
	bra.s	6$
10$:	lea	creg_URP(pc),a1		; URP
	bsr	CmpCReg
	beq.s	99$
	lea	creg_SRP(pc),a1		; SRP
	bsr	CmpCReg
	beq.s	99$
	cmp.b	#6,Machine(a5)		; Das folgende erst ab 68060
	blo.s	6$
	lea	creg_PCR(pc),a1		; PCR
	bsr	CmpCReg
	beq.s	99$

	bsr	UndefSym
99$:	move.l	(sp)+,a0		; NewInput
	move.b	d2,(a0)			; Alten String-Begrenzer wieder einsetzen
	move.w	d3,d0			; ControlRegister-Code
	rts

	cnop	0,4
CmpCReg:
; a1 CReg-String
	addq.w	#1,d3
	move.l	a3,a0
	bra	StrCmp

creg_SFC:
	dc.b	"SFC",0
creg_DFC:
	dc.b	"DFC",0
creg_CACR:
	dc.b	"CACR",0
creg_VBR:
	dc.b	"VBR",0
creg_CAAR:
	dc.b	"CAAR",0
creg_MSP:
	dc.b	"MSP",0
creg_ISP:
	dc.b	"ISP",0
creg_TC:
	dc.b	"TC",0
creg_ITT0:
	dc.b	"ITT0",0
creg_ITT1:
	dc.b	"ITT1",0
creg_DTT0:
	dc.b	"DTT0",0
creg_DTT1:
	dc.b	"DTT1",0
creg_BUSCR:
	dc.b	"BUSCR",0
creg_MMUSR:
	dc.b	"MMUSR",0
creg_URP:
	dc.b	"URP",0
creg_SRP:
	dc.b	"SRP",0
creg_PCR:
	dc.b	"PCR",0
	even


MovS:					; MOVES Rn,ea  MOVES ea,Rn  (68010)
	jmp	MovS2(pc)
	addq.l	#2,d6
	moveq	#$20,d1
	bra	InstrSize
MovS2:
	tst.b	Machine(a5)
	beq	IllegalInstr		; auf MC68000 nicht implementiert
	clr.b	TryPC(a5)
	move.l	#%00000011011111110000001101111111,d0
	moveq	#$20,d1
	bsr	GetCpOper
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	moveq	#ea_Adirect,d3
	cmp.b	oper2+opMode(a5),d3
	blo.s	2$
	lea	oper1(a5),a2		; MOVES ea,Rn
	moveq	#$60,d2
	moveq	#0,d5
	move.b	oper2+opReg(a5),d5
	move.b	oper2+opMode(a5),d0
	bra.s	3$
2$:	lea	oper2(a5),a2		; MOVES Rn,ea
	move.w	#$a0,d2
	move.w	#$8000,d5
	move.b	oper1+opReg(a5),d5
	move.b	oper1+opMode(a5),d0
3$:	beq.s	4$			; Rn = An ?
	addq.b	#8,d5
4$:	cmp.b	d3,d0
	bhi	IllegalMode
	cmp.b	opMode(a2),d3
	bhs	IllegalMode
	ror.w	#4,d5
	move.b	OpcodeSize(a5),d4
	ror.b	#2,d4
	bra	WriteCPEA
	ENDC


Chk:					; CHK ea,Dn
	jmp	Chk_2(pc)
	moveq	#$20,d1
	bra	InstrSize
Chk_2:
	tst.b	OpcodeSize(a5)
	beq	IllegalMode
	move.l	#%00011111011111010000000000000001,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	tst.b	(a1)
	bne	SyntaxErr
	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	2$
	cmp.b	#2,Machine(a5)		; CHK.L erst ab 68020
	blo	IllegalMode
	clr.b	d4
2$:	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteStdEA


	IFND	SMALLASS
C2:					; CHK2,CMP2 ea,Rn  (68020)
	jmp	C22(pc)
	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
C22:
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	move.l	#%00001111011001000000000000000011,d0
	moveq	#$20,d1
	bsr	GetCpOper
	bpl.s	1$
	rts
1$:	move.w	d4,d5
	move.w	#$6000,d4
	move.b	OpcodeSize(a5),d4
	ror.w	#7,d4
	move.b	oper2+opReg(a5),d5
	subq.b	#ea_Adirect,oper2+opMode(a5)
	bne.s	2$
	addq.b	#8,d5
2$:	ror.w	#4,d5
	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteCPEA
	ENDC


Stp:					; STOP #x
	jmp	Stp2(pc)
	addq.l	#4,d6
	rts
Stp2:
	addq.l	#2,d6
	move.w	d4,d0
	bsr	AddWord
	st	RefFlag(a5)
	move.l	a3,a0
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	moveq	#os_WORD,d0
	bsr	GetValue
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	tst.l	d0
	bmi.s	1$
	swap	d0
	tst.w	d0
	bne.s	1$
	swap	d0
	addq.l	#2,d6
	bra	AddWord
1$:	bra	ImmedSize


	IFND	SMALLASS
BkPt:					; BKPT #x (68010)
	jmp	BkPt2(pc)
	addq.l	#2,d6
	rts
BkPt2:
	tst.b	Machine(a5)
	beq	IllegalInstr
	st	RefFlag(a5)
	move.l	a3,a0
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	moveq	#os_BYTE,d0
	bsr	GetValue		; Breakpoint-Vector
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	tst.l	d0
	bmi.s	1$
	moveq	#8,d1			; Nur 0-7 erlaubt
	cmp.l	d1,d0
	bhs.s	1$
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord
1$:	bra	ImmedSize


RtD:					; RTD #d (68010)
	jmp	RtD2(pc)
	addq.l	#4,d6
	rts
RtD2:
	tst.b	Machine(a5)
	beq	IllegalInstr
	move.w	d4,d0
	bsr	AddWord			; RTD-Opcode
	addq.l	#2,d6
	st	RefFlag(a5)
	move.l	a3,a0
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	moveq	#os_WORD,d0
	bsr	GetValue		; Displacement lesen (signed word)
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	beq.s	1$
	tst.b	d2			; Nur Programm-Distanzen sind erlaubt
	bmi	AddrError
	clr.w	d2
	swap	d2
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
1$:	bsr	WordLimits
	bne	ImmedSize
	addq.l	#2,d6
	bra	AddWord
	ENDC


LineAF:					; LINEA xx  oder LINEF xx
	jmp	LineAF2(pc)
	addq.l	#2,d6
	rts
LineAF2:
	st	RefFlag(a5)
	move.l	a3,a0
	moveq	#os_WORD,d0
	bsr	GetValue
	tst.b	(a0)
	bne	SyntaxErr
	tst.w	d2
	bmi	UndefSym
	bne	AddrError		; Programmadressen sind nicht erlaubt
	and.w	#$0fff,d0
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord


	IFND	SMALLASS
CallM:					; CALLM #x,ea (68020)
	jmp	CallM2(pc)
	addq.l	#2,d6
	move.w	#$a0,d1
	bra	InstrSize
CallM2:
	cmp.b	#2,Machine(a5)		; nur beim 68020 implementiert!
	bne	IllegalInstr
	move.b	#-2,TryPC(a5)
	clr.b	OpcodeSize(a5)
	move.l	#%00010000000000000000111101100100,d0
	moveq	#$20,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	lea	oper2(a5),a2
	moveq	#$20,d2
	bra	WriteStdEA


Rtm:					; RTM Rn (68020)
	jmp	Rtm2(pc)
	addq.l	#2,d6
	rts
Rtm2:
	cmp.b	#2,Machine(a5)		; nur beim 68020 implementiert!
	bne	IllegalInstr
	st	RefFlag(a5)
	move.l	a3,a0
	bsr	GetRegister
	bmi	MissingReg
	tst.b	(a0)
	bne	SyntaxErr
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord


Cas:					; CAS Dc,Du,ea (68020)
	jmp	Cas_2(pc)
	addq.l	#2,d6
	move.w	#$c0,d1
	bra	InstrSize
Cas_2:
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	move.l	#%00000000000000010000000000000001,d0
	move.l	#%00000011011111000000000000000000,d1
	bsr	GetCpOper
	bpl.s	1$
	rts
1$:	moveq	#1,d0
	add.b	OpcodeSize(a5),d0
	ror.w	#7,d0
	or.w	d0,d4
	moveq	#0,d5
	move.b	oper2+opReg(a5),d5
	lsl.w	#6,d5
	or.b	oper1+opReg(a5),d5
	lea	oper3(a5),a2
	move.w	#$c0,d2
	bra	WriteCPEA


Cas2:				; CAS2 Dc1:Dc2,Du1:Du2,(Rn1):(Rn2)  (68020)
	jmp	Cas22(pc)
	addq.l	#6,d6
	rts
Cas22:
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	moveq	#0,d0
	move.b	OpcodeSize(a5),d0
	beq	IllegalMode
	addq.b	#1,d0
	ror.w	#7,d0
	or.w	d4,d0
	addq.l	#6,d6
	bsr	AddWord
	st	RefFlag(a5)
	move.l	a3,a0
	bsr.s	10$			; Dc1:Dc2 lesen
	beq.s	2$
1$:	bra	Error
2$:	move.w	d2,d4
	move.w	d0,d5
	bsr.s	10$			; Du1:Du2 lesen
	bne.s	1$
	lsl.w	#6,d2
	lsl.w	#6,d0
	or.w	d2,d4
	or.w	d0,d5
	bsr.s	20$			; (Rn1)
	bne.s	1$
	or.w	d0,d4
	cmp.b	#':',(a0)+
	bne	SyntaxErr
	bsr.s	20$			; (Rn2)
	bne.s	1$
	or.w	d0,d5
	move.w	d4,d0
	bsr	AddWord
	move.w	d5,d0
	bra	AddWord
10$:					; "D1:D2," nach d2:d0 holen
	bsr	GetRegister
	bpl.s	12$
11$:	moveq	#37,d0			; Missing register
	rts
12$:	bclr	#3,d0
	beq.s	14$
13$:	moveq	#38,d0			; Need data register
	rts
14$:	move.w	d0,d2
	cmp.b	#':',(a0)+
	beq.s	16$
15$:	moveq	#41,d0			; Syntax error
	rts
16$:	bsr	GetRegister
	bmi.s	11$
	bclr	#3,d0
	bne.s	13$
	cmp.b	#',',(a0)+
	bne.s	15$
	moveq	#0,d1
	rts
20$:	; (Rn) nach d0[15:12] holen
	cmp.b	#'(',(a0)+
	bne.s	15$
	bsr	GetRegister
	bmi.s	11$
	cmp.b	#')',(a0)+
	bne.s	15$
	ror.w	#4,d0
	moveq	#0,d1
	rts


Pack:				; PACK/UNPK -(Ax),-(Ay),#a / Dx,Dy,#a (68020)
	jmp	Pack2(pc)
	addq.l	#4,d6
	rts
Pack2:
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	move.b	#os_WORD,OpcodeSize(a5)
	move.l	#%00000000000100010000000000010001,d0
	move.l	#%00010000000000000000000000000000,d1
	bsr	GetOperand
	bpl.s	1$
	rts
1$:	move.b	oper1+opMode(a5),d0
	beq.s	2$
	addq.w	#8,d4			; Predecrement Mode
2$:	cmp.b	oper2+opMode(a5),d0	; Modi muessen gleich sein
	bne	IllegalMode
	moveq	#0,d0
	move.b	oper2+opReg(a5),d0
	ror.w	#7,d0
	or.w	d4,d0
	or.b	oper1+opReg(a5),d0
	bsr	AddWord
	move.w	#$c0,d2
	bra	WriteExt


TrpCC:					; TRAPcc [#x]	     (68020)
	jmp	TrpCC2(pc)
	addq.l	#2,d6
	tst.b	(a3)			; Operand da?
	beq.s	1$
	addq.l	#2,d6
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	1$
	addq.l	#2,d6
1$:	rts
TrpCC2:
	cmp.b	#2,Machine(a5)
	blo	IllegalInstr
	tst.b	(a3)
	bne.s	1$
	moveq	#4,d0			; TRAPcc ohne Parameter
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord
1$:	move.b	OpcodeSize(a5),d0
	beq	IllegalMode		; TRAPcc.B gibt's nicht
	addq.b	#1,d0
	or.b	d0,d4
	move.l	#%00010000000000000000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand		; Parameter lesen
	bpl.s	2$
	rts
2$:	move.w	d4,d0
	bsr	AddWord
	moveq	#$60,d2
	bra	WriteExt


Mov16:					; MOVE16 ...  (68040)
	jmp	Mov162(pc)
	move.l	d6,-(sp)
	moveq	#$20,d1
	bsr	InstrSize
	move.l	d6,d0
	subq.l	#2,d0
	sub.l	(sp)+,d0
	bne.s	1$
	addq.l	#2,d6
1$:	rts
Mov162:
	cmp.b	#4,Machine(a5)		; erst ab 68040 verfuegbar!
	blo	IllegalInstr
	clr.b	TryPC(a5)
	move.l	#%00000010000011000000001000001100,d0
	moveq	#$20,d1
	clr.b	OptFlag(a5)		; xxxx.L NICHT zu xxxx.W optimieren!
	bsr	GetOperand
	move.l	CurrentSec(a5),a0
	move.b	sec_Flags(a0),OptFlag(a5)
	tst.w	d0
	bpl.s	1$
	rts
1$:	moveq	#0,d2
	lea	oper1(a5),a2
	lea	oper2(a5),a3
	move.b	opMode(a2),d0
	move.b	opMode(a3),d1
	cmp.b	#ea_AindPostInc,d0
	bne.s	2$
	cmp.b	d1,d0
	bne.s	3$			; (Ax)+,(Ay)+ ?
	addq.l	#2,d6
	moveq	#$20,d0
	or.b	opReg(a2),d0
	or.w	d4,d0
	bsr	AddWord
	moveq	#8,d0
	or.b	opReg(a3),d0
	ror.w	#4,d0
	bra	AddWord
2$:	moveq	#$10,d2
	subq.b	#ea_Aind,d0
	beq.s	3$
	exg	a2,a3
	moveq	#$18,d2
	subq.b	#ea_Aind,d1
	beq.s	3$
	moveq	#$08,d2
	subq.b	#1,d1
	bne	IllegalMode
3$:	cmp.w	#(ea_SpecialMode<<8)+(ea_AbsLong&7),opMode(a3)
	bne	IllegalMode
	move.w	d4,d0
	or.b	d2,d0
	or.b	opReg(a2),d0
	bsr	AddWord
	move.l	opVal1(a3),d0
	bra	AddLong


Cinv:					; CINVx/CPUSHx <caches>[,(An)]   (68040)
	jmp	Cinv2(pc)
	addq.l	#2,d6
	rts
Cinv2:
	cmp.b	#4,Machine(a5)
	blo	IllegalInstr
	moveq	#0,d0
	move.w	#$dfdf,d1
	and.w	(a3)+,d1
	cmp.w	#'NC',d1		; Neither Cache
	beq.s	1$
	moveq	#1,d0
	cmp.w	#'DC',d1		; Data Cache
	beq.s	1$
	moveq	#2,d0
	cmp.w	#'IC',d1		; Instruction Cache
	beq.s	1$
	moveq	#3,d0
	cmp.w	#'BC',d1		; Both Caches
	bne	SyntaxErr
1$:	lsl.w	#6,d0
	or.w	d0,d4
	moveq	#0,d0
	moveq	#$18,d1
	and.w	d4,d1
	cmp.w	#$18,d1			; kein Adressregister bei CINVA/CPUSHA
	beq.s	2$
	cmp.b	#',',(a3)+
	bne	SyntaxErr
	cmp.b	#'(',(a3)+
	bne	IllegalMode
	move.l	a3,a0
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	cmp.b	#')',(a0)
	bne	IllegalMode
2$:	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord


LpStop:			; LPSTOP #x  (wie STOP #x, nur im LowPowerMode)
	jmp	LpStop2(pc)
	addq.l	#6,d6
	rts
LpStop2:
	cmp.b	#6,Machine(a5)		; 68060 Instruktion!
	blo	IllegalInstr
	addq.l	#6,d6
	move.w	d4,d0
	bsr	AddWord
	move.w	#$01c0,d0
	bsr	AddWord
	st	RefFlag(a5)
	move.l	a3,a0
	cmp.b	#'#',(a0)+
	bne	IllegalMode
	moveq	#os_WORD,d0
	bsr	GetValue
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	tst.l	d0
	bmi.s	1$
	swap	d0
	tst.w	d0
	bne.s	1$
	swap	d0
	bra	AddWord
1$:	bra	ImmedSize


Plpa:					; PLPAR (An), PLPAW (An)  (68060)
	jmp	Plpa2(pc)
	addq.l	#2,d6
	rts
Plpa2:
	cmp.b	#6,Machine(a5)		; 68060 Instruktion!
	blo	IllegalInstr
	addq.l	#2,d6
	move.l	a3,a0
	cmp.b	#'(',(a0)+
	bne	IllegalMode
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	cmp.b	#')',(a0)
	bne	IllegalMode
	or.w	d4,d0
	bra	AddWord


FEquReg:				; label FEQUR register
	nop
	nop
	move.l	a3,a0
	bsr	GetFPReg
	bpl.s	1$			; Register ok ?
	moveq	#31,d0			; Not a register
	bsr	Error
	bra.s	3$
1$:	tst.b	(a2)			; kein Label gegeben ?
	bne.s	2$
	bsr	MissingLabel
	bra.s	3$
2$:	move.l	a2,a0
	bsr	AddFPRegName
3$:	clr.b	(a2)			; Label löschen
	bra	RemEQULine		; im nächsten Pass nicht mehr beachten


FPRegList:
	; label FREG reglist (getrennt durch / oder -)
	nop
	nop
	move.l	a3,a0
	bsr	GetFPRegList
	bpl.s	1$			; Registerliste war fehlerfrei ?
	moveq	#27,d0			; Bad register list
	bsr	Error
	moveq	#0,d0
1$:	move.l	d0,d1
	moveq	#T_FREG,d0
	tst.b	(a2)			; kein Label gegeben ?
	bne.s	2$
	bsr	MissingLabel
	bra.s	3$
2$:	move.l	a2,a0
	bsr	AddGorLSymbol
3$:	clr.b	(a2)			; Label loeschen
	bra	RemEQULine		; im naechsten Pass nicht mehr beachten


gregl_data:
	dc.w	0,0,0,7
GetFPRegList:
; Zusammenfassen aller Register in einer Register-List zu einem Byte, wie es
; von FMOVEM benoetigt wird
; a0 = RegListText
; -> d0 = RegListBits (im MSW fuer SrcOperand und im LSW fuer DestOperand)
; -> d1 = Zahl der gesetzten Reg.Bits in d0 (oder negativ bei Fehler)
	movem.l	d2-d5/d7,-(sp)
	movem.w	gregl_data(pc),d2/d3/d5/d7
	tst.b	(a0)			; ueberhaupt ein Register benannt ?
	beq.s	9$
1$:	bsr.s	GetFPReg		; Register bestimmen
	bmi.s	11$			; unbekanntes Register ?
	move.w	d0,d4
	bset	d0,d3			; RegBit setzen (Src)
	eor.w	d7,d0
	bset	d0,d2			; RegBit setzen (Dest)
	bne.s	2$
	addq.w	#1,d5
2$:	move.b	(a0)+,d1
	beq.s	9$			; fertig ?
	cmp.b	#',',d1
	beq.s	9$
	cmp.b	#'/',d1			; '/' kuendigt ein weiteres Register an
	beq.s	1$
	cmp.b	#'-',d1			; '-' Register-Range ?
	bne.s	10$			; unbekanntes Zeichen ?
	bsr.s	GetFPReg		; Range-Register holen
	bmi.s	11$
	cmp.w	d0,d4
	beq.s	2$			; Range zum selben Reg. (z.B. d0-d0) ?
	bhi.s	3$
	exg	d0,d4
3$:	move.w	d0,d1
	eor.w	d7,d1
	bset	d0,d3			; RegBits setzen (Dest)
	bset	d1,d2			; (Src)
	bne.s	4$
	addq.w	#1,d5
4$:	addq.w	#1,d0
	subq.w	#1,d1
	cmp.w	d4,d0			; alle gesetzt ?
	bls.s	3$
	bra.s	2$
9$:	move.w	d3,d0			; RegBits(Dest)
	swap	d0
	move.w	d2,d0			; RegBits(Src)
	move.w	d5,d1			; Anzahl der Register
	movem.l	(sp)+,d2-d5/d7
	rts
10$:	moveq	#29,d0			; Illegal seperator for a register list
	bra.s	12$
11$:	moveq	#37,d0			; Missing register
12$:	bsr	Error
	moveq	#0,d0
	moveq	#-1,d1
	movem.l	(sp)+,d2-d5/d7
	rts


GetFPReg:
; Floatingpoint-Register (FP0-FP7) lesen
; a0 = StrPointer
; -> a0 = NewStrPointer
; d0 = FP-Register Nummer (bei N=0, und d1=0)
;    = FP-ControlRegister Nummer (bei N=1 und d1=-1) oder Fehler bei -1
	movem.l	d2/a2-a3,-(sp)
	lea	Buffer(a5),a2
	move.l	a0,a3
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; RegisterName in Buffer holen
	beq.s	9$			; nichts lesen können ?
	add.w	d0,a3
	move.w	d0,d2
	move.l	a2,a0
	bsr	checkFP
	bmi.s	2$
	tst.w	d1
	beq.s	1$
	moveq	#-1,d1			; N=1, d1=-1, bei FPControlRegister
1$:	move.l	a3,a0
	movem.l	(sp)+,d2/a2-a3
	rts
9$:	moveq	#0,d1
	moveq	#-1,d0
	bra.s	1$
2$:	move.l	a2,a0
	move.w	d2,d0
	bsr	FindFPRegName
	bmi.s	9$			; existiert nicht ?
	move.l	d0,-(sp)
	tst.b	RefFlag(a5)		; Referenzen eintragen?
	beq.s	5$
	lea	FPRegRefs(a5),a0	; Registerreferenz vermerken
	IFEQ	MAXFPREGNAMES-64
	lsl.w	#8,d0
	add.w	d0,a0
	ELSE
	mulu	#MAXFPREGNAMES<<2,d0
	add.l	d0,a0
	ENDC
	moveq	#MAXFPREGNAMES-1,d0
	sub.w	d1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),d0		; erster RegRefList-Chunk
3$:	move.l	d0,a2
	cmp.w	#REGREFLISTBLK/rrlSIZE,rrl_NumRefs(a2)
	blo.s	4$			; Chunk voll?
	move.l	(a2),d0			; Link holen
	bne.s	3$
	jsr	GetRegRefList		; Neuen Chunk holen und verbinden
	move.l	d0,(a2)
	move.l	d0,a2
4$:	move.w	rrl_NumRefs(a2),d0
	addq.w	#1,rrl_NumRefs(a2)
	add.w	d0,d0
	IFND	GIGALINES
	move.w	AbsLine(a5),rrl_HEAD(a2,d0.w) ; Referenzzeile
	ELSE
	add.w	d0,d0
	move.l	AbsLine(a5),rrl_HEAD(a2,d0.w)
	ENDC
5$:	moveq	#0,d1
	move.l	a3,a0
	movem.l	(sp)+,d0/d2/a2-a3
	rts


checkFP:
; a0 = FPString
; -> d0 = FPReg, oder FPCR/FPSR/FPIAR, -1 = not found
; -> d1 = 1: FPCR/FPSR/FPIAR-Select
; -> N=1: kein explizites FP-Register
	moveq	#-$21,d1
	and.b	(a0)+,d1
	cmp.b	#'F',d1			; FPn ?
	bne.s	1$
	moveq	#-$21,d1
	and.b	(a0)+,d1
	cmp.b	#'P',d1
	bne.s	1$
	moveq	#0,d0
	move.b	(a0),d1
	sub.b	#'0',d1			; RegisterNr. n zwischen 0 und 7 ?
	blo.s	2$
	cmp.b	#7,d1
	bhi.s	2$
	add.b	d1,d0			; Register-Nr.
	moveq	#0,d1
	rts
1$:	moveq	#0,d1
	moveq	#-1,d0
	rts
2$:	moveq	#-$21,d1
	and.b	(a0)+,d1
	cmp.b	#'C',d1			; FPCR
	bne.s	3$
	moveq	#%100,d0
	bra.s	5$
3$:	cmp.b	#'S',d1			; FPSR
	bne.s	4$
	moveq	#%010,d0
	bra.s	5$
4$:	cmp.b	#'I',d1			; FPIAR
	bne.s	1$
	moveq	#%001,d0
	moveq	#-$21,d1
	and.b	(a0)+,d1
	cmp.b	#'A',d1
	bne.s	1$
5$:	moveq	#-$21,d1
	and.b	(a0),d1
	cmp.b	#'R',d1
	bne.s	1$
	moveq	#1,d1
	rts


FindFPRegName:
; a0 = FPRegName
; d0 = Namenslänge
; -> d0 = Reg(0-7) oder -1
	movem.l	d2-d4/a2-a3,-(sp)
	move.l	a0,d2
	move.w	d0,d4
	beq.s	5$			; Länge 0 - nichts gefunden
	lea	FPRegNames(a5),a3
	moveq	#7,d3
1$:	move.l	a3,a2
	moveq	#MAXFPREGNAMES-1,d1
2$:	move.l	(a2)+,d0		; Zeiger auf nächsten RegName holen
	beq.s	4$
	move.l	d0,a0
	move.l	d2,a1
	move.w	d4,d0
3$:	cmpm.b	(a0)+,(a1)+		; Namen vergleichen
	dbne	d0,3$
	beq.s	6$
7$:	dbf	d1,2$			; nächster Name fuer dieses Register
4$:	lea	MAXFPREGNAMES<<2(a3),a3
	dbf	d3,1$			; nächstes Register
5$:	moveq	#-1,d0			; nichts gefunden!
	movem.l	(sp)+,d2-d4/a2-a3
	rts
6$:	moveq	#7,d0
	sub.w	d3,d0			; dem Namen entsprechendes Register
	movem.l	(sp)+,d2-d4/a2-a3
	rts


AddFPRegName:
; a0 = RegName, d0 = Register(0-7)
	movem.l	d2/a2,-(sp)
	move.l	a0,a2
	move.w	d0,d2
	moveq	#-1,d0
4$:	tst.b	(a0)+			; Länge von RegName bestimmen
	dbeq	d0,4$
	not.w	d0
	move.l	a2,a0
	bsr	FindFPRegName		; existiert Symbol schon als RegName?
	bmi.s	1$
	cmp.w	d2,d0			; für dasselbe Reg. nochmal definiert?
	beq.s	9$
	moveq	#18,d0			; Symbol declared twice
	bsr	Error
	bra.s	9$
1$:	move.l	a2,a0
	jsr	AddString
	lea	FPRegNames(a5),a0
	lea	FPRegRefs(a5),a2
	IFEQ	MAXFPREGNAMES-64
	lsl.w	#8,d2
	add.w	d2,a0
	add.w	d2,a2
	ELSE
	mulu	#MAXFPREGNAMES<<2,d2
	add.l	d2,a0
	add.l	d2,a2
	ENDC
	moveq	#MAXFPREGNAMES-1,d1
2$:	addq.l	#4,a2
	tst.l	(a0)+
	dbeq	d1,2$
	beq.s	3$
	moveq	#1,d0			; Out of memory
	bsr	Error
	bra.s	9$
3$:	move.l	d0,-4(a0)		; Zeiger auf Namen eintragen
	jsr	GetRegRefList		; Referenzliste anlegen
	move.l	d0,-4(a2)
	move.l	d0,a0
	IFND	GIGALINES
	move.w	AbsLine(a5),rrl_DeclLine(a0)
	ELSE
	move.l	AbsLine(a5),rrl_DeclLine(a0)
	ENDC
9$:	movem.l	(sp)+,d2/a2
	rts


Psave:
	; PSAVE/PRESTORE <ea>	     (68851)
	jmp	1$(pc)
	moveq	#$60,d1
	bra	InstrSize
1$:	tst.b	PMMUid(a5)
	bne.s	cpSavRes
	bra	IllegalInstr

Fsave:
	; FSAVE/FRESTORE <ea>	     (6888x/68040)
	jmp	Fsave2(pc)
	moveq	#$60,d1
	bra	InstrSize
Fsave2:
	moveq	#0,d0
	move.b	FPUid(a5),d0
	beq	IllegalInstr
	ror.w	#7,d0
	or.w	d0,d4

cpSavRes:
	; cpSAVE/cpRESTORE <ea> fuer alle Coproz.
	btst	#6,d4
	bne.s	2$
	clr.b	TryPC(a5)
	move.l	#%00000011011101000000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand		; FSAVE
	bpl.s	3$
1$:	rts
2$:	move.l	#%00001111011011000000000000000000,d0
	moveq	#$60,d1
	bsr	GetOperand		; FRESTORE
	bmi.s	1$
3$:	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteStdEA


Flt:					; Normal FPU Operations  F<op> <ea>,FPn
	jmp	Flt2(pc)
	move.l	a3,a0
	bsr	GetFPReg		; F<op> FPm[,FPn] ?
	bmi.s	2$
	move.b	(a0),d0
	beq.s	1$
	cmp.b	#',',d0
	bne.s	2$
1$:	addq.l	#4,d6
	rts
2$:	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
Flt2:
	tst.w	d4
	bpl.s	4$
	and.w	#$7fff,d4
	cmp.b	#4,Machine(a5)		; spezieller 68040 Float-Befehl - erlaubt?
	bhs.s	4$
	bsr	IllegalInstr
4$:	move.l	a3,a0
	bsr	GetFPReg
	bmi.s	2$
	clr.w	oper1+opMode(a5)
	clr.w	oper1+opSize1(a5)
	clr.w	oper1+opFormat(a5)
	addq.l	#4,d6
	bclr	#14,d4
	sne	d1			; Monadic Operation?
	cmp.b	#',',(a0)+
	beq.s	3$
	move.l	a3,a0
	tst.b	d1			; Monadic moeglich?
	bne.s	3$
	bra	SyntaxErr
1$:	rts
10$:	dc.b	%110,%100,%000,-1,%001,%101,%010,%011
2$:	move.l	#%00011111011111010000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper
	bmi.s	1$
	or.w	#$4000,d4
	moveq	#0,d0
	move.b	OpcodeSize(a5),d0
	move.b	10$(pc,d0.w),d0		; Source-Specifier holen
	bmi	IllegalMode
	move.l	a2,a0			; Dest.Register
3$:	ror.w	#6,d0
	or.w	d0,d4
	bsr	GetFPReg		; Zielregister lesen
	bmi	MissingReg
	lsl.w	#7,d0
	or.w	d0,d4
	bra	WriteFPEA


FTst:					; FTST <ea> / FPn
	jmp	FTst2(pc)
	move.w	#$dfdf,d0
	and.w	(a3),d0
	cmp.w	#'FP',d0		; FTST FPn ?
	bne.s	1$
	addq.l	#4,d6
	rts
1$:	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
FTst2:
	move.l	a3,a0
	bsr	GetFPReg
	bmi.s	1$
	clr.w	oper1+opMode(a5)
	clr.w	oper1+opSize1(a5)
	clr.w	oper1+opFormat(a5)
	addq.l	#4,d6
	bra.s	3$
10$:	dc.b	%110,%100,%000,-1,%001,%101,%010,%011
1$:	move.l	#%00011111011111010000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper
	bpl.s	2$
	rts
2$:	or.w	#$4000,d4
	moveq	#0,d0
	move.b	OpcodeSize(a5),d0
	move.b	10$(pc,d0.w),d0		; Source-Specifier holen
	bmi	IllegalMode
3$:	ror.w	#6,d0
	or.w	d0,d4
	bra	WriteFPEA


FSincos:				; FSINCOS <ea>,FPc:FPs
	jmp	FSincos2(pc)
	move.w	#$dfdf,d0
	and.w	(a3),d0
	cmp.w	#'FP',d0		; FSINCOS FPm,FPc:FPs	     ?
	bne.s	1$
	addq.l	#4,d6
	rts
1$:	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
FSincos2:
	move.l	a3,a0
	bsr	GetFPReg
	bmi.s	1$
	clr.w	oper1+opMode(a5)
	clr.w	oper1+opSize1(a5)
	clr.w	oper1+opFormat(a5)
	addq.l	#4,d6
	cmp.b	#',',(a0)+
	beq.s	3$
	bra	SyntaxErr
10$:	dc.b	%110,%100,%000,-1,%001,%101,%010,%011
1$:	move.l	#%00011111011111010000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper
	bpl.s	2$
	rts
2$:	or.w	#$4000,d4
	moveq	#0,d0
	move.b	OpcodeSize(a5),d0
	move.b	10$(pc,d0.w),d0		; Source-Specifier holen
	bmi	IllegalMode
	move.l	a2,a0
3$:	ror.w	#6,d0
	or.w	d0,d4
	bsr	GetFPReg		; FPc:FPs lesen
	bmi	MissingReg
	or.b	d0,d4
	cmp.b	#':',(a0)+
	bne	SyntaxErr
	bsr	GetFPReg
	lsl.w	#7,d0
	or.w	d0,d4
	bra	WriteFPEA


FNop:					; FNOP
	jmp	FNop2(pc)
	addq.l	#4,d6
	rts
FNop2:
	addq.l	#4,d6
	move.w	#$4078,d0
	move.b	FPUid(a5),d1
	bne.s	1$
	bsr	IllegalInstr
1$:	or.b	d1,d0
	ror.w	#7,d0
	bsr	AddWord
	moveq	#0,d0
	bra	AddWord


FMovCR:					; FMOVECR #ccc,FPn
	jmp	FMovCR2(pc)
	addq.l	#4,d6
	rts
FMovCR2:
	addq.l	#2,d6
	moveq	#$78,d0
	move.b	FPUid(a5),d1
	bne.s	1$
	bsr	IllegalInstr
1$:	or.b	d1,d0
	ror.w	#7,d0
	bsr	AddWord			; Opcode
	cmp.b	#'#',(a3)+
	bne	IllegalMode
	move.l	a3,a0
	moveq	#os_WORD,d0
	bsr	GetValue		; Constant
	tst.w	d2
	bmi	UndefSym
	bne	NoAddress
	and.w	#$3f,d0
	move.b	d0,d4
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	bsr	GetFPReg		; Dest.FPReg
	bmi	MissingReg
	lsl.w	#7,d0
	or.w	d4,d0
	addq.l	#2,d6
	bra	AddWord


PBcc:					; PBcc <displacement>
	jmp	2$(pc)
	addq.l	#4,d6
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	1$
	addq.l	#2,d6
1$:	rts
2$:	tst.b	PMMUid(a5)
	bne.s	cpBcc
	bra	IllegalInstr

FBcc:					; FBcc <displacement>
	jmp	FBcc2(pc)
	addq.l	#4,d6
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	1$
	addq.l	#2,d6
1$:	rts
FBcc2:
	moveq	#0,d0
	move.b	FPUid(a5),d0
	bne.s	1$
	bsr	IllegalInstr
1$:	ror.w	#7,d0
	or.w	d0,d4

cpBcc:					; cpBcc - Branch fuer alle Coprozessoren
; a3 = Operand
; d4 = OpCode (ohne SIZE-Bit)
	st	RefFlag(a5)
	addq.l	#2,d6
	move.l	a3,a0
	moveq	#os_WORD,d0
	bsr	GetValue
	tst.w	d2
	bmi	UndefSym
	tst.b	d2
	bpl.s	2$			; Sprungmarke muss vom Type Reloc
	clr.w	d2
	swap	d2
	cmp.w	SecNum(a5),d2		;  aus derselben Section
	beq.s	1$
	moveq	#48,d0			; "Displacement outside of section"
	bra	Error
2$:	bne	NoAddress
	swap	d2
	addq.w	#1,d2			;   oder vom Typ XREF sein
	bne	NoAddress
	moveq	#-1,d2
	cmp.b	#os_WORD,d5
	bls.s	1$
	moveq	#os_WORD,d5		; XREF darf kein 32-bit Displace sein
1$:	move.l	d0,d3
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	5$
	btst	#of_Branches,OptFlag(a5)
	beq.s	3$
	sub.l	d6,d0
	bsr	WordLimits		; Pruefen ob auch als 16-bit Branch moeglich
	bne.s	3$
	move.l	d3,oper1+opVal1(a5)
	st	oper1+opType1(a5)
	moveq	#-2,d0
	move.l	d6,a0
	bsr	ShiftRelocs
	move.l	oper1+opVal1(a5),d3
	bra.s	6$
3$:	moveq	#$40,d0			; Size = 32-Bit Displace
	or.w	d4,d0
	bsr	AddWord
	move.l	d3,d0
	move.l	d6,d1
	moveq	#os_LONG,d3
	move.l	d6,a1
	bsr	AddDistance
	addq.l	#4,d6
	bra	AddLong
5$:	sub.l	d6,d0
	bsr	WordLimits		; Pruefen ob cpBcc.w in 16-Bit Grenzen
	beq.s	6$
	tst.b	DistChkDisable(a5)
	beq	LargeDist
6$:	move.w	d4,d0
	bsr	AddWord
	move.l	d3,d0
	move.l	d6,d1
	tst.w	d2			; XREF?
	bmi.s	7$
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
7$:	addq.l	#2,d6
	bra	AddWord


PDBcc:					; PDBcc Dn,displacement
	jmp	1$(pc)
	addq.l	#6,d6
	rts
1$:	moveq	#0,d5
	tst.b	PMMUid(a5)
	bne.s	cpDBcc
	bra	IllegalInstr

FDBcc:					; FDBcc Dn,displacement
	jmp	FDBcc2(pc)
	addq.l	#6,d6
	rts
FDBcc2:
	moveq	#0,d5
	move.b	FPUid(a5),d5
	bne.s	1$
	bsr	IllegalInstr
1$:	ror.w	#7,d5

cpDBcc:					; cpDBcc fuer alle Coprozessoren
; a3 = Operand
; d5 = Opcode(Coprocessor ID), d4 = ConditionalPredicate
	st	RefFlag(a5)
	addq.l	#4,d6
	or.w	#$f048,d5
	move.l	a3,a0
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedDReg
	move.l	a0,a3
	or.w	d5,d0
	bsr	AddWord			; Opcode
	move.w	d4,d0
	bsr	AddWord			; Conditional Predicate
	cmp.b	#',',(a3)+
	bne	SyntaxErr
	move.l	a3,a0
	moveq	#os_WORD,d0
	bsr	GetValue		; displacement lesen
	tst.w	d2
	bmi	UndefSym
	tst.b	d2
	bpl.s	1$			; displacement muss vom Type Reloc
	clr.w	d2
	swap	d2
	cmp.w	SecNum(a5),d2		;  aus derselben Section
	beq.s	2$
	moveq	#48,d0			; "Displacement outside of section"
	bra	Error
1$:	bne	NoAddress
	swap	d2
	addq.w	#1,d2			;   oder vom Typ XREF sein
	bne	NoAddress
	moveq	#-1,d2
2$:	move.l	d0,d3
	sub.l	d6,d0
	bsr	WordLimits		; Sprungmarke in Reichweite?
	beq.s	3$
	tst.b	DistChkDisable(a5)
	beq	LargeDist
3$:	move.l	d3,d0
	move.l	d6,d1
	moveq	#os_WORD,d3
	move.l	d6,a1
	bsr	AddDistance
	addq.l	#2,d6
	bra	AddWord


PScc:					; PScc <ea>
	jmp	1$(pc)
	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
1$:	moveq	#0,d0
	tst.b	PMMUid(a5)
	bne.s	cpScc
	bra	IllegalInstr

FScc:					; FScc <ea>
	jmp	FScc2(pc)
	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
FScc2:
	moveq	#0,d0
	move.b	FPUid(a5),d0
	bne.s	1$
	bsr	IllegalInstr
1$:	ror.w	#7,d0

cpScc:					; cpScc fuer alle Coprozessoren
; a3 = Operand
; d0 = Opcode(Coprocessor ID), d4 = ConditionalPredicate
	or.w	#$f040,d0
	move.l	d0,-(sp)
	clr.b	TryPC(a5)
	move.l	#%00000011011111010000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper
	bpl.s	1$
	addq.l	#4,sp
	rts
1$:	move.w	d4,d5
	move.l	(sp)+,d4
	lea	oper1(a5),a2
	moveq	#$60,d2
	bra	WriteCPEA


PTrp:					; PTRAPcc [#x]
	jmp	2$(pc)
	addq.l	#4,d6
	tst.b	(a3)			; Operand da?
	beq.s	1$
	addq.l	#2,d6
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	1$
	addq.l	#2,d6
1$:	rts
2$:	moveq	#0,d0
	tst.b	PMMUid(a5)
	bne.s	cpTRAPcc
	bra	IllegalInstr

FTrp:					; FTRAPcc [#x]
	jmp	FTrp2(pc)
	addq.l	#4,d6
	tst.b	(a3)			; Operand da?
	beq.s	1$
	addq.l	#2,d6
	cmp.b	#os_LONG,OpcodeSize(a5)
	blo.s	1$
	addq.l	#2,d6
1$:	rts
FTrp2:
	moveq	#0,d0
	move.b	FPUid(a5),d0
	bne.s	1$
	bsr	IllegalInstr
1$:	ror.w	#7,d0

cpTRAPcc:				; cpTRAPcc [#x]  fuer alle Coprozessoren
; a3 = Operand
; d0 = Opcode(Coprocessor ID), d4 = ConditionalPredicate
	exg	d0,d4
	move.l	d0,-(sp)
	or.w	#$f078,d4
	tst.b	(a3)
	bne.s	1$
	moveq	#4,d0			; cpTRAPcc ohne Parameter
	or.w	d4,d0
	addq.l	#4,d6
	bsr	AddWord
	move.l	(sp)+,d0
	bra	AddWord
1$:	move.b	OpcodeSize(a5),d0
	beq	IllegalMode		; cpTRAPcc.B gibt's nicht
	addq.b	#1,d0
	or.b	d0,d4
	move.l	#%00010000000000000000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper		; Parameter lesen
	bpl.s	2$
	addq.l	#4,sp
	rts
2$:	move.w	d4,d0
	bsr	AddWord
	move.l	(sp)+,d0
	bsr	AddWord
	moveq	#$60,d2
	bra	WriteExt


FMov:					; FMOVE <ea>,FPn  oder  FMOVE FPm,<ea>
	jmp	FMov2(pc)
	bsr	SplitOperand
	moveq	#$60,d3
	move.l	a2,a0
	bsr	GetFPReg
	tst.w	d0
	bmi.s	1$
	move.l	a3,a0
	bsr	GetFPReg		; FPm,FPn ?
	tst.w	d0
	bmi.s	2$
	addq.l	#4,d6
	rts
1$:	move.w	#$a0,d3
2$:	addq.l	#2,d6
	bra	SplittedInstrSize
FMov2:
	bsr	SplitOperand
	st	RefFlag(a5)
	move.l	a2,a0
	bsr	GetFPReg		; <ea>,FPn ?
	tst.w	d0
	bmi	FMov3
	addq.l	#4,d6
	btst	#6,d4
	beq.s	1$			; Spezieller 68040 Befehl (FSMOVE/FDMOVE) ?
	cmp.b	#4,Machine(a5)
	blo	IllegalInstr
1$:	tst.w	d1
	beq.s	4$
	move.w	#$8000,d4		; FMOVE.L <ea>,FPcr
	move.b	#os_LONG,OpcodeSize(a5)
	lsl.w	#3,d0
4$:	lsl.w	#7,d0
	or.w	d0,d4
	lea	oper1(a5),a2
	move.l	a3,a0
	bsr	GetFPReg		; oder sogar FMOVE FPm,FPn ?
	bmi.s	2$
	clr.w	opMode(a2)
	clr.w	opSize1(a2)
	clr.w	opFormat(a2)
	tst.w	d4
	bpl.s	3$
	bra	IllegalMode		; nur FMOVE <ea>,FPcr erlaubt
2$:	addq.w	#5,ListFileOff(a5)
	clr.w	opType1(a2)
	movem.l	d4/d7,-(sp)
	moveq	#0,d7
	bsr	ProcessOperand
	movem.l	(sp)+,d4/d7
	bne	Error
	move.w	#%0001111101111101,d0
	cmp.w	#$8400,d4
	bne.s	5$
	addq.w	#2,d0			; FMOVE.L a0,FPIAR ermoeglichen
5$:	btst	d1,d0
	beq	IllegalMode
	tst.w	d4			; FMOVE ControlReg ?
	bmi.s	6$
	or.w	#$4000,d4
	moveq	#0,d0
	move.b	OpcodeSize(a5),d0
	tst.w	d1			; Dn,FPn ?
	bne.s	7$
	moveq	#%00010111,d1
	btst	d0,d1			; Nur B, W, L und S erlaubt
	beq	IllegalMode
7$:	move.b	FMovSize(pc,d0.w),d0	; Source-Specifier holen
	bmi	IllegalMode
3$:	ror.w	#6,d0
	or.w	d0,d4
6$:	bra	WriteFPEA
FMovSize:
	dc.b	%110,%100,%000,-1,%001,%101,%010,%011

FMov3:
	; FMOVE FPm,<ea> oder FMOVE.P FPm,<ea>{#k/Dn}
	btst	#6,d4
	bne	IllegalMode		; FSMOVE/FDMOVE FPm,<ea> gibt's nicht
	or.w	#$6000,d4
	addq.l	#4,d6
	move.l	a3,a0
	bsr	GetFPReg
	tst.w	d0
	bmi	MissingReg
	tst.w	d1
	beq.s	3$
	move.w	#$a000,d4		; FMOVE.L FPcr,<ea>
	move.b	#os_LONG,OpcodeSize(a5)
	lsl.w	#3,d0
3$:	lsl.w	#7,d0
	or.w	d0,d4
	move.l	a2,a3
	lea	oper1(a5),a2
	clr.b	TryPC(a5)
	addq.w	#5,ListFileOff(a5)
	clr.w	opType1(a2)
	movem.l	d4/d7/a3,-(sp)
	moveq	#0,d7
	bsr	ProcessOperand
	movem.l	(sp)+,d4/d7/a3
	bne	Error
	move.w	#%0000001101111101,d0
	cmp.w	#$a400,d4
	bne.s	4$
	addq.w	#2,d0			; FMOVE.L FPIAR,a0  ermoeglichen
4$:	btst	d1,d0
	beq	IllegalMode
	tst.w	d4			; FMOVE ControlReg ?
	bmi.s	5$
	moveq	#0,d0
	move.b	OpcodeSize(a5),d0
	tst.w	d1			; FPn,Dn ?
	beq.s	6$
7$:	move.b	FMovSize(pc,d0.w),d0	; Source-Specifier holen
	bmi	IllegalMode
	ror.w	#6,d0
	or.w	d0,d4
	cmp.w	#$0c00,d0		; Size = Packed BCD ?
	bne	WriteFPEA
	lea	1(a3),a0
	moveq	#'{',d1
1$:	move.b	(a0)+,d0		; {K-Factor} lesen
	beq	SyntaxErr
	cmp.b	d1,d0
	bne.s	1$
	cmp.b	#'#',(a0)		; #k  direkt angegeben ?
	beq.s	2$
	or.w	#$1000,d4
	bsr	GetRegister		; {Dn} lesen
	bmi	MissingReg
	bclr	#3,d0
	bne	NeedAReg
	lsl.w	#4,d0
	or.w	d0,d4
	bra	WriteFPEA
6$:	moveq	#%00010111,d1
	btst	d0,d1			; Nur B, W, L und S erlaubt
	bne.s	7$
	bra	IllegalMode
2$:	addq.l	#1,a0
	moveq	#0,d0
	bsr	GetValue		; {#k}
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	and.w	#$7f,d0
	or.w	d0,d4
5$:	bra	WriteFPEA


FMovM:					; FMOVEM <list>/Dn,<ea> oder <ea>,<list>/Dn
	jmp	FMovM2(pc)
	addq.l	#2,d6
	bsr	SplitOperand
	cmp.b	#os_LONG,OpcodeSize(a5)
	beq	5$			; FMOVEM.L FPControlRegs
	move.l	a3,a0
	bsr	GetFPReg		; RegList,ea  bzw.  Dn,ea
	tst.w	d0
	bpl.s	1$
	move.l	a3,a0
	bsr	GetRegister
	bmi.s	2$
1$:	move.w	#$a0,d3
	bra	SplittedInstrSize
2$:	move.l	a2,a0
	bsr	GetFPReg		; ea,RegList bzw. ea,Dn
	bpl.s	3$
	move.l	a2,a0
	bsr	GetRegister
	bmi.s	4$
3$:	moveq	#$60,d3
	bra	SplittedInstrSize
4$:	subq.l	#4,d6			; unknown,unknown
	moveq	#$20,d3
	bra	SplittedInstrSize
5$:	move.l	a3,a0
	bsr	GetFPReg
	tst.w	d1
	beq.s	3$
	bra.s	1$

FMovM2:
	bsr	SplitOperand
	move.b	OpcodeSize(a5),d0
	cmp.b	#os_EXTENDED,d0
	beq.s	4$
	subq.b	#os_WORD,d0
	beq.s	4$
	subq.b	#os_LONG-os_WORD,d0
	beq	FMovMCR			; FMOVEM.L FPControlRegs
	moveq	#20,d0			; Illegal Opcode Extension
	bsr	Error
4$:	addq.l	#2,d6
	addq.w	#5,ListFileOff(a5)
	or.w	#$5000,d4
	exg	a2,a3
	bsr	FMovMChk
	bne.s	1$
	or.w	#$2000,d4		; from FPU to Memory
	move.w	#%0000001101110100,d2
	clr.b	TryPC(a5)
	bra.s	2$
1$:	exg	a2,a3
	bsr	FMovMChk		; dann muß es Memory to FPU sein
	bne	UndefSym
	move.w	#%0001111101101100,d2
2$:	addq.l	#2,d6
	move.l	d0,d3			; RegList-Bits
	lea	oper1(a5),a2
	clr.w	opType1(a2)
	movem.l	d1-d4/d7,-(sp)
	moveq	#0,d7
	bsr	ProcessOperand
	move.w	d1,a0
	movem.l	(sp)+,d1-d4/d7
	bne	Error
	move.w	a0,d0
	btst	d0,d2
	beq	IllegalMode		; unterstützte Adressierungsart?
	subq.b	#ea_AindPreDec,d0
	bne.s	3$			; reglist,-(An) ?
	swap	d3			; Inverse RegList fuer Predecrement-Mode
	and.w	#$efff,d4
3$:	move.b	d3,d4			; Static/dynamic RegList in ExtWord eintragen
	btst	#of_MoveM,OptFlag(a5)
	beq	WriteFPEA
	tst.w	d1
	bne	WriteFPEA		; überhaupt kein Register in der RegList ?
	bsr	DelLastRefs		; fmovem-Befehl vollständig entfernen
	bsr	DelLastRelocs
	bsr	DelLastDists
	moveq	#-2,d0
	sub.b	opSize1(a2),d0
	sub.b	opSize2(a2),d0
	add.w	d0,d0
	bra	ShiftPC

FMovMChk:
; a2 = 1.Operand (a3=2.Operand)
; d4 = FP-ExtWord
; d6 = PC
; -> d4 = New FP-ExtWord (z.B. für Dyn.RegList)
; -> d0 = RegList
; -> d1 = NumRegs
; -> Z	= TRUE, wenn RegList im Operanden gefunden
	move.l	a2,a0
	bsr	GetFPReg		; FP Register vorhanden?
	bmi.s	1$
	st	RefFlag(a5)
	move.l	a2,a0
	bsr	GetFPRegList		; RegList lesen
	bpl.s	5$
	bra.s	3$
1$:	st	RefFlag(a5)
	move.l	a2,a0
	bsr	GetRegister		; dynamisch (D-Register)?
	bmi.s	2$
	move.l	d0,-(sp)
	move.l	a3,a0			; dann dürfen im anderen Operanden
	bsr	GetFPReg		;  *keine* FPU-Register mehr sein!
	tst.w	d0
	bpl.s	8$
	move.l	(sp)+,d0
	bclr	#3,d0
	bne.s	3$			; A-Reg wäre IllegalMode
	or.w	#$0800,d4		; Dynamic RegList
	lsl.w	#4,d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	moveq	#1,d1
	bra.s	5$
2$:	move.l	a2,a0
	bsr	FindGorLSymbol		; ist es ein RegList-Symbol?
	beq.s	3$
	move.l	d0,a0
	cmp.w	#T_FREG,sym_Type(a0)
	beq.s	4$
3$:	moveq	#-1,d2
	rts
8$:	addq.l	#4,sp
	bra.s	3$
4$:	move.l	d4,-(sp)
	move.l	d6,d5
	bsr	RegListRef		; Referenz eintragen, Register zählen
	move.l	(sp)+,d4
5$:	moveq	#0,d2
	rts

FMovMCR:
	move.l	a3,a0
	bsr	GetFPReg
	tst.w	d1
	beq.s	1$
	or.w	#$2000,d4		; RegList from FPU to Memory
	exg	a2,a3
	move.w	#%0000001101111111,d2
	clr.b	TryPC(a5)
	bra.s	2$
1$:	move.w	#%0001111101111111,d2
2$:	st	RefFlag(a5)
	move.l	a2,a0			; Control-RegList lesen (FPCR/FPSR/FPIAR)
	moveq	#0,d3
3$:	bsr	GetFPReg
	tst.w	d1
	beq	MissingReg
	or.b	d0,d3
	move.b	(a0)+,d0
	beq.s	4$
	and.b	#%11111100,d2		; bei mehreren Registern ist D/An illegal
	cmp.b	#'/',d0			; noch ein Register?
	beq.s	3$
	bra	SyntaxErr
4$:	ror.w	#6,d3
	or.w	d3,d4
	lea	oper1(a5),a2
	addq.l	#4,d6
	addq.w	#5,ListFileOff(a5)
	clr.w	opType1(a2)
	movem.l	d2/d4/d7,-(sp)
	moveq	#0,d7
	bsr	ProcessOperand
	movem.l	(sp)+,d2/d4/d7
	bne	Error
	btst	d1,d2
	beq	IllegalMode
	subq.b	#ea_Adirect,d1
	bne	WriteFPEA
	move.w	#$1c00,d0
	and.w	d4,d0
	cmp.w	#$0400,d0
	beq	WriteFPEA
	bra	IllegalMode		; An-Direct ist nur für FPIAR erlaubt


ReadFC:
; FC-Feld der PMMU-Befehle auslesen
; a0 = FC-Operand
; -> d0 = FC-Code
	cmp.b	#'#',(a0)
	bne.s	2$
	addq.l	#1,a0			; Immediate - #fc (0-15(68851) / 0-7(030))
	moveq	#0,d0
	bsr	GetValue
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	moveq	#15,d1
	tst.b	PMMUid(a5)
	bne.s	1$
	moveq	#7,d1
1$:	cmp.l	d1,d0			; Im gueltigen Bereich ?
	bhi	ImmedSize
	or.w	#$0010,d0
	bra.s	5$
2$:	bsr	GetRegister
	bmi.s	3$
	bclr	#3,d0			; DataRegister - Dn
	bne	NeedDReg
	addq.w	#8,d0
	bra.s	5$
3$:	move.l	a3,a0
	lea	creg_SFC(pc),a1
	bsr	UCaseStrCmp		; SFC ?
	bne.s	4$
	moveq	#0,d0
	bra.s	5$
4$:	move.l	a3,a0
	lea	creg_DFC(pc),a1
	bsr	UCaseStrCmp		; DFC ?
	bne	SyntaxErr
	moveq	#1,d0
5$:	rts


Pflsh:
	; Alle PFLUSH..-Variationen (68030/040/851)
	jmp	Pflsh2(pc)
	cmp.b	#4,Machine(a5)
	blo.s	PflshSb
Pflshx:
	addq.l	#2,d6
	rts
PflshS:
	jmp	Pflsh2s(pc)
PflshSb:
	addq.l	#2,d6
	cmp.w	#$2400,d4		; PFLUSHA - immer 4 Bytes
	beq.s	Pflshx
	bsr	SplitOperand
	tst.b	(a1)			; <ea>-Operand gegeben?
	beq.s	Pflshx
	move.w	#$c0,d3
	bra	SplittedInstrSize
Pflsh2:
	cmp.b	#4,Machine(a5)		; 68040-Varianten von PFLUSH/PFLUSHA ?
	blo.s	Pflsh3
	cmp.w	#$2400,d4
	bne.s	1$
	move.w	#$f518,d4
	bra	Pflsh040
1$:	move.w	#$f508,d4
	bra	Pflsh040
Pflsh2s:
	tst.b	PMMUid(a5)
	bne.s	Pflsh4
	bra	IllegalInstr		; PFLUSHS nur auf 68851
Pflsh3:
	cmp.b	#3,Machine(a5)		; 68030 oder 68851 aktiviert (fuer PFLUSH/A)
	bne.s	Pflsh2s
Pflsh4:
	addq.l	#4,d6
	st	RefFlag(a5)
	clr.w	oper1+opMode(a5)
	clr.w	oper1+opSize1(a5)
	clr.w	oper1+opFormat(a5)
	cmp.w	#$2400,d4
	beq	WritePMMUEA		; PFLUSHA
	or.w	#$1000,d4
	bsr	SplitOperand
	move.l	a1,d5
	move.l	a3,a0			; <FC> lesen
	bsr	ReadFC
	move.b	d0,d4
	move.l	a2,a0
	cmp.b	#'#',(a0)+		; #<MASK> lesen
	bne	IllegalMode
	moveq	#0,d0
	bsr	GetValue
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	moveq	#15,d1
	tst.b	PMMUid(a5)
	bne.s	1$
	moveq	#7,d1
1$:	and.w	d0,d1
	lsl.w	#5,d1
	or.w	d1,d4			; <MASK> einsetzen
	move.l	d5,a3
	tst.b	(a3)			; <ea> gegeben ?
	beq	WritePMMUEA
	or.w	#$0800,d4
	lea	oper1(a5),a2
	clr.b	TryPC(a5)
	addq.w	#5,ListFileOff(a5)
	clr.w	opType1(a2)
	movem.l	d4/d7,-(sp)
	moveq	#0,d7
	bsr	ProcessOperand
	movem.l	(sp)+,d4/d7
	bne	Error
	move.w	#%0000001101100100,d0
	btst	d1,d0
	bne	WritePMMUEA
	bra	IllegalMode


PflshN:					; PFLUSH/A/N/AN (68040)
	jmp	1$(pc)
	addq.l	#2,d6
	rts
1$:	cmp.b	#4,Machine(a5)
	blo	IllegalInstr
Pflsh040:
	addq.l	#2,d6
	btst	#4,d4
	bne.s	1$
	move.l	a3,a0
	cmp.b	#'(',(a0)+		; AdrReg. fuer PFLUSH/N (An) lesen
	bne	IllegalMode
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	cmp.b	#')',(a0)
	bne	IllegalMode
	or.b	d0,d4
1$:	move.w	d4,d0
	bra	AddWord


PflshR:					; PFLUSHR <ea>
	jmp	PflshR2(pc)
	addq.l	#2,d6
	moveq	#$60,d1
	bra	InstrSize
PflshR2:
	tst.b	PMMUid(a5)
	beq	IllegalInstr
	move.l	#%00011111011111000000000000000000,d0
	moveq	#$60,d1
	bsr	GetCpOper
	beq	WritePMMUEA
	rts


Pload:					; PLOADR/PLOADW <fc>,<ea>
	jmp	Pload2(pc)
	addq.l	#2,d6
	move.w	#$a0,d1
	bra	InstrSize
Pload2:
	tst.b	PMMUid(a5)		; 68851 oder 68030 ?
	bne.s	1$
	cmp.b	#3,Machine(a5)
	bne	IllegalInstr
1$:	move.w	#%0000001101100100,d0
	move.w	#$a0,d1
	bsr	GetCpOper
	bpl.s	2$
	rts
2$:	move.l	a3,a0
	bsr	ReadFC			; <FC> lesen
	move.b	d0,d4
	lea	oper2(a5),a2
	bra	WritePMMUa2


Pmov:					; PMOVE/PMOVEFD <ea>,PMMUcr / PMMUcr,<ea>
	jmp	Pmov2(pc)
	addq.l	#2,d6
	bsr	SplitOperand
	move.l	a3,a0
	bsr	GetPMMUReg
	beq.s	1$
	move.w	#$a0,d3
	bra	SplittedInstrSize
1$:	move.l	a2,a0
	bsr	GetPMMUReg
	moveq	#$60,d3
	bra	SplittedInstrSize
Pmov2:
	addq.l	#4,d6
	bsr	SplitOperand
	move.w	#%0001111101111111,d5
	move.l	a2,a0
	bsr.s	GetPMMUReg
	bne.s	1$
	move.l	a3,a0
	move.l	a2,a3
	bsr.s	GetPMMUReg
	beq	IllegalMode
	move.w	#%0000001101111111,d5
	clr.b	TryPC(a5)
	or.w	#$0200,d0		; R/W = 1
1$:	tst.w	d4
	beq.s	2$
	tst.b	PMMUid(a5)
	bne	IllegalInstr		; PMOVEFD nur auf 68030
	cmp.w	#$6000,d0
	bhi	IllegalMode		; PMOVEFD fuer MMUSR(PSR) nicht vorhanden
2$:	or.w	d0,d4
	tst.b	PMMUid(a5)		; MC68851 oder 68030 MMU
	bne.s	3$
	move.w	#%0000001101100100,d5	; 68030 unterstuetzt viel weniger Adr.arten
	clr.b	TryPC(a5)
3$:	lea	oper1(a5),a2
	clr.b	TryPC(a5)
	addq.w	#5,ListFileOff(a5)
	clr.w	opType1(a2)
	movem.l	d4-d5/d7,-(sp)
	moveq	#0,d7
	bsr	ProcessOperand
	movem.l	(sp)+,d4-d5/d7
	bne	Error
	btst	d1,d5
	bne	WritePMMUEA
	bra	IllegalMode


GetPMMUReg:
; PMMU Controlreg. bestimmen:
; TC,DRP,SRP,CRP,CAL,VAL,SCC,AC,BADx,BACx,PSR,PCSR
; a0 = Operand mit Controlreg.
; -> d0 = ExtensionWord (0=kein Controlreg.)
	movem.l	d2-d3/a2-a3,-(sp)
	move.l	a6,-(sp)
	lea	Buffer(a5),a2
	move.l	a2,a1
	lea	ucase_tab(a5),a3
	moveq	#0,d0
	moveq	#-1,d2			; Operand in Grossbuchstaben wandeln und
1$:	;  Länge bestimmen
	move.b	(a0)+,d0
	move.b	(a3,d0.w),(a1)+
	dbeq	d2,1$
	not.w	d2
	lea	pmmurt(pc),a6		; a6 PMMU-Register Binary Tree Root
	moveq	#0,d0
3$:	lea	(a6,d0.w),a3
	move.l	a2,a0			; String suchen
	lea	8(a3),a1
	move.w	d2,d0
4$:	cmpm.b	(a1)+,(a0)+
	dbne	d0,4$
	beq.s	6$
	bhi.s	5$
	move.w	(a3),d0			; gesuchter Name ist kleiner
	bne.s	3$
	moveq	#0,d0
	move.l	(sp)+,a6
	bra.s	9$
5$:	move.w	2(a3),d0		; gesuchter Name ist groesser
	bne.s	3$
	moveq	#0,d0
	move.l	(sp)+,a6
	bra.s	9$
6$:	; Gefunden!
	move.l	(sp)+,a6
	tst.b	Pass(a5)
	beq.s	7$
	moveq	#0,d1
	cmp.b	#3,Machine(a5)		; 68030?
	bne.s	61$
	moveq	#$40,d1
61$:	tst.b	PMMUid(a5)		; 68851?
	beq.s	62$
	or.b	#$80,d1
62$:	and.b	4(a3),d1		; wird dieser Befehl unterstuetzt?
	bne.s	7$
	bsr	IllegalInstr
7$:	move.b	5(a3),OpcodeSize(a5)
	move.w	6(a3),d0
9$:	movem.l	(sp)+,d2-d3/a2-a3
	rts


Ptst:					; PTESTR/PTESTW  <fc>,<ea>,#<level>[,An]
	jmp	Ptst2(pc)
	addq.l	#2,d6
	cmp.b	#4,Machine(a5)		; 68040-PTEST ?
	blo.s	1$
	rts
1$:	move.w	#$a0,d1
	bra	InstrSize
Ptst2:
	move.b	Machine(a5),d0
	subq.b	#3,d0			; 68030 ?
	beq.s	1$
	subq.b	#1,d0			; 68040 ?
	beq.s	Ptst040
	tst.b	PMMUid(a5)		; 68851 ?
	beq	IllegalInstr
1$:	move.l	a3,a0			; Auf vierten Operanden pruefen
	moveq	#2,d2
20$:	moveq	#',',d1
2$:	move.b	(a0)+,d0
	beq.s	4$
	cmp.b	#'(',d0			; Kommas zwischen Klammern ignorieren
	bne.s	23$
	moveq	#1,d1
21$:	move.b	(a0)+,d0
	beq.s	4$
	cmp.b	#'(',d0
	bne.s	22$
	addq.w	#1,d1
	bra.s	21$
22$:	cmp.b	#')',d0
	bne.s	21$
	subq.w	#1,d1
	bne.s	21$
	bra.s	20$
23$:	cmp.b	d1,d0
	bne.s	2$
	dbf	d2,2$
3$:	bsr	GetRegister
	bmi	IllegalMode
	btst	#3,d0
	beq	NeedAReg
	lsl.w	#5,d0
	or.w	d0,d4
4$:	move.w	#%0000001101100100,d0
	move.w	#$a0,d1
	bsr	GetCpOper		; <ea>
	bpl.s	5$
	rts
5$:	move.l	a1,a2
	move.l	a3,a0
	bsr	ReadFC			; <FC> lesen
	or.b	d0,d4
	move.l	a2,a0
	cmp.b	#'#',(a0)+		; #<level>
	bne	IllegalMode
	moveq	#0,d0
	bsr	GetValue
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	moveq	#7,d1
	cmp.l	d1,d0
	bhi	ImmedSize		; 0-7 als <level> erlaubt
	ror.w	#6,d0
	or.w	d0,d4
	lea	oper2(a5),a2
	bra	WritePMMUa2
Ptst040:				; PTESTR/PTESTW  (An)
	addq.l	#2,d6
	move.l	a3,a0
	cmp.b	#'(',(a0)+
	bne	IllegalMode
	bsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	cmp.b	#')',(a0)
	bne	IllegalMode
	and.w	#$0200,d4
	beq.s	1$
	or.w	#$0020,d0
1$:	or.w	#$f548,d0
	bra	AddWord


Pval:					; PVALID VAL,<ea> oder An,<ea>
	jmp	Pval2(pc)
	addq.l	#2,d6
	move.w	#$a0,d1
	bra	InstrSize
Pval2:
	tst.b	PMMUid(a5)		; nur auf 68851 implementiert
	beq	IllegalInstr
	move.l	#$dfdfdf00,d0
	and.l	(a3),d0
	cmp.l	#'VAL\0',d0		; mit VAL-Register vergleichen?
	beq.s	1$
	or.w	#$0400,d4
	st	RefFlag(a5)
	move.l	a3,a0
	bsr	GetRegister		; mit An vergleichen
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	or.b	d0,d4
1$:	move.w	#%0000001101100100,d0
	move.w	#$a0,d1
	bsr	GetCpOper
	bpl.s	2$
	rts
2$:	lea	oper2(a5),a2
	bra	WritePMMUa2
	ENDC


EquReg:					; label EQUR register
	nop
	nop
	move.l	a3,a0
	bsr	GetRegister
	bpl.s	1$			; Register ok ?
	moveq	#31,d0			; Not a register
	bsr	Error2
	bra.s	3$
1$:	tst.b	(a2)			; kein Label gegeben ?
	bne.s	2$
	bsr	MissingLabel
	bra.s	3$
2$:	move.l	a2,a0
	bsr	AddRegName
3$:	clr.b	(a2)			; Label loeschen
	bra	RemEQULine		; im naechsten Pass nicht mehr beachten


RegList:				; label REG reglist (getrennt durch / oder -)
	nop
	nop
	move.l	a3,a0
	bsr	GetRegList
	bpl.s	1$			; Registerliste war fehlerfrei ?
	moveq	#27,d0			; Bad register list
	bsr	Error2
	moveq	#0,d0
1$:	move.l	d0,d1
	moveq	#T_REG,d0
	tst.b	(a2)			; kein Label gegeben ?
	bne.s	2$
	bsr	MissingLabel
	bra.s	3$
2$:	move.l	a2,a0
	bsr	AddGorLSymbol
3$:	clr.b	(a2)			; Label loeschen
	bra	RemEQULine		; im naechsten Pass nicht mehr beachten


	cnop	0,4
SetSym:					; label SET.x <expression>
	nop
	nop
	move.l	a3,a0
	moveq	#os_LONG,d0
	IFND	SMALLASS
	move.b	OpcodeSize(a5),d4
	moveq	#os_FFP,d1
	cmp.b	d1,d4
	blo.s	3$
	move.b	d4,d0
	sub.b	d1,d4
	ext.w	d4
	add.w	d4,d4
	bra.s	4$
3$:	moveq	#-2,d4
	ENDC
4$:	bsr	GetValue
	tst.w	d2
	bmi	UndefSym		; Nur Konstanten erlaubt als value
	bne	AddrError
	tst.b	(a2)			; kein Label gegeben ?
	bne.s	1$
	bsr	MissingLabel
	bra.s	2$
1$:	move.l	d0,d1
	moveq	#T_SET,d0
	IFND	SMALLASS
	or.w	10$(pc,d4.w),d0
	ENDC
	move.l	a2,a0
	bsr	AddGorLSymbol
2$:	clr.b	(a2)
	rts

	IFND	SMALLASS
	dc.w	0
10$:	dc.w	T_FFP,T_SINGLE,T_DOUBLE,T_EXTENDED,T_PACKED
	ENDC


	IFND	FREEASS
IDir:					; INCDIR "path1"[,"path2",...]
	nop
	nop
	move.l	IncDirTable(a5),a0	; Include-Pfade in Tabelle aufnehmen
	move.l	a3,a1
	jsr	BuildStringTable
	beq.s	1$
	moveq	#8,d0			; IncDir path name expected
	bsr	Error2
1$:	clr.b	(a2)			; Label loeschen
	bra	Pass2Ignore		; Im nächsten Pass nicht mehr beachten


	cnop	0,4
FindIncFile:
; Alle gegebenen Include-Directories werden nach dem File durchsucht, falls es
; nicht beim ersten Versuch geoeffnet werden konnte. Wenn das File gefunden ist,
; wird seine Groesse bestimmt. (fuer INCLUDE und INCBIN)
; a3 = Operand
; -> a2 = FileName (ggf. mit Suchpfad)
; -> d0 = FileSize (-1 bei Error)
	bsr	IncludeFilename		; Filename in Buffer nach (a2) holen
	bmi.s	9$
	move.l	a2,a0
	jsr	FileSize		; angegebenes File versuchen zu öffnen
	bpl.s	9$
	move.l	a4,-(sp)
	move.l	IncDirTable(a5),d3	; alle IncludeDirs nach dem File absuchen
1$:	move.l	d3,a4
	move.w	#STRTABBLK/4-1,d4
	addq.l	#4,a4
2$:	move.l	(a4)+,d0
	beq.s	3$
	bsr.s	finc_TryOpen		; File versuchen im IncDir zu öffnen
	bpl.s	4$
	dbf	d4,2$
	move.l	d3,a0
	move.l	(a0),d3			; noch'n Chunk ?
	bne.s	1$
3$:	move.l	IncDirENV(a5),d0	; Letzte Chance: Die Environment-Variable
	beq.s	5$			;  PHXASSINC
	bsr.s	finc_TryOpen
	bpl.s	4$
5$:	moveq	#12,d0			; File doesn't exist
	bsr	Error2
	moveq	#-1,d0
4$:	move.l	a3,a2
	move.l	(sp)+,a4
9$:	rts

finc_TryOpen:
; d0 = IncDirPath
; a2 = FileName
; a3 = Buffer
; -> d0 = FileSize oder -1 (auch N-Flag) bei Fehler
	move.l	d0,a0
	move.l	a3,a1
1$:	move.b	(a0)+,(a1)+		; IncDir
	bne.s	1$
	subq.l	#1,a1
	move.b	-1(a1),d0
	cmp.b	#':',d0			; nur Volume angegeben?
	beq.s	2$
	moveq	#'/',d1
	cmp.b	d1,d0			; '/' ist schon vorhanden?
	beq.s	2$
	move.b	d1,(a1)+
2$:	move.l	a2,a0
3$:	move.b	(a0)+,(a1)+		; FileName
	bne.s	3$
	move.l	a3,a0
	jmp	FileSize		; File im IncludeDir versuchen zu öffnen


	cnop	0,4
IncludeFilename:
; Kopiert aus dem Operanden den Filename in den Arbeitsbuffer
; a3 = Operand
; -> a2 = FileName-Buffer
; -> N-Flag = Error (d0=-1)
	bsr.s	getFilename
	bne.s	1$
	moveq	#13,d0			; Missing include filename
	bsr	Error2
	moveq	#-1,d0
1$:	rts
	ENDC


	cnop	0,4
getFilename:
; a3 = Operand
; -> a2 = FileName-Buffer
; -> Z-Flag = FileName hat Länge Null
	lea	Buffer(a5),a2
	move.l	a3,a0
	move.l	a2,a1
	move.b	(a0)+,d0
	moveq	#$22,d1			; " ?
	cmp.b	d1,d0
	beq.s	1$
	moveq	#$27,d1			; ' ?
	cmp.b	d1,d0
	beq.s	1$
	moveq	#0,d1
	subq.l	#1,a0
1$:	move.b	(a0)+,d0		; Filename mit oder ohne Anführungsz. kopieren
	beq.s	2$
	cmp.b	d1,d0
	beq.s	2$
	move.b	d0,(a1)+
	bra.s	1$
2$:	clr.b	(a1)
	tst.b	(a2)
	rts


	IFND	FREEASS
	cnop	0,4
Incl:					; INCLUDE "filename"
	jmp	Incl2(pc)
	bsr	FindIncFile
	bpl.s	2$
	bsr	Pass2Ignore
1$:	rts
2$:	addq.l	#1,d0			; 1 zusaetzl. Zeichen fuer LF
	move.l	d0,d5			; FileSize merken
	moveq	#MEMF_ANY,d1
	jsr	AllocMem(a6)		; Speicher fuer Include-File
	move.l	d0,d4
	beq	OutofMemError2
	move.l	a2,a0
	jsr	AddString		; Include-Name merken
	move.l	d0,a2

	move.l	IncListPtr(a5),a3	; ** Eintrag in IncludeList **
3$:	move.l	incl_Link(a3),d0	; letzten Chunk suchen
	beq.s	4$
	move.l	d0,a3
	bra.s	3$
4$:	move.l	incl_FreeEntry(a3),d0
	bne.s	5$
	jsr	GetIncludeList		; Chunk voll - neuen besorgen
	move.l	d0,incl_Link(a3)
	move.l	d0,a3
	move.l	incl_FreeEntry(a3),d0
5$:	move.l	d0,a0
	move.l	d4,(a0)+		; TextPtr und Size eintragen
	move.l	d5,(a0)+
	move.l	a2,(a0)+		; Include-Name (ggf. mit Pfad)
	lea	incl_HEAD+INCLISTBLK(a3),a1
	cmp.l	a1,a0
	blo.s	6$
	sub.l	a0,a0			; naechstes mal neuen Chunk besorgen
6$:	move.l	a0,incl_FreeEntry(a3)

	move.l	a6,a3
	move.l	DosBase(a5),a6		; ** Include-file lesen **
	move.l	a2,d1
	move.l	#MODE_OLDFILE,d2
	jsr	Open(a6)
	move.l	d0,-(sp)
	move.l	d0,d1
	move.l	d4,d2
	move.l	d5,d3
	jsr	Read(a6)
	move.l	(sp)+,d1
	move.l	d0,-(sp)
	jsr	Close(a6)
	move.l	a3,a6
	tst.l	(sp)+
	bpl.s	7$
	moveq	#14,d0			; Read error
	bra	FatalError2
7$:	move.l	d4,a0
	move.b	#10,-1(a0,d5.l)		; LF als letztes Zeichen einfuegen

	addq.w	#1,IncludeCnt(a5)
	move.l	IncNest(a5),a3		; ** Eintrag in IncNestList **
8$:	move.w	nl_Nest(a3),d0
	bpl.s	9$
	move.l	(a3),a3			; Chunk war voll, naechsten nehmen
	bra.s	8$
9$:	move.w	d0,d3
	move.l	nl_FreeEntry(a3),a0
	move.l	a4,(a0)+		; SourcePtr, Len und Line retten
	move.l	d7,(a0)+
	IFND	GIGALINES
	move.w	Line(a5),(a0)+
	ELSE
	move.l	Line(a5),(a0)+
	ENDC
	move.b	AssMode(a5),(a0)+
	move.b	ReptDepth(a5),(a0)+
	clr.b	ReptDepth(a5)
	move.l	AssModeName(a5),(a0)+
	move.l	a0,nl_FreeEntry(a3)
	addq.w	#1,d3			; Nest erhoehen
	cmp.w	#INCNSTBLK/nlSIZE,d3
	bls.s	10$			; Chunk voll ?
	move.l	(a3),d0
	bne.s	11$
	jsr	GetIncNestList		; Speicher fuer neuen IncNest-Chunk besorgen
	move.l	d0,(a3)			; linken mit Vorgaenger
11$:	move.w	#-1,nl_Nest(a3)		; Vorgaender als Voll kennzeichnen
	move.l	d0,a3
	moveq	#0,d3
10$:	move.w	d3,nl_Nest(a3)		; neuen Nest-Wert speichern
	move.l	d4,a4			; SourcePtr auf Include-file setzen
	move.l	d5,d7			; Include Laenge
	move.b	#am_INC,AssMode(a5)
	move.l	a2,AssModeName(a5)
	bra	Incl_x

	cnop	0,4
Incl2:
	addq.w	#1,IncludeCnt(a5)
	move.l	IncNest(a5),a3		; ** Eintrag in IncNestList **
1$:	move.w	nl_Nest(a3),d0
	bpl.s	2$
	move.l	(a3),a3			; Chunk war voll, naechsten nehmen
	bra.s	1$
2$:	move.w	d0,d3
	move.l	nl_FreeEntry(a3),a0
	move.l	a4,(a0)+		; SourcePtr, Len und Line retten
	move.l	d7,(a0)+
	IFND	GIGALINES
	move.w	Line(a5),(a0)+
	ELSE
	move.l	Line(a5),(a0)+
	ENDC
	move.b	AssMode(a5),(a0)+
	move.b	ReptDepth(a5),(a0)+
	clr.b	ReptDepth(a5)
	move.l	AssModeName(a5),(a0)+
	move.l	a0,nl_FreeEntry(a3)
	addq.w	#1,d3			; Nest erhoehen
	cmp.w	#INCNSTBLK/nlSIZE,d3
	bls.s	3$			; Chunk voll ?
	move.l	(a3),d0
	bne.s	6$
	jsr	GetIncNestList		; Speicher fuer neuen IncNest-Chunk besorgen
	move.l	d0,(a3)			; linken mit Vorgaenger
6$:	move.w	#-1,nl_Nest(a3)		; Vorgaender als Voll kennzeichnen
	move.l	d0,a3
	moveq	#0,d3
3$:	move.w	d3,nl_Nest(a3)		; neuen Nest-Wert speichern

	move.b	#am_INC,AssMode(a5)
	move.l	IncListPtr(a5),a0
	move.l	#INCLISTBLK,d2
	moveq	#0,d0
	move.w	IncludeCnt(a5),d0
	lsl.l	#2,d0			; *12
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
4$:	cmp.l	d2,d0			; IncludeList-Chunk suchen
	blo.s	5$
	sub.l	d2,d0
	move.l	(a0),a0
	bra.s	4$
5$:	add.l	d0,a0
	move.l	incl_Name(a0),AssModeName(a5)
	move.l	incl_Text(a0),a4	; neuer Sourcepointer
	move.l	incl_Size(a0),d7	;  und SourceLen
Incl_x:
	IFND	GIGALINES
	clr.w	Line(a5)
	ELSE
	clr.l	Line(a5)
	ENDC
	btst	#sw2_VERBOSE,Switches2(a5)
	bne.s	1$
	rts
1$:	lea	include_dir(pc),a0
	bra	VerboseInfo


	cnop	0,4
IncBin:					; INCBIN "filename"
	jmp	IncBin2(pc)
	bsr	FindIncFile
	bmi	Pass2Ignore
	add.l	d0,d6			; Platz fuer INCBIN-file schaffen
IncBin_exit:
	rts

	cnop	0,4
IncBin2:
	bsr	FindIncFile
	bmi.s	IncBin_exit
	move.l	d0,d5
	move.l	a6,a3
	move.l	DosBase(a5),a6
	move.l	a2,d1			; incbin-file oeffnen
	move.l	#MODE_OLDFILE,d2
	jsr	Open(a6)
	move.l	d0,d4
	move.l	CurrentSec(a5),a2
	add.l	d5,sec_Size(a2)		; Section-Size und Prog.Counter setzen
	add.l	d5,d6
2$:	move.l	sec_FreeData(a2),d1
	beq.s	8$			; BSS oder OFFSET?
	move.l	d1,d0
	sub.l	d5,d0
	bpl.s	4$
3$:	sub.l	d1,d5
	move.l	d1,d3
	move.l	d4,d1
	move.l	sec_HunkDataPt(a2),d2
	jsr	Read(a6)		; Daten in Section lesen
	tst.l	d0
	bmi.s	7$
	move.l	a2,a1
	exg	a3,a6
	bsr	AddHunkData		; und noch einen Chunk anhaengen
	exg	a3,a6
	move.l	a0,sec_HunkDataPt(a2)
	bra.s	2$
4$:	move.l	d0,sec_FreeData(a2)
	bne.s	5$
	move.l	sec_HunkDataPt(a2),d2
	move.l	a2,a1
	exg	a3,a6
	bsr	AddHunkData		; Chunk anhaengen
	exg	a3,a6
	move.l	a0,sec_HunkDataPt(a2)
	bra.s	6$
5$:	move.l	sec_HunkDataPt(a2),d2
	move.l	d2,d0
	add.l	d5,d0
	move.l	d0,sec_HunkDataPt(a2)
6$:	move.l	d4,d1
	move.l	d5,d3
	jsr	Read(a6)		; letzten Chunk teilweise fuellen
	tst.l	d0
	bmi.s	7$
8$:	move.l	d4,d1
	jsr	Close(a6)
	move.l	a3,a6
	rts
7$:	move.l	d4,d1
	jsr	Close(a6)
	move.l	a3,a6
	moveq	#14,d0			; Read error
	bra	FatalError2


	cnop	0,4
MacCmd:					; mname MACRO ...text... ENDM
	rts
	nop
	tst.b	AssMode(a5)
	bpl.s	1$			; am_MACRO?
	moveq	#73,d0			; Can't define macro within a macro
	bsr	Error2
	bra	FindENDM
1$:	tst.b	(a2)
	beq.s	2$
	move.l	a2,a0			; Macro-Name darf entweder vor, oder hinter
	bra.s	4$			;  der MACRO-Directive stehen
2$:	move.b	(a3),d0
	bne.s	3$
	moveq	#71,d0			; Missing macro name
	bsr	Error2
	bra	FindENDM
3$:
	IFND	DOTNOTLOCAL
	cmp.b	#'.',d0			; .mname (local Macro?)
	beq.s	7$
	ENDIF
	move.l	a3,a0
	bsr	StrLen
	cmp.b	#'$',-1(a0,d0.w)	; mname$ (local Macro ?)
	bne.s	4$
7$:	st	Local(a5)
4$:	move.l	a0,a3
	lea	ucase_tab(a5),a1	; Macroname in Großbuchstaben wandeln
	moveq	#0,d0
	moveq	#-1,d2
5$:	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	dbeq	d2,5$
	not.w	d2			; d2 = Länge des Namens
	move.l	a3,a0			; Makroname mit allen Direktiven vergleichen
	HASHC	a0,d0,d1,d3		; Hashcode für Makronamen berechnen > d0
	and.w	MnemHashMask(a5),d0
	lsl.l	#2,d0
	move.l	MnemoHashList(a5),a0	; Hash Table
	move.l	(a0,d0.l),d0		; mind. ein Mnemonic in der Hash Chain?
	beq.s	12$
8$:	move.l	d0,a2			; Hash Chain durchgehen...
	move.l	mnn_Name(a2),a0		; Mnemonic Name
	move.l	a3,a1			;  mit Makronamen vergleichen
	move.w	d2,d0
9$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,9$
	beq.s	11$
	move.l	mnn_Next(a2),d0		; nächster Mnemonic in der Hash Chain?
	bne.s	8$
	bra.s	12$
11$:	moveq	#101,d0			; Already a directive name
	bsr	Error2
	bra.s	FindENDM
12$:	move.l	a3,a0			; Macro-Definition speichern
	moveq	#T_MACRO,d0
	move.l	a4,d1			; Beginn der ersten Macro-Zeile
	bsr	AddGorLSymbol

FindENDM:				; ENDM suchen, Zeilen ins Listing File (Pass 1)
	move.l	a6,-(sp)
	bsr	Pass2Ignore		; Alles bis inklusive ENDM in Pass 2 ignorieren
1$:
	IFND	GIGALINES
	addq.w	#1,Line(a5)
	addq.w	#1,AbsLine(a5)
	ELSE
	addq.l	#1,Line(a5)
	addq.l	#1,AbsLine(a5)
	ENDC
	bsr	LineParts
	tst.b	ListEn(a5)
	beq.s	2$
	bsr	ListSourceLine		; Sourcetext-Zeile in Listing aufnehmen
2$:	st	sut_LabelLen(a6)	; in Pass 2 ignorieren
	clr.w	sut_OperOffset(a6)
	and.l	#$dfdfdfdf,(a3)
	cmp.l	#"ENDM",(a3)+		; ENDM gefunden?
	bne.s	3$
	tst.b	(a3)
	beq.s	4$
3$:	tst.l	d7
	bne.s	1$			; Sourcetext zuende und immer noch kein ENDM ?
	moveq	#72,d0			; Missing ENDM
	bra	FatalError2
4$:	clr.b	LabelBuffer(a5)
	move.l	a6,a0
	move.l	(sp)+,a6
	rts


	cnop	0,4
EndMac:					; ENDM
	nop
	nop
	clr.b	(a2)
	tst.b	AssMode(a5)		; Bef. sich der Ass. überhaupt im MacroMode ?
	bpl.s	1$			; am_MACRO?
	tst.b	d4
	beq.s	2$			; MEXIT ?
	tst.b	Pass(a5)
	bne.s	2$			; in Pass 2 ist MEXIT identisch mit ENDM
	move.l	CurrentSUTPos(a5),a0
	move.l	sut_OpcodePtr(a0),d5
	bsr	FindENDM		; alles bis ENDM für Pass 2 unsichtbar machen
	move.l	d5,sut_OpcodePtr(a0)
2$:	move.l	symNARG(a5),a0		; außerhalb des Macros hat NARG den Wert 0
	clr.l	sym_Value(a0)
	IFND	GIGALINES
	move.w	AbsLine(a5),sym_DeclLine(a0)
	ELSE
	move.l	AbsLine(a5),sym_DeclLine(a0)
	ENDC
	subq.w	#1,MacroCnt(a5)		; Verschachtelungszähler
	move.w	MacroCnt(a5),d0
	move.l	MacParaPtr(a5),a0	; erster MacParameter-Chunk
	move.l	#MACPARBLK,d1
	mulu	#MACDEPTHSIZE,d0
3$:	cmp.l	d1,d0			; richtigen Chunk erreicht ?
	blo.s	4$
	sub.l	d1,d0
	move.l	(a0),a0
	bra.s	3$
4$:	; Übergeordneten \@-Label wieder setzen
	lea	mpar_HEAD(a0,d0.l),a0
	move.l	symNARG(a5),a1
	move.l	(a0)+,sym_Value(a1)	; mpar_LastNARG
	move.l	symCARG(a5),a1
	move.l	(a0)+,sym_Value(a1)	; mpar_LastCARG
	move.l	(a0),ActMacLabel(a5)	; mpar_LastLabel
	moveq	#0,d7			; Macro-Source ist beendet !
	IFND	GIGALINES
	subq.w	#1,AbsLine(a5)		; ENDM-Zeile nicht beachten
	ELSE
	subq.l	#1,AbsLine(a5)
	ENDC
	neg.b	ListEn(a5)
	rts
1$:	moveq	#74,d0			; Unexpected ENDM
	bra	Error2
	ENDC


mc680x0:				; MC680x0 Prozessor-Typ setzen
	nop
	nop
	clr.b	(a2)
	moveq	#0,d0
	move.w	d4,d0
	bra.s	setmachine


MachType:				; MACHINE Setzt Prozessor-Typ
	nop
	nop
	clr.b	(a2)
	move.w	(a3),d0
	and.w	#$dfdf,d0
	cmp.w	#'MC',d0		; mc680x0 statt nur 680x0 - auch moeglich
	bne.s	1$
	addq.l	#2,a3
1$:	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Nummer holen (68000-68040)
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
	sub.l	#68000,d0
setmachine:
	move.l	d0,d4
	IFD	SMALLASS
	bne.s	3$
	ELSE
	bmi.s	3$
	bne.s	5$
	clr.b	PMMUid(a5)		; 68000 setzt PMMUid zurück
	lea	MMUSymbol(pc),a0	; __MMU SET 0
	moveq	#T_SET,d0
	moveq	#0,d1
	bsr	AddSymbol
5$:	move.l	d4,d0
	divu	#10,d0
	move.b	d0,Machine(a5)		; Neuen Processor setzen
	subq.b	#4,d0			; 68040?
	blo.s	1$
	beq.s	4$
	subq.b	#2,d0			; 68060? - 68050 gibt's nicht!
	bne.s	2$
4$:	move.b	#1,FPUid(a5)		; FPU ist im 68040 und 68060 enthalten!
	lea	FPUSymbol(pc),a0	; __FPU SET 1
	moveq	#T_SET,d0
	moveq	#1,d1
	bsr	AddSymbol
	ENDC
1$:	move.l	#68000,d1
	add.l	d4,d1
	lea	CPUSymbol(pc),a0	; __CPU SET 68000..68060
	moveq	#T_SET,d0
	bra	AddSymbol
2$:	cmp.w	#88,d0			; 6888x?
	beq.s	4$
	cmp.w	#85,d0			; 68851?
	beq	SetPMMU
3$:	moveq	#11,d0			; MACHINE not supported
	bra	Error2

CPUSymbol:
	dc.b	"__CPU",0
FPUSymbol:
	dc.b	"__FPU",0
MMUSymbol:
	dc.b	"__MMU",0
	even


	IFND	SMALLASS
SetFPU:					; FPU [id]  aktiviert FloatingPoint Unit
	nop
	nop
	moveq	#1,d0			; Standard ID fuer FPU = 1
	tst.b	(a3)			; ID angegeben ?
	beq.s	1$
	move.l	a3,a0
	moveq	#0,d0
	bsr	GetValue		; ID holen (0-7)
	tst.w	d2
	bmi	UndefSym
	bne	AddrError
; tst.l	 d0
; beq	 OutofRange
	moveq	#7,d1
	cmp.l	d1,d0
	bhi	OutofRange
1$:	move.b	d0,FPUid(a5)		; FPU anmelden
	moveq	#0,d1
	move.b	d0,d1
	lea	FPUSymbol(pc),a0	; __FPU SET ID
	moveq	#T_SET,d0
	bsr	AddSymbol
	clr.b	(a2)
	rts


SetPMMU:				; PMMU  aktiviert die PagedMemoryManager Unit
	nop
	nop
	st	PMMUid(a5)		; ID ist egal - ist sowieso immer 0
	lea	MMUSymbol(pc),a0	; __MMU SET 1
	moveq	#T_SET,d0
	moveq	#1,d1
	bsr	AddSymbol
	clr.b	(a2)
	rts
	ENDC


AssEnd:					; END	    oder  FAIL
	nop
	nop
	move.w	d4,d0
	beq.s	1$
	tst.b	d5			; FAIL nur in Pass2 ausfuehren
	beq.s	2$
	bra	FatalError2
1$:	; END
	addq.l	#4,sp			; Rueckkehr-Adr. vom Stack nehmen. Jetzt liegt
2$:	;  die Assemble-aufrufende Stelle oben.
	rts


	IFND	FREEASS
StrOut:					; ECHO ["string"]  gibt einen String aus
	jmp	1$(pc)
	clr.b	(a2)
9$:	rts
1$:	clr.b	(a2)
	move.l	a3,a0
	tst.b	(a0)
	beq.s	4$			; kein String
	lea	Buffer(a5),a1
	move.w	#BUFSIZE-3,d0		; Platz fuer LF,CR freihalten
	bsr	ReadArgument
	lea	-1(a3,d0.w),a0
	cmp.b	#$22,(a0)		; String durch " oder ' eingegrenzt ?
	beq.s	2$
	cmp.b	#$27,(a0)
	bne.s	3$
2$:	addq.l	#1,a3
	bra.s	4$
3$:	addq.l	#1,a0
4$:	move.b	#10,(a0)+
	move.b	#13,(a0)+
	clr.b	(a0)
	move.l	a3,a0
	jmp	printf


ListEna:				; LIST  folgende Zeilen werden ausgegeben
	nop
	nop
	clr.b	(a2)
	tst.l	AssListName(a5)
	sne	ListEn(a5)
	rts


ListDis:				; NOLIST  folgende Zeilen nicht ausgeben
	nop
	nop
	clr.b	(a2)
	clr.b	ListEn(a5)
	rts
	ENDC


OptCode:				; OPTC <exp>  setzt Opt.Flags neu
	nop
	nop
	btst	#sw_OPTIMIZE,Switches(a5)
	bne.s	copt2
	tst.b	(a3)
	beq	MissingArg
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; opt flags lesen
	tst.w	d2
	beq.s	1$
	bmi	UndefSym
	bra	AddrError
1$:	move.b	d0,OptFlag(a5)
	btst	#8,d0
	sne	TotalBccOpt(a5)
	btst	#9,d0
	sne	Movem2MoveOpt(a5)
	bra.s	copt1


ChgOpt:					; OPT ! oder * oder [n][r][q][b][l][p][s][m]
	nop				; Seit V4.05 auch DevPac: C,D,L+/-,On
	nop				; Pass1 keine Optimierungsaenderung beachten
	btst	#sw_OPTIMIZE,Switches(a5)
	bne.s	copt2
	move.l	a3,a1
	jsr	GetOptFlags		; OptFlags fuer den Rest der aktuellen
copt1:	jsr	setOPTC
	move.l	CurrentSec(a5),d0	;  Section neu setzen
	beq.s	copt2
	move.l	d0,a0
	move.b	OptFlag(a5),sec_Flags(a0)
copt2:	clr.b	(a2)
	rts


UnitTtl:				; IDNT/TTL "Name" setzen Namen der Obj.-Unit
	nop
	nop
	bsr	absmodecheck
	bne.s	1$
	clr.l	UnitName(a5)
	tst.b	(a2)			; Motorola-Syntax - Unit-Name im Label?
	beq.s	2$
	move.l	a2,a3
2$:	move.l	a2,d4
	bsr	getFilename		; Unit-Namen lesen -> a2
	beq.s	3$			; "" - kein Name
	move.l	a2,a0
	jsr	AddString
	move.l	d0,UnitName(a5)
3$:	move.l	d4,a2
1$:	clr.b	(a2)			; Label löschen
	bra	Pass2Ignore		; TTL im nächsten Pass nicht mehr beachten


CSeg:
; bewirkt dasselbe wie: SECTION CODE,code
	IFND	FREEASS
	jmp	1$(pc)
	bsr	absmodecheck
	beq.s	1$
	rts
1$:	clr.b	AbsCode(a5)
	ELSE
	nop
	nop
	ENDC
	lea	code_dir(pc),a0
	move.w	d4,d0
	swap	d0
	move.w	#HUNK_CODE,d0
	bra	MakeSection


DSeg:
; bewirkt dasselbe wie: SECTION DATA,data
	IFND	FREEASS
	jmp	1$(pc)
	bsr	absmodecheck
	beq.s	1$
	rts
1$:	clr.b	AbsCode(a5)
	ELSE
	nop
	nop
	ENDC
	lea	data_dir(pc),a0
	move.w	d4,d0
	swap	d0
	move.w	#HUNK_DATA,d0
	bra	MakeSection


BSeg:
; bewirkt dasselbe wie: SECTION BSS,bss
	jmp	1$(pc)
	bsr	absmodecheck
	beq.s	1$
	rts
1$:	tst.b	(a3)
	beq.s	BSS_Section
	moveq	#-1,d2			; BSS Symbol,Size    Symbol in BSS definieren
	bra	DefineBSS		; wie GLOBAL, nur ohne  XDEF Symbol
BSS_Section:
	IFND	FREEASS
	clr.b	AbsCode(a5)		; Normale BSS-Section starten
	ENDC
	lea	bss_dir(pc),a0
	move.w	d4,d0
	swap	d0
	move.w	#HUNK_BSS,d0
	bra	MakeSection


	IFND	FREEASS
Offs:					; OFFSET [<offset>]
; Section zum Definieren von Struktur-Offsets
	nop
	nop
	lea	Sect_NoName(pc),a0
	move.l	#HUNK_OFFSET,d0
	bsr	MakeSection		; Offset-Section starten
	moveq	#0,d6			; Beginnt immer bei Adresse 0
	tst.b	(a3)
	beq.s	2$			; Start-Offset angegeben?
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; offset-Expression lesen
	tst.w	d2
	beq.s	1$
	bmi	UndefSym
	bra	AddrError		; Programmadr. (oder Dist.) sind nicht erlaubt
1$:	move.l	d0,d6
2$:	rts
	ENDC


Sect:					; SECTION Name[,code/data/
	jmp	7$(pc)			; bss[,chip/fast]] oder [,MemFlags]
	bsr	absmodecheck
	beq.s	7$
	rts
7$:	move.l	a3,d5			; Zeiger auf Name retten
	lea	Buffer(a5),a2		; Arbeitsbuffer
	move.l	#HUNK_CODE,d2		; default-Type
	moveq	#',',d1
1$:	; Section-Type suchen
	move.b	(a3)+,d0
	beq	Sect_Name
	cmp.b	d1,d0
	bne.s	1$
	move.l	a3,a0
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; Section-Type in Buffer holen
	beq	MissingArg
	add.w	d0,a3
	move.l	a2,a0
	lea	code_dir(pc),a1		; CODE ?
	bsr	UCaseStrCmp
	beq	8$
	move.l	a2,a0
	lea	data_dir(pc),a1		; DATA ?
	bsr	UCaseStrCmp
	bne.s	3$
	move.l	#HUNK_DATA,d2
	bra	8$
3$:	move.l	a2,a0
	lea	bss_dir(pc),a1		; BSS ?
	bsr	UCaseStrCmp
	bne.s	4$
	move.l	#HUNK_BSS,d2
	bra	8$
4$:	move.l	a2,a0
	lea	codec_dir(pc),a1	; CODE_C ?
	bsr	UCaseStrCmp
	bne.s	5$
	move.l	#HUNK_CODE|HUNK_CHIP,d2
	bra	Sect_Name
5$:	move.l	a2,a0
	lea	datac_dir(pc),a1	; DATA_C ?
	bsr	UCaseStrCmp
	bne.s	6$
	move.l	#HUNK_DATA|HUNK_CHIP,d2
	bra	Sect_Name
6$:	move.l	a2,a0
	lea	bssc_dir(pc),a1		; BSS_C ?
	bsr	UCaseStrCmp
	bne.s	14$
	move.l	#HUNK_BSS|HUNK_CHIP,d2
	bra	Sect_Name
14$:	move.l	a2,a0
	lea	codef_dir(pc),a1	; CODE_F ?
	bsr	UCaseStrCmp
	bne.s	15$
	move.l	#HUNK_CODE|HUNK_FAST,d2
	bra	Sect_Name
15$:	move.l	a2,a0
	lea	dataf_dir(pc),a1	; DATA_F ?
	bsr	UCaseStrCmp
	bne.s	16$
	move.l	#HUNK_DATA|HUNK_FAST,d2
	bra	Sect_Name
16$:	move.l	a2,a0
	lea	bssf_dir(pc),a1		; BSS_F ?
	bsr	UCaseStrCmp
	bne.s	17$
	move.l	#HUNK_BSS|HUNK_FAST,d2
	bra	Sect_Name
17$:	move.l	a2,a0
	lea	codep_dir(pc),a1	; CODE_P ?
	bsr	UCaseStrCmp
	bne.s	18$
	move.l	#HUNK_CODE,d2
	bra	Sect_Name
18$:	move.l	a2,a0
	lea	datap_dir(pc),a1	; DATA_P ?
	bsr	UCaseStrCmp
	bne.s	19$
	move.l	#HUNK_DATA,d2
	bra	Sect_Name
19$:	move.l	a2,a0
	lea	bssp_dir(pc),a1		; BSS_P ?
	bsr	UCaseStrCmp
	bne	SyntaxErr
	move.l	#HUNK_BSS,d2
	bra	Sect_Name
8$:	move.b	(a3)+,d0
	beq.s	Sect_Name		; kein CHIP/DATA Argument vorhanden ?
	cmp.b	#',',d0
	bne	SyntaxErr
	move.l	a3,a0
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; Memory-Flag in Buffer holen
	beq	MissingArg
	move.l	a2,a0
	lea	SectChip(pc),a1		; CHIP ?
	bsr	UCaseStrCmp
	bne.s	9$
	or.l	#HUNK_CHIP,d2
	bra.s	Sect_Name
9$:	move.l	a2,a0
	lea	SectFast(pc),a1		; FAST ?
	bsr	UCaseStrCmp
	bne.s	10$
	or.l	#HUNK_FAST,d2
	bra.s	Sect_Name
10$:	move.l	d2,-(sp)
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; MemFlag als Zahlenwert lesen
	tst.w	d2
	beq.s	11$
	addq.l	#4,sp
	bmi	UndefSym
	bra	AddrError
11$:	move.l	(sp)+,d2
	or.l	d0,d2
Sect_Name:
	move.l	d5,a0
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; Section-Name lesen
	beq.s	1$			; kein Name
	move.l	d5,a0
	add.w	d0,a0
	clr.b	(a0)
	subq.l	#1,a0
	cmp.b	#$22,(a0)		; String durch " oder ' eingegrenzt ?
	beq.s	2$
	cmp.b	#$27,(a0)
	bne.s	3$
2$:	clr.b	(a0)
	addq.l	#1,d5
3$:	move.l	d5,a0
	bra.s	4$
1$:	lea	Sect_NoName(pc),a0
4$:
	IFND	FREEASS
	clr.b	AbsCode(a5)
	ENDC
	move.l	d2,d0
	bra	MakeSection		; Section neu erstellen, oder anwaehlen

SectChip:
	dc.b	"CHIP",0
SectFast:
	dc.b	"FAST"
Sect_NoName:
	dc.b	0
	even


CrossRefs:				; Behandelt XREF/NREF/XDEF/PUBLIC sym[,sym..]
	jmp	5$(pc)
	bsr	absmodecheck
	bne.s	9$
5$:	clr.b	(a2)
	tst.b	(a3)			; kein Symbol angegeben ?
	beq.s	9$
	lea	Buffer(a5),a0
	move.l	a0,d5
1$:	move.l	a3,a0
	move.l	d5,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument
	bne.s	4$
	bsr	MissingArg
	bra.s	9$
4$:	add.w	d0,a3
	move.b	-1(a3),d0
	sub.b	#$22,d0			; String oder Local-Symbol ?
	beq.s	2$
	subq.b	#2,d0
	beq.s	2$
	subq.b	#3,d0
	bne.s	3$
2$:	moveq	#17,d0			; Symbol can't be defined as external
	bsr	Error2
	bra.s	9$
3$:	move.l	d5,a0
	IFND	DOTNOTLOCAL
	cmp.b	#'.',(a0)		; Local Symbol ?
	beq.s	2$
	ENDIF
	move.w	d4,d0			; Type (XREF,NREF,XDEF oder PUBLIC)
	moveq	#0,d1			; Value auf 0 setzen
	bsr	AddSymbol
	move.b	(a3)+,d0
	beq.s	9$
	cmp.b	#',',d0			; folgt noch ein Symbol ?
	beq.s	1$
	bsr	SyntaxErr
9$:	bra	RemEQULine		; im naechsten Pass nicht mehr beachten


Glob:					; GLOBAL SymbolName,Size
; Diese Directive belegt 'Size'-Speicher im BSS-Segment und deklariert das
; angegebene Symbol als XDEF. Mit Standard-Linkern hat diese Anweisung aller-
; dings nicht mehr die Funktion die sie beim Aztec-Linker besitzt.
	jmp	1$(pc)
	bsr	absmodecheck
	bne	RemEQULine
	clr.b	(a2)
	tst.b	(a3)			; Symbolname gegeben ?
	bne.s	1$
	rts
1$:	moveq	#0,d2
DefineBSS:				; d2 = 0 : Symbol wird XDEF'ed
	move.l	CurrentSec(a5),d3	; aktuelle Section merken
	moveq	#0,d4
	bsr	BSS_Section		; Symbol wird in BSS aufgenommen
	lea	Buffer(a5),a2
	move.l	a2,a1
	move.l	a3,a0
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; Symbolname lesen
	bne.s	2$
	bsr	MissingArg
	bra.s	7$
2$:	add.w	d0,a3
	tst.b	d5			; Pass2 ?
	bne.s	1$
	move.b	-1(a3),d0
	cmp.b	#$22,d0			; String ?
	beq.s	3$
	cmp.b	#$27,d0
	bne.s	4$
3$:	moveq	#17,d0			; Symbol can't be defined as external
	bsr	Error2
	bra.s	7$
4$:	tst.b	d2
	bne.s	41$
	move.l	a2,a0
	move.w	#T_XDEF,d0
	moveq	#0,d1
	bsr	AddSymbol
41$:	move.l	a2,a0
	moveq	#T_ABS,d0
	move.l	d6,d1			; Value = BSS PC
	bsr	AddSymbol		; ins BSS-Segment aufnehmen
1$:	cmp.b	#',',(a3)+
	beq.s	5$
	bsr	SyntaxErr
	bra.s	7$
5$:	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; zu belegende Bytes fuer das Symbol
	tst.w	d2
	bne	AddrError
	move.l	d6,LineAddr(a5)
	addq.l	#1,d0			; Anzahl begradigen
	moveq	#-2,d1
	and.l	d1,d0
	beq.s	7$			; 0 bytes ?
	bclr	#0,d0
	add.l	d0,d6
	tst.b	d5			; Pass 2 ?
	beq.s	7$
	move.l	d0,d2
51$:	moveq	#0,d0
	bsr	AddWord
	subq.l	#2,d2
	bne.s	51$
7$:	tst.l	d3
	bne.s	8$			; war noch keine Section definiert ?
	bra	CSeg
8$:	move.l	d3,a1
	move.l	(a1)+,a0		; SecName
	move.l	(a1),d0			; SecType
	bra	MakeSection		; alte Section reaktivieren


	cnop	0,4
EvenAdr:				; macht dasseble wie:	    CNOP 0,2
	jmp	1$(pc)
	moveq	#0,d3
	moveq	#2,d2
	bsr.s	MakeCNop
	add.l	d0,d6
	rts
1$:	moveq	#0,d3
	moveq	#2,d2
	bsr.s	MakeCNop
	add.l	d0,d6
	bra	AddCount


	cnop	0,4
MakeCNop:
; CurrentAdr durch align teilbar aufrunden und danach den offset addieren
; d2 = align(max.32768), d3 = offset
; -> d0 = Gesamtanzahl Fuellbytes
	tst.l	d6
	beq.s	3$
	moveq	#0,d0
	move.w	d6,d0
	moveq	#0,d1
	move.w	d2,d1
	beq.s	2$
	divu	d2,d0
	swap	d0
	tst.w	d0
	bne.s	1$			; Adr ist schon aligned ?
	moveq	#0,d1
1$:	sub.w	d0,d1
2$:	move.l	d1,d0			; nötige Bytes für align
	add.l	d3,d0			; +offset
	rts
3$:	moveq	#0,d2			; CNOP am Sectionsanfang nicht beachten!
	move.l	d3,d0
	rts

getcnopvalues:
; -> d2 = align, d3 = offset
	tst.b	(a3)
	bne.s	1$
	addq.l	#4,sp
	bra	MissingArg
1$:	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; offset lesen
	tst.w	d2
	beq.s	3$
2$:	addq.l	#4,sp
	bmi	UndefSym
	bne	AddrError
3$:	move.l	d0,d3
	cmp.b	#',',(a0)+
	beq.s	4$
	addq.l	#4,sp
	bra	SyntaxErr
4$:	moveq	#os_LONG,d0
	bsr	GetValue
	tst.w	d2
	bne.s	2$
	move.l	d0,d2
	rts

CNop:
	; CNOP offset,align
	jmp	CNop2(pc)
	bsr.s	getcnopvalues		; d2=align, d3=offset
ds_cnop1:
	bsr.s	MakeCNop		; d0=nötige Füllbytes
	cmp.w	#2,d2
	bls.s	2$			; align war größer als 2 ?
	move.l	CurrentSec(a5),a0
	cmp.w	#HUNK_CODE,sec_Type+2(a0)
	bne.s	2$
	add.l	d2,d0			; Code: Immer nächsten Align-Punkt nehmen!
	bsr.s	StoreCnopTab
2$:	add.l	d0,d6			; PC weitersetzen
	rts
CNop2:
	bsr.s	getcnopvalues
ds_cnop2:
	bsr.s	MakeCNop
	subq.w	#2,d2
	bls.s	6$			; align war größer als 2 ?
	move.l	CurrentSec(a5),a2
	cmp.w	#HUNK_CODE,sec_Type+2(a2)
	beq.s	1$
6$:	add.l	d0,d6			; PC weitersetzen und Füllbytes schreiben
	bra	AddCount
1$:	move.l	d0,d5			; Code Section:
	bsr.s	SubCnopTab
	beq.s	2$			; Zahl der Füllbytes wie in Pass 1 ?
	move.l	d6,sec_LastCnop(a2)
	move.l	d6,a0
	addq.l	#1,a0			; Sym. *vor* dem CNOP nicht versch.!
	bsr	ShiftRelocsNoOpt	; Symbole/Distanzen verschieben
2$:	add.l	d5,d6
	move.l	d6,sec_LastCnop(a2)
	tst.l	d5			; gar nichts einfügen?
	beq.s	5$
	tst.b	ZeroPadding(a5)
	bne.s	4$
	btst	#0,d5			; Gerade Anzahl NOPs in CodeSec einfügen?
	bne.s	4$
3$:	move.w	#$4e71,d0
	bsr	AddWord
	subq.l	#2,d5
	bne.s	3$
5$:	rts
4$:	move.l	d5,d0
	bra	AddCount


StoreCnopTab:
; d0 = zu speichernder Wert
; a2/d2 werden zerstoert!!!
	move.l	CnopTabPtr(a5),a2	;  dann Zahl der Fuellbytes in Tabelle eintr.
	move.l	CnopPtr(a5),a0
	cmp.l	ctab_End(a2),a0
	blo.s	1$
	move.l	d0,d2
	jsr	GetCnopTab
	move.l	d0,(a2)
	move.l	d0,CnopTabPtr(a5)
	addq.l	#ctab_HEAD,d0
	move.l	d0,a0
	move.l	d2,d0
1$:	move.l	d0,(a0)+		; Fuellbytes
	move.l	a0,CnopPtr(a5)
	rts

SubCnopTab:
; d0 = Wert, von dem der CnopTab-Wert subtrahiert wird
	move.l	CnopTabPtr(a5),a1
	move.l	CnopPtr(a5),a0
	cmp.l	ctab_End(a1),a0
	blo.s	1$
	move.l	(a1),a0
	move.l	a0,CnopTabPtr(a5)
	addq.l	#ctab_HEAD,a0
1$:	sub.l	(a0)+,d0
	move.l	a0,CnopPtr(a5)
	tst.l	d0
	rts


	IFND	FREEASS
	cnop	0,4
IfCmp:					; IFEQ/IFNE/IFGT/IFGE/IFLE/IFLT <Expression>
	nop
	nop
	clr.b	(a2)
	bsr	Pass2Ignore
	addq.b	#1,IfNest(a5)
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Wert der Expression bestimmen
	tst.w	d2
	bmi	UndefSym
	beq.s	1$
	tst.b	d2
	bmi.s	1$
	sub.l	d1,d0			; Distanz
1$:	moveq	#0,d1
	cmp.l	d1,d0			; Value gegen 0 vergleichen
	jmp	2$(pc,d4.w)
2$:	jmp	10$(pc)
	jmp	11$(pc)
	jmp	12$(pc)
	jmp	13$(pc)
	jmp	14$(pc)
	jmp	15$(pc)
10$:	bne	IfElse			; EQ
	rts
11$:	beq	IfElse			; NE
	rts
12$:	ble	IfElse			; GT
	rts
13$:	blt	IfElse			; GE
	rts
14$:	bgt	IfElse			; LE
	rts
15$:	bge	IfElse			; LT
	rts


	cnop	0,4
IfStr:					; IFC/IFNC str1,str2
	nop
	nop
	clr.b	(a2)
	bsr	Pass2Ignore
	addq.b	#1,IfNest(a5)
	lea	Buffer(a5),a2
	move.l	a3,a0
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	jsr	ReadArgument
	beq	MissingArg
	lea	(a3,d0.w),a0
	cmp.b	#',',(a0)
	bne	MissingArg
	clr.b	(a0)+			; str1 im SrcOperBuffer
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	jsr	ReadArgument		; str2 im Working-Buffer
	beq	MissingArg
	move.l	a3,a0
	move.l	a2,a1
	bsr	StrCmp			; Strings vergleichen
	sne	d0
	cmp.b	d0,d4			; IFC oder IFNC erfuellt ?
	bne	IfElse
	rts


	cnop	0,4
IfDef:
	; IFD/IFND Symbol
	nop
	nop
	clr.b	(a2)
	bsr	Pass2Ignore
	addq.b	#1,IfNest(a5)
	move.l	a3,a0
	moveq	#os_LONG,d0
	jsr	GetValue		; Wert der Expression bestimmen
	tst.w	d2
	bpl.s	1$			; Symbol ist definiert!
	move.l	a3,a0
	bsr	StrLen
	jsr	FindRegName		; Registersymbol?
	move.w	d0,d2
	bmi.s	2$			; Undefiniertes Symbol
1$:	tst.b	d4			; <- Defined
	bne.s	IfElse
	rts
2$:	tst.b	d4			; <- Undefined
	beq.s	IfElse
	rts


	cnop	0,4
IfElse:
; Versucht die Abarbeitung bei ELSE fortzusetzen. Falls dies nicht vorhanden
; ist, wird ENDC/ENDIF gesucht.
	move.l	a6,-(sp)
	lea	else_dir(pc),a0
	move.l	a0,d2
	lea	endc_dir(pc),a0
	move.l	a0,d3
	lea	endif_dir(pc),a0
	move.l	a0,d4
	moveq	#0,d5			; d5 NestCnt2
1$:
	IFND	GIGALINES
	addq.w	#1,Line(a5)
	addq.w	#1,AbsLine(a5)
	ELSE
	addq.l	#1,Line(a5)
	addq.l	#1,AbsLine(a5)
	ENDC
	movem.l	d2-d4,-(sp)
	jsr	LineParts		; Neue Zeile in Buffer holen
	tst.b	ListEn(a5)
	beq.s	8$
	bsr	ListSourceLine		; Sourcetext-Zeile in Listing aufnehmen
8$:	st	sut_LabelLen(a6)	; und in Pass 2 nicht mehr beachten!
	clr.w	sut_OperOffset(a6)
	move.l	a3,a0			; Opcode in Großbuchstaben wandeln
	lea	ucase_tab(a5),a1
	moveq	#0,d0
10$:	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	bne.s	10$
	movem.l	(sp)+,d2-d4
	cmp.w	#'IF',(a3)
	beq	5$			; Weitere Verschachtelung durch neues IF ?
	tst.w	d5
	bne.s	21$
	move.l	a3,a0
	move.l	d2,a1
	bsr	StrCmp			; ELSE oder ELSEIF gefunden ?
	beq.s	3$
	move.l	a3,a0
	lea	elseif_dir(pc),a1
	bsr	StrCmp
	beq.s	3$
21$:	move.l	a3,a0
	move.l	d3,a1
	bsr	StrCmp			; ENDC oder ENDIF ?
	beq.s	2$
	move.l	a3,a0
	move.l	d4,a1
	bsr	StrCmp
	beq.s	2$
4$:	tst.l	d7
	bne	1$			; Sourcetext zuende und noch kein ENDC/ENDIF ?
	moveq	#70,d0			; Missing ENDC/ENDIF
	bra	FatalError2
2$:	subq.w	#1,d5
	bpl.s	4$
	subq.b	#1,IfNest(a5)		; ENDC - IfNest vermindern
	bmi.s	9$
3$:	move.l	(sp)+,a6
	rts
9$:	move.l	(sp)+,a6
	clr.b	IfNest(a5)
	moveq	#75,d0			; Unexpected ENDC/ENDIF
	bra	Error2
5$:	; Testen ob es sich um echtes IFx handelt
	tst.b	2(a3)
	beq.s	7$
	move.w	2(a3),d0
	cmp.w	#$4300,d0
	beq.s	7$
	cmp.w	#'NC',d0
	beq.s	6$
	cmp.w	#$4400,d0
	beq.s	7$
	cmp.w	#'ND',d0
	beq.s	71$			; IFND or IFNDEF?
	cmp.w	#'EQ',d0
	beq.s	6$
	cmp.w	#'NE',d0
	beq.s	6$
	cmp.w	#'GT',d0
	beq.s	6$
	cmp.w	#'GE',d0
	beq.s	6$
	cmp.w	#'LE',d0
	beq.s	6$
	cmp.w	#'LT',d0
	beq.s	6$
	cmp.w	#'DE',d0		; IFDEF
	bne	4$
	cmp.w	#$4600,4(a3)
	beq.s	7$
	bra	4$
6$:	tst.b	4(a3)
	bne	4$
7$:	addq.w	#1,d5
	bra	4$
71$:	tst.b	4(a3)			; check for IFNDEF
	beq.s	7$
	cmp.w	#'EF',4(a3)
	bne	4$
	tst.b	6(a3)
	beq.s	7$
	bra	4$


	cnop	0,4
IfEND:
; Ende der bedingten Assemblierung ausgeloest durch ELSE, ELSEIF, ENDC, ENDIF
	nop
	nop
	clr.b	(a2)
	bsr	Pass2Ignore
	tst.b	d4			; ELSE-Teil nicht abarbeiten ?
	bne	IfElse			;  dann ENDC/ENDIF suchen
	subq.b	#1,IfNest(a5)		; ENDC - IfNest vermindern
	bmi.s	1$
	rts
1$:	clr.b	IfNest(a5)
	moveq	#75,d0			; Unexpected ENDC/ENDIF
	bra	Error2


InitNear:
	jmp	InitNear2(pc)
	tst.b	MainModel(a5)
	bmi.s	3$
	move.b	NearSec(a5),d0
	cmp.b	#-2,d0
	bhs.s	1$
	cmp.b	SecNum+1(a5),d0		; Near-Section ist aktuelle Section?
	bne.s	1$
	cmp.l	#$fffc,d6
	bhi.s	1$
	moveq	#4,d0
	bra.s	2$
1$:	moveq	#10,d0
2$:	add.l	d0,d6			; 10 Bytes Platz schaffen
3$:	rts
InitNear2:
	moveq	#0,d3
	move.b	MainModel(a5),d3
	bpl.s	2$
	moveq	#91,d0			; Near mode not activated
	bra	Error2
2$:	addq.l	#2,d6
	moveq	#0,d2
	move.b	NearSec(a5),d2
	IFND	FREEASS
	tst.b	AbsCode(a5)
	bne.s	20$			; absolute ?
	ENDC
	cmp.b	#-2,d0
	bhs.s	20$
	cmp.b	SecNum+1(a5),d2		; Near-Section ist aktuelle Section?
	bne.s	20$
	cmp.l	#$fffe,d6
	bhi.s	20$
	moveq	#-1,d4			; d4 PC-Relativ = TRUE
	move.w	#$41fa,d0		; LEA SecBase(PC),An
	bra.s	21$
20$:	moveq	#0,d4
	move.w	#$41f9,d0		; LEA SecBase,An
21$:	ror.w	#7,d3
	or.w	d3,d0
	bsr	AddWord
	tst.b	d4
	beq.s	30$
	move.l	#32766,d0
	sub.l	d6,d0
	bsr	AddWord
	addq.l	#2,d6
	rts
30$:
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	3$			; absolute ?
	bsr	GetSectionPtr
	move.l	sec_Origin(a0),d0
	bsr	AddLong
	bra.s	9$
	ENDC
3$:	moveq	#0,d0
	bsr	AddLong
	cmp.b	#-2,d2			; SmallData?
	blo.s	7$
	move.w	#HUNK_DATA,d1		; erste Data-Section suchen
	bsr.s	10$
	cmp.w	SectionCnt(a5),d2
	blo.s	8$
	move.w	#HUNK_BSS,d1		; nicht vorhanden? - Dann erste Bss-Section
	bsr.s	10$
7$:	cmp.w	SectionCnt(a5),d2
	blo.s	8$
	moveq	#95,d0
	bsr	Error2			; Section doesn't exist
	moveq	#0,d2
8$:	move.w	d2,d1
	move.l	d6,d0
	bsr	AddRelocation
9$:	addq.l	#8,d6
99$:	move.w	#$41e8,d0		; LEA 32766(An),An
	or.w	d3,d0
	or.b	MainModel(a5),d0
	bsr	AddWord
	move.w	#32766,d0
	bra	AddWord

10$:
; d1 = HUNK_DATA/HUNK_BSS
; d2 = erste SectionNum dieses Typs oder d2=SectionCnt bei Fehler
	move.l	SecTabPtr(a5),d0	; 1. Data/Bss-Section suchen (für Small-Data)
	moveq	#0,d2
4$:	move.l	d0,a3
	lea	secl_HEAD(a3),a1
	move.l	secl_FreeEntry(a3),d0
	bne.s	6$
	lea	SECLISTBLK(a1),a0
	move.l	a0,d0
	bra.s	6$
5$:	move.l	(a1)+,a0
	cmp.w	sec_Type+2(a0),d1
	bne.s	11$
	tst.b	sec_Near(a0)		; Typ stimmt und Section ist auch als
	bne.s	12$			;  Small-Data eingetragen?
11$:	addq.w	#1,d2
6$:	cmp.l	d0,a1
	bne.s	5$
	move.l	(a3),d0
	bne.s	4$
12$:	rts


NModel:					; NEAR [An[,SecNum]]
	nop				;  Bei SecNum= -1 (oder 'S..') werden alle
	nop				;   Data/BSS-Sections als Near behandelt
	btst	#sw_MODEL,Switches(a5)	;  Bei SecNum= -2 (default) sind alle Sections
	bne	4$			;   mit Namen "__MERGED" Small-Data
	moveq	#-$21,d0		;  Bei SecNum= 'C..' wird Small-Code aktiviert
	and.b	(a3),d0
	cmp.b	#'C',d0
	bne.s	5$
	bset	#sw_NEARCODE,Switches(a5) ; Small Code Model
	bra	4$
5$:	move.b	NearSec(a5),d4
	move.b	MainModel(a5),d3	; Basisregister eines bereits exist. Models
	bpl.s	3$
	moveq	#4,d3			; Default-Werte
	moveq	#-2,d4
3$:	tst.b	(a3)			; keine Parameter ? Dann nur reaktivieren.
	beq.s	1$
	move.l	a3,a0
	bsr	GetRegister		; BasisRegister fuer Near-Mode holen
	bmi	NeedAReg
	bclr	#3,d0
	beq	NeedAReg
	move.w	d0,d3
; cmp.b	 #2,d3			 ; An muss zwischen A2 und A6 liegen
; blo	 IllegalMode
	cmp.b	#7,d3
	bhs	IllegalMode
	move.b	(a0)+,d0
	beq.s	1$
	cmp.b	#',',d0			; folgt noch die Angabe der SecNum ?
	bne	SyntaxErr
	moveq	#-$21,d0
	and.b	(a0),d0
	cmp.b	#'S',d0			; 'S' (z.B. 'SmallData' oder 'SD') erlaubt
	bne.s	2$
	moveq	#-1,d4
	bra.s	1$
2$:	moveq	#os_BYTE,d0
	bsr	GetValue2
	tst.w	d2
	bne	AddrError		; SecNum kann keine PrgAdr. enthalten
	move.w	d0,d4
1$:	move.b	d3,MainModel(a5)
	move.b	d3,Model(a5)
	move.b	d4,NearSec(a5)
4$:	clr.b	(a2)			; Label löschen
	rts


FModel:					; FAR
	nop
	nop
	btst	#sw_MODEL,Switches(a5)
	bne.s	1$
	st	Model(a5)
1$:	clr.b	(a2)			; Label löschen
	rts


Rorg:
	; RORG RelOffset - Section Offset setzen
	nop
	nop
	tst.b	(a3)
	beq	MissingArg
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue2		; offset lesen
	tst.w	d2
	beq.s	1$
	bmi	UndefSym
	bra	AddrError
1$:	tst.l	d0			; Negativ?
	bmi.s	6$
	sub.l	d6,d0			; offset liegt vor der akt. Adresse?
	bhi.s	2$
	beq.s	3$
6$:	moveq	#96,d0			; Illegal RORG Offset
	bra	Error2
2$:	tst.b	d5
	bne.s	4$
	bsr.s	StoreCnopTab		; Pass 1
	add.l	d0,d6
3$:	rts
4$:	; Pass 2
	move.l	d0,d5
	bsr.s	SubCnopTab
	beq.s	5$			; Zahl der Füllbytes wie in Pass 1 ?
	move.l	CurrentSec(a5),a0
	move.l	d6,sec_LastCnop(a0)
	move.l	d6,a0
	bsr	ShiftRelocsNoOpt	; Symbole/Distanzen verschieben
5$:	add.l	d5,d6
	move.l	CurrentSec(a5),a0
	move.l	d6,sec_LastCnop(a0)
	move.l	d5,d0
	bra	AddCount


Orig:
	; ORG Address - Code zu abs. Addr. erzeugen
	jmp	GetORGSec(pc)
	bsr.s	GetORGSec
	bne.s	9$
	move.b	AbsCode(a5),d0
	bne.s	1$
	moveq	#76,d0			; Impossible in relative mode
	bra	Error2
1$:	bpl.s	2$
	move.l	d5,sec_Destination(a0)	; Default: LOAD nach ORG
2$:	move.l	d5,sec_Origin(a0)
	move.l	d5,d6
9$:	rts

GetORGSec:
; -> a0 = Section
; -> d5 = SectionBaseAddr
; -> d0 = Error(-1)
	clr.b	(a2)
	moveq	#os_LONG,d0
	move.l	a3,a0
	bsr	GetValue2		; Basis-Adresse bestimmen
	tst.w	d2
	bpl.s	2$
	moveq	#36,d0			; Undefined Symbol
	bra.s	3$
2$:	beq.s	1$
	moveq	#42,d0			; Relocatability error
3$:	bsr	Error2
	moveq	#-1,d0
	rts
1$:	move.l	d0,d5			; d5 Section - Origin
	move.l	d5,-(sp)
	move.l	sp,a1
	move.l	#'%lx\0',-(sp)
	move.l	sp,a0
	lea	10$(pc),a2
	lea	Buffer(a5),a3
	jsr	RawDoFmt(a6)		; OriginAddr. in String umwandeln
	addq.l	#8,sp
	lea	Buffer(a5),a0		;  und mit diesem Namen
	move.l	#HUNK_CODE,d0		;  eine
	bsr	MakeSection		; Code-Section eroeffnen
	moveq	#0,d0
	rts
10$:	move.b	d0,(a3)+
	clr.b	(a3)
	rts


AbsLoad:				; LOAD Address - Code an Addr. schreiben
	rts
	nop
	clr.b	(a2)
	tst.b	AbsCode(a5)
	bne.s	1$
3$:	moveq	#76,d0			; Impossible in relative mode
4$:	bsr	Error2
	bra.s	9$
1$:	moveq	#os_LONG,d0
	move.l	a3,a0
	bsr	GetValue2		; Destination-Adresse bestimmen
	tst.w	d2
	bmi	UndefSym
	beq.s	2$
	moveq	#42,d0			; Relocatability error
	bra.s	4$
2$:	move.l	CurrentSec(a5),d1
	beq.s	3$
	move.l	d1,a0
	move.b	AbsCode(a5),d1
	bmi.s	5$
	subq.b	#1,d1
	beq.s	6$
	moveq	#90,d0			; Can't mix LOAD, FILE and TRACKDISK
	bra.s	4$
5$:	move.b	#1,AbsCode(a5)
6$:	move.l	d0,sec_Destination(a0)
9$:	bra	Pass2Ignore


AbsFile:				; FILE "name" - Abs.Code in File schreiben
	rts				; SFORM "name" - S-Record schreiben
	nop				; d4 = 2 oder 7
	clr.b	(a2)
	tst.b	AbsCode(a5)
	bne.s	1$
11$:	moveq	#76,d0			; Impossible in relative mode
10$:	bsr	Error2
	bra.s	9$
1$:	bsr	getFilename		; Filename lesen (mit oder ohne " ')
	bne	2$			; keine Name ?
	move.l	ObjectName(a5),d0	;  dann den Object-Name verwenden
	bra.s	3$
2$:	move.l	a2,a0
	jsr	AddString
3$:	move.l	CurrentSec(a5),d1
	beq.s	11$
	move.l	d1,a0
	move.b	AbsCode(a5),d1
	bmi.s	7$
	cmp.b	d4,d1
	beq.s	8$
	moveq	#90,d0			; Can't mix LOAD, FILE and TRACKDISK
	bra.s	10$
7$:	move.b	d4,AbsCode(a5)
8$:	move.l	d0,sec_Destination(a0)	; FileName als Destination speichern
9$:	bra	Pass2Ignore


AbsTD:					; TRACKDISK drive,firstBlock[,offset]
	rts
	nop
	clr.b	(a2)
	tst.b	AbsCode(a5)
	bne.s	1$
11$:	moveq	#76,d0			; Impossible in relative mode
10$:	bsr	Error2
	bra.s	9$
1$:	moveq	#os_BYTE,d0
	move.l	a3,a0
	bsr	GetValue2		; Drive (0-3)
	tst.w	d2
2$:	bmi	UndefSym
	bne	AddrError
	moveq	#3,d5
	and.b	d5,d0
	add.b	d0,d5
	cmp.b	#',',(a0)+
	bne	SyntaxErr
	moveq	#os_LONG,d0
	bsr	GetValue2		; firstBlock
	tst.w	d2
	bne.s	2$
	move.l	d0,d4
	lsl.l	#8,d4
	add.l	d4,d4			; TrackdiskOffset = firstBlock*512
	move.b	(a0)+,d0
	beq.s	4$
	cmp.b	#',',d0			; noch ein Offset ?
	bne	SyntaxErr
	moveq	#os_LONG,d0
	bsr	GetValue2		; offset
	tst.w	d2
	bne.s	2$
	add.l	d0,d4			; Gesamt-Offset speichern
4$:	move.l	CurrentSec(a5),d1
	beq.s	11$
	move.l	d1,a0
	move.b	AbsCode(a5),d1
	bmi.s	7$
	cmp.b	d5,d1
	beq.s	8$
	moveq	#90,d0			; Can't mix LOAD, FILE and TRACKDISK
	bra.s	10$
7$:	move.b	d5,AbsCode(a5)
8$:	move.l	d4,sec_Destination(a0)	; Trackdisk-Offset als Destination speichern
9$:	bra	Pass2Ignore


SType:					; STYPE type[,recLen] - S-Record type
	rts
	nop
	moveq	#os_BYTE,d0
	move.l	a3,a0
	bsr	GetValue2		; Type (1-3)
	tst.w	d2
1$:	bmi	UndefSym
	bne	AddrError
	subq.l	#1,d0
	blo	OutofRange
	moveq	#2,d1
	cmp.l	d1,d0
	bhi	OutofRange
	move.b	d0,SRecType(a5)
	move.b	(a0)+,d0		; recLen gegeben?
	beq.s	9$
	cmp.b	#',',d0
	bne	SyntaxErr
	moveq	#os_BYTE,d0
	bsr	GetValue2		; recLen (16-255)
	tst.w	d2
	bne.s	1$
	moveq	#16,d1
	cmp.l	d1,d0			; Minimale Record-Länge = 16
	blo	OutofRange
	cmp.l	#255,d0
	bhi	OutofRange		; Maximale Record-Länge = 255
	move.b	d0,SRecLen(a5)
9$:	bra	Pass2Ignore
	ENDC


	cnop	0,4
DProcStrt:
; PROCSTART kennzeichnet bei DICE einen Bereich in dem ein LINK A5,#0 / UNLK A5
; Paar entfernt werden kann, wenn keine weiteren Referenzen auf A5 vorhanden.
	nop
	nop
	st	DiceProc(a5)
	clr.b	(a2)
	rts


	cnop	0,4
DProcEnd:
; PROCEND für DICE-C
	nop
	nop
	clr.b	DiceProc(a5)
	clr.b	(a2)
	rts


OutputName:
	rts
	nop
	clr.b	(a2)
	bsr	getFilename		; Filename lesen (mit oder ohne " ')
	beq	MissingArg		; keine Name ?
	move.l	a2,a0
	jsr	AddString
	move.l	d0,ObjectName(a5)	; als neuen ObjectName speichern 
	bra	Pass2Ignore


	IFND	FREEASS
	cnop	0,4
ReptStart:				; REPT <expression>
; Nachfolgenden Programmteil so oft wiederholen, wie in <expression> angegeben.
; <expression> muß positiv und absolut sein!
	nop
	nop
	moveq	#os_LONG,d0
	move.l	a3,a0
	bsr	GetValue2		; Basis-Adresse bestimmen
	tst.w	d2
	beq.s	2$
	bmi	UndefSym
1$:	moveq	#78,d0			; Illegal REPT count
	bra	Error2
2$:	move.l	d0,d2
	bmi.s	1$			; EQU-Value muß positiv sein
	beq.s	ZeroRept		; Spezialfall für REPT 0 (Bereich überspr.)
	move.l	RepTabPtr(a5),d0
3$:	move.l	d0,a2
	move.l	reptab_Ptr(a2),d0	; freien Slot in der RepTab suchen
	bne.s	4$
	move.l	reptab_Link(a2),d0
	bne.s	3$
	jsr	GetRepTab
	move.l	d0,reptab_Link(a2)
	bra.s	3$
4$:	move.l	d0,a0
	move.l	d7,(a0)+		; SrcLen/SrcPtr nach reptab_Len/reptab_Text
	move.l	a4,(a0)+
	move.l	d2,(a0)+		; actual Count nach reptab_Cnt
	IFND	GIGALINES
	move.w	Line(a5),(a0)+		; SrcText Zeilennr. nach reptab_Line
	clr.w	(a0)+
	ELSE
	move.l	Line(a5),(a0)+
	ENDC
	lea	REPTABBLK+reptab_HEAD(a2),a1
	cmp.l	a1,a0			; Chunk ist jetzt voll?
	blo.s	5$
	sub.l	a0,a0			; nächstesmal neuen Chunk besorgen
5$:	move.l	a0,reptab_Ptr(a2)
	addq.b	#1,ReptDepth(a5)
	beq.s	6$
	rts
6$:	moveq	#100,d0			; REPT nesting depth exceeded!
	bra	FatalError2

ZeroRept:				; REPT 0
; Alles bis zum dazugehörigen ENDR überlesen
	move.l	a6,-(sp)
	bsr	Pass2Ignore		; Den gesamten REPT-Part in Pass 2 ignorieren
	lea	rept_dir(pc),a0
	move.l	a0,d2			; d2 "REPT"
	lea	endr_dir(pc),a0
	move.l	a0,d3			; d3 "ENDR"
	moveq	#1,d5			; d5 REPT-Nest Count
1$:
	IFND	GIGALINES
	addq.w	#1,Line(a5)
	addq.w	#1,AbsLine(a5)
	ELSE
	addq.l	#1,Line(a5)
	addq.l	#1,AbsLine(a5)
	ENDC
	movem.l	d2-d3,-(sp)
	jsr	LineParts		; Neue Zeile in Buffer holen
	tst.b	ListEn(a5)
	beq.s	4$
	bsr	ListSourceLine		; Sourcetext-Zeile in Listing aufnehmen
4$:	movem.l	(sp)+,d2-d3
	st	sut_LabelLen(a6)	; und in Pass 2 nicht mehr beachten!
	clr.w	sut_OperOffset(a6)
	and.l	#$dfdfdfdf,(a3)
	move.l	a3,a0
	move.l	d3,a1
	bsr	StrCmp			; ENDR ?
	beq.s	3$
	move.l	a3,a0
	move.l	d2,a1
	bsr	StrCmp			; neues REPT nesting?
	bne.s	2$
	addq.w	#1,d5
2$:	tst.l	d7
	bne.s	1$			; Sourcetext zuende und noch kein ENDR ?
	move.l	(sp)+,a6
	moveq	#98,d0			; Missing ENDR
	bra	FatalError2
3$:	subq.w	#1,d5			; aktuelle REPT-0 loop verlassen?
	bne.s	2$
	move.l	(sp)+,a6
	rts


DoAsm:					; ASM / EREM
	nop
	nop
	clr.b	(a2)
	bra	Pass2Ignore


DoEndAsm:				; ENDASM/REM - alles bis
	nop				;  ASM/EREM ignorieren
	nop
	clr.b	(a2)
	bsr	Pass2Ignore
	move.l	a6,-(sp)
	tst.b	d4
	beq.s	5$
	lea	erem_dir(pc),a0		; EREM
	bra.s	6$
5$:	lea	asm_dir(pc),a0		; ASM
6$:	move.l	a0,d2
1$:
	IFND	GIGALINES
	addq.w	#1,Line(a5)
	addq.w	#1,AbsLine(a5)
	ELSE
	addq.l	#1,Line(a5)
	addq.l	#1,AbsLine(a5)
	ENDC
	move.l	d2,-(sp)
	jsr	LineParts		; Neue Zeile in Buffer holen
	tst.b	ListEn(a5)
	beq.s	2$
	bsr	ListSourceLine		; Sourcetext-Zeile in Listing aufnehmen
2$:	st	sut_LabelLen(a6)	; und in Pass 2 nicht mehr beachten!
	clr.w	sut_OperOffset(a6)
	move.l	a3,a0			; Opcode in Großbuchstaben wandeln
	lea	ucase_tab(a5),a1
	moveq	#0,d0
3$:	move.b	(a3),d0
	move.b	(a1,d0.w),(a3)+
	bne.s	3$
	move.l	(sp)+,d2
	move.l	d2,a1
	bsr	StrCmp			; ASM/EREM ?
	beq.s	4$
	tst.l	d7
	bne.s	1$
4$:	move.l	(sp)+,a6
	rts


	cnop	0,4
ReptEnd:				; ENDR
	nop
	nop
	clr.b	(a2)
	tst.b	ReptDepth(a5)
	beq.s	99$
	sub.l	a3,a3
	move.l	RepTabPtr(a5),a2
1$:	move.l	reptab_Ptr(a2),d0	; aktuellen REPT-Eintrag suchen
	bne.s	2$
	move.l	a2,a3
	move.l	reptab_Link(a2),a2
	bra.s	1$
99$:	moveq	#99,d0			; Unexpected ENDR!
	bra	Error2
2$:	move.l	d0,a0
	lea	reptab_HEAD(a2),a1
	cmp.l	a1,a0			; aktueller Eintrag im Vorgänger-Chunk?
	bne.s	3$
	move.l	a3,a2
	lea	reptab_HEAD+REPTABBLK(a2),a0
3$:	lea	-reptabSIZE(a0),a0	; a0 aktuelle REPT-Level Daten
	subq.l	#1,reptab_Cnt(a0)
	beq.s	4$			; Schleife ist am Ende?
	movem.l	reptab_Len(a0),d7/a4	; d7 remain.Size u. reptab_Text: a4 SrcPtr
	IFND	GIGALINES
	move.w	reptab_Line(a0),Line(a5) ; SrcLine zurücksetzen
	ELSE
	move.l	reptab_Line(a0),Line(a5)
	ENDC
	rts				; und am Schleifenanfang weitermachen
4$:	move.l	a0,reptab_Ptr(a2)	; Schleifenende: Eintrag als frei kennzeichnen
	subq.b	#1,ReptDepth(a5)
	rts


	IFND	SMALLASS
Int:					; label INT <float expression>
	nop				; Float nach Integer konvertieren
	nop
	moveq	#os_DOUBLE,d0
	move.b	d0,OpcodeSize(a5)
	move.l	a3,a0
	bsr	GetValue2
	tst.w	d2
	bmi	UndefSym		; Nur Konstanten erlaubt als value
	tst.b	(a2)			; kein Label gegeben ?
	bne.s	1$
	bsr	MissingLabel
	bra.s	3$
1$:	move.l	d0,a0
	movem.l	(a0),d0-d1		; d0/d1 Double Precision Float
	move.l	a6,d4
	move.l	MathIEEEBase(a5),a6
	jsr	IEEEDPFix(a6)		; nach 32-Bit Integer wandeln
	move.l	d4,a6
	bvc.s	2$			; Overflow?
	move.l	d0,d4
	moveq	#85,d0
	bsr	Error2
	move.l	d4,d0
2$:	move.l	d0,d1
	moveq	#T_SET,d0		; Integer als SET-Symbol einrichten
	move.l	a2,a0
	bsr	AddGorLSymbol
3$:	clr.b	(a2)
	rts
	ENDC
	ENDC


Save:					; SAVE - aktuelle Section merken
	nop
	nop
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	1$
	moveq	#65,d0			; Impossible in absolute mode
	bra	Error2
1$:
	ENDC
	moveq	#0,d0
	move.b	SaveCnt(a5),d0
	cmp.b	#MAXSAVES,d0
	bhs.s	2$
	addq.b	#1,SaveCnt(a5)
	add.w	d0,d0
	add.w	d0,d0
	lea	SaveSects(a5),a0
	move.l	CurrentSec(a5),(a0,d0.w)
	rts
2$:	moveq	#102,d0			; SAVE nesting depth exceeded
	bra	Error2


Restore:				; RESTORE - letzte Section reaktivieren
	nop
	nop
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	1$
	moveq	#65,d0			; Impossible in absolute mode
	bra	Error2
1$:
	ENDC
	moveq	#0,d0
	move.b	SaveCnt(a5),d0
	subq.b	#1,d0
	bmi.s	2$
	move.b	d0,SaveCnt(a5)
	add.w	d0,d0
	add.w	d0,d0
	lea	SaveSects(a5),a0
	move.l	(a0,d0.w),a0
	move.l	sec_Type(a0),d0
	move.l	sec_Name(a0),a0
	bra	MakeSection		; Section aktvieren
2$:	moveq	#103,d0			; Unexpected RESTORE
	bra	Error2


DSource:				; DSOURCE "Pfadname" setzt den vollständigen
	nop				;  Pfad für Source Level Debugging
	nop
	bsr	absmodecheck
	bne.s	1$
	bsr	getFilename		; Pfad einlesen
	beq.s	1$			; keiner? Dann nichts ändern
	move.l	a2,a0
	jsr	AddString
	move.l	d0,DebugPath(a5)	; Neuen Source-Pfad setzen
1$:	clr.b	(a2)			; Label löschen
	bra	Pass2Ignore


	cnop	0,4
DebugLine:				; DEBUG line  Zeilennr. für LineDebug
	nop
	nop
	tst.b	Pass(a5)		; nur in Pass 2 interessant
	beq.s	1$
	bsr	absmodecheck
	bne.s	1$
	tst.b	(a3)
	beq.s	1$			; Zeilennummer angegeben?
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue2
	tst.w	d2
	beq.s	2$
	bmi	UndefSym
	bra	AddrError		; Programmadr. (oder Dist.) sind nicht erlaubt
2$:	move.l	LineAddr(a5),d2		; Eintrag in LineDebug-Hunk tätigen
	move.l	d0,d3
	jmp	AddLineDebug
1$:	rts


	cnop	0,4
SetSymDebug:				; SYMDEBUG
	nop
	nop
	bsr	absmodecheck
	bne.s	1$
	bset	#sw_SYMDEBUG,Switches(a5)
1$:	clr.b	(a2)			; Label löschen
	bra	Pass2Ignore


	cnop	0,4
SetLineDebug:				; LINEDEBUG
	nop
	nop
	bsr	absmodecheck
	bne.s	1$
	bset	#sw2_LINEDEBUG,Switches2(a5)
1$:	clr.b	(a2)			; Label löschen
	bra	Pass2Ignore


	cnop	0,4
absmodecheck:
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	1$
	bmi.s	1$
	moveq	#65,d0			; Impossible in absolute mode
	bsr	Error2
	moveq	#-1,d0
	rts
1$:
	ENDC
	moveq	#0,d0
	rts


	cnop	0,4
showOffset:				; SHOWOFFSET [text]
	jmp	1$(pc)
	clr.b	(a2)
9$:	rts
1$:	clr.b	(a2)
	move.l	a3,a0
	tst.b	(a0)
	beq.s	4$			; kein String
	lea	Buffer(a5),a1
	move.w	#BUFSIZE-9,d0		; Platz für %08lx\r\n freihalten
	jsr	ReadArgument
	lea	-1(a3,d0.w),a0
	cmp.b	#$22,(a0)		; String durch " oder ' eingegrenzt ?
	beq.s	2$
	cmp.b	#$27,(a0)
	bne.s	3$
2$:	addq.l	#1,a3
	bra.s	4$
3$:	addq.l	#1,a0
4$:	lea	10$(pc),a1
5$:	move.b	(a1)+,(a0)+
	bne.s	5$
	move.l	a3,a0
	move.l	d6,-(sp)
	move.l	sp,a1
	jsr	printf
	addq.w	#4,sp
	rts
10$:	dc.b	" %08lx\r\n",0


	cnop	0,4
BaseReg:				; BASEREG label,An
	jmp	1$(pc)
	rts
1$:
	bsr	SplitOperand
	tst.b	(a3)
	beq	MissingLabel
	move.l	a3,a0
	jsr	FindGorLSymbol
	beq	UndefSym
	move.l	d0,a3			; a3 Symbol 'label'
	btst	#bit_ABS,sym_Type+1(a3)
	beq	NoAddress
	tst.b	(a2)
	beq	MissingReg
	move.l	a2,a0
	jsr	GetRegister
	bmi	MissingReg
	bclr	#3,d0
	beq	NeedAReg
	cmp.b	#7,d0
	bhs	IllegalMode
	move.b	d0,BaseRegNo(a5)
	move.l	sym_Value(a3),BaseSecOffset(a5)
	move.l	sym_RefList(a3),a0
	move.b	rlist_DeclHunk+1(a0),BaseSecNo(a5)
	rts


	cnop	0,4
EndBReg:				; ENDB
	jmp	1$(pc)
	rts
1$:
	st	BaseRegNo(a5)
	rts


	cnop	0,4
PalmRes:				; PALMRES id,num
	jmp	1$(pc)
	bsr	absmodecheck
	beq.s	1$
	rts
1$:
	tst.b	(a3)
	beq	MissingArg
	move.l	a3,a0
	moveq	#os_LONG,d0
	bsr	GetValue2		; id
	tst.w	d2
	beq.s	3$
2$:	bmi	UndefSym
	bne	AddrError
3$:	move.l	d0,d3
	cmp.b	#',',(a0)+
	beq.s	4$
	bra	SyntaxErr
4$:	moveq	#os_LONG,d0
	bsr	GetValue2		; num
	tst.w	d2
	bne.s	2$
	sub.w	#32,sp
	clr.b	(sp)
	move.l	d3,-(sp)
	move.l	sp,a0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	sp,a2
	addq.l	#5,a0
	lea	5$(pc),a1
	jsr	sprintf			; section name = "idstr:num"
	lea	13(sp),a0
	move.l	#HUNK_DATA,d0
	jsr	MakeSection
	add.w	#44,sp
	rts
5$:
	dc.b	"%s:%ld",0


	cnop	0,4
RemEQULine:
; entfernt die letzte Zeile aus dem Sourcecode, falls sich der Assembler
; nicht im Macro-Mode befindet
	IFND	FREEASS
	tst.b	AssMode(a5)
	bmi.s	reql_x			; am_MACRO?
	ENDC
	tst.b	Pass(a5)
	bne.s	reql_x
Pass2Ignore:
	move.l	CurrentSUTPos(a5),a0	; Zeile in Pass 2 nicht mehr beachten!
	st	sut_LabelLen(a0)
	clr.l	sut_OpcodePtr(a0)
	clr.w	sut_OperOffset(a0)
reql_x:
	rts


MakeMnemonicTab:
; HashTable für alle Mnemonics aufbauen.
; a6 = ExecBase
; -> d0 = NumElements
	movem.l	d2-d6/a2-a6,-(sp)
	move.l	MnemHashTabSize(a5),d0
	lsl.l	#2,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher für HashTable anfordern
	move.l	d0,MnemoHashList(a5)
	beq	OutofMemError2
	move.l	d0,a2			; a2 Mnemo-HashTable
	move.l	#Parameters-CG,d0
	move.w	d0,d2
	lsr.w	#1,d2			; d2 = Anzahl Mnemonics - 1
	subq.w	#1,d2
	IFEQ	mnnSIZE-16
	lsl.l	#3,d0			; 16 Bytes für jede Node
	ELSE
	mulu	#mnnSIZE/2,d0
	ENDC
	move.l	d0,MnemoSize(a5)
	moveq	#0,d1
	jsr	AllocMem(a6)		; Speicher für alle Mnemo-Nodes besorgen
	move.l	d0,MnemoMem(a5)
	beq	OutofMemError2
	move.l	d0,a3			; a3 Mnemonic-Nodes
	move.w	MnemHashMask(a5),d6
	lea	CG(pc),a4
	move.l	a4,d4
	lea	Parameters(pc),a5
	lea	Mnemonics(pc),a6
3$:	move.l	a3,d3			; d3 Node-Baseaddr. merken
	clr.l	(a3)+			; mnn_Next-Link für HashChain
	move.l	a6,(a3)+		; mnn_Name
	move.l	d4,a0
	add.w	(a4)+,a0		; Adresse der Generation-Routine bestimmen
	move.l	a0,(a3)+		; mnn_Function
	move.w	(a5)+,(a3)		; mnn_Parameter
	addq.l	#mnnSIZE-mnn_Parameter,a3
	HASHC	a6,d0,d1,d5		; Hashcode des Mnemonics berechnen
	and.w	d6,d0
	lsl.l	#2,d0
	move.l	(a2,d0.l),d1		; HashChain leer?
	beq.s	5$
4$:	move.l	d1,a0
	move.l	(a0),d1			; Ende der HashChain suchen
	bne.s	4$
	move.l	d3,(a0)			; und anhängen
	bra.s	6$
5$:	move.l	d3,(a2,d0.l)
6$:	dbf	d2,3$			; nächster Mnemonic
	movem.l	(sp)+,d2-d6/a2-a6
	rts



	IFND	SMALLASS
; *** PMMU Register Binary Tree ***
	cnop	0,4
pmmurt:
	dc.w	pmmur_bac6-pmmurt,pmmur_psr-pmmurt,$8001,$7014
	dc.b	"BAD5",0,0
pmmur_bac6:
	dc.w	pmmur_bac2-pmmurt,pmmur_bad2-pmmurt,$8001,$7418
	dc.b	"BAC6",0,0
pmmur_bac2:
	dc.w	pmmur_bac0-pmmurt,pmmur_bac4-pmmurt,$8001,$7408
	dc.b	"BAC2",0,0
pmmur_bac0:
	dc.w	pmmur_ac-pmmurt,pmmur_bac1-pmmurt,$8001,$7400
	dc.b	"BAC0",0,0
pmmur_ac:
	dc.w	0,0,$8001,$5c00
	dc.b	"AC",0,0
pmmur_bac1:
	dc.w	0,0,$8001,$7404
	dc.b	"BAC1",0,0
pmmur_bac4:
	dc.w	pmmur_bac3-pmmurt,pmmur_bac5-pmmurt,$8001,$7410
	dc.b	"BAC4",0,0
pmmur_bac3:
	dc.w	0,0,$8001,$740c
	dc.b	"BAC3",0,0
pmmur_bac5:
	dc.w	0,0,$8001,$7414
	dc.b	"BAC5",0,0
pmmur_bad2:
	dc.w	pmmur_bad0-pmmurt,pmmur_bad3-pmmurt,$8001,$7008
	dc.b	"BAD2",0,0
pmmur_bad0:
	dc.w	pmmur_bac7-pmmurt,pmmur_bad1-pmmurt,$8001,$7000
	dc.b	"BAD0",0,0
pmmur_bac7:
	dc.w	0,0,$8001,$741c
	dc.b	"BAC7",0,0
pmmur_bad1:
	dc.w	0,0,$8001,$7004
	dc.b	"BAD1",0,0
pmmur_bad3:
	dc.w	0,pmmur_bad4-pmmurt,$8001,$700c
	dc.b	"BAD3",0,0
pmmur_bad4:
	dc.w	0,0,$8001,$7010
	dc.b	"BAD4",0,0
pmmur_psr:
	dc.w	pmmur_crp-pmmurt,pmmur_tt0-pmmurt,$c001,$6000
	dc.b	"PSR",0
pmmur_crp:
	dc.w	pmmur_bad7-pmmurt,pmmur_mmusr-pmmurt,$c005,$4c00
	dc.b	"CRP",0
pmmur_bad7:
	dc.w	pmmur_bad6-pmmurt,pmmur_cal-pmmurt,$8001,$701c
	dc.b	"BAD7",0,0
pmmur_bad6:
	dc.w	0,0,$8001,$7018
	dc.b	"BAD6",0,0
pmmur_cal:
	dc.w	0,0,$8000,$5000
	dc.b	"CAL",0
pmmur_mmusr:
	dc.w	pmmur_drp-pmmurt,pmmur_pcsr-pmmurt,$c001,$6000
	dc.b	"MMUSR",0
pmmur_drp:
	dc.w	0,0,$8005,$4400
	dc.b	"DRP",0
pmmur_pcsr:
	dc.w	0,0,$8001,$6400
	dc.b	"PCSR",0,0
pmmur_tt0:
	dc.w	pmmur_srp-pmmurt,pmmur_val-pmmurt,$4002,$0800
	dc.b	"TT0",0
pmmur_srp:
	dc.w	pmmur_scc-pmmurt,pmmur_tc-pmmurt,$c005,$4800
	dc.b	"SRP",0
pmmur_scc:
	dc.w	0,0,$8000,$5800
	dc.b	"SCC",0
pmmur_tc:
	dc.w	0,0,$c002,$4000
	dc.b	"TC",0,0
pmmur_val:
	dc.w	pmmur_tt1-pmmurt,0,$8000,$5400
	dc.b	"VAL",0
pmmur_tt1:
	dc.w	0,0,$4002,$0c00
	dc.b	"TT1",0
	ENDC


	cnop	0,4
CG:
	dc.w	DConst-CG,DStor-CG,DStor-CG,DStor-CG,Equate-CG,Equate-CG
	dc.w	EquReg-CG,RegList-CG,SetSym-CG,AssEnd-CG,AssEnd-CG,ChgOpt-CG
	dc.w	DStor-CG,OutputName-CG,RegList-CG,OptCode-CG
	IFND	FREEASS
	dc.w	RSreset-CG,RSset-CG,RS-CG,StrOut-CG,ListEna-CG,ListDis-CG,IDir-CG
	dc.w	RSreset-CG,RSset-CG,RS-CG,FOreset-CG,FOset-CG,FO-CG
	dc.w	Incl-CG,IncBin-CG,IncBin-CG,MacCmd-CG,EndMac-CG,EndMac-CG
	ENDC
	dc.w	UnitTtl-CG,UnitTtl-CG,CSeg-CG,CSeg-CG,DSeg-CG,DSeg-CG,Sect-CG
	dc.w	CSeg-CG,CSeg-CG,DSeg-CG,DSeg-CG,BSeg-CG,BSeg-CG
	dc.w	CSeg-CG,DSeg-CG,BSeg-CG,PalmRes-CG
	dc.w	CrossRefs-CG,CrossRefs-CG,CrossRefs-CG,CrossRefs-CG
	dc.w	BSeg-CG,Glob-CG,BaseReg-CG,EndBReg-CG
	dc.w	NModel-CG,FModel-CG,EvenAdr-CG,CNop-CG,Save-CG,Restore-CG
	IFND	FREEASS
	dc.w	Rorg-CG,Offs-CG,SType-CG
	dc.w	Orig-CG,AbsFile-CG,AbsLoad-CG,AbsTD-CG,NoOp-CG,NoOp-CG
	dc.w	AbsFile-CG,IfCmp-CG,IfStr-CG,IfStr-CG,IfDef-CG,IfDef-CG
	dc.w	IfDef-CG,IfDef-CG
	dc.w	IfCmp-CG,IfCmp-CG,IfCmp-CG,IfCmp-CG,IfCmp-CG,IfCmp-CG
	dc.w	IfEND-CG,IfEND-CG,IfEND-CG,IfEND-CG,ReptStart-CG,ReptEnd-CG
	dc.w	DoAsm-CG,DoEndAsm-CG,DoAsm-CG,DoEndAsm-CG
	ENDC
	IFND	SMALLASS
	dc.w	SetFPU-CG,SetPMMU-CG,FPRegList-CG,FPRegList-CG,FEquReg-CG
	ENDC
	IFND	SMALLASS
	IFND	FREEASS
	dc.w	Int-CG
	ENDC
	ENDC
	dc.w	InitNear-CG,MachType-CG,DProcStrt-CG,DProcEnd-CG,DebugLine-CG,DSource-CG
	dc.w	mc680x0-CG,mc680x0-CG,mc680x0-CG,mc680x0-CG,mc680x0-CG,mc680x0-CG
	dc.w	mc680x0-CG,mc680x0-CG,mc680x0-CG
	dc.w	SetSymDebug-CG,SetLineDebug-CG,showOffset-CG

	dc.w	Mov-CG,Mov-CG,MovQ-CG,MovM-CG,AS-CG,ASA-CG,ASQ-CG,AS-CG
	dc.w	ASA-CG,ASQ-CG,Bra-CG,Bra-CG,Single-CG,Jmp-CG,Bra-CG,Bra-CG
	dc.w	Bra-CG,Bra-CG,Bra-CG,Bra-CG,Bra-CG,Bra-CG,Bra-CG,Bra-CG
	dc.w	Bra-CG,Bra-CG,Bra-CG,Bra-CG,Bra-CG,Bra-CG,Jmp-CG,Lea-CG
	dc.w	DBra-CG,DBra-CG,DBra-CG,Pea-CG,Cmp-CG,CmpA-CG,Swap-CG,Tst-CG
	dc.w	Clr-CG,Ext-CG,Btst-CG,AOr-CG,AOr-CG,Negs-CG,Shift-CG,Shift-CG
	dc.w	Shift-CG,Shift-CG,Negs-CG,Bit-CG,Bit-CG,Lnk-CG,Unlk-CG,Bit-CG
	dc.w	MD-CG,MD-CG,Exg-CG,ExOr-CG,CmpM-CG,Single-CG,MD-CG,MD-CG
	dc.w	SCC-CG,SCC-CG,SCC-CG,SCC-CG,SCC-CG,SCC-CG,Single-CG,Shift-CG
	dc.w	Shift-CG,Shift-CG,Shift-CG,Trp-CG,ASX-CG,ASX-CG,Negs-CG,Single-CG
	dc.w	DBra-CG,DBra-CG,DBra-CG,DBra-CG,DBra-CG,DBra-CG,DBra-CG,DBra-CG
	dc.w	DBra-CG,DBra-CG,DBra-CG,DBra-CG,DBra-CG,DBra-CG,DBra-CG,SCC-CG
	dc.w	SCC-CG,SCC-CG,SCC-CG,SCC-CG,SCC-CG,SCC-CG,SCC-CG,SCC-CG
	dc.w	SCC-CG,SCC-CG,SCC-CG,ASI-CG,OAE-CG,CmpI-CG,OAE-CG,OAE-CG
	dc.w	ASI-CG,ASB-CG,ASB-CG,SCC-CG,Single-CG,MovP-CG,Single-CG,SCC-CG
	dc.w	DBra-CG,Chk-CG,Stp-CG,LineAF-CG,LineAF-CG,Single-CG

	IFND	SMALLASS
	dc.w	BkPt-CG,MovC-CG,MovS-CG,RtD-CG

	dc.w	BFea-CG,BFea-CG,BFtoD-CG,BFtoD-CG,BFtoD-CG,BFins-CG
	dc.w	BFea-CG,BFPCea-CG,CallM-CG,Rtm-CG,Cas-CG,Cas2-CG
	dc.w	C2-CG,C2-CG,MD-CG,MD-CG,Pack-CG,Pack-CG
	dc.w	TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG
	dc.w	TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG
	dc.w	TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG,TrpCC-CG
	dc.w	Ext-CG
	dc.w	Mov16-CG,Cinv-CG,Cinv-CG,Cinv-CG,Cinv-CG,Cinv-CG,Cinv-CG
	dc.w	LpStop-CG,Plpa-CG,Plpa-CG,Single-CG,Single-CG
	dc.w	Fsave-CG,Fsave-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG,Flt-CG
	dc.w	Flt-CG,Flt-CG,FMovCR-CG,FNop-CG,FSincos-CG,FTst-CG
	dc.w	FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG
	dc.w	FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG
	dc.w	FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG
	dc.w	FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG
	dc.w	FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG,FBcc-CG
	dc.w	FBcc-CG,FBcc-CG
	dc.w	FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG
	dc.w	FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG
	dc.w	FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG
	dc.w	FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG
	dc.w	FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG,FDBcc-CG
	dc.w	FDBcc-CG,FDBcc-CG
	dc.w	FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG
	dc.w	FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG
	dc.w	FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG
	dc.w	FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG
	dc.w	FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG,FScc-CG
	dc.w	FScc-CG,FScc-CG
	dc.w	FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG
	dc.w	FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG
	dc.w	FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG
	dc.w	FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG
	dc.w	FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG,FTrp-CG
	dc.w	FTrp-CG,FTrp-CG
	dc.w	FMov-CG,FMov-CG,FMov-CG,FMovM-CG
	dc.w	PBcc-CG,PBcc-CG,PBcc-CG,PBcc-CG,PBcc-CG,PBcc-CG
	dc.w	PBcc-CG,PBcc-CG,PBcc-CG,PBcc-CG,PBcc-CG,PBcc-CG
	dc.w	PBcc-CG,PBcc-CG,PBcc-CG,PBcc-CG
	dc.w	PDBcc-CG,PDBcc-CG,PDBcc-CG,PDBcc-CG,PDBcc-CG,PDBcc-CG
	dc.w	PDBcc-CG,PDBcc-CG,PDBcc-CG,PDBcc-CG,PDBcc-CG,PDBcc-CG
	dc.w	PDBcc-CG,PDBcc-CG,PDBcc-CG,PDBcc-CG
	dc.w	PScc-CG,PScc-CG,PScc-CG,PScc-CG,PScc-CG,PScc-CG
	dc.w	PScc-CG,PScc-CG,PScc-CG,PScc-CG,PScc-CG,PScc-CG
	dc.w	PScc-CG,PScc-CG,PScc-CG,PScc-CG
	dc.w	PTrp-CG,PTrp-CG,PTrp-CG,PTrp-CG,PTrp-CG,PTrp-CG
	dc.w	PTrp-CG,PTrp-CG,PTrp-CG,PTrp-CG,PTrp-CG,PTrp-CG
	dc.w	PTrp-CG,PTrp-CG,PTrp-CG,PTrp-CG
	dc.w	Psave-CG,Psave-CG,Pflsh-CG,Pflsh-CG,PflshS-CG,PflshR-CG
	dc.w	PflshN-CG,PflshN-CG,Pload-CG,Pload-CG,Pmov-CG,Pmov-CG
	dc.w	Ptst-CG,Ptst-CG,Pval-CG
	ENDC


	cnop	0,4
Parameters:
	dc.w	0,0,0,1,0,0
	dc.w	0,0,0,0,69,0
	dc.w	1,0,0,0
	IFND	FREEASS
	dc.w	0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0
	dc.w	0,0,0,0,0,1
	ENDC
	dc.w	0,0,0,0,0,0,0
	dc.w	$4000,$8000,$4000,$8000,$4000,$8000
	dc.w	0,0,0,0
	dc.w	T_XREF,T_XDEF,T_PUBLIC,T_NREF
	dc.w	0,0,0,0
	dc.w	0,0,0,0,0,0
	IFND	FREEASS
	dc.w	0,0,0
	dc.w	0,2,0,0,0,0
	dc.w	7,4,0,-1,0,-1
	dc.w	0,-1
	dc.w	0,4,8,12,16,20
	dc.w	1,1,0,0,0,0
	dc.w	0,0,0,-1
	ENDC
	IFND	SMALLASS
	dc.w	0,0,0,0,0
	ENDC
	IFND	SMALLASS
	IFND	FREEASS
	dc.w	0
	ENDC
	ENDC
	dc.w	0,0,0,0,0,0
	dc.w	0,10,20,30,40,60
	dc.w	881,882,851
	dc.w	0,0,0

	dc.w	$0000,$0000,$7000,$0000,$d000,$d000,$5000,$9000
	dc.w	$9000,$5100,$6100,$6000,$4e75,$4e80,$6400,$6500
	dc.w	$6200,$6300,$6400,$6500,$6600,$6700,$6800,$6900
	dc.w	$6a00,$6b00,$6c00,$6d00,$6e00,$6f00,$4ec0,$41c0
	dc.w	$51c8,$56c8,$57c8,$4840,$b000,$b0c0,$4840,$4a00
	dc.w	$4200,$4880,$0000,$8000,$c000,$4600,$000c,$0008
	dc.w	$0004,$0000,$4400,$00c0,$0080,$4e50,$4e58,$0040
	dc.w	$8000,$0000,$c100,$b100,$b108,$4e71,$c000,$4000
	dc.w	$50c0,$51c0,$56c0,$57c0,$5ac0,$5bc0,$4e73,$001c
	dc.w	$0018,$0014,$0010,$4e40,$d100,$9100,$4000,$4e76
	dc.w	$50c8,$52c8,$53c8,$54c8,$55c8,$54c8,$55c8,$58c8
	dc.w	$59c8,$5ac8,$5bc8,$5cc8,$5dc8,$5ec8,$5fc8,$52c0
	dc.w	$53c0,$54c0,$55c0,$54c0,$55c0,$58c0,$59c0,$5cc0
	dc.w	$5dc0,$5ec0,$5fc0,$0600,$0200,$0c00,$0a00,$0000
	dc.w	$0400,$c100,$8100,$4800,$4e70,$0108,$4e77,$4ac0
	dc.w	$51c8,$4180,$4e72,$a000,$f000,$4afc

	IFND	SMALLASS
	dc.w	$4848,$4e7a,$0e00,$4e74

	dc.w	$eac0,$ecc0,$ebc0,$e9c0,$edc0,$efc0
	dc.w	$eec0,$e8c0,$06c0,$06c0,$08c0,$08fc
	dc.w	$8000,$0000,$2000,$6000,$8140,$8180
	dc.w	$50f8,$51f8,$52f8,$53f8,$54f8,$55f8
	dc.w	$54f8,$55f8,$56f8,$57f8,$58f8,$59f8
	dc.w	$5af8,$5bf8,$5cf8,$5df8,$5ef8,$5ff8
	dc.w	$49c0
	dc.w	$f600,$f408,$f410,$f418,$f428,$f430,$f438
	dc.w	$f800,$f5c8,$f588,$4ac8,$4acc
	dc.w	$f100,$f140,$0022,$8062,$8066,$0038
	dc.w	$0020,$8060,$8064,$0021,$0023,$8063
	dc.w	$8067,$0025,$0026,$0028,$8068,$806c
	dc.w	$0024,$0027,$4018,$c058,$c05c,$401c
	dc.w	$400c,$400a,$400d,$401d,$4019,$4010,$4008
	dc.w	$401e,$401f,$4001,$4003,$4015,$4016
	dc.w	$4014,$4006,$401a,$c05a,$c05e,$400e
	dc.w	$4002,$4004,$c041,$c045,$400f,$4009
	dc.w	$4012,$4011,$5c00,$0000,$0030,$003a
	dc.w	$f080,$f081,$f082,$f083,$f084,$f085
	dc.w	$f086,$f087,$f088,$f089,$f08a,$f08b
	dc.w	$f08c,$f08d,$f08e,$f08f,$f090,$f091
	dc.w	$f092,$f093,$f094,$f095,$f096,$f097
	dc.w	$f098,$f099,$f09a,$f09b,$f09c,$f09d
	dc.w	$f09e,$f09f
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009,$000a,$000b
	dc.w	$000c,$000d,$000e,$000f,$0010,$0011
	dc.w	$0012,$0013,$0014,$0015,$0016,$0017
	dc.w	$0018,$0019,$001a,$001b,$001c,$001d
	dc.w	$001e,$001f
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009,$000a,$000b
	dc.w	$000c,$000d,$000e,$000f,$0010,$0011
	dc.w	$0012,$0013,$0014,$0015,$0016,$0017
	dc.w	$0018,$0019,$001a,$001b,$001c,$001d
	dc.w	$001e,$001f
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009,$000a,$000b
	dc.w	$000c,$000d,$000e,$000f,$0010,$0011
	dc.w	$0012,$0013,$0014,$0015,$0016,$0017
	dc.w	$0018,$0019,$001a,$001b,$001c,$001d
	dc.w	$001e,$001f
	dc.w	$0000,$0040,$0044,$8000
	dc.w	$f080,$f081,$f082,$f083,$f084,$f085
	dc.w	$f086,$f087,$f088,$f089,$f08a,$f08b
	dc.w	$f08c,$f08d,$f08e,$f08f
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009,$000a,$000b
	dc.w	$000c,$000d,$000e,$000f
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009,$000a,$000b
	dc.w	$000c,$000d,$000e,$000f
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009,$000a,$000b
	dc.w	$000c,$000d,$000e,$000f
	dc.w	$f100,$f140,$2400,$2000,$3400,$a000
	dc.w	$f500,$f510,$2200,$2000,$0000,$0100
	dc.w	$8200,$8000,$2800
	ENDC


	cnop	0,4
Mnemonics:
	dc.b	"DC",0,"DCB",0,"BLK",0,"DS",0,"=",0,"EQU",0
	dc.b	"EQUR",0,"REG",0,"SET",0,"END",0,"FAIL",0,"OPT",0
	dc.b	"DX",0,"OUTPUT",0,"EQURL",0,"OPTC",0
	IFND	FREEASS
	dc.b	"RSRESET",0,"RSSET",0,"RS",0,"ECHO",0,"LIST",0,"NOLIST",0,"INCDIR",0
	dc.b	"CLRSO",0,"SETSO",0,"SO",0,"CLRFO",0,"SETFO",0,"FO",0
include_dir:
	dc.b	"INCLUDE",0,"INCBIN",0,"IMAGE",0,"MACRO",0,"ENDM",0,"MEXIT",0
	ENDC
	dc.b	"IDNT",0,"TTL",0
code_dir:
	dc.b	"CODE",0,"CSEG",0
data_dir:
	dc.b	"DATA",0,"DSEG",0,"SECTION",0
codec_dir:
	dc.b	"CODE_C",0
codef_dir:
	dc.b	"CODE_F",0
datac_dir:
	dc.b	"DATA_C",0
dataf_dir:
	dc.b	"DATA_F",0
bssc_dir:
	dc.b	"BSS_C",0
bssf_dir:
	dc.b	"BSS_F",0
codep_dir:
	dc.b	"CODE_P",0
datap_dir:
	dc.b	"DATA_P",0
bssp_dir:
	dc.b	"BSS_P",0,"PALMRES",0
	dc.b	"XREF",0,"XDEF",0,"PUBLIC",0,"NREF",0
bss_dir:
	dc.b	"BSS",0,"GLOBAL",0,"BASEREG",0,"ENDB",0
	dc.b	"NEAR",0,"FAR",0,"EVEN",0,"CNOP",0,"SAVE",0,"RESTORE",0
	IFND	FREEASS
	dc.b	"RORG",0,"OFFSET",0,"STYPE",0
	dc.b	"ORG",0,"FILE",0,"LOAD",0,"TRACKDISK",0,"COMMENT",0,"SUBTTL",0
	dc.b	"SFORM",0,"IF",0,"IFC",0,"IFNC",0,"IFD",0,"IFND",0
	dc.b	"IFDEF",0,"IFNDEF",0
	dc.b	"IFEQ",0,"IFNE",0,"IFGT",0,"IFGE",0,"IFLE",0,"IFLT",0
elseif_dir:
	dc.b	"ELSEIF",0
else_dir:
	dc.b	"ELSE",0
endif_dir:
	dc.b	"ENDIF",0
endc_dir:
	dc.b	"ENDC",0
rept_dir:
	dc.b	"REPT",0
endr_dir:
	dc.b	"ENDR",0
asm_dir:
	dc.b	"ASM",0
	dc.b	"ENDASM",0
erem_dir:
	dc.b	"EREM",0
	dc.b	"REM",0
	ENDC
	IFND	SMALLASS
	dc.b	"FPU",0,"PMMU",0,"FREG",0,"FEQURL",0,"FEQUR",0
	ENDC
	IFND	SMALLASS
	IFND	FREEASS
	dc.b	"INT",0
	ENDC
	ENDC
	dc.b	"INITNEAR",0,"MACHINE",0,"PROCSTART",0,"PROCEND",0,"DEBUG",0,"DSOURCE",0
	dc.b	"MC68000",0,"MC68010",0,"MC68020",0,"MC68030",0,"MC68040",0,"MC68060",0
	dc.b	"MC68881",0,"MC68882",0,"MC68851",0
	dc.b	"SYMDEBUG",0,"LINEDEBUG",0,"SHOWOFFSET",0

	dc.b	"MOVE",0,"MOVEA",0,"MOVEQ",0,"MOVEM",0,"ADD",0,"ADDA",0,"ADDQ",0,"SUB",0
	dc.b	"SUBA",0,"SUBQ",0,"BSR",0,"BRA",0,"RTS",0,"JSR",0,"BHS",0,"BLO",0
	dc.b	"BHI",0,"BLS",0,"BCC",0,"BCS",0,"BNE",0,"BEQ",0,"BVC",0,"BVS",0
	dc.b	"BPL",0,"BMI",0,"BGE",0,"BLT",0,"BGT",0,"BLE",0,"JMP",0,"LEA",0
	dc.b	"DBF",0,"DBNE",0,"DBEQ",0,"PEA",0,"CMP",0,"CMPA",0,"SWAP",0,"TST",0
	dc.b	"CLR",0,"EXT",0,"BTST",0,"OR",0,"AND",0,"NOT",0,"LSL",0,"LSR",0
	dc.b	"ASL",0,"ASR",0,"NEG",0,"BSET",0,"BCLR",0,"LINK",0,"UNLK",0,"BCHG",0
	dc.b	"MULU",0,"DIVU",0,"EXG",0,"EOR",0,"CMPM",0,"NOP",0,"MULS",0,"DIVS",0
	dc.b	"ST",0,"SF",0,"SNE",0,"SEQ",0,"SPL",0,"SMI",0,"RTE",0,"ROL",0
	dc.b	"ROR",0,"ROXL",0,"ROXR",0,"TRAP",0,"ADDX",0,"SUBX",0,"NEGX",0,"TRAPV",0
	dc.b	"DBT",0,"DBHI",0,"DBLS",0,"DBHS",0,"DBLO",0,"DBCC",0,"DBCS",0,"DBVC",0
	dc.b	"DBVS",0,"DBPL",0,"DBMI",0,"DBGE",0,"DBLT",0,"DBGT",0,"DBLE",0,"SHI",0
	dc.b	"SLS",0,"SHS",0,"SLO",0,"SCC",0,"SCS",0,"SVC",0,"SVS",0,"SGE",0
	dc.b	"SLT",0,"SGT",0,"SLE",0,"ADDI",0,"ANDI",0,"CMPI",0,"EORI",0,"ORI",0
	dc.b	"SUBI",0,"ABCD",0,"SBCD",0,"NBCD",0,"RESET",0,"MOVEP",0,"RTR",0,"TAS",0
	dc.b	"DBRA",0,"CHK",0,"STOP",0,"LINEA",0,"LINEF",0,"ILLEGAL",0

	IFND	SMALLASS
	dc.b	"BKPT",0,"MOVEC",0,"MOVES",0,"RTD",0

	dc.b	"BFCHG",0,"BFCLR",0,"BFEXTS",0,"BFEXTU",0,"BFFFO",0,"BFINS",0
	dc.b	"BFSET",0,"BFTST",0,"CALLM",0,"RTM",0,"CAS",0,"CAS2",0
	dc.b	"CHK2",0,"CMP2",0,"DIVUL",0,"DIVSL",0,"PACK",0,"UNPK",0
	dc.b	"TRAPT",0,"TRAPF",0,"TRAPHI",0,"TRAPLS",0,"TRAPCC",0,"TRAPCS",0
	dc.b	"TRAPHS",0,"TRAPLO",0,"TRAPNE",0,"TRAPEQ",0,"TRAPVC",0,"TRAPVS",0
	dc.b	"TRAPPL",0,"TRAPMI",0,"TRAPGE",0,"TRAPLT",0,"TRAPGT",0,"TRAPLE",0
	dc.b	"EXTB",0
	dc.b	"MOVE16",0,"CINVL",0,"CINVP",0,"CINVA",0,"CPUSHL",0,"CPUSHP",0,"CPUSHA",0
	dc.b	"LPSTOP",0,"PLPAR",0,"PLPAW",0,"HALT",0,"PULSE",0
	dc.b	"FSAVE",0,"FRESTORE",0,"FADD",0,"FSADD",0,"FDADD",0,"FCMP",0
	dc.b	"FDIV",0,"FSDIV",0,"FDDIV",0,"FMOD",0,"FMUL",0,"FSMUL",0
	dc.b	"FDMUL",0,"FREM",0,"FSCALE",0,"FSUB",0,"FSSUB",0,"FDSUB",0
	dc.b	"FSGLDIV",0,"FSGLMUL",0,"FABS",0,"FSABS",0,"FDABS",0,"FACOS",0
	dc.b	"FASIN",0,"FATAN",0,"FATANH",0,"FCOS",0,"FCOSH",0,"FETOX",0,"FETOXM1",0
	dc.b	"FGETEXP",0,"FGETMAN",0,"FINT",0,"FINTRZ",0,"FLOG10",0,"FLOG2",0
	dc.b	"FLOGN",0,"FLOGNP1",0,"FNEG",0,"FSNEG",0,"FDNEG",0,"FSIN",0
	dc.b	"FSINH",0,"FSQRT",0,"FSSQRT",0,"FDSQRT",0,"FTAN",0,"FTANH",0
	dc.b	"FTENTOX",0,"FTWOTOX",0,"FMOVECR",0,"FNOP",0,"FSINCOS",0,"FTST",0
	dc.b	"FBF",0,"FBEQ",0,"FBOGT",0,"FBOGE",0,"FBOLT",0,"FBOLE",0
	dc.b	"FBOGL",0,"FBOR",0,"FBUN",0,"FBUEQ",0,"FBUGT",0,"FBUGE",0
	dc.b	"FBULT",0,"FBULE",0,"FBNE",0,"FBT",0,"FBSF",0,"FBSEQ",0
	dc.b	"FBGT",0,"FBGE",0,"FBLT",0,"FBLE",0,"FBGL",0,"FBGLE",0
	dc.b	"FBNGLE",0,"FBNGL",0,"FBNLE",0,"FBNLT",0,"FBNGE",0,"FBNGT",0
	dc.b	"FBSNE",0,"FBST",0
	dc.b	"FDBF",0,"FDBEQ",0,"FDBOGT",0,"FDBOGE",0,"FDBOLT",0,"FDBOLE",0
	dc.b	"FDBOGL",0,"FDBOR",0,"FDBUN",0,"FDBUEQ",0,"FDBUGT",0,"FDBUGE",0
	dc.b	"FDBULT",0,"FDBULE",0,"FDBNE",0,"FDBT",0,"FDBSF",0,"FDBSEQ",0
	dc.b	"FDBGT",0,"FDBGE",0,"FDBLT",0,"FDBLE",0,"FDBGL",0,"FDBGLE",0
	dc.b	"FDBNGLE",0,"FDBNGL",0,"FDBNLE",0,"FDBNLT",0,"FDBNGE",0,"FDBNGT",0
	dc.b	"FDBSNE",0,"FDBST",0
	dc.b	"FSF",0,"FSEQ",0,"FSOGT",0,"FSOGE",0,"FSOLT",0,"FSOLE",0
	dc.b	"FSOGL",0,"FSOR",0,"FSUN",0,"FSUEQ",0,"FSUGT",0,"FSUGE",0
	dc.b	"FSULT",0,"FSULE",0,"FSNE",0,"FST",0,"FSSF",0,"FSSEQ",0
	dc.b	"FSGT",0,"FSGE",0,"FSLT",0,"FSLE",0,"FSGL",0,"FSGLE",0
	dc.b	"FSNGLE",0,"FSNGL",0,"FSNLE",0,"FSNLT",0,"FSNGE",0,"FSNGT",0
	dc.b	"FSSNE",0,"FSST",0
	dc.b	"FTRAPF",0,"FTRAPEQ",0,"FTRAPOGT",0,"FTRAPOGE",0,"FTRAPOLT",0
	dc.b	"FTRAPOLE",0,"FTRAPOGL",0,"FTRAPOR",0,"FTRAPUN",0,"FTRAPUEQ",0
	dc.b	"FTRAPUGT",0,"FTRAPUGE",0,"FTRAPULT",0,"FTRAPULE",0,"FTRAPNE",0
	dc.b	"FTRAPT",0,"FTRAPSF",0,"FTRAPSEQ",0,"FTRAPGT",0,"FTRAPGE",0
	dc.b	"FTRAPLT",0,"FTRAPLE",0,"FTRAPGL",0,"FTRAPGLE",0,"FTRAPNGLE",0
	dc.b	"FTRAPNGL",0,"FTRAPNLE",0,"FTRAPNLT",0,"FTRAPNGE",0,"FTRAPNGT",0
	dc.b	"FTRAPSNE",0,"FTRAPST",0
	dc.b	"FMOVE",0,"FSMOVE",0,"FDMOVE",0,"FMOVEM",0
	dc.b	"PBBS",0,"PBBC",0,"PBLS",0,"PBLC",0,"PBSS",0,"PBSC",0
	dc.b	"PBAS",0,"PBAC",0,"PBWS",0,"PBWC",0,"PBIS",0,"PBIC",0
	dc.b	"PBGS",0,"PBGC",0,"PBCS",0,"PBCC",0
	dc.b	"PDBBS",0,"PDBBC",0,"PDBLS",0,"PDBLC",0,"PDBSS",0,"PDBSC",0
	dc.b	"PDBAS",0,"PDBAC",0,"PDBWS",0,"PDBWC",0,"PDBIS",0,"PDBIC",0
	dc.b	"PDBGS",0,"PDBGC",0,"PDBCS",0,"PDBCC",0
	dc.b	"PSBS",0,"PSBC",0,"PSLS",0,"PSLC",0,"PSSS",0,"PSSC",0
	dc.b	"PSAS",0,"PSAC",0,"PSWS",0,"PSWC",0,"PSIS",0,"PSIC",0
	dc.b	"PSGS",0,"PSGC",0,"PSCS",0,"PSCC",0
	dc.b	"PTRAPBS",0,"PTRAPBC",0,"PTRAPLS",0,"PTRAPLC",0,"PTRAPSS",0,"PTRAPSC",0
	dc.b	"PTRAPAS",0,"PTRAPAC",0,"PTRAPWS",0,"PTRAPWC",0,"PTRAPIS",0,"PTRAPIC",0
	dc.b	"PTRAPGS",0,"PTRAPGC",0,"PTRAPCS",0,"PTRAPCC",0
	dc.b	"PSAVE",0,"PRESTORE",0,"PFLUSHA",0,"PFLUSH",0,"PFLUSHS",0,"PFLUSHR",0
	dc.b	"PFLUSHN",0,"PFLUSHAN",0,"PLOADR",0,"PLOADW",0,"PMOVE",0,"PMOVEFD",0
	dc.b	"PTESTR",0,"PTESTW",0,"PVALID",0
	ENDC
	even


	end
