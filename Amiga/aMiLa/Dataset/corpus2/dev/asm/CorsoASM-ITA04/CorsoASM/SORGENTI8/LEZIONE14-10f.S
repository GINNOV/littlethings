
;  Lezione14-10f.s - Uso della routine player6.1a per un modulo compresso

; Routine P61_Music chiamata da interrupt VERTB ($6c) livello3

; Inoltre e' abilitata la routine di salto ai vari punti del modulo. Per
; fare cio' basta settare jump = 1, e chiamare la routine P61_SetPosition
; con la posizione in d0.l

; Premere alternativamente i tasti desto e sinistro, ma attenzione al fatto
; che i cambiamenti avvengono alla fine del pattern, non subito!!!

	SECTION	Usoplay61a,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_Init to initialize the playroutine	н
;н D0 --> Timer detection (for CIA-version)	н
;н A0 --> Address to the module			н
;н A1 --> Address to samples/0			н
;н A2 --> Address to sample buffer		н
;н D0 <-- 0 if succeeded			н
;н A6 <-- $DFF000				н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	movem.l	d0-d7/a0-a6,-(SP)
	lea	P61_data,a0	; Indirizzo del modulo in a0
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	sub.l	a1,a1		; I samples non sono a parte, mettiamo zero
	lea	samples,a2	; modulo compattato! Buffer destinazione per
				; i samples (in chip ram) da indicare!
	bsr.w	P61_Init	; Nota: impiega alcuni secondi per decompress!
	movem.l	(SP)+,d0-d7/a0-a6

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	BaseVBR(PC),a0
	move.l	#Myint6c,$6c(a0)	; metto la mia routine interrupt

	move.w	#$e020,$9a(a5)		; INTENA - Abilito Master and lev6
					; e VERTB (lev3).

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	clr.w	ModPos		; riparti da capo
	st.b	CambiaPos

mouse2:
	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2

	move.w	#16,ModPos	; vai alla pos 16
	st.b	CambiaPos

mouse3:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse3

	move.w	#30,ModPos	; Vai alla posizione 30 (in questo modulo e'
	st.b	CambiaPos	; l'ultima).

mouse4:
	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse4

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_End to stop the music		н
;н   A6 --> Customchip baseaddress ($DFF000)	н
;н		Uses D0/D1/A0/A1/A3		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	bsr.w	P61_End

	rts

*****************************************************************************
*		Routine in interrupt livello 3 ($6c)			    *
*****************************************************************************

MyInt6c:
	btst	#5,$dff01f	; INTREQR - int VERTB?
	beq.s	noint		; se no, esci!

	movem.l	d0-d7/a0-a6,-(SP)
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	tst.b	CambiaPos	; dobbiamo saltare pos?
	beq.s	NonCambiarPos
	cmp.w	#63,P61_Crow	; siamo all'ultima riga del pattern?
	bne.s	NonCambiarPos	; se non ancora, non ripartire da capo!
	clr.b	CambiaPos
	moveq	#0,d0
	move.w	ModPos(PC),d0	; a quale pos. saltiamo?
	bsr.w	P61_SetPosition	; cambiamo posizione
NonCambiarPos:
	bsr.w	P61_Music		; suoniamo
	movem.l	(SP)+,d0-d7/a0-a6
noint:	
	move.w	#$70,$dff09c	; INTENAR
	rte

ModPos:
	dc.w	0
CambiaPos:
	dc.w	0

*****************************************************************************
*		 The Player 6.1A for Asm-One 1.09 and later 		    *
*****************************************************************************

fade  = 0	;0 = Normal, NO master volume control possible
		;1 = Use master volume (P61_Master)

jump = 1	;0 = do NOT include position jump code (P61_SetPosition)
		;1 = Include

system = 0	;0 = killer
		;1 = friendly

CIA = 0		;0 = CIA disabled
		;1 = CIA enabled

exec = 1	;0 = ExecBase destroyed
		;1 = ExecBase valid

opt020 = 0	;0 = MC680x0 code
		;1 = MC68020+ or better

use = $b55a	; Usecode (mettete il valore dato dal p61con al salvataggio
		; diverso per ogni modulo!)

*****************************************************************************
	include	"play.s"	; La routine vera e propria!
*****************************************************************************


*****************************************************************************
;	Copperlist
*****************************************************************************

	SECTION	COP,DATA_C

COPPERLIST:
	dc.w	$100,$200	; bplcon0 - no bitplanes
	DC.W	$180,$003	; color0 nero
	dc.W	$FFFF,$FFFE	; fine della copperlist

*****************************************************************************
;	Modulo musicale convertito in formato P61, COMPRESSO! (opzione pack!)
*****************************************************************************

	Section	modulozzo,data	; Non occorre sia in chip ram, perche' e'
				; compresso e sara' scompattato altrove!

; Il modulo e' di Jester/Sanity. Originale 153676, packed 71950

P61_data:
	incbin	"P61.stardust"	; Compresso, (opzione PACK SAMPLES), per cui
				; si puo' mettere anche in fast ram: sara'
				; usato per scompattare i samples nel buffer
				; samples, e non sara' "suonato" direttamente,
				; quindi non dovra' passare per i canali DMA
				; audio, ma solo dalla routine di depack del
				; processore. Quindi, basta un DATA (non _C!)


*****************************************************************************
;	Dove saranno scompattati i samples (section bss in chip ram!)
*****************************************************************************

	section	smp,bss_c

samples:
	ds.b	132112	; lunghezza riportata dal p61con

	end

Fate attenzione nell'uso della routine che salta qua' e la' nel modulo!
Innanzitutto, se saltate nel mezzo di un pattern, va tutto fuori sincronia,
non so se per un bug del player o per altro. Quindi occorre attendere la
fine del pattern corrente prima di saltare ad un altro. Si puo' sapere in
qualunque momento a che punto del modulo siamo leggendo queste 3 variabili:

	P61_Pos: 	Current song position
	P61_Patt:	Current pattern
	P61_CRow:	Current row in pattern

L'utilita' di questa routine si puo' trovare soltanto nel caso in cui si faccia
un modulo in cui volontariamente non si raggiunge mai una data posizione, a
cui si debba saltare con questa routine. Per esempio, per un gioco si puo'
fare una musica "tranquilla" di base, che loopa sempre, ed occupa le prime
40 posizioni. Pero', alle posizioni dalla 40 alla 50 c'e' un altro motivo,
piu' drammatico, a cui non si puo' accedere se non ci si salta.
Ecco allora il nostro metto che se ne va per il mondo, con la musica
spensierata di sfondo... poi trova il cattivo, e saltiamo all'altro motivetto,
che loopa per conto suo... ucciso il mostro, torniamo alla musichetta
tranquillissima.

