
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      A R N Y ' S   D R E A M S	            *
*                      ===========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                          HARDWARE  MODULE                               *
*                          ----------------                               *
*                                                                         *
*                                                                         *
***************************************************************************

* This module countain ONLY MACRO definition.

* These macros performe all the thing toutching at the hardware.




***************************************************************************

H_BLIT_CHAR	MACRO

* Synopsis:
* These macro display in cookie cut the char number d3 at position
* x d1, y d2 in the 512x512x5 game bitmap
* No cliping needed
* For the cookie cut these macro compute a 32x32x1 mask in Char_Mask(D) (128 bytes)
* These mask is put in 2 paralelle 512x512x1 masks.
* The first mask is Game_Bitmap_Mask only used for amiga paralax scroll.
* The second is Game_Base_Mask and only the 80 first chars (base chars) is put in,
* this 512x512x1 mask is used by ground and wall colision test.

* In:
* d1 pos x in game bitmap of the top left edge of the char
* d2 pos y  ''
* d3 char number (id 0->159)

* Out: -

* Attention Do not modify: a1, d0

* Use in: Game_Init

***************************************************************************



	lea	C_Id_2_Off_Table(D),a5  * !!! modify D !!!
	move	d3,d5
	add	d3,d3               * COMPUTE SOURCE
                  move	(a5,d3.w),d3
	lea	Char_Image,a0       * a0 source ptr
	add.l	d3,a0

	moveq	#36,d3	* BUILD 32x32x1 CHAR MASK
	move	d3,Bltamod(C)
	move	d3,Bltbmod(C)
	move	d3,Bltcmod(C)
	clr	Bltdmod(C)
	moveq	#-1,d3
	move.l	d3,Bltafwm(C)
	move.l	#$0ffe0000,Bltcon0(C)
	move	#%1000011001000000,Dmacon(C)

	move.l	a0,a5
	lea	Char_Mask,a4
	move	#40*256,d3
	move	#64*32+2,d4
	move.l	a5,Bltapt(C)
	add	d3,a5
	move.l	a5,Bltbpt(C)
	add	d3,a5
	move.l	a5,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT

	clr	Bltcmod(C)

	add	d3,a5
	move.l	a5,Bltapt(C)
	add	d3,a5
	move.l	a5,Bltbpt(C)
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT

	lea	Game_Bitmap,a5      * COMPUTE 3 DESTINATIONS
	lea	Game_Bitmap_Mask,a2
	lea	Game_Base_Mask,a3

	move	d1,d3	* d3 = blitter shift to do (0->15)
                  lsr	#3,d1
                  bclr	#0,d1
	add	d1,a5
	add	d1,a2
	add	d1,a3
	lsl	#6,d2
	add	d2,a5
	add	d2,a2
	add	d2,a3	* add at a5,a2,a3: ((x/16)*2)+(y*64)

	move	#-2,Bltamod(C)	* COOKIE CUT IN GAME BITMAP
	move	#40-6,Bltbmod(C)
	moveq	#64-6,d1
	move	d1,Bltcmod(C)
	move	d1,Bltdmod(C)
	move.l	#$ffff0000,Bltafwm(C)
	move	#$0fca,d1
	and	#$f,d3
	ror	#4,d3
	or	d3,d1
                  swap	d1
	or	d3,d1
	move.l	d1,Bltcon0(C)

                  move	#64*32+3,d1
	move.l	#64*512,d2
	move	#40*256,d4
                  move.l	a4,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a5,Bltcpt(C)
	move.l	a5,Bltdpt(C)
	move	d1,Bltsize(C)
	WAIT_BLIT
	add	d4,a0
	add.l	d2,a5
                  move.l	a4,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a5,Bltcpt(C)
	move.l	a5,Bltdpt(C)
 	move	d1,Bltsize(C)
	WAIT_BLIT
	add	d4,a0
	add.l	d2,a5
                  move.l	a4,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a5,Bltcpt(C)
	move.l	a5,Bltdpt(C)
 	move	d1,Bltsize(C)
	WAIT_BLIT
	add	d4,a0
	add.l	d2,a5
                  move.l	a4,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a5,Bltcpt(C)
	move.l	a5,Bltdpt(C)
 	move	d1,Bltsize(C)
	WAIT_BLIT
	add	d4,a0
	add.l	d2,a5
                  move.l	a4,Bltapt(C)
	move.l	a0,Bltbpt(C)
	move.l	a5,Bltcpt(C)
	move.l	a5,Bltdpt(C)
 	move	d1,Bltsize(C)
	WAIT_BLIT

	move.l	#$0bfa,d1           * BLIT CHAR MASK IN GAME BITMAP MASK
	or	d3,d1
                  swap	d1
	or	d3,d1
	move.l	d1,Bltcon0(C)
 	move	#64*32+3,d1

	move.l	a4,Bltapt(C)
	move.l	a2,Bltcpt(C)
	move.l	a2,Bltdpt(C)
 	move	d1,Bltsize(C)
	WAIT_BLIT
                                              * BLIT CHAR MASK IN GAME BASE MASK
	cmp	#80,d5
	bge	No_Base_Mask

	move.l	a4,Bltapt(C)
	move.l	a3,Bltcpt(C)
	move.l	a3,Bltdpt(C)
 	move	d1,Bltsize(C)
	WAIT_BLIT
