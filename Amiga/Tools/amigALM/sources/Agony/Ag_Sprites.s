
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                         SPRITES & 50 Hz PART                            *
*                         --------------------                            *
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






* DEMO
* ----


	IFEQ	ASM_Demo_Mode=2
JoyFire	EQU	$bfe001
JoyMove	EQU	Joy1dat+Custom
	ENDC

	IFNE	ASM_Demo_Mode=1	* RECORD
                  move.b	JoyMove,d0
	and	#%11,d0
                  move.b	JoyMove+1,d1
	and	#%11,d1
                  add	d1,d1
                  add	d1,d1
	or	d1,d0
	btst	#7,JoyFire
	beq	.skip
	bset	#4,d0
.skip
                  move.l	Demo_Track_Ptr,a0
	move.b	d0,(a0)
                  addq.l	#1,Demo_Track_Ptr
	ENDC

	IFNE	ASM_Demo_Mode=2	* PLAY
                  move.l	Demo_Track_Ptr,a0
	move.b	(a0),d0
                  addq.l	#1,Demo_Track_Ptr
	clr	JoyFire
	btst	#4,d0
	beq	.skip
	bset	#7,JoyFire
.skip
	and	#%1111,d0
	move	d0,d1
                  lsr	#2,d1
	move.b	d0,JoyMove
	move.b	d1,JoyMove+1
	ENDC



* SORCERER
* --------


	tst	Icones_Mode(D)
	bne	No_Axe_Anim
	tst	Life
	beq	.no
	tst	Die(D)
	beq     .yes
.no
	lea	Good_Col_List(D),a0
	moveq	#-1,d0		* COLISION UPDATE
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	bra	No_Axe_Anim
.yes
	tst	Pause2(D)
	bne     No_Sorcerer_Anim
	tst	Quit_Delay(D)
	bne     .no_up
                  moveq	#0,d0	* JOYSTICK TEST
                  moveq	#0,d6
	move.b	JoyMove,d0
	move.b	JoyMove+1,d5

	move	d5,d2
	lsr	#1,d2
	move	d0,d4
	lsr	#1,d4
	btst	#0,d2
	beq	.no_right
	cmp	#280-32+256,Sorcerer_X(D)
	bge	.no_left
	addq	#3,Sorcerer_X(D)	* Right
	st      d6
	bra	.no_left
.no_right
	btst	#0,d4
	beq	.no_left
	cmp	#256,Sorcerer_X(D)
	ble	.no_left
	st      d6
	subq	#3,Sorcerer_X(D)	* Left
.no_left
	eor	d5,d2
	btst	#0,d2
	beq	.no_down
	cmp	#192-60+256,Sorcerer_Y(D)
	bge	.no_up
	Addq	#3,Sorcerer_Y(D)	* Down
	bra	.no_up
.no_down
	eor	d0,d4
	btst	#0,d4
	beq	.no_up
                  cmp	#256-20,Sorcerer_Y(D)
	ble	.no_up
	subq	#3,Sorcerer_Y(D)	* Up
.no_up
	lea	Good_Col_List(D),a0
	move	Sorcerer_X(D),d0		* COLISION UPDATE
	move	Sorcerer_Y(D),d1
	move	d0,(a0)+
	add	#37,d1
	move	d1,(a0)+
	add	#32,d0
	move	d0,(a0)+
	add	#16,d1
	move	d1,(a0)+

	tst	d6
	beq	.zero
	cmp	#10,Axe_Delay(D)
                  beq	.cont
	addq	#1,Axe_Delay(D)
	bra	.cont
.zero
	clr	Axe_Delay(D)
	clr	Axe_Move(D)
.cont

	eor	#1,Sorcerer_Delay(D)	* SHAPE ANIM
	beq     No_Sorcerer_Anim
	add	#12,Sorcerer_Shape(D)
	add	#8,Sorcerer2_Shape(D)
	cmp	#16*12,Sorcerer_Shape(D)
	bne	No_Sorcerer_Anim
	clr	Sorcerer_Shape(D)
	clr	Sorcerer2_Shape(D)
No_Sorcerer_Anim
                                              * UPDATE SPR 0,1,2 & 3
                  lea	Sorcerer_Dat,a0
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	move.l	a0,a4
                  add     Sorcerer_Shape(D),a0
	move	(a0)+,d5	d5 y1
	move	(a0)+,d6	d6 h
                  add	(a0)+,a1
                  add	(a0)+,a2
                  add	(a0)+,a3
                  add	(a0)+,a4

	move.l	a1,Spr0ptB(D)
	move.l	a2,Spr1ptB(D)
	move.l	a3,Spr2ptB(D)
	move.l	a4,Spr3ptB(D)

                  IFNE	ASM_VDO_Mode=1
	cmp	#270,Sorcerer_Y(D)
	bge	.good
	add.l	#8*4,Spr0ptB(D)
	add.l	#8*4,Spr1ptB(D)
	add.l	#8*4,Spr2ptB(D)
	add.l	#8*4,Spr3ptB(D)
.good
	ENDC

	moveq	#0,d0
	moveq	#0,d3
                  move	Axe_Up_Y(D),d0
	sub	#256-SPR_Y_OFF,d0
	move	d0,d2
	lsl	#8,d0
                  move	Axe_Up_X(D),d1
	sub	#256-$90,d1
	tst	Axe_Up_On
	bne	.ok
	moveq	#0,d1
.ok
	move	d1,d4
	lsr	#1,d1
	move	d0,d3
	or	d1,d0
	add	#8,d1
	or	d1,d3
	swap	d0
	swap	d3
	add	#7,d2	*
	lsl	#8,d2
	or	d2,d0
	or	d2,d3
	and	#1,d4
                  or	d4,d0
                  or	d4,d3
                  or	#$80,d0
                  or	#$80,d3
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d3,(a3)+
	move.l	d3,(a4)+
	lea	7*4(a1),a1
	lea	7*4(a2),a2
	lea	7*4(a3),a3
	lea	7*4(a4),a4

	moveq	#0,d0
	moveq	#0,d3
                  move	Sorcerer_Y(D),d0
	sub	#256-SPR_Y_OFF,d0
	add	d5,d0
	move	d0,d2
	lsl	#8,d0
                  move	Sorcerer_X(D),d1
	sub	#256-$90,d1
	tst	Sorcerer_On(D)
	bne	.ok2
	moveq	#0,d1
.ok2
	move	d1,d4
	lsr	#1,d1
	move	d0,d3
	or	d1,d0
	add	#8,d1
	or	d1,d3
	swap	d0
	swap	d3
	add	d6,d2	*
	lsl	#8,d2
	or	d2,d0
	or	d2,d3
	and	#1,d4
                  or	d4,d0
                  or	d4,d3
                  or	#$80,d0
                  or	#$80,d3
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d3,(a3)+
	move.l	d3,(a4)+
	add	d6,d6
	add	d6,d6
	add	d6,a1
	add	d6,a2
	add	d6,a3
	add	d6,a4

	moveq	#0,d0
	moveq	#0,d3
                  move	Axe_Down_Y(D),d0
	sub	#256-SPR_Y_OFF,d0
	move	d0,d2
	lsl	#8,d0
                  move	Axe_Down_X(D),d1
	sub	#256-$90,d1
	tst	Axe_Down_On
	bne	.ok3
	moveq	#0,d1
