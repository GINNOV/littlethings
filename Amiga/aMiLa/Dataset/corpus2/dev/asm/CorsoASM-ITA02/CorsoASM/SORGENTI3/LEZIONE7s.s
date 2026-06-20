
; Lezione7s.s	VISUALIZZAZIONE DI 16 SPRITE

;	In questo listato si mostra come riutilizzare gli sprite.
;	Premendo il tasto sinistro gli sprite cambiano posizione.
;	Tasto destro del mouse per uscire.

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop


	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo gli sprite

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
	MOVE.L	#MIOSPRITE2,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE3,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE4,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE5,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE6,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE7,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

; posizioni sprite
	MOVE.B	#$2C+50,VSTART0
	MOVE.B	#$2C+50+8,VSTOP0
	MOVE.B	#$2C+50,VSTART1
	MOVE.B	#$2C+50+8,VSTOP1
	MOVE.B	#$2C+50,VSTART2
	MOVE.B	#$2C+50+8,VSTOP2
	MOVE.B	#$2C+50,VSTART3
	MOVE.B	#$2C+50+8,VSTOP3
	MOVE.B	#$2C+50,VSTART4
	MOVE.B	#$2C+50+8,VSTOP4
	MOVE.B	#$2C+50,VSTART5
	MOVE.B	#$2C+50+8,VSTOP5
	MOVE.B	#$2C+50,VSTART6
	MOVE.B	#$2C+50+8,VSTOP6
	MOVE.B	#$2C+50,VSTART7
	MOVE.B	#$2C+50+8,VSTOP7

; da qui iniziano gli sprite "riusati"
	MOVE.B	#$2C+90,VSTART8
	MOVE.B	#$2C+90+8,VSTOP8
	MOVE.B	#$2C+90,VSTART9
	MOVE.B	#$2C+90+8,VSTOP9
	MOVE.B	#$2C+90,VSTART10
	MOVE.B	#$2C+90+8,VSTOP10
	MOVE.B	#$2C+90,VSTART11
	MOVE.B	#$2C+90+8,VSTOP11
	MOVE.B	#$2C+90,VSTART12
	MOVE.B	#$2C+90+8,VSTOP12
	MOVE.B	#$2C+90,VSTART13
	MOVE.B	#$2C+90+8,VSTOP13
	MOVE.B	#$2C+90,VSTART14
	MOVE.B	#$2C+90+8,VSTOP14
	MOVE.B	#$2C+90,VSTART15
	MOVE.B	#$2C+90+8,VSTOP15


	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

Mouse1:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse1

; mette nuove posizioni verticali

	MOVE.B	#$2C+10,VSTART0
	MOVE.B	#$2C+10+8,VSTOP0
	MOVE.B	#$2C+10+8*1,VSTART1
	MOVE.B	#$2C+10+8*1+8,VSTOP1
	MOVE.B	#$2C+10+8*2,VSTART2
	MOVE.B	#$2C+10+8*2+8,VSTOP2
	MOVE.B	#$2C+10+8*3,VSTART3
	MOVE.B	#$2C+10+8*3+8,VSTOP3
	MOVE.B	#$2C+10+8*4,VSTART4
	MOVE.B	#$2C+10+8*4+8,VSTOP4
	MOVE.B	#$2C+10+8*5,VSTART5
	MOVE.B	#$2C+10+8*5+8,VSTOP5
	MOVE.B	#$2C+10+8*6,VSTART6
	MOVE.B	#$2C+10+8*6+8,VSTOP6
	MOVE.B	#$2C+10+8*7,VSTART7
	MOVE.B	#$2C+10+8*7+8,VSTOP7

; da qui iniziano gli sprite "riusati"

	MOVE.B	#$2C+10+20,VSTART8
	MOVE.B	#$2C+10+20+8,VSTOP8
	MOVE.B	#$2C+10+20+8*1,VSTART9
	MOVE.B	#$2C+10+20+8*1+8,VSTOP9
	MOVE.B	#$2C+10+20+8*2,VSTART10
	MOVE.B	#$2C+10+20+8*2+8,VSTOP10
	MOVE.B	#$2C+10+20+8*3,VSTART11
	MOVE.B	#$2C+10+20+8*3+8,VSTOP11
	MOVE.B	#$2C+10+20+8*4,VSTART12
	MOVE.B	#$2C+10+20+8*4+8,VSTOP12
	MOVE.B	#$2C+10+20+8*5,VSTART13
	MOVE.B	#$2C+10+20+8*5+8,VSTOP13
	MOVE.B	#$2C+10+20+8*6,VSTART14
	MOVE.B	#$2C+10+20+8*6+8,VSTOP14
	MOVE.B	#$2C+10+20+8*7,VSTART15
	MOVE.B	#$2C+10+20+8*7+8,VSTOP15

