;---------------T-------T---------------T------------------------------------T
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; This source is © Copyright 1992-1995, Jesper Skov.
; Read "GhostRiderSource.ReadMe" for a description of what you may do with
; this source!
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; Please do not abuse! Thanks. Jesper
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;-----------------------------------------------------------------------------;
;- Program Title	: GhostRider Loader	-;
;- Copyrigth Status	: PD, (c) Copyrigth Jesper Skov	-;
;- Programmed by	: Jesper Skov		-;
;- Version.Revision	: 38.7
;- Project start	: 05.11.93		-;
;-----------------------------------------------------------------------------;
;- Program Description	:		-;
;-----------------------------------------------------------------------------;
;- 		       Program History	-;
;-----------------------------------------------------------------------------;
;-----------------------------------------------------------------------------;
;210194.0015	Added $f00000 load handling.
;310194.0016	Added default path/file and revision# check.
;      .0017	Removed Config-name ARG. Always default now.
;      .0019	Added KeyMap Load.
;010294.0020.6	Added COLD ARG. Calls COLD/COOL init-routine if found.
;      .0021	Better output in case of wrong syntax.
;040294.0022	Added 'USER'-mark to signal GR of loaded prefs.
;060294.0023	Cache was not cleared after Reloc-table load. Fixed
;170494.0024	No need for ^. Removed. Added entry call to set_port
;140894.0029.9	Added 2-hunk loading, STATIC and CHIP specifiers.
;290894.0030.10	6 bytes of pref was not loaded. Fixed.
;080994.0031.11	Changed default pref path to S:

VERSTRING	macro
	dc.b	'.11 (08.09.94)'
	endm

ip_SetPort=	3

	IncDir	Include:
	include	dos/rdargs.i

                include libraryOffsets/exec_lib.i
                include exec/execbase.i
                include exec/exec.i

                include libraryOffsets/dos_lib.i
                include dos/dos.i
                include dos/dosextens.i

CallE           MACRO
                MOVE.L  $4.W,A6
                JSR     _LVO\1(A6)
                ENDM

CallD           MACRO
                MOVE.L  _DOSBase(b),A6
                JSR     _LVO\1(A6)
                ENDM

Call            macro
                jsr     _LVO\1(a6)
                endm

	jumpptr	s

b	equr	a5

s	lea	B,b	;open DOS
	lea	DOSNam(pc),a1
	moveq	#37,d0
	CallE	OpenLibrary
	move.l	d0,_DOSBase(b)
	beq.w	DOSTooOld

	move.l	#Template,d1	;get ARGs parsed
	lea	ArgArray(b),a0
	move.l	a0,d2
	moveq	#0,d3
	CallD	ReadArgs
	move.l	d0,_RDArgs(b)
	beq.w	NoArguments

	move.l	AbsAddr(b),d0	;parse string to hexadecimal integer
	beq.b	.NoAbsAddress
	move.l	d0,a0

	bsr.w	GetHexValue

	lea	$f00000,a0
	cmp.l	a0,d0	;GB memory?
	bne.b	.GBMem
	move.l	#$11114EF9,(a0)+
	move.l	#$00F00000,(a0)+
	move.l	a0,d0	;corrected address
	st.b	Force(b)	;always force
	st.b	FindRST(b)	;flag that RST should be found

.GBMem	move.l	d0,CodeAddress(b)

.NoAbsAddress	move.l	ChipAddr(b),d0
	beq.b	.NoChipAddress
	move.l	d0,a0

	bsr.w	GetHexValue

	move.l	d0,ChipAddress(b)

