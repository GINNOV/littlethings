
;  Octalyser replayer and graphics displayer. 

; Yes ! I have to admit I drew the picture ( for my little daughter,honest )

; Note the code is a crib of Mike Crosses Zoolook.s from disc 2. For more
;info read Mikes tutorial on that disc.

; To import your own gfx, the colour map should be behind bit planes for
;a 320*200*5 picture. Change the incbin in line 123.

; To import your own octalyser module, change the incbin in line 141.

; Have fun, M.Meany.


 opt c-

 incdir :include/
 include exec/exec_lib.i
 include workdisk:Include/hardware.i

 jsr rs_init

 lea $dff000,a5	             Offset for hardware registers
 
 move.l	#Picture,d0          d0=addr of first bitplane
 
 move.l	#(320/8)*200,d1      d1=size of each bitplane
 
 move.w	d0,pl1l
 swap   d0
 move.w d0,pl1h
 swap   d0
 
 add.l	d1,d0
 move.w	d0,pl2l
 swap	d0
 move.w	d0,pl2h
 swap	d0

 add.l	d1,d0
 move.w	d0,pl3l
 swap	d0
 move.w	d0,pl3h
 swap	d0
 
 add.l	d1,d0
 move.w	d0,pl4l
 swap	d0
 move.w	d0,pl4h
 swap	d0

 add.l	d1,d0
 move.w	d0,pl5l
 swap	d0
 move.w	d0,pl5h
 swap	d0
 
 add.l	d1,d0
 
 lea Colours,a3              D0 points to the colour table,
 move.l d0,a4                Which is placed into the colour   
 move.w #$180,d0       	     registers beginning at $dff180
 moveq #31,d5		     31 colours - exclding $180
Colloop	
 move.w d0,(a3)+	     Move first colour in, and increment pointer
 move.w (a4)+,(a3)+          And repeat for all colours
 addq.w #2,d0		     By adding two to register pointer
 dbra d5,Colloop             Exit loop when done

 lea Gfxname,a1     	     Get library name
 moveq #0,d0                 No particular version
 CALLEXEC OpenLibrary	     Open graphics library
 tst.l d0
 beq.s Get_out_quick	     If not - fast exit 
 move.l d0,a1                Save old address
 move.l 38(a1),Old     	     Save old copper address
 CALLEXEC CloseLibrary	     Close graphics library
 move.w #$0020,dmacon(a5)    Disable sprites (Horizontal flickers!)
 move.l #Newcop,cop1lch(a5)  Insert new copper data
 
Wait
 btst  #6,CIAAPRA
 bne.s Wait
 move.l Old,cop1lch(a5)      Restore copper
 move.w #$83e0,dmacon(a5)    Restore DMA channel
Get_out_quick  		    
; CALLEXEC Permit	             Restore multi-tasking
 jsr rs_exit
 rts			     Exit

 section mm,data_c

Newcop                   
 dc.w diwstrt,$2c81          Top left of screen
 dc.w diwstop,$f4c1          Bottom right of screen - NTSC ($2cc1 for PAL)
 dc.w ddfstrt,$38            Data fetch start
 dc.w ddfstop,$d0            Data fetch stop
 dc.w bplcon0,$5200          Select lo-res 16 colour 
 dc.w bplcon1,0              No horizontal offset

Colours ds.w 64              Space for 16 colour registers 
 
     dc.w bpl1pth            Plane pointers for 4 planes          
pl1h dc.w 0,bpl1ptl          
pl1l dc.w 0,bpl2pth
pl2h dc.w 0,bpl2ptl
pl2l dc.w 0,bpl3pth
pl3h dc.w 0,bpl3ptl
pl3l dc.w 0,bpl4pth
pl4h dc.w 0,bpl4ptl
pl4l dc.w 0,bpl5pth
pl5h dc.w 0,bpl5ptl
pl5l dc.w 0

     dc.w $ffff,$fffe        End of copper list
 
Old 
 dc.l 0 		     Storage point

Picture 
 Incbin "workdisk:bitmaps/piccy.bm"     Calls the raw data from disk 

Gfxname 
 dc.b "graphics.library",0   Pointer for library
 even

 * THATS ALL FOLKS *

