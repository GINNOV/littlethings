;
; CODICE FISCALE (C)1993 Daniele Paccaloni (DDT / HALF-BRAINS TEAM) !
; Questa e' la piu' veloce routine per calcolare il codice fiscale di
; una persona. La tabella dei comuni puo' essere ampliata a piacere.
; Ovviamente la velocita' non e' indispensabile per calcolare il
; codice fiscale di una sola persona (come avviene adesso in prompt mode)
; ma, aggiustando il tutto per un lavoro batch, sarebbe molto utile a
; qualche ufficio di stato, data la vergognosa lentezza con cui vengono
; svolte molte pratiche :) Se tutti i programmi fossero scritti in
; assembly non ci sarebbe piu' bisogno dei pentium... se non per giocare
; a DOOM !!!
; Divertitevi a scovare il codice fiscale dei vostri amici, li stupirete
; indovinando tutte le cifre.. e anche l'ultima, la piu' difficile !!! :)
; Questo programma puo' dare assuefazione .. !@#?! Tenere lontano dalla
; portata dei bambini piu' piccoli.
;					Daniele

S:

Input:	move.l	$4.w,a6			;Take the execbase address,
	lea	DosName,a1		;open the GFXlibrary {
	jsr	-408(a6)		;}.
	tst.l	d0
	beq.w	Error
	move.l	d0,DosBase		;Save the GFXbase pointer,
	move.l	d0,a6


; COGNOME

	bsr.w	ClrBuf

InputSurn:
	jsr	-60(a6)		; _LVOOutput
	tst.l	d0
	beq.w	Error
	move.l	d0,OutHandler
	move.l	d0,d1
	move.l	#OutText1,d2
	move.l	#EndOutText1-OutText1,d3
	jsr	-48(a6)		; _LVOWrite

	jsr	-54(a6)		; _LVOInput
	tst.l	d0
	beq.w	Error
	move.l	d0,InHandler	; d0=string lenght
	move.l	d0,d1
	move.l	#InputBuffer,d2
	moveq	#80,d3
	jsr	-42(a6)		; _LVORead
	tst.l	d0
	beq.s	InputSurn
	move.l	d0,d1			;Copy string lenght

	bsr.w	Maiuscolo
	bsr.w	EliminaSpazii

	move.w	d1,d0			;Cerca le prime 3 consonanti
	subq.w	#1,d0
	moveq	#3,d4
	lea	InputBuffer(pc),a0
	lea	CODICE(pc),a4
ChkNxtC:
	move.b	(a0)+,d3
	lea	VocalsTab(pc),a2
	moveq	#4,d2
ChkVocC:
	cmp.b	(a2)+,d3
	beq.s	IsVoc
	dbra	d2,ChkVocC
	cmp.b	#10,d3			;Check if EOL
	beq.s	GetVocs
	move.b	d3,(a4)+
	subq.w	#1,d4
	beq.s	NOME
IsVoc:
	dbra	d0,ChkNxtC

GetVocs:
	move.w	d1,d0			;Completa con le vocali
	subq.w	#1,d0
	lea	InputBuffer(pc),a0
ChkNxtV:
	move.b	(a0)+,d3
	lea	VocalsTab(pc),a2
	moveq	#4,d2
ChkVocV:
	cmp.b	(a2)+,d3
	beq.s	YeVoc
	dbra	d2,ChkVocV
	dbra	d0,ChkNxtV
	bra.s	VDone

YeVoc:
	move.b	d3,(a4)+
	subq.w	#1,d4
	beq.s	NOME
	dbra	d0,ChkNxtV
VDone:
PatchX:
	move.b	#"X",(a4)+	;Inserisce le X se necessario
	subq.w	#1,d4
	bne.s	PatchX

;--------------------------------NOME

NOME:
	bsr.w	ClrBuf
