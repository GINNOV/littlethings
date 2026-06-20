
debugbool	=	0		bei TRUE ist Debug-Modus an

;;	*****************************************************************
	*	Programm:	fdAsmInc				*
	*			(.fd-Files in Assemblerincludes kon-	*
	*			 vertieren)				*
	*	Copyright:	Freeware © von Hanns Holger Rutz (Tro-	*
	*			picDesign)				*
	*	History:	10.12.92-1.1.93	erste Version mit klei-	*
	*					nen Fehlern		*
	*			2-13.1.93	Source neu geschrieben	*
	*			30.07.1993	minor Bugs removed	*
	*					(RETURN_FAIL statt	*
	*					 RETURN_ERROR, BOOL-	*
	*					 Werte=WORDS, Versions-	*
	*					 string ($A0 statt $0A)	*
	*	Zukunft:	ALL-Option?				*
	*			[created] -> DestDir, wenn Src=Pattern?	*
	*			FROM/M?					*
	*****************************************************************

;;-- Includes --

		incdir	'sys:asm/inc/'
		include	'dos/dosasl.i'
		include	'dos/dosextens.i'
		include	'exec/execbase.i'
		include	'exec/memory.i'
		include	'private/dos_lib.i'	_LVO-File
		include	'private/exec_lib.i'	 "   "

;;-- Macros --

exec		macro
		if NARG
			move.l	4.w,\1
		else
			movea.l	4.w,lb
		endc
		endm

dos		macro
		if NARG
			move.l	gl_DOSBase(gl),\1
		else
			movea.l	gl_DOSBase(gl),lb
		endc
		endm

fjsr		macro
		jsr	_LVO\1(lb)
		endm

push		macro
		movem.l	\1,-(sp)
		endm

pull		macro
		movem.l	(sp)+,\1
		endm

rsword		macro
.addr		rs.b	0
		rs.b	.addr&1		eventuell auf WORD-Länge aufrunden
		endm

rslong		macro
.addr		rs.b	0
		rs.b	(-.addr)&3	eventuell auf LONG-Länge aufrunden
		endm

version		macro
		dc.b	'1.0b'		Version/Revision des Programms
		endm

;;-- Konstanten --

lb		equr	a6		Librarybasis
gl		equr	a5		globale Variablen
lo		equr	a4		lokale Variablen
		rsreset
gl_DOSBase	rs.l	1
gl_Result2	rs.l	1
gl_Process	rs.l	1		eigener Process
gl_Arg		rs.l	1		Array für Printf-Argument
gl_InputBuf	rs.b	512		Puffer für Continue-Abfrage
gl_SourceBuf	rs.l	1		Adresse des QuellMems (Ende: LF+##end)
gl_RDArgs	rs.l	1		Ergebnis von ReadArgs()
gl_Array	rs.b	0		Array für ReadArgs()
gl_aFrom	rs.l	1		..QuellName
gl_aTo		  rs.l	1		..ZielName
gl_aComments	  rs.l	1		..Kommentare/S
gl_aSpaces	  rs.l	1		..Spaces/S
gl_aTabs	  rs.l	1		..Tab(größe)/N
gl_aDec		  rs.l	1		..Dezimal/S
gl_aHex		  rs.l	1		..Hexdezimal/S
GL_AEND		  rs.b	0
gl_aSIZEOF	=	GL_AEND-gl_Array
gl_DestOld	rs.l	1		altes ZielDir-Lock
gl_DestDup	rs.l	1		Sicherheits-Lock des Ziels (wenn Dir)
gl_DestName	rs.l	1		*Name des Ziels (von DirLock aus)
gl_State	rs.b	1		allgemeine Flags
		rslong
gl_AnchorPath	rs.b	ap_SIZEOF	AnchorPath der Quelle
		rsword
gl_SIZEOF	rs.b	0

FLB_ANCHOR	=	0		Flag: gesetzt->AnchorPath initialisiert
FLB_ABORT	=	1		Flag: gesetzt->Continue unmöglich

;;-- Startup --

_Start		move.w	#(gl_SIZEOF/2)-1,d0
.ClearGlobal	clr.w	-(sp)				globales VarMem anlegen
		dbf	d0,.ClearGlobal
		movea.l	sp,gl
		exec
		move.l	ThisTask(lb),gl_Process(gl)	ProcessPtr sichern
		bsr.w	_OpenDOS			DOS.library öffnen
		beq.w	_Quit				..Fehler
		if debugbool
			lea.l	gl_Array(gl),a0
			lea.l	debugdata(pc),a1
			moveq.l	#gl_aSIZEOF/4-1,d0
.debugloop		move.l	(a1)+,(a0)+
			dbf	d0,.debugloop
		else
			bsr.w	_ReadArgs		Shellargument holen
			beq.w	_CleanUp		..Fehler
		endc

;;-- Hauptschleife --

_Main		bsr.w	_GetSource			Quelle laden
		beq.b	.Error				..Fehler
		blt.w	.LoopEnd			..keine Quelle mehr da
		bsr.w	_WriteDest			Zielfile erzeugen
		beq.b	.Error				..Fehler
.MainCont	bsr.w	_FreeDest			ZielDir evtl. freigeben
		bsr.w	_FreeSource			QuellSpeicher freigeben
		bra.b	_Main

.Error		dos
		move.l	gl_Result2(gl),d1
		moveq.l	#0,d2
		fjsr	PrintFault			Fehler ausgeben
		move.l	gl_DestName(gl),d1
		beq.b	.AskCont			..Ziel bearbeitet
		fjsr	DeleteFile			..nicht bearb., löschen
		tst.w	d0
		beq.b	.AskCont			..Fehler
		move.l	gl_DestName(gl),d1
		fjsr	FilePart
		lea.l	_DeleteText(pc),a0
		lea.l	gl_Arg(gl),a1
		move.l	d0,(a1)
		bsr.w	_Printf				Status-Text ausgeben

.AskCont	cmpi.l	#ERROR_BREAK,gl_Result2(gl)	***Break?
		beq.b	.AskEnd				..ja
		btst.b	#FLB_ABORT,gl_State(gl)		Continue möglich?
		bne.b	.AskEnd				..nein
		lea.l	_ContinueText(pc),a0
		suba.l	a1,a1
		bsr.w	_Printf				Prompt ausgeben
		fjsr	Input
		move.l	d0,d1
		lea.l	gl_InputBuf(gl),a2
		move.l	a2,d2
		move.l	#512,d3
		fjsr	Read				STDIN abfragen
		bra.b	.AskLoopEnd
.AskLoop	move.b	(a2)+,d1
		cmpi.b	#'y',d1
		beq.b	.MainCont			..'y', fortfahren
		cmpi.b	#'Y',d1
		beq.b	.MainCont			..'Y', fortfahren
		cmpi.b	#' ',d1
		beq.b	.AskLoopEnd			..' ', weitersuchen
		cmpi.b	#$09,d1
		bne.b	.AskEnd				..nicht fortfahren
.AskLoopEnd	dbf	d0,.AskLoop
.AskEnd

.LoopEnd

;;-- Aufräumen --

_CleanUp	bsr.w	_FreeDest			ZielDir etc. freigeben
		bsr.w	_FreeSource			QuellMem freigeben
		bsr.w	_FreeArgs			RDArgs freigeben
		bsr.w	_CloseDOS			DOS.library schließen
_Quit		moveq.l	#RETURN_OK,d0
		move.l	gl_Result2(gl),d1
		movea.l	gl_Process(gl),a0
		move.l	d1,pr_Result2(a0)		Result2 setzen
		beq.b	.Exit				..kein Fehler
		cmpi.l	#ERROR_BREAK,d1
		bne.b	.Error				..Fehler
		moveq.l	#RETURN_WARN,d0
		bra.b	.Exit
.Error		moveq.l	#RETURN_FAIL,d0
.Exit		lea.l	gl_SIZEOF(sp),sp		Stack korrigieren
		rts					Programmende

;;-- Globaler Konstantenspeicher --

_Version	dc.b	'$VER: fd2AsmInc',$A0
		version
		dc.b	0
_DeleteText	dc.b	'Destination file "%s" deleted.',$0a,0
_ContinueText	dc.b	'Continue? ',0
_LFEndText	dc.b	$0a		\
_EndCmdText	dc.b	'##end',0	/
_EndEnd		even

;;-- DOS.library öffnen --
;	Out:	cc=eq bei Fehler

_OpenDOS	push	d0/d1/a0/a1/lb
		exec
		lea.l	.DOSName(pc),a1
		moveq.l	#INCLUDE_VERSION,d0
		fjsr	OpenLibrary			DOS.library öffnen
		move.l	d0,gl_DOSBase(gl)		..und Basis sichern
		beq.b	.Error				..Fehler
.Exit		pull	d0/d1/a0/a1/lb
		rts
.Error		moveq.l	#ERROR_INVALID_RESIDENT_LIBRARY,d1
		move.l	d1,gl_Result2(gl)			Result2 setzen
		clr.b	d0
		bra.b	.Exit

.DOSName	DOSNAME
		even

;;-- DOS.library schließen --

_CloseDOS	push	d0/d1/a0/a1/lb
		exec
		dos	a1				DOSBase oder NULL
		fjsr	CloseLibrary			Library schließen
.Exit		pull	d0/d1/a0/a1/lb
		rts

;;-- Shellargumente lesen & prüfen --
;	Out:	cc=eq bei Fehler

_ReadArgs	push	d0/d1/a0/a1/lb
		dos
		lea.l	.Template(pc),a0
		move.l	a0,d1
		lea.l	gl_Array(gl),a0
		move.l	a0,d2
		moveq.l	#0,d3				keine eigene RDArgs
		fjsr	ReadArgs			Argumente besorgen
		move.l	d0,gl_RDArgs(gl)		..und RDArgs sichern
		beq.b	.UsageError			..Fehler

.CheckTabs	move.l	gl_aTabs(gl),d0
		beq.b	.Ok				..kein Tabs angegeben
		movea.l	d0,a0
		tst.w	(a0)+				Tabs größer als UWORD?
		bne.b	.TabError			..ja
		tst.w	(a0)				Tabs = NULL?
		beq.b	.TabError			..ja
.Ok		moveq.l	#-1,d0				cc setzen
.Exit		pull	d0/d1/a0/a1/lb
		rts

.TabError	moveq.l	#ERROR_BAD_NUMBER,d0
		move.l	d0,gl_Result2(gl)		Result2 sichern
		bra.b	.PrintUsage

.UsageError	bsr.w	_GetIoErr			Result2 sichern
		;||
;-- Usage ausgeben --

.PrintUsage	lea.l	-32(sp),sp
		move.l	sp,d1
		moveq.l	#32,d2
		fjsr	GetProgramName			Programmnamen
		move.l	sp,d1
		fjsr	FilePart			..besorgen
		move.l	d0,-(sp)			..= Argument
		lea.l	.Usage(pc),a0
		move.l	a0,d1
		move.l	sp,d2
		fjsr	VPrintf				Usage ausgeben
		lea.l	32+4(sp),sp
		clr.b	d0
		bra.b	.Exit

.Template	dc.b	'FROM/A,TO,COMMENTS/S,SPACES/S,TABS/N/K,DEC/S,HEX/S',0
.Usage		dc.b	'Usage:  %s <from> [<to>] [comments] [spaces] [tabs <1'
		dc.b	'-65535>] [dec] [hex]',$0a,0
		even

;;-- RDArgs freigeben --

_FreeArgs	push	d0/d1/a0/a1/lb
		move.l	gl_RDArgs(gl),d1
		beq.b	.Exit				..keine RDArgs
		dos
		fjsr	FreeArgs			RDArgs freigeben
.Exit		pull	d0/d1/a0/a1/lb
		rts

;;-- IoErr besorgen und sichern --
;	Out:	d0.l = IoErr, cc=d0.l

_GetIoErr	move.l	a0,-(sp)
		movea.l	gl_Process(gl),a0
		move.l	pr_Result2(a0),d0		IoErr in d0
		move.l	d0,gl_Result2(gl)		..und sichern
		movea.l	(sp)+,a0
		rts

;;-- Quelle suchen, öffnen und lesen --
;	Out:	cc=eq bei Fehler, cc=lt, wenn Suche erfolglos
;		hinterher muß _FreeSource aufgerufen werden!

		rsreset
gs_OldLock	rs.l	1		altes Dir
gs_SourceFH	rs.l	1		Filehandle der Quelle
gs_SourceLen	rs.l	1		Größe der Quelle
gs_Arg		rs.l	1		reserviert für Printf-Argument
		rsword
gs_SIZEOF	rs.b	0

_GetSource	push	d0-d3/a0-a2/lo/lb
		lea.l	gl_AnchorPath(gl),a2		PERMANENT lokal!
		moveq.l	#(gs_SIZEOF/2)-1,d0
.ClearLocal	clr.w	-(sp)				lokales VarMem anlegen
		dbf	d0,.ClearLocal
		movea.l	sp,lo
		dos
		bset.b	#FLB_ANCHOR,gl_State(gl)	AnchorPath schon init.?
		bne.w	.MatchNext			..ja
		move.l	gl_aFrom(gl),d1
		bset.b	#SIGBREAKB_CTRL_C-8,ap_BreakBits+3-1(a2)	BrkBit
		move.l	a2,d2
		fjsr	MatchFirst			Suche beginnen
		btst.b	#APB_ITSWILD,ap_Flags(a2)	Wildcards in Quelle ?
		bne.b	.CheckSeek			..ja
		bset.b	#FLB_ABORT,gl_State(gl)		..nein, Continue unmög.

.CheckSeek	tst.l	d0
		bne.w	.MatchError			..Fehler
		tst.l	ap_Info+fib_DirEntryType(a2)	Directory?
		bge.w	.MatchNext			..ja

.PrintName	lea.l	ap_Info+fib_FileName(a2),a0
		lea.l	gs_Arg(lo),a1
		move.l	a0,(a1)				FileName = Argument
		lea.l	.NameText(pc),a0
		bsr.w	_Printf				Namen ausgeben

.AllocMem	exec
		move.l	ap_Info+fib_Size(a2),d0
		move.l	d0,d2
		move.l	d0,gs_SourceLen(lo)		QuellGröße sichern
		addq.l	#_EndEnd-_LFEndText,d0		(für LF+##end,0)
		moveq.l	#MEMF_PUBLIC,d1
		fjsr	AllocVec			Speicher allokieren
		move.l	d0,gl_SourceBuf(gl)		..und sichern
		beq.w	.NoMemory			..Fehler
		add.l	d2,d0				Quellende
		movea.l	d0,a0
		lea.l	_LFEndText(pc),a1
.AllocLoop	move.b	(a1)+,(a0)+			LF+##end,0 ans Ende
		bne.b	.AllocLoop

.SourceDir	dos
		movea.l	ap_Current(a2),a0
		move.l	an_Lock(a0),d1
		fjsr	CurrentDir			ins QuellDir wechseln
		move.l	d0,gs_OldLock(lo)		..& alten Lock sichern

.OpenSource	lea.l	ap_Info+fib_FileName(a2),a0
		move.l	a0,d1
		move.l	#MODE_OLDFILE,d2
		fjsr	Open				Quelle öffnen
		move.l	d0,gs_SourceFH(lo)		..und Handle sichern
		beq.w	.OpenError			..Fehler

.ReadSource	move.l	gs_SourceFH(lo),d1
		move.l	gl_SourceBuf(gl),d2
		move.l	gs_SourceLen(lo),d3
		fjsr	Read				QuellCode einlesen
		addq.l	#1,d0
		beq.b	.ReadError			..Fehler

.CheckBreak	exec
		moveq.l	#0,d0
		moveq.l	#0,d1
		fjsr	SetSignal			Signal auslesen
		btst.l	#SIGBREAKB_CTRL_C,d0		Ctrl+C gedrückt?
		bne.b	.Break				..ja
		moveq.l	#1,d0				..nein, cc=gt -> OK
		;||
;-- Aufräumen und Routine verlassen --
;	In:	d0.b = cc, der zurückgegeben wird

.CleanUp	move.b	d0,d2
		dos
		move.l	gs_SourceFH(lo),d1
		beq.b	.CleanCont
		fjsr	Close				Quelle schließen
.CleanCont	move.l	gs_OldLock(lo),d1
		beq.b	.CleanCont2
		fjsr	CurrentDir			in altes Dir wechseln
.CleanCont2	tst.b	d2				cc setzen
		lea.l	gs_SIZEOF(sp),sp
		pull	d0-d3/a0-a2/lo/lb
		rts

.MatchNext	dos
		move.l	a2,d1
		fjsr	MatchNext			Suche fortsetzen
		bra.w	.CheckSeek

;-- MatchFirst() oder MatchNext() Fehler --
;	In:	d0.l = Fehlercode ^^

.MatchError	cmpi.l	#ERROR_NO_MORE_ENTRIES,d0	Suche beendet?
		bne.b	.SeekError			..nein, Fehler / Break
		dos
		move.l	a2,d1
		fjsr	MatchEnd			..und AchorPath freig.
		moveq.l	#-1,d0
		bra.b	.CleanUp

.Break		move.l	#ERROR_BREAK,gl_Result2(gl)	Returncodes
		bra.b	.Error

.NoMemory	moveq.l	#ERROR_NO_FREE_STORE,d0
		move.l	d0,gl_Result2(gl)		Result2 sichern
		bra.b	.Error

.SeekError	bset.b	#FLB_ABORT,gl_State(gl)		Cont. nicht mehr mögl.
.ReadError
.OpenError	bsr.w	_GetIoErr			Result2 sichern
		;||
;-- Fehlerstatus setzen und Routine verlassen --

.Error		clr.b	d0
		bra.b	.CleanUp

.NameText	dc.b	'  %s..',0
		even

;;-- QuellSpeicher freigeben --

_FreeSource	push	d0/d1/a0/a1/lb
		exec
		movea.l	gl_SourceBuf(gl),a1
		fjsr	FreeVec				Speicher freigeben
		clr.l	gl_SourceBuf(gl)		..und Ptr auf NULL
		pull	d0/d1/a0/a1/lb
		rts

;;-- Zielfile erzeugen --
;	Out:	cc=eq bei Fehler
;		hinterher muß _FreeDest aufgerufen werden!

		rsreset
wd_Lock		rs.l	1		Lock des Ziels
wd_DestFH	rs.l	1		FileHandle des Ziels
wd_NewName	rs.b	106+2		Buffer für evtl. neuen Namen
wd_FileInfo	rs.b	fib_SIZEOF	FileInfo-Block für Ziel
wd_Arg		rs.l	1		reserviert für Printf-Arg
		rsword
wd_SIZEOF	rs.b	0

_WriteDest	push	d0-d3/a0-a3/lo/lb
		move.w	#(wd_SIZEOF/2)-1,d0
.ClearLocal	clr.w	-(sp)				lokales VarMem anlegen
		dbf	d0,.ClearLocal
		movea.l	sp,lo
		dos
		move.l	gl_aTo(gl),d1			TO angegeben?
		beq.b	.NewName			..nein

.CheckDest	moveq.l	#ACCESS_READ,d2
		fjsr	Lock				..ja, Lock holen
		move.l	d0,wd_Lock(lo)			..und sichern
		beq.b	.OldName			..Fehler
		move.l	d0,d1
		lea.l	wd_FileInfo(lo),a2
		move.l	a2,d2
		fjsr	Examine				FileInfoBlock ausfüllen
		tst.w	d0
		beq.b	.OldName			..Fehler
		tst.l	fib_DirEntryType(a2)		File?
		blt.b	.OldName			..ja
		move.l	wd_Lock(lo),d1
		fjsr	DupLock				..nein, Lock kopieren
		move.l	d0,gl_DestDup(gl)		..und sichern
		beq.w	.DupLockError			..Fehler
		move.l	d0,d1
		fjsr	CurrentDir			in Directory wechseln
		move.l	d0,gl_DestOld(gl)		..& alten Lock sichern

.NewName	lea.l	gl_AnchorPath+ap_Info+fib_FileName(gl),a1
		lea.l	wd_NewName(lo),a0
		movea.l	a0,a2
		suba.l	a3,a3				letzer '.' auf NULL
.NewNameLoop	cmpi.b	#'.',(a1)			'.' gefunden?
		bne.b	.NewNameCont			..nein
		movea.l	a2,a3				..ja, Adresse merken
.NewNameCont	move.b	(a1)+,(a2)+			Namen kopieren
		bne.b	.NewNameLoop
		move.l	a3,d0				'.'irgendwo gefunden?
		bne.b	.NewNameCont2			..ja
		lea.l	-1(a2),a3			..nein, Adr.=Namensende
.NewNameCont2	move.b	#'.',(a3)+			'.i' dranhängen
		move.b	#'i',(a3)+
		clr.b	(a3)
		bra.b	.OpenDest

.OldName	movea.l	gl_aTo(gl),a0			Name in a0
		;||
;-- Lock freigeben, File öffnen und beschreiben --
;	In:	a0 = *Name

.OpenDest	movea.l	a0,gl_DestName(gl)
		move.l	wd_Lock(lo),d1			Lock
		beq.b	.OpenCont			..nicht vorhanden
		fjsr	UnLock				..freigeben
.OpenCont
		move.l	gl_DestName(gl),d1
		fjsr	FilePart			Filenamen extrahieren
		lea.l	.NameText(pc),a0
		lea.l	wd_Arg(lo),a1
		move.l	d0,(a1)				..= Argument
		bsr.w	_Printf				Namen ausgeben

		movea.l	gl_DestName(gl),d1
		move.l	#MODE_NEWFILE,d2
		fjsr	Open				Datei öffnen
		move.l	d0,wd_DestFH(lo)		..und Handle sichern
		beq.b	.OpenError			..Fehler
.WriteDest	bsr.w	_ProcessData			File erzeugen
		beq.b	.Error				..Fehler

.CheckBreak	exec
		moveq.l	#0,d0
		moveq.l	#0,d1
		fjsr	SetSignal			Signal auslesen
		btst.l	#SIGBREAKB_CTRL_C,d0		Ctrl+C gedrückt?
		bne.b	.Break				..ja

.PrintLF	dos
		lea.l	.LineFeedText(pc),a0
		move.l	a0,d1
		fjsr	PutStr				..ok, LineFeed ausgeben
		moveq.l	#-1,d0				..und OK-status setzen
		bra.b	.CleanUp

;-- Fehlerstatus setzen und raus --

.Error		clr.b	d0
		;||
;-- Aufräumen und Routine verlassen --
;	In:	d0.b = cc, der zurückgegeben wird

.CleanUp	move.b	d0,d2
		dos
		move.l	wd_DestFH(lo),d1
		beq.b	.CleanCont
		fjsr	Close
.CleanCont	tst.b	d2
		lea.l	wd_SIZEOF(sp),sp
		pull	d0-d3/a0-a3/lo/lb
		rts

.OpenError
.DupLockError	bsr.w	_GetIoErr			Result2 sichern
		bra.b	.Error

.Break		move.l	#ERROR_BREAK,gl_Result2(gl)	Returncodes
		bra.b	.Error

.NameText	dc.b	$08,$08,'  ',$0a,$9b,'A',$9b,'36C%s..',0
.LineFeedText	dc.b	$08,$08,'  ',$0a,0

;;-- ZielDir etc. freigeben --

_FreeDest	push	d0/d2/a0/a1/lb
		dos
		move.l	gl_DestOld(gl),d1
		beq.b	.CleanCont
		fjsr	CurrentDir
		clr.l	gl_DestOld(gl)
.CleanCont	move.l	gl_DestDup(gl),d1
		beq.b	.Exit
		fjsr	UnLock
		clr.l	gl_DestDup(gl)
.Exit		clr.l	gl_DestName(gl)			= Zielaktivtäten beend.
		pull	d0/d2/a0/a1/lb
		rts

;;-- Quelle in Ziel konvertieren --
;	In:	d0 = *DestFH
;	Out:	cc=eq bei Fehler

		rsreset
pd_DestFH	rs.l	1		FileHandle für's Ziel
pd_SrcLine	rs.l	1		aktuelle QuellZeile (nur Pass2)
pd_Longest	rs.w	1		längster Funktionsname (inkl. _LVO+Spc)
pd_Offset	rs.l	1		aktueller Funktionsoffset
pd_Tab		rs.b	1		\
pd_Space	rs.b	1		/
pd_Buffer	rs.b	3		'=' [+Space|Tab] + '-'
pd_HBuffer	rs.b	10		Puffer für HexOffset [$xxx+LF]
pd_DBuffer	rs.b	11		Puffer für DezOffset [xxx+LF]
		rsword
pd_SIZEOF	rs.b	0

_ProcessData	push	d0-d3/a0-a3/lo/lb
		moveq.l	#(pd_SIZEOF/2)-1,d1
.ClearLocal	clr.w	-(sp)				lokales VarMem anlegen
		dbf	d1,.ClearLocal
		movea.l	sp,lo
		move.l	d0,pd_DestFH(lo)		FileHandle sichern
		move.w	#$09<<8!' ',pd_Tab(lo)
		move.b	#'=',pd_Buffer(lo)
		exec
		move.l	LIB_VERSION(lb),d0
		move.w	SoftVer(lb),d0
		cmpi.l	#37<<16!300,d0			A600 vorhanden?
		beq.w	.A600Found			..ja

.CheckSource	dos
		movea.l	gl_SourceBuf(gl),a0		QuellAdresse
		moveq.l	#1,d0
		move.l	d0,pd_SrcLine(lo)		Zeilennummer resetten
.CheckLoop	cmpi.b	#'*',(a0)
		beq.b	.CheckNextLine			..Kommentar
		cmpi.b	#'#',(a0)
		beq.b	.CheckEndCmd			..auf ##end testen
		moveq.l	#'(',d0
		move.l	a0,d1
		neg.l	d1
		bsr.w	_Search				nach '(' suchen
		beq.w	.LineTempError			..Fehler
		add.l	a0,d1				Funktionsnamen-Länge+1
		addq.l	#-1+5,d1			-1+_LVO und Space
		move.l	d1,d0
		clr.w	d0
		tst.l	d0				Zeile zu Lang (>UWORD)?
		bne.w	.LineLongError			..ja
		cmp.w	pd_Longest(lo),d1		..längste bisher?
		blt.b	.CheckNextLine			..nein
		move.w	d1,pd_Longest(lo)		..ja, sichern
.CheckNextLine	bsr.w	.LineFeed			nächste Zeile
		bra.b	.CheckLoop

.CheckEndCmd	lea.l	_EndCmdText(pc),a1
		bsr.w	_Compare			auf ##end testen
		beq.b	.CheckNextLine			..liegt nicht vor

.WriteData	movea.l	gl_SourceBuf(gl),a0		QuellAdresse
		moveq.l	#1,d0
		move.l	d0,pd_SrcLine(lo)		Zeilennummer resetten
.WriteLoop	cmpi.b	#'*',(a0)
		beq.b	.WriteComment			..Kommentar
		cmpi.b	#'#',(a0)
		bne.b	.WriteFunc			..Funktion
		movea.l	a0,a2
		lea.l	.BiasText(pc),a1
		bsr.w	_Compare			##bias?
		exg.l	a0,a2
		beq.b	.WriteEndCmd			..nein
		moveq.l	#$0a,d0
		bsr.w	_Search
		clr.b	(a0)				..ja, NULLterminieren
		movea.l	a0,a3
		move.l	a2,d1
		lea.l	pd_Offset(lo),a0
		move.l	a0,d2
		fjsr	StrToLong			Offset sichern
		tst.l	d0
		blt.w	.LineKeyError			..Fehler
		movea.l	a3,a0
		move.b	#$0a,(a0)			LF wieder herstellen
.WriteNextLine	bsr.w	.LineFeed			nächste Zeile
		bra.b	.WriteLoop

.WriteEndCmd	lea.l	_EndCmdText(pc),a1
		bsr.w	_Compare			##end?
		beq.b	.WriteNextLine			..nein

;-- Ok-Status setzen und raus --

.Ok		moveq.l	#-1,d0				..ja, cc=ne
.Exit		lea.l	pd_SIZEOF(sp),sp
		pull	d0-d3/a0-a3/lo/lb
		rts

.WriteComment	movea.l	a0,a1
		move.l	a0,d0
		neg.l	d0
		bsr.w	.LineFeed			zur nächsten Zeile
		tst.l	gl_aComments(gl)		Kommentare gewünscht?
		beq.b	.WriteLoop			..nein
		add.l	a0,d0				Kommentarlänge
		exg.l	a1,a0
		bsr.w	.Write				Kommentar schreiben
		exg.l	a1,a0
		beq.w	.WriteError			..Fehler
		bra.b	.WriteLoop

.WriteFunc	movea.l	a0,a1				hier DURCHGEHEND lokal!
		lea.l	.LVOText(pc),a0
		moveq.l	#.LVOEnd-.LVOText,d0
		bsr.w	.Write				_LVO schreiben
		beq.w	.WriteError
		move.l	a1,d1
		neg.l	d1
		movea.l	a1,a0
		moveq.l	#'(',d0
		bsr.w	_Search				nach '(' suchen
;		beq.b	.LineTempError		evtl. Fehler in Pass1 abgefang.
		subq.l	#1,a0
		add.l	a0,d1				Funktionsnamen-Länge
		move.l	d1,d0
		movea.l	a1,a0
		bsr.w	.Write				FuncName schreiben
		beq.w	.WriteError
		addq.w	#4,d1				+_LVO
		moveq.l	#0,d2				Tabs
		moveq.l	#0,d3				Spaces
.CheckTabs	move.l	gl_aTabs(gl),d0
		beq.b	.CheckSpaces			..keine Tabs gewünscht
		movea.l	d0,a0
		move.l	d1,d0
		divu.w	2(a0),d0			d0.w=Tabs für FuncName
		move.w	pd_Longest(lo),d2		d2.w=Breite
		tst.l	gl_aSpaces(gl)
		bne.b	.TabCont			..Spaces gewünscht
		subq.w	#1,d2
		add.l	(a0),d2				d2 wird aufgerundet
.TabCont	divu.w	2(a0),d2			d2.w=Breite in Tabs
		sub.w	d0,d2				d2.w=benötigte Tabs
		beq.b	.Spaces				..keine vorhanden
		tst.l	gl_aSpaces(gl)
		beq.b	.FuncSpace			..keine Spcs gewünscht
		move.l	d2,d3
		swap.w	d3				d3=restliche Spaces
		bra.b	.FuncSpace
.CheckSpaces	tst.l	gl_aSpaces(gl)
		beq.b	.FuncSpace			..gar kein Leerraum
.Spaces		move.w	pd_Longest(lo),d3
		sub.w	d1,d3				d3=Spacs(Width-FuncLen)

.FuncSpace	lea.l	pd_Tab(lo),a0
		moveq.l	#1,d0
		bra.b	.TabsEndLoop
.TabsLoop	bsr.w	.Write				Tabulator schreiben
		beq.w	.WriteError			..Fehler
.TabsEndLoop	dbf	d2,.TabsLoop
		addq.l	#1,a0
		bra.b	.SpacesEndLoop
.SpacesLoop	bsr.w	.Write				Space schreiben
		beq.w	.WriteError			..Fehler
.SpacesEndLoop	dbf	d3,.SpacesLoop

.EquStuff	moveq.l	#2,d0				nur '='
		lea.l	pd_Buffer(lo),a0
		move.b	#' ',1(a0)			auch Space
		tst.l	gl_aSpaces(gl)
		bne.b	.EquNSpace
		tst.l	gl_aTabs(gl)
		beq.b	.WriteEqu
		move.b	#$09,1(a0)			auch Tab
.EquNSpace	addq.b	#1,d0				'=' und Tab/Space
.WriteEqu	move.b	#'-',-1(a0,d0.w)		+ Vorzeichen
		bsr.w	.Write				..schreiben
		beq.b	.WriteError			..Fehler

.OffsetStuff	lea.l	pd_HBuffer(lo),a2
		movea.l	a2,a0
		move.l	pd_Offset(lo),d0
		bsr.w	_ULong2Hex			Offset -> Hex
		move.b	d0,d1
		lea.l	pd_DBuffer(lo),a0
		move.l	pd_Offset(lo),d0
		bsr.w	_ULong2Dec			Offset -> Dez
		tst.l	gl_aDec(gl)
		bne.b	.CheckHex			..Dec gewünscht
		tst.l	gl_aHex(gl)
		bne.b	.Hex				..nur Hex
.Shortest	cmp.b	d0,d1				Dec oder Hex nehmen?
		bgt.b	.WriteOffset			..Dec ist kürzer
.Hex		movea.l	a2,a0				..Hex ist
		move.b	d1,d0				..kürzer
		bra.b	.WriteOffset
.CheckHex	tst.l	gl_aHex(gl)
		bne.b	.Shortest			..Dec oder Hex
.WriteOffset	move.b	#$0a,(a0,d0.w)			Offset + LF
		addq.b	#1,d0
		bsr.b	.Write				..schreiben
		beq.b	.WriteError			..Fehler
		addq.l	#6,pd_Offset(lo)		nächster Offset

		movea.l	a1,a0				Lokalität beendet!
		bra.w	.WriteNextLine

.A600Found	lea.l	.A600Text(pc),a0
		moveq.l	#.A600End-.A600Text,d0
		bsr.b	.Write				Boykott-Text schreiben
		bra.w	.Ok

.WriteError	bsr.w	_GetIoErr			Result2 sichern
		bra.b	.Error

.LineLongError	moveq.l	#ERROR_LINE_TOO_LONG,d0
		bra.b	.LineError

.LineTempError	moveq.l	#ERROR_BAD_TEMPLATE,d0
		bra.b	.LineError

.LineKeyError	moveq.l	#ERROR_KEY_NEEDS_ARG,d0
		;||
;-- Result2 sichern und Zeilennummer ausgeben --
;	In:	d0.l = Result2

.LineError	move.l	d0,gl_Result2(gl)		Result2 sichern
		lea.l	.LineText(pc),a0
		lea.l	pd_SrcLine(lo),a1
		bsr.w	_Printf				Fehlerzeile ausgeben
		;||
;-- Fehlerstatus setzen und raus --

.Error		clr.b	d0
		bra.w	.Exit

;-- Nächste (nicht leere) Zeile eines Strings suchen --
;	In:	a0 = String
;	Out:	a0 = *NextLine
;	ACHTUNG: a0 ist nicht NULLterminiert!

.LineFeed
.LineFLoop1	cmpi.b	#$0a,(a0)+			Ende der Zeile?
		bne.b	.LineFLoop1			..nein
.LineFLoop2	addq.l	#1,pd_SrcLine(lo)		Zeilennummer erhöhen
		cmpi.b	#$0a,(a0)+			Leerzeile?
		beq.b	.LineFLoop2			..ja
		subq.l	#1,a0				..nein, Adresse korrig.
		rts

;-- String ins Ziel schreiben --
;	In:	a0 = String, d0.l = Stringlänge
;	Out:	cc=eq bei Fehler

.Write		push	d0-d3/a0/a1/lb
		dos
		move.l	pd_DestFH(lo),d1
		move.l	a0,d2
		move.l	d0,d3
		fjsr	Write				Daten schreiben
		addq.l	#1,d0				cc setzen
		pull	d0-d3/a0/a1/lb
		rts

.LineText	dc.b	'(Line %ld:) ',0
.BiasText	dc.b	'##bias',0
.A600Text	dc.b	"Sorry, but u got a fuckin' A600!",$0a
.A600End
.LVOText	dc.b	'_LVO'
.LVOEnd		even

;;-- Zeichen in Stringzeile suchen (LCase <> UCase) --
;	In:	d0.b = Char, a0 = *String
;	Out:	cc=eq bei Fehler und a0 = *LineFeed, sonst a0 = *NachChar
;	ACHTUNG: a0 ist nicht NULLterminiert!

_Search		push	d0/d1
.Loop		cmpi.b	#$0a,(a0)			Ende der Zeile?
		beq.b	.Exit				..ja
		cmp.b	(a0)+,d0			..nein, Char gefunden?
		bne.b	.Loop				..nein
		moveq.l	#-1,d0				..ja, cc=ne
.Exit		pull	d0/d1
		rts

;;-- Teilstring mit Stringzeile vergleichen (LCase = UCase) --
;	In:	a0 = *String, a1 = *CTeilString
;	Out:	cc=eq bei Fehler und a0 = *LineFeed, sonst a0 = *NachTeilString
;	ACHTUNG: a0 ist nicht NULLterminiert und a1 MUSS LCase sein!

_Compare	push	d0/d1
.Loop		tst.b	(a1)				Teilstring zu Ende?
		beq.b	.Found				..ja
		cmpi.b	#$0a,(a0)			Ende der Zeile?
		beq.b	.Exit				..ja
		move.b	(a0)+,d0
		cmpi.b	#'A',d0
		blt.b	.Cont				..kein Großbuchstabe
		cmpi.b	#'Z',d0
		bgt.b	.Cont				.."    "
		addi.b	#32,d0				Char > Kleinbuchstabe
.Cont		cmp.b	(a1)+,d0			Chars gleich?
		beq.b	.Loop				..ja
.NotFound	clr.b	d0				cc=eq
.Exit		pull	d0/d1
		rts
.Found		moveq.l	#-1,d0				cc=ne
		bra.b	.Exit

;;-- String und Argumente formatiert in STDOUT ausgeben --
;	In:	a0 = *String, a1 = *ArgArray

_Printf		push	d0/d1/a0/a1/lb
		dos
		move.l	a0,d1
		move.l	a1,d2
		fjsr	VPrintf				String ausgeben
		fjsr	Output
		move.l	d0,d1
		fjsr	Flush				..und Buffer flushen
		pull	d0/d1/a0/a1/lb
		rts

;;-- ULong in LCase-Hex-String ($xxx) konvertieren
;	In:	a0 = *Buffer[9], d0.l = Wert
;	Out:	d0.l = Größe des benutzten Buffers

_ULong2Hex	push	d1/d2/a0-a2
		lea.l	.HexData(pc),a1
		movea.l	sp,a2				temp. Buffer auf Stack
		moveq.l	#0,d2
		moveq.l	#0,d1				Anzahl der Stellen
.Loop		addq.w	#1,d1				..+1
		move.b	d0,d2
		andi.b	#%1111,d2			4-Bit Wert filtern
		move.b	(a1,d2.w),-(a2)			zugeh. HexChar sichern
		lsr.l	#4,d0				nächste 4 Bits
		bne.b	.Loop				..Schleife
		move.b	d1,d0				d0.l = Größe-1
		addq.b	#1,d0				..+1 \/
		move.b	#'$',-(a2)			Kennzeichen
.Loop2		move.b	(a2)+,(a0)+			vom Stack in Buffer
		dbf	d1,.Loop2			..kopieren
		pull	d1/d2/a0-a2
		rts
.HexData	dc.b	'0123456789abcdef'
		even

;;-- ULong in Dez-String konvertieren
;	In:	a0 = *Buffer[10], d0.l = Wert
;	Out:	d0.l = Größe des benutzten Buffers

_ULong2Dec	push	d1-d5/a0-a2
		moveq.l	#0,d5				Anzahl der Stellen
		moveq.l	#'0',d4
		move.b	d4,(a0)				schon mal '0' schreiben
		lea.l	.DecData(pc),a1
		moveq.l	#10-1,d3			max. benötigte Stellen
.Loop2		move.l	(a1)+,d1			10er-Faktor
		moveq.l	#-1,d2				aktuelle 10er-Stelle
.Loop		addq.b	#1,d2				..+1
		sub.l	d1,d0
		bhs.b	.Loop				..weitere Stelle
		add.l	d1,d0
		tst.b	d2
		beq.b	.Cont				..keine Stellen
		bset.l	#31,d3				Flag setzen
.Cont		btst.l	#31,d3				Flag gesetzt?
		beq.b	.LoopEnd			..nein, Wert ist 0
		add.b	d4,d2				Stelle + '0'
		move.b	d2,(a0)+			..sichern
		addq.b	#1,d5				Anzahl ++
.LoopEnd	dbf	d3,.Loop2
		moveq.l	#1,d0
		tst.b	d5
		beq.b	.Exit				Wert = 0, Anzahl = 1
		move.b	d5,d0				Wert > 0, Anzahl in d0
.Exit		pull	d1-d5/a0-a2
		rts
.DecData	dc.l	1000000000,100000000,10000000,1000000,100000,10000,1000
		dc.l	100,10,1

;;-- Debugstuff --

		if debugbool
			even
debugdata		dc.l	.from,.to
			dc.l	.comments,.spaces
			dc.l	.tabs
			dc.l	.dec,.hex
.comments		=	0
.spaces			=	0
.tabs			=	0
.dec			=	0
.hex			=	0
.from			dc.b	'other:fd/#?.fd',0
.to			dc.b	't:',0
		endc
