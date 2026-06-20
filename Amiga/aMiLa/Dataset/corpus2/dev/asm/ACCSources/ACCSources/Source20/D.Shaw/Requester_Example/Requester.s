; AUTHOR	: Dave Shaw.
; LANGUAGE	: 68000 Assembler.
; HARDWARE	: 1Mb & 2 Drive Amiga.
; DESCRIPTION 	: Requester example.
; CODE SIZE	:
; VERSION	: Vr 0.1
; DATE		: 14-DEC-1991
; TAB SETTING	: 8

; NOTE: This code will GURU if assembled and run!!!! See fixed example.

		opt c-

;------	First get the include's for the program.

		Incdir		sys:include/
		Include		exec/exec_lib.i
		Include		exec/exec.i
		Include		intuition/intuition_lib.i
		Include		intuition/intuition.i
		
;------	Define equ's for program.

NULL	equ	0
LeftM	equ	$Bfe001

;------	Add easystart.i just in case.

		Include		Misc/easystart.i

;------	Steve Marshall's Callsys macro added

CALLSYS	MACRO		
        IFGT      NARG-1
        FAIL      !!!
        ENDC
        JSR       _LVO\1(A6)
        ENDM		

;------	Open intuition library.
	
main
		lea		Intname,a1		a1-> intuition name
		moveq.l		#0,d0			d0= any version
		CALLEXEC	OpenLibrary		and open int
		move.l		d0,_IntuitionBase	save pointer
		beq.s		.error			are we open
		
		bra.s		openwin			
		
.error		rts

;------	Open the main window.

openwin
		lea		mywin,a0		a0-> window struct
		CALLINT		OpenWindow		open the window
		move.l		d0,wd_ptr		save pointer
		beq.s		.error			did it open
		
		bsr.s		printmsg		some text	
		bra.s		Event_loop		
		
.error		
		move.l		_IntuitionBase,a1	a1-> pointer to base
		CALLEXEC	CloseLibrary		close intuition
		rts
		
;------	Print a message in the window.

printmsg
		lea		WinText,a1		a1-> pointer to text struct
		move.l		wd_ptr,a0		a0-> window pointer
		move.l		wd_RPort(a0),a0		a0-> window rastport
		move.l		a0,Rport		save rport to var
		moveq.l		#20,d0			d0= x pos of text
		moveq.l		#20,d1			d1= y pos of text
		CALLINT		PrintIText		print the text
		rts		
		
;------	This waits for user action.

Event_loop
		move.l		wd_ptr,a0
		move.l		wd_UserPort(a0),a0	a0-> holds address of userport
		move.l		a0,Uport		save wd_userport
	
		move.l		a0,-(sp)		save port
		CALLEXEC	WaitPort		wait for something to happen
		move.l		(sp)+,a0		get port
		CALLEXEC	GetMsg			any messages
		tst.l		d0			was there any
		beq.s		Event_loop		if not loop
		move.l		d0,a1			a1-> holds message
		move.l		im_Class(a1),d2		d2= IDCMP
		move.l		im_Code(a1),d3
		move.l		im_IAddress(a1),a2
		CALLEXEC	ReplyMsg		answer o/s or it will cry
		cmp.l		#CLOSEWINDOW,d2		window closed 
		beq.s		Check_it		yes let's go
		cmp.l		#RAWKEY,d2
		beq.s		keys
		bra.s		Event_loop		loop
		
Exit
		move.l		wd_ptr,a0		a0-> pointer to window
		CALLINT		CloseWindow		close my window
		
		move.l		_IntuitionBase,a1	a1-> base pointer
		CALLEXEC	CloseLibrary		close intuition
		rts					back to cli

keys	
		cmpi.b		#$5f,d3
		beq		exit
		bra		Event_loop

Check_it
		lea		request,a0		a0-> pointer to req struct
		move.l		wd_ptr,a1		a1-> pointer to win struct
		CALLINT		Request			and display req
		tst.l		d0
		beq		Event_loop
		Bne.s		exit

		Section Struct's,Data

;------	Window structure.

mywin		dc.w		10,10			x,y start position
		dc.w		450,200			width and height
		dc.b		0,1			detail and block pens
		dc.l		CLOSEWINDOW		idcmp flags
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH+SMART_REFRESH
		dc.l		NULL			first gadget in list
		dc.l		NULL			custom CHECKMARK imagary
		dc.l		.title			window title name
		dc.l		NULL			custom screen pointer
		dc.l		NULL			custom bitmap
		dc.w		5,5			min size
		dc.w		500,300			max size
		dc.w		WBENCHSCREEN		dest screen type
