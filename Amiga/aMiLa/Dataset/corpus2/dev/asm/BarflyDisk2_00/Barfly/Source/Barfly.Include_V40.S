;	bopt	l
****************************************************************************
*                                                                          *
* Include Structure Macro File                                             *
* Version: 1.1                                                             *
* Comment: The structure build Macros should NEVER be changed!             *
*          Don't touch this ! It's always subject to change!               *
*          Just use the defined Macros to add your own structure.          *
*                                                                          *
****************************************************************************
	NOLIST

SINCMEMMASK equ $f
SINCCOMMASK equ $f000

SINC_END        equ 0
SINC_APTR       equ $1004
SINC_CSTR       equ $2004
SINC_BPTR       equ $3004
SINC_BSTR       equ $4004
SINC_CPTR       equ $5004
SINC_BYTE       equ $6001
SINC_WORD       equ $7002
SINC_LONG       equ $8004
SINC_FPTR       equ SINC_CPTR
SINC_UBYTE      equ SINC_BYTE
SINC_UWORD      equ SINC_WORD
SINC_ULONG      equ SINC_LONG
SINC_BOOL       equ SINC_BYTE
SINC_SHORT      equ SINC_WORD
SINC_USHORT     equ SINC_WORD
SINC_FLOAT      equ $9004
SINC_DOUBLE     equ $a008
SINC_EXTENDED   equ $b00c
SINC_RPTR       equ $c002
SINC_LABEL      equ $d000
SINC_STRUCT     equ $e000


CS	set	0

****************************************************************************

STRUCTITEM:	MACRO
	dc.w	SINC_\1		;si_Flag
	dc.l	\2		;si_Offset
	IFEQ	NARG-3
	dc.l	\3_STRUCT	;si_Link auf andere Strukturen
	ENDC
	IFEQ	NARG-2
	dc.l	0		;si_Link nicht gegeben
	ENDC
	dc.w	STRUCTITEM_string_\@_end-STRUCTITEM_string_\@_start-1
STRUCTITEM_string_\@_start:
	dc.b	"\2",0		;String
STRUCTITEM_string_\@_end:
	cnop	0,2
	ENDM

****************************************************************************

STRUCTUREEND:	MACRO
	dc.w	SINC_END	;Struktur Ende
	ENDM

****************************************************************************

; structure name, initial offset
; will only define a new structure if these structure is unknown.
; This allows to include all includes and place the changed
; structures in front of the includes.

STRUCTURE:	MACRO
	IFND	\1_STRUCT
	IFNV	\2

	IFND	\2_STRUCT
	STRUCTURE_OFFSET	\1,\2
	ELSE
	STRUCTURE_STRUCT	\1,\2
	ENDC
	ENDC

	IFV	\2
	STRUCTURE_OFFSET	\1,\2
	ENDC
	ENDC
	ENDM


STRUCTURE_STRUCT:	MACRO
	STRUCTUREEND
\1_STRUCT:
\1_SIZE_STRUCT:
\1_SIZEOF_STRUCT:
\1	=	0
CS	set	\1_STRUCT
	dc.w	SINC_STRUCT		;si_Flag

;	IFD	\2_SIZE
;SOFFSET	SET	\2_SIZE
;	ENDC
;	IFD	\2_SIZEOF
;SOFFSET	SET	\2_SIZEOF
;	ENDC

SOFFSET SET \2

	dc.l	\1			;si_Offset
	dc.l	\2_STRUCT		;si_Link
	dc.w	STRUCTURE_string_\@_end-STRUCTURE_string_\@_start-1
STRUCTURE_string_\@_start:
	dc.b	"\1",0			;String
STRUCTURE_string_\@_end:
	cnop	0,2
	ENDM

STRUCTURE_OFFSET:	MACRO
	STRUCTUREEND
\1_STRUCT:
\1	=	0
CS	set	\1_STRUCT
SOFFSET     SET     \2
	ENDM
****************************************************************************




****************************************************************************

;\1 Name
;\2 Offset,Structname Length

STRUCT:		MACRO
	IFND	\1
	IFNV	\2

	IFND	\2_STRUCT
	STRUCT_OFFSET	\1,\2
	ELSE
	STRUCT_STRUCT	\1,\2
	ENDC
	ENDC

	IFV	\2
	STRUCT_OFFSET	\1,\2
	ENDC
	ENDC
	ENDM


STRUCT_STRUCT:	MACRO
\1=SOFFSET

SOFFSET	SET	SOFFSET+\2
;	IFD	\2_SIZE
;SOFFSET	SET	SOFFSET+\2_SIZE
;	ENDC
;	IFD	\2_SIZEOF
;SOFFSET	SET	SOFFSET+\2_SIZEOF
;	ENDC

	dc.w	SINC_STRUCT	;|(SOFFSET-\1)	;si_Flag
	dc.l	\1				;Offset

	dc.l	\2_STRUCT		;si_Link..x_Size_STRUCT

	dc.w	STRUCT_string_\@_end-STRUCT_string_\@_start-1
STRUCT_string_\@_start:
	dc.b	"\1",0				;String
STRUCT_string_\@_end:
	cnop	0,2
	ENDM


STRUCT_OFFSET:	MACRO
	IFC	'\2','0'
	LABEL	\1
	ENDC
	IFNC	'\2','0'
\1=SOFFSET
SOFFSET	SET	SOFFSET+\2
	dc.w	SINC_STRUCT|(\2);si_Flag
	dc.l	\1		;si_Offset
	dc.l	0		;si_Link=0,Also Bytes
	dc.w	STRUCTB_string_\@_end-STRUCTB_string_\@_start-1
STRUCTB_string_\@_start:
	dc.b	"\1",0		;String
STRUCTB_string_\@_end:
	cnop	0,2
	ENDC
	ENDM



****************************************************************************





BOOL:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+2
	STRUCTITEM	BOOL,\1
	ENDC
	ENDM

BYTE:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+1
	STRUCTITEM	BYTE,\1
	ENDC
	ENDM

UBYTE:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+1
	STRUCTITEM	UBYTE,\1
	ENDC
	ENDM

WORD:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+2
	STRUCTITEM	WORD,\1
	ENDC
	ENDM

UWORD:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+2
	STRUCTITEM	UWORD,\1
	ENDC
	ENDM

SHORT:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+2
	STRUCTITEM	SHORT,\1
	ENDC
	ENDM

USHORT:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+2
	STRUCTITEM	USHORT,\1
	ENDC
	ENDM

LONG:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	LONG,\1
	ENDC
	ENDM

ULONG:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	ULONG,\1
	ENDC
	ENDM

FLOAT:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	FLOAT,\1
	ENDC
	ENDM

DOUBLE:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET	    SET	    SOFFSET+8
	STRUCTITEM	DOUBLE,\1
	ENDC
	ENDM

EXTENDED:	MACRO
	IFND	\1
\1=SOFFSET
SOFFSET	SET	SOFFSET+12
	STRUCTITEM	EXTENDED,\1
	ENDC
	ENDM


FPTR:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	FPTR,\1
	ENDC
	ENDM

CPTR:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	CPTR,\1
	ENDC
	ENDM

