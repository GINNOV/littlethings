	Incdir	source:Include/
	Include CustomRegisters
	Section	Cube,Code_c

Ciaapra = $BFE001
Openlibrary = -30-522	
Disable	    = -120
Enable	    = -126
Startlist   = 38
Execbase = 4

bpl1pth:	equ	$e0
bpl1ptl:	equ	$e2
bpl2pth:	equ	$e4
bpl2ptl:	equ	$e6
bpl3pth:	equ	$e8
bpl3ptl:	equ	$ea
bpl4pth:	equ	$ec
bpl4ptl:	equ	$ee
bpl5pth:	equ	$f0
bpl5ptl:	equ	$f2

	Move.l	Execbase,a6
	Jsr	Disable(a6)
	jsr	mt_init
	clr.w	waitrot
	clr.w	fadecount
	move.w	#$007,logocol
	move.w	#$fff,vucol
	move.w	#0,backcol

	move.l	#logo,d0	; Get address of our screen memory.
	move.w	d0,pl2l		; Move the low word into copper list.
	swap	d0		; Swap the low and high words in d0.
	move.w	d0,pl2h		; Move the high word into the copper
				; list.

;-------- Switch Copper DMA ----------


	Move.l	#Clstart,Cop1lc
	Clr	Copjmp1

	Move.w	#$8780,Dmacon
	Move.w	#$0020,Dmacon
	Lea	Spr0data,a0
	Moveq	#7,d0
Clop
	Clr.l	(a0)
	Addq.l	#8,a0
	Dbf	d0,Clop

;------ Wait for Vertical position 1 --------

Wait:	Move.l	$dff004,d2
	And.l	#$0001ff00,d2	
	Cmp.l	#$00000100,d2
	Bne.s	Wait

	add.w	#1,waitrot
	cmpi.w	#450,waitrot
	blt	miss
	bsr	rottest	
miss	bsr	TD_rout

	move.w	#$20,$8(a5)
	jsr	mt_music
	bsr	flashtest1
	bsr	flashtest2
	bsr	flashtest3
	bsr	flashtest4
	Btst	#6,Ciaapra
	Bne	Wait

	jsr	mt_end
	move.w	#$777,logocol

Wait2:	Move.l	$dff004,d2
	And.l	#$0001ff00,d2	
	Cmp.l	#$00000100,d2
	Bne.s	Wait2
	
	bsr	fadetest

	
	cmpi.w	#$fff,logocol
	blt	Wait2


;------ Restore old Copper list -----------

	Move.l	Execbase,a6
	Move.l	#Grname,a1
	Clr.l	d0
	Jsr	Openlibrary(a6)
	Move.l	d0,a4
	Move.l	Startlist(a4),Cop1lc
	Clr.w	Copjmp1
	Move.w	#$83E0,Dmacon
	Jsr	Enable(a6)
	Clr.l	d0
	Rts

fadetest:
	add.w	#1,fadecount
	cmpi.w	#15,fadecount
	beq	yesfade
	rts
	
yesfade:
	move.w	#0,fadecount
	add.w	#$111,logocol
;	sub.w	#$222,vucol
	add.w	#$222,backcol
	rts
	
rottest	btst	#2,$dff016
	bne	yesrottest
	rts

yesrottest	Addq	#2,Zrot
	And	#$1fe,Zrot
	Addq	#4,Yrot
	And	#$1fe,Yrot
	Subq	#2,Xrot
	And	#$1fe,Xrot

	rts
	
flashtest1:
	cmpi.w	#0,mt_voice1
	bgt	flashme1
	
yesflashtest1:
	cmpi.w	#40,flash1
	bne	fadeflash1
	rts
	
fadeflash1:
	sub.w	#2,flash1
	sub.w	#2,flash1b
	rts

flashme1:
	move.w	#140,flash1
	move.w	#140,flash1b
	rts

	
flashtest2:
	cmpi.w	#0,mt_voice2
	bgt	flashme2

