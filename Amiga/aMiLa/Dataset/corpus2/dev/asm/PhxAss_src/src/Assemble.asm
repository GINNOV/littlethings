; $VER: Assemble.asm 4.46 (30.12.14)
; **********************************************
;
;             PhxAss Macro Assembler
;
;        Written by Frank Wille, 1991-2014
;
;               Assembler-Routine
;
; **********************************************

; set GLOBALLOCALS ermöglicht die Adressierung von lokalen Symbolen über
; "global\.local" - dies kostet aber 2% Speed. 
GLOBALLOCALS	set	1		; always set, since V4.39

	far				; Large Code/Data-Model

	include	"AssDefs.i"		; Strukturen und Definitionen einlesen

	ttl	"PhxAss - Assembly routines"


; ************
; CODE-Segment
; ************

	section	PHXAss,code


; *** Cross-References ***

; ** XREFs **
; * von AssMain.o *
	xref	Error			; d0=ErrNum
	xref	FatalError		; (wie oben), kehrt aber nicht zurueck
	xref	CleanUp
	xref	GetMacNestList,GetSUT,GetMacParameter,GetLocalParts
	xref	GetSymbolTable,GetLocalSymbolTable
	xref	GetReferenceList,GetRegRefList,GetHunkData,GetLineDebugTab
	xref	GetHunkExtTable,GetHunkSymbolTable,GetHunkReloc
	xref	GetDistanceList,GetSection,GetSecList
	xref	GetLocalHashTable,GetLocalRegs	; ->d0=MemPtr
	xref	AddLongFloat		; d0=FloatPtr, ->d0=NewFloatPtr
	xref	AddString		; a0=String, ->d0=NewStringPtr
	xref	printf			; a0=FormatString, a1=DataStream
	xref	fprintf			; d0=FileHandle, a0=FormatString, a1=DataStream
	xref	DivMod			; d0=Dividend, d1=Divisor, ->d0=Quotient,d1=Remainder
	; (a0/a1 werden gerettet)
	xref	PageTitle
; * von AssCode.o *
	xref	GetEscSym		; d0=EscSym, ->d0=Code
	xref	CSeg
	xref	GetSectionPtr		; d2=SecNum, ->a0=Section
	xref	VerboseInfo		; a0=TypeString
	xref	ShowVDepth

; * von AssExtra.o *
	xref	GetFloatExpression
	xref	FloatConversion

; * von AssTexts.o *
	xref	DefStringBase		; Englische Default-Strings


; ** XDEFs **
	xdef	Pass_1,Pass_2		; a4=SourcePtr, d6.l=Adress, d7.l=SourceLen
	xdef	AddLineDebug		; d2.l=Offset, d3.l=Line
	xdef	AddSymbol		; a0=SymbolName, d0=Type, d1.l=Value
	xdef	AddRegName		; a0=SymbolName, d0=Reg
	xdef	GetValue		; a0=SourceString, ->d0/d1=Value, d2=Type/Section
	xdef	StrLen			; a0=String, ->d0=Len
	xdef	LocStr			; d0=StringID, -> a0=LocaleString
	xdef	AddExternal		; a0=Symbol
	xdef	CloseLocalPart

	xdef	FindLocalSymbol,FindSymbol,FindGorLSymbol ; a0=Name, ->d0=Symbol
	xdef	LineParts,ListSourceLine
	xdef	FPtoNextLine,CalcFPOffset
	xdef	UCaseStrCmp,StrCmp	; a0=Str1, a1=Str2 ->Z-Flag
	xdef	GetRegList		; a0=InputStream, ->d0=RegList, ->a0=NewInputPos
	xdef	GetRegister		; a0=Input, ->d0=Reg, d1=NumRegs, ->a0=NewInput
	xdef	AddDistance,ReplaceDistance ; a1=DistAddr, d0=Minuend,d1=Subtrahend
	xdef	ShiftLastDists		; d0=AddrOffset, d1=FPOffset
	xdef	DelLastDists
	xdef	AddReference		; a0=Symbolstruct, d0=RefType, d1=RefAddr
	xdef	ChangeLastRefs		; d0=NewRefType, d1=RefAddrOffset
	xdef	DelLastRefs
	xdef	ShiftPC			; d0=ShiftDelta
	xdef	ShiftRelocs		; a0=BaseAddr, d0=ShiftDelta
	xdef	ShiftRelocsNoOpt	; a0=BaseAddr, d0=ShiftDelta
	xdef	AddGorLSymbol		; a0=Name, d0=Type, d1.l=Value
	xdef	OpenLocalPart		; ->d0=FirstSymbolTab
	xdef	ReadArgument		; a0=SrcBuf, a1=DestBuf, d0=DestBufSize, ->d0=ReadBytes
	xdef	AddByte,AddWord,AddLong	; d0=Byte/Word/Longword
	xdef	AddDouble,AddExtended	; d0=Zeiger auf 64/96-Bit Fliesskomma
	xdef	AddCount		; d0=NumBytes
	xdef	AddHunkData
	xdef	MakeSection		; a0=SecName, d0=Type, ->a0=Section
	xdef	FindRegName		; a0=RegName, d0=Len, -> d0=Reg,d1


; *** Wichtig ***
; Wenn nicht anders vermerkt, wird bei allen Aufrufen immer angenommen, dass
; a5 auf PhxAssVars zeigt und a6 die ExecBase enthaelt.
; Hierbei enthaelt ausserdem noch a4 den aktuellen SourceCodePtr, d7 die
; verbleibende Laenge des Source-Codes und d6 den aktuellen Adr.Zeiger.


Pass_1:
; Diese Sub-Routine fuehrt einen ganzen Assemblierungs-Pass aus
; a4 = SourcePtr
; d6 = ActualAdress
; d7 = RemainingBytes
	bsr	LineParts		; Label(a2),Opcode(a3),Operand holen, a6=SUT
	IFND	FREEASS
	tst.b	ListEn(a5)
	beq.s	12$
	bsr	ListSourceLine		; Sourcetext-Zeile in Listing aufnehmen
	moveq	#-ASSLINECOLUMN-6,d0
	sub.w	sut_LineLen(a6),d0
	move.l	d0,FPOffset(a5)		; Offset um zum Zeilenanfang zurückzukommen
12$:
	ENDC
	move.l	d6,LineAddr(a5)
	clr.b	Local(a5)
	clr.b	RefFlag(a5)		; Noch keine Referenzen aufnehmen
	move.b	(a2),d0
	beq	p1_chkOpcode		; kein Label gesetzt ?
	IFND	DOTNOTLOCAL
	cmp.b	#'.',d0			; Local-Label ?
	seq	Local(a5)
	ENDIF
	move.w	sut_LabelLen(a6),d0
	lea	(a2,d0.w),a0
	cmp.b	#':',(a0)		; ':' hinter Label entfernen
	bne.s	2$
	clr.b	(a0)
	subq.l	#1,a0
	subq.w	#1,sut_LabelLen(a6)
2$:	cmp.b	#'$',(a0)		; Local-Label ?
	bne.s	3$
	clr.b	(a0)
	st	Local(a5)
3$:
	IFND	FREEASS
	move.w	MacroCnt(a5),d1		; Assembler im Macro-Mode ?
	beq.s	1$
	move.l	a2,a0			; LabelBuffer
	bsr	SearchMacroParam	; Macro-Parameter suchen und ersetzen
	ENDC
1$:	moveq	#0,d0
	lea	label1_tab(a5),a0	; Testen ob der Label gültige Zeichen enthält
	move.b	(a2)+,d0
	tst.b	(a0,d0.w)		; erstes Zeichen: 0-9 A-Z a-z _ @ .
	bmi.s	4$
	beq.s	9$			; ungültig?
	cmp.b	#'9',(a2)		; '@' darf von keiner Ziffer gefolgt werden
	bhi.s	5$
	bra.s	9$
4$:	cmp.b	#'9',d0			; Label beginnt mit Ziffer?
	bhi.s	5$
	cmp.b	#'0',d0
	blo.s	5$
	tst.b	Local(a5)		; nur mit 'nnn$' möglich
	beq.s	9$
5$:	lea	label2_tab(a5),a0	; Rest des Labels überprüfen: 0-9 A-Z a-z _ .
6$:	move.b	(a2)+,d0
	beq.s	p1_chkOpcode
	tst.b	(a0,d0.w)
	bne.s	6$
9$:	moveq	#22,d0			; Illegal characters in label
	bsr	Error
	moveq	#0,d0
	bra.s	5$

p1_chkOpcode:
	tst.b	(a3)			; Opcode vorhanden ?
	beq	p1_addlabel
	IFND	FREEASS
	move.w	MacroCnt(a5),d1		; Assembler im Macro-Mode ?
	beq.s	1$
	move.l	a3,a0			; OpcodeBuffer
	bsr	SearchMacroParam	; Macro-Parameter suchen und ersetzen
	ENDC
1$:	move.l	a3,a0			; Opcode in Großbuchstaben umwandeln
	moveq	#0,d0
	lea	ucase_tab(a5),a1
2$:	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	bne.s	2$
	moveq	#os_WORD,d0		; Default Size = .w
	move.w	OpcodeLen(a5),d2	; d2 Länge des Opcode-Strings
	cmp.w	#3,d2			; Mnemonic kürzer als 3 Zeichen ?
	blo.s	p1_chkOperand		;  (dann ist bestimmt keine Extension dran)
	lea	-2(a3,d2.w),a0
	cmp.b	#'.',(a0)		; hängt eine Extension am Mnemonic ?
	bne.s	p1_chkOperand
	clr.b	(a0)+			; Ext. aus dem OpcodeBuffer entfernen
	subq.w	#2,d2
	moveq	#$1f,d0
	and.b	(a0),d0			; Extension-Character
	move.b	p1_sizes(pc,d0.l),d0
	bpl.s	p1_chkOperand		; UNDEF ?
	moveq	#20,d0			; Illegal opcode extension
	bsr	Error
	moveq	#os_WORD,d0
	bra.s	p1_chkOperand
p1_sizes:
	; zugehörige Opcode-Sizes von '@'-'Z'
	IFND	SMALLASS
	dc.b	-1,-1,os_BYTE,-1,os_DOUBLE,-1,os_FFP,-1,-1,-1,-1,-1,os_LONG,-1,-1,-1
	dc.b	os_PACKED,os_DOUBLE,-1,os_SINGLE,-1,-1,-1,os_WORD,os_EXTENDED,-1,-1,-1,-1,-1,-1,-1
	ELSE
	dc.b	-1,-1,os_BYTE,-1,-1,-1,-1,-1,-1,-1,-1,-1,os_LONG,-1,-1,-1
	dc.b	-1,-1,-1,os_SINGLE,-1,-1,-1,os_WORD,-1,-1,-1,-1,-1,-1,-1,-1
	ENDC
	even

p1_chkOperand:
	move.b	d0,OpcodeSize(a5)
	move.b	d0,sut_OpSize(a6)
	IFND	FREEASS
	move.w	MacroCnt(a5),d1		; Assembler im Macro-Mode ?
	beq.s	p1_execOpcode
	lea	SrcOperBuffer(a5),a0
	tst.b	(a0)			; ueberhaupt ein Operand vorhanden ?
	beq.s	p1_execOpcode
	bsr	SearchMacroParam	; Operand steht jetzt auch im Work-Buffer
	ENDC

p1_execOpcode:
	move.l	a3,a0			; Mnemonic in HashTable suchen (d2 = Länge)
	HASHC	a0,d0,d1,d3		; Hashcode für Mnemonic berechnen > d0
	and.w	MnemHashMask(a5),d0
	lsl.l	#2,d0
	move.l	MnemoHashList(a5),a0	; Hash Table
	move.l	(a0,d0.l),d0		; mind. ein Mnemonic in der Hash Chain?
	beq.s	5$
1$:	move.l	d0,a2			; Hash Chain durchgehen...
	move.l	mnn_Name(a2),a0
	move.l	a3,a1
	move.w	d2,d0
2$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,2$
	beq.s	6$
	move.l	mnn_Next(a2),d0		; nächster Mnemonic in der Hash Chain?
	bne.s	1$
5$:
	IFND	FREEASS
	move.l	a3,a0			; keine bekannte Direktive oder Instruktion,
	bsr	FindMacro		;  dann kann's nur noch ein Macro sein...
	beq.s	7$
	st	sut_OpFlags(a6)		; Macro-Flag setzen
	move.l	d0,sut_OpcodePtr(a6)	; und Macro-Symbol speichern
	move.l	SysBase(a5),a6
	move.l	d0,a2
	bsr	ExecuteMacro
	bra.s	p1_addlabel
	ENDC
7$:	moveq	#23,d0			; Unknown directive
	bsr	Error
	bra.s	p1_addlabel
6$:	addq.l	#mnn_Function,a2
	move.l	a2,sut_OpcodePtr(a6)	; Adresse der Opcode-Node für Pass 2 merken
	move.l	SysBase(a5),a6
	move.l	(a2)+,a0		; Spezialroutine fuer Mnemonic
	move.w	(a2),d4			; ** d4 Parameter
	lea	LabelBuffer(a5),a2	; ** a2 Label
	lea	SrcOperBuffer(a5),a3	; ** a3 Operand
	st	TryPC(a5)
	moveq	#0,d5			; ** d5 Pass 1
	jsr	4(a0)			; Opcode-Speicherbedarf fuer Pass1 bestimmen
	tst.l	CurrentSec(a5)
	bne.s	p1_addlabel		; noch gar keine Section begonnen?
	move.l	d6,d2			;  und trotzdem code gefunden?
	beq.s	p1_addlabel
	moveq	#0,d4
	jsr	CSeg			; .. dann eine Code-Section öffnen
	move.l	d2,d6

p1_addlabel:
	move.l	SysBase(a5),a6
	tst.b	LabelBuffer(a5)		; ABS-Symbol speichern ?
	beq.s	p1_nextline
	lea	LabelBuffer(a5),a0
	moveq	#T_ABS,d0
	move.l	LineAddr(a5),d1		; Value = Adresse am Anfang der Zeile
	tst.b	Local(a5)
	beq.s	1$
	bsr	AddLocalSymbol
	bra.s	2$
1$:	bsr	AddSymbol
	bsr	CloseLocalPart
2$:
	IFND	FREEASS
	tst.b	AssMode(a5)		; am_MACRO?
	bmi.s	p1_nextline		; Label im Macro-Mode nicht entfernen
	ENDC
	move.l	CurrentSUTPos(a5),a0	; Label ist unwichtig für Pass 2
	st	sut_LabelLen(a0)
	move.l	myTask(a5),a0
	btst	#SIGBREAKB_CTRL_C-8,tc_SigRecvd+2(a0) ; Control-C gedrückt ?
	bne	AssTerm

p1_nextline:
	IFND	FREEASS
	tst.b	ListEn(a5)
	bne.s	p1_listfile
	ENDC
p1_nxtln:
	IFND	GIGALINES
	addq.w	#1,Line(a5)		; ** Nächste Sourcetext-Zeile **
	addq.w	#1,AbsLine(a5)
	beq.s	p1_fatal		; Zeile 65536 erreicht?
	ELSE
	addq.l	#1,Line(a5)		; ** Nächste Sourcetext-Zeile **
	addq.l	#1,AbsLine(a5)
	ENDC
p1_cont:
	tst.l	d7
	bne	Pass_1

	IFND	FREEASS
	tst.b	ReptDepth(a5)		; offene REPT-ENDR Schleife?
	beq.s	p1_finished
	moveq	#98,d0			; Missing ENDR
	bra	FatalError
	ELSE
	rts
	ENDC
p1_fatal:
	moveq	#83,d0			; Source-code too big , 65535 Zeilen ist max.
	bra	FatalError

	IFND	FREEASS
p1_listfile:
	bmi.s	p1_nxtln
	st	ListEn(a5)		; Filepointer nicht weitersetzen
	bra.s	p1_nxtln
	ENDC

p1_finished:
	IFND	FREEASS
	move.b	AssMode(a5),d3
	bne.s	8$			; Main-Sourcetext beendet, dann FERTIG !
	ENDC
	rts				; Pass 1 beendet!
	IFND	FREEASS
8$:	bmi.s	6$			; am_INC ?
	move.l	IncNest(a5),a2		; INCLUDE beendet
	bra.s	7$
6$:	move.l	MacNest(a5),a2		; MACRO beendet
7$:	sub.l	a1,a1
1$:	move.w	nl_Nest(a2),d0		; letzten NestList-Chunk suchen
	bpl.s	2$
	move.l	a2,a1
	move.l	(a2),a2
	bra.s	1$
2$:	move.l	a2,a0
	subq.w	#1,d0			; Nest-Counter vermindern
	move.w	d0,d2
	bne.s	3$
	clr.w	nl_Nest(a2)
	move.l	a1,d0			; =0? Dann Vorgaenger-Chunk auf hoechsten Wert
	beq.s	5$			;  ausser dies war der erste Chunk
	move.l	d0,a0
	tst.b	d3
	bpl.s	4$
	move.w	#MACNSTBLK/nlSIZE,d2
	bra.s	3$
4$:	move.w	#INCNSTBLK/nlSIZE,d2
3$:	move.w	d2,nl_Nest(a0)
5$:	move.l	nl_FreeEntry(a2),a0
	move.l	-(a0),AssModeName(a5)
	move.b	-(a0),ReptDepth(a5)
	move.b	-(a0),AssMode(a5)
	IFND	GIGALINES
	move.w	-(a0),Line(a5)
	ELSE
	move.l	-(a0),Line(a5)
	ENDC
	move.l	-(a0),d7
	move.l	-(a0),a4
	move.l	a0,nl_FreeEntry(a2)
	IFND	GIGALINES
	addq.w	#1,Line(a5)
	ELSE
	addq.l	#1,Line(a5)
	ENDC
	btst	#sw2_VERBOSE,Switches2(a5)
	beq	p1_cont			; nächste Zeile assemblieren
	subq.b	#1,VDepth(a5)
	bsr	ShowVDepth		; Einrücken
	lea	brkt_txt(pc),a0
	bsr	printf
	bra	p1_cont
brkt_txt:
	dc.b	"}\n",0
	even
	ENDC


AssTerm:
	LOCS	S_BREAK
	bsr	printf			; "*** BREAK - Assembly terminated"
	move.l	CleanUpLevel(a5),sp
	bra	CleanUp


	cnop	0,4
Pass_2:
; Diese Sub-Routine fuehrt einen ganzen Assemblierungs-Pass aus
; a4 = SourcePtr
; d6 = ActualAdress
; d7 = Remaining Source Length
	move.l	myTask(a5),a0
	btst	#SIGBREAKB_CTRL_C-8,tc_SigRecvd+2(a0) ; Control-C gedrueckt ?
	bne.s	AssTerm
	bsr	LineInfo		; Label,Opcode,Operand holen, a6 = SUTPtr
	IFND	FREEASS
	tst.b	ListEn(a5)
	beq.s	1$
	bsr	CalcFPOffset		; FPOffset berechnen
1$:
	ENDC
	move.l	CurrentSec(a5),d0
	beq.s	2$
	move.l	d0,a0
	move.b	sec_Flags(a0),OptFlag(a5)
2$:	move.l	d6,LineAddr(a5)
	clr.b	Local(a5)
	clr.b	RefFlag(a5)		; Noch keine Referenzen aufnehmen
	move.b	(a2),d0
	beq.s	p2_getOperand		; kein Label gesetzt ?
	IFND	DOTNOTLOCAL
	cmp.b	#'.',d0			; Local-Label ?
	seq	Local(a5)
	ENDIF
	move.w	sut_LabelLen(a6),d0
	cmp.b	#'$',(a2,d0.w)		; Local-Label ?
	bne.s	3$
	clr.b	(a2,d0.w)
	st	Local(a5)
3$:
	IFND	FREEASS
	move.w	MacroCnt(a5),d1		; Assembler im Macro-Mode ?
	beq.s	p2_getOperand
	move.l	a2,a0			; LabelBuffer
	bsr	SearchMacroParam	; Macro-Parameter suchen und ersetzen
	ENDC

p2_getOperand:
	IFND	FREEASS
	move.w	MacroCnt(a5),d1		; Assembler im Macro-Mode ?
	beq.s	1$
	tst.b	(a3)			; ueberhaupt ein Operand vorhanden ?
	beq.s	1$
	move.l	a3,a0
	bsr	SearchMacroParam	; Operand steht jetzt auch im Work-Buffer
1$:
	ENDC

	move.l	sut_OpcodePtr(a6),d0
	beq.s	p2_nextline		; Opcode vorhanden?
	move.b	sut_OpSize(a6),OpcodeSize(a5)
	IFND	FREEASS
	tst.b	sut_OpFlags(a6)
	beq.s	2$			; Macro oder Instruktion?
	move.l	SysBase(a5),a6
	move.l	d0,a2
	st	RefFlag(a5)
	move.l	a2,a0
	moveq	#0,d0			; kein RefType noetig
	move.l	d6,d1
	bsr	AddReference		; Referenz auf Macro merken
	bsr	ExecuteMacro		; und Macro ausführen
	bra.s	p2_nextline
2$:
	ENDC
	move.l	SysBase(a5),a6
	move.l	d0,a0
	move.l	(a0)+,a1		; Pass 2 - Routine für Mnemonic
	move.w	(a0),d4			; ** d4 Parameter, a2 Label, a3 Operand
	st	TryPC(a5)
	move.w	#12,ListFileOff(a5)
	moveq	#1,d5			; Pass 2 Kennung
	clr.w	LastDistCnt(a5)
	clr.w	LastRelocCnt(a5)
	clr.w	LastRefCnt(a5)
	jsr	(a1)			; Opcode fuer Pass2 übersetzen

p2_nextline:
	move.l	SysBase(a5),a6
	IFND	FREEASS
	tst.b	ListEn(a5)
	bne.s	p2_listfile
	ENDC
p2_2:
	btst	#sw2_LINEDEBUG,Switches2(a5) ; LineDebug-Informationen erzeugen?
	bne.s	p2_linedebug
p2_6:
	IFND	GIGALINES
	addq.w	#1,Line(a5)		; ** Nächste Sourcetext-Zeile **
	addq.w	#1,AbsLine(a5)
	ELSE
	addq.l	#1,Line(a5)
	addq.l	#1,AbsLine(a5)
	ENDC
p2_cont:
	tst.l	d7
	bne	Pass_2

	IFND	FREEASS
	move.b	AssMode(a5),d3
	bne	p2_reNest		; Include/Macro-Nesting beenden?
	ENDC
	rts				; Pass 2 beendet!

	IFND	FREEASS
p2_listfile:
	bmi.s	3$
	st	ListEn(a5)		; Filepointer nicht weitersetzen
	bra.s	p2_2
3$:	bsr	FPtoNextLine		; Pass2: Filepointer auf Zeilenanfang
	bra.s	p2_2
	ENDC
p2_linedebug:
	IFND	FREEASS
	tst.b	AssMode(a5)		; und keine Includes oder Macros beachten
	bne.s	p2_6
	ENDC
	move.l	d6,d0
	move.l	LineAddr(a5),d2
	sub.l	d2,d0			; kein Code in dieser Zeile erzeugt?
	beq.s	p2_6
	IFND	GIGALINES
	moveq	#0,d3
	move.w	Line(a5),d3
	ELSE
	move.l	Line(a5),d3
	ENDC
	bsr	AddLineDebug		; Zeilennummer mit dazugeh. Offset speich.
	bra.s	p2_6

	cnop	0,4
AddLineDebug:
; d2 = Section Offset
; d3 = Source Line
; a2 wird zerstört!
	move.l	CurrentSec(a5),a0
	move.l	sec_HunkLineDebug(a0),d0
1$:	move.l	d0,a2
	move.l	lindb_Link(a2),d0	; zum letzten Chunk hangeln
	bne.s	1$
	move.l	lindb_Ptr(a2),d0	; noch ein Slot frei?
	bne.s	2$
	bsr	GetLineDebugTab		; neuen Chunk besorgen und verketten
	move.l	d0,lindb_Link(a2)
	bra.s	1$
2$:	move.l	d0,a0			; Zeilennummer und Section-Offset speichern
	move.l	d3,(a0)+
	move.l	d2,(a0)+
	lea	lindb_HEAD+LINEDEBUGBLK(a2),a1
	cmp.l	a1,a0			; Chunk jetzt voll?
	blo.s	9$
	sub.l	a0,a0
9$:	move.l	a0,lindb_Ptr(a2)
	rts


	IFND	FREEASS
p2_reNest:
	bmi.s	6$			; am_INC ?
	move.l	IncNest(a5),a2		; INCLUDE beendet
	bra.s	7$
6$:	move.l	MacNest(a5),a2		; MACRO beendet
7$:	sub.l	a1,a1
1$:	move.w	nl_Nest(a2),d0		; letzten NestList-Chunk suchen
	bpl.s	2$
	move.l	a2,a1
	move.l	(a2),a2
	bra.s	1$
