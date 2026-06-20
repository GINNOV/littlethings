
; Una routine di FADE (ossia dissolvenza) da e verso il QUALSIASI COLORE
; Premere il tasto sinistro e destro alternativamente per vedere i vari
; utilizzi della routine e per uscire

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

;	********** primo fade: dal NERO ai colori *********

mouse2:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse2
Aspetta1:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta1

	lea	Cstart1-2,a1	; Start-colour-table
	lea	Cend1-2,a2	; End-colour-table
	bsr.w	dofade		; Fade!!!


	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2

	clr.w	FaseDelFade		; azzera il numero del fotogramma

;	********** secondo fade: dai colori al NERO *********

mouse3:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse3
Aspetta2:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta2

	lea	Cstart2-2,a1	; Start-colour-table
	lea	Cend2-2,a2	; End-colour-table
	bsr.w	dofade		; Fade!!!


	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse3

	clr.w	FaseDelFade		; azzera il numero del fotogramma

;	********** terzo fade: dal BIANCO ai colori *********

mouse4:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse4
Aspetta3:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta3

	lea	Cstart3-2,a1	; Start-colour-table
	lea	Cend3-2,a2	; End-colour-table
	bsr.w	dofade		; Fade!!!


	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse4

	clr.w	FaseDelFade		; azzera il numero del fotogramma

;	********** quarto fade: dai COLORI ad altri colori diversi! *********

mouse5:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse5
Aspetta4:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta4

	lea	Cstart4-2,a1	; Start-colour-table
	lea	Cend4-2,a2	; End-colour-table
	bsr.w	dofade		; Fade!!!


	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse5

	clr.w	FaseDelFade		; azzera il numero del fotogramma

;	********** quinto fade: dai COLORI ad altri colori diversi! *********

mouse6:
	CMP.b	#$ff,$dff006	; linea 255
	bne.s	mouse6
Aspetta5:
	CMP.b	#$ff,$dff006	; linea 255
	beq.s	Aspetta5

	lea	Cstart5-2,a1	; Start-colour-table
	lea	Cend5-2,a2	; End-colour-table
	bsr.w	dofade		; Fade!!!

	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse6

	rts


*****************************************************************************
*	Routine per Fade In/Out da e verso qualsiasi colore!		    *
* Input:								    *
*									    *
* d6 = Numero colori-1							    *
* a1 = Indirizzo tabella1 con i colori della figura (sorgente)		    *
* a2 = Indirizzo tabella2 con i colori della figura (destinazione)	    *
* a0 = Indirizzo primo colore in copperlist				    *
* label FaseDelFade usata come il d0 per le routines precedenti,	    *
*   = Momento del fade, multiplier, in questo caso pero' occorre azzerarlo  *
*     semplicemente per far partire un nuovo fade			    *
*									    *
*  Il funzionamento della routine e' piu' complesso delle precedenti, e     *
*  per la verita' non mi ricordo neppure io come funziona esattamente.      *
*  Leggete i miei vecchi commenti, comunque basta che sappiate come usarla  *
*									    *
*****************************************************************************

;	           .--._.--. 
;	          ( O     O ) 
;	          /   . .   \ 
;	         .`._______.'. 
;	        /(    \_/    )\ 
;	      _/  \  \   /  /  \_ 
;	   .~   `  \  \ /  /  '   ~. 
;	  {    -.   \  V  /   .-    } 
;	_ _`.    \  |  |  |  /    .'_ _ 
;	>_       _} |  |  | {_       _< 
;	 /. - ~ ,_-'  .^.  `-_, ~ - .\ 
;	         '-'|/   \|`-` 

dofade:
	cmp.w	#17,FaseDelFade	; abbiamo superato l'ultima fase? (16)?
	beq.s	FadeFinito
	lea	CopColors+2,a0	; Copper
	move.w	#15-1,d6	; No.  colours
	bsr.w	fade2		; Do fading!
FadeFinito:
	rts

; Uses d0-d6/a0-a2

fade2:
f2main:
	addq.w	#4,a0	; vai al prossimo registro colore in copperlist
	addq.w	#2,a1	; vai al prossimo colore della tabella colori sorg.
	addq.w	#2,a2	; idem per la tabella colori destinaz.
	move.w	(a0),d0		; colore dalla copperlist in d0
	move.w	(a2),d1		; col. tab destinazione in d1
	cmp.w	d0,d1		; sono uguali?
	beq.w	ProssimoColore		; se si, vai al prossimo colore
	move.w	FaseDelFade(PC),d4	; fase del fade in d4 (0-16)
	clr.w	ColoreFinale		; azzera il colore finale

