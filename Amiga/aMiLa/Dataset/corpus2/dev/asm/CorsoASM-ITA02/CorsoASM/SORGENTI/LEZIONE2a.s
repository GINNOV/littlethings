
; Lezione2a.s - Questo programmino registra nel byte denominato col nome
; "contatore" il numero di volte che viene premuto il tasto destro, o meglio
; quanto e' stato premuto, infatti quando lo si tiene premuto viene continua-
; mente incrementato; per usecire si deve premere il tasto sinistro.

 Inizio:
	btst	#2,$dff016	; POTINP - tasto destro del mouse premuto?
	beq.s	aggiungi	; se si, vai ad "aggiungi"
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	inizio		; se no, torna ad Inizio e ripeti tutto
	rts			; se si invece ESCI!

aggiungi:
	move.b	contatore,$dff180 ; metti il valore di CONTATORE in COLOR0
	addq.b	#1,contatore	; Aggiungi 1 al valore di contatore
	bra.s	inizio		; torna ad inizio e ripeti

contatore:
	dc.b	0		; questo e' il byte che terra' il conto...

	END	; Con END si determina la fine del listato, le parole
		  Sotto l'END non sono considerate, e' come fossero tutte
		  precedute dal ; (Punto e virgola)

NOTA: POTINP e' il nome del registro $dff016. Il nome in maiuscolo dopo
      il punto e virgola si diferisce sempre al nome del registro $dffxxx
