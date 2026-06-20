;---------------T-------T---------------T-----------------------------------T
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; This source is © Copyright 1992-1995, Jesper Skov.
; Read "GhostRiderSource.ReadMe" for a description of what you may do with
; this source!
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; Please do not abuse! Thanks. Jesper
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;----------------------------------------------------------------------------;
;- Program Title	: 		-;
;- Copyrigth Status	: PD, (c) Copyrigth Jesper Skov	-;
;- Programmed by	: Jesper Skov		-;
;- Version.Revision	: 38.8		-;
;----------------------------------------------------------------------------;
;- 		       Program History	-;
;----------------------------------------------------------------------------;
;- 191093.004	Generated new source. Now using the GTB glue to open libs.
;-       .007	Ready to ship.
;- 291293.048	Fully functional, shipped with GR V0.2E
;- 200194.051	Added RAMBank and LongDisassembly prefs
;- 310194.061	Added Peeker and Paste prefs.
;-	Added GRPref ID and revision#.
;-	Added Default-button to main
;-       .062	Added Joker/NonASCII support !?!
;-       .063	Corrected TAB-cycle order of screen/memory preferences.
;- 010294.064.5	Added PAL/NTSC flag.
;-       .065	Now ENVARC:GR.Prefs is loaded at entry.
;- 010894.085	Added new rev 8 prefs.
;-	Added GetString/SetString, act/inact hex and alterable cycle
;-       .086   Fixed last pref default settings and the peeker height check.
;-       .087	Fixed loading of older pref files.
;-       .089	Fixed close gadgets.
;-       .090	Now diwstop is updated when diwstrt is changed.
;-       .091.6	Removed close gadget code.
;- 100894.092.7	Removed ptr color0
;- 080994.099.8	Added disk verify and ModifyGR. Default pref path is now S:
;-----------------------------------------------------------------------------;

Rev=9
RevText	Macro
	dc.b	'9'
	Endm

VERSIONSTRING	Macro
	dc.b	'8 (08.09.94)'
	Endm

	IncDir	Include:

                include libraryOffsets/exec_lib.i
                include exec/execbase.i
                include exec/exec.i

                include libraryOffsets/intuition_lib.i

                include libraryOffsets/dos_lib.i
                include dos/dos.i
                include dos/dosextens.i

                include libraryOffsets/graphics_lib.i

                include libraryOffsets/asl_lib.i
                include libraries/asl.i

                include libraryOffsets/gadtools_lib.i

Push            macro                           ;push all or selected regs
                ifc     all,\1                  ;on the stack
                movem.l d0-a6,-(a7)
                else
                movem.l \1,-(a7)
                endc
                endm

Pull            macro                           ;pull all or selected regs
                ifc     all,\1                  ;from the stack
                movem.l (a7)+,d0-a6
                else
                movem.l (a7)+,\1
                endc
                endm

CallD           MACRO
                MOVE.L  _DOSBase(b),A6
                JSR     _LVO\1(A6)
                ENDM
CallI           MACRO
                MOVE.L  _IntuitionBase(b),A6    ;CALLINT with PC relative
                JSR     _LVO\1(A6)
                ENDM
CallG           MACRO
                MOVE.L  _GraphicsBase(b),A6
                JSR     _LVO\1(A6)
                ENDM
CallA           macro
                move.l  _ASLBase(b),a6
                jsr     _LVO\1(a6)
                endm
CallE           MACRO
                MOVE.L  $4.W,A6
                JSR     _LVO\1(A6)
                ENDM

Call            macro
                jsr     _LVO\1(a6)
                endm


IntName                 MACRO
                        DC.B    'intuition.library',0
                        ENDM

DOSName                 MACRO
                        DC.B    'dos.library',0
                        ENDM

                IFND GfxName
GfxName         MACRO
                        DC.B    'graphics.library',0
                        ENDM
                ENDC

                IFND GadName
GadName                 MACRO
                        DC.B    'gadtools.library',0
                        ENDM
                ENDC

                IFND ASLName
ASLName                 MACRO
                        DC.B    'asl.library',0
                        ENDM
                ENDC


	Section Code,Code

	jumpptr	s

	include	misc/WBeasystart.i

b	equr	a5

s	lea	B,b
	bsr.w	OpenGTBLibs
	bne.w	LibOpenError

	lea	ASLNam(pc),a1
	Call	OldOpenLibrary
	move.l	d0,_ASLBase(b)
	beq.w	NoASL

	lea	DOSNam(pc),a1
	Call	OldOpenLibrary
	move.l	d0,_DOSBase(b)
	beq.w	NoDOS

	lea	zIntNam(pc),a1
	Call	OldOpenLibrary
	move.l	d0,_zIntuitionBase(b)
	beq.w	NoInt

	bsr.w	SetupScreen
	tst.l	d0
	bne.w	ProgramExit

	move.l	#ASL_FileRequest,d0
	sub.l	a0,a0
	CallA	AllocAslRequest
	move.l	d0,FileReq(b)
	beq.w	ProgramExit	;skip if allocation failed

	bsr.w	SetDefaultPrefs

	move.l	#'GRPF',IDString(b)
	move.w	#Rev,RevisionNumber(b)

	move.l	#DefaultDir,d1	;load user-prefs at startup
	bsr.w	EntryReadDefault

	st.b	InitPath(b)

MainLoopInit	bsr.w	OpenGhost_Rider_PrefsWindow
	bne.w	WindowError

	move.l	Ghost_Rider_PrefsWnd(pc),a0;get userport
	move.l	wd_UserPort(a0),WindowPort(b)

MainLoopPre	clr.b	ExitFlag(b)	;will be used for free library
	clr.b	Selected(b)

MainLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	Exit

	moveq	#0,d0
	move.b	Selected(b),d0
	bne.w	OpenSubWindow

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	MainLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	Ghost_Rider_PrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
	bsr.w	Ghost_Rider_PrefsRender
	move.l	Ghost_Rider_PrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_MainCancel,d6
	bne.b	.CheckCancel
.flagexit	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.CheckCancel	cmp.w	#GD_MainLoad,d6
	bne.b	.Load
	bsr.w	ReadNewPrefs
	bra.b	.MsgLoop
.Load
	cmp.w	#GD_MainSave,d6
	bne.b	.Save
	bsr.w	SavePrefs
	bra.w	.MsgLoop

.Save	cmp.w	#GD_DefaultPrefs,d6
	bne.b	.Modify
	bsr.w	SetUpDefaultPrefs
	bra.w	.MsgLoop

.Modify	cmp.w	#GD_ModifyGR,d6
	bne.b	.SubPrefs
	bsr.w	ModifyGR
	bra.w	.MsgLoop

.SubPrefs	move.b	#1,Selected(b)
	cmp.w	#GD_MainScreen,d6
	beq.w	.MsgLoop
	move.b	#2,Selected(b)
	cmp.w	#GD_MainDisk,d6
	beq.w	.MsgLoop
	move.b	#3,Selected(b)
	cmp.w	#GD_MainInput,d6
	beq.w	.MsgLoop
	move.b	#4,Selected(b)
	cmp.w	#GD_MainDisassem,d6
	beq.w	.MsgLoop
	move.b	#5,Selected(b)
	cmp.w	#GD_MainMemory,d6
	beq.w	.MsgLoop
	move.b	#6,Selected(b)
	cmp.w	#GD_MainStartup,d6
	beq.w	.MsgLoop
	move.b	#7,Selected(b)
	cmp.w	#GD_MainMisc,d6
	beq.w	.MsgLoop
	clr.b	Selected(b)
	bra.w	.MsgLoop

Exit	tst.b	PrefsModified(b)
	beq.w	OKExit

	lea	QuitBodyText(pc),a1
	lea	QuitButtText(pc),a2
	bsr.w	DoEZRequest

	tst.w	d0
	bne.b	OKExit
	bra.w	MainLoopPre

QuitBodyText	dc.b	'Preferences modified. Really quit?',0
	even

OKExit
	bsr.w	CloseGhost_Rider_PrefsWindow
WindowError

	move.l	FileReq(b),a0	;Free filerequester
	CallA	FreeAslRequest

ProgramExit	bsr.w	CloseDownScreen



	move.l	_zIntuitionBase(b),a1
	CallE	CloseLibrary

NoInt
	move.l	_DOSBase(b),a1
	CallE	CloseLibrary

NoDOS
	move.l	_ASLBase(b),a1
	CallE	CloseLibrary

NoASL
LibOpenError	bsr.w	CloseGTBLibs
	moveq	#0,d0
	rts

;---- Ask if needed b'fore setting default
SetUpDefaultPrefs
	tst.b	PrefsModified(b)
	beq.b	.OKZ

	lea	DefBodyText(pc),a1
	lea	DefButtText(pc),a2
	bsr.w	DoEZRequest

	tst.w	d0
	bne.b	.OKZ
	rts

.OKZ

;---- Init default settings
SetDefaultPrefs
	st.b	InitPath(b)
	REM	;Obsolet when using ASL
	lea	TagBuffer(b),a0	;set default dir to ENVARC:
	move.l	a0,a1
	move.l	#RTFI_Dir,(a1)+
	lea	DefaultDir(pc),a2
	move.l	a2,(a1)+
	clr.l	(a1)
	move.l	FileReq(b),a1
	Call	rtChangeReqAttrA
	EREM

	lea	Name(b),a1	;set default filename
	lea	DefaultName(pc),a0
.copyname	move.b	(a0)+,(a1)+
	bne.b	.copyname

ZDefaultPrefs	lea	DefaultPrefs(pc),a0;setup defaultprefs
	lea	PrefTable(b),a1
	move.w	#pr_SizeOf-1,d0
.setdefault	move.b	(a0)+,(a1)+
	dbra	d0,.setdefault

	clr.b	PrefsModified(b)
	rts

	dc.b	0,'$VER: GRPreferenceEditor 38.'
	VERSIONSTRING
	dc.b	' Copyright © 1993, 1994 Jesper Skov.',0
	even

