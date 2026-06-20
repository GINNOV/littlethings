
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
		beq.s		.ok

		lea		Fname1,a0
		move.l		#ANYMEM,d0
		bsr		LoadFile
		tst.l		d0
		beq.s		.ok

		move.l		a0,a1
		lea		Fname2,a0
		bsr		SaveData
		tst.l		d0
		beq.s		.ok

		lea		okmsg,a0
		bsr		SetError
				
.ok		lea		errmsg,a0
		bsr		SetError
		
		rts

Fname		dc.b		'Source:M.Meany/Include_Test/test.txt',0
		even

Fname1		dc.b		'Source:Include/Marks/Hardware/HW_Memory.i',0
		even

Fname2		dc.b		'Source:memory_copy.i',0
		even

Buffer		dc.b		'Mark'
		ds.b		100
		even
		
errmsg		dc.b		'Data not loaded',0
		even

okmsg		dc.b		'Everything OK.',0
		even