.NoChipAddress	move.l	FileName(b),a0	;get filename
	move.l	a0,d1
	beq.w	NoFilename
	move.l	#MODE_OLDFILE,d2;and open file
	Call	Open
	move.l	d0,_FileHandle(b)
	beq.w	FileNotOpened

	move.l	d0,d1	;get first $24 bytes
	lea	TrashBuffer(b),a0;including the hunklengths ($14/$18)
	move.l	a0,d2
	moveq	#$24,d3
	Call	Read
	cmp.l	#$24,d0
	bne.w	ReadError

	move.l	CodeAddress(b),d1;Get mem for CODE
	move.l	TrashBuffer+$14(b),d0
	asl.l	#2,d0	;convert to longs
	move.l	d0,d6
	moveq	#0,d2
	bsr.w	GetMemAllocated
	move.l	d0,CodeAddress(b)
	add.l	d0,d6
	move.l	d6,CodeAddressEnd(b)

	move.l	#MEMF_CLEAR,d2;if not abs address specified
	moveq	#0,d1	;if swap mem, don't alloc
	tst.l	Static(b)
	beq.b	.NotStatic

	move.l	ChipAddress(b),d1;Get mem for DATA
	or.l	#MEMF_CHIP,d2	;if not abs address specified
			;go for address in chip
.NotStatic	move.l	TrashBuffer+$18(b),d0
	and.l	#$fffff,d0	;get rid of ChipLoad hunk ID
	asl.l	#2,d0	;convert to longs
	move.l	d0,d6
	bsr.w	GetMemAllocated
	move.l	d0,DataAddress(b)
	add.l	d0,d6
	move.l	d6,DataAddressEnd(b)

	move.l	CodeAddress(b),d2
	move.l	CodeAddressEnd(b),d3
	sub.l	d2,d3
	move.l	_FileHandle(b),d1
	CallD	Read	;read the code
	cmp.l	d3,d0
	bne.w	ReadError

	move.l	_FileHandle(b),d1;get first 12 bytes
	lea	TrashBuffer(b),a0;including the reloc hunklength (4)
	move.l	a0,d2
	moveq	#12,d3
	Call	Read
	moveq	#12,d1
	cmp.l	d1,d0
	bne.w	ReadError

	move.l	TrashBuffer+4(b),d0;alloc space for reloc hunk
	addq.l	#7,d0	;AND space for the next hunk info (CHIP)
	asl.l	#2,d0
	move.l	d0,RelocLen(b)
	moveq	#0,d1
	CallE	AllocMem
	move.l	d0,RelocMem(b)	;read alloc hunk
	beq.w	AllocError

	move.l	d0,d2
	move.l	RelocLen(b),d3
	move.l	_FileHandle(b),d1
	CallD	Read
	cmp.l	RelocLen(b),d0
	bne.w	ReadError

	move.l	RelocMem(b),a0	;relocate program
	move.l	CodeAddress(b),a1
	move.l	a1,d0
	move.l	TrashBuffer+4(b),d1
.RelocLoop	move.l	(a0)+,d2
	add.l	d0,(a1,d2.l)
	subq.l	#1,d1
	bne.b	.RelocLoop

	addq.l	#8,a0	;skip two 1.l s
	move.l	DataAddress(b),d2
	move.l	(a0)+,d0
	move.l	4(a1,d0.l),a1	;get hold of ChipMem and ChipBackup

	move.l	ChipAddress(b),(a1);set specified CHIP (may be NULL)

	tst.l	Static(b)
	bne.w	.Static
	addq.w	#4,a1	;if dynamic set load address in ChipBackup

.Static	move.l	d2,(a1)

	move.l	$c(a0),d3	;get longword length
	asl.l	#2,d3
	move.l	_FileHandle(b),d1
	Call	Read	;and read DATA to memory
	cmp.l	d3,d0	;check OK load length
	bne.w	ReadError

	tst.b	FindRST(b)
	beq.b	.notF00000
	move.l	#'RST!',d0
	bsr.w	ScanGRID
	bne.b	.foundRST
	clr.w	$f00000	;kill, RST not found!
	bra.b	.notF00000

.foundRST	move.l	d0,$f00004	;store RST entry address

.notF00000	tst.l	SetNMI(b)	;set NMI-vector
	beq.b	.noNMI
	move.l	#'NMI!',d0	;find NMI-entry address
	bsr.w	ScanGRID
	move.l	d0,d7

	sub.l	a0,a0	;defaultVBR=0
	move.l	$4.w,a6
	btst	#0,AttnFlags+1(a6);'010+?
	beq.b	.MC68000
	lea	.GetVBR(pc),a5;yes, get VBR
	Call	Supervisor
	lea	B,b