;---- Call pref-handler
OpenSubWindow	move.w	d0,-(a7)
	bsr.w	CloseGhost_Rider_PrefsWindow

	clr.b	Cancelled(b)
	bsr.w	BackupPrefs	;get a backup of prefs before opening
			;new window
	move.w	(a7)+,d0
	subq.b	#1,d0
	asl.w	#2,d0
	jsr	BranchTable(pc,d0.w)

	tst.b	Cancelled(b)
	beq.b	.acceptdata
	bsr.w	RestorePrefs	;restore old prefs if window was
			;cancelled	
.acceptdata

	lea	PrefTable(b),a0
	lea	PrefTableBackup(b),a1
	move.w	#pr_SizeOf-1,d0
.checkchanges	cmpm.b	(a0)+,(a1)+
	beq.b	.eq
	st.b	PrefsModified(b)
.eq	dbra	d0,.checkchanges

	bra.w	MainLoopInit

BranchTable	bra.w	OpenScreenPrefs	
	bra.w	OpenDiskPrefs
	bra.w	OpenInputPrefs
	bra.w	OpenDisassemPrefs
	bra.w	OpenMemoryPrefs
	bra.w	OpenStartupPrefs
	bra.w	OpenMiscPrefs

;-----------------------------------------------------------------------------;
;-		         Screen Preferences	-;
;-----------------------------------------------------------------------------;
OpenScreenPrefs	bsr.w	OpenScreenPrefsWindow
	bne.w	.WindowError

	move.l	ScreenPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	ScreenPrefsGadgets,a4

	move.l	_GadToolsBase(pc),a6

	addq.l	#8,a4	;skip OK/CANCEL gadgets

	lea	pr_Monitors+PrefTable(b),a0
	move.l	a0,d1
	lea	CycleNameList(b),a3
	move.l	a3,a0
	moveq	#5-1,d0	;set 5 monitor names
.SetName	move.l	d1,(a0)+
	add.l	#mon_SizeOf,d1
	dbra	d0,.SetName
	clr.l	(a0)	;end list with NULL

	moveq	#0,d0
	move.b	pr_ScreenMode+PrefTable(b),d0
			;a3 is also parsed
	move.l	(a4)+,a0
	bsr.w	SetCycleD

	addq.w	#4,a4		;edit screen mode (button)

	move.l	(a4)+,a0
	moveq	#3,d1
	move.w	pr_ScreenColor0+PrefTable(b),d0
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#3,d1
	move.w	pr_ScreenColor1+PrefTable(b),d0
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#3,d1
	move.w	pr_HeaderColor0+PrefTable(b),d0
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#3,d1
	move.w	pr_HeaderColor1+PrefTable(b),d0
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#3,d1
	move.w	pr_CursorColor+PrefTable(b),d0
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#3,d1
	move.w	pr_ColorP1+PrefTable(b),d0
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#3,d1
	move.w	pr_ColorP2+PrefTable(b),d0
	bsr.w	SetHexInString



	clr.b	ExitFlag(b)	;will be used for free library
	clr.b	SubWindowFlag(b)

.ScreenLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	tst.b	SubWindowFlag(b)
	bne.w	.DoSubWindow

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.ScreenLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	ScreenPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	ScreenPrefsRender
	move.l	ScreenPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_ScreenCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.CheckCancel	cmp.w	#GD_ScreenOK,d6
	beq.b	.flagexit

	pea	.MsgLoop(pc)
	move.l	ScreenPrefsWnd(pc),a1;get userport

	lea	pr_HeaderColor0+PrefTable(b),a2
	cmp.w	#GD_HeaderColor,d6
	bne.b	.checkheadcol
.colormain	moveq	#3,d2
	bsr.w	GetHexInput
	bne.w	.fail
	and.w	#$fff,d0
	move.w	d0,(a2)
.fail	rts

.checkheadcol	lea	pr_HeaderColor1+PrefTable(b),a2
	cmp.w	#GD_HeaderTColor,d6
	beq.b	.colormain
 
	lea	pr_ScreenColor0+PrefTable(b),a2
	cmp.w	#GD_ScreenColor,d6
	beq.b	.colormain

	lea	pr_ScreenColor1+PrefTable(b),a2
	cmp.w	#GD_TextColor,d6
	beq.b	.colormain

	lea	pr_ColorP1+PrefTable(b),a2
	cmp.w	#GD_PointerColor1,d6
	beq.b	.colormain

	lea	pr_ColorP2+PrefTable(b),a2
	cmp.w	#GD_PointerColor2,d6
	beq.b	.colormain

	lea	pr_CursorColor+PrefTable(b),a2
	cmp.w	#GD_CursorColor,d6
	beq.b	.colormain

	lea	pr_ScreenMode+PrefTable(b),a1
	cmp.w	#GD_ScreenMode,d6
	beq.w	GetCycle


	cmp.w	#GD_EditScreenMode,d6
	bne.b	.NotEdit
	st.b	SubWindowFlag(b)


.NotEdit	rts

.Exit	bsr.w	CloseScreenPrefsWindow

.WindowError	rts


;----- Do ScreenMode Window
.DoSubWindow	clr.b	Cancelled(b)

;-- Backup area
	moveq	#0,d0
	move.b	pr_ScreenMode+PrefTable(b),d0
	mulu	#mon_SizeOf,d0
	lea	pr_Monitors+PrefTable(b),a0
	add.w	d0,a0
	move.l	a0,SelectedMonitor(b)
	lea	MonitorBackup(b),a1
	moveq	#mon_SizeOf/2-1,d0
.BackupMon	move.w	(a0)+,(a1)+
	dbra	d0,.BackupMon

;-- Close current
	bsr.w	CloseScreenPrefsWindow

;-- Call sub
	bsr.w	OpenScreenMode

	tst.b	Cancelled(b)
	beq.b	.dataok

;-- Restore if cancel
	move.l	SelectedMonitor(b),a0
	lea	MonitorBackup(b),a1
	moveq	#mon_SizeOf/2-1,d0
.RestoreMon	move.w	(a1)+,(a0)+
	dbra	d0,.RestoreMon

.dataok
;---- Check peeker height
	moveq	#0,d0	;make sure peekerlines are OK!
	move.w	pr_PeekerLines+PrefTable(b),d0
	addq.w	#1,d0

	lea	pr_Monitors+PrefTable(b),a0
	moveq	#0,d1
	move.b	pr_ScreenMode+PrefTable(b),d1
	mulu	#mon_SizeOf,d1
	add.w	d1,a0
	moveq	#0,d1
	move.b	mon_textlines(a0),d1
	add.w	d1,d1
	cmp.w	d1,d0
	bmi.b	.bigger
	move.w	d1,d0	;set stat=max if old stat>max
.bigger	cmp.w	#100,d0
	blt.b	.ok
	move.w	#100,d0
.ok
	subq.w	#1,d0
	move.w	d0,pr_PeekerLines+PrefTable(b)


	clr.b	Cancelled(b)

;-- re-open previous
	bra.w	OpenScreenPrefs


;-----------------------------------------------------------------------------;
;-		    Screen Mode Definitions	-;
;-----------------------------------------------------------------------------;
OpenScreenMode	bsr.w	OpenScreen_ModeWindow
	bne.w	.WindowError

.NewMode	move.l	Screen_ModeWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	Screen_ModeGadgets,a4

	move.l	_GadToolsBase(pc),a6

	addq.l	#8,a4	;skip OK/CANCEL gadgets


;mon_Name=	0
;mon_textlines=	$20
;mon_custom=	$21
;mon_diwstrt=	$22
;mon_diwstop=	$24
;mon_ddfstrt=	$26
;mon_ddfstop=	$28
;mon_beamcon0=	$2a
;mon_bplcon0=	$2c
;mon_hbstrt=	$2e
;mon_hbstop=	$30
;mon_hsstrt=	$32
;mon_hsstop=	$34
;mon_htotal=	$36
;mon_hcenter=	$38
;mon_vbstrt=	$3a
;mon_vbstop=	$3c
;mon_vsstrt=	$3e
;mon_vsstop=	$40
;mon_vtotal=	$42
;mon_diwhigh=	$44
;mon_SysView=	$46
;mon_Filler=	$47	;!Free!
;mon_SizeOf=	$48


	move.l	SelectedMonitor(b),a0
	move.l	a0,-(a7)	;utilize stack!
	moveq	#0,d0
	move.b	mon_textlines(a0),d0
	move.l	(a4)+,a0
	bsr.w	SetSlider

	move.l	(a7),a0
	moveq	#0,d0
	move.b	mon_custom(a0),d0
	move.l	(a4)+,a0
	bsr.w	SetCheckBox

	moveq	#6-1,d2	;set diwstrt-beamcon0
	move.l	(a7),a2
	add.w	#mon_diwstrt,a2
	moveq	#4,d1
.SetBaseRegs	move.w	(a2)+,d0
	move.l	(a4)+,a0

	Push	d1/d2/a2
	bsr.w	SetHexInString
	Pull	d1/d2/a2

	dbra	d2,.SetBaseRegs

	move.l	(a7),a0
	tst.b	mon_custom(a0)
	beq.b	.SetDisabled

	moveq	#12-1,d2	;set hbstrt-diwhigh
.SetCustomRegs	move.w	(a2)+,d0
	move.l	(a4)+,a0

	Push	d1/d2/a2
	bsr.w	SetHexInString
	Pull	d1/d2/a2

	dbra	d2,.SetCustomRegs
	bra.b	.WasSet


.SetDisabled	moveq	#12-1,d2	;set hbstrt-diwhigh (disabled)
.SetCustomRegsD	move.w	(a2)+,d0
	move.l	(a4)+,a0

	Push	d1/d2/a2
	bsr.w	SetHexInStringD
	Pull	d1/d2/a2

	dbra	d2,.SetCustomRegsD

