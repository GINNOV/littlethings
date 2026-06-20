
; Lezione9m2.s	Sparizione tramite scorrimento verso sinistra di un immagine
;		Tasto destro per eseguire la blittata, sinistro per uscire.

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
				; QUI C'E` LA UNA DIFFERENZA RISPETTO
				; ALLE IMMAGINI NORMALI!!!!!!
	ADD.L	#40,d0		; + LUNGHEZZA DI UNA RIGA !!!!!
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

	bsr.s	Scorri		; esegui la routine di scorrimento

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts


;****************************************************************************
; Questa routine fa scomparire progressivamente un immagine
; facendola scorrere verso sinistra
;****************************************************************************

;	      ___________ ))
;	  (( /          ¬\
;	    /   ___ ---   \
;	    \¬\____ ____/ /
;	    /   ( ·T. )  / ))
;	(( /     ¯¯!¯¯  /
;	  /   _  (_ _) /
;	  \ ( ¬   `-'_/ ))
;	(( \        /
;	    \______/ xCz

Scorri:
	move.w	#160-1,d7	; il loop va eseguito una volta per ogni pixel
				; l'immagine e` larga 160 pixel (10 words)

; In questo esempio copiamo un'immagine su se stessa, ma shiftandola
; continuamente di un pixel, in modo da farla scorrere.
; Pertanto gli indirizzi sorgente e destinazione sono uguali.
; Per shiftare verso sinistra usiamo il modo discendente, e quindi
; puntiamo l'ultima word dell'immagine:

	move.l	#bitplane+((20*3*(50+20))+(64+160)/16-1)*2,d0	; ind. sorg. e
								; destinazione

ScorriLoop:

; Aspetta il vblank in modo da far scorrere l'immagine di un pixel ad
; ogni fotogramma.

WaitWblank:
	CMP.b	#$ff,$dff006		; aspetta la linea 255
	bne.s	WaitWblank
Aspetta:
	CMP.b	#$ff,$dff006		; ancora linea 255 ?
	beq.s	Aspetta

	btst	#6,2(a5)		; aspetta che il blitter finisca
waitblit:
	btst	#6,2(a5)
	bne.s	waitblit

	move.l	#$19f00002,$40(a5)	; BLTCON0 e BLTCON1 - copia da A a D
					; in modo discendente con shift
					; (verso sinistra) di un pixel

	move.l	#$ffff7fff,$44(a5)	; BLTAFWM e BLTALWM
					; BLTAFWM = $ffff - passa tutto
					; BLTALWM = $7fff = %0111111111111111
					;   cancella il bit piu` a sinistra
; carica i puntatori

	move.l	d0,$50(a5)			; bltapt - sorgente
	move.l	d0,$54(a5)			; bltdpt - destinazione

; il modulo e` calcolato come al solito

	move.l #$00140014,$64(a5)		; bltamod e bltdmod 
	move.w	#(3*20*64)+160/16,$58(a5)	; bltsize
						; altezza 20 linee e 3 planes
						; largo 160 pixel (= 10 words)

	dbra	d7,ScorriLoop			; ripeti per ogni pixel
						
	btst	#6,$02(a5)		; aspetta che il blitter finisca
waitblit2:
	btst	#6,$02(a5)
	bne.s	waitblit2
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

				; QUI C'E` UNA DIFFERENZA RISPETTO
				; ALLE IMMAGINI NORMALI!!!!!!
	dc.w	$108,80		; VALORE MODULO = 2*20*(3-1)= 80
	dc.w	$10a,80		; ENTRAMBI I MODULI ALLO STESSO VALORE.

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


BITPLANE:
	incbin	"assembler2:sorgenti6/amiga.rawblit"
					; qua carichiamo la figura in
					; formato RAWBLIT (o interleaved),
					; convertita col KEFCON.
	end

;****************************************************************************

In questo esempio riproponiamo l'effetto visto in lezione9h4.s solo che
effettuiamo lo scorrimento verso sinistra. Per shiftare verso sinistra,
dobbiamo usare il blitter in modo discendente. La blittata e` sempre una
copia di un immagine su se stessa (indirizzi sorgente e destinazione uguali)
ma lo shift avviene verso sinistra. Dobbiamo mascherare la word piu` a sinistra
per cancellare la colonna di pixel piu` a sinistra. In modo discendente la
word piu` a sinistra e` mascherata da BLTALWM. Per cancellare la colonna di
pixel piu` a sinistra dobbiamo porre in BLTALWM il valore %0111111111111111
che cancella il bit piu` a sinistra e lascia passare gli altri.
Notate la differenza con lezione9h4 dove invece mascheravamo il bit piu` a
destra.

