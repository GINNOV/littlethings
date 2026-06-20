**
**		   PhxLnk
**
**	 The Linker for PhxAss Objects
**
**	 Coded by F.Wille 1992 - 1998
**
**	   Assembler:  PhxAss V4.xx
**
** vb: Aenderungen von Volker Barthelmann Dezember 1995
** vb: AllocMem()/AllocVec durch MemPools ersetzt
**
** vb: Wenn V39 gesetzt ist, werden die MemPool-Routinen der exec.library
** vb: direkt benutzt, PhxLnk laeuft dann nur unter V39+.
** vb: Ist es nicht gesetzt werden die Routinen der amiga.lib benutzt, es
** vb: muss dann mit amiga.lib gelinkt werden.
**
** vb: Die Symbole PUDDLESIZE und THRESHSIZE bestimmen die Parameter der
** vb: MemPools.


	idnt	PhxLnk

VERSION		= 4
REVISION	= 32

	ifnd	V39
	xref	_LibCreatePool
	xref	_LibDeletePool
	xref	_LibAllocPooled
	endc

	ifnd	PUDDLESIZE
PUDDLESIZE	= 65536
	endc

	ifnd	THRESHSIZE
THRESHSIZE	= 65536
	endc


** Include Files **

	include	"lib/exec.i"
	include	"lib/dos.i"
	include	"lib/locale.i"

	include	"exec/execbase.i"
	include	"exec/memory.i"
	include	"dos/dosextens.i"
	include	"dos/doshunks.i"


** Macros **

