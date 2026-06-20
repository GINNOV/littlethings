* a little bootintro by PROFI (comments in German)

InitBitMap=-390
InitRastPort=-198
ClearScreen=-48
RectFill=-306
FindResident=-96
ScrollRaster=-396
Text=-60

OffsetBase=$dff000
VPOSR=$6
DMACON=$96
BPL1MOD=$108
BPL2MOD=$10a
DIWSTRT=$8E
DIWSTOP=$90

SETCLR=$8000
DMAEN=$100
DIWSTRTV=44
DIWSTRTH=129
DIWSTOPV=244
DIWSTOPH=193

LeftMouseButton=$bfe001

RastPort=$70000
BitMap=$70200
Copperlist=$7a000


	dc.b	'DOS',0
	dc.l	0,880
Start:
;	move.l	4.w,a6
	movem.l	d0-d7/a0-a6,-(sp)	; Alle Register auf Stack retten
	Lea	Gfx.name(PC),A1
	Jsr	-408(A6)		;Graphics Library oeffnen
	Move.l  D0,A6			;Gfxbase nach A6

; Bildschirm Variable initialisieren
	Lea	 OffsetBase,A0
	Move	#SETCLR+DMAEN,DMACON(A0)
	moveq	#6,d0
	Move	d0,BPL1MOD(A0)
	Move	d0,BPL2MOD(A0)
	Move	#DIWSTRTV*$100+DIWSTRTH,DIWSTRT(A0)
	Move	#DIWSTOPV*$100+DIWSTOPH,DIWSTOP(A0)

; Init Copperlist
	Lea	Copperlist,A0
	Move.l	#$00e00005,(A0)+	; MOVE $5 -> BPL1PTH
	Move.l	#$00e29000,(A0)+	; MOVE $9000 -> BPL1PTL
	Move.l	#$01001200,(A0)+	; MOVE 1 -> BPU0 & 1 -> COLOR
	Move.l	#$01800000,(A0)+	; MOVE 0 -> COLOR0
	Move.l	#$01820000,(A0)+	; MOVE 0 -> COLOR1
	Lea	Copperlist,A0
	Move.l  A0,50(A6)		   ; GfxBase+50

; BitMap initialisieren
	Lea	BitMap,A0		   ; BitMap
	Moveq	#1,D0	 	  ; depth
	Move	#368,D1	 	; width
	Move	#220,D2	 	; height
	Jsr	InitBitMap(A6)
	Move.l	#$58e62,BitMap+8	; erstes BitPlane

; RastPort initialisieren
	Lea	RastPort,A1		 ; rastport
	move.l	a1,a3
	Jsr	InitRastPort(A6)
	move.l	a3,a1
	Move.l  #BitMap,RastPort+4	  ; BitMap Addresse -> RastPort
	Jsr	ClearScreen(A6)	 ; Bildschirm loeschen

; Kaestchen in die Copperliste schreiben
	Lea	Copperlist+20,A0	; Ende der Copperliste -> A0
	Move	#175,D7
	Move.l	#$2c09fffe,D5	   ; WAIT 8, 44
EinsVertikal:
	Move.l	D5,D0
	Moveq	#15,D6
Horizontalline:
	Move.l	D0,(A0)+
	Move.l	#$1800000,(A0)+	 ; MOVE $000 -> COLOR0
	Add.l	#$e0000,D0		  ; WAIT Oldx+15, Oldy
	Dbf	D6,Horizontalline
	Add.l	#$1000000,D5		; WAIT 8, Oldy+1
	Dbf	D7,EinsVertikal
	Moveq	#28,D7	 	 ; Kaestchenhoehe = 10
	Lea	TextScrollFeld(PC),A4
AppendCopList:
	Move.l	(A4)+,(A0)+		 ; Scrollfeld malen anhaengen
	Dbf	D7,AppendCopList

; The P.R.O.F.I. auf BitMap malen
	Lea	BobTab(PC),A5
	Moveq	#30,D7	 	 ; The PROFI = 31 Vierecke
InitBob:
	Lea	RastPort,A1		 ; RastPort
	moveq	#0,D0	 		 ; xl
	moveq	#0,D1	 		 ; yl
	moveq	#0,D2	 		 ; xu
	moveq	#0,d3	 		 ; yu
	Move.b	(A5)+,D0		    ; xl
	Add	#25,D0	 	 ; xl+25
	Move.b	(A5)+,D1		    ; yl
	Move.b	(A5)+,D2		    ; xu
	Add	#25,D2	 	 ; xu+25
	Move.b	(A5)+,D3		    ; yu
	Jsr	RectFill(A6)
	Dbf	D7,InitBob

