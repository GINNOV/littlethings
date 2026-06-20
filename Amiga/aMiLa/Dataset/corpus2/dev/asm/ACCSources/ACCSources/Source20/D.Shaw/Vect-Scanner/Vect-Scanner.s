							;Dave Shaw
							;15 Kirkton ave,
							;Flat 7/1,
							;Knightswood,
							;Glasgow,
							;G13 3SE
							;041-954-4493

; AUTHOR	: Dave Shaw.
; LANGUAGE	: 68000 Assembler.
; HARDWARE	: 1Mb & 2 Drive Amiga.
; PROGRAM	: Vector Checker.
; VERSION	: Vr 0.1
; DATE		: 27-DEC-1991
; TAB		: 8
	
							
;-----------added easystart.i for workbench startup
;	    but have not tested it yet.
	

; Arrrgggg, I hate code that must have the c- flag set to assemble. MM

		opt	c-,d+			

		Incdir	"SYS:include/"
		include	"exec/exec_lib.i"
		include	"exec/exec.i"
		include "exec/execbase.i"
		include	"intuition/intuition_lib.i"
		include	"intuition/intuition.i"
		include	"libraries/dos_lib.i"
		include	"libraries/dos.i"
		include	"libraries/dosextens.i"
		include	"Graphics/Graphics_lib.i
		include	"misc/easystart.i"
	
;-----------Some equ for the program.

Null		equ	0			;makes for easy reading
Mouse		equ	$bfe001			Left
Mouse2		equ	$dff016			Right

;-----------Added Steve Marshalls Macro call to speed up CALLINT etc

CALLSYS	MACRO		
        IFGT      NARG-1
        FAIL      !!!
        ENDC
        JSR       _LVO\1(A6)
        ENDM		


;-----------Program starts here.

	bsr.s	openint
	beq.s	error1
	bsr.s	opendos
	beq.s	error2
	bsr.s	opengraf
	beq.s	error3
	bsr.s	Mem_needed
	bra	Openwin
	
	
;-----------Open the intuition library and store base ptr.


openint		
	lea		intname,a1		;library name a1
	moveq.l		#0,d0			;any version
	CALLEXEC	OpenLibrary		;and open
	move.l		d0,_IntuitionBase	;store pointer
	rts
		

;------------Open dos library and store base pointer


opendos	
	lea		dosname,a1	
	moveq.l		#0,d0			;any version
	CALLEXEC	OpenLibrary
	move.l		d0,_DOSBase		;save pointer
	rts
	
;-----------Open graphics library.

Opengraf
	lea		Gfxname,a1
	moveq.l		#0,d0
	CALLEXEC	OpenLibrary
	Move.l		d0,_GfxBase
	rts
	
;-----------Allocate vars_mem.

Mem_needed
	move.l		#vars_sizeof,d0		d0=size 
	move.l		#MEMF_PUBLIC,d1		d1=Memtype
	CALLEXEC	AllocMem		get mem
	move.l		d0,d6			save address
	beq		error3			leave if not there
	
	move.l		d0,a4			else save ptr->a4
	rts

;-----------Error routine here

	
error3	bsr		closedos
error2	bsr		intclose
error1	rts	

;-----------Exit from here

exit
	move.l		window_ptr(a4),a0		;window ptr
	CALLINT		CloseWindow
	
;-----------Free the memory for the vars before exiting.
	
	move.l		d6,a1				pointer to vars mem
	move.l		#vars_sizeof,d0			size of block
	CALLEXEC	FreeMem				and release it
		
closelib		
	bsr.s		intclose
	bsr.s		closedos
	bra		closegraf
	
;-----------Close libraries

intclose	
	move.l		_IntuitionBase,a1	;close intuition
	CALLEXEC	CloseLibrary
	rts
	
closedos	
	move.l		_DOSBase,a1		;close dos
	CALLEXEC	CloseLibrary
	rts
	
Closegraf
	move.l		_GfxBase,a1
	CALLEXEC	CloseLibrary
	rts
	
;----------Open the main window.

