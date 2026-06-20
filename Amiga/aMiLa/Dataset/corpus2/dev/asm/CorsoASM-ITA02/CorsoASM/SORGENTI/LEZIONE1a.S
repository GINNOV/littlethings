
; by Fabio Ciucci - Assemblare con "A", eseguire con "J"

Waitmouse:			; questa LABEL serve di riferimento per il bne.
	move.w	$dff006,$dff180	; metti il valore di $dff006 nel $dff180
				; cioe' di VHPOSR in COLOR00
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	Waitmouse	; se no ritorna a waitmouse e ripeti
	rts			; esci

	END

; NOTA: il comando MOVE significa MUOVI, o meglio COPIA il numero contenuto
; nel primo operando nel secondo, in questo caso "LEGGI CHE NUMERO C'E' IN
; $DFF006, E METTILO IN $DFF180". Il .w significa che muove una word, cioe'
; 2 bytes, cioe' 16 bit (1 byte=8 bit, 1 word=16 bit, 1 longword=32 bit)
; NOTA2: il BTST seguito dal BNE serve per fare un salto nel programma nel
; caso che si sia verificata una condizione: si puo' tradurre cosi':
; BTST = CONTROLLA SE PIERO HA MANGIATO LA MELA,E SCRIVILO SU UN PEZZO DI CARTA
; BNE = IL BNE VA A LEGGERE NEL PEZZO DI CARTA SE PIERO HA MANGIATO LA MELA,
; COSA CHE NON PUO' VERIFICARE LUI, MA CHE GLI HA VERIFICATO L'AMICO BTST...
; NEL CASO CHE NEL FOGLIETTO CI SIA SCRITTO CHE NON LA HA MANGIATA, ALLORA
; SALTA ALLA LABEL INDICATA (IN QUESTO CASO BNE.S Waitmouse, quindi se piero
; non ha mangiato la mela il processore saltera' a Waitmouse e ripetera' il
; tutto; se invece la ha mangiata, allora non salta a Waitmouse, ma continua
; eseguendo l'instruzione sotto il BNE... in queso caso ci trova un RTS e
; di conseguenza il programma finisce. Il foglio in cui BTST scrive la sentenza
; per il BNE e' lo STATUS REGISTER, o SR. Se ad esempio al posto del BNE
; ci fosse stato un BEQ, allora il loop avverrebbe solo quando il mouse
; e' premuto, e finirebbe al suo rilascio (IL CONTRARIO: INFATTI BNE significa:
; BRANCH IF NOT EQUAL, ossia SALTA SE NON e' UGUALE (falso), mentre BEQ:
; BRANCH IF EQUAL, ossia salta se e' UGUALE (vero).
; Nella prima linea si legge il valore presente nel $dff006, ossia la linea
; raggiunta dal pennello elettronico che riscrive continuamente lo schermo,
; quindi un numero sempre diverso, e si mette nel $dff180, che e' il
; registro che controlla il colore 0, di conseguenza si ottiene lo schermo
; lampeggiante o striato, in cui cioe' viene cambiato il colore continuamente.
; verificate che $dff006 e' VHPOSR facendo "=c 006", e che $dff180 e' il
; COLOR 0, facendo "=C 180". questo aiuto lo potete chiedere all'ASMONE per
; ogni registro $dffxxx.
; il formato dei colori e' il seguente: $0RGB, cioe' la word del registro
; e' divisa in RED, GREEN e BLU, in 16 toni per colore; mischiandoli come
; dalla PALETTE o TAVOLOZZA del deluxe paint si puo' selezionare uno dei
; 4096 colori possibili (16*16*16=4096), ogni valore di RED, GREEN e BLU,
; ossia ROSSO, VERDE e BLU, va da 0 a F (numero esadecimale, ossia puo'
; essere 0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f), per esempio provate a cambiare la
; prima linea con MOVE.W #$000,$dff180: si otterra' colore nero
; cambiandola con MOVE.W #$00e,$dff180 si otterra' il BLU, 
; con un MOVE.W #$cd0,$dff180 si otterra' il GIALLO, ossia rosso+verde...
; provate a cambiare il colore per verificare se avete capito
; #$444 = grigio, #$900 = rosso scuro, #$e00 = rosso acceso, #$0a0 = verde....
; se infine cambiate il $dff180 con $dff182 lampeggeranno le scritte anziche'
; lo sfondo, cioe' quello colororato col colore 1. Se mettete entrambe le
; istruzioni una dopo l'altra lampeggeranno sia lo sfondo che le scritte.
; Il comando BTST controlla se un BIT in un dato indirizzo e'=0...
; ricordati che il numero dei bit va letto da destra verso sinistra e
; partendo da 0, ad esempio in un byte tipo %01000000 , il bit ad 1 e' il 6:
; 76543210 		 5432109876543210
; 01000000    una word:  0001000000000000 <= qua e' a 1 il bit 12!!!
;
; P.S:	Il primo bit viene detto bit 0 e non bit 1, quindi non bisogna mai
;	confondersi per questa cosa, cioe' che, per esempio, il settimo bit
;	venga chiamato bit 6. Per non sbagliarvi mettete sempre la numerazione
;	; 5432109876543210 sopra il numero in binario.
;
; il bit 6 di $bfe001 infatti e' il bottone sinistro del mouse.
; Il nome del registro $bfe001 e' CIAAPRA, ma nessuno se lo ricorda.
; il bottone destro invece e' il bit 2 di $dff016. prova a sostituire la
; linea BTST #6,$bfe001 con BTST #2,$dff016, e servira' il bottone destro
; per uscire dal ciclo. Fate tutte le variazioni suggerite per verificare!
; NOTA: se volete salvare il programma in modo che sia seguibile dal CLI
; basta fare "WO" dopo aver assemblato con A (e prima di fare il J!),
; e vi apparira' la finestrella per decidere dove salvarlo
; (Mi raccomando! salvatelo su un altro dischetto! Tenete il disco del
; corso protetto da scrittura e guai se ci scrivete sopra!!!).
; Se volete invece salvare il listato, usate il comando "W". ( su un altro
; disco!!!).

; PSPS: Avrete notato il BNE.S, che a un suffisso che non e' ne' .B, ne' .W
;	ne' .L!!!! Ebbene nelle istruzioni come BNE, BEQ, BSR si possono dare
;	solo due dimensioni: .B e .W, che pero' non influenzano il risultato,
;	infatti un bne.w fara' la stessa cosa di un bne.b. In queste istruzioni
;	e' permesso di chiamare il .B come .S, che sta per SHORT (corto), e
;	si puo' usare solo se la label a cui si riferisce non e' troppo
;	"lontana", altrimenti l'ASMONE durante l'assemblaggio la cambiera' nel
;	listato automaticamente in .W. Dato che il .S (che ripeto sta per .B)
;	puo' essere usato solo con tali istruzioni, credo sia meglio usarlo,
;	ora che lo sapete non dovrebbe creare problemi.
;	PSPSPS: Se mettete come grandezza un .L, (BNE.L) l'ASMONE non da errore
;	e assembla come .W, altri assemblatori danno errore. Se dimenticate
;	di mettere il suffisso (BNE Inizio), l'ASMONE assemblera' sempre come
;	BNE.W, lo stesso vale per le altre istruzioni! scrivere MOVE $10,$20,
;	non da errore perche' viene assemblato come MOVE.W $10,$20, MA NON E'
;	DETTO CHE TUTTI GLI ASSEMBLATORI SI COMPORTINO COSI', DUNQUE METTETE
;	SEMPRE IL SUFFISSO, che e' anche esteticamente piu' bello.

