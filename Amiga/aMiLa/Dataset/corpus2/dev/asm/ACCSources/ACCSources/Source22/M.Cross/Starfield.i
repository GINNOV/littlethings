
* -------------	Sprite star field subroutine ©1992 M J Cross ----------	*

* -------------	Uses about 5-6 lines of raster time -------------------	*


*		Equates

NumberOfStars	equ	58
Max_Speed	equ	4



*		Initialise (2 routines)

LoadSprites	move.l	#StarSprite,d0
		lea	Sprites,a0
		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)
		rts


MakeStars	lea	StarSprite,a0
		moveq.l	#NumberOfStars-1,d7
		moveq.l	#$20,d0			* Start Y position
		moveq.l	#1,d1
		moveq.l	#0,d2
		move.w	#$321f,d3
		move.w	#$5512,d5
MakeLoop	move.w	vhposr(a5),d4		* Random No. from beam pos'
		or.w	d3,d5
		add.w	d4,d5
		move.b	d0,(a0)+
		move.b	d5,(a0)+		* Random X Position
		addq.l	#1,d0
		move.b	d0,(a0)+		* Second control word
		move.b	d2,(a0)+
		move.w	d1,(a0)+		* Gfx Data
		move.w	#1,(a0)+
		eori.w	#1,d1			* Every second one grey
		addq.b	#3,d0			* Vertical gap
		cmpi.w	#238,d0			* Bottom reached?			
		ble	Okay	
		moveq.l	#0,d0			* Yes - start in Pal bit
		move.w	#6,d2	
Okay		dbf	d7,MakeLoop
		rts


*		IRQ routine (place in the vertical blank loop)

MoveStar	lea	StarSprite,a0
		moveq.l	#NumberOfStars-1,d0	
		moveq.b	#2,d1			* Speed counter	
StarLoop	sub.b	d1,1(a0)
		addq.l	#8,a0
		addq.b	#1,d1
		cmpi.b	#Max_Speed,d1
		ble	SpeedOkay
		moveq.b	#2,d1	
SpeedOkay	dbf	d0,StarLoop
		rts



*		Variables

StarSprite	dcb.w	4*NumberOfStars,0
