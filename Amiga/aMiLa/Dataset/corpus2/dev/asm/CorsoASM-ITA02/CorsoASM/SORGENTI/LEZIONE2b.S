
; Lezione2b.s

Inizio:
	MOVE.L	CANE,GATTO
	rts

CANE:
	dc.l	$123456

GATTO:
	dc.l	0

	END

Con questo esempio si puo' verificare che una volta assemblato il sorgente
al posto delle label viene assemblato l'indirizzo effettivo di CANE e GATTO:
Assemblate con A, dopodiche' fate "D Inizio" e noterete la sostituzione con
gli indirizzi. Dopo l'rts noterete un paio ORI.B e altre istruzioni: in
realta' queste sono un tentativo di interpretazione delle 2 longword CANE e
GATTO, infatti dopo il $4e75 dell'rts, noterete il $00123456, ossia la prima
longword denominata da noi CANE, e $00000000, ossia GATTO.
Ora eseguitelo con J, dopodiche' fate un M GATTO, e vi apparira' 00 12 34 56
infatti la longword contenuta in CANE e' stata copiata in GATTO:
Ora modificate la prima linea in MOVE.L #CANE,GATTO, assemblate e fate
"D inizio" ... constaterete che anche questa volta sono state sostituite
le label col loro indirizzo reale, infatti l'unica differenza con la prima
prova e' l'aggiunta del cancelletto (#). Ma questo cambia tutto come dal giorno
alla notte!!!!!!! Infatti questa volta se eseguite col J e fate M GATTO
verificherete che c'e' l'indirizzo di CANE! ossia, se l'istruzione fosse stata
assemblata come MOVE.L #$34200,$34204 , dopo l'esecuzione sarebbe stato
inserito in $34204 (cioe' GATTO) il numero FISSO dopo il cancelletto (#),
ossia l'indirizzo di CANE, ossia $34200.
Riassunto finale:

	MOVE.b	$10,$200	; copia il valore .b contenuto nell'indirizzo
				; $10 nell'indirizzo $200

	MOVE.b	#$10,$200	; mette il numero $10 nella locazione $200
	MOVE.B	#16,$200	; come sopra, infatti $10 = 16!!!
	MOVE.B	#%10000,$200	; come sopra, infatti %10000 = 16!!!

NOTA: ASMONE alloca, ossia posiziona il programma ogni volta in un indirizzo
diverso, lo stesso fa il sistema operativo quando caricate un programma, a
seconda di dove avete memoria libera. Questo sistema e' uno dei punti di
forza del sistema multitasking AMIGA. Quando salvate il file eseguibile con WO
salvate il file nel formato AMIGADOS, che poi il sistema operativo mettera'
in memoria dove meglio credera'. Per questo scrivo "se fosse a $34200....":
perche' puo' essere assemblato a qualsiasi indirizzo.
Provate a caricare programmi in multitasking prima dell'asmone e noterete meno
memoria allocabile alla selezione iniziale (ALLOCATE Chip, fast...) e che
facendo D Inizio la locazione e' piu' alta, infatti la memoria sottostante
e' gia occupata. Programmare ad indirizzi FISSI, ossia specificando sempre
l'indirizzo anziche' la label non va fatto per giochi o demo in cui si
puo' uscire ritornando al workbench, perche' se ad esempio si definisce
lo schermo del gioco a $70000 e a quella locazione e' gia presente un
programma caricato prima, all'uscita otterremo un bel GURU MEDITATION, detto
COMA... se non volete far andare l'Amiga in coma continuamente dunque
programmate come questo corso insegna. Indirizzi fissi si possono, o alle
volte si DEVONO usare se si fanno giochi o demo in AUTOBOOT, cioe' che
partono non dal WB ma automaticamente e la cui directory non puo' essere
vista (molti giochi sono cosi'). Prima di fare un gioco o una demo in
autoboot credo sia meglio imparare almeno a visualizzare qualcosa sullo
schermo pero', quindi ne parlero' piu' avanti.

