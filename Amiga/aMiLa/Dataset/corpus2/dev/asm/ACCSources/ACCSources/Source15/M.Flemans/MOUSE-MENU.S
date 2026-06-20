*
*    MOUSE-MENU SYSTEM
*    CODED BY MARK FLEMANS
*    DATE : 12.04.91
*
*

         SECTION shine_on_you_crazy_diamond,CODE_C        
         OPT C-     

START:   MOVEM.L   D0-D7/A0-A6,-(SP)        ; Save registers
         MOVE.L    4,A6                     ; Get EXEC-base
         JSR       -132(A6)                 ; Forbid Multitasking
         MOVE.L    4,A6                     ; Get EXEC-base
         MOVEQ     #0,D0                    ; Any version
         LEA       GFXNAM(PC),A1            ; Point to library name
         JSR       -552(A6)                 ; Open GFX library
         MOVE.L    D0,GFXBSE                ; Save base address
         MOVE.W    #$0020,$DFF096           ; Turn sprite DMA off
         MOVE.L    #TEXTPL,D0               ; Define Text plane
         MOVE.W    D0,LP1L
         SWAP      D0
         MOVE.W    D0,LP1H
         LEA       $DFF144,a0               ; Clear sprite data
         MOVEQ     #7,d0
CLOP:    CLR.L     (A0)
         ADDQ.L    #8,A0
         DBF       D0,CLOP
         MOVE.L    GFXBSE,A1                ; Get GFX-base
         MOVE.L    38(A1),OLDCOP            ; Store Copperlist
         MOVE.L    #NEWCOP,$DFF080          ; Run new Copperlist
         CLR.L     $DFF088
         BSR       PTEXT                    ; Print text on plane
         BSR       MFICHK                   ; First mouse check

LOOP:    CMPI.B    #$F0,$DFF006             ; Wait for VBL
         BNE.S     LOOP                     ; No, Ok loop
         BSR       MSECHK                   ; Check mouse
         BTST      #6,$BFE001               ; Is LMB pressed
         BNE       LOOP                     ; No, Ok loop

         MOVE.L    OLDCOP,$DFF080           ; Restore Old-copper
         MOVE.L    4,A6                     ; Get EXEC-Base
         MOVE.L    GFXBSE,A1                ; Get GFX-base 
         JSR       -414(A6)                 ; Close GFX Library
         MOVE.L    4,A6                     ; Get EXEC-Base
         JSR       -138(A6)                 ; Permit Multitasking
 
         MOVE.L    4,A6                     ; Get EXEC-Base
         MOVEQ     #0,D0                    ; Any version
         LEA       DOSNAM(PC),A1            ; Point to library name
         JSR       -552(A6)                 ; Open library
         MOVE.L    D0,DOSBSE                ; Save base address

         MOVE.L    DOSBSE,A6                ; Get DOS-base
         CLR.L     D3                       ; Main window
         MOVEQ     #0,D0                    ; Clear value
         LEA       CFLAG,A0                 ; Get Flag-value pointer
         MOVE.B    (A0),D0                  ; Get option Number
         MOVE.L    #8,D1                    ; Find position 
         MULU      D0,D1                    ; Get Offset
         ADD.L     #COM1,D1                 ; Point to command
         CLR.L     D2                       ; No input CLI
         JSR       -222(A6)                 ; Execute command

MOI:     MOVEM.L   (SP)+,D0-D7/A0-A6        ; Re-load registers
         MOVE.W    #$8020,$DFF096           ; Turn sprite DMA on

         MOVEQ     #0,D0                    ; No errors
END:     RTS                                ; Bye

**************************************************************************
*        BAR MOVEMENT ROUTINE
**************************************************************************

