; $VER: AssExtra.asm 4.46 (30.12.14)
; **********************************************
;
;             PhxAss Macro Assembler
;
;        Written by Frank Wille, 1991-2014
;
; Extra-Routinen, die nicht oft benötigt werden
;
; **********************************************

	far				; Large Code/Data-Model

	include	"AssDefs.i"		; Strukturen und Definitionen einlesen


	ttl	"PhxAss - Extra routines"


; ************
; CODE-Segment
; ************

	section	Extra,code

FARLOCS	set	1			; LocStr über Stub-Funktion aufrufen


; *** Cross-References ***


; ** XREFs **
; von AssMain.o
	xref	Error			; d0=ErrNum
	xref	fprintf			; d0=FileHandle, a0=FormatString, a1=DataStream
	xref	PageTitle
	xref	GetSysTime
	xref	CleanUp

; von Assemble.o
	xref	ReadArgument		; a0=SrcBuf,a1=DestBuf,d0=DestSize, -> d0=ReadBytes
	xref	FindGorLSymbol		; a0=Name, -> d0=Symbol
	xref	AddReference		; a0=Symbol,d0=RefType,d1=RefAddr
	xref	LocStr			; d0=StringID, -> a0=LocaleString

; ** XDEFs **

	xdef	CheckCont
	xdef	GetFloatExpression	; a2=Input,a3=Buffer,d7=StkArgs,
	; ->d0/d1=DoublePrec,d2=Error,a2=NewInput
	xdef	FloatConversion		; d0/d1=DoublePrec,d7=ConversionSize,
	; ->d0=Float/Pointer,d2=Error
	xdef	XRefFile
	xdef	EquatesFile



CheckCont:
; Gibt "do you want to continue" aus, und wartet auf Bestätigung
	movem.l	d2-d5/a6,-(sp)
	move.l	DosBase(a5),a6
	move.l	StdOut(a5),d4
	move.l	d4,d1
	jsr	IsInteractive(a6)
	tst.l	d0			; ist kein Shell-Fenster?
	beq.s	1$
	move.l	d4,d1
	LOCS	S_CONT			; Continue?
	move.l	a0,d2
	moveq	#-1,d3
3$:	tst.b	(a0)+
	dbeq	d3,3$
	not.l	d3
	jsr	Write(a6)
	moveq	#-1,d0
	bsr.s	pass_console_packet	; switch CON: to RAW:
	clr.l	-(sp)
	move.l	d4,d1
	move.l	sp,d2
	addq.l	#3,d2
	moveq	#4,d3
	jsr	Read(a6)		; nächsten RAW: Tastendruck lesen
	move.l	(sp)+,d5
	moveq	#0,d0
	bsr.s	pass_console_packet	; wieder zu CON: zurückkehren
	move.l	d4,d1
	lea	2$(pc),a0
	move.l	a0,d2
	moveq	#4,d3
	jsr	Write(a6)
	moveq	#-$21,d0		; Antwort-Char nach UpperCase
	and.b	d0,d5
	LOCS	S_YES			; Locale-Taste für (Y)es holen
	cmp.b	(a0),d5			; Positiv bestätigt?
	beq.s	1$
	move.l	CleanUpLevel(a5),sp
	jmp	CleanUp			; PhxAss verlassen !
1$:	movem.l	(sp)+,d2-d5/a6
	rts

2$:	dc.b	13,$1B,"[K"		; ClearEOL
	even

pass_console_packet:
; d0 = packet
; d4 = FileHandle
; a6 = DosBase
	movem.l	d2-d3/d7/a2-a3,-(sp)
	move.l	d0,d7
	clr.l	-(sp)			; TAG_DONE
	move.l	#DOS_STDPKT,d1
	jsr	AllocDosObject(a6)	; StdPacket/Message besorgen
	addq.l	#4,sp
	tst.l	d0
	beq	1$
	move.l	d0,a3
	move.l	SysBase(a5),a6
	move.l	myTask(a5),a2
	lea	pr_MsgPort(a2),a2
	move.l	dp_Link(a3),a1		; Message
	move.l	a2,mn_ReplyPort(a1)
	move.l	a2,dp_Port(a3)
	move.l	#ACTION_SCREEN_MODE,dp_Type(a3)
	move.l	d7,dp_Arg1(a3)
	move.l	d4,a0
	add.l	a0,a0
	add.l	a0,a0
	move.l	fh_Type(a0),a0
	jsr	PutMsg(a6)
2$:	move.l	a2,a0
	jsr	WaitPort(a6)
	move.l	a2,a0
	jsr	GetMsg(a6)
	tst.l	d0
	beq.s	2$
	move.l	DosBase(a5),a6
	move.l	#DOS_STDPKT,d1
	move.l	a3,d2
	jsr	FreeDosObject(a6)
1$:	movem.l	(sp)+,d2-d3/d7/a2-a3
	rts


	IFND	SMALLASS
	cnop	0,4
GetFloatExpression:
; Argumente und Operatoren einer Ebene miteinander verknüpfen
; (Rekursionsfähig)
; a2 = Input
; a3 = Buffer
; a4 = Expression Stack
; d7 = Zahl der Arg. auf dem Stack aus übergeordneten Ebenen
; -> d0/d1 = 64 Bit IEEE Double Precision
; -> d2 = 0 oder -1 = Error
; -> a2 = NewInputPos
	movem.l	d3-d5,-(sp)
	moveq	#-1,d5			; d5 zählt die verbleibenden Operationen

gfexp_BuildStack:
	; Stack aufbauen
	moveq	#0,d2			; d2 noch keine Unäre Operation
	moveq	#0,d3			; d3 noch keine Negation
1$:	move.l	a2,a0
	move.l	a3,a1
	move.w	#BUFSIZE-1,d0
	jsr	ReadArgument
	beq.s	3$			; auf Negierung oder Klammerterm checken
	cmp.w	#3,d0
	bne	gfexp_ArgGot		; Länge 3 könnte unärer Op. sein, sonst Arg.
	move.l	(a3),d1
	and.l	#$dfdfdf00,d1		; Prüfen ob's einer der unären Ops ist
	moveq	#5,d4
	lea	gfexp_unaries(pc),a0
2$:	cmp.l	(a0)+,d1
	dbeq	d4,2$
	bne	gfexp_ArgGot		; ist wohl'n normales Argument
	tst.w	d2			; schon ein unärer Operator vorhanden?
	bne.s	5$
	move.b	gfexp_unaryOffset(pc,d4.w),d2
	ext.w	d2
	add.w	d0,a2			; InputStreamPointer weiterruecken
	cmp.b	#':',(a2)		; Trennzeichen für Folge-Argument?
	bne.s	1$
	addq.l	#1,a2			; überlesen
	bra.s	1$
3$:	move.b	(a2)+,d0
	tst.w	d3
	bne.s	4$			; Doppelte Negations-Operation nicht möglich
	cmp.b	#'+',d0			; Pluszeichen ignorieren
	beq.s	1$
	cmp.b	#'-',d0			; Negate-Operator vor dem Symbol
	bne.s	4$
	moveq	#1,d3			; d3 positiv = IEEEDPNeg aufrufen
	bra.s	1$
4$:	cmp.b	#'[',d0			; Klammerterm ?
	beq	gfexp_Term
	cmp.b	#'(',d0
	beq	gfexp_Term
5$:	cmp.b	#':',d0			; #:3fe00000 etc. - Motorola Syntax?
	bne.s	6$
	move.b	#'$',-(a2)		; : durch $ ersetzen
	bra.s	1$
6$:	moveq	#46,d0			; Missing argument
	bsr	Error2
	tst.w	d5
	bmi	gfexp_error
	addq.l	#2,a4			; Operator loeschen (da Argument fehlt)
	bra	gfexp_Calc

gfexp_unaryOffset:
	dc.b	IEEEDPSqrt,IEEEDPLog,IEEEDPExp,IEEEDPTan,IEEEDPCos,IEEEDPSin
	cnop	0,4
gfexp_unaries:
	dc.l	"SIN\0","COS\0","TAN\0","EXP\0","LOG\0","SQR\0"

gfexp_Term:
	movem.l	d2-d3,-(sp)
	bsr	GetFloatExpression	; REKURSION
	tst.w	d2			; Fehler im Term ?
	beq.s	1$
	addq.l	#8,sp
	bra	gfexp_error
