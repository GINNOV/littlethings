*****************************************************************************
* FIVE BITPLANE PICTURE + LEV3 INTERRUPTS + SAMPLE PLAYER		    *
*****************************************************************************
 SECTION LOWMEM,CODE_C				Force Code To Chip RAM
 OPT C-						Case Independant
	movem.l	a0-a6/d0-d7,-(sp)		Save all registers
	move.l	sp,Stackpoint			Save pointer
*****************************************************************************
* SLAY THE OPERATING SYSTEM			      			    *
*****************************************************************************
Slay_os
	move.l	EXECbase,a6
	lea	GFXlib,a1
	clr.l	d0
	jsr	openlibrary(a6)			open graphics library
	move.l	d0,GFXbase

	move.l	GFXbase,a6
	jsr	waitblit(a6)		wait for blitter to finish task

	move.l	GFXbase,a6
	jsr	ownblitter(a6)		 then sieze control of blitter.
	
	move.l	EXECbase,a6
	jsr	forbid(a6)			stop multitasking

	move.l	#custom,a5
	move.w	dmaconr(a5),DMAsave		Save DMA
	move.w	intenar(a5),INTensave		Save interrupt enable
	move.w	intreqr(a5),INTrqsave		Save interrupt request
	move.w	#$7fff,d0
	move.w	d0,intena(a5)			Disable interrupts enable
	move.w	d0,intreq(a5)			Disable interrupts request
	move.w	d0,dmacon(a5)			Disable dma
	move.l	$6c.w,SYSlev3_save		Save old lev3 address
	move.l	#LEV3_interrupt,$6c.w		Replace with mine
	move.l	#copperlist,cop1lch(a5)		Replace copper
	move.w	copjmp1(a5),d0			strobe copper
	move.w	#setit+dmaen+bplen+copen+blten,dmacon(a5)
*****************************************************************************
* SET UP BITPLANE POINTERS & SPRITE POINTERS 				    *
*****************************************************************************
Set_Up	
	move.l	 #Planes,a0			Bpl Pointer In Copper
	move.l   #picture,d0			Picture Block
	move.l	 #4,d1				Number of bitplanes
pilp	
	move.w   d0,6(a0)			Load Low Word
	swap     d0				Swap Words
	move.w   d0,2(a0)			Load High Word
	swap	 d0
	add.l	 #10240,d0
	add.l	 #8,a0
	dbeq	 d1,pilp

	move.w	#setit+inten+vertb,intena(a5)	
*****************************************************************************
*-------- Main program loop sits hear untill mouse button is pressed -------*
*****************************************************************************
main_loop
		jsr	screen_ready
;		move.w	#$a00,$dff180		;Used to time routines
;If the fire button is pressed the program will play sample using the
; vertical blank as a timer.
		jsr	test_fire_button 	 
		jsr	exit
;		move.w	#0,$dff180		;etc.etc.etc...
		jmp	main_loop
*****************************************************************************
*---------------------------------------------------------------------------*
*****************************************************************************
exit
	btst	#6,ciaapra
	bne	exit_end
	jmp	erect_os	If button pressed program ends.
exit_end
	rts
*---------------------------------------------------------------------------*
Erect_OS
	jsr	mt_end
	move.l	#custom,a5
	move.w	#$7fff,d0			set to clear
	move.w	d0,intena(a5)			Clear interrupt enable
	move.w	d0,intreq(a5)			Clear interrupt request
	move.l	SYSlev3_save,$6c.w	Restore old lev3 interrupt address
	move.w  INTensave,d7
	bset    #$F,d7				Set Write Bit
	move.w  d7,intena(a5)		Restore system interrupt enable
	move.w  INTrqsave,d7
	bset    #$F,d7
	move.w  d7,intreq(a5)		Restore system interrupt request
	move.w  DMAsave,d7
	bset    #$F,d7
	move.w  d7,dmacon(a5)  		Restore system DMA control register
	move.l  GFXbase,a0			
	move.l $26(a0),cop1lch(a5)		Find/Replace System Copper

	move.l	EXECbase,a6
	jsr	permit(a6)		restore multitasking
	
	move.l	GFXbase,a6
	jsr	disownblitter(a6)	returm control of blitter.
	
	move.l	EXECbase,a6
	move.l	GFXbase,a1
	clr.l	d0
	jsr	closelibrary(a6)		close graphics library

	move.l	Stackpoint,sp			Restore pointer
	movem.l	(sp)+,a0-a6/d0-d7		Restore all registers
	rts
*----------------------------------------------------------------------------
	even
