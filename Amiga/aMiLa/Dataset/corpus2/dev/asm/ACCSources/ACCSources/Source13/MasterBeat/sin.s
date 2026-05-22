
 section Leeds,code_c
 opt c-,o+,ow-

max equ 2

WOBMAX EQU $24

go:



 
 jsr mt_init			; Start music
 
 
; move.l #sprite0,d0		; Get all the chips in order etc!
; move.w d0,sp0l
; swap d0
; move.w d0,sp0h
 
 move.l 4.w,a6
 jsr -132(a6)

 lea GFXLIB,a1
 MOVEQ #0,D0
 MOVE.L 4.w,a6
 JSR -$228(a6) ; OpenLibrary
 TST D0
 BEQ ERROR
 MOVE.L D0,GFXBASE
 
 bset #1,$bfe001
 
 move.l #blankplane,d0
 move.w d0,p2l3l
 swap d0
 move.w d0,p2l3h
 swap d0
 move.l #blankplane,d0
 move.w d0,p2l4l
 swap d0
 move.w d0,p2l4h
 swap d0
 
 
 move.l #showplane,d0
 move.w d0,zl6l
 swap d0
 move.w d0,zl6h
 
 
ff equ 8
 move.l #logo2+40*8,d0
 move.w d0,p2l0l
 swap d0
 move.w d0,p2l0h
 swap d0
 add.l #8000,d0
 move.w d0,p2l1l
 swap d0
 move.w d0,p2l1h
 swap d0
 add.l #8000,d0
 move.w d0,p2l2l
 swap d0
 move.w d0,p2l2h
 
 swap d0
 add.l #8000-40*8,d0
 move.l d0,a0
 lea cols2,a1				; We'll set the palette while
 lea cols3,a2				; we're at it
 moveq #31,d0
 move.w #$180,D2
ffl
 move.w d2,(a1)+
 move.w d2,(a2)+
 addq.w #2,d2
 move.w (a0)+,d3
 move.w d3,(a1)+
 lsr.w d3
 and.w #%0000011101110111,d3
 move.w d3,(a2)+
 dbra d0,ffl
 
 
 
 
 
 

 MOVE.L GFXBASE,A6
 ADD.L #$32,A6
 MOVE.W #$80,$dff096
 MOVE.L (A6),OLDCOPPER
 MOVE.L #NEWCOPPER,(A6)
 MOVE.W #$8080,$dff096

 move.w #$8010,$dff09a
 move.l $6c.w,old
 move.l  #new,$6c.w

WAIT: ANDI.B #$40,$BFE001
 Bne.s wait

 move.l old,$6c.w

 
 MOVE.L GFXBASE,A6
 ADD.L #$32,A6

 MOVE.W #$0080,$dff096
 MOVE.L OLDCOPPER,(A6)
 MOVE.W #$8080,$dff096
 
 
ERROR:
 jsr eggs
 move.l 4.w,a6
 jsr -138(a6)

 moveq #0,d0
 move.w #$f,$dff096
 move.w #$0,$dff0a8
 move.w #$0,$dff0b8
 move.w #$0,$dff0c8
 move.w #$0,$dff0d8
 RTS

new: movem.l d0-d7/a0-a6,-(sp)		; Our new interrupt
 and #$10,$dff01e        
 beq.s out
 move.w #$10,$dff09c

 jsr mt_music

 jsr scrolly

 subq.b #1,ctd
 bne.s out
 move.b #max,ctd


 bsr.s blittest
 
 subq.b #1,ct2
 bne.s out
 move.b #8,ct2
 

 
; interupt routine goes in here
 
out: movem.l (sp)+,d0-d7/a0-a6
 dc.w $4ef9
old: dc.l 0

ctd dc.b 1,0
ct2 dc.b 1,0
	
blittest: btst #14,$dff002
	bne.s blittest
	rts


OLDCOPPER: DC.L 0
NEWCOPPER:
 dc.w $100,$3600,$102,$0,$104,%1000000,$108,0,$10a,0
 dc.w $92,$38,$94,$d0,$8e,$5a71,$90,$f4c1,$e0