Openwin
	lea		Vect_Window,a0		a0->Window struct
	CALLINT		OpenWindow		open the window
	move.l		d0,window_ptr(a4)	save window pointer
	beq		error3			not opened the exit
	
	move.l		d0,a0			a0->window address
	move.l		wd_RPort(a0),Window_rp(a4)	save window rastport
	move.l		wd_UserPort(a0),Window_up(a4)	save window userport

	move.l		#12,Scr_XOffset(a4)
	move.l		#17,Scr_YOffset(a4)
	
	move.l		#336,Scr_width(a4)
	move.l		#132,Scr_height(a4)
	move.l		#99,UpDisp_flag		to print output on first scan

;-----------Two gadgets have to be disabled at the start
;	    the reset gadget and the clear vectors gadget
;	    incase they are selected by accident.

	lea		gadg1,a0		a0->gadg to disable
	bsr		remgadg			go do it
	
	lea		gadg2,a0		a0->gadg to disable
	bsr		remgadg			go do it
	
;----------Display window border.

Win_border
	lea		Frame,a1		a1->Border Def's
	move.l		window_rp(a4),a0	a0->window rastport
	moveq.l		#0,d0			no offsets
	move.l		d0,d1			no offsets
	CALLINT		DrawBorder		and draw it
		
;----------Event loop.

Event_loop
	move.l		window_up(a4),a0	get userport
	move.l		a0,-(sp)		save port to stack
	CALLEXEC	WaitPort		wait for an event
	move.l		(sp)+,a0		get port back
	CALLEXEC	GetMsg			any messages
	tst.l		d0			was there any
	beq.s		Event_loop		if not loop
	move.l		d0,a1			a1 holds message
	move.l		im_Class(a1),d2		d2 holds IDCMP
	move.l		im_IAddress(a1),a2	a2->address
	CALLEXEC	ReplyMsg		answer o/s 
	cmp.l		#CLOSEWINDOW,d2		was it windowclose
	beq		exit			yes then quit
	cmp.l		#GADGETUP,d2		was it a gadget
	beq		do_gadget		if yes go do it
	bra.s		Event_loop		no then loop
	
;----------Find out which gadget was selected.

do_gadget
	move.l		gg_UserData(a2),a0	get the data
	cmpa.l		#0,a0			assigned
	beq		Event_loop		no them loop
	
	jmp		(a0)			yes them do it
	
;----------This is the subroutine to disable gadgets
;entry	   a0 should hold address of gadget to remove

RemGadg
	move.l		window_ptr(a4),a1	a1->window pointer
	move.l		#0,a2			a2->zero not a requester
	CALLINT		OffGadget		Disable gadget
	rts
	
;----------This routine re-enables the gadgets that
;	   have been removed as in the remove routine
;entry	   a0 should hold address of gadget to add

Addgadg
	move.l		window_ptr(a4),a1	a1->window pointer
	move.l		#0,a2			a2->zero not a req
	CALLINT		OnGadget		Enable gadget
	rts
	
;--------- Routine to refresh gadgets

Refgadg
	lea		gadgets,a0		a0->gadgetlist
	move.l		window_ptr(a4),a1	a1->window pointer
	move.l		#0,a2			a2->zero not a req
	CALLINT		RefreshGadgets
	rts
	
;----------This routine prints out Itext messages
;
;Entry	   a1 should hold the address of message to be printed.

PrintText
	move.l		window_rp(a4),a0	get window ptr	
	moveq.l		#0,d0			no offsets
	move.l		d0,d1			no offsets
	CALLINT		PrintIText		and print it
	rts
	
;--------- Display an alert if a vector is non-zero.

Warn
	move.l		#$0,d0			Alert type
	move.l		#105,d1			Height
	lea		alert_text,a0		a0->alert text
	CALLINT		DisplayAlert		Display it
	tst.l		d0			right button pressed
	beq		Event_loop		yes stop scanning
	
;-------- If we get to here after the alert enable gadgets is required.

	lea		gadg1,a0		a0->gadget to enable
	bsr		addgadg
	
	lea		gadg2,a0
	bsr		addgadg
	bsr		Refgadg			refresh gadgets
	
	bra		Event_loop		loop
			
;---------This routine takes a value and converts it to ascii
;	  for output to window.
;Entry	  a3->text Buffer
;	  d0= Number to format
;
;Exit	  Text buffer should hold hex formatted number for
;	  output using Itext structure