**********************************
* OKTALYZER V1.1 REPLAYER SOURCE *
**********************************

		section	replayer,code_c

;by A.Sander with Defpac2
;(C) 1989 VERLAG MAYER
;- only for 4-Channels

rs_song:	incbin	workdisk:modules/demosong1
rs_songend:

p:		bsr.s	rs_init
		bmi.s	rs_error
rs_left:	btst	#6,$bfe001
		bne.s	rs_left
		bsr	rs_exit
		moveq	#0,d0
		rts
rs_error:	moveq	#100,d0
		rts

* init ********************************

rs_init:	lea	rs_song,a5
		cmp.l	#'OKTA',(a5)+
		bne	rs_error2
		cmp.l	#'SONG',(a5)+
		bne	rs_error2
		move.l	a5,a0
		lea	rs_cmformat(pc),a1
		bsr	rs_search
		lea	rs_channelmodes(pc),a0
		tst.l	(a0)+
;		bne	rs_error2
		tst.l	(a0)+
;		bne	rs_error2
		move.l	a5,a0
		lea	rs_extformat(pc),a1
		bsr	rs_search
		move.l	a5,a0
		bsr	rs_getpatts
		move.l	a5,a0
		bsr	rs_getsamples

		clr.w	rs_pointer
		bsr	rs_gettrkpos
		sub.l	#16,rs_trkpos
		subq.w	#1,rs_patty

		move.l	#$40404040,rs_vol
		clr.w	rs_filter
		clr.l	0.w
		move.w	rs_speed,rs_actspeed
		clr.w	rs_actcyc
		move.w	#-1,rs_nextpt

		lea	rs_pbuffs,a0
		moveq	#15,d0
rs_loop4:	clr.l	(a0)+
		dbf	d0,rs_loop4
		lea	rs_pattline,a0
		moveq	#3,d0
rs_loop5:	clr.l	(a0)+
		dbf	d0,rs_loop5

		move.w	#$ff,$dff09e
		move.w	#$4000,$dff09a
		move.l	$6c.w,rs_oldint+2
		move.l	$70.w,rs_oldaud
		move.l	#rs_int,$6c.w
		move.l	#rs_audint,$70.w
		move.w	#$780,$dff09c
		move.w	#$780,$dff09a
		move.w	#$c000,$dff09a
		moveq	#0,d0
		rts

rs_error2:	moveq	#-1,d0
		rts

* format search ***********************

;a0:fpt
;a1:format list

rs_search:	move.l	a0,a2
		move.l	(a1)+,d0
		beq.s	rs_ex
rs_loop:	cmp.l	#rs_songend,a2
		beq.s	rs_ex
		cmp.l	(a2)+,d0
		bne.s	rs_next
		move.l	(a1)+,d0
		cmp.l	(a2)+,d0
		ble.s	rs_nocorrect
		move.l	-4(a2),d0
rs_nocorrect:	move.l	(a1)+,a3
rs_copy:	subq.l	#1,d0
		bmi.s	rs_search
		move.b	(a2)+,(a3)+
		bra.s	rs_copy
rs_next:	add.l	(a2)+,a2
		bra.s	rs_loop
rs_ex:		rts

* pattern descriptor ******************

rs_getpatts:	lea	rs_pattpts(pc),a1
		move.l	#'PBOD',d0
rs_loop2:	cmp.l	#rs_songend,a0
		beq.s	rs_ready
		movem.l	(a0)+,d1-d2
		cmp.l	d0,d1
		beq.s	rs_got
		add.l	d2,a0
		bra.s	rs_loop2
rs_got:		move.l	a0,(a1)+
		add.l	d2,a0
		bra.s	rs_loop2
rs_ready:	rts

* sample descriptor *******************

rs_getsamples:	lea	rs_samplepts(pc),a1
		lea	rs_samples,a2
		move.l	#'SBOD',d0
rs_loop2a:	cmp.l	#rs_songend,a0
		beq.s	rs_sready
		movem.l	(a0)+,d1-d2
		cmp.l	d0,d1
		beq.s	rs_gots
		add.l	d2,a0
		bra.s	rs_loop2a
