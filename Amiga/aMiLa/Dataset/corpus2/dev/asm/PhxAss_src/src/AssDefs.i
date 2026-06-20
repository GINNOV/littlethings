; $VER: AssDefs.i 4.46 (14.10.14)
; **********************************************
;
;             PhxAss Macro Assembler
;
;        Written by Frank Wille, 1991-2014
;
;    Structures, Defines and global Variables
;
; **********************************************

; Das SET-Symbol GIGALINES erzeugt den Assembler fuer 4 Mrd. Zeilen
GIGALINES	SET	1	; ist seit V4.40 immer gesetzt!

; Das SET-Symbol FREEASS erzeugt eine Freeware-Version von PhxAss, die
;  z.B. von anderen Autoren für PD-Compiler benutzt werden kann

; Das SET-Symbol SMALLASS erzeugt eine Version die nur die 68000er
;  Instruktionen kennt


VERSION  = 4
REVISION = 46

 macro DATESTRING
 dc.b "(14.10.2014)"
 endm


;**** OS ****

	include "lib/exec.i"
	include "lib/dos.i"
	include "lib/utility.i"
	include "lib/mathtrans.i"
	include "lib/mathieeedoubbas.i"
	include "lib/mathieeedoubtrans.i"
	include "lib/locale.i"
	include "lib/timer.i"

	include "exec/execbase.i"
	include "exec/io.i"
	include "exec/memory.i"
	include "exec/tasks.i"
	include "dos/dosextens.i"
	include "dos/doshunks.i"
	include "dos/rdargs.i"
	include "utility/date.i"
	include "libraries/locale.i"
	include "devices/timer.i"
	include "devices/trackdisk.i"


;****  Debugging  ****

	macro	DB	; string,val1,val,val3,val4
	bra.b	\@do$
\@dbstr$:
	dc.b	\1
	dc.b	0
	even
\@do$:
	movem.l	d0-d7/a0-a4/a6,-(sp)
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	DosBase(a5),a6
	move.l	#\@dbstr$,d1
	move.l	sp,d2
	jsr	VPrintf(a6)
	add.w	#16,sp
	movem.l	(sp)+,d0-d7/a0-a4/a6
	endm


;****  Wichtigste Strukturen  ****

; SecList beinhaltet die Zeiger auf alle definierten Sections des Units
 rsreset
secl_Link	rs.l 1
secl_FreeEntry	rs.l 1		; naechster freier Eintrag in der SecList
secl_HEAD	rs
secl_Section	rs		; [SECLISTBLK/4] Zeiger auf Sections
seclSIZE	= 4

; Section verwaltet ein ganzes Code/Data/BSS-Segment mit allen noetigen Hunks
 rsreset
sec_Name	rs.l 1		; Name der Section
sec_Type	rs.l 1		; $3e9=code, $3ea=data, $400003eb=BSS-ChipRAM
sec_Flags	rs.b 1		; Optimierungs-Flags (dosFile: Sect.Nummern)
sec_Near	rs.b 1		; TRUE: Sect. läßt sich Near adressieren
 ifnd  GIGALINES
sec_DeclLine	rs.w 1		; Ab hier wurde die Section zum 1.mal benutzt
 else
sec_DeclLine	rs.l 1
		rs.w 1
 endc
sec_Size	rs.l 1		; Groesse des Code/Data/BSS-Hunks
sec_Origin	rs.l 1		; BasisAdr.(bei reloc.Code = 0)
sec_CurrentAdr	rs.l 1		; Addresse fuer die naechsten Daten
sec_Destination rs.l 1		; fuer absoluten Code (Adr.,File oder Block)
sec_HunkData	rs.l 1		; Dies ist der Hunk-Inhalt als Chunk
sec_HunkDataPt	rs.l 1		; ab hier wird weiterer Hunk-Inhalt angefuegt
sec_FreeData	rs.l 1		; freie Bytes im aktuellen Data-Chunk
sec_HunkReloc	rs.l 1		; Zeiger auf HunkReloc-Struct
sec_HunkNearReloc rs.l 1	; NearRelocs fuer Near-Data Model
sec_HunkExtTable rs.l 1 	; Tabelle der External-Symbols
sec_HETPt	rs.l 1		; hier wird das naechste ext.Symbol angefuegt
sec_HunkSymbolTable rs.l 1	; Tabelle aller Hunk-Symbols (fuer Debug)
sec_HSTPt	rs.l 1		; hier wird der Pt. auf naechstes Sym. angef.
sec_Distances	rs.l 1		; Zeiger auf ersten DistanceList-Chunk
sec_DistChunk	rs.l 1		; Zeiger auf aktuellen DistanceList-Chunk
sec_LastCnop	rs.l 1		; Letzte Adr. an der ein CNOP wirkte
sec_HunkLineDebug rs.l 1	; Zeiger auf ersten Hunk-Debug (Line) Chunk
SectionSIZE	rs
of_Normal      = 0		; Optimierungs-Flags fuer jede Section
of_Relative    = 1
of_Quick       = 2
of_Branches    = 3
of_Shifts      = 4
of_PeaLea      = 5
of_Special     = 6
of_MoveM       = 7

; HunkData enthaelt den Section-Inhalt (Code oder Data) als gelinkte Liste
 rsreset
hd_Link 	rs.l 1		; nächster Chunk
hd_HEAD 	rs
hd_Data 	rs		; Daten [HUNKDATBLK]

; HunkExtTable enthält Zeiger auf die externen Symbole dieser Section
 rsreset
hext_Link	rs.l 1		; nächster Chunk
hext_HEAD	rs
hext_Symbol	rs.l 1		; Zeiger auf externe Symbole [HEXTTABBLK/4]
hextSIZE	= 4

; HunkSymbolTable enthält Zeiger auf in dieser Section vorkommenden Symbole
 rsreset
