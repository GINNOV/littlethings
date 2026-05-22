
*---* gtfdevel.q *-------------------------------------------------------------
*
* 	Developement program for GTFace gadgets and menus.
*
* 	Author		Stefan Walter
*	Version		1.00
*	Last Revision	25.03.93
*
*------------------------------------------------------------------------------
*
* This source is meant to be used for developing gadget and menu lists. What
* you have to do is set either or both TESTGADGETS or/and TESTMENUS. Then you
* can add either or both a gadget or/and a menu list at the end of this source.
* Rules to be followed are described down there.
*
*------------------------------------------------------------------------------

*------------------

TESTGADGETS	SET	1	;Remove ';' if testing gadgets
;TESTMENUS	SET	1	;Remove ';' if testing menus

*------------------
* ProAsm
*
progbase:
	relax
	opt	o+,ow-,sw-,f+
	output	ram:GTFDemo
	odd2error
	exeobj
	mc68000
	base	progbase

	incdir	routines:
	incdir	include:


*------------------
* Tonns of flags...
*
USE_NEWROUTINES	SET	1
gea_progname	equr	"GTFDevel"
cws_DETACH	set	1
version		equr	"1.00"

	include	tasktricks.r
	include	gtfxdefs.r
	include	gtfmacros.r
	include	gtfguido.r
	include	basicmac.r
	include	intuition/sghooks.i

	NEED_	StringHistoryHookFunction


*------------------
* Startup and $VER.
*
start:	jmp	AutoDetach(pc)


*------------------------------------------------------------------------------
*
* Regular startup for WB and CLI.
*
*------------------------------------------------------------------------------

*------------------
* Comming from CLI.
*
clistartup:
	lea	progbase(pc),a4
	suba.l	a0,a0
	bsr	ReplySync
	bra.s	commonstartup

*------------------
* Comming from WB.
*
wbstartup:
	lea	progbase(pc),a4


*------------------
* Common part of startup.
*
commonstartup:
	CALL_	InitGTFace
	beq	exit

getwindow:
	lea	newwindow(pc),a0
	lea	newwindowtags(pc),a1
	lea	windowkey(pc),a2
	CALL_	OpenScaledWindow
	tst.l	d0
	beq.s	closegtf

	moveq	#3,d0
	CALL_	ClearWindow

	IFD	TESTGADGETS
getgadgets:
	move.w	#1,MXPatch
	move.l	#12345,NumberPatch
	lea	thetestgadgets(pc),a0
	lea	gadgetkey(pc),a1
	CALL_	CreateGList
	tst.l	d0
	beq	closewindow

	CALL_	AddGList
	CALL_	RefreshWindow
	ENDIF
	
	IFD	TESTMENUS
getmenus:	
	lea	thetestmenus(pc),a0
	CALL_	AddMenu
	beq.s	freegadgets
	ENDIF

wait:	CALL_	WaitForWindow
	CALL_	GetGTFMsg
	tst.l	d0
	beq.s	wait
\n3:	cmp.l	#4,d0
	bne.s	\n1
	CALL_	RefreshEventHandler
\n1:	cmp.l	#$200,d0
	bne.s	wait

freemainmenu:
	IFD	TESTMENUS
	CALL_	RemMenu
	ENDIF

freegadgets:
	IFD	TESTGADGETS
	lea	gadgetkey(pc),a1
	CALL_	RemGList
	CALL_	FreeGList
	ENDIF

closewindow:
	lea	windowkey(pc),a2
	CALL_	CloseScaledWindow
	
closegtf:
	CALL_	ResetGTFace

exit:	bsr	ReplyWBMsg
	moveq	#0,d0
	rts


*------------------------------------------------------------------------------
*
* Data and includes.
*
*------------------------------------------------------------------------------

*------------------
	include	startup4.r
	include	gtface.r
	include	gtfsupport.r


windowkey:	ds.b	gfw_SIZEOF,0
gadgetkey:	ds.b	gfg_SIZEOF,0

myhook:		HistoryHook_		myhiststruct
myhiststruct:	StringHistoryStruct_	stringhistory,1200
stringhistory:	ds.b	1200,0



*------------------------------------------------------------------------------
*
* Window, menus and gadgets.
*
*------------------------------------------------------------------------------

newwindowtags:
	dc.l	WA_InnerWidth,0
	dc.l	WA_InnerHeight,0
	dc.l	WA_AutoAdjust,-1
	dc.l	0

newwindow:	
	dc.w	0,0		;l/t
	dc.w	thewinsx,thewinsy	;w/h
	dc.b	-1,-1		;pens
	dc.l	$000306		;idcmp
	dc.l	$2000141f	;flags	($400:G00)
	dc.l	0		;gadget
	dc.l	0		;checkmark
	dc.l	windowtitle	;title
	dc.l	0		;screen
	dc.l	0		;s bitmap
	dc.w	100,4		;min w/h
	dc.w	500,200		;w/h
	dc.w	$1		;screen mode

windowtitle:	dc.b	"GTFDevel v",version,0
processname:	dc.b	"GTFDevel",0
		even

	IFD	TESTGADGETS