No_Base_Mask
	lea	Rel_Start+32768,D	* RESTORE a5

	ENDM






***************************************************************************

H_INIT_SCREEN	MACRO

* Synopsis:
* These macro init the two part game screen:
* Part 0: Status Panel (320x20)
* Part 1: Game Area (304x224) visible  (320x224) real for video shifting

* In: -

* Out: -

* Use in: Game_Init

***************************************************************************



	move.l	#Dummy_Cl,Cop1lc(C)
	move	d0,Copjmp1(C)

	move.l	#$309124c1,Diwstrt(C)
	move.l	#$003800d0,Ddfstrt(C)
                  move	#%0101001000000000,Bplcon0(C)
	clr	Bplcon2(C)

	lea	CL_Status_Bpl+2,a0
	move.l	#Status_Bitmap,d0
	move.l	#40*20,d1
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l   d1,d0
	move	d0,12(a0)
	swap	d0
	move	d0,8(a0)
	swap	d0
	add.l   d1,d0
	move	d0,20(a0)
	swap	d0
	move	d0,16(a0)
	swap	d0
	add.l   d1,d0
	move	d0,28(a0)
	swap	d0
	move	d0,24(a0)
	swap	d0
	add.l   d1,d0
	move	d0,36(a0)
	swap	d0
	move	d0,32(a0)

	move.l	#CL_Degrade0,d0
	move.l	d0,Cop2lc(C)
	lea	CL_Jmp1+2,a0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	move.l	#CL_Degrade1,d0
	lea	CL_Jmp0+2,a0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)

                  lea	CL_Deg0(D),a0
	lea	CL_Degrade0,a1
	move.l	#$4445fffe,d1	* wait 1
	move.l	#$44dffffe,d2	* wait 1
	moveq	#0,d3
	moveq	#91,d0
.deg_loop0
	move.l	d1,(a1)+
	move	#Color,(a1)+
	move	(a0),(a1)+
	move.l	d2,(a1)+
	move	#Color,(a1)+
	clr	(a1)+
	add.l	#$01000000,d1
	add.l	#$01000000,d2
	addq	#1,d3
	cmp	#10,d3
	bne	.cont
	addq	#2,a0
	moveq	#0,d3
.cont
	dbra	d0,.deg_loop0

	lea	CL_Deg1(D),a2
	moveq	#9,d4
	moveq	#63,d0
.deg_loop1
	addq	#1,d4
	cmp	#10,d4
	bne	.cont2
	move	#Color+32,(a1)+
	move	(a2)+,(a1)+
	moveq	#0,d4
