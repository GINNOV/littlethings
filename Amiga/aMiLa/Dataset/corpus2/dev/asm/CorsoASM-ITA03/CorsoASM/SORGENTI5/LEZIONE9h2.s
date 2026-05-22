
; Lezione9h2.s	BLITTATA, in cui copiamo un rettangolo (in una pic normale)
;		non allineato con una word, usando le maschere per "tappare".
;		Premendo il tasto destro si esegue la blittata "sporca"
;		Poi,premendo il tasto sinistro si esegue la blittata giusta
;		e infine premendo ancora il tasto destro si usce.

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
	btst	#2,$dff016		; tasto destro del mouse premuto?
	bne.s	mouse1			; se no, aspetta

; Prima Blittata, con le maschere che lasciano passare anche dati non
; desiderati

	lea	bitplane+((20*170)+80/16)*2,a0		; ind. destinazione
	move.w	#$ffff,d0				; passa tutto
	move.w	#$ffff,d1				; passa tutto
	bsr.s	copia

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

; Seconda blittata, grazie alle maschere viene copiata solo 
; lettera "I"

	lea	bitplane+((20*170)+160/16)*2,a0		; ind. destinazione
	move.w	#%0000000000001111,d0	; passano i 4 bit piu` a destra
	move.w	#%1111000000000000,d1	; passano i 4 bit piu` a sinistra
	bsr.s	copia

mouse3:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse3		; se no, aspetta

	rts

;****************************************************************************
; Questa routine copia la figura sullo schermo.
;
; A0   - indirizzo destinazione
; D0.w - maschera prima word
; D1.w - maschera ultima word
;****************************************************************************

;	  ___________   
;	 (_____ _____)  
;	 /(_o(___)O_)\  
;	/ ___________ \
;	\ \____l____/ /|
;	|\_`---'---'_/ |
;	| `---------'  |
;	|  T  xCz   T  |
;	l__|        l__|
;	(__)---^----(__)
;	  T    T     |  
;	 _l____l_____|_ 
;	(______X_______)

copia:

	lea	bitplane+((20*78)+128/16)*2,a1	; indirizzo sorgente fisso

	moveq	#3-1,d7		; ripeti per ogni plane
PlaneLoop:
	btst	#6,2(a5)	; aspetta che il blitter finisca
waitblit:
	btst	#6,2(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 - copia da A a D

					; carica i parametri nelle maschere
	move.w	d0,$44(a5)		; BLTAFWM mask a sinistra
	move.w	d1,$46(a5)		; BLTALWM mask a destra

; carica i puntatori

	move.l	a1,$50(a5)		; bltapt - sorgente 
	move.l	a0,$54(a5)		; bltdpt - destinazione

	move.l #$00240024,$64(a5)	; bltamod e bltdmod 

	move.w	#(60*64)+2,$58(a5)	; bltsize
					; altezza 60 linee
					; larghezza 2 words

	lea	40*256(a1),a1		; punta al prossimo plane sorgente
	lea	40*256(a0),a0		; punta al prossimo plane destinazione

	dbra	d7,PlaneLoop

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

				; IMMAGINI NORMALI!!!!!!
	dc.w	$108,0		; VALORE MODULO = 0
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

BITPLANE:
	incbin	"assembler2:sorgenti6/amiga.raw"
					; qua carichiamo la figura in
					; formato RAW convertita col KEFCON.
	end

;****************************************************************************

In questo esempio mettiamo in evidenza come mediante l'uso delle maschere
sia possibile estrarre "pezzi" di immagine cancellando delle parti non
desiderate. In questo caso vogliamo copiare solo la lettera "I" della
scritta Amiga. Tale lettera e` contenuta in un rettangolo largo 2 words.
Nel rettangolo pero` ci sono anche pezzi di altre lettere.
La prima blittata viene eseguita con le maschere al valore $ffff, cioe`
settate in modo tale da far passare tutti i pixel.
Come vedete vengono copiati anche i pezzi di altre lettere.
La seconda blittata, invece ha le maschere settate a dei valori opportuni
tali da far passare solo i pixel che formano la lettera "I"