hsym_Link	rs.l 1		; nächster Chunk
hsym_HEAD	rs
hsym_Symbol	rs.l 1		; Zeiger auf Section-Symbols [HSYMTABBLK/4]
hsymSIZE	= 4

; HunkReloc enthält Offsets auf die relocatiblen Adressen in dieser Section
; mit dem zugehörigen Bezugs-Hunk
 rsreset
hrel_Link	rs.l 1		; nächster Chunk
hrel_Entries	rs.w 1		; Zahl der Einträge in dieser Tabelle
hrel_HEAD	rs
hrel_Offset	rs.l 1		; zu ändernde Prg.stelle in diesem Hunk
hrel_HunkNum	rs.w 1		; BasisAdr. dieses Hunks addieren
hrelSIZE	= 6

; DistanceList enthält alle in dieser Section vorkommende ABS-Distanzen,
; sowie deren Breite (byte,word,long) und Adresse
 rsreset
dist_Link	rs.l 1
dist_FreeEntry	rs.l 1
dist_HEAD	rs
dist_Minuend	rs.l 1		; ABSMinuend - ABSSubtrahend
dist_Subtrahend rs.l 1
dist_Addr	rs.l 1		; Adresse an der die Distanz streht
dist_Width	rs.b 1		; 8, 16 oder 32 bit, negativ: EQU-Distanz mit
dist_Info	rs.b 1		; Bit7:static subtrahend, Bit6: Bcc.S subtrah.
				; Bit5-0:distance-shift
dist_HunkNum	rs.w 1		; Hunk auf den sich Addr bezieht
dist_ListFilePointer rs.l 1	; zu aendernde Pos. im Listing File
distSIZE	= 20

; SymbolTable enthält alle im Programm definierten Symbole
; Es gibt nur diese eine globale SymbolTable
 rsreset
stab_Link	rs.l 1		; Zeiger auf Folge-Hunk
stab_FreeEntry	rs.l 1
stab_NumSymbols rs.w 1		; hiernach folgen [SYMBOLBLK/SymbolSIZE] Bytes
 ifnd  GIGALINES
stab_pad	rs.b 18
 endc
stab_HEAD	rs		; für mehrere Symbol-Strukturen

; LocalSymbolTable kann mehrmals existieren und enthält die LocalSymbols in
; einem 'Part' zwischen zwei Global-Symbol-Deklarationen
 rsreset
lstab_Link	rs.l 1		; Zeiger auf Folge-Hunk
lstab_FreeEntry rs.l 1
lstab_NumSymbols rs.w 1
lstab_DeclHunk	rs.w 1		; hiernach folgen [LOCSYMBLK/SymbolSIZE] Bytes
 ifnd  GIGALINES
lstab_pad	rs.b 4
 else
lstab_pad	rs.b 2
 endc
lstab_HEAD	rs		; für mehrere Symbol-Strukturen

; LocalParts enthält Zeiger auf die LocalSymbolTable die zwischen den Zeilen
; StartLine und EndLine gilt
 rsreset
lp_Link 	rs.l 1
lp_NumParts	rs.w 1		; Zahl der Einträge in diesem Chunk
 ifnd  GIGALINES
lp_pad		rs.b 2
lp_HEAD 	rs
 else
lp_pad		rs.b 10
lp_HEAD 	rs
 endc
; LocalPart Struktur
 rsreset
 ifnd  GIGALINES
lp_StartLine	rs.w 1
lp_EndLine	rs.w 1
lp_SymTab	rs.l 1
lp_HashTab	rs.l 1
lp_LocRegNames	rs.l 1
lpSIZE		= 16
 else
lp_StartLine	rs.l 1
lp_EndLine	rs.l 1
lp_SymTab	rs.l 1
lp_HashTab	rs.l 1
lp_LocRegNames	rs.l 1
lpSIZE		= 20
 endc

; Symbol (die wohl wichtigste Struktur des Assemblers)
 rsreset
sym_Next	rs.l 1		; nächstes Symbol in der Hash-Chain
sym_Name	rs.l 1		; Name des Symbols
 ifnd  GIGALINES
sym_DeclLine	rs.w 1		; Zeile, in der das Symbol deklariert wurde
 else
sym_DeclLine	rs.l 1
 endc
sym_Type	rs.w 1		; Typ (EQU,ABS,MACRO,etc. und XDEF,XREF,etc.)
sym_Value	rs.l 1		; Wert des Symbols
sym_RefList	rs.l 1		; Tabelle der Symbol-Referenzen
SymbolSIZE	rs

; Macro zum Berechnen des Hashcodes für globale und lokale Symbole
; Es wird garantiert, daß der der NamePtr hiernach hinter der 0 steht!
 macro	 HASHC			; \1=NamePtr, \2=HashCode, \3,\4=Scratch
 moveq	 #0,\2
 moveq	 #0,\3
 bra.b	 \@2$
\@1$:
 move.w	 \2,\4			; bisheriger Hashcode * 3 + Buchstabe
 add.w	 \2,\2
 add.w	 \4,\2
 add.w	 \3,\2
\@2$:
 move.b	 (\1)+,\3		; noch ein Buchstabe?
 bne.b	 \@1$
 endm

; ReferenceList beinhaltet sämtliche Referenzen auf ein Symbol
 rsreset
rlist_Link	rs.l 1
rlist_NumRefs	rs.w 1		; Zahl der in diesem Chunk eingetr. Ref.
rlist_DeclHunk	rs.w 1		; Hunk in dem das Symbol deklariert wurde
 ifd   GIGALINES
rlist_pad	rs.w 1
 endc
rlist_HEAD	rs
rlist_Hunk	rs.b 1		; Referenz-Hunk
rlist_Type	rs.b 1		; Groesse (EXT_REF8-EXT_REF32)
 ifnd  GIGALINES
rlist_Line	rs.w 1		; Zeilennr. der Referenz
rlist_RelAdr	rs.l 1		; Adresse relativ zum Ref.-Hunk-Start
rlistSIZE	= 8
 else
