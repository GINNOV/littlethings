
; Lezione15e.s	- Visualiziamo la prima pic in ham8 a 256000 possibili colori.
;		  DA NOTARE CHE BASTA SETTARE 64 REGISTRI COLORE PER LA
;		  PALETTE, I RESTANTI 192 SONO IGNORATI.

	SECTION	AgaRulez,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper, bitplane DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;	Puntiamo la pic AGA

	MOVE.L	#PICTURE,d0
	LEA	BPLPOINTERS,A1
	MOVEQ	#8-1,D7		; num. bitplanes
POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addi.l	#80*100,d0	; Lunghezza di un bitplane
	addq.w	#8,a1
	dbra	d7,POINTB		;Rifai D1 volte (D1=num of bitplanes)

	bsr.s	MettiColori

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

LOOP:
	BTST	#6,$BFE001	; aspetta il mouse
	BNE.S	LOOP
	RTS


; Questa routine, che e' presente anche nella mia demo WORLD OF MANGA, serve
; per leggere la palette a 24 bit, in questo caso inclusa con un INCBIN
; In pratica converte ogni colore a 24 bit, che si presenta nel formato di
; una long $00RrGgBb, dove R = nibble alto di RED, r = nibble basso di RED,
; G = nibble alto di GREEN eccetera, nel formato della copperlist aga, ossia
; in due word $0RGB con i nibble alti e $0rgb con i nibble bassi.

MettiColori:
	LEA	LogoPal(PC),A0		; indirizzo della color palette 
	LEA	COLP0+2,A1		; Indirizzo del primo registro
					; settato per i nibble ALTI
	LEA	COLP0B+2,A2		; Indirizzo del primo registro
					; settato per i nibble BASSI
	MOVEQ	#2-1,d7			; 2 banchi da 32 registri ciascuno
					; *NOTA: IN HAM8 BASTA DEFINIRE UNA
					; PALETTE DI 64 COLORI! GLI ALTRI
					; REGISTRI COLORE DAL 65 AL 255 SONO
					; IGNORATI TOTALMENTE!
ConvertiPaletteBank:
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#32-1,d6	; 32 registri colore per banco

DaLongARegistri:	; loop che trasforma i colori $00RrGgBb.l nelle 2
			; word $0RGB, $0rgb adatte ai registri copper.

