
; Lezione6a.s	STAMPIAMO UNA RIGA DI TESTO SULLO SCHERMO!!!

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0	; in d0 mettiamo l'indirizzo della PIC,
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

	bsr.w	print		; Stampa una riga di testo sullo schermo

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
	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	MOVEQ	#40-1,D0	; NUMERO COLONNE PER RIGA: 40 (ossia il numero
				; di caratteri presenti in una riga).
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

	ADDQ.w	#1,A3		; A3+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (40) CARATTERI PER RIGA

	RTS


		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
	dc.b	' PRIMA RIGA  Sullo Schermo! 123 prova   '

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
	dc.w	$100,%0001001000000000	; 1 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

FONT:
;	incbin	"metal.fnt"	; Carattere largo
;	incbin	"normal.fnt"	; Simile ai caratteri kickstart 1.3
	incbin	"nice.fnt"	; Carattere stretto

	SECTION	MIOPLANE,BSS_C	; Le SECTION BSS devono essere fatte di
				; soli ZERI!!! si usa il DS.b per definire
				; quanti zeri contenga la section.

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end

In una riga si possono scrivere molte cose. Per stampare 40 caratteri basta
fare un ciclo DBRA, qua chiamato PRINTCHAR2:

	MOVEQ	#40-1,D0	; NUMERO COLONNE PER RIGA: 40
PRINTCHAR2:

Essendo ogni carattere "largo" un byte, in una colonna ci possono essere 40
caratteri in LOWRES, o 80 in HIRES. Prima di rifare il ciclo per stampare
il prossimo carattere c'e' un ADD che sposta al prossimo byte, ossia alla
posizione seguente dove stampare il carattere adiacente:

	ADDQ.w	#1,A3		; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (40) CARATTERI PER RIGA

Potete scegliere tra 3 font diversi, basta togliere e mettere i ; agli incbin
per caricare quello che vi interessa.

Se volete visualizzare la linea in hires eseguite le modifiche come nella
Lezione6a.s, in piu' potete "allungare" il testo fino ad 80 caratteri, in
questo caso dovete modificare il loop PRINTCHAR in MOVEQ #80-1,d0.
Il testo lo potete anche scrivere in due linee per ogni riga:

	dc.b	' PRIMA RIGA  Sullo Schermo! 123 prova   ' 0-40
	dc.b	' sono sempre sulla prima riga hires!!   ' 41-80

	dc.b	" SECONDA RIGA!.........................."
	dc.b	"........................................"

	dc.b	" TERZA RIGA!...... eccetera.

