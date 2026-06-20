;***********************************************************
;
;	Mutual Exclude Gadget Demo By S Marshall
;
;			 13/12/90
;
;	           Compiles with Devpac V2
;	
;***********************************************************

	INCDIR	 	"SYS:INCLUDE/"
	INCLUDE 	Intuition/Intuition.i
	INCLUDE 	Intuition/Intuition_lib.i
 	INCLUDE 	Exec/Exec_lib.i
 	INCLUDE		libraries/dosextens.i
		
NULL		EQU	0

;*****************************************

CALLSYS    MACRO
	IFGT	NARG-1         
	FAIL	!!!           
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
;*****************************************

	clr.l		returnMsg
	sub.l		a1,a1			;clear a1
	CALLEXEC	FindTask		;find task - us
	move.l		d0,a4			;process in a4

	tst.l		pr_CLI(a4)		;test if from CLI
	beq.s		Workbench		;branch if from workbench
	
	bra.s		end_startup		;and run the user prog

Workbench
	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	CALLSYS		WaitPort		;wait for workbench message
	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	CALLSYS		GetMsg			;get workbench message
	move.l		d0,returnMsg		;save it for later reply

end_startup
	bsr.s		_main			;call our program

	tst.l		returnMsg		;test if from workbench
	beq.s		exitToDOS		;if I was a CLI

	CALLEXEC	Forbid			;forbid multitasking
	move.l		returnMsg,a1		;get workbench message
	CALLSYS		ReplyMsg		;reply workbench message

exitToDOS
	moveq		#0,d0			;flag no error
	rts					;Quit our program

_main	
  	moveq		#0,d0			;clear d0 (any lib version)
  	lea		Intname(pc),a1		;lib name in a1
  	CALLSYS		OpenLibrary		;try to open library
  	move.l		d0,_IntuitionBase	;store lib base
  	beq		IntError		;cleanup and quit if fail
  	
;------ open a window 
  	lea 		AsmWindowStructure,a0	;get NewWindow
  	CALLINT		OpenWindow		;and open it
  	move.l 		d0,WindowPtr		;store pointer
  	beq 		WdwError		;branch if error
  	
  	move.l 		d0,a0			;window to a0
  	move.l		wd_RPort(a0),a0		;get rastport
  	lea		IntuiTextList1,a1	;get intuitext list
  	moveq		#0,d0			;x pos offset
  	moveq		#0,d1			;y pos offset
  	CALLSYS		PrintIText		;print text
  	
  	
  	
;------ wait for an Intuition message
Loop:
  	move.l 		WindowPtr,a0
  	move.l 		wd_UserPort(a0),a0
  	move.l 		a0,MPort
 	CALLEXEC 	WaitPort
 	
;------ get the message
  	move.l 		MPort,a0
  	CALLSYS		GetMsg
  	tst 		d0
  	beq.s 		Loop 

;------ store message 
  	move.l 		d0,a1
  	move.l 		a1,Message
  	
;------ test for message type and act accordingly
  	move.l 		im_Class(a1),d1
  	cmp.l 		#CLOSEWINDOW,d1
  	beq.s	 	KillWindow
	cmp.l		#GADGETDOWN,d1
  	beq.s		GadgetDown
  	cmp.l		#GADGETUP,d1
  	bne.s		NotGadget

GadgetDown:
	move.l 		im_IAddress(A1),A0
	move.l		gg_UserData(A0),A0
	jsr		(A0)			;jump to gadget function

NotGadget:
  	move.l 		Message,a1		;get message
  	CALLEXEC	ReplyMsg		;reply to it
  	bra.s	 	Loop			;branch back always

;------ remove menu and close window
KillWindow:
  	move.l 		WindowPtr,a0		;get window
  	CALLINT 	CloseWindow		;and close it

WdwError:  	
  	move.l 		_IntuitionBase,a1	;intuition lib base in a1
  	CALLEXEC 	CloseLibrary		;close intuition

IntError
DONOTHING:
	rts					;quit
	