2$:	move.l	a2,a0
	subq.w	#1,d0			; Nest-Counter vermindern
	move.w	d0,d2
	bne.s	3$
	clr.w	nl_Nest(a2)
	move.l	a1,d0			; =0? Dann Vorgaenger-Chunk auf hoechsten Wert
	beq.s	5$			;  ausser dies war der erste Chunk
	move.l	d0,a0
	tst.b	d3
	bpl.s	4$
	move.w	#MACNSTBLK/nlSIZE,d2
	bra.s	3$
4$:	move.w	#INCNSTBLK/nlSIZE,d2
3$:	move.w	d2,nl_Nest(a0)
5$:	move.l	nl_FreeEntry(a2),a0
	move.l	-(a0),AssModeName(a5)
	move.b	-(a0),ReptDepth(a5)
	move.b	-(a0),AssMode(a5)
	IFND	GIGALINES
	move.w	-(a0),Line(a5)
	ELSE
	move.l	-(a0),Line(a5)
	ENDC
	move.l	-(a0),d7
	move.l	-(a0),a4
	move.l	a0,nl_FreeEntry(a2)
	IFND	GIGALINES
	addq.w	#1,Line(a5)
	ELSE
	addq.l	#1,Line(a5)
	ENDC
	btst	#sw2_VERBOSE,Switches2(a5)
	beq	p2_cont			; nächste Zeile assemblieren
	subq.b	#1,VDepth(a5)
	bsr	ShowVDepth		; Einrücken
	lea	brkt_txt(pc),a0
	bsr	printf
	bra	p2_cont


	cnop	0,4
CalcFPOffset:
; Offset auf Filepointer berechnen, um am Anfang der nächsten Zeile
; weitermachen zu koennen
; a6 = SUTPtr
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	move.l	ListFileHandle(a5),d1
	moveq	#0,d2
	moveq	#OFFSET_CURRENT,d3
	jsr	Seek(a6)		; aktuellen FilePointer holen
	move.l	(sp)+,a6
	move.b	#ASSLINECOLUMN,Columns(a5)
	moveq	#ASSLINECOLUMN+6,d1
	add.w	sut_LineLen(a6),d1
	add.l	d1,d0
	move.l	d0,FPOffset(a5)		; Filepointer auf nächste Zeile
	rts


	cnop	0,4
FPtoNextLine:
; Filepointer auf den Anfang der naechsten Zeile setzen
	move.l	a6,a2
	move.l	DosBase(a5),a6		; Filepointer auf Anfang der naechsten
	move.l	FPOffset(a5),d2		;  Listing-Zeile setzen
	moveq	#OFFSET_BEGINNING,d3
	move.b	PageLine(a5),d0
	addq.b	#1,d0
	move.b	PageLength(a5),d1
	beq.s	3$			; unendlich lange Seiten ?
	cmp.b	d1,d0
	bne.s	3$
	add.l	SeekTitleOffset(a5),d2	; Ueberschrift und FormFeed ueberspringen
	moveq	#2,d0
3$:	move.b	d0,PageLine(a5)
	move.l	ListFileHandle(a5),d1
	jsr	Seek(a6)		; Filepointer bewegen
	move.l	a2,a6
	rts


	cnop	0,4
ExecuteMacro:
; Macro Parameter bestimmen und den SourcePtr auf das Macro setzten
; a2 = Macro-Symbol
	lea	MacNest(a5),a1
9$:	move.l	(a1),a1
	move.w	nl_Nest(a1),d5		; d5= Mac-Chunk Entries
	bmi.s	9$			; negativ ?  Dann ist der Chunk voll !
	move.l	a1,-(sp)		; MacNestList-Chunk retten
	move.l	MacParaPtr(a5),d0	; erster MacParameter-Chunk
	move.l	#MACPARBLK,d2
	move.w	MacroCnt(a5),d1
	addq.w	#1,MacroCnt(a5)
	mulu	#MACDEPTHSIZE,d1
1$:	move.l	d0,a3
	cmp.l	d2,d1			; richtigen Chunk erreicht ?
	blo.s	2$
	sub.l	d2,d1
	move.l	(a3),d0
	bne.s	1$
	bsr	GetMacParameter		; neuen Macro-Parameter Chunk anlegen
	move.l	d0,(a3)
	bra.s	1$
2$:	lea	mpar_HEAD(a3,d1.l),a3
	move.l	symNARG(a5),a0
	move.l	sym_Value(a0),(a3)+	; letzer NARG-Wert -> mpar_LastNARG
	move.l	symCARG(a5),a0
	move.l	sym_Value(a0),(a3)+	; letzer CARG-Wert -> mpar_LastCARG
	move.l	ActMacLabel(a5),(a3)+	; \@-Zustand merken -> mpar_LastLabel

	lea	SizesTxt(pc),a0		; Opcode-Size als Parameter \0 eintragen
	move.b	OpcodeSize(a5),d0
	ext.w	d0
	move.b	(a0,d0.w),(a3)+
	clr.b	(a3)
	lea	MACPARSIZE(a3),a3
	moveq	#MAXMACPAR-1,d1
	move.l	a3,a1
21$:	; Parameter \1 - \9, \A - \Z löschen
	clr.b	(a1)
	lea	MACPARSIZE+1(a1),a1
	dbf	d1,21$
	lea	SrcOperBuffer(a5),a0
	moveq	#MAXMACPAR,d4
	moveq	#MAXMACPAR-1,d3		; Zählt die Parameter
	move.l	#$00270022,d2		; ' und "
	moveq	#',',d1
3$:	move.l	a3,a1
	lea	MACPARSIZE+1(a3),a3
4$:	move.b	(a0)+,d0
	move.b	d0,(a1)+
	beq	mx_ok			; keiner mehr da ?
	cmp.b	d2,d0
	beq.s	5$
	swap	d2
	cmp.b	d2,d0
	beq.s	5$			; ' oder " ?
	cmp.b	#'<',d0			; < ... > ?
	beq.s	51$
	sub.b	d1,d0			; ',' Komma ?
	beq.s	7$
	addq.b	#4,d0			; '(' Beginn einer indir. Adressierung o.ä. ?
	beq.s	6$
40$:	move.w	d3,d4
41$:	cmp.l	a3,a1
	blo.s	4$
	bra.s	10$			; overflow
5$:	move.w	d3,d4
50$:	cmp.l	a3,a1			; Overflow ?
	bhs.s	10$
	move.b	(a0)+,d0		; String-Konstante kopieren
	move.b	d0,(a1)+
	beq.s	mx_ok
	cmp.b	d2,d0
	bne.s	50$
	cmp.b	(a0),d2			; "" oder '' ?  Weitermachen.
	bne.s	41$
	cmp.l	a3,a1			; Overflow ?
	bhs.s	10$
	move.b	(a0)+,(a1)+
	bra.s	50$
51$:	cmp.b	#'<',(a0)		; << ist ein Operator
	bne.s	52$
	cmp.l	a3,a1
	bhs.s	10$
	move.b	(a0)+,(a1)+
	bra.s	40$
52$:	moveq	#'>',d1
	subq.l	#1,a1			; '<' verschlucken
	move.w	d3,d4
53$:	cmp.l	a3,a1			; Overflow ?
	bhs.s	10$
	move.b	(a0)+,d0		; <...> kopieren
	move.b	d0,(a1)+
	beq.s	mx_ok
	cmp.b	d1,d0			; > ?
	bne.s	53$
	cmp.b	(a0),d1			; >> ?  Dann weitermachen.
	beq.s	54$
	subq.l	#1,a1
	moveq	#',',d1
	bra.s	41$
54$:	cmp.l	a3,a1			; Overflow ?
	bhs.s	10$
	move.b	(a0)+,(a1)+
	bra.s	53$
6$:	move.w	d3,d4
	moveq	#0,d1
61$:	addq.w	#1,d1
62$:	cmp.l	a3,a1
	bhs.s	10$
	move.b	(a0)+,d0		; Term kopieren
	move.b	d0,(a1)+
	beq.s	mx_ok
	sub.b	#'(',d0			; '(' noch 'ne Klammerebene?
	beq.s	61$
	subq.b	#1,d0			; ')' Klammerebene beendet?
	bne.s	62$
	subq.w	#1,d1
	bne.s	62$			; letzte Klammerebene?
	moveq	#',',d1
	bra.s	41$
7$:	clr.b	-(a1)
	dbf	d3,3$
	moveq	#24,d0			; Zu viele Parameter (hoechstens 35 ;)
	bra.s	11$
10$:	clr.b	-(a1)
	moveq	#77,d0			; Parameter buffer overflow
11$:	bsr	Error

mx_ok:
	moveq	#MAXMACPAR,d1
	sub.w	d4,d1			; Zahl der Parameter in NARG speichern
	IFND	GIGALINES
	move.w	AbsLine(a5),d0
	ELSE
	move.l	AbsLine(a5),d0
	ENDC
	move.l	symNARG(a5),a0
	move.l	d1,sym_Value(a0)
	IFND	GIGALINES
	move.w	d0,sym_DeclLine(a0)
	ELSE
	move.l	d0,sym_DeclLine(a0)
	ENDC
	move.l	symCARG(a5),a0		; CARG auf 1 setzen
	moveq	#1,d1
	move.l	d1,sym_Value(a0)
	IFND	GIGALINES
	move.w	d0,sym_DeclLine(a0)
	ELSE
	move.l	d0,sym_DeclLine(a0)
	ENDC
	move.l	(sp)+,a3		; MacNestList-Struktur
	move.l	nl_FreeEntry(a3),a0
	move.l	a4,(a0)+		; SrcPtr, Länge und Zeilennr. merken
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
	addq.w	#1,d5			; ChunkEntryCnt erhoehen
	cmp.w	#MACNSTBLK/nlSIZE,d5
	blo.s	1$			; Chunk voll ?
	move.l	(a3),d0
	bne.s	3$
	bsr	GetMacNestList		; Speicher fuer neuen MacNest-Chunk besorgen
	move.l	d0,(a3)			; linken mit Vorgaenger
3$:	move.w	#-1,nl_Nest(a3)		; Vorgaender als Voll kennzeichnen
	move.l	d0,a3
	moveq	#0,d5
1$:	move.w	d5,nl_Nest(a3)		; neuen Nest-Wert speichern
	lea	MacLabel+3(a5),a0
	move.b	(a0),d0
	cmp.b	#'9',d0
	blo.s	2$
	move.b	#'0',(a0)
	move.b	-(a0),d0
	cmp.b	#'9',d0
	blo.s	2$
	move.b	#'0',(a0)
	move.b	-(a0),d0
	cmp.b	#'9',d0
	blo.s	2$
	move.b	#'0',(a0)
	move.b	-(a0),d0
	cmp.b	#'9',d0
	blo.s	2$
	moveq	#$2f,d0
2$:	addq.b	#1,d0
	move.b	d0,(a0)
	move.l	MacLabel(a5),ActMacLabel(a5)
	move.l	sym_Value(a2),a4	; SourcePtr auf Macro setzen
	moveq	#-1,d7			; Länge ist belanglos (bis ENDM)
	move.b	#am_MACRO,AssMode(a5)
	move.l	sym_Name(a2),AssModeName(a5) ; Macro-Name merken
	IFND	GIGALINES
	clr.w	Line(a5)		; Zähler beginnt wieder bei Zeile 1
	ELSE
	clr.l	Line(a5)
	ENDC
	btst	#sw2_VERBOSE,Switches2(a5)
	bne.s	5$
	rts
5$:	lea	macro_dir(pc),a0
	bra	VerboseInfo

SizesTxt:
	dc.b	"BWLFSDXP",0
macro_dir:
	dc.b	"macro",0


	cnop	0,4
SearchMacroParam:
; Sucht einen Buffer nach Macro-Parametern ( \? ) durch, und ersetzt sie
; gegebenenfalls
; a0 = SearchBuffer
; d1 = MacroCnt (ist immer mindestens 1)
	movem.l	d2-d6/a2-a4,-(sp)
	subq.w	#1,d1
	move.l	a0,a2
	move.l	MacParaPtr(a5),a1	; erster MacParameter-Chunk
	move.l	#MACPARBLK,d2
	mulu	#MACDEPTHSIZE,d1
1$:	cmp.l	d2,d1			; richtigen Chunk erreicht ?
	blo.s	2$
	sub.l	d2,d1
	move.l	(a1),a1
	bra.s	1$
2$:	lea	mpar_Params(a1,d1.l),a1	; Zeiger auf die Parameter dieses Nestings
	moveq	#0,d3			; Flag, ob überhaupt ein Param. da war
	moveq	#ESCSYM,d2
	move.l	#$00270022,d4		; ' "
	lea	Buffer(a5),a3
	move.l	#BUFSIZE-2,d6
	add.l	a3,d6

smp_Loop:
	cmp.l	d6,a3
	bhi.s	11$
	move.b	(a0)+,d0
	cmp.b	d2,d0			; Macro-Parameter ?
	beq	1$
10$:	move.b	d0,(a3)+		; unverändert in Buffer übernehmen
	beq	smp_finished
	cmp.b	d4,d0			; String?
	beq.s	12$
	swap	d4
	cmp.b	d4,d0
	bne.s	smp_Loop

12$:	cmp.l	d6,a3			; String kopieren
	bhi.s	11$
	move.b	(a0)+,d0
	cmp.b	d2,d0			; Parameter oder Escape Symbol?
	beq.s	5$
	move.b	d0,(a3)+
	beq	smp_finished
	cmp.b	d4,d0			; Stringende?
	bne.s	12$
	cmp.b	(a0),d4			; '' oder "" ?
	beq.s	52$
	bra.s	smp_Loop
11$:	moveq	#77,d0			; Parameter Buffer Overflow
	bsr	Error
	bra.s	smp_exit
5$:	move.b	(a0)+,d0
	beq.s	10$
	cmp.b	#'0',d0			; \0 bis \9 gehen als MacroParams durch
	blo.s	53$
	cmp.b	#'9',d0
	bhi.s	51$
	bsr	smp_copyParam
	bra.s	12$
53$:	bsr	smp_dynParam
	beq.s	12$
51$:	move.b	d2,(a3)+		; Escape-Code übernehmen '\x'
52$:	cmp.l	d6,a3
	bhi.s	11$
	move.b	d0,(a3)+
	bra.s	12$

1$:	move.b	(a0)+,d0		; Parameter Nummer testen
	beq.s	10$
	cmp.b	#'0',d0
	bhs.s	3$
	bsr	smp_dynParam
	beq	smp_Loop
2$:	moveq	#21,d0			; Illegal macro parameter
	bsr	Error
	bra	smp_Loop

3$:	cmp.b	#'9',d0
	bls.s	4$
	cmp.b	#'@',d0			; MacLabel einsetzen ?
	bhi.s	31$
	bne.s	2$
	moveq	#-1,d3
	move.b	#'_',(a3)+		; _0000 einsetzen
	lea	ActMacLabel(a5),a4
	bsr	smp_copyLoop
	bra	smp_Loop
31$:	and.b	#$df,d0
	cmp.b	#'Z',d0			; Parameter \A-\Z ?
	bhi.s	2$
	sub.b	#'A'-'0'-10,d0
4$:	bsr	smp_copyParam
	bra	smp_Loop

smp_dynParam:				; dynamischen Macro Param. ersetzen
; -> d0!=0 : war weder \+, \-, noch \.
	move.l	symCARG(a5),a4
	moveq	#'0',d1
	add.b	sym_Value+3(a4),d1
	sub.b	#'+',d0			; \+ , \- oder \. ?
	bne.s	1$
	addq.l	#1,sym_Value(a4)
	bra.s	3$
1$:	subq.b	#2,d0
	bne.s	2$
	subq.l	#1,sym_Value(a4)
	bra.s	3$
2$:	subq.b	#1,d0
	beq.s	3$
	moveq	#-1,d0			; Illegal macro parameter
	rts
3$:	move.b	d1,d0

smp_copyParam:
; d0=ParCode, a1=ParBuf
;@@@ move.l	 symNARG(a5),a4
;@@@ Vergleich der Par.Nummer mit NARG ist nicht sinnvoll (?)
	moveq	#-1,d3
	sub.b	#'0',d0
	bmi.s	smp_copyErr
	ext.w	d0
	cmp.w	#MAXMACPAR,d0
;@@@ cmp.w	 sym_Value+2(a4),d0
	bhi.s	smp_copyErr
	IFEQ	MACPARSIZE-127
	lsl.w	#7,d0
	ELSE
	mulu	#MACPARSIZE+1,d0
	ENDC
	lea	(a1,d0.w),a4
smp_copyLoop:
	cmp.l	d6,a3			; overflow?
	bhi.s	1$
	move.b	(a4)+,(a3)+		; Parameter-Text anhängen
	bne.s	smp_copyLoop
	subq.l	#1,a3
1$:	rts
smp_copyErr:
	moveq	#21,d0			; Illegal macro parameter
	bsr	Error
	move.l	a1,a4
	bra.s	smp_copyLoop

smp_finished:
	tst.w	d3			; War ein Param. im Buffer enthalten ?
	beq.s	smp_exit
	move.l	a2,a1
	lea	Buffer(a5),a0		; Alles aus dem Arbeitsbuffer zurückkopieren
1$:	move.b	(a0)+,(a1)+
	bne.s	1$
	lea	OpcodeBuffer(a5),a0
	cmp.l	a0,a2			; OpcodeBuffer wurde verändert?
	bne.s	smp_exit
	move.l	a1,d0
	sub.l	a2,d0
	subq.w	#1,d0
	move.w	d0,OpcodeLen(a5)
smp_exit:
	movem.l	(sp)+,d2-d6/a2-a4
	rts


	cnop	0,4
FindMacro:
; Sucht in der globalen Symbol-Tabelle nach dem  gewuenschten Namen mit
; gesetztem MACRO-Flag, und gibt die Adresse des Macro-Sourcetexts zurueck.
; a0 = MacroName
; -> d0 = Macro-Symbolstruktur
	bsr	FindSymbol
	beq.s	1$
	move.l	d0,a0
	move.w	sym_Type(a0),d0
	and.w	#T_MACRO,d0		; ist das Symbol auch ein Macro-Symbol ?
	beq.s	1$
	move.l	a0,d0
1$:	rts
	ENDC


	cnop	0,4
FindGorLSymbol:
; a0 = SymbolName, -> d0 = Symbol (oder 0)
	move.l	a0,a1
	IFND	FREEASS
	tst.b	IgnoreCase(a5)		; Nur Grossbuchstaben?
	beq.s	3$
	move.l	a0,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	lea	ucase_tab(a5),a0
1$:	addq.w	#1,d0
	move.b	(a1),d1
	move.b	(a0,d1.w),(a1)+
	bne.s	1$
	subq.w	#1,d0
	move.l	(sp)+,a0
	bra.s	5$
	ENDC
3$:	moveq	#-1,d0
4$:	tst.b	(a1)+
	dbeq	d0,4$
	not.w	d0			; SymbolName-Laenge
5$:
	IFND	DOTNOTLOCAL
	cmp.b	#'.',(a0)
	beq.s	FindLocalSymbolLen	; Local-Symbol ?
	ENDIF
	subq.l	#2,a1
	cmp.b	#'$',(a1)		; Local-Symbol ?
	bne.s	FindSymbolLen
	clr.b	(a1)
	subq.w	#1,d0			; durch fehlendes '$'

FindLocalSymbolLen:
; a0 = SymbolName, d0 = SymbolLen, -> d0 = Symbol (oder 0)
	movem.l	d2-d4/a2-a4,-(sp)
	move.l	a0,a4
	move.w	d0,d4
	bra	fls_lenOK

FindSymbolLen:
; a0 = SymbolName, d0 = SymbolLen, -> d0 = Symbol (oder 0)
	movem.l	d2-d3/a2-a3,-(sp)
	move.l	a0,a2
	move.w	d0,d2
	bra.s	FSym_lenOK


	cnop	0,4
FindSymbol:
; Bestimmt die Adresse der Symbolstruktur zum gegebenen Symbol-Namen
; a0 = SymbolName
; -> d0 = Symbol (oder 0, wenn es nicht existiert)
; -> d1 = DeclHunk
	movem.l	d2-d3/a2-a3,-(sp)
	move.l	a0,a2			; a2: SymbolName
	IFND	FREEASS
	tst.b	IgnoreCase(a5)		; Nur Großbuchstaben?
	beq.s	3$
	moveq	#0,d2
	moveq	#0,d0
	lea	ucase_tab(a5),a1
1$:	addq.w	#1,d2
	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	bne.s	1$
	subq.w	#1,d2
	bra.s	FSym_lenOK
	ENDC
3$:	moveq	#-1,d2
4$:	tst.b	(a0)+			; d2: Länge des gesuchten Symbols
	dbeq	d2,4$
	not.w	d2
FSym_lenOK:
	beq.s	3$			; Länge=0 ? Symbol kann nicht gefunden werden
	move.l	a2,a0
	HASHC	a0,d0,d1,d3		; Hashcode für dieses Symbol berechnen > d0
	and.w	GloHashMask(a5),d0
	lsl.l	#2,d0
	move.l	SymHashList(a5),a0	; Hash Table
	move.l	(a0,d0.l),d0		; mind. ein Symbol in der Hash Chain?
	beq.s	3$
1$:	move.l	d0,a3			; Hash Chain durchgehen...
	move.l	sym_Name(a3),a0		; Symbol Name
	move.l	a2,a1			;  mit gesuchtem vergleichen
	move.w	d2,d0
2$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,2$
	beq.s	4$
	move.l	sym_Next(a3),d0		; nächstes Symbol in der Hash Chain?
	bne.s	1$
3$:	moveq	#0,d0			; Symbol doesn't exist
	bra.s	9$
4$:	move.l	sym_RefList(a3),a0	; DeclHunk des Symbol lesen
	move.w	rlist_DeclHunk(a0),d1
	move.l	a3,d0			; Zeiger auf Symbolstruktur
9$:	movem.l	(sp)+,d2-d3/a2-a3
	rts


	cnop	0,4
FindLocalSymbol:
; Bestimmt die Adresse der Symbolstruktur zum gegebenen Symbol-Namen
; a0 = SymbolName
; -> d0 = Symbol (oder 0, wenn es nicht existiert)
; -> d1 = DeclHunk
	movem.l	d2-d4/a2-a4,-(sp)
	move.l	a0,a4			; a4: SymbolName
	IFND	FREEASS
	tst.b	IgnoreCase(a5)		; Nur Großbuchstaben?
	beq.s	3$
	moveq	#0,d4
	moveq	#0,d0
	lea	ucase_tab(a5),a1
1$:	addq.w	#1,d4
	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	bne.s	1$
	subq.w	#1,d4
	bra.s	fls_lenOK
	ENDC
3$:	moveq	#-1,d4
4$:	tst.b	(a0)+			; d4: Länge des gesuchten Symbols
	dbeq	d4,4$
	not.w	d4
fls_lenOK:
	beq.s	13$			; Länge=0? Symbol kann nicht gefunden werden
	bsr.s	FindLocalPart		; -> a0 = HashTable
	beq.s	fls_exit
10$:	move.l	d0,a1
	move.l	lp_SymTab(a1),a1
	move.w	lstab_DeclHunk(a1),d1	; DeclHunk auslesen
	move.l	a4,a1
	HASHC	a1,d0,d2,d3		; Hashcode für dieses Symbol berechnen > d0
	and.w	LocHashMask(a5),d0
	lsl.l	#2,d0
	move.l	(a0,d0.l),d0		; mind. ein Symbol in der Hash Chain?
	beq.s	13$
11$:	move.l	d0,a2			; Hash Chain durchgehen...
	move.l	sym_Name(a2),a0		; Symbol Name
	move.l	a4,a1			;  mit gesuchtem vergleichen
	move.w	d4,d0
12$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,12$
	beq.s	14$
	move.l	sym_Next(a2),d0		; nächstes Symbol in der Hash Chain?
	bne.s	11$
13$:	sub.l	a2,a2			; Symbol doesn't exist
14$:	move.l	a2,d0			; Zeiger auf Symbol zurückgeben
fls_exit:
	movem.l	(sp)+,d2-d4/a2-a4
	rts

	cnop	0,4
FindLocalPart:
; LocalPart zur augenblicklichen AbsLine suchen. Falls vorhanden, wird der
; Zeiger auf die HashTable des Parts zurückgegeben.
; *** d2 und d3 werden zerstört! ***
; -> d0 = LocalPart
; -> a0 = HashTable des Parts
	IFND	GIGALINES
	move.w	AbsLine(a5),d2
	ELSE
	move.l	AbsLine(a5),d2
	ENDC
	move.l	LocPartsPtr(a5),d0	; LocalPart zur aktuellen Zeile suchen
1$:	move.l	d0,a1
	lea	lp_HEAD(a1),a0
	move.w	lp_NumParts(a1),d3	; zu testende Parts in diesem Chunk
	subq.w	#1,d3
	bmi.s	4$
