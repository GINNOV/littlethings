
; Lezione14-4a.s	** SUONA FORME D'ONDA COMPLESSE **


	section	samplemono,code

Start:
	move.l	4.w,a6
	jsr	-$78(A6)		; _LVODisable
	bset	#1,$bfe001		; Spegne il filtro passa-basso
	lea	$dff000,a6
	move.w	$2(a6),d7		; dmaconr - Salva DMA dell'OS

	move.l	#sample,$a0(a6)		; AUD0LCH.w+AUD0LCL.w=AUD0LC.l
	move.l	#sample,$b0(a6)		; AUD1LCH.w+AUD1LCL.w=AUD1LC.l
	move.w	#(sample_end-sample)/2,$a4(a6)	; lunghezza in word (AUD0LEN)
	move.w	#(sample_end-sample)/2,$b4(a6)	; lunghezza in word (AUD1LEN)

Clock	equ	3546895

	move.w	#clock/21056,$a6(a6)	; AUD0PER a 168
	move.w	#clock/21056,$b6(a6)	; AUD1PER a 168

	move.w	#64,$a8(a6)		; AUD0VOL al massimo (0 dB)
	move.w	#64,$b8(a6)		; AUD1VOL al massimo (0 dB)
	move.w	#$8003,$96(a6)		; Accende AUD0-AUD1 DMA in DMACONW


WLMB:
	btst	#6,$bfe001		;aspetta il tasto sinistro del mouse
	bne.s	WLMB

	or.w	#$8000,d7		; accende il bit 15 (SET/CLR)
	move.w	#$0003,$96(a6)		; spegne i DMA
	move.w	d7,$96(a6)		; reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	-$7e(a6)		; _LVOEnable
	rts

******************************************************************************

	SECTION	Sample,DATA_C

; Nota: il sample e' tratto da "NASP" by Pyratronik/IBB

Sample:	incbin	"assembler2:sorgenti8/carrasco.21056"
Sample_end:

	END

******************************************************************************

Per quanto riguarda questo esempio, le cose da spiegare non sono poi molte:
non ci sono novita', anzi, e' molto simile all'esempio 1, e siamo abituati
a listati ben piu' impegnativi.
Preciso solamente una cosa: la frequenza di campionamento del sample e' di
21056 Hz, pari alla frequenza originale di registrazione: e' necessario
porre una VELOCITA' DI CAMPIONAMENTO uguale a quella di digitalizzazione
se si vuole sentire il suono alla velocita' corretta...provate a cambiare
il periodo di campionamento in AUDxPER...

*** Voglio sottolineare che 21056 NON esprime il numero di volte in cui
viene letto l'intero sample, ma la frequenza di lettura di byte per byte:
vengono letto 21056 byte al secondo in un sample di lunghezza arbitraria;
all'hardware bisogna comunicare il periodo di campionamento relativo
alla velocita' di lettura.
Come abbiamo fatto per l'armonica: prima abbiamo stabilito quante volte doveva
venir letta l'INTERA onda, poi abbiamo calcolato il periodo di campionamento
moltiplicando la frequenza della nota per la lunghezza del sample in byte, per
ottenere la velocita' di lettura ***.

