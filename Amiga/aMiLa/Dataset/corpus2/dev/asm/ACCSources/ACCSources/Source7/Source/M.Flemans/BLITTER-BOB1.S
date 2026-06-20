***  TITLE  :  BLITTER-BOB1.S
***  CODER  :  MARK FLEMANS
***  DATE   :  22/11/90

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
         SWAP      D0
         ADD.L     #3000,D0
         MOVE.W    D0,SP2L
         SWAP      D0
         MOVE.W    D0,SP2H
         SWAP      D0
         ADD.L     #3000,D0
         MOVE.W    D0,SP3L
         SWAP      D0
         MOVE.W    D0,SP3H
         SWAP      D0
         ADD.L     #3000,D0
         MOVE.W    D0,SP4L
         SWAP      D0
         MOVE.W    D0,SP4H
         SWAP      D0
         ADD.L     #3000,D0
         MOVE.W    D0,SP5L
         SWAP      D0
         MOVE.W    D0,SP5H
         
         MOVE.L    GFXBSE,A1
         MOVE.L    38(A1),OLDCOP
         MOVE.L    #NEWCOP,$DFF080          ; Run new Copperlist

         BSR       ROUTINE                  ; Do Blit

MOUSE:   BTST      #6,$BFE001               ; Is LMB pressed ?
         BNE       MOUSE                    ; No, OK loop

         MOVE.W    #$8020,$DFF096           ; Turn sprite DMA off
         MOVE.L    OLDCOP,$DFF080           ; Restore Old-copper
         MOVE.L    4,A6                     ; Get EXEC-Base
         JSR       -138(A6)                 ; Permit Multitasking

MOI:     MOVEM.L   (SP)+,D0-D7/A0-A6        ; Re-load registers
         MOVEQ     #0,D0
END:     RTS

* ------------------------------------------------------------------------

ROUTINE: LEA       BOB,A0                   ; Find BOB address
         LEA       SCREEN,A1                ; Find SCREEN address
         ADD.W     #11,A1
         MOVEQ     #4,D2                    ; No. of planes -1

BTEST:   BTST      #14,$DFF002              ; Is Blitter free ?
         BNE.S     BTEST                    ; No, OK loop 
  
         MOVE.L    A0,$DFF050               ; Set BLTAPTH
         MOVE.L    A1,$DFF054               ; Set BLTDPTH
         CLR.W     $DFF064                  ; No source A Modulo
         MOVE.W    #24,$DFF066              ; Set BLTDMOD
         MOVE.W    #$FFFF,$DFF044           ; Set BLTAFWM
         MOVE.W    #$FFFF,$DFF046           ; Set BLTDLWM
         MOVE.W    #$09F0,$DFF040           ; Set BLTCON0
         CLR.W     $DFF042                  ; Set BLTCON1
         MOVE.W    #%0000111010001000,$DFF058 ; Set BLTSIZE (128*58)
         ADD.W     #928,A0                  ; Next BOB plane
         ADD.W     #3000,A1                 ; Next SCREEN plane
         DBRA      D2,BTEST                 ; Do next plane
         RTS                                ; End routine

* -----------------------------------------------------------------------

GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $0000
OLDCOP:  DC.L      $0000
         EVEN
BOB:     INCBIN    "club7:BITMAPS/BOB5.RAW",0
         EVEN
SCREEN:  DCB.B     3000*5,0

* ------------------------------------------------------------------------

NEWCOP:  DC.W     $008E,$2c81,$0090,$2cc1
         DC.W     $0092,$0038,$0094,$00D0
         DC.W     $0108,$0000,$010A,$0000
         DC.W     $00E0
SP1H:    DC.W     $0000,$00E2
SP1L:    DC.W     $0000,$00E4
SP2H:    DC.W     $0000,$00E6
SP2L:    DC.W     $0000,$00E8
SP3H:    DC.W     $0000,$00EA
SP3L:    DC.W     $0000,$00EC
SP4H:    DC.W     $0000,$00EE
SP4L:    DC.W     $0000,$00F0
SP5H:    DC.W     $0000,$00F2
SP5L:    DC.W     $0000
         DC.W     $0180,$0000,$0182,$0FFF,$0184,$04F0,$0186,$02E0
         DC.W     $0188,$00C0,$018A,$00A0,$018C,$0080,$018E,$0060
         DC.W     $0190,$0880,$0192,$0660,$0194,$0440,$0196,$0220
         DC.W     $0198,$0880,$019A,$0880,$019C,$0000,$019E,$0000
         DC.W     $01A0,$0F00,$01A2,$0FF0,$01A4,$0EE0,$01A6,$0DC0
         DC.W     $01A8,$0DB0,$01AA,$0CA0,$01AC,$0B90,$01AE,$0A80
         DC.W     $01B0,$0970,$01B2,$0960,$01B4,$0850,$01B6,$0740
         DC.W     $01B8,$0640,$01BA,$0630,$01BC,$0530,$01BE,$0420

         DC.W     $0100,$5200,$6009,$FFFE,$0100,$0000,$FFFF,$FFFE

* ------------------------------------------------------------------------
*   END OF SOURCE
* ------------------------------------------------------------------------

