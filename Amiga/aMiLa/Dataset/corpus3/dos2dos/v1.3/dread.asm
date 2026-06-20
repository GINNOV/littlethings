
DSKPTR: EQU     $DFF020
DSKLEN: EQU     $DFF024
FLAG:   EQU     $BFDD00
CIAA:   EQU     $BFE001
CIAB:   EQU     $BFD100
INTENAR: EQU    $DFF01C
INTENA: EQU     $DFF09A
INTREQ: EQU     $DFF09C
INTREQR: EQU    $DFF01E
BUFSIZ: EQU     16000
ADKCON: EQU     $DFF09E
ADKCONR: EQU    $DFF010

GO:     MOVE.B  #$7F,FLAG               ;TURN OFF ICR ENABLE MASK
        LEA     INT_STRUCT,A1           ;INT NODE
        MOVEQ   #$D,D0                  ;WHICH INTERRUPT
        MOVE.L  4,A6                    ;LIBRARY BASE
        JSR     -$A2(A6)                ;SET INTERRUPT VECTOR
        MOVE.W  #$2002,INTENA           ;TURN OFF DISK INTERRUPTS, IF ON
        MOVE.W  #$2002,INTREQ
;        MOVE.B  #$10,FLAG

* SELECT DF2 AND TURN ON ITS MOTOR

        MOVE.B  #-1,CIAB
        MOVE.B  #-1,CIAB
        MOVE.B  #-9,CIAB
        MOVE.B  #-1,CIAB
        MOVE.B  #-$11,CIAB
        MOVE.B  #-1,CIAB
        MOVE.B  #-$21,CIAB
        MOVE.B  #-1,CIAB
        MOVE.B  #-$41,CIAB

        MOVE.B  #-1,CIAB                ;START WITH ALL RESET
        MOVE.B  #$7F,CIAB               ;TURN ON MOTOR
        MOVE.B  #-$21,CIAB              ;SELECT DF2
        MOVE.L  #500000,D1              ;WAIT FOR MOTOR TO COME ON
        JSR     DELAY                   ;WAIT FOR A WHILE

* SET MFM, ETC.

        MOVE.W  #$600,ADKCON
        MOVE.W  #-$6F00,ADKCON

* SEEK DESIRED TRACK

        MOVE.B  #$5F,D0                 ;DF2 WITH MOTOR ON
        BSET    #2,D0                   ;SIDE 0
        BCLR    #1,D0                   ;TOWARD SPINDLE
        MOVE.B  D0,CIAB
        MOVE.B  D0,SAVE_D0              ;SAVE VALUE
        MOVEQ   #40,D2                  ;MAX OF 40 TRIES
1$:     BTST    #4,CIAA                 ;ON TRACK 0?
        BNE.S   2$                      ;NO...NO NEED TO GO FURTHER
        JSR     STEP                    ;ELSE MOVE AWAY FROM TRACK 0
        DBF     D2,1$                   ;LOOP FOR A WHILE
2$:     BSET    #1,SAVE_D0              ;NOW MOVE TOWARD EDGE
        MOVE.W  #100,D2                 ;MAX OF 100 STEPS
        BRA.S   3$
4$:     JSR     STEP                    ;STEP THE HEADS
3$:     BTST    #4,CIAA                 ;BACK TO TRACK 0?
        DBEQ    D2,4$                   ;NO...STEP AGAIN



* AT TRACK 0.  WAIT FOR INDEX MARK

        LEA     DSKBUF,A0               ;DISK BUFFER
        MOVE.L  A0,DSKPTR               ;SET UP DMA ADDRESS

INDEX:
        MOVE.B  #0,MARK_FLAG
 ;       MOVE.B  #$10,FLAG               ;CLEAR ANY PENDING INDEX MARK
        MOVE.B  FLAG,D0
        MOVE.W  #$2002,INTREQ           ;AND ANY PENDING DISK INTS
        MOVE.W  #$A000,INTENA           ;ENABLE INDEX MARK INTERRUPT
        MOVE.B  #$90,FLAG               ;ENABLE IN IRC MASK
