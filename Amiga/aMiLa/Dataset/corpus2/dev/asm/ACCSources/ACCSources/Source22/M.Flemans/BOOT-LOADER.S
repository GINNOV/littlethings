***
***      BOOT-LOADER.S
***      BY MARK FLEMANS
***      DATE 30.12.91

         SECTION loader,CODE_C
         OPT     C-

         DC.B    "DOS",$0
         DC.L    $0
         DC.L    $00000370

MAIN:    MOVE.L  #$2400,$24(A1)
         MOVE.L  #$30000,$28(A1)
         MOVE.L  #$D6800,$2C(A1)
         MOVE.W  #2,$1C(A1)
         JSR     -$1C8(A6)
         MOVEM.L D0-D7/A0-A6,-(SP)
         JSR     $30000
         MOVEM.L (SP)+,D0-D7/A0-A6
         MOVEQ   #0,D0
         RTS

         EVEN

         DC.B "                                   "
         DC.B "THIS IS NOT A BOOT-BLOCK VIRUS     "
