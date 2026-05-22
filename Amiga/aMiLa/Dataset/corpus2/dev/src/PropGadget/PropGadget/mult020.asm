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
; 19 Oct 89 Realized I had deleted my 020 mult routine, so I hacked this up 
;
;   unsigned 32x32 bit multiple into a QUAD (64)
;
	IFD LATTICE
	  CSECT text
	  XDEF _QuadMult020
	ELSE	
	 machine MC68020 
          public	_QuadMult020
	ENDC

_QuadMult020:
        link	a5,#0
    
 	move.l	8(a5),d0	; a
        move.l	16(a5),a0	; points to c 

	mulu.l	12(a5),d1:d0	; b * a
	move.l  d1,(a0)		; high long bytes
        move.l  d0,4(a0)	; low long bytes

        unlk	a5
        rts
        end
