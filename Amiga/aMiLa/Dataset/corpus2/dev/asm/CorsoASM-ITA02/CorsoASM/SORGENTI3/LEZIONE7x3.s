
; lezione7x3.s	- Collsioni tra playfield in Dual Playfield mode
; In questo esempio mostriamo le collisioni tra i due playfield.
; Il playfield 1 si muove dall'alto in basso.
; Se il colore 3 del playfield 1 si sovrappone al colore 1 del playfield 2
; viene rilevata una collisione e viene cambiato il colore di sfondo

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

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

	move.w	#$0024,$dff104	; BPLCON2
				; con questo valore gli sprite sono tutti
				; sopra entrambi i playfield

aspetta1:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	aspetta1
aspetta11:
	cmpi.b	#$ff,$dff006	; Ancora Linea 255?
	beq.s	aspetta11

	btst	#6,$bfe001
	beq.s	esci

	bsr.s	MuoviCopper	; Muove il playfield 1
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


; Questa routine muove un playfield in basso. E` la stessa della lezione 5
; solo che spostiamo solo il playfield 1, cioe` solo i bitplanes dispari. 

MuoviCopper:
	LEA	BPLPOINTERS1,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poniamo
	move.w	6(a1),d0	; in d0 - il contrario della routine che
				; punta i bitplanes! Qua invece di mettere
				; l'indirizzo lo prendiamo!!!

	TST.B	SuGiu		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei sub)
	beq.w	VAIGIU
	cmp.l	#PIC1-(40*90),d0	; siamo arrivati abbastanza in ALTO?
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
	sub.l	#40,d0		; sottraiamo 40, ossia 1 linea, facendo
				; scorrere in BASSO la figura
	bra.s	Finito

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	bra.s	Finito		; fara' saltare alla routine VAIGIU

VAIGIU:
	cmpi.l	#PIC1+(40*30),d0	; siamo arrivati abbastanza in BASSO?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	add.l	#40,d0		; Aggiungiamo 40, ossia 1 linea, facendo
				; scorrere in ALTO la figura
	bra.s	finito

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.

Finito:				; PUNTIAMO I PUNTATORI BITPLANES
	LEA	BPLPOINTERS1,A1	; puntatori nella COPPERLIST
	MOVEQ	#1,D1		; numero di bitplanes -1 (qua sono 2)
POINTBP3:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP3	; Rifai D1 volte POINTBP (D1=num of bitplanes)
	rts


;	Questo byte, indicato dalla label SuGiu, e' un FLAG.

SuGiu:
	dc.b	0,0


; Questa routine controlla se c'e` collisione.
; In caso affermativo, cambia il colore dello sfondo
; modificando nella copper list il valore assunto dal registro COLOR00.

CheckColl:
	move.w	$dff00e,d0	; legge CLXDAT ($dff00e)
				; una lettura di questo registro ne provoca
				; anche la cancellazione, per cui conviene
				; copiarselo in d0 e fare i test su d0
	btst.l	#0,d0		; il bit 0 indica la collisione tra playfield
	beq.s	no_coll		; se non c'e` collisione salta

	move.w	#$f00,rileva_collisione ; "accende" il rivelatore (color0)
					; modificando la copperlist (rosso)
	bra.s	ExitColl
	
no_coll:
	move.w	#$000,rileva_collisione ; "spegne" il rivelatore (color0)
					; modificando la copperlist (nero)
ExitColl:
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
	dc.w	$98,%0000001111000111	; CLXCON

; I planes 1,2,3,4 sono attivi per le collisioni (bit 6,7,8,9).
; viene segnalata collisione tra i playfield quando si sovrappongono
; un pixel che ha:	plane 1 = 1 (bit 0)
;       		plane 3 = 1 (bit 2)
; cioe` con il colore 3 del playfield 1
; e un pixel che ha:	plane 2 = 1 (bit 1)
;       		plane 4 = 0 (bit 3)
; cioe` con il colore 1 del playfield 2


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

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	dcb.b	40*90,0	; questo spazio azzerato serve perche' spostandoci
			; a visualizzare piu' in basso e piu' in alto usciamo
			; dalla zona della PIC1 e visualizziamo quello che sta
			; prima e dopo la pic stessa, il che' causerebbe
			; la visualizzazione di byte sparsi di disturbo.
			; mettendo dei byte azzerati in quel punto viene
			; visualizzato $0000, ossia il colore di sfondo.

PIC1:	incbin	"colldual1.raw"
	dcb.b	40*30,0	; vedi sopra

PIC2:	incbin	"colldual2.raw"

	end

In questo esempio mostriamo la collisione tra due playfield. Il meccanismo e`
lo stesso delle collisioni tra gli sprite. Il registro CLXCON viene usato per
indicare quali planes sono attivi per il rilevamento delle collisioni. Come
al solito e` possibile indicare quali planes sono attivi, e quali valori
devono assumere affinche` la collisione sia rilevata.
Nell'esempio rileviamo le collisioni tra colore 3 del playfield 1 e colore 1 
del playfield 2. Se modificate la copperlist cambiando il valore di CLXCON,
potete rivelare altri tipi di collisione. Ad esempio provate cosi`:

	dc.w	$98,%0000001111000110	; CLXCON

 I planes 1,2,3,4 sono attivi per le collisioni (bit 6,7,8,9).
 Viene segnalata collisione tra i playfield quando si sovrappongono
 un pixel che ha:	plane 1 = 0 (bit 0)
       	        	plane 3 = 1 (bit 2)
 cioe` il colore 2 del playfield 1
 e un pixel che ha:	plane 2 = 1 (bit 1)
               		plane 4 = 0 (bit 3)
 cioe` il colore 1 del playfield 2

Potete rilevare collisioni tra piu` colori non abilitando alcuni planes.
Esempio:

	dc.w	$98,%0000001011000011	; CLXCON

 I planes 1,2 e 4 sono attivi per le collisioni (bit 6,7 e 9).
 Per quant riguarda il playfield 2 sono attivi entrambi i planes pertanto
 verranno considerati i pixel che hanno:	plane 2 = 1 (bit 1)
                                       		plane 4 = 0 (bit 3)
cioe` il colore 1 del playfield 2

Per quanto riguarda il playfield 1 invece e` abilitato solo il plane 1
e il valore del plane 3 non ha importanza.
Verranno considerati sia i pixel che hanno:	plane 0 = 1 (bit 0)
                                       		plane 3 = 0 (bit 2)
 sia i pixel che hanno:                 	plane 0 = 1 (bit 0)
                                       		plane 3 = 1 (bit 2)

Cioe` vengono considerati sia il colore 1 del playfield 1, che il colore 3
del playfield 1.

Per il rilevamento vero e proprio si usa come al solito un bit di CLXDAT.
In questo caso si tratta del bit 0. Se vale 1 c'e` collisione tra i colori 
specificati con CLXCON, altrimenti no.

