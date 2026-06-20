
;  Lezione11l3b.s - allunghiamo "a ondeggio" una pic in senso verticale.

	SECTION	coplanes,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

NumLinee	EQU	53	; Numero di linee da fare nell'effetto.

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
ham		= 1	; 0 = non ham / 1 = ham
scr_bpl		= 6	; Numero Bitplanes

; parametri calcolati automaticamente

scr_w		= scr_bytes*8		; larghezza dello schermo
scr_size	= scr_bytes*scr_h	; dimensione in bytes dello schermo
BPLC0	= ((scr_res&2)<<14)+(scr_bpl<<12)+$200+(scr_lace<<2)+(ham<<11)
DIWS	= (scr_y<<8)+scr_x
DIWSt	= ((scr_y+scr_h/(scr_lace+1))&255)<<8+(scr_x+scr_w/scr_res)&255
DDFS	= (scr_x-(16/scr_res+1))/2
DDFSt	= DDFS+(8/scr_res)*(scr_bytes/2-scr_res)


START:

; Puntiamo la PIC

	LEA	bplpointers,A0
	MOVE.L	#LOGO+40*40,d0	; indirizzo logo (un po' ribassato)
	MOVEQ	#6-1,D7		; 6 bitplanes HAM.
pointloop:
	MOVE.W	D0,6(A0)
	SWAP	D0
	MOVE.W	D0,2(A0)
	SWAP	D0
	ADDQ.w	#8,A0
	ADD.L	#176*40,D0	; lunghezza plane
	DBRA	D7,pointloop

	bsr.s	PreparaCopEff	; Prepara l'effetto copper

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$11000,d2	; linea da aspettare = $110
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $110
	BNE.S	Waity1

	BSR.W	LOGOEFF2	; "allunga" la pic usando i moduli

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$11000,d2	; linea da aspettare = $110
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $110
	BEQ.S	Aspetta

	btst	#6,$bfe001	; Mouse premuto?
	bne.s	mouse
	rts			; esci


*****************************************************************************
;		ROUTINE DI PREPARAZIONE DELL'EFFETTO COPPER		    *
*****************************************************************************

;	 :        __
;	 : .-----'  `-----.
;	_:_|______________|___
;	\                    /
;	 \________/\________/
;	 : |  _        _  |
;	 `-|  \________/  |
;	   |              |
;	   `----,,,,,,----'

PreparaCopEff:

; Crea la copperlist

	LEA	coppyeff1,A0	; Indirizzo dove creare l'effetto in copperlist
	MOVE.L	#$1080000,D0	; bpl1mod
	MOVE.L	#$10A0000,D1	; bpl2mod
	MOVE.L	#$2E07FFFE,D2	; wait (comincia dalla linea $2e)
	MOVE.L	#$01000000,D3	; Valore da addare al wait ogni volta
	MOVEQ	#(NumLinee*2)-1,D7	; 53 linee da fare
makecop1:
	MOVE.L	D2,(A0)+	; Metti il WAIT
	MOVE.L	D0,(A0)+	; Metti il bpl1mod
	MOVE.L	D1,(A0)+	; Metti il bpl2mod
	ADD.L	D3,D2		; Fai aspettare una linea piu' in basso al wait
	DBRA	D7,makecop1

; Moltiplica per il modulo i valori nella tabella, in modo da poter essere
; usati come valori da mettere nei BPL1MOD e BPL2MOD.

	LEA	tabby2,A0	; Indirizzo tabella
	MOVE.W	#200-1,D7	; Numero valori contenuti nella tabella
tab2mul:
	MOVE.W	(A0),D0		; Prendi il valore dalla tabella
	MULU.W	#40,D0		; Moltiplicalo per la lungh. di 1 linea (mod.)
	MOVE.W	D0,(A0)+	; Rimetti il valore moltiplicato e avanza
	DBRA	D7,tab2mul
	rts


; Tabella contenente 200 valori .word, che saranno moltiplicati *40

tabby2:
	dc.w	0,1,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,0,1,0,0,0,1,0,0
	dc.w	0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,0,0,0
	dc.w	0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0
	dc.w	-1,0,0,-1,0,0,0,-1,0,0,-1,0,0,-1,0
	dc.w	0,-1,0,0,0,-1,0,0,-1,0,0,-1,0,0,0
	dc.w	-1,0,0,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0
	dc.w	0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0
	dc.w	0,0,1,0,0,1,0,0,1,0,0,0,1,0,0,1,0
tab2end:

*****************************************************************************
;			ROUTINE COPPER EFFECT DEL LOGO			    *
*****************************************************************************

