
; An Intuition front end for A68k.

; This was a joint project programmed by ( in alphabetical order ):

; Add your name to list and also brief discription of what you worked on.

;		S.Marshall
;		M.Meany 

		opt 		o+,ow-

;		incdir		"devmaster:include/"
		incdir		"vd0:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
;		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"
		
ciaapra		equ		$bfe001
NULL		equ		0

*****************************************************************************

; The main routine that opens and closes things

start		move.l		a7,stack	save stack pointer
		
		bsr		Initialise	clear some variables
		
		bsr		OpenLibs	open libraries
		beq.s		no_libs		quit if error
		
		bsr		MakeScript	creates ram: script file
		beq.s		no_libs		quit if error
		
		bsr		OpenMainWindow	open window+attatch menu
		beq.s		no_libs		quit if error
		
		bsr		WaitForMsg	IDCMP check loop (main body)
		
		bsr		CloseMainWin	release menu + close window

no_libs		bsr		CloseLibs	close libraries

		move.l		stack,a7	restore stack (just in case)

		rts

*****************************************************************************

; At present this routine clears the library base pointers. The CloseLibs
;routine checks if each pointer is zero, if not it closes the library !

Initialise	moveq.l		#0,d0
		move.l		d0,_GfxBase
		move.l		d0,_DOSBase
		move.l		d0,_IntuitionBase
		move.l		d0,_ArpBase
		move.w		d0,quit_flag
		move.l		#10,linenum		used for debug
		rts

*****************************************************************************

; This routine opens the intuition, graphics and dos libraries. Base pointers
;are saved for each. If a library refuses to be opened the Z flag is set. 
;This is checked on return and the program aborts if any of the libs failed.

OpenLibs	lea		intname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_IntuitionBase
		beq		error
	
		lea		grafname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_GfxBase
		beq		error
	
		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase

		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt stack
		move.l		a6,_ArpBase	;store arpbase

		
error		rts

*****************************************************************************
; This routine creates the script file in ram: that is used later to invoke
;A68K and Blink.

MakeScript	move.l		#script_name,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,script_handle
		beq		no_script
		move.l		d0,d1
		move.l		#script,d2
		move.l		#script_SIZEOF,d3
		CALLDOS		Write
		move.l		script_handle,d1
		CALLDOS		Close
		moveq.l		#1,d0
no_script	rts

*****************************************************************************

; Opens the main window and attatches the main menu to it ( Ahh PowerWindows)
;Again the Z flag is set if the window cannot be opened, the program aborts
;if this is the case.
		
OpenMainWindow	lea		a68k_window,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr
		beq		no_window
		
		move.l		d0,a0
		lea		main_menu,a1
		CALLINT		SetMenuStrip
		
		moveq.l		#1,d0		make sure Z flag clear
		
no_window	rts

*****************************************************************************

; The main routine. This is where we wait for intuition to report all user
;inputs. When a message is received, it is tested and the appropriate server
;routine is called ( none written at this point ).

WaitForMsg	move.l		window.ptr,a0	
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.ptr,a0	a0-->window pointer
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3	d3=key code or menu details
		move.l		im_IAddress(a1),d7
		CALLEXEC	ReplyMsg	answer os or it get angry
		cmp.l		#CLOSEWINDOW,d2	window closed ?
		bne.s		check_menu	if not check for menu selection
		bsr		QuitReq		otherwise verify QUIT
check_menu	cmp.l		#MENUPICK,d2	menu selection made ?
		bne.s		check_key	if not check for keyboard input
		bsr		find_menu	otherwise jump to menu handler
check_key	cmp.l		#RAWKEY,d2	keyboard input ?
		bne.s		check_quit	if not then check for quit
		bsr		find_key	otherwise jump to key handler
check_quit	tst.w		quit_flag	was QUIT selected and verified?
		beq		WaitForMsg	if not wait for next message
		rts				otherwise return

; The find menu routine first checks if a menu item was selected, if not
;msg.ptr is loaded with the address of appropriate message. Next a check
;is made to see if QUIT was selected, if so control branches to a routine
;that displays a requester to verify this choice. If neither of the 2 
;above happen then the menu number and item number are calculated,
;converted to ASCII and embeded into the default message, which is then
;displayed.

