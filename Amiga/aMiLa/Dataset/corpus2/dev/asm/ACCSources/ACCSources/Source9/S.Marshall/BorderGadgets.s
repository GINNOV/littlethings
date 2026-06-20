**************************************************************************
*
*	A small program to answer two questions sent to me this month
*	This program shows how to add a gadget to the top border and  
*	also how to wait for the window being resized before writing	
*	text or graphics to it.
*	This program simply iconifies the window when the border gadget
*	is clicked.The effect is similar to the shrink gadget in SID
*	or other such programs.When the window is made larger (by clicking
*	on the gadget again) it is moved back to it's last position and 
*	resized to it's last size.
*	This code is public domain so feel free to use it in your own
*	programs.
*			Compiles with Devpac V2.14
*
*			    By Steve Marshall
*
**************************************************************************



	INCDIR	 	sys:INCLUDE/
	INCLUDE 	Exec/Exec_lib.i
	INCLUDE		Libraries/Dosextens.i
	INCLUDE 	Intuition/Intuition.i
	INCLUDE 	Intuition/Intuition_lib.i
	INCDIR		source9:include/
	INCLUDE		arpbase.i

;*****************************************

CALLSYS	MACRO
	IFGT	NARG-1		 
	FAIL	!!!		   
	ENDC
	JSR	_LVO\1(A6)
	ENDM
		
;*****************************************

NULL	EQU	0

	clr.l		returnMsg
	sub.l		a1,a1		;clear a1
	CALLEXEC	FindTask	;find task - us
	move.l		d0,a4		;process in a4

	tst.l		pr_CLI(a4)	;test if from CLI
	beq.s		Workbench	;branch if from workbench
	
	bra.s		end_startup	;and run the user prog

Workbench
	lea		pr_MsgPort(a4),a0 ;tasks message port in a0
	CALLSYS		WaitPort	;wait for workbench message
	lea		pr_MsgPort(a4),a0 ;tasks message port in a0
	CALLSYS		GetMsg		;get workbench message
	move.l		d0,returnMsg	;save it for later reply

end_startup
	bsr.s		_main		;call our program

	tst.l		returnMsg	;test if from workbench
	beq.s		exitToDOS	;if I was a CLI

	CALLEXEC	Forbid		;forbid multitasking
	move.l		returnMsg,a1	;get workbench message
	CALLSYS		ReplyMsg	;reply workbench message

exitToDOS
	moveq		#0,d0		;flag no error
	rts				;Quit our program

_main	
	OPENARP
	movem.l		(sp)+,d0/a0	;pop regs from stack
	move.l		a6,_ArpBase	;store _ArpBase

;------	the ARP library opens and uses the graphics and intuition 
;	libs and it is quite legal for us to get these bases for 
;	our own use - neat eh!
	move.l		IntuiBase(a6),_IntuitionBase ;steal intbase
	
;------ open a window
  	lea 		MyNewWindow,a0	;get NewWindow
  	CALLINT		OpenWindow	;and open it
  	move.l 		d0,WindowPtr	;save window pointer
  	beq 		WdwError	;quit if error
  	
	move.l		d0,a0		;a pointer to window structure
	move.l		wd_RPort(a0),RPort ;save rastport

	lea		MYGADGET1,a1	;our border gadget
	CALLSYS		RemoveGadget	;remove it
	
	move.l		WindowPtr,a0	;get window structure
	lea		MYGADGET1,a1	;and our gadget
	moveq		#0,d0		;specify top of gadget list
	CALLSYS		AddGadget	;add gadget to top of list
	
	bsr		PrintText	;print some text

;------ wait for an Intuition message
Loop:
  	move.l 		WindowPtr,a0	;get window
  	move.l 		wd_UserPort(a0),a0 ;and get it's port
  	move.l 		a0,-(sp)	;save port
 	CALLEXEC 	WaitPort	;wait for a message
 	
;------ get the message
  	move.l 		(sp)+,a0	;get port	
  	CALLSYS		GetMsg		;reply message
  	tst 		d0		;test result
  	beq.s 		Loop 		;branch if no message

;------ store message 
  	move.l 		d0,a1		;message in a1
  	move.l 		a1,Message	;save message
  	
;------ test for message type and act accordingly
  	move.l 		im_Class(a1),d1 ;get message class
  	cmp.l 		#CLOSEWINDOW,d1	;test for closewindow
  	beq.s	 	KillWindow	;branch if closewindow
	cmp.l		#GADGETUP,d1	;test for gadget up
  	bne.s		NotGadget	;branch if not gadget up

	move.l 		im_IAddress(a1),a0 ;get gadget address
	move.l		gg_UserData(a0),a0 ;get gadgets userdata
	jsr		(a0)		;jump to this address