2$:
	IFND	GIGALINES
	move.w	(a0)+,d0		; StartLine, EndLine des Parts holen
	move.w	(a0)+,d1
	cmp.w	d2,d0
	bhi.s	3$			; aktuelle Zeilennr muss dazwischen liegen
	cmp.w	d2,d1
	blo.s	3$
	ELSE
	move.l	(a0)+,d0		; StartLine, EndLine des Parts holen
	move.l	(a0)+,d1
	cmp.l	d2,d0
	bhi.s	3$			; aktuelle Zeilennr muss dazwischen liegen
	cmp.l	d2,d1
	blo.s	3$
	ENDC
	moveq	#-lp_SymTab,d0
	add.l	a0,d0			; LocalPart
	move.l	lp_HashTab-lp_SymTab(a0),a0 ; LocalHashTable
	rts
3$:	lea	lpSIZE-lp_SymTab(a0),a0
	dbf	d3,2$			; nächsten LocalPart pruefen
	move.l	(a1),d0
	bne.s	1$			; noch ein Chunk ?
4$:	moveq	#0,d0			; nicht gefunden
	rts


	cnop	0,4
LineParts:
	; PASS 1
; Trennt eine SourceCode-Zeile in Label, Opcode und Operand auf und speichert
; diese getrennt ab. Die StartAdr der Zeile wird vermerkt und der SourcePtr
; steht hiernach auf dem Anfang der Folge-Zeile (falls es eine gibt).
; a4 = Zeiger auf aktuelle Zeile
; -> a2 = LabelBuffer
; -> a3 = OpcodeBuffer
; -> a4 = Anfang der nächsten Zeile
; -> a6 = SpeedUpTab-Ptr
	movem.l	CurrentSUT(a5),a2-a3	; CurrentSUT/SUTPos
	cmp.l	sut_Last(a2),a3
	bne.s	4$
	bsr	GetSUT
	move.l	d0,a0
	move.l	a0,sut_Link(a2)
	lea	sut_HEAD-sutSIZE(a0),a1
	movem.l	a0-a1,CurrentSUT(a5)
4$:	move.l	a3,a6			; a6 SpeedUpTab Entry
	move.l	a6,CurrentSUTPos(a5)
	moveq	#sutSIZE,d0
	add.l	d0,SUTPos(a5)
	move.l	a4,LineBase(a5)
	move.l	a4,d2			; d2 BaseAdr dieser Zeile
	moveq	#0,d3
	lea	OpcodeBuffer(a5),a3
	clr.b	(a3)			; Opcode/Operand Buffer löschen
	clr.b	SrcOperBuffer(a5)
	move.l	a4,a0
	lea	LabelBuffer(a5),a2
	move.l	a2,a1
	bsr	ReadDirective		; Label einlesen
	bmi.s	99$
	cmp.b	#'=',d1			; Label hört mit '=' auf?
	beq.s	6$
10$:	add.w	d0,d3
	sub.l	d0,d7
	add.l	d0,a4
	subq.w	#1,d0
	move.w	d0,sut_LabelLen(a6)
	moveq	#32-10,d1		; Zur Directive vorrücken
1$:	moveq	#32,d0
	sub.b	(a4)+,d0
	blo.s	3$
	sub.b	d1,d0
	beq.s	3$
	addq.w	#1,d3
	subq.l	#1,d7
	beq.s	2$
	subq.b	#1,d0
	bne.s	1$
	addq.w	#7,d3			; TAB
	and.w	#$fff8,d3
	bra.s	1$
6$:	subq.w	#1,d0			; '=' vom Ende des Labels entfernen
	clr.b	-(a1)
	bra.s	10$
3$:	subq.l	#1,a4
	move.l	a4,a0
	move.l	a3,a1
	bsr	ReadDirective		; Opcode einlesen
	bmi.s	rsl_nextline
	move.w	d0,OpcodeLen(a5)
	add.w	d0,d3
	sub.l	d0,d7
	add.l	d0,a4
	moveq	#32-10,d1		; Zum Operanden vorrücken
7$:	moveq	#32,d0
	sub.b	(a4)+,d0
	blo.s	8$
	sub.b	d1,d0
	beq.s	9$
	addq.w	#1,d3
	subq.l	#1,d7
	beq.s	2$
	subq.b	#1,d0
	bne.s	7$
	addq.w	#7,d3			; TAB
	and.w	#$fff8,d3
	bra.s	7$
9$:	subq.l	#1,d7			; Zeile ist zuende
2$:	bra.s	rsl_x
99$:	st	sut_LabelLen(a6)	; Zeile beginnt mit ; oder *
	bra.s	rsl_nextline
8$:	cmp.b	#';',-(a4)		; Kommentar statt Operand?
	beq.s	rsl_nextline
	move.l	a4,d0
	sub.l	d2,d0
	move.w	d0,sut_OperOffset(a6)
	move.w	d3,sut_OperXPos(a6)
	move.l	a4,a0
	move.w	d3,d1
	lea	SrcOperBuffer(a5),a1
	move.l	a1,d3
	bsr	ReadOperand		; Operand lesen, SPCs löschen, TABs expandieren
	blo.s	5$
	exg	a1,d3
	sub.l	a1,d3
	move.w	d3,sut_OperLen(a6)	; Operand kann in Pass 2 direkt kopiert werden!
5$:	sub.l	d0,d7
	add.l	d0,a4
	subq.w	#1,sut_OperLen(a6)
	cmp.w	#BUFSIZE-1,d0
	blo.s	rsl_nextline		; Buffer Overflow?
	move.l	a4,SrcPtr(a5)
	moveq	#15,d0			; String buffer overflow
	bsr	Error
	clr.b	SrcOperBuffer+BUFSIZE-1(a5)
rsl_nextline:
	moveq	#10,d0
1$:	subq.l	#1,d7
	cmp.b	(a4)+,d0		; Anfang der nächsten Zeile suchen
	bne.s	1$
rsl_x:
	move.l	a4,SrcPtr(a5)
	move.l	a4,d0
	sub.l	d2,d0			; Zeilenlänge speichern
	move.w	d0,sut_LineLen(a6)
	rts


	cnop	0,4
LineInfo:
	; PASS 2
; Trennt eine SourceCode-Zeile in Label, Opcode und Operand auf und benutzt
; die schon in Pass 1 gewonnenen Informationen aus der SpeedUpTable.
; a4 = Zeiger auf aktuelle Zeile
; -> a2 = LabelBuffer
; -> a3 = OperandBuffer
; -> a6 = SpeedUpTab-Ptr
	movem.l	CurrentSUT(a5),a0/a6	; CurrentSUT/SUTPos
	cmp.l	sut_Last(a0),a6
	bne.s	1$
	move.l	sut_Link(a0),a0
	lea	sut_HEAD(a0),a1
	movem.l	a0-a1,CurrentSUT(a5)
	bra.s	2$
1$:	lea	sutSIZE(a6),a1
	move.l	a1,SUTPos(a5)
2$:	move.l	a6,CurrentSUTPos(a5)
	lea	SrcOperBuffer(a5),a3	; a3 Operand
	lea	LabelBuffer(a5),a2	; a2 Label
	move.l	a4,a0			; Label lesen
	move.l	a2,a1
	move.w	sut_LabelLen(a6),d0
	bmi.s	4$
3$:	move.b	(a0)+,(a1)+
	dbf	d0,3$
4$:	clr.b	(a1)
	move.l	a3,a1
	move.w	sut_OperOffset(a6),d0	; Operand vorhanden?
	beq.s	6$
	lea	(a4,d0.w),a0
	move.w	sut_OperLen(a6),d0	; Operand direkt übernehmen?
	bmi.s	8$
5$:	move.b	(a0)+,(a1)+
	dbf	d0,5$
6$:	clr.b	(a1)
7$:	move.l	a4,LineBase(a5)		; BaseAdr dieser Zeile
	moveq	#0,d0
	move.w	sut_LineLen(a6),d0
	add.l	d0,a4
	move.l	a4,SrcPtr(a5)		; BaseAdr der nächsten Zeile
	sub.l	d0,d7
	rts
8$:	move.w	sut_OperXPos(a6),d1	; Operand expandiert übernehmen
	bsr.s	ReadOperand
	bra.s	7$


	cnop	0,4
ReadOperand:
; a0 = SrcLinePtr
; a1 = OperandBuffer
; d1 = SrcLineXPos
; -> a1 = OperandEndAdr (0-Byte)
; -> d0 = Bytes read
; -> BHS = Operand ist nicht direkt kopierbar (enthält dann SPCs u. TABs)
	movem.l	d2-d7/a2,-(sp)
	moveq	#' ',d0
	move.l	#$00220027,d2		; " und '
	moveq	#';',d3			; Kommentar
	moveq	#9,d4			; TAB
	moveq	#'<',d7			; < ... >
	moveq	#0,d5
	move.w	#-1,a2			; Wenn A2>=A1 ist, kann der Operand direkt
1$:	move.b	(a0)+,d6		;  übernommen werden, in Pass 2
	cmp.b	d3,d6			; Kommentar beginnt hier?
	beq.s	9$
	cmp.b	d0,d6			; Space, Tab oder LF ?
	bls.s	2$
	move.b	d6,(a1)+		; Character in OperandBuffer übernehmen
21$:	addq.w	#1,d1
	addq.w	#1,d5
	cmp.b	d2,d6			; Auf Stringbegrenzer " oder ' prüfen
	beq.s	4$
	swap	d2
	cmp.b	d2,d6
	beq.s	4$
	cmp.b	d7,d6			; < ... > ?
	bne.s	1$
	cmp.b	(a0),d6			; << irgnorieren (ist ein Operator)
	beq.s	20$
	addq.b	#2,d7			; '>'
	bra	11$
20$:	move.b	(a0)+,(a1)+
	moveq	#0,d6
	bra.s	21$

2$:	beq.s	3$			; Spaces oder Tabs 'verschlucken'
	cmp.b	d4,d6
	bne.s	9$			; kein TAB - dann Schluß machen
	and.w	#$fff8,d1		; expandieren
	addq.w	#7,d1
3$:	addq.w	#1,d1
	addq.w	#1,d5
	cmp.b	#'*',(a0)		; folgt ein Kommentar?
	beq.s	9$
	move.l	a2,d6
	bpl.s	1$
	move.l	a1,a2
	bra.s	1$
9$:	clr.b	(a1)
	move.l	d5,d0
	cmp.l	a1,a2			; Operand ohne Änderung kopierbar? (HS-Test)
	movem.l	(sp)+,d2-d7/a2
	rts

7$:	move.b	(a0)+,(a1)+		; '' oder "" übernehmen - String geht weiter
4$:	move.b	(a0)+,d6		; String lesen
	cmp.b	#10,d6			; Tab oder Zeilenende?
	bls.s	5$
	move.b	d6,(a1)+
	addq.w	#1,d1
	addq.w	#1,d5
	cmp.b	d2,d6			; String-Ende?
	bne.s	4$
	cmp.b	#ESCSYM,-2(a1)		; war jedoch nur ein \" oder \' ?
	beq.s	4$
	cmp.b	(a0),d2			; '' oder "" ?
	beq.s	7$
	bra	1$
5$:	cmp.b	d4,d6			; TAB?
	bne.s	9$			; Abbruch mitten im String!
	addq.w	#1,d5
	moveq	#7,d6
	and.w	d1,d6
	eor.w	#7,d6
6$:	addq.w	#1,d1			; expandieren
	move.b	d0,(a1)+
	dbf	d6,6$
	sub.l	a2,a2
	bra.s	4$

10$:	move.b	(a0)+,(a1)+		; >> übernehmen
	addq.w	#1,d1
	addq.w	#1,d5
11$:	move.b	(a0)+,d6		; < ... > lesen
	cmp.b	#10,d6			; Tab oder Zeilenende?
	bls.s	12$
	move.b	d6,(a1)+
	addq.w	#1,d1
	addq.w	#1,d5
	cmp.b	d7,d6			; Ende?
	bne.s	11$
	cmp.b	(a0),d7			; >> ?
	beq.s	10$
	subq.b	#2,d7			; '<'
	bra	1$
12$:	cmp.b	d4,d6			; TAB?
	bne	9$			; Abbruch mitten im Term!
	addq.w	#1,d5
	moveq	#7,d6
	and.w	d1,d6
	eor.w	#7,d6
13$:	addq.w	#1,d1			; expandieren
	move.b	d0,(a1)+
	dbf	d6,13$
	sub.l	a2,a2
	bra.s	11$


	cnop	0,4
ReadDirective:
; Alles bis zu einem White-Space, '=' oder ':' in den DestBuffer holen.
; Dabei wird ein ':' mitkopiert!
; a0 = SourceString
; a1 = DestBuffer
; -> d0 = BytesRead (negativ, wenn Kommentar begonnen hat)
; -> d1 = Zeichen, das zum Abbruch führte
; -> (a1) = 0.b (DestBuffer)
	movem.l	d2-d4,-(sp)
	moveq	#';',d0			; Kommentar (';' oder '*' erlaubt) ?
	sub.b	(a0),d0
	beq.s	4$
	sub.b	#';'-'*',d0
	beq.s	4$
	moveq	#32,d0			; WhiteSpace
	moveq	#'=',d3			; Gleichheitszeichen
	moveq	#':',d4			; Label-Terminator
	move.w	#BUFSIZE-2,d2
1$:	move.b	(a0)+,d1
	move.b	d1,(a1)+
	cmp.b	d3,d1			; Gleichheitszeichen?
	beq.s	5$
	cmp.b	d4,d1			; Label-Terminator?
	beq.s	5$
	cmp.b	d0,d1			; Trennzeichen?
	dbls	d2,1$
	bhi.s	3$			; Overflow?
2$:	clr.b	-(a1)
	move.w	#BUFSIZE-2,d0
	sub.w	d2,d0
	movem.l	(sp)+,d2-d4
	rts
3$:	move.w	d1,d2
	moveq	#15,d0			; Buffer overflow
	bsr	Error
	move.w	d2,d1
	addq.l	#1,a1
	moveq	#-1,d2
	bra.s	2$
4$:	movem.l	(sp)+,d2-d4
	clr.b	(a1)
	moveq	#-1,d0			; Kommentar gelesen
	rts
5$:	clr.b	(a1)			; Label/Opcode endet mit ':' oder '='
	move.w	#BUFSIZE-1,d0
	sub.w	d2,d0
	movem.l	(sp)+,d2-d4
	rts


	cnop	0,4
