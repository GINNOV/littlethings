***  TITLE  :  COPPER-FX1.S
***  CODER  :  MARK FLEMANS
***  DATE   :  18/11/90

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

ROUTINE: CMPI.W    #75,CFLAG1
         BNE.S     COPUP
         CMPI.W    #75,CFLAG2
         BNE.S     COPDOWN
         CLR.W     CFLAG1
         CLR.W     CFLAG2
         RTS

COPUP:   LEA       MOTHER,A0
         ADD.L     #1,A0
         MOVE.W    #8,D2    
CUL:     ADD.B     #2,(A0)
         ADD.L     #16,A0
         DBRA      D2,CUL
         ADDI.W    #1,CFLAG1
         RTS

COPDOWN: LEA       MOTHER,A0
         ADD.L     #1,A0
         MOVE.W    #8,D2    
CDL:     SUB.B     #2,(A0)
         ADD.L     #16,A0
         DBRA      D2,CDL
         ADDI.W    #1,CFLAG2
         RTS

* -----------------------------------------------------------------------

GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $0000
OLDCOP:  DC.L      $0000
CFLAG1:  DC.W      $0000
CFLAG2:  DC.W      $0000
         EVEN
SCREEN:  DCB.B     40*256,0

* ------------------------------------------------------------------------

NEWCOP:  DC.W     $008E,$2c81,$0090,$2cc1
         DC.W     $0092,$0038,$0094,$00D0
         DC.W     $0108,$0000,$010A,$0000
         DC.W     $0182,$0FFF,$00E0
SP1H:    DC.W     $0000,$00E2
SP1L:    DC.W     $0000               
         DC.W     $2501,$FFFE,$0100,$1200
         DC.W     $3009,$FFFE,$0180,$0004
MOTHER:  DC.W     $3041,$FFFE,$0180,$0FFF
         DC.W     $3109,$FFFE,$0180,$0008
         DC.W     $3141,$FFFE,$0180,$0FFF
         DC.W     $3209,$FFFE,$0180,$000C
         DC.W     $3241,$FFFE,$0180,$0FFF
         DC.W     $3309,$FFFE,$0180,$000F
         DC.W     $3341,$FFFE,$0180,$0FFF
         DC.W     $3409,$FFFE,$0180,$000F
         DC.W     $3441,$FFFE,$0180,$0FFF
         DC.W     $3509,$FFFE,$0180,$000F
         DC.W     $3541,$FFFE,$0180,$0FFF
         DC.W     $3609,$FFFE,$0180,$000C
         DC.W     $3641,$FFFE,$0180,$0FFF
         DC.W     $3709,$FFFE,$0180,$0008
         DC.W     $3741,$FFFE,$0180,$0FFF
         DC.W     $3809,$FFFE,$0180,$0004
         DC.W     $3841,$FFFE,$0180,$0000

         DC.W     $FFFF,$FFFE

* ------------------------------------------------------------------------
*   END OF SOURCE
* ------------------------------------------------------------------------

