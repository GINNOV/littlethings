
; Lezione11i1.s	- Scorrimento di colori a tutto schermo PAL

	SECTION	Scorricol,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"		; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	BSR.w	MAKECOP		; Fai la copperlist

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#MYCOP,$80(a5)		; Puntiamo la nostra COP
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

	btst	#2,$16(a5)	; tasto destro premuto?
	beq.s	Mouse2		; se si non eseguire ColorScrollPAL

	bsr.s	ColorScrollPAL		; Scorrimento dei colori

mouse2:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
;	Routine che crea la copperlist
*****************************************************************************

;	   .__ _  __..... .   .    .
;	-\-'_ \\// _`-/-- -  -    -
;	  \(-)____(-)/// /  /    /
;	  -'_/V""V\_`- _  _    _
;	    \ \    /__ _  _    _
;	     \ \,,/__ _  _    _
;	        \/-Mo!

MakeCop:
	lea	MYCOP,a0		; Indirizzo della copperlist da fare
	move.l	#$1f07fffe,d0		; Istruzione WAIT, prima linea $1f
					; ossia WAIT di partenza
	move.l	#$0007fffe,d1		; Ultima linea NTSC per la Copperlist
					; ossia WAIT finale
	bsr.w	FaiColors		; Fai Questo pezzo di Copperlist
					; da $1f a $ff, ossia la parte NTSC

	move.l	#$ffdffffe,(a0)+	; Wait Speciale per attendere la fine
					; della zona NTSC.
	move.l	#$0007fffe,d0		; Prima linea della zona pal (WAIT)
					; ossia WAIT di partenza
	move.l	#$3707fffe,d1		; Ultima linea in fondo allo schermo
					; ossia WAIT finale
	bsr.s	FaiColors2		; Fai il pezzo PAL della copperlist
	move.l	#$fffffffe,(a0)+	; Fine della copperlist
	rts


*****************************************************************************
; SubRoutine che crea la copperlist - in a0 va immesso l'indirizzo della
; copperlist, in d0 il primo wait, in d1 l'ultimo da fare
*****************************************************************************

;	  _    _  _ ___
;	(( _ \--/ _ ) )
;	\_\(°/__\°)/_/
;	 \-'_/VV\_`-/
;	 \\_\'  `/_/   
;	  \ \\..//
;	   \ `\/'

FaiColors:
	lea	ColorTabel(PC),a1	; Indirizzo tabella colori
FaiColors2:
	move.l	d0,(a0)+		; Immetti il WAIT in coplist
	move.w	#$0180,(a0)+		; Immetti il registro COLOR0
	move.w	(a1)+,(a0)+		; E il colore dalla tabella
	cmp.l	#ColorTabelEnd,a1	; siamo all'ultimo colore della tab?
	bne.s	labelok			; Non ancora? allora non ripartire
	lea	ColorTabel(PC),a1	; altrimenti riparti dal primo colore
labelok:
	addi.l	#$01000000,d0		; Incrementa la pos Y del WAIT
	cmp.l	d0,d1			; Siamo arrivati all'ultimo wait?
	bne.s	FaiColors2		; Se non ancora, fai un'altra linea
	rts


*****************************************************************************
; Routine che muove i colori
*****************************************************************************

;	 \  /
;	  oO
;	 \__/

ColorScrollPAL:
	move.l	PuntatorecolTab(PC),a0	; PuntatorecolTab in a0
	lea	MYCOP+6,a1		; Indirizzo del primo colore in copper
	move.l	#225-1,d0		; 225 colori da muovere in zona NTSC
	bsr.s	scroll			; Scorri la parte ntsc dello schermo
	addq.w	#4,a1			; salta il WAIT speciale alla fine
					; della zona NTSC ($FFDFFFFE)
	moveq	#54-1,d0		; 54 colori da muovere in zona PAL
	bsr.s	scroll			; Scorri la parte PAL dello schermo

	lea.l	PuntatorecolTab(PC),a0	; PuntatorecolTab in a0
	addq.l	#2,(a0)			; Avanza di un colore per la prossima
					; esecuzione della routine
	cmp.l	#ColorTabelEnd,(a0)	; siamo arrivati all'ultimo colore
					; della tabella??
	bne.s	NonRipartire		; Se non ancora esci dalla routine
	move.l #ColorTabel,(a0)		; Altrimenti riparti dall'inizio
					; della tabella
NonRipartire:
	rts

*****************************************************************************
;	Subroutine che muove i colori; il numero di colori va immesso in d0,
;	l'indirizzo della tabella colori in a0 e i colori in coplist in a1
*****************************************************************************

scroll:
	move.w	(a0)+,(a1)		; copia il colore dalla tabella alla
					; copperlist
	cmp.l	#ColorTabelEnd,a0	; Abbiamo copiato l'ultimo colore
					; della tabella?
	bne.s	okay			; Se non ancora, continua
	lea	ColorTabel(PC),a0	; ColorTabel in a0 - riparti dal primo
					; colore della tabella
okay:
	addq.w	#8,a1			; Vai al prossimo colore in copperlist
	dbra	d0,scroll		; d0 = numero colori da immettere
	rts


;	Tabella con i colori RGB

ColorTabel:
	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
	dc.w	$e00,$d00,$c00,$b00,$a00,$900,$800,$700
	dc.w	$600,$500,$400,$300,$200,$100,$000,$010
	dc.w	$020,$030,$040,$050,$060,$070,$080,$090
	dc.w	$0a0,$0b0,$0c0,$0d0,$0e0,$0f0,$0e0,$0d0
	dc.w	$0c0,$0b0,$0a0,$090,$080,$070,$060,$050
	dc.w	$040,$030,$020,$010,$000,$001,$002,$003
	dc.w	$004,$005,$006,$007,$008,$009,$00a,$00b
	dc.w	$00c,$00d,$00e,$00f,$00e,$00d,$00c,$00b
	dc.w	$00a,$009,$008,$007,$006,$005,$004,$003
	dc.w	$002,$001
ColorTabelEnd:

;	Questo e' il puntatore alla tabella ColorTabel

PuntatorecolTab:
	dc.l	ColorTabel+2

*****************************************************************************
;	Copperlist creata interamente dalla routine MAKECOP; in questo modo
;	basta fare una section BSS!
*****************************************************************************

	Section	Copperlist,bss_C

MYCOP:
	ds.b	225*8	; spazio per la zona PAL
	ds.b	4	; spazio per il $FFDFFFFE
	ds.b	55*8	; spazio per la zona NTSC
	ds.b	4	; spazio per la fine della copperlist $FFDFFFFE

	end