SP0H DC.W 0,$122
SP0L DC.W 0,$180,$0,$182,$0,$184,$0,$186,$0
  
 

cols2 dcb.l 32			; Start of logo 2 and sinescroll
  
  dc.w $5a09,$fffe,$100,$6200

   dc.w $e0
p2l0h: dc.w	0,$e2
p2l0l: dc.w	0,$e4
p2l1h: dc.w	0,$e6
p2l1l: dc.w	0,$e8
p2l2h: dc.w	0,$ea
p2l2l: dc.w	0,$ec
p2l3h: dc.w	0,$ee
p2l3l: dc.w	0,$f0
p2l4h: dc.w	0,$f2
p2l4l: dc.w 0,$f4
zl6h   dc.w 0,$f6
zl6l   dc.w 0
 
 dc.w	$9e09,$fffe		; This next copper list section
 dc.w	$180,$010		; is for the green "ground"
 dc.w	$a009,$fffe
 dc.w	$180,$020
 dc.w	$a209,$fffe
 dc.w	$180,$030
 dc.w	$a409,$fffe
 dc.w	$180,$040
 dc.w	$a609,$fffe
 dc.w	$180,$050
 dc.w	$a809,$fffe
 dc.w	$180,$050
 dc.w	$aa09,$fffe
 dc.w	$180,$060
 dc.w	$ac09,$fffe
 dc.w	$180,$070
 dc.w	$ae09,$fffe
 dc.w	$180,$080
 dc.w	$b009,$fffe
 dc.w	$180,$090
 dc.w	$b209,$fffe
 dc.w	$180,$0a0
 dc.w	$b409,$fffe
 dc.w	$180,$0b0
 dc.w	$b609,$fffe
 dc.w	$180,$0c0
 dc.w	$b809,$fffe
 dc.w	$180,$0d0
 dc.w	$ba09,$fffe
 dc.w	$180,$0e0
 dc.w	$bc09,$fffe
 dc.w	$180,$0f0


      
 dc.w $bf01,$fffe,$108,-120,$10a,-120	; Start of "water"
 dc.w $180,$0f0
cols3 dcb.l 32
 dc.w	$c0e1,$fffe
 dc.w	$180,$00e
 dc.w	$c4e1,$fffe
 dc.w	$180,$00d
 dc.w	$c8e1,$fffe
 dc.w	$180,$00c
 dc.w	$cbe1,$fffe
 dc.w	$180,$00b
 dc.w	$cee1,$fffe
 dc.w	$180,$00a
 dc.w	$d4e1,$fffe
 dc.w	$180,$009
 dc.w	$d8e1,$fffe
 dc.w	$180,$008
 dc.w	$dce1,$fffe
 dc.w	$180,$007
 dc.w	$dee1,$fffe
 dc.w	$180,$006
 dc.w	$e4e1,$fffe
 dc.w	$180,$005
 dc.w	$e8e1,$fffe
 dc.w	$180,$004
 dc.w	$ebe1,$fffe
 dc.w	$180,$003
 dc.w	$eee1,$fffe
 dc.w	$180,$002
 dc.w	$f4e1,$fffe
 dc.w	$180,$001
 dc.w	$f8e1,$fffe
 dc.w	$180,$000

 dc.w $2b09,$fffe
 dc.w $9c,$8010,$ffff,$fffe
 
  ; End copper
gfxlib: dc.b "graphics.library",0 	; Someone's gotta use 'em...
 EVEN
gfxbase: dc.l 0



scrollplane: dcb.b 8000,0

blankplane dcb.b 8000,0

logo2: incbin "source:bitmaps/logo3"

eggs:
	move.w	#$0222,$dff180
	move.w	#$0444,$dff180
	move.w	#$0666,$dff180
	move.w	#$0888,$dff180
	move.w	#$0aaa,$dff180
	move.w	#$0ccc,$dff180
	
	rts
	
sinscroll:
; first blit clear the scrolly

	lea showplane+35*40,a0		; visible bitplane