2$:     MOVE.B  MARK_FLAG,D0
        BTST    #0,D0                   ;FOUND INDEX MARK?
        BEQ.S   2$                      ;NO

* LOOP TILL DSKBLK SHOWS END OF DMA TRANSFER

        MOVEQ   #0,D0
3$:     ADD.L   #1,D0
        MOVE.W  INTREQR,D1              ;DISK DONE YET?
        BTST    #1,D1
        BEQ     3$                      ;NO

* NOW SHUT DOWN THE DISK

        MOVE.W  #0,DSKLEN               ;TURN OFF THE DMA ENABLE BIT
        MOVE.W  #2,INTREQ               ;AND KILL THE DISK DONT INT REQ
        MOVE.B  #-1,CIAB                ;TURN OFF THE DRIVE
        MOVE.B  #-1,CIAB
        MOVE.B  #-$21,CIAB

* TRY TO DECODE THE TRACK DATA

FIND_TRACK_START:
        JSR     FIND_TRACK_ID
        JSR     DECODE_SECTOR
        RTS                             ;BACK TO AMIGADOS

* STEP THE HEADS

STEP:
        MOVE.B  SAVE_D0,D0              ;SAVED DISK SELECT, SIDE, DIRECTION
        LEA     CIAB,A1
        MOVE.B  D0,D1
        BCLR    #0,D0                   ;STEP BIT
        MOVE.B  D0,(A1)
        NOP
        NOP
        MOVE.B  D1,(A1)
        MOVE.L  #$2000,D1
        JSR     DELAY                   ;WAIT
        RTS

DELAY:
        DBF     D1,DELAY
        SUB.L   #$10000,D1
        BPL.S   DELAY
        RTS


INDEX_MARK:
        MOVE.W  #$2000,INTENA           ;DISABLE ANY MORE INTS
        MOVE.B  FLAG,D0                 ;CHECK IF IT IS THE CORRECT INT
        BTST    #4,D0
        BEQ     1$
        MOVE.W  #6250,D1                ;NUMBER OF WORDS PER TRACK?
        OR.W    #$8000,D1               ;THIS IS THE START BIT
        MOVE.W  D1,DSKLEN               ;THATS ONCE
        MOVE.W  D1,DSKLEN               ;AND THAT SHOULD START IT
        MOVE.B  #$10,FLAG               ;DISABLE INDEX MARK INT
        MOVE.B  #1,MARK_FLAG            ;SHOW WE FOUND MARK
1$:     MOVE.W  #$2000,INTREQ
        RTS


FIND_TRACK_ID:
         LEA     ABUF,A3
         MOVEQ   #0,D6
         MOVEQ   #0,D7
         MOVEQ   #0,D1
         MOVE.W  #12499,D0
         LEA     DSKBUF,A0
         BSR.L   TRACK_SYNC
         TST.W   D0
1$:      BMI.L   8$
2$:      MOVE.W  #6,D3
         MOVEM.L D0/A0,-(A7)
3$:      MOVE.B  (A2)+,D2
         CMP.B   (A0)+,D2
         BNE.L   15$
         SUBQ.W  #1,D0
         BMI.L   9$
         DBF     D3,3$
         TST.B   D1
         BEQ.S   4$
         MOVE.W  #-$100,D3
         LSR.W   D1,D3
         MOVE.B  (A0),D2
         AND.B   D3,D2
         CMP.B   (A2)+,D2
         BNE.L   15$
4$:      LEA     DSKBUF,A1
         MOVE.L  A0,D2
         SUB.L   A1,D2
         MOVE.W  D2,0(A3)
         MOVE.W  D2,8(A3)
         CLR.B   $C(A3)
         MOVE.W  #-1,$E(A3)
         CLR.W   $16(A3)
         LEA     TEXTBUF,A1
         MOVEM.L A0-A1,-(A7)
         BSR.L   COPY_TRACK_ID
         MOVEM.L (A7)+,A0-A1
         MOVEM.L A0-A2,-(A7)
         MOVE.W  #5,D2
         MOVEA.L A1,A0
         LEA     2(A3),A1
         BSR.L   TRACK_DECODE
         MOVEM.L (A7)+,A0-A2
         MOVEM.L (A7)+,D0/A0