1$:	cmp.b	#')',(a2)		; Term wurde mit Klammer-Zu beendet ?
	beq.s	2$
	cmp.b	#']',(a2)
	beq.s	2$
	addq.l	#8,sp
	moveq	#50,d0			; Missing bracket/parenthesis
	bra	gfexp_Err
2$:	addq.l	#1,a2
	movem.l	(sp)+,d2-d3		; EQU
	bra.s	gfexp_AddArg

gfexp_RestOfArg:
	; Float-Rest hinter '.' o.ä. besorgen
	move.w	d0,d4
	lea	(a3,d0.w),a1
	move.b	(a2)+,(a1)+
	move.l	a2,a0
	neg.w	d0
	add.w	#BUFSIZE-3,d0
	jsr	ReadArgument
	add.w	d0,a2
	add.w	d4,d0
	addq.w	#1,d0
	rts

gfexp_ArgGot:
	add.w	d0,a2			; InputStreamPointer weiterrücken
4$:	move.b	(a2),d1
	sub.b	#'$',d1			; Local-Symbol ?
	bne.s	1$
	move.b	(a2)+,(a3,d0.w)		; '$' hinzufügen
	clr.b	1(a3,d0.w)
	bra.s	3$
1$:	subq.b	#7,d1			; '+' könnte Teil eines Exponents sein
	beq.s	2$
	subq.b	#2,d1			; '-' könnte Teil eines Exponents sein
	beq.s	2$
	subq.b	#1,d1			; '.' Dezimalpunkt mitnehmen
	bne.s	3$
	bsr.s	gfexp_RestOfArg
	bra.s	4$
2$:	moveq	#-$21,d1
	and.b	-1(a2),d1
	cmp.b	#'E',d1			; Exponent?
	bne.s	3$
	move.b	(a3),d1			; handelt es sich um einen numerischen Ausdr.?
	cmp.b	#'0',d1
	blo.s	3$
	cmp.b	#'9',d1
	bhi.s	3$			; ... dann kann es nur ein Exponent sein!
	bsr.s	gfexp_RestOfArg
3$:	move.l	a3,a0
	bsr	GetFloat		; Fließkommazahl oder Symbol lesen
	beq	gfexp_error

gfexp_AddArg:
	; neues Argument auf Expression-Stack legen
	move.l	a6,d4
	tst.w	d2			; Unären Operator ausführen
	beq.s	1$
	move.l	MathIEEETransBase(a5),a6 ; Transzendente Funktion
	jsr	(a6,d2.w)
	bsr.s	gfexp_chkover
	bne.s	1$
	move.l	d4,a6
	moveq	#85,d0			; Overflow during Float calculation!
	bra	gfexp_Err
1$:	tst.w	d3			; Negation ausführen?
	beq.s	2$
	move.l	MathIEEEBase(a5),a6
	jsr	IEEEDPNeg(a6)
2$:	move.l	d4,a6
	movem.l	d0-d1,-(a4)		; IEEEDP-Value auf Expression-Stack legen
	addq.w	#1,d5
	addq.w	#1,d7
	cmp.w	#((EXP_MAXARGS-1)*6)/10,d7 ; Noch Platz auf dem Stack ?
	blo.s	gfexp_Operator
	moveq	#51,d0			; Expression stack overflow
	bra	gfexp_Err
gfexp_chkover:
	move.l	d0,d2
	bclr	#31,d2
	cmp.l	#$7ff00000,d2
	rts

	cnop	0,4
gfexp_Ops:
	dc.b	"^/*-+",0
gfexp_OpOffs:
	dc.b	IEEEDPAdd,IEEEDPSub,IEEEDPMul,IEEEDPDiv,-IEEEDPPow
gfexp_OpPris:
	dc.b	0,0,1,1,2

gfexp_Operator:
	move.b	(a2)+,d0		; Operator holen
	beq.s	2$
	lea	gfexp_Ops(pc),a0
	moveq	#5-1,d1			; 5 Operatoren checken
1$:	cmp.b	(a0)+,d0
	dbeq	d1,1$
	bne.s	2$			; kein Operator? (Expression zuende)
	move.b	gfexp_OpOffs(pc,d1.w),-(a4) ; Offset und Priorität auf Exp.Stack
	move.b	gfexp_OpPris(pc,d1.w),-(a4)
	bra	gfexp_BuildStack	;  und nächstes Argument holen
2$:	subq.l	#1,a2			; kein Operator da - Expression zuende !!

gfexp_Calc:
	movem.l	a2-a3,-(sp)
	move.w	d5,a2
	mulu	#10,d5
	lea	8(a4,d5.w),a3		; Zeiger auf erstes Byte nach Expression stack
	moveq	#2,d4			; erste zu bearbeitende Priorität

gfexp_CalcLoop:
	move.l	a3,a0
	move.w	a2,d5
	beq	gfexp_finished		; Ergebnis zurückgeben ?
gfexp_OpLoop:
	lea	-10(a0),a0		; Zeiger auf nächsten Operator
	cmp.b	(a0),d4			; Operation ausführen (da Priorität stimmt)?
	beq.s	1$
	subq.w	#1,d5
	bne.s	gfexp_OpLoop
	dbf	d4,gfexp_CalcLoop	; Nächsten Operator-Typ suchen und ausführen
	bra	gfexp_finished
1$:	lea	2(a0),a1		; a1 hierher wird nachher aufgerückt
	subq.l	#8,a0
	movem.l	(a1),d0-d1		; d0/d1 Value1
	movem.l	(a0),d2-d3		; d2/d3 Value2
	movem.l	d4/a0-a1/a6,-(sp)
	move.l	MathIEEEBase(a5),a6
	move.b	-1(a1),d4		; Offset
	ext.w	d4
	bmi.s	2$
	move.l	MathIEEETransBase(a5),a6
	neg.w	d4
2$:	jsr	(a6,d4.w)		; Operation ausführen
	movem.l	(sp)+,d4/a0-a1/a6
	bsr	gfexp_chkover
	bne.s	5$
	movem.l	(sp)+,a2-a3
	moveq	#85,d0			; Overflow during Float calculation
	bra	gfexp_Err
5$:	movem.l	d0-d1,(a1)		; Ergebnis speichern
	move.l	a1,d0
	addq.l	#8,d0
	subq.w	#1,d7			; 1 Argument weniger auf dem Stack
	bra.s	4$
3$:	move.w	-(a0),-(a1)		; Rest des Stacks eine Position aufrücken
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
4$:	cmp.l	a4,a0
	bne.s	3$
	lea	10(a4),a4		; Stack-Ende verschieben
	subq.w	#1,a2			; Eine Operation weniger
	move.l	d0,a0
	subq.w	#1,d5
	bne	gfexp_OpLoop		; noch eine Operation auszuführen ?
	dbf	d4,gfexp_CalcLoop	; Nächsten Operator-Typ suchen und ausführen

gfexp_finished:
	movem.l	(sp)+,a2-a3
	movem.l	(a4),d0-d1		; Ergebnis vom Expression Stack nehmen
	addq.l	#8,a4
	subq.w	#1,d7
	moveq	#0,d2			; kein Fehler
	movem.l	(sp)+,d3-d5
	rts

gfexp_Err:
	bsr	Error2
gfexp_error:
	movem.l	(sp)+,d3-d5
	moveq	#0,d0
	moveq	#0,d1
	moveq	#-1,d2			; Error
	rts


	cnop	0,4
GetFloat:
; ASCII-Fließkommazahl lesen und nach IEEE Double Precision wandeln
;  Der ASCII-String muss folgendes Format haben: [-]xxxx[.yyyy[E[-]zzzz]]
; a0 = Float-String
; -> d0/d1 = 64 Bit Double Precision Fließkommazahl
; -> Z=1 : Error
	movem.l	d2-d7/a2-a4/a6,-(sp)
	move.l	sp,d0
	lea	-10(sp),sp
	move.l	sp,a4			; a4 10 Bytes Stack Frame
	move.l	d0,6(a4)
	move.l	a0,a2			; a2 Float String
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a2),d0
	beq	getf_exit
	cmp.b	#'0',d0			; Fliesskommazahl darf mit
	blo.s	1$			; '0'-'9' , '+' , '-' oder '.' beginnen
	cmp.b	#'9',d0
	bls	getf_ReadASCII
1$:	sub.b	#'$',d0			; Float ist als Hexadezimalzahl gegeben?
	bne.s	2$
	bsr.s	getf_Hex
	bra.s	4$