yesflashtest2:
	cmpi.w	#-40,flash2
	bne	fadeflash2
	rts

fadeflash2:
	add.w	#2,flash2
	add.w	#2,flash2b
	rts	

	
flashme2:
	move.w	#-140,flash2
	move.w	#-140,flash2b
	rts

	
flashtest3:
	cmpi.w	#0,mt_voice3
	bgt	flashme3
	
yesflashtest3:
	cmpi.w	#40,flash3
	bne	fadeflash3
	rts
	
fadeflash3:
	sub.w	#2,flash3
	sub.w	#2,flash3b
	rts

flashme3:
	move.w	#140,flash3
	move.w	#140,flash3b
	rts

	
flashtest4:
	cmpi.w	#0,mt_voice4
	bgt	flashme4

yesflashtest4:
	cmpi.w	#-40,flash4
	bne	fadeflash4
	rts

fadeflash4:
	add.w	#2,flash4
	add.w	#2,flash4b
	rts	

	
flashme4:
	move.w	#-140,flash4
	move.w	#-140,flash4b
	rts

fadecount:
	dc.w	0
;--------- 3D graphics ------------
TD_rout
	Move.l	Current(pc),d0
	Move	d0,Screen+2
	Swap	d0
	Move	d0,Screen+6
	Eor.l	#$3000,Current
	Move.l	Current(pc),a0
	Move.l	#$1f00000,Bltcon0
	Move.l	a0,Bltdpth
	Clr	Bltadat
	Clr	Bltdmod
	Move	#256*64+20,Bltsize

	Move	#No_points-1,d7
	Lea	Points(pc),a4	
	Lea	Sintable+$40(pc),a1
	Lea	Rotated_coords(pc),a2
	Lea	Perspective(pc),a3
TD_loop
	Move	(a4)+,d0
	Move	d0,d2
	Move	(a4)+,d1
	Move	d1,d3

	Move	Zrot(pc),d6
	Move	$40(a1,d6),d4
	Move	-$40(a1,d6),d5
	Muls	d4,d0
	Muls	d5,d1
	Sub.l	d1,d0
	Add.l	d0,d0
	Swap	d0		;d0 holds intermediate x coord
	Muls	d5,d2
	Muls	d4,d3
	Add.l	d3,d2
	Add.l	d2,d2
	Swap	d2		;d2 holds intermediate y coord
	Move	d2,d4

	Move	(a4)+,d1	;z coord
	Move	d1,d3
	Move	Xrot(pc),d6
	Move	$40(a1,d6),d5
	Move	-$40(a1,d6),d6
	Muls	d5,d2
	Muls	d6,d1
	Sub.l	d1,d2
	Add.l	d2,d2
	Swap	d2		;d2 holds the final y coord
	Muls	d5,d3
	Muls	d6,d4
	Add.l	d4,d3
	Add.l	d3,d3
	Swap	d3		;d3 holds intermediate z coord

	Move	d0,d1
	Move	d3,d4
	Move	Yrot(pc),d6
	Move	$40(a1,d6),d5
	Move	-$40(a1,d6),d6
	Muls	d5,d3
	Muls	d6,d0
	Sub.l	d0,d3
	Add.l	d3,d3
	Swap	d3		;d3 holds the final z coord
	Muls	d6,d4
	Muls	d5,d1
	Add.l	d4,d1
	Add.l	d1,d1
	Swap	d1		;d1 holds the final x coord

	Add	Depth(pc),d3
	Add	d3,d3
	Move	(a3,d3),d5
	Muls	d5,d1
	Muls	d5,d2
	Add.l	d1,d1
	Swap	d1
	Add	#160,d1
	Add.l	d2,d2
	Swap	d2
	Add	#128,d2
	
	Move	d1,(a2)+
	Move	d2,(a2)+
	Dbf	d7,TD_loop

	Move	#No_connects-1,d7
	Lea	$dff000,a5
	Lea	Connect(pc),a3
	Lea	Rotated_coords(pc),a4
	Moveq	#40,d0
	Lea	Mul40(pc),a1
	Lea	Bits(pc),a2

