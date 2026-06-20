
;Intelligent fade routine P.KENT
Fader

;d0 cur col,d1 dest col, returns: d0=faded value.

		CMP.W	D0,D1
		BEQ	FADER_DONE
        MOVEM.W D1-D6,-(SP)
        MOVE.W  D1,D2   ; d1-3 : dest values
        MOVE.W  D1,D3
        MOVE.W  D0,D4   ; d4-6 Init values
        MOVE.W  D0,D5
        MOVE.W  D0,D6
        AND.W   #15,D1  ; D1-3 B-G-R
        AND.W   #$00F0,D2
        AND.W   #$0F00,D3
        AND.W   #15,D4  ; d4-6 B-G-R
        AND.W   #$00F0,D5
        AND.W   #$0F00,D6
        CMP.W   D4,D1
        BCC.S   Blue_NOTdown
        SUBQ.W  #1,D4
Blue_NOTdown    CMP.W   D4,D1
        BLS.S   Blue_Fin
        ADDQ.W  #1,D4
Blue_Fin        CMP.W   D5,D2
        BCC.S   Green_NOTdown
        SUB.W   #$0010,D5
Green_NOTdown   CMP.W   D5,D2
        BLS.S   Green_Fin
        ADD.W   #$0010,D5
Green_Fin       CMP.W   D6,D3
        BCC.S   Red_NOTdown
        SUB.W   #$0100,D6
Red_NOTdown     CMP.W   D6,D3
        BLS.S   REd_FIn
        ADD.W   #$0100,D6
REd_FIn MOVE.W  D4,D0   ; -> d0 is finished value...
        OR.W    D5,D0
        OR.W    D6,D0
        MOVEM.W (SP)+,D1-D6

FADER_DONE		RTS
