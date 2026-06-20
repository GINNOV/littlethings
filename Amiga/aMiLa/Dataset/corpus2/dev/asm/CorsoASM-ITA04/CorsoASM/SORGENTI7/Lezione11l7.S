
; Lezione11l7.s		8 sprites attacched (quindi 4 a 16 colori) usati,
;			anzi "riutilizzati" 128 volte per linea.

	SECTION	MegaRiuso,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110100000	; copper,bitplane,sprites
;		 -----a-bcdefghij

Waitdisk	EQU	30

NumeroLinee	=	128
LungSpr		=	NumeroLinee*8

START:

; Punta gli sprites

	MOVE.L	#SpritesBuffer,d0
	LEA	SPRITEPOINTERS,A1
	MOVEQ	#8-1,D1			;num of sprites = 8
POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#LungSpr,d0		;lenght of sprite
	addq.w	#8,a1
	dbra	d1,POINTB		;Rifai D1 volte

; Puntiamo il biplane azzerato

	MOVE.L	#PLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	bsr.s	CreaSprites	; routine che crea i 4 sprite attacched,
				; ossia tutti e 8 gli sprite, fatti da
				; 128 riutilizzi di 1 linea ognuno!

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPER,$80(a5)		; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $010
	BNE.S	Waity1

	btst	#2,$16(A5)	; Tasto destro premuto?
	beq.s	NonOndegg

	bsr.w	OndeggiaSpriteS	; ondeggia gli 8 sprites riutilizzati

NonOndegg:
	btst	#6,$bfe001	; tasti sin. mouse premuto?
	bne.s	mouse
	rts

; ****************************************************************************
; Routine che crea gli 8 sprites, (ossia 4 attacched) nello "SpritesBuffer".
; Da notare che gli sprite attacched sono a sua volta affiancati a 2 a 2,
; in modo da ottenere 2 barre larghe 16*2=32 pixel, a 16 colori.
; Innanzitutto occorre ricordare che ogni sprite si puo' "riutilizzare",
; ossia "sotto" ad uno sprite, dopo la fine dello sprite, si puo'
; mettere un'altro sprite, a patto pero' che la sua posizione verticale
; di inizio lasci 1 linea "vuota". Qua usiamo questo fatto in modo massiccio,
; infatti ogni riuso dello sprite e' di 1 linea, per cui otteniamo una
; striscia verticale (larga 16 pixel) fatta di tanti "spritini" alti una linea
; distanziati da una linea "vuota". Per riempire le 256 linee verticali dello
; schermo, facciamo ben 128 utilizzi per ogni sprite! Ma almeno possiamo
; "curvare" quella linea di quanto vogliamo, dato che ogni striscia ha un
; proprio HSTART (posizione orizzontale) indipendente.
;
; Ricordiamo la struttura di uno sprite:
;
;VSTART:
;	dc.b xx		; Pos. verticale (da $2c a $f2)
;HSTART:
;	dc.b xx+(xx)	; Pos. orizzontale (da $40 a $d8)
;VSTOP:
;	dc.b xx		; fine verticale.
;	dc.b $00	; byte speciale: bit 7 per ATTACCHED!!
;	dc.l	XXXXX	; bitplane dello sprite (disegno!) qua 1 linea
;	dc.w	0,0	; 2 word azzerate di FINE SPRITE, che qua mettiamo
;			; mai... quindi qua ci saranno gia' i VSTART e il
;			; VSTOP del prossimo sprite!
;
; 4 bytes -> words di controllo + 4 bytes -> figura (1 striscia)
; 4*2= 8 -> lunghezza di uno sprite; 8*128 = 1024, lunghezza 1 sprite.
; facciamo 128 riutilizzi di ogni sprite: 2 linee per sprite = 256 linee!
;
; ****************************************************************************

; 1024 bytes (8*128) a sprite

