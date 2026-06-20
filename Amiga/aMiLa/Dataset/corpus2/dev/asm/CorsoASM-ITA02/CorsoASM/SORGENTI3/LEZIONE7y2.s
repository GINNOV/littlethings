
; lezione7y2.s	barre verticali

; 	In questo esempio utiliziamo 2 sprite per fare delle barre verticali.

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
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	MuoviSprite	; Muove gli sprite 0 ed 1 orizzontalmente, ma
				; agendo sui MOVE della COPPERLIST, dato
				; che li visualiziamo tramite i registri
				; diretti.

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

; Questa routine sposta gli sprite agendo sulla copperlist, modificando
; il valore bar1 che viene caricato nel registro SPRxPOS, ossia
; il byte della  posizione X, immettendoci delle coordinate gia' stabilite
; nella tabella TABX

MuoviSprite:
	ADDQ.L	#2,TABXPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT(PC),A0 ; indirizzo contenuto in loong TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-2,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTART	; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT ; Riparti a puntare dalla prima long
NOBSTART:
	MOVE.w	(A0),d1

	add.w	#128,D1		; 128 - per centrare lo sprite.
	btst.l	#0,D1		; bit basso della coordinata X azzerato?
	beq.s	BitBassoZERO
	bset.b	#0,bar1_b	; Settiamo il bit basso della bar
	bra.s	PlaceCoords

BitBassoZERO:
	bclr.b	#0,bar1_b	; Azzeriamo il bit basso della bar
PlaceCoords:
	lsr.w	#1,D1		; SHIFTIAMO, ossia spostiamo di 1 bit a destra

	move.b	D1,bar1		; Poniamo il valore XX nel byte della posizione

	ADDQ.L	#2,TABXPOINT2	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT2(PC),A0 ; indirizzo contenuto in loong TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-2,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTART2	; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT2 ; Riparti a puntare dalla prima long
NOBSTART2:
	MOVE.w	(A0),d1
	add.w	#128,D1		; 128 - per centrare lo sprite.
	btst.l	#0,D1		; bit basso della coordinata X azzerato?
	beq.s	BitBassoZERO2
	bset.b	#0,bar2_b	; Settiamo il bit basso della bar
	bra.s	PlaceCoords2

BitBassoZERO2:
	bclr.b	#0,bar2_b	; Azzeriamo il bit basso della bar
PlaceCoords2:
	lsr.w	#1,D1		; SHIFTIAMO, ossia spostiamo di 1 bit a destra

	move.b	D1,bar2		; Poniamo il valore XX nel byte della posizione
	rts

TABXPOINT:
	dc.l	TABX-2
	
TABXPOINT2:			; il puntatore per il secondo sprite e` diverso
	dc.l	TABX+40-2
	
; Tabella con coordinate X dello sprite precalcolate.

TABX:
	incbin	"XCOORDINATOK.TAB"

FINETABX:

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


	dc.w	$2c07,$fffe	; WAIT - aspetta il bordo superiore

	dc.w	$140		; SPR0POS
	dc.b	0		; posizione verticale (non usata)
bar1:	dc.b    0		; posizione orizzontale
	dc.w	$142		; SPR0CTL
	dc.b	0		; VSTOP (non usato)
bar1_b:	dc.b	0		; quarto byte di controllo: viene usato il
				; bit 0 che e` il bit basso della posizione
				; orizzontale

	dc.w	$146,$0e70	; SPR0DATB
	dc.w	$144,$03c0	; SPR0DATA - attiva lo sprite

	dc.w	$148		; SPR1POS
	dc.b	0
bar2:	dc.b	0		; posizione orizzontale
	dc.w	$14a		; SPR1CTL
	dc.b	0
bar2_b:	dc.b	0
	dc.w	$14e,$3e7c	; SPR1DATB
	dc.w	$14c,$0ff0;db0	; SPR1DATA - attiva lo sprite


	dc.w	$FFFF,$FFFE	; Fine della copperlist



	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end


Notate che siccome le colonne sono alte tutto lo schermo, non e` necessario
scrivere nei registri SPRxCTL per disabilitare gli sprite.

Inserite questo pezzo di copperist appena prima del "dc.w $FFFF,$FFFE" per
dare un tocco di colore al listato. (Amiga+b+c+i)

	dc.w	$5407,$fffe	; WAIT
	dc.w	$1A2,$FaF	; color17	; tono viola
	dc.w	$1A4,$703	; color18
	dc.w	$1A6,$F0a	; color19
	dc.w	$6807,$fffe	; WAIT
	dc.w	$1A2,$aFa	; color17	; tono verde
	dc.w	$1A4,$050	; color18
	dc.w	$1A6,$0a0	; color19
	dc.w	$7c07,$fffe	; WAIT
	dc.w	$1A2,$0FF	; color17	; tono blu
	dc.w	$1A4,$00d	; color18
	dc.w	$1A6,$07F	; color19
	dc.w	$9007,$fffe	; WAIT
	dc.w	$1A2,$eee	; color17	; tono grigio
	dc.w	$1A4,$444	; color18
	dc.w	$1A6,$888	; color19

