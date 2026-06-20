;  An ill-favored thing, sir, but my own.
;  It is easier to be critical than correct.   Disraeli
;
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
	 XDEF _QuadDiv68000
	ELSE
         public	_QuadDiv68000
	ENDC

_QuadDiv68000:
        link	a5,#0
        movem.l	d2/d3/d5,-(sp)	; push registers on the stack

        move.l	8(a5),a0	; Points to Dividend  (64 bits)
        move.l  4(a0),d1	; lower 32 of Dividend
        move.l  (a0),d0         ; upper 32 of Dividend

        move.l	12(a5),d2       ; 32 bit divisor

        move.l  #64,d5          ; counter for 64 bit operation
 
        clr.l   d3              ; clear the test LONG WORD
        asl.l   #1,d1           ; move a bit into the test position
        roxl.l  #1,d0
        roxl.l  #1,d3

_divide cmp.l   d2,d3           ; is dividend > divisor        
        blt     _smallr

_largr  sub.l   d2,d3           ; dividend-=divisor
        ori.b   #16,CCR         ; Q0=1  (X Flag)
        bra     _shift

_smallr andi.b  #15,CCR         ; Q0=0  (X Flag)

_shift  roxl.l  #1,d1           ; shift Quotient into dividend
        roxl.l  #1,d0           ; shift Dividend into test position
        roxl.l  #1,d3

        subi.l  #1,d5           ; decrement the counter        
        bne     _divide

        move.l   d0,(a0)        ; put the Quotient where it belongs
        move.l   d1,4(a0)

.007    movem.l	(sp)+,d2/d3/d5
        unlk	a5
        rts
        end

