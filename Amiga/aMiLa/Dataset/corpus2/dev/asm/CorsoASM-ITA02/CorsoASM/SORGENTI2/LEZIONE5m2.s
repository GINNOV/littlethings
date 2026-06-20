
; Lezione5m2.s	"CHIUSURA" DELLA FINESTRA VIDEO CON I DIWSTART/STOP ($8e/$90)

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

	bsr.w	DIWORIZZONTALE	; mostra la funzione dei DIWSTART e DIWSTOP

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

; Questa routine porta a $ff DIWXSTART incrementandolo di uno ogni volta e
; a $00 DIWXSTOP decrementandolo di uno ogni volta. Quando entrambi i valori
; sono raggiunti la routine esce senza modificare niente

DIWORIZZONTALE:
	CMPI.B	#$FF,DIWXSTART	; Siamo arrivati al massimo DIWSTART?
	BEQ.S	FINITO		; se si, non possiamo procedere oltre
	ADDQ.B	#1,DIWXSTART	; se no, allora aggiungiamo 1
FINITO:
	TST.B	DIWXSTOP	; Siamo arrivati al minimo DIWSTOP? ($00)
	BEQ.S	FINITO2		; se si non possiamo calare oltre
	SUBQ.B	#1,DIWXSTOP	; se no, allora sottraiamo1
FINITO2:
	RTS			; Uscita dalla routine


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8E		; DIWSTART - Inizio finestra video
	dc.b	$2c		; DIWSTRT $YY
DIWXSTART:
	dc.b	$81		; DIWSTRT $XX (lo incrementiamo fino a $ff)

	dc.w	$90		; DIWSTOP - Fine finestra video
	dc.b	$2c		; DiwStop YY
DIWXSTOP:
	dc.b	$c1		; DiwStop XX (lo caliamo fino a $00)
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

	dc.w	$ca07,$fffe
	dc.w	$180,$456	; nota: il colore di fondo non viene coinvolto
				; dal diwstart-diwstop

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Questo listato mostra come si possa diminuire la grandezza della finestra
video in senso orizzontale: se per esempio visualizzassimo solo delle figure
al centro dello schermo, potremmo "risparmiare" lavoro al copper, dunque
guadagnare velocita' per altri lavori, semplicemente restringendo la finestra
facendoci entrare la figura ed escludendo i "vuoti" laterali, oppure si possono
fare effetti di "chiusura" dello schermo. Avrete notato pero' che non si puo'
chiudere del tutto "lo schermo", ma rimane una linea, e che questa linea non
e' al centro dello schermo, ma spostata verso destra. Infatti il limite che
si puo; raggiungere nel "RESTRINGIMENTO" del visualizzabile e' proprio a quella
linea, infatti e' la posizione DIWSTART XX = $FF e DIWSTOP XX = $00.
Avrete notato anche che questi registri influiscono sui bitplanes, e non sul
colore di sfondo!