blitready:
	btst #14,$dff002		
	bne.s blitready			; wait till blitter ready

	move.l a0,$dff054		; source address
	move.l a0,$dff050		; destination address
	clr.l $dff044			; no FWM/LWM (see hardware manual)
	clr.l $dff064			; no MODULO (see hardware manual)

	move.w #%100000000,$dff040 	; Enable DMA channel D, nothing
					; else, no minterms active. 
	clr.w $dff042			; nothing set in BLTCON1
	move.w #%111100010101,$dff058	; Window size = 21 words wide
					; 60 lines deep


	move.l sinpt,a3
	subq.l #1,a3
	move.b (a3),d0
	cmp.b #255,d0
	bne.s notendofsine
	lea sintabend(pc),a3
notendofsine:
	move.l a3,sinpt

	moveq #19,d0
	lea scplane2,a0
	lea showplane+35*40-2,a1

sloop3:

	bsr getsinval

blitready2
	btst #14,$dff002
	bne.s blitready2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l #$f000f000,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #%0000100111110000,$dff040
	clr.w $dff042
	move.w #%100000000001,$dff058

	bsr getsinval

zonk2:
	btst #14,$dff002
	bne zonk2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f00,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
 	clr.w $dff042
	move.w #%100000000001,$dff058

	bsr getsinval
zonk3:
	btst #14,$dff002
	bne zonk3

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f0,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #%100000000001,$dff058

	bsr getsinval
zonk4:
	btst #14,$dff002
	bne zonk4
	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #%100000000001,$dff058



	addq.l #2,a0
LOAD	addq.l #2,a1
	dbra d0,sloop3

rts

getsinval:
	moveq #0,d1
	move.b (a3)+,d1
	move.b (a3),d2
	cmp.b #255,d2
	bne okyar
	move.l #sintab,a3
okyar:
	lsr.b #1,d1
	bclr #0,d1
	mulu #20,d1
	move.l a1,a2
	add.l d1,a2
	rts


scrolly: 
	bsr sinscroll
	btst	#2,$dff016		Is it RMB?
	bne	continuescroll		No, so scroll past
	rts


continuescroll:
	move.b pause,d0
	cmp.b #0,d0
	beq gopast
	sub.b #1,d0
	move.b d0,pause
	bra gopast2
gopast:
	move.l #scplane2,a0
	move.l #scplane2+2,a1
blitready3:
	btst #14,$dff002
	bne blitready3
	move.l a0,$dff054
	move.l a1,$dff050
	move.l #-1,$dff044
	clr.l $dff064
	move.w #%1100100111110000,$dff040
	clr.w $dff042
	move.w #%101000010111,$dff058
gopast2:

	move.b pause,d0
	cmp.b #0,d0
	bne iuo

	move.b countdown,d0
	sub.b #1,d0
	cmp.b #0,d0
	beq mfc
	move.b d0,countdown
iuo:
	rts
	
countdown:
	dc.b 4,0


sinpt: 	dc.l sintabend		
sinpt2: dc.l sintab2

eqtab	ds.b 40


 	dc.b 255
sintab:			; As calculated by the Sinuscreator


	dc.b	-56,-56,-57,-58,-59,-61,-63,-66
	dc.b	-68,-72,-75,-79,-83,-88,-92,-97
	dc.b	-102,-108,-113,-119,-125,125,119,113
	dc.b	106,100,94,87,81,75,69,63
	dc.b	57,52,46,41,36,32,27,23
	dc.b	19,16,12,10,7,5,3,2
	dc.b	1,0,0,0,1,2,3,5
	dc.b	7,10,12,16,19,23,27,32
	dc.b	36,41,46,52,57,63,69,75
	dc.b	81,87,94,100,106,113,119,125
	dc.b	-125,-119,-113,-108,-102,-97,-92,-88
	dc.b	-83,-79,-75,-72,-68,-66,-63,-61
	dc.b	-59,-58,-57,-56


sintabend:
 dc.b -56,255


