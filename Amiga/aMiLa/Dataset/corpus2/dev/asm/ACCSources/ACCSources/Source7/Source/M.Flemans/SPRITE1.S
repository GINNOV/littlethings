*  TITLE  :  SPRITE.S
*  CODE   :  MARK FLEMANS
*  DATE   :  07/11/90
*

         SECTION sprite,CODE_C         ; CHIP MEMORY PLEASE
         OPT C-                        ; NO CASE SENSITIVITY

**************************************************************************
*   START OF MY CODE
**************************************************************************

BEG:     MOVEM.L   D0-D7/A0-A6,-(SP)   ; SAVE REGISTERS
         MOVE.L    #PLANE,D0           ; SET UP PLANE 
         MOVE.W    D0,PL1L             ; LO-BITS
         SWAP      D0                  ; SWAP LO <-> HI
         MOVE.W    D0,PL1H             ; HI-BITS
         MOVE.L    #SPRITE,D0
         MOVE.W    D0,SP0TL
         SWAP      D0
         MOVE.W    D0,SP0TH 

MAIN:    MOVE.L    4,A6                ; GET EXEC BASE
         MOVEQ     #0,D0               ; ANY VERSION
         LEA       GFXNAM(PC),A1       ; POINT TO NAME OF LIBRARY
         JSR       -552(A6)            ; OPEN LIBRARY
         MOVE.L    D0,GFXBSE           ; STORE ITS BASE
         MOVE.L    GFXBSE,A1           ; GET ADDRESS
         MOVE.L    38(A1),OLDCOP       ; STORE OLD COPPERLIST
         MOVE.L    #NEWCOP,$DFF080     ; INSERT NEW COPPERLIST
         MOVE.W    #$8020,$DFF096      ; SPRITE DMA ENABLE

MOUSE:   CMPI.B    #$F0,$DFF006
         BNE.S     MOUSE

         BSR       ROUTINE

         BTST      #6,$BFE001          ; WAIT FOR LEFT MOUSE BUTTON
         BNE       MOUSE               ; NO, OK I`LL WAIT

         MOVE.L    OLDCOP,$DFF080      ; RESTORE OLD COPPER LIST
         MOVE.L    4,A6                ; GET EXEC BASE
         MOVE.L    GFXBSE,A1           ; POINT TO NAME OF LIBRARY
         JSR       -414(A6)            ; CLOSE LIBRARY
         MOVEM.L   (SP)+,D0-D7/A0-A6   ; RESTORE REGISTERS
MAINEND: MOVEQ     #0,D0               ; NO CLI ERROR
         RTS                           ; BYE / QUIT !!

**************************************************************************
*  SPRITE ROUTINE
**************************************************************************

ROUTINE: MOVE.W    #7,D2
         MOVE.L    #SPRITE,A0
MY:      ADDQ.B    #$1,1(A0)
         ADDQ.B    #$2,9(A0)
         ADDQ.B    #$3,17(A0)
         ADD.L     #24,A0
         SUB.W     #1,D2
         BNE.S     MY
         RTS

**************************************************************************
*   VARIABLE STORES
**************************************************************************

OLDCOP:  DC.L      $0000
         EVEN
GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $0000
         EVEN

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
         DC.W      $0120
SP0TH:   DC.W      $0000,$0122
SP0TL:   DC.W      $0000
         DC.W      $01A2,$0999
         DC.W      $01A4,$0BBB
         DC.W      $01A6,$0000
         DC.W      $01A8,$0000
         DC.W      $3009,$FFFE,$0180,$0000
         DC.W      $3409,$FFFE,$0180,$0001
         DC.W      $3809,$FFFE,$0180,$0002
         DC.W      $3C09,$FFFE,$0180,$0003
         DC.W      $4009,$FFFE,$0180,$0004
         DC.W      $4409,$FFFE,$0180,$0005
         DC.W      $4809,$FFFE,$0180,$0006
         DC.W      $4C09,$FFFE,$0180,$0007
         DC.W      $5009,$FFFE,$0180,$0008
         DC.W      $5409,$FFFE,$0180,$0009
         DC.W      $5809,$FFFE,$0180,$000A
         DC.W      $5C09,$FFFE,$0180,$000B
         DC.W      $6009,$FFFE,$0180,$000C
         DC.W      $6409,$FFFE,$0180,$000D
         DC.W      $6809,$FFFE,$0180,$000E
         DC.W      $6C09,$FFFE,$0180,$000F
         DC.W      $7009,$FFFE,$0180,$0050

         DC.W      $FFFF,$FFFE         ; END COPPER ( IMPOSSIBLE WAIT )

**************************************************************************
*   THE GRAPHIC PLANES
**************************************************************************

PLANE:   DCB.B     40*256,0            ; DEFINE MY SCREEN ( BLANK )   

***** SPRITE

SPRITE:  DC.W      $307A,$3100,$1000,$0000,$32C0,$3300,$1000,$0000
         DC.W      $3442,$3500,$1000,$0000,$36A2,$3700,$1000,$0000
         DC.W      $38DA,$3900,$1000,$0000,$3A5A,$3B00,$1000,$0000
         DC.W      $3CC5,$3D00,$1000,$0000,$3EB8,$3F00,$1000,$0000
         DC.W      $5082,$5100,$1000,$0000,$52D0,$5300,$1000,$0000
         DC.W      $547A,$5500,$1000,$0000,$56C0,$5700,$1000,$0000
         DC.W      $5842,$5900,$1000,$0000,$5AA2,$5B00,$1000,$0000
         DC.W      $5CDA,$5D00,$1000,$0000,$5E5A,$5F00,$1000,$0000
         DC.W      $60C5,$6100,$1000,$0000,$62B8,$6300,$1000,$0000
         DC.W      $6482,$6500,$1000,$0000,$66D0,$6700,$1000,$0000
         DC.W      $687A,$6900,$1000,$0000
SPRITEE: DC.W      $0000,$0000

         EVEN



**************************************************************************
*   END OF SOURCE
**************************************************************************

