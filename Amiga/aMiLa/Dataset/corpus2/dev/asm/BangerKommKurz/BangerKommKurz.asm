;Programm: BangerKommKurz ist ein Prog. zum entfernen von Kommentaren in Includes (nur Assembler) und anderen Assembler-Sourcecodes
;   Autor: Andre´ Trettin
;Codename: Banger
;   Begin: 02-Jan-96 14:00:00
;    $VER: BangerKommKurz.Asm 1.3 (4-Sep-96)

** INCLUDE Struktur Variablen
* Fehler Codes: 21=kein Speicher
*               22=konnte DOS.library nicht öffnen
*               23=konnte File nicht öffnen

	incdir INCLUDE:
	include lvo/dos_lib.i
	include lvo/exec_lib.i
	include dos/dos.i
	include exec/exec.i

	STRUCTURE Internal,0
	APTR    DOSBase
	APTR    TempArray
	APTR    ALLArg
	APTR    QUIETArg
	APTR    RDArgs
	APTR    FileListe
	APTR    letztesFile
	APTR    MyBasisLock
	APTR    JetzigeLock
	APTR    OutputHandle
	STRUCT  JetzigerFIB,[fib_SIZEOF]
	STRUCT  FIBs,[fib_SIZEOF*21]
	STRUCT  MyLocks,[4*21]
	STRUCT  BufferName,[512]
	WORD    DirAnzahl
*; Unterprog File bearbeitung ****
	APTR    FileMem
	APTR    FileHandle
	STRUCT  FileNameList,[256*256]
	LABEL   Int_SIZEOF
;;
** Int-Speicher reservieren + dos.lib öffene
	moveq   #0,d7
	move.l  4.w,a6
	move.l  #Int_SIZEOF,d0
	move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr     _LVOAllocMem(a6)
	move.l  d0,a5
	bne.s   LibraryOeffnen
	moveq   #21,d7           ;21 = kein Speicher
	bra.w   Ende
LibraryOeffnen
	lea     dosname(pc),a1
	moveq   #37,d0
	jsr     _LVOOpenLibrary(a6)
	move.l  d0,DOSBase(a5)
	bne.s   LibOK
	moveq   #22,d7              ;22 = konnte dos.library nicht öffnen
	bra.w   IntMemFree
;;
** Parse Parameter with readarg
LibOK
	move.l  DOSBase(a5),a6
	lea     Comtemplate(pc),a1
	move.l  a1,d1
	lea     TempArray(a5),a1
	move.l  a1,d2
	moveq   #0,d3
	jsr     _LVOReadArgs(a6)
	move.l  d0,RDArgs(a5)
	bne.s   ParaOK
	bsr.w   DOS_Fehler
	bra.w   SchliesseLib
;;
** Filesearch routine
ParaOK
	jsr     _LVOOutput(a6)
	move.l  d0,OutputHandle(a5)
	tst.l   QUIETArg(a5)
	bne.s   keinWillkommen
	move.l  d0,d1
	lea     Willkommen(pc),a0
	move.l  a0,d2
	moveq   #WillkommenEnde-Willkommen,d3
	jsr     _LVOWrite(a6)
keinWillkommen
;    lea     TempPC(pc),a0
;    move.l  a0,TempArray(a5)
Filesearch
	moveq   #0,d6
	move.l  TempArray(a5),a4
	lea     FileNameList(a5),a1
	move.l  a1,d4
naechstesTArray
	move.l  (a4)+,d1
	beq.w   keinFilemehr
	move.l  #ACCESS_READ,d2
	jsr     _LVOLock(a6)
	move.l  d0,MyBasisLock(a5)
	bne.s   LockisOK
	bsr.w   DOS_Fehler
	bra.w   keinFilemehr
LockisOK
	move.l  MyBasisLock(a5),JetzigeLock(a5)
naechstesDir
	move.l  JetzigeLock(a5),d1
	lea     JetzigerFIB(a5),a3
	move.l  a3,d2
	jsr     _LVOExamine(a6)
	tst.l   d0
	bne.s   ExamineIsOK
	bsr.w   DOS_Fehler
	bra.w   UnlockMyBasis
