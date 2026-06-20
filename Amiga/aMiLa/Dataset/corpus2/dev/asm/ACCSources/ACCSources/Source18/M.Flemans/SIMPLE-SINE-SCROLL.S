***
***      SIMPLE SINE SCROLLER PROGRAM
***
***      CODES BY MARK FLEMANS
***
***      DATE 22.10.91
***

         SECTION sine_scroller,CODE_C  ; CHIP MEMORY PLEASE
         OPT C-                        ; NO CASE SENSITIVITY

**************************************************************************
*   START OF MY CODE
**************************************************************************

BEG:     MOVEM.L   D0-D7/A0-A6,-(SP)   ; SAVE REGISTERS
         MOVE.L    4,A6                ; GET EXEC BASE
         JSR       -132(A6)            ; NO MULTI-TASKING

         MOVE.L    #PLANE2,D0          ; FIND MY TEXT PLANE
         MOVE.W    D0,PL1L             ; SET LOW VALUE
         SWAP      D0                  ; NEXT WORD
         MOVE.W    D0,PL1H             ; SET HIGH VALUE

         MOVE.L    4,A6                ; GET EXEC BASE
         MOVEQ     #0,D0               ; ANY VERSION
         LEA       GFXNAM(PC),A1       ; POINT TO NAME OF LIBRARY
         JSR       -552(A6)            ; OPEN LIBRARY
         MOVE.L    D0,GFXBSE           ; STORE ITS BASE
         MOVE.L    GFXBSE,A1           ; GET ADDRESS
         MOVE.L    38(A1),OLDCOP       ; STORE OLD COPPERLIST
         MOVE.L    #NEWCOP,$DFF080     ; INSERT NEW COPPERLIST
         MOVE.W    #$0020,$DFF096      ; SPRITE DMA ENABLE
         MOVE.W    #8,COUNT            ; SET SCROLL TEXT COUNT
         MOVE.L    $6C,OLDIRQ+2        ; STORE PRESENT IRQ 
         MOVE.L    #NEWIRQ,$6C         ; INSERT NEW IRQ