find_menu	lea		main_menu,a0
		move.l		d3,d0
		CALLINT		ItemAddress
		tst.l		d0
		beq		no_selection
		move.l		d0,a0
		move.l		mi_SIZEOF(a0),a0
		jsr		(a0)
no_selection	moveq.l		#0,d2		makes other tests fail	
		rts		

*****************************************************************************		
; Here are all the routines that service menu selections	
	
		
QuitReq		move.l		window.ptr,a0	a0-->window
		lea		body,a1		a1-->requester text
		lea		left,a2		a2-->requester button text
		lea		right,a3	a3-->requester button text
		moveq.l		#0,d0		left activated by click
		move.l		d0,d1		right activated by click
		move.l		#250,d2		requester width
		move.l		#70,d3		requester height
		CALLINT		AutoRequest	turn it on !
		tst.l		d0		CONT selected ?
		bne		dont_quit	if so continue
		move.w		#1,quit_flag	otherwise set flag
dont_quit	rts				else quit

Clear		move.l		#msg1,msg.ptr
		bsr		printmsg
		rts

SaveAs		move.l		#msg4,msg.ptr
		bsr		printmsg
		rts

InsertFile	move.l		#msg5,msg.ptr
		bsr		printmsg
		rts

PrintFile	move.l		#msg6,msg.ptr
		bsr		printmsg
		rts

About		move.l		#msg7,msg.ptr
		bsr		printmsg
		rts
		
*****************************************************************************
; Uses ARP filerequester to get source filename. This file is then copied to
;ram: and renamed source.s.
	
Load:
	
	lea		LoadFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester
	tst.l		d0			;did the user cancel ?
	beq		NoPath			;yes then quit
	lea		LoadFileStruct,a0	;get file struct
	bsr		CreatePath		;make full pathname
	tst.b		LoadPathName		;is there a pathname ?
	beq.s		NoPath			;no - then quit
	move.l		#Load_CON,d1
	move.l		#MODE_NEWFILE,d2
	CALLDOS		Open
	move.l		d0,load_handle
	beq		NoPath
	move.l		#Load_comm,d1
	moveq.l		#0,d2
	move.l		d2,d3
	CALLDOS		Execute
	move.l		load_handle,d1
	CALLDOS		Close

NoPath
	rts					;and return to calling routine
	
; Uses ARP filerequester to get destination file name and copies ram:source.s
;to this.

Save:
	lea		SaveFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester 
	tst.l		d0			;did the user cancel ?
	beq		NoPath2			;yes then quit
	lea		SaveFileStruct,a0	;get file struct
	bsr		CreatePath		;make full pathname
	tst.b		SavePathName		;is there a pathname ?
	beq.s		NoPath2			;no - then quit
	move.l		#Save_CON,d1
	move.l		#MODE_NEWFILE,d2
	CALLDOS		Open
	move.l		d0,Save_handle
	beq		NoPath2
	move.l		#Save_comm,d1
	moveq.l		#0,d2
	move.l		d2,d3
	CALLDOS		Execute
	move.l		Save_handle,d1
	CALLDOS		Close
	
NoPath2
	rts					;and return to calling routine

;***********************************************************
;	General subroutines called by anybody
;***********************************************************

;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.Called by

;CreatePath(FileRequest)
;		a0

;This routine assumes that a pointer to the pathname buffer
;is placed directly after the FileRequest structure.(My extension)
		

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

; This routine executes the script file written to ram: earlier. The script
;file invokes A68K and then Blink, producing the executable file source in
;ram.

Assemble	move.l		#asm_CON,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,asm_handle
		beq		cant_assemble
		move.l		#Assemble_comm,d1
		moveq.l		#0,d2
		move.l		d0,d3
		CALLDOS		Execute
		move.l		asm_handle,d1
		move.l		#mb_msg,d2
		move.l		#mb_len,d3
		CALLDOS		Write
debug		btst		#6,ciaapra
		bne.s		debug		
		move.l		asm_handle,d1
		CALLDOS		Close
		moveq.l		#1,d0
cant_assemble	rts

; This routine executes the file ram:source, produced by assembling
;the file ram:source.s

Run		move.l		#default_CON,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,default_handle
		beq		cant_run
		move.l		#Run_comm,d1
		moveq.l		#0,d2
		move.l		d0,d3
		CALLDOS		Execute
		move.l		default_handle,d1
		move.l		#mb_msg,d2
		move.l		#mb_len,d3
		CALLDOS		Write
