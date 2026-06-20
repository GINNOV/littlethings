
; Lezione11h3.s	- Effetto copper PRECALCOLATO!!! 50 copperlist precalcolate
;		  e visualizzate in sequenza usando COP2LC ($dff084).

	SECTION	BarrexPrecalc,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	bsr.w	precalcop	; Routine che precalcola 50 copperlist per
				; fare un "loop" completo dell'effetto

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
	MOVE.L	#$12000,d2	; linea da aspettare = $120
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $120
	BNE.S	Waity1

	btst	#2,$dff016	; tasto destro premuto?
	beq.s	Mouse2		; se si non eseguire SwappaCoppero

	bsr.w	SwappaCoppero	; Fai puntare alla prossima copperlist per
				; la corretta "animazione" dell'effetto.

mouse2:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12000,d2	; linea da aspettare = $120
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $120
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts


******************************************************************************
; Routine di SWAP delle copperlist precalcolate.. (un'animazione!!!)
******************************************************************************

;	      \||||/
;	      (·)(·)
;	   ___\ \/ /___
;	  (_   \__/   _)
;	  /   .        \
;	 /    |Stz!\_   \
;	(_____| ___(_____)
;	 (___)      (___)
;	   ¡   \_    ¡
;	   |_   |   _|
;	   |    ;    |
;	   |    |    |
;	 __(____|____)__
;	(_______:_______)
 

SwappaCoppero:
	MOVE.L	copbufpunt(PC),D0
	lea	coppajumpa,a0	; indirizzo puntatori al cop2 in coplist
	MOVE.W	D0,6(A0)	; fai puntare all'attuale fotogramma
	SWAP	D0
	MOVE.W	D0,2(A0)
	ADD.L	#(linee*8)+AGGIUNTE,COPBUFPUNT	; punta alla PROSSIMA COP
	MOVE.L	copbufpunt(PC),D0
	cmp.l	#finebuffoni,d0		; Siamo all'ultima copper?
	bne.w	NonRibuffona		; Se non ancora, ok
	move.l	#copbuf1,copbufpunt	; altrimenti riparti dalla prima!
NonRibuffona:
	rts

******************************************************************************
; 		routine di precalc dell'effetto copper
******************************************************************************

;	/\____/\
;	\(O..O)/
;	 (----)
;	  TTTT Mo!

LINEE		equ	211
AGGIUNTE	equ	20	; LUNGHEZZA PARTI AGGIUNTE IN FONDO...
NUMBUFCOPPERI	equ	50	; numero fotogrammi/copperlist!!!

PrecalCop:

; Ora creiamo le copperlist.

	lea	copbuf1,a0		; Indirizzo buffers dove fare cops
	move.w	#NUMBUFCOPPERI-1,d7	; numero di copperlist da precalcolare
FaiBuf:
	bsr.w	FaiCopp1		; Fai una copperlist
	add.w	#(linee*8)+AGGIUNTE,a0	; punta a quella dopo
	dbra	d7,FaiBuf		; fai tutti i fotogrammi

; Ora le "riempiamo", come se eseguissimo l'effetto in real-time.

	move.w	#NUMBUFCOPPERI-1,d7	; numero cops da "riempire"
	lea	copbuf1,a0		; indirizzo prima copper precalcolata
ribuf:
 	BSR.s	changecop	; chiama la routine che cambia il copper
	add.w	#(linee*8)+AGGIUNTE,a0 ; salta alla prossima da riempire
	dbra	d7,riBuf	; riempi tutte le copperlists


; Infine puntiamo le copperlists nei puntatori in copperlist!!!

	MOVE.L	#copbuf1,D0	; primo "fotogramma" copper2
	lea	coppajumpa,a0	; puntatore alla fine di copper1
	MOVE.W	D0,6(A0)	; puntiamo...
	SWAP	D0
	MOVE.W	D0,2(A0)

	MOVE.L	#ourcopper,D0	; copper1 INIZIO
	lea	coppajumpa2,a0	; puntatore alla fine della "pezzofinale"
	MOVE.W	D0,6(A0)	; a cui salta la copper2.
	SWAP	D0
	MOVE.W	D0,2(A0)
	rts

******************************************************************************
; routine che crea una copperlist
******************************************************************************

FaiCopp1:
	move.l	a0,-(SP)
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
	move.l	finPunt(PC),d0	; pezzofinale, a cui saltano tutte le copper2
				; usate come fotogrammi.
	MOVE.w	#$82,(A0)+	; PARTEFINALE da puntare - COP1LC
	move.w	d0,(a0)+
	swap	d0
	MOVE.w	#$80,(A0)+
	move.w	d0,(a0)+
	move.l	#$880000,(a0)+	; COPJMP1 - salto al pezzo finale, il quale
				; poi ristabilira' copper1 come prima cop!
	move.l	(SP)+,a0
	rts

CopBufPunt:
	dc.l	copbuf1
FinPunt:
	dc.l	pezzofinale

******************************************************************************
; routine che cambia i colori in una copperlist
******************************************************************************

changecop:
	move.l	a0,-(SP)	; salva a0 nello stack
	MOVE.w	#LINEE-1,d0	; numero linee per il loop
	MOVE.L	PuntatoreTABCol(PC),a1	; inizio della tabella colori in a1
	move.l	a1,PuntatTemporaneo	; salvato nel PuntatoreTemporaneo
	moveq	#0,d1			; azzero d1
LineeLoop:
	move.w	(a1)+,6(a0)	; copia il colore dalla tabella alla copperlist
	addq.w	#8,a0		; prossimo color0 in copperlist
	addq.b	#1,d1		; annoto in d1 la lunghezza della sotto-barra
 	cmp.b	#9,d1		; fine della sotto-barra?
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
	move.l	(SP)+,a0	; riprendi a0 dallo stack
	rts

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

***************************************************************************

	SECTION	GRAPH,DATA_C

ourcopper:
Copper2:
	dc.w	$180,$000	; Color0 - nero
	dc.w	$100,$200	; BplCon0 - no bitplanes

; qua potete mettere spritepointers, colori, bplpointers eccetera...


coppajumpa:
	dc.w	$84		; COP2LCh
	DC.W	0
	dc.w	$86		; COP2LCl
	DC.W	0
	DC.W	$8a,0		; COPJMP2 - fai partire la cop2 (fotogramma)

* * * * * * 

pezzofinale:			; a questo pezzo salta la copper2 alla sua
	dc.w	$ffdf,$fffe	; fine, ogni fotogramma di animazione...
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
	dc.w	$1607,$fffe
	dc.w	$180,$0a0
	dc.w	$1a07,$fffe
	dc.w	$180,$0b0
	dc.w	$1f07,$fffe
	dc.w	$180,$0c0
	dc.w	$2607,$fffe
	dc.w	$180,$0d0
	dc.w	$2c07,$fffe
	dc.w	$180,$0e0

coppajumpa2:
	dc.w	$80	; COP1lc per far ripartire la copperlist dall'ourcopper
	DC.W	0
	dc.w	$82	; COP2Lcl
	DC.W	0
	dc.w	$FFFF,$FFFE	; Fine della copperlist
finepezzofinale:


	section	bufcopperi,bss_C

copcols:
copbuf1:
	ds.b	((linee*8)+AGGIUNTE)*NUMBUFCOPPERI	; 50 copperlist!
finebuffoni:

	end

Se vi precalcolate l'effetto copper, le moltiplicazioni, le coordinate dei
3d vectors, la musica... potete fare una demo che lascia libero il processore
per fare aleno 1 effetto non precalcolato!!!! HAHAHAHA!

Da notare che dalla copper1 si salta alla copper2, alla cui fine si salta
alla copper "pezzofinale", che ripunta come copper di partenza la copper1!
Dunque facciamo saltare 2 volte il copper, e non 1 come in Lezione11h.s