ExamineIsOK
	move.l  fib_DirEntryType(a3),d0
	tst.l   d0
	bmi.w   einFile
naechstesFile
	move.l  JetzigeLock(a5),d1
	lea     JetzigerFIB(a5),a3
	move.l  a3,d2
	jsr     _LVOExNext(a6)
	tst.l   d0
	bne.s   FileOderDir
	jsr     _LVOIoErr(a6)
	cmp.w   #ERROR_NO_MORE_ENTRIES,d0
	beq.s   JetzigeUnlock
	bsr.w   DOS_Fehler
JetzigeUnlock
	sub.w   #1,DirAnzahl(a5)
	move.w  DirAnzahl(a5),d5
	tst.w   d5
	bmi.w   UnlockMyBasis
	move.l  JetzigeLock(a5),d1
	jsr     _LVOUnLock(a6)
	move.w  d5,d1
	asl.w   #2,d1
	lea     MyLocks(a5),a0
	lea     (a0,d1.w),a0
	move.l  (a0),JetzigeLock(a5)
	move.w  #fib_SIZEOF,d0
	mulu    d0,d5
	lea     FIBs(a5),a0
	lea     (a0,d5.w),a0
	subq    #1,d0
restoreFIB
	move.b  (a0)+,(a3)+
	dbra    d0,restoreFIB
	bra.s   naechstesFile
FileOderDir
	move.l  fib_DirEntryType(a3),d0
	tst.l   d0
	bmi.s   einFileImDir
	tst.l   ALLArg(a5)
	beq.s   naechstesFile
	move.w  DirAnzahl(a5),d5
	move.w  d5,d1
	add.w   #1,DirAnzahl(a5)
	asl.w   #2,d1
	lea     MyLocks(a5),a2
	lea     (a2,d1.w),a2
	move.l  JetzigeLock(a5),(a2)
	move.l  JetzigeLock(a5),d1
	lea     BufferName(a5),a2
	move.l  a2,d2
	move.l  #512,d3
	jsr     _LVONameFromLock(a6)
	move.l  a2,d1
	lea     fib_FileName(a3),a0
	move.l  a0,d2
	move.l  #512,d3
	jsr     _LVOAddPart(a6)
	move.l  a2,d1
	move.l  #ACCESS_READ,d2
	jsr     _LVOLock(a6)
	move.l  d0,JetzigeLock(a5)
	move.w  #fib_SIZEOF,d0
	mulu    d0,d5
	lea     FIBs(a5),a0
	lea     (a0,d5.w),a0
	subq    #1,d0
copyFIB
	move.b  (a3)+,(a0)+
	move.b  #0,-1(a3)
	dbra    d0,copyFIB
	bra.w   naechstesDir
einFile
	moveq   #-1,d6
einFileImDir
	move.l  JetzigeLock(a5),d1
	lea     BufferName(a5),a0
	move.l  a0,d2
	move.l  #512,d3
	jsr     _LVONameFromLock(a6)
	tst.l   d6
	bmi.s   einFileName
	lea     BufferName(a5),a0
	move.l  a0,d1
	lea     fib_FileName(a3),a0
	move.l  a0,d2
	move.l  #512,d3
	jsr     _LVOAddPart(a6)
einFileName
	lea     BufferName(a5),a0
	move.l  d4,a1
FileNameListLoop
	move.b  (a0)+,(a1)+
	tst.b   -1(a0)
	bne.s   FileNameListLoop
	move.l  a1,d4
	tst.l   d6
	beq.w   naechstesFile
	moveq   #0,d6
UnlockMyBasis
	move.l  MyBasisLock(a5),d1
	jsr     _LVOUnLock(a6)
	bra.w   naechstesTArray
keinFilemehr
;;
** FileBearbeit
* a5 : Internal-struct
FileBearbeit
	lea     FileNameList(a5),a4
naechstesFileBe
	lea     BufferName(a5),a0
FileBufferCopy
	move.b  (a4)+,(a0)+
	tst.b   -1(a4)
	bne.s   FileBufferCopy
	move.l  DOSBase(a5),a6
	tst.l   QUIETArg(a5)
	bne.s   keinFileNameAus
	lea     BufferName(a5),a0
	move.l  a0,d1
