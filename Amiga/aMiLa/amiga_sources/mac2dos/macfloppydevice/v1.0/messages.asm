* FROM MAC.ASM

Mac.		TEXTZ	<'Mac volume: '>
Dos.		TEXTZ	<'Amiga volume: '>
EditTitle.	TEXTZ	<'Edit File type/creator and Default tool names'>
Type.		TEXTZ	<'Mac Type'>
Creator.	TEXTZ	<'Creator'>
ToolName.	TEXTZ	<'Amiga Default Tool Name'>
NoMacDrv.	TEXTZ	<'Can''t find Mac disk drive...quitting'>

* FROM CMDS.ASM

NoConv.		TEXTZ	<'None (pure binary)        '>
MacBin.		TEXTZ	<'MacBinary                 '>
ASCII.		DC.B	 'Mac ASCII <--> Amiga ASCII',0
Post.		TEXTZ	<'PostScript                '>
MPIFF.		DC.B	 'MacPaint <--> Amiga IFF   ',0
CopyTitle.	TEXTZ	<'File Copy Status'>
TypeTitle.	TEXTZ	<'Contents of file: '>
CpyMacAmy.	TEXTZ	<'Copying files from Mac to Amiga'>
CpyAmyMac.	TEXTZ	<'Copying files from Amiga to Mac'>
File.		TEXTZ	<'File '>
Block.		TEXTZ	<'Block '>
Ofstg		TEXTZ	<' of '>
Blanks.		TEXTZ	<'    '>
FromAmy.	TEXTZ	<'From Amiga: '>
FromMac.	TEXTZ	<'From Mac: '>
ToAmy.		TEXTZ	<'To Amiga: '>
ToMac.		TEXTZ	<'To Mac: '>
Trans.		TEXTZ	<'Conversion: '>
NoDelete.	TEXTZ	<'No files selected to delete.'>
AskDel1.	TEXTZ	<'WARNING - You are about to delete'>
MacDel2.	TEXTZ	<'% Mac file(s).'>
DosDel2.	TEXTZ	<'% Amiga file(s).'>
AskDel3.	TEXTZ	<'Are you sure you want to proceed?'>
Tool1.		TEXTZ	<'Enter Amiga tool type:'>
Bin1.		TEXTZ	<'Enter Mac file type:'>
Bin2.		TEXTZ	<'Enter Mac file creator:'>
IncNam.		TEXTZ	<'Enter name of file to be included.'>
ExcNam.		TEXTZ	<'Enter name of file to be excluded.'>
Wild.		TEXTZ	<'Use wildcards ''?'' or ''#?'' for groups.'>
Tool2.
Bin3.		TEXTZ	<'See User''s Guide for details.'>
Eof.		TEXTZ	<'End of file.'>

* FROM COPY.ASM

NoMacFiles.	TEXTZ	<'No Mac files selected to process.'>
NoDosFiles.	TEXTZ	<'No Amiga files selected to process.'>
NotMPFile.	TEXTZ	<'File is not in MacPaint format:'>
NotIFFFile.	TEXTZ	<'File is not in IFF format:'>
NoLIST.		TEXTZ	<'IFF LIST format not supported:'>
BadIFFformat.	TEXTZ	<'IFF file data corrupted:'>
NoMacDisk.	TEXTZ	<'No Mac diskette loaded.'>
InvMacDisk.	TEXTZ	<'Not a Mac disk in Mac drive.'>
InvDosVol.	TEXTZ	<'Amiga volume undefined.'>

* FROM ILBM.ASM

NoMem.	TEXTZ	<'Out of memory...cannot copy file.'>

* FROM WIND.ASM

BAD_DIR.	TEXTZ	<'Invalid directory.'>
Bytes.		TEXTZ	<'Bytes free: '>
NO_PARENT.	TEXTZ	<'No parent directory.'>
NO_ROOT.	TEXTZ	<'No root directory.'>
ReadMacDir.	TEXTZ	<'Loading Mac disk directory...'>
Drawer.		TEXTZ	<' Drawer'>
Folder.		TEXTZ	<' Folder'>
Root.		TEXTZ	<'(root)'>
NoMacDisk.	TEXTZ	<'No Mac disk loaded'>
InvMacDisk.	TEXTZ	<'Not a Mac disk'>

