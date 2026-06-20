; mc0803.s					; count cmp on one scanline result in d1
; not on disk
; from Mark Wrobel course letter 24

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0803.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:
	clr.l d1				; clear d1

wait1:						; wait subroutine - waits 1/50th of a second
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#200,d0			; check if we reached line 200
	bne	wait1				; if not goto wait
                    
wait2:						; second wait - part of the wait subroutine
	addq.l  #1,d1			; increment d1 by 1
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	andi.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#201,d0			; check if we reached line 201
	bne	wait2				; if not goto wait2

	rts						; return from wait subroutine