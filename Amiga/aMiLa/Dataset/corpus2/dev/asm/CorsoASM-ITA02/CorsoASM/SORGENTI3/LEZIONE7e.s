
; Lezione7e.s	UNO SPRITE MOSSO SIA VERTICALMENTE CHE ORIZZONTALMENTE
; 		USANDO DUE TABELLE DI VALORI (ossia di coordinate verticali
;		e orizzontali) PRESTABILITI.
;		Nella nota finale viene spiegato come farsi proprie tabelle.


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo lo sprite

	MOVE.L	#MIOSPRITE,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	MuoviSpriteX	; Muovi lo sprite 0 orizzontalmente
	bsr.w	MuoviSpriteY	; Muovi lo sprite 0 verticalmente

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

; In questo esempio sono state incluse le routine e le tabelle dei due esempi
; precedenti, dunque agiamo sia sulla x che sulla y dello sprite.
; Essendo le due tabelle X ed Y entrambe formate da 200 coordinate, si
; verifica sempre la stessa "accoppiata" di coordinate:
; valore 1 della tabella X + valore 1 della tabella Y
; valore 2 della tabella X + valore 2 della tabella Y
; valore 3 della tabella X + valore 3 della tabella Y
; ....
; Dunque il risultato e' che lo sprite ondeggia in diagonale, come abbiamo gia'
; visto mettendo insieme addq.b #1,HSTART e addq.b #1,VSTART/VSTOP.


; Questa routine sposta  lo sprite agendo sul suo byte HSTART, ossia
; il byte della sua posizione X, immettendoci delle coordinate gia' stabilite
; nella tabella TABX. (scatti di 2 pixel minimo e non 1 pixel)

MuoviSpriteX:
	ADDQ.L	#1,TABXPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTX	; non ancora? allora continua
	MOVE.L	#TABX-1,TABXPOINT ; Riparti a puntare dal primo byte-1
NOBSTARTX:
	MOVE.b	(A0),HSTART	; copia il byte dalla tabella ad HSTART
	rts

TABXPOINT:
	dc.l	TABX-1		; NOTA: i valori della tabella qua sono bytes,
				; dunque lavoriamo con un ADDQ.L #1,TABXPOINT
				; e non #2 come per quando sono word o con #4
				; come quando sono longword.

; Tabella con coordinate X dello sprite precalcolate.
; Da notare che la posizione X per far entrare lo sprite nella finestra video
; deve essere compresa tra $40 e $d8, infatti nella tabella ci sono byte non
; piu' grandi di $d8 e non piu' piccoli di $40.

TABX:
	dc.b	$91,$93,$96,$98,$9A,$9C,$9F,$A1,$A3,$A5,$A7,$A9 ; 200 valori
	dc.b	$AC,$AE,$B0,$B2,$B4,$B6,$B8,$B9,$BB,$BD,$BF,$C0
	dc.b	$C2,$C4,$C5,$C7,$C8,$CA,$CB,$CC,$CD,$CF,$D0,$D1
	dc.b	$D2,$D3,$D3,$D4,$D5,$D5,$D6,$D7,$D7,$D7,$D8,$D8
	dc.b	$D8,$D8,$D8,$D8,$D8,$D8,$D7,$D7,$D7,$D6,$D5,$D5
	dc.b	$D4,$D3,$D3,$D2,$D1,$D0,$CF,$CD,$CC,$CB,$CA,$C8
	dc.b	$C7,$C5,$C4,$C2,$C0,$BF,$BD,$BB,$B9,$B8,$B6,$B4
	dc.b	$B2,$B0,$AE,$AC,$A9,$A7,$A5,$A3,$A1,$9F,$9C,$9A
	dc.b	$98,$96,$93,$91,$8F,$8D,$8A,$88,$86,$84,$81,$7F
	dc.b	$7D,$7B,$79,$77,$74,$72,$70,$6E,$6C,$6A,$68,$67
	dc.b	$65,$63,$61,$60,$5E,$5C,$5B,$59,$58,$56,$55,$54
	dc.b	$53,$51,$50,$4F,$4E,$4D,$4D,$4C,$4B,$4B,$4A,$49
	dc.b	$49,$49,$48,$48,$48,$48,$48,$48,$48,$48,$49,$49
	dc.b	$49,$4A,$4B,$4B,$4C,$4D,$4D,$4E,$4F,$50,$51,$53
	dc.b	$54,$55,$56,$58,$59,$5B,$5C,$5E,$60,$61,$63,$65
	dc.b	$67,$68,$6A,$6C,$6E,$70,$72,$74,$77,$79,$7B,$7D
	dc.b	$7F,$81,$84,$86,$88,$8A,$8D,$8F
FINETABX:


	even	; pareggia l'indirizzo seguente


; Questa routine sposta in alto e in basso lo sprite agendo sui suoi byte
; VSTART e VSTOP, ossia i byte della sua posizione Y di inizio e fine,
; immettendoci delle coordinate gia' stabilite nella tabella TABY

MuoviSpriteY:
	ADDQ.L	#1,TABYPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTY	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT ; Riparti a puntare dal primo byte (-1)
