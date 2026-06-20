
; Lezione8o.s	8 barre alte 13*2 linee ciascuna che rimbalzano.
;		Tasto destro per disattivare la pulizia dello sfondo.

	SECTION	Barre,CODE

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA
;		 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

START:
	BSR.s	INITCOPPER		; Crea la copperlist con una routine

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1

	btst	#2,$16(a5)	; Tasto destro del mouse premuto?
	beq.s	SaltaPulizia	; Se si non "pulire"

	BSR.s	CLRCOPPER	; "Pulisci" lo sfondo del copper

SaltaPulizia:
	BSR.s	DOBARS		; Fai le barre

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	rts

*************************************************************************
*	BARRE COL COPPER - istruzioni:					*
*									*
*	BSR.s INITCOPPER ; eseguire prima di puntare la Copperlist per	*
*			 ; creare la copperlist (fatta di WAIT e COLOR0)*
*									*
*	BSR.s CLRCOPPER	 ; eseguire per cancellare le vecchie barre	*
*			 ; "annerendo" tutti i COLOR0 della copperlist	*
*			 ; NOTA: si puo' cambiare il colore dello sfondo*
*			 ; agendo sull'equate SFONDO = $xxx		*
*									*
*	BSR.s DOBARS	 ; Visualizza le barre	richiamando PUTBARS	*
*									*
*************************************************************************

coplines	=	100	; numero linee di copperlist da fare per
				; l'effetto delle barre.
SFONDO		=	$004	; Colore dello "sfondo"


