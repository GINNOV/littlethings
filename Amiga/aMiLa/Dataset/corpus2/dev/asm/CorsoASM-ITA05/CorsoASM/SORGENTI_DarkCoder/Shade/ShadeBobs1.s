		************************************
		*       /\/\                       *
		*      /    \                      *
		*     / /\/\ \ O R B_I D           *
		*    / /    \ \   / /              *
		*   / /    __\ \ / /               *
		*   ¯¯     \ \¯¯/ / I S I O N S    *
		*           \ \/ /                 *
		*            \  /                  *
		*             \/                   *
		*     Feel the DEATH inside!       *
		************************************

; Codice di autori sconosciuti adattato e migliorato da
; DeathBringer/Morbid Visions 

***********************************************************
* Shade Bobs
*
* La routine dello ShadeBob e' essenzialmente una implementazione della
* capacita' del blitter di effettuare addizioni. Basta pensare ad ogni
* pixel dello schermo sia un numero ad n cifre binarie
* (dove n e' il numero dei bitplane), e quindi bisogna addizionare 1 a questo 
* numero. Il nostro bob ad 1 bitplane, rappresenta la maschera che indica quali
* pixel sono interessati all'addizione in un determinato quadro.
* Per prima cosa si prendono il bob e l'area di schermo interessata e si
* effettua un AND usando come destinazione un'area addizionale chiamata Carry.
* Fatto questo si prende il bob e si effettua lo XOR con l'appropriato 
* bitplane dello schermo. In seguito si continua usando l'area Carry come se
* fosse il nostro bob per ogni bitplane. 
* Chiaramente sono necessarie 2 aree Carry!!!
************************************************************

	section	ShadeBobs,code

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA

WaitBlit:	macro
.\@	btst.b	#6,dmaconr(a5)	; niente test preliminare
	bne.s	.\@		; si tratta di un bug OCS
	endm
	
WaitRast:	macro			; Attendi una Linea di Raster
.\@	move.l	vposr(a5),d0
	lsr.l	#8,d0
	and.w	#$1FF,d0
	cmp.w	#\1,d0
	bne.b	.\@
	endm

	incdir	"/Include/"
	include	MVstartup.s		; Codice di startup: prende il
					; controllo del sistema e chiama
					; la routine START: ponendo
					; A5=$DFF000

START:

	lea	BmapPtrs-2,a0		; Inserisci ^Bitplanes
                                        ; nella COPPERLIST
        move.l  #Bmap,d0
        moveq.l	#5-1,d1
.loop	addq.l	#4,a0
        swap d0
        move.w  d0,(a0)
        addq.l	#4,a0
        swap    d0
        move.w	d0,(a0)
        add.l	#8000,d0
        dbra    d1,.loop

; A5 e` inizializzato al valore $DFF000 (base registri hardware) nella
; routine di startup
	move.l	#Copper,cop1lc(A5)	; copperlist
	move.w	#DMASET,dmacon(A5)	; Copper+Blitter+Bplanes

MAIN:	
	WaitRast	$0f4		;aspetta la linea di raster 244

	move.l	x_ptr(pc),a3		;Copia puntatori alle tabelle x e y
	move.l	y_ptr(pc),a4		;in a3 e in a4 rispettivamente

	cmp.l	xl_ptr(pc),a3		;Fine tabella delle x?
	bne.b	.xok			;no
	move.l	xr_ptr(pc),a3		;si, resetta il puntatore
.xok:
	cmp.l	yl_ptr(pc),a4	;Fine della tabella delle y?
	bne.b	.yok		;no
	move.l	yr_ptr(pc),a4	;si, resetta puntatore
.yok:
	moveq	#0,d0		;Cancella
	moveq	#0,d1		;d1 e d0

	move.b	(a3)+,d0	;d0=x/2	(Vedi nota)
	move.b	(a4)+,d1	;d1=y
	add.w	d0,d0		;d0=x
	move.l	a3,x_ptr	;aggiorna puntatori
	move.l	a4,y_ptr	;delle tabelle x e y
	bsr	ShadeBob	salta alla routine di Shade

	moveq	#0,d0
	moveq	#0,d1
	move.b	10(a3),d0	;nuova coordinata x
	move.b	(a4),d1		;stessa coordinata y
	add.w	d0,d0
	bsr	ShadeBob

	moveq	#0,d0
	moveq	#0,d1
	move.b	(a3),d0		;stessa coordinata x
	move.b	10(a4),d1	;nuova coordinata y
	add.w	d0,d0
	bsr	ShadeBob

	btst	#6,$BFE001	; bottone sinistro del mouse premuto?
	bne.w	MAIN		;no, continua
	rts			;si, esci

***********************************************************
* Shade Bob
* d0 : x
* d1 : y

ShadeBob:

	movem.l	d0-d5/a0-a3,-(a7)
	move.l	d0,d2	; copia d0 in d2
	lsr.w	#4,d2	; d2=word offset
	add.w	d2,d2	; che contiene il pixel nella posizione 'x'

	andi.l	#$f,d0	; i quattro bit alti di d0 
	ror.l	#4,d0	; contengono lo shift per il blitter 

	mulu	#40,d1	; d1=offset nella bitmap
			; che e' la linea 'y' (ogni linea 40 bytes)
	add.w	d1,d2	; offset totale

	lea	Bob,a0
	lea	Bmap,a1
	lea	Carry1,a2
	lea	Carry2,a3

	adda.l	d2,a1	; posizione del bob nella bitmap

	moveq	#0,d2	; modulo
	moveq	#$22,d3	; modulo  (40-6)
	move.w	#(31<<6)+3,d5	; bltsize, Bob=31*(32+16) pixels

	move.l	#$0ba00000,d4	;abilita il dma dei canali ACD, setta lo shift
	or.l	d0,d4		;x il canale A e calcola la funzione d=a AND c
	
	move.w	#$8400,dmacon(a5)	;Blitternasty ON
		
	WaitBlit
	move.l	a0,bltapt(A5)	; canale A=bob
	move.l	a1,bltcpt(A5)	; canale C=Bitmap
	move.l	a2,bltdpt(A5)	; canale D=Carry1
	move.w	d3,bltcmod(A5)	; bltcmod=$22
	move.l	d2,bltamod(A5)	; bltamod e bltdmod=0
	move.l	d4,bltcon0(A5)	; bltcon0&bltcon1
 	move.w	d5,bltsize(A5)	; bltsize

	move.l	#$0b5a0000,d4	; d = a EOR c
	or.l	d0,d4
	
	WaitBlit
	move.l	a0,bltapt(A5)	; canale A=bob
	move.l	a1,bltcpt(A5)	; canale C=Bitmap
	move.l	a1,bltdpt(A5)	; canale D=bitmap
	move.w	d3,bltdmod(A5)	; bltdmod=$22 - gli altri moduli sono costanti
	move.l	d4,bltcon0(A5)	; nuova funzione minterms
 	move.w	d5,bltsize(A5)

	moveq	#4-1,d7		;Bitplane rimanenti
; Adesso l'area Carry indirizzata da a2 diventa il nostro Bob, e l'area	
; carry indirizzata da a3 diventa la nostra area Carry vera e propria

.1
	adda.l	#8000,a1	;prossimo bitplane
	move.w	#$0ba0,d4	; d = a AND c

	WaitBlit
	move.l	a2,bltapt(A5)	; canale A=Carry1
	move.l	a1,bltcpt(A5)	; canale C=Bitmap
	move.l	a3,bltdpt(A5)	; canale D=Carry2
	move.w	d3,bltcmod(A5)	; bltcmod=$22
	move.w	d2,bltdmod(A5)	; bltdmod=0
	move.w	d4,bltcon0(A5)
 	move.w	d5,bltsize(A5)

	move.w	#$0b5a,d4	; d = a EOR c
	
	WaitBlit
	move.l	a2,bltapt(A5)	; canale A=Carry1
	move.l	a1,bltcpt(A5)	; canale C=Bitmap
	move.l	a1,bltdpt(A5)	; canale D=Bitmap
	move.w	d3,bltdmod(A5)	; bltdmod=$22
	move.w	d4,bltcon0(A5)
 	move.w	d5,bltsize(A5)

	exg	a2,a3		;Scambia le due aree Carry
	dbf	d7,.1

	move.w	#$0400,dmacon(a5)	;Disabilita Blitternasty
	movem.l	(a7)+,d0-d5/a0-a3
	rts


***********************************************************************
;	DATI CHE NON VANNO IN CHIPRAM

x_ptr:	dc.l	Sine1	;Puntatore tabella delle x
y_ptr:	dc.l	Sine2	;Puntatore tabella delle y
xr_ptr:	dc.l	Sine1	;Indirizzo di START tabella delle x
yr_ptr:	dc.l	Sine2	;Indirizzo di START tabella delle y
xl_ptr:	dc.l	Sine1e	;Indirizzo di END tabella delle x
yl_ptr:	dc.l	Sine2e	;Indirizzo di END tabella delle y

;NOTA:	le coordinate delle x sono memorizzate divise per 2 in modo che 
;	abbiano dimensione 1 byte. 

Sine1:
	dc.b	$46,$43,$41,$3E,$3C,$39,$37,$35,$32,$30,$2D,$2B
	dc.b	$29,$27,$25,$22,$20,$1E,$1C,$1A,$18,$17,$15,$13
	dc.b	$11,$10,14,13,11,10,9,8,6,5,5,4,3,2,2,1,1,0,0,0,0
	dc.b	0,0,0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,12,13,15,$10
	dc.b	$12,$13,$15,$17,$19,$1B,$1D,$1F,$21,$23,$25,$27
	dc.b	$29,$2C,$2E,$30,$33,$35,$37,$3A,$3C,$3F,$41,$44
	dc.b	$46,$49,$4B,$4D,$50,$52,$55,$57,$59,$5C,$5E,$60
	dc.b	$63,$65,$67,$69,$6B,$6D,$6F,$71,$73,$75,$77,$78
	dc.b	$7A,$7C,$7D,$7F,$80,$81,$83,$84,$85,$86,$87,$88
	dc.b	$88,$89,$8A,$8A,$8B,$8B,$8B,$8B,$8B,$8B,$8B,$8B
	dc.b	$8B,$8B,$8A,$8A,$89,$89,$88,$87,$86,$85,$84,$83
	dc.b	$82,$80,$7F,$7E,$7C,$7A,$79,$77,$75,$74,$72,$70
	dc.b	$6E,$6C,$6A,$68,$65,$63,$61,$5F,$5C,$5A,$58,$55
	dc.b	$53,$51,$4E,$4C,$49,$47
Sine1e:
	dc.b	$46,$43,$41,$3E,$3C,$39,$37,$35,$32,$30,$2D,$2B

Sine2:
	dc.b	$46,$43,$41,$3F,$3D,$3A,$38,$36,$34,$32,$2F,$2D
	dc.b	$2B,$29,$27,$25,$23,$21,$1F,$1E,$1C,$1A,$18,$17
	dc.b	$15,$13,$12,$10,15,13,12,11,10,9,8,6,6,5,4,3,2,2
	dc.b	1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,3,4,5,5,6,7,8
	dc.b	10,11,12,13,15,$10,$11,$13,$15,$16,$18,$1A,$1B
	dc.b	$1D,$1F,$21,$23,$25,$27,$29,$2B,$2D,$2F,$31,$33
	dc.b	$36,$38,$3A,$3C,$3E,$41,$43,$45,$47,$4A,$4C,$4E
	dc.b	$50,$52,$55,$57,$59,$5B,$5D,$5F,$61,$63,$65,$67
	dc.b	$69,$6B,$6D,$6F,$71,$73,$74,$76,$77,$79,$7A,$7C
	dc.b	$7D,$7F,$80,$81,$82,$83,$84,$85,$86,$87,$88,$88
	dc.b	$89,$8A,$8A,$8B,$8B,$8B,$8B,$8B,$8B,$8B,$8B,$8B
	dc.b	$8B,$8B,$8A,$8A,$89,$89,$88,$87,$87,$86,$85,$84
	dc.b	$83,$82,$81,$7F,$7E,$7D,$7B,$7A,$78,$77,$75,$73
	dc.b	$72,$70,$6E,$6C,$6A,$68,$67,$65,$63,$60,$5E,$5C
	dc.b	$5A,$58,$56,$54,$51,$4F,$4D,$4B,$49,$46
Sine2e:
	dc.b	$46,$43,$41,$3F,$3D,$3A,$38,$36,$34,$32,$2F,$2D

***********************************************************

	section	THEDATA,data_c	

Copper:	
	dc.l	$1fc0000,$1060c00	;resetta AGA se presente, altrimenti
					;nessun significato
	
	; Setta DataFetch e grandezza display
	dc.l	$00920038,$009400D0,$008E2C81,$0090F4C1	 
	; Bplcon0, bplcon1, e moduli
	dc.l	$01005200,$01020000,$01080000,$010A0000
	; colori
	dc.l	$01800000,$01820003,$01840004,$01860005,$01880006,$018a0007
	dc.l	$018c0008,$018e0009,$0190000a,$0192000b,$0194000c,$0196000d
	dc.l	$0198000e,$019a000f,$019c020f,$019e030f,$01a0040f,$01a2050f
	dc.l	$01a4060f,$01a6070e,$01a8080d,$01aa090c,$01ac0a0b,$01ae0b0a
	dc.l	$01b00c09,$01b20d08,$01b40e07,$01b60f06,$01b80e35,$01ba0d44
	dc.l	$01bc0c53,$01be0b62
	; Puntatori BitPlanes 
BmapPtrs:dc.l	$00E00000,$00E20000,$00E40000,$00E60000,$00E80000,$00EA0000
	dc.l	$00EC0000,$00EE0000,$00F00000,$00F20000,$00F40000,$00F60000
	dc.l	-2,-2

Bob:	; La nostra Immagine
	dc.l	0,15,$E0000000,$7FFC00,$1FF,$FF000000,$3FFFF80
	dc.l	$7FF,$FFC00000,$FFFFFE0,$1FFF,$FFF00000,$1FFFFFF0
	dc.l	$3FFF,$FFF80000,$3FFFFFF8,$3FFF,$FFF80000
	dc.l	$7FFFFFFC,$7FFF,$FFFC0000,$7FFFFFFC,$7FFF
	dc.l	$FFFC0000,$7FFFFFFC,$7FFF,$FFFC0000,$7FFFFFFC
	dc.l	$3FFF,$FFF80000,$3FFFFFF8,$3FFF,$FFF80000
	dc.l	$1FFFFFF0,$1FFF,$FFF00000,$FFFFFE0,$7FF,$FFC00000
	dc.l	$3FFFF80,$1FF,$FF000000,$7FFC00,15,$E0000000,0

***********************************************************

	section	thpt,bss_c

Carry1:	ds.w	31*3	; Prima area carry
Carry2:	ds.w	31*3	; Seconda area carry
Bmap:	ds.b	8000*5	; Memoria Video