NotGadget:
	cmp.l 		#NEWSIZE,d1	;test for newsize
  	bne.s	 	NotNewsize	;branch if not newsize
  	bsr		PrintText	;redraw screen

NotNewsize
;------ reply to message then loop back to go again
  	move.l 		Message,a1	;get message
  	CALLEXEC	ReplyMsg	;and reply to it
  	bra	 	Loop		;loop forever

;------ remove menu and close window
KillWindow:
  	move.l 		WindowPtr,a0	;get window
  	CALLINT 	CloseWindow	;and close it

WdwError:  	
	move.l 		_ArpBase,a1	;Arp lib base in a1
  	CALLEXEC 	CloseLibrary	;close Arp
  
Error
	rts				;quit
	
;	End of Main Program

;***********************************************************
;			Subroutines
;***********************************************************

;------	Pretty dumb routine to fill window with text
PrintText:
	movem.l		a4-a6/d6-d7,-(sp)	;save regs
	lea		IText1,a4		;get Intuitext
	move.l		_IntuitionBase,a6	;get lib base
	move.l		WindowPtr,a5		;get window
	moveq		#0,d6			;clear d7
	move.w		wd_Height(a5),d6	;get window height
	sub.w		#24,d6			;correct for borders etc.		
	bmi.s		NoText			;quit if window too small
	lsr.w		#4,d6			;calc loop num
	move.l		RPort,a5		;get rastport
	moveq		#0,d7			;set start pos
Textloop	
	move.l		a4,a1			;Intuitext in a1
	move.l		a5,a0			;get rastport in a0
	moveq		#0,d0			;x offset
	move.l		d7,d1			;y offset
	CALLSYS		PrintIText		;print text
	
	add.w		#16,d7			;bump text  Y position
	dbra		d6,Textloop		;branch until done
NoText
	movem.l		(sp)+,a4-a6/d6-d7	;restore regs
	rts

;***********************************************************
;	Subroutines called by gadgets etc.
;***********************************************************
  	
Iconify:
	move.l		WindowPtr,a2		;get window
	tst.w		IconifyFlag		;check flag
	bne.s		Enlarge			;in non zero enlarge window
	
	move.l		a2,a0			;get window
	moveq		#0,d0			;clear d0
	moveq		#0,d1			;and d1
	move.w		wd_Width(a2),d0		;get width of window
	move.w		d0,OldWidth		;and store it
	sub.l		#230,d0			;subtract icon width
	neg.l		d0			;negate result negative	
	move.w		wd_Height(a2),d1	;get window height
	move.w		d1,OldHeight		;and store it
	sub.l		#10,d1			;subtract icon height
	neg.l		d1			;negate result
	CALLINT		SizeWindow		;resize window
	
	move.l		a2,a0			;get window
	moveq		#0,d0			;clear d0
	moveq		#0,d1			;and d1
	move.w		wd_LeftEdge(a2),d0	;get current leftedge
	move.w		d0,OldLeft		;and store it
	move.w		#330,d1			;get icon leftedge
	sub.l		d1,d0			;and subtract it
	neg.l		d0			;negate result 
	move.w		wd_TopEdge(a2),d1	;get current topedge
	move.w		d1,OldTop		;and store it
	neg.l		d1			;negate 
	CALLSYS		MoveWindow		;move the window
	
;------ We could clear the menus and gadgets from the window at this point
;	to free up some memory.
  	
  	moveq		#-1,d0			;set flag
  	move.w		d0,IconifyFlag		;and store it
	rts

Enlarge
	move.l		a2,a0			;get window pointer
	moveq		#0,d0			;clear d0
	moveq		#0,d1			;and d1
	moveq		#0,d2			;and d2
	move.w		wd_LeftEdge(a2),d0	;get current leftedge
	move.w		OldLeft,d1		;get old leftedge
	sub.l		d1,d0			;subtract
	neg.l		d0			;negate result
	move.w		wd_TopEdge(a2),d1	;get current topedge
	move.w		OldTop,d2		;get old topedge
	sub.l		d2,d1			;subtract
	neg.l		d1			;negate result
	CALLINT		MoveWindow		;move window
	
	move.l		a2,a0			;get window pointer
	moveq		#0,d0			;clear d0
	moveq		#0,d1			;and d1
	moveq		#0,d2			;and d2
	move.w		wd_Width(a2),d0		;get windows current width 
	move.w		OldWidth,d1		;and old width
	sub.l		d1,d0			;subtract
	neg.l		d0			;negate result
	move.w		wd_Height(a2),d1	;get windows current height
	move.w		OldHeight,d2		;and old height
	sub.l		d2,d1			;subtract
	neg.l		d1			;negate resilt
	CALLSYS		SizeWindow		;resize window
	
