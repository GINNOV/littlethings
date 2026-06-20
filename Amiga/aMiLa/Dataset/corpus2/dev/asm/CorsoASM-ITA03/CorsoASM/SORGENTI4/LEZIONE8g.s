
; Lezione8g.s - Prova di "pavimento" in parallasse - 10 livelli.

*****************************************************************************
*	PARALLAX 0.5	Copyright © 1994 by Federico "GONZO" Stango	    *
*			Modificato da Fabio Ciucci			    *
*****************************************************************************

	SECTION	MAINPROGRAM,CODE	; Sezione Codice: ovunque in memoria

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
	move.l	#PARALLAXPIC,d0		; Carico indirizzo Pic in d0
	lea	BPLPointers,a1		; Indirizzo dei pointers ai planes
	moveq	#5-1,d1			; NumPiani-1 per il DBRA
	move.w	#40*56,d2		; Bit per piano in d2
	bsr.w	PointBpls		; Chiamiamo la subroutine PointBpls

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#MyCopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

MainLoop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.s	ParallaxFX		; Salta alla subroutine "Parallax"

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001		; LMB premuto?
	bne.s	MainLoop		; Se "NO" ricomincia
	rts

******************************************************************************
*			 Parte dedicata alle subroutines		     *
******************************************************************************

; Questa e' la routine di parallasse. Funziona in un modo molto semplice,
; infatti non fa che modificare i valori dei 10 BPLCON1 ($dff102) posti uno
; sotto l'altro con dei WAIT nella zona del "pavimento". Ebbene, abbiamo gia'
; visto nelle lezioni precedenti come si possa far "ondeggiare" una figura
; utilizzando una copperlist con molti BPLCON1 ($dff102), i quali possono
; spostare verso destra la schermata per un massimo di 15 pixel, col valore
; $FF, mentre con $00 lo spostamento e' nullo. Ora, se anziche' ondulare una
; figura vogliamo fare in modo che sembri che scorra all'infinito, il problema
; che si pone e' quello che al massimo possiamo far scorrere la figura di 15
; pixel, e 15 pixel non sono l'infinito. Potremmo anche fare una figura larga
; un chilometro in memoria, e fare lo scroll usando anche i bplpointers, ma
; non sarebbe economico. Dunque dobbiamo fare uno scroll, che sembri infinito,
; verso destra, con una figura larga solo 320 pixel. Il "trucco" e' questo: se
; la figura in questione e' fatta a "blocchetti" uguali larghi 16 pixel ognuno
; si puo' ingannare l'occhio nascondendogli il fatto che spostiamo di soli 15
; pixel e poi "ripartiamo" da zero. Infatti basta avere una "mattonella" larga
; un tot di pixel, ad esempio 16, ripetuta per tutto lo schermo, per simulare
; uno scorrimento continuo, basta, appunto, spostare il tutto un pixel alla
; volta verso destra, fino a che l'ultima "mattonella" a destra e' uscita dal
; bordo e ne e' "entrata" una intera dal bordo sinistro: anziche' scattare
; al sedicesimo pixel, impossibile tra l'altro per la limitazione del BPLCON1,
; basta "indietreggiare" di 15 pixel, ripartire da zero, e' la situazione in
; realta' sara' la stessa di quella che si sarebbe verificata spostando di un
; pixel avanti: l'ultima mattonella sulla destra sarebbe sparita completamente
; e la prima a sinistra sarebbe "entrata" completamente. Per fare dei livelli
; che scorrano a velocita' diverse basta fare in modo che ognuno di questi
; livelli vengano spostati il primo ogni 25 fotogrammi, il secondo ogni 16, e
; cosi' via, fino agli ultimi che devono non solo muoversi ogni fotogramma, ma
; scattare 2 o 4 pixel alla volta per andare piu' veloce di 50Hz.
; Per contare da quanti fotogrammi e' stato eseguito lo scroll di ogni livello
; sono state usati dei contatori che vengono incrementati ogni fotogramma, poi
; con un CMP si controlla se si e' aspettato il numero di fotogrammi giusto.
; PxCounter1,2... sono i contatori, Parallax1,2... sono i BPLCON1 in COPLIST


