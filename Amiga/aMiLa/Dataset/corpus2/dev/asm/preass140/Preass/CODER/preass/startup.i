; Startup.i v1.0

    move.l d0,Laenge
    move.l a0,Adresse
	move.l $4.w,a6
	suba.l a1,a1		;a1=0 eigenen Task finden
	jsr Findtask(a6)	
	move.l d0,a4		;D0 enthält den Zeiger auf den eigenen
	tst.l $ac(a4)		;Prozess; inhalt $AC(A4) =0 dann wars WB
	bne.b FromCLI		;ansonsten das CLI
FromWB:
	lea $5c(a4),a0		;WB Message vom Port nehmen und dann weiter
	jsr waitport(a6)	        ;machen
	jsr getMSG(a6)		
	move.l d0,WBMESSAGE
fromCLI:
