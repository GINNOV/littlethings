
; Lezione7l.s	SCORRIMENTO VERTICALE DI UNO SPRITE SOTTO LA LINEA $FF


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
	cmpi.b	#$aa,$dff006	; Linea $aa?
	bne.s	mouse

	btst	#2,$dff016
	beq.s	aspetta
	bsr.w	MuoviSpriteY	; Muovi lo sprite 0 verticalmente (oltre $FF)

Aspetta:
	cmpi.b	#$aa,$dff006	; linea $aa?
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

; Questa routine sposta in alto e in basso lo sprite agendo sui suoi byte
; VSTART e VSTOP, ossia i byte della sua posizione Y di inizio e fine, nonche'
; i bit alti delle coordinate VSTART/VSTOP, permettendo il posizionamento
; dello sprite anche nelle linee sotto $FF. La coordinata iniziale deve essere
; in formato WORD, da 0 a $FF per rimanere nello schermo normale (l'offset di
; $2c viene aggiunto dalla routine) oppure si puo' andare oltre $FF per
; far andare lo sprite fino al limite hardware negli schermi overscan.

MuoviSpriteY:
	ADDQ.L	#2,TABYPOINT	 ; Fai puntare alla word successiva
	MOVE.L	TABYPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-2,A0  ; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTY	; non ancora? allora continua
	MOVE.L	#TABY-2,TABYPOINT ; Riparti a puntare dalla prima word (-2)
NOBSTARTY:
	moveq	#0,d0		; Pulisci d0
	MOVE.w	(A0),d0		; copia la word dalla tabella in d0
	ADD.W	#$2c,d0		; aggiungi l'offset dell'inizio dello schermo
	MOVE.b	d0,VSTART	; copia il byte (bits 0-7) in VSTART
	btst.l	#8,d0		; la posizione e' maggiore di 255? ($FF)
	beq.s	NonVSTARTSET
	bset.b	#2,MIOSPRITE+3	; Setta il bit 8 di VSTART (numero > $FF)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,MIOSPRITE+3	; Azzera il bit 8 di VSTART (numero < $FF)
ToVSTOP:
	ADD.w	#13,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,VSTOP	; Muovi il valore giusto (bits 0-7) in VSTOP
	btst.l	#8,d0		; la posizione e' maggiore di 255? ($FF)
	beq.s	NonVSTOPSET
	bset.b	#1,MIOSPRITE+3	; Setta il bit 8 di VSTOP (numero > $FF)
	bra.w	VstopFIN
NonVSTOPSET:
	bclr.b	#1,MIOSPRITE+3	; Azzera il bit 8 di VSTOP (numero < $FF)
VstopFIN:
	rts

TABYPOINT:
	dc.l	TABY-2		; NOTA: i valori della tabella qua sono bytes,
				; dunque lavoriamo con un ADDQ.L #1,TABYPOINT
				; e non #2 come per quando sono word o con #4
				; come quando sono longword.

; Tabella con coordinate Y dello sprite precalcolate.
; Da notare che la posizione Y per far entrare lo sprite nella finestra video
; deve essere compresa tra $0 e $ff, infatti l'offset di $2c viene aggiunto
; dalla routine. Se non si usano schermi overscan, ossia non piu' lunghi di
; 255 linee, si puo' usare una tabella di valori dc.b (da $00 a $FF)


; Come rifarsi la tabella:

; BEG> 0
; END> 360
; AMOUNT> 200
; AMPLITUDE> $f0/2
; YOFFSET> $f0/2
; SIZE (B/W/L)> b
; MULTIPLIER> 1


TABY:
	DC.W	$7A,$7E,$81,$85,$89,$8D,$90,$94,$98,$9B,$9F,$A2,$A6,$A9,$AD
	DC.W	$B0,$B3,$B7,$BA,$BD,$C0,$C3,$C6,$C9,$CC,$CE,$D1,$D3,$D6,$D8
	DC.W	$DA,$DC,$DE,$E0,$E2,$E4,$E5,$E7,$E8,$EA,$EB,$EC,$ED,$EE,$EE
	DC.W	$EF,$EF,$F0,$F0,$F0,$F0,$F0,$F0,$EF,$EF,$EE,$EE,$ED,$EC,$EB
	DC.W	$EA,$E8,$E7,$E5,$E4,$E2,$E0,$DE,$DC,$DA,$D8,$D6,$D3,$D1,$CE
	DC.W	$CC,$C9,$C6,$C3,$C0,$BD,$BA,$B7,$B3,$B0,$AD,$A9,$A6,$A2,$9F
	DC.W	$9B,$98,$94,$90,$8D,$89,$85,$81,$7E,$7A,$76,$72,$6F,$6B,$67
	DC.W	$63,$60,$5C,$58,$55,$51,$4E,$4A,$47,$43,$40,$3D,$39,$36,$33
	DC.W	$30,$2D,$2A,$27,$24,$22,$1F,$1D,$1A,$18,$16,$14,$12,$10,$0E
	DC.W	$0C,$0B,$09,$08,$06,$05,$04,$03,$02,$02,$01,$01,$00,$00,$00
	DC.W	$00,$00,$00,$01,$01,$02,$02,$03,$04,$05,$06,$08,$09,$0B,$0C
	DC.W	$0E,$10,$12,$14,$16,$18,$1A,$1D,$1F,$22,$24,$27,$2A,$2D,$30
	DC.W	$33,$36,$39,$3D,$40,$43,$47,$4A,$4E,$51,$55,$58,$5C,$60,$63
	DC.W	$67,$6B,$6F,$72,$76
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

Questo esempio e` quasi identico a quello del sorgente LEZIONE7d. In questo
esempio pero` la posizione verticale dello sprite puo` andare oltre la linea
255. Vi ricordo che poiche` la finestra video inizia alle coordinate ($40,$2c)
la linea 255 corrisponde alla 211-esima linea visibile sullo schermo
(infatti 255-$2c=211). Quindi se vogliamo che il nostro sprite possa muoversi
per tutte le 256 linee visibili sullo schermo, e` necessario che la posizione
verticale raggiunga il valore 299=$12b. Questo valore e` troppo grande per
essere contenuto in un byte, sono necessari 9 bit. Per specificare la posizione
Y di inizio dello sprite si usa quindi, oltre agli 8 bit del byte VSTART
(che abbiamo usato finora), un ulteriore bit, precisamente il bit 2 del byte
VHBITS, ovvero il quarto byte di controllo. Lo stesso discorso vale per la
posizione di fine dello sprite, solo che si usa il bit 1 del byte VHBITS.
Nella tabella invece le posizioni verticali sono memorizzate come word.
La routine che legge le coordinate verticali dalla tabella controlla se
i valori letti sono maggiori di 255; se questo accade mette a 1 il bit giusto
del registro VHBITS, altrimenti lo azzera. Da notare che il controllo viene
fatto indipendentemente per la posizione di inizio e per quella di fine;
puo` accadere infatti che uno sprite inizi ad una posizione minore di 255,
pero` finisca ad una posizione maggiore di 255. In questo caso il bit 2 di
VHBITS viene azzerato, mentre il bit 1 di VHBITS viene settato a 1.
