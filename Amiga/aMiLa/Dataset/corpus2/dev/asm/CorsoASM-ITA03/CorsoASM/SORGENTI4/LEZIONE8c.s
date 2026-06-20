
; Una routine di FADE (ossia dissolvenza) da e verso il NERO. ROUTINE N.1
; Premere il tasto sinistro e destro

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

	clr.w	FaseDelFade	; azzera il numero del fotogramma

;	********** primo fade: dal NERO ai colori *********

mouse2:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse2
Aspetta1:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta1

	bsr.w	FadeIN		; Fade!!!

	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2

	move.w	#16,FaseDelFade	; azzera il numero del fotogramma

;	********** secondo fade: dai colori al NERO *********

mouse3:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse3
Aspetta2:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta2

	bsr.w	FadeOUT	; Fade!!!

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse3
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
*		Routine per Fade In/Out da e verso il NERO		    *
* Input:								    *
*									    *
* d7 = Numero colori-1							    *
* a0 = Indirizzo tabella con i colori della figura			    *
* a1 = Indirizzo primo colore in copperlist				    *
* d0 = Momento del fade, multiplier - per esempio con d0=0 lo schermo	    *
*	e' nero totalmente, con d0=8 siamo a meta' fade e con d0=16	    *
*	siamo ai colori pieni; dunque ci sono 17 fasi, dalla 0 alla 16.	    *
*	Per fare un fade IN, dal nero al colore, si deve dare a ogni	    *
*	chiamata alla routine un valore di d0 crescente da 0 a 16	    *
*	Per un fade OUT, si dovra' partire da d0=16 fino a d0=0		    *
*									    *
*  Il procedimento di FADE e' quello di moltiplicare ogni componente R,G,B  *
*  del colore per un Multiplier, che va da 0 per il NERO (x*0=0), a 16 per  *
*  i colori normali, dato che poi il colore viene diviso per 16,	    *
*  moltiplicare un colore per 16 e ridividerlo non fa che lasciarlo uguale. *
*									    *
*****************************************************************************


;	        \   / 
;	        .\-/.
;	    /\ ()   ()
;	   /  \/~---~\.-~^-.
;	.-~^-./   |   \---.
;	     {    |    }   \
;	   .-~\   |   /~-.
;	  /    \  I  /    \
;	        \/ \/

Fade:
ColorLoop:
	moveq	#0,d1		; azzera D1
	moveq	#0,d2		; azzera D2

; Trova la componente risultante ROSSA (Red) ed inseriscila in copperlist ($0R)

	move.b	(a0)+,d1	; D1.b = componente RED (ROSSA) del colore
				; ossia $0R (la word e' $0RGB)
	mulu.w	d0,d1		; Moltiplicalo per il livello colore attuale
	lsr.w	#4,d1		; Dividilo per 16 (con LSR #4), portando il
				; risultato a destra (il byte e' %00001111)
	move.b	d1,(a1)+	; Inserisci la nuova componente ROSSA in
				; copperlist (ossia il byte $0R)

; Trova la componente risultante VERDE (Green) e mettila in d1

	move.b	(a0),d1		; D1.b = componente Green,Blue (VERDE,BLU)
				; ossia $GB (la word e' $0RGB)
	lsr.b	#4,d1		; Metti il VERDE tutto a destra spostando
				; il valore a destra di 4 bit (1 nibble)
				; dunque in d1.b abbiamo solo il verde
	mulu.w	d0,d1		; Moltiplicalo per il livello colore attuale
	and.b	#$f0,d1		; Mascheriamo per selezionare solo il risultato
				; che a questo punto e' pronto, non occorre
				; spostarlo a destra, dato che nel registro
				; colore si trova proprio in questa posizione.
				; infatti il byte basso e' $GB (la word $0RGB)

;  Trova la componente risultante BLU e mettila in d2

	move.b	(a0)+,d2	; D2.b = componente Green,Blue (VERDE,BLU)
				; ossia $GB (la word e' $0RGB)
	and.b	#$0f,d2		; Mascheriamo per selezionare solo il BLU ($0B)
	mulu.w	d0,d2		; Moltiplicalo per il livello colore attuale
	lsr.w	#4,d2		; Dividi per 16, portando il risultato a destra
				; in modo che il risultato sia $0B

; Unisci con OR la componente risultante VERDE con quella BLU

	or.w	d2,d1		; OR del BLU con il VERDE per "unirli" nel byte
				; finale risultante: $GB

; E metti il byte risultante $GB in copperlist

	move.b	d1,(a1)+	; Inserisci il valore del VERDE e del BLU nel
				; byte basso $GB del colore in copperlist
	addq.w	#2,a1		; Vai al prossimo colore i copperlist, saltando
				; la word del $18x
	dbra	d7,ColorLoop	; ripeti per gli altri colori
	rts


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

; Il logo e' copyright FLENDER/RAM JAM

Logo1:
	incbin	'logo320*84*16c.raw'

	end

Questo listato offre la visione di un FADE, ossia di una dissolvenza dal
NERO al colore, e dal colore al NERO. Dato che la routine FADE richiede
di essere richiamata 16 volte per trasformare i colori dal NERO a quelli
finali, e altre 16 volte per tornare al nero dai colori, e' stato necessario
scrivere 2 routines ausiliarie, FadeIn e FadeOut, che richiamano la
routine Fade, quella vera e propria, passandogli un valore del Multiplier
diverso ogni volta, salvata nella label FaseDelFade.
Il procedimento di FADE e' quello di moltiplicare ogni componente R,G,B del
colore per un Multiplier, che va da 0 per il NERO (x*0=0), a 16 per i colori
normali, dato che poi il colore viene diviso per 16, moltiplicare un colore
per 16 e ridividerlo non fa che lasciarlo invariato.
La routine di questo esempio e' la NUMERO 1, e lavora separatamente sui
due bytes della word colore. Il prossimo listato contiene una routine che
usa lo stesso procedimento della moltiplicazione per il multiplier e della
divisione per 16, ma non aggiorna la word colore un byte alla volta, e forse
puo' risultarvi piu' chiara. Comunque, o capite questo esempio o il prossimo!

