
; Lezione7f.s	VISUALIZZAZIONE DI TUTTI GLI 8 SPRITE DELL'AMIGA
;		In questo listato viene verificato che gli 8 sprite hanno
;		la palette in comune a coppie, ossia lo sprite 0 ha gli stessi
;		colori dello sprite 1, lo sprite 2 ha gli stessi dello sprite 3
;		e cosi' via. Viene verificato anche che nel caso della
;		sovrapposizione di due sprite, quello con numero minore
;		prevale su quello con numero maggiore, per cui lo sprite 0
;		appare sopra tutti gli altri e lo sprite 7 puo' essere coperto
;		da tutti gli altri, mentre lo sprite 3 copre gli sprite 4,5,6,7
;		ed e' coperto dagli sprite 0,1,2
;		Premendo il tasto sinistro gli sprite si sovrappongono e si
;		notano le priorita' di sovrapposizione. Tasto destro del mouse
;		per uscire.

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

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	MOVEQ	#$60,d0		; Coordinata HSTART iniziale
	ADDQ.B	#(10/2),d0	; distanza col prossimo sprite
				; (da notare che il byte HSTART lavora sui
				; pixel a 2 a 2, per cui per spostarsi di 10
				; pixel basta aggiungere 5 ad HSTART!
	MOVE.B	d0,HSTART1
	ADDQ.B	#(10/2),d0	; distanza col prossimo sprite
	MOVE.B	d0,HSTART2
	ADDQ.B	#(10/2),d0	; distanza col prossimo sprite
	MOVE.B	d0,HSTART3
	ADDQ.B	#(10/2),d0	; distanza col prossimo sprite
	MOVE.B	d0,HSTART4
	ADDQ.B	#(10/2),d0	; distanza col prossimo sprite
	MOVE.B	d0,HSTART5
	ADDQ.B	#(10/2),d0	; distanza col prossimo sprite
	MOVE.B	d0,HSTART6
	ADDQ.B	#(10/2),d0	; distanza col prossimo sprite
	MOVE.B	d0,HSTART7

MouseDestro:
	btst	#2,$dff016
	bne.s	MouseDestro

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
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART0:
	dc.b $60	; Pos. orizzontale (da $40 a $d8)
VSTOP0:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite


MIOSPRITE1:		; lunghezza 13 linee
VSTART1:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART1:
	dc.b $60+14	; Pos. orizzontale (da $40 a $d8)
VSTOP1:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000010001111
 dc.w	%0011111111111100,%1100000110000011
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0011111111111100,%1100000010000011
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 2 e 3
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (BIANCO)
 ;BINARIO 01=COLORE 2 (ACQUA)
 ;BINARIO 11=COLORE 3 (ARANCIO)

MIOSPRITE2:		; lunghezza 13 linee
VSTART2:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART2:
	dc.b $60+(14*2)	; Pos. orizzontale (da $40 a $d8)
VSTOP2:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0011111111111100,%1100001000100011
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0111111111111110,%1000000111000001
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE3:		; lunghezza 13 linee
VSTART3:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART3:
	dc.b $60+(14*3)	; Pos. orizzontale (da $40 a $d8)
VSTOP3:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0111111111111110,%1000000111100001
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 4 e 5
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (BLU)
 ;BINARIO 01=COLORE 2 (VIOLA)
 ;BINARIO 11=COLORE 3 (GRIGIO)

MIOSPRITE4:		; lunghezza 13 linee
VSTART4:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART4:
	dc.b $60+(14*4)	; Pos. orizzontale (da $40 a $d8)
VSTOP4:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001001001111
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE5:		; lunghezza 13 linee
VSTART5:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART5:
	dc.b $60+(14*5)	; Pos. orizzontale (da $40 a $d8)
VSTOP5:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 6 e 7
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (VERDE CHIARO)
 ;BINARIO 01=COLORE 2 (MARRONE)
 ;BINARIO 11=COLORE 3 (ROSSO SCURO)

MIOSPRITE6:		; lunghezza 13 linee
VSTART6:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART6:
	dc.b $60+(14*6)	; Pos. orizzontale (da $40 a $d8)
VSTOP6:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000001001000001
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE7:		; lunghezza 13 linee
VSTART7:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART7:
	dc.b $60+(14*7)	; Pos. orizzontale (da $40 a $d8)
VSTOP7:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo listato vengono "puntati" tutti gli 8 sprites, i quali hanno il
numero nel disegno per rendere piu' chiara la loro disposizione.
Come spiegato nella teoria, gli 8 sprite hanno 4 palette distinte di colori,
per cui gli sprite adiacenti condivisono la stessa palette:

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

Da notare che i colori Color16,Color20,Color24 e Color28 non sono usati dagli
sprite, vengono saltati, in quanto corrisponderebbero al color0 dello sprite,
quello TRASPARENTE, che non e', appunto, un colore, ma un "BUCO" che assume
il colore dei bitplane (o sprites) sottostanti.
Ogni sprite ha il suo VSTART,HSTART e VSTOP, vediamo ad esempio lo SPRITE2:

MIOSPRITE2:		; lunghezza 13 linee
VSTART2:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART2:
	dc.b $60+(14*2)	; Pos. orizzontale (da $40 a $d8)
VSTOP2:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00

Ogni sprite all'inizio e' distanziato dagli altri, tramite l'aggiunta di (14*x)
agli HSTART. Dopo la pressione del tasto sinistro del mouse vengono cambiati
tutti gli HSTART meno il primo in modo da sovrapporre gli sprite e mostrare le
priorita' di visualizzazione tra di essi.

