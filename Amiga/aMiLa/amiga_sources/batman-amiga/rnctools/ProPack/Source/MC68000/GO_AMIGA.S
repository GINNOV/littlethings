;------------------------------------------------------------------------------
; Routine to execute a loaded RNC packed AmigaDos file (file type option "a")
; On entry,
;       A0.L = start address of packed file (must be on a long word boundary)
;
; Note: the original unpacked file must contain only one code hunk
;------------------------------------------------------------------------------
go_amiga
		move.l	32(a0),d0	; length of unpack code (long words)
		add.l	d0,d0
		add.l	d0,d0
        lea     44(a0,d0.l),a1
		clr.l	(a1)		; (a1+4) = ultimate destination address
		move.l	a1,d0		; of unpacked code. This is the address
		lsr.l	#2,d0		; the unpacker jumps to after the file
		move.l	d0,32(a0)	; has been unpacked.
        jmp     36(a0)      ; unpack then jump to exec address

