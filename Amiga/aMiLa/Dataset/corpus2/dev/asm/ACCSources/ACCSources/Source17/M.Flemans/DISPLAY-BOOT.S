*
*      DISPLAY-BOOT v1.1
*      BY MARK FLEMANS
*      DATE : 31.07.91
*
*      READS THE BOOT-BLOCK 
*
*      SYNTAX : DBOOT N  - WHERE N IS THE DEVICE NUMBER ( 0 - 3 )
*                          IF NO DEVICE NUMBER THEN DEFAULTS TO 0
*
*      AMENDMENTS
*     ------------
*
*      21.08.91  NOW READS OFF ANY SPECIFIED DISK-DRIVE AND
*                GIVES ERROR MESSAGES
*

       SECTION display-boot,CODE_C
       OPT C-

START: SUBQ.W  #1,D0                   ; ANY CHARCTERS THERE ?
       BEQ     DEV0                    ; NO, OK LETS SET THE DEVICE
       CMPI.W  #1,D0
       BGT     DEVERR
SETDEV:MOVE.B  (A0),D0                 ; GET STRING
       CMPI.B  #"0",D0                 ; AM I DEVICE 0
       BLT     DEVERR                  ; NO, I'M SMALLER
       CMPI.B  #"3",D0                 ; AM I DEVICE 3
       BGT     DEVERR                  ; NO, I'M BIGGER
       CLR.L   D1
       SUBI.B  #"0",D0                 ; SUBTRACT ME TO GET DEVICE
       MOVE.B  D0,D1                   ; NUMBER
       MOVE.L  D1,DEVNUM               ; STORE DEVICE NUMBER
       BRA     MAIN                    ; LETS START THEN

DEV0:  MOVE.L  #0,DEVNUM               ; SET DRIVE NUMBER TO 0
       
MAIN:  MOVE.L  4,A6
       LEA     DOSNAM(PC),A1
       MOVEQ   #0,D0
       JSR     -552(A6)                ; OPEN DOS LIBRARY
       TST.L   D0
       BEQ     ERROR
       MOVE.L  D0,DOSBSE
 
       MOVE.L  DOSBSE,A6
       JSR     -60(A6)
       MOVE.L  D0,D1
       MOVE.L  DOSBSE,A6
       MOVE.L  #TEXT,D2
       MOVE.L  #TEXTE-TEXT,D3
       JSR     -48(A6)                 ; OUTPUT TITLE TEXT

       MOVE.L  4,A6
       SUB.L   A1,A1
       JSR     -294(A6)                ; FIND THIS TASK
       MOVE.L  D0,DISKRP+$10
       LEA     DISKRP(PC),A1
       JSR     -354(A6)

       LEA     DISKIO(PC),A1
       LEA     DEVNUM,A0
       MOVE.L  (A0),D0                 ; SET DEVICE NUMBER
       CLR.L   D1
       LEA     TRKDEV(PC),A0
       JSR     -444(A6)                ; OPEN MY DEVICE
       TST.L   D0
       BNE     DEVORR                  ; CANNOT OPEN DEVICE
 
       LEA     DISKIO(PC),A1
       MOVE.L  #DISKRP,14(A1)
       MOVE.W  #2,28(A1)
       MOVE.L  #DISKBF,40(A1)          ; POINT TO DESTINATION BUFFER
       MOVE.L  #512*2,36(A1)           ; SET READ LENGTH TO 2 SECTORS
       MOVE.L  #0,44(A1)               ; SET OFFSET SECTOR 0
       MOVE.L  4,A6                    ; GET EXEC-BASE
       JSR     -456(A6)                ; DOIO CALL

       LEA     DISKIO(PC),A1
       MOVE.B  31(A1),D0               ; GET IOERROR BYTE
       CMPI.B  #29,D0                  ; DO I HAVE A DISK IN THE DRIVE
       BEQ     DSKERR                  ; NO, OK THEN ERROR
    
TO:    LEA     OUTPL,A5
       LEA     DISKBF,A6
       MOVE.W  #0,BBCNT
       MOVE.W  #0,TOTCNT
L0:    MOVE.B  #0,LINCNT
L1:    MOVE.B  (A6)+,D1
       CMPI.B  #$20,D1                 ; COMPARE WITH SPACE
       BGT     L2                      ; IF GREATER THEN OK
       MOVE.B  #".",D1                 ; ELSE BLANK IT
