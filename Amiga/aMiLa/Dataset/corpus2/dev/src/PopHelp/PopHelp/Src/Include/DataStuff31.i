; Not modified at runtime - DATA, texts & moved gfx
; $VER: Include v1.01 / PH v2.58
; (C) Mika Lundell
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.

_DataStuff	macro
MpLImage	dc.w	0,0,96,10,2
		dc.l	MpLLogo
		dc.b	3,0
		dc.l	0

TextAttr	dc.l	FontName
		dc.w	8
		dc.b	0,0

IName		INTUINAME
GfxName		GFXNAME
DosName		DOSNAME
IconName	ICONNAME
MathName	MATHNAME
PPName		PPNAME
ReqTName	REQTOOLSNAME
TD_Name		TD_NAME
TR_Name		TIMERNAME
FontName	TOPAZNAME

		dc.b	'$VER:'	; Next byte $20 (space) used as length!
PrgTitle	dc.b	' PopHelp v2.58 Professional      (20.12.94)'
		dcb.b	26,32
		dc.b	0
PrefsFile	dc.b	'S:PH.prefs',0
Info_txt	dc.b	'.info',0
EnterParmsTitle	dc.b	' Please, Enter Required Parameters...',0
WorkingTitle	dc.b	' Working...',0
LoadPrefsTitle	dc.b	' Checking Prefs...',0
SavePrefsTitle	dc.b	' Saving Prefs To S:PH.prefs...',0
;ReallyQ_txt	dc.b	41,'Do You Really Want To Quit PopHelp? (y/n)'

NextGen		dc.b	21,'- The Next Generation'
TitleForm	dc.b	' CHIP:%07.7ld FAST:%07.ld  '
		dc.b	'%02.2ld:%02.2ld:%02.2ld ',0

PressKey_txt	dc.b	28,'Press Any Key To Continue...'
DirForm		dc.b	'%-30.30s - dir -',0
FileForm	dc.b	'%-30.30s %7.7ld',0

LineInfo_txt	dc.b	'%ld Line(s)    '
		dc.b	'Line(s) %5.5ld > %-5.5ld Currently Shown',0
NumDirs_txt	dc.b	'%ld Dir(s)',0
NumFiles_txt	dc.b	'%ld File(s)',0
NumBytes_txt	dc.b	'%ld Byte(s)',0
KilosFree_txt	dc.b	'%ld kb Free',0

DTitle_txt	dc.b	'Directory Of %s',0
CONFile		dc.b	'CON:0/43/640/60/PopHelp Output Window',0

Cpr_txt		dc.b	24,'Is FreeWare / © MpL 1994'
About2_txt	dc.b	38,'PopHelp Was Written In 100% Assembler.'
About3_txt	dc.b	71,'Feel Free To Distribute This Program As Long As '
		dc.b	'All Files Are Included.'

;Jokka_txt	dc.b	'Path "%s", JokerPattern "%s".',0
CopyingFrom_txt	dc.b	'Copying From %-50.50s',0
MovingFrom_txt	dc.b	'Moving  From %-50.50s',0
CopyingTo_txt	dc.b	'          To %-50.50s',0
CreaDestDir_txt	dc.b	35,'Create Destination Directory? (y/n)'
Replace_txt	dc.b	67,'Destination File Already Exists,'
		dc.b	' Replace It With The New One? (y/n)'
NoSpace_txt	dc.b	48,'Source File Is Too Long To Fit Into Destination!'
Deleting_txt	dc.b	'Deleting %-50.50s',0
Noting_txt	dc.b	'Noting %-50.50s',0
Protecting_txt	dc.b	'Protecting %-50.50s',0
MakingDir_txt	dc.b	'Creating Dir %-50.50s',0
Protected_txt	dc.b	59,'Protected From Deletion. '
		dc.b	'UnProtect And Delete Anyway? (y/n)'

MoreVol_txt	dc.b	26,'I Need More Than A Volume!'
MoreClear_txt	dc.b	11,'RTFM Error!'

