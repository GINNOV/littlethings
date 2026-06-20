
; Lezione7p.s - esempio di applicazione della routine universale:
;       	4 SPRITE A 4 COLORI AFFIANCATI PER FORMARE UNA FIGURA
;		LARGA 64 PIXEL.
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

;	Puntiamo 4 sprite


	MOVE.L	#MIOSPRITE,d0		; indirizzo dello sprite in d0
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

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!


Mouse1:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	Mouse1

	bsr.w	MuoviGliSprite	; muove tutti gli sprite
	
Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse1

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


; Questa routine legge dalla tabella le coordinate dello sprite 0, lo muove
; usando la routine Universale che abbiamo visto in lezione7m, e poi sposta
; anche gli altri sprite. Gli altri sprite avranno la stessa coordinata
; verticale del primo e saranno affiancati distando 16 pixel l'uno dall'altro.
; la posiz. orizzontale dello sprite 1 e` 16 pixel piu` a destra dello sprite 0
; la posiz. orizzontale dello sprite 2 e` 16 pixel piu` a destra dello sprite 1
; la posiz. orizzontale dello sprite 3 e` 16 pixel piu` a destra dello sprite 2

MuoviGliSprite:
	ADDQ.L	#1,TABYPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultimo byte della TAB?
	BNE.S	NOBSTARTY	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT ; Riparti a puntare dal primo byte
NOBSTARTY:
	moveq	#0,d4		; Pulisci d4
	MOVE.b	(A0),d4		; copia il byte dalla tabella in d4
				; in modo da farla trovare alla routine
				; universale

	ADDQ.L	#1,TABXPOINT
	MOVE.L	TABXPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0
	BNE.S	NOBSTARTX
	MOVE.L	#TABX-1,TABXPOINT
NOBSTARTX:
	moveq	#0,d3		; azzeriamo d3
	MOVE.b	(A0),d3	; poniamo il valore della tabella in d3

	moveq	#15,d2		; altezza dello sprite: e` la stessa per
                                ; tutti e 4, quindi la mettiamo in d2
				; una volta per tutte!

	lea	MIOSPRITE,A1	; indirizzo sprite 0
	move.w	d4,d0		; mettiamo le coordinate nei registri
	move.w	d3,d1
	bsr.w	UniMuoviSprite	; esegue la routine universale che posiziona
				; lo sprite

	lea	MIOSPRITE1,A1	; indirizzo sprite 1
	add.w	#16,d3		; sprite 1 16 pixel piu` a destra di sprite 0
	move.w	d4,d0		; mettiamo le coordinate nei registri
	move.w	d3,d1
	bsr.w	UniMuoviSprite	; esegue la routine universale che posiziona
				; lo sprite

	lea	MIOSPRITE2,A1	; indirizzo sprite 2
	add.w	#16,d3		; sprite 2 16 pixel piu` a destra di sprite 1
	move.w	d4,d0		; mettiamo le coordinate nei registri
	move.w	d3,d1
	bsr.w	UniMuoviSprite	; esegue la routine universale che posiziona
				; lo sprite

	lea	MIOSPRITE3,A1	; indirizzo sprite 3
	add.w	#16,d3		; sprite 3 16 pixel piu` a destra di sprite 2
	move.w	d4,d0		; mettiamo le coordinate nei registri
	move.w	d3,d1
	bsr.w	UniMuoviSprite	; esegue la routine universale che posiziona
				; lo sprite
	rts


TABYPOINT:
	dc.l	TABY-1		; NOTA: i valori della tabella qua sono bytes,
				; dunque lavoriamo con un ADDQ.L #1,TABYPOINT
				; e non #2 come per quando sono word o con #4
				; come quando sono longword.
TABXPOINT:
	dc.l	TABX-1		; NOTA: i valori della tabella qua sono byte

; Tabella con coordinate Y dello sprite precalcolate.
; Da notare che la posizione Y per far entrare lo sprite nella finestra video
; deve essere compresa tra $0 e $ff, infatti l'offset di $2c viene aggiunto
; dalla routine. Se non si usano schermi overscan, ossia non piu' lunghi di
; 255 linee, si puo' usare una tabella di valori dc.b (da $00 a $FF)

TABY:
	incbin	"ycoordinatok.tab"	; 200 valori .B
FINETABY:


; Tabella con coordinate X dello sprite piu` a sinistra precalcolate.
; Questa tabella contiene valori reali, senza gli offset che sono aggiunti
; automaticamente dalla routine universale.
; Poiche` i 4 sprite insieme formano una figura larga 64 pixel, lo sprite
; piu` a sinistra puo` variare la sua posizione orizzontale tra 0 e 
; 319-64=255. Questo fatto ci consente di usare anche per questa tabella
; dei bytes anziche` delle word
; La tabella e` fatta sempre con
; IS
; beg>0
; end>360
; amount>300
; amp>255/2
; y_offset>255/2
; multiplier>1

