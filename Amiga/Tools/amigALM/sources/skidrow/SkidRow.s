	* SkidRow Intro by Raise/Parasite *
	*   Graphics by Airwalk/Kefrens   *
	*     Disassembled by Frantic     *

	SECTION	"SkidRow Intro",CODE_C

;--------------------------------------;

WaitBlt	MACRO
WB\@	btst	#14,2(a6)
	bne.s	WB\@
	ENDM

;--------------------------------------;

Start	jsr	mt_init
	bsr.l	PushBPL
	lea	$dff000,a6
	move.w	$1e(a6),IntReq
	move.w	$1c(a6),IntEna
	move.w	#$7fff,$9c(a6)
	move.w	#$7fff,$9a(a6)
	move.l	$6c,OldIRQ
	move.l	#NewIRQ,$6c
	move.w	#$c020,$9a(a6)
	move.w	#$83f0,$dff096
WaitMse	btst	#6,$bfe001
	bne.s	WaitMse
	jsr	mt_end
	lea	$dff000,a6
	move.l	OldIRQ,$6c
	or.w	#$8000,IntEna
	or.w	#$8000,IntReq
	move.w	IntReq,$9c(a6)
	move.w	IntEna,$9a(a6)
	move.w	#$8020,$96(a6)
	clr.l	d0
	rts

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	move.w	$dff01e,d0
	btst	#5,d0
	beq.s	NoVertB
	move.l	#CopList,$dff084
	clr.w	$dff08a
	bsr.s	MainRtn
NoVertB	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	move.w	#$8020,$dff09a
	rte

;--------------------------------------;

PushBPL	lea	BPL,a0
	move.l	#3,d7
	move.l	#TxtArea,d0
PshLoop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#256*(320/8),d0
	add.l	#8,a0
	dbf	d7,PshLoop
	rts

;--------------------------------------;

IntReq	dc.w	0,0
IntEna	dc.w	0,0
OldIRQ	dc.l	0
DMACon	dc.w	0,0		;Unused

;--------------------------------------;

MainRtn	jsr	mt_music
	lea	$dff000,a6
	sub.w	#1,IntSwch
	cmp.w	#0,IntSwch
	bne.s	NoIntro
	add.w	#1,IntSwch
	bra.s	DoIntro
NoIntro	rts

DoIntro	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7

	btst	#0,IntFlgs
	bne.l	NoText
	REPT	16
	jsr	PutText
	ENDR

NoText	lea	MskArea,a0
	btst	#2,IntFlgs
	bne.s	TstWipe

	btst	#0,IntFlgs
	beq.s	TstWipe
	move.w	#0,MTrmPnt
	REPT	8
	jsr	DrawMsk
	ENDR

TstWipe	btst	#2,IntFlgs
	beq.s	NoEndDl

	sub.w	#1,TxDelay
	bne.s	NoEndDl
	add.w	#1,TxDelay
	move.w	#1,MTrmPnt
	bset	#3,IntFlgs
	REPT	8
	jsr	DrawMsk
	ENDR
NoEndDl	rts

;--------------------------------------;

DrawMsk	move.w	LnPosX1,d0
	move.w	LnPosX2,d2
	move.w	LnPosY1,d1
	move.w	LnPosY2,d3
	jsr	DrawLne
	btst	#1,IntFlgs
	bne.s	LneHorz
LneVert	sub.w	#1,LnPosY2
	add.w	#1,LnPosY1
	cmp.w	#256,LnPosY1
	bmi.s	NoLneFn
	bchg	#1,IntFlgs
NoLneFn	jmp	DrawEnd

LneHorz	add.w	#1,LnPosX1
	sub.w	#1,LnPosX2
	cmp.w	#320,LnPosX1
	bmi.l	DrawEnd
	bset	#2,IntFlgs
	move.w	#8*50,TxDelay
	bchg	#1,IntFlgs
	btst	#3,IntFlgs
	beq.l	NoReset

	clr.b	IntFlgs
	clr.l	PstnY
	clr.l	AdressX
	clr.l	PstnX
	move.w	#$09f0,BltCon1
	move.w	#$0dfc,BltCon2

	WaitBlt
	lea	TxtArea,a0
	move.l	a0,$54(a6)
	move.w	#$0000,$66(a6)
	move.l	#$01000000,$40(a6)
	move.w	#3*256<<6+(320/16),$58(a6)
	WaitBlt

	lea	MskArea,a0
	move.l	a0,$54(a6)
	move.w	#$0000,$66(a6)
	move.l	#$01ff0000,$40(a6)
	move.w	#256<<6+(320/16),$58(a6)
	WaitBlt