.WasSet	move.l	(a7),a0
	moveq	#0,d0
	move.b	mon_SysView(a0),d0
	move.l	(a4)+,a0
	bsr.w	SetCheckBox

	move.l	(a7)+,a3
	move.l	(a4),a0
	bsr.w	SetString

	clr.b	ExitFlag(b)	;will be used for free library
	clr.b	NewModeFlag(b)

.ScreenMLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	tst.b	NewModeFlag(b)
	bne.w	.NewMode

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.ScreenMLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	Screen_ModeWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	Screen_ModeRender
	move.l	Screen_ModeWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_ScreenModeCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.CheckCancel	cmp.w	#GD_ScreenModeOK,d6
	beq.b	.flagexit

	pea	.MsgLoop(pc)
	move.l	ScreenPrefsWnd(pc),a1;get userport

	move.l	SelectedMonitor(b),a3

	lea	mon_ddfstrt(a3),a2
	cmp.w	#GD_ddfstrt,d6
	bne.b	.check

.hexvaluemain	moveq	#4,d2
	bsr.w	GetHexInput
	bne.b	.fail
	move.w	d0,(a2)
.fail	rts

.check	lea	mon_ddfstop(a3),a2
	cmp.w	#GD_ddfstop,d6
	beq.b	.hexvaluemain

	lea	mon_beamcon0(a3),a2
	cmp.w	#GD_beamcon0,d6
	beq.b	.hexvaluemain

	lea	mon_bplcon0(a3),a2
	cmp.w	#GD_bplcon0,d6
	beq.b	.hexvaluemain

	lea	mon_hbstrt(a3),a2
	cmp.w	#GD_hbstrt,d6
	beq.b	.hexvaluemain

	lea	mon_hbstop(a3),a2
	cmp.w	#GD_hbstop,d6
	beq.b	.hexvaluemain

	lea	mon_hsstrt(a3),a2
	cmp.w	#GD_hsstrt,d6
	beq.b	.hexvaluemain

	lea	mon_hsstop(a3),a2
	cmp.w	#GD_hsstop,d6
	beq.b	.hexvaluemain

	lea	mon_vbstrt(a3),a2
	cmp.w	#GD_vbstrt,d6
	beq.b	.hexvaluemain

	lea	mon_vbstop(a3),a2
	cmp.w	#GD_vbstop,d6
	beq.b	.hexvaluemain

	lea	mon_vsstrt(a3),a2
	cmp.w	#GD_vsstrt,d6
	beq.b	.hexvaluemain

	lea	mon_vsstop(a3),a2
	cmp.w	#GD_vsstop,d6
	beq.b	.hexvaluemain


	lea	mon_htotal(a3),a2
	cmp.w	#GD_htotal,d6
	beq.w	.hexvaluemain

	lea	mon_hcenter(a3),a2
	cmp.w	#GD_hcenter,d6
	beq.w	.hexvaluemain

	lea	mon_vtotal(a3),a2
	cmp.w	#GD_vtotal,d6
	beq.w	.hexvaluemain

	lea	mon_diwhigh(a3),a2
	cmp.w	#GD_diwhigh,d6
	beq.w	.hexvaluemain

	lea	mon_SysView(a3),a1
	cmp.w	#GD_SystemView,d6
	beq.w	GetCheckBox

	cmp.w	#GD_CustomDisplay,d6
	bne.b	.ChangeCustomState
	lea	mon_custom(a3),a1
	st.b	NewModeFlag(b)
	bra.w	GetCheckBox

.ChangeCustomState
	
	lea	mon_textlines(a3),a1
	cmp.w	#GD_TextLines,d6
	bne.w	.GetTextLines
	bsr.w	GetSlider

.Setdiwstop	move.l	SelectedMonitor(b),a3
	moveq	#0,d0
	move.b	mon_textlines(a3),d0
	asl.w	#3,d0
	moveq	#11,d1
	btst	#2,mon_bplcon0+1(a3)
	beq.b	.noLace
	lsr.w	#1,d0
	moveq	#6,d1
.noLace	add.w	d1,d0
	asl.w	#8,d0

	move.w	mon_diwstrt(a3),d1;diwstart
	and.w	#$fc00,d1
	sub.w	#$0100,d1
	and.w	#$ff00,d1
	add.w	d1,d0
	move.b	mon_diwstop+1(a3),d0
	move.w	d0,mon_diwstop(a3)
	
	lea	Screen_ModeGadgets+$14,a4
.Setdiw	move.l	(a4),a0
	moveq	#4,d1
	move.l	Screen_ModeWnd(pc),a1
	bra.w	SetHexInString

.GetTextLines
	move.l	Screen_ModeWnd(pc),a1
	cmp.w	#GD_diwstop,d6
	bne.b	.Getdiwstop
	lea	mon_diwstop(a3),a2

	moveq	#4,d2
	bsr.w	GetHexInput
	bne.w	.fail
	move.w	d0,(a2)

	bra.b	.Setdiwstop


.Getdiwstop	lea	mon_diwstrt(a3),a2
	cmp.w	#GD_diwstrt,d6
	bne.b	.Getdiwstrt

	moveq	#4,d2
	bsr.w	GetHexInput
	bne.w	.fail
	and.w	#$fcff,d0
	move.w	d0,(a2)
	lea	Screen_ModeGadgets+$10,a4
	bsr.b	.Setdiw
	lea	mon_diwstop(a3),a2
	move.w	(a2),d0
	bra.w	.Setdiwstop

.Getdiwstrt			;a3 is text ptr
	cmp.w	#GD_ModeName,d6
	beq.w	GetString

	rts

.Exit	bsr.w	CloseScreen_ModeWindow
.WindowError	rts

;-----------------------------------------------------------------------------;
;-		        Disk Preferences	-;
;-----------------------------------------------------------------------------;
OpenDiskPrefs	bsr.w	OpenDiskPrefsWindow
	bne.w	.WindowError

	move.l	DiskPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	DiskPrefsGadgets,a4

	addq.l	#8,a4

	move.l	_GadToolsBase(pc),a6

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_SelectedDrive+PrefTable(b),d0
	bsr.w	SetCycle

	move.l	(a4)+,a0
	move.w	pr_DiskSync+PrefTable(b),d0
	moveq	#4,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.w	pr_DDTrackLen+PrefTable(b),d0
	moveq	#4,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.w	pr_HDTrackLen+PrefTable(b),d0
	moveq	#4,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_DiskRetries+PrefTable(b),d0
	subq.b	#1,d0
	bsr.w	SetSlider

	move.l	(a4)+,a0
	move.b	pr_BitMapRes+PrefTable(b),d0
	bsr.w	SetLetterInString

	move.l	(a4)+,a0
	move.b	pr_BitMapFree+PrefTable(b),d0
	bsr.w	SetLetterInString

	move.l	(a4)+,a0
	move.b	pr_BitMapUsed+PrefTable(b),d0
	bsr.w	SetLetterInString

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_DiskVerify+PrefTable(b),d0
	bsr.w	SetCheckBox

	clr.b	ExitFlag(b)	;will be used for free library

.DiskLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.DiskLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	DiskPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	DiskPrefsRender
	move.l	DiskPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	pea	.MsgLoop(pc)

	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.nop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?

	cmp.w	#GD_DiskCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
.nop	rts

.CheckCancel	cmp.w	#GD_DiskOK,d6
	beq.b	.flagexit

	move.l	DiskPrefsWnd(pc),a1

	lea	pr_DiskSync+PrefTable(b),a2
	cmp.w	#GD_DiskSync,d6
	bne.b	.check
.hexvaluemain	moveq	#4,d2
	bsr.w	GetHexInput
	bne.w	.fail
	move.w	d0,(a2)
.fail	rts

.check	lea	pr_DDTrackLen+PrefTable(b),a2
	cmp.w	#GD_DTrackLength,d6
	beq.b	.hexvaluemain

	lea	pr_HDTrackLen+PrefTable(b),a2
	cmp.w	#GD_HTrackLength,d6
	beq.b	.hexvaluemain

	lea	pr_DiskRetries+PrefTable(b),a1
	cmp.w	#GD_Retries,d6
	beq.w	GetSlider

	lea	pr_SelectedDrive+PrefTable(b),a1
	cmp.w	#GD_DefaultDrive,d6
	beq.w	GetCycle

	lea	pr_BitMapRes+PrefTable(b),a1
	cmp.w	#GD_BMReserved,d6
	beq.w	GetSingleLetter

	lea	pr_BitMapFree+PrefTable(b),a1
	cmp.w	#GD_BMFree,d6
	beq.w	GetSingleLetter

	lea	pr_BitMapUsed+PrefTable(b),a1
	cmp.w	#GD_BMUsed,d6
	beq.w	GetSingleLetter

	lea	pr_DiskVerify+PrefTable(b),a1
	cmp.w	#GD_DiskVerify,d6
	beq.w	GetCheckBox

	rts

.Exit	bsr.w	CloseDiskPrefsWindow

	addq.b	#1,pr_DiskRetries+PrefTable(b);fix retry count

.WindowError	rts

;-----------------------------------------------------------------------------;
;-		         Input Preferences	-;
;-----------------------------------------------------------------------------;
OpenInputPrefs	bsr.w	OpenInputPrefsWindow
	bne.w	.WindowError

	move.l	InputPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	InputPrefsGadgets(pc),a4
	addq.l	#8,a4

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_KeyDelay+PrefTable(b),d0
	bsr.w	SetSlider

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_KeyRepeat+PrefTable(b),d0
	bsr.w	SetSlider

	move.l	(a4)+,a0
	moveq	#1,d0
	tst.b	pr_InsertOW+PrefTable(b)
	beq.b	.insert
	moveq	#0,d0	;insert=0
.insert	bsr.w	SetCycle

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_CursorRate+PrefTable(b),d0
	bsr.w	SetSlider

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_ClearPointer+PrefTable(b),d0
	bsr.w	SetCheckBox

	move.l	(a4)+,a0
	move.b	pr_PasteKey+PrefTable(b),d0
	bsr.w	SetLetterInString

	clr.b	ExitFlag(b)	;will be used for free library

.InputLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.InputLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	InputPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	InputPrefsRender
	move.l	InputPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	pea	.MsgLoop(pc)

	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.nop	;gadget?

	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_InputCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
.nop	rts

.CheckCancel	cmp.w	#GD_InputOK,d6
	beq.b	.flagexit

	lea	pr_ClearPointer+PrefTable(b),a1
	cmp.w	#GD_PointerBlanker,d6
	beq.w	GetCheckBox

;sliders
	lea	pr_KeyRepeat+PrefTable(b),a1
	cmp.w	#GD_RepeatSpeed,d6
	beq.w	GetSlider

	lea	pr_KeyDelay+PrefTable(b),a1
	cmp.w	#GD_DelaySpeed,d6
	beq.w	GetSlider

	lea	pr_CursorRate+PrefTable(b),a1
	cmp.w	#GD_CursorRate,d6
	beq.w	GetSlider

	cmp.w	#GD_EditMode,d6
	bne.b	.editmode
	lea	pr_InsertOW+PrefTable(b),a1
	bsr.w	GetCycle
	moveq	#-1,d0
	tst.b	(a1)
	beq.w	.insert2
	moveq	#0,d0	;insert=0
.insert2	move.b	d0,(a1)
	rts

.editmode	lea	pr_PasteKey+PrefTable(b),a1;check pastekey
	cmp.w	#GD_PasteKey,d6
	beq.w	GetSingleLetter


	rts

.Exit	bsr.w	CloseInputPrefsWindow
.WindowError	rts

;-----------------------------------------------------------------------------;
;-		   Disassembler Preferences	-;
;-----------------------------------------------------------------------------;
OpenDisassemPrefs
	clr.b	Selected(b)
	bsr.w	OpenDisAssemPrefsWindow
	bne.w	.WindowError

.DisAssRestart	move.l	DisAssemPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	DisAssemPrefsGadgets(pc),a4
	addq.l	#8,a4

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_LeadingZeros+PrefTable(b),d0
	bsr.w	SetCheckBox

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_ShortAddress+PrefTable(b),d0
	bsr.w	SetCheckBox

	addq.l	#4,a4	;offset address

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_NegOffsets+PrefTable(b),d0
	bsr.w	SetCheckBox

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_PrintASCII+PrefTable(b),d0
	bsr.w	SetCheckBox

	addq.l	#4,a4	;disassem break

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_DumpLines+PrefTable(b),d0
	bsr.w	SetSlider

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_DisassemNext+PrefTable(b),d0
	bsr.w	SetCheckBox

	addq.l	#4,a4	;show CPU

	move.l	(a4)+,a0	;log updisassemble
	moveq	#0,d0
	move.b	pr_LongUpDis+PrefTable(b),d0
	bsr.w	SetCheckBox

	clr.b	ExitFlag(b)	;will be used for free library
	clr.b	SubWindowFlag(b)

.DisAssemLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	tst.b	SubWindowFlag(b)
	bne.w	.DoSubWindow

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.DisAssemLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	DisAssemPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	DisAssemPrefsRender
	move.l	DisAssemPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_DisAsmCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.CheckCancel	cmp.w	#GD_DisAsmOK,d6
	beq.b	.flagexit

	pea	.MsgLoop(pc)

	cmp.w	#GD_DisAsmBreak,d6
	bne.b	.checkBL
	st.b	SubWindowFlag(b)
	rts

.checkBL	lea	pr_LeadingZeros+PrefTable(b),a1
	cmp.w	#GD_LeadingZeros,d6
	beq.w	GetCheckBox

	lea	pr_ShortAddress+PrefTable(b),a1
	cmp.w	#GD_ShortAddress,d6
	beq.w	GetCheckBox

	lea	pr_PrintASCII+PrefTable(b),a1
	cmp.w	#GD_DCASCII,d6
	beq.w	GetCheckBox

	lea	pr_NegOffsets+PrefTable(b),a1
	cmp.w	#GD_NegativeOffsets,d6
	beq.w	GetCheckBox

	lea	pr_DisassemNext+PrefTable(b),a1
	cmp.w	#GD_DisassemNext,d6
	beq.w	GetCheckBox

	lea	pr_LongUpDis+PrefTable(b),a1
	cmp.w	#GD_LongUpDis,d6
	beq.w	GetCheckBox

;slider
	lea	pr_DumpLines+PrefTable(b),a1
	cmp.w	#GD_DumpLines,d6
	beq.w	GetSlider

	rts

.Exit	bsr.w	CloseDisAssemPrefsWindow

.WindowError	rts

;----- Open breakline prefs
.DoSubWindow	clr.b	Cancelled(b)

	move.w	pr_BreakLine+PrefTable(b),-(a7)

	bsr.w	CloseDisAssemPrefsWindow

	bsr.w	OpenBreakPrefs

	move.w	(a7)+,d0
	tst.b	Cancelled(b)
	beq.b	.dataok
	move.w	d0,pr_BreakLine+PrefTable(b);restore if cancelled

.dataok	clr.b	Cancelled(b)

	bra.w	OpenDisassemPrefs

;-----------------------------------------------------------------------------;
;-		      Memory Preferences	-;
;-----------------------------------------------------------------------------;
OpenMemoryPrefs	bsr.w	OpenMemPrefsWindow
	bne.w	.WindowError

	move.l	MemPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	MemPrefsGadgets(pc),a4
	addq.l	#8,a4

	move.l	(a4)+,a0
	move.l	pr_WorkArea+PrefTable(b),d0
	moveq	#6,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank0S+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank0E+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank1S+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank1E+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank2S+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank2E+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank3S+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank3E+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank4S+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank4E+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank5S+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	move.l	pr_RAMBank5E+PrefTable(b),d0
	moveq	#8,d1
	bsr.w	SetHexInString

	clr.b	ExitFlag(b)	;will be used for free library

.MemoryLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.MemoryLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	MemPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	MemPrefsRender
	move.l	MemPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	pea	.MsgLoop(pc)

	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.nop	;gadget?

	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_MemoryCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
.nop	rts

.CheckCancel	cmp.b	#GD_MemoryOK,d6
	beq.b	.flagexit

	move.l	MemPrefsWnd(pc),a1

	moveq	#6,d2
	lea	pr_WorkArea+PrefTable(b),a2
	cmp.w	#GD_ChipMemory,d6
	beq.b	.hexvaluemain

	moveq	#8,d2

	lea	pr_RAMBank0S+PrefTable(b),a2
	cmp.w	#GD_RAMBank0Start,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank0End,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank1Start,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank1End,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank2Start,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank2End,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank3Start,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank3End,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank4Start,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank4End,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank5Start,d6
	beq.b	.hexvaluemain
	addq.w	#4,a2
	cmp.w	#GD_RAMBank5End,d6
	bne.b	.check

;d2 - #nibbles
;a2 - pref-address
.hexvaluemain	bsr.w	GetHexInput
	bne.w	.fail
	move.l	d0,(a2)
.fail	rts

.check

	rts

.Exit	bsr.w	CloseMemPrefsWindow

	moveq	#0,d0
	lea	pr_RAMBank0S+PrefTable(b),a0
	moveq	#5,d1
.countloop	tst.l	(a0)+
	bne.b	.notfirst
	tst.l	(a0)+
	beq.b	.last
	bra.b	.goon
.notfirst	addq.w	#4,a0
.goon	addq.w	#1,d0
	dbra	d1,.countloop

.last	subq.w	#1,d0
	move.b	d0,pr_BankEntries+PrefTable(b)

.WindowError	rts


;-----------------------------------------------------------------------------;
;-		       Startup Preferences	-;
;-----------------------------------------------------------------------------;
OpenStartupPrefs
	bsr.w	OpenStartPrefsWindow
	bne.w	.WindowError

	move.l	StartPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	StartPrefsGadgets(pc),a4
	addq.l	#8,a4

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_ResetEntry+PrefTable(b),d0
	addq.b	#1,d0
	bsr.w	SetCycle

	add.w	#8,a4	;2 checkboxes

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_NMIROMCheck+PrefTable(b),d0
	bsr.w	SetCheckBox

	move.l	(a4)+,a0
	move.l	pr_CopSearchOff+PrefTable(b),d0
	moveq	#6,d1
	bsr.w	SetHexInString

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_FixKeyboard+PrefTable(b),d0
	bsr.w	SetCheckBox

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_ClearScreen+PrefTable(b),d0
	bsr.w	SetCheckBox


	clr.b	ExitFlag(b)	;will be used for free library

.StartupLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.StartupLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	StartPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	StartPrefsRender
	move.l	StartPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	pea	.MsgLoop(pc)

	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.nop	;gadget?

	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_StartCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
.nop	rts

.CheckCancel	cmp.w	#GD_StartOK,d6
	beq.b	.flagexit

	move.l	StartPrefsWnd(pc),a1

	lea	pr_CopSearchOff+PrefTable(b),a2
	cmp.w	#GD_CopOffset,d6
	bne.b	.check
.hexvaluemain	moveq	#6,d2
	bsr.w	GetHexInput
	bne.w	.fail
	move.l	d0,(a2)
.fail	rts

.check	lea	pr_NMIROMCheck+PrefTable(b),a1
	cmp.w	#GD_NMIROM,d6
	beq.w	GetCheckBox

	lea	pr_FixKeyboard+PrefTable(b),a1
	cmp.w	#GD_ClearMatrix,d6
	beq.w	GetCheckBox

	lea	pr_ClearScreen+PrefTable(b),a1
	cmp.w	#GD_ClearScreen,d6
	beq.w	GetCheckBox

	lea	pr_ResetEntry+PrefTable(b),a1
	cmp.w	#GD_ResetEntry,d6
	bne.b	.check2
	bsr.w	GetCycle
	subq.b	#1,(a1)
	rts

