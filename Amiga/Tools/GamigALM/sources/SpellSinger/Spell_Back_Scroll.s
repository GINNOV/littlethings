
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      S P E L L   S I N G E R	            *
*                      =========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                           Back Scrolling                                *
*                           --------------                                *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Coding:	Yves Grolet
* Date:	25/12/1991
* Tab:            custom






***************************************************************************



                  lea	Custom,C
	lea	Rel_Start+32768,D



* STAGE 1
* -------


	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	moveq	#4,d0
	move	d0,Bltamod(C)
	move	d0,Bltbmod(C)
	moveq	#0,d0
	move	d0,Bltcmod(C)
	move	d0,Bltdmod(C)
	move.l	#$00000fca,d0
	move    Pos_X(D),d1
	and	#%11110,d1
	eor	#%11110,d1
                  ror	#5,d1
	or	d1,d0
	swap	d0
	or	d1,d0
	move.l	d0,Bltcon0(C)

	move    Scr_1_Split(D),d0
	cmp	#1,d0
	ble	.no_part1

	move.l	Scr_1_Ptr(D),a0	* a0 scr scroll
                  lea	42*194*3(a0),a1	* a1 mask scroll
	move.l	Scr_B_Used(D),a2	* a2 scr buff
	move.l	#Scr_A,a3	* a3 dest buff
	move	#193,d1
	sub	d0,d1
	lea	x38(D),a4
	add	d1,d1
	move	(a4,d1.w),d1
	add	d1,a2
	add	d1,a3
	move	d0,d3
	subq	#1,d3
	lsl	#6,d3
	or	#19,d3

	move	#194*42,d1
	move	#192*38,d2
	move.l	a1,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a2,Bltcpt(C)
	move.l	a3,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	add	d2,a2
	add	d2,a3
	move.l	a1,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a2,Bltcpt(C)
	move.l	a3,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	add	d2,a2
	add	d2,a3
	move.l	a1,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a2,Bltcpt(C)
	move.l	a3,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
.no_part1
	cmp	#193,d0
                  beq	Stage_1_End

	move.l	Scr_1_Ptr(D),a0	* a0 scr scroll
                  lea	42*194*3(a0),a1	* a1 mask scroll
	move.l	Scr_B_Used(D),a2	* a2 scr buff
	move.l	#Scr_A,a3	* a3 dest buff
	move	d0,d1
	addq	#1,d1
	lea	x42(D),a4
	add	d1,d1
	move	(a4,d1.w),d1
	add	d1,a0
	add	d1,a1
	move	#193,d3
	sub	d0,d3
	lsl	#6,d3
	or	#19,d3

	move	#194*42,d1
	move	#192*38,d2
	move.l	a1,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a2,Bltcpt(C)
	move.l	a3,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	add	d2,a2
	add	d2,a3
	move.l	a1,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a2,Bltcpt(C)
	move.l	a3,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	add	d2,a2
	add	d2,a3
	move.l	a1,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a2,Bltcpt(C)
	move.l	a3,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
Stage_1_End



* STAGE 2
* -------


	move	Stage_2_Step(D),d0
	bne	.step1
	move.l	#Scr_2_Mask,d7
	move.l	d7,Bltapt(C)
	move.l	#Scr_2,d6
	move.l	d6,Bltbpt(C)
	move.l	Scr_C_Used(D),d5
	move.l	d5,Bltcpt(C)
	move.l	Scr_B_Build(D),d4
	move.l	d4,Bltdpt(C)

                  addq	#1,Stage_2_Step(D)
	move.l	Scr_B_Used(D),Scr_B_Build(D)
	move.l	d4,Scr_B_Used(D)
	bra	.cont
.step1
	move.l	#Scr_2_Mask+36*96,d7
	move.l	d7,Bltapt(C)
	move.l	#Scr_2+36*96,d6
	move.l	d6,Bltbpt(C)
	move.l	Scr_C_Used(D),d5
	add.l	#36*96,d5
	move.l	d5,Bltcpt(C)
	move.l	Scr_B_Build(D),d4
	add.l	#36*96,d4
	move.l	d4,Bltdpt(C)

                  clr	Stage_2_Step(D)
