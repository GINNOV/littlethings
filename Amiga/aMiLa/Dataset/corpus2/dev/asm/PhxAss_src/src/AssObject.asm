; $VER: AssObject.asm 4.36 (24.05.97)
; **********************************************
;
;             PhxAss Macro Assembler
;
;        Written by Frank Wille, 1991-2005
;
;          OBJECT/EXECUTABLE GENERATION
;
; **********************************************

	far				; Large Code/Data-Model

	include	"AssDefs.i"		; Strukturen und Definitionen einlesen

	ttl	"PhxAss - Object creation routines"


; ************
; CODE-Segment
; ************

	section	CreateObject,code


; ** XREFs **
	xref	FatalError,OutofMemError

; ** XDEFs **
	xdef	WriteObjectCode


	rsreset				; Struktur für Buffered I/O Routinen
bio_sysbase rs.l 1
bio_dosbase rs.l 1
bio_fh	rs.l	1
bio_have rs.l	1
bio_rec_end rs.l 1
bio_begin rs.l	1
bio_eof	rs.l	1
bio_bufptr rs.l	1
bio_bufsize rs.l 1
bio_buffer rs



	IFND	FREEASS
WriteObjectCode:
	moveq	#0,d0
	move.b	AbsCode(a5),d0		; Object-Code erzeugen
	bmi	CopyToAddr
	add.w	d0,d0
	add.w	d0,d0
	jmp	ObjTab(pc,d0.l)
ObjTab:
	jmp	DOSFile(pc)		; Amiga-DOS Objectfile oder Executable erz.
	jmp	CopyToAddr(pc)		; Code an absolute Adresse kopieren
	jmp	AbsoluteFile(pc)	; Absoluten Code in ein File schreiben
	jmp	Trackdisk0(pc)		; Abs. Code auf Disk in Drive 0-3 schreiben
	jmp	Trackdisk1(pc)
	jmp	Trackdisk2(pc)
	jmp	Trackdisk3(pc)
	jmp	SRecord(pc)		; Motorola S-Records schreiben
	ENDC


checkXREFs:
; Prüfen, ob die Section externe Referenzen benötigt
; a0 = Section
; -> Z = keine XREFs gefunden
	movem.l	d0-d1/a0-a3,-(sp)
	move.l	sec_HunkExtTable(a0),d0
	beq.s	9$
	move.l	d0,a2
	lea	hext_HEAD(a2),a1
	move.l	sec_HETPt(a0),a3
	cmp.l	a3,a1			; keine externen Symbole vorhanden?
	beq.s	8$
	btst	#sw2_EXE,Switches2(a5)	; Executable auch mit XDEFs erz.?
	bne.s	2$
1$:	moveq	#-1,d0
	bra.s	9$
2$:	move.l	d0,a2
	lea	hext_HEAD(a2),a0
	move.w	#HEXTTABBLK/4-1,d1
3$:	cmp.l	a3,a0			; alle externen Symbole durch ?
	beq.s	8$
	move.l	(a0)+,a1		; Symbol
	move.w	sym_Type(a1),d0
	btst	#bit_XDEF,d0
	beq.s	1$			; ist ein XDEF-Symbol?
	dbf	d1,3$
	move.l	(a2),d0			; noch ein Chunk ?
	bne.s	2$
8$:	moveq	#0,d0
9$:	movem.l	(sp)+,d0-d1/a0-a3
	rts


checkRelocs:
; d0 = Prüfen ob zu dieser Sect.Nr. Reloc-Referenzen bestehen
; -> Z = keine Referenzen gefunden
	movem.l	d2/a0/a2-a3,-(sp)
	move.l	LinSecList(a5),a3
	move.w	SectionCnt(a5),d2
	subq.w	#1,d2
1$:	move.l	(a3)+,a2
	move.l	sec_HunkReloc(a2),d1
	bsr.s	10$
	bne.s	2$
	move.l	sec_HunkNearReloc(a2),d1
	bsr.s	10$
	dbne	d2,1$
2$:	movem.l	(sp)+,d2/a0/a2-a3
	rts

; Hunk-Reloc Liste der Section nach Referenzen durchsuchen
10$:
; d0 = zu suchende Sect.Nr.
; d1 = HunkReloc Struct
; -> Z = keine Ref. auf Sect.Nr in dieser Section gefunden
	beq.s	14$			; HunkReloc=0 ?
	move.l	d1,a1
	lea	hrel_HEAD(a1),a0
	move.w	hrel_Entries(a1),d1
	bpl.s	12$
	move.w	#(HUNKRELOCBLK/6)-1,d1
11$:	addq.l	#4,a0
	cmp.w	(a0)+,d0
	beq.s	13$			; gefunden?
12$:	dbf	d1,11$
	move.l	(a1),d1
	bne.s	10$
	rts
13$:	moveq	#-1,d1
14$:	rts


ignoreSect:
; d0 = zu ignorierende Section
; d4 = Anzahl Sections (wird dekrementiert)
	move.l	d1,-(sp)
	subq.w	#1,d4
	lea	SecNumBuffer+255(a5),a0
	lea	1(a0),a1
	move.w	#254,d1
	sub.w	d0,d1
1$:	move.b	-(a0),-(a1)
	dbf	d1,1$
	move.l	(sp)+,d1
	rts


	IFD	FREEASS
WriteObjectCode:
	ENDC

DOSFile:
; Unbenutzte Sections aussortieren, dabei prüfen, ob anstatt
; eines Objectsfiles auch schon ein Executable erzeugt werden kann
	lea	SecNumBuffer(a5),a0
	moveq	#0,d0
1$:	move.b	d0,(a0)+		; Alle Section-Nummern 0-255 speichern
	addq.b	#1,d0
	bne.s	1$
	moveq	#0,d2			; d2 Section 0
	moveq	#0,d3			; d3 XDEF/XREF-Flag
	moveq	#0,d4
	move.w	SectionCnt(a5),d4	; d4 Anzahl zu 'speichernder' Sections
	moveq	#0,d6			; d6 DataSecs.w|BssSecs.w
	move.w	d4,d5
	subq.w	#1,d5
	move.l	LinSecList(a5),a2
	moveq	#-1,d0
	move.l	d0,SDdata(a5)		; SDdata, SDbss = -1 (falls kein SmallData)
	clr.l	SDdataPtr(a5)
	clr.l	SDbssPtr(a5)
2$:	move.l	(a2)+,a0		; Section
	move.w	sec_Type+2(a0),d0	; Offset-Section ?
	beq.s	6$
	tst.b	sec_Near(a0)		; Section wird Near adressiert?
	beq.s	4$
	sub.w	#HUNK_DATA,d0		; Data oder Bss?
	bne.s	41$
	swap	d6
	addq.w	#1,d6			; d6: MSW=DataSects | LSW=BssSects
	swap	d6
	move.w	d2,SDdata(a5)
	move.l	a0,SDdataPtr(a5)
	bra.s	4$
41$:	subq.w	#1,d0
	bne.s	4$
	addq.w	#1,d6
	move.w	d2,SDbss(a5)
	move.l	a0,SDbssPtr(a5)
4$:	move.b	d2,sec_Flags(a0)	; Section-Nummer speichern
	bsr	checkXREFs
	beq.s	5$
	moveq	#-1,d3			; Source enthält XREFs oder XDEFs
	bra.s	3$