CreaSprites:
	lea	SpritesBuffer,A0 ; destinazione
	move.l	#%10000000,D5	; bit 7 settato - per attacched in sprite+3
	moveq	#$2c,D0		; VSTART - iniziamo da $2c
CreaLoop:
	move.b	d0,(A0)		; metti il vstart agli 8 sprite
	move.b	d0,LungSpr(A0)	; 2 (ogni sprite e' lungo 2400 bytes)
	move.b	d0,LungSpr*2(A0)	; 3
	move.b	d0,LungSpr*3(A0)	; 4
	move.b	d0,LungSpr*4(A0)	; 5
	move.b	d0,LungSpr*5(A0)	; 6
	move.b	d0,LungSpr*6(A0)	; 7
	move.b	d0,LungSpr*7(A0)	; 8

	move.l	d0,D1
	addq.w	#1,D1		; VSTART 1 linea sotto -> usiamolo come VSTOP

	move.b	d1,2(A0)		; metti il vstop agli 8 sprite
	move.b	d1,LungSpr+2(A0)	; 2 (ogni sprite e' lungo 2400 bytes)
	move.b	d1,(LungSpr*2)+2(A0)	; 3
	move.b	d1,(LungSpr*3)+2(A0)	; 4
	move.b	d1,(LungSpr*4)+2(A0)	; 5
	move.b	d1,(LungSpr*5)+2(A0)	; 6
	move.b	d1,(LungSpr*6)+2(A0)	; 7
	move.b	d1,(LungSpr*7)+2(A0)	; 8

; Settiamo i bit attacched agli 8 sprite

	move.b	d5,3(A0)		; metti il byte spec. agli 8 sprite
	move.b	d5,LungSpr+3(A0)	; 2 (ogni sprite e' lungo 2400 bytes)
	move.b	d5,(LungSpr*2)+3(A0)	; 3
	move.b	d5,(LungSpr*3)+3(A0)	; 4
	move.b	d5,(LungSpr*4)+3(A0)	; 5
	move.b	d5,(LungSpr*5)+3(A0)	; 6
	move.b	d5,(LungSpr*6)+3(A0)	; 7
	move.b	d5,(LungSpr*7)+3(A0)	; 8

	addq.w	#4,A0			; saltiamo le 2 word di controllo
					; e andiamo nei plane degli sprite!

	move.l	#$55553333,(A0)		; 1 \ metti la linea sfumata
	move.l	#$0f0f00ff,LungSpr(A0)	; 2 / attacched 1!

	move.l	#$aaaacccc,LungSpr*2(A0)	; 3 \ attacched 2!
	move.l	#$f0f0ff00,LungSpr*3(A0)	; 4 /

	move.l	#$55553333,LungSpr*4(A0)	; 5 \ attacched 3!
	move.l	#$0f0f00ff,LungSpr*5(A0)	; 6 /

	move.l	#$aaaacccc,LungSpr*6(A0)	; 7 \ attacched 4!
	move.l	#$f0f0ff00,LungSpr*7(A0)	; 8 /

	addq.w	#4,A0			; saltiamo le 2 word dei plane,
					; per andare alle prossime
					; 2 word di controllo, dato che
					; non ci sono le 2 word azzerate
					; di fine sprite.

	cmp.b	#%10000110,D5	; siamo sotto la linea $FF?
	beq.s	SiamoSottoFF
	addq.b	#2,D0		; vstart 2 linee sotto per il prossimo
				; riutilizzo dello sprite. Dato che ogni
				; sprite e' alto 1 linea, e che tra un
				; utilizzo ed un altro occorre lasciare
				; una linea vuota, addiamo 2.
	bne.w	CreaLoop	; siamo giunti a $fe+2 = $00?
				; Se si, occorre settare il bit alto di
				; vstart e vstop. Altrimenti continua

	move.b	#%10000110,D5	; %10000110 -> settati i 2 bit alti di vstart
				; e vstop per andare sotto la linea $FF
	subq.b	#2,D0		; ritorniamo "indietro" di 1 passo...

SiamoSottoFF:
	addq.b	#2,D0		; vstart 2 linee sotto...
	cmpi.b	#$2c,D0		; siamo alla posizione $FF+$2c?
	bne.w	CreaLoop	; se non ancora, continua!
	rts

; ****************************************************************************

; Parametri per "IS"

; BEG> 0
; END> 360
; AMOUNT> 250
; AMPLITUDE> $20
; YOFFSET> $20
; SIZE (B/W/L)> b
; MULTIPLIER> 1

SinTabHstarts:
 dc.B	$20,$21,$22,$23,$24,$24,$25,$26,$27,$28,$28,$29,$2A,$2B,$2B,$2C
 dc.B	$2D,$2E,$2E,$2F,$30,$30,$31,$32,$32,$33,$34,$34,$35,$36,$36,$37
 dc.B	$37,$38,$38,$39,$39,$3A,$3A,$3B,$3B,$3C,$3C,$3C,$3D,$3D,$3D,$3E
 dc.B	$3E,$3E,$3F,$3F,$3F,$3F,$3F,$40,$40,$40,$40,$40,$40,$40,$40,$40
 dc.B	$40,$40,$40,$40,$40,$40,$3F,$3F,$3F,$3F,$3F,$3E,$3E,$3E,$3D,$3D
 dc.B	$3D,$3C,$3C,$3C,$3B,$3B,$3A,$3A,$39,$39,$38,$38,$37,$37,$36,$36
 dc.B	$35,$34,$34,$33,$32,$32,$31,$30,$30,$2F,$2E,$2E,$2D,$2C,$2B,$2B
 dc.B	$2A,$29,$28,$28,$27,$26,$25,$24,$24,$23,$22,$21,$20,$20,$1F,$1E
 dc.B	$1D,$1C,$1C,$1B,$1A,$19,$18,$18,$17,$16,$15,$15,$14,$13,$12,$12
 dc.B	$11,$10,$10,$0F,$0E,$0E,$0D,$0C,$0C,$0B,$0A,$0A,$09,$09,$08,$08
 dc.B	$07,$07,$06,$06,$05,$05,$04,$04,$04,$03,$03,$03,$02,$02,$02,$01
 dc.B	$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 dc.B	$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04
 dc.B	$04,$05,$05,$06,$06,$07,$07,$08,$08,$09,$09,$0A,$0A,$0B,$0C,$0C
 dc.B	$0D,$0E,$0E,$0F,$10,$10,$11,$12,$12,$13,$14,$15,$15,$16,$17,$18
 dc.B	$18,$19,$1A,$1B,$1C,$1C,$1D,$1E,$1F,$20
FinTab:

TabLunghezz	= FinTab-SinTabHstarts

OndeggiaSpriteS:
	addq.b	#1,Barra1OffSalv
	moveq	#0,D0
	move.b	Barra1OffSalv(pc),D0
	cmp.w	#TabLunghezz,D0		; siamo al massimo offset?
	bne.s	NonRipartireO1
	clr.b	Barra1OffSalv		; riparti da capo
NonRipartireO1:
	addq.b	#2,Barra2OffSalv
	moveq	#0,D0
	move.b	Barra2OffSalv(pc),D0
	cmp.w	#TabLunghezz,D0
	bne.s	NonRipartireO2
	clr.b	Barra2OffSalv		; riparti da capo
NonRipartireO2:
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
	moveq	#0,D4
	moveq	#0,D5
	lea	SpritesBuffer,A0	; indirizzo primo sprite
	lea	SinTabHstarts(PC),A1
	move.b	Barra1OffSalv(pc),D0
	move.b	Barra2OffSalv(pc),D2
	move.b	0(A1,D0.w),D5	; da sintab secondo Barra1OffSalv
OndeggiaLoop:
	move.b	0(A1,D0.w),D3	; da sintab - per barra 1
	move.b	0(A1,D2.w),D4	; da sintab - per barra 2

; modifica tutto

	add.b	D4,D3	; barra 1
	sub.b	D5,D3	; 

	add.b	D5,D4	; barra 2

	add.b	#105,D3	; centra barra 1
	add.b	#75,D4	; centra barra 2

; Modifica gli HSTART (posizione orizzontale) degli 8 sprites

; ** Prima Barra

	move.b	D3,1(A0)		; sprite 1
	move.b	D3,LungSpr+1(A0)	; 2

; ora lo sprite attacched della stessa barra, ma affiancato (16 pixel dopo)

	addq.w	#8,D3			; adda 8, ossia 16 pixel, dato che
					; HSTART adda 2 ogni volta.
	move.b	D3,(LungSpr*2)+1(A0)	; 3
	move.b	D3,(LungSpr*3)+1(A0)	; 4

; ** Seconda Barra

	move.b	D4,(LungSpr*4)+1(A0)	; 5
	move.b	D4,(LungSpr*5)+1(A0)	; 6

	addq.w	#8,D4			; adda 8, ossia 16 pixel, dato che
					; HSTART adda 2 ogni volta.
	move.b	D4,(LungSpr*6)+1(A0)	; 7
	move.b	D4,(LungSpr*7)+1(A0)	; 8

	addq.w	#1,D2		; offset prossimo - bar 2...
	cmpi.w	#TabLunghezz,D2	; siamo al massimo?
	bne.s	Nonrestart2
	moveq	#0,D2		; rileggi dal primo valore...
Nonrestart2:
	addq.w	#1,D0		; offset prossimo - bar 1
	cmp.w	#TabLunghezz,D0	; siamo al massimo?
	bne.s	Nonrestart1
	moveq	#0,D0		; rileggi dal primo valore
Nonrestart1:
	addq.w	#8,A0		; salta al prossimo riutilizzo di sprite

	cmpa.l	#SpritesBuffer+LungSpr,a0 ; abbiamo finito?
	bne.s	OndeggiaLoop
	rts

Barra1OffSalv:
	dc.w	0
Barra2OffSalv:
	dc.w	0


; ****************************************************************************
;				COPPERLIST
; ****************************************************************************

	section	baucoppe,data_c

COPPER:
	dc.w	$8e,$2c81	; diwstart
	dc.w	$90,$2cc1	; diwstop
	dc.w	$92,$38		; ddfstart
	dc.w	$94,$d0		; ddfstop

SPRITEPOINTERS:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0,$138,0,$13a,0,$13c,0,$13e,0

	dc.w	$108,0	; bpl1mod
	dc.w	$10a,0	; bpl2mod
	dc.w	$102,0	; bplcon1
	dc.w	$104,0	; bplcon2

BPLPOINTERS:
	dc.w	$e0,0,$e2,0	; plane 1

	dc.w	$100,$1200	; bplcon0 - 1 plane lowres

	dc.w	$180,0		; color0 - nero
	dc.w	$182,$fff	; color1 - bianco

; Colori degli sprite (attacched) - da color17 a color31

	dc.w	$1a2,$010,$1a4,$020,$1a6,$030
	dc.w	$1a8,$140,$1aa,$250,$1ac,$360,$1ae,$470
	dc.w	$1b0,$580,$1b2,$690,$1b4,$7a0,$1b6,$8b0
	dc.w	$1b8,$9c0,$1ba,$ad0,$1bc,$be0,$1be,$cf0

	dc.w	$ffff,$fffe	; fine copperlist

; ****************************************************************************

	section	grafica,bss_C

SpritesBuffer:
	DS.B	LungSpr*8	; 1024 bytes ogni sprite megariutilizzato

; ****************************************************************************

plane:
	ds.b	40*256	; 1 plane lowres "nero" come sfondo.

	END

