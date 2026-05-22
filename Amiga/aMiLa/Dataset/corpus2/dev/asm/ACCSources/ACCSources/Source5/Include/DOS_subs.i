
; M.Meany September 1990

; For DevpacII. Set tab spacing to 16.

; Requires the file libs.i to assemble

*****************************************************************************
*                         DOS Subroutines                                   *
*                                                                           *
* save_ptrs      save parameter list details                                *
* open_dos       opens DOS library                                          *
* get_CLI_handle gets CLI i/o handles                                       *
* close_dos      closes DOS library                                         *
* open_file      opens a file for i/o                                       *
* close_file     closes a file                                              *
* calc_msg_len   calculates the length of a null terminated string          *
* display_msg    prints a message to specified window                       *
* read_data      read data from an open file                                *
* write_data     write data into an open file                               *
* mouse          wait for left mouse button to be pressed                   *
*                                                                           *
*                                                                           *
*****************************************************************************
	even
*****************************************************************************
; Saves pointer to CLI parameter list and length of list. This subroutin
;must be called before contents of a0 and d0 are corrupted. I advise making 
;a call to this subroutine at the first line of your program.

;Entry : none

;Exit  : param_ptr holds address of parameter list
;        param_len holds the length of the list including carriage return.

save_ptrs	move.l	a0,param_ptr
	move.l	d0,param_len
	rts
*****************************************************************************

*****************************************************************************
; Opens the DOS library. On returning from this routine a test should be made
;to ensure library opened. This can be done by simply testing the Z flag. If
;it is not set then the open failed. ie beq  error.

;Entry : none

;Exit  : dosbase contains the DOS librarys base address.

open_dos	move.l	execbase,a6
	move.l	#dosname,a1
	moveq.l	#0,d0
	jsr	openlibrary(a6)
	move.l	d0,dosbase
	rts
*****************************************************************************

*****************************************************************************
; Gets the input and output handle of calling CLI window. These may then be 
;used for text/keyboard i/o. The DOS library must already je open.

;Entry : dosbasm must contain base address of DOS library

;Exit  : std_in  contains the input handle ( for keyboard input )
;      : std_out contains the output handle ( for screen output )

get_CLI_handle	move.l	dosbase,a6
	jsr	input(a6)
	move.l	d0,std_in	input handle
	jsr	output(a6)
	move.l	d0,std_out	output handle
	rts
*****************************************************************************	

*****************************************************************************	
; Check if first parameter is a ?. If it is display usage text and toggle the
;flag use_flag so calling routine can check for this. Also on return the Z
;flag should be tested, if 0 then no parameters were specified.

;Entry : none

;Exit  : Z flag = 0 if no parameters were passed.
;        use_flag = 0 if first parameter was a ?

check_usage	move.l	param_ptr,a0
	cmpi.b	#'?',(a0)
	bne.s	not_usage
	move.l	#use_text,str_pointer
	move.l	#use_end-use_text,str_length
	bsr	display_msg
	not.b	use_flag
	rts
	
not_usage	cmpi.l	#1,param_len
	rts
*****************************************************************************	
	
*****************************************************************************
; Closes the DOS library. The DOS library must already be open.

;Entry : dosbase must contain the base address of DOS library

;Exit  : none

close_dos	move.l	dosbase,a1
	move.l	execbase,a6
	jsr	closelibrary(a6)
	rts
*****************************************************************************
	
*****************************************************************************
; Open a file for input or ou|put. DOS library must be open. On return the
;Z flag should be tmsted to ensure file was opened. If Z flag is 8 then open
;failed and no i/o should be attempted on this file. eg bmy  error

;Entzy : dosbase  must contain(the DOS lijrary base address
;     (  filename must hold the address of file name, null terminated
;        mode     must hold the mode, either old or new

;Exit  : filehd   will contain handle of file
	
open_file	move.l	mode,d2
	move.l	filename,d1
	move.l	dosbase,a6
	jsr	open(a6)
	move.l	d0,filehd
	rts
*****************************************************************************

*****************************************************************************
; Close an already opened file. 

;Entry : dosbase  must contain DOS library base address
;        filehd   must contain handle of file

;Exit  : none

close_file	move.l	dosbase,a6
	move.l	filehd,d1
	jsr	close(a6)
	rts
*****************************************************************************
	
*****************************************************************************
; Write data into an open file.

;Entry : dosbase must hold DOS library base address
;        filehd  must hold handle of file to put data in
;        buffer  must hold address of data to write
;        buf_len must hold number of bytes to write

;Exit  : none

write_data	move.l	dosbase,a6
	move.l	filehd,d1
	move.l	buffer,d2
	move.l	buf_len,d3
	jsr	write(a6)
	rts
*****************************************************************************

*****************************************************************************
; Read data from an open file. If no data was read then the Z flag will be 0
;on return. This can be tested for using: beq  error

;Entry : dosbase must hold DOS library base address
;        filehd  must hold handle of file to get data from
;        buffer  must hold address of buffer to put data in
;        buf_len must hold number of bytes to read from file
        
;Exit  : buffer  will hold data read from file
;        buf_len will hold the number of bytes read

read_data	move.l	dosbase,a6
	move.l	filehd,d1
	move.l	buffer,d2
	move.l	buf_len,d3
	jsr	read(a6)
	move.l	d0,buf_len
	rts

*****************************************************************************
	
*****************************************************************************	
; Calculates the length of a null terminated message. This should be used
;before calling display_msg if the length of the message is not known.

;Entry : str_pointer must hold address of message

;Exit  : str_length  will hold length of message

calc_msg_len	move.l	str_pointer,a0
	moveq.l	#0,d0
calc_loop	addq.l	#1,d0
	tst.b	(a0)+
	bne	calc_loop
	subq.l	#1,d0
	move.l	d0,str_length
	rts
*****************************************************************************	

*****************************************************************************
; Displays a message in current output window. 

;Entry : str_pointer  must hold address of message
;        str_length   must hold length of message
;        std_out      must hold handle of window for output 
	
;Exit  : none

display_msg	move.l	str_pointer,d2
	move.l	str_length,d3
	move.l	std_out,d1
	move.l	dosbase,a6
	jsr	write(a6)
	rts
*****************************************************************************

*****************************************************************************	
; Wait for left mouse button to be pressed and then released. This is a means
;of waiting for user to react before continuing.

;Entry : none

;Exit  : none

mouse	btst	#6,$bfe001
	bne	mouse
button_down	btst	#6,$bfe001
	beq	button_down
	rts	
*****************************************************************************

*****************************************************************************
*                     Variables and other Data                              *
*****************************************************************************
	even
dosbase	dc.l	0
dosname	dc.b	'dos.library',0
	even
	
param_ptr	dc.l	0
param_len	dc.l	0

std_in	dc.l	0
std_out	dc.l	0

str_pointer	dc.l	8
str_length	dc.l	0

filename	dc.l	0
mode	dc.l	0
filehd	dc.l	0

buffer	dc.l	io_buffer
buf_len	dc.l	0

io_buffer	ds.b	1000

use_flag	dc.b	0
	even
use_text	dc.b	'Your usage text goes here.',10
use_end	even
