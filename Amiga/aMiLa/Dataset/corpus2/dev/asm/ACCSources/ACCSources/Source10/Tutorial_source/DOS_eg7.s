
; DOS_eg7.s

; Here is the program that will convert any file ( of 10000 bytes or less )
;from upper case to lower case. All you have to do is enter the files name
;as a parameter at the CLI.

; Useful messages are now printed all over the show, taking user-friendlieness
;to the extreme.

; Added a routine to get filename from user.

;--------------	To start with, the INCLUDE files we require.

		incdir		sys:include/		specify directory
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dos.i

;--------------	First then, 0 terminate parameter list.

Start		move.b		#0,-1(a0,d0)

;--------------	Now save start of parameter list as filename pointer

		move.l		a0,filename

;--------------	Open the DOS library

		lea		dosname,a1		a1->library name
		moveq.l		#0,d0			d0=0,any version
		CALLEXEC	OpenLibrary		open the library
		move.l		d0,_DOSBase		save base ptr
		beq		error			leave if error

;--------------	Get CLI output handle

		CALLDOS		Output			get handle
		move.l		d0,STD_OUT		save it
		beq		error1		leave if no handle

;--------------	Time for the first message, an introduction to the prog.

		lea		intro_msg,a0		a0=addr of msg
		bsr		PrintMsg		print it


;--------------	Check for usage instructions.

		move.l		filename,a0		a0-->parameter list
		cmpi.b		#'?',(a0)		is 1st param a ?
		bne		.continue		if not branch
		lea		usage,a0		a0=addr of msg
		bsr		PrintMsg		print it
		bra		error1			and quit

;--------------	Check that a file name has been given

.continue	move.l		filename,a0		a0-->parameter list
		tst.b		(a0)			is 1st byte a 0
		bne.s		.ok			if not branch

		bsr		GetFileName	else call subroutine
						;to get a filename from user

		tst.l		d0		does user want to quit?
		beq		error1		if so leave

;--------------	Now display a message telling user what file is bieng
;		converted.

.ok		lea		convrt_msg,a0	a0=addr of msg
		bsr		PrintMsg	print it

		move.l		filename,a0	a0=address of filename
		bsr		PrintMsg	print it

		lea		convrt_msg1,a0	a0=addr of msg
		bsr		PrintMsg	print it

;--------------	Allocate memory for our text buffer

		move.l		#10000,d0		d0=size in bytes
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 d1=requirements
		CALLEXEC	AllocMem		ask for memory
		move.l		d0,buffer		save mem addr
		bne.s		.cont1		branch if all ok

		lea		no_mem_msg,a0	a0=addr of error msg
		bsr		PrintMsg	print it
		bra		error1		leave if error

;--------------	Open file for reading

.cont1		move.l		filename,d1		d1=addr of filename
		move.l		#MODE_OLDFILE,d2	d2=access mode
		CALLDOS		Open			open the file
		move.l		d0,filehd		save handle
		bne.s		.cont2		branch if ok

		lea		no_file_msg,a0	a0=addr of error msg
		bsr		PrintMsg	print it
		bra		error2		leave if error

;--------------	Read data from file into buffer

.cont2		move.l		filehd,d1		d1=file handle
		move.l		buffer,d2		d2=addr of buffer
		move.l		#10000,d3		d3=max num of chars
		CALLDOS		Read			read data from file
		move.l		d0,file_len		save num of chars

;--------------	Close the file

		move.l		filehd,d1		d1=file handle
		CALLDOS		Close			close the file

;--------------	Call subroutine to do conversion. Note I have used the 
;		routine detailed above, but as a subroutine. If you wanted
;		to process the file in some other way, you just change the
;		subroutine.

		bsr		convert

;--------------	Open the file using MODE_NEWFILE to erase old contents

		move.l		filename,d1		d1=filename
		move.l		#MODE_NEWFILE,d2	d2=access mode
		CALLDOS		Open			and open file
		move.l		d0,filehd		save handle
		bne.s		.cont3		branch if OK

		lea		no_out_file,a0	a0=addr of error msg
		bsr		PrintMsg	print it		
		bra		error2		leave if error

;--------------	Write contents of buffer to the file

.cont3		move.l		filehd,d1		d1=files handle
		move.l		buffer,d2		d2=addr of buffer
		move.l		file_len,d3		d3=size of buffer
		CALLDOS		Write			write buffer

;--------------	Close the file

		move.l		filehd,d1		d1=file handle
		CALLDOS		Close			and close it

