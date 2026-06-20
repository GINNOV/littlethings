


		opt	d+

		section chipmem,code_c
		
		include	source_1:include/my_hardware.i


* put equates, structure defs etc here

BP_WIDE		equ	320		;320 pixels wide
BP_TALL		equ	256		;256 pixels tall
BP_PIXELS	equ	BP_WIDE*BP_TALL
BP_BYTES		equ	BP_PIXELS/8
BP_DEPTH		equ	4		;4 bit planes

* main program variables


		rsreset
cl_ptr		rs.l	1

bp_1		rs.l	1
bp_2		rs.l	1
bp_3		rs.l	1
bp_4		rs.l	1

sizeof_vars	rs.w	0


* bob structure definition


		rsreset

bob_image	rs.l	1
bob_screen	rs.l	1
bob_bgnd		rs.l	1
bob_mask		rs.l	1

bob_rows		rs.w	1
bob_cols		rs.w	1
bob_xpos		rs.w	1
bob_ypos		rs.w	1

bob_deltax	rs.w	1
bob_deltay	rs.w	1

bob_flags	rs.w	1

bob_bcon0	rs.w	1
bob_bcon1	rs.w	1
bob_fmsk		rs.w	1
bob_lmsk		rs.w	1

bob_cptr		rs.l	1
bob_bptr		rs.l	1
bob_aptr		rs.l	1
bob_dptr		rs.l	1

bob_cmod		rs.w	1
bob_bmod		rs.w	1
bob_amod		rs.w	1
bob_dmod		rs.w	1


bob_sizeof	rs.w	0

bob_flag1	equ	bob_flags
bob_flag2	equ	bob_flags+1

*bob_flag1

* bits 0-3 : bitplane selectors planes 0-3 in REVERSE order!!
* bit 4    : ??

* bob_flag2 : minterm selector!!!



* new line structure definition V2.0


		rsreset

line_screen	rs.l	1		;ptr to 1st screen bitplane : assumes continuity
line_ssize	rs.w	1		;size of 1 bitplane in bytes
line_smod	rs.w	1		;screen modulo
line_coords	rs.l	1		;ptr to line coord list

line_deltax	rs.w	1
line_deltay	rs.w	1
line_2S_L	rs.w	1
line_oct_bits	rs.b	1
line_pad		rs.b	1

line_sizeof	rs.w	0


* line coord list structure


		rsreset

lc_next		rs.l	1
lc_x1		rs.w	1
lc_y1		rs.w	1
lc_x2		rs.w	1
lc_y2		rs.w	1
lc_pattern	rs.w	1
lc_bits		rs.b	1
lc_pad		rs.b	1
lc_sizeof	rs.w	0

* lc_bits : 0-3 = colour (bitplanes in which drawn)
*	 : 4 = SING bit for line draw


* polygon definition structure


		rsreset

poly_screen	rs.l	1	;1st bitplane to draw polygon on
poly_ssize	rs.w	1	;bitplane size
poly_smod	rs.w	1

poly_buffer	rs.l	1	;where to draw polygon
poly_wide	rs.w	1	;width of buffer in words
poly_tall	rs.w	1	;height in raster lines

poly_border	rs.l	1	;pointer to line definition structure

poly_xpos	rs.w	1
poly_ypos	rs.w	1

poly_flag	rs.b	1	;colours
poly_pad		rs.b	1

poly_sizeof	rs.w	0


* poly_flag	: bits 0-3 = colour


* poly_border : points to line definition structure. This in turn has
* a pointer to a line coord list, each entry of which should have the
* SING bit set in lc_bits.


		include	source_1:include/hardstart.i


		lea	$64,a0			;starrt of 68000 interrupt vectors
		lea	null_vector(pc),a1	;points to RTE
		moveq	#7,d0			;no of vectors
		bra.s	ki_a

ki_l		move.l	a1,(a0)+			;blast old interrupt vector
ki_a		dbra	d0,ki_l			;this many

		lea	vblint(pc),a0
		move.l	a0,$6c

		move.w	#$C020,INTENA(a5)		;enable vertical blank int
		move.w	#$2300,sr		;and allow 68000 to respond

		lea	vars(pc),a6		;now set up my own vars

		lea	BPL_1(pc),a0
		move.l	#BP_BYTES,d0
		move.l	a0,bp_1(a6)		;initialise

		add.l	d0,a0
		move.l	a0,bp_2(a6)		;bitplane

		add.l	d0,a0
		move.l	a0,bp_3(a6)		;pointers

		add.l	d0,a0
		move.l	a0,bp_4(a6)

		lea	copper_list(pc),a0
		move.l	a0,cl_ptr(a6)

		bsr	cl_bgen
		move.l	#-2,(a0)		;copper END instruction

		move.w	#$4200,BPLCON0(a5)	;bitplane control
		clr.w	BPLCON1(a5)
		clr.w	BPLCON2(a5)

		clr.w	BPL1MOD(a5)	;no extra-wide playfields so
		clr.w	BPL2MOD(a5)	;bitplane moduli are 0

		move.w	#$2984,DIWSTRT(a5)
		move.w	#$29C4,DIWSTOP(a5)

		move.w	#$38,DDFSTRT(a5)
		move.w	#$D0,DDFSTOP(a5)

		move.l	cl_ptr(a6),d0
		move.l	d0,COP1LCH(a5)	;set up copper
		clr.w	COPJMP1(a5)	;and generate screen

		move.w	#SETIT+DMAEN+BPLEN+COPEN+BLTEN,DMACON(a5)

		moveq	#16,d0
		lea	palette(pc),a0
		bsr	setpalette

		lea	testbob(pc),a4
		move.l	bp_1(a6),bob_screen(a4)
