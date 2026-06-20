*
*       DUAL-TEXT-MENU
*       CODED BY MARK FLEMANS
*       DATE : 20.06.91
*

         SECTION welcome_to_the_machine,CODE_C       ; CHIP MEMORY PLEASE
         OPT C-                                      ; NO CASE SENSITIVITY

**************************************************************************
*   START OF MY CODE
**************************************************************************

BEG:     MOVEM.L   D0-D7/A0-A6,-(SP)   ; SAVE REGISTERS
         MOVE.L    4,A6                ; GET EXEC BASE
         JSR       -132(A6)            ; NO MULTI-TASKING

         MOVE.L    #PLANE,D0           ; FIND MY TEXT PLANE
         MOVE.W    D0,PL1L             ; SET LOW VALUE
         SWAP      D0                  ; NEXT WORD
         MOVE.W    D0,PL1H             ; SET HIGH VALUE
         SWAP      D0                  ; BACK TO NORMAL
         SUB.L     #80,D0              ; SET PLANE BACK
         MOVE.W    D0,PL2L             ; SET LOW VALUE
         SWAP      D0                  ; NEXT WORD
         MOVE.W    D0,PL2H             ; SET HIGH VALUE

         MOVEQ     #0,D0               ; ANY VERSION
         LEA       GFXNAM(PC),A1       ; POINT TO NAME OF LIBRARY
         JSR       -552(A6)            ; OPEN LIBRARY
         MOVE.L    D0,GFXBSE           ; STORE ITS BASE
         MOVE.L    GFXBSE,A1           ; GET ADDRESS
         MOVE.L    38(A1),OLDCOP       ; STORE OLD COPPERLIST
         MOVE.L    #NEWCOP,$DFF080     ; INSERT NEW COPPERLIST
         MOVE.W    #$0020,$DFF096      ; SPRITE DMA DISABLE
         BSR       PTEXT               ; GO OUTPUT TEXT

OPEN:    CMPI.B    #$F0,$DFF006        ; WAIT FOR VBL
         BNE.S     OPEN                ; NO, OK I'LL WAIT
         BSR       OPENCOP             ; DO ME ROUTINE
         CMP.B     #$48,D6             ; NO, OK I`LL WAIT
         BNE       OPEN

LOOP:    CMPI.B    #$F0,$DFF006        ; WAIT FOR VBL
         BNE.S     LOOP                ; NO, OK I'LL WAIT
         MOVE.B    $BFEC01,D0          ; GET CHARACTER
         NOT       D0                  ; REVERSE IT
         ROR.B     #1,D0               ; ROTATE RIGHT ONCE
         BSR       COPQUIT             ; DO COPPER ROUTINE
         CMP.B     #$53,D0             ; CHECK FOR F4 KEY
         BHI       LOOP                ; LOOP IF GREATER
         CMP.B     #$4F,D0             ; CHECK FOR F1 KEY
         BLS       LOOP                ; LOOP IF SMALLER
         MOVE.B    D0,FKEY             ; SAVE INPUT F-KEY

CLOSE:   CMPI.B    #$F0,$DFF006        ; WAIT FOR VBL
         BNE.S     CLOSE               ; NO, OK I'LL WAIT
         BSR       CLSECOP             ; DO ME ROUTINE
         CMPI.B    #0,D6
         BNE       CLOSE

         MOVE.W    #$8020,$DFF096      ; RESTORE SPRITE DMA
         MOVE.L    OLDCOP,$DFF080      ; RESTORE OLD COPPER LIST
         MOVE.L    4,A6                ; GET EXEC BASE
         MOVE.L    GFXBSE,A1           ; POINT TO NAME OF LIBRARY
         JSR       -414(A6)            ; CLOSE LIBRARY
         MOVE.L    4,A6
         JSR       -138(A6)            ; ENABLE MULTI-TASKING

         MOVE.L    4,A6                ; GET EXEC-BASE
         MOVEQ     #0,D0               ; ANY VERSION
         LEA       DOSNAM(PC),A1       ; POINT TO LIBRARY NAME
         JSR       -552(A6)            ; OPEN LIBRARY
         MOVE.L    D0,DOSBSE           ; SAVE BASE ADDRESS

         MOVE.L    DOSBSE,A6
         CLR.L     D3                  ; MAIN WINDOW
         MOVEQ     #0,D0
         LEA       FKEY,A0
         MOVE.B    (A0),D0             ; GET VALUE
         SUB.B     #$50,D0             ; GET CORRECT VALUE
         MOVE.L    #8,D1               
         MULU      D0,D1
         ADD.L     #COM1,D1            ; POINT TO COMMAND
         CLR.L     D2                  ; NO INPUT CLI
         JSR       -222(A6)            ; EXECUTE COMMAND

         MOVEM.L   (SP)+,D0-D7/A0-A6   ; RESTORE REGISTERS
