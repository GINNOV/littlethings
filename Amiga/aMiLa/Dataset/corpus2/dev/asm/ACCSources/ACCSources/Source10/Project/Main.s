; An Intuition front end for A68k.

; This was a joint project programmed by ( in alphabetical order ):

; Add your name to list and also brief discription of what you worked on.

;		S.Marshall
;		M.Meany 	

; Fixed ARP Load/Save bug 1-2-91 MM
; Fixed end of file bug, cursor no longer returns to start of file.
; Fixed bug causing the last line to be missed on Saves and Assemblies 26/2/91 MM
; Added requester so unsaved changes are not accidentally lost 26/2/91 MM
; Added routines so line being edited is scrolled 2/3/91 MM
; Deleted routines no longer in use 2/3/91 MM
; Border of window is no longer corrupted 3/3/91 MM

		opt 		o+,ow-

		incdir		"df0:include/"
;		incdir		rrd:
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"exec/ports.i"
		include		"devices/console_lib.i"
		include		"devices/inputevent.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"source10:include/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"sys:include/misc/easystart.i"
		
ciaapra		equ		$bfe001
NULL		equ		0

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things
;** OPENARP moved to front as it will print a message on the CLI then **
;**   return to easystart if it can't find the ARP library ,we don't  **
;**                need to do any error checking of our own           **

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt stack
		move.l		a6,_ArpBase	;store arpbase
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use - neat eh!

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GfxBase(a6),_GfxBase
		
		move.l		a7,stack	save stack pointer
		
		bsr.s		Initialise	clear some variables
		beq.s		no_libs		quit if error
		
		bsr		OpenMainWindow	open window+attatch menu
		beq.s		no_libs		quit if error
		
		bsr		WaitForMsg	IDCMP check loop (main body)
		
		bsr		CloseMainWin	release menu + close window

		bsr		clear_list

no_libs		bsr		CloseLibs	close libraries

		move.l		stack,a7	restore stack (just in case)

		rts

*****************************************************************************

; At present this routine clears the library base pointers. The CloseLibs
;routine checks if each pointer is zero, if not it closes the library !
; Now clears all uninitialized data except _IntuitionBase,_GfxBase,_ArpBase
;and stack which have already been initialized ,this may allow Acc
;to be made resident - anyway it helps with debugging  (S.M)

Initialise	move.l		#BSS_Size,d0
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLARP		ArpAllocMem
		tst.l		d0
		beq		error
		move.l		d0,a4
		
		lea		msg1(a4),a0
		move.l		a0,msg.ptr
		move.l		a0,curline.ptr
		
		lea		status_text(a4),a0
		move.l		a0,status.ptr
		
; Initialise file requeser structures

		move.l		#Requesterflags,d0
		
		lea		LoadFileStruct(a4),a0
		move.l		#LoadText,(a0)+
		lea		LoadFileData(a4),a1
		move.l		a1,(a0)+
		lea		LoadDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		LoadFileStruct(a4),a0
		lea		LoadPathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)
		
		lea		InsertFileStruct(a4),a0
		move.l		#InsertTitle,(a0)+
		lea		InsertFileData(a4),a1
		move.l		a1,(a0)+
		lea		InsertDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		InsertFileStruct(a4),a0
		lea		InsertPathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)
		
		or.b		#FRF_DoColor,d0
		
		lea		SaveFileStruct(a4),a0
		move.l		#SaveText,(a0)+
		lea		SaveFileData(a4),a1
		move.l		a1,(a0)+
		lea		SaveDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		SaveFileStruct(a4),a0
		lea		SavePathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)
		
		move.l		#10,linenum(a4)	
		move.l		#10,cur_y(a4)
		move.l		#5,cur_x(a4)
		move.l		#status_msg1,status_msg.ptr(a4)
		
		move.l		#A68k_name,d1
		CALLARP		LoadPrg
		move.l		d0,A68k_Seg(a4)
		beq.s		error
		
		move.l		d0,d1
		lea		A68k_name,a0
		CALLSYS		AddResidentPrg
		
		move.l		#Blink_name,d1
		CALLSYS		LoadPrg
		move.l		d0,Blink_Seg(a4)
		beq.s		error
		
		sub.l		a0,a0			;no name
		moveq		#0,d0			;pri = 0
		CALLSYS		CreatePort
		lea		Console_StdIO(a4),a0
		move.l		d0,MN_REPLYPORT(a0)
		beq.s		error
		
		move.l		a0,a1			;StdIO to a1
		lea		Console_name(pc),a0	;console dev name
		moveq		#-1,d0			;do not attach window
		moveq		#0,d1
		CALLEXEC	OpenDevice		;open console device
		tst.l		d0
		bne.s		error2
		
		sub.l		a0,a0			;no name
		moveq		#0,d0			;pri = 0
		CALLARP		CreatePort
		lea		Zombie_Message(a4),a0
		move.l		d0,MN_REPLYPORT(a0)
		
; ** Removed DOS lib as we don't need it - ARP has all DOS routines S.M. **

		bsr		init_list
		
		bsr		empty_line
	
		bsr		cursor_home
	
error		rts

error2
		moveq		#0,d0
		rts

*****************************************************************************