LoadingPP_txt	dc.b	33,'Trying To Get PowerPacked File...'
Read.fast_txt	dc.b	19,'Reading .fastdir...'
ReadTDir_txt	dc.b	19,'Reading TrackDir...'
ReadDir_txt	dc.b	19,'Reading Directory, '
ESCToCancel_txt	dc.b	16,'Esc To CANCEL...'
Creatingfd_txt	dc.b	17,'Creating '
fd_txt		dc.b	'.fastdir',0	; Also used as FileName!
EmptyDir_txt	dc.b	41,'Directory Is Empty, .fastdir Not Created!'
DirLockErr_txt	dc.b	26,"Couldn't Lock() Directory!"
DirExamErr_txt	dc.b	29,"Couldn't Examine() Directory!"
DirIsFile_txt	dc.b	32,'This Is A File, Not A Directory!'
LockErr_txt	dc.b	21,"Couldn't Lock() File!"
ExamineErr_txt	dc.b	24,"Couldn't Examine() File!"
OpenErr_txt	dc.b	21,"Couldn't Open() File!"
ReadErr_txt	dc.b	26,"Couldn't Read() From File!"
WriteErr_txt	dc.b	25,"Couldn't Write() To File!"
IDFailed_txt	dc.b	'%s Failed!!!',0
DErr_txt	dc.b	'DOS Error #%ld - %s',0

NoPort_txt	dc.b	"Couldn't Create Message Port For Drive DF%1.1ld:.",0
NoIO_txt	dc.b	"Couldn't Create I/O Request For Drive DF%1.1ld:.",0
NoUnit_txt	dc.b	"Couldn't Allocate Drive DF%1.1ld:, Error #%ld.",0
NoDisk_txt	dc.b	'No Disk In Drive DF%1.1ld:!',0
DiskProt_txt	dc.b	'Disk In Drive DF%1.1ld: Is Write Protected!',0
NoBufMem_txt	dc.b	29,'Not Enough Memory For Buffer!'
NotDOSDisk_txt	dc.b	23,'This Is Not A DOS Disk!'
NoFloppy_txt	dc.b	35,'Only Floppy Disk Units Can Be Used!'
OutOfMem_txt	dc.b	37,'Out Of Memory!? Unable To Continue...'

Copying_txt	dc.b	'Copying',0
Verifying_txt	dc.b	'Verifying',0
Formatting_txt	dc.b	'Formatting',0
Reading_txt	dc.b	'Reading',0
Writing_txt	dc.b	'Writing',0
DC_txt		dc.b	'%-10.10s Cylinder %2.2ld',0
TDErr_txt	dc.b	'TrackDisk Error #%ld.',0
ReportErrs_txt	dc.b	'%ld Blocks Marked As Used.',0
VeriCylErr_txt	dc.b	22,'Verify Error Detected!'
RIC_txt		dc.b	32,'Retry, Ignore Or Cancel? (r/i/c)'
DCRemDisk_txt	dc.b	23,'Remove Identical Disks!'
SetClkErr_txt	dc.b	29,'Error In SetClock Parameters!'
DCInsert_txt	dc.b	36,'Insert Source And Destination Disks.'
FormInsert_txt	dc.b	'Insert Disk To Be Formatted In Drive DF%1.1ld:.',0
InsertSrc_txt	dc.b	'Insert Source Disk In Drive DF%1.1ld:.',0
InsertDest_txt	dc.b	'Insert Destination Disk In Drive DF%1.1ld:.',0
NeedIconLib_txt	dc.b	20,'I Need icon.library!'
FileTypeErr_txt	dc.b	16,'File Type Error!'
PicSize_txt	dc.b	'%d*%d, %d Planes, (Page %d*%d)',0

BUF_txt		dc.b	'BufSize In KiloBytes:',0
DATE_txt	dc.b	'Date And Time (DD-MM-YY HH:MM:SS):',0
REN_txt		dc.b	'ReName File:',0
COPY_txt	dc.b	'Copy From:',0
MDIR_txt	dc.b	'Create Dir(s):',0
DEL_txt		dc.b	'Delete:',0
MOVE_txt	dc.b	'Move From:',0
PROT_txt	dc.b	'Protect:',0
INS_txt		dc.b	'Install Drive:',0
DIR_txt		dc.b	'Directory:',0
EXE_txt		dc.b	'Execute Command:',0
NOTE_txt	dc.b	'FileNote:',0
COMMENT_txt	dc.b	'Comment:',0
REL_txt		dc.b	'ReLabel Drive:',0
SRC_txt		dc.b	'Source Drive:',0
DEST_txt	dc.b	'Destination Drive:',0
FORMAT_txt	dc.b	'Format Drive:',0
NAME_txt	dc.b	'Name For Disk:',0
ASC_txt		dc.b	'ASCII File:',0
TO_txt		dc.b	'To:',0
AS_txt		dc.b	'As:',0
CREA_txt	dc.b	'Create .fastdir Into Directory:',0
GFX_txt		dc.b	'Name Of ILBM Or Icon File:',0
Empty_txt	dc.b	' ',0