;	           _
;	       .--' `-.
;	       |     .|      
;	       |  /\__|       
;	       `------'____ __
;	      ./ (_________|__)
;	      |         |_|__)
;	      |         |   __
;	      |_________|  |  |
;	 _____/\_     `----'  |
;	|       (_____________|
;	|   _______/         
;	l__|g®m

; L'effetto in copperlist e' cosi' strutturato:
;
;	DC.W	$2e07,$FFFE	; wait
;	dc.w	$108		; registro bpl1mod
;COPPEREFFY:
;	DC.w	xxx		; valore bpl1mod
;	dc.w	$10A,xxx	; registro e valore bpl1mod
;	wait... eccetera.

LOGOEFF2:
	LEA	coppyeff1+6,A0		; Indirizzo copper effect bpl1mod
	LEA	TABBY2POINTER(PC),A4	; Indirizzo puntatore alla tabella
	LEA	tab2end(PC),A3		; Indirizzo fine della tabella
	MOVE.L	TABBY2POINTER(PC),A1	; Dove siamo attualmente in tabella
	MOVEQ	#10,D0
	MOVEQ	#(NumLinee*2)-1,D7	; numero di linee per l'effetto
LOGOEFFLOOP:
	MOVE.W	(A1),(A0)+	; Copia il valore bpl1mod dalla tab alla cop
	MOVE.W	(A1)+,2(A0)	;  "	  "	  bpl2mod	"	"
	ADDA.L	D0,A0		; Vai al prossimo $dff108 (bpl1mod) in coplist
	CMPA.L	A3,A1		; Era l'ultimo valore della tabella?
	BNE.S	norestart	; Se non ancora, non ripartire
	LEA	tabby2(PC),A1	; Altrimenti, riparti!
norestart:
	DBRA	D7,LOGOEFFLOOP
	ADDQ.L	#4,(A4)		; Salta 2 valori in coplist (se si mette #2 si
				; "rallenta" l'effetto facendo leggere tutti
				; i 200 valori della tabella).
	CMPA.L	(A4),A3		; Fine della tabella?
	BNE.S	NOTABENDY	; Se non ancora, ok
	MOVE.L	#tabby2,(A4)	; Altrimenti ripunta da capo
NOTABENDY:
	RTS

; Puntatore alla tabella usato per leggerne i valori

TABBY2POINTER:
	dc.l	tabby2

******************************************************************************
;		COPPERLIST:
******************************************************************************

	Section	MioCoppero,data_C	

COPPERLIST:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

BPLPOINTERS:
	dc.w $e0,0,$e2,0		;primo 	 bitplane
	dc.w $e4,0,$e6,0		;secondo    "
	dc.w $e8,0,$ea,0		;terzo      "
	dc.w $ec,0,$ee,0		;quarto     "
	dc.w $f0,0,$f2,0		;quinto     "
	dc.w $f4,0,$f6,0		;sesto      "

	dc.w	$180,0	; Color0 nero

	dc.w	$100,BPLC0	; BplCon0 - 320*256 HAM

	dc.w $180,$0000,$182,$134,$184,$531,$186,$443
	dc.w $188,$0455,$18a,$664,$18c,$466,$18e,$973
	dc.w $190,$0677,$192,$886,$194,$898,$196,$a96
	dc.w $198,$0ca6,$19a,$9a9,$19c,$bb9,$19e,$dc9
	dc.w $1a0,$0666

	dc.w	$102	; bplcon1
CON1:
	dc.w	0

coppyeff1:
	dcb.w	12*NumLinee

	dc.w	$9707,$FFFE	; wait linea $97
	dc.w	$100,$200	; no bitplanes
	dc.w	$180,$110	; color0
	dc.w	$9807,$FFFE	; wait
	dc.w	$180,$120	; color0
	dc.w	$9a07,$FFFE
	dc.w	$180,$130
	dc.w	$9b07,$FFFE
	dc.w	$180,$240
	dc.w	$9c07,$FFFE
	dc.w	$180,$250
	dc.w	$9d07,$FFFE
	dc.w	$180,$370
	dc.w	$9e07,$FFFE
	dc.w	$180,$390
	dc.w	$9f07,$FFFE
	dc.w	$180,$4b0
	dc.w	$a007,$FFFE
	dc.w	$180,$5d0
	dc.w	$a107,$FFFE
	dc.w	$180,$4a0
	dc.w	$a207,$FFFE
	dc.w	$180,$380
	dc.w	$a307,$FFFE
	dc.w	$180,$360
	dc.w	$a407,$FFFE
	dc.w	$180,$240
	dc.w	$a507,$FFFE
	dc.w	$180,$120
	dc.w	$a607,$FFFE
	dc.w	$180,$110
	DC.W	$A70F,$FFFE
	DC.W	$180,$000

	dc.w	$FFFF,$FFFE	; Fine della copperlist


	SECTION	LOGO,CODE_C

LOGO:
	incbin	"amiet.raw"	; 6 bitplanes * 176 lines * 40 bytes (HAM)

	END

