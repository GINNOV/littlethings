
; Lezione3b.s	; LA PRIMA COPPERLIST


	SECTION	PRIMOCOP,CODE	; Questo comando fa caricare dal sistema
				; operativo questa parte di codice
				; in FAST ram, se e' libera, oppure se c'e'
				; solo CHIP la carica in CHIP.

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName,a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary, routine della EXEC che apre
				; le librerie, e da in uscita in d0 l'indirizzo
				; di base di quella libreria da cui fare le
				; distanze di indirizzamento (Offset)
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist
				; di sistema (sempre a $26 della GfxBase)
	move.l	#COPPERLIST,$dff080	; COP1LC - Puntiamo la nostra COP
	move.w	d0,$dff088		; COPJMP1 - Facciamo partire la COP
mouse:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - Puntiamo la cop di sistema
	move.w	d0,$dff088		; COPJMP1 - facciamo partire la cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
				; (vanno aperte e chiuse le librerie!!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts

GfxName:
	dc.b	"graphics.library",0,0	; NOTA: per mettere in memoria
					; dei caratteri usare sempre il dc.b
					; e metterli tra "", oppure ''
					; terminando con ,0


GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library



OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	GRAPHIC,DATA_C	; Questo comando fa caricare dal sistema
				; operativo questo segmento di dati
				; in CHIP RAM, obbligatoriamente
				; Le copperlist DEVONO essere in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - Nessuna figura, solo lo sfondo
	dc.w	$180,$000	; Color 0 NERO
	dc.w	$7f07,$FFFE	; WAIT - Aspetta la linea $7f (127)
	dc.w	$180,$00F	; Color 0 BLU
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

Questo programma fa "puntare" una nostra COPPERLIST, e puo' essere usato
per far puntare una qualsiasi COPPERLIST, quindi e' utile per fare esperimenti
col COPPER. NON DOVETE SCORAGGIARVI DALL'UTILIZZO DEL SISTEMA OPERATIVO
CON L'APERTURA DELLE LIBRERIE E AFFINI, IN QUANTO IN TUTTO IL CORSO TROVERETE
SOLTANTO L'APERTURA DELLA GRAPHICS.LIBRARY PER RIMETTERE A POSTO LA VECCHIA
COPPERLIST E POCHE ALTRE COSE, BASTERA' DUNQUE IMPARARSI QUESTE POCHE COSE.
NOTA1: Come avete gia' notato questo listato contiene il comando SECTION,
che ha la funzione di decidere gli HUNK del file eseguibile che salverete
con il comando WO: ogni file eseguibile dallo shell, come ad esempio lo
stesso ASMONE, e' messo in memoria RAM dal sistema operativo copiandolo dal
dischetto o dall'hard disk, e questa azione di copia viene effettuata a
seconda degli HUNK del file in questione, che non sono altro che parti di
quel file, infatti un file e' formato da uno o piu' hunk. Ogni hunk ha la
sua caratteristica, in particolare quella di DOVE DEVE ESSERE CARICATO, se solo
in CHIP RAM o se e' possibile metterlo anche in FAST RAM; e' necessario
usare il comando SECTION se si desidera generare un file eseguibile con delle
copperlist o con dei suoni, infatti questo tipo di dati deve essere caricato
sempre in CHIP RAM, altrimenti, se non si specifica il _C, il file generato con
il WO avra' un hunk generico che puo' essere caricato in qualsiasi parte di
memoria libera, sia essa CHIP o FAST. Molte vecchie demo o addirittura delle
demo per Amiga 1200 non funzionano su Amiga con Fast Ram proprio perche' il
file ha degli hunk caricabili in qualsiasi tipo di memoria libera, e non
funziona in computer con FAST memory, in quanto il sistema operativo tende
a riempire prima la FAST RAM della preziosa CHIP RAM: evidentemente coloro
che hanno fatto quelle vecchie demo o giochi avevano l'amiga 500 di base con
512k di chip ram, senza FAST, e i programmi gli funzionavano perche' venivano
comunque caricati in CHIP, lo stesso valga per chi ha un a500+ o un a600,
infatti hanno 1MB di CHIP solamente, ma quando questi programmi sono
caricati su un computer con la FAST ram, le FIGURE, i SUONI e le COPPERLIST
sono caricate in FAST RAM ed essendo i CHIP CUSTOM in grado di accedere
solamente alla memoria CHIP fanno dei suoni casuali e il video impazzisce,
generando alle volte degli inchiodamenti del sistema.
La sintassi del comando SECTION e' la seguente: dopo la parola SECTION si deve
scrivere il nome di quella sezione, date pure un nome a piacere, dopodiche'
si scrive quale tipo di section definiamo: se CODE o DATA, ovvero se fatta
di ISTRUZIONI o di DATI, differenza che pero' non e' molto importante, infatti
si definisce sezione CODE la prima di questo listato, che ha anche delle LABEL
con dei testi (dc.b 'graphics library'); dopodiche' si decide la cosa piu'
importante: se va caricata in CHIP o se va bene anche in FAST memory: per
decidere che deve essere CARICATA per forza in CHIP basta aggiungere un _C
al DATA o al CODE, se invece non e' aggiunto niente significa che i dati o
le istruzioni nella sezione sono caricabili in qualsiasi tipo di memoria.
Alcuni esempi:

	SECTION FIGURE,DATA_C	; sezione di dati da caricare in CHIP
	SECTION	LISTANOMI,DATA	; sezione di dati caricabile in CHIP o FAST
	SECTION Program,CODE_C	; sezione di codice da caricare in CHIP
	SECTION Program2,CODE	; sezione di codice caricabile in CHIP o FAST

Mettete la prima SECTION sempre come CODE o CODE_C, iniziando ovviamente con
delle istruzioni, dopodiche' potete fare delle section DATA o DATA_C dove non
ci sono istruzioni, facciamo un esempio:

	SECTION	Myprogram,CODE	; Caricabile sia in CHIP che in FAST

	move...
	move...

	SECTION	COPPER,DATA_C	; Assemblabile solo in CHIP

	dc.w	$100,$200....	; $0100,$0200, ma si possono togliere
				; gli zeri iniziali, se per esempio
				; dobbiamo scrivere dc.l $00000001
				; sara' piu' comodo scrovere dc.l 1
				; allo stesso modo dc.b $0a si puo'
				; scrivere dc.b $a, in memoria sara'
				; assemblato $0a.

	SECTION	MUSICA,DATA_C	; Assemblabile solo in CHIP

	dc.b	Pavarotti.....

	SECTION	FIGURE,DATA_C	; solo in CHIP!

	dc.l	piramidi egizie

	END

Si puo' fare anche tutta una unica section CODE_C, ma frammentare almeno
a pezzi di 50k i dati grafici o sonori rende il programma piu' facile da
allocare nei buchetti della memoria di un unico pezzettone da 300k o piu'.
Inoltre considerate che caricare le istruzioni in CHIP RAM e' un peccato
anche perche' se sono caricate in FAST RAM, specie su un Amiga con 68020+,
sono eseguite piu' velocemente, anche di 4 volte, rispetto alla mem CHIP.
Esistono anche le section di tipo BSS o BSS_C, ne parleremo quando le useremo.
NOTA2: Avrete notato anche l'uso di (PC) nell'istruzione:

	move.l	OldCop(PC),$dff080	; COP1LC - Puntiamo la cop di sistema

Questo (PC) aggiunto dopo il nome della label non cambia la FUNZIONE del
comando, infatti se togliete il (PC) succede la stessa cosa; piuttosto serve
a cambiare la FORMA del comando, infatti provate ad assemblare e fare un
D Mouse:

	...			BTST	#$06,$00BFE001
	...			BNE.B	$xxxxxxxx
	23FA003400DFF080	MOVE.L	$xxxxxx(PC),$00DFF080
	...			MOVE.W	D0,$00DFF088

Noterete che il move.l Oldcop(PC),$dff080 viene assemblato come $23fa....

Provate ora a togliere il (PC), assemblate e rifate D MOUSE:

	23F900xxxxxx00DFF080	MOVE.L	$xxxxxx,$00DFF080

Questa volta l'istruzione viene assemblata in 10 bytes anziche' 8, e si
legge chiaramente dopo il $23f9, che significa MOVE.L, l'indirizzo di Oldcop,
mentre nel caso del move.l con PC il comando inizia con $23fa e si vede in $34
anziche' l'indirizzo di OldCop!!! La differenza e' che quando non c'e' il
PC l'istruzione si riferisce ad un INDIRIZZO DEFINITO, infatti e' assemblato,
mentre un'istruzione col (PC) anziche' scrivere l'indirizzo scrive la distanza
che c'e' da se alla label in questione, in questo caso $34 bytes.
Le struzioni col (PC) si dicono RELATIVE AL PC, ossia al Program Counter, che
e' il registro dove e' scritto l'indirizzo dell'istruzione in esecuzione:
quando il 68000 arriva ad eseguire il MOVE.L OLDCOP(PC), calcola l'indirizzo
in PC+$34 ed ottiene l'indirizzo di Oldcop, appunto situato $34 bytes piu'
avanti. Questo modo e' piu' veloce e le istruzioni come gia' visto sono piu'
corte, ma si possono solo usare per label non piu' lontane di 32768 (come per
il BSR), e non si possono usare tra una section e l'altra, proprio perche'
le section sono caricate in chissa' che punto e chissa' che distanza in memoria
e quindi sarebbero troppo lontane. Infatti provate ad aggiungere la linea
LEA COPPERLIST(PC),a0 all'inizio del listato e constaterete che tentando di
assembllare ASMONE vi comunica un RELATIVE MODE ERROR, mentre togliendo il (PC)
l'istruzione viene assemblata. Vi consiglio di mettere sempre il (PC) alle
label quando e' possibile:

	LEA	LABEL(PC),a0
	MOVE.L	LABEL(PC),d0
	MOVE.L	LABEL1(PC),LABEL2	; solo la prima label puo' essere
					; seguita dal PC, la seconda MAI.
	MOVE.L	#LABEL1,LABEL2		; in questo caso infatti non
					; si puo' mettere il (PC) ne' al
					; primo operando ne' al secondo.

