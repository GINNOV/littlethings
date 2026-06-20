
; Lezione11g7.s -  Uso della caratteristica del copper di richiedere 8 pixel
;		   orizzontali per eseguire un suo "MOVE" per fare una specie
;		   di plasma. Tasto destro per bloccarlo.

	SECTION	Plasmino,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	BSR.w	MAKEPLASM	; Metti i colori dello "pseudoplasma"
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
	MOVE.L	#$0e000,d2	; linea da aspettare = $e0
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $e0
	BNE.S	Waity1

	btst	#2,$dff016	; tasto destro premuto?
	beq.s	Mouse2		; se si non eseguire PLASMA

	BSR.w	PLASMA		; Effetto PLASMA (piu' o meno...)

mouse2:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$0e000,d2	; linea da aspettare = $e0
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $e0
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

******************************************************************************
;			CREA I COLORI DEL PLASMA
******************************************************************************

;		       __
;	            ./  \:
;	            |    |
;	          __(_  _)__
;	   _    ___(° )( °)___
;	 _| |   \_/ ¯¯ \¯¯ \_/
;	| |_|_  _/   (__)   \_
;	|_|\_ \ \ (________) /
;	 (_  _/  \  V -- V  /        __
;	   \ \    \________/        /_(
;	    \ \_____ _\/_ ________ ((__)
;	     \______(    )__________(__)
;	             \__/
;	             ||||
;	           __||||__
;	          /___||___\ g®m


MAKEPLASM:
	LEA	PLASMZONE,A0	; Indirizzo colori in coplist
	lea	COLCOPDAT,a1	; tabella colori
	MOVEQ	#80-1,D7	; numero linee
	moveq	#9,d2		; e metti il contatore a 9
FaiLeLinee:
	MOVEQ	#52-1,D6	; numero di COLOR0 per ogni linea
	ADDQ.w	#4,A0		; Salta il WAIT tra una linea e l'altra
FaiUnaLinea:
	ADDQ.w	#2,A0		; Salta il dc.w $180
	MOVE.W	(a1)+,(A0)+	; per andare a piazzare il colore subito dopo
	DBRA	D6,FaiUnaLinea
	subq.b	#1,d2		; segna che abbiamo fatto una linea
	bne.s	NonRipartire	; se ne abbiamo fatte 8, d6=0, allora occorre
				; ripartire dal primo colore nella tabella.
	lea	COLCOPDAT(pc),a1 ; tab colori in a1 - riparti col colori.
	moveq	#9,d2		; e metti il contatore a 9
NonRipartire:
	DBRA	D7,FaiLeLinee
	RTS


;	Tabella con i 52*9 colori di una linea orizzontale.

COLCOPDAT:
	dc.w	$26F,$27E,$28D,$29C,$2AB,$2BA,$2C9,$2D8,$2E7,$2F6
	dc.w	$4E7,$6D8,$8C9,$ABA,$CAA,$D9A,$E8A,$F7A,$F6C,$F5C
	dc.w	$D6D,$B6E,$96F,$76F,$56F,$36F,$26F,$27E,$28D,$29C
	dc.w	$2AB,$2BA,$2C9,$2D8,$2E7,$2F6,$4E7,$6D8,$8C9,$ABA
	dc.w	$CAA,$D9A,$E8A,$F7A,$F6B,$F5C,$D6D,$B6E,$96F,$76F
	dc.w	$56F,$36F,$36F,$37E,$38D,$39C,$3AB,$3BA,$3C9,$3D8
	dc.w	$3E7,$3F6,$4E7,$7D8,$9C9,$BBA,$DAA,$E9A,$F8A,$F7A
	dc.w	$F6C,$F5C,$E6D,$C6E,$A6F,$86F,$66F,$46F,$36F,$37E
	dc.w	$38D,$39C,$3AB,$3BA,$3C9,$3D8,$3E7,$3F6,$5E7,$7D8
	dc.w	$9C9,$BBA,$DAA,$E9A,$F8A,$F7A,$F6B,$F5C,$E6D,$C6E
	dc.w	$A6F,$86F,$46F,$46F,$36E,$37D,$38C,$39B,$3AA,$3B9
	dc.w	$3C8,$3D7,$3E6,$3F5,$4E6,$7D7,$9C8,$BB9,$DA9,$E99
	dc.w	$F89,$F79,$F6B,$F5B,$E6C,$C6D,$A6E,$86E,$66E,$46E
	dc.w	$36E,$37D,$38C,$39B,$3AA,$3B9,$3C8,$3D7,$3E6,$3F5
	dc.w	$5E6,$7D7,$9C8,$BB9,$DA9,$E99,$F89,$F79,$F6A,$F5B
	dc.w	$E6C,$C6E,$A6E,$86E,$46E,$46E,$46E,$47D,$48C,$49B
	dc.w	$4AA,$4B9,$4C8,$4D7,$4E6,$4F5,$5E6,$8D7,$AC8,$CB9
	dc.w	$EA9,$F99,$F89,$F79,$F6B,$F5B,$F6C,$D6D,$B6E,$96E
	dc.w	$76E,$56E,$46E,$47D,$48C,$49B,$4AA,$4B9,$4C8,$4D7
	dc.w	$4E6,$4F5,$6E6,$8D7,$AC8,$CB9,$EA9,$F99,$F89,$F79
	dc.w	$F6A,$F5B,$F6C,$D6E,$B6E,$96E,$56E,$56E,$45E,$46D
	dc.w	$47C,$48B,$49A,$4A9,$4B8,$4C7,$4D6,$4E5,$5D6,$8C7
	dc.w	$AB8,$CA9,$E99,$F89,$F79,$F69,$F5B,$F4B,$F5C,$D5D
	dc.w	$B5E,$95E,$75E,$55E,$45E,$46D,$47C,$48B,$49A,$4A9
	dc.w	$4B8,$4C7,$4D6,$4E5,$6D6,$8C7,$AB8,$CA9,$E99,$F89
	dc.w	$F79,$F69,$F5A,$F4B,$F5C,$D5E,$B5E,$95E,$55E,$55E
	dc.w	$44D,$45C,$46B,$47A,$489,$498,$4A7,$4B6,$4C5,$4D4
	dc.w	$5C5,$8B6,$AA7,$C98,$E88,$F78,$F68,$F68,$F59,$F4A
	dc.w	$F4B,$D4C,$B4D,$94D,$74D,$54D,$44D,$45C,$46B,$47A
	dc.w	$489,$498,$4A7,$4B6,$4C5,$4D4,$6C5,$8B6,$AA7,$C98
	dc.w	$E88,$F78,$F68,$F58,$F49,$F3A,$F4B,$D4D,$B4D,$94D
	dc.w	$54D,$54D,$44C,$45B,$46A,$479,$488,$499,$4A6,$4B5
	dc.w	$4C4,$4D3,$5C4,$8B5,$AA6,$C97,$E87,$F77,$F67,$F67
	dc.w	$F58,$F49,$F4C,$D4B,$B4C,$94C,$74C,$54C,$44C,$45B
	dc.w	$46A,$479,$488,$497,$4A6,$4B5,$4C4,$4D3,$6C4,$8B5
	dc.w	$AA6,$C97,$E87,$F77,$F67,$F57,$F48,$F39,$F4A,$D4C
	dc.w	$B4C,$94C,$54C,$54C,$44B,$45A,$469,$478,$487,$498
	dc.w	$4A5,$4B4,$4C3,$4D2,$5C3,$8B4,$AA5,$C96,$E86,$F76
	dc.w	$F66,$F66,$F57,$F48,$F4B,$D4A,$B4B,$94B,$74B,$54B
	dc.w	$44B,$45A,$469,$478,$487,$496,$4A5,$4B4,$4C3,$4D2
	dc.w	$6C3,$8B4,$AA5,$C96,$E86,$F76,$F66,$F56,$F47,$F38
	dc.w	$F49,$D4B,$B4B,$94B,$54B,$54B,$44A,$459,$468,$477
	dc.w	$486,$497,$4A4,$4B3,$4C2,$4D1,$5C2,$8B3,$AA4,$C95
	dc.w	$E85,$F75,$F65,$F65,$F56,$F47,$F4A,$D49,$B4A,$94A
	dc.w	$74A,$54A,$44A,$459,$468,$477,$486,$495,$4A4,$4B3
	dc.w	$4C2,$4D1,$6C2,$8B3,$AA4,$C95,$E85,$F75,$F65,$F55
	dc.w	$F46,$F37,$F48,$D4A,$B4A,$94A,$54A,$54A


PVAR1:
	dc.b	0
PVAR2:
	dc.b	0
PVAR3:
	dc.W	0

******************************************************************************
; Questa routine, aziche' cambiare tutti i 54*80=4320 color0 della copperlist,
; cambia gli 80 WAIT tra una linea e l'altra, in modo da far iniziare le linee
; a posizioni orizzontali diverse. Questo sistema e' veloce, ma puo' far
; solamente scorrere a destra o a sinistra le linee. Un vero plasma lo vedremo
; piu' avanti.
******************************************************************************

;	   _________           :
;	___\_      /           :
;	\_________/       __.____
;	  |     |    .-  (_______)
;	  !     _    :  __·'''''`_
;	 _-----(_)__ `- \_   _  __)
;	( __  _  ___)     \__/  \_
;	 \_/ /__/           \  __/
;	  /    (_            )).
;	  \_____/--------------'g®m


PLASMA:
	MOVEQ	#0,D1		; azzeriamo i registri
	MOVEQ	#0,D3
	MOVEQ	#0,D5
	MOVE.B	PVAR1(PC),D1
	MOVE.B	PVAR2(PC),D4
	MOVE.B	PVAR3(PC),D5
	LEA	PLASMZONE,A0		; Indirizzo plasma in copperlist
	LEA	PLASMMOVES(PC),A1	; indirizzo tabella coi movimenti
	MOVE.W	#$8101,D3		; Wait minimo da aggiungere
	MOVE.W	#79-1,D7		; numero linee da "plasmizzare"
PLASMA2:
	MOVEQ	#0,D0			; azzeriamo d0
	MOVE.B	0(A1,D1.w),D0	; e preleviamo dalla tabella in un modo un
	ADD.B	0(A1,D4.w),D0	; po' incasinato il valore giusto secondo
	ADD.B	0(A1,D5.w),D0	; le 3 variabili
	BCLR.L	#0,D0		; non ci serve il bit basso
	ADD.W	D3,D0		; aggiungiamo il wait MINIMO
	ADD.W	#$0100,D3	; e spostiamo il wait minimo una linea sotto
	MOVE.W	D0,(A0)		; Metti il WAIT cambiato
	ADD.W	#(52*4)+4,A0	; e salta al prossimo WAIT
	ADD.B	#$FF,D1		; seleziona solo il byte basso di d1
	ADDQ.B	#4,D4		; aggiungi 4 a d4
	ADD.B	#$7D,D5		; e 125 a d5 (che casino...)
	DBRA	D7,PLASMA2

	ADDQ.B	#1,PVAR1	; secondo queste 3 variabili cambia il casino
	ADDQ.B	#2,PVAR2
	ADDQ.B	#1,PVAR3
	RTS


; parametri per il comando "IS":
;
; BEG> 0
; END> 180
; AMOUNT> 256
; AMPLITUDE> $4A
; YOFFSET> 0
; SIZE> B
; MULTIPLIER> 1

PLASMMOVES:	; 256 bytes
 DC.B	$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D,$0E
 DC.B	$0F,$10,$11,$12,$12,$13,$14,$15,$16,$17,$18,$19,$19,$1A,$1B,$1C
 DC.B	$1D,$1E,$1E,$1F,$20,$21,$22,$22,$23,$24,$25,$26,$26,$27,$28,$29
 DC.B	$29,$2A,$2B,$2C,$2C,$2D,$2E,$2F,$2F,$30,$31,$31,$32,$33,$33,$34
 DC.B	$35,$35,$36,$37,$37,$38,$38,$39,$39,$3A,$3B,$3B,$3C,$3C,$3D,$3D
 DC.B	$3E,$3E,$3F,$3F,$40,$40,$41,$41,$41,$42,$42,$43,$43,$43,$44,$44
 DC.B	$45,$45,$45,$46,$46,$46,$46,$47,$47,$47,$47,$48,$48,$48,$48,$48
 DC.B	$49,$49,$49,$49,$49,$49,$49,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A
 DC.B	$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$49,$49,$49,$49,$49,$49,$49
 DC.B	$48,$48,$48,$48,$48,$47,$47,$47,$47,$46,$46,$46,$46,$45,$45,$45
 DC.B	$44,$44,$43,$43,$43,$42,$42,$41,$41,$41,$40,$40,$3F,$3F,$3E,$3E
 DC.B	$3D,$3D,$3C,$3C,$3B,$3B,$3A,$39,$39,$38,$38,$37,$37,$36,$35,$35
 DC.B	$34,$33,$33,$32,$31,$31,$30,$2F,$2F,$2E,$2D,$2C,$2C,$2B,$2A,$29
 DC.B	$29,$28,$27,$26,$26,$25,$24,$23,$22,$22,$21,$20,$1F,$1E,$1E,$1D
 DC.B	$1C,$1B,$1A,$19,$19,$18,$17,$16,$15,$14,$13,$12,$12,$11,$10,$0F
 DC.B	$0E,$0D,$0C,$0B,$0A,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00

******************************************************************************

	Section	Copper,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$000	; color0 nero
	dc.w	$7F19,$FFFE
	dc.w	$180,$ff0	; giallo (cornicina)
	dc.w	$8007,$FFFE
	dc.w	$180,$06a	; colore intermedio
PLASMZONE:
				; Questo pezzo di copperlist lo avremmo potuto
				; fare anche con una routine...
	dc.l	$8101FFFE	; wait
	dcb.l	52,$1800000	; 54*color0
	dc.l	$8201FFFE	; wait
	dcb.l	52,$1800000	; 54*color0
	dc.l	$8301FFFE	; eccetera
	dcb.l	52,$1800000
	dc.l	$8401FFFE
	dcb.l	52,$1800000
	dc.l	$8501FFFE
	dcb.l	52,$1800000
	dc.l	$8601FFFE
	dcb.l	52,$1800000
	dc.l	$8701FFFE
	dcb.l	52,$1800000
	dc.l	$8801FFFE
	dcb.l	52,$1800000
	dc.l	$8901FFFE
	dcb.l	52,$1800000
	dc.l	$8A01FFFE
	dcb.l	52,$1800000
	dc.l	$8B01FFFE
	dcb.l	52,$1800000
	dc.l	$8C01FFFE
	dcb.l	52,$1800000
	dc.l	$8D01FFFE
	dcb.l	52,$1800000
	dc.l	$8E01FFFE
	dcb.l	52,$1800000
	dc.l	$8F01FFFE
	dcb.l	52,$1800000
	dc.l	$9001FFFE
	dcb.l	52,$1800000
	dc.l	$9101FFFE
	dcb.l	52,$1800000
	dc.l	$9201FFFE
	dcb.l	52,$1800000
	dc.l	$9301FFFE
	dcb.l	52,$1800000
	dc.l	$9401FFFE
	dcb.l	52,$1800000
	dc.l	$9501FFFE
	dcb.l	52,$1800000
	dc.l	$9601FFFE
	dcb.l	52,$1800000
	dc.l	$9701FFFE
	dcb.l	52,$1800000
	dc.l	$9801FFFE
	dcb.l	52,$1800000
	dc.l	$9901FFFE
	dcb.l	52,$1800000
	dc.l	$9A01FFFE
	dcb.l	52,$1800000
	dc.l	$9B01FFFE
	dcb.l	52,$1800000
	dc.l	$9C01FFFE
	dcb.l	52,$1800000
	dc.l	$9D01FFFE
	dcb.l	52,$1800000
	dc.l	$9E01FFFE
	dcb.l	52,$1800000
	dc.l	$9F01FFFE
	dcb.l	52,$1800000
	dc.l	$A001FFFE
	dcb.l	52,$1800000
	dc.l	$A101FFFE
	dcb.l	52,$1800000
	dc.l	$A201FFFE
	dcb.l	52,$1800000
	dc.l	$A301FFFE
	dcb.l	52,$1800000
	dc.l	$A401FFFE
	dcb.l	52,$1800000
	dc.l	$A501FFFE
	dcb.l	52,$1800000
	dc.l	$A601FFFE
	dcb.l	52,$1800000
	dc.l	$A701FFFE
	dcb.l	52,$1800000
	dc.l	$A801FFFE
	dcb.l	52,$1800000
	dc.l	$A901FFFE
	dcb.l	52,$1800000
	dc.l	$AA01FFFE
	dcb.l	52,$1800000
	dc.l	$AB01FFFE
	dcb.l	52,$1800000
	dc.l	$AC01FFFE
	dcb.l	52,$1800000
	dc.l	$AD01FFFE
	dcb.l	52,$1800000
	dc.l	$AE01FFFE
	dcb.l	52,$1800000
	dc.l	$AF01FFFE
	dcb.l	52,$1800000
	dc.l	$B001FFFE
	dcb.l	52,$1800000
	dc.l	$B101FFFE
	dcb.l	52,$1800000
	dc.l	$B201FFFE
	dcb.l	52,$1800000
	dc.l	$B301FFFE
	dcb.l	52,$1800000
	dc.l	$B401FFFE
	dcb.l	52,$1800000
	dc.l	$B501FFFE
	dcb.l	52,$1800000
	dc.l	$B601FFFE
	dcb.l	52,$1800000
	dc.l	$B701FFFE
	dcb.l	52,$1800000
	dc.l	$B801FFFE
	dcb.l	52,$1800000
	dc.l	$B901FFFE
	dcb.l	52,$1800000
	dc.l	$BA01FFFE
	dcb.l	52,$1800000
	dc.l	$BB01FFFE
	dcb.l	52,$1800000
	dc.l	$BC01FFFE
	dcb.l	52,$1800000
	dc.l	$BD01FFFE
	dcb.l	52,$1800000
	dc.l	$BE01FFFE
	dcb.l	52,$1800000
	dc.l	$BF01FFFE
	dcb.l	52,$1800000
	dc.l	$C001FFFE
	dcb.l	52,$1800000
	dc.l	$C101FFFE
	dcb.l	52,$1800000
	dc.l	$C201FFFE
	dcb.l	52,$1800000
	dc.l	$C301FFFE
	dcb.l	52,$1800000
	dc.l	$C401FFFE
	dcb.l	52,$1800000
	dc.l	$C501FFFE
	dcb.l	52,$1800000
	dc.l	$C601FFFE
	dcb.l	52,$1800000
	dc.l	$C701FFFE
	dcb.l	52,$1800000
	dc.l	$C801FFFE
	dcb.l	52,$1800000
	dc.l	$C901FFFE
	dcb.l	52,$1800000
	dc.l	$CA01FFFE
	dcb.l	52,$1800000
	dc.l	$CB01FFFE
	dcb.l	52,$1800000
	dc.l	$CC01FFFE
	dcb.l	52,$1800000
	dc.l	$CD01FFFE
	dcb.l	52,$1800000
	dc.l	$CE01FFFE
	dcb.l	52,$1800000
	dc.l	$CF01FFFE
	dcb.l	52,$1800000
	dc.l	$D001FFFE
	dcb.l	52,$1800000
	dc.l	$D101FFFE

	dc.l	$D219FFFE	; Wait $d2
	dc.l	$1800FF0	; Color0 giallo (cornicina)
	dc.l	$D311FFFE	; Wait $d3
	dc.l	$1800000	; Color0 nero
	dc.l	$FFFFFFFE	; fine della copperlist

	END