;	BLU

	move.w	(a1),d0		; colore attuale della tab sorgente in d0
	move.w	(a2),d2		; colore tab destinazione in d2
	and.l	#$00f,d0	; selez. solo il BLU dal colore tab sorgente
	and.l	#$00f,d2	; idem per colore tab destinazione
	cmp.w	d2,d0		; i BLU sorg. e destinazione sono uguali?
	bhi.b	SottraiD2	; se d2>d0, FadCh1a
	beq.b	SottraiD2	; se sono uguali, Sottrai d2
	sub.w	d0,d2		; se d2<d0, subba d0 a d2!
	bra.b	SottFatto
SottraiD2:
	sub.w	d2,d0		; altrimenti subba d2 a d0!
	bra.b	SottFatto2

SottFatto:
	move.w	d2,d0
SottFatto2:
	moveq	#16,d1
	bsr.w	dodivu
	and.w	#$00f,d1	; seleziona solo BLU
	move.w	(a1),d0		; colore attuale della tab sorgente in d0
	move.w	(a2),d2		; colore tab destinazione in d2
	and.w	#$00f,d0	; selez. solo il BLU dal colore tab sorgente
	and.w	#$00f,d2	; idem per colore tab destinazione
	cmp.w	d0,d2		; i BLU sorg. e destinazione sono uguali?
	bhi.b	SommaD1		; se d0>d2, somma d1 a d0
	beq.b	OkBlu		; se sono uguali, ok
	sub.w	d1,d0		; d0=d0-d1
	bra.b	OkBlu
SommaD1:
	add.w	d1,d0		; d0=d0+d1
OkBlu:
	move.w	d0,ColoreFinale	; Salviamo il BLU finale

; VERDE

	move.w	(a1),d0		; colore attuale della tab sorgente in d0
	move.w	(a2),d2		; colore tab destinazione in d2
	and.l	#$0f0,d0	; selez. solo il VERDE dal colore tab sorgente
	and.l	#$0f0,d2	; idem per colore tab destinazione
	cmp.w	d2,d0		; i VERDE sorg. e destinazione sono uguali?
	bhi.b	SottraiD2v	; se d2>d0, FadCh1a
	beq.b	SottraiD2v	; se sono uguali, Sottrai d2
	sub.w	d0,d2		; se d2<d0, subba d0 a d2!
	bra.b	SottFattov
SottraiD2v:
	sub.w	d2,d0		; altrimenti subba d2 a d0!
	bra.b	SottFatto2v

SottFattov:
	move.w	d2,d0
SottFatto2v:
	moveq	#16,d1
	bsr.w	dodivu
	and.w	#$0f0,d1	; seleziona solo VERDE
	move.w	(a1),d0		; colore attuale della tab sorgente in d0
	move.w	(a2),d2		; colore tab destinazione in d2
	and.w	#$0f0,d0	; selez. solo il VERDE dal colore tab sorgente
	and.w	#$0f0,d2	; idem per colore tab destinazione
	cmp.w	d0,d2		; i VERDE sorg. e destinazione sono uguali?
	bhi.b	SommaD1v	; se d0>d2, somma d1 a d0
	beq.b	OkVERDE		; se sono uguali, ok
	sub.w	d1,d0		; d0=d0-d1
	bra.b	OkVERDE
SommaD1v:
	add.w	d1,d0		; d0=d0+d1
OkVERDE:
	or.w	d0,ColoreFinale	; con l'OR sistema la componente verde

;	ROSSO

	move.w	(a1),d0		; colore attuale della tab sorgente in d0
	move.w	(a2),d2		; colore tab destinazione in d2
	and.l	#$f00,d0	; selez. solo il ROSSO dal colore tab sorgente
	and.l	#$f00,d2	; idem per colore tab destinazione
	cmp.w	d2,d0		; i ROSSO sorg. e destinazione sono uguali?
	bhi.b	SottraiD2r	; se d2>d0, FadCh1a
	beq.b	SottraiD2r	; se sono uguali, Sottrai d2
	sub.w	d0,d2		; se d2<d0, subba d0 a d2!
	bra.b	SottFattor