rlist_Line	rs.l 1		; Zeilennr. der Referenz
rlist_RelAdr	rs.l 1		; Adresse relativ zum Ref.-Hunk-Start
rlistSIZE	= 10
 endc

; RefListBlock beinhaltet mehrere ReferenceList-Strukturen
 rsreset
rlblk_Link	rs.l 1
rlblk_FreeEntry rs.l 1
rlblk_HEAD	rs		; ab hier folgende mehrere ReferenceLists

; RegRefList enthält alle Register-Symbol Referenzen
 rsreset
rrl_Link	rs.l 1
 ifnd  GIGALINES
rrl_DeclLine	rs.w 1
 else
rrl_DeclLine	rs.l 1
 endc
rrl_NumRefs	rs.w 1
rrl_HEAD	rs
; hier folgen die Zeilennummern der Referenzen als UWORD-Eintraege
 ifnd  GIGALINES
rrlSIZE 	= 2
 else
rrlSIZE 	= 4
 endc

; StringBuffer enthaelt alle Strings, wie FileNames oder SymbolNames, die
; waehrend der Assemblierung anfallen
 rsreset
sb_Link 	rs.l 1
sb_Free 	rs.l 1		; Anzahl der unbelegten Chars. in diesem Chunk
sb_HEAD 	rs
sb_Buffer	rs		; Strings

; StringTable enthaelt mehrere Zeiger auf den StringBuffer. Eine solche Struktur
; wird zum Beispiel benoetigt fuer die Liste der Include-Files oder der
; Include-Directories
 rsreset
strt_Link	rs.l 1
strt_HEAD	rs
strt_String	rs.l 1		; Zeiger auf StringBuffer
strtSIZE	= 4

; IncludeList enthaelt den Zeiger auf den Source-Code aller nacheinander
; eingebundenen Includes
 rsreset
incl_Link	rs.l 1
incl_FreeEntry	rs.l 1
incl_pad	rs.l 1
incl_HEAD	rs
incl_Text	rs.l 1		; Include-SourceCode
incl_Size	rs.l 1		; Groesse (um Speicher wieder freizugeben)
incl_Name	rs.l 1		; Name des Include-Files
inclSIZE	= 12

; MacParameter enthält die Macro-Parameter für jede Macro-Verschachtelung-
; tiefe
 rsreset
mpar_Link	rs.l 1
mpar_HEAD	rs
mpar_LastNARG	rs.l 1		; übergeordnetes NARG
mpar_LastCARG	rs.l 1		; übergeordnetes CARG
mpar_LastLabel	rs.l 1		; /@-Label des übergeordneten Macros
mpar_Params	rs		; jeder Parameter (36 Stk.) belegt 128 Bytes
MACPARSIZE	= 127		; Speicherplatz fuer einen Macro-Parameter
MAXMACPAR	= 35		; Max. Anzahl Macro-Parameter (ohne \0)
MACDEPTHSIZE	= mpar_Params-mpar_HEAD+(MAXMACPAR+1)*(MACPARSIZE+1)

; NestList enthält bei Include oder Macro-Verschachtelungen die Zeiger
; auf die uebergeordneten Source-Codes
 rsreset
nl_Link 	rs.l 1
nl_FreeEntry	rs.l 1
nl_Nest 	rs.w 1		; aktuelle Macro-Verschachtelungstiefe
nl_pad		rs.b 6
nl_HEAD 	rs
nl_SrcText	rs.l 1
nl_SrcLen	rs.l 1
 ifnd  GIGALINES
nl_Line 	rs.w 1
 else
nl_Line 	rs.l 1
 endc
nl_AssMode	rs.b 1
nl_ReptDepth	rs.b 1
nl_Name 	rs.l 1
 ifnd  GIGALINES
nlSIZE		= 16
 else
nlSIZE		= 18
 endc


; CNOPTab enthaelt den in Pass1 ermittelten Speicherbedarf aller CNOP-
; Directiven als Longwords.
 rsreset
ctab_Link	rs.l 1
ctab_End	rs.l 1
ctab_HEAD	rs

; RepTab enthält die Daten der REPT ... ENDR Verschachtelungen
 rsreset
reptab_Link	rs.l 1
reptab_Ptr	rs.l 1		; freier Slot in diesem Chunk (oder 0)
reptab_HEAD	rs
 rsreset
reptab_Len	rs.l 1		; Verbleibende SrcTxt-Länge (d7)
reptab_Text	rs.l 1		; Beginn der REPT-Schleife im Sourcetext (a4)
reptab_Cnt	rs.l 1		; aktueller Wert des Schleifenzählers
 ifnd GIGALINES
reptab_Line	rs.w 1		; Zeilennummer der ersten Zeile nach REPT
		rs.w 1
 else
reptab_Line	rs.l 1
 endc
reptabSIZE	rs

; LineDebugTab enthält alle Zeilennummern mit zugehörigen Offsets
 rsreset
lindb_Link	rs.l 1
lindb_Ptr	rs.l 1		; nächster freier Slot, oder 0
lindb_HEAD	rs
; danach folgen immer abwechselnd Zeilennummer und Section-Offset

; SpeedUpTable Einträge wiederholen sich für jede Quelltextzeile
 rsreset
sut_Link	rs.l 1
sut_Last	rs.l 1		; Zeiger auf letzten Eintrag
sut_HEAD	rs
 rsreset
sut_LineLen	rs.w 1		; Länge dieser Quelltextzeile (inkl. LF)
sut_LabelLen	rs.w 1		; Zeichen im Label (0 = kein Label)
sut_OpcodePtr	rs.l 1		; Interne Routine oder Macro Symbol
sut_OpFlags	rs.b 1		; OpcodeFlags (0:Direct/Inst, -1:Macro, pos:Org)
sut_OpSize	rs.b 1		; OpcodeSize (byte, word, long, etc.)
sut_OperOffset	rs.w 1		; Beginn des Operanden relativ zu LinePtr
sut_OperXPos	rs.w 1		; Crsr-XPos bei Operandenstart (durch Tabs..)
sut_OperLen	rs.w 1		; Länge eines Operanden ohne Blanks und Tabs
sutSIZE 	rs

