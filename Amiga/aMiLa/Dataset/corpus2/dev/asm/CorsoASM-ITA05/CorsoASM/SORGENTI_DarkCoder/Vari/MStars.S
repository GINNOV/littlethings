
; Animazione degli sprite per fare delle stelle "magic"
; Original version: Autore sconosciuto
; Fixed version: Randy/Ram Jam

	SECTION	stars6,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110100000	; copper,bitplane,sprites

Waitdisk	EQU	10

START:

; Puntiamo il biplane azzerato

	MOVE.L	#PLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPERSTELL,$80(a5)	; Puntiamo la nostra COP
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
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $010
	Beq.S	Waity2

	btst	#2,$16(A5)	; Tasto destro premuto?
	beq.s	NonStell

	bsr.s	Stellozze

NonStell:
	btst	#6,$bfe001	; tasti sin. mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
; Routine che punta gli sprites giusti per fare l'effetto "stelle magiche"
*****************************************************************************

WaitTime	=	2	; 0 = max velocita'

Stellozze:
	MOVEQ	#8-1,D0		; numero sprites: 8
	LEA	SpritePosXYTab(PC),A0	; Questo indirizzo e' usato per due
					; tabelle: con offset positivi si
					; accede alla tabella delle posizioni
					; XY in formato "words di controllo",
					; mentre con offsets negativi si
					; accede alla tab .b usata per fare
					; l'animazione simil-casuale

	LEA	COPSPR,A1	; puntatori agli sprites in COPPERLIST
FaiUnoSpriteLoop:

; Rallentiamo un poco l'esecuzione...

	SUBQ.B	#1,-8(A0,D0.W)	; sottrai 1 al wait time
	BPL.S	NonAncZero	; non e' = 0 ancora?
	MOVE.B	#WaitTime,-8(A0,D0.W)	; rimetti il wait time

; Ora ci occupiamo di ciclare i valori e i frames dalla anitab

	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	-16(A0,D0.W),D1	; val1
	MOVE.B	-24(A0,D0.W),D2	; val2
	ADDQ.W	#1,D1		; val1+1
	CMP.B	#13,D1		; siamo a 13? (massimo fotogramma)
	BLT.S	NonMax1		; se non ancora, ok
	MOVEQ	#0,D1		; se si, riparti da zero
	ADDQ.W	#1,D2
	CMP.B	#45,D2		; Siamo a 45? (massima coppia di word di
				; controllo della SpritePosXYTab)
	BLT.S	NonMax2		; se non ancora, ok
	MOVEQ	#0,D2		; si?, riparti da zero! (o andiamo fuori tab)
NonMax2:
	MOVE.B	D2,-24(A0,D0.W)	; salva il valore (pos XY attuale dalla tab)
NonMax1:
	MOVE.B	D1,-16(A0,D0.W)	; salva il valore

; Ora dobbiamo trovare il frame (sprite) giusto

	MULU.W	#68,D1		; fotogramma attuale * lungh. 1 fotogramma,
				; e otteniamo l'offset dall'inizio dello
				; spriteanim giusto
	MOVE.W	D0,D3		; numero sprite attuale in d3
	MULU.W	#13*68,D3	; * lunghezza 1 spriteanim = offset per lo
				; spriteanim giusto
	ADD.L	#AnimSprites-2,D1 ; offset fotogramma + indirizzo AnimSprites
	ADD.L	D3,D1		; + offset sprite anim = indirizzo giusto!!!

; Abbiamo in d1 l'indirizzo dello sprite giusto... dobbiamo pero' cambiargli
; la posizione X ed Y (HSTART/VSTART), prendendo tali valori dalla tab
; SpritePosXYTab, che li contiene gia' in forma di 2 word di controllo belle
; pronte. In d2 abbiamo quale val il tab prendere... d2*4 per l'offset!

	MOVE.L	D1,A2		; copio address dello sprite giusto in a2
	ADD.W	D2,D2		;\ d2*4, infatti ogni elemento della tabella
	ADD.W	D2,D2		;/       e' lungo 2 words (4 bytes)
	MOVE.L	0(A0,D2.W),(A2) ; SpritePosXYTab + offset ok nelle 2 word di
				; controllo dello sprite giusto.

