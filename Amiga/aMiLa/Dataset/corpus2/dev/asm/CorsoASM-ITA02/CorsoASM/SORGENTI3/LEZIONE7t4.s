
; Lezione7t4.s	palline

;	In questo listato facciamo una serie di palline in movimento
;	riutilizzando i 4 sprite "attached" 11 volte ciascuno, per un totale
;	di 44 palline.
;	Ognuno degli sprite attacched viene riutilizzato per formare uno
;	"strato" di stelle con la medesima velocita', per cui ci sono
;	4 diverse velocita' di scorrimento.
;	Ad esempio le stelle piu' piccole e lente, che sembrano le piu'
;	lontane, sono tutte fatte col riutilizzo dello sprite attacched 4,
;	ossia formato dagli sprite 6 e 7 attaccati.


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

	MOVE.L	#SPRITE0,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo tutti gli 8 sprite, dato che li utiliziamo tutti per fare
;	4 sprite attacched, i quali formano i 4 "livelli" di stelle a
;	diversa velocita'

	MOVE.L	#SPRITE1,d0
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#SPRITE2,d0
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#SPRITE3,d0
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#SPRITE4,d0
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#SPRITE5,d0
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#SPRITE6,d0
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#SPRITE7,d0
	addq.w	#8,a1
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

	bsr.s	MuoviSprites_01	; questa routine muove gli sprite 0 e 1
				; attacched, cioe' le palline grandi con
				; la massima velocita': 8 pixel alla volta

	bsr.s	MuoviSprites_23	; questa routine muove gli sprite 2 e 3
				; attacched, cioe' le palline grandi con
				; una velocita' di 6 pixel alla volta

	bsr.w	MuoviSprites_45	; questa routine muove gli sprite 4 e 5
				; attacched, cioe' le palline di media
				; grandezza e media velocita' (4 pixel a volta)

	bsr.w	MuoviSprites_67	; questa routine muove gli sprite 6 e 7
				; attacched, cioe' le palline piu' lente
				; e piccole (spostate di 2 pixel alla volta)

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

; Questa routine muove gli sprite 0 e 1 che sono attaccati, pertanto devono
; avere le stesse coordinate. 

MuoviSprites_01:
	lea	Sprite0,a0	; indirizzo sprite 0
	lea	Sprite1,a1	; indirizzo sprite 1
	moveq	#11-1,d7	; numero di utilizzi dello sprite
loop01:
	addq.b	#4,1(a0)	; sposta di 8 pixel a destra lo sprite 0
				; agendo sul suo HSTART
	addq.b	#4,1(a1)	; sposta di 8 pixel a destra lo sprite 1
				; agendo sul suo HSTART
	lea	68(a0),a0	; coordinate prossimo riuso dello sprite 0
	lea	68(a1),a1	; coordinate prossimo riuso dello sprite 1
	dbra	d7,loop01       ; loop
	rts

; Questa routine muove gli sprite 2 e 3 che sono attaccati, pertanto devono
; avere le stesse coordinate.

MuoviSprites_23:
	lea	Sprite2,a0	; indirizzo sprite 2
	lea	Sprite3,a1	; indirizzo sprite 3
	moveq	#11-1,d7	; numero di utilizzi dello sprite
loop23:
	addq.b	#3,1(a0)	; sposta di 6 pixel a destra lo sprite 2
				; agendo sul suo HSTART
	addq.b	#3,1(a1)	; sposta di 6 pixel a destra lo sprite 3
				; agendo sul suo HSTART
	lea	68(a0),a0	; coordinate prossimo riuso dello sprite 2
	lea	68(a1),a1	; coordinate prossimo riuso dello sprite 3
	dbra	d7,loop23       ; loop
	rts

; Questa routine muove gli sprite 4 e 5 che sono attaccati, pertanto devono
; avere le stesse coordinate.

MuoviSprites_45:
	lea	Sprite4,a0	; indirizzo sprite 4
	lea	Sprite5,a1	; indirizzo sprite 5
	moveq	#11-1,d7	; numero di utilizzi dello sprite
