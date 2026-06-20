
; Lezione11g4.s	- Effetto di scorrimento orizzontale dei colori col Copper

	SECTION	Supercar,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
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
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	btst	#2,$dff016	; tasto destro premuto?
	beq.s	Mouse2		; se si non eseguire Linecop

	bsr.s	LineCop		; Effetto "supercar"

mouse2:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

; Questa routine immette i colori ciclicamente dalla tabella alle due linee
; formate da 54 "dc.w $1800000". L'effetto e' possibile in quanto ogni volta
; che il copper legge una istruzione, formata da 2 words, il tempo necessario
; per arrivare a leggere quella seguente corrisponde a 4 pixel per word, ossia
; 8 pixel per ogni istruzione completa. Facendo un calcolo, in uno schermo
; largo 320 pixel si puo' cambiare il colore orizzontalmente 40 volte, infatti
; 320/8=40. In questo caso si parte dalla posizione verticale overscan,
; ossia fuori dai bordi del monitor (il wait e' dc.w $2901,$FFFE), e si arriva
; fuori al bordo destro dall'altra parte. In teoria faremmo 54*8=432 pixel
; di larghezza (monitor permettendo). Da notare che ci si riferisce a 8 pixel
; LOWRES, in caso di HIRES la dimensione rimane invariata, ed apparira' di
; 16 pixel hires, naturalmente.

;	      /////////
;	     /       /_____________________
;	    / ___ __//                     \
;	   / ______//  eY! fig sta rutin!   \
;	 _/ /  ® \©\\_ _____________________/
;	(_  \____/_/ / /
;	 \ _       \ \/
;	  \/    (·__)
;	  /        |
;	 /_____ (o)|
;	   T T`----'
;	   l_! xCz

LineCop:
	lea	TabellaColori(PC),a0
	lea	FineTabColori(PC),a3
	lea	EffInCop,a1	; Indirizzo barra orizzontale 1
	lea	EffInCop2,a2	; Indirizzo barra orizzontale 2
	moveq	#54-1,d3	; Numero di colori orizzontali
	addq.l	#2,ColBarraAltOffset	; Barra bassa - scorr. colori
					; verso sinistra
	subq.l	#2,ColBarraBassOffset	; Barra alta - scorrimento colori
					; verso destra
	move.l	ColBarraAltOffset(PC),d0	; Start Offset (1)
	add.l	d0,a0		; trova il colore giusto nella tabella colori
				; secondo l'offset attuale
	cmp.w	#-1,(a0)	; siamo alla fine della tabella? (indicata
				; con un dc.w -1)
	bne.s	CSalta		; se no, vai avanti
	clr.l	ColBarraAltOffset	; altrimenti riparti
	lea	TabellaColori(PC),a0	; dal primo colore
CSalta:
	move.l	ColBarraBassOffset(PC),d1	; Start Offset (2)
	sub.l	d1,a3				; trova il colore giusto
	cmp.w	#-1,-(a3)		; siamo alla fine della tabella
	bne.s	MettiColori		; se non ancora vai avanti
	move.l	#FineTabColori-TabellaColori,ColBarraBassOffset ; altrimenti
					; fai ripartire dalla fine della
					; tabella (dato che questa barra
					; scorre all'indietro!)
	lea	FineTabColori-2(PC),a3
MettiColori:
	addq.w	#2,a1		; salta il dc.w $180
	addq.w	#2,a2		; salta il dc.w $180
	move.w	(a0)+,(a1)+	; Immetti il colore in coplist (barra1)
	move.w	(a3),(a2)+	; Immetti il col. nella barra 2

	cmp.w	#-1,(a0)	; siamo alla fine della tabella colori? (bar1)
	bne.s	NonFine		; se non ancora vai avanti
	lea 	TabellaColori(PC),a0	; altrimenti riparti da capo (bar1)
NonFine:
	cmp.w	#-1,-(a3)	; siamo all'inizio della tab colori? (bar2)
	bne.s	NonFine2	; se non ancora vai avanti
	lea 	FineTabColori-2(PC),a3	; altrimenti riparti dalla fine (bar2)
NonFine2:
	dbra	d3,MettiColori
	rts

*** *** *** *** *** *** *** *** *** ***


ColBarraAltOffset:
	dc.l	0

ColBarraBassOffset:
	dc.l	0



; NOTA: per indicare la fine ( e l'inizio) della tabella, viene controllato
;	se si e' arrivati al dc.w -1.

	dc.w 	-1	; fine tabella
TabellaColori:
	DC.W	$F0F,$F0E,$F0D,$F0C,$F0B,$F0A,$F09,$F08,$F07,$F06
	DC.W	$F05,$F04,$F03,$F02,$F01,$F00,$F10,$F20,$F30,$F40
	DC.W	$F50,$F60,$F70,$F80,$F90,$FA0,$FB0,$FC0,$FD0,$FE0
	DC.W	$FF0,$EF0,$DF0,$CF0,$BF0,$AF0,$9F0,$8F0,$7F0,$6F0
	DC.W	$5F0,$4F0,$3F0,$2F0,$1F0,$0F0,$0F1,$0F2,$0F3,$0F4
	DC.W	$0F5,$0F6,$0F7,$0F8,$0F9,$0FA,$0FB,$0FC,$0FD,$0FE
	DC.W	$0FF,$0EF,$0DF,$0CF,$0BF,$0AF,$09F,$08F,$07F,$06F
	DC.W	$05F,$04F,$03F,$02F,$01F,$00F,$10F,$20F,$30F,$40F
	DC.W	$50F,$60F,$70F,$80F,$90F,$A0F,$B0F,$C0F,$D0F,$E0F
FineTabColori:
	dc.w	-1	; fine tabella


	section CList,code_c

CopperList:
	dc.w	$100,$200	; BPLCON0 - 0 bitplanes
	dc.w	$180,$000	; Color0 nero

	dc.w	$2901,$FFFE	; Wait linea $29
EffInCop2:
	dcb.l	54,$1800000	; 54 Color0 di seguito, che a scatti di 8
				; pixel in avanti ogni volta riempiono la
				; linea interamente

	dc.w	$2a01,$FFFE	; Wait linea $2a
	dc.w	$180,$000	; Color0 nero


	dc.w	$FFDF,$FFFE	; Wait speciale per andare in zona PAL

	dc.w	$2A01,$FFFE	; Attendi la linea $2a+$ff
EffInCop:
	dcb.l	54,$1800000	; 54 Color0 di seguito, che a scatti di 8
				; pixel in avanti ogni volta riempiono la
				; linea interamente

	dc.w	$2B07,$FFFE	; Wait linea $ff+$2b
	dc.w	$180,$000	; Color0 nero

	dc.w	$FFFF,$FFFE	; Fine copperlist

	end