rs_gots:	tst.l	20(a2)
		bne.s	rs_setsample
		lea	32(a2),a2
		clr.l	(a1)+
		bra.s	rs_gots
rs_setsample:	move.l	a0,(a1)+
		lea	32(a2),a2
		add.l	d2,a0
		bra.s	rs_loop2a
rs_sready:	rts

* exit ********************************

rs_exit:	move.w	#$4000,$dff09a
		move.l	rs_oldint+2,$6c.w
		move.l	rs_oldaud,$70.w
		move.w	#$c000,$dff09a
		lea	$dff000,a6
		moveq	#0,d0
		move.w	#$f,$96(a6)
		move.w	d0,$a8(a6)
		move.w	d0,$b8(a6)
		move.w	d0,$c8(a6)
		move.w	d0,$d8(a6)
		rts

rs_int:		btst	#5,$dff01f
		beq.s	rs_oldint
		movem.l	d0-d7/a0-a6,-(sp)
		bsr	rs_rh
		movem.l	(sp)+,d0-d7/a0-a6
rs_oldint:	jmp	0

rs_rh:		bsr	rs_p4
		addq.w	#1,rs_actcyc
		move.w	rs_actspeed,d0
		cmp.w	rs_actcyc,d0
		ble.s	rs_addcyc
		rts

rs_addcyc:	clr.w	rs_actcyc
		moveq	#16,d0
		add.l	d0,rs_trkpos
		addq.w	#1,rs_patty
		bsr	rs_getppatt
		tst.w	rs_nextpt
		bpl.s	rs_pattend
		cmp.w	rs_patty,d0
		bgt.s	rs_nonew
rs_pattend:	clr.w	rs_patty
		tst.w	rs_nextpt
		bmi	rs_nonextpt
		move.w	rs_nextpt,rs_pointer
		bra.s	rs_newpos
rs_nonextpt:	addq.w	#1,rs_pointer
rs_newpos:	move.w	rs_pointer,d0
		cmp.w	rs_len,d0
		bne.s	rs_nonewinit
		clr.w	rs_pointer
		move.w	rs_speed,rs_actspeed
rs_nonewinit:	bsr	rs_gettrkpos
rs_nonew:	move.l	rs_trkpos,a0
		lea	rs_pattline,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	#-1,rs_nextpt
		rts

rs_p4:		tst.w	rs_actcyc
		bne.s	rs_effects

		bsr	rs_set
		tst.w	d4
		beq.s	rs_effects
		bsr	rs_dma
		bsr	rs_setperiods
		or.w	#$8000,d4
		move.w	d4,$dff096
		bsr	rs_dma
		bsr	rs_action

rs_effects:	bsr	rs_effect
		lea	rs_vol,a0
		lea	$dff0a9,a1
		move.b	(a0)+,(a1)
		move.b	(a0)+,$10(a1)
		move.b	(a0)+,$20(a1)
		move.b	(a0)+,$30(a1)
		tst.b	rs_filter
		beq.s	rs_blink
		bclr	#1,$bfe001
		rts
rs_blink:	bset	#1,$bfe001
		rts

rs_set:		lea	rs_samplepts,a0
		lea	rs_pattline,a2
		lea	rs_pbuffs,a3
		lea	$dff0a0,a4
		lea	rs_periods,a6

		moveq	#0,d4
		moveq	#1,d5
		moveq	#3,d7

rs_ploop:	bsr.s	rs_set4
		addq.w	#4,a2
		lea	16(a3),a3
		lea	$10(a4),a4
		add.w	d5,d5
		dbf	d7,rs_ploop
		rts