.cont
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	moveq	#0,d0
	move.l	d0,Bltamod(C)
	move.l	d0,Bltcmod(C)
	move.l	#$00000fca,d0
	move    Pos_X(D),d1
	and.l	#%111100,d1
                  ror	#6,d1
	or	d1,d0
	swap	d0
	or	d1,d0
	move.l	d0,Bltcon0(C)

	move	#64*96+19,d0
	move	d0,Bltsize(C)
	WAIT_BLIT
	move.l	#36*192,d3
	add.l	d3,d6
	add.l	d3,d5
	add.l	d3,d4
	move.l	d7,Bltapt(C)
	move.l	d6,Bltbpt(C)
	move.l	d5,Bltcpt(C)
	move.l	d4,Bltdpt(C)
	move	d0,Bltsize(C)
	WAIT_BLIT
	add.l	d3,d6
	add.l	d3,d5
	add.l	d3,d4
	move.l	d7,Bltapt(C)
	move.l	d6,Bltbpt(C)
	move.l	d5,Bltcpt(C)
	move.l	d4,Bltdpt(C)
	move	d0,Bltsize(C)
	WAIT_BLIT



* STAGE 3  (Scr 4 rot)
* --------------------


Loc0
	move	Stage_3_Step(D),d0
	beq	.step0
	subq	#1,d0
	beq	.step1
	subq	#1,d0
	beq	.step2
.step3
	move.l	#Scr_4+36*144,d7
	bra	.cont
.step2
	move.l	#Scr_4+36*96,d7
	bra	.cont
.step1
	move.l	#Scr_4+36*48,d7
	bra	.cont
.step0
	move.l	#Scr_4,d7
.cont
	move.l	d7,Bltapt(C)
	move.l	#Scr_D,Bltdpt(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	moveq	#0,d0
	move.l	d0,Bltamod(C)
	move.l	d0,Bltcmod(C)
	move.l	#$000009f0,d0
	move    Pos_X(D),d1
	and.l	#%11110000,d1
                  ror	#8,d1
	or	d1,d0
	swap	d0
	or	d1,d0
	move.l	d0,Bltcon0(C)

	move	#64*48+19,d0
	move	d0,Bltsize(C)
	WAIT_BLIT
	add.l	#36*192,d7
	move.l	d7,Bltapt(C)
	move	d0,Bltsize(C)
	WAIT_BLIT
	add.l	#36*192,d7
	move.l	d7,Bltapt(C)
	move	d0,Bltsize(C)
	WAIT_BLIT



* STAGE 3  (Mix)
* --------------


Loc1
	move	Stage_3_Step(D),d0
	beq	.step0
	subq	#1,d0
	beq	.step1
	subq	#1,d0
	beq	.step2
.step3
	move.l	#Scr_3_Mask+36*144,d7
	move.l	d7,Bltapt(C)
	move.l	#Scr_3+36*144,d6
	move.l	d6,Bltbpt(C)
	move.l	Scr_C_Build(D),d4
	add.l	#36*144,d4
	move.l	d4,Bltdpt(C)

                  clr	Stage_3_Step(D)
	bra	.cont
.step2
	move.l	#Scr_3_Mask+36*96,d7
	move.l	d7,Bltapt(C)
	move.l	#Scr_3+36*96,d6
	move.l	d6,Bltbpt(C)
	move.l	Scr_C_Build(D),d4
	move.l	d4,d0
	add.l	#36*96,d4
	move.l	d4,Bltdpt(C)

                  addq	#1,Stage_3_Step(D)
	move.l	Scr_C_Used(D),Scr_C_Build(D)
	move.l	d0,Scr_C_Used(D)
	bra	.cont
.step1
	move.l	#Scr_3_Mask+36*48,d7
	move.l	d7,Bltapt(C)
	move.l	#Scr_3+36*48,d6
	move.l	d6,Bltbpt(C)
	move.l	Scr_C_Build(D),d4
	add.l	#36*48,d4
	move.l	d4,Bltdpt(C)

                  addq	#1,Stage_3_Step(D)
	bra	.cont
.step0
	move.l	#Scr_3_Mask,d7
	move.l	d7,Bltapt(C)
	move.l	#Scr_3,d6
	move.l	d6,Bltbpt(C)
	move.l	Scr_C_Build(D),d4
	move.l	d4,Bltdpt(C)

                  addq	#1,Stage_3_Step(D)
