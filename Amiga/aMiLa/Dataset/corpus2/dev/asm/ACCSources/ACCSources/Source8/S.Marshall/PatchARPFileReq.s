***********************************************************************
*	After  using  other  FileRequesters I got quite  used to having
*	a pattern or  wilcarding system. So I thought it  would be nice 
*	to add  something similar  to the ARP  requester, so this short
*	program  was born. It was mainly  intended for  use with Devpac
*	but I made it  flexible enough  so a number  of other  programs
*	could  use it. PPMore for  instance also  uses  the fr_Function
*	to  reposition  the requester  so I had  to make sure that this
*	program  passed control  to the other  programs function when I 
*	was finished with it.
*
*	Program  to patch  the Arp  libraries  FileRequester  function.
*	Adds  three  extra  gadgets  to  the  requester. These  gadgets 
*	allow  you to  use  wildcards to  decide  which  files  will be
*	displayed  ie '.info' with  gadget  set to  Exclude  will  stop
*	any icons  from being  displayed  or '(*.s|*.asm)' with  gadget
*	set to  Include will only  display files  ending  in .s or .asm
*	(standard assembler files).All standard wildcards are supported
*	(#,#?,?,* etc). You  could  also use  (a*.s|b.asm)  which would
*	display  all  files  starting with a end  ending in .s  and all
*	files  starting  with b and  ending  in .asm. All  searches are
*	case independant. All directories  will be shown no matter what
*	the filter is set to.
*	
*	Version 0.4 - First release (16/10/90)
*
*	Version 0.5 - Second release (18/10/90)  Added an opencount to
*	stop  people  removing the patch whilst  it was in use - could
*	have caused a guru. Also added  undo buffer  to string gadget. 
*
*	   By S.Marshall - Compiles with Devpac V2
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
	
	moveq		#0,d0			;lib version - any
	lea		IntName(pc),a1		;lib name
	CALLEXEC	OpenLibrary		;open it
	move.l		d0,_IntuitionBase	;store lib base
	beq.s		IntError		;branch if not opened
	
	move.l		_ArpBase,a1		;lib base in a1
	move.l		#_LVOFileRequest,a0	;offset in a0
	lea		FileReqPatch,a2		;new filerequest address
	move.l		a2,d0			;move address to d0

;------	Note - we can SetFunction() the ARP library and all the DOS
;	routines in it. You cannot however SetFunction() the DOS lib. 
	
	CALLEXEC	SetFunction		;patch FileRequest
	move.l		d0,OldFileReq		;save original address
	
	move.l		#$1000,d0		;control C mask (SIGBREAKF_CTRL_C)
;------ wait for ctrl c 
	CALLSYS		Wait			

	move.l		_ArpBase,a1		;lib base in a1
	move.l		#_LVOFileRequest,a0	;offset in a0
	move.l		OldFileReq,d0		;get old FileRequset
	CALLSYS		SetFunction		;and restore

Inuse
;------	use delay to sleep for a while so busy loop
;	doesn't waste too much cpu time
	moveq		#25,d1			;delay set to .5 sec
	CALLARP		Delay			;sleep a while
	tst.w		Opencount		;wait till all users have
	bne.s		Inuse			;finished with FileRequest()
	
	move.l 		_IntuitionBase,a1	;Arp lib base in a1
  	CALLEXEC 	CloseLibrary		;close Arp
	
IntError
	move.l 		_ArpBase,a1		;Arp lib base in a1
  	CALLSYS 	CloseLibrary		;close Arp
  
Error
	rts					;quit
	
;	End of Main Program

IntName:
	dc.b	'intuition.library',0


;***********************************************************
	SECTION	PatchCode,DATA
;***********************************************************

;------	Note this is code but is placed here as we shouldn't 
;	let other programs use our code space. In theory I
;	should have allocated some Public memory then copied
;	all this across, however there is quite bit of relocation
;	to be done - so I didn't bother - for now.
FileReqPatch:
	addq.w		#1,Opencount		;bump opencount
	move.l		fr_Function(a0),OldFunc	;save old fr_Function
	lea		FileRQFunction(pc),a1	;get our function address
	move.l		a1,fr_Function(a0)	;and place in FileRequeststruct
	move.b		fr_Flags(a0),d1		;get old fr_Flags
	movem.l		d1/a0,-(sp)		;save flags and struct
	ori.b		#FRF_DoWildFunc|FRF_NewWindFunc|FRF_AddGadFunc,fr_Flags(a0)	
	move.l		OldFileReq(pc),a1	;get original FileRequest
	jsr		(a1)			;and call it
	movem.l		(sp)+,d1/a0		;restore flags and struct
	move.b		d1,fr_Flags(a0)		;restore flags in struct
	move.l		OldFunc,fr_Function(a0)	;restore fr_Function
	subq.w		#1,Opencount		;decrement opencount
	rts

;***********************************************************
;	Special function called by FileRequester fr_Function
;***********************************************************

FileRQFunction
	cmpi.w		#FRF_DoWildFunc,d0  ;are we called for wildcards
	bne.s		NotWild		    ;branch if not wildcard func
	
	lea		Gadget4(pc),a1	    ;get on/off gadget
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
	move.l		Gadget5SInfo(pc),a0     ;get pattern address
	lea		WildCardString(pc),a1   ;get spare buffer
	CALLARP		PreParse	    ;preparse string for patternmatch
	
	lea		WildCardString(pc),a0   ;get prepared string
	move.l		(sp)+,a1	    ;restore a1
	CALLARP		PatternMatch	    ;check for match
	move.l		(sp)+,a6	    ;restore a6
	tst.l		d0		    ;test result 0 = No match
	beq.s		NoMatch		    ;branch if no match
	
	lea		Gadget3(pc),a1	    ;get on/off gadget
	move.w		gg_Flags(a1),d1     ;get flags
	andi.w		#SELECTED,d1	    ;is gadget selected
	beq.s		HideFile	    ;branch if not selected
ShowFile
	moveq		#0,d0		    ;tell requester to display filename
	rts
NoMatch
	lea		Gadget3(pc),a1	    ;get on/off gadget
	move.w		gg_Flags(a1),d1     ;get flags
	andi.w		#SELECTED,d1	    ;is gadget selected
	beq.s		ShowFile	    ;branch if not selected
HideFile
	moveq		#-1,d0		    ;tell requester to skip filename
	rts 


NotWild
	cmpi.w		#FRF_NewWindFunc,d0 ;Are we called by NewWindow ?
	bne.s		NotWind		   ;branch if not window
	move.w		#166,nw_Height(a0) ;increase height for gadgets
	tst.l		OldFunc		   ;was fr_Function set
	beq.s		nofunc		   ;no then branch
	move.l		OldFunc(pc),a1	   ;get old function address
	jmp		(a1)		   ;and pass control to it
nofunc
	rts

NotWind
	cmpi.w		#FRF_AddGadFunc,d0 ;are we called by addgadget
	bne.s		EndFunc		   ;no then quit
	lea		GadgetList1(pc),a1 ;get gadgetlist to add
	movem.l		a2/a6,-(sp)	   ;store regs used
	sub.l		a2,a2		   ;clear a2
	moveq		#-1,d0		   ;gadget position - end of list
	moveq		#-1,d1		   ;number of gadgets - all
	CALLINT		AddGList	   ;add the gadgets
	movem.l		(sp)+,a2/a6	   ;restore regs
	rts
EndFunc
	tst.l		OldFunc		   ;was fr_Function set
	beq.s		nofunc2		   ;if no then branch
	move.l		OldFunc(pc),a1	   ;get old function address
	jmp		(a1)		   ;and pass control to it
nofunc2
	rts				   ;quit
	
;***********************************************************
;	Gadget structures
;***********************************************************
GadgetList1:
Gadget3:
	dc.l	Gadget4			;next gadget
	dc.w	14,136			;origin XY of hit box relative to window TopLeft
	dc.w	56,13			;hit box width and height
	dc.w	GADGHIMAGE!GADGIMAGE!SELECTED	;gadget flags
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
	dc.w	GADGHIMAGE!GADGIMAGE!SELECTED	;gadget flags
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
	dc.l	Gadget5SIUBuff			;optional undo buffer
	dc.w	0			;character position in buffer
	dc.w	30			;maximum number of characters to allow
	dc.w	0			;first displayed character buffer position
	dc.w	0,0,0,0,0		;Intuition initialized and maintained variables
	dc.l	0			;Rastport of gadget
	dc.l	0			;initial value for integer gadgets
	dc.l	NULL			;alternate keymap (fill in if you set the flag)

Gadget5SIBuff:
	dc.b	'(*.s|*.asm)',0
	dcb.b	18,0
	
Gadget5SIUBuff:
	dcb.b	30,0
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

Border3:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.b	0,2,RP_JAM2		;front pen, back pen and drawmode
	dc.b	5			;number of XY vectors
	dc.l	BorderVectors3		;pointer to XY vectors
	dc.l	Border4			;next border in list

BorderVectors3:
	dc.w	-1,-1
	dc.w	120,-1
	dc.w	120,8
	dc.w	-1,8
	dc.w	-1,-1
	
Border4:
	dc.w	0,0			;XY origin relative to container TopLeft
	dc.b	0,2,RP_JAM2		;front pen, back pen and drawmode
	dc.b	5			;number of XY vectors
	dc.l	BorderVectors4		;pointer to XY vectors
	dc.l	NULL			;next border in list

BorderVectors4:
	dc.w	-2,-2
	dc.w	121,-2
	dc.w	121,9
	dc.w	-2,9
	dc.w	-2,-2
	
WildCardString:
	dcb.b	32,0		;this buffer is used by PreParse()

;***********************************************************	

	EVEN
_ArpBase:
	dc.l	0		;storage for Arp lib pointer
	
_IntuitionBase:
	dc.l	0		;storage for Arp lib pointer

Opencount:
	dc.w	0		;number of current users
	
OldFunc
	dc.l	0		;pointer to callers fr_Function
	
OldFileReq
	dc.l	0		;pointer to original FileRequest

returnMsg:
	dc.l	0		;storage for workbench message
	


;***********************************************************
	SECTION	GadgetStuff,DATA_C
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


