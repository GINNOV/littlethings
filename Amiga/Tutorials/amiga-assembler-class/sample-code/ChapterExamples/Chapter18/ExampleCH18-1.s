; ---------------------------------------------------------------------

; CH18-1.s code example 

; ---------------------------------------------------------------------
	
		include exec/memory.i
		include intuition/intuition.i
		include libraries/dos.i
		include libraries/asl.i
		include libraries/gadtools.i

		include exec/exec_lib.i
		include intuition/intuition_lib.i
		include libraries/dos_lib.i
		include libraries/asl_lib.i
		include	libraries/gadtools_lib.i


		XDEF	_main
		
		
NULL			EQU	   0

TRUE			EQU	   1

_AbsExecBase		EQU	   4

; ---------------------------------------------------------------------

CALLSYS		MACRO
		LINKLIB	_LVO\1,\2
		ENDM

; ---------------------------------------------------------------------

_main		movem.l d3/a2-a3/a5,-(sp)       preserve registers
		move.l	_AbsExecBase,_SysBase	copy of exec library base
		lea	function_stack,a5	for alloc/dealloc operations
		lea 	lib_names,a2
		lea 	lib_base_start,a3
		move.w	#LIBRARY_COUNT-1,d3	loop counter
.loop		movea.l	(a2)+,a1		library name pointer
		moveq	#0,d0			any version will do
		CALLSYS	OpenLibrary,_SysBase
		move.l	d0,(a3)+		store returned base
		dbeq	d3,.loop

		beq.s	lib_error_exit				
		
		; all libraries are open and available for use.
						
		jsr	LockScreen
		beq.s	closedown

		jsr	GetVisInfo
		beq.s	closedown	
		
		jsr	CreateGadgets
		
		beq.s	closedown
		
		jsr	OpenWindow
		beq.s	closedown
		
		jsr	CreateMenu
		beq.s	closedown
		
		jsr	LayoutMenu
		beq.s	closedown

		jsr	InstallMenu
		beq.s	closedown		

		jsr	AllocFileReq
		beq.s	closedown

		; now everything is set up we call the event handler!

		movea.l window_p,a1
		movea.l wd_UserPort(a1),a2	user port address
		jsr	EventHandler		handle user actions

closedown	move.l	(a5)+,d0		retrieve function pointer
		beq.s	lib_normal_exit
		move.l	d0,a0
		jsr	(a0)			and execute routine if it exists!
		bra.s	closedown


lib_normal_exit	lea	lib_base_end,a3		
		moveq	#LIBRARY_COUNT,d2	library count
		jsr	CloseLibs		close libraries
		moveq	#0,d0			clear d0 for O/S
		movem.l  (sp)+,d3/a2-a3/a5      restore registers
		rts				and terminate program

lib_error_exit	moveq	#LIBRARY_COUNT-1,d2		
		sub	d3,d2
		jsr	CloseLibs		close libraries
		moveq	#0,d0			clear d0 for O/S
		movem.l  (sp)+,d3/a2-a3/a5      restore registers		
		rts				and terminate program
		

; ---------------------------------------------------------------------		

; CloseLibs() On entry...

; 	a3 should hold address of the longword location just past 
; 	   that of the first library to close (this is because the 
;	   routine uses a backward reading loop).

; 	d2 should hold count of the number of libraries to close	

CloseLibs	tst.b	d2			test counter
		beq.s	.loop_end		
		movea.l	-(a3),a1		get library base
		CALLSYS	CloseLibrary,_SysBase
		subq.b	#1,d2
		bra.s	CloseLibs
.loop_end	rts

; ---------------------------------------------------------------------					

; LockScreen() and UnlkScreen() on entry... need no register parameters!


LockScreen	lea	workbench_name,a0	pointer to screen name
		CALLSYS	LockPubScreen,_IntuitionBase
		move.l	d0,workbench_p		save returned pointer
		beq.s	.error
		move.l	#UnlkScreen,-(a5)	push deallocation routine address
.error		rts

UnlkScreen	movea.w	#NULL,a0		screen name not needed
		movea.l	workbench_p,a1		screen to unlock
		CALLSYS	UnlockPubScreen,_IntuitionBase
		rts

; ---------------------------------------------------------------------					

; OpenWindow() and ShutWindow() on entry... need no register parameters!


