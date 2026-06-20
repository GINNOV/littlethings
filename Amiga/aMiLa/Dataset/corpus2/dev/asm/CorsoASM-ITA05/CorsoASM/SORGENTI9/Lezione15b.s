
; Lezione15b.s		Sfumatura copper AGA con utilizzo della palette 24bit.
;			Usiamo una routine per fare la sfumatura.
;			Tasti destro e sinistro per uscire

	SECTION	AgaRulez,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

	move.l	#$2c07fffe,d1	; Prima linea YY wait: $2c
	moveq	#$00,d5		; Colore start
	move.w	#200-1,d7	; Numero linee: 200!
	bsr.w	FaiAGACopR	; Fai una sfumatura ROSSA

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

LOOP1:
	BTST.b	#6,$BFE001	; tasto sin mouse?
	BNE.S	LOOP1


	move.l	#$2c07fffe,d1	; Prima linea YY wait: $2c
	moveq	#$00,d5		; Colore start
	move.w	#200-1,d7	; Numero linee: 200!
	bsr.w	FaiAGACopG	; Fai una sfumatura GREEN (verde)

LOOP2:
	BTST.b	#2,$16(a5)	; tasto destro mouse?
	BNE.S	LOOP2

	move.l	#$2c07fffe,d1	; Prima linea YY wait: $2c
	moveq	#$00,d5		; Colore start
	move.w	#200-1,d7	; Numero linee: 200!
	bsr.w	FaiAGACopB	; Fai una sfumatura BLU

LOOP3:
	BTST.b	#6,$BFE001	; tasto sin mouse?
	BNE.S	LOOP3

	move.l	#$2c07fffe,d1	; Prima linea YY wait: $2c
	moveq	#$00,d5		; Colore start
	move.w	#150-1,d7	; Numero linee: 150!
	bsr.s	FaiAGACopG	; Fai una sfumatura GREEN (verde)

LOOP4:
	BTST.b	#2,$16(a5)	; tasto destro mouse?
	BNE.S	LOOP4

	move.l	#$2c07fffe,d1	; Prima linea YY wait: $2c
	moveq	#$00,d5		; Colore start
	move.w	#60-1,d7	; Numero linee: 200!
	bsr.w	FaiAGACopR	; Fai una sfumatura ROSSA

LOOP5:
	BTST.b	#6,$BFE001	; tasto sin mouse?
	BNE.S	LOOP5

	RTS

;*****************************************************************************
; Routine che crea sfumature aga ROSSE:
;
; d1 = Prima linea da aspettare (Wait, ad es: $2c07fffe per linea Y=$2c)
; d5 = inizio tonalita' ($00-$ff)
; d7 = Numero linee da fare
;*****************************************************************************

FaiAgaCopR:
	lea	AgaCopEff1,a0
	move.l	#$01060c00,d4	; BplCon3 - nibble alti
	move.l	#$01060e00,d3	; BplCon3 - nibble bassi
	move.w	#$180,d2	; Registro Color0
FaiAGALoopR:
	move.l	d1,(a0)+	; Metti il wait YYXXFFFE
	add.l	#$01000000,d1	; Fai waitare una linea sotto per la prossima
	move.l	d4,(a0)+	; BplCon3 - selez. nibble alti
	move.w	d2,(a0)+	; Registro Color0
	addq.b	#1,d5		; "Illumina" leggermente il colore $Gg
	move.w	d5,d6		; Copialo in d6
	and.w	#%11110000,d6	; Selez. solo il nibble ALTO
	lsl.w	#4,d6		; Alla posizione giusta, ossia al RED ($Rxx)
	move.w	d6,(a0)+	; Valore del Color0 (nib alti)
	move.l	d3,(a0)+	; BplCon3 - selez. nibble bassi
	move.w	d2,(a0)+	; Registro Color0
	move.w	d5,d6		; Colore $xx in d6
	and.w	#%00001111,d6	; Selez. solo i nibble bassi
	lsl.w	#8,d6		; Spostali alla posizione del rosso
	move.w	d6,(a0)+	; Metti il colore in copperlist (nibble bassi)
	dbra	d7,FaiAGALoopR
	rts

