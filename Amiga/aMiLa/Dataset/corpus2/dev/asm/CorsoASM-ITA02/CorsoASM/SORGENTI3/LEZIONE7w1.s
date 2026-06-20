
; Lezione7w1.s	COLLISIONE TRA SPRITE


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
	MOVEQ	#2-1,D1
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0
	addq.w	#8,a1
	dbra	d1,POINTBP

;	Puntiamo lo sprite

	LEA	SpritePointers,a1	; Puntatori in copperlist
	MOVE.L	#MIOSPRITE0,d0		; indirizzo dello sprite in d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	add.l	#16,a1

	MOVE.L	#MIOSPRITE2,d0		; indirizzo dello sprite in d0
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

	bsr.s	MuoviSprite0	; Muovi l'aereo
	bsr.s	MuoviSprite1	; Muovi il missile contro l'aereo
	bsr.s	CheckColl	; Controlla collisione e provvede

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

; Questa routine muove lo sprite dell'aereo in linea retta a sinistra di
; 2 pixel per volta, agendo sul suo HSTART

MuoviSprite0:
	subq.b	#1,HSTART0
	rts

;	-		-		-		-

; Questa routine muove il missile. Lo fa solo se l'aereo e` abbastanza vicino
; da colpirlo. L'aereo e' a tiro quando il suo HSTART e' a $b0.
; Se volete salvare l'aereo provate a far partire il missile alla posizione
; $AA, cioe' troppo presto, oppure alla posizione $c1, ossia troppo tardi.

MuoviSprite1:
	cmp.b	#$b0,HSTART0	; L'aereo e' a tiro?
	bhi.s	non_a_tiro	; non partire se l'aereo e` troppo a destra
	subq.b	#1,VSTART2	; fai salire il missile agendo sia sul
	subq.b	#1,VSTOP2	; VSTART che sul VSTOP
non_a_tiro:
	rts

;	-		-		-		-

; Questa routine controlla se c'e` collisione. In caso affermativo, cancella
; i due sprites, azzerando i relativi puntatori nella copperlist

CheckColl:
	move.w	$dff00e,d0	; legge CLXDAT ($dff00e)
				; una lettura di questo registro ne provoca
				; anche la cancellazione, per cui conviene
				; copiarselo in d0 e fare i test su d0
	btst.l	#9,d0
	beq.s	no_coll		; se non c'e` collisione salta

	MOVEQ	#0,d0		  ; altrimenti cancella gli sprites
	LEA	SpritePointers,a1 ; puntatore sprite 0
	move.w	d0,6(a1)	  ; azzera puntatore sprite 0 in copperlist
	move.w	d0,2(a1)
	add.w	#16,a1		; puntatore sprite 2
	move.w	d0,6(a1)	; azzera puntatore sprite 2 in copperlist
	move.w	d0,2(a1)
no_coll:
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
	dc.w	$104,$0024	; BplCon2 - Sprites davanti i bitplanes
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0010001000000000	; bit 13 acceso!! 2 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane
	dc.w $e4,0,$e6,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$005	; color1	; colore 1 del bitplane
	dc.w	$184,$a40	; color1	; colore 2 del bitplane
	dc.w	$186,$f80	; color1	; colore 3 del bitplane

	dc.w	$1A2,$06f	; color17, ossia COLOR1 dello sprite0
	dc.w	$1A4,$0c0	; color18, ossia COLOR2 dello sprite0
	dc.w	$1A6,$0c0	; color19, ossia COLOR3 dello sprite0

	dc.w	$1AA,$444	; color21, ossia COLOR1 dello sprite2
	dc.w	$1AC,$888	; color22, ossia COLOR2 dello sprite2
	dc.w	$1AE,$0c0	; color23, ossia COLOR3 dello sprite2

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco lo sprite: OVVIAMENTE deve essere in CHIP RAM! ************

MIOSPRITE0:		; lunghezza 6 linee
VSTART0:
	dc.b 180	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART0:
	dc.b $d8	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP0:
	dc.b 186	; 180+6=186