* FROM MACFILES.ASM

;CantDelFile.	TEXTZ	<'Can''t delete protected file:'>
CantOpenMac.	TEXTZ	<'Unable to open Mac file:'>
CantCreateMac.	TEXTZ	<'Unable to create Mac file:'>
MacFmtErr.	TEXTZ	<'Unknown Mac disk format.'>
MacDskFull.	TEXTZ	<'Mac disk is full.'>
MacDirFull.	TEXTZ	<'Mac directory is full.'>
Int3.		TEXTZ	<'HFS error 3'>

* FROM DOSFILES.ASM

NoMemory.	TEXTZ	<'Out of memory...aborting.'>
VolErr.		TEXTZ	<'Amiga volume undefined.'>
CurPathErr.	TEXTZ	<'Amiga path error.'>
CantDelFile.	TEXTZ	<'Can''t delete protected file:'>
CantOpenDos.	TEXTZ	<'Unable to open Amiga file:'>
CantCreateInfo.	TEXTZ	<'Unable to create icon for file:'>
CantCreateDos.	TEXTZ	<'Unable to create Amiga file:'>
FuncNotAvail.	TEXTZ	<'Function not yet implemented.'>
DiskBad.	TEXTZ	<'Amiga directory error: garbage.'>
FileLim.	TEXTZ	<'Amiga directory error: looping.'>
Info.		TEXTZ	<'.info'>
ReadDosDir.	TEXTZ	<'Loading Amiga directory...'>

* FROM DISK.ASM

MF.		TEXTZ	'macfloppy.device'
MacReadErr.	TEXTZ	<'Error reading Mac disk.'>
MacWriteErr.	TEXTZ	<'Error writing Mac disk.'>
MacFormErr.	TEXTZ	<'Error formatting Mac disk.'>
WrtProt.	TEXTZ	<'Mac disk is write-protected.'>

* FROM DISKCMDS.ASM

Format0. TEXTZ	<'Format Macintosh diskette'>
Format1. TEXTZ	<'WARNING - Old contents will be lost!'>
RenVol.
Format2. TEXTZ	<'Enter new volume name:'>
Format3. TEXTZ	<'Formatting Mac disk ... please wait'>
Verify.	 TEXTZ	<'Verifying Mac disk ... please wait'>
Create.	 TEXTZ	<'Creating directory ... please wait'>
Untitled. TEXTZ	<'Untitled'>
;VerifyPassed.	TEXTZ	<'Mac disk has no errors.'>
VerifyFailed.	TEXTZ	<'Mac disk verify failed.'>
FormatFailed.	TEXTZ	<'Formatting attempt unsuccessful.'>
SSDrive.	TEXTZ	<'Your Mac drive is single-sided.'>
FInfo0.	TEXTZ	<'FILE INFO'>
FInfo1.	TEXTZ	<'Name:'>
FInfo2.	TEXTZ	<'Size:'>
FInfo3.	TEXTZ	<'Date:'>
FInfo4.	TEXTZ	<'Protected:'>
FInfo5.	TEXTZ	<'Type:'>
FInfo6.	TEXTZ	<'Creator:'>	

* FROM MENUS.ASM

PROJ_TXT	PTEXTZ	<'Project'>
MDSK_TXT	PTEXTZ	<'Mac Disk'>
FUTL_TXT	PTEXTZ	<'File Utilities'>
SELF_TXT	PTEXTZ	<'Select Files'>
FCONV_TXT	PTEXTZ	<'Conversions'>
OPT_TXT		PTEXTZ	<'Other Options'>

AM2D_TXT	MTXT	<'About M2D'>
LODOPT_TXT	MTXT	<'Load Options'>
CONVDEF_TXT	MTXT	<'Edit Types/Tools'>
SAVOPT_TXT	MTXT	<'Save Options'>
QUIT_TXT	MTXT	<'Quit'>

EJCT_TXT	MTXT	<'Eject Disk  '>
;FLDR_TXT	MTXT	<'Make Folder '>
RNAMV_TXT	MTXT	<'Rename Disk '>
VRFY_TXT	MTXT	<'Verify Disk '>
FMAT_TXT	MTXT	<'Format Disk '>