;*****************************************************************************
; Routine che crea sfumature aga VERDI:
;
; d1 = Prima linea da aspettare (Wait, ad es: $2c07fffe per linea Y=$2c)
; d5 = inizio tonalita' ($00-$ff)
; d7 = Numero linee da fare
;*****************************************************************************

FaiAgaCopG:
	lea	AgaCopEff1,a0
	move.l	#$01060c00,d4	; BplCon3 - nibble alti
	move.l	#$01060e00,d3	; BplCon3 - nibble bassi
	move.w	#$180,d2	; Registro Color0
FaiAGALoopG:
	move.l	d1,(a0)+	; Metti il wait YYXXFFFE
	add.l	#$01000000,d1	; Fai waitare una linea sotto per la prossima
	move.l	d4,(a0)+	; BplCon3 - selez. nibble alti
	move.w	d2,(a0)+	; Registro Color0
	addq.b	#1,d5		; "Illumina" leggermente il colore $Gg
	move.w	d5,d6		; Copialo in d6
	and.w	#%11110000,d6	; Selez. solo il nibble ALTO (e' gia' alla
				; posizione giusta, ossia al GREEN $xGx)
	move.w	d6,(a0)+	; Valore del Color0 (nib alti)
	move.l	d3,(a0)+	; BplCon3 - selez. nibble bassi
	move.w	d2,(a0)+	; Registro Color0
	move.w	d5,d6		; Colore $xx in d6
	and.w	#%00001111,d6	; Selez. solo i nibble bassi
	lsl.w	#4,d6		; Spostali alla posizione del verde
	move.w	d6,(a0)+	; Metti il colore in copperlist (nibble bassi)
	dbra	d7,FaiAGALoopG
	rts

;*****************************************************************************
; Routine che crea sfumature aga BLU:
;
; d1 = Prima linea da aspettare (Wait, ad es: $2c07fffe per linea Y=$2c)
; d5 = inizio tonalita' ($00-$ff)
; d7 = Numero linee da fare
;*****************************************************************************

FaiAgaCopB:
	lea	AgaCopEff1,a0
	move.l	#$01060c00,d4	; BplCon3 - nibble alti
	move.l	#$01060e00,d3	; BplCon3 - nibble bassi
	move.w	#$180,d2	; Registro Color0
FaiAGALoopB:
	move.l	d1,(a0)+	; Metti il wait YYXXFFFE
	add.l	#$01000000,d1	; Fai waitare una linea sotto per la prossima
	move.l	d4,(a0)+	; BplCon3 - selez. nibble alti
	move.w	d2,(a0)+	; Registro Color0
	addq.b	#1,d5		; "Illumina" leggermente il colore $Gg
	move.w	d5,d6		; Copialo in d6
	and.w	#%11110000,d6	; Selez. solo il nibble ALTO
	lsr.w	#4,d6		; Alla posizione giusta, ossia al BLU $xxB)
	move.w	d6,(a0)+	; Valore del Color0 (nib alti)
	move.l	d3,(a0)+	; BplCon3 - selez. nibble bassi
	move.w	d2,(a0)+	; Registro Color0
	move.w	d5,d6		; Colore $xx in d6
	and.w	#%00001111,d6	; Selez. solo i nibble bassi - posizione $xxB
	move.w	d6,(a0)+	; Metti il colore in copperlist (nibble bassi)
	dbra	d7,FaiAGALoopB
	rts

;*****************************************************************************
;*				COPPERLIST				     *
;*****************************************************************************

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
	dc.w	$100,$201	; no bitplanes (bit 1 abilitato, pero'!)

	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
				; (I nibble bassi li lasciamo a zero...)

AgaCopEff1:
	dcb.l	200*5		; Ossia: 200 linee * 5 long:
				; 1 per il wait,
				; 1 per il bplcon3
				; 1 per color0 (nib alti)
				; 1 per il bplcon3
				; 1 per color0 (nib bassi)

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end

Conveniva proprio farsi una routine per questa sfumatura. Vi immaginate quante
linee avremmo dovuto scrivere???