;		bsr	blit_image
		bsr	blitpic_i

waitmouse1	btst	#6,CIAAPRA
		bne.s	waitmouse1
waitmouse2	btst	#6,CIAAPRA
		beq.s	waitmouse2

		lea	test_line(pc),a4
		move.l	bp_1(a6),line_screen(a4)	;these 3 need to
		move.w	#BP_BYTES,line_ssize(a4)	;be initialised
		move.w	#40,line_smod(a4)
		bsr	drawline

;		move.l	bp_1(a6),a0
;		add.l	debug,a0
;		move.w	#-1,(a0)

waitmouse3	btst	#6,CIAAPRA
		bne.s	waitmouse3
waitmouse4	btst	#6,CIAAPRA
		beq.s	waitmouse4

		lea	test_poly(pc),a4
		move.l	bp_1(a6),poly_screen(a4)
		move.w	#BP_BYTES,poly_ssize(a4)
		move.w	#40,poly_smod(a4)
		lea	spare_mem,a0
		move.l	a0,poly_buffer(a4)
		bsr	draw_polygon


;		lea	spare_mem,a0
;		move.l	a0,BLTAPTH(a5)
;		move.l	bp_1(a6),BLTDPTH(a5)
;		move.w	#40-2*4,BLTDMOD(a5)
;		clr.w	BLTAMOD(a5)
;		moveq	#-1,d0
;		move.l	d0,BLTAFWM(a5)
;		move.w	#$09f0,BLTCON0(a5)
;		clr.w	BLTCON1(a5)
;		move.w	#80*64+4,BLTSIZE(a5)

		move.l	debug,d0 	;if I need it
		moveq	#20,d1
		moveq	#10,d2
		bsr	showd0
		move.l	debug+4,d0
		moveq	#20,d1
		moveq	#20,d2
		bsr	showd0
		move.l	debug+8,d0
		moveq	#20,d1
		moveq	#30,d2
		bsr	showd0
		move.l	debug+12,d0
		moveq	#20,d1
		moveq	#40,d2
		bsr	showd0
		move.l	debug+16,d0
		moveq	#20,d1
		moveq	#50,d2
		bsr	showd0
		move.l	debug+20,d0
		moveq	#20,d1
		moveq	#60,d2
		bsr	showd0
		move.l	debug+24,d0
		moveq	#20,d1
		moveq	#70,d2
		bsr	showd0
		move.l	bp_1(a6),d0
		moveq	#20,d1
		moveq	#80,d2
		bsr	showd0
		

hang		nop
		bra.s	hang


vblint		move.w	#$2700,sr	;kill other ints for now
		move.l	d0,-(sp)

		move.w	INTREQR(a5),d0

		btst	#6,d0		;blitter interrupt?
		beq.s	vblint_1

		move.w	#$0040,INTREQ(a5)
		addq.l	#1,bltcount

vblint_1		btst	#5,d0		;vertical blank interrupt?
		beq.s	vblint_2

		move.w	#$0020,INTREQ(a5)
		addq.l	#1,vblcount

vblint_2		btst	#4,d0		;copper interrupt?
		beq.s	vblint_3

		move.w	#$0010,INTREQ(a5)
		addq.l	#1,copcount

vblint_3		move.l	(sp)+,d0
		rte

vblcount		dc.l	0
copcount		dc.l	0
bltcount		dc.l	0


;setpalette(a0,a5,d0) set palette colours
;a0 = ptr to palette
;a5 = ptr to custom chips
;d0 = no of colours to set

;d0/a0-a1 corrupt

setpalette	move.l	a5,a1		;copy chip ptr
		add.l	#COLOR00,a1	;ptr to colour palette regs

		bra.s	setpalette_a

setpalette_l	move.w	(a0)+,(a1)+	;copy colour value from table

setpalette_a	dbra	d0,setpalette_l	;do this many

		rts


;cl_bgen(a0) a0 = ptr to where copper list goes
;make bitplane portion of copper list
;returns ptr to end of generated copper list

;d0-d2/a0 corrupt

cl_bgen		move.w	#BPL1PTH,d0

		move.l	#BPL_1,d1

		moveq	#4,d2
		bra.s	cl_bgen_a

cl_bgen_l	swap	d1		;get high word
		move.w	d0,(a0)+		;copper MOVE
		move.w	d1,(a0)+		;register value
		swap	d1		;now low word
		addq.w	#2,d0		;next register number
		move.w	d0,(a0)+		;copper MOVE
		move.w	d1,(a0)+		;register value
		addq.w	#2,d0
		add.l	#BP_BYTES,d1