MFICHK:  MOVE.W   $DFF00A,D7                ; Control in D7 (Stop error)
MSECHK:  MOVE.W   D7,D6                     ; Copy D7 to D6
         MOVE.W   $DFF00A,D7                ; Control in D7
         SUB.B    D7,D6                     ; Sub horizontal byte
         ROR.W    #8,D7                     ; Rotate control bytes
         ROR.W    #8,D6
         SUB.B    D7,D6                     ; Sub verticle bytes
         ROR.W    #8,D6                     ; Rotate back
         ROR.W    #8,D7
         CMP.W    #0,D6                     ; Compare D6
         BEQ      MSEOUT                    ; Any movement ?
         ROR.W    #8,D6                     ; Get verticle byte
         CMP.B    #0,D6
         BGT      COPDOWN                   ; Move bar up
         BLT      COPUP                     ; Move bar down
MSEOUT:  RTS

COPUP:   CMP.B    #255,D6                   ; Move bar down
         BLT      C2
         JMP      NOUP
C2:      LEA      CFLAG,A0                   
         MOVE.B   (A0),D0                   ; Get value
         CMPI.B   #$3,D0                    ; Is it Max ?
         BEQ      NOUP                      ; Yes, Ok no further down
         LEA      MOTHER,A0                 
         ADDI.B   #11,(A0)
         ADDI.B   #11,8(A0)
         ADDI.B   #11,16(A0)
         ADDI.B   #11,24(A0)                ; Lower bar down screen
         ADDI.B   #1,CFLAG                  ; Next choice
NOUP:    RTS

COPDOWN: CMP.B    #1,D6                     ; Move bar up
         BGT      C1
         JMP      NODOWN
C1:      LEA      CFLAG,A0
         MOVE.B   (A0),D0                   ; Get value
         CMPI.B   #$0,D0                    ; Is it Low ?
         BEQ      NODOWN                    ; Yes, Ok no further up
         LEA      MOTHER,A0
         SUBI.B   #11,(A0)
         SUBI.B   #11,8(A0)
         SUBI.B   #11,16(A0)
         SUBI.B   #11,24(A0)                ; Move bar up screen
         SUBI.B   #1,CFLAG                  ; Next choice
NODOWN:  RTS

**************************************************************************
*   PRINT TEXT ROUTINE
**************************************************************************

PTEXT:   MOVE.L   #12,D5                    ; NUMBER OF LINES
         MOVE.L   #TEXT,A0                  ; GET ADDRESS OF TEXT
         LEA      TEXTPL(PC),A1             ; GET WHERE TO STORE
LLOOP:   ADD.L    #80,A1                    ; MAKE START
         MOVE.L   #39,D1                    ; LENGTH OF TEXT TO PRINT
NXTCHAR: MOVEQ    #0,D0                     ; CLEAR WHAT CHARACTER
         MOVE.B   (A0)+,D0                  ; GET BYTE OF TEXT
         SUB.B    #32,D0                    ; FIND CHARACTER
         MULU     #8,D0                     ; FIND OFFSET
         LEA      CHARS(PC),A2              ; FIND FONT ADDRESS
         ADD.L    D0,A2                     ; FIND ACTUAL FONT ADDRESS
         MOVEQ    #7,D2                     ; HOW MANY BYTES TO COPY 1-1
         MOVE.L   A1,A3                     ; STORE ADDRESS
DOCHAR:  MOVE.B   (A2)+,(A3)                ; MOVE BYTE
         ADD.L    #40,A3                    ; NEXT LINE
         DBRA     D2,DOCHAR                 ; IS CHARACTER FINISHED ?
         ADD.L    #1,A1                     ; YES, OK NEXT CHARACTER
         DBRA     D1,NXTCHAR                ; IS LINE OF TEXT FINISHED
         ADD.L    #40*8,A1

         DBRA     D5,LLOOP
         RTS                                ; OK, RETURN

