;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : Paint.s
;* Created on       : 12-Nov-93
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: A basic paint program that is CLI driven! The object is to
;*          demonstrate inter-task communication as all commands must be
;*          passed to this program via its Public Port called  'MMPaint'.
;*                                                    M.Meany (12-Nov-93)
;*          
;*
;* V0.000 : --- Initial release ---
;*
;*************************************************************************
REVISION        MACRO
                dc.b "0.000"
                ENDM
REVDATE         MACRO
                dc.b "12-Nov-93"
                ENDM


	incdir	sys:include/
	include exec/exec.i
	include exec/exec_lib.i

	include libraries/dos.i
	include libraries/dosextens.i
	include libraries/dos_lib.i

	include graphics/gfxbase.i
	include	graphics/graphics_lib.i

	include intuition/intuition.i
	include intuition/intuition_lib.i

	include	devices/console_lib.i
	include devices/inputevent.i
	include	source:include/mmMacros.i

		rsreset
myio_Msg	rs.b		MN_SIZE		standar Message header
myio_Command	rs.b		40		max of 40 characters
myio_SIZE	rs.b		0

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		lea		Variables,a5	variable  base

		move.l		a0,_args(a5)	save addr of CLI args
		move.l		d0,_argslen(a5)	and the length

		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		InitPort
		tst.l		d0
		beq		no_port

		bsr		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_win		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

no_port		bsr		FreePort

no_win		bsr		DeInit		free resources

no_libs		bsr		Closelibs	close open libraries

		rts				finish

;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg	are we from WorkBench?
		bne.s		.ok		if so ignore usage bit

		CALLDOS		Output		determine CLI handle
		move.l		d0,STD_OUT(a5)	and save it for later
		beq.s		.err		quit if there is no handle

		move.l		_args(a5),a0	get addr of CLI args
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok		if not skip the next bit

		lea		_UsageText(pc),a0	a0->the usage text
		bsr		DosMsg		and display it
.err		moveq.l		#0,d0		set an error
		bra.s		.error		and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0		no errors

.error		rts				back to main

**************	Get Port

; Get a port for communication

InitPort	CALLEXEC	CreateMsgPort
		move.l		d0,MyPort(a5)
		beq		.Error

; Generate and store signal mask for this port

		move.l		d0,a1
		moveq.l		#0,d0
		moveq.l		#1,d1
		move.b		MP_SIGBIT(a1),d0
		asl.l		d0,d1
		move.l		d1,PortSigMask(a5)

; Make the port public

		move.l		#PortName,LN_NAME(a1)
		CALLEXEC	AddPort

		moveq.l		#1,d0

.Error		rts

*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,win.ptr(a5)	save struct ptr
		beq.s		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),win.up(a5) ;save up ptr
		move.l		wd_RPort(a0),win.rp(a5)    ;save rp ptr

;--------------	Get window signal bit

		move.l		win.up(a5),a0
		moveq.l		#1,d0
		moveq.l		#0,d1
		move.b		MP_SIGBIT(a0),d1
		asl.l		d1,d0
		move.l		d0,WinSigMask(a5)

.win_error	rts				all done so return

*************** Deal with User interaction

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget/menu service subroutines should set
;d2=0 to ensure accidental QUIT is not forced. If a QUIT gadget is used
;it should set d2=CLOSEWINDOW.


WaitForMsg	move.l		WinSigMask(a5),d0
		or.l		PortSigMask(a5),d0
		CALLEXEC	Wait

; Determine what caused us to wake up

		move.l		WinSigMask(a5),d1
		and.l		d0,d1
		bne.s		.DoIntui
		
		bsr		HandlePort
		bra.s		WaitForMsg

.DoIntui	move.l		win.up(a5),a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a4 a4=addr of structure
		CALLSYS		ReplyMsg	answer os or it get angry

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a4),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump

		lea		.QuitMsg,a0
		bsr		TFReq
		tst.l		d0
		beq.s		WaitForMsg

		rts

.QuitMsg	dc.b		'Quit Program?',0
		even

***************	Deal with messages arriving at our port

HandlePort	move.l		PortSigMask(a5),d1
		and.l		d0,d1
		beq		.Done

; Was a Message, get it from the Port

