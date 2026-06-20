
; AMW = ArguMentWriter.

* This program is only made for one reason. To help learn a
* little assembler. When I started I couldn't find one single
* example that worked. And if they worked (sort of paradoxal but)
* they had either no comments or comments that MAYBE the coder of
* Myst or DirOpus 5.5 would understand. What the program does
* is that it takes your argument (whatever you write after the
* program name) and writes it out again with a little other text.
*
* If you have any questions or want me to make further examples
* feel free to write me a letter at:
* davsjo@algonet.se
* You can also visit my homepage at:
* http://www.algonet.se/~davsjo where there is an assemblerpage
* with some more examples.

; some includes for better readability.

		include	lvo/exec_lib.i
		include	lvo/dos_lib.i

		move.l	a0,_message	 get argument.
		move.l	d0,_message_SIZEOF	get size of argument

		cmpi.b	#'?',(a0)	was it a '?'

		beq	NOARG		then write the helptext

		cmpi	#1,d0		Is there an argument ?

		beq	NOARG		if not goto NOARG...

		jsr	OPENDOS		open the dos.library

		move.l	_DOSBase,a6	
		jsr	_LVOOutput(a6)	get standard output handle

		move.l	d0,_stdout	store returned value
		beq	CLOSELIB	did we get an output handle?

		lea	first(PC),a0	get first mess into a0
		move.l	a0,d2		move it to d2

; the reason we move it to a0 before moving it to d2 is because it
; will make the final .exe smaller.

		move.l	#firstend-start,d3	get size into d3
		move.l	_stdout,d1		get output handle

		move.l	_DOSBase,a6		base needed for Write
		jsr	_LVOWrite(a6)		Write message.


		move.l	_message_SIZEOF,d3	get argument into d3
		subq.l	#1,d3		decrease by 1 (linefeed)
		beq	CLOSELIB
		move.l	_stdout,d1	get output handle...
		move.l	_message,d2	get message into d2

		move.l	_DOSBase,a6	get dosbase to a6, again. 

; the reason we move _DOSBase into a6 so many times is since we dont
; know if the system will alter it while doing other stuff.

		jsr	_LVOWrite(a6)	write argument
		
		move.l	#linefeed,d2
		move.l	#linefeed_SIZEOF,d3
		move.l	_stdout,d1

		jsr	_LVOWrite(a6)	write a linefeed.

		bra	CLOSELIB

NOARG		jsr	OPENDOS

		move.l	_DOSBase,a6	get dosbase into a6
		jsr	_LVOOutput(a6)	get default output handle

		move.l	d0,_stdout	store returned value
		beq.s	CLOSELIB	did we get any output ?

		lea	noarg(PC),a0	get message to a0
		move.l	a0,d2		move message to d2.
		move.l	#noargend-noargbeg,d3	get size into d3
		move.l	_stdout,d1		get output handle

		jsr	_LVOWrite(a6)	write the message

CLOSELIB	move.l	_DOSBase,a1	base needed in a1
		move.l	4,a6		Execbase into a6
		jsr	_LVOCloseLibrary(a6)	Close dos.library

EXIT		moveq	#0,d0		clear d0 for O/S
		rts		logical end of program.

OPENDOS		lea	dos_name(PC),a1		get dos.library in a1
		move.l	4,a6		get Execbase into a6
		moveq	#0,d0		any version of dos.library will do
		jsr	_LVOOpenLibrary(a6)	open dos...

		move.l	d0,_DOSBase	store returned value
		beq	EXIT
		rts

; declarations and variables.

_DOSBase	ds.l	1
_stdout		ds.l	1
_message	ds.l	1
_message_SIZEOF	ds.l	1

dos_name	dc.b	'dos.library',0

start:
first		dc.b	'The argument you just wrote will soon show up below!',10
		dc.b	'(That is soon for the computer which is a few ms.)',10,10
firstend:
linefeed	dc.b	10
linefeed_SIZEOF	EQU	*-linefeed

noargbeg:
noarg		dc.b	10,'Write an argument and the program will write it out!',10,10
noargend:

; the last declaration will make the 'version' command work!

VerStr		dc.b	'$VER: Argumentwriter V1.04',0
		end
