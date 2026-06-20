
; Lezione8p8.s	Funzionamento dei Condition Codes con l'istruzione ADDX

	SECTION	CondC,CODE

Inizio:
	move.l	#$b1114000,d0
	move.l	#$22222222,d1
	move.l	#$82345678,d2
	move.l	#$abababab,d3
	add.l	d0,d2
	addx.l	d1,d3
	move.l	#$01114000,d0
	move.l	#$00000000,d1
	move.l	#$02222222,d2
	move.l	#$00000000,d3
	add.l	d0,d2
	addx.l	d1,d3
stop:
	rts

	end

Vediamo ora un esempio d'uso dell'istruzione ADDX.
Supponiamo di dover sommare 2 interi a 64 bit, uno contenuto in D0 e D1
e l'altro in D2 e D3. Per prima cosa sommiamo i 32 bit meno significativi
dei 2 numeri con una normale ADD:

D0: B1114000 22222222 82345678 ABABABAB 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8008 T1 -- PL=0 -N--- PC=07CA74C4
PC=07CA74C4 D480		 ADD.L   D0,D2
>

Notiamo che viene generato un riporto, perche` la somma e` troppo grande per
essere contenuta in 32 bit. Pertanto i flag C e X assumono il valore 1.
Per sommare i 32 bit piu` significativi, impieghiamo la ADDX che
aggiunge ai 2 registri anche il contenuto del flag X, tenendo conto cosi`
del riporto.

D0: B1114000 22222222 33459678 ABABABAB 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8013 T1 -- PL=0 X--VC PC=07CA74C6
PC=07CA74C6 D781		 ADDX.L  D1,D3
>

Abbiamo cosi` il nostro risultato a 64 bit nei registri D2 e D3

D0: B1114000 22222222 33459678 CDCDCDCE 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8008 T1 -- PL=0 -N--- PC=07CA74C8
PC=07CA7B3E 223C02222222	 MOVE.L  #$02222222,D1
>
 
La ADDX modifica i flag come la ADD, tranne che per il flag Z.
Infatti il flag Z viene azzerato se il risultato di ADDX e` diverso da zero,
ma viene lasciato inalterato se il risultato e` zero. Cio` consente al flag
Z di tener conto dello stato dell'intera operazione.
Il seguito dell'esempio ce lo mostra:
Ci troviamo infatti a sommare 2 numeri a 64 bit, ma entrambi hanno i 32
bit piu` significativi azzerati

D0: 01114000 00000000 02222222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8004 T1 -- PL=0 --Z-- PC=07CA8058
PC=07CA8058 D480		 ADD.L   D0,D2
>

La ADD delle cifre meno significative pone Z al valore 1 perche` il risultato
non e` nullo

D0: 01114000 00000000 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8000 T1 -- PL=0 ----- PC=07CA805A
PC=07CA805A D781		 ADDX.L  D1,D3
>

Il risultato della ADDX invece e` proprio zero. Se essa si comportasse come
la ADD dovrebbe azzerare il flag Z. Ma anche se la somma dei 32 bit piu`
significativi e` nulla, non lo e` il risultato dell'intera operazione.
La ADDX dunque lascia invariato il flag Z in modo tale che noi possiamo
accorgerci che il risultato dell'intera operazione e` non nullo

D0: 01114000 00000000 03336222 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA4A64
SSP=07CA5B97 USP=07CA4A64 SR=8000 T1 -- PL=0 ----- PC=07CA805C
PC=07CA805C 4E75		 RTS
>

Questa maniera di trattare il flag Z e` usato anche dalle istruzioni
SUBX e NEGX.