ReadArgument:
; Überträgt die Zeichen aus dem InputBuffer in den DestBuffer solange sie
; aus den folgenden Zeichen bestehen:  _ 0..9 @..Z a..z
;				       . %   nur als 1. Zeichen
;				       $     nur als letztes Zeichen
;				       ' "   als String-Begrenzer
; a0 = InputBuffer
; a1 = DestBuffer
; d0 = DestBufferSize
; -> d0 = gelesene Zeichen (auch Z-Flag bei d0=0)
	movem.l	d0/a2-a3,-(sp)
	move.l	a1,a3			; a3 DestBuffer Start
	move.w	d0,d1
	moveq	#0,d0
	lea	arg1_tab(a5),a2
	move.b	(a0)+,d0
	tst.b	(a2,d0.w)		; erstes Zeichen @-Z a-z 0-9 _ " ' . % $
	beq.s	2$
	bpl.s	4$			; String? (beginnt mit ' oder " )
	lea	arg2_tab(a5),a2		; Folgezeichen: A-Z a-z 0-9 _ .
	subq.w	#1,d1
1$:	move.b	d0,(a1)+
	move.b	(a0)+,d0
	tst.b	(a2,d0.w)
	dbeq	d1,1$
	bne.s	33$
2$:	clr.b	(a1)
	cmp.b	#'.',-2(a1)		; Argument endet mit ".x" ?
	beq.s	30$
3$:	movem.l	(sp)+,d0/a2-a3
	sub.w	d1,d0			; Anzahl gelesener Zeichen zurückgeben
	rts
30$:	moveq	#-$21,d0
	and.b	-(a1),d0
	cmp.b	#'W',d0			; Argument endet auf ".W" oder ".L" ?
	beq.s	31$
	cmp.b	#'L',d0
	bne.s	3$
31$:	addq.w	#2,d1
	clr.b	-(a1)			; .W / .L Endung nicht mitübernehmen!
	cmp.l	a3,a1			; müssen aber mehr als 2 Zeichen sein
	bhi.s	3$
	move.b	#'.',(a1)		; ansonsten Rückgängig machen
	subq.w	#2,d1
	bra.s	3$
33$:	moveq	#26,d0			; Argument buffer overflow
	bsr	Error
	bra.s	2$

4$:	movem.l	d2-d3,-(sp)
	move.b	d0,(a1)+		; String einlesen
	moveq	#%101,d3
	eor.b	d0,d3
	swap	d3
	move.b	d0,d3			; d3 = anderer Strbegr. | akt. Strbegr.
	subq.w	#1,d1
	moveq	#ESCSYM,d0
5$:	move.b	(a0)+,d2
	beq.s	10$			; Zeile vorzeitig zuende ?
	move.b	d2,(a1)+
	subq.w	#1,d1
	bmi.s	9$			; Dest-Buffer Überlauf?
	cmp.b	d0,d2			; Escape-Zeichen ?
	beq.s	7$
	swap	d3
	cmp.b	d3,d2			; anderer String-Begrenzer ?
	beq.s	8$
	swap	d3
	cmp.b	d3,d2			; echter String-Begrenzer?
	bne.s	5$
	cmp.b	(a0),d3			; "" oder '' ?
	beq.s	6$
10$:	clr.b	(a1)
	movem.l	(sp)+,d2-d3/a1-a3
	move.l	a1,d0
	sub.w	d1,d0
	rts
8$:	swap	d3
	cmp.b	(a0),d2			; "" oder '' ?
	bne.s	5$
6$:	move.b	d0,-1(a1)		; durch \" bzw. \' ersetzen
7$:	move.b	(a0)+,(a1)+
	subq.w	#1,d1
	bpl.s	5$
9$:	moveq	#26,d0			; Argument buffer overflow
	bsr	Error
	bra.s	10$


	cnop	0,4
RefTypeList:
	dc.w	EXT_REF8,EXT_REF16,EXT_REF32
	IFND	SMALLASS
	dc.w	REF_SIMPLEFLOAT,REF_SIMPLEFLOAT,REF_EXTFLOAT,REF_EXTFLOAT,REF_EXTFLOAT
	ENDC

GetValue:
; a0 = InputStream
; d0 = ValueSize (byte,word,long - nur fuer ReferenceList wichtig)
;      bei -1 wird die ValueSize aus OpcodeSize gelesen
;      bei -2 ebenfalls, aber die RefAddr bei REF8 nicht erhoeht (fuer DC.B's)
; -> d0 = Minuend (oder das normale Value, falls Type=normal
;		   oder ein Zeiger auf eine Fliesskommazahl)
; -> d1 = Subtrahend (wird nur bei ABS-Type gesetzt)
; -> d2 = LSW : Type(0=normal, 1=ABS) oder -1 bei Error (z.B. UndefSymbol)
;	  MSW : DeclHunk(wenn Type=ABS)
;	  Fuer Type=0,MSW=0   :  EQU
;		      MSW=-1  :  XREF
;		      MSW=-2  :  NREF
; -> a0 = New InputStream position
	movem.l	d7/a2-a3,-(sp)
	clr.l	RefAdrOff(a5)
	clr.w	RefNear(a5)
	clr.b	DistShift(a5)
	add.w	d0,d0
	bpl.s	1$
	move.w	d0,d1
	move.b	OpcodeSize(a5),d0
	ext.w	d0
	add.w	d0,d0
	addq.w	#4,d1
	beq.s	2$
	tst.w	d0
1$:	bne.s	2$
	addq.w	#1,RefAdrOff+2(a5)	; Bei EXT_REF8 ist RefAdrOff = 1
2$:	move.w	RefTypeList(pc,d0.w),RefType(a5)
	lea	ExpStackBase(a5),a4	; a4 = Expression Stack Pointer
	lea	Buffer(a5),a3
	clr.b	DistSet(a5)		; Noch keine Distanz gefunden
	clr.w	LastRefCnt(a5)
	moveq	#0,d7			; d7 = Zahl der Arg. auf dem Exp.Stack
	move.l	a0,a2
	IFND	SMALLASS
	cmp.b	#os_FFP<<1,d0
	bhs.s	3$
	ENDC
	bsr.s	GetExpression		; Integer Ausdruck auswerten
	move.l	a2,a0
	movem.l	(sp)+,d7/a2-a3
	move.l	SrcPtr(a5),a4
	rts

	IFND	SMALLASS
3$:	tst.b	FloatLibs(a5)		; Fließkomma überhaupt möglich?
	beq.s	5$
	lsr.w	#1,d0
	move.l	d0,-(sp)
	jsr	GetFloatExpression	; Float Ausdruck auswerten (IEEE Double Prec.)
	move.l	(sp)+,d7
	move.l	SrcPtr(a5),a4
	tst.w	d2			; sowieso schon Fehler?
	bne.s	4$
	jsr	FloatConversion		; In gewünschte Opcode size (d7) konvertieren
4$:	move.l	a2,a0
	movem.l	(sp)+,d7/a2-a3
	rts
5$:	moveq	#84,d0			; No float without approriate Math libraries
	bsr	Error
	bra.s	4$
	ENDC


	cnop	0,4
GetExpression:
; Argumente und Operatoren einer Ebene miteinander verknuepfen
; (Rekursionsfaehig)
; a2 = Input
; a3 = Buffer
; a4 = Expression Stack
; d7 = Zahl der Arg. auf dem Stack aus uebergeordneten Ebenen
; -> d0 = Minuend
; -> d1 = Subtrahend
; -> d2 = LSW: Type or Error,  MSW: DeclHunk
; -> a2 = NewInputPos
	movem.l	d3-d5,-(sp)
	moveq	#-1,d5			; d5 zaehlt die verbleibenden Operationen
	moveq	#0,d4			; Type (defaults to EQU)

gexp_BuildStack:			; Stack aufbauen
	moveq	#0,d2			; kein NOT oder Negate auf Argument anwenden
1$:	move.l	a2,a0
	move.l	a3,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument
	bne.s	gexp_ArgGot		; hat was vernuenftiges lesen koennen ?
	move.b	(a2)+,d0
	tst.w	d2
	bne.s	3$			; Noch ein NOT oder Negate kann nicht kommen
	cmp.b	#'~',d0			; NOT-Operator vor dem Symbol
	bne.s	2$
	moveq	#1,d2
	bra.s	1$
2$:	cmp.b	#'-',d0			; Negate-Operator vor dem Symbol
	bne.s	3$
	moveq	#-1,d2
	bra.s	1$
3$:	cmp.b	#'[',d0			; Klammerterm ?
	beq	gexp_Term
	cmp.b	#'(',d0
	beq	gexp_Term
	cmp.b	#'*',d0			; * = Adresse am Anfang dieser Zeile
	bne.s	4$
	move.l	d6,d0			; PC
;	move.l	LineAddr(a5),d0
	move.w	SecNum(a5),d3
	bra	gexp_addABS
4$:	cmp.b	#'+',d0			; + ignorieren
	beq.s	1$
	moveq	#46,d0			; Missing argument
	bsr	Error
	tst.w	d5
	bmi	gexp_error
	addq.l	#1,a4			; Operator loeschen (da Argument fehlt)
	bra	gexp_Calc
gexp_ArgGot:
	move.l	a3,a0
	add.w	d0,a2			; InputStreamPointer weiterruecken
	cmp.b	#'$',(a2)		; Local-Symbol ?
	beq.s	gexp_LocalSym
	move.b	(a0),d0
	sub.b	#$22,d0			; " Character ?
	beq	gexp_Char
	subq.b	#2,d0			; $ Hexadezimalzahl ?
	beq	gexp_Hex
	subq.b	#1,d0			; % Binaerzahl ?
	beq	gexp_Binary
	subq.b	#2,d0			; ' Character ?
	beq	gexp_Char
	subq.b	#7,d0			; . Local-Symbol ?
	IFD	DOTNOTLOCAL
	beq.s	gexp_GlobalSym
	ELSE
	beq.s	gexp_LocalSym2
	ENDIF
	sub.b	#12,d0			; 0..9 Dezimalzahl ?
	blo	gexp_Decimal
	subq.b	#6,d0			; @ Oktalzahl ?
	bne.s	gexp_GlobalSym
	cmp.b	#'9',1(a0)		; wenn keine Ziffer folgt, ist es ein Symbol
	bhi.s	gexp_GlobalSym
	bra	gexp_Octal

gexp_errclr:
	clr.b	(a2)
	bra	gexp_error

gexp_LocalSym:				; Wert eines lokalen Symbols besorgen
	addq.l	#1,a2
gexp_LocalSym2:
	bsr	FindLocalSymbol
	bne.s	gexp_addref
	cmp.b	#'#',(a2)		; Extern definiertes Symbol ?
	bne.s	gexp_errclr
	addq.l	#1,a2
	move.l	a3,a0
	bsr	FindSymbol		; schon als XREF definiert worden?
	bne.s	gexp_addref
	move.l	a3,a0
	move.w	#T_XREF,d0
	moveq	#0,d1
	bsr	AddSymbol		; Symbolname als XREF deklarieren
	move.l	a3,a0

gexp_GlobalSym:				; Wert eines globalen Symbols besorgen
	bsr	FindSymbol
	beq.s	gexp_errclr

	IFD	GLOBALLOCALS
	cmp.b	#ESCSYM,(a2)		; <symbol>\<.local> ?
	bne.s	gexp_addref
	cmp.b	#'.',1(a2)
	bne.s	gexp_addref
	move.l	d0,a0
	IFND	GIGALINES
	move.w	AbsLine(a5),d3
	move.w	sym_DeclLine(a0),d0
	addq.w	#1,d0
	move.w	d0,AbsLine(a5)
	ELSE
	move.l	AbsLine(a5),d3
	move.l	sym_DeclLine(a0),d0
	addq.l	#1,d0
	move.l	d0,AbsLine(a5)
	ENDC
	addq.l	#1,a2
	move.l	a2,a0
	move.l	a3,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument
	add.w	d0,a2
	move.l	a3,a0
	bsr	FindLocalSymbol		; Lokales Symbol im LocalPart des globalen
	IFND	GIGALINES
	move.w	d3,AbsLine(a5)
	ELSE
	move.l	d3,AbsLine(a5)
	ENDC
	tst.l	d0
	beq	gexp_error
	ENDC

gexp_addref:
	move.w	d1,d3			; d3 = Delcaration-Hunk des Symbols
	move.l	d0,a0
	move.w	sym_Type(a0),d0
	move.w	#T_FREG|T_REG|T_MACRO,d1
	and.w	d0,d1			; FREG, REG, MACRO nicht zulaessig !
	beq.s	1$
	moveq	#47,d0			; Need numeric symbol
	bra	gexp_Err
1$:	btst	#bit_XDEF,d0		; zu XDEF muss ABS, EQU oder DIST gesetzt sein
	beq.s	2$
	and.w	#T_ABS|T_EQU|T_DIST,d0
	bne.s	21$
	bra	gexp_error
2$:	and.w	#T_NREF,d0		; NREF-Symbol ?
	beq.s	21$
	move.w	RefType(a5),d0
	cmp.w	#EXT_REF32,d0
	bne.s	22$
	st	RefNear(a5)
	move.w	#EXT_DEXT16,d0
	bra.s	22$
21$:	move.w	RefType(a5),d0
22$:	move.l	d6,d1			; RelAddr
	add.l	RefAdrOff(a5),d1
	bsr	AddReference
3$:	move.l	sym_Value(a0),d0	; Symbol-Wert
	move.w	sym_Type(a0),d1
	btst	#bit_XREF,d1
	bne.s	34$
	btst	#bit_NREF,d1
	beq.s	32$
34$:	clr.b	OptFlag(a5)
	moveq	#-2,d1			; NREF/XREF als Type uebergeben
	bra	gexp_AddArg
32$:	btst	#bit_ABS,d1		; ABS-Symbol ?
	bne.s	gexp_addABS

	btst	#bit_DIST,d1		; Symbol-Wert aus DistanceList holen ?
	beq	gexp_AddEQUArg		;  oder normales EQU-Symbol ?
	bset	#0,DistSet(a5)
	beq.s	31$
	moveq	#49,d0			; Only one distance allowed
	bra	gexp_Err
31$:	move.l	d0,a1			; Value ist Zeiger auf Distance-Entry
	moveq	#$3f,d0
	and.b	dist_Info-dist_HEAD(a1),d0
	move.b	d0,DistShift(a5)
	movem.l	(a1),d0-d1
	movem.l	d0-d1,DistVal(a5)
	tst.w	d4
	beq.s	33$
	moveq	#53,d0			; Can't use distance and reloc in the same exp
	bra	gexp_Err
33$:	move.w	d3,d4
	swap	d4
	move.w	#1,d4
	moveq	#1,d1			; DIST-Type
	bra	gexp_AddArg

	cnop	0,4
gexp_addABS:
	swap	d4
	bset	#16,d4
	beq.s	1$			; war vorher noch kein ABS gesetzt ?
	cmp.w	d3,d4			; ABS-Symbole liegen im selben Hunk ?
	beq.s	2$
	moveq	#48,d0			; Symbols must be declared in the same section
	bra	gexp_Err
1$:	move.w	d3,d4			; Hunk-Nummer merken
2$:	swap	d4
	moveq	#-1,d1			; ABS-Type
	bra	gexp_AddArg

	cnop	0,4
gexp_Term:
	move.l	d2,-(sp)
	bsr	GetExpression		; REKURSION
	tst.w	d2			; Fehler im Term ?
	bpl.s	11$
	addq.l	#4,sp
	bra	gexp_error
11$:	cmp.b	#')',(a2)		; Term wurde mit Klammer-Zu beendet ?
	beq.s	10$
	cmp.b	#']',(a2)
	beq.s	10$
	addq.l	#4,sp
	moveq	#50,d0			; Missing bracket/parenthesis
	bra	gexp_Err
10$:	addq.l	#1,a2
	tst.b	d2			; Distanz,
	beq.s	2$			; EQU oder
	bmi.s	3$			; ABS ?
	move.l	(sp)+,d2
	moveq	#1,d1
	bra	gexp_AddArg
2$:	tst.l	d2
	bmi.s	4$			; XREF/NREF ?
	move.l	(sp)+,d2		; EQU
	bra	gexp_AddEQUArg
3$:	swap	d2			; ABS
	move.w	d2,d3			; DeclHunk
	move.l	(sp)+,d2
	bra	gexp_addABS
4$:	move.l	(sp)+,d2
	moveq	#-2,d1			;XREF/NREF
	bra	gexp_AddArg

	cnop	0,4
gexp_Octal:
	; Oktalzahl lesen
	addq.l	#1,a0
	movem.l	d2-d4,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#'0',d2
	moveq	#'7',d3
	moveq	#7,d4
	move.b	(a0)+,d1
	cmp.b	d2,d1			; Testen ob Char zwischen 0 und 7 liegt
	blo.s	3$
	cmp.b	d3,d1
	bhi.s	3$
1$:	and.w	d4,d1
	lsl.l	#3,d0			; Zahl eine Stelle nach links schieben (*8)
	add.b	d1,d0			;  und neue Oktal-Ziffer anhaengen
	move.b	(a0)+,d1
	cmp.b	d2,d1			; Testen ob Char zwischen 0 und 7 liegt
	blo.s	2$
	cmp.b	d3,d1
	bls.s	1$
2$:	movem.l	(sp)+,d2-d4
	tst.b	d1
	beq	gexp_AddEQUArg
	bra	gexp_error
3$:	movem.l	(sp)+,d2-d4
	bra	gexp_error

	cnop	0,4
gexp_Binary:
	; Binaerzahl lesen
	addq.l	#1,a0
	movem.l	d2-d4,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#'0',d2
	moveq	#'1',d3
	moveq	#1,d4
	move.b	(a0)+,d1
	cmp.b	d2,d1			; 0 oder 1 ist erlaubt
	blo.s	3$
	cmp.b	d3,d1
	bhi.s	3$
1$:	and.w	d4,d1
	add.l	d0,d0			; Zahl eine Stelle nach links schieben (*2)
	or.b	d1,d0			;  und neue Binaer-Ziffer anhaengen
	move.b	(a0)+,d1
	cmp.b	d2,d1			; 0 oder 1 ist erlaubt
	blo.s	2$
	cmp.b	d3,d1
	bls.s	1$
2$:	movem.l	(sp)+,d2-d4
	tst.b	d1
	beq	gexp_AddEQUArg
	bra	gexp_error
3$:	movem.l	(sp)+,d2-d4
	bra	gexp_error

	cnop	0,4
gexp_Char:
	; Bis zu 4 Characters lesen
	movem.l	d2-d3,-(sp)
	moveq	#ESCSYM,d3
	move.b	(a0)+,d2		; String-Ende Zeichen ( ' oder " )
	moveq	#0,d0
	moveq	#0,d1
1$:	move.b	(a0)+,d0
	beq.s	3$
	cmp.b	d2,d0			; End-Markierung ?
	beq.s	3$
	cmp.b	d3,d0			; Escape-Symbol '\' ?
	bne.s	2$
	move.b	(a0)+,d0
	bsr	GetEscSym		; Code in Escape-Symbol umwandeln
2$:	lsl.l	#8,d1			; Platz machen und neuen Char anfuegen
	move.b	d0,d1
	bra.s	1$
3$:	move.l	d1,d0
	movem.l	(sp)+,d2-d3
	bra	gexp_AddEQUArg

	cnop	0,4
gexp_Hex:
	; Hexadezimalzahl lesen
	addq.l	#1,a0
	movem.l	d2-d7,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#'0',d2
	moveq	#'9',d3
	moveq	#'A',d4
	moveq	#'F',d5
	moveq	#15,d6
	moveq	#-$21,d7		; $df für UpperCase
	move.b	(a0)+,d1
	cmp.b	d2,d1			; Testen ob Char zwischen 0 und 9 liegt
	blo.s	4$
	cmp.b	d3,d1
	bls.s	3$
	and.b	d7,d1
	cmp.b	d4,d1			; Testen ob Char zwischen A und F liegt
	blo.s	4$
	cmp.b	d5,d1
	bhi.s	4$
1$:	subq.b	#7,d1
3$:	and.w	d6,d1
	lsl.l	#4,d0			; Zahl eine Stelle nach links schieben (*16)
	add.b	d1,d0			;  und neue Hex-Ziffer anhaengen
	move.b	(a0)+,d1
	cmp.b	d2,d1			; Testen ob Char zwischen 0 und 9 liegt
	blo.s	2$
	cmp.b	d3,d1
	bls.s	3$
	and.b	d7,d1
	cmp.b	d4,d1			; Testen ob Char zwischen A und F liegt
	blo.s	2$
	cmp.b	d5,d1
	bls.s	1$
2$:	movem.l	(sp)+,d2-d7
	tst.b	d1
	beq.s	gexp_AddEQUArg
	bra	gexp_error
4$:	movem.l	(sp)+,d2-d7
	bra	gexp_error

	cnop	0,4
gexp_Decimal:
	; Dezimalzahl lesen
	movem.l	d2-d4,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#'0',d2
	moveq	#'9',d3
	moveq	#15,d4
1$:	move.b	(a0)+,d1
	cmp.b	d2,d1			; Testen ob Char zwischen 0 und 9 liegt
	blo.s	3$
	cmp.b	d3,d1
	bhi.s	3$
	add.l	d0,d0			; Zahl eine Stelle nach links schieben (*10)
	move.l	d0,a1			;  und neue Ziffer addieren
	add.l	d0,d0
	add.l	d0,d0
	add.l	a1,d0
	and.w	d4,d1
	add.l	d1,d0
	bra.s	1$
3$:	movem.l	(sp)+,d2-d4
	tst.b	d1
	beq.s	gexp_AddEQUArg
	bra	gexp_error

	cnop	0,4
gexp_AddArg:
	tst.w	d2			; fuer Relocs ist kein PreOp. erlaubt
	beq.s	gexp_push
	moveq	#52,d0			; Unable to negate an address
	bra	gexp_Err
	cnop	0,4
gexp_AddEQUArg:
	moveq	#0,d1
	tst.w	d2			; einstelligen Operator ausfuehren
	beq.s	gexp_push
	bmi.s	1$
	move.w	RefType(a5),d2		; ~ Operator (.b / .w / .l beachten)
	sub.w	#EXT_REF32,d2
	beq.s	2$
	subq.w	#2,d2
	beq.s	3$
	not.b	d0			; .b NOT
	bra.s	gexp_push
3$:	not.w	d0			; .w NOT
	bra.s	gexp_push
2$:	not.l	d0			; .l NOT
	bra.s	gexp_push
1$:	neg.l	d0			; - Operator
gexp_push:
	move.l	d0,-(a4)		; Value und
	move.b	d1,-(a4)		;  Type auf den Expression-Stack
	addq.w	#1,d5
	addq.w	#1,d7
	cmp.w	#EXP_MAXARGS,d7		; Noch Platz auf dem Stack ?
	blo.s	gexp_Operator
	moveq	#51,d0			; Expression stack overflow
	bra	gexp_Err

	cnop	0,4
gexp_Ops:
	dc.b	"+-^|!&*//><",0
gexp_Operator:
	move.b	(a2)+,d0		; Operator holen
	beq.s	5$
	lea	gexp_Ops(pc),a0
	moveq	#11-1,d1		; 11 Operatoren checken
1$:	cmp.b	(a0)+,d0
	dbeq	d1,1$
	bne.s	5$			; kein Operator? (Expression zuende)
	moveq	#10,d2
	sub.b	d1,d2
	subq.b	#1,d1			; > oder < gefunden ?
	bls.s	3$
	subq.b	#2,d1			; / ?
	bne.s	4$
	cmp.b	(a2),d0			; folgt noch ein / - dann ist es Modulo
	bne.s	4$
	moveq	#8,d2
	bra.s	6$
3$:	cmp.b	(a2),d0			; Bei > u. < muss dasseble Zchn. nochmal kommen
	bne.s	5$
6$:	addq.l	#1,a2
4$:	move.b	10$(pc,d2.w),-(a4)	; <Priorität<<2 | Operator> auf ExpStack legen
	bra	gexp_BuildStack		;  und naechstes Argument holen
10$:	dc.b	%0000,%0001,%0100,%0101,%0110,%0111,%1000,%1001,%1010,%1100,%1101,0
5$:	subq.l	#1,a2			; kein Operator da - Expression zuende !!

gexp_Calc:
	movem.l	a2-a3,-(sp)
	move.w	d5,a2
	add.w	d5,d5			; *6
	move.w	d5,d0
	add.w	d5,d5
	add.w	d0,d5
	lea	5(a4,d5.w),a3		; Zeiger auf erstes Byte nach Expression stack
	moveq	#3<<2,d3		; Nummer der ersten zu bearbeitenden Priorität

gexp_CalcLoop:
	move.l	a3,a0
	move.w	a2,d5
	beq	gexp_finished		; Ergebnis zurueckgeben ?
gexp_OpLoop:
	subq.l	#6,a0			; Zeiger auf nächsten Operator
	moveq	#-4,d2
	and.b	(a0),d2
	cmp.b	d3,d2			; richtige Priorität ? Dann ausführen!
	beq.s	1$
	subq.w	#1,d5
	bne.s	gexp_OpLoop
	subq.w	#1<<2,d3		; nächste Prioritäts-Ebene bearbeiten
	bpl.s	gexp_CalcLoop
	bra	gexp_finished
1$:	moveq	#0,d2
	addq.l	#6,a0
	move.l	-(a0),d0		; Value1 und Type1 holen
	move.b	-(a0),d2
	swap	d2
	subq.l	#1,a0
	move.l	a0,a1			; nach 1(a1) wird nachher aufgerückt
	move.l	-(a0),d1		; Value2 und Type2 holen
	move.b	-(a0),d2
	swap	d2
	move.l	d2,-(sp)
	move.b	(a1)+,d2		; d2:Operator , a1 auf Aufrückposition
	add.w	d2,d2
	add.w	d2,d2
	jmp	gexp_jmptable(pc,d2.w)
	cnop	0,4
gexp_jmptable:
	jmp	gexp_Plus(pc)		; Priorität 0
	jmp	gexp_Minus(pc)
	ds.l	2
	jmp	gexp_ExclusiveOr(pc)	; Priorität 1
	jmp	gexp_Or(pc)
	jmp	gexp_Or(pc)
	jmp	gexp_And(pc)
	jmp	gexp_Mult(pc)		; Priorität 2
	jmp	gexp_Divide(pc)
	jmp	gexp_Modulo(pc)
	ds.l	1
	jmp	gexp_ShiftRight(pc)	; Priorität 3
	jmp	gexp_ShiftLeft(pc)


gexp_shifterr1:
	addq.l	#2,sp
gexp_shifterr2:
	moveq	#54,d0			; shift error
	bra	gexp_CalcErr

gexp_ShiftLeft:
	tst.w	(sp)+			; Type2 muß EQU-Type sein
	bne.s	gexp_shifterr1
	tst.w	(sp)+			; Type1 hingegen darf nur keine Reloc-Addr sein
	bmi.s	gexp_shifterr2
	bne.s	gexp_shiftdist
	asl.l	d1,d0			; EQU << EQU - kein Problem
	bra	gexp_nextOp0

	cnop	0,4
gexp_ShiftRight:
	tst.w	(sp)+			; Type2 muß EQU-Type sein
	bne.s	gexp_shifterr1
	tst.w	(sp)+			; Type1 hingegen darf nur keine Reloc-Addr sein
	bmi.s	gexp_shifterr2
	bne.s	1$
	asr.l	d1,d0
	bra	gexp_nextOp0
1$:	neg.b	d1
gexp_shiftdist:
	; Distance Shift
	move.b	DistShift(a5),d2
	bclr	#5,d2
	beq.s	1$
	neg.b	d2
1$:	add.b	d1,d2			; Shifts addieren sich auf (hmm...)
	beq.s	4$
	bpl.s	2$
	neg.b	d2
	or.b	#32,d2			; Right-Shift (negativ) hat Bit 5 gesetzt
2$:	moveq	#1,d1
3$:	move.b	d2,DistShift(a5)
	bra	gexp_nextOp
4$:	moveq	#0,d1
	bra.s	3$

	cnop	0,4
gexp_Mult:
	tst.l	(sp)+			; Es darf kein ABS-Type dabei sein
	bne.s	1$
	move.l	a6,-(sp)
	move.l	UtilityBase(a5),a6
	jsr	SMult32(a6)
	move.l	(sp)+,a6
	bra	gexp_nextOp0		; ignore Overflow!
;	bvc	gexp_nextOp0
;	moveq	#56,d0			; Overflow during multiplication
;	bra	gexp_CalcErr
1$:	moveq	#55,d0			; Can't multiply an address
	bra	gexp_CalcErr

	cnop	0,4
gexp_Modulo:
	tst.l	(sp)+			; Es darf kein ABS-Type dabei sein
	bne.s	gexp_cantdiv
	tst.l	d1			; Divisor ist 0 ?
	beq.s	gexp_zerodiv
	bsr	DivMod			; 32-bit Modulo
	move.l	d1,d0
	bra	gexp_nextOp0

gexp_cantdiv:
	moveq	#57,d0			; Can't divide an address
	bra	gexp_CalcErr
gexp_zerodiv:
	moveq	#58,d0			; Division by zero
	bra	gexp_CalcErr

	cnop	0,4
gexp_Divide:
	tst.l	(sp)+			; Es darf kein ABS-Type dabei sein
	bne.s	gexp_cantdiv
	tst.l	d1			; Divisor ist 0 ?
	beq.s	gexp_zerodiv
	bsr	DivMod			; 32-bit Division
	bra	gexp_nextOp0

gexp_nologic:
	moveq	#59,d0			; No logical operation allowed on addresses
	bra	gexp_CalcErr

	cnop	0,4
gexp_And:
	tst.l	(sp)+			; Es darf kein ABS-Type dabei sein
	bne.s	gexp_nologic
	and.l	d1,d0
	bra	gexp_nextOp0

	cnop	0,4
gexp_Or:
	tst.l	(sp)+			; Es darf kein ABS-Type dabei sein
	bne.s	gexp_nologic
	or.l	d1,d0
	bra	gexp_nextOp0

	cnop	0,4
gexp_ExclusiveOr:
	tst.l	(sp)+			; Es darf kein ABS-Type dabei sein
	bne.s	gexp_nologic
	eor.l	d1,d0
	bra	gexp_nextOp0

	cnop	0,4
gexp_Minus:
	move.w	(sp)+,d2
	beq.s	2$			; Type2 = EQU ?
	addq.b	#1,d2
	bne.s	10$			; wenn nicht, darf er hoechstens noch ABS sein
	move.w	(sp)+,d2
	addq.b	#1,d2
	bne.s	11$			; und Type1 muss dann auch ABS sein
	swap	d4
	move.w	d4,d2
	swap	d4
	move.l	a0,-(sp)
	bsr	GetSectionPtr
	moveq	#0,d2
	cmp.w	#HUNK_CODE,sec_Type+2(a0) ; Distanz aus Code-Section?
	move.l	(sp)+,a0
	bne.s	3$			; nein? Dann ist das Resultat EQU!
	bset	#0,DistSet(a5)
	beq.s	1$
	moveq	#49,d0			; Only one distance allowed
	bra	gexp_CalcErr
1$:	movem.l	d0-d1,DistVal(a5)	; Distanz speichern
	moveq	#1,d1
	bra	gexp_nextOp
2$:	move.w	(sp)+,d2
	cmp.w	#1,d2			; DIST-EQU ?
	bne.s	3$
	sub.l	d1,DistVal(a5)		; Wert vom Distanz-Subtrahenden abziehen
	moveq	#1,d1
	bra	gexp_nextOp
3$:	sub.l	d1,d0
	move.w	d2,d1			; Ergebnis nimmt Type1 an
	bra	gexp_nextOp
10$:	addq.l	#2,sp
	moveq	#42,d0			; Relocatability Error
	bra	gexp_CalcErr
11$:	moveq	#60,d0			; Need two addresses to make a distance
	bra	gexp_CalcErr

	cnop	0,4
gexp_Plus:
	move.l	(sp)+,d2
	beq.s	3$
	move.w	d3,-(sp)
	move.w	d2,d3			; d3 = Type1
	swap	d2			; d2 = Type2
	cmp.w	d2,d3
	bne.s	2$
1$:	addq.l	#2,sp
	moveq	#61,d0			; Unable to sum two addresses
	bra	gexp_CalcErr
2$:	cmp.b	#1,d2			; Distanz dabei ?
	beq.s	4$
	cmp.b	#1,d3
	beq.s	5$
	add.l	d1,d0
	or.w	d3,d2			; Type-Praezedenz:  ABS -> XREF -> EQU
	move.w	(sp)+,d3
	move.w	d2,d1
	bra.s	gexp_nextOp
4$:	move.w	d3,d2
	move.l	d0,d1
5$:	; DIST+(XREF|EQU)
	addq.w	#1,d2
	beq.s	1$			; DIST+ABS nicht erlaubt
	add.l	d1,DistVal(a5)		; auf Distanz-Subtrahenden addieren
	move.w	(sp)+,d3
	moveq	#1,d1
	bra.s	gexp_nextOp
3$:	add.l	d1,d0			; EQU+EQU
gexp_nextOp0:
	moveq	#0,d1

gexp_nextOp:
	move.b	d1,(a1)+		; Type und Value ablegen
	move.l	d0,(a1)+
	move.l	a1,d0
	subq.w	#1,d7			; 1 Argument weniger auf dem Stack
	subq.l	#5,a1
	bra.s	2$
1$:	move.b	-(a0),-(a1)		; Rest des Stacks eine Position aufruecken
	move.l	-(a0),-(a1)
	move.b	-(a0),-(a1)
2$:	cmp.l	a4,a0
	bne.s	1$
	addq.l	#6,a4			; Stack-Ende verschieben
	subq.w	#1,a2			; Eine Operation weniger
	move.l	d0,a0
	subq.w	#1,d5
	bne	gexp_OpLoop		; noch eine Operation auszufuehren ?
	subq.w	#1<<2,d3		; nächste Prioritäts-Ebene bearbeiten
	bpl	gexp_CalcLoop

gexp_finished:
	movem.l	(sp)+,a2-a3
	move.b	(a4)+,d4
	move.l	d4,d2			; d2 = DeclHunk|Type
	addq.b	#2,d4			; XREF ?
	beq.s	1$
	subq.b	#3,d4			; DIST ?
	beq.s	2$
3$:	move.l	(a4)+,d0		; Ergbnis vom Expression stack holen
	moveq	#0,d1
	subq.w	#1,d7
	movem.l	(sp)+,d3-d5
	rts
1$:	; XREF
	moveq	#-1,d2			; wie normales EQU behandeln
	clr.w	d2			;  (MSW wird aber auf -1 gesetzt)
	tst.b	RefNear(a5)
	beq.s	3$
	bclr	#16,d2			; NREF gibt -2 im MSW zurueck
	bra.s	3$
2$:	; DIST
	movem.l	DistVal(a5),d0-d1
	move.b	DistShift(a5),d3	; shifted distance?
	bne.s	5$
4$:	addq.l	#4,a4
	subq.w	#1,d7
	movem.l	(sp)+,d3-d5
	rts
5$:	bclr	#5,d3			; ugly! Verhindert aber Probleme mit
	bne.s	6$			; Distance-Size Checks (so ziemlich)
	asl.l	d3,d0			; Minuend u. Subtrahend shiften!
	asl.l	d3,d1
	bra.s	4$
6$:	asr.l	d3,d0
	asr.l	d3,d1
	bra.s	4$

gexp_CalcErr:
	movem.l	(sp)+,a2-a3
gexp_Err:
	bsr	Error
gexp_error:
	movem.l	(sp)+,d3-d5
	moveq	#0,d0
	moveq	#0,d1
	moveq	#-1,d2			; Error
	rts


	cnop	0,4
GetRegList:
; Zusammenfassen aller Register in einer Register-List zu einem Word, wie es
; z.B. auch von MOVEM benutzt wird
; a0 = RegListText
; -> d0 = RegListBits (im MSW fuer SrcOperand und im LSW fuer DestOperand)
; -> d1 = Zahl der gesetzten Reg.Bits in d0 (oder negativ bei Fehler)
	movem.l	d2-d5/d7,-(sp)
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d5
	moveq	#15,d7
	tst.b	(a0)			; ueberhaupt ein Register benannt ?
	beq.s	9$
1$:	bsr	GetRegister		; Register bestimmen
	bmi.s	gregl_unknown		; unbekanntes Register ?
	move.w	d0,d4
	bset	d0,d3			; RegBit setzen (Dest)
	eor.w	d7,d0
	bset	d0,d2			; RegBit setzen (Src)
	bne.s	2$
	addq.w	#1,d5
2$:	move.b	(a0)+,d1
	beq.s	9$			; fertig ?
	sub.b	#',',d1
	beq.s	9$
	subq.b	#3,d1			; '/' kuendigt ein weiteres Register an
	beq.s	1$
	addq.b	#2,d1			; '-' Register-Range ?
	bne.s	gregl_error		; unbekanntes Zeichen ?
	bsr	GetRegister		; Range-Register holen
	bmi.s	10$
5$:	cmp.w	d0,d4
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
9$:	move.w	d2,d0			; RegBits(Src)
	swap	d0
	move.w	d3,d0			; RegBits(Dest)
	move.w	d5,d1			; Anzahl der Register
	movem.l	(sp)+,d2-d5/d7
	rts
10$:	move.b	-1(a0),d0		; 'Dn-m' oder 'An-m' ?
	cmp.b	#'0',d0
	blo.s	gregl_unknown
	cmp.b	#'7',d0
	bhi.s	gregl_unknown
	cmp.b	#'-',-2(a0)
	bne.s	gregl_unknown
	moveq	#7,d1
	and.w	d0,d1
	moveq	#8,d0
	and.w	d4,d0
	or.w	d1,d0
	bra.s	5$
gregl_error:
	tst.b	Pass(a5)
	beq.s	gregl_unknown
	moveq	#29,d0			; Illegal seperator for a register list
	bsr	Error
gregl_unknown:
	moveq	#0,d0
	moveq	#-1,d1
	movem.l	(sp)+,d2-d5/d7
	rts


	cnop	0,4
GetRegister:
; Versucht ein Register zu erkennen und gibt bei Erfolg 0-7 fuer ein Data-Reg.
; und 8-15 fuer ein Address-Reg. zurueck
; a0 = InputStream
; -> d0 = RegNr (negativ = Error)
; -> a0 = neue InputStream Position
	movem.l	d2/a2-a3,-(sp)
	lea	Buffer(a5),a2
	move.l	a0,a3
	move.l	a2,a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; RegisterName in Buffer holen
	beq.s	9$			; nichts lesen können ?
	add.w	d0,a3
	move.w	d0,d2
	subq.w	#2,d0			; Länge 2 ?
	bne.s	2$
	move.l	a2,a0
	moveq	#-$21,d1
	and.b	(a0)+,d1
	moveq	#8,d0
	sub.b	#'A',d1			; An ?
	beq.s	1$
	moveq	#0,d0
	subq.b	#3,d1			; Dn ?
	beq.s	1$
	sub.b	#15,d1			; SP ?
	bne.s	2$
	moveq	#-$21,d1
	and.b	(a0),d1
	cmp.b	#'P',d1
	bne.s	2$
	moveq	#15,d0
	bra.s	8$
1$:	move.b	(a0),d1
	sub.b	#'0',d1			; RegisterNr. n zwischen 0 und 7 ?
	blo.s	2$
	cmp.b	#7,d1
	bhi.s	2$
	add.b	d1,d0			; Register-Nr.
8$:	move.l	a3,a0
	movem.l	(sp)+,d2/a2-a3
	rts
9$:	moveq	#-1,d0			; -1: Symbol unbekannt
	move.l	a3,a0
	movem.l	(sp)+,d2/a2-a3
	rts
2$:	move.l	a2,a0
	move.w	d2,d0
	bsr.s	FindRegName
	bmi.s	9$			; existiert nicht ?
	move.l	d0,-(sp)
	tst.b	RefFlag(a5)		; Referenzen eintragen?
	beq.s	5$
	tst.b	LocalRegName(a5)
	bne.s	5$
	lea	RegRefs(a5),a0		; Registerreferenz vermerken
	IFEQ	MAXREGNAMES-64
	lsl.w	#8,d0
	add.w	d0,a0
	ELSE
	mulu	#MAXREGNAMES<<2,d0
	add.l	d0,a0
	ENDC
	moveq	#MAXREGNAMES-1,d0
	sub.w	d1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),d0		; erster RegRefList-Chunk
3$:	move.l	d0,a2
	cmp.w	#REGREFLISTBLK/rrlSIZE,rrl_NumRefs(a2)
	blo.s	4$			; Chunk voll?
	move.l	(a2),d0			; Link holen
	bne.s	3$
	bsr	GetRegRefList		; Neuen Chunk holen und verbinden
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
5$:	move.l	a3,a0
	move.l	(sp)+,d0
	movem.l	(sp)+,d2/a2-a3
	rts


	cnop	0,4
FindRegName:
; a0 = RegName
; d0 = Namenslänge
; -> d0 = Reg(0-15) oder -1
; -> d1 = MAXREGNAMES-1-ListOffset
	movem.l	d2-d6/a2-a3,-(sp)
	move.l	a0,d6
	move.w	d0,d4
	beq.s	5$			; Länge 0 - nichts gefunden
	IFND	DOTNOTLOCAL
	cmp.b	#'.',(a0)		; Lokale Registerdefinition?
	beq.s	10$
	ENDIF
	cmp.b	#'$',-1(a0,d0.w)
	bne.s	11$
10$:	st	LocalRegName(a5)
	bsr	FindLocalPart
	beq.s	5$
	move.l	d0,a0
	move.l	lp_LocRegNames(a0),d0	; Lokale EQURs durchsuchen
	beq.s	5$
	move.l	d0,a3
	moveq	#MAXLOCREGNAMES-1,d5
	move.l	#MAXLOCREGNAMES<<2,d2
	bra.s	12$
11$:	lea	RegNames(a5),a3		; Globale EQURs durchsuchen
	moveq	#MAXREGNAMES-1,d5
	move.l	#MAXREGNAMES<<2,d2
	clr.b	LocalRegName(a5)
12$:	moveq	#15,d3
1$:	move.l	a3,a2
	move.w	d5,d1
2$:	move.l	(a2)+,d0		; Zeiger auf nächsten RegName holen
	beq.s	4$
	move.l	d0,a0
	move.l	d6,a1
	move.w	d4,d0
3$:	cmpm.b	(a0)+,(a1)+		; Namen vergleichen
	dbne	d0,3$
	beq.s	6$
7$:	dbf	d1,2$			; nächster Name fuer dieses Register
4$:	add.l	d2,a3
	dbf	d3,1$			; nächstes Register
5$:	moveq	#-1,d0			; nichts gefunden!
	movem.l	(sp)+,d2-d6/a2-a3
	rts
6$:	moveq	#15,d0
	sub.w	d3,d0			; dem Namen entsprechendes Register
	movem.l	(sp)+,d2-d6/a2-a3
	rts


AddRegName:
; a0 = RegName, d0 = Register(0-15)
	movem.l	d2/a2,-(sp)
	move.l	a0,a2
	move.w	d0,d2
	moveq	#-1,d0
4$:	tst.b	(a0)+			; Länge von RegName bestimmen
	dbeq	d0,4$
	not.w	d0
	move.l	a2,a0
	bsr	FindRegName		; existiert Symbol schon als RegName?
	bmi.s	1$
	cmp.w	d2,d0			; für dasselbe Reg. nochmal definiert?
	beq.s	9$
	moveq	#18,d0			; Symbol declared twice
	bsr	Error
	bra.s	9$
1$:	move.l	a2,a0
	bsr	AddString
	tst.b	LocalRegName(a5)	; lokales Registersymbol?
	bne	AddLocalRegName
	lea	RegNames(a5),a0
	lea	RegRefs(a5),a2
	IFEQ	MAXREGNAMES-64
	lsl.w	#8,d2
	add.w	d2,a0
	add.w	d2,a2
	ELSE
	mulu	#MAXREGNAMES<<2,d2
	add.l	d2,a0
	add.l	d2,a2
	ENDC
	moveq	#MAXREGNAMES-1,d1
2$:	addq.l	#4,a2
	tst.l	(a0)+
	dbeq	d1,2$
	beq.s	3$
	moveq	#1,d0			; Out of memory
	bsr	Error
	bra.s	9$
3$:	move.l	d0,-4(a0)		; Zeiger auf Namen eintragen
	bsr	GetRegRefList		; Referenzliste anlegen
	move.l	d0,-4(a2)
	move.l	d0,a0
	IFND	GIGALINES
	move.w	AbsLine(a5),rrl_DeclLine(a0)
	ELSE
	move.l	AbsLine(a5),rrl_DeclLine(a0)
	ENDC
9$:	movem.l	(sp)+,d2/a2
	rts

AddLocalRegName:
; d0 = NamePtr, d2 = Register (0-15)
	move.l	d0,a2
	tst.b	Pass(a5)		; In Pass2 nur noch in vorhandene LocalParts
	beq.s	1$			;  einsetzen
	bsr	FindLocalPart
	bne.s	2$
	moveq	#66,d0			; Unknown Error (eigentlich nicht möglich)
	bsr	Error
	bra	9$
1$:	bsr	OpenLocalPart		; Pass1 neuen LocalPart öffnen, wenn nötig
2$:	move.l	d0,a0			; LocalPart
	move.l	lp_LocRegNames(a0),d0
	bne.s	3$
	move.l	a0,-(sp)
	bsr	GetLocalRegs
	move.l	(sp)+,a0
	move.l	d0,lp_LocRegNames(a0)
3$:	move.l	d0,a0
	IFEQ	MAXLOCREGNAMES-16
	lsl.w	#6,d2
	add.w	d2,a0
	ELSE
	mulu	#MAXLOCREGNAMES<<2,d2
	add.l	d2,a0
	ENDC
	moveq	#MAXLOCREGNAMES-1,d1
4$:	tst.l	(a0)+
	dbeq	d1,4$
	beq.s	5$
	moveq	#1,d0			; Out of memory
	bsr	Error
	bra.s	9$
5$:	move.l	a2,-4(a0)		; Zeiger auf Namen eintragen
9$:	movem.l	(sp)+,d2/a2
	rts


	cnop	0,4
AddGorLSymbol:
; Fuegt das Symbol entweder der globalen oder lokalen Symbol-Table zu,
; je nach Zustand des Local-Flags
	tst.b	Local(a5)
	beq	AddSymbol


AddLocalSymbol:
; Symbol in die lokale Symbol-Table aufnehmen
; a0 = NameString
; d0 = Type
; d1 = Value
	movem.l	d2-d5/a2-a3,-(sp)
	move.l	a0,a2
	move.w	d0,d3
	move.l	d1,d2
	and.w	#T_ABS|T_EQU|T_FREG|T_REG|T_DIST,d0
	beq.s	2$			; SET, MACRO oder XREFs sind verboten
	IFND	FREEASS
	tst.b	IgnoreCase(a5)		; Groß/Kleinschreibung ignorieren?
	beq.s	3$
	moveq	#0,d5
	moveq	#0,d0
	lea	ucase_tab(a5),a1
1$:	addq.w	#1,d5			; Uppercase-Konvertierung
	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	bne.s	1$
	subq.w	#1,d5
	bra.s	5$
	ENDC
2$:	moveq	#30,d0
	bsr	Error
	bra	99$
3$:	moveq	#-1,d5
4$:	tst.b	(a0)+			; d5 SymbolName-Len
	dbeq	d5,4$
	not.w	d5
5$:	tst.b	Pass(a5)		; In Pass2 nur noch in vorhandene LocalParts
	beq.s	6$			;  einsetzen
	bsr	FindLocalPart		; -> a0 = HashTable
	bne.s	7$
	moveq	#66,d0			; Unknown Error (eigentlich nicht möglich)
	bsr	Error
	bra	99$
6$:	bsr	OpenLocalPart		; Pass1 neuen LocalPart öffnen, wenn nötig
7$:	move.l	d0,a3			; LocalPart
	move.l	a2,a1
	HASHC	a1,d0,d1,d4		; Hashcode für dieses Symbol berechnen > d0
	and.w	LocHashMask(a5),d0
	lsl.l	#2,d0
	move.l	a2,d4			; d4 Symbolname
	move.l	(a0,d0.l),d1		; an dieser Stelle schon benutzt worden?
	bne.s	8$
	lea	(a0,d0.l),a2
	bra.s	10$
14$:	; Symbol existiert bereits!
	IFND	FREEASS
	tst.b	Pass(a5)		; In Pass 1 ist das garantiert ein Fehler!
	beq.s	15$
	tst.b	AssMode(a5)		; im Macro-Mode nicht beachten
	bmi	99$			; am_MACRO?
15$:
	ENDC
	moveq	#18,d0			; Symbol was declared twice !
	bsr	Error
	bra	99$
8$:	move.l	d1,a2			; Hash Chain durchgehen...
	move.l	sym_Name(a2),a0		; Symbol Name
	move.l	d4,a1			;  mit gesuchtem vergleichen
	move.w	d5,d0
9$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,9$
	beq.s	14$			; Symbol existiert bereits!
	move.l	sym_Next(a2),d1		; nächstes Symbol in der Hash Chain?
	bne.s	8$
10$:	move.l	lp_SymTab(a3),d0
11$:	move.l	d0,a3			; letzten LocalSymbolTab-Chunk suchen
	move.l	(a3),d0
	bne.s	11$
	move.l	lstab_FreeEntry(a3),d0
	bne.s	12$			; noch ein Platz frei ?
	bsr	GetLocalSymbolTable
	move.l	d0,(a3)			; neuen Chunk linken
	move.l	d0,a3
	move.l	lstab_FreeEntry(a3),d0
12$:	move.l	d0,sym_Next(a2)		; an die Hash Chain anhängen
	move.l	d0,a2
	clr.l	(a2)+
	move.l	d4,a0
	bsr	AddString		; SymbolName eintragen
	move.l	d0,(a2)+
	IFND	GIGALINES
	move.w	AbsLine(a5),(a2)+	; AbsLine als DeclLine
	ELSE
	move.l	AbsLine(a5),(a2)+
	ENDC
	move.w	d3,(a2)+		; Type
	move.l	d2,(a2)+		; Value
	clr.l	(a2)+			; ** keine RefList für LocalSymbols **
	move.l	a2,lstab_FreeEntry(a3)	; FreeEntry neu setzen
	addq.w	#1,LocSymCnt(a5)
	move.w	lstab_NumSymbols(a3),d0
	addq.w	#1,d0
	cmp.w	#LOCSYMBLK/SymbolSIZE,d0
	blo.s	13$			; SymbolTable voll ?
	clr.l	lstab_FreeEntry(a3)
13$:	move.w	d0,lstab_NumSymbols(a3)
99$:	movem.l	(sp)+,d2-d5/a2-a3
	rts


	cnop	0,4
OpenLocalPart:
; Falls der letzte nicht sowieso noch offen ist, wird ein neuer (leerer)
; LocalPart eingerichtet.
; -> d0 = LocalPart
; -> a0 = LocalHashTable
	movem.l	a2-a3,-(sp)
	move.l	LocPartsPtr(a5),d0
1$:	move.l	d0,a3
	move.l	(a3),d0			; letzten LocalParts Chunk suchen
	bne.s	1$
	move.w	lp_NumParts(a3),d1
	beq.s	5$			; kein LP existent? (Dann sowieso neu!)
	move.w	d1,d0
	subq.w	#1,d0
	mulu	#lpSIZE,d0
	lea	lp_HEAD(a3,d0.l),a0
	IFND	GIGALINES
	cmp.w	#-1,lp_EndLine(a0)	; LocalPart noch offen ?
	ELSE
	moveq	#-1,d0
	cmp.l	lp_EndLine(a0),d0
	ENDC
	bne.s	3$
	move.l	a0,d0			; LocalPart
	move.l	lp_HashTab(a0),a0	; LocalHashTab
	bra.s	9$
3$:	cmp.w	#LOCALPARTSBLK/lpSIZE,d1 ; LocalParts-Chunk schon voll ?
	blo.s	5$
	bsr	GetLocalParts		; Neuen Chunk anfordern
	move.l	d0,(a3)			; und linken
	move.l	d0,a3
5$:	move.w	lp_NumParts(a3),d0
	mulu	#lpSIZE,d0
	lea	lp_HEAD(a3,d0.l),a2
	addq.w	#1,lp_NumParts(a3)
	move.l	a2,a3
	IFND	GIGALINES
	move.w	FirstLocalLine(a5),(a2)+
	move.w	#-1,(a2)+		; EndLine ist noch offen
	ELSE
	move.l	FirstLocalLine(a5),(a2)+
	moveq	#-1,d1
	move.l	d1,(a2)+		; EndLine ist noch offen
	ENDC
	bsr	GetLocalSymbolTable
	move.l	d0,(a2)+		; SymTab
	bsr	GetLocalHashTable
	move.l	d0,(a2)			; HashTab
	move.l	d0,a0
	move.l	a3,d0
9$:	movem.l	(sp)+,a2-a3
	rts


	cnop	0,4
AddSymbol:
; Symbol in die globale Symbol-Table aufnehmen
; a0 = NameString
; d0 = Type
; d1 = Value
	movem.l	d2-d7/a2-a3,-(sp)
	move.w	d0,d2
	move.l	d1,d3
	move.l	a0,a3
	IFND	FREEASS
	tst.b	IgnoreCase(a5)		; Nur Grossbuchstaben?
	beq.s	3$
	moveq	#0,d5
	moveq	#0,d0
	lea	ucase_tab(a5),a1
1$:	addq.w	#1,d5
	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	bne.s	1$
	subq.w	#1,d5
	bra.s	5$
	ENDC
3$:	moveq	#-1,d5
4$:	tst.b	(a0)+			; d5 SymbolName-Len
	dbeq	d5,4$
	not.w	d5
5$:	move.l	a3,a0
	HASHC	a0,d0,d1,d4		; Hashcode für dieses Symbol berechnen > d0
	and.w	GloHashMask(a5),d0
	lsl.l	#2,d0
	move.l	SymHashList(a5),a0	; Hash Table
	move.l	(a0,d0.l),d1		; an dieser Stelle schon benutzt worden?
	beq	addsym_newchain
6$:	move.l	d1,a2			; Hash Chain durchgehen...
	move.l	sym_Name(a2),a0		; Symbol Name
	move.l	a3,a1			;  mit gesuchtem vergleichen
	move.w	d5,d0
7$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,7$
	beq.s	addsym_exists
	move.l	sym_Next(a2),d1		; nächstes Symbol in der Hash Chain?
	bne.s	6$
	bra	addsym_new		; Neues Symbol anhängen

addsym_exists:
	move.w	d2,d0
	and.w	#T_PUBLIC|T_XREF|T_XDEF|T_NREF,d0
	beq.s	10$			; Symbol 'external' machen ?
20$:	and.w	#T_XREF|T_NREF,d2	; XREF/NREF kann nur extern definiert werden
	beq.s	21$
	cmp.w	sym_Type(a2),d2		; darf aber ruhig mehrere Male dekl. werden
	beq.s	22$
	moveq	#19,d0			; Unable to declare XREF-symbol
	bra.s	11$

21$:	move.w	sym_Type(a2),d0		; Vorhandenes Symbol zu XDEF machen:
	and.w	#T_ABS|T_EQU,d0		; nur mit EQU oder ABS moeglich
	bne.s	23$
	move.w	#T_PUBLIC|T_XDEF|T_XREF,d0
	and.w	sym_Type(a2),d0		; XREF/XDEF/PUBLIC darf ruhig mehrere
	bne.s	22$			;  Male deklariert werden
	moveq	#17,d0			; Symbol can't be defined as external
	bra.s	11$
23$:	bset	#bit_XDEF-8,sym_Type(a2)
	bne.s	22$			; AddExternal nur einmal fuer jedes Symbol
	and.w	#T_EQU,d0
	bne.s	24$
	move.l	CurrentSec(a5),a3
	move.l	sym_RefList(a2),a0
	move.w	rlist_DeclHunk(a0),d2
	bsr	GetSectionPtr		; CurrentSection auf DeclHunk des Symbols
	move.l	a0,CurrentSec(a5)
	move.l	a2,a0
	bsr	AddExternal		; XDEF-Symbol in HunkExtTable vermerken
	move.l	a3,CurrentSec(a5)
	bra	addsym_exit
24$:	move.l	a2,a0
	bsr	AddExtAbs		; XDEF-Equate
	bra	addsym_exit

10$:	move.w	sym_Type(a2),d0		; ABS,EQU,FREG,REG,MACRO,DIST
	move.w	d0,d1			;  nicht zweimal def.bar
	and.w	#T_ABS|T_EQU|T_FREG|T_REG|T_MACRO|T_DIST,d1
	beq.s	1$
	IFND	FREEASS
	tst.b	Pass(a5)		; In Pass 1 ist das garantiert ein Fehler!
	beq.s	12$
	tst.b	AssMode(a5)		; Im Macro-Mode wird darueber hinweg gesehen !
	bmi	addsym_exit		; am_MACRO?
12$:
	ENDC
	moveq	#18,d0			; Symbol declared twice !
11$:	bsr	Error
22$:	bra	addsym_exit

	IFND	SMALLASS		; SET-Symbol ändern
25$:	cmp.w	d0,d2			; Typ immer noch derselbe?
	bne.s	27$
	and.w	#T_DOUBLE|T_EXTENDED|T_PACKED,d0
	beq	addsym_setvalue		; 64- oder 96-bit Float-SET ?
	move.l	d3,a0
	move.l	sym_Value(a2),a1
	move.l	(a0)+,(a1)+		; neuen Float-Wert übertragen
	move.l	(a0)+,(a1)+
	and.w	#T_DOUBLE,d0
	bne.s	26$			; 96-Bit ?
	move.l	(a0),(a1)
26$:	bra	addsym_newdecl
27$:	moveq	#89,d0			; Type of SET can't be changed!
	bra.s	11$
	ENDC
1$:	move.w	d0,d1
	and.w	d2,d1
	btst	#bit_SET,d1		; vorher und jetzt, als SET definiert ?
	IFND	SMALLASS
	bne.s	25$
	ELSE
	bne	addsym_setvalue
	ENDC
	btst	#bit_XREF,d0		; XREF kann nur extern definiert werden
	beq.s	3$
	moveq	#19,d0			; Unable to declare XREF-symbol
	bra.s	11$
3$:	btst	#bit_PUBLIC,d0		; bereits als PUBLIC definiert ?
	beq.s	4$
	move.w	#T_XDEF,d0		; - dann ist es jetzt XDEF !
4$:	move.w	d2,d1
	and.w	#T_ABS|T_EQU,d1		; nur ABS und EQU als XDEF moeglich !
	bne.s	5$
	moveq	#17,d0			; Symbol can't be defined as external
	bra.s	11$
5$:	or.w	d2,d0			; Typ mit XDEF verbinden
	move.w	d0,sym_Type(a2)
	moveq	#-1,d5
	and.w	#T_EQU,d1
	beq.s	51$			; XDEF-Equate?
52$:	move.l	a2,a0
	bsr	AddExtAbs
	bra.s	9$
51$:	move.l	CurrentSec(a5),d1	; noch keine Section definiert ?
	bne.s	6$
	moveq	#0,d4
	bsr	CSeg			; Normales Code-Segment erstellen
	move.l	CurrentSec(a5),d1
6$:	move.l	d1,a0
	tst.w	sec_Type+2(a0)		; OFFSET-Section aktiv?
	bne.s	62$
	bclr	#bit_ABS,sym_Type+1(a2)	; dann in Equate umwandeln
	bset	#bit_EQU,sym_Type+1(a2)
	bra.s	52$
62$:	btst	#bit_DIST,d2
	beq.s	61$
	move.w	SecNum(a5),d5		; bei DIST den DeclHunk setzen
	bra.s	7$
61$:	and.w	#T_ABS,d2
	beq.s	7$
	btst	#sw_SYMDEBUG,Switches(a5)
	beq.s	8$
	move.l	a2,a0
	bsr	AddDebugSymbol		; RelocSymbol bei SYMDEBUG in HunkSymbolTable
8$:	move.w	SecNum(a5),d5		; bei Reloc den DeclHunk setzen
7$:	move.l	a2,a0
	bsr	AddExternal		; XDEF-Symbol in HunkExtTable vermerken
9$:	move.l	sym_RefList(a2),a0
	move.w	d5,rlist_DeclHunk(a0)
addsym_setvalue:
	move.l	d3,sym_Value(a2)	; neuen Wert einsetzen
addsym_newdecl:
	IFND	GIGALINES
	move.w	AbsLine(a5),sym_DeclLine(a2)
	ELSE
	move.l	AbsLine(a5),sym_DeclLine(a2)
	ENDC
	bra	addsym_exit

addsym_newchain:
	lea	-sym_Next(a0,d0.l),a2
addsym_new:
; a2 = Adresse des bisher letzten Symbols in der Hash Chain
	btst	#bit_ABS,d2
	beq.s	1$
	move.l	CurrentSec(a5),d0	; ABS-Sym. und noch keine Section definiert ?
	bne.s	10$
	moveq	#0,d4
	bsr	CSeg			; Normales Code-Segment erstellen
	move.l	CurrentSec(a5),d0
10$:	move.l	d0,a0
	tst.w	sec_Type+2(a0)		; OFFSET-Section?
	bne.s	1$
	and.w	#~T_ABS,d2
	or.w	#T_EQU,d2		; dann in Equate umwandeln
1$:	move.l	a3,d6
	lea	SymbolTable(a5),a3
11$:	move.l	(a3),a3
	move.l	stab_FreeEntry(a3),d7	; freien Eintrag in der Symbol Table suchen
	beq.s	11$
	move.l	d7,sym_Next(a2)		; an die Hash Chain anhängen
	move.l	d7,a2			; a2 Neues Symbol
	clr.l	(a2)+
	move.l	d6,a0
	bsr	AddString
	move.l	d0,(a2)+		; SymbolName
	IFND	GIGALINES
	move.w	AbsLine(a5),(a2)+	; DeclarationLine
	ELSE
	move.l	AbsLine(a5),(a2)+
	ENDC
	move.w	d2,(a2)+		; Type
	IFND	SMALLASS
	move.w	#T_SET|T_DOUBLE|T_EXTENDED|T_PACKED,d0
	and.w	d2,d0
	bne.s	6$			; SET?
	ENDC
5$:	move.l	d3,(a2)+		; Value
	bsr	GetReferenceList
	move.l	d0,(a2)+		; RefList
	move.l	a2,stab_FreeEntry(a3)
	move.l	d0,a2
	moveq	#-1,d5
	btst	#bit_DIST,d2
	beq.s	7$
	move.w	SecNum(a5),d5		; bei DIST den DeclHunk setzen
	bra.s	2$
6$:
	IFND	SMALLASS
	and.w	#T_DOUBLE|T_EXTENDED|T_PACKED,d0
	beq.s	5$			; Normales LONG-SET?
	move.l	d3,d0
	bsr	AddLongFloat		; Speicher für 64- oder 96-Bit Float
	move.l	d0,d3			; (benötigt OpcodeSize - diese ist aber garan-
	bra.s	5$			;  tiert, da immer nur von SET aus aufgerufen)
	ENDC
7$:	and.w	#T_ABS,d2
	beq.s	2$
	btst	#sw_SYMDEBUG,Switches(a5)
	beq.s	3$
	move.l	d7,a0
	bsr	AddDebugSymbol		; RelocSymbol bei SYMDEBUG in HunkSymbolTable
3$:	move.w	SecNum(a5),d5		; bei Reloc den DeclHunk setzen
2$:	move.w	d5,rlist_DeclHunk(a2)

	addq.w	#1,SymbolCnt(a5)
	move.w	stab_NumSymbols(a3),d0	; 1 Symbol mehr im Chunk
	addq.w	#1,d0
	move.w	d0,stab_NumSymbols(a3)
	cmp.w	#SYMBOLBLK/SymbolSIZE,d0
	blo.s	addsym_exit		; SymbolTable-Chunk jetzt voll ?
	bsr	GetSymbolTable		; Speicher fuer neue SymbolTable
	move.l	d0,(a3)			; linken
	clr.l	stab_FreeEntry(a3)
addsym_exit:
	movem.l	(sp)+,d2-d7/a2-a3
	rts


	cnop	0,4
CloseLocalPart:
; Kennzeichnet den letzten, offenen LocalPart als in der vorhergehenden
; Zeile beendet
; (z.B. nach GlobalSymbol-Deklaration oder nach wechseln einer Section)
; Die FirstLocalLine fuer den naechsten LocalPart wird dabei auf die
; aktuelle Zeile gesetzt.
	IFND	GIGALINES
	move.w	AbsLine(a5),d1
	ELSE
	move.l	AbsLine(a5),d1
	ENDC
	move.l	LocPartsPtr(a5),d0
1$:	move.l	d0,a0
	move.l	(a0),d0			; Letzten LocalParts-Chunk suchen
	bne.s	1$
	move.w	lp_NumParts(a0),d0	; keiner vorhanden ?
	beq.s	3$
	subq.w	#1,d0
	mulu	#lpSIZE,d0
	lea	lp_HEAD+lp_EndLine(a0,d0.l),a0
	IFND	GIGALINES
	cmp.w	#-1,(a0)		; Part noch offen ?
	bne.s	3$
	move.w	d1,d0
	subq.w	#1,d0
	move.w	d0,(a0)			; letzte Zeile des LocalParts
3$:	move.w	d1,FirstLocalLine(a5)
	rts
	ELSE
	moveq	#-1,d0
	cmp.l	(a0),d0			; Part noch offen ?
	bne.s	3$
	move.l	d1,d0
	subq.l	#1,d0
	move.l	d0,(a0)			; letzte Zeile des LocalParts
3$:	move.l	d1,FirstLocalLine(a5)
	rts
	ENDC


	cnop	0,4
AddReference:
; Neue Referenz auf ein Symbol eintragen.
; ** a0 wird gerettet **
; a0 = Symbol
; d0 = RefType
; d1 = RefAddr
	tst.b	RefFlag(a5)
	beq.s	10$			; Keine Referenz eintragen ?
	movem.l	d2-d3/a0/a2,-(sp)
	move.b	d0,d2
	move.l	d1,d3
	move.l	sym_RefList(a0),d0
	bne.s	5$
	bra.s	9$			; Symbol will keine Referenz haben
1$:	move.l	(a2),d0			; letzten Chunk suchen
	beq.s	2$
5$:	move.l	d0,a2
	bra.s	1$
2$:	move.w	rlist_NumRefs(a2),d1
	bpl.s	3$			; Chunk voll ?
	bsr	GetReferenceList	;  Neuen Chunk besorgen und verketten
	move.l	a2,a0
	move.l	d0,(a0)
	move.l	d0,a2
	move.w	rlist_DeclHunk(a0),rlist_DeclHunk(a2)
	moveq	#0,d1
3$:	moveq	#1,d0
	add.w	d1,d0			; Neuer NumRefs-Wert
	cmp.w	#REFLISTBLK/rlistSIZE,d0
	blo.s	4$			; Chunk jetzt voll ?
	moveq	#-1,d0			; Naechstesmal neuen Chunk besorgen
4$:	move.w	d0,rlist_NumRefs(a2)
	IFEQ	rlistSIZE-8
	lsl.w	#3,d1			; *8 (Groesse eines Eintrags)
	ELSE
	mulu	#rlistSIZE,d1
	ENDC
	lea	rlist_HEAD(a2,d1.w),a2
	move.w	LastRefCnt(a5),d0	; Zeiger auf Ref.-Eintrag in Liste vermerken
	cmp.w	#MAXLASTREFS*4,d0
	bhs.s	6$
	lea	LastRefs(a5),a0
	move.l	a2,(a0,d0.w)
	addq.w	#4,LastRefCnt(a5)
6$:	move.b	SecNum+1(a5),(a2)+	; Reference-Hunk
	move.b	d2,(a2)+		; RefType
	IFND	GIGALINES
	move.w	AbsLine(a5),(a2)+	; RefLine als AbsLine
	ELSE
	move.l	AbsLine(a5),(a2)+
	ENDC
	move.l	d3,(a2)			; RefAddr
9$:	movem.l	(sp)+,d2-d3/a0/a2
10$:	rts


	cnop	0,4
ChangeLastRefs:
; d0 = NewRefType
; d1 = RefAddr-Offset
; *** d0 und d1 werden nicht veraendert!!!
	move.l	d2,-(sp)
	lea	LastRefs(a5),a0
	move.w	LastRefCnt(a5),d2
	beq.s	3$
	tst.b	d0			; RefType nicht aendern ?
	beq.s	2$
1$:	move.l	(a0)+,a1
	move.b	d0,rlist_Type-rlist_HEAD(a1)
	add.l	d1,rlist_RelAdr-rlist_HEAD(a1)
	subq.w	#4,d2
	bne.s	1$
	move.l	(sp)+,d2
	rts
2$:	move.l	(a0)+,a1
	add.l	d1,rlist_RelAdr-rlist_HEAD(a1)
	subq.w	#4,d2
	bne.s	2$
3$:	move.l	(sp)+,d2
	rts


	cnop	0,4
DelLastRefs:
; Alle Referenzen dieser Zeile durch Angabe einer illegal SecNum loeschen
	lea	LastRefs(a5),a0
	move.w	LastRefCnt(a5),d0
	beq.s	2$
1$:	move.l	(a0)+,a1
	st	rlist_Hunk-rlist_HEAD(a1)
	subq.w	#4,d0
	bne.s	1$
2$:	rts


	cnop	0,4
AddExtAbs:
; Absolutes XDEF-Symbol in die globale ExtAbsTable eintragen
; a0 = Symbol
	IFND	FREEASS
	tst.b	AbsCode(a5)		; Externals gibt's nur in Object-Files
	beq.s	1$
	bmi.s	1$
	moveq	#67,d0			; No externals in absolute mode
	bra	FatalError
	ENDC
1$:	move.l	ExtAbsPtr(a5),a1	; freier Platz in HunkExtTable
	move.l	a0,(a1)+
	move.l	a1,d0
	move.l	ExtAbsTab(a5),d1
2$:	move.l	d1,a1			; letzten HunkExt-Chunk suchen
	move.l	(a1),d1
	bne.s	2$
	lea	hext_HEAD+HEXTTABBLK(a1),a0
	cmp.l	a0,d0			; Chunk jetzt voll ?
	blo.s	3$
	move.l	a1,-(sp)
	bsr	GetHunkExtTable		; Speicher besorgen
	move.l	(sp)+,a1
	move.l	d0,(a1)			; linken
	addq.l	#hext_HEAD,d0
3$:	move.l	d0,ExtAbsPtr(a5)	; neuen freien Platz merken
	rts


	cnop	0,4
AddExternal:
; Zeiger auf ein Symbol in die HunkExtTable des aktuellen Hunks eintragen
; a0 = Symbol
	IFND	FREEASS
	tst.b	AbsCode(a5)		; Externals gibt's nur in Object-Files
	beq.s	2$
	moveq	#67,d0			; No externals in absolute mode
	bra	FatalError
	ENDC
2$:	move.l	a2,-(sp)
	move.l	CurrentSec(a5),a2
	move.l	sec_HETPt(a2),a1	; freier Platz in HunkExtTable
	move.l	a0,(a1)+
	move.l	a1,d0
	move.l	sec_HunkExtTable(a2),d1
3$:	move.l	d1,a1			; letzten HunkExt-Chunk suchen
	move.l	(a1),d1
	bne.s	3$
	lea	hext_HEAD+HEXTTABBLK(a1),a0
	cmp.l	a0,d0			; Chunk jetzt voll ?
	blo.s	1$
	move.l	a1,-(sp)
	bsr	GetHunkExtTable		; Speicher besorgen
	move.l	(sp)+,a1
	move.l	d0,(a1)			; linken
	addq.l	#hext_HEAD,d0
1$:	move.l	d0,sec_HETPt(a2)	; neuen freien Platz merken
	move.l	(sp)+,a2
	rts


	cnop	0,4
AddDebugSymbol:
; Zeiger auf ein ABS-Symbol in die HunkSymbolTable fuer Debugger eintragen
; a0 = Symbol
	move.l	a2,-(sp)
	move.l	CurrentSec(a5),a2
	move.l	sec_HSTPt(a2),d0	; freier Platz in HunkSymbolTable
	beq.s	4$
	move.l	d0,a1
	move.l	a0,(a1)+
	move.l	a1,d0
	move.l	sec_HunkSymbolTable(a2),a1
2$:	move.l	(a1),d1			; letzten HunkSymbol-Chunk suchen
	beq.s	3$
	move.l	d1,a1
	bra.s	2$
3$:	lea	hsym_HEAD+HSYMTABBLK(a1),a0
	cmp.l	a0,d0			; Chunk jetzt voll ?
	blo.s	1$
	move.l	a1,-(sp)
	bsr	GetHunkSymbolTable	; Speicher besorgen
	move.l	(sp)+,a1
	move.l	d0,(a1)			; linken
	addq.l	#hsym_HEAD,d0
1$:	move.l	d0,sec_HSTPt(a2)	; neuen freien Platz merken
4$:	move.l	(sp)+,a2
	rts


	cnop	0,4
ReplaceDistance:
; Fast wie AddDistance.
; Der einzige Unterschied besteht darin, dass die Angabe der Section nicht
; mehr noetig ist, da der zuletzt getaetigte Eintrag veraendert wird.
; a1=Adr, d0=Minuend, d1=Subtr., d2=FPOffset!, d3=Info|Width
; -> d0=Distance, d1=EntryPointer
	move.l	LastDistance(a5),a0
	movem.l	d0-d1/a1,(a0)		; Min., Sub., Addr
	move.b	d3,dist_Width-dist_HEAD(a0)
	swap	d3
	and.b	#$3f,dist_Info-dist_HEAD(a0) ; ShiftCnt nicht löschen
	or.b	d3,dist_Info-dist_HEAD(a0) ; Static? (Reloc wurde zu Near gemacht)
2$:	tst.l	dist_ListFilePointer-dist_HEAD(a0)
	beq.s	1$
	add.l	d2,dist_ListFilePointer-dist_HEAD(a0) ; FPOffset
1$:	sub.l	d1,d0
	move.l	a0,d1
	rts

	cnop	0,4
AddDistance:
; Fuegt der DistanceList dieser Section einen neuen Eintrag hinzu
;  a0 und d3 werden gerettet !
; a1 = Adresse an der die Distance eingetragen ist (Current Section)
; d0 = Minuend
; d1 = Subtrahend
; d2 = MSW:FilePtrOffset (wird auf aktuellen Filepointer addiert)
;      LSW:DistanceSection (Minuend und Subt. gehoeren in diese Section)
; d3 = MSW:Info Bit7:StaticSub(NEAR), 6:ShortBranch, 5-0:DistanceShift
;      LSW:DistanceWidth (os_BYTE,os_WORD,os_LONG, -1 bei EQU-Distanzen)
;
; -> d0 = Minuend-Subtrahend
; -> d1 = DistanceEntry-Pointer
	movem.l	d3-d5/a0/a2-a4,-(sp)
	move.l	a1,a4			; a4 Address retten
	move.l	d0,d4			; Minuend und Subtrahend retten
	move.l	d1,d5
	moveq	#SECLISTBLK/seclSIZE,d0
	move.l	SecTabPtr(a5),a3	; SecList
7$:	cmp.w	d0,d2			; Befinden wir uns im richtigen Chunk ?
	blo.s	1$
	move.l	(a3),a3			; sonst zum naechsten wechseln
	sub.w	d0,d2
	bra.s	7$
8$:	movem.l	DistVal(a5),d4-d5
	move.l	d4,(a0)+		; dist_Minuend
	move.l	d5,(a0)+		; dist_Subtrahend
	move.l	a4,(a0)+		; dist_Addr
	move.b	d3,(a0)+		; dist_Width
	swap	d3
	move.b	d0,d3			; ShiftCount setzen
	sub.l	d5,d4
	bclr	#5,d0
	bne.s	10$			; shifted Distance berechnen
	asl.l	d0,d4
	bra.s	9$
10$:	asr.l	d0,d4
	bra.s	9$
1$:	add.w	d2,d2
	add.w	d2,d2			; *4 (Groesse eines SecList-Eintrags)
	move.l	secl_HEAD(a3,d2.w),a3	; Section-Ptr holen
	move.l	sec_DistChunk(a3),a2
	move.l	dist_FreeEntry(a2),d0	; DistanceList-Chunk voll ?
	bne.s	2$
	bsr	GetDistanceList		; neuen Chunk besorgen
	move.l	d0,(a2)			; und anhaengen
	move.l	d0,sec_DistChunk(a3)
	move.l	d0,a2
	move.l	dist_FreeEntry(a2),d0
2$:	move.l	d0,LastDistance(a5)
	move.w	LastDistCnt(a5),d1
	cmp.w	#MAXLASTDISTS,d1
	bhs.s	6$
	lea	LastDists(a5),a0	; Ptr. auf alle Dist. zu einer Instr. merken
	add.w	d1,d1
	add.w	d1,d1
	move.l	d0,(a0,d1.w)
	addq.w	#1,LastDistCnt(a5)
6$:	move.l	d0,a0			; freier Eintrag
	move.l	a0,a3
	move.b	DistShift(a5),d0	; Shifted Distance speichern?
	bne.s	8$
	move.l	d4,(a0)+		; dist_Minuend
	move.l	d5,(a0)+		; dist_Subtrahend
	move.l	a4,(a0)+		; dist_Addr
	sub.l	d5,d4			; Distance ausrechnen
	move.b	d3,(a0)+		; dist_Width
	swap	d3
9$:	move.b	d3,(a0)+		; dist_Info: StaticSub/ShortBranch/ShiftCnt
	move.w	SecNum(a5),(a0)+	; dist_HunkNum: SectionNumber
	IFND	FREEASS
	move.l	ListFileHandle(a5),d1	; Listing File in Pass2 erzeugen ?
	beq.s	4$
	tst.b	Pass(a5)
	beq.s	4$
	moveq	#3,d0
	swap	d3
	and.b	d3,d0
	move.b	Columns(a5),d3
	clr.w	d2
	swap	d2
	sub.b	d2,d3
	cmp.b	addd_DSpc(pc,d0.w),d3	; genuegend Platz im Listing ?
	blt.s	4$
	move.l	d2,-(sp)
	move.l	a6,a4
	move.l	DosBase(a5),a6
	moveq	#0,d2
	moveq	#OFFSET_CURRENT,d3
	jsr	Seek(a6)		; aktuellen Filepointer holen
	move.l	a4,a6
	lea	dist_ListFilePointer-dist_HEAD(a3),a0
	add.l	(sp)+,d0		; Bei Adresse und/oder LoByteInWord verschieben
	move.l	d0,(a0)			; und speichern
	ENDC
4$:	addq.l	#4,a0
	move.l	a0,dist_FreeEntry(a2)
	lea	dist_HEAD+DISTLISTBLK(a2),a1
	cmp.l	a1,a0			; Chunk jetzt voll ?
	blo.s	5$
	clr.l	dist_FreeEntry(a2)	; naechstesmal neuen Speicher beschaffen
5$:	move.l	a3,d1			; Distance-Entry Pointer
	move.l	d4,d0			; Distance
	movem.l	(sp)+,d3-d5/a0/a2-a4
	rts
addd_DSpc:
	dc.b	3,5,9,80		; benoetigte Zchn. zur Darst. eines Byte,Word,Long


	cnop	0,4
ShiftLastDists:
; d0 = RelAddrOffset, d1 = ListFilePointerOffset
; *** d0&d1 werden nicht veraendert!!!
	move.l	d2,-(sp)
	lea	LastDists(a5),a1
	move.w	LastDistCnt(a5),d2
	bra.s	2$
1$:	move.l	(a1)+,a0
	add.l	d0,dist_Addr-dist_HEAD(a0)
	tst.l	dist_ListFilePointer-dist_HEAD(a0)
	beq.s	2$
	add.l	d1,dist_ListFilePointer-dist_HEAD(a0)
2$:	dbf	d2,1$
	move.l	(sp)+,d2
	rts


	cnop	0,4
DelLastDists:
; Alle in dieser Zeile eingetragenen Distanzen unbrauchbar machen
	lea	LastDists(a5),a1
	move.w	LastDistCnt(a5),d1
	moveq	#-1,d0
	bra.s	2$
1$:	move.l	(a1)+,a0
	move.l	d0,dist_Addr-dist_HEAD(a0)	; in EQU-Distanz umwandeln
2$:	dbf	d1,1$
	rts


ShowOptimization:
; Zeigt die Quelltextzeile zusammen mit der Zahl der gewonnenen Bytes an.
	movem.l	d0/d2/a0/a4,-(sp)
	move.l	AssModeName(a5),-(sp)
	IFND	GIGALINES
	move.w	Line(a5),-(sp)
	clr.w	-(sp)
	ELSE
	move.l	Line(a5),-(sp)
	ENDC
	IFND	FREEASS
	tst.b	AssMode(a5)
	bpl.s	2$			; Macro-Mode ?
	move.l	d0,d2
	LOCS	S_MACROERR
	move.l	sp,a1
	bsr	printf			; In line .. of macro .. :
	addq.l	#8,sp
	move.l	d2,d0
	move.l	MacNest(a5),a1
	move.l	nl_Name(a1),-(sp)
	IFND	GIGALINES
	move.w	nl_Line(a1),-(sp)
	clr.w	-(sp)
	ELSE
	move.l	nl_Line(a1),-(sp)
	ENDC
	ENDC
2$:
	IFND	GIGALINES
	move.w	AbsLine(a5),-(sp)	; Absolute ErrorLine
	clr.w	-(sp)
	ELSE
	move.l	AbsLine(a5),-(sp)
	ENDC
	pea	opt_txt(pc)
	neg.w	d0
	move.w	d0,-(sp)		; Zahl der gewonnenen Bytes
	move.l	LineBase(a5),-(sp)
	move.l	SrcPtr(a5),a4		; Zeiger auf Folge-Zeile
	move.b	-(a4),d2		; LF der gerade assembl. Zeile loeschen
	clr.b	(a4)
	LOCS	S_ERRLIN
	move.l	sp,a1
	bsr	printf
	lea	22(sp),sp
	move.b	d2,(a4)			; und wieder setzen
	movem.l	(sp)+,d0/d2/a0/a4
	rts

opt_txt:
	dc.b	"bytes optimized",0


	cnop	0,4
ShiftPC:
; ShiftRelocs wird fuer die BaseAddr PC gestartet, ausserdem wird
; ShiftDelta auf den PC (d6) addiert!
; d0 = ShiftDelta
	move.l	d6,a0
	add.l	d0,d6

ShiftRelocs:
; Verschiebt alle Reloc-Symbole ab einer bestimmten Adresse um den angegebenen
; Betrag (z.B. nach Aufloesen einer FwdRef oder durch eine Optimierung).
; Danach wird noch die DistanceList durchgesehen und die veraenderten Distanzen
; im Code berichtigt.
; a0 = BaseAddr
; d0 = ShiftDelta
	sub.l	d0,BytesGained(a5)

	btst	#sw2_SHOWOPTS,Switches2(a5)
	beq.s	ShiftRelocsNoOpt
	bsr	ShowOptimization	; Zeile mit Zahl der gew. Bytes zeigen
ShiftRelocsNoOpt:
	movem.l	d2-d5/d7/a2-a3,-(sp)
	movem.l	d6/a4,-(sp)
	move.l	d0,d7			; d7 = ShiftDelta, a0 = BaseAddr
	move.l	LastShiftPtr(a5),d0
	lea	LastShiftAddrs(a5),a1
	cmp.l	a1,d0			; Max.ShiftReloc Rekursionstiefe erreicht?
	bhi.s	1$
	moveq	#66,d0
	bra	FatalError
1$:	move.l	d0,a1
	move.l	a0,-(a1)		; Shift-BaseAddr für nächste Rekursion merken
	move.l	a1,LastShiftPtr(a5)
	moveq	#bit_ABS,d2
	IFND	GIGALINES
	move.w	AbsLine(a5),d3		; d3 = Absolute CurrentLine
	ELSE
	move.l	AbsLine(a5),d3
	ENDC
	move.w	SecNum(a5),d5		; d5 = SectionNumber
	move.l	LocPartsPtr(a5),d0	; ** Local Reloc-Symbols verschieben **
2$:	move.l	d0,a3
	lea	lp_HEAD(a3),a2
	move.w	lp_NumParts(a3),d4	; zu testende Parts in diesem Chunk
	subq.w	#1,d4
	bmi	shabs_Global		; kein LocalPart eingetragen ?
3$:
	IFND	GIGALINES
	cmp.w	lp_EndLine(a2),d3
	ELSE
	cmp.l	lp_EndLine(a2),d3
	ENDC
	bhi.s	8$			; LocalPart liegt noch vor der aktuellen Zeile
	move.l	lp_SymTab(a2),d0	; zu prüfende LocalSymbolTable
4$:	move.l	d0,a4
	move.w	lstab_NumSymbols(a4),d6
	subq.w	#1,d6
	bmi.s	8$			; kein Eintrag vorhanden ?
	cmp.w	lstab_DeclHunk(a4),d5	; Symbols gehören zur zu shiftenden Section ?
	bne.s	8$
	lea	lstab_HEAD(a4),a1	; erster Symbol-Eintrag
5$:	btst	d2,sym_Type+1(a1)	; Reloc-Symbol ?
	beq.s	6$
	cmp.l	sym_Value(a1),a0	; Größergleich als BaseAddr, dann versch.
;***	bgt.s	6$
	bhi.s	6$
	add.l	d7,sym_Value(a1)
6$:	lea	SymbolSIZE(a1),a1	; nächstes Symbol
	dbf	d6,5$
	move.l	(a4),d0			; noch ein Chunk ?
	bne.s	4$
8$:	lea	lpSIZE(a2),a2		; nächsten LocalPart
	dbf	d4,3$
	move.l	(a3),d0
	bne.s	2$			; noch ein Chunk ?

shabs_Global:				; ** Global Reloc-Symbols verschieben **
	movem.l	(sp)+,d6/a4
	move.l	SymbolTable(a5),d0
2$:	move.l	d0,a3
	lea	stab_HEAD(a3),a2	; erstes Symbol des Chunks
	move.w	stab_NumSymbols(a3),d4
	bra.s	5$
3$:	btst	d2,sym_Type+1(a2)	; Reloc-Symbol ?
	beq.s	4$
	move.l	sym_RefList(a2),a1
	cmp.w	rlist_DeclHunk(a1),d5	; Gleiche Section ?
	bne.s	4$
	cmp.l	sym_Value(a2),a0	; Groessergleich als BaseAddr, dann versch.
;***	bgt.s	4$
	bhi.s	4$
	add.l	d7,sym_Value(a2)
4$:	lea	SymbolSIZE(a2),a2
5$:	dbf	d4,3$
	move.l	(a3),d0			; noch ein Chunk ?
	bne.s	2$

shabs_DistList:				; ** Distanzen korrigieren **
	move.l	CurrentSec(a5),a1
	move.l	sec_Distances(a1),d4
1$:	move.l	d4,a1
	move.l	dist_FreeEntry(a1),d0	; Endmarkierung dieses Chunks finden
	move.l	d0,a3
	bne.s	2$
	lea	dist_HEAD+DISTLISTBLK(a1),a3
2$:	lea	dist_HEAD(a1),a2	; Erster Eintrag
3$:	cmp.l	a2,a3			; Chunk zuende ?
	beq.s	9$
	movem.l	(a2),d0-d1/a1		; dist_Minuend,Subtrahend,Addr
	move.l	d0,d2
	sub.l	d1,d2			; Distance
	cmp.l	a0,d0			; Minuend verschieben ?
;***	blt.s	4$
	blo.s	4$
	add.l	d7,d0
4$:	move.b	dist_Info-dist_HEAD(a2),d3
	bmi.s	6$			; Subtrahend static ?
	btst	#6,d3			; Short-Branch?
	bne.s	82$
	cmp.l	a0,d1			; Subtrahend verschieben ?
;***	blt.s	6$
	blo.s	6$
5$:	add.l	d7,d1
6$:	movem.l	d0-d1,(a2)		; dist_Minuend, dist_Subtrahend zurueckschr.
	sub.l	d1,d0			; Neue Distance stimmt mit alter ueberein ?
	cmp.l	d0,d2
	beq.s	8$
	move.l	a1,d1			; zu aendernde Adresse
	addq.l	#1,d1
	beq.s	8$			; -1: keine gesetzt, EQU-Definition
	subq.l	#1,d1
	and.w	#$3f,d3
	bne.s	80$			; shifted Distance?
7$:	move.w	dist_HunkNum-dist_HEAD(a2),d2 ; zugehoerige Section
	move.b	dist_Width-dist_HEAD(a2),d3 ; Distance-Width lesen
	bsr	SetSectionData		; korrigieren
	move.l	LastShiftPtr(a5),a0
	move.l	(a0),a0			; Veränderung durch Rekursion berücksichtigen
8$:	lea	distSIZE(a2),a2		; Nächsten Eintrag pruefen (+20)
	bra.s	3$
82$:	cmp.l	a0,d1			; Short-Branch Subtrahenden prüfen
;***	ble.s	6$
	bls.s	6$
	bra.s	5$
80$:	bclr	#5,d3
	bne.s	81$			; shifted Distance berechnen
	asl.l	d3,d0
	bra.s	7$
81$:	asr.l	d3,d0
	bra.s	7$
9$:	move.l	d4,a1
	move.l	(a1),d4			; Nächsten Chunk pruefen
	bne.s	1$

	tst.b	oper1+opType1(a5)	; ** gerade bearbeiteten Oper. korrigieren **
	bpl.s	10$
	move.l	oper1+opVal1(a5),a1
	cmp.l	a0,a1
;***	ble.s	10$
	bls.s	10$
	add.l	d7,a1
	move.l	a1,oper1+opVal1(a5)
10$:	tst.b	oper1+opType2(a5)
	bpl.s	11$
	move.l	oper1+opVal2(a5),a1
	cmp.l	a0,a1
;***	ble.s	11$
	bls.s	11$
	add.l	d7,a1
	move.l	a1,oper1+opVal2(a5)
11$:	tst.b	oper2+opType1(a5)
	bpl.s	12$
	move.l	oper2+opVal1(a5),a1
	cmp.l	a0,a1
;***	ble.s	12$
	bls.s	12$
	add.l	d7,a1
	move.l	a1,oper2+opVal1(a5)
12$:	tst.b	oper2+opType2(a5)
	bpl.s	13$
	move.l	oper2+opVal2(a5),a1
	cmp.l	a0,a1
;***	ble.s	13$
	bls.s	13$
	add.l	d7,a1
	move.l	a1,oper2+opVal2(a5)
13$:	tst.b	oper3+opType1(a5)
	bpl.s	14$
	move.l	oper3+opVal1(a5),a1
	cmp.l	a0,a1
;***	ble.s	14$
	bls.s	14$
	add.l	d7,a1
	move.l	a1,oper3+opVal1(a5)
14$:	tst.b	oper3+opType2(a5)
	bpl.s	15$
	move.l	oper3+opVal2(a5),a1
	cmp.l	a0,a1
;***	ble.s	15$
	bls.s	15$
	add.l	d7,a1
	move.l	a1,oper3+opVal2(a5)

15$:	move.l	LastShiftPtr(a5),a1	; ShiftBaseAddrs aus alten Rekursionen korr.
	addq.l	#4,a1
	move.l	a1,LastShiftPtr(a5)
	lea	LastShiftAddrs+MAXOPTSHIFTS*4(a5),a2
	bra.s	17$
16$:	cmp.l	(a1)+,a0
	bhi.s	17$
	add.l	d7,-4(a1)
17$:	cmp.l	a2,a1
	blo.s	16$
	movem.l	(sp)+,d2-d5/d7/a2-a3
	rts


	cnop	0,4
MakeSection:
; Neue Section (code, data, bss, offset) anlegen, oder in vorhandene einsteigen
; a0 = SectionName
; d0 = Type
; -> a0=SectionPtr und setzt ggf. in d6 die neue Addresse ein
	movem.l	d2-d4/a2-a4,-(sp)
	move.l	a0,a2
	move.l	d0,d2
	bsr	CloseLocalPart		; LocalSymbols anderer Sections sind unbekannt
	move.w	SectionCnt(a5),d3
	bne.s	maksec_search		; Noch gar keine vorhanden ? Dann neue !
	cmp.w	#HUNK_CODE,d2
	beq	maksec_new
	moveq	#0,d4
	bsr	CSeg			; Bevor eine andere Section eingerichtet wird,
	moveq	#1,d3			;  muss schon eine Code-Section existieren
	bra	maksec_new
maksec_search:
	moveq	#0,d3			; Zaehl die Sections mit
	move.l	SecTabPtr(a5),a4
3$:	lea	secl_HEAD(a4),a3
	move.l	secl_FreeEntry(a4),d4
	bne.s	4$			; SecList-Chunk noch nicht voll ?
	lea	SECLISTBLK(a3),a0
	move.l	a0,d4
1$:	move.l	(a3)+,a0
	cmp.l	sec_Type(a0),d2		; Section-Types stimmen ueberein ?
	bne.s	2$
	move.l	(a0),a0			; Section.Name
	move.l	a2,a1
	bsr	StrCmp			; vergleichen mit neuem Namen
	bne.s	2$
	move.l	CurrentSec(a5),a0	; Section-Adresse merken
	move.l	d6,sec_CurrentAdr(a0)	;  fuer Wiederaufruf
	move.l	-4(a3),a2
	move.w	d3,SecNum(a5)
	move.l	a2,CurrentSec(a5)
	move.l	sec_CurrentAdr(a2),d6
	move.l	a2,a0
	movem.l	(sp)+,d2-d4/a2-a4
	rts
2$:	addq.w	#1,d3
4$:	cmp.l	d4,a3			; Chunk-Ende erreicht ?
	bne.s	1$
	tst.l	secl_FreeEntry(a4)	; noch ein Chunk ?
	bne.s	5$
	move.l	(a4),a4
	bra.s	3$
5$:	move.l	CurrentSec(a5),a0	; Section-Adresse merken
	move.l	d6,sec_CurrentAdr(a0)	;  fuer Wiederaufruf

maksec_new:
	; Neue Section einrichten
	cmp.w	#MAXSECTIONS,d3
	blo.s	3$
	moveq	#16,d0			; Too many sections
	bsr	Error
	bra	maksec_exit
3$:	addq.w	#1,SectionCnt(a5)
	move.l	SecTabPtr(a5),a4	; freien Eintrag suchen
1$:	move.l	secl_FreeEntry(a4),d0
	bne.s	2$
	move.l	(a4),a4
	bra.s	1$
2$:	move.b	Switches(a5),d4
	move.l	d0,a3
	bsr	GetSection		; Speicher fuer Section-Struktur
	move.l	d0,(a3)+
	move.l	a3,secl_FreeEntry(a4)
	move.l	a2,a0			; SectionName
	move.l	d0,a2
	bsr	AddString
	move.l	d0,sec_Name(a2)		;  - eintragen
	move.l	CurrentSec(a5),d0
	beq.s	21$
	move.l	d0,a0
	move.b	sec_Flags(a0),OptFlag(a5)
21$:	move.b	OptFlag(a5),sec_Flags(a2)
	IFND	GIGALINES
	move.w	AbsLine(a5),sec_DeclLine(a2)
	ELSE
	move.l	AbsLine(a5),sec_DeclLine(a2)
	ENDC
	move.l	d2,sec_Type(a2)		; Type eintragen
	beq	5$			; OFFSET-Segment?
	tst.b	MainModel(a5)
	bmi.s	7$			; Near- oder Small-Data Modus?
	move.b	NearSec(a5),d1
	cmp.b	#-2,d1
	bhs.s	8$			; normale Near-Section Adressierung?
	cmp.b	d1,d3
	bne.s	7$			; ... und zwar mit der gerade generierten?
	bra.s	9$
8$:	cmp.w	#HUNK_CODE,d2		; Small Data (Code kommt dafür nicht in Frage)
	beq.s	7$
	addq.b	#1,d1			; normales SmallData (für ALLE Data/Bss) ?
	beq.s	9$
	move.l	sec_Name(a2),a0		; DATA oder BSS und Name = "__MERGED" ?
	lea	mergedName(pc),a1
	bsr	StrCmp
	bne.s	7$
9$:	st	sec_Near(a2)		; Diese Section kann NEAR adressiert werden!
7$:	cmp.w	#HUNK_BSS,d2		; oder BSS-Segment?
	beq.s	5$
	bsr	GetHunkData		; Speicher fuer HunkData-Struktur
	move.l	d0,sec_HunkData(a2)
	addq.l	#hd_HEAD,d0
	move.l	d0,sec_HunkDataPt(a2)
	move.l	#HUNKDATBLK,sec_FreeData(a2)
	bsr	GetHunkReloc		; Speicher fuer HunkReloc-Struktur
	move.l	d0,sec_HunkReloc(a2)
	bsr	GetHunkReloc
	move.l	d0,sec_HunkNearReloc(a2)
5$:	bsr	GetHunkExtTable		; Speicher fuer HunkExtTable-Struktur
	move.l	d0,sec_HunkExtTable(a2)
	addq.l	#hext_HEAD,d0
	move.l	d0,sec_HETPt(a2)
	btst	#sw_SYMDEBUG,d4
	beq.s	4$
	bsr	GetHunkSymbolTable	; HunkSymbolTable nur bei SYMDEBUG belegen
	move.l	d0,sec_HunkSymbolTable(a2)
	addq.l	#hsym_HEAD,d0
	move.l	d0,sec_HSTPt(a2)
4$:	bsr	GetDistanceList		; Speicher fuer DistanceList-Struktur
	move.l	d0,sec_Distances(a2)
	move.l	d0,sec_DistChunk(a2)
	bsr	GetLineDebugTab		; Speicher für LINE Debug-Hunk (SourceLevelDB)
	move.l	d0,sec_HunkLineDebug(a2)
6$:	lea	secl_HEAD+SECLISTBLK(a4),a0
	cmp.l	a0,a3			; SecList-Chunk jetzt voll ?
	bne.s	maksec_SecNum
	clr.l	secl_FreeEntry(a4)
	bsr	GetSecList		; Speicher fuer neuen SecList-Chunk
	move.l	d0,(a4)			; linken

maksec_SecNum:
	move.w	d3,SecNum(a5)		; Nummer und Position der aktuellen Section
	move.l	a2,CurrentSec(a5)
	move.l	sec_CurrentAdr(a2),d6	; Adress
	move.l	a2,a0
maksec_exit:
	movem.l	(sp)+,d2-d4/a2-a4
	rts

mergedName:
	dc.b	"__MERGED",0		; Name für SmallData-Sections im -2 Modus


	cnop	0,4
SetSectionData:
; Aendern eines Bytes/Words/LongWords einer beliebigen Section.
; Falls der Filepointer != 0 ist, wird das Byte/Word/Longword auch im
; aktuellen Listing file geaendert.
; d0 = Byte
; d1 = Addr
; d2 = SectionNum
; d3 = DataWidth
; a2 = Distance-Pointer
	movem.l	d4/a0/a3,-(sp)
	moveq	#SECLISTBLK/4,d4
	move.l	SecTabPtr(a5),a1	; SecList
1$:	cmp.w	d4,d2			; Befinden wir uns im richtigen Chunk ?
	blo.s	2$
	move.l	(a1),a1			; sonst zum naechsten wechseln
	sub.w	d4,d2
	bra.s	1$
2$:	add.w	d2,d2
	add.w	d2,d2			; *4 (Groesse eines SecList-Eintrags)
	move.l	secl_HEAD(a1,d2.w),a1	; Section-Ptr holen
	sub.l	sec_Origin(a1),d1	; d1 RelAddr relativ zum Section-Start
	cmp.l	sec_Size(a1),d1		; existiert der Code ueberhaupt schon ?
	bhs	9$
	move.l	sec_HunkData(a1),d2	; Erster HunkData-Chunk
	beq	9$			; NULL? Dann war's eine BSS-Section...
	move.l	d2,a1
	move.l	#HUNKDATBLK,d2		; Chunk-Groesse
	bra.s	4$
3$:	move.l	a1,a3			; a3 Vorgaenger-Chunk merken
	move.l	(a1),a1			; naechster Chunk
	sub.l	d2,d1
4$:	cmp.l	d2,d1			; Adresse liegt in diesem Chunk ?
	bhs.s	3$
	sub.l	d1,d2			; Zahl der Bytes ab RelAddr in diesem Chunk
	lea	hd_HEAD(a1,d1.l),a0	; Zu aendernde Adresse
	subq.b	#1,d3
	bpl	5$
	moveq	#127,d1			; Befindet sich das Byte noch im 8-bit Rahmen?
	cmp.l	d1,d0
	bgt.s	41$
	moveq	#-128,d1
	cmp.l	d1,d0
	bge.s	42$
41$:	tst.b	DistChkDisable(a5)
	bne.s	42$
	movem.l	d0/a0,-(sp)
	moveq	#43,d0			; Too large distance
	bsr	Error
	movem.l	(sp)+,d0/a0
42$:	move.b	d0,(a0)			; Byte ändern
	beq.s	44$			; Distanz=0.b? Gefährlich...
43$:
	IFND	FREEASS
	move.l	dist_ListFilePointer-dist_HEAD(a2),d2
	beq.s	9$
	lea	ListByte(pc),a0
	bsr	updateListing
	ENDC
	bra.s	9$
44$:	btst	#6,dist_Info-dist_HEAD(a2) ; Ist es ein B<cc>.B *+0 geworden?
	beq.s	43$
	subq.l	#1,a0
	move.w	#$4e71,(a0)		; durch NOP ersetzen
	clr.l	dist_Minuend-dist_HEAD(a2) ; Distanz-Eintrag hiernach löschen
	clr.l	dist_Subtrahend-dist_HEAD(a2)
	IFND	FREEASS
	move.l	dist_ListFilePointer-dist_HEAD(a2),d2
	beq.s	9$
	subq.l	#2,d2			; ganzes Word ändern, statt LoByte
	move.w	#$4e71,d0
	bra.s	54$
	ELSE
	bra.s	9$
	ENDC
	
5$:	subq.b	#1,d3
	bpl.s	6$
51$:	move.l	#$7fff,d1		; Word befindet sich im 16-bit Rahmen ?
	cmp.l	d1,d0
	bgt.s	52$
	not.l	d1
	cmp.l	d1,d0
	bge.s	53$
52$:	tst.b	DistChkDisable(a5)
	bne.s	53$
	movem.l	d0/a0,-(sp)
	moveq	#43,d0			; Too large distance
	bsr	Error
	movem.l	(sp)+,d0/a0
53$:	move.w	d0,(a0)			; Word aendern
	IFND	FREEASS
	move.l	dist_ListFilePointer-dist_HEAD(a2),d2
	beq.s	9$
54$:	lea	ListWord(pc),a0
	bsr	updateListing
	ENDC
9$:	movem.l	(sp)+,d4/a0/a3
	rts

55$:	; Near-Reloc im ObjectMode von $0000-$fffc
	subq.b	#os_NEARWORD-2,d3
	bne.s	10$
	cmp.l	#$fffc,d0
	bls.s	53$
	bra.s	52$
6$:	bne.s	55$
61$:	swap	d0
	move.w	d0,(a0)+		; Longword aendern
	swap	d0
	subq.l	#2,d2
	bne.s	7$			; Chunk mitten im Longword zuende ?
	move.l	(a1),a0
	addq.l	#hd_HEAD,a0		; naechster Chunk
7$:	move.w	d0,(a0)
	IFND	FREEASS
	move.l	dist_ListFilePointer-dist_HEAD(a2),d2
	beq.s	9$
	lea	ListLong(pc),a0
	bsr	updateListing
	ENDC
	bra.s	9$

10$:	subq.b	#os_BRANCH+os_WORD-os_NEARWORD,d3
	bne	20$
	moveq	#126,d1			; Ist nun ein 8-Bit Branch moeglich geworden?
	addq.l	#2,d1
	cmp.l	d1,d0
	bgt	51$
	movem.l	a0-a1,-(sp)
	move.l	CurrentSec(a5),a1
	move.l	sec_LastCnop(a1),d1
	cmp.l	dist_Addr-dist_HEAD(a2),d1 ; Liegt ein CNOP dazwischen?
	bls.s	11$
	movem.l	(sp)+,a0-a1
	bra	51$
11$:	cmp.l	#HUNKDATBLK,d2		; $6xxx liegt im Vorgaenger-Chunk?
	bne.s	12$
	move.b	d0,hd_HEAD-1(a3,d2.l)
	bra.s	13$
12$:	move.b	d0,-1(a0)
13$:	move.b	#os_BYTE,dist_Width-dist_HEAD(a2)
	IFND	FREEASS
	move.l	dist_ListFilePointer-dist_HEAD(a2),d2 ; Listingfile?
	beq.s	14$
	subq.l	#3,d2			; Offset ist jetzt drei Zeichen frueher!
	move.l	d2,dist_ListFilePointer-dist_HEAD(a2)
	and.w	#$00ff,d0
	subq.l	#2,sp
	move.w	d0,-(sp)
	move.l	a6,a3
	move.l	DosBase(a5),a6
	move.l	ListFileHandle(a5),d1
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)		; zu aendernde Pos. setzen, alte retten
	move.l	d0,d2
	exg	a3,a6
	move.l	sp,a1
	lea	lst_optBccB(pc),a0
	move.l	ListFileHandle(a5),d0
	bsr	fprintf
	addq.l	#4,sp
	exg	a3,a6
	move.l	ListFileHandle(a5),d1
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	move.l	a3,a6
	ENDC
14$:	movem.l	(sp)+,a0-a1
	bsr	MoveHunkData2
	or.b	#$40,dist_Info-dist_HEAD(a2) ; ShortBranch-Distance!
	move.l	dist_Addr-dist_HEAD(a2),a0
	subq.l	#1,dist_Addr-dist_HEAD(a2) ; Byte-Distanz liegt 1 Byte vor Word-Dist.
	moveq	#-2,d0
	add.l	d0,d6
	bsr	ShiftRelocs		; 2 Bytes ab der Bcc.b-Adr. gewonnen
	bra	9$

20$:	; os_BRANCH+os_LONG?
	subq.b	#1,d3
	beq.s	25$
	moveq	#66,d0			; Fatal Error (Illegale Distance-Width)
	bra	FatalError
25$:	cmp.l	#$8000,d0		; Ist nun ein 16-Bit Branch moeglich geworden?
	bgt	61$
	move.l	a0,-(sp)
	move.l	CurrentSec(a5),a0
	move.l	sec_LastCnop(a0),d1
	move.l	(sp)+,a0
	cmp.l	dist_Addr-dist_HEAD(a2),d1 ; Liegt ein CNOP dazwischen?
	bhi	61$
	cmp.l	#HUNKDATBLK,d2		; $6xff liegt im Vorgaenger-Chunk?
	bne.s	21$
	clr.b	hd_HEAD-1(a3,d2.l)	; $6x00 (16-bit displ.) eintragen
	bra.s	22$
21$:	clr.b	-1(a0)
22$:	move.w	d0,(a0)+		; 16-bit Displ. eintragen
	subq.l	#2,d2			; Nachfolge-Word im naechsten Chunk?
	bne.s	23$
	move.l	(a1),a1
	lea	hd_HEAD(a1),a0
23$:	movem.l	a0-a1,-(sp)
	move.b	#os_WORD,dist_Width-dist_HEAD(a2)
	IFND	FREEASS
	move.l	dist_ListFilePointer-dist_HEAD(a2),d2 ; Listingfile?
	beq.s	24$
	subq.l	#3,d2
	subq.l	#2,sp
	move.w	d0,-(sp)
	move.l	a6,a3
	move.l	DosBase(a5),a6
	move.l	ListFileHandle(a5),d1
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)		; zu aendernde Pos. setzen, alte retten
	move.l	d0,d2
	exg	a3,a6
	move.l	sp,a1
	lea	lst_optBccW(pc),a0
	move.l	ListFileHandle(a5),d0
	bsr	fprintf
	addq.l	#4,sp
	exg	a3,a6
	move.l	ListFileHandle(a5),d1
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	move.l	a3,a6
	ENDC
