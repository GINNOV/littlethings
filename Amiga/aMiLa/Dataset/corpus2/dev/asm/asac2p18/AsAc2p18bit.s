*-----------------------------------------------------------------------
*                            AsAc2p18bit.s  v1.0   25-8-96
*
*
*         a fast 18bit truecolor ham8 c2p routine by ASA/Cirion
*                Modified from Peter Mcgavins Gloom c2p
*  On 030/28Mhz machine this takes 1.6 frames from processor to convert
*     And then it activates blitter to make 1 blit for every plane
*                    Long word writes to chipmem !
*                          Double buffering !
*                              Linear !
*
*              Remember to thank me if you use this !  =)
*
* tchunky .l = ptr to truecolor chunky area in fast mem  160*100*4 RBGB
* Cbuf = buffer for c2p routine. Processor converts chunky to Cbuf
*        and then blitter converts from Cbuf to screen
* Chip_map2 .l = ptr to 640/8*100*2 are in chip mem for Ham8 Mask bits
* Chip_map .l = ptr to 640/8*100*6 screen 1 in chip mem
* Chip_map3 .l = ptr to 640/8*100*6 screen 2 in chip mem
* c2p_blitter_4pass .w = blitter progress
*                       0-blitter is ready for blits
*                       10- blitting plane 1
*                       11- blitting plane 2
*                       12- blitting plane 3
*                       13- blitting plane 4
*                       14- blitting plane 5
*                       15- blitting plane 6
*                       16- all done
*
*
* Remember to OwnBlitter() before using this. Or use QBlit()  :-)
* Works nice... Used in a demo  Showstopper/Cirion  at assembly'96
*
*  Don't blame me if you destroy your computer/software with this ! ;)
*
* My E-mail address:   juhpin@freenet.hut.fi
*-----------------------------------------------------------------------

BLTSIZH	equ	$05e
BLTSIZV	equ	$05c

	incdir	include:
	include	omat/custom.i


	section	himohomo,code

	clr.w	c2p_blitter_4pass
	move.w	#%1000000001000000,intena+custom	; blitter int

	jsr	init_ham8_screen


 ; --- Drawing loop ---
	jsr	change_buffers
	jsr	convert_tchunky
 ; ---
	rts


*----------------------- VBI -----------------------
*-- Put this at start of your VBI interrupt --

; -VBI-
;	cmp.w	#10,c2p_blitter_4pass
;	blt.s	no_blitter_int
;	btst	#6,intreqr+custom
;	bne.s	no_blitter_int
;		MOVEM.L	D0-D7/A0-A6,-(sp)
;		jsr	blitter_4pass_cont
;		MOVEM.L	(sp)+,D0-D7/A0-A6
;	move.w	#%0000000001000000,intreq+custom
;	rte
;no_blitter_int:
;	btst	#5,intreqr+custom
;	beq.s	yeah_vbi_int
;	rte
;yeah_vbi_int:

*-- Now your own VBI things here --
*---------------------------------------------------






*------------------------ c2p routines -----------------------
;///////////////////////////////////////////
convert_tchunky:
	move.l	tchunky,a0
	move.l	#cbuf,a1
	move.l	#640,d0		; width
	move.l	#100,d1		; height	if you change these
	move.l	#80*100,d2	; plane size	then you must modify
	move.l	#80,d3		; line size	blitter routines !
	jsr	_c2p		;		it thinks you have 640*100
				;		screen
ei_olla_viel_4pass_tehty_tchu:
	tst.w	c2p_blitter_4pass
	bne.s	ei_olla_viel_4pass_tehty_tchu

	move.w	#10,c2p_blitter_4pass
	bsr	blitter_4pass_cont	; start blitter
	rts

