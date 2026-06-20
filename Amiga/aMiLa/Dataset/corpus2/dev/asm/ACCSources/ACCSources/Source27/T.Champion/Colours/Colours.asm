*************************************************************************
*									*
*	A program to change the screen colours				*
*	and save then to a file, click on the				*
*	file and the screen colours will change				*
*                                                                       *
*	(C) 1992 Tom Champion						*
*                                                                       *
*	Name - Colurs.asm						*
*                                                                       *
*	For use with AmigaDos 2.04 Only.				*
*                                                                       *
*	Assembled with Devpac 3						*
*                                                                       *
*************************************************************************

;	opt NODEBUG, O-
	
	incdir	sys:include2.0/
	include exec/exec_lib.i
	include graphics/graphics_lib.i
	include libraries/asl.i
	include libraries/asl_lib.i
	include libraries/dos.i
	include libraries/dos_lib.i
	include libraries/dosextens.i
	include libraries/gadtools.i
	include libraries/gadtools_lib.i
	include intuition/intuition.i
	include intuition/intuition_lib.i
	include intuition/gadgetclass.i
	include workbench/startup.i
	include workbench/icon_lib.i
	include workbench/workbench.i
	
;	include misc/macros.i


* Macro to load a6 with the proper variable

Ready		MACRO
	IFC 	'\1','Dos'
		move.l DosBase,a6
	ENDC
	IFC	'\1','Exec'
		move.l	$4.w,a6
	ENDC
		ENDM

* Macro to call the function after you have set a6

Call		MACRO
		jsr	_LVO\1(a6)
		ENDM

	
	bra	main


* Library Bases
	
AslBase			dc.l 0
DosBase			dc.l 0
GraphicsBase		dc.l 0
GadtoolsBase		dc.l 0
IconBase		dc.l 0


* Program variables

FileName		ds.b 80
CurDir			ds.b 80
MyDrawInfo		dc.l 0
VisualIn		dc.l 0
Gad			dc.l 0
GadgetList		dc.l 0
RGadget			dc.l 0
GGadget			dc.l 0
BGadget			dc.l 0
MyMenus			dc.l 0
CreateIcon		dc.w 1
MyFont			dc.l 0
FontHeight		dc.w 0
WbMsg			dc.l 0
MyMsg			dc.l 0
Colour			dc.w 0 
Red			dc.w 0
Green			dc.w 0
Blue			dc.w 0
Class			dc.l 0
Code			dc.w 0
GadgetID		dc.w 0
MyIDCMP			dc.l 0
MyWindow		dc.l 0
AslRequester		dc.l 0
RestoreColours		ds.w 16
DefaultColours		
			dc.w $0AAA, $0000, $0FFF, $068B, $000F, $0F0F
			dc.w $000F, $0FFF, $0620, $0E50, $09F1, $0EB0
			dc.w $055F, $092F, $00F8, $0BBB
			
PresetColours		dc.w $0BA9, $0002, $0FFF, $068B		;Tint
			dc.w $08AC, $0002, $0FFF, $0FB9		;Pharoah
			dc.w $08AC, $0002, $0FFF, $0E97		;Sunset
			dc.w $05BA, $0002, $0EEF, $057A		;Ocean
			dc.w $09BD, $0002, $0FFF, $068B		;Steel
			dc.w $0A98, $0321, $0FEE, $0FDB		;Chocolate
			dc.w $0CCB, $0003, $0FFF, $09AB		;Pewter
			dc.w $0B99, $0002, $0FEE, $0B67		;Wine
			dc.w $0A96, $0002, $0FFF, $0779		;A2024
			
AslName			dc.b 'asl.library',0
	even
DosName			dc.b 'dos.library',0
	even	
IntuiName		dc.b 'intuition.library',0
	even	
GraphicsName		dc.b 'graphics.library',0
	even	
GadtoolsName		dc.b 'gadtools.library',0
	even		
IconName		dc.b 'icon.library',0
	even		
ScreenName		dc.b 'Workbench',0
	even		
SaveTitle		dc.b 'Saving...',0
	even


* Window
			
ZoomSize		dc.w 170,0,140
ZoomHeight		dc.w 3

WindowTags
			dc.l WA_Left,80
			dc.l WA_Top,30
			dc.l WA_Width,270
			dc.l WA_Height
WindowHeight		dc.l 95
			dc.l WA_DetailPen,0
			dc.l WA_BlockPen,1
			dc.l WA_IDCMP,IDCMP_CLOSEWINDOW+IDCMP_GADGETUP+IDCMP_CHANGEWINDOW+IDCMP_MENUPICK
			dc.l WA_Activate,1
			dc.l WA_DepthGadget,1
			dc.l WA_DragBar,1
			dc.l WA_CloseGadget,1
			dc.l WA_Title,WindowTitle
			dc.l WA_SmartRefresh,1
			dc.l WA_Zoom,ZoomSize
			dc.l WA_PubScreen