cl_bgen_a	dbra	d2,cl_bgen_l

		rts


;blit_image(a4,a5) a4 = ptr to bob structure definition block
;a5 = ptr to custom chip registers

;d0-d7/a0-a3 corrupt

;uses Laurence's trick for shifted blitting without extra space at
;right edge of bob image data : A,B modulo -2, use no of word cols + 1,
;and set BLTALWM to zero to scrub unwanted data.


blit_image	move.l	bob_screen(a4),a0		;screen pointer
		move.w	bob_ypos(a4),d0
		mulu	#40,d0
		add.l	d0,a0			;add on y*40
		move.w	bob_xpos(a4),d0
		lsr.w	#4,d0
		add.w	d0,d0
		add.w	d0,a0			;add on 2*int(x/16)

		move.l	bob_image(a4),a1		;ptr to bitplane data
		move.w	bob_cols(a4),d6
		mulu	bob_rows(a4),d6
		add.l	d6,d6			;size of 1 bitplane of image in BYTES!

		move.l	#BP_BYTES,a2		;size of 1 screen bitplane in bytes

		move.l	bob_mask(a4),a3

		moveq	#3,d7			;bitplane counter

;see similar piece of code in DRAWLINE routine for explanation of
;bitplane number management trick.

blit_image_l1	swap	d7			;get bitplane bit number
		move.w	d7,d0			;for test
		addq.w	#1,d7			;next bitplane
		swap	d7			;back to loop counter
		btst	d0,bob_flag1(a4)		;this image active?
		beq	blit_image_b2

blit_image_b1	btst	#6,DMACONR(a5)		;blitter done?
		bne.s	blit_image_b1		;no, wait for it

		move.l	a0,bob_cptr(a4)		;bgnd and destination
		move.l	a0,bob_dptr(a4)		;bitplane pointers
		move.l	a1,bob_aptr(a4)		;ptr to image data
		move.l	a3,bob_bptr(a4)		;ptr to mask data

		move.w	#-2,d0
		move.w	d0,bob_amod(a4)		;modulo -2:part 1 of
		move.w	d0,bob_bmod(a4)		;Laurence's Trick

		move.w	bob_cols(a4),d0
		addq.w	#1,d0			;cols + 1:part 2 of
		add.w	d0,d0			;Laurence's Trick
		neg.w	d0
		add.w	#40,d0
		move.w	d0,bob_cmod(a4)		;C, D moduli equals
		move.w	d0,bob_dmod(a4)		;40-(cols width in bytes)

		moveq	#-1,d0
		clr.w	d0			;BLTALWM = 0 :Part 3 of
		move.l	d0,bob_fmsk(a4)		;Laurence's Trick

		moveq	#0,d0
		move.w	bob_xpos(a4),d0
		and.w	#%1111,d0		;frac(x/16)

		rol.w	#4,d0
		move.w	d0,d1
		or.w	#%1111,d0		;and in USEx bits!
		rol.w	#8,d0			;put in proper place
		or.b	bob_flag2(a4),d0		;put in minterm bits

		move.w	d0,bob_bcon0(a4)		;save BLTCON0 control word

		rol.w	#8,d1			;proper place
		move.w	d1,bob_bcon1(a4)

		movem.l	bob_bcon0(a4),d0-d5
		movem.l	d0-d5,BLTCON0(a5)

		movem.w	bob_cmod(a4),d0-d3
		movem.w	d0-d3,BLTCMOD(a5)

		move.w	bob_rows(a4),d0
		and.w	#$3ff,d0
		lsl.w	#6,d0
		move.w	bob_cols(a4),d1
		addq.w	#1,d1			;cols + 1 :part 2 of Laurence Trick
		and.w	#$3f,d1
		or.w	d1,d0
		move.w	d0,BLTSIZE(a5)

blit_image_b2	add.l	a2,a0			;next bgnd/dest bitplane
		add.l	d6,a1			;next image bitplane

		dbra	d7,blit_image_l1

		rts


;drawline(a4,a5) a4 = ptr to line structure definition V2.0
;a5 = ptr to custom chip registers


;draws line(s) according to the contents of the line definition
;structure(s). Note : line definition structure is a header structure
;containing workspace used by drawline() in this version. Actual
;coordinate and bitplane information etc., contained in separate list
;pointed to by an entry in the line definition structure.

;d0-d7/a0-a3 corrupted


drawline		move.l	line_coords(a4),a3

drawline_l0	moveq	#0,d1		;clear line octant selector
		move.w	lc_x2(a3),d0
		sub.w	lc_x1(a3),d0	;compute deltax = x2-x1
		roxl.w	#1,d1
		tst.w	d0		;>0 or <0?
		bge.s	drawline_b1	;>=0 so skip
		neg.w	d0		;else absolute value

drawline_b1	move.w	d0,line_deltax(a4)
		move.w	lc_y2(a3),d0
		sub.w	lc_y1(a3),d0	;compute deltay = y2-y1
		roxl.w	#1,d1
		tst.w	d0
		bge.s	drawline_b2
		neg.w	d0		;absolute value again

