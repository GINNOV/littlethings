
; This program demonstrates the use of Nico Francois Powerpacker.library. A 
;text file crunched by PowerPacker is decrunched and displayed in the calling
;CLI window.

; Thanks to Nico for putting such a useful library into the Public Domain.

; This source by M.Meany, Jan 1990, for Devpac II.

; IMPORTANT --- Do not try to run this from the Workbench....IT WILL CRASH !


		incdir		sys:include/
		include		exec/types.i
		include		exec/exec_lib.i
		include		libraries/dos.i
		include		libraries/dos_lib.i
		incdir		source9:include/
		include		misc/ppbase.i
		include		misc/powerpacker_lib.i

;--------------	First a macro that simplifies calling Nico's library.
		
CALLNICO	macro
		move.l		_PPBase,a6
		jsr		_LVO\1(a6)
		endm
		
;-------------- Now the code. Start by opening Nico's library.

		lea		PPName,a1		a1->library name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open the library
		move.l		d0,_PPBase		save base pointer
		beq		error			leave if no library

;-------------- Open DOS library.

		lea		dosname,a1		a1->library name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open the library
		move.l		d0,_DOSBase		save base pointer
		beq.s		error1			leave if no library

;--------------	Decrunch file to a buffer.

		lea		filename,a0		a0->name of loadfile
		moveq.l		#DECR_POINTER,d0	d0=decrunch options
		moveq.l		#0,d1			d1=public memory
		lea		buffer,a1	      a1->space for buf addr
		lea		length,a2		a2->space for len
		move.l		d1,a3			a3=> no password
		CALLNICO	ppLoadData		load the file
		tst.l		d0			test for error
		bne.s		error2			leave if found
		
;--------------	Get CLI handle and output text.

		CALLDOS		Output			get STD_OUT
		
		move.l		d0,d1			d0=output handle
		move.l		buffer,d2		d1=addr of buffer
		move.l		length,d3		d3=length of buffer
		CALLDOS		Write			print it
		
;--------------	Free memory used for text buffers.

		move.l		buffer,a1		a1->buffer
		move.l		length,d0		d0=length of buffer
		CALLEXEC	FreeMem			release memory
		
;--------------	Close the DOS library.

error2		move.l		_DOSBase,a1		a1->lib base
		CALLEXEC	CloseLibrary		close the lib
		
;--------------	Close PP library.
		
error1		move.l		_PPBase,a1		a1->lib base
		CALLEXEC	CloseLibrary		close the lib

;--------------	Finish !

error		rts					leave !


;--------------	Data ( very boring ) area.

PPName		PPNAME
		even
_PPBase		dc.l		0

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

filename	dc.b		'df1:readme',0
		even

buffer		dc.l		0		space to store ptr to buffer
length		dc.l		0		space to store buffer length

