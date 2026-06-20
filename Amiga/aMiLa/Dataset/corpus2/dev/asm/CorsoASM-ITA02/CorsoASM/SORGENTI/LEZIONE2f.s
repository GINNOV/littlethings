
; Lezione2f.s

Inizio:
	lea	START,a0	; metti in a0 l'indirizzo da dove iniziare
				; ovvero in a0 va l'indirizzo di START, ossia
				; DOVE si trova START, non cosa contiene!
	lea	THEEND,a1	; metti in a1 l'indirizzo dove finire
				; Ossia si mette l'indirizzo della fine dei
				; 40 bytes, infatti sta SOTTO i 40 bytes.
				; Ora, TUTTO QUELLO CHE SI TROVA TRA la label
				; START: e la LABEL THEEND: verra' pulito
				; da LOOP CLELOOP:, siano essi 40 bytes
				; o di piu', anche se ci mettete delle
				; istruzioni.

CLELOOP:
	clr.l	(a0)+	; Azzera la long in (a0), poi aggiungi 4 ad a0 (long!)
			; ATTENZIONE! Questo e' un indirizzamento indiretto,
			; in cui non si cancella il registro a0, ma il
			; contenuto dell'indirizzo, ossia 4 $FE alla volta,
			; ($fe e' un numero a caso che ho messo tanto per
			; esempio per distinguerlo dagli zeri! per dimostrare
			; che pulisco parto da una zona riempita con degli $FE;
			; essendoci un + dopo la parantesi, ogni volta che
			; viene eseguita il valore di a0 aumenta di 4, ossia
			; si mette al prossimo indirizzo da pulire)
			; (Il primo passaggio vengono azzerati i primi 4
			; $FE sotto start, il secondo passaggio i 4 seguenti
			; e cosi' via). da notare che aumenta soltanto a0,
			; mentre a1 rimane fermo all'indirizzo THEEND.
	cmp.l	a0,a1	; a0 e' uguale ad a1? Cioe' siamo all'indirizzo THEEND?
			; (Infatti a0 aumenta di 4 ogni ciclo, e fermiamo il
			; ciclo quando a0 raggiunge l'indirizzo THEEND)
	bne.s	CLELOOP	; se no, torna ad eseguire CLELOOP...
	rts		; ESCI dal prog e torna ad ASMONE

START:
	dcb.b	40,$fe	; Il comando DCB serve per mettere in memoria un
			; numero definito di byte, word o long uguali tra
			; di loro: similmente al comando DC.B, in cui in
			; questo caso avremmo dovuto fare dc.b $fe,$fe,$fe...
			; mettendo 40 $fe. Invece col comando dcb possiamo
			; fare piu' semplicemente dcb.b 40,$fe, ossia
			; METTI QUA IN MEMORIA 40 bytes $fe.
THEEND:		; questa label segna la fine dei 40 bytes...

	dcb.b	10,0	; mettiamo 10 bytes azzerati qua tanto per sfizio

	end

Attenzione! con LEA START,a0, in a0 c'e' l'indirizzo del primo dei 40 bytes
$fe, e non contiene i 40 bytes!!! La LABEL e' una convenzione usata nella
programmazione per orientarsi nel listato, infatti servono per dare un nome
alle varie parti del programma, siano esse istruzioni o altro, poi riferendoci
a quella LABEL ci riferiremo AL PUNTO ESATTO IN CUI E' MESSA LA LABEL, cioe'
l'indirizzo dove sta la label; per evitare confusioni, immaginatevi come mai
sono state inventate le LABEL: se non ci fossero state, avremmo dovuto
numerare ogni byte, ossia ragionare per indirizzi, ad esempio unvece di
fare un BNE.S CLELOOP avremmo dovuto scrivere direttamente BNE.S $20398, ad
esempio, cioe' scrivere l'indirizzo di partenza del loop, ossia dove si trovava
il clr.l (a0)+, allo stesso modo, invece di scrivere LEA START,a0 avremmo
dovuto scrivere lea $123456,a0, cioe' l'indirizzo da dove partire per pulire.
Immaginatevi poi se avessimo inserito un istruzione in piu' nel ciclo! in
questo caso START si sarebbe spostato in avanti, e avremmo dovuto riscrivere
il numero esatto nel LEA $123456,a0 ossia nel LEA START,a0. Invece dando un
nome a ogni PUNTO DEL PROGRAMMA, come si da il nome ad un fiume, si indica
con quel nome l'indirizzo di partenza di quella cosa (E NON IL SUO CONTENUTO!
SE FACCIO LEA START,A0, in A0 non va il contenuto di start! ma dove e'!).
Durante l'assemblaggio l'assemblatore si occupa di sistemare tutte le
label e sostituirle con gli indirizzi che rappresentano.
questo programmino fa una pulizia a partire dall'indirizzo messo in a0, fino
all'indirizzo che mettiamo in a1: per verificare cio', assemblate con A e
fate M START (prima di fare j) per verificare che sono stati messi in quel
punto dei $fe consecutivi; come ulteriore verifica fate D Inizio, e noterete
che in a0 viene messo lo stesso numero che compare accanto al primo LINE_F,
ossia l'indirizzo del primo $FE che viene interpretato come LINE_F da
ASMONE, mentre in a1 viene messo l'indirizzo di THEEND, ossia come potete
vedere la fine dei $FEFE e l'inizio degli 00000000. Ora eseguite con il J:
se fate D INIZIO potete verificare che i bytes sono stati azzerati (e ora
sono interpretati come ORI.B #$0,d0), allo stesso modo con M START potete
verificarlo, inoltre potete verificare che A0 ed A1 hanno lo stesso valore.
ORA VI INSEGNERO' UNA UTILITA' DELL'ASMONE MOLTO CARINA PER VERIFICARE IL
FUNZIONAMENTO DEI VOSTRI PROGRAMMI:
invece di fare A, provate a fare AD!!!!!
In questo modo dopo aver assemblato enterete nel DEBUGGER!!!!
CALMA E SANGUE FREDDO: vi apparira' il sorgente cosi' come lo avete scritto,
e al lato destro avrete sotto controllo tutti i registri che appaiono in
una colonna uno sotto l'altro: d0,d1,d2..a0,a1,a2.. eccetera.
Noterete che la prima linea del listato, in questo caso lea START,a0, e'
scritta in negativo: questo evidenzia che siamo a quella linea. Ora potete
controllare l'esecuzione del programma istruzione dopo istruzione verificando
cosa avviene nei registri! Nell'ultima linea in basso si vedono le istruzioni
disassemblate come col comando D una alla volta, con l'indirizzo all'estrema
sinistra, seguito dall'istruzione in formato BYTES, seguito dall'istruzione
in formato COMANDO (es. CLR.L (a0)+, che in bytes verificherete che e' $4298)
Per eseguire una istruzione alla volta e andare alla seguente basta premere
il tasto che sposta il cursore in avanti, quello con la freccia rivolta
verso destra: noterete come dopo aver eseguito la prima istruzione,
in a0 sara' messo l'indirizzo di START, mentre dopo la seconda sara'
caricato l'indirizzo di THEEND; scendendo nel loop noterete come a0
ogni volta sara' aumentato di 4 e come si ritornera' a CLELOOP
dopo il BNE fino a che a0 non avra' raggiunto il valore di a1.
Una volta raggiunto l'RTS della fine, o se volete anche prima, potete
uscire dal debugger con il tasto ESC.
Se contate le volte che viene eseguito il CLR.L (a0)+ verificherete che
viene eseguito 10 volte, infatti per pulire 40 bytes una long alla volta,
ossia 4 bytes allla volta, occorranno 10 passaggi (10*4=40).
Provate a modificare il CLR.L (a0)+ con CLR.W (a0)+ e noterete che sono
necessari 20 passaggi (infatti 20*2=40) e che ogni volta a0 e' aumentato
di 2, mentre sostituendolo con CLR.B (a0)+ serviranno 40 passaggi e il
registro a0 sara' incrementato di 1 ogni volta.
Per verifica caricate nuovamente i listati visti fino ad ora e seguiteli
passo passo con il comando AD.
NOTA: il debugger non puo' essere impiegato per tutti i programmi, perche'
quelli che disabilitano il sistema operativo disabilitano anche il debugger!

Per sincerarvi che viene pulito tutto quello che si trova tra la label START:
e la label THEEND:, sia che siano 40 bytes che 200 o altri, infatti provate
a fare questa modifica:

START:
	dcb.b	80,$fe	; METTI QUA IN MEMORIA 80 bytes $fe.

THEEND:		; questa label segna la fine degli 80 bytes...

Se fate gli stessi passaggi con AD noterete che vengono fatti il doppio dei
cicli, perche' la distanza tra START e  THEEND e' raddoppiata.
Infatti immaginatevi che il programma sia una strada, in cui START corrisponde
al numero civico 10... nel primo caso ci sono 40 bytes di distanza, quindi
THEEND sarebbe l'equivalente del numero civico 50 (10+40), e se l'abitante
in START deve andare a trovare l'amico che sta a THEEND deve fare 40 passi
lunghi 1 byte. Se invece START rappresenta sempre il numero 10, ma l'amico
THEEND e' andato a stare a 80 bytes di distanza, anziche' 40, si trovera'
all'indirizzo 90, e l'amico START per raggiungerlo dovra' fare questa volta
80 passi da un byte.