BPTR:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	BPTR,\1,\2
	ENDC
	ENDM

BSTR:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	BSTR,\1,\2
	ENDC
	ENDM

APTR:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET     SET     SOFFSET+4
	STRUCTITEM	APTR,\1,\2
	ENDC
	ENDM

CSTR:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET	SET	SOFFSET+4
	STRUCTITEM	CSTR,\1,\2
	ENDC
	ENDM


RPTR:		MACRO
	IFND	\1
\1=SOFFSET
SOFFSET	SET	SOFFSET+2
	STRUCTITEM	RPTR,\1,\2
	ENDC
	ENDM

LABEL:		MACRO
	IFND	\1
\1=SOFFSET
	IFND	\1_STRUCT
\1_STRUCT	=	CS
	ENDC
	STRUCTITEM	LABEL,\1
	ENDC
	ENDM


ALIGNWORD:	MACRO
SOFFSET     SET     (SOFFSET+1)&$fffffffe
	ENDM

ALIGNLONG:	MACRO
SOFFSET	SET	(SOFFSET+3)&$fffffffc
	ENDM
****************************************************************************

EXEC_TYPES_I	SET	1			;Types.i already included

INCLUDE_VERSION	EQU 40	;Version of the include files in use. (Do not
			;use this label for OpenLibrary() calls!)


EXTERN_LIB  MACRO
	    XREF    _LVO\1
	    ENDM

ENUM	    MACRO   ;[new base]
	    IFC     '\1',''
EOFFSET	    SET	    0		; Default to zero
	    ENDC
	    IFNC    '\1',''
EOFFSET	    SET     \1
	    ENDC
	    ENDM

EITEM	    MACRO   ;label
\1	    EQU     EOFFSET
EOFFSET     SET     EOFFSET+1
	    ENDM

BITDEF	    MACRO   ; prefix,&name,&bitnum
	    BITDEF0 \1,\2,B_,\3
\@BITDEF    SET     1<<\3
	    BITDEF0 \1,\2,F_,\@BITDEF
	    ENDM

BITDEF0     MACRO   ; prefix,&name,&type,&value
\1\3\2	    EQU     \4
	    ENDM

LIBRARY_MINIMUM	EQU 33	;Lowest version supported by Commodore-Amiga

****************************************************************************


MENUDIR:	MACRO
	dc.l	MENUDIR_end\@
	dc.l	\2
	dc.l	\3
	dc.l	0
	dc.w	0
	dc.b	"\1",0
	cnop	0,2
MENUDIR_end\@:
	ENDM

MENUDIREND:	MACRO
	dc.l	0
	dc.l	\2
	dc.l	\3
	dc.l	0
	dc.w	0
	dc.b	"\1",0
	cnop	0,2
	ENDM

MENUITEM:	MACRO
	dc.l	MENUITEM_end\@
	dc.l	\2
	dc.l	0
	dc.l	\1_STRUCT
	dc.w	0
	dc.b	"\1",0
	cnop	0,2
MENUITEM_end\@:
	ENDM

MENUITEMEND:	MACRO
	dc.l	0
	dc.l	\2
	dc.l	0
	dc.l	\1_STRUCT
	dc.w	0
	dc.b	"\1",0
	cnop	0,2
	ENDM

****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************

START:
	moveq	#0,d0				;Save End
	rts

Include_File_Header:
	dc.l	$4afc				;Magic Word
	dc.l	1				;Version
	dc.l	RootDir				;Pointer the RootDir
	dc.l	MYCUSTOMENTRY			;Pointer the Custom Directory
						;That will include
						;your custom entries

****************************************************************************

RootDir:
	MENUDIR		devices,0,Devices_Dir
	MENUDIR		dos,0,Dos_Dir
	MENUDIR		exec,0,Exec_Dir
	MENUDIR		graphics,0,Graphics_Dir
	MENUDIR		intuition,0,Intuition_Dir
	MENUDIR		libraries,0,Libraries_Dir
	MENUDIR		resources,0,Resources_Dir
	MENUDIR		rexx,0,Rexx_Dir
	MENUDIR		utility,0,Utility_Dir
	MENUDIR		workbench,0,Workbench_Dir
	MENUDIR		prefs,0,Prefs_Dir
	MENUDIR		gadgets,0,Gadgets_Dir
	MENUDIR		datatypes,0,Datatypes_Dir
	MENUDIR		diskfont,0,Diskfont_Dir
	MENUITEM	TestGfxBase,0
MYCUSTOMENTRY:
	MENUDIREND	CUSTOM,0,0

Devices_Dir:
	MENUDIR		audio.i,RootDir,Audio_Dir
	MENUDIR		bootblock.i,RootDir,BootBlock_Dir
	MENUDIR		clipboard.i,RootDir,ClipBoard_Dir
	MENUDIR		conunit.i,RootDir,ConUnit_Dir
	MENUDIR		gameport.i,RootDir,GamePort_Dir
	MENUDIR		hardblocks.i,RootDir,HardBlocks_Dir
	MENUDIR		inputevent.i,RootDir,InputEvent_Dir
	MENUDIR		keymap.i,RootDir,KeyMap_Dir
	MENUDIR		narrator.i,RootDir,Narrator_Dir
	MENUDIR		parallel.i,RootDir,Paralell_Dir
	MENUDIR		printer.i,RootDir,Printer_Dir
	MENUDIR		prtbase.i,RootDir,PrtBase_Dir
	MENUDIR		prtgfx.i,RootDir,PrtGfx_Dir
	MENUDIR		scsidisk.i,RootDir,ScsiDisk_Dir
	MENUDIR		serial.i,RootDir,Serial_Dir
	MENUDIR		timer.i,RootDir,Timer_Dir
	MENUDIREND	trackdisk.i,RootDir,TrackDisk_Dir

Dos_Dir:
	MENUDIR		datetime.i,RootDir,DateTime_Dir
	MENUDIR		dos.i,RootDir,Dos_0_Dir
	MENUDIR		dosasl.i,RootDir,DosAsl_Dir
	MENUDIR		dosextens.i,RootDir,DosExtens_Dir
	MENUDIR		exall.i,RootDir,Exall_Dir
	MENUDIR		filehandler.i,RootDir,FileHandler_Dir
	MENUDIR		notify.i,RootDir,Notify_Dir
	MENUDIR		rdargs.i,RootDir,Rdargs_Dir
	MENUDIR		record.i,RootDir,Record_Dir
	MENUDIREND	var.i,RootDir,Var_Dir

Exec_Dir:
	MENUDIR		devices.i,RootDir,Devices_0_Dir
	MENUDIR		execbase.i,RootDir,ExecBase_Dir
	MENUDIR		interrupts.i,RootDir,Interrupts_Dir
	MENUDIR		io.i,RootDir,IO_Dir
	MENUDIR		libraries.i,RootDir,Libraries_0_Dir
	MENUDIR		lists.i,RootDir,Lists_Dir
	MENUDIR		memory.i,RootDir,Memory_Dir
	MENUDIR		nodes.i,RootDir,Nodes_Dir
	MENUDIR		ports.i,RootDir,Ports_Dir
	MENUDIR		resident.i,RootDir,Resident_Dir
	MENUDIR		semaphores.i,RootDir,Semaphores_Dir
	MENUDIREND	tasks.i,RootDir,Tasks_Dir

