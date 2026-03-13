
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                             GAME MODULE                                 *
*                             -----------                                 *
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



	tst	Pause2(D)
	bne	Play_End

	cmp	#2,Curent_Spell(D)
	beq     No_Pal_Update

	tst	Begin_To_Start(D)
	bne     No_Pal_Update

	tst	Clean_Up(D)
	bne	No_New_Sl_Instr



* INERPRET START LIST
* -------------------


	addq	#2,Level_X(D)

                  tst	Short_Phase(D)
	beq	No_New_Sl_Instr

                  move	Level_X(D),d0
	cmp	Sl_Waiting(D),d0
	blt	No_New_Sl_Instr

                  move.l	Start_list_Ptr(D),a0
	move.l  (a0)+,d0
	bmi	Routine_Start
	btst	#30,d0	* TRACK START
	beq	Relative_Start	* -----------
	move	(a0)+,d1
	move	(a0)+,d2
Relative_Start
	st	Refresh_Pal+1(D)
	lea	Track_Table-4(D),a1
.track_loop
	lea	4(a1),a1
	btst	#7,(a1)
	beq	.track_loop
                  bclr	#7,(a1)
	move.l	(a1),a1
	move.l	d0,TS_Aws_Ptr(a1)
	clr	TS_Alien_Num(a1)
	clr.b	TS_First_Alien(a1)
	move	d1,TS_X_Start(a1)
	move	d2,TS_Y_Start(a1)
	lea	AWO_Struct-AWO_size(D),a2
	move.l	d0,a3
.awo_loop
	lea	AWO_size(a2),a2
	tst	(a2)
	bpl	.awo_loop
	clr.l	(a2)
	move.l	a2,TS_Awo_Ptr(a1)

	move	AWS_Alien_Energy(a3),d1
	moveq	#0,d2
	move.b	AWS_Alien_F_Rate(a3),d3
	moveq	#15,d0
	addq	#4,a2
.init_loop
	move	d1,AWO_Alien_Energy(a2)
	clr.b	AWO_Alien_Status(a2)

	addq.b	#1,d2
	cmp.b	d2,d3
	bne	.no
	move.b	AWS_Alien_Bad_F(a3),AWO_Alien_F_Rt_S(a2)
	moveq	#0,d2
	bra	.cont
.no
	st      AWO_Alien_F_Rt_S(a2)
.cont
	clr.b	AWO_Alien_F_Rt_D(a2)

	lea	AWO_Len(a2),a2
	dbra	d0,.init_loop
	bra     SL_Ctrl
			* ROUTINE START
Routine_Start			* -------------
	lea	Rout_Struct-Rout_Len(D),a1
Rout_Loop
	lea	Rout_Len(a1),a1
	tst.l   (a1)
	bpl	Rout_Loop
                  bclr	#31,d0
	move.l	d0,Rout_Code_Ptr(a1)
	move.l	a0,Rout_Param_Ptr(a1)
	lea	AWO_Struct-AWO_size(D),a2
.awo_loop
	lea	AWO_size(a2),a2
	tst	(a2)
	bpl	.awo_loop
	move.l	a2,Rout_Awo_Ptr(a1)
	clr.l	(a2)+
	clr.l	Rout_Variables(a1)
	clr.l	Rout_Variables+4(a1)
	clr.l	Rout_Variables+8(a1)
	clr.l	Rout_Variables+12(a1)
.par_loop
                  cmp	#-1,(a0)+
	bne	.par_loop
SL_Ctrl
	move	(a0)+,Sl_Waiting(D)
	move.l	a0,Start_List_Ptr(D)
No_New_Sl_Instr



* TRACK FOLOWER
* -------------


	moveq	#15,d7
	move.l	#_Track_Table,d6
Tracks_Loop
	move.l	d6,a0
	addq.l	#4,d6
	move.l	(a0),d0		* A1 Ptr on TS
                  bmi     Track_End

	move.l	d0,a1 	* R E L A T I V E   T R A C K S
			* -----------------------------
                  move.l	TS_Aws_Ptr(a1),d0		* A3 Ptr on AWS

                  btst	#30,d0
	bne	Abs_Track

	move.l	d0,a3
	move	TS_Alien_Num(a1),d0		* d0 Alien num
	beq	New_Alien

                  lea	TS_Aliens(a1),a2		* A2 Ptr on 32 Aliens
	moveq	#0,d1
	move.b	TS_First_Alien(a1),d1
	add	d1,a2
	move	d0,d1
	subq	#1,d1
