
; lezione7v2.s  -  Sprite nel Dual Playfield mode
; In questo esempio mostriamo i vari livelli di priorita` per gli sprite
; rispetto ai 2 playfield. Gli sprite si muovono dall'alto in basso.
; Ogni volta che raggiungono il bordo inferiore ripartono dall'alto con un
; diverso livello di priorita`. Attendere la fine del programma.

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

;	Puntiamo gli sprite

	MOVE.L	#MIOSPRITE0,d0		; indirizzo dello sprite in d0
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
	MOVE.L	#MIOSPRITE4,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE5,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE6,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE7,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

	lea	PriList(PC),a0	; a0 punta alla lista dei valori di priorita`
	
	move.w	#$0000,$dff104	; BPLCON2
				; con questo valore gli sprite sono tutti
				; sotto entrambi i playfield

aspetta1:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	aspetta1

	bsr.s	MuoviSprites	; Muove in basso gli sprites

aspetta2:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	aspetta2

	cmp.w	#250,altezza	; gli sprite hanno raggiunto il bordo basso?
	blo.s	aspetta1	; no, continua a muoverli

	move.w	#$2c,altezza	; si. Rimetti gli sprite in alto
	cmp.l	#EndPriList,a0	; abbiamo terminato i valori di priorita`?
	beq.s	esci		; se si esci.
	move.w	(a0)+,$dff104	; se no, metti il prossimo valore in BPLCON2
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

; Questa routine muove gli 8 sprites in basso di un pixel alla volta
; Tutti gli sprites hanno la stessa altezza

Muovisprites:

; muove lo sprite 0

	addq.w	#1,altezza
	move.w	altezza(PC),d0

	CLR.B	VHBITS0		; azzera i bit 8 delle posizioni verticali
	MOVE.b	d0,VSTART0	; copia i bit da 0 a 7 in VSTART
	BTST.l	#8,D0		; la posizione e` maggiore di 255 ?
	BEQ.S	NOBIGVSTART	; se no vai oltre infatti il bit e` stato gia`
				; azzerato con la CLR.b VHBITS

	BSET.b	#2,VHBITS0	; altrimenti metti a 1 il bit 8 della posizione
				; verticale di partenza

NOBIGVSTART:
	ADDQ.W	#8,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,VSTOP0	; Muovi i bit da 0 a 7 in VSTOP
	BTST.l	#8,D0		; la posizione e` maggiore di 255 ?
	BEQ.S	NOBIGVSTOP	; se no vai oltre infatti il bit e` stato gia` 
				; azzerato con la CLR.b VHBITS

	BSET.b	#1,VHBITS0	; altrimenti metti a 1 il bit 8 della posizione
				; verticale di fine dello sprite
NOBIGVSTOP:

; copia l'altezza sugli altri sprites

	move.b	vstart0,vstart1	; copia vstart
	move.w	vstop0,vstop1	; copia VSTOP e VHBITS

	move.b	vstart0,vstart2	; copia vstart
	move.w	vstop0,vstop2	; copia VSTOP e VHBITS

	move.b	vstart0,vstart3	; copia vstart
	move.w	vstop0,vstop3	; copia VSTOP e VHBITS

	move.b	vstart0,vstart4	; copia vstart
	move.w	vstop0,vstop4	; copia VSTOP e VHBITS

	move.b	vstart0,vstart5	; copia vstart
	move.w	vstop0,vstop5	; copia VSTOP e VHBITS

	move.b	vstart0,vstart6	; copia vstart
	move.w	vstop0,vstop6	; copia VSTOP e VHBITS

	move.b	vstart0,vstart7	; copia vstart
	move.w	vstop0,vstop7	; copia VSTOP e VHBITS

FineMuovisprites:
	rts

altezza:
	dc.w	$2c