VHBITS:
	dc.b $00
	dc.w	$0008,$0000
	dc.w	$1818,$0000
	dc.w	$2C28,$1010
	dc.w	$7FF8,$0000
	dc.w	$3FC0,$0000
	dc.w	$01F0,$0000
	dc.w	$0000,$0000

MIOSPRITE2:		; lunghezza 16 linee
VSTART2:
	dc.b 224	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART2:
	dc.b $86	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP2:
	dc.b 240
	dc.b 0
	dc.w	$0200,$0000
	dc.w	$0200,$0000
	dc.w	$0200,$0000
	dc.w	$0000,$0200
	dc.w	$0000,$0700
	dc.w	$0000,$0700
	dc.w	$0500,$0200
	dc.w	$0200,$0500
	dc.w	$0500,$0200
	dc.w	$0200,$0500
	dc.w	$1540,$0200
	dc.w	$0200,$1DC0
	dc.w	$0000,$1FC0
	dc.w	$0000,$1740
	dc.w	$0500,$0200
	dc.w	$0000,$0000
	dc.w	$0000,$0000

;	Figura della rampa di lancio

PIC:
	incbin	"paesaggio.raw"

	end

In questo esempio vediamo come rilevare la collisione tra 2 sprite.
Abbiamo 2 oggetti che si scontrano. Notate che per i 2 oggetti abbiamo usato
gli sprite 0 e 2, cioe` 2 sprite che appartengono a 2 gruppi diversi.
Questo fatto innanzitutto ci permette, come abbiamo gia` visto, di usare
2 palette diverse per i 2 oggetti, ma e` anche necessario per poter
sfruttare la collisione tra sprite. Infatti e` possibile rilevare solo
le collisioni tra sprite appartenenti a coppie diverse, e non fra sprite
appartenenti alla stessa coppia. Per rilevare una collisione basta controllare
lo stato di un bit nel registro CLXDAT, come abbiamo gia` visto nella lezione.

Quando il bit relativo alla collisione vale 1, allora la collisione si e` 
effettivamente verificata. Il nostro esempio si limita a cancellare i 2
sprite, azzerando i relativi puntatori nella copperlist. Potete migliorare
l'esempio aggiungendo una bella esplosione. E` molto semplice. Innanzitutto
disegnatevi uno sprite che rappresenta un'esplosione e aggiungetelo al
sorgente (mi raccomando nella SECTION che va nella memoria CHIP).
Poi modificate la routine ChekColl: quando viene rilevata la collisione
sostituite alle istruzioni

	MOVEQ	#0,d0		; altrimenti cancella gli sprites
	LEA	SpritePointers,a1	; puntatore sprite 0
	move.w	d0,6(a1)	; azzera puntatore sprite 0 in copperlist
	move.w	d0,2(a1)

le istruzioni

	MOVE.L	#SPRITE_ESPLOSIONE,d0	; indirizzo sprite esplosione
	LEA	SpritePointers,a1	; puntatore sprite 0
	move.w	d0,6(a1)	; modifica puntatore sprite 0 in copperlist
	swap	d0
	move.w	d0,2(a1)

in questo modo invece di cancellare lo sprite, sostituirete il disegno
dell'aereo con quello dell'esplosione. Dovrete inoltre avere l'accortezza
di copiare i byte che controllano la posizione dell'aereo (VSTART0,HSTART0)
nei corrispondenti byte di controllo dello sprite dell'esplosione. Questo
dovreste saperlo fare da soli, ormai. Dovete fare solo un po' di attenzione
a VSTOP: se il disegno dell'esplosione ha un'altezza diversa da quello
dell'aereo, non potete semplicemente copiare il VSTOP, ma dovrete aggiustarlo.
Nulla di difficile, comunque.

In questo esempio abbiamo volutamente fatto percorrere delle traettorie molto
semplici (delle rette) ai 2 sprite, per mostrare meglio il meccanismo della
collisione. Potete provare a sostituire alle 2 routine che muovono gli sprite
una delle routine che usano tabelle che abbiamo usato negli altri esempi.

