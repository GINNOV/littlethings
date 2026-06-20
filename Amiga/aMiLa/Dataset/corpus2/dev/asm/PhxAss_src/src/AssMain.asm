; $VER: AssMain.asm 4.42 (20.08.03)
; **********************************************
;
;             PhxAss Macro Assembler
;
;        Written by Frank Wille, 1991-2005
;
;                MAIN - PROGRAM
;
; **********************************************

	far				; Large Code/Data-Model

	include	"AssDefs.i"		; Strukturen und Definitionen einlesen

	ttl	"PhxAss - Main routines"


; ************
; CODE-Segment
; ************

	section	PHXAss,code


; *** Cross-References ***

; ** XREFs **
	xref	Pass_1,Pass_2		; a4=SourcePtr, d6.l=Address, d7.l=SourceLen
	xref	AddSymbol		; a0=SymbolName, d0=Type, d1.l=Value
	xref	FindSymbol		; a0=Name, ->d0=Symbol
	xref	GetValue		; a0=SourceString, ->d0/d1=Value, d2=Type/Section
	xref	StrLen			; a0=String, ->d0=Len
	xref	AddExternal		; a0=Symbol
	xref	CloseLocalPart
	xref	ReadArgument		; a0=SrcBuf, a1=DestBuf, d0=DestBufSize, ->d0=ReadBytes
	xref	MakeSection		; a0=SecName, d0=Type, ->a0=Section
	xref	MakeMnemonicTab
	xref	LocStr			; d0=StringID, ->a0=LocaleString
	xref	WriteObjectCode
	xref	XRefFile
	xref	EquatesFile
	xref	CheckCont

; ** XDEFs **
	xdef	Error			; d0=ErrNum (Rest wird gerettet)
	xdef	Warning			; a1=WarnText (Rest wird gerettet)
	xdef	FatalError		; (wie oben), kehrt aber nicht zurueck
	xdef	CleanUp			; Programm verlassen (bei Fehler oder CTRL-C)
	xdef	OutofMemError
	xdef	GetCnopTab,GetIncNestList,GetIncludeList,GetMacNestList
	xdef	GetMacParameter,GetLocalParts,GetSymbolTable,GetLocalSymbolTable,GetSUT
	xdef	GetReferenceList,GetRegRefList,GetSection,GetHunkData,GetRepTab
	xdef	GetHunkExtTable,GetHunkSymbolTable,GetHunkReloc,GetDistanceList
	xdef	GetSecList,GetStringTable,GetStringBuffer,GetLineDebugTab
	xdef	GetLocalHashTable,GetLocalRegs	; ->d0=MemPtr
	xdef	AddString		; a0=String, ->d0=NewStringPtr
	xdef	AddLongFloat		; d0=FloatPtr, ->d0=NewFloatPtr
	xdef	FileSize		; a0=FileName
	xdef	printf			; a0=FormatString, a1=DataStream
	xdef	fprintf			; d0=FileHandle, a0=FormatString, a1=DataStream
	xdef	sprintf			; a0=Buf, a1=FmtString, a2=DataStream
	xdef	DivMod			; d0=Divisor, d1=Dividend, ->d0=Quotient,d1=Remainder
	; (a0/a1 werden gerettet)
	xdef	PageTitle
	xdef	GetSysTime
	xdef	GetOptFlags		; a1=FlagsString
	xdef	BuildStringTable	; a0=StringTable, a1=Strings
	xdef	setOPTC



; *** Wichtig ***
; Wenn nicht anders vermerkt, wird bei allen Aufrufen immer angenommen, dass
; a5 auf PhxAssVars zeigt und a6 die ExecBase enthaelt.


PhoenixAssembler:
	; *** <- Hier beginnt das Programm !! ***
; a0 = CommandLine
	bra.s	Start
	dc.b	"$VER: "
; Seit V4.40 ist die Giga-Version Standard!
;	IFD	GIGALINES
;	dc.b	"Giga"
;	ENDC
	dc.b	"PhxAss ",$30+VERSION,$2e,$30+REVISION/10,$30+REVISION//10
	IFD	BETA
	dc.b	'ß'
	ENDC
	IFD	ALPHA
	dc.b	"alpha"
	ENDC
	dc.b	32
	DATESTRING
	dc.b	13,10,0
	even
Start:
	move.l	ExecBase.w,a6
	cmp.w	#37,lib_Version(a6)
	blo.s	1$			; exec.library muß mindestens 2.04 sein
	lea	DosName(pc),a1
	moveq	#37,d0
	jsr	OpenLibrary(a6)		; dos.library 2.04 oeffnen
	move.l	d0,d6
	beq.s	1$
	move.l	#GlobalVarsSIZE,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer Variablenbereich anfordern
	tst.l	d0
	bne.s	2$
	move.l	d6,a1
	jsr	CloseLibrary(a6)
1$:	moveq	#20,d0			; FAIL
	rts
2$:	move.l	d0,a5			; a5 zeigt immer auf den Variablenbereich
	move.l	a6,SysBase(a5)		; SysBase,
	move.l	d6,DosBase(a5)		; DosBase und
	move.l	sp,CleanUpLevel(a5)	; SP, fuer Rueckkehr durch Fehler, merken
	bsr	Init			; Libraries öffnen, Speicher besorgen
	bsr	ReadOptions		; Commandline parsen, Options lesen
	bne	CleanUp
	bsr	AssemblerSymbols	; Standard SET-Symbole initialisieren
	bsr	ReadSourceCode		; Source lesen, -h incl. einfügen
	bsr	OpenTimer		; timer.device oeffnen
	IFND	FREEASS
	bsr	OpenListingFile		; Listing file oeffnen
	ENDC
	bsr	PrintTitle
	jsr	MakeMnemonicTab		; HashTable für alle Mnemonics erstellen
	bsr	CurrentTime		; Zeit merken bei der die Assemblierung begann
	movem.l	d0-d1,AssTime(a5)

	clr.b	Pass(a5)		; *** PASS 1 ***
	bsr	PrintPass
	move.b	MachinePreset(a5),Machine(a5)
	move.b	FPUidPreset(a5),FPUid(a5)
	move.b	PMMUidPreset(a5),PMMUid(a5)
	IFND	FREEASS
	move.l	#$30303030,MacLabel(a5)	; MacLabel auf "0000" setzen
	move.b	#am_SOURCE,AssMode(a5)
	moveq	#-1,d0
	move.b	d0,AbsCode(a5)		; Code-Typ noch unbekannt
	move.w	d0,IncludeCnt(a5)
	ENDC
	move.l	SourceName(a5),AssModeName(a5)
	IFND	GIGALINES
	move.w	LineStart(a5),Line(a5)
	move.w	#1,AbsLine(a5)
	ELSE
	move.l	LineStart(a5),Line(a5)
	moveq	#1,d0
	move.l	d0,AbsLine(a5)
	ENDC
	move.l	SourceText(a5),a4
	moveq	#0,d6
	move.l	SourceLength(a5),d7
	bsr	Pass_1			; Code assemblieren (Pass 1)

	bsr	CloseLocalPart		; letzten LocalPart beenden
	move.l	SecTabPtr(a5),d0	; CurrentAddr aller Sections zurueckstellen
3$:	move.l	d0,a4
	lea	secl_HEAD(a4),a3
	move.l	secl_FreeEntry(a4),d4
	bne.s	5$
	move.l	a3,d4
	add.l	#SECLISTBLK,d4
	bra.s	5$
4$:	move.l	(a3)+,a0		; Section - CurrentAdr zurueckstellen
	move.l	sec_Origin(a0),sec_CurrentAdr(a0)
5$:	cmp.l	a3,d4			; SecList-Chunk Ende erreicht ?
	bne.s	4$
	move.l	(a4),d0			; Naechster SecList-Chunk vorhanden ?
	bne.s	3$
10$:	bsr	PUBLICtoXREF		; Alle PUBLIC-Symbole in XREF umwandeln

	IFND	FREEASS
	move.l	SeekListBegin(a5),d0
	beq.s	21$
	move.l	a6,a2			; Listing file zurueckspulen
	move.l	DosBase(a5),a6
	move.l	ListFileHandle(a5),d1
	move.l	d0,d2
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	move.l	d0,SeekListBegin(a5)	; alte Position merken
	move.l	a2,a6
	move.b	#2+TITLE_LINES+1,PageLine(a5)
	ENDC
21$:	tst.b	SaveCnt(a5)
	beq.s	22$
	clr.b	SaveCnt(a5)
	moveq	#104,d0
	bsr	Error			; Missing RESTORE

22$:	move.b	#1,Pass(a5)		; *** PASS 2 ***
	bsr	PrintPass
	move.b	MachinePreset(a5),Machine(a5)
	move.b	FPUidPreset(a5),FPUid(a5)
	move.b	PMMUidPreset(a5),PMMUid(a5)
	IFND	FREEASS
	move.l	#$30303030,MacLabel(a5)	; MacLabel auf "0000" setzen
	move.b	#am_SOURCE,AssMode(a5)
	ENDC
	move.l	SourceName(a5),AssModeName(a5)
	move.l	FirstCnopTab(a5),a0	; Zeiger auf erstes Cnop setzen
	move.l	a0,CnopTabPtr(a5)
	addq.l	#ctab_HEAD,a0
	move.l	a0,CnopPtr(a5)
	IFND	FREEASS
	moveq	#-1,d0
	move.w	d0,IncludeCnt(a5)
	clr.w	MacroCnt(a5)
	ENDC
	IFND	GIGALINES
	move.w	LineStart(a5),Line(a5)
	move.w	#1,AbsLine(a5)
	ELSE
	move.l	LineStart(a5),Line(a5)
	moveq	#1,d0
	move.l	d0,AbsLine(a5)
	ENDC
	move.l	SpeedUpTab(a5),a0
	move.l	a0,CurrentSUT(a5)
	lea	sut_HEAD(a0),a0
	move.l	a0,SUTPos(a5)
	st	BaseRegNo(a5)
	tst.w	SectionCnt(a5)
	beq.s	6$
	move.l	SecTabPtr(a5),a0	; Erste Section setzen
	move.l	secl_HEAD(a0),a0
	move.l	a0,CurrentSec(a5)
	clr.w	SecNum(a5)
	move.l	sec_Origin(a0),d6
	move.l	sec_Type(a0),d0
	move.l	sec_Name(a0),a0
	bsr	MakeSection
6$:	move.l	SourceText(a5),a4
	move.l	SourceLength(a5),d7
	bsr	Pass_2			; Code assemblieren (Pass 2)

EndAssem:
	IFND	GIGALINES
	move.w	AbsLine(a5),NumLines(a5)
	clr.w	Line(a5)
	clr.w	AbsLine(a5)
	ELSE
	move.l	AbsLine(a5),NumLines(a5)
	clr.l	Line(a5)
	clr.l	AbsLine(a5)
	ENDC
	LOCS	S_CLEANUP		; folgende Fehler beziehen sich auf CleanUp
	move.l	a0,AssModeName(a5)
	bsr	LinearSecList		; Lineare Section Liste erzeugen (garantiert,
	IFND	FREEASS			;  daß mind. eine Dummy-Section vorhanden ist)
	tst.b	AbsCode(a5)
	beq.s	4$
	bpl.s	7$
	clr.b	AbsCode(a5)
	bra.s	6$
	ENDC
4$:	bsr	XREFtoExtTable		; XREF/NREF in HunkExtTable uebernehmen
6$:	bsr	UndefinedXDEFs		; Undefinierte XDEFs ausgeben
	bsr	AbsXDEFtoExtTable	; Absolute-XDEFs auch
7$:
	IFND	FREEASS
	move.l	SeekListBegin(a5),d0	; Listing file auf letztes Byte setzen
	beq.s	3$
	move.l	a6,a2
	move.l	DosBase(a5),a6
	move.l	ListFileHandle(a5),d1
	move.l	d0,d2
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	move.l	a2,a6
	ENDC
3$:	bsr	AssemTime		; Assemblierungsdauer berechnen
	tst.b	ErrorFlag(a5)		; Fehler waehrend der Ass. aufgetreten ?
	bne	CleanUp
	btst	#sw_QUIET,Switches(a5)
	bne.s	1$
	moveq	#0,d0
	bsr	Error			; No error
	bsr	Statistics		; Assem.-Statistiken ausgeben
1$:
	IFND	FREEASS
	jsr	XRefFile
	ENDC
	jsr	WriteObjectCode		; Object-, Load File, Absolutes File, etc. erz.
	IFND	FREEASS
	jsr	EquatesFile
	ENDC
	clr.b	ReturnCode(a5)		; kein Fehler aufgetreten

CleanUp:
; Den ganzen Speicher wieder freigeben, dos.library schliessen
	move.l	SysBase(a5),a6
	move.l	LinSecList(a5),d0	; Lineaer Section List freigeben?
	beq.s	2$
	move.l	d0,a1
	moveq	#0,d0
	move.w	SectionCnt(a5),d0
	lsl.w	#2,d0
	jsr	FreeMem(a6)
2$:
	IFND	FREEASS
	move.l	ListFileHandle(a5),d1	; Listing file noch offen ?
	beq.s	1$
	move.l	a6,a2
	move.l	DosBase(a5),a6
	jsr	Close(a6)
	move.l	AssListName(a5),d1
	moveq	#%0010,d2
	jsr	SetProtection(a6)	; rw-d für Listing
	move.l	a2,a6
	ENDC
1$:	move.l	MnemoMem(a5),d0		; Speicher fuer MnemonicStructures freigeben
	beq.s	3$
	move.l	d0,a1
	move.l	MnemoSize(a5),d0
	jsr	FreeMem(a6)
3$:	move.l	MnemoHashList(a5),d0
	beq.s	4$
	move.l	d0,a1
	move.l	MnemHashTabSize(a5),d0
	lsl.l	#2,d0
	jsr	FreeMem(a6)
4$:	move.l	TimerPort(a5),d0	; timer.device schliessen
	beq.s	9$
	move.l	d0,a0
	jsr	DeleteMsgPort(a6)
	move.l	TimerReq(a5),a2
	move.l	a2,a1
	jsr	CloseDevice(a6)
	move.l	a2,a0
	jsr	DeleteIORequest(a6)

9$:
	IFND	FREEASS
	move.l	IncListPtr(a5),d0	; Include-Files aus dem Speicher werfen
	beq	19$
	move.l	d0,a0
	clr.l	-(sp)
10$:	move.l	incl_Link(a0),d0	; Link gesetzt ?
	beq.s	11$
	move.l	a0,-(sp)
	move.l	d0,a0
	bra.s	10$
11$:	move.l	incl_FreeEntry(a0),a3
	move.l	a3,d0
	bne.s	13$
	move.l	a0,d0
12$:	move.l	d0,a0
	lea	incl_HEAD+INCLISTBLK(a0),a3
13$:	lea	incl_Text(a0),a2
14$:	cmp.l	a2,a3			; alle IncFiles aus diesem Chunk freigegeben ?
	beq.s	15$
	subq.l	#4,a3			; Name wird nicht benoetigt
	move.l	-(a3),d0		; Size
	move.l	-(a3),a1		; Text
	jsr	FreeMem(a6)
	bra.s	14$
