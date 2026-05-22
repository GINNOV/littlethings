
; Una routine di FADE (ossia dissolvenza) con una modifica riguardante il mix
; dei colori, infatti si puo' indicare una sfumatura RGB verso la quale
; tendere. Premere il tasto sinistro e destro varie volte per vedere e uscire.

	SECTION	Fade1,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA
;		 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

START:
;	puntiamo la figura

	MOVE.L	#Logo1,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#4-1,D1		; numero di bitplanes (qua sono 4)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*84,d0	; + lunghezza bitplane (qua e' alto 84 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP


	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA


mouse1:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse1

;	****************+ parte 1 con tendenza al ROSSO *****************

	clr.w	FaseDelFade	; azzera il numero del fotogramma
	move.w	#$b12,Tendenza	; imposta la tendenza al rosso ******

mouse2:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse2
Aspetta1:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta1

	bsr.w	FadeIN		; Fade!!!

	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2

	move.w	#16,FaseDelFade	; parti dal fotogramma 16

mouse3:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse3
Aspetta2:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta2

	bsr.w	FadeOUT	; Fade!!!

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse3

;	****************+ parte 2 con tendenza al VERDE *****************

	clr.w	FaseDelFade	; azzera il numero del fotogramma
	move.w	#$373,Tendenza	; imposta la tendenza al verde ******

mouse2x:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse2x
Aspetta1x:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta1x

	bsr.w	FadeIN		; Fade!!!

	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2x

	move.w	#16,FaseDelFade	; parti dal fotogramma 16

mouse3x:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse3x
Aspetta2x:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta2x

	bsr.w	FadeOUT	; Fade!!!

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse3x


;	****************+ parte 3 con tendenza al BLU *****************

	clr.w	FaseDelFade	; azzera il numero del fotogramma
	move.w	#$33c,Tendenza	; imposta la tendenza al BLU ******

mouse2y:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse2y
Aspetta1y:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta1y

	bsr.w	FadeIN		; Fade!!!

	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2y

	move.w	#16,FaseDelFade	; parti dal fotogramma 16

mouse3y:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse3y
Aspetta2y:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta2y

	bsr.w	FadeOUT	; Fade!!!

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse3y

	rts


*****************************************************************************
;	Routines che aspettano e richiamano Fade al momento giusto
*****************************************************************************

FadeIn:
	cmp.w	#17,FaseDelFade
	beq.s	FinitoFadeIn
	moveq	#0,d0
	move.w	FaseDelFade(PC),d0
	moveq	#15-1,d7		; D7 = Numero di colori
	lea	TabColoriPic(PC),a0	; A0 = indirizzo tabella dei colori
					; della figura da "dissolvere"
	lea	CopColors+6,a1		; A1 = indirizzo colori in copperlist
					; da notare che parte dal COLOR1 e
					; non dal color0, in quanto il color0
					; e'=$000 e cosi' rimane.
	bsr.s	Fade
	addq.w	#1,FaseDelFade	; sistema per la prossima volta la fase da fare
FinitoFadeIn:
	rts


FadeOut:
	tst.w	FaseDelFade	; abbiamo superato l'ultima fase? (16)?
	beq.s	FinitoOut
	subq.w	#1,FaseDelFade	; sistema per la prossima volta la fase da fare
	moveq	#0,d0
	move.w	FaseDelFade(PC),d0
	moveq	#15-1,d7		; D7 = Numero di colori
	lea	TabColoriPic(PC),a0	; A0 = indirizzo tabella dei colori
					; della figura da "dissolvere"
	lea	CopColors+6,a1		; A1 = indirizzo colori in copperlist
					; da notare che parte dal COLOR1 e
					; non dal color0, in quanto il color0
					; e'=$000 e cosi' rimane.
	bsr.s	Fade
FinitoOut:
	rts

FaseDelFade:		; fase attuale del fade (0-16)
	dc.w	0

