; mc1102.s						; print
; from disk1/brev10
; explanation on letter_11 p. 09
; explanation in MW_series 32	
	
; WinUAE: additional settings for printing
; IO Ports/Parallel Port/
; Printer: Microsoft XPS Document Writer
; Type:    Epson Matrix Printer Emulation, 48Pin

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1102.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j		

; after execution: save the printfile (XPS-Document) and open with a XPS-Viewer

start:							; comments from Mark Wrobel
	lea.l	buffer,a0			; store address of buffer into a0

	move.w	#$4000,$dff09a		; INTENA clear master interrupt
	bsr	print					; branch to subroutine print
	move.w	#$c000,$dff09a		; INTENA set master interrupt

	rts							; return from subroutine

buffer:							; label for the buffer
	dc.b	"Dette er en test av en printer-rutine.",10  ; text to be printed with added linefeed
	dc.b	0                                            ; null termination of the string


print:							; label for the print subroutine
	move.b	#$ff,$bfe301		; ddrb set all pins to output for the parallel port prb

wait:
	move.b	$bfd000,d0			; move data in pra into d0
	andi.b	#%111,d0			; only keep 3 first bits in d0 - control lines SEL, POUT, BUSY
	cmp.b	#%100,d0			; compare 4 with d0 - SEL=1, POUT=0, BUSY=0
	beq.s	ready				; if equal, goto label ready
	cmp.b	#%001,d0			; compare 1 with d0 - SEL=0, POUT=0, BUSY=1
	beq.s	offline				; if equal, goto label offline 
	cmp.b	#%111,d0			; compare 7 with d0 - SEL=1, POUT=1, BUSY=1
	beq.s	poweroff			; if all bits are set high, goto subroutine poweroff
	cmp.b	#%001,d0			; compare 1 with d0 - SEL=0, POUT=0, BUSY=1
	beq.s	wait				; if equal, goto label wait
	cmp.b	#%011,d0			; compare 3 with d0 - SEL=0, POUT=1, BUSY=1
	beq.s	paperout			; if equal, goto label paperout
	bra.s	wait				; branch always to wait

ready:							; label
	move.b	(a0)+,d0			; move value a0 points to into d0 and then increment a0 by a byte
	cmp.b	#0,d0				; compare 0 with d0 - we could use tst here
	beq.s	stop				; if the zero termination of the string is reached then goto stop
	move.b	d0,$bfe101			; move value in d0 into the parallel port prb
	bra.s	wait				; goto wait

stop:							; label
	moveq	#0,d0				; move quick 0 into d0
	rts							; return from subroutine

poweroff:						; label
	moveq	#1,d0				; move quick 1 into d0
	rts							; return from subroutine

offline:						; label
	moveq	#2,d0				; move quick 2 into d0
	rts							; return from subroutine

paperout:						; label
	moveq	#3,d0				; move quick 3 into d0
	rts							; return from subroutine
	
	end
	