sintab2:

 dc.b $2D,$31,$34,$38,$3B,$3E,$41,$45,$47,$4A,$4D,$4F,$51,$53,$55,$57
 dc.b $58,$59,$59,$5A,$5A,$5A,$59,$59,$58,$57,$55,$53,$51,$4F,$4D,$4A
 dc.b $47,$45,$41,$3E,$3B,$38,$34,$31,$2D,$29,$26,$22,$1F,$1C,$19,$15
 dc.b $13,$10,$D,$B,$9,$7,$5,$3,$2,$1,$1,$0,$0,$0,$1,$1,$2,$3,$5,$7,$9
 dc.b $B,$D,$10,$13,$15,$19,$1C,$1F,$22,$26,$29,$ff

pause: 	dc.b 0
sinmodulo:
	dc.b 0

 	even
mfc:
	move.b #4,countdown
	clr.w scplane2+40
	clr.w scplane2+82
	move.l #scplane2+124,a1
	bsr charaddress

	moveq #15,d0
zonkin:
	move.w (a0),(a1)
	lea 40(a0),a0
	lea 42(a1),a1
	dbf d0,zonkin

	rts
CHARADDRESS:
	move.l mesptr,a0
	moveq #0,d0
	move.l d0,d1
	move.l d0,d2
	move.b (a0)+,d0
	cmp.b #$0a,d0
	bne wizy
	move.b #32,d0
wizy:
	cmp.b #120,d0
	bne wazy
	move.l #message,a0
	move.b #32,d0
wazy:
	cmp.b #97,d0
	bne wozy
	move.b #32,d0
	move.b #$60,pause
wozy:
	move.l a0,mesptr

	sub.b #32,d0 
 	moveq #0,d1
 	divu #20,d0  		; 20 chars on each line
 	move.b d0,d1 
 	clr.w d0
 	swap d0  
	move.l #fnt2,a0
	mulu #640,d1
	add.l d0,d0
	add.l d0,a0
	add.l d1,a0

	rts


 even
 
 
SPRITE0 DC.W 0,0,0,0,0,0
mesptr: dc.l message
message:
        ;012345678901234567890


 DC.B	"     MASTER BEAT    a      PRESENTS.........   "
 DC.B	"   SINE INTRO V2.0  a  A CUT-DOWN VERSION OF THE "
 DC.B	"DEMO ON ACC 9.     "
 DC.B	"THE MUSIC IS RIPPED FROM AN ANGELS INTRO     "
 DC.B	" DON'T WORRY, THERE WILL BE NO HUGE "
 DC.B	"LISTS OF GREETS OR SCROLLTEXT ON THIS ONE, JUST A FEW GOLDEN HANDSHAKES TO : "
 DC.B	"EVERYONE WHO CONTRIBUTES TO ACC, ESPECIALLY    " 
 DC.B	"  BLAINE EVANS (FM) a     AND A QUICK SHOUT TO : JONTY AND JEDI OF XCESS, "
 DC.B	" DALE WILKS (I WILL WRITE SOON), KREATOR/ANARCHY UK (GOOD LUCK!), AND "
 DC.B	"THE HORSFORTH COMPUTER CENTRE, WHO PAY ME FOR COPYING PD.......     "
 DC.B	"THIS IS A UNITY RELEASE IN 1991............"
 DC.B 	"               x"
 

	
	even
showplane: 	ds.b 8000
scplane2: 	ds.b 2500
fnt2: 		incbin source:Fonts/16font3




*** END OF MY CODE ***



**************************************
*   NoisetrackerV1.0 replayroutine   *
* Mahoney & Kaktus - HALLONSOFT 1989 *
**************************************


mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts




mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0

mt_data
 incbin "source:Modules/mod.gonads cracks"


;EQUATES for HARDWARE REGISTERS


; NOTE: For more information about these hardware registers, read
; either the 'Amiga Hardware Reference Manual' by Addison Wesley or
; the 'Amiga System Programmers Guide' by Abacus, both of which
; document them fully.

bltddat	EQU   $000
dmaconr	EQU   $002
vposr	EQU   $004
vhposr	EQU   $006
dskdatr	EQU   $008
joy0dat	EQU   $00A
joy1dat	EQU   $00C
clxdat	EQU   $00E

adkconr	EQU   $010
pot0dat	EQU   $012
pot1dat	EQU   $014
potinp	EQU   $016
serdatr	EQU   $018
dskbytr	EQU   $01A
intenar	EQU   $01C
intreqr	EQU   $01E