.MC68000	move.l	d7,$7c(a0)
	bra.b	.noNMI

.GetVBR	movec	vbr,a0
	rte

.noNMI	tst.l	Cold(b)
	beq.w	.noCold
	move.l	#'CLD!',d0
	bsr.w	ScanGRID
	beq.b	.noCold	;ID was not found
	move.l	d0,a0
	jsr	(a0)	;get Cold/Cool set
	lea	B,b

.noCold	move.l	#'GRIP',d0
	bsr.w	ScanGRID
	beq.b	.noIP
	move.l	d0,a0
.scanMsgPort	move.w	(a0),d0
	bmi.b	.noIP
	addq.w	#6,a0
	cmp.w	#ip_SetPort,d0
	bne.b	.scanMsgPort
	move.l	-(a0),a0
	jsr	(a0)
.noIP

Exit	move.l	RelocMem(b),a1	;free relocmem
	move.l	a1,d0
	beq.b	.nomem
	move.l	RelocLen(b),d0
	CallE	FreeMem
	clr.l	RelocMem(b)
.nomem
	move.l	_FileHandle(b),d1
	beq.b	.nofile
	CallD	Close
	clr.l	_FileHandle(b)
.nofile
	tst.b	Error(b)
	bne.b	.dead
	bsr.w	ReadConfig
.dead
	move.l	_RDArgs(b),d1
	beq.b	CloseDOSLib
	CallD	FreeArgs
	clr.l	_RDArgs(b)

CloseDOSLib	move.l	_DOSBase(b),a1
	CallE	CloseLibrary

	Call	CacheClearU

	tst.l	Quiet(b)
	bne.b	.QuietExit
	tst.b	Error(b)
	bne.b	.QuietExit
	move.l	CodeAddress(b),a0
	jmp	4(a0)	;enter mon if not quiet and no errors
			;4 because of two other bras.

.QuietExit	moveq	#0,d0
	rts

NoFilename	lea	NoFileNameText(pc),a0
	bra.b	PrintError

AllocErrorP	addq.w	#4,a7	;quit caller
AllocError	lea	AllocErrorText(pc),a0
	bra.b	PrintError

ReadError	lea	ReadErrorText(pc),a0
	bra.b	PrintError

HexError	addq.w	#4,a7	;quit caller
	lea	HexErrorText(pc),a0
	bra.b	PrintError

FileNotOpened	lea	OpenErrorText(pc),a0
	bra.b	PrintError

NoArguments	lea	InfoText(pc),a0
	bsr.b	ShowError
	lea	Usage(pc),a0
	bsr.b	ShowError
	lea	LineFeed(pc),a0
;	bra.w	PrintError

PrintError	st.b	Error(b)
	pea	Exit(pc)
ShowError	move.l	a0,-(a7)
	CallD	Output
	move.l	d0,d1
	move.l	(a7)+,a0
	moveq	#0,d3
	move.b	(a0)+,d3
	move.l	a0,d2
	Call	Write
	rts


DOSTooOld	moveq	#1,d0
	rts

;---- Conve	rt ASCII string to HEX value (a0 - string)
GetHexValue	moveq	#0,d0
.parsehexaddr	move.b	(a0)+,d1
	beq.b	.addrend
	cmp.b	#'0',d1
	blt.w	HexError
	cmp.b	#'9',d1
	bgt.b	.checkalfa
	sub.b	#'0',d1
	bra.b	.nibbleok

.checkalfa	or.b	#$20,d1
	cmp.b	#'a',d1
	blt.w	HexError
	cmp.b	#'f',d1
	bgt.w	HexError
	sub.b	#'a'-10,d1
.nibbleok	asl.l	#4,d0
	or.b	d1,d0
	bra.b	.parsehexaddr

.addrend	rts

;---- Allocate Mem (d1 address/d0 - len)
GetMemAllocated	move.l	$4.w,a6
	tst.l	d1
	beq.b	.notabsolute
	move.l	d1,a1
	move.l	d1,d7
	Call	AllocAbs
	tst.l	d0
	bne.b	.AllocationOK
	tst.l	Force(b)
	beq.w	AllocErrorP
	move.l	d7,d0	;brute force if requested!
	bra.b	.AllocationOK

