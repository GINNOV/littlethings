
; Lezione15c5.s	- 	Fade a 24bit in tempo reale, non precalcolato

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
	MOVEQ	#8-1,D7		; num of bitplanes -1
POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addi.l	#10240,d0	; lenght of bitplane
	addq.w	#8,a1
	dbra	d7,POINTB	; Rifai D7 volte (D7=num of bitplanes)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

LOOP:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$08000,d2	; linea da aspettare = $80
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $80
	BNE.S	Waity1

	bsr.s	MainFadeInOut	; Routine che sfuma dal nero al colore pieno
				; e viceversa.

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$08000,d2	; linea da aspettare = $110
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $110
	BEQ.S	Aspetta

	BTST	#6,$BFE001
	BNE.S	LOOP
	RTS

*****************************************************************************
* Questa routine incrementa o decrementa il MULTIPLIER per il fadeIn/Out    *
* FlagFadeInOut e' usata per controllare se il fade e' In o Out.	    *
*****************************************************************************

MainFadeInOut:
	BSR.w	CalcolaMettiCol ; Calcola i 256 colori in questa fase del
				; fade, a seconda del MULTIPLIER, li converte
				; nelle word per la copperlist AGA e li copia
				; nella copperlist stessa.

	BTST.b	#1,FlagFadeInOut ; Fade In o fade Out?
	BNE.S	FadeOut
FadeIn:
	ADDQ.W	#1,MULTIPLIER	; Prossima fase del fade (piu' chiaro)
	CMP.W	#255,MULTIPLIER	; Siamo arrivati alla massima chiarezza
				; del fade? (Colori pieni e lucenti)
	BNE.s	NonFinito	; Se non ancora, -> NonFinito
	BCHG.B	#1,FlagFadeInOut ; Altrimenti cambia la direzione del fade
FadeOut:
	SUBQ.W	#1,MULTIPLIER	; Prossima fase del fade (piu' scuro)
	BNE.W	NonFinito	; multiplier=zero? Se non ancora -> Nonfinito
	BCHG.B	#1,FlagFadeInOut ; Altrimenti cambia la direzione del fade
NonFinito:
	RTS

FlagFadeInOut:		; Usato per decidere se FadeIn o FadeOut
	dc.w	0

MULTIPLIER:
	dc.w	0

Temporaneo:
	dc.l	0

******************************************************************************
* Questa routine converte i colori a 24 bit, che si presentano come una      *
* longword $00RrGgBb, (dove R = nibble alto di RED, r = nibble basso di RED, *
* G = nibble alto di GREEN eccetera), nel formato della copperlist aga,      *
* ossia in due word: $0RGB con i nibble alti e $0rgb con i nibble bassi.     *
******************************************************************************

CalcolaMettiCol:
	LEA	temporaneo(PC),A0 	; Long temporanea per colore a 24
					; bit nel formato $00RrGgBb
	LEA	COLP0+2,A1		; Indirizzo del primo registro
					; settato per i nibble ALTI
	LEA	COLP0B+2,A2		; Indirizzo del primo registro
					; settato per i nibble BASSI
	LEA	palettepic(PC),A3	; 24bit colors tab address

	MOVEQ	#8-1,d7			; 8 banchi da 32 registri ciascuno
ConvertiPaletteBank:
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#32-1,d6	; 32 registri colore per banco

DaLongARegistri:	; loop che trasforma i colori $00RrGgBb.l nelle 2
			; word $0RGB, $0rgb adatte ai registri copper.

;	CALCOLA IL ROSSO

	MOVE.L	(A3),D4			; READ COLOR FROM TAB
	ANDI.L	#%000011111111,D4	; SELECT BLUE
	MULU.W	MULTIPLIER(PC),D4		; MULTIPLIER
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%000011111111,D4	; SELECT BLUE VAL
	MOVE.L	D4,D5			; SAVE BLUE TO D5

;	CALCOLA IL VERDE

	MOVE.L	(A3),D4			; READ COLOR FROM TAB
	ANDI.L	#%1111111100000000,D4	; SELECT GREEN
	LSR.L	#8,D4			; -> 8 bits (so from 0 to 7)
	MULU.W	MULTIPLIER(PC),D4	; MULTIPLIER
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%0000000011111111,D4	; SELECT GREEN
	LSL.L	#8,D4			; <- 8 bits (so from 8 to 15)
	OR.L	D4,D5			; SAVE GREEN TO D5