CHARS:   DC.B $00,$00,$00,$00,$00,$00,$00,$00         ;SPACE
         DC.B $18,$18,$18,$18,$00,$18,$18,$00         ;!
         DC.B $6C,$6C,$00,$00,$00,$00,$00,$00         ;"
         DC.B $1C,$36,$7C,$78,$7C,$3E,$1C,$00         ;#
         DC.B $1C,$36,$1F,$0F,$1F,$3E,$1C,$00         ;$
         DC.B $00,$00,$00,$00,$00,$00,$00,$00         ;%
         DC.B $00,$00,$00,$00,$00,$00,$00,$00	;&
         DC.B $0C,$0C,$18,$00,$00,$00,$00,$00	;'
         DC.B $18,$30,$30,$30,$30,$30,$18,$00	;(
         DC.B $18,$0C,$0C,$0C,$0C,$0C,$18,$00	;)
         DC.B $00,$00,$00,$00,$00,$00,$00,$00	;*
         DC.B $00,$18,$18,$7E,$7E,$18,$18,$00	;+
         DC.B $00,$00,$00,$00,$0C,$0C,$18,$00	;,
         DC.B $00,$00,$00,$7E,$7E,$00,$00,$00	;-
         DC.B $00,$00,$00,$00,$00,$18,$18,$00	;.
         DC.B $02,$06,$0C,$18,$30,$60,$C0,$00	;/
         DC.B $7C,$C6,$CE,$DE,$F6,$E6,$7C,$00	;0
         DC.B $38,$78,$18,$18,$18,$18,$7E,$00	;1
         DC.B $7C,$C6,$06,$7C,$C0,$C0,$FE,$00	;2
         DC.B $FC,$06,$06,$7C,$06,$06,$FC,$00	;3
         DC.B $1C,$3C,$6C,$CC,$FE,$0C,$0C,$00	;4
         DC.B $FE,$C0,$C0,$FC,$06,$06,$FC,$00	;5
         DC.B $7E,$C0,$C0,$FC,$C6,$C6,$7C,$00	;6
         DC.B $FE,$06,$06,$0C,$0C,$18,$18,$00	;7
         DC.B $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	;8
         DC.B $7C,$C6,$C6,$7E,$06,$06,$06,$00	;9
         DC.B $00,$18,$18,$00,$00,$18,$18,$00	;:
         DC.B $00,$18,$18,$00,$18,$18,$30,$00	;;
         DC.B $06,$1C,$70,$E0,$70,$1C,$06,$00	;<
         DC.B $00,$00,$00,$00,$00,$00,$00,$00	;=
         DC.B $60,$38,$0E,$07,$0E,$38,$60,$00	;>
         DC.B $7C,$C6,$C6,$0C,$18,$00,$18,$00	;?
         DC.B $00,$00,$00,$00,$00,$00,$00,$00	;@
         DC.B $7C,$C6,$C6,$FE,$C6,$C6,$C6,$00	;A
         DC.B $FC,$C6,$C6,$FC,$C6,$C6,$FC,$00	;B
         DC.B $7E,$C0,$C0,$C0,$C0,$C0,$7E,$00	;C
         DC.B $FC,$C6,$C6,$C6,$C6,$C6,$FC,$00	;D
         DC.B $7E,$C0,$C0,$FE,$C0,$C0,$7E,$00	;E
         DC.B $7E,$C0,$C0,$FE,$C0,$C0,$C0,$00	;F
         DC.B $7E,$C0,$C0,$DE,$C6,$C6,$7C,$00	;G
         DC.B $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00	;H
         DC.B $7E,$18,$18,$18,$18,$18,$7E,$00	;I
         DC.B $FE,$06,$06,$C6,$C6,$C6,$7C,$00	;J
         DC.B $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00	;K
         DC.B $C0,$C0,$C0,$C0,$C0,$C0,$FE,$00	;L
         DC.B $C6,$EE,$FE,$D6,$C6,$C6,$C6,$00	;M
         DC.B $E6,$F6,$DE,$CE,$C6,$C6,$C6,$00	;N
         DC.B $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00	;O
         DC.B $FC,$C6,$C6,$FC,$C0,$C0,$C0,$00	;P
         DC.B $7C,$C6,$C6,$C6,$C6,$6E,$3E,$00	;Q
         DC.B $FC,$C6,$C6,$FE,$CC,$C6,$C6,$00	;R
         DC.B $7E,$C0,$C0,$7C,$06,$06,$FC,$00	;S
         DC.B $7E,$18,$18,$18,$18,$18,$18,$00	;T
         DC.B $C6,$C6,$C6,$C6,$C6,$C6,$7C,$00	;U
         DC.B $C6,$C6,$C6,$C6,$C6,$38,$38,$00	;V
         DC.B $C6,$C6,$C6,$D6,$FE,$EE,$C6,$00	;W
         DC.B $C6,$6C,$38,$10,$38,$6C,$C6,$00	;X
         DC.B $C6,$C6,$C6,$7E,$06,$06,$FC,$00	;Y
         DC.B $FE,$0E,$1C,$38,$70,$E0,$FE,$00	;Z

