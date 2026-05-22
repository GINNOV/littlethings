
	; this is the first source on the disk...
	; (exciting isn't it?)
	; (as you see, the lines with ; or * are not assembled)
	; this source contains 74 lines, of which only 6 lines are
	; code. That's super documentation or what ?!!??!!


	; when you run this source (j), Amiga will wait for you to
	; press the left mousebutton. If you do, the program ends
	; (rts) and seka will tell you the contents of the various
	; dataregisters. Something like this:

; D0=00000000 00000000 00000000 00000000  .... 00000000
; A0=00000000 00000000	....		....   00c1c2bc
;SSP=00c1d24a ...	....

; the first row represents the different dataregisters (D0... D7)
; the second row the addresregs, A0-A7. See the last one in line 2 ?
; this is the stackpointer (a7) (=USP, user stack pointer)
; the last line are some more special pointers, like the supervisor-
; stack pointer, program counter,...

*************************

top:			; this is a label
			; after assembling, it is replaced by a number,
			; an address in memory. All other references in 
			; this source to 'top' are replaced by this number
			; as well. try '@dtop' which means 'disassemble
			; from label top'
			; After assembling, type  '?top'  (=print the value
			; which corresponds with our label top) and you
			; will see what address TOP stands for.

	movem.l	d0-d7/a0-a6,-(a7)	; save the registers !!!
					; see letter

loop:	btst	#6,$bfe001	; this instruction checks the
				; 6th bit in addres $bfe001.
				; this is the left mousebutton.

	bne.s	loop		; if the 6th bit in $bfe001 is set,
				; (not equal to zero), then go to
				; label 'loop' (else: just go on)

	movem.l	(a7)+,d0-d7/a0-a6	; reload the saved registers

	rts				; and go back to the routine
					; who called this subroutine
*************************		; (the 'higher level')
					; since there is no higher
					; level in this case, the 
					; program is finished, and 
					; returns back to Seka or
					; to CLI

	; please have a try and type 'dtop' after you assembled the
	; program. You'll see that each instruction is put on a 
	; certain address, and instead of 'bne.s label', there will
	; be an address, something like 'bne.s $2c043'
	; also note that each command starts at an EVEN address.

	; note: the '.s' after the BNE means that it is a very small
	;	branch. This will result in a slightly shorter and
	;	faster code. (just for fun)

