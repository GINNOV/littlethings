
; Lezione7g.s	UNO SPRITE A 16 COLORI IN MODO ATTACCHED MOSSO SULLO SCHERMO
; 		USANDO DUE TABELLE DI VALORI (ossia di coordinate verticali
;		e orizzontali) PRESTABILITI.


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

;	Puntiamo gli sprite 0 ed 1, che ATTACCATI formeranno un solo sprite
;	a 16 colori. Lo sprite1, quello dispari, deve avere il bit 7 della
;	seconda word ad 1.

	MOVE.L	#MIOSPRITE0,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE1,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	bset	#7,MIOSPRITE1+3		; Setta il bit dell'attacched allo
					; sprite 1. Togliendo questa istruzione
					; gli sprite non sono ATTACCHED, ma
					; due a 3 colori sovrapposti.

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

; Questa routine sposta  lo sprite agendo sul suo byte HSTART, ossia
; il byte della sua posizione X, immettendoci delle coordinate gia' stabilite
; nella tabella TABX. (Scatti di 2 pixel alla volta)

MuoviSpriteX:
	ADDQ.L	#1,TABXPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTX	; non ancora? allora continua
	MOVE.L	#TABX-1,TABXPOINT ; Riparti a puntare dal primo byte-1
NOBSTARTX:
	MOVE.b	(A0),MIOSPRITE0+1 ; copia il byte dalla tabella ad HSTART0
	MOVE.b	(A0),MIOSPRITE1+1 ; copia il byte dalla tabella ad HSTART1
	rts

TABXPOINT:
	dc.l	TABX-1		; NOTA: i valori della tabella sono bytes

; Tabella con coordinate X dello sprite precalcolate.

TABX:
	incbin	"XCOORDINAT.TAB"	; 334 valori
FINETABX:


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
	MOVE.b	d0,MIOSPRITE0	; copia il byte in VSTART0
	MOVE.b	d0,MIOSPRITE1	; copia il byte in VSTART1
	ADD.B	#15,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,MIOSPRITE0+2	; Muovi il valore giusto in VSTOP0
	move.b	d0,MIOSPRITE1+2	; Muovi il valore giusto in VSTOP1
	rts

TABYPOINT:
	dc.l	TABY-1		; NOTA: i valori della tabella sono bytes

; Tabella con coordinate Y dello sprite precalcolate.

TABY:
	incbin	"YCOORDINAT.TAB"	; 200 valori
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

;	Palette della PIC

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

;	Palette degli SPRITE attacched

	dc.w	$1A2,$FFC	; color17, COLORE 1 per gli sprite attaccati
	dc.w	$1A4,$EEB	; color18, COLORE 2 per gli sprite attaccati
	dc.w	$1A6,$CD9	; color19, COLORE 3 per gli sprite attaccati
	dc.w	$1A8,$AC8	; color20, COLORE 4 per gli sprite attaccati
	dc.w	$1AA,$8B6	; color21, COLORE 5 per gli sprite attaccati
	dc.w	$1AC,$6A5	; color22, COLORE 6 per gli sprite attaccati
	dc.w	$1AE,$494	; color23, COLORE 7 per gli sprite attaccati
	dc.w	$1B0,$384	; color24, COLORE 7 per gli sprite attaccati
	dc.w	$1B2,$274	; color25, COLORE 9 per gli sprite attaccati
	dc.w	$1B4,$164	; color26, COLORE 10 per gli sprite attaccati
	dc.w	$1B6,$154	; color27, COLORE 11 per gli sprite attaccati
	dc.w	$1B8,$044	; color28, COLORE 12 per gli sprite attaccati
	dc.w	$1BA,$033	; color29, COLORE 13 per gli sprite attaccati
	dc.w	$1BC,$012	; color30, COLORE 14 per gli sprite attaccati
	dc.w	$1BE,$001	; color31, COLORE 15 per gli sprite attaccati

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco gli sprite: OVVIAMENTE in CHIP RAM! **********

MIOSPRITE0:		; lunghezza 15 linee
VSTART0:
	dc.b $00	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART0:
	dc.b $00	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP0:
	dc.b $00	; posizione verticale di fine sprite
	dc.b $00

	dc.w $0380,$0650,$04e8,$07d0,$0534,$1868,$1e5c,$1636 ; dati dello
	dc.w $377e,$5514,$43a1,$1595,$0172,$1317,$6858,$5035 ; sprite 0
	dc.w $318c,$0c65,$7453,$27c9,$5ece,$5298,$0bfe,$2c32
	dc.w $005c,$13c4,$0be8,$0c18,$03e0,$03e0

	dc.w	0,0	; 2 word azzerate definiscono la fine dello sprite.



