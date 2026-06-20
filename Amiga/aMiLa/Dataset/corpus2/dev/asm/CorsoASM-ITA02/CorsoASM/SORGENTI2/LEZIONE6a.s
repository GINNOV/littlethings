
; Lezione6a.s	STAMPIAMO UNA DEI CARATTERI SULLO SCHERMO!!!

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

	bsr.w	print		; Stampa una parola sullo schermo

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

TESTO:
	dc.b	'A'	; il testo da stampare. Qua solo una "A", ossia $41

	EVEN	; allinea a indirizzo pari


PRINT:
	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0),D2		; Prossimo carattere in d2
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

	RTS



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
	incbin	"nice.fnt"	; senza caratteri ALT

	SECTION	MIOPLANE,BSS_C	; Le SECTION BSS devono essere fatte di
				; soli ZERI!!! si usa il DS.b per definire
				; quanti zeri contenga la section.

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end

Una "A" e' apparsa sul nostro monitor!!! Nell'angolo in alto a sinistra.
Potete cambiare parola da stampare, ma non e' una grande modifica stampare
una "B" anziche' una "A".

* MODIFICA 1:

Provate a far stampare solo meta' carattere, ossia le sue prime 4 linee:


	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
;	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
;	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
;	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
;	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

Ogni linea e' un byte, ossia 8 BIT

	12345678

	...###.. linea	1 - 8 bit, 1 byte
	..#...#. 2
	..#...#. 3
	..#####. 4
	..#...#. 5
	..#...#. 6
	..#...#. 7
	........ 8

* MODIFICA 2:

Provate a togliere l'EVEN dalla stringa:

	dc.b	"A"

Assemblando l'ASMONE vi comunichera' l'errore: "Word at ODD address", ossia
"INDIRIZZO DISPARI!!". Bastera' rimettere lo zero a posto o aggiungere EVEN.


* MODIFICA 3:

Per cambiare la posizione della "A" basta cambiare la destinazione del PRINT:

PRINT:
	LEA	TESTO(PC),A0
	LEA	BITPLANE+(40*120),A3 ; Indirizzo destinazione

In questo modo stampiamo 120 linee piu' in basso, al centro dello schermo.
Per far avanzare il carattere basta aggiungere dei bytes:

	LEA	BITPLANE+19+(40*120),A3 ; Indirizzo destinazione

In questo modo lo facciamo avanzare di 19 bytes, e viene stampato al ventesimo
byte, la meta' dello schermo (che e' di 40 bytes).

* MODIFICA 4:

Proviamo a visualizzare il carattere in un bitplane in HIRES: Per fare cio'
eseguite queste modifiche:

Nella routine, essendo lo schermo hires largo 80 byte per linea anziche' 40:

	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,80(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,80*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,80*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,80*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,80*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,80*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,80*7(A3)	; stampa LA LINEA 8  " "

Nella copperlist: settare il BIT 15 in BPLCON0, attivando l'HIRES

		    ; 5432109876543210
	dc.w	$100,%1001001000000000	; 1 bitplane HIRES 640x256

E modificare il DDFSTART/DDFSTOP per lo schermo HIRES, pena il "TAGLIO" delle
prime linee a sinistra. Se non modificate questi due registri infatti la "A"
non viene visualizzata se e' al bordo sinistro.

	dc.w	$92,$003c	; DdfStart HIRES normale
	dc.w	$94,$00d4	; DdfStop HIRES normale

Infine nella SECTION BSS: dobbiamo ingrandire il BITPLANE!

	ds.b	80*256	; un bitplane hires 640x256

