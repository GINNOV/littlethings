
; Corso Asm:	LEZIONE14 - ** (IN)UTILITY DI DIAL DA CLI **

; Questo sorgente va assemblato e reso eseguibile, poichè funziona come
; comando da CLI: es) > Dial 113[RETURN]
; Assemblare con 'a' e salvare con 'wo'

	SECTION	LEZIONE14-9b,CODE

main:	
	moveq	#0,d0
	move.b	(a0)+,d0		;l'OS punta a0 alla stringa ASCII
					;dei parametri dopo il comando CLI
	cmp.b	#10,d0			;loopa fino al return (ASCII=10)
	beq.b	.esci
	sub.w	#'0',d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	Numbers(pc,d0.w),d0
	bsr.s	Start
	bra.s	main
.esci:	moveq	#0,d0
	rts

	even
Numbers:

zero:		dc.l	$ee00a7		; 0
uno:		dc.l	$14100b9	; 1
due:		dc.l	$14100a7	; 2
tre:		dc.l	$1410097	; 3
quattro:	dc.l	$12200b9	; 4
cinque:		dc.l	$12200a7	; 5
sei:		dc.l	$1220097	; 6
sette:		dc.l	$10700b9	; 7
otto:		dc.l	$10700a7	; 8
nove:		dc.l	$1070097	; 9
cancelletto:	dc.l	$ee0097		; #
asterisco:	dc.l	$ee00b7		; *

; d0.l =	numero da suonare

_LVODisable	EQU	-120
_LVOEnable	EQU	-126

Start:
	move.l	4.w,a6
	jsr	_LVODisable(a6)

	lea	$dff000,a5	; Custom base per offsets

	move.l	#SMP1,$a0(a5)		; AUD0LCH - indirizzo del sample
	move.l	#SMP1,$b0(a5)		; AUD1LCH - indirizzo del sample
	move.l	#SMP1,$c0(a5)		; AUD2LCH - indirizzo del sample
	move.l	#SMP1,$d0(a5)		; AUD3LCH - indirizzo del sample
	move.w	#SMP1LEN,$A4(a5)	; AUD0LEN - lunghezza del sample
	move.w	#SMP1LEN,$B4(a5)	; AUD1LEN - lunghezza del sample
	move.w	#SMP1LEN,$C4(a5)	; AUD2LEN - lunghezza del sample
	move.w	#SMP1LEN,$D4(a5)	; AUD3LEN - lunghezza del sample
	move.w	#64,$A8(a5)		; AUD0VOL - volume massimo
	move.w	#64,$B8(a5)		; AUD1VOL - volume massimo
	move.w	#64,$C8(a5)		; AUD2VOL - volume massimo
	move.w	#64,$D8(a5)		; AUD3VOL - volume massimo
	move.w	d0,$c6(a5)		; AUD2PER - period
	move.w	d0,$d6(a5)		; AUD3PER - period
	swap	d0
	move.w	d0,$a6(a5)		; AUD0PER - period
	move.w	d0,$b6(a5)		; AUD1PER - period

	move.w	$2(a5),d7
	move.w	#$820f,$96(a5)	; MACON - abilito il canale DMA audio 0,
				; dunque il sample comincia ad essere suonato.
	MOVEQ	#12,D1		; numero di fotogrammi da aspettare
	MOVEQ	#-1,D0
WBLAN1:	CMP.B	6(A5),d0
	BNE.S	WBLAN1
WBLAN2:	CMP.B	6(A5),D0
	BEQ.S	WBLAN2
	DBRA	D1,WBLAN1

	or.w	#$8000,d7
	move.w	#$000f,$96(a5)
	move.w	d7,$96(a5)	; DMACON - chiudo il canale audio 0 (zitto!)

	MOVEQ	#4,D1		; numero di fotogrammi da aspettare
	MOVEQ	#-1,D0
WBLAN1b:CMP.B	6(A5),d0
	BNE.S	WBLAN1b
WBLAN2b:CMP.B	6(A5),D0
	BEQ.S	WBLAN2b
	DBRA	D1,WBLAN1b

	jsr	_LVOEnable(a6)
	rts

	SECTION	Tono,DATA_C

SMP1:
	dc.b $00,$31,$5a,$75,$7f,$75,$5a,$31,$00,$cf,$a6,$8b,$81,$8b,$a6,$cf
SMP1LEN	equ	(*-SMP1)>>1	; lunghezza del sample in words

	END


Adesso abbiamo toccato il fondo: ecco a voi una perfetta INUTILITY !!!
Un programmino eseguibile da CLI che serve a comporre numeri telefonici
a toni: non serve a nulla, ma, se non altro, avete imparato come il sistema
operativo passa la linea dei paramentri di un comando CLI...