*--------------------------------------
* Gadgets.
*
* Insert your definitions between SetIDCounter_ and GadgetsDone_. Required
* is that you use the GUI macros for positioning and that you start your
* gadgets with BeginGList_ and end them with EndGList_.
*
thetestgadgets:
	SetIDCounter_	1000
	BeginGList_	ListOne

	GUINew_
	GUIBoxStart_	BoxOne

		GUISize_	15*8,12
		GUIGadget_	BUTTON,ButtonOne
			Underscore_
			TextIn_	"_Simple Button"

		GUIBeside_
		GUIAdjust_	15*8
		GUISize_	32,12
		GUIGadget_	BUTTON,ButtonTwo
			Underscore_
			TextLeft_	"_Toggle Button"
			ToggleSelect_
			Selected_

		GUIBeside_
		GUISize_	90,12
		GUIGadget_	BUTTON,ButtonThree
			Underscore_
			TextIn_	"_Disabled"
			Disabled_

		GUIBelow_	ButtonOne
		GUIAdjust_	,1
		GUISize_	32,12
		GUIGadget_	CHECKBOX,CheckBoxOne
			Underscore_
			TextRight_	"_CheckBox"
			Checked_

		GUIBeside_
		GUIAdjust_	10*8+10*8,-1
		GUIRight_	ButtonThree
		GUISize_	,14
		GUIGadget_	INTEGER,IntegerOne
			Underscore_
			TextLeft_	"_Integer"
			RightJustified_
			NumberPatch_	100000,NumberPatch

	GUIBoxEnd_	BoxOne

	GUIBelowBox_	BoxOne
	GUIBoxStart_	BoxTwo

		GUIRight_	ButtonThree
		GUISize_	,5*8
		GUIGadget_	LISTVIEW,ListViewOne
			ShowSelected_

	GUIBoxEnd_	BoxTwo
		Recessed_

	GUIBelowBox_	BoxTwo
	GUIBoxStart_	BoxThree

		GUISize_	10,(4*8+3*2)
		GUIGadget_	MX,MXOne
			TextRight_	0
			Labels_		MXLabels
			ActivePatch_	2,MXPatch
			Spacing_	3

		GUIBeside_
		GUIAdjust_	10*8,8+5
		GUIRight_	ButtonThree
		GUISize_	,12
		GUIGadget_	SLIDER,SliderOne
			RelVerify_
			Min_	10
			Max_	100
			Level_	25
			MaxLevelLen_	14
			LevelFormat_	"Level %ld  "
			LevelPlace_	PLACETEXT_ABOVE
	
		GUIBelow_	SliderOne
		GUISize_	108,14
		GUIGadget_	CYCLE,CycleOne
			Labels_	CycleLabels
			Active_	4

		GUIBeside_
		GUIRight_	ButtonThree
		GUISize_	,14
		GUIGadget_	STRING,StringOne
			TextRight_	0
			String_		"GYAAAAAHH......"
			MaxChars_	100
			TabCycle_
			EditHook_	myhook

		
	GUIBoxEnd_	BoxThree

	GUIBelowBox_	BoxThree
	GUIBoxStart_	BoxFour

		GUIRight_	ButtonThree
		GUISize_	,14
		GUISpace_	emptyspace1

		GUISize_	370,14
		GUICenterX_	BoxFour
		GUICenterY_	BoxFour
		GUIGadget_	BUTTON,okaybutton
		  TextIn_	"centered"

	GUIBoxEnd_	BoxFour

	GUIWindowSize_	winsx,winsy
	EndGList_	ListOne




	GUIWindowSize_	thewinsx,thewinsy

;------------------
MXLabels:
	GenLabel_	"First"
	GenLabel_	"Second"
	GenLabel_	"Third"
	GenLabel_	"Last"
	EndLabel_

CycleLabels:
	GenLabel_	"Australien"
	GenLabel_	"Europa"
	GenLabel_	"Amerika"
	GenLabel_	"Asien"
	GenLabel_	"Arktis"
	GenLabel_	"Afrika"
	EndLabel_

	GadgetsDone_

*--------------------------------------

	ELSE
thewinsx	EQU	400
thewinsy	EQU	100
	ENDIF

	IFD	TESTMENUS

*--------------------------------------
* Menus.
*
* Insert your menu definitions between MenuStart_ and MenuEnd_.
*
thetestmenus:
	MenuStart_




	MenuTitle_	" Project "

		MenuItem_	"About","A",menuabout
		  Disabled_
		MenuBar_	-1
		MenuItem_	"Quit","Q",menuquit

	MenuTitle_	" Test "

		MenuItem_	"Load..."
			MenuSubItem_	"File","F",subfile
			  CheckIt_
			  Checked_
			  Exclude_	subdisk
			  Exclude_	subpara

			MenuSubItem_	"Disk","D",subdisk
			  CheckIt_
			  Toggled_
			  Exclude_	subfile

			MenuSubItem_	"Paralell","P",subpara
			  CheckIt_
			  Toggled_
			  Exclude_	subfile
			
		MenuItem_	"Save..."
			MenuSubItem_	"Now"
			  CheckIt_
			  Toggled_
			  Checked_

			MenuSubItem_	"Later"
			  CheckIt_
			  Toggled_
			  Checked_

	MenuTitle_	" Master "

		MenuItem_	"Executable","L"
		MenuItem_	"File","F"
		MenuItem_	"Bootblock","B"
		MenuItem_	"Project","B"

	MenuEnd_
	MenusDone_


*--------------------------------------

	ENDIF

*------------------------------------------------------------------------------

	end