.check2	rts

.Exit	bsr.w	CloseStartPrefsWindow
.WindowError	rts

;-----------------------------------------------------------------------------;
;-		   Miscellaneous Preferences	-;
;-----------------------------------------------------------------------------;
OpenMiscPrefs	bsr.w	OpenMiscPrefsWindow
	bne.w	.WindowError

	move.l	MiscPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	MiscPrefsGadgets(pc),a4
	addq.l	#8,a4

	move.l	(a4)+,a0
	move.b	pr_Prompt+PrefTable(b),d0
	bsr.w	SetLetterInString

	move.l	(a4)+,a0
	move.b	pr_NonASCII+PrefTable(b),d0
	bsr.w	SetLetterInString

	move.l	(a4)+,a0
	move.b	pr_TextJoker+PrefTable(b),d0
	bsr.w	SetLetterInString

	move.l	(a4)+,a0
	moveq	#0,d0
	move.b	pr_ProgressBar+PrefTable(b),d0
	bsr.w	SetCheckBox

	moveq	#0,d0
	move.w	pr_PeekerLines+PrefTable(b),d0
	addq.w	#1,d0
	moveq	#0,d1
	move.b	pr_ScreenMode+PrefTable(b),d1
	mulu	#mon_SizeOf,d1
	lea	pr_Monitors+PrefTable(b),a0
	add.w	d1,a0
	moveq	#0,d1
	move.b	mon_textlines(a0),d1
	add.w	d1,d1
	cmp.w	#100,d1
	blt.b	.ok
	move.w	#99,d1
.ok	move.l	(a4)+,a0
	bsr.w	SetSliderMax

	clr.b	ExitFlag(b)	;will be used for free library

.MiscLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.MiscLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	MiscPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	MiscPrefsRender
	move.l	MiscPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_MiscCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)

.flagexit	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.CheckCancel	cmp.w	#GD_MiscOK,d6
	beq.b	.flagexit

	pea	.MsgLoop(pc)

	lea	pr_ProgressBar+PrefTable(b),a1
	cmp.w	#GD_ProgressBar,d6
	beq.w	GetCheckBox

	lea	pr_Prompt+PrefTable(b),a1
	cmp.w	#GD_Prompt,d6
	beq.w	GetSingleLetter

	lea	pr_NonASCII+PrefTable(b),a1
	cmp.w	#GD_NonASCII,d6
	beq.w	GetSingleLetter

	lea	pr_TextJoker+PrefTable(b),a1
	cmp.w	#GD_TextJoker,d6
	beq.w	GetSingleLetter

	cmp.w	#GD_PeekerHeight,d6
	bne.b	.checkpeeker
	lea	pr_PeekerLines+PrefTable(b),a1
	bsr.w	GetSlider
	moveq	#0,d0
	move.b	(a1),d0
	subq.w	#1,d0
	move.w	d0,(a1)
	rts

.checkpeeker

	rts

.Exit	bsr.w	CloseMiscPrefsWindow
.WindowError	rts


;-----------------------------------------------------------------------------;
;-		    BreakLine Preferences	-;
;-----------------------------------------------------------------------------;
OpenBreakPrefs	bsr.w	OpenBLPrefsWindow
	bne.w	.WindowError

	move.l	BLPrefsWnd(pc),a1;get userport
	move.l	wd_UserPort(a1),WindowPort(b)

	lea	BLPrefsGadgets(pc),a4
	addq.l	#8,a4

	moveq	#5,d7
	move.b	pr_BreakLineEd+PrefTable(b),d6
.prepareloop	move.l	(a4)+,a0
	moveq	#0,d0
	lsr.w	#1,d6
	bcc.b	.notset
	moveq	#1,d0
.notset	bsr.w	SetCheckBox
	dbra	d7,.prepareloop

	moveq	#5,d7
	move.b	pr_BreakLine+PrefTable(b),d6
.prepareloop2	move.l	(a4)+,a0
	moveq	#0,d0
	lsr.w	#1,d6
	bcc.b	.notset2
	moveq	#1,d0
.notset2	bsr.w	SetCheckBox
	dbra	d7,.prepareloop2

	clr.b	ExitFlag(b)	;will be used for free library

.BLLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	.BLLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	BLPrefsWnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.w	BLPrefsRender
	move.l	BLPrefsWnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_BreakCancel,d6
	bne.b	.CheckCancel
	st.b	Cancelled(b)
.flagexit	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.CheckCancel	cmp.w	#GD_BreakOK,d6
	beq.b	.flagexit

	cmp.w	#GD_BLDumpDW,d6
	bgt.b	.MsgLoop

	cmp.w	#GD_BLDumpUB,d6
	blt.b	.dumpbl
	lea	pr_BreakLine+PrefTable(b),a1
	sub.w	#GD_BLDumpUB,d6
	bra.b	.ready

.dumpbl	lea	pr_BreakLineEd+PrefTable(b),a1
	sub.w	#GD_BLEditUB,d6
.ready	bchg	d6,(a1)
	bra.w	.MsgLoop

.Exit	bsr.w	CloseBLPrefsWindow
.WindowError	rts


BackupPrefs	lea	PrefTable(b),a0
	lea	PrefTableBackup(b),a1
	move.w	#pr_SizeOf-1,d0
.backuploop	move.b	(a0)+,(a1)+
	dbra	d0,.backuploop
	rts

RestorePrefs	lea	PrefTableBackup(b),a0
	lea	PrefTable(b),a1
	move.w	#pr_SizeOf-1,d0
.restoreloop	move.b	(a0)+,(a1)+
	dbra	d0,.restoreloop
	rts


;---- Gadget setup

;---- Set checkbox
; In:	d0 -	false/true
;	a0 -	Gadget
;	a1 -	Window
;----
SetCheckBox	lea	TagBuffer(b),a2
	move.l	a2,a3
	move.l	#GTCB_Checked,(a2)+
	move.l	d0,(a2)+
	bra.w	CallSetGadget

;---- Set cycle
; In:	d0 -	active
;	a0 -	Gadget
;	a1 -	Window
;-	a3 -	Text array / NULL
;----
SetCycleD	bra.b	SetCycle\.Entry

SetCycle:	sub.l	a3,a3
.Entry	lea	TagBuffer(b),a2
	move.l	#GTCY_Active,(a2)+
	move.l	d0,(a2)+
	move.l	a3,(a2)+
	beq.b	.None
	move.l	a3,(a2)+
	move.l	#GTCY_Labels,-8(a2)
.None	lea	TagBuffer(b),a3
	bra.w	CallSetGadget

;---- Set Slider
; In:	d0 -	Sliderpos
;	d1 -	Max size (SetSliderMax)
;	a0 -	Gadget
;	a1 -	Window
;----
SetSlider	moveq	#0,d1
SetSliderMax	lea	TagBuffer(b),a2
	move.l	a2,a3
	move.l	#GTSL_Level,(a2)+
	move.l	d0,(a2)+
	tst.l	d1
	beq.b	.nomax
	move.l	#GTSL_Max,(a2)+
	move.l	d1,(a2)+
.nomax	bra.b	CallSetGadget

;---- Set but also disable gadget
SetHexInStringD	moveq	#-1,d2
	bra.b	SetHexInString\.Entry
;---- Set Hex in string
; In:	d0 -	value
;	d1 -	#chars
;	a0 -	Gadget
;	a1 -	Window
;----
SetHexInString:	moveq	#0,d2
.Entry	lea	StringBuffer(b),a3
	lea	TagBuffer(b),a2
	move.l	#GTST_String,(a2)+
	move.l	a3,(a2)+
	move.l	#GA_Disabled,(a2)+
	move.l	d2,(a2)+

	add.w	d1,a3
	clr.b	(a3)
	subq.w	#1,d1
.converttohex	move.w	d0,d2
	and.w	#$f,d2
	add.b	#'0',d2
	cmp.b	#'9'+1,d2
	blt.b	.nonalfa
	addq.w	#7,d2
.nonalfa	move.b	d2,-(a3)
	lsr.l	#4,d0
	dbra	d1,.converttohex
	lea	TagBuffer(b),a3
	bra.b	CallSetGadget

;---- Set string
; In:	a0 -	Gadget
;	a1 -	Window
;	a3 -	string ptr
;----
SetString	lea	TagBuffer(b),a2
	move.l	#GTST_String,(a2)+
	move.l	a3,(a2)+
	lea	TagBuffer(b),a3
	bra.b	CallSetGadget

;---- Set single letter in string
SetLetterInString
	lea	StringBuffer(b),a3
	lea	TagBuffer(b),a2
	move.l	#GTST_String,(a2)+
	move.l	a3,(a2)+
	move.b	d0,(a3)+
	clr.b	(a3)
	lea	TagBuffer(b),a3
;	bra.b	CallSetGadget

;	nop

CallSetGadget	clr.l	(a2)+
	sub.l	a2,a2
	Push	a0/a1
	move.l	_GadToolsBase(pc),a6
	Call	GT_SetGadgetAttrsA
	Pull	a0/a1
	rts


;---- Gadget-message controlling

;---- Control checkbox
;- IN:	d7 -	Message type
;-	a1 -	Boolean pointer
;----
GetCheckBox:	cmp.w	#CHECKBOXIDCMP,d7
	bne.b	.notchecked
	not.b	(a1)	;invert state
.notchecked	rts

;---- Control SingleLetter stringgadget
;- IN:	d7 -	Message type
;-	a0 -	Pointer to gadget
;-	a1 -	Char pointer
;----
GetSingleLetter	cmp.w	#STRINGIDCMP,d7
	bne.b	.skip
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_Buffer(a0),a0
	move.b	(a0),(a1)
.skip	rts