24$:	movem.l	(sp)+,a0-a1
	bsr.s	MoveHunkData2
	move.l	dist_Addr-dist_HEAD(a2),a0
	addq.l	#2,a0
	moveq	#-2,d0
	add.l	d0,d6
	bsr	ShiftRelocs		; 2 Bytes ab der Bcc.w-Adr. gewonnen
	bra	9$


	cnop	0,4
MoveHunkData2:
; Alle folgenden Words im HunkDataChunk sowie die Adressen in den
; HunkReloc-Chunks (falls kein AbsCode) um 2 Bytes verschieben, und
; deren Adressen in der DistanceList berichtigen.
; Ebenfalls um 2 Bytes verschoben werden die Referenz-Adressen von
; XREF-Symbolen.
; * Diese Aktion wird IMMER infolge einer Total-Branch-Optimierung aus-   *
; * gefuehrt, d.h. die betreffende Section kann NUR CurrentSection sein!! *
; a0 = Chunk-ShiftStart
; a1 = ActualChunk
; a2 = DistancePtr
	move.l	dist_Addr-dist_HEAD(a2),d2 ; d2 ab dieser Adr. alle verschieben
	lea	HUNKDATBLK+hd_HEAD-2(a1),a3
	bra.s	2$
1$:	move.w	2(a0),(a0)+
2$:	cmp.l	a3,a0
	bne.s	1$
	move.l	(a1),d0			; kein Chunk mehr?
	beq.s	3$
	move.l	d0,a1
	move.w	hd_HEAD(a1),(a0)
	lea	hd_HEAD(a1),a0
	lea	HUNKDATBLK+hd_HEAD-2(a1),a3
	bra.s	1$