.NextMsg	move.l		MyPort(a5),a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq		.Done

; Got the Message, deal with it!

		move.l		d0,Received(a5)

; Get pointer to command sent

		move.l		d0,a0
		lea		myio_Command(a0),a4	a4->command

; See if it's a Move command

		cmpi.l		#'MOVE',(a4)
		bne.s		.TryLine
		bsr		DoMove
		bra		.AnswerIt

; See if it's a Line command

.TryLine	cmpi.l		#'LINE',(a4)
		bne.s		.TryPlot
		bsr		DoLine
		bra		.AnswerIt

; See if it's a Plot command

.TryPlot	cmpi.l		#'PLOT',(a4)
		bne.s		.TryPen0
		bsr		DoPlot
		bra		.AnswerIt

; See if its a Pen0 command

.TryPen0	cmpi.l		#'PEN0',(a4)
		bne.s		.TryPen1
		bsr		DoPen0
		bra		.AnswerIt

; See if it's a Pen1 command

.TryPen1	cmpi.l		#'PEN1',(a4)
		bne.s		.AnswerIt
		bsr		DoPen1
		bra		.AnswerIt

; Could put checks here for more commands


; Now reply it and loop for more!

.AnswerIt	move.l		Received(a5),a1
		CALLEXEC	ReplyMsg
		bra		.NextMsg

.Done		rts

*************** Close the Intuition window.

Closewin	move.l		win.ptr(a5),a0	a0->Window struct
		CALLINT		CloseWindow	and close it
		rts

***************	Free the Port

FreePort	tst.l		MyPort(a5)
		beq.s		.Done

; Remove port from public list

		move.l		MyPort(a5),a1
		CALLEXEC	RemPort

; Reply all outstanding Messages

.ByeMsg		move.l		MyPort(a5),a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq		.AllGone

		move.l		d0,a1
		CALLEXEC	ReplyMsg
		bra		.ByeMsg

; Free the port

.AllGone	move.l		MyPort(a5),a0
		CALLEXEC	DeleteMsgPort

; All done so exit

.Done		rts

***************	Release any additional resources used

DeInit
		rts

***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_IntuitionBase,d0	d0=base ptr	
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

**************	OK requester

; Entry		a0->text string

; Exit		none

; Corrupt	d0

OKReq		PUSHALL

		lea		.TheEasy,a1		EasyStruct
		move.l		a0,es_TextFormat(a1)	set text
		
		move.l		win.ptr(a5),a0		Window
		suba.l		a2,a2			No IDCMP
		suba.l		a3,a3
		CALLINT		EasyRequestArgs		display it

.done		PULLALL
		rts

.TheEasy	dc.l		es_SIZEOF
		dc.l		0			no flags
		dc.l		0			title
		dc.l		0			text
		dc.l		.Gadgets

.Gadgets	dc.b		'Ok',0
		even

**************	True/False requester

; Entry		a0->text string

; Exit		d0=result 1=true( OK ), 0=false( Cancel )

; Corrupt	d0

TFReq		PUSHALL

		lea		.TheEasy,a1		EasyStruct
		move.l		a0,es_TextFormat(a1)	set text
		
		move.l		win.ptr(a5),a0		Window
		suba.l		a2,a2			No IDCMP
		suba.l		a3,a3
		CALLINT		EasyRequestArgs		display it

.done		PULLALL
		rts

.TheEasy	dc.l		es_SIZEOF
		dc.l		0			no flags
		dc.l		0			title
		dc.l		0			text
		dc.l		.Gadgets

.Gadgets	dc.b		'Ok|Cancel',0
		even

**************	General CLI printing routine

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp) save registers

		tst.l		STD_OUT(a5)	test for open console
		beq		.error		quit if not one

		move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT(a5),d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts

***************	Reads a number from a string

;--------------
;--------------	Subroutine to convert a string into a long word value
;--------------

; Entry		a0->start of string
; Exit		a0->1st character of next number
;		d0=long word value
;		d1=0 if error, 1 if converted ok.
; Corrupt	d0, d1 & a0.

; String can contain following identifiers:	$	Hex number follows
;						#	Decimal number
;						&	Octal number
;						%	Binary number
; NOTE: Decimal identifier is optional.

; Routine stops evaluating when a character outside range is reached. The
;address of this character is returned to calling routine.

