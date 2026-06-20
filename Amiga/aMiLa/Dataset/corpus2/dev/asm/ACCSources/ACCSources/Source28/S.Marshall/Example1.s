
; Audio Example 1: Playing A Sample Once
;		   ~~~~~~~~~~~~~~~~~~~~~
; by M.Meany. - Modified by Steve Marshall to show an easier way
;		of doing basically the same thing.

		include		source:include/hardware.i

Start		lea		$dff000,a5		hardware base

; Write sample parameters into hardware registers

		move.w		#64,AUD0VOL(a5)		set volume
		move.w		#$12c,AUD0PER(a5)	set period
		move.l		#SMP1,AUD0LCH(a5)	set new address
		move.w		#SMP1LEN,AUD0LEN(a5)	set new length

; Enable channel 0 DMA to start the sound playing.

		move.w		#SETIT!AUD0EN,DMACON(a5) start playing

		move.w		#1,AUD0LEN(a5)		set new length

; Wait for mouse to be pressed

Mouse		btst		#6,CIAAPRA
		bne.s		Mouse


; All done. Kill channel 0 DMA incase it's still playing!

		move.w		#AUD0EN,DMACON(a5)	quiet!

		rts					go home

*****************************************************************************

		section		sounds,DATA_C

SMP1		dc.w		0
		incbin		monobass	sample itself
SMP1LEN		equ		(*-SMP1)>>1	word length