5$:	tst.l	sec_Size(a0)		; Section ist leer?
	bne.s	3$
	move.w	d2,d0
	bsr	checkRelocs		; Existieren Reloc-Referenzen auf die Sect.?
	bne.s	3$
6$:	; Diese Section (a0, Nr. d2) wird ignoriert
	st	sec_Flags(a0)
	moveq	#-1,d0
	cmp.l	SDdataPtr(a5),a0
	bne.s	61$
	clr.l	SDdataPtr(a5)
	move.w	d0,SDdata(a5)
	swap	d6
	subq.w	#1,d6
	swap	d6
61$:	cmp.l	SDbssPtr(a5),a0
	bne.s	62$
	clr.l	SDbssPtr(a5)
	move.w	d0,SDbss(a5)
	subq.w	#1,d6
62$:	move.w	d2,d0
	bsr	ignoreSect
3$:	addq.w	#1,d2
	dbf	d5,2$			; nächste Section
	tst.w	d4			; Ist überhaupt eine Sect. zu speichern?
	beq.s	90$
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	move.l	ObjectName(a5),d1
	move.l	#MODE_NEWFILE,d2
	tst.b	d3			; XDEFs oder XREFs vorhanden?
	bne.s	9$
	btst	#sw_NOEXE,Switches(a5)	; LoadFile-Generierung nicht erlaubt?
	bne.s	9$
	btst	#sw_NEARCODE,Switches(a5) ; SmallCode aktiviert?
	beq.s	8$
	swap	d6
	subq.b	#1,d6
	bhi.s	9$			; .. und mehrere Code-Sections? (uff)
	swap	d6
8$:	cmp.b	#-2,NearSec(a5)		; SmallData aktiviert?
	blo.s	DOSExecutable
	btst	#sw2_LINEDEBUG,Switches2(a5) ; Data/Bss mit LineDebug vereinigen? (uff)
	bne.s	9$
	move.w	d6,d0
	subq.w	#1,d6			; nur maximal eine Bss-Section bei SmallData
	bhi.s	9$
	swap	d6
	add.w	d6,d0
	subq.w	#1,d6			;    und/oder eine Data-Section
	bls.s	10$
9$:	bra	DOSObject
90$:	move.l	a6,-(sp)		; leeres Object File erzeugen
	move.l	DosBase(a5),a6
	move.l	ObjectName(a5),d1
	move.l	#MODE_NEWFILE,d2
	jsr	Open(a6)
	move.l	d0,d4
	beq	WriteErr
	pea	HUNK_END.w
	clr.l	-(sp)
	pea	HUNK_CODE.w
	clr.l	-(sp)
	pea	HUNK_UNIT.w
	move.l	d4,d1
	move.l	sp,d2
	moveq	#20,d3
	jsr	Write(a6)
	tst.l	d0
	bmi	WriteErr
	move.l	d4,d1
	jsr	Close(a6)
	lea	20(sp),sp
	move.l	(sp)+,a6
	rts
10$:	subq.w	#2,d0			; Data UND Bss vorhanden?
	bne.s	DOSExecutable
	move.w	SDbss(a5),d0		; Bss entfernen
	bsr	ignoreSect

DOSExecutable:
; Amiga-DOS LoadFile erzeugen
; d4.l wirkliche Anzahl Sections
; d1 ObjectName, d2 MODE_NEWFILE, a6 DOSBase
	move.l	d1,a0
	bsr	StrLen
	add.w	d0,a0
;	subq.w	#1,d0
;1$:	cmp.b	#'.',-(a0)		; ".o" im ObjectName suchen und streichen
;	dbeq	d0,1$
;	bne.s	2$
	moveq	#-$21,d0
	and.b	-(a0),d0
	cmp.b	#'O',d0			;".o" im ObjName suchen und streichen
	bne.s	2$
	cmp.b	#'.',-(a0)
	bne.s	2$
	clr.b	(a0)
2$:	jsr	Open(a6)		; LoadFile öffnen
	move.l	d0,d2
	beq	WriteErr
	move.l	bioBufSize(a5),d1
	bsr	bio_buf
	move.l	d0,d7
	bne.s	4$
	move.l	d2,d1
	jsr	Close(a6)
	bra	WriteErr
4$:	move.l	#HUNK_HEADER,d0		; Hunk-Header erzeugen
	bsr	WriteLong
	moveq	#0,d0
	bsr	WriteLong
	move.l	d4,d0
	bsr	WriteLong		; Anzahl Sections/Hunks
	moveq	#0,d0
	bsr	WriteLong		; erste/letzte
	move.l	d4,d0
	subq.w	#1,d0
	bsr	WriteLong
	subq.w	#1,d4
3$:	; Alle Section-Längen (in Longwords)
	moveq	#0,d0			; erstmal provisorisch mit Nullen füllen
	bsr	WriteLong
	dbf	d4,3$
	moveq	#20,d4			; d4 Filepointer für Section-Size
	move.l	LinSecList(a5),a4
	move.w	SectionCnt(a5),d6
	subq.w	#1,d6

exe_Section:
	move.l	(a4)+,a2		; a2 Section
	movem.l	d6/a4,-(sp)
	move.b	sec_Flags(a2),d0	; ist bereits als 'gelöscht' gekennzeichnet?
	addq.b	#1,d0
	beq	exe_nextSec
	move.l	d7,a1
	move.l	d4,d0
	moveq	#OFFSET_BEGINNING,d1
	bsr	bio_seek		; Hunk-Header für Eintrag der nächsten
	move.l	d0,a3			;  Hunk-Size anfahren -> a3 saved FilePos
	moveq	#0,d6
	move.w	sec_Type+2(a2),d6	; d6 Hunk-Code -Data oder -BSS
	move.l	sec_Size(a2),d5		; Größe der Section in Bytes
	moveq	#0,d0
	move.b	sec_Flags(a2),d1
	cmp.b	SDbss+1(a5),d1		; ist es eine SmallData Bss-Section?
	bne.s	2$
	tst.l	SDdataPtr(a5)		; Wenn Data-Section ebenfalls vorhanden ist,
	beq.s	1$			; wird die Bss-Section völlig ignoriert
	bsr.s	3$
	bra	exe_nextSec
3$:	move.l	d7,a1			; Filepointer an alte Pos. zurückstellen
	move.l	a3,d0
	moveq	#OFFSET_BEGINNING,d1
	bra	bio_seek
2$:	cmp.b	SDdata+1(a5),d1		; SmallData Data-Section?
	bne.s	1$
	move.l	SDbssPtr(a5),d0		; falls vorhanden, Größe der Bss-Section
	beq.s	1$			;  dazuaddieren und MemFlags vereinigen
	move.l	d0,a0
	moveq	#3,d0
	ror.l	#2,d0
	and.l	sec_Type(a0),d0
	or.l	d0,sec_Type(a2)
	move.l	sec_Size(a0),d0