;	End of Main Program

Intname
	dc.b	'intuition.library',0
	EVEN
	
_IntuitionBase
	dc.l	0
	
Message
	dc.l	0
	
MPort
	dc.l	0
	
WindowPtr
	dc.l	0
	
returnMsg
	dc.l	0
	

;***********************************************************
;	Subroutines called by gadgets 
;***********************************************************

Executable
	lea		Gadget1(pc),a1		;get first excluded gadget
	moveq		#2,d0			;number of excluded gadgets
	bsr		RemoveGad		;and remove them from window
	move.w		#SELECTED,d1		;get SELECTED mask
	lea		Gadget1(pc),a1		;get this gadget
	or.w		d1,gg_Flags(a1)		;select this gadget
	not.w		d1			;invert mask
	lea		Gadget2(pc),a1		;get other gadget
	and.w		d1,gg_Flags(a1)		;and un-select it
	
	lea		Gadget1(pc),a1		;get first gadget again
	moveq		#2,d1			;and number of gadgets
	bsr		AddGad			;add them back + refresh
;------ Do any other stuff we need to do

	rts
	
Linkable
	lea		Gadget1(pc),a1
	moveq		#2,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget2(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget1(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#2,d1
	bsr		AddGad
;------ Do any other stuff we need to do

	rts