;---- Parse Hex-input stringgadget
;- IN:	d7 -	Message type
;-	a0 -	Pointer to gadget
;-	a1 -	Pointer to window
;- OUT:	d0 -	Value
;-	d1 -	State (0=ok)
;----
GetHexInput:	Push	a0-a2
	cmp.w	#STRINGIDCMP,d7
	bne.b	.dontstore
	move.l	gg_SpecialInfo(a0),a2
	move.l	si_Buffer(a2),a2
	moveq	#0,d0
	tst.b	(a2)
	beq.b	.wrongchar
.convertloop	moveq	#0,d1
	move.b	(a2)+,d1
	beq.b	.valueok
	cmp.b	#'0',d1
	blt.b	.wrongchar
	cmp.b	#'9',d1
	ble.b	.charok
	or.b	#$20,d1
	cmp.b	#'a',d1
	blt.b	.wrongchar
	cmp.b	#'f',d1
	bgt.b	.wrongchar
	sub.w	#7+$20,d1
.charok	sub.w	#'0',d1
	asl.l	#4,d0
	or.w	d1,d0
	bra.b	.convertloop

.wrongchar	move.l	_IntuitionBase(pc),a6
	sub.l	a2,a2
	Call	ActivateGadget	;input (a0+a1) from caller!!!!

	move.l	Scr(pc),a0
	Call	DisplayBeep
.dontstore	moveq	#-1,d1
	Pull	a0-a2
	rts

.valueok	move.l	d2,d1
	Push	d0
	bsr.w	SetHexInString	;update with new value
	Pull	d0
	moveq	#0,d1
	Pull	a0-a2
	rts


;---- Parse Hex-input stringgadget
;- IN:	d7 -	Message type
;-	a0 -	Pointer to gadget
;-	a1 -	Pointer to window
;-	a3 -	String destination
;----
GetString:	Push	a0-a2
	cmp.w	#STRINGIDCMP,d7
	bne.b	.dontstore
	move.l	gg_SpecialInfo(a0),a2
	move.l	si_Buffer(a2),a2
.CopyChars	move.b	(a2)+,(a3)+
	bne.b	.CopyChars
.dontstore	Pull	a0-a2
	rts


;---- Control SliderGadget
;- In:	d5 -	ie_Code
;	a1 -	Sliderpos storage
;----
GetCycle			;same as slider
GetSlider:	cmp.w	#GADGETUP,d7
	bne.b	.skip
	move.b	d5,(a1)

.skip	rts


	include	misc/GTBLibsOpen.i

	include	gr:prefeditor/PrefEditor27.s


;---- Read new preferences
ReadNewPrefs	bsr.w	BackupPrefs
	tst.b	PrefsModified(b)
	beq.w	OKRead

	lea	ReadBodyText(pc),a1
	lea	ReadButtText(pc),a2
	bsr.w	DoEZRequest

	tst.w	d0
	bne.w	OKRead
	rts

OKRead	bsr.w	ZDefaultPrefs	;set default, so shorter files will
			;still have default "extra" data.

	move.l	FileReq(b),a0
	lea	TagBuffer(b),a1
	move.l	a1,a4
	move.l	#ASLFR_Window,(a4)+
	move.l	Ghost_Rider_PrefsWnd(pc),(a4)+
	move.l	#ASLFR_TitleText,(a4)+
	lea	LoadTitle(pc),a2
	move.l	a2,(a4)+
	tst.b	InitPath(b)
	beq.b	.NoPath
	clr.b	InitPath(b)
	move.l	#ASLFR_InitialDrawer,(a4)+
	lea	DefaultDir(pc),a2
	move.l	a2,(a4)+
	move.l	#ASLFR_InitialFile,(a4)+
	lea	DefaultName(pc),a2
	move.l	a2,(a4)+
.NoPath	move.l	#ASLFR_DoSaveMode,(a4)+
	clr.l	(a4)+
	clr.l	(a4)+

	move.l	_ASLBase(b),a6
	jsr	_LVOAslRequest(a6)
	tst.w	d0
	beq.w	SkipRead

	move.l	FileReq(b),a1	;get lock on path
	move.l	fr_Drawer(a1),d1

	move.l	fr_File(a1),a1	;copy name from structure
	lea	Name(b),a0
.CopyNameLoop	move.b	(a1)+,(a0)+
	bne.b	.CopyNameLoop


EntryReadDefault		;called at startup to get def. user prefs
	move.l	#ACCESS_READ,d2
	CallD	Lock
	move.l	d0,CDLock(b)

	move.l	CDLock(b),d1
	bne.b	LockOK

	bsr.w	NoOpening
	bra.w	SkipRead

LockOK	CallD	CurrentDir
	move.l	d0,SysPath(b)

	lea	Name(b),a0
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	Call	Open
	move.l	d0,zFileHandle(b)
	bne.b	.OpenOK
	move.l	SysPath(b),d1
	Call	CurrentDir
	move.l	d0,d1	;free lock
	Call	UnLock
	bsr.w	NoOpening
	bra.w	SkipRead

.OpenOK	lea	IDBuffer(b),a0	;read ID of pref file
	move.l	a0,d2
	moveq	#6,d3
	move.l	zFileHandle(b),d1
	Call	Read
	cmp.l	#6,d0	;read 6 bytes?
	bne.b	.ReadError

	cmp.l	#'GRPF',IDBuffer(b);ID header OK?
	beq.b	.IDOK
	bsr.b	FreeDiskResour
	lea	BadIDBody(pc),a1
	lea	BadIDButt(pc),a2
	bra.b	.HandleRErrors

.IDOK	cmp.w	#Rev,IDBuffer+4(b);only tell user, don't act!
	beq.b	.RevisionOK
	lea	BadRevBody(pc),a1
	lea	BadRevButt(pc),a2
	bsr.b	DoEZRequest

.RevisionOK	lea	PrefTable(b),a0	;read pref file
	move.l	a0,d2
	move.l	#pr_SizeOf,d3	;without type checking!
	move.l	zFileHandle(b),d1
	CallD	Read
	move.l	d0,d7	;save for later "full load" check

.ReadError	bsr.b	FreeDiskResour

	cmp.l	#pr_SizeOf,d7
	beq.b	ReadOK

	st.b	PrefsModified(b);older rev.

	rts

.HandleRErrors	bsr.b	DoEZRequest

	bsr.w	RestorePrefs

SkipRead	rts

ReadOK	clr.b	PrefsModified(b)
	rts

;---- Close file, and free lock
FreeDiskResour	move.l	zFileHandle(b),d1;close file
	CallD	Close

	move.l	SysPath(b),d1	;and get to sys path
	Call	CurrentDir
	move.l	d0,d1	;free lock
	Call	UnLock
	rts

;---- Setup EZRequest
;- Input:	a1 - Body text
;-	a2 - Button text
;----
DoEZRequest
	lea	EZStruct(b),a3
	moveq	#5*4,d0
	move.l	d0,(a3)+
	clr.l	(a3)+
	lea	RequestTitle(pc),a0
	move.l	a0,(a3)+
	move.l	a1,(a3)+
	move.l	a2,(a3)+

	lea	EZStruct(b),a1
	sub.l	a2,a2
	sub.l	a3,a3
	move.l	Ghost_Rider_PrefsWnd(pc),a0

	move.l	_zIntuitionBase(b),a6
	jsr	_LVOEasyRequestArgs(a6)
	rts

	REM
	lea	TagBuffer(b),a3
	move.l	a3,a0

	move.l	#RT_Window,(a3)+
	move.l	Ghost_Rider_PrefsWnd(pc),(a3)+
	clr.l	(a3)

	sub.l	a3,a3
	sub.l	a4,a4
	CallR	rtEZRequestA
	rts
	EREM

GRMemAllocSize=$40000
;---- Modify GhostRider executable
ModifyGR	move.l	#GRMemAllocSize,d0;first alloc memory for file
	moveq	#0,d1
	CallE	AllocMem
	move.l	d0,d7	;mem ptr
	bne.b	.GotMemory

	lea	NoMemBody(pc),a1;not enough memory
	lea	NoMemButt(pc),a2
	bra.b	DoEZRequest

.GotMemory	st.b	InitPath(b)	;init path next time

	move.l	FileReq(b),a0

	lea	TagBuffer(b),a1
	move.l	a1,a4
	move.l	#ASLFR_Window,(a4)+
	move.l	Ghost_Rider_PrefsWnd(pc),(a4)+
	move.l	#ASLFR_TitleText,(a4)+
	lea	ModifyTitle(pc),a3
	move.l	a3,(a4)+

	move.l	#ASLFR_InitialDrawer,(a4)+
	lea	ModifyDir(pc),a2
	move.l	a2,(a4)+
	move.l	#ASLFR_InitialFile,(a4)+
	lea	ModifyName(pc),a2
	move.l	a2,(a4)+

	move.l	#ASLFR_DoSaveMode,(a4)+
	clr.l	(a4)+
	clr.l	(a4)+
	move.l	_ASLBase(b),a6
	jsr	_LVOAslRequest(a6)
	tst.w	d0
	beq.w	SkipModify

	move.l	FileReq(b),a1	;get lock on path
	move.l	fr_Drawer(a1),d1

	move.l	fr_File(a1),a1	;copy name from structure
	lea	Name(b),a0
.CopyNameLoop	move.b	(a1)+,(a0)+
	bne.b	.CopyNameLoop

	move.l	#ACCESS_READ,d2
	CallD	Lock
	move.l	d0,CDLock(b)

	move.l	CDLock(b),d1
	bne.b	.LockOK2

	bsr.w	NoOpening	;;

	bra.w	SkipModify

.LockOK2	Call	CurrentDir
	move.l	d0,SysPath(b)

	lea	Name(b),a0
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	Call	Open
	move.l	d0,zFileHandle(b)
	bne.b	.OpenOK

	move.l	SysPath(b),d1
	Call	CurrentDir
	move.l	d0,d1	;free lock
	Call	UnLock
	bsr.w	NoOpening
	bra.w	SkipModify