5$:      BSR.L   TRACK_SYNC
         TST.W   D0
         BMI.L   11$
         MOVEM.L D0/A0,-(A7)
         MOVE.W  #5,D3
6$:      MOVE.B  (A2)+,D2
         CMP.B   (A0)+,D2
         BNE.L   12$
         SUBQ.W  #1,D0
         BMI.L   10$
         DBF     D3,6$
         ADDQ.L  #2,A2
         MOVE.B  (A2)+,D2
         CMP.B   (A0)+,D2
         BNE.L   14$
         SUBQ.W  #1,D0
         BMI.L   10$
         TST.B   D1
         BEQ.S   7$
         MOVE.W  #-$100,D3
         LSR.W   D1,D3
         MOVE.B  (A0)+,D2
         AND.B   D3,D2
         CMP.B   (A2)+,D2
         BNE.L   13$
         SUBQ.W  #1,D0
         BMI.L   10$
         MOVE.B  #-5,$C(A3)
7$:      MOVEM.L (A7)+,D0/A0
         SUBQ.L  #1,A0
         LEA     DSKBUF,A1
         MOVE.L  A0,D2
         SUB.L   A1,D2
         MOVE.W  D2,8(A3)
         MOVE.W  D1,$A(A3)
         RTS
9$:      ADDQ.L  #8,A7
8$:      CLR.W   0(A3)
         CLR.W   8(A3)
         RTS
10$:     ADDQ.L  #8,A7
11$:     CLR.W   $E(A3)
         CLR.W   $16(A3)
         RTS
12$:     MOVEM.L (A7)+,D0/A0
         BRA.L   5$
13$:     SUBQ.L  #1,A0
         SUBQ.L  #1,A2
14$:     SUBQ.L  #1,A0
         ADDQ.L  #1,A2
         MOVE.B  (A2)+,D2
         CMP.B   (A0)+,D2
         BNE.L   16$
         SUBQ.W  #1,D0
         BMI.S   10$
         TST.B   D1
         BEQ.S   7$
         MOVE.W  #-$100,D3
         LSR.W   D1,D3
         MOVE.B  (A0)+,D2
         AND.B   D3,D2
         CMP.B   (A2)+,D2
         BNE.S   16$
         SUBQ.W  #1,D0
         BMI.S   10$
         MOVE.B  #-8,$C(A3)
         BRA.S   7$
15$:     MOVEM.L (A7)+,D0/A0
         BSR.L   TRACK_SYNC
         TST.W   D0
         BMI.S   8$
         BRA.L   2$
16$:     ADDQ.L  #8,A7
         RTS



DECODE_SECTOR
         MOVEM.L D0-D3/A0-A2,-(A7)
         LEA     TEXTBUF,A1
         LEA     DSKBUF,A0
         ADDA.W  8(A3),A0
         MOVE.W  $A(A3),D1
         BSR.L   BLITTER_COPY
         LEA     TEXTBUF,A1
         MOVEA.L A1,A0
         LSR.W   #1,D1
         MOVE.W  D1,D2
         BSR.L   TRACK_DECODE
         MOVEM.L (A7)+,D0-D3/A0-A2
         RTS

TRACK_SYNC:
         LEA     TRACK_TABLE_5,A2
         MOVE.B  (A0)+,D7
         MOVE.B  TRACK_TABLE_1(D7.W),D6
         BNE.L   TS_1
         DBF     D0,*-$A
         RTS

TRACK_TABLE_1:
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,$55,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,$63,0,0,0,$39,0,0,0,0,0,0,0
        DC.B    0,0,$1D,0,1,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,$47,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,$2B,0,0,0,0,$F,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