Dependant
	lea		Gadget3(pc),a1
	moveq		#2,d0
	bsr.s		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget3(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget4(pc),a1
	and.w		d1,gg_Flags(a1)
	
	lea		Gadget3(pc),a1
	moveq		#2,d1
	bsr.s		AddGad
;------ Do any other stuff we need to do

	rts

Independant
	lea		Gadget3(pc),a1
	moveq		#2,d0
	bsr.s		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget4(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget3(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#2,d1
	bsr.s		AddGad
;------ Do any other stuff we need to do

	rts
	
Nodebug
	lea		Gadget5(pc),a1
	moveq		#3,d0
	bsr.s		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget5(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget6(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget7(pc),a1
	and.w		d1,gg_Flags(a1)
	
	lea		Gadget5(pc),a1
	moveq		#3,d1
	bsr.s		AddGad
;------ Do any other stuff we need to do

	rts

RemoveGad
	move.l		WindowPtr(pc),a0
	CALLINT		RemoveGList
	rts
	
AddGad
	movem.l		d1/a1,-(sp)		;save d1,a1 numgad,gadget
	move.l		WindowPtr(pc),a0	;get window ptr
	sub.l		a2,a2			;clear a2
	CALLINT		AddGList		;d0 should remain unchanged
	move.l		WindowPtr(pc),a1	;since RemoveGList
	movem.l		(sp)+,d0/a0		;set up d0,a0 numgad,gadget  
	CALLSYS		RefreshGList		;refresh gadgets	
	rts		


Do_debug
	lea		Gadget5(pc),a1
	moveq		#3,d0
	bsr.s		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget6(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget7(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget5(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#3,d1
	bsr.s		AddGad
;------ Do any other stuff we need to do

	rts

Exports
	lea		Gadget5(pc),a1
	moveq		#3,d0
	bsr.s		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget7(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget6(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget5(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#3,d1
	bsr.s		AddGad
;------ Do any other stuff we need to do

	rts

Nolist
	lea		Gadget8(pc),a1
	moveq		#3,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget8(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget9(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget10(pc),a1
	and.w		d1,gg_Flags(a1)
	
	lea		Gadget8(pc),a1
	moveq		#3,d1
	bsr		AddGad
;------ Do any other stuff we need to do

	rts

Scrnlist 
	lea		Gadget8(pc),a1
	moveq		#3,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget9(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget10(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget8(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#3,d1
	bsr		AddGad
;------ Do any other stuff we need to do

	rts

DiskList
	lea		Gadget8(pc),a1
	moveq		#3,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget10(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget9(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget8(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#3,d1
	bsr		AddGad
;------ Do any other stuff we need to do

	rts

NoOutput
	lea		Gadget11(pc),a1
	moveq		#3,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget11(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget12(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget13(pc),a1
	and.w		d1,gg_Flags(a1)
	
	lea		Gadget11(pc),a1
	moveq		#3,d1
	bsr		AddGad
;------ Do any other stuff we need to do

	rts

AsmToMem
	lea		Gadget11(pc),a1
	moveq		#3,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget12(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget13(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget11(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#3,d1
	bsr		AddGad
;------ Do any other stuff we need to do

	rts

AsmToDisk
	lea		Gadget11(pc),a1
	moveq		#3,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		Gadget13(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		Gadget12(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		Gadget11(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#3,d1
	bsr		AddGad
;------ Do any other stuff we need to do

	rts

Linkwith
Library 	
Cancel
Assemble
	rts
	
AsmWindowStructure:
	dc.w	0,0	;window XY origin relative to TopLeft of screen
	dc.w	440,200	;window width and height
	dc.b	3,2	;detail and block pens
	dc.l	GADGETDOWN+GADGETUP+CLOSEWINDOW	;IDCMP flags
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH	;other window flags
	dc.l	GadgetList1	;first gadget in gadget list
	dc.l	NULL	;custom CHECKMARK imagery
	dc.l	NewWindowName1	;window title
	dc.l	NULL	;custom screen pointer
	dc.l	NULL	;custom bitmap
	dc.w	5,5	;minimum width and height
	dc.w	640,200	;maximum width and height
	dc.w	WBENCHSCREEN	;destination screen type
NewWindowName1:
	dc.b	'Assemble',0
	EVEN

GadgetList1:
Gadget1:
	dc.l	Gadget2	;next gadget
	dc.w	144,17	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP|SELECTED	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText1	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	1	;user-definable data
	dc.l	Executable	;pointer to user-definable data

IText1:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	10,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText1	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText1:
	dc.b	'Executable',0
	EVEN

Image1:
	dc.w	0,0	;XY origin relative to container TopLeft
	dc.w	102,13	;Image width and height in pixels
	dc.w	2	;number of bitplanes in Image
	dc.l	ImageData1	;pointer to ImageData
	dc.b	$0003,$0000	;PlanePick and PlaneOnOff
	dc.l	NULL	;next Image structure

Gadget2:
	dc.l	Gadget3	;next gadget
	dc.w	278,17	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText2	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	2	;user-definable data
	dc.l	Linkable	;pointer to user-definable data

IText2:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	19,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText2	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText2:
	dc.b	'Linkable',0
	EVEN

Gadget3:
	dc.l	Gadget4	;next gadget
	dc.w	144,40	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP|SELECTED	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText3	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	3	;user-definable data
	dc.l	Dependant	;pointer to user-definable data

IText3:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	16,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText3	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText3:
	dc.b	'Dependant',0
	EVEN

Gadget4:
	dc.l	Gadget5	;next gadget
	dc.w	278,40	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText4	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	4	;user-definable data
	dc.l	Independant	;pointer to user-definable data
IText4:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	8,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText4	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText4:
	dc.b	'Independant',0
	EVEN

Gadget5:
	dc.l	Gadget6	;next gadget
	dc.w	76,63	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP|SELECTED	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText5	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	5	;user-definable data
	dc.l	Nodebug	;pointer to user-definable data

IText5:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	30,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText5	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText5:
	dc.b	'None',0
	EVEN

Gadget6:
	dc.l	Gadget7	;next gadget
	dc.w	201,63	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText6	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	6	;user-definable data
	dc.l	Do_debug	;pointer to user-definable data

IText6:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	24,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText6	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText6:
	dc.b	'Normal',0
	EVEN

Gadget7:
	dc.l	Gadget8	;next gadget
	dc.w	326,63	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText7	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	7	;user-definable data
	dc.l	Exports	;pointer to user-definable data
IText7:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	20,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText7	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText7:
	dc.b	'Exports',0
	EVEN

Gadget8:
	dc.l	Gadget9	;next gadget
	dc.w	76,86	;origin XY of hit box relative to window TopLeft
	dc.w	103,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP|SELECTED	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText5	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	8	;user-definable data
	dc.l	Nolist	;pointer to user-definable data

Gadget9:
	dc.l	Gadget10	;next gadget
	dc.w	201,86	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText8	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	9	;user-definable data
	dc.l	Scrnlist	;pointer to user-definable data

IText8:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	23,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText8	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText8:
	dc.b	'Screen',0
	EVEN

Gadget10:
	dc.l	Gadget11	;next gadget
	dc.w	326,86	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText11	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	10	;user-definable data
	dc.l	DiskList	;pointer to user-definable data

IText11:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	34,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText11	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText11:
	dc.b	'Disk',0
	EVEN

Gadget11:
	dc.l	Gadget12	;next gadget
	dc.w	144,109	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText5	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	11	;user-definable data
	dc.l	NoOutput	;pointer to user-definable data

Gadget12:
	dc.l	Gadget13	;next gadget
	dc.w	278,109	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP|SELECTED	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText9	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	12	;user-definable data
	dc.l	AsmToMem	;pointer to user-definable data

IText9:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	24,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText9	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText9:
	dc.b	'Memory',0
	EVEN

Gadget13:
	dc.l	Gadget14	;next gadget
	dc.w	37,131	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText11	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	13	;user-definable data
	dc.l	AsmToDisk	;pointer to user-definable data

Gadget14:
	dc.l	Gadget15	;next gadget
	dc.w	184,133	;origin XY of hit box relative to window TopLeft
	dc.w	240,8	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY+GADGIMMEDIATE	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	NULL	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	Gadget14SInfo	;SpecialInfo structure
	dc.w	14	;user-definable data
	dc.l	Assemble	;pointer to user-definable data
Gadget14SInfo:
	dc.l	Gadget14SIBuff	;buffer where text will be edited
	dc.l	UNDOBUFFER	;optional undo buffer
	dc.w	0	;character position in buffer
	dc.w	44	;maximum number of characters to allow
	dc.w	0	;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition initialized and maintained variables
	dc.l	0	;Rastport of gadget
	dc.l	0	;initial value for integer gadgets
	dc.l	NULL	;alternate keymap (fill in if you set the flag)
Gadget14SIBuff:
	dcb.b	44,0
	EVEN

Border1:
	dc.w	-3,-2	;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors1	;pointer to XY vectors
	dc.l	NULL	;next border in list
BorderVectors1:
	dc.w	0,0
	dc.w	246,0
	dc.w	246,11
	dc.w	0,11
	dc.w	0,1

Gadget15:
	dc.l	Gadget16	;next gadget
	dc.w	184,150	;origin XY of hit box relative to window TopLeft
	dc.w	240,8	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY+GADGIMMEDIATE	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	NULL	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	Gadget16SInfo	;SpecialInfo structure
	dc.w	15	;user-definable data
	dc.l	Linkwith	;pointer to user-definable data
Gadget15SInfo:
	dc.l	Gadget15SIBuff	;buffer where text will be edited
	dc.l	UNDOBUFFER	;optional undo buffer
	dc.w	0	;character position in buffer
	dc.w	44	;maximum number of characters to allow
	dc.w	0	;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition initialized and maintained variables
	dc.l	0	;Rastport of gadget
	dc.l	0	;initial value for integer gadgets
	dc.l	NULL	;alternate keymap (fill in if you set the flag)
Gadget15SIBuff:
	dcb.b 44,0
	EVEN

Gadget16:
	dc.l	Gadget17	;next gadget
	dc.w	184,166	;origin XY of hit box relative to window TopLeft
	dc.w	240,8	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY+GADGIMMEDIATE	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	NULL	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	Gadget16SInfo	;SpecialInfo structure
	dc.w	16	;user-definable data
	dc.l	Library	;pointer to user-definable data
Gadget16SInfo:
	dc.l	Gadget16SIBuff	;buffer where text will be edited
	dc.l	UNDOBUFFER	;optional undo buffer
	dc.w	0	;character position in buffer
	dc.w	44	;maximum number of characters to allow
	dc.w	0	;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition initialized and maintained variables
	dc.l	0	;Rastport of gadget
	dc.l	0	;initial value for integer gadgets
	dc.l	NULL	;alternate keymap (fill in if you set the flag)
Gadget16SIBuff:
	dcb.b 44,0
	EVEN
	
UNDOBUFFER:
	dcb.b 44,0
	EVEN

Gadget17:
	dc.l	Gadget18	;next gadget
	dc.w	51,181	;origin XY of hit box relative to window TopLeft
	dc.w	102,13	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText12	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	17	;user-definable data
	dc.l	Cancel	;pointer to user-definable data

IText12:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	25,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText12	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText12:
	dc.b	'Cancel',0
	EVEN

Gadget18:
	dc.l	NULL	;next gadget
	dc.w	313,180	;origin XY of hit box relative to window TopLeft
	dc.w	102,15	;hit box width and height
	dc.w	GADGIMAGE|GADGHCOMP	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Image2	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText10	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	18	;user-definable data
	dc.l	Assemble	;pointer to user-definable data

Image2:
	dc.w	0,0	;XY origin relative to container TopLeft
	dc.w	102,15	;Image width and height in pixels
	dc.w	2	;number of bitplanes in Image
	dc.l	ImageData2	;pointer to ImageData
	dc.b	$0003,$0000	;PlanePick and PlaneOnOff
	dc.l	NULL	;next Image structure

IText10:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	17,3	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText10	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText10:
	dc.b	'Assemble',0
	EVEN	
	
IntuiTextList1:
IText13:
	dc.b	1,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	18,20	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText13	;pointer to text
	dc.l	IText14	;next IntuiText structure
ITextText13:
	dc.b	'Program Type',0
	EVEN
IText14:
	dc.b	1,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	50,42	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText14	;pointer to text
	dc.l	IText15	;next IntuiText structure
ITextText14:
	dc.b	'Case',0
	EVEN
IText15:
	dc.b	1,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	16,66	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText15	;pointer to text
	dc.l	IText16	;next IntuiText structure
ITextText15:
	dc.b	'Debug',0
	EVEN
IText16:
	dc.b	1,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	17,89	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText16	;pointer to text
	dc.l	IText17	;next IntuiText structure
ITextText16:
	dc.b	'List',0
	EVEN
IText17:
	dc.b	1,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	47,112	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText17	;pointer to text
	dc.l	IText18	;next IntuiText structure
ITextText17:
	dc.b	'Output',0
	EVEN
IText18:
	dc.b	1,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	96,151	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText18	;pointer to text
	dc.l	IText19	;next IntuiText structure
ITextText18:
	dc.b	'Link With',0
	EVEN
IText19:
	dc.b	1,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	112,166	;XY origin relative to container TopLeft
	dc.l	TOPAZ80	;font pointer or NULL for default
	dc.l	ITextText19	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText19:
	dc.b	'Library',0
	EVEN

TOPAZ80:
	dc.l	TOPAZname
	dc.w	TOPAZ_EIGHTY
	dc.b	0,0
TOPAZname:
	dc.b	'topaz.font',0
	EVEN

********************************************************************
	SECTION	ImageData,DATA_C
********************************************************************


ImageData1:
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FC00,$C000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0C00,$C000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0C00,$C000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0C00,$C000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0C00,$C000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C00,$C000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0C00,$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00,$C000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0C00,$C000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0C00,$C000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0C00,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FC00,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$03FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$3FFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$3FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$3FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$F3FF,$3FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$03FF
	
ImageData2:
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FC00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FC00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FC00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FC00
	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$03FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$03FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$03FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$03FF


