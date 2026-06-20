
;  Lezione14-10b.s - Uso della routine player6.1a per un modulo compresso

; Routine P61_Music chiamata ogni vertical blank

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

	move.w	#$e000,$9a(a5)		; INTENA - Abilito Master and lev6
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$08000,d2	; linea da aspettare = $80
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_Music every frame to play the music	н
;н	  _NOT_ if CIA-version is used!		н
;н A6 --> Customchip baseaddress ($DFF000)	н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	move.w	#$f00,$180(a5)	; color0 rosso -> per fare il copper monitor

	movem.l	d0-d7/a0-a6,-(SP)
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	bsr.w	P61_Music
	movem.l	(SP)+,d0-d7/a0-a6

	move.w	#$003,$180(a5)	; color0 nero

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_End to stop the music		н
;н   A6 --> Customchip baseaddress ($DFF000)	н
;н		Uses D0/D1/A0/A1/A3		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	bsr.w	P61_End

	rts


*****************************************************************************
*		 The Player 6.1A for Asm-One 1.09 and later 		    *
*****************************************************************************

fade  = 0	;0 = Normal, NO master volume control possible
		;1 = Use master volume (P61_Master)

jump = 0	;0 = do NOT include position jump code (P61_SetPosition)
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

Questo esempio e' come quello precedente, solo che il modulo ha i sample
compressi (opzione "Pack Samples" attiva, ma senza "Delta" attivo, che pero'
che sia attivo o no ho notato che non cambia quasi niente!!!)
Prima di prendere la decisione di compattare il sample, pensateci due o tre
volte, infatti occorre usare piu' memoria, per creare un buffer dove mettere
i sample scompattati, si perde del tempo nello scompattarli, e si puo' perdere
qualita' audio. A tal proposito, se si sceglie di compattare i sample di un
modulo, appare un requester che ci permette di scegliere sample per sample
quali compattare e quali no, e di ascoltare l'originale e l'eventuale versione
compattata. Ascoltando i vari sample in versione normale e compattata noterete
che alcuni in particolare perdono molto di qualita'.......