1$:	bsr	Bytes2Longs
	move.l	d0,d2
	move.l	d5,d0
	bsr	Bytes2Longs
	add.l	d2,d0
	moveq	#3,d1
	ror.l	#2,d1
	and.l	sec_Type(a2),d1		; Chip/Fast-MemFlags von sec_Type mit
	or.l	d1,d0			;  Section-Size in Longwords verbinden
	bsr	WriteLong
	bsr.s	3$			; FilePointer zurücksetzen
	addq.l	#4,d4
	move.l	d6,d0			; Section erzeugen:
	bsr	WriteLong		; Hunk-Type (Code, Data, Bss)
	move.l	d5,d0
	bsr	Bytes2Longs
	bsr	WriteLong		; Section-Size in Longwords
	cmp.w	#HUNK_BSS,d6
	beq	exe_Debug		; BSS-Hunk hat keinen definierten Inhalt
	tst.b	MainModel(a5)		; Near-Data irgenwie aktiviert?
	bmi	exe_writedata

	moveq	#0,d3
	move.l	SDdata(a5),d5		; d5 = MSW: Data-Sec ID, LSW: Bss-Sec ID
	move.l	SDdataPtr(a5),d0
	beq	20$			; keine Data? Reloc32 nicht korrigieren!
	move.l	d0,a0
	move.l	sec_Size(a0),d0
	beq	20$
	bsr	Bytes2Longs
	lsl.l	#2,d0
	move.l	d0,d3
	tst.l	SDbssPtr(a5)
	beq	20$			; keine Bss? Dann Reloc32 nicht korrigieren
	cmp.b	#-2,NearSec(a5)		; SmallData-Modell?
	blo	20$			;  dann müssen Reloc32 auf Bss korrig. werden!

	move.l	a6,-(sp)
	move.l	sec_HunkReloc(a2),d0
14$:	move.l	d0,a6
	lea	hrel_HEAD(a6),a3
	move.w	hrel_Entries(a6),d2
	bpl.s	16$
	move.w	#HUNKRELOCBLK/6,d2
	bra.s	16$
15$:	move.l	(a3)+,d6		; d6 RELOC32-Offset
	cmp.w	(a3)+,d5		; Bezugs-Section ist Small-Data Bss?
	bne.s	16$
	bsr	offsetPtr		; HunkData-Wert muß in zwei Schritten gele-
	move.l	a1,a0			;  sen werden, da ein Longword-Alignment
	move.w	(a0),d1			;  nicht garantiert werden kann!
	swap	d1
	addq.l	#2,d6
	bsr	offsetPtr
	move.w	(a1),d1
	add.l	d3,d1			; Offset für Bss-Section dazuaddieren
	move.w	d1,(a1)			; und zurückschreiben
	swap	d1
	move.w	d1,(a0)
	swap	d5
	move.w	d5,-2(a3)		; Bezugs-Section ist jetzt die Data-Sect.
	swap	d5
16$:	dbf	d2,15$
	move.l	(a6),d0			; noch ein HunkReloc-Chunk ?
	bne	14$
	move.l	(sp)+,a6

20$:	move.l	sec_HunkNearReloc(a2),d0 ; Near-Relocs (DREL16) korrigieren
4$:	move.l	d0,a0
	lea	hrel_HEAD(a0),a3
	move.w	hrel_Entries(a0),d2
	bpl.s	12$
	move.w	#HUNKRELOCBLK/6,d2
	bra.s	12$
5$:	moveq	#0,d5			; d5 Default Section Offset
	move.l	(a3)+,d6		; d6 DREL16-Offset
	moveq	#0,d0
	move.w	(a3)+,d0
	move.b	NearSec(a5),d1
	cmp.b	d1,d0			; Bezug auf korrekte Near-Section?
	beq.s	7$
	cmp.b	#-2,d1			; oder ist es SmallData?
	bhs.s	6$
	moveq	#66,d0
	bra	FatalErrClose
6$:	move.l	LinSecList(a5),a1
	lsl.w	#2,d0
	move.l	(a1,d0.w),a1
	cmp.w	#HUNK_BSS,sec_Type+2(a1)
	bne.s	7$
	move.l	d3,d5			; Bss-Offset verwenden
7$:	move.l	#32766,d1
	sub.l	d1,d5			; d5 DREL16-Offset
	bsr	offsetPtr		; -> a1 = zu ändernde Stelle
	moveq	#0,d0
	move.w	(a1),d0
	add.l	d5,d0
	cmp.l	d1,d0			; prüfen ab DREL16 noch in 16 Bit paßt
	bgt.s	10$
	neg.l	d1
	cmp.l	d1,d0
	bge.s	11$
10$:	moveq	#4,d0			; DREL16 out of range
	bra	FatalErrClose
11$:	move.w	d0,(a1)			; korrigiertes Word zurückschreiben
12$:	dbf	d2,5$
	move.l	(a0),d0			; noch ein HunkReloc-Chunk ?
	bne	4$

exe_writedata:
	move.l	a2,a0
	bsr	WriteHunkData		; den ganzen Hunk schreiben
	move.l	sec_Size(a2),d2
	bsr	HunkFillBytes
	move.l	sec_HunkReloc(a2),a0	; Hunk-Reloc32
	tst.w	hrel_Entries(a0)	; wird der Hunk ueberhaupt benoetigt ?
	beq.s	exe_Debug
	move.l	#HUNK_RELOC32,d5	; Reloc32 Hunk erzeugen
	bsr	BuildRelocHunk
exe_Debug:
	; Debugger Symbol-Hunk erzeugen
	bsr	BuildSymbolHunk
	bsr	BuildLineDebugHunk
exe_hunkend:
	; Section ist zuende
	move.l	#HUNK_END,d0
	bsr	WriteLong
exe_nextSec:
	movem.l	(sp)+,d6/a4
	dbf	d6,exe_Section		; naechste Section speichern
	move.l	d7,a1
	bsr	bio_close
exe_x:
	move.l	(sp)+,a6
	rts

FatalErrClose:
	move.l	d0,d4
	move.l	d7,a1
	bsr	bio_close
	move.l	d4,d0
	bra	FatalErr


	cnop	0,4
offsetPtr:
; Anhand des Offsets die betreffende Stelle im HunkData-Chunk bestimmen
; (a0/d1 werden nicht verändert !)
; d6 = Offset
; -> a1 = DataPtr
	move.l	d6,-(sp)
	move.l	sec_HunkData(a2),a1	; Erster HunkData-Chunk
	move.l	#HUNKDATBLK,d0		; Chunk-Groesse
	bra.s	2$
1$:	move.l	(a1),a1			; nächster Chunk
	sub.l	d0,d6
2$:	cmp.l	d0,d6			; Adresse liegt in diesem Chunk ?
	bhs.s	1$
	lea	hd_HEAD(a1,d6.l),a1	; Zu ändernde Stelle
	move.l	(sp)+,d6
	rts


DOSObject:
; Erzeugen eines Amiga-DOS Object-File
	jsr	Open(a6)		; Objectfile öffnen
	move.l	d0,d2
	beq	WriteErr
	move.l	bioBufSize(a5),d1
	bsr	bio_buf
	move.l	d0,d7
	bne.s	3$
	move.l	d2,d1
	jsr	Close(a6)
	bra	WriteErr
3$:	move.l	#HUNK_UNIT,d0
	bsr	WriteLong
	move.l	UnitName(a5),d0		; Name gesetzt ?
	beq.s	1$
	bsr	LongStrLen
	bsr	WriteLong		; Name-Laenge
	bsr	WriteString		; Name-String
	bra.s	2$
1$:	moveq	#0,d0
	bsr	WriteLong
2$:	clr.w	SecNum(a5)		; Zaehl die Section-Nummer mit
	move.l	LinSecList(a5),a4
	move.w	SectionCnt(a5),d6
	subq.w	#1,d6

