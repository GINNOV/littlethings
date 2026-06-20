
; Lezione11i2.s	- Barre in "pseudoparallasse"

	SECTION	ParaCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	bsr.w	WriteWaits	; Crea le 2 copperlist...

	lea	$dff000,a6
	MOVE.W	#DMASET,$96(a6)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#KOPLIST1,$80(a6)	; Puntiamo la nostra COP
	move.w	d0,$88(a6)		; Facciamo partire la COP
	move.w	#0,$1fc(a6)		; Disattiva l'AGA
	move.w	#$c00,$106(a6)		; Disattiva l'AGA
	move.w	#$11,$10c(a6)		; Disattiva l'AGA

mouse:
	bsr.w	waitvb				; Aspetta il vertical Blank
	move.l	#koplist2,$dff080
	move.l	#koplist1Waits+6,stampa		; inizio cop
	move.l	#koplist1Waits+6+(8*200),a5	; fine cop
	bsr.w	cleacop				; pulisci la copperlist
	bsr.w	makeBeams			; disegna le barre

	bsr.w	waitvb				; Aspetta il vertical Blank
	move.l	#koplist1,$dff080
	move.l	#koplist2Waits+6,stampa		; inzio cop
	move.l	#koplist2Waits+6+(8*200),a5	; fine cop
	bsr.w	cleacop				; pulisci la copperlist
	bsr.w	makeBeams			; disegna le barre

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts			; esci

*****************************************************************************
;	Routine che crea le 2 copperlist
*****************************************************************************

;	__/\__
;	\(Oo)/
;	/_()_\
;	  \/

WriteWaits:
	lea	koplist1waits,a1
	lea	koplist2waits,a2
	move.l	#$2c07ff00,d0	; Wait (prima linea $2c)
	move.l	#$01800000,d2	; Color0
	move.w	#200-1,d1	; Numero waits (200 per l'area NTSC)
WWLoop:
	move.l	d0,(a1)+	; Wait in coplist 1
	move.l	d0,(a2)+	; Wait in coplist 2

	move.l	d2,(a1)+	; Color0 in coplist1
	move.l	d2,(a2)+	; Color0 in coplist2
	add.l	#$01000000,d0	; Fai waitare 1 linea sotto
	dbra	d1,WWLoop
	RTS

*****************************************************************************
;	Routine che "pulisce" lo sfondo
*****************************************************************************

;	__/\__
;	\[oO]/
;	/_--_\
;	  \/

CleaCop:
	move.l	stampa(PC),a0	; copper attuale
	moveq	#$001,d0	; Colore di sfondo
	move.w	#(200/4)-1,d1	; numero waits