Mouse2:
	btst	#2,$dff016
	bne.s	Mouse2


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
	dc.w	$100,%0001001000000000

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$1A2,$F00	; color17, - COLOR1 degli sprite0/1 -ROSSO
	dc.w	$1A4,$0F0	; color18, - COLOR2 degli sprite0/1 -VERDE
	dc.w	$1A6,$FF0	; color19, - COLOR3 degli sprite0/1 -GIALLO

	dc.w	$1AA,$FFF	; color21, - COLOR1 degli sprite2/3 -BIANCO
	dc.w	$1AC,$0BD	; color22, - COLOR2 degli sprite2/3 -ACQUA
	dc.w	$1AE,$D50	; color23, - COLOR3 degli sprite2/3 -ARANCIO

	dc.w	$1B2,$00F	; color25, - COLOR1 degli sprite4/5 -BLU
	dc.w	$1B4,$F0F	; color26, - COLOR2 degli sprite4/5 -VIOLA
	dc.w	$1B6,$BBB	; color27, - COLOR3 degli sprite4/5 -GRIGIO

	dc.w	$1BA,$8E0	; color29, - COLOR1 degli sprite6/7 -VERDE CH.
	dc.w	$1BC,$a70	; color30, - COLOR2 degli sprite6/7 -MARRONE
	dc.w	$1BE,$d00	; color31, - COLOR3 degli sprite6/7 -ROSSO SC.

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco gli sprite: OVVIAMENTE in CHIP RAM! ************

 ; tabella di riferimento per definire i colori:


 ; per gli sprite 0 ed 1
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (ROSSO)
 ;BINARIO 01=COLORE 2 (VERDE)
 ;BINARIO 11=COLORE 3 (GIALLO)

MIOSPRITE0:		; lunghezza 13 linee
VSTART0:
	dc.b 0
HSTART0:
	dc.b $40+12+0*20
VSTOP0:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0000001111000000,%0111110000111110
VSTART8:
	dc.b $0
HSTART8:
	dc.b $40+20+0*12
VSTOP8:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0111111111111110,%1000001110000001
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite


MIOSPRITE1:		; lunghezza 13 linee
VSTART1:
	dc.b $0
HSTART1:
	dc.b $40+12+1*20
VSTOP1:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000010001111
 dc.w	%0011111111111100,%1100000110000011
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0011111111111100,%1100000010000011
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0000001111000000,%0111110000111110
VSTART9:
	dc.b $0
HSTART9:
	dc.b $40+20+1*12
VSTOP9:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0111111111111110,%1000001110000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 2 e 3
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (BIANCO)
 ;BINARIO 01=COLORE 2 (ACQUA)
 ;BINARIO 11=COLORE 3 (ARANCIO)

MIOSPRITE2:		; lunghezza 13 linee
VSTART2:
	dc.b $0
HSTART2:
	dc.b $40+12+2*20
VSTOP2:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0011111111111100,%1100001000100011
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0111111111111110,%1000000111000001
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
VSTART10:
	dc.b $0
HSTART10:
	dc.b $40+20+2*12
VSTOP10:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0011111111111100,%1100010011100011
 dc.w	%0111111111111110,%1000110010100001
 dc.w	%0111111111111110,%1000010010100001
 dc.w	%0011111111111100,%1100111011100011
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE3:		; lunghezza 13 linee
VSTART3:
	dc.b $0
HSTART3:
	dc.b $40+12+3*20
VSTOP3:
	dc.b 0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0111111111111110,%1000000111100001
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
VSTART11:
	dc.b $0
HSTART11:
	dc.b $40+20+3*12
VSTOP11:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0111111111111110,%1000110011000001
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0011111111111100,%1100111011100011
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 4 e 5
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (BLU)
 ;BINARIO 01=COLORE 2 (VIOLA)
 ;BINARIO 11=COLORE 3 (GRIGIO)

MIOSPRITE4:		; lunghezza 13 linee
VSTART4:
	dc.b $0
HSTART4:
	dc.b $40+12+4*20
VSTOP4:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001001001111
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
VSTART12:
	dc.b $0
HSTART12:
	dc.b $40+20+4*12
