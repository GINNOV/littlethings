
; Lezione3g.s	SCORRIMENTO A DESTRA E SINISTRA TRAMITE IL WAIT del COPPER


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary, routine della EXEC che apre
				; le librerie, e da in uscita l'indirizzo
				; di base di quella libreria da cui fare le
				; distanze di indirizzamento (Offset)
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist
				; di sistema
	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.w	CopperDestSin	; Routine di scorrimento destra/sinistra

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
				; (vanno aperte e chiuse le librerie!!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts


; Questa routine anziche' agire sul primo byte a sinistra del wait, ossia
; quello che determina la posizione Y, facendo abbassare o alzare i wait con
; i colori seguenti, agisce sul secondo byte, quello delle X, generando uno
; spostamento a destra e a sinistra, regolato da 2 flags simili al SuGiu che
; abbiamo gia' visto, in questo caso si chiamano DestraFlag e SinistraFlag,
; dove sta il numero di volte che la routine VAIDESTRA o VAISINISTRA sono state
; eseguite, per limitare lo spostamento (ossia per decidere quanto andare 
; avanti prima di ritornare indietro): infatti ogni volta che la routine
; VAIDESTRA viene eseguita, la "barra grigia" avanza a destra, dunque dobbiamo
; farla fermare quando raggiunge il bordo opposto dello schermo, in questo caso
; quando e' stata eseguita 85 volte, dopodiche' la facciamo tornare indietro
; eseguendo altre 85 volte la routine VAISINISTRA, che la riporta alla
; posizione iniziale, e il ciclo riparte per continuare fino a che non premiamo
; il tasto del mouse.
; DA NOTARE CHE QUESTA ROUTINE O VA A VAIDESTRA O A VAISINISTRA, NON VENGONO
; ESEGUITE TUTTE E DUE: SE VIENE ESEGUITA VAIDESTRA POI SI TORNA DA QUELLA
; ROUTINE AL LOOP MOUSE:, LO STESSO PER VAISINISTRA. SE IL CICLO VAIDESTRA E
; VAISINISTRA E' FINITO (DOPO 2*85 FRAMES) SI TORNA AL CICLO "MOUSE" DALL'RTS
; DELLA ROUTINE CopperDESTSIN direttamente, dopo aver azzerato i 2 flag.


CopperDESTSIN:
	CMPI.W	#85,DestraFlag		; VAIDESTRA eseguita 85 volte?
	BNE.S	VAIDESTRA		; se non ancora, rieseguila
					; se e' stata eseguita gia' 85
					; volte invece continua di seguito

	CMPI.W	#85,SinistraFlag	; VAISINISTRA eseguita 85 volte?
	BNE.S	VAISINISTRA		; se non ancora, rieseguila

	CLR.W	DestraFlag	; la routine VAISINISTRA e' stata eseguita
	CLR.W	SinistraFlag	; 85 volte, dunque a questo punto la barra
				; grigia e' tornata indietro e il ciclo
				; destra-sinistra e' finito, dunque azzeriamo
				; i due flag e usciamo: al prossimo FRAME
				; verra' rieseguita VAIDESTRA, dopo 85 frame
				; vaisinistra 85 volte per 85 frame, eccetera.
	RTS			; TORNIAMO AL LOOP mouse


VAIDESTRA:			; questa routine sposta la barra verso DESTRA
	addq.b	#2,CopBar	; aggiungiamo 2 alla coordinata X del wait
	addq.w	#1,DestraFlag	; segnamo che abbiamo eseguito un'altra volta
				; VAIDESTRA: in DestraFlag sta il numero
				; di volte che abbiamo eseguito VAIDESTRA.
	RTS			; TORNIAMO AL LOOP mouse


VAISINISTRA:			; questa routine sposta la barra verso SINISTRA
	subq.b	#2,CopBar	; sottraiamo 2 alla coordinata X del wait
	addq.w	#1,SinistraFlag ; Aggiungiamo 1 al numero di volte che e'
				; stata eseguita VAISINISTRA.
	RTS			; TORNIAMO AL LOOP mouse


DestraFlag:		; In questa word viene tenuto il conto delle volte
	dc.w	0	; che e' stata eseguita VAIDESTRA

SinistraFlag:		; In questa word viene tenuto il conto delle volte
	dc.w    0	; che e' stata eseguita VAISINISTRA


;	dati per salvare la copperlist di sistema.

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - Inizio la cop col colore NERO


	dc.w	$9007,$fffe	; aspettiamo l'inizio della linea $90
	dc.w	$180,$AAA	; COLORE grigio

; Qua abbiamo "SPEZZATO" la prima WORD del WAIT $9031 in 2 bytes per poter
; mettere una label (CopBar) ad indicare il secondo byte, ossia $31 (LA XX)

	dc.b	$90		; POSIZIONE YY del WAIT (primo byte del WAIT)
CopBar:
	dc.b	$31		; POSIZIONE XX del WAIT (Che cambiamo!!!)
	dc.w	$fffe		; wait - (sara' $9033,$FFFE - $9035,$FFFE....)

	dc.w	$180,$700	; colore ROSSO, che partira' da posizioni
				; sempre piu' verso destra, preceduto dal
				; grigio che avanzera' di conseguenza.
	dc.w	$9107,$fffe	; wait che non cambiamo (Inizio linea $91)
	dc.w	$180,$000	; che serve a cambiare il colore in NERO
				; alla linea successiva alla barretta.

;	Come notate per la linea $90 servono 2 wait, uno per aspettare l'inizio
;	della linea (07) e uno, quello che modifichiamo (31), per definire in
;	che punto della linea cambiare colore, ossia passare dal giallo che e'
;	presente dalla posizione 07, al rosso che parte dopo la posizione
;	assunta dal wait che cambiamo.
;
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

Bello Eh? Un effetto del genere viene usato spesso per fare gli equalizzatori
a barre della musica. Lo spostamento orizzontale tramite il wait pero' ha
dei limiti, infatti si possono dare solo valori dispari, e' per questo che
di solito aspettiamo la linea yy07,$fffe e non yy08,$fffe. Di conseguenza si
puo' scorrere a scatti di 2 pixel alla volta minimo: 7,9,$b,$d,$f,$11,$13....
oppure ogni 4 pixel, oppure 8, mantenendo comunque il numero dispari, o si
rischia di far esplodere l'Amiga. Nota: il massimo valore di XX e' $e1.
Come modifiche quindi posso solo consigliarvi di far aggiungere 4 o 8 anziche'
2 per cambiare velocita', in questo caso ricordatevi anche di modificare il
numero massimo di volte che eseguite la routine:


	CMPI.W	#85/2,DestraFlag	; 85 volte /2, ossia "diviso 2"
	BNE.S	VAIDESTRA
	CMPI.W	#85/2,SinistraFlag	; 85/2, ossia 42 volte
	BNE.S	VAISINISTRA		; se non ancora, rieseguila
	....

	addq.b	#4,(a0)		; aggiungiamo 4....
	....

Oppure per un addq.b #8,a0:

	CMPI.W	#85/4,DestraFlag	; 85 volte /4, ossia 21


se siete dei sadici provate a mettere un addq.b #1,(a0), creando dei wait XX
anche pari.... nel migliore dei casi vi sparira' lo schermo a "flash" quando
avviene la disparita' (infatti lo schermo si "spenge" quando un programmatore
sprovveduto mette un wait con XX pari), oppure se si waita un valore strano
alle volte si puo' generare proprio un blocco totale del computer, una specie
di "GURU MEDITATION" del Copper. Fate dunque attenzione!!!!
In particolare posso segnalarvi alcune coordinate pari particolari che
anziche' limitarsi a far sparire lo schermo mandano proprio nel pallone il
copper, costringendovi a resettare. (almeno sull'Amiga 1200 dove le ho provate)

	dc.w	$79DC,$FFFE	; $dc = 220! pari e particolarmente ACIDO!
				; fa impazzire il copper, ma non blocca
				; il 68000, infatti potete continuare a
				; lavorare "alla cieca", senza vedere nulla

	dc.w	$0100,$FFFE	; questo invece BLOCCA tutto, non si puo'
				; nemmeno uscire dal programma, bisogna
				; resettare

	dc.w	$0300,$FFFE	; Altro blocco totale...


Questi "ERRORI" possono essere utili in caso vogliate proteggere dei programmi:
nel caso il disco sia copiato male o la password non sia data giusta se
si fa puntare immediatamente una copperlist con questi wait indiavolati
si BLOCCA il computer peggio che con un guru del 68000, e ogni Action Replay
o altre cartucce sono disabilitate e inutilizzabili. Oppure si potrebbero
usare come autodistruzione, chissa' se mettendo tanti errori in fila si
puo' danneggiare il computer FISICAMENTE???

NOTA: Potete ottenere un effetto come questo modificando l'esempio Lezione3c.s
      che sposta in basso un wait semplicemente modificando la routine:


MuoviCopper:
	cmpi.b	#$fc,BARRA	; siamo arrivati alla linea $fc?
	beq.s	Finito		; se si, siamo in fondo e non continuiamo
	addq.b	#1,BARRA	; WAIT 1 cambiato, la barra scende di 1 linea
Finito:
	rts

In questo modo, facendogli cambiare la posizione XX anziche' YY (BARRA+1), e
facendolo avanzare di 2 anziche' di 1 alla volta (numeri DISPARI!), senza
dimenticarsi che il valore massimo e' $e1, da sostituire al $fc

MuoviCopper:
	cmpi.b	#$e1,BARRA+1	; siamo arrivati alla colonna $fc?
	beq.s	Finito		; se si, siamo in fondo e non continuiamo
	addq.b	#2,BARRA+1	; WAIT 1 cambiato, la barra avanza di 2
Finito:
	rts

Vedrete la prima linea spostarsi verso destra anziche' abbasarsi. Per
evidenziare l'effetto potete "ISOLARE" la linea $79 facendo diventare blu
scuro lo schermo dalla linea seguente, ossia la $7a aggiungendo queste 2
linee prima della fine della copperlist:

	dc.w	$7a07,$FFFE	; aspetto la linea $79
	dc.w	$180,$004	; inizio la zona rossa: rosso a 6

Nella lezione3g la difficolta' forse risiede piu' nella routine che fa andare
avanti e indietro la barra piuttosto che nel fatto che operiamo sulla posizione
XX anziche' su quella YY. In effetti le ultime lezioni che avete affrontato
hanno delle routines 68000 non troppo semplici, che sono pero' indispensabili
per generare gli effetti col copper, dunque per capire il copper stesso; nella
Lezione 4 invece le routines 68000 saranno anche piu' semplici di quelle
di questa lezione 3, dovendo spiegare come visualizzare immagini statiche.
Se non riuscite a comprendere a fondo il funzionamento delle routine delle
ultime lezioni quindi procedete con la Lezione4, e riprovate a comprenderle
quando vi troverete piu' avanti nel corso, momento in cui avrete certamente
piu' familiarita' con le routines. La Lezione3h.s e' un ampliamento della
Lezione3g.s.