3$:	movem.l	a2/a4,-(sp)
	move.w	SecNum(a5),d4		; d4 Nummer der aktuellen Section
	move.l	SecTabPtr(a5),a4	; Jede DistanceList jeder Section durchgehen
4$:	lea	secl_HEAD(a4),a2
	move.l	secl_FreeEntry(a4),d3
	bne.s	5$
	lea	SECLISTBLK(a2),a0
	move.l	a0,d3
5$:	move.l	(a2)+,a0		; Nächste Section
	move.l	sec_Distances(a0),d1
	beq.s	7$
6$:	move.l	d1,a1			; DistanceList
	lea	dist_HEAD(a1),a0
	move.l	dist_FreeEntry(a1),d0	; Endmarkierung dieses Chunks finden
	move.l	d0,a3
	bne.s	63$
	lea	dist_HEAD+DISTLISTBLK(a1),a3
	bra.s	63$
61$:	cmp.w	dist_HunkNum-dist_HEAD(a0),d4 ; DistAddr liegt in aktueller Section?
	bne.s	62$
	cmp.l	dist_Addr-dist_HEAD(a0),d2 ; Adresse um ein Word verschieben?
	bhs.s	62$
	subq.l	#2,dist_Addr-dist_HEAD(a0)
62$:	lea	distSIZE(a0),a0		; Naechsten Eintrag pruefen (+20)
63$:	cmp.l	a3,a0			; Chunk zuende ?
	bne.s	61$
	move.l	d1,a1
	move.l	(a1),d1			; Naechsten Chunk pruefen
	bne.s	6$
