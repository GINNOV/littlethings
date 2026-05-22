
; Lezione15c.s	Visualizzazione di una figura lowres a 256 colori (8 planes)

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
	MOVEQ	#8-1,D7			; num bitplanes -1
POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#40*256,d0		; lunghezza bitplane
	addq.w	#8,a1
	dbra	d7,POINTB		;Rifai D1 volte (D1=num of bitplanes)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

LOOP:
	BTST.b	#6,$BFE001
	BNE.S	LOOP
	RTS

;*****************************************************************************
;*				COPPERLIST				     *
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
	dc.w	$100,%0000001000010001	; 8 bitplane LOWRES 320x256

	dc.w	$1fc,0		; Burst mode azzerato

BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo 	bitplane
	dc.w $e4,0,$e6,0	; secondo	   "
	dc.w $e8,0,$ea,0	; terzo		   "
	dc.w $ec,0,$ee,0	; quarto	   "
	dc.w $f0,0,$f2,0	; quinto	   "
	dc.w $f4,0,$f6,0	; sesto		   "
	dc.w $f8,0,$fA,0	; settimo	   "
	dc.w $fC,0,$fE,0	; ottavo	   "

; Colori salvati dall'iffconverter. Da PicCon occorre settare nel menu' dei
; Settings/Paletteformat il "pulsante" COPPERLIST, il che salva una copperlist
; con i registri $106 e $180,$182 ecc. anziche' i soli valori. Inoltre occorre
; salcare come sorgente in "dc.w" anziche' in binario, e questo si puo' fare
; settando il menu' Project/Save data as../*ASM source*, anziche' bynary.
; Per l'iffconv di Yragael basta salvare come COPPER, ma la lista viene piu'
; lunga perche' mette un registro per linea. L'agaconv salva i registri colore
; senza i $106, per cui si dovrebbe metterli a mano, vi consiglio di salvare
; la copperlist con il PicCon o l'Iffconv. (nota: i registri $106 non hanno i
; bit 10 e 11 settati, per cui sono $106,$000 - $106,$200 - $106,$2000 ecc,
; la funzione e' la stessa. Una volta settata la palette potete cambiare dei
; bit del $dff106 (BPLCON3) a vostro piacimento.

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI

	dc.w	$180,$010,$182,$100,$184,$011,$186,$110 ; nibble alti dei
	dc.w	$188,$020,$18a,$120,$18c,$022,$18e,$210 ; colori 0-31
	dc.w	$190,$121,$192,$130,$194,$311,$196,$320
	dc.w	$198,$131,$19a,$230,$19c,$023,$19e,$321
	dc.w	$1a0,$332,$1a2,$240,$1a4,$133,$1a6,$420
	dc.w	$1a8,$421,$1aa,$233,$1ac,$024,$1ae,$340
	dc.w	$1b0,$422,$1b2,$430,$1b4,$250,$1b6,$520
	dc.w	$1b8,$432,$1ba,$333,$1bc,$034,$1be,$234

	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI

	dc.w	$180,$214,$182,$5f4,$184,$015,$186,$969 ; nibble bassi dei
	dc.w	$188,$926,$18a,$877,$18c,$540,$18e,$f56 ; colori 0-31
	dc.w	$190,$79c,$192,$f18,$194,$463,$196,$53b
	dc.w	$198,$c3c,$19a,$c49,$19c,$00d,$19e,$54f
	dc.w	$1a0,$240,$1a2,$17a,$1a4,$097,$1a6,$a07
	dc.w	$1a8,$70b,$1aa,$4a2,$1ac,$0aa,$1ae,$54d
	dc.w	$1b0,$982,$1b2,$4ca,$1b4,$15a,$1b6,$48b
	dc.w	$1b8,$841,$1ba,$a91,$1bc,$76f,$1be,$3e5

	DC.W	$106,$2C00	; SELEZIONA PALETTE 1 (32-63), NIBBLE ALTI

	dc.w	$180,$143,$182,$350,$184,$035,$186,$253 ; nibble alti dei
	dc.w	$188,$441,$18a,$530,$18c,$343,$18e,$532 ; colori 32-63
	dc.w	$190,$533,$192,$720,$194,$451,$196,$046
	dc.w	$198,$542,$19a,$541,$19c,$453,$19e,$146
	dc.w	$1a0,$721,$1a2,$364,$1a4,$543,$1a6,$346
	dc.w	$1a8,$561,$1aa,$730,$1ac,$742,$1ae,$651
	dc.w	$1b0,$454,$1b2,$733,$1b4,$156,$1b6,$821
	dc.w	$1b8,$266,$1ba,$652,$1bc,$741,$1be,$047

	DC.W	$106,$2E00	; SELEZIONA PALETTE 1 (32-63), NIBBLE BASSI

	dc.w	$180,$ddc,$182,$29c,$184,$13d,$186,$70d ; nibble bassi, ecc.
	dc.w	$188,$8f1,$18a,$aee,$18c,$5ec,$18e,$c91
	dc.w	$190,$941,$192,$03e,$194,$cb2,$196,$606
	dc.w	$198,$b4c,$19a,$dd1,$19c,$6a0,$19e,$037
	dc.w	$1a0,$3e1,$1a2,$113,$1a4,$b88,$1a6,$262
	dc.w	$1a8,$074,$1aa,$6bf,$1ac,$003,$1ae,$571
	dc.w	$1b0,$dd4,$1b2,$3f1,$1b4,$93e,$1b6,$a02
	dc.w	$1b8,$b21,$1ba,$c5e,$1bc,$8f9,$1be,$dcd

	DC.W	$106,$4C00	; SELEZIONA PALETTE 2 (64-95), NIBBLE ALTI

	dc.w	$180,$742,$182,$821,$184,$761,$186,$662
	dc.w	$188,$456,$18a,$830,$18c,$158,$18e,$754
	dc.w	$190,$761,$192,$931,$194,$566,$196,$841
	dc.w	$198,$158,$19a,$850,$19c,$762,$19e,$852
	dc.w	$1a0,$582,$1a2,$764,$1a4,$861,$1a6,$852
	dc.w	$1a8,$765,$1aa,$854,$1ac,$b21,$1ae,$169
	dc.w	$1b0,$a31,$1b2,$a21,$1b4,$871,$1b6,$269
	dc.w	$1b8,$a52,$1ba,$782,$1bc,$a51,$1be,$963

	DC.W	$106,$4E00	; SELEZIONA PALETTE 2 (64-95), NIBBLE BASSI

	dc.w	$180,$99e,$182,$f73,$184,$127,$186,$c1b
	dc.w	$188,$5e1,$18a,$f7f,$18c,$b01,$18e,$085
	dc.w	$190,$1e6,$192,$4c7,$194,$143,$196,$bef
	dc.w	$198,$ef3,$19a,$f1f,$19c,$4dd,$19e,$91e
	dc.w	$1a0,$8a4,$1a2,$7a5,$1a4,$c3d,$1a6,$eef
	dc.w	$1a8,$23d,$1aa,$c64,$1ac,$005,$1ae,$d71
	dc.w	$1b0,$ac5,$1b2,$fd4,$1b4,$d49,$1b6,$bd0
	dc.w	$1b8,$15d,$1ba,$8aa,$1bc,$2f3,$1be,$3d1

	DC.W	$106,$6C00	; SELEZIONA PALETTE 3 (96-127), NIBBLE ALTI

	dc.w	$180,$a41,$182,$677,$184,$379,$186,$b21
	dc.w	$188,$881,$18a,$a62,$18c,$964,$18e,$a61
	dc.w	$190,$586,$192,$875,$194,$a64,$196,$279
	dc.w	$198,$a73,$19a,$c21,$19c,$b61,$19e,$883
	dc.w	$1a0,$885,$1a2,$c41,$1a4,$37a,$1a6,$877
	dc.w	$1a8,$b62,$1aa,$b61,$1ac,$a74,$1ae,$a75
	dc.w	$1b0,$a82,$1b2,$886,$1b4,$a84,$1b6,$48a
	dc.w	$1b8,$a92,$1ba,$a76,$1bc,$c61,$1be,$b73

	DC.W	$106,$6E00	; SELEZIONA PALETTE 3 (96-127), NIBBLE BASSI

	dc.w	$180,$ce3,$182,$e01,$184,$a12,$186,$da6
	dc.w	$188,$7be,$18a,$17e,$18c,$2f7,$18e,$4e3
	dc.w	$190,$de7,$192,$d04,$194,$056,$196,$f3f
	dc.w	$198,$331,$19a,$9b6,$19c,$610,$19e,$ebb
	dc.w	$1a0,$1d5,$1a2,$703,$1a4,$d94,$1a6,$c13
	dc.w	$1a8,$3eb,$1aa,$ac1,$1ac,$d24,$1ae,$723
	dc.w	$1b0,$5b7,$1b2,$fc0,$1b4,$544,$1b6,$494
	dc.w	$1b8,$570,$1ba,$761,$1bc,$d24,$1be,$a6e

	DC.W	$106,$8C00	; SELEZIONA PALETTE 4 (128-159), NIBBLE ALTI

	dc.w	$180,$a84,$182,$d41,$184,$a85,$186,$48b
	dc.w	$188,$b75,$18a,$68a,$18c,$c72,$18e,$8a6
	dc.w	$190,$d61,$192,$c82,$194,$b84,$196,$c81
	dc.w	$198,$a86,$19a,$d62,$19c,$a95,$19e,$889
	dc.w	$1a0,$59b,$1a2,$e61,$1a4,$c92,$1a6,$c84
	dc.w	$1a8,$b95,$1aa,$d63,$1ac,$c94,$1ae,$ca2
	dc.w	$1b0,$a97,$1b2,$d74,$1b4,$59c,$1b6,$899
	dc.w	$1b8,$c95,$1ba,$b97,$1bc,$e62,$1be,$e71

	DC.W	$106,$8E00	; SELEZIONA PALETTE 4 (128-159), NIBBLE BASSI

	dc.w	$180,$7f1,$182,$b14,$184,$4b5,$186,$590
	dc.w	$188,$874,$18a,$0f2,$18c,$978,$18e,$b28
	dc.w	$190,$4d0,$192,$548,$194,$89a,$196,$864
	dc.w	$198,$4ce,$19a,$8b2,$19c,$5e9,$19e,$9f7
	dc.w	$1a0,$a43,$1a2,$427,$1a4,$547,$1a6,$990
	dc.w	$1a8,$929,$1aa,$fa9,$1ac,$343,$1ae,$205
	dc.w	$1b0,$7a4,$1b2,$a3c,$1b4,$551,$1b6,$cf5
	dc.w	$1b8,$716,$1ba,$921,$1bc,$f37,$1be,$a55

	DC.W	$106,$AC00	; SELEZIONA PALETTE 5 (160-191), NIBBLE ALTI

	dc.w	$180,$d81,$182,$a98,$184,$e72,$186,$d82
	dc.w	$188,$ca3,$18a,$d93,$18c,$69c,$18e,$ca5
	dc.w	$190,$c97,$192,$5ac,$194,$f81,$196,$d95
	dc.w	$198,$e91,$19a,$da4,$19c,$f82,$19e,$ea2
	dc.w	$1a0,$ca7,$1a2,$aaa,$1a4,$7ac,$1a6,$e94
	dc.w	$1a8,$8ac,$1aa,$ca6,$1ac,$f92,$1ae,$ca8
	dc.w	$1b0,$f91,$1b2,$e95,$1b4,$da6,$1b6,$fa3
	dc.w	$1b8,$cb7,$1ba,$ca9,$1bc,$eb2,$1be,$eb4

	DC.W	$106,$AE00	; SELEZIONA PALETTE 5 (160-191), NIBBLE BASSI

	dc.w	$180,$eba,$182,$898,$184,$b63,$186,$fd9
	dc.w	$188,$79e,$18a,$d0f,$18c,$6a7,$18e,$55b
	dc.w	$190,$770,$192,$d68,$194,$0a8,$196,$69f
	dc.w	$198,$a7a,$19a,$d03,$19c,$37b,$19e,$14d
	dc.w	$1a0,$a42,$1a2,$823,$1a4,$17b,$1a6,$f31
	dc.w	$1a8,$066,$1aa,$aef,$1ac,$28a,$1ae,$727
	dc.w	$1b0,$6ac,$1b2,$999,$1b4,$78a,$1b6,$21e
	dc.w	$1b8,$c68,$1ba,$649,$1bc,$f17,$1be,$827

	DC.W	$106,$CC00	; SELEZIONA PALETTE 6 (192-223), NIBBLE ALTI

	dc.w	$180,$8bc,$182,$ea6,$184,$ca9,$186,$eb6
	dc.w	$188,$bc8,$18a,$fa2,$18c,$db7,$18e,$8bd
	dc.w	$190,$db9,$192,$bba,$194,$fb4,$196,$db9
	dc.w	$198,$fb6,$19a,$8be,$19c,$fb7,$19e,$db9
	dc.w	$1a0,$fc2,$1a2,$dc8,$1a4,$fc4,$1a6,$8ce
	dc.w	$1a8,$cca,$1aa,$abd,$1ac,$eb9,$1ae,$fd3
	dc.w	$1b0,$fc6,$1b2,$9be,$1b4,$fb8,$1b6,$dca
	dc.w	$1b8,$fd4,$1ba,$dbb,$1bc,$cbc,$1be,$ec8

	DC.W	$106,$CE00	; SELEZIONA PALETTE 6 (192-223), NIBBLE BASSI

	dc.w	$180,$929,$182,$588,$184,$8f4,$186,$233
	dc.w	$188,$c2f,$18a,$7fd,$18c,$e57,$18e,$b16
	dc.w	$190,$125,$192,$e5a,$194,$73b,$196,$b11
	dc.w	$198,$542,$19a,$c33,$19c,$135,$19e,$2af
	dc.w	$1a0,$d4f,$1a2,$f19,$1a4,$a3a,$1a6,$703
	dc.w	$1a8,$34e,$1aa,$6b4,$1ac,$2a4,$1ae,$b22
	dc.w	$1b0,$397,$1b2,$8e4,$1b4,$0f5,$1b6,$664
	dc.w	$1b8,$b2a,$1ba,$3aa,$1bc,$1fd,$1be,$8ed

	DC.W	$106,$EC00	; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

	dc.w	$180,$fd5,$182,$ace,$184,$dda,$186,$dcb
	dc.w	$188,$fca,$18a,$fd6,$18c,$ace,$18e,$fc8
	dc.w	$190,$bce,$192,$dcb,$194,$cdd,$196,$fe6
	dc.w	$198,$fe8,$19a,$bce,$19c,$dcd,$19e,$fda
	dc.w	$1a0,$fe8,$1a2,$fda,$1a4,$ddc,$1a6,$cde
	dc.w	$1a8,$fdb,$1aa,$dde,$1ac,$eec,$1ae,$dde
	dc.w	$1b0,$fea,$1b2,$fdd,$1b4,$fec,$1b6,$dde
	dc.w	$1b8,$edd,$1ba,$ffc,$1bc,$fed,$1be,$ffe

	DC.W	$106,$EE00	; SELEZIONA PALETTE 7 (224-255), NIBBLE BASSI

	dc.w	$180,$d47,$182,$339,$184,$b08,$186,$3bd
	dc.w	$188,$040,$18a,$cb6,$18c,$dd0,$18e,$7fa
	dc.w	$190,$359,$192,$fec,$194,$428,$196,$ea6
	dc.w	$198,$349,$19a,$5eb,$19c,$2e4,$19e,$508
	dc.w	$1a0,$e85,$1a2,$3f7,$1a4,$8fa,$1a6,$52c
	dc.w	$1a8,$52c,$1aa,$127,$1ac,$d12,$1ae,$947
	dc.w	$1b0,$d7a,$1b2,$225,$1b4,$920,$1b6,$2ff
	dc.w	$1b8,$9ef,$1ba,$934,$1bc,$8fa,$1be,$95e

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;******************************************************************************

; Figura RAW ad 8 bitplanes, cioe' a 256 colori

	CNOP	0,8	; allineo a 64 bit

PICTURE:
	INCBIN	"MURALE320*256*256c.RAW"

	end

Per il disegno originale su muro devo ringraziare la mia ex compagna di classe
Silvia Papucci, che mi ha aiutato a dipingerlo.
Per lo scanner Andrea Scarafoni. (e' immorale scansire un proprio disegno?)