.cont2
	move.l	d1,(a1)+
	move	#Color,(a1)+
	move	(a0),(a1)+
	move.l	d2,(a1)+
	move	#Color,(a1)+
	clr	(a1)+
	add.l	#$01000000,d1
	add.l	#$01000000,d2
	addq	#1,d3
	cmp	#10,d3
	bne	.cont1
	addq	#2,a0
	moveq	#0,d3
.cont1
	dbra	d0,.deg_loop1

	moveq	#67,d0
.deg_loop2
	addq	#1,d4
	cmp	#10,d4
	bne	.cont3
	addq	#2,a2
	moveq	#0,d4
.cont3
	move.l	d1,(a1)+
	move	#Color,(a1)+
	move	-2(a2),(a1)+
	move.l	d2,(a1)+
	move	#Color,(a1)+
	clr	(a1)+
	add.l	#$01000000,d1
	add.l	#$01000000,d2
	dbra	d0,.deg_loop2
Flip2
                  lea	CL_Deg0(D),a0
	lea	CL_Degrade1,a1
	move.l	#$4445fffe,d1	* wait 1
	move.l	#$44dffffe,d2	* wait 1
	moveq	#5,d3
	moveq	#91,d0
.deg_loop0
	move.l	d1,(a1)+
	move	#Color,(a1)+
	move	(a0),(a1)+
	move.l	d2,(a1)+
	move	#Color,(a1)+
	clr	(a1)+
	add.l	#$01000000,d1
	add.l	#$01000000,d2
	addq	#1,d3
	cmp	#10,d3
	bne	.cont
	addq	#2,a0
	moveq	#0,d3
.cont
	dbra	d0,.deg_loop0

	lea	CL_Deg1(D),a2
	move	#Color+32,(a1)+
	move	(a2)+,(a1)+
	moveq	#5,d4
	moveq	#63,d0
.deg_loop1
	addq	#1,d4
	cmp	#10,d4
	bne	.cont2
	move	#Color+32,(a1)+
	move	(a2)+,(a1)+
	moveq	#0,d4
.cont2
	move.l	d1,(a1)+
	move	#Color,(a1)+
	move	(a0),(a1)+
	move.l	d2,(a1)+
	move	#Color,(a1)+
	clr	(a1)+
	add.l	#$01000000,d1
	add.l	#$01000000,d2
	addq	#1,d3
	cmp	#10,d3
	bne	.cont1
	addq	#2,a0
	moveq	#0,d3
.cont1
	dbra	d0,.deg_loop1

	moveq	#67,d0
.deg_loop2
	addq	#1,d4
	cmp	#10,d4
	bne	.cont3
	addq	#2,a2
	moveq	#0,d4
.cont3
	move.l	d1,(a1)+
	move	#Color,(a1)+
	move	-2(a2),(a1)+
	move.l	d2,(a1)+
	move	#Color,(a1)+
	clr	(a1)+
	add.l	#$01000000,d1
	add.l	#$01000000,d2
	dbra	d0,.deg_loop2

	lea	Common_Pal+2,a0
	lea	Cl_Game_Pal+2,a1
	moveq	#14,d0
.loop0
	move	(a0)+,(a1)
	lea	4(a1),a1
	dbra	d0,.loop0

	lea	World_Pal0,a0
	moveq	#14,d0
.loop1
	move	(a0)+,(a1)
	lea	4(a1),a1
	dbra	d0,.loop1

                  WAIT_SYNCH_D0_C
	move.l	#Game_Main_Cl,Cop1lc(C)
                  move	#%1000011111100000,Dmacon(C)

	ENDM






***************************************************************************

H_WAIT_SYNCH	MACRO

* Synopsis:
* These macro wait good vertical beam position

* In: -

* Out: -

* Use in: Game_loop

