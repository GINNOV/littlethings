
; Lezione6i.s	TESTO A 3 COLORI CON UN COLORE LAMPEGGIANTE OTTENUTO USANDO
;		UNA TABELLA DI COLORI RGB PREFISSATI.


	SECTION	CiriCop,CODE	; NOTA: ho tolto alcuni commenti iniziali per
				; risparmiare spazio!

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.L	#BITPLANE2,d0	; dove puntare
	LEA	BPLPOINTERS2,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

	LEA	TESTO(PC),A0	; testo da stampare
	LEA	BITPLANE,A3	; destinazione
	bsr.w	print		; Stampa

	LEA	TESTO2(PC),A0	; testo da stampare
	LEA	BITPLANE2,A3	; destinazione
	bsr.w	print		; Stampa

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	btst	#2,$dff016	; tasto destro?
	beq.s	aspetta

	bsr.w	Lampeggio	; Fa lampeggiare il Color2 in copperlist

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

;	Routine di lampeggiamento che sfrutta una TABELLA di sfumature gia'
;	pronte. La TABELLA non e' altro che una serie di words contenenti
;	i vari valori RGB che il COLOR1 dovra' assumere nei vari fotogrammi.
;	Questa routine copia la word successiva nella tabella ogni volta che
;	viene eseguita, e una volta raggiunta l'ultima word della TABELLA,
;	ossia 1 word (2 bytes) prima della label FINECOLORTAB, riparte la
;	lettura della tabella dall'inizio, ad esempio:
;
;	dc.w	1,3,5,7,9,8,6,4,2,1	; la nostra "mini" tabella
;
;	Durante i vari fotogrammi le word saranno copiate, all'infinito, con
;	questo ordine:
;
;	1,3,5,7,9,8,6,4,2,1,1,3,5,7,9,8,6,4,2,1,1,3,5,7,9,8,6,4,2,1....
;
;	L'indirizzo dell'ultima word letta viene tenuto nella long COLTABPOINT

Lampeggio:
	ADDQ.L	#2,COLTABPOINT	; Fai puntare alla word successiva
	MOVE.L	COLTABPOINT(PC),A0 ; indirizzo contenuto in long COLTABPOINT
				   ; copiato in a0
	CMP.L	#FINECOLORTAB-2,A0 ; Siamo arrivati all'ultima word della TAB?
	BNE.S	NOBSTART2		; non ancora? allora continua
	MOVE.L	#COLORTAB-2,COLTABPOINT	; Riparti a puntare dalla prima word
NOBSTART2:
	MOVE.W	(A0),COLORE1	; copia la word dalla tabella al colore COP
	rts


