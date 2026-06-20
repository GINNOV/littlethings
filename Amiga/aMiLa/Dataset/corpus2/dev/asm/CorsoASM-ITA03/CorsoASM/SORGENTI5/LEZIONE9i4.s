
; Lezione9i4.s	BOB con sfondo "finto"
;		Tasto sinistro per uscire.

	SECTION	bau,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


; costanti bordi.

Lowest_Floor	equ	200	; bordo in basso
Right_Side	equ	287	; bordo a destra	


START:

; puntiamo i bitplanes
	MOVE.L	#BITPLANE1,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#3-1,D1		; numero di bitplanes
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane (qua e' alto 256 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP

;	Puntiamo il quarto bitplane (lo sfondo)

	LEA	BPLPOINTERS,A0		; puntatori COP
	move.l	#SfondoFinto,d0		; indirizzo sfondo
	move.w	d0,30(a0)		; lo sfondo e` il bitplane 4
	swap	d0	
	move.w	d0,26(a0)		; scrivi word alta

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	bsr.s	MuoviOggetto		; muove il bob
	bsr.w	DisegnaOggetto		; disegna il bob


	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.w	CancellaOggetto		; cancella il bob dalla vecchia
					; posizione

	btst	#6,$bfe001		; tasto sinistro del mouse premuto?
	bne.s	mouse			; se no, torna a mouse:

	rts


;****************************************************************************
; Questa routine muove il bob controllando che non superi i bordi
;****************************************************************************

MuoviOggetto:
	move.w	ogg_x(pc),d0		; posizione X
	move.w	ogg_y(pc),d1		; posizione Y
	move.w	vel_x(pc),d2		; dx (velocita` X)
	move.w	vel_y(pc),d3		; dy (velocita` Y)
	add.w	d2,d0			; x = x + dx
	add.w	d3,d1			; y = y + dy
	addq.w	#1,d3			; aggiunge la gravita`
					; (aumenta la velocita`)
	cmp.w	#Lowest_Floor,d1	; controlla bordo in basso
	blt.s	UO_NoBounce1

	subq.w	#1,d3			; togli l'aumento di velocita`
	neg.w	d3			; cambia il segno della velocita` dy
					; invertendo la direzione del moto
	move.w	#Lowest_Floor,d1	; riparti dal bordo
UO_NoBounce1:

	cmp.w	#Right_Side,d0		; controlla bordo destro
	blt.s	UO_NoBounce2		; se supera il bordo destro..
	sub.w	#Right_Side,d0		; distanza dal bordo
	neg.w	d0			; inverti la distanza
	add.w	#Right_Side,d0		; aggiungi coordinata bordo
	neg.w	d2			; inverti direzione del moto
UO_NoBounce2:
	btst	#15,d0			; controlla bordo sinistro (X=0)
	beq.s	UO_NoBounce3		; se la X e` negativa...
	neg.w	d0			; .. fa il rimbalzo
	neg.w	d2			; inverti direzione del moto
UO_NoBounce3:
	move.w	d0,ogg_x		; aggiorna posizione e velocita`
	move.w	d1,ogg_y
	move.w	d2,vel_x
	move.w	d3,vel_y

	rts


;****************************************************************************
; Questa routine disegna il BOB alle coordinate specificate nelle variabili
; X_OGG e Y_OGG. Il BOB e lo schermo sono in formato normale (non interleaved)
; e sono utilizzate le formule relative a questo formato nel calcolo dei
; valori da scrivere nei registri del blitter. Inoltre viene impiegata la
; tecnica di mascherare l'ultima word del BOB vista nella lezione
;****************************************************************************

;	     ,-^---^-.
;	   _/  -- --  \_
;	   l_ /¯¯T¯¯\ _|
;	  (¯T \_°|°_/ T¯)
;	   ¯T _ ¯u¯ _ T¯
;	   _| l_____| |_
;	  |¬|   ¯¬¯   |¬|
;	xCz l_________| l

DisegnaOggetto:
	lea	BITPLANE1,a0	; indirizzo bitplane
	move.w	ogg_y(pc),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga occupa 40 bytes

	add.l	d0,a0		; aggiungi offset Y

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
	and.l	#$0000fffe,d1	; escludo il bit 0 del
	add.l	d1,a0		; aggiungi l'offset X, trovando l'indirizzo
				; della destinazione

	move.l	a0,IndirizzoOgg		; memorizza l'indirizzo della
					; destinazione per la routine
					; di cancellazione

	lea	Ball_Bob,a1		; puntatore alla figura
	moveq	#3-1,d7			; bitplane counter

DrawLoop:
	btst	#6,2(a5)
WBlit2:
	btst	#6,2(a5)
	bne.s	WBlit2

	move.w	d0,$40(a5)		; BLTCON0 - scrivi valore di shift
	move.w	#$0000,$42(a5)		; BLTCON1 - modo ascendente
	move.l	#$ffff0000,$44(a5)	; BLTAFWM e BLTLWM
	move.w	#$FFFE,$64(a5)		; BLTAMOD
	move.w	#40-6,$66(a5)		; BLTDMOD
	move.l	a1,$50(a5)		; BLTAPT - puntatore figura
	move.l	a0,$54(a5)		; BLTDPT - puntatore bitplanes

	move.w	#(31*64)+3,$58(a5)	; BLTSIZE - altezza 31 linee
				 	; largh. 3 word (48 pixel).

	add.l	#4*31,a1		; indirizzo prossimo plane immagine
	add.l	#40*256,a0		; indirizzo prossimo plane destinazione

	dbra	d7,DrawLoop
	rts


;****************************************************************************
; Questa routine cancella il BOB mediante il blitter. La cancellazione
; viene fatta sul rettangolo che racchiude il bob
;****************************************************************************

CancellaOggetto:
	moveq	#3-1,d7			; 3 bitplanes
	move.l	IndirizzoOgg(PC),a0	; rileggi l'indirizzo destinazione

canc_loop:
	btst	#6,2(a5)
WBlit3:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move	#$0022,$66(a5)		; BLTDMOD=40-6=34=$22
	move.l	a0,$54(a5)		; BLTDPT
	move.w	#(64*31)+3,$58(a5)	; BLTSIZE (via al blitter !)
					; cancella il rettangolo che racchiude
					; il BOB

	add.l	#40*256,a0		; indirizzo prossimo plane destinazione
	dbra	d7,canc_loop
	rts


; dati oggetto

IndirizzoOgg:
	dc.l	0	; questa variabile contiene l'indirizzo della
			; destinazione

ogg_x:	dc.w	32		; posizione X
ogg_y:	dc.w	50		; posizione Y
vel_x:	dc.w	-3		; velocita` X
vel_y:	dc.w	1		; velocita` Y

;****************************************************************************

	SECTION	MY_COPPER,CODE_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2

	dc.w	$108,0		; MODULO
	dc.w	$10a,0

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000
	dc.w $ec,$0000,$ee,$0000

	dc.w	$180,$000	; color0 - sfondo
	dc.w	$190,$000

 	dc.w	$182,$0A0			; colori da 1 a 7
 	dc.w	$184,$040
 	dc.w	$186,$050
 	dc.w	$188,$061
 	dc.w	$18A,$081
 	dc.w	$18C,$020
 	dc.w	$18E,$6F8

	dc.w	$192,$0A0			; colori da 9 a 15
	dc.w	$194,$040			; sono gli stessi valori
	dc.w	$196,$050			; caricati nei registri da 1 a 7
	dc.w	$198,$061
	dc.w	$19a,$081
	dc.w	$19c,$020
	dc.w	$19e,$6F8

	dc.w	$190,$345	; colore 8 - pixel ad 1 dello sfondo

	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

	dc.w	$8007,$fffe	; aspetta riga $80
	dc.w	$100,$4200	; bplcon0 - 4 bitplanes lowres
				; attiva il bitplane 4 (sfondo)

; in questo spazio e' visualizzata la parte dello sfondo

	dc.w	$e007,$fffe	; aspetta riga $e0
	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Figura Bob
Ball_Bob:
 DC.W $0000,$0000,$0000,$0000,$0000,$0000,$003F,$8000	; plane 1
 DC.W $00C1,$E000,$017C,$E000,$02FE,$3000,$05FF,$5400
 DC.W $07FF,$1800,$0BFE,$AC00,$03FF,$1A00,$0BFE,$AC00
 DC.W $11FF,$1A00,$197D,$2C00,$0EAA,$1A00,$1454,$DC00
 DC.W $0E81,$3800,$0154,$F400,$02EB,$F000,$015F,$D000
 DC.W $00B5,$A000,$002A,$8000,$0000,$0000,$0000,$0000
 DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
 DC.W $0000,$0000,$0000,$0000,$0000,$0000

 DC.W $000F,$E000,$007F,$FC00,$01FF,$FF00,$03FF,$FF80	; plane 2
 DC.W $07C1,$FFC0,$0F00,$FFE0,$1E00,$3FF0,$3C40,$5FF8
 DC.W $3CE0,$1FF8,$7840,$2FFC,$7800,$1FFC,$7800,$2FFC
 DC.W $F800,$1FFE,$F800,$2FFE,$FE00,$1FFE,$FC00,$DFFE
 DC.W $FE81,$3FFE,$FF54,$FFFE,$FFEB,$FFFE,$7FFF,$FFFC
 DC.W $7FFF,$FFFC,$7FFF,$FFFC,$3FFF,$FFF8,$3FFF,$FFF8
 DC.W $1FFF,$FFF0,$0FFF,$FFE0,$07FF,$FFC0,$03FF,$FF80
 DC.W $01FF,$FF00,$007F,$FC00,$000F,$E000

 DC.W $000F,$E000,$007F,$FC00,$01E0,$7F00,$0380,$0F80	; plane 3
 DC.W $073E,$0AC0,$0CFF,$0560,$198F,$C2F0,$3347,$A0B8
 DC.W $32EB,$E158,$6647,$D0AC,$660B,$E05C,$4757,$D0AC
 DC.W $C7AF,$E05E,$A7FF,$D02E,$C1FF,$E05E,$A3FF,$202E
 DC.W $D17E,$C05E,$E0AB,$002E,$D014,$005E,$6800,$00AC
 DC.W $7000,$02DC,$7400,$057C,$2800,$0AF8,$3680,$55F8
 DC.W $1D54,$AAF0,$0EAB,$55E0,$0754,$ABC0,$03EB,$FF80
 DC.W $01FE,$FF00,$007F,$FC00,$000F,$E000

;****************************************************************************

; Sfondo 320 * 100 1 Bitplane, raw normale.

SfondoFinto:
	incbin	"assembler2:sorgenti6/sfondo320*100.raw"

;****************************************************************************

	SECTION	bitplane,BSS_C
BITPLANE1:
	ds.b	40*256
BITPLANE2:
	ds.b	40*256
BITPLANE3:
	ds.b	40*256

	end

;****************************************************************************

In questo esempio vedremo un bob che si muove su uno sfondo. L'effetto e`
ottenuto pero` con un trucco che limita molto le prestazioni. Il trucco e`
il seguente: usiamo 4 bitplanes, i primi 3 per disegnare il bob e il quarto
e' per lo sfondo. Lo sfondo e il bob hanno dunque piani separati.
Per far apparire il bob sopra lo sfondo, si fa in modo che il bitplane
dello sfondo non influenzi i colori del bob. Consideriamo per esempio un
pixel del bob formato prendendo plane 1=0, plane 2=1, plane 3=1.
Questo pixel muovendosi viene a trovarsi sovrapposto a tanti bit del plane 4.
Quando si trova in corrispondenza di un bit posto a 0, i 4 planes formeranno
la combinazione plane 1=0, plane 2=1, plane 3=1, plane 4=0 che definisce il
colore 6. Quando invece si trova in corrispondenza di un bit posto a 1, si
formera` la combinazione plane 1=0, plane 2=1, plane 3=1, plane 4=1 che
definisce il colore 14. Quindi i colori del bob cambiano a seconda della
zona di sfondo che attraversano. Noi vorremmo invece che il bob apparisse
sempre uguale passando sopra lo sfondo. Possiamo simulare questo effetto
in un modo molto semplice, rendendo uguali i colori contenuti nei registri
colore che differiscono solo per i bit dello sfondo. Tornando all'esempio, se
mettiamo lo stesso valore RGB sia nel registro COLOR06 che in COLOR14, quale
che sia il valore del bit del plane 4, il nostro pixel apparira` sempre dello
stesso colore. facendo lo stesso per tutti gli altri registri (cioe` ponendo
 COLOR01 = COLOR09, COLOR02=COLOR10, COLOR03=COLOR11 ecc) risolveremo
il problema. La parte "trasparente" del bob, e` quella che ha i 3 planes a 0,
che visualizza il colore 0 o il colore 8 a seconda del valore del bit nel plane
4. Tenendo diversi questi 2 colori, e` possibile visualizzare lo sfondo:
i bit a 0 dello sfondo appariranno del colore 0, mentre quelli a 1 appariranno
del colore 8. Per capire bene cosa succende, provate un po' a mettere nei
registri COLOR01-07 valori diversi da quelli di COLOR09-15: scoprirete subito
il trucco. Questa tecnica ha lo svantaggio di "sprecare" alcuni colori.
Infatti siamo costretti a scrivere valori RGB uguali in alcuni registri,
diminuendo il numero di colori visualizzabili. In questo esempio, utiliziamo 4
bitplanes, ma possiamo usare solo 8 colori per il bob e 2 per lo sfondo.
Sprechiamo dunque 6 colori. Se usassimo 3 planes per il bob e 2 per lo sfondo,
potremmo visualizzare 8+4=12 colori, contro i 32 normalmente permessi da 5
bitplanes. Come vedete dunque anche questa tecnica non e` l'ideale.
Ma non temete, prima o poi riusciremo a fare un bob come si deve!
Nel frattempo notate un po' di cose in questo listato:
1) Utiliziamo il trucco (gia` visto) della BLTLWM a 0 per risparmiare la
colonna di word a destra del bob;
2) Utiliziamo uno schermo NON interleaved per separare i planes di sfondo e
planes del bob.
3) Negli esempi precedenti calcoliamo l'indirizzo della destinazione del bob,
sia nella routine di disegno che in quella di cancellazione. In realta` tra
il disegno e la successiva cancellazione, il bob non cambia posizione (lo fa
solo DOPO la cancellazione) quindi il calcolo e` sempre lo stesso e lo si
potrebbe fare una sola volta. In questo esempio facciamo appunto questo:
il calcolo viene fatto nella routine DisegnaOggetto e viene memorizzato
nella variabile IndirizzoOgg. La routine di cancellazione si limita a rileggere
il risultato dalla variabile e ad usarlo.

