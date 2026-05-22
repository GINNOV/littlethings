*************************************************************************
*									*
*	A program to change the protection bits of a file, and comment	*
*                                                                       *
*	(C) 1992 Tom Champion						*
*                                                                       *
*	Name - Pro.asm							*
*									*
*	For use with AmigaDos 2.04 only.				*
*									*
*	Assembled with Devpac 3						*
*									*
*************************************************************************

	opt 	ow-, o+

	incdir	sys:include2.0/
	include exec/types.i
	include exec/exec_lib.i
	include exec/memory.i
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

AslBase			dc.l 0
DosBase			dc.l 0
GraphicsBase		dc.l 0
GadtoolsBase		dc.l 0

FileName		ds.b 80
CurDir			ds.b 80
Comment			ds.b 80
Multi			dc.l 0
Number			dc.l 1
Protection		dc.l $F0
OldDir			dc.l 0
FileInfo		dc.l 0
VisualIn		dc.l 0
Gad			dc.l 0
GadgetList		dc.l 0
NameGadget		dc.l 0
CommentGadget		dc.l 0
NextGadget		dc.l 0
PrevGadget		dc.l 0
SaveGadget		dc.l 0
MyFont			dc.l 0
FontHeight		dc.w 0
WbMsg			dc.l 0
MyMsg			dc.l 0
Class			dc.l 0
GadgetID		dc.w 0
IAddress		dc.l 0
MyIDCMP			dc.l 0
MyWindow		dc.l 0
AslRequester		dc.l 0

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
ScreenName		dc.b 'Workbench',0
	even
SaveTitle		dc.b 'Saving...',0
	even
ErrorName		dc.b 'Error!  File Not Saved',0

	even
	
GadgetTable
			dc.l 0
			dc.l 0
			dc.l 0
			dc.l 0
			dc.l 0
			dc.l 0
			dc.l 0
			dc.l 0
			
ZoomSize		dc.w 170,0,110
ZoomHeight		dc.w 3

WindowTags
			dc.l WA_Left,80
			dc.l WA_Top,30
			dc.l WA_Width,500
			dc.l WA_Height
WindowHeight		dc.l 105
			dc.l WA_DetailPen,0
			dc.l WA_BlockPen,1
			dc.l WA_IDCMP,IDCMP_CLOSEWINDOW+IDCMP_GADGETUP+IDCMP_NEWSIZE
			dc.l WA_Activate,1
			dc.l WA_DepthGadget,1
			dc.l WA_DragBar,1
			dc.l WA_CloseGadget,1
			dc.l WA_RMBTrap,1
			dc.l WA_Title,WindowTitle
			dc.l WA_SmartRefresh,1
			dc.l WA_NoCareRefresh,1
			dc.l WA_Zoom,ZoomSize
			dc.l WA_PubScreen
MyScreen		dc.l 0
			dc.l TAG_DONE
			
WindowTitle		dc.b 'Pro (C) 1992 Tom Champion',0

TextAtt
			dc.l FontName
			dc.w 8
			dc.b 0
			dc.b 0

FontName		dc.b 'topaz.font',0

	even
	
FileReqTags		dc.l ASL_Window
FileReqWindow		dc.l 0
			dc.l ASL_Hail,FileReqText
			dc.l ASL_LeftEdge,100
			dc.l ASL_TopEdge,40
			dc.l ASL_Width,200
			dc.l ASL_Height,160
			dc.l ASL_Dir,CurDir
			dc.l TAG_DONE

FileReqText		dc.b 'Load File',0
	
	even

NoFileError		dc.l es_SIZEOF
			dc.l 0
			dc.l NoFileTitle
			dc.l NoFileText
			dc.l NoFileGadget

NoFileTitle		dc.b 'Error!',0
	even
NoFileText		dc.b ' No File Found ',0
	even
NoFileGadget		dc.b 'Continue',0

	even

