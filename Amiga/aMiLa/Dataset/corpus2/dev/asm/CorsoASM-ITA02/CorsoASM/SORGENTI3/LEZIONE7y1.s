
; Lezione7y1.s	UNO SPRITE VISUALIZZATO SCRIVENDO DIRETTAMENTE I REGISTRI
;		(SENZA DMA)
;       Questo esempio mostra uno sprite ottenuto usando direttamente i
;       registri. Lo sprite tra l'altro viene visualizzato a due diverse
;	posizioni orizzontali, in modo analogo al riutilizzo.


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

;	NON Puntiamo lo sprite !!!!!!!!!!!!!!!!!!!!

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
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

	dc.w	$1A2,$FF0	; color17, ossia COLOR1 dello sprite0 - GIALLO
	dc.w	$1A4,$a00	; color18, ossia COLOR2 dello sprite0 - ROSSO
	dc.w	$1A6,$F70	; color19, ossia COLOR3 dello sprite0 - ARANCIO


	dc.w	$4007,$fffe	; aspetta la linea $40
	dc.w	$140,$0080	; SPR0POS - posizione orizzontale
	dc.w	$142,$0000	; SPR0CTL
	dc.w	$146,$0e70	; SPR0DATB
	dc.w	$144,$03c0	; SPR0DATA - attiva lo sprite

	dc.w	$6007,$fffe	; aspetta la linea $60
	dc.w	$142,$0000	; SPR0CTL - "spegne" lo sprite 

	dc.w	$140,$00a0	; SPR0POS - nuova posizione orizz.
	dc.w	$146,$2ff4	; SPR0DATB
	dc.w	$8007,$fffe	; aspetta la linea $80
	dc.w	$144,$13c8	; SPR0DATA - attiva lo sprite

	dc.w	$b407,$fffe	; aspetta la linea $b4
	dc.w	$142,$0000	; SPR0CTL - "spegne" lo sprite 

	dc.w	$FFFF,$FFFE	; Fine della copperlist



	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo esempio vediamo come usare uno sprite manipolando direttamente i
registri SPRxPOS, SPRxCTL, SPRxDATA, SPRxDATB.
Per prima cosa notate che NON puntiamo lo sprite nella copperlist. Anzi, per
di piu` NON esiste la struttura sprite nella memoria chip. Infatti questa
struttura e` usata dal DMA, che, quando e` usato,in pratica non fa altro che
copiare i dati dalla struttura nei registri SPRxPOS, SPRxCTL, SPRxDATA,
SPRxDATB. Se scriviamo noi i dati direttamente in quei registri, non abbiamo
bisogno del DMA. Vediamo in dettaglio come si usano i registri.
In SPRxPOS, viene scritta la posizione dello sprite. Il contenuto di questo
registro e` in pratica lo stesso della prima word di controllo della
struttura sprite che usiamo con il DMA. La differenza, pero` e` che VSTART
non influenza la posizione verticale degli sprite. Gli sprite infatti vengono
attivati scrivendo nel registro SPRxDATA. Una volta attivato, uno
sprite, viene disegnato ad ogni riga, alla posizione orizzontale che abbiamo
scritto in SPRxPOS, e per ogni riga esso ha sempre la stessa "forma".
La "forma" dello sprite viene scritta nei due registri SPRxDATB e SPRxDATA
che funzionano esattamente come le coppie di word che descrivono la forma
dello sprite nella struttura che si usa con il DMA. I bit piu` significativi
sono contenuti in SPRxDATB e i meno significativi in SPRxDATA. Questi due
registri vengono riutilizzati per ogni riga. Se quindi si desidera che la
forma dello sprite cambi da una riga ad un'altra e` necessario modificare i
due registri SPRxDATx ad ogni riga.
Il registro SPRxCTL, invece ha lo stesso contenuto della seconda word di
controllo della struttura. Anche qui la posizione verticale non serve a
niente. In pratica, di tutto il registro gli unici bit che hanno un
significato, sono il bit 0, che e` il bit basso di HSTART e il bit 7 che
serve per "attaccare" gli sprite. Scrivendo nel registro SPRxCTL, inoltre, si
disabilita lo sprite.

Usare gli sprite senza DMA e` molto scomodo per il fatto di dover cambiare ad
ogni riga SPRxDATx. Infatti di solito non viene usato. Puo` diventare
vantaggioso, pero` nel caso in cui si voglia uno sprite che sia uguale per
ogni riga: in pratica per fare delle colonne. In questo caso infatti non e`
necessario cambiare ad ogni riga SPRxDATx, perche` quello che si vuole e`
appunto che ad ogni riga lo sprite abbia la stessa forma. Inoltre con questo
metodo risparmiamo molta memoria: se dovessimo fare uno sprite-colonna alto 
100 righe con il DMA, saremmo infatti costretti a utilizzare una struttura
lunga 100 longword, escluse le word di controllo!

La procedura per fare una colonna con gli sprite senza DMA, quindi,
 e` la seguente:
1) si scrivono i giusti valori in SPRxPOS, SPRxCTL e SPRxDATB
2) si attende la posizione verticale nella quale si vuole far iniziare lo
sprite.
3) si scrive il valore di SPRxDATA. A questo punto lo sprite verra`
disegnato, sempre uguale ad ogni riga.
4) si attende la posizione verticale nella quale si vuole far finire lo
sprite.
5) si scrive un qualsiasi valore in SPRxCTL

E` possibile, come facciamo in questo esempio, visualizzare piu` colonne a 
diverse altezze, ripetendo la procedura precedentemente descritta piu` volte 
nella stessa copperlist. Si potrebbe anche cambiare la palette tra una
colonna e l'altra.