dskpt	EQU   $020
dsklen	EQU   $024
dskdat	EQU   $026
refptr	EQU   $028
vposw	EQU   $02A
vhposw	EQU   $02C
copcon	EQU   $02E
serdat	EQU   $030
serper	EQU   $032
potgo	EQU   $034
joytest	EQU   $036
strequ	EQU   $038
strvbl	EQU   $03A
strhor	EQU   $03C
strlong	EQU   $03E

bltcon0	EQU   $040
bltcon1	EQU   $042
bltafwm	EQU   $044
bltalwm	EQU   $046
bltcpth	EQU   $048
bltcptl EQU   $04A
bltbpth	EQU   $04C
bltbptl EQU   $04E
bltapth	EQU   $050
bltaptl EQU   $052
bltdpth	EQU   $054
bltdptl EQU   $056
bltsize	EQU   $058

bltcmod	EQU   $060
bltbmod	EQU   $062
bltamod	EQU   $064
bltdmod	EQU   $066

bltcdat	EQU   $070
bltbdat	EQU   $072
bltadat	EQU   $074

dsksync	EQU   $07E

cop1lc	EQU   $080
cop2lc	EQU   $084
copjmp1	EQU   $088
copjmp2	EQU   $08A
copins	EQU   $08C
diwstrt	EQU   $08E
diwstop	EQU   $090
ddfstrt	EQU   $092
ddfstop	EQU   $094
dmacon	EQU   $096
clxcon	EQU   $098
intena	EQU   $09A
intreq	EQU   $09C
adkcon	EQU   $09E


aud0vol	EQU   $0A8
aud1vol EQU   $0B8
aud2vol	EQU   $0C8
aud3vol	EQU   $0D8

bpl1pth	EQU   $0E0
bpl1ptl	EQU   $0E2
bpl2pth	EQU   $0E4
bpl2ptl	EQU   $0E6
bpl3pth	EQU   $0E8
bpl3ptl	EQU   $0EA
bpl4pth	EQU   $0EC
bpl4ptl	EQU   $0EE
bpl5pth	EQU   $0F0
bpl5ptl	EQU   $0F2
bpl6pth	EQU   $0F4
bpl6ptl	EQU   $0F6

bplcon0	EQU   $100
bplcon1	EQU   $102
bplcon2	EQU   $104
bpl1mod	EQU   $108
bpl2mod	EQU   $10A

bpldat	EQU   $110

spr0pth	EQU   $120
spr0ptl EQU   $122
spr1pth EQU   $124
spr1ptl EQU   $126
spr2pth	EQU   $128
spr2ptl EQU   $12A
spr3pth EQU   $12C
spr3ptl EQU   $12E
spr4pth	EQU   $130
spr4ptl EQU   $132
spr5pth EQU   $134
spr5ptl EQU   $136
spr6pth	EQU   $138
spr6ptl EQU   $13A
spr7pth EQU   $13C
spr7ptl EQU   $13E

spr0pos	EQU   $140
spr1pos	EQU   $148
spr2pos EQU   $150
spr3pos EQU   $158
spr4pos EQU   $160
spr5pos EQU   $168
spr6pos EQU   $170
spr7pos EQU   $178

spr0ctl	EQU   $142
spr1ctl	EQU   $14A
spr2ctl EQU   $152
spr3ctl EQU   $15A
spr4ctl EQU   $162
spr5ctl EQU   $16A
spr6ctl EQU   $172
spr7ctl EQU   $17A

spr0data EQU  $144
spr1data EQU  $14c
spr2data EQU  $154
spr3data EQU  $15c
spr4data EQU  $164
spr5data EQU  $16c
spr6data EQU  $174
spr7data EQU  $17c


spr0datb EQU  $146
spr1datb EQU  $14e
spr2datb EQU  $156
spr3datb EQU  $15e
spr4datb EQU  $166
spr5datb EQU  $16e
spr6datb EQU  $176
spr7datb EQU  $17e

col0	EQU   $180
col1 	EQU   $182
col2	EQU   $184
col3    EQU   $186
col8	EQU   $190
col16   EQU   $1A0	

  