.ok3
	move	d1,d4
	lsr	#1,d1
	move	d0,d3
	or	d1,d0
	add	#8,d1
	or	d1,d3
	swap	d0
	swap	d3
	add	#7,d2	*
	lsl	#8,d2
	or	d2,d0
	or	d2,d3
	and	#1,d4
                  or	d4,d0
                  or	d4,d3
                  or	#$80,d0
                  or	#$80,d3
	move.l	d0,(a1)
	move.l	d0,(a2)
	move.l	d3,(a3)
	move.l	d3,(a4)

	tst	Quit_Delay(D)
	beq     .no_quit
	bset	#7,JoyFire
.no_quit
                  btst	#7,JoyFire	* FIRE TEST
	bne	No_Fire_Start
	tst	Pause2(D)
	beq	.no_pause_off
	clr     Pause(D)
	clr	Stop(D)
	move	#2,Text_Delay(D)
	and	#%111111111111011,Bpl_con0+2(D)
.no_pause_off
	tst	Pause2(D)
	bne     No_Fire_Start

	addq	#1,Fire_Count(D)
	cmp	#Fw_F_Off,Fw_Fire_Step(D)
	bne	No_Fire_Start
	tst	Fw_Fire_Off(D)
	bne	No_Fire_Start
                  clr	Fw_Fire_Step(D)     * START FIRE
	move	#2,Sound0_Req(D)
	move    #50,Sound0_Vol_Req(D)
	bsr	Sound_Start
	clr	Fw_Fire_Phase(D)
No_Fire_Start
                  btst	#7,JoyFire	* FIRE TEST
	beq     .no
	clr	Fire_Count(D)
.no
	tst	Menu_Mode
	beq	No_Icones_Menu
	cmp	#2,Curent_Spell(D)
	beq     No_Icones_Menu
	cmp     #30,Fire_Count(D)
	bne     No_Icones_Menu
	tst	Quit_Delay(D)
	bne     No_Icones_Menu
	move	Curent_Spell(D),Safe_Cur_Spell(D)
                  st	Pause+1(D)
	st	Stop+1(D)
	st	Icones_Mode+1(D)
	move	#24*2,Arow_y(D)
	clr	Icones_Fire_Up(D)
No_Icones_Menu



* FORWARD FIRE
* ------------


	tst	Pause2(D)
	bne     No_Axe_Anim

	lea	Good_Col_List+8(D),a3                 * COLISION UPDATE

	move	Fw_Fire_Step(D),d0
	cmp	#Fw_F_Off,d0
	bne	.fire_on

	moveq	#-1,d1
	move.l	d1,(a3)+
	move.l	d1,(a3)+
	lea	Empty_Spr(D),a0
	move.l	a0,Spr4ptB(D)
	bra     No_Fw_Fire
.fire_on
	move	Fw_Fire_Weapon,d1
	beq	.fire0
	subq	#1,d1
	beq	.fire1
	subq	#1,d1
	beq	.fire2

	lea	Fw_Fire_Spr+508,a0		* Fire 3

                  move	Sorcerer_X(D),d1
	sub	#256-$90-32,d1
	add	d0,d1
	move	d1,d6
	cmp	#$90+300,d1
	blt	.ok3
	move	#$90+300,d1
.ok3
	lsr	#1,d1

                  move	Sorcerer_Y(D),d0
	cmp	#256,d0
	bgt     .cont31
	move	#256,d0
.cont31
	cmp	#256+192-100+32,d0
	blt	.cont32
	move	#256+192-100+32,d0
.cont32
	sub	#256-SPR_Y_OFF+8,d0
	move	d0,d4
	move	#100-16,d5
	lsl	#8,d0
                  move	d0,d2
	add	#99*256,d2
	bra	.cont
.fire0
	lea	Fw_Fire_Spr,a0		* Fire 0
	clr.l	25*4(a0)

                  move	Sorcerer_X(D),d1
	sub	#256-$90-32,d1
	add	d0,d1
	move	d1,d6
	cmp	#$90+300,d1
	blt	.ok0
	move	#$90+300,d1
.ok0
	lsr	#1,d1

                  move	Sorcerer_Y(D),d0
	cmp	#240,d0
	bgt     .cont01
	move	#240,d0
.cont01
	cmp	#256+192-24+32,d0
	blt	.cont02
	move	#256+192-24+32,d0
.cont02
	sub	#256-SPR_Y_OFF-32,d0
	move	d0,d4
	moveq	#24-16,d5
	lsl	#8,d0
                  move	d0,d2
	add	#23*256,d2
	bra	.cont
.fire1
	lea	Fw_Fire_Spr+25*4,a0		* Fire 1
	clr.l	40*4(a0)

                  move	Sorcerer_X(D),d1
	sub	#256-$90-32,d1
	add	d0,d1
	move	d1,d6
	cmp	#$90+300,d1
	blt	.ok1
	move	#$90+300,d1
.ok1
	lsr	#1,d1

                  move	Sorcerer_Y(D),d0
	cmp	#256,d0
	bgt     .cont11
	move	#256,d0
.cont11
	cmp	#256+192-40+32,d0
	blt	.cont12
	move	#256+192-40+32,d0
.cont12
	sub	#256-SPR_Y_OFF-22,d0
	move	d0,d4
	moveq	#40-16,d5
	lsl	#8,d0
                  move	d0,d2
	add	#39*256,d2
	bra	.cont
.fire2
	lea	Fw_Fire_Spr+264,a0		* Fire 2
	clr.l	60*4(a0)

                  move	Sorcerer_X(D),d1
	sub	#256-$90-32,d1
	add	d0,d1
	move	d1,d6
	cmp	#$90+300,d1
	blt	.ok2
	move	#$90+300,d1
.ok2
	lsr	#1,d1

                  move	Sorcerer_Y(D),d0
	cmp	#256,d0
	bgt     .cont21
	move	#256,d0
.cont21
	cmp	#256+192-60+32,d0
	blt	.cont22
	move	#256+192-60+32,d0
.cont22
	sub	#256-SPR_Y_OFF-12,d0
	move	d0,d4
	moveq	#60-16,d5
	lsl	#8,d0
                  move	d0,d2
	add	#59*256,d2
.cont
                  or      d1,d0

                  move	d0,(a0)
	move	d2,2(a0)

	move.l	a0,Spr4ptB(D)

	add	#20,Fw_Fire_Step(D)
	eor	#1,Fw_Fire_Phase(D)
	beq	No_Fw_Fire

	add	#256-$90,d6
	move	d6,(a3)+
	add	#256-SPR_Y_OFF+8,d4
	move	d4,(a3)+
	add	#60,d6
	move	d6,(a3)+
	add	d5,d4
	move	d4,(a3)+
No_Fw_Fire



* AXES
* ----


	tst	Quit_Delay(D)
	bne     No_Axe_Anim

                  moveq	#3,d2
                  move	Axe_Delay(D),d1
	beq	.normal
	cmp	#10,d1
	beq     .normal
	tst	Axe_Move(D)
	beq	.normal
	move	#-3,d2
.normal
	move	Sorcerer_X(D),d0
	cmp     Axe_Up_X(D),d0
	beq	.cont
	bls	.less
	add	d2,Axe_Up_X(D)
	add	d2,Axe_Down_X(D)
	bra	.cont
.less
	sub	d2,Axe_Up_X(D)
	sub	d2,Axe_Down_X(D)
