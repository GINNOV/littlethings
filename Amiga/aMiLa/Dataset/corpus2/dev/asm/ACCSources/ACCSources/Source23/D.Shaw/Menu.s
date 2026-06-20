							;Dave Shaw
							;15 Kirkton ave,
							;Flat 7/1,
							;Knightswood,
							;Glasgow,
							;G13 3SE
							;041-954-4493

; AUTHOR	: Dave Shaw.
; LANGUAGE	: 68000 Assembler.
; HARDWARE	: 1Mb & 2 Drive Amiga v2.04.
; PROGRAM	: Menu Selector.
; VERSION	: Vr 1.3b/2
; DATE		: 21-NOV-1991
; TAB		: 8

; Tried & Tested on v2.04 Amiga OS. M.Meany.


;------ Suggestion! Place all selections in a certain directory.
;	The directory MUST be the first entry in the script.
;	On running, CD this directory.
;	This will save having to put all selections in same dir as
;	selector program, allowing one script per directory on the
;	disk .... ie you could seperate the selections into
;	catagories and have a different script for each.

;	When you add ability to read a new script into program this
;	will save loads of time!

;	Also open the window on a custom screen with all the gadgets
;	being drawn over a suitable backdrop. This would look great!
	
;------	22-NOV-1991
;	Added status text and other info to the window,also re-positioned
;	the gadgets and added another coloum this menu now has room to
;	execute 56 programs from it.

;------ 3-JAN-1992
;	Finally got round to re-writing the loader,been up all night
;	improving and testing,as they say (Practice makes nearly
;	perfect)

;------ 4-JAN-1992
;	Adding script file handling,just text to display,and the
;	command line sequence to start with but there will not
;	be support for sub-menus as yet maybe in the next version.
							
;------ 17th Feb 1992, M.Meany
;	Alterd script parsing so gadget can have a proper title and command
;	line to be executed upon selection. Ensured pointer to command
;	line is stored in appropriate gadget so execution will take place.
;	Corrected bug in Print_it subroutine. Was positioning text according
;	to length of script entry.
;	Corrected 'Illegal Address' bug in Function subroutine, code was
;	testing a long word in the text file which could lie on an odd
;	address.
;	Completely re-wrote Find_line_length subroutine to accomodate above
;	alterations.
;	Have not added check for end of gadget list -- Don't load files with
;	more than 56 entries in or funny resets may occur!
;	Added parsing to allow comment lines to be added to script.
;	Shaved some 5080 bytes off by trimming here and there.
;	Passing CLI handle to all child processes for output.
;	Live fast, code hard and die in a beautiful way:-)

;------ 19th Mar 1992
;	Added new requester,the old one was a autorequester.

;-------------- Run from cli only.
	
	opt	o+,ow-			

	Incdir		"sys:include/"
	include		"exec/exec_lib.i"
	include		"exec/exec.i"
	include		"intuition/intuition_lib.i"
	include		"intuition/intuition.i"
	include		"libraries/dos_lib.i"
	include		"libraries/dos.i"
	include		"libraries/dosextens.i"
	
;-------------- Only one equ for a zero.

Null	equ	0			;makes for easy reading

;-------------- Added Steve Marshalls Macro call to speed up CALLINT etc

CALLSYS	MACRO		
        IFGT      NARG-1
        FAIL      !!!
        ENDC
        JSR       _LVO\1(A6)
        ENDM		


;-------------- Well here we go, let's do it.

		bsr.s	openlibs
		
		bsr.s	Init
		
		bsr	openwin

		bsr	Graphics
				
		bsr	script
		
		bra	wait_for_msg
	
	
;-------------- Open the intuition library and store base ptr.


openlibs		
	lea		intname,a1		;library name a1
	moveq.l		#0,d0			;any version
	CALLEXEC	OpenLibrary		;and open
	move.l		d0,_IntuitionBase	;store pointer
	beq		error1
			
	lea		dosname,a1	
	moveq.l		#0,d0			;any version
	CALLEXEC	OpenLibrary
	move.l		d0,_DOSBase		;save pointer
	beq		error2
	CALLDOS		Output			get CLI handle
	move.l		d0,CLI_OUT		save it
	rts
	
;-------------- Allocate some memory for vars.

Init
	move.l		#Vars_Sizeof,d0		d0=size required
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	d1=Memtype required
	CALLEXEC	AllocMem		and get it
	move.l		d0,d6			save address
	beq		error3			leave if not allocated	
	move.l		d0,varptr		save addr
	move.l		d0,a4			else a4->var area
	
;-------------- Open the initial script file for reading.

Dofile	
	lea		Filename,a0	    	a0->filename
	bsr		FileLen			get size of file
	move.l		d0,File_len(a4)		save length
	bne.s		Filemem
	
	bra		error4
	
