;***********************************************************
;	
;			68000 Help    
;		  Re-coded by Steve Marshall
;		     from the original  
;		       by Mark Meany 
;	    	  Compiles with Devpac V2
;
;	I was going to use a rather sneaky string search
;	routine but decided to use Mark's so as the text
;	already written could be used without change.This
;	version uses a string gadget to enter the mnemonic 
;	but uses a console to output the text.This simplifies
;	the text output routine (not loads of intuitext structs)
;	and also allows us to use control sequences within the
;	text to allow bold,reverse,italic underlines etc.
;	
;***********************************************************

	INCDIR	 	"SYS:INCLUDE/"
	INCLUDE 	Intuition/Intuition.i
	INCLUDE 	Intuition/Intuition_lib.i
	INCLUDE		Graphics/Graphics_lib.i
 	INCLUDE 	Exec/Exec_lib.i
	INCLUDE		Libraries/Dos.i
	INCLUDE		Libraries/Dos_lib.i
	INCLUDE		Libraries/Dosextens.i

		
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
	moveq		#0,d0			;clear d0 (any lib version)
  	lea		DOSname(pc),a1		;lib name in a1
  	CALLEXEC	OpenLibrary		;try to open library
  	move.l		d0,_DOSBase		;store lib base
  	beq		DOSError		;cleanup and quit if fail

  	moveq		#0,d0			;clear d0 (any lib version)
  	lea		Grafname(pc),a1		;lib name in a1
  	CALLEXEC	OpenLibrary		;try to open library
  	move.l		d0,_GfxBase		;store lib base
  	beq		GfxError		;cleanup and quit if fail
  	
  	moveq		#0,d0			;clear d0 (any lib version)
  	lea		Intname(pc),a1		;lib name in a1
  	CALLSYS		OpenLibrary		;try to open library
  	move.l		d0,_IntuitionBase	;store lib base
  	beq		IntError		;cleanup and quit if fail
  	
;------ open a window
  	lea 		MyNewWindow,a0		;new window structure in a0
  	CALLINT		OpenWindow		;open window
  	move.l 		d0,WindowPtr		;store window pointer
  	beq 		WdwError		;quit if no window opened
  	
  	move.l		d0,a1			;move window pointer to a1
  	move.l		wd_RPort(a1),a1		;get rastport

ActivateString  	
  	lea		MyGadget2,a0		;gadget address in a0
  	move.l		WindowPtr,a1		;window address in a1
  	sub.l		a2,a2			;clear a2 - not a requester
	CALLINT		ActivateGadget		;activate string gadget
	tst.l		d0			;was we successfull ?
	beq.s		ActivateString		;no try again

  	
;------ wait for an Intuition message
Loop:
  	move.l 		WindowPtr,a0		;window ptr in a0
  	move.l 		wd_UserPort(a0),a0	;get windows message port
  	move.l 		a0,MPort		;and store it
 	CALLEXEC 	WaitPort		;wait for a message
 	
;------ get the message
  	move.l 		MPort,a0		;message port in a0
  	CALLSYS		GetMsg			;get message
  	tst 		d0			;do we have a message ?
  	beq.s 		Loop 			;no then try again

;------ store message 
  	move.l 		d0,a1			;move message to a1
  	move.l 		a1,Message		;store message
  	
;------ test for message type and act accordingly
  	move.l 		im_Class(a1),d1		;get message type
  	cmp.l 		#CLOSEWINDOW,d1		;was it closewindow ?
  	beq.s	 	KillWindow		;yes then quit
  	
;------ test for gadgets
	cmp.l		#GADGETUP,D1		;was it gadgetup
  	bne.s		NotGadget		;no then reply and loop
	bsr.s		Do_Gadget		;do gadget routine

;------ reply to message then loop back to go again
NotGadget
  	move.l 		Message,a1		;message in a1
  	CALLEXEC	ReplyMsg		;reply to intuition
  	bra.s		Loop			;loop back and go again
  						;do not collect £200


;------ close window
KillWindow:
  	move.l 		WindowPtr,a0		;window pointer in a0
  	CALLINT 	CloseWindow		;and close it
  	
