*********************************************************************
*
*	Program  to demonstrate  the use of  the input device
*	to add your own  input handlers. This  version uses a
*	crude method of message  passing so that  the calling
*	program can sleep until an event happens which we are
*	interested in. The message  passed holds  the ie_Code
*	and  ie_Qualifier information  so that you  could use
*	the same  handler to test  for a number  of different 
*	keys being pressed. 
*	
*	When run this program simply adds a handler then goes
*	to sleep  until you press  Ctrl/Esc. The program then
*	frees the message memory removes the handler and quits.
*
*	The main use for this code is in PopCLI type programs
*	where you want  your program  to sleep until the user
*	presses a certain key  combinations. It could also be
*	used with anti virus type programs to check each disk
*	as it is inserted.  The handler code would need a few
*	small changes to do this.
*
*		   Compiles with Devpac V2
*
*		      By Steve Marshall
*
*********************************************************************

	INCDIR	sys:INCLUDE/
	INCLUDE	EXEC/EXEC_LIB.I
	INCLUDE	EXEC/EXEC.I
	INCLUDE	EXEC/NODES.I
	INCLUDE	EXEC/IO.I
	INCLUDE	MISC/ARPBASE.I
	INCLUDE	DEVICES/INPUT.I
	INCLUDE	DEVICES/INPUTEVENT.I

**********

CALLSYS	MACRO
	JSR	_LVO\1(A6)
	ENDM

**********

	OPENARP
	move.l		a6,_ArpBase
	movem.l		(sp)+,d0/a0		;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt
						;stack
	
	bsr		OpenInputDevice		;open input device
	move.l		d0,InputIOB		;test for errors
	beq.s		.Error
	
	lea		InputCode,a0		;get our input handler code
	move.l		d0,a1			;get IOB
	moveq		#100,d0			;Set priority (Higher than Int!)
	bsr		SetInputHandler		;add our handler
	tst.l		d0			;check for errors
	bne.s		.NoHandler		;branch if error

.EventLoop	
	move.l		RPort(pc),a2		;extract port
	move.l		a2,a0			;port in a0
	CALLEXEC	WaitPort		;wait for message

	move.l		a2,a0			;port in a0
	CALLSYS		GetMsg			;get message
	move.l		d0,a1			;save message
	
	move.w		20(a1),d7		;get ie_Code
	move.w		22(a1),d6		;get ie_Qualifier
	
;------	We could now extract information from the message
	
	CALLSYS		ReplyMsg		;reply to message
	
	cmpi.w		#$45,d7			;ESC key pressed?
	bne.s		.EventLoop		;This event does not interest us

	btst		#IEQUALIFIERB_CONTROL,d6 ;CTRL pressed as well
	beq.s		.EventLoop		;branch if not

	move.l		InputIOB(pc),a1		;IO Request struct
	bsr		RemInputHandler		;remove handler
	
;------	We could now check which keys were pressed and act accordingly

.NoHandler
	move.l		InputIOB(pc),a1		;IO Request struct
	bsr		CloseInputDevice	;close input device
.Error	
	move.l		_ArpBase(pc),a1		;get ArpBase
	CALLEXEC	CloseLibrary		;close Arp.lib
	rts					;end of program


_ArpBase	dc.l	0
InputIOB	dc.l	0
IntPtr		dc.l	0
RPort		dc.l	0

**************************************************************************
*	IOB = OpenInputDevice()
**************************************************************************

OpenInputDevice
	movem.l		a5-a6,-(sp)		;save regs
	moveq		#IOSTD_SIZE,d0		;struct size
	move.l		#MEMF_PUBLIC|MEMF_CLEAR,d1 ;type of mem
	CALLEXEC	AllocMem		;allocate IOBlock
	tst.l		d0			;test result
	beq		NoIOB			;branch on error
	
	move.l		d0,a5			;store IOBlk ptr
	moveq		#0,d0			;clear d0 - pri = 0
	lea		PortName,a0		;set port name
	CALLARP		CreatePort		;create a port
	move.l		d0,MN_REPLYPORT(a5)	;store port
	move.l		d0,RPort		;save port for input code
	beq.s		NoPort			;branch if error

	moveq		#IS_SIZE,d0		;interrupt struct size
	move.l		#MEMF_PUBLIC+MEMF_CLEAR,d1 ;set mem type
	CALLEXEC	AllocMem		;allocete structure
	move.l		d0,IO_DATA(a5)		;Interrupt struct location
	beq.s		IntError		;branch if error
	
	move.l		d0,a0			;int struct in a0
	move.l		#0,IS_DATA(a0)		;Clear data
	move.l		#InterruptName,LN_NAME(a0) ;Interrupt name


	lea		InputDevName(pc),a0	;get device name
	move.l		a5,a1			;IOB
	moveq		#0,d0			;Unit 0
	moveq		#0,d1			;No special flags
	CALLSYS		OpenDevice		;Open input device
	tst.l		d0			;test result
	bne.s		DevError		;OpenDevice() error

	move.l		a5,d0			;return IOB in d0
	movem.l		(sp)+,a5-a6		;restore regs
	rts					;end of OpenInputDevice

**************************************************************************
*		CloseInputDevice(IOBlock)
*				   a1
**************************************************************************

CloseInputDevice	
	movem.l		a5-a6,-(sp)		;save regs
	move.l		a1,a5			;IO Request struct
	CALLEXEC	CloseDevice		;close input device
	
