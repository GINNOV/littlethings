
; M.Meany 20th September 1990

; For DevpacII tab spacing set at 16
 
	opt	c-,o+,ow-	optimise
	
; The following file has all library offsets in as found in the back of
;Abicus Amiga Machine Language.
	
	include	source5:include/libs.i

start	
	bsr	save_ptrs	saves parameter list pointers
	bsr	open_dos	open the dos library
	beq.s	fast_exit	leave if any problems
	bsr	get_CLI_handle	get CLI i/o handles
	bsr	check_usage	check for ? and display text if found
	bne.s	params_found	if parameter exsists then jump
	bsr	no_params_err	else display error message
	bra	easy_out	and leave
params_found	tst.b	use_flag	was usage text displayed ?
	bne	easy_out	leave if it was
	bsr	make_filenames	get filenames from param string
	bsr	print_msg1	display info to user
	bsr	open_infile	open text file
	beq	easy_out	leave if error
	bsr	print_msg2	display info to user
	bsr	open_outfile	open .mod file
	beq	error_1	leave if error
	bsr	get_data	read text into buffer
	bsr	print_msg3	display info to user
	bsr	process	process buffer
	bsr	save_data	save processed text to disc
	bsr	close_outfile	close output file
error_1	bsr	close_infile	close input file
easy_out	bsr	print_end	display info to user
	bsr	close_dos	close DOS library
;	bsr	mouse
fast_exit	rts		leave

;*********************************************
; Text2Scrolltext Filter program
; SK 15th September 1990

process	movem.l	d0-d1/a0,-(sp)	save the used regs
	move.l	file_size,d1	file length
	lea	io_buffer,a0	address of text to filter
proc_loop:
	moveq	#0,d0
	move.b	(a0),d0	next byte in d0
	cmp.b	#10,d0	is it $a / line feed
	bne.s	update	no - go to update
	move.b	#32,d0	change to $20 / space
update:
	move.b	d0,(a0)+	put byte back whether changed or not
	dbra	d1,proc_loop	jump until end of text
	movem.l	(sp)+,d0-d1/a0	restore regs for writedata
	rts
;*******************************************

*****************************************************************************
; This routine copies the supplied name into infilename and outfilename. It
;also adds the extension .mod to outfilename and makes sure both names are
;null terminated.

make_filenames	move.l	param_ptr,a0	get length and address of
	move.l	param_len,d0	supplied filename
	subi.l	#2,d0	correct for dbra and $0a
	lea	infilename,a1	get address of destinations
	lea	outfilename,a2
makefileloop	move.b	(a0),(a1)+	copy each char
	move.b	(a0)+,(a2)+
	dbra	d0,makefileloop 
	move.b	#0,(a1)	null terminate infilename
	move.b	#'.',(a2)+	add .mod to outfilename
	move.b	#'m',(a2)+
	move.b	#'o',(a2)+
	move.b	#'d',(a2)+
	move.b	#0,(a2)	null terminate outfilename
	rts		all done so return

*****************************************************************************
; This routine displays a witty message if no filename was specified.

; Puts address of message string into str_pointer and length of string into
;str_length as required by display_msg subroutine

no_params_err	move.l	#no_param_msg,str_pointer
	move.l	#param_msg_end-no_param_msg,str_length
	bsr	display_msg
	rts
*****************************************************************************
; This displays the opening input message.

; Puts address of message string into str_pointer and length of string into
;str_length as required by display_msg subroutine

print_msg1	move.l	#msg1,str_pointer
	move.l	#msg1_end-msg1,str_length
	bsr	display_msg

; Puts address of infilename string into str_pointer and uses calc_msg_len to
;put its length into str_length as required by display_msg subroutine

	move.l	#infilename,str_pointer
	bsr	calc_msg_len	
	bsr	display_msg
	rts

*****************************************************************************
; Puts address of message string into str_pointer and length of string into
;str_length as required by display_msg subroutine

print_msg2	move.l	#msg2,str_pointer
	move.l	#msg2_end-msg2,str_length
	bsr	display_msg

