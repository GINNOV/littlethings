
; Lezione8r.s		Routines di riconoscimento del processore e del
;			chipset (aga o normale).
;			(Ma a noi che ci fa il Sysinfo!!)

	SECTION	SysInfo,CODE

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

START:

;	Puntiamo i bitplanes in copperlist

	MOVE.L	#BITPLANE,d0	; in d0 mettiamo l'indirizzo del bitplane
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

; NOTATE IL -80!!!! (per provocare l'effetto "profondita'"

	MOVE.L	#BITPLANE-80,d0	; in d0 mettiamo l'indirizzo del bitplane -80
				; ossia una linea SOTTO! *******
	LEA	BPLPOINTERS2,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	bsr.s	CpuDetect	; Controlla quale CPU e' presente, e cambia
				; il testo opportunamente se non e' un 68000
				; di base.
	bsr.w	FpuDetect	; Controlla se e' presente una coprocessore
				; matematico in virgola mobile (Floating
				; Point Unit).
	bsr.w	AgaDetect	; Controlla se e' presente il chipset AGA.

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA


mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

	bsr.w	PrintCarattere	; Stampa un carattere alla volta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	rts

;*****************************************************************************
;			ROUTINE DI DETECT DEL PROCESSORE
;
; Sia questa routine che quella che controlla la presenza dell'FPU usano un
; apposito byte del sistema operativo, che si trova $129 bytes dopo il
; valore che si trova in $4, ossia execBase+$129.
;
;	AttnFlags ( ossia il byte $129(a6), dove in a6 c'e' execBase )
;
;      bit	CPU o FPU
;
;	0	68010 (o 68020/30/40)
;	1	68020 (o 68030/40)
;	2	68030 (o 68040)			[V37+]
;	3	68040 				[V37+]
;	4	68881 FPU fitted (o 68882)
;	5	68882 FPU fitted		[V37+]
;	6	68040 FPU fitted		[V37+]
;
;*****************************************************************************

;	      /\                     ___.               /\
;	     /  \   ______  __      /   |_________     /  \NoS!
;	    /    \  \_    \/  \    /    |        /    /    \_ ___ _/\__
;	   //     \  /         \  /_____|   ____/___./     \ _ _ _ ø¶ /
;	  //       \/    \  /   \/      |   \__     |       \\   /_)(_\
;	 /          \     \/     \      |     7     |         \    \/
;	/____________\____/_____/\______j___________j__________\

CpuDetect:
	LEA	CpuType(PC),A1
	move.l	4.w,a6		; ExecBase in a6

; nota: il 68030/40 non viene riconosciuto dal kickstart 1.3 o inferiore, ma
; si suppone che chi ha un 68020+ ha anche il kickstart 2.0 o superiore!

	btst.b	#3,$129(a6)	; Attnflags - un 68040?
	BNE.S	M68040
	btst.b	#2,$129(a6);d0	; Attnflags - un 68030?
	BNE.S	M68030
	btst.b	#1,$129(a6);d0	; Attnflags - un 68020?
	BNE.S	M68020
	btst.b	#0,$129(a6);d0	; Attnflags - un 68010?
	BNE.S	M68010
M68000:
	BRA.S	PROCDONE	; un 68000! lascia la scritta '68000'

M68010:
	MOVE.W	#'10',(a1)	; cambia '68000' in '68010'
	BRA.S	PROCDONE

M68020:
	MOVE.W	#'20',(a1)	; cambia '68000' in '68020'
	BRA.S	PROCDONE

M68030:
	MOVE.W	#'30',(a1)	; cambia '68000' in '68030'
	BRA.S	PROCDONE

M68040:
	MOVE.W	#'40',(a1)	; cambia '68000' in '68040'


PROCDONE:
	rts

;*****************************************************************************
;			ROUTINE DI DETECT DEL COPROCESSORE
;*****************************************************************************

; Ora controllo se e' presente un coprocessore matematico (FPU)

FPUDetect:
	LEA	FpuType(PC),a1	; stringa di testo del coprocessore (FPU)
	move.l	4.w,a6		; Execbase (Per accedere al byte AttnFlags)
	btst.b	#3,$129(a6)	; se e' un 68040, il coprocessore e' incluso!
	BNE.S	FpuPresente
	btst.b	#4,$129(a6);d0	; 68881? -> FPU detected!
	BNE.S	FpuPresente
	btst.b	#5,$129(a6);d0	; 68882? -> FPU detected!
	BNE.S	FpuPresente
	BRA.S	FpuNonPresente	; NO FPU! Vabbe'....

FpuPresente:
	MOVE.L	#'FOUN',(A1)+	; Se e' presente, scriviamo FOUND!
	MOVE.B	#'D',(A1)+
FpuNonPresente:
	rts

;*****************************************************************************
;	      ROUTINE DI DETECT DEL CHIPSET AGA (non sbaglia MAI!)
;*****************************************************************************

AgaDetect:
	LEA	$DFF000,A5
	MOVE.W	$7C(A5),D0	; DeniseID (o LisaID AGA)
	MOVEQ	#100,D7		; Controlla 100 volte (per sicurezza, dato
				; che il vecchio denise da valori casuali)