INFO_TXT	MTXT	<'File info    '>
DISP_TXT	MTXT	<'Display Text '>
RNAMF_TXT	MTXT	<'Rename File  '>
DELF_TXT	MTXT	<'Delete File  '>

IALL_TXT	MTXT	<'Include All  '>
INAM_TXT	MTXT	<'Include Name '>
EALL_TXT	MTXT	<'Exclude All  '>
ENAM_TXT	MTXT	<'Exclude Name '>

BIN_TXT		MTXT	NCtxt.,1
MACBIN_TXT	MTXT	<'  MacBinary     '>
ASCII_TXT	MTXT	AStxt.,1
POST_TXT	MTXT	PStxt.,1
MACP_TXT	MTXT	MPtxt.,1

NCtxt.		TEXTZ	<'  No Conversion '>
AStxt.		TEXTZ	<'  ASCII (text)  '>
PStxt.		TEXTZ	<'  PostScript    '>
MPtxt.		TEXTZ	<'  MacPaint-IFF  '>

ICON_TXT	MTXT	<'  Amiga Icon    '>
AMY_TXT		MTXT	<'  Ask Amiga Tool'>
MAC_TXT		MTXT	<'  Ask Mac Type  '>
AUTO_TXT	MTXT	<'  Auto-Replace  '>
RES_TXT		MTXT	<'Amiga Resolution'>

LowResTxt	MTXT	<'  320x200'>
HiResTxt	MTXT	<'  640x400'>

* FROM VERSION.ASM

About0.	TEXTZ	<'Mac-2-Dos V1.1a, August 30, 1989'>
About1.	DC.B	'Copyright ',$A9,' 1989',0
About2.	TEXTZ	<'Central Coast Software'>
About3.	TEXTZ	<'424 Vista Avenue'>
About4.	TEXTZ	<'Golden, CO 80401 USA'>
About5.	TEXTZ	<'303-526-1030'>

* FROM GADGETS.ASM

CANTXT	TEXT	BLACK,WHITE,JAM2,8,3,'Cancel',0
ROOTXT	TEXT	BLACK,ORANGE,JAM2,16,2,'Root',0
PARTXT	TEXT	BLACK,ORANGE,JAM2,8,2,'Parent',0
TRYTXT	TEXT	BLACK,WHITE,JAM2,8,3,<'Retry'>,0
POSTXT	TEXT	BLACK,WHITE,JAM2,24,3,<'YES'>,0
NEGTXT	TEXT	ORANGE,WHITE,JAM2,8,3,<'Cancel'>,0
NOTXT	TEXT	ORANGE,WHITE,JAM2,28,3,<'NO'>,0
OKTXT	TEXT	BLACK,WHITE,JAM2,8,3,<' Okay '>,0

DSTXT	TEXT	BLACK,WHITE,JAM2,8,2,'Two-Sided',0
SSTXT	TEXT	BLACK,WHITE,JAM2,8,2,'One-Sided',0
ESaveTxt TEXT	BLACK,WHITE,JAM1,12,2,'Save',0
EUseTxt	TEXT	BLACK,WHITE,JAM1,16,2,'Use',0
ECanTxt	TEXT	BLACK,ORANGE,JAM1,8,2,'Cancel',0
CanTxt	TEXT	ORANGE,WHITE,JAM2,20,2,'CANCEL',0
AbtTxt	TEXT	BLACK,0,JAM1,12,2,'CANCEL',0
SkipTxt	TEXT	BLACK,0,JAM1,20,2,'SKIP',0
ProcTxt	TEXT	BLACK,0,JAM1,8,2,'PROCEED',0

CTXT	TEXTZ	'COPY'
ASDTXT	TEXTZ	<'Do you want to delete this file?'>
ASRTXT	TEXTZ	<'Do you want to replace this file?'>
CONTXT	TEXTZ	<'Disk read error.  Proceed with test?'>
Dup1.	TEXTZ	<'This file already exists:'>
Dup2.	TEXTZ	<'Do you want to replace it?'>

* FROM MFIO.ASM

Timer.	TEXTZ	<'Timer B already in use.'>