loop45:
	addq.b	#2,1(a0)	; sposta di 4 pixel a destra lo sprite 4
	addq.b	#2,1(a1)	; sposta di 4 pixel a destra lo sprite 5
	lea	68(a0),a0	; coordinate prossimo riuso dello sprite 4
	lea	68(a1),a1	; coordinate prossimo riuso dello sprite 5
	dbra	d7,loop45       ; loop
	rts

; Questa routine muove gli sprite 4 e 5 che sono attaccati, pertanto devono
; avere le stesse coordinate.

MuoviSprites_67:
	lea	Sprite6,a0	; indirizzo sprite 6
	lea	Sprite7,a1	; indirizzo sprite 7
	moveq	#11-1,d7	; numero di utilizzi dello sprite
loop67:
	addq.b	#1,1(a0)	; sposta di 2 pixel a destra lo sprite 6
	addq.b	#1,1(a1)	; sposta di 2 pixel a destra lo sprite 7
	lea	68(a0),a0	; coordinate prossimo riuso dello sprite 6
	lea	68(a1),a1	; coordinate prossimo riuso dello sprite 7
	dbra	d7,loop67       ; loop
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
	dc.w	$100,%0001001000000000

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$000	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$1a0,$000,$1a2,$fff	; palette degli sprites
	dc.w	$1a4,$f00,$1a6,$b00
	dc.w	$1a8,$600,$1aa,$F40
	dc.w	$1ac,$F80,$1ae,$Fa0
	dc.w	$1b0,$Ff0,$1b2,$00f
	dc.w	$1b4,$04f,$1b6,$08f
	dc.w	$1b8,$0ff,$1ba,$0f0
	dc.w	$1bc,$283,$1be,$f0f


	dc.w	$FFFF,$FFFE	; Fine della copperlist