***************************************************************************



	moveq	#0,d0
                  move	Arny_Y(D),d0
	lsr	#6,d0
	sub	Camera_Y(D),d0
	add	#$44+50,d0
	cmp	#$a4,d0
	bge	.ok0
	move	#$a4,d0
.ok0
	cmp	#$124,d0
	ble	.ok1
	move	#$124,d0
.ok1
	lsl.l	#8,d0
Ws_Loop
	move.l	Vpos(C),d1
	and.l	#$0001ff00,d1
	cmp.l	d0,d1
	bne	Ws_Loop

	ENDM






***************************************************************************

H_READ_JOY	MACRO

* Synopsis:
* These macro read joystick position and update joy flags

* In: -

* Out:
* Joy_Up(D), Joy_Down(D), Joy_Right(D), Joy_Left(D), Joy_Fire(D)

* Use in: Game_init & Game_loop

***************************************************************************



	clr	Joy_Up(D)
	clr	Joy_Right(D)
	clr	Joy_Down(D)
	clr	Joy_Left(D)
	clr	Joy_Fire(D)

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
	st	Joy_Right(D)
	bra	.no_left
.no_right
	btst	#0,d4
	beq	.no_left
			* Left
	st	Joy_Left(D)
.no_left
	eor	d5,d2
	btst	#0,d2
	beq	.no_down
			* Down
	st	Joy_Down(D)
	bra	.no_up
.no_down
	eor	d0,d4
	btst	#0,d4
	beq	.no_up

	st	Joy_Up(D)
			* Up
.no_up
                  btst	#7,$bfe001
	bne	.no_fire
                                              * Fire
	st	Joy_Fire(D)
.no_fire
	ENDM






***************************************************************************

H_UPDATE_CAMERA	MACRO

* Synopsis:
* These macro move the camera ( 304x224 views in the 512x512 Game Bitmap)

* In:
* Camera_x & Camera_y are the top left edge of the 304x224 views (screen)

* Out: -

* Use in: Game_Sub, Game_init & Game_loop on bsr form.

***************************************************************************



	lea	CL_Game_Bpl+2,a0
	move.l	#Game_Bitmap,d0
	lea	Game_Bitmap_Mask+92*64,a1

	moveq	#0,d1	* UPDATE CL
                  move	Camera_x(D),d1
	move	d1,d3
	lsr	#3,d1
	bclr	#0,d1
	add.l	d1,d0
	add	d1,a1

	and	#$f,d3
	eor	#$f,d3
	move	d3,d1
	lsl	#4,d1
	or	d3,d1
	move	d1,Cl_Game_Shift+2

	moveq	#0,d2
                  move	Camera_y(D),d2
	lsl	#6,d2
	add.l	d2,d0
	add	d2,a1

	move.l	#64*512,d1
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l   d1,d0
	move	d0,12(a0)
	swap	d0
	move	d0,8(a0)
	swap	d0
	add.l   d1,d0
	move	d0,20(a0)
	swap	d0
	move	d0,16(a0)
	swap	d0
	add.l   d1,d0
	move	d0,28(a0)
	swap	d0
	move	d0,24(a0)
	swap	d0
	add.l   d1,d0
	move	d0,36(a0)
	swap	d0
	move	d0,32(a0)
	swap	d0
			* BLIT THE BAGROUND PLANE
	move	#-2,Bltbmod(C)
	moveq	#64-40,d2
	move	d2,Bltamod(C)
	move	d2,Bltcmod(C)
	move	d2,Bltdmod(C)
	moveq	#-1,d1
	move.l	d1,Bltafwm(C)
	move.l	#$0fac0000,d1
	eor	#$f,d3
	ror	#4,d3
	or	d3,d1
	move.l	d1,Bltcon0(C)

	move.l	a1,Bltapt(C)
	move.l	#Baground_Image,Bltbpt(C)
	add.l	#92*64,d0
	move.l	d0,Bltcpt(C)
	move.l	d0,Bltdpt(C)
	move	#64*64+20,Bltsize(C)
	WAIT_BLIT

	moveq	#64-44,d2
	move	d2,Bltamod(C)
	move	d2,Bltbmod(C)
	move	d2,Bltdmod(C)
	sub.l	#514,d0
	move.l	d0,Bltbpt(C)
	move.l	d0,Bltdpt(C)
	lea	-514(a1),a1
	move.l	a1,Bltapt(C)
	move.l	#$0dc00000,Bltcon0(C)
	move	#64*8+22,Bltsize(C)
	WAIT_BLIT

	add.l	#4608,d0
	move.l	d0,Bltbpt(C)
	move.l	d0,Bltdpt(C)
	lea	4608(a1),a1
	move.l	a1,Bltapt(C)
	move	#64*8+22,Bltsize(C)
	WAIT_BLIT

	moveq	#64-2,d2
	move	d2,Bltamod(C)
	move	d2,Bltbmod(C)
	move	d2,Bltdmod(C)
	sub.l	#4096,d0
	move.l	d0,Bltbpt(C)
	move.l	d0,Bltdpt(C)
	lea	-4096(a1),a1
	move.l	a1,Bltapt(C)
	move	#64*64+1,Bltsize(C)
	WAIT_BLIT

	add.l	#42,d0
	move.l	d0,Bltbpt(C)
	move.l	d0,Bltdpt(C)
	lea	42(a1),a1
	move.l	a1,Bltapt(C)
	move	#64*64+1,Bltsize(C)
	WAIT_BLIT

                  ENDM






