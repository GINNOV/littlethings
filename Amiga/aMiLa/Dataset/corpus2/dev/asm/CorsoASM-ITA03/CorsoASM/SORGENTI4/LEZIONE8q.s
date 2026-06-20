
; Lezione8q.s  Utilizzo delle pic con la palette salvata in fondo (BEHIND).
;		Tasto sinistro per "colorare", destro per uscire.

	SECTION	Behind,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

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


mouse:
	btst.b	#6,$bfe001	; Mouse sinistro premuto?
	bne.s	mouse

;	          |||||
;	_____.oOo_/o_O\_oOo.____.

Puntacolori:
	lea	logo1+(40*84*4),a0	; in a0 indirizzo palette dopo pic,
					; ricavabile aggiungendo la lunghezza
					; dei bitplanes all'inizio della
					; pic: rimangono i colori!
	lea	CopColors+2,a1	; Indirizzo registri colore in coplist
	moveq	#16-1,d0	; Numero colori
MettiLoop2:
	move.w	(a0)+,(a1)	; Copia colore da palette a coplist
	addq.w	#4,a1		; Salta al prossimo registro colore
	dbra	d0,mettiloop2	; Fai tutti i colori

mouse2:
	btst.b	#2,$dff016	; Mouse destro premuto?
	bne.s	mouse2

	rts

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
	dc.w $180,0,$182,0,$184,0,$186,0	; Ora sono azzerati, sara' la
	dc.w $188,0,$18a,0,$18c,0,$18e,0	; routine a copiare i valori
	dc.w $190,0,$192,0,$194,0,$196,0	; dal fondo della pic.
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

L'utilita' di mettere la palette nei .raw si nota quando si devono gestire
molte figure, ad esempio in giochi di avventura o negli slideshow.
Ad esempio nel mio "World of Manga" ho usato questo sistema, con le figure
AGA, salvate dall'iffconverter AGA con la palette a 24 bit in fondo.

