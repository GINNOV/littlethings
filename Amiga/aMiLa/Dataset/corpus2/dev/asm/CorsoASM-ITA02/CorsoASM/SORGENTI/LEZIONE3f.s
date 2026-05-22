
; Lezione3f.s	          BARRETTA SOTTO LA LINEA $FF

;	Questo listato e' identico al Lezione3d.s, fatta eccezione per
;	il fatto che la barretta si trova sotto la linea $FF che non
;	abbiamo mai oltrepassato.

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary, routine della EXEC che apre
				; le librerie, e da in uscita l'indirizzo
				; di base di quella libreria da cui fare le
				; distanze di indirizzamento (Offset)
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist
				; di sistema
	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.s	MuoviCopper	; Routine che sfrutta il mascheramento del WAIT

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
				; (vanno aperte e chiuse le librerie!!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts

; La routine MuoviCopper e' la stessa, sono cambiati solo i valori della
; massima altezza raggiungibile, ossia $0a e del fondo dello schermo, $2c.

MuoviCopper:
	LEA	BARRA,a0
	TST.B	SuGiu		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei subq)
	beq.w	VAIGIU
	cmpi.b	#$0a,(a0)	; siamo arrivati alla linea $0a+$ff? (265)
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
	subq.b	#1,(a0)
	subq.b	#1,8(a0)	; ora cambiamo gli altri wait: la distanza
	subq.b	#1,8*2(a0)	; tra un wait e l'altro e' di 8 bytes
	subq.b	#1,8*3(a0)
	subq.b	#1,8*4(a0)
	subq.b	#1,8*5(a0)
	subq.b	#1,8*6(a0)
	subq.b	#1,8*7(a0)	; qua dobbiamo modificare tutti i 9 wait della
	subq.b	#1,8*8(a0)	; barra rossa ogni volta per farla salire!
	subq.b	#1,8*9(a0)
	rts

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	rts			; fara' saltare alla routine VAIGIU, e
				; la barra scedera'

VAIGIU:
	cmpi.b	#$2c,8*9(a0)	; siamo arrivati alla linea $2c?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	addq.b	#1,(a0)
	addq.b	#1,8(a0)	; ora cambiamo gli altri wait: la distanza
	addq.b	#1,8*2(a0)	; tra un wait e l'altro e' di 8 bytes
	addq.b	#1,8*3(a0)
	addq.b	#1,8*4(a0)
	addq.b	#1,8*5(a0)
	addq.b	#1,8*6(a0)
	addq.b	#1,8*7(a0)	; qua dobbiamo modificare tutti i 9 wait della
	addq.b	#1,8*8(a0)	; barra rossa ogni volta per farla scendere!
	addq.b	#1,8*9(a0)
	rts

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.

;	Questo byte, indicato dalla label SuGiu, e' un FLAG, ossia una
;	bandierina (in gergo), infatti una volta e'a  $ff e un'altra e' a
;	$00, a seconda della direzione da seguire (su o giu'!). E' appunto
;	come una bandierina, che quando e' abbassata ($00) indica che dobbiamo
;	scendere e quando e' alzata ($FF) dobbiamo salire. Viene infatti
;	eseguita una comparazione della linea raggiunta per verificare se
;	siamo arrivati in cima o in fondo, e se ci siamo arrivati cambiamo
;	la direzione (con clr.b SuGiu o move.b #$ff,Sugiu)

SuGiu:
	dc.b	0,0

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - Inizio la cop col colore NERO

	dc.w	$2c07,$FFFE	; WAIT - una piccola barretta fissa verde
	dc.w	$180,$010	; COLOR0
	dc.w	$2d07,$FFFE	; WAIT
	dc.w	$180,$020	; COLOR0
	dc.w	$2e07,$FFFE
	dc.w	$180,$030
	dc.w	$2f07,$FFFE
	dc.w	$180,$040
	dc.w	$3007,$FFFE
	dc.w	$180,$030
	dc.w	$3107,$FFFE
	dc.w	$180,$020
	dc.w	$3207,$FFFE
	dc.w	$180,$010
	dc.w	$3307,$FFFE
	dc.w	$180,$000

	dc.w	$ffdf,$fffe	; ATTENZIONE! WAIT ALLA FINE LINEA $FF!
				; i wait dopo questo sono sotto la linea
				; $FF e ripartono da $00!!

	dc.w	$0107,$FFFE	; una barretta fissa verde SOTTO la linea $FF!
	dc.w	$180,$010
	dc.w	$0207,$FFFE
	dc.w	$180,$020
	dc.w	$0307,$FFFE
	dc.w	$180,$030
	dc.w	$0407,$FFFE
	dc.w	$180,$040
	dc.w	$0507,$FFFE
	dc.w	$180,$030
	dc.w	$0607,$FFFE
	dc.w	$180,$020
	dc.w	$0707,$FFFE
	dc.w	$180,$010
	dc.w	$0807,$FFFE
	dc.w	$180,$000

BARRA:
	dc.w	$0907,$FFFE	; aspetto la linea $79
	dc.w	$180,$300	; inizio la barra rossa: rosso a 3
	dc.w	$0a07,$FFFE	; linea seguente
	dc.w	$180,$600	; rosso a 6
	dc.w	$0b07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$0c07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$0d07,$FFFE
	dc.w	$180,$f00	; rosso a 15 (al massimo)
	dc.w	$0e07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$0f07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$1007,$FFFE
	dc.w	$180,$600	; rosso a 6
	dc.w	$1107,$FFFE
	dc.w	$180,$300	; rosso a 3
	dc.w	$1207,$FFFE
	dc.w	$180,$000	; colore NERO

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

MIRACOLO! Abbiamo messo delle barre colorate sotto la flamigerata linea $FF!
E basta solo mettere il comando:

	dc.w	$ffdf,$fffe

E ripartire da $0107,$fffe per waitare nella parte bassa dello screen.
Questo perche' come sapete un byte contiene solo 255 valori, ossia fino
a $FF, dunque per aspettare una linea superiore a $ff basta arrivarci
con $FFdf,$FFFE, poi la numerazione riparte da 0, fino a dove arriva lo
schermo visibile, verso il $30. da notare che lo standard televisivo americano
NTSC arriva fino alla linea $FF solamente, o poco piu' in overscan, quindi
gli americani non vedono la parte bassa dello schermo sul televisore, ma a
noi non importa, perche' l'Amiga e' diffuso soprattutto in Europa dove c'e'
lo standard PAL, infatti le demo e i giochi sono quasi sempre in PAL. In certi
casi i programmatori fanno delle versioni NTSC del gioco esclusivamente per
la distribuzione in USA.

NOTA: Per ora abbiamo potuto aspettare con il $DFF006 solo una linea compresa
da $01 a $FF; spieghero' in seguito come si fa ad aspettare col $dffxxx una
linea dopo il $FF correttamente.