rs_set4:	moveq	#0,d3
		move.b	(a2),d3
		beq	rs_noset
		subq.w	#1,d3
		moveq	#0,d0
		move.b	1(a2),d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	(a0,d0.w),d2
		beq	rs_noset
		lsl.w	#3,d0
		lea	rs_samples,a1
		add.w	d0,a1
		tst.w	30(a1)
		beq	rs_noset
		move.l	20(a1),d1
		lsr.l	#1,d1
		tst.w	d1
		beq	rs_noset
		move.w	#124,6(a4)
		lsl.w	#7,d5
		move.w	d5,$dff09a
		lsr.w	#7,d5
		move.w	d5,$dff096
		or.w	d5,d4
		move.l	d2,(a4)
		move.w	d3,12(a3)
		add.w	d3,d3
		move.w	(a6,d3.w),14(a3)
		move.l	a0,-(sp)
		lea	rs_vol,a0
		moveq	#0,d0
		move.b	rs_volum1(pc,d7.w),d0
		move.b	29(a1),(a0,d0.w)
		move.l	(sp)+,a0
		tst.w	26(a1)
		beq.s	rs_norep
		tst.w	24(a1)
		bne.s	rs_realrep

		move.w	26(a1),4(a4)
		clr.l	(a3)
		clr.w	4(a3)
		moveq	#0,d0
		move.w	26(a1),d0
		add.l	d0,d0
		add.l	d0,d2
		move.l	d2,6(a3)
		move.l	20(a1),d1
		sub.l	d0,d1
		lsr.l	#1,d1
		move.w	d1,10(a3)
		rts

rs_volum1:	dc.b	3,2,1,0

rs_realrep:	move.w	24(a1),4(a4)
		moveq	#0,d0
		move.w	24(a1),d0
		add.l	d0,d0
		add.l	d2,d0
		move.l	d0,(a3)
		move.w	26(a1),4(a3)
		moveq	#0,d0
		move.w	24(a1),d0
		add.w	26(a1),d0
		add.l	d0,d0
		add.l	d0,d2
		move.l	d2,6(a3)
		move.l	20(a1),d1
		sub.l	d0,d1
		lsr.l	#1,d1
		move.w	d1,10(a3)
		rts

rs_norep:	move.w	d1,4(a4)
		moveq	#2,d0
		move.l	d0,(a3)
		move.w	#1,4(a3)
		clr.l	6(a3)
		clr.w	10(a3)
rs_noset:	rts

rs_setperiods:	lea	rs_pbuffs,a3
		lea	$dff000,a4
		btst	#0,d4
		beq.s	rs_notc1
		move.w	14(a3),$a6(a4)
rs_notc1:	btst	#1,d4
		beq.s	rs_notc2
		move.w	14+16(a3),$b6(a4)
rs_notc2:	btst	#2,d4
		beq.s	rs_notc3
		move.w	14+32(a3),$c6(a4)
rs_notc3:	btst	#3,d4
		beq.s	rs_notc4
		move.w	14+48(a3),$d6(a4)
rs_notc4:	rts

rs_action:	lea	rs_pbuffs,a3
		lea	$dff0a0,a4
		moveq	#3,d7
rs_aloop:	move.l	(a3),d0
		beq.s	rs_nopt
		move.l	d0,(a4)
		clr.l	(a3)
rs_nopt:	move.w	4(a3),d0
		beq.s	rs_nolen
		move.w	d0,4(a4)
		clr.w	4(a3)
rs_nolen:	lea	16(a3),a3
		lea	$10(a4),a4
		dbf	d7,rs_aloop
		rts

rs_effect:	lea	p(pc),a1
		lea	rs_pattline,a2
		lea	rs_pbuffs,a3
		lea	$dff0a0,a4
		lea	rs_periods,a6
		moveq	#1,d5
		moveq	#3,d7
rs_eloop:	bsr	rs_doeff
		addq.w	#4,a2
		lea	$10(a3),a3
		lea	$10(a4),a4
		add.w	d5,d5
		dbf	d7,rs_eloop
		rts

rs_doeff:	moveq	#0,d0
		move.b	2(a2),d0
		add.w	d0,d0
		moveq	#0,d1
		move.b	3(a2),d1

		move.w	rs_effecttab(pc,d0.w),d0
		beq.s	rs_noeff
		bmi.s	rs_1eff

		jsr	(a1,d0.w)
		bra.s	rs_noeff

rs_1eff:	tst.w	rs_actcyc
		bne.s	rs_noeff
		neg.w	d0
		jsr	(a1,d0.w)
rs_noeff:	rts

