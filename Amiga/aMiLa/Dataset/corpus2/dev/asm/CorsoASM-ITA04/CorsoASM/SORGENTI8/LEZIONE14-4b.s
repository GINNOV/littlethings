
; Lezione14-4b.s	** SUONA PIU' FORME D'ONDA COMPLESSE **

	section	samplestereo,code

Start:
	move.l	4.w,a6
	jsr	-$78(A6)		; _LVODisable
	bset	#1,$bfe001		; Spegne il filtro passa-basso
	lea	$dff000,a6
	move.w	$2(a6),d7		; dmaconr - Salva DMA dell'OS

	move.l	#sample1,$a0(a6)	; AUD0LCH.w+AUD0LCL.w=AUD0LC.l
	move.l	#sample2,$b0(a6)	; AUD1LCH.w+AUD1LCL.w=AUD1LC.l
	move.w	#(sample1_end-sample1)/2,$a4(a6) ; lunghezza in word (AUD0LEN)
	move.w	#(sample2_end-sample2)/2,$b4(a6) ; lunghezza in word (AUD1LEN)

Clock	equ	3546895

	move.w	#clock/21056,$a6(a6)	; AUD0PER a 168
	move.w	#clock/21056,$b6(a6)	; AUD1PER a 168

	move.w	#64,$a8(a6)		; AUD0VOL al massimo (0 dB)
	move.w	#64,$b8(a6)		; AUD1VOL al massimo (0 dB)
	move.w	#$8003,$96(a6)		; Accende AUD0-AUD1 DMA in DMACONW
WLMB:
	btst	#6,$bfe001		; Aspetta il tasto sinistro del mouse
	bne.s	WLMB

	or.w	#$8000,d7		; accende il bit 15 (SET/CLR)
	move.w	#$0003,$96(a6)		; spegne i DMA
	move.w	d7,$96(a6)		; reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	-$7e(a6)		; _LVOEnable
	rts

******************************************************************************

	SECTION	Sample,DATA_C

; Nota: i sample sono tratti da "NASP" by Pyratronik/IBB

Sample1:
	incbin	"assembler2:sorgenti8/carrasco.21056"
Sample1_end:

Sample2:
	incbin	"assembler2:sorgenti8/lee3.21056"
Sample2_end:

	END

******************************************************************************

Abbiamo semplicemente suonato due sample diversi in stereo, due sample
che avevano la stessa frequenza di lettura ideale (ma potrebbero averla avuta
anche differente: non sarebbe cambiato nulla !) e la stessa lunghezza (cosa
molto importante, poiche' letti alla stessa frequenza hanno la medesima
durata e loopano sincronizzati).

