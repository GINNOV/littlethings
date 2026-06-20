
;  Lezione11l2.s - Si cambiano per ogni linea ben 3 colori su 4 (2 bitplanes).

	SECTION	coplanes,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

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
scr_lace	= 0	; 0 = non interlace (xxx*256) / 1 = interlace (xxx*512)
ham		= 0	; 0 = non ham / 1 = ham
scr_bpl		= 2	; Numero Bitplanes

; parametri calcolati automaticamente

scr_w		= scr_bytes*8		; larghezza dello schermo
scr_size	= scr_bytes*scr_h	; dimensione in bytes dello schermo
BPLC0	= ((scr_res&2)<<14)+(scr_bpl<<12)+$200+(scr_lace<<2)+(ham<<11)
DIWS	= (scr_y<<8)+scr_x
DIWSt	= ((scr_y+scr_h/(scr_lace+1))&255)<<8+(scr_x+scr_w/scr_res)&255
DDFS	= (scr_x-(16/scr_res+1))/2
DDFSt	= DDFS+(8/scr_res)*(scr_bytes/2-scr_res)


START:

; Puntiamo i planes

	MOVE.L	#Bitplane1,d0
	LEA	PLANES,a0
	MOVEQ	#2-1,d7		; 2 bitplanes
PLOOP:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.w	#8,a0
	dbra	d7,ploop

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#LISTE,$80(a5)		; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	bsr.s	CreaCopper	; crea la copperlist

	LEA	TESTO(PC),A0	; testo da stampare
	LEA	BITPLANE1,A3	; destinazione
	bsr.w	print		; Stampa

	LEA	TESTO2(PC),A0	; testo da stampare
	LEA	BITPLANE2,A3	; destinazione
	bsr.w	print		; Stampa

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta

	BSR.w	RASTERMAGIC	; copia da tabelle in copperlist
	BSR.w	CYCLEBLU	; cicla la tab del blu (verso il basso)
	BSR.w	CYCLERED	; cicla la tab del rosso (verso l'alto)
	BSR.w	CYCLEGREEN	; cicla la tab del verde (verso l'alto)

	btst.b	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
; Questa routine crea la copperlist
*****************************************************************************

;	            _____
;	           /   _/
;	          /_____\
;	 _        \ o.O /
;	/ )________\_-_/_________
;	\__/      _  Y  _       /__
;	 _/______/   :   \_____/__ \
;	       _/    :    \_  .--(_/
;	       \_____:_____/.
;	       /    ___   :\ :
;	      /      |   :..:
;	    _/       |       \
;	   _\________|        \_
;	  (__________l_________/_ _ _
;	             (___________))

CreaCopper:
	LEA	CopperEffyz,A1
	MOVE.l	#$180,d2	; col 0
	MOVE.l	#$182,d3	; col 1
	MOVE.l	#$186,d4	; col 3
	MOVEQ	#-2,D5		; $FFFE	; wait command
	MOVE.W	#$0100,d6	; WAIT ADD: 0107FFFE, 0207FFFE....
	MOVE.W	#$2C07,D1	; start line
	MOVEQ	#7-1,D7		; Num. loops
AGAIN:
	LEA	ColTabBlu(PC),A0
	LEA	ColTabRosso(PC),A2
	LEA	ColTabVerde(PC),A3

	REPT	28		; num of lines: 28*d7
	MOVE.W	D1,(A1)+	; line to wait...
	MOVE.W	d5,(A1)+	; $FFFE wait command
	MOVE.W	d2,(A1)+	; col register 0
	MOVE.W	(A0)+,(A1)+	; col value da tab blu
	MOVE.W	d3,(A1)+	; col register 1
	MOVE.W	(A2)+,(A1)+	; col value da tab rossa
	MOVE.W	d4,(A1)+	; col register 3
	MOVE.W	(A3)+,(A1)+	; col value da tab Verde
	ADD.W	d6,D1		; Fai waitare una linea sotto
	ENDR

	DBRA	D7,AGAIN
	RTS

*****************************************************************************

;	              __ ___
;		     (______)
;		    __||||||__
;		   (__________)
;		     |      |
;		     _ __   |
;		    (.(._) (((
;		   (__ __   __)
;		   ./    \  |
;	magico!	   `----( \ |
;		  __ \____/ /\__
;		 /  /__\___/__\ \
;		/   __   o  __   ì g®m


RASTERMAGIC:
	LEA	CopperEffyz,A1
	MOVEQ	#7-1,D7		; Num. loops
AGAIN2:
	LEA	ColTabBlu(PC),A0
	LEA	ColTabRosso(PC),A2
	LEA	ColTabVerde(PC),A3

	REPT	28		; num of lines: 28*d7
	addq.w	#2+4,a1		; salta il wait e il col register 0
	MOVE.W	(A0)+,(A1)+	; col value da tab blu
	addq.w	#2,a1		; salta il col register 1
	MOVE.W	(A2)+,(A1)+	; col value da tab rossa
	addq.w	#2,a1		; salta il col register 3
	MOVE.W	(A3)+,(A1)+	; col value da tab Verde
	ADD.W	d6,D1		; Fai waitare una linea sotto
	ENDR

	DBRA	D7,AGAIN2
	RTS

*****************************************************************************

;	    _))_
;	  ./    \.
;	  |      |
;	 \_ __/  |
;	 (-(--)  |
;	(__ __  (((
;	 /__  \  __)
;  Ue'..  __)  \ | g®m
;	 (_____/ |

CYCLEBLU:
	LEA	ColTabBlu+54(PC),A0
	LEA	ColTabBlu+52(PC),A1
	MOVE.W	ColTabBlu+54(PC),D1	; salva l'ultimo colore

	REPT	27
	MOVE.W	(A1),(A0)	; cycle2
	SUBQ.W 	#2,A0
	SUBQ.W	#2,A1
	ENDR

	MOVE.W	D1,ColTabBlu	; Rimetti l'ultimo 
	RTS

*****************************************************************************

CYCLERED:
 	LEA	ColTabRosso(PC),A0
	LEA	ColTabRosso+2(PC),A1
	MOVE.W	(A0),56(A0)

	REPT	29		; cycle 2
	MOVE.W	(A1)+,(A0)+
	ENDR

	RTS
		
CYCLEGREEN:
 	LEA	ColTabVerde(PC),A0
	LEA	ColTabVerde+2(PC),A1
	MOVE.W	(A0),56(A0)

	REPT	29		; cycle 3
	MOVE.W	(A1)+,(A0)+
	ENDR

	RTS		

ColTabBlu:
	DC.W	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	DC.W	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,0,0,0

ColTabRosso:
	DC.W	$100,$200,$300,$400,$500,$600,$700,$800,$900
	DC.W	$A00,$B00,$C00,$D00,$E00,$F00,$F00,$E00,$C00
	DC.W	$B00,$A00,$900,$800,$700,$600,$500,$400,$300
	DC.W	$200,$100,0,0,0,0

ColTabVerde:
	DC.W	$010,$020,$030,$040,$050,$060,$070,$080,$090
	DC.W	$0A0,$0B0,$0C0,$0D0,$0E0,$0F0,$0F0,$0E0,$0D0,$0C0
	DC.W	$0B0,$0A0,$090,$080,$070,$060,$050,$040,$030,$020
	DC.W	$010,0,0,0,0


*****************************************************************************
;	Routine che stampa caratteri larghi 8x8 pixel
*****************************************************************************

PRINT:
	MOVEQ	#23-1,D3	; NUMERO RIGHE DA STAMPARE: 23
PRINTRIGA:
	MOVEQ	#40-1,D0	; NUMERO COLONNE PER RIGA: 40
PRINTCHAR2:
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE
	LSL.W	#3,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.w	#1,A3		; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (40) CARATTERI PER RIGA

	ADD.W	#40*7,A3	; ANDIAMO A CAPO

	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE

	RTS


		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
	dc.b	'   PRIMA RIGA (solo in testo1)          ' ; 1
	dc.b	'                                        ' ; 2
	dc.b	'     /\  /          # #                 ' ; 3
	dc.b	'    /  \/           # #                 ' ; 4
	dc.b	'                    # #                 ' ; 5
	dc.b	'        SESTA RIGA (entrambi i bitplane)' ; 6
	dc.b	'                                        ' ; 7
	dc.b	'                                        ' ; 8
	dc.b	'FABIO CIUCCI               INTERNATIONAL' ; 9
	dc.b	'                                        ' ; 10
	dc.b	'   1  4 6 89  !@ $ ^& () +| =- ]{       ' ; 11
	dc.b	'                                        ' ; 12
	dc.b	'     LA  A I G N T C  OBLITERAZIONE     ' ; 15
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 16
	dc.b	'  Nel mezzo del cammin di nostra vita   ' ; 17
	dc.b	'                                        ' ; 18
	dc.b	'    Mi RitRoVaI pEr UnA sELva oScuRa    ' ; 19
	dc.b	'                                        ' ; 20
	dc.b	'    CHE LA DIRITTA VIA ERA              ' ; 21
	dc.b	'                                        ' ; 22
	dc.b	'  AHI Quanto a DIR QUAL ERA...          ' ; 23
	dc.b	'                                        ' ; 24
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 26
	dc.b	'                                        ' ; 27

	EVEN

		; numero caratteri per linea: 40
TESTO2:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
	dc.b	'                                        ' ; 1
	dc.b	'  SECONDA RIGA (solo in testo2)         ' ; 2
	dc.b	'     /\  /          ##                  ' ; 3
	dc.b	'    /  \/           ##                  ' ; 4
	dc.b	'                    ##                  ' ; 5
	dc.b	'        SESTA RIGA (entrambi i bitplane)' ; 6
	dc.b	'                                        ' ; 7
	dc.b	'                                        ' ; 8
	dc.b	'FABIO        COMMUNICATION INTERNATIONAL' ; 9
	dc.b	'                                        ' ; 10
	dc.b	'   1234567 90  @#$%^&*( _+|\=-[]{}      ' ; 11
	dc.b	'                                        ' ; 12
	dc.b	'     LA PALINGENETICA  B I E A I N      ' ; 15
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 16
	dc.b	'  Nel       del cammin di        vita   ' ; 17
	dc.b	'                                        ' ; 18
	dc.b	'    Mi          pEr UnA       oScuRa    ' ; 19
	dc.b	'                                        ' ; 20
	dc.b	'    CHE LA         VIA ERA SMARRITA     ' ; 21
	dc.b	'                                        ' ; 22
	dc.b	'  AHI Quanto a     QUAL ERA...          ' ; 23
	dc.b	'                                        ' ; 24
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 26
	dc.b	'                                        ' ; 27

	EVEN

;	Il FONT caratteri 8x8 copiato in CHIP dalla CPU e non dal blitter,
;	per cui puo' stare anche in fast ram. Anzi sarebbe meglio!

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

*****************************************************************************

	SECTION	COP,DATA_C

LISTE:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop

	dc.w	$102,$0		; Bplcon1
	dc.w	$104,$0		; Bplcon2
	dc.w	$108,$0		; Bpl1mod
	dc.w	$10a,$0		; Bpl2mod
PLANES:
	DC.W	$E0,0,$E2,0,$E4,0,$E6,0
	dc.w	$100,BPLC0	; Bplcon0 - 2 bitplanes lowres
	DC.W	$184,$fff	; color2 giallo (quello fisso)
CopperEffyz:
	DCB.W	28*8*7		; Spazio per l'effetto
	DC.W	$FFFF,$FFFE

*****************************************************************************

	SECTION	BPLBUF,BSS_C

Bitplane1:
	ds.b	40*256
Bitplane2:
	ds.b	40*256

	END

Avete notato la bandierina italiana?? Mettiamo sempre un riconoscimento per
gli stranieri! Ci fanno un baffo!

