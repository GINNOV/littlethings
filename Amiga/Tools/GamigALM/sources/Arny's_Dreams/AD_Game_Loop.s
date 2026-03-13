
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      A R N Y ' S   D R E A M S	            *
*                      ===========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                           GAME LOOP MODULE                              *
*                           ----------------                              *
*                                                                         *
*                                                                         *
***************************************************************************



Main_Loop
	H_WAIT_SYNCH

	RLINE	$fff

	H_RESTORE_OBJ

	RLINE	$f00



* Camrea Move
* -----------


	move	Camera_Mode(D),d0	* 0 folow arny 1 ball 2 dest
                  bne     No_F_Arny
	move	Arny_X(D),d1
	lsr	#6,d1
	sub	#138,d1
	move	d1,Camera_Dest_X(D)
	move	Arny_Y(D),d1
	lsr	#6,d1
	sub	#96,d1
	move	d1,Camera_Dest_Y(D)
No_F_Arny
	cmp	#1,d0
                  bne     No_F_Ball
	move	Ball_X(D),Camera_Dest_X(D)
	move	Ball_Y(D),Camera_Dest_Y(D)
No_F_Ball
                  move	Camera_Dest_X(D),d0
                  move	Camera_Dest_Y(D),d1

	move	d0,d2
	sub	Camera_X(D),d2
	bpl	.plus
                  neg	d2
.plus
	cmp	#8,d2
	bge	No_X_Affect
	move	d0,Camera_X(D)
	bra     Cam_X_End
No_X_Affect
	cmp	Camera_X(D),d0
	blt	.plus
	addq	#8,Camera_X(D)
	bra     Cam_X_End
.plus
	subq	#8,Camera_X(D)
Cam_X_End
	move	d1,d2
	sub	Camera_y(D),d2
	bpl	.plus
                  neg	d2
.plus
	cmp	#8,d2
	bge	No_Y_Affect
	move	d1,Camera_Y(D)
	bra     Cam_Update
No_Y_Affect
	cmp	Camera_Y(D),d1
	blt	.plus1
	addq	#8,Camera_Y(D)
	bra     Cam_Update
.plus1
	subq	#8,Camera_Y(D)
Cam_Update
	move	Camera_X(D),d0
	bpl	.ok0
	clr	Camera_X(D)
.ok0
	cmp	#208,d0
	ble	.ok1
	move	#208,Camera_X(D)
.ok1
	move	Camera_Y(D),d0
	bpl	.ok2
	clr	Camera_Y(D)
.ok2
	cmp	#288,d0
	ble     .ok3
	move	#288,Camera_Y(D)
.ok3
	bsr	Update_Camera



* Obj Routines
* -------------


	RLINE	$fff

	H_SAFE_OBJ

	RLINE	$0f0

	H_DISPLAY_OBJ

	RLINE	$00f



* Arny's Movement Request
* -----------------------


	H_READ_JOY

                  tst	Joy_Up(D)
	beq     No_Up
				* UP
;	cmp	#-256,Arny_Speed_Y(D)
;	ble	No_Up
;	tst	Arny_Speed_Y(D)
;	bpl	.frein
;	subq	#8,Arny_Speed_Y(D)
;	bra	No_Up
;.frein
;	subq	#16,Arny_Speed_Y(D)
No_Up
                  tst	Joy_Down(D)
	beq     No_Down
				* DOWN
;	cmp	#256,Arny_Speed_Y(D)
;	bge	No_Down
;	tst	Arny_Speed_Y(D)
;	bmi     .frein
;	addq	#8,Arny_Speed_Y(D)
;	bra	No_Down
;.frein
;	addq	#16,Arny_Speed_Y(D)
No_Down
                  tst	Joy_Right(D)
	beq     No_Right
				* RIGHT
	cmp	#256,Arny_Speed_X(D)
	bge	No_Right
	tst	Arny_Speed_X(D)
	bmi	.frein
	addq	#8,Arny_Speed_X(D)
	bra	No_Right
.frein
	add	#16,Arny_Speed_X(D)
No_Right
                  tst	Joy_Left(D)
	beq     No_Left
				* LEFT
	cmp	#-256,Arny_Speed_X(D)
	ble	No_Left
	tst	Arny_Speed_X(D)
	bpl	.frein
	subq	#8,Arny_Speed_X(D)
	bra	No_Left
.frein
	sub	#16,Arny_Speed_X(D)
No_Left                                                       * go down without joystick req.
	tst	Flying_Mode(D)
	bne	No_X_Down

	lea	Obj_Struct(D),a1

	move	Obj_Y(a1),d1
	add	#30,d1
	move	Obj_X(a1),d0
	add	#15,d0
	bsr	Get_V_Mask_Info	* use d0-d4,a0
	or	d0,d1
	or	d0,d2
	bne	.no_left
	tst	d3
	beq	.no_left
	sub	#5,Arny_Speed_X(D)