MyScreen		dc.l 0
			dc.l TAG_DONE
			
WindowTitle		dc.b 'Colours',0
	even


* Font
	
TextAtt
			dc.l FontName
			dc.w 8
			dc.b 0
			dc.b 0

FontName		dc.b 'topaz.font',0


* Save Requester 

FileReqTags		dc.l ASL_Window
FileReqWindow		dc.l 0
			dc.l ASL_Hail,SaveReqText
			dc.l ASL_LeftEdge,100
			dc.l ASL_TopEdge,40
			dc.l ASL_Width,200
			dc.l ASL_Height,160
			dc.l ASL_Dir,CurDir
			dc.l TAG_DONE

SaveReqText		dc.b 'Save Executable File',0


* Error Requester

OpenError		dc.l es_SIZEOF
			dc.l 0
			dc.l OpenErrorTitle
			dc.l OpenErrorText
			dc.l OpenErrorGadget

OpenErrorTitle		dc.b 'Error!',0
	even
	
OpenErrorText		dc.b " Can't Create File ",0
	even
	
OpenErrorGadget		dc.b 'Continue',0
	even


* About Requester

AboutReq		dc.l es_SIZEOF
			dc.l 0
			dc.l AboutTitle
			dc.l AboutText
			dc.l AboutGadget

AboutTitle		dc.b 'About',0
	even
	
AboutText		dc.b ' Colours (C)1992 By Tom Champion ',10,10
			dc.b ' Bug reports or correspondence to ',10,10
			dc.b ' Tom Champion',10
			dc.b ' 62 Sterling Rd.',10
			dc.b ' Metung 3904',10
			dc.b ' Australia',10,0
	even
	
AboutGadget		dc.b ' Ok ',0
	even


* Gadgets
	
PaletteGadget
			dc.w 50
			dc.w 7
			dc.w 200
			dc.w 20
			dc.l 0
			dc.l TextAtt
			dc.w 1
			dc.l 0
			dc.l 0
			dc.l 0

	even

PaletteTags		dc.l GTPA_Depth
PaletteDepth		dc.l 0
			dc.l GTPA_IndicatorWidth,40
			dc.l GTPA_Color,0
			dc.l TAG_DONE
			
	even

SliderTags		dc.l GTSL_Min,0
			dc.l GTSL_Max,15
			dc.l GTSL_Level
SliderLevel		dc.l 0
			dc.l GTSL_LevelFormat,String
			dc.l GTSL_MaxLevelLen,4
			dc.l TAG_DONE	
	
	even
	
RedGadget
			dc.w 99
			dc.w 32
			dc.w 151
			dc.w 10
			dc.l RedText
			dc.l TextAtt
			dc.w 2
			dc.l PLACETEXT_LEFT|NG_HIGHLABEL
			dc.l 0
			dc.l 0

RedText			dc.b 'Red:   ',0

	even
	
GreenGadget
			dc.w 99
			dc.w 47
			dc.w 151
			dc.w 10
			dc.l GreenText
			dc.l TextAtt
			dc.w 3
			dc.l PLACETEXT_LEFT|NG_HIGHLABEL
			dc.l 0
			dc.l 0

GreenText		dc.b 'Green:   ',0

	even
	
BlueGadget
			dc.w 99
			dc.w 62
			dc.w 151
			dc.w 10
			dc.l BlueText
			dc.l TextAtt
			dc.w 4			
			dc.l PLACETEXT_LEFT|NG_HIGHLABEL
			dc.l 0
			dc.l 0

BlueText		dc.b 'Blue:   ',0

	even
	
String			dc.b '%2ld',0

	even

SaveGadget
			dc.w 20
			dc.w 75
			dc.w 70
			dc.w 13
			dc.l SaveText
			dc.l TextAtt
			dc.w 5
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0
			
SaveText		dc.b 'Save',0

	even
				
UseGadget
			dc.w 100
			dc.w 75
			dc.w 70
			dc.w 13
			dc.l UseText
			dc.l TextAtt
			dc.w 6
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0
			
UseText			dc.b 'Use',0

	even
	
CancelGadget
			dc.w 180
			dc.w 75
			dc.w 70
			dc.w 13
			dc.l CancelText
			dc.l TextAtt
			dc.w 7
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0
			
CancelText		dc.b 'Cancel',0

	even

* Menus

