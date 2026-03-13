
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      A R N Y ' S   D R E A M S	            *
*                      ===========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                           GAME INIT MODULE                              *
*                           ----------------                              *
*                                                                         *
*                                                                         *
***************************************************************************



* Init Level
* ----------


	lea	Obj_Struct(D),a0
	move.l	a0,a2
	moveq	#-1,d1
	move	#((Obj_Sizeof*Obj_Num)/4)-1,d0
Clr_Obj_Loop
	move.l	d1,(a0)+
	dbra	d0,Clr_Obj_Loop

	lea	World_Dat,a1
	move.l	a1,a0
	move	Curent_Level(D),d0
	add	d0,d0
	add     4(a0,d0.w),a0
	move.l	a0,Level_Data_Ptr(D)
                  add	LD_Map_Off(a0),a1
	move	LD_Char_Num(a0),d0

	move	(a0)+,d1	* Init Arny
	move	d1,Obj_X(a2)
	lsl	#6,d1
	move	d1,Arny_X(D)
	move	(a0)+,d1
	move	d1,Obj_Y(a2)
	lsl	#6,d1
	move	d1,Arny_Y(D)
	move	#1,Obj_Id(a2)

	move	(a0)+,Ball_X(D)
	move	(a0)+,Ball_Y(D)
	move	(a0)+,Exit_X(D)
	move	(a0)+,Exit_Y(D)
	move	(a0),Level_Time(D)

	subq	#1,d0
Build_Map_Loop
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.b  (a1)+,d1	* d1 char x
	move.b  (a1)+,d2	* d2 char y
	move.b  (a1)+,d3
	btst	#0,d3
	beq	.cont0
	bset	#8,d1
.cont0
	btst	#1,d3
	beq	.cont1
	bset	#8,d2
.cont1
	move.b  (a1)+,d3	* d3 char Id

	H_BLIT_CHAR

	dbra	d0,Build_Map_Loop



* Open Screen
* -----------


	moveq	#0,d0
	move	d0,Camera_X(D)
	move	d0,Camera_Y(D)
	move	d0,Camera_Mode(D)
	move	d0,Flying_Mode(D)

	bsr	Update_Camera

	H_INIT_SCREEN