drawline_b2	move.w	d0,line_deltay(a4)

		move.w	line_deltax(a4),d2
		move.w	d2,d3
		sub.w	d0,d3

		roxl.w	#1,d1
		tst.w	d3
		bge.s	drawline_b3
		exg	d0,d2		;ensure smallest of the two in d0

drawline_b3	movem.w	d0/d2,line_deltax(a4)	Dx = DS, Dy = DL

		lea	octants(pc),a0
		add.w	d1,a0
		clr.w	d1
		move.b	(a0),d1		;get octant code
		move.b	lc_bits(a3),d0
		and.b	#$10,d0		;get SING bit
		lsr.b	#3,d0
		or.b	d0,d1

		asl.w	line_deltax(a4)		;2*DS
		move.w	line_deltax(a4),d0
		sub.w	line_deltay(a4),d0	;2*DS - DL

		bge.s	drawline_b4
		or.b	#$40,d1		;set SIGN bit if needed

drawline_b4	move.b	d1,line_oct_bits(a4)	;save BLTCON1 bits for later

		move.w	d0,line_2S_L(a4)	;save 2*DS-DL

;		lea	bp_1(a6),a0		;get ptr to bitplane pointer

		move.l	line_screen(a4),a0	;screen pointer

		move.w	d0,d1
		sub.w	line_deltay(a4),d1	;2*DS - 2*DL
		move.w	lc_y1(a3),d2
;		mulu	#40,d2

		mulu	line_smod(a4),d2		;y1 * bitplane size
		move.w	lc_x1(a3),d3
		asr.w	#4,d3
		add.w	d3,d3			;2*int(x1/16)
		ext.l	d3
		add.l	d3,d2		;bitplane offset

		move.w	line_deltax(a4),d3	;2*DS

		moveq	#0,d4
		move.w	lc_x1(a3),d4
		and.w	#$F,d4		;frac(x1/16)
		ror.w	#4,d4		;create STARTx bits
		move.w	d4,d5
		swap	d4
		move.w	d5,d4		;copy to TEXTUREx bits

		or.b	line_oct_bits(a4),d4	;create BLTCON1 bits

		swap	d4
		or.w	#$BCA,d4		;create BLTCON0 bits

		swap	d4
		move.w	line_deltay(a4),d5	;get DL

		moveq	#3,d7		;no of bitplanes - 1


;NB : trick here. Upper word of d7=0 after moveq #3,d7. Use this as
;the bitplane bit number, doing an addq.w #1,d7 each time, and using
;swap d7 to alternate between bitplane number counter & bitplane bit
;position counter.


drawline_l1	swap	d7		;get bitplane bit number
		move.w	d7,d6		;ready for test
		addq.w	#1,d7		;next bitplane number
		swap	d7		;back to loop counter
		btst	d6,lc_bits(a3)	;bitplane flag set?
		beq.s	drawline_a1	;no-get next

drawline_b5	btst	#6,DMACONR(a5)	;blitter ready?
		bne.s	drawline_b5

		move.l	a0,a1		;bitplane pointer
		add.l	d2,a1		;offset to 1st word of line
		move.w	d0,BLTAPTL(a5)	;2*DS-DL
		move.w	d1,BLTAMOD(a5)	;2*DS - 2*DL
		move.l	a1,BLTCPTH(a5)
		move.l	a1,BLTDPTH(a5)	;bitplane pointers proper
		move.w	d3,BLTBMOD(a5)	;2*DS
		move.l	#-1,BLTAFWM(a5)		;set masks
		move.w	#$8000,BLTADAT(a5)	;1 bit must be set

;		move.w	#40,BLTCMOD(a5)
;		move.w	#40,BLTDMOD(a5)

		move.w	line_smod(a4),BLTCMOD(a5)
		move.w	line_smod(a4),BLTDMOD(a5)	;bitplane moduli!

		move.l	d4,BLTCON0(a5)	;set blitter control regs!

		move.w	lc_pattern(a3),BLTBDAT(a5)	;line pattern

		move.w	d5,d6
		lsl.w	#6,d6
		addq.w	#2,d6		;BLTSIZE = 64*DL+2

		move.w	d6,BLTSIZE(a5)	;draw line

drawline_a1	add.w	line_ssize(a4),a0		;next bitplane pointer

		dbra	d7,drawline_l1

		move.l	lc_next(a3),d0	;check if more lines to do
		beq.s	drawline_b6	;none so exit
		move.l	d0,a3		;else set pointer
		bra	drawline_l0	;and do it

drawline_b6	rts


;draw_polygon(a4,a5)

;a4 = ptr to polygon structure definition block
;a5 = ptr to custom chip registers

;creates polygon using blitter line draw in SING mode into a buffer
;followed by blitter fill. Then transfers the whole lot to the screen
;at the desired polygon coordinates.

;d0-d7/a0-a3 corrupt


draw_polygon	move.l	poly_border(a4),a3
		move.l	line_coords(a3),a3	;get coord list
		move.l	a3,d0
		beq	draw_poly_done

		moveq	#0,d0		;potential x&y coord
		moveq	#0,d1		;maxima

draw_poly_l1	move.w	lc_x1(a3),d2
		move.w	lc_y1(a3),d3
		cmp.w	d2,d0
		bge.s	draw_poly_b1
		move.w	d2,d0		;new x maximum
