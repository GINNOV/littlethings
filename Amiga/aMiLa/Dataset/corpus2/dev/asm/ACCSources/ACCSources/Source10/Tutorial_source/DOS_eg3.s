
; DOS_eg3.s

; Here is the program that will convert any file ( of 10000 bytes or less )
;from upper case to lower case. All you have to do is enter the files name
;as a parameter at the CLI.

; Now comes complete with usage text printed when ? is enterd at the CLI

;--------------	To start with, the INCLUDE files we require.

		incdir		sys:include/		specify directory
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dos.i

;--------------	First then, 0 terminate parameter list.

		move.b		#0,-1(a0,d0)

;--------------	Now save start of parameter list as filename pointer

		move.l		a0,filename

;--------------	Open the DOS library

		lea		dosname,a1		a1->library name
		moveq.l		#0,d0			d0=0,any version
		CALLEXEC	OpenLibrary		open the library
		move.l		d0,_DOSBase		save base ptr
		beq		error			leave if error

;--------------	Now the DOS lib is open, check for usage instructions.

		move.l		filename,a0		a0-->parameter list
		cmpi.b		#'?',(a0)		is 1st param a ?
		beq		usage_msg		if so brach

;--------------	Allocate memory for our text buffer

		move.l		#10000,d0		d0=size in bytes
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 d1=requirements
		CALLEXEC	AllocMem		ask for memory
		move.l		d0,buffer		save mem addr
		beq		error1			leave if error

;--------------	Open file for reading

		move.l		filename,d1		d1=addr of filename
		move.l		#MODE_OLDFILE,d2	d2=access mode
		CALLDOS		Open			open the file
		move.l		d0,filehd		save handle
		beq		error2			leave if error

;--------------	Read data from file into buffer

		move.l		filehd,d1		d1=file handle
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
		beq		error2			leave if error

;--------------	Write contents of buffer to the file

		move.l		filehd,d1		d1=files handle
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

error1		move.l		_DOSBase,a1		a1=lib base ptr
		CALLEXEC	CloseLibrary		and close it

error		rts					all done so quit

;--------------
;--------------	SUBROUTINE AREA
;--------------

;--------------	The Usage routine. Not a subroutine proper, but I put it
;		here anyhow.

usage_msg	CALLDOS		Output			get CLI handle
		move.l		d0,d1			put it in d1
		beq.s		no_cli			whoops ! no CLI

		move.l		#usage,d2		d2=addr of message
		move.l		#usage_len,d3		d3=len of message
		CALLDOS		Write			write the message

no_cli		bra		error1			close DOS and finish


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

filename	dc.l		0
		even
filehd		dc.l		0
buffer		dc.l		0
file_len	dc.l		0

usage		dc.b		$0a,'UCASE, a utility to convert all characters'
		dc.b		' in a file',$0a,' from lower case to upper case.',$0a,$0a
		dc.b		'From the CLI :',$0a
		dc.b		'              UCASE <filename>',$0a,$0a
		dc.b		'Where <filename> is the name of the file to convert.'
		dc.b		$0a,$0a,'     © M.Meany, March 91',$0a,$0a
usage_len	equ		*-usage
		even
