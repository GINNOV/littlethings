
	 OPT W-
	 rsreset
SysInts	rs.w 	1
SYsDMA	rs.w 	1
;lev2	rs.l 	1
lev3	rs.l 	1
cop1	rs.l	1
cop2	rs.l	1
InfoSize rs.w 	1

* UPGRADED SO COMPATIBLE WITH WB 2.04.
* P.KENT 25/1/91.

	list
*HWStart V3 / P.Kent (2.0 COMPATIBLE)*
	nolist
	Push d1-d7/a0-A6
	move.l	4.w,a6
	jsr	-132(a6)					forbid

	lea	gfx(pc),a1
	moveq	#0,d0
	jsr	-552(a6)					open library
	tst.l	d0						something must be v wrong for no gfx lib!
	beq	gfxerr
	move.l	d0,a1	 				gfx ptr...
	Lea	SysInfo(pc),a5
	move.l	$26(a1),cop1(a5)	  	copper list ptrs
	move.l	$32(a1),cop2(a5)
	jsr	-414(a6)					close library
	Lea	custom,a6
	blitwait a6
	catchvb a6
	move.w	intenar(a6),SysInts(a5)	save system interupts
	move.w	dmaconr(a6),SysDMA(a5)	and DMA settings
	move.w	#$7fff,intena(a6) 		kill everything!
	move.w	#$7fff,dmacon(a6)
;	move.l	$68.w,Lev2(a5) 			
	move.l	$6c.w,Lev3(a5)  		
	bsr	_boot
	Lea $dff000,a6
	Lea Sysinfo(pc),a5
;	move.l	Lev2(a5),$68.w			restore the system vectors
	move.l	Lev3(a5),$6c.w			and interrupts and DMA
	
	move.l	cop1(a5),cop1lch(a6)	reinsert copper lists
	move.l	cop2(a5),cop2lch(a6)

	move.w	SysInts(a5),d0
	or.w	#$c000,d0
	move.w	d0,intena(a6)
	move.w	SysDMA(a5),d0
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)
gfxerr
	move.l	4.w,a6
	jsr	-138(a6) 					permit
	Pop d1-d7/a0-a6
	MOVEQ   #0,D0
	rts
gfx	dc.b	"graphics.library",0
	even
Sysinfo ds.b	 Infosize
	OPT	W+
	
