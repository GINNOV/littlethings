
; Lezione5d.s	SCORRIMENTO DI UNA FIGURA IN ALTO E IN BASSO MODIFICANDO I
;		PUNTATORI AI PITPLANES NELLA COPPERLIST PIU' SCORRIMENTO
;		A DESTRA E SINISTRA TRAMITE IL $dff102 (BPLCON0)

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

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP

	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti


	bsr.w	MuoviCopper	; fa scorrere la figura in alto e in basso
				; di una linea alla volta cambiando i
				; puntatori ai bitplanes in copperlist

	btst	#2,$dff016	; se il tasto destro e' premuto salta
	beq.s	Aspetta		; la routine dello scroll, bloccandolo

	bsr.w	MuoviCopper2	; fa scorrere col $dff102 la figura a destra
				; e a sinistra (massimo 15 pixel)

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


;	Questa routine sposta la figura in alto e in basso, agendo sui
;	puntatori ai bitplanes in copperlist (tramite la label BPLPOINTERS)
;	La struttura e' simile a quella di Lezione3d.s

MuoviCopper:
	LEA	BPLPOINTERS,A1	; Con queste 4 istruzioni preleviamo dalla
	move.w	2(a1),d0	; copperlist l'indirizzo dove sta puntando
	swap	d0		; attualmente il $dff0e0 e lo poniamo
	move.w	6(a1),d0	; in d0
	TST.B	SuGiu		; Dobbiamo salire o scendere?
	beq.w	VAIGIU
	cmp.l	#PIC-(40*30),d0	; siamo arrivati abbastanza in ALTO?
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
	sub.l	#40,d0		; sottraiamo 40, ossia 1 linea
	bra.s	Finito

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	bra.s	Finito		; fara' saltare alla routine VAIGIU

VAIGIU:
	cmpi.l	#PIC+(40*30),d0	; siamo arrivati abbastanza in BASSO?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	add.l	#40,d0		; Aggiungiamo 40, ossia 1 linea
	bra.s	finito

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.

Finito:				; PUNTIAMO I PUNTATORI BITPLANES
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP2:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP2	; Rifai D1 volte POINTBP (D1=num of bitplanes)
	rts

;	Questo byte, indicato dalla label SuGiu, e' un FLAG.

SuGiu:
	dc.b	0,0

;***************************************************************************
MuoviCopper2:
	TST.B	FLAG		; Dobbiamo avanzare o indietreggiare?
	beq.w	AVANTI
	cmpi.b	#$00,MIOCON1	; siamo arrivati alla posizione normale?
	beq.s	MettiAvanti	; se si, dobbiamo avanzare!
	sub.b	#$11,MIOCON1	; sottraiamo 1 allo scroll dei bitplanes
	rts

MettiAvanti:
	clr.b	FLAG		; Azzerando FLAG, al TST.B FLAG il BEQ
	rts			; fara' saltare alla routine AVANTI

AVANTI:
	cmpi.b	#$ff,MIOCON1	; siamo arrivati allo scroll massimo in
				; avanti, ossia $FF? ($f pari e $f dispari)
	beq.s	MettiIndietro	; se si, siamo dobbiamo tornare indietro
	add.b	#$11,MIOCON1	; aggiungiamo 1 allo scroll dei bitplanes
	rts

MettiIndietro:
	move.b	#$ff,FLAG	; Quando la label FLAG non e' a zero,
	rts			; significa che dobbiamo indietreggiare

;	Questo byte e' un FLAG, ossia serve per indicare se andare avanti o
;	indietro.

FLAG:
	dc.b	0,0


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

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIOCON1:
	dc.b	$00		; BplCon1 - IL BYTE UTILIZZATO!!!

	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210	; BPLCON0:
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane - BPL2PT

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

	dcb.b	40*30,0			; spazio azzerato

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	dcb.b	40*30,0			; spazio azzerato

	end

Nulla di nuovo, semplicemente sono stati uniti i sorgenti precedenti della
Lezione5.s