;	          .=============.
;	         /st!            \
;	____ ___/_________________\___ ____
;	\  (/                         \)  /
;	 \_______________________________/
;	    \__/ ______     ______ \__/
;	    /_\  ¬----/     \----¬  /_\
;	    \/\\_    (_______)    _//\/
;	     \__/ _______________ \__/
;	      /   /\| | | | | |/\   \
;	      \     `-^-^-^-^-'     /
;	       \_____         _____/
;	            `---------'

ParallaxFX:
para1:
	addq.b	#$01,PxCounter1	; Incremento il Contatore di Parallasse 1
	cmpi.b	#25,PxCounter1	; Contatore velocita'=25?
	bne.s	Para2		; non ancora 25 fotogrammi...
	clr.b	PxCounter1	; passati 25 fotogrammi! azzera il contatore
	cmp.b	#$ff,Parallax1	; Abbiamo raggiunto il valore di scroll
				; massimo? (15 pixel verso destra)
	beq.s	riazzera1	; se si, dobbiamo ripartire da zero!
	add.b	#$11,Parallax1	; se non ancora, sposta il livello 1
	bra.s	para2
riazzera1:
	clr.b	Parallax1	; riparti da zero con lo scroll
Para2:
	addq.b	#$01,PxCounter2	; Incremento il Contatore di Parallasse 2
	cmpi.b	#16,PxCounter2	; Contatore velocita'=16?
	bne.s	Para3		; (I commenti sarebbero analoghi a Para1)
	clr.b	PxCounter2
	cmp.b	#$ff,Parallax2
	beq.s	riazzera2
	add.b	#$11,Parallax2	; sposta il livello di parallasse 2
	bra.s	para3
riazzera2:
	clr.b	Parallax2
Para3:
	addq.b	#$01,PxCounter3	; Incremento il Contatore di Parallasse 3
	cmpi.b	#10,PxCounter3	; Contatore velocita'=10?
	bne.s	Para4
	clr.b	PxCounter3
	cmp.b	#$ff,Parallax3
	beq.s	riazzera3
	add.b	#$11,Parallax3	; sposta il livello di parallasse 3
	bra.s	para4
riazzera3:
	clr.b	Parallax3
Para4:
	addq.b	#$01,PxCounter4	; Incremento il Contatore di Parallasse 4
	cmpi.b	#5,PxCounter4	; Contatore velocita'=5?
	bne.s	Para5
	clr.b	PxCounter4
	cmp.b	#$ff,Parallax4
	beq.s	riazzera4
	add.b	#$11,Parallax4	; sposta il livello di parallasse 4
	bra.s	para5
riazzera4:
	clr.b	Parallax4
Para5:
	addq.b	#$01,PxCounter5	; Incremento il Contatore di Parallasse 5
	cmpi.b	#4,PxCounter5	; Contatore velocita'=4?
	bne.s	Para6
	clr.b	PxCounter5
	cmp.b	#$ff,Parallax5
	beq.s	riazzera5
	add.b	#$11,Parallax5	; sposta il livello di parallasse 5
	bra.s	para6
riazzera5:
	clr.b	Parallax5
Para6:
	addq.b	#$01,PxCounter6	; Incremento il Contatore di Parallasse 6
	cmpi.b	#3,PxCounter6	; Contatore velocita'=3?
	bne.s	Para7
	clr.b	PxCounter6
	cmp.b	#$ff,Parallax6
	beq.s	riazzera6
	add.b	#$11,Parallax6	; sposta il livello di parallasse 6
	bra.s	para7
riazzera6:
	clr.b	Parallax6
Para7:
	addq.b	#$01,PxCounter7	; Incremento il Contatore di Parallasse 7
	cmpi.b	#2,PxCounter7	; Contatore velocita'=2?
	bne.s	Para8
	clr.b	PxCounter7
	cmp.b	#$ff,Parallax7
	beq.s	riazzera7
	add.b	#$11,Parallax7	; sposta il livello di parallasse 7
	bra.s	Para8
riazzera7:
	clr.b	Parallax7
				; DA NOTARE CHE PARA8,PARA9,PARA10 DEVONO
				; ESSERE ESEGUITI OGNI FRAME, DUNQUE NON
