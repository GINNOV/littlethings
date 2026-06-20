
; Lezione6d.s		HIRES E LOWRES NELLO STESSO SCHERMO

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	Puntiamo i bitplanes in copperlist

	MOVE.L	#PIC+(40*50),d0	; in d0 mettiamo l'indirizzo della PIC, in
				; questo caso puntiamo piu' avanti di 50
				; linee in modo da far "SALIRE" l'immagine.
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

;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0	; in d0 mettiamo l'indirizzo della PIC,
	LEA	BPLPOINTERS2,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

	bsr.w	print		; Stampa le linee di testo sullo schermo
				; in HIRES
mouse:
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

;	Routine che stampa caratteri larghi 8x8 pixel (su schermo HIRES)

PRINT:
	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	MOVEQ	#15-1,D3	; NUMERO RIGHE DA STAMPARE: 15
PRINTRIGA:
	MOVEQ	#80-1,D0	; NUMERO COLONNE PER RIGA: 80 (hires!)
PRINTCHAR2:
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	MULU.W	#8,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,80(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,80*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,80*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,80*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,80*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,80*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,80*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.w	#1,A3		; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (40) CARATTERI PER RIGA

	ADD.W	#80*7,A3	; ANDIAMO A CAPO

	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE

	RTS


		; numero caratteri per linea: 80, dunque 2 di queste da 40!
TESTO:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
	dc.b	'   PRIMA RIGA  IN HIRES 640 PIXEL DI LAR' ; 1a \ PRIMA RIGA
	dc.b	'GHEZZA!  -- -- --   SEMPRE LA PRIMA RIGA' ; 1b /
	dc.b	'                SECONDA RIGA            ' ; 2  \ SECONDA RIGA
	dc.b	'ANCORA SECONDA RIGA                     ' ;    /
	dc.b	'     /\  /                              ' ; 3
	dc.b	'                                        ' ;
	dc.b	'    /  \/                               ' ; 4
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 5
	dc.b	'                                        ' ;
	dc.b	'        SESTA RIGA                      ' ; 6
	dc.b	'                        FINE SESTA RIGA ' ;
	dc.b	'                                        ' ; 7
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 8
	dc.b	'                                        ' ;
	dc.b	'FABIO CIUCCI COMMUNICATION INTERNATIONAL' ; 9
	dc.b	' MARKETING TRUST TRADEMARK COPYRIGHTED  ' ;
	dc.b	'                                        ' ; 10
	dc.b	'                                        ' ;
	dc.b	'   1234567890 !@#$%^&*()_+|\=-[]{}      ' ; 11
	dc.b	'   PROVE TECNICHE DI TRASMISSIONE       ' ;
	dc.b	'                                        ' ; 12
	dc.b	'                                        ' ;
	dc.b	'     LA PALINGENETICA OBLITERAZIONE DELL' ; 13
	dc.b	"'IO TRASCENDENTALE CHE SI IMMEDESIMA    " ;
	dc.b	'                                        ' ; 14
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 15
	dc.b	'                                        ' ;
	dc.b	'  Nel mezzo del cammin di nostra vita   ' ; 16
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 17
	dc.b	'                                        ' ;
	dc.b	'    Mi RitRoVaI pEr UnA sELva oScuRa    ' ; 18
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 19
	dc.b	'                                        ' ;
	dc.b	'    CHE LA DIRITTA VIA ERA SMARRITA     ' ; 20
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 21
	dc.b	'                                        ' ;
	dc.b	'  AHI Quanto a DIR QUAL ERA...          ' ; 22
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 23
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 24
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ;
	dc.b	'                                        ' ; 26
	dc.b	'                                        ' ;

	EVEN



	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane

	dc.w	$180,$000	; color0
	dc.w	$182,$475	; color1
	dc.w	$184,$fff	; color2
	dc.w	$186,$ccc	; color3
	dc.w	$188,$999	; color4
	dc.w	$18a,$232	; color5
	dc.w	$18c,$777	; color6
	dc.w	$18e,$444	; color7

;	QUA RIDEFINIAMO BPLCON0,COLORI,DDFSTART/STOP e PUNTATORI AI BITPLANES!

	dc.w	$a007,$FFFE

	dc.w	$92,$003c	; DdfStart HIRES
	dc.w	$94,$00d4	; DdfStop HIRES
		    ; 5432109876543210
	dc.w	$100,%1001001000000000	; 1 bitplane HIRES 640x256

BPLPOINTERS2:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

FONT:
;	incbin	"metal.fnt"	; Carattere largo
;	incbin	"normal.fnt"	; Simile ai caratteri kickstart 1.3
	incbin	"nice.fnt"	; Carattere stretto

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,

	SECTION	MIOPLANE,BSS_C	; Le SECTION BSS devono essere fatte di
				; soli ZERI!!! si usa il DS.b per definire
				; quanti zeri contenga la section.

BITPLANE:
	ds.b	80*256	; un bitplane HIres 640x256

	end

Si potrebbe cambiare risoluzione grafica anche 50 volte nello stesso schermo,
basta ridefinire BPLCON0, colori e puntatori ai bitplanes.
Questo puo' essere utile quando servono, ad esempio, 32 colori nel centro dello
schermo per far camminare gli ometti di un gioco, ma ne occorrono 16 nel cielo
e magari solo 4 per il pannello col punteggio, che si puo' fare in HIRES.
Basta considerare che piu' linee in HIRES ci sono e piu' l'esecuzione
rallenta, e piu' colori ci sono meno tempo hanno gli altri coprocessori e
il 68000 per lavorare. Per questo conviene fare solo delle "strisce" di
schermo in HIRES o in HAM, per esempio, lasciando le altre parti con meno
colori e in lowres per velocizzare le operazioni.