; Conversione dei nibble bassi da $00RgGgBb (long) al colore aga $0rgb (word)

	MOVE.B	1(A0),(a2)	; Byte alto del colore $00Rr0000 copiato
				; nel registro cop per nibble bassi
	ANDI.B	#%00001111,(a2) ; Seleziona solo il nibble BASSO ($0r)
	move.b	2(a0),d2	; Prendi il byte $0000Gg00 dal colore a 24bit
	lsl.b	#4,d2		; Sposta a sinistra di 4 bit il nibble basso
				; del GREEN, "trasformandolo" in nibble alto
				; di del byte basso di D2 ($g0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24bit
	ANDI.B	#%00001111,d3	; Seleziona solo il nibble BASSO ($0b)
	or.b	d2,d3		; "FONDI" i nibble bassi di green e blu...
	move.b	d3,1(a2)	; Formando il byte basso finale $gb da mettere
				; nel registro colore, dopo il byte $0r, per
				; formare la word $0rgb dei nibble bassi

; Conversione dei nibble alti da $00RgGgBb (long) al colore aga $0RGB (word)

	MOVE.B	1(A0),d0	; Byte alto del colore $00Rr0000 in d0
	ANDI.B	#%11110000,d0	; Seleziona solo il nibble ALTO ($R0)
	lsr.b	#4,d0		; Shifta a destra di 4 bit il nibble, in modo
				; che diventi il nibble basso del byte ($0R)
	move.b	d0,(a1)		; Copia il byte alto $0R nel color register
	move.b	2(a0),d2	; Prendi il byte $0000Gg00 dal colore a 24bit
	ANDI.B	#%11110000,d2	; Seleziona solo il nibble ALTO ($G0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24 bit
	ANDI.B	#%11110000,d3	; Seleziona solo il nibble ALTO ($B0)
	lsr.b	#4,d3		; Shiftalo di 4 bit a destra trasformandolo in
				; nibble basso del byte basso di d3 ($0B)
	ori.b	d2,d3		; Fondi i nibble alti di green e blu ($G0+$0B)
	move.b	d3,1(a1)	; Formando il byte basso finale $GB da mettere
				; nel registro colore, dopo il byte $0R, per
				; formare la word $0RGB dei nibble alti.

	addq.w	#4,a0		; Saltiamo al prossimo colore .l della palette
				; attaccata in fondo alla pic
	addq.w	#4,a1		; Saltiamo al prossimo registro colore per i
				; nibble ALTI in Copperlist
	addq.w	#4,a2		; Saltiamo al prossimo registro colore per i
				; nibble BASSI in Copperlist

	dbra	d6,DaLongARegistri

	add.w	#(128+8),a1	; salta i registri colore + il dc.w $106,xxx
				; dei nibble ALTI
	add.w	#(128+8),a2	; salta i registri colore + il dc.w $106,xxx
				; dei nibble BASSI

	dbra	d7,ConvertiPaletteBank	; Converte un banco da 32 colori per
	rts				; loop. 8 loop per i 256 colori.

; Palette salvata in binario con il PicCon (opzioni: save as binary, non cop)
; NOTA: ESSENDO LA PALETTE DI UNA PIC HAM, CONTIENE SOLO 64 COLORI, NON 256.

LogoPal:
	incbin	"pic640x100xham8.pal"

;*****************************************************************************
;*				COPPERLIST				     *
;*****************************************************************************

	CNOP	0,8	; Allineo a 64 bit

	section	coppera,data_C

COPLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop

; Nota: il ddfstart/stop HIRES sarebbero $003c e $00d4, ma con il burst attivo
; va bene lo stesso valore del LOWRES, ossia $0038 e $00d0.

	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,-8		; Bpl1Mod (burst 64bit, modulo=modulo-8)
	dc.w	$10a,-8		; Bpl2Mod (come sopra)

		    ; 5432109876543210
	dc.w	$100,%1000101000010001	; 8 bitplane HIRES 640x256 HAM8. Per
					; settare 8 planes setto il bit 4 e
					; azzero i bit 12,13,14. Il bit 0 e'
					; settato dato che abilita molte
					; funzioni AGA che vedremo dopo.
					; Settando il bit 11 attivo l'HAM8

	dc.w	$1fc,3		; Burst mode a 64 bit

; Il RAW e' salvato con PicCon, dunque si puo' puntare normalmente.

BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo 	bitplane
	dc.w $e4,0,$e6,0	; secondo	   "
	dc.w $e8,0,$ea,0	; terzo		   "
	dc.w $ec,0,$ee,0	; quarto	   "
	dc.w $f0,0,$f2,0	; quinto	   "
	dc.w $f4,0,$f6,0	; sesto		   "
	dc.w $f8,0,$fA,0	; settimo	   "
	dc.w $fC,0,$fE,0	; ottavo	   "

; Questo e' l'ordine dei bitplanes se salvate il RAW con AgaConv
;
;	dc.w $e8,0,$ea,0	; terzo	       bitplane
;	dc.w $ec,0,$ee,0	; quarto	   "
;	dc.w $f0,0,$f2,0	; quinto	   "
;	dc.w $f4,0,$f6,0	; sesto		   "
;	dc.w $f8,0,$fA,0	; settimo	   "
;	dc.w $fC,0,$fE,0	; ottavo	   "
;	dc.w $e0,0,$e2,0	; primo 	   "
;	dc.w $e4,0,$e6,0	; secondo	   "


; In questo caso la palette viene aggiornata da una routine, per cui basta
; lasciare azzerati i valori dei registri.

; *NOTA: IN HAM8 BASTA DEFINIRE 64 COLORI, NON TUTTI E 255!!!!!

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
COLP0:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
COLP0B:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2C00	; SELEZIONA PALETTE 1 (32-63), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2E00	; SELEZIONA PALETTE 1 (32-63), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	dc.w	$9007,$fffe	; aspetta la fine del logo
	dc.w	$100,$200	; zero bitplanes

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;******************************************************************************

; Figura RAW ad 8 bitplanes, in HAM8.

	CNOP	0,8	; allineo a 64 bit

PICTURE:
	INCBIN	"pic640x100xham8.RAW"

	end

La particolarta' che avrete notato, e' che la palette e' composta da solo
64 colori. Basta settare il bit 11 di bplcon0, quello dell'HAM, e il gioco
e' fatto. Non dimenticatevi il particolare dello scambio dei bitplanes 
(puntandoli come nell'esempio in copperlist) nel caso che salviate il RAW con
un Iffconverter che non li scambia da solo, come invece fa il PicCon.