2$:	subq.b	#7,d0			; '+'
	beq	getf_ReadASCII
	subq.b	#2,d0			; '-'
	beq	getf_ReadASCII
	subq.b	#1,d0			; '.'
	beq	getf_ReadASCII

	move.l	a2,a0			; ** Wert eines Float-Symbols bestimmen **
	jsr	FindGorLSymbol
	beq	getf_exit		; nicht gefunden ?
	move.l	d0,a0
	move.w	sym_Type(a0),d2
	move.w	#T_EQU|T_SET|T_FFP|T_SINGLE|T_DOUBLE|T_EXTENDED|T_PACKED,d0
	and.w	d2,d0
	bne.s	3$
	moveq	#86,d0			; Illegal symbol type in float expression
	bra	getf_error
3$:	move.w	RefType(a5),d0		; Referenz auf Float-Symbol eintragen
	move.l	d6,d1			; RelAddr
	jsr	AddReference
	move.l	sym_Value(a0),a1	; Value (oder Pointer)
4$:	move.w	d2,d0
	and.w	#~(T_EQU|T_SET),d0
	bsr	Conv2Double		; Float-Typ nach DoublePrec konvertieren
	bra	getf_exit

getf_Hex:
; a2 = InputPos
; -> a1 = FFP,Single oder Zeiger auf Extended, Packed oder Double
; -> d2 = Type
	addq.l	#1,a2			; '$' ueberspringen
	lea	FloatBuffer(a5),a0
	move.l	a0,a1
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)
	moveq	#'0',d2
	moveq	#'9',d3
	moveq	#'A',d4
	moveq	#'F',d5
	moveq	#-$10,d7
1$:	move.b	(a2)+,d0
	cmp.b	d2,d0			; Testen ob Char zwischen 0 und 9 liegt
	blo.s	3$
	cmp.b	d3,d0
	bls.s	2$
	and.b	#$df,d0
	cmp.b	d4,d0			; Testen ob Char zwischen A und F liegt
	blo.s	3$
	cmp.b	d5,d0
	bhi.s	3$
	subq.b	#7,d0
2$:	moveq	#15,d6
	and.b	d6,d0			; Neue Hex-Ziffer anhaengen
	lea	8(a1),a0
	move.l	(a0),d1
	rol.l	#4,d1
	and.b	d1,d6
	and.b	d7,d1
	or.b	d0,d1
	move.l	d1,(a0)
	move.l	-(a0),d0
	rol.l	#4,d0
	moveq	#15,d1
	and.b	d0,d1
	and.b	d7,d0
	or.b	d6,d0
	move.l	d0,(a0)
	move.l	-(a0),d0
	lsl.l	#4,d0
	or.b	d1,d0
	move.l	d0,(a0)
	bra.s	1$
3$:	moveq	#0,d0
	move.b	OpcodeSize(a5),d0	; Float-Type (4, 8, oder 12 Bytes ?)
	move.w	d0,d2
	add.w	d2,d2
	move.w	9$-2*os_FFP(pc,d2.w),d2	; d2 Type
	subq.b	#os_DOUBLE,d0
	bhi.s	5$
	beq.s	4$
	move.l	8(a1),a1		; 4 Byte Float direkt zurueckgeben
	rts
4$:	addq.l	#4,a1
5$:	rts
9$:	dc.w	T_FFP,T_SINGLE,T_DOUBLE,T_EXTENDED,T_PACKED

getf_ReadASCII:
	move.l	MathIEEEBase(a5),a6
	move.l	#$40240000,a3		; Bits 63-32 von '10' in IEEE DoublePrecision
	moveq	#0,d4			; d4/d5 = Integer Anteil (default 0)
	moveq	#0,d5
	moveq	#0,d6			; d6/d7 = Fraction (default 0)
	moveq	#0,d7
	clr.b	2(a4)			; Vorzeichen
	move.b	(a2)+,d0
	cmp.b	#'0',d0
	blo.s	1$
	cmp.b	#'9',d0
	bls.s	getf_shiftint
1$:	cmp.b	#'.',d0			; Integer Anteil = 0 ? (z.B. ".125")
	beq.s	getf_fraction
	cmp.b	#'+',d0
	beq.s	getf_integer
	cmp.b	#'-',d0			; Negative Zahl ?
	bne	getf_syntaxerr
	st	2(a4)

getf_integer:
	move.b	(a2)+,d0
	beq	getf_convert
	cmp.b	#'0',d0
	blo.s	getf_intfinish
	cmp.b	#'9',d0
	bhi.s	getf_intfinish
getf_shiftint:
	move.w	d0,(a4)
	move.l	d4,d0
	move.l	d5,d1
	move.l	a3,d2
	moveq	#0,d3
	jsr	IEEEDPMul(a6)		; Integer * 10
	move.l	d0,d4
	move.l	d1,d5
	moveq	#15,d0
	and.w	(a4),d0
	jsr	IEEEDPFlt(a6)
	move.l	d4,d2
	move.l	d5,d3
	jsr	IEEEDPAdd(a6)		; Neue Integer-Ziffer addieren
	move.l	d0,d4
	move.l	d1,d5
	bra.s	getf_integer
getf_intfinish:
	cmp.b	#'.',d0			; folgt noch Fraction ?
	bne.s	getf_fracfinish

getf_fraction:
	move.b	(a2)+,d0		; Ende der Fraction-Zahl suchen
	beq.s	1$
	cmp.b	#'0',d0
	blo.s	1$
	cmp.b	#'9',d0
	bls.s	getf_fraction
1$:	subq.l	#1,a2
	move.l	a2,-(sp)
	bra.s	3$
2$:	moveq	#$0f,d0
	and.b	d1,d0
	jsr	IEEEDPFlt(a6)
	move.l	d6,d2
	move.l	d7,d3
	jsr	IEEEDPAdd(a6)		; Ziffer auf Fraction addieren und /10 teilen
	move.l	a3,d2
	moveq	#0,d3
	jsr	IEEEDPDiv(a6)
	move.l	d0,d6
	move.l	d1,d7
3$:	move.b	-(a2),d1
	cmp.b	#'.',d1
	bne.s	2$
	move.l	(sp)+,a2
	move.l	d4,d0
	move.l	d5,d1
	move.l	d6,d2
	move.l	d7,d3
	jsr	IEEEDPAdd(a6)		; Integer + Fraction
	move.l	d0,d4
	move.l	d1,d5
	move.b	(a2)+,d0
	beq	getf_convert
getf_fracfinish:
	and.b	#$df,d0			; hinter Fraction könnte der Exponent folgen
	cmp.b	#'E',d0
	bne	getf_syntaxerr
	clr.b	3(a4)			; default: Exponent positiv
	moveq	#3,d6			; Exponent darf höchstens 3 Ziffern haben
	move.b	(a2),d0
	cmp.b	#'0',d0
	blo.s	1$
	cmp.b	#'9',d0
	bls.s	4$
1$:	cmp.b	#'-',d0			; negativer Exponent ?
	bne.s	2$
	st	3(a4)
	bra.s	3$
2$:	cmp.b	#'+',d0
	bne	getf_syntaxerr
3$:	addq.l	#1,a2
4$:	move.b	(a2)+,d0
	beq.s	5$
	subq.w	#1,d6
	bmi	getf_overflow		; mehr als 3 Ziffern ?
	cmp.b	#'0',d0
	blo.s	5$
	cmp.b	#'9',d0
	bls.s	4$
5$:	subq.l	#1,a2
	movem.l	d4-d5/a2,-(sp)
	lea	dprec_tab(pc),a3
	movem.l	(a3)+,d6-d7		; 1.0
	bra.s	getf_exponent

	cnop	0,4
dprec_tab:
	dc.l	$3ff00000,$00000000	; 1E0	       = 1
	dc.l	$40240000,$00000000	; 1E1	       = 10
	dc.l	$4202a05f,$20000000	; 1E10   = 10000000000
	dc.l	$54b249ad,$2594c379	; 1E100  = 1(HUNDERT x '0')

getf_chkover:
	; Double Prec auf Overflow testen
	move.l	d0,-(sp)
	bclr	#31,d0
	cmp.l	#$7ff00000,d0
	beq.s	getf_overflow
	move.l	(sp)+,d0
	rts
getf_overflow:
	moveq	#85,d0			; Overflow during Float calculation!
	bra	getf_error
getf_exploop:
	movem.l	(a3)+,d4-d5
	movem.l	dprec_tab(pc),d0-d1	; 1.0
	move.l	d6,-(sp)
	moveq	#15,d6
	and.b	d2,d6
	bra.s	2$
