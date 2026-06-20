
; Lezione10g3.s	Effetto tendina
;		Tasto destro per vedere la figura, sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#3-1,D1		; numero di bitplanes (qua sono 3)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0		; + LUNGHEZZA DI UNA PLANE !!!!!
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse1:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse1		; se no, aspetta

	moveq	#16-1,d6	; ripeti per ogni colonna di pixel

	move.w	#%1000000000000000,d5	; valore della maschera all'inizio.
					; Fa passare solo il pixel piu`
					; a sinistra della word.

MostraLoop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130
	BNE.S	Waity1

	bsr.s	BlitAnd		; disegna la figura

	asr.w	#1,d5			; calcola la maschera per la prossima
					; blittata. Fa passare ogni volta un
					; bit in piu` rispetto alla volta
					; precedente.

	dbra	d6,MostraLoop


mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	moveq	#16-1,d6	; ripeti per ogni colonna di pixel
CancellaLoop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130
	BNE.S	Waity2

	lsr.w	#1,d5			; calcola la maschera per la prossima
					; blittata. Fa passare ogni volta un
					; bit in piu` rispetto alla volta
					; precedente.

	bsr.s	BlitAnd			; disegna la figura

	dbra	d6,CancellaLoop

fine:
	rts


;****************************************************************************
; Questa routine esegue un AND tra una figura letta attraverso il canale A
; e un valore costante caricato in BLTBDAT. Il risultato viene disegnato
; sullo schermo.
; D5 - contiene il valore costante (maschera) da caricare in BLTBDAT
;****************************************************************************

;	    ____
;	  .'_  _`.
;	  |/ \/ \|
;	  || oo ||
;	  ||    ||
;	 _|\_/\_/|_
;	(|-.____.-|)
;	 `._ -- _.'
;	   |_  _|
;	     `'

BlitAnd:
	lea	bitplane+100*40+4,a0	; puntatore destinazione in a0
	lea	figura,a1		; puntatore sorgente

	moveq	#3-1,d7			; ripeti per ogni plane
PlaneLoop:
	btst	#6,2(a5)
WBlit2:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word


	move.w	d5,$72(a5)		; scrive maschera in BLTBDAT
	move.l	#$09C00000,$40(a5)	; BLTCON0 usa i canali A e D
					;	  D=A AND B
					; BLTCON1 (nessun modo speciale)
	move.l	#$00000004,$64(a5)	; BLTAMOD=0
					; BLTDMOD=40-36=4 come al solito

	move.l	a1,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (linee di schermo)
	move.w	#(64*45)+18,$58(a5)	; BLTSIZE (via al blitter !)

	lea	2*18*45(a1),a1		; punta al prossimo plane sorgente
					; ogni plane e` largo 18 words e alto
					; 45 righe

	lea	40*256(a0),a0		; punta al prossimo plane destinazione
	dbra	d7,PlaneLoop

	rts

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; VALORE MODULO 0
	dc.w	$10a,0		; ENTRAMBI I MODULI ALLO STESSO VALORE.

	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Questi sono i dati che compongono la figura del bob.
; Il bob e` in formato normale, largo 288 pixel (18 words)
; alto 45 righe e formato da 3 bitplanes

Figura:
	incbin	copmon.raw

;****************************************************************************

	section	gnippi,bss_C

BITPLANE:
		ds.b	40*256	; 3 bitplanes
		ds.b	40*256
		ds.b	40*256

	end

;****************************************************************************

In questo esempio facciamoun effetto "tendina", cioe` disegnamo una figura
come se fosse una tendina veneziana che viene aperta o chiusa. Fate prima
a guardarlo che a capire di cosa si tratta rileggendo la spiegazione !
Questo effetto e` ottenuto mediante una tecnica simile a quella usata
nell'esempio lezione9h3.s per disegnare un immagine una colonna per volta.
Per ottenere l'effetto si fa un AND tra la figura e un valore di maschera
che seleziona solo alcune colonne di pixel. A differenza dell'esempio
lezione9h3, non possiamo usare BLTAFWM/BLTALWM per contenere la maschera
perche` dobbiamo applicare la maschera a tutte le word della figura, non
solamente alla prima e all'ultima. Per questo facciamo un AND tra il canale
A e il canale B, teniamo disabilitato il canale B e usiamo BLTBDAT come
maschera.
La maschera viene fatta variare in modo da mostrare progressivamente tutta
l'immagine, e poi viene variata di nuovo in modo da cancellare a poco a poco
tutta l'immagine.