15$:	move.l	(sp)+,d0		; noch einen Chunk freigeben ?
	bne.s	12$
	ENDC

19$:
	move.l	LocPartsPtr(a5),d0	; Alle LocalSymbolTables freigeben
	beq	26$
	move.l	LocHashTabSize(a5),d3
	lsl.l	#2,d3
	move.l	#LOCSYMBLK+lstab_HEAD,d2
	move.l	d0,a0
	clr.l	-(sp)
20$:	move.l	(a0),d0			; Link gesetzt ?
	beq.s	21$
	move.l	a0,-(sp)
	move.l	d0,a0
	bra.s	20$
22$:	move.l	d0,a0
21$:	moveq	#lpSIZE,d0
	mulu	lp_NumParts(a0),d0
	lea	lp_HEAD(a0,d0.l),a3
	lea	lp_HEAD(a0),a2
	bra.s	25$
24$:	lea	-lpSIZE(a3),a3
	move.l	lp_SymTab(a3),d0	; LocSymTab
	beq.s	27$
	move.l	d0,a0
	move.l	d2,d0
	bsr	FreeChunkList
	move.l	lp_HashTab(a3),d0	; LocHashTab
	beq.s	27$
	move.l	d0,a1
	move.l	d3,d0
	jsr	FreeMem(a6)
27$:	move.l	lp_LocRegNames(a3),d0	; LocRegNames
	beq.s	25$
	move.l	d0,a1
	move.l	#MAXLOCREGNAMES*4*16,d0
	jsr	FreeMem(a6)
25$:	cmp.l	a2,a3			; alle LocalSymTabs aus diesem Chunk frei ?
	bne.s	24$
	move.l	(sp)+,d0		; noch einen Chunk freigeben ?
	bne.s	22$
	move.l	LocPartsPtr(a5),a0	; Alle LocalParts-Chunks freigeben
	move.l	#LOCALPARTSBLK+lp_HEAD,d0
	bsr	FreeChunkList

26$:	bsr	FreeSymTabs		; alle globalen SymbolTables freigeben

30$:	move.l	FirstRefListBlock(a5),d0
	beq.s	31$
	move.l	d0,a0			; RefListBlocks freigeben (enthalten RefLists)
	move.l	#RLBLOCKBLK+rlblk_HEAD,d0
	bsr	FreeChunkList

31$:	moveq	#15,d3			; Alle Register-Referenzlisten freigeben
	lea	RegRefs(a5),a3
32$:	move.l	a3,a2
	moveq	#MAXREGNAMES-1,d2
33$:	move.l	(a2)+,d0
	beq.s	34$
	move.l	d0,a0
	move.l	#REGREFLISTBLK+rrl_HEAD,d0
	bsr	FreeChunkList
	dbf	d2,33$
34$:	lea	MAXREGNAMES<<2(a3),a3
	dbf	d3,32$

40$:	move.l	SourceText(a5),d0	; SourceCode aus dem Speicher werfen
	beq.s	42$
	move.l	d0,a1
	move.l	SourceLength(a5),d0
	jsr	FreeMem(a6)
42$:
	IFND	FREEASS
	move.l	MacParaPtr(a5),d0	; MacParameter-Chunks freigeben
	beq.s	43$
	move.l	d0,a0
	move.l	#MACPARBLK+mpar_HEAD,d0
	bsr	FreeChunkList
43$:	move.l	MacNest(a5),d0		; MacNestList-Chunks freigeben
	beq.s	44$
	move.l	d0,a0
	move.l	#MACNSTBLK+nl_HEAD,d0
	bsr	FreeChunkList
44$:	move.l	IncListPtr(a5),d0	; IncludeList-Chunks freigeben
	beq.s	45$
	move.l	d0,a0
	move.l	#INCLISTBLK+incl_HEAD,d0
	bsr	FreeChunkList
45$:	move.l	IncNest(a5),d0		; IncNestList-Chunks freigeben
	beq.s	48$
	move.l	d0,a0
	move.l	#INCNSTBLK+nl_HEAD,d0
	bsr	FreeChunkList
	ENDC

48$:	move.l	SpeedUpTab(a5),d0	; SpeedUpTab freigeben
	beq.s	49$
	move.l	d0,a0
	move.l	#SUTBLK+sut_HEAD,d0
	bsr	FreeChunkList
49$:	move.l	SecTabPtr(a5),d0	; Alle Sections und SecLists freigeben
	beq	70$
	move.l	d0,a0
	clr.l	-(sp)
50$:	move.l	(a0),d0			; Link gesetzt ?
	beq.s	51$
	move.l	a0,-(sp)
	move.l	d0,a0
	bra.s	50$
51$:	move.l	secl_FreeEntry(a0),a3
	bra.s	53$
52$:	move.l	d0,a0
	lea	secl_HEAD+SECLISTBLK(a0),a3
53$:	lea	secl_Section(a0),a2
54$:	cmp.l	a2,a3			; alle Sections aus diesem Chunk freigegeben ?
	beq.s	64$
	move.l	-(a3),a4
	move.l	sec_HunkLineDebug(a4),d0
	beq.s	57$
	move.l	d0,a0
	move.l	#LINEDEBUGBLK+lindb_HEAD,d0
	bsr	FreeChunkList		; LineDebugTab-Chunks der Section freigeben
57$:	move.l	sec_Distances(a4),d0
	beq.s	58$
	move.l	d0,a0
	move.l	#DISTLISTBLK+dist_HEAD,d0
	bsr	FreeChunkList		; DistanceLists der Section freigeben
58$:	move.l	sec_HunkSymbolTable(a4),d0
	beq.s	59$
	move.l	d0,a0
	move.l	#HSYMTABBLK+hsym_HEAD,d0
	bsr	FreeChunkList		; HunkSymbolTable der Section freigeben
59$:	move.l	sec_HunkExtTable(a4),d0
	beq.s	60$
	move.l	d0,a0
	move.l	#HEXTTABBLK+hext_HEAD,d0
	bsr	FreeChunkList		; HunkExtTable der Section freigeben
60$:	move.l	sec_HunkNearReloc(a4),d0
	beq.s	61$
	move.l	d0,a0
	move.l	#HUNKRELOCBLK+hrel_HEAD,d0
	bsr	FreeChunkList		; HunkReloc der Section freigeben
61$:	move.l	sec_HunkReloc(a4),d0
	beq.s	62$
	move.l	d0,a0
	move.l	#HUNKRELOCBLK+hrel_HEAD,d0
	bsr	FreeChunkList		; HunkReloc der Section freigeben
62$:	move.l	sec_HunkData(a4),d0
	beq.s	63$
	move.l	d0,a0
	move.l	#HUNKDATBLK+hd_HEAD,d0
	bsr	FreeChunkList		; HunkData der Section freigeben
63$:	move.l	a4,a1
	move.l	#SectionSIZE,d0
	jsr	FreeMem(a6)		; Section-Struktur freigeben
	bra.s	54$
64$:	move.l	(sp)+,d0
	bne	52$			; noch einen SecList-Chunk bearbeiten ?

	move.l	SecTabPtr(a5),a0	; SecList-Chunks freigeben
	move.l	#SECLISTBLK+secl_HEAD,d0
	bsr	FreeChunkList

70$:	
	IFND	FREEASS
	move.l	RepTabPtr(a5),d0	; RepTable-Chunks freigeben
	beq.s	71$
	move.l	d0,a0
	move.l	#REPTABBLK+reptab_HEAD,d0
	bsr	FreeChunkList
	ENDC
71$:	move.l	ExtAbsTab(a5),d0	; Abs-XDEFTable-Chunks freigeben
	beq.s	72$
	move.l	d0,a0
	move.l	#HEXTTABBLK+hext_HEAD,d0
	bsr	FreeChunkList
72$:	move.l	FirstCnopTab(a5),d0	; CnopTable-Chunks freigeben
	beq.s	73$
	move.l	d0,a0
	move.l	#CNOPTABBLK+ctab_HEAD,d0
	bsr	FreeChunkList
73$:
	IFND	FREEASS
	move.l	IncFileTable(a5),d0	; IncFileTable-Chunks freigeben
	beq.s	75$
	move.l	d0,a0
	move.l	#STRTABBLK+strt_HEAD,d0
	bsr	FreeChunkList
75$:	move.l	IncDirTable(a5),d0	; IncDirTable-Chunks freigeben
	beq.s	76$
	move.l	d0,a0
	move.l	#STRTABBLK+strt_HEAD,d0
	bsr	FreeChunkList
	ENDC
76$:	move.l	StringBuf(a5),d0	; StringBuffer-Chunks freigeben
	beq.s	79$
	move.l	d0,a0
	move.l	#STRINGBLK+sb_HEAD,d0
	bsr	FreeChunkList

79$:
	IFND	FREEASS
	move.l	TDBuffer(a5),d0		; Trackdisk-Buffer freigeben
	beq.s	80$
	move.l	d0,a1
	move.l	#TD_SECTOR,d0
	jsr	FreeMem(a6)
80$:	move.l	LocaleBase(a5),d7	; locale.library schließen (falls vorhanden)
	beq.s	83$
	exg	d7,a6
	move.l	Catalog(a5),d0		; Catalog schließen
	beq.s	81$
	move.l	d0,a0
	jsr	CloseCatalog(a6)
81$:	move.l	Locale(a5),d0		; Zugriff auf Locale-Struktur beenden
	beq.s	82$
	move.l	d0,a0
	jsr	CloseLocale(a6)
82$:	move.l	a6,a1
	move.l	d7,a6
	jsr	CloseLibrary(a6)
83$:
	ENDC
	IFND	SMALLASS		; Mathe-Libs schließen - falls offen
	move.l	MathIEEETransBase(a5),d0 ; mathieeedoubtrans.library schließen
	bsr.s	closelib
	move.l	MathIEEEBase(a5),d0	; mathieeedoubbas.library schließen
	bsr.s	closelib
	move.l	MathFFPTransBase(a5),d0	; mathffptrans.library schließen
	bsr.s	closelib
	ENDC
	move.l	UtilityBase(a5),d0	; utility.library schließen
	bsr.s	closelib
	move.l	DosBase(a5),d0		; dos.library schließen
	bsr.s	closelib
	btst	#sw2_FORCEPRI,Switches2(a5) ; Priorität wurde geändert?
	beq.s	90$
	move.b	OldTaskPri(a5),d0
	ext.w	d0
	ext.l	d0
	move.l	myTask(a5),a1
	jsr	SetTaskPri(a6)

90$:	moveq	#0,d7			; ****  Rueckkehr zum CLI !  ****
	move.b	ReturnCode(a5),d7
	move.l	#GlobalVarsSIZE,d0
	move.l	a5,a1
	jsr	FreeMem(a6)		; Variablenbereich freigeben
	move.l	d7,d0
	rts

closelib:
	beq.s	1$
	move.l	d0,a1
	jsr	CloseLibrary(a6)
1$:	rts


FreeChunkList:
; Verkettete Chunks vom letzten an, bis zum ersten, freigeben
; a0 = FirstChunk
; d0 = ChunkSize
	move.l	d2,-(sp)
	move.l	d0,d2
	clr.l	-(sp)
1$:	move.l	(a0),d0			; Link gesetzt ?
	beq.s	2$
	move.l	a0,-(sp)
	move.l	d0,a0
	bra.s	1$
2$:	move.l	a0,d0
3$:	move.l	d0,a1
	move.l	d2,d0
	jsr	FreeMem(a6)		; Chunk freigeben
	move.l	(sp)+,d0
	bne.s	3$
	move.l	(sp)+,d2
	rts


Init:
; Öffnet benötigte Libraries, beschafft Speicher fuer alle vor dem Start
; zu initialisierenden Strukturen und setzt die vordefinierten Symbole.
	sub.l	a1,a1
	jsr	FindTask(a6)		; eigene Process Struktur finden
	move.l	d0,myTask(a5)
	move.l	a6,a4
	move.l	DosBase(a5),a6
	jsr	Input(a6)		; stdin bestimmen
	move.l	d0,StdIn(a5)
	jsr	Output(a6)		; stdout bestimmen
	move.l	d0,StdOut(a5)
	move.l	a4,a6
	lea	UtilityName(pc),a1
	moveq	#36,d0
	jsr	OpenLibrary(a6)		; utility.library öffnen (erst ab 2.0 vorh.)
	move.l	d0,UtilityBase(a5)
	bne.s	1$
	moveq	#2,d0			; Unable to open utility.library
	bra	FatalError
1$:
	IFND	SMALLASS
	lea	MathTransName(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)		; mathtrans.library öffnen
	move.l	d0,MathFFPTransBase(a5)
	beq.s	2$
	lea	MathIEEEName(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)		; mathieeedoubbas.library öffnen
	move.l	d0,MathIEEEBase(a5)
	beq.s	2$
	lea	MathIEEETransName(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)		; mathieeedoubtrans.library öffnen
	move.l	d0,MathIEEETransBase(a5)
	sne	FloatLibs(a5)		; Geschafft: Alle Mathe Libraries verfügbar!
	ENDC