OpenWindow	movea.w	#NULL,a0
		lea	window_tags,a1		start of tag list
		CALLSYS	OpenWindowTagList,_IntuitionBase
		move.l	d0,window_p		save returned pointer
		beq.s	.error
		move.l	#ShutWindow,-(a5)	push deallocation routine address
.error		rts

ShutWindow	movea.l	window_p,a0		window to close
		CALLSYS	CloseWindow,_IntuitionBase
		rts

; ---------------------------------------------------------------------					

; GetVisInfo() and FreeVisInfo() on entry... need no register parameters!


GetVisInfo	movea.l	workbench_p,a0		
		movea.w	#TAG_END,a1		no tags
		CALLSYS	GetVisualInfoA,_GadToolsBase
		move.l	d0,visual_info_p	save returned pointer
		beq.s	.error
		move.l	#FreeVisInfo,-(a5)	push deallocation routine address
.error		rts

FreeVisInfo	movea.l	visual_info_p,a0	
		CALLSYS	FreeVisualInfo,_GadToolsBase
		rts

; ---------------------------------------------------------------------					

; CreateMenu() and FreeMenu() on entry... need no register parameters!


CreateMenu	lea	menu,a0
		movea.w	#TAG_END,a1		no tags
		CALLSYS	CreateMenusA,_GadToolsBase
		move.l	d0,menu_p		save returned pointer
		beq.s	.error
		move.l	#FreeMenu,-(a5)		push deallocation routine address
.error		rts

FreeMenu	movea.l	menu_p,a0		menu to free
		CALLSYS	FreeMenus,_GadToolsBase
		rts

; ---------------------------------------------------------------------					

; LayoutMenu() on entry... needs no register parameters!


LayoutMenu	movea.l	menu_p,a0
		movea.l	visual_info_p,a1
		movea.w	#TAG_END,a2		no tags
		CALLSYS	LayoutMenusA,_GadToolsBase
		tst.l	d0			nothing to deallocate
		rts

; ---------------------------------------------------------------------					

; InstallMenu() and RemoveMenu() on entry... need no register parameters!


InstallMenu	movea.l	window_p,a0
		movea.l	menu_p,a1
		CALLSYS	SetMenuStrip,_IntuitionBase
		tst.l	d0
		beq.s	.error
		move.l	#RemoveMenu,-(a5)	push deallocation routine address
.error		rts

RemoveMenu	movea.l	window_p,a0		target window
		CALLSYS	ClearMenuStrip,_IntuitionBase
		rts

; ---------------------------------------------------------------------	

; AllocFileReq() and FreeFileReq() on entry... need no register parameters!


AllocFileReq	CALLSYS	AllocFileRequest,_AslBase
		move.l	d0,file_request_p	save returned pointer
		beq.s	.error
		move.l	#FreeFileReq,-(a5)	push deallocation routine address
.error		rts

FreeFileReq 	movea.l	file_request_p,a0	requester to close
		CALLSYS	FreeFileRequest,_AslBase
		rts

; ---------------------------------------------------------------------					

; CreateGadgets() and FreeGadgets() on entry... need no register parameters!


CreateGadgets	movem.l	d2/a2,-(a7)		preserve registers

		lea	gadtool_list,a0
		CALLSYS	CreateContext,_GadToolsBase
		tst.l	d0			last_gadget_p
		beq	.error
		move.l	#FreeGadgets,-(a5)	push deallocation routine address


		
		move.l	d0,a0			last_gadget_p
		moveq	#TEXT_KIND,d0
		lea	gadget1,a1		holds gadget details
		lea	gadget1_tags,a2		
		CALLSYS	CreateGadgetA,_GadToolsBase
		tst.l	d0
		beq	.error

		move.l	d0,a0			last_gadget_p
		move.w	#NULL,a2		
		lea	gadget2,a1		holds gadget details
		move.l	visual_info_p,gng_VisualInfo(a1)

		lea	gadtext_list,a3
		
		moveq	#9-1,d2			loop counter for 9 gadgets