*****************************************************************************
*		Routine per Fade In/Out da e verso il BIANCO		    *
* Input:								    *
*									    *
* d7 = Numero colori-1							    *
* a0 = Indirizzo tabella con i colori della figura			    *
* a1 = Indirizzo primo colore in copperlist				    *
* d0 = Momento del fade, multiplier - per esempio con d0=0 lo schermo	    *
*	e' bianco totalmente, con d0=8 siamo a meta' fade e con d0=16	    *
*	siamo ai colori pieni; dunque ci sono 17 fasi, dalla 0 alla 16.	    *
*	Per fare un fade IN, dal bianco al colore, si deve dare a ogni	    *
*	chiamata alla routine un valore di d0 crescente da 0 a 16	    *
*	Per un fade OUT, si dovra' partire da d0=16 fino a d0=0		    *
* d6 = colore da aggiungere al fade per dargli certe tonalita'		    *
*									    *
*  Il procedimento di FADE e' quello di moltiplicare ogni componente R,G,B  *
*  del colore per un Multiplier, che va da 0 per il NERO (x*0=0), a 16 per  *
*  i colori normali, dato che poi il colore viene diviso per 16,	    *
*  moltiplicare un colore per 16 e ridividerlo non fa che lasciarlo uguale. *
*									    *
* La modifica consiste semplicemente nell'aggiungere le tonalita' in d6     *
* e dividere il risultato per 2, per evitare di superare un totale di $f    *
*									    *
*****************************************************************************

