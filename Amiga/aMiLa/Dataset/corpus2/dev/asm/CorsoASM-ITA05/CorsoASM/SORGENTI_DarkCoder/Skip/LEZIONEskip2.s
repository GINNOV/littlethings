
; Lezione skip2
;		Tasto sinistro per uscire.

	SECTION	bau,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper,bitplane,blitter DMA

Waitdisk	EQU	10

START:

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	move.l	#copperloop,d0
	move	d0,cpptr1+6
	swap	d0
	move	d0,cpptr1+2

	move.l	#copperloop2,d0
	move	d0,cpptr2+6
	swap	d0
	move	d0,cpptr2+2

mouse:

	bsr	MuoviCopper

	moveq	#20-1,d7

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Waity2

	btst	#6,$bfe001		; tasto sinistro del mouse premuto?
	bne.s	mouse			; se no, torna a mouse:

	rts

MuoviCopper:
	lea	copperloop,a0

	move.w	6(a0),d0

	moveq	#7-1,d1
.loop	move.w	14(a0),6(a0)
	addq.l	#8,a0
	dbra	d1,.loop

	move.w	d0,6(a0)

	lea	copperloop2,a0

	move.w	6(a0),d0

	moveq	#7-1,d1
muoviloop2
	move.w	14(a0),6(a0)
	addq.l	#8,a0
	dbra	d1,muoviloop2

	move.w	d0,6(a0)
	rts

	SECTION	MY_COPPER,CODE_C

COPPERLIST:

; barra 1
	dc.l $01800111
	dc.l $2901fffe
	dc.l $01800a0a
	dc.l $2a01fffe
	dc.l $0180011f
	dc.l $2b01fffe
	dc.l $01800000

	dc.w	$3007,$FFFE	; aspetta la linea $30

cpptr1
	dc.w	$084,0
	dc.w	$086,0

copperloop			; questo loop viene eseguito al di sopra 
	dc.w	$0007,$07fe	; della riga $80. Tutte le WAIT hanno
	dc.w	$180,$080	; il bit piu` significativo della posizione
	dc.w	$0107,$07fe	; verticale a 0
	dc.w	$180,$0a0
	dc.w	$0207,$07fe	; WAIT alla riga 2 con bit + significativo a 0
	dc.w	$180,$0c0
	dc.w	$0307,$07fe
	dc.w	$180,$0e0
	dc.w	$0407,$07FE
	dc.w	$180,$0c0
	dc.w	$0507,$07FE
	dc.w	$180,$0a0
	dc.w	$0607,$07FE
	dc.w	$180,$080
	dc.w	$0707,$07FE
	dc.w	$180,$088
	dc.w	$00e1,$00FE
	dc.w	$8007,$ffff
	dc.w	$8a,0

cpptr2
	dc.w	$084,0
	dc.w	$086,0

copperloop2			; questo loop viene eseguito al di sotto 
	dc.w	$8007,$07fe	; della riga $80. Tutte le WAIT hanno
	dc.w	$180,$080	; il bit piu` significativo della posizione
	dc.w	$8107,$07fe	; verticale a 1
	dc.w	$180,$0a0
	dc.w	$8207,$07fe	; WAIT alla riga 2 con bit + significativo a 1
	dc.w	$180,$0c0
	dc.w	$8307,$07fe
	dc.w	$180,$0e0
	dc.w	$8407,$07FE
	dc.w	$180,$0c0
	dc.w	$8507,$07FE
	dc.w	$180,$0a0
	dc.w	$8607,$07FE
	dc.w	$180,$080
	dc.w	$8707,$07FE
	dc.w	$180,$088
	dc.w	$80e1,$00FE
	dc.w	$b007,$ffff
	dc.w	$8a,0

	dc.w	$180,$000
	dc.w $FFDF,$FFFE	; aspetta la linea 255

; barra 2
	dc.l $01800000
	dc.l $1401fffe
	dc.l $0180011f
	dc.l $1501fffe
	dc.l $01800a0a
	dc.l $1601fffe
	dc.l $01800111

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end

Questo esempio mostra la necessita` di usare 2 copper loop a causa
dell'impossibilita` di mascherare il bit piu` significativo della posizione
verticale. Usiamo 2 loop che sono assolutamente identici, salvo per il
valore del bit piu` significativo delle WAIT, che vale 0 per il loop eseguito
al di sopra della linea $80 e invece 1 nell'altro.
La necessita` di usare 2 loop ci costringe naturalemte a variare l'indirizzo
contenuto in COP2LC, che deve essere ogni volta l'indirizzo del loop
giusto. Poiche` bisogna caricare COP2LC in maniera sincronizzata al video,
lo facciamo tramite il copper. Carichiamo COP2LC esattamente allo stesso
modo degli altri registri puntatori (BPLxPT, SPRxPT, ecc.) tramite la
copperlist. PRIMA di entrare in un loop, l'indirizzo del loop viene scritto
in COP2LC.
Notate che poiche` usiamo 2 loop la routine processore deve far ruotare i
colori in entrambi i loop. Nonostante cio`, questa tecnica risulta sempre
vantaggiosa rispetto alla tecnica che non fa uso di loop: in questo esempio
realizziamo l'effetto dalla riga $30 alla $b0, per un totale di 128 righe,
che con la tecnica "tradizionale" richiederebbero 128 iterazioni alla routine
che cicla i colori. Grazie ai loop ce la caviamo con 16 iterazioni (8 per ogni
loop), andando quindi ben 8 volte piu` veloci.