; Opens the main window and attatches the main menu to it ( Ahh PowerWindows)
;Again the Z flag is set if the window cannot be opened, the program aborts
;if this is the case.Added bit for ASyncRun and tidied up first part.(S.M)
		
OpenMainWindow	lea		a68k_window,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr(a4)	store window pointer
		beq.s		no_window
		
		move.l		d0,a0
		move.l		wd_RPort(a0),window.rp(a4) store rastport pointer
		move.l		wd_UserPort(a0),window.up(a4) store userport pointer

;--------------	a0 still contains window.ptr		
		lea		main_menu,a1
		CALLSYS		SetMenuStrip

; change this to alter the line spacing default = 0 		

		move.w		#0,linespace(a4)

; Set screen title bar

		move.l		window.ptr(a4),a0
		lea		WindowName,a1
		lea		ScreenName,a2
		CALLINT		SetWindowTitles
		
; Print initial status line

		bsr		ReSize
		
		moveq.l		#1,d0		make sure Z flag clear
		
no_window	rts
		
*****************************************************************************

; The main routine. This is where we wait for intuition to report all user
;inputs. When a message is received, it is tested and the appropriate server
;routine is called .

; Execution will stay in this loop until the value in quit_flag becomes non-
;zero. Any routine that gives the user the oportunity to quit the program
;should call the subroutine QuitReq. This gives the user the chance to 
;change his ( her ? ) mind. QuitReq is the only routine at present that 
;alters the value of quit_flag.

WaitForMsg	bsr		printcurline
		bsr		cursor_on
		move.l		window.up(a4),a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up(a4),a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3	d3=key code or menu details
		move.w		im_Qualifier(a1),d4 d4=special key details
		move.l		im_IAddress(a1),d7
		cmp.l		#RAWKEY,d2	keyboard input ?
		bne.s		Do_Reply	if not then reply to message
		move.l		a1,-(sp)	save message ptr
		bsr		find_key	otherwise jump to key handler
		move.l		(sp)+,a1	restore message ptr
Do_Reply
		CALLEXEC	ReplyMsg	answer os or it get angry
		cmp.l		#CLOSEWINDOW,d2	window closed ?
		bne.s		check_resize	if not check if window resized
		bsr		QuitReq		otherwise verify QUIT
check_resize	cmp.l		#NEWSIZE,d2	window resized ?
		bne.s		check_menu	if not check menu selection
		bsr.s		ReSize		else deal with resize
check_menu	cmp.l		#MENUPICK,d2	menu selection made ?
		bne.s		check_quit	if not check for keyboard input
		bsr		find_menu	otherwise jump to menu handler
check_quit	tst.w		quit_flag(a4)	was QUIT selected and verified?
		beq.s		WaitForMsg	if not wait for next message
		rts				otherwise return

*****************************************************************************		
; converts raw key codes to ASCII - NOTE message must not be replied to
; or the data may not be valid.Change variable BuffSize to value required.
; Because keymaps allow more than one char per keypress we must allow for 
; this.SetKey allows up to 128 chars but 40 should be enough.If on return if 
; d0 = -1 then buffer overflow ocurred otherwise it contains the number of
; chars in the buffer.a0 points to buffer which will contains the string
; of chars - not null terminated.
; Actual = ConvertRAW (Message)
;   d0			a1

BuffSize	EQU	40		
ConvertRAW:
		lea		Console_IOEvent(a4),a0
		move.b		#IECLASS_RAWKEY,ie_Class(a0)
		move.w		im_Code(a1),ie_Code(a0)
		move.w		im_Qualifier(a1),ie_Qualifier(a0)
		move.l		im_IAddress(a1),ie_EventAddress(a0)
		
		move.l		a6,-(sp)
		lea		Console_StdIO(a4),a1
		move.l		IO_DEVICE(a1),a6
		lea		ConvertBuffer(a4),a1
		moveq		#BuffSize,d1
		sub.l		a2,a2			;use default keymap
		jsr		_LVORawKeyConvert(a6)
		move.l		(sp)+,a6
		lea		ConvertBuffer(a4),a0
		move.b		#0,0(a0,d0.w)		;null terminate string
		rts

*****************************************************************************		
; Refreshes display and updates scrn_size after window has been resized. The
;number of lines that can be printed on screen is calculated as follows:

; number of lines = ( window height -10 / font height ) - 1

; It would be possible to get more text in the window by dividing by 8, but I
;prefer to look at well spaced text. Other routines will need to be alterd if
;you want to change this.

ReSize		move.l		window.ptr(a4),a0
		moveq.l		#0,d0
		move.w		wd_Height(a0),d0
		move.l		window.rp(a4),a1
		moveq		#0,d1
		move.w		rp_TxWidth(a1),d1
		move.l		d1,font.width(a4)
		move.w		rp_TxHeight(a1),d1		
		add.w		linespace(a4),d1
		move.l		d1,font.height(a4)
		sub.l		#12,d0
		divu		d1,d0
		and.l		#$ffff,d0
		subq.l		#1,d0
		move.l		d0,scrn_size(a4)
		moveq		#0,d1
		move.w		wd_Width(a0),d1
		subq.w		#4,d1
		move.l		d1,scrn_width(a4)
		move.l		font.width(a4),d0
		mulu		#5,d0
		sub.l		d0,d1
		move.l		d1,max_curx(a4)
		move.l		scrn_width(a4),d0
		divu		font.width+2(a4),d0
		subq.w		#1,d0
		and.l		#$ffff,d0
		move.l		d0,max_num_chars(a4)
		bsr		cursor_top
		bsr		refresh_display
		bsr		PrintStatus
		moveq.l		#0,d2
		rts

