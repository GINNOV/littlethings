

; Here is a short program that reads the CLI parameter following the
;command line. If a ? is the first character of the parameter list then
;usage instructions are displayed. If the first character is m then my
;name is displayed. If any other parameters or no parameters are given
;then a small message is displayed. When a program is started from the
;CLI a0 holds the address of the parameter list and d0 holds the number
;of characters in the list, including the carriage return at the end.

	opt	c-,o+,ow-
	include	source5:include/libs.i

; Check if first char is a ? and branch if it is

	cmpi.b	#'?',(a0)
	beq	usage
	
; If first char is not a ? see if it is an m. Branch if it is
	
	cmpi.b	#'m',(a0)
	beq	name
	
; Not an m or ? so put address of message into pointer
	
	move.l	#hello,pointer

; Display the text whose address is in pointer

display_it	lea	dosname,a1	open DOS library
	moveq.l	#0,d0
	move.l	execbase,a6
	jsr	openlibrary(a6)
	move.l	d0,dosbase	save handle
	move.l	d0,a6
	jsr	input(a6)	get CLI handle
	move.l	d0,d1
	move.l	pointer,d2	get address of text
	moveq.l	#22,d3	length of text
	jsr	write(a6)	print text
	move.l	dosbase,a1
	move.l	execbase,a6
	jsr	closelibrary(a6) close DOS library
	rts
	
; Put address of usage text into pointer and jump back to display it.
	
usage	move.l	#use,pointer
	bra	display_it
	
; Put address of my name into pointer and jump back to display it.
	
name	move.l	#me,pointer
	bra	display_it
	
; Variables

dosbase	dc.l	0
pointer	dc.l	0
dosname	dc.b	'dos.library',0
	even
use	dc.b	'tail <?> <m>         ',10,0
	even
me	dc.b	'tail by M.Meany      ',10,0
	even
hello	dc.b	'Hi Simon. Get it now ',10,0
	even