2$:
	IFND	FREEASS
	lea	LocaleName(pc),a1
	moveq	#38,d0
	jsr	OpenLibrary(a6)		; locale.library (ab OS2.1) öffnen
	move.l	d0,LocaleBase(a5)	; (wenn's nicht klappt, nur englische Texte)
	beq.s	3$
	move.l	d0,a6
	sub.l	a0,a0
	jsr	OpenLocale(a6)		; Zugriff auf Locale-Struktur
	move.l	d0,Locale(a5)
	sub.l	a0,a0
	lea	PhxAssCatName(pc),a1
	clr.l	-(sp)
	clr.l	-(sp)			; TAG_DONE
	move.l	sp,a2
	jsr	OpenCatalogA(a6)	; PhxAss-Catalog mit sämtlichen Strings öffnen
	move.l	d0,Catalog(a5)
	addq.l	#8,sp
	move.l	a4,a6
	ENDC
3$:	LOCS	S_INIT			; Fehlermeldungen auf Init beziehen
	move.l	a0,AssModeName(a5)
	IFND	FREEASS
	move.l	#TD_SECTOR,d0
	moveq	#MEMF_PUBLIC,d1
	jsr	AllocMem(a6)		; Speicher fuer Trackdisk-Sectors
	move.l	d0,TDBuffer(a5)
	beq	OutofMemError
	ENDC
	bsr	GetStringBuffer		; Speicher fuer StringBuffer besorgen
	move.l	d0,StringBuf(a5)
	move.l	d0,StrBufChunk(a5)
	addq.l	#sb_HEAD,d0
	move.l	d0,StringPtr(a5)
	IFND	FREEASS
	bsr	GetStringTable		; IncFileTable besorgen
	move.l	d0,IncFileTable(a5)
	bsr	GetStringTable		; IncDirTable besorgen
	move.l	d0,IncDirTable(a5)
	ENDC
	bsr	GetSecList		; SecList-Struktur (leer)
	move.l	d0,SecTabPtr(a5)
	bsr	GetRefListBlock
	move.l	d0,FirstRefListBlock(a5)
	move.l	d0,RefListBlockPtr(a5)	; akt. Chunk fuer ReferenceLists
	bsr	GetLocalParts		; LocalParts fuer lokale SymTabs
	move.l	d0,LocPartsPtr(a5)
	IFND	FREEASS
	bsr	GetIncNestList		; IncNestList und IncludeList besorgen
	move.l	d0,IncNest(a5)
	bsr	GetIncludeList
	move.l	d0,IncListPtr(a5)
	bsr	GetMacNestList		; MacNestList und MacParameter besorgen
	move.l	d0,MacNest(a5)
	bsr	GetMacParameter
	move.l	d0,MacParaPtr(a5)
	ENDC
	bsr	GetSUT			; SpeedUpTable besorgen
	move.l	d0,SpeedUpTab(a5)
	move.l	d0,CurrentSUT(a5)
	addq.l	#sut_HEAD,d0
	move.l	d0,SUTPos(a5)
	bsr	GetCnopTab		; CnopTable besorgen
	move.l	d0,FirstCnopTab(a5)
	move.l	d0,CnopTabPtr(a5)
	addq.l	#ctab_HEAD,d0
	move.l	d0,CnopPtr(a5)
	bsr	GetHunkExtTable		; Abs-XDEF Table besorgen
	move.l	d0,ExtAbsTab(a5)
	addq.l	#hext_HEAD,d0
	move.l	d0,ExtAbsPtr(a5)
	bsr	MakeCharTabs		; Tabellen für Zeichenüberpüfung erzeugen
	IFND	FREEASS
	bsr	GetRepTab		; RepTab besorgen
	move.l	d0,RepTabPtr(a5)
	bsr	CheckENVVars		; PHXASSINC in ENV: suchen
	move.b	#PLENDEFAULT,PageLength(a5)
	move.b	#1,SRecType(a5)		; Default SRecord-Typ = S28
	move.b	#68,SRecLen(a5)		; Default SRecord-Länge = 68
	ENDC
	lea	LastShiftAddrs+MAXOPTSHIFTS*4(a5),a0
	move.l	a0,LastShiftPtr(a5)
	st	MainModel(a5)		; Default Far Model
	st	Model(a5)
	st	BaseRegNo(a5)
	move.b	#$0f,OptFlag(a5)	; Normal, Relative, Quick & Branches
	move.b	#5,MaxErrors(a5)	; Nach 5 Fehlern auf Bestätigung warten
	rts

DosName:
	dc.b	"dos.library",0
UtilityName:
	dc.b	"utility.library",0
	IFND	SMALLASS
MathTransName:
	dc.b	"mathtrans.library",0
MathIEEEName:
	dc.b	"mathieeedoubbas.library",0
MathIEEETransName:
	dc.b	"mathieeedoubtrans.library",0
	ENDC
	IFND	FREEASS
LocaleName:
	dc.b	"locale.library",0
PhxAssCatName:
	dc.b	"PhxAss.catalog",0
NARGSymbol:
	dc.b	"NARG",0
CARGSymbol:
	dc.b	"CARG",0
__RSSymbol:
	dc.b	"__RS",0
__SOSymbol:
	dc.b	"__SO",0
__FOSymbol:
	dc.b	"__FO",0
	ENDC
PhxAssSymbol:
	dc.b	"_PHXASS_",0
VersionSymbol:
	dc.b	"_VERSION_",0
CPUSymbol:
	dc.b	"__CPU",0
FPUSymbol:
	dc.b	"__FPU",0
MMUSymbol:
	dc.b	"__MMU",0
OptCSymbol:
	dc.b	"__OPTC",0

PrgErrTxt:
	dc.b	"%d %s (%s).\n",0
	even


AssemblerSymbols:
; Standard SET-Symbole initialisieren
	IFND	FREEASS
	lea	NARGSymbol(pc),a2
	move.l	a2,a0			; NARG SET 0
	moveq	#T_SET,d0
	moveq	#0,d1
	bsr	AddSymbol
	move.l	a2,a0
	bsr	FindSymbol
	move.l	d0,symNARG(a5)		; NARG-Symboladresse speichern
	lea	CARGSymbol(pc),a2
	move.l	a2,a0			; CARG SET 0
	moveq	#T_SET,d0
	moveq	#0,d1
	bsr	AddSymbol
	move.l	a2,a0
	bsr	FindSymbol
	move.l	d0,symCARG(a5)		; CARG-Symboladresse speichern
	lea	__RSSymbol(pc),a2
	move.l	a2,a0			; __RS SET 0
	moveq	#T_SET,d0
	moveq	#0,d1
	bsr	AddSymbol
	move.l	a2,a0
	bsr	FindSymbol
	move.l	d0,sym__RS(a5)		; __RS-Symboladresse speichern
	lea	__SOSymbol(pc),a2
	move.l	a2,a0			; __SO SET 0
	moveq	#T_SET,d0
	moveq	#0,d1
	bsr	AddSymbol
	move.l	a2,a0
	bsr	FindSymbol
	move.l	d0,sym__SO(a5)		; __SO-Symboladresse speichern
	lea	__FOSymbol(pc),a2
	move.l	a2,a0			; __FO SET 0
	moveq	#T_SET,d0
	moveq	#0,d1
	bsr	AddSymbol
	move.l	a2,a0
	bsr	FindSymbol
	move.l	d0,sym__FO(a5)		; __FO-Symboladresse speichern
	ENDC
	lea	OptCSymbol(pc),a2
	move.l	a2,a0			; __OPTC SET 0
	moveq	#T_SET,d0
	moveq	#0,d1
	bsr	AddSymbol
	move.l	a2,a0
	bsr	FindSymbol
	move.l	d0,sym__OPTC(a5)
	bsr	setOPTC			; __OPTC SET <opt flags>
	lea	PhxAssSymbol(pc),a0	; _PHXASS_ SET 1  erzeugen
	moveq	#T_SET,d0
	moveq	#1,d1
	bsr	AddSymbol
	lea	VersionSymbol(pc),a0	; _VERSION_ SET version<<16|revision
	moveq	#T_SET,d0
	move.l	#VERSION<<16|REVISION,d1
	bsr	AddSymbol
	lea	CPUSymbol(pc),a0	; __CPU SET 680x0  erzeugen
	moveq	#T_SET,d0
	moveq	#0,d1
	move.b	MachinePreset(a5),d1
	mulu	#10,d1
	add.l	#68000,d1
	bsr	AddSymbol
	lea	FPUSymbol(pc),a0	; __FPU SET x  erzeugen
	moveq	#T_SET,d0
	moveq	#0,d1
	move.b	FPUidPreset(a5),d1
	bsr	AddSymbol
	lea	MMUSymbol(pc),a0	; __MMU SET x  erzeugen
	moveq	#T_SET,d0
	moveq	#0,d1
	tst.b	PMMUidPreset(a5)
	beq.s	4$
	moveq	#1,d1
4$:	bsr	AddSymbol
	lea	Buffer(a5),a2
	move.l	a2,a0
	move.l	#"_MC6",(a0)+
	move.l	#"8882",(a0)+
	move.w	#"_\0",(a0)		; "_MC68882_" in den Buffer kopieren
	move.b	AttnFlags+1(a6),d2
	lsl.b	#8-AFB_68882,d2
	bcc.s	1$
	bsr.s	3$			; _MC68882_ SET 1
	add.b	d2,d2
	bra.s	2$
1$:	add.b	d2,d2
	bcc.s	2$
	subq.b	#1,7(a2)		; _MC68881_ SET 1
	bsr.s	3$
2$:	move.l	#"8060",4(a2)
	lea	6(a2),a0
	tst.b	AttnFlags+1(a6)		; _MC68060_ SET 1
	bmi.s	3$
	subq.b	#2,(a0)
	add.b	d2,d2
	bcs.s	3$			; _MC68040_ SET 1
	subq.b	#1,(a0)
	add.b	d2,d2
	bcs.s	3$			; _MC68030_ SET 1
	subq.b	#1,(a0)
	add.b	d2,d2
	bcs.s	3$			; _MC68020_ SET 1
	subq.b	#1,(a0)
	add.b	d2,d2
	bcs.s	3$			; _MC68010_ SET 1
	subq.b	#1,(a0)			; _MC68000_ SET 1
3$:	move.l	a2,a0			; Im Buffer generiertes Symbol in StringTable
	bsr	AddString		;  kopieren und als SET-Symbol etablieren
	move.l	d0,a0
	moveq	#T_SET,d0
	moveq	#1,d1
	bra	AddSymbol


setOPTC:
; __OPTC Symbol auf den Zustand der aktuellen Optimierungs-Flags
; setzen, do daß "OPTC __OPTC" funktioniert.
	move.l	sym__OPTC(a5),a0
	moveq	#0,d0
	move.b	OptFlag(a5),d0
	tst.b	TotalBccOpt(a5)
	beq.s	1$
	or.w	#$100,d0
1$:	tst.b	Movem2MoveOpt(a5)
	beq.s	2$
	or.w	#$200,d0
2$:	move.l	d0,sym_Value(a0)
	rts


AllocSymTabs:
; Speicher für die globale Hashtable und den ersten SymbolTable Chunk
; besorgen.
	move.l	GloHashTabSize(a5),d0
	lsl.l	#2,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer die Symbol-HashTable
	move.l	d0,SymHashList(a5)
	beq	OutofMemError
	bsr	GetSymbolTable		; Globale Symbol Table
	move.l	d0,SymbolTable(a5)
	rts


FreeSymTabs:
; Speicher für alle globalen SymbolTable Chunks sowie für die Hashtable
; freigeben.
	move.l	SymbolTable(a5),d0
	beq.s	1$
	move.l	d0,a0
	move.l	#SYMBOLBLK+stab_HEAD,d0
	bsr	FreeChunkList
1$:	move.l	SymHashList(a5),d0
	beq.s	2$
	move.l	d0,a1
	move.l	GloHashTabSize(a5),d0
	lsl.l	#2,d0
	jsr	FreeMem(a6)
2$:	rts


MakeCharTabs:
; 256er-Tabellen für Großbuchstabenumwandlung und Überprüfung auf gültige
; Zeichen in Labels und Argumenten
	lea	ucase_tab(a5),a0	; Tabelle für Klein-Großbuchst. Umwandlung
	move.w	#255,d0
	lea	1(a0,d0.w),a1
1$:	move.b	d0,-(a1)
	dbf	d0,1$
	lea	'a'(a0),a1
	lea	'A'(a0),a0
	moveq	#25,d0
2$:	move.b	(a0)+,(a1)+		; upper case für a - z
	dbf	d0,2$
	lea	ucase_tab+$c0(a5),a0
	lea	ucase_tab+$e0(a5),a1
	moveq	#30,d0
3$:	move.b	(a0)+,(a1)+		; upper case für ISO-Umlaute
	dbf	d0,3$
	lea	label1_tab(a5),a0	; Label-Check (1.Zeichen)
	lea	l1tabInit(pc),a1
	bsr.s	makeChkTab
	lea	label2_tab(a5),a0	; Label-Check (Rest)
	lea	l2tabInit(pc),a1
	bsr.s	makeChkTab
	lea	arg1_tab(a5),a0		; Arg-Check (1.Zeichen)
	lea	a1tabInit(pc),a1
	bsr.s	makeChkTab
	lea	arg2_tab(a5),a0		; Arg-Check (Rest)
	lea	a2tabInit(pc),a1

makeChkTab:
; Tabelle zur Zeichenüberprüfung initialisieren (ist vorher schon 0)
; a0 = Table256
; a1 = InitTable
	moveq	#0,d1
1$:	moveq	#0,d0
	move.b	(a1)+,d0		; Start-Zeichen
	beq.s	4$
	move.b	(a1)+,d1		; Ende-Zeichen
2$:	st	(a0,d0.w)
	addq.w	#1,d0
	cmp.w	d1,d0
	bls.s	2$
	bra.s	1$
3$:	move.b	(a1)+,(a0,d0.w)		; Spezialwert setzen
	bra.s	1$
4$:	move.b	(a1)+,d0		; Ende oder Spezialzeichen?
	bne.s	3$
	rts


l1tabInit:
	dc.b	'0','9','A','Z','a','z',$c0,$d6,$d8,$f6,$f8,$fe
	dc.b	'_','_','.','.',0,'@',1,0,0
l2tabInit:
	dc.b	'0','9','A','Z','a','z',$c0,$d6,$d8,$f6,$f8,$fe
	dc.b	'%','%','_','_','.','.',0,0
;	   dc.b '_','_','.','.',0,0
a1tabInit:
	dc.b	'0','9','@','Z','a','z',$c0,$d6,$d8,$f6,$f8,$fe
	dc.b	'_','_','$','$','%','%','.','.',0,$22,1,0,$27,1,0,0
a2tabInit:
	dc.b	'0','9','A','Z','a','z',$c0,$d6,$d8,$f6,$f8,$fe
	dc.b	'%','%','_','_','.','.',0,0
;	   dc.b '_','_','.','.',0,0
	even


LinearSecList:
; SectionPtr aus mehreren SecList-Chunks in eine lineare Section-Liste
; eintragen. Wenn überhaupt keine Section existiert, wird eine leere
; Dummy Code-Section erzeugt.
	movem.l	a2-a3,-(sp)
	bra.s	2$
1$:	bsr	GetSection
	move.l	d0,a3
	lea	ExpressionStack(a5),a0	; für Section Namen mißbrauchen
	move.l	#"CODE",(a0)
	clr.b	4(a0)
	move.l	a0,sec_Name(a3)
	move.l	#HUNK_CODE,sec_Type(a3)
	IFND	GIGALINES
	move.w	NumLines(a5),sec_DeclLine(a3)
	ELSE
	move.l	NumLines(a5),sec_DeclLine(a3)
	ENDC
	bsr	GetHunkExtTable
	move.l	d0,sec_HunkExtTable(a3)
	addq.l	#hext_HEAD,d0
	move.l	d0,sec_HETPt(a3)
	move.l	SecTabPtr(a5),a0
	move.l	a3,secl_Section(a0)	; Neue Section in SectionList eintragen
	addq.l	#seclSIZE,secl_FreeEntry(a0)
	addq.w	#1,SectionCnt(a5)
2$:	moveq	#0,d0
	move.w	SectionCnt(a5),d0
	beq.s	1$			; gar keine Section da?
	lsl.w	#2,d0
	moveq	#0,d1
	jsr	AllocMem(a6)
	move.l	d0,LinSecList(a5)	; Speicher für LinearSectionList
	beq	OutofMemError
	move.l	d0,a0
	move.l	SecTabPtr(a5),d0	; Erster SecList-Chunk
3$:	move.l	d0,a2
	lea	secl_HEAD(a2),a1
	move.l	secl_FreeEntry(a2),d1
	bne.s	5$
	move.l	a1,d1
	add.l	#SECLISTBLK,d1
	bra.s	5$
4$:	move.l	(a1)+,(a0)+		; Section-Ptr kopieren
5$:	cmp.l	a1,d1			; Am Chunk-Ende angelangt ?
	bne.s	4$
	move.l	(a2),d0			; Naechster SecList-Chunk vorhanden ?
	bne.s	3$
	movem.l	(sp)+,a2-a3
	rts


UndefinedXDEFs:
; Alle undefinierten XDEFs bemängeln.
	movem.l	d2/a2-a3,-(sp)
	moveq	#bit_XDEF,d1
1$:	move.l	SymbolTable(a5),d0
4$:	move.l	d0,a3
	lea	stab_HEAD(a3),a2
	move.w	stab_NumSymbols(a3),d2
	bra.s	5$
2$:	move.w	sym_Type(a2),d0
	bclr	d1,d0			; XDEF?
	beq.s	3$
	tst.w	d0			; sonst kein Type-Flag gesetzt?
	bne.s	3$
	move.l	d1,-(sp)		; bit_XDEF retten
	lea	undefxdef_txt(pc),a0
	move.l	sym_Name(a2),-(sp)
	move.l	sp,a1
	bsr	printf			; Warnung ausgeben, XDEF undefiniert
	movem.l	(sp)+,d0-d1
3$:	lea	SymbolSIZE(a2),a2
5$:	dbf	d2,2$			; nächstes Symbol
	move.l	(a3),d0
	bne.s	4$			; noch ein Symbol-Chunk ?
	movem.l	(sp)+,d2/a2-a3
	rts

undefxdef_txt:
	dc.b	"Undefined XDEF: %s\n\n",0
	even


PUBLICtoXREF:
; Alle globalen Symbole vom Typ PUBLIC werden zu XREF gemacht
	movem.l	d4-d5/a2-a3,-(sp)
	move.w	#T_XREF,d4
	move.w	#T_PUBLIC,d1
1$:	move.l	SymbolTable(a5),d0
4$:	move.l	d0,a3
	lea	stab_HEAD(a3),a2
	move.w	stab_NumSymbols(a3),d5
	bra.s	5$
2$:	move.w	d1,d0
	and.w	sym_Type(a2),d0
	beq.s	3$
	move.w	d4,sym_Type(a2)		; PUBLIC->XREF
3$:	lea	SymbolSIZE(a2),a2
5$:	dbf	d5,2$			; nächstes Symbol
	move.l	(a3),d0
	bne.s	4$			; noch ein Symbol-Chunk ?
	movem.l	(sp)+,d4-d5/a2-a3
	rts


AbsXDEFtoExtTable:
; Alle absoluten XDEF-Symbole in die ExtTable-Liste der ersten,
; nicht leeren, Section uebernehmen. Wenn alle leer sind, werden die XDEFs
; in die letzte leere aufgenommen.
	movem.l	d2-d3/a2-a3,-(sp)
	move.l	LinSecList(a5),a1
	move.w	SectionCnt(a5),d1
	subq.w	#1,d1
1$:	move.l	(a1)+,a0		; Section
	tst.w	sec_Type+2(a0)		; Offset-Section? (ist keine echte Section)
	beq.s	2$
	tst.l	sec_Size(a0)		; leer?
2$:	dbne	d1,1$
	move.l	a0,-(sp)		; Zeiger auf Section retten
	move.l	sec_HunkExtTable(a0),d0
6$:	move.l	d0,a2			; letzten HunkExtTable-Chunk suchen
	move.l	(a2),d0
	bne.s	6$
	move.l	sec_HETPt(a0),a0
	move.l	ExtAbsTab(a5),a3
	move.l	ExtAbsPtr(a5),d3
	lea	hext_HEAD(a3),a1
	move.l	a1,d2
	add.l	#HEXTTABBLK,d2
	bra.s	9$
8$:	move.l	d0,a2
	lea	hext_HEAD(a2),a0
9$:	move.l	a2,d1
	add.l	#hext_HEAD+HEXTTABBLK,d1
	bra.s	11$
10$:	; Eintraege aus ExtAbsTab anfuegen
	move.l	(a1)+,(a0)+
11$:	cmp.l	d2,a1
	bne.s	12$
	move.l	(a3),d0
	beq.s	20$
	move.l	d0,a3
	lea	hext_HEAD(a3),a1
	move.l	a1,d2
	add.l	#HEXTTABBLK,d2
12$:	cmp.l	d3,a1
	beq.s	20$
	cmp.l	d1,a0
	bne.s	10$
	move.l	a1,-(sp)
	bsr	GetHunkExtTable
	move.l	d0,(a2)
	move.l	(sp)+,a1
	bra.s	8$
20$:	move.l	(sp)+,a1
	move.l	a0,sec_HETPt(a1)
	movem.l	(sp)+,d2-d3/a2-a3
	rts


XREFtoExtTable:
; Alle globalen NREFs und XREFs werden in die External-Tabellen der Sections
; aufgenommen, in denen sie verwendet werden
	movem.l	d2-d5/a2-a3,-(sp)
	move.l	SymbolTable(a5),d0
1$:	move.l	d0,a3
	lea	stab_HEAD(a3),a2
	move.w	stab_NumSymbols(a3),d5
	bra	8$
2$:	move.w	sym_Type(a2),d0
	move.w	d0,d1
	and.w	#T_XREF|T_NREF,d1	; XREF oder NREF suchen
	beq	7$
	move.l	a3,d3
	move.l	LinSecList(a5),a3
	move.w	SectionCnt(a5),d4
	subq.w	#1,d4
	moveq	#0,d2
4$:	move.l	(a3)+,CurrentSec(a5)	; Alle Sections durchgehen
	move.l	sym_RefList(a2),d0
5$:	move.l	d0,a0
	lea	rlist_HEAD(a0),a1
	move.w	rlist_NumRefs(a0),d0
	bmi.s	52$
	bra.s	58$
52$:	move.w	#REFLISTBLK/rlistSIZE-1,d0
53$:	cmp.b	(a1),d2			; Referenz auf CurrentSec ?
	bne.s	57$
	move.l	a2,a0
	bsr	AddExternal		; NREF/XREF in External-Liste aufnehmen
	bra.s	6$			; nicht noch nach weiteren suchen
57$:	lea	rlistSIZE(a1),a1
58$:	dbf	d0,53$
	move.l	(a0),d0
	bne.s	5$
6$:	addq.w	#1,d2			; nächste Section
	dbf	d4,4$
	move.l	d3,a3
7$:	lea	SymbolSIZE(a2),a2
8$:	dbf	d5,2$			; naechstes Symbol
	move.l	(a3),d0
	bne	1$			; noch ein Symbol-Chunk ?
	movem.l	(sp)+,d2-d5/a2-a3
	rts


Statistics:
; Assemblierungsstatistiken auf STDOUT ausgeben
	movem.l	AssTime(a5),d2-d3
	move.l	d3,d1
	beq.s	10$
	divu	#10000,d1		; MicroSec in 100tel wandeln
	swap	d1
	clr.w	d1
	swap	d1
	move.w	d1,d3
	bne.s	11$
10$:	moveq	#1,d1			; Zeit darf nicht 0.00 sein
11$:	move.w	d2,d0
	mulu	#100,d0
	add.l	d0,d1			; d1 AssTime in 100tel
	IFND	GIGALINES
	moveq	#0,d4
	move.w	NumLines(a5),d4
	move.w	#6000,d0
	mulu	d4,d0			; Anzahl der assembl. Zeilen * 6000
	bsr	DivMod			; d0 = Assemblierte Zeilen pro Minute
	move.l	d0,-(sp)
	movem.w	d2-d3,-(sp)
	move.l	d4,-(sp)
	ELSE
	move.l	NumLines(a5),d4
	swap	d4
	move.w	#6000,d0
	mulu	d4,d0			; Anzahl der assembl. Zeilen * 6000
	swap	d0
	clr.w	d0
	swap	d4
	mulu	#6000,d4
	add.l	d4,d0
	bsr	DivMod			; d0 = Assemblierte Zeilen pro Minute
	move.l	d0,-(sp)
	movem.w	d2-d3,-(sp)
	move.l	NumLines(a5),-(sp)
	ENDC
	LOCS	S_STATS
	move.l	sp,a1
	bsr	printf			; xxx lines in xx.x sec = xxx lines/min
	lea	12(sp),sp
	moveq	#0,d0
	move.w	LocSymCnt(a5),d0
	move.l	d0,-(sp)
	move.w	SymbolCnt(a5),d0
	move.l	d0,-(sp)
	LOCS	S_STATS+1
	move.l	sp,a1
	bsr	printf			; Anzahl der global/local Symbols ausgeben
	addq.l	#8,sp
	moveq	#0,d1
	moveq	#0,d2			; Anzahl der Code/Data/BSS Sections,
	moveq	#0,d3			;  sowie deren Groesse bestimmen
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	LinSecList(a5),a1	; Alle Sections durchgehen
	move.w	SectionCnt(a5),d1
	subq.w	#1,d1
1$:	move.l	(a1)+,a0		; Section
	tst.l	sec_Size(a0)
	beq.s	2$
	swap	d1
	or.b	sec_Flags(a0),d1
	swap	d1
	move.w	sec_Type+2(a0),d0
	sub.w	#HUNK_CODE,d0		; Code-Section?
	bne.s	3$
	addq.w	#1,d2
	add.l	sec_Size(a0),d5
	bra.s	2$
3$:	subq.w	#1,d0			; Data-Section?
	bne.s	4$
	addq.w	#1,d3
	add.l	sec_Size(a0),d6
	bra.s	2$
4$:	subq.w	#1,d0			; Bss-Section?
	bne.s	2$
	addq.w	#1,d4
	add.l	sec_Size(a0),d7
2$:	dbf	d1,1$
	swap	d1
	tst.b	d1			; wurden Optimierungen vorgenommen ?
	beq.s	6$
	move.l	BytesGained(a5),-(sp)
	LOCS	S_STATS+2
	move.l	sp,a1
	bsr	printf			; Anzahl der gewonnenen Bytes ausgeben
	addq.l	#4,sp
6$:	LOCS	S_STATS+6
	move.l	a0,a2
	LOCS	S_STATS+7
	move.l	a0,a3
	LOCS	S_STATS+3
	bsr	printf
	tst.w	d2
	bne.s	61$
	move.l	a3,a0
	bsr	printf
	bra.s	7$
61$:	move.l	d5,-(sp)
	move.w	d2,-(sp)
	move.l	a2,a0
	move.l	sp,a1
	bsr	printf
	addq.l	#6,sp
7$:	LOCS	S_STATS+4
	bsr	printf
	tst.w	d3
	bne.s	71$
	move.l	a3,a0
	bsr	printf
	bra.s	8$
71$:	move.l	d6,-(sp)
	move.w	d3,-(sp)
	move.l	a2,a0
	move.l	sp,a1
	bsr	printf
	addq.l	#6,sp
8$:	LOCS	S_STATS+5
	bsr	printf
	tst.w	d4
	bne.s	81$
	move.l	a3,a0
	bsr	printf
	bra.s	9$
81$:	move.l	d7,-(sp)
	move.w	d4,-(sp)
	move.l	a2,a0
	move.l	sp,a1
	bsr	printf
	addq.l	#6,sp
9$:	rts


	cnop	0,4
GetCnopTab:
; -> d0 = CNOPTable-Adr
	move.l	#CNOPTABBLK+ctab_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer CnopTable
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	ctab_HEAD+CNOPTABBLK(a0),a1
	move.l	a1,ctab_End(a0)
	rts


	IFND	FREEASS
GetIncNestList:
; -> d0 = IncNestList-Adr
	move.l	#INCNSTBLK+nl_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer IncNestList
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	nl_HEAD(a0),a1
	move.l	a1,nl_FreeEntry(a0)
	rts


GetIncludeList:
; -> d0 = IncNestList-Adr
	move.l	#INCLISTBLK+incl_HEAD,d0
	moveq	#0,d1
	jsr	AllocMem(a6)		; Speicher fuer IncludeList
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0			; Initialisieren
	clr.l	(a0)+
	move.l	a0,(a0)
	addq.l	#8,(a0)			; FreeEntry
	rts


	cnop	0,4
GetMacNestList:
; -> d0 = MacNestList-Adr
	move.l	#MACNSTBLK+nl_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer MacNestList
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	nl_HEAD(a0),a1
	move.l	a1,nl_FreeEntry(a0)
	rts


GetRepTab:
; -> d0 = RepTab-Adr
	move.l	#REPTABBLK+reptab_HEAD,d0
	moveq	#0,d1
	jsr	AllocMem(a6)		; Speicher für RepTab (REPT...ENDR)
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	reptab_HEAD(a0),a1
	clr.l	(a0)+
	move.l	a1,(a0)
	rts
	ENDC


	cnop	0,4
GetLocalSymbolTable:
; -> d0 = SymbolTable-Adr
	move.l	#LOCSYMBLK+lstab_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher für SymbolTable
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	lstab_HEAD(a0),a1
	move.l	a1,lstab_FreeEntry(a0)
	move.w	SecNum(a5),lstab_DeclHunk(a0)
	rts

	cnop	0,4
GetSymbolTable:
; -> d0 = SymbolTable-Adr
	move.l	#SYMBOLBLK+stab_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher für SymbolTable
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	stab_HEAD(a0),a1
	move.l	a1,stab_FreeEntry(a0)
	rts


GetLineDebugTab:
; -> d0 = LineDebug-Adr
	move.l	#LINEDEBUGBLK+lindb_HEAD,d0
	moveq	#0,d1
	jsr	AllocMem(a6)		; Speicher für LineDebugTab (SourceLevelDebug)
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	lindb_HEAD(a0),a1
	clr.l	(a0)+
	move.l	a1,(a0)
	rts


	cnop	0,4
GetSUT:
; -> d0 = SpeedUpTab-Adr
	move.l	a6,-(sp)
	move.l	SysBase(a5),a6
	move.l	#SUTBLK+sut_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	sut_HEAD+SUTBLK-sutSIZE(a0),a1
	move.l	a1,sut_Last(a0)
	move.l	(sp)+,a6
	rts


	IFND	FREEASS
	cnop	0,4
GetMacParameter:
; -> d0 = MacParameter-Adr
	move.l	#MACPARBLK+mpar_HEAD,d0	; Speicher fuer MacParameter
	bra.s	alloc_clr
	ENDC

GetRegRefList:
; -> d0 = RegRefList-Adr
	move.l	#REGREFLISTBLK+rrl_HEAD,d0 ; Speicher fuer RegRefList
	bra.s	alloc_clr

GetSection:
; -> d0 = Section-Adr
	move.l	#SectionSIZE,d0		; Speicher fuer Section
	bra.s	alloc_clr

GetHunkData:
; -> d0 = HunkData-Adr
	move.l	#HUNKDATBLK+hd_HEAD,d0	; Speicher fuer HunkData
	bra.s	alloc_clr

GetHunkExtTable:
; -> d0 = HunkExtTable-Adr
	move.l	#HEXTTABBLK+hext_HEAD,d0 ; Speicher fuer HunkExtTable
	bra.s	alloc_clr

GetHunkSymbolTable:
; -> d0 = HunkSymbolTable-Adr
	move.l	#HSYMTABBLK+hsym_HEAD,d0 ; Speicher fuer HunkSymbolTable
	bra.s	alloc_clr

GetHunkReloc:
; -> d0 = HunkReloc-Adr
	move.l	#HUNKRELOCBLK+hrel_HEAD,d0 ; Speicher fuer HunkReloc
	bra.s	alloc_clr

GetStringTable:
; -> d0 = StringTable-Adr
	move.l	#STRTABBLK+strt_HEAD,d0	; Speicher fuer StringTable-Struktur
	bra.s	alloc_clr

GetLocalParts:
; -> d0 = LocalParts-Adr
	move.l	#LOCALPARTSBLK+lp_HEAD,d0 ; Speicher fuer LocalParts
	bra.s	alloc_clr

GetLocalRegs:
; -> d0 = LocalRegNames-Adr
	move.l	#MAXLOCREGNAMES*4*16,d0 ; Speicher fuer Lok. Reg.namen
	bra.s	alloc_clr

GetLocalHashTable:
; -> d0 = HashTable-Adr
	move.l	LocHashTabSize(a5),d0	; Speicher für HashTable
	lsl.l	#2,d0

alloc_clr:
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer StringTable-Struktur
	tst.l	d0
	beq	OutofMemError
	rts


GetReferenceList:
; -> d0 = ReferenceList-Adr
	move.l	a2,-(sp)
	move.l	RefListBlockPtr(a5),a2
	move.l	rlblk_FreeEntry(a2),d0
	bne.s	1$
	bsr	GetRefListBlock		; RefListBlock ist voll - neuen besorgen
	move.l	d0,(a2)
	move.l	d0,a2
	move.l	a2,RefListBlockPtr(a5)
	move.l	rlblk_FreeEntry(a2),d0
1$:	move.l	d0,a0
	lea	REFLISTSIZE(a0),a0	; Zeiger auf naechsten freien Eintrag
	lea	rlblk_HEAD+RLBLOCKBLK(a2),a1
	cmp.l	a1,a0			; noch Platz genug fuer weiteren Eintrag ?
	blo.s	2$
	sub.l	a0,a0
2$:	move.l	a0,rlblk_FreeEntry(a2)
	move.l	(sp)+,a2
	rts


GetRefListBlock:
; -> d0 = RefListBlock-Adr
	move.l	#RLBLOCKBLK+rlblk_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer RefListBlock
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	rlblk_HEAD(a0),a1
	move.l	a1,rlblk_FreeEntry(a0)
	rts


GetSecList:
; -> d0 = SecList-Adr
	move.l	#SECLISTBLK+secl_HEAD,d0
	moveq	#0,d1
	jsr	AllocMem(a6)		; Speicher fuer SecList
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0			; Initialisieren
	clr.l	(a0)+
	move.l	a0,(a0)
	addq.l	#4,(a0)			; Zeiger auf ersten freien Eintrag
	rts


GetDistanceList:
; -> d0 = DistanceList-Adr
	move.l	#DISTLISTBLK+dist_HEAD,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)		; Speicher fuer DistanceList
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0
	lea	dist_HEAD(a0),a1
	move.l	a1,dist_FreeEntry(a0)
	rts


GetStringBuffer:
; -> d0 = StringBuffer-Adr
	move.l	#STRINGBLK+sb_HEAD,d0
	moveq	#0,d1
	jsr	AllocMem(a6)		; Speicher fuer StringBuffer-Struktur
	tst.l	d0
	beq	OutofMemError
	move.l	d0,a0			; Initialisieren
	clr.l	(a0)+
	move.l	#STRINGBLK,(a0)		; Speicherplatz im Buffer
	rts


AddString:
; String in den StringBuffer kopieren und den neuen Zeiger darauf zurueckliefern
; a0 = StringPtr
; -> d0 = NewStringPtr
	move.l	a0,a1
	moveq	#-1,d1
3$:	tst.b	(a1)+
	dbeq	d1,3$
	neg.l	d1			; Stringlänge + Nullbyte
	move.l	StrBufChunk(a5),a1
	cmp.l	sb_Free(a1),d1		; noch Platz im Buffer ?
	bls.s	1$
	movem.l	d1/a0-a1,-(sp)
	bsr	GetStringBuffer		; Neuen StringBuffer-Chunk anfordern
	movem.l	(sp)+,d1/a0-a1
	move.l	d0,(a1)			; Link setzen
	move.l	d0,StrBufChunk(a5)
	move.l	d0,a1
	addq.l	#sb_HEAD,d0
	move.l	d0,StringPtr(a5)
1$:	sub.l	d1,sb_Free(a1)
	move.l	StringPtr(a5),d0
	move.l	d0,a1
	subq.w	#1,d1
2$:	move.b	(a0)+,(a1)+		; String kopieren
	dbf	d1,2$
	move.l	a1,StringPtr(a5)
	rts


	IFND	SMALLASS
AddLongFloat:
; d0 = Zeiger auf 64- oder 96-Bit IEEE-FloatingPoint
; -> d0 = Zeiger auf Fliesskommazahl im StringBuffer
	move.l	d0,a0
	moveq	#12,d1			; 12 Bytes fuer .x und .p
	cmp.b	#os_DOUBLE,OpcodeSize(a5)
	bne.s	1$
	moveq	#8,d1			; 8 Bytes fuer .d
1$:	move.l	StrBufChunk(a5),a1
	cmp.l	sb_Free(a1),d1		; noch Platz im Buffer ?
	bls.s	2$
	movem.l	d1/a0-a1,-(sp)
	bsr	GetStringBuffer		; Neuen StringBuffer-Chunk anfordern
	beq	OutofMemError
	movem.l	(sp)+,d1/a0-a1
	move.l	d0,(a1)			; Link setzen
	move.l	d0,StrBufChunk(a5)
	move.l	d0,a1
	addq.l	#sb_HEAD,d0
	move.l	d0,StringPtr(a5)
2$:	move.l	StringPtr(a5),d0
	btst	#0,d0			; auf gerader Adresse ?
	beq.s	3$
	addq.l	#1,d0
	subq.l	#1,sb_Free(a1)
3$:	sub.l	d1,sb_Free(a1)
	move.l	d0,a1
4$:	move.l	(a0)+,(a1)+		; Fliesskommazahl kopieren
	subq.l	#4,d1
	bne.s	4$
	move.l	a1,StringPtr(a5)
	rts
	ENDC


	cnop	0,4
printf:
; a0 = FormatString
; a1 = DataStream
	move.l	StdOut(a5),d0

fprintf:
; d0 = FileHandle
; a0 = FormatString
; a1 = DataStream
	movem.l	d2-d3/a6,-(sp)
	move.l	DosBase(a5),a6
	move.l	d0,d1
	move.l	a0,d2
	move.l	a1,d3
	jsr	VFPrintf(a6)		; String formatieren und ausgeben (OS2.04)
	movem.l	(sp)+,d2-d3/a6
	rts

	cnop	0,4
sprintf:
; a0 = Buffer
; a1 = FormatString
; a2 = DataStream
	movem.l	a3/a6,-(sp)
	move.l	a0,a3
	move.l	a1,a0
	move.l	a2,a1
	lea	1$(pc),a2
	move.l	SysBase(a5),a6
	jsr	RawDoFmt(a6)
	movem.l	(sp)+,a3/a6
	rts
	cnop	0,4
1$:	move.b	d0,(a3)+
	rts


ReadOptions:
; Sucht zunächst nach einem Option-File PHXOPTIONS im aktuellen Verzeichnis.
; Wenn dies nicht gefunden wird, in ENV:PhxAss/PHXOPTIONS. Schließlich
; wird noch die Commandline, die PhxAss direkt übergeben wurde, ausgewertet.
; -> Z = 1, wenn kein Fehler aufgetreten ist.
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	move.w	#"X ",rda_srcbuf(a5)	; Dummy-Source Name
	lea	phxlocalopts(pc),a0
	bsr.s	readOptFile		; Lokales Options-File PHXOPTIONS vorhanden?
	bpl.s	1$
	lea	phxglobalopts(pc),a0	; Globales Options-File lesen
	bsr.s	readOptFile
	bmi.s	4$			; existiert auch nicht?
1$:	move.w	d5,d0
	addq.l	#2,d5			; Dummy-Sourcename nicht vergessen
	subq.w	#2,d0			; abschließendes '\n' nicht ersetzen
	lea	rda_srcbuf+2(a5),a0
	moveq	#'\n',d1
2$:	cmp.b	(a0)+,d1		; '\n' durch ' ' ersetzen, für ReadArgs()
	bne.s	3$
	move.b	#' ',-1(a0)
3$:	dbf	d0,2$
	moveq	#DOS_RDARGS,d1
	moveq	#0,d2
	jsr	AllocDosObject(a6)	; RDA-Struktur erzeugen
	move.l	d0,d3
	beq.s	4$			; will nicht?
	move.l	d3,a4			; d3,a4 rda
	lea	rda_srcbuf(a5),a0
	move.l	a0,CS_Buffer(a4)
	move.l	d5,CS_Length(a4)
	clr.l	CS_CurChr(a4)
	moveq	#1,d7
	bsr.s	CheckCommandLine	; OptionFile parsen
	moveq	#DOS_RDARGS,d1
	move.l	a4,d2
	jsr	FreeDosObject(a6)	; RDA-Struktur freigeben
	tst.w	d7
	bne.s	9$			; Fehler beim Parsen?
4$:	moveq	#0,d3
	moveq	#-1,d7
	bsr.s	CheckCommandLine	; Jetzt noch die 'echte' CommandLine parsen
9$:	move.l	(sp)+,a6
	rts

readOptFile:
; a0 = Filename
; scratch: d2,d3,d4
; -> d5 = Length (oder -1, bei Fehler)
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	jsr	Open(a6)		; versuchen, PHXOPTIONS zu öffnen
	move.l	d0,d4
	bne.s	1$
	moveq	#-1,d5
	rts
1$:	move.l	d4,d1
	lea	rda_srcbuf+2(a5),a0
	move.l	a0,d2
	move.l	#4*BUFSIZE-2,d3
	jsr	Read(a6)		; PHXOPTIONS lesen
	move.l	d4,d1
	move.l	d0,d5
	jsr	Close(a6)
	tst.l	d5			; Read-Error o.ä. dabei?
	rts


CheckCommandLine:
; Befehlszeile, die PhxAss übergeben wurde, auswerten.
; d7 = 1: Source nicht beachten (PHXOPTIONS), -1: Commandline auswerten
; d3 = RDArgs, oder NULL wenn die Standard-CmdLine ausgewertet werden soll
; -> Z = 1 (d7), wenn kein Fehler aufgetreten ist
	move.l	a6,-(sp)
	move.l	SysBase(a5),a6
	IFND	FREEASS
	move.l	#35<<2,d6		; d6 Speicher für CmdLineArray anfordern
	ELSE
	move.l	#27<<2,d6
	ENDC
	move.l	d6,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)
	move.l	d0,d4			; d4 CmdArray
	beq	OutofMemError
	move.l	DosBase(a5),a6
	lea	cmdTemplate(pc),a0
	move.l	a0,d1
	move.l	d4,d2
	jsr	ReadArgs(a6)		; DOS CommandLine auswerten lassen
	move.l	d0,d5			; d5 RdArgs
	bne.s	2$			; Fehler?
	tst.b	d7
	bpl.s	100$
	jsr	IoErr(a6)		; dann den Grund herausfinden
	moveq	#116,d1
	cmp.l	d1,d0			; ERROR_REQUIRED_ARG_MISSING ?
	bne.s	1$
	bsr	Instructions		; dann Bedienungsanleitung ausgeben
	bra	99$