COLTABPOINT:			; Questa longword "PUNTA" a COLORTAB, ossia
	dc.l	COLORTAB-2	; contiene l'indirizzo di COLORTAB. Terra'
				; l'indirizzo del'ultima word "letta" dentro
				; la tabella. (qua inizia da COLORTAB-2 in
				; quanto Lampeggio inizia con un ADDQ.L #2,C..
				; serve per "bilanciare" la prima istruzione.

;	La tabella con i valori "precalcolati" del lampeggiamento di color0

COLORTAB:
	dc.w	$000,$000,$001,$011,$011,$011,$012,$012	; inizio SCURO
	dc.w	$022,$022,$022,$023,$023
	dc.w	$033,$033,$034
	dc.w	$044,$044
	dc.w	$045,$055,$055
	dc.w	$056,$056,$066,$066,$066
	dc.w	$167,$167,$177,$177,$177,$177,$177
	dc.w	$278,$278,$278,$288,$288,$288,$288,$288
	dc.w	$389,$389,$399,$399,$399,$399
	dc.w	$39a,$39a,$3aa,$3aa,$3aa
	dc.w	$3ab,$3bb,$3bb,$3bb
	dc.w	$4bc,$4cc,$4cc,$4cc
	dc.w	$4cd,$4cd,$4dd,$4dd,$4dd
	dc.w	$5de,$5de,$5ee,$5ee,$5ee,$5ee
	dc.w	$6ef,$6ff,$6ff,$7ff,$7ff,$8ff,$8ff,$9ff	; ,massimo CHIARO
	dc.w	$5ee,$5ee,$5ee,$5de,$5de,$5de
	dc.w	$4dd,$4dd,$4dd,$4cd,$4cd
	dc.w	$4cc,$4cc,$4cc,$4bc
	dc.w	$3cb,$3bb,$3bb
	dc.w	$3ba,$3aa,$3aa
	dc.w	$3a9,$399,$399
	dc.w	$298,$288
	dc.w	$187,$177
	dc.w	$076,$066
	dc.w	$065,$055
	dc.w	$054,$044
	dc.w	$034
	dc.w	$022
	dc.w	$011
	dc.w	$000			; di nuovo SCURO
FINECOLORTAB:

;	Routine che stampa caratteri larghi 8x8 pixel

PRINT:
	MOVEQ	#23-1,D3	; NUMERO RIGHE DA STAMPARE: 23
PRINTRIGA:
	MOVEQ	#40-1,D0	; NUMERO COLONNE PER RIGA: 40
PRINTCHAR2:
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE
	MULU.W	#8,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...
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
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
		    ; 5432109876543210
	dc.w	$100,%0010001000000000	; 2 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane
BPLPOINTERS2:
	dc.w $e4,0,$e6,0	;secondo bitplane

	dc.w	$180,$000	; color0 - SFONDO
	dc.w	$182
COLORE1:
	dc.w	$000		; color1 - SCRITTE primo bitplane (blu)
	dc.w	$184,$f62	; color2 - SCRITTE secondo bitplane (arancio)
	dc.w	$186,$1e4	; color3 - SCRITTE primo+secondo bitpl. (verde)

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

FONT:
	incbin	"metal.fnt"
;	incbin	"normal.fnt"
;	incbin	"nice.fnt"

	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	40*256	; lowres 320x256
BITPLANE2:
	ds.b	40*256	; lowres 320x256

	end

Con l'uso di valori predeterminati, o "precalcolati" si possono ottenere
effetti di movimento o di sfumatura dei colori molto migliori che tramite
l'uso di soli ADD e SUB.
L'unica "novita'" e' la tecnica di programmazione della routine "Lampeggio" che
legge i valori da mettere nel "COLORE1" da una tabella, in cui viene usato
un PUNTATORE all'ultima word letta, ossia una LONGWORD che contiene l'indirizzo
di quella word nella tabella. Da notare che un:

COLTABPOINT:
	dc.l	COLORTAB

E' come un

COLTABPOINT:
	DC.L	0

Dopo un MOVE.L #COLORTAB,COLTABPOINT, ossia viene assemblata una longword che
contiene l'indirizzo della label in questione. In questa routine c'e' un

	dc.l	COLORTAB-2

Ma e' soltanto per far leggere la prima word la prima volta, dato che la
routine comincia con:

Lampeggio:
	ADDQ.L	#2,COLTABPOINT	; Fai puntare alla word successiva

Bisogna che COLTABPOINT contenga l'inizio della prima word-2, almeno dopo il
primo ADDQ.L #2 al primo jsr viene copiata la prima word e non la seconda.
Successivamente la longword COLTABPOINT sara' aumentata di 2 ogni volta, ossia
l'indirizzo che contiene sara' quello delle varie word, fino a che non
raggiungera' l'ultima word, che comincia 2 bytes prima della fine della
tabella:


; siamo a questo indirizzo quando leggiamo l'ultima word...
	dc.w	$0000			; di nuovo SCURO
FINECOLORTAB:

A questo punto con un:

	MOVE.L	#COLORTAB,COLTABPOINT	; Riparti a puntare dalla prima word

la label COLTABPOINT ritorna a contenere l'indirizzo della prima word.

Potete usare questa routine cambiando la tabella per moltissimi scopi, per
esempio per far saltellare o ondeggiare uno sprite.

Provate a sostituire la tabella con questa:

COLORTAB:
	dc.w	$26F,$27E,$28D,$29C,$2AB,$2BA,$2C9,$2D8,$2E7,$2F6
	dc.w	$4E7,$6D8,$8C9,$ABA,$CAA,$D9A,$E8A,$F7A,$F6B,$F5C
	dc.w	$D6D,$B6E,$96F,$76F,$56F,$36F
FINECOLORTAB:

