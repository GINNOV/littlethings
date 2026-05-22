;           Jerry J. Trantow
;           1560 A East Irving Place
;           Milwaukee, Wi 53202-1460

	IFD LATTICE
	  CSECT text
	  XDEF _QuadAdd
	ELSE	 
          public	_QuadAdd
	ENDC

_QuadAdd:
        link	a5,#0
;        movem.l	.3,-(sp)	; push registers on the stack

        move.l  8(a5),d0	; value of addend
        move.l  12(a5),a0	; address of the Quad

        clr.l   d1
        add.l   d0,4(a0)	; LOW ULONG = addend + LOWER ULONG
        move.l  (a0),d0
        addx.l  d1,d0		; extend the carry
        move.l  d0,(a0)		; HIGH ULONG = LOW ULONG + eXtend

.98     unlk	a5
        rts
        end