1$:	move.l	d0,d1
	moveq	#0,d2
	jsr	PrintFault(a6)		; DOS-Fehlermeldung
	bra	99$
100$:	moveq	#5,d0			; Invalid PHXOPTIONS file
	bsr	Error
	bra	99$
2$:	move.l	SysBase(a5),a6
	move.l	d4,a2			; CmdArray untersuchen
	move.l	(a2)+,a0
	bsr	StrLen			; testen, ob Extension gegeben (.asm,.s,...)
	lea	(a0,d0.w),a1
	subq.w	#1,d0
	moveq	#'.',d1
3$:	cmp.b	-(a1),d1
	dbeq	d0,3$
	beq.s	4$
	move.l	a0,SourceName(a5)
	lea	extension_asm(pc),a0	; keine Ext. gefunden, ".asm" anhängen
	bsr	ConcatExtension		; "source.asm" erzeugen
4$:	bsr	AddString		; Source-Name speichern
	move.l	d0,SourceName(a5)
	move.l	(a2)+,a0
	move.l	a0,d0			; TO: Object-Name bestimmen?
	beq.s	40$
	lea	OpcodeBuffer(a5),a1
41$:	move.b	(a0)+,(a1)+
	bne.s	41$
	subq.l	#2,a1
	move.b	(a1)+,d0
	cmp.b	#'/',d0			; TO spezifiziert Pfad-Namen?
	beq.s	42$
	cmp.b	#':',d0
	bne.s	44$
