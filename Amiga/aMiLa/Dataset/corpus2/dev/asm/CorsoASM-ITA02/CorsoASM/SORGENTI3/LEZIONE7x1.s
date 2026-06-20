
; Lezione7x1.s	COLLISIONE TRA SPRITE E PLAYFIELD
;		In questo esempio c'e` uno sprite che attraversa rettangoli
;		di diversi colori. Quando lo sprite tocca un determinato
;		colore, si accende un rivelatore.

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
	MOVEQ	#3-1,D1
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

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	MuoviSprite0	; Muovi l'aereo
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

; Questa routine muove lo sprite in linea retta di 2 pixel per volta

MuoviSprite0:
	subq.b	#1,HSTART0
	rts


; Questa routine controlla se c'e` collisione.
; In caso affermativo, "accende" il rivelatore di collisione.
; Il rivelatore e` semplicemente un rettangolo colorato con il COLORE 7.
; Modificando nella copperlist il valore assunto dal registro COLOR07,
; si provoca l'accensione (rosso) o lo spegnimento (grigio) del rivelatore.

CheckColl:
	move.w	$dff00e,d0	; legge CLXDAT ($dff00e)
				; una lettura di questo registro ne provoca
				; anche la cancellazione, per cui conviene
				; copiarselo in d0 e fare i test su d0
	move.w	d0,d7
	btst.l	#1,d0		; il bit 1 indica la collisione tra sprite 0
				; e playfield
	beq.s	no_coll		; se non c'e` collisione salta

si_coll:
	move.w	#$f00,rileva_collisione ; "accende" il rivelatore (COLOR07)
					; modificando la copperlist (rosso)
	bra.s	exitColl		; esci

no_coll:
	move.w	#$555,rileva_collisione ; "spegne" il rivelatore (COLOR07)
					; modificando la copperlist (grigio)
exitColl:
	rts



	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0


; Questo e` il registro CLXCON (controlla il modo di rilevamento)

; i bit da 0 a 5 sono i valori che devono essere assunti dai plane
; i bit da 6 a 11 indicano quali planes sono abilitati alle collisioni
; i bit da 12 a 15 indicano quali degli sprite dispari sono abilitati
; al rilevamento delle collisioni.
		    ;5432109876543210
	dc.w	$98,%0000000111000011	; CLXCON

; Questi valori indicano che i planes 1,2 e 3 sono attivi per le collisioni, e
; che viene segnalata collisione quando lo sprite si sovrappone ad un pixel
; che ha:	plane 1 = 1
; 		plane 2 = 1
;		plane 3 = 0
 

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1

	dc.w	$104,$0024	; BplCon2 - mette tutti gli sprite davanti ai
				; playfield

	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; 3 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0
	dc.w $e4,0,$e6,0
	dc.w $e8,0,$ea,0

; colori bitplanes
	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$620
	dc.w	$184,$fff
	dc.w	$186,$e00
	dc.w	$188,$808
	dc.w	$18a,$f4a
	dc.w	$18c,$aaa
	dc.w	$18e	; color07 - il valore caricato in questo registro viene
			; scritto dalla routine ChekColl a seconda del verifi-
			; carsi o meno di una collisione.
rileva_collisione:
	dc.w	0	; IN QUESTO PUNTO la routine CheckColl modifica
			; la copper list scrivendo il colore giusto.

; colori sprite
	dc.w	$1A2,$00f	; color17, ossia COLOR1 dello sprite0
	dc.w	$1A4,$0c0	; color18, ossia COLOR2 dello sprite0
	dc.w	$1A6,$0c0	; color19, ossia COLOR3 dello sprite0

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco lo sprite: OVVIAMENTE deve essere in CHIP RAM! ************

MIOSPRITE0:		; lunghezza 6 linee
VSTART0:
	dc.b 200	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART0:
	dc.b $d8	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP0:
	dc.b 206	; 200+6=206
VHBITS:
	dc.b $00
	dc.w	$0008,$0000
	dc.w	$1818,$0000
	dc.w	$2C28,$1010
	dc.w	$7FF8,$0000
	dc.w	$3FC0,$0000
	dc.w	$01F0,$0000
	dc.w	$0000,$0000

PIC:
	incbin	"collpic.raw"

	end

In questo esempio mostriamo come rilevare le collisioni tra sprite e plafield.
Come abbiamo gia` visto nella lezione, si usano i due registri CLXDAT e CLXCON.
CLXDAT serve semplicemente per sapere se si e` verificata una collisione e si
usa esattamente come nel caso di collisione tra 2 sprite (solo che ovviamente
si usa un bit diverso). L'uso di CLXCON, invece e` piu` complesso. Vediamolo
bene studiando il nostro esempio. Abbiamo scritto nella copper list: 

		    ;5432109876543210
	dc.w	$98,%0000000111000011	; CLXCON

I bit da 6 a 11 indicano quali planes sono abilitati alle collisioni. Nel
nostro esempio sono abilitati i planes 1,2,3 (i planes visualizzati). I bit
da 0 a 5 indicano invece i valori che devono essere assunti dai plane affinche`
si verifichi la collisione. Nel nostro esempio la collisione c'e` se i 3 planes
abilitati assumono i seguenti valori: plane 3 = 0, plane 2 = 1, plane 1 = 1,
ovvero la sequenza %011=3. Quidi viene rilevata la collisione tra lo sprite
e il colore 3. Notate che non ha interesse il valore che devono assumere
i planes 4,5 e 6 in quanto sono disabilitati.

Modificate ora la copper list come segue:
		    ;5432109876543210
	dc.w	$98,%0000000111000010	; CLXCON

Ora i planes abilitati sono sempre 1,2 e 3 ma il valore che devono assumere
e` pari alla sequenza %010, ovvero il colore 2. Potete verificarlo lanciando
il programma. Funziona allo stesso modo per gli altri colori.

E se volessimo rilevare la collisione con piu` di 2 colori ?
In certi casi e` possibile farlo non abilitando tutti i piani visualizzati.
Modificate la copper list come segue:
		    ;5432109876543210
	dc.w	$98,%0000000110000010	; CLXCON

A differenza di prima, abbiamo abilitato per il rilevamento collisioni
solo i planes 2 e 3. Questo significa che il valore del plane 1 non ha effetto
sul rilevamento delle collisioni. E` necessario solamente che:
plane 3 = 0 e plane 2 = 1. Poiche` cio` si verifica sia per la sequenza
binaria %010 sia per la sequenza %011, entrambe daranno luogo ad una
collisione. In questo modo la collisione avverra` per il colore 2 (%010)
e per il colore 3 (%011).

Vediamo un'altro esempio. Modificate la copper list come segue:
		    ;5432109876543210
	dc.w	$98,%0000000001000001	; CLXCON

Ora e` abilitato solo il plane 1, e la collisione si verifica quando il
plane 1 = 1. Questo accade per tutti i colori dispari. Si ha infatti:

	%001	colore 1
	%011	colore 3
	%101	colore 5
	%111	colore 7

In tutte e quattro queste combinazioni il plane 1 vale 1.

Tutto cio` che abbiamo detto e` valido anche nel caso di un numero di planes
visualizzati diverso da 3.

