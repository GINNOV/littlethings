
; Lezione9l1.s	copia di un rettangolo tra 2 zone sovrapposte
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

	bsr.s	copia		; esegui la routine di copia

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts


; ************************ LA ROUTINE DI COPIA ****************************
; viene copiato un rettangolo con larghezza=160 e altezza=20
; dalle coordinate X1=64, Y1=50 (sorgente)
; alle coordinate X2=64, Y2=40 (destinazione)
; notate che la sorgente e la destinazione si sovrappongono, e la destinazione
; si trova piu` in alto, quindi ad un indirizzo minore.
;****************************************************************************

;	     _______________
;	    /      _       ¬\
;	   /      / ¡__      \
;	  /      / O|o \      \
;	 /       \__l__/       \
;	/         (___)         \
;	\       (°              /
;	 \_____________________/
;	         T    T
;	        _l____|_
;	       | _    _ |
;	       |_|    |_|
;	       (_)--^-(_)
;	         T  T T  xCz
;	........ l__|_|__
;	         (____)__)

copia:

; Carica gli indirizzi sorgente e destinazione in 2 registri

	move.l	#bitplane+((20*3*50)+64/16)*2,d0	; ind. sorgente
	move.l	#bitplane+((20*3*40)+64/16)*2,d2	; ind. destinazione

	btst	#6,2(a5)		; aspetta che il blitter finisca
waitblit:
	btst	#6,2(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 - copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM fanno passare tutto

; carica i puntatori

	move.l	d0,$50(a5)		; bltapt
	move.l	d2,$54(a5)		; bltdpt

	move.l #$00140014,$64(a5)	; bltamod e bltdmod 

	move.w	#(3*20*64)+160/16,$58(a5)	; bltsize
						; altezza 20 linee e 3 planes
						; largo 160 pixel (= 10 words)
						
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

;****************************************************************************

BITPLANE:
	incbin	"assembler2:sorgenti6/amiga.rawblit"
					; qua carichiamo la figura in
					; formato RAWBLIT (o interleaved),
					; convertita col KEFCON.
	end

;****************************************************************************

In questo esempio copiamo un rettangolo tra 2 zone sovrapposte. Poiche`
l'indirizzo della destinazione e` minore di quello della sorgente (sullo
schermo la destinazione si trova piu` in alto) possiamo tranquillamente
adoperare le tecniche che abbiamo usato finora (copia di un rettangolo su
schermo interleaved). Infatti le routine di questo esempio sono identiche a
quelle viste nell'esempio lezione9g2.s.