*****************************************************************************		
; This routine deals with menu selections. The address of the subroutine that
;deals with a menu selection is stored after the menu item definition. This
;way the address is obtainable by getting the address of the menu items data
;structure ( by calling ItemAddress () ) into a0 and using mi_SIZEOF(a0)
;thanks to Steve Marshall for this tip.

; At the end of this routine the status line is re-printed so routines may
;set error messages via the status_msg.ptr, these will appear in the status
;line at the bottom of the display. Before returning to WaitForMsg, d2 is set
;to 0 so that other IDCMP tests fail.

;*** Patched find_menu code to allow extended selection of menus.(S.M)

find_menu	move.l		d3,d0

menuloop
		lea		main_menu,a0
		CALLINT		ItemAddress
		tst.l		d0
		beq.s		no_selection
		move.l		d0,a0
		move.w		mi_NextSelect(a0),LastItem(a4)
		move.l		mi_SIZEOF(a0),a0
		jsr		(a0)
		move.w		LastItem(a4),d0
		bra.s		menuloop
		
no_selection	bsr		PrintStatus
		moveq.l		#0,d2		makes other tests fail	
		rts		

*****************************************************************************		
; Here are all the routines that service menu selections	
	
; This routine pops a requester up on the screen giving the user the choice
;of QUITting or CONTinuing. If quit is selected then quit_flag is made non-
;zero and WaitForMsg will know that the user wishes to quit.
		
QuitReq		tst.l		changes(a4)
		beq.s		.ok
		bsr		Lose_Changes
		beq.s		.dont_quit
.ok		move.l		window.ptr(a4),a0	a0-->window
		lea		Qbody,a1		a1-->requester text
		lea		Qleft,a2		a2-->requester button text
		lea		Qright,a3	a3-->requester button text
		moveq.l		#0,d0		left activated by click
		move.l		d0,d1		right activated by click
		move.l		#290,d2		requester width
		moveq		#70,d3		requester height
		CALLINT		AutoRequest	turn it on !
		tst.l		d0		CONT selected ?
		bne.s		.dont_quit	if so continue
		move.w		#1,quit_flag(a4) otherwise set flag
.dont_quit	rts				else quit

*****************************************************************************
; Load in a text file. This is a biggy. The ARP file requester is used to 
;obtain the full pathname of the file to load. No pathname causes a message
;to appear in status line and the routine aborts.

; Once a filename has been specified, the size of the file is determined by
;examaning the File Info Block ( fib_ ). If the file is bigger than the text
;buffer then a message is displayed in the status line and the subroutine
;aborts.

; If the file will fit in the buffer it is opened and the text is read into
;the buffer. If the file cannot be opened, a message appears in the status 
;line and the subroutine aborts.

; Once the text has been read into memory the number of lines of text present
;is determined and the text output variables start_line_num ( number of line
;to appear in top line of window ) and start_line ( address in text buffer of
;of line to appear in top line of window ) are both initialised to the start
;of the text buffer. The first window of text is then printed and the
;subroutine finishes. Phew !

Load		tst.l		changes(a4)
		beq		.no_changes
		bsr		Lose_Changes
		beq		load_error
.no_changes	bsr.s		arpload
		bne.s		.ok
		move.l		#status_msg7,status_msg.ptr(a4)
		bra.s		load_error
.ok		lea		LoadPathName(a4),a5
		bsr		clear_list
		bsr		load_file
		bsr		cursor_home
		bsr		refresh_display
		move.l		#0,changes(a4)
load_error	rts

; Uses ARP filerequester to get source filename.
	
arpload		lea		LoadFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester
		tst.l		d0			;did the user cancel ?
		beq.s		NoPath
		lea		LoadFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		NoPath
		bsr		CreatePath		;make full pathname
		tst.b		LoadPathName(a4)	;is there a pathname ?
NoPath		rts					;and return to calling routine

	
; This routine pops a requester up on the screen giving the user the choice
;of CANCELing the Load operation if changes have been made to the text which
;have not yet been saved.
		
Lose_Changes	move.l		window.ptr(a4),a0	a0-->window
		lea		Lbody,a1		a1-->requester text
		lea		Lleft,a2		a2-->requester button text
		lea		Lright,a3	a3-->requester button text
		moveq.l		#0,d0		left activated by click
		move.l		d0,d1		right activated by click
		move.l		#290,d2		requester width
		moveq		#70,d3		requester height
		CALLINT		AutoRequest	turn it on !
		tst.l		d0		CONT selected ?
		rts				else quit

*****************************************************************************
; Save text in buffer to name specified. This subroutin has two entry points,
;entering at SaveAs causes an ARP file requester to appear so a file name can
;be specified, Entering at Save will save text to a previousley specified
;file.

; If no file name is specified a message is displayed in the status line and
;the subroutine aborts.

