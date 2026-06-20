
	OPT	W-
	 rsreset
SysInts	rs.w 	1
SYsDMA	rs.w 	1
Cop1	rs.l	1
Cop2	rs.l	1
LowMem	rs.b	$c0
InfoSize rs.b 	1

* UPGRADED SO COMPATIBLE WITH WB 2.04.
* NUKES INTS, MORE MODULAR
* P.KENT 23/3/91.
* KNOWS ABOUT WB - USING COMBISTART.S : 2/6/92
* CUSTOMISED FOR TANKS!!!

	list
*HWStart V4 / P.Kent (2.0 COMPATIBLE)*
	nolist
	Push d1-d7/a0-A6
	BSR.S	SaveSystem
	IFD	RUNTIME
	BSR	TakeSystem
	MOVE.L	#Except,$80.W
	TRAP	#0
	ENDC
	IFND	RUNTIME
	BSR	_Boot
	ENDC
Done	BSR	RecoverSystem
	IFD	EDITOR
	JSR	EDIT_SAVE
	ENDC
Quit	Pop d1-d7/a0-a6
	MOVEQ   #0,D0
	rts
gfx	dc.b	"graphics.library",0
	even
gfxerr
	addq.l	#4,a7
	BRA.S	quit
*****
*Save DMA, lowmem
*****
SaveSystem
	move.l	4.w,a6
	lea	gfx(pc),a1
	moveq	#0,d0
	jsr	-552(a6)					open library
	tst.l	d0						something must be v wrong for no gfx lib!
	beq.S	gfxerr
	move.l	d0,a1	 				gfx ptr...
	Lea	SysInfo(pc),a5
	move.l	$26(a1),cop1(a5)	  	copper list ptrs
	move.l	$32(a1),cop2(a5)
	jsr	-414(a6)					close library
	
	lea	custom,a6
	blitwait a6
	move.w	intenar(a6),SysInts(a5)	save system interupts
	move.w	dmaconr(a6),SysDMA(a5)	and DMA settings

	Sub.l	a0,a0					Save low memory...
	LEA	Lowmem(a5),a1
SaveLowMem
	MOVE.L	(A0)+,(A1)+
	CMP.W	#$C0,A0
	BNE.S	SaveLowmem
	RTS

*****
*Kill DMA,nuke int vectors
*****
TakeSystem
	catchvb	a6
	move.w	#$7fff,intena(a6) 		kill everything!
	move.w	#$7fff,dmacon(a6)
	lea	null_vector(pc),a0
	lea	$64.W,a1
	moveq	#6,d0
TS_Ints	move.l	a0,(a1)+
	dbra	d0,TS_Ints
; Switch drives off
	or.b		#$f8,CIABPRB
	and.b		#$87,CIABPRB
	or.b		#$f8,CIABPRB
	rts

*****
*Restore low mem,recover DMA
*****
RecoverSystem
	Lea custom,a6
	Lea Sysinfo(pc),a5
	Sub.l	a0,a0					recover low memory...
	LEA	Lowmem(a5),a1
LoadLowMem
	MOVE.L	(A1)+,(A0)+
	CMP.W	#$C0,A0
	BNE.S	LoadLowmem
	move.l	cop1(a5),cop1lch(a6)	reinsert copper lists
	move.l	cop2(a5),cop2lch(a6)
	catchvb	a6
	move.w	SysInts(a5),d0
	or.w	#$c000,d0
	move.w	d0,intena(a6)
	move.w	SysDMA(a5),d0
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)
	rts

Except		bsr	_boot
Null_Vector	rte
Sysinfo 	ds.b	 Infosize
			even
	
	OPT	W+
