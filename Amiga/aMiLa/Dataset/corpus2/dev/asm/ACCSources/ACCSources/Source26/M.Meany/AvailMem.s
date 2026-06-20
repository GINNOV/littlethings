
		***********************************************
		* Utility to display free memory from the CLI *
		*			by M.Meany, July 1992 *
		***********************************************

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		libraries/dos_lib.i

; Open DOS library

Start		lea		dosname,a1	library name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save pointer
		beq		Error		exit if none

; Get output stream

		CALLDOS		Output		get stream
		move.l		d0,std_out	save handle

		lea		DStream,a2	a2->storage buffer
		moveq.l		#10,d3		2^10 = 1024

; CHIP Memory - largest

		move.l		#MEMF_CHIP!MEMF_LARGEST,d1	CHIP mem
		CALLEXEC	AvailMem	get size
		move.l		d0,(a2)+	save result

		asr.l		d3,d0		/1024 for Kb size
		move.l		d0,(a2)+	and save

; CHIP Memory - total

		moveq.l		#MEMF_CHIP,d1	CHIP mem
		CALLEXEC	AvailMem	get size
		move.l		d0,(a2)+	save result

		asr.l		d3,d0		/1024 for Kb size
		move.l		d0,(a2)+	and save

; FAST Memory - largest

		move.l		#MEMF_FAST!MEMF_LARGEST,d1	FAST memory
		CALLEXEC	AvailMem	get size
		move.l		d0,(a2)+	save result

		asr.l		d3,d0		/1024 for Kb size
		move.l		d0,(a2)+	and save

; FAST Memory - total

		moveq.l		#MEMF_FAST,d1	FAST memory
		CALLEXEC	AvailMem	get size
		move.l		d0,(a2)+	save result

		asr.l		d3,d0		/1024 for Kb size
		move.l		d0,(a2)+	and save

; Total Memory

		moveq.l		#0,d1		any
		CALLEXEC	AvailMem	get size
		move.l		d0,(a2)+	save result

		asr.l		d3,d0		/1024 for Kb size
		move.l		d0,(a2)		and save

; Build output text in buffer, RawDoFmt() does all the hard work :-)

		lea		template,a0	C type format string
		lea		DStream,a1	data to be inserted
		lea		PutChar,a2	subroutine address
		lea		DBuffer,a3	buffer for text
		CALLEXEC	RawDoFmt	build text

; Now print the results

		lea		DBuffer,a0	a0->text
		bsr.s		DosMsg		write it

; Close DOS
		move.l		_DOSBase,a1	base pointer
		CALLEXEC	CloseLibrary	and close DOS

; Finish

Error		moveq.l		#0,d0		no script errors
		rts				back to the CLI

		************************************************
		* Subroutine called by RawDoFmt() as suggested *
		*         in RKM Includes and Autodocs         *
		************************************************

PutChar		move.b		d0,(a3)+	copy byte into buffer
		rts

		**********************************************
		* Subroutine to write NULL terminated string *
		* to an open stream ( con:, prt:, file etc ) *
		**********************************************

; Entry		a0 must hold address of 0 terminated string.
;		std_out should hold handle of output stream.
;		DOS library must be open

; Corrupt	none

DosMsg		movem.l		d0-d3/a0-a3,-(sp) save registers

		tst.l		std_out		is stream available ?
		beq		error		quit if not

		move.l		a0,a1		get a working copy

; Determine length of string

		moveq.l		#-1,d3		reset counter
loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		loop		if not loop back

; Make sure there was a string

		tst.l		d3		was there a string ?
		beq.s		error		if not, graceful exit

; Get handle of output stream

		move.l		std_out,d1	d1= handle
		beq.s		error		leave if no handle

; Now print the string

		move.l		a0,d2		d2=address of string
		CALLDOS		Write		output it

;--------------	All done so finish

error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts

		*************************************
		* Text strings used by this utility *
		*************************************

dosname		dc.b	'dos.library',0
		even

template	dc.b	'Memory Displayer by M.Meany.',$0a,$0a

		dc.b	"'CHIP' Memory",$0a
		dc.b	'~~~~~~~~~~~~~ Largest : %ld bytes ( %ld K ).',$0a
		dc.b	'              Total   : %ld bytes ( %ld K ).',$0a
		dc.b	$0a

		dc.b	"'FAST' Memory",$0a
		dc.b	'~~~~~~~~~~~~~ Largest : %ld bytes ( %ld K ).',$0a
		dc.b	'              Total   : %ld bytes ( %ld K ).',$0a
		dc.b	$0a

		dc.b	'Total Available Memory: %ld bytes ( %ld K ).',$0a
		dc.b	$0a
		
		dc.b	0
		even

		dc.b	'$VER: ShowMem v1.00'
		even

		*********************************
		* Data storage area for utility *
		*********************************

		section		dat,BSS

_DOSBase	ds.l		1

std_out		ds.l		1

DStream		ds.l		10

DBuffer		ds.b		320