MIOSPRITE1:		; lunghezza 15 linee
VSTART1:
	dc.b $00	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART1:
	dc.b $00	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP1:
	dc.b $00	; $50+13=$5d	; posizione verticale di fine sprite
	dc.b $00	; settare il bit 7 per attaccare sprite 0 ed 1.

	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e ; dati dello
	dc.w $58f2,$600e,$5873,$600f,$5cf1,$600f,$1ff3,$600f ; sprite 1
	dc.w $4fe3,$701f,$47c7,$783f,$6286,$7d7e,$300e,$3ffe
	dc.w $1c3c,$1ffc,$0ff8,$0ff8,$03e0,$03e0

	dc.w	0,0	; 2 word azzerate definiscono la fine dello sprite.


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

A parte la novita' del bit ATTACCHED per fare uno sprite a 16 colori anziche'
due a 4 colori, sono da notare un paio di cose:
1) Le tabelle X ed Y sono state salvate col comando "WB" e vengono caricate
con l'incbin, in questo modo le tabelle possono essere caricate dai vari
listati che le richiedono, basta che siano sul disco!
2) Non vengono piu' usate le label VSTART0,VSTART1,HSTART0,HSTART1 ecc. per
muovere lo sprite. Le label rimangono al loro posto nello sprite in questo
listato, ma risulta piu' comodo "raggiungere" i byte di controllo cosi':

	MIOSPRITE	; Per VSTART
	MIOSPRITE+1	; Per HSTART
	MIOSPRITE+2	; Per VSTOP

In questo modo si puo' semplicemente cominciare lo sprite con:

MIOSPRITE:
	DC.W	0,0
	..dati...

Senza dividere le due word in singoli byte, ognuno con una LABEL che allunga
il listato.
Anche per settare il bit 7 della word 2 dello SPRITE1, quello dell'ATTACCHED,
e' bastata questa istruzione:

	bset	#7,MIOSPRITE1+3

Altrimento avremmo potuto settarlo "a mano" nel quarto byte:

MIOSPRITE1:
VSTART1:
	dc.b $00
HSTART1:
	dc.b $00
VSTOP1:
	dc.b $00
	dc.b %10000000		; oppure dc.b $80 ($80=%10000000)

Se si devono usare tutti e 8 gli sprite si risparmiano un bel po' di label e
di spazio. Ancora meglio sarebbe mettere in un registro Ax l'indirizzo dello
sprite ed eseguire gli offset da quel registro:

	lea	MIOSPRITE,a0
	MOVE.B	#yy,(a0)	; Per VSTART
	MOVE.B	#xx,1(A0)	; Per HSTART
	MOVE.B	#y2,2(A0)	; Per VSTOP

Definirsi in binario uno sprite a 16 colori diventa problematico.
Dunque bisogna ricorrere ad un programma di disegno, basta ricordarsi di
usare uno schermo a 16 colori e di disegnare gli sprite non piu' larghi di 16
pixel. Una volta salvata la PIC a 16 colori (o un BRUSH piu' piccolo con lo
sprite) in formato IFF, convertirlo con l'IFFCONVERTER e' facile come
convertire una figura.

NOTA: Per BRUSH si intende un pezzo di figura di dimensioni variabili.

Ecco come potete convertirvi uno sprite col KEFCON:

1) Caricate il file IFF, che deve essere a 16 colori
2) Dovete selezionare solo lo sprite, per fare cio' premete il tasto destro,
poi posizionatevi sull'angolo in alto a sinistra del futuro sprite, e premete
il tasto sinistro. Muovendo il mouse vi apparira' una griglia che, guarda caso,
e' divisa a strisce larghe 16 pixel. Potete comunque controllare la larghezza
e la lunghezza del blocco selezionato. Per includere bene lo sprite dovete
considerare che dovete passare per il bordo dello sprite con la "striscia" di
selezione del rettangolo, l'ultima linea inclusa nel rettangolo e' quella che
passa per la striscia di confine, non e' quella interna alla striscia:

	<----- 16 pixel ----->

	|========####========| /\
	||     ########	    || ||
	||   ############   || ||
	|| ################ || ||
	||##################|| ||
	###################### ||
	###################### Lunghezza dello sprite, massimo 256 pixel
	###################### ||
	||##################|| ||
	|| ################ || ||
	||   ############   || ||
	||     ########     || ||
	|========####========| \/


Se lo sprite e' piu' piccolo di 16 pixel dovete lasciare un margine vuoto ai
lati, o ad un solo lato, in modo che la larghezza del blocco sia sempre 16.

