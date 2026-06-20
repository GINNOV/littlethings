
		incdir		Source:Include/
		include		hardware.i
		include		Marks/Hardware/hw_macros.i
		include		Marks/Hardware/hw_start.i

Main		

.wait		btst		#6,CIAAPRA
		bne.s		.wait

		rts

