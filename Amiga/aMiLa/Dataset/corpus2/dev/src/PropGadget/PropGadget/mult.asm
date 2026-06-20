;  Famines will not be stopped by LAKs carrying placards in parades;
;  famines will be stopped by engineers producing machines that make 
;  man more productive.                                             deTrebo
;
;           Jerry J. Trantow
;           1560 A East Irving Place
;           Milwaukee, Wi 53202-1460
;  8 Jan 89 Needed a 64 bit mult for Calculating Gadgetry
;  9 Jan 89 Not pretty, but it works
;  9 Jan 89 Started a 64 bit divide (div.asm)
; 14 Jan 89 Changed a,b to be passed by value
;
;   unsigned 32x32 bit multiple into a QUAD (64)
;
; Note that with an 020 these can be done in 1 or 2 instructions mulu.l, divu.l
; QUAD = |  16  |  16  |  16   |  16   |             
;                      |     al*bl     |
;               | ah*bl+al*bh  |
;        |    ah*bh    |

	IFD LATTICE
	  CSECT text
	  XDEF _QuadMult68000
	ELSE	 
          public	_QuadMult68000
	ENDC

_QuadMult68000:
        link	a5,#0
        movem.l	a2/d3/d4/d5/d6,-(sp)	; push registers on the stack
        clr.l   d3		; clear these for later
        clr.l   d4
        clr.l   d5
        clr.l   d6
        move.w	8(a5),d3	; high SHORT of a
        move.w  10(a5),d4	; low SHORT of a
        move.w	12(a5),d5	; high SHORT b
        move.w  14(a5),d6
        move.l	16(a5),a2	; points to c

        move.w	d4,d0	        ; al 	
        mulu.w  d6,d0	        ; bl*al
        move.l  d0,4(a2)	; c=bl*al   (Lowest 4 bytes of the QUAD)

        move.w  d4,d0	        ; al
        mulu.w  d5,d0	        ; al*bh
        move.l  d0,(a2)		; temp storage in high bytes of c
        
        move.w  d3,d0	        ; ah
        mulu.w  d6,d0	        ; bl*ah
        clr.l   d1		; Used with the carry
        add.l   (a2),d0		; al*bh+bl*ah

        bcc     .99
        move.l  #10000,d1	; save the carry
        
.99     move.l  d1,(a2)		; clear temp storage (propogate carry)
        add.l   d0,2(a2)	; c=(al*bh+bl*ah)*2^16 (Middle bytes of QUAD c)
        bcc     .777            ; another carry bit to worry about
        move.w  #1,(a2)		; carry was set

.777    move.w  d3,d0		; ah
        mulu.w  d5,d0		; bh*ah
        add.l   d0,(a2)		; c=(ah*bh)*2^32	(High bytes of QUAD c)

.98     movem.l	(sp)+,a2/d3/d4/d5/d6
        unlk	a5
        rts
        end