Para8:				; OCCORRE UN CONTATORE DI RITARDO!
	cmp.b	#$ff,Parallax8	; Abbiamo raggiunto il massimo scroll?
	bne.s	NonRiazzera8
	clr.b	Parallax8	; azzera parallax8
	bra.s	para9
NonRiazzera8:
	add.b	#$11,Parallax8	; sposta il livello di parallasse 8
Para9:
	cmp.b	#$ee,Parallax9	; Abbiamo raggiunto il massimo scroll?
				; Il massimo e' $ee e non $ff perche' questo
				; livello deve scattare a passi di 2 ogni
				; frame, per cui: 00,22,44,66,88,aa,cc,ee
	bne.s	NonRiazzera9
	clr.b	Parallax9	; azzera parallax9
	bra.s	Para10
NonRiazzera9:
	add.b	#$22,Parallax9	; sposta il livello di parallasse 9 (2 pixel!)
Para10:
	cmp.b	#$cc,Parallax10	; Abbiamo raggiunto il massimo scroll?
				; Il massimo e' $cc e non $ff perche' questo
				; livello deve scattare a passi di 4 ogni
				; frame, per cui: 00,44,88,cc
	bne.s	NonRiazzera10
	clr.b	Parallax10	; azzera parallax10
	bra.s	ParaFinito
NonRiazzera10:
	add.b	#$44,Parallax10	; sposta il livello di parallasse 10 (4 pixel)
ParaFinito:
	rts

; Le variabili usate per contare i ritardi per i primi 7 livelli, che devono
; essere spostati una volta ogni 25,16,10 ecc. fotogrammi.

PxCounter1:	dc.b	$00
PxCounter2:	dc.b	$00
PxCounter3:	dc.b	$00
PxCounter4:	dc.b	$00
PxCounter5:	dc.b	$00
PxCounter6:	dc.b	$00
PxCounter7:	dc.b	$00
	even

; SubRoutine per puntare i bitplanes... 

************* d0=Indirizzo picture		| d2=Numero di bit per piano
* PointBpls * d1=NumPiani-1 per il DBRA		|
************* a1=Indirizzo puntatori ai planes	|
PointBpls:
	move.w	d0,6(a1)	; .w bassa nella .w giusta della CopperList
	swap	d0		; Scambia le 2 .w di d0
	move.w	d0,2(a1)	; .w alta nella .w giusta della CopperList
	swap	d0		; Rimetto a posto d0
	add.l	d2,d0		; Aggiungo lungh. bitplane a d0 - pross. bitp.
	addq.w	#8,a1		; indirizzo dei prossimi bplpointers
	dbra	d1,PointBpls	; Ricomincio il ciclo
	rts

*****************************************************************************
	SECTION	PROGDATA,DATA_C		; Dati: Questa va in CHIPRAM	    *
*****************************************************************************

