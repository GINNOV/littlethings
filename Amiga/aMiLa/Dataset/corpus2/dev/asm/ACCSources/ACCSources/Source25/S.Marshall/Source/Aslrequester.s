***************************************************************
*
*	Short Program to Demonstrate the use of WBench2's
*
*			Asl FileRequester
*
*	   By S.Marshall - Compiles with Devpac V3.01
*	Simple example crudely constructed from my old
*	ARP requester example.
* 
***********************************************************************

	INCLUDE 	Intuition/Intuition.i
	INCLUDE		Libraries/Dosextens.i
	INCLUDE		libraries/asl_lib.i
	INCLUDE		libraries/asl.i

		
NULL	EQU	0

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

	move.l		returnMsg,d7		;test if from workbench
	beq.s		exitToDOS		;if I was a CLI

	CALLEXEC	Forbid			;forbid multitasking
	move.l		d7,a1			;get workbench message
	CALLSYS		ReplyMsg		;reply workbench message

exitToDOS
	moveq		#0,d0			;flag no error
	rts					;Quit our program

_main	
	moveq		#36,d0			;set lib version
  	lea		Dosname(pc),a1		;lib name in a1
  	CALLEXEC	OpenLibrary		;try to open library
  	move.l		d0,_DOSBase		;store lib base
  	beq		Error			;cleanup and quit if fail

	moveq		#36,d0			;set lib version
  	lea		Intname(pc),a1		;lib name in a1
  	CALLSYS		OpenLibrary		;try to open library
  	move.l		d0,_IntuitionBase	;store lib base
  	beq		IntError		;cleanup and quit if fail

	moveq		#36,d0			;set lib version
  	lea		Aslname(pc),a1		;lib name in a1
  	CALLSYS		OpenLibrary		;try to open library
  	move.l		d0,_AslBase		;store lib base
  	beq		AslError		;cleanup and quit if fail

	move.l		d0,a6			;get asl base in a6
	moveq		#ASL_FileRequest,d0	;requester type
	lea		MainTags,a0		;taglist
	CALLSYS		AllocAslRequest		;allocate asl request struct
	move.l		d0,Asl_Request		;save request struct
	beq		ReqError
	
;------ open a window 
  	lea 		MyNewWindow,a0		;pointer to newwindow struct
  	CALLINT		OpenWindow		;and open it
  	move.l 		d0,WindowPtr		;store window pointer	
  	beq 		WdwError		;quit if fail
  	
  	move.l		d0,a0			;move window ptr to a0
  	move.l		wd_RPort(a0),RPort	;and get rastport
  	
  	move.l		RPort,a0		;rastport to a0
  	lea		Border2,a1		;get address of border
  	moveq		#0,d0			;no x offset
  	moveq		#0,d1			;no y ofset
  	CALLSYS		DrawBorder		;draw border
  
  	move.l 		WindowPtr,a0		;get window ptr
  	move.l 		wd_UserPort(a0),a0	;get message port
  	move.l 		a0,d6			;and store it
	
  	
;------ wait for an Intuition message
Loop:
  	move.l		d6,a0
  	CALLEXEC 	WaitPort		;wait for an event
 	
;------ get the message
  	move.l 		d6,a0			;get mesage port
  	CALLSYS		GetMsg			;and  get it's message
  	tst 		d0			;was there a message
  	beq.s 		Loop 			;if no then quit

;------ store message 
  	move.l 		d0,a1			;message to a1
  	move.l 		im_Class(a1),d7		;get message class
 	move.l 		im_IAddress(A1),A5	;get address
  	CALLSYS		ReplyMsg		;reply to message

  	
;------ test for message type and act accordingly
  	cmp.l 		#CLOSEWINDOW,d7		;was it closewindow ?
  	beq.s	 	KillWindow		;yes cleanup and quit
	
	cmp.l		#GADGETUP,D7		;no - was it gadgetup ?
  	bne.s		Loop			;no then loop again

	move.l		gg_UserData(A5),A0	;get the userdata
	jsr		(A0)			;and jsr to that address
  	bra.s	 	Loop			;loop back and go again

;------ remove menu and close window
KillWindow:
  	move.l 		WindowPtr,a0		;get window pointer
  	CALLINT 	CloseWindow		;and close it

WdwError
	move.l		Asl_Request,a0		;get request struct
	move.l		_AslBase,a6
	CALLSYS		FreeAslRequest
	
ReqError
	move.l 		_AslBase,a1		;asl lib base in a1
  	CALLEXEC 	CloseLibrary		;close asl

AslError:
	move.l 		_IntuitionBase,a1	;intuition lib base in a1
  	CALLEXEC 	CloseLibrary		;close intuition

