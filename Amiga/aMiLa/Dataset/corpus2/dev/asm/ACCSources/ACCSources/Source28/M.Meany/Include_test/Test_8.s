
; Test the sample player and sample declaration macro.


		incdir		Source:Include/
		include		hardware.i
		include		Marks/Hardware/HW_Macros.i
		include		Marks/Hardware/HW_start.i
		include		Marks/Hardware/HW_Sound.i

Main		lea		Bang,a0			a0->sample
		moveq.l		#0,d0			d0=channel number
		bsr		DoSample

.wait		btst		#6,CIAAPRA
		bne.s		.wait

		rts
		
		section		sample,DATA_C

		incdir		Source:M.Meany/Gfx/

		SETSAMPLE	Bang,'bang.snd'



