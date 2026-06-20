
; Lezione10e6.s	Versione ottimizzata di lezione10c4.s (Effetto riflettore)
;		Tasto sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE1,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#5-1,D1		; numero di bitplanes
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane (qua e' alto 256 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5

; qui il blitter e` sicuramente fermo perche` ha provveduto la startup
; quindi possiamo tranquillamente settare i registri.
; I seguenti registri sono usati sempre con gli stessi valori, quindi
; li inizializziamo una volta per tutte all'inizio del programma.

	move.l	#$ffffffff,$44(a5)	; BLTAFWM/BLTALWM
	move.w	#$0000,$42(a5)		; BLTCON1 modo ascendente
	move.l	#$00200000,$62(a5)	; BLTBMOD (40-8=32=$20)
					; BLTAMOD (=0)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse2:

Loop:
	cmp.b	#$ff,$6(a5)	; VHPOSR - aspetta la linea $ff
	bne.s	loop
Aspetta:
	cmp.b	#$ff,$6(a5)	; ancora linea $ff?
	beq.s	Aspetta

	bsr.s	ClearScreen	; pulisci schermo
	bsr.w	SpostaMaschera	; sposta posizione riflettore
	bsr.s	Riflettore	; routine effetto

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts

;***************************************************************************
; Questa routine cancella la porzione di schermo interessata dalla blittata
;***************************************************************************

ClearScreen:
	moveq	#5-1,d7			; 5 bit-planes
	lea	BITPLANE1+100*40,a1	; indirizzo zona da cancellare (plane1)

	move.w	#(64*39)+20,d5		; valore da scrivere in BLTSIZE
					; lo mettiamo in D5 per ottimizzare
					; la scrittura

	btst	#6,2(a5) 		; dmaconr
WBlit1a:
	btst	#6,2(a5) 		; attendi che il blitter abbia finito
	bne.s	wblit1a			; prima di modificare i registri

	move.w	#$0100,$40(a5)		; BLTCON0. Cancellazione
	move.w	#$0000,$66(a5)		; BLTDMOD questi 2 registri sono usati
					; con valori diversi nella routine
					; Riflettore, quindi devono essere
					; reinizializzati ogni volta
					; e` comunque necessario farlo una
					; volta sola, fuori dal loop.

ClearLoop:
	btst	#6,2(a5) 		; dmaconr
WBlit1b:
	btst	#6,2(a5) 		; attendi che il blitter abbia finito
	bne.s	wblit1b			; prima di blittare

	move.l	a1,$54(a5)
	move.w	d5,$58(a5)		; scrivi BLTSIZE
					; il valore e` stato precedentemente
					; scritto in D5

	add.l	#256*40,a1		; indirizzo prossimo plane
	dbra	d7,Clearloop
	rts

;*****************************************************************************
; Questa routine realizza l'effetto riflettore. Viene effettuata un'operazione
; di AND tra la figura e una maschera
;*****************************************************************************

;	   |\_._/|        |,\__/|        |\__/,|  
;	   | o o |        |  o o|        |o o  |  
;	   (  T  )        (   T )        ( T   )  
;	  .^`-^-'^.      .^`--^'^.      .^`^--'^. 
;	  `.  ;  .'      `.  ;  .'      `.  ;  .' 
;	  | | | | |      | | | | |      | | | | | 
;	 ((_((|))_))    ((_((|))_))    ((_((|))_))

Riflettore:
	moveq	#5-1,d7			; 5 bit-planes
	lea	Figura+40,a0		; ind. figura
	lea	BITPLANE1+100*40,a1	; ind. destinazione

	move.w	MascheraX(PC),d0 ; posizione riflettore
	move.w	d0,d2		; copia
	and.w	#$000f,d0	; si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word...
	or.w	#$0dc0,d0	; ...giusti per inserirsi nel registro BLTCON0
				; notate LF=$C0 (cioe` AND tra A e B)
	lsr.w	#3,d2		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d2	; escludo il bit 0 del
	add.w	d2,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto nella figura
	add.w	d2,a1		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	move.l	#Maschera,a2		; valore da scrivere in BLTAPT
					; (puntatore maschera)
					; lo mettiamo in A2 per ottimizzare
					; la scrittura

	move.w	#(64*39)+4,d5		; valore da scrivere in BLTSIZE
					; lo mettiamo in D5 per ottimizzare
					; la scrittura

	btst	#6,2(a5) 		; dmaconr
WBlit2a:
	btst	#6,2(a5) 		; attendi che il blitter abbia finito
	bne.s	wblit2a			; prima di modificare i registri

	move.w	#32,$66(a5)		; BLTDMOD (40-8=32)
	move.w	d0,$40(a5)		; BLTCON0 questi 2 registri sono usati
					; con valori diversi nella routine
					; ClearScreen, quindi devono essere
					; reinizializzati ogni volta
					; e` comunque necessario farlo una
					; volta sola, fuori dal loop.

Drawloop:
	btst	#6,2(a5) 		; dmaconr
WBlit2b:
	btst	#6,2(a5) 		; attendi che il blitter abbia finito
	bne.s	wblit2b			; prima di blittare

	move.l	a2,$50(a5)		; BLTAPT  puntatore maschera
					; il valore e` stato precedentemente
					; scritto in A2
	move.l	a0,$4c(a5)		; BLTBPT  puntatore figura
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	d5,$58(a5)		; scrivi BLTSIZE
					; il valore e` stato precedentemente
					; scritto in D5

	add.w	#56*40,a0		; ind. prossimo plane figura
	add.w	#256*40,a1		; ind. prossimo plane destinazione
	dbra	d7,Drawloop
	rts

;*****************************************************************************
; Questa routine legge la coordinata orizzontale da una tabella
; e la memorizza nella variabile MASCHERAX
;*****************************************************************************

SpostaMaschera:
	ADDQ.L	#2,TABXPOINT		; Fai puntare alla word successiva
	MOVE.L	TABXPOINT(PC),A0	; indirizzo contenuto in long TABXPOINT
					; copiato in a0
	CMP.L	#FINETABX-2,A0  	; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTX		; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT 	; Riparti a puntare dalla prima word-2
NOBSTARTX:
	MOVE.W	(A0),MascheraX		; copia il valore nella variabile
	rts

MascheraX:
		dc.w	0	; posizione attuale maschera
TABXPOINT:
		dc.l	TABX	; puntatore alla tabella

; tabella posizioni maschera

TABX:
	DC.W	$12,$16,$19,$1D,$21,$25,$28,$2C,$30,$34
	DC.W	$37,$3B,$3F,$43,$46,$4A,$4E,$51,$55,$58
	DC.W	$5C,$60,$63,$67,$6A,$6E,$71,$74,$78,$7B
	DC.W	$7F,$82,$85,$89,$8C,$8F,$92,$95,$98,$9C
	DC.W	$9F,$A2,$A5,$A8,$AA,$AD,$B0,$B3,$B6,$B8
	DC.W	$BB,$BE,$C0,$C3,$C5,$C8,$CA,$CC,$CF,$D1
	DC.W	$D3,$D5,$D8,$DA,$DC,$DE,$E0,$E1,$E3,$E5
	DC.W	$E7,$E8,$EA,$EC,$ED,$EE,$F0,$F1,$F2,$F4
	DC.W	$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FB,$FC,$FD
	DC.W	$FD,$FE,$FE,$FF,$FF,$FF,$100,$100,$100,$100
	DC.W	$100,$100,$100,$100,$FF,$FF,$FF,$FE,$FE,$FD
	DC.W	$FD,$FC,$FB,$FB,$FA,$F9,$F8,$F7,$F6,$F5
	DC.W	$F4,$F2,$F1,$F0,$EE,$ED,$EC,$EA,$E8,$E7
	DC.W	$E5,$E3,$E1,$E0,$DE,$DC,$DA,$D8,$D5,$D3
	DC.W	$D1,$CF,$CC,$CA,$C8,$C5,$C3,$C0,$BE,$BB
	DC.W	$B8,$B6,$B3,$B0,$AD,$AA,$A8,$A5,$A2,$9F
	DC.W	$9C,$98,$95,$92,$8F,$8C,$89,$85,$82,$7F
	DC.W	$7B,$78,$74,$71,$6E,$6A,$67,$63,$60,$5C
	DC.W	$58,$55,$51,$4E,$4A,$46,$43,$3F,$3B,$37
	DC.W	$34,$30,$2C,$28,$25,$21,$1D,$19,$16,$12
FINETABX:

;*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$5200	; bplcon0

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000
	dc.w $ec,$0000,$ee,$0000
	dc.w $f0,$0000,$f2,$0000

Colours:
	dc.w	$180,0,$182,$f10,$184,$f21,$186,$f42
	dc.w	$188,$f53,$18a,$f63,$18c,$f74,$18e,$f85
	dc.w	$190,$f96,$192,$fa6,$194,$fb7,$196,$fb8
	dc.w	$198,$fc9,$19a,$f21,$19c,$f10,$19e,$f00
	dc.w	$1a0,$eff,$1a2,$eff,$1a4,$dff,$1a6,$dff
	dc.w	$1a8,$cff,$1aa,$bef,$1ac,$bef,$1ae,$adf
	dc.w	$1b0,$9df,$1b2,$9cf,$1b4,$8bf,$1b6,$7bf
	dc.w	$1b8,$7af,$1ba,$69f,$1bc,$68f,$1be,$57f

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;*****************************************************************************

; qui c'e` il disegno, largo 320 pixel, alto 56 linee e formato da 5 plane

Figura:
	incbin	lava320*56*5.raw

;*****************************************************************************

; Questa e` la maschera. E` una figura formata da un solo bitplane,
; alta 39 linee e larga 4 words

Maschera:
	dc.l	$00007fc0,$00000000,$0003fff8,$00000000,$000ffffe,$00000000
	dc.l	$001fffff,$00000000,$007fffff,$c0000000,$00ffffff,$e0000000
	dc.l	$01ffffff,$f0000000,$03ffffff,$f8000000,$03ffffff,$f8000000
	dc.l	$07ffffff,$fc000000,$0fffffff,$fe000000,$0fffffff,$fe000000
	dc.l	$1fffffff,$ff000000,$1fffffff,$ff000000,$1fffffff,$ff000000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000,$3fffffff,$ff800000,$3fffffff,$ff800000
	dc.l	$1fffffff,$ff000000,$1fffffff,$ff000000,$1fffffff,$ff000000
	dc.l	$0fffffff,$fe000000,$0fffffff,$fe000000,$07ffffff,$fc000000
	dc.l	$03ffffff,$f8000000,$03ffffff,$f8000000,$01ffffff,$f0000000
	dc.l	$00ffffff,$e0000000,$007fffff,$c0000000,$001fffff,$00000000
	dc.l	$000ffffe,$00000000,$0003fff8,$00000000,$00007fc0,$00000000
	
;*****************************************************************************

	SECTION	bitplane,BSS_C
BITPLANE1:
	ds.b	40*256
BITPLANE2:
	ds.b	40*256
BITPLANE3:
	ds.b	40*256
BITPLANE4:
	ds.b	40*256
BITPLANE5:
	ds.b	40*256

	end

;*****************************************************************************

Questo esempio e` la versione ottimizzata di lezione10c4.s. le ottimizzazioni
sono spiegate nel listato.

