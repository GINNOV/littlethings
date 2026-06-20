
; Lezione2c.s

Inizio:
	LEA	CANE,a0
	MOVE.L	#CANE,a1
	MOVE.L	CANE,a2
	move.l	a0,GATTO1
	move.l	a1,GATTO2
	move.l	a2,GATTO3
	rts

CANE:
	dc.l	$12345678

GATTO1:
	dc.l	0

GATTO2:
	dc.l	0

GATTO3:
	dc.l	0

	END

Assemblate, fate un D Inizio per controllare a che indirizzo sono allocate
le label, dopodiche' eseguite con J. Verificherete gia' che dopo il J la
lista dei registri riporta dei numeri in negativo, e precisamente:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: NUMERO   NUMERO   12345678 00000000 00000000 00000000 00000000 NUMERO (SP)
SSP= ..... USP= SR.....

Ogni volta che si e' eseguito un listato vengono visualizzati tutti i
registri: la prima fila e' quella dei D0,D1,D2,D3,D4,D5,D6,D7, la seconda
fila e' quella a0,a1,a2,a3,a4,a5,a6,a7.
Sotto ci sono altri registri di cui parleremo piu' aventi. Il numero in A7
e' lo SP attuale, non interessa in questo momento. Controllate invece i
numeri presenti in A0,A1 ed A2: il primi sono 2 numeri uguali, in questo caso
l'indirizzo di CANE:, infatti le due istruzioni:

	LEA	CANE,a0		; piu' veloce di MOVE.L #CANE,A1! fate cosi'!
	MOVE.L	#CANE,a1

Fanno la stessa cosa, cioe' copiare l'indirizzo della label in un registro.
In A3 invece si legge 12345678, ovvero il contenuto della longword CANE:
infatti l'istruzione MOVE.L CANE,a2 mette il contenuto della long CANE in a2.
Come ulteriori verifiche, controllate dopo il J con un M CANE, e constaterete
che CANE e' alla stessa locazione che appare in a0 e a1; dopodiche' potete
anche controllare con M GATTO1 e M GATTO2 che queste 2 longword contengono
l'indirizzo di gatto, infatti ci viene copiato con queste 2 istruzioni:

	move.l	a0,GATTO1
	move.l	a1,GATTO2

Infine con M GATTO3 si verifichera' che contiene il contenuto della long
GATTO, ossia $12345678.
Per fare questi 3 controlli in un colpo solo potete fate un m gatto1 e
premere il tasto return (o invio o "A CAPO!") varie volte: otterrete nei
primi 4 bytes l'indirizzo di CANE, nei 4 bytes seguenti lo stesso indirizzo,
nei 4 bytes seguenti il contenuto .L di cane, ossia $12345678. Continuando si
vedranno numeri che non c'entrano nulla, infatti state vedendo una parte
di memoria vuota od occupata da chissa' che cosa.
Se volete fare qualche modifica, potete aggiungere per esempio prima dell'RTS
queste linee:

	MOVE.L	A0,D0
	MOVE.L	A1,D1
	MOVE.L	A2,D2

Ed otterrete nella lista dei registri dopo il J un cambiamento anche dei
primi 3 registri DATI.
NOTA1: Come avete visto usare il LEA e' meglio di fare un MOVE.L #lab,a0, ma
fate attenzione! il comando lea puo' essere usato solo per mettere un
valore nei registri indirizzo! non si puo' fare ad esempio LEA LABEL,d0!!!!
per mettere l'indirizzo di una label in un registro dati o in un altra long
della memoria si deve usare il MOVE.L #LABEL,destinazione!!!!
NOTA2: Di solito nei registri a0,a1,a2... si mettono indirizzi e nei
registri d0,d1,d2,d3... si mettono dati vari, ma spesso si mettono indirizzi
nei registri dati (d0,d1...) o dati nei registri indirizzi (a0,a1,a2..), a
seconda della situazione. Insomma per darvi un idea del loro utilizzo,
vengono usati come un foglio degli appunti in cui tenete un certo numero
di numeri di telefono o dove riportate quanto avete speso per comprare il
gelato, quindi come utili E VELOCI longword a disposizione che possono
essere usate a volonta', basta ricordarsi cosa ci avete messo!!!!!