.loop
	add.l	#$00010002,(a2)+	* INC POS OF EATCH ALIEN IN TS
	move	-4(a2),d3		* d3 pos in track of LAST Alien
	dbra	d1,.loop
	cmp.b	AWS_Alien_Rate(a3),d3	* Tst alien rate
	bne	No_New
New_Alien			* ADD AN ALIEN
	cmp.b	AWS_Alien_Num(a3),d0
	beq	No_New
                  tst.b	TS_First_Alien(a1)
	bne	No_New
                  addq	#1,TS_Alien_Num(a1)
	move	d0,d1
	addq	#1,d0
	add	d1,d1
	add	d1,d1
                  lea	TS_Aliens(a1),a2		* A2 Ptr on 32 Aliens
                  clr.l	(a2,d1.w)
No_New
	lea     Relative_Tracks,a0  * UPDATE ALIENS IN AWO
	move.l	a0,a6
	add     AWS_Table_X_Off(a3),a0	* A0 X Track
	add     AWS_Table_Y_Off(a3),a6	* A6 Y Track
	move	AWS_Table_Obj_Off(a3),d5	* D5 Table Obj Nff
                  lea	TS_Aliens(a1),a2
	moveq	#0,d1
	move.b	TS_First_Alien(a1),d1
	add	d1,a2
	move.l	TS_Awo_Ptr(a1),a4		* A4 Ptr on AWO
	move	d0,(a4)+
	move.l	a4,a3
                  lea	2(a4),a4
	add	d1,a4	** AWO
	add	d1,d1
	add	d1,a4
	subq	#1,d0
.loop
	move	(a2)+,d1
	bne	.no_first
	move	(a0),d2
	sub	Level_X(D),d2
	add	#320-32,d2
	move	d2,AWO_Alien_X(a4)
	move	(a6),AWO_Alien_Y(a4)
	addq	#2,a0                               * ignore 1st coord ctrl 1
	addq	#2,a6
	bra	.cont
.no_first
;	subq	#1,d1		* ignore 1st coord ctrl 2
                  addq	#1,d1

	move	d1,d2		* Read new delta x & y
	lsr	#1,d1
	move.b	(a0,d1.w),d3
	move.b	(a6,d1.w),d4
	btst	#0,d2
	bne	.sec
	lsr	#4,d3
	lsr	#4,d4
.sec
	and	#$f,d3
	btst	#3,d3
	beq	.plus0
	or	#$fff0,d3
.plus0
	and	#$f,d4
	btst	#3,d4
	beq	.plus1
	or	#$fff0,d4
.plus1
	cmp	#$fff8,d3
	bne	.no_last
                  addq.b	#4,TS_First_Alien(a1)	* Remove an Alien
	add	#AWO_Len,(a3)
	subq	#1,-2(a3)
	subq	#1,TS_Alien_Num(a1)
	bne	.cont
	moveq	#0,d1		* Remove Track
	move.b	TS_Num(a1),d1
                  lea     Track_Table(D),a0
	bset	#7,(a0,d1.w)
	move.l	#$ffff0000,-2(a3)
	st	_Refresh_Pal
	bra	Track_End
.no_last
	subq	#2,d3		* update AWO coord
	add	d3,AWO_Alien_X(a4)
	add	d4,AWO_Alien_Y(a4)
.cont
	lea	Anim_Base,a5
	add     d5,a5
	add     (a2)+,a5
	move	(a5),d1
	bpl	.ok
	clr	-2(a2)
	lea	Anim_Base,a5
	add     d5,a5
	move	(a5),d1
.ok
	move	d1,AWO_Alien_Obj_Off(a4)
	lea	Rel_Start+32768,D

	lea	AWO_Len(a4),a4            * LOOP ENDING CTRL
	dbra	d0,.loop
	bra	Track_end

Abs_Track                                     * A B S O L U T E   T R A C K S
	bclr	#30,d0	* -----------------------------

	move.l	d0,a3
	move	TS_Alien_Num(a1),d0		* d0 Alien num
	beq	A_New_Alien

                  lea	TS_Aliens(a1),a2		* A2 Ptr on 32 Aliens
	moveq	#0,d1
	move.b	TS_First_Alien(a1),d1
	add	d1,a2
	move	d0,d1
	subq	#1,d1
