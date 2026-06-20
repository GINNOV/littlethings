
; Lezione11c.s - Utilizzo di interrupts COPER e VERTB dell livello 3 ($6c).

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
	move.l	#MioInt6c,$6c(a0)	; metto la mia rout. int. livello 3.

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

	move.w	#$c030,$9a(a5)	; INTENA - abilito interrupt "VERTB" e "COPER"
				; del livello 3 ($6c)

mouse:
	btst	#6,$bfe001	; Mouse premuto? (il processore esegue questo
	bne.s	mouse		; loop in modo utente, e ogni vertical blank
				; nonche' ogni WAIT della linea raster $a0
				; lo interrompe per suonare la musica!).

	bsr.w	mt_end		; fine del replay!

	rts			; esci

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (livello 3) - usato il VERTB e COPER.
*****************************************************************************

;	,;)))(((;,
;	¦'__  __`¦
;	|,-.  ,-.l
;	( © )( © )
;	¡`-'_)`-'¡
;	|  ___   |
;	l__ ¬  __!
;	 T`----'T xCz
;	 '      `

MioInt6c:
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
	move.w	#%1110000,$dff09c ; INTREQ - cancello rich. BLIT e COPER
				; dato che il 680x0 non la cancella da solo!!!
	rte	; uscita dall'int COPER/BLIT/VERTB

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
	incbin	"assembler2:sorgenti4/mod.yellowcandy"

	end

Questa volta abbiamo sfruttato anche l'interrupt del copper, detto COPER,
utile per eseguire operazioni ad una certa linea video.
Da Copperlist infatti si puo' accedere anche al registro INTREQ ($dff09c),
e in questo caso non facciamo altro che settare il bit 4, COPER, assieme al
bit 15 Set/Clr.
In questo caso abbiamo messo solo un "MOVE.W #$f00,$dff180", che non e' un
gran che di routine, ma considerate l'utilita' se le cose da fare sono molte,
e non conviene perdere tempo a comparare il vertical blank con un loop del
processore in modo user...