;Puts address of outfilename string into str_pointer and uses calc_msg_len to
;put its length into str_length as required by display_msg subroutine

	move.l	#outfilename,str_pointer
	bsr	calc_msg_len
	bsr	display_msg
	rts

*****************************************************************************
; This displays the removing CR message.

; Puts address of message string into str_pointer and length of string into
;str_length as required by display_msg subroutine

print_msg3	move.l	#msg3,str_pointer
	move.l	#msg3_end-msg3,str_length
	bsr	display_msg
	rts

*****************************************************************************
; This displays the all done message.


print_end	move.l	#end_msg,str_pointer
	move.l	#end_end-end_msg,str_length
	bsr	display_msg
	rts

*****************************************************************************
; Opens the specified input file.

; The address of the filename is put in filename and the opening mode is put
;in mode as required by the open_file subroutine. The file handle is copied
;into infilehd once the file has been opened. If open fails then an error
;message is displayed.

open_infile	move.l	#infilename,filename
	move.l	#mode_oldfile,mode
	bsr	open_file
	move.l	filehd,infilehd
	bne.s	infile_opened
	move.l	#err_msg1,str_pointer
	move.l	#err1_end-err_msg1,str_length
	bsr	display_msg
	moveq.l	#0,d0
infile_opened	rts

*****************************************************************************
; Closes the specified input file.

; The file handle is copied into filehd as required by close_file.

close_infile	move.l	infilehd,filehd
	bsr	close_file
	rts

*****************************************************************************
; Opens the specified output file.

; The address of the filename is put in filename and the opening mode is put
;in mode as required by the open_file subroutine. The file handle is copied
;into outfilehd once the file has been opened. If open fails then an error
;message is displayed.

open_outfile	move.l	#outfilename,filename
	move.l	#mode_newfile,mode
	bsr	open_file
	move.l	filehd,outfilehd
	bne.s	outfile_opened
	move.l	#err_msg1,str_pointer
	move.l	#err1_end-err_msg1,str_length
	bsr	display_msg
	moveq.l	#0,d0
outfile_opened	rts

*****************************************************************************
; Closes the specified output file.

; The file handle is copied into filehd as required by close_file.

close_outfile	move.l	outfilehd,filehd
	bsr	close_file
	rts

*****************************************************************************
; Read data from the input file into memory at io_buffer.

; The file handle is copied into filehd and the number of chars into buf_len
;as required by read_data. Note that there is no need in this case to put
;address of buffer into buffer as we are going to use the io_buffer that is
;supplied by the dos_subs.i file.

get_data	move.l	infilehd,filehd
	move.l	#1000,buf_len
	bsr	read_data
	move.l	buf_len,file_size
	rts
	
*****************************************************************************
; Save data in io_buffer to the output file.

; The file handle is copied into filehd and the number of chars into buf_len
;as required by save_data. Note that there is no need in this case to put
;address of buffer into buffer as we are going to use the io_buffer that is
;supplied by the dos_subs.i file.
	
save_data	move.l	outfilehd,filehd
	move.l	file_size,buf_len
	bsr	write_data
	rts
	
*****************************************************************************
*                                Variables                                  *	
*****************************************************************************

msg1	dc.b	$0a,'Opening input file:  '
msg1_end	even

msg2	dc.b	$0a,'Opening output file: '
msg2_end	even

msg3	dc.b	$0a,'Removing all carriage returns.'
msg3_end	even

end_msg	dc.b	$0a,'All done !',$0a
end_end	even

infilehd	dc.l	0
infilename	ds.b	50
	even
	
outfilehd	dc.l	0
outfilename	ds.b	50
	even
	
err_msg1	dc.b	$0a,'Aborted, cant open file',$0a
err1_end	even

no_param_msg	dc.b	10,' Sorry, my psychic batteries are running low. Try ? for usage.',10
param_msg_end	even

file_size	dc.l	0

	include	source5:include/dos_subs.i
