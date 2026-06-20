
; Lezione11e.s - Utilizzo di interrupts COPER e VERTB dell livello 3 ($6c).
;		 In questo caso ridefiniamo tutti gli interrupt, giusto
;		 per rendere l'idea di come si fa.

	Section	Interrupt,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA abilitato

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	move.l	BaseVBR(PC),a0	     ; In a0 il valore del VBR

	MOVE.L	#NOINT1,$64(A0)		; Interrupt "vuoto"
	MOVE.L	#NOINT2,$68(A0)		; int vuoto
	move.l	#MioInt6c,$6c(a0)	; metto la mia rout. int. livello 3.
	MOVE.L	#NOINT4,$70(A0)		; int vuoto
	MOVE.L	#NOINT5,$74(A0)		; " "
	MOVE.L	#NOINT6,$78(A0)		; " "

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
	move.w	#%1111111111111111,$9a(a5)    ; INTENA - abilito TUTTI gli
					      ; interrupt!

mouse:
	btst	#6,$bfe001	; Mouse premuto? (il processore esegue questo
	bne.s	mouse		; loop in modo utente, e ogni vertical blank
				; nonche' ogni WAIT della linea raster $a0
				; lo interrompe per suonare la musica!).

	bsr.w	mt_end		; fine del replay!

	rts			; esci


*****************************************************************************
*	ROUTINE IN INTERRUPT $64 (livello 1)
*****************************************************************************

;	.:·.·...·..
;	 ·::::::::::.
;	  ·::::::::::
;	  ( _____·:::
;	   \____` ::|
;	   _(° _)  ·l
;	  / ¯¯¯     .)
;	 /         ¯T
;	/  ,_  ___ _j
;	¯¯¬ l____\  \
;	        ¬\\  \ xCz
;	__________)   \
;	\_      _____  \
;	 `------'   \___)

;02	SOFT	1 ($64)	Riservato agli interrupt inizializzati via software.
;01	DSKBLK	1 ($64)	Fine del trasferimento di un blocco dati dal disco.
;00	TBE	1 ($64)	Buffer UART di trasmissione della porta seriale VUOTO.

NOINT1:	; $64
	btst.b	#0,$dff01f	; INTREQR - TBE?
	beq.w	NoTBE
	; tbe routines
NoTBE:
	btst.b	#1,$dff01f	; INTREQR - DSKBLK?
	beq.w	NoDSKBLK
	; DSKBLK routines
NoDSKBLK:
	btst.b	#2,$dff01f	; INTREQR - SOFT?
	beq.w	NoSOFT
	; SOFT routines
NoSOFT:
		; 210
	move.w	#%111,$dff09c	; INTREQ - soft,dskblk,serial port tbe
	rte

*****************************************************************************
*	ROUTINE IN INTERRUPT $68 (livello 2)
*****************************************************************************

;	    .:::::::::.
;	   ¦:·       ·:¦
;	   |'         `|
;	   |    ,      |
;	   |  ¯¯   `-- |
;	  _!   __  __  |
;	 (C \ ( °)(o ) |
;	  7 /\ ¯(__)¯ _!
;	 / /  \______/\\
;	/  \_______l__//
;	\   \:::::::::\\ xCz
;	 \   \:::::::::\\
;	  \___¯¯¯¯¯¯¯¯¯¯/
;	     `---------'

;03	PORTS	2 ($68)	Input/Output Porte e timers, connesso alla linea INT2

NOINT2:	; $68
	btst.b	#3,$dff01f	; INTREQR - PORTS?
	beq.w	NoPORTS
	; routines PORTS
NoPORTS:
	move.l	d0,-(sp)	; salva d0
	move.b	$bfed01,d0	; CIAA icr - e' un interrupt della tastiera?
	and.b	#$8,d0
	beq.w	NoTastiera
	; Routines per la lettura della tastiera
NoTastiera:
	move.l	(sp)+,d0	; ripristina d0
		; 3210
	move.w	#%1000,$dff09c	; INTREQ - ports
	rte

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (livello 3) - usato il VERTB e COPER.	    *
*****************************************************************************
;	    __________________
;	 __/  _______________/
;	( .      ¬(___©)\©_T
;	 \_,             \ |
;	  T            C. )|
;	  l____________  _ |
;	       T      l__¬_!
;	       |   (_) T`-'
;	       l__     ¦ xCz
;	         `-----'

;06	BLIT	3 ($6c)	Se il blitter ha finito una blittata si setta ad 1
;05	VERTB	3 ($6c)	Generato ogni volta che il pennello elettronico e'
;			alla linea 00, ossia ad ogni inizio di vertical blank.
;04	COPER	3 ($6c)	Si puo' settare col copper per generarlo ad una certa
;			linea video. Basta richiederlo dopo un certo WAIT.

MioInt6c:
	btst.b	#6,$dff01f	; INTREQR - BLIT?
	beq.w	NoBLIT
	; routines BLIT
NoBLIT:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.s	NointVERTB		; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.w	mt_music		; suono la musica
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack
nointVERTB:
	btst.b	#4,$dff01f	; INTREQR - COPER azzerato?
	beq.s	NointCOPER	; se si, non e' un int COPER!
	move.w	#$F00,$dff180	; int COPER, allora COLOR0 = ROSSO
NointCOPER:
		 ;6543210
	move.w	#%1110000,$dff09c ; INTREQ - cancello rich. BLIT,VERTB e COPER
	rte	; uscita dall'int COPER/BLIT/VERTB

*****************************************************************************
*	ROUTINE IN INTERRUPT $70 (livello 4)
*****************************************************************************

;	    _/\__/\_
;	  _/ '_  _`¬\_
;	 (/  (¤)(¤)  \)
;	 /  _ ¯··¯ _  \
;	/    ¯Y¯¯Y¯    \
;	\____ '  ` ____/
;	   `--------' xCz

;10	AUD3	4 ($70)	Lettura di un blocco di dati del can. audio 3 finita.
;09	AUD2	4 ($70)	Lettura di un blocco di dati del can. audio 2 finita.
;08	AUD1	4 ($70)	Lettura di un blocco di dati del can. audio 1 finita.
;07	AUD0	4 ($70)	Lettura di un blocco di dati del can. audio 0 finita.

NOINT4: ; $70
	BTST.b	#7,$dff01f	; INTREQR - AUD0?
	BEQ.W	NoAUD0
	; routines aud0
NoAUD0:
	BTST.b	#8-7,$dff01e	; INTREQR - AUD1? nota: $dff01e e non $dff01f
				; 		  perche' il bit e' >7!
	BEQ.W	NoAUD1
	; routines aud1
NoAUD1:
	BTST.b	#9-7,$dff01e	; INTREQR - AUD2?
	Beq.W	NoAUD2
	; routines aud2
NoAUD2:
	BTST.b	#10-7,$dff01e	; INTREQR - AUD3?
	Beq.W	NoAUD3
	; routines aud3
NoAUD3:
		; 09876543210
	MOVE.W	#%11110000000,$DFF09C	; aud0,aud1,aud2,aud3
	RTE

*****************************************************************************
*	ROUTINE IN INTERRUPT $74 (livello 5)
*****************************************************************************

;	 .:::::.
;	 ¦:·_ _!
;	 ! (°T°)
;	( , ¯,\\
;	 \`---¯/
;	  `---' xCz

;12	DSKSYN	5 ($74)	Generato se il registro DSKSYNC corrisponde ai dati
;			letti dal disco nel drive.Serve per i loader hardware.
;11	RBF	5 ($74)	Buffer UART di ricezione della porta seriale PIENO.


NOINT5: ; $74
	BTST.b	#12-7,$dff01e	; INTREQR - DSKSYN?
	BEQ.W	NoDSKSYN
	; routines dsksyn
NoDSKSYN:
	BTST.b	#11-7,$dff01e	; INTREQR - RBF?
	BEQ.W	NoRBF
	; routines rbf
NoRBF:
		; 2109876543210
	MOVE.W	#%1100000000000,$DFF09C	; serial port rbf, dsksyn
	rte

*****************************************************************************
*	ROUTINE IN INTERRUPT $78 (livello 6)				    *
*****************************************************************************

;	 ......
;	¡·¸ ,·:¦
;	| °u°. )
;	l_`--'_!
;	 `----'xCz