TS_1:
         ADDA.W  D6,A2
         MOVE.B  TRACK_TABLE_2(D7.W),D1
         SUBQ.W  #1,D0
         RTS

TRACK_TABLE_2:
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0
        DC.B    0,0,5,0,7,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,4,0,0,0,0,0


TRACK_DECODE:
         MOVEQ   #0,D1
         LEA     TRACK_TABLE_3,A6
         LEA     TRACK_TABLE_4,A2
1$:      MOVE.B  (A0)+,D1
         MOVE.B  0(A6,D1.W),D0
         MOVE.B  (A0)+,D1
         OR.B    0(A2,D1.W),D0
         MOVE.B  D0,(A1)+
         DBF     D2,1$
         RTS


BLITTER_COPY:
        MOVE.W  #$40,INTENA             ;DISABLE BLITTER INTERRUPTS
        MOVE.W  #512,D2
        ADDQ.W  #6,D2
        LSL.W   #1,D2
        MOVE.W  #0,$DFF064
        TST.B   D1
        BEQ.S   BC_4
        MOVE.B  #8,D3
        SUB.B   D1,D3
        MOVE.B  D3,D1
        SUBQ.W  #2,A1
        ADDQ.W  #2,D2
        MOVE.L  A0,D3
        BTST    #0,D3
        BEQ.S   BC_2
        SUBQ.L  #1,A0
        BRA.S   BC_3
BC_2:   ADDQ.B  #8,D1
BC_3:   BRA.S   BC_5
BC_4:   MOVE.L  A0,D3
        BTST    #0,D3
        BEQ.S   BC_5
        SUBQ.L  #1,A0
        ADDQ.B  #8,D1
        SUBQ.W  #2,A1
        ADDQ.W  #2,D2
BC_5:   MOVE.L  A1,$DFF054
        MOVE.W  #0,$DFF066
        MOVE.L  A0,$DFF050
        MOVE.W  #0,$DFF042
        LSL.W   #8,D1
        LSL.W   #4,D1
        OR.W    #$9F0,D1
        MOVE.W  D1,$DFF040
        MOVE.W  D2,D1
        MOVE.W  #-1,$DFF044
        MOVE.W  #-1,$DFF046
        ADD.W   #$10,D2
        AND.W   #-$10,D2
        LSL.W   #2,D2
        OR.W    #8,D2
        MOVE.W  D2,$DFF058
        BSR.L   WAIT_BLITTER
        RTS


CALC_CRCC:
         MOVEA.L A4,A6
         ADDA.L  #$4C84,A6
         MOVE.L  A6,D4
         MOVEQ   #0,D5
CRCC_1:  MOVE.B  (A1)+,D5
         MOVEA.L D4,A6
         EOR.B   D6,D5
         ADDA.W  D5,A6
         MOVE.B  (A6),D6
         EOR.B   D7,D6
         MOVE.B  $100(A6),D7
         DBF     D2,CRCC_1
         RTS


COPY_TRACK_ID:
         MOVE.W  #$B,D3
         SUB.W   D3,D0
         TST.W   D1
         BEQ.S   CT2
         SUBQ.W  #1,D0
         MOVE.L  D0,-(A7)
         MOVE.B  #8,D0
         SUB.B   D1,D0
         MOVE.B  (A0)+,D2
         LSL.W   #8,D2
CT1:     MOVE.B  (A0)+,D2
         ROR.W   D0,D2
         MOVE.B  D2,(A1)+
         LSR.W   D1,D2
         DBF     D3,CT1
         MOVE.L  (A7)+,D0
         RTS
CT2:     MOVE.B  (A0)+,(A1)+
         DBF     D3,CT2
         RTS



WAIT_BLITTER:
         MOVE.W  INTREQR,D3
         BTST    #6,D3
         BEQ.S   WAIT_BLITTER
         MOVE.W  #$40,INTREQ
         RTS


ABUF:   DC.B   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