Menus
			dc.b NM_TITLE
			dc.b 0
			dc.l ProjectTitle
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 0
			
			dc.b NM_ITEM
			dc.b 0
			dc.l AboutItem
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 1
						
			dc.b NM_ITEM
			dc.b 0
			dc.l SaveItem
			dc.l SaveKey
			dc.w 0
			dc.l 0
			dc.l 2
			
			dc.b NM_ITEM
			dc.b 0
			dc.l NM_BARLABEL
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 0
						
			dc.b NM_ITEM
			dc.b 0
			dc.l QuitItem
			dc.l QuitKey
			dc.w 0
			dc.l 0
			dc.l 3
												
			dc.b NM_TITLE
			dc.b 0
			dc.l EditTitle
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 0
			
			dc.b NM_ITEM
			dc.b 0
			dc.l ResetItem
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 4
			
			dc.b NM_ITEM
			dc.b 0
			dc.l RestoreItem
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 5
						
			dc.b NM_ITEM
			dc.b 0
			dc.l PresetItem
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 0
			
			dc.b NM_SUB
			dc.b 0
			dc.l TintSubItem
			dc.l TintKey
			dc.w 0
			dc.l 0
			dc.l 6
			
			dc.b NM_SUB
			dc.b 0
			dc.l PharoahSubItem
			dc.l PharoahKey
			dc.w 0
			dc.l 0
			dc.l 7
			
			dc.b NM_SUB
			dc.b 0
			dc.l SunsetSubItem
			dc.l SunsetKey
			dc.w 0
			dc.l 0
			dc.l 8
			
			dc.b NM_SUB
			dc.b 0
			dc.l OceanSubItem
			dc.l OceanKey
			dc.w 0
			dc.l 0
			dc.l 9
			
			dc.b NM_SUB
			dc.b 0
			dc.l SteelSubItem
			dc.l SteelKey
			dc.w 0
			dc.l 0
			dc.l 10
			
			dc.b NM_SUB
			dc.b 0
			dc.l ChocolateSubItem
			dc.l ChocolateKey
			dc.w 0
			dc.l 0
			dc.l 11
			
			dc.b NM_SUB
			dc.b 0
			dc.l PewterSubItem
			dc.l PewterKey
			dc.w 0
			dc.l 0
			dc.l 12
			
			dc.b NM_SUB
			dc.b 0
			dc.l WineSubItem
			dc.l WineKey
			dc.w 0
			dc.l 0
			dc.l 13			
			
			dc.b NM_SUB
			dc.b 0
			dc.l NM_BARLABEL
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 0
			
			dc.b NM_SUB
			dc.b 0
			dc.l A2024SubItem
			dc.l A2024Key
			dc.w 0
			dc.l 0
			dc.l 14
			
			dc.b NM_TITLE
			dc.b 0
			dc.l OptionTitle
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 0
			
			dc.b NM_ITEM
			dc.b 0
			dc.l SaveIconItem
			dc.l 0
			dc.w CHECKIT|MENUTOGGLE|CHECKED
			dc.l 0
			dc.l 15
						
			dc.b NM_END
			dc.b 0
			dc.l 0
			dc.l 0
			dc.w 0
			dc.l 0
			dc.l 0
			
ProjectTitle		dc.b 'Project',0
	even
AboutItem		dc.b 'About',0
	even	
SaveItem		dc.b 'Save...',0
	even	
SaveKey			dc.b 'S',0
	even	
QuitItem		dc.b 'Quit',0
	even	
QuitKey			dc.b 'Q',0
	even		
EditTitle		dc.b 'Edit',0
	even
ResetItem		dc.b 'Reset To Default',0
	even	
RestoreItem		dc.b 'Restore',0
	even	
PresetItem		dc.b 'Presets',0
	even	
TintSubItem		dc.b 'Tint',0
	even	
TintKey			dc.b '1',0
	even
PharoahSubItem		dc.b 'Pharoah',0
	even
PharoahKey		dc.b '2',0
	even
SunsetSubItem		dc.b 'Sunset',0
	even
SunsetKey		dc.b '3',0
	even
OceanSubItem		dc.b 'Ocean',0
	even
OceanKey		dc.b '4',0
	even
SteelSubItem		dc.b 'Steel',0
	even
SteelKey		dc.b '5',0
	even
ChocolateSubItem	dc.b 'Chocolate',0
	even
ChocolateKey		dc.b '6',0
	even
PewterSubItem		dc.b 'Pewter',0
	even
PewterKey		dc.b '7',0
	even
WineSubItem		dc.b 'Wine',0
	even
WineKey			dc.b '8',0
	even
A2024SubItem		dc.b 'A2024',0
	even
A2024Key		dc.b '9',0														
	even
OptionTitle		dc.b 'Options',0
	even
SaveIconItem		dc.b 'Save Icon?',0

MenuTags		dc.l GTMN_TextAttr,TextAtt
			dc.l TAG_DONE
			
			