dos_Section:
	move.l	(a4)+,a2		; a2 Section
	move.l	a4,-(sp)
	move.b	sec_Flags(a2),d0	; ist bereits als 'gelöscht' gekennzeichnet?
	addq.b	#1,d0
	beq	dos_nextSec
	move.l	#HUNK_NAME,d0		; Hunk-Name
	bsr	WriteLong
	move.l	sec_Name(a2),d0
	bsr	LongStrLen
	bne.s	2$
	bsr	WriteLong		; Stringlaenge Null, kein Name
	bra.s	3$
2$:	bsr	WriteLong		; Name-Laenge
	bsr	WriteString		; Name-String
3$:	move.l	sec_Type(a2),d0		; Hunk-Code -Data oder -BSS
	bsr	WriteLong
	move.l	sec_Size(a2),d2
	bne.s	4$
	moveq	#0,d0
	bsr	WriteLong		; leere Section
	bra.s	dos_ExtRef		; Externe Referenzen aber trotzdem speichern
4$:	move.l	d2,d0
	bsr	Bytes2Longs
	bsr	WriteLong
	cmp.w	#HUNK_BSS,sec_Type+2(a2)
	beq.s	dos_ExtRef		; BSS-Hunk hat keinen definierten Inhalt
	move.l	a2,a0
	bsr	WriteHunkData		; den ganzen Hunk schreiben
	bsr	HunkFillBytes

dos_Reloc32:
	move.l	sec_HunkReloc(a2),a0	; Hunk-Reloc32
	tst.w	hrel_Entries(a0)	; wird der Hunk ueberhaupt benoetigt ?
	beq.s	dos_NearReloc
	move.l	#HUNK_RELOC32,d5
	bsr	BuildRelocHunk

dos_NearReloc:
	move.l	sec_HunkNearReloc(a2),a0
	tst.w	hrel_Entries(a0)	; werden Near-Relocs benoetigt ?
	beq.s	dos_ExtRef
	move.l	#HUNK_DREL16,d5
	bsr	BuildRelocHunk

dos_ExtRef:
	move.l	sec_HunkExtTable(a2),d2
	move.l	d2,d0
	addq.l	#hext_HEAD,d0
	move.l	sec_HETPt(a2),d5
	cmp.l	d5,d0			; wird der Hunk ueberhaupt benoetigt ?
	beq	dos_Debug
	move.l	a2,-(sp)
	move.l	#HUNK_EXT,d0		; Hunk- External References
	bsr	WriteLong
	move.l	d2,d0
1$:	move.l	d0,a4
	lea	hext_HEAD(a4),a3
	move.w	#HEXTTABBLK/4-1,d4
2$:	cmp.l	d5,a3			; alle externen Symbole durch ?
	beq	11$
	move.l	(a3)+,a2		; Symbol
	move.w	sym_Type(a2),d0
	btst	#bit_XDEF,d0
	beq.s	9$			; ** XDEF **
	btst	#bit_DIST,d0		; Distanzwert ?
	beq.s	4$
	move.l	sym_Value(a2),a0
	move.l	(a0)+,d3
	sub.l	(a0),d3
	bra.s	5$
4$:	move.l	sym_Value(a2),d3
5$:	move.w	#EXT_DEF<<8,d2
	and.w	#T_ABS,d0		; zu korrigierende Definition ?
	bne.s	3$
	move.w	#EXT_ABS<<8,d2
3$:	move.l	sym_Name(a2),d0
	bsr	LongStrLen
	swap	d0
	move.w	d2,d0
	swap	d0
	bsr	WriteLong		; Symbol-Type und Name-Laenge
	bsr	WriteString		; Name-String
	move.l	d3,d0
	bsr	WriteLong		; Symbol-Wert
	bra.s	10$
9$:	; ** XREF **
	move.w	SecNum(a5),d0
	lea	SecNumBuffer+256(a5),a0
	move.w	#255,d2
12$:	cmp.b	-(a0),d0
	dbeq	d2,12$
	lsl.w	#8,d2
	move.b	#EXT_REF32,d2
	bsr	BuildXREFHunk
	move.b	#EXT_REF16,d2
	bsr	BuildXREFHunk
	move.b	#EXT_REF8,d2
	bsr	BuildXREFHunk
	move.b	#EXT_DEXT16,d2
	bsr	BuildXREFHunk
	move.b	#EXT_RELREF32,d2
	bsr	BuildXREFHunk
10$:	dbf	d4,2$
	move.l	(a4),d0			; noch ein Chunk ?
	bne	1$
11$:	moveq	#0,d0			; 0 schliesst die Externals ab
	bsr	WriteLong
	move.l	(sp)+,a2

dos_Debug:
	bsr	BuildSymbolHunk
	bsr	BuildLineDebugHunk
dos_hunkend:
	; Section ist zuende
	move.l	#HUNK_END,d0
	bsr	WriteLong
	addq.w	#1,SecNum(a5)
dos_nextSec:
	move.l	(sp)+,a4
	dbf	d6,dos_Section		; nächste Section speichern
	move.l	d7,a1
	bsr	bio_close		; File schliessen und FERTIG !
	move.l	ObjectName(a5),d1
	moveq	#%0010,d2		; rw-d Protection für Objectfile
	jsr	SetProtection(a6)
	move.l	(sp)+,a6
	rts


StrLen:
; a0 = String
; -> d0 = StringLength.l
	move.l	a0,-(sp)
	moveq	#-1,d0
1$:	tst.b	(a0)+
	dbeq	d0,1$
	not.l	d0
	move.l	(sp)+,a0
	rts

LongStrLen:
; d0 = StringPtr
; -> d0 = StrLen in Longwords
; -> a0 = StringPtr
	move.l	d0,a0
	bsr.s	StrLen

Bytes2Longs:
; d0 = ByteLength
; -> d0 = LongwordLength
	tst.l	d0
	beq.s	1$
	subq.l	#1,d0
	lsr.l	#2,d0
	addq.l	#1,d0
1$:	rts


HunkFillBytes:
; Hunk-Block, der nicht auf Longword-Grenze endet, mit Nullen auffüllen
; d2 = Hunk-Size in Bytes
	movem.l	d2-d4,-(sp)
	move.w	d2,d0
	moveq	#3,d4
	and.w	d4,d0
	move.b	3$(pc,d0.w),d4
	beq.s	2$			; keine Füllbytes nötig?
	clr.l	-(sp)
	cmp.w	#HUNK_CODE,sec_Type+2(a2) ; Code-Section? (evtl. NOP-padding)
	bne.s	1$
	subq.w	#2,d0			; NOP-Padding nur für Word-Align interessant
	bne.s	1$
	tst.b	ZeroPadding(a5)
	bne.s	1$
	subq.l	#8,d2
	bmi.s	4$			; Wenn mindestens 8 Bytes da sind -
	move.l	d7,a1			;  prüfen ob diese alle Null waren
	moveq	#-8,d0
	moveq	#OFFSET_CURRENT,d1
	bsr	bio_seek
	tst.l	d0
	bmi.s	4$
	subq.l	#8,sp
	move.l	d7,a1
	move.l	sp,a0
	moveq	#8,d0
	bsr	bio_read
	movem.l	(sp)+,d0-d1
	or.l	d1,d0			; 8 Null-Bytes?
	beq.s	1$			;  dann auf *keinen Fall* NOP-padding !
4$:	move.w	#$4e71,(sp)		; NOP-Padding für Code-Hunks
1$:	move.l	d7,a1
	move.l	sp,a0
	move.l	d4,d0
	bsr	bio_write		; Füllbytes auf Longword-Grenze schreiben
	addq.l	#4,sp
	tst.l	d0
	bmi	WriteErrClose