WdwError:  
  	move.l 		_IntuitionBase,a1	;intuition lib base in a1
  	CALLEXEC 	CloseLibrary		;close intuition

IntError
	move.l 		_GfxBase,a1		;graphics lib base in a1
  	CALLEXEC 	CloseLibrary		;close graphics
  	
GfxError
	move.l		_DOSBase,a1		;DOS lib base in a1
  	CALLEXEC 	CloseLibrary		;close DOS
  	
DOSError
	rts					;quit
	
;	End of Main Program

;***********************************************************
;	Subroutines called by gadgets etc.
;***********************************************************
;------	this bit is a litle more complicated than nesessary but
;	is written so that the program may be expanded later
Do_Gadget:
	move.l 		im_IAddress(a1),a0	;get gadgets address
	move.w		gg_GadgetID(a0),d0	;get gadgets ID number
	cmpi.b		#1,d0			;is it the OK gadget
	beq.s		BoolGadget		;yes then do bool
	cmpi.b		#2,d0			;is it the string gadget
	beq.s		BoolGadget		;if yes do same as for bool
	rts					;no then quit
	
BoolGadget
	lea		GadgetBuffer,a0		;get string from gadget
	lea		String,a1		;get temp buffer
	moveq		#7,d1			;number of chars -1
TextLoop
	move.b		(a0)+,d0		;char into d0
	cmpi.b		#'.',d0			;is it a .
	beq.s		TextOK			;yes then leave it alone
	bclr		#5,d0			;no then make it upper case
TextOK
	move.b		d0,(a1)+		;copy modified char to buffer
	dbra		d1,TextLoop		;loop if not done

	lea		String,a1		;get users word
	lea		StrgInfo,a2		;get stinginfo address
	moveq		#0,d2			;clear d2
	move.w		si_NumChars(a2),d2	;get number of chars
	bsr.s		find			;find mnemonic
	tst.l		d0			;was it found ?
	bne.s		Found			;yes then branch
	lea		ErrorText(pc),a5	;no - get error msg
	bra.s		PrtOutput		;and print it
Found	
	move.l		a0,a5			;save text address

PrtOutput
	lea		ConName(pc),a0		;get console name
	move.l		a0,d1			;and put in d1
	move.l		#MODE_OLDFILE,d2	;set open mode
	CALLDOS		Open			;and open console
	move.l		d0,d7			;store con handle
	beq.s		NotRecognised		;and branch if not opened
	
	move.l		a5,a0			;restore text ptr
	bsr.s		puts			;and print it
	
.loop
	btst 		#6,$bfe001		;check for left mouseclick
	bne.s		.loop 			
	btst		#2,$dff016		;check for right mouseclick
	bne.s		.loop 
	
	move.l		d7,d1			;get con handle
	CALLSYS		Close			;and close console
	
NotRecognised
	rts					;and quit		
	
		

; A subroutine that takes the users input and tries to find a match in a
;predefined list of supported words. No match is indicated by setting d0=0

find	lea	list,a0	a0-->start of known word list
	move.l	(a0)+,d1	d1=number of words in list

;  Subroutine to search through a list of words checking each for a match
; with a supplied word. Each word in the list is preceded by its ID number
; (1 byte) and its length (1 byte). On exit d0 contains the ID number of
; the word if found and zero otherwise. This obviously means that all ID
; numbers must be non zero. All ID numbers are treated as unsigned.
;
;ENTRY :	a0-->The list of words
;	a1-->The word to find
;	d1=number of words in the list
;	d2=the length of the word to find
;EXIT  :	d0=The words ID ( encoded in table as explained above )

CHKWRD	moveq.l	#0,d0	clear d0
	move.b	(a0)+,d0	read past words ID
	move.b	(a0)+,d0	d0=next entries length
	cmp.b	d0,d2	same as required length?
	bne.s	NXTWRD	if not then next word
	move.l	a0,a2	a2-->word in list
	move.l	a1,a3	a3-->word to find
	subi.b	#1,d0	decrease char count