* Icon

	include icon.i
		
********************************************************
* End of variables
********************************************************
	
	even
	
main
	Ready	Exec

	lea	DosName(pc),a1
	moveq	#37,d0				;AmigaDos 2.04 Only
	Call	OpenLibrary			;Open Dos Library
	move.l	d0,DosBase			;Save Base
	beq	Done				;If Error, Done

	suba.l	a1,a1
	Call	FindTask
	movea.l	d0,a2
	tst.l	pr_CLI(a2)
	bne	Cli				;If Cli, Cli

Workbench
	lea	pr_MsgPort(a2),a0
	Call	WaitPort			;Wait for Workbench Msg

	lea	pr_MsgPort(a2),a0
	Call	GetMsg				;Get Msg
	move.l	d0,WbMsg			;Save Msg
	move.l	d0,a2

	Ready	Dos
	move.l	sm_ArgList(a2),a2
	move.l	wa_Lock(a2),d1
	Call	CurrentDir			;Make Colours Dir Current

Cli
	Ready	Exec
	lea	GraphicsName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Graphics library
	move.l	d0,GraphicsBase			;Save Base
	beq	Done				;If error, Done

	lea	IntuiName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Intuition library
	move.l	d0,IntuitionBase		;Save Base
	beq	Done				;If error, Done

	lea	GadtoolsName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Gadtools library
	move.l	d0,GadtoolsBase			;Save Base
	beq	Done				;If error, Done

	lea	AslName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Asl library
	move.l	d0,AslBase			;Save Base
	beq	Done				;If error, Done
	
	lea	IconName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Icon library
	move.l	d0,IconBase			;Save Base
	beq	Done				;If error, Done
	
	Ready	Intuition
	lea	ScreenName(pc),a0
	Call	LockPubScreen			;Lock Workbench Screen
	move.l	d0,MyScreen			;Save Result
	beq	Done				;If error, Done
	
	move.l	d0,a0
	Call	GetScreenDrawInfo		;Get Screen Draw Info
	move.l	d0,a0
	move.l	d0,MyDrawInfo			;Save Result
	clr.l	d0
	move.w	dri_Depth(a0),d0		;Save Screen Depth in 
	move.l	d0,PaletteDepth			;PaletteDept

	move.l	MyScreen,a0
	move.l	sc_ViewPort+vp_ColorMap(a0),a0
	move.l	cm_ColorTable(a0),a0
	
	lea	RestoreColours(pc),a1
	lea	Colours(pc),a2
	move.l	#15,d0
.Loop
	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbf	d0,.Loop	
		
* Create Gadgets

	Ready	Gadtools
	move.l	MyScreen,a0
	move.l	#TAG_DONE,a1
	Call	GetVisualInfoA
	move.l	d0,VisualIn	

	clr.l	GadgetList
	lea	GadgetList(pc),a0
	Call	CreateContext
	move.l	d0,Gad

	Ready	Graphics
	move.l	MyScreen,a0
	move.l	sc_Font(a0),a0
	Call	OpenFont			;Open Screen Font
	move.l	d0,MyFont	
	beq	Done

	move.l	MyFont,a0
	move.l	WindowHeight,d0
	move.w	ZoomHeight,d1
	move.w	tf_YSize(a0),FontHeight
	add.w	tf_YSize(a0),d0
	add.w	tf_YSize(a0),d1
	move.l	d0,WindowHeight
	move.w	d1,ZoomHeight
	
	move.w	FontHeight,d3
	Ready	Gadtools
	move.l	#PALETTE_KIND,d0
	move.l	Gad,a0
	lea	PaletteGadget(pc),a1		;Palette Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	lea	PaletteTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad

	move.w	Colours,d4
	ror.l	#8,d4
	move.w	d4,d1
	move.l	d1,SliderLevel			;Save SliderLevel
	move.w	d1,Red
	
	move.l	#SLIDER_KIND,d0
	move.l	Gad,a0
	lea	RedGadget(pc),a1		;Red Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	lea	SliderTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,RGadget
	
	sub.w	d4,d4
	rol.l	#4,d4
	move.w	d4,d1
	move.l	d1,SliderLevel			;Save SliderLevel
	move.w	d1,Green
	
	move.l	#SLIDER_KIND,d0
	move.l	Gad,a0
	lea	GreenGadget(pc),a1		;Green Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	lea	SliderTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GGadget
	
	sub.w	d4,d4
	rol.l	#4,d4
	move.w	d4,d1
	move.l	d1,SliderLevel			;Save SliderLevel
	move.w	d1,Blue
	
	move.l	#SLIDER_KIND,d0
	move.l	Gad,a0
	lea	BlueGadget(pc),a1		;Blue Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	lea	SliderTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,BGadget
	

	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	SaveGadget(pc),a1		;Save Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.w	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	
	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	UseGadget(pc),a1		;Use Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.w	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	
	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	CancelGadget(pc),a1		;Cancel Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.w	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	
	Ready	Gadtools
	lea	Menus(pc),a0
	move.l	#TAG_DONE,a1
	Call	CreateMenusA			;Create Menus
	move.l	d0,MyMenus
	beq	Done
	
	move.l	d0,a0
	move.l	VisualIn,a1
	lea	MenuTags(pc),a2
	Call	LayoutMenusA			;Layout Menus
	
	Ready	Intuition
	move.l	#0,a0
	lea	WindowTags(pc),a1
	Call	OpenWindowTagList		;Open Window
	move.l	d0,MyWindow
	move.l	d0,FileReqWindow
	beq	Done
		
	move.l	d0,a0
	move.l	MyMenus,a1
	Call	SetMenuStrip			;Set MenuStrip
	
	move.l	MyWindow,a0
	move.l	GadgetList,a1
	moveq	#-1,d0
	move.l	d0,d1
	move.l	#0,a2
	Call	AddGList			;Add Gadgets

	move.l	GadgetList,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	moveq	#-1,d0
	Call	RefreshGList			;Refresh Gadgets

	Ready	Gadtools
	move.l	MyWindow,a0
	sub.l	a1,a1
	Call	GT_RefreshWindow		;Refresh Window

	move.l	MyWindow,a0
	move.l	wd_UserPort(a0),MyIDCMP

	