FileLaengeLoop
	tst.b   (a0)+
	bne.s   FileLaengeLoop
	move.l  a0,d2
	sub.l   d1,d2
	jsr     _LVOWriteChars(a6)
	lea     LeerZwei(pc),a0
	move.l  a0,d1
	moveq   #2,d2
	jsr     _LVOWriteChars(a6)
keinFileNameAus
	lea     BufferName(a5),a0
	move.l  a0,d1
	move.l  #MODE_OLDFILE,d2
	jsr     _LVOOpen(a6)
	move.l  d0,FileHandle(a5)
	bne.s   geoeffnet
	bsr.w   DOS_Fehler
	bra.w   FileSucheEnde
geoeffnet
	move.l  FileHandle(a5),d1
	lea     FIBs(a5),a3
	move.l  a3,d2
	jsr     _LVOExamineFH(a6)
	move.l  4.w,a6
	move.l  fib_Size(a3),d0
	add.l   d0,d0
	move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr     _LVOAllocMem(a6)
	move.l  d0,FileMem(a5)
	bne.s   FileSpeicherOK
	moveq   #21,d7
	bra.w   FileSucheEnde
FileSpeicherOK
	move.l  FileHandle(a5),d1
	move.l  FileMem(a5),d2
	move.l  fib_Size(a3),d3
	move.l  DOSBase(a5),a6
	jsr     _LVORead(a6)
	move.l  FileHandle(a5),d1
	jsr     _LVOClose(a6)
	lea     BufferName(a5),a0
	move.l  a0,d1
	move.l  #MODE_NEWFILE,d2
	jsr     _LVOOpen(a6)
	move.l  d0,FileHandle(a5)
	bne.s   NeuesGeoeffnet
	bsr.s   DOS_Fehler
	bra.s   FileSucheEnde
NeuesGeoeffnet
	move.l  FileMem(a5),a0
	move.l  fib_Size(a3),d0
	bsr.s   KommentarKuerzen
	move.l  FileHandle(a5),d1
	move.l  a2,d2
	move.l  d0,d3
	jsr     _LVOWrite(a6)
	move.l  FileHandle(a5),d1
	jsr     _LVOClose(a6)
	tst.l   QUIETArg(a5)
	bne.s   FileSpeicherFrei
	lea     Return(pc),a0
	move.l  a0,d1
	moveq   #2,d2
	jsr     _LVOWriteChars(a6)
FileSpeicherFrei
	move.l  4.w,a6
	move.l  fib_Size(a3),d0
	add.l   d0,d0
	move.l  FileMem(a5),a1
	jsr     _LVOFreeMem(a6)
FileSucheEnde
	move.l  DOSBase(a5),a6
	tst.b   (a4)
	bne.w   naechstesFileBe
;;
** FreeArgs
	move.l  RDArgs(a5),d1
	jsr     _LVOFreeArgs(a6)
;;
** dos.library schliessen + int speicher freigeben + ende
SchliesseLib
	move.l  4.w,a6
	move.l  DOSBase(a5),a1
	jsr     _LVOCloseLibrary(a6)
IntMemFree
	move.l  a5,a1
	move.l  #Int_SIZEOF,d0
	jsr     _LVOFreeMem(a6)
Ende
	move.l  d7,d0
	rts
;;
** KommentarKuerzen
* d0 = Größe  des zu kürzendes Files mit Kommentaren
* a0 = Pointer auf das File (Speicher muß doppelt so groß sein)
*    d0 = Größe des gekürzten Files
*    a2 = Pointer auf das gekürzte File
* d0-d4, a0-a2
KommentarKuerzen
	lea     (a0,d0.l),a1
	move.l  a1,a2
NaechsteZeile
	moveq   #0,d3
	moveq   #0,d4
	sub.l   #1,d0
	bmi.s   FileEnde
	move.b  (a0)+,d1
	cmp.b   #'*',d1
	beq.w   KommentarZeile
	cmp.b   #';',d1
	beq.w   KommentarZeile
	cmp.b   #10,d1
	beq.s   NaechsteZeile
	cmp.b   #' ',d1
	beq.s   AnfangTabLeer
	cmp.b   #9,d1
	beq.s   AnfangTabLeer
