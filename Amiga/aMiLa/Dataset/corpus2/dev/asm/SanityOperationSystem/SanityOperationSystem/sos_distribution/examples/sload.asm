;DEBUG	EQU	1

; ===================================================================
;
;        S O S  ---- Testprogramm
;
; ===================================================================

HARDWARE	EQU	$dff002

	INCLUDE	"include:sos.i"

; ===================================================================


	SECTION	"code",CODE_C

Start	move.l	a0,LoadName	; Get Name
.loop	cmp.b	#$20,(a0)+
	bhi.s	.loop
	clr.b	-1(a0)
.loop2	cmp.b	#$20,(a0)+
	beq.s	.loop2
	subq.w	#1,a0
	move.l	a0,String

	bsr	DosOpen		; Lade SOS
	move.l	DosBase,a6
	move.l	#Name,d1
	jsr	-150(a6)
	move.l	d0,Segment
	beq.s	.end
	lsl.l	#2,d0		; Starte SOS
	move.l	d0,a0
	jsr	4(a0)

	movem.l	Zeros,d0-d7/a1/a3-a5	; Lösche Register

	lea	MyCode(pc),a0
	jsr	_StartIt(a6)

	move.l	Segment,d1		; SOS Löschen
	move.l	DosBase,a6
	jsr	-156(a6)
.end	bsr	DosClose			; Ende
	moveq	#0,d0
	rts


MyCode	move.l	LoadName,a0		; Load File
	jsr	_LoadSeg(a6)
	cmp.l	#'sos'*$100,12(a0)	; Testing
	bne.s	.error			; -> kein Module
	move.l	a0,a1
	move.l	String(pc),a0
	jsr	6(a1)			; Reinspringen
.error	rts				; SOS deaktivieren

Name	dc.b	'SOSBIN:sos_dev',0	; Filename
Segment	dc.l	0			; Segmentspeicher
String	dc.l	0
LoadName	dc.l	0

Zeros	dcb.l	16


; **************************************************************
;
; Dos Support
;
; **************************************************************
;
; DosClose ()
; DosOpen ()
; DosLoad  (Name,Adresse,Länge)(a0,a1,d0) ()()
; DosSave  (Name,Adresse,Länge)(a0,a1,d0) ()()
; DosPut   (Text)(a0)                     ()()
; DosPutCr (Text||0)(a0)                  ()()
; DosBreak ()()                           (1=Break)(d0)
;
; Alle Befehle verändern d0/d1/d2/d3/a0/a1/a6!

DosClose	move.l	DosBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)
	rts

DosOpen	lea	DosName(pc),a1
	moveq	#0,d0
	move.l	4.w,a6
	jsr	-552(a6)
	move.l	d0,DosBase
	move.l	d0,a6
	rts

DosBase	dc.l	0
DosName	dc.b	'dos.library',0
	even