1$:	move.l	d4,d2			; letzte Ziffer * 1E1
	move.l	d5,d3			; vorletzte Ziffer * 1E10
	jsr	IEEEDPMul(a6)		; und vorvorletzte Ziffer * 1E100
	bsr.s	getf_chkover
2$:	dbf	d6,1$
	move.l	(sp)+,d6
	move.l	d6,d2
	move.l	d7,d3
	jsr	IEEEDPMul(a6)
	bsr.s	getf_chkover
	move.l	d0,d6
	move.l	d1,d7
getf_exponent:
	move.b	-(a2),d2
	cmp.b	#'0',d2
	blo.s	1$
	cmp.b	#'9',d2
	bls.s	getf_exploop
1$:	movem.l	(sp)+,d0-d1/a2
	addq.l	#1,a2
	move.l	d6,d2
	move.l	d7,d3
	tst.b	3(a4)			; positiver oder negativer Exponent
	beq.s	2$
	jsr	IEEEDPDiv(a6)		; negativ = Dividieren
	bra.s	3$
2$:	jsr	IEEEDPMul(a6)		; positiv = Multiplizieren
3$:	move.l	d0,d4
	move.l	d1,d5

getf_convert:
	subq.l	#1,a2
	tst.b	2(a4)			; war die Zahl negativ ?
	beq.s	1$
	bset	#31,d4
1$:	move.l	d4,d0
	move.l	d5,d1
getf_exit:
	; Double Prec in d0/d1 zurückgeben
	moveq	#-1,d2			; kein Fehler! (Z-Flag löschen)
getf_x:
	move.l	6(a4),sp
	movem.l	(sp)+,d2-d7/a2-a4/a6
	rts
getf_syntaxerr:
	moveq	#41,d0			; Syntax error in operand
getf_error:
; d0 = Error
	bsr	Error2
	moveq	#0,d2			; Z-Flag! (Fehler)
	bra.s	getf_x


	cnop	0,4
Conv2Double:
; a1 = 32-Bit Float oder Zeiger auf 64/96-Bit Float (je nach Typ)
; d0 = Type (FFP,SINGLE,DOUBLE,EXTENDED,PACKED,SET,EQU)
; ACHTUNG! Es MUSS unbedingt vorher geprüft worden sein, ob es sich wirklich
; um die Integer-Typen SET/EQU handelt. ABS, DIST, etc. sind VERBOTEN!
; -> d0/d1 = Double Precision
; -> Z-Flag = Error
	movem.l	d2-d4/a6,-(sp)
	cmp.w	#T_DOUBLE,d0		; ist schon Double Prec?
	bne.s	2$
	movem.l	(a1),d0-d1		; fertig!
	bra.s	1$
2$:	cmp.w	#T_FFP,d0		; FastFloatingPoint?
	bne.s	3$
	move.l	a1,d0
	move.l	MathFFPTransBase(a5),a6
	jsr	SPTieee(a6)		; nach Single Prec konvertieren
	bra.s	4$
3$:	cmp.w	#T_SINGLE,d0		; Single Prec?
	bne.s	5$
	move.l	a1,d0
4$:	move.l	MathIEEETransBase(a5),a6
	jsr	IEEEDPFieee(a6)		; nach Double Prec konvertieren
1$:	moveq	#-1,d2			; kein Fehler
	movem.l	(sp)+,d2-d4/a6
	rts
5$:	cmp.w	#T_EXTENDED,d0
	bne.s	10$
	move.l	(a1)+,d2		; 96-Bit Extended Prec
	movem.l	(a1),d0-d1
	bclr	#31,d0			; Explicit Integer Bit löschen
	move.l	d0,d3
	or.l	d1,d3
	or.l	d2,d3			; Null (0.0) ?
	beq.s	1$
	moveq	#10,d3
6$:	; Mantisse 11 Bits nach rechts
	lsr.l	#1,d0
	roxr.l	#1,d1
	dbf	d3,6$
	clr.w	d2
	swap	d2
	bclr	#15,d2			; Sign übertragen
	beq.s	7$
	bset	#31,d0
7$:	sub.w	#$3fff,d2		; Extended Prec BIAS abziehen
	add.w	#$3ff,d2		;  dann Double Prec BIAS addieren
	cmp.w	#$0fff,d2
	bhi.s	8$			; Overflow dabei?
	lsl.w	#4,d2
	swap	d2
	or.l	d2,d0			; Exponent hinzuodern
	bra.s	1$
8$:	moveq	#85,d0			; Overflow during float calc
	bsr	Error2
9$:	moveq	#0,d0			; Z-Flag: Error!
	moveq	#0,d1
	movem.l	(sp)+,d2-d4/a6
	rts
10$:	cmp.w	#T_PACKED,d0
	bne	20$
	move.l	(a1)+,d2
	movem.l	(a1),d0-d1
	lea	Buffer(a5),a0		; Float-String erzeugen
	move.l	a0,a1
	tst.l	d2			; Mantisse Vorzeichen?
	bpl.s	11$
	move.b	#'-',(a1)+
11$:	or.b	#'0',d2
	move.b	d2,(a1)+		; 1-digit integer
	move.b	#'.',(a1)+
	moveq	#7,d3
	bsr.s	15$			; 16-digit Fraction schreiben
	move.l	d1,d0
	moveq	#7,d3
	bsr.s	15$
	move.b	#'E',(a1)+		; Exponent
	moveq	#'+',d0
	btst	#30,d2			; Exp. Vorzeichen?
	beq.s	12$
	moveq	#'-',d0
12$:	move.b	d0,(a1)+
	move.l	d2,d0
	lsl.l	#4,d0
	moveq	#2,d3
	bsr.s	15$			; 3-digit Exponent schreiben
	clr.b	(a1)
	bsr	GetFloat
	bne	1$
	bra.s	9$
15$:	moveq	#$0f,d4
	rol.l	#4,d0
	and.b	d0,d4
	or.b	#'0',d4
	move.b	d4,(a1)+
	dbf	d3,15$
	rts
20$:	; Absolutes SET- oder Equate-Symbol
	move.l	MathIEEEBase(a5),a6
	move.l	a1,d0
	jsr	IEEEDPFlt(a6)		; Long nach Double Prec konvertieren
	bra	1$


	cnop	0,4
FloatConversion:
; d0/d1 = 64 Bit IEEE Double Precision
; d7 = Conversion Size (os_FFP,os_SINGLE,...)
; -> d0 = FFP,SinglePrec oder Zeiger auf Double,Extended oder Packed
; -> d2 = 0 oder -1:Error
	movem.l	d3-d7/a2-a3/a6,-(sp)
	lea	FloatBuffer(a5),a2
	subq.b	#os_SINGLE,d7
	bhi.s	3$
	move.l	MathIEEETransBase(a5),a6
	jsr	IEEEDPTieee(a6)		; nach Single Prec konvertieren
	move.l	d0,d1
	swap	d1
	or.w	#%1000000010000000,d1
	addq.w	#1,d1			; Overflow?
	bne.s	2$
1$:	moveq	#85,d0			; Overflow during Float calculation!
	bra	fcon_error
2$:	tst.b	d7			; nach FFP konvertieren?
	beq	fcon_exit
	move.l	MathFFPTransBase(a5),a6
	jsr	SPFieee(a6)
	bvs.s	1$
	bra	fcon_exit
3$:	subq.b	#1,d7
	bne.s	4$
	movem.l	d0-d1,(a2)		; nach Double Prec braucht keine Konvertierung
	move.l	a2,d0
	bra	fcon_exit
4$:	subq.b	#1,d7			; Extended Precision?
	bne	fcon_PackedBCD
	move.l	d0,d4
	move.l	d1,d5
	or.l	d4,d5			; NULL ?
	bne.s	5$
	move.l	a2,d0
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)
	bra.s	fcon_exit
5$:	moveq	#10,d3			; Mantisse 11 Bits nach links
6$:	add.l	d1,d1
	addx.l	d0,d0
	dbf	d3,6$
	bset	#31,d0			; MSB wieder sichtbar machen
	movem.l	d0-d1,4(a2)		; Extended Prec. Mantisse speichern
	clr.w	2(a2)
	swap	d4
	move.w	d4,d0
	bclr	#15,d0
	lsr.w	#4,d0			; Exponent
	sub.w	#$3ff,d0		; IEEE Double BIAS abziehen
	add.w	#$3fff,d0		;  und IEEE Ext. BIAS addieren
	btst	#15,d4
	beq.s	7$
	bset	#15,d0			; Vorzeichen