;	CALCOLA IL BLU

	MOVE.L	(A3)+,D4		; READ COLOR FROM TAB AND GO TO NEXT
	ANDI.L	#%111111110000000000000000,D4	; SELECT RED
	LSR.L	#8,D4			; -> 8 bits (so from 8 to 15)
	LSR.L	#8,D4			; -> 8 bits (so from 0 to 7)
	MULU.W	MULTIPLIER(PC),D4	; MULTIPLIER
	ASR.w	#8,D4			; -> 8 BITS
	ANDI.L	#%0000000011111111,D4	; SELECT RED
	LSL.L	#8,D4			; <- 8 bits (so from 8 to 15)
	LSL.L	#8,D4			; <- 8 bits (so from 0 to 7)
	OR.L	D4,D5			; SAVE RED TO D5
	MOVE.L	D5,(A0)			; SAVE 24 BIT VALUE IN temporaneo

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

; Tabella con la palette a 24 bit in formato $00RRGGBB. Avremmo potuto anche
; usare quella attaccata in fondo alla PIC, ma per variare eccola in dc.l!
; Si puo' salvare da PicCon se non si seleziona "Copperlist".

PalettePic:
	dc.l	$021104,$150f04,$001115,$191609,$092206,$182707
	dc.l	$052420,$2f1506,$17291c,$1f3108,$341613,$35230b
	dc.l	$1c331c,$2c3409,$00203d,$35241f,$323420,$21470a
	dc.l	$103937,$4a2007,$47201b,$243a32,$002a4a,$35440d
	dc.l	$492822,$443c0a,$21550a,$54280b,$483421,$3a3931
	dc.l	$07364f,$233e45,$1d4d3c,$32590c,$01335d,$27503d
	dc.l	$484f11,$5a3e0e,$354e3c,$5c3921,$593431,$70230e
	dc.l	$4c5b12,$064066,$5b442c,$5d4d11,$465a30,$104367
	dc.l	$732e11,$316143,$5b4838,$324662,$506714,$763b0f
	dc.l	$704023,$655711,$4d5d44,$733f31,$19536e,$8a2012
	dc.l	$2b6261,$6c552e,$784f19,$0d4c7d,$79492e,$8f2713
	dc.l	$716217,$6c612b,$455e61,$8f370f,$1b5081,$705845
	dc.l	$716e16,$943c17,$516463,$8b4e1f,$1e5f83,$8f510f
	dc.l	$746d2d,$89512e,$588a24,$776a45,$8c631d,$8e5e2f
	dc.l	$72635d,$8c5644,$b02015,$1d6791,$aa3c15,$af2d14
	dc.l	$8d7419,$2b6d90,$a1552d,$788a2a,$a25f13,$936d31
	dc.l	$ac4e13,$6e7071,$3a7192,$bd2a16,$878b1e,$a1672e
	dc.l	$926f47,$a46e13,$5d8e67,$8d7054,$a06546,$2f739f
	dc.l	$a37331,$c92b16,$b66110,$8e8b3b,$818d55,$c74013
	dc.l	$3d79a4,$8c7173,$b36e2b,$ba6c11,$ad7244,$a77253
	dc.l	$a58b27,$8f8c60,$a58444,$4489a4,$a59720,$a77661
	dc.l	$cd6214,$ba763e,$a78f41,$db4114,$a48b55,$4589b0
	dc.l	$b87754,$608fa2,$c97728,$8ba268,$d46d10,$c58428
	dc.l	$b8894a,$c88614,$a48c6e,$d86b22,$a59e59,$898f97
	dc.l	$5a94b3,$e46217,$c59427,$c98940,$b99259,$df6a39
	dc.l	$c39443,$c2a025,$a79a74,$da734c,$5595c1,$8c9f95
	dc.l	$c79156,$b99271,$ef6327,$ea7515,$de8b1a,$a89988
	dc.l	$eb7623,$df8d29,$c7a93e,$dd903f,$669ac7,$c5a55b
	dc.l	$c79770,$5da6c8,$f08a18,$d6995f,$ea971a,$dda043
	dc.l	$f3872b,$e1a42d,$caa472,$a8a2a3,$71a7cb,$ef9341
	dc.l	$80a6c6,$caae6f,$f2982a,$c7a287,$f69a1c,$e99959
	dc.l	$d7a86a,$f2a13e,$ccb678,$c6a499,$efb127,$e8b247
	dc.l	$89b2c9,$e5a868,$c8af94,$e2b363,$bcc28f,$f7af2d
	dc.l	$deb577,$8bb1d6,$d1b295,$beb5aa,$f7b34b,$dbb191
	dc.l	$f5b462,$8cb3e3,$f1b375,$d2ba9f,$fdc42f,$dfc189
	dc.l	$fac34a,$87c0e3,$c3c4ae,$a6bbd4,$e2ba94,$fbd232
	dc.l	$f3c967,$98bee4,$f0bf85,$d6c6a4,$fbd24a,$d3baba
	dc.l	$c1bfcd,$e8ce8d,$fdd457,$a3c3e9,$dbd0a8,$d3cbbd
	dc.l	$f0c4a0,$fcdb66,$adcde0,$f7cf8a,$b3c5e9,$dfcebc
	dc.l	$c4d2d8,$feea66,$f3e489,$b5ceeb,$d2ced4,$f5d0a8
	dc.l	$fee885,$f3dfa7,$d8dfca,$c5d2ec,$f5d2bc,$d1d2e7
	dc.l	$ede1c2,$d9d4e7,$fde7aa,$f2d2d5,$f9e2c0,$d2dfef
	dc.l	$e9dedf,$f9f3c4,$f8efda,$f9f5ee

