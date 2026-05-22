
; Lezione10a2.s	BLITTATA, in cui copiamo un disegno invertendo un bitplane
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
	MOVEQ	#2-1,D1		; numero di bitplanes
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

mouse1:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse1

; copia l'immagine invertendo il primo bitplane

	lea	FiguraPlane1,a0
	lea	BITPLANE1+14,a1
	bsr.s	CopiaInversa		; copia il primo plane invertendolo

	lea	FiguraPlane2,a0
	lea	BITPLANE2+14,a1
	bsr.s	copia			; copia secondo plane normalmente

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:
	rts

;****************************************************************************
; Questa routine copia la figura sullo schermo.
; Prende come parametri
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
	move.w	#(64*25)+3,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 3 word
	rts				; altezza 25 linee

;****************************************************************************
; Questa routine copia la figura sullo schermo invertendola
; cioe` trasforma 1 in 0 e 0 in 1.
;
; A0 - indirizzo sorgente
; A1 - indirizzo destinazione
;****************************************************************************

;	               _   _
;	            __/ \_/ \
;	           /  \_ oo_/
;	          /        \/_
;	     ____/_ ___ ____o
;	 ___/      \\  \\ UU

CopiaInversa:
	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffffffff,$44(a5)	; maschere
	move.l	#$090f0000,$40(a5)	; BLTCON0  e BLTCON1
					; copia invertendo i bit, cioe`
					; D=NOT A
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#34,$66(a5)		; BLTDMOD (40-6=34)
	move.l	a0,$50(a5)		; BLTAPT  puntatore sorgente
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*25)+3,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 3 word
	rts				; altezza 25 linee

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

	dc.w	$100,$2200	; bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w	$e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w	$e4,$0000,$e6,$0000

	dc.w	$0180,$000	; color0
	dc.w	$0182,$aaa	; color1
	dc.w	$0184,$55f	; color2
	dc.w	$0186,$f80	; color3

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

FiguraPlane1:
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$c000,$0000,$0003,$c000
	dc.w	$0000,$0003,$c000,$0000,$0003,$c000,$0000,$0003,$c000,$0000
	dc.w	$0003,$c000,$0000,$0003,$c000,$0000,$0003,$c000,$0000,$0003
	dc.w	$c25c,$3bbb,$bb83,$c354,$22aa,$a283,$c2d4,$22bb,$b303,$c254
	dc.w	$22a2,$2283,$c25c,$3ba2,$3a83,$c000,$0000,$0003,$c000,$0000
	dc.w	$0003,$c000,$0000,$0003,$c000,$0000,$0003,$c000,$0000,$0003
	dc.w	$c000,$0000,$0003,$c000,$0000,$0003,$c000,$0000,$0003,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff

FiguraPlane2:
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff

;****************************************************************************

	SECTION	bitplane,BSS_C
BITPLANE1:
	ds.b	40*256
BITPLANE2:
	ds.b	40*256

	end

;****************************************************************************

In questo esempio vediamo un'applicazione dell'operazione logica di NOT.
Abbiamo un disegno sullo schermo, che potrebbe rappresentare un pulsante.
Supponiamo ora di voler disegnare lo stesso pulsante, ma invertendo i
colori, per simulare la pressione.
Un metodo e` quello di scambiare i colori nella copperlist.
In questo modo, pero` si scambiano i colori in tutto lo schermo e quindi se
vogliamo avere contemporaneamente 2 pulsanti, uno con i colori normali e
l'altro con i colori invertiti, questa tecnica non va bene.
Allora non ci resta che modificare i bitplane che formano l'immagine.
Il pulsante e` disegnato con i colori 2 e 3.
Per scambiare i colori dobbiamo trasformare il colore 2 in 3 e viceversa.
I pixel colorati con il colore 2:
Si ha il colore 2 quando il plane 1 e` settato a 0 e il plane 2 e` settato a 1.
Si ha il colore 3 quando il plane 1 e` settato a 1 e il plane 2 e` settato a 1.
Poiche` entrambi i colori hanno il plane 2 settato a 1, dobbiamo cambiare
solo il plane 1.
Se nel plane 1 invertiamo tutti i bit (cioe` trasformiamo tutti gli 0 in 1
e tutti gli 1 in 0) scambieremo i colori 2 e 3.
L'inversione dei bit e` l'operazione logica NOT che possiamo realizzare con il
blitter mediante un opportuno minterm. Se per leggere usiamo il canale A,
dobbiamo porre l'uscita D a 1 ogni volta che l'ingresso vale 0 e viceversa.
Cio` si ottiene settando a 1 tutti i minterms che corrispondono a combinazioni
con A=0, ovvero (come potete verificare dalla tabella nella lezione) con
LF=$0F.