AnfangKurz
	move.b  d1,(a1)+
ZeileWeiterBe
	sub.l   #1,d0
	bmi.s   FileEnde
	move.b  (a0)+,d1
LeerZeichenBeendet
	cmp.b   #'"',d1
	beq.w   SelektAnfuehrung
	cmp.b   #"'",d1
	beq.w   SelektHochKomma
	cmp.b   #'*',d1
	beq.s   KannKomment
	cmp.b   #';',d1
	beq.s   KannKomment
	cmp.b   #' ',d1
	beq.s   LeerTabZeichen
	cmp.b   #9,d1
	beq.s   LeerTabZeichen
StringCheckt
	move.b  d1,(a1)+
	cmp.b   #10,d1
	bne.s   ZeileWeiterBe
	bra.s   NaechsteZeile
FileEnde
	sub.l   a2,a1
	move.l  a1,d0
	rts
LeerTabZeichen
	tst.b   d3
	bne.s   StringCheckt
	tst.b   d4
	bne.s   StringCheckt
	moveq   #0,d2
LeerTabLoop
	sub.l   #1,d0
	bmi.s   FileEnde
	move.b  (a0)+,d1
	cmp.b   #9,d1
	beq.s   LeerTabLoop
	cmp.b   #' ',d1
	beq.s   LeerTabLoop
	move.b  #' ',(a1)+
	bra.w   LeerZeichenBeendet
AnfangTabLeer
	sub.l   #1,d0
	bmi.s   FileEnde
	move.b  (a0)+,d1
	cmp.b   #9,d1
	beq.s   AnfangTabLeer
	cmp.b   #' ',d1
	beq.s   AnfangTabLeer
	cmp.b   #'*',d1
	beq.w   KommentarZeile
	cmp.b   #';',d1
	beq.s   KommentarZeile
	cmp.b   #10,d1
	beq.w   NaechsteZeile
	move.b  #' ',(a1)+
	bra.w   AnfangKurz
KannKomment
	tst.b   d3
	bne.s   StringCheckt
	tst.b   d4
	bne.s   StringCheckt
	cmp.b   #'*',d1
	bne.s   KommentarLoop
	move.b  -2(a0),d2
	cmp.b   #' ',d2
	beq.s   KommentarLoop
	cmp.b   #9,d2
	beq.s   KommentarLoop
	bra.w   StringCheckt
KommentarLoop
	sub.l   #1,d0
	cmp.b   #10,(a0)+
	bne.s   KommentarLoop
	move.b  #10,(a1)+
	bra.w   NaechsteZeile
SelektAnfuehrung
	tst.b   d3
	bne.s   AnfuehrungJa
	moveq   #1,d3
	bra.w   StringCheckt
AnfuehrungJa
	moveq   #0,d3
	bra.w   StringCheckt
SelektHochKomma
	tst.b   d4
	bne.s   HochKommaJa
	moveq   #1,d4
	bra.w   StringCheckt
HochKommaJa
	moveq   #0,d4
	bra.w   StringCheckt
KommentarZeile
	sub.l   #1,d0
	cmp.b   #10,(a0)+
	bne.s   KommentarZeile
	bra.w   NaechsteZeile
;;
** DOS-Fehler + Ausgabe routine
DOS_Fehler
	jsr     _LVOIoErr(a6)
	move.l  d0,d1
	moveq   #0,d2
	jsr     _LVOPrintFault(a6)
	rts
;;
** Byte Daten
LeerZwei    dc.b 9,9,0
Return      dc.b 10,0
Willkommen  dc.b 10,10,'$VER: BangerKommKurz 1.3 (4-Sep-96)',10
			dc.b 'BangerKommKurz is Freeware. Use at your own risk',10
			dc.b 'Copyright by Andre´ Trettin',10,10
WillkommenEnde
Comtemplate dc.b 'FILES/A/M,ALL/S,QUIET/S',0
dosname     DOSNAME
;        even
;TempPC  dc.l File0,0
;File0   dc.b 'Ram:intuition.i.bak',0
;;