IntError
	move.l 		_DOSBase,a1		;DOS lib base in a1
  	CALLSYS 	CloseLibrary		;close intuition

Error
	rts					;quit
	
;	End of Main Program

;***********************************************************
;	Subroutines called by menus,gadgets etc.
;***********************************************************
;------	routine called by load gadget
	
Load:	
	lea		LoadTags,a1		;address of taglist
	bsr		DoRequest		;start requester
	move.l		Asl_Request,a0		;address of requester struc
	bsr		PrintResult		;output result
	rts					;and return to calling routine
	
;===========================================================

;------	routine called by save gadget and menus save

Save:
	lea		SaveTags,a1
	bsr		DoRequest		;start requester
	move.l		Asl_Request,a0		;address of requester struc
	bsr		PrintResult		;output result
	rts					;and return to calling routine

;===========================================================

DoRequest
	move.l		_AslBase,a6		;get asl base
	move.l		Asl_Request,a0		;address of requester struc
	CALLSYS		AslRequest		;do request
	rts					;end of DoRequest
	
;===========================================================

;------	routine to print result from call to Asl requester
;------	Called as	PrintResult(Bool,Requester)
;				     d0      a0
;------	Where Bool = return value fron Requester and Requester
;------	is a pointer to the Asl Requester structure.

PrintResult
	movem.l		d0/a0,-(sp)		;save d0 and a0
	lea		ClearText,a0		;address of string of spaces
	bsr.s		puts			;overwrite old text
	movem.l		(sp)+,d0/a0		;restore d0 and a0
	tst.l		d0			;test d0
	beq.s		cancelled		;branch if cancelled
	
	move.l		rf_Dir(a0),a1		;get dir string
	lea		TextBuffer,a2		;get output buffer
	moveq		#56,d0			;set max size
copy
	move.b		(a1)+,(a2)+		;copy bytes
	dbeq		d0,copy			;until end of string or buffer
	
	move.l		#TextBuffer,d1		;get dir name (copy)
	move.l		rf_File(a0),d2		;get file name
	move.l		#200,d3			;size of buffer
	CALLDOS		AddPart			;create full pathname
	
	tst.l		d0			;test for overflow
	beq.s		cancelled		;branch on error
	
	moveq		#-1,d0			;initialise count		
	lea		TextBuffer,a0		;address of buffer
	
checksize
	addq.w		#1,d0			;decrement counter
	tst.b		0(a0,d0.w)		;test for zero terminator
	bne.s		checksize		;branch if not found
	
	cmpi.w		#37,d0			;is count too large
	ble.s		sizeok			;branch if not
	sub.w		#37,d0			;subtract count from numchars
	add.w		d0,a0			;add to buff address so end of string shown
	
sizeok
	bsr.s		puts			;write to screen
	rts					;quit
	
cancelled
	lea		CancelText,a0		;address of Cancel text
	bsr		puts			;write to screen
	rts					;quit
	
;===========================================================
;a simple routine to put text to the screen without any formatting.

;	puts (String)
;		a0

puts:
	moveq		#0,d1		;x pos
	moveq		#0,d0		;y pos
	move.l		a0,ITextPtr	;set text pointer in intuitext
	lea		IText,a1	;get intuitext struct
	move.l		RPort,a0	;get rastport
	CALLINT		PrintIText	;print string
	rts

Aslname
	AslName			;macro for asl lib name

Dosname
	DOSNAME			;macro for dos lib name

Intname
	INTNAME			;macro for Intuition lib name
	
Grafname:
	GRAFNAME		;macro for graphics lib name


;***********************************************************
	SECTION Display_Data,DATA
;***********************************************************

;------ window structure
MyNewWindow 
  	dc.w 	0,20
  	dc.w 	320,52
  	dc.b 	-1,-1
  	dc.l 	CLOSEWINDOW!GADGETUP
  	dc.l 	WINDOWDRAG!WINDOWDEPTH!WINDOWCLOSE!ACTIVATE
  	dc.l 	MYGADGET1
  	dc.l 	NULL
  	dc.l 	MYTITLE  
  	dc.l	NULL
  	dc.l	NULL
  	dc.w 	255,111
  	dc.w 	320,160
  	dc.w	WBENCHSCREEN
  
MYTITLE:
  	dc.b 	"Asl FileRequester",0  
  	EVEN

Font80:	dc.l	FontName
	dc.w	8
	dc.b	0
	dc.b	0
	
FontName:
	dc.b	"topaz.font",0
	EVEN  	
  	