42$:	move.l	a1,-(sp)
	lea	extension_obj(pc),a0
	bsr	ConcatExtension		; "source.o" erzeugen 
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	move.l	a0,d1
	jsr	FilePart(a6)		; Zeiger auf Filenamen (ohne Pfad) holen
	move.l	(sp)+,a6
	move.l	d0,a0
	move.l	(sp)+,a1
43$:	move.b	(a0)+,(a1)+
	bne.s	43$
44$:	lea	OpcodeBuffer(a5),a0
	bra.s	5$
40$:	tst.b	d7
	bpl.s	51$
	tst.l	ObjectName(a5)
	bne.s	51$
	lea	extension_obj(pc),a0
	bsr	ConcatExtension		; "source.o" erzeugen
5$:	bsr	AddString		; Object-Name speichern
	move.l	d0,ObjectName(a5)
51$:	move.l	(a2)+,d0
	beq.s	6$			; OPT: Optimize-Flags?
	move.l	d0,a1
	bset	#sw_OPTIMIZE,Switches(a5)
	clr.b	OptFlag(a5)
	bsr	GetOptFlags
6$:
	IFND	FREEASS
	move.l	(a2)+,d0
	beq.s	8$			; EQU: Equates-File?
	move.l	d0,a0
	cmp.b	#'*',(a0)
	bne.s	7$
	lea	extension_equ(pc),a0
	bsr	ConcatExtension		; EQU * :"source.equ" erzeugen
7$:	bsr	AddString
	move.l	d0,EquatesName(a5)
8$:	move.l	(a2)+,d0
	beq.s	10$			; LIST: Listing-File?
	move.l	d0,a0
	cmp.b	#'*',(a0)
	bne.s	9$
	lea	extension_lst(pc),a0
	bsr	ConcatExtension		; LIST * :"source.lst" erzeugen