.loop		moveq	#TEXT_KIND,d0
		lea	gadget2,a1		holds gadget details
		move.l	(a3)+,gng_GadgetText(a1)
		add.w	#10,gng_TopEdge(a1)
		CALLSYS	CreateGadgetA,_GadToolsBase
		tst.l	d0
		beq.s	.error
		dbeq	d2,.loop
						
		move.l	d0,a0			last_gadget_p
		moveq	#TEXT_KIND,d0
		lea	gadget11,a1		holds gadget details
		lea	gadget11_tags,a2		
		move.l	visual_info_p,gng_VisualInfo(a1)
		CALLSYS	CreateGadgetA,_GadToolsBase
		tst.l	d0
		beq.s	.error

		move.l	window_p,a0
		move.w	#NULL,a1		docs say must be NULL
		CALLSYS	GT_RefreshWindow,_GadToolsBase
		moveq	#1,d0			no errors so clear zero flag

.error		movem.l	(a7)+,d2/a2		restore registers
		rts

FreeGadgets	movea.l	gadtool_list,a0		
		CALLSYS	FreeGadgets,_GadToolsBase
		rts
; ---------------------------------------------------------------------					



; Function name:     EventHandler()

; Purpose:           Handles Intuition events

; Input Parameters:  Address of IDCMP user-port should be in a2. 

; Output parameters: None

; Register Usage:    a0: Used by WaitPort() and GetMsg()  
                     
;                    a1: Used by ReplyMsg()
                     
;                    a2: Holds user-port address

;                    d0: Used by WaitPort() and GetMsg()
                     
;                    d1: Unused but possibly altered by system functions

;                    d2: Used as an exit flag (quit when non-zero)

;		     d3: Used to hold message class field

;		     d4: Used to hold message code field


; Other Notes:       Within EventHandler() all registers are preserved

; ---------------------------------------------------------------------

EventHandler   	movem.l	d0-d4/a0-a2,-(a7)	preserve registers
		clr.l	d2			clear exit flag
EventHandler2	movea.l	a2,a0			port address  
		CALLSYS	WaitPort,_SysBase  
		jsr	GetMessage           
		cmpi.l	#TRUE,d2		exit flag set?
		bne.s	EventHandler2
		move.l	buffer_p,a1		
		beq.s	.no_buffer	 	is a buffer still allocated?
		move.l	buffer_size,d0
		CALLSYS	FreeMem,_SysBase
.no_buffer	movem.l	(a7)+,d0-d4/a0-a2	restore registers
		rts				logical end of routine

; ---------------------------------------------------------------------
                     
GetMessage	movea.l	a2,a0			get port address in a0
		CALLSYS	GetMsg,_SysBase		get the message
		tst.l	d0
		beq.s	GetMessageExit		did it exist?
		movea.l	d0,a1			copy pointer to a1
		move.l	im_Class(a1),d3		copy message class
		move.w	im_Code(a1),d4		copy message code
		CALLSYS	ReplyMsg,_SysBase	then send message back

		cmpi.l	#IDCMP_CLOSEWINDOW,d3
		bne.s	MenuMessage
		moveq	#TRUE,d2		set QUIT signal to exit routine 
		bra.s	GetMessage
		
MenuMessage	cmpi.l	#IDCMP_MENUPICK,d3 	check message class
		bne.s	GetMessage		ignore other message types           	

		cmpi.w	#MENUNULL,d4
		beq.s	GetMessage		ignore if MENUNULL
		lsr.w	#5,d4			extract menu item number
		andi.b	#$3F,d4			(will be either 0 or 1)
		beq.s	SelectFile
		moveq	#TRUE,d2		set QUIT signal to exit routine 
		bra.s	GetMessage
		
SelectFile	jsr	FileHandler

		tst.l	buffer_p		
		beq.s	GetMessage	 	no file in memory
		jsr	WordCount		result in d0
		jsr	DisplayCount
		bra.s	GetMessage		check for more messages!

GetMessageExit	rts				d2 holds exit flag

; ---------------------------------------------------------------------

; Function name:     DisplayCount()

; Purpose:           Display longword value

; Input Parameters:  d0 holds longword value to display

; Output parameters: None

; Register Usage:    a0-a3/d0-d3: Used by various system calls
  
; Other Notes:       All non-scratch registers are preserved

; ---------------------------------------------------------------------

DisplayCount 	movem.l	a2-a3,-(a7)		preserve registers

		move.l	d0,count		save count value		
		lea	format_string,a0
		lea	count,a1
		lea	copychar,a2
		lea 	count_string,a3
		CALLSYS	RawDoFmt,_SysBase
		moveq	#0,d0
		moveq	#0,d1
		move.l	window_p,a0
		move.l	wd_RPort(a0),a0		rastport_p now in a0
		lea	intuitext1,a1
		CALLSYS	PrintIText,_IntuitionBase

		movem.l	(a7)+,a2-a3		restore registers
		rts
		
