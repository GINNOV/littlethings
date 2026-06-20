
; Audio Example 1: Playing A Sample
;		   ~~~~~~~~~~~~~~~~
; by M.Meany.

		include		source:include/hardware.i

Start		lea		$dff000,a5		hardware base

; Write sample parameters into hardware registers

		move.l		#SMP1,AUD0LCH(a5)	set new address
		move.w		#SMP1LEN,AUD0LEN(a5)	set new length
		move.w		#64,AUD0VOL(a5)		set volume
		move.w		#$12c,AUD0PER(a5)	set period

; Enable channel 0 DMA to start the sound playing.

		move.w		#SETIT!AUD0EN,DMACON(a5) start playing

; Wait for mouse to be pressed

Mouse		btst		#6,CIAAPRA
		bne.s		Mouse


; All done. Kill channel 0 DMA incase it's still playing!

		move.w		#AUD0EN,DMACON(a5)	quiet!

		rts					go home

*****************************************************************************

		section		sounds,DATA_C

SMP1		incbin		shot.snd	sample itself
SMP1LEN		equ		(*-SMP1)>>1	word length
		
	