***************************************************************************

H_RESTORE_OBJ	MACRO

* Synopsis:
* Obj are cokie cut B_litter OB_ject_S (BOB) or Sprites in Amiga Hardware.
* All object are 32x32x4 (16 col) and col 0 translucide
* These macro read Obj_Struct(D) and restore the bitmap under the old Bob.
* Obj are ignored if these x = -1

* In:
* Obj_Ptr, Obj_Safe_Buffer are Screen destination and safe bitmap buffer
* See Obj_Struct(D) definition in relative data section for more info.

* Out: -

* Use in: Game_loop

***************************************************************************



	clr	Bltamod(C)
	move	#64-6,Bltdmod(C)
	moveq	#-1,d1
                  move.l	d1,Bltafwm(C)
	move.l	#$09f00000,Bltcon0(C)
	move.l	#64*512,d2
	move	#64*32+3,d4

	lea	Obj_Struct(D),a0
	move	#Obj_Num-1,d0
Restore_Obj_Loop
	move.l	Obj_Ptr(a0),d3
	bmi	No_Restore

	move.l	d3,Bltdpt(C)
                  lea	Obj_Safe_Buffer(a0),a1
	move.l	a1,Bltapt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,d3
	move.l	d3,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,d3
	move.l	d3,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,d3
	move.l	d3,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,d3
	move.l	d3,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
No_Restore
	lea	Obj_Sizeof(a0),a0
                  dbra	d0,Restore_Obj_Loop

                  ENDM






***************************************************************************

H_SAFE_OBJ	MACRO

* Synopsis:
* Obj are cokie cut B_litter OB_ject_S (BOB) or Sprites in Amiga Hardware.
* All object are 32x32x4 (16 col) and col 0 translucide
* These macro read Obj_Struct(D) and safe the bitmap under new Bob.
* Obj are ignored if these x = -1

* In:
* Obj_Y & Obj_Y are the position of the top left edge of the 32x32 Obj in
* the 512x512 game bitmap
* Obj_Ptr, Obj_Safe_Buffer are use by this routine to
* safe the bitmap under a Obj.
* See Obj_Struct(D) definition in relative data section for more info.

* Out:
* Obj_Ptr is the pointer in the game bitmap of a Obj, is computed unsing
* Obj_X and Obj_Y.

* Use in: Game_loop