; OperandStruct enthaelt alle wichtigen Informationen die waehrend der
; Adressierungsart-Erkennung entdeckt wurden
 rsreset
opMode		rs.b 1		; Mode/Reg fuer EffectiveAddress-Feld
opReg		rs.b 1
opFormat	rs.w 1		; Bei 68020 FullFormat benutzt
opSize1 	rs.b 1		; Speicherbedarf in Words
opSize2 	rs.b 1
opType1 	rs.b 1		; -1=Reloc 0=Abs 1=Distance 2=d8Distance
opType2 	rs.b 1
opInfo1 	rs.b 1		; -8=Dist -2=NREF -1=XREF 0=Absolute
opInfo2 	rs.b 1		;    1-127 = Reloc Declaration Section + 1
opImmedByte	rs.b 1		; #Immediate-Byte Value (= ignore Bits 8-15)
opFlags 	rs.b 1		; - unbenutzt -
opVal1		rs.l 1		; Value oder Distancepointer
opVal2		rs.l 1
operSIZE	rs

; Mnemonic Node
 rsreset
mnn_Next	rs.l 1		; nächste Node in der HashChain
mnn_Name	rs.l 1		; Mnemonic
mnn_Function	rs.l 1		; Generator-Funktion für Pass1(+4)/Pass2
mnn_Parameter	rs.w 1		; zusätzliche Parameter
mnn_reserved	rs.w 1
mnnSIZE		rs


;****  Defines fuer Strukturen	****

; Definitionen fuer sym_Type
bit_ABS 	= 0
bit_EQU 	= 1
bit_FREG	= 2
bit_REG 	= 3
bit_SET 	= 4
bit_MACRO	= 5
bit_FFP 	= 6	; Motorola FastFloatingPoint (z.B. in mathffp.library)
bit_PACKED	= 7	; Packed BCD (sym_Value= Zeiger auf 96 Bit)
bit_SINGLE	= 8	; SinglePrecision Real
bit_DOUBLE	= 9	; DoublePrecision Real (sym_Value= Zeiger auf 64 Bit)
bit_EXTENDED	= 10	; ExtendedPrecision Real (sym_Value= Zeiger auf 96 Bit)
bit_DIST	= 11	; wird bei EQU ABS1-ABS2 gesetzt
bit_XDEF	= 12
bit_NREF	= 13	; Referenz mit Near-Data Model
bit_XREF	= 14
bit_PUBLIC	= 15
T_ABS		= $0001
T_EQU		= $0002
T_FREG		= $0004
T_REG		= $0008
T_SET		= $0010
T_MACRO 	= $0020
T_FFP		= $0040 	; Lage der Float-Typen sollte aufgrund der
T_PACKED	= $0080 	;  Verwendung in EquatesFile() nicht
T_SINGLE	= $0100 	;  mehr verändert werden!!!
T_DOUBLE	= $0200
T_EXTENDED	= $0400
T_DIST		= $0800
T_XDEF		= $1000
T_NREF		= $2000
T_XREF		= $4000
T_PUBLIC	= $8000

; Definition von Chunk-Größen
SECLISTBLK	= $40-secl_HEAD 	; [4er/Head8]SecList-Chunk
STRINGBLK	= $1000-sb_HEAD 	; [*]StringBuffer-Chunk
STRTABBLK	= $100-strt_HEAD	; [4er]StringTable-Chunk
HEXTTABBLK	= $100-hext_HEAD	; [4er]HunkExtTable-Chunk
HSYMTABBLK	= $400-hsym_HEAD	; [4er]HunkSymTable-Chunk
HUNKDATBLK	= $2000-hd_HEAD 	; [*]HunkData-Chunk
HUNKRELOCBLK	= $c00-hrel_HEAD	; [6er]HunkReloc-Chunk
DISTLISTBLK	= $1400 		; [20er]DistanceList-Chunk (ohne HEAD)
INCLISTBLK	= $180-incl_HEAD	; [12er]IncludeList-Chunk
MACPARBLK	= 4*MACDEPTHSIZE	; [..]MacParameter-Chunk (ohne HEAD)
CNOPTABBLK	= $80-ctab_HEAD 	; [4er]CNopTable-Chunk
REPTABBLK	= $88-ctab_HEAD 	; [16er]RepTab-Chunk (8 Einträge)
LINEDEBUGBLK	= $1000-lindb_HEAD	; [8er]LineDebugTab-Chunk (511 Einträge)
SYMBOLBLK	= $8000-stab_HEAD	; [20/22er]SymbolTable-Chunk
LOCSYMBLK	= $100-lstab_HEAD	; [20/22er]LocalSymbolTable-Chunk
 ifnd GIGALINES
LOCALPARTSBLK	= $1100-lp_HEAD 	; [12er]LocalParts-Chunk
REFLISTSIZE	= $40
REGREFLISTBLK	= $40-rrl_HEAD		; [2er/Head8]RegRefList-Chunk
MACNSTBLK	= $200-nl_HEAD		; [16er]MacNestList-Chunk
INCNSTBLK	= $200-nl_HEAD		; [16er]IncNestList-Chunk
 else
LOCALPARTSBLK	= $1800-lp_HEAD 	; [16er]LocalParts-Chunk
REFLISTSIZE	= $50
REGREFLISTBLK	= $80-rrl_HEAD		; [4er/Head10]RegRefList-Chunk
MACNSTBLK	= $240-nl_HEAD		; [18er]MacNestList-Chunk
INCNSTBLK	= $240-nl_HEAD		; [18er]IncNestList-Chunk
 endc
