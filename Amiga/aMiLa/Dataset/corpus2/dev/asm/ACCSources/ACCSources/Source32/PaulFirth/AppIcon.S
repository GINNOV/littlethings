; AppIcon
;
; Vesion 1.00 (15/11/93)
;
; Conversion of AmigaMail version
;
; © Copyright 1993 Paul Firth.

		incdir		sys:include2.0/
		
		include		exec/exec_lib.i
		include		intuition/intuition_lib.i
		include		exec/memory.i
		include		workbench/startup.i
		include		workbench/workbench.i
		include		workbench/wb_lib.i
		include		dos/dos_lib.i
		include		dos/dosextens.i
		
		include		clarityov_macros.i
		include		misc/easystart.i
		
NULL		EQU		0
FALSE		EQU		0
TRUE		EQU		1

ID		EQU		1				;just to look at in our messages
USER_DATA	EQU		0

CR		EQU		10
;----------------------------------------------------------------------------
INITIALISE
		jsr		OPEN_DOS
		IF_NOT		EXIT

		jsr		OPEN_INTUITION
		IF_NOT		CLOSE_DOS

		jsr		OPEN_WORKBENCH
		IF_NOT		CLOSE_INTUITION

SETUP_INVISIBLES
		jsr		GET_CLI_HANDLE
		IF_NOT		CLOSE_WORKBENCH
		
		jsr		CREATE_MSG_PORT
		IF_NOT		CLOSE_WORKBENCH

SETUP_VISIBLES		
		jsr		OPEN_WINDOW
		IF_NOT		DELETE_MSG_PORT	

		jsr		ADD_APP_ICON
		IF_NOT		CLOSE_WINDOW
		
MESSAGE_HANDLING
		jsr		GET_PORT_MASKS
		bra		WAIT_MESSAGES			;we won't be going anywhere from here!
;----------------------------------------------------------------------------			
OPEN_DOS
		lea		DOS_NAME,a1
		moveq.l		#36,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		rts
		
OPEN_INTUITION
		lea		INTUITION_NAME,a1
		moveq.l		#36,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_IntuitionBase
		rts
		
OPEN_WORKBENCH
		lea		WB_NAME,a1
		moveq.l		#36,d0
		CALLEXEC	OpenLibrary
		move.l		d0,WB_BASE
		rts
;----------------------------------------------------------------------------						
GET_CLI_HANDLE
		CALLDOS		Output
		move.l		d0,STD_OUT			;get cli output handle
		rts

CREATE_MSG_PORT
		CALLEXEC	CreateMsgPort
		move.l		d0,MSG_PORT		
		rts
;----------------------------------------------------------------------------
OPEN_WINDOW
		move.l		#NULL,a0			;new window struct
		lea		WINDOW_TAGS,a1			;windows tags 
		CALLINT		OpenWindowTagList
		move.l		d0,WINDOW_POINTER
		rts
;----------------------------------------------------------------------------							
ADD_APP_ICON
		moveq.l		#ID,d0				;user use only
		moveq.l		#USER_DATA,d1			;ditto
		lea		APPI_TEXT,a0			;name of app icon
		move.l		MSG_PORT,a1			;msg port to send messages to
		move.l		#NULL,a2			;currently unused
		lea		APP_DISKOBJ,a3			;disk object struct (picy and more)
		move.l		#NULL,a4			;tag list
		
		CALLWB		AddAppIconA
		move.l		d0,APPI_POINTER
		rts
;----------------------------------------------------------------------------		
GET_PORT_MASKS
		move.l		WINDOW_POINTER,a1
		move.l		wd_UserPort(a1),a1		;get window's user port
		moveq.l		#1,d1
		clr.l		d0
		move.b		MP_SIGBIT(a1),d0
		asl.l		d0,d1
		move.l		d1,d4				;window wait mask in d4

		move.l		MSG_PORT,a1
		moveq.l		#1,d1
		clr.l		d0
		move.b		MP_SIGBIT(a1),d0
		asl.l		d0,d1				;port wait mask in d1
		
		or.l		d4,d1				;get bit mask for wait()
		move.l		d1,WAIT_BITMASKS
		rts

WAIT_MESSAGES
		move.l		WAIT_BITMASKS,d0
		CALLEXEC	Wait				;go to sleep
		
GET_INT_MESSAGE
		move.l		WINDOW_POINTER,a0
		move.l		wd_UserPort(a0),a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq		GET_APPI_MESSAGE		;check appi messages

		PUSH		d0				;save d0 from replymsg
		move.l		d0,a1
		CALLEXEC	ReplyMsg			;reply now to calling message
		PULL		d0
		
		move.l		d0,a0
		cmpi.l		#CLOSEWINDOW,im_Class(a0)	;see if window was told to close
		beq		REMOVE_MSG_PORT_MSGS		;close if we were
		
		bra.s		GET_INT_MESSAGE			;go and check for more...
		