test_fire_button
	btst	#0,fire_flag		Is sample playing?
	bne	sample_playing		branch if yes.
	btst	#7,ciaapra		If not test for fire button
	bne	no_fire
	bset	#0,fire_flag		If pressed than set flag
; Write sample parameters into hardware registers
		move.l		#mick,aud3lch(a5)	set new address
		move.w		#mick1len,aud3len(a5)	set new length
		move.w		#64,aud3vol(a5)		set volume
		move.w		#$190,aud3per(a5)	set period
; Enable channel 3 DMA to start the sound playing.
		move.w		#SETIT!AUD3EN,DMACON(a5) start playing
no_fire
	rts
*-- Sample has been inisalised now time it ---------------------------------*
sample_playing		
	add.w	#1,sample_vblank_counter
	cmp.w	#280,sample_vblank_counter
	bne	donot_stop_sample
;stop_sample
	bclr	#0,fire_flag
	move.w	#0,sample_vblank_counter
; Can now initialise quiet sample
		move.l		#NullSnd,aud3lch(a5)	set new address
		move.w		#NullLen,aud3len(a5)	set new length
		move.w		#AUD3EN,DMACON(a5)	quiet!
		rts
donot_stop_sample
	rts
*****************************************************************************
*****************************************************************************
*****************************************************************************
	even
LEV3_interrupt	
		movem.l	d0-d7/a0-a6,-(sp)	save all registers
		move.w	intreqr(a5),d0		get interrupt requests
		btst	#6,d0			is it blitter request?
		beq.s	not_blit
		move.w	#$0040,intreq(a5)	clear blitter request bit
*---------------- Do blitter lev3 interrupt code hear ----------------------*

*****************  blitter code should end hear *****************************
not_blit
		btst.l	#5,d0			is it vblank request bit?
		beq	not_vblank
		move.w	#$0020,intreq(a5)	clear vblank request bit
*---------------- Do vertical blank lev3 code hear -------------------------*
		jsr	mt_music
***************** Vertical blank code should end hear ***********************
not_vblank
		btst	#4,d0			is it copper request bit?
		beq	not_copper
		move.w	#$0010,intreq(a5)	clear copper request bit.
*---------------- do Copper lev3 code hear ---------------------------------*

***************** Copper interrupt code ends hear ***************************
not_copper
		movem.l	(sp)+,d0-d7/a0-a6	replace all registers
		rte
*****************************************************************************
*			        COPPER				    	    *
*****************************************************************************
Copperlist
	DC.W BPL1MOD,$0000,BPL2MOD,$0000,BPLCON0,$5200,BPLCON1,$0000 
	DC.W DDFSTRT,$0038,DDFSTOP,$00d0,DIWSTRT,$2c81,DIWSTOP,$2cc1
		
Planes	
	DC.W BPL1PTH,$0000,BPL1PTL,$0000,BPL2PTH,$0000,BPL2PTL,$0000
	DC.W BPL3PTH,$0000,BPL3PTL,$0000,BPL4PTH,$0000,BPL4PTL,$0000
	DC.W BPL5PTH,$0000,BPL5PTL,$0000
Col     ;bpl0=col1 bpl1=col2 bpl2=col4 bpl3=col8 bpl4=col16
	DC.W COLOR00,$0000,COLOR01,$00f0,COLOR02,$00f0,COLOR03,$00f0
	DC.W COLOR04,$00f0,COLOR05,$00f0,COLOR06,$00f0,COLOR07,$00f0
	DC.W COLOR08,$00f0,COLOR09,$00f0,COLOR10,$00f0,COLOR11,$00f0
	DC.W COLOR12,$00f0,COLOR13,$00f0,COLOR14,$00f0,COLOR15,$00f0

	DC.W COLOR16,$0000,COLOR17,$0000,COLOR18,$0000,COLOR19,$0000
	DC.W COLOR20,$0000,COLOR21,$0000,COLOR22,$0000,COLOR23,$0000
	DC.W COLOR24,$0000,COLOR25,$0000,COLOR26,$0000,COLOR27,$0000
	DC.W COLOR28,$0000,COLOR29,$0000,COLOR30,$0000,COLOR31,$0000
spr_ptr	
	dc.w spr0pth,$0000,spr0ptl,$0000,spr1pth,$0000,spr1ptl,$0000
	dc.w spr2pth,$0000,spr2ptl,$0000,spr3pth,$0000,spr3ptl,$0000
	dc.w spr4pth,$0000,spr4ptl,$0000,spr5pth,$0000,spr5ptl,$0000
	dc.w spr6pth,$0000,spr6ptl,$0000,spr7pth,$0000,spr7ptl,$0000	

	DC.W BPLCON2,$0024	Sprites have Video Priority over playfields 
	DC.L $FFFFFFFE			WAIT FOR END OF VBLNK