2$:	movem.l	(sp)+,d2-d4
	rts
3$:	dc.b	0,3,2,1


BuildSymbolHunk:
; HUNK_SYMBOL für Symbole die ein Debugger mit Namen anzeigen soll
; a2 = Section
	movem.l	d2-d5/a3-a4,-(sp)
	btst	#sw_SYMDEBUG,Switches(a5) ; Symbol-Debug-Hunk anhaengen ?
	beq.s	4$
	move.l	sec_HunkSymbolTable(a2),d0
	beq.s	4$
	addq.l	#hsym_HEAD,d0
	move.l	sec_HSTPt(a2),d4
	cmp.l	d4,d0			; wird der Symbol-Hunk ueberhaupt benoetigt ?
	beq.s	4$
	move.l	#HUNK_SYMBOL,d0		; Hunk - Symbol
	bsr	WriteLong
	move.l	sec_HunkSymbolTable(a2),d0
1$:	move.l	d0,a4
	lea	hsym_HEAD(a4),a3
	move.w	#HSYMTABBLK/4-1,d5
2$:	cmp.l	d4,a3			; alle Symbole ausgegeben ?
	bhs.s	3$
	move.l	(a3)+,a0
	move.l	sym_Value(a0),d3
	move.l	sym_Name(a0),d0
	bsr	LongStrLen
	bsr	WriteLong		; Name-Laenge
	bsr	WriteString		; Name-String
	move.l	d3,d0
	bsr	WriteLong		; Symbol-Wert
	dbf	d5,2$
	move.l	(a4),d0			; Noch einen HunkSymbolTable-Chunk ?
	bne.s	1$
3$:	moveq	#0,d0
	bsr	WriteLong		; Ende der symbol data units
4$:	movem.l	(sp)+,d2-d5/a3-a4
	rts


BuildLineDebugHunk:
; HUNK_DEBUG mit LINE-Informationen für Source Level Debugging
; a2 = Section
	movem.l	d2-d5/a3,-(sp)
	move.l	sec_HunkLineDebug(a2),d0
	beq	9$
	move.l	d0,a0
	move.l	lindb_Ptr(a0),d0
	subq.l	#lindb_HEAD,d0
	cmp.l	a0,d0			; wird Debug-Hunk überhaupt benötigt?
	beq	9$
	move.l	#HUNK_DEBUG,d0		; Debug-Hunk
	bsr	WriteLong
	move.l	d7,a1
	moveq	#0,d0
	moveq	#OFFSET_CURRENT,d1
	bsr	bio_seek		; FilePointer-Position merken (d4)
	move.l	d0,d4
	moveq	#0,d0
	bsr	WriteLong		; HUNK_DEBUG-Länge mit 0 vorbelegen
	moveq	#0,d0
	bsr	WriteLong		; Link-Offset (interessiert nur den Linker)
	move.l	#"LINE",d0
	bsr	WriteLong		; Jetzt folgen LINE-Debug Informationen!
	move.l	DebugPath(a5),d0
	bsr	LongStrLen		; Name des Sourcecodes speichern
	bsr	WriteLong
	bsr	WriteString
	move.l	sec_HunkLineDebug(a2),d0
1$:	move.l	d0,a3
	lea	lindb_HEAD(a3),a0
	move.l	lindb_Ptr(a3),d0
	bne.s	2$
	lea	LINEDEBUGBLK(a0),a1
	move.l	a1,d0
2$:	move.l	d7,a1
	sub.l	a0,d0
	bsr	bio_write		; Chunk-Inhalt direkt als LINE-Debug übernehmen
	tst.l	d0			; Fehler ?
	bmi	WriteErrClose
	move.l	lindb_Link(a3),d0	; noch'n Chunk?
	bne.s	1$
	move.l	d7,a1
	move.l	d4,d0
	moveq	#OFFSET_BEGINNING,d1
	bsr	bio_seek
	move.l	d0,d2
	sub.l	d4,d0
	lsr.l	#2,d0
	subq.l	#1,d0
	bsr	WriteLong		; Länge des DEBUG-Hunks einsetzen
	move.l	d7,a1
	move.l	d2,d0
	moveq	#OFFSET_BEGINNING,d1
	bsr	bio_seek		;   und FilePointer zurücksetzen
9$:	movem.l	(sp)+,d2-d5/a3
	rts


BuildRelocHunk:
; a0 = HunkReloc-Ptr
; d5 = RelocType (HUNK_RELOC32, HUNK_DREL16, etc.)
	movem.l	d2-d4/a3-a4,-(sp)
	move.l	a0,-(sp)
	moveq	#0,d0			; max. benötigte Bytes fuer Hunk-Reloc
	move.l	#4*HUNKRELOCBLK/6,d2	;  berechnen
	move.l	a0,d1
1$:	move.l	d1,a0
	moveq	#0,d1
	move.w	hrel_Entries(a0),d1
	bpl.s	2$
	add.l	d2,d0
	move.l	(a0),d1			; Naechster Reloc-Chunk
	bne.s	1$
	bra.s	3$
2$:	add.l	d1,d1
	add.l	d1,d1
	add.l	d1,d0			; Speicherbedarf fuer Relocationen
3$:	move.l	d0,d3			; d3 = RelocMemSize
	move.l	a6,a3
	move.l	SysBase(a5),a6
	moveq	#0,d1
	jsr	AllocMem(a6)
	tst.l	d0
	beq	OutofMemErr
	move.l	a3,a6
	move.l	d0,a4			; a4 = RelocMemPtr
	move.l	d5,d0
	bsr	WriteLong		; Reloc-Block Header schreiben
	moveq	#0,d5
	move.w	SectionCnt(a5),d5	; Relocations auf jede bekannte Section
	subq.w	#1,d5
4$:	moveq	#0,d4			; d4 = Zaehler fuer Eintraege
	move.l	(sp),d0			; Zeiger auf ersten HunkReloc-Chunk holen
5$:	move.l	d0,a0
	lea	hrel_HEAD(a0),a3	; Tabelle nach Relocs fuer aktuelle Section
	move.w	hrel_Entries(a0),d2	;  absuchen
	bpl.s	7$
	move.w	#HUNKRELOCBLK/6,d2	; Max. moegliche Eintraege
	bra.s	7$
6$:	move.l	(a3)+,d0
	cmp.w	(a3)+,d5		; Relocation fuer aktuelle Section ?
	bne.s	7$
	move.l	d0,(a4)+		;  dann speichern
	addq.l	#1,d4			;  und Zaehler erhoehen
7$:	dbf	d2,6$
	move.l	(a0),d0			; noch ein HunkReloc-Chunk ?
	bne.s	5$
	move.l	d4,d0
	beq.s	9$			; kein Eintrag fuer diese Section ?
	bsr	WriteLong
	moveq	#0,d0
	lea	SecNumBuffer(a5),a0
	move.b	(a0,d5.w),d0
	bsr	WriteLong		; Bezugs-Section
8$:	move.l	-(a4),d0
	bsr	WriteLong		; Reloc-Offsets schreiben
	subq.l	#1,d4
	bne.s	8$