9$:	bsr	AddString
	move.l	d0,AssListName(a5)
10$:	move.l	(a2)+,d0		; INCPATH: Include-Paths?
	beq.s	11$
	move.l	d0,a1
	move.l	IncDirTable(a5),a0
	bsr	BuildStringTable0	; Name(n) in die IncDirTable aufnehmen
	beq.s	11$
	moveq	#8,d0			; DirectoryName expected
	bra	98$
11$:	move.l	(a2)+,d0		; HEADINC: Header-Includes?
	beq.s	12$
	move.l	d0,a1
	move.l	IncFileTable(a5),a0
	bsr	BuildStringTable0	; Name(n) in die IncFileTable aufnehmen
	beq.s	12$
	moveq	#7,d0			; FileName expected
	bra	98$
12$:	move.l	(a2)+,d0		; PAGE: Page Length?
	beq.s	13$
	move.l	d0,a0
	move.b	3(a0),PageLength(a5)
	ENDC
13$:	move.l	(a2)+,d0		; ERRORS: Max Number of Errors
	beq.s	18$
	move.l	d0,a0
	move.b	3(a0),MaxErrors(a5)
18$:	moveq	#20,d1
	move.l	(a2)+,d0		; ERRCODE: Return code in case of an error
	beq.s	14$
	move.l	d0,a0
	move.b	3(a0),d1
14$:	move.b	d1,ReturnCode(a5)
	move.l	(a2)+,d0		; SMALLDATA: SD=<reg>[,<sec>]
	beq.s	19$
	move.b	#-2,NearSec(a5)		; default: Small Data Mode (__MERGED)
	move.l	d0,a0
	moveq	#os_BYTE,d0
	bsr	GetValue		; Base-Register bestimmen
	move.w	d0,d1
	tst.w	d2
	beq.s	15$
	moveq	#4,d1			; Bei Fehler Default A4 annehmen
	bra.s	16$
15$:	moveq	#10,d0			; Bei Fehler: Illegal base register...
;	cmp.w	#2,d1			; muss zwischen A2 und A6 liegen
;	blo	98$
	cmp.w	#6,d1
	bhi	98$
16$:	move.b	d1,MainModel(a5)
	move.b	d1,Model(a5)
	move.b	(a0)+,d0
	cmp.b	#',',d0
	bne.s	17$
	moveq	#os_BYTE,d0		; Near-Section bestimmen (kein reines
	bsr	GetValue		;  Small-Data)
	tst.w	d2
	bne.s	17$
	move.b	d0,NearSec(a5)
17$:	bset	#sw_MODEL,Switches(a5)

19$:	tst.l	(a2)+			; SMALLCODE ?
	beq.s	20$
	bset	#sw_NEARCODE,Switches(a5)
20$:	tst.l	(a2)+			; LARGE: Force Large Code Model?
	beq.s	21$
	st	MainModel(a5)
	st	Model(a5)
	bclr	#sw_NEARCODE,Switches(a5)
	bset	#sw_MODEL,Switches(a5)
21$:
	IFND	FREEASS
	tst.l	(a2)+			; VERBOSE ?
	beq.s	27$
	bset	#sw2_VERBOSE,Switches2(a5)
	ENDC
27$:	tst.l	(a2)+			; SYMDEBUG ?
	beq.s	22$
	bset	#sw_SYMDEBUG,Switches(a5)
22$:	tst.l	(a2)+			; LINEDEBUG ?
	beq.s	26$
	bset	#sw2_LINEDEBUG,Switches2(a5)
26$:	tst.l	(a2)+			; ALIGN ?
	beq.s	23$
	bset	#sw_ALIGN,Switches(a5)
23$:
	IFND	FREEASS
	tst.l	(a2)+			; CASE ?
	beq.b	231$
	st	IgnoreCase(a5)
231$:	tst.l	(a2)+			; XREFS ?
	beq.s	24$
	tst.l	AssListName(a5)		; dann muß auch ein Listing File exisitieren
	bne.s	28$
	moveq	#80,d0			; No references without a listing file!
	bra	98$
28$:	bset	#sw_REFS,Switches(a5)
24$:
	ENDC
	tst.l	(a2)+			; QUIET ?
	beq.s	25$
	bset	#sw_QUIET,Switches(a5)
	IFND	FREEASS
	bclr	#sw2_VERBOSE,Switches2(a5)
	ENDC
25$:	tst.l	(a2)+			; NOWARN?
	beq.s	30$
	bset	#sw2_NOWARNINGS,Switches2(a5)

30$:	tst.l	(a2)+			; NOEXE ?
	beq.s	31$
	bset	#sw_NOEXE,Switches(a5)	; niemals Executables erzeugen
31$:	move.l	(a2)+,d0		; MACHINE: 0,1,2,3,4,6 (oder 68000,68010...)
	beq.s	35$
	move.l	d0,a0
	move.l	(a0),d1
	move.l	#68000,d0
	cmp.l	d0,d1
	blo.s	32$
	sub.l	d0,d1
	divu	#10,d1
32$:	moveq	#11,d0			; 11: Machine not supported
	cmp.b	#4,d1			; 68040?
	blo.s	34$
	beq.s	33$
	cmp.b	#6,d1			; 68060? - 68050 gibt's nicht!
	bne	98$
33$:	move.b	#1,FPUidPreset(a5)	; FPU ist im 68040 und 68060 enthalten!
34$:	move.b	d1,MachinePreset(a5)
35$:	move.l	(a2)+,d0		; FPU: 0-7
	beq.s	36$
	move.l	d0,a0
	move.b	3(a0),d1
	moveq	#68,d0
	cmp.b	#7,d1
	bhi	98$			; out of range error
	move.b	d1,FPUidPreset(a5)
36$:	tst.l	(a2)+			; PMMU?
	beq.s	361$
	st	PMMUidPreset(a5)
361$:	move.l	#DEF_BIOBUFSIZE,bioBufSize(a5)
	move.l	(a2)+,d0		; BUFSIZE ?
	beq.s	37$
	move.l	d0,a0
	move.l	(a0),d0			; =0 ?
	beq.s	37$
	move.l	d0,bioBufSize(a5)
37$:	tst.l	(a2)+			; SHOWOPT?
	beq.s	38$
	bset	#sw2_SHOWOPTS,Switches2(a5)
38$:	move.l	(a2)+,d0		; PRI ?
	beq.s	39$
	bset	#sw2_FORCEPRI,Switches2(a5) ; Eigene Priorität setzen
	move.l	d0,a0
	move.b	3(a0),d0
	ext.w	d0
	ext.l	d0
	move.l	myTask(a5),a1
	jsr	SetTaskPri(a6)
	move.b	d0,OldTaskPri(a5)	; alte Priorität retten
39$:	tst.l	(a2)+			; EXE?
	beq.s	48$
	bset	#sw2_EXE,Switches2(a5)

48$:	move.l	#DEF_GLOBHASHTAB,GloHashTabSize(a5)
	move.l	(a2)+,d0		; GLOBHASHTAB ?
	beq.s	49$
	move.l	d0,a0
	move.b	3(a0),d1
	moveq	#68,d0
	cmp.b	#8,d1			; Global HashTable zwischen 2^8 und 2^16?
	blo	98$
	cmp.b	#16,d1
	bhi	98$
	moveq	#0,d0
	bset	d1,d0
	move.l	d0,GloHashTabSize(a5)
49$:	move.l	#DEF_LOCHASHTAB,LocHashTabSize(a5)
	move.l	(a2)+,d0		; LOCHASHTAB ?
	beq.s	50$
	move.l	d0,a0
	move.b	3(a0),d1
	moveq	#68,d0
	cmp.b	#2,d1			; Global HashTable zwischen 2^2 und 2^10?
	blo	98$
	cmp.b	#10,d1
	bhi	98$
	moveq	#0,d0
	bset	d1,d0
	move.l	d0,LocHashTabSize(a5)
50$:	move.l	#DEF_MNEMHASHTAB,MnemHashTabSize(a5)
	move.l	(a2)+,d0		; MNEMOHASHTAB ?
	beq.s	52$
	move.l	d0,a0
	move.b	3(a0),d1
	moveq	#68,d0
	cmp.b	#6,d1			; Mnemo HashTable zwischen 2^6 und 2^16?
	blo	98$
	cmp.b	#16,d1
	bhi	98$
	moveq	#0,d0
	bset	d1,d0
	move.l	d0,MnemHashTabSize(a5)
52$:	tst.l	(a2)+			; ZEROPADDING ?
	beq.s	53$
	st	ZeroPadding(a5)
53$:	tst.l	(a2)+			; RELOCATABLE ?
	beq.s	60$
	st	Relocatable(a5)

60$:	tst.b	d7			; Hash- und Symbol-Table initialisieren
	bpl	88$			; Aufruf von PHXOPTIONS? Kein SET!
	move.l	GloHashTabSize(a5),d0
	subq.l	#1,d0
	move.w	d0,GloHashMask(a5)
	move.l	LocHashTabSize(a5),d0
	subq.l	#1,d0
	move.w	d0,LocHashMask(a5)
	bsr	AllocSymTabs
	move.l	MnemHashTabSize(a5),d0
	subq.l	#1,d0
	move.w	d0,MnemHashMask(a5)

80$:	move.l	(a2),d0			; SET: SET symbol[=value],... ?
	beq.s	88$			; (SET muß immer als letztes kommen!)
	move.l	d0,a3
81$:	move.l	a3,a0
	moveq	#82,d0			; Error82 = Illegal characters in symbol name
	tst.b	(a0)
	beq	98$			; kein Name angegeben ?
	lea	LabelBuffer(a5),a1
	move.w	#BUFSIZE-1,d0
	bsr	ReadArgument		; SymbolName in den LabelBuffer lesen
	add.w	d0,a3
	moveq	#82,d0
	moveq	#1,d1			; Default-Value von 1 annehmen
	move.b	(a3),d2
	beq.s	82$			; folgt noch das Value ?
	cmp.b	#',',d2
	beq.s	82$
	cmp.b	#'=',d2
	bne	98$
	lea	1(a3),a0
	moveq	#os_LONG,d0
	bsr	GetValue		; Value ausrechnen
	move.l	a0,a3
	moveq	#0,d1
	tst.w	d2			; ungueltiges Value - dann 0 annehmen
	bne.s	82$
	move.l	d0,d1
82$:	moveq	#T_SET,d0
	lea	LabelBuffer(a5),a0
	bsr	AddSymbol		; SET-Symbol deklarieren
	move.b	(a3)+,d0
	beq.s	88$
	cmp.b	#',',d0			; Noch ein SET-Symbol ?
	beq.s	81$

88$:	lea	extension_unit(pc),a0
	bsr	ConcatExtension
	clr.b	(a1)			; Default Unit-Name = SourceName ohne Ext.
	bsr	AddString
	move.l	d0,UnitName(a5)
	moveq	#0,d7			; keine Fehler
	bra.s	90$
98$:	bsr	Error
90$:	move.l	DosBase(a5),a6
	move.l	d5,d1
	jsr	FreeArgs(a6)
99$:	move.l	SysBase(a5),a6
	move.l	d6,d0
	move.l	d4,a1
	jsr	FreeMem(a6)		; CmdArray freigeben
	move.l	(sp)+,a6
	tst.w	d7
	rts

phxglobalopts:
	dc.b	"ENV:PhxAss/"
phxlocalopts:
	dc.b	"PHXOPTIONS",0

cmdTemplate:
	IFND	FREEASS
	dc.b	"FROM/A,TO/K,OPT/K,EQU/K,LIST/K,I=INCPATH/K,H=HEADINC/K,PAGE/K/N,"
	dc.b	"ERRORS/K/N,RC=ERRCODE/K/N,SD=SMALLDATA/K,SC=SMALLCODE/S,LARGE/S,VERBOSE/S,"
	dc.b	"DS=SYMDEBUG/S,DL=LINEDEBUG/S,A=ALIGN/S,C=CASE/S,XREFS/S,Q=QUIET/S,"
	dc.b	"NOWARN/S,NOEXE/S,M=MACHINE/K/N,FPU/K/N,PMMU/S,BUFSIZE/K/N,"
	dc.b	"SHOWOPT/S,PRI/K/N,EXE/S,GH=GLOBHASHTAB/K/N,"
	dc.b	"LH=LOCHASHTAB/K/N,MH=MNEMOHASHTAB/K/N,Z=ZEROPADDING/S,"
	dc.b	"REL=RELOCATABLE/S,SET/K",0
extension_lst:
	dc.b	"lst",0
extension_equ:
	dc.b	"equ",0
	ELSE
	dc.b	"FROM/A,TO/K,OPT/K,ERRORS/K/N,RC=ERRCODE/K/N,SD=SMALLDATA/K,SC=SMALLCODE/S,"
	dc.b	"LARGE/S,DS=SYMDEBUG/S,DL=LINEDEBUG/S,A=ALIGN/S,Q=QUIET/S,NOWARN/S,"
	dc.b	"NOEXE/S,M=MACHINE/K/N,FPU/K/N,PMMU/S,BUFSIZE/K/N,SHOWOPT/S,"
	dc.b	"PRI/K/N,EXE/S,GH=GLOBHASHTAB/K/N,LH=LOCHASHTAB/K/N,"
	dc.b	"MH=MNEMOHASHTAB/K/N,Z=ZEROPADDING/S,REL=RELOCATABLE/S,"
	dc.b	"SET/K",0
	ENDC
extension_obj:
	dc.b	"o",0
extension_asm:
	dc.b	"asm"
extension_unit:
	dc.b	0
	even


GetOptFlags:
; Liest die gegebenen OptFlags und speichert sie in OptFlag
; a1 = FlagsString
; d2 wird zerstört!
	move.b	(a1),d0
	beq.s	54$
	cmp.b	#'0',d0			; "OPT 0" verbietet jede Optimierung
	beq.s	50$
	cmp.b	#'1',d0			; 1 = Standard
	beq.s	5$
	cmp.b	#'2',d0			; 2 = Standard + T (*)
	beq.s	60$
	cmp.b	#'*',d0			; * = alle Standard-Optimierungen + T
	bne.s	6$
60$:	move.b	#$0f,OptFlag(a5)	; normal + T
	st	TotalBccOpt(a5)
	bra.s	52$
6$:	cmp.b	#'3',d0			; 3 = alles optimieren was geht
	beq.s	61$
	cmp.b	#'!',d0			; ! = 3
	bne.s	7$
61$:	; full
	st	OptFlag(a5)
	st	TotalBccOpt(a5)
	st	Movem2MoveOpt(a5)
	bra.s	53$
5$:	; normal
	move.b	#$0f,OptFlag(a5)
	bra.s	51$
50$:	; 0
	clr.b	OptFlag(a5)
51$:	clr.b	TotalBccOpt(a5)
52$:	clr.b	Movem2MoveOpt(a5)
53$:	clr.b	DistChkDisable(a5)
54$:	rts
7$:	moveq	#0,d0
	moveq	#0,d2			; d2 OptFlags
