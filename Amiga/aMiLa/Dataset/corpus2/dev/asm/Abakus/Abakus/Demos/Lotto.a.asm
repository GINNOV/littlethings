
    Include "Abakus:I/StartCLI"
    Include "Abakus:I/SLI"
    Include "Abakus:I/Tools1.m"

    Input  stdin
    Output  stdout

    Randomize_Timer      ;Startwert für RND setzen

*_________ sechs Lottozahlen zwischen 1 und 49 ermitteln ________________

    move.b  #1,zz
    move.b  #6,d7
    bra _FCFORROUT_i
_FCFORLOOP_i
    add.b  #1,zz
    cmp.b  zz,d7
    blt _FCEXITFOR_i
_FCFORROUT_i    ; 6 mal durchlaufen

    RND  #1,#49,Zahl
    Lea  Zahlen,a4
    ; Abakus intern !!
    ; nimmt als Vergleichsregister nun d6 statt d7

*____ nachsehen ob Zahl schonmal vorkam __________

    move.l  Zahl,d6
    cmp.l  (a4)+,d6
    beq Abermals
    cmp.l  (a4)+,d6
    beq Abermals
    cmp.l  (a4)+,d6
    beq Abermals
    cmp.l  (a4)+,d6
    beq Abermals
    cmp.l  (a4),d6
    beq Abermals    ; wenn ja Gehe zu Label Abermals


    moveq.l #0,d0
    move.b  zz,d0
    sub.b  #1,d0
    add.b  d0,d0
    add.b  d0,d0


    lea  Zahlen,a4
    move.l  Zahl,0(a4,d0)
Lotto
    bra _FCFORLOOP_i
_FCEXITFOR_i

*____ Dezimalzahlen in String umwandeln und in Stdout Window ausgeben ____

    lea  Zahlen,A3
    move.l  #6,d6
    sub.l #1,d6
_FCAGAIN_a

    move.l  #0,String
    move.l  #0,String2
    Str.l  (a3)+,#String
    WriteS  #String
    WriteS  #LF,#1
    dbra d6,_FCAGAIN_a
_FC_EXAGAIN_a

    rts     ; Programm Ende


Abermals
    sub.b  #1,zz    ; Schleifenzähler um eins runter
    bra Lotto


*__________ Daten ______________________________

zz        dc.b 0
LF        dc.b 10

    even  
Zahl      ds.l 1
Zahlen    ds.l 6
String    ds.l 1
String2   ds.l 1
    Include "Abakus:I/Tools1.s"
    End
