
; Lezione11d.s - Utilizzo di interrupts COPER e VERTB dell livello 3 ($6c).

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
;	    ______________
;	   ¡¯            ¬\
;	   | ______ _______)
;	  _| /¯ © \ / ø ¬\|_
;	 C,l \____/_\____/|.)
;	 `-|  ___   \ ___ |-'
;	   |  _/  ,  \ \_ |
;	   |_ ` _ ¯--'_ ' ! xCz
;	  _j \  ¯¯¯¯¯¯¬  /
;	/¯    \__ ¯¯¯ __/¯¯¯\
;	        `-----'

MioInt6c:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.s	NointVERTB		; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.w	mt_music		; suono la musica
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack
nointVERTB:
	btst.b	#4,$dff01f	; INTREQR - COPER azzerato?
	beq.s	NointCOPER	; se si, non e' un int COPER!
	addq.b	#1,Attuale
	cmp.b	#6,Attuale
	bne.s	Vabene
	clr.b	attuale	; riparti da zero
VaBene:
	move.b	Attuale(PC),d0
	cmp.b	#1,d0
	beq.s	Col1
	cmp.b	#2,d0
	beq.s	Col2
	cmp.b	#3,d0
	beq.s	Col3
	cmp.b	#4,d0
	beq.s	Col4
	cmp.b	#5,d0
	beq.s	Col5
Col0:
	move.w	#$300,$dff180	; COLOR0
	bra.s	Colorato
Col1:
	move.w	#$d00,$dff180	; COLOR0
	bra.s	Colorato
Col2:
	move.w	#$f31,$dff180	; COLOR0
	bra.s	Colorato
Col3:
	move.w	#$d00,$dff180	; COLOR0
	bra.s	Colorato
Col4:
	move.w	#$a00,$dff180	; COLOR0
	bra.s	Colorato
Col5:
	move.w	#$500,$dff180	; COLOR0
Colorato:
NointCOPER:
		 ;6543210
	move.w	#%1110000,$dff09c ; INTREQ - cancello rich. BLIT,COPER,VERTB
				; dato che il 680x0 non la cancella da solo!!!
	rte	; uscita dall'int COPER/BLIT/VERTB

Attuale:
	dc.w	0

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
	dc.w	$a207,$fffe	; WAIT - attendi la linea $a2
	dc.w	$9c,$8010	; INTREQ - Richiedo un interrupt COPER, il
				; quale fa agire sul color0 con un "MOVE.W".
	dc.w	$a407,$fffe	; WAIT - attendi la linea $a4
	dc.w	$9c,$8010	; INTREQ - Richiedo un interrupt COPER, il
				; quale fa agire sul color0 con un "MOVE.W".
	dc.w	$a607,$fffe	; WAIT - attendi la linea $a6
	dc.w	$9c,$8010	; INTREQ - Richiedo un interrupt COPER, il
				; quale fa agire sul color0 con un "MOVE.W".
	dc.w	$a807,$fffe	; WAIT - attendi la linea $a8
	dc.w	$9c,$8010	; INTREQ - Richiedo un interrupt COPER, il
				; quale fa agire sul color0 con un "MOVE.W".
	dc.w	$aa07,$fffe	; WAIT - attendi la linea $aa
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

In questo esempio vediamo come sia possibile chiamare l'interrupt a diverse
linee, e come si possa ogni volta far eseguire una routine diversa, tramite
l'uso di un contatore, la label "Attuale", che tiene il conto della routine
da eseguire ad ogni chiamata. Se questo ordine viene cambiato, togliendo una
routine, avverera' un "ciclare" delle routines. Provate, ad esempio, a fare
questa modifica:

nointVERTB:
	btst.b	#4,$dff01f	; INTREQR - COPER azzerato?
	beq.s	NointCOPER	; se si, non e' un int COPER!
	addq.b	#1,Attuale
	cmp.b	#5,Attuale	; ** MODIFICA ** -> 5, e non 6!!!!!!!!!

In questo modo vedrete uno scorrimento dei colori. Essendo pochi l'effetto e'
un po' troppo veloce, ma pensate all'utilita' se per ogni interrupt cambiaste
l'intera palette da 32 colori, e faceste anche qualcos'altro!
Senza contare il fatto che potete anche fare qualcosa nella routine "user",
che qua fa solo uno sterile ciclo in attesa della pressione del mouse.