9$:	dbf	d5,4$			; Naechste Basis-Section
	moveq	#0,d0
	bsr	WriteLong		; 0 beendet den Reloc-Hunk
	move.l	a6,a3
	move.l	SysBase(a5),a6
	move.l	a4,a1
	move.l	d3,d0
	jsr	FreeMem(a6)		; RelocMem freigeben
	move.l	a3,a6
	addq.l	#4,sp
	movem.l	(sp)+,d2-d4/a3-a4
	rts


BuildXREFHunk:
; a2 = Symbol
; d2 = HiByte=OrigSecNum, LoByte=ReferenceType (REF32, REF16, REF8,
;      RELREF32 oder NearREF16)
; d7 = FileHandle
	movem.l	d2-d6/a3-a4,-(sp)
	move.w	d2,d6
	moveq	#0,d5			; Flag, ob Name schon geschrieben wurde
	move.l	sym_RefList(a2),d0
1$:	move.l	d0,a4
	lea	rlist_HEAD(a4),a3
	move.w	rlist_NumRefs(a4),d4
	bmi.s	2$
	subq.w	#1,d4
	bpl.s	3$
	bra	6$
2$:	move.w	#REFLISTBLK/rlistSIZE-1,d4
3$:	cmp.w	(a3),d6			; SectionNum. und Referenzart passen ?
	bne.s	5$
	tst.l	d5			; Name schon geschrieben ?
	bne.s	4$
	move.l	sym_Name(a2),d0
	bsr	LongStrLen
	swap	d0
	move.b	d6,d0			; RefType einsetzen
	lsl.w	#8,d0
	swap	d0
	bsr	WriteLong		; RefType und Name-Laenge
	bsr	WriteString		; Name-String
	move.l	d7,a1
	moveq	#0,d0
	moveq	#OFFSET_CURRENT,d1
	bsr	bio_seek		; FilePointer-Position merken (d5)
	move.l	d0,d5
	moveq	#0,d0
	bsr	WriteLong		; Zahl der Offsets mit 0 vorbelegen
	moveq	#0,d3			; d3 zaehlt die gefundenen Offsets
4$:	addq.l	#1,d3
	IFND	GIGALINES
	move.l	4(a3),d0		; Offset anhaengen
	ELSE
	move.l	6(a3),d0
	ENDC
	bsr	WriteLong
5$:	lea	rlistSIZE(a3),a3	; naechste Referenz
	dbf	d4,3$
	move.l	(a4),d0			; noch ein RefList-Chunk ?
	bne.s	1$
	move.l	d5,d0			; Wurde ueberhaupt eine Referenz gefunden ?
	beq.s	6$
	move.l	d3,d5			; Zahl der Referenzen in d5 retten
	move.l	d7,a1
	moveq	#OFFSET_BEGINNING,d1
	bsr	bio_seek
	move.l	d0,d2
	move.l	d5,d0
	bsr	WriteLong		; Referenz-Anzahl einsetzen
	move.l	d7,a1
	move.l	d2,d0
	moveq	#OFFSET_BEGINNING,d1
	bsr	bio_seek		;   und FilePointer zuruecksetzen
6$:	movem.l	(sp)+,d2-d6/a3-a4
	rts


WriteString:
; String auf Longwordgrenze mit 0-Bytes fuellen und in File ausgeben
; d7 = FileHandle
; a0 = String
	move.l	a2,-(sp)
	move.l	a0,a2
	subq.l	#4,sp
	bra.s	5$
1$:	move.l	sp,a1
	clr.l	(a1)
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	beq.s	2$
	move.b	(a2)+,(a1)+
	beq.s	2$
	move.b	(a2)+,(a1)+
	bne.s	3$
2$:	subq.l	#1,a2
3$:	move.l	(sp),d0
	bsr.s	WriteLong
5$:	tst.b	(a2)
	bne.s	1$
4$:	addq.l	#4,sp
	move.l	(sp)+,a2
	rts


WriteLong:
; ** a0 wird auch gerettet! **
; d0 = LongWord
; d7 = FileHandle
	movem.l	d0/a0,-(sp)
	move.l	d7,a1
	move.l	sp,a0
	moveq	#4,d0
	bsr	bio_write
	movem.l	(sp)+,d1/a0
	tst.l	d0			; Fehler ?
	bmi.s	WriteErrClose
	rts
WriteErrClose:
	move.l	d7,a1
	bsr	bio_close
WriteErr:
	move.l	SysBase(a5),a6
	moveq	#62,d0			; Write error
	bra	FatalErr


WriteHunkData:
; Den Inhalt aller HunkData-Chunks an das File anhaengen
; a0 = Section
; d7 = FileHandle
	movem.l	d4-d5/a2,-(sp)
	move.l	#HUNKDATBLK,d5
	move.l	sec_Size(a0),d4
	move.l	sec_HunkData(a0),d0
1$:	move.l	d0,a2
	cmp.l	d5,d4
	bhs.s	2$
	move.l	d4,d5
2$:	sub.l	d5,d4
	move.l	d7,a1
	lea	hd_HEAD(a2),a0
	move.l	d5,d0
	bsr	bio_write
	tst.l	d0
	bmi	WriteErrClose
	move.l	(a2),d0
	bne.s	1$
3$:	movem.l	(sp)+,d4-d5/a2
	rts


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


bio_read:
; a0 = Buffer
; a1 = struct bio *bf
; d0 = nBytes
; -> d0 = ...? / -1 = Error
	movem.l	d2-d5/a2-a3/a6,-(sp)
	move.l	a0,a2
	move.l	a1,a3
	move.l	d0,d4
	move.l	bio_sysbase(a3),a6
	move.l	bio_eof(a3),d0
	sub.l	bio_begin(a3),d0
	sub.l	bio_have(a3),d0
	cmp.l	d0,d4
	bls	2$
	move.l	d0,d4
	bra	2$
1$:	move.l	bio_bufsize(a3),d0
	sub.l	bio_have(a3),d0
	cmp.l	d0,d4
	bhi	4$
	move.l	d4,d0
4$:	move.l	d0,d5
	move.l	bio_bufptr(a3),a0
	add.l	bio_have(a3),a0
	move.l	a2,a1
	jsr	CopyMem(a6)
	move.l	bio_have(a3),d1
	add.l	d5,d1
	move.l	d1,bio_have(a3)
	sub.l	d5,d4
	add.l	d5,a2
	cmp.l	bio_bufsize(a3),d1
	bne	2$
	move.l	bio_dosbase(a3),a6
	move.l	bio_fh(a3),d5
	move.l	bio_rec_end(a3),d3
	beq	5$
	move.l	d5,d1
	move.l	bio_bufptr(a3),d2
	jsr	Write(a6)
	tst.l	d0
	bmi	3$
5$:	move.l	d5,d1
	move.l	bio_begin(a3),d2
	add.l	bio_bufsize(a3),d2
	move.l	d2,bio_begin(a3)
	moveq	#OFFSET_BEGINNING,d3
	jsr	Seek(a6)
	tst.l	d0
	bmi	3$
	move.l	d5,d1
	move.l	bio_bufptr(a3),d2
	move.l	bio_bufsize(a3),d3
	jsr	Read(a6)
	move.l	bio_sysbase(a3),a6
	clr.l	bio_have(a3)
	clr.l	bio_rec_end(a3)
	tst.l	d0
	bmi	3$
2$:	tst.l	d4
	bne	1$
3$:	movem.l	(sp)+,d2-d5/a2-a3/a6
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


	IFND	FREEASS
