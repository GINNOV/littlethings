
; Lezione8p1b.s		Funzionamento dei Condition Codes con le MULU/MULS

	SECTION	CondC,CODE

;	 oO 
;	 C _
;	\__/
;	  U 

Inizio:
	move.l	#$0003,d0	; Sarebbe piu' veloce un "moveq #3,d0"...
	move.l	#$c000,d1
	muls.w	d0,d1

	moveq	#3,d0		; Qua lo abbiamo usato... vah!
	move.l	#$c000,d1
	mulu.w	d0,d1
stop:
	rts

	end

Vediamo ora un esempio d'uso delle istruzioni di moltiplicazione.
Il 68000 ci mette a disposizione 2 diverse istruzioni di moltiplicazione:
MULS moltiplica 2 numeri considerandoli come numeri in complemento a 2,
mentre MULU considera i numeri da moltiplicare sempre positivi.
Muls/Divs lavorano con numeri in complemento a due mentre Mulu/Divu usano
numeri senza segno.

	MULU    <ea>,Dn         Sorgente=Dati    Destinazione=Dn
	MULS    <ea>,Dn         Sorgente=Dati    Destinazione=Dn

E' possibile moltiplicare solo numeri a 16 bit (in formato di word) e
il prodotto a 32bit (formato di longword) e' fornito in un registro dati.
Ovviamente i risultati che si ottengono con MULU o MULS sono molto diversi.
Facciamo un esempio moltiplicando $c000 per $0003.

D0: 00000003 0000C000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154 
SSP=07D33287 USP=07D32154 SR=8000 T1 -- PL=0 ----- PC=07D34CEC
PC=07D34CEC C3C0		 MULS.W  D0,D1
>

La MULS considera $c000 come un numero negativo.
Il risultato che ottiene e` il seguente:

D0: 00000003 FFFF4000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154
SSP=07D33287 USP=07D32154 SR=8008 T1 -- PL=0 -N--- PC=07D34CEE
PC=07D34CEE 203C00000003	 MOVE.L  #$00000003,D0
>

Il risultato e` negativo (infatti abbiamo moltiplicato un numero positivo per
un negativo) e pertanto il flag N vale 1.
Ricordo agli ignoranti che se si moltiplicano due numeri positivi tra loro il
risultato e' positivo, allo stesso modo se si moltiplicano 2 numeri negativi
tra loro il risultato e' positivo. Invece se si moltiplica un numero negativo
per uno positivo, o uno positovo per uno negativo, il risultato e' negativo.
In sintesi: 	+ * + = +       - * - = +       + * - = -       - * + = -
Vediamo ora come si comporta la MULU, che considera $c000 come un numero
positivo.

D0: 00000003 0000C000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154
SSP=07D33287 USP=07D32154 SR=8000 T1 -- PL=0 ----- PC=07D34CFA
PC=07D34CFA C2C0		 MULU.W  D0,D1
>

Il risultato che si ottiene e` il seguente:

D0: 00000003 00024000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07D32154
SSP=07D33287 USP=07D32154 SR=8000 T1 -- PL=0 ----- PC=07D34CFC
PC=07D34CFC 4E75		 RTS
>

Come potete vedere esso e` molto diverso. Tra l'altro e` positivo, e infatti
il flag N vale 0. Quindi anche per quanto riguarda le moltiplicazioni si deve
scegliere con attenzione l'istruzione da impiegare.