7$:	move.w	d0,(a2)
	move.l	a2,d0			; Zeiger auf 96-Bit Float übergeben

fcon_exit:
	moveq	#0,d2
fcon_x:
	moveq	#0,d1
	movem.l	(sp)+,d3-d7/a2-a3/a6
	rts
fcon_error:
	bsr	Error2
	moveq	#-1,d2
	bra.s	fcon_x

fcon_PackedBCD:
	; ** Packed BCD Real erzeugen **
	move.l	a2,a0
	clr.l	(a0)+			; Float Buffer löschen
	clr.l	(a0)+
	clr.l	(a0)
	lea	3(a2),a3
	lea	Buffer+2(a5),a2		; a2 Float String Buffer
	move.l	a2,a0
	moveq	#15,d2			; 15 Nachkommastellen (sollten reichen)
	bsr	Double2Asc		; Double Precision als ASCII nach (a2) schreib.
	move.l	a3,a0			; a0/d4 Zieladr. der BCD-Ziffer
	moveq	#0,d4			;  (d4 gibt dabei das Nibble an)
	lea	Buffer(a5),a3
	clr.w	(a3)			; Mantissa & Exp. default to positive
	moveq	#16,d5			; d5 17 Ziffern können max. gelesen werden
	moveq	#0,d6			; d6 (=-1) Offsetberechnung abgeschlossen
	moveq	#0,d7			; d7 Exp.-Offset (durch zB. 123.5 oder 0.001,
1$:	;    Normalized: 1.235E+2 , 1.0E-3 )
	move.b	(a2)+,d0
	beq	mpbcd_zeroexp
	cmp.b	#'-',d0
	bne.s	2$
	st	(a3)			; negative Mantisse
	bra.s	1$
2$:	cmp.b	#'+',d0
	beq.s	1$
	cmp.b	#'.',d0
	bne.s	3$
	moveq	#-1,d7			; 0.x (Exp. wird mindestens um 1 verkleinert)
	bra.s	mpbcd_read
3$:	cmp.b	#'0',d0
	beq.s	1$
	subq.l	#1,a2

mpbcd_read:
	move.b	(a2)+,d0
	beq	mpbcd_zeroexp		; Zahl zuende ?
	cmp.b	#'.',d0
	beq.s	mpbcd_read
	cmp.b	#'E',d0
	beq.s	mpbcd_exp
	and.b	#15,d0
	lsl.b	d4,d0
	or.b	d0,(a0)			; BCD-Ziffer einfügen
	bchg	#2,d4
	bne.s	1$
	addq.l	#1,a0
1$:	dbf	d5,mpbcd_read
mpbcd_exp:
	moveq	#0,d1			; d1 wird den BCD-Exponenten enthalten
	move.b	(a2)+,d0
	cmp.b	#'0',d0
	bhs.s	3$
1$:	cmp.b	#'-',d0			; negativer Exponent ?
	seq	1(a3)
2$:	move.b	(a2)+,d0
	beq.s	mpbcd_normalize		; fertig, Exp. berechnen und einsetzen
3$:	lsl.l	#4,d1
	and.b	#15,d0
	or.b	d0,d1			; neue BCD-Zahl einsetzen
	bra.s	2$

mpbcd_zeroexp:
	moveq	#0,d1			; kein Exponent angegeben
mpbcd_normalize:
	move.w	d1,d0
	lsr.w	#8,d0
	and.w	#$ff,d1
	moveq	#-8,d3			; (=$fff8)
	and.w	d0,d3			; Exponent zu gross ?
	beq.s	4$
	moveq	#85,d0			; Overflow
	bra	fcon_error
4$:	and.b	#$0f,d0
	tst.b	(a3)
	beq.s	5$
	or.b	#$80,d0			; Mantisse negativ
5$:	tst.b	1(a3)
	beq.s	6$
	or.b	#$40,d0			; Exponent negativ
6$:	lea	FloatBuffer(a5),a0
	move.b	d0,(a0)			; Vorzeichen und Exponent speichern
	move.b	d1,1(a0)
	move.l	a0,d0			; Zeiger auf Packed-BCD übergeben
	bra	fcon_exit


	cnop	0,4
dprec_fracs:
	dc.l	$3fb99999,$99999999	; 1E-1 (0.1)
	dc.l	$3ddb7cdf,$d9d7bdba	; 1E-10

Double2Asc:
; d0/d1 = IEEE Double Precision
; d2 = Max.Anzahl Nachkommastellen (sollte mindestens eine sein)
; a0 = FloatString Buffer
	movem.l	d3-d7/a2/a6,-(sp)
	move.l	MathIEEEBase(a5),a6
	move.w	d2,d5			; d5 Anzahl Nachkommastellen
	move.l	a0,a2			; a2 FloatString
	bclr	#31,d0			; Vorzeichen?
	beq.s	1$
	move.b	#'-',(a2)+
1$:	moveq	#0,d4			; d4 10er Exponent
	move.l	d0,d6
	move.l	d1,d7
	movem.l	dprec_tab(pc),d2-d3
	jsr	IEEEDPCmp(a6)		; Double >= 1.0 ?
	blt.s	d2a_upmult

2$:	; Double>1 auf 1..10 herunterdividieren
	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_tab+16(pc),d2-d3
	jsr	IEEEDPCmp(a6)		; >= 1E10 ?
	blt.s	3$
	add.w	#10,d4			; Exponent + 10 (Division durch 1E10)
	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_tab+16(pc),d2-d3
	jsr	IEEEDPDiv(a6)
	move.l	d0,d6
	move.l	d1,d7
	bra.s	2$
3$:	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_tab+8(pc),d2-d3
	jsr	IEEEDPCmp(a6)		; >= 10 ?
	blt.s	d2a_normalized
	addq.w	#1,d4			; Exponent + 1 (Division durch 10)
	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_tab+8(pc),d2-d3
	jsr	IEEEDPDiv(a6)
	move.l	d0,d6
	move.l	d1,d7
	bra.s	3$

d2a_upmult:
	; Double<1 auf 1..10 heraufmultiplizieren
	move.l	d6,d0
	or.l	d7,d0			; 0.0 ?
	bne.s	1$
	move.b	#'0',(a2)+
	bra	d2a_exit
1$:	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_fracs+8(pc),d2-d3
	jsr	IEEEDPCmp(a6)		; <= 1E-10 ?
	bgt.s	2$
	sub.w	#10,d4			; Exponent - 10 (Division durch 1E-10)
	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_fracs+8(pc),d2-d3
	jsr	IEEEDPDiv(a6)
	move.l	d0,d6
	move.l	d1,d7
	bra.s	1$
2$:	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_tab(pc),d2-d3
	jsr	IEEEDPCmp(a6)		; < 1 ?
	bge.s	d2a_normalized
	subq.w	#1,d4			; Exponent - 1 (Division durch 0.1)
	move.l	d6,d0
	move.l	d7,d1
	movem.l	dprec_fracs(pc),d2-d3
	jsr	IEEEDPDiv(a6)
	move.l	d0,d6
	move.l	d1,d7
	bra.s	2$

d2a_normalized:
	moveq	#0,d0
	move.w	d5,d0
	jsr	IEEEDPFlt(a6)		; 0.5 * 10^-(Stellen_nach_dem_Komma)
	jsr	IEEEDPNeg(a6)
	move.l	d0,d2
	move.l	d1,d3
	movem.l	dprec_tab+8(pc),d0-d1	; 10
	move.l	a6,-(sp)
	move.l	MathIEEETransBase(a5),a6
	jsr	IEEEDPPow(a6)		; 10^-Stellen
	move.l	(sp)+,a6
	move.l	#$3fe00000,d2
	moveq	#0,d3
	jsr	IEEEDPMul(a6)		; * 0.5
	move.l	d6,d2
	move.l	d7,d3
	jsr	IEEEDPAdd(a6)		; Letzte auszugebene Stelle runden
	move.l	d0,d6
	move.l	d1,d7
	jsr	IEEEDPFix(a6)		; Integer vor dem Komma bestimmen
	moveq	#'0',d1
	add.b	d0,d1
	move.b	d1,(a2)+
	move.b	#'.',(a2)+
	subq.w	#1,d5
