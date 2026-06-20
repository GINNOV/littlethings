
; Lezione7t2.s	stelle lente

;	In questo listato facciamo un cielo stellato
;	con stelle che si muovono di un pixel per volta


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop


	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo gli sprite

	MOVE.L	#SPRITE,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	MuoviStelle	; questa routine muove le stelle

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

; Questa semplice routine fa avanzare lo sprite che costituisce le stelle
; agendo su ogni HSTART (e sul byte VHBITS per lo scroll fluido di 1 pixel
; anziche' 2) tramite il loop STELLE_LOOP

MuoviStelle:
	lea	Sprite,A0		; a0 punta allo sprite
STELLE_LOOP:
	CMPI.B	#$f0,1(A0)		; la stella ha raggiunto il bordo
					; destro dello schermo ?
	BNE.S	no_bordo		; no, allora salta
	MOVE.B	#$30,1(A0)		; si, rimetti la stella a sinistra  
no_bordo:
	BCHG	#0,3(A0)		; agisci sul byte VHBITS
	BEQ.S	pari
	ADDQ.B  #$1,1(A0)		; sposta di 2 pixel lo sprite
pari:
	ADDQ.w	#8,A0			; prossima stella
	CMP.L	#SpriteEnd,A0		; abbiamo raggiunto la fine?
	BLO.S	STELLE_LOOP		; se no rifai il loop
	RTS				; fine routine


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
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
	dc.w	$100,%0001001000000000

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$000	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.
; lo sprite usa un solo colore, il 17

	dc.w	$1A2,$ddd	; color17, - COLOR1 dello sprite0 - bianco

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	-	-	-	-	-	-	-	

; Come potete notare, questo sprite e' riutilizzato un bel po' di volte, per
; la precisione 127. E' composto di tante coppie di word di controllo seguite
; da un $1000,$0000, ossia la linea di dati che compone ogni singola stella.
; Le posizioni verticali vanno di 2 in 2, per cui c'e' una stella ogni 2
; linee verticali, ad una posizione orizzontale diversa per ogni stella.
; il primo utilizzo dello sprite e' $307a,$3100,$1000,$0000
; il secondo e' $3220,$3300,$1000,$0000
; E cosi' via. I vari VSTART vanno di 2 in 2, infatti sono $30,$32,$34,$36...
; Gli HSTART sono posizionati casualmente ($7a,$20,$c0,$50...)
; I Vstop sono chiaramente 1 linea dopo lo start ($31,$33,$35..) essendo le
; stelle alte 1 pixel.
; La routine agisce ogni fotogramma su tutti gli HSTART spostando avanti le
; stelle.

Sprite:
	dc.w    $307A,$3100,$1000,$0000,$3220,$3300,$1000,$0000
	dc.w    $34C0,$3500,$1000,$0000,$3650,$3700,$1000,$0000
	dc.w    $3842,$3900,$1000,$0000,$3A6D,$3B00,$1000,$0000
	dc.w    $3CA2,$3D00,$1000,$0000,$3E9C,$3F00,$1000,$0000
	dc.w    $40DA,$4100,$1000,$0000,$4243,$4300,$1000,$0000
	dc.w    $445A,$4500,$1000,$0000,$4615,$4700,$1000,$0000
	dc.w    $4845,$4900,$1000,$0000,$4A68,$4B00,$1000,$0000
	dc.w    $4CB8,$4D00,$1000,$0000,$4EB4,$4F00,$1000,$0000
	dc.w    $5082,$5100,$1000,$0000,$5292,$5300,$1000,$0000
	dc.w    $54D0,$5500,$1000,$0000,$56D3,$5700,$1000,$0000
	dc.w    $58F0,$5900,$1000,$0000,$5A6A,$5B00,$1000,$0000
	dc.w    $5CA5,$5D00,$1000,$0000,$5E46,$5F00,$1000,$0000
	dc.w    $606A,$6100,$1000,$0000,$62A0,$6300,$1000,$0000
	dc.w    $64D7,$6500,$1000,$0000,$667C,$6700,$1000,$0000
	dc.w    $68C4,$6900,$1000,$0000,$6AC0,$6B00,$1000,$0000
	dc.w    $6C4A,$6D00,$1000,$0000,$6EDA,$6F00,$1000,$0000
	dc.w    $70D7,$7100,$1000,$0000,$7243,$7300,$1000,$0000
	dc.w    $74A2,$7500,$1000,$0000,$7699,$7700,$1000,$0000
	dc.w    $7872,$7900,$1000,$0000,$7A77,$7B00,$1000,$0000
	dc.w    $7CC2,$7D00,$1000,$0000,$7E56,$7F00,$1000,$0000
	dc.w    $805A,$8100,$1000,$0000,$82CC,$8300,$1000,$0000
	dc.w    $848F,$8500,$1000,$0000,$8688,$8700,$1000,$0000
	dc.w    $88B9,$8900,$1000,$0000,$8AAF,$8B00,$1000,$0000
	dc.w    $8C48,$8D00,$1000,$0000,$8E68,$8F00,$1000,$0000
	dc.w    $90DF,$9100,$1000,$0000,$924F,$9300,$1000,$0000
	dc.w    $9424,$9500,$1000,$0000,$96D7,$9700,$1000,$0000
	dc.w    $9859,$9900,$1000,$0000,$9A4F,$9B00,$1000,$0000
	dc.w    $9C4A,$9D00,$1000,$0000,$9E5C,$9F00,$1000,$0000
	dc.w    $A046,$A100,$1000,$0000,$A2A6,$A300,$1000,$0000
	dc.w    $A423,$A500,$1000,$0000,$A6FA,$A700,$1000,$0000
	dc.w    $A86C,$A900,$1000,$0000,$AA44,$AB00,$1000,$0000
	dc.w    $AC88,$AD00,$1000,$0000,$AE9A,$AF00,$1000,$0000
	dc.w    $B06C,$B100,$1000,$0000,$B2D4,$B300,$1000,$0000
	dc.w    $B42A,$B500,$1000,$0000,$B636,$B700,$1000,$0000
	dc.w    $B875,$B900,$1000,$0000,$BA89,$BB00,$1000,$0000
	dc.w    $BC45,$BD00,$1000,$0000,$BE24,$BF00,$1000,$0000
	dc.w    $C0A3,$C100,$1000,$0000,$C29D,$C300,$1000,$0000		
	dc.w    $C43F,$C500,$1000,$0000,$C634,$C700,$1000,$0000		
	dc.w    $C87C,$C900,$1000,$0000,$CA1D,$CB00,$1000,$0000		
	dc.w    $CC6B,$CD00,$1000,$0000,$CEAC,$CF00,$1000,$0000
	dc.w    $D0CF,$D100,$1000,$0000,$D2FF,$D300,$1000,$0000		
	dc.w    $D4A5,$D500,$1000,$0000,$D6D6,$D700,$1000,$0000		
	dc.w    $D8EF,$D900,$1000,$0000,$DAE1,$DB00,$1000,$0000		
	dc.w    $DCD9,$DD00,$1000,$0000,$DEA6,$DF00,$1000,$0000		
	dc.w    $E055,$E100,$1000,$0000,$E237,$E300,$1000,$0000		
	dc.w    $E47D,$E500,$1000,$0000,$E62E,$E700,$1000,$0000
	dc.w    $E8AF,$E900,$1000,$0000,$EA46,$EB00,$1000,$0000
	dc.w	$EC65,$ED00,$1000,$0000,$EE87,$EF00,$1000,$0000
	dc.w	$F0D4,$F100,$1000,$0000,$F2F5,$F300,$1000,$0000
	dc.w	$F4FA,$F500,$1000,$0000,$F62C,$F700,$1000,$0000
	dc.w	$F84D,$F900,$1000,$0000,$FAAC,$FB00,$1000,$0000
	dc.w	$FCB2,$FD00,$1000,$0000,$FE9A,$FF00,$1000,$0000
	dc.w	$009A,$0106,$1000,$0000,$02DF,$0306,$1000,$0000
	dc.w	$0446,$0506,$1000,$0000,$0688,$0706,$1000,$0000
	dc.w	$0899,$0906,$1000,$0000,$0ADD,$0B06,$1000,$0000
	dc.w	$0CEE,$0D06,$1000,$0000,$0EFF,$0F06,$1000,$0000
	dc.w	$10CD,$1106,$1000,$0000,$1267,$1306,$1000,$0000
	dc.w	$1443,$1506,$1000,$0000,$1664,$1706,$1000,$0000
	dc.w	$1823,$1906,$1000,$0000,$1A6D,$1B06,$1000,$0000
	dc.w	$1C4F,$1D06,$1000,$0000,$1E5F,$1F06,$1000,$0000
	dc.w	$2055,$2106,$1000,$0000,$2267,$2306,$1000,$0000
	dc.w	$2445,$2506,$1000,$0000,$2623,$2706,$1000,$0000
	dc.w	$2834,$2906,$1000,$0000,$2AF0,$2B06,$1000,$0000
	dc.w	$2CBC,$2D06,$1000,$0000
SpriteEnd
	dc.w 	$0000,$0000	; fine sprite


	SECTION	PLANEVUOTO,BSS_C
BITPLANE:
	ds.b	40*256

	end

In questo listato facciamo muovere le stelle a passi di un pixel.
Il programma e` identico all'esempio precedente, la sola cosa che cambia e`
che dobbiamo aumentare di 1 pixel invece che di 2 le posizioni orizzontali
delle stelle quando le mouviamo. Il problema e` che come sapete il bit basso
della posizione orizzontale di uno sprite e` scritto separatamente dagli
altri, quindi non possiamo spostare di 1 pixel uno sprite con una semplice
ADD. Una possibile soluzione sarebbe quella di tenere memorizzate a parte le
posizioni orizzontali in forma di word, cioe` con tutti i bit insieme,
aggiungere 1 alle word e poi scriverle nel byte HSTART e nel bit basso
mediante la stessa procedura che abbiamo usato nella routine UniMuoviSprite.
Questa soluzione ci costringerebbe pero` a memorizzare ben 127 word, una per
ogni posizione orizzontale. Nella routine abbiamo usato un metodo migliore.

	BCHG	#0,3(A0)		; agisci sul byte VHBITS
	BEQ.S	pari
	ADDQ.B  #$1,1(A0)		; sposta di 2 pixel lo sprite
pari:

vediamo passo per passo cosa succede

	BCHG	#0,3(A0)		; agisci sul byte VHBITS

questa istruzione funziona esattamente come il BSET o il BCLR, solo che
mentre BSET pone sempre a 1 il bit indicato e BCLR lo pone sempre a 0,
BCHG lo inverte: se prima era 0 lo trasforma in 1 e viceversa. In questo caso
il bit in questione e` proprio il bit basso della posizione della stella.
Inoltre BCHG PRIMA DI INVERTIRE IL BIT, controlla se esso e` a 0, esattamente
come fa il BTST. Quindi l'istruzione

	BEQ.S	pari

effettua il salto se il bit basso di HSTART ERA A 0 PRIMA DI ESEGUIRE IL BCHG.

L'istruzione seguente sposta di 2 pixel lo sprite, se la posizione era dispari

	ADDQ.B  #$1,1(A0)  ; sposta di 2 pixel lo sprite.

Queste 3 istruzioni risolvono il nostro problema. Infatti si possono
verificare 2 casi:

Se il bit basso ERA a 0, il BCHG lo porta a 1, il che equivale ad aggiungere
1 alla posizione orizzontale. Poiche` in questo caso il BEQ effettua il
salto, il byte HSTART non viene modificato. In pratica se per esempio avevamo
byte HSTART=%0110010 e bit basso = 0 (che messi insieme formavano per la
posizione orizzontale il numero %01100100=100), dopo aver eseguito la routine
ci ritroviamo con HSTART uguale e il bit basso=1, ovvero
byte HSTART=%0110010 e bit basso = 1 (che messi insieme formano per la
posizione orizzontale il numero %01100101=101).
Come volevamo abbiamo aumentato di 1 la posizione orizzontale.

Se invece il bit basso ERA a 1 la  BCHG lo porta a 0, il che equivale a
sottrarre 1 alla posizione orizzontale. In questo caso pero` il BEQ
NON effettua il salto, e pertanto viene aggiunto 1 al il byte HSTART il che
come sapete equivale ad aggiungere 2 alla posizione orizzontale. Combinando
insieme la sottrazione di 1 fatta dal BCHG con la somma di 2 fatta dalla
ADD, abbiamo aggiunto 1 alla posizione orizzontale.

In pratica se per esempio prima di eseguire la routine avevamo
byte HSTART=%0110010 e bit basso = 1 (che messi insieme formavano per la
posizione orizzontale il numero %01100101=101), dopo aver eseguito la routine
ci ritroviamo con HSTART aumentato di 1 e il bit basso=0, ovvero
byte HSTART=%0110011 e bit basso = 0 che messi insieme formano per la
posizione orizzontale il numero %01100110=102).
Come volevamo anche in questo caso abbiamo aumentato di 1 la posizione
orizzontale dello sprite.

