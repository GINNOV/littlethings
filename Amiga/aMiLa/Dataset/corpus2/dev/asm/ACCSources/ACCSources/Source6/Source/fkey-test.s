*  TITLE  :  FKEY-TEST.S
*  AUTHOR :  MARK FLEMANS
*  DATE   :  09/10/90

   SECTION f-key,CODE_C

   OPT C-

*
*  START OF CODE
*

BEG:     MOVEM.L   D0-D7/A0-A6,-(SP)   ; Save registers

         MOVE.L    4,A6                ; Get EXEC-Base
         MOVEQ     #0,D0               ; Any version
         LEA       DOSNAM(PC),A1       ; Point to library name
         JSR       -552(A6)            ; Open library
         MOVE.L    D0,DOSBSE           ; Save base address

         MOVE.L    DOSBSE,A6           ; Get DOS-Base
         JSR       -60(A6)             ; Get output handel
         MOVE.L    D0,CONHDLE          ; Save window number
         MOVE.L    DOSBSE,A6           ; Get DOS-Base
         MOVE.L    CONHDLE,D1          ; Standard CLI window
         MOVE.L    #TEXT,D2            ; Point to text address
         MOVE.L    #44,D3              ; Length of text
         JSR       -48(A6)             ; Outout text

LOOP:    MOVE.B    $BFEC01,D0          ; Get character
         NOT       D0                  ; Reverse it
         ROR.B     #1,D0               ; Rotate right once
         CMP.B     #$59,D0             ; Check for F10 key
         BHI       LOOP                ; Loop if greater
         CMP.B     #$4F,D0             ; Check for F1 key
         BLS       LOOP                ; Loop if smaller
         
         SUB.B     #$50,D0             ; Get numeric value
         ADD.B     #1,D0              
         CMP.B     #1,D0               ; Is it 1 ?
         BNE.S     NEXT1               ; Check next one
         MOVE.L    #COM1,D2            ; Find text address
         BRA       PRINT
NEXT1:   CMP.B     #2,D0               ; Is it 2 ?
         BNE.S     NEXT2               ; Check next one
         MOVE.L    #COM2,D2            ; Find text address
         BRA       PRINT
NEXT2:   CMP.B     #3,D0               ; Is it 3 ?
         BNE.S     NEXT3               ; Check next one
         MOVE.L    #COM3,D2            ; Find text address
         BRA       PRINT
NEXT3:   CMP.B     #4,D0               ; Is it 4 ?
         BNE.S     NEXT4               ; Check next one
         MOVE.L    #COM4,D2            ; Find text address
         BRA       PRINT
NEXT4:   CMP.B     #5,D0               ; Is it 5 ?
         BNE.S     NEXT5               ; Check next one
         MOVE.L    #COM5,D2            ; Find text address
         BRA       PRINT
NEXT5:   CMP.B     #6,D0               ; Is it 6 ?
         BNE.S     NEXT6               ; Check next one
         MOVE.L    #COM6,D2            ; Find text address
         BRA       PRINT
NEXT6:   CMP.B     #7,D0               ; Is it 7 ?
         BNE.S     NEXT7               ; Check next one
         MOVE.L    #COM7,D2            ; Find text address
         BRA       PRINT
NEXT7:   CMP.B     #8,D0               ; Is it 8 ?
         BNE.S     NEXT8               ; Check next one
         MOVE.L    #COM8,D2            ; Find text address
         BRA       PRINT
NEXT8:   CMP.B     #9,D0               ; Is it 9 ?
         BNE.S     NEXT9               ; Check next one
         MOVE.L    #COM9,D2            ; Find text address
         BRA       PRINT
NEXT9:   MOVE.L    #COM10,D2           ; Find text address
PRINT:   MOVE.L    CONHDLE,D1          ; Standard CLI Window
         MOVE.L    #4,D3               ; Length of text
         MOVE.L    DOSBSE,A6           ; Get DOS-Base
         JSR       -48(A6)             ; Output text

         MOVE.L    CONHDLE,D1          ; Standard CLI Window
         MOVE.L    #TEXT3,D2           ; Point to text address
         MOVE.L    #33,D3              ; Length of text
         MOVE.L    DOSBSE,A6           ; Get DOS-Base
         JSR       -48(A6)             ; Outout text

MSLOOP:  BTST      #6,$BFE001          ; Is LMB pressed ?
         BNE       MSLOOP              ; No, then loop
         
OUT:     MOVEM.L   (SP)+,D0-D7/A0-A6   ; Re-load registers
         MOVEQ     #0,D0               ; No CLI error
         RTS                           ; End

*
*  EQUATES ETC..
*

DOSNAM:  DC.B      "dos.library",0
         EVEN
DOSBSE:  DC.L      $00000000
         EVEN
CONHDLE: DC.L      $00000000
         EVEN
TEXT:    DC.B      $A,"PRESS ANY FUNCTION KEY BETWEEN F1 AND F10",$A,$A
         EVEN
COM1:    DC.B      " F1 ",0
COM2:    DC.B      " F2 ",0
COM3:    DC.B      " F3 ",0
COM4:    DC.B      " F4 ",0
COM5:    DC.B      " F5 ",0
COM6:    DC.B      " F6 ",0
COM7:    DC.B      " F7 ",0
COM8:    DC.B      " F8 ",0
COM9:    DC.B      " F9 ",0
COM10:   DC.B      " F10",0
         EVEN
TEXT3:   DC.B      $A,$A,"PRESS LEFT MOUSE BUTTON TO QUIT",0

*
*  END OF SOURCE CODE
*