InputName:
	jsr	-60(a6)		; _LVOOutput
	tst.l	d0
	beq.w	Error
	move.l	d0,OutHandler
	move.l	d0,d1
	move.l	#OutText2,d2
	move.l	#EndOutText2-OutText2,d3
	jsr	-48(a6)		; _LVOWrite

	jsr	-54(a6)		; _LVOInput
	tst.l	d0
	beq.w	Error
	move.l	d0,InHandler
	move.l	d0,d1
	move.l	#InputBuffer,d2
	moveq	#80,d3
	jsr	-42(a6)		; _LVORead
	tst.l	d0		; d0 = lunghezza stringa
	beq.s	InputName
	move.l	d0,d1			;Copia lunghezza stringa

	bsr.w	Maiuscolo
	bsr.w	EliminaSpazii

; Copia le prime 4 consonanti del nome in ConsNome:

	move.l	d1,d0
	subq.w	#1,d0
	moveq	#4,d4			;Verifica 4 consonanti
	lea	InputBuffer(pc),a0
	lea	ConsNome(pc),a5		;Copia qui le prime 4 conson
NxtLet:
	move.b	(a0)+,d3
	lea	VocalsTab(pc),a2
	moveq	#4,d2
ChkCons:
	cmp.b	(a2)+,d3
	beq.s	NoCon
	dbra	d2,ChkCons
	cmp.b	#10,d3			;Check if EOL
	beq.s	NoCon
	move.b	d3,(a5)+
	subq.w	#1,d4
	beq.s	FourCon
NoCon:
	dbra	d0,NxtLet
	lea	ConsNome(pc),a5		;Indirizzo prime 4 consonanti
	moveq	#3,d0
	sub.w	d4,d0			;d0=numero di consonanti nome
	bpl.s	CPyCon
	subq.w	#1,d4
	bra.s	NoCons
CpyCon:
	move.b	(a5)+,(a4)+
	dbra	d0,CpyCon
	subq.w	#1,d4		;Testa se ci sono 3 consonanti,
	beq.s	DATA		; se si` vai a codificare la data...
NoCons:
	move.w	d1,d0		;Altrimenti completa con vocali:
	subq.w	#1,d0
	lea	InputBuffer(pc),a0
ChkNxtN:
	move.b	(a0)+,d3
	lea	VocalsTab(pc),a2
	moveq	#4,d2
ChkVocN:
	cmp.b	(a2)+,d3
	beq.s	YeVoc2
	dbra	d2,ChkVocN
	dbra	d0,ChkNxtN
	bra.s	VDoneN

YeVoc2:
	move.b	d3,(a4)+
	subq.w	#1,d4
	beq.w	DATA
	dbra	d0,ChkNxtN
VDoneN:
PatchXN:
	move.b	#"X",(a4)+	;Inserisce le X se necessario
	subq.w	#1,d4
	bne.s	PatchXN
	bra.s	SkipHere

; Copia la 1',3',4' consonante nel CODICE

FourCon:
	lea	ConsNome(pc),a5		; Indirizzo prime 4 consonanti
	move.b	(a5),(a4)+		; Copia la prima nel codice
	move.b	2(a5),(a4)+		; Copia la terza nel codica
	move.b	3(a5),(a4)+		; Copia la quarta nel codice
SkipHere:
;------------------------------------DATA DI NASCITA
DATA:
	bsr.w	ClrBuf
InputData:
	jsr	-60(a6)		; _LVOOutput
	tst.l	d0
	beq.w	Error
	move.l	d0,OutHandler
	move.l	d0,d1
	move.l	#OutText3,d2
	move.l	#EndOutText3-OutText3,d3
	jsr	-48(a6)		; _LVOWrite

	jsr	-54(a6)		; _LVOInput
	tst.l	d0
	beq.w	Error
	move.l	d0,InHandler
	move.l	d0,d1
	move.l	#InputBuffer,d2
	moveq	#80,d3
	jsr	-42(a6)		; _LVORead
	tst.l	d0		; d0 = lunghezza stringa
	beq.s	InputData
	cmp.l	#9,d0
	bne.s	InputData
	lea	InputBuffer(pc),a0
	cmp.b	#"/",2(a0)
	bne.s	InputData
	cmp.b	#"/",5(a0)
	bne.s	InputData
	move.b	(a0),d7
	bsr.w	VerifNum
	bne.s	InputData
	move.b	1(a0),d7
	bsr.w	VerifNum
	bne.s	InputData
	move.b	3(a0),d7
	bsr.w	VerifNum
	bne.s	InputData
	move.b	4(a0),d7
	bsr.w	VerifNum
	bne.w	InputData
	move.b	6(a0),d7
	bsr.w	VerifNum
	bne.w	InputData
	move.b	7(a0),d7
	bsr.w	VerifNum
	bne.w	InputData
	move.l	d0,d1			;Copia lunghezza stringa

	cmp.b	#"2",(a0)		;Testa se il giorno e' > 29
	bls.s	OkGg
	cmp.b	#"1",1(a0)		;Se giorno > 31 allora
	bhi.w	InputData		;   reinput...

OkGg:
	move.b	3(a0),d0
	sub.b	#$30,d0
	mulu.w	#10,d0			;moltiplicazione non ottimizz
	add.b	4(a0),d0
	sub.b	#$30,d0
	cmp.b	#12,d0
	bhi.w	InputData

	move.b	6(a0),(a4)+		;Copia le ultime due cifre dell'
	move.b	7(a0),(a4)+		; anno nel codice.

	subq.w	#1,d0			;Sottrae 1 per scostam in tab
	and.w	#$00ff,d0		;Pulisce parte alta di d0
	lea	MonthTab(pc),a2		;a2 punta alla tabella
	move.b	(a2,d0.w),d0		;prende lettera del mese in d0

	move.b	d0,(a4)+		;mette lettera del mese nel cod

	move.b	(a0),d6			;d6.b = cifra decine del giorno
	move.b	1(a0),d7		;d7.b = cifra unita` del giorno