; Providing a file name exsists then, the subroutine opens the file. If the
;file cannot be opened a message is sent to the status line and the
;subroutine aborts.

; After the text has been saved, the file is close and the subroutine ends.

; Added a third entry point ( entry2 ??? ). The section of code following
;this is called by the assemble subroutine to write the text to ram: prior
;to invoking A68K.

; Since the addittion of list, can also use entry2 for partial saves. Set
;node=addr of line to start saving from, d1= filename.

SaveAs		bsr.s		arpsave
Save		tst.b		SavePathName(a4)
		bne.s		.ok
		move.l		#status_msg7,status_msg.ptr(a4)
		bra.s		save_error
.ok		bsr		chk_ln_changes
		move.l		#0,changes(a4)
		lea		start_list(a4),a0
		move.l		node.next(a0),a0
		move.l		a0,node(a4)		node=addr to start
		move.l		a4,d1
		add.l		#SavePathName,d1
entry2		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d7
		bne.s		.ok
		move.l		#status_msg11,status_msg.ptr(a4)
		bra.s		save_error
.ok		bsr		save_list
		move.l		d7,d1
		CALLSYS		Close
save_error	rts

; Use ARP file requester to obtain save file name.

arpsave		lea		SaveFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester 
		tst.l		d0			;did the user cancel ?
		beq.s		NoPath2			;yes then quit
		lea		SaveFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		NoPath2
		bsr.s		CreatePath		;make full pathname
NoPath2		rts					;and return to calling routine

*****************************************************************************
;	General subroutines called by anybody
*****************************************************************************

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

*****************************************************************************		
; Clears text buffer and assosiated variables.

Clear		tst.l		changes(a4)
		beq.s		.ok
		bsr		Lose_Changes
		beq.s		.dont_clear
.ok		bsr		clear_list
		bsr		empty_line
		bsr		cursor_home
		bsr		refresh_display
		move.l		#0,changes(a4)
.dont_clear	rts
		
*****************************************************************************
; This subroutine assembles and links the contents of the text buffer.

; Another biggy !

Assemble	bsr		chk_ln_changes
		bsr		GoAsmP
		move.l		#ramname,d1
		lea		start_list(a4),a0
		move.l		node.next(a0),a0
		move.l		a0,node(a4)	node=addr to start
		bsr		entry2		part of Save subroutine
		move.l		#asm_CON,d1
		move.l		#MODE_OLDFILE,d2
		CALLARP		Open
		move.l		d0,asm_handle(a4)
		bne.s		assemble_now
		move.l		#status_msg12,status_msg.ptr(a4)
		bra		cant_assemble
assemble_now	
		lea		PrCtrlBlk(a4),a2
		move.l		d0,pcb_Output(a2)
		move.l		d0,pcb_Splatfile(a2)
		move.l		#0,pcb_LoadedCode(a2)

		lea		Zombie_Message(a4),a3
		move.l		a3,pcb_LastGasp(a2)		;nice name!
		move.l		#8000,(a2)		;set stacksize
		move.b		#0,pcb_Pri(a2)		;and priority
		move.b		#PRF_SAVEIO,pcb_Control(a2)

;--------------	the argument is supplied seperatly for ASyncRun. At the
;		moment this arg is just a newline and return (for safety)
;		we can add a requester asking for arguments so we can test
;		CLI utilities etc later.

		lea		A68k_name,a0
		lea		Asm_comm(pc),a1
		CALLSYS		ASyncRun	;ASyncRun will close default_CON
		
		move.l		MN_REPLYPORT(a3),a0
		CALLEXEC	WaitPort
		move.l		MN_REPLYPORT(a3),a0
		CALLSYS		GetMsg
		
		move.l		Blink_Seg(a4),pcb_LoadedCode(a2)
		
		sub.l		a0,a0
		lea		Link_comm(pc),a1
		CALLARP		ASyncRun	;ASyncRun will close default_CON
		
		lea		Zombie_Message(a4),a3
		move.l		MN_REPLYPORT(a3),a0
		CALLEXEC	WaitPort
		move.l		MN_REPLYPORT(a3),a0
		CALLSYS		GetMsg

		move.l		asm_handle(a4),d1
		move.l		#mb_msg,d2
		move.l		#mb_len,d3
		CALLARP		Write
.loop		btst		#6,ciaapra
		bne.s		.loop		
		move.l		#ramname,d1
		CALLSYS		DeleteFile
		move.l		#objname,d1
		CALLSYS		DeleteFile
		move.l		asm_handle(a4),d1
		CALLSYS		Close
cant_assemble	rts


GoAsmP		lea		AsmP_window,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,AsmP.ptr(a4)	save its pointer
		lea		AsmPWinText,a1	a1-->text structure
		move.l		AsmP.ptr(a4),a0	a0-->window
		move.l		50(a0),a0	
		moveq.l		#0,d0		x position of text
		moveq		#0,d1		y position of text
		CALLSYS		PrintIText	print the help message
WaitForAsmP	move.l		AsmP.ptr(a4),a0	a0-->window
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		AsmP.ptr(a4),a0	a0-->window pointer
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForAsmP	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer o/s or it gets angry
		cmp.l		#GADGETUP,d2
		bne.s		WaitForAsmP
		move.l		gg_UserData(a5),a5
		jsr		(a5)
		move.l		AsmP.ptr(a4),a0	a0-->window
		CALLINT		CloseWindow	close this window
		rts
	