Clealoop:
	move.w	d0,(a0)		; azzera
	move.w	d0,8(a0)	;...
	move.w	d0,8*2(a0)
	move.w	d0,8*3(a0)
	lea	8*4(a0),a0
	dbra	d1,Clealoop	; rifai 200/4 volte, perche' pulisce 4
	rts			; words per loop! (piu' veloce!)

*****************************************************************************
;	Routine che attende il vblank
*****************************************************************************

;	__/\__
;	\-OO-/
;	/_\/_\
;	  \/

Waitvb:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$0ff00,d2	; linea da aspettare = $FF
Waity1:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $FF
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $FF
	BEQ.S	Aspetta
	RTS

*****************************************************************************
;	Routine che modifica le copperlist
*****************************************************************************

;	__/\__
;	\(OO)/
;	/_==_\
;	  \/

MakeBeams:
	lea	beam01(pc),a1	; tab colori barra 1
	move.l	beam01x(pc),d0	; la x...
	moveq	#10,d1		; la distanza tra 1 e l'altro
	bsr.w	writebeam

	lea	beam02(PC),a1	; tab colori barra 2
	move.l	beam02x(PC),d0	; la x...
	moveq	#25,d1		; la distanza tra 1 e l'altro
	bsr.w	writebeam

	lea	beam03(PC),a1	; tab colori barra 2
	move.l	beam03x(PC),d0	; la x...
	moveq	#55,d1		; la distanza tra 1 e l'altro
	bsr.w	writebeam

; BEAM01x scende di 1 ogni 2 frames.

	subq.b	#1,timer01x	; 1 frame ogni 2.
	bne.s	Non01x		; passato il frame? (timer1x=0?)
	move.b	#2,timer01x	; risetta 2 frame

	addq.l	#1,beam01x	; Fai scendere di 1 Beam01x
	cmp.l	#8+10,beam01x	; siamo in fondo?
	bne.s	Non01x
	clr.l	beam01x		; Se si, riparti!
Non01x:

; BEAM02x scende di 1 ogni frame.

	addq.l	#1,beam02x	; fai scendere di 1 beam02x
	cmp.l	#16+25,beam02x	; siamo in fondo?
	bmi.s	NONON2
	clr.l	beam02x		; se si riparti
NONON2:

; BEAM03x scende di 2 ogni frame.

	addq.l	#2,beam03x	; Fai scendere di 2 beam03x

	cmp.l	#16+55,beam03x	; siamo in fondo
	bmi.s	NONON3

	clr.l	beam03x		; se si riparti.
NONON3:
	RTS

timer01x:
	dc.b	2

	even

stampa:		dc.l	koplist1Waits+6		; Copper attuale

beam01x:	dc.l 10
beam02x:	dc.l 5
beam03x:	dc.l 2


*****************************************************************************
;	Routine che "scrive" le barre
*****************************************************************************
;	lea	beam01(pc),a1	; Tabella colori Beam01
;	move.l	beam01x(pc),d0	; la x...
;	moveq	#10,d1		; la distanza tra 1 e l'altro

;	__/\__
;	\ $$ /
;	/_()_\
;	  \/  

WriteBeam:
	move.l	stampa(PC),a0	; indirizzo copper attuale
	move.l	a1,a2		; indirizzo tabella colori in a1 e a2
	lsl.w	#3,d0		; X * 8
	lsl.w	#3,d1		; Distanza tra le barre * 8
	add.w	d0,a0		; trova offset (x*8)
WBLoop2:
	move.l	a2,a1		; tab colori
WBLoop:
	tst.w	(a1)		; tab colori finita?
	beq.s	EndOfBeam	; se si, esci!
	move.w	(a1)+,(a0)	; Copia il colore dalla tabella alla copbar
	addq.w	#8,a0		; vai al prossimo color0
	cmp.l	a5,a0		; fine della copperlist?
	bmi.s	WBloop		; se non ancora, insisti
EndOfBeam:
	add.w	d1,a0		; finita una barra, se ne fa un'altra piu'
				; sotto: aggiungiamo la distanza * 8 per
				; trovare dove comincia la prossima barra
	cmp.l	a5,a0		; e verifichiamo di non essere fuori copper
	bmi.s	WBloop2		; Se non siamo fuori, possiamo andare!
	RTS


; Tabella colori delle barre piu' "lontane" e lente (blu)

Beam01:
	dc.w	$003
	dc.w	$005
	dc.w	$007
	dc.w	$009
	dc.w	$00a
	dc.w	$007
	dc.w	$005
	dc.w	$003
	dc.w	0

; Tabella colori delle barre intermedie (verdi)

Beam02:
	dc.w	$001
	dc.w	$001

	dc.w	$010
	dc.w	$020
	dc.w	$030
	dc.w	$040
	dc.w	$050
	dc.w	$060
	dc.w	$070
	dc.w	$060
	dc.w	$050
	dc.w	$040
	dc.w	$030
	dc.w	$020
	dc.w	$010

	dc.w	$001
	dc.w	0

; Tabella colori delle barre "vicine" (arancione)

Beam03:
	dc.w	$110
	dc.w	$320
	dc.w	$520
	dc.w	$730
	dc.w	$940
	dc.w	$b50
	dc.w	$d60
	dc.w	$f70
	dc.w	$f60
	dc.w	$b50
	dc.w	$940
	dc.w	$730
	dc.w	$520
	dc.w	$420
	dc.w	$320
	dc.w	$210
	dc.w	$110
	dc.w	0


*****************************************************************************

	SECTION	koplists,DATA_C

; Prima copper

koplist1:
	dc.w	$180,$666	; Color0
	dc.w	$100,$200	; bplcon0 - no bitplanes
koplist1waits:
	dcb.w	4*200,0		; Spazio per l'effetto
	dc.w	$180,$666	; Color0
	dc.w    $ffff,$fffe	; Fine della copperlist

; Seconda copper, scambiata con la prima per una sorta di "double buffering"
; per copperlist, per eliminare l'evenienza di non riuscire a scrivere in
; tempo nei color0 per evitare che si "noti" la scrittura stessa.

koplist2:
	dc.w	$180,$666	; Color0
	dc.w	$100,$200	; bplcon0 - no bitplanes
koplist2waits:
	dcb.w	4*200,0		; Spazio per l'effetto.
	dc.w	$180,$666	; Color0
	dc.w    $ffff,$fffe	; Fine della copperlist

	end

Questo listato ha la particolarita' di avere un "double coppering", ossia si
scrive su una copper mentre se ne visualizza un'altra scritta prima, in modo
da evitare che si "noti" la scrittura rallentata a video. Si poteva anche
usare il sistema del COP2LC+COPJMP2 per scambiare le copperlist.