;-------------- Allocate some memory for the file to be read into.
;		d0 already holds length of the file

Filemem
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALLEXEC	AllocMem		ask for mem
	move.l		d0,Filebuff(a4)		save mem addr
	bne.s		Openfile
	
	bra		error4
	
;-------------- Open file for reading.

Openfile
	move.l		#Filename,d1		d1=addr of filename
	move.l		#MODE_OLDFILE,d2	d2=access mode
	CALLDOS		Open			open the file
	move.l		d0,Filehd		save handle
	bne.s		Readfile
	
	bra		error5
	
;-------------- Read the file into the buffer and then close it.

Readfile	
	move.l		Filehd,d1		d1=file handle
	move.l		Filebuff(a4),d2		d2=buffer
	move.l		File_len(a4),d3	   	d3=size of file
	CALLDOS		Read			read data from file
	
;-------------- Close the file.

	move.l		Filehd,d1		d1=file handle
	CALLDOS		Close			close the file
	rts

;-------------- Open the main window with attached gadgets.

openwin	
	lea		mainwindow,a0		;window struct
	CALLINT		OpenWindow		;open the window
	move.l		d0,Window.ptr(a4)	;save window pointer
	beq		error4
	
	move.l		d0,a0			a0->window address
	move.l		wd_RPort(a0),Window.rp(a4)	
	move.l		wd_UserPort(a0),Window.up(a4)
	

;-------------- Routine taken from M.M examples on intuition

ok	
	moveq.l		#MEMF_CHIP,d1		type of mem
	CALLEXEC	AvailMem		how much is free?
	move.l		d0,d7			store free chip

	moveq.l		#MEMF_FAST,d1		type of mem
	CALLEXEC	AvailMem		how much is free?
	add.l		d7,d0			add free chip to this

	move.l		d0,DataStream		and store value
		
	lea		Template,a0		format string
	lea		DataStream,a1		data
	lea		PutChar,a2		subroutine
	lea		Text,a3			buffer
	CALLEXEC	RawDoFmt		create text string

	moveq.l		#1,d0			no errors

.error	rts

PutChar	
	move.b		d0,(a3)+		save next character
	rts					and return

;-------------- Routine to attach logo graphics to main window

Graphics
	move.l		Window.rp(a4),a0
	lea		redlogo,a1
	moveq.l		#80,d0
	moveq.l		#20,d1
	CALLINT		DrawImage
	
	lea		WinText,a1
	move.l		Window.rp(a4),a0
	moveq.l		#0,d0
	move.l		d0,d1
	CALLINT		PrintIText
	rts

;-------------- This part is to read in a script file with 
;	 	the program names and command sequences,I hope

script	
	move.l		#Gadg1,NextGadg(a4)	init 1st gadg to set
	move.l		Filebuff(a4),a5		a5->buffer
	move.l		a5,-(sp)		save addr
	moveq.l		#0,d4
	lea		Gadget.txt(a4),a3	
	move.b		#RP_JAM2,it_DrawMode(a3)
	add.w		#15,it_LeftEdge(a3)
	add.w		#37,it_TopEdge(a3)
	
loopy	
	cmpi.b		#';',(a5)		comment line?
	bne.s		.DoColours		skip if not
.FindE	cmpi.b		#$0a,(a5)+		else move to next line
	bne.s		.FindE
	bra.s		loopy			and try again!
	
.DoColours
	cmpi.b		#'1',(a5)		control char
	beq.s		White
	cmpi.b		#'2',(a5)
	beq.s		Black
	cmpi.b		#'3',(a5)
	beq.s		Red
	move.l		(sp)+,a5
	move.l		a5,Filebuff(a4)
	rts
	
;-------------- This part prints all header text lines.

White	
	move.b		#0,(a5)+		clear ctrl char
	move.b		#1,it_FrontPen(a3)	make white text
	move.l		#temp_buff,a1
	bsr		Find_line_length
	
	move.l		a1,it_IText(a3)
	cmpi.l		#0,d4
	bne.s		IncrTop	
	bsr		Print_it

	bra.s		loopy


;-------------- This part prints black header text lines.

Black	
	move.b		#0,(a5)+		clear ctrl char
	move.b		#2,it_FrontPen(a3)	make white text
	move.l		#temp_buff,a1
	bsr.s		Find_line_length

	move.l		a1,it_IText(a3)
	cmpi.l		#0,d4
	bne.s		IncrTop	
	bsr		Print_it

	bra		loopy


;-------------- This part prints red header text lines.

Red	
	move.b		#0,(a5)+		clear ctrl char
	move.b		#3,it_FrontPen(a3)	make white text
	move.l		#temp_buff,a1
	bsr		Find_line_length

	move.l		a1,it_IText(a3)
	cmpi.l		#0,d4
	bne		IncrTop
		
	bsr		Print_it

	bra		loopy
	
	