MAINEND: MOVEQ     #0,D0               ; NO CLI ERROR
         RTS                           ; BYE / QUIT !!

**************************************************************************
*   VARIABLE STORES
**************************************************************************

OLDCOP:  DC.L      $0000
GFXNAM:  DC.B      "graphics.library",0
DOSNAM:  DC.B      "dos.library",0
         EVEN
GFXBSE:  DC.L      $0000
DOSBSE:  DC.L      $0000
CFLAG:   DC.B      $0000
FKEY:    DC.B      $0000
         EVEN
BLANK:   DCB.B     40*5,0
PLANE:   DCB.B     40*150,0
         EVEN
COM1:    DC.B      "X S/B1",0,0        ; MUST BE EIGHT BYTES 
COM2:    DC.B      "X S/B2",0,0
COM3:    DC.B      "X S/B3",0,0
COM4:    DC.B      "X S/B4",0,0
         EVEN
COLSAVE1:DC.W      0
TEXT:    DC.B      "                                        "
         DC.B      "       MARKS WORKING UTILITY DISK       "
         DC.B      "      ----------------------------      "
         DC.B      "                                        "
         DC.B      "  F1 ......... IFF MASTER ......... F1  "
         DC.B      "  F2 .......... DEVPAC 2 .......... F2  "
         DC.B      "  F3 ........ DISKMASTER 3 ........ F3  "
         DC.B      "  F4 ...... POWERPACKER 2.3B ...... F4  "
         DC.B      "                                        "
         DC.B      "        MENU SYSTEM CODE BY MARK        "
         DC.B      "                                        "
         DC.B      " THIS IS AN EXAMPLE MENU FOR ACC CODERS "
  
**************************************************************************
*   COPPER ROUTINES
**************************************************************************

OPENCOP: LEA       CFLAG,A0
         MOVE.B    (A0),D6
         CMPI.B    #$48,D6
         BEQ       COPQUIT
         SUBI.W    #$100,LINE1
         SUBI.W    #$100,LINE2
         ADDI.W    #$100,LINE3
         ADDI.W    #$100,LINE4
         ADDI.B    #$1,CFLAG
         JMP       COPQUIT

CLSECOP: LEA       CFLAG,A0
         MOVE.B    (A0),D6
         CMPI.B    #0,D6
         BEQ       COPQUIT
         ADDI.W    #$100,LINE1
         ADDI.W    #$100,LINE2
         SUBI.W    #$100,LINE3
         SUBI.W    #$100,LINE4
         SUBI.B    #$1,CFLAG

COPQUIT: LEA       CPSRL1,A5
         LEA       CPSTP1,A6
         BSR       SCOPBAR
         LEA       CPSRL2,A5
         LEA       CPSTP2,A6
         BSR       SCOPBAR
         RTS

SCOPBAR: MOVE.L    A5,A0
         ADD.L     #2,A0
         MOVE.B    #$40-19,D3
         MOVE.W    (A0),COLSAVE1
CPL:     MOVE.W    4(A0),(A0)
         ADDA.L    #4,A0
         SUBQ.B    #1,D3
         CMP.B     #$FF,D3
         BNE.S     CPL
         MOVE.W    COLSAVE1,2(A6)
         RTS