debug1		btst		#6,ciaapra
		bne.s		debug1		
		move.l		default_handle,d1
		CALLDOS		Close
		moveq.l		#1,d0
cant_run	rts


Find
FindN
FindP
Replace
DoNothing
ReplaceAll
GoLine
GoTop
GoBot
Prefs
Help		rts

printmsg	lea		msg_text,a1	a1-->text structure
		move.l		window.ptr,a0	a0-->window
		move.l		50(a0),a0	
		moveq.l		#5,d0		x position of text
		move.l		linenum,d1	y position of text
		CALLINT		PrintIText	print the help message
		addi.l		#8,linenum
		rts

*****************************************************************************
; Keyboard service routine

find_key	rts

*****************************************************************************

; Releases the main menu and then shuts down the main window.

CloseMainWin	move.l		window.ptr,a0
		CALLINT		ClearMenuStrip

		move.l		window.ptr,a0
		CALLINT		CloseWindow
		
		rts
		
*****************************************************************************

; This routine checks each of the libraries base pointers and closes all 
;those that are set.

CloseLibs	move.l		_IntuitionBase,a1
		beq.s		closeGFX
		CALLEXEC	CloseLibrary
		
closeGFX	move.l		_GfxBase,a1
		beq.s		closeDOS
		CALLEXEC	CloseLibrary
		
closeDOS	move.l		_DOSBase,a1
		beq.s		allclosed
		CALLEXEC	CloseLibrary

allclosed	rts

*****************************************************************************
*******************************  VARIABLES  *********************************
*****************************************************************************

; Variables and data defenition area

intname		dc.b		'intuition.library',0
		even
_IntuitionBase	dc.l		0

grafname	dc.b		'graphics.library',0
		even
_GfxBase	dc.l		0

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

_ArpBase	 dc.l		0

script_name	dc.b		'ram:asm.exe',0
		even
script_handle	dc.l		0

script		dc.b		'c:A68K ram:source.s -iworkdisc:include -d',$0a
		dc.b		'c:Blink ram:source.o',$0a
script_SIZEOF	equ		*-script

stack		dc.l		0
window.ptr	dc.l		0
linenum		dc.l		10
itn		dc.w		0
quit_flag	dc.w		0

; Console windows used by this program.

asm_CON		dc.b		'con:0/11/640/200/Assembling',0
		even
asm_handle	dc.l		0

default_CON	dc.b		'con:0/11/640/200/Default_Window',0
		even
default_handle	dc.l		0

Load_CON	dc.b		'con:0/50/640/150/Loading_File',0
		even
load_handle	dc.l		0

Save_CON	dc.b		'con:0/50/640/150/Saving_File',0
		even
Save_handle	dc.l		0

; Messages displayed in the above console windows

mb_msg		dc.b		$0a,' ACC Message: PRESS LEFT MOUSE BUTTON TO CONTINUE.'
mb_len		equ		*-mb_msg
		even

; Command sequences this program executes

Run_comm	dc.b		'ram:source',0
		even

Assemble_comm	dc.b		'execute ram:asm.exe',0
		even

Load_comm	dc.b		'copy to ram:source.s from '
	
LoadPathName	ds.b	DSIZE+FCHARS+2	;reserve space for full pathname name buffer
		EVEN

Save_comm	dc.b		'copy from ram:source.s to '
	
SavePathName	ds.b	DSIZE+FCHARS+2	;reserve space for full pathname name buffer
		even
		
*****************************************************************************
; The following Intuition text structure and messages are here for debug
;purposes only. They will be removed from the final version. Add any extra
;that you require.

msg_text	dc.b	2,2	colours to use
		dc.b	0	mode to use (normal)
		even
		dc.w	0,8	text position in window
		dc.l	0	font to use (standard)
msg.ptr		dc.l	msg1	pointer to text
		dc.l	0	end of text list
		
msg1		dc.b	'Clear selected from the Project menu ',0
		even
msg2		dc.b	'Load selected from the Project menu ',0
		even
msg3		dc.b	'Save selected from the Project menu ',0
		even
msg4		dc.b	'Save As selected from the Project menu ',0
		even