;--------------	Release buffer memory

error2		move.l		buffer,a1		a1=addr of buffer
		move.l		#10000,d0		d0=size allocated
		CALLEXEC	FreeMem			and release it

;--------------	Close the DOS library

error1		lea		all_done_msg,a0	a0=addr of message
		bsr		PrintMsg	print it

		move.l		_DOSBase,a1		a1=lib base ptr
		CALLEXEC	CloseLibrary		and close it

error		rts					all done so quit

;--------------
;--------------	SUBROUTINE AREA
;--------------

;--------------	Subroutine to get a filename from user

;Entry		none

;Exit		d0=0 if user wishes to quit or if no keyboard handle
;		   could be obtained.

;--------------	Get keyboard handle

GetFileName	CALLDOS		Input		get keyboard handle
		move.l		d0,STD_IN	store it
		beq.s		.error		leave if no handle

;--------------	Display a prompt to the user

		lea		get_file,a0	a0=addr of prompt message
		bsr		PrintMsg	print it

;--------------	Get filename

		move.l		STD_IN,d1	d1=handle
		move.l		#key_buffer,d2	d2=addr of buffer
		move.l		#buf_len,d3	d3=max num of chars to read
		CALLDOS		Read		get user input

;--------------	Save addr of filename and 0 terminate it

		lea		key_buffer,a0	a0=addr of filename
		move.l		a0,filename	save addr of filename
		move.b		#0,-1(a0,d0)	0 terminate

;--------------	Get first character of filename into register d0. If this is
;		a 0 byte then the user pressed return and wants to quit. This
;		value will be passed back to the calling program.

		moveq.l		#0,d0		clear d0
		move.b		(a0),d0		get 1st char into d0

;--------------	And return

.error		rts


;--------------	Subroutine to display any message in the CLI window

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

PrintMsg	move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT,d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		rts



;-------------- Subroutine to convert chars in buffer from lower case to
;		upper case.

; Initialise the data counter

convert		move.l		file_len,d0	d0 is counter
		subq.l		#1,d0		adjust for dbra
		
; Get address of start of buffer into register a0.

		move.l		buffer,a0	a0=start addr of buffer

; Move codes for 'a' and 'z' into data registers. This will speed loop up.

		move.b		#'a',d1		d1=code of char 'a'
		move.b		#'z',d2		d2=code of char 'z'

; If char is less than 'a' it is not lower case, so don't convert it.

char_loop	cmp.b		(a0)+,d1
		bgt.s		not_lower_case

; If char is greater than 'z' it is not lower case, so don't convert it.

		cmp.b		-1(a0),d2
		blt.s		not_lower_case 

; Char must be lower case so convert it.

		sub.b		#$20,-1(a0)	convert byte

; Test for end of data. Loop back if not there yet.

not_lower_case	dbra		d0,char_loop	loop until end of data

		rts

;--------------
;--------------	DATA AREA
;--------------

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

STD_OUT		dc.l		0
STD_IN		dc.l		0

filename	dc.l		0
		even
filehd		dc.l		0
buffer		dc.l		0
file_len	dc.l		0

;-------------- Buffer for keyboard entry

key_buffer		ds.b		200
buf_len		equ		*-buffer

;--------------	Messages that will be displayed in CLI window

intro_msg	dc.b		$0a,'Ucase, by M.Meany.',$0a,$0a,0
		even

usage		dc.b		$0a,'UCASE, a utility to convert all characters'
		dc.b		' in a file',$0a,' from lower case to upper case.',$0a,$0a
		dc.b		'From the CLI :',$0a
		dc.b		'              UCASE <filename>',$0a,$0a
		dc.b		'Where <filename> is the name of the file to convert.'
		dc.b		$0a,$0a,'     © M.Meany, March 91',$0a,$0a,0
		even

convrt_msg	dc.b		'Converting file : ',0
		even

convrt_msg1	dc.b		'  to upper case.',$0a,0
		even

no_mem_msg	dc.b		"ABORTED......Can't allocate memory for buffer.",$0a,0
		even

no_file_msg	dc.b		"ABORTED......Can't open file to read data.",$0a,0
		even

no_out_file	dc.b		"ABORTED......Can't open file to save data.",$0a,0
		even

all_done_msg	dc.b		"Thank you for using this utility. M.Meany.",$0a,$0a,0
		even

get_file	dc.b		"You must specify a file name !",$0a
		dc.b		"Please enter a file name or press return to quit.",$0a
		dc.b		0
		even

