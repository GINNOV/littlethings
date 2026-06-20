
*****	Title		Int_Eg
*****	Function	A replayer driven by a legal interrupt server
*****			
*****			
*****	Size		
*****	Author		Int code, Mark Meany
*****	Date Started	15 March 92
*****	This Revision	
*****	Notes		This is a noisetracker replayer!
*****			


		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/interrupts.i
		include		hardware/intbits.i

; initialise music data

Start		jsr		_init			Initialise data

		lea		MyInt,a1		a1->Interrupt struct
		move.b		#9,LN_PRI(a1)		priority = 9
		move.l		#IntCode,IS_CODE(a1)	address of server
		moveq.l		#INTB_VERTB,d0		interrupt number
		CALLEXEC	AddIntServer		start it!

wait		btst		#6,$bfe001		LMB pressed?
		bne.s		wait			loop if not
		
		moveq.l		#INTB_VERTB,d0		interrupt number
		lea		MyInt,a1		Interrupt struct
		CALLEXEC	RemIntServer		remove interrupt
		
		jsr		_end			stop music
		
		rts					exit

****************************************************************************
*			The Interrupt Server				   *
****************************************************************************

IntCode		movem.l		a0-a4/d2-d7,-(a7)	Save all registers
		jsr		_music			play routine
		movem.l		(a7)+,a0-a4/d2-d7	Bring back registers
		moveq.l		#0,d0			clear Z flag
		rts					exit


****************************************************************************
*			   Data Section					   *
****************************************************************************

MyInt		ds.l		IS_SIZE			Interrupt structure

	
****************************************************************************
*			The Replay Routine				   *
****************************************************************************

		section		replay,code_c
		
_init 	lea	Module,a0		* Initialise Music
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
_init1 
	move.l	d1,d2
	subq.w	#1,d0
_init2 
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	_init1
	dbf	d0,_init2
	addq.b	#1,d2

_init3 
	lea	Module,a0
	lea	_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
_init4 
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,_init4

	lea	_sample1(PC),a0
	moveq	#0,d0
_clear 
	move.l	0(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	_partnrplay
	clr.l	_partnote
	clr.l	_partpoint

	move.b	Module+$3b6,_maxpart+1
	rts

* call '_end' to switch the sound off

_end 	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

* the playroutine - call this every frame

_music 
	addq.w	#1,_counter
_cool cmp.w	#6,_counter
	bne.s	_notsix
	clr.w	_counter
	bra	_rout2

_notsix 
	lea	_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp1
	lea	$dff0a0,a5		
	bsr.s	_arprout
_arp1 lea	_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp2
	lea	$dff0b0,a5
	bsr.s	_arprout
_arp2 lea	_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp3
	lea	$dff0c0,a5
	bsr.s	_arprout
_arp3 lea	_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	_arp4
	lea	$dff0d0,a5
	bra.s	_arprout
_arp4 rts

_arprout 
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	_arpegrt
	cmp.b	#$01,d0
	beq.s	_portup
	cmp.b	#$02,d0
	beq.s	_portdwn
	cmp.b	#$0a,d0
	beq.s	_volslide
	rts

_portup 
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	_ok1
	move.w	#$71,22(a6)
_ok1 	move.w	22(a6),6(a5)
	rts

_portdwn 
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	_ok2
	move.w	#$538,22(a6)
_ok2 	move.w	22(a6),6(a5)
	rts

_volslide 
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	_ok3
	move.w	#64,18(a6)
_ok3 	move.w	18(a6),8(a5)
	rts
_voldwn 
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	_ok4
	clr.w	18(a6)
_ok4 	move.w	18(a6),8(a5)
	rts

_arpegrt 
	move.w	_counter(PC),d0
	cmp.w	#1,d0
	beq.s	_loop2
	cmp.w	#2,d0
	beq.s	_loop3
	cmp.w	#3,d0
	beq.s	_loop4
	cmp.w	#4,d0
	beq.s	_loop2
	cmp.w	#5,d0
	beq.s	_loop3
	rts

_loop2 
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	_cont
_loop3 
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	_cont
_loop4 
	move.w	16(a6),d2
	bra.s	_endpart
_cont 
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	_arpeggio(PC),a0
_loop5 
	move.w	0(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	_endpart
	addq.l	#2,a0
	bra.s	_loop5
_endpart 
	move.w	d2,6(a5)
	rts

_rout2 
	lea	Module,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	_partnrplay(PC),d0
	moveq	#0,d1
	move.b	0(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	_partnote(PC),d1
	move.l	d1,_partpoint
	clr.w	_dmacon

	lea	$dff0a0,a5
	lea	_aud1temp(PC),a6
	bsr	_playit
	lea	$dff0b0,a5
	lea	_aud2temp(PC),a6
	bsr	_playit
	lea	$dff0c0,a5
	lea	_aud3temp(PC),a6
	bsr	_playit
	lea	$dff0d0,a5
	lea	_aud4temp(PC),a6
	bsr	_playit
	move.w	#$01f4,d0
_rls 	dbf	d0,_rls

	move.w	#$8000,d0
	or.w	_dmacon,d0
	move.w	d0,$dff096

	lea	_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
_voice3 
	lea	_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
_voice2 
	lea	_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
_voice1 
	lea	_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
_voice0 
	move.l	_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,_partnote
	cmp.l	#$400,d0
	bne.s	_stop
_higher 
	clr.l	_partnote
	addq.l	#1,_partnrplay
	moveq	#0,d0
	move.w	_maxpart(PC),d0
	move.l	_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	_stop
	clr.l	_partnrplay
	
_stop tst.w	_status
	beq.s	_stop2
	clr.w	_status
	bra.s	_higher
_stop2 
	rts

_playit 
	move.l	0(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	_nosamplechange

	moveq	#0,d3
	lea	_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	0(a1,d2),4(a6)
	move.w	0(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	_nosamplechange

_displace 
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
_nosamplechange 
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	_retrout
 	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,_dmacon

_retrout 
	tst.w	(a6)
	beq.s	_nonewper
	move.w	(a6),22(a6)

_nonewper 
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	_posjmp
	cmp.b	#$0c,d0
	beq.s	_setvol
	cmp.b	#$0d,d0
	beq.s	_break
	cmp.b	#$0e,d0
	beq.s	_setfil
	cmp.b	#$0f,d0
	beq.s	_setspeed
	rts

_posjmp 
	not.w	_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,_partnrplay
	rts

_setvol 
	move.b	3(a6),8(a5)
	rts

_break 
	not.w	_status
	rts

_setfil 
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

_setspeed 
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	_back
	clr.w	_counter
	move.b	d0,_cool+3
_back rts

_aud1temp 
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
_aud2temp 
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
_aud3temp 
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
_aud4temp 
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

_partnote 	dc.l	0
_partnrplay 	dc.l	0
_counter 	dc.w	0
_partpoint 	dc.l	0
_samples 	dc.l	0
_sample1 	dcb.l	31,0
_maxpart 	dc.w	0
_dmacon 	dc.w	0
_status 	dc.w	0

_arpeggio 
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

Module 	incbin	df1:modules/Mod.Music