NUM_SPECIFIERS	equ		4		four unique base specifiers

StrToVal	movem.l		d2/d5/d6/d7/a1/a2,-(sp)	save registers

; a0->start of string at this point

		lea		.SpecifierTable(pc),a1	a1->start of table
		moveq.l		#0,d1			clear register

.next_specifier	move.w		(a1)+,d1		d1=next entry
		beq.s		.error			quit if end of table

		cmp.b		(a0),d1			found specifier?
		bne.s		.next_specifier		if not check next

; If we get to here, d1 contains the info we require on the specifier

		asr.w		#8,d1			base into lowest byte
		move.l		d1,d7			d7=conversion factor

; Scan the string to determine it's end

		move.l		a0,a1		make copy of string pointer

; Determine if 1st character is a specifier

		lea		.SpecifierTable(pc),a2	ptr to look-up table
		move.l		#NUM_SPECIFIERS-1,d1	loop counter

.spec_loop	move.w		(a2)+,d2		get next specifier
		cmp.b		(a1),d2			specifier found
		bne.s		.loop_end		if not skip!
		addq.l		#1,a1			else bump pointer
		moveq.l		#0,d1			force loop exit
.loop_end	dbra		d1,.spec_loop		check all specifiers

; a1 now points to the start of the digits in the string.

		bsr.s		.GetByteVal		check 1st digit
		tst.l		d0			is it valid
		bne.s		.scan_loop		if so continue
		move.l		d0,d1			else set error
		bra.s		.error			and quit

.scan_loop	addq.l		#1,a1			bump to next char
		bsr.s		.GetByteVal		convert char
		tst.l		d0			is it valid?
		bne.s		.scan_loop		if so loop back

; a1 now points to the byte after the last legal character and at least one
;legal digit exsists.

		moveq.l		#0,d6			will hold conversion
		moveq.l		#1,d5			index for conversion
		move.l		a1,a2			copy end pointer
		
.convert_loop	subq.l		#1,a1			back one char
		bsr.s		.GetByteVal		convert it
		tst.l		d0			legal?
		beq.s		.convert_done		if not skip

		subq.l		#1,d0			must correct return		
		mulu		d5,d0			x index
		add.l		d0,d6			add to total
		mulu		d7,d5			index=index*base
		
		cmpa.l		a0,a1			at the start yet?
		bne.s		.convert_loop		if not loop back

.convert_done	move.l		d6,d0			total into d0
		moveq.l		#1,d1			no errors
		move.l		a2,a0			a0->next char
		addq.l		#1,a0
		
.error		movem.l		(sp)+,d2/d5/d6/d7/a1/a2	restore
		rts					and return
		
; Look-up table that defines all legal number base specifiers

.SpecifierTable	dc.b		16,'$'		$ is for base 16
		dc.b		10,'#'		# is for base 10
		dc.b		8,'&'		& is for base 8
		dc.b		2,'%'		% is for base 2
; The following entries are for strings with no specifier
		dc.b		10,'1'		1 is for base 10
		dc.b		10,'2'		1 is for base 10
		dc.b		10,'3'		1 is for base 10
		dc.b		10,'4'		1 is for base 10
		dc.b		10,'5'		1 is for base 10
		dc.b		10,'6'		1 is for base 10
		dc.b		10,'7'		1 is for base 10
		dc.b		10,'8'		1 is for base 10
		dc.b		10,'9'		1 is for base 10
		dc.b		10,'0'		1 is for base 10
		dc.b		0,0		end of table

;--------------	Subroutine to convert a digit

;Entry		a1->character

;Exit		d0=0 if character is invalid or value of character plus 1

;Corrupt	d0

.GetByteVal	move.l		a0,-(sp)	save registers
		move.l		d1,-(sp)

		moveq.l		#0,d0		clear register
		lea		.CharTable(pc),a0	a0->digit lookup table
		move.b		(a1),d1		d1=digit to convert

.loop		move.w		(a0)+,d0	get next entry
		beq.s		.done		quit if end of table

		cmp.b		d0,d1		found digit?
		bne.s		.loop		if not loop back

		asr.w		#8,d0		value into low byte

		cmp.b		d0,d7		compare with base
		bge.s		.done		if legal then skip
		moveq.l		#0,d0		else flag an error

