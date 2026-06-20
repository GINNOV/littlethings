***************************************************************
*
*	Short Program to Demonstrate the use of ARP's
*	FileRequester.This version opens a lo-res screen
*	with a window on it.The FileRequester is redirected
*	to open on this screen.This program also shows a fairly
*	trivial use of the requesters flags an fr_Function to add
*	a few gadgets,resize and move the requester.These gadgets 
*	allow you to use wildcards to decide which files will be
*	displayed ie '.info' with gadget set to Exclude will stop
*	any icons from being displayed or '(*.s|*.asm)' with gadget
*	set to Include will only display files ending in .s or .asm
*	(standard assembler files).All standard wildcards are supported
*	(#,#?,?,* etc).You could also use (a*.s|b.asm) which would display
*	all files starting with a end ending in .s and all files starting 
*	with b and ending in .asm.All searches are case independant.All
*	directories will be shown no matter what the filter is set to.
*	
*
*	   By S.Marshall - Compiles with Devpac V2
* 
*	  Requires the ARP include files (supplied)
*
*	to Compile and the ARP Library (supplied) to run.
*
***********************************************************************
*
*       The two include files required for this program:
*       
*       arpbase.i and arpcompat.i are on this disc and will
* 
*       decrunch into the include directory of the source disc.
*
*       You should copy these into the include/misc directory
*
*       on you assembler workdisc.
*
*       arp.library can be found in the libs directory of this
*
*       disc. If you are using Devpac v2.12 you should replace
*
*       the old arp.library in the libs dir of your work disc
*
*       with this more up to  date version.  M.Meany  Sept 90
*
*
***********************************************************************

	INCDIR	 	"SYS:INCLUDE/"
	INCLUDE 	Graphics/graphics_lib.i
	INCLUDE 	Intuition/Intuition.i
	INCLUDE 	Intuition/Intuition_lib.i
 	INCLUDE 	Exec/Exec_lib.i
	INCLUDE		Libraries/Dosextens.i
	INCLUDE		misc/arpbase.i

		
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

	tst.l		returnMsg		;test if from workbench
	beq.s		exitToDOS		;if I was a CLI

	CALLEXEC	Forbid			;forbid multitasking
	move.l		returnMsg,a1		;get workbench message
	CALLSYS		ReplyMsg		;reply workbench message

exitToDOS
	moveq		#0,d0			;flag no error
	rts					;Quit our program

_main	
	OPENARP					;use arp's own open macro
	movem.l		(sp)+,d0/a0		;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt stack
	move.l		a6,_ArpBase		;store arpbase
	
  	moveq		#0,d0			;clear d0 (any lib version)
  	lea		Intname(pc),a1		;lib name in a1
  	CALLEXEC	OpenLibrary		;try to open library
  	move.l		d0,_IntuitionBase	;store lib base
  	beq		IntError		;cleanup and quit if fail
  	
    	moveq		#0,d0			;clear d0 (any lib version)
  	lea		Grafname(pc),a1		;lib name in a1
  	CALLEXEC	OpenLibrary		;try to open library
  	move.l		d0,_GfxBase		;store lib base
  	beq		GfxError		;cleanup and quit if fail
  	
	lea		NewScreenStructure,a0	;get screen args
	CALLINT		OpenScreen		;open screen 
	move.l		d0,ScreenPtr		;store pointer
	beq		ScrError		;branch if error
	
	move.l		d0,a0			;screen in a0
  	lea		sc_ViewPort(a0),a0	;viewport in a0
  	lea		Palette,a1		;get palette in a1
	moveq		#$16,d0			;number of colours
	CALLGRAF	LoadRGB4		;set colours


;------ open a window 
  	lea 		MyNewWindow,a0		;pointer to newwindow struct
	move.l		ScreenPtr,nw_Screen(a0)	;make window appear on new screen
  	CALLINT		OpenWindow		;and open it
  	move.l 		d0,WindowPtr		;store window pointer	
  	beq 		WdwError		;quit if fail
  	
;------	We will now tell the filerequesters that we are using a 
;	custom screen -note D0 still contains pointer to Window
	lea		LoadFileStruct,a0	;get Load FileRequest Struct
	move.l		d0,fr_Window(a0)	;and make it appear on customscreen
	
	lea		SaveFileStruct,a0	;get Save FileRequest Struct
	move.l		d0,fr_Window(a0)	;and make it appear on customscreen
	  	
  	move.l		d0,a0			;move window ptr to a0
  	move.l		wd_RPort(a0),RPort	;and get rastport
  	
  	move.l		RPort,a0		;rastport to a0
  	lea		Border2,a1		;get address of border
  	moveq		#0,d0			;no x offset
  	moveq		#0,d1			;no y ofset
  	CALLSYS		DrawBorder		;draw border
  	
  	
;------ wait for an Intuition message
Loop:
  	move.l 		WindowPtr,a0		;get window ptr
  	move.l 		wd_UserPort(a0),a0	;get message port
  	move.l 		a0,MPort		;and store it
 	CALLEXEC 	WaitPort		;wait for an event
 	
;------ get the message
  	move.l 		MPort,a0		;get mesage port
  	CALLSYS		GetMsg			;and  get it's message
  	tst 		d0			;was there a message
  	beq.s 		Loop 			;if no then quit

;------ store message 
  	move.l 		d0,a1			;message to a1
  	move.l 		a1,Message		;and store it
  	
;------ test for message type and act accordingly
  	move.l 		im_Class(a1),d1		;get message class
  	cmp.l 		#CLOSEWINDOW,d1		;was it closewindow ?
  	beq.s	 	KillWindow		;yes cleanup and quit
	cmp.l		#GADGETUP,D1		;no - was it gadgetup ?
  	bne.s		EndMessage		;no then loop again

	move.l 		im_IAddress(A1),A0	;yes - get gadgets address
	move.l		gg_UserData(A0),A0	;get the userdata
	jsr		(A0)			;and jsr to that address

EndMessage
  	move.l 		Message,a1		;get message
  	CALLEXEC	ReplyMsg		;and reply to it
  	bra.s	 	Loop			;loop back and go again

;------ remove menu and close window
KillWindow:
  	move.l 		WindowPtr,a0		;get window pointer
  	CALLINT 	CloseWindow		;and close it

WdwError:
	move.l		ScreenPtr,a0		;get screen pointer
	CALLINT		CloseScreen		;and close screen
  	
ScrError:
	move.l 		_IntuitionBase,a1	;intuition lib base in a1
  	CALLEXEC 	CloseLibrary		;close intuition

GfxError:  	
  	move.l 		_GfxBase,a1		;intuition lib base in a1
  	CALLEXEC 	CloseLibrary		;close intuition

IntError
	move.l 		_ArpBase,a1		;Arp lib base in a1
  	CALLEXEC 	CloseLibrary		;close Arp
  
Error
	rts					;quit
	
;	End of Main Program

;***********************************************************
;	Subroutines called by menus,gadgets etc.
;***********************************************************
;------	routine called by load gadget
	
Load:
;------	Clear message from window
	lea		ClrString,a2		;get blank string
	bsr		puts			;and erase old text
	
	lea		LoadFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester
	tst.l		d0			;did the user cancel ?
	beq.s		NoPath			;yes then quit
	
	lea		LoadFileStruct,a0	;get file struct
	bsr		CreatePath		;make full pathname
	tst.b		LoadPathName		;is there a pathname ?
	beq.s		NoPath			;no - then quit
	lea		LoadPathName,a2		;yes then get its address
	bsr		puts			;and print it

NoPath
	rts					;and return to calling routine
	
;===========================================================

;------	routine called by save gadget and menus save

Save:
	lea		ClrString,a2		;get blank string
	bsr		puts			;and erase old text
	
	lea		SaveFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester 
	tst.l		d0			;did the user cancel ?
	beq.s		NoPath2			;yes then quit
	
	lea		SaveFileStruct,a0	;get file struct
	bsr		CreatePath		;make full pathname
	tst.b		SavePathName		;is there a pathname ?
	beq.s		NoPath2			;no - then quit
	lea		SavePathName,a2		;yes then get its address
	bsr		puts			;and print it
	
NoPath2
	rts					;and return to calling routine

;***********************************************************
;	Special function called by FileRequester fr_Function
;***********************************************************

FileRQFunction
	cmpi.w		#FRF_DoWildFunc,d0  ;are we called for wildcards
	bne.s		NotWild		    ;branch if not wildcard func
	
	lea		Gadget4,a1	    ;get on/off gadget
	move.w		gg_Flags(a1),d1     ;get flags
	andi.w		#SELECTED,d1	    ;is gadget selected
	beq.s		ShowFile	    ;branch if not selected
	
;------ we are supposed to get a pointer to a fileinfo block but I find
;	that the pointer is FileInfoBlock - 20 ,I presume this is a bug

	lea		20(a0),a0	    ;get fileinfo block ??
	tst.l		fib_DirEntryType(a0);test if file
	bpl.s		ShowFile	    ;branch if a directory
	
	lea		fib_FileName(a0),a1 ;get file name address
	movem.l		a1/a6,-(sp)	    ;save regs
	move.l		Gadget5SInfo,a0     ;get pattern address
	lea		WildCardString,a1   ;get spare buffer
	CALLARP		PreParse	    ;preparse string for patternmatch
	
	lea		WildCardString,a0   ;get prepared string
	move.l		(sp)+,a1	    ;restore a1
	CALLARP		PatternMatch	    ;check for match
	move.l		(sp)+,a6	    ;restore a6
	tst.l		d0		    ;test result 0 = No match
	beq.s		NoMatch		    ;branch if no match
	
	lea		Gadget3,a1	    ;get on/off gadget
	move.w		gg_Flags(a1),d1     ;get flags
	andi.w		#SELECTED,d1	    ;is gadget selected
	beq.s		HideFile	    ;branch if not selected
ShowFile
	moveq		#0,d0		    ;tell requester to display filename
	rts
NoMatch
	lea		Gadget3,a1	    ;get on/off gadget
	move.w		gg_Flags(a1),d1     ;get flags
	andi.w		#SELECTED,d1	    ;is gadget selected
	beq.s		ShowFile	    ;branch if not selected
HideFile
	moveq		#-1,d0		    ;tell requester to skip filename
	rts 


NotWild
	cmpi.w		#FRF_NewWindFunc,d0 ;Are we called by NewWindow ?
	bne.s		NotWind		   ;branch if not window
	move.w		#10,(a0)	   ;set leftedge so can open on lo-res screen
	move.w		#166,nw_Height(a0) ;increase height for gadgets
	rts

NotWind
	cmpi.w		#FRF_AddGadFunc,d0 ;are we called by addgadget
	bne.s		EndFunc		   ;no then quit
	lea		GadgetList1,a1	   ;get gadgetlist to add
	movem.l		a2/a6,-(sp)	   ;store regs used
	sub.l		a2,a2		   ;clear a2
	moveq		#-1,d0		   ;gadget position - end of list
	moveq		#-1,d1		   ;number of gadgets - all
	CALLINT		AddGList	   ;add the gadgets
	movem.l		(sp)+,a2/a6	   ;restore regs
EndFunc
	rts				   ;quit
	
;***********************************************************
;	General subroutines called by anybody
;***********************************************************

;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.Called by

;CreatePath(FileRequest)
;		a0

;This routine assumes that a pointer to the pathname buffer
;is placed directly after the FileRequest structure.
		

CreatePath:
	move.l		a2,-(sp)		;save a2
	move.l		a0,a2			;file struct to a2
	move.l		fr_Dir(a2),a0		;directory string to a0
	move.l		fr_SIZEOF(a2),a1	;get destination address
	moveq		#DSIZE,d0		;get size
	CALLEXEC	CopyMem			;and copy dir string
	
	move.l		fr_SIZEOF(a2),a0	;get path (dest) address
	move.l		fr_File(a2),a1		;get file string
	CALLARP		TackOn			;and tack onto dir string
	move.l		(sp)+,a2		;restore a2
	rts					;and quit

;===========================================================
;a simple routine to put text to the screen without any formatting.

;	puts (String)
;		a2

puts:
	moveq		#0,d1		;x pos
	moveq		#0,d0		;y pos
	move.b		#0,36(a2)	;set max string length
	move.l		a2,ITextPtr	;set text pointer in intuitext
	lea		IText,a1	;get intuitext struct
	move.l		RPort,a0	;get rastport
	CALLINT		PrintIText	;print string
	rts

Intname
	INTNAME			;macro for Intuition lib name
	
Grafname:
	GRAFNAME		;macro for graphics lib name


;***********************************************************
	SECTION Display_Data,DATA
;***********************************************************

NewScreenStructure:
	dc.w	0,0		;screen XY origin relative to View
	dc.w	320,200		;screen width and height
	dc.w	4		;screen depth (number of bitplanes)
	dc.b	0,1		;detail and block pens
	dc.w	0		;display modes for this screen
	dc.w	CUSTOMSCREEN	;screen type
	dc.l	Font80		;pointer to default screen font
	dc.l	NULL		;screen title
	dc.l	NULL		;first in list of custom screen gadgets
	dc.l	NULL		;pointer to custom BitMap structure

Palette:
	dc.w	$005A		;color #0
	dc.w	$0FFF		;color #1
	dc.w	$0002		;color #2
	dc.w	$0F80		;color #3
	dc.w	$000F		;color #4
	dc.w	$0F0F		;color #5
	dc.w	$00FF		;color #6
	dc.w	$0FFF		;color #7
	dc.w	$0620		;color #8
	dc.w	$0E50		;color #9
	dc.w	$09F1		;color #10
	dc.w	$0EB0		;color #11
	dc.w	$055F		;color #12
	dc.w	$092F		;color #13
	dc.w	$00F8		;color #14
	dc.w	$0CCC		;color #15

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
  	dc.w	CUSTOMSCREEN
  
MYTITLE:
  	dc.b 	"FileRequester",0  
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
  	dc.l	0				;user-definable data			;SpecialInfo structure
  	dc.w 	1				;pointer to user-definable data
  	dc.l	Load			        ;my extension 
  	
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
  	dc.l	0				;user-definable data			;SpecialInfo structure			;gadget mutual-exclude long word
  	dc.w	2				;pointer to user-definable data
  	dc.l	Save			        ;my extension 
    
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

GadgetList1:
Gadget3:
	dc.l	Gadget4			;next gadget
	dc.w	14,136			;origin XY of hit box relative to window TopLeft
	dc.w	56,13			;hit box width and height
	dc.w	GADGHIMAGE!GADGIMAGE	;gadget flags
	dc.w	RELVERIFY!TOGGLESELECT	;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Image2			;gadget border or image to be rendered
	dc.l	Image3			;alternate imagery for selection
	dc.l	NULL			;first IntuiText structure
	dc.l	NULL			;gadget mutual-exclude long word
	dc.l	NULL			;SpecialInfo structure
	dc.w	3			;user-definable data
	dc.l	NULL			;pointer to user-definable data
Image2:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.w	62,17			;Image width and height in pixels
	dc.w	4			;number of bitplanes in Image
	dc.l	ImageData2		;pointer to ImageData
	dc.b	$0003,$0000		;PlanePick and PlaneOnOff
	dc.l	NULL			;next Image structure

Image3:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.w	62,17			;Image width and height in pixels
	dc.w	4			;number of bitplanes in Image
	dc.l	ImageData3		;pointer to ImageData
	dc.b	$0003,$0000		;PlanePick and PlaneOnOff
	dc.l	NULL			;next Image structure

Gadget4:
	dc.l	Gadget5			;next gadget
	dc.w	84,136			;origin XY of hit box relative to window TopLeft
	dc.w	56,13			;hit box width and height
	dc.w	GADGHIMAGE!GADGIMAGE	;gadget flags
	dc.w	RELVERIFY!TOGGLESELECT	;activation flags
	dc.w	BOOLGADGET		;gadget type flags
	dc.l	Image4			;gadget border or image to be rendered
	dc.l	Image5			;alternate imagery for selection
	dc.l	IText1			;first IntuiText structure
	dc.l	NULL			;gadget mutual-exclude long word
	dc.l	NULL			;SpecialInfo structure
	dc.w	4			;user-definable data
	dc.l	NULL			;pointer to user-definable data
Image4:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.w	62,17			;Image width and height in pixels
	dc.w	4			;number of bitplanes in Image
	dc.l	ImageData4		;pointer to ImageData
	dc.b	$0003,$0000		;PlanePick and PlaneOnOff
	dc.l	NULL			;next Image structure

Image5:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.w	62,17			;Image width and height in pixels
	dc.w	4			;number of bitplanes in Image
	dc.l	ImageData5		;pointer to ImageData
	dc.b	$0003,$0000		;PlanePick and PlaneOnOff
	dc.l	NULL			;next Image structure

IText1:
	dc.b	0,1,RP_JAM2,0		;front and back text pens, drawmode and fill byte
	dc.w	5,18			;XY origin relative to container TopLeft
	dc.l	NULL			;font pointer or NULL for default
	dc.l	ITextText1		;pointer to text
	dc.l	NULL			;next IntuiText structure
ITextText1:
	dc.b	'Filter',0
	cnop 0,2

Gadget5:
	dc.l	NULL			;next gadget
	dc.w	157,140			;origin XY of hit box relative to window TopLeft
	dc.w	120,9			;hit box width and height
	dc.w	NULL			;gadget flags
	dc.w	RELVERIFY		;activation flags
	dc.w	STRGADGET		;gadget type flags
	dc.l	Border3			;gadget border or image to be rendered
	dc.l	NULL			;alternate imagery for selection
	dc.l	IText2			;first IntuiText structure
	dc.l	NULL			;gadget mutual-exclude long word
	dc.l	Gadget5SInfo		;SpecialInfo structure
	dc.w	5			;user-definable data
	dc.l	NULL			;pointer to user-definable data
Gadget5SInfo:
	dc.l	Gadget5SIBuff		;buffer where text will be edited
	dc.l	NULL			;optional undo buffer
	dc.w	0			;character position in buffer
	dc.w	30			;maximum number of characters to allow
	dc.w	0			;first displayed character buffer position
	dc.w	0,0,0,0,0		;Intuition initialized and maintained variables
	dc.l	0			;Rastport of gadget
	dc.l	0			;initial value for integer gadgets
	dc.l	NULL			;alternate keymap (fill in if you set the flag)
Gadget5SIBuff:
	dc.b	'*.info',0
	dcb.b	23,0
	EVEN

IText2:
	dc.b	0,1,RP_JAM2,0		;front and back text pens, drawmode and fill byte
	dc.w	30,14			;XY origin relative to container TopLeft
	dc.l	NULL			;font pointer or NULL for default
	dc.l	ITextText2		;pointer to text
	dc.l	NULL			;next IntuiText structure
ITextText2:
	dc.b	'Pattern',0
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


Border3:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.b	0,3,RP_JAM2		;front pen, back pen and drawmode
	dc.b	5			;number of XY vectors
	dc.l	BorderVectors3		;pointer to XY vectors
	dc.l	NULL			;next border in list

BorderVectors3:
	dc.w	-1,-1
	dc.w	120,-1
	dc.w	120,8
	dc.w	-1,8
	dc.w	-1,-1
	

IText
	dc.b	1,0
	dc.b	1,0
	dc.w	26,40
	dc.l	Font80
ITextPtr:
	dc.l	0
	dc.l	0

ClrString:
	dcb.b	36,32		;string of just spaces to clear text
	dc.w	0		;NULL plus padd byte for alignment
	
WildCardString:
	dcb.b	32,0		;this buffer is used by PreParse()

;***********************************************************
;	FileRequester Structures
;***********************************************************

;------	hail text is what will appear in requesters window title	

Requesterflags	EQU	FRF_NewWindFunc!FRF_DoWildFunc!FRF_AddGadFunc

LoadFileStruct:
	dc.l		LoadText	;pointer to hail text
	dc.l		LoadFileData	;pointer to filename buffer
	dc.l		LoadDirData	;pointer to path buffer
	dc.l		NULL		;window to attach to - none if on WB
	dc.b		Requesterflags	;flags - none
	dc.b		0		;reserved
	dc.l		FileRQFunction	;fr_Function
	dc.l		0		;reserved2

;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset
	dc.l		LoadPathName
	
SaveFileStruct:
	dc.l		SaveText	;pointer to hail text
	dc.l		SaveFileData	;pointer to filename buffer
	dc.l		SaveDirData	;pointer to path buffer
	dc.l		NULL		;window to attach to - none if on WB
	dc.b		Requesterflags!FRF_DoColor
	dc.b		0		;reserved
	dc.l		FileRQFunction	;fr_Function
	dc.l		0		;reserved2
	
;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset
	dc.l		SavePathName

;------	This is the text for requesters title
LoadText:
	dc.b	'Load',0
SaveText:
	dc.b	'Save',0

;***********************************************************
	SECTION	FileRequest,BSS
;***********************************************************

LoadFileData:
	ds.b	FCHARS+1	;reserve space for filename buffer
	EVEN
	
LoadDirData:
	ds.b	DSIZE+1		;reserve space for path buffer
	EVEN
	
LoadPathName:
	ds.b	DSIZE+FCHARS+2	;reserve space for full pathname name buffer
	EVEN
	
SaveFileData:
	ds.b	FCHARS+1	;reserve space for filename buffer
	EVEN
	
SaveDirData:
	ds.b	DSIZE+1		;reserve space for path buffer
	EVEN
	
SavePathName:
	ds.b	DSIZE+FCHARS+2	;reserve space for full pathname name buffer
	
;***********************************************************
	SECTION	Variables,BSS
;***********************************************************	

ScreenPtr:
	ds.l	1		;storage for screen pointer
MPort:	
	ds.l	1		;storage for message port pointer
Message:	
	ds.l	1		;storage for pointer to message
_ArpBase:
	ds.l	1		;storage for Arp lib pointer
_GfxBase:
	ds.l	1		;storage for graphics lib pointer
_IntuitionBase:
	ds.l	1		;storage for Intuition lib pointer
WindowPtr:
	ds.l	1		;storage for window structure pointer 
RPort:
	ds.l	1		;storage for windows rastport pointer
returnMsg:
	ds.l	1		;storage for workbench message

;***********************************************************
	SECTION	GadgetImages,DATA_C
;***********************************************************

;------	This is just the data used to render the two bool gadgets
;	in the FileRequester (Include/Exclude and On/Off)
ImageData2:
	dc.w	$0000,$0000,$0000,$003F,$7FFF,$FFFF,$FFFF,$FFBF
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$00FF,$FFE3,$FFF8,$FF83,$4CFF,$FFF3,$FFFC,$FF83
	dc.w	$4FCE,$61F3,$CCE4,$E183,$43E4,$CCF3,$CCC8,$CC83
	dc.w	$4FF1,$CFF3,$CCCC,$C083,$4CE4,$CCF3,$CCCC,$CF83
	dc.w	$00CE,$61E1,$E262,$6183,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$0000,$0000,$0000,$0003,$F000,$0000,$0000,$0003
	dc.w	$F000,$0000,$0000,$0003,$FFFF,$FFFF,$FFFF,$FFC0
	dc.w	$8000,$0000,$0000,$0040,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$FFFF,$FFFF,$FFFF,$FFFC
	dc.w	$0FFF,$FFFF,$FFFF,$FFFC,$0FFF,$FFFF,$FFFF,$FFFC

ImageData3:
	dc.w	$0000,$0000,$0000,$003F,$7FFF,$FFFF,$FFFF,$FFBF
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$40FF,$FFE3,$FFF8,$FF83,$73FF,$FFF3,$FFFC,$FF83
	dc.w	$73C1,$E1F3,$CCE4,$E183,$73CC,$CCF3,$CCC8,$CC83
	dc.w	$73CC,$CFF3,$CCCC,$C083,$73CC,$CCF3,$CCCC,$CF83
	dc.w	$40CC,$E1E1,$E262,$6183,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$0000,$0000,$0000,$0003,$F000,$0000,$0000,$0003
	dc.w	$F000,$0000,$0000,$0003,$FFFF,$FFFF,$FFFF,$FFC0
	dc.w	$8000,$0000,$0000,$0040,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$FFFF,$FFFF,$FFFF,$FFFC
	dc.w	$0FFF,$FFFF,$FFFF,$FFFC,$0FFF,$FFFF,$FFFF,$FFFC

ImageData4:
	dc.w	$0000,$0000,$0000,$003F,$7FFF,$FFFF,$FFFF,$FFBF
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$7FFF,$F1F8,$F8FF,$FF83,$7FFF,$E4F2,$727F,$FF83
	dc.w	$7FFF,$CE73,$F3FF,$FF83,$7FFF,$CE61,$E1FF,$FF83
	dc.w	$7FFF,$CE73,$F3FF,$FF83,$7FFF,$E4F3,$F3FF,$FF83
	dc.w	$7FFF,$F1E1,$E1FF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$0000,$0000,$0000,$0003,$F000,$0000,$0000,$0003
	dc.w	$F000,$0000,$0000,$0003,$FFFF,$FFFF,$FFFF,$FFC0
	dc.w	$8000,$0000,$0000,$0040,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$FFFF,$FFFF,$FFFF,$FFFC
	dc.w	$0FFF,$FFFF,$FFFF,$FFFC,$0FFF,$FFFF,$FFFF,$FFFC

ImageData5:
	dc.w	$0000,$0000,$0000,$003F,$7FFF,$FFFF,$FFFF,$FFBF
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$7FFF,$FE3F,$FFFF,$FF83,$7FFF,$FC9F,$FFFF,$FF83
	dc.w	$7FFF,$F9CC,$1FFF,$FF83,$7FFF,$F9CC,$CFFF,$FF83
	dc.w	$7FFF,$F9CC,$CFFF,$FF83,$7FFF,$FC9C,$CFFF,$FF83
	dc.w	$7FFF,$FE3C,$CFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$7FFF,$FFFF,$FFFF,$FF83,$7FFF,$FFFF,$FFFF,$FF83
	dc.w	$0000,$0000,$0000,$0003,$F000,$0000,$0000,$0003
	dc.w	$F000,$0000,$0000,$0003,$FFFF,$FFFF,$FFFF,$FFC0
	dc.w	$8000,$0000,$0000,$0040,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$8000,$0000,$0000,$007C
	dc.w	$8000,$0000,$0000,$007C,$FFFF,$FFFF,$FFFF,$FFFC
	dc.w	$0FFF,$FFFF,$FFFF,$FFFC,$0FFF,$FFFF,$FFFF,$FFFC


