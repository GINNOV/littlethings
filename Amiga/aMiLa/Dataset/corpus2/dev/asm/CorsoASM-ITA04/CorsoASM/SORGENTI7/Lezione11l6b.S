
; Lezione11l6b.s	Routine di gestione del modo interlacciato (640x512)
;			che legge il bit 15 (LOF) del VPOSR ($dff004).
;			Premendo il tasto destro non si esegue tale routine,
;			e si nota come rimangano alle volte le linee pari o
;			le dispari in "pseudo-non lace".

	SECTION	Interlaccione,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

WaitDisk	EQU	30

scr_bytes	= 40	; Numero di bytes per ogni linea orizzontale.
			; Da questa si calcola la larghezza dello schermo,
			; moltiplicando i bytes per 8: schermo norm. 320/8=40
			; Es. per uno schermo largo 336 pixel, 336/8=42
			; larghezze esempio:
			; 264 pixel = 33 / 272 pixel = 34 / 280 pixel = 35
			; 360 pixel = 45 / 368 pixel = 46 / 376 pixel = 47
			; ... 640 pixel = 80 / 648 pixel = 81 ...

scr_h		= 256	; Altezza dello schermo in linee
scr_x		= $81	; Inizio schermo, posizione XX (normale $xx81) (129)
scr_y		= $2c	; Inizio schermo, posizione YY (normale $2cxx) (44)
scr_res		= 1	; 2 = HighRes (640*xxx) / 1 = LowRes (320*xxx)
scr_lace	= 1	; 0 = non interlace (xxx*256) / 1 = interlace (xxx*512)
ham		= 0	; 0 = non ham / 1 = ham
scr_bpl		= 4	; Numero Bitplanes

; parametri calcolati automaticamente

scr_w		= scr_bytes*8		; larghezza dello schermo
scr_size	= scr_bytes*scr_h	; dimensione in bytes dello schermo
BPLC0	= ((scr_res&2)<<14)+(scr_bpl<<12)+$200+(scr_lace<<2)+(ham<<11)
DIWS	= (scr_y<<8)+scr_x
DIWSt	= ((scr_y+scr_h/(scr_lace+1))&255)<<8+(scr_x+scr_w/scr_res)&255
DDFS	= (scr_x-(16/scr_res+1))/2
DDFSt	= DDFS+(8/scr_res)*(scr_bytes/2-scr_res)


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
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$01000,d2	; linea da aspettare = $000
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	Beq.S	Waity2

	btst	#2,$16(A5)	; Tasto destro premuto?
	beq.s	NonLaceint

	bsr.s	laceint		; Routine che punta linee pari o dispari
				; ogni frame a seconda del bit LOF per
				; l'interlace
NonLaceint:
	btst.b	#6,$bfe001	; Mouse sinistro premuto?
	bne.s	mouse
	rts

******************************************************************************
; INTERLACE ROUTINE - Testa il bit LOF (Long Frame) per sapere se si devono
; visualizzare le linee pari o quelle dispari, e punta di conseguenza.
******************************************************************************

LACEINT:
	MOVE.L	#Logo1,D0	; Indirizzo bitplanes
	btst.b	#15-8,4(A5)	; VPOSR LOF bit?
	Beq.S	Faidispari	; Se si, tocca alle linee dispari
	ADD.L	#40,D0		; Oppure aggiungi la lunghezza di una linea,
				; facendo partire la visualizzazione dalla
				; seconda: visualizzate linee pari!
FaiDispari:
	LEA	BPLPOINTERS,A1	; PLANE POINTERS IN COPLIST
	MOVEQ	#4-1,D7		; NUM. DI BITPLANES -1
LACELOOP:
	MOVE.W	D0,6(A1)	; Punta la figura
	SWAP	D0
	MOVE.W	D0,2(A1)
	SWAP	D0
	ADD.L	#40*84,D0	; Lunghezza bitplane
	ADDQ.w	#8,A1		; Prossimi pointers
	DBRA	D7,LACELOOP
	RTS

*****************************************************************************
;			Copper List
*****************************************************************************
	section	copper,data_c		; Chip data

Copperlist:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop

	dc.w	$102,0		; BplCon1 - scroll register
	dc.w	$104,0		; BplCon2 - priority register
	dc.w	$108,40		; Bpl1Mod - \ INTERLACE: lungh. di una linea
	dc.w	$10a,40		; Bpl2Mod - / per saltare linee pari o disp.

; Bitplane pointers

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane
	dc.w $ec,$0000,$ee,$0000	;quarto	 bitplane

;		    ; 5432109876543210
;	dc.w	$100,%0100001000000100	; BPLCON0 - 4 planes lowres (16 colori)
;					; INTERLACCIATO (bit 2!)

	dc.w	$100,BPLC0	; BplCon0 - calcolato automaticamente


; i primi 16 colori sono per il LOGO

	dc.w $180,$000,$182,$fff,$184,$200,$186,$310
	dc.w $188,$410,$18a,$620,$18c,$841,$18e,$a73
	dc.w $190,$b95,$192,$db6,$194,$dc7,$196,$111
	dc.w $198,$222,$19a,$334,$19c,$99b,$19e,$446

;	Mettiamo un poco di sfumature per la scenografia...

	dc.w	$5607,$fffe	; Wait - $2c+84=$80
	dc.w	$100,$204	; bplcon0 - no bitplanes, MA BIT LACE SETTATO!
	dc.w	$8007,$fffe	; wait
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
	incbin	'assembler2:sorgenti4/logo320*84*16c.raw'

	end

Avete notato che TUTTI i bplcon0 della copperlist devono avere il bit 2,
quello dell'interlace, settato? Infatti, se l'ultimo BPLCON0 non avesse il
bit settato, nonostante gli altri lo abbiano lo schermo non verrebbe
interlacciato!

