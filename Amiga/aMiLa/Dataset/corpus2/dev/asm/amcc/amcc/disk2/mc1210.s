; mc1210.s	= disk.s
; from disk2/disk
; explanation in letter_12.pdf / p. 10
; no explanation in MW_series	

start:
	move.w	#$4000,$dff09a

	moveq	#0,d0
	bsr	driveon

	bsr	track00

	moveq	#80,d0
	bsr	track

	lea.l	diskbuf(pc),a1

	bsr	readdisk
	bsr	decodemfm

	moveq	#0,d0
	bsr	driveoff
	rts

	settime=10000
	delay=1900
	headchg=500

driveon:
	move.l	d0,-(a7)
	andi.w	#3,d0
	addi.w	#3,d0
	bset	d0,$bfd100
	bclr	#7,$bfd100
	bclr	d0,$bfd100
	move.w	#$8010,$dff096
	move.l	(a7)+,d0
	rts

driveoff:
	move.l	d0,-(a7)
	andi.w	#3,d0
	addi.w	#3,d0
	bset	d0,$bfd100
	bset	#7,$bfd100
	bclr	d0,$bfd100
	bset	d0,$bfd100
	move.l	(a7)+,d0
	rts

writedisk:
	movem.l	d0/a1,-(a7)
	move.w	#$4000,$dff024
	move.w	#$7f00,$dff09e
	move.w	#$9100,d0
	lea.l	trackpos(pc),a1
	cmp.w	#39,(a1)
	ble.s	wr_precomp00
	add.w	#$2000,d0
wr_precomp00:
	move.w	d0,$dff09e
	lea.l	wmfm(pc),a1
	move.l	a1,$dff020
	move.w	#$1002,$dff09c
	move.w	#$d8d3,$dff024
	move.w	#$d8d3,$dff024
wr_wait:
	move.w	$dff01e,d0
	btst	#1,d0
	beq.s	wr_wait
	move.w	#$0002,$dff09c
	move.w	#$4000,$dff024
	movem.l	(a7)+,d0/a1
	rts

readdisk:
	movem.l	d0/a1,-(a7)
	move.w	#$4000,$dff024
	move.w	#$7f00,$dff09e
	move.w	#$8500,$dff09e
	lea.l	mfm(pc),a1
	move.l	a1,$dff020
	move.w	#$1002,$dff09c
	move.w	#$4489,$dff07e
	move.w	#$9771,$dff024
	move.w	#$9771,$dff024
rd_wait:
	move.w	$dff01e,d0
	btst	#1,d0
	beq.s	rd_wait
	move.w	#$0002,$dff09c
	move.w	#$4000,$dff024
	movem.l	(a7)+,d0/a1
	rts

track:
	tst.w	d0
	bge.s	tk_ok1
	rts
tk_ok1:
	cmp.w	#163,d0
	ble.s	tk_ok2
	rts
tk_ok2:
	movem.l	d0-d2/a1,-(a7)
	move.w	d0,d2
	lsr.w	#1,d0
	lea.l	trackpos(pc),a1
	move.w	(a1),d1
	move.w	d0,(a1)
	cmp.w	d1,d0
	blt.s	stepout
	bgt.s	stepin
	btst	#0,d2
	bne.s	tk_side1
	bset	#2,$bfd100
	bra.s	tk_sideok
tk_side1:
	bclr	#2,$bfd100
tk_sideok:
	move.w	#headchg,d0
tk_sideloop:
	dbra	d0,tk_sideloop
	movem.l	(a7)+,d0-d2/a1
	rts
stepout:
	sub.w	d0,d1
	bset	#1,$bfd100
sto_loop:
	bclr	#0,$bfd100
	bset	#0,$bfd100
	move.w	#delay,d0
sto_wait:
	dbra	d0,sto_wait
	subq.w	#1,d1
	bne.s	sto_loop
	btst	#0,d2
	bne.s	sto_side1
	bset	#2,$bfd100
	bra.s	sto_sideok
sto_side1:
	bclr	#2,$bfd100
sto_sideok:
	move.w	#settime,d0
sto_setloop:
	dbra	d0,sto_setloop
	movem.l	(a7)+,d0-d2/a1
	rts
stepin:
	exg	d0,d1
	sub.w	d0,d1
	bclr	#1,$bfd100
sti_loop:
	bclr	#0,$bfd100
	bset	#0,$bfd100
	move.w	#delay,d0
sti_wait:
	dbra	d0,sti_wait
	subq.w	#1,d1
	bne.s	sti_loop
	btst	#0,d2
	bne.s	sti_side1
	bset	#2,$bfd100
	bra.s	sti_sideok
sti_side1:
	bclr	#2,$bfd100
sti_sideok:
	move.w	#settime,d0
sti_setloop:
	dbra	d0,sti_setloop
	movem.l	(a7)+,d0-d2/a1
	rts
trackpos:
	dc.w	0

track00:
	movem.l	d0/a1,-(a7)
	bset	#1,$bfd100
tk00_loop:
	bclr	#0,$bfd100
	bset	#0,$bfd100
	move.w	#delay,d0
tk00_wait:
	dbra	d0,tk00_wait
	btst	#4,$bfe001
	bne.s	tk00_loop
	lea.l	trackpos(pc),a1
	clr.w	(a1)
	movem.l	(a7)+,d0/a1
	rts

codemfm:
	movem.l	d0-d5/a1-a2,-(a7)
	lea.l	diskbuf(pc),a1
	lea.l	mfm(pc),a2
	move.l	#$aaaaaaaa,d3
	move.l	#$55555555,d4
	move.w	#1499,d5
cmfm_loop:
	move.l	(a1)+,d0
	move.l	d0,d1
	move.l	d0,d2
	or.l	d3,d0
	and.l	d4,d1
	add.l	d1,d1
	not.l	d1
	and.l	d1,d0
	lsr.l	#1,d2
	move.l	d2,d1
	or.l	d3,d2
	and.l	d4,d1
	add.l	d1,d1
	not.l	d1
	and.l	d1,d2
	move.l	d0,(a2)+
	move.l	d2,(a2)+
	dbra	d5,cmfm_loop
	movem.l	(a7)+,d0-d5/a1-a2
	rts

decodemfm:
	movem.l	d0-d4/a1-a2,-(a7)
	lea.l	mfm(pc),a1
	lea.l	diskbuf(pc),a2
	move.l	#$55555555,d2
	move.l	#$aaaaaaaa,d3
	move.w	#1499,d4
dcmfm_loop:
	movem.l	(a1)+,d0-d1
	and.l	d2,d0
	not.l	d1
	and.l	d3,d1
	or.l	d1,d0
	move.l	d0,(a2)+
	dbra	d4,dcmfm_loop
	movem.l	(a7)+,d0-d4/a1-a2
	rts

wmfm:
	blk.w	350,$aaaa
	dc.w	$4489
mfm:
	blk.w	6000,$aaaa
	dc.l	$aaaaaaaa
	dc.l	$aaaaaaaa

diskbuf:
	blk.w	3000,0

	end
	