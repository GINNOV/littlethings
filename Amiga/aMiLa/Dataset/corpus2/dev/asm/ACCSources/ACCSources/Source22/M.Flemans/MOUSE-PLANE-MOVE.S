***
***      MOUSE-READ-PROGRAM
***      BY MARK FLEMANS
***
***      DATE STARTED        : 03.11.91
***      DATE LAST AMENDMENT : 03.11.91
***

         SECTION mouse_read,CODE_C
         OPT     C-
 

MAIN:    MOVEM.L   A0-A6/D0-D7,-(SP)
         MOVE.L    4,A6
         JSR       -132(A6)

         MOVE.L    #PLANE,D0
         MOVE.W    D0,PL+6
         SWAP      D0
         MOVE.W    D0,PL+2

         MOVE.L    4,A6
         MOVEQ     #0,D0
         LEA       GFXNAM,A1
         JSR       -552(A6)
         TST       D0
         BEQ       END
         MOVE.L    D0,GFXBSE
         MOVE.L    D0,A0

         MOVE.W    #$0020,$DFF096
         MOVE.L    38(A0),OLDCOP
         MOVE.L    #NEWCOP,$DFF080
         CLR       $DFF088

         MOVE.B    $DFF00A,MPOINT
MOUSE:   MOVE.B    $DFF00A,D0
         CMP.B     MPOINT,D0
         BLT       COL1
         BGT       COL2
         BRA       OUT
COL1:    MOVE.W    #$0F00,$DFF180
         BRA       OUT
COL2:    MOVE.W    #$000F,$DFF180
OUT:     MOVE.B    D0,MPOINT
         BTST      #6,$BFE001
         BNE       MOUSE

         MOVE.W    #$8020,$DFF096
         MOVE.L    OLDCOP,$DFF080
         MOVE.L    4,A6
         MOVE.L    GFXBSE,A1
         JSR       -414(A6)
         MOVE.L    4,A6
         JSR       -138(A6)
         MOVEQ     #0,D0
END:     MOVEM.L   (SP)+,A0-A6/D0-D7
         RTS

***
***      WORKING VARIABLES
***

MPOINT:  DC.B      0 
         EVEN
PLANE:   DCB.B     (320*256)/8,0
GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      0
OLDCOP:  DC.L      0
NEWCOP:  DC.L      $008E2C81,$00902CC1
         DC.L      $01800000,$01820FFF
         DC.L      $01001200,$01020000
PL:      DC.L      $00E00000,$00E20000
         DC.L      $FFFFFFFE


