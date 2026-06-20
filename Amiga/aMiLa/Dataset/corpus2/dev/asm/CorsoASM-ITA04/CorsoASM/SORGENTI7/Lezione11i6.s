
;  Lezione11i6.s - effetto sfumato copper "pseudo 3d"

	SECTION	Barrex,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	bsr.s	makerast	; Fai la copperlist

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta

	bsr.s	MakeRast	; rulla i colori

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
;	Routine che crea la copperlist
*****************************************************************************

;	  Oo 
;	 `--'

MakeRast:
	lea Offsets(PC),a2	; tabella con 8*20 valori degli offset tra le
				; linee wait
	sub.w	#1*20,ContatoreWaitAnim
	bpl.s	nocolscroll
	addq.b	#1,ContatoreColore
	move.w	#7*20,ContatoreWaitAnim
nocolscroll:
	moveq	#0,d0		; azzera d0
	move.w	ContatoreWaitAnim(PC),d0
	add.w	d0,a2		; trova l'offset giusto nella tabella Offsets
	lea	CopBuffer,a0

	moveq	#0,d0
	move.b	ContatoreColore(PC),d0

	moveq	#20,d3		; numero loops FaiCopper
	lea Colors(PC),a1	; tabella con i colori
FaiCopper:
	and.w	#%01111111,d0	; servono solo i primi 7 bit di d0
	move.w	d0,d2		; rimetti in d2 l'ultimo valore del colore
				; salvato
	asl.l	#1,d2		; e spostalo a sinistra di 1 bit, il che
				; significa moltiplicare il valore per 2, dato
				; che i valori nella tabella sono .w (2 bytes)
				; in questo modo il valore di d2 e' pronto
				; per il "move.w (a1,d2),(a0)+" finale

	addq.b	#1,d0		; prossimo colore per il prossimo loop

	moveq	#0,d1		; azzera d1
	move.b	(a2)+,d1	; prendi il prossimo offset dalla tabella

	add.b	#$0f,d1		; offset dalla linea $00, ossia dall'inizio
				; dello schermo, da aggiungere ai valori
				; letti nella TAB
	asl.w	#8,d1		; sposta il valore a sinistra di 8 bit,dato che
				; si tratta della coordinata verticale
				; es: prima era $0019, allora diventa $1900

	or.w	#$07,d1		; linea orizzontale dei wait: 07 (con l'OR si
				; aggiunge lo 07 finale, es: $1907,$fffe...)
	move.w	d1,(a0)+	; prima word del wait con linea e colonna
	move.w	#$fffe,(a0)+	; seconda word del WAIT
	move.w	#$0180,(a0)+	; COLOR0
	move.w	(a1,d2),(a0)+	; copia il colore giusto dalla tabella alla
				; copperlist
	dbra	d3,FaiCopper
	rts



;	tabella con i colori della sfumatura. 128 valori.w

Colors:
	dc.w $111,$444,$222,$777,$333,$aaa,$333,$aaa	; prima parte grigia
	dc.w $333,$aaa,$333,$aaa,$333,$aaa,$333,$aaa
	dc.w $222,$777,$222,$444,$111,$000

	dc.w $000,$100,$200,$300,$400,$500,$600,$700	; parte colorata
	dc.w $800,$900,$a00,$b00,$c00,$d00,$e00
	dc.w $f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70
	dc.w $f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0
	dc.w $ff0,$ef0,$df0,$cf0,$bf0,$af0,$9f0,$8f0
	dc.w $7f0,$6f0,$5f0,$4f0,$3f0,$2f0,$1f0
	dc.w $0f0,$0f1,$0f2,$0f3,$0f4,$0f5,$0f6,$0f7
	dc.w $0f8,$0f9,$0fa,$0fb,$0fc,$0fd,$0fe
	dc.w $0ff,$0ef,$0df,$0cf,$0bf,$0af,$09f,$08f
	dc.w $07f,$06f,$05f,$04f,$03f,$02f,$01f
	dc.w $00f,$10f,$20f,$30f,$40f,$50f,$60f,$70f
	dc.w $80f,$90f,$a0f,$b0f,$c0f,$d0f,$e0f
	dc.w $f0f,$e0e,$d0d,$c0c,$b0b,$a0a,$909,$808
	dc.w $707,$606,$505,$404,$303,$202,$101,$000
	

; Tabella per distanze tra una linea e l'altra.
; Sono 8 linee di 20 valori, per un totale di 20*8=160 bytes
; Da notare che mentre i primi valori di ogni linea sono molto distanti fra
; loro (0,16,28,37...) gli ultimi arrivano ad essere consecutivi (77,78,79)
; Questo e' per rendere una specie di prospettiva:
;
;	------------------------------------------------------------
;
;	------------------------------------------------------------
;	____________________________________________________________
;	____________________________________________________________
;	------------------------------------------------------------
;
; Ci sono 8 linee di 20 valori, in quanto ogni fotogramma i wait "si spostano"
; scorrendo in alto (si noti: 0,16.. prima linea, 2,18... la seconda, 6,21 la
; terza). In questo modo, oltre ad essere disposti in "pseudo-prospettiva",
; scorrono verso l'alto rendendo l'effetto piu' credibile. Potremmo dire che
; questa e' una tabella con 8 "fotogrammi" di animazione dei wait!!!

Offsets:
	dc.b  0,16,28,37,44,50,54,58,61,64,66,68,70,72,74,75,76,77,78,79
	dc.b  2,18,29,38,45,50,55,58,61,64,66,68,70,72,74,75,76,77,78,79
	dc.b  4,20,31,39,45,51,55,58,62,64,67,69,71,72,74,75,76,77,78,79
	dc.b  6,21,32,40,46,51,56,59,62,65,67,69,71,72,74,75,76,77,78,79
	dc.b  8,23,33,41,47,52,56,60,62,65,67,69,71,72,74,75,76,77,78,79
	dc.b 10,24,34,42,48,52,56,60,63,65,68,69,71,73,74,75,76,77,78,79
	dc.b 12,25,35,42,48,53,57,60,63,66,68,70,71,73,74,75,76,77,78,79
	dc.b 14,27,36,43,49,54,57,61,63,66,68,70,71,73,74,75,76,77,78,79

ContatoreWaitAnim:
 	dc.w	7*20

ContatoreColore:
	dc.b	0

	even

*****************************************************************************
;	Copperlist
*****************************************************************************

	Section	Grafica,data_C

copperlist:
	dc.w	$8e,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,40		; Bpl1Mod
	dc.w	$10a,40		; Bpl2Mod

	dc.w	$180,$000	; Color0 nero
	dc.w	$100,$200	; bplcon0 - no bitplanes

CopBuffer:
	dcb.w	21*4,0		; spazio dove viene creato l'effetto

	dc.w	$6007,$fffe	; "pavimentazione" grigia
	dc.w	$0180,$0444
	dc.w	$6207,$fffe
	dc.w	$0180,$0666
	dc.w	$6507,$fffe
	dc.w	$0180,$0888
	dc.w	$6907,$fffe
	dc.w	$0180,$0aaa

	dc.w	$FFFF,$FFFE	; Fine della copperlist


	end

