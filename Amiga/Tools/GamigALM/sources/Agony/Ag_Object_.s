
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                           OBJECTS  MODULE                               *
*                           ---------------                               *
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



* RESTORE CURENT BUILD SCREEN
* ---------------------------



;	REPT	16
;	st	$dff180
;	ENDR
;	clr	$dff180

	move.l	Rest_Screen_Ptr(D),Bltapt(C)
	move.l	Cur_Front_Build(D),Bltdpt(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	move.l	#$40004,Bltamod(C)
	move.l	#$09f00000,Bltcon0(C)
	REPT    8
	move	#64*(192/4)+20,Bltsize(C)
	WAIT_BLIT
	ENDR
	move	#64*192+20,Bltsize(C)
	WAIT_BLIT

;	REPT	16
;	st	$dff180
;	ENDR
;	clr	$dff180






***************************************************************************

*	ALIEN (Object+Ctrl) DISPLAY

***************************************************************************



* ALIEN BANK CTRL
* ---------------


	eor     #1,Flash_Phase(D)
	move	Front_Shift(D),Front_Shift_Phase(D)
	lea	AWO_Struct(D),a0
Alien_Bank_Loop
	move	(a0)+,d0
                  beq	Bank_Ignored
	cmp	#-1,d0
	bne	Bank_To_Display
Bank_Ignored
	lea	16*AWO_Len+2(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	bge     Alien_Bank_End
	bra	Alien_Bank_Loop
Bank_To_Display
	move	(a0)+,d1
	move.l	a0,Curent_Bank_Ptr(D)
	add	d1,a0
	move	d0,Curent_Alien_Num(D)
                  clr	Alien_AWO_Count(D)

Alien_AWO_Loop
                  move.l	a0,Curent_Awo_Ptr(D)

	move.b	AWO_Alien_Status(a0),d0
	and	#$00f0,d0
	beq	No_Flash
	cmp	#$00f0,d0
	bne	.no_end
	and.b	#$0f,AWO_Alien_Status(a0)
	bra	No_Flash
.no_end
	add.b	#$10,AWO_Alien_Status(a0)
;	tst     Flash_Phase(D)
;	beq     Object_End
No_Flash



* DRAW OBJECT
* -----------


	move.l	Cur_Front_Build(D),d4
	lea	X44(D),a3
	moveq	#31,d5
	move  	Front_Shift_Phase(D),d0
	addq	#1,d0
	and	#31,d0
	sub     d0,d5
	add	AWO_Alien_X(a0),d5
	move	AWO_Alien_Y(a0),d6
	clr	Cur_Explo_State(D)
	move.b	AWO_Alien_Status(a0),d0
	and	#$f,d0
	beq	.ok
	cmp	#$f,d0
	beq	Object_End
	cmp	#1,Bonus_Mode(D)
	bne	.no_bonus
	move	d5,Bonus_X(D)
	move	d6,Bonus_Y(D)
	move	#2,Bonus_Mode(D)
.no_bonus
	addq.b	#1,AWO_Alien_Status(a0)
                  lea	Explo_Spr_List(D),a1
                  add	d0,d0
	move	(a1,d0.w),Cur_Explo_State(D)
.ok
	move	#256,d0
	sub	d0,d5
	sub	d0,d6
	move	AWO_Alien_Obj_Off(a0),a0
	add.l	#Objects_Struct+4,a0
Object_Loop
	move.b  (a0)+,d0
	ext	d0
	add	d5,d0
	move.b	(a0)+,d1
	cmp.b	#$80,d1
	beq	Object_End
	ext	d1
	add	d6,d1

	moveq	#0,d2
	move.b	(a0)+,d2
	tst     Cur_Explo_State(D)
	beq	.ok
	move	Cur_Explo_State(D),d2
.ok

	lea	Sprites_Struct(D),a1
	add	d2,d2
	add	d2,a1
	add	d2,d2
	add	d2,d2
	add	d2,a1
	add	d2,d2
	add	d2,a1

	moveq	#0,d3
	move.l	d3,d7
	move.b  (a1)+,d3
	move.b  (a1)+,d7
	add	d0,d3
	add	d1,d7

	tst	d0
	blt	Clip_L
	cmp	#320,d3
	bge	Clip_R

	tst	d1
	blt	Clip_U
	cmp	#192,d7
	bge	Clip_D



* NO CLIPING PRE-COMPUTE
* ----------------------


                  moveq	#-2,d3
	move	d3,Bltamod(C)
                  clr	d3
	move.l	d3,Bltafwm(C)
	move.l	d4,a4
	add	d1,d1
	add	(a3,d1.w),a4
	move	d0,d1
	lsr	#3,d1
	and	#$fffe,d1
	add	d1,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

                  move	#44*192,d3
	lea	Normal_Rout_Ptr(a1),a1
	move.l	(a1)+,a2
                  jmp	(a2)                * call normal blit routines



* CLIPING PRE-COMPUTE
* -------------------


Clip_L
	tst	d3
	ble	Object_loop

	tst	d1
	blt	Clip_LU
	cmp	#192,d7
	bge	Clip_LD

	bsr	Build_Clip_Mask

	lea	Fwm_Conv(D),a4
	and     #$f,d3
	add	d3,d3
	move	(a4,d3.w),Bltafwm(C)

	move	d0,d7
	not	d7
	lsr	#3,d7
                  moveq	#-2,d3
	and	d3,d7

	move	d7,Dm_Ta(D)
	move	d7,Ap_Ta+2(D)
	move	d7,Bm_Ta(D)
	moveq	#0,d2
	move	d2,Mbl(D)

	add     d7,d3
	move	d3,Bltamod(C)
	move	d2,Bltalwm(C)
	move.l	d4,a4
	add	d1,d1
	add	(a3,d1.w),a4
	subq	#2,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	lsr	#1,d7
	move	d7,S_Ts(D)

                  move	#44*192,d3
	move.l	H_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2)                * call horizontal clipping routines

Clip_R
	cmp	#320,d0
	bge     Object_Loop

	tst	d1
	blt	Clip_RU
	cmp	#192,d7
	bge	Clip_RD

	bsr	Build_Clip_Mask

	move	d3,d7
                  sub	#304,d7
	lsr	#3,d7
	moveq	#-2,d2
	and	d2,d7

	lea	Lwm_Conv(D),a4
	and     #$f,d3
	add	d3,d3
	move	(a4,d3.w),Bltalwm(C)

	move	d7,Dm_Ta(D)
	move	d7,Bm_Ta(D)
	moveq	#0,d3
	move	d3,Ap_Ta+2(D)
	move	d3,Mbl(D)

	st	Bltafwm(C)
	move.l	d4,a4
	add	d1,d1
	add	(a3,d1.w),a4
	move	d0,d1
	lsr	#3,d1
	and	d2,d1
	add	d1,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	add     d7,d2
	move	d2,Bltamod(C)

	lsr	#1,d7
	move	d7,S_Ts(D)

                  move	#44*192,d3
	move.l	H_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2) 	* call horizontal clipping routines