GET_APPI_MESSAGE
		move.l		MSG_PORT,a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq.s		WAIT_MESSAGES			;if there are no messages here then wait again
		
		PUSH		d0				;in d0 is our message, something was dropped on our icon or it was click on
		
		move.l		d0,a0

		lea		FIRST_VALUES,a1			;the next lines write the values in the message		
								;into the vfprintf structure
		move.l		a0,(a1)				;appmsg
		move.w		am_Type(a0),4(a1)		
		move.l		am_ID(a0),6(a1)
		move.l		am_UserData(a0),10(a1)		
		move.l		am_NumArgs(a0),14(a1)
		move.l		am_NumArgs(a0),d6		;counter
		move.l		am_ArgList(a0),ARG_PTR		;store argptr

		move.l		STD_OUT,d1			;standard output window
		lea		FIRST_MESSAGE,a0
		move.l		a0,d2				;message in d2
		lea		FIRST_VALUES,a0
		move.l		a0,d3				;values in d3
		CALLDOS		VFPrintf			;do it!!
;---------------		
		move.l		d6,d4				;counter (am_numargs)
		tst.l		d4				;test to see if user double clicked
		beq		DOUBLE_CLICKED
		subq.l		#1,d4				;-1 for dbra
	
PRINT_LOOP
		move.l		ARG_PTR,a0 
		lea		SECOND_VALUES,a1
		move.l		d4,(a1)				;arg no.
		move.l		wa_Name(a0),4(a1)		;name of file dropped on us
		move.l		wa_Lock(a0),8(a1)		;lock of the file
		addq.l		#4,ARG_PTR

		move.l		STD_OUT,d1			;output handle in d1
		lea		SECOND_MESSAGE,a0
		move.l		a0,d2				;message in d2
		lea		SECOND_VALUES,a0
		move.l		a0,d3				;needs values in d3
	
		CALLDOS		VFPrintf			;do it!!

		dbra		d4,PRINT_LOOP
		
		PULL		d0
		move.l		d0,a1
		CALLEXEC	ReplyMsg			;reply now to caller message

		bra		GET_APPI_MESSAGE		;loop for more

DOUBLE_CLICKED
		move.l		STD_OUT,d1
		lea		THIRD_MESSAGE,a0
		move.l		a0,d2
		moveq.l		#NULL,d3
		CALLDOS		VFPrintf			;tell user he/she double clicked

		PULL		d0
		move.l		d0,a1
		CALLEXEC	ReplyMsg
		
		bra		GET_APPI_MESSAGE
		rts						;will never get here
;----------------------------------------------------------------------------
REMOVE_MSG_PORT_MSGS
		move.l		MSG_PORT,a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq		REMOVE_WINS_MESSAGES
		
		move.l		d0,d1
		CALLEXEC	ReplyMsg			;make sure no more messages when we exit!!
		bra.s		REMOVE_MSG_PORT_MSGS

REMOVE_WINS_MESSAGES
		move.l		WINDOW_POINTER,a0
		move.l		wd_UserPort(a0),a0		;get window's msg port
		CALLEXEC	GetMsg
		tst.l		d0
		beq		REMOVE_APP_ICON			;continue if no more
		
		move.l		d0,d1
		CALLEXEC	ReplyMsg			;make sure no more messages when we exit!!
		bra.s		REMOVE_WINS_MESSAGES

REMOVE_APP_ICON
		move.l		APPI_POINTER,a0
		CALLWB		RemoveAppIcon

CLOSE_WINDOW
		move.l		WINDOW_POINTER,a0
		CALLINT		CloseWindow		

DELETE_MSG_PORT
		move.l		MSG_PORT,a0
		CALLEXEC	DeleteMsgPort

CLOSE_WORKBENCH
		move.l		WB_BASE,a1
		CALLEXEC	CloseLibrary
				
CLOSE_INTUITION
		move.l		_IntuitionBase,a1
		CALLEXEC	CloseLibrary
		
CLOSE_DOS
		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary
		
EXIT
		clr.l		d0
		rts						;come down
;----------------------------------------------------------------------------
WINDOW_TAGS	dc.l		WA_Left,0
		dc.l		WA_Top,0
		dc.l		WA_Width,160
		dc.l		WA_Height,50
		dc.l		WA_IDCMP,CLOSEWINDOW
		dc.l		WA_Flags,WFLG_CLOSEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET
		dc.l		WA_Title,WINDOW_TITLE
		dc.l		TAG_DONE

_IntuitionBase	ds.l		1
_DOSBase	ds.l		1
WB_BASE		ds.l		1

MSG_PORT	ds.l		1
APPI_POINTER	ds.l		1
STD_OUT		ds.l		1
ARG_PTR		ds.l		1
WAIT_BITMASKS	ds.l		1
WINDOW_POINTER	ds.l		1

FIRST_VALUES	dc.l		NULL				;appmsg			
		dc.w		NULL				;type
		dc.l		NULL				;id
		dc.l		NULL				;userdata
		dc.l		NULL				;num args

SECOND_VALUES	dc.l		NULL				;arg number
		dc.l		NULL				;pointer to a name
		dc.l		NULL				;lock
		
FIRST_MESSAGE	dc.b		'ai: appmsg=%lx, Type=%d, ID=%ld, UserData=%ld, NumArgs=%ld',CR,0
SECOND_MESSAGE	dc.b		'arg(%ld): Name=''%s'', Lock=%lx',CR,0
THIRD_MESSAGE	dc.b		'you double clicked on me!!',CR,0

WINDOW_TITLE	dc.b		'AppIcon!',0
APPI_TEXT	dc.b		'Appy man',0

INTUITION_NAME	dc.b		'intuition.library',0
DOS_NAME	dc.b		'dos.library',0
WB_NAME		dc.b		'workbench.library',0
		cnop		0,4
		
		include		appicon.i										