NOBSTARTY:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte dalla tabella in d0
	MOVE.b	d0,VSTART	; copia il byte in VSTART
	ADD.B	#13,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,VSTOP	; Muovi il valore giusto in VSTOP
	rts

TABYPOINT:
	dc.l	TABY-1		; NOTA: i valori della tabella qua sono bytes,
				; dunque lavoriamo con un ADDQ.L #1,TABYPOINT
				; e non #2 come per quando sono word o con #4
				; come quando sono longword.

; Tabella con coordinate Y dello sprite precalcolate.
; Da notare che la posizione Y per far entrare lo sprite nella finestra video
; deve essere compresa tra $2c e $f2, infatti nella tabella ci sono byte non
; piu' grandi di $f2 e non piu' piccoli di $2c.

TABY:
	dc.b	$8E,$91,$94,$97,$9A,$9D,$A0,$A3,$A6,$A9,$AC,$AF ; ondeggio
	dc.b	$B2,$B4,$B7,$BA,$BD,$BF,$C2,$C5,$C7,$CA,$CC,$CE ; 200 valori
	dc.b	$D1,$D3,$D5,$D7,$D9,$DB,$DD,$DF,$E0,$E2,$E3,$E5
	dc.b	$E6,$E7,$E9,$EA,$EB,$EC,$EC,$ED,$EE,$EE,$EF,$EF
	dc.b	$EF,$EF,$F0,$EF,$EF,$EF,$EF,$EE,$EE,$ED,$EC,$EC
	dc.b	$EB,$EA,$E9,$E7,$E6,$E5,$E3,$E2,$E0,$DF,$DD,$DB
	dc.b	$D9,$D7,$D5,$D3,$D1,$CE,$CC,$CA,$C7,$C5,$C2,$BF
	dc.b	$BD,$BA,$B7,$B4,$B2,$AF,$AC,$A9,$A6,$A3,$A0,$9D
	dc.b	$9A,$97,$94,$91,$8E,$8B,$88,$85,$82,$7F,$7C,$79
	dc.b	$76,$73,$70,$6D,$6A,$68,$65,$62,$5F,$5D,$5A,$57
	dc.b	$55,$52,$50,$4E,$4B,$49,$47,$45,$43,$41,$3F,$3D
	dc.b	$3C,$3A,$39,$37,$36,$35,$33,$32,$31,$30,$30,$2F
	dc.b	$2E,$2E,$2D,$2D,$2D,$2D,$2C,$2D,$2D,$2D,$2D,$2E
	dc.b	$2E,$2F,$30,$30,$31,$32,$33,$35,$36,$37,$39,$3A
	dc.b	$3C,$3D,$3F,$41,$43,$45,$47,$49,$4B,$4E,$50,$52
	dc.b	$55,$57,$5A,$5D,$5F,$62,$65,$68,$6A,$6D,$70,$73
	dc.b	$76,$79,$7C,$7F,$82,$85,$88,$8b
FINETABY:


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; bit 12 acceso!! 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco lo sprite: OVVIAMENTE deve essere in CHIP RAM! ************

MIOSPRITE:		; lunghezza 13 linee
VSTART:
	dc.b $50	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART:
	dc.b $90	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP:
	dc.b $5d	; $50+13=$5d	; posizione verticale di fine sprite
	dc.b $00
 dc.w	%0000000000000000,%0000110000110000 ; Formato binario per modifiche
 dc.w	%0000000000000000,%0000011001100000
 dc.w	%0000000000000000,%0000001001000000
 dc.w	%0000000110000000,%0011000110001100 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 dc.w	%0000011111100000,%0110011111100110 ;BINARIO 10=COLORE 1 (ROSSO)
 dc.w	%0000011111100000,%1100100110010011 ;BINARIO 01=COLORE 2 (VERDE)
 dc.w	%0000110110110000,%1111100110011111 ;BINARIO 11=COLORE 3 (GIALLO)
 dc.w	%0000011111100000,%0000011111100000
 dc.w	%0000011111100000,%0001111001111000
 dc.w	%0000001111000000,%0011101111011100
 dc.w	%0000000110000000,%0011000110001100
 dc.w	%0000000000000000,%1111000000001111
 dc.w	%0000000000000000,%1111000000001111
 dc.w	0,0	; 2 word azzerate definiscono la fine dello sprite.


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

Fino ad adesso abbiamo fatto andare lo sprite in orizzontale, in verticale, e
in diagonale, ma mai gli abbiamo fatto fare curve. Ebbene basta modificare
questo listato per fargli fare tutte le curve possibili, infatti possiamo
variare le sue coordinate X ed Y tramite due tabelle. In questo listato sono
riportate due tabelle di uguale lunghezza (200 valori) per cui ogni volta
avvengono sempre le stesse "accoppiate" di coordinate X ed Y:

 valore 1 della tabella X + valore 1 della tabella Y
 valore 2 della tabella X + valore 2 della tabella Y
 valore 3 della tabella X + valore 3 della tabella Y
 ....

Dunque il risultato e' sempre la stessa oscillazione in diagonale.
Se pero' una delle due tabelle fosse piu' corta, questa ripartirebbe prima da
capo dell'altra creando nuove oscillazioni, e ogni volta le due tabelle
farebbero delle accoppiate XX ed YY diverse, ad esempio:

 valore 23 della tabella X + valore 56 della tabella Y
 valore 24 della tabella X + valore 57 della tabella Y
 valore 25 della tabella X + valore 58 della tabella Y
 ....