mainloop
	Ready	Exec
	move.l	MyIDCMP,a0
	Call	WaitPort			;Wait for Window Msg

	Ready	Gadtools
	move.l	MyIDCMP,a0
	Call	GT_GetIMsg			;Get Msg
	move.l	d0,MyMsg

	move.l	d0,a1
	move.l	im_Class(a1),Class
	move.w	im_Code(a1),Code
	move.l	im_IAddress(a1),a1
	move.w	gg_GadgetID(a1),GadgetID

	move.l	d0,a1
	Call	GT_ReplyIMsg

	move.l	Class,d0

	cmp.l	#IDCMP_GADGETUP,d0		;Gadget Msg, UseGadget
	beq	Gadgets

	cmp.l	#IDCMP_MOUSEMOVE,d0		;Gadget Msg, UseGadget
	beq	Gadgets
	
	cmp.l	#IDCMP_CLOSEWINDOW,d0		;CloseWindow Msg, Done
	bne	.1
	bsr	RestoreColour
	bra	Done
.1
	cmp.l	#IDCMP_CHANGEWINDOW,d0		;NewSize Msg, Refresh
	beq	Refresh
	
	cmp.l	#IDCMP_MENUPICK,d0		;Menu Msg, DoMenu
	beq	DoMenu
	
	bra	mainloop			;Goto mainloop


Refresh
	Ready	Gadtools
	move.l	MyWindow,a0
	Call	GT_BeginRefresh

	move.l	MyWindow,a0
	move.l	#1,d0
	Call	GT_EndRefresh

	bra	mainloop			;Goto mainloop


Gadgets

	move.w	GadgetID,d0
	
	cmp.w	#1,d0				;Palette Gadget
	bne	.1
	move.w	Code,Colour
	bsr	ReloadColour
.1	
	cmp.w	#2,d0				;Red Gadget
	beq	SetColour
	
	cmp.w	#3,d0				;Green Gadget
	beq	SetColour
	
	cmp.w	#4,d0				;Blue Gadget
	beq	SetColour
	
	cmp.w	#5,d0				;Save Gadget
	bne	.2
	bsr	SaveFile

.2
	cmp.w	#6,d0				;Use Gadget
	beq	Done
	
	cmp.w	#7,d0				;Cancel Gadget
	bne	.3
	bsr	RestoreColour
	bra	Done
.3	
	bra	mainloop


ChangeColour
	lea	Colours(pc),a0
	move.w	Colour,d0
	mulu	#2,d0
	add.w	d0,a0
	move.w	(a0),d1
	ror.l	#8,d1
	move.w	d1,Red
	sub.w	d1,d1
	rol.l	#4,d1
	move.w	d1,Green
	sub.w	d1,d1
	rol.l	#4,d1
	move.w	d1,Blue
	
	clr.l	d1
	move.w	Red,d1
	move.l	d1,SliderLevel
	
	Ready	Gadtools
	move.l	RGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	SliderTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Refresh Name Gadget
	
	clr.l	d1
	move.w	Green,d1
	move.l	d1,SliderLevel
	
	Ready	Gadtools
	move.l	GGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	SliderTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Refresh Name Gadget
	
	clr.l	d1
	move.w	Blue,d1
	move.l	d1,SliderLevel
	
	Ready	Gadtools
	move.l	BGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	SliderTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Refresh Name Gadget
	
	rts
		
	