draw_poly_b1	cmp.w	d3,d1
		bge.s	draw_poly_b2
		move.w	d3,d1		;new y maximum
draw_poly_b2	move.w	lc_x2(a3),d2
		move.w	lc_y2(a3),d3
		cmp.w	d2,d0
		bge.s	draw_poly_b3
		move.w	d2,d0		;new x maximum
draw_poly_b3	cmp.w	d3,d1
		bge.s	draw_poly_b4
		move.w	d3,d1		;new y maximum
draw_poly_b4	move.l	lc_next(a3),a3
		move.l	a3,d2
		bne.s	draw_poly_l1

		move.w	d0,d2
		lsr.w	#4,d0		;int(max_x/16) = word count
		and.w	#%1111,d2	;check fraction
		beq.s	draw_poly_b5
		addq.w	#1,d0		;1 word more

draw_poly_b5	move.w	d0,poly_wide(a4)	;WORD count!
		move.w	d1,poly_tall(a4)


;prepare to clear buffer in which polygon is to be drawn.
;Clear using blitter - it's most efficient!


		move.w	d1,d6
		lsl.w	#6,d6
		add.w	d0,d6		;this is BLTSIZE

		move.w	#$08F0,BLTCON0(a5)	;USED only
		clr.w	BLTCON1(a5)		;normal mode, no shift

		move.l	poly_buffer(a4),BLTDPTH(a5)	;ptr to buffer to clear

		clr.w	BLTDMOD(a5)	;D modulo zero
		clr.w	BLTADAT(a5)	;A data zero for clear
		moveq	#-1,d2
		move.l	d2,BLTAFWM(a5)	;ensure masks allow data passage
		move.w	d6,BLTSIZE(a5)	;and clear buffer!

		move.l	poly_border(a4),a3

		add.w	d0,d0		;WORD count to BYTE count
		move.w	d0,line_smod(a3)
		mulu	d0,d1		;size of buffer in bytes
		move.w	d1,line_ssize(a3)	;won't be a long really!

		move.l	poly_buffer(a4),d2
		move.l	d2,line_screen(a3)

		move.l	a4,-(sp)
		move.l	a3,a4		;point to line structure

		bsr	drawline		;& draw the lines

		move.l	(sp)+,a4		;recover pointer


;now activate blitter fill. Note : that works only if descending mode
;selected. This code does that. This is an exclusive fill enable type
;fill, with FCI initially zero (non-inverting fill).


draw_poly_b6	btst	#6,DMACONR(a5)	;wait till blitter done
		bne.s	draw_poly_b6

;		bra.s	dpdebug

		move.l	poly_buffer(a4),a0	;where border is
		move.w	poly_wide(a4),d1		;width in words
		move.w	d1,d2
		move.w	poly_tall(a4),d3
		mulu	d3,d1			;area size in words
		add.l	d1,d1			;area size in bytes
		add.l	d1,a0			;descending mode-adjust pointer
		subq.l	#2,a0			;point to last word of data proper!
		move.l	a0,BLTDPTH(a5)
		move.l	a0,BLTAPTH(a5)		;two pointers
		clr.w	BLTAMOD(a5)
		clr.w	BLTDMOD(a5)		;both moduli zero!
		moveq	#-1,d0
		move.l	d0,BLTAFWM(a5)		;ensure masks OK
		move.w	#$09f0,BLTCON0(a5)	;USEA/D, minterms $F0
;		move.w	#$0012,BLTCON1(a5)	;EFE on, FCI=0, DESC=1
		move.w	#$000A,BLTCON1(a5)	;IFE on, FCI=0, DESC=1
		move.w	d3,d0			;height
		lsl.w	#6,d0			;*64
		add.w	d2,d0			;add on width in words
		move.w	d0,BLTSIZE(a5)		;start blitter


;NB : when computing pointers for data blocks in above section,
;use subq.l #2,a0 to point to last words proper, instead of beyond
;the data blocks, otherwise the fill gets confused! Weird things
;happen if you don't do this!
		

;now transfer the complete polygon to the screen