1$:	jsr	IEEEDPFlt(a6)
	move.l	d0,d2
	move.l	d1,d3
	move.l	d6,d0
	move.l	d7,d1
	jsr	IEEEDPSub(a6)		; Integer wieder abziehen
	movem.l	dprec_tab+8(pc),d2-d3
	jsr	IEEEDPMul(a6)		; *10 macht nächste Stelle im Int-Teil sichtbar
	move.l	d0,d6
	move.l	d1,d7
	jsr	IEEEDPFix(a6)		; Nachkommastelle anfügen
	moveq	#'0',d1
	add.b	d0,d1
	move.b	d1,(a2)+
	dbf	d5,1$			; noch eine Nachkommastelle berechnen?

	tst.w	d4			; Exponent ausgeben
	beq.s	d2a_exit		; gar nicht nötig?
	move.l	a3,d5
	move.l	SysBase(a5),a6
	movem.w	d4-d5,-(sp)
	move.l	sp,a1
	move.l	#"E%d\0",-(sp)
	move.l	sp,a0
	move.l	a2,a3
	lea	2$(pc),a2
	jsr	RawDoFmt(a6)		; E<n> hinzufügen
	addq.l	#8,sp
	move.l	d5,a3
	bra.s	d2a_x
2$:	move.b	d0,(a3)+
	clr.b	(a3)
	rts
d2a_exit:
	clr.b	(a2)
d2a_x:
	movem.l	(sp)+,d3-d7/a2/a6
	rts
	ENDC


	IFND	FREEASS
XRefFile:
	btst	#sw_REFS,Switches(a5)	; Reference-File gewünscht?
	beq.s	1$
	move.l	ListFileHandle(a5),d7
	bne.s	20$
1$:	rts
20$:	tst.b	PageLength(a5)
	beq.s	2$
	cmp.b	#3,PageLine(a5)		; gerade neue Seite begonnen ?
	blo.s	2$
	bsr	NewPage
2$:	LOCS	S_SECLIST
	move.l	d7,d0
	bsr	print
	moveq	#5,d6			; d6 = PageLine
	moveq	#0,d5			; Section No Counter
	move.l	LinSecList(a5),a2
	move.w	SectionCnt(a5),d4
	subq.w	#1,d4
3$:	move.l	(a2)+,a0
	IFND	GIGALINES
	moveq	#0,d0
	move.w	sec_DeclLine(a0),d0
	move.l	d0,-(sp)		; first referenced
	ELSE
	move.l	sec_DeclLine(a0),-(sp)
	ENDC
	subq.l	#8,sp
	move.l	sec_Name(a0),-(sp)	; section name
	move.l	sec_Type(a0),d1
	bne.s	12$
	moveq	#S_SECTYPES+3,d0
	bra.s	8$
12$:	cmp.w	#HUNK_BSS,d1
	bne.s	6$
	moveq	#S_SECTYPES+2,d0
	bra.s	8$
6$:	cmp.w	#HUNK_DATA,d1
	bne.s	7$
	moveq	#S_SECTYPES+1,d0
	bra.s	8$
7$:	moveq	#S_SECTYPES,d0
8$:	bsr	LocStr_stub
	lea	SecNoTxt(pc),a1
	cmp.w	#HUNK_FAST>>16,d1
	bne.s	9$
	lea	SecFastTxt(pc),a1
	bra.s	10$
9$:	cmp.w	#HUNK_CHIP>>16,d1
	bne.s	10$
	lea	SecChipTxt(pc),a1
10$:	movem.l	a0-a1,4(sp)		; SectionType, MemType
	move.w	d5,-(sp)		; no
	move.l	d7,d0
	lea	SecDatTxt(pc),a0
	move.l	sp,a1
	bsr	print
	lea	18(sp),sp
	addq.w	#1,d5
	addq.b	#1,d6
	move.b	PageLength(a5),d0	; keine Kontrolle bei PageLength=0
	beq.s	5$
	cmp.b	d0,d6
	bls.s	5$
	moveq	#2,d6
	bsr	NewPage
5$:	dbf	d4,3$			; nächste Section

XRefSymbols:
	move.b	PageLength(a5),d0
	beq.s	1$
	sub.b	d6,d0
	cmp.b	#8,d0			; noch mind. 8 Zeilen auf dem Blatt frei ?
	bge.s	1$
	moveq	#2,d6
	bsr	NewPage
1$:	LOCS	S_SYMLIST		; Symbols Überschrift
	move.l	d7,d0
	bsr	print
	addq.b	#5,d6			;  kostet 5 Zeilen
	move.b	d6,PageLine(a5)
	move.l	SymbolTable(a5),d0
21$:	move.l	d0,a3
	lea	stab_HEAD(a3),a2
	move.w	stab_NumSymbols(a3),d5
	bra	30$
3$:	movem.l	d5/a3-a4,-(sp)
	addq.l	#sym_Name,a2
	move.l	(a2)+,-(sp)
	move.l	d7,d0
	lea	SymNameFmt(pc),a0
	move.l	sp,a1
	bsr	print			; sym_Name ausgeben
	addq.l	#4,sp
	IFND	GIGALINES
	moveq	#0,d4
	move.w	(a2)+,d4		; sym_DeclLine
	ELSE
	move.l	(a2)+,d4
	ENDC
	move.w	(a2)+,d5		; sym_Type
	move.l	(a2)+,d3		; sym_Value
	move.l	(a2)+,a4		; sym_RefList

	move.w	#T_ABS|T_EQU|T_DIST|T_XREF|T_NREF|T_XDEF,d0
	and.w	d5,d0
	bne	7$
	btst	#bit_SET,d5
	beq.s	4$
	LOCS	S_SYMTYPES+1		; * Set-Symbol *
	move.l	d7,d0
	bsr	print
	bra	10$			; Referenzen ausgeben
4$:
	IFND	SMALLASS
	move.w	#T_FFP|T_PACKED|T_SINGLE|T_DOUBLE|T_EXTENDED,d0
	and.w	d5,d0
	beq.s	41$			; Float-Zahl ?
	move.l	d3,a1
	bsr	Conv2Double		; nach Double Precision konvertieren
	lea	Buffer(a5),a0
	move.l	a0,-(sp)
	moveq	#8,d2			; 8 Nachk.stellen (gefährlich bei:-x.yyyyE-zzz)
	bsr	Double2Asc		; Float-String erzeugen
	move.l	d7,d0
	lea	SymFltFmt(pc),a0
	move.l	sp,a1
	bsr	print			; Normalized Float String ausgeben
	addq.l	#4,sp
	bra	9$
	ENDC
41$:	and.w	#T_REG|T_FREG,d5
	bne.s	5$
	LOCS	S_SYMTYPES		; * Macro *
	move.l	d7,d0
	bsr	print
	bra	9$			; DeclLine ausgeben
5$:	and.w	#T_FREG,d5
	beq	6$
	lea	Buffer(a5),a0
	move.l	a0,a1
	moveq	#-1,d2			; * FREG - List *
	moveq	#7,d1
	swap	d3
	move.w	d3,-(sp)
51$:	add.b	d3,d3
	bcc.s	53$
	tst.w	d2
	bmi.s	52$			; erstes Reg. überhaupt ?
	bne.s	56$			; mehrere Register in Folge ?
	move.b	#'/',(a0)+
52$:	move.w	d1,d0
	bsr.s	59$
	move.w	d1,d2			; neues Ausgangsregister merken
	bra.s	56$
53$:	tst.w	d2
	bmi.s	56$
	beq.s	56$
	subq.w	#1,d2
	cmp.w	d1,d2			; nur 1 Register in Reihe ?
	beq.s	54$
	move.b	#'-',(a0)+
	move.w	d1,d0
	addq.w	#1,d0
	bsr.s	59$
54$:	moveq	#0,d2			; Reihe abgeschlossen
56$:	dbf	d1,51$			; nächstes Register
	moveq	#3,d0
	and.w	(sp)+,d0
	subq.w	#3,d0			; Reihe endet auf FP0 ?
	bne.s	57$
	move.b	#'-',(a0)+
	bsr.s	59$
57$:	clr.b	(a0)
	move.l	d7,d0
	lea	SymRegListFmt(pc),a0
	move.l	a1,-(sp)
	move.l	sp,a1
	bsr	print
	addq.l	#4,sp
	bra	9$			; DeclLine
59$:	move.b	#'F',(a0)+
	move.b	#'P',(a0)+
	or.b	#'0',d0
	move.b	d0,(a0)+
	rts
6$:	lea	Buffer(a5),a0
	move.l	a0,a1
	moveq	#-1,d2			; * REG - List *
	moveq	#15,d1
	move.w	d3,-(sp)
