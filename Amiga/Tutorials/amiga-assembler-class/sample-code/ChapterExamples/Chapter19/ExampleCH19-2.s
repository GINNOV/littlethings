; ---------------------------------------------------------------------

; CH19-2.s - reentrant code example

; ---------------------------------------------------------------------

		include exec/exec.i		
		include intuition/intuition.i
		include libraries/gadtools.i

		include exec/exec_lib.i
		include intuition/intuition_lib.i
		include	libraries/gadtools_lib.i

		XDEF	_main
		
		
NULL			EQU	0

TRUE			EQU   	1

LIBRARY_COUNT		EQU  	2

_AbsExecBase		EQU	4

FSTACK_SIZEOF		EQU	8*4


	STRUCTURE	LocalData,0
		LABEL	ld_lib_base_start
		ULONG	ld_IntuitionBase
		ULONG	ld_GadToolsBase
		LABEL	ld_lib_base_end
		ULONG	ld_window_p
		ULONG	ld_visual_info_p
		ULONG	ld_menu_p
		STRUCT	ld_FStack,FSTACK_SIZEOF
		LABEL	LocalData_SIZEOF
	
	
; ---------------------------------------------------------------------

CALLSYS		MACRO
		LINKLIB	_LVO\1,\2
		ENDM

; ---------------------------------------------------------------------

_main		link	a4,#-LocalData_SIZEOF
		movem.l	a2-a5/d2-d3,-(sp)	preserve non-scratch regs
		move.l	_AbsExecBase,_SysBase	copy of exec library base
		
.setupfstack	move.l	a4,a5			top of local data
		move.l	#NULL,-(a5)		stack top identifier
		lea	-LocalData_SIZEOF(a4),a4 frame pointer to bottom
		
		lea 	lib_names,a2
		lea 	ld_lib_base_start(a4),a3
		move.w	#(LIBRARY_COUNT-1),d3	loop counter
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
		
		jsr	OpenWindow
		beq.s	closedown
		
		jsr	CreateMenu
		beq.s	closedown
		
		jsr	LayoutMenu
		beq.s	closedown

		jsr	InstallMenu
		beq.s	closedown		

		; now everything is set up we can call the event handler!

		movea.l ld_window_p(a4),a1
		movea.l wd_UserPort(a1),a2	user port address
		jsr	EventHandler		handle user actions

closedown	move.l	(a5)+,d0		retrieve function pointer
		beq.s	lib_normal_exit
		move.l	d0,a0
		jsr	(a0)			and execute routine if it exists!
		bra.s	closedown


lib_normal_exit	lea	ld_lib_base_end(a4),a3		
		moveq	#LIBRARY_COUNT,d2	library count
		jsr	CloseLibs		close libraries
		movem.l	(sp)+,a2-a5/d2-d3	restore non-scratch regs
		unlk	a4
		moveq	#0,d0			clear d0 for O/S
		rts				and terminate program

lib_error_exit	moveq	#(LIBRARY_COUNT-1),d2		
		sub	d3,d2
		jsr	CloseLibs		close libraries
		movem.l	(sp)+,a2-a5/d2-d3	restore non-scratch regs
		unlk	a4
		moveq	#0,d0			clear d0 for O/S
		rts				and terminate program

; ---------------------------------------------------------------------		

; CloseLibs() On entry...

; 	a3 should hold address of the longword location just past 
; 	   that of the first library to close (this is because the 
;	   routine uses a backward reading loop).

; 	d2 should hold count of the number of libraries to close	

CloseLibs	tst.b	d2			test counter
		beq.s	loop_end		
		movea.l	-(a3),a1		get library base
		CALLSYS	CloseLibrary,_SysBase
		subq.b	#1,d2
		bra.s	CloseLibs
loop_end	rts

; ---------------------------------------------------------------------					

; LockScreen() and UnlkScreen() on entry... need no register parameters!


LockScreen	lea	workbench_name,a0	pointer to screen name
		CALLSYS	LockPubScreen,ld_IntuitionBase(a4)
		move.l	d0,workbench_p		save returned pointer
		beq.s	.error
		move.l	#UnlkScreen,-(a5)	push deallocation routine address
.error		rts

UnlkScreen	movea.w	#NULL,a0		screen name not needed
		movea.l	workbench_p,a1		screen to unlock
		CALLSYS	UnlockPubScreen,ld_IntuitionBase(a4)
		rts

; ---------------------------------------------------------------------					

; OpenWindow() and ShutWindow() on entry... need no register parameters!


OpenWindow	movea.w	#NULL,a0
		lea	tags,a1			start of  tag list
		CALLSYS	OpenWindowTagList,ld_IntuitionBase(a4)
		move.l	d0,ld_window_p(a4)	save returned pointer
		beq.s	.error
		move.l	#ShutWindow,-(a5)	push deallocation routine address
