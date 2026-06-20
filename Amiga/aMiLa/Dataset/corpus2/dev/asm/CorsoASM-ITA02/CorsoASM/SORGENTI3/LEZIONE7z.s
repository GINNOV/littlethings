
; Lezione7z.s	ANIMAZIONE (6 FOTOGRAMMI) DI UNO SPRITE ATTACCHED


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

	MOVE.L	FRAMETAB(PC),d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#$44,d0		; lo sprite dispari e' 44 bytes dopo!
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

; P.S: non occore settare il bit 7, e' gia' settato nello sprite in questo caso

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	Animazione
	bsr.w	MuoviSprites	; Muovi gli sprites

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

; Questa routine anima gli sprite, spostando gli indirizzi dei fotogrammi
; in maniera che ogni volta il primo della tabella vada all'ultimo posto,
; mentra gli altri scorrono tutti di un posto in direzione del primo

Animazione:
	addq.b	#1,ContaAnim    ; queste tre istruzioni fanno si' che il
	cmp.b	#2,ContaAnim    ; fotogramma venga cambiato una volta
	bne.s	NonCambiare     ; si e una no.
	clr.b	ContaAnim
	LEA	FRAMETAB(PC),a0 ; tabella dei fotogrammi
	MOVE.L	(a0),d0		; salva il primo indirizzo in d0
	MOVE.L	4(a0),(a0)	; sposta indietro gli altri 5 indirizzi
	MOVE.L	4*2(a0),4(a0)	; Queste istruzioni "ruotano" gli indirizzi
	MOVE.L	4*3(a0),4*2(a0) ; della tabella.
	MOVE.L	4*4(a0),4*3(a0)
	MOVE.L	4*5(a0),4*4(a0)
	MOVE.L	d0,4*5(a0)	; metti l'ex primo indirizzo al sesto posto

	MOVE.L	FRAMETAB(PC),d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatore sprite pari
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#$44,d0		; lo sprite dispari e' 44 bytes dopo il pari
	addq.w	#8,a1		; POINTER dello sprite dispari
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
NonCambiare:
	rts

ContaAnim:
	dc.w	0

; Questa e` la tabella degli indirizzi dei fotogrammi dello sprite pari, da
; cui si accede anche ai rispettivi sprite dispari da attaccare. Gli indirizzi
; presenti nella tabella vengono "ruotati" all'interno della tabella dalla
; routine Animazione, in modo che il primo nella lista sia la prima volta il
; fotogramma1, la volta dopo il Fotogramma2, poi il 3,4,5,6 e di nuovo il
; primo, ciclicamente. In questo modo basta prendere l'indirizzo che sta
; all'inizio della tabella ogni volta dopo il "rimescolamento" per avere gli
; indirizzi dei fotogrammi in sequenza.

FRAMETAB:
	DC.L	Fotogramma1
	DC.L	Fotogramma2
	DC.L	Fotogramma3
	DC.L	Fotogramma4
	DC.L	Fotogramma5
	DC.L	Fotogramma6


; Questa routine legge dalle 2 tabelle le coordinate reali degli sprite.
; poiche` gli sprites sono attached hanno entrambi le stesse coordiante.

MuoviSprites:
	ADDQ.L	#1,TABYPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultimo byte della TAB?
	BNE.S	NOBSTARTY	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT ; Riparti a puntare dal primo byte
