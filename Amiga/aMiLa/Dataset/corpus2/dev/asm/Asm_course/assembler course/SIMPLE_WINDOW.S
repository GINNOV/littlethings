

	; the next part will open a window on the screen, print text in it,
	; wait a few seconds, and close it again. 

	; NOTE **** the window will be on the WORKBENCH-screen so it is NOT
	; visible in the ASMONE-screen. Switch to the workbench screen if you
	; wanna look at it.

	; How this program works: A window on the Amiga can be threated 
	; just as a FILE: you use the same routines
	; to open a file on disk (df0:) as to open a window (con: or raw:)
	; A filename on disks is something like df0:s/startup-sequence.
	; The 'filename' for a window is: "CON:x1/y1/x2/y2/name" where you
	; must fill in x1..y2 with the start- and end-coordinates of the
	; window. for example if you open a file called 
	; "CON:0/0/640/256/testwindow", a window with titlebar "testwindow"
	; will appear with maximum size.
	; You can use this way of opening a window ANYwhere, so also in
	; CLI-commands. Try for example:

	; COPY df0:s/startup-sequence CON:0/0/640/256/MyWindow

	; this will copy the contents of the st.seq. not to a usual file but
	; to a window !


	; ANYWAY... HERE IT IS....


START:	movem.l	d0-a6,-(a7)			; save all registers on stack


	; because we use commands in the DOSlibrary, we must find out where
	; this lib is, we use the 'openlib' command.

OPENDOSLIB:

	move.l	$4,a6				; 'openlib' is an EXEC routine
						; so load the startaddress of
						; the execlib.
	move.l	#doslibname,a1			; a1 must contain the address
						; where we typed the library's
						; name.
	jsr	-408(a6)			; now call the 'openlib' routy
	move.l	d0,dosbase			; The result is the base of
						; the specified library, or
	beq.s	error				; zero if it wasn't found.

	; at this point, we are ready to use the doslib-commands. Opening
	; a window now is nothing more than opening a file with the special
	; name 'CON:.....' (see top of source) Then you can 'WRITE' anything
	; to this window just like you would write it to a file, 

	; So you should now see that you could use the next routine to put
	; some text in  ANY file, so also one on disk or printer. Just 
	; change the filename to DF0:BLABLA or PRT: or anything you like.

OPEN:	; the dos-'OPEN' command is used to open a file. It needs 2 
	; parameters: d1 and d2

	move.l	#filename,d1			; address where the filename
						; is situated must be loaded
						; into d1
	move.l	#1006,d2			; d2 must contain the 'mode'
						; 1006 means 'open_old':
						; open an existing file for
						; reading.
						; 1005 means 'open_new':
						; open a new fiel for output
	move.l	dosbase,a6			; Load the base of the doslib
	jsr	-30(a6)				; Call routine at -30 in the
						; doslib. This is 'OPEN'

	move.l	d0,filehandle			; the result is the 'handle'
						; to this file. if it's zero,
						; some error ocurred, in that
	beq.w	error				; case goto the errorroutine


WRITE:	; the dos-'write' command needs 3 parameters: d1, d2 and d3...

	move.l	filehandle,d1			; d1 must contain the handle
						; of our file.
	move.l	#text,d2			; d2 must contain the address
						; where our data (text) is
						; located.
	move.l	#endoftext-text,d3		; d3 must contain the size of
						; the datablock, which is the
						; end-address minus the start-
						; address.
	move.l	dosbase,a6
	jsr	-48(a6)				; call the 'Write' command
	

DELAY:	; this command needs 1 parameter: d1

	move.l	#100,d1				; d1 is the time to delay.
						; time in seconds = value/50
						; for example move.l #100,d1
						; is same as wait 2 seconds.
	move.l	dosbase,a6
	jsr	-198(a6)			; call the 'delay' command.

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
filename:	dc.b	"RAW:0/0/200/100/test",0
text:		dc.b	"Yeah, this is just a simple TEST",10,0
endoftext:
		even		; force the next data to even boundary

dosbase:	dc.l	0
filehandle:	dc.l	0

