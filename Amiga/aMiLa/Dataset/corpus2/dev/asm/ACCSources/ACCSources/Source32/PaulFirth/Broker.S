; Broker version 1.0 (7/11/93)
; 
; Conversion of AMCX from AmigaMail
;

		incdir		sys:include2.0/
		
		include		exec/exec_lib.i
		include		exec/ports.i
		include		libraries/commodities.i
		include		libraries/commodities_lib.i
		include		dos/dos.i
		include		dos/dos_lib.i
		include		clarityov_macros.i

		
NULL		EQU		0
FALSE		EQU		0
TRUE		EQU		1

CR		EQU		10

		
CALLLCOM		MACRO
		move.l		COMMOD_BASE,a6
		jsr		_LVO\1(a6)
		ENDM		

;----------------------------------------------------------------------------
INITIALISE
		jsr		OPEN_COMMODITIES
		IF_NOT		EXIT

		jsr		OPEN_DOS
		IF_NOT		CLOSE_COMMODITIES

		jsr		GET_STDOUT
		IF_NOT		CLOSE_DOS
		
		jsr		CREATE_MSG_PORT
		IF_NOT		CLOSE_DOS

		jsr		GET_WAIT_MASK
		
		jsr		MAKE_BROKER
		IF_NOT		DELETE_BROKER_MP
		
		jsr		ACTIVATE_CXOBJECT

		bra		WAIT_MESSAGES

;---------------initialise---------------------------------------------------
OPEN_COMMODITIES
		lea		COMMOD_NAME,a1
		moveq.l		#37,d0
		CALLLEXEC	OpenLibrary
		move.l		d0,COMMOD_BASE
		rts
;---------------
OPEN_DOS
		lea		DOS_NAME,a1
		moveq.l		#37,d0
		CALLLEXEC	OpenLibrary
		move.l		d0,DOS_BASE
		rts
;---------------
GET_STDOUT
		CALLLDOS		Output
		move.l		d0,STD_OUT
		rts
;---------------			
CREATE_MSG_PORT
		CALLLEXEC	CreateMsgPort
		move.l		d0,BROKER_MP
		rts
;---------------
GET_WAIT_MASK
		clr.l		d0

		moveq.l		#1,d1
		
		move.l		BROKER_MP,a0
		move.b		MP_SIGBIT(a0),d0		;get sigbit for commodites msgport

		asl.l		d0,d1				;shift into place

		or.l		#SIGBREAKF_CTRL_C,d1
		move.l		d1,WAIT_MASK			;store wait mask
		rts
;---------------
MAKE_BROKER
		lea		NULL_LONG,a0
		move.l		a0,d0				;null longword in d0

		lea		BROKER_STRUCT,a0		;broker struct in a0
		move.l		BROKER_MP,nb_Port(a0)		;setup our brokers message port

		CALLLCOM		CxBroker
		move.l		d0,BROKER

		;lea		NULL_LONG,a0
		;cmpi.l		#CBERR_SYSERR,(a0)		;low memory error

		;cmpi.l		#CBERR_DUP,(a0)			;unique error (another commod with same name launched

		;cmpi.l		#CBERR_VERSION,(a0)		;unknown version
		rts
;---------------		
ACTIVATE_CXOBJECT
		move.l		BROKER,a0
		moveq.l		#TRUE,d0
		CALLLCOM		ActivateCxObj			;make our commodity activated
		rts

;---------------wait messages------------------------------------------------
WAIT_MESSAGES
		move.l		WAIT_MASK,d0
		CALLLEXEC	Wait				;go to sleep

GET_MESSAGE
		move.l		BROKER_MP,a0			;test brokers msgport
		CALLLEXEC	GetMsg
		IF_NOT		WAIT_MESSAGES			;no messages? then wait some more		
		move.l		d0,a2

		move.l		a2,a0
		CALLLCOM		CxMsgID
		move.l		d0,MSG_ID			;get msg id
		
		move.l		a2,a0
		CALLLCOM		CxMsgType
		move.l		d0,MSG_TYPE			;get msg type
		
		move.l		a2,a1
		CALLLEXEC	ReplyMsg			;reply message
		
		move.l		MSG_TYPE,a0
		;cmp.l		#CXM_IEVENT,a0			;shouldn't get any of these in this example

		cmp.l		#CXM_COMMAND,a0			;commodities has sent a command
		beq		COMMAND_CHECK

		bra.s		GET_MESSAGE			;check for more

