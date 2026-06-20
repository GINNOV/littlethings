*
*     INTUITION-MENU
*     BY MARK FLEMANS
*     DATE : 28.07.91
*
*     OPENS AN INTUITION SCREEN, WITH WINDOW & MENU BAR
*
 
      SECTION output,CODE_C
      OPT C-
 
*
 
INIT:   MOVE.L  4,A6                     ; GET EXEC-BASE
        MOVEQ   #0,D0                    ; ANY LIBRARY VERSION
        LEA     INTNAM(PC),A1            ; GET LIBRARY NAME ADDRESS
        JSR     -552(A6)                 ; OPEN LIBRARY
        TST     D0                       ; IS IT ALRIGHT ?
        BEQ     ERROR                    ; NO, EXIT
        MOVE.L  D0,INTBSE                ; STORE LIBRARY-BASE

        LEA     SCRDEF(PC),A0            ; SET UP SCREEN DEFINITIONS
        MOVE.L  INTBSE,A6                ; GET INTUITION-BASE
        JSR     -198(A6)                 ; OPEN SCREEN
        MOVE.L  D0,SCRHD                 ; STORE SCREEN HANDLE
       
        MOVE.L  INTBSE,A6                ; GET INTUITION-BASE
        LEA     WINDEF(PC),A0            ; SET UP WINDOW STRUCTURE
        JSR     -204(A6)                 ; OPEN WINDOW ON SCREEN
        MOVE.L  D0,WINHD                 ; STORE WINDOW HANDLE

        MOVE.L  INTBSE,A6                ; GET INTUITION-BASE
        MOVE.L  WINHD,A0                 ; SET UP WINDOW STRUCTURE
        LEA     SCRMNU(PC),A1            ; SET UP MENU STRUCTURE
        JSR     -264(A6)                 ; INSERT MENU STRIP

        LEA     BORDER,A1                ; SET UP BORDER ADDRESS
        MOVE.W  #200,D0                  ; SET UP X-COORDINATE
        MOVE.W  #15,D1                   ; SET UP Y-COORDINATE
        MOVE.L  INTBSE,A6                ; GET INTUITION-BASE
        MOVE.L  WINHD,A0                 ; SET UP WINDOW STRUCTURE
        MOVE.L  50(A0),A0                ; GET RASTPORT ADDRESS
        JSR     -108(A6)                 ; DRAW BORDER

MAIN:   MOVE.L  4,A6                     ; GET EXEC-BASE
        MOVE.L  WINHD,A0                 ; SET UP WINDOW STRUCTURE
        MOVE.L  86(A0),A0                ; GET PORT OFFSET
        JSR     -372(A6)                 ; GET MESSAGE FROM PORT
        TST     D0                       ; TEST IT
        BEQ     MAIN                     ; NO, OK LOOP BACK
        MOVE.L  D0,A0                    ; GET ADDRESS
        MOVE.L  20(A0),D6                ; GET OFFSET FOR WINDOW
        CMPI.W  #$200,D6                 ; WAS IT CLOSE WINDOW
        BNE     CHK1                     ; NO, CHECK FOR MENU OPTIONS
        JMP     RMM                      ; OK, JUMP OUT

CHK1:   CMPI.W  #$100,D6                 ; ANY MENU OPTIONS CHOOSEN
        BNE     MAIN                     ; NO, OK LOOP BACK
 
CHKMNU: MOVE.W  24(A0),D7                ; GET EVENT STRUCTURE
        MOVE.W  D7,D6                    ; MOVE IT
        LSR     #8,D7                    ; SHIFT IT ELEVEN TIMES
        LSR     #3,D7                    ; SUB MENU IN D7
        CLR.L   D5
        ROXR    #1,D6
        ROXL    #1,D5                    ; MENU NUMBER IN D5
        AND.L   #$7F,D6
        CMP     #$7F,D6
        BEQ     MAIN
        LSR     #4,D6                    ; MENU ITEM IN D6
        CMPI.B  #0,D5                    ; IS OPTION IN FIRST MENU
        BNE     MAIN                     ; NO, OK LOOP BACK
        CMPI.B  #1,D6                    ; IS OPTION NUMBER 2 (QUIT)
        BNE     MAIN                     ; NO, OK LOOP BACK