; Questa e` la lista dei valori di priorita`. Potete variarla come volete.
; Dopo l'ultimo valore deve esserci pero` la label EndPriList
; Questi valori verranno scritti in BPLCON2. Notate che a differenza
; dell'esempio lezione7w1.s qui usiamo uno schermo dual playfield, e
; pertanto possiamo usare per ciascun playfield un diverso livello di
; priorita`,
; Vi ricordo che tra gli sprite le priorita` sono fisse e sono in ordine
; decrescente: lo sprite 0 ha la priorita` maggiore, il 7 la minore.

PriList:
	dc.w	$0008	; %001000 - con questo valore le priorita` sono:
			; playfield 1 (sopra tutto)
			; sprite 0 e 1
			; playfield 2
			; sprite 2,3,4,5,6,7 (sotto tutto)

	dc.w	$0010	; %010000 - con questo valore le priorita` sono:
			; playfield 1 (sopra tutto)
			; sprite 0,1,2,3
			; playfield 2
			; sprite 4,5,6,7 (sotto tutto)

	dc.w	$0018	; %011000 - con questo valore le priorita` sono:
			; playfield 1 (sopra tutto)
			; sprite 0,1,2,3,4,5
			; playfield 2
			; sprite 6,7 (sotto tutto)
			
	dc.w	$0020	; %100000 - con questo valore le priorita` sono:
			; playfield 1 (sopra tutto)
			; sprite 0,1,2,3,4,5,6,7
			; playfield 2
			
	dc.w	$0021	; %100001 - con questo valore le priorita` sono:
			; sprite 0 e 1 (sopra tutto)
			; playfield 1
			; sprite 2,3,4,5,6,7
			; playfield 2 (sotto tutto)
			
	dc.w	$0022	; %100010 - con questo valore le priorita` sono:
			; sprite 0,1,2,3 (sopra tutto)
			; playfield 1
			; sprite 4,5,6,7
			; playfield 2 (sotto tutto)
		
	dc.w	$0023	; %100011 - con questo valore le priorita` sono:
			; sprite 0,1,2,3,4,5 (sopra tutto)
			; playfield 1
			; sprite 6,7
			; playfield 2 (sotto tutto)

	dc.w	$0024	; %100100 - con questo valore le priorita` sono:
			; sprite 0,1,2,3,4,5,6,7 (sopra tutto)
			; playfield 1
			; playfield 2 (sotto tutto)
EndPriList:



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

;	abbiamo tolto il BPLCON2 dalla Copperlist, dato che lo variamo
;	col processore "manualmente".

	dc.w	$102,0		; BplCon1
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

	dc.w	$180,$110	; palette playfield 1
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


PIC1:	incbin	"dual1.raw"
PIC2:	incbin	"dual2.raw"

; ************ Ecco gli sprite: OVVIAMENTE in CHIP RAM! ************
MIOSPRITE0:
VSTART0:
	dc.b $60
HSTART0:
	dc.b $60
VSTOP0:
	dc.b $68
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


MIOSPRITE1:
VSTART1:
	dc.b $60
HSTART1:
	dc.b $60+14
VSTOP1:
	dc.b $68
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000010001111
 dc.w	%0011111111111100,%1100000110000011
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0011111111111100,%1100000010000011
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0

MIOSPRITE2:
VSTART2:
	dc.b $60
HSTART2:
	dc.b $60+(14*2)
VSTOP2:
	dc.b $68
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0011111111111100,%1100001000100011
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0111111111111110,%1000000111000001
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0

MIOSPRITE3:
VSTART3:
	dc.b $60
HSTART3:
	dc.b $60+(14*3)
VSTOP3:
	dc.b $68
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0111111111111110,%1000000111100001
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0


MIOSPRITE4:
VSTART4:
	dc.b $60
HSTART4:
	dc.b $60+(14*4)
VSTOP4:
	dc.b $68
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001001001111
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0

MIOSPRITE5:
VSTART5:
	dc.b $60
HSTART5:
	dc.b $60+(14*5)
VSTOP5:
	dc.b $68
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0

MIOSPRITE6:
VSTART6:
	dc.b $60
HSTART6:
	dc.b $60+(14*6)
VSTOP6:
	dc.b $68
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000001001000001
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0

MIOSPRITE7:
VSTART7:
	dc.b $60
HSTART7:
	dc.b $60+(14*7)
VSTOP7:
	dc.b $68
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0

	end

Questo esempio mostra come funzionano le priorita` degli sprite rispetto
ad uno schermo dualplayfield. Per ogni playfield si puo` settare un livello
di priorita` diverso.
Per questo esempio abbiamo usato una lista di valori di priorita`.
Una lista in pratica e` una serie di valori, come una TABELLA.
Con un registro indirizzi (in questo caso a0) puntiamo al primo valore con
l'istruzione:

	lea PriList(PC),a0

Ogni volta che viene letto un valore, il registro a0 viene spostato a puntare
il valore successivo, mediante l'indirizzamento indiretto con postincremento,
ovvero:

	move.w	(a0)+,$dff104	; Mettiamo il valore in BPLCON2

Quando raggiungiamo l'ultimo valore, a0 viene fatto puntare all'indirizzo
di memoria che segue l'ultimo valore. Questo indirizzo e` il valore della
label EndPriList. Quando  a0 diventa uguale a EndPriList allora abbiamo
raggiunto la fine della lista, e quindi usciamo dal programma.

Potete cambiare i valori nella lista, sperimentando vari livelli di priorita`.
Per es. se provate con $0011 vedrete gli sprite 0 e 1 sopra tutti e 2 i
playfield, gli sprite 2 e 3 sopra il playfield 2 e sotto l'uno, mentre gli
altri sprite sotto entrambi i playfield.

NOTA: In questo esempio cambiamo la priorita' scrivendo direttamente nel
      registro $dff104 (BPLCON2). Questo e' stato possibile togliendo la
      definizione di tale registro dalla copperlist, ossia la linea:

	dc.w	$104,0	; BPLCON2

     Se provate a rimettere al suo posto questa istruzione copper, sara'
     annullato l'effetto, proprio perche' ogni fotogramma la copperlist
     viene eseguita, e con essa il BPLCON2 viene azzerato.
     Si puo' decidere dunque di modificare certi registri con la copperlist
     e certi altri direttamente col processore, ma vi consiglio di
     modificarli col copper quando e' possibile, dato che potete sincronizzare
     meglio il momento e la linea video adatti per l'accesso al registro.