.cont
	move.l	#Scr_D,Bltcpt(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	moveq	#0,d0
	move.l	d0,Bltamod(C)
	move.l	d0,Bltcmod(C)
	move.l	#$00000fca,d0
	move    Pos_X(D),d1
	and.l	#%1111000,d1
                  ror	#7,d1
	or	d1,d0
	swap	d0
	or	d1,d0
	move.l	d0,Bltcon0(C)

	move	#64*48+19,d0
	move	d0,Bltsize(C)
	WAIT_BLIT
	move.l	#36*192,d3
	add.l	d3,d6
	add.l	d3,d4
	move.l	d7,Bltapt(C)
	move.l	d6,Bltbpt(C)
	move.l	d4,Bltdpt(C)
	move	d0,Bltsize(C)
	WAIT_BLIT
	add.l	d3,d6
	add.l	d3,d4
	move.l	d7,Bltapt(C)
	move.l	d6,Bltbpt(C)
	move.l	d4,Bltdpt(C)
	move	d0,Bltsize(C)
	WAIT_BLIT






***************************************************************************



* JOYSTICK TEST
* -------------


	clr	Move_Up(D)
	clr	Move_Right(D)
	clr	Move_Down(D)
	clr	Move_Left(D)

                  moveq	#0,d0
                  moveq	#0,d5
	move.b	Joy1dat(C),d0
	move.b	Joy1dat+1(C),d5

	move	d5,d2
	lsr	#1,d2
	move	d0,d4
	lsr	#1,d4
	btst	#0,d2
	beq	.no_right
			* Right
	st	Move_Right(D)
                  addq	#2,Pos_X(D)
	bra	.no_left
.no_right
	btst	#0,d4
	beq	.no_left
			* Left
	st	Move_Left(D)
                  subq	#2,Pos_X(D)
.no_left
	eor	d5,d2
	btst	#0,d2
	beq	.no_down
			* Down
	st	Move_Down(D)
                  addq	#2,Pos_Y(D)
	bra	.no_up
.no_down
	eor	d0,d4
	btst	#0,d4
	beq	.no_up

	st	Move_Up(D)
                  subq	#2,Pos_Y(D)
			* Up
.no_up



* Initial Build
* -------------


	tst	Initial_Build(D)
	beq     No_Init_Build
	clr	Initial_Build(D)

	moveq  	#$f0,d0
	and	d0,Pos_X(D)
	and	d0,Pos_Y(D)
	move	Pos_X(D),d0
	move	Pos_Y(D),d1

                  lea	Scr_1,a0
	lsr	#4,d0
	move	d0,d2
	add	d0,a0
	move.l	a0,Scr_1_Ptr(D)     * a0 Scr ptr - 2
	lea	42(a0),a0           * +42 = skip up-build-line-buffer
                  lea	Map_1-576,a1
	add	d2,d2
	add	d2,a1
	add	d1,d1
	add	d1,a1
	lsl	#3,d1	* d1=d1x18 (576/32)
	add	d1,a1
	move.l	a1,Map_1_Ptr(D)	* a1 map ptr - 576
	lea	576(a1),a1

	moveq	#11,d5
.y_loop
	moveq	#18,d6