.no_left
	move	Obj_Y(a1),d1
	add	#30,d1
	move	Obj_X(a1),d0
	add	#14,d0
	bsr	Get_V_Mask_Info	* use d0-d4,a0
	or	d0,d1
	or	d0,d2
	bne	.no_left2
	tst	d3
	beq	.no_left2
	sub	#5,Arny_Speed_X(D)
.no_left2
	move	Obj_Y(a1),d1
	add	#30,d1
	move	Obj_X(a1),d0
	add	#16,d0
	bsr	Get_V_Mask_Info	* use d0-d4,a0
	or	d0,d1
	or	d0,d2
	bne     .no_right
	tst	d3
	beq     .no_right
	add	#5,Arny_Speed_X(D)
.no_right
	move	Obj_Y(a1),d1
	add	#30,d1
	move	Obj_X(a1),d0
	add	#17,d0
	bsr	Get_V_Mask_Info	* use d0-d4,a0
	or	d0,d1
	or	d0,d2
	bne     No_X_Down
	tst	d3
	beq     No_X_Down
	add	#5,Arny_Speed_X(D)
No_X_Down
				* Default Deccel.
	tst     Arny_Speed_X(D)
	beq	.cont
	bpl	.plus
	cmp	#-4,Arny_Speed_X(D)
	blt	.skip0
	clr	Arny_Speed_X(D)
	bra	.cont
.skip0
	addq	#4,Arny_Speed_X(D)
	bra	.cont
.plus
	cmp	#4,Arny_Speed_X(D)
	bge	.skip1
	clr	Arny_Speed_X(D)
	bra	.cont
.skip1
	subq	#4,Arny_Speed_X(D)
.cont
	tst     Arny_Speed_Y(D)
	beq	.cont1
	bpl	.plus1
	cmp	#-4,Arny_Speed_Y(D)
	blt	.skip2
	clr	Arny_Speed_Y(D)
	bra	.cont1
.skip2
	addq	#4,Arny_Speed_Y(D)
	bra	.cont1
.plus1
	cmp	#4,Arny_Speed_Y(D)
	bge	.skip3
	clr	Arny_Speed_Y(D)
	bra	.cont1
.skip3
	subq	#4,Arny_Speed_Y(D)
.cont1
	tst	Flying_Mode(D)
	beq	.no_flying
	add	#20,Arny_Speed_Y(D)
.no_flying
				* Add Speed at Pos
                  move	Arny_Speed_X(D),d0
	add	d0,Arny_X(D)
                  move	Arny_Speed_Y(D),d0
	add	d0,Arny_Y(D)
				* Border test
	move	Arny_X(D),d0
	bpl	.ok0
                  moveq	#0,d0
	move	d0,Arny_Speed_X(D)
	move	d0,Arny_X(D)
.ok0
	cmp	#(512-32)*64,d0
	ble	.ok1
	move	#(512-32)*64,Arny_X(D)
	clr	Arny_Speed_X(D)
.ok1
	move	Arny_Y(D),d0
	bpl	.ok2
                  moveq	#0,d0
	move	d0,Arny_Speed_Y(D)
	move	d0,Arny_Y(D)
.ok2
	cmp	#(512-32)*64,d0
	ble	.ok3
	move	#(512-32)*64,Arny_Y(D)
	clr	Arny_Speed_Y(D)
.ok3



* DO Arny's movement with pixel event test
* ----------------------------------------


	lea	Obj_Struct(D),a1

* Y  LOOP
* - - - -

	moveq	#1,d6	* d6 direction of move 1 ->   -1 <-
	move	Arny_Y(D),d5
	lsr	#6,d5
	sub	Obj_Y(a1),d5	* d5 num of pixel to move
	bpl	.pos
                  neg	d5
	moveq	#-1,d6
.pos
	tst	d5
	beq	No_Arny_Y_Move
	subq	#1,d5
Arny_Move_Y_Loop			* Y Loop
	tst	Flying_Mode(D)
	beq     No_Arny_Move_Y_Flying
	tst	Arny_Speed_Y(D)
	bmi	No_Arny_Move_Y_Flying

	move	Obj_Y(a1),d1
	add	#30,d1
	move	Obj_X(a1),d0
	add	#15,d0
	bsr	Get_V_Mask_Info	* use d0-d4,a0
	tst	d2
	beq     .no
	or	d1,d0
	bne     .no
	clr	Flying_Mode(D)
       	clr	Jump_Step(D)
                  move	Obj_Y(a1),d0	* stoped
	lsl	#6,d0
	move	d0,Arny_Y(D)
	clr     Arny_Speed_Y(D)
	bra	No_Arny_Y_Move
