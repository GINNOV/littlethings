
; Tests load file routine. File loaded is a copper list designed using
;Copper Writer by ARTWERKS, available from Amiganuts united.

		incdir		Source:Include/
		include		hardware.i
		include		Marks/Hardware/HW_Macros.i
		include		Marks/Hardware/HW_start.i
		include		Marks/Hardware/HW_disk.i

Main		lea		Fname,a0
		moveq.l		#CHIPMEM,d0
		bsr		LoadFile
		tst.l		d0
		bne.s		.ok

		lea		errmsg,a0
		bsr		SetError
		bra.s		.done

.ok		STARTCOP	a0
		move.w		#SETIT!DMAEN!COPEN,DMACON(a5)

.Wait		btst		#6,CIAAPRA
		bne.s		.Wait
		
.done		rts

Fname		dc.b		'Source:M.Meany/Gfx/Copper001',0
		even
		
errmsg		dc.b		'Error loading CopperList data file!',0
		even