;*****************************************************************************
;*				COPPERLIST AGA				     *
;*****************************************************************************

	CNOP	0,8	; Allineo a 64 bit

	section	coppera,data_C

COPLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0000001000010001	; 8 bitplane LOWRES 320x256. Per
					; settare 8 planes setto il bit 4 e
					; azzero i bit 12,13,14. Il bit 0 e'
					; settato dato che abilita molte
					; funzioni AGA che vedremo dopo.

	dc.w	$1fc,0		; Burst mode azzerato (per ora!)

BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo 	bitplane
	dc.w $e4,0,$e6,0	; secondo	   "
	dc.w $e8,0,$ea,0	; terzo		   "
	dc.w $ec,0,$ee,0	; quarto	   "
	dc.w $f0,0,$f2,0	; quinto	   "
	dc.w $f4,0,$f6,0	; sesto		   "
	dc.w $f8,0,$fA,0	; settimo	   "
	dc.w $fC,0,$fE,0	; ottavo	   "

; In questo caso la palette viene aggiornata da una routine, per cui basta
; lasciare azzerati i valori dei registri.

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

	DC.W	$106,$4C00	; SELEZIONA PALETTE 2 (64-95), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$4E00	; SELEZIONA PALETTE 2 (64-95), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6C00	; SELEZIONA PALETTE 3 (96-127), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6E00	; SELEZIONA PALETTE 3 (96-127), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8C00	; SELEZIONA PALETTE 4 (128-159), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8E00	; SELEZIONA PALETTE 4 (128-159), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AC00	; SELEZIONA PALETTE 5 (160-191), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AE00	; SELEZIONA PALETTE 5 (160-191), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CC00	; SELEZIONA PALETTE 6 (192-223), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CE00	; SELEZIONA PALETTE 6 (192-223), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EC00	; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EE00	; SELEZIONA PALETTE 7 (224-255), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;******************************************************************************

; Figura RAW ad 8 bitplanes, cioe' a 256 colori

	CNOP	0,8	; allineo a 64 bit

PICTURE:
	INCBIN	"MURALE320*256*256c.RAW"

	end

Abbiamo eliminato la COLORTABBY, e questa si puo' chiamare "FADE IN REALTIME",
dato che viene calcolato fotogramma per fotogramma. E' molto piu' lenta di
quelli precalcolati, ma non richiede 256k di buffer. Si puo' usare quando
occorre fare il fade di una figura statica o comunque dove non ci sono
routines molto "mangiatempo". Da notare che la palette viene presa da una
tabella, anziche' dalla fine della pic.

