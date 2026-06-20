
; Lezione8p3.s	Funzionamento dei Condition Codes con l'istruzione TST

	SECTION	CondC,CODE

Inizio:
	tst.w	dato
stop:
	rts


dato:
	dc.w	$ff02

	end

;	 \  /
;	  oO
;	 \__/

L'istruzione tst in pratica confronta l'operando con zero.
Abbiamo visto che l'istruzione MOVE modifica i CC dandoci informazioni sul
dato che viene copiato. Se vogliamo ottenere quelle informazioni SENZA copiare
il dato, possiamo usare l'istruzione TST.
Si ratta di un'istruzione ad un solo operando, che legge un valore e modifica
tutti i CC in base ad esso.
I CC vengono modificati allo stesso modo dell'istruzione MOVE:

I flag V e C vengono azzerati
Il flag X non viene modificato
Il flag Z assume il valore 1 se il dato testato e` 0
Il flag N assume il valore 1 se il dato testato e` negativo.

Assemblate il programma e eseguite l'istruzione TST:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CBD594
SSP=07CBE6C7 USP=07CBD594 SR=8008 T1 -- PL=0 -N--- PC=07CC0F52
PC=07CC0F52 4E75		 RTS
>

Il flag N ha assunto il valore 1 perche` la WORD all'indirizzo di
memoria "dato" vale $ff03 che e` un numero negativo perche` il suo bit piu`
significativo vale 1.

Potete variare il valore contenuto all'indirizzo "dato" e osservare come 
si comporta il TST.
Notate che non e` possibile usare il TST con registri indirizzi, cioe`
se tentate di assemblare

	TST.W	A0

L'ASMONE vi dara` un messaggio di errore.