DevError
	move.l		IO_DATA(a5),a1		;Interrupt struct location
	moveq		#IS_SIZE,d0		;mem size
	CALLSYS		FreeMem			;free memory block
	
IntError
	move.l		MN_REPLYPORT(a5),a1	;get port
	CALLARP		DeletePort		;free port
	
NoPort
	move.l		a5,a1			;IO Request struct
	moveq		#IOSTD_SIZE,d0		;mem size
	CALLEXEC	FreeMem			;free memory block
	
NoIOB
	moveq		#0,d0			;flag error
	movem.l		(sp)+,a5-a6		;restore regs
	rts					;end of CloseInputDevice

**************************************************************************
*	Error =	SetInputHandler(Handler,IOBlock,Priority)
*	 d0			  a0       a1      d0
**************************************************************************

SetInputHandler:
	movem.l		a2/a6,-(sp)		;save regs
	
	move.l		IO_DATA(a1),a2		;Interrupt struct location
	move.l		a0,IS_CODE(a2)		;Address of handler routine
	move.b		d0,LN_PRI(a2)		;Set priority (Higher than Int!)
	move.l		a1,a2			;save ioblock
	
	moveq		#0,d0			;clear d0 - pri = 0
	move.l		d0,a0			;set no port name (private)
	CALLARP		CreatePort		;create a port
	move.l		d0,RPort2		;store port
	bne.s		.PortOK			;branch if no error
	
	moveq		#-1,d0			;error return
	bra.s		.exit			;branch to end

.PortOK	move.l		a2,a1			;get ioblock
	move.w		#IND_ADDHANDLER,IO_COMMAND(a1)	;command =  new handler
	CALLEXEC	DoIO			;Lets do it!

.exit	movem.l		(sp)+,a2/a6		;restore regs
	rts					;end of SetInputHandler

**************************************************************************
*	Error =	RemInputHandler(IOBlock)
*	  d0			  a1
**************************************************************************

RemInputHandler
	move.l		a6,-(sp)		;save regs
	move.w		#IND_REMHANDLER,IO_COMMAND(a1)	;command =  new handler
	CALLEXEC	DoIO			;Lets do it!
	
	move.l		RPort2(pc),d0		;get port
	beq.s		.NoPort			;branch if no port
	
	move.l		d0,a0			;get port
	CALLSYS		GetMsg			;check for message reply
	tst.l		d0			;test result
	beq.s		.NoMsg			;branch if no msg
	
	move.l		d0,a1			;get message
	cmpi.b		#NT_REPLYMSG,LN_TYPE(a1);test node type
	bne.s		.NoMsg			;branch if not a reply
	
	move.w		MN_LENGTH(a1),d0	;get msg length
	ext.l		d0			;make long 
	CALLSYS		FreeMem			;free message memory
	
.NoMsg	move.l		RPort2(pc),a1		;get port
	CALLARP		DeletePort		;delete port
	
.NoPort	move.l		(sp)+,a6		;restore regs
	rts					;end of RemInputHandler
	
**************************************************************************
;	This is the code called by the input handler
**************************************************************************

InputCode
	movem.l		a0/a2/a6,-(sp)		;Save event list
	
.Loop	move.l		RPort2(pc),a0		;get port
	CALLEXEC	GetMsg			;check for message reply
	tst.l		d0			;test result
	beq.s		.Loop1			;branch if no msg
	
	move.l		d0,a1			;get message
	cmpi.b		#NT_REPLYMSG,LN_TYPE(a1);test node type
	bne.s		.Loop1			;branch if not a reply
	
	move.w		MN_LENGTH(a1),d0	;get msg length
	ext.l		d0			;make long 
	CALLSYS		FreeMem			;free message memory
	
.Loop1	movem.l		(sp),a0/a2/a6		;restore regs

	move.l		a0,a2			;save event
	cmpi.b		#IECLASS_RAWKEY,ie_Class(a2) ;A rawkey event?
	bne.s		.Skip			;This event doesn't interest us
	
	moveq		#24,d0			;message size
	move.l		#MEMF_PUBLIC|MEMF_CLEAR,d1 ;memory type
	CALLEXEC	AllocMem
	tst.l		d0			;test result
	beq.s		.Skip			;branch on no memory

	move.l		RPort(pc),a0		;port in a0
	move.l		d0,a1			;get message
	move.b		#NT_MESSAGE,LN_TYPE(a1)	;set node type
	move.w		#24,MN_LENGTH(a1)	;set msg length
	move.l		RPort2(pc),MN_REPLYPORT(a1) ;set reply port
	move.w		ie_Code(a2),20(a1)	;add ie_Code
	move.w		ie_Qualifier(a2),22(a1)	;add ie_Qualifier
	CALLSYS		PutMsg			;send message

;------	Condition codes are set with the first instruction
.Skip	move.l		(a2),d0			;ie_NextEvent
	move.l		d0,a0			;in a0
	bne.s		.Loop1			;check next event.

	movem.l		(sp)+,a0/a2/a6		;restore regs
	move.l		a0,d0			;Event list -> d0
	rts					;end of InputCode

**************************************************************************

RPort2	dc.l	0

**************************************************************************
;	Structure and strings used by the input device subroutines
**************************************************************************

InputDevName
	dc.b	'input.device',0
	EVEN
	
InterruptName
	dc.b	'My.input.handler',0
	EVEN	
	
PortName
	dc.b	'Input.Port',0
