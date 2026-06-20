
; Lezione8h2.s		Routine di scrolltext 8*8, che usa solo il bplcon1
;			per scorrere. Originale di Lorenzo Di Gaetano.

	SECTION	SysInfo,CODE

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

START:

;	Puntiamo i bitplanes in copperlist

	MOVE.L	#schermo,d0	; in d0 mettiamo l'indirizzo del bitplane
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	clr.w	ContaScroll	; Azzera il contatore dello scroll
	bsr.w	Print		; Stampa la prima volta

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
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

	bsr.s	Scroll		; Routine sche scrolla a sinistra il testo
				; con bplcon1, e ogni 16 pixel lo ristampa
				; 2 caratteri (8*2=16 pixel) piu' avanti
				; resettando il bplcon1 -> SCROLLING!!!

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
; Routine che decide se scrollare col bplcon1, o ristampando l'intero testo
; 2 caratteri (16 pixel) piu' a sinistra (questo 1 volta ogni 16, naturalmente)
*****************************************************************************

Scroll:
	tst.b	Scrolling	; Abbiamo scrollato al massimo con bplcon1?
	bne.s	AlloraAdda	; Se non ancora, continua la sottrazione

; Altrimenti ripartiamo da $FF e ristampiamo il testo 2 caratteri avanti!

	addq.w	#2,ContaScroll	; 2 caratteri piu' avanti -> 16 pixel avanti
	move.b	#$FF,Scrolling	; Resetta bplcon1
	bsr.s	Print		; e ristampa il ScrollText 2 caratteri piu'
	rts			; avanti,  ossia 2*8=16 pixel piu' avanti.

AlloraAdda:
	sub.b	#$11,Scrolling	; 1 pixel verso sinistra con bplcon1
	rts

*****************************************************************************
; Routine di print 8*8 modificata per lo scroll
*****************************************************************************

Print:
	lea	Schermo+(42*192),a0	; Indirizzo dove stampare
	lea	ScrollText(PC),a1	; Indirizzo scrolltext (ascii)
	moveq	#42-1,d2		; Numero caratteri da stampare
	moveq	#0,d0
	move.w	ContaScroll(PC),d0	; Offset dall'inizio del ScrollText
	add.l	d0,a1			; Trova il carattere nello scrolltext
Printriga:
	sub.l	a2,a2		; azzera a2
	moveq	#0,d1
	move.b	(a1)+,d1
	cmp.b	#$ff,d1		; flag di fine ScrollText?
	bne.s	NonRipartire	; Se non ancora, continua
	clr.w	Contascroll	; Oppure, riparti dall'inizio del ScrollText
NonRipartire:
	sub.b	#$20,d1
	lsl.w	#3,d1		; moltiplica per 8
	move.l	d1,a2
	add.l	#Fonts,a2	; trova il carattere nel font
	move.b	(a2)+,(a0)
	move.b	(a2)+,42(a0)	; 42 per compensare il dfstart e andare quindi
	move.b	(a2)+,42*2(a0)	; oltre lo schermo
	move.b	(a2)+,42*3(a0)
	move.b	(a2)+,42*4(a0)
	move.b	(a2)+,42*5(a0)
	move.b	(a2)+,42*6(a0)
	move.b	(a2)+,42*7(a0)
	addq.w	#1,a0		; prossimo carattere
	dbra	d2,Printriga
	rts

ContaScroll:
	dc.w	0



ScrollText:
	dc.b	"                                              "
	dc.b	"QUESTO TESTO VIENE SPOSTATO CON IL REGISTRO BPLCON1:"
	DC.B	" DOPO AVERLO SPOSTATO DI 16 PIXEL VIENE AZZERATO,"
	DC.B	" E INVECE DI PUNTARE ALLA PROSSIMA WORD DELL` IMMAGINE IL TE"
	DC.B	"STO VIENE RISTAMPATO SULLO SCHERMO 2 LETTERE DOPO."
	DC.B	"L'AUTORE, LORENZO DI GAETANO, (The Amiga Dj) HA FATTO QUESTA"
	dc.b	" ROUTINE CON LE SOLE CONOSCENZE DEL DISCO 1 DEL CORSO."
	dc.b	"... FORZA AMIGA!!!                    "
	DC.B	"                                       "
	dc.b	$FF	; Flag di fine scrolltext

	even

; Font 8x8

Fonts:
	incbin	"nice.fnt"

;****************************************************************************

	SECTION	GRAPHIC,DATA_C


COPPERLIST:
	dc.w    $08e,$2c81       ; Qui` ci sono i registri standard
	dc.w    $090,$2cc1
	dc.w    $092,$0038
	dc.w    $094,$00d0
	dc.w	$102,0
	dc.w    $104,0
	dc.w    $108,2			;2 per saltare il vuoto dell` immagine
	dc.w    $10a,2

bplpointers:
	dc.w    $e0,$0000,$e2,$0000    ; Puntatori ai bitplane

	dc.w    $100,%0001001000000000 ; Bplcon0 2 colori

	dc.w	$180,$000
	dc.w	$182,$888

; Qua potrebbe starci un'immagine qualsiasi...

	dc.w	$eb07,$fffe	; Qui` comincia la copperlist dello 
				; scrolling.
	dc.w    $092,$0030	; Per nascondere l`errore di scroll
	dc.w    $094,$00d0

	dc.w    $104,0
	dc.w    $108,0
	dc.w    $10a,0
	dc.w    $102		; bplcon1
	dc.b	$00
Scrolling:
	dc.b	$FF
	dc.w	$182,$200
	dc.w	$ec07,$FFFe
	dc.w	$182,$400
	dc.w	$ed07,$fffe
	dc.w	$182,$600
	dc.w	$ee07,$fffe
	dc.w	$182,$800
	dc.w	$ef07,$fffe
	dc.w	$182,$a00
	dc.w	$f007,$fffe
	dc.w	$182,$d00
	dc.w	$f107,$fffe
	dc.w	$182,$a00
	dc.w	$f207,$fffe
	dc.w	$182,$800
	dc.w	$f307,$fffe	
	
	dc.w	$182,$000	; Effetti copper...
	dc.w	$180,$001
	dc.w	$108,-84
	dc.w	$10a,-84
	dc.w	$f4ff,$fffe
	dc.w	$180,$003
	dc.w	$f5ff,$fffe
	dc.w	$180,$005
	dc.w	$f6ff,$fffe
	dc.w	$180,$007
	dc.w	$f7ff,$fffe
	dc.w	$180,$009
	dc.w	$f8ff,$fffe
	dc.w	$180,$00b
	dc.w	$f8ff,$fffe
	dc.w	$180,$00c
	dc.w	$f9ff,$fffe
	dc.w	$180,$00f
	dc.w	$faff,$fffe
	dc.w	$180,$00f
	dc.w	$fbff,$fffe
	dc.w	$180,$000
	dc.w	$108,0
	dc.w	$10a,0
	dc.w	$ffff,$fffe	; Fine copperlist

;****************************************************************************

	Section	Bitplanozzo,bss_C

Schermo:
	ds.b	42*256

	end