B_wait2
	Btst	#14,Dmaconr
	Bne.s	B_wait2

	Move	#$ffff,Bltafwm
	Move	d0,$60(a5)	;Bltcmod
	Move	d0,$66(a5)	;Bltdmod
	Move	#$ffff,$72(a5)	;Bltbdat
Draw_loop
	Move	(a3)+,d6
	Move	(a4,d6),d0
	Move	2(a4,d6),d1
	Move	(a3)+,d6
	Move	(a4,d6),d2
	Move	2(a4,d6),d3
	Cmp	d0,d2
	Bne.s	Draw
	Cmp	d1,d3
	Beq.s	Nodraw	
Draw
	Bsr	Line
Nodraw
	Dbf	d7,Draw_loop
Bwit
	Btst	#14,Dmaconr
	Bne.s	Bwit
	Rts

;----------- Line Draw ------------
Line
	Moveq	#0,d4
	Move	d1,d4
	Add	d4,d4
	Move	(a1,d4),d4
	Moveq	#-$10,d5
	And	d0,d5
	Lsr	#3,d5
	Add	d5,d4
	Add.l	a0,d4

	Moveq	#0,d5
	Sub	d1,d3
	Roxl.b	d5
	Tst	d3
	Bge.s	Y2gy1
	Neg	d3
Y2gy1
	Sub	d0,d2
	Roxl.b	d5
	Tst	d2
	Bge.s	X2gx1
	Neg	d2
X2gx1

	Move	d3,d1
	Sub	d2,d1
	Bge.s	Dygdx
	Exg	d2,d3
Dygdx
	Roxl.b	d5
	Move.b	Octant_table(pc,d5),d5
	Add	d2,d2
Wblit
	Btst	#14,Dmaconr
	Bne.s	Wblit

	Move	d2,$62(a5)	;Bltbmod
	Sub	d3,d2
	Bge.s	Signn1
	Or.b	#$40,d5
Signn1
	Move	d2,$52(a5)	;Bltaptl
	Sub	d3,d2
	Move	d2,$64(a5)	;Bltamod

	Move	#$8000,$74(a5)	;Bltadat
	Add	d0,d0
	Move	(a2,d0),$40(a5)	;Bltcon0
	Move	d5,$42(a5)	;Bltcon1
	Move.l	d4,$48(a5)	;Bltcpth
	Move.l	d4,$54(a5)	;Bltdpth
	Lsl	#6,d3
	Addq	#2,d3
	Move	d3,$58(a5)	;Bltsize
	Rts

;---------- Constants -------------

Octant_table
	Dc.b	1,17,9,21,5,25,13,29

Grname:	Dc.b	"graphics.library",0

logo:	incbin source:bitmaps/mblogo8
	Even

;----------- Variables ------------

Xrot	Dc.w	$100
Yrot	Dc.w	0
Zrot	Dc.w	0
Current	Dc.l	$70000
Depth	Dc.w	180
Depthpt	Dc.w	0


waitrot dc.w	0
;---------- Copperlists -----------
Clstart:
	Wait	0,20
	Mov	$2f81,Diwstrt
	Mov	$f4c1,Diwstop
	Mov	$0038,Ddfstrt
	Mov	$00d0,Diwstop
Screen
	Mov	0,Bpl1ptl
	Mov	7,Bpl1pth
	Mov	%0010010000000000,Bplcon0
	Mov	0,Bpl1mod
	dc.w	$180
backcol dc.w	$000	
	dc.w	$182
vucol	dc.w	$fff
	dc.w	$192
logocol	dc.w	$007
	dc.w bpl2pth		; Bitplane high word.
pl2h:
	dc.w 0

	dc.w bpl2ptl		; Bitplane low word.
pl2l:
	dc.w 0

	dc.w	$df09,$fffe
	dc.w	$100,$1200
	Wait	224,255
	Wait	$fe,$ff