NoReset	clr.w	LnPosX1
	clr.w	LnPosY1
	move.w	#319,LnPosX2
	move.w	#255,LnPosY2
DrawEnd	rts

;--------------------------------------;

PutText	lea	TxtArea,a0
	lea	Buffer,a1
	lea	FontDat,a2
	lea	Text,a3
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.l	TxtPntr,d2
	and.w	#$0fff,BltCon1
	move.w	BltCon1,d1
	move.b	(a3,d2.l),d0
	cmp.b	#-2,d0
	bne.s	NoRstPg
	clr.l	TxtPntr
	bset	#0,IntFlgs
	sub.l	#2,TxtPntr

NoRstPg	cmp.b	#-1,d0
	bne.s	NoNewPg
	bset	#0,IntFlgs

NoNewPg	sub.w	#32,d0
	move.w	d0,d2
	eor.w	#1,d0
	and.w	#1,d0
	lsl.w	#3,d0
	ror.w	#4,d0
	or.w	d0,d1
	move.w	d1,BltCon1
	add.l	d2,a2
	move.w	#38,$62(a6)
	move.w	#58,$64(a6)
	move.w	#38,$66(a6)
	move.w	#$ffff,$44(a6)
	move.w	#$ffff,$46(a6)
	move.l	a1,$54(a6)
	move.l	#$01000000,$40(a6)
	move.w	#3*18<<6+1,$58(a6)
	WaitBlt
	move.l	#2,d7
CpyBPL1	move.l	a2,$50(a6)
	move.l	a1,$54(a6)
	move.w	BltCon1,$40(a6)
	move.w	#18<<6+1,$58(a6)
	WaitBlt
	add.l	#18*(480/8),a2
	add.l	#18*(320/8),a1
	dbf	d7,CpyBPL1
	move.w	#36,$62(a6)
	move.w	#36,$64(a6)
	move.w	#36,$66(a6)
	lea	TxtArea,a0
	add.l	#19*(320/8),a0
	add.l	PstnY,a0
	add.l	AdressX,a0
	lea	Buffer,a1
	move.w	#$ff00,$44(a6)
	move.w	#$0000,$46(a6)
	move.l	#2,d7
CpyBPL2	move.l	a0,$4c(a6)
	move.l	a1,$50(a6)
	move.l	a0,$54(a6)
	move.w	BltCon2,$40(a6)
	move.w	#18<<6+2,$58(a6)
	WaitBlt
	add.l	#18*(320/8),a1
	add.l	#256*(320/8),a0
	dbf	d7,CpyBPL2
	add.l	#1,TxtPntr
	add.l	#9,PstnX
	cmp.l	#9*35,PstnX
	bne.s	NoEndLn
	clr.l	PstnX
	add.l	#22*(320/8),PstnY
NoEndLn	move.l	PstnX,d0
	move.l	d0,d2
	and.l	#$f,d0
	ror.w	#4,d0
	and.w	#$0fff,BltCon2
	move.w	BltCon2,d1
	or.w	d0,d1
	move.w	d1,BltCon2
	lsr.l	#3,d2
	move.l	d2,AdressX
	rts

;--------------------------------------;

DrawLne	clr.l	d4
	sub.w	d1,d3
	bge.s	Y1LY2
	neg.w	d3
	bra.s	Y1GY2
Y1LY2	bset	#0,d4
Y1GY2	sub.w	d0,d2
	bge.s	X1LX2
	neg.w	d2
	bra.s	X1GX2
X1LX2	bset	#1,d4
X1GX2	move.w	d2,d5
	sub.w	d3,d5
	bge.s	YLX
	exg	d2,d3
	bra.s	YGX
YLX	bset	#2,d4
YGX	clr.w	d5
	ror.w	#4,d0
	or.w	#$0b00,d0
	move.b	d0,d5
	move.w	MTrmPnt,d6
	lea	MnTerms,a5
	move.b	(a5,d6.w),d0
	lsl.w	#1,d5
	muls	#(320/8),d1
	add.w	d5,d1
	add.l	a0,d1
BltWait	btst	#14,$dff002
	bne.s	BltWait
	move.b	Octants(pc,d4.w),d4
	add.l	d3,d3
	move.w	d3,$62(a6)
	sub.w	d2,d3
	bge.s	LneOver
	or.b	#$40,d4