SizeLoop
  	move.l 		WindowPtr,a0		;get window pointer
  	move.l 		wd_UserPort(a0),a0	;get port
  	move.l 		a0,a2			;save port
 	CALLEXEC 	WaitPort		;wait for message
 	
;------ get the message
  	move.l 		a2,a0			;get port
  	CALLSYS		GetMsg			;get message
  	tst 		d0			;test result
  	beq.s 		SizeLoop 		;branch if no message
  	
   	move.l 		d0,a1			;message in a1
  	
;------ test for message type and act accordingly
  	move.l 		im_Class(a1),d1		;msg class in d1
  	cmp.l 		#NEWSIZE,d1		;test for newsize
  	beq.s	 	WindowSized		;branch if newsize
  	
  	CALLSYS		ReplyMsg		;reply to message
  	bra.s		SizeLoop		;loop for next message
  	
WindowSized:
  	CALLSYS		ReplyMsg		;reply to message
  	
;------	we can now write to the window and all of it will be rendered
;	we could also add back any menus or gadgets removed earlier

  	bsr		PrintText		;redraw screen
	
  	moveq		#0,d0			;clear flag
  	move.w		d0,IconifyFlag		;and store it

	rts
;***********************************************************
;		Window structure
;***********************************************************
	
MyNewWindow 
	dc.w	16,16	;window XY origin relative to TopLeft of screen
	dc.w	400,150	;window width and height
	dc.b	0,1	;detail and block pens
	dc.l	NEWSIZE+GADGETUP+CLOSEWINDOW	;IDCMP flags
	dc.l	WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH ;other window flags
	dc.l	MYGADGET1	;first gadget in gadget list
	dc.l	NULL	;custom CHECKMARK imagery
	dc.l	NewWindowName1	;window title
	dc.l	NULL	;custom screen pointer
	dc.l	NULL	;custom bitmap
	dc.w	380,20	;minimum width and height
	dc.w	-1,-1	;maximum width and height
	dc.w	WBENCHSCREEN	;destination screen type
NewWindowName1:
	dc.b	'Iconify Window',0
	
	EVEN

IText1:
	dc.b	1,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	10,15	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText1	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText1:
	dc.b	'Just Something To Fill The Window With Text',0
	
	EVEN

;***********************************************************
;	Gadget structure
;***********************************************************

MYGADGET1:
	dc.l	NULL	;next gadget
	dc.w	-83,0	;origin XY of hit box relative to window TopLeft
	dc.w	31,10	;hit box width and height
	dc.w	GADGIMAGE+GRELRIGHT	;gadget flags
	dc.w	RELVERIFY+TOPBORDER	;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Image1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	NULL	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	NULL	;user-definable data
	dc.l	Iconify	;pointer to user-definable data
Image1:
	dc.w	0,0	;XY origin relative to container TopLeft
	dc.w	31,10	;Image width and height in pixels
	dc.w	2	;number of bitplanes in Image
	dc.l	ImageData1	;pointer to ImageData
	dc.b	$0003,$0000	;PlanePick and PlaneOnOff
	dc.l	NULL	;next Image structure

;***********************************************************
	SECTION	Image,DATA_C
;***********************************************************	

ImageData1:
	dc.w	$7FFF,$FFFC,$601F,$FFFC,$6000,$000C,$607F,$FFCC
	dc.w	$6060,$00CC,$6067,$FCCC,$7E60,$00CC,$7E7F,$FFCC
	dc.w	$7E00,$000C,$7FFF,$FFFC,$0000,$0000,$1FE0,$0000
	dc.w	$1FFF,$FFF0,$1F80,$0030,$1F9F,$FF30,$1F98,$0330
	dc.w	$019F,$FF30,$0180,$0030,$01FF,$FFF0,$0000,$0000



;***********************************************************
	SECTION	Variables,BSS
;***********************************************************	

MPort:	
	ds.l	1
Message:	
	ds.l	1
_ArpBase:
	ds.l	1		;storage for Arp lib pointer
_IntuitionBase:
	ds.l	1		;storage for Intuition lib pointer
WindowPtr:
	ds.l	1		;storage for window structure pointer 
RPort:
	ds.l	1		;storage for windows rastport pointer
returnMsg:
	ds.l	1		;storage for workbench message
IconifyFlag:
	ds.w	1		;flag for iconify gadget
OldWidth
	ds.w	1		;storage for old window sizes
OldHeight
	ds.w	1		;storage for old window sizes
OldTop
	ds.w	1		;storage for old window sizes
OldLeft
	ds.w	1		;storage for old window sizes

