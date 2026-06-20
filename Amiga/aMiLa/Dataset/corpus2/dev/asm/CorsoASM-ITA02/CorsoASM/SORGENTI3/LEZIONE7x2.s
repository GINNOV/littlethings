
; lezione7x2.s 	- Collsioni Sprite in Dual Playfield mode
; In questo esempio mostriamo le collisioni tra uno sprite e i due playfield.
; Lo sprite si muove dall'alto in basso. Se viene rilevata una collisione,
; viene cambiato il colore di sfondo (rosso o verde a seconda di cosa e'
; in collisione).

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

; Usiamo 2 planes per ogni playfield

;	Puntiamo le PIC

	MOVE.L	#PIC1,d0	; puntiamo il playfield 1
	LEA	BPLPOINTERS1,A1
	MOVEQ	#2-1,D1
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0
	addq.w	#8,a1
	dbra	d1,POINTBP

	MOVE.L	#PIC2,d0	; puntiamo il playfield 2
	LEA	BPLPOINTERS2,A1
	MOVEQ	#2-1,D1
POINTBP2:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0
	addq.w	#8,a1
	dbra	d1,POINTBP2

;	Puntiamo lo sprite

	MOVE.L	#MIOSPRITE0,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

	move.w	#$0024,$dff104	; BPLCON2
				; con questo valore gli sprite sono tutti
				; sopra entrambi i playfield

aspetta1:
	cmp.b	#$ff,$dff006	; Linea 255?
	bne.s	aspetta1
aspetta11:
	cmp.b	#$ff,$dff006	; Ancora Linea 255?
	beq.s	aspetta11

	btst	#6,$bfe001
	beq.s	esci

	bsr.s	MuoviSprite	; Muove in basso lo sprite
	bsr.w	CheckColl	; Controlla collisione e provvede

	bra.s	aspetta1

esci	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
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

; Questa routine muove lo sprite 0 in basso di un pixel ogni 2 fotogrammi
; Viene usato un flag.

Muovisprite:
	not.w	flag
	beq.s	FineMuovisprite

	addq.w	#1,altezza
	cmp.w	#300,altezza	; e` arrivato al bordo inferiore?
	blo.s	no_bordo
	move.w	#$2c,altezza	; se si, rimetti lo sprite in alto
no_bordo:
	move.w	altezza(PC),d0
	CLR.B	VHBITS0		; azzera i bit 8 delle posizioni verticali
	MOVE.b	d0,VSTART0	; copia i bit da 0 a 7 in VSTART
	BTST.l	#8,D0		; la posizione e` maggiore di 255 ?
	BEQ.S	NOBIGVSTART	; se no vai oltre, infatti il bit e` stato gia`
				; azzerato con la CLR.b VHBITS

	BSET.b	#2,VHBITS0	; altrimenti metti a 1 il bit 8 della posizione
				; verticale di partenza
NOBIGVSTART:
	ADDQ.w	#8,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,VSTOP0	; Muovi i bit da 0 a 7 in VSTOP
	BTST.l	#8,D0		; la posizione e` maggiore di 255 ?
	BEQ.S	NOBIGVSTOP	; se no vai oltre infatti il bit e` stato gia`
				; azzerato con la CLR.b VHBITS
	BSET.b	#1,VHBITS0	; altrimenti metti a 1 il bit 8 della posizione
				; verticale di fine dello sprite
NOBIGVSTOP:
FineMuovisprite:
	rts


; Questa routine controlla se c'e` collisione.
; In caso affermativo, cambia il colore dello sfondo modificando nella copper
; list il valore assunto dal registro COLOR00, rosso o verde.

CheckColl:
	move.w	$dff00e,d0	; legge CLXDAT ($dff00e)
				; una lettura di questo registro ne provoca
				; anche la cancellazione, per cui conviene
				; copiarselo in d0 e fare i test su d0
	btst.l	#1,d0		; il bit 1 indica la collisione tra sprite 0
				; e playfield 1
	beq.s	no_coll1		; se non c'e` collisione salta

	move.w	#$f00,rileva_collisione ; "accende" il rivelatore (color0)
					; modificando la copperlist (rosso)
	bra.s	exitColl		; esci

no_coll1:
	btst.l	#5,d0		; il bit 5 indica la collisione tra sprite 0
				; e playfield 2
	beq.s	no_coll2		; se non c'e` collisione salta
	move.w	#$0f0,rileva_collisione ; "accende" il rivelatore (color0)
					; modificando la copperlist (verde)
	bra.s	exitColl		; esci