Graphics_Dir:
	MENUDIR		clip.i,RootDir,Clip_Dir
;	MENUDIR		coerce.i,RootDir,Coerce_Dir
	MENUDIR		copper.i,RootDir,Copper_Dir
;	MENUDIR		display.i,RootDir,Display_Dir
	MENUDIR		displayinfo.i,RootDir,DisplayInfo_Dir
	MENUDIR		gels.i,RootDir,Gels_Dir
	MENUDIR		gfx.i,RootDir,Gfx_Dir
	MENUDIR		gfxbase.i,RootDir,GfxBase_Dir
	MENUDIR		gfxnodes.i,RootDir,GfxNodes_Dir
	MENUDIR		layers.i,RootDir,Layers_Dir
;	MENUDIR		modeid.i,RootDir,ModeID_Dir
	MENUDIR		monitor.i,RootDir,Monitor_Dir
	MENUDIR		rastport.i,RootDir,RastPort_Dir
	MENUDIR		regions.i,RootDir,Regions_Dir
;	MENUDIR		rpattr.i,RootDir,RPattr_Dir
	MENUDIR		scale.i,RootDir,Scale_Dir
	MENUDIR		sprite.i,RootDir,Sprite_Dir
	MENUDIR		text.i,RootDir,Text_Dir
	MENUDIREND	view.i,RootDir,View_Dir
;	MENUDIREND	videocontrol.i,RootDir,Viedeocontrol_Dir


Intuition_Dir:
	MENUDIR		cghooks.i,RootDir,CGHooks_Dir
	MENUDIR		classes.i,RootDir,Classes_Dir
	MENUDIR		classusr.i,RootDir,ClassUsr_Dir
	MENUDIR		gadgetclass.i,RootDir,GadgetClass_Dir
;	MENUDIR		icclass.i,RootDir,ICClass_Dir
	MENUDIR		imageclass.i,RootDir,ImageClass_Dir
	MENUDIR		intuition.i,RootDir,Intuition_0_Dir
	MENUDIR		intuitionbase.i,RootDir,IntuitionBase_Dir
	MENUDIR		preferences.i,RootDir,Preferences_Dir
	MENUDIR		screens.i,RootDir,Screens_Dir
;	MENUDIR		pointerclass.i,RootDir,PointerClass_Dir
	MENUDIREND	sghooks.i,RootDir,SGHooks_Dir


Libraries_Dir:
	MENUDIR		asl.i,RootDir,Asl_Dir
	MENUDIR		commodities.i,RootDir,Commodities_Dir
	MENUDIR		configregs.i,RootDir,ConfirRegs_Dir
	MENUDIR		configvars.i,RootDir,ConfigVars_Dir
	MENUDIR		diskfont.i,RootDir,DiskFont_Dir
	MENUDIR		dos.i,RootDir,Dos_0_Dir
	MENUDIR		dosextens.i,RootDir,DosExtens_Dir
	MENUDIR		expansionbase.i,RootDir,ExpansionBase_Dir
	MENUDIR		gadtools.i,RootDir,GadTools_Dir
	MENUDIR		iffparse.i,RootDir,IffParse_Dir
	MENUDIR		mathlibrary.i,RootDir,MathLibrary_Dir
	MENUDIREND		mathresource.i,RootDir,MathResource_Dir

Resources_Dir:
	MENUDIR		disk.i,RootDir,Disk_Dir
	MENUDIR		filesysres.i,RootDir,FileSysRes_Dir
	MENUDIREND	mathresource.i,RootDir,MathResource_Dir

Rexx_Dir:
;	MENUDIR		rexxio.i,RootDir,RexxIO_Dir
;	MENUDIR		rxslib.i,RootDir,RxsLib_Dir
;	MENUDIREND	storage.i,RootDir,Storage_Dir

Utility_Dir:
	MENUDIR		date.i,RootDir,Date_Dir
	MENUDIR		hooks.i,RootDir,Hooks_Dir
	MENUDIREND	tagitem.i,RootDir,TagItem_Dir

Workbench_Dir:
	MENUDIR		startup.i,RootDir,StartUp_Dir
	MENUDIREND	workbench.i,RootDir,Workbench_0_Dir

Prefs_Dir:
	MENUDIR		input.i,RootDir,InputPrefs_Dir
	MENUDIR		locale.i,RootDir,LocalePrefs_Dir
	MENUDIR		overscan.i,RootDir,OverscanPrefs_Dir
	MENUDIR		palette.i,RootDir,Paletterefs_Dir
	MENUDIR		pointer.i,RootDir,PointerPrefs_Dir
	MENUDIR		prefhdr.i,RootDir,PrefhdrPrefs_Dir
	MENUDIR		printergfx.i,RootDir,PrintergfxPrefs_Dir
	MENUDIR		printerps.i,RootDir,Printerps_Dir
	MENUDIR		printertxt.i,RootDir,PrintertxtPrefs_Dir
	MENUDIR		screenmode.i,RootDir,ScreenmodePrefs_Dir
	MENUDIR		serial.i,RootDir,SerialPrefs_Dir
	MENUDIR		sound.i,RootDir,SoundPrefs_Dir
	MENUDIREND	wbpattern.i,RootDir,WBPatternPrefs_Dir

Gadgets_Dir:
	MENUDIREND	colorwheel.i,RootDir,Colorwheel_Dir
;	MENUDIR		gradientslider.i,RootDir,Gradientslider_Dir
;	MENUDIREND	tapedeck.i,RootDir,Tapedeck_Dir

Datatypes_Dir:
	MENUDIR		animationclass.i,RootDir,Animationclass_Dir
	MENUDIR		datatypes.i,RootDir,Datatypes_0_Dir
	MENUDIR		datatypesclass.i,RootDir,Datatypesclass_Dir
	MENUDIR		pictureclass.i,RootDir,Pictureclass_Dir
	MENUDIR		soundclass.i,RootDir,Soundclass_Dir
	MENUDIREND	textclass.i,RootDir,Textclass_Dir

Diskfont_Dir:
	MENUDIR		diskfont.i,RootDir,Diskfont_0_Dir
;	MENUDIR		diskfonttag.i,RootDir,Diskfonttag_Dir
	MENUDIREND	glyph.i,RootDir,Glyph_Dir
;	MENUDIREND	oterrors.i,RootDir,OTErrors_Dir

****************************************************************************

Devices_0_Dir:
	MENUITEM	DD,Exec_Dir
	MENUITEMEND	UNIT,Exec_Dir
ExecBase_Dir:
	MENUITEMEND	ExecBase,Exec_Dir
Interrupts_Dir:
	MENUITEM	IS,Exec_Dir
	MENUITEM	IV,Exec_Dir
	MENUITEMEND	SH,Exec_Dir
IO_Dir:
	MENUITEMEND	IO,Exec_Dir
Libraries_0_Dir:
	MENUITEMEND	LIB,Exec_Dir