.notabsolute	move.l	d2,d1
	Call	AllocMem
	tst.l	d0
	beq.w	AllocErrorP	;no force if nice-load

.AllocationOK	rts

;---- Read config file if specified
ReadConfig	move.l	#'CFG!',d0	;scan for Config
	bsr.w	ScanGRID
	bne.b	.foundit
	lea	CFGNotFoundText(pc),a0
	bsr.w	ShowError
	moveq	#0,d0

.foundit	move.l	d0,ConfigSpot(b)

	move.l	#'KMP!',d0	;scan for KeyMap
	bsr.w	ScanGRID
	bne.b	.foundit2
	lea	KMPNotFoundText(pc),a0
	bsr.w	ShowError
	moveq	#0,d0

.foundit2	move.l	d0,KeyMapSpot(b)

	tst.l	ConfigSpot(b)	;Config SPOT found?
	beq.w	.NoConfigLoad

	moveq	#0,d5	;Load State

	move.l	ConfigSpot(b),a0
	move.w	-2-4(a0),ConfigLength(b)
;	subq.w	#6,ConfigLength(b);length of ID and revision#
	move.w	-4-4(a0),ConfigRevision(b)

	lea	ConfigName(pc),a0
	move.l	a0,d1	;open pref file
	move.l	#MODE_OLDFILE,d2
	CallD	Open
	lea	OpenErrorText2(pc),a0
	move.l	d0,_FileHandle(b)
	beq.b	.ConfigError

.fileok	lea	TrashBuffer(b),a0;get ID and revision
	move.l	a0,d2
	moveq	#6,d3
	move.l	_FileHandle(b),d1
	Call	Read
	lea	ReadErrorText2(pc),a0
	cmp.l	#6,d0
	bne.w	.ConfigError

	lea	NotGRPrefFileText(pc),a0
	cmp.l	#'GRPF',TrashBuffer(b)
	bne.w	.ConfigError

	lea	WrongRevisionText(pc),a0
	move.w	ConfigRevision(b),d0
	cmp.w	TrashBuffer+4(b),d0;correct revision #?
	bne.w	.ConfigError

	move.l	ConfigSpot(b),d2
	moveq	#0,d3
	move.w	ConfigLength(b),d3
	move.l	_FileHandle(b),d1
	Call	Read
	move.l	#'USER',d5
	cmp.w	ConfigLength(b),d0
	beq.b	.ConfigOK
	lea	ReadErrorText2(pc),a0
	moveq	#0,d5	;config fail
.ConfigError	bsr.w	ShowError
.ConfigOK	move.l	_FileHandle(b),d1
	beq.b	.NoConfigLoad
	CallD	Close	;close file if open
	move.l	ConfigSpot(b),a0
	move.l	d5,-(a0)	;mark loaded


.NoConfigLoad	tst.l	KeyMapSpot(b)	;KeyMap SPOT found?
	beq.b	.NoKeyMapLoad

	lea	KeyMapName(pc),a0
	move.l	a0,d1	;open pref file
	move.l	#MODE_OLDFILE,d2
	CallD	Open
	lea	OpenErrorTextKM(pc),a0
	move.l	d0,_FileHandle(b)
	beq.b	.KeyMapError

	move.l	KeyMapSpot(b),d2
	move.l	#96*2,d3
	move.l	_FileHandle(b),d1
	Call	Read
	cmp.l	#96*2,d0
	beq.b	.KeyMapOK
	lea	ReadErrorTextKM2(pc),a0

.KeyMapError	bsr.w	ShowError
.KeyMapOK	move.l	_FileHandle(b),d1
	beq.b	.NoKeyMapLoad
	CallD	Close	;close file if open

.NoKeyMapLoad	rts

;---- Scan GR for ID longword
;- Input:	d0 -	ID
;- Output:	d0 -	Address/NULL(error)
;----
ScanGRID	move.l	CodeAddress(b),a0;scan GR for config
	move.l	CodeAddressEnd(b),d1

