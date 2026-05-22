*  TITLE  :  FKEY-MENU.S
*  AUTHOR :  MARK FLEMANS 
*  DATE   :  14/10/90

         SECTION monty_python,CODE_C

         OPT C-

*
*  START OF CODE
*

BEG:     MOVEM.L   D0-D7/A0-A6,-(SP)   ; Save registers
         MOVE.L    4,A6                ; Get EXEC-Base
         JSR       -132(A6)            ; Forbid Multitasking
         
         MOVE.L    4,A6                ; Get EXEC-Base
         MOVEQ     #0,D0               ; Any version
         LEA       GFXNAM(PC),A1       ; Point to name address
         JSR       -552(A6)            ; Open library
         MOVE.L    D0,GFXBSE           ; Store GFX-Base
         MOVE.L    4,A6                ; Get EXEC-Base
         MOVEQ     #0,D0               ; Any version
         LEA       DOSNAM(PC),A1       ; Point to name address
         JSR       -552(A6)            ; Open library
         MOVE.L    D0,DOSBSE           ; Store DOS-Base

         MOVE.W    #$0020,$DFF096      ; Sprite DMA off
         MOVE.L    #LOGO,D0            ; Get LOGO-Base
         MOVE.W    D0,PL1L
         SWAP      D0
         MOVE.W    D0,PL1H
         SWAP      D0
         ADD       #$0C30,D0           ; Get next plane
         MOVE.W    D0,PL2L
         SWAP      D0
         MOVE.W    D0,PL2H
         SWAP      D0
         ADD       #$0C30,D0           ; Get next plane
         MOVE.W    D0,PL3L
         SWAP      D0
         MOVE.W    D0,PL3H
         SWAP      D0
         ADD       #$0C30,D0           ; Get next plane
         MOVE.W    D0,PL4L
         SWAP      D0
         MOVE.W    D0,PL4H
         SWAP      D0
         ADD       #$0C30,D0           ; Get next plane
         MOVE.W    D0,PL5L
         SWAP      D0
         MOVE.W    D0,PL5H
         MOVE.L    #TEXT1,D0           ; Get TEXT1-Base
         MOVE.W    D0,WH1L
         SWAP      D0
         MOVE.W    D0,WH1H
         MOVE.L    #TEXT2,D0           ; Get TEXT2-Base
         MOVE.W    D0,TX1L
         SWAP      D0
         MOVE.W    D0,TX1H
         MOVE.L    GFXBSE,A1
         MOVE.L    38(A1),OLDCOP       ; Save Old-copperlist
         MOVE.L    #NEWCOP,$DFF080     ; Insert New-copperlist

LOOP:    MOVE.B    $BFEC01,D0          ; Get character
         NOT       D0                  ; Reverse it
         ROR.B     #1,D0               ; Rotate right once
         CMP.B     #$52,D0             ; Check for F3 key
         BHI       LOOP                ; Loop if greater
         CMP.B     #$4F,D0             ; Check for F1 key
         BLS       LOOP                ; Loop if smaller

         MOVE.B    D0,FKEY             ; Save input F-KEY
         MOVE.L    OLDCOP,$DFF080      ; Restore Old-copper
         MOVE.L    4,A6                ; Get EXEC-Base
         MOVE.L    GFXBSE,A1           ; 
         JSR       -414(A6)            ; Close GFX Library
         MOVE.L    4,A6                ; Get EXEC-Base
         JSR       -138(A6)            ; Permit Multitasking

         MOVE.B    FKEY,D0             ; Re-load D0 with input
         CMP.B     #$50,D0             ; Is it F1 ?
         BNE.S     NEXT1               ; Check next one
         LEA       CONNAM(PC),A1
         MOVE.L    #1005,D0
         MOVE.L    A1,D1
         MOVE.L    D0,D2
         MOVE.L    DOSBSE,A6
         JSR       -30(A6)
         MOVE.L    D0,CONHDLE
         MOVE.L    DOSBSE,A6           ; Get DOS address
         MOVE.L    #COM1,D1
         CLR.L     D2                  ; No input
         MOVE.L    CONHDLE,D3
         JSR       -222(A6)            ; Execute command
         BRA       MOI
NEXT1:   CMP.B     #$51,D0             ; Is it F2 ?
         BNE.S     NEXT2               ; Check next one
         LEA       CONNAM(PC),A1
         MOVE.L    #1005,D0
         MOVE.L    A1,D1
         MOVE.L    D0,D2
         MOVE.L    DOSBSE,A6
         JSR       -30(A6)
         MOVE.L    D0,CONHDLE
         MOVE.L    DOSBSE,A6           ; Get DOS address
         MOVE.L    #COM2,D1
         CLR.L     D2                  ; No input
         MOVE.L    CONHDLE,D3
         JSR       -222(A6)            ; Execute command
         BRA       MOI
NEXT2:   LEA       CONNAM(PC),A1
         MOVE.L    #1005,D0
         MOVE.L    A1,D1
         MOVE.L    D0,D2
         MOVE.L    DOSBSE,A6
         JSR       -30(A6)
         MOVE.L    D0,CONHDLE
         MOVE.L    DOSBSE,A6           ; Get DOS address
         MOVE.L    #COM3,D1       
         CLR.L     D2                  ; No input
         MOVE.L    CONHDLE,D3
         JSR       -222(A6)            ; Execute command

