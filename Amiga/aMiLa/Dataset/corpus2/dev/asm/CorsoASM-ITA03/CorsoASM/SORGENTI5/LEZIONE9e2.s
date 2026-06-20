
; Lezione9e2.s		SHIFTAMENTO CON oggetto largo 2 word (una azzerata)

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:
;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	moveq	#0,d4			; coordinata orizzontale a 0

Loop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

;	            .
;	           .¦.¦:.:¦:.:¦
;	          .;/'____  `;l
;	          ;/ /   ¬\  __\
;	          / /    ° \/o¬\\
;	         /  \______/\__//
;	        / ____       \  \
;	        \ \   \    ,  )  \
;	        /\ \   \_________/
;	       /    \   l_l_|/ /
;	      /    \ \      / /
;	   __/    _/\ \/\__/ /
;	  / ¬`----'¯¯\______/
;	 /  __      __ \
;	/   /        T  \

	move.w	d4,d5	; coordinata orizzontale attuale in d5

	and.w	#$000f,d5	; Si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A
	lsl.w	#8,d5		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d5		; della word... (8+4 = shift di 12 bit!)
	or.w	#$09f0,d5	; ...giusti per inserirsi nel registro BLTCON0
				; Qua mettiamo $f0 nei minterm per copia da
				; sorgente A a destinazione D e abilitiamo
				; ovviamente i canali A+D con $0900 (bit 8
				; per D e 11 per A). Ossia $09f0 + shift.

	addq.w	#1,d4		; Aggiungi 1 alla coordinata orizzontale per
				; andare a destra di 1 pixel la prossima volta

	move.w	#$ffff,$44(a5)		; BLTAFWM lo spieghiamo dopo
	move.w	#$ffff,$46(a5)		; BLTALWM lo spieghiamo dopo
	move.w	d5,$40(a5)		; BLTCON0 (usa A+D) - nel registro
					; abbiamo messo lo shift! (bits 12,13
					; 14 e 15, ossia nibble alto!)
	move.w	#$0000,$42(a5)		; BLTCON1 lo spieghiamo dopo
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#36,$66(a5)		; BLTDMOD (40-4=36)
	move.l	#figura,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	#bitplane,$54(a5)	; BLTDPT  (linee di schermo)
	move.w	#(64*6)+2,$58(a5)	; BLTSIZE (via al blitter !)
					; blittiamo 2 word, la seconda delle
					; quali e' nulla per permettere
					; lo shift
	btst	#6,$bfe001		; mouse premuto?
	bne.s	loop

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	rts

;****************************************************************************

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

	dc.w	$100,$1200

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; ecco il pesce... questa volta abbiamo una seconda word azzerata per ogni riga
; dimensioni: 32*6

Figura:
	dc.w	%1000001111100000,%000000000000000
	dc.w	%1100111111111000,%000000000000000
	dc.w	%1111111111101100,%000000000000000
	dc.w	%1111111111111110,%000000000000000
	dc.w	%1100111111111000,%000000000000000
	dc.w	%1000001111100000,%000000000000000

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C	

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempo spostiamo una figura verso destra di un pixel alla volta
con lo shift, utilizzando una word azzerata a destra di ogni riga per
milgiorare l'effetto rispetto a Lezione9e1.s
Poiche` non incrementiamo mai l'indirizzo destinazione, la figura si sposta
solo usando lo shifter del blitter.
In questo modo e` possibile spostarsi al massimo di 15 pixel, poiche` 15 e` il
massimo valore di shift consentito.
Dopo aver raggiunto 15, il valore di shift (che e` ottenuto prendendo i 4 bit
meno significativi della posizione della figura) ritorna al valore 0 e pertanto
la figura ritornera` alla posizione di partenza per ricominciare a muoversi.
Per fare uno scroll "serio", ogni 15 pixel di scorrimento ottenuto con lo
shift occorrerebbe far scattare l'immagine di 16 pixel aggiungendo 2 alla
destinazione, e ripartendo con lo shift a zero, eccetera, in modo analogo a
quanto visto per lo scroll con bplcon1 ($dff102) e bplpointers in copperlist.