.scan	cmp.l	(a0),d0
	beq.b	.foundID
	addq.l	#2,a0
	cmp.l	a0,d1
	bne.b	.scan
	moveq	#0,d0	;return error
	rts

.foundID	move.l	a0,d0
	addq.l	#4,d0	;skip ID word
	rts

	dc.b	'$VER: GRDR 38'
	VERSTRING
	dc.b	' © 1993-1994, Jesper Skov.',0

Usage	dc.b	UsageLen
	dc.b	'Usage: '
Template	dc.b	'FILENAME,CODE/K,CHIP/K,STATIC/S,FORCE/S,SETNMI/S,COLD/S,QUIET/S',0
UsageLen=*-Usage-1

DOSNam	dc.b	'dos.library',0

ConfigName	dc.b	'S:GhostRider.Prefs',0
KeyMapName	dc.b	'S:GhostRider.KeyMap',0

LineFeed	dc.b	1,10

InfoText	dc.b	TL1-1
	dc.b	'GhostRider DeckRunner by Jesper Skov.',10
TL1=*-InfoText

OpenErrorText	dc.b	TL2-1
	dc.b	'Could not open GR file!',10
TL2=*-OpenErrorText

ReadErrorText	dc.b	TL3-1
	dc.b	'Read error/not expected length!',10
TL3=*-ReadErrorText

AllocErrorText	dc.b	TL4-1
	dc.b	'Not enough memory/Could not allocate absolute memory!',10
TL4=*-AllocErrorText

NoFileNameText	dc.b	TL5-1
	dc.b	'You must specify a filename!',10
TL5=*-NoFileNameText

HexErrorText	dc.b	TL6-1
	dc.b	'Address must be in hexadecimal!',10
TL6=*-HexErrorText

CFGNotFoundText	dc.b	TL7-1
	dc.b	'Could not locate preferences in GR!',10
TL7=*-CFGNotFoundText

OpenErrorText2	dc.b	TL8-1
	dc.b	'Could not open preference file!',10
TL8=*-OpenErrorText2

ReadErrorText2	dc.b	TL9-1
	dc.b	'Preference read error/not expected length!',10
TL9=*-ReadErrorText2

NotGRPrefFileText
	dc.b	TL10-1
	dc.b	'Not a GhostRider Preference File!',10
TL10=*-NotGRPrefFileText

WrongRevisionText
	dc.b	TL11-1
	dc.b	'Preference File has wrong revision number!',10
TL11=*-WrongRevisionText

KMPNotFoundText	dc.b	TL12-1
	dc.b	'Could not locate keymap in GR!',10
TL12=*-KMPNotFoundText

OpenErrorTextKM	dc.b	TL13-1
	dc.b	'Could not open keymap file!',10
TL13=*-OpenErrorTextKM

ReadErrorTextKM2 dc.b	TL14-1
	dc.b	'KeyMap read error/not expected length!',10
TL14=*-ReadErrorTextKM2


	section	BSSArea,BSS

	rsreset
_DOSBase	rs.l	1
_RDArgs	rs.l	1
_FileHandle	rs.l	1

ChipAddress	rs.l	1	;work address in CHIP
CodeAddress	rs.l	1	;abs code load address
CodeAddressEnd	rs.l	1
DataAddress	rs.l	1	;abs data load address
DataAddressEnd	rs.l	1

RelocMem	rs.l	1
RelocLen	rs.l	1

GRIPBase	rs.l	1

ArgArray	rs.b	0
FileName	rs.l	1
AbsAddr	rs.l	1
ChipAddr	rs.l	1
Static	rs.l	1
Force	rs.l	1
SetNMI	rs.l	1
Cold	rs.l	1
Quiet	rs.l	1

TrashBuffer	rs.l	8

ConfigLength	rs.w	1
ConfigRevision	rs.w	1
ConfigSpot	rs.l	1
KeyMapSpot	rs.l	1

Error	rs.b	1
FindRST	rs.b	1

BSSSize	rs.b	0
B	ds.b	BSSSize