1$:	lea	ucase_tab(a5),a0
	move.b	(a1)+,d0
	move.b	(a0,d0.w),d0		; upper case
	beq	99$
	cmp.b	#'L',d0			; DevPac L+ ?
	bne.s	42$
	bsr.s	20$
	beq.s	42$
	bpl.s	41$
	bclr	#sw_NOEXE,Switches(a5)	; niemals Executables erzeugen
	bra	18$
41$:	bset	#sw_NOEXE,Switches(a5)
	bra	18$
42$:	lea	10$(pc),a0
	moveq	#7,d1
2$:	cmp.b	(a0)+,d0
	dbeq	d1,2$
	bne.s	3$
	bset	d1,d2
	bra.s	1$
3$:	cmp.b	#'T',d0			; (T)otal Branch Optimization
	bne.s	8$
	st	TotalBccOpt(a5)
	bra.s	1$
8$:	cmp.b	#'I',d0			; (I)gnore Branch Distances
	bne.s	9$
	st	DistChkDisable(a5)
	bra.s	1$
20$:	cmp.b	#'+',(a1)		; DevPac +/- Check
	bne.s	21$			; d1 = 0 NoDevPac
	moveq	#1,d1			;     -1 '-'
	bra.s	22$			;	 1 '+'
21$:	cmp.b	#'-',(a1)
	bne.s	23$
	moveq	#-1,d1
22$:	addq.l	#1,a1
	rts
23$:	moveq	#0,d1
	rts
9$:
	IFND	FREEASS
	cmp.b	#'C',d0			; C+/- ?
	bne.s	11$
	bsr.s	20$
	beq	19$
	smi	IgnoreCase(a5)
	bra.s	18$
11$:
	ENDC
	cmp.b	#'D',d0			; D+/- ?
	bne.s	13$
	bsr.s	20$
	beq.s	14$
	bmi.s	12$
	bset	#sw_SYMDEBUG,Switches(a5)
	bset	#sw2_LINEDEBUG,Switches2(a5)
	bra.s	18$
12$:	bclr	#sw_SYMDEBUG,Switches(a5)
	bclr	#sw2_LINEDEBUG,Switches2(a5)
	bra.s	18$
14$:	st	Movem2MoveOpt(a5)	; MOVEM (D)n -> MOVE (D)n optimization
	bra	1$
13$:	cmp.b	#'O',d0			; O<n>   Optimize 1-6 (DevPac)
	bne	19$
	addq.l	#1,a1			; <n> ignorieren...
18$:	cmp.b	#',',(a1)		; Hinter DevPac-Opts sind Kommas erlaubt
	bne.s	180$
	addq.l	#1,a1
180$:	bra	1$
19$:	movem.l	d0-d1/a0-a1,-(sp)
	move.w	d0,-(sp)
	LOCS	S_OPTIGN
	move.l	sp,a1
	bsr	printf			; Optimize '?' ignored !
	addq.l	#2,sp
	movem.l	(sp)+,d0-d1/a0-a1
	bra	1$
99$:	tst.b	d2			; OptFlags wurden manipuliert?
	beq.s	98$
	move.b	d2,OptFlag(a5)
98$:	rts
10$:	dc.b	"MSPLBQRN"
	even


Instructions:
	; Bedienungsanleitung ausgeben (dann CleanUp)
	bsr.s	title
	moveq	#S_INSTR,d2		; Instructions zeilenweise ausgeben, damit
1$:	;  man sie unterbrechen kann
	move.w	d2,d0
	bsr	LocStr
	bsr	printf
	addq.w	#1,d2
	cmp.w	#S_INSTRLAST+1,d2
	bne.s	1$
	LOCS	S_REFERTO
	bsr	printf
	moveq	#-1,d0			; CleanUp erzwingen
instr_rts:
	rts


PrintTitle:
	btst	#sw_QUIET,Switches(a5)
	bne.s	instr_rts
title:
	lea	phxassName(pc),a0
	move.w	#REVISION,-(sp)
	move.w	#VERSION,-(sp)
	move.l	sp,a1
	bsr	printf			; Titelzeile ausgeben
	addq.l	#4,sp
	LOCS	S_TITLE
	bra	printf

phxassName:
	IFD	SMALLASS
	dc.b	"\nPhxAss MC68000 Macro Assembler v%d.%02d"
	ENDC
	IFD	FREEASS
	dc.b	"\nPhxAss MC680x0/68851/6888x Assembler v%d.%02d"
	ENDC
	IFND	SMALLASS
	IFND	FREEASS
	dc.b	"\nPhxAss MC680x0/68851/6888x Macro Assembler v%d.%02d"
	ENDC
	ENDC
	IFD	BETA
	dc.b	"ß"
	ENDC
	IFD	ALPHA
	dc.b	"(alpha)"
	ENDC
; Seit V4.40 ist die Giga-Version Standard!
;	IFD	GIGALINES
;	IFD	DOTNOTLOCAL
;	dc.b	" (Special Gigaline Version)"
;	ELSE
;	dc.b	" (Gigaline Version)"
;	ENDC
;	ENDC
	dc.b	0
	even


PrintPass:
	btst	#sw_QUIET,Switches(a5)
	bne.s	1$
	LOCS	S_PASS
	moveq	#1,d0
	add.b	Pass(a5),d0
	move.w	d0,-(sp)
	move.l	sp,a1
	bsr	printf
	addq.l	#2,sp
1$:	rts


ReadSourceCode:
; Speicher fuer Source + -h includes besorgen und einlesen
	moveq	#0,d4			; SourceLength
	moveq	#0,d5			; Zaehler fuer Anzahl der -h includes
	IFND	FREEASS
	move.l	IncFileTable(a5),d0
	beq.s	3$
	move.l	d0,a3
1$:	lea	strt_HEAD(a3),a1
	lea	STRTABBLK(a3),a2
2$:	move.l	(a1)+,d0
	beq.s	3$			; kein Eintrag mehr da ?
	addq.w	#1,d5
	move.l	d0,a0
	bsr	StrLen			; Laenge des IncFileNames
	add.w	#12,d0			; + <spc>include<spc>"..."<cr> (12 Zeichen)
	add.w	d0,d4
	cmp.l	a2,a1			; Chunk am Ende ?
	bne.s	2$
	move.l	(a3),d0
	beq.s	3$			; kein Chunk mehr da ?
	move.l	d0,a3
	bra.s	1$
	ELSE
	bra.s	3$
	ENDC
21$:	moveq	#12,d0			; File doesn't exist
	bra	FatalError
3$:
	IFND	GIGALINES
	move.w	d5,d0
	neg.w	d0
	addq.w	#1,d0
	move.w	d0,LineStart(a5)	; Startzeilennr fuer Assemblierung
	ELSE
	move.l	d5,d0
	neg.l	d0
	addq.l	#1,d0
	move.l	d0,LineStart(a5)
	ENDC
	move.l	SourceName(a5),a0
	bsr	FileSize		; Speicherbedarf des Files bestimmen -> d6
	bmi.s	21$
	move.l	d0,d6
	add.l	d4,d0			; Gesamtbedarf
	move.l	d0,d4
	addq.l	#1,d0			; 1 Byte fuer LF am Ende des Codes
	move.l	d0,SourceLength(a5)
	moveq	#0,d1
	jsr	AllocMem(a6)		; Speicher fuer SourceCode
	move.l	d0,SourceText(a5)
	beq	OutofMemError
	move.l	d0,a1
	move.b	#10,0(a1,d4.l)		; LF am Ende
	IFND	FREEASS
	subq.w	#1,d5
	bmi.s	10$			; keine include-Befehle vor den SourceCode ?

	lea	hinclude_txt(pc),a0
	move.l	a0,d2
	move.l	IncFileTable(a5),a4
4$:	lea	strt_HEAD(a4),a2
	lea	STRTABBLK(a2),a3
5$:	move.l	d2,a0
	moveq	#hinclude_size-1,d0
6$:	move.b	(a0)+,(a1)+		;  include "
	dbf	d0,6$
	move.l	(a2)+,a0
	bsr	StrLen
	subq.w	#1,d0
	bpl.s	7$			; Include-FileName hat Laenge 0 ?
	moveq	#13,d0
	bsr	Error
	lea	-hinclude_size(a1),a1
	IFND	GIGALINES
	addq.w	#1,Line(a5)		; include wieder vergessen
	ELSE
	addq.l	#1,Line(a5)
	ENDC
	bra.s	8$			; und ueberspringen
7$:	move.b	(a0)+,(a1)+		; FileName einsetzen
	dbf	d0,7$
	move.b	#$22,(a1)+		; " und <cr> anhaengen
	move.b	#10,(a1)+
8$:	cmp.l	a3,a2			; Chunk zuende ?
	bne.s	9$
	move.l	(a4),a4
	lea	strt_HEAD(a4),a2
	lea	STRTABBLK(a2),a3
9$:	dbf	d5,5$
	ENDC

10$:	move.l	a1,d5			; Buffer-Base
	move.l	a6,a4			; Source-Code in Buffer einlesen
	move.l	DosBase(a5),a6
	move.l	SourceName(a5),d1
	move.l	#MODE_OLDFILE,d2
	jsr	Open(a6)		; File exisitiert unter Garantie (FileSize)
	move.l	d0,d4
	move.l	d4,d1
	lea	SrcOperBuffer(a5),a2
	move.l	a2,d2
	move.l	#4*BUFSIZE,d3
	jsr	NameFromFH(a6)		; ... den vollständigen Pfad-Namen bestimmen
	move.l	a2,a0
	tst.l	d0
	bne.s	13$
	move.l	SourceName(a5),a0
13$:	bsr	AddString
	move.l	d0,DebugPath(a5)
	move.l	d4,d1
	move.l	d5,d2
	move.l	d6,d3
	jsr	Read(a6)		; Quelltext einlesen
	move.l	d0,d6
	move.l	d4,d1
	jsr	Close(a6)
	move.l	a4,a6
	tst.l	d6
	bpl.s	11$			; Read-Error ?
	moveq	#14,d0
	bra	FatalError
11$:
	IFND	FREEASS
	move.l	IncFileTable(a5),d0	; IncFileTable freigeben
	beq.s	12$
	move.l	d0,a0
	move.l	#STRTABBLK+strt_HEAD,d0
	bsr	FreeChunkList
	clr.l	IncFileTable(a5)
	ENDC
12$:	move.l	d5,a0			; AsmOne-Source?
	lea	asmone_id(pc),a1
	moveq	#3,d0
14$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,14$
	bne.s	99$
	move.l	d5,a0
	moveq	#$2a,d0			; '*'
	moveq	#42,d1
15$:	move.b	d0,(a0)+		; Cursor-Pos. Settings auskommentieren
	dbf	d1,15$
	move.b	#10,(a0)+
99$:	rts

asmone_id:
	dc.b	$f9,$fa,$f9,$fa

	IFND	FREEASS
hinclude_size =	10			; Buchstaben
hinclude_txt:
	dc.b	" include \""
	even


OpenListingFile:
; Falls gewuenscht, wird das Listing file zum Schreiben geoeffnet
	move.l	AssListName(a5),d1
	bne.s	1$
	rts
1$:	move.l	a6,a2
	move.l	DosBase(a5),a6
	move.l	#MODE_NEWFILE,d2
	jsr	Open(a6)
	move.l	d0,ListFileHandle(a5)
	move.l	d0,d4
	bne.s	2$
	clr.l	AssListName(a5)
	move.l	a2,a6
	moveq	#79,d0			; Unable to create file
	bra	Error
2$:	st	ListEn(a5)		; ListingEnable
	clr.b	PageCnt(a5)
	bsr	PageTitle		; Datum, Filename, Seitennummer
	move.l	d4,d1
	moveq	#0,d2
	moveq	#OFFSET_CURRENT,d3
	jsr	Seek(a6)
	addq.l	#1,d0			; FormFeed mitrechnen
	move.l	d0,SeekTitleOffset(a5)	; Offset auf Filepointer fuer PageTitle + FF
	lea	phxassName(pc),a0
	move.w	#REVISION,-(sp)
	move.w	#VERSION,-(sp)
	move.l	sp,a1
	move.l	d4,d0
	bsr	fprintf			; Titeltext
	LOCS	S_TITLE
	move.l	d4,d0
	bsr	fprintf
	move.l	sp,a0
	move.b	#10,(a0)
	clr.b	1(a0)
	move.l	d4,d0
	bsr	fprintf			; Leerzeile
	addq.l	#4,sp
	addq.b	#TITLE_LINES+1,PageLine(a5)
	move.l	d4,d1
	moveq	#0,d2
	moveq	#OFFSET_CURRENT,d3
	jsr	Seek(a6)
	move.l	d0,SeekListBegin(a5)
	move.l	a2,a6
	rts


PageTitle:
; Erste Zeile einer Seite enthaelt immer Datum, Filename und Seitennummer
	bsr	GetSysTime
	LOCS	S_PAGE
	moveq	#1,d0
	add.b	PageCnt(a5),d0
	move.b	d0,PageCnt(a5)
	move.w	d0,-(sp)
	move.l	SourceName(a5),-(sp)
	lea	TimeString(a5),a1
	move.l	a1,-(sp)
	move.l	sp,a1
	move.l	ListFileHandle(a5),d0
	bsr	fprintf			; ins File ausgeben
	lea	10(sp),sp
	move.b	#2,PageLine(a5)		; In Zeile 2 geht's weiter
	rts
	ENDC


FileSize:
; Bestimmt die Groesse des angegebenen Files in Bytes
; a0 = FileName
; -> d0 = Size in Bytes (-1=Error)
	movem.l	d2-d4/a2/a6,-(sp)
	move.l	DosBase(a5),a6
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	Lock(a6)
	move.l	d0,d4			; existiert das File ?
	bne.s	1$
2$:	moveq	#-1,d0
	bra.s	3$
1$:	move.l	d4,d1
	lea	FileInfoBlock(a5),a2
	move.l	a2,d2
	jsr	Examine(a6)
	move.l	d0,-(sp)
	move.l	d4,d1
	jsr	UnLock(a6)
	move.l	(sp)+,d0
	beq.s	2$			; FileSize konnte nicht bestimmt werden ?
	tst.l	4(a2)
	bpl.s	2$			; File ist ein Directory ?
	move.l	124(a2),d0		; File-Size
3$:	movem.l	(sp)+,d2-d4/a2/a6
	rts


	IFND	FREEASS
CheckENVVars:
; Environment-Variable PHXASSINC suchen und in IncDirENV speichern (oder 0)
	lea	EnvVarInc(pc),a0
	bsr	getENVstring		; PHXASSINC lesen
	bmi.s	1$			; nicht gefunden?
	bsr	AddString
	move.l	d0,IncDirENV(a5)
1$:	rts