.no
	move	Obj_Y(a1),d1
	add	#30,d1
	move	Obj_X(a1),d0
	add	#16,d0
	bsr	Get_V_Mask_Info	* use d0-d4,a0
	tst	d2
	beq     No_Arny_Move_Y_Flying
	or	d1,d0
	bne	No_Arny_Move_Y_Flying
	clr	Flying_Mode(D)
       	clr	Jump_Step(D)
                  move	Obj_Y(a1),d0	* stoped
	lsl	#6,d0
	move	d0,Arny_Y(D)
	clr     Arny_Speed_Y(D)
	bra	No_Arny_Y_Move
No_Arny_Move_Y_Flying

	add	d6,Obj_Y(a1)

          	dbra	d5,Arny_Move_Y_Loop
No_Arny_Y_Move


* X  LOOP
* - - - -

	moveq	#1,d6	* d6 direction of move 1 ->   -1 <-
	move	Arny_X(D),d5
	lsr	#6,d5
	sub	Obj_X(a1),d5	* d5 num of pixel to move
	bpl	.pos
                  neg	d5
	moveq	#-1,d6
.pos
	tst	d5
	beq	No_Arny_X_Move
	subq	#1,d5
Arny_Move_X_Loop			* X Loop
	tst	Flying_Mode(D)
	bne     Arny_Move_X_Flying


	move	Obj_X(a1),d0
	move	Obj_Y(a1),d1
                  addq	#6,d0
	add	#14,d1
                  cmp	#1,d6
	bne	.no0
	add	#20,d0
.no0
	bsr	Get_V_Mask_Info
	or	d0,d3
	or	d1,d3
	or	d2,d3
	beq	.no_col
                  move	Obj_X(a1),d0	* stoped
	lsl	#6,d0
	move	d0,Arny_X(D)
	clr	Arny_Speed_X(D)
	bra	No_Arny_X_Move
.no_col
	move	Obj_X(a1),d0
	move	Obj_Y(a1),d1
	add	#15,d0
	add	#30,d1
                  cmp	#1,d6
	bne	.no
	addq	#1,d0
.no
	bsr	Get_V_Mask_Info	* use d0-d4,a0
                  tst	d0
	beq     .no_stop
                  move	Obj_X(a1),d0	* stoped
	lsl	#6,d0
	move	d0,Arny_X(D)
	clr	Arny_Speed_X(D)
	bra	No_Arny_X_Move
.no_stop
	or	d2,d3
	bne	.no_flying
                  st	Flying_Mode+1(D)
.no_flying
	tst	d1
	beq	.no_up
	sub	#64,Arny_Y(D)
	subq	#1,Obj_Y(a1)
	tst	Arny_Speed_X(D)
	bmi	.minus0
	subq	#2,Arny_Speed_X(D)
	bra	.no_up
.minus0
	addq	#2,Arny_Speed_X(D)
.no_up
	tst	d2
	bne	.no_Down
	add	#64,Arny_Y(D)
	addq	#1,Obj_Y(a1)
	tst	Arny_Speed_X(D)
	bmi	.minus1
	addq	#2,Arny_Speed_X(D)
	bra	.no_down
.minus1
	subq	#2,Arny_Speed_X(D)
.no_down
	bra	Arny_Move_X_Loop_End


Arny_Move_X_Flying
	move	Obj_X(a1),d0
	move	Obj_Y(a1),d1
                  add	#15,d0
	add	#31,d1
                  cmp	#1,d6
	bne	.left

	bsr	Get_H_Mask_Info
	tst	d0
	bne     Arny_Move_X_Loop_End
	tst	d1
	beq     Arny_Move_X_Loop_End
                  move	Obj_X(a1),d0	* stoped
	lsl	#6,d0
	move	d0,Arny_X(D)
	clr	Arny_Speed_X(D)
	bra	No_Arny_X_Move
.left
	bsr	Get_H_Mask_Info
	tst	d0
	beq     Arny_Move_X_Loop_End
	tst	d1
	bne     Arny_Move_X_Loop_End
                  move	Obj_X(a1),d0	* stoped
	lsl	#6,d0
	move	d0,Arny_X(D)
	clr	Arny_Speed_X(D)
	bra	No_Arny_X_Move


Arny_Move_X_Loop_End
	add	d6,Obj_X(a1)

          	dbra	d5,Arny_Move_X_Loop
No_Arny_X_Move



* Arny's Jump
* -----------


	tst	Joy_Fire(D)
	beq	.no_init
	tst     Flying_Mode(D)
	bne	.no_init
	tst	Jump_Step(D)
	bne	.no_init
                  addq	#1,Jump_Step(D)
.no_init

	tst	Jump_Step(D)
	beq	No_Jump
	addq	#1,Jump_Step(D)
	cmp	#4,Jump_Step(D)
	bne	.no_fly
	st	Flying_Mode+1(D)
.no_fly
	cmp	#10,Jump_Step(D)
	bne	.no_end
       	clr	Jump_Step(D)
	bra	No_Jump
.no_end
                  sub	#64,Arny_Speed_Y(D)
No_Jump



* Game Main Loop End
* ------------------


	RLINE	$00f

	bra	Main_loop

