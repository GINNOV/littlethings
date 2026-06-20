
; Lezione11g2.s -  Uso della caratteristica del copper di richiedere 8 pixel
;		   orizzontali per eseguire un suo "MOVE".

	Section	coppuz,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************

; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA abilitato

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	BSR.W	MAKE_IT		; Prepara la copperlist

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA
MOUSE:
	BTST	#$06,$BFE001	; Aspetta la presisone del mouse
	BNE.S	MOUSE
	RTS

*************************************************************************
*   Questa routine crea una copperlist con 52 registri COLOR0 per	*
*   Linea, per cui, dato che ogni move della copperlist impiega 8	*
*   pixel (lowres) di tempo per essere eseguita, il color0 viene	*
*   cambiato 52 volte ORIZZONTALMENTE a scatti di 8 pixel lowres	*
*************************************************************************

;	  .:::::.
;	 ¦:::·:::¦
;	 |·     ·|
;	C| _   _ l)
;	/ _°(_)°_ \
;	\_\_____/_/
;	 l_`---'_!
;	  `-----'xCz


LINSTART	EQU	$8021fffe	; Cambiare "$80" per iniziare ad un
					; altra linea verticale.
LINUM		EQU	25*3		; Numero di linee da fare.

MAKE_IT:
	lea	CopBuf,a1	; Indirizzo spazio in copperlist
	move.l	#LINSTART,d0	; Primo "wait"
	move.w	#LINUM-1,d1	; Numero di linee da fare
	move.w	#$180,d3	; Word per il registro color0 in coplist
	move.l	#$01000000,d4	; Valore da "addare" al wait per farlo waitare
				; alla linea successiva.
colcon1:
	lea	cols(pc),a0	; Indirizzo tabella con i colori in a0
	move.w	#52-1,d2	; 52 colori per linea
	move.l	d0,(a1)+	; Metti il WAIT in copperlist
colcon2:
	move.w	d3,(a1)+	; Metti il registro COLOR0 ($180)
	move.w	(a0)+,(a1)+	; Metti il valore del COLOR0 (dalla tabella)
	dbra	d2,colcon2	; Esegui tutta una linea
	add.l	d4,d0		; Fai "waitare" alla linea sotto (+$01000000)
	dbra	d1,colcon1	; ripeti per il numero di linee da fare
	rts


;	Tabella con i 52 colori di una linea orizzontale.

cols:
	dc.w	$26F,$27E,$28D,$29C,$2AB,$2BA,$2C9,$2D8,$2E7,$2F6
	dc.w	$4E7,$6D8,$8C9,$ABA,$CAA,$D9A,$E8A,$F7A,$F6B,$F5C
	dc.w	$D6D,$B6E,$96F,$76F,$56F,$36F,$26F,$27E,$28D,$29C
	dc.w	$2AB,$2BA,$2C9,$2D8,$2E7,$2F6,$4E7,$6D8,$8C9,$ABA
	dc.w	$CAA,$D9A,$E8A,$F7A,$F6B,$F5C,$D6D,$B6E,$96F,$76F
	dc.w	$56F,$36F

*****************************************************************************

	section	coppa,data_C

COPLIST:
	DC.W	$100,$200	; BplCon0 - no bitplanes
	DC.W	$180,$003	; Color0 - blu
CopBuf:
	dcb.w	(52*2)*LINUM+(2*linum),0	; Spazio per la copperlist.
	DC.W	$180,$003	; Color0 - blu
	dc.w	$ffff,$fffe	; Fine copperlist

	END

In questo caso abbiamo reso piu' "colorato" l'effetto, niente di speciale.