**************************************************************************
*   PRINT TEXT ROUTINE
**************************************************************************

PTEXT:   MOVE.L   #11,D5               ; NUMBER OF LINES
         MOVE.L   #TEXT,A0             ; GET ADDRESS OF TEXT
         LEA      PLANE(PC),A1         ; GET WHERE TO STORE
LLOOP:   ADD.L    #80,A1               ; MAKE START
         MOVE.L   #39,D1               ; LENGTH OF TEXT TO PRINT
NXTCHAR: MOVEQ    #0,D0                ; CLEAR WHAT CHARACTER
         MOVE.B   (A0)+,D0             ; GET BYTE OF TEXT
         SUB.B    #32,D0               ; FIND CHARACTER
         MULU     #8,D0                ; FIND OFFSET
         LEA      CHARS(PC),A2         ; FIND FONT ADDRESS
         ADD.L    D0,A2                ; FIND ACTUAL FONT ADDRESS
         MOVEQ    #7,D2                ; HOW MANY BYTES TO COPY 1-1
         MOVE.L   A1,A3                ; STORE ADDRESS
DOCHAR:  MOVE.B   (A2)+,(A3)           ; MOVE BYTE
         ADD.L    #40,A3               ; NEXT LINE
         DBRA     D2,DOCHAR            ; IS CHARACTER FINISHED ?
         ADD.L    #1,A1                ; YES, OK NEXT CHARACTER
         DBRA     D1,NXTCHAR           ; IS LINE OF TEXT FINISHED
         ADD.L    #40*8,A1             ; NEXT LINE
         DBRA     D5,LLOOP             ; HAS TOTAL TEXT FINISHED ?
         RTS                           ; OK, RETURN

CHARS:   DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;SPACE
         DC.B $18,$18,$18,$18,$00,$18,$18,$00 ;!
         DC.B $6C,$6C,$00,$00,$00,$00,$00,$00 ;"
         DC.B $1C,$36,$7C,$78,$7C,$3E,$1C,$00 ;#
         DC.B $1C,$36,$1F,$0F,$1F,$3E,$1C,$00 ;$
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;%
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
         DC.B $7C,$C6,$C6,$FE,$C6,$C6,$C6,$00 ;A
         DC.B $FC,$C6,$C6,$FC,$C6,$C6,$FC,$00 ;B
         DC.B $7E,$C0,$C0,$C0,$C0,$C0,$7E,$00 ;C
         DC.B $FC,$C6,$C6,$C6,$C6,$C6,$FC,$00 ;D
         DC.B $7E,$C0,$C0,$FE,$C0,$C0,$7E,$00 ;E
         DC.B $7E,$C0,$C0,$FE,$C0,$C0,$C0,$00 ;F
         DC.B $7E,$C0,$C0,$DE,$C6,$C6,$7C,$00 ;G
         DC.B $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00 ;H
         DC.B $7E,$18,$18,$18,$18,$18,$7E,$00 ;I
         DC.B $FE,$06,$06,$C6,$C6,$C6,$7C,$00 ;J
         DC.B $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00 ;K
         DC.B $C0,$C0,$C0,$C0,$C0,$C0,$FE,$00 ;L
         DC.B $C6,$EE,$FE,$D6,$C6,$C6,$C6,$00 ;M
         DC.B $E6,$F6,$DE,$CE,$C6,$C6,$C6,$00 ;N
         DC.B $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00 ;O
         DC.B $FC,$C6,$C6,$FC,$C0,$C0,$C0,$00 ;P
         DC.B $7C,$C6,$C6,$C6,$C6,$DA,$C6,$00 ;Q
         DC.B $FC,$C6,$C6,$FE,$CC,$C6,$C6,$00 ;R
         DC.B $7E,$C0,$C0,$7C,$06,$06,$FC,$00 ;S
         DC.B $7E,$18,$18,$18,$18,$18,$18,$00 ;T
         DC.B $C6,$C6,$C6,$C6,$C6,$C6,$7C,$00 ;U
         DC.B $C6,$C6,$C6,$C6,$C6,$38,$38,$00 ;V
         DC.B $C6,$C6,$C6,$D6,$FE,$EE,$C6,$00 ;W
         DC.B $C6,$6C,$38,$10,$38,$6C,$C6,$00 ;X
         DC.B $C6,$C6,$C6,$7E,$06,$06,$FC,$00 ;Y
         DC.B $FE,$0E,$1C,$38,$70,$E0,$FE,$00 ;Z