In questo listato si nota l'uso delle label sia per rappresentare delle
istruzioni, (bne.s inizio, bra.s inizio), sia per rappresentare un byte
di dati (addq.b #1,contatore). Non c'e' differenza tra la label Inizio:
e la label contatore:, sono entrambe label, ossia NOMI CHE IDENTIFICANO UN
DATO PUNTO DEL PROGRAMMA, SIA ESSO UN BYTE, UN MOVE O QUALSIASI ALTRA COSA,
CHE SERVE PER FAR ESEGUIRE LE ISTRUZIONI CHE HA SOTTO, QUANDO PRECEDE DELLE
ISTRUZIONI (SI FARA' UN BNE LABEL, AD ESEMPIO), O A LEGGERE/SCRIVERE IL
BYTE, LA WORD O LA LONGWORD CHE PRECEDE. Ho notato che molti trovano
difficolta' ad entrare in questa logica. Facciamo degli esempi per chiarire
il ruolo delle LABEL: immaginate di avere un orticello rettangolare
recintato, con un viottolo che lo attraversa nel mezzo. Dopo averlo
vangato decidete di seminarci delle fragole, dell'insalata, del basilico e
del prezzemolo, quindi lo dividete in 4 rettangoli di diversa grandezza e
seminate. Per sapere da dove inizieranno a crescere i diversi ortaggi si
usano spesso quelle etichette di plastica con una punta da inserire nel
terreno, le avete presenti??? Allora piantiamole: l'orto ora ha 4 etichette
che spuntano dal terreno, ognuna con scritto sopra il nome dell'ortaggio: su
una troveremo FRAGOLE:, in un'altro INSALATA:, poi BASILICO: e PREZZEMOLO:.
Da notare che abbiamo messo le etichette nel punto dove inizia un tipo
di ortaggio, e di conseguenza dove finisce quello precedente:


FRAGOLE:	INSALATA:	BASILICO:	PREZZEMOLO:
  \/		 \/		   \/		     \/
  ................oooooooooooooooooo^^^^^^^^^^^^^^^^^^_-_-_-_-_-_-_-_-_-_-_-_


Se considerate le fragole come i "......", l'insalata come i "ooooo", il
basilico come i "^^^^^^^" e il prezzemolo come i "-_-_-_-_", noterete
che quando scrivo "BNE INSALATA" intendo VAI ALL'ETICHETTA INSALATA, non
"buttati nel mezzo dell'insalata" o "vai in direzione dell'insalata", ma
proprio "VAI AL CARTELLINO INFILATO NEL TERRENO IN CUI C'E' SCRITTO INSALATA,
ED ESEGUI LE ISTRUZIONI DOPO ESSO, in questo caso si eseguirebbero i "oooo".
Nel caso che usi la label in questo modo:

	addq.b	#1,BASILICO

Non faccio altro che aggiungere 1 seme nel primo byte dopo L'ETICHETTA, che
non ha cambiato funzione! Non indica contenuti o altre stranezze!!! Indica
sempre un punto della memoria, ossia del listato, che e' l'inizio del basilico.
Proviamo a fare un MOVE.B FRAGOLE,BASILICO

FRAGOLE:	INSALATA:	BASILICO:	PREZZEMOLO:
  \/		 \/		   \/		     \/
  ................oooooooooooooooooo.^^^^^^^^^^^^^^^^^_-_-_-_-_-_-_-_-_-_-_-_

  |				    |
   \--> ----> ----> ----> ----> --->

Come noterete un ".", ossia il byte dopo fragole e' stato copiato nel byte
dopo BASILICO:, proviamo ora un MOVE.W INSALATA,FRAGOLE

FRAGOLE:	INSALATA:	BASILICO:	PREZZEMOLO:
  \/		 \/		   \/		     \/
  oo..............oooooooooooooooooo.^^^^^^^^^^^^^^^^^_-_-_-_-_-_-_-_-_-_-_-_

  ||              ||
   \<--- <--- <---/

Abbiamo spostato i primi 2 "oo" che erano dopo INSATATA: nei primi 2 byte
dopo FRAGOLE:

Se si volesse leggere o scrivere da un punto intermedio tra le LABEL, bastera'
aggiungerne un'altra dove si desidera: per mettere 4 bytes di INSALATA
nel centro del basilico dovremo fare una nuova LABEL denominata BAS2: nel
punto prestabilito, dopodiche' faremo un MOVE.L INSALATA,BAS2


Prima:

FRAGOLE:	INSALATA:	BASILICO: BAS2:	PREZZEMOLO:
  \/		 \/		   \/	   \/	     \/
  oo..............oooooooooooooooooo.^^^^^^^^^^^^^^^^^_-_-_-_-_-_-_-_-_-_-_-_


Dopo:

FRAGOLE:	INSALATA:	BASILICO: BAS2:	PREZZEMOLO:
  \/		 \/		   \/	   \/	     \/
  oo..............oooooooooooooooooo.^^^^^^^oooo^^^^^^_-_-_-_-_-_-_-_-_-_-_-_

		  ||||			    ||||
		   \ ----> ----> ----> -----> /

Abbiamo spostato i primi 4 bytes che si trovavano dopo INSALATA: nei primi 4
bytes dopo BAS2:

Il funzionamento e' lo stesso dello spostamento che avviene usando indirizzi
reali, come gia' spiegato nella LEZIONE1 (CANE GATTO>NEO CANEO), soltanto che
invece di operare con gli indirizzi, in cui ogni seme ha un indirizzo, si
mettono delle etichette solo agli indirizzi che interessano:

Usando gli indirizzi:

FRAGOLE:	INSALATA:	BASILICO:	PREZZEMOLO:
  \/		 \/		   \/		     \/
  ................oooooooooooooooooo^^^^^^^^^^^^^^^^^^_-_-_-_-_-_-_-_-_-_-_-_
  123456789012345678901234567890123456789012345678901234567890123456789012345
		     11111111112222222222333333333344444444445555555555666666

Muovendosi con gli indirizzi, si possono copiare 4 byte di insalata da ogni
posizione, ad esempio dalla n.15, e metterlo nella n.55: MOVE.L 15,55


FRAGOLE:	INSALATA:	BASILICO:	PREZZEMOLO:
  \/		 \/		   \/		     \/
  ................oooooooooooooooooo^^^^^^^^^^^^^^^^^^_-_-_-_-_-_-oooo_-_-_-_
  123456789012345678901234567890123456789012345678901234567890123456789012345
		     11111111112222222222333333333344444444445555555555666666
			   \--> ---> ---> ---> ---> ---> ---> --->/

La stessa operazione si puo' pero' fare mettendo una label alla posizione 15
e un'altra alla posizione 55, facendo poi "move.l LABEL1, LABEL2"

			LABEL1:					LABEL2:
			 \/					 \/
  ................oooooooooooooooooo^^^^^^^^^^^^^^^^^^_-_-_-_-_-_-oooo_-_-_-_
			  \---> ---> ---> ---> ---> ---> ---> --->/

Come mai si e' preferito usare le LABEL piuttosto che gli indirizzi?
SEMPLICE! Perche' usando gli indirizzi, se avessimo inserito delle cose
tra l'insalata e il basilico, la destinazione non sarebbe stata piu' 55,
ma un altro numero, per esempio 80, e avremmo dovuto cambiare tutti i
numeri spostandoli in avanti per farci entrare il nuovo pezzo inserito.
Invece, con le label, se inseriamo qualcosa tra l'una e l'altra non ci
comporta modifiche, perche' l'ASMONE calcola ogni volta l'indirizzo della
label.

Provate ad eseguire questo prog, la prima volta senza premere il tasto destro,
ma solo il tasto sinistro per uscire: il byte CONTATORE in questo caso e'
rimasto 0, come si puo' verificare con il comando M, che visualizza i valori
effettivi contenuti negli indirizzi di memoria in formato di bytes in
esadecimale (indicato con il numero della locazione, ad esempio M $50000, o
il nome di una label): facendo M contatore si otterra' uno ZERO, seguito
da altri numeri che corrisponderanno ai byte seguenti in memoria che non ci
interessano. (per avanzare in memoria premete varie volte return, per terminare
premete il tasto ESC - i byte sono ovviamente in formato ESADECIMALE)
Riassemblate con A ed eseguitelo una seconda volta, questa
volta premendo il tasto destro prima di uscire (col sinistro): rifacendo
"M contatore" si otterra' un numero diverso da zero, che corrispondera'
al numero di cicli in cui il tasto destro del mouse era premuto, infatti
il ciclo viene eseguito molto velocemente dal processore e anche premendo il
tasto destro per un istante si ottengono numeri superiori a 1.
Va notato che il contatore in questione e' lungo un byte, quindi puo'
raggiungere un valore massimo di 255, ossia $FF, ossia %11111111 in binario,
cioe' tutti gli otto bit che formano il byte ACCESI (1), dopodiche' il numero
ripartira' da zero (se si continua ad addizionare). ($ff+1 = 0, $ff+2 = 1...)
Il passo avanti di questo programmino rispetto al primo e' che la struttura
dei salti condizionati e' piu' complessa (E mi raccomando di non andare avanti
fino a che non la avete capita!), inoltre viene usato un byte come variabile.
Questo byte nominato CONTATORE non solo viene scritto, ma viene anche letto
per scriverne il valore nel $dff180, ossia il COLOR0: di qui si intuisce come
possano essere gestite molte VARIABILI, ossia bytes, words o longwords in
cui vengono scritti e letti numeri utili al programma, ad esempio il numero
delle vite del PLAYER 1, la sua energia, i suoi punti, eccetera.
L'uso delle LABEL e' utile al programmatore ma il programma una volta
assemblato, diviene una serie di bytes, che se sono letti dal 68000
vengono interpretati come istruzioni che si riferiscono ad indirizzi diretti:
per verificare cio, assemblate il programma e fate un D Inizio...
Verra' cosi' visualizzato il programma assemblato in memoria nella sua vera
forma, in cui al posto delle label compaiono gli indirizzi EFFETTIVI: come
osservate la prima colonna di numeri a sinistra sono gli indirizzi della
memoria dove stiamo leggendo, la seconda colonna di numeri sono i comandi
nella loro forma REALE in memoria, cioe' sequenze di bytes (ad esempio la
prima riga BTST #2,$dff016 in memoria diventa 0839000200dff016, in cui
$0839 significa BTST, 0002 e' il #2, 00dff016 e' l'indirizzo interessato)...
la terza colonna, quella a destra, riporta il DISASSEMBLATO, ossia fa il
contrario di quando assembla: trasforma i BYTES in ISTRUZIONI (quando si
preme A (assembla) invece vengono trasformate istruzioni dal formato MOVE,ADD,
BNE,BTST... in BYTES). Leggendo noterete subito che le label sono sostituite
dagli indirizzi reali dove si trovano routines o variabili.
Come ulteriore verifica del fatto che le istruzioni diventano numeri ben
precisi, sostituite la linea:

	btst	#2,$dff016	; POTINP - tasto destro del mouse premuto?

Con la linea equivalente:

	dc.l	$08390002,$00dff016

oppure:

	dc.w	$0839,$0002,$00df,$f016

oppure:

	dc.b	$08,$39,$00,$02,$00,$df,$f0,$16

In tutti i casi il risultato e' un 0839000200dff016 in memoria, che il 68000
interpreta come "btst #2,$dff016", cioe' "il bit 2 di $dff016 e' a zero?".

Se la variabile fosse stata una WORD anziche' un BYTE, il listato dovrebbe
essere modificato cosi':

Inizio:
	btst	#2,$dff016	; POTINP - tasto destro del mouse premuto?
	beq.s	aggiungi	; se si, vai ad "aggiungi"
	btst	#6,$bfe001	; stato sinistro del mouse premuto?
	bne.s	inizio		; se no, torna ad Inizio e ripeti tutto
	rts			; se si invece ESCI!

aggiungi:
	move.w	contatore,$dff180 ; COLOR0 - Usare .w invece che .b
	addq.W	#1,contatore	; usare ADDQ.W invece che ADDQ.B!!!
	bra.s	inizio

contatore:
	dc.W	0		; dc.w invece di dc.b (lo stesso che dc.b 0,0)

In questo caso il numero massimo contenibile da una word prima che ricominci
da capo e' $FFFF, ossia 65535, ossia %1111111111111111.

Se si volesse usare una LONGWORD per CONTATORE:, il numero massimo prima
di riazzerarsi sarebbe $FFFFFFFF , ossia qualche miliardo, ma bisogna
considerare che il bit alto (ossia il trentunesimo nel caso della longword)
e' usato per il segno del numero: provate a fare ?$0FFFFFFF e otterrete
un 268 milioni e rotte, ed in binario si nota che i quattro bit piu' alti
del numero (ossia i primi quattro dopo il %) sono a zero. il massimo numero
positivo che si puo' ottenere e' $7FFFFFFF ossia in binario:
	;10987654321098765432109876543210	; numero di bit da 0 a 31
	%01111111111111111111111111111111
Infatti il bit 31 (che sarebbe il trentaduesimo, ma e' il trentuno perche'
conta anche lo zero) e' a ZERO, mentre gli altri sono tutti ad 1.
Se si fa ?$7FFFFFFF+1 si ottiene -2 miliardi e rotte, e mano mano che si
aumenta il numero si avvicina allo zero (-1 miliardo, -100 milioni, -10 etc)
infatti se si fa un ?-1 si ottiene $FFFFFFFF, con ?-2 invece $FFFFFFFE.

Questo sistema del bit alto usato come segno puo' essere valido anche per
i byte e le word: per i byte, un move.b #-1,$50000 si puo' scrivere anche
move.b $FF,$50000 quindi il massimo numero positivo diventerebbe:
 %01111111 , ossia $7f, 127. Per le word il massimo numero positivo diventa
 %0111111111111111, ossia $7FFF, ossia 32767. Comunque e seconda di come si
fa il programma i numeri possono essere usati come numeri positivi e negativi
o come numeri assoluti.

Provate a cambiare il listato in modo che CONTATORE: sia una word, come
descritto sopra: Potete usare le funzioni dell'editor di ASMONE, il
cosiddetto TAGLIA ed INCOLLA: per "ritagliare" un pezzo di testo e
copiarlo in un altro punto, premete insieme il tasto Amiga destro+b
all'inizio della parte di testo che volete copiare; in questo caso selezionate
il sorgente modificato a WORD sotto la linea "essere modificato cosi':"
posizionandovi appunto sopra la label Inizio: e premendo Amiga+b. Ora
potete selezionare il blocco (che vi apparira' in negativo), spostandovi in
basso con il cursore. Arrivati sotto il Dc.W 0 premete Amiga+c, e il pezzo di
testo comprendente il listato andra' in memoria. Ora andate in cima al
listato a colpi di CURSORE SU+SHIFT, e premete Amiga+i ...
Magicamente apparira' una copia del testo che avevate selezionato prima.
A questo punto basta mettere un END (distanziato dall'inizio della riga con
degli spazi, o meglio con un TAB) sotto il DC.W 0 per escludere il primo
sorgente con CONTATORE: lungo un byte. Assemblate e Jumpate.

P.S: Non fate caso, per ora, a quella sfilza di numeri, a volte evidenziati,
     che compaiono dopo ogni "J", il loro significato verra' spiegato dopo.

Subito noterete la differenza di lampeggiamento dello schermo quando premete
il tasto destro; provate a fare un M CONTATORE adesso:
ora e' una WORD, quindi saranno valide le prime 2 coppie di numeri,
ossia i primi 2 bytes... se compariranno ad esempio 00 30 significa che
l'ADDQ.W #1,CONTATORE e' stato eseguito $30 volte, ossia 48 volte; un valore
di 02 5e significherebbe $25e volte, ossia 606 volte.

Se non siete esperti di editor di testi fate un po di prove di TAGLIA E INCOLLA
scopiazzando e inserendo parti di questo testo qua' e la', e considerate che
se una volta selezionato un blocco con Amiga+b invece di copiarlo in memoria
con Amiga+c, premete Amiga+x il blocco selezionato sara' anche cancellato, ma
premendo Amiga+i si potra' reinserire da un'altra parte. Vi assicuro che
programmare e' tutto un TAGLIA e INCOLLA, in quanto questo trucchetto permette
di risparmiare il tempo di riscrivere parti di programma simili, che invece
possono essere copiate e modificate velocemente.

Bisogna districarsi bene nella numerazione binaria per poter lavorare, infatti
anche molti registri hardware sono BITMAPPED, ossia ogni bit corrisponde ad
una funzione. Ecco una tabella per rendere piu' chiara la differenza:

ESADECIMALE    BINARIO   DECIMALE
        0      %00000    0
        1      %00001    1
        2      %00010    2
        3      %00011    3
        4      %00100    4
        5      %00101    5
        6      %00110    6
        7      %00111    7
        8      %01000    8
        9      %01001    9
       $A      %01010    10
       $B      %01011    11
       $C      %01100    12
       $D      %01101    13
       $E      %01110    14
       $F      %01111    15
      $10      %10000    16
      $11      %10001    17
      $12      %10010    18
      ...       ...      ...

Come vedete il binario segue una logica semplice di riempimento con gli 1 fino
a che non si giunge a 11, 111, 1111, 11111, 111111, eccetera, cioe' fino a che
non scatta la cifra seguente: dopo %011 c'e' %0100, dopo %0111 c'e' %01000,
dopo %01111 c'e' %010000, dopo %011111 c'e' %0100000 e cosi' via.
Va ricordato che i numeri in formato esadecimale sono preceduti dal segno del
dollaro $, mentre quelli binari sono preceduti dal segno di percentuale %.
I numeri in formato normale decimale invece non devono essere preceduti da
nessun segno. Se per esempio scriviamo 9 o $9, intendiamo sempre 9, ma se
invece scriviamo 10 o $10 intendiamo 10 in decimale o 16 in esadecimale!
Ricordatevi dunque che dopo il 9 un $ in piu' o in meno cambia tutto.
Non e' importante saper convertire a memoria i numeri, quello non serve perche'
basta usare il comando "?" per eseguire qualsiasi operazione o conversione,
infatti il risultato lo da in tutti i formati, decimale, esadecimale, binario
e ASCII, ossia in forma di CARATTERI. Infatti i caratteri come "abcd" non sono
altro che bytes, che secondo lo standard ASCII simile nei vari computers
corrispondono a certi caratteri, ad esempio "a"= $61, mentre "A"= $41.
Potete verificarlo facendo un ?"a", oppure un ?$61 dalla linea comandi.

NOTA: Il .s al BNE significa SHORT, ossia "corto" (equivalente a .b)
anziche' .s, oppure .w quando la label a cui si riferisce e' piu' lontana.
Provate sempre a mettere il .s al BNE, e vedrete che se la label indicata
dopo il beq.s o il bne.s e' troppo distante (piu' di 127 bytes), viene corretto
dall'assembllatore in .w. Per verificarlo fate questa modifica:

Inizio:
	btst	#2,$dff016	; POTINP - tasto destro del mouse premuto?
	beq.s	aggiungi	; se si, vai ad "aggiungi"
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	inizio		; se no, torna ad Inizio e ripeti tutto
	rts			; se si invece ESCI!

	dcb.b	200,0		; questa direttiva sara' spiegata in
				; seguito, in questo caso mette 200
				; bytes $00 in memoria, aumentando la distanza
				; fra le label Inizio: e aggiungi:

aggiungi:
	move.b	contatore,$dff180 ; metti il valore di CONTATORE in COLOR0
	addq.b	#1,contatore	; Aggiungi 1 al valore di contatore
	bra.s	inizio		; torna ad inizio e ripeti

Assemblando, vedrete che l'assemblatore vi segnala dei FORCED TO WORD SIZE,
infatti ha FORZATO A WORD i bne.s, proprio nel listato, perche' la distanza
tra Inizio: e aggiungi: era maggiore di 128. Vi consiglio di mettere sempre
il .s dopo i bra, bsr, beq, bne e simili, l'assemblatore correggera' quando
serve. Si puo' anche mettere sempre .w, ma le istruzioni .s sono piu' veloci
e occupano meno bytes. Per riprendere il concetto di LABEL discusso prima,
questo del dcb.b 200,0 inserito e' un esempio lampante dell'utilita' delle
LABEL, che ci hanno evitato di riscrivere la nuova posizione assunta da
aggiungi:, ossia 200 bytes piu' avanti.