getENVstring:
; a0 = ENVVarName
; -> a0 = StringBuffer
; -> d0 = Länge des Strings
; -> N-Flag = Error
	movem.l	d2-d4/a6,-(sp)
	move.l	DosBase(a5),a6
	move.l	a0,d1
	lea	rda_srcbuf+2(a5),a0
	move.l	a0,d2
	move.l	#4*BUFSIZE-2,d3
	moveq	#0,d4
	jsr	GetVar(a6)		; Environment Variable suchen und auslesen
	movem.l	(sp)+,d2-d4/a6
	lea	rda_srcbuf+2(a5),a0
	tst.l	d0
	rts

EnvVarInc:
	dc.b	"PhxAss/PHXASSINC",0
	even


BuildStringTable0:
; CmdLine-BuildStringTable ins richtige Format bringen
; a0 = StringTable
; a1 = StringList
	movem.l	d2-d4/a2-a4,-(sp)
	move.l	a0,a2
	moveq	#'"',d3
	moveq	#',',d4
	lea	Buffer(a5),a3
	move.l	a3,a0
1$:	move.b	d3,(a0)+
2$:	move.b	(a1)+,d0		; Jeden Eintrag in "..." einbetten
	beq.s	3$
	cmp.b	d4,d0
	beq.s	3$
	move.b	d0,(a0)+
	bra.s	2$
3$:	move.b	d3,(a0)+
	move.b	d0,(a0)+		; String zuende?
	bne.s	1$
	bra.s	bstab

BuildStringTable:
; Liste von durch ',' getrennte Strings in eine StringTable aufnehmen
; a0 = StringTable
; a1 = StringList
; -> Z=0 : Error
	movem.l	d2-d4/a2-a4,-(sp)
	move.l	a0,a2
	move.l	a1,a3
	move.l	#$00270022,d3		; ' und "
	moveq	#',',d4
bstab:
	move.l	(a2),d0			; freien StringTable-Chunk suchen
	beq.s	21$
	move.l	d0,a2
	bra.s	bstab
21$:	move.l	a2,a4			; ChunkPtr
	addq.l	#strt_HEAD,a2
22$:	tst.l	(a2)			; freien Eintrag suchen
	beq.s	1$
	addq.l	#4,a2
	bra.s	22$
1$:	move.l	a3,a0
2$:	move.b	(a3)+,d0		; Ende eines Strings suchen
	cmp.b	d3,d0
	beq.s	20$
	swap	d3
	cmp.b	d3,d0
	bne.s	5$
20$:	move.l	a3,a0
6$:	move.b	(a3)+,d0		; String innerhalb von Anfuehrungszeichen
	beq.s	3$
	cmp.b	d3,d0
	bne.s	6$
	bra.s	3$
5$:	cmp.b	d4,d0
	beq.s	3$
	cmp.b	#' ',d0
	bhi.s	2$
3$:	move.b	d0,d2
	clr.b	-1(a3)			; künstlichen String-Begrenzer setzen
	tst.b	(a0)
	bne.s	7$			; String sollte mind. Länge 1 haben
	moveq	#0,d0
	bra.s	9$			; IncDir "" trotzdem erlauben - bewirkt nichts!
7$:	bsr	AddString		; in StringBuffer kopieren
	move.l	d0,(a2)+		; seinen Zeiger in der StringTable vermerken
	lea	STRTABBLK(a4),a0
	cmp.l	a0,a2			; StringTable-Chunk voll ?
	bne.s	4$
	bsr	GetStringTable		; Neuen Chunk besorgen
	move.l	d0,(a4)			; linken
	move.l	d0,a4
	lea	strt_HEAD(a4),a2
4$:	clr.l	(a2)			; als naechsten freien Eintrag kennzeichnen
	move.b	d2,-1(a3)
	beq.s	9$
	cmp.b	d4,d2			; folgt ein weiterer String ?
	beq.s	1$
	cmp.b	d3,d2
	beq.s	40$
	swap	d3
	cmp.b	d3,d2
	bne.s	9$
40$:	cmp.b	(a3)+,d4
	beq.s	1$
	tst.b	-1(a3)
9$:	movem.l	(sp)+,d2-d4/a2-a4
	rts
	ENDC


ConcatExtension:
; Sucht SourceName ab, wo die gewuenschte Extension angehaengt werden kann, und
; legt dann den neuen Namen im Buffer ab.
; a0 = ExtensionPtr
; -> a0 = Zeiger auf Buffer
; -> a1 = Zeiger auf Extension-Punkt
	move.l	a0,-(sp)
	lea	Buffer(a5),a0
	moveq	#0,d1
	move.l	SourceName(a5),a1
1$:	move.b	(a1)+,d0		; Den letzten Punkt im SourceName suchen
	beq.s	2$
	move.b	d0,(a0)+
	cmp.b	#'.',d0
	bne.s	1$
	move.l	a0,d1
	subq.l	#1,d1
	bra.s	1$
2$:	tst.l	d1
	beq.s	3$
	move.l	d1,a0
3$:	move.b	#'.',(a0)+
	move.l	(sp)+,a1
4$:	move.b	(a1)+,(a0)+		; neue Extension anhaengen
	bne.s	4$
	lea	Buffer(a5),a0		; Zeiger auf Buffer uebergeben
	move.l	d1,a1			; Zeiger auf Extension-Punkt auch uebergeb.
	rts


OpenTimer:
; timer.device oeffnen
	jsr	CreateMsgPort(a6)
	move.l	d0,TimerPort(a5)
	beq	OutofMemError
	move.l	d0,a0
	move.l	#iotv_SIZE,d0
	jsr	CreateIORequest(a6)
	move.l	d0,TimerReq(a5)
	bne.s	1$
	move.l	TimerPort(a5),a0
	clr.l	TimerPort(a5)
	jsr	DeleteMsgPort(a6)
	bra	OutofMemError
1$:	move.l	d0,a1
	lea	TimerName(pc),a0
	moveq	#UNIT_VBLANK,d0
	moveq	#0,d1
	jsr	OpenDevice(a6)		; Timer-Device öffnen
	tst.b	d0
	beq.s	2$
	move.l	TimerReq(a5),a0
	jsr	DeleteIORequest(a6)
	move.l	TimerPort(a5),a0
	jsr	DeleteMsgPort(a6)
	clr.l	TimerReq(a5)
	clr.l	TimerPort(a5)
	moveq	#3,d0			; Can't open timer.device
	bra	FatalError
2$:	rts
TimerName:
	dc.b	"timer.device",0
	even


CurrentTime:
; liefert die augenblickliche Uhrzeit zurueck
; -> d0 = Seconds (since 1.1.1978)
; -> d1 = Micros
	move.l	TimerReq(a5),a1
	move.w	#TR_GETSYSTIME,io_Command(a1)
	jsr	DoIO(a6)		; Symstemzeit lesen
	move.l	TimerReq(a5),a1
	movem.l	iotv_time(a1),d0-d1
	rts


AssemTime:
; Zeit auslesen und von der Ass.Start-Zeit abziehen. Das Ergebnis wird wieder
; in AssTime gespeichert.
	move.l	a6,-(sp)
	movem.l	AssTime(a5),d0-d1
	movem.l	d0-d1,-(sp)
	bsr	CurrentTime
	movem.l	d0-d1,AssTime(a5)
	move.l	TimerReq(a5),a0
	move.l	io_Device(a0),a6	; TimerBase
	lea	AssTime(a5),a0
	move.l	sp,a1
	jsr	SubTime(a6)		; Differenz berechnen und in AssTime speichern
	addq.l	#8,sp
	move.l	(sp)+,a6
	rts


	IFND	FREEASS
GetSysTime:
; Erzeugt String des folgenden Formats:  "22 Dec 1991  12:41"
; Das Ergebnis steht dann in TimeString ! 0  3	   9   13 16
	movem.l	d2-d3/a2/a6,-(sp)
	lea	-cd_SIZE(sp),sp		; sp: ClockDate Struktur
	move.l	SysBase(a5),a6
	bsr	CurrentTime		; Zeit lesen
	move.l	sp,a0
	move.l	UtilityBase(a5),a6
	jsr	Amiga2Date(a6)		; seconds since 1.1.1978 in ClockDate umrechnen
	lea	TimeString(a5),a2	; a2 TimeString
	moveq	#' ',d2
	move.w	cd_mday(sp),d0		; Tag
	bsr	InsertTwoDigits
	move.b	d2,(a2)+
	move.w	cd_month(sp),d1		; Monat
	subq.w	#1,d1
	moveq	#ABMON_1,d0
	add.w	d1,d0
	add.w	d1,d1
	add.w	d1,d1
	lea	MonthNames(pc,d1.w),a0
	move.l	Locale(a5),d1		; Locale-Struktur vorhanden?
	beq.s	1$
	move.l	LocaleBase(a5),a6
	move.l	d1,a0			; dann Monatsabkürzung in Landesspache holen
	jsr	GetLocaleStr(a6)
	move.l	d0,a0
1$:	move.b	(a0)+,(a2)+		; Monat
	move.b	(a0)+,(a2)+
	move.b	(a0),(a2)+
	move.b	d2,(a2)+
	moveq	#0,d3
	move.w	cd_year(sp),d3
	divu	#100,d3
	move.w	d3,d0
	bsr	InsertTwoDigits		; Jahrhundert
	swap	d3
	move.w	d3,d0
	bsr	InsertTwoDigits		; Jahr
	move.b	d2,(a2)+
	move.b	d2,(a2)+
	move.w	cd_hour(sp),d0		; Stunden
	bsr	InsertTwoDigits
	move.b	#':',(a2)+
	move.w	cd_min(sp),d0		; Minuten
	bsr	InsertTwoDigits
	clr.b	(a2)
	lea	cd_SIZE(sp),sp
	movem.l	(sp)+,d2-d3/a2/a6
	rts

MonthNames:
	dc.b	"Jan",0,"Feb",0,"Mar",0,"Apr",0,"May",0,"Jun",0
	dc.b	"Jul",0,"Aug",0,"Sep",0,"Oct",0,"Nov",0,"Dec",0

InsertTwoDigits:
; Zweistellige Dezimalzahl an einer bestimmten Stelle im String einsetzen
; d0 = Zahl.w (0-99)
; a2 = StringPosition
	moveq	#0,d1
	move.w	d0,d1
	moveq	#'0',d0
	divu	#10,d1
	or.b	d0,d1
	move.b	d1,(a2)+
	swap	d1
	or.b	d0,d1
	move.b	d1,(a2)+
	rts
	ENDC


	cnop	0,4
DivMod:
; d0 = Dividend, d1 = Divisor
; -> d0 = Quotient
; -> d1 = Remainder
	move.l	a6,-(sp)
	move.l	UtilityBase(a5),a6
	jsr	SDivMod32(a6)		; Signed Division/Modulo
	move.l	(sp)+,a6
	rts


Warning:
; a1 = WarnString
	btst	#sw2_NOWARNINGS,Switches2(a5)
	bne.s	1$
	movem.l	d0-d2/a0/a4,-(sp)
	move.l	AssModeName(a5),-(sp)
	IFND	GIGALINES
	move.w	Line(a5),-(sp)
	clr.w	-(sp)
	move.w	AbsLine(a5),-(sp)
	clr.w	-(sp)
	ELSE
	move.l	Line(a5),-(sp)
	move.l	AbsLine(a5),-(sp)
	ENDC
	move.l	a1,-(sp)		; ErrorString
	clr.w	-(sp)			; ErrorNum = 0 (Warning)
	move.l	LineBase(a5),-(sp)
	move.l	SrcPtr(a5),a4		; Zeiger auf Folge-Zeile
	move.b	-(a4),d2		; LF der gerade assembl. Zeile loeschen
	clr.b	(a4)
	LOCS	S_ERRLIN
	move.l	sp,a1
	bsr	printf
	lea	22(sp),sp
	move.b	d2,(a4)			; und wieder setzen
	movem.l	(sp)+,d0-d2/a0/a4
1$:	rts


OutofMemError:
	moveq	#1,d0			; out of memory
	tst.w	Line(a5)
	beq.s	FatalError
	clr.w	Line(a5)		; keine Programmzeile mit ausgeben
	LOCS	S_NOMEM
	move.l	a0,AssModeName(a5)
	moveq	#1,d0

FatalError:
	move.l	CleanUpLevel(a5),sp
	clr.b	ErrorCnt(a5)
	bsr.s	Error
	bra	CleanUp


Error:
; d0 = ErrorNumber
	movem.l	d1-d3/a0-a2/a4/a6,-(sp)
	move.l	SysBase(a5),a6
	st	ErrorFlag(a5)		; kein Objectfile erzeugen
	IFND	GIGALINES
	moveq	#0,d1
	move.w	Line(a5),d1
	cmp.w	#65000,d1		; bis zur Zeile 65000 Informationen ausgeben
	blo.s	9$
	ELSE				; (danach können's nur -h Include-Lines sein)
	move.l	Line(a5),d1
	bpl.s	9$
	ENDC
	moveq	#0,d1
9$:	move.w	d0,d2
	add.w	#S_ERRORS,d0
	bsr	LocStr			; ErrorStr in aktueller Landessprache holen
	tst.w	d2
	bne.s	1$
	bsr	printf			; No error
	movem.l	(sp)+,d1-d3/a0-a2/a4/a6
	rts
1$:	move.l	AssModeName(a5),-(sp)
	tst.w	d1			; Programm-Fehler oder Assembler-Error ?
	bne.s	3$
	tst.b	AssMode(a5)
	bne.s	3$
	move.l	a0,-(sp)		; ErrorString
	move.w	d2,-(sp)		; ErrorNum
	lea	PrgErrTxt(pc),a0
	move.l	sp,a1
	bsr	printf
	lea	10(sp),sp
	bra.s	4$
3$:	move.l	d1,-(sp)		; ErrorLine
	IFND	FREEASS
	tst.b	AssMode(a5)
	bpl.s	2$			; Macro-Mode ?
	move.l	a0,a2
	LOCS	S_MACROERR
	move.l	sp,a1
	bsr	printf			; In line .. of macro .. :
	addq.l	#8,sp
	move.l	a2,a0
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
	move.l	a0,-(sp)		; ErrorString
	move.w	d2,-(sp)		; ErrorNum
	move.l	LineBase(a5),-(sp)
	move.l	SrcPtr(a5),a4		; Zeiger auf Folge-Zeile
	move.b	-(a4),d3		; LF der gerade assembl. Zeile loeschen
	clr.b	(a4)
	LOCS	S_ERRLIN
	move.l	sp,a1
	bsr	printf
	lea	22(sp),sp
	move.b	d3,(a4)			; und wieder setzen
4$:	move.b	ErrorCnt(a5),d0
	addq.b	#1,d0
	move.b	d0,ErrorCnt(a5)
	move.b	MaxErrors(a5),d1
	beq.s	99$
	cmp.b	d1,d0			; MaxErrors (default 5) überschritten?
	blo.s	99$
	clr.b	ErrorCnt(a5)
	jsr	CheckCont		; Continue?
99$:	movem.l	(sp)+,d1-d3/a0-a2/a4/a6
	rts


	end

