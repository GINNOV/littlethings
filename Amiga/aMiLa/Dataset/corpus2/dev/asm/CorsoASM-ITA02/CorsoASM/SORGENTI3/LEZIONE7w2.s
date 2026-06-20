
; Lezione7w2.s	COLLISIONE TRA SPRITE DISPARI
; In questo esempio vediamo come rilevare le collisioni degli sprite dispari.
; Questa volta ci sono 2 missili a caccia dell'aereo, e uno dei 2 e` uno
; sprite dispari.
; Se lanciate il programma vedrete pero` che il missile piu` a destra non
; funziona.
; Volete ripararlo ? Leggete il commento finale!


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

	add.l	#16,a1			; puntatore sprite 2
	MOVE.L	#MIOSPRITE2,d0		; indirizzo dello sprite in d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	add.l	#8,a1			; puntatore sprite 3
	MOVE.L	#MIOSPRITE3,d0		; indirizzo dello sprite in d0
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
	bsr.s	MuoviSprite2	; Muovi il missile 1 contro l'aereo
	bsr.s	MuoviSprite3	; Muovi il missile 2 contro l'aereo
	bsr.w	CheckColl	; Controlla collisione e provvede

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

; Questa routine muove lo sprite dell'aereo in linea retta di 2 pixel per volta

MuoviSprite0:
	subq.b	#1,HSTART0
	rts


; Questa routine muove il missile. Lo fa solo se l'aereo e` abbastanza vicino
; da colpirlo.

MuoviSprite2:
	cmp.b	#$b0,HSTART0
	bhi.s	non_a_tiro2	; non partire se l'aereo e` troppo a destra
	subq.b	#1,VSTART2
	subq.b	#1,VSTOP2
non_a_tiro2:
	rts


; Questa routine muove il missile. Lo fa solo se l'aereo e` abbastanza vicino
; da colpirlo.

MuoviSprite3:
	cmp.b	#$d0,HSTART0
	bhi.s	non_a_tiro3	; non partire se l'aereo e` troppo a destra
	subq.b	#1,VSTART3
	subq.b	#1,VSTOP3
non_a_tiro3:
	rts

; Questa routine controlla se c'e` collisione. In caso affermativo, cancella
; i due sprites che hanno scontrato, azzerando i relativi puntatori nella
; copperlist. Per distinguere quale dei 2 missili ha colpito l'aereo,
; vengono controllate le posizioni. Infatti in questo esempio i missili
; possono colpire l'aereo solo dal basso; quindi se un missile si trova
; piu` in alto dell'aereo NON PUO` averlo colpito. In questo modo riusciamo
; a capire quale dei 2 missili ha colpito l'aereo.

CheckColl:
	move.w	$dff00e,d0	; legge CLXDAT ($dff00e)
				; una lettura di questo registro ne provoca
				; anche la cancellazione, per cui conviene
				; copiarselo in d0 e fare i test su d0
	btst.l	#9,d0
	beq.s	no_coll		; se non c'e` collisione salta

	MOVEQ	#0,d0		  ; altrimenti cancella l'aereo
	LEA	SpritePointers,a1 ; puntatore sprite 0
	move.w	d0,6(a1)	  ; azzera puntatore sprite 0 in copperlist
	move.w	d0,2(a1)

; ora dobbiamo capire quale dei 2 missili ha colpito l'aereo.
; controlliamo l'altezza del missile piu` a destra: se si trova piu`
; in alto NON ha colpito l'aereo, altrimenti e` stato lui

	move.b	VSTART0,d1	; legge l'altezza dell'aereo
	cmp.b	VSTART3,d1	; confronta con l'altezza del missile a destra
	bhi.s	spr2_coll	; se l'aereo e` piu` in basso
				; (quindi VSTART0 e` MAGGIORE di VSTART3)
				; la collisione e` causata dallo sprite 2

	LEA	SpritePointer3,a1 ; altrimenti cancella sprite 3
	move.w	d0,6(a1)	  ; azzera puntatore sprite 3 in copperlist
	move.w	d0,2(a1)
	bra.s	no_coll
	
spr2_coll:
	LEA	SpritePointer2,a1 ; cancella sprite 2
	move.w	d0,6(a1)	  ; azzera puntatore sprite 2 in copperlist
	move.w	d0,2(a1)
no_coll:
	rts



	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0
SpritePointer2:
	dc.w	$128,0,$12a,0
SpritePointer3:
	dc.w	$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

		   ; 5432109876543210
	dc.w	$98,%0000000000000000	; CLXCON  $dff098

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,$0024	; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0010001000000000	; 2 bitplane lowres

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

MIOSPRITE3:		; lunghezza 16 linee
VSTART3:
	dc.b 224	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART3:
	dc.b $a6	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP3:
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

;	figura della rampa di lancio

PIC:
	incbin	"paesaggio.raw"

	end

Come abbiamo visto nella lezione, il registro CLXDAT ci permette di rilevare
collisioni tra gruppi di sprite e non tra i singoli sprite. In questo esempio
vediamo come risolvere il problema. Vi ricordo che mentre le collisioni degli
sprite pari (cioe` sprite 0,2,4,6) sono sempre abiitate, quelle degli sprite
dispari (1,3,5,7) devono essere abilitate mediante dei bit di controllo del
registro CLXCON ( $dff098 ). Ogni sprite dispari ha un proprio bit di controllo
e pertanto puo` essere abilitato indipendentemente dagli altri. Se provate ad
eseguire il nostro esempio, noterete che il missile piu` a destra non funziona.
Cio` avviene proprio perche` il missile piu` a destra e` uno sprite dispari
(sprite 3) ed e` disabilitato. Infatti nella copperlist potete trovare
l'istruzione:
		   ; 5432109876543210
	dc.w	$98,%0000000000000000

Che disabilita per le collisioni tutti gli sprite dispari (per il significato
preciso di tutti i bit guardate nella lezione). Per abilitare lo sprite 3,
si deve settare a 1 il bit 13, cioe` modificare l'istruzione copper come segue:

		   ; 5432109876543210
	dc.w	$98,%0010000000000000

Provate ad eseguire l'esempio, e vedrete che ora il missile funziona!

Un altro problema delle collisioni e` che il registro CLXDAT rivela collisioni
tra gruppi di sprite, e non tra i singoli sprite. Nel nostro esempio ci sono
i 2 missili che appartengono allo stesso gruppo. Quindi quando c'e` una 
collisione non possiamo sapere quale dei 2 missili ha colpito l'aereo leggendo
il registro CLXDAT. Per farlo il metodo piu` usato e` quello di controllare le
posizioni degli sprite. In questo esempio particolarmente semplice, basta
controllare se lo sprite piu` a destra sia o meno al di sopra dell'aereo,
come abbiamo spiegato piu` in dettaglio nel commento alla routine CheckColl.
In situazioni piu` complesse con gli sprite che si muovono in piu` direzioni
e` necessario fare dei controlli piu` accurati, basandosi sia sulle posizioni
verticali che su quelle orizzontali. Il principio e` comunque sempre lo stesso.

Potete verificare che la nostra routine individua sempre il missile giusto
modificando la posizione di partenza dello sprite piu` a destra.
Il valore iniziale di HSTART3 e` $a6 e garantisce al misssile di colpire
l'aereo. Sostituite $a6 con $b6. Se eseguite l'esempio vedrete che il missile
si trova troppo a destra e pertanto manchera` l'aereo. Ma non temete! 
Il secondo fara` comunque centro!