REFLISTBLK	= REFLISTSIZE-rlist_HEAD	; ReferenceList-Chunk
RLBLOCKBLK	= REFLISTSIZE*128		; [REFLISTSIZE-Eintraege]
SUTBLK		= $8000 			; [16er]SpeedUpTable-Chunk


; ****	Hunk - Types  ****

; Ergänzung zu doshunks.i
HUNK_OFFSET	= $00000000	; Offset-Segment (keine echte Section)
HUNK_CHIP	= $40000000	; Hunk wird ins Chip-RAM geladen
HUNK_FAST	= $80000000	; Hunk wird ins Fast-RAM geladen

; External Symbol-Types fuer ReferenceList (Ergänzung zu doshunks.i)
REF_REG 	= $7f		; Register-Symbol Referenz
REF_REGLIST	= $7e		; RegisterList-Symbol Referenz
REF_EXTFLOAT	= $7d		; Float-Symbol (sym_Value enthält Zeiger)
REF_SIMPLEFLOAT = $7c		; Float (32Bit FFP oder IEEESinglePrecision)


; **** Locale String-IDs ****

S_TITLE 	= 0		; PhxAss...
S_INSTR 	= 1		; Usage...
 ifnd FREEASS
S_INSTRLAST	= 12
 else
S_INSTRLAST	= 8
 endc