LneOver	move.l	d3,$50(a6)
	sub.w	d2,d3
	move.w	d3,$64(a6)
	move.w	d4,$42(a6)
	move.w	d0,$40(a6)
	move.l	d1,$48(a6)
	move.l	d1,$54(a6)
	move.w	#(320/8),$60(a6)
	move.w	#(320/8),$66(a6)
	move.w	#$8000,$74(a6)
	move.w	#$ffff,$44(a6)
	move.w	#$ffff,$72(a6)
	asl.w	#6,d2
	add.w	#2,d2
	move.w	d2,$58(a6)
	rts

Octants	dc.b	3<<2+1,2<<2+1
	dc.b	1<<2+1,0<<2+1
	dc.b	7<<2+1,5<<2+1
	dc.b	6<<2+1,4<<2+1

;--------------------------------------;

CopList	dc.w	$0100,$0200,$0102,$0000
	dc.w	$0104,$0000,$0096,$0020
	dc.w	$008e,$2880,$0090,$28c0
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0120,$0000,$0122,$0000

	dc.w	$0180,$0000
	dc.w	$0184,$0004,$0186,$0004
	dc.w	$0188,$0004,$018a,$0004
	dc.w	$018c,$0004,$018e,$0004
	dc.w	$0190,$0004,$0192,$0004
	dc.w	$0194,$0004,$0196,$0004
	dc.w	$0198,$0004,$019a,$0004
	dc.w	$019c,$0004,$019e,$0004

	dc.w	$2707,$fffe,$0180,$0fff
	dc.w	$2807,$fffe,$0180,$0000
	dc.w	$0100,$4200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000

	dc.w	$0190,$0004,$0192,$0004
	dc.w	$0194,$0004,$0196,$0004
	dc.w	$0198,$0004,$019a,$0004
	dc.w	$019c,$0004,$019e,$0004
	dc.w	$0180,$0004,$0182,$0bcf
	dc.w	$0184,$09bd,$0186,$089b
	dc.w	$0188,$0789,$018a,$0568
	dc.w	$018c,$0456,$018e,$0fff

	dc.w	$ffdf,$fffe
	dc.w	$1507,$fffe,$0100,$0200
	dc.w	$2807,$fffe,$0180,$0fff
	dc.w	$2907,$fffe,$0180,$0000
	dc.w	$ffff,$fffe

;--------------------------------------;

	dcb.b	8,0
