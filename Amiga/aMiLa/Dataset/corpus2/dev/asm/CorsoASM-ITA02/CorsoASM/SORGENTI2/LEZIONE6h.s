
; Lezione6h.s	STAMPIAMO VARIE RIGHE DI TESTO * A 3 COLORI * ATTIVANDO IL
;		SECONDO BITPLANE, SU CUI SCRIVIAMO IL TESTO2.

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	 PUNTIAMO I NOSTRI BITPLANE

	MOVE.L	#BITPLANE,d0	; in d0 mettiamo l'indirizzo del bitplane1
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	MOVE.L	#BITPLANE2,d0	; in d0 mettiamo l'indirizzo del bitplane 2
	LEA	BPLPOINTERS2,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	bsr.w	print		; Stampa le linee di testo sullo schermo

	LEA	TESTO2(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE2,A3	; Indirizzo del bitplane destinazione in a3
	bsr.w	print		; Stampa le linee di testo sullo schermo

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

;	Routine che stampa caratteri larghi 8x8 pixel

PRINT:
	MOVEQ	#23-1,D3	; NUMERO RIGHE DA STAMPARE: 23
PRINTRIGA:
	MOVEQ	#40-1,D0	; NUMERO COLONNE PER RIGA: 40
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
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.w	#1,A3		; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (40) CARATTERI PER RIGA

	ADD.W	#40*7,A3	; ANDIAMO A CAPO

	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE

	RTS


		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
	dc.b	'   PRIMA RIGA (solo in testo1)          ' ; 1
	dc.b	'                                        ' ; 2
	dc.b	'     /\  /                              ' ; 3
	dc.b	'    /  \/                               ' ; 4
	dc.b	'                                        ' ; 5
	dc.b	'        SESTA RIGA (entrambi i bitplane)' ; 6
	dc.b	'                                        ' ; 7
	dc.b	'                                        ' ; 8
	dc.b	'FABIO CIUCCI               INTERNATIONAL' ; 9
	dc.b	'                                        ' ; 10
	dc.b	'   1  4 6 89  !@ $ ^& () +| =- ]{       ' ; 11
	dc.b	'                                        ' ; 12
	dc.b	'     LA  A I G N T C  OBLITERAZIONE     ' ; 15
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 16
	dc.b	'  Nel mezzo del cammin di nostra vita   ' ; 17
	dc.b	'                                        ' ; 18
	dc.b	'    Mi RitRoVaI pEr UnA sELva oScuRa    ' ; 19
	dc.b	'                                        ' ; 20
	dc.b	'    CHE LA DIRITTA VIA ERA              ' ; 21
	dc.b	'                                        ' ; 22
	dc.b	'  AHI Quanto a DIR QUAL ERA...          ' ; 23
	dc.b	'                                        ' ; 24
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 26
	dc.b	'                                        ' ; 27

	EVEN

		; numero caratteri per linea: 40
TESTO2:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
	dc.b	'                                        ' ; 1
	dc.b	'  SECONDA RIGA (solo in testo2)         ' ; 2
	dc.b	'     /\  /                              ' ; 3
	dc.b	'    /  \/                               ' ; 4
	dc.b	'                                        ' ; 5
	dc.b	'        SESTA RIGA (entrambi i bitplane)' ; 6
	dc.b	'                                        ' ; 7
	dc.b	'                                        ' ; 8
	dc.b	'FABIO        COMMUNICATION INTERNATIONAL' ; 9
	dc.b	'                                        ' ; 10
	dc.b	'   1234567 90  @#$%^&*( _+|\=-[]{}      ' ; 11
	dc.b	'                                        ' ; 12
	dc.b	'     LA PALINGENETICA  B I E A I N      ' ; 15
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 16
	dc.b	'  Nel       del cammin di        vita   ' ; 17
	dc.b	'                                        ' ; 18
	dc.b	'    Mi          pEr UnA       oScuRa    ' ; 19
	dc.b	'                                        ' ; 20
	dc.b	'    CHE LA         VIA ERA SMARRITA     ' ; 21
	dc.b	'                                        ' ; 22
	dc.b	'  AHI Quanto a     QUAL ERA...          ' ; 23
	dc.b	'                                        ' ; 24
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 26
	dc.b	'                                        ' ; 27

	EVEN



	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
		    ; 5432109876543210
	dc.w	$100,%0010001000000000	; 2 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
BPLPOINTERS2:
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE primo bitplane
	dc.w	$0184,$f62	; color2 - SCRITTE secondo bitplane
	dc.w	$0186,$1e4	; color3 - SCRITTE primo+secondo bitplane

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

FONT:
;	incbin	"metal.fnt"	; Carattere largo
;	incbin	"normal.fnt"	; Simile ai caratteri kickstart 1.3
	incbin	"nice.fnt"	; Carattere stretto

	SECTION	MIOPLANE,BSS_C	; In CHIP

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256
BITPLANE2:
	ds.b	40*256	; un bitplane lowres 320x256

	end

Per fare il testo a 3 colori (4 con lo sfondo) e' bastato attivare un altro
bitplane e stamparci il testo2, modificato in modo che manchino delle parole
per creare colori diversi nella sovrapposizione. Anche facendo "mancare" delle
parole al testo del primo bitplane si cambia il colore, infatti rimane solo il
secondo bitplane. Per stampare entrambi i testi si usa la stessa routine print,
ma c'e' una piccola modifica: le prime due istruzioni, che prelevano gli
indirizzi del testo da stampare e del bitplane destinazione sono state tolte,
in modo da rendere la routine utilizzabile per stampare qualsiasi testo
preventivamente caricato in a0 nel bitplane preventivamente caricato in a3:


	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	bsr.w	print		; Stampa le linee di testo sullo schermo

	LEA	TESTO2(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE2,A3	; Indirizzo del bitplane destinazione in a3
	bsr.w	print		; Stampa le linee di testo sullo schermo

In questo modo la routine print puo' essere utilizzata per stampare qualsiasi
testo su qualsiasi bitplane, e non sempre TESTO: in BITPLANE:!
Al primo "bsr.w print" stampa come nei listati precedenti, al secondo bsr.w
invece stampa il TESTO2: nel BITPLANE2:.
Dalla sovrapposizione dei 2 bitplane, a seconda che il carattere sia solo nel
primo bitplane, o sia solo nel secondo, o sia in entrambi, viene visualizzato
uno dei 3 colori (il quarto e' lo sfondo)

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE primo bitplane (BLU)
	dc.w	$0184,$f62	; color2 - SCRITTE secondo bitplane (ARANCIO)
	dc.w	$0186,$1e4	; color3 - SCRITTE primo+secondo bitpl. (VERDE)

Per vedere meglio la situazione dei 2 biplane provate a spostare in alto il
secondo bitplane di 5 pixel:

	MOVE.L	#BITPLANE2+(40*5),d0