61$:	cmp.w	#7,d1
	bne.s	65$
	tst.w	d2			; RegL. An-A0 unterbrechen, bei D7 neu beginnen
	beq.s	65$
	bmi.s	65$
	moveq	#8,d0
	cmp.w	d0,d2
	beq.s	65$
	move.b	#'-',(a0)+
	bsr	BinToReg
	moveq	#0,d2
65$:	add.w	d3,d3
	bcc.s	63$
	tst.w	d2
	bmi.s	62$			; erstes Reg. ueberhaupt ?
	bne.s	66$			; mehrere Register in Folge ?
	move.b	#'/',(a0)+
62$:	move.w	d1,d0
	bsr	BinToReg
	move.w	d1,d2			; neues Ausgangsregister merken
	bra.s	66$
63$:	tst.w	d2
	bmi.s	66$
	beq.s	66$
	subq.w	#1,d2
	cmp.w	d1,d2			; nur 1 Register in Reihe ?
	beq.s	64$
	move.b	#'-',(a0)+
	move.w	d1,d0
	addq.w	#1,d0
	bsr	BinToReg
64$:	moveq	#0,d2			; Reihe abgeschlossen
66$:	dbf	d1,61$			; naechstes Register
	moveq	#3,d0
	and.w	(sp)+,d0
	subq.w	#3,d0			; Reihe endet auf D0 ?
	bne.s	67$
	move.b	#'-',(a0)+
	bsr	BinToReg
67$:	clr.b	(a0)
	move.l	d7,d0
	lea	SymRegListFmt(pc),a0
	move.l	a1,-(sp)
	move.l	sp,a1
	bsr	print
	addq.l	#4,sp
	bra	9$			; DeclLine
7$:	btst	#bit_DIST,d5
	beq.s	79$
	move.l	d3,a0			; Distanz-Symbolwert lesen
	moveq	#$3f,d0
	and.b	dist_Info-dist_HEAD(a0),d0
	move.l	(a0)+,d3
	sub.l	(a0),d3
	bclr	#5,d0			; Left/Right Distance Shift?
	beq.s	73$
	asr.l	d0,d3
	bra.s	79$
73$:	asl.l	d0,d3
79$:	moveq	#$20,d0
	btst	#bit_ABS,d5
	beq.s	78$
	moveq	#$27,d0			; Reloc-Symbols ein ' nachstellen
78$:	move.l	d0,-(sp)
	move.l	d3,-(sp)
	move.l	d7,d0
	lea	SymValFmt(pc),a0
	move.l	sp,a1
	bsr	print			; Symbol-Value ausgeben
	addq.l	#8,sp
	and.w	#T_EQU|T_DIST|T_XREF|T_NREF,d5
	beq.s	8$
	and.w	#T_DIST|T_XREF|T_NREF,d5
	bne.s	71$
	move.l	d7,d0
	lea	SymAbsTxt(pc),a0	; Abs (EQU-Symbol)
	bsr	print
	bra.s	9$
71$:	and.w	#T_XREF|T_NREF,d5
	bne.s	72$
	move.l	d7,d0
	lea	SymDistTxt(pc),a0	; Dist (DIST-Symbol)
	bsr	print
	bra.s	9$
72$:	move.l	d7,d0
	lea	SymExtTxt(pc),a0	; Ext (XREF-Symbol)
	bsr	print
	bra.s	9$
8$:	; * ABS (Relocatable) *
	move.w	rlist_DeclHunk(a4),-(sp)
	move.l	d7,d0
	lea	SymDecSecFmt(pc),a0
	move.l	sp,a1
	bsr	print			; Declaration-Section ausgeben
	addq.l	#2,sp

9$:	move.l	d4,-(sp)
	move.l	d7,d0
	lea	SymDecLFmt(pc),a0
	move.l	sp,a1
	bsr	print
	addq.l	#4,sp
10$:	tst.w	rlist_NumRefs(a4)	; Ueberhaupt eine Referenz eingetragen ?
	bne.s	11$
	LOCS	S_UNREF
	move.l	d7,d0
	bsr	print
	bra.s	20$
11$:	moveq	#6,d3			; Max. 6 Werte in einer Zeile
	lea	SymRefDatTxt(pc),a0
	move.l	a0,d5
	move.l	a4,d0
12$:	move.l	d0,a4
	lea	rlist_HEAD(a4),a3
	move.w	rlist_NumRefs(a4),d4
	bpl.s	14$			; ReferenceList vollstaendig belegt ?
	move.w	#REFLISTBLK/rlistSIZE,d4
	bra.s	14$
13$:	subq.w	#1,d3
	bpl.s	15$
	moveq	#5,d3
	move.l	d7,d0
	lea	SymRefNewLine(pc),a0
	bsr	print
15$:
	IFND	GIGALINES
	moveq	#0,d0
	move.w	2(a3),d0
	move.l	d0,-(sp)
	ELSE
	move.l	2(a3),-(sp)
	ENDC
	move.l	d7,d0
	move.l	d5,a0
	move.l	sp,a1
	bsr	print			; Referenzzeile (gefolgt von SPC) ausgeben
	addq.l	#4,sp
	lea	rlistSIZE(a3),a3	; Zeiger auf naechsten Referenz-Eintrag
14$:	dbf	d4,13$
	move.l	(a4),d0			; naechster ReferenceList-Chunk
	bne.s	12$
	move.l	d7,d0
	lea	SymNewLine(pc),a0
	bsr	print			; neue Zeile
20$:	movem.l	(sp)+,d5/a3-a4
	move.b	PageLine(a5),d0
	addq.b	#1,d0
	move.b	d0,PageLine(a5)
	move.b	PageLength(a5),d1
	beq.s	30$
	cmp.b	d1,d0
	bls.s	30$
	bsr	NewPage
30$:	dbf	d5,3$			; nächstes Symbol
	move.l	(a3),d0			; nächster Symbol-Chunk
	bne	21$

printregrefs:
	lea	RegNames(a5),a3		; Register-Symbol Referenzen ausgeben
	lea	RegRefs(a5),a4
	move.l	#'D0\0\0',Buffer(a5)
	moveq	#15,d6
1$:	moveq	#MAXREGNAMES-1,d5
2$:	move.l	(a3)+,d0
	beq	9$
	lea	SymRegFmt(pc),a0
	move.l	(a4),a2			; RefRef-struct
	IFND	GIGALINES
	move.w	rrl_DeclLine(a2),-(sp)
	clr.w	-(sp)
	ELSE
	move.l	rrl_DeclLine(a2),-(sp)
	ENDC
	pea	Buffer(a5)
	move.l	d0,-(sp)
	move.l	sp,a1
	move.l	d7,d0
	bsr	print			; Name, Register und DeclLine ausgeben
	lea	12(sp),sp
	tst.w	rrl_NumRefs(a2)		; Ueberhaupt eine Referenz eingetragen ?
	bne.s	3$
	LOCS	S_UNREF
	move.l	d7,d0
	bsr	print
	bra.s	9$
3$:	move.l	a3,-(sp)
	moveq	#6,d3			; Max. 6 Werte in einer Zeile
	move.l	a2,d0
4$:	move.l	d0,a2
	lea	rrl_HEAD(a2),a3
	move.w	rrl_NumRefs(a2),d4
	bra.s	6$
5$:
	IFND	GIGALINES
	moveq	#0,d0
	move.w	(a3)+,d0
	move.l	d0,-(sp)
	ELSE
	move.l	(a3)+,-(sp)
	ENDC
	move.l	d7,d0
	lea	SymRefDatTxt(pc),a0
	move.l	sp,a1
	bsr	print			; Referenzzeile (gefolgt von SPC) ausgeben
	addq.l	#4,sp
	subq.w	#1,d3
	bne.s	6$
	moveq	#6,d3			; neue Zeile
	move.l	d7,d0
	lea	SymRefNewLine(pc),a0
	bsr	print
6$:	dbf	d4,5$
	move.l	(a2),d0			; naechster ReferenceList-Chunk
	bne.s	4$
	move.l	d7,d0
	lea	SymNewLine(pc),a0
	bsr	print			; neue Zeile
	move.l	(sp)+,a3
	move.b	PageLine(a5),d0
	addq.b	#1,d0
	move.b	d0,PageLine(a5)
	move.b	PageLength(a5),d1
	beq.s	9$
	cmp.b	d1,d0
	bls.s	9$
	bsr	NewPage
