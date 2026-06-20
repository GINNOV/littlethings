
; Audio Example 2: Playing A Sample Once
;		   ~~~~~~~~~~~~~~~~~~~~~
; by M.Meany.

		include		source:include/hardware.i

Start		lea		$dff000,a5		hardware base

; Write sample parameters into hardware registers

		move.w		#64,AUD0VOL(a5)		set volume
		move.w		#$12c,AUD0PER(a5)	set period
		move.l		#SMP1,AUD0LCH(a5)	set new address
		move.w		#SMP1LEN,AUD0LEN(a5)	set new length

; Enable channel 0 DMA to start the sound playing.

		move.w		#SETIT!AUD0EN,DMACON(a5) start playing

; Clear audio channel 0's interrupt request bit

		move.w		#AUD0,INTREQ(a5)	clear outstanding

; Wait for DMA channel to request an interrupt

WaitL4		btst		#7,INTREQR+1(a5)	request yet?
		beq.s		WaitL4			no, so loop.

; Can now initialise quiet sample

		move.l		#NullSnd,AUD0LCH(a5)	set new address
		move.w		#NullLen,AUD0LEN(a5)	set new length

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
		
NullSnd		ds.w		50

NullLen		equ		50		word length
