; FILE: GG:src/own/awin/awsetlnnameinner.ASM          REV: 0 --- set ln_name
; LINK: >LEAVEOBJ>
; History
;  0      21st Dec 1998: started because of ppc cache probs.
;

; a0 = UBYTE ** tc_name
; a1 = UBYTE *name

_awsetlnnameinner68k:
	move.l	a1,(a0)
	rts
