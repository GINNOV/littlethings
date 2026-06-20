
; An example of using the DOS Seek() function to move about a file. The
;template for this function is:

;	distance = Seek( handle, distance, mode )
;	   d0		  d1        d2      d3

; distance	Seek() returns the number of bytes moved through the file
; handle	valid file handle as returned by Open()
; distance	number of bytes to move ( + or - allowed )
; mode		OFFSET_BEGINNING	move distance from start of file
;		OFFSET_CURRENT		move distance from current position
;		OFFSET_END		move distance from end of file

; The following example moves first to the end of a file, then to the
;beginning. The value returned by the second call to Seek() will be the
;size of the file! Use Monam to set a break point at label 'break' to see
;the result ( create the file ram:test.s first though!!! ).


		incdir		source:include/marks/
		include		mm_macros.i

Start		OPENDOS

		move.l		#filename,d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,d4			handle
		beq		quit_fast
		
		move.l		d4,d1
		move.l		#0,d2
		move.l		#1,d3			OFFSET_END
		CALLDOS		Seek
		
		move.l		d4,d1
		move.l		#0,d2
		move.l		#-1,d3			OFFSET_BEGINNING
		CALLDOS		Seek
		move.l		d0,d3			end of file
		
		move.l		d4,d1
		CALLDOS		Close

break		move.l		d3,d0			file length

quit_fast	CLEANUP		

		include		mm_subs.i


filename	dc.b		'ram:test.s',0
		even