.loop
	add.l	#$00010002,(a2)+	* INC POS OF EATCH ALIEN IN TS
	move	-4(a2),d3		* d3 pos in track of LAST Alie~
	dbra	d1,.loop
	cmp.b	AWS_Alien_Rate(a3),d3	* Tst alien rate
	bne	A_No_New
A_New_Alien			* ADD AN ALIEN
	cmp.b	AWS_Alien_Num(a3),d0
	beq	A_No_New
                  tst.b	TS_First_Alien(a1)
	bne	A_No_New
                  addq	#1,TS_Alien_Num(a1)
	move	d0,d1
	addq	#1,d0
	add	d1,d1
	add	d1,d1
	lea	TS_Aliens(a1),a2		* a2 Ptr on 32 Aliens
                  clr.l	(a2,d1.w)
A_No_New
	lea     Absolute_Tracks,a0  * UPDATE ALIENS IN AWO
	move.l	a0,a6
	add     AWS_Table_X_Off(a3),a0	* A0 X Track
	add     AWS_Table_Y_Off(a3),a6	* A6 Y Track
	move	AWS_Table_Obj_Off(a3),d5	* D5 Table Obj Off
                  lea	TS_Aliens(a1),a2
	moveq	#0,d1
	move.b	TS_First_Alien(a1),d1
	add	d1,a2
	move.l	TS_Awo_Ptr(a1),a4		* A4 Ptr on AWO
	move	d0,(a4)+
	move.l	a4,a3
                  lea	2(a4),a4
	add	d1,a4	** AWO
	add	d1,d1
	add	d1,a4
	subq	#1,d0
.loop
	move	(a2)+,d1
	bne	.no_first
	move	TS_X_Start(a1),AWO_Alien_X(a4)
	move	TS_Y_Start(a1),AWO_Alien_Y(a4)
	bra	.cont
.no_first
	subq	#1,d1		* ignore 1st coord ctrl 2

	move	d1,d2		* Read new delta x & y
	lsr	#1,d1
	move.b	(a0,d1.w),d3
	move.b	(a6,d1.w),d4
	btst	#0,d2
	bne	.sec
	lsr	#4,d3
	lsr	#4,d4
.sec
	and	#$f,d3
	btst	#3,d3
	beq	.plus0
	or	#$fff0,d3
.plus0
	and	#$f,d4
	btst	#3,d4
	beq	.plus1
	or	#$fff0,d4
.plus1
	cmp	#$fff8,d3
	bne	.no_last
	addq.b	#4,TS_First_Alien(a1)	* Remove an Alien
	add	#AWO_Len,(a3)
	subq	#1,-2(a3)
	subq	#1,TS_Alien_Num(a1)
	bne	.cont
	moveq	#0,d1		* Remove Track
	move.b	TS_Num(a1),d1
                  lea     Track_Table(D),a0
	bset	#7,(a0,d1.w)
	move.l	#$ffff0000,-2(a3)
	move	#1,_Refresh_Pal
	bra	Track_End
.no_last
	add	d3,AWO_Alien_X(a4)		* update AWO coord
	add	d4,AWO_Alien_Y(a4)
.cont
	lea	Anim_Base,a5
	add     d5,a5
	add     (a2)+,a5
	move	(a5),d1
	bpl	.ok
	clr	-2(a2)
	lea	Anim_Base,a5
	add     d5,a5
	move	(a5),d1
.ok
	move	d1,AWO_Alien_Obj_Off(a4)
	lea	Rel_Start+32768,D

	lea	AWO_Len(a4),a4            * LOOP ENDING CTRL
	dbra	d0,.loop
Track_End
	dbra	d7,Tracks_Loop

	lea	Custom,C



* PALETTE CTRL
* ------------


                  tst	Short_Phase(D)
	beq	No_Pal_Update

                  move    Refresh_Pal(D),d0
	beq	No_Pal_Update

	cmp	#1,d0
	beq	.cpy
	cmp	#2,Rout_Mod_Pal_Counter(D)
	bge	.pass
.cpy
	move.l	Front_Pal_Ptr(D),a0
	lea     Front_Pal_Buffer(D),a1
	moveq	#(7*3)-1,d0
.cpy_loop
	move.l	(a0)+,(a1)+
	dbra	d0,.cpy_loop
