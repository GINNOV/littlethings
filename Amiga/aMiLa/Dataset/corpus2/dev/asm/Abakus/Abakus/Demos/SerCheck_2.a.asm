*  Dieses Programm überwacht die serielle Schnittstelle,
*  bei einem Connect wird das in BBS angegebene Programm gestartet,
*  nach beenden des BBS Progr. überwacht es die serielle erneut.
*  Programm kann durch drücken von Ctrl C  beendet werden.

    Include "Abakus:I/StartCLI"
    Include "Abakus:I/SLI"
    Include "Abakus:I/Tools1.m"


    Input  stdin
    Output  stdout
    raw  

    OpenSer  0,#Sername,#1    ;Serielle öffnen .. noch mehrere Angaben möglich!
    mem  #4000,Buffer

_FC_LOOP_L1
    WriteSer  0,#init,#initln    ;Initialisiere Modem
    delay  #100    ;etwas Warten

    CheckReadBuff  0,x    ;Checken wieviel im Buffer ist.
    ReadSer  0,Buffer,x    ;Buffer auslesen.

    WriteS  Buffer,x    ;In stdout Window schreiben

    SetSer  0,#Buff2,#1

    Set_C  
    TaskWait  C,Ser

    ;CTRL ^C abgebrochen wird!
    ;verbraucht 0% CPU Zeit.
    btst.l  #12,d0
    bne  Adios    ;Wenn CTRL ^C dann Abbruch


    Execute  #BBS    ;Lade BBS Prog.

    CheckReadBuff  0    ;Leere Buffer
    ReadSer  0,Buffer,d0
    bra   _FC_LOOP_L1
_FC_EXLOOPL1

Adios

    CloseSer  0
    free  Buffer
    rts 
*_______________________________________________________

BBS       dc.b "Pfad/BBS",0
init      dc.b  "ATZ",13,10,"ATS0=1",13,10
initln    equ   *-init

Sername   dc.b "nullmodem.device",0

Buff2     dc.b 0

    cnop  0,4

Buffer    ds.l 1
x         dc.l 0

    Include "Abakus:I/Tools1.s"
    End
