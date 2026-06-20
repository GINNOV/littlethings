;  There is not a man that lives, who hath not known his god-like hours.
;                                                              Wordsworth
;           Jerry J. Trantow
;           1560 A East Irving Place
;           Milwaukee, Wi 53202-1460
; written especially for Gadget calculation where result is always 32 bits
; 12 Jan 89 Now does a 64/32 with a 64 bit result
; 12 Jan 89 64 bit Quotient gets returned in the Dividend
; 14 Jan 89 passes divisor by value
; 15 Jan 89 Used Andi, ori to set X Flag
; 24 Jan 89 Division by 2^31 or larger doesn't seem to work
;  1 Feb 89 Implemented a 64/32 = 32 bit Quotient Division
;           NOTE : ONLY USE THE LOWER ULONG i.e. ONLY A 32 bit Quotient
; 
	IFD LATTICE
	 CSECT text
	 XDEF _QuadDiv020
	ELSE
         machine MC68020
         public	_QuadDiv020
	ENDC
 
_QuadDiv020:
        link	a5,#0
        movem.l	d2/d3/d5,-(sp)	; push registers on the stack

        move.l	8(a5),a0	; Points to Dividend  (64 bits)
        move.l  (a0),d0		; High ULONG of Quad
        move.l  4(a0),d1	; Low ULONG of Quad

        divu.l	12(a5),d0:d1	
;       move.l  d0,(a0)		; put Remainder in High ULONG of QUAD
        move.l  d1,4(a0)	; puts Quotient in Low ULONG of QUAD

        movem.l	(sp)+,d2/d3/d5
        unlk	a5
        rts
        end