TABX:
	DC.B	$80,$83,$86,$88,$8B,$8E,$90,$93,$95,$98,$9B,$9D,$A0,$A2,$A5,$A8
	DC.B	$AA,$AD,$AF,$B1,$B4,$B6,$B9,$BB,$BD,$C0,$C2,$C4,$C6,$C9,$CB,$CD
	DC.B	$CF,$D1,$D3,$D5,$D7,$D9,$DB,$DC,$DE,$E0,$E2,$E3,$E5,$E7,$E8,$EA
	DC.B	$EB,$EC,$EE,$EF,$F0,$F1,$F2,$F4,$F5,$F6,$F6,$F7,$F8,$F9,$FA,$FA
	DC.B	$FB,$FB,$FC,$FC,$FD,$FD,$FD,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FD
	DC.B	$FD,$FD,$FC,$FC,$FB,$FB,$FA,$FA,$F9,$F8,$F7,$F6,$F6,$F5,$F4,$F2
	DC.B	$F1,$F0,$EF,$EE,$EC,$EB,$EA,$E8,$E7,$E5,$E3,$E2,$E0,$DE,$DC,$DB
	DC.B	$D9,$D7,$D5,$D3,$D1,$CF,$CD,$CB,$C9,$C6,$C4,$C2,$C0,$BD,$BB,$B9
	DC.B	$B6,$B4,$B1,$AF,$AD,$AA,$A8,$A5,$A2,$A0,$9D,$9B,$98,$95,$93,$90
	DC.B	$8E,$8B,$88,$86,$83,$80,$7E,$7B,$78,$76,$73,$70,$6E,$6B,$69,$66
	DC.B	$63,$61,$5E,$5C,$59,$56,$54,$51,$4F,$4D,$4A,$48,$45,$43,$41,$3E
	DC.B	$3C,$3A,$38,$35,$33,$31,$2F,$2D,$2B,$29,$27,$25,$23,$22,$20,$1E
	DC.B	$1C,$1B,$19,$17,$16,$14,$13,$12,$10,$0F,$0E,$0D,$0C,$0A,$09,$08
	DC.B	$08,$07,$06,$05,$04,$04,$03,$03,$02,$02,$01,$01,$01,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$01,$01,$01,$02,$02,$03,$03,$04,$04,$05,$06
	DC.B	$07,$08,$08,$09,$0A,$0C,$0D,$0E,$0F,$10,$12,$13,$14,$16,$17,$19
	DC.B	$1B,$1C,$1E,$20,$22,$23,$25,$27,$29,$2B,$2D,$2F,$31,$33,$35,$38
	DC.B	$3A,$3C,$3E,$41,$43,$45,$48,$4A,$4D,$4F,$51,$54,$56,$59,$5C,$5E
	DC.B	$61,$63,$66,$69,$6B,$6E,$70,$73,$76,$78,$7B,$7E
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

;	Palette degli SPRITE

	dc.w	$1A2,$800	; color17
	dc.w	$1A4,$d00	; color18
	dc.w	$1A6,$cc0	; color19

	 ; i colori per gli sprite 2 e 3 sono gli stessi che per sprite 0 e 1
	dc.w	$1AA,$800	; color21
	dc.w	$1AC,$d00	; color22
	dc.w	$1AE,$cc0	; color23

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco gli sprite: OVVIAMENTE in CHIP RAM! **********

MIOSPRITE:				; lunghezza 15 linee
	incbin	"Largesprite0.raw"

MIOSPRITE1:				; lunghezza 15 linee
	incbin	"Largesprite1.raw"

MIOSPRITE2:				; lunghezza 15 linee
	incbin	"Largesprite2.raw"

MIOSPRITE3:				; lunghezza 15 linee
	incbin	"Largesprite3.raw"


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo listato utiliziamo 4 sprite a 4 colori per realizzare una figura
larga 64 pixel. Gli sprite sono allineati orizzontalmente. Pertanto hanno
tutti la stessa posizione verticale, mentre orizzontalmente distano 16 pixel
l'uno dall'altro.
Dalle tabelle leggiamo la posizione del primo sprite, mentre per gli altri
usiamo la stessa coordinata verticale e aggiungiamo ogni volta 16 pixel a
quella orizzontale.
Notate la comodita` di avere una routine universale: per spostare gli sprite
usiamo sempre la stessa routine, solo che ogni volta mettiamo un diverso
indirizzo in a1 e diverse coordinate nei registri d0 e d1. In questo caso
l'altezza e` sempre la stessa, per cui non modifichiamo d2. Se pero` avessimo
bisogno di muovere sprite di diverse altezze, non ci sarebbe problema,
basterebbe cambiare anche d2 e usare sempre la stessa routine universale.