SottraiD2r:
	sub.w	d2,d0		; altrimenti subba d2 a d0!
	bra.b	SottFatto2r

SottFattor:
	move.w	d2,d0
SottFatto2r:
	moveq	#16,d1
	bsr.w	dodivu
	and.w	#$f00,d1	; seleziona solo ROSSO
	move.w	(a1),d0		; colore attuale della tab sorgente in d0
	move.w	(a2),d2		; colore tab destinazione in d2
	and.w	#$f00,d0	; selez. solo il ROSSO dal colore tab sorgente
	and.w	#$f00,d2	; idem per colore tab destinazione
	cmp.w	d0,d2		; i ROSSO sorg. e destinazione sono uguali?
	bhi.b	SommaD1r	; se d0>d2, somma d1 a d0
	beq.b	OkROSSO		; se sono uguali, ok
	sub.w	d1,d0		; d0=d0-d1
	bra.b	OkROSSO
SommaD1r:
	add.w	d1,d0		; d0=d0+d1
OkROSSO:
	or.w	d0,ColoreFinale	; con l'OR sistema la componente rossa

;	Metti il colore in copperlist!

	move.w	ColoreFinale(PC),(a0)	; e metti il colore finale in copper!

ProssimoColore:
	dbra	d6,f2main	; ripeti per ogni colore

	addq.w	#1,FaseDelFade	; sistema per la prossima volta la fase da fare
nocrs:
	rts

***
*	Input -> D0 = Numeratore
*		 D1 = Denominatore	(16)
*		 D4 = * fattore di moltiplicazione
*
* Output -> D1 = Risultato
***

DoDivu:
	divu.w	d1,d0	; divisione per 16, non ottimizzabilr con lsr
	move.l	d0,d1
	swap	d1
	move.l	#$31000,d2	;$10003 (65539) divu 16
	moveq	#0,d3
	move.w	d1,d3
	mulu.w	d3,d2
	move.w	d2,d1

	and.l	#$ffff,d1
	mulu.w	d4,d1		; moltiplica per la fase del fade
	swap	d1
	mulu.w	d4,d0		; moltiplica per la fase del fade
	add.w	d0,d1
	and.l	#$ffff,d1
	rts

FaseDelFade:		; fase attuale del fade (0-16)
	dc.w	0

;	In questa label viene salvato il colore finale ogni volta

ColoreFinale:
	dc.w	0

; ---

Cstart1:
	dcb.w	15,0	; partiamo dal nero
Cend1:
	dc.w $fff,$200,$310,$410,$620,$841,$a73		; e arriviamo ai colori
	dc.w $b95,$db6,$dc7,$111,$222,$334,$99b,$446
;=----------

Cstart2:
	dc.w $fff,$200,$310,$410,$620,$841,$a73		; partiamo dai colori
	dc.w $b95,$db6,$dc7,$111,$222,$334,$99b,$446
Cend2:
	dcb.w	15,0			; e finiamo al nero
;=----------

Cstart3:
	dcb.w	15,$FFF	; partiamo dal BIANCO
Cend3:
	dc.w $fff,$200,$310,$410,$620,$841,$a73		; e arriviamo ai colori
	dc.w $b95,$db6,$dc7,$111,$222,$334,$99b,$446
;=----------

Cstart4:
	dc.w $fff,$200,$310,$410,$620,$841,$a73		; partiamo dai colori
	dc.w $b95,$db6,$dc7,$111,$222,$334,$99b,$446
Cend4:
	dc.w $fff,$020,$031,$041,$062,$184,$3a7		; e arriviamo colori
	dc.w $5b9,$6db,$7dc,$111,$222,$433,$b99,$644	; diversi! (tono verde)
;=----------

Cstart5:
	dc.w $fff,$020,$031,$041,$062,$184,$3a7		; partiamo dai colori
	dc.w $5b9,$6db,$7dc,$111,$222,$433,$b99,$644	; diversi! (tono verde)
Cend5:
	dc.w $fff,$002,$013,$014,$026,$148,$37a		; ad altri ancora
	dc.w $59b,$6bd,$7cd,$111,$222,$334,$99b,$446	; diversi! (tono blu)
;=----------


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

Ecco una routine che "trasforma" i colori come vogliamo.
Il principio di funzionamento e' piu' complesso di un normale fade, quindi
basta che capiate come si puo' usare. Se volete friggervi il cervello,
comunque, ho messo dei commenti.