Clip_U
	tst	d7
	ble	Object_loop

	move	d1,d7
	not	d7
	addq	#1,d7

	move	d7,Mbl(D)

	moveq	#-2,d3
	move	d3,Bltamod(C)

	move.l	d4,a4
	move	d0,d1
	lsr	#3,d1
	and	d3,d1
	add	d1,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	clr	d3
	move.l	d3,Bltafwm(C)

	move	d3,Dm_Ta(D)
	move	d3,Ap_Ta+2(D)
	move	d3,Bm_Ta(D)

	lsl	#6,d7
	move	d7,S_Ts(D)

                  move	#44*192,d3
	move.l	V_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2)                * call horizontal clipping routines

Clip_D
	move	#192,d2
	cmp	d2,d1
	bge     Object_Loop

                  sub	d2,d7

	moveq	#-2,d3
	move	d3,Bltamod(C)

	move.l	d4,a4
	add	d1,d1
	add	(a3,d1.w),a4
	move	d0,d1
	lsr	#3,d1
	and	d3,d1
	add	d1,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	clr	d3
	move.l	d3,Bltafwm(C)

	move	d3,Dm_Ta(D)
	move	d3,Ap_Ta+2(D)
	move	d3,Mbl(D)
	move	d3,Bm_Ta(D)

	lsl	#6,d7
	move	d7,S_Ts(D)

                  move	#44*192,d3
	move.l	V_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2)                * call horizontal clipping routines