; Ora abbiamo in d1 l'indirizzo dello sprite giusto da puntare.... puntiamolo!

	MOVE.W	D0,D3		; numero sprite attuale in d3...
	ASL.W	#3,D3		; d3 * 8, per trovare l'ofsset dal primo
				; puntatore in copperlist, infatti ogni
				; puntatore occupa 8 bytes.....
	MOVE.W	D1,6(A1,D3.W)	; punta word alta address sprite in cop,
				; infatti: a1(primo puntatore)+d3(offset dal
	SWAP	D1		; (primo puntatore)=address puntatore giusto!
	MOVE.W	D1,2(A1,D3.W)	; punta word bassa
NonAncZero:
	DBRA	D0,FaiUnoSpriteLoop
	RTS



; 24 bytes (3*8)

Anitab:
	dc.b	34,8,28,41,19,16,42,26	; tabella con valori scombinati per
	dc.b	0,7,7,1,6,7,11,4	; permettere l'animazione "simil"
	dc.b	1,1,0,0,2,2,2,1		; casuale delle stelle.
SpritePosXYTab:
	DC.W	$2770,$3600,$434B,$5200,$7F43,$8E00	; tabella con le word
	DC.W	$874B,$9600,$8655,$9500,$6F62,$7E00	; di controllo con le
	DC.W	$4362,$5200,$416C,$5000,$6060,$6F00	; varie posizioni X Y
	DC.W	$6569,$7400,$6B66,$7A00,$4A70,$5900	; per gli sprite.
	DC.W	$646F,$7300,$3978,$4800,$577D,$6600	; nota: 45 coppie
	DC.W	$6078,$6F00,$3687,$4500,$3891,$4700
	DC.W	$438B,$5200,$538D,$6200,$5D87,$6C00
	DC.W	$2C91,$3B00,$2E96,$3D00,$4F92,$5E00
	DC.W	$5E96,$6D00,$3A9A,$4900,$39A1,$4800
	DC.W	$46A8,$5500,$599E,$6800,$61A2,$7000
	DC.W	$5AA5,$6900,$43AB,$5200,$44B3,$5300
	DC.W	$65B0,$7400,$4FB8,$5E00,$6DBC,$7C00
	DC.W	$28B8,$3700,$33BE,$4200,$3EC4,$4D00
	DC.W	$49CA,$5800,$49BB,$5800,$72BF,$8100
	DC.W	$7CC5,$8B00,$82D5,$9100,$86CE,$9500

*****************************************************************************

	section	copper,data_C

COPPERSTELL:
	dc.w	$8e,$2c81	; diwstart
	dc.w	$90,$2cc1	; diwstop
	dc.w	$92,$38		; ddfstart
	dc.w	$94,$d0		; ddfstop

COPSPR:
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

	DC.W	$180,$000,$182,$000

; Colori degli sprite - da color17 a color31

	DC.W	$1A2,$F00,$1A4,$A00,$1A6,$600
	DC.W	$1A8,$000,$1AA,$0F0,$1AC,$0A0
	DC.W	$1AE,$060,$1B0,$000,$1B2,$00F
	DC.W	$1B4,$00A,$1B6,$006,$1B8,$000
	DC.W	$1BA,$FFF,$1BC,$AAA,$1BE,$666

	dc.w	$ffff,$fffe	; fine copperlist

*****************************************************************************

; 68*13*8	ossia 68 bytes ogni fotogramma * 13 fotogrammi * 8 spriteanim

	dc.w	0	; scriviamo anche qua! la word alta... e' tutto
			; sfasato di 1 word.. non chiedetemi perche'!
AnimSprites:
	incbin	"spranim1"	; 13 fotogrammi
	incbin	"spranim2"	; 13 fotogrammi
	incbin	"spranim3"	; 13 fotogrammi
	incbin	"spranim4"	; 13 fotogrammi
	incbin	"spranim5"	; 13 fotogrammi
	incbin	"spranim6"	; 13 fotogrammi
	incbin	"spranim7"	; 13 fotogrammi
	incbin	"spranim8"	; 13 fotogrammi

; ****************************************************************************

	section	grafica,bss_C

plane:
	ds.b	40*256	; 1 plane lowres "nero" come sfondo.

	end