; ---------------------------------------------------------------------

copychar	move.b	d0,(a3)+		copy character to count_string
		rts
		
; ---------------------------------------------------------------------

; Function name:     FileHandler()

; Purpose:           Handles the identification and loading of file

; Input Parameters:  None

; Output parameters: None

; Register Usage:    a0-a1/d0-d3: Used by various system calls
  
;		     d4: Used to hold pointer to FileInfoBlock

;		     d5: Used to hold file handle
		     
; Other Notes:       All registers are preserved

; ---------------------------------------------------------------------

FileHandler	movem.l	d0-d5/a0-a1,-(a7)	preserve registers

		movea.l	file_request_p,a0	asl requester address
		movea.w	#NULL,a1		no tags are used
		CALLSYS	AslRequest,_AslBase	bring up the requester

		; clear filename buffer (notice 
		;loop stops when a NULL is found)...

clear_filename	move.l	#filename_SIZEOF-1,d0	filename buffer size less 1
		move.l	#filename,a0		our filename buffer
.clear_loop	move.b	#NULL,(a0)+		
		tst.b	(a0)			have we reached a NULL?
		dbeq	d0,.clear_loop

		; now copy the ASL requester directory 
		; entry to our file name buffer...

		move.l	#filename_SIZEOF-1,d0	filename buffer size less 1
		movea.l	file_request_p,a0	ASL requester address
		movea.l	rf_Dir(a0),a0		get start of directory entry
		move.l	#filename,a1		our filename buffer
.copy_loop	move.b	(a0)+,(a1)+		
		tst.b	(a0)			have we reached a NULL?
		dbeq	d0,.copy_loop

		
		; finally add the filename to the 
		; filename buffer...

		movea.l	file_request_p,a0	ASL requester address
		move.l	#filename,d1		our filename buffer
		move.l	rf_File(a0),d2		ASL filename entry
		move.l	#filename_SIZEOF,d3	filename buffer size
		CALLSYS	AddPart,_DOSBase
		
.alloc_fib	moveq	#DOS_FIB,d1		object type
		moveq	#NULL,d2		no tags
		CALLSYS	AllocDosObject,_DOSBase
		move.l	d0,d4			save pointer to fib
		beq	.error0
		
		move.l	#filename,d1		filename start address
		move.l	#MODE_OLDFILE,d2		
		CALLSYS	Open,_DOSBase
		move.l	d0,d5			save file handle for closing
		beq	.error1

		move.l	d5,d1
		move.l	d4,d2
		CALLSYS	ExamineFH,_DOSBase
		tst.l	d0			ExamineFH() OK?
		beq	.error2

		move.l	buffer_p,a1		
		beq.s	.no_buffer	 	is a buffer still allocated?
		move.l	buffer_size,d0
		CALLSYS	FreeMem,_SysBase	free allocated buffer memory
		move.l	#NULL,buffer_p		clear buffer pointer
		
.no_buffer	move.l	d4,a0			file info block address
		move.l	fib_Size(a0),d0		size of selected file 

		move.l	d0,buffer_size		store identified size
		move.l	d0,d3			needed for Read() call
		moveq	#MEMF_ANY,d1		any memory will do
		CALLSYS	AllocMem,_SysBase
		move.l	d0,buffer_p		did we get any memory?
		beq.s	.error2

		move.l	d5,d1			file handle pointer
		move.l	d0,d2			buffer_p from AllocMem()
		CALLSYS	Read,_DOSBase 		copy file into memory
		

.normal_exit	move.l	d5,d1			file handle pointer
		CALLSYS	Close,_DOSBase		close file

		moveq	#DOS_FIB,d1		object type
		move.l	d4,d2			fib pointer
		CALLSYS	FreeDosObject,_DOSBase	free fib
	
		movem.l	(a7)+,d0-d5/a0-a1	restore registers
		rts				normal exit

.error2		move.l	d5,d1
		CALLSYS	Close,_DOSBase		close file
		
.error1		moveq	#DOS_FIB,d1		object type
		move.l	d4,d2			fib pointer
		CALLSYS	FreeDosObject,_DOSBase	free fib
		