MyCopList:
	dc.w	$8e,$2c91	; DiwStrt (finestra video fatta
				; partire 16 pixel piu' a destra per
				; coprire l'orrore (ehm. errore)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; BplMod1
	dc.w	$10a,0		; BplMod2
	dc.w	$100,$200	; No Bitplanes...

Rainbow:
	dc.w	$180,$a9c
	dc.w	$eb07,$fffe
	dc.w	$180,$bad
	dc.w	$ed07,$fffe
	dc.w	$180,$cbe
	dc.w	$ef07,$fffe
	dc.w	$180,$dce
	dc.w	$f107,$fffe
	dc.w	$180,$ede
	dc.w	$f307,$fffe
	dc.w	$180,$fef

	dc.w	$f407,$fffe	; wait - aspetta

	dc.w	$100,%0101001000000000	; LowRes 32Colors

BPLPointers:
	dc.w	$e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w	$e4,$0000,$e6,$0000	;secondo bitplane
	dc.w	$e8,$0000,$ea,$0000	;terzo	 bitplane
	dc.w	$ec,$0000,$ee,$0000	;quarto	 bitplane
	dc.w	$f0,$0000,$f2,$0000	;quinto	 bitplane

	dc.w	$0180
Colours:
	dc.w	$fff,$182,$f10,$184,$f21,$186,$f42
	dc.w	$188,$f53,$18a,$f63,$18c,$f74,$18e,$f85
	dc.w	$190,$f96,$192,$fa6,$194,$fb7,$196,$fb8
	dc.w	$198,$fc9,$19a,$f21,$19c,$f10,$19e,$f00
	dc.w	$1a0,$eff,$1a2,$eff,$1a4,$dff,$1a6,$dff
	dc.w	$1a8,$cff,$1aa,$bef,$1ac,$bef,$1ae,$adf
	dc.w	$1b0,$9df,$1b2,$9cf,$1b4,$8bf,$1b6,$7bf
	dc.w	$1b8,$7af,$1ba,$69f,$1bc,$68f,$1be,$57f


; ECCO LA PARTE DI COPPERLIST RESPONSABILE DELLA PARALLASSE:

	dc.w	$f507,$fffe	; Wait linea $f5
	dc.w	$180,$f52	; Color0 - sfondo arancione per "mimetizzarsi"
				; con la figura

	dc.w	$102		; BPLCON1
	dc.b	$00		; byte alto, non usato
Parallax1:
	dc.b	$00		; byte basso, valore di scroll!!!!

	dc.w	$f607,$fffe	; wait
	dc.w	$102		; BPLCON1
	dc.b	$00		; eccetera, per ogni "livello"
Parallax2:
	dc.b	$00

	dc.w	$f807,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax3:
	dc.b	$00

	dc.w	$fb07,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax4:
	dc.b	$00

	dc.w	$ff07,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax5:
	dc.b	$00

	dc.w	$ffdf,$fffe	; per superare la linea $FF

	dc.w	$0407,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax6:
	dc.b	$00

	dc.w	$0b07,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax7:
	dc.b	$00

	dc.w	$1207,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax8:
	dc.b	$00

	dc.w	$1a07,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax9:
	dc.b	$00

	dc.w	$2307,$fffe
	dc.w	$102	; BPLCON1
	dc.b	$00
Parallax10:
	dc.b	$00

	dc.w	$2c07,$fffe
	dc.w	$180,$f30

	dc.w	$FFFF,$FFFE	; Fine CopList

; L'immagine e' larga 320 pixel e alta 56, a 5 bitplanes (32 colori)

PARALLAXPIC:
	incbin	"Lava320*56*5.Raw"	; Includo l'immagine.

	END

Questo listatuccio lo ha fatto il mio allievo "Gonzo" una volta letta la
LEZIONE5. Mi telefono' chiedendomi come fare un parallasse, e gli ho risposto
prontamente che una volta letta la lezione 5 sarebbe stato in grado di farne
uno, nonostante non ci fosse un listato specifico. Come vedete ha intuito bene
come fare. C'e' pero' un erroruccio, facilmente removibile, ossia il fatto che
avviene il classico "errore" dello scroll nei primi 16 pixel a sinistra. La
figura infatti e' larga solo 320 pixel, per cui quando sposta i vari livelli
di parallasse porta via anche la parte sinistra del livello in questione. Per
vedere l'errore riportate a livelli normali il DiwStart, che in questo listato
e' modificato per "tappare" il problema:

	dc.w	$8e,$2c91	; DiwStrt (finestra video fatta
				; partire 16 pixel piu' a destra per
				; coprire l'orrore ehm. errore)

Sostituitelo con lo standard $2c81 e noterete il danno sulla sinistra.
Per ovviare definitivamente al problema, basta fare come abbiamo fatto per lo
scroll di una figura piu' grande dello schermo: occore ridisegnare la figura
della pavimentazione facendola 16 pixel piu' larga, ossia 336 pixel, cioe'
dobbiamo aggiungere una "mattonella" in piu'. A questo punto occorre puntare
la figura ricordandosi di questo "allargamento", agendo proprio come nel caso
dello scroll "gigante", lasciando agire l'errore nei 16 pixel "fuori schermo"
sulla sinistra.
Questa e' solo una base per un pavimento in parallasse. Si potrebbe anche fare
uno scorrimento piu' fluido, linea per linea, calcolandolo con precisione
matematica con una tabella, e si potrebbe cambiare anche la palette per ogni
livello per sfumare maggiormente i colori. Se avete voglia poi di aggiungere
le nuvole in parallasse, le montagnine e gli uccellini, vi prego di spedirmi
l'opera!