***************************************************************************



	clr	Bltdmod(C)
	move	#64-6,Bltamod(C)
	moveq	#-1,d0
                  move.l	d0,Bltafwm(C)
	move.l	#$09f00000,Bltcon0(C)
	move.l	#64*512,d2
	move	#64*32+3,d4

	lea	Obj_Struct(D),a0
	move	#Obj_Num-1,d0
Safe_Obj_Loop
	move	Obj_X(a0),d1
	bmi	No_Safe

	lea	Game_Bitmap,a1
                  lsr	#3,d1
	bclr	#0,d1
	add	d1,a1
	move	Obj_Y(a0),d1
	lsl	#6,d1
	add	d1,a1
	move.l	a1,Obj_Ptr(a0)

                  move.l	a1,Bltapt(C)
                  lea	Obj_Safe_Buffer(a0),a2
	move.l	a2,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a1
	move.l	a1,Bltapt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a1
	move.l	a1,Bltapt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a1
	move.l	a1,Bltapt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a1
	move.l	a1,Bltapt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
No_Safe
	lea	Obj_Sizeof(a0),a0
                  dbra	d0,Safe_Obj_Loop

                  ENDM






***************************************************************************

H_DISPLAY_OBJ	MACRO

* Synopsis:
* Obj are cokie cut Blitter OBjects (BOB) or Sprites in Amiga Hardware.
* All object are 32x32x4 (16 col) and col 0 translucide.
* These macro read Obj_Struct(D) and blit in cockie cut the 32x32x4 Bob
* in the 512x512x5 game bitmap.
* If Obj is sprite the routines only update sprites hardware.
* Object are ignored if these x = -1
* ATTENTION all coordinates are in 512x512 GAME AREA FORMAT and NOT in 308x200
* screen format !

* In:
* Obj_Id are the number of the Obj to display
* Obj_Ptr, are used like destination ptr in the game bitmap
* See Obj_Struct(D) definition in relative data section for more info.
* The bitmap definition of the obj are in Obj_Image

* Out: -

* Use in: Game_loop

***************************************************************************



	moveq	#-2,d0
	move	d0,Bltamod(C)
	move	d0,Bltbmod(C)
	moveq	#64-6,d0
	move	d0,Bltcmod(C)
	move	d0,Bltdmod(C)
	move.l	#$ffff0000,Bltafwm(C)
	move.l	#64*512,d2
	move	#64*32+3,d4

	lea	Obj_Struct(D),a0
	move	#Obj_Num-1,d0
Disp_Obj_Loop
	move	Obj_X(a0),d1
	bmi	No_Obj

	and	#$f,d1
	ror	#4,d1
	move.l	#$0fca,d3
	move.l	#$0b0a,d5
	or	d1,d3
	or	d1,d5
	swap	d3
	swap	d5
	or	d1,d3
	move.l	d3,Bltcon0(C)

	move	Obj_Id(a0),d1
	cmp	#First_Bob,d1
                  bge	Display_Bob
Display_Sprite




	bra	No_Obj
Display_Bob
	sub	#First_Bob,d1
	lea     Bob_Image,a3
	add	d1,d1
	lea	Obj_Id_2_Off(D),a1
	add	(a1,d1.w),a3
	move.l	a3,Bltbpt(C)

	lea     4*32*4(a3),a3
	move.l	a3,Bltapt(C)

	move.l	Obj_Ptr(a0),a4
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a4
	move.l	a3,Bltapt(C)
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a4
	move.l	a3,Bltapt(C)
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a4
	move.l	a3,Bltapt(C)
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
	add.l	d2,a4
	move.l	d5,Bltcon0(C)
	move.l	a3,Bltapt(C)
	move.l	a4,Bltcpt(C)
	move.l	a4,Bltdpt(C)
	move	d4,Bltsize(C)
	WAIT_BLIT
No_Obj
	lea	Obj_Sizeof(a0),a0
                  dbra	d0,Disp_Obj_Loop

                  ENDM






***************************************************************************

H_COPPER_LIST	MACRO

