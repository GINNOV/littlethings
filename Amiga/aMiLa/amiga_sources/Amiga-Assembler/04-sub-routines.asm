START:
	; Hauptprogramm
	move.b #$0A,d0
	bsr ADDIERE
	bsr SUBTRAHIERE
	rts
	
ADDIERE:
	; Funktion 1 Addiere 10
	add.b #10,d0
	rts
	
SUBTRAHIERE:
	; Funktion 2 Subtrahiere 5
	sub.b #5,d0
	rts