Clip_LU
	tst	d7
	ble	Object_loop

	bsr	Build_Clip_Mask

	lea	Fwm_Conv(D),a4
	and     #$f,d3
	add	d3,d3
	move	(a4,d3.w),Bltafwm(C)

	move	d0,d7
	not	d7
	lsr	#3,d7
                  moveq	#-2,d3
	and	d3,d7

	move	d7,Dm_Ta(D)
	move	d7,Ap_Ta+2(D)
	move	d7,Bm_Ta(D)

	add     d7,d3
	move	d3,Bltamod(C)
	clr	Bltalwm(C)
	move.l	d4,a4
	subq	#2,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	not	d1
	addq	#1,d1
	move	d1,Mbl(D)
	lsl	#6,d1

	lsr	#1,d7
	or	d1,d7
	move	d7,S_Ts(D)

                  move	#44*192,d3
	move.l	H_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2)                * call horizontal clipping routines

Clip_LD
	move	#192,a2
	cmp	a2,d1
	bge     Object_Loop

                  sub	a2,d7
	lsl	#6,d7

	bsr	Build_Clip_Mask

	lea	Fwm_Conv(D),a4
	and     #$f,d3
	add	d3,d3
	move	(a4,d3.w),Bltafwm(C)

	move	d0,d2
	not	d2
	lsr	#3,d2
                  moveq	#-2,d3
	and	d3,d2

	move	d2,Dm_Ta(D)
	move	d2,Ap_Ta+2(D)
	move	d2,Bm_Ta(D)

	add     d2,d3
	move	d3,Bltamod(C)
	moveq	#0,d3
	move	d3,Bltalwm(C)
	move.l	d4,a4
	add	d1,d1
	add	(a3,d1.w),a4
	subq	#2,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	move	d3,Mbl(D)

	lsr	#1,d2
	or	d7,d2
	move	d2,S_Ts(D)

                  move	#44*192,d3
	move.l	H_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2)                * call horizontal clipping routines

Clip_RU
	tst	d7
	ble	Object_loop

	bsr	Build_Clip_Mask

	move	d3,d7
                  sub	#304,d7
	lsr	#3,d7
	moveq	#-2,d2
	and	d2,d7

	lea	Lwm_Conv(D),a4
	and     #$f,d3
	add	d3,d3
	move	(a4,d3.w),Bltalwm(C)

	move	d7,Dm_Ta(D)
	move	d7,Bm_Ta(D)
	clr	Ap_Ta+2(D)

	st	Bltafwm(C)
	move.l	d4,a4
	move	d0,d3
	lsr	#3,d3
	and	d2,d3
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	add     d7,d2
	move	d2,Bltamod(C)

	not	d1
	addq	#1,d1
	move	d1,Mbl(D)
	lsl	#6,d1

	lsr	#1,d7
	or	d1,d7
	move	d7,S_Ts(D)

                  move	#44*192,d3
	move.l	H_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2) 	* call horizontal clipping routines

Clip_RD
	lea	192,a2
	cmp	a2,d1
	bge     Object_Loop

                  sub	a2,d7
	lsl	#6,d7

	bsr	Build_Clip_Mask

	move	d3,d2

	lea	Lwm_Conv(D),a4
	and     #$f,d3
	add	d3,d3
	move	(a4,d3.w),Bltalwm(C)

                  sub	#304,d2
	lsr	#3,d2
	moveq	#-2,d3
	and	d3,d2

	move	d2,Dm_Ta(D)
	move	d2,Bm_Ta(D)

	st	Bltafwm(C)
	move.l	d4,a4
	add	d1,d1
	add	(a3,d1.w),a4
	move	d0,d1
	lsr	#3,d1
	and	d3,d1
	add	d1,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)

	add     d2,d3
	move	d3,Bltamod(C)

	moveq	#0,d3
	move	d3,Ap_Ta+2(D)
	move	d3,Mbl(D)

	lsr	#1,d2
	or	d7,d2
	move	d2,S_Ts(D)

                  move	#44*192,d3
	move.l	H_C_Rout_Ptr(a1),a2
	lea	16(a1),a1
                  jmp	(a2) 	* call horizontal clipping routines