Gadget1
			dc.w 80
			dc.w 7
			dc.w 380
			dc.w 15
			dc.l GadgetText1
			dc.l TextAtt
			dc.w 1
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText1		dc.b 'Name',0

	even
	
NameTags		dc.l GTTX_Text,FileName
			dc.l GTTX_Border,1
			dc.l TAG_DONE
	
Gadget2
			dc.w 80
			dc.w 27
			dc.w 380
			dc.w 14
			dc.l GadgetText2
			dc.l TextAtt
			dc.w 2
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText2		dc.b 'Comment',0

	even

CommentTags		dc.l GTST_String,Comment
			dc.l GTST_MaxChars,79
			dc.l GTBB_Recessed,1
			dc.l TAG_DONE
			
Gadget3
			dc.w 90
			dc.w 47
			dc.w 0
			dc.w 0
			dc.l GadgetText3
			dc.l TextAtt
			dc.w 10
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText3		dc.b 'Hidden',0

	even
	
Gadget4
			dc.w 200
			dc.w 47
			dc.w 0
			dc.w 0
			dc.l GadgetText4
			dc.l TextAtt
			dc.w 9
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText4		dc.b 'Script',0

	even
	
Gadget5
			dc.w 330
			dc.w 47
			dc.w 0
			dc.w 0
			dc.l GadgetText5
			dc.l TextAtt
			dc.w 8
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText5		dc.b 'Pure',0

	even
	
Gadget6
			dc.w 450
			dc.w 47
			dc.w 0
			dc.w 0
			dc.l GadgetText6
			dc.l TextAtt
			dc.w 7
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText6		dc.b 'Archived',0

	even
	
Gadget7
			dc.w 90
			dc.w 62
			dc.w 0
			dc.w 0
			dc.l GadgetText7
			dc.l TextAtt
			dc.w 6
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText7		dc.b 'Readable',0

	even
	
Gadget8
			dc.w 200
			dc.w 62
			dc.w 0
			dc.w 0
			dc.l GadgetText8
			dc.l TextAtt
			dc.w 5
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText8		dc.b 'Writable',0

	even
	
Gadget9
			dc.w 330
			dc.w 62
			dc.w 0
			dc.w 0
			dc.l GadgetText9
			dc.l TextAtt
			dc.w 4
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText9		dc.b 'Executable',0

	even
	
Gadget10
			dc.w 450
			dc.w 62
			dc.w 0
			dc.w 0
			dc.l GadgetText10
			dc.l TextAtt
			dc.w 3
			dc.l PLACETEXT_LEFT
			dc.l 0
			dc.l 0

GadgetText10		dc.b 'Deletable',0

	even
	
Gadget11
			dc.w 35
			dc.w 82
			dc.w 70
			dc.w 14
			dc.l GadgetText11
			dc.l TextAtt
			dc.w 11
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0

GadgetText11		dc.b 'Next',0

	even
	
Gadget12
			dc.w 125
			dc.w 82
			dc.w 70
			dc.w 14
			dc.l GadgetText12
			dc.l TextAtt
			dc.w 12
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0

GadgetText12		dc.b 'Prev',0

	even
	
Gadget13
			dc.w 215
			dc.w 82			
			dc.w 70
			dc.w 14
			dc.l GadgetText13
			dc.l TextAtt
			dc.w 13
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0

GadgetText13		dc.b 'Load',0

	even
	
Gadget14
			dc.w 305
			dc.w 82
			dc.w 70
			dc.w 14
			dc.l GadgetText14
			dc.l TextAtt
			dc.w 14
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0

GadgetText14		dc.b 'Save',0

	even
	
Gadget15
			dc.w 395
			dc.w 82
			dc.w 70
			dc.w 14
			dc.l GadgetText15
			dc.l TextAtt
			dc.w 15
			dc.l PLACETEXT_IN
			dc.l 0
			dc.l 0

GadgetText15		dc.b 'Quit',0

	even
	