Una volta selezionato lo sprite dentro il rettangolo, occorre salvarlo come
SPRITE16 se e' uno sprite a 16 colori, o come SPRITE4 se e' uno sprite a
quattro colori. Lo sprite viene salvato in "dc.b", ossia in formato TESTO, che
potete includere nel listato col comando "I" dell'Asmone o caricandolo in un
altro buffer di testo e copiandolo con Amiga+b+c+i.

Ecco come il KEFCON salva lo sprite attacched (16 colori):

	dc.w $0000,$0000
	dc.w $0380,$0650,$04e8,$07d0,$0534,$1868,$1e5c,$1636
	dc.w $377e,$5514,$43a1,$1595,$0172,$1317,$6858,$5035
	dc.w $318c,$0c65,$7453,$27c9,$5ece,$5298,$0bfe,$2c32
	dc.w $005c,$13c4,$0be8,$0c18,$03e0,$03e0
	dc.w 0,0

	dc.w $0000,$0000
	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e
	dc.w $58f2,$600e,$5873,$600f,$5cf1,$600f,$1ff3,$600f
	dc.w $4fe3,$701f,$47c7,$783f,$6286,$7d7e,$300e,$3ffe
	dc.w $1c3c,$1ffc,$0ff8,$0ff8,$03e0,$03e0
	dc.w 0,0

Come potete notare, questi sono i due sprite con le due word di controllo
azzerate, i dati in formato esadecimale e le due word azzerate di FINE SPRITE.
Basta mettere le due label "MIOSPRITE0:" e "MIOSPRITE1:" all'inizio dei due
sprite, dopodiche' lavorando con MIOSPRITE+x per raggiungere i byte delle
coordinate non occorre aggiungere altre LABEL. L'unico particolare e' che
bisogna settare il bit dell'ATTACCHED con un BSET #7,MIOSPRITE+3 oppure
direttamente nello sprite:

MIOSPRITE1:
	dc.w $0000,$0080	; $80, ossia %10000000 -> ATTACCHED!
	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e
	...

Se volete disegnarvi e convertirvi anche gli sprite a 4 colori, il problema non
sussiste, perche' viene salvato un solo sprite e non occorre settare il bit!

Per quanto riguarda la palette dei colori degli sprite, bisogna salvarli dal
KEFCON dopo aver salvato lo SPRITE16 o SPRITE4, con l'opzione COPPER, proprio
come per le figure normali. Il problemuccio e' che viene salvata la palette
intesa come FIGURA a 16 COLORI, e non come SPRITE.
Ecco come il KEFCON salva la palette:

	dc.w $0180,$0000,$0182,$0ffc,$0184,$0eeb,$0186,$0cd9
	dc.w $0188,$0ac8,$018a,$08b6,$018c,$06a5,$018e,$0494
	dc.w $0190,$0384,$0192,$0274,$0194,$0164,$0196,$0154
	dc.w $0198,$0044,$019a,$0033,$019c,$0012,$019e,$0001

I colori sono giusti, ma i registri colore si riferiscono ai primi 16 colori
e non gli ultimi 16. Basta riscriverli "a mano" nei registri colore giusti:

	dc.w	$1A2,$FFC	; color17, COLORE 1 per gli sprite attaccati
	dc.w	$1A4,$EEB	; color18, COLORE 2 per gli sprite attaccati
	dc.w	$1A6,$CD9	; color19, COLORE 3 per gli sprite attaccati
	dc.w	$1A8,$AC8	; color20, COLORE 4 per gli sprite attaccati
	dc.w	$1AA,$8B6	; color21, COLORE 5 per gli sprite attaccati
	dc.w	$1AC,$6A5	; color22, COLORE 6 per gli sprite attaccati
	dc.w	$1AE,$494	; color23, COLORE 7 per gli sprite attaccati
	dc.w	$1B0,$384	; color24, COLORE 7 per gli sprite attaccati
	dc.w	$1B2,$274	; color25, COLORE 9 per gli sprite attaccati
	dc.w	$1B4,$164	; color26, COLORE 10 per gli sprite attaccati
	dc.w	$1B6,$154	; color27, COLORE 11 per gli sprite attaccati
	dc.w	$1B8,$044	; color28, COLORE 12 per gli sprite attaccati
	dc.w	$1BA,$033	; color29, COLORE 13 per gli sprite attaccati
	dc.w	$1BC,$012	; color30, COLORE 14 per gli sprite attaccati
	dc.w	$1BE,$001	; color31, COLORE 15 per gli sprite attaccati

Si noti che in $1a2 bisogna copiare il colore in $182, in $1a4 quello in $184
e cosi' via.

Provate a sostituire lo sprite a 16 colori di questo listato con uno vostro,
con la vostra palette colori, e anche a convertirne uno a 4 colori da
sostituire a quello delle lezioni precedenti. Farlo servira' da verifica!!!