* NORMAL BLIT ROUTINES
* --------------------


N_Blit0                                         * 32 x 32 3 col pal0
	moveq	#44-6,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	128(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+3,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$02,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit1			* 64 x 32 3 col pal0
	moveq	#44-10,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	256(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+5,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$02,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit2                                         * 32 x 64 3 col pal0
	moveq	#44-6,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	256(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+3,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$02,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit3			* 64 x 64 3 col pal0
	moveq	#44-10,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	512(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+5,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$02,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit4                                         * 32 x 32 3 col pal1
	moveq	#44-6,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	128(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+3,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$fe,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit5			* 64 x 32 3 col pal1
	moveq	#44-10,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	256(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+5,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$fe,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit6                                         * 32 x 64 3 col pal1
	moveq	#44-6,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	256(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+3,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$fe,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit7			* 64 x 64 3 col pal1
	moveq	#44-10,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	move.l	d1,a2
	lea	512(a2),a2
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	clr	Bltbmod(C)
	move	#$0ff2,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+5,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	#$fe,d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit8                                         * 32 x 32 7 col
	moveq	#44-6,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,Bltbpt(C)
                  move.l	(a1)+,d1
	move.l	d1,Bltapt(C)
	move	#-2,Bltbmod(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+3,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit9                                         * 64 x 32 7 col
	moveq	#44-10,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,Bltbpt(C)
                  move.l	(a1)+,d1
	move.l	d1,Bltapt(C)
	move	#-2,Bltbmod(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+5,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit10                                        * 32 x 64 7 col
	moveq	#44-6,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,Bltbpt(C)
                  move.l	(a1)+,d1
	move.l	d1,Bltapt(C)
	move	#-2,Bltbmod(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+3,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
N_Blit11                                        * 64 x 64 7 col
	moveq	#44-10,d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,Bltbpt(C)
                  move.l	(a1)+,d1
	move.l	d1,Bltapt(C)
	move	#-2,Bltbmod(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+5,d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop



* BUILD MASK ROUTINES FOR H. CLIPPING
* -----------------------------------


Build_Clip_Mask
	moveq	#0,d2
	move.l	d2,Bltamod(C)
	move	#2,bltbmod(C)
	moveq	#-1,d2
	move.l	d2,Bltafwm(C)
	move.l	#$0dfc0000,Bltcon0(C)
	move.l	Frst_Bitplane_Ptr(a1),d2
	move.l	d2,Bltapt(C)

	move.l	Mask_Rout_Ptr(a1),a2
	jmp	(a2)	* call mask construction routines

M_Blit0				* 32 x 32
	add	#4*32,d2
	move.l	d2,Bltbpt(C)
	move.l  #_C_Blit_Mask_Buff,Bltdpt(C)
	move	#64*32+2,Bltsize(C)
	WAIT_BLIT

                  rts
M_Blit1				* 64 x 32
	add	#8*32,d2
	move.l	d2,Bltbpt(C)
	move.l  #_C_Blit_Mask_Buff,Bltdpt(C)
	move	#64*32+4,Bltsize(C)
	WAIT_BLIT

                  rts
M_Blit2				* 32 x 64
	add	#8*32,d2
	move.l	d2,Bltbpt(C)
	move.l  #_C_Blit_Mask_Buff,Bltdpt(C)
	move	#64*64+2,Bltsize(C)
	WAIT_BLIT

                  rts