GotAsmPName	rts

NoAsmPName	moveq.l		#10,d0
		lea		AsmPBuffer,a0
		lea		AsmMemName,a1
.loop		move.b		(a1)+,(a0)+
		dbra		d0,.loop
		rts

; This routine executes the file ram:source, produced by assembling
;the file ram:source.s

Run		move.l		#default_CON,d1
		move.l		#MODE_OLDFILE,d2
		CALLARP		Open
		move.l		d0,default_handle(a4)
		bne.s		run_now
		move.l		#status_msg13,status_msg.ptr(a4)
		bra.s		cant_run
run_now		
		lea		PrCtrlBlk(a4),a2
		move.l		d0,pcb_Output(a2)
		move.l		d0,pcb_Splatfile(a2)
		moveq		#0,d0
		move.l		d0,pcb_LoadedCode(a2)
		move.l		d0,pcb_LastGasp(a2)	
		move.l		#8000,(a2)		;set stacksize
		move.b		d0,pcb_Pri(a2)		;and priority
		move.b		#PRF_CLOSESPLAT,pcb_Control(a2)

		lea		Run_comm(pc),a0
;--------------	the argument is supplied seperatly for ASyncRun. At the
;		moment this arg is just a newline and return (for safety)
;	we can add a requester asking for arguments so we can test
;		CLI utilities etc later.
		lea		Run_arg(pc),a1		
		CALLSYS		ASyncRun	;ASyncRun will close default_CON
		
cant_run	rts

*****************************************************************************
; Print the file

PrintFile	move.l		#printername,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d7
		bne.s		.ok
		move.l		#status_msg14,status_msg.ptr(a4)
		bra.s		.done
.ok		lea		start_list(a4),a0
		move.l		node.next(a0),a0
		move.l		a0,node(a4)
		bsr		save_list
		move.l		d7,d1
		CALLARP		Close
.done		rts
		
*****************************************************************************
; Print the current page of text

PrintPage	move.l		start_line(a4),a0
		move.l		scrn_size(a4),d0
		bsr		print_section
		rts
		
*****************************************************************************

;-------------- Print a section of the listing.

;Entry		a0->addr of first line to print
;	either	a1->addr of last line to print
;	or	d0= number of lines to print

print_section	tst.l		d0
		beq.s		.ok
		subq.l		#1,d0
		move.l		a0,a1
.loop		move.l		node.next(a1),a1
		dbra		d0,.loop
.ok		move.l		a0,node(a4)
		move.l		node.next(a1),a1
		move.l		node.next(a1),temp(a4)
		move.l		#0,node.next(a1)
		move.l		#printername,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d7
		bne.s		.ok1
		move.l		#status_msg14,status_msg.ptr(a4)
		bra.s		.done
.ok1		bsr		save_list
		move.l		d7,d1
		CALLARP		Close
		move.l		temp(a4),d0
		beq.s		.done
		move.l		d0,a0
		move.l		node.prev(a0),a1
		move.l		a0,node.next(a1)
.done		rts

*****************************************************************************

InsertFile	bsr		arpinsert
		beq.s		.done
		move.l		num_lines(a4),old_size(a4)
		move.l		start_line(a4),node(a4)
		move.l		a4,a5
		add.l		#InsertPathName,a5
		bsr		load_file
		move.l		old_size(a4),d0
		add.l		num_lines(a4),d0
		move.l		d0,num_lines(a4)
		bsr		refresh_display
.done		rts

arpinsert	lea		InsertFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester
		tst.l		d0			;did the user cancel ?
		beq.s		NoPath3			;yes then quit
		lea		InsertFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		NoPath3
		bsr		CreatePath		;make full pathname
		tst.b		InsertPathName(a4)	;is there a pathname ?
NoPath3		rts					;and return to calling routine
		
*****************************************************************************	

; Display the ABOUT window
		
About		lea		about_win,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,about.ptr(a4)	save window pointer
		beq.s		no_win
		lea		about_text,a1	a1-->text structure
		move.l		about.ptr(a4),a0	a0-->window
		move.l		50(a0),a0	
		moveq.l		#0,d0		x position of text
		moveq		#0,d1		y position of text
		CALLSYS		PrintIText	print the help message
wait_about	btst		#6,ciaapra	wait for left mouse button
		bne.s		wait_about
		move.l		about.ptr(a4),a0	a0-->window
		CALLSYS		CloseWindow	close this window
no_win		rts


*****************************************************************************	

GoLine		bsr.s		WhatLine
GoLine2		bsr		chk_ln_changes
		move.l		num_lines(a4),d1
		sub.l		scrn_size(a4),d1
		bhi.s		.ok1
		move.l		#status_msg4,status_msg.ptr(a4)
		bra.s		no_goline
.ok1		tst.l		d7
		bne.s		.ok2
		move.l		#status_msg4,status_msg.ptr(a4)
		bra.s		no_goline
.ok2		cmp.l		d1,d7
		ble.s		.ok3
		move.l		#status_msg4,status_msg.ptr(a4)
		bra.s		no_goline
