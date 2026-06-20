
; Lezione11g6.s -  Uso della caratteristica del copper di richiedere 8 pixel
;		   orizzontali per eseguire un suo "MOVE".

	SECTION	copfantasia,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

NUMLINES	=	80


START:
	MOVE.L	#$5001FFFE,D2	; $50 = prima linea verticale
	BSR.W	MAKE_IT		; fai la copper!

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$0e000,d2	; linea da aspettare = $e0
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $e0
	BNE.S	Waity1

	BTST	#2,$16(a5)	; tasto destro premuto?
	BEQ.s	Blocca

	BSR.w	FantaCop	; rulla i colori...

Blocca:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	rts

*****************************************************************************
*		Routine che crea la copperlist per l'effetto		    *
*****************************************************************************

;	  ____________
;	  \          /
;	   \________/
;	     |  ._|_
;	    ____|o \
;	 ___(°__|___)___
;	 \_/  (___)/\\_/
;	  / \_____/  \\
;	_/     \______\\_
;	\_______________/g®m


MAKE_IT:
	LEA	COPBUF,A0		; Indirizzo copper buffer
	MOVEQ	#NUMLINES-1,D6		; numero linee...
MAIN0:
	LEA	COLORS(PC),A1		; Tabella con i colori...
	MOVEQ	#32-1,D7		; Numero 
	MOVE.L	D2,(A0)+		; Metti il WAIT
	MOVE.L	#$01800505,(A0)+	; color0
COP0:
	MOVE.W	#$0180,(A0)+	; registro COLOR0
	MOVE.W	(A1)+,(A0)+	; valore del color0 preso dalla tabella
	DBRA	d7,COP0		 ; Fai una linea con 32 color0...
	MOVE.L	#$01800505,(A0)+ ; Metti un COLOR0
	ADDI.L	#$01020000,D2	; Fai waitare 1 linea sotto e 2 piu' avanti
				; per creare la "diagonale".
	DBRA	d6,MAIN0	; Fai tutte le linee
	RTS

; Tabella colori

COLORS:
 DC.W	$100,$101,$202,$303,$404,$505,$606,$707
 DC.W	$808,$909,$A0A,$B0B,$C0C,$D0D,$E0E,$F0F
 DC.W	$F0F,$E0E,$D0D,$C0C,$B0B,$A0A,$909,$808
 DC.W	$707,$606,$505,$404,$303,$202,$101,$100

*****************************************************************************
*		Routine che cicla i colori dell'effetto			    *
*****************************************************************************

;	    __
;	   (((________.
;	    \_____.---|
;	     ____ |---|
;	  ___(°__||---|__
;	 /   ___  )__/_ /
;	/______)\   _/_/
;	     \___\ /\
;	       \__/g®m


FantaCop:
	LEA	COPBUF+8,A0	; Indirizzo primo col da ciclare
	MOVEQ	#NUMLINES-1,D6	; numero di linee da fare
MOVE1:
	MOVE.W	2(A0),D0	; Salva il primo colore in d0
MOVE0:
	MOVE.W	2(A0),-2(A0)		; copia i 32 colori della linea
	MOVE.W	6(A0),2(A0)		; "indietro" di un posto.
	MOVE.W	6+4(A0),2+4(A0)
	MOVE.W	6+4*2(A0),2+4*2(A0)
	MOVE.W	6+4*3(A0),2+4*3(A0)
	MOVE.W	6+4*4(A0),2+4*4(A0)
	MOVE.W	6+4*5(A0),2+4*5(A0)
	MOVE.W	6+4*6(A0),2+4*6(A0)
	MOVE.W	6+4*7(A0),2+4*7(A0)
	MOVE.W	6+4*8(A0),2+4*8(A0)
	MOVE.W	6+4*9(A0),2+4*9(A0)
	MOVE.W	6+4*10(A0),2+4*10(A0)
	MOVE.W	6+4*11(A0),2+4*11(A0)
	MOVE.W	6+4*12(A0),2+4*12(A0)
	MOVE.W	6+4*13(A0),2+4*13(A0)
	MOVE.W	6+4*14(A0),2+4*14(A0)
	MOVE.W	6+4*15(A0),2+4*15(A0)
	MOVE.W	6+4*16(A0),2+4*16(A0)
	MOVE.W	6+4*17(A0),2+4*17(A0)
	MOVE.W	6+4*18(A0),2+4*18(A0)
	MOVE.W	6+4*19(A0),2+4*19(A0)
	MOVE.W	6+4*20(A0),2+4*20(A0)
	MOVE.W	6+4*21(A0),2+4*21(A0)
	MOVE.W	6+4*22(A0),2+4*22(A0)
	MOVE.W	6+4*23(A0),2+4*23(A0)
	MOVE.W	6+4*24(A0),2+4*24(A0)
	MOVE.W	6+4*25(A0),2+4*25(A0)
	MOVE.W	6+4*26(A0),2+4*26(A0)
	MOVE.W	6+4*27(A0),2+4*27(A0)
	MOVE.W	6+4*28(A0),2+4*28(A0)
	MOVE.W	6+4*29(A0),2+4*29(A0)
	MOVE.W	6+4*30(A0),2+4*30(A0)
	MOVE.W	6+4*31(A0),2+4*31(A0)
	lea	4*32(a0),A0	; puntiamo alla prossima linea
	MOVE.W	D0,-(A0)	; metti il primo colore salvato come ultimo
				; per non interrompere il ciclo.
	lea	14(a0),A0	; saltiamo il wait+move "esterno"
	DBRA	d6,MOVE1	; eseguiamo tutte le linee
	RTS

*****************************************************************************

	SECTION	COPPY,DATA_C

COPLIST:
	dc.w	$100,$200	; bplcon0 - no bitplanes.
COPBUF:
	ds.b	NUMLINES*12+numlines*$20*4 ; spazio per l'effetto.
	dc.w	$ffff,$fffe		; fine copperlist

	end