* Synopsis:
* These macro countain the copper list
* Copper list it's only use by the Amiga Hardware (copper) to define an
* screen and to do screen register multiplexing.

* In: -

* Out: -

* Use in: Data

***************************************************************************



Game_Main_Cl



* Status panel
* ------------


Cl_Status_Pal
	C_MOVE	0,Color+2
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
	C_MOVE	0,Color+14
	C_MOVE	0,Color+16
	C_MOVE	0,Color+18
	C_MOVE	0,Color+20
	C_MOVE	0,Color+22
	C_MOVE	0,Color+24
	C_MOVE	0,Color+26
	C_MOVE	0,Color+28
	C_MOVE	0,Color+30
	C_MOVE	0,Color+32
	C_MOVE	0,Color+34
	C_MOVE	0,Color+36
	C_MOVE	0,Color+38
	C_MOVE	0,Color+40
	C_MOVE	0,Color+42
	C_MOVE	0,Color+44
	C_MOVE	0,Color+46
	C_MOVE	0,Color+48
	C_MOVE	0,Color+50
	C_MOVE	0,Color+52
	C_MOVE	0,Color+54
	C_MOVE	0,Color+56
	C_MOVE	0,Color+58
	C_MOVE	0,Color+60
	C_MOVE  0,Color+62
Cl_Spr_Ptr
	C_MOVE  0,Spr0Pt  
	C_MOVE  0,Spr0Pt+2
	C_MOVE  0,Spr1Pt
	C_MOVE  0,Spr1Pt+2
	C_MOVE  0,Spr2Pt
	C_MOVE  0,Spr2Pt+2
	C_MOVE  0,Spr3Pt
	C_MOVE  0,Spr3Pt+2
	C_MOVE  0,Spr4Pt
	C_MOVE  0,Spr4Pt+2
	C_MOVE  0,Spr5Pt
	C_MOVE  0,Spr5Pt+2
	C_MOVE  0,Spr6Pt
	C_MOVE  0,Spr6Pt+2
	C_MOVE  0,Spr7Pt
	C_MOVE  0,Spr7Pt+2

	C_MOVE	0,Bpl1mod
	C_MOVE	0,Bpl2mod
	C_MOVE	0,Bplcon1

Cl_Status_Bpl
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2



* Game area
* ---------


	C_WAIT	$42
Cl_Game_Pal
	C_MOVE	0,Color+2
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
	C_MOVE	0,Color+14
	C_MOVE	0,Color+16
	C_MOVE	0,Color+18
	C_MOVE	0,Color+20
	C_MOVE	0,Color+22
	C_MOVE	0,Color+24
	C_MOVE	0,Color+26
	C_MOVE	0,Color+28
	C_MOVE	0,Color+30
	C_MOVE	0,Color+32
	C_MOVE	0,Color+34
	C_MOVE	0,Color+36
	C_MOVE	0,Color+38
	C_MOVE	0,Color+40
	C_MOVE	0,Color+42
	C_MOVE	0,Color+44
	C_MOVE	0,Color+46
	C_MOVE	0,Color+48
	C_MOVE	0,Color+50
	C_MOVE	0,Color+52
	C_MOVE	0,Color+54
	C_MOVE	0,Color+56
	C_MOVE	0,Color+58
	C_MOVE	0,Color+60
	C_MOVE  0,Color+62

	C_MOVE	24,Bpl1mod	* 64-40
	C_MOVE	24,Bpl2mod
Cl_Game_Shift
	C_MOVE	0,Bplcon1

	C_WAIT	$1d1,$43

Cl_Game_Bpl
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2

	C_MOVE	0,Copjmp2

CL_Degrade0
	DS.L	903
CL_Jmp0
	C_MOVE	0,Cop2lc
	C_MOVE	0,Cop2lc+2
Dummy_Cl
	C_END

CL_Degrade1
	DS.L	903
CL_Jmp1
	C_MOVE	0,Cop2lc
	C_MOVE	0,Cop2lc+2

	C_END

	ENDM