VSTOP12:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0011111111111100,%1100010011000011
 dc.w	%0111111111111110,%1000110001000001
 dc.w	%0111111111111110,%1000010010000001
 dc.w	%0011111111111100,%1100111011100011
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE5:		; lunghezza 13 linee
VSTART5:
	dc.b $0
HSTART5:
	dc.b $40+12+5*20
VSTOP5:
	dc.b $0
	dc.b $0
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
VSTART13:
	dc.b $0
HSTART13:
	dc.b $40+20+5*12
VSTOP13:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0011111111111100,%1100010011100011
 dc.w	%0111111111111110,%1000110001100001
 dc.w	%0111111111111110,%1000010000100001
 dc.w	%0011111111111100,%1100111011000011
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 6 e 7
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (VERDE CHIARO)
 ;BINARIO 01=COLORE 2 (MARRONE)
 ;BINARIO 11=COLORE 3 (ROSSO SCURO)

MIOSPRITE6:		; lunghezza 13 linee
VSTART6:
	dc.b $0
HSTART6:
	dc.b $40+12+6*20
VSTOP6:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000001001000001
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
VSTART14:
	dc.b $0
HSTART14:
	dc.b $40+20+6*12
VSTOP14:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0011111111111100,%1100010000100011
 dc.w	%0111111111111110,%1000110010100001
 dc.w	%0111111111111110,%1000010011100001
 dc.w	%0011111111111100,%1100111001000011
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE7:		; lunghezza 13 linee
VSTART7:
	dc.b 0
HSTART7:
	dc.b $40+12+7*20
VSTOP7:
	dc.b $0
	dc.b $0
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
VSTART15:
	dc.b $0
HSTART15:
	dc.b $40+20+7*12
VSTOP15:
	dc.b $0
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0011111111111100,%1100010011100011
 dc.w	%0111111111111110,%1000110011000001
 dc.w	%0111111111111110,%1000010000100001
 dc.w	%0011111111111100,%1100111011100011
 dc.w	%0000111111110000,%1111000000001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

	SECTION	PLANEVUOTO,BSS_C
BITPLANE:
	ds.b	40*256

	end

In questo listato viene mostrato come riutilizzare gli sprite piu` volte sulla
stessa schermata. Nell'esempio, ogni sprite viene utilizzato due volte.
Lo sprite 0 viene riutilizzato per disegnare lo sprite 8.
Lo sprite 1 viene riutilizzato per disegnare lo sprite 9.
Lo sprite 2 viene riutilizzato per disegnare lo sprite 10.
Lo sprite 3 viene riutilizzato per disegnare lo sprite 11.
Lo sprite 4 viene riutilizzato per disegnare lo sprite 12.
Lo sprite 5 viene riutilizzato per disegnare lo sprite 13.
Lo sprite 6 viene riutilizzato per disegnare lo sprite 14.
Lo sprite 7 viene riutilizzato per disegnare lo sprite 15.

Notate che quando uno sprite viene utilizzato la seconda volta, esso viene
posizionato sullo schermo PIU` IN BASSO dell'ultima riga dello sprite
visualizzato durante il primo utilizzo. Questo e` dovuto ad una precisa limita-
zione dell'hardware. Infatti tra un utilizzo e il successivo di uno sprite e`
necessario lasciare ALMENO una riga vuota.

Il byte VSTART dello sprite 8 deve essere MAGGIORE di VSTOP dello sprite 0
Il byte VSTART dello sprite 9 deve essere MAGGIORE di VSTOP dello sprite 1
Il byte VSTART dello sprite 10 deve essere MAGGIORE di VSTOP dello sprite 2
Il byte VSTART dello sprite 11 deve essere MAGGIORE di VSTOP dello sprite 3
Il byte VSTART dello sprite 12 deve essere MAGGIORE di VSTOP dello sprite 4
Il byte VSTART dello sprite 13 deve essere MAGGIORE di VSTOP dello sprite 5
Il byte VSTART dello sprite 14 deve essere MAGGIORE di VSTOP dello sprite 6
Il byte VSTART dello sprite 15 deve essere MAGGIORE di VSTOP dello sprite 7

Riutilizzare uno sprite non cambiano i registri colore che ad esso sono
assegnati.
Nell'esempio potete notare infatti che uno sprite "riusato" ha gli stessi
colori di quelli "originali". Poiche` pero` gli sprite sono posizionati
sullo schermo a diverse altezze, nulla ci impedisce di cambiare i valori dei
registri colore tra un utilizzo e l'altro usando il copper. Potete farlo
per esercizio.