msg5		dc.b	'Insert File selected from the Project menu ',0
		even
msg6		dc.b	'Print File selected from the Project menu ',0
		even
msg7		dc.b	'About selected from the Project menu ',0
		even


*****************************************************************************
; Data for QUIT requester

body	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	50,10	text position in window
	dc.l	0	font to use (standard)
	dc.l	b_text	pointer to text
	dc.l	body1	end of text list
	
b_text	dc.b	'QUIT, are you sure ?',0  message
	even
body1	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	57,20	text position in window
	dc.l	0	font to use (standard)
	dc.l	b_text1	pointer to text
	dc.l	0	end of text list
	
b_text1	dc.b	'M.Meany  1990 ',0  message
	even


left	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	5,3	text position in window
	dc.l	0	font to use (standard)
	dc.l	l_text	pointer to text
	dc.l	0	end of text list
	
l_text	dc.b	'CONT',0  message
	even


right	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	5,3	text position in window
	dc.l	0	font to use (standard)
	dc.l	r_text	pointer to text
	dc.l	0	end of text list
	
r_text	dc.b	'QUIT',0  message
	even


*****************************************************************************

a68k_window	dc.w	0,11		window XY origin relative to TopLeft of screen
		dc.w		640,188		window width and height
		dc.b		0,1		detail and block pens
		dc.l		NEWSIZE+MOUSEBUTTONS+GADGETDOWN+GADGETUP+MENUPICK+CLOSEWINDOW+RAWKEY		IDCMP flags
		dc.l		WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+SIZEBRIGHT+ACTIVATE+NOCAREREFRESH		other window flags
		dc.l		0		first gadget in gadget list
		dc.l		0		custom CHECKMARK imagery
		dc.l		WindowName		window title
		dc.l		0		custom screen pointer
		dc.l		0		custom bitmap
		dc.w		250,55		minimum width and height
		dc.w		640,256		maximum width and height
		dc.w		WBENCHSCREEN		destination screen type

WindowName	dc.b		'A68K Front End  © ACC 1990',0
		cnop 0,2


main_menu	dc.l		Menu2		next Menu structure
		dc.w		10,0		XY origin of Menu hit box relative to screen TopLeft
		dc.w		80,10		Menu hit box width and height
		dc.w		MENUENABLED		Menu flags
		dc.l		Menu1Name		text of Menu name
		dc.l		MenuItem1		MenuItem linked list pointer
		dc.w		0,0,0,0		Intuition mystery variables
Menu1Name:
		dc.b		'Project',0
		cnop 0,2
MenuItem1:
		dc.l		MenuItem2		next MenuItem structure
		dc.w		0,0		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText1		Item render  (IntuiText or Image or 0)
		dc.l		0		Select render
		dc.b		'C'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Clear
IText1:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText1		pointer to text
		dc.l		0		next IntuiText structure
ITextText1:
		dc.b		'Clear',0
		cnop 0,2
MenuItem2:
		dc.l		MenuItem3		next MenuItem structure
		dc.w		0,10		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText2		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'L'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Load
IText2:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText2		pointer to text
		dc.l		0		next IntuiText structure
ITextText2:
		dc.b		'Load',0
		cnop 0,2
MenuItem3:
		dc.l		MenuItem4		next MenuItem structure
		dc.w		0,22		XY of Item hitbox zelative to TopLeft of parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText3		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		0		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		fillmd in by Intuition for drag selections
		dc.l		Save
IText3:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL nor default
		dc.l		ITextText3		pointer to text
		dc.l		0		next IntuiText structure
ITextText3:
		dc.b		'Save',0
		cnop 0,2
MenuItem4:
		dc.l		MenuItem5		next MenuItem structure
		dc.w		0,32		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText4		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'S'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		SaveAs
IText4:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText4		pointer to text
		dc.l		0		next IntuiText structure
ITextText4:
		dc.b		'Save As',0
		cnop 0,2
MenuItem5:
		dc.l		MenuItem6		next MenuItem structure
		dc.w		0,44		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText5		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'I'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		fillmd in by Intuition for drag selections
		dc.l		InsertFile
IText5:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText5		pointer to text
		dc.l		0		next IntuiText structure
ITextText5:
		dc.b		'Insert file',0
		cnop 0,2
