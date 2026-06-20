
	******* EQUALIZER 1 - BY KHUL IN FEB 1993 ******
	*NOTE: This is based on current voice volume

*The replay source is standard - but the routine I have coded NEEDS this
*replayer as PT replayers hold information in different places
*(if you have to use another one just make surce the "volume" offset is
*correct!)


WIDTH		=	40
HEIGHT		=	200
PLANESIZE	=	WIDTH*HEIGHT
NO_PLANES	=	1

		opt c-

	section program,code_c
	include	"Source:include/hardware.i"

	bsr.b	KillSys
	bsr.b	Initialize
	bsr.w	Main
	bsr.b	RestoreSys
	rts

*************************************************************************
* "Quick Trash" routine by Khul, Feb 93					*
*************************************************************************
KillSys:lea	$dff000,a5
	move.w	#$4000,intena(a5)	Disable all interrupts
	move.w	#$01a0,dmacon(a5)	Disable DMACON
	rts
RestoreSys:
	lea	$dff000,a5
	move.l	4,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080		Get system copper
	move.w	#$8020,$96(a5)		Activate
	moveq	#0,d0
	rts
*****************************************************************************
INITIALIZE:
	move.l	#screen,d0		Set copper plane addresses
	lea	planes,a0
	moveq	#NO_PLANES-1,d1		no.of bitplanes-1
set_planes:
	move.w	d0,6(a0)		get lower
	swap 	d0
	move.w	d0,2(a0)		get higher
	swap	d0			revert the screen ad to normal
	add.l	#PLANESIZE,D0		size of screen bitplane
	add.l	#8,a0
	dbra	D1,Set_planes

	lea	$dff000,a5		New Copperlist on
        move.l 	#new,$80(a5)
	move.l	#new+1,$84(a5)
	move.w 	$88(a5),d0
	move.w	#$87f0,$96(a5)
	rts
*****************************************************************************
MAIN:	jsr	mt_init
loop:	move.l	$dff004,d0		VBlank routine
	asr.l	#8,d0
	andi.w	#$1ff,d0
	cmp.w	#257,d0
	bne.s	loop

	jsr	mt_music
	jsr	equalizer	
	btst	#6,$bfe001
	bne.s	loop
	jsr	mt_end
	rts
*****************************************************************************

		*****************************************
		*		New Copper List		*
		*****************************************

cw = $fffe
new:	dc.w	dmacon,$20
	dc.w	bplcon0,$1200,bplcon1,$0000
	dc.w	bpl1mod,$0000,bpl2mod,$0000
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	diwstrt,$2c81,diwstop,$f4c1
planes:	dc.w	bpl1pth,0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0
	dc.w	bpl4pth,0,bpl4ptl,0
	dc.w	bpl5pth,0,bpl5ptl,0
spr_ptrs:
	dc.l	$01200000,$01220000		SPR0PTH/L
	dc.l	$01240000,$01260000		SPR1PTH/L
	dc.l	$01280000,$012a0000		SPR2PTH/L
	dc.l	$012c0000,$012e0000		SPR3PTH/L
	dc.l	$01300000,$01320000		SPR4PTH/L
	dc.l	$01340000,$01360000		SPR5PTH/L
	dc.l	$01380000,$013a0000		SPR6PTH/L
	dc.l	$013c0000,$013e0000		SPR7PTH/L
	dc.w	color17,$88d,color18,$568,color19,$335

	dc.w	color00,$0
	dc.w	color01,$aaa

gfx_equ:
	dc.w	$680f,cw,$180,$0,$800f,cw,$180,0
	dc.w	$880f,cw,$180,$0,$a00f,cw,$180,0
	dc.w	$a80f,cw,$180,$0,$c00f,cw,$180,0
	dc.w	$c80f,cw,$180,$0,$e00f,cw,$180,0

NTSC:	dc.w	$ffe1,cw
	dc.w 	$ffff,cw

*****************************************************************************
screen:	ds.b	PLANESIZE*NO_PLANES

*****************************************************************************

;-----------------------------------------------
; ****   Simple EQUALIZER by Khul in 1992   ****
;-----------------------------------------------
equalizer:
	lea	mt_voice1,a0
	lea	gfx_equ+6,a2	;point for first equalizer copper gap
	move.l	#3,d1

equ_lp:	moveq	#0,d0
	move.b	19(a0),d0
	
	asr	#1,d0		;divide by 2
	cmp.l	#2,d0		;is it less than 2 ???
	bge.s	equ_ok0		;no
	move.l	#2,d0		;yes, plonk 2 in so we CAN subtract