DENLOOP:
	MOVE.W	$7C(A5),D1	; Denise ID (o LisaID AGA)
	CMP.B	d0,d1		; Lo stesso valore?
	BNE.S	NOTAGA		; Non e' lo stesso valore: Denise OCS!
	DBRA	D7,DENLOOP
	BTST.L	#2,d0		; BIT 2 azzerato=AGA. E' presente l'aga??
	BNE.S	NOTAGA		; no?
	LEA	Chipset(PC),A1	; SI!
	MOVE.L	#'AGA ',(A1)+	; Metti AGA al posto di NORMAL...
	MOVE.W	#'  ',(A1)+
	LEA	Messaggio(PC),A1 ; E fai i complimenti per la presenza dell'AGA
	MOVE.L	#'Gran',(A1)+
	MOVE.L	#'de! ',(A1)+
	MOVE.L	#'Una ',(A1)+
	MOVE.L	#'macc',(A1)+
	MOVE.L	#'hina',(A1)+
	MOVE.L	#' AGA',(A1)+
	MOVE.L	#'!!! ',(A1)+
	MOVE.L	#'    ',(A1)+
	MOVE.L	#'    ',(A1)+
	MOVE.L	#'    ',(A1)
NOTAGA:				; non AGA... OCS/ECS... mah..
	rts			; Allora lascia il messaggio di comprarselo!

*****************************************************************************
;			Routine di Print
*****************************************************************************

PRINTcarattere:
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#80*7,PuntaBITPLANE	; ANDIAMO A CAPO
	ADDQ.L	#1,PuntaTesto		; primo carattere riga dopo
					; (saltiamo lo ZERO)
	move.b	(a0)+,d2		; primo carattere della riga dopo
					; (saltiamo lo ZERO)

NonFineRiga:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	LSL.W	#3,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,80(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,80*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,80*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,80*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,80*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,80*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,80*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	RTS


PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BITPLANE

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
             ;   1234567890123456789012345678901234567890
	dc.b	'    Loading Randy Operating System 1.02,'   ; 1
	dc.b	' please wait...                         ',0 ; 1b
;
	dc.b	'                                        '   ; 2
	dc.b	'                                        ',0 ; 2b
;
	dc.b	'    Testing HARWARE...                  '   ; 3
	dc.b	'                                        ',0 ; 3b
;
	dc.b	'    Testing KickStart...                '   ; 4
	dc.b	'                                        ',0 ; 4b
;
	dc.b	'    Done.                               '   ; 5
	dc.b	'                                        ',0 ; 5b
;
	dc.b	'                                        '   ; 6
	dc.b	'                                        ',0 ; 6b
;
	dc.b	'    PROCESSOR (CPU):  680'
CpuType:
	dc.b	'00             '  ; 7
	dc.b	'                                        ',0 ; 7b
;
	dc.b	'    MATH COPROCESSOR: '
FpuType:
	dc.b	'NONE              '   ; 8
	dc.b	'                                        ',0 ; 8b
;
	dc.b	'    GRAPHIC CHIPSET:  '
Chipset:
	dc.b	'NORMAL           '   ; 9
	dc.b	'                                        ',0 ; 9b
;
	dc.b	'                                        '   ; 10
	dc.b	'                                        ',0 ; 10b
;
	dc.b	'     '
Messaggio:
	dc.b	'Comprati una macchina AGA!         '   ; 11
	dc.b	'                                        ',$FF ; 11b
;

	EVEN


;	Il FONT caratteri 8x8 copiato in CHIP dalla CPU e non dal blitter,
;	per cui puo' stare anche in fast ram. Anzi sarebbe meglio!

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

******************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$003c	; DdfStart HIRES
	dc.w	$94,$00d4	; DdfStop HIRES
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%1010001000000000	; bit 13 - 2 bitplanes, 4 colori HIRES

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
BPLPOINTERS2:
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane

	dc.w	$180,$103	; color0 - SFONDO
	dc.w	$182,$fff	; color1 - plane 1 posizione normale, e'
				; la parte che "sporge" in alto.
	dc.w	$184,$345	; color2 - plane 2 (sfasato in basso)
	dc.w	$186,$abc	; color3 - entrambi i plane - sovrapposizione

	dc.w	$FFFF,$FFFE	; Fine della copperlist

******************************************************************************

	SECTION	MIOPLANE,BSS_C	; Le SECTION BSS devono essere fatte di
				; soli ZERI!!! si usa il DS.b per definire
				; quanti zeri contenga la section.

;	Ecco perche' serve il "ds.b 80":
;	MOVE.L	#BITPLANE-80,d0	; in d0 mettiamo l'indirizzo del bitplane -80
;				; ossia una linea SOTTO! *******

	ds.b	80	; la linea che "spunta"
BITPLANE:
	ds.b	80*256	; un bitplane HIres 640x256

	end

Se notate, cambiamo il testo prima che venga stampato, niente di strabiliante.
Per sapere quale processore e che chipset ci sono nel computer basta consultare
i relativi bit del sistema operativo e del $dff07c. Comunque fa abbastanza
scena mostrare un detect all'inizio della produzione!!!