DisableTags		dc.l GA_Disabled,1
			dc.l TAG_DONE
			
EnableTags		dc.l GA_Disabled,0
			dc.l TAG_DONE
	
CheckedTags		dc.l GTCB_Checked,1
			dc.l TAG_DONE
			
NoCheckedTags		dc.l GTCB_Checked,0
			dc.l TAG_DONE
			
	even
	
main
	Ready	Exec
	lea	DosName(pc),a1
	moveq	#37,d0
	Call	OpenLibrary			;Open Dos Library
	move.l	d0,DosBase			;Save Base
	beq	done				;If Error, done

	suba.l	a1,a1
	Call	FindTask
	movea.l	d0,a2
	tst.l	pr_CLI(a2)
	bne	Cli				;If Cli, Cli

WorkBench
	lea	pr_MsgPort(a2),a0
	Call	WaitPort			;Wait for Workbench Msg

	lea	pr_MsgPort(a2),a0
	Call	GetMsg				;Get Msg
	move.l	d0,WbMsg			;Save Msg
	move.l	d0,a2

	Ready	Dos
	move.l	sm_ArgList(a2),a2
	move.l	wa_Lock(a2),d1
	move.l	d1,OldDir
	Call	CurrentDir			;Make Pro Dir Current

	move.l	WbMsg,a2
	move.l	sm_NumArgs(a2),a0
	cmp.l	#2,a0				;If sn_NumArgs > 2 then
	ble	Cli				; set Multi to 1
	move.l	#1,Multi

Cli
	Ready	Exec
	lea	GraphicsName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Graphics library
	move.l	d0,GraphicsBase			;Save Base
	beq	done				;If error, done

	lea	IntuiName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Intuition library
	move.l	d0,IntuitionBase		;Save Base
	beq	done				;If error, done

	lea	GadtoolsName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Gadtools library
	move.l	d0,GadtoolsBase			;Save Base
	beq	done				;If error, done

	lea	AslName(pc),a1
	moveq	#37,d0				;AmigaDos2.04
	Call	OpenLibrary			;Open Asl library
	move.l	d0,AslBase			;Save Base
	beq	done				;If error, done
	
	Ready	Intuition
	lea	ScreenName(pc),a0
	Call	LockPubScreen			;Lock Workbench Screen
	move.l	d0,MyScreen			;Save Result
	beq	done				;If error, done
	
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
	beq	done

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
	move.l	#TEXT_KIND,d0
	move.l	Gad,a0
	lea	Gadget1(pc),a1			;Name Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	lea	NameTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,NameGadget
	
	move.l	#STRING_KIND,d0
	move.l	Gad,a0
	lea	Gadget2(pc),a1			;Comment Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	lea	CommentTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,CommentGadget
	
	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0	
	lea	Gadget10(pc),a1			;Deletable Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable

	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0
	lea	Gadget9(pc),a1			;Executable Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable+4
	
	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0
	lea	Gadget8(pc),a1			;Writable Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable+8
	
	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0
	lea	Gadget7(pc),a1			;Readable Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable+12
	
	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0
	lea	Gadget6(pc),a1			;Archived Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable+16
	
	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0
	lea	Gadget5(pc),a1			;Pure Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable+20
	
	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0
	lea	Gadget4(pc),a1			;Script Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable+24
			
	move.l	#CHECKBOX_KIND,d0
	move.l	Gad,a0
	lea	Gadget3(pc),a1			;Hidden Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,GadgetTable+28
	
	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	Gadget11(pc),a1			;Next Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	cmp.l	#1,Multi
	bne	.L1
	lea	EnableTags(pc),a2
	bra	.L2
.L1	
	lea	DisableTags(pc),a2