; Farbtabelle spiegeln auf 44 Farben
	Lea	Farbtabelle(PC),A0
	Lea	Farbtabelle+80(PC),A1
	Moveq	#20,D7
SpiegelFarbtabelleLoop3:
	Move	(A0)+,-(A1)
	Dbf	D7,SpiegelFarbtabelleLoop3

	Lea	Dummy(PC),A0
	Move.l	$6c.w,2(A0)	; -> jmp ($6c)
	Lea	TextScrollen(PC),A0
	Move.l  A0,$6c.w	; -> jmp Textscrollen

MainLoop:

; Farben in die Copperliste eintragen
	Moveq	#21,D7
	Lea	Copperlist+26,A0
	Lea	Farbtabelle(PC),A5
	Move	(A5),-8(A0)
FCLop0: Moveq	#7,D4
FCLop1: Move.l	A5,A1
	Moveq	#15,D6
FCLop2: Move	(A1)+,(A0)
	Addq.l	#8,A0
	Dbf	D6,FCLop2
	Dbf	D4,FCLop1
	Addq.l	#2,A5
	Dbf	D7,FCLop0

; Farbtabelle rotieren
	Lea	Farbtabelle(PC),A0
	Lea	Farbtabelle+2(PC),A1
	Moveq	#38,D0
	Move	(A0),D1	 	; farbe0 -> dummy
RotateFarbtabelle:
	Move	(A1)+,(A0)+
	Dbf	D0,RotateFarbtabelle
	Move	D1,-(A1)		    ; dummy -> farbe44

; Warten bis Elektronenstrahl in Zeile 64 ist (WaitTOF)
WaitTOF:
;	Cmpi.b	#64,OffsetBase+VPOSR
;	Bls.s	WaitTOF
	jsr	-270(a6)

	Btst	#6,LeftMouseButton	  ; Mousebutton gedrueckt
	Bne.s	MainLoop		    ; falls nein -> Mainloop

; Programm beenden
	Lea	Dummy+2(PC),A0
	Move.l	(A0),$6c.w
	Lea	Dummy+10(PC),A1
	Move.l	#$20646f73,(A1)	 ; " dos"

	Movem.l	(sp)+,d0-d7/a0-a6
	Lea	Dummy+11(PC),A1	 ; Name = dos.library
	Jsr	FindResident(A6)
	Move.l	D0,A0
	Move.l	22(A0),A0
	moveq	#0,D0
	Rts

TextScrollen:
	Movem.l	d0-d7/a0-a6,-(sp)
	Lea	RastPort,A1		 ; RastPort
	Moveq	#1,D0	 	  ; dx
	moveq	#0,d1	 		 ; dy
	moveq	#0,d2	 		 ; minx
	Move	#198,D3	 	; miny
	Move	#351,D4	 	; maxx
	Move	#206,D5	 	; maxy
	Jsr	ScrollRaster(A6)
	Lea	ScrollText-2(PC),A0
	Subq.b	#1,(A0)
	Bne.s	Bra2
	Move.b	#9,(A0)
	Lea	ScrollText-1(PC),A0
	Eori.b	#1,(A0)
	Lea	RastPort,A1
	Move	#320,36(A1)		 ; Current Pen Position x
	Move	#205,38(A1)		 ; Current Pen Position y
	Lea	AktBuchstabe(PC),A2
	Addq.b	#1,(A2)
	Cmp.b	#TextEnde-ScrollText,(A2)	   ;Anzahl der Buchstaben
	Bne.s	PrintBuchstabe
	Clr.b	(A2)
PrintBuchstabe:
	Lea	ScrollText(PC),A0
	Add	-1(A2),A0		   ; string
	Moveq	#1,D0	 	  ; count
	Jsr	Text(A6)		    ; A1=RastPort

Bra2:   Lea	Copperlist+6,A1
	Lea	ScrollText-1(PC),A0

; Scrollen des grossen Schriftzueges
; er wird durch veraendern der HintergrundBitmap Startaddresse
; gescrollt.
	Tst.b	(A0)
	Beq.s	Scrollrunter
	Add	#46,(A1)		    ; Scrollwert * 46
	Bra.s	Hochgescrollt