.cont
	sub     Axe_Up_X(D),d0
	cmp	#6,d0
	bge	.no
	cmp	#-6,d0
	ble	.no
	st	Axe_Move+1(D)
	move	#1,Axe_Delay(D)
.no
	move	Axe_Up_X(D),d0
	sub	Sorcerer_X(D),d0
	add	#48-2,d0
	lea	Axe_Traj(D),a0
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	move    Sorcerer_Y(D),d0
	sub	d1,d0
                  sub	#18,d0
	move	d0,Axe_Up_Y(D)
	move    Sorcerer_Y(D),d0
	add	d1,d0
                  add	#98,d0
	move	d0,Axe_Down_Y(D)

	cmp     #256-32,Axe_Up_Y(D)
	bge	.ok
	move	#256-32,Axe_Up_Y(D)
.ok
                  lea	Good_Col_List+16(D),a0
	moveq	#-1,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	tst	Axe_Up_On
	beq	.no_up
                  lea	Good_Col_List+16(D),a0
	move	Axe_Up_X(D),d0
	move	Axe_Up_Y(D),d1
	move	d0,(a0)+
	move	d1,(a0)+
	add	#32,d0
	addq	#8,d1
	move	d0,(a0)+
	move	d1,(a0)+
.no_up
	tst	Axe_Down_On
	beq	.no_down
                  lea	Good_Col_List+24(D),a0
	move	Axe_Down_X(D),d0
	move	Axe_Down_Y(D),d1
	move	d0,(a0)+
	move	d1,(a0)+
	add	#32,d0
	addq	#8,d1
	move	d0,(a0)+
	move	d1,(a0)+
.no_down

No_Axe_Anim



* ICONES SPRITES (SPELL MENU)
* ---------------------------


	tst	Icones_Off(D)
	beq     No_Icones_Off
Quit_Icones
	clr	Icones_Off(D)
	clr	Icones_Mode(D)

	lea	Sorcerer_Pal(D),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,Color+32(C)
No_Icones_off

	tst	Icones_Mode(D)
	beq	No_Icones

	move	Arow_Down(D),d0
	or	Arow_Up(D),d0
	bne	.no_up

                  moveq	#0,d0	* JOYSTICK TEST
                  moveq	#0,d6
	move.b	JoyMove,d0
	move.b	JoyMove+1,d5

	move	d5,d2
	lsr	#1,d2
	move	d0,d4
	lsr	#1,d4

	eor	d5,d2
	btst	#0,d2
	beq	.no_down
	cmp	#7,Curent_Spell(D)
	beq	.no_up
	st	Arow_Down+1(D)
	bra	.no_up
.no_down
	eor	d0,d4
	btst	#0,d4
	beq	.no_up
	tst	Curent_Spell(D)
	beq	.no_up
	st      Arow_Up+1(D)
.no_up
	tst	Arow_Down(D)
	beq	.no_down2
                  addq	#2,Arow_Y(D)
.no_down2
	tst	Arow_Up(D)
	beq	.no_up2
                  subq	#2,Arow_Y(D)
.no_up2
	clr     Selection_On(D)
	moveq	#0,d0
	move	Arow_Y(D),d0
                  divu	#24,d0
	swap	d0
	tst	d0
	bne	.no_item
	swap	d0
	move	d0,Curent_Spell(D)
                  addq	#1,d0
	move	d0,Text_Num(D)
	move	#-1,Text_Delay(D)
	clr	Arow_Up(D)
	clr	Arow_Down(D)
	st      Selection_On+1(D)
.no_item
	lea	Icones_Pal(D),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,Color+32(C)

                  lea     Icones_Spr(D),a0	* Icone
	move.l	a0,Spr4ptB(D)
	IFNE	ASM_VDO_Mode=1
	move.b	#$31,(a0)
	ENDC
	lea	768(a0),a0
	move.l	a0,Spr5ptB(D)
	IFNE	ASM_VDO_Mode=1
	move.b	#$31,(a0)
	ENDC
	lea	768(a0),a0
	move.l	a0,Spr6ptB(D)
	IFNE	ASM_VDO_Mode=1
	move.b	#$31,(a0)
	ENDC
	lea	768(a0),a0
	move.l	a0,Spr7ptB(D)
	IFNE	ASM_VDO_Mode=1
	move.b	#$31,(a0)
	ENDC

	move    Arow_Y(D),d0	* Arow
	IFNE	ASM_VDO_Mode=0
	add	#$46,d0
	ELSEIF
	add	#$36,d0
	ENDC
	move	d0,d1
	add	#15,d1
	lsl	#8,d0
	lsl	#8,d1
	or	#$7c,d0
	or	#$80,d1
	swap	d0
	or	d1,d0
	lea	Arow_Spr(D),a0
	move.l  d0,(a0)
	move.l	a0,Spr0ptB(D)
	lea	68(a0),a0
	move.l  d0,(a0)
	move.l	a0,Spr1ptB(D)

	lea	Mask_Spr(D),a0	* Mask
	lea	776(a0),a1
	move.l	a1,Spr3ptB(D)
	move.l	a0,Spr2ptB(D)
	IFNE	ASM_VDO_Mode=1
	move.b	#$31,(a0)
	move.b	#$31,(a1)
	ENDC
	addq	#4,a0
	addq	#4,a1

	lea	Spell_Advailable,a3
	moveq	#7,d0
.yloop
	tst	(a3)+
	beq	.n_advailable
	moveq	#23,d1
.cp_loop0
	clr.l	(a0)+
	clr.l	(a1)+
	dbra	d1,.cp_loop0
	bra	.cont
.n_advailable
	lea	Arow_Spr+140(D),a2
	lea	68(a2),a4
	add	#4*4,a0
	add	#4*4,a1
	moveq	#14,d1
.cp_loop1
	move.l	(a2)+,(a0)+
	move.l	(a4)+,(a1)+
	dbra	d1,.cp_loop1
	add	#5*4,a0
	add	#5*4,a1
.cont
                  dbra	d0,.yloop

                  btst	#7,JoyFire	* FIRE TEST
	beq	.no_fire_up
	st	Icones_Fire_Up+1(D)
.no_fire_up
                  btst	#7,JoyFire	* FIRE TEST
	bne	No_Icones
	tst	Icones_Fire_Up(D)
	beq	No_Icones
	tst     Selection_On(D)
	beq	No_Icones

	lea	Empty_Spr(D),a0
	move.l	a0,Spr0ptB(D)
	move.l	a0,Spr1ptB(D)
	move.l	a0,Spr2ptB(D)
	move.l	a0,Spr3ptB(D)
	move.l	a0,Spr4ptB(D)
	move.l	a0,Spr5ptB(D)
	move.l	a0,Spr6ptB(D)
	move.l	a0,Spr7ptB(D)
	st	Old_Text_Num(D)
	lea	Spell_advailable,a0
	move	curent_spell(D),d0
	add	d0,d0
	tst	(a0,d0.w)
	bne	.spell_ok
	move	Safe_Cur_Spell(D),Curent_Spell(D)
	move	#2,Text_Delay(D)
	clr     Pause(D)
	clr	Stop(D)
	clr	Fire_Count(D)
	st	Icones_off(D)
	bra     No_Icones
.spell_ok                                     * START A SPELL
	clr	(a0,d0.w)
	clr     Pause(D)
	clr	Stop(D)
	clr	Fire_Count(D)
	move	#2,Text_Delay(D)
	move	#50,Spell_Time_Delay(D)
	move	Curent_Spell(D),d0
	add	d0,d0
	lea	Time_Table(D),a0
	move	(a0,d0.w),Spell_Time(D)
	st	Icones_off(D)
	move	Sorcerer_X(D),Sorcerer2_X(D)
	move	Sorcerer_Y(D),Sorcerer2_Y(D)