SAVE_D0:   DC.B 0                       ;SAVED DRIVE SELECT, SIDE, DIRECTION
MARK_FLAG: DC.B 0                       ;1=INDEX MARK FOUND, 0=NOT

TRACK_TABLE_3:
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $00,$10,$00,$10,$20,$30,$20,$30
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $40,$50,$40,$50,$60,$70,$60,$70
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $80,$90,$80,$90,$A0,$B0,$A0,$B0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0
        DC.B    $C0,$D0,$C0,$D0,$E0,$F0,$E0,$F0

TRACK_TABLE_4:
        DC.B    0,1,0,1,2,3,2,3,0,1,0,1,2,3,2,3
        DC.B    4,5,4,5,6,7,6,7,4,5,4,5,6,7,6,7
        DC.B    0,1,0,1,2,3,2,3,0,1,0,1,2,3,2,3
        DC.B    4,5,4,5,6,7,6,7,4,5,4,5,6,7,6,7
        DC.B    8,9,8,9,$A,$B,$A,$B,8,9,8,9,$A,$B,$A,$B
        DC.B    $C,$D,$C,$D,$E,$F,$E,$F,$C,$D,$C,$D,$E,$F,$E,$F
        DC.B    8,9,8,9,$A,$B,$A,$B,8,9,8,9,$A,$B,$A,$B
        DC.B    $C,$D,$C,$D,$E,$F,$E,$F,$C,$D,$C,$D,$E,$F,$E,$F
        DC.B    0,1,0,1,2,3,2,3,0,1,0,1,2,3,2,3
        DC.B    4,5,4,5,6,7,6,7,4,5,4,5,6,7,6,7
        DC.B    0,1,0,1,2,3,2,3,0,1,0,1,2,3,2,3
        DC.B    4,5,4,5,6,7,6,7,4,5,4,5,6,7,6,7
        DC.B    8,9,8,9,$A,$B,$A,$B,8,9,8,9,$A,$B,$A,$B
        DC.B    $C,$D,$C,$D,$E,$F,$E,$F,$C,$D,$C,$D,$E,$F,$E,$F
        DC.B    8,9,8,9,$A,$B,$A,$B,8,9,8,9,$A,$B,$A,$B
        DC.B    $C,$D,$C,$D,$E,$F,$E,$F,$C,$D,$C,$D,$E,$F,$E,$F

TRACK_TABLE_5:
        DC.B    $54,$89,$12,$89,$12,$89,$12,$AA,$A8,$AA,$8A,$AA,$94,00
        DC.B    $A9,$12,$25,$12,$25,$12,$25,$55,$50,$55,$14,$55,$28,00
        DC.B    $52,$24,$4A,$24,$4A,$24,$4A,$AA,$A0,$AA,$28,$AA,$50,00
        DC.B    $A4,$48,$94,$48,$94,$48,$95,$55,$40,$54,$50,$54,$A0,00
        DC.B    $48,$91,$28,$91,$28,$91,$2A,$AA,$80,$A8,$A0,$A9,$40,00
        DC.B    $91,$22,$51,$22,$51,$22,$55,$55,$00,$51,$40,$52,$80,00
        DC.B    $22,$44,$A2,$44,$A2,$44,$AA,$AA,$00,$A2,$80,$A5,$00,00
        DC.B    $44,$89,$44,$89,$44,$89,$55,$54,$00,$45,$00,$4A,$00,00

        CNOP   0,4

INT_STRUCT:
        DS.B    8                       ;LINKAGE
        DC.B    2                       ;NODE TYPE = INTERRUPT
        DC.B    $7F                     ;PRIORITY
        DC.L    NODE_NAME
        DC.L    GO                      ;DATA SEGMENT
        DC.L    INDEX_MARK              ;VECTOR

NODE_NAME: DC.B   'D2D',0

        CNOP    0,4
  
DSKBUF: DCB.B  BUFSIZ,0                 ;RESERVE DISK DATA BUFFER


TEXTBUF: DCB.B  BUFSIZ,0                ;CONVERTED DATA BUFFER
        END


