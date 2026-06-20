
; Lezione9g2.s	BLITTATA, in cui copiamo un rettangolo da un punto
;		all'altro dello stesso schermo in formato INTERLEAVED
;		Tasto sinistro per eseguire la blittata, destro per uscire.

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

	bsr.s	copia		; esegui la routine di copia

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts


; ************************ LA ROUTINE DI COPIA ****************************

 ; viene copiato un rettangolo con larghezza=160 e altezza=20
 ; dalle coordinate X1=64, Y1=50 (sorgente)
 ; alle coordinate X2=80, Y2=190 (destinazione)

;	           _
;	          /¬\
;	         /   \
;	    __  /__ __\  __
;	 .--\/-/ `°u°' \-\/--.
;	 |    /  T¯¯¬   \    |
;	 |   /   `       \   |
;	 |  /_____________\  |
;	 |    _         _    |
;	 |    |         |    |
;	 l____|         l____|
;	 (____)----^----(____)
;	    T      T      T   xCz
;	 ___l______|______|___
;	`----------^----------'

copia:

; Carica gli indirizzi sorgente e destinazione in 2 registri
; NOTATE LA DIFFERENZA RISPETTO AL CASO NORMALE: NEL CALCOLO DELL'OFFSET
; DELLA RIGA Y SI MOLTIPLICA ANCHE PER IL NUMERO DI PLANES (cioe` 3)
; la formula e` OFFSET=(Y*(NUMERO WORDS PER RIGA)*(NUMERO PLANES))*2

	move.l	#bitplane+((20*3*50)+64/16)*2,d0	; ind. sorgente
							; notate il fattore *3!
	move.l	#bitplane+((20*3*190)+80/16)*2,d2	; ind. destinazione
							; notate il fattore *3!

	btst	#6,2(a5)	; aspetta che il blitter finisca
waitblit:
	btst	#6,2(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 - copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo

; carica i puntatori
	move.l	d0,$50(a5)	; bltapt
	move.l	d2,$54(a5)	; bltdpt

; queste 2 istruzioni settano i moduli della sorgente e della destinazione
; NON CI SONO DIFFERENZE RISPETTO AL CASO NORMALE:
; il modulo e` calcolato secondo la formula (H-L)*2  (H e` la larghezza del
; bitplane in words e L e` la larghezza dell'immagine, sempre in words)
; che abbiamo visto a lezione, (20-160/16)*2=20

	move.w	#(20-160/16)*2,$64(a5)	; bltamod
	move.w	#(20-160/16)*2,$66(a5)	; bltdmod

; notate anche che poiche` i 2 registri hanno indirizzi consecutivi, si puo`
; usare una sola istruzione invece che 2 (ricordate che 20=$14):
; move.l #$00140014,$64(a5)	; bltamod e bltdmod 

; NOTATE LA DIFFERENZA RISPETTO AL CASO NORMALE: NELLA DIMENSIONE
; DELLA BLITTATA, L'ALTEZZA DELL'IMMAGINE E` MOLTIPLICATA PER IL NUMERO
; DI BITPLANES

	move.w	#(3*20*64)+160/16,$58(a5)	; bltsize
						; altezza 20 linee e 3 planes
						; largo 160 pixel (= 10 words)
						
	btst	#6,$02(a5)	; aspetta che il blitter finisca
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

;****************************************************************************

BITPLANE:
	incbin	"assembler2:sorgenti6/amiga.rawblit"
					; qua carichiamo la figura in
					; formato RAWBLIT (o interleaved),
					; convertita col KEFCON.
	end

;****************************************************************************

In questo esempio visualizziamo un'immagine in formato interleaved e ne copiamo
un pezzo da un punto all'altro dello schermo. Si tratta dello stesso programma
dell'esempio lezione9f1.s, ma in formato interleaved.
Vi consigliamo di esaminare questo esempio confrontandolo con lezione9f1.s.
Come abbiamo visto nella lezione, il formato interleaved ci permette di
effettuare la copia mediante una sola blittata. Per questo la routine "Copia"
(che e` la routine che effettua la copia) e` priva di loop, a differenza
dell'omonima routine di lezione9f1.s.
Alcuni valori caricati nei registi del blitter sono diversi:

1) Nel calcolo dell'indirizzo, per ottenere l'offset tra la prima word della
   riga Y e l'inizio del bitplane, bisogna moltiplicare Y per il numero dei
   bitplanes, oltre che per la dimensione della riga; per quanto riguarda la
   X, invece, non ci sono differenze.

2) L'altezza della blittata e` pari all'altezza dell'immagine moltiplicata per
   il numero dei bitplanes; per quanto riguarda la larghezza, invece, non ci
   sono differenze.

Anche per quanto riguarda gli altri registri, in particolare per il modulo,
non ci sono differenze.

