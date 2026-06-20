
; Lezione10c5.s	Effetto riflettore su schermo interleaved
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
	ADD.L	#40,d0		; INTERLEAVED! lungh. 1 linea
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
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

;**************************************************************************
; Questa routine cancella la porzione di schermo interessata dalla blittata
;**************************************************************************

ClearScreen:
	lea	BITPLANE1+100*40*5,a1	; indirizzo zona da cancellare (plane1)

	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$01000000,$40(a5)	; BLTCON0 + BLTCON1. Cancellazone
	move.w	#$0000,$66(a5)
	move.l	a1,$54(a5)
	move.w	#(64*39*5)+20,$58(a5)
	rts

;*****************************************************************************
; Questa routine realizza l'effetto riflettore. Viene effettuata un'operazione
; di AND tra la figura e una maschera
;*****************************************************************************

;	      ___________
;	     /           \
;	    /\            \
;	   / /\____________)____
;	   \/:/\___   ___/\     \
;	    \/ ___ \_/ ___ \     \
;	    ( /  o)   (  o\ )____/
;	     \\__/ /Y\ \__//
;	     (___/(_n_)\___)
;	   __//\ _ _ _ _ /\\__
;	  /==\\_Y Y Y Y Y_//==\
;	 /    `-| | | | |-'    \
;	/       `-^-^-^-'       \

Riflettore:
	lea	Figura+40*5,a0		; ind. figura
	lea	BITPLANE1+100*40*5,a1	; ind. destinazione

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

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffffffff,$44(a5)	; maschere
	move.w	d0,$40(a5)		; BLTCON0
	move.w	#$0000,$42(a5)		; BLTCON1 modo ascendente
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#32,$62(a5)		; BLTBMOD (40-8=32)
	move.w	#32,$66(a5)		; BLTDMOD (40-8=32)

	move.l	#Maschera,$50(a5)	; BLTAPT  puntatore maschera
	move.l	a0,$4c(a5)		; BLTBPT  puntatore figura
	move.l	a1,$54(a5)		; BLTDPT  puntatore destinazione
	move.w	#(64*39*5)+4,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 4 word
	rts				; altezza 39 linee
					; 5 planes

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

MascheraX;
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
	dc.w	$108,160	; VALORE MODULO = 2*20*(5-1)= 160
	dc.w	$10a,160

	dc.w	$100,$5200	; bplcon0

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000
	dc.w $ec,$0000,$ee,$0000
	dc.w $f0,$0000,$f2,$0000

Colours:
	dc.w	$180,$000,$182,$f10,$184,$f21,$186,$f42
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
	incbin	lava320*56*5.rawblit

;*****************************************************************************

; Questa e` la maschera. In formato interleaved e` formata da 5 planes
; alta 39 linee e larga 4 words 

Maschera:
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$3fffffff,$ff800000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$1fffffff,$ff000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$fffffff,$fe000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$7ffffff,$fc000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$3ffffff,$f8000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$1ffffff,$f0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$ffffff,$e0000000
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$7fffff,$c0000000
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$1fffff,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$ffffe,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$3fff8,0
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	dc.l	$7fc0,0
	
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

In questo esempio realizziamo l'effetto "riflettore" con uno schermo
interleaved. La tecnica e` la stessa di lezione10c4.s. L'unica differenza e`
che stavolta, poiche` usiamo uno schermo interleaved, possiamo blittare i plane
tutti insieme. Questo fatto (che come sappiamo aumenta la velocita`) ci crea
pero` problemi con la maschera. Infatti siccome blittiamo tutti i planes in una
sola volta, abbiamo bisogno di una maschera per ogni plane. In questo caso
quindi la nostra maschera e` formata da 5 planes tutti uguali. Poiche` e`
interleaved, in pratica e` come prendere la maschera da un plane e ripetere
ogni riga 5 volte. In questo caso, dunque il formato interleaved ci costringe
a usare una maschera da 5 planes che occupa piu` memoria di quella da un solo
plane.