.ok3		move.l		d7,start_line_num(a4)
		move.l		d7,d1
		bsr		find_ln
		move.l		a5,start_line(a4)
		bsr		cursor_top
		bsr		refresh_display
no_goline	rts


WhatLine	move.l		#0,LineBuffer
		lea		line_window,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,line.ptr(a4)	save its pointer
		lea		LineWinText,a1	a1-->text structure
		move.l		line.ptr(a4),a0	a0-->window
		move.l		50(a0),a0	
		moveq.l		#0,d0		x position of text
		moveq		#0,d1		y position of text
		CALLSYS		PrintIText	print the help message
WaitForLine	move.l		line.ptr(a4),a0	a0-->window
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		line.ptr(a4),a0	a0-->window pointer
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForLine	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer o/s or it gets angry
		cmp.l		#GADGETUP,d2
		bne.s		WaitForLine
		move.l		gg_UserData(a5),a5
		jsr		(a5)
		move.l		line.ptr(a4),a0	a0-->window
		CALLINT		CloseWindow	close this window
		rts
	
GotLineNum	lea		LineGadgInfo,a5
		move.l		si_LongInt(a5),d7
		bpl.s		ok
NoLineNum	moveq		#0,d7
ok		rts

*****************************************************************************	

GoTop		bsr		chk_ln_changes
		bsr		cursor_home
		bsr		refresh_display
		rts

*****************************************************************************	

GoBot		bsr		chk_ln_changes
		move.l		num_lines(a4),d1
		sub.l		scrn_size(a4),d1
		bls.s		no_gobot
		move.l		d1,start_line_num(a4)
		bsr		find_ln
		move.l		a5,start_line(a4)
		bsr		cursor_top
		bsr		refresh_display
no_gobot	rts
		
*****************************************************************************	

; Scroll on to next page

next_page	move.l		start_line_num(a4),d7
		move.l		scrn_size(a4),d1
		add.l		d1,d7
		move.l		num_lines(a4),d1
		cmp.l		d1,d7
		bne.s		.ok2
		move.l		#status_msg3,status_msg.ptr(a4)
		bra.s		noline
.ok2		
		subq.l		#1,d7
		sub.l		scrn_size(a4),d1
		cmp.l		d1,d7
		bhi.s		GoBot
		bra		GoLine2
noline		rts
		
*****************************************************************************

; Scroll to previous page

prev_page	cmp.l		#1,start_line_num(a4)
		bne.s		.ok2
		move.l		#status_msg2,status_msg.ptr(a4)
		bra.s		noline
.ok2		move.l		start_line_num(a4),d7	else bump top line
		move.l		scrn_size(a4),d1
		subq.l		#1,d1
		sub.l		d1,d7
		bmi		GoTop
		beq		GoTop
		bra		GoLine2

*****************************************************************************

		
Find
FindN
FindP
Replace
DoNothing
ReplaceAll
Prefs
Help		move.l		#status_msg20,status_msg.ptr(a4)
		rts

*****************************************************************************
; Keyboard service routine

;-------------	added call to ConvertRAW here for now  a1 = message still

;-------------	added test for key-up message. Ignored if received.

find_key	btst		#7,d3
		bne		ignore_keys
		
		bsr		ConvertRAW

;-------------	number of chars in d0 and address of char buffer in a0

		tst.l		d0
		beq		done_keys

		bsr		cursor_off
		
		cmpi.b		#$9b,(a0)
		bne.s		Not_UpDown
		
		cmp.w		#$9b53,(a0)
		bne.s		page_down
		bsr		next_page
		bra		done_keys
		
page_down	cmp.w		#$9b54,(a0)
		bne.s		line_up
		bsr.s		prev_page
		bra.s		done_keys
line_up
		cmp.w		#$9b42,(a0)
		bne.s		line_down
		bsr		cursor_down
		bra.s		done_keys
		
line_down	cmp.w		#$9b41,(a0)
		bne.s		chkleft
		bsr		cursor_up
		bra.s		done_keys

chkleft		cmp.w		#$9b44,(a0)
		bne.s		chkright
		bsr		cursor_left
		bra.s		done_keys
		
chkright	cmp.w		#$9b43,(a0)
		bne.s		done_keys
		bsr		cursor_right
		bra.s		done_keys

Not_UpDown	moveq.l		#0,d0
		move.b		(a0),d0
		cmp.b		#$08,d0
		bne.s		chk_del
		bsr		bckspc
		bra.s		done_keys

chk_del		cmp.b		#$7f,d0
		bne.s		chk_lf
		bsr		del
		bra.s		done_keys

chk_lf		cmp.b		#$0d,d0
		bne.s		chk_ascii
		move.l		#$0a,d2
		bsr		line_feed
		bra.s		done_keys

chk_ascii	cmp.b		#$09,d0
		beq.s		.ok
		cmp.b		#$20,d0
		blt.s		done_keys
		cmp.b		#$7e,d0
		bgt.s		done_keys
.ok		move.l		d0,d2
		bsr		insert_char
		bra.s		done_keys
		
		nop
		
done_keys	bsr		PrintStatus
ignore_keys	moveq.l		#0,d2
		rts

; Print the message defined by the Intuition text structure at msg_text