MYGADGET1:
  	dc.l 	MYGADGET2			;next gadget
  	dc.w 	15,15,50,20			;top,left,width,height
  	dc.w 	GADGHCOMP			;gadget flags
  	dc.w 	GADGIMMEDIATE|RELVERIFY		;activation flags
  	dc.w 	BOOLGADGET			;gadget type flags
  	dc.l 	Border1				;gadget border to be rendered
  	dc.l 	NULL				;alternate imagery for selection
  	dc.l	Gadget1IText			;first IntuiText structure
  	dc.l 	0				;gadget mutual-exclude long word
  	dc.l	0				;special info
  	dc.w 	0				;gadget ID
  	dc.l	Load				;user-definable data
  	
Gadget1IText:
	dc.b	1,0
	dc.b	1,0
	dc.w	8,6
	dc.l	Font80
	dc.l	Gadg1Text
	dc.l	0
	
Gadg1Text:
	dc.b	'LOAD',0
	EVEN
    
MYGADGET2:
  	dc.l 	NULL				;next gadget
  	dc.w 	255,15,50,20			;top,left,width,height
  	dc.w 	GADGHCOMP			;gadget flags
  	dc.w 	GADGIMMEDIATE|RELVERIFY		;activation flags
  	dc.w 	BOOLGADGET			;gadget type flags
  	dc.l 	Border1				;gadget border to be rendered
  	dc.l	NULL				;alternate imagery for selection
  	dc.l	Gadget2IText			;first IntuiText structure
  	dc.l 	0				;gadget mutual-exclude long word
  	dc.l	0				;special info
  	dc.w 	0				;gadget ID
  	dc.l	Save				;user-definable data

Gadget2IText:
	dc.b	1,0
	dc.b	1,0
	dc.w	8,6
	dc.l	Font80
	dc.l	Gadg2Text
	dc.l	0
	
Gadg2Text:
	dc.b	'SAVE',0
	EVEN



;***********************************************************
;	Border Structure
;***********************************************************

Border1:
 	dc.w	-1,-1			;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2		;front pen, back pen and drawmode
	dc.b	5			;number of XY vectors
	dc.l	BorderVectors1		;pointer to XY vectors
	dc.l	NULL			;next border in list
BorderVectors1:
  	dc.w 	-2,-1
  	dc.w	50,-1
  	dc.w	50,20
  	dc.w	-2,20
  	dc.w	-2,-1
  	
Border2:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2		;front pen, back pen and drawmode
	dc.b	5			;number of XY vectors
	dc.l	BorderVectors2		;pointer to XY vectors
	dc.l	NULL			;next border in list
BorderVectors2:
  	dc.w	6,38
  	dc.w	6,48
  	dc.w	314,48
  	dc.w	314,38
  	dc.w	6,38


IText
	dc.b	1,0
	dc.b	1,0
	dc.w	16,40
	dc.l	Font80
ITextPtr:
	dc.l	0
	dc.l	0

CancelText
	dc.b	'              Cancelled',0 ;cancel string
	EVEN

ClearText
	dc.b	'                                     ',0 ;cancel string
	EVEN


MainTags
	dc.l	ASL_Height		;requester height tag
	dc.l	200			;height
	dc.l	ASL_Width		;width tag
	dc.l	340			;width
	dc.l	ASL_Pattern		;pattern tag
	dc.l	Pattern			;pointer to pattern
	dc.l	TAG_DONE		;end of taglist tag

Pattern
	dc.b	'(#?.doc|~#?.info)',0	
	EVEN
	
LoadTags
	dc.l	ASL_Hail		;name tag
	dc.l	LoadText		;pointer to hail text
	dc.l	ASL_FuncFlags		;special function tag
	dc.l	FILF_PATGAD		;flag add pattern gadget
	dc.l	TAG_DONE		;end of taglist tag
	
LoadText
	dc.b	'Load File',0	
	EVEN
	
SaveTags
	dc.l	ASL_Hail		;name tag
	dc.l	SaveText		;pointer to hail text
	dc.l	ASL_FuncFlags		;special function tag
	dc.l	FILF_SAVE|FILF_PATGAD	;save + pattern gad requester flags
	dc.l	TAG_DONE		;end of taglist tag
	
SaveText
	dc.b	'Save File',0
		
;***********************************************************
	SECTION	Variables,BSS
;***********************************************************	

_AslBase
	ds.l	1		;storage for Asl lib base
_DOSBase
	ds.l	1		;storage for DOS lib base
Asl_Request
	ds.l	1		;pointer to requester struct
_IntuitionBase:
	ds.l	1		;storage for Intuition lib pointer
WindowPtr:
	ds.l	1		;storage for window structure pointer 
RPort:
	ds.l	1		;storage for windows rastport pointer
returnMsg:
	ds.l	1		;storage for workbench message
TextBuffer
	ds.l	50