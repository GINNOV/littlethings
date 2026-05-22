
; Lezione11h4.s	BARRETTA CHE SALE E SCENDE USANDO IL MASCHERAMENTO DEL WAIT

;	Questo listato e' identico al Lezione3d.s, fatta eccezione per
;	uno stratagemma che ci permette di spostare l'intera barretta
;	con una sola istruzione!!!! Il trucco sta nella COPPERLIST!


	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	btst	#2,$dff016	; tasto destro premuto?
	beq.s	Mouse2		; se si non eseguire MuoviCopper

	bsr.s	MuoviCopper	; Routine che sfrutta il mascheramento del WAIT

mouse2:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************

MuoviCopper:
	TST.B	SuGiu		; Dobbiamo salire o scendere? se SuGiu e'
				; azzerata, (cioe' il TST verifica il BEQ)
				; allora saltiamo a VAIGIU, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo salendo (facendo dei subq)
	beq.w	VAIGIU
	cmpi.b	#$34,BARRA	; siamo arrivati alla linea $34?
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
	subq.b	#1,BARRA
	rts

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	rts			; fara' saltare alla routine VAIGIU, e
				; la barra scedera'

VAIGIU:
	cmpi.b	#$77,BARRA	; siamo arrivati alla linea $77?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	addq.b	#1,BARRA
	rts

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.

Finito:
	rts


;	Questo byte, indicato dalla label SuGiu, e' un FLAG, ossia una
;	bandierina (in gergo)

SuGiu:
	dc.b	0,0


*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200
	dc.w	$180,$000	; Inizio la cop col colore NERO

	dc.w	$2c07,$FFFE	; una piccola barretta fissa verde
	dc.w	$180,$010
	dc.w	$2d07,$FFFE
	dc.w	$180,$020
	dc.w	$2e07,$FFFE
	dc.w	$180,$030
	dc.w	$2f07,$FFFE
	dc.w	$180,$040
	dc.w	$3007,$FFFE
	dc.w	$180,$030
	dc.w	$3107,$FFFE
	dc.w	$180,$020
	dc.w	$3207,$FFFE
	dc.w	$180,$010
	dc.w	$3307,$FFFE
	dc.w	$180,$000

;	  /\  __ __ ______ __ __  /\ Mo!
;	_// \/  ____ _  _ ____  \/ \\_
;	\(_  \  \(O/      \O)/  /  _)/
;	 \/     _)/  _/\   \(_     \/
;	 /_ __        ··\    ______ \
;	(    (_____/\  _____/ | | |\ \
;	 \__________ \/   \_|_|_|_|_) )
;	            \ _______________/
;	             \/

BARRA:
	dc.w	$3407,$FFFE	; aspetto la linea $79 (WAIT NORMALE!)
				; questo wait e' il "BOSS" dei wait
				; mascherati seguenti, infatti lo seguono
				; come degli scagnozzi: se questo wait
				; scende di 1, tutti i wait mascherati
				; sottostanti scendono di 1, eccetera.

	dc.w	$180,$300	; inizio la barra rossa: rosso a 3

	dc.w	$00E1,$80FE	; Questa coppia di istruzioni copper, che
	dc.w	$0007,$80FE	; invece di terminare per $FFFE terminano
				; con $80FE, in pratica si possono tradurre
				; in: "ASPETTA LA LINEA SEGUENTE", in questo
				; caso la linea seguente al wait di BARRA:.
				; Infatti il $00E180fE aspetta la fine della
				; linea (al bordo destro dello schermo), il
				; che fa scattare il copper alla linea seguente
				; alla sua posizione orizzintale 0001 (il
				; bordo sinistro dello schermo). A questo
				; punto per "allineare" aspettiamo la posizione
				; 0007 come gli altri wait.

	dc.w	$180,$600	; rosso a 6

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$900	; rosso a 9

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$c00	; rosso a 12

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$f00	; rosso a 15 (al massimo)

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$c00	; rosso a 12

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$900	; rosso a 9

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$600	; rosso a 6

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$300	; rosso a 3

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

	dc.w	$180,$000	; colore NERO


	dc.w	$fd07,$FFFE	; aspetto la linea $FD
	dc.w	$180,$00a	; blu intensita' 10
	dc.w	$fe07,$FFFE	; linea seguente
	dc.w	$180,$00f	; blu intensita' massima (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

In questo esempio abbiamo risparmiato un bel po' di MOVE: Cambiando 1 solo
BYTE per fotogramma facciamo scorrere una barra intera! Questo grazie al
"mascheramento della y del wait". In pratica l'utilita' sta nel fatto che
mettendo queste 2 wait mascherate:

	dc.w	$00E1,$80FE	; ASPETTA LA LINEA SEGUENTE
	dc.w	$0007,$80FE	; CON il Wait ad Y "mascherata"

Andiamo alla linea seguente all'ultimo wait $FFFE definito, e aggiungendo
altre coppie di $80fe si possono "appiccicare" al primo wait molte linee.
Nonostante tutto pero' e' uno stratagemma poco usato, in quanto ha delle
limitazioni, ad esempio non funziona per le linee superiori alla 127 ($7f)
circa. Provate infatti a cambiare la linea massima raggiungibile:

VAIGIU:
	cmpi.b	#$77,BARRA	; siamo arrivati alla linea $77?

mettendoci un bel $f0, e noterete come superata la linea $80 la barra
si appiattisce e diventa una linea.
La coordinata Y deve andare da $00 a $7f, perche' possiamo mascherare solo 6
bit. Meglio di niente, pero'!!!

Quindi, si puo' dire che il mascheramento funziona nella parte alta dello
schermo da $00 a $7f circa, e sotto la zona NTSC, ossia dopo il $FFDF,$FFFE.