Queste accoppiate si tradurrebbero in oscillazioni curvilinee dello sprite

Provate a sostituire la tabella corrente delle coordinate XX con questa:
(Amiga+b+c+i per copiare), (amiga+b+x per cancellare un pezzo)


TABX:
	dc.b	$8A,$8D,$90,$93,$95,$98,$9B,$9E,$A1,$A4,$A7,$A9 ; 150 valori
	dc.b	$AC,$AF,$B1,$B4,$B6,$B8,$BA,$BC,$BF,$C0,$C2,$C4
	dc.b	$C6,$C7,$C8,$CA,$CB,$CC,$CD,$CE,$CE,$CF,$CF,$D0
	dc.b	$D0,$D0,$D0,$D0,$CF,$CF,$CE,$CE,$CD,$CC,$CB,$CA
	dc.b	$C8,$C7,$C6,$C4,$C2,$C0,$BF,$BC,$BA,$B8,$B6,$B4
	dc.b	$B1,$AF,$AC,$A9,$A7,$A4,$A1,$9E,$9B,$98,$95,$93
	dc.b	$90,$8D,$8A,$86,$83,$80,$7D,$7B,$78,$75,$72,$6F
	dc.b	$6C,$69,$67,$64,$61,$5F,$5C,$5A,$58,$56,$54,$51
	dc.b	$50,$4E,$4C,$4A,$49,$48,$46,$45,$44,$43,$42,$42
	dc.b	$41,$41,$40,$40,$40,$40,$40,$41,$41,$42,$42,$43
	dc.b	$44,$45,$46,$48,$49,$4A,$4C,$4E,$50,$51,$54,$56
	dc.b	$58,$5A,$5C,$5F,$61,$64,$67,$69,$6C,$6F,$72,$75
	dc.b	$78,$7B,$7D,$80,$83,$86
FINETABX:


Ora potete ammirare lo sprite ondeggiare per lo schermo realisticamente e con
un movimento variabile, a causa della differenza di lunghezza delle due tabelle

Con due tabelle, una per la posizione XX ed una per la posizione YY, vanno
definiti i vari movimenti curvilinei dei giochi e delle dimostrazioni grafiche,
ad esempio il lancio di una bomba:

		.  .
	     .	     .
	    .	      .
	 o /	      .
	/||	     
	 /\	   BOOM!!


La curva percorsa dalla bomba lanciata dal protagonista del nostro gioco e'
stata simulata tramite il precalcolamento di essa in termini di XX ed YY.
Dato che il personaggio al momento del lancio poteva trovarsi in posizioni
diverse dello schermo, tutto spostato a destra o a sinistra, bastera'
aggiungere la posizione del protagonista lanciatore alle coordinate della
curva e la bomba partira' e cadra' nel posto giusto.
Oppure i movimenti di una squadriglia di astronavi nemiche:


			     @  @  @  @  @  @  @  @ <--
			  @	  @
			@	    @
		
			@  	    @
			  @       @ 
	   <--  @  @  @  @  @  @


Gli utilizzi delle coordinate nelle tabelle sono infiniti.

Vi starete chiedendo: ma le tabelle si fanno a mano calcolandosi ad occhio
l'onda?? Ebbene NO, esiste un comando dell'ASMONE, il "CS" (oppure "IS"), che
puo' bastare per fare le tabelle presenti in questo listato (infatti le ho
fatte proprio con questo comando!). Oppure se serve qualche tabella "speciale"
ci si puo' fare un programmino che la faccia.

Anticipiamo l'argomento "come farsi una tabella":
Il comando CS significa "CREATE SINUS", che per chi conosce la trigonometria
significa "TUTTO LI'?", mentre per chi non la conosce significa "COSA E'?".
Dato che questo deve essere solo un accenno, spieghero' soltanto come dare i
parametri al comando "CS" o "IS".

Il comando "CS" crea i valori in memoria dall'indirizzo o dalla label che viene
specificata, ad esempio se e' gia' presente una tab di 200 bytes alla label
TABX, se si crea all'indirizzo "TABX", dopo aver assemblato, un'altra tabella
di 200 bytes, questa sara' "sovrapposta" a quella precedente in memoria, ed
eseguendo il listato si vedra' l'effetto dell'ultima tabella creata.
Ma assemblando nuovamente viene riassemblata la tabella precedente, in quanto
non abbiamo cambiato il testo (dc.b $xx,$xx..).
Per salvare la tabella allora si puo' creare sopra un'altra di uguale grandezza
oppure si puo' fare un "buffer", ossia una zona di memoria dedicata alla
creazione e al salvataggio su disco della tabella.
Facciamo un esempio pratico: vogliamo fare una tabella particolare lunga 512
bytes, e la vogliamo salvare su disco per poterla ricaricare col comando
incbin cosi':

TABX:
	incbin	"TABELLA1"

Per fare la TABELLA1 da salvare dobbiamo prima crearci uno spazio vuoto di 512
byte dove crearla col comando "CS":

SPAZIO:
	dcb.b	512,0	; 512 byte azzerati dove sara' creata la tabella
