
; Lezione10c1.s	BLITTATA, in cui costruiamo la maschera di un disegno
;		Alternare i tasti del mouse per vedere le blittate

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
	MOVEQ	#3-1,D1		; numero di bitplanes
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

; copia l'immagine normalmente

	lea	FiguraPlane1,a0		; copia il primo plane
	lea	BITPLANE1,a1
	bsr.s	copia

	lea	FiguraPlane2,a0		; copia secondo plane
	lea	BITPLANE2,a1
	bsr.s	copia

	lea	FiguraPlane3,a0		; copia terzo plane
	lea	BITPLANE3,a1
	bsr.s	copia

mouse1:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse1

; copia primo bitplane

	lea	FiguraPlane1,a0
	lea	BITPLANE1+14,a1
	bsr.s	BlitOR		; esegue un OR tra il plane 1 della figura
				; e la destinazione (vuota)

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	lea	FiguraPlane2,a0
	lea	BITPLANE1+14,a1
	bsr.s	BlitOR		; esegue un OR tra il plane 2 della figura
				; e la destinazione (plane 1 della figura)
mouse3:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse3

	lea	FiguraPlane3,a0
	lea	BITPLANE1+14,a1
	bsr.s	BlitOR		; esegue un OR tra il plane 3 della figura
				; e la destinazione (plane 1 OR 2 della figura)
mouse4:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse4
	rts

;****************************************************************************
; Questa routine copia la figura sullo schermo.
;
; A0 - indirizzo sorgente
; A1 - indirizzo destinazione
;****************************************************************************

Copia:
	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$ffffffff,$44(a5)	; maschere
	move.l	#$09f00000,$40(a5)	; BLTCON0  e BLTCON1 (usa A+D)
					; copia normale
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#34,$66(a5)		; BLTDMOD (40-6=34)
	move.l	a0,$50(a5)		; BLTAPT  puntatore sorgente
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*42)+3,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 3 word
	rts				; altezza 42 linee

;****************************************************************************
; Questa routine esegue un OR tra la sorgente e la destinazione.
; Usa i canali B,C e D. La sorgente viene letta attraverso il canale C.
; La destinazione invece viene letta dal canale B e poi riscritta tramite il D.
; Per conseguenza i canali B e D hanno lo stesso modulo e gli stessi indirizzi
; di partenza.
;
; Parametri:
;
; A0 - indirizzo sorgente
; A1 - indirizzo destinazione
;****************************************************************************

;	                 _____
;	                (_____)
;	                  ,,,
;	 __n____________.|o o|.____________n__
;	== _o_|         |  -  |         |_o_ ==
;	 ¯¯ . |   ____  |\ O /|  ____   |   ¯¯
;	      |__/    \ ||`*'|| /    \_#| :
;	    :         | ||   || |      `:
;	    .         |#._______|         .
;	              ! |  o  |
;	                (     )
;	                |  U  |
;	                :  !  :


BlitOR:
	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$07EE0000,$40(a5)	; BLTCON0 e BLTCON1
					; esegue un OR tra B e C
					; D=B OR C
	move.w	#0,$60(a5)		; BLTCMOD (=0)
	move.w	#34,$66(a5)		; BLTDMOD (40-6=34)
	move.w	#34,$62(a5)		; BLTBMOD (40-6=34)
	move.l	a0,$48(a5)		; BLTCPT  puntatore sorgente
	move.l	a1,$4c(a5)		; BLTBPT  puntatore destinazione
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*42)+3,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 3 word
	rts				; altezza 42 linee

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

	dc.w	$100,$3200	; bplcon0

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000

	dc.w	$180,$000	; color0
	dc.w	$182,$aaa	; color1
	dc.w	$184,$b00	; color2
	dc.w	$186,$080	; color3
	dc.w	$188,$24c
	dc.w	$18a,$eb0
	dc.w	$18c,$b52
	dc.w	$18e,$0cc

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Questa e` la figura

FiguraPlane1:
	dc.l	$ffffc000,$ffff,$c0000000,$ffffc000,$ffff,$c0000000
	dc.l	$ffffc000,$ffff,$c0000000,$ffffc000,$ffff,$c0000000
	dc.l	$ffffc000,$ffff,$c0000000,$ffffc000,$ffff,$c0000000
	dc.l	$ffffc000,$ffff,$c0000000,$ffffc000,$ffff,$c0000000
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0,0,0,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,0

FiguraPlane2:
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,$3fffff80
	dc.l	$3fff,$ff800000,$3fffff80,$3fff,$ff800000,0
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0

FiguraPlane3:
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0,0,0,0
	dc.l	0,0,0,0,0,0
	dc.l	$ffffc000,$ffff,$c0000000,$ffffc000,$ffff,$c0000000
	dc.l	$ffffc000,$ffff,$c0000000,$ffffc000,$ffff,$ffffff80
	dc.l	$ffffffff,$ff80ffff,$ffffff80,$ffffffff,$ff80ffff,$ffffff80
	dc.l	$f000ffff,$ff80f000,$ffffff80,$f000ffff,$ff80f000,$ffffff80
	dc.l	$f000ffff,$ff80f000,$ffffff80,$f000ffff,$ff80f000,$ffffff80
	dc.l	$f000ffff,$ff80f000,$ffffff80,$f000ffff,$ff80f000,$ffffff80
	dc.l	$ffffffff,$ff800000,0

;****************************************************************************

	SECTION	bitplane,BSS_C

BITPLANE1:
	ds.b	40*256
BITPLANE2:
	ds.b	40*256
BITPLANE3:
	ds.b	40*256

	end

;****************************************************************************

In questo esempio costruiamo con il blitter la maschera di una figura,
ovverosia la sua "ombra". Per farlo e` necessario eseguire un OR tra i bit
planes della figura. In questo esempio eseguiamo questa operazione
un passo alla volta. Per prima cosa facciamo l'OR tra il primo bitplane
della figura e la destinazione nella quale disegneremo la maschera.
Poiche` all'inizio la destinazione e` vuota questo passo e` equivalente ad
una semplice copia del primo plane della figura. Come secondo passo
eseguiamo l'OR tra il secondo plane e la destinazione. Poiche` la destinazione
contiene il primo plane, in pratica eseguiamo l'OR tra il plane 1 e il plane 2.
Come terzo passo eseguiamo l'OR tra il plane 3 e la destinazione. Poiche` la
destinazione contiene l'OR di plane 1 e plane 2, come risultato otterremo
l'OR di tutti e 3 i planes. Se avessimo avuto una figura con piu` di 3 planes,
avremmo dovuto ripetere questo stesso procedimento anche per gli altri planes.
La blittata avviene utilizzando 3 canali. I planes della figura vengono letti
attraverso il canale C. La destinazione invece viene letta attraverso il canale
B e poi riscritta attraverso il canale D. Il valore di LF e` calcolato per
effettuare l'OR dei canali B e C.

