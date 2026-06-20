
; Lezione14-1.s			** SUONARE UN'ARMONICA **


	SECTION	armonica,CODE

Start:
	move.l	4.w,a6
	jsr	-$78(A6)		; _LVODisable

	bset	#1,$bfe001		; Spegne il filtro passa-basso

	lea	$dff000,a6
	move.w	$2(a6),d7		; dmaconr - Salva DMA dell'OS

Clock	equ	3546895

	move.l	#armonica,$a0(a6)	; AUD0LCH.w+AUD0LCL.w=AUD0LC.l
	move.w	#16/2,$a4(a6)		; 16 bytes/2=8 word di dati (AUD0LEN)
	move.w	#clock/(16*880),$a6(a6)	; AUD0PER a 251
	move.w	#64,$a8(a6)		; AUD0VOL al massimo (0 dB)
	move.w	#$8201,$96(a6)		; Accende AUD0 DMA in DMACONW

WLMB:
	btst	#6,$bfe001		; Aspetta tasto sinistro del mouse
	bne.s	WLMB

	or.w	#$8000,d7		; Accende il bit 15 (SET/CLR)
	move.w	#$0001,$96(a6)		; dmacon - Spegne aud0
	move.w	d7,$96(a6)		; dmacon - Reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	-$7e(a6)		; _LVOEnable
	rts

******************************************************************************

	SECTION	Sample,DATA_C	;venendo letta dal DMA deve essere in CHIP

	; Armonica di 16 valori creata col'IS del trash'm-one

Armonica:
	DC.B	$19,$46,$69,$7C,$7D,$6A,$47,$1A,$E8,$BB,$97,$84,$83,$95,$B8,$E5

	END

******************************************************************************

L'Armonica e' un sample di 16 byte che viene suonato sul canale 0 con periodo
di campionamento 251.
Per suonare 16 byte in 1 secondo (1 Hz), il valore di AUDPER dovrebbe essere 
di 1/16 del valore della costante di clock, poiche' il DMA dovrebbe attendere
1/16 del clock per 16 = tutto il clock = 1 secondo.
Per generare un LA3, ad esempio, (=440 Hz) bisognerebbe campionare a 880 Hz per
il teorema di Nyquist, per cui l'armonica andrebbe letta con una frequenza di
lettura di 880 Hz, ed il periodo di campionamento (=valore da inserire in
AUDPER) sarebbe di 1/880 dell' 1/16 della costante di clock:
3546895/16 = 221680 = 1 Hz, valore, oltretutto, non inseribile nel registro
poiche' e' superiore al range dei 16 bit (AUDxPER = 1 word senza segno);
(3546895/16)/880 = 3546895/(16*880) = 251 = 880 Hz.

N.B.:	i due JSR alle funzioni "Disable" ed "Enable" dell'exec potrebbero
	essere omessi, ma, per eleganza di coding, sarebbero obbligatori:
	sotto sistema operativo non sarebbe possibile toccare direttamente
	i canali DMA (nemmeno quelli audio), non tanto per il rischio che vada
	in crash il computer (l'exec non e' ingrado di controllare evetuali
	accessi ai registri hardware, visto che l'hardware non ha circuiti di
	protezione e le librerie di sistema non fanno miracoli), quanto per
	la certezza che il vostro task/processo andra' in conflitto con altri
	task/processi che stanno utilizzando le risorse audio: l'amiga ha solo
	un chip sonoro e tutti devono accedere a quello, per suonare; il
	Kernel in ROM mette a disposizione l'AUDIO.DEVICE per permettere
	a qualunque task di usufruire del chip e per arbitrarne via software
	l'accesso e l'uso tra i vari processi.
	Siccome questo corso prevede l'utilizzo dell'hardware tramite accesso
	diretto ai registri, noi non useremo le device, e, pertanto, saremo
	sempre obbligati (anche se, nel caso in cui nessuno stia accedendo
	all'hardware sonoro, non sarebbe effettivamente necessario) a spegnere
	"legalemente" (con una funzione dell'exec) il sistema operativo.

