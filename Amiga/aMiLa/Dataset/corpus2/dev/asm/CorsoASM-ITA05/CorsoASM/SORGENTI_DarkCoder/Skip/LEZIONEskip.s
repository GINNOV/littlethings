
; Lezione skip
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

	move.l	#copperloop,$84(a5)	; carica l'indirizzo del loop
					; in COP2LC

mouse:

	bsr	MuoviCopper

; notare il doppio controllo sulla sincronia
; necessario perche` la muovicopper richiede MENO di UNA rasterline su 68030
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
	CMPI.L	D2,D0		; aspetta la fine della linea $130 (304)
	BEQ.S	Waity2

	btst	#6,$bfe001		; tasto sinistro del mouse premuto?
	bne.s	mouse			; se no, torna a mouse:

	rts

* Questa routine cicla i colori nella copperlist
MuoviCopper:
	lea	copperloop,a0

	move.w	6(a0),d0

	moveq	#7-1,d1		; vengono ciclati solo 8 colori
.loop	move.w	14(a0),6(a0)
	addq.l	#8,a0
	dbra	d1,.loop

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

copperloop			; da qui inizia il loop
	dc.w	$0007,$07fe	; aspetta inizio linea 0 - poiche` sono
				; mascherati i bit da 3 a 7 della posizione
				; verticale, questa wait aspettera` tutte le
				; linee che hanno i bit da 0 a 2 azzerati
				; cioe` le linee $30,$38,$40,$48, ecc
	dc.w	$180,$080
	dc.w	$0107,$07fe	; aspetta inizio linea 1 - poiche` sono
				; mascherati i bit da 3 a 7 della posizione
				; verticale, questa wait aspettera` tutte le
				; linee che hanno i bit da 0 a 2 al valore %001
				; cioe` le linee $31,$39,$41,$49, ecc
	dc.w	$180,$0a0
	dc.w	$0207,$07fe
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
	dc.w	$00e1,$00FE	; aspetta la fine dell'ultima riga del loop
				; questa istruzione e` necessaria, in quanto
				; se la WAIT della linea 0 viene eseguita
				; prima della fine della linea 7 non blocca

	dc.w	$6007,$ffff	; SKIP alla linea $60
	dc.w	$8a,0		; scrive in COPJMP2 - salta ad inizio loop

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

Questo esempio mostra un uso dei copperloop. Vogliamo realizzare una copperlist
che cambi il COLOR00 ad ogni linea di raster. Come avete imparato nelle prime
lezioni del corso, e` sufficente scrivere una copperlist che faccia una wait
ad ogni riga seguita da una coppermove nel registro COLOR00. Se per esempio
vogliamo cambiare il COLOR00 dalla linea $30 alla linea $60 dobbiamo scrivere
le seguenti istruzioni nella copperlist:

	dc.w	$3007,$fffe	; aspetta la linea $30
	dc.w	$180,$345	; scrive nel color00
	dc.w	$3107,$fffe	; aspetta la linea $31
	dc.w	$180,$456	; scrive nel color00
	
	.
	.

	dc.w	$6007,$fffe	; aspetta la linea $60
	dc.w	$180,$000	; scrive nel color00

Questo pezzo di copperlist occupa 4 word per ogni riga di raster, per un
totale di 8*($60-$30)=384 bytes. Se vogliamo far scorrere i colori, dobbiamo
usare una routine 68000 che legga tutti i colori e li riscriva, tipo la routine
MuoviCopper di questo esempio. Tale routine dovra` eseguire un'iterazione per
ogni linea di raster, nel nostro caso dunque $30=48 iterazioni.
Se i colori da scrivere in COLOR00 sono tutti diversi questo e` l'unico metodo
possibile. Se pero` i colori non sono diversi ma si ripetono dopo un po' e`
possibile usare un copperloop. Nel nostro esempio, vogliamo ripetere una
sequenza di 8 colori. Poiche` il nostro effetto va dalla riga $30 alla $60
(48 righe) vuol dire che ripetiamo la stessa sequenza 6 volte. Possiamo 
quindi scrivere un copperloop che ripeta gli 8 colori e farlo ripetere
dalle linee $30 a $60. Il loop (che potete vedere nel listato) occupa 
4 word per ogni colore che scrive, piu` altre 3 istruzioni che occupano
ciascuna 2 words (la WAIT fino alla fine dell'ultima riga, la SKIP e quella
che scrive in COPJMP2), per un totale di 8*4+3*2=38 words ovvero 56 bytes,
contro i 384 della copperlist senza loop. Inoltre la routine che cicla i
colori deve fare solamente 8 iterazioni contro le 48 del caso "tradizionale",
ovvero va circa 6 volte piu` veloce.

