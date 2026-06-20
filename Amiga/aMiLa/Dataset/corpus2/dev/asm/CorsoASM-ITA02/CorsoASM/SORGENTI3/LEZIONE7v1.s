
; Lezione7v1.s	PRIORITA` SPRITE E PLAYFIELD
;		In questo listato vengono mostrate le priorita` tra sprite
;		e playfield. Gli sprites attraversano quattro linee
;		sullo schermo. Ogni volta che attraversano una linea
;		le priorita` vengono cambiate mediante la copperlist.

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo la PIC con il solito metodo

	MOVE.L	#PIC,d0
	LEA	BPLPOINTERS,A1
	MOVEQ	#3-1,D1
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0
	addq.w	#8,a1
	dbra	d1,POINTBP

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
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	MuoviSprites	; Muove in basso gli sprites

Aspetta1:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta1


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

; questa routine muove gli 8 sprites in basso:
; gli sprites vengono spostati una volta si ed una no. Per questo
; si usa la variabile flag. Ogni volta che la routine viene eseguita
; la variabile viene cambiata di stato con l'istruzione not:
; se e` a 0, viene posta a $ffff
; se e` a $ffff, viene posta a 0
; se la variabile passa da 0 a $ffff, gli sprite non vengono mossi
; Tutti gli sprites hanno la stessa altezza

Muovisprites:
	not.w	flag
	bne.w	esci

; muove lo sprite 0

	addq.w	#1,altezza
	cmp.w	#300,altezza
	blo.s	no_bordo	; e` arrivato al bordo inferiore?
	move.w	#$2c,altezza	; se si lo rimette in alto

no_bordo:
	move.w	altezza(PC),d0

	CLR.B	VHBITS0		; azzera i bit 8 delle posizioni verticali
	MOVE.b	d0,VSTART0	; copia i bit da 0 a 7 in VSTART
	BTST.l	#8,D0		; la posizione e` maggiore di 255 ?
	BEQ.S	NOBIGVSTART	; se no vai oltre infatti il bit e` stato gia` 
				; azzerato con la CLR.b VHBITS

	BSET.b	#2,VHBITS0	; altrimenti metti a 1 il bit 8 della posizione
				; verticale di partenza
NOBIGVSTART:
	ADDQ.W	#8,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,VSTOP0	; Muovi i bit da 0 a 7 in VSTOP
	BTST.l	#8,D0		; la posizione e` maggiore di 255 ?
	BEQ.S	NOBIGVSTOP	; se no vai oltre infatti il bit e` stato gia` 
				; azzerato con la CLR.b VHBITS

	BSET.b	#1,VHBITS0	; altrimenti metti a 1 il bit 8 della posizione
				; verticale di fine dello sprite
NOBIGVSTOP:

; copia l'altezza sugli altri sprites

	move.b	vstart0,vstart1	; copia vstart
	move.w	vstop0,vstop1	; copia VSTOP e VHBITS

	move.b	vstart0,vstart2	; copia vstart
	move.w	vstop0,vstop2	; copia VSTOP e VHBITS

	move.b	vstart0,vstart3	; copia vstart
	move.w	vstop0,vstop3	; copia VSTOP e VHBITS

	move.b	vstart0,vstart4	; copia vstart
	move.w	vstop0,vstop4	; copia VSTOP e VHBITS

	move.b	vstart0,vstart5	; copia vstart
	move.w	vstop0,vstop5	; copia VSTOP e VHBITS

	move.b	vstart0,vstart6	; copia vstart
	move.w	vstop0,vstop6	; copia VSTOP e VHBITS

	move.b	vstart0,vstart7	; copia vstart
	move.w	vstop0,vstop7	; copia VSTOP e VHBITS

esci:
	rts

altezza:
	dc.w	$2c
flag:
	dc.w	0


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
	dc.w	$100,%0011001000000000	; bit 12 acceso!! 3 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane
	dc.w $e4,0,$e6,0
	dc.w $e8,0,$ea,0

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$ff0
	dc.w	$184,$800
	dc.w	$186,$0f0
	dc.w	$188,$ff0
	dc.w	$18a,$f00
	dc.w	$18c,$0f0
	dc.w	$18e,$0f0

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

; da qui iniziano le istruzioni che cambiano la priorita`
; potete notare che siccome si opera con un playfield normale (non in modo
; dual playfield) il codice di priorita` e` lo stesso per i bit-planes pari
; e per i dispari: per esempio il valore $0009 che e` il primo valore
; che viene scritto in BPLCON2:
;
;        5432109876543210
; $0009=%0000000000001001       potete vedere che:
;
; nei bit da 0 a 2 viene scritto %001
; nei bit da 3 a 5 viene scritto %001, come avevamo detto.
;
; potete verificare che la stessa cosa vale per tutti gli altri valori che
; vengono scritti in BPLCON2


	dc.w	$104,$0000	; BPLCON2 - all'inizio tutti gli sprite sotto

	dc.w	$7007,$fffe	; WAIT - attendi la fine della fascia
	dc.w	$104,$0009	; BPLCON2 - sprites 0,1 sopra e
				; sprites 2,3,4,5,6,7 sotto

	dc.w	$a007,$fffe	; WAIT - attendi la fine della fascia
	dc.w	$104,$0012	; BPLCON2 - sprites 0,1,2,3 sopra e
				; sprites 4,5,6,7 sotto

	dc.w	$d007,$fffe	; WAIT - attendi la fine della fascia
	dc.w	$104,$001b	; BPLCON2 - sprites 0,1,2,3,4,5 sopra e
				; sprites 6,7 sotto

	dc.w	$ff07,$fffe	; WAIT - attendi la fine della fascia
	dc.w	$104,$0024	; BPLCON2 - tutti gli sprites sopra

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	       543210
; NOTA:	$0  = %000000 - tutti gli sprites sotto
;	$9  = %001001 - sprites 0,1 sopra, 	2,3,4,5,6,7 sotto
;	$12 = %010010 - sprites 0,1,2,3 sopra, 	    4,5,6,7 sotto
;	$1b = %011011 - sprites 0,1,2,3,4,5 sopra, 	6,7 sotto
;	$24 = %100100 - tutti gli sprites sopra

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
VHBITS0
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

	SECTION	PLANEVUOTO,BSS_C	; Il bitplane che usiamo

PIC:
	incbin	"priorita.raw"	; il disegno

	end

In questo listato mostriamo come cambiare le priorita` degli sprites rispetto
ai playfield. Innanzitutto notiamo che gli sprite appaiono sempre al di sopra
del colore zero. Per gli altri colori la priorita e` controllata dal registro
BPLCON2. E` possibile controllare la priorita` individualmente per i piani pari
 e per quelli dispari. Questo fatto e` molto importante quando si usa il modo
dual playfield. Quando, come in questo esempio si usa invece il modo normale
si mettono gli stessi livelli di priorita` sia per i planes pari che per quelli
dispari. Per vedere quali sono i livelli di priorita` consultate la lezione.

Per cabiare il livello di priorita` piu` volte nella stessa schermata, usiamo
il copper che ci permette di cambiare priorita` quando gli sprites si trovano
tra una fascia e l'altra. Ecco i valori per il $dff104 (BPLCON2):

	       543210
 	$0  = %000000 - tutti gli sprites sotto
	$9  = %001001 - sprites 0,1 sopra, 	2,3,4,5,6,7 sotto
	$12 = %010010 - sprites 0,1,2,3 sopra, 	    4,5,6,7 sotto
	$1b = %011011 - sprites 0,1,2,3,4,5 sopra, 	6,7 sotto
	$24 = %100100 - tutti gli sprites sopra