;14	INTEN	6 ($78)
;13	EXTER	6 ($78)	Interrupt esterno, connesso alla linea INT6 + TOD CIAB

NOINT6: ; $78
	tst.b	$bfdd00		; CIAB icr - resetta interrupt timer
	BTST.b	#14-7,$dff01e	; INTREQR - INTEN?
	BEQ.W	NoINTEN
	; routines inten
NoINTEN:
	BTST.b	#13-7,$dff01e	; INTREQR - EXTER?
	BEQ.W	NoEXTER
	; routines exter
NoEXTER:
		; 432109876543210
	MOVE.W	#%110000000000000,$DFF09C ; INTREQ - external int + ciab
	rte

*****************************************************************************
;	Routine di replay del protracker/soundtracker/noisetracker
;
	include	"assembler2:sorgenti4/music.s"
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$00e	; color0 BLU
	dc.w	$a007,$fffe	; WAIT - attendi la linea $a0
	dc.w	$9c,$8010	; INTREQ - Richiedo un interrupt COPER, il
				; quale fa agire sul color0 con un "MOVE.W".
	dc.w	$FFFF,$FFFE	; Fine della copperlist

*****************************************************************************
;				MUSICA
*****************************************************************************

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"assembler2:sorgenti4/mod.fairlight"

	end

Abbiamo ridefinito tutti gli interrupt. Questo puo' essere uno schema di
partenza per farsi un "sistema operativo", ma ve lo sconsiglio!

