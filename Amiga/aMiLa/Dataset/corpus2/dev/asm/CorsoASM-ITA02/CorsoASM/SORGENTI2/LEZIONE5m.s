
; Lezione5m.s	SPOSTAMENTO DELLA FINESTRA VIDEO CON IL DIWSTART ($dff08e)

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	 PUNTIAMO I NOSTRI BITPLANES

	MOVE.L	#PIC,d0		; in d0 mettiamo l'indirizzo della PIC,
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP	; Rifai D1 volte POINTBP (D1=num of bitplanes)
;
	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	btst	#2,$dff016	; se il tasto destro e' premuto salta
	beq.s	Aspetta		; la routine dello scroll, bloccandolo

	bsr.w	SuGiuDIW	; scorre in alto e in basso col DIWSTART

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta!

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts			; USCITA DAL PROGRAMMA

;	Dati

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

;	Questa routine agisce semplicemente sul byte YY del $dff08e in
;	copperlist, il DIWSTART; questo registro definisce l'inizio della
;	finestra video, che puo' essere "centrata", come si puo' fare
;	dalle preferences del workBench. Nel nostro caso semplicemente
;	facciamo "cominciare" la finestra video piu' in basso, per cui
;	si sposta quello che contiene. In questo caso a differenza dello
;	scroll che abbiamo visto con i bitplanes, non viene visualizzato
;	nulla "sopra" la figura, perche' spostiamo proprio la "finestra", e
;	al di fuori di essa non vengono visualizzati i bitplane.
;	Un'aspetto interessante della routine puo' essere il fatto che viene
;	usata una word etichettata come COUNTER per aspettare 35 fotogrammi
;	prima di agire, per creare un ritardo quando il logo e' in alto
;	prima di scendere; ho usato anche due istruzioni "nuove", che non
;	avevamo ancora visto, ma che sono utilissime in questa routine; si
;	tratta del BHI, che e' un'istruzione della famiglia BEQ/BNE, che salta
;	alla routine se il risultato del CMP, ossia del COMPARA, e' che
;	il valore e' SUPERIORE, in questo caso BHI.s LOGOD fa saltare a LOGOD
;	solo quando il COUNTER ha raggiunto il valore 35, nonche' le volte
;	dopo, in cui sara' a 36,37 eccetera, comunque SUPERIORE a 35.
;	L'altra istruzione e' il BCHG, che significa BIT CHANGE, ossia
;	"scambia il bit", e' della famiglia del BTST, e "scambia" il bit
;	indicato, ossia: un BCHG #1,label agisce sul bit 1 di quella label
;	facendolo diventare 1 se era 0, 0 se era 1.

SuGiuDIW:
	ADDQ.W	#1,COUNTER	; segnamo l'esecuzione
	CMPI.W	#35,COUNTER	; sono passato almeno 35 fotogrammi?
	BHI.S	LOGOD		; se si esegui la routine
	RTS			; altrimenti torna senza eseguirla

LOGOD:
	BTST	#1,FLAGDIW	; Dobbiamo andare in alto?
	BEQ.S	UP		; Se si eseguiamo la routine "UP"
	SUBQ.B	#2,DIWSCX	; Vai in alto a passi di 2, piu' velocemente
	CMPI.B	#$2c,DIWSCX	; Siamo in cima? (valore normale $2c81)
	BEQ.S	CHANGEUPDOWN2	; se si cambiamo la direzione di scroll
	RTS

UP:
	ADDQ.B	#1,DIWSCX	; Vai in basso a passi di 1, lentamente
	CMPI.B	#$70,DIWSCX	; Siamo in fondo? (posizione $70)
	BEQ.S	CHANGEUPDOWN	; se si, cambiamo direzione di scorrimento
	RTS

CHANGEUPDOWN
	BCHG	#1,FLAGDIW	; scambiamo il bit della direzione
	RTS

CHANGEUPDOWN2
	BCHG	#1,FLAGDIW	; scambiamo il bit della direzione
	CLR.W	COUNTER		; e azzeriamo il COUNTER, siamo al termine!
	RTS

FLAGDIW:
	dc.w	0

COUNTER:
	dc.w	0


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8E
DIWSCX:
	dc.w	$2c81	; DIWSTRT = $YYXX Inizio finestra video

	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

