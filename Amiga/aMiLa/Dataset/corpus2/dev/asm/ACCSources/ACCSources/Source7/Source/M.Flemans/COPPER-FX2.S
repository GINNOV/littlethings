***  TITLE  :  COPPER-FX2.S
***  CODER  :  MARK FLEMANS
***  DATE   :  21/11/90

         SECTION chip_memory_please,CODE_C        

         OPT C-     


START:   MOVEM.L   D0-D7/A0-A6,-(SP)        ; Save registers
         MOVE.L    4,A6                     ; Get EXEC-Base
         JSR       -132(A6)                 ; Forbid Multitasking

         MOVE.L    4,A6                     ; Get EXEC-base
         MOVEQ     #0,D0                    ; Any version
         LEA       GFXNAM(PC),A1            ; Point to library name
         JSR       -552(A6)                 ; Open GFX library
         MOVE.L    D0,GFXBSE                ; Save base address

         MOVE.W    #$0020,$DFF096           ; Turn sprite DMA off

         MOVE.L    #SCREEN,D0               ; Define screen plane
         MOVE.W    D0,SP1L
         SWAP      D0
         MOVE.W    D0,SP1H

         MOVE.L    GFXBSE,A1
         MOVE.L    38(A1),OLDCOP
         MOVE.L    #NEWCOP,$DFF080          ; Run new Copperlist

LOOP:    CMPI.B    #$F0,$DFF006
         BNE.S     LOOP

         BSR       ROUTINE

         BTST      #6,$BFE001
         BNE       LOOP

         MOVE.W    #$8020,$DFF096           ; Turn sprite DMA off
         MOVE.L    OLDCOP,$DFF080           ; Restore Old-copper
         MOVE.L    4,A6                     ; Get EXEC-Base
         JSR       -138(A6)                 ; Permit Multitasking

MOI:     MOVEM.L   (SP)+,D0-D7/A0-A6        ; Re-load registers
         MOVEQ     #0,D0
END:     RTS

* ------------------------------------------------------------------------

ROUTINE: LEA       COLSTRT,A0
         ADD.L     #6,A0
         MOVE.W    (A0),COLSAVE1
         MOVE.W    #19,D2
CPL:     MOVE.L    A0,A3
         ADD.L     #8,A0
         MOVE.W    (A0),(A3)
         DBRA      D2,CPL
         LEA       COLSTOP,A0
         MOVE.W    COLSAVE1,6(A0)
         RTS

* -----------------------------------------------------------------------

GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $0000
OLDCOP:  DC.L      $0000
COLSAVE1:DC.W      $0000
         EVEN
SCREEN:  DCB.B     40*256,0

* ------------------------------------------------------------------------

NEWCOP:  DC.W     $008E,$2c81,$0090,$2cc1
         DC.W     $0092,$0038,$0094,$00D0
         DC.W     $0108,$0000,$010A,$0000
         DC.W     $0182,$0FFF,$00E0
SP1H:    DC.W     $0000,$00E2
SP1L:    DC.W     $0000               
         DC.W     $0180,$0000,$0100,$1200
         DC.W     $2501,$FFFE,$0180,$0000
         
COLSTRT: DC.W     $3009,$FFFE,$0180,$0000
         DC.W     $3209,$FFFE,$0180,$0001
         DC.W     $3409,$FFFE,$0180,$0002
         DC.W     $3609,$FFFE,$0180,$0003
         DC.W     $3809,$FFFE,$0180,$0004
         DC.W     $3A09,$FFFE,$0180,$0005
         DC.W     $3C09,$FFFE,$0180,$0006
         DC.W     $3E09,$FFFE,$0180,$0007
         DC.W     $4009,$FFFE,$0180,$0008
         DC.W     $4209,$FFFE,$0180,$0009
         DC.W     $4409,$FFFE,$0180,$000A
         DC.W     $4609,$FFFE,$0180,$0009
         DC.W     $4809,$FFFE,$0180,$0008
         DC.W     $4A09,$FFFE,$0180,$0007
         DC.W     $4C09,$FFFE,$0180,$0006
         DC.W     $4E09,$FFFE,$0180,$0005
         DC.W     $5009,$FFFE,$0180,$0004
         DC.W     $5209,$FFFE,$0180,$0003
         DC.W     $5409,$FFFE,$0180,$0002
         DC.W     $5609,$FFFE,$0180,$0001
COLSTOP: DC.W     $5809,$FFFE,$0180,$0000
         DC.W     $5A09,$FFFE,$0180,$0000

         DC.W     $FFFF,$FFFE

* ------------------------------------------------------------------------
*   END OF SOURCE
* ------------------------------------------------------------------------

