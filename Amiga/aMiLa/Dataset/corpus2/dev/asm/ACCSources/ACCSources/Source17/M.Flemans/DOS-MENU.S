*
*     DOS-MENU
*     BY MARK FLEMANS
*     DATE : 11.08.91
*
*     DISPLAYS MENU AND EXECUTES THE SPECIFIED FILE
*
 
      SECTION anti-perspirant,CODE_C
      OPT C-
 
*
 
INIT:   MOVE.L  4,A6                     ; GET EXEC-BASE
        MOVEQ   #0,D0                    ; ANY LIBRARY VERSION
        LEA     DOSNAM(PC),A1            ; GET LIBRARY NAME ADDRESS
        JSR     -552(A6)                 ; OPEN LIBRARY
        TST     D0                       ; IS IT ALRIGHT ?
        BEQ     ERROR                    ; NO, EXIT
        MOVE.L  D0,DOSBSE                ; STORE LIBRARY-BASE

        MOVE.L  DOSBSE,A6                ; GET DOS-BASE
        JSR     -60(A6)                  ; FIND OUTPUT HANDLE

        MOVE.L  DOSBSE,A6                ; GET DOS-BASE
        MOVE.L  D0,D1                    ; SET FILE HANDLE
        MOVE.L  #MENU,D2                 ; SET ADDRESS OF MENU TEXT
        MOVE.L  #MEND-MENU,D3            ; SET LENGHT OF MENU
        JSR     -48(A6)                  ; WRITE IT TO SCREEN

LOOP:   MOVE.B  $BFEC01,D0               ; GET CHARACTER
        NOT     D0                       ; REVERSE IT
        ROR.B   #1,D0                    ; ROTATE RIGHT ONCE
        CMP.B   #$53,D0                  ; CHECK FOR F4 KEY
        BHI     LOOP                     ; LOOP IF GREATER
        CMP.B   #$4F,D0                  ; CHECK FOR F1 KEY
        BLS     LOOP                     ; LOOP IF SMALLER
        MOVE.B  D0,FKEY                  ; SAVE INPUT F-KEY

        MOVE.L  DOSBSE,A6                ; GET DOS-BASE
        CLR.L   D3                       ; POINT TO MAIN WINDOW
        MOVEQ   #0,D0 
        LEA     FKEY,A0                  ; GET ADDRESS OF FKEY
        MOVE.B  (A0),D0                  ; GET FKEY VALUE
        SUB.B   #$50,D0                  ; GET TRUE VALUE
        MOVE.L  #8,D1                    ; LENGTH OF COM1 STRING
        MULU    D0,D1                    ; CALCULATE OFFSET
        ADD.L   #COM1,D1                 ; POINT TO COMMAND
        CLR.L   D2                       ; NO INPUT CLI
        JSR     -222(A6)                 ; EXECUTE COMMAND
        MOVE.L  4,A6                     ; GET EXEC-BASE
        MOVE.L  DOSBSE,A1                ; SET UP DOS-BASE
        JSR     -414(A6)                 ; CLOSE LIBRARY

ERROR:  RTS

*
 
DOSNAM: DC.B "dos.library",0             ; DOS LIBRARY NAME
DOSBSE: DC.L 0                           ; DOS LIBRARY BASE
SCRHAN: DC.L 0                           ; SCREEN HANDLE
FKEY:   DC.B 0                           ; F-KEY VALUE STORE
        EVEN
COM1:   DC.B "X S/B1",0,0                ; F1 POINTS TO THIS
COM2:   DC.B "X S/B2",0,0                ; F2 POINTS TO THIS
COM3:   DC.B "X S/B3",0,0                ; F3 POINTS TO THIS
COM4:   DC.B "X S/B4",0,0                ; F4 POINTS TO THIS
        EVEN
MENU:   DC.B $0C,$9B,"4",$42             ; THE TEXT FOR THE MENU
        DC.B $9B,"0;30;40m","                       "
        DC.B $9B,"7;31;41m","                                  ",$0A
        DC.B $9B,"0;30;40m","                       "
        DC.B $9B,"7;31;43m","        THE NAME-LESS CREW        ",$0A
        DC.B $9B,"0;30;40m","                       "
        DC.B $9B,"7;31;41m","                                  ",$0A
        DC.B $0A
        DC.B $9B,"0;30;40m","               "
        DC.B $9B,"0;33;40m","-------------------------"
        DC.B $9B,"0;33;40m","-------------------------",$0A
        DC.B $0A,$9B,"0;31;40m"
        DC.B "                            F1 ..... LLAMATRON 2112 ",$0A
        DC.B "                            F2 ..... SKYFIGHT       ",$0A
        DC.B "                            F3 ..... ROLLERPEDE ",$0A    
        DC.B "                            F4 ..... RINGS OF ZON",$0A,$0A
        DC.B $9B,"0;32;40m"
        DC.B "                       DISK COMPILED BY  THE LAME-SCUMBAG"
        DC.B $0A,$0A,$9B,"0;30;40m","               "
        DC.B $9B,"0;33;40m","-------------------------"
        DC.B $9B,"0;33;40m","-------------------------",$0A
        DC.B $9B,$30,$20,$70
MEND:   DC.B 0                           ; THE END OF THE MENU TEXT

*