;	               .-~~~-.
;	             /        }
;	            /      .-~
;	  \        |        }
;	___\.~~-.-~|     .-~_
;	   { O  |  `  -~      ~-._
;	    ~--~/-|_\         .-~
;	       /  |  \~ - - ~
;	      /   |   \

Fade:
	MOVE.W	Tendenza(PC),D6	;	; Maschera di tendenza RGB
Fade1:
	MOVE.W	D6,D1		; copia col. tendenz. in d1
	MOVE.W	D6,D2		; in d2
	MOVE.W	D6,D3		; in d3
	ANDI.W	#$00f,D1	; SELEZ. SOLO BLUE
	ANDI.W	#$0f0,D2	; SELEZ. SOLO GREEN
	ANDI.W	#$f00,D3	; SELEZ. SOLO RED

;	Calcola la componente BLU

	MOVE.W	(A0),D4		; Metti il colore dalla tabella colori in d4
	AND.W	#$00f,D4	; Seleziona solo la componente blu ($RGB->$00B)
; modifica
	ADD.W	D1,D4		; Aggiungi la componente BLU di Tendenza
	LSR.W	#1,D4		; e dividi per 2 tramite uno shift di 1 bit a >
; fine modifica
	MULU.W	D0,D4		; Moltiplica per la fase del fade (0-16)
	ASR.W	#4,D4		; shift 4 BITS a destra, ossia divisione per 16
	AND.W	#$00f,D4	; Seleziona solo la componente BLU
	MOVE.W	D4,D5		; Salva la componente BLU in d5

;	Calcola la componente VERDE (GREEN)

	MOVE.W	(A0),D4		; Metti il colore dalla tabella colori in d4
	AND.W	#$0f0,D4	; Selez. solo la componente verde ($RGB->$0G0)
; modifica
	ADD.W	D2,D4		; Aggiungi la componente VERDE di Tendenza
	LSR.W	#1,D4		; e dividi per 2 tramite uno shift di 1 bit a >
; fine modifica
	MULU.W	D0,D4		; Moltiplica per la fase del fade (0-16)
	ASR.W	#4,D4		; shift 4 BITS a destra, ossia divisione per 16
	AND.W	#$0f0,D4	; Seleziona solo la componente VERDE
	OR.W	D4,D5		; Salva la comp.verde assieme a quella BLU


;	Calcola la componente ROSSA (RED)

	MOVE.W	(A0)+,D4	; leggi il colore dalla tabella
				; e fai puntare a0 al prossimo col.
	AND.W	#$f00,D4	; Selez. solo la componente rossa ($RGB->$R00)
; modifica
	ADD.W	D3,D4		; Aggiungi la componente ROSSA di Tendenza
	LSR.W	#1,D4		; e dividi per 2 tramite uno shift di 1 bit a >
; fine modifica
	MULU.W	D0,D4		; Moltiplica per la fase del fade (0-16)
	ASR.W	#4,D4		; shift 4 BITS a destra, ossia divisione per 16
	AND.W	#$f00,D4	; Selez. solo la componente rossa ($RGB->$R00)
	OR.W	D4,D5		; Salva la c. ROSSA assieme alla BLU e VERDE

	MOVE.W	D5,(A1)		; E metti il colore $0RGB finale in copperlist
	addq.w	#4,a1		; prossimo colore in copperlist
	DBRA	D7,Fade1	; fai tutti i colori
	rts


Tendenza:
	dc.w	0

; il $180, color0, e' $000, dunque non cambia! La tabella parte dal color1

TabColoriPic:
	dc.w $fff,$200,$310,$410,$620,$841,$a73
	dc.w $b95,$db6,$dc7,$111,$222,$334,$99b,$446


*****************************************************************************
;			Copper List
*****************************************************************************
	section	copper,data_c		; Chip data

Copperlist:
	dc.w	$8E,$2c81	; DiwStrt - window start
	dc.w	$90,$2cc1	; DiwStop - window stop
	dc.w	$92,$38		; DdfStart - data fetch start
	dc.w	$94,$d0		; DdfStop - data fetch stop
	dc.w	$102,0		; BplCon1 - scroll register
	dc.w	$104,0		; BplCon2 - priority register
	dc.w	$108,0		; Bpl1Mod - modulo pl. dispari
	dc.w	$10a,0		; Bpl2Mod - modulo pl. pari

		    ; 5432109876543210
	dc.w	$100,%0100001000000000	; BPLCON0 - 4 planes lowres (16 colori)

; Bitplane pointers

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane
	dc.w $ec,$0000,$ee,$0000	;quarto	 bitplane

; i primi 16 colori sono per il LOGO

CopColors:
	dc.w $180,0,$182,0,$184,0,$186,0
	dc.w $188,0,$18a,0,$18c,0,$18e,0
	dc.w $190,0,$192,0,$194,0,$196,0
	dc.w $198,0,$19a,0,$19c,0,$19e,0

;	dc.w $180,$000,$182,$fff,$184,$200,$186,$310
;	dc.w $188,$410,$18a,$620,$18c,$841,$18e,$a73
;	dc.w $190,$b95,$192,$db6,$194,$dc7,$196,$111
;	dc.w $198,$222,$19a,$334,$19c,$99b,$19e,$446

;	Mettiamo un poco di sfumature per la scenografia...

	dc.w	$8007,$fffe	; Wait - $2c+84=$80
	dc.w	$100,$200	; bplcon0 - no bitplanes
	dc.w	$180,$003	; color0
	dc.w	$8207,$fffe	; wait
	dc.w	$180,$005	; color0
	dc.w	$8507,$fffe	; wait
	dc.w	$180,$007	; color0
	dc.w	$8a07,$fffe	; wait
	dc.w	$180,$009	; color0
	dc.w	$9207,$fffe	; wait
	dc.w	$180,$00b	; color0

	dc.w	$9e07,$fffe	; wait
	dc.w	$180,$999	; color0
	dc.w	$a007,$fffe	; wait
	dc.w	$180,$666	; color0
	dc.w	$a207,$fffe	; wait
	dc.w	$180,$222	; color0
	dc.w	$a407,$fffe	; wait
	dc.w	$180,$001	; color0

	dc.l	$ffff,$fffe	; Fine della copperlist


*****************************************************************************
;				DISEGNO
*****************************************************************************

	section	gfxstuff,data_c

; Disegno largo 320 pixel, alto 84, a 4 bitplanes (16 colori).

Logo1:
	incbin	'logo320*84*16c.raw'

	end

Questa e' una semplice modifica della routine precedente.

