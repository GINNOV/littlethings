*
*   include file for handling buffered files
*   founded 07.08.89 tm of supervisor
*

; 09.08.89 -> 1.01 fbuflib added, buflib now always loads Dosbase

*T
*T	BUFLIB.I * Metacc Include File
*T		 Version 1.01
*T		Date 07.08.89
*T
*B

;  fopen	(open a buffered file)
;  in:		a0=name, d0=mode (1005-1006)
;		[a6=dosbase];
;  call:	buflib	fopen [,Dos]
;  out:		d0=*buffile; /0=error/

;  fclose	(close a buffered file)
;  in:		a0=*buffile;
;		[a6=dosbase];
;  call:	buflib	fclose [,Dos]
;  out:		d0=success;

;  fflush	(flush the file buffers)
;  in:		a0=*buffile;
;		[a6=dosbase];
;  call:	buflib	fflush [,Dos]
;  out:		d0=success;

;  fread	(read given number of bytes)
;  in:		a0=*buffile; a1=*buffer, d0=length
;		[a6=dosbase];
;  call:	buflib	fread [,Dos]
;  out:		d0=number_of_bytes_read; /-1=error/

;  fwrite	(write given number of bytes)
;  in:		a0=*buffile; a1=*buffer, d0=length;
;		[a6=dosbase];
;  call:	buflib	fwrite [,Dos]
;  out:		d0=number_of_bytes_written; /-1=error/

;  fseek	(move to a different position in file)
;  in:		a0=*buffile; d0=offset, d1=mode;
;		[a6=dosbase];
;  call:	buflib	fseek [,Dos]
;  out:		d0=success;

;  fputc	(write a character)
;  in:		a0=*buffile; d0.b=char;
;		[a6=dosbase];
;  call:	buflib	fputc [,Dos]
;  out:		d0=success;

;  fputs	(write a string)
;  in:		a0=*buffile; a1=*string;
;		[a6=dosbase];
;  call:	buflib	fputs [,Dos]
;  out:		d0=number_of_chars_written; /-1 = error/

;  fgetc	(read a character)
;  in:		a0=*buffile;
;		[a6=dosbase];
;  call:	buflib	fgetc [,Dos]
;  out:		d0.l=char; /-1.l if error/

;  fgets	(read a line /LF-terminated/)
;  in:		a0=*buffile; a1=*buffer;
;		[a6=dosbase];
;  call:	buflib	fgets [,Dos]
;  out:		d0=number_of_bytes_read; a1=*(NULL);
;  notes:	The LF is also included to the output string.

;  feof		(check for end of file)
;  in:		a0=*buffile;
;		[a6=dosbase];
;  call:	buflib	feof [,Dos]
;  out:		d0=boolean; /-1 = eof/

*E

	xref	_BUFfopen
	xref	_BUFfclose
	xref	_BUFfflush
	xref	_BUFfread
	xref	_BUFfputc
	xref	_BUFfgets
	xref	_BUFfseek
	xref	_BUFfgetc
	xref	_BUFfeof
	xref	_BUFfwrite
	xref	_BUFfputs

buflib	macro	[name]
	ifnc	'\1',''
	lbase	Dos,a6
	bsr	_BUF\1
	endc
	endm

fbuflib	macro	[name]
	bsr	_BUF\1
	endm