;---------------subroutines--------------------------------------------------
COMMAND_CHECK
		jsr		PRINT_COMMAND
		
		move.l		MSG_ID,a0

		cmp.l		#CXCMD_DISABLE,a0		;command sub set
		beq		DEACTIVATE_COMMODITY
		
		cmp.l		#CXCMD_ENABLE,a0
		beq		ACTIVATE_COMMODITY

		cmp.l		#CXCMD_KILL,a0
		beq		REMOVE_MESSAGES		

		bra		GET_MESSAGE			;check for more
;---------------
PRINT_COMMAND
		move.l		MSG_ID,a0
		
		cmp.l		#CXCMD_DISABLE,a0
		beq		PRINT_DISABLE

		cmp.l		#CXCMD_ENABLE,a0
		beq		PRINT_ENABLE
		
		cmp.l		#CXCMD_KILL,a0
		beq		PRINT_KILL
		
PRINT_EXIT
		rts		

PRINT_DISABLE
		move.l		STD_OUT,d1			;cli output handle
		lea		DISABLE_MSG,a0
		move.l		a0,d2				;message
		moveq.l		#NULL,d3			;% commands
		CALLLDOS		VFPrintf			;print it
	
		bra		PRINT_EXIT

PRINT_ENABLE
		move.l		STD_OUT,d1			;cli output handle
		lea		ENABLE_MSG,a0
		move.l		a0,d2				;message
		moveq.l		#NULL,d3			;% commands
		CALLLDOS		VFPrintf			;print it
	
		bra		PRINT_EXIT

PRINT_KILL
		move.l		STD_OUT,d1			;cli output handle
		lea		KILL_MSG,a0
		move.l		a0,d2				;message
		moveq.l		#NULL,d3			;% commands
		CALLLDOS		VFPrintf			;print it
	
		bra		PRINT_EXIT
;---------------		
ACTIVATE_COMMODITY
		move.l		BROKER,a0
		moveq.l		#TRUE,d0
		CALLLCOM		ActivateCxObj
		bra		GET_MESSAGE

DEACTIVATE_COMMODITY
		move.l		BROKER,a0
		moveq.l		#FALSE,d0
		CALLLCOM		ActivateCxObj
		bra		GET_MESSAGE
;----------------------------------------------------------------------------		
REMOVE_MESSAGES
		move.l		BROKER_MP,a0
		CALLLEXEC	GetMsg
		tst.l		d0
		beq		DELETE_COMMODITY		;carry on
		
		move.l		d0,d1
		CALLLEXEC	ReplyMsg			;make sure no more messages when we exit!!
		bra.s		REMOVE_MESSAGES
				
DELETE_COMMODITY
		move.l		BROKER,a0			;time to clean up
		CALLLCOM		DeleteCxObj			;delete our object

DELETE_BROKER_MP		
		move.l		BROKER_MP,a0
		CALLLEXEC	DeleteMsgPort			;delete our message port
		
CLOSE_DOS
		move.l		DOS_BASE,a1
		CALLLEXEC	CloseLibrary

CLOSE_COMMODITIES
		move.l		COMMOD_BASE,a1
		CALLLEXEC	CloseLibrary
		
EXIT
		clr.l		d0
		rts				
;----------------------------------------------------------------------------
BROKER_STRUCT	dc.b		NB_VERSION			;version of structure
		dc.b		NULL				;allignment
		dc.l		BROKER_NAME			;name cx uses to identify us
		dc.l		BROKER_TITLE			;title of commodity that appears in cx
		dc.l		BROKER_DISCRIPT			;discription of commodity that appears in cx
		dc.w		0				;tells cx not to launch new commodity with same name
		dc.w		0				;tells cx if this commodity has a window
		dc.b		0				;this commodities priority
		dc.b		NULL				;allignment
		dc.l		NULL				;message port cx talks to
		dc.w		NULL				;reserved channel - later use

DOS_BASE	ds.l		1

BROKER_MP	ds.l		1
BROKER		ds.l		1
BROKER_SIGBITS	ds.l		1
COMMOD_BASE	ds.l		1

STD_OUT		ds.l		1

MSG_ID		ds.l		1
MSG_TYPE	ds.l		1
WAIT_MASK	ds.l		1

NULL_LONG	dc.l		NULL

BROKER_NAME	dc.b		'AmigaMail broker',0
BROKER_TITLE	dc.b		'Broker',0
BROKER_DISCRIPT	dc.b		'A simple example of a broker',0

DISABLE_MSG	dc.b		'Command: CXCMD_DISABLE',CR,0
ENABLE_MSG	dc.b		'Command: CXCMD_ENABLE',CR,0
KILL_MSG	dc.b		'Command: CXCMD_KILL',CR,0

DOS_NAME	dc.b		'dos.library',0
COMMOD_NAME	dc.b		'commodities.library',0						