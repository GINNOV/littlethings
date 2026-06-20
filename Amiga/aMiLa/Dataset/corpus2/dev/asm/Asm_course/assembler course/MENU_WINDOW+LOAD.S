
	; finally, this source will show the same menu as the other one,
	; but this one will EXECUTE a command when you type a selection.
	; see 'routine1' etc.

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
	move.l	#demoname1,d1			; name of command to be
						; executed
	clr.l	d2				; zero
	clr.l	d3				; zero
	move.l	dosbase,a6
	jsr	-222(a6)			; call the 'EXECUTE' command
	bra	DELAY

routine2:
	move.l	#demoname2,d1			; name of command to be
						; executed
	clr.l	d2				; zero
	clr.l	d3				; zero
	move.l	dosbase,a6
	jsr	-222(a6)			; call the 'EXECUTE' command
	bra	DELAY
	
routine3:
	move.l	#demoname2,d1			; name of command to be
						; executed
	clr.l	d2				; zero
	clr.l	d3				; zero
	move.l	dosbase,a6
	jsr	-222(a6)			; call the 'EXECUTE' command
	bra	DELAY

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
		dc.b	"  1. load demo 1",10
		dc.b	"  2. load demo 2",10
		dc.b	"  3. load demo 3",10
		dc.b	"  4. exit",10
		dc.b	10
		dc.b	"  Your choice: ",0
endofmenutext:

demoname1:	dc.b	"df0:demo1",0
demoname2:	dc.b	"df0:demo2",0
demoname3:	dc.b	"df0:demo3",0

errormessage:	dc.b	10,"Wrong selection ! Please try again !",0
endoferror:

buffer:		blk.b	5,0	; reserve 5 bytes to read some text

		even


dosbase:	dc.l	0
filehandle:	dc.l	0