No_Icones



* SPELL TIME
* ----------

	tst	Pause2(D)
	bne	No_Dec_Spell_Time

	tst	Spell_Time(D)
	beq     No_Dec_Spell_Time

	subq	#1,Spell_Time_Delay(D)
	bne	No_Dec_Spell_Time
	move	#50,Spell_Time_Delay(D)

        	move	#1,d0
	move	Spell_Time(D),d1
	sbcd    d0,d1
	move	d1,Spell_Time(D)

	bne	No_Dec_Spell_Time
	st      Curent_Spell+1(D)
No_Dec_Spell_Time






***************************************************************************

*	S P E L L   R O U T I N E S

***************************************************************************



	move	Icones_Mode(D),d0
	or	Pause2(D),d0
	bne	No_Spell

	st	Sorcerer_On(D)
	clr	Fw_Fire_Off(D)

	lea	Good_Col_List+32(D),a0
	moveq	#-1,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+



* (0) BACK FIRE BALL
* ------------------


                  tst	Curent_Spell(D)
	bne     No_Back_FB

	move.l	#$058f08cf,Color+58(C)
                  st	Color+62(C)
	lea	Good_Col_List+32(D),a1

	sub	#10,Back_FB_X0(D)
	move	Back_FB_X0(D),d0	* d0 x0
	cmp	#-100,d0
	bne	.no_mid
	clr	Back_FB_X1(D)
.no_mid
	sub	#10,Back_FB_X1(D)
	move	Back_FB_X1(D),d1	* d1 x1
	cmp	#-100,d1
	bne	.no_mid2
	clr	Back_FB_X0(D)
.no_mid2
	move	Sorcerer_Y(D),d3
	sub	#256-SPR_Y_OFF-46,d3
	move	d3,d4	* d4 -> d6 = y0 -> y2
	move	d3,d5
	move	d3,d6
	add	d0,d4
	sub	#14,d4
	cmp	#SPR_Y_OFF-16,d4
	bgt	.ok
	move	#SPR_Y_OFF-16,d4
.ok
	sub	d0,d6

	move	Sorcerer_X(D),d2
	add	d2,d0
	move	d0,(a1)+
	move	d4,(a1)
	add	#256-SPR_Y_OFF-46,(a1)+
	move	d0,(a1)
	add	#32,(a1)+
	move	d6,(a1)
	add	#256-SPR_Y_OFF-46+14,(a1)+
                  sub	#256-$90-10,d0

	lea	Back_FB_Spr0(D),a0
	move.l	a0,Spr6ptB(D)
	move	d4,d7
	add	#13,d7
	lsl	#8,d4
	lsl	#8,d7
                  lsr	#1,d0
	or	d0,d4
	move	d4,(a0)+
	move    d7,(a0)+
	lea     52(a0),a0
	move	d5,d7
	add	#5,d7
	lsl	#8,d5
	lsl	#8,d7
	or	d0,d5
	move	d5,(a0)+
	move    d7,(a0)+
	lea     20(a0),a0
	move	d6,d7
	add	#13,d7
	lsl	#8,d6
	lsl	#8,d7
	or	d0,d6
	move	d6,(a0)+
	move    d7,(a0)

	move	d3,d4	* d4 -> d6 = y0 -> y2
	move	d3,d5
	move	d3,d6
	add	d1,d4
	sub	#14,d4
	cmp	#SPR_Y_OFF-16,d4
	bgt	.ok2
	move	#SPR_Y_OFF-16,d4
.ok2
	sub	d1,d6

	add	d2,d1
	move	d1,(a1)+
	move	d4,(a1)
	add	#256-SPR_Y_OFF-46,(a1)+
	move	d1,(a1)
	add	#32,(a1)+
	move	d6,(a1)
	add	#256-SPR_Y_OFF-46+14,(a1)+
                  sub	#256-$90-10,d1

	lea	Back_FB_Spr1(D),a0
	move.l	a0,Spr7ptB(D)
	move	d4,d7
	add	#13,d7
	lsl	#8,d4
	lsl	#8,d7
                  lsr	#1,d1
	or	d1,d4
	move	d4,(a0)+
	move    d7,(a0)+
	lea     13*4(a0),a0
	move	d5,d7
	add	#5,d7
	lsl	#8,d5
	lsl	#8,d7
	or	d1,d5
	move	d5,(a0)+
	move    d7,(a0)+
	lea     5*4(a0),a0
	move	d6,d7
	add	#13,d7
	lsl	#8,d6
	lsl	#8,d7
	or	d1,d6
	move	d6,(a0)+
	move    d7,(a0)
No_Back_FB



* (1) ROTATIVE FIRE BALL
* ----------------------


                  cmp	#1,Curent_Spell(D)
	bne     No_Rot_FB

	move.l	#$0ff90f85,Color+58(C)
	move	#$d40,Color+62(C)

	lea	FBall_3spr0(D),a0
	lea	FBall_3spr1(D),a1
	move.l	a0,Spr6ptB(D)
	move.l	a1,Spr7ptB(D)

	move	Rot_Step(D),d0
	addq	#1,Rot_Step(D)
	cmp	#8,d0
	bne	.ok
	clr	Rot_Step(D)
.ok
	lea	Rot_Table(D),a2
                  lsl	#4,d0
	add	d0,a2

	move	Sorcerer_X(D),d3
	sub	#256-12-$90,d3
	move	Sorcerer_Y(D),d4
	sub	#256-37-SPR_Y_OFF,d4

                  moveq	#3,d5
.loop0
                  move.b  (a2)+,d0
	ext	d0
	add	d3,d0
                  move.b  (a2)+,d1
	ext	d1
	add	d4,d1
	cmp	#SPR_Y_OFF-16,d1
	bgt	.ok1
	add.l	#64,Spr6ptB(D)
.ok1
	move	d1,d2
	add	#15,d2
	lsl	#8,d1
	lsl	#8,d2
	lsr	#1,d0
	or	d0,d1
	move	d1,(a0)+
	move    d2,(a0)+
	lea     60(a0),a0
                  dbra	d5,.loop0

                  moveq	#3,d5
.loop1
                  move.b  (a2)+,d0
	ext	d0
	add	d3,d0
                  move.b  (a2)+,d1
	ext	d1
	add	d4,d1
	cmp	#SPR_Y_OFF-16,d1
	bgt	.ok2
	add.l	#64,Spr7ptB(D)
.ok2
	move	d1,d2
	add	#15,d2
	lsl	#8,d1
	lsl	#8,d2
	lsr	#1,d0
	or	d0,d1
	move	d1,(a1)+
	move    d2,(a1)+
	lea     60(a1),a1
                  dbra	d5,.loop1

	lea	Good_Col_List+32(D),a0
	move	Sorcerer_X(D),d0
	move	Sorcerer_Y(D),d1
	move	d0,d2
	move	d1,d3
	sub	#40,d2
	sub	#60,d3
	move	d2,(a0)+
	move	d3,(a0)+
	add	#120,d2
	add	#20,d3
	move	d2,(a0)+
	move	d3,(a0)+

	move	d0,d2
	move	d1,d3
	add	#100,d2
	sub	#40,d3
	move	d2,(a0)+
	move	d3,(a0)+
	add	#20,d2
	add	#120,d3
	move	d2,(a0)+
	move	d3,(a0)+

	move	d0,d2
	move	d1,d3
	sub	#40,d2
	add	#100,d3
	move	d2,(a0)+
	move	d3,(a0)+
	add	#120,d2
	add	#20,d3
	move	d2,(a0)+
	move	d3,(a0)+

	sub	#60,d0
	sub	#40,d1
	move	d0,(a0)+
	move	d1,(a0)+
	add	#20,d0
	add	#120,d1
	move	d0,(a0)+
	move	d1,(a0)+