Scrollrunter:
	Sub	#46,(A1)		    ; Scrollwert * 46
Hochgescrollt:
	Movem.l	(sp)+,d0-d7/a0-a6
Dummy:  Jmp	$ffffffff

Gfx.name:dc.b "graphics.library",0
AktBuchstabe:dc.b $ff

Farbtabelle:
	dc.w	$005,$006,$007,$008,$009,$00a,$00b,$00c,$00d,$00e,$00f
	dc.w	$50f,$60f,$70f,$80f,$90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f

TextScrollFeld:
	dc.l	$dc09fffe	; WAIT 8, 220
	dc.l	$00e2b058	; MOVE $b058 -> BPL1PTL
	dc.l	$01800aaf	; MOVE $aaf  -> COLOR0
	dc.l	$de09fffe	; WAIT 8, 222
	dc.l	$0180086f	; MOVE $86f  -> COLOR0
	dc.l	$e609fffe	; WAIT 8,230
	dc.l	$01820fff	; MOVE $fff -> COLOR1
	dc.l	$e709fffe	; WAIT 8,231
	dc.l	$01820fdd	; MOVE $fdd -> COLOR1
	dc.l	$e809fffe	; WAIT 8,232
	dc.l	$01820fcc	; MOVE $fbb -> COLOR1
	dc.l	$e909fffe	; WAIT 8,233
	dc.l	$01820faa	; MOVE $faa -> COLOR1
	dc.l	$ea09fffe	; WAIT 8,234
	dc.l	$01820f99	; MOVE $f99 -> COLOR1
	dc.l	$eb09fffe	; WAIT 8,235
	dc.l	$01820f77	; MOVE $f77 -> COLOR1
	dc.l	$ec09fffe	; WAIT 8,236
	dc.l	$01820f66	; MOVE $f55 -> COLOR1
	dc.l	$ed09fffe	; WAIT 8,237
	dc.l	$01820f44	; MOVE $f33 -> COLOR1
	dc.l	$ee09fffe	; WAIT 8,238
	dc.l	$01820f33	; MOVE $f11 -> COLOR1
	dc.l	$ef09fffe	; WAIT 8,239
	dc.l	$01820f00	; MOVE $f00 -> COLOR1
	dc.l	$f609fffe	; WAIT 8, 246
	dc.l	$0180042f	; MOVE $42f  -> COLOR0
	dc.l	$f809fffe	; WAIT 8, 248
	dc.l	$01800000	; MOVE $000  -> COLOR0

BobTab:
	dc.b	65,80,105,90	; T 1
	dc.b	80,90,90,120	; T 2

	dc.b	110,80,120,120  ; H 3
	dc.b	120,95,140,105  ; H 4
	dc.b	140,80,150,120  ; H 5

	dc.b	155,85,165,115  ; E 6
	dc.b	160,80,195,90   ; E 7
	dc.b	165,95,185,105  ; E 8
	dc.b	160,110,195,120 ; E 9

	dc.b	0,130,35,140	; P 10
	dc.b	30,135,40,150   ; P 11
	dc.b	10,145,35,155   ; P 12
	dc.b	0,145,10,170	; P 13
	dc.b	45,160,55,170   ; Punkt 14

	dc.b	60,130,95,140   ; R 15
	dc.b	90,135,100,150  ; R 16
	dc.b	60,145,95,155   ; R 17
	dc.b	60,155,70,170   ; R 18
	dc.b	90,155,100,170  ; R 19
	dc.b	105,160,115,170 ; Punkt 20

	dc.b	120,135,130,165 ; O 21
	dc.b	125,130,155,140 ; O 22
	dc.b	150,135,160,165 ; O 23
	dc.b	125,160,155,170 ; O 24
	dc.b	165,160,175,170 ; Punkt 25

	dc.b	180,135,190,170 ; F 26
	dc.b	185,130,220,140 ; F 27
	dc.b	190,145,210,155 ; F 28
	dc.b	215,160,225,170 ; Punkt 29

	dc.b	230,130,240,170 ; I 30
	dc.b	245,160,255,170 ; Punkt 31

	dc.b	1
	dc.b	0

ScrollText:
	dc.b	"K-Seka Assembler Diskette von The P.R.O.F.I.  "
	dc.b	"many greetings to ICI  "
TextEnde:

End:
	dcb.b	512,0