no_coll2:
	move.w	#$000,rileva_collisione ; "spegne" il rivelatore (color0)
					; modificando la copperlist (nero)
exitColl:
	rts

flag:
	dc.w	0
altezza:
	dc.w	$2c


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
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0100011000000000	; bit 10 acceso = dual playfield
					; uso 4 planes = 4 colori per playfield

BPLPOINTERS1:
	dc.w $e0,0,$e2,0	;primo bitplane playfield 1 (BPLPT1)
	dc.w $e8,0,$ea,0	;secondo bitplane playfield 1 (BPLPT3)


BPLPOINTERS2:
	dc.w $e4,0,$e6,0	;primo bitplane playfield 2 (BPLPT2)
	dc.w $ec,0,$ee,0	;secondo bitplane playfield 2 (BPLPT4)

; Questo e` il registro CLXCON (controlla il modo di rilevamento)

; i bit da 0 a 5 sono i valori che devono essere assunti dai plane
; i bit da 6 a 11 indicano quali planes sono abilitati alle collisioni
; i bit da 12 a 15 indicano quali degli sprite dispari sono abilitati
; al rilevamento delle collisioni.

		    ;5432109876543210
	dc.w	$98,%0000001111001011	; CLXCON

; Questi valori indicano che i planes 1,2,3,4 sono attivi per le collisioni.
; Viene segnalata collisione con il playfield 1 quando lo sprite si sovrappone
; ad un pixel che ha:	plane 1 = 1 (bit 0)
;       		plane 3 = 0 (bit 2)
; cioe` con il colore 1 del playfield 1

; viene segnalata collisione con il playfield 2 quando lo sprite si sovrappone
; ad un pixel che ha:	plane 2 = 1 (bit 1)
;       		plane 4 = 1 (bit 3)
; cioe` con il colore 3 del playfield 2


	dc.w	$180    ; COLOR00
rileva_collisione:
	dc.w	0	; IN QUESTO PUNTO la routine CheckColl modifica
			; la copper list scrivendo il colore giusto.

                        	; palette playfield 1
	dc.w	$182,$005	; colori da 0 a 7
	dc.w	$184,$a40
	dc.w	$186,$f80
	dc.w	$188,$f00
	dc.w	$18a,$0f0
	dc.w	$18c,$00f
	dc.w	$18e,$080


				; palette playfield 2
	dc.w	$192,$367	; colori da 9 a 15
	dc.w	$194,$0cc 	; il colore 8 e` trasparente, non va settato
	dc.w	$196,$a0a 
	dc.w	$198,$242 
	dc.w	$19a,$282
	dc.w	$19c,$861
	dc.w	$19e,$ff0


	dc.w	$1A2,$F00	; palette degli sprites
	dc.w	$1A4,$0F0
	dc.w	$1A6,$FF0

	dc.w	$1AA,$FFF
	dc.w	$1AC,$0BD
	dc.w	$1AE,$D50

	dc.w	$1B2,$00F
	dc.w	$1B4,$F0F
	dc.w	$1B6,$BBB

	dc.w	$1BA,$8E0
	dc.w	$1BC,$a70
	dc.w	$1BE,$d00

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	I due playfields

PIC1:	incbin	"colldual1.raw"
PIC2:	incbin	"colldual2.raw"

; ************ Ecco lo sprite: OVVIAMENTE in CHIP RAM! ************
MIOSPRITE0:
VSTART0:
	dc.b $2c
HSTART0:
	dc.b $80
VSTOP0:
	dc.b $2c+8
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
 dc.w	0,0


	end

Questo esempio mostra come funzionano le collisioni tra sprite e i playfield
di uno schermo (dualplayfield). Si controllano indipendentemente le
collisioni con i 2 playfield usando 2 diversi bit del registro CLXDAT.
Nel nostro esempio (usiamo lo sprite 0), il bit 1 controlla la collisione con
il playfield 1 (piani dispari) e il bit 5 la collisione con il playfield 2
(piani pari).
Per quanto il registro CLXCON, fuunziona tutto come per il caso di schermo
normale:
i bit da 0 a 5 sono i valori che devono essere assunti dai plane
i bit da 6 a 11 indicano quali planes sono abilitati alle collisioni
i bit da 12 a 15 indicano quali degli sprite dispari sono abilitati
al rilevamento delle collisioni.
Rimane sempre possibile non abilitare alcuni planes per rilevare piu` colori
contemporaneamente, come abbiamo illustrato con l'esempio lezione7w2.
Potete provare modificando nella copperlist il valore assegnato a CLXCON.

