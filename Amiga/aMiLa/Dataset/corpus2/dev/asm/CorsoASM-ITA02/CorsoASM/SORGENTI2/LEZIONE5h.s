
; Lezione5h.s	ONDULAZIONE ORIZZONTALE DI UNA FIGURA COL $dff102

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	 PUNTIAMO I NOSTRI BITPLANES

	MOVE.L	#PIC,d0		; in d0 mettiamo l'indirizzo della PIC,
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP	; Rifai D1 volte POINTBP (D1=num of bitplanes)

;

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP

	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	btst	#2,$dff016	; se il tasto destro e' premuto salta
	beq.s	Aspetta		; la routine dello scroll, bloccandolo

	bsr.w	Ondula		; fa ondulare la figura con molti $dff102 in
				; copperlist

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta!

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts			; USCITA DAL PROGRAMMA

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

; Questa routine e' simile a quella in Lezione3e.s, infatti vengono "spostati"
; dei valori come in una catena; vi ricordate il sistema gia' usato:
;	
;	move.w	col2,col1	; col2 copiato in col1
;	move.w	col3,col2	; col3 copiato in col2
;	move.w	col4,col3	; col4 copiato in col3
;	move.w	col5,col4	; col5 copiato in col4
;
; In questa routine invece di copiare colori si copiano valori del $dff102, ma
; il funzionamento della routine e' lo stesso. Per risparmiare LABEL e tempo
; la routine e' stata fornita di un ciclo DBRA che esegue la rotazione di
; quante word vogliamo: essendo le word da cambiare distanti 8 bytes, basta
; mettere l'indirizzo di una in a0 e dell'altra in a1 e lo spostamento avviene
; con un MOVE.W (a0),(a1). Poi passiamo alla coppia seguente aggiungendo 8
; ad a0 e a1, che punteranno alla prossima coppia di word da scambiare.
; Ricorderete che per fare il ciclo INFINITO bisogna che il primo valore sia
; sempre rimpiazzato dall'ultimo:
;
;	 >>>>>>>>>>>>>>>>>>>>>	
;	^ 		      v
; In questo caso al termine del ciclo viene copiato il primo valore nell'ultimo
; per cui l'afflusso e' costante; la vecchia routine infatti terminava cosi':
;
;	move.w	col1,col14	; col1 copiato in col14
;

Ondula:
	LEA	CON1EFFETTO+8,A0 ; Indirizzo word sorgente in a0
	LEA	CON1EFFETTO,A1	; Indirizzo delle word destinazione in a1
	MOVEQ	#44,D2		; 45 bplcon1 da cambiare in COPLIST
SCAMBIA:
	MOVE.W	(A0),(A1)	; copia due word consecutive - scorrimento!
	ADDQ.W	#8,A0		; prossima coppia di word
	ADDQ.W	#8,A1		; prossima coppia di word
	DBRA	D2,SCAMBIA	; ripeti "SCAMBIA" il numero giusto di VOLTE

	MOVE.W	CON1EFFETTO,ULTIMOVALORE ; per rendere infinito il ciclo
	RTS				; copiamo il primo valore nell'ultimo
					; ogni volta.


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop


	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIOCON1:
	dc.b	$00		; BplCon1 - IL BYTE UTILIZZATO!!!


	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

;	L'effetto nella copperlist: e' composto di un wait e un BPLCON1, i
;	wait aspettano una volta ogni 4 linee: $34,$38,$3c....
;	Nei $dff102 ci sono gia' i valori dell'"ONDA": 1,2,3,4...3,2,1.

	DC.W	$3007,$FFFE,$102
CON1EFFETTO:
	DC.W	$00
	DC.W	$3407,$FFFE,$102,$00
	DC.W	$3807,$FFFE,$102,$00
	DC.W	$3C07,$FFFE,$102,$11
	DC.W	$4007,$FFFE,$102,$11
	DC.W	$4407,$FFFE,$102,$11
	DC.W	$4807,$FFFE,$102,$11
	DC.W	$4C07,$FFFE,$102,$22
	DC.W	$5007,$FFFE,$102,$22
	DC.W	$5407,$FFFE,$102,$22
	DC.W	$5807,$FFFE,$102,$33
	DC.W	$5C07,$FFFE,$102,$33
	DC.W	$6007,$FFFE,$102,$44
	DC.W	$6407,$FFFE,$102,$44
	DC.W	$6807,$FFFE,$102,$55
	DC.W	$6C07,$FFFE,$102,$66
	DC.W	$7007,$FFFE,$102,$77
	DC.W	$7407,$FFFE,$102,$88
	DC.W	$7807,$FFFE,$102,$88
	DC.W	$7C07,$FFFE,$102,$99
	DC.W	$8007,$FFFE,$102,$99
	DC.W	$8407,$FFFE,$102,$aa
	DC.W	$8807,$FFFE,$102,$aa
	DC.W	$8C07,$FFFE,$102,$aa
	DC.W	$9007,$FFFE,$102,$99
	DC.W	$9407,$FFFE,$102,$99
	DC.W	$9807,$FFFE,$102,$88
	DC.W	$9C07,$FFFE,$102,$88
	DC.W	$A007,$FFFE,$102,$77
	DC.W	$A407,$FFFE,$102,$66
	DC.W	$A807,$FFFE,$102,$55
	DC.W	$AC07,$FFFE,$102,$44
	DC.W	$B007,$FFFE,$102,$44
	DC.W	$B407,$FFFE,$102,$33
	DC.W	$B807,$FFFE,$102,$33
	DC.W	$BC07,$FFFE,$102,$22
	DC.W	$C007,$FFFE,$102,$22
	DC.W	$C407,$FFFE,$102,$22
	DC.W	$C807,$FFFE,$102,$11
	DC.W	$CC07,$FFFE,$102,$11
	DC.W	$D007,$FFFE,$102,$11
	DC.W	$D407,$FFFE,$102,$11
	DC.W	$D807,$FFFE,$102,$00
	DC.W	$DC07,$FFFE,$102,$00
	DC.W	$E007,$FFFE,$102,$00
	DC.W	$E407,$FFFE,$102
ULTIMOVALORE:
	DC.W	$00

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Questo effetto di ondulazione e' un classico nell'Amiga. Per risparmiare qua
non ondula ogni linea separatamente ma ogni quattro linee, ma almeno ha una
routine con un loop veloce per scorrere i valori del $102 presenti nella
copperlist.

La routine in questa lezione puo' essere utilizzata per "ruotare" qualsiasi
gruppo di word, dunque puo' servire anche per effetti di scorrimento dei
colori, o qualsiasi altro effetto.