;--------- Binaries -------------
No_points	= 24
No_connects	= 56
No_faces	= 6

Points
	Dc.w	40,40,40
	Dc.w	-40,40,40
	Dc.w	-40,-40,40
	Dc.w	40,-40,40

	Dc.w	40,40,-40
	Dc.w	-40,40,-40
	Dc.w	-40,-40,-40
	Dc.w	40,-40,-40
	
	dc.w	0
flash1:	dc.w	40
	dc.w	0
	
	dc.w	0
flash2:	dc.w	-40
	dc.w	0
	
flash3:	dc.w	40
	dc.w	0
	dc.w	0

flash4:	dc.w	-40
	dc.w	0
	dc.w	0


	Dc.w	40+1,40+1,40+1
	Dc.w	-40+1,40+1,40+1
	Dc.w	-40+1,-40+1,40+1
	Dc.w	40+1,-40+1,40+1

	Dc.w	40+1,40+1,-40+1
	Dc.w	-40+1,40+1,-40+1
	Dc.w	-40+1,-40+1,-40+1
	Dc.w	40+1,-40+1,-40+1
	
	dc.w	0+1
flash1b:	dc.w	40+1
	dc.w	0+1
	
	dc.w	0+1
flash2b:	dc.w	-40+1
	dc.w	0+1
	
flash3b:	dc.w	40+1
	dc.w	0+1
	dc.w	0+1

flash4b:	dc.w	-40+1
	dc.w	0+1
	dc.w	0+1


Connect
	Dc.w	0,4
	Dc.w	4,8
	Dc.w	8,12
	Dc.w	12,0

	Dc.w	16,20
	Dc.w	20,24
	Dc.w	24,28
	Dc.w	28,16

	Dc.w	0,16
	Dc.w	4,20
	Dc.w	8,24
	Dc.w	12,28
	
	dc.w	0,32
	dc.w	4,32
	dc.w	16,32
	dc.w	20,32
	
	dc.w	8,36
	dc.w	12,36
	dc.w	24,36
	dc.w	28,36
	
	dc.w	0,40
	dc.w	12,40
	dc.w	16,40
	dc.w	28,40

	dc.w	4,44
	dc.w	8,44
	dc.w	20,44
	dc.w	24,44
	

	Dc.w	48+0,48+4
	Dc.w	48+4,48+8
	Dc.w	48+8,48+12
	Dc.w	48+12,48+0

	Dc.w	48+16,48+20
	Dc.w	48+20,48+24
	Dc.w	48+24,48+28
	Dc.w	48+28,48+16

	Dc.w	48+0,48+16
	Dc.w	48+4,48+20
	Dc.w	48+8,48+24
	Dc.w	48+12,48+28
	
	dc.w	48+0,48+32
	dc.w	48+4,48+32
	dc.w	48+16,48+32
	dc.w	48+20,48+32
	
	dc.w	48+8,48+36
	dc.w	48+12,48+36
	dc.w	48+24,48+36
	dc.w	48+28,48+36
	
	dc.w	48+0,48+40
	dc.w	48+12,48+40
	dc.w	48+16,48+40
	dc.w	48+28,48+40

	dc.w	48+4,48+44
	dc.w	48+8,48+44
	dc.w	48+20,48+44
	dc.w	48+24,48+44


Rotated_coords	
	Dcb.w	No_points*2,0
Sintable
	Incbin	source:masterbeat/Sin
	Incbin	source:masterbeat/Sin
Perspective
	Incbin	source:masterbeat/Perspective

Mul40
A set 0
	Rept	320
	Dc.w	A*40
A set A+1
	Endr

A set 0
Bits
	Rept	320
	Dc.w	((A&$f)*$1000)+$bca
A set A+1
	Endr

Size
A set 0
	Rept	320
	Dc.w	(A*64)+2
A set A+1
	Endr


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
 incbin "source:Modules/mod.musix5"