.OpenOK	move.l	zFileHandle(b),d1
	move.l	d7,d2
	move.l	#GRMemAllocSize,d3
	Call	Read
	move.l	d0,d6	;length

	bsr.w	FreeDiskResour

	move.l	d7,a0	;find config data
	move.l	d6,d0
	lsr.l	#2,d0
.findConf	cmp.l	#'CFG!',(a0)+
	beq.b	.found
	dbra	d0,.findConf

	lea	NoCFGBody(pc),a1
	lea	NoCFGButt(pc),a2
	bsr.w	DoEZRequest

	bra.w	SkipModify

.found	cmp.w	#Rev,-8(a0)	;check revision is OK
	beq.b	.RevOK

	lea	RevisionBody(pc),a1
	lea	RevisionButt(pc),a2
	bsr.w	DoEZRequest

	bra.w	SkipModify

.RevOK	lea	PrefTable(b),a1	;if found and rev is OK then copy
	move.w	#pr_SizeOf-1,d0
.CopyPrefsLoop	move.b	(a1)+,(a0)+
	dbra	d0,.CopyPrefsLoop


	move.l	FileReq(b),a0

	lea	TagBuffer(b),a1
	move.l	a1,a4
	move.l	#ASLFR_Window,(a4)+
	move.l	Ghost_Rider_PrefsWnd(pc),(a4)+
	move.l	#ASLFR_TitleText,(a4)+
	lea	ModifyOutTitle(pc),a3
	move.l	a3,(a4)+

	move.l	#ASLFR_InitialFile,(a4)+
	lea	ModifyOutName(pc),a2
	move.l	a2,(a4)+
	move.l	#ASLFR_DoSaveMode,(a4)+
	moveq	#-1,d0
	move.l	d0,(a4)+
	clr.l	(a4)+
	move.l	_ASLBase(b),a6
	jsr	_LVOAslRequest(a6)
	tst.w	d0
	beq.w	SkipModify	;no write

	move.l	FileReq(b),a1	;get lock on path
	move.l	fr_Drawer(a1),d1

	move.l	fr_File(a1),a1	;copy name from structure
	lea	Name(b),a0
.CopyNameLoop2	move.b	(a1)+,(a0)+
	bne.b	.CopyNameLoop2

	move.l	#ACCESS_READ,d2
	CallD	Lock
	move.l	d0,CDLock(b)

	move.l	d0,d1
	bne.b	.LockOK3

	bsr.w	NoOpening

	bra.w	SkipModify

.LockOK3	Call	CurrentDir
	move.l	d0,SysPath(b)

	lea	Name(b),a0
	move.l	a0,d1
	move.l	#MODE_NEWFILE,d2
	Call	Open
	move.l	d0,zFileHandle(b)
	bne.w	.OpenOK2
	move.l	SysPath(b),d1
	Call	CurrentDir
	move.l	d0,d1	;free lock
	Call	UnLock
	bsr.w	NoOpening
	bra.b	SkipModify

.OpenOK2	move.l	d0,d1
	move.l	d7,d2	;mem ptr
	move.l	d6,d3	;size
	Call	Write
	move.l	d0,d5	;save for later "full load" check

	bsr.w	FreeDiskResour

	cmp.l	d5,d6
	beq.b	ModifyOK

	lea	BadWriteBody(pc),a1
	lea	BadWriteButt(pc),a2
	bsr.w	DoEZRequest

ModifyOK
SkipModify	move.l	d7,a1	;free alloced memory
	move.l	#GRMemAllocSize,d0
	CallE	FreeMem
	rts

;---- Save preferences
SavePrefs	move.l	FileReq(b),a0

	lea	TagBuffer(b),a1
	move.l	a1,a4
	move.l	#ASLFR_Window,(a4)+
	move.l	Ghost_Rider_PrefsWnd(pc),(a4)+
	move.l	#ASLFR_TitleText,(a4)+
	lea	WriteTitle(pc),a3
	move.l	a3,(a4)+

	tst.b	InitPath(b)
	beq.b	.NoPath
	clr.b	InitPath(b)

	move.l	#ASLFR_InitialDrawer,(a4)+
	lea	DefaultDir(pc),a2
	move.l	a2,(a4)+
	move.l	#ASLFR_InitialFile,(a4)+
	lea	DefaultName(pc),a2
	move.l	a2,(a4)+
.NoPath	move.l	#ASLFR_DoSaveMode,(a4)+
	moveq	#-1,d0
	move.l	d0,(a4)+
	clr.l	(a4)+
	move.l	_ASLBase(b),a6
	jsr	_LVOAslRequest(a6)
	tst.w	d0
	beq.w	SkipWrite

	move.l	FileReq(b),a1	;get lock on path
	move.l	fr_Drawer(a1),d1

	move.l	fr_File(a1),a1	;copy name from structure
	lea	Name(b),a0
.CopyNameLoop	move.b	(a1)+,(a0)+
	bne.b	.CopyNameLoop


	move.l	#ACCESS_READ,d2
	CallD	Lock
	move.l	d0,CDLock(b)

	move.l	CDLock(b),d1
	bne.b	LockOK2

	bsr.w	NoOpening

	bra.w	SkipWrite

LockOK2	CallD	CurrentDir
	move.l	d0,SysPath(b)

	lea	Name(b),a0
	move.l	a0,d1
	move.l	#MODE_NEWFILE,d2
	Call	Open
	move.l	d0,zFileHandle(b)
	bne.b	.OpenOK
	move.l	SysPath(b),d1
	Call	CurrentDir
	move.l	d0,d1	;free lock
	Call	UnLock
	bsr.b	NoOpening
	bra.b	SkipWrite

.OpenOK	lea	PrefTable-6(b),a0;write pref file
	move.l	a0,d2
	move.l	#pr_SizeOf+6,d3	;without type checking!
	move.l	zFileHandle(b),d1
	Call	Write
	move.l	d0,d7	;save for later "full load" check

	bsr.w	FreeDiskResour

	cmp.l	#pr_SizeOf+6,d7
	beq.b	WriteOK

	lea	BadWriteBody(pc),a1
	lea	BadWriteButt(pc),a2
	bsr.w	DoEZRequest

SkipWrite	rts

WriteOK	clr.b	PrefsModified(b)
	rts


NoOpening	lea	NoOpenBody(pc),a1
	lea	NoOpenButt(pc),a2
	bra.w	DoEZRequest


RequestTitle	dc.b	'GR Pref request',0

ModifyTitle	dc.b	'Please find GR for me...',0
ModifyOutTitle	dc.b	'Name of the modified file',0

ReadBodyText	dc.b	'Preferences are modified.',10
	dc.b	'Still want to load new preferences?',0
QuitButtText
DefButtText
ReadButtText	dc.b	'Yes|No',0

DefBodyText	dc.b	'Preferences are modified.',10
	dc.b	'Really set default preferences?',0

LoadTitle	dc.b	'Load GhostRider preferencefile',0
WriteTitle	dc.b	'Save GhostRider preferencefile',0

NoOpenBody	dc.b	'Could not open file!?!',0
NoOpenButt	dc.b	'Say what?',0

BadIDBody	dc.b	'Not a GhostRider Preference File!',10
	dc.b	'Cancelling operation!',0
NoMemButt
BadIDButt	dc.b	"Blast!",0

NoMemBody	dc.b	'Not enough memory free!',0

RevisionBody	dc.b	'This GR has incorrect preference version.',10
	dc.b	'The "ver" command in GR should yield',10
	dc.b	'GRP revision '
	RevText
	dc.b	' for GR to be compatiple.',0

NoCFGBody	dc.b	'Could not locate GR preferences.',10
	dc.b	'Make sure the file is not compressed!',0

BadRevBody	dc.b	'Revision number of Preference File not correct!',10
	dc.b	'Operation is continued, but settings may '
	dc.b	'be corrupt!',0
RevisionButt
BadRevButt	dc.b	"I see!?!",0

BadWriteBody	dc.b	'File not saved succesfully!?!',0
NoCFGButt
BadWriteButt	dc.b	"Huh?",0
	even


;------------- Default Preferences
DBSize=$31A0

;---- Flags for resetentry
re_Never=		-1
re_Always=		0
re_RightMouse=		1
re_LeftMouse=		2
re_Joystick=		3


DefaultPrefs:	offset	0
;---- Display Prefs
pr_ScreenColor0	dc.w	$448	;screen background color
pr_ScreenColor1	dc.w	$ccc	;screen text color
pr_HeaderColor0	dc.w	$446	;header background color
pr_HeaderColor1	dc.w	$ddd	;header text color
pr_CursorColor	dc.w	$d80	;Cursor color

	dc.w	$000

pr_ColorP1	dc.w	$b00	;Pointer color
pr_ColorP2	dc.w	$f00	;Pointer color

	dc.b	0
	dc.b	0

pr_ClearPointer	dc.b	~0	;clear pointer at key-prez?
pr_DiskVerify	dc.b	~0	;disk verify

;---- Input Prefs
pr_KeyRepeat	dc.b	1	;keyboard repeat
pr_KeyDelay	dc.b	20	;keyboard delay
pr_CursorRate	dc.b	2
	dc.b	0

;---- Dis/Assembler Prefs
pr_BreakLine	dc.b	%101101	;mask for inserting line after cmds
pr_BreakLineEd	dc.b	%000000	;mask for inserting line after cmds in editor
pr_LeadingZeros	dc.b	~0	;suppress leading zeros
pr_ShortAddress	dc.b	0	;only print addresses with 6 digits
pr_Indirect	dc.b	0	;display indirect addresses (5/6th col)
pr_PrintASCII	dc.b	0	;also print ASCII letters of DC.W value
pr_NegOffsets	dc.b	~0	;print negative offsets like -abs(off)
pr_DumpLines	dc.b	10	;dump how many lines?
pr_DisassemNext	dc.b	~0	;disassemble next after lineassemble?
pr_ShowCPU	dc.b	0	;show CPUType in editor.
pr_LongUpDis	dc.b	0	;backwards disassembly seek 12-22 bytes
	dc.b	0