No_Rot_FB



* (2) STOP_TIME
* -------------


	cmp	#2,Curent_Spell(D)
	bne     No_Time

	st	Stop+1(D)
                  st	Refresh_Status+1(D)
	st      AF_Off+1(D)

	move.l	#$00000222,Color+58(C)
	move	#$0333,Color+62(C)

	addq	#1,Time_Y(D)
	move	Time_Y(D),d0
	cmp	#$f0,d0
	blt	.ok
	tst	Prg_Pause(D)
	bne	.no
	clr	Stop2(D)
	clr	Stop(D)
.no
	clr	Time_Y(D)
	st      Curent_Spell+1(D)
.ok
	lea	Time_Y_Table(D),a0
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	add	#SPR_Y_OFF-50,d1

	add	#256,Time_Step(D)
	and	#15*256,Time_Step(D)
	move	Time_Step(D),d0
	lea	Time_Spr(D),a0
	add	d0,a0
	lea	32*4(a0),a1
	clr.l	32*4(a1)
	move.l	a0,Spr6ptB(D)
	move.l	a1,Spr7ptB(D)
	move	#($90+240)/2,d0
	lsl	#8,d1
                  move	d1,d2
	add	#256*31,d2
	or	d0,d1
	move	d1,(a0)+
	move	d2,(a0)
	addq	#8,d1
	move	d1,(a1)+
	move	d2,(a1)
No_Time



* (3) SEEKER
* ----------


                  cmp	#3,Curent_Spell(D)
	bne     No_Seeker

	move	#256+180,d3
	move	#256+80,d4
	move	#32767,d5

	lea     AWO_Struct(D),a0	* a0 AWO Dyn Ptr
Seek_Bank_Loop
	move	(a0)+,d0	* d0 Curent Alien Num
                  beq	Seek_Bank_Ignored
	cmp	#-1,d0
	bne	Seek_Bank_Tested
