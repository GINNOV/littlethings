
; Lezione7h.s	4 SPRITE A 16 COLORI IN MODO ATTACCHED MOSSI SULLO SCHERMO
; 		USANDO DUE TABELLE DI VALORI (ossia di coordinate verticali
;		e orizzontali) PRESTABILITI.
;		** NOTA ** Per vedere il programma ed uscire premere:
;		TASTO SINISTRO, TASTO DESTRO, TASTO SINISTRO, TASTO DESTRO.

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

;	Puntiamo gli 8 sprite, che ATTACCATI formeranno 4 sprite a 16 colori.
;	Gli sprite 1,3,5,7, quelli dispari, devono avere il bit 7 della
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

; Settiamo i bit dell'ATTACCHED

	bset	#7,MIOSPRITE1+3		; Setta il bit dell'attacched allo
					; sprite 1. Togliendo questa istruzione
					; gli sprite non sono ATTACCHED, ma
					; due a 3 colori sovrapposti.

	bset	#7,MIOSPRITE3+3
	bset	#7,MIOSPRITE5+3
	bset	#7,MIOSPRITE7+3

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

;	Creiamo una differenza di posizione nei puntatori alle tabelle tra i
;	4 sprite per fargli fare movimenti diversi l'uno dall'altro.

	MOVE.L	#TABX+55,TABXPOINT0
	MOVE.L	#TABX+86,TABXPOINT1
	MOVE.L	#TABX+130,TABXPOINT2
	MOVE.L	#TABX+170,TABXPOINT3
	MOVE.L	#TABY-1,TABYPOINT0
	MOVE.L	#TABY+45,TABYPOINT1
	MOVE.L	#TABY+90,TABYPOINT2
	MOVE.L	#TABY+140,TABYPOINT3


Mouse1:
	bsr.w	MuoviGliSprite	; Attende un fotogramma, muove gli sprite e
				; ritorna.

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse1

	MOVE.L	#TABX+170,TABXPOINT0
	MOVE.L	#TABX+130,TABXPOINT1
	MOVE.L	#TABX+86,TABXPOINT2
	MOVE.L	#TABX+55,TABXPOINT3
	MOVE.L	#TABY-1,TABYPOINT0
	MOVE.L	#TABY+45,TABYPOINT1
	MOVE.L	#TABY+90,TABYPOINT2
	MOVE.L	#TABY+140,TABYPOINT3

Mouse2:
	bsr.w	MuoviGliSprite	; Attende un fotogramma, muove gli sprite e
				; ritorna.

	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse2

; SPRITE IN FILA INDIANA

	MOVE.L	#TABX+30,TABXPOINT0
	MOVE.L	#TABX+20,TABXPOINT1
	MOVE.L	#TABX+10,TABXPOINT2
	MOVE.L	#TABX-1,TABXPOINT3
	MOVE.L	#TABY+30,TABYPOINT0
	MOVE.L	#TABY+20,TABYPOINT1
	MOVE.L	#TABY+10,TABYPOINT2
	MOVE.L	#TABY-1,TABYPOINT3

Mouse3:
	bsr.w	MuoviGliSprite	; Attende un fotogramma, muove gli sprite e
				; ritorna.

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse3

; SPRITE UBRIACHI PER LO SCHERMO

	MOVE.L	#TABX+220,TABXPOINT0
	MOVE.L	#TABX+30,TABXPOINT1
	MOVE.L	#TABX+102,TABXPOINT2
	MOVE.L	#TABX+5,TABXPOINT3
	MOVE.L	#TABY-1,TABYPOINT0
	MOVE.L	#TABY+180,TABYPOINT1
	MOVE.L	#TABY+20,TABYPOINT2
	MOVE.L	#TABY+100,TABYPOINT3


Mouse4:
	bsr.w	MuoviGliSprite	; Attende un fotogramma, muove gli sprite e
				; ritorna.

	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse4

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


; Questa routine esegue le singole routines di movimento degli sprite
; ed include anche il loop di attesa del fotogramma per la temporizzazione.