*( in theory: divide by 4 for colour value (1-16), * 2  for offset  and -2
*  so just divide by 2 and -2 )

equ_ok0	sub.l	#2,d0		;subtract 2,  offset is in d0
	and.w	#$fffe,d0	;get rid of first bit so no ODD offset (guru!)

	lea	equ_tab,a1
	add.l	d0,a1		;add on offset
	move.w	(a1),(a2)
	add.l	#16,a2
	add.l	#28,a0		;update mt_chan, copper_equalizer addresses

	dbra	d1,equ_lp
	rts

equ_tab:	dc.w	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f

*****************************************************************************
;   NoisetrackerV2.0 Normal replay
;     Uses registers d0-d3/a0-a5
; Mahoney & Kaktus - (C) E.A.S. 1990

mt_init:movem.l	d0-d2/a0-a2,-(a7)
	lea	mt_data,a0
	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d2
	moveq	#0,d1
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.b	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#42,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#2,$bfe001
	move.b	#6,mt_speed
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	movem.l	(a7)+,d0-d2/a0-a2
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts


mt_music:
	movem.l	d0-d3/a0-a5,-(a7)
	lea	mt_data,a0
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	clr.b	mt_counter

	lea	mt_data,a0
	lea	$c(a0),a3
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	bsr	mt_playvoice

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma

	bsr	mt_wait
	or.w	#$8000,d0
	move.w	d0,$dff096
	bsr	mt_wait
mt_nodma:
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos
mt_exit:tst.b	mt_break
	bne.s	mt_next
	movem.l	(a7)+,d0-d3/a0-a5
	rts

mt_wait:moveq	#3,d3
mt_wai2:move.b	$dff006,d2
mt_wai3:cmp.b	$dff006,d2
	beq.s	mt_wai3
	dbf	d3,mt_wai2
	moveq	#8,d2
mt_wai4:dbf	d2,mt_wai4
	rts

mt_nonew:
	lea	mt_voice1(pc),a4
	lea	$dff0a0,a5
	bsr	mt_com
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	bsr	mt_com
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	bsr	mt_com
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	bsr	mt_com
	bra.s	mt_exit

mt_mulu:
	dc.w $000,$01e,$03c,$05a,$078,$096,$0b4,$0d2,$0f0,$10e,$12c,$14a
	dc.w $168,$186,$1a4,$1c2,$1e0,$1fe,$21c,$23a,$258,$276,$294,$2b2
	dc.w $2d0,$2ee,$30c,$32a,$348,$366,$384,$3a2

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq.s	mt_oldinstr

	lea	mt_samplestarts-4(pc),a1
	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	lsr.w	#1,d2
	move.w	mt_mulu(pc,d2.w),d2
	move.w	(a3,d2.w),8(a4)
	move.w	2(a3,d2.w),$12(a4)
	moveq	#0,d3
	move.w	4(a3,d2.w),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	4(a4),d0
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	4(a3,d2.w),d0
	add.w	6(a3,d2.w),d0
	move.w	d0,8(a4)
	bra.s	mt_hejaSverige
mt_noloop:
	move.l	4(a4),d0
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	6(a3,d2.w),$e(a4)
	moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)

mt_oldinstr:
	move.w	(a4),d0
	and.w	#$fff,d0
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	tst.b	$12(a4)
	bne.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	(a4),$10(a4)
	and.w	#$fff,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0	;dmaset
	or.w	d0,mt_dmacon
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:move.b	3(a4),d0
	beq.s	mt_port2
	move.b	d0,$15(a4)
	clr.b	3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	moveq	#0,d0
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_arp0
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	bra.s	mt_arpdo
mt_arp2:moveq	#0,d0
	move.b	3(a4),d0
	and.b	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	and.w	#$fff,d1
	lea	mt_periods(pc),a0
	moveq	#$24,d2
mt_arp3:cmp.w	(a0)+,d1
	bge.s	mt_arpfound
	dbf	d2,mt_arp3
mt_arp0:move.w	$10(a4),6(a5)
	rts
mt_arpfound:
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	tst.b	d0
	beq.s	mt_arp
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#6,d0
	beq.s	mt_volvib
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)
	rts

mt_com2:move.b	$2(a4),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break
	rts

mt_songjmp:
	move.b	#1,mt_break
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	13,0
		dc.w	1
mt_voice2:	dcb.w	13,0
		dc.w	2
mt_voice3:	dcb.w	13,0
		dc.w	4
mt_voice4:	dcb.w	13,0
		dc.w	8

mt_data:	incbin	"mod.music"