.pass
                  clr	Refresh_Pal(D)
	lea	Track_Table(D),a3
	moveq	#15,d7
.loop
	move.l	(a3)+,d0		* A3 Ptr on TS
                  bmi     .end_loop

	move.l  d0,a1

	lea	Front_Pal_Buffer(D),a0
                  move.l	TS_Aws_Ptr(a1),d0
	bclr	#30,d0
	move.l	d0,a1
	lea	AWS_Pal_Mod_Lin0(a1),a2

	moveq	#5,d1
.yloop
	tst.b	(a2)+
	bpl	.yes
	lea	14(a0),a0
	bra	.no_Y
.yes
	moveq	#6,d2
	lea	AWS_Pal_Mod_Col1(a1),a4
.col_loop
	tst	(a4)+
	bmi	.no_col
	move	-2(a4),(a0)
.no_col
	addq	#2,a0
	dbra	d2,.col_loop
.no_y
	dbra	d1,.yloop
.end_loop
	dbra	d7,.loop
Rout_Pal
	move.l	Rout_Pal_Ptr(D),d0
	bmi	.no_Rout_pal
	move.l	d0,a1
                  lea	6(a1),a2
	lea	Front_Pal_Buffer(D),a0
                  moveq	#5,d0
.lin_loop
	tst.b   (a1)+
	bpl	.yes
	lea	14(a0),a0
                  bra	.no_col
.yes
	move.l	a2,a3
	moveq	#6,d1
.col_loop
	tst	(a3)+
	bmi	.no
	move	-2(a3),(a0)
.no
                  addq	#2,a0
	dbra    d1,.col_loop
.no_col
	dbra	d0,.lin_loop
.no_rout_pal

	lea	Front_Pal_Buffer(D),a0                 * COPY IN COPPER LIST
	lea	Fr_Color0a_f0+2(D),a1
	move	(a0)+,(a1)
	move	(a0)+,4(a1)
	move	(a0)+,8(a1)
	move	(a0)+,12(a1)
	move	(a0)+,16(a1)
	move	(a0)+,20(a1)
	lea	Fr_Color0b_f0+2(D),a1
	move	(a0)+,(a1)

	lea	Fr_Color1a_f0+2(D),a1
	lea	Fr_Color1a_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)
	move	(a0)+,d0
	move	d0,4(a1)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,8(a2)
	move	(a0)+,d0
	move	d0,12(a1)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,16(a2)
	move	(a0)+,d0
	move	d0,20(a1)
	move	d0,20(a2)
	lea	Fr_Color1b_f0+2(D),a1
	lea	Fr_Color1b_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)

	lea	Fr_Color2a_f0+2(D),a1
	lea	Fr_Color2a_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)
	move	(a0)+,d0
	move	d0,4(a1)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,8(a2)
	move	(a0)+,d0
	move	d0,12(a1)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,16(a2)
	move	(a0)+,d0
	move	d0,20(a1)
	move	d0,20(a2)
	lea	Fr_Color2b_f0+2(D),a1
	lea	Fr_Color2b_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)

	lea	Fr_Color3a_f0+2(D),a1
	lea	Fr_Color3a_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)
	move	(a0)+,d0
	move	d0,4(a1)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,8(a2)
	move	(a0)+,d0
	move	d0,12(a1)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,16(a2)
	move	(a0)+,d0
	move	d0,20(a1)
	move	d0,20(a2)
	lea	Fr_Color3b_f0+2(D),a1
	lea	Fr_Color3b_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)

	lea	Fr_Color4a_f0+2(D),a1
	lea	Fr_Color4a_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)
	move	(a0)+,d0
	move	d0,4(a1)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,8(a2)
	move	(a0)+,d0
	move	d0,12(a1)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,16(a2)
	move	(a0)+,d0
	move	d0,20(a1)
	move	d0,20(a2)
	lea	Fr_Color4b_f0+2(D),a1
	lea	Fr_Color4b_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)

	lea	Fr_Color5a_f0+2(D),a1
	lea	Fr_Color5a_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)
	move	(a0)+,d0
	move	d0,4(a1)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,8(a2)
	move	(a0)+,d0
	move	d0,12(a1)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,16(a2)
	move	(a0)+,d0
	move	d0,20(a1)
	move	d0,20(a2)
	lea	Fr_Color5b_f0+2(D),a1
	lea	Fr_Color5b_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,(a2)