.title
		dc.b	'Requester Example By Davie Shaw',0
		even

;------	The text structure.

wintext	
		dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
		dc.w		0,0			position of text
		dc.l		NULL			default font
		dc.l		.Itext			the text
		dc.l		NULL			Next text struct null if last
		
.Itext		dc.b		'To activate requester click close gadget or esc to quit',0		text to be displayed
		even

;------	This is the requester structure with Gadgetlist for two gadgets
;	and alternative border vectors.

Request
		dc.l		NULL			OlderRequester
		dc.w		10,10			Container relative to window
		dc.w		250,70			requester width and height
		dc.w		NULL			relleft,reltop
		dc.l		GList			Gadget to be rendered
		dc.l		Rborder			Borders to be rendered
		dc.l		Rtext			The text for requester
		dc.w		NULL			requester flags
		dc.b		3			Backfill
		dc.b		NULL			Kludgefill00
		dc.l		NULL			reqlayer
		dc.b		NULL			reqpad1
		dc.l		NULL			Custom bitmap
		dc.l		NULL			reqwindow
		dc.b		NULL			reqpad2
		even	

Rtext
		dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
		dc.w		10,10			position of text
		dc.l		NULL			default font
		dc.l		.Itext			the text
		dc.l		NULL			Next text struct null if last
		
.Itext		dc.b		'Test Text',0		text to be displayed
		even

;------	Border to enclose requester.

RBorder
		dc.w		-1,-1			xy origin relative to container topleft
		dc.b		1,0,RP_JAM2		front pen,back pen and draw mode
		dc.b		5			number of xy vectors
		dc.l		.BorderVectors		ptr to xy vectors
		dc.l		NULL			next border in list
.BorderVectors
		dc.w		0,0
		dc.w		0,250			x,y pos lines
		dc.w		250,70
		dc.w		0,70
		dc.w		0,0

;------	The gadgetlist for requester.

GList
Gadg1		dc.l		Gadg2			next gadget
		dc.w		10,30			xy of hit box relt to win topleft
		dc.w		50,10			hit box width and height
		dc.w		GADGHBOX		gadget flags
		dc.w		RELVERIFY+ENDGADGET	activation flags
		dc.w		BOOLGADGET+REQGADGET	gadget type flags
		dc.l		NULL			gadget border or image to be rendered
		dc.l		NULL			alt image to be rendered
		dc.l		.IText			first intuitext struct
		dc.l		NULL			gadget mutual-exclude long word
		dc.l		NULL			specialinfo struct
		dc.w		NULL			user-definable data
		dc.l		NULL			ptr to user-definable data

.IText
		dc.b		1,0,RP_JAM2,0		front and back text pen,drawmode and fill byte
		dc.w		1,1			xy origin relative to container topleft
		dc.l		NULL			font ptr or null for default
		dc.l		.ITextText		ptr to text
		dc.l		NULL			next intuitext struct
.ITextText
		dc.b		'YES',0
		even

;------	Gadget No.2 for requester.

Gadg2		dc.l		NULL			next gadget
		dc.w		50,30			xy of hit box relt to win topleft
		dc.w		50,10			hit box width and height
		dc.w		GADGHBOX		gadget flags
		dc.w		RELVERIFY		activation flags
		dc.w		BOOLGADGET+REQGADGET	gadget type flags
		dc.l		NULL			gadget border or image to be rendered
		dc.l		NULL			alt image to be rendered
		dc.l		.IText			first intuitext struct
		dc.l		NULL			gadget mutual-exclude long word
		dc.l		NULL			specialinfo struct
		dc.w		NULL			user-definable data
		dc.l		NULL			ptr to user-definable data

.IText
		dc.b		1,0,RP_JAM2,0		front and back text pen,drawmode and fill byte
		dc.w		1,1			xy origin relative to container topleft
		dc.l		NULL			font ptr or null for default
		dc.l		.ITextText		ptr to text
		dc.l		NULL			next intuitext struct
.ITextText
		dc.b		'NO',0
		even
		
	
;------	Vars section.

Intname			INTNAME
		even
_IntuitionBase	ds.l	1
wd_ptr		ds.l	1
Uport		ds.l	1
Rport		ds.l	1
		end