Text	dc.b	"        - S K I D  R O W -         "
        dc.b	"  THE LEADING FORCE IS BACK WITH:  "
        dc.b	"                                   "
        dc.b	"       ..PINBALL DREAMS II..       "
        dc.b	"                                   "
        dc.b	" CRACKED BY..............BLACKHAWK "
        dc.b	" ORIGINAL BY..BOMBER MAN AND WILLY "
        dc.b	"                                   "
        dc.b	"   REMEMBER TO BUY THE ORIGINAL!   "
        dc.b	"                                   "
        dc.b	-1,0

	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"   HERE IS A COMPLETE MEMBERLIST:  "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"-----------------------------------"
	dc.b	"     ANNIHILATOR..ANON..BANDITT    "
	dc.b	"  BATBLASTER..BEACH BUM..BLACKHAWK "
	dc.b	" BOMBER MAN..D-MAN..DOCTOR REVENGE "
	dc.b	"EAST COAST..EAGLE'S TALON..EUROSOFT"
	dc.b	" FFC..HUSTLER..ICEBERG..JABBAWOCKY "
	dc.b	" JACK..JANITOR..KITARO..MAJOR THEFT"
	dc.b	" MARC..MARSHAL..MAXIMILIAN..MESSIAH"
	dc.b	"   MR.XEROX..MUNCHIE..NIGHTSPAWN   "
	dc.b	"------------------------------- 1 -"
	dc.b	-1,0

	dc.b	"-----------------------------------"
	dc.b	" PARAGON..PHIL DOUGLAS..PHONESTUD  "
	dc.b	" RICK..SCOOTER.SHOCK..SHUT BERLIN  "
	dc.b	"    SLASH..SLUGGER..SOULTAKER      "
	dc.b	"SPEED MASTER..STINGRAY..TARZAN..TFT"
	dc.b	"    THE CORSAIR..THE DESPISER      "
	dc.b	"THE HELLION..THE Z..TORNADO..TOYMAN"
	dc.b	" WACKY..WILDCARD..WILDTHING..WILLY "
	dc.b	"      WOLVERINE..ZOOL..ZOOM        "
	dc.b	"--------------------------------2 -"
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"         WRITE TO SKID ROW:        "
	dc.b	"       (NO SWAPPING PLEASE!)       "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"            -SKID ROW-             "
	dc.b	"PB 151 , 2800 MECHELEN 2 , BELGIUM."
	dc.b	"POSTE RES. , 8450 HAMMEL , DENMARK."
	dc.b	"..BP 13 , 85370 MONTIGNY , FRANCE.."
	dc.b	".PO BOX 28 , 36055 NOVE (VICENSA).."
	dc.b	".............ITALY................."
	dc.b	"....PO BOX 55293 , SHERMAN OAKS...."
	dc.b	"..........CA 91413 , USA..........."
	dc.b	".POSTE RESTANTE-SEJS , 8600 SKB 13."
	dc.b	"..............DENMARK.............."
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"    CALL OUR BOARDS WORLDWIDE:     "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"      ..UNLAWFUL ENTRY - WHQ..     "
	dc.b	"           612-754-0266            "
	dc.b	"                                   "
	dc.b	"       ..AMIGA EAST - USHQ..       "
	dc.b	"           804-499-2266            "
	dc.b	"                                   "
	dc.b	"     ..BOGUS EXCEPTION - USHQ..    "
	dc.b	"           203-848-2250            "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"       ..SANCTUARY - USHQ..        "
	dc.b	"           708-969-8325            "
	dc.b	"                                   "
	dc.b	"     ..ELUSIVE DREAMS - USHQ..     "
	dc.b	"           317-868-9464            "
	dc.b	"                                   "
	dc.b	"     ..HUSTLERS HAVEN - USHQ..     "
	dc.b	"           215-324-6918            "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"   ..LIGHT HOUSE EXPRESS - DIST..  "
	dc.b	"           407-624-4329            "
	dc.b	"                                   "
	dc.b	"         ..BALKAN - CHQ..          "
	dc.b	"           416-607-6267            "
	dc.b	"                                   "
	dc.b	"     ..CYBORG COMMAND - USHQ..     "
	dc.b	"           206-531-0817            "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	" ..CENTRAL NERVOUS SYSTEM - USHQ.. "
	dc.b	"           414-832-1449            "
	dc.b	"                                   "
	dc.b	"         ..NIRVANA - USHQ..        "
	dc.b	"           516-364-6257            "
	dc.b	"                                   "
	dc.b	"        ..TERRORDOME - CHQ..       "
	dc.b	"           416-619-1717            "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"    ..WORLD TRADE CENTER - EHQ..   "
	dc.b	"          +49-304-966-037          "
	dc.b	"                                   "
	dc.b	"     ..PLASTIC PASSION - DKHQ..    "
	dc.b	"           +45-982-38413           "
	dc.b	"                                   "
	dc.b	"        ..MILLENNIA - UKHQ..       "
	dc.b	"           +44-91-2843142          "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"      ..MUSICAL PHARMACY - IHQ..   "
	dc.b	"           +39-81-5751248          "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"       CREDITS FOR THIS INTRO      "
	dc.b	"       ----------------------      "
	dc.b	"                                   "
	dc.b	" ORGANIZATION...............TARZAN "
	dc.b	"                                   "
	dc.b	" CODING.............RAISE/PARASITE "
	dc.b	"                                   "
	dc.b	" GRAPHICS..........AIRWALK/KEFRENS "
	dc.b	"                                   "
	dc.b	" GREAT MUSIC...................HCO "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	-1,0

	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"      ADIOS AMIGO AND SEE YOU      "
	dc.b	"                                   "
	dc.b	"     IN THE NEXT MAJOR RELEASE     "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	"                                   "
	dc.b	-2,0

;--------------------------------------;

BltCon1	dc.w	$9f0
BltCon2	dc.w	$dfc
IntFlgs	dc.b	0
	even
TxtPntr	dc.l	0
PstnX	dc.l	0
PstnY	dc.l	0
AdressX	dc.l	0
LnPosX1	dc.w	0
LnPosX2	dc.w	319
LnPosY1	dc.w	0
LnPosY2	dc.w	255
TxDelay	dc.w	0
IntSwch	dc.w	1
MTrmPnt	dc.w	0
MnTerms	dc.b	$3a,$ca

;--------------------------------------;

TxtArea	dcb.b	3*256*(320/8),0
MskArea	dcb.b	1*256*(320/8),-1
Buffer	dcb.b	3*18*(320/8),0
Music	include	"DH2:SkidRow/ProTracker2.3A.i"
	dc.b	0
FontDat	incbin	"DH2:SkidRow/SkidRow.raw"
mt_data	incbin	"DH2:SkidRow/mod.DreamOff"