No_Pal_Update



* AWO COLISION TEST
* -----------------

	lea     AWO_Struct(D),a0	* a0 AWO Dyn Ptr
Col_Bank_Loop
	move	(a0)+,d0	* d0 Curent Alien Num
                  beq	Col_Bank_Ignored
	cmp	#-1,d0
	bne	Col_Bank_Tested
Col_Bank_Ignored
	lea	16*AWO_Len+2(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	bge     Col_Bank_End
	bra	Col_Bank_Loop
Col_Bank_Tested
	move	(a0)+,d1
	move.l	a0,Curent_Bank_Ptr(D)
	add	d1,a0
	subq	#1,d0
.obj_loop
	move.b	AWO_Alien_Status(a0),d1
	and	#$f,d1
	bne	.obj_end

	move	AWO_Alien_Obj_Off(a0),a1
	add.l	#Objects_Struct,a1
	add	(a1),a1	* a1 Ptr on Rec Struct
.bad_rec_loop
	move.b	(a1)+,d2	* d2 x1
	cmp.b	#$80,d2
	beq	.obj_end
	move.b	(a1)+,d3            * d3 y1
	move.b	(a1)+,d4            * d4 x2
	move.b	(a1)+,d5            * d5 y2
	ext	d2
	ext	d3
	ext	d4
	ext	d5
	move	AWO_Alien_X(a0),d6
	move	AWO_Alien_Y(a0),d7
	add	d6,d2
	add	d7,d3
	add	d6,d4
	add	d7,d5

	lea	Good_Col_List(D),a2
	moveq	#7,d1
.good_rec_loop
                  move	(a2),d6	* d6 x1'
                  bmi	.no_col
	cmp	d6,d4
	blt	.no_col
                  move	2(a2),d6	* d6 y1'
	cmp	d6,d5
	blt	.no_col
	move	4(a2),d6	* d6 x2'
	cmp	d2,d6
	blt	.no_col
                  move	6(a2),d6	* d6 y2'
	cmp	d3,d6
	blt	.no_col
			* COLISION FOUND
;	REPT	16
;	st	$dff18
;	ENDR

	move.l	#$13,Point(D)
	move	#3,Sound0_Req(D)
	move    #63,Sound0_Vol_Req(D)
	bsr	Sound_Start
	move.b	#$10,AWO_Alien_Status(a0)
	subq	#1,AWO_Alien_Energy(a0)
	bne	.no_explo
	move	#1,Sound0_Req(D)
	move    #63,Sound0_Vol_Req(D)
	bsr	Sound_Start
	move.b	#$01,AWO_Alien_Status(a0)
	move.l  #$116,Point(D)
.no_explo
	tst	Sorcerer_On(D)
	beq	.cont
	cmp	#7,d1
	bne	.cont
	IFNE	ASM_Demo_Mode=2
                  cmp     #$22f0,Level_X(D)
	ble	.cont
	ENDC
	tst	Die(D)
	bne	.obj_end
                  st	Die(D)
	clr	Die_Mode(D)
.cont
	cmp	#6,d1
	bne	.obj_end
	move	#Fw_F_Off,Fw_Fire_Step(D)
	moveq	#-1,d6
	move.l	d6,(a2)+
	move.l	d6,(a2)
                  bra	.obj_end
.no_col
	lea	8(a2),a2
	dbra	d1,.good_rec_loop
	bra	.bad_rec_loop
.obj_end
	lea     AWO_Len(a0),a0
	dbra    d0,.obj_loop

	move.l  Curent_Bank_Ptr(D),a0
	lea	16*AWO_Len(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	beq     Col_Bank_End
                  bra     Col_Bank_Loop
Col_Bank_End



* ROUTINE MANAGER
* ---------------


	cmp	#2,Curent_Spell(D)
	beq     Play_End

	lea	Rout_Struct(D),a0
	moveq	#31,d7
Routine_Loop
	move.l	(a0),a1
	cmp.l	#-1,a1
	beq	.no_valid
	jsr	(a1)
.no_valid
	lea	Rout_Len(a0),a0
	dbra	d7,Routine_Loop
Play_End

;	move	Rout_Mod_Pal_Counter(D),Spell_Time(D)    ***
;	st	Refresh_Status(D)