rs_effecttab:	dc.w	0,rs_portd-p,rs_portu-p,0,0,0
		dc.w	0,0,0,0,rs_arp-p,rs_arp2-p
		dc.w	0,rs_slided-p,0,p-rs_filt,0,p-rs_slideu
		dc.w	0,0,0,p-rs_slided,0,0
		dc.w	0,p-rs_posjmp,0,p-rs_release,p-rs_cspeed,0
		dc.w	rs_slideu-p,rs_volume-p,0,0,0,0

rs_portd:	sub.w	d1,14(a3)
		bpl.s	rs_pdok
		move.w	#113,14(a3)
rs_pdok:	move.w	14(a3),6(a4)
		rts

rs_portu:	add.w	d1,14(a3)
		bpl.s	rs_puok
		move.w	#113,14(a3)
rs_puok:	move.w	14(a3),6(a4)
		rts

rs_arp:		move.w	12(a3),d2
		move.w	rs_actcyc,d0
		move.b	rs_divtab(pc,d0.w),d0
		bne.s	rs_val1
		and.w	#$f0,d1		;runter
		lsr.w	#4,d1
		sub.w	d1,d2
		bra.s	rs_setarp

rs_val1:	subq.b	#1,d0
		bne.s	rs_val2
		move.w	d2,8(a4)
		bra.s	rs_setarp

rs_val2:	and.w	#$0f,d1
		add.w	d1,d2
		bra.s	rs_setarp

rs_divtab:	dc.b	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2

rs_arp2:	move.w	12(a3),d2
		move.w	rs_actcyc,d0
		and.w	#3,d0
		bne.s	rs_val3
		bra.s	rs_setarp

rs_val3:	subq.b	#1,d0
		bne.s	rs_val4
		and.w	#$f,d1
		add.w	d1,d2
		bra.s	rs_setarp

rs_val4:	subq.b	#1,d0
		beq.s	rs_setarp
		and.w	#$f0,d1
		lsr.w	#4,d1
		sub.w	d1,d2

rs_setarp:	tst.w	d2
		bpl.s	rs_arpok1
		moveq	#0,d2
rs_arpok1:	cmp.w	#35,d2
		ble.s	rs_arpok2
		moveq	#35,d2
rs_arpok2:	add.w	d2,d2
		move.w	(a6,d2.w),d0
		move.w	d0,6(a4)
		move.w	d0,14(a3)
		rts

rs_slided:	move.w	12(a3),d2
		sub.w	d1,d2
		move.w	d2,12(a3)
		bra.s	rs_setarp

rs_slideu:	move.w	12(a3),d2
		add.w	d1,d2
		move.w	d2,12(a3)
		bra.s	rs_setarp

rs_cspeed:	tst.b	d1
		beq.s	rs_nochange
		and.w	#$f,D1
		move.w	d1,rs_actspeed
rs_nochange:	rts

rs_filt:	tst.b	d1
		sne	rs_filter
		rts

rs_volume:	move.l	a0,-(sp)
		lea	rs_vol,a0
		moveq	#0,d0
		move.b	volum2(pc,d7.w),d0
		add.w	d0,a0
		cmp.w	#$40,d1
		bgt.s	rs_4567
		move.b	d1,(a0)
rs_vex:		move.l	(sp)+,a0
		rts

volum2:		dc.b	3,2,1,0

rs_4567:	sub.b	#$40,d1
		cmp.b	#$10,d1
		blt.s	rs_4
		sub.b	#$10,d1
		cmp.b	#$10,d1
		blt.s	rs_5
		sub.b	#$10,d1
		cmp.b	#$10,d1
		blt.s	rs_6
		sub.b	#$10,d1
		cmp.b	#$10,d1
		blt.s	rs_7
		bra.s	rs_vex

rs_6:		tst.w	rs_actcyc
		bne.s	rs_vex

rs_4:		sub.b	d1,(a0)
		bpl.s	rs_vex
		clr.b	(a0)
		bra.s	rs_vex

rs_7:		tst.w	rs_actcyc
		bne.s	rs_vex

rs_5:		add.b	d1,(a0)
		cmp.b	#$40,(a0)
		ble.s	rs_vex
		move.b	#$40,(a0)
		bra.s	rs_vex

