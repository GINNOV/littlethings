
; Lezione11m2.s - Utilizzo dell'interrupt di livello 2 ($68) per leggere i
;		  codici dei tasti premuti sulla tastiera.
;		  In questo caso decodifichiamo anche il tasto letto
;		  trasformandolo nel carattere ASCII corrispondente.

	Section	InterruptKey,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper,bitplane e DMA abilitato

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;	Puntiamo i bitplanes in copperlist

	MOVE.L	#BITPLANE,d0	; in d0 mettiamo l'indirizzo del bitplane
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	move.l	BaseVBR(PC),a0	     ; In a0 il valore del VBR

	MOVE.L	#MioInt68KeyB,$68(A0)	; Routine per la tastiera int. liv. 2
	move.l	#MioInt6c,$6c(a0)	; metto la mia rout. int. livello 3

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	movem.l	d0-d7/a0-a6,-(SP)
	bsr.w	mt_init		; inizializza la routine musicale
	movem.l	(SP)+,d0-d7/a0-a6

		; 5432109876543210
	move.w	#%1100000000101000,$9a(a5)    ; INTENA - abilito solo VERTB
					      ; del livello 3 e il livello2
Mouse:
	btst	#6,$bfe001
	bne.s	mouse

	bsr.w	mt_end		   ; fine del replay!
	rts			   ; esci

	even

*****************************************************************************
*	ROUTINE IN INTERRUPT $68 (livello 2) - gestione TASTIERA
*****************************************************************************

;03	PORTS	2 ($68)	Input/Output Porte e timers, connesso alla linea INT2

MioInt68KeyB:	; $68
	movem.l d0/a0,-(sp)	; salva i registri usati nello stack
	lea	$dff000,a0	; reg. custom per offset

	MOVE.B	$BFED01,D0	; Ciaa icr - in d0 (leggendo l'icr causiamo
				; anche il suo azzeramento, per cui l'int e'
				; "disdetto" come in intreq).
	BTST.l	#7,D0	; bit IR, (interrupt cia autorizzato), azzerato?
	BEQ.s	NonKey	; se si, esci
	BTST.l	#3,D0	; bit SP, (interrupt della tastiera), azzerato?
	BEQ.s	NonKey	; se si, esci

	MOVE.W	$1C(A0),D0	; INTENAR in d0
	BTST.l	#14,D0		; Bit Master di abilitazione azzerato?
	BEQ.s	NonKey		; Se si, interrupt non attivi!
	AND.W	$1E(A0),D0	; INREQR - in d1 rimangono settati solo i bit
				; che sono settati sia in INTENA che in INTREQ
				; in modo da essere sicuri che l'interrupt
				; avvenuto fosse abilitato.
	btst.l	#3,d0		; INTREQR - PORTS?
	beq.w	NonKey		; Se no, allora esci!

; Dopo i controlli, se siamo qua significa che dobbiamo prendere il carattere!

	moveq	#0,d0
	move.b	$bfec01,d0	; CIAA sdr (serial data register - connesso
				; alla tastiera - contiene il byte inviato dal
				; chip della tastiera) LEGGIAMO IL CHAR!

	bsr.s	convertichar	; Converti in ASCII il carattere

; Ora dobbiamo comunicare alla tastiera che abbiamo preso il dato!

	bset.b	#6,$bfee01	; CIAA cra - sp ($bfec01) output, in modo da
				; abbassare la linea KDAT per confermare che
				; abbiamo ricevuto il carattere.

	st.b	$bfec01		; $FF in $bfec01 - ue'! ho ricevuto il dato!

; Qua dobbiamo mettere una routine che aspetti 90 microsecondi perche' la
; linea KDAT deve stare bassa abbastanza tempo per essere "capita" da tutti
; i tipi di tastiere. Si possono, per esempio, aspettare 3 o 4 linee raster.

	moveq	#4-1,d0	; Numero di linee da aspettare = 4 (in pratica 3 piu'
			; la frazione in cui siamo nel momento di inizio)
waitlines:
	move.b	6(a0),d1	; $dff006 - linea verticale attuale in d1
stepline:
	cmp.b	6(a0),d1	; siamo sempre alla stessa linea?
	beq.s	stepline	; se si aspetta
	dbra	d0,waitlines	; linea "aspettata", aspetta d0-1 linee

; Ora che abbiamo atteso, possiamo riportare $bfec01 in modo input...

	bclr.b	#6,$bfee01	; CIAA cra - sp (bfec01) input nuovamente.

NonKey:		; 3210
	move.w	#%1000,$9c(a0)	; INTREQ togli richiesta, int eseguito!
	movem.l (sp)+,d0/a0	; ripristina i registri dallo stack
	rte

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (livello 3) - usato il VERTB e COPER.	    *
*****************************************************************************