.L2	
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,NextGadget
	
	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	Gadget12(pc),a1			;Prev Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	cmp.l	#1,Multi
	lea	DisableTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,PrevGadget
	
	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	Gadget13(pc),a1			;Load Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
	
	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	Gadget14(pc),a1			;Save Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	lea	DisableTags(pc),a2
	Call	CreateGadgetA
	move.l	d0,Gad
	move.l	d0,SaveGadget
	
	move.l	#BUTTON_KIND,d0
	move.l	Gad,a0
	lea	Gadget15(pc),a1			;Quit Gadget
	move.l	VisualIn,gng_VisualInfo(a1)
	add.w	d3,gng_TopEdge(a1)
	move.l	#TAG_DONE,a2
	Call	CreateGadgetA
	move.l	d0,Gad
					
	Ready	Intuition
	move.l	#0,a0
	lea	WindowTags(pc),a1
	Call	OpenWindowTagList		;Open Window
	move.l	d0,MyWindow
	move.l	d0,FileReqWindow
	beq	done
		
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

	Ready	Intuition
	move.l	#0,a0
	move.l	MyScreen,a1
	Call	UnlockPubScreen			;UnLock Workbench Screen

	tst.l	WbMsg
	beq	.1
	
	move.l	WbMsg,a0
	move.l	sm_NumArgs(a0),d0
	cmp.l	#2,d0
	blt	.1
	bsr	GetWFile
.1	
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
	move.l	im_IAddress(a1),IAddress
	move.l	im_IAddress(a1),a1
	move.w	gg_GadgetID(a1),GadgetID

	move.l	d0,a1
	Call	GT_ReplyIMsg

	move.l	Class,d0

	cmp.l	#IDCMP_GADGETUP,d0		;Gadget Msg, UseGadget
	beq	UseGadget

	cmp.l	#IDCMP_CLOSEWINDOW,d0		;CloseWindow Msg, done
	beq	done

	cmp.l	#IDCMP_NEWSIZE,d0		;NewSize Msg, Refresh
	beq	Refresh
	
	bra	mainloop			;Goto mainloop


Refresh
	Ready	Gadtools
	move.l	NameGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	NameTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Refresh Name Gadget
	
	bra	mainloop			;Goto mainloop


UseGadget
	move.w	GadgetID,d0
	
	cmp.w	#2,d0
	beq	SetComment			;Comment Gadget
	
	cmp.w	#11,d0
	beq	Next				;Next Gadget
	
	cmp.w	#12,d0
	beq	Prev				;Prev Gadget
	
	cmp.w	#13,d0
	beq	Load				;Load Gadget
	
	cmp.w	#14,d0
	beq	Save				;Save Gadget
	
	cmp.w	#15,d0
	beq	done				;Quit Gadget
	
	sub.w	#3,d0
	move.l	Protection,d1			;Protection Gadgets
	bchg	d0,d1				;Change Bits
	move.l	d1,Protection			
	bra	mainloop			;Goto mainloop


SetComment
	move.l	IAddress,a2
	move.l	gg_SpecialInfo(a2),a2
	move.l	si_Buffer(a2),a2
	lea	Comment(pc),a1
.Loop
	move.b	(a2)+,(a1)+			;Copy String buffer to		
	tst.b	(a2)				;Comment
	bne	.Loop
	move.b	#0,(a1)
	bra	mainloop		


Next
	Ready	Gadtools
	move.l	WbMsg,a2
	move.l	sm_NumArgs(a2),d0
	addq.l	#1,Number
	sub.l	#1,d0
	cmp.l	Number,d0
	bne.	.E1
	
	move.l	PrevGadget,a0			;If Number = d0
	move.l	MyWindow,a1			;Enable Prev Gadget
	sub.l	a2,a2
	lea	EnableTags(pc),a3
	Call	GT_SetGadgetAttrsA	
	
	move.l	NextGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	DisableTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Disable Next Gadget
.E1
	move.l	PrevGadget,a0			;If Number != d0
	move.l	MyWindow,a1			;Enable Prev Gadget
	sub.l	a2,a2
	lea	EnableTags(pc),a3
	Call	GT_SetGadgetAttrsA	

	bsr	GetWFile			;Load File
	bra	mainloop			;Goto mainloop

	