Lists_Dir:
	MENUITEM	LH,Exec_Dir
	MENUITEMEND	MLH,Exec_Dir
Memory_Dir:
	MENUITEM	ML,Exec_Dir
	MENUITEM	ME,Exec_Dir
	MENUITEM	MH,Exec_Dir
	MENUITEMEND	MC,Exec_Dir
Nodes_Dir:
	MENUITEM	LN,Exec_Dir
	MENUITEMEND	MLN,Exec_Dir
Ports_Dir:
	MENUITEM	MP,Exec_Dir
	MENUITEMEND	MN,Exec_Dir
Resident_Dir:
	MENUITEMEND	RT,Exec_Dir
Semaphores_Dir:
	MENUITEM	SSR,Exec_Dir
	MENUITEM	SS,Exec_Dir
	MENUITEMEND	SM,Exec_Dir
Tasks_Dir:
	MENUITEM	TC_Struct,Exec_Dir
	MENUITEM	ETask,Exec_Dir
	MENUITEMEND	StackSwapStruct,Exec_Dir

****************************************************************************

Audio_Dir:
	MENUITEMEND	IOAudio,Devices_Dir
BootBlock_Dir:
	MENUITEMEND	BB,Devices_Dir
ClipBoard_Dir:
	MENUITEM	ClipboardUnitPartial,Devices_Dir
	MENUITEM	IOClipReq,Devices_Dir
	MENUITEM	SatisfyMsg,Devices_Dir
	MENUITEMEND	ClipHookMsg,Devices_Dir
ConUnit_Dir
	MENUITEMEND	ConUnit,Devices_Dir
GamePort_Dir:
	MENUITEMEND	GamePortTrigger,Devices_Dir
HardBlocks_Dir:
	MENUITEM	RigidDiskBlock,Devices_Dir
	MENUITEM	BadBlockEntry,Devices_Dir
	MENUITEM	BadBlockBlock,Devices_Dir
	MENUITEM	PartitionBlock,Devices_Dir
	MENUITEM	FileSysHeaderBlock,Devices_Dir
	MENUITEMEND	LoadSegBlock,Devices_Dir
InputEvent_Dir:
	MENUITEM	IEPointerPixel,Devices_Dir
	MENUITEM	IEPointerTablet,Devices_Dir
	MENUITEMEND	InputEvent,Devices_Dir
KeyMap_Dir:
	MENUITEM	KeyMap,Devices_Dir
	MENUITEM	KeyMapNode,Devices_Dir
	MENUITEMEND	KeyMapResource,Devices_Dir
Narrator_Dir:
	MENUITEM	NDI,Devices_Dir
	MENUITEMEND	MRB,Devices_Dir
Paralell_Dir:
	MENUITEM	PTERMARRAY,Devices_Dir
	MENUITEMEND	IOEXTPAR,Devices_Dir
Printer_Dir:
	MENUITEM	IOPrtCmdReq,Devices_Dir
	MENUITEMEND	IODRPReq,Devices_Dir
PrtBase_Dir:
	MENUITEM	DeviceData,Devices_Dir
	MENUITEM	PrinterData,Devices_Dir
	MENUITEM	PrinterExtendedData,Devices_Dir
	MENUITEMEND	PrinterSegment,Devices_Dir
PrtGfx_Dir:
	MENUITEM	colorEntry,Devices_Dir
	MENUITEMEND	PrtInfo,Devices_Dir
ScsiDisk_Dir:
	MENUITEMEND	SCSICmd,Devices_Dir
Serial_Dir:
	MENUITEM	TERMARRAY,Devices_Dir
	MENUITEMEND	IOEXTSER,Devices_Dir
Timer_Dir:
	MENUITEM	TIMEVAL,Devices_Dir
	MENUITEM	ECLOCKVAL,Devices_Dir
	MENUITEMEND	TIMEREQUEST,Devices_Dir
TrackDisk_Dir:
	MENUITEM	IOEXTTD,Devices_Dir
	MENUITEM	DriveGeometry,Devices_Dir
	MENUITEM	TDU_PUBLICUNIT,Devices_Dir

****************************************************************************

DateTime_Dir:
	MENUITEMEND	DateTime,Dos_Dir
Dos_0_Dir:
	MENUITEM	DateStamp,Dos_Dir
	MENUITEM	FileInfoBlock,Dos_Dir
	MENUITEMEND	InfoData,Dos_Dir
DosAsl_Dir:
	MENUITEM	AnchorPath,Dos_Dir
	MENUITEMEND	AChain,Dos_Dir
DosExtens_Dir:
	MENUITEM	Process,Dos_Dir
	MENUITEM	FileHandle,Dos_Dir
	MENUITEM	DosPacket,Dos_Dir
	MENUITEM	StandardPacket,Dos_Dir
	MENUITEM	ErrorString,Dos_Dir
	MENUITEM	DosLibrary,Dos_Dir
	MENUITEM	RootNode,Dos_Dir
	MENUITEM	CliProcList,Dos_Dir
	MENUITEM	DosInfo,Dos_Dir
	MENUITEM	Segment,Dos_Dir
	MENUITEM	CommandLineInterface,Dos_Dir
	MENUITEM	DevList,Dos_Dir
	MENUITEM	DevInfo,Dos_Dir
	MENUITEM	DosList,Dos_Dir
	MENUITEM	DevProc,Dos_Dir
	MENUITEMEND	FileLock,Dos_Dir
Exall_Dir:
	MENUITEM	ExAllData,Dos_Dir
	MENUITEMEND	ExAllControl,Dos_Dir
FileHandler_Dir:
	MENUITEM	DosEnvec,Dos_Dir
	MENUITEM	FileSysStartupMsg,Dos_Dir
	MENUITEMEND	DeviceNode,Dos_Dir
Notify_Dir:
	MENUITEM	NotifyMessage,Dos_Dir
	MENUITEMEND	NotifyRequest,Dos_Dir
Rdargs_Dir:
	MENUITEM	CSource,Dos_Dir
	MENUITEMEND	RDArgs,Dos_Dir
Record_Dir:
	MENUITEMEND	RecordLock,Dos_Dir
Var_Dir:
	MENUITEMEND	LocalVar,Dos_Dir

****************************************************************************

Clip_Dir:
	MENUITEM	Layer,Graphics_Dir
	MENUITEMEND	ClipRect,Graphics_Dir
Copper_Dir:
	MENUITEM	CopIns,Graphics_Dir
	MENUITEM	cprlist,Graphics_Dir
	MENUITEM	CopList,Graphics_Dir
	MENUITEM	UCopList,Graphics_Dir
	MENUITEMEND	copinit,Graphics_Dir
DisplayInfo_Dir:
	MENUITEM	QueryHeader,Graphics_Dir
	MENUITEM	DisplayInfo,Graphics_Dir
	MENUITEM	DimensionInfo,Graphics_Dir
	MENUITEM	MonitorInfo,Graphics_Dir
	MENUITEM	NameInfo,Graphics_Dir
	MENUITEMEND	VecInfo,Graphics_Dir