CHKNXTBYT	cmp.b	(a2)+,(a3)+	compare chars+step to next
	bne.s	NOMATCH	if diffirent then exit loop
	dbra	d0,CHKNXTBYT	if same check next until fin
	moveq.l	#0,d0	clear d0
	suba.l	#2,a0	a0-->word ID
	move.b	(a0),d0	d0=word ID
	bra.s	CHKWRDFIN	all done so leave
NOMATCH	suba.l	#1,a0	a0-->word len
	move.b	(a0)+,d0	d0=word len
NXTWRD	and.l	#$ff,d0	mask off word len
	add.l	d0,a0	add to list pointer
	dbra	d1,CHKWRD	loop back till list checked
	moveq.l	#0,d0	d0=0 (word not found)
	bra.s	not_found
CHKWRDFIN	subi.w	#1,d0	correct offset
	asl.w	#2,d0	multiply by 4 
	lea	def_table,a0	a0-->pointer table
	adda.l	d0,a0	add offset
	move.l	(a0),a0	a0-->required data
	not.w	d0	make non zero (word found)
not_found	rts

;	puts(textpointer,filehandle)
;	         a0	     d0

puts:
	movem.l		d2-d3/a6,-(sp)		;save modified regs
	move.l		d0,d1			;output handle in d1
	beq.s		.noOutput		;no output - then quit
	move.l		a0,d2			;address of text in d2
	moveq		#-1,d3			;initialise d3 to for loop

	;------ Count the number of chars
.Count
	tst.b		(a0)+			;check for end of text
	dbeq		d3,.Count		;decrement d3 and loop
	neg.l		d3			;make d3 positive
	subq.l		#1,d3			;count -1 (forget the 0)
	CALLDOS		Write			;write message
.noOutput:
	movem.l		(sp)+,d2-d3/a6		;restore regs
	rts	


; List of all recognised mnemonics

	even
list	dc.l	2
	dc.b	1,4,'ADDA'
	dc.b	2,5,'MOVEM'
	
; Pointer table to definition texts

	even
def_table	dc.l	t1
	dc.l	t2
	dc.l	t3
	
; Mnemonic definitions

ErrorText	
	dc.b	$0a,'Mnemonic not recognised.'
	dc.b	$0a,'Complain to author.',0

t1
	dc.b	$0a,$9b,'32;41m ADDA '
	dc.b	$9b,'31;40m     <effective address>,An'
	dc.b	$0a,$0a,'SIZE = (WORD,LONG)',0 
	
t2	
	dc.b	$0a,$9b,'32;41m MOVEM '
	dc.b	$9b,'31;40m    <register list>,<ea>'
	dc.b	$0a,$0a,$9b,'32;41m MOVEM '
	dc.b	$9b,'31;40m    <ea>,<register list>'
	dc.b	$0a,$0a,'SIZE = (WORD,LONG)',0
	even
	
t3	dc.w	1
	dc.b	'Something has gone wrong !!!!',0
	even
	



;===========================================================

;------	Constants,Strings etc.	

ConName:
	dc.b	'CON:200/10/340/210/Click Both MouseButtons to Continue',0

DOSname
	DOSNAME			;macro for DOS lib name	
Grafname
	GRAFNAME		;macro for Graphics lib name
Intname
	INTNAME			;macro for Intuition lib name

;***********************************************************
	SECTION Display_Data,DATA
;***********************************************************

;------ window structure
MyNewWindow 
  	dc.w 		475,0
  	dc.w 		165,30
  	dc.b 		-1,-1
  	dc.l 		CLOSEWINDOW!MENUPICK!GADGETUP
  	dc.l 		WINDOWDRAG!WINDOWDEPTH!WINDOWCLOSE!ACTIVATE
  	dc.l 		MyGadget1
  	dc.l 		NULL
  	dc.l 		MYTITLE  
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.w 		0,0
  	dc.w 		0,0
  	dc.w 		WBENCHSCREEN
  
MYTITLE:
  	dc.b 		"68k Help",0  
  	EVEN

Font60:	dc.l		FontName
	dc.w		9
	dc.b		0
	dc.b		0
	