9$:	addq.l	#4,a4
	dbf	d5,2$
	cmp.w	#8,d6
	bne.s	10$
	move.w	#'A0',Buffer(a5)
	dbf	d6,1$
10$:	addq.b	#1,Buffer+1(a5)
	dbf	d6,1$

	lea	FPRegNames(a5),a3	; FPRegister-Symbol Referenzen ausgeben
	lea	FPRegRefs(a5),a4
	move.l	#'FP0\0',Buffer(a5)
	moveq	#7,d6
11$:	moveq	#MAXFPREGNAMES-1,d5
12$:	move.l	(a3)+,d0
	beq	19$
	lea	SymRegFmt(pc),a0
	move.l	(a4),a2			; RefRef-struct
	IFND	GIGALINES
	move.w	rrl_DeclLine(a2),-(sp)
	clr.w	-(sp)
	ELSE
	move.l	rrl_DeclLine(a2),-(sp)
	ENDC
	pea	Buffer(a5)
	move.l	d0,-(sp)
	move.l	sp,a1
	move.l	d7,d0
	bsr	print			; Name, Register und DeclLine ausgeben
	lea	12(sp),sp
	tst.w	rrl_NumRefs(a2)		; Ueberhaupt eine Referenz eingetragen ?
	bne.s	13$
	LOCS	S_UNREF
	move.l	d7,d0
	bsr	print
	bra.s	19$
13$:	move.l	a3,-(sp)
	moveq	#6,d3			; Max. 6 Werte in einer Zeile
	move.l	a2,d0
14$:	move.l	d0,a2
	lea	rrl_HEAD(a2),a3
	move.w	rrl_NumRefs(a2),d4
	bra.s	16$
15$:
	IFND	GIGALINES
	moveq	#0,d0
	move.w	(a3)+,d0
	move.l	d0,-(sp)
	ELSE
	move.l	(a3)+,-(sp)
	ENDC
	move.l	d7,d0
	lea	SymRefDatTxt(pc),a0
	move.l	sp,a1
	bsr	print			; Referenzzeile (gefolgt von SPC) ausgeben
	addq.l	#4,sp
	subq.w	#1,d3
	bne.s	16$
	moveq	#6,d3			; neue Zeile
	move.l	d7,d0
	lea	SymRefNewLine(pc),a0
	bsr	print
16$:	dbf	d4,15$
	move.l	(a2),d0			; naechster ReferenceList-Chunk
	bne.s	14$
	move.l	d7,d0
	lea	SymNewLine(pc),a0
	bsr	print			; neue Zeile
	move.l	(sp)+,a3
	move.b	PageLine(a5),d0
	addq.b	#1,d0
	move.b	d0,PageLine(a5)
	move.b	PageLength(a5),d1
	beq.s	19$
	cmp.b	d1,d0
	bls.s	19$
	bsr	NewPage
19$:	addq.l	#4,a4
	dbf	d5,12$
	addq.b	#1,Buffer+2(a5)
	dbf	d6,11$
	rts

SecDatTxt:
	dc.b	"%-3d %-32s %-4s %-9s  %ld\n",0
SecChipTxt:
	dc.b	"(ChipRAM)",0
SecFastTxt:
	dc.b	"(FastRAM)"
SecNoTxt:
	dc.b	0

SymNameFmt:
	dc.b	"%-16s ",0
SymRegFmt:
	dc.b	"%-16s %-16s%5ld  ",0
SymRegListFmt:
	dc.b	"%-16s",0
SymValFmt:
	dc.b	"$%08lx%lc",0
SymFltFmt:
	dc.b	"%-15s ",0
SymAbsTxt:
	dc.b	"  Abs ",0
SymDistTxt:
	dc.b	" Dist ",0
SymExtTxt:
	dc.b	"  Ext ",0
SymDecSecFmt:
	dc.b	"  %3d ",0
SymDecLFmt:
	dc.b	"%5ld  ",0
SymRefDatTxt:
	dc.b	"%-5ld ",0
SymRefNewLine:
	dc.b	10
	dcb.b	40,32
	dc.b	0
SymNewLine:
	dc.b	10,0


	cnop	0,4
print:
	jmp	fprintf


BinToReg:
; d0 = RegisterNr.(0-15) (=>D0-A7)
; a0 = StringBuffer
; -> a0 = NewStringBuffer-Pos. (a1 und d1 werden gerettet !)
	move.l	d1,-(sp)
	moveq	#'D',d1
	bclr	#3,d0
	beq.s	1$
	moveq	#'A',d1
1$:	move.b	d1,(a0)+
	and.w	#7,d0
	or.b	#'0',d0
	move.b	d0,(a0)+
	move.l	(sp)+,d1
	rts


NewPage:
; d7 = FileHandle
	move.w	#$0c00,-(sp)
	move.l	sp,a0
	move.l	d7,d0
	bsr	print			; FormFeed - neue Seite beginnen
	addq.l	#2,sp
	jmp	PageTitle


EquatesFile:
	move.l	EquatesName(a5),d1
	beq	9$
	move.l	a6,a2
	move.l	DosBase(a5),a6
	move.l	#MODE_NEWFILE,d2
	jsr	Open(a6)
	move.l	a2,a6
	move.l	d0,d7
	bne.s	1$
	moveq	#79,d0			; Unable to create file
	bra	Error2
1$:	jsr	GetSysTime
	lea	TimeString(a5),a0
	move.l	a0,-(sp)
	move.l	SourceName(a5),-(sp)
	LOCS	S_EQU
	move.l	sp,a1
	move.l	d7,d0
	bsr	print
	addq.l	#8,sp
	move.l	SymbolTable(a5),d0
21$:	move.l	d0,a3
	lea	stab_HEAD(a3),a2
	move.w	stab_NumSymbols(a3),d5
	bra	5$
3$:	move.w	sym_Type(a2),d0
	IFD	SMALLASS
	and.w	#T_EQU,d0
	beq.s	4$
	ELSE
	cmp.w	#T_DIST,d0
	beq	10$
	and.w	#T_EQU|T_FFP|T_SINGLE|T_DOUBLE|T_EXTENDED|T_PACKED,d0
	beq	4$
	and.w	#T_FFP|T_SINGLE|T_DOUBLE|T_EXTENDED|T_PACKED,d0
	beq.s	7$
	move.w	d0,d4
	move.l	sym_Value(a2),a1	; Float-EQU Symbol ausgeben
	bsr	Conv2Double
	lea	Buffer(a5),a0
	move.l	a0,-(sp)
	moveq	#16,d2			; auf 16 Nachkommastellen genau
	bsr	Double2Asc
	lsr.w	#6,d4
	moveq	#-1,d0
8$:	; Float-Extension bestimmen (f,s,d,x,p)
	addq.w	#1,d0
	lsr.w	#1,d4
	bcc.s	8$
	moveq	#0,d1
	move.b	FltExts(pc,d0.w),d1
	move.l	d1,-(sp)
	move.l	sym_Name(a2),-(sp)
	move.l	sp,a1
	lea	FloatEquLine(pc),a0
	move.l	d7,d0
	bsr	print
	lea	12(sp),sp
	bra.s	4$
	ENDC
10$:	move.l	sym_Value(a2),a0
	movem.l	(a0),d0-d1
	sub.l	d1,d0
	move.l	d0,-(sp)
	bra.s	11$
7$:	move.l	sym_Value(a2),-(sp)	; Normales EQU ausgeben
11$:	move.l	sym_Name(a2),-(sp)
	move.l	sp,a1
	lea	NormEquLine(pc),a0
	move.l	d7,d0
	bsr	print
	addq.l	#8,sp
4$:	lea	SymbolSIZE(a2),a2
5$:	dbf	d5,3$			; nächstes Symbol
	move.l	(a3),d0
	bne.s	21$
	move.l	a6,a2
	move.l	DosBase(a5),a6
	move.l	d7,d1
	jsr	Close(a6)
	move.l	EquatesName(a5),d1
	moveq	#%0010,d2		; rw-d Protection
	jsr	SetProtection(a6)
	move.l	a2,a6
9$:	rts

	IFND	SMALLASS
FltExts:
	dc.b	"FPSDX"
FloatEquLine:
	dc.b	"%s \tEQU.%lc\t%s\n",0
	ENDC
NormEquLine:
	dc.b	"%s \tEQU\t$%lx\n",0
	even

LocStr_stub:
	jmp	LocStr
	ENDC

Error2:
	jmp	Error


	end