Gels_Dir:
	MENUITEM	VS,Graphics_Dir
	MENUITEM	BOB,Graphics_Dir
	MENUITEM	AC,Graphics_Dir
	MENUITEM	AO,Graphics_Dir
	MENUITEMEND	DBP,Graphics_Dir
Gfx_Dir:
	MENUITEM	BitMap,Graphics_Dir
	MENUITEM	Rectangle,Graphics_Dir
	MENUITEM	Rect32,Graphics_Dir
	MENUITEMEND	tPoint,Graphics_Dir
GfxBase_Dir:
	MENUITEMEND	GfxBase,Graphics_Dir
GfxNodes_Dir:
	MENUITEMEND	XLN,Graphics_Dir
Layers_Dir:
	MENUITEMEND	Layer_Info,Graphics_Dir
Monitor_Dir:
	MENUITEM	AnalogSignalInterval,Graphics_Dir
	MENUITEM	SpecialMonitor,Graphics_Dir
	MENUITEMEND	MonitorSpec,Graphics_Dir
RastPort_Dir:
	MENUITEM	TmpRas,Graphics_Dir
	MENUITEM	GelsInfo,Graphics_Dir
	MENUITEM	RastPort,Graphics_Dir
	MENUITEMEND	AreaInfo,Graphics_Dir
Regions_Dir:
	MENUITEM	Region,Graphics_Dir
	MENUITEMEND	RegionRectangle,Graphics_Dir
Scale_Dir:
	MENUITEMEND	BitScaleArgs,Graphics_Dir
Sprite_Dir:
	MENUITEMEND	SimpleSprite,Graphics_Dir
Text_Dir:
	MENUITEM	TextAttr,Graphics_Dir
	MENUITEM	TTextAttr,Graphics_Dir
	MENUITEM	TextFont,Graphics_Dir
	MENUITEM	TextFontExtension,Graphics_Dir
	MENUITEM	ColorFontColors,Graphics_Dir
	MENUITEM	ColorTextFont,Graphics_Dir
	MENUITEMEND	TextExtent,Graphics_Dir
View_Dir:
	MENUITEM	ColorMap,Graphics_Dir
	MENUITEM	ViewPort,Graphics_Dir
	MENUITEM	View,Graphics_Dir
	MENUITEM	ViewExtra,Graphics_Dir
	MENUITEM	ViewPortExtra,Graphics_Dir
	MENUITEM	collTable,Graphics_Dir
	MENUITEMEND	RasInfo,Graphics_Dir

****************************************************************************

CGHooks_Dir:
	MENUITEMEND	GadgetInfo,Intuition_Dir
Classes_Dir:
	MENUITEM	ICLASS,Intuition_Dir
	MENUITEMEND	_Object,Intuition_Dir
ClassUsr_Dir:
	MENUITEM	Msg,Intuition_Dir
	MENUITEM	opSet,Intuition_Dir
	MENUITEM	opUpdate,Intuition_Dir
	MENUITEM	opGet,Intuition_Dir
	MENUITEMEND	opAddTail,Intuition_Dir
GadgetClass_Dir:
	MENUITEM	MsgHeader,Intuition_Dir
	MENUITEM	gpHitTest,Intuition_Dir
	MENUITEM	gpRender,Intuition_Dir
	MENUITEM	gpInput,Intuition_Dir
	MENUITEMEND	gpGoInactive,Intuition_Dir

ICClass_Dir:

ImageClass_Dir:
	MENUITEM	impFrameBox,Intuition_Dir
	MENUITEM	impDraw,Intuition_Dir
	MENUITEM	impErase,Intuition_Dir
	MENUITEMEND	impHitTest,Intuition_Dir
Intuition_0_Dir:
	MENUITEM	Menu,Intuition_Dir
	MENUITEM	MenuItem,Intuition_Dir
	MENUITEM	Requester,Intuition_Dir
	MENUITEM	Gadget,Intuition_Dir
	MENUITEM	ExtGadget,Intuition_Dir
	MENUITEM	BoolInfo,Intuition_Dir
	MENUITEM	PropInfo,Intuition_Dir
	MENUITEM	StringInfo,Intuition_Dir
	MENUITEM	IntuiText,Intuition_Dir
	MENUITEM	Border,Intuition_Dir
	MENUITEM	Image,Intuition_Dir
	MENUITEM	IntuiMessage,Intuition_Dir
	MENUITEM	ExtIntuiMessage,Intuition_Dir
	MENUITEM	IBox,Intuition_Dir
	MENUITEM	Window,Intuition_Dir
	MENUITEM	NewWindow,Intuition_Dir
	MENUITEM	ExtNewWindow,Intuition_Dir
	MENUITEM	Remember,Intuition_Dir
	MENUITEM	ColorSpec,Intuition_Dir
	MENUITEM	EasyStruct,Intuition_Dir
	MENUITEM	TabletData,Intuition_Dir
	MENUITEMEND	TabletHookData,Intuition_Dir

IntuitionBase_Dir:
	MENUITEMEND	IntuitionBase,Intuition_Dir
Preferences_Dir:
	MENUITEMEND	Preferences,Intuition_Dir
Screens_Dir:
	MENUITEM	DrawInfo,Intuition_Dir
	MENUITEM	Screen,Intuition_Dir
	MENUITEM	NewScreen,Intuition_Dir
	MENUITEM	ExtNewScreen,Intuition_Dir
	MENUITEMEND	PubScreenNode,Intuition_Dir
SGHooks_Dir:
	MENUITEM	StringExtend,Intuition_Dir
	MENUITEMEND	SGWork,Intuition_Dir

PointerClass_Dir:

****************************************************************************

Asl_Dir:
	MENUITEM	FileRequester,Libraries_Dir
	MENUITEMEND	FontRequester,Libraries_Dir
Commodities_Dir:
	MENUITEM	NewBroker,Libraries_Dir
	MENUITEMEND	InputXpression,Libraries_Dir
ConfirRegs_Dir:
	MENUITEM	ExpansionRom,Libraries_Dir
	MENUITEM	ExpansionControl,Libraries_Dir
	MENUITEMEND	DiagArea,Libraries_Dir
ConfigVars_Dir:
	MENUITEM	ConfigDev,Libraries_Dir
	MENUITEMEND	CurrentBinding,Libraries_Dir
DiskFont_Dir:
	MENUITEM	FC,Libraries_Dir
	MENUITEM	TFC,Libraries_Dir
	MENUITEM	FCH,Libraries_Dir
	MENUITEM	DiskFontHeader,Libraries_Dir
	MENUITEM	AF,Libraries_Dir
	MENUITEM	TAF,Libraries_Dir
	MENUITEMEND	AFH,Libraries_Dir
ExpansionBase_Dir:
	MENUITEM	BootNode,Libraries_Dir
	MENUITEM	ExpansionBase,Libraries_Dir
GadTools_Dir:
	MENUITEM	NewGadget,Libraries_Dir
	MENUITEMEND	NewMenu,Libraries_Dir