M_Blit3				* 64 x 64
	add	#8*64,d2
	move.l	d2,Bltbpt(C)
	move.l  #_C_Blit_Mask_Buff,Bltdpt(C)
	move	#64*64+4,Bltsize(C)
	WAIT_BLIT
M_Nop				* No Mask Constr.
                  rts



* HORIZONTAL CLIPED BLIT ROUTINES
* -------------------------------


H_C_Blit0
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-6,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)

	lea	C_Blit_Mask_Buff(D),a2
                  move.l	(a1)+,d1
	move	Ap_Ta+2(D),d7
	add.l	d7,d1
	add	d7,a2
	move.l	d1,d2

	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add.l	d7,d1
	add	d7,a2
	add.l	d7,d2
.no_mbl
	add.l	#128,d2
	move.l	d1,Bltbpt(C)
	move.l	a2,Bltapt(C)

	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)

	move    #64*32+3,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d2,Bltbpt(C)
	move.l	a2,Bltapt(C)
	move	Bm_Ta(D),Bltbmod(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	a2,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	swap	d7
	and	#$f000,d7
	or	(a1),d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

H_C_Blit1
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-10,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)

	lea	C_Blit_Mask_Buff(D),a2
                  move.l	(a1)+,d1
	move	Ap_Ta+2(D),d7
	add.l	d7,d1
	add	d7,a2
	move.l	d1,d2

	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add	d7,d7
	add.l	d7,d1
	add	d7,a2
	add.l	d7,d2
.no_mbl
	add.l	#256,d2
	move.l	d1,Bltbpt(C)
	move.l	a2,Bltapt(C)

	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)

	move    #64*32+5,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d2,Bltbpt(C)
	move.l	a2,Bltapt(C)
	move	Bm_Ta(D),Bltbmod(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	a2,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	swap	d7
	and	#$f000,d7
	or	(a1),d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

H_C_Blit2
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-6,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)

	lea	C_Blit_Mask_Buff(D),a2
                  move.l	(a1)+,d1
	move	Ap_Ta+2(D),d7
	add.l	d7,d1
	add	d7,a2
	move.l	d1,d2

	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add.l	d7,d1
	add	d7,a2
	add.l	d7,d2
.no_mbl
	add.l	#256,d2
	move.l	d1,Bltbpt(C)
	move.l	a2,Bltapt(C)

	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)

	move    #64*64+3,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d2,Bltbpt(C)
	move.l	a2,Bltapt(C)
	move	Bm_Ta(D),Bltbmod(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	a2,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	swap	d7
	and	#$f000,d7
	or	(a1),d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

H_C_Blit3
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-10,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)

	lea	C_Blit_Mask_Buff(D),a2
                  move.l	(a1)+,d1
	move	Ap_Ta+2(D),d7
	add.l	d7,d1
	add	d7,a2
	move.l	d1,d2

	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add	d7,d7
	add.l	d7,d1
	add	d7,a2
	add.l	d7,d2
