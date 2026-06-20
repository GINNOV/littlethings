


		opt	d+


* Fast fill test #2.


		lea	TestPoly(pc),a0
		moveq	#8,d0
		swap	d0
		move.w	#8,d0
		bsr	Fill
		rts


* Fill(a0,d0)
* a0 = ptr to memory area containing polygon outline
* d0 = width & height: d0{31:16}=width, d0{15:0}=height
* NOTE:width is in WORDS!!!

* Perform a fast fill of the polygon outline.

* d0-d6/a0-a3 corrupt


Fill		moveq	#-1,d1		;filler value

		lea	FillTables(pc),a2	;ptr to fill tables

Fill_L1		swap	d0		;get width
		move.l	a0,a1		;copy raster line ptr
		add.w	d0,a1
		add.w	d0,a1		;point to next line
		move.l	a1,d2		;and save ptr
		swap	d0		;recover height


* Now, get left hand side (LHS) outline. If we don't find one then
* move on to next raster line of polygon.


Fill_1		move.b	(a0),d3		;get polygon byte
		move.w	(a0),d4		;and word
		bne.s	Fill_2		;skip if hit outline
		addq.l	#2,a0		;else point to next
		cmp.l	a1,a0		;blank raster line?
		bcs.s	Fill_1		;back for more if not
		bra.s	Fill_10		;else do next raster line

Fill_2		move.l	a2,a3		;copy fill table ptr
		tst.b	d3		;outline in upper byte?
		beq.s	Fill_3		;skip if not


* Here outline bits are present in the upper byte. Use it as
* index into the LHS upper table & extract fill word.


		moveq	#0,d4		;clear word index
		move.b	d3,d4		;get index value
		add.w	d4,d4		;word scale index
		move.w	0(a3,d4.w),d5	;get fill word
		bra.s	Fill_4		;and continue


* Here outline bits in lower byte only. Use entire word as
* index into LHS lower byte table, extract fill word.


Fill_3		add.w	d4,d4		;word scale index
		add.w	#512,a3		;point to LHS lower table
		move.w	0(a3,d4.w),d5	;get fill word


* Here repeat the procedure for the right hand side (RHS) outline.


Fill_4		move.l	a2,a3		;copy table ptr again

Fill_5		move.w	-(a1),d4		;get RHS boundary
		beq.s	Fill_5		;fetch new word if not found
		move.b	(a1),d3		;get upper byte also


* Now check which byte contains the rightmost boundary bits.


		tst.b	d4		;outline in lower byte?
		bne.s	Fill_6		;skip if so


* Here outline bits in upper byte only. Use as index into
* RHS upper byte table & extract fill word.


		moveq	#0,d4		;clear index
		move.b	d3,d4		;create it
		add.w	d4,d4		;word scale it
		add.w	#1024,a3		;point to correct table
		move.w	0(a3,d4.w),d6	;get fill word
		bra.s	Fill_7		;and continue


* Here outline bits are in lower byte also. Use as index into
* RHS lower byte table & extract fill word.


Fill_6		add.w	#1536,a3		;point to correct table
		moveq	#0,d3		;clear index
		move.b	d4,d3		;create it
		add.w	d3,d3		;word scale it
		move.w	0(a3,d3.w),d6	;get fill word


* Here see if LHS and RHS fill words at same address. If so,
* create combination fill word & exit.


Fill_7		cmp.l	a1,a0		;LHS ptr = RHS ptr?
		bne.s	Fill_8		;skip if not

		and.w	d5,d6		;create combination fill word
		move.w	d6,(a0)		;fill it
		bra.s	Fill_10		;and continue


* Here, fill words in different regions of the polygon. So fill LHS
* & RHS ends, then fill any blank space remaining.


Fill_8		move.w	d6,(a1)		;fill RHS extremity
		move.w	d5,(a0)+		;now do LHS extremity

		cmp.l	a1,a0		;LHS ptr = RHS ptr?
		beq.s	Fill_10		;exit if so

Fill_9		move.w	d1,(a0)+		;fill blank space
		cmp.l	a1,a0		;done all blank space?
		bcs.s	Fill_9		;back for more if not

Fill_10		move.l	d2,a0		;point to next raster line

		subq.w	#1,d0		;done all raster lines?
		bne.s	Fill_L1		;back for more if not

		rts			;done!!!


* Fill tables. These are four tables of 256 words each, following
* consecutively.

* Table 1 = LHS upper byte fill words
* Table 2 = LHS lower byte fill words
* Table 3 = RHS upper byte fill words
* Table 4 = RHS lower byte fill words


* Table 1 LHS