MuoviGliSprite:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	MuoviGliSprite

	bsr.s	MuoviSpriteX0	; Muovi lo sprite 0 orizzontalmente
	bsr.w	MuoviSpriteX1	; Muovi lo sprite 1 orizzontalmente
	bsr.w	MuoviSpriteX2	; Muovi lo sprite 2 orizzontalmente
	bsr.w	MuoviSpriteX3	; Muovi lo sprite 3 orizzontalmente
	bsr.w	MuoviSpriteY0	; Muovi lo sprite 0 verticalmente
	bsr.w	MuoviSpriteY1	; Muovi lo sprite 1 verticalmente
	bsr.w	MuoviSpriteY2	; Muovi lo sprite 2 verticalmente
	bsr.w	MuoviSpriteY3	; Muovi lo sprite 3 verticalmente

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	rts		; Torna al loop MOUSE


; ********************* ROUTINES DI MOVIMENTO ORIZZONTALE *******************

; Queste routines spostano lo sprite agendo sul suo byte HSTART, ossia
; il byte della sua posizione X, immettendoci delle coordinate gia' stabilite
; nella tabella TABX (Scorrimento orizzontale a scatti di 2 pixel e non 1)

; Per lo sprite0 ATTACCHED: (ossia Sprite0+Sprite1)

MuoviSpriteX0:
	ADDQ.L	#1,TABXPOINT0	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT0(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTX0	; non ancora? allora continua
	MOVE.L	#TABX-1,TABXPOINT0 ; Riparti a puntare dal primo byte-1
NOBSTARTX0:
	MOVE.b	(A0),MIOSPRITE0+1 ; copia il byte dalla tabella ad HSTART0
	MOVE.b	(A0),MIOSPRITE1+1 ; copia il byte dalla tabella ad HSTART1
	rts

TABXPOINT0:
	dc.l	TABX+55		; NOTA: i valori della tabella sono bytes



; Per lo sprite1 ATTACCHED: (ossia Sprite2+Sprite3)

MuoviSpriteX1:
	ADDQ.L	#1,TABXPOINT1	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT1(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTX1	; non ancora? allora continua
	MOVE.L	#TABX-1,TABXPOINT1 ; Riparti a puntare dal primo byte-1
NOBSTARTX1:
	MOVE.b	(A0),MIOSPRITE2+1 ; copia il byte dalla tabella ad HSTART2
	MOVE.b	(A0),MIOSPRITE3+1 ; copia il byte dalla tabella ad HSTART3
	rts

TABXPOINT1:
	dc.l	TABX+86		; NOTA: i valori della tabella sono bytes



; Per lo sprite2 ATTACCHED: (ossia Sprite4+Sprite5)

MuoviSpriteX2:
	ADDQ.L	#1,TABXPOINT2	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT2(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTX2	; non ancora? allora continua
	MOVE.L	#TABX-1,TABXPOINT2 ; Riparti a puntare dal primo byte-1
NOBSTARTX2:
	MOVE.b	(A0),MIOSPRITE4+1 ; copia il byte dalla tabella ad HSTART4
	MOVE.b	(A0),MIOSPRITE5+1 ; copia il byte dalla tabella ad HSTART5
	rts

TABXPOINT2:
	dc.l	TABX+130	; NOTA: i valori della tabella sono bytes



; Per lo sprite3 ATTACCHED: (ossia Sprite6+Sprite7)

MuoviSpriteX3:
	ADDQ.L	#1,TABXPOINT3	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT3(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTX3	; non ancora? allora continua
	MOVE.L	#TABX-1,TABXPOINT3 ; Riparti a puntare dal primo byte-1
NOBSTARTX3:
	MOVE.b	(A0),MIOSPRITE6+1 ; copia il byte dalla tabella ad HSTART6
	MOVE.b	(A0),MIOSPRITE7+1 ; copia il byte dalla tabella ad HSTART7
	rts

TABXPOINT3:
	dc.l	TABX+170	; NOTA: i valori della tabella sono bytes

; ********************* ROUTINES DI MOVIMENTO VERTICALE *******************