SetColour
	lea	Colours(pc),a0
	move.w	Colour,d0
	mulu.w	#2,d0
	add.w	d0,a0
	move.w	(a0),d1

	move.w	GadgetID,d0
	cmp.w	#2,d0
	bne	.1
	move.w	Code,Red
.1
	cmp.w	#3,d0
	bne	.2
	move.w	Code,Green
.2		
	cmp.w	#4,d0
	bne	.3
	move.w	Code,Blue
.3
	move.w	Red,d1
	move.w	Green,d2
	move.w	Blue,d3
	
	rol.l	#8,d1
	rol.l	#4,d2
	eor.w	d2,d1
	eor.w	d3,d1
	move.w	d1,(a0)
	
	move.w	Red,d1
	move.w	Green,d2
	move.w	Blue,d3
	
	Ready	Graphics
	move.l	MyScreen,a0
	lea	sc_ViewPort(a0),a0
	move.w	Colour,d0
	Call	SetRGB4
	
	bra	mainloop
		
		
SaveFile
	Ready	Asl
	move.l	#0,d0
	lea	FileReqTags(pc),a0
	Call	AllocAslRequest
	move.l	d0,AslRequester
	
	move.l	AslRequester,a0
	move.l	#0,a1
	Call	AslRequest
	
	Ready	Dos
	move.l	AslRequester,a2
	move.l	rf_Dir(a2),a1
	lea	CurDir(pc),a0
.L1
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne	.L1
	move.b	#0,(a0)
	
	move.l	rf_File(a2),a1
	tst.b	(a1)
	beq	.Exit
	
	move.l	rf_Dir(a2),a1			;Tst rf_Dir
	tst.b	(a1)				;No, .FileLock
	beq	.NoDir
	
	move.l	a1,d1
	move.l	#SHARED_LOCK,d2
	Call	Lock				;Lock rf_Dir
	move.l	d0,d4
	
	move.l	d0,d1
	Call	CurrentDir			;Make Lock CurrentDir
	move.l	d0,d3

.NoDir	
	move.l	rf_File(a2),a0
	lea	FileName(pc),a1
.L2	
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne	.L2
	move.b	#0,(a1)
	
	Ready	Dos
	lea	FileName(pc),a1
	move.l	a1,d1
	move.l	#MODE_NEWFILE,d2
	Call	Open
	tst.l	d0
	bne	.File
		
	Ready	Intuition
	move.l	MyWindow,a0
	lea	OpenError(pc),a1
	move.l	#TAG_DONE,a2
	move.l	#0,a3
	Call	EasyRequestArgs			;Show Error requester
	bra	.NoCreate
		
.File
	move.l	d0,d1
	move.l	d0,d4
	lea	CodeStart(pc),a2
	move.l	a2,d2
	move.l	#CodeLen,d3
	Call	Write
	
	tst	CreateIcon
	beq	.NoIcon
	
	Ready	Icon
	lea	FileName(pc),a0
	lea	MyIcon(pc),a1
	Call	PutDiskObject
	
.NoIcon
	Ready	Dos
	move.l	d4,d1
	Call	Close

.NoCreate
	move.l	rf_Dir(a2),a1			;Tst rf_Dir
	tst.b	(a1)				;No, .Exit
	beq	.Exit
	
	move.l	d3,d1
	Call	CurrentDir			;Make Pro Dir CurrentDir
	
	move.l	d4,d1
	Call	UnLock				;UnLock File Directory

.Exit
	Ready	Asl
	move.l	AslRequester,a0
	Call	FreeAslRequest
	
	rts					;Return
		
		
DoMenu
	Ready	Intuition
	move.l	MyMenus,a0
	move.w	Code,d0
	Call	ItemAddress
	beq	.Exit
	move.l	d0,a0
	move.l	mi_NextSelect(a0),Code
	
	move.l	d0,a0
	GTMENUITEM_USERDATA a0,d1

	cmp.l	#1,d1				;About
	bne	.1
	bsr	About
.1	
	cmp.l	#2,d1				;Save
	bne	.2
	bsr	SaveFile
.2
	cmp.l	#3,d1				;Quit
	bne	.3
	bsr	RestoreColour
	bra	Done
.3
	cmp.l	#4,d1				;Reset Default
	bne	.4
	bsr	ResetColour
.4	
	cmp.l	#5,d1				;Restore Colour
	bne	.5
	bsr	RestoreColour	
.5
	cmp.l	#6,d1				;Preset Colour Tint
	bne	.6
	move.l	#0,d0
	bsr	PresetColour
