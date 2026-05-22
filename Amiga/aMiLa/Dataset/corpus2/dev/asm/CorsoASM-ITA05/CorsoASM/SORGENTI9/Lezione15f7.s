
; Lezione15f7.s		Palette degli sprite AGA spostata con $dff10c.
;			Tasto sinistro per assegnare 2 palette diverse
;			agli sprite pari e dispari, destro per uscire.

	SECTION	AgaRulez,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110100000	; copper, bitplane, sprite DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo gli sprite

	MOVE.L	#MIOSPRITE0,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE1,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE2,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE3,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE4,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE5,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE6,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE7,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

	move.w	#%11101110,bplcon4+2	; stessa palette per sprite pari
					; e dispari

mouseS:
	btst.b	#6,$bfe001	; mouse sin. premuto?
	bne.s	mouseS

	move.w	#%11101111,bplcon4+2	; palette diversa per sprite pari
					; e dispari

mouseD:
	btst.b	#2,$dff016	; mouse dest. premuto?
	bne.s	mouseD

	rts

;*****************************************************************************
;*				COPPERLIST				     *
;*****************************************************************************

	CNOP	0,8	; Allineo a 64 bit

	section	coppera,data_C

COPLIST:
SpritePointers:
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
	dc.w	$108,-8		; Bpl1Mod (burst 64bit, modulo=modulo-8)
	dc.w	$10a,-8		; Bpl2Mod (come sopra)

		    ; 5432109876543210
	dc.w	$100,%0001001000000001	; 1 bitplane LORES 320x256.

	dc.w	$1fc,%0011	; Burst mode a 64 bit, sprite larghi 16 pixel


BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo 	bitplane
	dc.w $e4,0,$e6,0	; secondo	   "
	dc.w $e8,0,$ea,0	; terzo		   "
	dc.w $ec,0,$ee,0	; quarto	   "
	dc.w $f0,0,$f2,0	; quinto	   "
	dc.w $f4,0,$f6,0	; sesto		   "
	dc.w $f8,0,$fA,0	; settimo	   "
	dc.w $fC,0,$fE,0	; ottavo	   "

; Da notare che i colori dello sprite sono a 24 bit, anche se sono solo 3.

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
COLP0:
	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	DC.W	$106,$EC00	; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

bplcon4:
	dc.w	$10c,%11101111	; BPLCON4 - Palette sprite pari = 224-240
				; 	    Palette sprite dispari = 240-256

; Ora il banco della palette sprite pari

	dc.w	$182,$F00	; color225, - COLOR1 dello sprite0 -ROSSO
	dc.w	$184,$0F0	; color226, - COLOR2 dello sprite0 -VERDE
	dc.w	$186,$FF0	; color227, - COLOR3 dello sprite0 -GIALLO

	dc.w	$18A,$FFF	; color229, - COLOR1 dello sprite2 -BIANCO
	dc.w	$18C,$0BD	; color230, - COLOR2 dello sprite2 -ACQUA
	dc.w	$18E,$D50	; color231, - COLOR3 dello sprite2 -ARANCIO

	dc.w	$192,$00F	; color233, - COLOR1 dello sprite4 -BLU
	dc.w	$194,$F0F	; color234, - COLOR2 dello sprite4 -VIOLA
	dc.w	$196,$BBB	; color235, - COLOR3 dello sprite4 -GRIGIO

	dc.w	$19A,$8E0	; color237, - COLOR1 dello sprite6 -VERDE CH.
	dc.w	$19C,$a70	; color238, - COLOR2 dello sprite6 -MARRONE
	dc.w	$19E,$d00	; color239, - COLOR3 dello sprite6 -ROSSO SC.

