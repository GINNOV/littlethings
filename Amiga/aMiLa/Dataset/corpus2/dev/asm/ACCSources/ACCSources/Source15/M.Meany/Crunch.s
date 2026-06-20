

; This program was written for Artwerx by M.Meany, July 1991.

; © M.Meany,1991.

; This is a basic ByteRun cruncher. No frills!


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

;-------------- Call subroutine to determine length of file

		move.l		filename,a0	a0->the files name
		bsr		FileLen		determine size of file
		move.l		d0,file_len	save length
		bne.s		.cont		branch if all ok

		lea		no_len_msg,a0	a0=addr of error msg
		bsr		PrintMsg	print it
		bra		error1		and quit

;--------------	Allocate memory for our text buffer. D0 already holds the
;		length of the file.

.cont		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 d1=requirements
		CALLEXEC	AllocMem		ask for memory
		move.l		d0,Inbuffer		save mem addr
		bne.s		.cont1		branch if all ok

		lea		no_mem_msg,a0	a0=addr of error msg
		bsr		PrintMsg	print it
		bra		error1		leave if error

.cont1		move.l		file_len,d0		d0=size of memory
		addq.l		#4,d0			add some extra
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 d1=requirements
		CALLEXEC	AllocMem		ask for memory
		move.l		d0,Outbuffer		save mem addr
		bne.s		.cont2		branch if all ok

		lea		no_mem_msg,a0	a0=addr of error msg
		bsr		PrintMsg	print it
		bra		error2		leave if error

;--------------	Open file for reading

.cont2		move.l		filename,d1		d1=addr of filename
		move.l		#MODE_OLDFILE,d2	d2=access mode
		CALLDOS		Open			open the file
		move.l		d0,filehd		save handle
		bne.s		.cont3		branch if ok

		lea		no_file_msg,a0	a0=addr of error msg
		bsr		PrintMsg	print it
		bra		error3		leave if error

;--------------	Read data from file into buffer

.cont3		move.l		filehd,d1		d1=file handle
		move.l		Inbuffer,d2		d2=addr of buffer
		move.l		file_len,d3		d3=size of file
		CALLDOS		Read			read data from file

;--------------	Close the file

		move.l		filehd,d1		d1=file handle
		CALLDOS		Close			close the file

;--------------	Call subroutine to do conversion. Note I have used the 
;		routine detailed above, but as a subroutine. If you wanted
;		to process the file in some other way, you just change the
;		subroutine.

		move.l		Inbuffer,a0
		move.l		file_len,d0
		move.l		Outbuffer,a1
		bsr		Crunch			crunch data
		move.l		d0,Crunch_len		save size
		bne.s		.hi_frank		and jump if alls ok

		lea		no_gain_msg,a0		a0->err msg
		bsr		PrintMsg		and print it
		bra		error3			quit if error

;--------------	Open the file using MODE_NEWFILE to erase old contents

.hi_frank	move.l		filename,d1		d1=filename
		move.l		#MODE_NEWFILE,d2	d2=access mode
		CALLDOS		Open			and open file
		move.l		d0,filehd		save handle
		bne.s		.cont4		branch if OK

		lea		no_out_file,a0	a0=addr of error msg
		bsr		PrintMsg	print it		
		bra		error3		leave if error

;--------------	Write contents of buffer to the file

.cont4		move.l		filehd,d1		d1=files handle
		move.l		#file_len,d2		d2=length of file
		move.l		#4,d3			d3=1 long word
		CALLDOS		Write			write buffer

		move.l		filehd,d1		d1=files handle
		move.l		Outbuffer,d2		d2=addr of buffer
		move.l		Crunch_len,d3		d3=size of buffer
		CALLDOS		Write			write buffer

		move.l		filehd,d1		d1=files handle
		move.l		#TheEnd,d2		d2=NULL terminator
		move.l		#2,d3			d3=1 word
		CALLDOS		Write			write buffer

;--------------	Close the file

		move.l		filehd,d1		d1=file handle
		CALLDOS		Close			and close it

;--------------	Release buffer memory

error3		move.l		Outbuffer,a1		a1=addr of buffer
		move.l		file_len,d0		d0=size allocated
		CALLEXEC	FreeMem			and release it

;--------------	Release buffer memory

error2		move.l		Inbuffer,a1		a1=addr of buffer
		move.l		file_len,d0		d0=size allocated
		CALLEXEC	FreeMem			and release it

;--------------	Close the DOS library

error1		lea		all_done_msg,a0	a0=addr of message
		bsr		PrintMsg	print it

		move.l		_DOSBase,a1		a1=lib base ptr
		CALLEXEC	CloseLibrary		and close it

error		rts					all done so quit

**************************************************************************

;--------------
;--------------	SUBROUTINE AREA
;--------------

