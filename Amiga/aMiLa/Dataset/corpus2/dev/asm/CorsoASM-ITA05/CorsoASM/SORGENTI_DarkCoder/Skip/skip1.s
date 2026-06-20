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
		* Coded by:                        *
		* The Dark Coder / Morbid Visions  *
		************************************

; commenti alla fine del sorgente

	SECTION	DK,code

	incdir	"/Include/"
	include	MVstartup.s		; Codice di startup: prende il
					; controllo del sistema e chiama
					; la routine START: ponendo
					; A5=$DFF000

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA


START:

	move	#DMASET,dmacon(a5)
	move.l	#COPPERLIST,cop1lc(a5)
	move	d0,copjmp1(a5)

	move.l	#copperloop,cop2lc(a5)	; carica l'indirizzo del loop
					; in COP2LC

mouse:

	bsr	MuoviCopper

; notare il doppio controllo sulla sincronia
; necessario perche` la muovicopper richiede MENO di UNA rasterline su 68030
	move.l	#$1ff00,d1	; bit per la selezione tramite AND
	move.l	#$13000,d2	; linea da aspettare = $130, ossia 304
.Waity1
	move.l	vposr(a5),d0	; vposr e vhposr
	and.l	d1,d0		; seleziona solo i bit della pos. verticale
	cmp.l	d2,d0		; aspetta la linea $130 (304)
	bne.s	.waity1

.Waity2
	move.l	vposr(a5),d0
	and.l	d1,d0
	cmp.l	d2,d0
	beq.s	.waity2

	btst	#6,$bfe001		; attendi tasto mouse
	bne.s	mouse

	rts

************************************************
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

	SECTION	COPPER,DATA_C

COPPERLIST:

; barra 1
	dc.l $01800111
	dc.l $2907fffe
	dc.l $01800a0a
	dc.l $2a07fffe
	dc.l $0180011f
	dc.l $2b07fffe
	dc.l $01800000

	dc.w	$3007,$FFFE	; aspetta la linea $30

copperloop:			; da qui inizia il loop
	dc.w	$0007,$87fe	; aspetta inizio linea 0 - poiche` sono
				; mascherati i bit da 3 a 7 della posizione
				; verticale, questa wait aspettera` tutte le
				; linee che hanno i bit da 0 a 2 azzerati
				; cioe` le linee $30,$38,$40,$48, ecc
	dc.w	$180,$080
	dc.w	$0107,$87fe	; aspetta inizio linea 1 - poiche` sono
				; mascherati i bit da 3 a 7 della posizione
				; verticale, questa wait aspettera` tutte le
				; linee che hanno i bit da 0 a 2 al valore %001
				; cioe` le linee $31,$39,$41,$49, ecc
	dc.w	$180,$0a0
	dc.w	$0207,$87fe
	dc.w	$180,$0c0
	dc.w	$0307,$87fe
	dc.w	$180,$0e0
	dc.w	$0407,$87FE
	dc.w	$180,$0c0
	dc.w	$0507,$87FE
	dc.w	$180,$0a0
	dc.w	$0607,$87FE
	dc.w	$180,$080
	dc.w	$0707,$87FE
	dc.w	$180,$088
	dc.w	$00e1,$80FE	; aspetta la fine dell'ultima riga del loop
				; questa istruzione e` necessaria, in quanto
				; se la WAIT della linea 0 viene eseguita
				; prima della fine della linea 7 non blocca

	dc.w	$6007,$ffff	; SKIP alla linea $60
	dc.w	$8a,0		; scrive in COPJMP2 - salta ad inizio loop

	dc.w	$180,$000
	dc.w $FFDF,$FFFE	; aspetta la linea 255

; barra 2
	dc.l $01800000
	dc.l $1407fffe
	dc.l $0180011f
	dc.l $1507fffe
	dc.l $01800a0a
	dc.l $1607fffe
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