Format
	lea		Template,a0		a0->Template for output
	lea		Datastream,a1		a1->Number
	lea		PutChar,a2		a2->routine to put char in buffer
	CALLEXEC	RawDoFmt		Format number
	
	moveq.l		#1,d0
	
.error	rts

PutChar	
	move.b		d0,(a3)+		Move char into buffer
	rts

;---------Set pen to background colour.

Clrscr
	move.l		window_rp(a4),a1	a1->rastport
	moveq.l		#0,d0			d0=background colour
	CALLGRAF	SetAPen			and set colour

;---------Draw a rectangle over window.

	move.l		window_rp(a4),a1	a1->rastport
	move.l		Scr_XOffset(a4),d0	d0=Xoffset
	move.l		Scr_YOffset(a4),d1	d1="    "
	move.l		Scr_width(a4),d2	d2=width to fill
	move.l		Scr_height(a4),d3	d3="   "   "   "
	CALLGRAF	RectFill		Fill the window
	rts
	
;----------To print the info text.

Infomsg		
	lea		infotext,a1		a1->info text
	bsr		printText		print it
wait
	btst		#6,Mouse		Left button pressed
	bne		wait			no then loop

	bsr.s		Clrscr			clear old text
		
;---------Now redraw the main text and vector text.
	
	lea		maintext,a1		yes restore main text
	bsr		printText
	
	lea		vecttext,a1		and the vectors info
	bsr		printText
	
	bra		Event_loop		loop	

;----------This is the main part of the program to
;	   get vector values store them then format them
;	   and finally output results.

Scan_Vectors
	movea.l		$4.w,a6			get execbase
	move.l		ColdCapture(a6),_ColdCapture(a4) 	Save all vectors
	move.l		CoolCapture(a6),_CoolCapture(a4)
	move.l		WarmCapture(a6),_WarmCapture(a4)
	move.l		KickTagPtr(a6),_KickTagPtr(a4)
	move.l		KickCheckSum(a6),_KickCheckSum(a4)
	move.l		KickMemPtr(a6),_KickMemPtr(a4)
	
;----------Now Format results for output to window.

	move.l		_ColdCapture(a4),Datastream	number to convert to hex
	lea		Coldtxt,a3			Text buffer
	bsr		Format				and convert it
	
	move.l		_CoolCapture(a4),Datastream	number to convert to hex
	lea		Cooltxt,a3			Text buffer
	bsr		Format				and convert it
	
	move.l		_WarmCapture(a4),Datastream	number to convert to hex
	lea		Warmtxt,a3			Text buffer
	bsr		Format				and convert it
	
	move.l		_KickTagPtr(a4),Datastream	number to convert to hex
	lea		Ktptxt,a3			Text buffer
	bsr		Format				and convert it
	
	move.l		_KickCheckSum(a4),Datastream	number to convert to hex
	lea		Kcstxt,a3			Text buffer
	bsr		Format				and convert it
	
	move.l		_KickMemPtr(a4),Datastream	number to convert to hex
	lea		Kmptxt,a3			Text buffer
	bsr		Format				and convert it
		
;--------- Set a flag to update display every 100th scan

	add.l		#1,UpDisp_flag		Add one to flag
	cmp.l		#100,UpDisp_flag	have we scanned 100 times
	beq		ReDisplay		if yes then redisplay vectors

;--------- Check if vectors are non-zero.

Check_vectors
	cmpi.l		#0,_ColdCapture(a4)	is it zero
	bne		Warn			no then warn user
	
	cmpi.l		#0,_CoolCapture(a4)	is it zero
	bne		Warn			no then warn user
	
	cmpi.l		#0,_WarmCapture(a4)	is it zero
	bne		Warn			no then warn user	
	
	cmpi.l		#0,_KickTagPtr(a4)	is it zero
	bne		Warn			no then warn user
	
	cmpi.l		#0,_KickCheckSum(a4)	is it zero
	bne		Warn			no then warn user

	cmpi.l		#0,_KickMemPtr(a4)	is it zero
	bne		Warn			no then warn user

wait2
	btst		#10,Mouse2
	bne		Scan_Vectors
		
	Bra		Event_loop
	
;--------- Clear all vectors here.

