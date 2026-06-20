

	; Examine the SIMPLE_WINDOW.S before you try this one. In this source,
	; some more commands in the doslib are used. 


START:	movem.l	d0-a6,-(a7)			; save all registers on stack

OPENDOSLIB:
	move.l	$4,a6
	move.l	#doslibname,a1
	jsr	-408(a6)
	move.l	d0,dosbase
	beq.w	error

OPEN:	move.l	#filename,d1			; open a window (see filename)
	move.l	#1006,d2
	move.l	dosbase,a6
	jsr	-30(a6)
	move.l	d0,filehandle
	beq.w	error

WRITE:	move.l	filehandle,d1			; handle of file (window)
	move.l	#menutext,d2			; address of text
	move.l	#endofmenutext-menutext,d3	; length of text
	move.l	dosbase,a6
	jsr	-48(a6)				; 'Write'

READ:	; read some text from this window (you must type something!)
	; the READ command in the doslib is used. It needs 3 parameters:

	move.l	filehandle,d1			; again, d1 must contain the
						; handle of our file (window)
	move.l	#buffer,d2			; d2 must contain the address
						; of the buffer, where the
						; text to be read will be 
						; stored to.
	move.l	#5,d3				; d3=the amount of bytes to be
						; read. (unless you type
						; return earlier)
	move.l	dosbase,a6
	jsr	-42(a6)				; call the 'read' command


CHECK:	move.b	buffer,d0			; check first character in the
						; buffer:
	cmp.b	#"1",d0
	beq.s	routine1			; switch to each routine

	cmp.b	#"2",d0				; for the different possible
	beq.s	routine2			; menu-options

	cmp.b	#"3",d0
	beq.s	routine3

	cmp.b	#"4",d0
	beq.w	close				; 4: end-of-program

	; none of the possible characters were entered, so the user typed
	; something else: display an error message, using the WRITE command:

	move.l	filehandle,d1			; handle of output-file
	move.l	#errormessage,d2		; address of the text
	move.l	#endoferror-errormessage,d3	; length of text
	move.l	dosbase,a6
	jsr	-48(a6)				; 'Write'

DELAY:	; now wait 1 second and re-display the menu

	move.l	#50,d1				; time to delay (1 sec)
	move.l	dosbase,a6
	jsr	-198(a6)			; 'delay'
	
	bra	WRITE				; and goto 'WRITE'

*********

routine1:
	move.l	filehandle,d1			; handle of output-file
	move.l	#message1,d2			; address of the text
	move.l	#endm1-message1,d3		; length of text
	move.l	dosbase,a6
	jsr	-48(a6)				; 'Write'
	bra	delay				; continue at 'delay'

routine2:
	move.l	filehandle,d1			; handle of output-file
	move.l	#message2,d2			; address of the text
	move.l	#endm2-message2,d3		; length of text
	move.l	dosbase,a6
	jsr	-48(a6)				; 'Write'
	bra	delay				; continue at 'delay'
	
routine3:
	move.l	filehandle,d1			; handle of output-file
	move.l	#message3,d2			; address of the text
	move.l	#endm3-message3,d3		; length of text
	move.l	dosbase,a6
	jsr	-48(a6)				; 'Write'
	bra	delay				; continue at 'delay'

***********

CLOSE:	; now close the file, opened with the OPEN command. This will in this
	; case close the window.

	move.l	filehandle,d1			; d1 must contain the file-
						; handle.
	move.l	dosbase,a6
	jsr	-36(a6)				; call the 'close' command.


error:	movem.l	(a7)+,d0-a6			; restore all registers
	rts					; end of program

***************************

;; Here starts the DATA part. Make sure it is situated BEHIND the code-part


doslibname:	dc.b	"dos.library",0
filename:	dc.b	"con:100/50/440/180/ Simple Menu, made for Mike ",0


menutext:	dc.b	27,"c"		; 27,"c" clears the window
		dc.b	10		; 10 means 'return'
		dc.b	10
		dc.b	"  Please make a selection:",10
		dc.b	"  ------------------------",10
		dc.b	10
		dc.b	10
		dc.b	"  1. blabla",10
		dc.b	"  2. blabla",10
		dc.b	"  3. blabla",10
		dc.b	"  4. exit",10
		dc.b	10
		dc.b	"  Your choice: ",0
endofmenutext:

message1:	dc.b	10,"You typed '1'",0
endm1:

message2:	dc.b	10,"You typed '2'",0
endm2:

message3:	dc.b	10,"You typed '3'",0
endm3:

errormessage:	dc.b	10,"Wrong selection ! Please try again !",0
endoferror:

buffer:		blk.b	5,0	; reserve 5 bytes to read some text

		even


dosbase:	dc.l	0
filehandle:	dc.l	0

