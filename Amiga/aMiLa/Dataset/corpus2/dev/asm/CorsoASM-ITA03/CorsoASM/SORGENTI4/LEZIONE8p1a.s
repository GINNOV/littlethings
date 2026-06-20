
; Lezione8p1a.s	Funzionamento dei Condition Codes con l'istruzione MOVE

; Ecco qui il programma di questa lezione: 2 istruzioni.
; Pensate che vi stia prendendo in giro? Dopo tutto quello che avete visto
; finora pensate di sapere gia` tutto su questo semplice programma?
; Ebbene vi sbagliate. Seguite le istruzioni nel commento.

	SECTION	CondC,CODE

Inizio:
	move.w	#$0000,d0
stop:
	rts

	end

;	 oO
;	\__/
;	 U

In questa lezione e nelle successive vedremo il funzionamento dei
Condition Codes (detti CC, codici di condizione) del registro di stato.
I CC sono stati ampiamente descritti nella lezione 68000-2.TXT.
Se non vi ricordate bene cosa sono e come funzionano vi consiglio di rileggere
meglio 68000-2.TXT.
Ricordiamo brevemente che i CC sono dei bit presenti nel registro di stato che
vengono modificati dalle istruzioni assembler per dare informazioni sul
risultato dell'operazione eseguita.
Vi sono istruzioni che modificano tutti i CC, altre che ne modificano solo
alcuni e altre che non ne modificano nessuno.
Inoltre ogni istruzione che modifica i CC, lo fa in una sua propria maniera.
Nella lezione 68000-2.TXT per ogni istruzione assembler viene descritto
sinteticamente l'effetto che essa ha sui CC. In questi listati presenteremo
dei piccoli esempi pratici di come le istruzioni piu` usate modificano i CC.
Si tratta di listati piu` noiosi di quelli che avete visto sinora, ma e`
necessario che voi li studiate bene, se volte diventare dei VERI coders.
In questa lezione esamineremo l'istruzione MOVE.
Si tratta, come dovreste sapere, di un istruzione che copia il contenuto
di un registro o di una locazione di memoria e modifica di conseguenza i CC.
Per osservare bene come opera questa istruzione utilizzeremo l'ASMONE per
eseguire il programma PASSO PASSO, cioe` un'istruzione per volta.
Per farlo assemblate come al solito il programma, ma NON eseguitelo.
Date, invece all'ASMONE il comando X che serve per stampare il contenuto di
tutti i registri del 68000 e la prossima istruzione che verra` eseguita.
Queste informazioni vengono rappresentate sinteticamente dall'ASMONE nelle 4
righe riportate sotto:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CAAE9C 
SSP=07CABFD3 USP=07CAAE9C SR=0000 -- -- PL=0 ----- PC=07CAE030
PC=07CAE030 303C0000             MOVE.W  #$0000,D0
>