7$:	cmp.l	d3,a2			; SecList Chunk-Ende erreicht ?
	bne.s	5$
	tst.l	secl_FreeEntry(a4)	; noch ein Chunk ?
	bne.s	8$
	move.l	(a4),a4
	bra.s	4$
8$:	move.l	CurrentSec(a5),a3
	subq.l	#2,sec_Size(a3)		; Section-Groesse schrumpft um 2 Bytes
	cmp.l	#HUNKDATBLK,sec_FreeData(a3)
	bne.s	10$			; Neuer Data-Chunk wird nicht mehr benoetigt?
	move.l	sec_HunkData(a3),a1
9$:	move.l	a1,a0
	move.l	(a0),a1
	tst.l	(a1)			; Nachfolger ist der letzte?
	bne.s	9$
	move.l	#HUNKDATBLK+hd_HEAD,d0
	clr.l	(a0)			; Link loeschen
	lea	-2(a0,d0.l),a0
	move.l	a0,sec_HunkDataPt(a3)
	move.l	#2,sec_FreeData(a3)
	jsr	FreeMem(a6)		; letzten (jetzt unbenutzten) Chunk erst
	bra.s	11$			;  einmal wieder freigeben
10$:	subq.l	#2,sec_HunkDataPt(a3)
	addq.l	#2,sec_FreeData(a3)