; Qui ci sono gli sprite. Ogni sprite e` riutilizzato 11 volte.
; Gli sprite dispari hanno il bit ATTACHED settato per formare sprite
; a 16 colori. Come potete notare, le "palline" sono tutte uguali.

Sprite0:
	dc.w    $38D0,$4800	; words di controllo
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318 ; pallina
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$4943,$5900	; words di controllo
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318 ; pallina
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$6087,$7000
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $71af,$8100
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $8213,$9200
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $93D0,$a300
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$a443,$b400
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$b587,$c500
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $c6af,$d600
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $d713,$e700
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $e8b9,$f800
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000
	dc.w	0,0	; fine sprite0

Sprite1:
	dc.w    $38D0,$4880	; words di controllo
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000 ;pallina
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$4943,$5980	; words di controllo
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000 ; pallina
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$6087,$7080
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $71af,$8180
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $8213,$9280
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $93D0,$a380
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$a443,$b480
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$b587,$c580
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $c6af,$d680
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $d713,$e780
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $e8b9,$f880
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000
	dc.w	0,0 ; fine sprite 1

Sprite2:
	dc.w    $44D0,$5400	; words di controllo
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318 ; pallina
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$5543,$6500	; words di controllo
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318 ; pallina
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$6687,$7600
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $77af,$8700
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $8813,$9800
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $99D0,$a900
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$aa43,$ba00
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w	$bb87,$cb00
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $ccaf,$dc00
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $dd13,$ed00
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000

	dc.w    $ee5c,$fe00
	dc.w	$0000,$0000,$0200,$0200,$0db0,$0d80,$1520,$1318
	dc.w	$2e30,$3208,$3e70,$260c,$3464,$2c1c,$70e0,$7018
	dc.w	$20c8,$2038,$01c0,$0030,$0390,$0070,$0720,$00e0
	dc.w	$0e40,$01c0,$0000,$0700,$0000,$0000,$0000,$0000
	dc.w	0,0	; fine sprite 2

Sprite3:
	dc.w    $44D0,$5480	; words di controllo
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000 ; pallina
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$5543,$6580	; words di controllo
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000 ; pallina
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$6687,$7680
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $77af,$8780
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $8813,$9880
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $99D0,$a980
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$aa43,$ba80
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w	$bb87,$cb80
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $ccaf,$dc80
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $dd13,$ed80
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000

	dc.w    $ee5c,$fe80
	dc.w	$07c0,$0000,$1df8,$0000,$3278,$0000,$68fc,$0000
	dc.w	$41fc,$0000,$c1fe,$0000,$c3fe,$0000,$8ffa,$0004
	dc.w	$dffa,$0004,$fff2,$000c,$7ff4,$0008,$7fe4,$0018
	dc.w	$3fc8,$0030,$1f30,$00c0,$07c0,$0000,$0000,$0000
	dc.w	0,0	; fine sprite 3

Sprite4:
	dc.w    $3877,$4800	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 ; pallina
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w    $49D0,$5900	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 ; pallina
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$6043,$7000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$7187,$8100
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w    $82af,$9200
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w    $9313,$a300
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w    $a4D0,$b400
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w	$b543,$c500
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w	$c687,$d600
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w    $d7af,$e700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	

	dc.w    $e813,$f800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0540,$0700,$0e60,$0980,$3cc0,$3220,$1a90,$1670
	dc.w	$0490,$1c70,$19a0,$1860,$0320,$00e0,$0640,$01c0
	dc.w	$0080,$0380,$0000,$0000,$0000,$0000,$0000,$0000	
	dc.w	0,0	; fine sprite 4

Sprite5:
	dc.w    $3877,$4880	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000 ; pallina
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w    $49D0,$5980	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000 ; pallina
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w	$6043,$7080
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w	$7187,$8180
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w    $82af,$9280
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w    $9313,$a380
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w    $a4D0,$b480
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w	$b543,$c580
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w	$c687,$d680
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w    $d7af,$e780
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000

	dc.w    $e813,$f880
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$0000
	dc.w	$08e0,$0000,$1070,$0000,$01f8,$0000,$21f8,$0000
	dc.w	$23f8,$0000,$27e8,$0010,$3fe8,$0010,$1fd0,$0020
	dc.w	$0fa0,$0040,$07c0,$0000,$0000,$0000,$0000,$0000
	dc.w	0,0	; fine sprite 5

Sprite6:
	dc.w	$4040,$5000	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 ; pallina
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$5188,$6100	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 ; pallina
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$6206,$7200
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$73dd,$8300
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$8469,$9400
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$95e4,$a500
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$a62c,$b600
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$b799,$c700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$c8d0,$d800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$d955,$e900
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$eab4,$fa00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$03a0,$0280,$03e0,$00a0,$0340,$0320
	dc.w	$0180,$0140,$0340,$00c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	0,0

Sprite7:
	dc.w	$4040,$5080	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 ; pallina
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$5188,$6180	; words di controllo
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 ; pallina
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$6206,$7280
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$73dd,$8380
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$8469,$9480
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$95e4,$a580
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$a62c,$b680
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$b799,$c780
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$c8d0,$d880
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$d955,$e980
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$eab4,$fa80
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c0,$0000,$0060,$0000,$0470,$0000,$04f0,$0000
	dc.w	$06d0,$0020,$03e0,$0000,$01c0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	0,0	; fine sprite 7


	SECTION	PLANEVUOTO,BSS_C
BITPLANE:
	ds.b	40*256

	end

In questo listato vediamo un miglioramento dell'effetto delle stelle.
Questa volta invece di stelle fatte da un puntino, muoviamo delle palline
colorate. Usiamo sempre degli sprite, ma a 16 colori, perche' ogni sferetta
e' costituita da una coppia di sprite attaccati. Inoltre non utiliziamo
una sola coppia di sprite attaccati (le stelle erano fatte con un solo sprite 
riutilizzato), ma tutte e 4 le coppie disponibili, il che ci consente di 
avere piu` sprite che viaggiano sulla stessa riga e che si sovrappongono.
Ogni coppia di sprite e' riutilizzata 11 volte per un totale di 44 palline
sullo schermo.

Utiliziamo per ogni coppia di sprite una routine di movimento separata.
Le quattro routine comunque si differenziano solo per la diversa velocita`
con cui muovono le palline. Palline create da una stessa coppia di sprite
hanno la stessa velocita`, mentre palline create da coppie diverse hanno
velocita` diverse.

Per il resto non ci sono differenze con i listati delle stelle.