.error0		move.w	#NULL,a0		flash screen to show error!
		CALLSYS	DisplayBeep,_IntuitionBase
		
		movem.l	(a7)+,d0-d5/a0-a1	restore registers
		rts				error exit
				
; ---------------------------------------------------------------------

* ===================================================================== * 
* Final word counting routine for counting words                        *
* defined as letters a-z or A-Z delimited by ANY other characters       *
* --------------------------------------------------------------------- *

* a0    is loaded with the address of the start of the buffer
* d0    is loaded with  the total number of characters in the file
* d1    holds the current character being examined
* d2    is used as an 'characters available' flag
* d3   is used as the word count variable

* on return register d0 is set to this count value!

* requires long word buffer_p and buffer_size variables to be available

LOWERCASE_Z   equ   $7A
LOWERCASE_A   equ   $61
UPPERCASE_Z   equ   $5A
UPPERCASE_A   equ   $41

* --------------------------------------------------------------------- *

* NOTES: The NEXTCHAR routine places the NEXT character into register d1 and then 
* increments pointer and decreases character counter. This means that 
* d2 WOULD BE CLEARED BEFORE THE LAST CHARACTER WAS EXAMINED.
* I've avoided this by setting the original d0 character count to one 
* more than it really is!

WordCount              movem.l d2-d3,-(sp)            preserve registers
                        move.l  buffer_p,a0           start of buffer
                        moveq  #0,d3                  no words yet
                        move.l  buffer_size,d0        characters in file
                        sne     d2                    set if NOT zero size  
                        addq.l  #1,d0                 now file size + 1

FINDSTART:              tst.b   d2                    zero if no characters
                        beq.s   EXIT_FINDSTART

NEXTCHAR:               move.b  (a0)+,d1              new character
                        subq.l  #1,d0                 decrease characters left count
                        sne     d2                    made zero if no chars

                        cmpi.b  #LOWERCASE_Z,d1       is char a-z ?
                        bhi.s   NOTLOWERCASE
                        cmpi.b  #LOWERCASE_A,d1
                        bcs.s   NOTLOWERCASE

                        jsr     FINDEND
                        bra.s   FINDSTART

NOTLOWERCASE:           cmpi.b  #UPPERCASE_Z,d1       is char A-Z ?
                        bhi.s   FINDSTART
                        cmpi.b  #UPPERCASE_A,d1
                        bcs.s   FINDSTART

                        jsr     FINDEND
                        bra.s   FINDSTART

EXIT_FINDSTART:         move.l  d3,d0                 set up returned count  value
                        movem.l   (sp)+,d2-d3         re-instate registers
                        rts                           
* --------------------------------------------------------------------- * 

FINDEND:                tst.b   d2                    zero if no characters       
                        beq.s   EXIT_FINDEND          end of file found so quit

NEXTCHAR2:              move.b  (a0)+,d1              new character
                        subq.l  #1,d0                 decrease characters left count
                        sne     d2                    made zero if no chars

                        cmpi.b  #LOWERCASE_Z,d1       is char a-z ?
                        bhi.s   NOTLOWERCASE2
                        cmpi.b  #LOWERCASE_A,d1
                        bcs.s   NOTLOWERCASE2

                        bra.s   FINDEND

NOTLOWERCASE2:          cmpi.b  #UPPERCASE_Z,d1       is char A-Z ?
                        bhi.s   EXIT_FINDEND
                        cmpi.b  #UPPERCASE_A,d1
                        bcs.s   EXIT_FINDEND

                        bra.s   FINDEND

EXIT_FINDEND:           addq.l  #1,d3                 count word
                        rts
* --------------------------------------------------------------------- * 





LIBRARY_COUNT	EQU  	4

lib_base_start
_DOSBase	ds.l	1
_IntuitionBase	ds.l 	1
_GadToolsBase 	ds.l 	1
_AslBase	ds.l	1
lib_base_end					;end of library base variables

_SysBase	ds.l	1
window_p	ds.l 	1
menu_p		ds.l 	1
file_request_p	ds.l 	1
buffer_size	ds.l 	1
buffer_p	ds.l 	1
count		ds.l	1


stack_space	ds.l	8			space set as required
function_stack	dc.l	NULL			top of function stack