L2:    MOVE.B  D1,(A5)+
       ADD.B   #1,LINCNT               ; ADD 1 TO LINE COUNT
       ADD.W   #1,BBCNT                ; ADD 1 TO BOOTBLOCK COUNT
       ADD.W   #1,TOTCNT               ; ADD 1 TO TOTAL COUNT
       CMPI.B  #63,LINCNT              ; HAVE I REACHED END OF A LINE
       BLE     L1                      ; NO, OK LOOP
       MOVE.B  #$0A,(A5)+              ; SET LINE FEED
       ADD.B   #1,LINCNT
       ADD.W   #1,BBCNT
       ADD.W   #1,TOTCNT
       CMPI.W  #1024,BBCNT             ; HAVE I REACHED END OF BOOT
       BLE     L0                      ; NO, OK LOOP

       MOVE.B  #$0A,(A5)+
       ADD.W   #1,TOTCNT
  
       MOVE.L  DOSBSE,A6
       JSR     -60(A6)
       MOVE.L  D0,D1
       MOVE.L  DOSBSE,A6
       MOVE.L  #OUTPL,D2
       MOVE.L  #OUTPE-OUTPL,D3
       JSR     -48(A6)                 ; OUTPUT BOOTBLOCK

DOUT:  MOVE.L  4,A6                    ; GET EXEC-BASE
       LEA     DISKIO(PC),A1           ; POINT TO DEVICEIO
       MOVE.W  #9,28(A1)               ; SET DRIVE MOTOR
       MOVE.L  #0,36(A1)               ; SET DRIVE OFF
       JSR     -456(A6)                ; DOIO CALL
     
       MOVE.L  4,A6
       LEA     DISKIO(PC),A1           ; POINT TO DEVICEIO
       JSR     -450(A6)                ; CLOSE TRACKDISK.DEVICE

OUTT:  MOVE.L  4,A6
       LEA     DISKRP(PC),A1           ; POINT TO REPLY-PORT
       JSR     -360(A6)                ; REMOVE REPLY-PORT

OUT:   MOVE.L  4,A6                    ; GET EXEC-BASE
       MOVE.L  DOSBSE,A1               ; SET UP DOS-BASE ADDRESS
       JSR     -414(A6)                ; CLOSE LIBRARY

ERROR: MOVEQ   #0,D0                   ; NO ERRORS
       RTS                             ; BYE
 
* 

DEVERR:MOVE.L  4,A6                    ; INCORRECT DEVICE NUMBER ERROR
       LEA     DOSNAM(PC),A1
       MOVEQ   #0,D0
       JSR     -552(A6)
       TST.L   D0
       BEQ     ERROR
       MOVE.L  D0,DOSBSE
       MOVE.L  DOSBSE,A6
       JSR     -60(A6)
       MOVE.L  D0,D1
       MOVE.L  DOSBSE,A6
       MOVE.L  #TEXT,D2
       MOVE.L  #TEXTE-TEXT,D3
       JSR     -48(A6)                 ; OUTPUT TITLE TEXT
       MOVE.L  DOSBSE,A6
       JSR     -60(A6)
       MOVE.L  D0,D1
       MOVE.L  DOSBSE,A6
       MOVE.L  #DEVT,D2
       MOVE.L  #DEVTE-DEVT,D3
       JSR     -48(A6)                 ; OUTPUT ERROR TEXT
       BRA     OUT

DEVORR:MOVE.L  DOSBSE,A6               ; DEVICE NOT ATTACHED IE 1-3
       JSR     -60(A6)
       MOVE.L  D0,D1
       MOVE.L  DOSBSE,A6
       MOVE.L  #DEVT2,D2
       MOVE.L  #DEVTE2-DEVT2,D3
       JSR     -48(A6)                 ; OUTPUT ERROR TEXT
       BRA     OUTT

DSKERR:MOVE.L  DOSBSE,A6               ; NO DISK IN DRIVE
       JSR     -60(A6)
       MOVE.L  D0,D1
       MOVE.L  DOSBSE,A6
       MOVE.L  #DSKT,D2
       MOVE.L  #DSKTE-DSKT,D3
       JSR     -48(A6)                 ; OUTPUT ERROR TEXT
       BRA     DOUT

*
      
DOSNAM:DC.B "dos.library",0
       EVEN
DOSBSE:DC.L 0
TOTCNT:DC.W 0
BBCNT: DC.W 0
LINCNT:DC.B 0
       EVEN
TEXT:  DC.B $9B,"3;31;40m","DISPLAY-BOOT v1.1 ",$9B,"0;31;40m"
       DC.B "by Mark Flemans",$0A,"Useage : DBOOT n ",$0A,$0A
TEXTE: DC.B 0
       EVEN
DEVT:  DC.B "Sorry, could not read that device number ",$0A,$0A
DEVTE: DC.B 0
       EVEN
DEVT2: DC.B "Sorry, that device is not attached ",$0A,$0A
DEVTE2:DC.B 0
       EVEN
DSKT:  DC.B "Sorry, no disk in drive ",$0A,$0A
DSKTE: DC.B 0
       EVEN
TRKDEV:DC.B "trackdisk.device",0
       EVEN
DEVNUM:DC.L 0
DISKIO:DS.L 20
DISKRP:DS.L 8
DISKBF:DS.B 512*2                ; TWO SECTORS
DISKBE:DC.B 0
OUTPL: DS.B 512*4                ; OUTPUT STRING
OUTPE: DC.B 0

 
