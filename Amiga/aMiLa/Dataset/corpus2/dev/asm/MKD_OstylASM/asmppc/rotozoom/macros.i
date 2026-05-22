;---------------------------------------------------------
;---------------------------------------------------------

Wrt4Txl MACRO
        Add     r16,r12,\1          ; r16 = V,v | U,u
        Add     r17,r13,\1
        Add     r18,r14,\1
        Add     r19,r15,\1

        Rlwimi  r16,r16,8,8,16      ; r16 = V,U | u,?
        Rlwimi  r17,r17,8,8,16
        Rlwimi  r18,r18,8,8,16
        Rlwimi  r19,r19,8,8,16
        Rlwinm  r16,r16,32-16,16,31 ; r16 = 0,0 | V,U
        Rlwinm  r17,r17,32-16,16,31
        Rlwinm  r18,r18,32-16,16,31
        Rlwinm  r19,r19,32-16,16,31

        Lbzx    r16,r16,r4
        Lbzx    r17,r17,r4
        Lbzx    r18,r18,r4
        Lbzx    r19,r19,r4
        Rlwimi  r17,r16,8,15,15+8
        Rlwimi  r19,r18,8,15,15+8
        Rlwimi  r19,r17,16,0,15
        Stw     r19,WrtPos(r5)

WrtPos  SET     WrtPos+320
        ENDM

;---------------------------------------------------------
;---------------------------------------------------------

;WrtBfTxl   (tex ptr, tex ptr+256, coord16)

WrtBfTxl    MACRO
        Rlwinm  r24,\3,0,24,31      ;r24 = 0,0 | 0,u
        Rlwinm  r25,\3,16,24,31     ;r25 = 0,0 | 0,v
        Rlwimi  \3,\3,8,8,16        ;r?? = V,U | U,u
        Rlwinm  r27,\3,32-16,16,31  ;r27 = 0,0 | V,U
        Lhzx    r26,r27,\1          ;r26 = 0,0 | c1,c2
        Lhzx    r27,r27,\2          ;r27 = 0,0 | c4,c3
        Rlwimi  r26,r26,8,8,15      ;r26 = 0,c1 | 0,c2
        Rlwimi  r26,r26,16,16,23
        Rlwimi  r27,r27,8,8,15      ;r27 = 0,c4 | 0,c3
        Rlwimi  r27,r27,16,16,23
        Sub     r27,r27,r26         ;r27 = (c4-c1) | (c3-c2)
        Mullw   r27,r27,r25         ;r27 = (c4-c1)v | (c3-c2)v
        Srwi    r27,r27,8
        Add     r26,r27,r26         ;r26 = (c4-c1)v+c1 | (c3-c2)v+c2
        Rlwinm  r27,r26,16,24,31
        Andi.   r26,r26,$ff
        Sub     r26,r26,r27         ;r26 = RS-LS
        Mullw   r26,r26,r24         ;r26 = (RS-LS)u
        Srwi    r26,r26,8
        Add     r26,r26,r27         ;r26 = (RS-LS)u+LS
        ENDM