; Ora il banco della palette sprite dispari

	dc.w	$1A2,$555	; color241, - COLOR1 dello sprite1 -grigio
	dc.w	$1A4,$aa0	; color242, - COLOR2 dello sprite1 -giallo
	dc.w	$1A6,$0af	; color243, - COLOR3 dello sprite1 -azzurro

	dc.w	$1AA,$a0a	; color245, - COLOR1 dello sprite3 -...
	dc.w	$1AC,$3fa	; color246, - COLOR2 dello sprite3 -...
	dc.w	$1AE,$faf	; color247, - COLOR3 dello sprite3 -...

	dc.w	$1B2,$254	; color249, - COLOR1 dello sprite5 -...
	dc.w	$1B4,$5a3	; color250, - COLOR2 dello sprite5 -...
	dc.w	$1B6,$4ee	; color251, - COLOR3 dello sprite5 -...

	dc.w	$1BA,$22c	; color253, - COLOR1 dello sprite7 -...
	dc.w	$1BC,$381	; color354, - COLOR2 dello sprite7 -...
	dc.w	$1BE,$fe9	; color255, - COLOR3 dello sprite7 -...

	dc.w	$FFFF,$FFFE	; Fine della copperlist


;*****************************************************************************
;************ Ecco gli sprite: OVVIAMENTE devono essere in CHIP RAM! *********
;*****************************************************************************

MIOSPRITE0:		; lunghezza 13 linee
VSTART0:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART0:
	dc.b $60	; Pos. orizzontale (da $40 a $d8)
VSTOP0:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite


MIOSPRITE1:		; lunghezza 13 linee
VSTART1:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART1:
	dc.b $60+14	; Pos. orizzontale (da $40 a $d8)
VSTOP1:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000010001111
 dc.w	%0011111111111100,%1100000110000011
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0011111111111100,%1100000010000011
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 2 e 3
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (BIANCO)
 ;BINARIO 01=COLORE 2 (ACQUA)
 ;BINARIO 11=COLORE 3 (ARANCIO)

MIOSPRITE2:		; lunghezza 13 linee
VSTART2:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART2:
	dc.b $60+(14*2)	; Pos. orizzontale (da $40 a $d8)
VSTOP2:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0011111111111100,%1100001000100011
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0111111111111110,%1000000111000001
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE3:		; lunghezza 13 linee
VSTART3:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART3:
	dc.b $60+(14*3)	; Pos. orizzontale (da $40 a $d8)
VSTOP3:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0111111111111110,%1000000111100001
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 4 e 5
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (BLU)
 ;BINARIO 01=COLORE 2 (VIOLA)
 ;BINARIO 11=COLORE 3 (GRIGIO)

MIOSPRITE4:		; lunghezza 13 linee
VSTART4:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART4:
	dc.b $60+(14*4)	; Pos. orizzontale (da $40 a $d8)
VSTOP4:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001001001111
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE5:		; lunghezza 13 linee
VSTART5:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART5:
	dc.b $60+(14*5)	; Pos. orizzontale (da $40 a $d8)
VSTOP5:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

 ; per gli sprite 6 e 7
 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 ;BINARIO 10=COLORE 1 (VERDE CHIARO)
 ;BINARIO 01=COLORE 2 (MARRONE)
 ;BINARIO 11=COLORE 3 (ROSSO SCURO)

MIOSPRITE6:		; lunghezza 13 linee
VSTART6:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART6:
	dc.b $60+(14*6)	; Pos. orizzontale (da $40 a $d8)
VSTOP6:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000001001000001
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

MIOSPRITE7:		; lunghezza 13 linee
VSTART7:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART7:
	dc.b $60+(14*7)	; Pos. orizzontale (da $40 a $d8)
VSTOP7:
	dc.b $68	; $60+13=$6d	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite

	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

Tutto il listato e' basato su questi due registri in copperlist:

	DC.W	$106,$EC00	; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

	dc.w	$10c,%11101111	; BPLCON4 - Palette sprite pari = 224-240
				; 	    Palette sprite dispari = 240-256

Poi vengono settati i colori dal 225 a 255 (solo i nibble alti, non avevo
voglia di mettere anche quelli bassi!).

"Spostare" la palette degli sprite in fondo alla palette puo' essere utile nel
caso si visualizzino figure fino a 128 colori, per cui la palette dei nostri
sprite e' totalmente indipendente. Nel caso la figura sia a 256 colori, si
puo' optare per un qualsiasi banco di 16 colori usabili anche per gli sprite.