Prev
	Ready	Gadtools
	sub.l	#1,Number
	cmp.l	#1,Number
	bne	.E1
	
	move.l	NextGadget,a0			;If number = 1
	move.l	MyWindow,a1			;Enable Next Gadget
	sub.l	a2,a2
	lea	EnableTags(pc),a3
	Call	GT_SetGadgetAttrsA	
	
	move.l	PrevGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	DisableTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Disable Prev Gadget
.E1
	move.l	NextGadget,a0			;If Number > 1
	move.l	MyWindow,a1			;Enable Next Gadget
	sub.l	a2,a2
	lea	EnableTags(pc),a3
	Call	GT_SetGadgetAttrsA	

	bsr	GetWFile			;Load File
	bra	mainloop			;Goto mainloop

	
Load
	Ready	Asl
	move.l	#0,d0
	lea	FileReqTags(pc),a0
	Call	AllocAslRequest
	move.l	d0,AslRequester

	move.l	AslRequester,a0
	move.l	#0,a1
	Call	AslRequest			;Bring up Asl Requester

	Ready	Dos
	move.l	AslRequester,a2	
	move.l	rf_Dir(a2),a1
	lea	CurDir(pc),a0
.L1
	move.b	(a1)+,(a0)+			;Copy rf_Dir to CurDir
	tst.b	(a1)
	bne	.L1
	move.b	#0,(a0)
	
	move.l	rf_File(a2),a1			;Tst rf_File
	tst.b	(a1)				;No, Exit
	beq	.Exit
	
	move.l	rf_Dir(a2),a1			;Tst rf_Dir
	tst.b	(a1)				;No, .FileLock
	beq	.FileLock
	
	move.l	a1,d1
	move.l	#SHARED_LOCK,d2
	Call	Lock				;Lock rf_Dir
	move.l	d0,d4
	
	move.l	d0,d1
	Call	CurrentDir			;Make Lock CurrentDir
	move.l	d0,d3

.FileLock	
	move.l	rf_File(a2),a1
	move.l	a1,d1
	move.l	#SHARED_LOCK,d2
	Call	Lock				;Lock rf_File
	bne	.Loop				;If no error, .Loop
	
	Ready	Intuition
	move.l	MyWindow,a0
	lea	NoFileError(pc),a1
	move.l	#TAG_DONE,a2
	move.l	#0,a3
	Call	EasyRequestArgs			;Show Error requester
	bra	.Done
.Loop
	move.l	d0,d1
	Call	UnLock				;UnLock File

	Ready	Gadtools
	move.l	NextGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	DisableTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Disable Next Gadet
	
	move.l	PrevGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	DisableTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Disable Prev Gadget
		
	move.l	AslRequester,a2
	move.l	rf_File(a2),a0
	lea	FileName(pc),a1
	
	movem.l	d3-d4/a2,-(sp)
	bsr	GetFile				;Load File routine
	movem.l	(sp)+,d3-d4/a2
.Done
	move.l	rf_Dir(a2),a1			;Tst rf_Dir
	tst.b	(a1)				;No, .Exit
	beq	.Exit
	
	Ready	Dos
	move.l	d3,d1
	Call	CurrentDir			;Make Pro Dir CurrentDir
	
	move.l	d4,d1
	Call	UnLock				;UnLock File Directory

.Exit	
	Ready	Asl
	move.l	AslRequester,a0
	Call	FreeAslRequest
	
	bra	mainloop			;Goto mainloop
		

Save
	Ready	Intuition
	move.l	MyWindow,a0
	lea	SaveTitle(pc),a1
	move.l	#-1,a2
	Call	SetWindowTitles			;Set Window Title to Saving..
	
	Ready	Dos
	lea	CurDir(pc),a1
	tst.b	(a1)				;Tst CurDir
	beq	.NoDir				;No, .NoDir
	
	move.l	a1,d1
	move.l	#SHARED_LOCK,d2
	Call	Lock				;Lock File Directory
	move.l	d0,d3
	
	move.l	d0,d1
	Call	CurrentDir			;Make File Dir CurrentDir
	move.l	d0,d4
	