;------------------------------------SESSO
	bsr.w	ClrBuf
InputSesso:
	jsr	-60(a6)		; _LVOOutput
	tst.l	d0
	beq.w	Error
	move.l	d0,OutHandler
	move.l	d0,d1
	move.l	#OutText4,d2
	move.l	#EndOutText4-OutText4,d3
	jsr	-48(a6)		; _LVOWrite

	jsr	-54(a6)		; _LVOInput
	tst.l	d0
	beq.w	Error
	move.l	d0,InHandler
	move.l	d0,d1
	move.l	#InputBuffer,d2
	moveq	#80,d3
	jsr	-42(a6)		; _LVORead
	tst.l	d0		;d0 = lunghezza stringa
	beq.s	InputSesso
	move.l	d0,d1			;Copia lunghezza stringa

	bsr.w	Maiuscolo

	lea	InputBuffer(pc),a2
	cmp.b	#"M",(a2)
	beq.s	Maschio
	cmp.b	#"F",(a2)
	bne.s	InputSesso

	addq.b	#4,d6			;Se e' una femmina aggiungi 4
					; alla cifra delle decine !

Maschio:move.b	d6,(a4)+		;Mette cifra decine del giorno
					;  nel codice,
	move.b	d7,(a4)+		;Mette cifra unita` del giorno
					;  nel codice.

;------------------------------------COMUNE
	bsr.w	ClrBuf
InputComune:
	jsr	-60(a6)		; _LVOOutput
	tst.l	d0
	beq.w	Error
	move.l	d0,OutHandler
	move.l	d0,d1
	move.l	#OutText5,d2
	move.l	#EndOutText5-OutText5,d3
	jsr	-48(a6)		; _LVOWrite

	jsr	-54(a6)		; _LVOInput
	tst.l	d0
	beq.w	Error
	move.l	d0,InHandler
	move.l	d0,d1
	move.l	#InputBuffer,d2
	moveq	#80,d3
	jsr	-42(a6)		; _LVORead
	tst.l	d0		; d0 = lunghezza stringa
	beq.s	InputComune
	move.l	d0,d1			;Copia lunghezza stringa

	bsr.w	Maiuscolo

	lea	ComuniTab(pc),a3
SrchNxt:
	lea	InputBuffer(pc),a2
	move.l	d0,d1
	subq.w	#1,d1
CmpCom:
	move.b	(a2)+,d2
	cmp.b	(a3)+,d2
	bne.s	NoThiz
	dbra	d1,CmpCom
	bra.s	ComFound

NoThiz:
	cmp.b	#10,(a3)+
	bne.s	NoThiz
	addq.w	#4,a3
	cmp.l	#ComuniTabEnd,a3
	bne.s	SrchNxt

;Non trovato; inserire il codice fiscale

InputCodiceCom:
	jsr	-60(a6)		; _LVOOutput
	tst.l	d0
	beq.w	Error
	move.l	d0,OutHandler
	move.l	d0,d1
	move.l	#OutText6,d2
	move.l	#EndOutText6-OutText6,d3
	jsr	-48(a6)		; _LVOWrite
	jsr	-54(a6)		; _LVOInput
	tst.l	d0
	beq.w	Error
	move.l	d0,InHandler
	move.l	d0,d1
	move.l	#InputBuffer,d2
	moveq	#80,d3
	jsr	-42(a6)			;d0 = lunghezza stringa
	tst.l	d0
	beq.s	InputCodiceCom
	cmp.b	#5,d0			;Lunghezza codice = 4 cifre
	bne.s	InputCodiceCom
	lea	InputBuffer(pc),a3
	bclr.b	#5,(a3)			;Lettera codice maiuscola
ComFound:
	move.b	(a3)+,(a4)+		;Copia codice comune
	move.b	(a3)+,(a4)+		;   nel codice fiscale
	move.b	(a3)+,(a4)+
	move.b	(a3)+,(a4)+

;------------------------------COMPUTA CARATTERE DI CONTROLLO

	lea	CODICE+1(pc),a0
	moveq	#6,d5
	moveq	#0,d7
ParLop:
	move.b	(a0),d6
	cmp.b	#"9",d6
	bls.s	PNum
	sub.b	#"A"-"0",d6
PNum:
	sub.b	#"0",d6
	ext.w	d6
	add.w	d6,d7
	addq.w	#2,a0
	dbra	d5,ParLop

	lea	CODICE(pc),a0
	lea	CtrlTab(pc),a2
	moveq	#7,d5
DisLop:
	moveq	#0,d6
	move.b	(a0),d6
	cmp.b	#"9",d6
	bls.s	DNum
	sub.b	#"A"-"0",d6
DNum:
	sub.b	#"0",d6
	lsl.w	#1,d6
	add.w	(a2,d6.w),d7
	addq	#2,a0
	dbra	d5,DisLop

	divu.w	#26,d7
	swap	d7
	add.b	#"A",d7
	move.b	d7,(a4)

;------------------------------STAMPA CODICE

	move.l	DosBase(pc),a6
	jsr	-60(a6)		; _LVOOutput - Stampa il codice fiscale
	tst.l	d0
	beq.s	Error
	move.l	d0,OutHandler
	move.l	d0,d1
	move.l	#CODICE,d2
	moveq	#17,d3
	jsr	-48(a6)		; _LVOWrite

Error:
	move.l	$4.w,a6			;Indirizzo Execbase,
	move.l	DosBase(pc),a1
	jsr	-414(a6)		;Chiude la libreria DOS
	rts



;---- SOUBROUTINE MAIUSCOLO --------
; Parametri:	d0.w = numero caratteri

Maiuscolo:
	movem.l	d0/a0,-(sp)
	subq.w	#1,d0
	lea	InputBuffer(pc),a0
Caps:
	cmp.b	#" ",(a0)
	bne.s	OkM
	addq.w	#1,a0
	bra.s	After

OkM:
	bclr.b	#5,(a0)+
After:
	dbra	d0,Caps
	movem.l	(sp)+,d0/a0
	rts


;---- SOUBROUTINE ELIMINASPAZII --------
; Parametri:	[nessuno]

EliminaSpazii:
	movem.l	d0/a0/a1/a2,-(sp)
	lea	InputBuffer(pc),a0
HuntS:
	move.b	(a0),d6
	cmp.b	#10,d6
	beq.s	EDone
	cmp.b	#" ",d6
	beq.s	Argh
	addq.w	#1,a0
	bra.s	HuntS

Argh:
	move.l	a0,a1
	move.l	a0,a2
Yop:
	addq.w	#1,a2
	move.b	(a2),(a1)+
	cmp.b	#10,(a2)
	beq.s	SEOL
	bra.s	Yop

SEOL:
	addq.w	#1,a0
	bra.s	HuntS
EDone:
	movem.l	(sp)+,d0/a0/a1/a2
	rts


;---- SOUBROUTINE CLEAR BUFFER --------
; Parametri:	nessuno

ClrBuf:
	lea	InputBuffer(pc),a0
	moveq	#(80/4)-1,d0
ClrB:
	clr.l	(a0)+
	dbra	d0,ClrB
	rts

;---- SOUBROUTINE VERIFICA NUMERO --------
; Parametri:	d7.b = carattere da verificare
; Risultato:	Zflag settato se uguale

VerifNum:
	cmp.b	#$30,d7
	bhi.s	OKBnd1
	rts

OkBnd1:
	cmp.b	#$39,d7
	bhi.s	ExitVM
	moveq	#0,d7
ExitVM:
	rts

;---------------------------------------------------
DosName:	dc.b	"dos.library",0
DosBase:	dc.l	0

OutHandler:	dc.l	0
InHandler:	dc.l	0

OutText1:	dc.b	10,$9b,'33',$6d,"  CODICE FISCALE ",$9b,'31',$6d,"di D.Paccaloni & T.Labruzzo"
		dc.b	10,10,"COGNOME > "
EndOutText1:
OutText2:	dc.b	10,"NOME > "
EndOutText2:
OutText3:	dc.b	10,"DATA DI NASCITA (gg/mm/aa) > "
EndOutText3:
OutText4:	dc.b	10,"SESSO > "
EndOutText4:
OutText5:	dc.b	10,"COMUNE DI NASCITA > "
EndOutText5:
OutText6:	dc.b	10,"Codice comune non trovato, inserirlo (4 cifre) > "
EndOutText6:

	even

InputBuffer:	dcb.b	80,0

VocalsTab:	dc.b	"AEIOU"

MonthTab:	dc.b	"ABCDEHLMPRST"

		; Tabella dei comuni, da ampliare se necessario !
ComuniTab:	dc.b	"AREZZO",10,"A390"
		dc.b	"ASCOLI PICENO",10,"A462"
		dc.b	"ASTI",10,"A479"
		dc.b	"BARI",10,"A662"
		dc.b	"BERGAMO",10,"A794"
		dc.b	"BOLOGNA",10,"A944"
		dc.b	"BRESCIA",10,"B157"
		dc.b	"CATANIA",10,"C351"
		dc.b	"CATANZARO",10,"C352"
		dc.b	"COMO",10,"C933"
		dc.b	"FERRARA",10,"D548"
		dc.b	"IMPERIA",10,"E290"
		dc.b	"LA SPEZIA",10,"E463"
		dc.b	"LECCE",10,"E506"
		dc.b	"MILANO",10,"F205"
		dc.b	"NAPOLI",10,"F839"
		dc.b	"PALERMO",10,"G273"
		dc.b	"PISA",10,"G702"
		dc.b	"ROMA",10,"H501"
		dc.b	"SIRACUSA",10,"I754"
		dc.b	"TORINO",10,"L219"
		dc.b	"TRIESTE",10,"L424"
		dc.b	"TRENTO",10,"L378"
		dc.b	"UDINE",10,"L483"
		dc.b	"VENEZIA",10,"L736"
		dc.b	"VERONA",10,"L781"
ComuniTabEnd:

		even
CtrlTab:	dc.w	1,0,5,7,9,13,15,17,19,21,2,4,18,20,11,3,6,8
		dc.w	12,14,16,10,22,25,24,23

		even
ConsNome:	dcb.b	4,0

CODICE:		dcb.b	16,0	;16 caratteri
		dc.b	10	;EOL


	end