printmsg	move.l		msg.ptr,a1
		move.l		max_num_chars(a4),d0
		move.b		#0,0(a1,d0)
		lea		msg_text,a1	a1-->text structure
		move.l		window.rp(a4),a0	a0-->window rastport
		moveq.l		#5,d0		x position of text
		move.l		linenum(a4),d1	y position of text
		CALLINT		PrintIText	print the help message
		move.l		font.height(a4),d0
		add.l		d0,linenum(a4)
		rts

*****************************************************************************
HandleOtherKeys
		rts

*****************************************************************************

; This routine scrolls the display up one line and displays the next line of
;text at the bottom of the display. No scroll is done if the bottom line is
;off the display.

scroll_up	move.l		window.rp(a4),a1		: : : : : : : : : : :
		moveq.l		#0,d0			: : : : : : : : : : :
		move.l		font.height(a4),d1			: : : : : : : : : : :
		moveq.l		#4,d2			set params for 
		moveq.l		#10,d3			ScrollRaster routine
		move.l		scrn_width(a4),d4		: : : : : : : : : : :
		move.l		scrn_size(a4),d5		calculate height of 
		mulu.w		font.height+2(a4),d5	screen.
		add.w		#9,d5			: : : : : : : : : : :
		CALLGRAF	ScrollRaster		and scroll up
		rts					and return

*****************************************************************************

; This routine scrolls the display down one line and displays the next line of
;text at the top. If the top of the file is already being displayed, then no
;scroll takes place.

scroll_down	move.l		window.rp(a4),a1		: : : : : : : : : : :
		moveq.l		#0,d0			: : : : : : : : : : :
		move.l		font.height(a4),d1		: : : : : : : : : : :
		neg.l		d1
		moveq.l		#4,d2			set params for
		moveq.l		#10,d3			ScrollRaster routine
		move.l		scrn_width(a4),d4		: : : : : : : : : : :
		move.l		scrn_size(a4),d5		calculate height of 
		mulu.w		font.height+2(a4),d5	screen
		add.w		#9,d5			: : : : : : : : : : :
		CALLGRAF	ScrollRaster		and scroll down
		rts

*****************************************************************************

; Prints a new page of text. the number of lines displayed is controled by
;scrn_size.

; Set pen to background colour

refresh_display	move.l		window.rp(a4),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen

; Blit a great big rectangle over the window ( clear the screen )
		
		move.l		window.ptr(a4),a0
		move.w		wd_Width(a0),d2
		subi.w		#4,d2
		move.w		wd_Height(a0),d3
		subi.w		#11,d3
		move.w		#2,d0
		move.w		#10,d1
		move.l		window.rp(a4),a1
		CALLSYS		RectFill

; Now print the text. Checks that there is text in the buffer, if not 
;no text is printed and a status message is returned. Checks that there is
;enough text in the buffer to fill the screen, if not only text present
;is printed.

		move.l		#10,linenum(a4)
		move.l		num_lines(a4),d5
		cmp.l		scrn_size(a4),d5
		bgt.s		do_lines
		subq.l		#1,d5
		beq.s		part_refresh
		subq.l		#1,d5
		bra.s		part_refresh
do_lines	move.l		scrn_size(a4),d5	get num of lines to print
		subq.l		#1,d5		adjust for dbra
part_refresh	move.l		start_line(a4),a1	get addr of 1st text line
.loop		movea.l		a1,a5		save addr of text line
		bsr.s		print_line	print this line
		move.l		node.next(a5),a5 get addr of next line of text
		movea.l		a5,a1		put it in a1
		dbra		d5,.loop	loop until all lines printed
no_refresh	rts				return

*****************************************************************************

; Expands a line of text and prints the result on the screen. The position of
;the text must already be set ( linenum ).

; Entry		a1 must hold address of unexpanded text.

print_line	lea		msg1(a4),a0		a0-->destination buffer
		bsr.s		expand_text	process the text
		bsr		printmsg	print the message
		rts				and return
		
*****************************************************************************

; Finds the address of the start of a given line in the text.

; Entry		d1 must hold the line number required ( 0 NOT allowed )

; Exit		a5 will hold the address of the start of required line.

find_ln		cmp.l		num_lines(a4),d1	is this a valid size
		ble.s		.ok		if so don't worry
		move.l		num_lines(a4),d1	else set line = max value
.ok		subq.l		#1,d1		convert line num to offset
		lea		start_list(a4),a5
.loop		move.l		node.next(a5),a5
		dbra		d1,.loop
		rts
		

*****************************************************************************