;06	BLIT	3 ($6c)	Se il blitter ha finito una blittata si setta ad 1
;05	VERTB	3 ($6c)	Generato ogni volta che il pennello elettronico e'
;			alla linea 00, ossia ad ogni inizio di vertical blank.
;04	COPER	3 ($6c)	Si puo' settare col copper per generarlo ad una certa
;			linea video. Basta richiederlo dopo un certo WAIT.

MioInt6c:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.s	NointVERTB		; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.s	PrintaChar		; Stampa il carattere
	bsr.w	mt_music		; suono la musica
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack
nointVERTB:
NointCOPER:
NoBLIT:		 ;6543210
	move.w	#%1110000,$dff09c ; INTREQ - cancello rich. BLIT,VERTB e COPER
	rte	; uscita dall'int COPER/BLIT/VERTB


*****************************************************************************
; SubRoutine che converte il carattere in ASCII
*****************************************************************************

ConvertiChar:
	movem.l	d1-d2/a0,-(SP)

; data received bit : 6 5 4 3 2 1 0 7
; il bit 7 e' 1 se il tasto e' rilasciato

	not.b	d0			;e' trasmesso nottatto
	lsr.b	#1,d0			;e ruotato a sx
	bcs.b	Tasto_up

	cmp.b	#$60,d0			;left shift
	blo.b	To_Ascii
	bset	d0,Control_Key
	bra.b	exit

Tasto_up:
	cmp.b	#$60,d0			;left shift
	blo.b	exit
	bclr	d0,Control_Key
	bra.b	exit

;	bit	7 6     5 4     3    2     1 0
;              Amiga    Alt   Ctrl  caps  shift
;               r l     r l         lock   r l

to_ascii:
	move.b	Control_Key(PC),d1
	beq.b	Get_Char
	move.b	d1,d2
	and.b	#%00000111,d1
	beq.b	tst_alt
	add.w	#$68,d0
	bra.b	Get_Char
tst_alt:
	and.b	#%00110000,d2
;	beq	....
	add.w	#$68*2,d0
Get_Char:
	lea	Raw_2_Ascii(pc),a0
	move.b	(a0,d0.w),d0
	move.b	d0,ascii_char
	clr.b	received	; il dato e' pronto!
exit:
	movem.l	(SP)+,d1-d2/a0
	rts

*****************************************************************************

PrintaChar:
	tst.b	received	; Dato ricevuto?
	bne.s	NonPremuto
	st.b	received
	moveq	#0,d0
	move.b	ascii_char(pc),d0
	cmp.b	#-1,d0
	beq.b	NonValido  ; era un carattere speciale tipo help tab ecc.
	bsr.s	PrintaD0   ; altrimenti stampa il char sullo schermo
NonValido:
NonPremuto:
	rts

Control_Key:	dc.b	0
ascii_char:	dc.b	0
received: 	dc.b	-1
contariga:	dc.b	0

	even

*****************************************************************************
; Routine di Print del carattere in d0
*****************************************************************************

PRINTAd0:
	movem.l	a2-a3,-(SP)

	SUB.B	#$20,D0		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	LSL.W	#3,D0		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D0,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	cmp.b	#80,ContaRiga	; 80 caratteri stampati?
	bne.s	NonFine
	add.l	#80*7,PuntaBitplane	; Vai a Capo
	clr.b	ContaRiga