.error		rts

ShutWindow	movea.l	ld_window_p(a4),a0	window to close
		CALLSYS	CloseWindow,ld_IntuitionBase(a4)
		rts

; ---------------------------------------------------------------------					

; GetVisInfo() and FreeVisInfo() on entry... need no register parameters!


GetVisInfo	movea.l	workbench_p,a0		
		movea.w	#TAG_END,a1		no tags
		CALLSYS	GetVisualInfoA,ld_GadToolsBase(a4)
		move.l	d0,ld_visual_info_p(a4)	save returned pointer
		beq.s	.error
		move.l	#FreeVisInfo,-(a5)	push deallocation routine address
.error		rts

FreeVisInfo	movea.l	ld_visual_info_p(a4),a0	
		CALLSYS	FreeVisualInfo,ld_GadToolsBase(a4)
		rts

; ---------------------------------------------------------------------					

; CreateMenu() and FreeMenu() on entry... need no register parameters!


CreateMenu	lea	menu,a0
		movea.w	#TAG_END,a1		no tags
		CALLSYS	CreateMenusA,ld_GadToolsBase(a4)
		move.l	d0,ld_menu_p(a4)	save returned pointer
		beq.s	.error
		move.l	#FreeMenu,-(a5)		push deallocation routine address
.error		rts

FreeMenu	movea.l	ld_menu_p(a4),a0	menu to free
		CALLSYS	FreeMenus,ld_GadToolsBase(a4)
		rts

; ---------------------------------------------------------------------					

; LayoutMenu() on entry... needs no register parameters!


LayoutMenu	movea.l	ld_menu_p(a4),a0
		movea.l	ld_visual_info_p(a4),a1
		movea.w	#TAG_END,a2		no tags
		CALLSYS	LayoutMenusA,ld_GadToolsBase(a4)
		tst.l	d0			nothing to deallocate
		rts

; ---------------------------------------------------------------------					

; InstallMenu() and RemoveMenu() on entry... need no register parameters!


InstallMenu	movea.l	ld_window_p(a4),a0
		movea.l	ld_menu_p(a4),a1
		CALLSYS	SetMenuStrip,ld_IntuitionBase(a4)
		tst.l	d0
		beq.s	.error
		move.l	#RemoveMenu,-(a5)	push deallocation routine address
.error		rts

RemoveMenu	movea.l	ld_window_p(a4),a0	target window
		CALLSYS	ClearMenuStrip,ld_IntuitionBase(a4)
		rts

; ---------------------------------------------------------------------	

; Function name:     EventHandler()

; Purpose:           Handles window menu events

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
		movem.l	(a7)+,d0-d4/a0-a2	restore registers
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
		beq.s	DoMenuItem0
		moveq	#TRUE,d2		set QUIT signal to exit routine 
		bra.s	GetMessage
		
DoMenuItem0	jsr	DoNothing
		bra.s	GetMessage		check for more messages!

GetMessageExit	rts				d2 holds exit flag

; ---------------------------------------------------------------------

DoNothing	rts			
			
; ---------------------------------------------------------------------

_SysBase	ds.l	1

tags		dc.l	WA_PubScreen
workbench_p	ds.l	1
		dc.l	WA_Left,300
		dc.l	WA_Top,0
		dc.l	WA_Width,340
		dc.l	WA_Height,10
		dc.l	WA_DragBar,TRUE
		dc.l	WA_DepthGadget,TRUE
		dc.l	WA_CloseGadget,TRUE
		dc.l	WA_SizeGadget,TRUE
		dc.l	WA_Zoom,zoom_data
		dc.l	WA_MinWidth,100
		dc.l	WA_MinHeight,10
		dc.l	WA_MaxWidth,640
		dc.l	WA_MaxHeight,256
		dc.l	WA_IDCMP,IDCMP_MENUPICK|IDCMP_CLOSEWINDOW
		dc.l	WA_Title,window_name
		dc.l	TAG_DONE,NULL

zoom_data	dc.w	10,10,340,200

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
		

lib_names	dc.l lib1,lib2

lib1		dc.b 'intuition.library',NULL
lib2		dc.b 'gadtools.library',NULL

workbench_name	dc.b 'Workbench',NULL

window_name	dc.b 'CH19-2 reentrant test',NULL

menu_title	dc.b 'PROJECT',NULL

item0		dc.b 'Do Something...',NULL

commkey0	dc.b 'S',NULL

item1		dc.b 'Quit to Workbench!',NULL

commkey1	dc.b 'Q',NULL
	
		END

; ---------------------------------------------------------------------


		