.done		move.l		(sp)+,d1	restore registers
		move.l		(sp)+,a0
		rts

; The following table defines the value of individual digits.

.CharTable	dc.b		1,'0'
		dc.b		2,'1'
		dc.b		3,'2'
		dc.b		4,'3'
		dc.b		5,'4'
		dc.b		6,'5'
		dc.b		7,'6'
		dc.b		8,'7'
		dc.b		9,'8'
		dc.b		10,'9'
		dc.b		11,'A'
		dc.b		12,'B'
		dc.b		13,'C'
		dc.b		14,'D'
		dc.b		15,'E'
		dc.b		16,'F'
		dc.b		11,'a'
		dc.b		12,'b'
		dc.b		13,'c'
		dc.b		14,'d'
		dc.b		15,'e'
		dc.b		16,'f'
		dc.b		0,0		end of table

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

PortName	dc.b		'MMPaint',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'This is only a skeleton routine written for:'
		dc.b		$0a
		dc.b		'       ACC discs Intuition Tutorials!'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

MyWindow:
    DC.W    56,12,462,167
    DC.B    0,1
    DC.L    CLOSEWINDOW
    DC.L    WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE
    DC.L    0,0
    DC.L    MyWindow_title
    DC.L    0,0
    DC.W    150,50,640,256,WBENCHSCREEN

MyWindow_title:
    DC.B    'MMPaint v'
    REVISION
    dc.b    ' by M.Meany, '
    REVDATE
    dc.b    '.',0
    EVEN

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

		rsreset
_args		rs.l		1
_argslen	rs.l		1

win.ptr		rs.l		1
win.rp		rs.l		1
win.up		rs.l		1

WinSigMask	rs.l		1

MyPort		rs.l		1
PortSigMask	rs.l		1
Received	rs.l		1

STD_OUT		rs.l		1

VarSize		rs.b		0

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

Variables	ds.b		VarSize

		section		Skeleton,code

***** Your code goes here!!!

; Command format: MOVE x,y

DoMove		addq.l		#5,a4		a4->start of numeric data

		move.l		a4,a0
		bsr		StrToVal
		tst.l		d1
		bne.s		.GotValue
		
.Error		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra.s		.Done

.GotValue	move.l		d0,d7
		bsr		StrToVal
		tst.l		d1
		beq.s		.Error		

		move.l		d0,d1
		move.l		d7,d0
		move.l		win.rp(a5),a1
		CALLGRAF	Move

.Done		rts

; Command format: LINE x,y

DoLine		addq.l		#5,a4		a4->start of numeric data

		move.l		a4,a0
		bsr		StrToVal
		tst.l		d1
		bne.s		.GotValue
		
.Error		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra.s		.Done

.GotValue	move.l		d0,d7
		bsr		StrToVal
		tst.l		d1
		beq.s		.Error		

		move.l		d0,d1
		move.l		d7,d0
		move.l		win.rp(a5),a1
		CALLGRAF	Draw

.Done		rts

; Command format: PLOT x,y

DoPlot		addq.l		#5,a4		a4->start of numeric data

		move.l		a4,a0
		bsr		StrToVal
		tst.l		d1
		bne.s		.GotValue
		
.Error		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra.s		.Done

.GotValue	move.l		d0,d7
		bsr		StrToVal
		tst.l		d1
		beq.s		.Error		

		move.l		d0,d1
		move.l		d7,d0
		move.l		win.rp(a5),a1
		CALLGRAF	WritePixel

.Done		rts


; Command format: PEN0 n

DoPen0		addq.l		#5,a4		a4->start of numeric data

		move.l		a4,a0
		bsr		StrToVal
		tst.l		d1
		bne.s		.GotValue
		
		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra.s		.Done

.GotValue	move.l		win.rp(a5),a1
		CALLGRAF	SetAPen

.Done		rts


; Command format: PEN1 n

DoPen1		addq.l		#5,a4		a4->start of numeric data

		move.l		a4,a0
		bsr		StrToVal
		tst.l		d1
		bne.s		.GotValue
		
		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra.s		.Done

.GotValue	move.l		win.rp(a5),a1
		CALLGRAF	SetBPen

.Done		rts






