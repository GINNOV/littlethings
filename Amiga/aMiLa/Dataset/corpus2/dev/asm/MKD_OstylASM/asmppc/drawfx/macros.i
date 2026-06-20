**********************************************************************
**
**  MACROS
**
**  Révision:
**  1 juin 00
**
**********************************************************************

offset  SET     0

Plot16  MACRO
        Adde    r13,r13,r14
        Rlwimi  r10,r25,1,15,22
        Rlwimi  r10,r13,1,23,30
        Lhzx    r17,r10,r5

        Add     r25,r25,r26
        Adde    r13,r13,r14
        Rlwimi  r10,r25,1,15,22
        Rlwimi  r10,r13,1,23,30
        Lhzx    r18,r10,r5

        Add     r25,r25,r26
        Rlwimi  r18,r17,16,0,15

        IFNE    Transp
            Lwzu   r17,offset(r6)
            Add    r18,r18,r17
            Srwi   r18,r18,1
            Stw    r18,0(r6)
        ENDC

        IFNE    Blur
            Lwzu   r17,offset(r6)
            And    r17,r17,r19
            Srwi   r17,r17,1
            Add    r18,r18,r17
            Stw    r18,0(r6)
        ENDC

        IFEQ    Transp+Blur
            IFEQ   offset
            Stw     r18,offset(r6)
            ELSE
            Stwu    r18,offset(r6)
            ENDIF
        ENDC

offset  SET     4

        ENDM