IffParse_Dir:
	MENUITEM	IFFHandle,Libraries_Dir
	MENUITEM	IFFStreamCmd,Libraries_Dir
	MENUITEM	ContextNode,Libraries_Dir
	MENUITEM	LocalContextItem,Libraries_Dir
	MENUITEM	StoredProperty,Libraries_Dir
	MENUITEM	CollectionItem,Libraries_Dir
	MENUITEMEND	ClipboardHandle,Libraries_Dir
MathLibrary_Dir:
	MENUITEMEND	MathIEEEBase,Libraries_Dir
MathResource_Dir:
	MENUITEMEND	MathIEEEResourceResource,Libraries_Dir


****************************************************************************

Disk_Dir:
	MENUITEM	DISCRESOURCEUNIT,Resources_Dir
	MENUITEMEND	DISCRESOURCE,Resources_Dir
FileSysRes_Dir:
	MENUITEM	FileSysResource,Resources_Dir
	MENUITEMEND	FileSysEntry,Resources_Dir

****************************************************************************

;RexxIO_Dir:
;	MENUITEM	IoBuff,Rexx_Dir
;	MENUITEMEND	RexxMsgPort,Rexx_Dir
;RxsLib_Dir:
;	MENUITEMEND	RxsLib,Rexx_Dir
;Storage_Dir:
;	MENUITEM	NexxStr,Rexx_Dir
;	MENUITEM	RexxArg,Rexx_Dir
;	MENUITEM	RexxMsg,Rexx_Dir
;	MENUITEM	RexxRsrc,Rexx_Dir
;	MENUITEM	RexxTask,Rexx_Dir
;	MENUITEMEND	SrcNode,Rexx_Dir

****************************************************************************

Date_Dir:
	MENUITEMEND	CLOCKDATA,Utility_Dir
Hooks_Dir:
	MENUITEMEND	HOOK,Utility_Dir
TagItem_Dir:
	MENUITEMEND	TagItem,Utility_Dir

****************************************************************************

StartUp_Dir:
	MENUITEM	WBStartup,Workbench_Dir
	MENUITEMEND	WBArg,Workbench_Dir
Workbench_0_Dir:
	MENUITEM	DrawerData,Workbench_Dir
	MENUITEM	DiskObject,Workbench_Dir
	MENUITEM	FreeList,Workbench_Dir
	MENUITEM	AppMessage,Workbench_Dir
	MENUITEM	AppWindow,Workbench_Dir
	MENUITEM	AppIcon,Workbench_Dir
	MENUITEMEND	AppMenuItem,Workbench_Dir

****************************************************************************

InputPrefs_Dir:
	MENUITEMEND	InputPrefs,Prefs_Dir

LocalePrefs_Dir:
	MENUITEM	CountryPrefs,Prefs_Dir
	MENUITEMEND	LocalePrefs,Prefs_Dir
OverscanPrefs_Dir:
	MENUITEMEND	OverscanPrefs,Prefs_Dir
Paletterefs_Dir:
	MENUITEMEND	PalettePrefs,Prefs_Dir
PointerPrefs_Dir:
	MENUITEMEND	PointerPrefs,Prefs_Dir
PrefhdrPrefs_Dir:
	MENUITEMEND	PrefHeader,Prefs_Dir
PrintergfxPrefs_Dir:
	MENUITEMEND	PrinterGfxPrefs,Prefs_Dir
Printerps_Dir:
	MENUITEMEND	PrinterPSPrefs,Prefs_Dir
PrintertxtPrefs_Dir:
	MENUITEM	PrinterTxtPrefs,Prefs_Dir
	MENUITEMEND	PrinterUnitPrefs,Prefs_Dir
ScreenmodePrefs_Dir:
	MENUITEMEND	ScreenModePrefs,Prefs_Dir
SerialPrefs_Dir:
	MENUITEMEND	SerialPrefs,Prefs_Dir
SoundPrefs_Dir:
	MENUITEMEND	SoundPrefs,Prefs_Dir
WBPatternPrefs_Dir:
	MENUITEMEND	WBPatternPrefs,Prefs_Dir

****************************************************************************
Colorwheel_Dir:
	MENUITEM	ColorWheelHSB,Gadgets_Dir
	MENUITEMEND	ColorWheelRGB,Gadgets_Dir

Gradientslider_Dir:
Tapedeck_Dir:

****************************************************************************

Animationclass_Dir:
	MENUITEM	AnimHeader,Datatypes_Dir
	MENUITEMEND	adtFrame,Datatypes_Dir

Datatypes_0_Dir:
	MENUITEM	DataTypeHeader,Datatypes_Dir
	MENUITEM	DTHookContext,Datatypes_Dir
	MENUITEM	DataType,Datatypes_Dir
	MENUITEMEND	ToolNode,Datatypes_Dir

Datatypesclass_Dir:
	MENUITEM	DTSpecialInfo,Datatypes_Dir
	MENUITEM	DTMethod,Datatypes_Dir
	MENUITEM	FrameInfo,Datatypes_Dir
	MENUITEM	dtGeneral,Datatypes_Dir
	MENUITEM	dtSelect,Datatypes_Dir
	MENUITEM	dtFrameBox,Datatypes_Dir
	MENUITEM	dtGoto,Datatypes_Dir
	MENUITEM	dtTrigger,Datatypes_Dir
	MENUITEM	dtDraw,Datatypes_Dir
	MENUITEMEND	dtWrite,Datatypes_Dir


Pictureclass_Dir:
	MENUITEM	BitMapHeader,Datatypes_Dir
	MENUITEMEND	ColorRegister,Datatypes_Dir


Soundclass_Dir:
	MENUITEMEND	VoiceHeader,Datatypes_Dir


Textclass_Dir:
	MENUITEMEND	Line,Datatypes_Dir

****************************************************************************

Diskfont_0_Dir:
	MENUITEM	FC,Diskfont_Dir
	MENUITEM	TFC,Diskfont_Dir
	MENUITEM	FCH,Diskfont_Dir
	MENUITEM	DiskFontHeader,Diskfont_Dir
	MENUITEM	AF,Diskfont_Dir
	MENUITEM	TAF,Diskfont_Dir
	MENUITEMEND	AFH,Diskfont_Dir

Diskfonttag_Dir:


Glyph_Dir:
	MENUITEM	GlyphEngine,Diskfont_Dir
	MENUITEM	GlyphMap,Diskfont_Dir
	MENUITEMEND	GlyphWidthEntry,Diskfont_Dir

OTErrors_Dir:



****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************
****************************************************************************

	NOLIST

	incdir	"asm:"


	STRUCTURE	LN,0
	APTR		LN_SUCC,LN
	APTR		LN_PRED,LN
	UBYTE		LN_TYPE
	BYTE		LN_PRI
	CSTR		LN_NAME
	LABEL		LN_SIZE

	STRUCTURE LIB,LN_SIZE
	UBYTE		LIB_FLAGS
	UBYTE		LIB_pad
	UWORD		LIB_NEGSIZE
	UWORD		LIB_POSSIZE
	UWORD		LIB_VERSION
	UWORD		LIB_REVISION
	APTR		LIB_IDSTRING
	ULONG		LIB_SUM
	UWORD		LIB_OPENCNT
	LABEL		LIB_SIZE


	STRUCTURE	MLN,0
	APTR		MLN_SUCC,MLN
	APTR		MLN_PRED,MLN
	LABEL		MLN_SIZE

