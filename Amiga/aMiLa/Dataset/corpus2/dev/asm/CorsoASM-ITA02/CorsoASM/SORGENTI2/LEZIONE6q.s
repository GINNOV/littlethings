
; Lezione6q.s	Alcune "scacchiere" screate sullo schermo
;		- ALTERNARE TASTO SINISTRO-DESTRO-SINISTRO del mouse per
;		vedere le scacchiere ed uscire

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

	bsr.w	GRIGLIA1

mouse:
	btst	#6,$bfe001	; tasto sinistro?
	bne.s	mouse

	bsr.w	GRIGLIA2

mouse2:
	btst	#2,$dff016	; tasto destro?
	bne.s	Mouse2

	bsr.w	GRIGLIA3

mouse3:
	btst	#6,$bfe001	; tasto sinistro?
	bne.s	mouse3

	bsr.w	GRIGLIA4

mouse4:
	btst	#2,$dff016	; tasto destro?
	bne.s	Mouse4


	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0



; questa routine fa una scacchiera con quadrati di 8 pixel di lato

GRIGLIA1:
	LEA	BITPLANE,a0	; Indirizzo bitplane destinazione

	MOVEQ	#16-1,d0	; 16 coppie di quadretti alti 8 pixel
				; 16*2*8=256 riempimento completo dello schermo
FaiCoppia:
	move.l	#(20*8)-1,d1	; 20 words per riempire 1 linea
				; 8 linee da riempire
FaiUNO:
	move.w	#%1111111100000000,(a0)+ ; lunghezza quadretto ad 1 = 8 pixel
					 ; quadretto azzerato = 8 pixel
	dbra	d1,FaiUNO		 ; fai 8 linee #.#.#.#.#.#.#.#.#.#

	move.l	#(20*8)-1,d1	; 20 words per riempire 1 linea
				; 8 linee da riempire
FaiALTRO:
	move.w	#%0000000011111111,(a0)+ ; lunghezza quadretto azzerato = 8
					 ; quadretto ad 1 = 8 pixel
	dbra	d1,FaiAltro		 ; fai 8 linee .#.#.#.#.#.#.#.#.#.

	DBRA	d0,FaiCoppia		 ; fai 16 coppie di quadretti
					 ; #.#.#.#.#.#.#.#.#.#
	rts				 ; .#.#.#.#.#.#.#.#.#.

; questa routine fa una scacchiera con quadrati di 4 pixel di lato

GRIGLIA2:
	LEA	BITPLANE,a0	; Indirizzo bitplane destinazione

	MOVEQ	#32-1,d0	; 32 coppie di quadretti alti 4 pixel
				; 32*2*4=256 riempimento completo dello schermo
FaiCoppia2:
	move.l	#(40*4)-1,d1	; 40 bytes per riempire 1 linea
				; 4 linee da riempire
FaiUNO2:
	move.b	#%11110000,(a0)+ 	; lunghezza quadretto ad 1 = 4 pixel
					; quadretto azzerato = 4 pixel
	dbra	d1,FaiUNO2		; fai 4 linee #.#.#.#.#.#.#.#.#.#

	move.l	#(40*4)-1,d1	; 40 bytes per riempire 1 linea
				; 4 linee da riempire
FaiALTRO2:
	move.b	#%00001111,(a0)+ 	; lunghezza quadretto azzerato=4 pixel
					; quadretto ad 1 = 4 pixel
	dbra	d1,FaiAltro2		; fai 8 linee .#.#.#.#.#.#.#.#.#.

	DBRA	d0,FaiCoppia2		 ; fai 32 coppie di quadretti
					 ; #.#.#.#.#.#.#.#.#.#
	rts				 ; .#.#.#.#.#.#.#.#.#.

; questa routine fa una scacchiera con quadrati di 16 pixel di lato

GRIGLIA3:
	LEA	BITPLANE,a0	; Indirizzo bitplane destinazione

	MOVEQ	#8-1,d0		; 8 coppie di quadretti alti 16 pixel
				; 8*2*16=256 riempimento completo dello schermo
FaiCoppia3:
	move.l	#(10*16)-1,d1	; 10 lingwords per riempire 1 linea
				; 16 linee da riempire
FaiUNO3:
	move.l	#%11111111111111110000000000000000,(a0)+ 
					; lunghezza quadretto ad 1 = 16 pixel
					; quadretto azzerato = 16 pixel
	dbra	d1,FaiUNO3		; fai 16 linee #.#.#.#.#.#.#.#.#.#

	move.l	#(10*16)-1,d1	; 10 lingwords per riempire 1 linea
				; 16 linee da riempire
FaiALTRO3:
	move.l	#%00000000000000001111111111111111,(a0)+
					; lunghezza quadretto azzerato = 16
					; quadretto ad 1 = 16 pixel
	dbra	d1,FaiAltro3		; fai 8 linee .#.#.#.#.#.#.#.#.#.

	DBRA	d0,FaiCoppia3		 ; fai 8 coppie di quadretti
					 ; #.#.#.#.#.#.#.#.#.#
	rts				 ; .#.#.#.#.#.#.#.#.#.

	; griglia "fantasia"

GRIGLIA4:
	LEA	BITPLANE,a0	; Indirizzo bitplane destinazione

	MOVEQ	#8-1,d0		; 8 coppie di quadretti alti 16 pixel
				; 8*2*16=256 riempimento completo dello schermo
FaiCoppia4:
	move.l	#(10*16)-1,d1	; 10 lingwords per riempire 1 linea
				; 16 linee da riempire
FaiUNO4:
	move.l	#%11111000000000011111000000000000,(a0)+ 
					; lunghezza quadretto ad 1 = 4 pixel
					; quadretto azzerato = 12 pixel
	dbra	d1,FaiUNO4		; fai 16 linee #.#.#.#.#.#.#.#.#.#

	move.l	#(10*16)-1,d1	; 10 lingwords per riempire 1 linea
				; 16 linee da riempire
FaiALTRO4:
	move.l	#%00000000000011111000000000011111,(a0)+
					; lunghezza quadretto azzerato = 12
					; quadretto ad 1 = 4 pixel
	dbra	d1,FaiAltro4		; fai 8 linee .#.#.#.#.#.#.#.#.#.

	DBRA	d0,FaiCoppia4		 ; fai 8 coppie di quadretti
					 ; #.#.#.#.#.#.#.#.#.#
	rts				 ; .#.#.#.#.#.#.#.#.#.

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - DISEGNO

	dc.w	$FFFF,$FFFE	; Fine della copperlist


	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end

Se avete bisogno di uno sfondo geometrico o ripetitivo potete farvelo con una
routine anziche' disegnarlo, risparmiando lo spazio della figura. Questo e'
solo un esempio di quello che si puo' fare, si possono anche ripetere piccoli
disegni sullo schermo copiandoli uno accanto all'altro come mattoncini.