dpdebug:
		move.l	poly_screen(a4),a0	;screen pointer
		move.l	poly_buffer(a4),a2	;ptr to polygon buffer
		moveq	#0,d0
		move.w	#BP_BYTES,d5		;no of bytes per screen bitplane

		move.w	poly_ypos(a4),d0
		mulu	poly_smod(a4),d0	;y coordinate * screen modulo
		add.l	d0,a0
		move.w	poly_xpos(a4),d0
		move.w	d0,d4		;save(x coordinate
		lsr.w	#4,d0		;2*int(x/16)
		add.w	d0,d0
		add.w	d0,a0		;now this is initial pointer

		move.w	poly_smod(a4),d2	;screen modulo
		move.w	poly_wide(a4),d3
		addq.w	#1,d3		;word cols + 1:Laurence trick
		add.w	d3,d3		;Part 2
		sub.w	d3,d2
		move.w	d2,d0		;C,D mods in d0
		swap	d0
		move.w	#-2,d0		;A,B mods also

		moveq	#-1,d1		;blitter mask values:Laurence
		clr.w	d1		;Trick Part 3

		move.w	d4,d2		;get x coordinate
		and.w	#%1111,d2	;frac(x/16)
		ror.w	#4,d2		;put in top 4 bits for BLTCONx
		move.w	d2,d3
		or.w	#$0FCA,d2	;USEA/B/C/D, minterms $CA
		swap	d2
		move.w	d3,d2		;create BLTCONx bits

		moveq	#0,d3
		move.w	poly_tall(a4),d3
		and.w	#$3FF,d3
		lsl.w	#6,d3
		move.w	poly_wide(a4),d6
		addq.w	#1,d6
		and.w	#$3f,d6
		add.w	d6,d3		;this is BLTSIZE!!

		move.l	a0,debug
		move.l	a2,debug+4
		move.l	d0,debug+8
		move.l	d1,debug+12
		move.l	d2,debug+16
		move.l	d5,debug+20
		move.l	d3,debug+24

		moveq	#3,d7		;no of bitplanes


;here transfer polygon to screen bitplanes according to colour
;specifier. a0 = ptr to screen location, d0 = moduli (C,D high
;word, A,B low word), d1 = blitter mask values, d2 = BLTCON0
;and BLTCON1 control words, d5 = size of 1 screen bitplane in
;bytes, d3 = BLTSIZE value pre-calculated (will stway the same
;size throughout the operation) and a2 = ptr to polygon buffer.
;So leave d0/d1/d2/d4/d5/a0/a2 alone while within the loop!.
;Freely alter d4/d6/a1/a3.


draw_poly_l2	swap	d7		;bitplane bit no
		move.w	d7,d6		;copy
		addq.w	#1,d7		;next bitplane no
		swap	d7		;back to counter
		btst	d6,poly_flag(a4)	;this bitplane?
		beq	draw_poly_b8

draw_poly_b7	btst	#6,DMACONR(a5)	;wait till blitter done
		bne.s	draw_poly_b7

		move.l	a0,BLTDPTH(a5)
		move.l	a0,BLTCPTH(a5)
		move.l	a2,BLTAPTH(a5)	;ptr to polygon buffer
		move.l	a2,BLTBPTH(a5)

		move.w	d0,BLTAMOD(a5)	;A,B  moduli -2:Laurence trick
		move.w	d0,BLTBMOD(a5)	;Part 1
		swap	d0		;get C,D moduli
		move.w	d0,BLTDMOD(a5)	;C,D moduli
		move.w	d0,BLTCMOD(a5)
		swap	d0		;recover A,B moduli again

		move.l	d1,BLTAFWM(a5)	;blitter masks (see above)
		move.l	d2,BLTCON0(a5)

		move.w	d3,BLTSIZE(a5)	;start blitter

draw_poly_b8	add.w	d5,a0		;next bitplane

		dbra	d7,draw_poly_l2	;continue
		
draw_poly_done	rts


;filled_rect(d0,d1,d2,a0)
;d0/d1 = width/height (words/raster lines)
;d2 = width of rectangle plot area
;a0 = rectangle plot area pointer

;only does 1 bitplane

;d3/d4 corrupt


filled_rect	move.w	#$01f0,BLTCON0(a5)	;minterms $F0, USED only enabled
		clr.w	BLTCON1(a5)		;normal mode
		move.l	a0,BLTDPTH(a5)		;plot area pointer
		moveq	#-1,d3
		move.w	d3,BLTADAT(a5)		;word to transfer (copied repeatedly by blitter)
		move.l	d3,BLTAFWM(a5)
		move.w	d2,d3			;plot area width
		move.w	d0,d4
		add.w	d4,d4			;rectange width in bytes
		sub.w	d4,d3
		move.w	d3,BLTDMOD(a5)		;plot area modulo
		move.w	d1,d3			;raster lines deep
		lsl.w	#6,d3			;*64
		add.w	d0,d3			;add on words across
		move.w	d3,BLTSIZE(a5)		;do it
		rts

debug		dc.l	0	;0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0	;16
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0	;32
		dc.l	0
		dc.l	0

;showd0(d0,d1,d2)
;d0 = value to show
;d1 = x pos
;d2 = y pos

showd0		lea	BPL_1(pc),a0
		mulu	#40,d2
		add.l	d2,a0
		add.w	d1,a0
			
		moveq	#8,d7
		bra.s	showd0_a

showd0_l		moveq	#0,d6
		rol.l	#4,d0
		move.b	d0,d6
		and.b	#%1111,d6
		lsl.w	#3,d6
		lea	chars(pc),a1
		add.w	d6,a1
		move.b	(a1)+,(a0)
		move.b	(a1)+,40(a0)
		move.b	(a1)+,80(a0)
		move.b	(a1)+,120(a0)
		move.b	(a1)+,160(a0)
		move.b	(a1)+,200(a0)
		move.b	(a1)+,240(a0)
		move.b	(a1)+,280(a0)
		addq.l	#1,a0

showd0_a		dbra	d7,showd0_l

		rts


;blitpic_i(a4) a4 = ptr to bob structure definition
;this version creates a queue of blitter service requests to
;be processed by an interrupt routine, for blitting a bob to
;a screen. Parameters taken from bob structure def.

;d0-d7/a0-a3 corrupt

;uses Laurence's trick for shifted blitting without extra space at
;right edge of bob image data : A,B modulo -2, use no of word cols + 1,
;and set BLTALWM to zero to scrub unwanted data.


blitpic_i	move.l	bob_screen(a4),a0		;screen pointer
		move.w	bob_ypos(a4),d0
		mulu	#40,d0
		add.l	d0,a0			;add on y*40
		move.w	bob_xpos(a4),d0
		lsr.w	#4,d0
		add.w	d0,d0
		add.w	d0,a0			;add on 2*int(x/16)

		move.l	bob_image(a4),a1		;ptr to bitplane data
		move.w	bob_cols(a4),d6
		mulu	bob_rows(a4),d6
		add.l	d6,d6			;size of 1 bitplane of image in BYTES!

		move.l	#BP_BYTES,a2		;size of 1 screen bitplane in bytes

		move.l	bob_mask(a4),a3

		move.l	a3,bob_bptr(a4)		;ptr to mask data

		move.w	#-2,d0
		move.w	d0,bob_amod(a4)		;modulo -2:part 1 of
		move.w	d0,bob_bmod(a4)		;Laurence's Trick

		move.w	bob_cols(a4),d0
		addq.w	#1,d0			;cols + 1:part 2 of
		add.w	d0,d0			;Laurence's Trick
		neg.w	d0
		add.w	#40,d0
		move.w	d0,bob_cmod(a4)		;C, D moduli equals
		move.w	d0,bob_dmod(a4)		;40-(cols width in bytes)

		moveq	#-1,d0
		clr.w	d0			;BLTALWM = 0 :Part 3 of
		move.l	d0,bob_fmsk(a4)		;Laurence's Trick

		moveq	#0,d0
		move.w	bob_xpos(a4),d0
		and.w	#%1111,d0		;frac(x/16)

		rol.w	#4,d0
		move.w	d0,d1
		or.w	#%1111,d0		;and in USEx bits!
		rol.w	#8,d0			;put in proper place
		or.b	bob_flag2(a4),d0		;put in minterm bits

		move.w	d0,bob_bcon0(a4)		;save BLTCON0 control word

		rol.w	#8,d1			;proper place
		move.w	d1,bob_bcon1(a4)

		move.w	bob_rows(a4),d0
		and.w	#$3ff,d0
		lsl.w	#6,d0
		move.w	bob_cols(a4),d1
		addq.w	#1,d1			;cols + 1 :part 2 of Laurence Trick
		and.w	#$3f,d1
		or.w	d1,d0
		move.w	d0,-(sp)

		moveq	#3,d7			;bitplane counter

;see similar piece of code in DRAWLINE routine for explanation of
;bitplane number management trick.

blitpic_i_l1	swap	d7			;get bitplane bit number
		move.w	d7,d0			;for test
		addq.w	#1,d7			;next bitplane
		swap	d7			;back to loop counter
		btst	d0,bob_flag1(a4)		;this image active?
		beq	blitpic_i_b2

blitpic_i_b1	btst	#6,DMACONR(a5)		;blitter done?
		bne.s	blitpic_i_b1		;no, wait for it

		move.l	a0,bob_cptr(a4)		;bgnd and destination
		move.l	a0,bob_dptr(a4)		;bitplane pointers
		move.l	a1,bob_aptr(a4)		;ptr to image data

		movem.l	bob_bcon0(a4),d0-d5
		movem.l	d0-d5,BLTCON0(a5)

		movem.w	bob_cmod(a4),d0-d3
		movem.w	d0-d3,BLTCMOD(a5)

		move.w	(sp),BLTSIZE(a5)

blitpic_i_b2	add.l	a2,a0			;next bgnd/dest bitplane
		add.l	d6,a1			;next image bitplane

		dbra	d7,blitpic_i_l1
		move.w	(sp)+,d6

		rts



vars		ds.b	sizeof_vars
		even


copper_list	ds.l	64


chars		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00001000
		dc.b	%00011000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00000100
		dc.b	%00001000
		dc.b	%00010000
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00001100
		dc.b	%00001100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00001000
		dc.b	%00011000
		dc.b	%00101000
		dc.b	%01111100
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01111100
		dc.b	%00000010
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000000
		dc.b	%01111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%00000010
		dc.b	%00000100
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00111110
		dc.b	%00000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01111110
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111000
		dc.b	%01000100
		dc.b	%01111100
		dc.b	%01000100
		dc.b	%01000010
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01110000
		dc.b	%01110000
		dc.b	%01000000
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01110000
		dc.b	%01110000
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%00000000




palette		dc.w	$000,$FFF,$F00,$0F0
		dc.w	$00F,$F0F,$FF0,$0FF
		dc.w	$333,$555,$777,$999
		dc.w	$BBB,$707,$770,$077

* octant selection table

old_octants	dc.b	4*4+1
		dc.b	0*4+1
		dc.b	6*4+1
		dc.b	1*4+1
		dc.b	5*4+1
		dc.b	2*4+1
		dc.b	7*4+1
		dc.b	3*4+1

octants		dc.b	4*4+1
		dc.b	0*4+1
		dc.b	6*4+1
		dc.b	1*4+1
		dc.b	5*4+1
		dc.b	2*4+1
		dc.b	7*4+1
		dc.b	3*4+1

		even


test_line	dc.l	0		;screen ptr
		dc.w	0		;size of 1 bitplane in bytes
		dc.w	40		;screen modulo
		dc.l	line1

		dc.w	0,0,0		;workspace for drawline()
		dc.b	0,0


;coord list for above line definition structure


line1		dc.l	line2
		dc.w	160,128
		dc.w	160+70,128+30
		dc.w	$FFFF
		dc.b	$00+1,0

line2		dc.l	line3
		dc.w	160,128
		dc.w	160+70,128-30
		dc.w	$FFFF
		dc.b	$00+2,0

line3		dc.l	line4
		dc.w	160,128
		dc.w	160+30,128+70
		dc.w	$FFFF
		dc.b	$00+3,0

line4		dc.l	line5
		dc.w	160,128
		dc.w	160+30,128-70
		dc.w	$FFFF
		dc.b	$00+4,0

line5		dc.l	line6
		dc.w	160,128
		dc.w	160-70,128+30
		dc.w	$FFFF
		dc.b	$00+5,0

line6		dc.l	line7
		dc.w	160,128
		dc.w	160-70,128-30
		dc.w	$FFFF
		dc.b	$00+6,0

line7		dc.l	line8
		dc.w	160,128
		dc.w	160-30,128+70
		dc.w	$FFFF
		dc.b	$00+7,0

line8		dc.l	0
		dc.w	160,128
		dc.w	160-30,128-70
		dc.w	$FFFF
		dc.b	$00+14,0

		even


test_poly	dc.l	0		;screen pointer
		dc.w	0		;screen size
		dc.w	40		;screen modulo

		dc.l	0		;buffer
		dc.w	0,0		;buffer width, height

		dc.l	poly_ldef	;ptr to line definition structure

		dc.w	12,30		;x & y coords
		dc.b	15,0		;colours, pad


poly_ldef	dc.l	0		;'screen' ptr
		dc.w	0		;size of 1 'bitplane' in bytes
		dc.w	40		;'screen' modulo
		dc.l	poly_1

		dc.w	0,0,0		;workspace for drawline()
		dc.b	0,0

;below are coords for a triangle boundary

poly_1		dc.l	poly_2
		dc.w	0,0		;start & end coords
		dc.w	60,40
		dc.w	$FFFF		;draw mask
		dc.b	$10+1,0		;SING bit set, 1 bitplane

poly_2		dc.l	poly_3
		dc.w	60,40
		dc.w	40,80
		dc.w	$FFFF
		dc.b	$10+1,0

poly_3		dc.l	0
		dc.w	40,80
		dc.w	0,0
		dc.w	$FFFF
		dc.b	$10+1,0


		even



testbob		dc.l	testimage
		dc.l	0		;set to screen beforehand
		dc.l	testbgnd		;set to bgnd save area
		dc.l	testmask

		dc.w	8		;8 rows
		dc.w	2		;2 cols (words!)
		dc.w	32,128		;init x,y position
		dc.w	0,0		;deltax/deltay

		dc.b	%00001111,$CA	;flags

		ds.w	4
		ds.l	4
		ds.w	4

testimage	dc.w	%0000000011111111,%1111100000000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000001111111111,%1111101100000000
		dc.w	%0000011111111111,%1111111100000000
		dc.w	%0000011111111111,%1111111100000000
		dc.w	%0000001111111111,%1111101100000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000000011111111,%1111100000000000

		dc.w	%0000000011111111,%1111100000000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000001111111001,%1111101100000000
		dc.w	%0000011111110000,%1111111100000000
		dc.w	%0000011111110000,%1111111100000000
		dc.w	%0000001111111001,%1111101100000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000000011111111,%1111100000000000

		dc.w	%0000000011111111,%1111100000000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000001111111001,%1111101100000000
		dc.w	%0000011111110000,%1111111100000000
		dc.w	%0000011111110000,%1111111100000000
		dc.w	%0000001111111001,%1111101100000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000000011111111,%1111100000000000

		dc.w	%0000000011111111,%1111100000000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000001111111111,%1111101100000000
		dc.w	%0000011111111111,%1111111100000000
		dc.w	%0000011111111111,%1111111100000000
		dc.w	%0000001111111111,%1111101100000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000000011111111,%1111100000000000




testmask		dc.w	%0000000011111111,%1111100000000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000001111111111,%1111101100000000
		dc.w	%0000011111111111,%1111111100000000
		dc.w	%0000011111111111,%1111111100000000
		dc.w	%0000001111111111,%1111101100000000
		dc.w	%0000000111111111,%1111100100000000
		dc.w	%0000000011111111,%1111100000000000

testbgnd		dc.w	8*2




BPL_1		ds.b	BP_BYTES
		even

BPL_2		ds.b	BP_BYTES
		even

BPL_3		ds.b	BP_BYTES
		even

BPL_4		ds.b	BP_BYTES
		even

spare_mem	ds.l	256