.NoDir
	lea	FileName(pc),a1
	move.l	a1,d1
	move.l	Protection,d2
	Call	SetProtection			;Set File Protection
	beq	.Error				;If error, .Error
	
	move.l	Comment,a1
	tst.b	(a1)				;Tst Comment
	beq	.Exit				;No, .Exit

	lea	FileName(pc),a1
	move.l	a1,d1
	lea	Comment(pc),a2
	move.l	a2,d2
	Call	SetComment			;Set File Comment
	beq	.Error				;If error, .Error
	bra	.Exit				;Goto .Exit
	
.Error
	Ready	Intuition
	move.l	MyWindow,a0
	lea	ErrorName(pc),a1
	move.l	#-1,a2
	Call	SetWindowTitles			;Set Window Title to 
						;Error! File Not Saved	
	Ready	Dos
	move.l	#60,d1
	Call	Delay				;Delay for 1 second
		
.Exit
	Ready	Dos
	move.l	CurDir,a1
	tst.b	(a1)				;Tst CurDir
	beq	.NoDir1				;No, .NoDir
		
	move.l	d4,d1
	Call	CurrentDir			;Make Pro Dir CurrentDir
	
	move.l	d3,d1
	Call	UnLock				;UnLock File Directory
.NoDir1	
	move.l	#30,d1
	Call	Delay				;Delay for 1/2 a second
	
	Ready	Intuition
	move.l	MyWindow,a0
	lea	WindowTitle(pc),a1
	move.l	#-1,a2
	Call	SetWindowTitles			;Set Window Title to WindowTitle
	
	bra	mainloop			;Goto mainloop
		
		
GetFile
	Ready	Exec
	movem.l	a0-a1,-(sp)
	move.l	#fib_SIZEOF,d0
	move.l	#MEMF_ANY,d1
	Call	AllocMem			;Alloc memory for FileInfoBlock
	movem.l (sp)+,a0-a1
	move.l	d0,FileInfo
	beq	.UnMem				;If Error, .UnMem
	
.Loop1
	move.b	(a0)+,(a1)+			;Copy File Name to FileName
	tst.b	(a0)
	bne	.Loop1
	move.b	#0,(a1)
	
	Ready	Dos
	lea	FileName(pc),a1
	move.l	a1,d1
	move.l	#SHARED_LOCK,d2
	Call	Lock				;Lock FileName
	move.l	d0,d3
	beq	.UnMem				;If error, .UnMem
	
	move.l	d0,d1
	move.l	FileInfo,d2
	Call	Examine				;Examine FileName

	move.l	FileInfo,a2
	move.l	fib_Protection(a2),Protection	
	lea	fib_Comment(a2),a0
	lea	Comment(pc),a1
	
.Loop
	move.b	(a0)+,(a1)+			;Copy fib_Comment to Comment
	tst.b	(a0)
	bne	.Loop
	move.b	#0,(a1)

	Ready	Gadtools
	move.l	CommentGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	CommentTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Refresh Comment Gadget
		
	Ready	Gadtools
	move.l	NameGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	NameTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Refresh Name Gadget
	
	move.l	SaveGadget,a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	EnableTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Enable Save Gadget
		
	Ready	Dos
	move.l	d3,d1
	Call	UnLock				;UnLock File

	bsr	SetAttr				;Set Protection Gadgets
.UnMem
	Ready	Exec
	move.l	FileInfo,a1
	move.l	#fib_SIZEOF,d0
	Call	FreeMem				;FreeMem 
	rts


GetWFile
	Ready	Dos
	move.l	WbMsg,a2
	move.l	sm_ArgList(a2),a2
	move.l	Number,d0
	mulu	#wa_SIZEOF,d0
	add.l	d0,a2
	move.l	wa_Lock(a2),d1
	Call	CurrentDir			;Make File Dir CurrentDir
	move.l	d0,d1
	
	move.l	wa_Name(a2),a0
	lea	FileName(pc),a1
	
	bsr	GetFile				;Load File routine
	rts					;Return
		
		
