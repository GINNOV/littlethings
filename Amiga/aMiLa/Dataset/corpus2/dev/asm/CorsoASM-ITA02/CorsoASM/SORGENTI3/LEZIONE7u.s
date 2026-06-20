
; lezione7u.s  - ESEMPIO Double Playfield
; Questo e` un semplice esempio del dual playfield mode.
; Sono visualizzati i due playfield. Premendo il bottone destro si cambia
; la priorita` dei due playfield. Sinistro per uscire
; Fate attenzione alla copperlist, perche' le principali differenze del modo
; Dual Playfield rispetto al modo normale e' nei BPLPOINTERS e nei colori.


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo le PIC

	MOVE.L	#PIC1,d0	; puntiamo il playfield 1
	LEA	BPLPOINTERS1,A1
	MOVEQ	#3-1,D1
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
	MOVEQ	#3-1,D1
POINTBP2:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0
	addq.w	#8,a1
	dbra	d1,POINTBP2


	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse1:
	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2

	bchg.b	#6,BPLCON2	; scambiamo la priorita' agendo sul bit 6
				; del $dff104

mouse2:
	btst	#6,$bfe001	; mouse premuto?
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

	dc.w	$104		; BplCon2
	dc.b	0
BPLCON2:
	dc.b	0		; priorita' fra playfields: bit 6

	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0110011000000000	; bit 10 acceso = dual playfield
					; uso 6 planes = 8 colori per playfield

BPLPOINTERS1:
	dc.w $e0,0,$e2,0	;primo bitplane playfield 1 (BPLPT1)
	dc.w $e8,0,$ea,0	;secondo bitplane playfield 1 (BPLPT3)
	dc.w $f0,0,$f2,0	;terzo bitplane playfield 1 (BPLPT5)


BPLPOINTERS2:
	dc.w $e4,0,$e6,0	;primo bitplane playfield 2 (BPLPT2)
	dc.w $ec,0,$ee,0	;secondo bitplane playfield 2 (BPLPT4)
	dc.w $f4,0,$f6,0	;terzo bitplane playfield 2 (BPLPT6)

	dc.w	$180,$0f0	; palette playfield 1
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

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Ecco le figure dei 2 playfields

PIC1:	incbin	"dual1.raw"
PIC2:	incbin	"dual2.raw"

	end

Questo e` un semplice esempio di uso del modo dual-playfield. Per 
visualizzare una schermata dual playfield si eseguono, piu` o meno, le stesse
operazioni. Bisogna solo tenere presente che nel puntare i bit-planes, i 
dispari puntano ad un playfield e i pari all'altro. Di solito quindi si usano 
2 routine separate, e anche nella copperlist i bit-planes dispari sono 
separati dai pari. Per quanto riguarda i colori, ogni playfield ha la sua 
palette. I colori 0 e 8 fanno da trasparente, cioe` lasciano vedere cosa c'e` 
sotto, allo stesso modo che il trasparente degli sprites. Il colore 0, pero`, 
fa anche da sfondo, nel senso che nelle zone dello schermo in cui entrambi i
playfield sono trasparenti, viene SEMPRE visualizzato il colore 0, 
indipendentemente dalla pririta` dei due playfield. Per questo motivo, il 
colore 0 va comunque settato, mentre e` inutile settare il colore 8.
La priorita` dei 2 playfield e` controllata dal bit 6 del registro BPLCON2
($dff104): se il bit vale 0 il playfield 1 appare sopra al 2, viceversa se il 
bit vale 1.