FINESPAZIO:

Una volta assemblato, creeremo la tabella definendo come destinazione "SPAZIO":

 DEST> SPAZIO

E naturalmente 512 valori da generare, di grandezza BYTE:

 AMOUNT> 512
 SIZE (B/W/L)> B

A questo punto avremo la tabella generata nei 512 bytes che vanno da SPAZIO:
a FINESPAZIO: , dunque dobbiamo salvare quel pezzo di memoria in un file.
Per questo esisite un comando dell'ASMONE, il "WB" (ossia Write Binary, cioe'
SCRIVI UN PEZZO DI MEMORIA). Per salvare la nostra tabella bastera' eseguire
queste operazioni:

1) Scrivere "WB" e definire il nome che si vuole dare al file, es "TABELLA1"
2) alla domanda BEG> (begin ossia da dove partire) scrivere SPAZIO
3) alla domanda END> (ossia FINE) scrivere FINESPAZIO

Otterremo in questo modo un file TABELLA1 lungo naturalmente 512 bytes che
conterra' la tabella, ricaricabile con l'INCBIN.

Il comando WB puo' essere applicato per salvare qualsiasi pezzo di memoria!
Potete provare a salvare uno sprite sprite e ricaricarlo con l'incbin.

L'altro sistema e' il comando "IS", ossia INSERT SINUS, inserisci il sinus
nel testo. In questo caso la tabella viene creata direttamente nel listato in
formato dc.b. Puo' essere comodo per piccole tabelle.
Basta posizionarsi col cursore dove si vuole che venga scritta la tabella, ad
esempio sotto la label "TABX:"; a questo punto di deve premere ESC per passare
alla linea di comandi e fare la tabella col comando "IS" anziche' "CS", la
procedura e i parametri da passare sono gli stessi.
Premendo nuovamente ESC troveremo la tabella fatta di dc.b sotto TABX:.