MenuItem6:
		dc.l		MenuItem7		next MenuItem structure
		dc.w		0,54		XY of Item hitbox relative to TopLeft of(parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText6		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'W'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		PrintFile
IText6:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText6		pointer to text
		dc.l		0		next IntuiText structure
ITextText6:
		dc.b		'Print File',0
		cnop 0,2
MenuItem7:
		dc.l		MenuItem8		next MenuItem structure
		dc.w		0,64		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText7		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'O'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		About
IText7:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText7		pointer to text
		dc.l		0		next IntuiText structure
ITextText7:
		dc.b		'About',0
		cnop 0,2
MenuItem8:
		dc.l		0		next MenuItem structure
		dc.w		0,76		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		160,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText8		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select rendez
		dc.b		'Q'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		QuitReq
IText8:
		dc.b		0,0,RP_JAM1,0		front and jakk text pens, drawmodm and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText8
		dc.l		0		next IntuiText structure
ITextText8:
		dc.b		'Quit',0
		cnop 0,2
Menu2:
		dc.l		Menu3		next Menu structure
		dc.w		100,0		XY origin of Menu hit box relative to screen TopLeft
		dc.w		72,10		Menu hit box width and height
		dc.w		MENUENABLED		Menu flags
		dc.l		Menu2Name		text of Menu name
		dc.l		MenuItem9		MenuItem linked list pointer
		dc.w		0,0,0,0		Intuition mystery variables
Menu2Name:
		dc.b		'Search',0
		cnop 0,2
MenuItem9:
		dc.l		MenuItem10		next MenuItem structure
		dc.w		0,0		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText9		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'F'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Find
IText9:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText9		pointer to text
		dc.l		0		next IntuiText structure
ITextText9:
		dc.b		'Find',0
		cnop 0,2
MenuItem10:
		dc.l		MenuItem11		next MenuItem structure
		dc.w		0,10		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText10		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'N'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		FindN
IText10:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText10		poin|er to text
		dc.l		0		next IntuiText structure
ITextText10:
		dc.b		'Find Next',0
		cnop 0,2
MenuItem11:
		dc.l		MenuItem12		next MenuItem structure
		dc.w		0,20		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText11		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'P'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		FindP
IText11:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText11		pointer to text
		dc.l		0		next IntuiText structure
ITextText11:
		dc.b		'Find Previous',0
		cnop 0,2
MenuItem12:
		dc.l		MenuItem13		next MenuItem structure
		dc.w		0,30		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP		Item flaos
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText12		Item render  (In|uiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'R'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Replace
IText12:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText12		pointer to text
		dc.l		0		next IntuiText structure
ITextText12:
		dc.b		'Replace',0
		cnop 0,2
MenuItem13:
		dc.l		0		next MenuItem structure
		dc.w		0,40		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText13		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		0		alternate command-key
		dc.b		0		fill byte
		dc.l		SubItem1		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		DoNothing
IText13:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText13		pointer to text
		dc.l		0		next IntuiText structure
ITextText13:
		dc.b		'Replace All',0
		cnop 0,2
SubItem1:
		dc.l		0		next SubItem structure
		dc.w		132,6		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		128,8		hit box width and height
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText14		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		0		alternate command-key
		dc.b		0		fill byte
		dc.l		0		no SubItem list for SubItems
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		ReplaceAll
IText14:
		dc.b		2,2,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		0,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText14		pointer to text
		dc.l		0		next IntuiText structure
ITextText14:
		dc.b		'Are you sure?',0
		cnop 0,2
Menu3:
		dc.l		Menu4		next Menu structure
		dc.w		182,0		XY origin of Menu hit box relative to screen TopLeft
		dc.w		80,10		Menu hit box width and height
		dc.w		MENUENABLED		Menu flags
		dc.l		Menu3Name		text of Menu name
		dc.l		MenuItem14		MenuItem linked list pointer
		dc.w		0,0,0,0		Intuition mystery variables
Menu3Name:
		dc.b		'Options',0
		cnop 0,2
MenuItem14:
		dc.l		MenuItem15		next MenuItem structure
		dc.w		0,0		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText15		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'G'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		GoLine
IText15:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText15		pointer to text
		dc.l		0		next IntuiText structure
ITextText15:
		dc.b		'Goto line',0
		cnop 0,2
MenuItem15:
		dc.l		MenuItem16		next MenuItem structure
		dc.w		0,10		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText16		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'T'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		GoTop
IText16:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText16		pointer to text
		dc.l		0		next IntuiText structure
ITextText16:
		dc.b		'Goto Top',0
		cnop 0,2
MenuItem16:
		dc.l		MenuItem17		next MenuItem structure
		dc.w		0,20		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText17		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'B'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		GoBot
IText17:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText17		pointer to text
		dc.l		0		next IntuiText structure
ITextText17:
		dc.b		'Goto Bottom',0
		cnop 0,2
MenuItem17:
		dc.l		0		next MenuItem structure
		dc.w		0,35		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		176,8		hit box width and height
		dc.w		ITEMTEXT+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText18		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		0		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Prefs
IText18:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText18		pointer to text
		dc.l		0		next IntuiText structure
ITextText18:
		dc.b		'Preferences',0
		cnop 0,2
Menu4:
		dc.l		0		next Menu structure
		dc.w		272,0		XY origin of Menu hit box relative to screen TopLeft
		dc.w		80,10		Menu hit box width and height
		dc.w		MENUENABLED		Menu flags
		dc.l		Menu4Name		text of Menu name
		dc.l		MenuItem18		MenuItem linked list pointer
		dc.w		0,0,0,0		Intuition mystery variables
Menu4Name:
		dc.b		'Program',0
		cnop 0,2
MenuItem18:
		dc.l		MenuItem19		next MenuItem structure
		dc.w		0,0		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		194,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText19		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'A'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Assemble
IText19:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText19		pointer to text
		dc.l		0		next IntuiText structure
ITextText19
		dc.b		'Assemble',0
		cnop 0,2
MenuItem19:
		dc.l		MenuItem20		next MenuItem structure
		dc.w		0,10		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		194,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText20		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'X'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Run
IText20:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText20		pointer to text
		dc.l		0		next IntuiText structure
ITextText20:
		dc.b		'Run',0
		cnop 0,2
MenuItem20:
		dc.l		0		next MenuItem structure
		dc.w		0,60		XY of Item hitbox relative to TopLeft of parent hitbox
		dc.w		194,8		hit box width and height
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		each bit mutually-excludes a same-level Item
		dc.l		IText21		Item render  (IntuiText or Image or NULL)
		dc.l		0		Select render
		dc.b		'H'		alternate command-key
		dc.b		0		fill byte
		dc.l		0		SubItem list
		dc.w		MENUNULL		filled in by Intuition for drag selections
		dc.l		Help
IText21:
		dc.b		0,0,RP_JAM1,0		front and back text pens, drawmode and fill byte
		dc.w		8,0		XY origin relative to container TopLeft
		dc.l		0		font pointer or NULL for default
		dc.l		ITextText21		pointer to text
		dc.l		0		next IntuiText structure
ITextText21:
		dc.b		'Help',0
		even
	
;***********************************************************
;	FileRequester Structures
;***********************************************************


;------	hail text is what will appear in requesters window title	

Requesterflags	EQU	NULL

LoadFileStruct:
	dc.l		LoadText	;pointer to hail text
	dc.l		LoadFileData	;pointer to filename buffer
	dc.l		LoadDirData	;pointer to path buffer
	dc.l		NULL		;window to attach to - none if on WB
	dc.b		Requesterflags	;flags - none
	dc.b		0		;reserved
	dc.l		0		;fr_Function
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
	dc.l		0		;fr_Function
	dc.l		0		;reserved2
	
;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset
	dc.l		SavePathName

;------	This is the text for requesters title
LoadText:
	dc.b	'Load File ',0
SaveText:
	dc.b	'Save File ',0

;***********************************************************
	SECTION	FileRequest,BSS
;***********************************************************

LoadFileData:
	ds.b	FCHARS+1	;reserve space for filename buffer
	EVEN
	
LoadDirData:
	ds.b	DSIZE+1		;reserve space for path buffer
	EVEN

SaveFileData:
	ds.b	FCHARS+1	;reserve space for filename buffer
	EVEN
	
SaveDirData:
	ds.b	DSIZE+1		;reserve space for path buffer
	EVEN