NOBSTARTY:
	moveq	#0,d3		; Pulisci d3
	MOVE.b	(A0),d3		; copia il byte della tabella, cioe` la
				; coordinata Y in d3

	ADDQ.L	#2,TABXPOINT	 ; Fai puntare alla word successiva
	MOVE.L	TABXPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-2,A0  ; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTX	; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT ; Riparti a puntare dalla prima word-2
NOBSTARTX:
	moveq	#0,d4		; azzeriamo d4
	MOVE.w	(A0),d4		; poniamo il valore della tabella, cioe`
				; la coordinata X in d4

        MOVE    D3,D0           ; coordinata Y in d0
        MOVE    D4,D1           ; coordinata X in d1
	moveq	#15,d2		; altezza dello sprite in d2
	MOVE.L	FRAMETAB(PC),a1	; indirizzo dello sprite in A1

	bsr.w	UniMuoviSprite  ; esegue la routine universale che posiziona
        			; lo sprite pari

	MOVE.W	D3,D0		; coordinata Y in d0
	MOVE.W	D4,D1		; coordinata X in d1
	moveq	#15,d2		; altezza dello sprite in d2
	LEA	$44(a1),a1	; indirizzo dello sprite dispari in A1
				; lo sprite dispari e` $44 bytes dopo quello
				; pari
	bsr.w	UniMuoviSprite  ; esegue la routine universale che posiziona
        			; lo sprite dispari
	rts


TABYPOINT:
	dc.l	TABY-1		; NOTA: i valori della tabella qua sono bytes,
				; dunque lavoriamo con un ADDQ.L #1,TABYPOINT
				; e non #2 come per quando sono word o con #4
				; come quando sono longword.
TABXPOINT:
	dc.l	TABX-2		; NOTA: i valori della tabella qua sono word,

; Tabella con coordinate Y dello sprite precalcolate.

TABY:
	incbin	"ycoordinatok.tab"	; 200 valori .B
FINETABY:

; Tabella con coordinate X dello sprite precalcolate.

TABX:
	incbin	"xcoordinatok.tab"	; 150 valori .W
FINETABX:



; Routine universale di posizionamento degli sprite.

;
;	Parametri in entrata di UniMuoviSprite:
;
;	a1 = Indirizzo dello sprite
;	d0 = posizione verticale Y dello sprite sullo schermo (0-255)
;	d1 = posizione orizzontale X dello sprite sullo schermo (0-320)
;	d2 = altezza dello sprite
;

UniMuoviSprite:
; posizionamento verticale
	ADD.W	#$2c,d0		; aggiungi l'offset dell'inizio dello schermo

; a1 contiene l'indirizzo dello sprite
	MOVE.b	d0,(a1)		; copia il byte in VSTART
	btst.l	#8,d0
	beq.s	NonVSTARTSET
	bset.b	#2,3(a1)	; Setta il bit 8 di VSTART (numero > $FF)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,3(a1)	; Azzera il bit 8 di VSTART (numero < $FF)
ToVSTOP:
	ADD.w	D2,D0		; Aggiungi l'altezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,2(a1)	; Muovi il valore giusto in VSTOP
	btst.l	#8,d0
	beq.s	NonVSTOPSET
	bset.b	#1,3(a1)	; Setta il bit 8 di VSTOP (numero > $FF)
	bra.w	VstopFIN
NonVSTOPSET:
	bclr.b	#1,3(a1)	; Azzera il bit 8 di VSTOP (numero < $FF)
VstopFIN:

; posizionamento orizzontale
	add.w	#128,D1		; 128 - per centrare lo sprite.
	btst	#0,D1		; bit basso della coordinata X azzerato?
	beq.s	BitBassoZERO
	bset	#0,3(a1)	; Settiamo il bit basso di HSTART
	bra.s	PlaceCoords

BitBassoZERO:
	bclr	#0,3(a1)	; Azzeriamo il bit basso di HSTART
PlaceCoords:
	lsr.w	#1,D1		; SHIFTIAMO, ossia spostiamo di 1 bit a destra
				; il valore di HSTART, per "trasformarlo" nel
				; valore fa porre nel byte HSTART, senza cioe'
				; il bit basso.
	move.b	D1,1(a1)	; Poniamo il valore XX nel byte HSTART
	rts



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

	dc.w	$1A2,$FFC	; color17, COL 1 per sprite att.
	dc.w	$1A4,$DEA	; color18, COL 2 per sprite att.
	dc.w	$1A6,$AC7	; color19, COL 3 per sprite att.
	dc.w	$1A8,$7B6	; color20, COL 4 per sprite att.
	dc.w	$1AA,$494	; color21, COL 5 per sprite att.
	dc.w	$1AC,$284	; color22, COL 6 per sprite att.
	dc.w	$1AE,$164	; color23, COL 7 per sprite att.
	dc.w	$1B0,$044	; color24, COL 7 per sprite att.
	dc.w	$1B2,$023	; color25, COL 9 per sprite att.
	dc.w	$1B4,$001	; color26, COL 10 per sprite att.
	dc.w	$1B6,$F80	; color27, COL 11 per sprite att.
	dc.w	$1B8,$C40	; color28, COL 12 per sprite att.
	dc.w	$1BA,$820	; color29, COL 13 per sprite att.
	dc.w	$1BC,$500	; color30, COL 14 per sprite att.
	dc.w	$1BE,$200	; color31, COL 15 per sprite att.

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco gli sprite: OVVIAMENTE in CHIP RAM! **********


Fotogramma1:		; lunghezza 15 linee, $44 bytes
	dc.w $0000,$0000
	dc.w $0580,$0040,$07c0,$0430,$0d68,$0d18,$1fac,$1b9c
	dc.w $3428,$3818,$068e,$993c,$d554,$1390,$729e,$b6d8
	dc.w $5556,$9390,$96b0,$e972,$406c,$7c60,$5bc4,$5fc8
	dc.w $0970,$0908,$0bc0,$0030,$0600,$01c0
	dc.w 0,0
Fotogramma1b:		; lunghezza 15 linee
	dc.w $0000,$0080
	dc.w $07c0,$0000,$1bf0,$0380,$32f8,$0380,$607c,$0380
	dc.w $43f8,$0384,$e3fc,$0382,$efec,$7ffe,$cfe4,$7ffe
	dc.w $efec,$7ffe,$fff0,$038e,$7fe0,$039c,$5c40,$23bc
	dc.w $0a80,$37f8,$0380,$1ff0,$0000,$07c0
	dc.w 0,0

Fotogramma2:
	dc.w $0000,$0000
	dc.w $0580,$0040,$05c0,$0430,$0ee8,$0e98,$1dac,$1b9c
	dc.w $34e8,$3ad8,$560e,$993c,$f5e8,$3318,$d252,$1690
	dc.w $3a96,$c7d0,$95b8,$ea32,$41ec,$78e0,$5e44,$5e48
	dc.w $0470,$0408,$0ec0,$0030,$0600,$01c0
	dc.w 0,0
Fotogramma2b:
	dc.w $0000,$0080
	dc.w $07c0,$0000,$1bf0,$0180,$3178,$01c0,$607c,$01c0
	dc.w $4138,$01c4,$e3fc,$7382,$cff8,$7f86,$efe0,$fffe
	dc.w $ffec,$0ffe,$ffc8,$07fe,$7ff8,$071c,$5940,$27bc
	dc.w $0a00,$3ff8,$0e00,$1ff0,$0000,$07c0
	dc.w 0,0

Fotogramma3:
	dc.w $0000,$0000
	dc.w $0580,$0040,$04c0,$0430,$0e68,$0e18,$3dfc,$1bec
	dc.w $25c8,$0bd8,$7b2e,$ba3c,$d068,$1798,$6642,$82b0
	dc.w $32d6,$c690,$9490,$eb12,$49bc,$78b0,$4d6c,$4d60
	dc.w $1870,$0808,$0ec0,$0030,$0600,$01c0
	dc.w 0,0
Fotogramma3b:
	dc.w $0000,$0080
	dc.w $07c0,$0000,$1bf0,$0000,$31f8,$0060,$601c,$20f0
	dc.w $7038,$30e4,$c5dc,$7de2,$eff8,$3fc6,$fff0,$0fce
	dc.w $fff0,$07ee,$ffe8,$07fe,$77c8,$0f7c,$5358,$3ebc
	dc.w $1400,$3ff8,$0c00,$1ff0,$0000,$07c0
	dc.w 0,0

Fotogramma4:
	dc.w $0000,$0000
	dc.w $0580,$0040,$04c0,$0430,$1678,$0608,$357c,$1764
	dc.w $0968,$0968,$122e,$91bc,$c7e8,$0398,$6242,$86b0
	dc.w $3256,$c790,$93b0,$f032,$786c,$5b60,$7354,$4748
	dc.w $1870,$0808,$0ac0,$0030,$0600,$01c0
	dc.w 0,0
Fotogramma4b:
	dc.w $0000,$0080
	dc.w $07c0,$0000,$1bf0,$0000,$39f8,$1830,$689c,$3c78
	dc.w $7698,$3ef4,$efdc,$1fe2,$fff8,$0fc6,$fff0,$07ce
	dc.w $fff0,$0fee,$efc0,$1ffe,$6798,$3cfc,$7f30,$38fc
	dc.w $1820,$37f8,$0000,$1ff0,$0000,$07c0
	dc.w 0,0

Fotogramma5:
	dc.w $0000,$0000
	dc.w $0580,$0040,$04c0,$0030,$0e68,$0218,$172c,$1714
	dc.w $3ca8,$3ca0,$0116,$9810,$cf10,$09d0,$64e2,$8290
	dc.w $30d6,$d7b0,$8a50,$c992,$782c,$5b20,$7be4,$4fe8
	dc.w $0830,$0808,$0ae0,$0010,$0600,$01c0
	dc.w 0,0
Fotogramma5b:
	dc.w $0000,$0080
	dc.w $07c0,$0000,$1ff0,$0400,$3df8,$0c00,$68fc,$0e08
	dc.w $4358,$0f3c,$e7ec,$077e,$f7e8,$07fe,$fff0,$07ee
	dc.w $eff0,$1fce,$f7f0,$3fee,$67c0,$3cfc,$7f10,$30fc
	dc.w $0870,$37f8,$0060,$1ff0,$0000,$07c0
	dc.w 0,0

Fotogramma6:
	dc.w $0000,$0000
	dc.w $0580,$0040,$07c0,$0430,$0e68,$0a18,$1b2c,$1b1c
	dc.w $3428,$3c18,$0696,$9910,$cf5c,$0d98,$7492,$92d0
	dc.w $50b6,$97d0,$ab70,$c8b2,$602c,$5e20,$5bc4,$5fc8
	dc.w $0850,$0848,$0ae0,$0010,$0600,$01c0
	dc.w 0,0
Fotogramma6b:
	dc.w $0000,$0080
	dc.w $07c0,$0000,$1bf0,$0300,$35f8,$0700,$64fc,$0700
	dc.w $43f8,$0784,$e3ec,$03be,$f3e4,$03fe,$efee,$1ffe
	dc.w $eff0,$7fee,$f7f0,$3fce,$7fe0,$21dc,$5e00,$21fc
	dc.w $08a0,$37f8,$00e0,$1ff0,$0000,$07c0
	dc.w 0,0


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo esempio mostriamo come realizzare uno sprite animato, seguendo la
tecnica spiegata nella lezione.
La figura che animiamo e` formata da una coppia di sprite "attached".
In pratica quindi sono 2 gli sprite che animiamo.
Per ciascun sprite abbiamo 6 fotogrammi. Consideriamo per ora solo il primo
sprite. Ogni fotogramma e` memorizzato in una struttura sprite.
Ogni volta che lo sprite viene ridisegnato, la routine "animazione" provvede
ad utilizzare un diverso fotogramma, ovvero una diversa struttura sprite.
La routine infatti gestisce una tabella con gli indirizzi delle varie
strutture sprite, e ogni volta che viene eseguita sposta gli indirizzi
all'interno della tabella in maniera che tutti, a rotazione vengano a trovarsi
all'inizio della tabella.
In pratica non c'e' nulla di nuovo, perche' siamo di fronte ad una tabella
di indirizzi, anziche' una tabella di valori. Inoltre i 6 indirizzi vengono
"ruotati" all'interno della tabella stessa, cioe' ogni fotogramma il primo
indirizzo viene messo al posto dell'ultimo, il secondo al posto del primo, il
terzo al posto del secondo e cosi' via, in modo analogo alla rotazione che
abbiamo gia' visto per i colori in copperlist nella Lezione3e.s.
L'indirizzo che si trova in testa alla tabella viene caricato nel puntatore
dello sprite e usato come fotogramma per lo sprite.
Per evitare di ripetere questo lavoro anche per il secondo sprite (quello
dispari da attaccare al primo), ogni fotogramma di ogni "secondo sprite" e`
sistemato in memoria subito dopo il corrispondente fotogramma del primo sprite,
in modo tale che dall'indirizzo del fotogramma del primo sprite (pari) si puo`
risalire all'indirizzo del corrispondente secondo sprite (dispari) da attaccare
al primo semplicemente con un:

	lea     $44(a0),a1

Che aggiunge all'indirizzo del fotogramma del primo sprite la lunghezza del
fotogramma stesso, ottenendo l'indirizzo del secondo fotogramma (dispari).

