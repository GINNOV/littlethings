*  TITLE  :  RUNNIT.S
*  AUTHOR :  MARK FLEMANS
*  DATE   :  09/10/90

   SECTION execute,CODE_C

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

         MOVE.L    DOSBSE,A6           ; Get DOS address
         MOVE.L    #COMMAND,D1         ; Point to command
         CLR.L     D2                  ; No input
         CLR.L     D3                  ; Standard CLI window
         JSR       -222(A6)            ; Execute command
         MOVEM.L   (SP)+,D0-D7/A0-A6   ; Re-load registers
         MOVEQ     #0,D0               ; No CLI error
         RTS                           ; End

*
*  EQUATES ETC..
*

DOSNAM:  DC.B      "dos.library",0
         EVEN
DOSBSE:  DC.L      $00000000
         EVEN
COMMAND: DC.B      "DIR",0

*
*  END OF SOURCE CODE
*