AbsoluteFile:
; Absoluten Code in einem File ablegen
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	moveq	#0,d7			; kein File offen
	move.l	LinSecList(a5),a4
	move.w	SectionCnt(a5),d6
	subq.w	#1,d6
1$:	move.l	(a4)+,a2		; a2 Next Section
	tst.w	sec_Type+2(a2)		; Offset-Section?
	beq.s	2$
	move.l	sec_Destination(a2),d4	; Dest-Filename angegeben ?
	beq.s	5$
	tst.l	d7			; altes File schliessen ?
	beq.s	4$
	move.l	d7,a1
	bsr	bio_close
	move.l	d5,d1
	moveq	#%0010,d2		; rw-d Protection
	jsr	SetProtection(a6)
4$:	move.l	d4,d5			; FileName merken
	move.l	d4,d1
	move.l	#MODE_NEWFILE,d2	; neues File für Section öffnen
	jsr	Open(a6)
	move.l	d0,d2
	beq	WriteErr
	move.l	bioBufSize(a5),d1
	bsr	bio_buf
	move.l	d0,d7
	bne.s	5$
	move.l	d2,d1
	jsr	Close(a6)
	bra	WriteErr
5$:	move.l	a2,a0			; Alle HunkData-Chunks ins File schreiben
	bsr	WriteHunkData
2$:	dbf	d6,1$
	tst.l	d7			; FERTIG
	beq.s	9$
	move.l	d7,a1
	bsr	bio_close		; letztes File schliessen
	move.l	d5,d1
	moveq	#%0010,d2		; rw-d Protection für letztes File
	jsr	SetProtection(a6)
9$:	move.l	(sp)+,a6
	rts


CopyToAddr:
; Code absolut in den Speicher schreiben
	moveq	#0,d7			; noch kein Code nach Dest. geschrieben
	move.l	LinSecList(a5),a4
	move.w	SectionCnt(a5),d6
	subq.w	#1,d6
1$:	move.l	(a4)+,a0		; Next Section
	tst.w	sec_Type+2(a0)		; Offset-Section?
	beq.s	2$
	move.l	sec_Destination(a0),d0	; Dest-Adresse
	beq.s	6$			; keine ? - ab der alten weitermachen
	move.l	d0,d7
6$:	move.l	#HUNKDATBLK,d5
	move.l	sec_Size(a0),d4
	beq.s	2$
	move.l	sec_HunkData(a0),d0
4$:	move.l	d0,a2
	cmp.l	d5,d4
	bhs.s	5$
	move.l	d4,d5
5$:	sub.l	d5,d4
	move.l	d5,d0
	lea	hd_HEAD(a2),a0		; Source
	move.l	d7,a1			; Dest
	add.l	d0,d7			;  um Size Bytes verschieben
	jsr	CopyMem(a6)
	move.l	(a2),d0			; nächster HunkData-Block
	bne.s	4$
2$:	dbf	d6,1$
	rts


Trackdisk3:
	moveq	#3,d7
	bra.s	TDSave
Trackdisk2:
	moveq	#2,d7
	bra.s	TDSave
Trackdisk1:
	moveq	#1,d7
	bra.s	TDSave
Trackdisk0:
	moveq	#0,d7

TDSave:
	jsr	CreateMsgPort(a6)
	move.l	d0,d6
	beq	OutofMemErr
	move.l	d0,a0
	move.l	#iostd_SIZE,d0
	jsr	CreateIORequest(a6)
	move.l	d0,a4
	tst.l	d0
	bne.s	1$
	move.l	d6,a0
	jsr	DeleteMsgPort(a6)
	bra	OutofMemErr
1$:	lea	TDName(pc),a0
	move.l	d7,d0
	moveq	#0,d1
	move.l	a4,a1
	jsr	OpenDevice(a6)		; Trackdisk-Device öffnen
	tst.b	d0
	beq.s	20$
	move.l	a4,a0
	jsr	DeleteIORequest(a6)
	move.l	d6,a0
	jsr	DeleteMsgPort(a6)
	moveq	#25,d0			; Can't open trackdisk.device
	bra	FatalErr

20$:	move.l	d6,-(sp)		; LocalPort retten
	moveq	#0,d7
	move.l	TDBuffer(a5),a3		; a3 Sector-Buffer
	move.l	LinSecList(a5),a1
	move.w	SectionCnt(a5),d1
	subq.w	#1,d1
2$:	move.l	(a1)+,a2		; Next Section a2
	movem.l	d1/a1,-(sp)
	tst.w	sec_Type+2(a2)		; Offset-Section?
	beq	11$

	move.l	sec_Destination(a2),d0
	beq.s	24$			; TRACKDISK nicht gesetzt fuer diese Section?
	move.l	d0,d7
	move.l	d7,d3
	and.l	#$fffffe00,d7
	and.l	#$1ff,d3
24$:	move.l	a4,a1
	move.w	#CMD_READ,io_Command(a1)
	move.l	a3,io_Data(a1)
	move.l	#TD_SECTOR,io_Length(a1)
	move.l	d7,io_Offset(a1)
	jsr	DoIO(a6)		; ersten Block in Buffer holen
	move.l	#HUNKDATBLK,d5
	move.l	sec_Size(a2),d4
	beq	99$
	move.l	sec_HunkData(a2),a2	; a2 Section-Data
	lea	0(a3,d3.l),a1
	move.l	#TD_SECTOR,d2
	cmp.l	d4,d2
	blo.s	3$
	move.l	d4,d0
	add.l	d3,d0
	cmp.l	d0,d2
	blo.s	3$
	move.l	d4,d2
	bra.s	4$
3$:	sub.l	d3,d2
4$:	cmp.l	d5,d4
	bhs.s	5$
	move.l	d4,d3
	bra.s	6$
5$:	move.l	d5,d3
6$:	lea	hd_HEAD(a2),a0
7$:	subq.l	#1,d4
	move.b	(a0)+,(a1)+		; Aus HunkData ins ChipRAM
	subq.l	#1,d3
	beq.s	8$
	subq.l	#1,d2
	bne.s	7$
	move.l	a0,-(sp)
	move.l	a4,a1			; Trackdisk-Buffer voll
	move.w	#CMD_WRITE,io_Command(a1)
	move.l	a3,io_Data(a1)
	move.l	#TD_SECTOR,d2
	move.l	d2,io_Length(a1)
	move.l	d7,io_Offset(a1)
	add.l	d2,d7
	jsr	DoIO(a6)
	cmp.l	d2,d4			; naechster Sector ist der letzte ?
	bhi.s	71$
	move.l	a4,a1
	move.w	#CMD_READ,io_Command(a1)
	move.l	a3,io_Data(a1)
	move.l	#TD_SECTOR,d2
	move.l	d2,io_Length(a1)
	move.l	d7,io_Offset(a1)
	jsr	DoIO(a6)
71$:	move.l	(sp)+,a0
	move.l	a3,a1
	bra.s	7$
8$:	subq.l	#1,d2
	move.l	(a2),a2			; naechster Chunk
	tst.l	d4
	bne.s	4$

	move.l	a4,a1			; letzten Sector schreiben
	move.w	#CMD_WRITE,io_Command(a1)
	move.l	a3,io_Data(a1)
	move.l	#TD_SECTOR,io_Length(a1)
	move.l	d7,io_Offset(a1)
	jsr	DoIO(a6)
9$:	move.l	a4,a1
	move.w	#CMD_UPDATE,io_Command(a1)
	jsr	DoIO(a6)