;---- Peeker prefs
pr_PeekerLines	dc.w	23*2-1

pr_RAMBank0S	dc.l	0
pr_RAMBank0E	dc.l	$100000-1
pr_RAMBank1S	dc.l	$f80000
pr_RAMBank1E	dc.l	$1000000-1
pr_RAMBank2S	dc.l	$7c00000
pr_RAMBank2E	dc.l	$8000000-1
pr_RAMBank3S	dc.l	0
pr_RAMBank3E	dc.l	0
pr_RAMBank4S	dc.l	0
pr_RAMBank4E	dc.l	0
pr_RAMBank5S	dc.l	0
pr_RAMBank5E	dc.l	0

pr_BankEntries	dc.b	3-1
	dc.b	0

;---- Misc Prefs
pr_Prompt	dc.b	'>'	;command line prompt
pr_NonASCII	dc.b	'_'	;displayed instead of NON ascii chars
pr_SelectedDrive dc.b	0	;selected drive at entry
pr_TextJoker	dc.b	'?'
pr_InsertOW	dc.b	~0	;start with insert/overwrite (0/-1)
pr_ProgressBar	dc.b	~0	;progress bar
pr_WorkArea	dc.l	$f0000	;start of chip-work
pr_CopSearchOff	dc.l	$200	;default copper search offset

pr_DiskSync	dc.w	$4489
pr_DDTrackLen	dc.w	DBSize
pr_HDTrackLen	dc.w	DBSize*2+32
pr_DiskRetries	dc.b	2+1	;2 retries before error

pr_ResetEntry	dc.b	re_RightMouse
pr_NMIROMCheck	dc.b	~0

pr_PasteKey	dc.b	'<'

pr_FixKeyboard	dc.b	~0	;system entry will clear keyboard matrix

pr_BitMapRes	dc.b	'#'	;BitMap reserved
pr_BitMapFree	dc.b	'+'	;BitMap Free
pr_BitMapUsed	dc.b	'X'	;BitMap Used

pr_ClearScreen	dc.b	0	;Clear screen at entry

pr_ScreenMode	dc.b	0	;Default screen mode


mon_Name=	0
mon_textlines=	$20
mon_custom=	$21
mon_diwstrt=	$22
mon_diwstop=	$24
mon_ddfstrt=	$26
mon_ddfstop=	$28
mon_beamcon0=	$2a
mon_bplcon0=	$2c
mon_hbstrt=	$2e
mon_hbstop=	$30
mon_hsstrt=	$32
mon_hsstop=	$34
mon_htotal=	$36
mon_hcenter=	$38
mon_vbstrt=	$3a
mon_vbstop=	$3c
mon_vsstrt=	$3e
mon_vsstop=	$40
mon_vtotal=	$42
mon_diwhigh=	$44
mon_SysView=	$46
mon_Filler=	$47	;!Free!
mon_SizeOf=	$48


pr_Monitors	dc.b	'PAL:High Res (29 lines)',0,0,0,0,0,0,0,0,0
	dc.b	29	;mon_textlines
	dc.b	0	;mon_custom
	dc.w	$2c81	;mon_diwstrt
	dc.w	$1ec1	;mon_diwstop
	dc.w	$003c	;mon_ddfstrt
	dc.w	$00d4	;mon_ddfstop
	dc.w	$0020	;mon_beamcon0
	dc.w	$9200	;mon_bplcon0
	dc.w	$0	;mon_hbstrt
	dc.w	$0	;mon_hbstop
	dc.w	$0	;mon_hsstrt
	dc.w	$0	;mon_hsstop
	dc.w	$0	;mon_htotal
	dc.w	$0	;mon_hcenter
	dc.w	$0	;mon_vbstrt
	dc.w	$0	;mon_vbstop
	dc.w	$0	;mon_vsstrt
	dc.w	$0	;mon_vsstop
	dc.w	$0	;mon_vtotal
	dc.w	$0	;mon_diwhigh
	dc.b	~0
	dc.b	0

	dc.b	'NTSC:High Res (23 lines)',0,0,0,0,0,0,0,0
	dc.b	23	;mon_textlines
	dc.b	0	;mon_custom
	dc.w	$2c81	;mon_diwstrt
	dc.w	$eec1	;mon_diwstop
	dc.w	$003c	;mon_ddfstrt
	dc.w	$00d4	;mon_ddfstop
	dc.w	$0000	;mon_beamcon0
	dc.w	$9200	;mon_bplcon0
	dc.w	$0	;mon_hbstrt
	dc.w	$0	;mon_hbstop
	dc.w	$0	;mon_hsstrt
	dc.w	$0	;mon_hsstop
	dc.w	$0	;mon_htotal
	dc.w	$0	;mon_hcenter
	dc.w	$0	;mon_vbstrt
	dc.w	$0	;mon_vbstop
	dc.w	$0	;mon_vsstrt
	dc.w	$0	;mon_vsstop
	dc.w	$0	;mon_vtotal
	dc.w	$0	;mon_diwhigh
	dc.b	~0
	dc.b	0

	dc.b	'PAL:High Res Lace (51 lines)',0,0,0,0
	dc.b	51	;mon_textlines
	dc.b	0	;mon_custom
	dc.w	$2c81	;mon_diwstrt
	dc.w	$fdc1	;mon_diwstop
	dc.w	$003c	;mon_ddfstrt
	dc.w	$00d4	;mon_ddfstop
	dc.w	$0020	;mon_beamcon0
	dc.w	$9204	;mon_bplcon0
	dc.w	$0	;mon_hbstrt
	dc.w	$0	;mon_hbstop
	dc.w	$0	;mon_hsstrt
	dc.w	$0	;mon_hsstop
	dc.w	$0	;mon_htotal
	dc.w	$0	;mon_hcenter
	dc.w	$0	;mon_vbstrt
	dc.w	$0	;mon_vbstop
	dc.w	$0	;mon_vsstrt
	dc.w	$0	;mon_vsstop
	dc.w	$0	;mon_vtotal
	dc.w	$0	;mon_diwhigh
	dc.b	~0
	dc.b	0

	dc.b	'NTSC:High Res Lace (46 lines)',0,0,0
	dc.b	46	;mon_textlines
	dc.b	0	;mon_custom
	dc.w	$2c81	;mon_diwstrt
	dc.w	$e9c1	;mon_diwstop
	dc.w	$003c	;mon_ddfstrt
	dc.w	$00d4	;mon_ddfstop
	dc.w	$0000	;mon_beamcon0
	dc.w	$9204	;mon_bplcon0
	dc.w	$0	;mon_hbstrt
	dc.w	$0	;mon_hbstop
	dc.w	$0	;mon_hsstrt
	dc.w	$0	;mon_hsstop
	dc.w	$0	;mon_htotal
	dc.w	$0	;mon_hcenter
	dc.w	$0	;mon_vbstrt
	dc.w	$0	;mon_vbstop
	dc.w	$0	;mon_vsstrt
	dc.w	$0	;mon_vsstop
	dc.w	$0	;mon_vtotal
	dc.w	$0	;mon_diwhigh
	dc.b	~0
	dc.b	0

	dc.b	'MSCAN:Productivity (51 lines)',0,0,0
	dc.b	51	;mon_textlines
	dc.b	~0	;mon_custom
	dc.w	$2c41	;mon_diwstrt
	dc.w	$cee5	;mon_diwstop
	dc.w	$0020	;mon_ddfstrt
	dc.w	$0068	;mon_ddfstop
	dc.w	$1b88	;mon_beamcon0
	dc.w	$1241	;mon_bplcon0
	dc.w	$0001	;mon_hbstrt
	dc.w	$0021	;mon_hbstop
	dc.w	$000e	;mon_hsstrt
	dc.w	$0018	;mon_hsstop
	dc.w	$0071	;mon_htotal
	dc.w	$0048	;mon_hcenter
	dc.w	$0000	;mon_vbstrt
	dc.w	$001c	;mon_vbstop
	dc.w	$0004	;mon_vsstrt
	dc.w	$0008	;mon_vsstop
	dc.w	$01ce	;mon_vtotal
	dc.w	$0100	;mon_diwhigh
	dc.b	0
	dc.b	0


;pr_fill	dc.b	0

pr_SizeOf
	endoff

	even

ASLNam	ASLName
zIntNam	IntName
DOSNam	DOSName
DefaultDir	dc.b	'S:',0
DefaultName	dc.b	'GhostRider.Prefs',0
ModifyDir	dc.b	'C:',0
ModifyName	dc.b	'GR',0
ModifyOutName	dc.b	'GRup',0

	section	crap,BSS
	rsreset
WindowPort	rs.l	1

zFileHandle	rs.l	1

MonitorBackup	rs.b	mon_SizeOf

SelectedMonitor	rs.l	1

EZStruct	rs.b	4*5

FileReq	rs.l	1
SysPath	rs.l	1
CDLock	rs.l	1

_ASLBase	rs.l	1
_DOSBase	rs.l	1
_zIntuitionBase	rs.l	1

Name	rs.b	32+2	;guess 32 is enough, but...

IDString	rs.l	1
RevisionNumber	rs.w	1
PrefTable	rs.b	pr_SizeOf
PrefTableBackup	rs.b	pr_SizeOf;updated before entering window

CycleNameList	rs.l	6
			;probs with assembler/breaklines

TagBuffer	rs.l	6+2+4
StringBuffer	rs.b	10

IDBuffer	rs.w	3	;4 for ID, 2 for revision

SubWindowFlag	rs.b	1
NewModeFlag	rs.b	1

ExitFlag	rs.b	1
Selected	rs.b	1

Cancelled	rs.b	1

PrefsModified	rs.b	1

InitPath	rs.b	1	;flag filereq to include default path

BSSSize	rs.b	0

B	ds.b	BSSSize

	printv	Rev