**************************************************************************
*   MY COPPER LIST
**************************************************************************

NEWCOP:  DC.W      $008E,$2C81
         DC.W      $0090,$2CC1
         DC.W      $0092,$0038
         DC.W      $0094,$00D0
         DC.W      $0100,$0000
         DC.W      $0180,$0000,$0182,$0FFF
         DC.W      $0192,$0444,$0102,$0003

LINE1:   DC.W      $A031,$FFFE
CPSRL1:  DC.W      $0180,$00F5,$0180,$00F3,$0180,$00F1,$0180,$01F0
         DC.W      $0180,$03F0,$0180,$05F0,$0180,$07F0,$0180,$09F0
         DC.W      $0180,$0BF0,$0180,$0DF0,$0180,$0FF0,$0180,$0FD0
         DC.W      $0180,$0FB0,$0180,$0F90,$0180,$0F70,$0180,$0F50
         DC.W      $0180,$0F30,$0180,$0F10,$0180,$0F01,$0180,$0F03
         DC.W      $0180,$0F05,$0180,$0F07,$0180,$0F09,$0180,$0F0B
         DC.W      $0180,$0F0D,$0180,$0F0F,$0180,$0D0F,$0180,$0B0F
         DC.W      $0180,$090F,$0180,$070F,$0180,$050F,$0180,$030F
         DC.W      $0180,$010F,$0180,$001F,$0180,$003F,$0180,$005F 
         DC.W      $0180,$007F,$0180,$009F,$0180,$00BF,$0180,$00DF
         DC.W      $0180,$00FF,$0180,$00FD,$0180,$00FB,$0180,$00F9
CPSTP1:  DC.W      $0180,$00F7
LINE2:   DC.W      $A119,$FFFE,$0180,$0000
         DC.W      $00E0
PL1H:    DC.W      $0000,$00E2
PL1L:    DC.W      $0000,$00E4
PL2H:    DC.W      $0000,$00E6
PL2L:    DC.W      $0000,$0100,$2400
LINE3:   DC.W      $A231,$FFFE,$0100,$0000
CPSRL2:  DC.W      $0180,$00F5,$0180,$00F3,$0180,$00F1,$0180,$01F0
         DC.W      $0180,$03F0,$0180,$05F0,$0180,$07F0,$0180,$09F0
         DC.W      $0180,$0BF0,$0180,$0DF0,$0180,$0FF0,$0180,$0FD0
         DC.W      $0180,$0FB0,$0180,$0F90,$0180,$0F70,$0180,$0F50
         DC.W      $0180,$0F30,$0180,$0F10,$0180,$0F01,$0180,$0F03
         DC.W      $0180,$0F05,$0180,$0F07,$0180,$0F09,$0180,$0F0B
         DC.W      $0180,$0F0D,$0180,$0F0F,$0180,$0D0F,$0180,$0B0F
         DC.W      $0180,$090F,$0180,$070F,$0180,$050F,$0180,$030F
         DC.W      $0180,$010F,$0180,$001F,$0180,$003F,$0180,$005F 
         DC.W      $0180,$007F,$0180,$009F,$0180,$00BF,$0180,$00DF
         DC.W      $0180,$00FF,$0180,$00FD,$0180,$00FB,$0180,$00F9
CPSTP2:  DC.W      $0180,$00F7,$0180,$0000
LINE4:   DC.W      $A319,$FFFE,$0180,$0000

         DC.W      $FFFF,$FFFE         ; END COPPER ( IMPOSSIBLE WAIT )

**************************************************************************
*   END OF SOURCE
**************************************************************************