S_REFERTO	= 18		; Refer to docs...
S_PASS		= 20		; Pass %d
S_OPTIGN	= 21		; Optimize %c ignored
S_STATS 	= 22		; Statistik-Ausgaben: .. lines in .. sec ,etc.
S_PAGE		= 30		; Listing File Kopfzeile
S_SECLIST	= 34		; *** SECTIONS ***
S_SECTYPES	= 35		; CODE,DATA,..
S_SYMLIST	= 40		; *** SYMBOLS ***
S_SYMTYPES	= 41		; ++MACRO++, --SET Symbol--
S_UNREF 	= 43		; ** unreferenced **
S_EQU		= 49		; *** Equates file ...
S_ERRLIN	= 50		; .. in line .. (= line ..
S_CONT		= 51		; Do you want to continue?
S_INIT		= 52
S_CLEANUP	= 53
S_NOMEM 	= 54
S_BREAK 	= 55		; *** BREAK ...
S_MACROERR	= 56		; In line .. of macro ..
S_YES		= 63
S_ERRORS	= 64		; Alle Error-Messages

TITLE_LINES	= 3		; Bildschirmzeilen für S_TITLE
; Locale String Macro
LOCS macro
 ifgt	 \1-127
 move.w  #\1,d0
 else
 moveq	 #\1,d0
 endc
 ifnd	 FARLOCS
 bsr	 LocStr
 else
 bsr	 LocStr_stub
 endc
 endm


; ****	Variablenstruktur von PhxAss  ****
BUFSIZE 	= 1024		; am besten durch 4 teilbar !
PLENDEFAULT	= 60
MAXSECTIONS	= 250
MAXIFNEST	= 255		; Max. 255 IF-Verschachtelungen
ASSLINECOLUMN	= 34
SRCLISTLEN	= 38
MAXLASTREFS	= 32		; Max.Zahl der verm. Refs waehrend GetValue
MAXLASTDISTS	= 8		; Max.Zahl der erz. Dist. waehrend GetOperand
MAXLASTRELOCS	= 8		; Max.Zahl der erz. Relocs waehrend GetOperand
MAXREGNAMES	= 64		; Max.Anzahl Reg.-Symbole pro Register
MAXFPREGNAMES	= 64		; Max.Anzahl Reg.-Symbole pro FP-Register
MAXLOCREGNAMES	= 16		; Max.Anzahl lokaler Reg.-Symbole/Register
MAXSAVES	= 8		; Max. SAVE-Aufrufe ohne RESTORE
MAXOPTSHIFTS	= 128		; Max.Verschacht. bei Fwd.-Branch Optimierung
DEF_BIOBUFSIZE	= 8192		; Default Buffersize für Buffered I/O
DEF_GLOBHASHTAB	= 1<<12		; Defaultgröße für globale Hash-Table
DEF_LOCHASHTAB	= 1<<4		; Defaultgröße für lokale Hash-Tables
DEF_MNEMHASHTAB	= 1<<10		; Defaultgröße für Mnemonic Hash-Table

; Defines zur Expression-Auswertung
EXP_MAXARGS	= 128		  ; Max. 128 Argumente
 ifd _PHXASS_
ESCSYM		= '\\'		  ; Escape-Symbol
 endc
 ifnd _PHXASS_
ESCSYM		= '\'		  ; Escape-Symbol
 endc


; *** GlobalVars ***
 rsreset
DosBase 	rs.l 1		; dos.library
SysBase 	rs.l 1		; exec.library
UtilityBase	rs.l 1		; utility.library
myTask		rs.l 1		; PhxAss Process Struktur
		ifnd SMALLASS
MathFFPTransBase rs.l 1 	; mathtrans.library
MathIEEEBase	rs.l 1		; mathieeedoubbas.library
MathIEEETransBase rs.l 1	; mathieeedoubtrans.library
		endc
		ifnd FREEASS
LocaleBase	rs.l 1		; locale.library
Locale		rs.l 1		; Landesspezifische Locale-Struktur
Catalog 	rs.l 1		; Landesspezifischer PhxAss-Catalog
		endc
SourceName	rs.l 1		; Name des zu assemblierenden Source-Files
ObjectName	rs.l 1		; Name des zu erzeugenden Files
UnitName	rs.l 1		; Name der Object-File Unit
		ifnd FREEASS
AssListName	rs.l 1		; List-File
EquatesName	rs.l 1		; Equates (mit X-Referenzen, wenn gewuenscht)
ListFileHandle	rs.l 1		; Filehandle fuer AssList
SeekListBegin	rs.l 1		; Filepointer auf Listing-Anfang
SeekTitleOffset rs.l 1		; Offset auf Filepointer bei neuer Seite
FPOffset	rs.l 1		; Offset auf naechste Zeile
		endc
FileInfoBlock	rs.b 260	; MUSS! AN EINER DURCH 4 TEILBAREN ADR. LIEGEN
bioBufSize	rs.l 1		; Buffer-Size für Buffered I/O
AssModeName	rs.l 1		; Name des gerade assemblierten Textes
TimerPort	rs.l 1		; MsgPort fuer timer.device
TimerReq	rs.l 1		; timer.device - IO-Request
AssTime 	rs.l 2		; Zeit die zur Assemblierung benoetigt wurde
NumLines	rs.l 1		; absolute Anzahl der assembl. Zeilen (.w / .l)
SpeedUpTab	rs.l 1		; Speicher alle Informat. aus Pass 1 für Pass 2
CurrentSUT	rs.l 1		; Aktueller SpeedUpTab Chunk
SUTPos		rs.l 1		; Zeiger auf nächsten Eintrag im aktuellen Chunk
CurrentSUTPos	rs.l 1		; Zeiger SUT-Eintrag für aktuelle Zeile
MnemoMem	rs.l 1		; Zeiger auf Mnemonic-Strucuture-Nodes Mem.
MnemoSize	rs.l 1		; = Anzahl Mnemonics*16
MnemoHashList	rs.l 1		; Zeiger auf Mnemonic-Hashtable
StringBuf	rs.l 1		; Zeiger auf ersten StringBuffer-Chunk
StrBufChunk	rs.l 1		; Zeiger auf momentan letzen Chunk
StringPtr	rs.l 1		; Freier Platz in diesem StringBuffer-Chunk
		ifnd FREEASS
IncFileTable	rs.l 1		; StringTable enthaelt IncFile-Namen
IncDirTable	rs.l 1		; StringTable enthaelt IncDirectory-Namen
IncDirENV	rs.l 1		; IncDirectory aus PHXASSINC Environment
		endc
SecTabPtr	rs.l 1		; Zeiger auf SecList (enthaelt alle Sections)
CurrentSec	rs.l 1		; Adr. der gerade aktivierten Section
LinSecList	rs.l 1		; Lineare Section Liste (ersetzt SecList-Chunks)
SectionCnt	rs.w 1		; zählt Anzahl der Sections
SecNum		rs.w 1		; Momentan aktive Section
GloHashTabSize	rs.l 1		; Zahl der Einträge in der globalen Hashtable
LocHashTabSize	rs.l 1		; Zahl der Einträge in der lokalen Hashtable
MnemHashTabSize	rs.l 1		; Zahl der Einträge in der Mnemonic-Hashtable
GloHashMask	rs.w 1		; Mask für globalen Hashcode
LocHashMask	rs.w 1		; Mask für lokalen Hashcode
MnemHashMask	rs.w 1		; Mask für Mnemonics-Hashcode
		rs.w 1
SymHashList	rs.l 1		; Hashtab mit Ptr auf 1.Symbol der Hashchain
SymbolTable	rs.l 1		; Zeiger auf globale Symbol-Table
SymbolCnt	rs.w 1		; zählt Anzahl der Symbols
LocSymCnt	rs.w 1		; zählt Anzahl der Local-Symbols
LocPartsPtr	rs.l 1		; Zeiger auf LocalParts-Struktur
FirstLocalLine	rs.l 1		; momentane StartLine fuer LocalPart (.w / .l)
FirstRefListBlock rs.l 1	; erster RefListBlock-Chunk
RefListBlockPtr rs.l 1		; letzter RefListBlock-Chunk
ExtAbsTab	rs.l 1		; enthält die Zeiger auf XDEF-Equates
ExtAbsPtr	rs.l 1
MainModel	rs.b 1		; -1=FAR, 0-6 = NEAR fuer A0-A6 als OffsetBase
MaxErrors	rs.b 1		; Anzahl Fehlermeldungen bis zur Bestätigung
FloatLibs	rs.b 1		; TRUE: Alle Float-Library verfügbar
Relocatable     rs.b 1		; Fehlermeldung bei nicht relocierbarem Code
		ifnd FREEASS
AbsCode 	rs.b 1		; Art der Code-Erzeugung (0=DOS-Object)
SRecType	rs.b 1		; S-Record Typ (S19,S28,S37)
SRecLen		rs.b 1		; S-Record Länge
VDepth		rs.b 1		; Verschachtelungstiefe für V-Option (Verbose)
ReptDepth	rs.b 1		; Akt. REPT..ENDR Verschachtelungstiefe
		rs.b 3
		endc
sym__OPTC	rs.l 1		; Zeiger auf __OPTC-Symbol
		ifnd FREEASS
symNARG 	rs.l 1		; Zeiger auf NARG-Symbol
symCARG 	rs.l 1		; Zeiger auf CARG-Symbol
sym__RS 	rs.l 1		; Zeiger auf __RS-Symbol
sym__SO		rs.l 1		; Zeiger auf __SO-Symbol (identisch zu __RS)
sym__FO		rs.l 1		; Zeiger auf __FO-Symbol
TDBuffer	rs.l 1		; Fuer Trackdisk-Befehl
		endc
SourceText	rs.l 1		; Zeiger auf zu assemblierenden Source-Code
SourceLength	rs.l 1		; und dessen Speicherbedarf
		ifnd FREEASS
IncludeCnt	rs.w 1		; enthaelt Nummer des letzten include-Befehls
MacroCnt	rs.w 1		; aktuelle Macro-Verschachtelungstiefe
IncNest 	rs.l 1		; Zeiger auf IncNestList (Include-Verschacht.)
IncListPtr	rs.l 1		; Zeiger auf IncludeList
MacNest 	rs.l 1		; Zeiger auf MacNestList (Macro-Verschacht.)
MacParaPtr	rs.l 1		; Zeiger auf Macro-Parameter (fuer jede Ver.)
MacLabel	rs.b 4		; "nnnn" wird eingesetzt bei \@
ActMacLabel	rs.b 4		; aktueller Zustand
		rs.b 1		; \0 für ActMacLabel
		rs.b 3
		endc
StdIn		rs.l 1		; Standard-DOS-EingabeFileHandle (CLI-Window)
StdOut		rs.l 1		; Standard-DOS-AusgabeFileHandle (CLI-Window)
CleanUpLevel	rs.l 1		; SP-Wert fuer CleanUp-Ebene
Model		rs.b 1		; aktuelles Data-Model (far oder near)
NearSec 	rs.b 1		; Nummer der Sec. auf die NEAR einwirkt
		ifnd FREEASS
AssMode 	rs.b 1		; Include-, Macro- oder SourceText wird assem.
IfNest		rs.b 1		; aktuelle IF-Verschachtelungstiefe
RepTabPtr	rs.l 1		; Zeiger auf RepTab für REPT...ENDR
RScounter	rs.l 1		; Zaehler fuer RS-Directive
FOcounter	rs.l 1
		else
		rs.w 1
		endc
		rs.w 1
BaseRegNo	rs.b 1		; BASEREG Addressregister 0-6 (-1 = inaktiv)
BaseSecNo	rs.b 1		; BASEREG Section Nummber
BaseSecOffset	rs.l 1		; BASEREG Section Offset
FirstCnopTab	rs.l 1		; Zeiger auf erste CnopTable
CnopPtr 	rs.l 1		;  aktueller Wert
CnopTabPtr	rs.l 1		;  aktueller Chunk
MachinePreset	rs.b 1		; Commandline-Presets für CPU,FPU,PMMU
FPUidPreset	rs.b 1
PMMUidPreset	rs.b 1
Machine 	rs.b 1		; 0=68000,1=010,2=020,3=030,4=040,6=060
FPUid		rs.b 1		; 68881/68882 oder 68040
PMMUid		rs.b 1		; 68851
ErrorCnt	rs.b 1		; zaehlt die Erros bis zum naechsten Request
ErrorFlag	rs.b 1		; TRUE, wenn schon ein Fehler aufgetreten ist
Switches	rs.b 1		; /S Schalter, Teil 1
Switches2	rs.b 1		; /S Schalter, Teil 2
		ifnd FREEASS
ListEn		rs.b 1		; TRUE, wenn der SourceCode ins Listing soll
IgnoreCase	rs.b 1		; =1 'a'=='A'
PageLength	rs.b 1		; Zeilen pro Einzelblatt bei -l Option
PageLine	rs.b 1		; aktuelle Zeile auf dieser Seite
PageCnt 	rs.b 1		; aktuelle Seite
Columns 	rs.b 1		; Zahl der Leerzeichen vor Ass.Zeilenausgabe
		else
		rs.b 2
		endc
Pass		rs.b 1		; Pass1(0) oder Pass2(1)
OpcodeSize	rs.b 1		; Byte, Word, etc. Extension des Opcodes
Local		rs.b 1		; =1 wenn Symbol im LabelBuffer local ist
RefFlag 	rs.b 1		; =1 wenn Referenzen einzutragen sind
OptFlag 	rs.b 1		; Optimize-Flags fuer aktuelle Section
DistSet 	rs.b 1		; =1 wenn GetExpression Distanz gefunden hat
TryPC		rs.b 1		; <0 wenn Umwandlung AbsLong->PCdisp moeglich
ReturnCode	rs.b 1		; wird erst 0 wenn Ass. keinen Fehler meldete
TotalBccOpt	rs.b 1		; =1 aktiviert die totale Bcc-Optimierung!
Movem2MoveOpt	rs.b 1		; =1 MOVEM mit 1 Register wird zu MOVE opt.
DistChkDisable	rs.b 1		; =1 Distanzen werden nicht ueberprueft
DistShift	rs.b 1		; Bit 5: R(1)/L-shift, Bits 4-0: Dist-Shiftcount
DiceProc	rs.b 1		; PROCSTART-END Bereich für DICE-C
SaveCnt 	rs.b 1		; Zähler für SAVE/RESTORE Verschachtelung
OldTaskPri	rs.b 1		; Alte Task-Priorität
ZeroPadding	rs.b 1		; CNOP und Hunk-Alignment mit 0 statt $4e71
LocalRegName	rs.b 1		; Local register name detected
		rs.b 3
LineBase	rs.l 1		; Startadr. der aktuelln Text-Zeile
LineAddr	rs.l 1		; Adr. die am Anfang der Zeile gueltig ist
		ifnd  GIGALINES
LineStart	rs.w 1		; Nr. der ersten SourceText-Zeile
Line		rs.w 1		; Momentan assemblierte Zeile
AbsLine 	rs.w 1		; wird auch in Includes, etc. weitergezaehlt
		rs.w 1
		else
LineStart	rs.l 1		; Nr. der ersten SourceText-Zeile
Line		rs.l 1		; Momentan assemblierte Zeile
AbsLine 	rs.l 1		; wird auch in Includes, etc. weitergezaehlt
		endc
DebugPath	rs.l 1		; Vollst. Pfad für SourceLevelDebugging
LastRefCnt	rs.w 1		; Zaehlt die Referenzen, Distanzen,
LastDistCnt	rs.w 1		;  Relocs,.. waehrend einer Instruktion
LastRelocCnt	rs.w 1
ListFileOff	rs.w 1		; Offset auf Filepointer am Zeilenanfang
LastDistance	rs.l 1		; Zeiger auf gerade getaetigten DList-Eintrag
DistVal 	rs.l 2		; Subtr.,Minuend die GetExpr. gefunden hat
BytesGained	rs.l 1		; Durch Optimierung gewonnene Bytes
SrcPtr		rs.l 1		; Diese Var. werden von GetValue benoetigt
SDdata		rs		; Write Executable: SecNum Data-Part/SmallData
RefType 	rs.w 1
SDbss		rs		; Write Executable: SecNum Bss-Part/SmallData
RefNear 	rs.w 1
RefAdrOff	rs.l 1
oper1		rs.b operSIZE	; Operanden-Strukturen
oper2		rs.b operSIZE
oper3		rs.b operSIZE
OpcodeLen	rs.w 1		;  und im Opcode (wird in LineParts bestimmt)
OperStart	rs		; Startadresse des aktuellen Operanden (Pass1)
EarlyOD		rs.l 1		; Outer Displacement before MemIndirect
SecNumBuffer	rs		; zum Zwischenspeichern aller Section-Nummern
LabelBuffer	rs.b BUFSIZE	; Buffer fuer Label
rda_srcbuf	rs		; wird von CheckENVVar und ChkCommandLine ben.
OpcodeBuffer	rs.b BUFSIZE	; Buffer fuer Opcode
SrcOperBuffer	rs.b BUFSIZE	; Buffer fuer Quell-Operanden
DestOperBuffer	rs.b BUFSIZE	; Buffer fuer Ziel-Operanden
ThirdOperBuffer rs.b BUFSIZE	; Buffer fuer dritten Operanden (ab 68020)
Buffer		rs.b BUFSIZE	; Allgemeiner Arbeits-Buffer
		ifnd SMALLASS
FloatBuffer	rs.l 3		; fuer 64 oder 96 Bit Fliesskommazahlen
		endc
LastShiftPtr	rs.l 1		; 'StackPointer' zu LastShiftAddrs
SDdataPtr	rs		; Write Executable: Zeiger auf SD-Data Section
TimeString	rs.b 4		; 20 Zeichen für Datum und Zeit
SDbssPtr	rs		; Write Executable: Zeiger auf SD-Bss Section
		rs.b 16 	; letzte Stelle wird f. andere Zwecke genutzt
SaveSects	rs.l MAXSAVES	; Section-Adressen für SAVE/RESTORE Direktiven
ucase_tab	rs.b 256	; Tabelle für Großbuchtstaben-Umwandlung
label1_tab	rs.b 256	; Tabellen für Überpüfung von gültigen Zeichen
label2_tab	rs.b 256
arg1_tab	rs.b 256
arg2_tab	rs.b 256
RegNames	rs.l 16*MAXREGNAMES
RegRefs 	rs.l 16*MAXREGNAMES ; Zeiger auf Reg.-Reference-Strukturen
FPRegNames	rs.l 8*MAXREGNAMES
FPRegRefs 	rs.l 8*MAXREGNAMES ; Zeiger auf FPReg.-Reference-Strukturen
LastRefs	rs.l MAXLASTREFS
LastDists	rs.l MAXLASTDISTS
LastRelocs	rs.l MAXLASTRELOCS
LastShiftAddrs	rs.l MAXOPTSHIFTS  ; Letzte ShiftPCs vor der Rekursion
ExpressionStack rs.b EXP_MAXARGS*6 ; Expression-Stack fuer GetExpression
ExpStackBase	rs
GlobalVarsSIZE	rs

; Switches
sw_NOEXE	= 0		  ; keine Executables erz. - nur Objectfiles
sw_REFS 	= 1		  ; References an's Listing anhängen
sw_NEARCODE	= 2		  ; Small Code Model
sw_MODEL	= 3		  ; Forced model (Model im Code ignorieren)
sw_SYMDEBUG	= 4		  ; Debug-Symbol Hunk anhängen
sw_QUIET	= 5		  ; Ausgaben, bis auf Fehler, unterdrücken
sw_OPTIMIZE	= 6		  ; Optimize Directiven im Code ignorieren
sw_ALIGN	= 7		  ; Auto-Align fuer dc.w/dc.l ist aktiviert
sw2_EXE		= 0		  ; Executables auch bei XDEFs erzeugen
sw2_SHOWOPTS	= 1		  ; Optimierungen anzeigen
sw2_NOWARNINGS	= 2		  ; Warnungen unterdrücken
sw2_VERBOSE	= 3		  ; Include/Macro-Verschachtelungen darstellen
sw2_LINEDEBUG	= 4		  ; Line-Debugging Informationen erzeugen
sw2_FORCEPRI	= 5		  ; Priorität während des Assemblierens ändern

; AssModes
am_SOURCE	= 0		  ; Der normale Sourcecode wird assembliert
am_INC		= 1		  ; Includefile wird assembliert
am_MACRO	= -1		  ; Macro wird assembliert

; OpcodeSizes
os_UNDEF	= -1		  ; z.B. EQU-Distance
os_BYTE 	= 0		  ; .b
os_WORD 	= 1		  ; .w
os_LONG 	= 2		  ; .l
os_FFP		= 3		  ; .f
os_SINGLE	= 4		  ; .s (kann auch Short-Branch bedeuten)
os_DOUBLE	= 5		  ; .d
os_EXTENDED	= 6		  ; .x
os_PACKED	= 7		  ; .p
os_NEARWORD	= 9		  ; Near-Data Distanzen (os_WORD)
os_BRANCH	= 16		  ; 17 & 18 = Bcc.w/.l Vorwaerts-Distanzen


; Effective Adressing Modes
ea_NoOperand	= -1
ea_Ddirect	= 0		  ; Mode 0-6 haben im Register die RegNr.
ea_Adirect	= 1
ea_Aind 	= 2
ea_AindPostInc	= 3
ea_AindPreDec	= 4
ea_AindDispl	= 5
ea_AindIndex	= 6
ea_SpecialMode	= 7

; SpecialMode im Register	 ; SpecialMode benoetigt kein Register
ea_AbsShort	= 8
ea_AbsLong	= 9
ea_PCdisplace	= 10
ea_PCindex	= 11
ea_Immediate	= 12
ea_USP		= 13
ea_SR		= 14
ea_RegList	= 15