; Given the address of a $0a terminated line of text, this(subroutine will
;produce a printable line ( TAB's expanded ) in a line buffer.

; Entry		a0 must hold address of line buffer for expanded text
;		a1 must hold address of start of text string
		
		
expand_text	movem.l		d0-d7/a0-a1,-(sp) save registers
		adda.l		#node.data,a1	point at data
		moveq.l		#0,d6		d6=line length
		moveq.l		#$09,d2		d2=TAB
		moveq.l		#$0a,d3		d3=CR
		moveq.l		#' ',d4		d4=space
next_char	move.b		(a1)+,d0	d0=next char
		cmp.b		d3,d0		new line ?
		beq.s		line_done	if so finish up
		cmp.b		d2,d0		TAB ?
		beq.s		do_tab		if so deal with it
		move.b		d0,0(a0,d6)	position character
		addq.w		#1,d6		bump counter
		bra.s		next_char	go back for next char
		
line_done	move.b		#0,0(a0,d6)	null terminate line
		movem.l		(sp)+,d0-d7/a0-a1 restore registers
		rts
		
do_tab		move.l		d6,d1		copy chars so far
		asr.w		#3,d1		calculate num of spaces
		addq.w		#1,d1
		asl.w		#3,d1
		sub.w		d6,d1
		subq.w		#1,d1		adjust for dbra
next_spc	move.b		d4,0(a0,d6)	add a space
		addq.w		#1,d6		bump line length
		dbra		d1,next_spc	until tab position reached
		bra.s		next_char

; The Intuition text structure

msg_text	dc.b	1,0	colours to use
		dc.b	RP_JAM2 mode to use (normal)
		even
		dc.w	0,0	text position in window
		dc.l	0	font to use (standard)
msg.ptr		dc.l	0	pointer to text
		dc.l	0	end of text list

*****************************************************************************
PrintStatus	movem.l		d0-d7/a0-a7,-(sp)
		move.l		status_msg.ptr(a4),-(sp)
		move.l		start_col_num(a4),-(sp)
		move.l		cur_line_num(a4),-(sp)
		lea		status_text2(pc),a0
		lea		status_text(a4),a1
		bsr		sprintf
		lea		12(sp),sp		;pull args from stack
		
		move.l		#status_msg0,status_msg.ptr(a4)
		
; added this next bit to clip status text to stop trashing of the size gadget
		move.l		window.ptr(a4),a0
		moveq		#0,d1
		move.w		wd_Width(a0),d1
		sub.w		#20,d1
		move.l		window.rp(a4),a0		a0-->window rastport
		divu		rp_TxWidth(a0),d1
		cmp.w		#70,d1
		ble.s		NoClip
		moveq		#70,d1
NoClip		lea		status_text(a4),a0

		move.b		#0,0(a0,d1.w)
		
		lea		status_struct,a1	a1-->text structure
		moveq.l		#5,d0			x pos of text
		move.l		window.ptr(a4),a0
		moveq		#0,d1
		move.w		wd_Height(a0),d1
		move.l		window.rp(a4),a0		a0-->window rastport
		sub.w		rp_TxHeight(a0),d1
		subq.l		#2,d1
		CALLINT		PrintIText		print status line
		movem.l		(sp)+,d0-d7/a0-a7
		rts

status_struct	dc.b	3,0	colours to use
		dc.b	RP_JAM2	mode to use
		dc.b	0
		dc.w	0,0	text position in window
		dc.l	0	font to use (standard)
status.ptr	dc.l	0	pointer to text
		dc.l	0	end of text list


;===========================================================
sprintf:
		move.l		a1,a3
		lea		4(sp),a1
		lea		PutChar(pc),a2
		CALLEXEC	RawDoFmt
		rts
	
PutChar:
		move.b		d0,(a3)+
		rts
		
*****************************************************************************

; Releases the main menu and then shuts down the main window.

CloseMainWin	move.l		window.ptr(a4),a0
		CALLINT		ClearMenuStrip

		move.l		window.ptr(a4),a0
		CALLSYS		CloseWindow
		
		rts
		
*****************************************************************************
; This routine checks each of the libraries base pointers and closes all 
;those that are set.  ****** NOOOO! it doesn't - guru maker here
;instuctions where the destination is an address reg will NOT effect
;the condition codes - Fixed this - Steve Marshall

CloseLibs	lea		Console_StdIO(a4),a0
		move.l		MN_REPLYPORT(a0),d0
		beq.s		NoPort
		move.l		d0,a1
		CALLARP		DeletePort
		
		lea		Console_StdIO(a4),a1
		CALLEXEC	CloseDevice
		
NoPort
		lea		Zombie_Message(a4),a0
		move.l		MN_REPLYPORT(a0),d0
		beq.s		NoPort2
		move.l		d0,a1
		CALLARP		DeletePort
		
NoPort2
		move.l		Blink_Seg(a4),d1
		beq.s		NoBlink
		CALLARP		UnLoadPrg
		
NoBlink		lea		A68k_name,a0
		CALLARP		RemResidentPrg
		;move.l		A68k_Seg(a4),d1
		;beq.s		closeARP
		;CALLSYS		UnLoadPrg
		
;-------- note we still have to close ARP ourselves  - DOS routine removed
;	  if we get to here the ARP library must be open as OPENARP will 
;	  will quit the program if the library can't be opened		

closeARP	move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary

allclosed	rts


;		incdir	source10:project/
		
;***********************************************************

	INCLUDE	list.s

;***********************************************************

;***********************************************************

	INCLUDE	cursor.s

;***********************************************************

;***********************************************************

	INCLUDE	Acc_Window.s

;***********************************************************

;***********************************************************

	INCLUDE	Assemble_Window.s

;***********************************************************

;***********************************************************

	INCLUDE	About_Window.s

;***********************************************************


;***********************************************************

	INCLUDE	Requesters.s

;***********************************************************

;***********************************************************

	INCLUDE	Goto_Window.s

;***********************************************************

;***********************************************************

	INCLUDE	Strings_Variables.s

;***********************************************************