****************************************************************************
	STRUCTURE	LH,0
	APTR		LH_HEAD,MLN
	APTR		LH_TAIL,MLN
	APTR		LH_TAILPRED,MLN
	UBYTE		LH_TYPE
	UBYTE		LH_pad
	LABEL		LH_SIZE

	STRUCTURE	MLH,0
	APTR		MLH_HEAD,MLN
	APTR		MLH_TAIL,MLN
	APTR		MLH_TAILPRED,MLN
	LABEL		MLH_SIZE

****************************************************************************

	STRUCTURE	MN,LN
	APTR		MN_REPLYPORT,MP
	UWORD		MN_LENGTH
	LABEL		MN_SIZE

****************************************************************************

	STRUCTURE	TC_Struct,LN_SIZE
	UBYTE		TC_FLAGS
	UBYTE		TC_STATE
	BYTE		TC_IDNESTCNT
	BYTE		TC_TDNESTCNT
	ULONG		TC_SIGALLOC
	ULONG		TC_SIGWAIT
	ULONG		TC_SIGRECVD
	ULONG		TC_SIGEXCEPT
	APTR		tc_ETask
	APTR		TC_EXCEPTDATA
	APTR		TC_EXCEPTCODE
	APTR		TC_TRAPDATA
	APTR		TC_TRAPCODE
	APTR		TC_SPREG
	APTR		TC_SPLOWER
	APTR		TC_SPUPPER
	FPTR		TC_SWITCH
	FPTR		TC_LAUNCH
	STRUCT_STRUCT	TC_MEMENTRY,LH_SIZE
	APTR		TC_Userdata
	LABEL		TC_SIZE

****************************************************************************

	STRUCTURE	  MP,LN_SIZE
	UBYTE		MP_FLAGS
	UBYTE		MP_SIGBIT
	APTR		MP_SIGTASK,TC_Struct
	STRUCT_STRUCT	MP_MSGLIST,LH_SIZE
	LABEL		MP_SIZE

	STRUCTURE	SSR,MLN_SIZE
	APTR		SSR_WAITER
	LABEL		SSR_SIZE

****************************************************************************

	STRUCTURE	SS,LN_SIZE
	WORD		SS_NESTCOUNT
	STRUCT_STRUCT	SS_WAITQUEUE,MLH_SIZE
	STRUCT_STRUCT	SS_MULTIPLELINK,SSR_SIZE
	APTR		SS_OWNER
	WORD		SS_QUEUECOUNT
	LABEL		SS_SIZE

	STRUCTURE	SemaphoreMessage,MN_SIZE
	APTR		SSM_SEMAPHORE
	LABEL		SSM_SIZEOF

	STRUCTURE	SM,MP_SIZE
	WORD		SM_BIDS
	LABEL		SM_SIZE

****************************************************************************

DOS_DOS_I SET	1


	STRUCTURE	DateStamp,0 
	LONG		ds_Days
	LONG		ds_Minute
	LONG		ds_Tick
	LABEL		ds_SIZEOF

	STRUCTURE	FileInfoBlock,0
	LONG		fib_DiskKey
	LONG		fib_DirEntryType

	STRUCT		fib_FileName,108
	LONG		fib_Protection
	LONG		fib_EntryType
	LONG		fib_Size
	LONG		fib_NumBlocks
	STRUCT		fib_DateStamp,ds_SIZEOF
	STRUCT		fib_Comment,80

	UWORD		fib_OwnerUID
	UWORD		fib_OwnerGID

	STRUCT		fib_Reserved,32
	LABEL		fib_SIZEOF


	STRUCTURE	InfoData,0
	LONG		id_NumSoftErrors
	LONG		id_UnitNumber
	LONG		id_DiskState
	LONG		id_NumBlocks
	LONG		id_NumBlocksUsed
	LONG		id_BytesPerBlock
	LONG		id_DiskType
	BPTR		id_VolumeNode
	LONG		id_InUse
	LABEL		id_SIZEOF


	STRUCTURE_OFFSET	CommandLineInterface,0
	LONG		cli_Result2
	BSTR		cli_SetName
	BPTR		cli_CommandDir
	LONG		cli_ReturnCode
	BSTR		cli_CommandName
	LONG		cli_FailLevel
	BSTR		cli_Prompt
	BPTR		cli_StandardInput
	BPTR		cli_CurrentInput
	BSTR		cli_CommandFile
	LONG		cli_Interactive
	LONG		cli_Background
	BPTR		cli_CurrentOutput
	LONG		cli_DefaultStack
	BPTR		cli_StandardOutput
	BPTR		cli_Module
	LABEL		CommandLineInterface_SIZEOF

	STRUCTURE_OFFSET	Process,0
	STRUCT		pr_Task,TC_SIZE
	STRUCT		pr_MsgPort,MP_SIZE
	WORD		pr_Pad
	BPTR		pr_SegList
	LONG		pr_StackSize
	APTR		pr_GlobVec
	LONG		pr_TaskNum
	BPTR		pr_StackBase
	LONG		pr_Result2
	BPTR		pr_CurrentDir
	BPTR		pr_CIS
	BPTR		pr_COS
	APTR		pr_ConsoleTask
	APTR		pr_FileSystemTask
	BPTR		pr_CLI,CommandLineInterface
	APTR		pr_ReturnAddr
	APTR		pr_PktWait
	APTR		pr_WindowPtr
	BPTR		pr_HomeDir
	LONG		pr_Flags
	APTR		pr_ExitCode
	LONG		pr_ExitData
	APTR		pr_Arguments
	STRUCT		pr_LocalVars,MLH_SIZE
	APTR		pr_ShellPrivate
	BPTR		pr_CES
	LABEL		pr_SIZEOF


****************************************************************************
	STRUCTURE	BitMap,0
	WORD		bm_BytesPerRow
	WORD		bm_Rows
	BYTE		bm_Flags
	BYTE		bm_Depth
	WORD		bm_Pad
	STRUCT		bm_Planes,8*4
	LABEL		bm_SIZEOF

	STRUCTURE	Rectangle,0
	WORD		ra_MinX
	WORD		ra_MinY
	WORD		ra_MaxX
	WORD		ra_MaxY
	LABEL		ra_SIZEOF

	STRUCTURE	Rect32,0
	LONG		r32_MinX
	LONG		r32_MinY
	LONG		r32_MaxX
	LONG		r32_MaxY
	LABEL		r32_SIZEOF

	STRUCTURE	tPoint,0
	WORD		tpt_x
	WORD		tpt_y
	LABEL		tpt_SIZEOF

****************************************************************************

	STRUCTURE_OFFSET	XLN,0
	APTR		XLN_SUCC
	APTR		XLN_PRED
	UBYTE		XLN_TYPE
	BYTE		XLN_PRI
	APTR		XLN_NAME
	UBYTE		XLN_SUBSYSTEM
	UBYTE		XLN_SUBTYPE
	LONG		XLN_LIBRARY
	LONG		XLN_INIT
	LABEL		XLN_SIZE