.6
	cmp.l	#7,d1				;Preset Colour Paroah
	bne	.7
	move.l	#1,d0
	bsr	PresetColour
.7
	cmp.l	#8,d1				;Preset Colour Sunset
	bne	.8
	move.l	#2,d0
	bsr	PresetColour
.8
	cmp.l	#9,d1				;Preset Colour Ocean
	bne	.9
	move.l	#3,d0
	bsr	PresetColour
.9
	cmp.l	#10,d1				;Preset Colour Steel
	bne	.10
	move.l	#4,d0
	bsr	PresetColour
.10
	cmp.l	#11,d1				;Preset Colour Chocolate
	bne	.11
	move.l	#5,d0
	bsr	PresetColour
.11
	cmp.l	#12,d1				;Preset Colour Pewter
	bne	.12
	move.l	#6,d0
	bsr	PresetColour
.12
	cmp.l	#13,d1				;Preset Colour Wine
	bne	.13
	move.l	#7,d0
	bsr	PresetColour
.13
	cmp.l	#14,d1				;Preset Colour A2024
	bne	.14
	move.l	#8,d0
	bsr	PresetColour
.14
	cmp.l	#15,d1
	bne	.15
	eor.w	#1,CreateIcon
.15
	
	bra	DoMenu	
.Exit
	
	bra	mainloop


About
	Ready	Intuition
	move.l	MyWindow,a0
	lea	AboutReq(pc),a1
	move.l	#TAG_DONE,a2
	move.l	#0,a3
	Call	EasyRequestArgs			;Show About requester
					
	rts
	

ResetColour
	lea	Colours(pc),a2
	lea	DefaultColours(pc),a1

	move.l	#15,d0
.1	
	move.w	(a1)+,(a2)+
	dbf	d0,.1
	
	lea	Colours(pc),a1
	
	Ready	Graphics	
	move.l	MyScreen,a0
	lea	sc_ViewPort(a0),a0
	move.l	#16,d0
	Call	LoadRGB4
	
	bsr	ChangeColour
	
	rts
	

RestoreColour
	lea	Colours(pc),a2	
	lea	RestoreColours(pc),a1
	
	move.l	#15,d0
.1	
	move.w	(a1)+,(a2)+
	dbf	d0,.1
	
	lea	Colours(pc),a1
		
	Ready	Graphics	
	move.l	MyScreen,a0
	lea	sc_ViewPort(a0),a0
	move.l	#16,d0
	Call	LoadRGB4
	
	bsr	ChangeColour
	
	rts
	
	
PresetColour
	lea	Colours(pc),a2
	lea	PresetColours(pc),a1
	mulu	#8,d0
	add	d0,a1
	
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	sub	#8,a1
	
	Ready	Graphics
	move.l	MyScreen,a0
	lea	sc_ViewPort(a0),a0
	move.w	#4,d0
	Call	LoadRGB4
	
	bsr	ChangeColour
	rts


ReloadColour
	move.l	MyScreen,a0
	move.l	sc_ViewPort+vp_ColorMap(a0),a1
	move.l	cm_ColorTable(a1),a1

	lea	Colours(pc),a2
	
	move.l	#15,d1
.1	
	move.w	(a1)+,(a2)+
	dbf	d1,.1
	
	bsr	ChangeColour
	
	rts
	

Done
	tst.l	MyWindow			;Tst MyWindow
	beq	.1				;No, .1
	Ready	Intuition
	move.l	MyWindow,a0
	Call	ClearMenuStrip			;Clear MenuStrip
.1	
	tst.l	MyWindow			;Tst MyWindow
	beq	.2				;No, .2
	move.l	MyWindow,a0
	Call	CloseWindow			;CloseWindow
.2
	tst.l	MyMenus				;Tst Menu
	beq	.3				;No, .3
	Ready	Gadtools
	move.l	MyMenus,a0
	Call	FreeMenus			;Free Menus
.3	
	tst.l	VisualIn			;Tst VisualIn
	beq	.4				;No, .4
	Ready	Gadtools
	move.l	VisualIn,a0
	Call	FreeVisualInfo			;FreeVisualInfo
.4
	tst.l	GadgetList			;Tst GadgetList
	beq	.5				;No, .5
	Ready	Gadtools
	move.l	GadgetList,a0
	Call	FreeGadgets
.5
	tst.l	MyFont				;Tst MyFont
	beq	.6				;No, .6
	Ready	Graphics
	move.l	MyFont,a1
	Call	CloseFont			;CloseFont
.6
	tst.l	MyDrawInfo			;Tst MyDrawInfo
	beq	.7				;No, .7
	Ready	Intuition
	move.l	MyScreen,a0
	move.l	MyDrawInfo,a1
	Call	FreeScreenDrawInfo		;Free Screen Draw Info