Clear_vectors
	movea.l		$4.w,a6			execbase
	clr.l		ColdCapture(a6)		Clear all vectors
	clr.l		CoolCapture(a6)	
	clr.l		WarmCapture(a6)
	clr.l		KickTagPtr(a6)
	clr.l		KickCheckSum(a6)
	clr.l		KickMemPtr(a6)
	
	cmpi.l		#5,Resetflag		are we here from reset
	beq		Reset2			yes go back
	
	lea		gadg1,a0		here from clear
	bsr		RemGadg			then remove reset
						;and clear and loop
	lea		gadg2,a0		for more
	bsr		RemGadg
	bsr		Clrscr			Clear the screen
	bra		Event_loop	
	
;----------Now output the results to the screen.

ReDisplay
	
	lea		maintext,a1
	bsr		printText
	
	lea		vecttext,a1		and the vectors info
	bsr		printText

	move.l		#0,UpDisp_flag		set counter flag to zero
	bra		Check_Vectors		branch

;--------- Time for the reset routine taken from the
;	   hardware reference manual.

Reset1
	move.l		#5,Resetflag		flag for clear vect
	bsr.s		Clear_vectors		
Reset2
	lea		ResetCode,a5
	CALLEXEC	Supervisor
	rts
	
ResetCode
	lea.l		2,a0
	reset
	jmp		(a0)
	
;----------Include the intuition stuctures here to keep
;	   the code readable and tidy.

; You don't need to specify a directory! Devpac checks the current one first

;	incdir		'df1:Vect-Scanner/'


	include		'window.i'		Window Def's
	include		'gadgets.i'		Gadget Def's
	include		'win-border.i'		Window Border Def's
	include		'info-text.i'		{	       }
	include		'main-text.i'		{ All the text } 
	include		'Vect-text.i'		{	       }
	
;--------- Put alert text here temp.


; Undocumented bug in DisplayAlert. All Texts must be an even number of bytes
;long, including the terminating 0. Failure to follow this will crash the
;system and will corrupt the display of your alert.
;			 	 01010101010101010101010101010101010101010101010101010101010101010101010101010101     
alert_text	dc.w		180
		dc.b		15
		dc.b		'>>>>>>> VECTOR SCANNER ALERT <<<<<<< ',0
		dc.b		$ff

		dc.w		10
		dc.b		25
		dc.b		'An execbase reset vector has been changed.Please check for a resident RAD: ',0
		dc.b		$ff
	
		dc.w		10
		dc.b		35
		dc.b		'If one is not installed this could be a !!! VIRUS !!!',0
		dc.b		$ff
		
		dc.w		100
		dc.b		55
		dc.b		'Press Left mouse                       Press Right mouse ',0
		dc.b		$ff
		
		dc.w		90
		dc.b		65
		dc.b		'Enable RESET & CLEAR                     To STOP Scanning',0
		dc.b		$ff
		
		dc.w		10
		dc.b		85
		dc.b		'NOTE: Selecting RESET gadget will destroy any unsaved data ',0
		dc.b		$ff
		
		dc.w		60
		dc.b		95
		dc.b		'Selecting CLEAR gadget will kill any resident RAD: ',0
		dc.b		$00
		even

;----------The vars for libs etc.

dosname	 	dc.b	'dos.library',0
		even
intname	 	dc.b	'intuition.library',0
		even
Gfxname		dc.b	'graphics.library',0
		even
Template	dc.b	' %lx',0

		section  vars,bss
		
_DOSBase	ds.l	1
_IntuitionBase  ds.l	1
_GfxBase	ds.l	1
Datastream	ds.l	1
Resetflag	ds.l	1
UpDisp_Flag	ds.l	1
Coldtxt		ds.b	100
Cooltxt		ds.b	100
Warmtxt		ds.b	100
Ktptxt		ds.b	100
Kcstxt		ds.b	100
Kmptxt		ds.b	100
		even

;----------Block of vars allocated to mem.
	
	rsreset

Window_ptr	rs.l	1
Window_up	rs.l	1
Window_rp	rs.l	1
_Coldcapture	rs.l	1
_Coolcapture	rs.l	1
_Warmcapture	rs.l	1
_Kicktagptr	rs.l	1
_Kickchecksum	rs.l	1
_Kickmemptr	rs.l	1
Scr_height	rs.l	1
Scr_Width	rs.l	1
Scr_XOffset	rs.l	1
Scr_YOffset	rs.l	1

Vars_Sizeof	rs.l	0	

	end