Seek_Bank_Ignored
	lea	16*AWO_Len+2(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	bge     Seek_Bank_End
	bra	Seek_Bank_Loop
Seek_Bank_Tested
	move	(a0)+,d1
	move.l	a0,a1
	add	d1,a0
	subq	#1,d0
.obj_loop
	tst.b	AWO_Alien_Status(a0)
	bne	.obj_end
                  move    AWO_Alien_X(a0),d1
	move	d1,d2
	sub	Sorcerer_X(D),d1
	bpl	.ok
	neg	d1
.ok
	cmp	d1,d5
	ble	.obj_end
	move	d1,d5
	move	d2,d3
	move	AWO_Alien_Y(a0),d4
.obj_end
	lea     AWO_Len(a0),a0
	dbra    d0,.obj_loop
	move.l  a1,a0
	lea	16*AWO_Len(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	beq     Seek_Bank_End
                  bra     Seek_Bank_Loop
Seek_Bank_End
	moveq	#0,d0
	move	Sorcerer2_X(D),d1
	move	Sorcerer2_Y(D),d0

Seek_Speed	SET	2

                  cmp	#256+280,d3
	bgt	.no
	cmp	#256,d3
	blt	.no
	cmp	#256,d4
	blt	.no
	cmp	#256+190,d4
	bgt	.no
                  cmp	d3,d1
	bgt	.plus
	addq	#Seek_Speed,d1
	bra	.cont
.plus
	subq	#Seek_Speed,d1
.cont
	cmp     d4,d0
	bgt	.plus2
	addq	#Seek_Speed,d0
	bra	.cont2
.plus2
	subq	#Seek_Speed,d0
.cont2
	cmp	#256+192-60,d0
	blt	.ok3
	move	#256+192-60,d0
.ok3
	move	d1,Sorcerer2_X(D)
	move	d0,Sorcerer2_Y(D)
.no
	move	d3,d6
                  sub	d1,d6
                  bpl	.ok
	neg	d6
.ok
	cmp	#Seek_Speed,d6
	bgt	.cont3
	move	d3,d1
.cont3
	move	d4,d6
                  sub	d0,d6
                  bpl	.ok2
	neg	d6
.ok2
	cmp	#Seek_Speed,d6
	bgt	.cont4
	move	d4,d0
.cont4
	sub	#16,d1
	sub	#40,d0

	lea	Good_Col_list+32(D),a0
	move	d1,d3
	move	d0,d4
	add	#37,d4
	move	d3,(a0)+
	move	d4,(a0)+
	add	#64,d3
	add	#32,d4
	move	d3,(a0)+
	move	d4,(a0)+

	move.l	#$0ff80fb0,Color+58(C)
	move	#$f60,Color+62(C)

                  lea	Sorcerer2_Dat,a0
	move.l	a0,a1
	move.l	a0,a2
                  add     Sorcerer2_Shape(D),a0
	move	(a0)+,d5	d5 y1
	move	(a0)+,d6	d6 h
                  add	(a0)+,a1
                  add	(a0)+,a2

	move.l	a1,Spr6ptB(D)
	move.l	a2,Spr7ptB(D)

	moveq	#0,d3
;                  move	Sorcerer2_Y(D),d0
	sub	#256-SPR_Y_OFF,d0
	add	d5,d0
	move	d0,d2
	lsl	#8,d0
;                  move	Sorcerer2_X(D),d1
	sub	#256-$90,d1
	move	d1,d4
	lsr	#1,d1
	move	d0,d3
	or	d1,d0
	add	#8,d1
	or	d1,d3
	swap	d0
	swap	d3
	add	d6,d2	*
	lsl	#8,d2
	or	d2,d0
	or	d2,d3
	and	#1,d4
                  or	d4,d0
                  or	d4,d3
	move.l	d0,(a1)
	move.l	d3,(a2)
No_Seeker



* (4) SMART BOMB
* --------------


                  cmp	#4,Curent_Spell(D)
	bne     No_Smart_B

	move.l	#$0ff80fb0,Color+58(C)
	move	#$0f60,Color+62(C)

	add	#157*4,Smart_B_Step(D)
	move	Smart_B_Step(D),d0
	cmp	#157*4*6,d0
	bne	.ok
	moveq	#0,d0
	move	d0,Smart_B_Step(D)
.ok
	lea	Smart_B_Spr(D),a0
	lea	157*4*6(a0),a1
	add	d0,a0
	add	d0,a1

	addq	#1,Smart_B_StepHC(D)
	cmp	#5,Smart_B_StepHC(D)
	bne	.no
	addq	#1,Smart_B_StepH(D)
	clr	Smart_B_StepHC(D)
.no
	move	Smart_B_X(D),d0
	add	Smart_B_StepH(D),d0
	cmp	#128,d0
	ble	.ok2
	moveq	#0,d0
	move	d0,Smart_B_StepH(D)
.ok2
	move	d0,Smart_B_X(D)
                  move	Sorcerer_X(D),d1
	sub	#256-$90,d1
	lsr	#1,d1
	move	d1,d2
	sub	d0,d1
	add	d0,d2
	cmp	#($90+300)/2,d2
	blt	.ok0
	move	#($90+300)/2,d2
.ok0
	add	#32/2,d2
	sub	#16/2,d1
                  move	Sorcerer_Y(D),d0
	cmp	#256+32,d0
	bgt	.ok3
	move	#256+32,d0
.ok3
	cmp	#256+192-156+32,d0
	blt	.ok4
	move	#256+192-156+32,d0
.ok4
	move	d0,d6
	sub	#256-SPR_Y_OFF+30,d0
	lsl	#8,d0
                  move	d0,d3
	add	#156*256,d3
	move	d0,d4
	or	d1,d0
	or	d2,d4
	move	d0,(a0)
	move	d3,2(a0)
	move	d4,(a1)
	move	d3,2(a1)

	move.l	a0,Spr6ptB(D)
	move.l	a1,Spr7ptB(D)

	lea	Good_Col_List+32(D),a0
	move	Sorcerer_X(D),d0
	sub	#30,d6
	move	d0,d2
	move	d6,d3
	move	Smart_B_X(D),d4
	sub	d4,d0
	add	d4,d2
	move	d0,(a0)+
	move	d6,(a0)+
	add	#50,d0
	add	#156,d6
	move	d0,(a0)+
	move	d6,(a0)+
	move	d2,(a0)+
	move	d3,(a0)+
	add	#50,d2
	add	#156,d3
	move	d2,(a0)+
	move	d3,(a0)+
No_Smart_B



* (5) MEGA BLAST
* --------------


                  cmp	#5,Curent_Spell(D)
	bne     No_Mega_B

	move.l	#$0fff0ffc,Color+58(C)
	move	#$0ff8,Color+62(C)

	st	Fw_Fire_Off+1(D)
	st      AF_Off+1(D)

                  lea	Mega_B_Spr(D),a0
	lea	151*4(a0),a1
	lea	151*4(a1),a2
	lea	151*4(a2),a3

	add	#10,Mega_B_X(D)
	and	#127,Mega_B_X(D)
	move	Mega_B_X(D),d0
	move	d0,d5

                  move	Sorcerer_X(D),d1
	move	d1,d3
	sub	#256-$90-32,d1
	lsr	#1,d1
	add	d0,d1
	cmp	#($90+300)/2,d1
	blt	.ok0
	move	#($90+300)/2,d1
.ok0

                  move	Sorcerer_Y(D),d0
	move	d0,d4
	cmp	#256+32,d0
	bgt	.ok3
	move	#256+32,d0
.ok3
	cmp	#256+192-150+32,d0
	blt	.ok4
	move	#256+192-150+32,d0
.ok4
	sub	#256-SPR_Y_OFF+30,d0
	lsl	#8,d0
                  move	d0,d2
	add	#150*256,d2

                  or      d1,d0

                  move	d0,(a0)
	move	d2,2(a0)
	addq	#8,d0
                  move	d0,(a1)
	move	d2,2(a1)
	addq	#8,d0
                  move	d0,(a2)
	move	d2,2(a2)
	addq	#8,d0
                  move	d0,(a3)
	move	d2,2(a3)

	move.l  a0,Spr6ptB(D)
	move.l  a1,Spr7ptB(D)
	move.l  a2,Spr4ptB(D)
	move.l  a3,Spr5ptB(D)

	lea	Good_Col_List+32(D),a0
                  add	d5,d5
	add	d5,d3
	move	d3,(a0)+
	move	d4,(a0)+
	add	#64,d3
	add	#150,d4
	move	d3,(a0)+
	move	d4,(a0)+
No_Mega_B



* (6) SHIELD
* ----------


                  cmp	#6,Curent_Spell(D)
	bne     No_Shield

	move.l	#$0fff07df,Color+58(C)
	move	#$08f,Color+62(C)

	clr	Sorcerer_On(D)

                  lea	Sorcerer2_Dat,a0
	move.l	a0,a1
	move.l	a0,a2
                  add     Sorcerer2_Shape(D),a0
	move	(a0)+,d5	d5 y1
	move	(a0)+,d6	d6 h
                  add	(a0)+,a1
                  add	(a0)+,a2

	moveq	#0,d0
	moveq	#0,d3
                  move	Sorcerer_Y(D),d0
	sub	#256-SPR_Y_OFF+10,d0
	add	d5,d0
	move	d0,d2
	lsl	#8,d0
                  move	Sorcerer_X(D),d1
	sub	#256-$90,d1
	move	d1,d4
	lsr	#1,d1
	move	d0,d3
	or	d1,d0
	add	#8,d1
	or	d1,d3
	swap	d0
	swap	d3
	add	d6,d2	*
	cmp	#255,d2
	ble	.ok
	moveq	#255,d2
.ok
	lsl	#8,d2
	or	d2,d0
	or	d2,d3
	and	#1,d4
                  or	d4,d0
                  or	d4,d3
	move.l	d0,(a1)
	move.l	d3,(a2)

	move.l	a1,Spr6ptB(D)
	move.l	a2,Spr7ptB(D)

No_Shield



* (7) FORWARD FIRE BALL
* ---------------------


                  cmp	#7,Curent_Spell(D)
	bne     No_Fw_FB

	move.l	#$0ff90fb7,Color+58(C)
	move	#$f85,Color+62(C)
	lea	Good_Col_List+32(D),a3

	addq	#8,Fw_FB_X0(D)
	move	Fw_FB_X0(D),d0	* d0 x0
	cmp	#128,d0
	bne	.no_mid
	clr	Fw_FB_X1(D)
.no_mid
	addq	#8,Fw_FB_X1(D)
	move	Fw_FB_X1(D),d1	* d1 x1
	cmp	#128,d1
	bne	.no_mid2
	clr	Fw_FB_X0(D)
.no_mid2
	lea     Sin_Table(D),a1
	move.l	a1,a2
                  move	d0,d3
	lsr	#3,d3
	add	d3,a1
                  move	d1,d3
	lsr	#3,d3
	add	d3,a2

	move	Sorcerer_Y(D),d3
	sub	#256-SPR_Y_OFF-46,d3
	move	d3,d4	* d4 -> d5 = y0 -> y1
	move	d3,d5
	moveq	#0,d6
	move.b	(a1),d6
                  sub	d6,d4
	cmp	#SPR_Y_OFF-16,d4
	bgt	.ok
	move	#SPR_Y_OFF-16,d4
.ok
	add	d6,d5

	move	Sorcerer_X(D),d2
                  sub	#256-$90-10,d2
	add	d2,d0
	cmp	#$90+300,d0
	blt	.ok0
	move	#$90+300,d0
.ok0
	add	d2,d1
	cmp	#$90+300,d1
	blt	.ok1
	move	#$90+300,d1
.ok1

	lea	FW_FB_Spr0(D),a0
	move.l	a0,Spr6ptB(D)
	move	d4,d7

	move	d0,(a3)
	add	#256-$90,(a3)+
	move	d4,(a3)
	add	#256-SPR_Y_OFF,(a3)+
	move	-4(a3),(a3)
                  add	#32,(a3)+
	move	-4(a3),(a3)
                  add	#16,(a3)+

	add	#15,d7
	lsl	#8,d4
	lsl	#8,d7
                  lsr	#1,d0
	or	d0,d4
	move	d4,(a0)+
	move    d7,(a0)+
	lea     60(a0),a0
	move	d5,d7

	move	-8(a3),(a3)+
	move    d5,(a3)
	add	#256-SPR_Y_OFF,(a3)+
	move	-8(a3),(a3)+
	move	-4(a3),(a3)
                  add	#16,(a3)+

	add	#15,d7
	lsl	#8,d5
	lsl	#8,d7
	or	d0,d5
	move	d5,(a0)+
	move    d7,(a0)+
	lea     60(a0),a0
	clr.l	(a0)

	move	d3,d4	* d4 -> d5 = y0 -> y1
	move	d3,d5
	moveq	#0,d6
	move.b	(a2),d6
                  sub	d6,d4
	cmp	#SPR_Y_OFF-16,d4
	bgt	.ok2
	move	#SPR_Y_OFF-16,d4
.ok2
	add	d6,d5

	lea	FW_FB_Spr1(D),a0
	move.l	a0,Spr7ptB(D)
	move	d4,d7

	move	d1,(a3)
	add	#256-$90,(a3)+
	move	d4,(a3)
	add	#256-SPR_Y_OFF,(a3)+
	move	-4(a3),(a3)
                  add	#32,(a3)+
	move	-4(a3),(a3)
                  add	#16,(a3)+

	add	#15,d7
	lsl	#8,d4
	lsl	#8,d7
                  lsr	#1,d1
	or	d1,d4
	move	d4,(a0)+
	move    d7,(a0)+
	lea     60(a0),a0
	move	d5,d7

	move	-8(a3),(a3)+
	move    d5,(a3)
	add	#256-SPR_Y_OFF,(a3)+
	move	-8(a3),(a3)+
	move	-4(a3),(a3)
                  add	#16,(a3)+

	add	#15,d7
	lsl	#8,d5
	lsl	#8,d7
	or	d1,d5
	move	d5,(a0)+
	move    d7,(a0)+
	lea     60(a0),a0
	clr.l	(a0)
No_Fw_FB



* (-1) SPELL OFF
* --------------


                  cmp.b	#-1,Curent_Spell+1(D)
	bne	No_Spell

	tst	Rain_On(D)
	bne	No_Spell
                  lea	Empty_Spr(D),a0
	move.l	a0,Spr6ptB(D)
	move.l	a0,Spr7ptB(D)
No_Spell



* MAIN CHAR DIE
* -------------


	tst	Die(D)
	beq	No_Die

	tst	Quit_Delay(D)
	bne	No_Die

	move	Die_Mode(D),d0
	beq	Die_mode0
	subq	#1,d0
	beq	Die_mode1

Die_mode0			* INIT EXPLO
	lsr	Life
	bne	.no_Game_Over
	move	#11,Text_Num(D)
	move	#-1,Text_Delay(D)
.No_Game_Over
	clr	Bonus_Mode(D)
	lea	Die_Table(D),a0
	lea	Die_Dyn_Ptr(D),a1
;	lea	Die_Spr,a4
;	lea	Spr0ptB(D),a3
                  move.l	a0,d1
                  moveq	#7,d0
.init0_loop
	move	(a0)+,a2
	add.l	d1,a2
	move.l	a2,(a1)+
;	move.l  a4,(a3)+
;	lea	33*4(a4),a4
	dbra	d0,.init0_loop

	clr	Sorcerer_On(D)
	st	Curent_Spell+1(D)
	st	Fw_Fire_Off(D)
	st      AF_Off+1(D)
	clr	Stop(D)

	move.l	#$0fff0cbe,Color+34(C)
	move	#$087a,Color+38(C)
	move.l	#$0fff0db9,Color+42(C)
	move	#$0975,Color+46(C)
	move.l	#$0cbe087a,Color+50(C)
	move	#$0547,Color+54(C)
	move.l	#$0db90975,Color+58(C)
	move	#$0755,Color+62(C)

	move	Sorcerer_X(D),d3
	move	Sorcerer_Y(D),d4
	sub	#256-$90-16,d3
	sub	#256-SPR_Y_OFF-42,d4
	move	d3,Die_X(D)
	move	d4,Die_Y(D)

	addq	#1,Die_Mode(D)
	bra	No_Die
Die_mode1
	clr	Sorcerer_On(D)

	lea	Die_Spr,a0
	lea	Die_Dyn_Ptr(D),a1
	lea	Spr0ptB(D),a3
	move	Die_X(D),d3
	move	Die_Y(D),d4
	moveq	#0,d6
	moveq	#7,d0
.loop
	move.l	(a1)+,d1
	bpl	.cont
	addq	#1,d6
	bra	.no
.cont
	move.l	d1,a2
                  addq.l	#2,-4(a1)
	move.b  (a2)+,d1
	cmp.b	#$80,d1
	bne	.ok
	move.l	#-1,-4(a1)
	bra	.no
.ok
	move.b  (a2),d2
	ext	d1
	ext	d2
	add	d3,d1
	add	d4,d2
	cmp	#256,d2
	blt	.ok2
	move.l	#-1,-4(a1)
.ok2
	lsl	#8,d2
	move	d2,d5
	add	#256*32,d5
	lsr	#1,d1
	or	d1,d2
	move.l	a0,(a3)
	move	d2,(a0)
	move	d5,2(a0)
.no
	lea     4(a3),a3
	lea	33*4(a0),a0
	dbra	d0,.loop

	cmp	#8,d6
	bne	.cont2
	tst	Life
	bne	.no_quit
	move	#50,Quit_Delay(D)
                  lea	Empty_Spr(D),a0
	move.l	a0,Spr0ptB(D)
	move.l	a0,Spr1ptB(D)
	move.l	a0,Spr2ptB(D)
	move.l	a0,Spr3ptB(D)
	move.l	a0,Spr4ptB(D)
	move.l	a0,Spr5ptB(D)
	move.l	a0,Spr6ptB(D)
	move.l	a0,Spr7ptB(D)
                  clr	Die(D)
	st	Clean_up(D)
	bra     .end
.no_quit
	subq	#1,Fw_Fire_Weapon
	bpl	.ok3
	clr	Fw_Fire_Weapon
.ok3
	tst	Axe_Down_on
	bne	.skip
	clr	Axe_Up_on
.skip
	clr	Axe_Down_on

                  clr	Die(D)
	clr	Fw_Fire_Off(D)
	move	#6,Curent_Spell(D)
	move	#3,Spell_Time(D)
	move	#50,Spell_Time_Delay(D)
.end
	lea	Sorcerer_Pal(D),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,Color+32(C)
.cont2

No_Die



* BONUS
* -----


	tst.b   Curent_Spell+1(D)
	bmi	.no_spell
	clr	Bonus_Mode(D)
.no_spell
                  move	Bonus_Mode(D),d0
	bne	.no_mode0
	tst	Stop2(D)
	bne	Bonus_End
	addq	#1,Bonus_Delay(D)
	cmp	#2000,Bonus_Delay(D)
	ble     Bonus_End
	tst	Die(D)
	bne	Bonus_End
	tst.b   Curent_Spell+1(D)
	bpl	Bonus_End
	tst	Stop2(D)
	bne	Bonus_End
	move	#1,Bonus_Mode(D)		* Bonus Start
	clr	Rain_On(D)
	clr	Bonus_Delay(D)
                  cmp	#1,Fw_Fire_Weapon
	bgt	.next
	move	#2,Bonus_Num(D)
	bra	Bonus_End
.next
	cmp	#1,Life
	bgt	.next2
	cmp.l	#$40000,Extra_Life
	blt	.next2
	move	#1,Bonus_Num(D)
	bra	Bonus_End
.next2
	tst	Axe_Up_On
	bne     .next3
	clr	Bonus_Num(D)
	bra	Bonus_End
.next3
                  cmp	#2,Fw_Fire_Weapon
	bne     .next4
	move	#2,Bonus_Num(D)
	bra	Bonus_End
.next4
	tst	Axe_Down_On
	bne     .next5
	move	#11,Bonus_Num(D)
	bra	Bonus_End
.next5


	lea	Spell_Pri(D),a0
	lea	Spell_Advailable,a1
	moveq	#0,d1
.a_loop
	move	Spell_Next_Bonus,d0
	add	d0,d0
	addq	#1,Spell_Next_Bonus
	and	#$7,Spell_Next_Bonus
	move	(a0,d0.w),d0
	move	d0,d2
	add	d2,d2
	tst	(a1,d2.w)
	beq	.found
	addq	#1,d1
	cmp	#9,d1
	bne	.a_loop

	move	#1,Bonus_Num(D)
	bra	Bonus_End
.found
	addq	#3,d0
	move	d0,Bonus_Num(D)
	bra	Bonus_End
.no_mode0
	cmp	#1,d0
	beq     Bonus_End

	cmp	#2,d0
	bne     .no_fall
	tst	Pause2(D)
	bne     .paused0
	subq	#1,Bonus_X(D)
.paused0
                  move	Bonus_X(D),d0
	cmp	#240,d0
	ble	.close
	tst	Pause2(D)
	bne     .paused1
	addq	#2,Bonus_Y(D)
.paused1
                  move	Bonus_Y(D),d1
	cmp	#256+166,d1
	blt	.cont3
	move	#3,Bonus_Mode(D)
.cont3
	bra .display
.no_fall
	cmp	#3,d0
	bne     Bonus_End
	tst	Pause2(D)
	bne     .paused2
	subq	#1,Bonus_X(D)
.paused2
                  move	Bonus_X(D),d0
	cmp	#240,d0
	ble	.close
                  move	#256+166,d1
.display
	move	Sorcerer_X(D),d3
	move	Sorcerer_Y(D),d4
	add	#40,d4
	move	d3,d5
	move	d4,d6
	sub	#16,d3	* x1
	sub	#50,d4	* y1
	add	#50,d5	* x2
	add	#30,d6	* y2
	cmp	d5,d0
	bgt	.no_col
                  cmp	d3,d0
	blt	.no_col
                  cmp     d6,d1
	bgt	.no_col
	cmp     d4,d1
	blt	.no_col
			* Bonus attribution
	move	#0,Sound0_Req(D)
	move    #63,Sound0_Vol_Req(D)
	bsr	Sound_Start
	move.l	#$258,Point(D)
	move	Bonus_Num(D),d2
	bne	.no_sword_u
                  st	Axe_Up_On
	move    Sorcerer_X(D),Axe_Down_X(D)
	move    Sorcerer_X(D),Axe_Up_X(D)
	bra	.close
.no_sword_u
	cmp	#11,d2
	bne	.no_sword_d
                  st	Axe_Down_On
	move    Sorcerer_X(D),Axe_Down_X(D)
	move    Sorcerer_X(D),Axe_Up_X(D)
	bra	.close
.no_sword_d
	cmp	#1,d2
	bne	.no_money
                  move.l	#$20000,Point(D)
	bra	.close
.no_money
	cmp	#2,d2
	bne	.no_fire
                  cmp	#3,Fw_Fire_Weapon
	beq	.close
                  addq	#1,Fw_Fire_Weapon
	bra	.close
.no_fire
	sub	#3,d2
	add	d2,d2
	lea	Spell_Advailable,a0
	move	#1,(a0,d2.w)
	bra	.close
.no_col
	sub	#256-$80,d0
	sub	#256-SPR_Y_OFF+22,d1
	lea	Bonus_Image(D),a0
	move	Bonus_Num(D),d2
	add	d2,d2
	move	(a0,d2.w),d2

	move	#$f00,Color+58(C)
	move	d2,d3
	bne	.no_0
	move.l	#$0bbb0888,Color+60(C)
                  bra	.cont2
.no_0
	subq	#1,d3
	bne	.no_1
	move.l	#$0e920b72,Color+60(C)
                  bra	.cont2
.no_1
	subq	#1,d3
	bne	.no_2
	move.l	#$00500070,Color+60(C)
                  bra	.cont2
.no_2
	move.l	#$0a860753,Color+60(C)
.cont2
	lea     Bonus_Spr,a0
	lea	Bonus_Shape(D),a1
	add	d2,d2
	add	(a1,d2.w),a0
	addq	#1,Bonus_Anim(D)
	btst	#3,Bonus_Anim+1(D)
	beq	.cont
	tst	Pause2(D)
	bne     .cont
	lea	400(a0),a0
.cont
	lea	200(a0),a1
	move.l	a0,Spr6ptB(D)
	move.l	a1,Spr7ptB(D)
	lsl	#8,d1
	move	d1,d2
	add	#$3080,d2
                  move	d0,d3
	and	#1,d3
	or	d3,d2
	lsr	#1,d0
	or	d0,d1
	move	d1,(a0)+
	move	d2,(a0)+
	move	d1,(a1)+
	move	d2,(a1)+
	bra	Bonus_End
.close
	lea	Empty_Spr(D),a0
	move.l	a0,Spr6ptB(D)
	move.l	a0,Spr7ptB(D)
	move.l	a0,Spr6pt(D)
	move.l	a0,Spr7pt(D)
	clr	Bonus_Mode(D)
Bonus_End


* ALIEN FIRE X DEC
* ----------------



	cmp	#2,Curent_Spell(D)
	beq     AFXD_End
	cmp	#5,Curent_Spell(D)
	beq     AFXD_End
                  tst	Pause(D)
	bne	AFXD_End
	tst	Die(D)
	bne	AFXD_End
	tst	Icones_Mode(D)
	bne	AFXD_End

	lea	Alien_Fire_Spr,a0
	move.l	a0,Spr5ptB(D)
	moveq	#11,d0
AFXD_Loop
	tst.l	(a0)
	beq	.end
	move	(a0)+,d1
	move	(a0)+,d2
	and	#$ff,d1
                  lsl	#1,d1
	and	#1,d2
	or	d2,d1	* d1 x
	subq	#1,d1
	move	d1,d2
	lsr	#1,d1
	and	#1,d2
	move.b	d1,-3(a0)
	move.b	d2,-1(a0)
	lea	32(a0),a0
	dbra	d0,AFXD_Loop
	bra	AFXD_End
.end
	lea	36(a0),a0
	dbra	d0,AFXD_Loop
AFXD_End



* UPDATE SPRITES PTR IN CL
* ------------------------


	lea	Spr_Ptr+2(D),a0
	move.l	Spr0ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	lea	8(a0),a0

	move.l	Spr1ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	lea	8(a0),a0

	move.l	Spr2ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	lea	8(a0),a0

	move.l	Spr3ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	lea	8(a0),a0

	move.l	Spr4ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	lea	8(a0),a0

	move.l	Spr5ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	lea	8(a0),a0

	move.l	Spr6ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	lea	8(a0),a0

	move.l	Spr7ptB(D),d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)