SetAttr
	Ready	Gadtools
	move.l	#4,d3
	move.l	Protection,d4
	lea	GadgetTable(pc),a4
.Loop
	cmp.l	#0,d3
	beq	.S
	btst	#0,d4				;Tst bit 0 of Protection
	beq	.P1				;Yes, .P1

	move.l	(a4),a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	NoCheckedTags(pc),a3
	Call	GT_SetGadgetAttrsA		;UnCheck Gadget
	ror.l	#1,d4
	sub.l	#1,d3
	addq	#4,a4
	bra	.Loop
.P1	
	move.l	(a4),a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	CheckedTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Check Gadget
	ror.l	#1,d4
	sub.l	#1,d3	
	addq	#4,a4
	bra	.Loop

.S
	move.l	#4,d3
.Loop1
	cmp.l	#0,d3
	beq	.Exit
	btst	#0,d4				;Tst bit 0 of Protection
	bne	.P2				;No, .P2

	move.l	(a4),a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	NoCheckedTags(pc),a3
	Call	GT_SetGadgetAttrsA		;UnCheck Gadget
	ror.l	#1,d4
	sub.l	#1,d3
	addq	#4,a4
	bra	.Loop1
.P2
	move.l	(a4),a0
	move.l	MyWindow,a1
	sub.l	a2,a2
	lea	CheckedTags(pc),a3
	Call	GT_SetGadgetAttrsA		;Check Gadget
	ror.l	#1,d4
	sub.l	#1,d3	
	addq	#4,a4
	bra	.Loop1
		
.Exit
	rts
		
		
done
	tst.l	MyWindow			;Tst MyWindow
	beq	.1				;No, .4
	Ready	Intuition
	move.l	MyWindow,a0
	Call	CloseWindow			;CloseWindow
.1	
	tst.l	VisualIn			;Tst VisualIn
	beq	.2				;No, .2
	Ready	Gadtools
	move.l	VisualIn,a0
	Call	FreeVisualInfo			;FreeVisualInfo
.2
	tst.l	GadgetList			;Tst GadgetList
	beq	.3				;No, .3
	Ready	Gadtools
	move.l	GadgetList,a0
	Call	FreeGadgets
.3
	tst.l	MyFont				;Tst MyFont
	beq	.4				;No, .4
	Ready	Graphics
	move.l	MyFont,a1
	Call	CloseFont			;CloseFont
.4
	tst.l	AslBase				;Tst AslBase
	beq	.5				;No, .5
	Ready	Exec
	move.l	AslBase,a1
	Call	CloseLibrary			;CloseLibrary
.5	
	tst.l	GadtoolsBase			;Tst GadtoolsBase
	beq	.6				;No, .6
	Ready	Exec
	move.l	GadtoolsBase,a1
	Call	CloseLibrary			;CloseLibrary
.6
	tst.l	IntuitionBase			;Tst IntuitionBase
	beq	.7				;No, .7
	move.l	IntuitionBase,a1
	Call	CloseLibrary			;CloseLibrary
.7
	tst.l	GraphicsBase			;Tst GraphicsBase
	beq	.8				;No, .8
	move.l	GraphicsBase,a1
	Call	CloseLibrary			;CloseLibrary
.8
	tst.l	DosBase				;Tst DosBase
	beq	.9				;No, .9
	move.l	DosBase,a1
	Call	CloseLibrary			;CloseLibrary
.9
	tst.l	WbMsg				;Tst WbMsg
	beq	.10				;No, .10
	Call	Forbid
	move.l	WbMsg,a1
	Call	ReplyMsg			;Reply Msg to Workbench
.10
	clr.l	d0				;Clear d0
	rts					;Return

	End