window_tags	dc.l	WA_PubScreen
workbench_p	ds.l	1
		dc.l	WA_Left,0
		dc.l	WA_Top,0
		dc.l	WA_Width,390
		dc.l	WA_Height,210
		dc.l	WA_DragBar,TRUE
		dc.l	WA_DepthGadget,TRUE
		dc.l	WA_CloseGadget,TRUE
		dc.l	WA_SizeGadget,TRUE
		dc.l	WA_Gadgets
gadtool_list	dc.l	NULL
		dc.l	WA_MinWidth,100
		dc.l	WA_MinHeight,50
		dc.l	WA_MaxWidth,640
		dc.l	WA_MaxHeight,256
		dc.l	WA_IDCMP,IDCMP_MENUPICK|IDCMP_CLOSEWINDOW
		dc.l	WA_Title,window_name
		dc.l	TAG_DONE,NULL




gadget1_tags	
gadget11_tags	dc.l	GTTX_Border,TRUE
		dc.l	TAG_DONE,NULL


menu		dc.b	NM_TITLE,0
		dc.l	menu_title,NULL
		dc.w	0
		dc.l	0,NULL
		
		dc.b	NM_ITEM,0
		dc.l	item0,commkey0
		dc.w	0
		dc.l	0,NULL
		
		dc.b	NM_ITEM,0
		dc.l	item1,commkey1
		dc.w	0
		dc.l	0,NULL

		dc.b	NM_END,0
		dc.l	NULL,NULL
		dc.w	0
		dc.l	0,NULL


gadget1		dc.w	30,20,300,20
		dc.l	gad1_text,NULL
		dc.w	0
		dc.l	PLACETEXT_IN
visual_info_p	ds.l	1	
		dc.l	NULL			

gadget2		dc.w	30,35,300,20
		dc.l	gad2_text,NULL
		dc.w	0
		dc.l	PLACETEXT_IN
		ds.l	1			for visual info pointer	
		dc.l	NULL			


		
gadget11	dc.w	30,170,300,20
		dc.l	gad11_text,NULL
		dc.w	0
		dc.l	PLACETEXT_IN
		ds.l	1			for visual info pointer	
		dc.l	NULL			

gadtext_list 	dc.l gad2_text,gad3_text,gad4_text,gad5_text,gad6_text
		dc.l gad7_text,gad8_text,gad9_text,gad10_text   

intuitext1	dc.b	2,0,RP_JAM2,0
		dc.w	60,150
		dc.l	NULL
		dc.l	clear_string
		dc.l	intuitext2

intuitext2	dc.b	2,0,RP_JAM1,0
		dc.w	60,150
		dc.l	NULL
		dc.l	count_string
		dc.l	NULL
		

lib_names	dc.l lib1,lib2,lib3,lib4

lib1		dc.b 'dos.library',NULL
lib2		dc.b 'intuition.library',NULL
lib3		dc.b 'gadtools.library',NULL
lib4		dc.b 'asl.library',NULL

		
workbench_name	dc.b 'Workbench',NULL

window_name	dc.b 'Example CH18-1',NULL

gad1_text	dc.b '******** Word Count Utility ********',NULL

gad2_text	dc.b 'This utility will count the number of',NULL

gad3_text	dc.b 'words present in a selected text file',NULL

gad4_text	dc.b NULL

gad5_text	dc.b 'It is very easy to use -  just choose',NULL

gad6_text	dc.b 'Select File from the program menu and',NULL

gad7_text	dc.b 'and use the requester to identify the',NULL

gad8_text	dc.b 'the text file.  Chosen file will then',NULL

gad9_text	dc.b 'be analysed and a word count given!  ',NULL

gad10_text	dc.b NULL

gad11_text	dc.b 'PLEASE USE THE MENU TO SELECT A FILE',NULL


menu_title	dc.b 'PROJECT',NULL

item0		dc.b 'Select File...',NULL

commkey0	dc.b 'S',NULL

item1		dc.b 'Quit to Workbench!',NULL

commkey1	dc.b 'Q',NULL

filename	ds.b 256

filename_SIZEOF EQU *-filename

count_string	ds.b 20

count_string_SIZEOF EQU *-count_string

format_string	dc.b 'WORD COUNT = %ld',NULL

clear_string	dc.b '                  ',NULL
 	
		END

; ---------------------------------------------------------------------


		