NonFine:
	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,80(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,80*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,80*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,80*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,80*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,80*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,80*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.B	#1,ContaRiga

	movem.l	(SP)+,a2-a3
	RTS

PuntaBitplane:
	dc.l	BITPLANE


; Tabella di conversione in ascii. Facilmente modificabile per tastiera
; italiana o altre.

raw_2_ascii:
	dc.b	'`'
	dc.b	'1'
	dc.b	'2'
	dc.b	'3'
	dc.b	'4'
	dc.b	'5'
	dc.b	'6'
	dc.b	'7'
	dc.b	'8'
	dc.b	'9'
	dc.b	'0'
	dc.b	'-'
	dc.b	'='
	dc.b	'\'
	dc.b	-1	;<<<<<<<<<<<<<<
	dc.b	'0'	;tastierino numerico
	dc.b	'q'
	dc.b	'w'
	dc.b	'e'
	dc.b	'r'
	dc.b	't'
	dc.b	'y'
	dc.b	'u'
	dc.b	'i'
	dc.b	'o'
	dc.b	'p'
	dc.b	'['
	dc.b	']'
	dc.b	-1	;<<<<<<<<<<<<<<<<<
	dc.b	'1'
	dc.b	'2'
	dc.b	'3'
	dc.b	'a'
	dc.b	's'
	dc.b	'd'
	dc.b	'f'
	dc.b	'g'
	dc.b	'h'
	dc.b	'j'
	dc.b	'k'
	dc.b	'l'
	dc.b	';'
	dc.b    39
	dc.b	-1	;not used
	dc.b	-1	;<<<<<<<<<<<<<<<<<<<<
	dc.b	'4'
	dc.b	'5'
	dc.b	'6'
	dc.b	'<'
	dc.b	'z'
	dc.b	'x'
	dc.b	'c'
	dc.b	'v'
	dc.b	'b'
	dc.b	'n'
	dc.b	'm'
	dc.b	','
	dc.b	'.'
	dc.b	'/'
	dc.b	-1	;<<<<<<<<<<<<<<<<<<
	dc.b	'.'
	dc.b	'7'
	dc.b	'8'
	dc.b	'9'
	dc.b	' '	;space
	dc.b	-1	;back space
	dc.b	-1	;tab
	dc.b	-1	;return	tastierino
	dc.b	-1	;return
	dc.b	-1	;esc
	dc.b	-1	;del
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;<<<<<<<<<
	dc.b	'-'
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;up
	dc.b	-1	;down
	dc.b	-1	;dx
	dc.b	-1	;sx
	dc.b	-1	;f1
	dc.b	-1	;f2
	dc.b	-1	;f3
	dc.b	-1	;f4
	dc.b	-1	;f5
	dc.b	-1	;f6
	dc.b	-1	;f7
	dc.b	-1	;f8
	dc.b	-1	;f9
	dc.b	-1	;f10
	dc.b	'('
	dc.b	')'
	dc.b	'/'
	dc.b	'*'
	dc.b	'+'
	dc.b	-1	;help
	dc.b	-1	;lshift
	dc.b	-1	;rshift
	dc.b	-1	;caps lock
	dc.b	-1	;ctrl
	dc.b	-1	;lalt
	dc.b	-1	;ralt
	dc.b	-1	;lamiga
	dc.b	-1	;ramiga

	dc.b	'~'	;shift-tati
	dc.b	'!'
	dc.b	'@'
	dc.b	'#'
	dc.b	'$'
	dc.b	'%'
	dc.b	'^'
	dc.b	'&'
	dc.b	'*'
	dc.b	'('
	dc.b	')'
	dc.b	'_'
	dc.b	'+'
	dc.b	'|'
	dc.b	-1	;<<<<<<<<<<<<<<
	dc.b	'0'	;tastierino numerico
	dc.b	'Q'
	dc.b	'W'
	dc.b	'E'
	dc.b	'R'
	dc.b	'T'
	dc.b	'Y'
	dc.b	'U'
	dc.b	'I'
	dc.b	'O'
	dc.b	'P'
	dc.b	'{'
	dc.b	'}'
	dc.b	-1	;<<<<<<<<<<<<<<<<<
	dc.b	'1'	;tastierino
	dc.b	'2'	;tastierino
	dc.b	'3'	;tastierino
	dc.b	'A'
	dc.b	'S'
	dc.b	'D'
	dc.b	'F'
	dc.b	'G'
	dc.b	'H'
	dc.b	'J'
	dc.b	'K'
	dc.b	'L'
	dc.b	':'
	dc.b    '"'
	dc.b	-1	;not used
	dc.b	-1	;<<<<<<<<<<<<<<<<<<<<
	dc.b	'4'	;tastierino
	dc.b	'5'	;tastierino
	dc.b	'6'	;tastierino
	dc.b	'>'
	dc.b	'Z'
	dc.b	'X'
	dc.b	'C'
	dc.b	'V'
	dc.b	'B'
	dc.b	'N'
	dc.b	'M'
	dc.b	'<'
	dc.b	'>'
	dc.b	'?'
	dc.b	-1	;<<<<<<<<<<<<<<<<<<
	dc.b	'.'	;tastierino
	dc.b	'7'	;tastierino
	dc.b	'8'	;tastierino
	dc.b	'9'	;tastierino
	dc.b	' '	;space
	dc.b	-1	;back space
	dc.b	-1	;tab
	dc.b	-1	;return tastierino
	dc.b	-1	;return
	dc.b	-1	;esc
	dc.b	-1	;del
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;<<<<<<<<<
	dc.b	'-'
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;up
	dc.b	-1	;down
	dc.b	-1	;dx
	dc.b	-1	;sx
	dc.b	-1	;f1
	dc.b	-1	;f2
	dc.b	-1	;f3
	dc.b	-1	;f4
	dc.b	-1	;f5
	dc.b	-1	;f6
	dc.b	-1	;f7
	dc.b	-1	;f8
	dc.b	-1	;f9
	dc.b	-1	;f10
	dc.b	'('
	dc.b	')'
	dc.b	'/'
	dc.b	'*'
	dc.b	'+'
	dc.b	-1	;help
	dc.b	-1	;lshift
	dc.b	-1	;rshift
	dc.b	-1	;caps lock
	dc.b	-1	;ctrl
	dc.b	-1	;lalt
	dc.b	-1	;ralt
	dc.b	-1	;lamiga
	dc.b	-1	;ramiga

	dc.b	'`'	;alt-tati
	dc.b	'¹'
	dc.b	'²'
	dc.b	'³'
	dc.b	'¢'
	dc.b	'¼'
	dc.b	'½'
	dc.b	'¾'
	dc.b	'·'
	dc.b	'«'
	dc.b	'»'
	dc.b	'-'
	dc.b	'='
	dc.b	'\'
	dc.b	-1	;<<<<<<<<<<<<<<
	dc.b	'0'	;tastierino numerico
	dc.b	'å'
	dc.b	'°'
	dc.b	'©'
	dc.b	'®'
	dc.b	'þ'
	dc.b	'¤'
	dc.b	'µ'
	dc.b	'¡'
	dc.b	'ø'
	dc.b	'¶'
	dc.b	'['
	dc.b	']'
	dc.b	-1	;<<<<<<<<<<<<<<<<<
	dc.b	'1'	;tastierino
	dc.b	'2'	;tastierino
	dc.b	'3'	;tastierino
	dc.b	'æ'
	dc.b	'ß'
	dc.b	'ð'
	dc.b	''
	dc.b	''
	dc.b	''
	dc.b	''
	dc.b	''
	dc.b	'£'
	dc.b	';'
	dc.b    39
	dc.b	'ù'	;not used
	dc.b	-1	;<<<<<<<<<<<<<<<<<<<<
	dc.b	'4'	;tastierino
	dc.b	'5'	;tastierino
	dc.b	'6'	;tastierino
	dc.b	'<'
	dc.b	'±'
	dc.b	'×'
	dc.b	'ç'
	dc.b	'ª'
	dc.b	'º'
	dc.b	'­'
	dc.b	'¸'
	dc.b	','
	dc.b	'.'
	dc.b	'/'
	dc.b	-1	;<<<<<<<<<<<<<<<<<<
	dc.b	'.'	;tastierino
	dc.b	'7'	;tastierino
	dc.b	'8'	;tastierino
	dc.b	'9'	;tastierino
	dc.b	' '	;space
	dc.b	-1	;back space
	dc.b	-1	;tab
	dc.b	-1	;return	tastierino
	dc.b	-1	;return
	dc.b	'›'	;esc
	dc.b	-1	;del
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;<<<<<<<<<
	dc.b	'-'
	dc.b	-1	;<<<<<<<<<
	dc.b	-1	;up
	dc.b	-1	;down
	dc.b	-1	;dx
	dc.b	-1	;sx
	dc.b	-1	;f1
	dc.b	-1	;f2
	dc.b	-1	;f3
	dc.b	-1	;f4
	dc.b	-1	;f5
	dc.b	-1	;f6
	dc.b	-1	;f7
	dc.b	-1	;f8
	dc.b	-1	;f9
	dc.b	-1	;f10
	dc.b	'['
	dc.b	']'
	dc.b	'/'
	dc.b	'*'
	dc.b	'+'
	dc.b	-1	;help
	dc.b	-1	;lshift
	dc.b	-1	;rshift
	dc.b	-1	;caps lock
	dc.b	-1	;ctrl
	dc.b	-1	;lalt
	dc.b	-1	;ralt
	dc.b	-1	;lamiga
	dc.b	-1	;ramiga

	even

;	Il FONT caratteri 8x8.

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

*****************************************************************************
;	Routine di replay del protracker/soundtracker/noisetracker
;
	include	"assembler2:sorgenti4/music.s"
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$003c	; DdfStart HIRES
	dc.w	$94,$00d4	; DdfStop HIRES
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod \ INTERLACE: modulo = lungh. linea!
	dc.w	$10a,0		; Bpl2Mod / per saltarle (le pari o le disp.)

		    ; 5432109876543210
	dc.w	$100,%1001001000000000	; 1 bitplane, HIRES 640x256

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$180,$226	; color0 - SFONDO
	dc.w	$182,$0c0	; color1 - plane 1 posizione normale, e'
				; la parte che "sporge" in alto.

	dc.w	$FFFF,$FFFE	; Fine della copperlist

*****************************************************************************
;				MUSICA
*****************************************************************************

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"assembler2:sorgenti4/mod.fairlight"

;********************************************************************
;	Il bitplane
;********************************************************************
	section	bitplane,bss_C

BITPLANE:
	ds.b	80*320

	end

Potreste farvi una utility, oppure un programma che richiede l'immissione
del nome o di altri dati, o uno che vi risponde a tono, come fosse una
persona... fate voi!