rs_release:	tst.l	6(a3)
		beq.s	rs_rex
		tst.w	10(a3)
		beq.s	rs_rex
		move.w	d5,d0
		lsl.w	#7,d0
		move.w	d0,$dff09a
		move.l	6(a3),(a4)
		move.w	10(a3),4(a4)
		clr.l	6(a3)
		clr.w	10(a3)
		move.w	d0,$dff09c
		or.w	#$8000,d0
		move.w	d0,$dff09a
rs_rex:		rts

rs_posjmp:	move.w	d1,d0
		and.w	#$f,d0
		lsr.w	#4,d1
		mulu	#10,d1
		add.w	d1,d0
		cmp.w	rs_len,d0
		bge.s	rs_nojmp
		move.w	d0,rs_nextpt
rs_nojmp:	rts

rs_audint:	movem.l	d0-d1/a0,-(sp)
		lea	$dff000,a0
		move.w	$1e(a0),d0
		and.w	$1c(a0),d0
		moveq	#0,d1
		btst	#7,d0
		beq.s	rs_let1
		move.l	d1,$a0(a0)
		move.w	#1,$a4(a0)
		move.w	#$80,$9a(a0)
rs_let1:	btst	#8,d0
		beq.s	rs_let2
		move.l	d1,$b0(a0)
		move.w	#1,$b4(a0)
		move.w	#$100,$9a(a0)
rs_let2:	btst	#9,d0
		beq.s	rs_let3
		move.l	d1,$c0(a0)
		move.w	#1,$c4(a0)
		move.w	#$200,$9a(a0)
rs_let3:	btst	#10,d0
		beq.s	rs_let4
		move.l	d1,$d0(a0)
		move.w	#1,$d4(a0)
		move.w	#$400,$9a(a0)
rs_let4:	movem.l	(sp)+,d0-d1/a0
		rte

rs_gettrkpos:	lea	rs_patterns,a0
		add.w	rs_pointer,a0
		moveq	#0,d0
		move.b	(a0),d0
		bsr.s	rs_getpattern
		move.l	a0,rs_trkpos
		clr.w	rs_patty
		rts

rs_getppatt:	lea	rs_patterns,a0
		add.w	rs_pointer,a0
		moveq	#0,d0
		move.b	(a0),d0
rs_getpattern:	lea	rs_pattpts,a0
		add.w	d0,d0
		add.w	d0,d0
		move.l	(a0,d0.w),a0
		move.w	(a0)+,d0
		rts

rs_dma:		movem.w	d0-d1,-(sp)
		move.w	#4,d1
rs_nextline:	move.b	$dff006,d0
rs_waitline:	cmp.b	$dff006,d0
		beq.s	rs_waitline
		dbf	d1,rs_nextline
		movem.w	(sp)+,d0-d1
		rts

rs_cmformat:	dc.l	'CMOD',8,rs_channelmodes
rs_extformat:	dc.l	'SAMP',36*32,rs_samples
		dc.l	'SPEE',2,rs_speed
		dc.l	'PLEN',2,rs_len
		dc.l	'PATT',128,rs_patterns,0
rs_channelmodes:ds.w	4
rs_samples:	ds.b	36*32
rs_speed:	dc.w	6
rs_len:		dc.w	1
rs_patterns:	ds.b	128
rs_pattpts:	ds.l	64
rs_samplepts:	ds.l	36
rs_patty:	ds.w	1
rs_trkpos:	ds.l	1
rs_pbuffs:	ds.l	16
rs_pattline:	ds.l	4
rs_actspeed:	ds.w	1
rs_actcyc:	ds.w	1
rs_nextpt:	ds.w	1
rs_pointer:	ds.w	1
rs_vol:		ds.l	1
rs_filter:	ds.w	1
rs_oldaud:	ds.l	1
rs_periods:	dc.w	$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A,$21A
		dc.w	$1FC,$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140
		dc.w	$12E,$11D,$10D,$FE,$F0,$E2,$D6,$CA,$BE
		dc.w	$B4,$AA,$A0,$97,$8F,$87,$7F,$78,$71