11$:
	IFND	FREEASS
	tst.b	AbsCode(a5)
	beq.s	12$			; Reloc/Reference-Tables auch korrigieren?
	movem.l	(sp)+,a2/a4
	rts
	ENDC

12$:
; d4 = Current SecNum
	move.l	SymbolTable(a5),d0	; XREF-Symbole suchen
21$:	move.l	d0,a3
	lea	stab_HEAD(a3),a2
	move.w	stab_NumSymbols(a3),d1
	bra.s	28$
22$:	move.w	#T_XREF|T_NREF,d0	; XREF oder NREF suchen
	and.w	sym_Type(a2),d0
	beq.s	27$
	move.l	sym_RefList(a2),d0	; Referenzliste des Symbols nach Referenz-
23$:	;  Adressen aus aktueller Sect. absuchen
	move.l	d0,a0
	lea	rlist_HEAD(a0),a1
	move.w	rlist_NumRefs(a0),d0
	bpl.s	26$
	move.w	#REFLISTBLK/rlistSIZE-1,d0
24$:	cmp.b	rlist_Hunk-rlist_HEAD(a1),d4	; Referenz auf CurrentSec ?
	bne.s	25$
	cmp.l	rlist_RelAdr-rlist_HEAD(a1),d2	; Adresse muss verschoben werden?
	bhs.s	25$
	subq.l	#2,rlist_RelAdr-rlist_HEAD(a1)
25$:	lea	rlistSIZE(a1),a1
26$:	dbf	d0,24$
	move.l	(a0),d0
	bne.s	23$
27$:	lea	SymbolSIZE(a2),a2
28$:	dbf	d1,22$			; nächstes Symbol
	move.l	(a3),d0
	bne	21$			; noch ein Symbol-Chunk ?
	movem.l	(sp)+,a2/a4
	move.l	CurrentSec(a5),a3
	move.l	sec_HunkLineDebug(a3),d0 ; LineDebug-Offsets verschieben?
	beq.s	30$
	bsr.s	ShiftLineDebugOffsets
30$:	move.l	sec_HunkReloc(a3),d0	; Relocation-Table Eintraege verschieben
	bsr.s	ShiftHunkReloc2
	move.l	sec_HunkNearReloc(a3),d0

ShiftHunkReloc2:
; Relocation-Adressen ab (d2) um 2 Bytes verschieben
; d0 = erster HunkReloc-Chunk
; d2 = Shift-BaseAdr
	move.l	d0,a0
	lea	hrel_HEAD(a0),a1
	move.w	hrel_Entries(a0),d0
	bpl.s	3$
	move.w	#(HUNKRELOCBLK/hrelSIZE)-1,d0
1$:	cmp.l	(a1),d2
	bhs.s	2$
	subq.l	#2,(a1)
2$:	addq.l	#hrelSIZE,a1
3$:	dbf	d0,1$
	move.l	(a0),d0
	bne.s	ShiftHunkReloc2
	rts

ShiftLineDebugOffsets:
; Line-Debug Offsets ab (d2) um 2 Bytes verschieben
; d0 = erster LineDebugTab-Chunk
; d2 = Shift-BaseAdr
	move.l	d0,a0
	move.l	lindb_Ptr(a0),d1	; letzten Slot in diesem Chunk bestimmen
	bne.s	1$
	lea	lindb_HEAD+LINEDEBUGBLK(a0),a1
	move.l	a1,d1
1$:	addq.l	#4,d1
	lea	lindb_HEAD+4(a0),a1
	bra.s	4$
2$:	cmp.l	(a1),d2			; Offsets > d2 um 2 vermindern
	bhs.s	3$
	subq.l	#2,(a1)
3$:	addq.l	#8,a1
4$:	cmp.l	d1,a1
	blo.s	2$
	move.l	(a0),d0
	bne.s	ShiftLineDebugOffsets
	rts


updateListing:
; Byte, Word oder Longword im Listing-File ändern.
; Diese Funktion wird nur von SetSectionData benutzt.
; d0 = Byte/Word/Long
; d2 = ListFileOffset
; a0 = List-Funktion: ListByte, ListWord, ListLong
; a6 = ExecBase
; d0-d4/a0-a1/a3 = scratch
	move.l	a0,-(sp)
	move.l	d0,d4
	move.l	a6,a3
	move.l	DosBase(a5),a6
	move.l	ListFileHandle(a5),d1
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)		; zu ädernde Pos. setzen, alte retten
	move.l	d0,d2
	exg	a3,a6
	move.l	(sp)+,a0
	move.l	d4,d0
	jsr	(a0)			; Daten im Listingfile ändern
	exg	a3,a6
	move.l	ListFileHandle(a5),d1
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	move.l	a3,a6
	rts


	cnop	0,4
AddCount:
; Die gegebene Anzahl Bytes in der momentanen Section wird uebersprungen
; d0 = Count
	tst.l	d0
	beq.s	3$
	move.l	CurrentSec(a5),a1
	add.l	d0,sec_Size(a1)
	tst.l	sec_HunkDataPt(a1)
	beq.s	3$
	move.l	sec_FreeData(a1),d1
	sub.l	d0,d1
	bpl.s	1$
2$:	move.l	d1,d0
	neg.l	d0
	bsr	AddHunkData
	move.l	a0,sec_HunkDataPt(a1)
	move.l	sec_FreeData(a1),d1
	sub.l	d0,d1
	bmi.s	2$
1$:	move.l	d1,sec_FreeData(a1)
	add.l	d0,sec_HunkDataPt(a1)
3$:	rts


	cnop	0,4
AddByte:
; Fuegt der momentan aktivierten Section ein Byte hinzu
; d0 = Byte
	IFND	FREEASS
	tst.b	ListEn(a5)
	bne.s	10$
3$:
	ENDC
	move.l	CurrentSec(a5),a1
	move.l	sec_HunkDataPt(a1),d1
	beq.s	2$
	move.l	d1,a0
	subq.l	#1,sec_FreeData(a1)
	bpl.s	1$
	bsr	AddHunkData
	subq.l	#1,sec_FreeData(a1)
1$:	move.b	d0,(a0)+
	move.l	a0,sec_HunkDataPt(a1)
2$:	addq.l	#1,sec_Size(a1)
	rts
	IFND	FREEASS
10$:	move.w	d0,-(sp)
	move.w	d2,-(sp)
	move.b	Columns(a5),d2
	cmp.b	#ASSLINECOLUMN,d2	; Adresse schreiben ?
	bne.s	11$
	bsr	ListAddr
	subq.b	#8,d2
	move.w	2(sp),d0
11$:	cmp.b	#3,d2			; Platz fuer Byte und Space ?
	blo.s	12$
	bsr	ListByte
	subq.b	#3,d2
12$:	move.b	d2,Columns(a5)
	move.w	(sp)+,d2
	move.w	(sp)+,d0
	bra	3$
	ENDC


	cnop	0,4
AddWord:
; Fuegt der momentan aktivierten Section ein Word hinzu
; d0 = Word
	IFND	FREEASS
	tst.b	ListEn(a5)
	bne.s	10$
	ENDC
1$:	move.l	CurrentSec(a5),a1
	move.l	sec_HunkDataPt(a1),d1
	beq.s	4$
	move.l	d1,a0
	and.b	#1,d1
	bne.s	5$
2$:	subq.l	#2,sec_FreeData(a1)
	bpl.s	3$
	bsr	AddHunkData
	subq.l	#2,sec_FreeData(a1)
3$:	move.w	d0,(a0)+
	move.l	a0,sec_HunkDataPt(a1)
4$:	addq.l	#2,sec_Size(a1)
	rts
5$:	movem.l	d0/a0-a1,-(sp)
	moveq	#40,d0			; Word at odd address
	bsr	Error
	move.l	d6,a0
	addq.l	#1,d6
	moveq	#1,d0
	bsr	ShiftRelocs
	movem.l	(sp)+,d0/a0-a1
	addq.l	#1,sec_Size(a1)
13$:	addq.l	#1,a0
	subq.l	#1,sec_FreeData(a1)
	bpl.s	2$
	bsr	AddHunkData
	bra.s	13$
	IFND	FREEASS
10$:	move.w	d0,-(sp)
	move.w	d2,-(sp)
	move.b	Columns(a5),d2
	cmp.b	#ASSLINECOLUMN,d2	; Adresse schreiben ?
	bne.s	11$
	bsr	ListAddr
	subq.b	#8,d2
	move.w	2(sp),d0
11$:	cmp.b	#5,d2			; Platz fuer Word und Space ?
	blo.s	12$
	bsr	ListWord
	subq.b	#5,d2
12$:	move.b	d2,Columns(a5)
	move.w	(sp)+,d2
	move.w	(sp)+,d0
	bra	1$
	ENDC


	cnop	0,4
AddLong:
; Fuegt der momentan aktivierten Section ein LongWord hinzu
; d0 = LongWord
	IFND	FREEASS
	tst.b	ListEn(a5)
	bne.s	10$
	ENDC
1$:	move.l	CurrentSec(a5),a1
	move.l	sec_HunkDataPt(a1),d1
	beq.s	5$
	move.l	d1,a0
	and.b	#1,d1
	bne.s	6$
2$:	subq.l	#2,sec_FreeData(a1)
	bpl.s	3$
	bsr	AddHunkData
	subq.l	#2,sec_FreeData(a1)
3$:	swap	d0
	move.w	d0,(a0)+
	subq.l	#2,sec_FreeData(a1)
	bpl.s	4$
	bsr	AddHunkData
	subq.l	#2,sec_FreeData(a1)
4$:	swap	d0
	move.w	d0,(a0)+
	move.l	a0,sec_HunkDataPt(a1)
5$:	addq.l	#4,sec_Size(a1)
	rts
6$:	movem.l	d0/a0-a1,-(sp)
	moveq	#40,d0			; Word at odd address
	bsr	Error
	move.l	d6,a0
	addq.l	#1,d6
	moveq	#1,d0
	bsr	ShiftRelocs
	movem.l	(sp)+,d0/a0-a1
	addq.l	#1,sec_Size(a1)
13$:	addq.l	#1,a0
	subq.l	#1,sec_FreeData(a1)
	bpl.s	2$
	bsr	AddHunkData
	bra.s	13$
	IFND	FREEASS
10$:	move.l	d0,-(sp)
	move.w	d2,-(sp)
	move.b	Columns(a5),d2
	cmp.b	#ASSLINECOLUMN,d2	; Adresse schreiben ?
	bne.s	11$
	bsr	ListAddr
	subq.b	#8,d2
	move.l	2(sp),d0
11$:	cmp.b	#9,d2			; Platz fuer Long und Space ?
	blo.s	12$
	bsr	ListLong
	sub.b	#9,d2
12$:	move.b	d2,Columns(a5)
	move.w	(sp)+,d2
	move.l	(sp)+,d0
	bra	1$
	ENDC


	IFND	SMALLASS
	cnop	0,4
AddDouble:
; Fuegt der momentan aktivierten Section ein IEEE DoublePrecision hinzu
; d0 = Zeiger auf 64-Bit Fliesskomma
	movem.l	d2/a2,-(sp)
	move.l	d0,a2			; a2 = Zeiger auf Double
	IFND	FREEASS
	tst.b	ListEn(a5)
	beq.s	10$
	move.b	Columns(a5),d2
	cmp.b	#ASSLINECOLUMN,d2	; Adresse schreiben ?
	bne.s	11$
	bsr	ListAddr
	subq.b	#8,d2
	move.l	a2,a0
11$:	cmp.b	#17,d2			; Platz fuer Double und Space ?
	blo.s	12$
	bsr	ListDouble
	sub.b	#17,d2
12$:	move.b	d2,Columns(a5)
10$:
	ENDC
	move.l	CurrentSec(a5),a1
	move.l	sec_HunkDataPt(a1),d1
	beq.s	5$
	move.l	d1,a0
	and.b	#1,d1
	beq.s	2$
	movem.l	a0-a1,-(sp)
	moveq	#40,d0			; Word at odd address
	bsr	Error
	move.l	d6,a0
	addq.l	#1,d6
	moveq	#1,d0
	bsr	ShiftRelocs
	movem.l	(sp)+,a0-a1
	addq.l	#1,sec_Size(a1)
13$:	addq.l	#1,a0
	subq.l	#1,sec_FreeData(a1)
	bpl.s	2$
	bsr	AddHunkData
	bra.s	13$
2$:	move.l	sec_FreeData(a1),d2
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2),d0
	bsr.s	3$
	move.l	d2,sec_FreeData(a1)
	move.l	a0,sec_HunkDataPt(a1)
5$:	addq.l	#8,sec_Size(a1)
	movem.l	(sp)+,d2/a2
	rts
3$:	subq.l	#2,d2
	bpl.s	4$
	bsr	AddHunkData
	move.l	sec_FreeData(a1),d2
	subq.l	#2,d2
4$:	move.w	d0,(a0)+
	rts


	cnop	0,4
AddExtended:
; Fuegt der momentan aktivierten Section ein IEEE ExtendedPrecision
; oder Packed BCD hinzu
; d0 = Zeiger auf 96-Bit Fliesskomma (IEEE oder BCD-Format)
	movem.l	d2/a2,-(sp)
	move.l	d0,a2			; a2 = Zeiger auf 96-Bit
	IFND	FREEASS
	tst.b	ListEn(a5)
	beq.s	10$
	move.b	Columns(a5),d2
	cmp.b	#ASSLINECOLUMN,d2	; Adresse schreiben ?
	bne.s	11$
	bsr	ListAddr
	subq.b	#8,d2
	move.l	a2,a0
11$:	cmp.b	#25,d2			; Platz fuer 96-Bit-Zahl und Space ?
	blo.s	12$
	bsr	ListExtended
	sub.b	#25,d2
12$:	move.b	d2,Columns(a5)
10$:
	ENDC
	move.l	CurrentSec(a5),a1
	move.l	sec_HunkDataPt(a1),d1
	beq.s	5$
	move.l	d1,a0
	and.b	#1,d1
	beq.s	2$
	movem.l	a0-a1,-(sp)
	moveq	#40,d0			; Word at odd address
	bsr	Error
	move.l	d6,a0
	addq.l	#1,d6
	moveq	#1,d0
	bsr	ShiftRelocs
	movem.l	(sp)+,a0-a1
	addq.l	#1,sec_Size(a1)
13$:	addq.l	#1,a0
	subq.l	#1,sec_FreeData(a1)
	bpl.s	2$
	bsr	AddHunkData
	bra.s	13$
2$:	move.l	sec_FreeData(a1),d2
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2)+,d0
	bsr.s	3$
	move.w	(a2),d0
	bsr.s	3$
	move.l	d2,sec_FreeData(a1)
	move.l	a0,sec_HunkDataPt(a1)
5$:	moveq	#12,d0
	add.l	d0,sec_Size(a1)
	movem.l	(sp)+,d2/a2
	rts
3$:	subq.l	#2,d2
	bpl.s	4$
	bsr	AddHunkData
	move.l	sec_FreeData(a1),d2
	subq.l	#2,d2
4$:	move.w	d0,(a0)+
	rts
	ENDC


	cnop	0,4
AddHunkData:
; Haengt an die momentane Section einen weiteren HunkData-Chunk an
; ** d0 und a1 werden gerettet **
; a1 = CurrentSection
; -> a0 = HunkDataPtr
	movem.l	d0/a1-a2,-(sp)
	move.l	sec_HunkData(a1),a2
1$:	move.l	(a2),d0			; letzten Chunk finden
	beq.s	2$
	move.l	d0,a2
	bra.s	1$
2$:	bsr	GetHunkData		; Speicher fuer neuen Chunk belegen
	move.l	d0,(a2)			; und anhaengen
	addq.l	#hd_HEAD,d0
	move.l	d0,a0
	movem.l	(sp)+,d0/a1-a2
	move.l	#HUNKDATBLK,sec_FreeData(a1)
	rts


	IFND	FREEASS
ListByte:
	and.w	#$00ff,d0
	subq.l	#2,sp
	move.w	d0,-(sp)
	move.l	sp,a1
	lea	lst_byte(pc),a0
	move.l	ListFileHandle(a5),d0
	bsr	fprintf
	addq.l	#4,sp
	rts


ListWord:
	subq.l	#2,sp
	move.w	d0,-(sp)
	move.l	sp,a1
	lea	lst_word(pc),a0
	move.l	ListFileHandle(a5),d0
	bsr	fprintf
	addq.l	#4,sp
	rts


ListAddr:
	move.l	LineAddr(a5),-(sp)
	move.l	sp,a1
	lea	lst_addr(pc),a0
	move.l	ListFileHandle(a5),d0
	bsr	fprintf
	addq.l	#4,sp
	rts


ListLong:
	move.l	d0,-(sp)
	move.l	sp,a1
	lea	lst_long(pc),a0
	move.l	ListFileHandle(a5),d0
	bsr	fprintf
	addq.l	#4,sp
	rts


ListDouble:
	move.l	a0,a1
	lea	lst_doub(pc),a0
	move.l	ListFileHandle(a5),d0
	bra	fprintf


ListExtended:
	move.l	a0,a1
	lea	lst_extd(pc),a0
	move.l	ListFileHandle(a5),d0
	bra	fprintf


ListSourceLine:
; aktuelle Zeile in das Assemblerlisting schreiben
	move.l	a2,d2			; a2 retten (normal: Label-Buffer)
	move.l	ListFileHandle(a5),d4
	move.l	LineBase(a5),a0
	lea	-1(a4),a2
; move.l  a2,d0
; sub.l   a0,d0
; cmp.w   #SRCLISTLEN,d0
; bls.s   4$
; lea	  SRCLISTLEN(a0),a2	  ; Zeile kuerzen, wenn zu lang
;4$:
	moveq	#' ',d0
	tst.b	AssMode(a5)
	bpl.s	1$			; kein am_MACRO?
	move.l	#$dfdfdfdf,d1
	and.l	(a3),d1
	cmp.l	#'ENDM',d1		; ENDM nicht mit ausgeben
	bne.s	2$
	tst.b	4(a3)
	beq.s	9$
2$:	moveq	#'.',d0			; macro-Insert
1$:	move.b	(a2),d3
	clr.b	(a2)
	move.l	a0,-(sp)		; LineBase
	move.w	d0,-(sp)		; SPC oder '.' fuer Macro
	IFND	GIGALINES
	move.w	AbsLine(a5),d0
	move.l	d0,-(sp)
	ELSE
	move.l	AbsLine(a5),-(sp)
	ENDC
	move.l	sp,a1
	lea	SrcListLine(pc),a0
	move.l	d4,d0
	bsr	fprintf
	lea	10(sp),sp
	move.b	d3,(a2)
	move.b	PageLine(a5),d0
	addq.b	#1,d0
	move.b	PageLength(a5),d1
	beq.s	9$
	cmp.b	d1,d0			; neue Seite anfangen ?
	beq.s	3$
	move.b	d0,PageLine(a5)
9$	move.l	d2,a2
	rts
3$:	move.l	d2,a2
	subq.l	#2,sp
	move.w	#$0c00,-(sp)		; FormFeed
	move.l	sp,a0
	move.l	d4,d0
	bsr	fprintf
	addq.l	#4,sp
	bra	PageTitle

SrcListLine:
	dc.b	"                                  %5ld%c%s\n",0
lst_byte:
	dc.b	"%02x ",0
lst_word:
	dc.b	"%04x ",0
lst_addr:
	dc.b	"%06lx ",0
lst_long:
	dc.b	"%08lx ",0
lst_doub:
	dc.b	"%08lx%08lx",0
lst_extd:
	dc.b	"%08lx%08lx%08lx",0
lst_optBccB:
	dc.b	"%02x     ",0
lst_optBccW:
	dc.b	"00 %04x     ",0


	cnop	0,4
UCase:
; Alle Kleinbuchstaben eines Symbol-Strings groß machen
; a0 = String
	movem.l	d0/a0-a1,-(sp)
	moveq	#0,d0
	lea	ucase_tab(a5),a1
1$:	move.b	(a0),d0
	move.b	(a1,d0.w),(a0)+
	bne.s	1$
	movem.l	(sp)+,d0/a0-a1
	rts
	ENDC


	cnop	0,4
StrLen:
; a0 = String
; -> d0 = StringLength
	move.l	a0,-(sp)
	moveq	#-1,d0
1$:	tst.b	(a0)+
	dbeq	d0,1$
	not.w	d0
	move.l	(sp)+,a0
	rts


	cnop	0,4
StrCmp:
; Zwei Strings vergleichen
; a0 = String1, a1 = String2
	move.b	(a1)+,d0
	cmp.b	(a0)+,d0
	bne.s	1$
	tst.b	d0
	bne.s	StrCmp
1$:	rts


	cnop	0,4
UCaseStrCmp:
; Zwei Strings vergleichen. Dabei werden die Buchstaben des String1 in
; Grossbuchstaben umgewandelt bevor sie verglichen werden.
; a0 = String1, a1 = String2
; -> Z-Flag (true=Übereinstimmung)
	move.l	a2,d1
	lea	ucase_tab(a5),a2
	moveq	#0,d0
	bra.s	2$
1$:	cmp.b	(a1)+,d0
	bne.s	3$
2$:	move.b	(a0)+,d0
	move.b	(a2,d0.w),d0
	bne.s	1$
	tst.b	(a1)+
3$:	move.l	d1,a2
	rts


	cnop	0,4
LocStr:
; d0 = Local String ID
; -> a0 = Zeiger auf String (Default oder in voreingestellter Landessprache)
	movem.l	d1/a1/a6,-(sp)
	lea	DefStringBase,a0	; Zeiger auf englischen Default-String holen
	move.w	d0,d1
	beq.s	2$
1$:	tst.b	(a0)+
	bne.s	1$
	subq.w	#1,d1
	bne.s	1$
2$:
	IFND	FREEASS
	move.l	Catalog(a5),d1		; Locale-Catalog vorhanden?
	beq.s	3$
	move.l	LocaleBase(a5),a6
	move.l	a0,a1
	move.l	d1,a0
	ext.l	d0
	jsr	GetCatalogStr(a6)	; Landesspezifischen String lesen
	move.l	d0,a0
	ENDC
3$:	movem.l	(sp)+,d1/a1/a6
	rts


	end