NODIFICHE: Ora potete farvi qualsiasi copperlist! cominciate cambiando i 2
colori sapendo che il formato e' questo: $0RGB, in cui cioe' contano solo 3
numeri, $RGB, con R=RED,ossia ROSSO, G=GREEN,ossia VERDE, B=BLU
Ognuno di questi 3 numeri possono andare da 0 a 15, in notazione esadecimale,
cioe' da 0 ad F (0123456789ABCDEF), e a seconda di come si mischiano questi
3 colori di base si possono formare tutti i 4096 colori dell'Amiga (16*16*16).
Per ottenere il nero serve un $000, per un bianco un $FFF, un $999 e' grigio.
Attenzione! Non si mischiano come i colori a tempera o ad olio! per esempio
per fare il giallo occorrono ROSSO+VERDE, $dd0 ad esempio, per fare un viola
si devono mischiare ROSSO+BLU, ad esempio $d0e.
Questo sistema di mix dei colori e' lo stesso che trovate nelle PREFERENCES
del WorkBench o nella palette del DPAINT, con i 3 regolatori RGB.
Una volta fatte delle prove cambiando la prima copperlist, potete creare
delle sfumature, aggiungendo dei WAIT e dei COLOR 0 ($180,xxx), simili ai
tramonti che avete visto negli sfondi di SHADOW OF THE BEAST o di altri
giochi, o alle sfumature a barre di tante demo: ora sapete come funzionano!
Sostituite con Amiga+B+C+I questa copperlist a quella nel listato, osservate
cosa visualizza e perche', e modificatela per sincerarvi che avete chiaro
tutto, oppure per fare le sfumature di sfondo per il vostro primo gioco!!!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - solo sfondo
	dc.w	$180,$000	; COLOR0 - Inizio la cop col colore NERO
	dc.w	$4907,$FFFE	; WAIT - Aspetto la linea $49 (73)
	dc.w	$180,$001	; COLOR0 - blu scurissimo
	dc.w	$4a07,$FFFE	; WAIT - linea 74 ($4a)
	dc.w	$180,$002	; COLOR0 - blu un po' piu' intenso
	dc.w	$4b07,$FFFE	; WAIT - linea 75 ($4b)
	dc.w	$180,$003	; COLOR0 - blu piu' chiaro
	dc.w	$4c07,$FFFE	; WAIT - prossima linea
	dc.w	$180,$004	; COLOR0 - blu piu' chiaro
	dc.w	$4d07,$FFFE	; WAIT - prossima linea
	dc.w	$180,$005	; COLOR0 - blu piu' chiaro
	dc.w	$4e07,$FFFE	; WAIT - prossima linea
	dc.w	$180,$006	; COLOR0 - blu a 6
	dc.w	$5007,$FFFE	; WAIT - salto 2 linee: da $4e a $50, ossia da 78 a 80
	dc.w	$180,$007	; COLOR0 - blu a 7
	dc.w	$5207,$FFFE	; WAIT - sato 2 linee
	dc.w	$180,$008	; COLOR0 - blu a 8
	dc.w	$5507,$FFFE	; WAIT - salto 3 linee
	dc.w	$180,$009	; COLOR0 - blu a 9
	dc.w	$5807,$FFFE	; WAIT - salto 3 linee
	dc.w	$180,$00a	; COLOR0 - blu a 10
	dc.w	$5b07,$FFFE	; WAIT - salto 3 linee
	dc.w	$180,$00b	; COLOR0 - blu a 11
	dc.w	$5e07,$FFFE	; WAIT - salto 3 linee
	dc.w	$180,$00c	; COLOR0 - blu a 12
	dc.w	$6207,$FFFE	; WAIT - salto 4 linee
	dc.w	$180,$00d	; COLOR0 - blu a 13
	dc.w	$6707,$FFFE	; WAIT - salto 5 linee
	dc.w	$180,$00e	; COLOR0 - blu a 14
	dc.w	$6d07,$FFFE	; WAIT - salto 6 linee
	dc.w	$180,$00f	; COLOR0 - blu a 15
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79
	dc.w	$180,$300	; COLOR0 - inizio la barra rossa: rosso a 3
	dc.w	$7a07,$FFFE	; WAIT - linea seguente
	dc.w	$180,$600	; COLOR0 - rosso a 6
	dc.w	$7b07,$FFFE	; WAIT - 
	dc.w	$180,$900	; COLOR0 - rosso a 9
	dc.w	$7c07,$FFFE	; WAIT - 
	dc.w	$180,$c00	; COLOR0 - rosso a 12
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; rosso a 15 (al massimo)
	dc.w	$7e07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$7f07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$8007,$FFFE
	dc.w	$180,$600	; rosso a 6
	dc.w	$8107,$FFFE
	dc.w	$180,$300	; rosso a 3
	dc.w	$8207,$FFFE
	dc.w	$180,$000	; colore NERO
	dc.w	$fd07,$FFFE	; aspetto la linea $FD
	dc.w	$180,$00a	; blu intensita' 10
	dc.w	$fe07,$FFFE	; linea seguente
	dc.w	$180,$00f	; blu intensita' massima (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

Riassumendo, se ad esempio alla linea $50 impostate il color0 come verde, le
linee $50 e seguenti saranno verdi, fino a che non viene cambiato nuovamente
il colore dopo un wait, ad esempio un wait $6007.
Un consiglio: per fare questa copperlist OVVIAMENTE non ho scritto tutte le
volte dc.w $180,$... dc.w $xx07,$FFFE!!!! Basta prendersi le due istruzioni:

	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0

Selezionarle con Amiga+B, e Amiga+C, poi farne una lunga fila premendo varie
volte Amiga+i:

	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0
	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0
	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0
	.....

A questo punto basta cambiare le XX del wait e il valore di $180 ogni volta,
e cancellare le istruzioni di troppo con Amiga+B e Amiga+X.
NOTA: Questo si puo' fare anche tra diversi buffer di testo dell'ASMONE,
se per esempio nel buffer F2 ho un listato con una copperlist che voglio
modificare, basta che la selezioni normalmente con Amiga+B e Amiga+C, poi
torno al mio listato, per esempio in F5, e inserisco il pezzo preso
dall'altro listato con Amiga+i.
