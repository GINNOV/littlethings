**
**      PROGRAM : FORTUNE-COOKIE.S
**      AUTHOR  : MARK FLEMANS
**      DATE    : 15.09.91
**
**      USEAGE  : COOKIE ? - JUST TYPE THE PROGRAM NAME, ELSE IF IT HAS
**                          A QUESTION MARK IT WILL GIVE MORE INFO.
**
**

        SECTION cookie,CODE_C
        OPT     C-

**
 
START:  MOVEM.L D0/A0,-(SP)            ; SAVE REGISTERS
        MOVE.L  4,A6                   ; GET EXEC-BASE
        MOVEQ   #0,D0                  ; ANY VERSION
        LEA     DOSNAM,A1              ; GET LIBRARY NAME
        JSR     -552(A6)               ; OPEN LIBRARY
        TST.L   D0
        BEQ     ERROR                  ; BRANCH IF CANNOT OPEN IT
        MOVE.L  D0,DOSBSE              ; STORE LIBRARY-BASE

        MOVEM.L (SP)+,D0/A0            ; RE-LOAD REGISTERS
        SUBQ.W  #1,D0                  ; FIND NUMBER OF CHARACTERS -1
        BEQ     CHKRET                 ; IGNORE DO REST OF COOKIE
        MOVE.B  (A0),D0                ; OK, GET INPUT CHARACTER
        CMP.B   #63,D0                 ; IS IT ? , IE INFO CHARACTER
        BNE     CHKRET                 ; NO, CONTINUE PROGRAM
        MOVE.L  DOSBSE,A6              ; GET DOS-BASE
        JSR     -60(A6)                ; GET OUTPUT HANDLE
        MOVE.L  D0,D1                  ; OUTPUT CHANNEL
        MOVE.L  #INFO,D2               ; ADDRESS OF INFO TEXT
        MOVE.L  #INFOE-INFO,D3         ; LENGHT OF TEXT
        JSR     -48(A6)                ; WRITE OUTPUT
        BRA     CLOSE                  ; JUMP TO EXIT ROUTINE
 
CHKRET  MOVEQ   #0,D0                  ; CLEAR D0
        MOVE.W  $DFF006,D0             ; GET A RANDOM NUMBER ( VHPOSR )
        LSR     #8,D0                  ; SHIFT IT
        LSR     #5,D0                  ; MORE TO GET A SMALL NUMBER
        MOVE.B  D0,CCPTR               ; SAVE POINTER

        MOVE.L  DOSBSE,A6              ; GET DOS-BASE
        JSR     -60(A6)                ; GET OUTPUT HANDLE
        MOVE.L  D0,D1                  ; OUTPUT CHANNEL
        MOVE.L  #FCMAIN,D2             ; ADDRESS OF MAIN TEXT
        MOVE.L  #34,D3                 ; LENGHT OF TEXT
        JSR     -48(A6)                ; WRITE OUTPUT

        MOVE.L  DOSBSE,A6              ; GET EXEC-BASE
        JSR     -60(A6)                ; FIND OUTPUT CLI WINDOW
        MOVE.L  D0,D1                  ; SET UP FOR OUTPUT
        MOVEQ   #0,D2
        LEA     FCTEXT(PC),A0          ; GET BASE OUTPUT TEXT ADDRESS
        MOVE.B  CCPTR,D2               ; GET RANDOM VALUE FROM POINTER
        MULU    #44,D2                 ; MULTIPLY TO FIND OFFSET
        MOVE.L  A0,D0 
        ADD.L   D0,D2                  ; TEXT OUTPUT ADDRESS NOW IN D2
        MOVE.L  #44,D3                 ; LENGHT OF TEXT OUTPUT
        JSR     -48(A6)                ; WRITE OUTPUT

CLOSE:  MOVE.L  4,A6                   ; GET EXEC-BASE
        MOVE.L  DOSBSE,A1              ; GET LIBRARY-BASE TO CLOSE
        JSR     -414(A6)               ; CLOSE LIBRARY

OUT:    MOVE    #0,D0                  ; NO CLI ERROR
ERROR:  RTS                            ; EXIT
 
**

DOSBSE: DC.L    0
DOSNAM: DC.B    "dos.library",0
CCPTR:  DC.B    0
        EVEN
INFO:   DC.B    $0A,$9B,"3;31;40m","Fortune Cookie v1.0"
        DC.B    $9B,"0;31;40m"," By Mark Flemans"
        DC.B    $0A,$0A,"This program was written purely for fun. Why not"
        DC.B    $0A,"insert me in your startup-sequence. This program"
        DC.B    $0A,"is public domain. Written 19.09.91 ",$0A,$0A
INFOE:  DC.B    0
        EVEN
FCMAIN: DC.B    $0A,"The thought for today is ..... ",$0A,$0A
        EVEN
FCTEXT: DC.B    "Someones nicked me pint of Murphys !!!    ",$0A,$0A
        DC.B    "It never rains, it pours.                 ",$0A,$0A
        DC.B    "Why not learn to program in C ?           ",$0A,$0A
        DC.B    "Oh No !!, not you again !                 ",$0A,$0A
        DC.B    "Have you put clean pants on today !       ",$0A,$0A
        DC.B    "There ain't no Dark Side of the Moon !    ",$0A,$0A
        DC.B    "Why does toast land the butter side down !",$0A,$0A
        DC.B    "Are you actually going to do some work ?  ",$0A,$0A
        EVEN

**
          
