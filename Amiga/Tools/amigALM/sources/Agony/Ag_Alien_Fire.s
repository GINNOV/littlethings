
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                          ALIEN FIRE  MODULE                             *
*                          ------------------                             *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Artwork:        Franck Sauer
*	Marc Albinet

* Coding:	Yves Grolet
* Date:	25/06/1990
* Tab:            custom




***************************************************************************






	cmp	#2,Curent_Spell(D)
	beq     AFCT_End
	cmp	#5,Curent_Spell(D)
	beq     AFCT_End
                  tst	Pause(D)
	bne	AFCT_End
                  tst	Pause2(D)
	bne	AFCT_End
	tst	Die(D)
	bne	AFCT_End
	tst	Icones_Mode(D)
	bne	AFCT_End



* LAUNCH ALIEN FIRE
* -----------------


                  tst	Short_Phase(D)
	beq     LAF_Bank_End

	lea     AWO_Struct(D),a0	* a0 AWO Dyn Ptr
	lea	AF_Struct,a1
LAF_Bank_Loop
	move	(a0)+,d0	* d0 Curent Alien Num
                  beq	LAF_Bank_Ignored
	cmp	#-1,d0
	bne	LAF_Bank_Tested
LAF_Bank_Ignored
	lea	16*AWO_Len+2(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	bge     LAF_Bank_End
	bra	LAF_Bank_Loop
LAF_Bank_Tested
	move	(a0)+,d1
	move.l	a0,Curent_Bank_Ptr(D)
	add	d1,a0
	subq	#1,d0
.obj_loop
	move.b	AWO_Alien_Status(a0),d1
	and	#$f,d1
	bne	.obj_end
	addq.b	#1,AWO_Alien_F_Rt_D(a0)
	move.b	AWO_Alien_F_Rt_D(a0),d1
	cmp.b	AWO_Alien_F_Rt_S(a0),d1
	bne	.obj_end
	clr.b	AWO_Alien_F_Rt_D(a0)
	lea	-AF_Len(a1),a2	* PLACE NEW ALIEN FIRE
.search
	lea	AF_Len(a2),a2
	cmp	#-1,(a2)
	bne	.search
	move	AWO_Alien_Obj_Off(a0),a3
	add.l	#Objects_Struct+2,a3
	move.b	(a3)+,d1
	move.b	(a3),d2
	ext	d1
	ext	d2
	add	AWO_Alien_X(a0),d1
	add	AWO_Alien_Y(a0),d2
	move	d1,AF_X(a2)
	move	d2,AF_Y(a2)
			* i= Dx/(Dy*3)
	clr.b	AF_Y_Count_Dyn(a2)
	sub	Sorcerer_X(D),d1
	bpl	.fire
.no_fire
	moveq	#-1,d1
	move.l	d1,AF_X(a2)
	bra	.obj_end
.fire
	cmp	#64,d1
	ble	.no_fire
	sub	Sorcerer_Y(D),d2
                  sub	#45,d2
	bpl	.pos
	neg	d2
	moveq	#0,d4	* no neg
	bra	.cont
.pos
	moveq	#1,d4	* to neg
.cont
	tst	d2
	beq	.flat
	move	d2,d3
	add	d2,d2
	add	d3,d2
	ext.l	d1
	divu	d2,d1
	bne	.ok
	moveq	#1,d1
.ok
	cmp	#255,d1
	bgt     .flat
	tst	d4
	beq	.no_neg
	neg	d1
.no_neg
	move.b	d1,AF_Y_Count_Stat(a2)
	bra     .obj_end
.flat
	clr.b	AF_Y_Count_Stat(a2)
.obj_end
	lea     AWO_Len(a0),a0
	dbra    d0,.obj_loop

	move.l  Curent_Bank_Ptr(D),a0
	lea	16*AWO_Len(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	beq     LAF_Bank_End
                  bra     LAF_Bank_Loop
LAF_Bank_End



* DISPLAY ALIEN FIRE
* ------------------


	lea	AF_Struct,a0	* Compute new coord
                  moveq	#31,d0
Af_loop
	tst	AF_X(a0)
	bmi	.no

	cmp	#2,Curent_Spell(D)
	beq     .no2
	subq	#3,AF_X(a0)
	addq.b	#1,AF_Y_Count_Dyn(a0)
.no2
	moveq	#1,d2
	move.b	AF_Y_Count_Stat(a0),d1
	ext	d1
	bpl	.ok
	neg	d1
	moveq	#-1,d2
.ok
	cmp.b	AF_Y_Count_Dyn(a0),d1
	bne	.no_y
	clr.b	AF_Y_Count_Dyn(a0)
	cmp	#2,Curent_Spell(D)
	beq     .no_y
	add	d2,AF_Y(a0)
.no_y
	move	AF_X(a0),d1
	cmp	#250,d1
	ble	.off
	cmp	#256+272,d1
	bge	.off
	move	AF_Y(a0),d2
	cmp	#256,d2
	ble	.off
	cmp	#256+192,d2
	bge	.off
	bra	.no
.off
	move.l	#-1,(a0)
                  clr.l	4(a0)
.no
	lea	AF_Len(a0),a0
	dbra	d0,Af_loop

N	=	200                 * Byte_Sort
N_	=       32

	lea	BS_Count(D),a0
	move.l	a0,a1
	moveq	#49,d0
Sort_Clr_Loop
	clr.l	(a0)+
	dbra	d0,Sort_Clr_Loop
	lea	AF_Struct,a0	* Pass 1
	moveq	#N_-1,d0
Sort_P1_Loop
	tst     AF_X(a0)
	bmi	.no
	move	AF_Y(a0),d1
	sub	#252,d1
	addq.b	#1,(a1,d1.w)
.no
	lea     AF_Len(a0),a0
	dbra	d0,Sort_P1_Loop
			* Pass 2
	lea	BS_Offset+1(D),a0
	moveq	#0,d1
	move	d1,BS_Offset(D)
	move	#N,d0
Sort_P2_Loop
	add.b	(a1)+,d1
	move.b	d1,(a0)+
	dbra	d0,Sort_P2_Loop
			* Pass 3
	lea	BS_Order(D),a0
	moveq	#-1,d1
	moveq	#7,d0
Sort_Clr2_loop
	move.l	d1,(a0)+
	dbra	d0,Sort_Clr2_loop
	lea	BS_Offset(D),a0
	lea	BS_Order(D),a1
	lea	AF_Struct,a2
	moveq	#0,d2
	moveq	#0,d3
	moveq	#N_-1,d0
Sort_P3_Loop
	tst	AF_X(a2)
	bmi	.no
	move	AF_Y(a2),d1
	sub	#252,d1
	move.b	(a0,d1),d2
	addq.b	#1,(a0,d1)
	move.b	d3,(a1,d2)
.no
	addq.b	#1,d3
	lea     AF_Len(a2),a2
	dbra	d0,Sort_P3_Loop
			* Compute Closer Situation
	lea	BS_Order(D),a0
	lea	AF_Struct,a1
	moveq	#0,d0
Ccs_Loop
	addq	#1,d0
                  cmp	#32,d0
	bge	Ccs_End
	moveq	#0,d1
	move.b	(a0)+,d1
	bmi	Ccs_Loop
	lsl	#3,d1               * d1=d1*AF_Len
	move	AF_Y(a1,d1.w),d2
                  move	#$0100,AF_Closer_Num(a1,d1.w)
	moveq	#0,d5
	move.l	a0,a2
.searsh_loop
	moveq	#0,d3
	move.b	(a0),d3
	bpl	.ok
	addq	#1,a0
	addq	#1,d0
	cmp	#31,d0
	bge	.searsh_end
	bra     .searsh_loop
.ok
                  lsl	#3,d3	* d3=d3*AF_Len
	move	AF_Y(a1,d3.w),d4
	sub	d2,d4
	cmp	#10,d4
	ble     .closer
.searsh_end
	move.b	AF_Closer_Num(a1,d1.w),d4
	subq	#1,d5
	bmi	Ccs_Loop
.fill_loop
	moveq	#0,d3
	move.b  (a2)+,d3
                  lsl	#3,d3	* d3=d3*AF_Len
	move.b	d4,AF_Closer_Num(a1,d3.w)
	dbra	d5,.fill_loop
	bra	Ccs_Loop
.closer
                  addq	#1,a0
	addq.b	#1,AF_Closer_Num(a1,d1.w)
	addq	#1,d5
	move.b	d5,AF_Closer_Offset(a1,d3.w)
	addq	#1,d0
	cmp	#31,d0
	bge	.searsh_end
	bra	.searsh_loop
Ccs_End			* Refresh AF LFOs

	lea	AF_Lfo(D),a0
	moveq	#2,d0
AF_Lfo_Loop
	addq	#1,(a0)
	cmp     (a0)+,d0
	bne	.ok
	clr	-2(a0)
.ok
                  addq	#1,d0
	cmp	#10,d0
	bne	AF_Lfo_Loop
			* Refresh Y sprites datas
	lea	AF_Struct,a0
	lea	BS_Order(D),a1
	lea	Alien_Fire_Spr,a2
	lea     AF_Lfo(D),a3
	move.l	a2,Spr5ptB(D)
	moveq	#31,d0
Rsd_Loop
	moveq	#0,d1
	move.b	(a1)+,d1
	bmi	.end
	lsl	#3,d1
	moveq	#0,d2
	move.b	AF_Closer_Num(a0,d1.w),d2
	cmp	#1,d2
	beq	.no2
	move	d2,d3
	subq	#2,d2
	subq	#1,d3
	add	d2,d2
	move	(a3,d2.w),d2
	moveq	#0,d4
	move.b	AF_Closer_Offset(a0,d1.w),d4
	add	d4,d2
	cmp	d2,d3
	bne	.end
.no2
	move	AF_X(a0,d1.w),d2
	sub	#256-$90,d2
	move	AF_Y(a0,d1.w),d3	* d3 y1
	sub	#256-SPR_Y_OFF,d3
	lsl	#8,d3
	move	d3,d4
	add	#$800,d4	* d4 y2
	btst	#0,d2
	beq	.no
    	or	#1,d4
.no
	lsr	#1,d2
	or	d2,d3
	move	d3,(a2)+
	move	d4,(a2)+
	lea	32(a2),a2
.end
	dbra	d0,Rsd_Loop
	clr.l	(a2)
No_Af



* ALIEN FIRE COLISION TEST
* ------------------------



                  tst	Short_Phase(D)
	beq     AFCT_End
	tst	Sorcerer_On(D)
	beq	AFCT_End

	lea	Good_Col_List(D),a1
	move	(a1)+,d2	* d2 x1
	move	(a1)+,d3            * d3 y1
	move	(a1)+,d4            * d4 x2
	move	(a1),d5             * d5 y2

	moveq	#8,d0
	moveq	#31,d1
	lea	AF_Struct,a1
.loop
                  move	AF_X(a1),d6	* d6 x1'
                  bmi	.no_col
	cmp	d6,d4
	blt	.no_col
                  move	AF_Y(a1),d7	* d7 y1'
	cmp	d7,d5
	blt	.no_col
	add	d0,d6	* d6 x2'
	cmp	d2,d6
	blt	.no_col
	addq	#7,d7	* d7 y2'
	cmp	d3,d7
	blt	.no_col
			* COLISION FOUND
	tst	Die(D)
	bne	.no_col
                  st	Die(D)
	clr	Die_Mode(D)
.no_col
	lea     AF_Len(a1),a1
	dbra	d1,.loop
AFCT_End



* TURN OFF ALL ALIEN FIRE
* -----------------------


	tst	AF_Off(D)
	beq     No_AF_Off

	clr	AF_Off(D)
	moveq	#-1,d1
                  lea	AF_Struct,a0
	moveq	#31,d0
.Af_Loop
	move.l	d1,(a0)
	lea	AF_Len(a0),a0
	dbra	d0,.Af_Loop
	move.l	#_Empty_Spr,Spr5ptB(D)
	clr.l	Alien_Fire_Spr
No_AF_Off


