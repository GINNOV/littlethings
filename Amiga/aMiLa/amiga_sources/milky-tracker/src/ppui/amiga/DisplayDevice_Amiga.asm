; ------------------------------------------------------------------------------
; | Apollo AMMX blitting functions                                             |
; | Henryk Richter <henryk.richter@gmx.net>                                    |
; | All rights reserved                                                        |
; ------------------------------------------------------------------------------
;

	        xdef    _CopyRect_68080

	        machine	ac68080

            section .text,code

CONVHEAD8P	macro
            ; 8 pixels per loop + remaining pixels afterwards - change size to match
            ;
            ; 4 instructions, one Apollo cycle
            moveq	#-8,d5		; F $fffffff8
            and.l	d0,d5		; F clear lower 3 bits
            moveq	#7,d4		; F
            and.l	d4,d0		; F keep lower 3 bits
            sub.l	d0,d5		; total width - (0,1,2,3,...,7) -> simplifies loop
.yloop:
            move.l	d5,d0
.xloop:
            ble.s	.xleftover	; less than 4 pixels remaining ?
            endm

CONVMID8P	macro
            subq.l	#8,d0
            bra.s	.xloop
.xleftover:
            beq.s	.xnoleftover
            ;1...3 pixels left over (if width is not a multiple of 4
            endm

CONVEND8P	macro	            ; same as 4P

            addq.l	#1,d0
            bra.s	.xleftover	; leftover loop

.xnoleftover:			        ; end of x loop
            endm

CONVLINEEND	macro
            subq.l	#1,d1

            adda.l	d2,a0		;add skip values
            adda.l	d3,a1

            bne	    .yloop
            endm

_CopyRect_68080:
            movem.l	d4-d5,-(sp)

            CONVHEAD8P		    ; set up d5 (trash D0,D4 but D4 is useable now)

            load	(a0)+,E0    ; this doesn't copy more data per cycle than 68k version,
            store	E0,(a1)+    ; BUT! Less strain on the write buffers due to 64 Bit transfers

            CONVMID8P		    ; end of regular xloop

            move.b	(a0)+,(a1)+

            CONVEND8P		    ; end of leftover xloop
            CONVLINEEND		    ; y loop: advance a0/a1, loop if lines left

            movem.l	(sp)+,d4-d5
            rts

            end