; Queste routines spostano in alto e in basso lo sprite agendo sui suoi byte
; VSTART e VSTOP, ossia i byte della sua posizione Y di inizio e fine,
; immettendoci delle coordinate gia' stabilite nella tabella TABY

; Per lo sprite0 ATTACCHED: (ossia Sprite0+Sprite1)

MuoviSpriteY0:
	ADDQ.L	#1,TABYPOINT0	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT0(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTY0	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT0 ; Riparti a puntare dal primo byte (-1)
NOBSTARTY0:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte dalla tabella in d0
	MOVE.b	d0,MIOSPRITE0	; copia il byte in VSTART0
	MOVE.b	d0,MIOSPRITE1	; copia il byte in VSTART1
	ADD.B	#15,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,MIOSPRITE0+2	; Muovi il valore giusto in VSTOP0
	move.b	d0,MIOSPRITE1+2	; Muovi il valore giusto in VSTOP1
	rts

TABYPOINT0:
	dc.l	TABY-1		; NOTA: i valori della tabella sono bytes



; Per lo sprite1 ATTACCHED: (ossia Sprite2+Sprite3)

MuoviSpriteY1:
	ADDQ.L	#1,TABYPOINT1	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT1(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTY1	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT1 ; Riparti a puntare dal primo byte (-1)
NOBSTARTY1:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte dalla tabella in d0
	MOVE.b	d0,MIOSPRITE2	; copia il byte in VSTART2
	MOVE.b	d0,MIOSPRITE3	; copia il byte in VSTART3
	ADD.B	#15,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,MIOSPRITE2+2	; Muovi il valore giusto in VSTOP2
	move.b	d0,MIOSPRITE3+2	; Muovi il valore giusto in VSTOP3
	rts

TABYPOINT1:
	dc.l	TABY+45		; NOTA: i valori della tabella sono bytes



; Per lo sprite2 ATTACCHED: (ossia Sprite4+Sprite5)

MuoviSpriteY2:
	ADDQ.L	#1,TABYPOINT2	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT2(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTY2	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT2 ; Riparti a puntare dal primo byte (-1)
NOBSTARTY2:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte dalla tabella in d0
	MOVE.b	d0,MIOSPRITE4	; copia il byte in VSTART4
	MOVE.b	d0,MIOSPRITE5	; copia il byte in VSTART5
	ADD.B	#15,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,MIOSPRITE4+2	; Muovi il valore giusto in VSTOP4
	move.b	d0,MIOSPRITE5+2	; Muovi il valore giusto in VSTOP5
	rts

TABYPOINT2:
	dc.l	TABY+90		; NOTA: i valori della tabella sono bytes



; Per lo sprite3 ATTACCHED: (ossia Sprite5+Sprite6)

MuoviSpriteY3:
	ADDQ.L	#1,TABYPOINT3	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT3(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTY3	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT3 ; Riparti a puntare dal primo byte (-1)
NOBSTARTY3:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte dalla tabella in d0
	MOVE.b	d0,MIOSPRITE6	; copia il byte in VSTART6
	MOVE.b	d0,MIOSPRITE7	; copia il byte in VSTART7
	ADD.B	#15,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,MIOSPRITE6+2	; Muovi il valore giusto in VSTOP6
	move.b	d0,MIOSPRITE7+2	; Muovi il valore giusto in VSTOP7
	rts

TABYPOINT3:
	dc.l	TABY+140	; NOTA: i valori della tabella sono bytes



; Tabella con coordinate X dello sprite precalcolate.

TABX:
	incbin	"XCOORDINAT.TAB"	; 334 valori
FINETABX:


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

MIOSPRITE0:				; lunghezza 15 linee
	incbin	"Sprite16Col.PARI"

MIOSPRITE1:				; lunghezza 15 linee
	incbin	"Sprite16Col.DISPARI"

MIOSPRITE2:				; lunghezza 15 linee
	incbin	"Sprite16Col.PARI"

MIOSPRITE3:				; lunghezza 15 linee
	incbin	"Sprite16Col.DISPARI"