.7
	tst.l	MyScreen			;Tst MyScreen
	beq	.8				;No, .8
	Ready	Intuition
	move.l	#0,a0
	move.l	MyScreen,a1
	Call	UnlockPubScreen			;UnLock Workbench Screen
.8
	tst.l	AslBase				;Tst AslBase
	beq	.9				;No, .9
	Ready	Exec
	move.l	AslBase,a1
	Call	CloseLibrary			;CloseLibrary
.9
	tst.l	IconBase			;Tst IconBase
	beq	.10				;No, .10
	Ready	Exec
	move.l	IconBase,a1
	Call	CloseLibrary			;CloseLibrary
.10
	tst.l	GadtoolsBase			;Tst GadtoolsBase
	beq	.11				;No, .11
	Ready	Exec
	move.l	GadtoolsBase,a1
	Call	CloseLibrary			;CloseLibrary
.11
	tst.l	IntuitionBase			;Tst IntuitionBase
	beq	.12				;No, .12
	move.l	IntuitionBase,a1
	Call	CloseLibrary			;CloseLibrary
.12
	tst.l	GraphicsBase			;Tst GraphicsBase
	beq	.13				;No, .13
	move.l	GraphicsBase,a1
	Call	CloseLibrary			;CloseLibrary
.13
	tst.l	DosBase				;Tst DosBase
	beq	.14				;No, .14
	move.l	DosBase,a1
	Call	CloseLibrary			;CloseLibrary
.14
	tst.l	WbMsg				;Tst WbMsg
	beq	.15				;No, .15
	Call	Forbid
	move.l	WbMsg,a1
	Call	ReplyMsg			;Reply Msg to Workbench
.15
	clr.l	d0				;Clear d0
	rts					;Return

************************************************
* Code written to file
************************************************

CodeStart		
HeaderHunk		dc.l $000003F3
			dc.l $00000000
			dc.l $00000001
			dc.l $00000000
			dc.l $00000000
			dc.l $00000055			
			dc.l $000003E9
			dc.l $00000055

	bra Start
	
GBase			dc.l 0
IBase			dc.l 0

MScreen			dc.l 0
MMsg			dc.l 0
Colours			ds.w 16

GName			dc.b 'graphics.library',0
	even
IName			dc.b 'intuition.library',0
	even
SName			dc.b 'Workbench',0

	even
	
Start
	move.l	$4.w,a6
	
	suba.l	a1,a1
	Call	FindTask
	movea.l	d0,a2
	tst.l	pr_CLI(a2)
	bne	FromCli
	
FromWorkBench
	lea	pr_MsgPort(a2),a0
	Call	WaitPort
	
	lea	pr_MsgPort(a2),a0
	Call	GetMsg 
	move.l	d0,$10.l
	
FromCli
	lea	GName(pc),a1
	moveq	#37,d0
	Call	OpenLibrary
	move.l	d0,4.l
	beq	exit
	
	lea	IName(pc),a1
	moveq	#37,d0
	Call	OpenLibrary
	move.l	d0,8.l
	beq	exit
	
	move.l	8.l,a6
	lea	SName(pc),a0
	Call	LockPubScreen
	move.l	d0,$c.l
	beq	exit
	
	move.l	4.l,a6
	move.l	d0,a0
	lea	sc_ViewPort(a0),a0
	lea	Colours(pc),a1
	move.l	#16,d0
	Call	LoadRGB4

exit	
	tst.l	$c.l
	beq	.1
	move.l	8.l,a6
	move.l	#0,a0
	move.l	$c.l,a1
	Call	UnlockPubScreen
.1
	tst.l	8.l
	beq	.2
	move.l	$4.w,a6
	move.l	8.l,a1
	Call	CloseLibrary
.2	
	tst.l	4.l
	beq	.3
	move.l	$4.w,a6
	move.l	4.l,a1
	Call	CloseLibrary
.3
	tst.l	$10.l
	beq	.4
	Call	Forbid
	move.l	$10.l,a1
	Call	ReplyMsg
.4
	clr.l	d0
	rts
	
EndHunk			dc.w $0000
			dc.l $000003EC
			dc.l $0000000F
			dc.l $00000000
			dc.l $00000088 
			dc.l $00000098 
			dc.l $000000AC 
			dc.l $000000B6
			dc.l $000000C4 
			dc.l $000000CE 
			dc.l $000000E8 
			dc.l $000000F2
			dc.l $000000FE 
			dc.l $00000108 
			dc.l $00000116 
			dc.l $00000120
			dc.l $0000012E 
			dc.l $00000138 
			dc.l $00000146 
			dc.l $00000000
			dc.l $000003F2
			
CodeLen			=*-CodeStart
	End
