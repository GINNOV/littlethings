; AUTHOR	: Dave Shaw -- Fixed by M.Meany, Dec 91.
; LANGUAGE	: 68000 Assembler.
; HARDWARE	: 1Mb & 2 Drive Amiga.
; DESCRIPTION 	: Requester example.
; CODE SIZE	:approx 900 bytes
; VERSION	: Vr 0.1
; DATE		: 14-DEC-1991
; Version	: v0.2  working!
; Date		: Dec 91
; TAB SETTING	: 8

; Dave, the original program did not work because:

; 1/ Requester structure incorrectly declared.
; 2/ The program was expecting and acting on a non-exsistent return from
;    Request(). The function does not set a return, I suspect some
;    confusion with AutoRequest() which returns True or False.
; 3/ IntuiMessage im_Code field is WORD size, in the Event_loop your code
;    was reading LONG WORD.
; 4/ The code for ESC is $45, not $5 .

; Notes.

; 1/ When a requester opens, all IDCMP messages to your window get frozen.
;    This can be disabled by setting the NOISEYREQ flag if you need to.

; 2/ Messages can arrive from gadgets in the requester, so as soon as a
;requester has opened start waiting for it's messages. You can now treat
;the requester as if it were your main input window.

; 3/ If none of your gadgets have the ENDGADGET flag set, you will have to
;    close the gadget by calling EndRequest(), see below as this is what
;    I've done.

; 4/ You are not limited to just BOOLEAN gadgets in a requester.

 


;		opt c-

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
		move.w		im_Code(a1),d3	******** code is WORD sized
		move.l		im_IAddress(a1),a2
		CALLEXEC	ReplyMsg		answer o/s or it will cry
Problem		cmp.l		#CLOSEWINDOW,d2		window closed 
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

		***********************************
		************ Changes **************
		***********************************

; According to my manual, $45 is the code for ESC. Not also that the
;im_Code field is only word sized. You had specified long word in your
;original Event_loop.

keys	
		cmpi.b		#$45,d3
		beq		Exit
		bra		Event_loop

Check_it
		lea		MyRequest,a0		a0-> pointer to req struct
		move.l		wd_ptr,a1		a1-> pointer to win struct
		CALLINT		Request			and display req
		bra		Event_loop2		and return

		**********************************
		************ Changes *************
		**********************************

; This code is meaningless to a call to Request(), I think you confused a
;call to AutoRequest() !!! Request() does not set a return value.

		tst.l		d0
		beq		Event_loop
		Bne.s		Exit

		**********************************
		************ Changes *************
		**********************************

; Added a new event loop to deal with gadget selection in the requester.
;Just because your window is deactivated, gadgets in the requester can still
;send messages. This is how Devpac2 selection requesters operate! Note that
;I have not set the ENDGADGET flag in either of the gadgets, this event loop
;keeps track of what gadget is being pressed and acts accordingly.

Event_loop2
		move.l		wd_ptr,a0
		move.l		wd_UserPort(a0),a0	a0-> holds address of userport
		move.l		a0,Uport		save wd_userport
	
		move.l		a0,-(sp)		save port
		CALLEXEC	WaitPort		wait for something to happen
		move.l		(sp)+,a0		get port
		CALLEXEC	GetMsg			any messages
		tst.l		d0			was there any
		beq.s		Event_loop2		if not loop
		move.l		d0,a1			a1-> holds message
		move.l		im_Class(a1),d2		d2= IDCMP
		move.l		im_IAddress(a1),a2
		CALLEXEC	ReplyMsg		answer o/s or it will cry
		cmp.l		#GADGETUP,d2		gadget
		bne.s		Event_loop2		nope, so loop!

; Since a gadgetup message will only arrive when requester is present it is
;(fairly) safe to assume the user has made his/her choice. Quash the
;requester!

		lea		MyRequest,a0		a0-> pointer to req struct
		move.l		wd_ptr,a1		a1-> pointer to win struct
		CALLINT		EndRequest			and display req

; Now see what action to take ( I modified gg_GadgetID fields ).

		cmpi.w		#1,gg_GadgetID(a2)	Yes gadget?
		beq		Exit			if so quit
		
		cmpi.w		#2,gg_GadgetID(a2)	No gadget?
		beq		Event_loop		keep waiting!
		
; If we get this far then a naff message has arrived, damn cheapo OS! Go and
;re-open the requester.

		move.l		#CLOSEWINDOW,d2		simulate event
		bra		Problem			and loop

		Section Struct's,Data

;------	Window structure.

; Added RAWKEY IDCMP flag.

mywin		dc.w		10,10			x,y start position
		dc.w		450,200			width and height
		dc.b		0,1			detail and block pens
		dc.l		RAWKEY+CLOSEWINDOW+GADGETUP	idcmp flags
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
		dc.b	'Requester Example Fixed By M.Meany',0
		even

;------	The text structure.

WinText	
		dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
		dc.w		0,0			position of text
		dc.l		NULL			default font
		dc.l		.Itext			the text
		dc.l		NULL			Next text struct null if last
		
.Itext		dc.b		'Click close gadget or press ESC to quit.',0		text to be displayed
		even

		**********************************
		************ Changes *************
		**********************************

; Corrected entries in your requester structure, ie pad fields. Also spaced
;the buttons out a little, they were overlapping!

;------	This is the requester structure with Gadgetlist for two gadgets
;	and alternative border vectors.

MyRequest
		dc.l		NULL			OlderRequester
		dc.w		10,10			Container relative to window
		dc.w		250,70			requester width and height
		dc.w		NULL			relleft
		dc.w		NULL			reltop
		dc.l		GList			Gadget to be rendered
		dc.l		RBorder			Borders to be rendered
		dc.l		Rtext			The text for requester
		dc.w		0			Continue with IDCMP
		dc.b		3			Backfill
		dc.b		NULL			Kludgefill00
		dc.l		NULL			reqlayer
		ds.b		32			reqpad1 ( 32 bytes )
		dc.l		NULL			Custom bitmap
		dc.l		NULL			reqwindow
		ds.b		32			reqpad2 ( 32 bytes )
		even	

Rtext
		dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
		dc.w		10,10			position of text
		dc.l		NULL			default font
		dc.l		.Itext			the text
		dc.l		NULL			Next text struct null if last
		
.Itext		dc.b		'QUIT, are you mad?',0		text to be displayed
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
		dc.w		GADGHCOMP		gadget flags
		dc.w		RELVERIFY		activation flags
		dc.w		BOOLGADGET+REQGADGET	gadget type flags
		dc.l		NULL			gadget border or image to be rendered
		dc.l		NULL			alt image to be rendered
		dc.l		.IText			first intuitext struct
		dc.l		NULL			gadget mutual-exclude long word
		dc.l		NULL			specialinfo struct
		dc.w		1			Gadget ID
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
		dc.w		150,30			xy of hit box relt to win topleft
		dc.w		50,10			hit box width and height
		dc.w		GADGHCOMP		gadget flags
		dc.w		RELVERIFY		activation flags
		dc.w		BOOLGADGET+REQGADGET	gadget type flags
		dc.l		NULL			gadget border or image to be rendered
		dc.l		NULL			alt image to be rendered
		dc.l		.IText			first intuitext struct
		dc.l		NULL			gadget mutual-exclude long word
		dc.l		NULL			specialinfo struct
		dc.w		2			Gadget ID
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

