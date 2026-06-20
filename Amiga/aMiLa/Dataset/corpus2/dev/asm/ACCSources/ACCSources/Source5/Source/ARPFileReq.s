***********************************************************************
*
*	Short Program to Demonstrate the use of ARP's
*
*			FileRequester
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
  	
;------ open a window 
  	lea 		MyNewWindow,a0		;pointer to newwindow struct
  	CALLINT		OpenWindow		;and open it
  	move.l 		d0,WindowPtr		;store window pointer	
  	beq 		WdwError		;quit if fail
  	move.l		d0,a0			;move window ptr to a0
  	move.l		wd_RPort(a0),RPort	;and get rastport
  	
  	move.l		RPort,a0		;rastport to a0
  	lea		MyBorder2,a1		;get address of border
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
  	bra	 	Loop			;loop back and go again

;------ remove menu and close window
KillWindow:
  	move.l 		WindowPtr,a0		;get window pointer
  	CALLINT 	CloseWindow		;and close it
WdwError:  	
  	move.l 		_IntuitionBase,a1	;intuition lib base in a1
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
	lea		ClrString,a2		;get blank string
	bsr		puts			;and erase old text
	
	lea		LoadFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester
	tst.l		d0			;did the user cancel ?
	beq		NoPath			;yes then quit
	
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

SaveMOD:
	lea		ClrString,a2		;get blank string
	bsr		puts			;and erase old text
	
	lea		SaveFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester 
	tst.l		d0			;did the user cancel ?
	beq		NoPath2			;yes then quit
	
	lea		SaveFileStruct,a0	;get file struct
	bsr		CreatePath		;make full pathname
	tst.b		SavePathName		;is there a pathname ?
	beq.s		NoPath2			;no - then quit
	lea		SavePathName,a2		;yes then get its address
	bsr		puts			;and print it
	
NoPath2
	rts					;and return to calling routine
	
;***********************************************************
;	General subroutines called by anybody
;***********************************************************

;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.Called by

;CreatePath(FileRequest)
;		a0

;This routine assumes that memory has been allocated for the pathname
;string directly after the FileRequest structure.
		

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
	moveq		#0,d1
	moveq		#0,d0
	move.l		RPort,a0
	move.l		a2,ITextPtr
	lea		IText,a1
	CALLINT		PrintIText
	rts

Intname
	INTNAME			;macro for Intuition lib name


;***********************************************************
	SECTION Display_Data,DATA
;***********************************************************

;------ window structure
MyNewWindow 
  	dc.w 		10,20
  	dc.w 		400,52
  	dc.b 		-1,-1
  	dc.l 		CLOSEWINDOW!MENUPICK!GADGETUP
  	dc.l 		WINDOWDRAG!WINDOWDEPTH!WINDOWCLOSE!ACTIVATE
  	dc.l 		MYGADGET1
  	dc.l 		NULL
  	dc.l 		MYTITLE  
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.w 		255,111
  	dc.w 		320,160
  	dc.w 		WBENCHSCREEN
  
MYTITLE:
  	dc.b 		"FileRequester",0  
  	EVEN

Font80:	dc.l		FontName
	dc.w		8
	dc.b		0
	dc.b		0
	
FontName:
	dc.b		"topaz.font",0
	EVEN  	
  	

MYGADGET1:
  	dc.l 		MYGADGET2
  	dc.w 		15,15,50,20
  	dc.w 		GADGHCOMP
  	dc.w 		GADGIMMEDIATE|RELVERIFY
  	dc.w 		BOOLGADGET
  	dc.l 		MyBorder
  	dc.l 		NULL
  	dc.l		Gadget1IText
  	dc.l 		0
  	dc.l 		0
  	dc.w 		1
  	dc.l		Load
  	
Gadget1IText:
	dc.b		1,0
	dc.b		1,0
	dc.w		8,6
	dc.l		Font80
	dc.l		Gadg1Text
	dc.l		0
	
Gadg1Text:
	dc.b		'LOAD',0
	EVEN
    
MYGADGET2:
  	dc.l 		NULL
  	dc.w 		336,15,50,20
  	dc.w 		GADGHCOMP
  	dc.w 		GADGIMMEDIATE|RELVERIFY
  	dc.w 		BOOLGADGET
  	dc.l 		MyBorder
  	dc.l 		NULL
  	dc.l		Gadget2IText
  	dc.l 		0
  	dc.l 		0
  	dc.w 		2
  	dc.l		SaveMOD
    
Gadget2IText:
	dc.b		1,0
	dc.b		1,0
	dc.w		8,6
	dc.l		Font80
	dc.l		Gadg2Text
	dc.l		0
	
Gadg2Text:
	dc.b		'SAVE',0
	EVEN

;***********************************************************
;	Border Structure
;***********************************************************

MyBorder:
  	dc.w 		0,0
  	dc.b 		1,0,0
  	dc.b 		5
  	dc.l 		Coordinates
  	dc.l 		0
  
Coordinates:
  	dc.w 		-2,-1
  	dc.w		50,-1
  	dc.w		50,20
  	dc.w		-2,20
  	dc.w		-2,-1
  	
MyBorder2:
  	dc.w 		0,0
  	dc.b 		1,0,0
  	dc.b 		5
  	dc.l 		Coordinates2
  	dc.l 		0
  
Coordinates2:
  	dc.w 		6,38
  	dc.w		6,48
  	dc.w		394,48
  	dc.w		394,38
  	dc.w		6,38

IText
	dc.b		1,0
	dc.b		1,0
	dc.w		30,40
	dc.l		Font80
ITextPtr:
	dc.l		0
	dc.l		0

ClrString:
	dcb.b		45,32
	dc.b		0

;***********************************************************
;	FileRequester Structures
;***********************************************************

LoadFileStruct:
	dc.l		LoadText
	dc.l		LoadFileData
	dc.l		LoadDirData
	dc.l		NULL
	dc.w		0
	dc.l		0
	dc.l		0
	dc.l		LoadPathName
	
SaveFileStruct:
	dc.l		SaveText
	dc.l		SaveFileData
	dc.l		SaveDirData
	dc.l		NULL
	dc.b		FRF_DoColor
	dc.b		0
	dc.l		0
	dc.l		0
	dc.l		SavePathName

LoadText:
	dc.b	'Load',0
SaveText:
	dc.b	'Save',0

;***********************************************************
	SECTION	FileRequest,BSS
;***********************************************************

FileInfo:
	ds.b	fib_SIZEOF
	EVEN
	
LoadFileData:
	ds.b	FCHARS+1
	EVEN
	
LoadDirData:
	ds.b	DSIZE+1
	EVEN
	
LoadPathName:
	ds.b	DSIZE+FCHARS+2
	EVEN
	
SaveFileData:
	ds.b	FCHARS+1
	EVEN
	
SaveDirData:
	ds.b	DSIZE+1
	EVEN
	
SavePathName:
	ds.b	DSIZE+FCHARS+2
	
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