MOI:     move.l    CONHDLE,d1          ; Close the con: window.
         move.l    DOSBSE,a6
         jsr       -36(a6)
         MOVEM.L   (SP)+,D0-D7/A0-A6   ; Re-load registers
         MOVE.W    #$8020,$DFF096      ; Sprite DMA on
END:     MOVEQ     #0,D0               ; No errors
         RTS                           ; End

*
*  PROGRAM VARIABLE STORES
*
 
         EVEN
OLDCOP:  DC.L      $00000000
         EVEN
GFXNAM:  DC.B      "graphics.library",0
         EVEN
GFXBSE:  DC.L      $00000000
         EVEN
DOSNAM:  DC.B      "dos.library",0
         EVEN
DOSBSE:  DC.L      $00000000
         EVEN

COM1:    DC.B      "1",0
         EVEN
COM2:    DC.B      "2",0
         EVEN
COM3:    DC.B      "3",0
         EVEN
FKEY:    DC.B      $00
         EVEN
CONHDLE: DC.L      $00000000
         EVEN
CONNAM:  DC.B      "CON:0/0/640/256/Now Loading ....",0

*
*  NEW COPPER-LIST
*

NEWCOP:  DC.W      $008E,$2C81,$0090,$2CC1
         DC.W      $0092,$0038,$0094,$00D0
         DC.W      $0108,$0000,$010A,$0000
         DC.W      $0180,$0DDD,$0182,$0FFF
         DC.W      $0184,$0000,$0186,$0000
         DC.W      $0188,$0000,$018A,$0000
         DC.W      $018C,$0000,$018E,$0000
         DC.W      $0190,$0FEE,$0192,$0CAA
         DC.W      $0194,$0B77,$0196,$0955
         DC.W      $0198,$0733,$019A,$0511
         DC.W      $019C,$0300,$019E,$0100
         DC.W      $01A0,$0FAA,$01A2,$0B55
         DC.W      $01A4,$0822,$01A6,$0400
         DC.W      $01A8,$0000,$01AA,$0000
         DC.W      $01AC,$0000,$01AE,$0000
         DC.W      $01B0,$0000,$01B2,$0000
         DC.W      $01B4,$0000,$01B6,$0000
         DC.W      $01B8,$0000,$01BA,$0000
         DC.W      $01BC,$0000,$01BE,$0000
         DC.W      $1D09,$FFFE,$0180,$0000
         DC.W      $2109,$FFFE,$0180,$0333
         DC.W      $2209,$FFFE,$0180,$0777
         DC.W      $2309,$FFFE,$0180,$0BBB
         DC.W      $2409,$FFFE,$0180,$0777
         DC.W      $2509,$FFFE,$0180,$0333
         DC.W      $2609,$FFFE,$0180,$0000
         DC.W      $2709,$FFFE,$0100,$5200
         DC.W      $00E0
PL1H:    DC.W      $0000,$00E2
PL1L:    DC.W      $0000,$00E4
PL2H:    DC.W      $0000,$00E6
PL2L:    DC.W      $0000,$00E8
PL3H:    DC.W      $0000,$00EA
PL3L:    DC.W      $0000,$00EC
PL4H:    DC.W      $0000,$00EE
PL4L:    DC.W      $0000,$00F0
PL5H:    DC.W      $0000,$00F2
PL5L:    DC.W      $0000

         DC.W      $7709,$FFFE,$0100,$0000
         DC.W      $7809,$FFFE,$0180,$0000
         DC.W      $7909,$FFFE,$0180,$0333
         DC.W      $7A09,$FFFE,$0180,$0777
         DC.W      $7B09,$FFFE,$0180,$0BBB
         DC.W      $7C09,$FFFE,$0180,$0777
         DC.W      $7D09,$FFFE,$0180,$0333
         DC.W      $7E09,$FFFE,$0180,$0000
         DC.W      $8009,$FFFE,$0100,$1200
         DC.W      $00E0
WH1H:    DC.W      $0000,$00E2
WH1L:    DC.W      $0000
         DC.W      $8A09,$FFFE,$0100,$0000
         DC.W      $8D09,$FFFE,$0180,$0000
         DC.W      $8E09,$FFFE,$0180,$0333
         DC.W      $8F09,$FFFE,$0180,$0777
         DC.W      $9009,$FFFE,$0180,$0BBB
         DC.W      $9109,$FFFE,$0180,$0777
         DC.W      $9209,$FFFE,$0180,$0333
         DC.W      $9309,$FFFE,$0180,$0000
         DC.W      $9909,$FFFE,$0100,$1200
         DC.W      $00E0
TX1H:    DC.W      $0000,$00E2
TX1L:    DC.W      $0000
         DC.W      $FFE1,$FFFE,$01FE,$0000
         DC.W      $0011,$FFFE,$0180,$0000 
         DC.W      $1109,$FFFE,$0180,$0333
         DC.W      $1209,$FFFE,$0180,$0777
         DC.W      $1309,$FFFE,$0180,$0BBB
         DC.W      $1409,$FFFE,$0180,$0777
         DC.W      $1509,$FFFE,$0180,$0333
         DC.W      $1609,$FFFE,$0180,$0000
         DC.W      $1709,$FFFE,$0100,$0000
         DC.W      $FFFF,$FFFE

*
*  GRAPHICS PLANES
*

LOGO:    INCBIN "source6:bitmaps/madness-logo3.bm"
         EVEN
TEXT1:   INCBIN "source6:bitmaps/what.bm"
         EVEN
TEXT2:   INCBIN "source6:bitmaps/which.bm"

*
*  END OF SOURCE
*