ma vediamo come CREARE una SONTAB usando il comando CS o IS dell'ASMONE:


 DEST> indirizzo o label di destinazione, esempio: DEST>tabx
 BEG> angolo di inizio (0-360) (si possono dare anche valori superiori a 360)
 END> angolo di fine (0-360)
 AMOUNT> numero di valori da generare (esempio: 200 come in questo listato)
 AMPLITUDE> ampiezza, ossia valore piu' alto da raggiungere
 YOFFSET> offset (numero aggiunto a tutti i valori per spostare in "alto")
 SIZE (B/W/L)> dimensione dei valori (byte,word,long)
 MULTIPLIER> "moltiplicatore" (moltiplica l'ampiezza)
 HALF CORRECTION>Y/N		\ questi si occupano di "lisciare" l'onda
 ROUND CORRECTION>Y/N		/ per "correggere" eventuali sbalzi.


Chi sa cosa sono il SENO ed il COSENO capira' al volo come fare, per chi non
lo sa posso dire che con BEG> ed END> si definisce l'angolo inizio e l'angolo
fine dell'onda, ossia la forma dell'onda, se questa comincera' calando e poi
risalendo, oppure se comincera' salendo e poi ricalando. Qua di seguito ci
sono degli esempi con il disegno della curva a fianco.

- Con AMOUNT> si decide quanti valori debba avere la tabella.
- Con AMPLITUDE si definisce l'ampiezza dell'onda, ossia il valore massimo che
  raggiungera' in alto, o in negativo, se e' presente la parte di curva
  negativa.
- Con YOFFSET si decide di quanto "alzare" l'intera curva, ossia quanto si deve
  aggiungere ad ogni valore della tabella. Se per esempio una tabella fosse
  composta da 0,1,2,3,4,5,4,3,2,1,0 con un YOFFSET di 0, mettendo un YOFFSET di
  10 otterremmo 10,11,12,13,14,15,14,13,12,11,10. Nel caso delle posizioni
  dello sprite, sappiamo che la X parte da $40 ed arriva a $d8, dunque
  l'YOFFSET sara' di $40, per traformare gli eventuali $00 in $40, gli $01 in
  $41 eccetera.
- Con "SIZE" definiamo se i valori della tabella saranno byte, word o longword.
  Nel caso delle coordinate dello sprite sono BYTE.
- Il MULTIPLIER> e' un moltiplicatore dell'ampiezza, se non si vuole
  moltiplicare basta definirlo come 1.


Ora rimane da chiarire come definire la "forma dell'onda", ossia la cosa piu'
importante, e per questo possiamo usare solo BEG> ed END> che si riferiscono
all'angolo inizio e all'angolo di fine di tale curva dal punto di vista
trigonometrico. Per chi non conosce la trigonometria consiglio di studiarla
un poco, anche perche' e' importante per le routines tridimensionali.
Brevemente posso sintetizzare cosi': immaginatevi una circonferenza con un
centro O e raggio come vi pare (per motivi tecnici il cerchio non e' tondo..)
inserito negli assi cartesiani X ed Y, per cui il centro O si trova alla
posizione 0,0: (ridisegnate su carta questi passaggi)


			   |
			   | y
			   |
			  _L_
			 / | \	asse x
		--------|--o--|---------»
			 \_L_/
			   |
			   |

Supponiamo ora che sia per un momento un orologio ad una sola lancetta che
vada all'indietro (che esempio contorto!) partendo da questa posizione:


			      90 gradi
			    _____
			   /	 \
			  /	  \
			 /	   \
	    180 gradi	(     O---» ) 0 gradi
			 \	   /
			  \	  /
			   \_____/

			 270 gradi

(fate finta che sia un cerchio!!!) In pratica segna le 3. Al posto delle ore
qua abbiamo i gradi formati dalla lancetta rispetto all'asse X, infatti quando
segna le 12 e' a 90 gradi rispetto all'asse X:

			      90 gradi
			    _____
			   /  ^  \
			  /   |   \
			 /    |    \
	    180 gradi	(     O     ) 0 gradi
			 \	   /
			  \	  /
			   \_____/

			 270 gradi


Allo stesso modo, questi sono 45 gradi:

			      90 gradi
			    _____
			   /     \
			  /     / \
			 /     /   \
	    180 gradi	(     O     ) 0 gradi (o anche 360, il giro completo)
			 \	   /
			  \	  /
			   \_____/

			 270 gradi

Ci siamo con questo balordo orologio che va al contrario e che ha i gradi al
posto delle ore?? Ora veniamo al nesso con i BEG> ed END> del comando "CS".
Disponendo di questo orologio, si puo' fare lo studio dell'andamento della
funzione SENO (e COSENO, perche' no). Immaginiamo di far fare un giro completo
alla lancetta, partendo da 0 gradi a 360, ossia la stessa posizione dopo un
giro completo: se registriamo in un grafico accanto all'orologio i movimenti
della punta della lancetta rispetto all'asse Y noteremo che parte da zero,
poi sale fino alla massima altezza raggiunta ai 90 gradi, dopodiche' scende
nuovamente ritornando a zero una volta giunto a 180 gradi, e continua a
scendere sotto lo zero fino al minimo dei 270 gradi, per poi risalire fino
allo zero iniziale dei 360 gradi (stessa posizione della partenza):


	      90 gradi
	    _____
	   /	 \
	  /	  \
	 /	   \
 180 g.	(     O---» ) 0 gradi	*-----------------------------------
	 \	   /		0	90	180	270	360 (gradi)
	  \	  /
	   \_____/
	 270 gradi


	      90 gradi
	    _____
	   /	 \ 	45 gradi
	  /	/ \- - - - - - - - *
	 /     /   \		 *
 180 g.	(     O     ) 0 gradi	*-------------------------------------
	 \	   /		0	90	180	270	360 (gradi)
	  \	  /
	   \_____/
	 270 gradi


	      90 gradi
	    _____ _ _ _ _ _ _ _ _ _ _ _ *
	   /  ^  \ 		     * 
	  /   |   \ 		   *
	 /    |    \		 *
 180 g.	(     O     ) 0 gradi	*-----------------------------------
	 \	   /		0	90	180	270	360 (gradi)
	  \	  /
	   \_____/
	 270 gradi


	      90 gradi
	    _____ 		       * *
	   /     \ 	135 gradi    *     *
	  / \     \- - - - - - - - * - - - - *
	 /   \     \		 *
 180 g.	(     O     ) 0 gradi	*-----------------------------------
	 \	   /		0	90	180	270	360 (gradi)
	  \	  /
	   \_____/
	 270 gradi


	      90 gradi
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 g.	( <---O     ) 0 gradi	*---------------*---------------------
	 \	   /		0	90	180	270	360 (gradi)
	  \	  /
	   \_____/
	 270 gradi


	      90 gradi
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 g.	(     O     ) 0 gradi	*---------------*---------------------
	 \   /	   /		0	90	180	270	360 (gradi)
	  \ /	  /- - - - - - - - - - - - - - - - -*
	   \_____/		225 gradi
	 270 gradi


	      90 gradi
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 g.	(     O     ) 0 gradi	*---------------*---------------------
	 \    |	   /		0	90	180	270	360 (gradi)
	  \   |	  /				   *
	   \__L__/				     *
	 270 gradi - - - - - - - - - - - - - - - - - - *


	      90 gradi
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 g.	(     O     ) 0 gradi	*---------------*---------------------
	 \     \   /		0	90	180	270	360 (gradi)
	  \	\ /- - - - - - - - - - - - - - - - * - - - - *
	   \_____/		315 gradi	     *	   *
	 270 gradi				       * *


	      90 gradi
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 g.	(     O---> ) 0 gradi	*---------------*----------------*----
	 \ 	   /		0	90	180	270    *360 (gradi)
	  \	  /				   *	     *
	   \_____/		360 gradi	     *	   *
	 270 gradi				       * *


Spero di essere stato abbastanza chiaro per chi e' a digiuno di matematica:
per fare una curva che sale e scende basta dare come angolo inizio 0 e come
angolo di fine 180!!! Per fare una curva che scende e risale basta dare
come angolo inizio BEG> 180 e come angolo fine END> 360, cosi' per tutte le
altre curve. Cambiando AMPLITUDE, YOFFSET e MULTIPLIER farete curve piu'
lunghe e strette o piu' o meno lunghe. Si possono usare anche valori superiori
a 360 per utilizzare la curva del secondo "giro d'orologio", dato che la
funzione e' continua: /\/\/\/\/\/\/\/\/\/\/\.....

Facciamo degli esempi:  (sotto il disegno viene dato un accenno sulla tabella
			(effettiva: 0,1,2,3...999,1000.. ossia il suo contenuto

  UN ESEMPIO DI SINUS:
			   +	 __
  DEST>cosintabx	   _ _ _/_ \_ _ _ _ _ _  = 512 words:
  BEG>0				    \__/
  END>360		   -	0      360
  AMOUNT>512	0,1,2,3...999,1000,999..3,2,0,-1,-2,-3..-1000,-999,...-2,-1,0
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>1


  UN ESEMPIO DI COSINUS:
 			    +	  _	 _
  DEST>cosintabx	    _ _ _ _\_ _ /_ _ _ _  = 512 words:
  BEG>90			    \__/
  END>360+90		   -	90      450
  AMOUNT>512	1000,999..3,2,0,-1,-2,-3..-1000,-999,...-2,-1,0,1,2...999,1000
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>1


UN ALTRO ESEMPIO:
 			   +	 ___
  DEST>cosintabx	   _ _ _/_ _\_ _ _ _  = 800 words:
  BEG>0				    
  END>180		   -	0  180
  AMOUNT>800		0,1,2,3,4,5...999,1000,999..3,2,1,0 (800 valori)
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>1


UN ALTRO ESEMPIO:		  _
 			   +	 / \
  DEST>cosintabx	   _ _ _/_ _\_ _ _ _  = 800 words:
  BEG>0				    
  END>180		   -	0  180
  AMOUNT>800		0,1,2,3,4,5...1999,2000,1999..3,2,1,0 (800 valori)
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>2	<--


UN ALTRO ESEMPIO:		 _	_
			    +	  \    /
  DEST>cosintabx	    _ _ _ _\__/_ _ _ _  = 512 words:
  BEG>90			   
  END>360+90		   -	90      450
  AMOUNT>512	     2000,1999..3,2,0,1,2...1999,2000
  AMPLITUDE>1000
  YOFFSET>1000
  SIZE (B/W/L)>W
  MULTIPLIER>1


 ULTIMO ESEMPIO:		 _	_
			    +	  \    /
  DEST>cosintabx	    _ _ _ _\__/_ _ _ _  = 360 words:
  BEG>90			   
  END>360+90		   -	90      450
  AMOUNT>360	     304,303..3,2,0,1,2...303,304
  AMPLITUDE>152
  YOFFSET>152
  SIZE (B/W/L)>W
  MULTIPLIER>1
  HALF CORRECTION>Y
  ROUND CORRECTION>N

Ecco a voi come rifarsi le tabelle delle coordinate XX ed YY usate negli esempi
precedenti sugli sprite: (parametri per il CS e tabella finale)

Per le coordinate X, che devono andare da $40 a $d8 al massimo

; DEST> tabx
; BEG> 0		 ___ $d0
; END> 180		/   \40
; AMOUNT> 200
; AMPLITUDE> $d0-$40	; $40,$41,$42...$ce,$cf,d0,$cf,$ce...$43,$41....
; YOFFSET> $40	 ; lo zero va trasformato in $40
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$41,$43,$46,$48,$4A,$4C,$4F,$51,$53,$55,$58,$5A
	dc.b	$5C,$5E,$61,$63,$65,$67,$69,$6B,$6E,$70,$72,$74
	dc.b	$76,$78,$7A,$7C,$7E,$80,$82,$84,$86,$88,$8A,$8C
	dc.b	$8E,$90,$92,$94,$96,$97,$99,$9B,$9D,$9E,$A0,$A2
	dc.b	$A3,$A5,$A7,$A8,$AA,$AB,$AD,$AE,$B0,$B1,$B2,$B4
	dc.b	$B5,$B6,$B8,$B9,$BA,$BB,$BD,$BE,$BF,$C0,$C1,$C2
	dc.b	$C3,$C4,$C5,$C5,$C6,$C7,$C8,$C9,$C9,$CA,$CB,$CB
	dc.b	$CC,$CC,$CD,$CD,$CE,$CE,$CE,$CF,$CF,$CF,$CF,$D0
	dc.b	$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0,$CF,$CF,$CF
	dc.b	$CF,$CE,$CE,$CE,$CD,$CD,$CC,$CC,$CB,$CB,$CA,$C9
	dc.b	$C9,$C8,$C7,$C6,$C5,$C5,$C4,$C3,$C2,$C1,$C0,$BF
	dc.b	$BE,$BD,$BB,$BA,$B9,$B8,$B6,$B5,$B4,$B2,$B1,$B0
	dc.b	$AE,$AD,$AB,$AA,$A8,$A7,$A5,$A3,$A2,$A0,$9E,$9D
	dc.b	$9B,$99,$97,$96,$94,$92,$90,$8E,$8C,$8A,$88,$86
	dc.b	$84,$82,$80,$7E,$7C,$7A,$78,$76,$74,$72,$70,$6E
	dc.b	$6B,$69,$67,$65,$63,$61,$5E,$5C,$5A,$58,$55,$53
	dc.b	$51,$4F,$4C,$4A,$48,$46,$43,$41

--	--	--	--	--	--	--	--	--	--

; DEST> tabx			$d0
; BEG> 180		\____/  $40
; END> 360
; AMOUNT> 200
; AMPLITUDE> $d0-$40	; $cf,$cd,$ca...$42,$41,$40,$41,$42...$ca,$cd,$cf
; YOFFSET> $d0	 ; curva sotto zero! allora bisogna aggiungere $d0
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$CF,$CD,$CA,$C8,$C6,$C4,$C1,$BF,$BD,$BB,$B8,$B6
	dc.b	$B4,$B2,$AF,$AD,$AB,$A9,$A7,$A5,$A2,$A0,$9E,$9C
	dc.b	$9A,$98,$96,$94,$92,$90,$8E,$8C,$8A,$88,$86,$84
	dc.b	$82,$80,$7E,$7C,$7A,$79,$77,$75,$73,$72,$70,$6E
	dc.b	$6D,$6B,$69,$68,$66,$65,$63,$62,$60,$5F,$5E,$5C
	dc.b	$5B,$5A,$58,$57,$56,$55,$53,$52,$51,$50,$4F,$4E
	dc.b	$4D,$4C,$4B,$4B,$4A,$49,$48,$47,$47,$46,$45,$45
	dc.b	$44,$44,$43,$43,$42,$42,$42,$41,$41,$41,$41,$40
	dc.b	$40,$40,$40,$40,$40,$40,$40,$40,$40,$41,$41,$41
	dc.b	$41,$42,$42,$42,$43,$43,$44,$44,$45,$45,$46,$47
	dc.b	$47,$48,$49,$4A,$4B,$4B,$4C,$4D,$4E,$4F,$50,$51
	dc.b	$52,$53,$55,$56,$57,$58,$5A,$5B,$5C,$5E,$5F,$60
	dc.b	$62,$63,$65,$66,$68,$69,$6B,$6D,$6E,$70,$72,$73
	dc.b	$75,$77,$79,$7A,$7C,$7E,$80,$82,$84,$86,$88,$8A
	dc.b	$8C,$8E,$90,$92,$94,$96,$98,$9A,$9C,$9E,$A0,$A2
	dc.b	$A5,$A7,$A9,$AB,$AD,$AF,$B2,$B4,$B6,$B8,$BB,$BD
	dc.b	$BF,$C1,$C4,$C6,$C8,$CA,$CD,$CF

--	--	--	--	--	--	--	--	--	--

;			            ___$d8
; DEST> tabx	                   /   \ $d0-$40 ($90)
; BEG> 0		      \___/     $48
; END> 360
; AMOUNT> 200
; AMPLITUDE> ($d0-$40)/2 ; ampiezza sia sopra zero che sotto zero, allora
			 ; bisogna che faccia meta' sopra zero e meta' sotto,
			 ; ossia dividiamo per 2 l'AMPIEZZA
; YOFFSET> $90		; e spostiamo tutto sopra per trasformare -72 in $48
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$91,$93,$96,$98,$9A,$9C,$9F,$A1,$A3,$A5,$A7,$A9
	dc.b	$AC,$AE,$B0,$B2,$B4,$B6,$B8,$B9,$BB,$BD,$BF,$C0
	dc.b	$C2,$C4,$C5,$C7,$C8,$CA,$CB,$CC,$CD,$CF,$D0,$D1
	dc.b	$D2,$D3,$D3,$D4,$D5,$D5,$D6,$D7,$D7,$D7,$D8,$D8
	dc.b	$D8,$D8,$D8,$D8,$D8,$D8,$D7,$D7,$D7,$D6,$D5,$D5
	dc.b	$D4,$D3,$D3,$D2,$D1,$D0,$CF,$CD,$CC,$CB,$CA,$C8
	dc.b	$C7,$C5,$C4,$C2,$C0,$BF,$BD,$BB,$B9,$B8,$B6,$B4
	dc.b	$B2,$B0,$AE,$AC,$A9,$A7,$A5,$A3,$A1,$9F,$9C,$9A
	dc.b	$98,$96,$93,$91,$8F,$8D,$8A,$88,$86,$84,$81,$7F
	dc.b	$7D,$7B,$79,$77,$74,$72,$70,$6E,$6C,$6A,$68,$67
	dc.b	$65,$63,$61,$60,$5E,$5C,$5B,$59,$58,$56,$55,$54
	dc.b	$53,$51,$50,$4F,$4E,$4D,$4D,$4C,$4B,$4B,$4A,$49
	dc.b	$49,$49,$48,$48,$48,$48,$48,$48,$48,$48,$49,$49
	dc.b	$49,$4A,$4B,$4B,$4C,$4D,$4D,$4E,$4F,$50,$51,$53
	dc.b	$54,$55,$56,$58,$59,$5B,$5C,$5E,$60,$61,$63,$65
	dc.b	$67,$68,$6A,$6C,$6E,$70,$72,$74,$77,$79,$7B,$7D
	dc.b	$7F,$81,$84,$86,$88,$8A,$8D,$8F

--	--	--	--	--	--	--	--	--	--

 TABELLA DELLE Y:
; Da notare che la posizione Y per far entrare lo sprite nella finestra video
; deve essere compresa tra $2c e $f2, infatti nella tabella ci sono byte non
; piu' grandi di $f2 e non piu' piccoli di $2c.

; DEST> taby			$f0 (d0)
; BEG> 180		\____/  $2c (40)
; END> 360
; AMOUNT> 200
; AMPLITUDE> $f0-$2c	; $ef,$ed,$ea...$2c...$ea,$ed,$ef
; YOFFSET> $f0
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$EE,$EB,$E8,$E5,$E2,$DF,$DC,$D9,$D6,$D3,$D0,$CD ; salto in
	dc.b	$CA,$C7,$C4,$C1,$BE,$BB,$B8,$B5,$B2,$AF,$AC,$A9 ; alto da
	dc.b	$A6,$A4,$A1,$9E,$9B,$98,$96,$93,$90,$8E,$8B,$88 ; record!
	dc.b	$86,$83,$81,$7E,$7C,$79,$77,$74,$72,$70,$6D,$6B
	dc.b	$69,$66,$64,$62,$60,$5E,$5C,$5A,$58,$56,$54,$52
	dc.b	$51,$4F,$4D,$4B,$4A,$48,$47,$45,$44,$42,$41,$3F
	dc.b	$3E,$3D,$3C,$3A,$39,$38,$37,$36,$35,$34,$33,$33
	dc.b	$32,$31,$30,$30,$2F,$2F,$2E,$2E,$2D,$2D,$2D,$2C
	dc.b	$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2D,$2D,$2D
	dc.b	$2E,$2E,$2F,$2F,$30,$30,$31,$32,$33,$33,$34,$35
	dc.b	$36,$37,$38,$39,$3A,$3C,$3D,$3E,$3F,$41,$42,$44
	dc.b	$45,$47,$48,$4A,$4B,$4D,$4F,$51,$52,$54,$56,$58
	dc.b	$5A,$5C,$5E,$60,$62,$64,$66,$69,$6B,$6D,$70,$72
	dc.b	$74,$77,$79,$7C,$7E,$81,$83,$86,$88,$8B,$8E,$90
	dc.b	$93,$96,$98,$9B,$9E,$A1,$A4,$A6,$A9,$AC,$AF,$B2
	dc.b	$B5,$B8,$BB,$BE,$C1,$C4,$C7,$CA,$CD,$D0,$D3,$D6
	dc.b	$D9,$DC,$DF,$E2,$E5,$E8,$EB,$EE


--	--	--	--	--	--	--	--	--	--


;			            ___ ($f0) $d8
; DEST> taby	                   /   \ ($f0-$2c) $d0-$40 ($90)
; BEG> 0		      \___/      ($2c) $48
; END> 360
; AMOUNT> 200
; AMPLITUDE> ($f0-$2c)/2 ;
; YOFFSET> $8e		; sarebbe $f0-(($f0-$2c)/2)
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$8E,$91,$94,$97,$9A,$9D,$A0,$A3,$A6,$A9,$AC,$AF
	dc.b	$B2,$B4,$B7,$BA,$BD,$BF,$C2,$C5,$C7,$CA,$CC,$CE
	dc.b	$D1,$D3,$D5,$D7,$D9,$DB,$DD,$DF,$E0,$E2,$E3,$E5
	dc.b	$E6,$E7,$E9,$EA,$EB,$EC,$EC,$ED,$EE,$EE,$EF,$EF
	dc.b	$EF,$EF,$F0,$EF,$EF,$EF,$EF,$EE,$EE,$ED,$EC,$EC
	dc.b	$EB,$EA,$E9,$E7,$E6,$E5,$E3,$E2,$E0,$DF,$DD,$DB
	dc.b	$D9,$D7,$D5,$D3,$D1,$CE,$CC,$CA,$C7,$C5,$C2,$BF
	dc.b	$BD,$BA,$B7,$B4,$B2,$AF,$AC,$A9,$A6,$A3,$A0,$9D
	dc.b	$9A,$97,$94,$91,$8E,$8B,$88,$85,$82,$7F,$7C,$79
	dc.b	$76,$73,$70,$6D,$6A,$68,$65,$62,$5F,$5D,$5A,$57
	dc.b	$55,$52,$50,$4E,$4B,$49,$47,$45,$43,$41,$3F,$3D
	dc.b	$3C,$3A,$39,$37,$36,$35,$33,$32,$31,$30,$30,$2F
	dc.b	$2E,$2E,$2D,$2D,$2D,$2D,$2C,$2D,$2D,$2D,$2D,$2E
	dc.b	$2E,$2F,$30,$30,$31,$32,$33,$35,$36,$37,$39,$3A
	dc.b	$3C,$3D,$3F,$41,$43,$45,$47,$49,$4B,$4E,$50,$52
	dc.b	$55,$57,$5A,$5D,$5F,$62,$65,$68,$6A,$6D,$70,$73
	dc.b	$76,$79,$7C,$7F,$82,$85,$88,$8B,$8d

--	--	--	--	--	--	--	--	--	--

Dato che avete tutte queste tabelle XX ed YY pronte provate a sostituirle a
quelle del listato, per creare molti effetti diversi, e provate a farne altre
con 100, 120, 300 valori anziche' 200 ( AMOUNT> 100), per creare infinite
traiettorie dello sprite.