MIOSPRITE4:				; lunghezza 15 linee
	incbin	"Sprite16Col.PARI"

MIOSPRITE5:				; lunghezza 15 linee
	incbin	"Sprite16Col.DISPARI"

MIOSPRITE6:				; lunghezza 15 linee
	incbin	"Sprite16Col.PARI"

MIOSPRITE7:				; lunghezza 15 linee
	incbin	"Sprite16Col.DISPARI"


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo listato vengono visualizzati tutti i 4 sprite ATTACCHED a 16 colori.
Gli sprite sono stati salvati (comprese le word di controllo) in file,
usando il comando "WB". Questo per risparmiare spazio nel listato e per
riutilizzare lo sprite attacched in altri listati e varie volte nello stesso
listato, infatti lo stesso sprite (diviso in SPRITE PARI e DISPARI) e'
utilizzato per tutti i quattro sprite.
Per quanto riguarda il movimento degli sprite, ognuno ha una routine di
movimento autonoma, con un puntatore alle tabelle di X e di Y autonomo.
In questo modo, facendo partire il movimento da fasi diverse (ossia punti
diversi della tabella) in ogni sprite, si generano i movimenti piu' disparati.
Le due tabelle X ed Y pero' sono le stesse per tutte le routine, tra una
routine e l'altra cambia solo la posizione di inizio del puntatore, per cui
mentre uno sprite parte dalla posizione X,Y, un'altro parte dalla posizione
X+n, Y+n, creando sprite piu' avanti e piu' indietro nella curva (NEL CASO
DELLA "FILA INDIANA"), oppure traiettorie apparentemente casuali.
E' degna di nota una particolarita' della struttura delle routine in questo
listato: dovendo aspettare la pressione del tasto sinistro e destro piu' volte
per cambiare il movimento degli sprite prima di uscire, sarebbe stato
necessario riscrivere ogni volta i due loop che aspettano la linea $FF del
pennello elettronico e tutti gli 8 "BSR muovisprite":

; aspetta linea $FF
; bsr muovisprite
; aspetta il mouse sinistro

; cambia la traiettoria degli sprite

; aspetta linea $FF
; bsr muovisprite
; aspetta il mouse destro

; cambia la traiettoria degli sprite

; aspetta linea $FF
; bsr muovisprite
; aspetta il mouse sinistro

; cambia la traiettoria degli sprite

; aspetta linea $FF
; bsr muovisprite
; aspetta il mouse destro

Per risparmiare linee di listato una soluzione e' quella di includere il
loop che aspetta il pennello elettronico per la temporizzazione nella
subroutine BSR muovisprite:

; Questa routine esegue le singole routines di movimento degli sprite
; ed include anche il loop di attesa del fotogramma per la temporizzazione.

MuoviGliSprite:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	MuoviGliSprite

	bsr.s	MuoviSpriteX0	; Muovi lo sprite 0 orizzontalmente
	bsr.w	MuoviSpriteX1	; Muovi lo sprite 1 orizzontalmente
	bsr.w	MuoviSpriteX2	; Muovi lo sprite 2 orizzontalmente
	bsr.w	MuoviSpriteX3	; Muovi lo sprite 3 orizzontalmente
	bsr.w	MuoviSpriteY0	; Muovi lo sprite 0 verticalmente
	bsr.w	MuoviSpriteY1	; Muovi lo sprite 1 verticalmente
	bsr.w	MuoviSpriteY2	; Muovi lo sprite 2 verticalmente
	bsr.w	MuoviSpriteY3	; Muovi lo sprite 3 verticalmente

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	rts		; Torna al loop MOUSE

In questo modo basta aspettare la pressione del tasto del mouse, se non e'
premuto eseguire MuovigliSprite:


Mouse1:
	bsr.w	MuoviGliSprite	; Attende un fotogramma, muove gli sprite e
				; ritorna.

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse1

	MOVE.L	#TABX+170,TABXPOINT0	; cambia la traiettoria degli sprite
	...

Mouse2:
	bsr.w	MuoviGliSprite	; Attende un fotogramma, muove gli sprite e
				; ritorna.

	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse2

