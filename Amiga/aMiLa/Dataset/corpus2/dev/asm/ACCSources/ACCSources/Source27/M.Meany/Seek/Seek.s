

; Example of using Seek() to move the file cursor into an open file to alter
;exsisting data. This example changes the name John to Mark in the temporary
;file created,'ram:text.doc1'.


		include		dos_start.i

Main		lea		MyVars,a4

; Create a file and write some text into it.

		move.l		#filename,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,handle(a4)
		beq		Error

		move.l		d0,d1
		move.l		#buffer,d2
		move.l		#buffer_len,d3
		CALLDOS		Write

; rewind back to the name

		move.l		handle(a4),d1
		moveq.l		#14,d2
		move.l		#OFFSET_BEGINNING,d3
		CALLDOS		Seek

; replace name with a new name

		move.l		handle(a4),d1
		move.l		#newname,d2
		move.l		#4,d3
		CALLDOS		Write

; Close the file

		move.l		handle(a4),d1
		CALLDOS		Close

; ReOpen the the file

		move.l		#filename,d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,handle(a4)
		beq		Error

; Read data back into memory

		move.l		d0,d1
		move.l		#buffer,d2
		move.l		#buffer_len,d3
		CALLDOS		Read

; Close the file

		move.l		handle(a4),d1
		CALLDOS		Close

; Print what was read from the file

		lea		buffer,a0
		bsr		DosMsg

; and exit

Error		rts


filename	dc.b		'ram:Text.doc1',0
		even
newname		dc.b		'Mark',0
		even
buffer		dc.b		'Programmed by John.',$0a,'or was it?',$0a
buffer_len	equ		*-buffer
		even 

		rsreset

handle		rs.l		1

varsSize	rs.b		0

		section		data,BSS
MyVars		ds.b		varsSize
