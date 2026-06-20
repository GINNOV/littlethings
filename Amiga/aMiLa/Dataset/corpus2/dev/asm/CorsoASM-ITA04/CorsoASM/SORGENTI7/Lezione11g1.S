
; Lezione11g1.s -  Uso della caratteristica del copper di richiedere 8 pixel
;		   orizzontali per eseguire un suo "MOVE".

	Section	HorizCop,CODE

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
*   Questa routine crea una copperlist con 40 registri COLOR0 per	*
*   Linea, per cui, dato che ogni move della copperlist impiega 8	*
*   pixel (lowres) di tempo per essere eseguita, il color0 viene	*
*   cambiato 40 volte ORIZZONTALMENTE a scatti di 8 pixel lowres	*
*************************************************************************

;	   .:::::.
;	  ¦:::·:::¦
;	  |· ¯ ¯ ·|
;	 C|  ° °  l)
;	 /__ (_) __\
;	/ \ \___/ / \
;	\__\_   _/__/
;	  \_`---'_/xCz
;	    ¯¯¯¯¯

LINSTART	EQU	$A041fffe	; Cambiare "$a0" per iniziare ad un
					; altra linea verticale.
LINUM		EQU	25		; Numero di linee da fare.

MAKE_IT:
	lea	CopBuf,a1
	move.l	#LINSTART,d0	; Primo "wait"
	move.w	#LINUM-1,d1	; Numero di linee da fare
colcon1:
	lea	cols(pc),a0	; Indirizzo tabella con i colori in a0
	move.w	#39-1,d2	; 39 colori per linea
	move.l	d0,(a1)+	; Metti il WAIT in copperlist
colcon2:
	move.w	#$0180,(a1)+	; Metti il registro COLOR0
	move.w	(a0)+,(a1)+	; Metti il valore del COLOR0 (dalla tabella)
	dbra	d2,colcon2	; Esegui tutta una linea
	add.l	#$01000000,d0	; Fai "waitare" alla linea sotto
	dbra	d1,colcon1	; ripeti per il numero di linee da fare
	rts


;	Tabella con i 39 colori di una linea orizzontale.

cols:
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff
	dc.w	$eee,$ddd,$ccc,$bbb,$aaa,$999,$888,$777
	dc.w	$666,$555,$444,$333,$222,$111,$000

*****************************************************************************

	section	coppa,data_C

COPLIST:
	DC.W	$100,$200	; BplCon0 - no bitplanes
	DC.W	$180,$003	; Color0 - blu
CopBuf:
	dcb.w	80*LINUM,0	; Spazio dove sara' creata la copperlist.

	DC.W	$180,$003	; Color0 - blu
	dc.w	$ffff,$fffe	; Fine copperlist

	END

Questo listato dimostra come mettendo una fila di COLOR0 (o di qualsiasi altro
MOVE del WAIT), ci vuole un certo tempo per eseguirne ciascuno, e precisamente
8 pixel lowres. Infatti se si mette la risoluzione hires questo non cambia,
e si puo' parlare di "16" pixel hires... ma e' inutile, se volete potete
misurare la larghezza di uno "scatto" orizzontale con un righello e noterete
che e' sempre quella. Oltre a essere un fatto utile per effetti come il PLASMI
o quello visto in questo esempio, e' una limitazione, nel senso che se si
vuol cambiare tutta la palette ad ogni riga ci vuole "un certo tempo" e questa
non cambierebbe completamente che a meta' linea o addirittura alla linea sotto.