**************************************************************************

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

**************************************************************************

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

**************************************************************************

; ByteRun algorithm. For ArtWerx by M.Meany, July 1991.

; This subroutine will attempt to crunch an area of memory using the IFF
;byterun method. If the crunched size exceeds the original size, the routine
;aborts.


; Entry		a0-> Data to be crunched
;		d0=size of data to crunch
;		a1-> Buffer to store crunched data at (2 bytes more than d0)

; Exit		d0=size of crunched file or 0 if failure

Crunch		move.l		d0,d7		save a copy
		subq.l		#1,d0		adjust for dbra
		moveq.l		#0,d1		clear counter

.loop		moveq.l		#1,d2		byte counter
		move.b		(a0)+,d3	get a byte
.inner		cmp.b		(a0)+,d3	compare with next byte
		bne.s		.write		if different save byte/count
		addq.b		#1,d2		bump count
		bcc		.ok		if < 255 keep going
		move.l		#255,d2		step back
		bra		.write		and save byte/count

.ok		dbra		d0,.inner	loop back if not finished
		bra		.done		else finish up

.write		lea		-1(a0),a0	step back a byte
		move.b		d3,(a1)+	save byte
		move.b		d2,(a1)+	save count
		addq.l		#2,d1		bump crunched length
		cmp.l		d7,d1		crunched>original ?
		bgt		.abort		if so abort!
		dbra		d0,.loop	else loop back
		move.l		d1,d0		d0=crunched size
		rts				and finish

.done		move.b		d3,(a1)+	save byte
		move.b		d2,(a1)+	save count
		addq.l		#2,d1		bump crunched length
		move.l		d1,d0		d0=crunched size
		rts				and finish

.abort		moveq.l		#0,d0		signal error
		rts				and finish

**************************************************************************

; Subroutine that returns the length of a file in bytes.

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

; M.Meany, Feb 91


; Save register values

FileLen		movem.l		d1-d4/a1-a4,-(sp)

; Save address of filename and clear file length

		move.l		a0,RFfile_name
		move.l		#0,RFfile_len

; Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,RFfile_info
		beq		.error1
		
; Lock the file
		
		move.l		RFfile_name,d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,RFfile_lock
		beq		.error2

; Use Examine to load the File Info block

		move.l		d0,d1
		move.l		RFfile_info,d2
		CALLDOS		Examine

; Copy the length of the file into RFfile_len

		move.l		RFfile_info,a0
		move.l		fib_Size(a0),RFfile_len

; Release the file

		move.l		RFfile_lock,d1
		CALLDOS		UnLock

; Release allocated memory

.error2		move.l		RFfile_info,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem


; All done so return

.error1		move.l		RFfile_len,d0
		movem.l		(sp)+,d1-d4/a1-a4
		rts

RFfile_name	dc.l		0
RFfile_lock	dc.l		0
RFfile_info	dc.l		0
RFfile_len	dc.l		0

**************************************************************************


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
Inbuffer	dc.l		0
Outbuffer	dc.l		0
file_len	dc.l		0
Crunch_len	dc.l		0
TheEnd		dc.w		0

;-------------- Buffer for keyboard entry

key_buffer		ds.b		200
buf_len			equ		*-key_buffer

;--------------	Messages that will be displayed in CLI window

intro_msg	dc.b		$0a,'Crunch, by M.Meany.',$0a,$0a,0
		even

usage		dc.b		$0a,'Crunch, a utility to crunch a raw data file.',$0a
		dc.b		'Uses the ByteRun method.',$0a,$0a
		dc.b		'From the CLI :',$0a
		dc.b		'              Crunch <filename>',$0a,$0a
		dc.b		'Where <filename> is the name of the file to crunch.',$0a
		dc.b		'NOTE: Crunched file replaces the original !!!!!!!! '
		dc.b		$0a,$0a,'     © M.Meany, July 91',$0a,$0a,0
		even

convrt_msg	dc.b		'File : ',0
		even

convrt_msg1	dc.b		'  is being crunched.',$0a,0
		even

no_len_msg	dc.b		"ABORTED......Can't determine files length.",$0a,0
		even

no_mem_msg	dc.b		"ABORTED......Can't allocate memory for buffer.",$0a,0
		even

no_file_msg	dc.b		"ABORTED......Can't open file to read data.",$0a,0
		even

no_out_file	dc.b		"ABORTED......Can't open file to save data.",$0a,0
		even

all_done_msg	dc.b		"Thank you for using this utility. M.Meany.",$0a,$0a,0
		even

no_gain_msg	dc.b		"ABORTED......Crunched file larger than original!",$0a,0
		even

get_file	dc.b		"You must specify a file name !",$0a
		dc.b		"Please enter a file name or press return to quit.",$0a
		dc.b		0
		even

