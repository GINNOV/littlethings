
; Lezione11h2.s	- Routine che genera delle barre sfumate - USARE IL TASTO
;		  DESTRO DEL MOUSE PER AUMENTARE l'ALTEZZA DELLE BARRE.

	SECTION	Barrex,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

LINEE:	equ	211

START:
	bsr.s	FaiCopp1

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#OURCOPPER,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10500,d2	; linea da aspettare = $105
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $105
	BNE.S	Waity1

 	BSR.s	changecop	; chiama la routine che cambia il copper

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
; routine che crea la copperlist
*****************************************************************************

FaiCopp1:
	LEA	copcols,a0	; indirizzo buffer in copperlist
	MOVE.L	#$2c07fffe,d1	; istruzione copper wait, che inizia
				; attendendo alla linea $2c
	MOVE.L	#$1800000,d2	; $dff180 = colore 0 per il copper
	MOVE.w	#LINEE-1,d0	; numero di linee per il loop
	MOVEQ	#$000,d3	; colore da mettere = nero
coploop:
	MOVE.L	d1,(a0)+	; Metti il WAIT
	MOVE.L	d2,(a0)+	; Metti il $180 (color0) azzerato al NERO
	ADD.L	#$01000000,d1	; Fai aspettare il WAIT 1 linea dopo
	DBRA	d0,coploop	; ripeti fino alla fine delle linee
	rts

*****************************************************************************
; routine che cambia i colori nella copperlist
*****************************************************************************

;	            ________________________
;	           /                        \
;	  ___   ___\       ehHHHHhHh?        \
;	 /_  ¯¯¯  _\\_ ______________________/
;	 \ \_____/ / / /
;	  \_(°I°)_/ / /
;	  _l_¯U¯_l_ \/
;	 /  T¯¬¯T  \
;	/ _________ \ xCz
;	¯¯         ¯¯

changecop:
	btst	#2,$dff016	; tasto destro premuto?
	bne.s	noadd		; se no, salta a noadd
	cmp.b	#$24,barlen	; altrimenti controlla se siamo gia' a $24
	beq.s	noadd		; in tal caso salta a noadd
	addq.b	#1,barlen	; oppure ingrandisci la barra (BARLEN)
noadd:
	LEA	copcols,a0	; indirizzo buffer in copperlist
	MOVE.w	#LINEE-1,d0	; numero linee per il loop
	MOVE.L	PuntatoreTABCol(PC),a1	; inizio della tabella colori in a1
	move.l	a1,PuntatTemporaneo	; salvato nel PuntatoreTemporaneo
	moveq	#0,d1			; azzero d1
LineeLoop:
	move.w	(a1)+,6(a0)	; copia il colore dalla tabella alla copperlist
	addq.w	#8,a0		; prossimo color0 in copperlist
 	addq.b	#1,d1		; annoto in d1 la lunghezza della sotto-barra
 	cmp.b	barlen(PC),d1	; fine della sotto-barra?
	bne.s	AspettaSottoBarra

	MOVE.L	PuntatTemporaneo(PC),a1
	addq.w	#2,a1			; punto al colore dopo
	cmp.l	#FINETABColBarra,PuntatTemporaneo	; siamo a fine tab?
	bne.s	NonRipartire		; se non ancora, vai a NonRipartire
	lea	TABColoriBarra(pc),a1	; altrimenti riparti dal primo col!
NonRipartire:
	move.l	a1,PuntatTemporaneo	; e salva il valore nel Pun. temporaneo
	moveq	#0,d1			; azzero d1
AspettaSottoBarra:
	dbra d0,LineeLoop	; fai tutte le linee


	addq.l	#2,PuntatoreTABCol		 ; prossimo colore
	cmp.l	#FINETABColBarra+2,PuntatoreTABCol ; siamo alla fine della
						 ; tabella colori?
	bne.s FineRoutine			 ; se no, esci, altrimenti...
	move.l #TABColoriBarra,PuntatoreTABCol	 ; riparti dal primo valore di
						 ; TABColoriBarra
FineRoutine:
	rts

;	altezza barre

barlen:
	dc.b	1

	even


;	Tabella con i valori RGB dei colori. in questo caso sono toni di BLU

TABColoriBarra:
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$008,$009,$00A,$00B,$00C,$00D,$00D,$00E
	dc.w	$00E,$00F,$00F,$00F,$00E,$00E,$00D,$00D
	dc.w	$00C,$00B,$00A,$009,$008,$007,$006,$005
	dc.w	$004,$003,$002,$001,$000,$000,$000,$000
	dcb.w	10,$000
FINETABColBarra:
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007	; questi valori servono
	dc.w	$008,$009,$00A,$00B,$00C,$00D,$00D,$00E ; per le sotto-barre
	dc.w	$00E,$00F,$00F,$00F,$00E,$00E,$00D,$00D
	dc.w	$00C,$00B,$00A,$009,$008,$007,$006,$005
	dc.w	$004,$003,$002,$001,$000,$000,$000,$000


PuntatTemporaneo:
 	dc.l	TABColoriBarra

PuntatoreTABCol:
 	DC.L	TABColoriBarra

*****************************************************************************

	Section	Coppy,data_C

OURCOPPER:
	dc.w	$180,$000	; Color0 nero
	dc.w	$100,$200	; bplcon0 - no bitplanes

copcols:
	dcb.b	LINEE*8,0	; spazio per 100 linee in questo formato:
				; WAIT xx07,$fffe
				; MOVE $xxx,$180	; color0
	dc.w	$ffdf,$fffe
	dc.w	$0107,$fffe
	dc.w	$180,$010
	dc.w	$0207,$fffe
	dc.w	$180,$020
	dc.w	$0307,$fffe
	dc.w	$180,$030
	dc.w	$0507,$fffe
	dc.w	$180,$040
	dc.w	$0707,$fffe
	dc.w	$180,$050
	dc.w	$0907,$fffe
	dc.w	$180,$060
	dc.w	$0c07,$fffe
	dc.w	$180,$070
	dc.w	$0f07,$fffe
	dc.w	$180,$080
	dc.w	$1207,$fffe
	dc.w	$180,$090
	dc.w	$1507,$fffe
	dc.w	$180,$0a0

	dc.w	$180,$000	; color0 nero
	dc.w	$FFFF,$FFFE	; Fine della copperlist
 
	end

