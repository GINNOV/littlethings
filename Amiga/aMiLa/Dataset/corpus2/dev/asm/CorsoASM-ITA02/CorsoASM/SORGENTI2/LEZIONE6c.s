
; Lezione6c.s	STAMPIAMO VARIE RIGHE DI TESTO SULLO SCHERMO!!!

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
	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
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
	dc.b	'   PRIMA RIGA                           ' ; 1
	dc.b	'                SECONDA RIGA            ' ; 2
	dc.b	'     /\  /                              ' ; 3
	dc.b	'    /  \/                               ' ; 4
	dc.b	'                                        ' ; 5
	dc.b	'        SESTA RIGA                      ' ; 6
	dc.b	'                                        ' ; 7
	dc.b	'                                        ' ; 8
	dc.b	'FABIO CIUCCI COMMUNICATION INTERNATIONAL' ; 9
	dc.b	'                                        ' ; 10
	dc.b	'   1234567890 !@#$%^&*()_+|\=-[]{}      ' ; 11
	dc.b	'                                        ' ; 12
	dc.b	'     LA PALINGENETICA OBLITERAZIONE     ' ; 15
	dc.b	'                                        ' ; 25
	dc.b	'                                        ' ; 16
	dc.b	'  Nel mezzo del cammin di nostra vita   ' ; 17
	dc.b	'                                        ' ; 18
	dc.b	'    Mi RitRoVaI pEr UnA sELva oScuRa    ' ; 19
	dc.b	'                                        ' ; 20
	dc.b	'    CHE LA DIRITTA VIA ERA SMARRITA     ' ; 21
	dc.b	'                                        ' ; 22
	dc.b	'  AHI Quanto a DIR QUAL ERA...          ' ; 23
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
	dc.w	$100,%0001001000000000	; 1 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE

	dc.w	$6c07,$fffe	; Sfumatura alla linea di testo 9
	dc.w	$182,$451	; linea1 del carattere
	dc.w	$6d07,$fffe
	dc.w	$182,$671	; linea 2
	dc.w	$6e07,$fffe
	dc.w	$182,$891	; linea 3
	dc.w	$6f07,$fffe
	dc.w	$182,$ab1	; linea 4
	dc.w	$7007,$fffe
	dc.w	$182,$781	; linea 5
	dc.w	$7107,$fffe
	dc.w	$182,$561	; linea 6
	dc.w	$7207,$fffe
	dc.w	$182,$451	; linea 7  l'ultima perche' la 8 e' azzerata
				;	   per fare spaziatura tra le linee

	dc.w	$7307,$fffe
	dc.w	$182,$19a	; colore normale

	dc.w	$8c07,$fffe	; Sfumatura alla linea di testo 11
	dc.w	$182,$516	; linea1 del carattere
	dc.w	$8d07,$fffe
	dc.w	$182,$739	; linea 2
	dc.w	$8e07,$fffe
	dc.w	$182,$95b	; linea 3
	dc.w	$8f07,$fffe
	dc.w	$182,$c6f	; linea 4
	dc.w	$9007,$fffe
	dc.w	$182,$84a	; linea 5
	dc.w	$9107,$fffe
	dc.w	$182,$739	; linea 6
	dc.w	$9207,$fffe
	dc.w	$182,$517	; linea 7  l'ultima perche' la 8 e' azzerata


	dc.w	$9307,$fffe
	dc.w	$182,$19a	; colore normale

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

FONT:
	incbin	"metal.fnt"	; Carattere largo
;	incbin	"normal.fnt"	; Simile ai caratteri kickstart 1.3
;	incbin	"nice.fnt"	; Carattere stretto

	SECTION	MIOPLANE,BSS_C	; Le SECTION BSS devono essere fatte di
				; soli ZERI!!! si usa il DS.b per definire
				; quanti zeri contenga la section.

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end


Come avrete visto, il fatto che il font sia ad un solo colore non vieta di
cambiare il colore ogni linea con i WAIT del copper!
Per scrivere molte righe l'una sotto l'altra e' bastato "ANDARE A CAPO" e
stampare la linea seguente, per un numero di volte specificato in D3

	ADD.W	#40*7,A3	; ANDIAMO A CAPO
	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE

NOTA: per andare a capo serve scendere di 7 linee. Per RIGA intendo RIGA DI
TESTO, alta 8 pixel, per linea intendo LINEA VIDEO effettiva.

Ecco perche' per andare a capo serve un "ADD.W #40*7,A3" :

Il problema puo' nascere dall'impressione di trovarsi gia' con l'indirizzo in
a3 all'ultima linea del carattere appena stampata, per cui verrebbe da pensare
che basti scattare avanti di 1 per trovarsi alla riga di testo successiva, ma
in realta' in A3 c'e' sempre e solo l'indirizzo della prima linea dei caratteri
infatti le atre 7 linee sono stampate tramite OFFSET:

	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

Ma il registro A3 punta sempre alla prima linea. Infatti ogni volta che viene
stampato un carattere, si avanza al carattere successivo aggiungendo 8 bit,
ossia 1 byte, all'indirizzo in A3, il quale poi puntera' alla prima linea del
carattere successivo:

	ADDQ.w	#1,A3		; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

A questo punto per stampare quel "carattere successivo" bastera' rieseguire la
routine con le distanze di indirizzamento (OFFSET).
Vediamo cosa succede quando ci troviamo ad aver stampato l'ultimo carattere a
destra, ossia l'ultimo di una riga: in A3 abbiamo l'indirizzo della prima linea
dell'ultimo carattere in questione, dopo le istruzioni che stampano facendo
l'offset da A3, c'e' l'istruzione che fa scattare A3 agli 8 bit successivi, in
questo caso fa scattare all'inizio della seconda linea. E' per questo che per
portare A3 alla prima linea della riga successiva basta scendere di 7 linee e
non di 8, perche' ci trovavamo gia' all'inizio della seconda linea.


