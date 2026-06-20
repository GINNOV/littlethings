
; Lezione10e2.s	Cancellazione e disegno con copper monitor
;		Tasto sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#3-1,D1		; numero di bitplanes (qua sono 3)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0		; + LUNGHEZZA DI UNA PLANE !!!!!
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	move.w	#0,ogg_x
	move.w	#0,ogg_y

mouse:

	addq.w	#1,ogg_y
	cmp.w	#130,ogg_y
	beq.s	fine

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$0d000,d2	; linea da aspettare = $D0
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $D0
	BNE.S	Waity1

;	   \\\|||///
;	 .  =======
;	/ \| O   O |
;	\ / \`___'/
;	 #   _| |_
;	(#) (     )
;	 #\//|* *|\\
;	 #\/(  *  )/
;	 #   =====
;	 #   ( U )
;	 #   || ||
;	.#---'| |`----.
;	`#----' `-----'

	bsr.s	CancellaOggetto		; cancella il bob

	move	#$0b0,$180(a5)		; schermo verde scuro quando il
					; PROCESSORE ha finito la cancellazione

	bsr.s	DisegnaOggetto		; disegna il bob

	move	#$b00,$180(a5)		; schermo verde scuro quando il
					; PROCESSORE ha finito il disegno

	btst	#6,2(a5)
WBlit_coppermonitor:
	btst	#6,2(a5)	 ; attendi che il blitter abbia finito
	bne.s	wblit_coppermonitor

	move.w	#$000,$180(a5)

	bra.s	mouse

fine:
	rts


;*****************************************************************************
; Questa routine cancella il BOB mediante il blitter. La cancellazione
; viene fatta sul rettangolo che racchiude il bob
;****************************************************************************

CancellaOggetto:
	lea	bitplane,a0	; destinazione in a0
	move.w	ogg_y(pc),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga e` costituita da
				; 40 bytes
	add.w	d0,a0		; aggiungi all'indirizzo di partenza

	move.w	ogg_x(pc),d1	; coordinata X
	lsr.w	#3,d1		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d1	; escludo il bit 0 del
	add.w	d1,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	moveq	#3-1,d7		; ripeti per ogni plane
PlaneLoop2:
	btst	#6,2(a5)
WBlit3:
	btst	#6,2(a5)	 ; attendi che il blitter abbia finito
	bne.s	wblit3

	move.w	#$0f0,$180(a5)		; coppermonitor! schermo verde durante
					; la cancellazione.

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move.w	#$0004,$66(a5)		; BLTDMOD=40-36=4
	move.l	a0,$54(a5)		; BLTDPT
	move.w	#(64*45)+18,$58(a5)	; BLTSIZE (via al blitter !)
					; cancella il rettangolo che racchiude
					; il BOB

	lea	40*256(a0),a0		; punta al prossimo plane destinazione
	dbra	d7,PlaneLoop2

	rts				

;****************************************************************************
; Questa routine disegna il BOB alle coordinate specificate nelle variabili
; X_OGG e Y_OGG.
;****************************************************************************

DisegnaOggetto:
	lea	bitplane,a0	; destinazione in a0
	move.w	ogg_y(pc),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga e` costituita da
				; 40 bytes
	add.w	d0,a0		; aggiungi all'indirizzo di partenza

	move.w	ogg_x(pc),d0	; coordinata X
	move.w	d0,d1		; copia
	and.w	#$000f,d0	; si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word...
	or.w	#$09f0,d0	; ...giusti per inserirsi nel registro BLTCON0
	lsr.w	#3,d1		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d1	; escludo il bit 0 del
	add.w	d1,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	lea	figura,a1	; puntatore sorgente
	moveq	#3-1,d7		; ripeti per ogni plane
PlaneLoop:
	btst	#6,2(a5)
WBlit2:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit2

	move.w	#$f00,$180(a5)

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word


	move.w	d0,$40(a5)		; BLTCON0 (usa A+D)
	move.w	#$0000,$42(a5)		; BLTCON1 (nessun modo speciale)
	move.l	#$00000004,$64(a5)	; BLTAMOD=0
					; BLTDMOD=40-36=4 come al solito
	move.l	a1,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (linee di schermo)
	move.w	#(64*45)+18,$58(a5)	; BLTSIZE (via al blitter !)

	lea	2*18*45(a1),a1		; punta al prossimo plane sorgente
					; ogni plane e` largo 18 words e alto
					; 45 righe

	lea	40*256(a0),a0		; punta al prossimo plane destinazione
	dbra	d7,PlaneLoop

	rts

OGG_Y:		dc.w	0	; qui viene memorizzata la Y dell'oggetto
OGG_X:		dc.w	0	; qui viene memorizzata la X dell'oggetto
MOUSE_Y:	dc.b	0	; qui viene memorizzata la Y del mouse
MOUSE_X:	dc.b	0	; qui viene memorizzata la X del mouse

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; VALORE MODULO 0
	dc.w	$10a,0		; ENTRAMBI I MODULI ALLO STESSO VALORE.

	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Questi sono i dati che compongono la figura del bob.
; Il bob e` in formato normale, largo 288 pixel (18 words)
; alto 45 righe e formato da 3 bitplanes

Figura:
	incbin	copmon.raw

;****************************************************************************

	section	gnippi,bss_C

BITPLANE:
		ds.b	40*256	; 3 bitplanes
		ds.b	40*256
		ds.b	40*256

	end

;****************************************************************************

In questo esempio spostiamo un rettangolo sullo schermo, ovvero lo cancelliamo
e lo ridisegnamo. Abbiamo utilizzato una serie di colori diversi per
evidenziare la velocita` delle routine e il lavoro svolto dal blitter e dal
processore. Quando inizia la routine di cancellazione, lo schermo diventa
di colore rosso chiaro. In questo momento, sia il blitter che il processore
sono impegnati nell'operazione di cancellazione. Quando il processore termina
la routine di cancellazione, il blitter non ha ancora finito di eseguire il
suo compito. Il processore pero` e` gia` libero per altri compiti. Questa
situazione e` evidenziata colorando lo schermo di rosso piu` scuro
all'uscita della routine "CancellaOggetto". A questo punto il processore
entra nella routine "DisegnaOggetto". Poiche` il blitter e` ancora impegnato
prima che l'operazione di disegno abbia inizio e` necessario attendere il
blitter. Quando finalmente il blitter si libera lo schermo viene colorato
di verde chiaro. All'uscita della routine "DisegnaOggetto" lo schermo viene
colorato di verde scuro in attesa che il blitter finisca di disegnare.
Quando cio` accade, lo schermo ridiventa nero.

Notate inoltre che la cancellazione e la copia richiedono (circa) la stessa
velocita`.