*****************************************************************************
*---------------------------------------------------------------------------*
mouse_wait
	btst	#6,ciaapra
	bne	mouse_wait
wait
	btst	#2,potgor+$dff000
	bne	wait
	rts
*----------------------------------------------------------------------------
screen_ready
Wtt	cmpi.b	#255,vhposr(a5)			Wait for line 255
	bne.s	Wtt
Wttt	cmpi.b	#45,vhposr(a5)			Wait for line 310
	bne.s	Wttt				(Stops spurious sprite data)
	rts
*****************************************************************************
	even
		Include		my_hardware.i
picture		dcb.b		51200,0			Picture data
	even
GFXlib			DC.B "graphics.library"
Stackpoint		DC.L 0
GFXbase			DC.L 0
INTrqsave		DC.W 0
INTensave		DC.W 0
DMAsave			DC.W 0
OLD_COP			DC.L 0
SYSlev3_save		dc.l 0
fire_flag		dc.b 0
	even
mick		incbin	mick		Sample
mick1len	equ	*-mick
NullSnd		ds.w		50
NullLen		equ		50		word length
sample_vblank_counter		dc.w 0
Mt_Data		IncBin 		mod1
*****************************************************************************
* 			  REPLAY ROUTINE V2.4				    *
*****************************************************************************
*------------------- Subroutine to initialize music -------------------------
mt_init 
	lea	mt_data,a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1
	move.l	d1,d2
	subq.w	#1,d0
mt_init2
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2
mt_init3
	lea	mt_data,a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4
	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	mt_clear
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint
	move.b	mt_data+$3b6,mt_maxpart+1
	rts
*-------------------------- Subroutine to stop music ------------------------
mt_end	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts
*---------- Music subroutine gets executed by lev3 interrupt ----------------
mt_music
	addq.w	#1,mt_counter
mt_cool cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra	mt_rout2
mt_notsix
	lea	mt_aud1temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm1
;	move.w	#$000E,Ch1			
levm1	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1 lea	mt_aud2temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm2
;	move.w	#$000C,Ch2			
levm2	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2 lea	mt_aud3temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm3
;	move.w	#$000A,Ch3			
levm3	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3 lea	mt_aud4temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm4
;	move.w	#$0008,Ch4			
levm4	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4 rts
mt_arprout
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	mt_arpegrt
	cmp.b	#$01,d0
	beq.s	mt_portup
	cmp.b	#$02,d0
	beq.s	mt_portdwn
	cmp.b	#$0a,d0
	beq.s	mt_volslide
	rts
mt_portup
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1	move.w	22(a6),6(a5)
	rts
mt_portdwn
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2	move.w	22(a6),6(a5)
	rts
mt_volslide
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3	move.w	18(a6),8(a5)
	rts
mt_voldwn
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4	move.w	18(a6),8(a5)
	rts
mt_arpegrt
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts
mt_loop2
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	lea	mt_arpeggio(PC),a0
mt_loop5
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart
	move.w	d2,6(a5)
	rts
mt_rout2
	lea	mt_data,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	mt_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(PC),d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon
	lea	$dff0a0,a5
	lea	mt_aud1temp(PC),a6
	bsr	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	bsr	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	bsr	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	bsr	mt_playit
	move.w	#$01f4,d0
mt_rls	dbf	d0,mt_rls
	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096
	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
mt_voice3
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
mt_voice2
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
mt_voice1
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
mt_voice0
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
mt_stop tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2
	rts
mt_playit
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_nosamplechange
	moveq	#0,d3
	lea	mt_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange
mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange
	tst.w	(a6)
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon
mt_retrout
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)
mt_nonewper
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
	rts
mt_posjmp
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts
mt_setvol
	move.b	3(a6),8(a5)
	rts
mt_break
	not.w	mt_status
	rts
mt_setfil
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_setspeed
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back rts

mt_aud1temp
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
mt_aud2temp
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
mt_aud3temp
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
mt_aud4temp
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

mt_partnote	dc.l	0
mt_partnrplay	dc.l	0
mt_counter	dc.w	0
mt_partpoint	dc.l	0
mt_samples	dc.l	0
mt_sample1	dcb.l	31,0
mt_maxpart	dc.w	0
mt_dmacon	dc.w	0
mt_status	dc.w	0

mt_arpeggio
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000	
	