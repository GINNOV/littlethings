
; Lezione10a1.s	BLITTATA, in cui disegnamo rettangoli sullo schermo
;		Tasto destro per eseguire la blittata, sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE1,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#1-1,D1		; numero di bitplanes
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane (qua e' alto 256 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

; parametri per routine di disegno

	move.w	#16,d0			; X vertice superiore sinistro
	move.w	#10,d1			; Y vertice superiore sinistro
	move.w	#48,d2			; larghezza
	move.w	#20,d3			; altezza
	bsr.s	BlitRett		; esegui la routine di disegno

mouse1:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse1

; parametri per routine di disegno

	move.w	#64,d0			; X vertice superiore sinistro
	move.w	#70,d1			; Y vertice superiore sinistro
	move.w	#32,d2			; larghezza
	move.w	#40,d3			; altezza
	bsr.s	BlitRett		; esegui la routine di disegno

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts

;****************************************************************************
; Questa routine disegna un rettangolo sullo schermo.
;
; D0 - coordinata X del vertice superiore sinistro
; D1 - coordinata Y del vertice superiore sinistro
; D2 - larghezza rettangolo in pixel
; D3 - altezza rettangolo
;****************************************************************************

;	  _____     .
;	 / ___ \____.
;	¡ (___)___ ¬|
;	| | o Y___) |
;	| l___| ° | ¦
;	|   , `---' `;
;	|  C__.     _)
;	| _______   T
;	| l_l_l_|   |
;	| .¾¾¾¾¾,   |
;	| (_|_)_|   |
;	l___________|
;	   _T    T_
;	  / `-^--' \
;	_/          \_
;	|       xCz  |

BlitRett:
	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

; calcolo indirizzo di partenza del blitter

	lea	bitplane1,a1	; indirizzo bitplane
	mulu.w	#40,d1		; offset Y
	add.l	d1,a1		; aggiungi ad indirizzo
	lsr.w	#3,d0		; dividi per 8 la X
	and.w	#$fffe,d0	; rendilo pari
	add.w	d0,a1		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

; calcolo modulo blitter

	lsr.w	#3,d2		; dividi per 8 la larghezza
	and.w	#$fffe,d2	; azzerro il bit 0 (rendo pari)
	move.w	#40,d4		; larghezza schermo in bytes
	sub.w	d2,d4		; modulo=larg. schermo-larg. rettangolo

; calcolo dimensione blittata

	lsl.w	#6,d3		; altezza per 64
	lsr.w	#1,d2		; larghezza in pixel diviso 16
				; cioe` larghezza in words
	or	d2,d3		; metti insieme le dimensioni

; carica i registri

	move.l	#$01ff0000,$40(a5)	; BLTCON0 e BLTCON1
					; usa il canale D
					; LF=$FF (operaz. disegno)
					; modo ascendente

	move.w	d4,$66(a5)		; BLTDMOD
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	d3,$58(a5)		; BLTSIZE (via al blitter !)

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
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$1200	; bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$aaa	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

	SECTION	bitplane,BSS_C

BITPLANE1:
	ds.b	40*256

;****************************************************************************

	end

In questo esempio usiamo il blitter per tracciare dei rettangoli sullo schermo.
Utilizziamo una routine parametrica, che traccia un rettangolo conoscendo le
coordinate del vertice superiore sinistro e le dimensioni (larghezza e altezza)
del rettangolo. Per semplificare la routine la larghezza e la posizione X
del vertice sono approssimate a multipli di 16.
Il disegno viene realizzato mediante una blittata che pone l'uscita sempre a
1, che si ottiene ponendo LF=$FF come spiegato nella lezione.

