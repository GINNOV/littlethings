
	section	caz,code_C

run:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$50000,a0
	move.l	#5120,d0
clr_bitmap:
	clr.l	(a0)+
	dbra	d0,clr_bitmap
	bsr	star_init

	move.l	4,a6
	jsr	-132(a6)
	move.w	#$03f0,$dff096
	move.l	#copperlist,$dff080
	clr.w	$dff088
	move.w	#$83c0,$dff096
	move.w	#$4000,$dff09a
	move.w	#$c010,$dff09a
wait:
	cmpi.b	#$ff,$dff006
	bne.s	wait
	bsr	stars
	btst	#6,$bfe001
	bne.w	wait
	move.w	#$4010,$dff09a
	move.w	#$c000,$dff09a
	move.l	#gfxlib,a1
	move.l	4,a6
	jsr	-408(a6)
	move.l	d0,a4
	move.w	#$03ff,$dff096
	move.l	38(a4),$dff080
	clr.w	$dff088
	move.w	#$83f0,$dff096
	move.l	a4,a1
	jsr	-414(a6)
	jsr	-138(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts


copperlist:
	dc.w	$00e0,$0005,$00e2,$0000,$0102,$0000
	dc.w	$00e4,$0005,$00e6,$2800
	dc.w	$0100,$2200,$0104,$0000,$0108,$0000,$010a,$0000
	dc.w	$008e,$3081,$0090,$30c1,$0092,$0038,$0094,$00d0
	dc.w	$0180,$0000,$0182,$0555,$0184,$0aaa,$0186,$0fff
	dc.w	$1fc,0
	dc.w	$106,0
	dc.w	$ffff,$fffe
gfxlib:
	dc.b	"graphics.library",0
	even

star_init:

;generiere random

 	MOVE.W #$45,D3
 	MOVE.L #ran_tab,A0
ran_loop:
	BSR get_ran		;get randomvalue
	add.w	#4008,d0
 	MOVE.W D0,(A0)+		;nach a0+
 	BSR get_ran		;noch eine
	add.w	#4008,d0
 	MOVE.W D0,(A0)+		;und save
 	BSR get_ran		;noch eine
 	ANDI.W #$1FF,D0		;kleiner 512
 	MOVE.W D0,(A0)+		;und save
 	DBRA D3,ran_loop
	rts		
	
stars:
	MOVE.L #ran_tab,A4	;randomtab nach a4	
 	MOVE.W #$45,D3		;70 mal
 	MOVE.L #ran2_tab,A5	;newtab nach a5
star_loop:
	MOVE.W (A4)+,D4		
 	MOVE.W (A4)+,D5
 	MOVE.W (A4),D6
 	SUBI.W #2,(A4)+		;erniedrige a4 um 2
 	TST.W D6		;6 = 0
 	BLE L0584BE		;kleiner
 	EXT.L D4		;d4 zu longword
	DIVS D6,D4		;dividiere d4/d6 horizontal
 	ADDI.W #160,D4		;+160 = mitte
	EXT.L D5		;erweitere d5
 	DIVS D6,D5		;divi vertical
 	ADDI.W #128,D5		;+128 = mitte		
 	TST.W D4		; d4 = 0
 	BLT L0584BE		; ja neue randomwerte
 	TST.W D5		; d5 = 0
 	BLT L0584BE		; neue werte
 	CMPI.W #319,D4		; ende horizontal
 	BGT L0584BE		;neue werte
 	CMPI.W #255,D5		;ende vertical
 	BGT L0584BE		;neue werte
 	MOVE.W (A5),D0		;a5 nach d0
 	MOVE.W D4,(A5)+		;d4 rett
 	MOVE.W (A5),D1		;a5 nach d1
 	MOVE.W D5,(A5)+		;d5 rett
 	BSR loesch		;loesch star
 	MOVE.W D4,D0		;d4 nach d0 = x
 	MOVE.W D5,D1		;d5 nach d1 = y
 	MULU #$28,D1		;zeile
 	MOVE.W D0,D2		;d0 nach d2
 	ASR.W #3,D2		;durch 8
 	ADD.W D2,D1		;add zur zeile die spalte
 	ASL.W #3,D2		;mal 8
	SUB.W D0,D2		;?
	SUBQ.B #1,D2		;minus 1
 	CMPI.W #350,D6		; d6 = 400		
 	BGT.S L058428		;groesser > 58428
 	CMPI.W #250,D6		;d6 = 300		
 	BGT.S L058434		; groesser = 58434 
 	BRA.S L058440		;ansonnsten 58440
L058428:
	MOVE.L #$50000,A1
 	ADDA.L D1,A1
 	BSET D2,(A1)
 	BRA.S L058454
L058434:
	MOVE.L #$50000+$2800,A1
 	ADDA.L D1,A1
 	BSET D2,(A1)
 	BRA.S L058454
L058440:
	MOVE.L #$50000,A1
 	ADDA.L D1,A1
 	BSET D2,(A1)
 	MOVE.L #$50000+$2800,A1
 	ADDA.L D1,A1
 	BSET D2,(A1)
L058454:
	DBRA D3,star_loop

 	RTS
	ran_pointer:	dc.w	0
get_ran:
	move.w	$dff006,d0
 	LEA l058604,A3
 	MULS (A3),D0
 	ADDI.W #$1249,D0
 	EXT.L D0
 	LEA L058604(PC),A3
 	MOVE.W D0,(A3)
 RTS
L0584BE:
	SUBA.L #6,A4
	BSR get_ran
 	MOVE.W D0,(A4)+
 	BSR get_ran
 	MOVE.W D0,(A4)+
 	BSR get_ran
	and.w	#600,d0	 
	MOVE.W d0,(A4)+
 	BRA L058454
loesch:
	MULU #$28,D1
 	MOVE.W D0,D2
 	ASR.W #3,D2
 	ADD.W D2,D1
 	ASL.W #3,D2
 	SUB.W D0,D2
 	SUBQ.B #1,D2
 	MOVE.L #$50000,A1
 	ADDA.L D1,A1
 	BCLR D2,(A1)
 	MOVE.L #$50000+$2800,A1
 	ADDA.L D1,A1
 	BCLR D2,(A1)
 	RTS

l058604:dc.w	0
	dc.w	0
ran_tab:
	blk.w	210,0
ran2_tab:
	blk.w	210,0