**************************************************************************
*        VARIABLE STORES
**************************************************************************

GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $0000
         EVEN
DOSNAM:  DC.B      "dos.library",0
         EVEN
DOSBSE:  DC.L      $0000
         EVEN
OLDCOP:  DC.L      $0000
         EVEN
TEXTPL:  DCB.B     10240,0
         EVEN
COM1:    DC.B      "1",0,0,0,0,0,0,0
COM2:    DC.B      "2",0,0,0,0,0,0,0
COM3:    DC.B      "3",0,0,0,0,0,0,0
COM4:    DC.B      "4",0,0,0,0,0,0,0
         EVEN
CFLAG:   DC.B     $00
         EVEN
NEWCOP:	DC.W     $008E,$2C81,$0090,$2CC1         
	DC.W     $0092,$0038,$0094,$00D0         
	DC.W     $0100,$0000,$0102,$0000         
	DC.W     $0104,$0000,$0108,$0000
	DC.W     $010A,$0000,$0180,$0000         
         DC.W     $0180,$0000,$0182,$0FFF
         DC.W     $0184,$0888,$0186,$0CCC
         DC.W     $0188,$0000,$018A,$0000
         DC.W     $018C,$0000,$018E,$0000
         DC.W     $0190,$0000,$0192,$0000
         DC.W     $0194,$0000,$0196,$0000
         DC.W     $0198,$0000,$019A,$0000
         DC.W     $019C,$0000,$019E,$0000
         DC.W     $5001,$FFFE
         DC.W     $00E0
LP1H:    DC.W     $0000,$00E2
LP1L:    DC.W     $0000
         DC.W     $5401,$FFFE,$0180,$000D
         DC.W     $5801,$FFFE,$0180,$0008
         dc.w     $0100,$1100

MOTHER:  DC.W     $8309,$FFFE,$0180,$0003
         DC.W     $8509,$FFFE,$0180,$0008
         DC.W     $8e09,$FFFE,$0180,$000D
         DC.W     $9009,$FFFE,$0180,$0008
         DC.W     $e909,$FFFE,$0180,$0003
         DC.W     $ed09,$FFFE,$0180,$0000
         DC.W     $FFFF,$FFFE

TEXT:    DC.B     "                                        "
         DC.B     "      MARKS WORKING UTILITIES DISK      "
         DC.B     "     ------------------------------     "
         DC.B     "                                        "
         DC.B     "               IFF MASTER               "
         DC.B     "                DEVPAC 2                "
         DC.B     "              DISKMASTER 3              "
         DC.B     "            POWERPACKER 2.3B            "
         DC.B     "                                        "
         DC.B     "           MENU CODED BY MARK           "
         DC.B     "                                        "
         DC.B     " THIS IS AN EXAMPLE MENU FOR ACC CODERS "
         DC.B     "                                        "

         DC.B     $FF

**************************************************************************
*   END OF SOURCE
**************************************************************************