TrkDir_txt	dc.b	'TrackDir',0
LastDir_txt	dc.b	'Last Dir',0
NoBoot_txt	dc.b	' NoBoot ',0
Quick_txt	dc.b	' Quick  ',0
Verify_txt	dc.b	' Verify ',0
FFS_txt		dc.b	'  FFS   ',0
BADD_txt	dc.b	'MarkBADD',0
Date_txt	dc.b	'  Date  ',0
Hide_txt	dc.b	'  Hide  ',0
Script_txt	dc.b	' Script ',0
Pure_txt	dc.b	'  Pure  ',0
Archive_txt	dc.b	'Archive ',0
Read_txt	dc.b	'  Read  ',0
Write_txt	dc.b	' Write  ',0
Execute_txt	dc.b	'Execute ',0
Delete_txt	dc.b	' Delete ',0
All_txt		dc.b	'  All   ',0
;Dates_txt	dc.b	' Dates  ',0
Comment_txt	dc.b	'Comments',0
Flags_txt	dc.b	' Flags  ',0

Vector_num	dc.b	'%08.8lx',0

ObjNotFnd	dc.b	'Object Not Found',0
FDelProt	dc.b	'File Protected From Deletion',0
FWriteProt	dc.b	'File Protected From Writing',0
FReadProt	dc.b	'File Protected From Reading',0
NoDev		dc.b	'Device Not Mounted',0
NoDisk		dc.b	'No Disk In Drive',0
NoDOS		dc.b	'Not A DOS Disk',0
WriteProt	dc.b	'Disk Write Protected',0
ObjInUse	dc.b	'Object In Use',0
ObjExists	dc.b	'Object AlReady Exists',0
DiskNotValid	dc.b	'Disk Not Validated',0
RenAcrDev	dc.b	'Rename Across Devices Attempted',0
DirNotEmpty	dc.b	'Directory Not Empty',0
Unknwn		dc.b	'?',0
NumKnownErrs	equ	13
ErrNums		dc.b	205,222,223,224,218,226,225,214,202,203
		dc.b	213,215,216
PixsLeft	dc.b	%11111111,%10000000,%11000000,%11100000,%11110000
		dc.b	%11111000,%11111100,%11111110
		cnop	0,2
ErrAddrs	dc.l	ObjNotFnd,FDelProt,FWriteProt,FReadProt
		dc.l	NoDev,NoDisk,NoDOS,WriteProt,ObjInUse,ObjExists
		dc.l	DiskNotValid,RenAcrDev,DirNotEmpty

Calendar	dc.w	31,28,31,30,31,30,31,31,30,31,30,31
K_Vuodet	dc.w	80-78,84-78,88-78,92-78,96-78,$ffff,$ffff

Boot13		dc.l	$43FA0018,$4EAEFFA0,$4A80670A,$20402068,$00167000
		dc.l	$4E7570FF,$60FA646F,$732E6C69,$62726172,$79000000
B13Len		equ	*-Boot13
Boot20		dc.l	$43FA003E,$70254EAE,$FDD84A80,$670C2240,$08E90006
		dc.l	$00224EAE,$FE6243FA,$00184EAE,$FFA04A80,$670A2040
		dc.l	$20680016,$70004E75,$70FF4E75,$646F732E,$6C696272
		dc.l	$61727900,$65787061,$6E73696F,$6E2E6C69,$62726172
		dc.l	$79000000
B20Len		equ	*-Boot20
BootMsg		dc.b	'* This Disk Was Installed With',0
		dc.b	' By MpL *',0
		cnop	0,4

ChangedGfx	_ArrowPtr_	; MUST be long-aligned!
		_BusyPtr_
		_DwnArrowData_
		_UpArrowData_
		_PDwnArrowData_
		_PUpArrowData_
		_BotArrowData_
		_TopArrowData_
		dc.l	0,0,0	; OffPtrData
MoveGfx_SIZE	equ	*-ChangedGfx
		endm