Spieghiamo brevemente il significato di queste 4 righe.
La prima riga rappresenta il contenuto degli 8 registri dati del 68000.
Potete infatti osservare come ci siano 8 numeri separati da uno spazio che
rappresentano il contenuto dei registri, cominciando da D0 (il piu` a sinistra)
e proseguendo ordinatamente fino a D7.
Notate come prima di eseguire il programma i registri siano tutti azzerati.

La seconda riga rappresenta il contenuto dei registri indirizzi, esattamente
nello stesso modo in cui la prima rappresenta il contenuto dei registri dati.
Notate che i registri sono tutti azzerati tranne A7 che contiene l'indirizzo
dello stack di sistema.

Nella terza riga sono rappresentati altri registri del processore.
Per il momento ci occuperemo soltanto del PC (Program Counter) e del SR (Status
Register)
Il PC contiene l'indirizzo della prossima istruzione da eseguire. Come sapete
le istruzioni che compongono un programma assembler si trovano in memoria!
Nel PC e` appunto contenuto l'indirizzo di memoria dal quale verra` prelevata
la prossima istruzione. In questo caso l'indirizzo e' 07CAE030, che fa parte
della memoria FAST a 32bit montata su a1200/a4000 e simili. E' ovvio che se
assemblate su diversi computer con memoria in diversi locazioni questo valore
cambiera', e anche sullo stesso computer volta per volta potra' essere diverso,
dato che i programmi sono rilocabili e non SCHIFOSAMENTE non rilocabili.

Di SR, il registro di stato abbiamo gia` parlato in 68000-2.TXT. Ci occuperemo
per ora solo del byte basso che contiene i CC. Notate che il contenuto di SR
viene rappresentato in forma esadecimale. Quindi leggere il contenuto dei
singoli CC potrebbe risultare scomodo. Per questo motivo i CC vengono
rappresentati separatamente. Noterete infatti che subito prima del contenuto
del PC ci sono 5 trattini. Ogni trattino rappresenta un diverso CC e indica
che esso e` azzerato. Quando uno dei CC assume il valore 1 al posto del
trattino viene stampata la lettera che denomina il trattino: se ad esempio
il Carry diventa 1, al posto del trattino corrispondente viene stampata la
lettera C.

Nella quarta riga infine possiamo leggere la prossima istruzione che verra`
eseguita. In questo caso si tratta della prima istruzione del programma.

NOTA: se volete stampare su un file l'output di ASMONE lo potete fare
 usando il comando > o equivalentemente selezionando la voce Output dal Menu
 command. L'ASMONE vi chiedera` il nome del file dove volete stampare l'output
 e il gioco e` fatto. E` esattamente in questo modo che sono stato stampato
 l'output del comando X

A questo punto possiamo eseguire la prima istruzione del programma, cioe`

          MOVE.W  #$0000,D0

Diamo all'ASMONE il comando K. L'istruzione verra` eseguita e ci viene stampato
automaticamente il contenuto dei registri:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CAAE9C 
SSP=07CABFCF USP=07CAAE9C SR=8004 T1 -- PL=0 --Z-- PC=07CAE034
PC=07CAE034 4E75		 RTS
>

La nostra istruzione ha messo il valore $0000 nel registro D0. Inoltre essa ha
anche variato i CC. Notate infatti che ora il contenuto di SR e` $8004, cioe`
il byte basso vale $04 che in binario si scrive %00000100. Cio` vuol dire che
il bit 2, corrispondente al CC "Zero", ha assunto il valore 1. Come vi avevo
anticipato, uno dei 5 trattini che comparivano in precedenza e` stato
sostituito dal Carattere "Z" che indica appunto che il Flag "Zero" ha assunto
il valore 1.
L'istruzione MOVE infatti modifica i CC nel modo seguente:
I flag V e C vengono azzerati
Il flag X non viene modificato
Il flag Z assume il valore 1 se il dato che viene copiato e` 0
Il flag N assume il valore 1 se il dato che viene copiato e` negativo.

Nel nostro caso, poiche` il dato che copiamo in D0 e` $0000, il flag Z assume
il valore 1 e il flag N assume il valore 0 (perche` $0000 NON E` un numero
negativo).

Vediamo ora qualche altro esempio di uso dell'istruzione MOVE. Modificate nel
sorgente la MOVE, scrivendo: 

	move.w	#$1000,d0

Ripetete ora la procedura per eseguire il programma PASSO PASSO.
Dopo aver eseguito la MOVE avremo la seguente situazione:

D0: 00001000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07C9EDFC 
SSP=07C9FF2F USP=07C9EDFC SR=8000 T1 -- PL=0 ----- PC=07CA2E40
PC=07CA2E40 4E75		 RTS     

Possiamo notare che ora D0 contiene il valore $00001000, ovvero proprio
quello che gli abbiamo copiato noi con la MOVE. Inoltre questa volta i CC
sono tutti azzerati. Cio` dipende dal fatto che il valore $1000 che noi
abbiamo spostato e` diverso da zero ed inoltre e` un numero positivo.

Facciamo ora un'altra modifica.
Invece del valore $1000 mettiamo $8020, ottenendo:

	move.w	#$8020,d0	; ossia "move.w #-32736,d0

Questa volta dopo l'esecuzione della MOVE otteniamo:

D0: 00008020 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07C9EDFC 
SSP=07C9FF2F USP=07C9EDFC SR=8008 T1 -- PL=0 -N--- PC=07CA2E40
PC=07CA2E40 4E75		 RTS

Come potete vedere, D0 ha assunto il valore desiderato e il flag N ha assunto
valore 1. Cio` dipende dal fatto che il numero $8020 e` un numero negativo
perche` il suo bit piu` significativo vale 1.

Trasformiamo ora la MOVE come segue:

	move.l	#$8020,d0

Abbiamo semplicemente cambiato la dimensione del dato spostato. Questo fatto
comporta che ora dobbiamo considerare il valore $8020 come un numero a 32 bit
ovvero come $00008020. Ora il bit piu` significativo e` il bit 31, non il
bit 15 come in precedenza! Quindi in questo caso abbiamo a che fare con un
numero POSITIVO. Eseguendo la MOVE si ottiene infatti:

D0: 00008020 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07C9EDC4 
SSP=07C9FEF7 USP=07C9EDC4 SR=8000 T1 -- PL=0 ----- PC=07CA33CA
PC=07CA33CA 4E75		 RTS
>

dove potete notare che il flag "N" e` azzerato. 

