*  TITLE  :  SCREEN-PRINT.S
*  CODE   :  MARK FLEMANS 
*  DATE   :  20/09/90
*

         SECTION the_macc_lads,CODE_C  ; CHIP MEMORY PLEASE
         OPT C-                        ; NO CASE SENSITIVITY

**************************************************************************
*   START OF MY CODE
**************************************************************************

BEG:     MOVEM.L   D0-D7/A0-A6,-(SP)   ; SAVE REGISTERS
         MOVE.L    #PLANE,D0           ; SET UP PLANE 
         MOVE.W    D0,PL1L             ; LO-BITS
         SWAP      D0                  ; SWAP LO <-> HI
         MOVE.W    D0,PL1H             ; HI-BITS
         MOVE.W    #$0020,$DFF096      ; SPRITE DMA OFF
 
MAIN:    MOVE.L    4,A6                ; GET EXEC BASE
         MOVEQ     #0,D0               ; ANY VERSION
         LEA       GFXNAM(PC),A1       ; POINT TO NAME OF LIBRARY
         JSR       -552(A6)            ; OPEN LIBRARY
         MOVE.L    D0,GFXBSE           ; STORE ITS BASE
         MOVE.L    GFXBSE,A1           ; GET ADDRESS
         MOVE.L    38(A1),OLDCOP       ; STORE OLD COPPERLIST
         MOVE.L    #NEWCOP,$DFF080     ; INSERT NEW COPPERLIST

         BSR       PRTEXT              ; PRINT MY TEXT

MOUSE:   BTST      #6,$BFE001          ; WAIT FOR LEFT MOUSE BUTTON
         BNE       MOUSE               ; NO, OK I`LL WAIT

         MOVE.L    OLDCOP,$DFF080      ; RESTORE OLD COPPER LIST
         MOVE.W    #$8020,$DFF096      ; SPRITE DMA ON
         MOVE.L    4,A6                ; GET EXEC BASE
         MOVE.L    GFXBSE,A1           ; POINT TO NAME OF LIBRARY
         JSR       -414(A6)            ; CLOSE LIBRARY
         MOVEM.L   (SP)+,D0-D7/A0-A6   ; RESTORE REGISTERS
MAINEND: MOVEQ     #0,D0               ; NO CLI ERROR
         RTS                           ; BYE / QUIT !!

**************************************************************************
*  PRINT ROUTINE
**************************************************************************

PRTEXT:  MOVE.L   #25,D1               ; LENGTH OF TEXT TO PRINT
         MOVE.L   #TEXT,A0             ; GET ADDRESS OF TEXT
         LEA      PLANE(PC),A1         ; GET WHERE TO STORE
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
         RTS                           ; OK, RETURN

**************************************************************************
*   VARIABLE STORES
**************************************************************************

OLDCOP:  DC.L      $0000
         EVEN
GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $0000
         EVEN
TEXT:    DC.B      "MADNESS - A STATE OF MIND",0
         EVEN
LENGTH:  * - TEXT

**************************************************************************
*   MY COPPER LIST
**************************************************************************

NEWCOP:  DC.W      $008E,$2C81
         DC.W      $0090,$2CC1
         DC.W      $0092,$0038
         DC.W      $0094,$00D0
         DC.W      $0102,$0000
         DC.W      $0104,$0000
         DC.W      $0108,$0000         ; NO MODULO
         DC.W      $010A,$0000         ; NO MODULO
         DC.W      $0180,$0000         ; SET COLOUR 0 ( BACKGROUND )
         DC.W      $0182,$0FFF         ; SET COLOUR 1 ( MY TEXT )
         DC.W      $00E0
PL1H:    DC.W      $0000,$00E2
PL1L:    DC.W      $0000
         DC.W      $0100,$1200         ; TURN ON 1 BITPLANE

         DC.W      $FFFF,$FFFE         ; END COPPER ( IMPOSSIBLE WAIT )

**************************************************************************
*   THE GRAPHIC PLANES
**************************************************************************

PLANE:   DCB.B     40*256,0            ; DEFINE MY SCREEN ( BLANK )   

**************************************************************************
*  THE FONT
**************************************************************************

CHARS:   DC.B $00,$00,$00,$00,$00,$00,$00,$00   ;SPACE
         DC.B $18,$18,$18,$18,$00,$18,$18,$00   ;!
         DC.B $6C,$6C,$00,$00,$00,$00,$00,$00   ;"
         DC.B $1C,$36,$7C,$78,$7C,$3E,$1C,$00   ;#
         DC.B $1C,$36,$1F,$0F,$1F,$3E,$1C,$00   ;$
         DC.B $00,$00,$00,$00,$00,$00,$00,$00   ;%
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
         DC.B $7C,$C6,$C6,$C6,$C6,$DA,$C6,$00	;Q
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
*   END OF SOURCE
**************************************************************************