FillTables	dc.w	$00FF,$01FF,$03FF,$03FF	;0
		dc.w	$07FF,$07FF,$07FF,$07FF
		dc.w	$0FFF,$0FFF,$0FFF,$0FFF
		dc.w	$0FFF,$0FFF,$0FFF,$0FFF
		dc.w	$1FFF,$1FFF,$1FFF,$1FFF
		dc.w	$1FFF,$1FFF,$1FFF,$1FFF
		dc.w	$1FFF,$1FFF,$1FFF,$1FFF
		dc.w	$1FFF,$1FFF,$1FFF,$1FFF

		dc.w	$3FFF,$3FFF,$3FFF,$3FFF	;32
		dc.w	$3FFF,$3FFF,$3FFF,$3FFF
		dc.w	$3FFF,$3FFF,$3FFF,$3FFF
		dc.w	$3FFF,$3FFF,$3FFF,$3FFF
		dc.w	$3FFF,$3FFF,$3FFF,$3FFF
		dc.w	$3FFF,$3FFF,$3FFF,$3FFF
		dc.w	$3FFF,$3FFF,$3FFF,$3FFF
		dc.w	$3FFF,$3FFF,$3FFF,$3FFF

		dc.w	$7FFF,$7FFF,$7FFF,$7FFF	;64
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF

		dc.w	$7FFF,$7FFF,$7FFF,$7FFF	;96
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$7FFF,$7FFF

		dc.w	$FFFF,$FFFF,$FFFF,$FFFF	;128
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF

		dc.w	$FFFF,$FFFF,$FFFF,$FFFF	;160
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF

		dc.w	$FFFF,$FFFF,$FFFF,$FFFF	;192
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF

		dc.w	$FFFF,$FFFF,$FFFF,$FFFF	;224
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF


* Table 2 LHS


		dc.w	$0000,$0001,$0003,$0003	;0
		dc.w	$0007,$0007,$0007,$0007
		dc.w	$000F,$000F,$000F,$000F
		dc.w	$000F,$000F,$000F,$000F
		dc.w	$001F,$001F,$001F,$001F
		dc.w	$001F,$001F,$001F,$001F
		dc.w	$001F,$001F,$001F,$001F
		dc.w	$001F,$001F,$001F,$001F

		dc.w	$003F,$003F,$003F,$003F	;32
		dc.w	$003F,$003F,$003F,$003F
		dc.w	$003F,$003F,$003F,$003F
		dc.w	$003F,$003F,$003F,$003F
		dc.w	$003F,$003F,$003F,$003F
		dc.w	$003F,$003F,$003F,$003F
		dc.w	$003F,$003F,$003F,$003F
		dc.w	$003F,$003F,$003F,$003F

		dc.w	$007F,$007F,$007F,$007F	;64
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F

		dc.w	$007F,$007F,$007F,$007F	;96
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F
		dc.w	$007F,$007F,$007F,$007F

		dc.w	$00FF,$00FF,$00FF,$00FF	;128
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF

		dc.w	$00FF,$00FF,$00FF,$00FF	;160
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF

		dc.w	$00FF,$00FF,$00FF,$00FF	;192
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF

		dc.w	$00FF,$00FF,$00FF,$00FF	;224
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF
		dc.w	$00FF,$00FF,$00FF,$00FF


* Table 3 RHS


		dc.w	$0000,$FF00,$FE00,$FF00	;0
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00

		dc.w	$E000,$FF00,$FE00,$FF00	;32
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00

		dc.w	$C000,$FF00,$FE00,$FF00	;64
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00

		dc.w	$F800,$FF00,$FE00,$FF00	;96
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00

		dc.w	$8000,$FF00,$FE00,$FF00	;128
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00

		dc.w	$E000,$FF00,$FE00,$FF00	;160
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00

		dc.w	$C000,$FF00,$FE00,$FF00	;192
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00

		dc.w	$E000,$FF00,$FE00,$FF00	;224
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F000,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00
		dc.w	$F800,$FF00,$FE00,$FF00
		dc.w	$FC00,$FF00,$FE00,$FF00


* Table 4 RHS


		dc.w	$FF00,$FFFF,$FFFE,$FFFF	;0
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF

		dc.w	$FFE0,$FFFF,$FFFE,$FFFF	;32
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF

		dc.w	$FFC0,$FFFF,$FFFE,$FFFF	;64
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF

		dc.w	$FFF8,$FFFF,$FFFE,$FFFF	;96
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF

		dc.w	$FF80,$FFFF,$FFFE,$FFFF	;128
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF

		dc.w	$FFE0,$FFFF,$FFFE,$FFFF	;160
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF

		dc.w	$FFC0,$FFFF,$FFFE,$FFFF	;192
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF

		dc.w	$FFE0,$FFFF,$FFFE,$FFFF	;224
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF0,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF
		dc.w	$FFF8,$FFFF,$FFFE,$FFFF
		dc.w	$FFFC,$FFFF,$FFFE,$FFFF


* Test Polygon


TestPoly		dc.w	$0000,$0000,$0000,$3C00,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$40C0,$0000,$0000,$0000,$0000
		dc.w	$0000,$0FFF,$FFFF,$8030,$0000,$0000,$0000,$0000
		dc.w	$0000,$0800,$0000,$000F,$FFFF,$FFFF,$FF00,$0000
		dc.w	$0000,$0800,$0000,$0000,$0000,$0000,$0200,$0000
		dc.w	$0000,$0400,$0000,$0000,$0000,$0000,$0400,$0000
		dc.w	$0000,$0200,$0000,$0000,$0000,$0000,$0800,$0000
		dc.w	$0000,$01FF,$FFFF,$FFFF,$FFFF,$FFFF,$F000,$0000






