XREF Tel_gfirstnam
    
    Move.l #Zeiger,-(a7)
    Move.l #Zeiger,-(a7)
    Move.l XYC,-(a7)
    Move.l SDF,-(a7)
    Jsr tel_gfirstnam
    addi.l #16,a7 
Errorhandling:
    Move.l DOSBase,a6
    Jsr output(a6)
    Move.l D0,Ausgabe
    Move.l Error,d0
    Cmp.l #1,D0
    Beq .Pre0000
    Bra .Pre0001
.Pre0000:
Move.l DOSBase,a6
Move.l Ausgabe,d1
Move.l #Allgemeiner_Fehlerxnname000,d2
Moveq.l #$13,d3
Jsr Write(a6)
.Pre0001:
    Move.l Error,d0
    Cmp.l #2,D0
    Beq .Pre0002
    Bra .Pre0003
.Pre0002:
Move.l DOSBase,a6
Move.l Ausgabe,d1
Move.l #Konnte_File_nicht_findenxnname001,d2
Moveq.l #$19,d3
Jsr Write(a6)
.Pre0003:
    Move.l Error,d0
    Cmp.l #3,D0
    Beq .Pre0004
    Bra .Pre0005
.Pre0004:
Move.l DOSBase,a6
Move.l Ausgabe,d1
Move.l #Window_Screen_Fehlerxnname002,d2
Moveq.l #$15,d3
Jsr Write(a6)
.Pre0005:
    Move.l Error,d0
    Cmp.l #4,D0
    Beq .Pre0006
    Bra .Pre0007
.Pre0006:
Move.l DOSBase,a6
Move.l Ausgabe,d1
Move.l #Library_nicht_gefundenxnname003,d2
Moveq.l #$17,d3
Jsr Write(a6)
.Pre0007:
    Move.l Error,d0
    Cmp.l #5,D0
    Beq .Pre0008
    Bra .Pre0009
.Pre0008:
Move.l DOSBase,a6
Move.l Ausgabe,d1
Move.l #Fehlerhafte_Eingabexnname004,d2
Moveq.l #$14,d3
Jsr Write(a6)
.Pre0009:
    Move.l Error,d0
    Cmp.l #6,D0
    Beq .Pre0010
    Bra .Pre0011
.Pre0010:
Move.l DOSBase,a6
Move.l Ausgabe,d1
Move.l #Speicherfehlerxnname005,d2
Moveq.l #$0F,d3
Jsr Write(a6)
.Pre0011:
    RTS
even
Ausgabe:		dc.l 0
Allgemeiner_Fehlerxnname000:
	dc.b `Allgemeiner Fehler`,$a,``,0
even
Konnte_File_nicht_findenxnname001:
	dc.b `Konnte File nicht finden`,$a,``,0
even
Window_Screen_Fehlerxnname002:
	dc.b `Window|Screen Fehler`,$a,``,0
even
Library_nicht_gefundenxnname003:
	dc.b `Library nicht gefunden`,$a,``,0
even
Fehlerhafte_Eingabexnname004:
	dc.b `Fehlerhafte Eingabe`,$a,``,0
even
Speicherfehlerxnname005:	dc.b `Speicherfehler`,$a,``,0
even

even
even