.x_loop
	move.l	(a1)+,d3
	move.l	d3,d2
	swap	d3
	ext.l	d3	* d3 1st char
	ext.l	d2	* d2 2nd char

	addq	#2,a0
	lea	Char_1,a2
	move.l	a2,a4
                                              * COMPUTE MASK OF CHAR 2
                  lsl.l	#5,d2
	add.l	d2,a4
	add.l	d2,d2
	add.l	d2,a4               * a4 src ptr for second char
	move.l	a4,a3
	move.l	a4,Bltapt(C)
	moveq	#32,d0
                  add	d0,a4
	move.l	a4,Bltbpt(C)
                  add	d0,a4
	move.l	a4,Bltcpt(C)
	move.l	#Char_Mask,d4
	move.l	d4,Bltdpt(C)
	moveq	#0,d0
	move.l	d0,Bltamod(C)
	move.l	d0,Bltcmod(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	move.l	#$0ffe0000,Bltcon0(C)
	move	#64*16+1,d7
	move	d7,Bltsize(C)
	WAIT_BLIT
                                              * DISPLAY CHAR 1
                  lsl.l	#5,d3
	add.l	d3,a2
	add.l	d3,d3
	add.l	d3,a2               * a2 src ptr for first char
                  move.l	a2,Bltapt(C)
	move.l	a0,Bltdpt(C)
	move.l	a0,a2
	moveq	#$28,d0
	move	d0,Bltdmod(C)
	move	#$09f0,Bltcon0(C)
                  move	#42*194,d1
	move	d7,Bltsize(C)
	WAIT_BLIT
	add	d1,a2
	move.l	a2,Bltdpt(C)
	move	d7,Bltsize(C)
	WAIT_BLIT
	add	d1,a2
	move.l	a2,Bltdpt(C)
	move	d7,Bltsize(C)
	WAIT_BLIT
                               	* DISPLAY CHAR 2
	move.l	d4,Bltapt(C)
                  move.l	a3,Bltbpt(C)
	move.l	a0,a2
	move.l	a2,Bltcpt(C)
	move.l	a2,Bltdpt(C)
	move	d0,Bltcmod(C)
	move	#$0fca,Bltcon0(C)
	move	d7,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d1,a2
	move.l	a2,Bltcpt(C)
	move.l	a2,Bltdpt(C)
	move	d7,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d1,a2
	move.l	a2,Bltcpt(C)
	move.l	a2,Bltdpt(C)
	move	d7,Bltsize(C)
	WAIT_BLIT
			* COMPUTE TOTAL MASK
	move.l	a0,a2
	move.l  a2,Bltapt(C)
                  add	d1,a2
	move.l  a2,Bltbpt(C)
                  add	d1,a2
	move.l  a2,Bltcpt(C)
                  add	d1,a2
	move.l  a2,Bltdpt(C)
	move	d0,Bltamod(C)
	move	d0,Bltbmod(C)
	move	#$0ffe,Bltcon0(C)
	move	d7,Bltsize(C)
	WAIT_BLIT

	dbra	d6,.x_loop
	lea	634(a0),a0
	lea	500(a1),a1
	dbra	d5,.y_loop

	moveq	#-1,d0
	move	d0,Scr_1_U_Step(D)
	move	d0,Scr_1_R_Step(D)
	move	d0,Scr_1_D_Step(D)
	move	d0,Scr_1_L_Step(D)
	move	#193,Scr_1_Split(D)
                  st      Move_Right(D)	* ! inc scr ptr & map ptr
                  st      Move_Down(D)
No_Init_Build



* Update screen 1
* ---------------


	BORDER	$f00
                                              *** SCROLL DOWN ***
	tst	Move_Down(D)
	beq     No_Scr_1_Down

	move	Pos_Y(D),d4
	and.l	#%11110,d4
	bne	.no_init
	add.l	#144*4,Map_1_Ptr(D)
	lea	Map_1_R_Buff(D),a0
	lea	Map_1_L_Buff(D),a1
	move	Scr_1_Split(D),d0
	lsr	#4,d0
	bne	.cont
	lea	11*4(a0),a0
      	bra	.cont2
.cont
	subq	#1,d0
	add	d0,d0
	add	d0,d0
	add	d0,a0
.cont2
	move.l	Map_1_Ptr(D),a2
	move.l  5832(a2),(a0)
;	move.l	8060(a2),(a1)
	moveq	#-1,d0
	move	d0,Scr_1_D_Step(D)
	move	d0,Scr_1_U_Step(D)
.no_init
	addq	#1,Scr_1_D_Step(D)
	bne	.no_step0
	lea	Map_1_D_Buff(D),a1
	move.l	Map_1_Ptr(D),a0
	lea	6904(a0),a0
	moveq	#20,d0
.loop
	move.l	(a0)+,d1
	move	d1,d2
	swap	d1
	ext.l	d1
	ext.l	d2
	lea	char_1,a2
	move.l	a2,d3
                  lsl.l	#5,d1
	add.l	d1,a2
	add.l	d1,d1
	add.l	d1,a2
	add	d4,a2
	move.l	a2,(a1)+            * char 1 ptr
                  lsl.l	#5,d2
	add.l	d2,d3
	add.l	d2,d2
	add.l	d2,d3
	add.l	d4,d3
	move.l	d3,(a1)+            * char 2 ptr
	dbra	d0,.loop
.no_step0
	addq	#1,Scr_1_Split(D)
	move	Scr_1_Split(D),d0
	cmp	#194,d0
	bne     .no
	clr	Scr_1_Split(D)	* if split=0 => d0 keep at 194 ! -1
.no
	subq	#1,d0
	lea	x42(D),a0
	add	d0,d0
                  move.l	Scr_1_Ptr(D),a1
	add	(a0,d0.w),a1	* a1 dest ptr
	subq	#2,a1
	lea	Map_1_D_Buff(D),a0
	lea	42*194(a1),a2
	lea	42*194*2(a1),a4
	lea	42*194*3(a1),a5	* ! a5 = D
	moveq	#20,d0
.char_loop
	move.l	(a0),a3
	addq.l	#2,(a0)+
	move	(a3),d5
	move	32(a3),d6
	move	64(a3),d7

	move.l	(a0),a3
	addq.l	#2,(a0)+
	move	(a3),d1
	move	32(a3),d2
	move	64(a3),d3

	move	d1,d4
	or	d3,d4
	or	d2,d4	* d4 mask
	eor	#$ffff,d4

	and	d4,d5
	and	d4,d6
	and	d4,d7

	or	d1,d5
	or	d2,d6
	or	d3,d7

	move	d5,(a1)+
	move	d6,(a2)+
	move	d7,(a4)+

	or	d5,d7
	or	d6,d7

	move	d7,(a5)+

                  dbra	d0,.char_loop
	lea	Rel_Start+32768,D
No_Scr_1_Down
                                              *** SCROLL RIGHT ***
	tst	Move_Right(D)
	beq     No_Scr_1_Right

	move	Pos_X(D),d0
	and	#%11110,d0
	bne	.no_init
	addq.l	#2,Scr_1_Ptr(D)
	addq.l	#4,Map_1_Ptr(D)
	moveq	#-1,d0
	move	d0,Scr_1_R_Step(D)
	move	d0,Scr_1_L_Step(D)
	move	d0,Scr_1_D_Step(D)
.no_init
	addq	#1,Scr_1_R_Step(D)
	bne	.no_Step0
	lea	Map_1_R_Buff(D),a1
	move.l	Map_1_Ptr(D),a0
	lea	18*4(a0),a0
	moveq	#14,d0
.loop
	move.l	(a0),(a1)+
	lea	144*4(a0),a0
	dbra	d0,.loop
                  move.l	Scr_1_Ptr(D),a0
	lea	38+42(a0),a0	* skip up-buffer & go to end of line
	move	Scr_1_Split(D),d0
	addq	#1,d0
	and	#$fff0,d0
	lea	x42(D),a1
	add	d0,d0
	add	(a1,d0.w),a0
	move.l	a0,Scr_1_R_Ptr(D)
	bra	No_Scr_1_Left
.no_step0
	move	Scr_1_R_Step(D),d0
	cmp	#13,d0
	bgt	No_Scr_1_Left
	bne	.no_step13
			* STEP 13 (disp only part of this char)
	move	Scr_1_Split(D),d3
	and	#$f,d3
	beq	No_Scr_1_Left
	lsl	#6,d3
	or	#1,d3

	subq	#1,d0
	move	d0,d1
	add	d1,d1
	add	d1,d1
	lea	Map_1_R_Buff(D),a0
	move.l	(a0,d1.w),d1	* d1 first char
	move.l	d1,d2
	swap	d1                  * d2 second char
                  ext.l   d1
                  ext.l   d2
                  move.l	Scr_1_R_Ptr(D),a0   * a0 dest ptr
                  add.l	#672,Scr_1_R_Ptr(D)
	move.l	Scr_1_Ptr(D),a1
                  lea	8064+38+42(a1),a2
	cmp.l	Scr_1_R_Ptr(D),a2
	bne	.ok
	lea     38+42(a1),a1
	move.l	a1,Scr_1_R_Ptr(D)
.ok
	lea	Char_1,a1
	move.l	a1,a2
                                              * COMPUTE MASK OF CHAR 2
                  lsl.l	#5,d2
	add.l	d2,a1
	add.l	d2,d2
	add.l	d2,a1               * a1 src ptr for second char
	move.l	a1,a3
	move.l	a1,Bltapt(C)
	moveq	#32,d0
                  add	d0,a1
	move.l	a1,Bltbpt(C)
                  add	d0,a1
	move.l	a1,Bltcpt(C)
	move.l	#Char_Mask,d4
	move.l	d4,Bltdpt(C)
	moveq	#0,d0
	move.l	d0,Bltamod(C)
	move.l	d0,Bltcmod(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	move.l	#$0ffe0000,Bltcon0(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
                                              * DISPLAY CHAR 1
                  lsl.l	#5,d1
	add.l	d1,a2
	add.l	d1,d1
	add.l	d1,a2               * a1 src ptr for first char
                  move.l	a2,Bltapt(C)
	move.l	a0,Bltdpt(C)
	move.l	a0,a1
	moveq	#$28,d0
	move	d0,Bltdmod(C)
	move	#$09f0,Bltcon0(C)
                  move	#42*194,d1
	move	#32,d2
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d2,a2
	add	d1,a0
                  move.l	a2,Bltapt(C)
	move.l	a0,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d2,a2
	add	d1,a0
                  move.l	a2,Bltapt(C)
	move.l	a0,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
                               	* DISPLAY CHAR 2
	move.l	d4,Bltapt(C)
                  move.l	a3,Bltbpt(C)
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move.l	a1,a0
	move	d0,Bltcmod(C)
	move	#$0fca,Bltcon0(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d2,a3
                  move.l	a3,Bltbpt(C)
	add	d1,a1
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d2,a3
                  move.l	a3,Bltbpt(C)
	add	d1,a1
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
			* COMPUTE TOTAL MASK
	move.l  a0,Bltapt(C)
                  add	d1,a0
	move.l  a0,Bltbpt(C)
                  add	d1,a0
	move.l  a0,Bltcpt(C)
                  add	d1,a0
	move.l  a0,Bltdpt(C)
	move	d0,Bltamod(C)
	move	d0,Bltbmod(C)
	move	#$0ffe,Bltcon0(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	bra	No_Scr_1_Left
.no_step13
	subq	#1,d0	* STEP 1->12
	move	d0,d1
	add	d1,d1
	add	d1,d1
	lea	Map_1_R_Buff(D),a0
	move.l	(a0,d1.w),d1	* d1 first char
	move.l	d1,d2
	swap	d1                  * d2 second char
                  ext.l   d1
                  ext.l   d2
                  move.l	Scr_1_R_Ptr(D),a0   * a0 dest ptr
                  add.l	#672,Scr_1_R_Ptr(D)
	move.l	Scr_1_Ptr(D),a1
                  lea	8064+38+42(a1),a2
	cmp.l	Scr_1_R_Ptr(D),a2
	bne	.ok2
	lea     38+42(a1),a1
	move.l	a1,Scr_1_R_Ptr(D)
.ok2
	lea	Char_1,a1
	move.l	a1,a2
                                              * COMPUTE MASK OF CHAR 2
                  lsl.l	#5,d2
	add.l	d2,a2
	add.l	d2,d2
	add.l	d2,a2               * a2 src ptr for second char
	move.l	a2,a3
	move.l	a2,Bltapt(C)
	moveq	#32,d0
                  add	d0,a2
	move.l	a2,Bltbpt(C)
                  add	d0,a2
	move.l	a2,Bltcpt(C)
	move.l	#Char_Mask,d4
	move.l	d4,Bltdpt(C)
	moveq	#0,d0
	move.l	d0,Bltamod(C)
	move.l	d0,Bltcmod(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	move.l	#$0ffe0000,Bltcon0(C)
	move	#64*16+1,d3
	move	d3,Bltsize(C)
	WAIT_BLIT
                                              * DISPLAY CHAR 1
                  lsl.l	#5,d1
	add.l	d1,a1
	add.l	d1,d1
	add.l	d1,a1               * a1 src ptr for first char
                  move.l	a1,Bltapt(C)
	move.l	a0,Bltdpt(C)
	move.l	a0,a1
	moveq	#$28,d0
	move	d0,Bltdmod(C)
	move	#$09f0,Bltcon0(C)
                  move	#42*194,d1
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	move.l	a0,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	move.l	a0,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
                               	* DISPLAY CHAR 2
	move.l	d4,Bltapt(C)
                  move.l	a3,Bltbpt(C)
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move.l	a1,a0
	move	d0,Bltcmod(C)
	move	#$0fca,Bltcon0(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d1,a1
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d1,a1
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
			* COMPUTE TOTAL MASK
	move.l  a0,Bltapt(C)
                  add	d1,a0
	move.l  a0,Bltbpt(C)
                  add	d1,a0
	move.l  a0,Bltcpt(C)
                  add	d1,a0
	move.l  a0,Bltdpt(C)
	move	d0,Bltamod(C)
	move	d0,Bltbmod(C)
	move	#$0ffe,Bltcon0(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	bra	No_Scr_1_Left
No_Scr_1_Right
                                              *** SCROLL LEFT ***
	tst	Move_Left(D)
	beq     No_Scr_1_Left

	move	Pos_X(D),d0
	and	#%11110,d0
	cmp	#%11110,d0
	bne	.no_init
	subq.l	#2,Scr_1_Ptr(D)
	subq.l	#4,Map_1_Ptr(D)
	moveq	#-1,d0
	move	d0,Scr_1_L_Step(D)
	move	d0,Scr_1_R_Step(D)
	move	d0,Scr_1_D_Step(D)
.no_init
	addq	#1,Scr_1_L_Step(D)
	bne	.no_Step0
	lea	Map_1_L_Buff(D),a1
	move.l	Map_1_Ptr(D),a0
	lea	-8(a0),a0
	moveq	#14,d0
.loop
	move.l	(a0),(a1)+
	lea	144*4(a0),a0
	dbra	d0,.loop
                  move.l	Scr_1_Ptr(D),a0
	lea	-2(a0),a0
	move.l	a0,Scr_1_L_Ptr(D)
	bra	No_Scr_1_Left
.no_Step0
	move	Scr_1_L_Step(D),d0
	cmp	#12,d0
	bgt	No_Scr_1_Left
	subq	#1,d0
	move	d0,d1
	add	d1,d1
	add	d1,d1
	lea	Map_1_L_Buff(D),a0
	move.l	(a0,d1.w),d1	* d1 first char
	move.l	d1,d2
	swap	d1                  * d2 second char
                  ext.l   d1
                  ext.l   d2
                  move.l	Scr_1_L_Ptr(D),a0   * a0 dest ptr
                  add.l	#672,Scr_1_L_Ptr(D)
	lea	Char_1,a1
	move.l	a1,a2
                                              * COMPUTE MASK OF CHAR 2
                  lsl.l	#5,d2
	add.l	d2,a2
	add.l	d2,d2
	add.l	d2,a2               * a2 src ptr for second char
	move.l	a2,a3
	move.l	a2,Bltapt(C)
	moveq	#32,d0
                  add	d0,a2
	move.l	a2,Bltbpt(C)
                  add	d0,a2
	move.l	a2,Bltcpt(C)
	move.l	#Char_Mask,d4
	move.l	d4,Bltdpt(C)
	moveq	#0,d0
	move.l	d0,Bltamod(C)
	move.l	d0,Bltcmod(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	move.l	#$0ffe0000,Bltcon0(C)
	move	#64*16+1,d3
	move	d3,Bltsize(C)
	WAIT_BLIT
                                              * DISPLAY CHAR 1
                  lsl.l	#5,d1
	add.l	d1,a1
	add.l	d1,d1
	add.l	d1,a1               * a1 src ptr for first char
                  move.l	a1,Bltapt(C)
	move.l	a0,Bltdpt(C)
	move.l	a0,a1
	moveq	#$28,d0
	move	d0,Bltdmod(C)
	move	#$09f0,Bltcon0(C)
                  move	#42*194,d1
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	move.l	a0,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	add	d1,a0
	move.l	a0,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
                               	* DISPLAY CHAR 2
	move.l	d4,Bltapt(C)
                  move.l	a3,Bltbpt(C)
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move.l	a1,a0
	move	d0,Bltcmod(C)
	move	#$0fca,Bltcon0(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d1,a1
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
	add	d1,a1
	move.l	a1,Bltcpt(C)
	move.l	a1,Bltdpt(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
			* COMPUTE TOTAL MASK
	move.l  a0,Bltapt(C)
                  add	d1,a0
	move.l  a0,Bltbpt(C)
                  add	d1,a0
	move.l  a0,Bltcpt(C)
                  add	d1,a0
	move.l  a0,Bltdpt(C)
	move	d0,Bltamod(C)
	move	d0,Bltbmod(C)
	move	#$0ffe,Bltcon0(C)
	move	d3,Bltsize(C)
	WAIT_BLIT
No_Scr_1_Left

	BORDER	$fff