****************************************************************************

	STRUCTURE	AnalogSignalInterval,0
	UWORD		asi_Start
	UWORD		asi_Stop
	LABEL		asi_SIZEOF

	STRUCTURE	SpecialMonitor,XLN_SIZE
	UWORD		spm_Flags
	APTR		spm_do_monitor
	APTR		spm_reserved1
	APTR		spm_reserved2
	APTR		spm_reserved3
	STRUCT		spm_hblank,asi_SIZEOF
	STRUCT		spm_vblank,asi_SIZEOF
	STRUCT		spm_hsync,asi_SIZEOF
	STRUCT		spm_vsync,asi_SIZEOF
	LABEL		spm_SIZEOF

	STRUCTURE	MonitorSpec,XLN_SIZE
	UWORD		ms_Flags
	LONG		ms_ratioh
	LONG		ms_ratiov
	UWORD		ms_total_rows
	UWORD		ms_total_colorclocks
	UWORD		ms_DeniseMaxDisplayColumn
	UWORD		ms_BeamCon0
	UWORD		ms_min_row
	APTR		ms_Special
	UWORD		ms_OpenCount
	APTR		ms_transform
	APTR		ms_translate
	APTR		ms_scale
	UWORD		ms_xoffset
	UWORD		ms_yoffset
	STRUCT_STRUCT	ms_LegalView,ra_SIZEOF
	APTR		ms_maxoscan
	APTR		ms_videoscan
	UWORD		ms_DeniseMinDisplayColumn
	ULONG		ms_DisplayCompatible
	STRUCT_STRUCT	ms_DisplayInfoDataBase,LH_SIZE
	STRUCT_STRUCT	ms_DIDBSemaphore,SS_SIZE
	ULONG		ms_MrgCop
	ULONG		ms_LoadView
	ULONG		ms_KillView
	LABEL		ms_SIZEOF

****************************************************************************

	include	exec/ables.i
	include	exec/alerts.i
	include	exec/devices.i
	include	exec/errors.i
	include	exec/exec.i
	include	exec/execbase.i
	include	exec/initializers.i
	include	exec/interrupts.i
	include	exec/io.i
	include	exec/libraries.i
	include	exec/lists.i
	include	exec/macros.i
	include	exec/memory.i
	include	exec/nodes.i
	include	exec/ports.i
	include	exec/resident.i
	include	exec/semaphores.i
	include	exec/strings.i
	include	exec/tasks.i
	include	exec/types.i                          

	include	devices/audio.i
	include	devices/bootblock.i
	include	devices/clipboard.i
	include	devices/console.i
	include	devices/conunit.i
	include	devices/gameport.i
	include	devices/hardblocks.i
	include	devices/input.i
	include	devices/inputevent.i
	include	devices/keyboard.i
	include	devices/keymap.i
	include	devices/narrator.i
	include	devices/parallel.i
	include	devices/printer.i
	include	devices/prtbase.i
	include	devices/prtgfx.i
	include	devices/scsidisk.i
	include	devices/serial.i
	include	devices/timer.i
	include	devices/trackdisk.i

	include	resources/battclock.i
	include	resources/battmem.i
	include	resources/battmembitsamiga.i
	include	resources/battmembitsamix.i
	include	resources/battmembitsshared.i
	include	resources/card.i
	include	resources/cia.i
	include	resources/ciabase.i
	include	resources/disk.i
	include	resources/filesysres.i
	include	resources/mathresource.i
	include	resources/misc.i
	include	resources/potgo.i

	include	dos/datetime.i
	include	dos/dos.i
	include	dos/dosasl.i
	include	dos/dosextens.i
	include	dos/doshunks.i
	include	dos/dostags.i
	include	dos/exall.i
	include	dos/filehandler.i
	include	dos/notify.i
	include	dos/rdargs.i
	include	dos/record.i
	include	dos/stdio.i
	include	dos/var.i                            

	include	libraries/amigaguide.i
	include	libraries/asl.i
	include	libraries/commodities.i
	include	libraries/configregs.i
	include	libraries/configvars.i
	include	libraries/diskfont.i
	include	libraries/dos.i
	include	libraries/dosextens.i
	include	libraries/expansion.i
	include	libraries/expansionbase.i
	include	libraries/filehandler.i
	include	libraries/gadtools.i
	include	libraries/iffparse.i
	include	libraries/locale.i
	include	libraries/mathlibrary.i
	include	libraries/mathresource.i
	include	libraries/translator.i

	include	utility/date.i
	include	utility/hooks.i
	include	utility/name.i
	include	utility/pack.i
	include	utility/tagitem.i
	include	utility/utility.i

	include	graphics/clip.i
	include	graphics/coerce.i
	include	graphics/copper.i
	include	graphics/display.i
	include	graphics/displayinfo.i
	include	graphics/gels.i
	include	graphics/gfx.i
	include	graphics/gfxbase.i
	include	graphics/gfxnodes.i
	include	graphics/layers.i
	include	graphics/modeid.i
	include	graphics/monitor.i
	include	graphics/rastport.i
	include	graphics/regions.i
	include	graphics/rpattr.i
	include	graphics/scale.i
	include	graphics/sprite.i
	include	graphics/text.i
	include	graphics/videocontrol.i
	include	graphics/view.i                           

	include	diskfont/diskfont.i
	include	diskfont/diskfonttag.i
	include	diskfont/glyph.i
	include	diskfont/oterrors.i

	include	intuition/cghooks.i
	include	intuition/classes.i
	include	intuition/classusr.i
	include	intuition/gadgetclass.i
	include	intuition/icclass.i
	include	intuition/imageclass.i
	include	intuition/intuition.i
	include	intuition/intuitionbase.i
	include	intuition/iobsolete.i
	include	intuition/pointerclass.i
	include	intuition/preferences.i
	include	intuition/screens.i
	include	intuition/sghooks.i                        

	include	gadgets/colorwheel.i
	include	gadgets/gradientslider.i

	include	datatypes/animationclass.i
	include	datatypes/datatypes.i
	include	datatypes/datatypesclass.i
	include	datatypes/pictureclass.i
	include	datatypes/soundclass.i
	include	datatypes/textclass.i

	include	workbench/icon.i
	include	workbench/startup.i
	include	workbench/workbench.i                      

	include	prefs/font.i
	include	prefs/icontrol.i
	include	prefs/input.i
	include	prefs/locale.i
	include	prefs/overscan.i
	include	prefs/palette.i
	include	prefs/pointer.i
	include	prefs/prefhdr.i
	include	prefs/printergfx.i
	include	prefs/printerps.i
	include	prefs/printertxt.i
	include	prefs/screenmode.i
	include	prefs/serial.i
	include	prefs/sound.i
	include	prefs/wbpattern.i


;	include	rexx/errors.i
;	include	rexx/rexxio.i
;	include	rexx/rxslib.i
;	include	rexx/storage.i


	include	hardware/adkbits.i
	include	hardware/blit.i
	include	hardware/cia.i
	include	hardware/custom.i
	include	hardware/dmabits.i
	include	hardware/intbits.i

	LIST

				

	NOLIST
