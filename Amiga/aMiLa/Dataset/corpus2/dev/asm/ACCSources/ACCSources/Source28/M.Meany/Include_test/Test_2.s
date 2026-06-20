
; Test disk routines. Loads data from a file into a buffer!

		incdir		Source:Include/
		include		hardware.i
		include		Marks/Hardware/HW_Macros.i
		include		Marks/Hardware/HW_start.i
		include		Marks/Hardware/HW_disk.i

Main		btst		#6,CIAAPRA
		bne.s		Main

		lea		Fname,a0
		lea		Buffer,a1
		moveq.l		#100,d0
		bsr		LoadData
		tst.l		d0
		bne.s		.ok
		lea		errmsg,a0
		bsr		SetError
		
.ok		lea		Buffer,a0
		bsr		SetError
		
		rts

Fname		dc.b		'Source:M.Meany/Include_Test/test.txt',0
		even

Buffer		dc.b		'Mark'
		ds.b		100
		even
		
errmsg		dc.b		'Data not loaded',0
		even