FontName:
	dc.b		"topaz.font",0
	EVEN  	

MyGadget1:
  	dc.l 		MyGadget2		;next gadget in list
  	dc.w 		113,15,30,9		;left, top, width, height
  	dc.w 		GADGHCOMP		;general flags
  	dc.w 		GADGIMMEDIATE|RELVERIFY	;activation flags
  	dc.w 		BOOLGADGET		;gadget type
  	dc.l 		MyBorder1		;pointer to primary Border
  	dc.l 		NULL			;pointer to selected image
  	dc.l		GadgetIText		;pointer to IntuiText
  	dc.l 		0			;mutual exclude bit field
  	dc.l 		0			;no special info for a boolean gadget
  	dc.w 		1			;gadget ID
  	dc.l		NULL			;no known user data
  	
GadgetIText:
	dc.b		1,0			;frontpen,backpen
	dc.b		1,0			;drawmode (JAM1),PAD
	dc.w		5,1			;left edge,Top edge
	dc.l		Font60			;Font
	dc.l		Gadg1Text		;pointer to text
	dc.l		0			;no more intuitext structures
	
Gadg1Text:
	dc.b		'OK',0		;gadget text string
	EVEN
  	
MyBorder1
  	dc.w 	0,0			;left edge,top edge
  	dc.b 	1,0,0			;frontpen,backpen,drawmode
  	dc.b	5			;number of coordinates
  	dc.l 	Coordinates		;pointer to coordinates
  	dc.l	0			;no more borders

;------ These are the coordinates that describe the border   
Coordinates
  	dc.w 		-2,-2
  	dc.w		32,-2
  	dc.w		32,10
  	dc.w		-2,10
  	dc.w		-2,-2


MyGadget2:
  	dc.l	NULL			;last gadget in list
  	dc.w 	16,15,82,9		;left, top, width, height
  	dc.w 	GADGHCOMP		;general flags
  	dc.w 	GADGIMMEDIATE|RELVERIFY	;activation flags
  	dc.w	STRGADGET		;gadget type
  	dc.l 	MyBorder2		;pointer to primary Border
  	dc.l 	NULL			;pointer to selected image
  	dc.l	NULL			;pointer to IntuiText
  	dc.l	0			;mutual exclude bit field
  	dc.l	StrgInfo		;special info for a string gadget
  	dc.w	2			;gadget ID
  	dc.l	NULL			;no known user data

StrgInfo
  	dc.l	GadgetBuffer		;pointer to text buffer
  	dc.l	UNDO			;pointer to undo buffer
  	dc.w	0			;buffer position
  	dc.w	8			;max num of chars
  	dc.w	0			;first char displayed

;------ intuition handles these next few variables
  	dc.w	0,0,0,0,0
  	dc.l	0

  	dc.l	0			;holds number if this is a longint
  	dc.l	0			;pointer to alternate keymap

MyBorder2
  	dc.w 	0,0			;left edge,top edge
  	dc.b 	1,0,0			;frontpen,backpen,drawmode
  	dc.b	5			;number of coordinates
  	dc.l 	Coordinates2		;pointer to coordinates
  	dc.l	0			;no more borders

;------ These are the coordinates that describe the border   
Coordinates2
  	dc.w 		-8,-2
  	dc.w		82,-2
  	dc.w		82,10
  	dc.w		-8,10
  	dc.w		-8,-2

;***********************************************************
	SECTION	Variables,BSS
;***********************************************************	

MPort:	
	ds.l	1		;storage for message port pointer
Message:
	ds.l	1		;temp storage for message
_DOSBase:
	ds.l	1		;storage for DOS lib pointer
_GfxBase:
	ds.l	1		;storage for Graphics lib pointer
_IntuitionBase:
	ds.l	1		;storage for Intuition lib pointer
WindowPtr:
	ds.l	1		;storage for window structure pointer 
returnMsg:
	ds.l	1		;storage for workbench message
GadgetBuffer:
  	ds.l 	2		;string gadgets string buffer  
UNDO: 
  	ds.l 	2		;string gadgets undo buffer
String
	ds.l	2		;temp storage for string
  		