99$:	move.l	#TD_SECTOR,d3
	tst.l	d2			; d7 und d3 fuer naechste Section setzen
	bne.s	10$
	add.l	d3,d7
	moveq	#0,d3
	bra.s	11$
10$:	sub.l	d2,d3			; Offset
11$:	movem.l	(sp)+,d1/a1
	dbf	d1,2$
	move.l	a4,a1			; CleanUp
	move.w	#TD_MOTOR,io_Command(a1)
	clr.l	io_Length(a1)
	jsr	DoIO(a6)
	move.l	(sp)+,a0
	jsr	DeleteMsgPort(a6)
	move.l	a4,a1
	jsr	CloseDevice(a6)
	move.l	a4,a0
	jmp	DeleteIORequest(a6)


TDName:
	dc.b	"trackdisk.device",0
	even


SRecord:
; Motorola S-Records erzeugen
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	moveq	#0,d7			; kein File offen
	move.l	LinSecList(a5),a4
	move.w	SectionCnt(a5),d6
	subq.w	#1,d6
1$:	move.l	(a4)+,a2		; a2 Next Section
	tst.w	sec_Type+2(a2)		; Offset-Section?
	beq.s	2$
	move.l	sec_Destination(a2),d4	; Dest-Filename angegeben ?
	beq.s	5$
	tst.l	d7			; altes File schliessen ?
	beq.s	4$
	bsr	writeSTrailer
4$:	bsr	writeSHeader
5$:	move.l	a2,a0			; Alle Data-Chunks als S2-Records schreiben
	bsr	writeS2
2$:	dbf	d6,1$
	tst.l	d7			; FERTIG
	beq.s	9$
	bsr	writeSTrailer
9$:	move.l	(sp)+,a6
	rts


writeSTrailer:
; d7 = FileHandle
; d5 = FileName
	move.l	d6,d4
	move.w	#'S9',d0		; S7/S8/S9-Trailer schreiben
	sub.b	SRecType(a5),d0
	swap	d0
	clr.w	d0
	move.l	d0,-(sp)
	move.l	sp,d2
	bsr	vfprintf
	addq.l	#4,sp
	lea	Buffer(a5),a0
	moveq	#1,d0
	add.b	SRecType(a5),d0
	move.w	d0,d6
	addq.w	#2,d6
	move.b	d6,(a0)+
1$:	clr.b	(a0)+
	dbf	d0,1$
	bsr	writesrec
	move.l	d7,d1
	jsr	Close(a6)
	move.l	d4,d6
	move.l	d5,d1
	moveq	#%0010,d2		; rw-d Protection
	jmp	SetProtection(a6)


writeS2:
; Den Inhalt aller HunkData-Chunks einer Section als S2-Records speichern
; a0 = Section
; d7 = FileHandle
; a6 = DOSBase
	movem.l	d2-d6/a2-a4,-(sp)
	move.l	#HUNKDATBLK,d4
	move.l	sec_Size(a0),d5
	move.l	sec_Origin(a0),a4
	move.l	sec_HunkData(a0),a3
	lea	hd_HEAD(a3),a2
	bra	6$
1$:	moveq	#0,d6			; weitere SRecord-Zeile erzeugen
	move.b	SRecLen(a5),d6
	sub.b	SRecType(a5),d6
	subq.b	#3,d6
	sub.l	d6,d5
	bpl.s	2$
	add.l	d5,d6			; keine vollständige Zeile mehr vorhanden?
	moveq	#0,d5
2$:	move.w	#'S1',d0		; S1/S2/S3-Kennung schreiben
	add.b	SRecType(a5),d0
	swap	d0
	clr.w	d0
	move.l	d0,-(sp)
	move.l	sp,d2
	bsr	vfprintf
	addq.l	#4,sp
	move.w	d6,d0
	lea	Buffer(a5),a0
	move.l	a4,d1
	cmp.b	#1,SRecType(a5)
	bhi.s	23$
	beq.s	22$
	addq.w	#3,d6			; S1
	move.b	d6,(a0)+
	swap	d1
	bra.s	20$
22$:	addq.w	#4,d6			; S2
	move.b	d6,(a0)+
	swap	d1
	move.b	d1,(a0)+
	bra.s	20$
23$:	addq.w	#5,d6			; S3
	move.b	d6,(a0)+
	rol.l	#8,d1
	move.b	d1,(a0)+
	rol.l	#8,d1
	move.b	d1,(a0)+
20$:	rol.l	#8,d1
	move.b	d1,(a0)+
	rol.l	#8,d1
	move.b	d1,(a0)+
	add.w	d0,a4
	subq.w	#1,d0
3$:	move.b	(a2)+,(a0)+
	subq.l	#1,d4
	bne.s	4$
	move.l	(a3),a3			; nächster HunkData-Chunk
	lea	hd_HEAD(a3),a2
	move.l	#HUNKDATBLK,d4
4$:	dbf	d0,3$
	bsr	writesrec
6$:	tst.l	d5			; noch weitere Bytes in dieser Section?
	bne	1$
	movem.l	(sp)+,d2-d6/a2-a4
	rts


writeSHeader:
; d4 = Filename
; -> d5 = Filename
; -> d7 = FileHandle
	move.l	d4,d5			; FileName merken
	move.l	d4,d1
	move.l	#MODE_NEWFILE,d2	; neues File fuer Section oeffnen
	jsr	Open(a6)
	move.l	d0,d7
	beq	WriteErr
	move.l	#"S0\0\0",-(sp)
	move.l	sp,d2
	bsr	vfprintf		; S0 schreiben
	addq.l	#4,sp
	move.l	d5,a0
	bsr	StrLen			; strlen des FileName bestimmen
	move.l	d6,d4
	move.w	d0,d6
	addq.w	#3,d6			; + len-Byte und zwei Null-Bytes
	lea	Buffer(a5),a1
	move.b	d6,(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	move.l	d5,a0
	subq.w	#1,d0
1$:	move.b	(a0)+,(a1)+		; FileName kopieren
	dbf	d0,1$
	bsr.s	writesrec
	move.l	d4,d6
	rts


writesrec:
; Buffer enthält den zu schreibenden Record
; d6 = Record-Length
	movem.l	d0/d2-d5/a2-a3,-(sp)
	lea	sbyte(pc),a3
	moveq	#0,d4
	moveq	#0,d5
	subq.b	#1,d5			; ChkSum-Init (von $ff an herunterzählen)
	lea	Buffer(a5),a2
	subq.w	#1,d6
1$:	move.b	(a2)+,d4
	sub.b	d4,d5
	move.l	d4,(sp)
	move.l	a3,d2
	move.l	sp,d3
	bsr.s	vfprintf		; ein Hex-Byte schreiben
	dbf	d6,1$
	lea	schksum(pc),a0
	move.l	d5,(sp)			; Prüfsumme schreiben
	move.l	a0,d2
	move.l	sp,d3
	bsr.s	vfprintf
	movem.l	(sp)+,d0/d2-d5/a2-a3
	rts


vfprintf:
	move.l	d7,d1
	jsr	VFPrintf(a6)
	tst.l	d0
	bmi.s	1$
	rts
1$:	move.l	d7,d1
	jsr	Close(a6)
	bra	WriteErr


sbyte:
	dc.b	"%02lx",0
schksum:
	dc.b	"%02lx\n",0
	even
	ENDC


FatalErr:
	jmp	FatalError

OutofMemErr:
	jmp	OutofMemError


	end