.LOOP    BTST      #6,$BFE001          ; WAIT FOR LEFT MOUSE BUTTON
         BNE       .LOOP               ; NO, OK I`LL WAIT

         MOVE.L    OLDIRQ+2,$6C        ; RESTORE OLD IRQ
         MOVE.W    #$8020,$DFF096      ; RESTORE SPRITE DMA
         MOVE.L    OLDCOP,$DFF080      ; RESTORE OLD COPPER LIST
         MOVE.L    4,A6                ; GET EXEC BASE
         MOVE.L    GFXBSE,A1           ; POINT TO NAME OF LIBRARY
         JSR       -414(A6)            ; CLOSE LIBRARY
         MOVE.L    4,A6
         JSR       -138(A6)            ; ENABLE MULTI-TASKING
         MOVEM.L   (SP)+,D0-D7/A0-A6   ; RESTORE REGISTERS
MAINEND: MOVEQ     #0,D0               ; NO CLI ERROR
         RTS                           ; BYE / QUIT !!

**************************************************************************
*   VARIABLE STORES
**************************************************************************

OLDCOP:  DC.L      $0000
GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $0000
CFLAG:   DC.B      $0000
         EVEN
HANGOVR: DCB.B     42*10,0
PLANE1:  DCB.B     42*60,0
         EVEN
PLANE2:  DCB.B     42*60,0
         EVEN
TEXT:    DC.B      "   MINI SINE WAVE .... CODED BY FIXX   "
         DC.B      "WELL, HERE IT IS MY FIRST SINE-SCROLLER."
         DC.B      " GREETINGZ FLY OUT TO .... MARK , MIKE ,"
         DC.B      " NEIL , RAISTLIN , TREEBEARD , BLAINE , "
         DC.B      " DAVE , TREVOR , NIPPER AND "
         DC.B      "EVERYBODY ELSE WHO I CAN'T REMEMBER AT "
         DC.B      "THE MOMENT. ANYHOW CU L8R               "
         DC.B      0
         EVEN
TXTPTR:  DC.L      TEXT
COUNT:   DC.W      $0000
         EVEN

NEWIRQ:  MOVEM.L   A0-A6/D0-D7,-(SP)
         BSR       SCROLL
         BSR       SINE
         MOVEM.L   (SP)+,A0-A6/D0-D7
OLDIRQ:  JMP       $0000

**************************************************************************
*   SINE ROUTINE
**************************************************************************

SINE:    LEA       PLANE1,A0           ; GET START PLANE ADDRESS
         LEA       PLANE2,A1           ; GET DESTINATION PLANE ADDRESS
         LEA       $DFF000,A5          ; GET CUSTOM CHIP ADDRESS
         SUB.L     #2,A0               ; DONE TO REMOVE OFFSET
         SUB.L     #2,A1
         MOVE.L    A1,A2
         MOVEQ     #20,D1              ; NUMBER OF WORDS TO BLIT
PN:      ADD.W     #2,A0
         ADD.W     #2,A2
         MOVE.L    A2,A1

         BSR       DOWAVE              ; GET SINE VALUE AND CALCULATE

         MOVE.L    A0,$50(A5)          ; SET SOURCE A ADDRESS
         MOVE.L    A1,$54(A5)          ; SET SOURCE D (DESTINATION) ADDRESS
         MOVE.L    #$FF00FF00,$44(A5)  ; SET BLITTER MASK
         MOVE.W    #40,$64(A5)         ; SET SOURCE A MODULO
         MOVE.W    #40,$66(A5)         ; SET SOURCE D (DESTINATION) MODULO
         MOVE.W    #$09F0,$40(A5)      ; SET BLITTER CONTROL 0
         CLR.W     $42(A5)             ; CLEAR BLITTER CONTROL 1
         MOVE.W    #(23*64)+1,$58(A5)  ; DO BLIT (23 HIGH BY 1 WORD)

.LOOP    BTST      #14,$02(A5)         ; IS BLITTER FINISHED ?
         BNE       .LOOP               ; NO, OK WAIT TILL IT IS 

         BSR       DOWAVE              ; GET SINE VALUE AND CALCULATE

         MOVE.L    A0,$50(A5)          ; SET SOURCE A ADDRESS
         MOVE.L    A1,$54(A5)          ; SET SOURCE D (DESTINATION) ADDRESS
         MOVE.L    A1,$4C(A5)          ; SET SOURCE B ADDRESS ( PREV BLIT )
         MOVE.L    #$00FF00FF,$44(A5)  ; SET BLITTER MASK
         MOVE.W    #40,$64(A5)         ; SET SOURCE A MODULO
         MOVE.W    #40,$66(A5)         ; SET SOURCE D (DESTINATION) MODULO
         MOVE.W    #40,$62(A5)         ; SET SOURCE B MODULO
         MOVE.W    #$0DFC,$40(A5)      ; SET BLITTER CONTROL 0
         CLR.W     $42(A5)             ; CLEAR BLITTER CONTROL 1
         MOVE.W    #(23*64)+1,$58(A5)  ; DO BLIT (23 HIGH BY 1 WORD)

.LOOP2   BTST      #14,$02(A5)
         BNE       .LOOP2

CONT:    SUB.B     #1,D1
         BNE       PN
         ADD.L     #1,SP2
         MOVE.L    SP2,A6
         CMP.B     #$FF,(A6)
         BNE       OKWAVE
         MOVE.L    #SD,SP2
OKWAVE:  MOVE.L    SP2,SP1
         RTS

DOWAVE:  MOVEQ     #0,D2
         MOVE.L    SP1,A3
         MOVE.B    (A3),D2
         CMP.W     #$FF,D2
         BNE       SCNWRAP
         MOVE.L    #SD,SP1
         BRA       DOWAVE

SCNWRAP: MULU      #42,D2
         MOVE.L    A2,A1
         ADD.L     D2,A1
         ADD.L     #1,SP1
WAVEEND: RTS

SP1:     DC.L      SD
SP2:     DC.L      SD
SD:      DC.B      0,0,1,1,2,4,5,6,8,10,11,12,13,14,14,15,15,15
         DC.B      14,14,13,12,11,10,8,6,5,4,2,1,1,0
         DC.B      $FF

**************************************************************************
*   SCROLL TEXT ROUTINE
**************************************************************************

SCROLL:  LEA       $DFF000,A5
         MOVE.L    #PLANE1+(10*42),$50(A5)     ; SET SOURCE A ADDRESS
         MOVE.L    #PLANE1+(10*42)-2,$54(A5)   ; SET SOURCE D (DESTINATION) ADDRESS
         MOVE.L    #$FFFFFFFF,$44(A5)  ; SET BLITTER MASK
         MOVE.W    #$0000,$64(A5)      ; SET SOURCE A MODULO
         MOVE.W    #$0000,$66(A5)      ; SET SOURCE D (DESTINATION) MODULO
         MOVE.W    #$F9F0,$40(A5)      ; SET BLITTER CONTROL 0
         MOVE.W    #$0000,$42(A5)      ; CLEAR BLITTER CONTROL 1
         MOVE.W    #(20*64)+20,$58(A5) ; DO BLIT (23 HIGH BY 1 WORD)

.LOOP    BTST      #14,$02(A5)         ; IS BLITTER FINISHED ?
         BNE       .LOOP               ; NO, OK WAIT TILL IT IS 

         SUB.W     #1,COUNT
         BNE       NNCHAR
         MOVE.L    TXTPTR,A0
         MOVEQ     #0,D0
         LEA       PLANE1,A1
         ADD.L     #(11*42),A1
         SUB.L     #2,A1

RCHAR:   MOVE.B    (A0)+,D0             ; GET BYTE OF TEXT
         BNE       CHAROK
         MOVE.L    #TEXT,A0
         BRA       RCHAR
CHAROK:  SUB.B     #32,D0               ; FIND CHARACTER
         MULU      #8,D0                ; FIND OFFSET
         LEA       CHARS(PC),A2         ; FIND FONT ADDRESS
         ADD.L     D0,A2                ; FIND ACTUAL FONT ADDRESS
         MOVEQ     #7,D2                ; HOW MANY BYTES TO COPY 1-1
         MOVE.L    A1,A3                ; STORE ADDRESS
DOCHAR:  MOVE.B    (A2)+,(A3)           ; MOVE BYTE
         ADD.L     #42,A3               ; NEXT LINE
         DBRA      D2,DOCHAR            ; IS CHARACTER FINISHED ?
         MOVE.L    A0,TXTPTR
         MOVE.W    #8,COUNT
NNCHAR:  RTS                            ; OK, RETURN

CHARS:   DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;SPACE
         DC.B $18,$18,$18,$18,$00,$18,$18,$00 ;!
         DC.B $6C,$6C,$00,$00,$00,$00,$00,$00 ;"
         DC.B $1C,$36,$7C,$78,$7C,$3E,$1C,$00 ;#
         DC.B $1C,$36,$1F,$0F,$1F,$3E,$1C,$00 ;$
         DC.B $00,$7E,$42,$42,$42,$42,$7E,$00 ;%
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;&
         DC.B $0C,$0C,$18,$00,$00,$00,$00,$00 ;'
         DC.B $18,$30,$30,$30,$30,$30,$18,$00 ;(
         DC.B $18,$0C,$0C,$0C,$0C,$0C,$18,$00 ;)
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;*
         DC.B $00,$18,$18,$7E,$7E,$18,$18,$00 ;+
         DC.B $00,$00,$00,$00,$0C,$0C,$18,$00 ;,
         DC.B $00,$00,$00,$7E,$7E,$00,$00,$00 ;-
         DC.B $00,$00,$00,$00,$00,$18,$18,$00 ;.
         DC.B $02,$06,$0C,$18,$30,$60,$C0,$00 ;/
         DC.B $7C,$C6,$CE,$DE,$F6,$E6,$7C,$00 ;0
         DC.B $38,$78,$18,$18,$18,$18,$7E,$00 ;1
         DC.B $7C,$C6,$06,$7C,$C0,$C0,$FE,$00 ;2
         DC.B $FC,$06,$06,$7C,$06,$06,$FC,$00 ;3
         DC.B $1C,$3C,$6C,$CC,$FE,$0C,$0C,$00 ;4
         DC.B $FE,$C0,$C0,$FC,$06,$06,$FC,$00 ;5
         DC.B $7E,$C0,$C0,$FC,$C6,$C6,$7C,$00 ;6
         DC.B $FE,$06,$06,$0C,$0C,$18,$18,$00 ;7
         DC.B $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00 ;8
         DC.B $7C,$C6,$C6,$7E,$06,$06,$06,$00 ;9
         DC.B $00,$18,$18,$00,$00,$18,$18,$00 ;:
         DC.B $00,$18,$18,$00,$18,$18,$30,$00 ;;
         DC.B $06,$1C,$70,$E0,$70,$1C,$06,$00 ;<
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;=
         DC.B $60,$38,$0E,$07,$0E,$38,$60,$00 ;>
         DC.B $7C,$C6,$C6,$0C,$18,$00,$18,$00 ;?
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;@
         DC.B $00,$00,$FF,$03,$7F,$73,$73,$00 ;A
         DC.B $00,$00,$FE,$03,$7E,$73,$7E,$00 ;B
         DC.B $00,$00,$FF,$00,$70,$70,$3F,$00 ;C
         DC.B $00,$00,$FE,$03,$73,$73,$7E,$00 ;D
         DC.B $00,$00,$FF,$00,$7E,$70,$7F,$00 ;E
         DC.B $00,$00,$FF,$00,$7E,$70,$70,$00 ;F
         DC.B $00,$00,$FE,$00,$76,$72,$7E,$00 ;G
         DC.B $00,$00,$73,$73,$7F,$73,$73,$00 ;H
         DC.B $00,$00,$1C,$1C,$1C,$1C,$1C,$00 ;I
         DC.B $FE,$06,$06,$C6,$C6,$C6,$7C,$00 ;J
         DC.B $00,$00,$73,$76,$7C,$76,$73,$00 ;K
         DC.B $00,$00,$70,$70,$70,$70,$3F,$00 ;L
         DC.B $00,$41,$63,$77,$7F,$6B,$63,$00 ;M
         DC.B $40,$60,$73,$7B,$7F,$6F,$67,$00 ;N
         DC.B $00,$00,$FE,$03,$73,$73,$3E,$00 ;O
         DC.B $00,$00,$FE,$03,$7E,$70,$70,$00 ;P
         DC.B $7C,$C6,$C6,$C6,$C6,$DA,$C6,$00 ;Q
         DC.B $00,$00,$FE,$03,$7E,$6C,$66,$00 ;R
         DC.B $00,$00,$1F,$3C,$3C,$3C,$F8,$00 ;S
         DC.B $00,$00,$FF,$1C,$1C,$1C,$1C,$00 ;T
         DC.B $00,$00,$73,$73,$73,$73,$3E,$00 ;U
         DC.B $00,$00,$73,$73,$73,$36,$1C,$00 ;V
         DC.B $00,$00,$63,$6B,$7F,$77,$63,$00 ;W
         DC.B $00,$00,$33,$1E,$0C,$1E,$33,$00 ;X
         DC.B $00,$00,$73,$73,$3E,$1C,$1C,$00 ;Y
         DC.B $FF,$FF,$1C,$38,$70,$E0,$FE,$00 ;Z

**************************************************************************
*   MY COPPER LIST
**************************************************************************

NEWCOP:  DC.W      $008E,$2C81,$0090,$2CC1
         DC.W      $0092,$0038,$0094,$00D0
         DC.W      $0100,$0000,$0102,$0000,$0104,$0000
         DC.W      $0108,$0002,$010A,$0002
         DC.W      $0180,$0000,$0182,$0FFF
         DC.W      $2A09,$FFFE,$0180,$0F00
         DC.W      $2B09,$FFFE,$0180,$0000
         DC.W      $00E0
PL1H:    DC.W      $0000,$00E2
PL1L:    DC.W      $0000
         DC.W      $2209,$FFFE,$0100,$1200
         DC.W      $4D09,$FFFE,$0180,$000F
         DC.W      $0108,00-82,$0182,$0CCC
         DC.W      $7109,$FFFE,$0180,$0000
         DC.W      $7209,$FFFE,$0180,$0F00
         DC.W      $7309,$FFFE,$0180,$0000
         DC.W      $0100,$0000

         DC.W      $FFFF,$FFFE         ; END COPPER ( IMPOSSIBLE WAIT )

**************************************************************************
*   END OF SOURCE
**************************************************************************