;	    /¯¯¯¯¯¯¯¯¯¯\
;	  .~            ~.
;	  | ·     \/   : |
;	  | |_____||___| |
;	.--./ ___ \/ __\.-.
;	|~\/ ( o~\></o~)\~|
;	`c(   ¯¯¯_/ \¯¯  )'
;	  /\    ( ( )¯) /\
;	 /  .'___~\_/~___ \
;	 \   {IIIII[]II:· /
;	  \   \::.   //  /
;	   \  \::::.//  /
;	    \  \\IIII]_/
;	     \   ¯¯¯¯  )
;	      \  ¯¯¯¯¯/
;	       ¯~~~~¯¯

; INITCOPPER crea la parte di copperlist con tanti WAIT e COLOR0 di seguito

INITCOPPER:
	lea	barcopper,a0	; Indirizzo dove creare la copperlist
	move.l	#$3001fffe,d1	; Prima wait: linea $30 - WAIT in d1
	move.l	#$01800000,d2	; COLOR0 in d2
	move.w  #coplines-1,d0	; numero di linee copper
initloop:
	move.l	d1,(a0)+	; metti il WAIT
	move.l	d2,(a0)+	; metti il COLOR0
	add.l	#$02000000,d1	; prossimo wait, aspetta 2 linee piu' in basso
	dbra	d0,initloop
	rts

; CLRCOPPER "pulisce" l'effetto copper, facendo diventare NERI ($000) tutti
;	    i valori dei COLOR0 nella copperlist (o meglio del colore SFONDO)

CLRCOPPER:
	lea	barcopper,a0	; Indirizzo dei WAIT/COLOR0 in copperlit
	move.w	#coplines-1,d0	; numero di linee
	MOVE.W	#SFONDO,d1	; Colore RGB di sfondo
clrloop:
	move.w	d1,6(a0)	; Cambia questo Color 0
	addq.w	#8,a0		; prossimo Color0 in copperlist
	dbra 	d0,clrloop
	rts

; DOBARS effettua lo "scorrimento" delle barre colorate, una per una,
;	 richiamando la sottoroutine PUTBAR per ogni barra

DOBARS:
	lea	bar1(PC),a0
	move.l	barpos1(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos1
	lea	bar2(PC),a0
	move.l	barpos2(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos2
	lea	bar3(PC),a0
	move.l	barpos3(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos3
	lea	bar4(PC),a0
	move.l	barpos4(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos4
	lea	bar5(PC),a0
	move.l	barpos5(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos5
	lea	bar6(PC),a0
	move.l	barpos6(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos6
	lea	bar7(PC),a0
	move.l	barpos7(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos7
	lea	bar8(PC),a0
	move.l	barpos8(PC),d0
	bsr.s	putbar
	move.l 	d0,barpos8
	rts

;	Sottoroutine, in entrata:
;	a0 = indirizzo BARx, ossia i colori della barra
;	d0 = posizione BARx

putbar:	
	lsl.l	#1,d0		; sposta a sinistra di 1 bit il barpos
	lea	poslist(PC),a1	; indirizzo tabella con le posizioni in a1
	add.l	d0,a1		; somma barpos ad a1, trovando il giusto
				; valore di posizione nella poslist
	cmp.b	#$ff,(a1)	; siamo all'ultimo valore di poslist??
	bne.s	putbar1		; se no, non ripartire da capo
	moveq	#0,d0
	lea	poslist,a1	; se si, riparti da capo
putbar1:
	moveq	#0,d2
	move.b	(a1),d2		; valore dalla tabella POSLIST
	lsl.l	#3,d2		; shiftiamo a sinistra di 3 bit (moltipl.*8)
	lea	barcopper,a2	; indirizzo barre in copperlist
	add.l	d2,a2		; sommo valore preso dalla poslist e
				; moltiplicato per 8, ossia trovo in a2
				; l'indirizzo del wait giusto dove deve essere
				; la mia barra
	moveq	#13-1,d4	; Ogni barra e' alta 14 linee
putloop:
	move.w	(a0)+,6(a2)	; copio il colore della barra da BARx al
				; dc.w $180,xxx in copperlit
	addq.w	#8,a2		; vado al prossimo valore di color0
	dbra	d4,putloop	; e rifaccio 14 volte per fare tutta la barra

	lsr.l	#1,d0		; riporto il barpos a destra di 1 bit
	addq.l	#1,d0		; e aggiungo 1, per il prossimo ciclo.
	rts


; Queste sono le posizioni delle barre l'una rispetto all'altra. Come vedete
; sono poste l'una dopo l'altra, e in questo ordine si susseguono.

barpos1:	dc.l 0
barpos2:	dc.l 4
barpos3:	dc.l 8
barpos4:	dc.l 12
barpos5:	dc.l 16
barpos6:	dc.l 20
barpos7:	dc.l 24
barpos8:	dc.l 28


; Queste sono le 8 barre, ossia i 13 colori RGB che compongono ognuna di
; esse. Per esempio la Bar1 e' BLU, la bar2 e' GRIGIA ecc.

; colori:     RGB, RGB, RGB, RGB, RGB, RGB, RGB, RGB, RGB, RGB, RGB, RGB, RGB
bar1:
	DC.W $002,$004,$006,$008,$00a,$00c,$00f,$00c,$00a,$008,$006,$004,$002
bar2:
	DC.W $222,$444,$666,$888,$aaa,$ccc,$fff,$ccc,$aaa,$888,$666,$444,$222
bar3:
	DC.W $200,$400,$600,$800,$a00,$c00,$f00,$c00,$a00,$800,$600,$400,$200
bar4:
	DC.W $020,$040,$060,$080,$0a0,$0c0,$0f0,$0c0,$0a0,$080,$060,$040,$020
bar5:
	DC.W $012,$024,$036,$048,$05a,$06c,$07f,$06c,$05a,$048,$036,$024,$012
bar6:
	DC.W $202,$404,$606,$808,$a0a,$c0c,$f0f,$c0c,$a0a,$808,$606,$404,$202
bar7:
	DC.W $210,$420,$630,$840,$a50,$c60,$f70,$c80,$a70,$860,$650,$440,$230
bar8:
	DC.W $220,$440,$660,$880,$aa0,$cc0,$ff0,$cc0,$aa0,$880,$660,$440,$220



; Questa e' la tabella (o lista) delle posizioni verticali che possono
; assumere le barre colorate. si termina con il valore $FF.
; come indicazione, questa tabella e' fatta da "IS" con questi parametri:
; BEG>0
; END>180
; AMOUNT>150
; AMPLITUDE>85
; YOFFSET>0
; SIZE (B/W/L)>B
; MULTIPLIER>1

poslist:
	DC.B	$01,$03,$04,$06,$08,$0A,$0C,$0D,$0F,$11,$13,$14,$16,$18,$19,$1B
	DC.B	$1D,$1E,$20,$22,$23,$25,$27,$28,$2A,$2B,$2D,$2E,$30,$31,$33,$34
	DC.B	$35,$37,$38,$3A,$3B,$3C,$3D,$3F,$40,$41,$42,$43,$44,$45,$46,$47
	DC.B	$48,$49,$4A,$4B,$4C,$4D,$4D,$4E,$4F,$4F,$50,$51,$51,$52,$52,$53
	DC.B	$53,$53,$54,$54,$54,$54,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	DC.B	$54,$54,$54,$54,$53,$53,$53,$52,$52,$51,$51,$50,$4F,$4F,$4E,$4D
	DC.B	$4D,$4C,$4B,$4A,$49,$48,$47,$46,$45,$44,$43,$42,$41,$40,$3F,$3D
	DC.B	$3C,$3B,$3A,$38,$37,$35,$34,$33,$31,$30,$2E,$2D,$2B,$2A,$28,$27
	DC.B	$25,$23,$22,$20,$1E,$1D,$1B,$19,$18,$16,$14,$13,$11,$0F,$0D,$0C
	DC.B	$0A,$08,$06,$04,$03,$01

	DC.b	$FF	; fine della tabella

	even

*************************************************************************
;	Copperlist
*************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
	dc.w	$100,$200	; 0 bitplanes

barcopper:			; Qua verra' costruita la copperlist per
	dcb.w	coplines*4,0	; l'effetto delle barre - in questo caso
				; servono 400 words. (coplines=100)

	DC.W	$ffdf,$fffe
	dc.w	$0107,$FFFE
	dc.w	$180,$222	; Color0 grigio

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end

Questo listato mostra come si possano "costruire" delle copperlist lunghe, ma
regolari, con delle routines. Piu' avanti vedremo come spesso gli effetti piu'
spettacolari nascondono copperlist lunghe chilometri.

Modifiche consigliate: per rendere piu' "schiacciato" il tutto, fate attendere
ogni linea, e non ogni due linee. Basta modificare INITCOPPER:

	add.l	#$01000000,d1	; prossimo wait, aspetta 1 linea piu' in basso

Ora le barre sono alte 13 linee, e non 13*2 linee!
Potete far anche attendere ogni 3 linee, ma cosi' facendo andate troppo in
basso, comunque provate:

	add.l	#$03000000,d1	; prossimo wait, aspetta 3 linee piu' in basso