;-------------- To increment topedge if this is not the first gadgets text.

IncrTop	
	add.w		#12,it_TopEdge(a3)
	cmpi.l		#14,d4
	beq		IncrLeft
	
	bsr		Print_it
	bra		loopy
	
;-------------- Gadgets text in first coloum printed start in next coloum.

IncrLeft	
	add.w		#155,it_LeftEdge(a3)
	move.w		#37,it_TopEdge(a3)
	move.l		#0,d4
	bsr		Print_it
	bra		loopy
	
;-------------- Build next gadget text & correct command line buffer

; This is my version of the above rotuine. More efficient and allows a
;command line parameter list to be passed as part of script entry. Also
;activates a new gadget for each line processed:-)

;Does not check that there is a gadget to activate, so could corrupt
;memory address $00000000 if more than 56 lines of text in the file:-(

; Could be optimised further, but unsure what registers are safe to scratch!

; M.Meany, Feb 92.

Find_line_length	
	move.l		NextGadg(a4),a0		get gadg to install
	move.l		a5,gg_UserData(a0) 	set pointer
	move.l		gg_NextGadget(a0),NextGadg(a4)
			
.loop	move.b		(a5)+,d0		get next char
	cmpi.b		#'>',d0			delimiter ?
	bne.s		.NotDelim		skip if not
	move.b		#$0a,d0			simulate EOL
	move.l		a5,gg_UserData(a0) 	replace with this

; Since a parameter list has been supplied, we must skip buffer pointer to
;end of line before continuing!

.loopy			
	cmp.b		(a5)+,d0		there yet?
	bne.s		.loopy			no, so keep going

; Whenever we get hear, a5 will be pointing to start of next line!

.NotDelim		
	move.b		d0,(a1)+		copy char
	cmp.b		#$0a,d0			was it an EOL ?
	bne.s		.loop			loop back if not
	move.b		#0,-1(a1)		if so Null terminate
	move.l		a5,nextline(a4)		save next line ptr
	lea		temp_buff,a1		reset pointer
	rts					and return

;-------------- Print the gadget text.

Print_it    
	lea		Gadget.txt(a4),a1
	move.l		Window.rp(a4),a0
	moveq.l		#10,d0
	move.l		d0,d1
	CALLINT		PrintIText
	addq.l		#1,d4
	rts

;-------------- This routine waits for gadget select and branches to
;		a routine which finds out which was selected

wait_for_msg
	move.l		Window.up(a4),a0	;a0 holds address of userport
	move.l		a0,-(sp)		;save port
	CALLEXEC	WaitPort		;wait for something to happen
	move.l		(sp)+,a0		;get port
	CALLEXEC	GetMsg			;any messages
	tst.l		d0			;was there any
	beq.s		wait_for_msg		;if not loop
	move.l		d0,a1			;a1 holds message
	move.l		im_Class(a1),d2		;d2 holds IDCMP
	move.l		im_IAddress(a1),a2
	CALLEXEC	ReplyMsg		;answer o/s or it will cry
Ahhh	cmp.l		#CLOSEWINDOW,d2		;window closed ?
	beq.s		Check_it		;display quit requester
	cmp.l		#GADGETUP,D2		;gadget selected ?
	beq		go_gadget		;find out which one
	bra.s		wait_for_msg		;loop

;------ Display requester.

Check_it
	lea		QuitReq,a0		a0->pointer to req 
	move.l		Window.ptr(a4),a1		a1->pointer to win
	CALLINT		Request			display req
	
;------ Event loop for new quit requester.

Quit_loop
	move.l		Window.up(a4),a0	;a0 holds address of userport
	move.l		a0,-(sp)		;save port
	CALLEXEC	WaitPort		;wait for something to happen
	move.l		(sp)+,a0		;get port
	CALLEXEC	GetMsg			;any messages
	tst.l		d0			;was there any
	beq.s		Quit_loop		;if not loop
	move.l		d0,a1			;a1 holds message
	move.l		im_Class(a1),d2		;d2 holds IDCMP
	move.l		im_IAddress(a1),a2
	CALLEXEC	ReplyMsg		;answer o/s or it will cry
	cmp.l		#GADGETUP,D2		;gadget selected ?
	bne.s		Quit_loop		;find out which one

;------ Got gadgetup message so quash requester.

	lea		QuitReq,a0		a0->pointer to req 
	move.l		Window.ptr(a4),a1	a1->pointer to win
	CALLINT		EndRequest		Close req
	
;------ Now lets see which its to be.

	cmpi.w		#1,gg_GadgetID(a2)	Quit gadget?
	beq		exit			if so quit
	
	cmpi.w		#2,gg_GadgetID(a2)	Cont gadget?
	beq		wait_for_msg		Keep waiting
	
;------ Check just incase a bogus message was sent.

	move.l		#CLOSEWINDOW,d2		simulate event
	bra		Ahhh
	
;-------------- Find out which gadg was selected below
;		and disable gadgets so that they are
;		not accidently selected on quiting a
;		program.

go_gadget
	move.l		gg_UserData(a2),d0	;gadget assigned
	beq		wait_for_msg		;no then wait for gadget selection
	move.l		d0,a1			a1->command line
	movem.l		a0-a2/d0-d1,-(sp)	;yes then save regs
	
	lea		Ex.txt,a1
	move.l		Window.rp(a4),a0
	moveq.l		#0,d0
	move.l		d0,d1
	CALLINT		PrintIText

	movem.l		(sp)+,a0-a2/d0-d1	;restore regs
	
	bra		Function		execute command
	

	lea		Wait,a1
	move.l		Window.rp(a4),a0
	moveq.l		#0,d0
	move.l		d0,d1
	CALLINT		PrintIText
	bra		wait_for_msg		;wait for next selection

;-------------- This is the new loader routine,ok it's not that
;		impressive but it work's just fine.
 
Function
	move.l		a1,a2			;move command a2
	cmp.b		#0,(a2)			;is it zero
	beq		wait_for_msg		;yes then quit
	movem.l		d0-d7/a0-a6,-(sp)	;save
	move.l		a1,d1			;no move command d1
	clr.l		d2			;no input window
	move.l		CLI_OUT,d3		;no output window
	CALLDOS		Execute			;Execute CLI command 
	movem.l		(sp)+,d0-d7/a0-a6	;restore
	
	lea		Wait,a1
	move.l		Window.rp(a4),a0
	moveq.l		#0,d0
	move.l		d0,d1
	CALLINT		PrintIText
	bra		wait_for_msg		;wait for next selection
	
;-------------- Error handling here

error5	bsr		FreeFileMem
error4	bsr		FreeVarMem	
error3	bsr		closedos
error2	bsr		intclose
error1	rts	

;-------------- Exit from here

exit
	move.l		Window.ptr(a4),a0	;window ptr
	CALLINT		CloseWindow
	
	bsr.s		FreeFileMem
	bsr.s		FreeVarMem		free the var mem
	bsr.s		closedos
	bra		intclose
	
;-------------- Close libraries,and free all memory.

FreeFileMem
	move.l		Filebuff(a4),a1		a1->addr of buffer
	move.l		File_len(a4),d0		d0=size allocated
	CALLEXEC	FreeMem
	rts

FreeVarMem
	move.l		varptr,a1	   	a1->vars mem
	move.l		#Vars_Sizeof,d0		d0=size to free
	CALLEXEC	FreeMem			and free it
	rts
		
closedos	
	move.l		_DOSBase,a1		;close dos
	CALLEXEC	CloseLibrary
	rts

intclose	
	move.l		_IntuitionBase,a1	;close intuition
	CALLEXEC	CloseLibrary
	rts

;-------------- Include Subroutines here.

	Include		'Sub.i'


;-------------- Include window and text defs here.

	Include		'defs.i'
	include		'QReq.i'	

	Section 	Data,Data
		
;-------------- Gadgets structures included to keep code tidy
;		gadgets all have a 2.04 OS look to them.
	
	
	include		"Menu-gadgets.i"

;-------------- Variable store

intname	dc.b		'intuition.library',0
	even
dosname	dc.b		'dos.library',0
	even
Template		dc.b	' %ld ',0
	even
Filename		dc.b	'S/Menu-Config00',0
	even

	Section 	Vars,Bss
	
DataStream		ds.l	1	
_DOSBase		ds.l	1
_IntuitionBase		ds.l	1
gadgpos			ds.l	1
RFfile_name		ds.l	1
RFfile_lock		ds.l	1
RFfile_info		ds.l	1
RFfile_len		ds.l	1
Filehd			ds.l	1
varptr			ds.l	1
CLI_OUT			ds.l	1
temp_buff		ds.b	100
Text			ds.b	100		;the text itself
	even
	
;-------------- Vars allocated to memory block,Thanks to Dave Edward's
;		for this tip.

	rsreset
Window.ptr		rs.l	1
Window.up		rs.l	1
Window.rp		rs.l	1
Filebuff		rs.l	1
File_len		rs.l	1
nextline		rs.l	1
comm_buff		rs.l	1
NextGadg		rs.l	1		temp pointer storage
Gadget.txt  		rs.l	it_SIZEOF

Vars_Sizeof		rs.l	1

	end					;Well did that make any sense
						;cos I'm lost.
			
						;I'm here on holiday:-) MM
			
	