;////////////////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////
init_ham8_screen:
	move.l	#c2p_cop,cop1lch+custom

	move.l	chip_map2,d0		; mask planes
	move.l	#bluit,a1
	swap	d0
	move.w	d0,(a1)
	swap	d0
	move.w	d0,4(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,8(a1)
	swap	d0
	move.w	d0,12(a1)

	jsr	aseta_disp

 move.l	chip_map2,a0		; do ham8 mask
 move.l	a0,a1
 add.l	#80*100,a1
 move.w	#80*100-1,d7
duu_rgb_plane_class:
 move.b	#%11001100,(a1)+	; plane 1		RGBB -order
 move.b	#%01110111,(a0)+	; plane 0		! you must draw
 dbf	d7,duu_rgb_plane_class				in RBGB -order !
 

	move.l	#tyhja,d0		; clear sprites
	move.l	#spruit,a1
	move.w	d0,(a1)
	move.w	d0,4(a1)
	move.w	d0,8(a1)
	move.w	d0,12(a1)
	move.w	d0,16(a1)
	move.w	d0,20(a1)
	move.w	d0,24(a1)
	move.w	d0,28(a1)
	move.l	#spruit2,a1
	swap	d0
	move.w	d0,(a1)
	move.w	d0,4(a1)
	move.w	d0,8(a1)
	move.w	d0,12(a1)
	move.w	d0,16(a1)
	move.w	d0,20(a1)
	move.w	d0,24(a1)
	move.w	d0,28(a1)
	rts
;//////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////
aseta_disp:
	move.l	#bluit,a1
	move.l	dispbuf,d0
	swap	d0
	move.w	d0,16(a1)
	swap	d0
	move.w	d0,20(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,24(a1)
	swap	d0
	move.w	d0,28(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,32(a1)
	swap	d0
	move.w	d0,36(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,40(a1)
	swap	d0
	move.w	d0,44(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,48(a1)
	swap	d0
	move.w	d0,52(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,56(a1)
	swap	d0
	move.w	d0,60(a1)
	rts
;//////////////////////////////////////////////////////
change_buffers:
	cmp.w	#1,dbuffer
	beq.s	buffer_1
	  move.l	chip_map,chipbuf
	  move.l	chip_map3,dispbuf
	  move.w	#1,dbuffer
	  bsr	aseta_disp
	rts

buffer_1
	  move.l	chip_map3,chipbuf
	  move.l	chip_map,dispbuf
	  move.w	#0,dbuffer
	  bsr	aseta_disp
	rts
;;;;;
;/////////////////////////////////
	cnop	0,4
blitter_4pass_cont:
; tst.l	chipbuf
; beq.w	_planes_ready
	cmp.w	#10,c2p_blitter_4pass
	beq.s	_plane_0
	cmp.w	#11,c2p_blitter_4pass
	beq.w	_plane_1
	cmp.w	#12,c2p_blitter_4pass
	beq.w	_plane_2
	cmp.w	#13,c2p_blitter_4pass
	beq.w	_plane_3
	cmp.w	#14,c2p_blitter_4pass
	beq.w	_plane_4
	cmp.w	#15,c2p_blitter_4pass
	beq.w	_plane_5
	cmp.w	#16,c2p_blitter_4pass
	beq.w	_planes_ready
	rts
;0
_plane_0:
;	waitblit
 btst	#14,dmaconr+custom
 bne.s	perkules_0
	move.l	#cbuf+4,bltapth+custom
	move.l	#cbuf+2,bltbpth+custom
	move.l	chipbuf,d0
	move.l	d0,bltdpth+custom
	move.w	#%0101010101010101,bltafwm+custom
	move.w	#%0101010101010101,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0000000000000000,bltcon1+custom
	move.w	#%1111110111111000,bltcon0+custom
	move.w	#4000,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#11,c2p_blitter_4pass
perkules_0:
	rts
;1
_plane_1:
;	waitblit
 btst	#14,dmaconr+custom
 bne.s	perkules_0
	move.l	#cbuf,bltapth+custom
	move.l	#cbuf+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000,d0
	move.l	d0,bltdpth+custom
	move.w	#%1010101010101010,bltafwm+custom
	move.w	#%1010101010101010,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0001000000000000,bltcon1+custom
	move.w	#%0000110111111000,bltcon0+custom
	move.w	#4000,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#12,c2p_blitter_4pass
	rts
;2
_plane_2:
;	waitblit
 btst	#14,dmaconr+custom
 bne.w	perkules_0
	move.l	#cbuf+8000*2+4,bltapth+custom
	move.l	#cbuf+8000*2+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*2,d0
	move.l	d0,bltdpth+custom
	move.w	#%0101010101010101,bltafwm+custom
	move.w	#%0101010101010101,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0000000000000000,bltcon1+custom
	move.w	#%1111110111111000,bltcon0+custom
	move.w	#4000,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#13,c2p_blitter_4pass
	rts
;3
_plane_3:
;	waitblit
 btst	#14,dmaconr+custom
 bne.s	perkules_1
	move.l	#cbuf+8000*2,bltapth+custom
	move.l	#cbuf+8000*2+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*3,d0
	move.l	d0,bltdpth+custom
	move.w	#%1010101010101010,bltafwm+custom
	move.w	#%1010101010101010,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0001000000000000,bltcon1+custom
	move.w	#%0000110111111000,bltcon0+custom
	move.w	#4000,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#14,c2p_blitter_4pass
perkules_1:
	rts
;4
_plane_4:
;	waitblit
 btst	#14,dmaconr+custom
 bne.s	perkules_1
	move.l	#cbuf+8000*4+4,bltapth+custom
	move.l	#cbuf+8000*4+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*4,d0
	move.l	d0,bltdpth+custom
	move.w	#%0101010101010101,bltafwm+custom
	move.w	#%0101010101010101,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0000000000000000,bltcon1+custom
	move.w	#%1111110111111000,bltcon0+custom
	move.w	#4000,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#15,c2p_blitter_4pass
	rts
;5
_plane_5:
;	waitblit
 btst	#14,dmaconr+custom
 bne.w	perkules_1
	move.l	#cbuf+8000*4,bltapth+custom
	move.l	#cbuf+8000*4+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*5,d0
	move.l	d0,bltdpth+custom
	move.w	#%1010101010101010,bltafwm+custom
	move.w	#%1010101010101010,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0001000000000000,bltcon1+custom
	move.w	#%0000110111111000,bltcon0+custom
	move.w	#4000,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#16,c2p_blitter_4pass
	rts

_planes_ready:
	move.w	#0,c2p_blitter_4pass
	rts
;////////////////////////////////////////////////////////////////

tchunky:	dc.l	0	; ptr to chunky data  in  RBGB -order
chip_map2:	dc.l	0	; ham8 mask
chip_map:	dc.l	0	; screen buffer 1
chip_map3:	dc.l	0	; screen buffer 2
c2p_blitter_4pass:	dc.w	0	; for blitter ....
chipbuf:	dc.l	0	; ptr to drawin buffer
dispbuf:	dc.l	0	; ptr to view screen
dbuffer:	dc.w	0	; visible buffer ?

;////////////////////////////////////////////////////////////////

Suorista:	MACRO
 move.l	d5,-(sp)
	move.l	(a0)+,d1
	move.l	(a0)+,d5
	move.l	(a0)+,d2
 move.l	#$ff00ff00,d6
	move.l	d1,d0
	and.l	d6,d0
	eor.l	d0,d1
	lsl.l	#8,d1
	move.l	d2,d3
	and.l	d6,d3
	eor.l	d3,d2
	lsr.l	#8,d3
	or.l	d3,d0
	or.l	d2,d1
	 move.l	(a0)+,d3
	move.l	d5,d2
	and.l	d6,d2
	eor.l	d2,d5
	lsl.l	#8,d5
	move.l	d3,d4
	and.l	d6,d4
	eor.l	d4,d3
	lsr.l	#8,d4
	or.l	d4,d2
	or.l	d5,d3
	move.l	(sp)+,d5
	move.l	a2,d6
	ENDM


	cnop	0,4
_c2p:
		movea.l	d2,a5		; a5 = bpmod
		lsl.l	#2,d2
		add.l	a5,d2
		subq.l	#2*2,d2
		movea.l	d2,a6		; a6 = 5*bpmod-2

		lsr.w	#4,d0
		ext.l	d0
		move.l	d0,d4
		subq.l	#1,d4
		move.l	d4,-(sp)	; (4,sp) = num of 16 pix per row - 1

		add.l	d0,d0		; num of 8 pix per row (bytesperrow)
		sub.l	d0,d3
		sub.l	a6,d3
		move.l	d3,-(sp)	; (sp) = linemod-bytesperrow-5*bpmod+2

		move.w	d1,d7
		subq.w	#1,d7		; d7 = height-1

		movea.l	#$f0f0f0f0,a2	; a2 = 4 bit mask
		movea.l	#$cccccccc,a3	; a3 = 2 bit mask
		movea.l	#$aaaa5555,a4	; a4 = 1 bit mask
		move.l	a2,d6		; 4 bit mask = #$f0f0f0f0

;------------------------------------------------------------------------
;------------------------------------------------------------------------
		swap	d7
		move.w	6(sp),d7	; num 16 pix per row - 1
 suorista
		move.l	d0,d4
		and.l	d6,d0
		eor.l	d0,d4
		lsl.l	#4,d4
		bra.w	.same_from_here
		cnop	0,4
.outerloop	swap	d7
		move.w	6(sp),d7	; num 16 pix per row - 1
 suorista
		move.l	d5,(a1)		; 31 -> plane 4
		adda.l	a5,a1		; +bpmod
		move.l	d0,d4
		and.l	d6,d0
		eor.l	d0,d4
		lsl.l	#4,d4
		adda.l	(sp),a1		; +linemod-bytesperrow-5*bpmod+2
		bra.b	.same_from_here
.innerloop
 suorista
		move.l	d5,(a1)		; 31 -> plane 4
		adda.l	a5,a1		; +bpmod

		move.l	d0,d4
		and.l	d6,d0
		eor.l	d0,d4
		lsl.l	#4,d4
		suba.l	a6,a1		; -5*bpmod+2
.same_from_here
		move.l	d2,d5
		and.l	d6,d5
		eor.l	d5,d2
		lsr.l	#4,d5
		or.l	d5,d0
		or.l	d4,d2		; 00x02 -> 10 11
		move.l	d1,d4
		and.l	d6,d1
		eor.l	d1,d4
		move.l	d3,d5
		and.l	d6,d5
		eor.l	d5,d3
		lsr.l	#4,d5
		lsl.l	#4,d4
		or.l	d5,d1
		or.l	d4,d3		; 01x03 -> 12 13
		move.l	a3,d6		; 2 bit mask = #$cccccccc
		move.l	d2,d4
		and.l	d6,d2
		eor.l	d2,d4
		move.l	d3,d5
		and.l	d6,d5
		eor.l	d5,d3
		lsl.l	#2,d4
		or.l	d4,d3		; 11x13b -> 23

		move.l	d3,(a1)		; 33 -> plane 0
		adda.l	a5,a1		; +bpmod
		adda.l	a5,a1		; +bpmod
		move.l	a4,d6		; 1 bit mask = #$aaaa5555
		lsr.l	#2,d5
		or.l	d5,d2		; 11x13a -> 22

		move.l	d2,(a1)		; 32 -> plane 2
		adda.l	a5,a1		; +bpmod
		adda.l	a5,a1		; +bpmod

		lsl.l	#2,d0
		or.l	d0,d1		; 10x12b -> 21
		move.l	d1,d5
		dbra	d7,.innerloop
		swap	d7
		dbra	d7,.outerloop
		move.l	d5,(a1)		; 31 -> plane 4
		addq.l	#8,sp		; remove locals
		rts



;--------------------------- copper list ----------------------
	section feafae,data_c
c2p_cop:
	dc.w	$01fc,3+16384		; doublescan
	dc.w	$108,-80-8
	dc.w	$10a,-8

	dc.w	diwstrt,$4481
	dc.w	diwstop,$0ac1

	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

	dc.w	bplcon1,0
	dc.w	bplcon2,%0000001000000000
	dc.w	bplcon3,%0000000000100000

	dc.w	bplcon0,%1000101000010001

	dc.w	bpl1pth
bluit:	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0,bpl5pth
	dc.w	0,bpl5ptl
	dc.w	0,bpl6pth
	dc.w	0,bpl6ptl
	dc.w	0,bpl7pth
	dc.w	0,bpl7ptl
	dc.w	0,bpl8pth
	dc.w	0,bpl8ptl
	dc.w	0

	dc.w	spr0ptl
spruit:	dc.w	0
	dc.w	spr1ptl,0
	dc.w	spr2ptl,0
	dc.w	spr3ptl,0
	dc.w	spr4ptl,0
	dc.w	spr5ptl,0
	dc.w	spr6ptl,0
	dc.w	spr7ptl,0

	dc.w	spr0pth
spruit2: dc.w	0
	dc.w	spr1pth,0
	dc.w	spr2pth,0
	dc.w	spr3pth,0
	dc.w	spr4pth,0
	dc.w	spr5pth,0
	dc.w	spr6pth,0
	dc.w	spr7pth,0

	dc.w	bplcon3,%0000000000100000

	dc.l	$fffffffe
	dc.l	$fffffffe

tyhja:	dc.l	0,0,0,0

cbuf:	blk.b	640/8*100*6,0