.no_mbl
	add.l	#512,d2
	move.l	d1,Bltbpt(C)
	move.l	a2,Bltapt(C)

	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)

	move    #64*64+5,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d2,Bltbpt(C)
	move.l	a2,Bltapt(C)
	move	Bm_Ta(D),Bltbmod(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	a2,Bltapt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	swap	d7
	and	#$f000,d7
	or	(a1),d7
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop



* VERTICAL CLIPED BLIT ROUTINES
* -----------------------------


V_C_Blit0
	moveq	#44-6,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	add.l	Ap_Ta(D),d1
	move.l	d1,d2

	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add.l	d7,d1
	add.l	d7,d2
.no_mbl
	add.l	#128,d2
	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	move	Bm_Ta(D),Bltbmod(C)
	move	#$0ff2,d7 f2
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+3,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7 ce
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	3(a1),d7 02
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

V_C_Blit1
	moveq	#44-10,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	add.l	Ap_Ta(D),d1
	move.l	d1,d2
	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add	d7,d7
	add.l	d7,d1
	add.l	d7,d2
.no_mbl
	add.l	#256,d2
	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	move	Bm_Ta(D),Bltbmod(C)
	move	#$0ff2,d7 f2
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+5,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7 ce
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	3(a1),d7 02
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

V_C_Blit2
	moveq	#44-6,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	add.l	Ap_Ta(D),d1
	move.l	d1,d2
	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add.l	d7,d1
	add.l	d7,d2
.no_mbl
	add.l	#256,d2
	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	move	Bm_Ta(D),Bltbmod(C)
	move	#$0ff2,d7 f2
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+3,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7 ce
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	3(a1),d7 02
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

V_C_Blit3
	moveq	#44-10,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,d1
	add.l	Ap_Ta(D),d1
	move.l	d1,d2
	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add.l	d7,d2
	add	d7,d7
	add	d7,d7
	add.l	d7,d1
	add.l	d7,d2
.no_mbl
	add.l	#512,d2
	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	move	Bm_Ta(D),Bltbmod(C)
	move	#$0ff2,d7 f2
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+5,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
                  swap	d7
	move.b	#$ce,d7 ce
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move.l	d2,Bltbpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move.b	3(a1),d7 02
	move	d7,Bltcon0(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

V_C_Blit4
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-6,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,a2
                  move.l	(a1)+,d1
	move.l	Ap_Ta(D),d7
	add.l	d7,d1
	add.l	d7,a2

	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add	d7,d7
	add.l	d7,d1
	add.l	d7,a2
.no_mbl
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+3,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move	#128,d7
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

V_C_Blit5
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-10,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,a2
                  move.l	(a1)+,d1
	move.l	Ap_Ta(D),d7
	add.l	d7,d1
	add.l	d7,a2
	move	Mbl(D),d7
	beq	.no_mbl
	lsl	#3,d7
	add.l	d7,d1
	add.l	d7,a2
.no_mbl
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*32+5,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move	#256,d7
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

V_C_Blit6
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-6,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,a2
                  move.l	(a1)+,d1
	move.l	Ap_Ta(D),d7
	add.l	d7,d1
	add.l	d7,a2
	move	Mbl(D),d7
	beq	.no_mbl
	add	d7,d7
	add	d7,d7
	add.l	d7,d1
	add.l	d7,a2
.no_mbl
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+3,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move	#256,d7
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop

V_C_Blit7
	moveq	#-2,d7
	add	Bm_Ta(D),d7
	move	d7,Bltbmod(C)

	moveq	#44-10,d7
	add     Dm_Ta(D),d7
                  move	d7,Bltcmod(C)
                  move	d7,Bltdmod(C)
                  move.l	(a1)+,a2
                  move.l	(a1)+,d1
	move.l	Ap_Ta(D),d7
	add.l	d7,d1
	add.l	d7,a2
	move	Mbl(D),d7
	beq	.no_mbl
	lsl	#3,d7
	add.l	d7,d1
	add.l	d7,a2
.no_mbl
	move.l	d1,Bltapt(C)
	move.l	a2,Bltbpt(C)
	move	#$0fca,d7
	and	#$f,d0
                  ror	#4,d0
	or	d0,d7
                  swap	d7
	or	d0,d7
	move.l	d7,Bltcon0(C)
	move    #64*64+5,d0
                  sub     S_Ts(D),d0
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	move	#512,d7
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	move.l	d1,Bltapt(C)
	add	d7,a2
	move.l	a2,BltBpt(C)
	add	d3,a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move    d0,Bltsize(C)
	WAIT_BLIT

	bra	Object_Loop
Object_End



* ALIEN BANK CTRL
* ---------------


	move.l	Curent_AWO_Ptr(D),a0
	addq	#1,Alien_AWO_Count(D)
	move	Curent_Alien_Num(D),d0
	cmp	Alien_AWO_Count(D),d0
	beq     .Bank_Finished
                  lea	AWO_Len(a0),a0
	bra	Alien_AWO_Loop
.Bank_Finished
	move.l  Curent_Bank_Ptr(D),a0
	lea	16*AWO_Len(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	beq     Alien_Bank_End
                  bra     Alien_Bank_Loop
Alien_Bank_End

