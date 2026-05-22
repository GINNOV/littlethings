
; Lezione7a.s		VISUALIZZAZIONE DI UNO SPRITE


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

	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco lo sprite: OVVIAMENTE deve essere in CHIP RAM! ************

MIOSPRITE:		; lunghezza 13 linee
VSTART:
	dc.b $30	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART:
	dc.b $90	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP:
	dc.b $3d	; $30+13=$3d	; posizione verticale di fine sprite
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

Questo e' il primo sprite che controlliamo nel corso, potete facilmente
definirne uno vostro cambiando i suoi 2 piani , che in questo listato sono
definiti in binario; il colore risultante dalle varie sovrapposizioni
binarie puo' essere intuito leggendo il commento a fianco dello sprite.
I colori dello sprite 0 sono definiti dai registri del COLOR 17,18 e 19:

	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO

Per cambiare la posizione dello sprite, agite sui suoi primi byte:

MIOSPRITE:		; lunghezza 13 linee
VSTART:
	dc.b $30	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART:
	dc.b $90	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP:
	dc.b $3d	; $30+13=$3d	; posizione verticale di fine sprite
	dc.b $00

Basta ricordarsi queste due cose:

1) L'angolo in alto a sinistra dello schermo non e' la posizione $00,$00
infatti lo schermo con l'overscan puo' essere piu' largo; nel caso dello
schermo di larghezza normale la posizione orizzontale iniziale (HSTART) puo'
andare da $40 a $d8, altrimenti lo sprite viene "tagliato" o va proprio fuori
dallo schermo visibile. Allo stesso modo la posizione verticale iniziale, ossia
il VSTART, va selezionato a partire da $2c, cioe' dall'inizio della finestra
video definita in DIWSTART (che qua e' $2c81). 
Per posizionare nello schermo 320x256 lo sprite, per esempio alla cordinata
centrale 160,128 bisogna tener conto che la prima coordinata in alto a sinistra
e' $40,$2c anziche' 0,0 per cui bisogna sommare $40 alla coordinata X e $2c
alla coordinata Y.
Infatti $40+160, $2c+128, corrispondono alla coordinata 160,128 di uno schermo
320x256 non overscan.
Non avendo ancora il controllo della posizione orizzontale a livello di 1
pixel, ma ogni 2 pixel, dobbiamo sommare non 160, ma 160/2 all'inizio per
individuare il centro dello schermo:

HSTART:
	dc.b $40+(160/2)	; posizionato al centro dello schermo

Cosi' per altre coordinate orizzontali, ad esempio la posizione 50:

	dc.b $40+(50/2)

Piu' avanti vedremo come posizionare orizzontalmente 1 pixel alla volta.

2) La posizione orizzontale si puo' variare da sola per spostare a destra e a
sinistra uno sprite, mentre se si intende spostare lo sprite in alto o in basso
e' necessario ogni volta agire su due byte, ossia su VSTART e VSTOP, cioe' la
posizione verticale di inizio e di fine sprite. Infatti, mentre la larghezza di
uno sprite e' sempre 16, per cui determinata la posizione orizzontale di inizio
la posizione di fine e' sempre 16 pixel piu' a destra, per quanto riguarda la
lunghezza in verticale, essendo a piacere, e' necessario definirla comunicando
la posizione di inizio e di fine ogni volta, per cui se vogliamo spostare lo
sprite in alto dobbiamo sottrarre 1 sia a VSTART che a VSTOP, se vogliamo
spostarlo in basso e' necessario invece aggiungere 1 ad entrambi.
Se per esempio si vuole modificare il VSTART in $55, per determinare VSTOP
occorrera' sommare la lunghezza dello sprite (questo e' alto 13 linee) a
VSTART, dunque $55+13=$62.

Spostate lo sprite in varie posizioni dello schermo per verificare se avete
capito o se avete solo l'illusione di aver capito.
Non dimenticatevi che HSTART fa spostare di 2 pixel ogni volta e non di 1
pixel come potrebbe sembrare.

