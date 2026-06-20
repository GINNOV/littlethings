
; Lezione6p.s	STAMPIAMO LO SCHERMO UN CARATTERE OGNI FOTOGRAMMA

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	PrintCarattere	; Stampa un carattere alla volta

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0


;	Questa routine e' una specie di ibrido tra la routine normale del
;	PRINT e quella della TABELLA, infatti utiliziamo il TESTO in maniera
;	analoga ad una tabella, prendendone un valore solamente ogni FOTOGRAMMA
;	e stampandolo. D'altronde dobbiamo salvare anche l'indirizzo nel
;	bitplane dell'ultima posizione raggiunta nel print, per stampare il
;	carattere seguente dopo quello precedente. Per mantenere tra un frame
;	e l'altro l'indirizzo del carattere nel testo e del punto del bitplane
;	dove siamo arrivati sono usate 2 longword PUNTATORI:
;
; PuntaTesto:
;	dc.l	TESTO
;
; PuntaBitplane:
;	dc.l	BITPLANE
;
;	Ogni volta che la routine viene eseguita viene stampato un solo
;	carattere e viene aggiornato sia il puntatore del TESTO, con un
;	ADDQ.L #1 che lo sposta al carattere dopo (essendo un carattere
;	lungo un byte), sia il puntatore del BITPLANE, infatti ogni carattere
;	ha il suo posto nel bitplane.
;	Il primo problema e' che ogni 40 caratteri bisogna "ANDARE A CAPO",
;	ossia aggiungere 40*7 al puntatore del BITPLANE. Per risolvere questo
;	e' bastato aggiungere uno ZERO alla fine di ogni riga di testo e
;	delle istruzioni che controllano se il byte da stampare e' zero: se
;	si tratta dello zero allora significa che siamo alla fine della riga,
;	dunque viene aggiunto 40*7 al puntatore bitplane ed 1 a quello testo
;	per saltare lo zero e puntare al primo carattere della riga dopo.
;	Il secondo problema e' che una volta raggiunta la fine del testo
;	bisogna smettere di stampare caratteri. Per convenzione terminando
;	la riga con $FF anziche' con $00 indichiamo la fine del testo, basta
;	controllare se il byte da leggere e' $FF e uscire senza stampare e
;	senza far avanzare il puntatore PUNTATESTO, per cui ogni volta che
;	viene eseguito PRINTcarattere dopo aver stampato l'intero testo usciamo
;	senza compiere operazioni, in quanto il carattere e' sempre $FF.
;	NOTA: potete "inventare" vari numeri "speciali" da inserire nel
;	testo per varie funzioni, basta che non siano numeri compresi tra $20
;	e $80, ossia tra i byte dedicati ai caratteri.

PRINTcarattere:
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#40*7,PuntaBITPLANE	; ANDIAMO A CAPO
	ADDQ.L	#1,PuntaTesto		; primo carattere riga dopo
					; (saltiamo lo ZERO)
	move.b	(a0)+,d2		; primo carattere della riga dopo
					; (saltiamo lo ZERO)

NonFineRiga:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	MULU.W	#8,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	RTS


PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BITPLANE

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
	dc.b	'   PRIMA RIGA                           ',0 ; 1
	dc.b	'                SECONDA RIGA            ',0 ; 2
	dc.b	'     /\  /                              ',0 ; 3
	dc.b	'    /  \/                               ',0 ; 4
	dc.b	'                                        ',0 ; 5
	dc.b	'        SESTA RIGA                      ',0 ; 6
	dc.b	'                                        ',0 ; 7
	dc.b	'                                        ',0 ; 8
	dc.b	'FABIO CIUCCI COMMUNICATION INTERNATIONAL',0 ; 9
	dc.b	'                                        ',0 ; 10
	dc.b	'   1234567890 !@#$%^&*()_+|\=-[]{}      ',0 ; 11
	dc.b	'                                        ',0 ; 12
	dc.b	'     LA PALINGENETICA OBLITERAZIONE     ',0 ; 15
	dc.b	'                                        ',0 ; 16
	dc.b	'                                        ',0 ; 17
	dc.b	'  Nel mezzo del cammin di nostra vita   ',0 ; 18
	dc.b	'                                        ',0 ; 19
	dc.b	'    Mi RitRoVaI pEr UnA sELva oScuRa    ',0 ; 20
	dc.b	'                                        ',0 ; 21
	dc.b	'    CHE LA DIRITTA VIA ERA SMARRITA     ',0 ; 22
	dc.b	'                                        ',0 ; 23
	dc.b	'  AHI Quanto a DIR QUAL ERA...          ',$FF ; 24 FINE


	EVEN



	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

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
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

FONT:
	incbin	"metal.fnt"
;	incbin	"normal.fnt"
;	incbin	"nice.fnt"


	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end