REVSTRING macro
	dc.b	"$VER: PhxLnk "
	dc.b	$30+VERSION,$2e,$30+(REVISION/10),$30+(REVISION//10)
	ifd	ALPHA
	dc.b	" alpha"
	endc
	ifd	BETA
	dc.b	'ß'
	endc
	dc.b	" (17.11.98)\r\n",0
	endm

LOCS	macro
	ifgt	\1-127
	move.w	#\1,d0
	else
	moveq	#\1,d0
	endc
	bsr	LocStr
	endm

; Macro zum Berechnen des Hashcodes
; \1=NamePtr, \2=HashCode, \3=NameLen in Longwords, \4,\5=Scratch
HASHC	macro
	lsl.w	#2,\3
	subq.w	#1,\3
	moveq	#0,\2
	moveq	#0,\4
\@1$:	move.b	(\1)+,\4
	move.w	\2,\5		; bisheriger Hashcode * 3 + Buchstabe
	add.w	\2,\2
	add.w	\5,\2
	add.w	\4,\2
	dbf	\3,\@1$
	endm


** constants **

DEF_SECPERUNIT 	= 16		; Defaultwert für Anzahl Sections pro Unit
DEF_BUFSIZE 	= 8192		; Default-Buffersize für Buffered I/O
DEF_HASHTABSIZE = 4096		; Zahl der HashTable-Einträge
MAXOFNAMES	= 256		; Max.Anzahl Namen im ObjectNameFile

HUNK_RELOC32SHRT = HUNK_DREL32


** structures **

		rsreset		** struct Section **
NextSection 	rs.l 1
Type		rs.l 1
SectionID	rs.l 1
SecSize		rs.l 1		; absolute Section-Size (Bytes, inkl. ALVs)
LastReloc32	rs.l 1		; letzer benutzter absoluter Reloc32-Offset + 4
HunkList	rs.l 3		; sizeof(struct MinList)
ALVList		rs.l 1		; Einfach-verkettete Liste von struct ALVs
OddSection	rs.b 1		; Section endet durch ALVs nicht auf Longword
Section_rsrvd	rs.b 1
SectionName	rs
SectionSIZE	equ 256
SecNameSIZE	equ SectionSIZE-SectionName

		rsreset		** struct Hunk **
NextHunk	rs.l 1
PrevHunk	rs.l 1
HunkData	rs.l 1		; Adr. 32-Bit aligned!
DataSize	rs.l 1		; garantiert druch 4 teilbar!
HunkSection	rs.l 1
HunkReloc8	rs.l 1
HunkReloc16	rs.l 1
HunkReloc32	rs.l 1
HunkNearReloc	rs.l 1
HunkExtern	rs.l 1
HunkSymbol	rs.l 1
HunkDebug	rs.l 1		; Zeiger auf einfach-verkettetete Liste!
NumXRefs	rs.w 1
FreeXRefRel	rs.w 1		; Offset auf XRefRelocs (zuerst 0)
XRefRelocs	rs.l 1		; Array: SecNum.w, Offset.l, ...
UnitStruct	rs.l 1
SecBaseOffset	rs.l 1
HunkSIZE	rs

		rsreset		** struct Unit **
U_Next		rs.l 1
U_Select	rs.b 1		; wird eingebunden? (wichtig für .lib-Units)
U_Reserved	rs.b 1
U_NumHunks	rs.w 1
U_HunkPtr	rs.l 1		; arrays[NumHunks], Hunks dieser Unit
U_HunkSec	rs.l 1		;  zugehörige Section für alle Hunks
U_HunkOffset	rs.l 1		;  Section-Offsets für alle Hunks
U_ObjName	rs.l 1
U_Name		rs.l 1
U_NameBuffer	rs.b SecNameSIZE
UnitSIZE	rs

		rsreset		** struct XDEF **
NextXdef	rs.l 1		; nächstes XDEF in der Hash-Chain
XdefUnit	rs.l 1
XdefSec		rs.l 1		; Section in der XDEF definiert ist
XdefPtr		rs.l 1
XdefSIZE	rs

		rsreset		** struct XREF **
NextXref 	rs.l 1		; nächstes XREF in der Liste
XrefXdef 	rs.l 1		; dazu passendes XDEF
XrefHunk	rs.l 1
XrefPtr		rs.l 1
XrefSIZE 	rs

		rsreset		** struct UserXDEF **
ux_Next		rs.l 1
ux_XdefStruct	rs.l 1		; Zeiger auf struct XDEF
ux_SymLen	rs.l 1		; Länge des zugewiesenen Symbols in Longwords
ux_SymName	rs		; Name des zugewiesenen Symbols (long-alinged)

		rsreset		** struct ALV (Automatic Link Vector) **
alv_Next	rs.l 1
alv_SecNum	rs.l 1		; Ziel-Section
alv_JmpOffset	rs.l 1		; zu erreichende Zieladresse
alv_ALVOffset	rs.l 1		; Offset des ALV in aktueller Section
alvSIZE		rs

MAXNAMELEN	equ SecNameSIZE


		rsreset		; Struktur für Buffered I/O Routinen
bio_sysbase	rs.l 1
bio_dosbase	rs.l 1
bio_fh		rs.l 1
bio_have	rs.l 1
bio_rec_end	rs.l 1
bio_begin	rs.l 1
bio_eof		rs.l 1
bio_bufptr	rs.l 1
bio_bufsize	rs.l 1
bio_buffer	rs



** The Code **


	section	"PhxLnk Code",code

	near	a4,-2			; __MERGED-SmallData


PhxLnk:
	initnear
	move.l	ExecBase.w,a6
	move.l	a6,SysBase(a4)
	move.b	#1,ReturnCode(a4)

;vb:	MemPool initialisieren
	ifd	V39
	move.l	#MEMF_CLEAR,d0
	move.l	#PUDDLESIZE,d1
	move.l	#THRESHSIZE,d2
	jsr	CreatePool(a6)		; SysBase noch in a6
	move.l	d0,Pool(a4)		; Pooladresse speichern
	beq	CleanUp
	else
	pea	THRESHSIZE
	pea	PUDDLESIZE
	pea	MEMF_CLEAR
	jsr	_LibCreatePool
	lea	12(a7),a7
	move.l	d0,Pool(a4)		; Pooladresse speichern
	beq	CleanUp
	endc

	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,a0
	move.l	a0,this_task(a4)
	tst.l	pr_CLI(a0)		; vom CLI gestartet ?
	beq	CleanUp
	lea	DosName(pc),a1
	ifd	V39
	moveq	#39,d0			; dos.library (OS3.x) öffnen
	else
	moveq	#37,d0			; dos.library (OS2.04) öffnen
	endc
	jsr	OpenLibrary(a6)
	move.l	d0,DOSBase(a4)
	beq	CleanUp
	lea	LocaleName(pc),a1
	moveq	#38,d0
	jsr	OpenLibrary(a6)		; locale.library (ab OS2.1) öffnen
	move.l	d0,LocaleBase(a4)	; (wenn's nicht klappt nur englische Texte)
	beq.s	1$
	move.l	d0,a6
	sub.l	a0,a0
	jsr	OpenLocale(a6)		; Zugriff auf Locale-Struktur
	move.l	d0,Locale(a4)
	sub.l	a0,a0
	lea	PhxLnkCatName(pc),a1
	clr.l	-(sp)
	clr.l	-(sp)			; TAG_DONE
	move.l	sp,a2
	jsr	OpenCatalogA(a6)	; PhxLnk-Catalog mit sämtlichen Strings öffnen
	move.l	d0,Catalog(a4)
	addq.l	#8,sp
1$:	move.l	sp,ExitSP(a4)

	move.l	DOSBase(a4),a6		; ** Command Line Parsing **
	lea	CmdTemplate(pc),a0
	move.l	a0,d1
	lea	argv(a4),a2
	move.l	a2,d2
	moveq	#0,d3
	jsr	ReadArgs(a6)		; CommandLine auswerten lassen
	move.l	d0,rdargs(a4)
	bne.s	3$
	jsr	IoErr(a6)		; Fehler: Grund herausfinden und ausgeben
	move.l	d0,d1
	moveq	#0,d2
	jsr	PrintFault(a6)
2$:	bra	Instructions
3$:	move.l	(a2)+,d0		; Wenigstens ein FROM/M-Parameter 
	beq.s	2$			;  vorhanden?
	move.l	d0,a5			; a5 = FROM/M-Array aller Link-Files
	move.l	(a2)+,OutName(a4)	; TO ?
	tst.l	(a2)+			; SMALLCODE ?
	sne	SmallCode(a4)
	tst.l	(a2)+			; SMALLDATA ?
	sne	SmallData(a4)
	tst.l	(a2)+			; NODEBUG ?
	sne	NoDebug(a4)
	tst.l	(a2)+			; PVCOMPAT ?
	sne	PVcompat(a4)
	tst.l	(a2)+			; CHIP ?
	sne	HunksToChip(a4)
	tst.l	(a2)+			; PRESERVE ?
	seq	RemEmpty(a4)
	tst.l	(a2)+			; BLINKCOMPAT ?
	sne	BLinkCompat(a4)
	tst.l	(a2)+			; KICK1 ?
	beq.s	32$
	st	NoShortRelocs(a4)
	st	NoShortenSects(a4)
32$:	move.l	(a2)+,d0		; MAXSECTS ?
	beq.s	30$
	move.l	d0,a0
	move.l	(a0),d0
	move.w	d0,HunksPerUnit(a4)
	subq.w	#3,d0
	bhs.s	30$
	LOCS	5			; Maximum of 3 sect. required
	bsr	printf
	bra.s	CleanUp
30$:	move.l	(a2)+,d0		; BUFSIZE ?
	beq.s	31$
	move.l	d0,a0
	move.l	(a0),d0
	beq.s	31$			; 0? Guter Witz...
	move.l	d0,bioBufSize(a4)
31$:	move.l	(a2)+,d0		; HASHTAB ?
	beq.s	4$
	move.l	d0,a0
	moveq	#0,d0
	move.b	3(a0),d1
	cmp.b	#8,d1			; HashTable zwischen 2^8 und 2^16?
	blo.s	4$			;  sonst gilt Default-Wert
	cmp.b	#16,d1
	bhi.s	4$
	bset	d1,d0
	move.l	d0,HashTabSize(a4)
4$:	move.l	SysBase(a4),a6		; XDEF-HashTable initialisieren
	move.l	HashTabSize(a4),d0
	move.l	d0,d1
	subq.l	#1,d1
	move.w	d1,HashTabMask(a4)
	lsl.l	#2,d0
	bsr	mAlloc_Clear
	move.l	d0,XDEFHashTab(a4)
	beq	OutOfMemory
	tst.l	(a2)+			; NOSHORTRELOCS
	beq.s	41$
	st	NoShortRelocs(a4)
41$:	tst.l	(a2)+			; DONTSHORTENSECT
	beq.s	42$
	st	NoShortenSects(a4)

42$:	add.w	#5*4,a2			; BATCH,ADDSYM,NOALV,NOICONS,LIB ignorieren
	tst.l	(a2)+			; ALV ?
	sne	GenALVs(a4)

	move.l	(a2)+,d0		; DEFINE ?
	beq	20$
	move.l	d0,a3

8$:	moveq	#EXT_ABS,d7		; d7 XDEF-Typ des Defines
	pea	1.w			; Symbolwert mit 1 vorbelegen
	move.l	a3,a0
	moveq	#'=',d2			; 'symbol=n' oder nur 'symbol' akzeptieren
	moveq	#',',d3
5$:	move.b	(a0)+,d1
	beq.s	6$
	cmp.b	d3,d1
	beq.s	6$
	cmp.b	d2,d1
	bne.s	5$			; '=' entdeckt?
	move.l	a0,d1
	move.l	sp,d2
	move.l	a0,-(sp)
	move.l	DOSBase(a4),a6
	jsr	StrToLong(a6)		; Ascii-Zahl in Long-Integer umwandeln
	move.l	(sp)+,a0
	ifd	V39
	tst.l	d0
	bpl.s	6$			; war eine gültige Zahl?
	else
	subq.l	#1,d0			; OS2-Test auf gültige Zahl
	bmi.s	50$
	move.b	(a0,d0),d0
	cmp.b	#'0',d0
	blo.s	50$
	cmp.b	#'9',d0
	bls.s	6$			; ok, war eine gültige Zahl
50$:
	endc
	moveq	#EXT_DEF,d7		; keine Zahl, dann Symboldefinition

6$:	; a3=Symolanfang,a0=Symbolende,(sp)=Symbolwert
	subq.l	#1,a0
	move.l	a0,d6			; d6=Zeiger auf 0-Byte, ',' oder '='
	move.l	a0,d2
	sub.l	a3,d2			; Länge des Symbols ohne das 0-Byte
	beq	19$			; 0?
	move.w	d2,d4			; d4  "
	moveq	#3,d0
	add.l	d0,d2
	not.l	d0
	and.l	d0,d2			; Länge auf Longword ausrichten
	moveq	#8,d0
	add.l	d2,d0
	move.l	SysBase(a4),a6
	bsr	mAlloc_Clear		; Speicher für XDEF-Eintrag besorgen
	move.l	d0,d3
	beq	OutOfMemory
	exg	d3,a2
	move.l	d2,d1
	lsr.l	#2,d1			; Symbollänge in Longwords
	move.l	d7,d0			; Symboltyp (EXT_DEF oder EXT_ABS)
	ror.l	#8,d0
	or.l	d1,d0			; XDEF ($0x000len) speichern
	move.l	a2,a0
	move.l	d0,(a0)+
	subq.w	#1,d4
7$:	move.b	(a3)+,(a0)+		; Symbolnamen
	dbf	d4,7$
	move.l	(sp)+,4(a2,d2.l)	; und Symbolwert speichern
	lea	LinkerUnit(a4),a0
	move.l	a0,d4
	move.l	d4,d5
	bsr	AddXDEF			; User-Symbol in XDEF-Liste aufnehmen
	exg	d3,a2
	subq.b	#EXT_DEF,d7		; war es ein relocatibles EXT_DEF?
	bne.s	70$
	move.l	d0,d7			; d7 struct XDEF
	lea	RelDefList(a4),a3
	bra.s	72$
71$:	move.l	d0,a3			; neue struct UserXDEF erzeugen
72$:	move.l	ux_Next(a3),d0
	bne.s	71$
	addq.l	#1,d6
	move.l	d6,a0
73$:	move.b	(a0)+,d0		; Länge des zugew. Symbols bestimmen
	beq.s	74$
	cmp.b	#',',d0
	bne.s	73$
74$:	move.l	a0,d1
	subq.l	#1,d1
	sub.l	d6,d1			; Länge 0?
	beq	79$
	move.l	d1,d4
	addq.l	#3,d1			; Länge auf Longword ausrichten
	lsr.l	#2,d1
	move.l	d1,d5			; d5 Länge in Longwords
	lsl.l	#2,d1
	moveq	#ux_SymName,d0
	add.l	d1,d0
	bsr	mAlloc_Clear		; Speicher für struct UserXDEF
	move.l	d0,ux_Next(a3)
	beq	OutOfMemory
	move.l	d0,a3
	move.l	d7,ux_XdefStruct(a3)	; Zeiger auf struct XDEF merken
	move.l	d5,ux_SymLen(a3)	; Länge in Longwords merken
	move.l	d6,a0
	lea	ux_SymName(a3),a1
	move.l	d4,d0
	jsr	CopyMem(a6)		; zugewiesenes Symbol kopieren
79$:	subq.l	#1,d6
70$:	move.l	d6,a3
	move.b	(a3)+,d0
	moveq	#',',d1
	cmp.b	d1,d0			; noch eine Definition?
	beq	8$
	cmp.b	#'=',d0
	bne.s	20$
9$:	move.b	(a3)+,d0
	beq.s	20$
	cmp.b	d1,d0
	bne.s	9$
	bra	8$

19$:	addq.l	#4,sp
20$:	move.l	SysBase(a4),a6
	moveq	#0,d0
	move.w	HunksPerUnit(a4),d0
	lsl.l	#3,d0
	bsr	mAlloc			; Speicher für UnitInfo-Table
	move.l	d0,UnitInfo(a4)
	beq	OutOfMemory
	bsr	Linker			; Linker-Hauptprogramm starten
	clr.b	ReturnCode(a4)		; kein Fehler

CleanUp:
	move.l	SysBase(a4),a6
	move.l	rdargs(a4),d1
	beq.s	5$
	move.l	a6,a5
	move.l	DOSBase(a4),a6
	jsr	FreeArgs(a6)		; ReadArgs()-Parameter freigeben
	move.l	a5,a6
5$:	move.l	LocaleBase(a4),d7	; locale.library schließen (falls vorhanden)
	beq.s	2$
	exg	d7,a6
	move.l	Catalog(a4),d0		; Catalog schließen
	beq.s	4$
	move.l	d0,a0
	jsr	CloseCatalog(a6)
4$:	move.l	Locale(a4),d0		; Zugriff auf Locale-Struktur beenden
	beq.s	3$
	move.l	d0,a0
	jsr	CloseLocale(a6)
3$:	move.l	a6,a1
	move.l	d7,a6
	jsr	CloseLibrary(a6)
2$:	move.l	DOSBase(a4),d0
	beq.s	1$
	move.l	d0,a1
	jsr	CloseLibrary(a6)
1$:
;vb:	Pool freigeben
	ifd	V39
	move.l	Pool(a4),d0
	beq.s	nopool			; sollte man hier ein n$ nehmen?
	move.l	d0,a0
	jsr	DeletePool(a6)		; SysBase noch in a6, denke ich
nopool:
	else
	move.l	Pool(a4),d0
	beq.s	nopool			; sollte man hier ein n$ nehmen?
	move.l	d0,-(a7)
	jsr	_LibDeletePool
	addq.w	#4,a7
nopool:
	endc

	moveq	#0,d0
	move.b	ReturnCode(a4),d0
	rts

	REVSTRING
DosName:
	dc.b	"dos.library",0
LocaleName:
	dc.b	"locale.library",0
PhxLnkCatName:
	dc.b	"PhxLnk.catalog",0

CmdTemplate:
	dc.b	"FROM/M,TO/K,SC=SMALLCODE/S,SD=SMALLDATA/S,ND=NODEBUG/S,"
	dc.b	"PV=PVCOMPAT/S,CHIP/S,PRESERVE/S,B=BLINKCOMPAT/S,K1=KICK1/S,"
	dc.b	"MAXSECTS/K/N,BUFSIZE/K/N,HT=HASHTAB/K/N,"
	dc.b	"NOSHORTRELOCS/S,DONTSHORTENSECT/S,BATCH/S,ADDSYM/S,"
	dc.b	"NOALVS/S,NOICONS/S,LIB/S,ALV/S,DEF=DEFINE/K"
NTEMPLATES 	= 22
	even


Instructions:
	LOCS	0			; Instruction-String
	move.w	#DEF_SECPERUNIT,-(sp)
	move.w	#REVISION,-(sp)
	move.w	#VERSION,-(sp)
	move.l	sp,a1
	bsr.s	printf			; Anleitung ausgeben
	bra	exit


printf:
; Text auf StdOut formatiert ausgeben
; a0 = FormatString
; a1 = DataStream
	movem.l	d2-d3/a6,-(sp)
	move.l	DOSBase(a4),a6
	move.l	a0,d1
	move.l	a1,d2
	jsr	VPrintf(a6)		; OS2 Printf to stdout
	move.l	this_task(a4),a0
	btst	#SIGBREAKB_CTRL_C-8,tc_SigRecvd+2(a0) ; Control-C gedrückt ?
	beq.s	1$
	lea	break_txt(pc),a0	; ***Break
	move.l	a0,d1
	jsr	VPrintf(a6)
	bra	exit
1$:	movem.l	(sp)+,d2-d3/a6
	rts


ObjFileNotFound:
	LOCS	12
	bra.s	Error

LibFileNotFound:
	LOCS	13

Error:
; a0 = ErrorString
	move.l	ObjName(a4),-(sp)
	move.l	sp,a1
	bsr	printf
	bra	exit


	cnop	0,4
ReadUnits:
; a5 = Zeiger auf ein mit NULL terminiertes Feld von ObjectName-Zeigern
	movem.l	a5-a6,-(sp)
rdunitsLoop:
	move.l	(a5)+,d0
	beq	5$			; kein ObjName mehr da?
	move.l	d0,a0
	cmp.b	#'@',(a0)		; Name einer ObjectName-Datei?
	beq	getObjNameFile
	bsr	CheckExtension		; ObjName setzen und .o /.lib prüfen
	move.w	d0,d5			; d5 = -1(Library), 0(Object)
	move.l	ObjName(a4),d1
	tst.l	OutName(a4)		; schon gesetzt ?
	bne.s	1$
	move.l	d1,a0
	lea	NameBuffer(a4),a1
	moveq	#'.',d3
	move.w	#MAXNAMELEN-2,d0	; OutName auf 1. ObjectName ohne '.o' setzen
	move.l	a1,a2
	sub.l	a3,a3
2$:	move.b	(a0)+,d2
	cmp.b	d3,d2
	bne.s	6$
	move.l	a1,a3
6$:	move.b	d2,(a1)+
	dbeq	d0,2$
	clr.b	-(a1)
	move.l	a3,d0
	beq.s	7$
	clr.b	(a3)			; mögliche Extension abschneiden
7$:	move.l	a2,OutName(a4)
1$:	bsr	AddObject		; Object File lesen und in Liste einhängen
	lea	8(a0),a3		; Object File BaseAddr.
	cmp.l	#HUNK_LIB,(a3)		; Spezielles SAS/C Library-Format?
	bne.s	3$
	bsr	TranslateLibrary	; Library in normales Unit-Format übersetzen
	moveq	#-1,d5
	lea	8(a0),a3
3$:	cmp.l	#HUNK_UNIT,(a3)+
	beq.s	4$
	LOCS	15			; Missing Hunk_Unit
	bra	Error
5$:	movem.l	(sp)+,a5-a6
	rts
4$:	bsr	GetUnit			; Neue Unit-Struktur
	move.l	a0,ActiveUnit(a4)
	move.b	d5,LibUnit(a4)		; Unit gehört zu einer Library?
	seq	U_Select(a0)		; .o - Units werden immer eingebunden
	move.l	ObjName(a4),U_ObjName(a0)
	move.l	(a3)+,d0		; Länge des Unit-Namen
	lea	U_NameBuffer(a0),a0
	move.l	a3,a1
	bsr	GetName
	move.l	a1,a3
	move.l	a3,a0
	bsr	AddUnit			; Alle Hunks dieser Unit einlesen
	move.l	a0,a3
	tst.w	d0
	bne.s	3$			; noch eine Unit im File ?
	bra	rdunitsLoop		; nächstes Object

getObjNameFile:
	move.l	DOSBase(a4),a6
	addq.l	#1,a0
	move.l	a0,d5
	move.l	d5,d1
	move.l	#MODE_OLDFILE,d2
	jsr	Open(a6)		; ObjectName-Datei einlesen
	move.l	d0,d4
	bne.s	1$
	move.l	d5,a0
	bra	ObjFileNotFound
1$:	move.l	d4,d1			; Größe des Files bestimmen
	moveq	#0,d2
	moveq	#OFFSET_END,d3
	jsr	Seek(a6)
	move.l	d4,d1
	tst.l	d0
	bmi	ReadErr
	moveq	#0,d2
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	move.l	d4,d1
	tst.l	d0
	bmi	ReadErr
	move.l	SysBase(a4),a6
	addq.l	#1,d0
	move.l	d0,d5
	bsr	mAlloc			; Speicher besorgen
	tst.l	d0
	beq	OutOfMemory
	move.l	d0,a2
	move.l	DOSBase(a4),a6
	move.l	d4,d1
	move.l	a2,d2
	move.l	d5,d3
	jsr	Read(a6)		; ObjectName-Datei lesen
	tst.l	d0
	bpl.s	2$			; Read Error?
	move.l	d4,d1
	bra	ReadErr
2$:	move.l	d4,d1
	jsr	Close(a6)
	clr.b	-1(a2,d5.l)
	move.l	sp,d2
	moveq	#'"',d0
	moveq	#' ',d1
	move.l	a2,a0
	lea	-4*MAXOFNAMES(sp),a2
3$:	subq.l	#1,d5
	beq.s	10$
	cmp.b	(a0)+,d1
	bhs.s	3$
	subq.l	#1,a0
	cmp.b	(a0)+,d0		; File Name ist in ".."
	beq.s	5$
	subq.l	#1,a0
	addq.l	#1,d5
	move.l	a0,-(sp)
4$:	subq.l	#1,d5
	beq.s	10$
	cmp.b	(a0)+,d1
	blo.s	4$
	bra.s	7$
5$:	move.l	a0,-(sp)
6$:	subq.l	#1,d5
	beq.s	10$
	cmp.b	(a0)+,d0
	bne.s	6$
7$:	clr.b	-1(a0)			; File Name abschließen
	cmp.l	a2,sp			; zu viele Namen gefunden?
	bhi.s	3$
10$:	move.l	SysBase(a4),a6
	move.l	d2,d0
	sub.l	sp,d0			; Speicher für ObjectName-Array
	move.l	d0,d3
	addq.l	#4,d0
	bsr	mAlloc
	tst.l	d0
	beq	OutOfMemory
	move.l	d0,a3
	move.l	d2,a0
	move.l	a3,a1
	lsr.l	#2,d3
	subq.w	#1,d3
12$:	move.l	-(a0),(a1)+		; Pointer ins Array kopieren
	dbf	d3,12$
	clr.l	(a1)
	move.l	d2,sp			; Stack freigeben
	movem.l	a2-a3/a5,-(sp)
	move.l	a3,a5
	bsr	ReadUnits		; Alle Units der ObjectName Datei lesen
	movem.l	(sp)+,a2-a3/a5
	bra	rdunitsLoop


Linker:
; Linker Hauptprogramm
; a5 = Zeiger auf ein mit NULL terminiertes Feld von ObjectName-Zeigern

	bsr	AddLinkerXDEF		; Linker-XDEFs erzeugen
	bsr	ReadUnits		; alle Units der Objects und Libs einlesen
	bsr	SearchUserXDEFs		; struct UserXDEF auflösen

	bsr	SelectUnits		; Bestimme, welche Units dazugelinkt werden
	bsr	KillUnselected		; Die nicht benötigten rausschmeißen
	bsr	KillZeroSecs		; Sections mit Länge 0 löschen
	bsr	CalcHunkOffsets		; BaseOffsets innerhalb der Sections best.
	bsr	SetLnkXDEF		; Werte der Linker-XDEFs setzen
	bsr	Correction		; Offsets der dazugelinkten Hunks korrigieren
	bsr	AlignSecLengths		; Längen auf Longword ausrichten

	move.l	DOSBase(a4),a6		; Load File schreiben
	move.w	IDCnt(a4),d7
	beq	finished
	move.l	OutName(a4),d1
	move.l	#MODE_NEWFILE,d2
	jsr	Open(a6)		; zum schreiben öffnen
	move.l	d0,d2
	beq.s	18$
	move.l	bioBufSize(a4),d1
	bsr	bio_buf
	move.l	d0,d6
	bne.s	10$
	move.l	d2,d1
	jsr	Close(a6)
18$:	LOCS	16
	bsr	printf
	bra	exit
10$:	moveq	#0,d4
	subq.w	#1,d7
	move.b	SmallData(a4),d5
	move.l	#HUNKF_CHIP|HUNKF_FAST,d3
11$:	lea	CodeSections(a4),a0
	bsr	SearchSection
	bne	13$
	tst.b	d5
	beq.s	12$
	moveq	#0,d1
	move.l	BssSections(a4),d0	; SmallData: Size = DataSize+BSSSize
	beq.s	110$
	move.l	d0,a0
	move.l	SecSize(a0),d0
	move.l	Type(a0),d1
	and.l	d3,d1
110$:	move.l	DataSections(a4),d2
	beq.s	16$
	move.l	d2,a0
	add.l	SecSize(a0),d0
	or.l	d1,Type(a0)
	bra.s	16$
12$:	lea	DataSections(a4),a0
	bsr	SearchSection
	beq.s	17$
	cmp.l	mergedData(a4),a0	; __MERGED Size = mergedData + mergedBss
	bne.s	13$
	move.l	mergedBss(a4),d1
	beq.s	13$
	move.l	SecSize(a0),d0
	move.l	d1,a0
	add.l	SecSize(a0),d0
	bra.s	16$
17$:	lea	BssSections(a4),a0
	bsr	SearchSection
13$:	move.l	SecSize(a0),d0
16$:	lsr.l	#2,d0			; Größe der Section in Longwords
	tst.b	HunksToChip(a4)		; Alle Sections ins Chip-RAM ?
	beq.s	14$
	or.l	#HUNKF_CHIP,d0
	bra.s	15$
14$:	move.l	Type(a0),d1
	and.l	d3,d1
	or.l	d1,d0			; Mem-Flags mit dazu nehmen
15$:	move.l	d0,-(sp)
	addq.l	#4,d4
	dbf	d7,11$
	moveq	#0,d0
	move.w	IDCnt(a4),d0		; Anzahl Sections
	move.l	d0,d1
	subq.w	#1,d0
	move.l	d0,-(sp)		; Nummer der letzten Section
	clr.l	-(sp)			; Nummer der ersten Section
	addq.l	#8,d4
	move.l	d1,-(sp)		; Anzahl der Sections
	addq.l	#4,d4
	clr.l	-(sp)
	move.l	#HUNK_HEADER,-(sp)	; HUNK_HEADER
	addq.l	#8,d4
	move.l	sp,d2
	move.l	d4,d3
	bsr	WriteData		; Header schreiben
	add.l	d4,sp

	moveq	#0,d7			; Alle Sections von 0-Letzte speichern
20$:	lea	CodeSections(a4),a0
	bsr	SearchSection
	bne.s	22$
	tst.b	d5
	beq.s	21$
	move.l	DataSections(a4),a0	; Bei SmallData nur die Data-Section speichern
	move.l	a0,d0
	bne.s	22$
	move.l	BssSections(a4),a0
	bra.s	22$
21$:	lea	DataSections(a4),a0
	bsr	SearchSection
	bne.s	22$
	lea	BssSections(a4),a0
	bsr	SearchSection
	beq	27$
22$:	move.l	a0,a5			; Section
	bsr	ShortenSection		; 0-Bytes am Section-Ende ignorieren (ab OS2.0)
	lsr.l	#2,d0
	move.l	d0,-(sp)
	moveq	#0,d0
	move.w	Type+2(a5),d0
	move.l	d0,-(sp)
	move.l	sp,d2
	moveq	#8,d3
	bsr	WriteData		; Hunk-Type und Länge schreiben
	addq.l	#8,sp
	cmp.w	#HUNK_BSS,Type+2(a5)
	beq.s	23$
	move.l	HunkList(a5),d0
	bsr	WriteHunkData		; Inhalt aller Hunks schreiben -> d2 = TotSize
	bsr	SearchRelocs
	bne.s	23$			; Relocs überhaupt vorhanden ?
	tst.b	NoShortRelocs(a4)
	bne.s	26$
	swap	d2
	tst.w	d2			; Ab OS2.0 bei Hunksize <= 64kB
	bne.s	26$			; HUNK_RELOC32SHORT (mit 16-bit Offsets) verw.
	move.l	#HUNK_RELOC32SHRT,-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData
	addq.l	#4,sp
	bsr	WriteReloc32Short	; Reloc32Short Hunk Blocks schreiben
	bra.s	23$
26$:	move.l	#HUNK_RELOC32,-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData
	addq.l	#4,sp
	bsr	WriteReloc32		; Reloc32 Hunk Blocks schreiben
23$:	tst.b	NoDebug(a4)
	bne.s	25$
	bsr	SearchSymbols
	bne.s	24$			; keine Symbol Hunks Blocks?
	move.l	#HUNK_SYMBOL,-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData
	addq.l	#4,sp
	move.l	HunkList(a5),d0
	bsr	WriteSymbol		; Symbol Hunk Blocks schreiben
24$:	bsr	WriteDebug		; Debugger Hunk Blocks schreiben (falls vorh.)
25$:	move.l	#HUNK_END,-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData		; Hunk-Ende
	addq.l	#4,sp
27$:	addq.w	#1,d7
	cmp.w	IDCnt(a4),d7
	bne	20$			; nächster Hunk

	move.l	d6,a1
	bsr	bio_close		; Load File schließen
finished:
	rts


	cnop	0,4
AddObject:
; Größe des Objectfiles bestimmen, Speicher beschaffen, File einlesen und
; an die Liste anhängen
; d1 = FileName
; -> a0 = ObjectFileHead (0:Next, 4:Size, 8:ObjectFile... , x:'PHX!')
	movem.l	d2-d5/a6,-(sp)
	move.l	DOSBase(a4),a6
	move.l	#MODE_OLDFILE,d2
	jsr	Open(a6)		; Object-File öffnen
	move.l	d0,d4			; d4 = FileHandle
	bne.s	1$
	move.l	ObjName(a4),a0
	bra	ObjFileNotFound
1$:	move.l	d4,d1			; Größe des Files bestimmen
	moveq	#0,d2
	moveq	#OFFSET_END,d3
	jsr	Seek(a6)
	move.l	d4,d1
	tst.l	d0
	bmi	ReadErr
	moveq	#0,d2
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	move.l	d4,d1
	move.l	d0,d5
	bmi	ReadErr
	move.l	SysBase(a4),a6
	addq.l	#8,d5
	addq.l	#4,d5			; Speicher besorgen
	move.l	d5,d0
	bsr	mAlloc
	tst.l	d0
	beq	OutOfMemory
	move.l	d0,a1
	clr.l	(a1)			; Letzter Block
	move.l	d5,4(a1)		; Größe des Blocks merken
	move.l	#'PHX!',-4(a1,d5.l)	; Endmarkierung des Object-Files
	lea	Objects(a4),a0
2$:	move.l	(a0),d0
	beq.s	3$
	move.l	d0,a0
	bra.s	2$
3$:	move.l	a1,(a0)			; an Object-Liste anhaengen
	move.l	a1,d5
	move.l	DOSBase(a4),a6
	move.l	d4,d1
	move.l	a1,d2
	addq.l	#8,d2
	move.l	4(a1),d3
	subq.l	#8,d3
	subq.l	#4,d3
	jsr	Read(a6)		; Object File lesen
	move.l	d4,d1
	tst.l	d0
	bmi	ReadErr
	jsr	Close(a6)
	move.l	d5,a0			; Zeiger auf ObjectFile-Head übergeben
	movem.l	(sp)+,d2-d5/a6
	rts


ReadErr:
	jsr	Close(a6)
	LOCS	40			; Read error
	bra	Error


	cnop	0,4
TranslateLibrary:
; HUNK_LIB-Library aus der Object-Liste wieder entfernen, in normales Unit-
; Format umwandeln und in die Object-Liste einhängen. Das HUNK_LIB-File wird
; danach vollständig aus dem Speicher entfernt.
; a0 = Zeiger auf Library Module Header
; -> a0 = Normale Unit-Library
	movem.l	a2-a3/a5-a6/d2-d7,-(sp)
	move.l	a0,a2			; a2 Anfang des Module Header merken
	lea	12(a2),a0
	moveq	#0,d7
1$:					; ** Benötigten Speicher für die Library
	move.l	(a0)+,d0		;    nach der Umwandlung ausrechnen **
	move.l	a0,a3			; a3 HUNK_LIB block
	lsl.l	#2,d0
	add.l	d0,a0
	cmp.l	#HUNK_INDEX,(a0)+
	beq.s	2$
	LOCS	20
	bra	Error
2$:	move.l	(a0)+,d2
	lsl.l	#2,d2			; Länge von HUNK_INDEX
	moveq	#0,d0
	move.w	(a0)+,d0
	subq.l	#2,d2
	move.l	a0,a6			; a6 String block
	add.l	d0,a0			; String Block überspringen
	sub.l	d0,d2
3$:	moveq	#6,d0
	cmp.l	d0,d2			; noch ein index unit block ?
	blo	8$
	addq.l	#8,d7			; Speicherbedarf für HUNK_UNIT
	sub.l	d0,d2
	move.w	(a0)+,d0
	bsr	libstrlen
	add.l	d0,d7
	moveq	#0,d0
	move.w	(a0)+,d0		; longword offset in HUNK_LIB
	lsl.l	#2,d0
	lea	(a3,d0.l),a5		; a5 first unit hunk
	move.w	(a0)+,d3		; d3 NumHunks in this unit
	bra	7$
4$:	move.w	(a0),d0
	bsr	libstrlen		; Länge des Hunk-Namens bestimmen
	tst.l	d0
	beq.s	5$			; kein Name?
	addq.l	#8,d0
	add.l	d0,d7			; Speicherbedarf für HUNK_NAME
5$:	moveq	#6,d0
	add.l	d0,a0
	sub.l	d0,d2
	bsr	libHunkSize		; Größe des Hunks (a5) mit Relocs und XRefs
	add.l	d0,d7
	subq.l	#4,d2
	moveq	#0,d0
	move.w	(a0)+,d0		; number of xrefs
	add.l	d0,d0
	sub.l	d0,d2
	add.l	d0,a0
	move.w	(a0)+,d4		; number of xdefs
	beq.s	7$
	subq.w	#1,d4
	tst.b	d1			; HUNK_EXT schon vorhanden?
	bne.s	6$
	addq.l	#8,d7			; 8 Bytes für HUNK_EXT und abschließende 0
6$:	subq.l	#6,d2
	move.w	(a0),d0			; symbol name
	bsr	libstrlen
	add.l	d0,d7
	addq.l	#8,d7
	addq.l	#6,a0
	dbf	d4,6$
7$:	dbf	d3,4$			; next Hunk
	bra	3$			; next Unit
8$:	add.l	d2,a0
9$:	move.l	(a0)+,d0
	cmp.l	#'PHX!',d0		; End of File?
	beq	generateUnits
	cmp.w	#HUNK_LIB,d0		; noch ein Library-Block?
	beq	1$
	cmp.w	#HUNK_UNIT,d0		; oder zur Abwechselung mal 'ne normale Unit?
	beq.s	10$
	LOCS	15			; illegaler Hunk-Block
	bra	Error
10$:	move.l	a0,a5
	subq.l	#4,a0			; Anfang in a0 merken
	move.l	(a5)+,d0
	lsl.l	#2,d0
	add.l	d0,a5			; Unit-Name überspringen
11$:	cmp.l	#HUNK_NAME,(a5)
	bne.s	12$			; kein Name?
	move.l	4(a5),d0
	lsl.l	#2,d0
	lea	8(a5,d0.l),a5
12$:	bsr	libHunkSize		; Hunk vollständig überspringen
	move.l	a5,d0
	sub.l	a0,d0
	add.l	d0,d7			; Speicherbedarf des Hunks
	move.l	a5,a0
	move.l	(a0),d0
	cmp.w	#HUNK_LIB,d0
	beq.s	9$
	cmp.w	#HUNK_UNIT,d0
	beq.s	9$
	cmp.l	#'PHX!',d0
	bne.s	11$

generateUnits:
; a2 Object Module, d7 Speicherbedarf für Units
	move.l	SysBase(a4),a6
	moveq	#12,d0			; 12 Bytes für Module-Header + Endmarkierung
	add.l	d0,d7
	move.l	d7,d0
	bsr	mAlloc
	move.l	d0,-(sp)
	beq	OutOfMemory
	move.l	a2,-(sp)
	lea	12(a2),a0
	move.l	d0,a2
	clr.l	(a2)+
	move.l	d7,(a2)+
1$:	move.l	(a0)+,d0
	move.l	a0,a3			; a3 HUNK_LIB block
	lsl.l	#2,d0
	lea	4(a0,d0.l),a0
	move.l	(a0)+,d2
	lsl.l	#2,d2			; d2 Länge von HUNK_INDEX
	moveq	#0,d0
	move.w	(a0)+,d0
	subq.l	#2,d2
	move.l	a0,a6			; a6 String block
	add.l	d0,a0			; String Block überspringen
	sub.l	d0,d2
2$:	moveq	#6,d0
	cmp.l	d0,d2			; noch ein index unit block ?
	blo	15$
	sub.l	d0,d2
	move.w	(a0)+,d0
	move.l	#HUNK_UNIT,d1
	bsr	libHunkName
	moveq	#0,d0
	move.w	(a0)+,d0		; longword offset in HUNK_LIB
	lsl.l	#2,d0
	lea	(a3,d0.l),a5		; a5 first unit hunk
	move.w	(a0)+,d3		; d3 NumHunks in this unit
	bra	14$
3$:	move.w	(a0),d0
	beq.s	4$
	move.l	#HUNK_NAME,d1
	bsr	libHunkName
4$:	moveq	#6,d0
	add.l	d0,a0
	sub.l	d0,d2
	move.l	a5,d4
	bsr	libHunkSize		; Länge des aktuellen Hunks ermitteln
	move.l	d4,a1
	lsr.l	#2,d0
	subq.l	#1,d0			; HUNK_END noch nicht mitkopieren
5$:	move.l	(a1)+,(a2)+		; Hunk mit Relocs und XRefs kopieren
	subq.l	#1,d0
	bne.s	5$
	subq.l	#4,d2
	moveq	#0,d0
	move.w	(a0)+,d0		; number of xrefs
	add.l	d0,d0
	sub.l	d0,d2
	add.l	d0,a0
	move.w	(a0)+,d4		; number of xdefs
	beq	13$
	subq.w	#1,d4
	subq.l	#4,a2
	tst.b	d1			; HUNK_EXT schon vorhanden?
	bne.s	6$
	addq.l	#4,a2
	move.l	#HUNK_EXT,(a2)+
6$:	move.l	a2,d6
	addq.l	#4,a2
	subq.l	#6,d2
	moveq	#0,d0
	move.w	(a0)+,d0
	lea	(a6,d0.l),a1		; Symbol Name
	moveq	#0,d5
	move.w	(a0)+,d5		; value0-15(EXT_ABS) oder offset(EXT_DEF)
	move.w	(a0)+,d0
	moveq	#1,d1
	btst	#0,d0			; EXT_DEF? ($01)
	bne.s	8$
	moveq	#2,d1			; EXT_ABS
	swap	d5
	btst	#6,d0			; ABS Vorzeichen
	beq.s	7$
	move.w	#$ff00,d5
7$:	lsr.w	#8,d0
	move.b	d0,d5			; Bits 16-23 aus Symbol Type holen
	swap	d5
8$:	ror.l	#8,d1
	bra.s	10$
9$:	move.b	d0,(a2)+
	addq.w	#1,d1
10$:	move.b	(a1)+,d0
	bne.s	9$
	moveq	#3,d0
	add.w	d0,d1
	and.w	d1,d0
	eor.w	#3,d0
	bra.s	12$
11$:	clr.b	(a2)+			; auf nächstes Longword ausrichten
12$:	dbf	d0,11$
	lsr.w	#2,d1
	move.l	d6,a1
	move.l	d1,(a1)			; Symbol Type und Länge in Longwords speichern
	move.l	d5,(a2)+		; Symbol value
	dbf	d4,6$
	clr.l	(a2)+			; HUNK_EXT abschließen
13$:	move.l	#HUNK_END,(a2)+
14$:	dbf	d3,3$			; next Hunk
	bra	2$			; next Unit
15$:	add.l	d2,a0
16$:	move.l	(a0)+,d0
	cmp.l	#'PHX!',d0		; End of File?
	beq.s	20$
	cmp.w	#HUNK_LIB,d0		; noch ein Library-Block?
	beq	1$
	move.l	a0,a5			; Normale Unit übernehmen
	subq.l	#4,a0
	move.l	(a5)+,d0
	lsl.l	#2,d0
	add.l	d0,a5			; Unit-Name überspringen
17$:	cmp.l	#HUNK_NAME,(a5)
	bne.s	18$			; kein Name?
	move.l	4(a5),d0
	lsl.l	#2,d0
	lea	8(a5,d0.l),a5
18$:	bsr	libHunkSize		; Größe bestimmen,
19$:	;  dann Hunk kopieren
	move.l	(a0)+,(a2)+
	cmp.l	a5,a0
	bne.s	19$
	move.l	(a0),d0
	cmp.w	#HUNK_LIB,d0
	beq.s	16$
	cmp.w	#HUNK_UNIT,d0
	beq.s	16$
	cmp.l	#'PHX!',d0
	bne.s	17$
20$:	move.l	d0,(a2)			; Module-Endmarkierung setzen
	move.l	(sp)+,a1
	lea	Objects(a4),a0
	move.l	a0,d0
21$:	move.l	d0,a0
	move.l	(a0),d0
	cmp.l	a1,d0
	bne.s	21$
	move.l	(sp)+,a2
	move.l	a2,(a0)			; Module gegen neu erstelltes austauschen
	move.l	a2,a0
	movem.l	(sp)+,a2-a3/a5-a6/d2-d7
	rts


	cnop	0,4
libstrlen:
; d0 = string block offset
; a6 = string block
; -> d0 = strlen auf longword aufgerundet
; uses: d0-d1/a1
	moveq	#0,d1
	move.w	d0,d1
	lea	(a6,d1.l),a1
	moveq	#-4,d0
1$:	tst.b	(a1)+
	dbeq	d0,1$
	not.l	d0
	and.b	#$fc,d0
	rts


	cnop	0,4
libHunkName:
; d0 = string block offset
; d1 = Hunk Block Type (HUNK_UNIT, HUNK_NAME, ...)
; a2 = current HunkPtr
; a6 = string block
; -> a2 = new HunkPtr
; a0 wird gerettet!
	move.l	a0,-(sp)
	move.l	d1,(a2)+
	move.l	a2,a1
	addq.l	#4,a2
	moveq	#0,d1
	move.w	d0,d1
	lea	(a6,d1.l),a0
	moveq	#3,d1
	bra.s	2$
1$:	move.b	d0,(a2)+		; Name aus dem Str. Blk herauskopieren
	addq.l	#1,d1
2$:	move.b	(a0)+,d0
	bne.s	1$
	moveq	#3,d0
	and.w	d1,d0
	eor.w	#3,d0
	bra.s	4$
3$:	clr.b	(a2)+			; Name auf nächstes Longw. ausrichten
4$:	dbf	d0,3$
	lsr.l	#2,d1
	move.l	d1,(a1)			; Länge in Longwords
	move.l	(sp)+,a0
	rts


	cnop	0,4
libHunkSize:
; a5 = HunkPtr (HUNK_CODE, _DATA oder _BSS)
; -> d0 = Speicherbedarf des Hunks ab (a5) mit XRefs und Relocs
; -> d1 = !0 (HUNK_EXT im Hunk schon vorhanden)
; -> a5 = HunkPtr auf nächstem Hunk
; a0 wird nicht verändert
	sub.l	a1,a1			; a1 Flag für HUNK_EXT gefunden
	move.l	#$ffffff,d1		; d1 Maske für HUNK_EXT
	move.l	a5,-(sp)		; Hunk-Base merken
	cmp.w	#HUNK_BSS,2(a5)
	bne.s	10$
	addq.l	#8,a5
	bra.s	1$
10$:	move.l	4(a5),d0
	lsl.l	#2,d0
	lea	8(a5,d0.l),a5
1$:	move.l	(a5)+,d0
	cmp.w	#HUNK_DREL16,d0
	bhi.s	2$
	sub.w	#HUNK_RELOC32,d0
	bmi.s	2$
	add.w	d0,d0
	jmp	3$(pc,d0.w)
2$:	LOCS	21
	bra	Error
3$:	bra.s	4$			; 3ec
	bra.s	4$			; 3ed
	bra.s	4$			; 3ee
	bra.s	50$			; 3ef
	bra.s	5$			; 3f0
	bra.s	7$			; 3f1
	bra.s	8$			; 3f2
	bra.s	2$			; 3f3
	bra.s	2$			; 3f4
	bra.s	2$			; 3f5
	bra.s	2$			; 3f6
	bra.s	2$			; 3f7
4$:					; 3f8
	move.l	a1,d0			; HUNK_RELOC kommt nach HUNK_EXT ?
	beq.s	40$
	LOCS	22
	bra	Error
40$:	move.l	(a5)+,d0		; Relocs überspringen
	beq	1$
	lsl.l	#2,d0
	lea	4(a5,d0.l),a5
	bra.s	40$
50$:	subq.l	#1,a1
5$:	; XRefs/XDefs/Symbols überspringen
	move.l	(a5)+,d0
	beq.s	60$
	bmi.s	6$
	and.l	d1,d0
	lsl.l	#2,d0
	lea	4(a5,d0.l),a5		; XDEF/Symbol überspringen
	bra.s	5$
6$:	and.l	d1,d0
	lsl.l	#2,d0
	add.l	d0,a5			; XREF überspringen
	move.l	(a5)+,d0
	lsl.l	#2,d0
	add.l	d0,a5
	bra.s	5$
60$:	move.l	a1,d0
	addq.l	#1,d0
	bne	1$
	lea	4(a5),a1		; hinter HUNK_EXT alles ignorieren
	bra	1$			; (die +4 steht für ein simuliertes HUNK_END)
7$:	move.l	(a5)+,d0		; HUNK_DEBUG
	lsl.l	#2,d0
	add.l	d0,a5
	bra	1$
8$:	move.l	a5,d0			; HUNK_END
	move.l	a1,d1
	beq.s	9$
	move.l	d1,d0
	moveq	#-1,d1
9$:	sub.l	(sp)+,d0		; Speicherbedarf (ohne HUNK_SYMBOL/DEBUG )
	rts


	cnop	0,4
ShortenSection:
; Prüfen ob Section auf 0-Bytes endet und diese dann nicht mit speichern
; *** d2 wird zerstört!! ***
; a5 = Section
; -> d0 = new SecSize (ohne 0-Bytes am Ende)
	move.l	SecSize(a5),d0
	tst.b	NoShortenSects(a4)
	bne.s	9$
	cmp.w	#HUNK_BSS,Type+2(a5)	; nur Code und Data prüfen
	beq.s	9$
	move.l	HunkList+lh_TailPred(a5),a0
	move.l	LastReloc32(a5),d2	; SecSize darf nie kleiner als d2 werden!
	bne.s	4$
	moveq	#4,d2			; LoadSeg() mag keine Section-Länge von 0
4$:	tst.l	lh_Tail(a0)		; HunkList völlig leer?
	beq.s	9$
	move.l	HunkData(a0),a1
	move.l	DataSize(a0),d1
	add.l	d1,a1
	bra.s	2$
1$:	tst.l	-(a1)
	bne.s	3$
	subq.l	#4,d0
	cmp.l	d2,d0			; Sect. würde dadurch kleiner als LastReloc32?
	blo.s	5$
	subq.l	#4,d1
2$:	bne.s	1$
	clr.l	DataSize(a0)		; Hunk völlig leer gemacht?
	move.l	PrevHunk(a0),a0
	bra.s	4$
5$:	addq.l	#4,d0
3$:	move.l	d1,DataSize(a0)		; neue Hunklänge (ohne die Nullen am Ende)
9$:	rts


	cnop	0,4
SearchRelocs:
; a5 = Section
; -> d0 = 0 (wenn mindestens eine Relocation vorhanden)
	moveq	#-1,d0
	tst.l	ALVList(a5)
	bne.s	2$
	move.l	HunkList(a5),d1
1$:	move.l	d1,a0
	move.l	(a0),d1
	beq.s	3$
	tst.l	HunkReloc32(a0)
	bne.s	2$
	tst.l	XRefRelocs(a0)
	beq.s	1$
	tst.w	FreeXRefRel(a0)
	beq.s	1$
2$:	moveq	#0,d0
3$:	tst.w	d0
	rts


	cnop	0,4
SearchSymbols:
; a5 = Section
; -> d0 = 0 (wenn mindestens ein Symbol-Block dabei ist)
	move.l	d2,-(sp)
	moveq	#-1,d0
	move.l	HunkList(a5),d1
1$:	move.l	d1,a0
	move.l	(a0),d1
	beq.s	2$
	move.l	HunkSymbol(a0),d2
	beq.s	1$
	move.l	d2,a0
	tst.l	(a0)			; Hunk zwar vorhanden, aber völlig leer?
	beq.s	1$
	moveq	#0,d0
2$:	move.l	(sp)+,d2
	tst.w	d0
	rts


	cnop	0,4
WriteHunkData:
; d0 = FirstHunk
; a5 = Section
; -> d2 = TotalSize (bytes)
	movem.l	d4-d5,-(sp)
	moveq	#0,d5
	move.l	d0,d4
1$:	move.l	d4,a2
	move.l	(a2),d4
	beq.s	2$
	move.l	HunkData(a2),d2
	beq.s	1$
	move.l	DataSize(a2),d3
	add.l	d3,d5
	bsr	WriteData
	bra.s	1$
2$:	move.l	ALVList(a5),d0
	bra.s	4$
3$:	move.l	d0,a2
	lea	alvec(a4),a0
	move.l	alv_JmpOffset(a2),2(a0)
	move.l	a0,d2
	moveq	#6,d3
	add.l	d3,d5
	bsr	WriteData
	move.l	(a2),d0
4$:	bne.s	3$
	tst.b	OddSection(a5)
	beq.s	5$
	clr.l	-(sp)
	move.l	sp,d2
	moveq	#2,d3
	add.l	d3,d5
	bsr	WriteData
	addq.l	#4,sp
5$:	move.l	d5,d2
	movem.l	(sp)+,d4-d5
	rts


	cnop	0,4
WriteReloc32Short:
; a5 = Section
	movem.l	a3/d4-d5/d7,-(sp)
	moveq	#0,d4			; SectionCounter
1$:	cmp.w	IDCnt(a4),d4
	beq	99$
	move.l	HunkList(a5),d7		; Alle Relocs auf eine Section schreiben
	bsr	GetFilepointer
	move.l	d0,-(sp)
	move.l	d4,-(sp)		; Offsets.w / Section.w
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData
	addq.l	#4,sp
	moveq	#0,d5			; OffsetCounter

2$:	move.l	d7,a2
	move.l	(a2),d7
	beq	8$			; kein Hunk mehr da ?
	move.l	HunkReloc32(a2),d0
	beq.s	5$
	move.l	d0,a3
3$:	move.l	(a3)+,d0		; Anzahl Offsets
	beq.s	5$
	cmp.l	(a3)+,d4		; richtige Section ?
	beq.s	4$
	lsl.l	#2,d0
	add.l	d0,a3
	bra.s	3$
4$:	add.l	d0,d5			; OffsetCounter erhöhen
	lea	2(a3),a0
	move.l	a3,a1
	move.w	d0,d1
	subq.w	#1,d1
41$:	move.w	(a0),(a1)+		; Offsets auf 16-bit Format bringen
	addq.l	#4,a0
	dbf	d1,41$
	move.l	a3,d2			;  und Offsets schreiben
	add.l	d0,d0
	move.l	d0,d3
	add.l	d0,d0
	add.l	d0,a3
	bsr	WriteData
	bra.s	3$
5$:	move.l	XRefRelocs(a2),d0
	beq	2$
	move.l	d0,a3
	move.w	FreeXRefRel(a2),d0
	lea	(a3,d0.w),a0
6$:	cmp.l	a0,a3
	bhs	2$			; nächster Hunk
	cmp.w	(a3)+,d4
	bne.s	7$
	move.l	a0,-(sp)
	move.l	a3,d2
	addq.l	#2,d2
	moveq	#2,d3
	bsr	WriteData		; Durch XREF erzeugte Relocs schreiben
	addq.l	#1,d5
	move.l	(sp)+,a0
7$:	addq.l	#4,a3
	bra.s	6$

8$:	move.l	ALVList(a5),d0		; ALV-Relocs schreiben
	bra.s	83$
81$:	move.l	d0,a2
	cmp.l	alv_SecNum(a2),d4
	bne.s	82$
	lea	alv_ALVOffset+2(a2),a0
	addq.w	#2,(a0)
	move.l	a0,d2
	moveq	#2,d3
	bsr	WriteData
	addq.l	#1,d5
82$:	move.l	(a2),d0
83$:	bne.s	81$

	tst.l	d5
	bne.s	9$
	move.l	(sp)+,d0		; kein Offset vorhanden gewesen (alter FP)
	bra.s	10$
9$:	swap	d5
	tst.w	d5
	beq.s	11$
	LOCS	43			; mehr als 65535 Offsets! KICK1-Mode verwenden!
	bra	bio_exit
11$:	swap	d5
	bsr	GetFilepointer
	move.l	d0,a3
	move.l	(sp),d0
	bsr	SetFilepointer
	move.w	d5,(sp)
	move.l	sp,d2
	moveq	#2,d3
	bsr	WriteData		; richtige Anzahl Offsets schreiben
	addq.l	#4,sp
	move.l	a3,d0
10$:	bsr	SetFilepointer		; Pointer am File-Ende
	addq.w	#1,d4			; nächste Section
	bra	1$
99$:	clr.l	-(sp)
	bsr	GetFilepointer
	move.l	sp,d2
	moveq	#4,d3
	and.w	#%0010,d0		; Longword-Align
	sub.w	d0,d3
	bsr	WriteData		; Reloc32Short-Block abschließen (0.w / 0.l)
	addq.l	#4,sp
	movem.l	(sp)+,a3/d4-d5/d7
	rts


	cnop	0,4
WriteReloc32:
; d0 = FirstHunk
; a5 = Section
	movem.l	a3/d4-d5/d7,-(sp)
	moveq	#0,d4			; SectionCounter
1$:	cmp.w	IDCnt(a4),d4
	beq	99$
	move.l	HunkList(a5),d7		; Alle Relocs auf eine Section schreiben
	bsr	GetFilepointer
	move.l	d0,-(sp)
	move.l	d4,-(sp)		; Section
	clr.l	-(sp)			; Anzahl der Offsets noch unbestimmt
	move.l	sp,d2
	moveq	#8,d3
	bsr	WriteData
	addq.l	#8,sp
	moveq	#0,d5			; OffsetCounter

2$:	move.l	d7,a2
	move.l	(a2),d7
	beq	8$			; kein Hunk mehr da ?
	move.l	HunkReloc32(a2),d0
	beq.s	5$
	move.l	d0,a3
3$:	move.l	(a3)+,d0		; Anzahl Offsets
	beq.s	5$
	cmp.l	(a3)+,d4		; richtige Section ?
	beq.s	4$
	lsl.l	#2,d0
	add.l	d0,a3
	bra.s	3$
4$:	add.l	d0,d5			; OffsetCounter erhoehen
	move.l	a3,d2			;  und Offsets schreiben
	lsl.l	#2,d0
	add.l	d0,a3
	move.l	d0,d3
	bsr	WriteData
	bra.s	3$
5$:	move.l	XRefRelocs(a2),d0
	beq.s	2$
	move.l	d0,a3
	move.w	FreeXRefRel(a2),d0
	lea	(a3,d0.w),a0
6$:	cmp.l	a0,a3
	bhs.s	2$			; nächster Hunk
	cmp.w	(a3)+,d4
	bne.s	7$
	move.l	a0,-(sp)
	move.l	a3,d2
	moveq	#4,d3
	bsr	WriteData		; Durch XREF erzeugte Relocs schreiben
	addq.l	#1,d5
	move.l	(sp)+,a0
7$:	addq.l	#4,a3
	bra.s	6$

8$:	move.l	ALVList(a5),d0		; ALV-Relocs schreiben
	bra.s	83$
81$:	move.l	d0,a2
	cmp.l	alv_SecNum(a2),d4
	bne.s	82$
	lea	alv_ALVOffset(a2),a0
	addq.l	#2,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	WriteData
	addq.l	#1,d5
82$:	move.l	(a2),d0
83$:	bne.s	81$

	tst.l	d5
	bne.s	9$
	move.l	(sp)+,d0		; kein Offset vorhanden gewesen (alter FP)
	bra.s	10$
9$:	bsr	GetFilepointer
	move.l	d0,a3
	move.l	(sp),d0
	bsr	SetFilepointer
	move.l	d5,(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData		; richtige Anzahl Offsets schreiben
	addq.l	#4,sp
	move.l	a3,d0
10$:	bsr	SetFilepointer		; Pointer am File-Ende
	addq.w	#1,d4			; nächste Section
	bra	1$
99$:	clr.l	-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData		; 0 schließt den Reloc32-Block ab
	addq.l	#4,sp
	movem.l	(sp)+,a3/d4-d5/d7
	rts


	cnop	0,4
WriteSymbol:
; d0 = FirstHunk
	move.l	d4,-(sp)
	move.l	d0,d4
4$:	move.l	d4,a2
	move.l	(a2),d4
	beq.s	1$
	move.l	HunkSymbol(a2),d2
	beq.s	4$
	move.l	d2,a0
	moveq	#0,d3
2$:	move.l	(a0)+,d0		; Länge des Symbol-Blocks messen
	beq.s	3$
	addq.l	#4,d3
	addq.l	#1,d0
	lsl.l	#2,d0
	add.l	d0,d3
	add.l	d0,a0
	bra.s	2$
3$:	bsr	WriteData
	bra.s	4$
1$:	clr.l	-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	WriteData		; abschließende 0
	addq.l	#4,sp
	move.l	(sp)+,d4
	rts


	cnop	0,4
WriteDebug:
; DEBUG Hunk Blocks schreiben (nicht verketten!)
; a5 = Section
	movem.l	a3/d4,-(sp)
	move.l	HunkList(a5),d4
1$:	move.l	d4,a2
	move.l	(a2),d4
	beq.s	2$
	lea	HunkDebug(a2),a3
	bra.s	4$
3$:	move.l	d0,a3			; nächster Debug-Block
	move.l	4(a3),a0
	move.l	-(a0),d3		; leer?
	beq.s	4$
	subq.l	#4,a0
	move.l	a0,d2
	addq.l	#2,d3
	lsl.l	#2,d3
	bsr	WriteData
4$:	move.l	(a3),d0
	bne.s	3$
	bra.s	1$
2$:	movem.l	(sp)+,a3/d4
	rts


	cnop	0,4
WriteData:
; d6 = FileHandle
; d2 = Buffer
; d3 = NumBytes
	move.l	d6,a1
	move.l	d2,a0
	move.l	d3,d0
	bsr	bio_write		; buffered Write()
	tst.l	d0
	bmi.s	1$
	rts
1$:	LOCS	16

bio_exit:
	bsr	printf
	move.l	d6,a1
	bsr	bio_close
	bra	exit


	cnop	0,4
GetFilepointer:
; aktuelle Position des Filepointers lesen
; d6 = FileHandle
	move.l	d6,a1
	moveq	#0,d0
	moveq	#OFFSET_CURRENT,d1
	bsr	bio_seek
	tst.l	d0
	bmi.s	EOFErr
	rts


	cnop	0,4
SetFilepointer:
; Filepointer auf neue Position setzen
; d6 = FileHandle
; d0 = Filepointer
	move.l	d6,a1
	moveq	#OFFSET_BEGINNING,d1
	bsr	bio_seek
	tst.l	d0
	bmi.s	EOFErr
	rts


EOFErr:
	move.l	d6,a1
	bsr	bio_close
	LOCS	41			; Unexpected EOF
	bra	Error


bio_buf:
; a6 = DOSBase
; d0 = BPTR fh
; d1 = long Buffer Size
; -> d0 = struct bio *bf | NULL bei Fehler
	movem.l	d2-d3/a2/a6,-(sp)
	move.l	a6,a2
	move.l	d0,d2
	move.l	d1,d3
	move.l	ExecBase.w,a6
	move.l	#bio_buffer,d0
	add.l	d1,d0
	move.l	#MEMF_CLEAR,d1
	jsr	AllocMem(a6)
	tst.l	d0
	beq	1$
	move.l	d0,a0
	move.l	a6,bio_sysbase(a0)
	move.l	a2,bio_dosbase(a0)
	move.l	d2,bio_fh(a0)
	move.l	d3,bio_bufsize(a0)
	lea	bio_buffer(a0),a1
	move.l	a1,bio_bufptr(a0)
1$:	movem.l	(sp)+,d2-d3/a2/a6
	rts


bio_unbuf:
; a1 = struct bio *bf
	move.l	a6,-(sp)
	move.l	bio_rec_end(a1),d0
	beq	1$
	movem.l	d2-d3/a1,-(sp)
	move.l	bio_dosbase(a1),a6
	move.l	bio_fh(a1),d1
	move.l	bio_bufptr(a1),d2
	move.l	d0,d3
	jsr	Write(a6)
	movem.l	(sp)+,d2-d3/a1
1$:	move.l	bio_sysbase(a1),a6
	move.l	#bio_buffer,d0
	add.l	bio_bufsize(a1),d0
	jsr	FreeMem(a6)
	move.l	(sp)+,a6
	rts


bio_close:
; a1 = struct bio *bf
	move.l	a6,-(sp)
	move.l	bio_dosbase(a1),a6
	move.l	bio_fh(a1),-(sp)
	bsr.s	bio_unbuf
	move.l	(sp)+,d1
	jsr	Close(a6)
	move.l	(sp)+,a6
	rts


bio_write:
; a0 = Buffer
; a1 = struct bio *bf
; d0 = nBytes
; -> d0 = ...? / -1 = Error
	movem.l	d2-d5/a2-a3/a6,-(sp)
	move.l	a0,a2
	move.l	a1,a3
	move.l	d0,d4
	move.l	bio_sysbase(a3),a6
	bra	2$
1$:	move.l	bio_bufsize(a3),d0
	sub.l	bio_have(a3),d0
	cmp.l	d0,d4
	bhi	4$
	move.l	d4,d0
4$:	move.l	d0,d5
	move.l	a2,a0
	move.l	bio_bufptr(a3),a1
	add.l	bio_have(a3),a1
	jsr	CopyMem(a6)
	move.l	bio_have(a3),d1
	add.l	d5,d1
	move.l	d1,bio_have(a3)
	cmp.l	bio_rec_end(a3),d1
	bls.s	6$
	move.l	d1,bio_rec_end(a3)
6$:	sub.l	d5,d4
	add.l	d5,a2
	move.l	bio_begin(a3),d0
	add.l	d1,d0
	cmp.l	bio_eof(a3),d0
	bls	5$
	move.l	d0,bio_eof(a3)
5$:	cmp.l	bio_bufsize(a3),d1
	bne	2$
	move.l	bio_dosbase(a3),a6
	move.l	bio_fh(a3),d1
	move.l	bio_bufptr(a3),d2
	move.l	bio_bufsize(a3),d5
	move.l	d5,d3
	jsr	Write(a6)
	move.l	bio_sysbase(a3),a6
	clr.l	bio_have(a3)
	clr.l	bio_rec_end(a3)
	add.l	d5,bio_begin(a3)
	tst.l	d0
	bmi	3$
2$:	tst.l	d4
	bne	1$
3$:	movem.l	(sp)+,d2-d5/a2-a3/a6
	rts


bio_seek:
; a1 = struct bio *bf
; d0 = Seek-Pos
; d1 = Seek-Mode
; -> d0 = old position / -1 = Error
	movem.l	d2-d7/a2/a6,-(sp)
	move.l	a1,a2
	move.l	bio_dosbase(a2),a6
	tst.l	d1
	bmi	2$
	beq	1$
	add.l	bio_eof(a2),d0
	bra	2$
1$:	add.l	bio_begin(a2),d0
	add.l	bio_have(a2),d0
2$:	move.l	d0,d4
	bmi	9$
	cmp.l	bio_eof(a2),d4
	bhi	9$
	move.l	bio_begin(a2),d5
	move.l	d5,d6
	add.l	bio_have(a2),d5
	cmp.l	d6,d4
	blo	3$
	move.l	d6,d0
	add.l	bio_bufsize(a2),d0
	cmp.l	d0,d4
	bhs	3$
	sub.l	d6,d4
	bra	6$
3$:	move.l	bio_rec_end(a2),d3
	beq	4$
	move.l	bio_fh(a2),d1
	move.l	bio_bufptr(a2),d2
	jsr	Write(a6)
	tst.l	d0
	bmi	9$
4$:	move.l	d4,d6
	move.l	bio_bufsize(a2),d0
	lsr.l	#1,d0
	sub.l	d0,d6
	bpl	5$
	moveq	#0,d6
5$:	move.l	d6,bio_begin(a2)
	move.l	bio_fh(a2),d7
	bsr	10$
	bmi	9$
	move.l	d7,d1
	move.l	bio_bufptr(a2),d2
	move.l	bio_bufsize(a2),d3
	jsr	Read(a6)
	tst.l	d0
	bmi	9$
	bsr	10$
	bmi	9$
	sub.l	d6,d4
	clr.l	bio_rec_end(a2)
6$:	move.l	d4,bio_have(a2)
	move.l	d5,d0
7$:	movem.l	(sp)+,d2-d7/a2/a6
	rts
9$:	moveq	#-1,d0
	bra	7$
10$:	move.l	d7,d1
	move.l	d6,d2
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	tst.l	d0
	rts


	cnop	0,4
SearchSection:
; a0 = SectionList
; d7 = SecID
; -> d0/a0 = Section oder 0
	bra.s	2$
1$:	move.l	d0,a0
	cmp.w	SectionID+2(a0),d7
	beq.s	3$
2$:	move.l	(a0),d0
	bne.s	1$
	rts
3$:	move.l	a0,d0
	rts


	cnop	0,4
AddLinkerXDEF:
; Linker XDEFs _DATA_BAS_, _CODE_LEN_, _DATA_LEN_, _BSS_LEN_
	movem.l	d4-d5/a2,-(sp)
	lea	LinkerUnit(a4),a0
	move.l	a0,d4
	move.l	a0,d5
	lea	pdatbas_def(a4),a2	; _DATA_BAS_
	bsr	AddXDEF
	subq.l	#XdefPtr-XdefSec,a0
	move.l	a0,pdatbas_sec(a4)	; XdefSec-Ptr merken
	lea	pcodlen_def(a4),a2	; _CODE_LEN
	bsr	AddXDEF
	lea	pdatlen_def(a4),a2	; _DATA_LEN_
	bsr	AddXDEF
	lea	pbsslen_def(a4),a2	; _BSS_LEN_
	bsr	AddXDEF
	lea	psdlen_def(a4),a2	; _SMALL_DATA_LEN_
	bsr	AddXDEF
	lea	ldatbas_def(a4),a2	; _LinkerDB
	bsr	AddXDEF
	subq.l	#XdefPtr-XdefSec,a0
	move.l	a0,ldatbas_sec(a4)	; XdefSec-Ptr merken
	lea	lbssbas_def(a4),a2	; __BSSBAS
	bsr	AddXDEF
	subq.l	#XdefPtr-XdefSec,a0
	move.l	a0,lbssbas_sec(a4)	; XdefSec-Ptr merken
	lea	lbsslen_def(a4),a2	; __BSSLEN
	bsr	AddXDEF
	lea	lctors_def(a4),a2	; __ctors
	bsr	AddXDEF
	lea	ldtors_def(a4),a2	; __dtors
	bsr	AddXDEF
	lea	ddatbas_def(a4),a2	; __DATA_BAS
	bsr	AddXDEF
	subq.l	#XdefPtr-XdefSec,a0
	move.l	a0,ddatbas_sec(a4)	; XdefSec-Ptr merken
	lea	ddatlen_def(a4),a2	; __DATA_LEN
	bsr	AddXDEF
	lea	dbsslen_def(a4),a2	; __BSS_LEN
	bsr	AddXDEF
	lea	dresdnt_def(a4),a2	; __RESIDENT
	bsr	AddXDEF
	lea	phxlnk_def(a4),a2	; __PhxLnk
	bsr	AddXDEF
	movem.l	(sp)+,d4-d5/a2
	rts


	cnop	0,4
SetLnkXDEF:
; Werte für Linker XDEFs setzen
	move.l	CodeSections(a4),d0
	beq	10$
	move.l	d0,a0
	move.l	SecSize(a0),pcodlen_val(a4)
10$:	moveq	#0,d2
	move.l	mergedData(a4),d0
	sne	d1			; d1 = Merged-Mode
	bne.s	4$
	move.l	mergedBss(a4),d0
	bne	7$
	move.l	DataSections(a4),d0
	beq	1$
4$:	move.l	d0,a0
	move.l	pdatbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	ldatbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	lbssbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	ddatbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	SecSize(a0),d0
	move.l	d0,d2			; d2 Größe des gesamten SmallData-Bereichs
	move.l	d0,pdatlen_val(a4)
	move.l	d0,lbssbas_val(a4)
	lsr.l	#2,d0
	move.l	d0,ddatlen_val(a4)
	tst.b	d1
	bne.s	5$
	move.l	BssSections(a4),d0
	bra.s	6$
5$:	move.l	mergedBss(a4),d0
6$:	beq.s	2$
	move.l	d0,a0
	move.l	lbssbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	SecSize(a0),d0
	add.l	d0,d2
	tst.b	SmallData(a4)
	bne.s	3$
	tst.b	d1
	bne.s	3$
	sub.l	d0,d2
	clr.l	lbssbas_val(a4)
	bra.s	30$
3$:	move.l	d2,psdlen_val(a4)	; Größe des gesamten SD-Bereichs
30$:	move.l	d0,pbsslen_val(a4)
	lsr.l	#2,d0
	move.l	d0,lbsslen_val(a4)
	move.l	d0,dbsslen_val(a4)
2$:	tst.b	BLinkCompat(a4)
	beq.s	9$
	cmp.l	#$8000,d2		; wenn SmallData <32k, _LinkerDB auf
	bhs.s	9$			;  auf Sections-Anfang legen
	clr.l	SDOffset(a4)
9$:	rts
1$:	move.l	BssSections(a4),d0
	beq.s	2$
7$:	move.l	d0,a0
	move.l	pdatbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	ldatbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	lbssbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	ddatbas_sec(a4),a1
	move.l	a0,(a1)
	move.l	SecSize(a0),d2
	move.l	d2,d0
	bra.s	3$


	cnop	0,4
Correction:
; Diese Routine führt den eigentlichen Link-Vorgang aus !
	lea	Units(a4),a0
	move.l	a0,d6
corr_loop:
	move.l	d6,a0
	move.l	(a0),d6
	beq	corr_xrefs
	move.l	d6,a0
	move.w	U_NumHunks(a0),d7
	move.l	U_HunkPtr(a0),a6
	move.l	U_HunkSec(a0),a2
	move.l	U_HunkOffset(a0),a3
	moveq	#0,d5			; HunkCnt*4
	bra	corr_nexthunk
corr_hunkloop:
	move.l	(a6)+,a5		; Hunk
	movem.l	a5-a6,-(sp)		; a5-a6 retten!
	move.l	(a3,d5.l),d4		; Offset auf SectionBase
	move.l	HunkData(a5),a1		; Hunk-Inhalt
	move.l	HunkReloc32(a5),d0
	beq.s	20$
	move.l	d0,a0			; ** Reloc32 korrigieren **
	move.l	HunkSection(a5),a5	; a5 aktuelle Section
	move.l	LastReloc32(a5),d2	; bisher letzter Reloc32-Offset + 4
1$:	move.l	(a0)+,d3		; Anzahl RelocOffsets
	beq.s	20$
	move.l	(a0),d0			; HunkNum
	lsl.l	#2,d0
	move.l	(a2,d0.l),a6		; U_HunkSec[d0], a6 = Section
	move.l	SectionID(a6),(a0)+	; echte SecNum einsetzen
	move.l	(a3,d0.l),d1		; Offset auf diese Section
2$:	move.l	(a0),d0			; zu korrigierende Stelle
	add.l	d4,(a0)+		; um SectionBase-Offset verschieben
	add.l	d1,(a1,d0.l)		; Adr. in HunkData an Reloc-Section anpassen
	add.l	d4,d0			; Absoluter Section Offset
	addq.l	#4,d0
	cmp.l	d2,d0
	blo.s	23$			; neuer LastReloc32-Offset?
	move.l	d0,d2
23$:	subq.l	#1,d3
	bne.s	2$
	move.l	d2,LastReloc32(a5)
	bra.s	1$

20$:	movem.l	(sp)+,a5-a6		; a5-a6 zurückholen
	move.l	HunkReloc8(a5),d0
	beq.s	25$
	move.l	d0,a0			; ** Reloc8 korrigieren **
21$:	move.l	(a0)+,d3		; Anzahl
	beq.s	25$
	move.l	(a0)+,d0		; Hunk
	lsl.l	#2,d0
	move.l	(a3,d0.l),d2		; SecOffset
	move.l	(a2,d0.l),d0
	cmp.l	(a2,d5.l),d0		; Reloc8 auf aktuelle Section ?
	bne	28$
22$:	move.l	(a0)+,d0		; zu ändernde Stelle
	move.b	(a1,d0.l),d1
	ext.w	d1
	ext.l	d1
	add.l	d2,d1			; Abstand berechnen
	sub.l	d4,d1
	sub.l	d0,d1
	move.b	d1,(a1,d0.l)
	moveq	#$7f,d0			; Im Byte-Bereich (-128 bis 127) ?
	cmp.l	d0,d1
	bgt	29$
	not.l	d0
	cmp.l	d0,d1
	blt	29$
	subq.l	#1,d3
	bne.s	22$
	bra.s	21$

25$:	move.l	HunkReloc16(a5),d0
	beq.s	3$
	move.l	d0,a0			; ** Reloc16 korrigieren **
26$:	move.l	(a0)+,d3		; Anzahl
	beq.s	3$
	move.l	(a0)+,d0		; Hunk
	lsl.l	#2,d0
	move.l	(a3,d0.l),d2		; SecOffset
	move.l	(a2,d0.l),d0
	cmp.l	(a2,d5.l),d0		; Reloc16 auf aktuelle Section ?
	bne.s	28$
27$:	move.l	(a0)+,d0		; zu ändernde Stelle
	move.w	(a1,d0.l),d1
	ext.l	d1
	add.l	d2,d1			; Abstand berechnen
	sub.l	d4,d1
	sub.l	d0,d1
	move.w	d1,(a1,d0.l)
	move.l	#$7fff,d0		; Im Word-Bereich (-32768 bis 32767) ?
	cmp.l	d0,d1
	bgt.s	29$
	not.l	d0
	cmp.l	d0,d1
	blt.s	29$
	subq.l	#1,d3
	bne.s	27$
	bra.s	26$
28$:	LOCS	27			; relative between different sections
	bra.s	30$
29$:	bsr	WriteErrorOffset
	LOCS	28			; Relative out of range
30$:	move.l	d6,a1
	bra	CorrUnitError

3$:	move.l	HunkNearReloc(a5),d0
	beq.s	7$
	move.l	d0,a0			; ** NearRelocs einsetzen **
4$:	move.l	(a0)+,d3		; Anzahl NearRelocs
	beq.s	7$
	move.l	(a0)+,d0		; Hunk
	lsl.l	#2,d0
	move.l	(a3,d0.l),d2		; Offset auf diese Section
5$:	move.l	(a0)+,d0		; zu ändernde Stelle
	moveq	#0,d1
	move.w	(a1,d0.l),d1		; Word-Offset auf Near-Hunk (0-65535)
	add.l	d2,d1			; + SectionBase-Offset
	cmp.l	#$fffe,d1
	blo.s	6$
	LOCS	24			; Near addressing out of range
	move.l	d6,a1
	bra	CorrUnitError
6$:	sub.w	SDOffset+2(a4),d1	; -32766 (oder 0,scheint der Standard zu sein)
	move.w	d1,(a1,d0.l)		; Adr.Reg.Indirekt-Offset speichern
	subq.l	#1,d3
	bne.s	5$
	bra.s	4$

7$:	move.l	HunkSymbol(a5),d0
	beq.s	40$
	move.l	d0,a0			; ** Debugger Symbols korrigieren **
	move.l	#$00ffffff,d1
8$:	move.l	(a0)+,d0
	beq.s	40$
	and.l	d1,d0
	lsl.l	#2,d0			; Name überspringen
	add.l	d0,a0
	add.l	d4,(a0)+		; Symbol-Wert korrigieren
	bra.s	8$

40$:	lea	HunkDebug(a5),a0	; ** Debug-Offsets korrigieren **
	tst.b	PVcompat(a4)		; PowerVisor 1.42 DEBUG Korrektur?
	beq.s	46$
	bra.s	44$
41$:	move.l	d0,a0
	move.l	4(a0),a1
	clr.l	(a1)+			; PowerVisor DEBUG Korrektur
	cmp.l	#"LINE",(a1)+		; funktioniert nur mit LINE Blöcken
	bne.s	44$
	move.l	-12(a1),d2		; d2 HunkBlock Länge
	move.l	(a1)+,d0		; Source-Namen überspringen
	subq.l	#3,d2
	sub.l	d0,d2
	lsl.l	#2,d0
	lea	4(a1,d0.l),a1		; Zeiger auf ersten Offset
	bra.s	43$
42$:	add.l	d4,(a1)			; Line-Offset korrigieren
	addq.l	#8,a1
43$:	subq.l	#2,d2			; Noch ein Eintrag da?
	bpl.s	42$
44$:	move.l	(a0),d0			; noch ein Debug-Block in diesem Hunk?
	bne.s	41$
	bra.s	9$

45$:	move.l	d0,a0			; normale Korrektur (BLink, SAS/C)
	move.l	4(a0),a1
	add.l	d4,(a1)
46$:	move.l	(a0),d0
	bne.s	45$

9$:	move.l	HunkExtern(a5),d0
	beq.s	14$
	move.l	d0,a0			; ** XDEFs korrigieren **
	move.l	#$00ffffff,d3
10$:	move.l	(a0)+,d0
	beq.s	14$
	bpl.s	11$
	and.l	d3,d0			; XREFS übergehen (werden gesond. behandelt)
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
	bra.s	10$
11$:	move.l	d0,d1			; XDEF, Name übergehen
	and.l	d3,d1
	lsl.l	#2,d1
	add.l	d1,a0
	rol.l	#8,d0
	subq.b	#1,d0			; ext_def ?
	bne.s	12$
	add.l	d4,(a0)+		; korrigieren
	bra.s	10$
12$:	subq.b	#1,d0			; ext_abs ?
	bne.s	13$
	addq.l	#4,a0
	bra.s	10$
13$:	LOCS	25			; Unknown XDEF
	move.l	d6,a1
	bra	CorrUnitError

14$:	move.l	XRefRelocs(a5),d0
	beq.s	16$
	move.l	d0,a0			; SectionBase-Offset in XRefRelocs eintragen
	move.w	NumXRefs(a5),d0
	subq.w	#1,d0
15$:	clr.w	(a0)+
	move.l	d4,(a0)+
	dbf	d0,15$

16$:	addq.l	#4,d5
corr_nexthunk:
	dbf	d7,corr_hunkloop
	bra	corr_loop

corr_exit:
	rts
corr_xrefs:
	lea	XREFList(a4),a5		; Alle XREFs einsetzen
	move.l	#$00ffffff,d7
1$:	move.l	(a5),d0
	beq.s	corr_exit
	move.l	d0,a5
	move.l	XrefXdef(a5),d0		; undef.te stammten von gelöschten Units
	beq.s	1$
	move.l	d0,a0
	move.l	XrefHunk(a5),a2
	move.l	HunkSection(a2),a6	; a6 XREF-Section
	move.l	XdefSec(a0),a1
	move.l	SectionID(a1),d2	; SecNum des XDEF
	move.l	XdefPtr(a0),a0
	cmp.b	#EXT_DEF,(a0)
	beq.s	2$
	moveq	#-1,d2			; absoluter Wert braucht keine SectionNum
2$:	move.l	(a0)+,d0
	and.l	d7,d0
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0),d6			; Symbol-Wert
	move.l	XrefPtr(a5),a0
	move.l	HunkData(a2),a3		; Hunk Inhalt
	move.b	(a0),d0
	move.l	(a0)+,d1
	and.l	d7,d1
	lsl.l	#2,d1
	add.l	d1,a0
	move.l	(a0)+,d5		; Zahl der Korrekturen

	cmp.b	#EXT_REF32,d0
	bne.s	3$
	tst.w	d2
	bmi.s	22$
	move.l	LastReloc32(a6),d1	; bisher letzter Reloc32-Offset +4
21$:	move.l	(a0)+,d4
	move.l	XRefRelocs(a2),a1
	add.w	FreeXRefRel(a2),a1
	addq.w	#6,FreeXRefRel(a2)
	move.w	d2,(a1)+		; Section
	add.l	d4,(a1)			; Offset auf Hunk
	add.l	d6,(a3,d4.l)		; 32-Bit Reloc-Offset einsetzen
	move.l	(a1),d0
	addq.l	#4,d0
	cmp.l	d1,d0			; neuer LastReloc32-Offset?
	blo.s	23$
	move.l	d0,d1
23$:	subq.l	#1,d5
	bne.s	21$
	move.l	d1,LastReloc32(a6)
	bra	1$
22$:	move.l	(a0)+,d0
	add.l	d6,(a3,d0.l)		; 32-Bit Absolutwert einsetzen
	subq.l	#1,d5
	bne.s	22$
	bra	1$
3$:	cmp.b	#EXT_REF16,d0
	bne.s	4$
	tst.w	d2
	bmi	63$			; absolut?
30$:	move.l	SecBaseOffset(a2),d4	; SectionBaseOffset
	cmp.w	SectionID+2(a6),d2	; relative Adressierung auf andere Section ?
	beq.s	31$
	tst.b	GenALVs(a4)		; ALV-Generierung erlaubt?
	beq	9$
	bsr	GenerateALV
	bra	1$
31$:	move.l	(a0)+,d0
	move.w	(a3,d0.l),d1
	ext.l	d1
	add.l	d6,d1
	sub.l	d4,d1
	sub.l	d0,d1			; Abstand berechnen
	move.l	#$7fff,d3
	cmp.l	d3,d1			; Auf Wortgrenzen testen
	bgt.s	8$
	not.l	d3
	cmp.l	d3,d1
	blt.s	8$
	move.w	d1,(a3,d0.l)		; 16-Bit Relative-Addressing einsetzen
	subq.l	#1,d5
	bne.s	31$
	bra	1$
4$:	cmp.b	#EXT_REF8,d0
	bne.s	5$
	tst.w	d2
	bmi	65$
40$:	LOCS	29			; Byte-Addressierung ziemlich unmöglich
	bra	99$			; (sollte zumindest besser vermieden werden)
5$:	cmp.b	#EXT_DEXT16,d0
	bne.s	6$
	tst.w	d2
	bmi	63$			; Absolutwert?
	cmp.l	#$fffe,d6		; Adresse im Near-Bereich (64K)
	blo.s	52$
51$:	LOCS	24			; Near addressing out of range
	bra.s	99$
52$:	sub.w	SDOffset+2(a4),d6	; Near-Offset
53$:	move.l	(a0)+,d0
	add.w	d6,(a3,d0.l)		; 16-Bit Near-Offset einsetzen
	bvs.s	51$			; Overflow dabei ?
	subq.l	#1,d5
	bne.s	53$
	bra	1$
6$:	cmp.b	#EXT_RELREF32,d0
	bne.s	62$
	tst.w	d2
	bmi	22$
	cmp.w	SectionID+2(a6),d2	; relative Adressierung auf andere Section ?
	bne	9$
	move.l	SecBaseOffset(a2),d4	; SectionBaseOffset
61$:	move.l	(a0)+,d0
	move.l	(a3,d0.l),d1
	add.l	d6,d1
	sub.l	d4,d1
	sub.l	d0,d1			; Abstand berechnen
	move.l	d1,(a3,d0.l)		; 32-Bit Relative-Addressing einsetzen
	subq.l	#1,d5
	bne.s	61$
	bra	1$
62$:	cmp.b	#EXT_ABSREF16,d0
	bne.s	64$
	tst.w	d2
	bpl	30$			; relativ? dann EXT_REF16
63$:	move.l	(a0)+,d0
	add.w	d6,(a3,d0.l)		; 16-Bit Absolutwert einsetzen
	subq.l	#1,d5
	bne.s	63$
	bra	1$
64$:	cmp.b	#EXT_ABSREF8,d0
	bne.s	7$
	tst.w	d2
	bpl	40$			; relativ? dann EXT_REF8
65$:	move.l	(a0)+,d0
	add.b	d6,(a3,d0.l)		; 8-Bit Absolutwert einsetzen
	subq.l	#1,d5
	bne.s	65$
	bra	1$

7$:	LOCS	26
	bra.s	99$
8$:	bsr	WriteErrorOffset
	LOCS	28			; Relative out of range
	bra.s	99$
9$:	LOCS	27			; relative between different sections
99$:	move.l	UnitStruct(a2),a1
	bra	CorrUnitError


CorrUnitError:
	move.l	U_ObjName(a1),-(sp)
	move.l	U_Name(a1),-(sp)
	move.l	sp,a1
	bsr	printf
	bra	exit


WriteErrorOffset:
; Gibt den Offset des fehlerhaften Wertes innerhalb einer Section an
; a0 = Zeiger auf neuen Offset (ErrorOffset = -4(a0))
	move.l	-4(a0),-(sp)
	LOCS	30			; At Offset ..
	move.l	sp,a1
	bsr	printf
	addq.l	#4,sp
	rts


	cnop	0,4
GenerateALV:
; Automatic Link Vector am Hunk-Ende als Reloc-32Bit-JMP erzeugen
; d2 = SectionID der durch ALV anzuspringenden Section
; d6 = ALV Ziel-Offset
; a0 = Zeiger auf zu korr. Offsets im EXT_REF16-Block
; d5 = Anzahl der zu korrigierenden Stellen
; a2 = Hunk-Struktur
	movem.l	d7/a3/a5-a6,-(sp)
	move.l	SysBase(a4),a6
	move.l	a0,a5			; a5 zu korr. HunkOffset-Liste
	move.l	HunkSection(a2),a0	; Section, zu der der Hunk gehört
	lea	ALVList(a0),a3
	bra.s	2$
1$:	move.l	d0,a3
	cmp.l	alv_SecNum(a3),d2	; existiert derselbe ALV bereits?
	bne.s	2$
	cmp.l	alv_JmpOffset(a3),d6
	bne.s	2$
	move.l	alv_ALVOffset(a3),d7	; ...dann benutzen
	bra.s	4$
2$:	move.l	(a3),d0
	bne.s	1$
	moveq	#6,d0			; neuen ALV erzeugen
	move.l	SecSize(a0),d7		; d7 neuer Ziel-Offset
	add.l	d0,SecSize(a0)
	add.l	d7,d0
	move.l	d0,LastReloc32(a0)
	moveq	#alvSIZE,d0
	bsr	mAlloc_Clear		; Speicher für neue ALV-Struktur
	move.l	d0,(a3)			; einhängen
	beq	OutOfMemory
	move.l	d0,a0
	move.l	d2,alv_SecNum(a0)
	move.l	d6,alv_JmpOffset(a0)
	move.l	d7,alv_ALVOffset(a0)
4$:	move.l	HunkData(a2),a3		; Hunk-Inhalt
5$:	move.l	(a5)+,d0		; nächster zu korr. Hunk-Offset
	tst.w	(a3,d0.l)		; ALVs klappen nur, wenn das Ziel
	bne	90$			;  direkt angesprungen wird
	move.l	d7,d1
	sub.l	d0,d1			; Offset bis zum ALV
	cmp.l	#$7fff,d1
	bgt	90$			; innerhalb der Reichweite?
	move.w	d1,(a3,d0.l)
	subq.l	#1,d5			; noch ein Hunk-Offset?
	bne.s	5$
	movem.l	(sp)+,d7/a3/a5-a6
	rts
90$:	LOCS	27			; relative between different sections
99$:	move.l	UnitStruct(a2),a1
	bra	CorrUnitError


	cnop	0,4
CalcHunkOffsets:
; Alle Hunk-Offset auf die SectionBase berechnen und in Unit->HunkOffset[...]
; eintragen.
	lea	Units(a4),a5
	moveq	#0,d4
	move.l	mergedData(a4),d6
	bne.s	11$
	move.b	SmallData(a4),d4
	beq.s	1$
	move.l	DataSections(a4),d6
	beq.s	1$
11$:	move.l	d6,a0
	move.l	SecSize(a0),d6		; DataSize wird bei SmallData benötigt
1$:	move.l	(a5),d0
	beq.s	7$
	move.l	d0,a5
	move.w	U_NumHunks(a5),d7
	move.l	U_HunkPtr(a5),a1
	move.l	U_HunkOffset(a5),a3
	bra.s	5$
2$:	move.l	(a1)+,a2		; Hunk
	move.l	HunkSection(a2),a0	; Section
	moveq	#0,d3
	cmp.l	mergedBss(a4),a0	; ist __MERGED-BSS ?
	beq.s	21$
	tst.b	d4
	beq.s	6$			; ist SmallData
	cmp.w	#HUNK_BSS,Type+2(a0)	;  und BSS-Section ?
	bne.s	6$
21$:	move.l	d6,d3			; BSS direkt hinter DATA haengen
6$:	move.l	HunkList(a0),a0
	bra.s	4$
3$:	add.l	DataSize(a0),d3		; Offset fuer Hunk bestimmen
	move.l	(a0),a0
4$:	cmp.l	a2,a0
	bne.s	3$
	move.l	d3,(a3)+		; und speichern
	move.l	d3,SecBaseOffset(a2)
5$:	dbf	d7,2$
	bra.s	1$			; nächste Unit

7$:	lea	RelDefList(a4),a2	; Section-Offset für User-XDEFs korr.
	bra.s	9$
8$:	move.l	d0,a2
	move.l	ux_XdefStruct(a2),a0
	move.l	XdefPtr(a0),a1
	cmp.b	#EXT_DEF,(a1)		; Nur Reloc-Definitionen korrigieren
	bne.s	9$
	move.l	XdefSec(a0),d1
	move.l	XdefUnit(a0),a3
	move.w	U_NumHunks(a3),d0
	move.l	U_HunkSec(a3),a0	; Section suchen, zu der das...
	tst.l	d1			;  (d1 sollte das Z-Flags löschen)
	bra.s	82$
81$:	cmp.l	(a0)+,d1		; ...User-XDEF gehört
82$:	dbeq	d0,81$
	bne.s	9$			; Nicht gefunden??? Gibt's nicht!
	sub.l	U_HunkSec(a3),a0
	move.l	U_HunkOffset(a3),a3
	move.l	-4(a3,a0),d0		; Section-Offset für diesen Hunk
	move.l	(a1)+,d1
	lsl.w	#2,d1
	add.l	d0,(a1,d1.w)		; Offset addieren
9$:	move.l	(a2),d0
	bne.s	8$
	rts


	cnop	0,4
KillUnselected:
; Alle Units (sowie dessen Hunks) ohne gesetztes U_Select werden entfernt
	move.l	SysBase(a4),a6
	lea	Units(a4),a0
	move.l	a0,d5			; d5 LastUnit
	move.l	(a0),d2			; d2 NewUnit
	beq.s	killun_exit
killun_loop:
	move.l	d2,a5			; nächste Unit
	tst.b	U_Select(a5)
	beq.s	killun_del
	move.l	d2,d5
	move.l	(a5),d2
	bne.s	killun_loop
killun_exit:
	rts
killun_del:
	move.l	d5,a0
	move.l	(a5),(a0)		; Unit aus Liste nehmen
	move.l	U_HunkPtr(a5),a2
	move.w	U_NumHunks(a5),d7
	bra.s	2$
1$:	move.l	(a2)+,a1		; hunk
	move.l	DataSize(a1),d2
	move.l	HunkSection(a1),a3
	lea	HunkList(a3),a0
	jsr	Remove(a6)		; Hunk aus der Liste nehmen
	sub.l	d2,SecSize(a3)
	move.l	HunkList(a3),a0
	tst.l	(a0)			; HunkList ist jetzt völlig leer?
	bne.s	2$
	move.l	a3,a0
	bsr.s	KillSection
2$:	dbf	d7,1$			; nächster Hunk der Unit
	move.l	(a5),d2
	bne	killun_loop
	rts


	cnop	0,4
KillZeroSecs:
; Section mit Länge 0 werden entfernt
	tst.b	RemEmpty(a4)
	beq.s	3$			; Leere Sections löschen?
	move.l	CodeSections(a4),d0
	bsr.s	2$
	move.l	DataSections(a4),d0
	bsr.s	2$
	move.l	BssSections(a4),d0
	bra.s	2$
1$:	move.l	d0,a0
	move.l	(a0),d0
	tst.l	SecSize(a0)		; Länge 0?
	bne.s	2$
	bsr.s	KillSection
2$:	tst.l	d0
	bne.s	1$
3$:	rts


	cnop	0,4
KillSection:
; Leere Section aus ihrer Section-Liste entfernen
; ** Alle Register werden gerettet **
; a0 = Section
	movem.l	d0-d3/a0-a2,-(sp)
	move.w	Type+2(a0),d2		; Section-Type
	cmp.w	#HUNK_CODE,d2
	bne.s	3$
	moveq	#0,d2			; d2=0 : CodeSection entfernen
	lea	CodeSections(a4),a1
	move.l	a1,d0
	bra.s	1$
3$:	cmp.w	#HUNK_DATA,d2
	bne.s	4$
	lea	DataSections(a4),a1
	move.l	a1,d0
	bra.s	1$
4$:	lea	BssSections(a4),a1
	move.l	a1,d0
1$:	move.l	d0,a1
	move.l	(a1),d0
	cmp.l	a0,d0
	bne.s	1$
	move.l	(a0),(a1)		; Section aus der Liste nehmen
	move.w	SectionID+2(a0),d3	; d3 ID der entfernten Section
	move.l	a0,a2			; Sect.addr merken -> a2
	tst.b	d2
	beq.s	6$			; keine CODE-Section?
	cmp.l	mergedData(a4),a2	; __MERGED-Data oder -Bss entfernt?
	bne.s	11$
	clr.l	mergedData(a4)
	tst.l	mergedBss(a4)		; __MERGED-Bereich hat sich aufgelöst?
	bra.s	12$
11$:	cmp.l	mergedBss(a4),a0
	bne.s	13$
	clr.l	mergedBss(a4)
	tst.l	mergedData(a4)		; __MERGED-Bereich hat sich aufgelöst?
12$:	bne.s	2$
	bra.s	6$
13$:	tst.b	SmallData(a4)
	beq.s	6$
	move.l	DataSections(a4),d0
	add.l	BssSections(a4),d0	; SmallData-Bereich hat sich aufgelöst?
	bne.s	2$
6$:	subq.w	#1,IDCnt(a4)
	lea	CodeSections(a4),a0	; Alle IDs größer als die der entfernten
	bsr.s	10$			;  Section um einen erniedrigen
	lea	DataSections(a4),a0
	bsr.s	10$
	lea	BssSections(a4),a0
	bsr.s	10$
2$:	movem.l	(sp)+,d0-d3/a0-a2
	rts
9$:	move.l	d0,a0
	cmp.w	SectionID+2(a0),d3
	bhs.s	10$
	subq.w	#1,SectionID+2(a0)
10$:	move.l	(a0),d0
	bne.s	9$
	rts


	cnop	0,4
AlignSecLengths:
; Die Länge aller Sections 32-Bit-aligned machen, da diese Ausrichtung
; durch mögliche ALVs nicht mehr garantiert ist.
	tst.b	GenALVs(a4)		; waren überhaupt ALVs erlaubt?
	beq.s	3$
	move.l	CodeSections(a4),d0
	bsr.s	2$
	move.l	DataSections(a4),d0
	bra.s	2$
1$:	move.l	d0,a0
	btst	#1,SecSize+3(a0)	; Long- oder Word-Aligned?
	beq.s	4$
	st	OddSection(a0)
	addq.l	#2,SecSize(a0)
4$:	move.l	(a0),d0
2$:	bne.s	1$
3$:	rts


	cnop	0,4
SearchUserXDEFs:
; Die den UserXDEFs zugewiesenen XDEF-Symbol in der HashTable suchen und
; deren Offsets übernehmen.
	lea	RelDefList(a4),a5
	bra	9$
1$:	move.l	d0,a5			; a5 struct UserXDEF
	lea	ux_SymName(a5),a2
	move.l	a2,a0
	move.l	ux_SymLen(a5),d4
	move.w	d4,d1
	HASHC	a0,d0,d1,d2,d3		; Hashcode für zugew. Sym. berechnen
	and.w	HashTabMask(a4),d0
	lsl.l	#2,d0
	move.l	XDEFHashTab(a4),a0	; Hash Table
	move.l	(a0,d0.l),d0
	beq.s	5$			; XDEF dieses Namens existiert nicht?
2$:	move.l	d0,a3			; Hash Chain durchgehen...
	move.l	XdefPtr(a3),a1		; Symbol Namen vergleichen
	move.l	(a1)+,d0
	cmp.w	d4,d0			; dieselbe Länge?
	bne.s	4$
	subq.w	#1,d0
	move.l	a2,a0
3$:	cmpm.l	(a0)+,(a1)+		; Symbolnamen vergleichen
	dbne	d0,3$
	bne.s	4$
	move.l	ux_XdefStruct(a5),a1	; XDEF-Daten kopieren
	move.l	XdefUnit(a3),XdefUnit(a1)
	move.l	XdefSec(a3),XdefSec(a1)
	move.l	XdefPtr(a3),a0
	move.l	XdefPtr(a1),a1
	move.l	(a0),d0
	lsl.w	#2,d0
	move.l	(a1),d1
	lsl.w	#2,d1
	move.l	4(a0,d0.w),4(a1,d1.w)	; Symbol-Offset/Absolutwert
	move.b	(a0),(a1)		; und Typ kopieren
	bra.s	9$
4$:	move.l	NextXdef(a3),d0		; noch ein XDEF in der Hash-Chain?
	bne.s	2$

5$:	clr.l	-(sp)			; Zugewiesenes Symbol ist unbekannt!
	move.l	ux_SymLen(a5),d0
	move.w	d0,d1
	subq.w	#1,d1
	lsl.l	#2,d0
	lea	ux_SymName(a5,d0.l),a0
6$:	move.l	-(a0),-(sp)
	dbf	d1,6$
	move.l	sp,-(sp)
	LOCS	6			; Unable to resolve user definition
	move.l	sp,a1
	bsr	printf
	bra	exit

9$:	move.l	ux_Next(a5),d0		; noch ein UserXDEF auflösen?
	bne	1$
	rts


	cnop	0,4
SelectUnits:
; Alle XREFs der 'selected'-Units mit XDEFs vergleichen und dadurch bestimmen
; welche Library-Units benötigt werden
; (Hier hält sich der Linker wohl am längsten auf!!)
	moveq	#0,d4			; Undef.Sym Title schon ausgegeben?
sel_restart:
	lea	XREFList(a4),a5
	moveq	#0,d7			; =-1 wenn eine weitere Unit selektiert wurde
sel_loop:
	move.l	(a5),d0			; nächste XREF-Struktur
	beq	sel_exit
	move.l	d0,a5
	tst.l	XrefXdef(a5)		; zugehöriges XDEF schon gefunden ?
	bne.s	sel_loop
	move.l	XrefHunk(a5),a0
	move.l	UnitStruct(a0),a0
	tst.b	U_Select(a0)		; Unit für dieses XREF gültig ?
	beq.s	sel_loop
	move.l	XrefPtr(a5),a2
	move.l	(a2)+,d6
	move.w	d6,d1
	subq.w	#1,d6
	bmi.s	4$			; illeg. Sym. der Länge 0?
	move.l	a2,a0
	HASHC	a0,d0,d1,d2,d3		; Hashcode für dieses Symbol berechnen > d0
	and.w	HashTabMask(a4),d0
	lsl.l	#2,d0
	move.l	XDEFHashTab(a4),a0	; Hash Table
	move.l	(a0,d0.l),d0
	beq.s	4$			; XDEF dieses Namens existiert nicht?
1$:	move.l	d0,a3			; Hash Chain durchgehen...
	move.l	XdefPtr(a3),a1		; Symbol Namen vergleichen
	move.l	(a1)+,d0
	subq.w	#1,d0
	cmp.w	d6,d0			; dieselbe Länge?
	bne.s	3$
	move.l	a2,a0
2$:	cmpm.l	(a0)+,(a1)+		; Symbolnamen vergleichen
	dbne	d0,2$
	bne.s	3$
	move.l	a3,XrefXdef(a5)		; gefundenes XDEF eintragen
	move.l	XdefUnit(a3),a0
	tst.b	U_Select(a0)		; Unit des XDEF-Symbols schon selektiert ?
	bne.s	sel_loop
	st	U_Select(a0)		;  dann ist sie's jetzt
	moveq	#-1,d7
	bra.s	sel_loop
3$:	move.l	NextXdef(a3),d0		; noch ein XDEF in der Hash-Chain?
	bne.s	1$
4$:	bset	#0,d4			; Undefined Symbol!
	bne.s	5$
	LOCS	32			; Title: Undef.Symbols,Unit,File ...
	bsr	printf
	lea	xrefundeftitle(pc),a0	; unterstreichen
	bsr	printf
5$:	move.l	XrefHunk(a5),a0
	move.l	UnitStruct(a0),a1
	move.l	U_ObjName(a1),-(sp)
	move.l	U_Name(a1),-(sp)
	move.l	HunkSection(a0),a0
	pea	SectionName(a0)
	move.l	XrefPtr(a5),a0
	move.l	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	clr.b	(a0,d0.w)
	move.l	a0,-(sp)
	lea	xrefundef(pc),a0
	move.l	sp,a1
	bsr	printf			; undefined symbol ausgeben
	lea	16(sp),sp
	st	XrefXdef(a5)		; trotzdem als gefunden markieren
	bra	sel_loop
sel_exit:
	tst.b	d7			; neue Unit hinzugekommen ?
	bne	sel_restart		;  Nochmal durchgehen
	tst.b	d4			; undef. Symbols dabei?
	bne	exit
	rts

xrefundeftitle:
	dcb.b	72,'-'
	dc.b	"\n\0"
xrefundef:
	dc.b	"%-24s%-16s%-16s%s\n\0"
break_txt:
	dc.b	"***Break\n\0"


	cnop	0,4
GetName:
; d0 = NameLen in Longwords
; a0 = NameBuffer
; a1 = FilePtr
; -> a1 = NewFilePtr
	move.l	d2,-(sp)
	moveq	#0,d2
	lsl.w	#2,d0
	bne.s	3$
	move.l	#'UNNA',(a0)+		; keine Name, dann "UNNAMED"
	move.l	#'MED\0',(a0)
	bra.s	4$
3$:	move.w	#MAXNAMELEN-1,d1
	cmp.w	d1,d0
	blo.s	1$
	move.w	d0,d2
	move.w	d1,d0
	sub.w	d0,d2
1$:	subq.w	#1,d0
2$:	move.b	(a1)+,(a0)+
	dbf	d0,2$
	clr.b	(a0)
	add.l	d2,a1
4$:	move.l	(sp)+,d2
	rts


	cnop	0,4
GetUnit:
; Speicher für Unit-Struktur besorgen
; -> a0 = Unit
	move.l	a6,-(sp)
	move.l	SysBase(a4),a6
	move.l	#UnitSIZE,d0
	bsr	mAlloc_Clear
	tst.l	d0
	beq	OutOfMemory
	move.l	d0,a0
	lea	U_NameBuffer(a0),a1
	move.l	a1,U_Name(a0)
	lea	Units(a4),a1
1$:	move.l	(a1),d0			; neue Unit in Liste anhängen
	beq.s	2$
	move.l	d0,a1
	bra.s	1$
2$:	move.l	a0,(a1)
	move.l	(sp)+,a6
	rts


UnitError:
	move.l	ActiveUnit(a4),a1
	move.l	U_ObjName(a1),-(sp)
	move.l	U_Name(a1),-(sp)
	move.l	sp,a1
	bsr	printf
exit:
	move.l	ExitSP(a4),sp
	bra	CleanUp


OutOfMemory:
	LOCS	34			; Out of Memory!
	bsr	printf
	bra.s	exit


	cnop	0,4
AddUnit:
; Filepointer steht auf dem ersten Hunk dieser Unit
; a0 = FilePtr
; -> d0 = 0(ok), -1(File besitzt noch mindestens eine Unit)
; -> a0 = NewFilePtr
	movem.l	d4-d7/a2-a3/a5-a6,-(sp)
	move.l	a0,a5			; a5 = FilePtr
	clr.w	HunkCnt(a4)

Next_Hunk:
	move.l	(a5),d0
	cmp.w	#HUNK_UNIT,d0		; Beginnt hier eine neue Unit ?
	bne.s	1$
	moveq	#-1,d0			; ab hier beginnt eine neue Unit
	bra	au_savehunkptrs
1$:	cmp.l	#'PHX!',d0		; File hier zuende ?
	bne.s	11$
	moveq	#0,d0
	bra	au_savehunkptrs		; Object-File zuende
11$:	cmp.w	#HUNK_NAME,d0		; Hat die Section einen Namen?
	beq.s	12$
	lea	SecName(a4),a0
	moveq	#0,d0
	bsr	GetName
	bra.s	60$
12$:	move.w	#MAXNAMELEN-1,d0	; Section Name Buffer erst löschen
	lea	SecName+MAXNAMELEN(a4),a0
6$:	clr.b	-(a0)
	dbf	d0,6$
	move.l	4(a5),d0
	lea	8(a5),a1
	bsr	GetName			; Section Name lesen
	move.l	a1,a5

60$:	move.w	2(a5),d0
	cmp.w	#HUNK_CODE,d0
	bne.s	2$
	lea	CodeSections(a4),a0
	tst.b	SmallCode(a4)		; Small Code?
	beq	5$
	move.l	(a0),d0
	beq	5$
	move.l	d0,a0
	bra	7$

2$:	cmp.w	#HUNK_DATA,d0
	bne	3$
	lea	DataSections(a4),a0
	tst.b	SmallData(a4)		; Small Data?
	beq	5$
	move.l	(a0),d0
	beq.s	21$
	move.l	d0,a0
	bra	7$
21$:	bsr	GetSection
	move.l	BssSections(a4),d0	; war vorher schon eine BSS eingerichtet ?
	beq	7$
22$:	move.l	d0,a1
	move.w	SectionID+2(a1),SectionID+2(a0)
	subq.w	#1,IDCnt(a4)		; Data und BSS sind eine Section
	bra	7$
3$:	cmp.w	#HUNK_BSS,d0
	bne.s	4$
	lea	BssSections(a4),a0
	tst.b	SmallData(a4)
	beq.s	5$
	move.l	(a0),d0
	beq.s	31$
	move.l	d0,a0
	bra.s	7$
31$:	bsr	GetSection
	move.l	DataSections(a4),d0	; war vorher schon eine DATA eingerichtet ?
	beq.s	7$
	bra.s	22$
4$:	cmp.w	#HUNK_DEBUG,d0		; Debug-Hunk vor allem anderen?
	bne.s	9$
	move.l	4(a5),d0		; na gut... dann aber ignorieren...
	addq.l	#2,d0
	lsl.l	#2,d0
	add.l	d0,a5
	bra	60$
9$:	LOCS	35			; Unknown section type
	bra	UnitError
7$:	move.l	(a5)+,d0
	or.l	d0,Type(a0)		; OR wegen eventueller CHIP/FAST-Flags
	bra	8$

5$:	bsr	GetSection		; Section suchen -> a0
	move.l	(a5)+,d0		; Type
	cmp.l	#"__ME",SecName(a4)	; Section Name ist zufällig "__MERGED" ?
	bne	8$
	cmp.l	#"RGED",SecName+4(a4)
	bne	8$
	sub.w	#HUNK_DATA,d0		; __MERGED-Data?
	bne.s	50$
	tst.l	mergedData(a4)		; war schon vorhanden?
	bne	8$
	move.l	a0,mergedData(a4)
	move.l	mergedBss(a4),d0	; vorher schon _MERGED-Bss eingerichtet?
	beq	8$
51$:	move.l	d0,a1
	move.w	SectionID+2(a1),SectionID+2(a0)
	subq.w	#1,IDCnt(a4)		; _MERGED-Data und -BSS sind eine Section
	bra.s	8$
50$:	subq.w	#1,d0			; __MERGED-BSS?
	bne.s	8$
	tst.l	mergedBss(a4)		; war schon vorhanden?
	bne.s	8$
	move.l	a0,mergedBss(a4)
	move.l	mergedData(a4),d0	; vorher schon _MERGED-Data eingerichtet?
	bne.s	51$
8$:	move.l	(a5)+,d0
	lsl.l	#2,d0			; Größe des Hunk-Inhalts in Bytes
	bsr	NewHunk			; Neuen Hunk anhängen
	bra	Next_Hunk

	cnop	0,4
au_savehunkptrs:
	movem.l	d0/a5,-(sp)
	move.l	SysBase(a4),a6
	move.l	ActiveUnit(a4),a3
	moveq	#0,d0
	move.w	HunkCnt(a4),d0
	move.w	d0,d2
	beq	au_exit
	subq.w	#1,d2
	move.w	d0,U_NumHunks(a3)
	lsl.l	#2,d0
	move.l	d0,d3
	mulu	#3,d0			; 4 Bytes fuer jeden Eintrag * 3 Felder
	bsr	mAlloc
	tst.l	d0
	beq	OutOfMemory
	move.l	d0,a0
	move.l	a0,U_HunkPtr(a3)
	lea	(a0,d3.l),a1
	move.l	a1,U_HunkSec(a3)
	lea	(a1,d3.l),a2
	move.l	a2,U_HunkOffset(a3)
	move.l	UnitInfo(a4),a6
1$:	move.l	(a6)+,(a0)+		; HunkPtr
	move.l	(a6)+,(a1)+		; HunkSec
	dbf	d2,1$

	move.w	U_NumHunks(a3),d2
	move.l	a3,d4			; Unit
	move.l	U_HunkSec(a3),a5	; HunkSection-Array
	move.l	U_HunkPtr(a3),a3	; HunkPtr-Array
	bra	7$
2$:	move.l	(a3)+,a6		; Hunk-Struktur
	move.l	(a5)+,d5		; Section
	move.l	HunkExtern(a6),d0
	beq	7$
	move.l	d0,a2
3$:	tst.l	(a2)
	beq.s	6$
	move.b	(a2),d3
	bmi.s	4$
	bsr	AddXDEF
	move.l	#$00ffffff,d0
	and.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	addq.l	#4,a2
	bra.s	3$
4$:	bsr	AddXREF
	move.l	#$00ffffff,d0
	and.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	(a2)+,d0
	cmp.b	#EXT_REF32,d3		; XREF wird eine Relocation erzeugen ?
	bne.s	5$
	add.w	d0,NumXRefs(a6)
5$:	lsl.l	#2,d0
	add.l	d0,a2
	bra.s	3$
6$:	move.l	a6,a2
	move.l	SysBase(a4),a6
	move.w	NumXRefs(a2),d0
	beq.s	7$
	mulu	#6,d0			; Speicher für die durch ext_ref32
	bsr	mAlloc_Clear		;  erz. Relocs
	move.l	d0,XRefRelocs(a2)
	beq	OutOfMemory
7$:	dbf	d2,2$			; nächster Hunk

au_exit:
	movem.l	(sp)+,d0/a0
	movem.l	(sp)+,d4-d7/a2-a3/a5-a6
	rts


	cnop	0,4
AddXDEF:
; d4 = Unit, d5 = HunkSection, a2 = XdefPtr
; d4,d5,a2 bleiben unverändert,
; ->a0 = Zeiger auf XDefPtr der neuen XDef-Struktur
	movem.l	d2-d3/d6/a3/a6,-(sp)
	move.l	(a2)+,d6		; d6.w Symbol-Länge in Longwords
	move.w	d6,d1
	subq.w	#1,d6
	bmi	9$			; illeg. Sym. der Länge 0 ignorieren
	move.l	a2,a0
	HASHC	a0,d0,d1,d2,d3		; Hashcode für dieses Symbol berechnen > d0
	and.w	HashTabMask(a4),d0
	lsl.l	#2,d0
	move.l	XDEFHashTab(a4),a0	; Hash Table
	move.l	(a0,d0.l),d1		; an dieser Stelle schon benutzt?
	beq.s	11$
	tst.b	LibUnit(a4)		; bei Objects prüfen ob Sym. doppelt
	beq.s	1$
10$:	move.l	d1,a3			; ohne Vergleich bis zum Ende der
	move.l	NextXdef(a3),d1		;  Hash-Chain wandern
	bne.s	10$
	bra.s	4$
11$:	lea	(a0,d0.l),a3
	bra.s	4$
1$:	move.l	d1,a3			; Hash Chain durchgehen...
	move.l	XdefPtr(a3),a1		; Symbol Namen vergleichen
	move.l	(a1)+,d0
	subq.w	#1,d0
	cmp.w	d6,d0			; dieselbe Länge?
	bne.s	3$
	move.l	a2,a0
2$:	cmpm.l	(a0)+,(a1)+
	dbne	d0,2$
	bne.s	3$
	move.l	sp,a6			; Multiple defined Symbol!
	clr.l	-(sp)
	move.w	d6,d0
	move.w	d0,d1
	lsl.w	#2,d0
	lea	4(a2,d0.w),a0
20$:	move.l	-(a0),-(sp)		; Symbolname auf den Stack
	dbf	d1,20$
	move.l	sp,-(sp)
	move.l	sp,a1
	LOCS	31
	bsr	printf			; Fehlermeldung ausgeben
	move.l	a6,sp
3$:	move.l	NextXdef(a3),d1
	bne.s	1$
4$:	move.l	SysBase(a4),a6		; Neue XDEF-Node ans Ende der
	moveq	#XdefSIZE,d0		;  Hash-Chain hängen
	bsr	mAlloc
	move.l	d0,NextXdef(a3)
	beq	OutOfMemory
	move.l	d0,a0
	clr.l	(a0)+
	move.l	d4,(a0)+
	move.l	d5,(a0)+		; XdefSec
	subq.l	#4,a2
	move.l	a2,(a0)
9$:	movem.l	(sp)+,d2-d3/d6/a3/a6
	rts


	cnop	0,4
AddXREF:
; a6 = HunkPtr, a2 = XrefPtr
	move.l	a6,-(sp)
	move.l	SysBase(a4),a6
	moveq	#XrefSIZE,d0
	bsr	mAlloc
	tst.l	d0
	beq	OutOfMemory
	move.l	d0,a0
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	(sp),(a0)+
	move.l	a2,(a0)
	move.l	lastXREF(a4),a0
	move.l	d0,(a0)
	move.l	d0,lastXREF(a4)
	move.l	(sp)+,a6
	rts


HunkError:
	move.l	ActiveUnit(a4),a1
	move.l	U_ObjName(a1),-(sp)
	move.l	U_Name(a1),-(sp)
	pea	SecName(a4)
	move.l	sp,a1
	bsr	printf
	bra	exit


	cnop	0,4
NewHunk:
; Neuen Hunk in der Hunkliste der Section anhängen
; a5 = FilePtr
; a0 = Section, d0 = HunkDataSize
	movem.l	a2-a3/a6/d4-d7,-(sp)
	move.l	SysBase(a4),a6
	move.l	d0,d2			; d2 DataSize
	move.l	a0,a3			; a3 Section struct
	add.l	d2,SecSize(a3)
	moveq	#0,d4
	move.w	SectionID+2(a3),d4	; d4 SecID
	move.l	#HunkSIZE,d0
	bsr	mAlloc_Clear		; Speicher fuer Hunk-Struktur
	tst.l	d0
	beq	OutOfMemory
	move.l	d0,a2			; a2 Hunk-Struktur
	lea	HunkList(a3),a0
	move.l	a2,a1
	jsr	AddTail(a6)		; Hunk in Liste aufnehmen
	move.l	ActiveUnit(a4),UnitStruct(a2)
	move.l	a3,HunkSection(a2)
	move.l	d2,DataSize(a2)
	beq.s	next_HunkSeg
	cmp.w	#HUNK_BSS,Type+2(a3)	; BSS-Hunks haben keinen Inhalt
	beq.s	next_HunkSeg
	move.l	a5,HunkData(a2)
	add.l	d2,a5			; FP auf nächsten Hunk-Block

next_HunkSeg:
	move.l	(a5)+,d0
	cmp.w	#HUNK_DREL16,d0
	bhi.s	2$
	sub.w	#HUNK_RELOC32,d0
	bmi.s	2$
	add.w	d0,d0
	add.w	d0,d0
	jmp	3$(pc,d0.w)
1$:	LOCS	36			; Hunk cannot contain another hunk
	bra	HunkError
2$:	LOCS	37			; Unknown hunk type in hunk..
	bra	HunkError
3$:	jmp	ReadReloc32(pc)		; 3ec
	jmp	ReadReloc16(pc)		; 3ed
	jmp	ReadReloc8(pc)		; 3ee
	jmp	ReadExt(pc)		; 3ef
	jmp	ReadSymbol(pc)		; 3f0
	jmp	ReadDebug(pc)		; 3f1
	jmp	StoreInfo(pc)		; 3f2
	jmp	1$(pc)			; 3f3
	jmp	1$(pc)			; 3f4
	jmp	2$(pc)			; 3f5
	jmp	2$(pc)			; 3f6
	jmp	1$(pc)			; 3f7
	jmp	ReadNearReloc(pc)	; 3f8


DoubleHunkBlk:
	LOCS	38			; Hunk block appeared twice
	bra	HunkError

	cnop	0,4
StoreInfo:
	moveq	#0,d0
	move.w	HunkCnt(a4),d0
	cmp.w	HunksPerUnit(a4),d0	; zu viele Hunks in der Unit ?
	blo.s	1$
	LOCS	39			; Too many hunks in unit..
	bra	UnitError
1$:	lsl.l	#3,d0
	move.l	UnitInfo(a4),a0
	add.l	d0,a0
	move.l	a2,(a0)+		; Unit-Hunk Pointer
	move.l	a3,(a0)+		; zugehöriger Section Pointer
	addq.w	#1,HunkCnt(a4)
	movem.l	(sp)+,a2-a3/a6/d4-d7
	rts

	cnop	0,4
ReadNearReloc:
	tst.l	HunkNearReloc(a2)
	bne	DoubleHunkBlk
	move.l	a5,HunkNearReloc(a2)
	bra.s	readrelocblock

	cnop	0,4
ReadReloc8:
	tst.l	HunkReloc8(a2)
	bne	DoubleHunkBlk
	move.l	a5,HunkReloc8(a2)
	bra.s	readrelocblock

	cnop	0,4
ReadReloc16:
	tst.l	HunkReloc16(a2)
	bne	DoubleHunkBlk
	move.l	a5,HunkReloc16(a2)
	bra.s	readrelocblock

	cnop	0,4
ReadReloc32:
	tst.l	HunkReloc32(a2)
	bne	DoubleHunkBlk
	move.l	a5,HunkReloc32(a2)
readrelocblock:
	move.l	(a5)+,d0		; Reloc-Block überlesen
	beq.s	1$
	addq.l	#4,a5
	lsl.l	#2,d0
	add.l	d0,a5
	bra.s	readrelocblock
1$:	bra	next_HunkSeg

	cnop	0,4
ReadExt:
	tst.l	HunkExtern(a2)
	bne	DoubleHunkBlk
	move.l	a5,HunkExtern(a2)
	move.l	#$00ffffff,d2
1$:	move.l	(a5)+,d0
	move.l	d0,d1
	beq	next_HunkSeg
	bpl.s	2$
	and.l	d2,d0			; xref-Symbol übergehen
	lsl.l	#2,d0
	add.l	d0,a5
	move.l	(a5)+,d0
	lsl.l	#2,d0
	add.l	d0,a5
	bra.s	1$
2$:	and.l	d2,d0			; xdef-Symbol übergehen
	lsl.l	#2,d0
	lea	4(a5,d0.l),a5
	bra.s	1$

	cnop	0,4
ReadSymbol:
	tst.b	NoDebug(a4)
	bne.s	1$
	tst.l	HunkSymbol(a2)
	bne	DoubleHunkBlk
	move.l	a5,HunkSymbol(a2)
1$:	move.l	(a5)+,d0
	beq	next_HunkSeg
	lsl.l	#2,d0
	add.l	d0,a5
	addq.l	#4,a5
	bra.s	1$

	cnop	0,4
ReadDebug:
	move.l	(a5)+,d2		; Größe des Blocks
	lsl.l	#2,d2
	tst.b	NoDebug(a4)
	bne.s	1$
	move.l	a3,-(sp)
	lea	HunkDebug(a2),a0	; einfach verkettete Liste, hier sind
	move.l	a0,d0			; mehrere Blöcke pro Hunk erlaubt
2$:	move.l	d0,a3
	move.l	(a3),d0
	bne.s	2$
	moveq	#8,d0
	bsr	mAlloc_Clear		; neue HunkDebug-Node (*next,*hunk)
	move.l	d0,(a3)			; einhängen
	beq	OutOfMemory
	move.l	d0,a0
	move.l	a5,4(a0)		; Zeiger auf HunkBlock speichern
	move.l	(sp)+,a3
1$:	add.l	d2,a5
	bra	next_HunkSeg


	cnop	0,4
GetSection:
; a0 = SectionList
; a5 = Zeiger auf Hunk-Type
; Section mit Name in SecName in der Liste suchen
; -> a0 = SectionPtr
	movem.l	a2/a6,-(sp)
	move.l	SysBase(a4),a6
	move.l	a0,a2
1$:	move.l	(a2),d0			; Next Section
	bne.s	3$
	move.l	#SectionSIZE,d0		; keine mit diesem Namen da, neue einrichten
	bsr	mAlloc_Clear
	move.l	d0,(a2)			; NextSection setzen
	beq	OutOfMemory
	move.l	d0,a2
	move.w	IDCnt(a4),SectionID+2(a2) ; Nummer der Section
	addq.w	#1,IDCnt(a4)
	move.w	#SecNameSIZE-1,d0
	lea	SecName(a4),a0
	lea	SectionName(a2),a1
2$:	move.b	(a0)+,(a1)+		; Name eintragen
	dbf	d0,2$
	lea	HunkList(a2),a0		; Liste initialisieren
	move.l	a0,(a0)
	addq.l	#4,(a0)
	move.l	a0,8(a0)
	move.l	(a5),Type(a2)		; Hunk-Type setzen
	bra.s	9$
3$:	move.l	d0,a2			; a2 Section
	move.w	#SecNameSIZE-1,d0
	lea	SecName(a4),a0
	lea	SectionName(a2),a1
4$:	cmpm.b	(a0)+,(a1)+
	dbne	d0,4$
	bne.s	1$			; falscher Name, nächste Section
	move.l	Type(a2),d0
	cmp.l	(a5),d0			; stimmt der Hunk-Type auch überein?
	bne.s	1$
9$:	move.l	a2,a0
	movem.l	(sp)+,a2/a6
	rts


	cnop	0,4
CheckExtension:
; a0 = FileName
; -> d0 = 0 wenn Object oder -1 wenn Library
	move.l	a0,ObjName(a4)
	moveq	#'.',d1
	sub.l	a1,a1
1$:	move.b	(a0)+,d0
	bne.s	2$
	move.l	a1,d0
	bne.s	5$
4$:	LOCS	42			; Illegal extension..
	bra	Error
2$:	cmp.b	d1,d0
	bne.s	1$
	move.l	a0,a1
	bra.s	1$
5$:	move.b	(a1),d0
	and.b	#$df,d0
	cmp.b	#'O',d0
	bne.s	3$
	moveq	#0,d0
	rts
3$:	cmp.b	#'L',d0
	bne.s	4$
	moveq	#-1,d0
	rts


	cnop	0,4
LocStr:
; d0 = Local String ID
; -> a0 = Zeiger auf String (Default oder in voreingestellter Landessprache)
	movem.l	d1/a1/a6,-(sp)
	lea	DefStringBase(a4),a0	; Zeiger auf englischen Default-String holen
	move.w	d0,d1
	beq.s	2$
1$:	tst.b	(a0)+
	bne.s	1$
	subq.w	#1,d1
	bne.s	1$
2$:	move.l	Catalog(a4),d1		; Locale-Catalog vorhanden?
	beq.s	3$
	move.l	LocaleBase(a4),a6
	move.l	a0,a1
	move.l	d1,a0
	ext.l	d0
	jsr	GetCatalogStr(a6)	; Landesspezifischen String lesen
	move.l	d0,a0
3$:	movem.l	(sp)+,d1/a1/a6
	rts


;vb:	mAlloc	a4:SmallDataPointer d0:Size in Bytes
;vb:	falls V39 gesetzt, muss SysBase in a6 sein
;vb:	memAttr==MEMF_CLEAR
;vb:	Evtl. noch etwas schneller, wenn man die Pools mit memAttr==0
;vb:	erzeugt und nur mAlloc_Clear den Speicher loescht - lohnt aber
;vb:	vermutlich den Aufwand nicht

	ifd	V39
mAlloc:
mAlloc_Clear:
	move.l	Pool(a4),a0
	jmp	AllocPooled(a6)		; implizites rts


	else
mAlloc:
mAlloc_Clear:
	move.l	d0,-(a7)
	move.l	Pool(a4),-(a7)
	jsr	_LibAllocPooled
	addq.w	#8,a7
	rts

	endc



	section	"__MERGED",data


lastXREF:
	dc.l	XREFList		; Zeiger auf letzten Listeneintrag

LinkerUnit:
	dcb.b	20
	dc.l	LnkName,LnkName
LnkName:
	dc.b	"PhxLnk",0,0

pdatbas_def:
	dc.l	$01000003		; PhxAss Compatible
	dc.b	"_DATA_BAS_",0,0
	dc.l	0
pdatlen_def:
	dc.l	$02000003
	dc.b	"_DATA_LEN_",0,0
pdatlen_val:
	dc.l	0			; Data-Länge in Bytes
pbsslen_def:
	dc.l	$02000003
	dc.b	"_BSS_LEN_",0,0,0
pbsslen_val:
	dc.l	0			; Bss-Länge in Bytes
pcodlen_def:
	dc.l	$02000003
	dc.b	"_CODE_LEN_",0,0
pcodlen_val:
	dc.l	0			; Code-Länge in Bytes
psdlen_def:
	dc.l	$02000004
	dc.b	"_SMALL_DATA_LEN_"
psdlen_val:
	dc.l	0			; Länge des Small-Data Bereichs

ldatbas_def:
	dc.l	$01000003		; Lattice/SAS Compatible
	dc.b	"_LinkerDB",0,0,0
SDOffset:
	dc.l	$7ffe			; dies ist NICHT die DataBase wie bei BLink (Vorsicht!)
lbssbas_def:
	dc.l	$01000002
	dc.b	"__BSSBAS"
lbssbas_val:
	dc.l	0
lbsslen_def:
	dc.l	$02000002
	dc.b	"__BSSLEN"
lbsslen_val:
	dc.l	0			; Bss-Länge in Longwords
lctors_def:
	dc.l	$02000002
	dc.b	"__ctors",0
	dc.l	0			; immer 0
ldtors_def:
	dc.l	$02000002
	dc.b	"__dtors",0
	dc.l	0			; immer 0

ddatbas_def:
	dc.l	$01000003		; DICE Compatible
	dc.b	"__DATA_BAS",0,0
	dc.l	0
ddatlen_def:
	dc.l	$02000003
	dc.b	"__DATA_LEN",0,0
ddatlen_val:
	dc.l	0			; Data-Länge in Longwords
dbsslen_def:
	dc.l	$02000003
	dc.b	"__BSS_LEN",0,0,0
dbsslen_val:
	dc.l	0			; Bss-Länge in Longwords
dresdnt_def:
	dc.l	$02000003
	dc.b	"__RESIDENT",0,0
	dc.l	0			; immer 0
phxlnk_def:
	dc.l	$02000002
	dc.b	"__PhxLnk"
	dc.l	(VERSION<<16)|REVISION	; Version im Hi-Word, Rev. im Low-W.

bioBufSize:
	dc.l	DEF_BUFSIZE		; Buffergröße für Buffered I/O
HashTabSize:	
	dc.l	DEF_HASHTABSIZE		; Zahl der Einträge in der HashTab
HunksPerUnit:
	dc.w	DEF_SECPERUNIT		; Max. Anzahl Sections pro Unit

DefStringBase:				; Alle englischen Default-Strings
	dc.b	"\nPhxLnk Amiga DOS Linker V%d.%02d"
	ifd	ALPHA
	dc.b	" alpha"
	endc
	ifd	BETA
	dc.b	'ß'
	endc
	ifd	V39
	dc.b	" (OS3.x)\n"
	else
	dc.b	" (OS2.x)\n"
	endc
	dc.b	"Copyright 1992-98 by Frank Wille and Volker Barthelmann\n\n"
	dc.b	"Description of parameters:\n"
	dc.b	"  FROM/M\t\tObject and library modules to link\n"
	dc.b	"  TO/K\t\t\tOutput file\n"
	dc.b	"  SC=SMALLCODE/S\tCoalesce code sections\n"
	dc.b	"  SD=SMALLDATA/S\tCoalesce data and bss sections\n"
	dc.b	"  ND=NODEBUG/S\t\tIgnore Debugger informations\n"
	dc.b	"  PV=PVCOMPAT/S \tPowerVisor compatible DEBUG blocks\n"
	dc.b	"  CHIP/S\t\tForce all sections into Chip RAM\n"
	dc.b	"  PRESERVE/S\t\tPreserve empty sections\n"
	dc.b	"  B=BLINKCOMPAT/S\tBLink compatible small data offsets\n"
	dc.b	"  K1=KICK1/S\t\tKickstart 1.x compatibility\n"
	dc.b	"  MAXSECTS/K/N\t\tMaximum number of sections per unit (default %d)\n"
	dc.b	"  NOSHORTRELOCS/S\tDon't try to use RELOC32SHORT\n"
	dc.b	"  DONTSHORTENSECT/S\tDon't kill zero words at end of section\n"
	dc.b	"  DEF=DEFINE/K\t\tDefine symbol\n"
	dc.b	0
	dc.b	0,0,0,0

	dc.b	"Minimum of three sections per unit required.\n\0" *05*
	dc.b	"Unable to resolve user definition for \"%s\".\n\0"
	dc.b	0,0,0

	dc.b	0,0
	dc.b	"Object module \"%s\" not found !\n\0" *12*
	dc.b	"Library module \"%s\" not found !\n\0"
	dc.b	0

	dc.b	"Missing HUNK_UNIT or HUNK_LIB in \"%s\" !\n\0" *15*
	dc.b	"Unable to write load file !\n\0"
	dc.b	0,0,0

	dc.b	"HUNK_LIB without HUNK_INDEX in \"%s\" !\n\0" *20*
	dc.b	"HUNK_LIB in \"%s\" contains an unknown hunk block!\n\0"
	dc.b	"HUNK_RELOC must not appear after HUNK_EXT in \"%s\" !\n\0"
	dc.b	0

	dc.b	"Small Data addressing impossible in unit \"%s\" of \"%s\" !\n" *24*
	dc.b	"Section size exceeded 64k.\n\0"
	dc.b	"Unknown XDEF type in unit \"%s\" of \"%s\"
	dc.b	"(only ext_def and ext_abs are supported) !\n\0"
	dc.b	"Unknown XREF type in unit \"%s\" of \"%s\" !\n\0"
	dc.b	"Unit \"%s\" of file \"%s\" :\n"
	dc.b	"No relative addressing between different sections!\n\0"
	dc.b	"Relative out of range in unit \"%s\" of \"%s\" !\n\0"
	dc.b	"8-Bit relative addressing is impossible (Unit \"%s\" of \"%s\")!\n\0"
	dc.b	"At Offset $%08lx:\n\0"
	dc.b	"Multiple defined symbol: \"%s\"\n\0"

	dc.b	"Undefined Symbols\tHunk\t\tUnit\t\tFile\n\0" *32*
	dc.b	0

	dc.b	"Out of memory error !\n\0" *34*
	dc.b	"Unknown section type in unit \"%s\" of \"%s\" !\n\0"
	dc.b	"Hunk \"%s\" cannot contain another hunk or unit\n"
	dc.b	"in unit \"%s\" of \"%s\" !\n\0"
	dc.b	"Unknown hunk type in hunk \"%s\"\n"
	dc.b	"(Unit \"%s\" of \"%s\") !\n\0"
	dc.b	"Hunk block appeared twice in hunk \"%s\"\n"
	dc.b	"(Unit \"%s\" of \"%s\") !\n\0"
	dc.b	"Too many hunks in unit \"%s\" of \"%s\" !\n"
	dc.b	"Use MAXSECTS to resize buffer.\n\0"

	dc.b	"Read error while reading \"%s\" !\n\0" *40*
	dc.b	"Unexpected end of file in \"%s\" !\n\0"

	dc.b	"Illegal file name extension in \"%s\" (try .o, .obj or .lib)!\n\0" *42*
	dc.b	"Too many offsets for RELOC32SHORT! Set NOSHORTRELOCS switch.\n\0"

	even
alvec:
	dc.w	$4ef9			; JMP
	dc.l	0			; vector



	section	"__MERGED",bss


SysBase:	ds.l	1		; exec.library
DOSBase:	ds.l	1		; dos.library
LocaleBase:	ds.l	1		; locale.library
Locale:		ds.l	1
Catalog:	ds.l	1
ExitSP:		ds.l	1
argv:		ds.l	NTEMPLATES	; Argument Vector für ReadArgs()
rdargs:		ds.l	1
this_task:	ds.l	1
NameBuffer:	ds.b	MAXNAMELEN
SecName:	ds.b	MAXNAMELEN	; Name der aktuellen Section
SmallCode:	ds.b	1		; Optionen
SmallData:	ds.b	1
NoDebug:	ds.b	1
HunksToChip:	ds.b	1
RemEmpty:	ds.b	1
PVcompat:	ds.b	1
BLinkCompat:	ds.b	1		; Bei SD <32k Offset 0 wählen (wie BLink)
NoShortRelocs:	ds.b	1		; Keine RELOC32SHORT Hunks erzeugen
NoShortenSects:	ds.b	1		; Null-Bytes am Ende nicht entfernen
GenALVs:	ds.b	1		; ALVs erzeugen, wenn nötig
ReturnCode:	ds.b	1		; CLI Return-Code
LibUnit:	ds.b	1		; true: Unit ist Teil einer Library
		cnop	0,4
ObjName:	ds.l	1		; Name des aktuellen Object Files
OutName:	ds.l	1		; Name des zu erzeugenden Files
Objects:	ds.l	1		; 0:Next Object, 4:Size, 8:Object-File..,PHX!
CodeSections:	ds.l	1		; Header fuer Code,Data,BSS-Section Lists
DataSections:	ds.l	1
BssSections:	ds.l	1
mergedData:	ds.l	1		; Zeiger auf __MERGED-Data/Bss (oder Null)
mergedBss:	ds.l	1
Units:		ds.l	1		; Unit-Liste
ActiveUnit:	ds.l	1
IDCnt:		ds.w	1		; ID für nächste, neue, Section
HunkCnt:	ds.w	1		; Zählt die Hunks einer Unit
HashTabMask:	ds.w	1		; HashTabSize-1 & $ffff
		cnop	0,4
XDEFHashTab:	ds.l	1		; XDEF Hash-Table
XREFList:	ds.l	1		; XREF Liste
UnitInfo:	ds.l	1		; enthält HunkPtr,SecNum
RelDefList:	ds.l	1		; Liste für relocatible User-Defines
pdatbas_sec:	ds.l	1		; XdefSec der Linker-XDEFs
ldatbas_sec:	ds.l	1
lbssbas_sec:	ds.l	1
ddatbas_sec:	ds.l	1

;vb:
Pool:		ds.l	1		; Adresse des MemPools

;vb: _SysBase fuer amiga.lib exportieren
		ifnd	V39
		xdef	_SysBase
_SysBase 	equ	SysBase
		endc

	end