RMM:    MOVE.L  INTBSE,A6                ; GET INTUITION-BASE
        MOVE.L  SCRHD,A0                 ; SET UP WINDOW STRUCTURE
        JSR     -54(A6)                  ; REMOVE MENU STRIP

        MOVE.L  INTBSE,A6                ; GET INTUITION-BASE
        MOVE.L  WINHD,A0                 ; SET UP WINDOW STRUCTURE
        JSR     -72(A6)                  ; CLOSE WINDOW

        MOVE.L  INTBSE,A6                ; GET INTUITION-BASE
        MOVE.L  SCRHD,A0                 ; SET UP SCREEN HANDLE
        JSR     -66(A6)                  ; CLOSE SCREEN
       
        MOVE.L  INTBSE,A1                ; SET UP INTUTION-BASE
        MOVE.L  4,A6                     ; GET EXEC-BASE
        JSR     -414(A6)                 ; CLOSE LIBRARY
ERROR:  MOVEQ   #0,D0                    ; NO ERRORS
        RTS

*
 
INTNAM: DC.B "intuition.library",0       ; INTUITION LIBRARY NAME
INTBSE: DC.L 0                           ; INTUITION LIBRARY BASE
        EVEN

SCRDEF: DC.W 0,0,640,400                 ; WINDOW X,Y WIDTH & HEIGHT
        DC.W 2                           ; NUMBER OF PLANES
        DC.B 0,1                         ; TEXT & BACKGROUND COLOUR
        DC.W $8002,15                    ; VIEW MODE & TYPE
        DC.L 0,SCRNAM                    ; NORMAL FONT & TITLE TEXT
        DC.L 0,0                         ; GADGETS & BITMAP
SCRNAM: DC.B "DISPLAY BOOT v1.0 by Mark Flemans",0 ; SCREEN TITLE
        EVEN

SCRMNU: DC.L 0                           ; NEXT MENU POINTER
        DC.W 10,30                       ; X AND Y POSITION
        DC.W 80,10                       ; WIDTH AND HEIGHT OF MENU TITLE
        DC.W 1                           ; MENU AVAILABLE
        DC.L MNUNAM                      ; TITLE TEXT
        DC.L MNUI01                      ; POINTER FIRST MENU ITEM
        DC.W 0,0,0,0                     ; RESERVED
MNUNAM: DC.B "MISC",0
        EVEN
MNUI01: DC.L MNUI02
        DC.W 0,0,162,8,$56
        DC.L 0
        DC.L MNUT01
        DC.L 0
        DC.B "A"
        EVEN
        DC.L 0
        DC.W 0
MNUT01: DC.B 0,1,0
        EVEN
        DC.W 5,0
        DC.L 0
        DC.L MTXT01
        DC.L 0
MTXT01: DC.B "ABOUT",0
        EVEN
MNUI02: DC.L 0
        DC.W 0,10,162,8,$56
        DC.L 0
        DC.L MNUT02
        DC.L 0
        DC.B "Q"
        EVEN
        DC.L 0
        DC.W 0
MNUT02: DC.B 0,1,0
        EVEN
        DC.W 5,0
        DC.L 0
        DC.L MTXT02
        DC.L 0
MTXT02: DC.B "QUIT",0
        EVEN
WINHD:  DC.L 0
        EVEN
WINDEF: DC.W 0,10
        DC.W 640,255
        DC.B 0,1
        DC.L $300,$100F,0,0
        DC.L WINNAM
SCRHD:  DC.L 0                           ; SCREEN HANDLE
        DC.L 0
        DC.W 640,400,640,400,15
WINNAM: DC.B "BOOT-BLOCK",0
 EVEN
BORDER: DC.W 0,0
        DC.B 3,0
        DC.B 0,5
        DC.L CRTAB
        DC.L 0
CRTAB:  DC.W 0,0,425,0,425,190,0,190,0,0

