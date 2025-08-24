
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                             BACK SCROLL                                 *
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



* FRAME CONTROL
* -------------

 	tst	Back_Phase(D)
	bne     No_New_Frame2

	clr	Refresh_Frame(D)
	tst	Pause2(D)
	bne	Back_End
	tst	Stop2(D)		* STOP
	bne	.cont
                  subq    #1,Back_Shift(D)
	and	#%11111,Back_Shift(D)
	cmp	#31,Back_Shift(D)
	bne	.cont
	add	#1*240,Back_Config(D)
	cmp	#5*240,Back_Config(D)
	bne	.cont
	clr	Back_Config(D)

                  move.l	Pat1_Ptr_Stat(D),Pat0_Ptr_Stat(D)
                  move.l	Pat1_Ptr_Dyn(D),Pat0_Ptr_Dyn(D)
                  move	Pat1_Dly_Count(D),Pat0_Dly_Count(D)
                  move.l	Pat1_Frm_Ptr(D),Pat0_Frm_Ptr(D)

                  move.l	Pat2_Ptr_Stat(D),Pat1_Ptr_Stat(D)
                  move.l	Pat2_Ptr_Dyn(D),Pat1_Ptr_Dyn(D)
                  move	Pat2_Dly_Count(D),Pat1_Dly_Count(D)
                  move.l	Pat2_Frm_Ptr(D),Pat1_Frm_Ptr(D)

	addq.l	#2,Pat_Ptr(D)
	move.l	Pat_Ptr(D),a0
	move.l	a0,d2

	move	(a0),d0		* New Pattern
	lea	Back_Pattern(D),a0
	add	d0,a0

	cmp.l	#_Back_Pattern+30,d2
	bls	.no_end

                  st	Stop+1(D)
	st	Prg_Pause+1(D)
	bra	.no_col
.no_end
	addq	#2,a0
	lea	Back_Color0+2(D),a1
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)

	addq	#2,a0
	lea	Back_Color1_f0+2(D),a1
	lea	Back_Color1_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a2)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a2)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a2)
	move	d0,20(a2)

	addq	#2,a0
	lea	Back_Color2_f0+2(D),a1
	lea	Back_Color2_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a2)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a2)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a2)
	move	d0,20(a2)

	addq	#2,a0
	lea	Back_Color3_f0+2(D),a1
	lea	Back_Color3_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a2)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a2)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a2)
	move	d0,20(a2)

	addq	#2,a0
	lea	Back_Color4_f0+2(D),a1
	lea	Back_Color4_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a2)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a2)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a2)
	move	d0,20(a2)

	addq	#2,a0
	lea	Back_Color5_f0+2(D),a1
	lea	Back_Color5_f1+2(D),a2
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a2)
	move	d0,4(a2)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a2)
	move	d0,12(a2)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a2)
	move	d0,20(a2)

	bra	.cont2
.no_col
	lea	6*4*2(a0),a0
.cont2
	move.l	a0,Pat2_Ptr_Stat(D)
	move.l	a0,Pat2_Ptr_Dyn(D)
	move	#1,Pat2_Dly_Count(D)
	st	Refresh_Frame(D)
.cont

	lea	X60(D),a1
	lea     Back_Frame(D),a2

	tst	Refresh_Frame(D)
	bne	.do
              	subq	#1,Pat0_Dly_Count(D)
	bne     No_New_Frame0
.do
	move.l	Pat0_Ptr_Dyn(D),a0
	move.b	(a0)+,d0
	bpl	.No_Seq_End
	move.l	Pat0_Ptr_Stat(D),a0
	move.b	(a0)+,d0		* d0 Curent Frame 0
.No_Seq_End
	move.b	(a0)+,Pat0_Dly_Count+1(D)
	move.l	a0,Pat0_Ptr_Dyn(D)
	ext	d0
                  add	d0,d0
	move	(a1,d0.w),d0
                  move.l	a2,a3
	add	d0,a3
	move.l	a3,Pat0_Frm_Ptr(D)
No_New_Frame0

	tst	Refresh_Frame(D)
	bne	.do
              	subq	#1,Pat1_Dly_Count(D)
	bne     No_New_Frame1
.do
	move.l	Pat1_Ptr_Dyn(D),a0
	move.b	(a0)+,d0
	bpl	.No_Seq_End
	move.l	Pat1_Ptr_Stat(D),a0
	move.b	(a0)+,d0		* d0 Curent Frame 1
.No_Seq_End
	move.b	(a0)+,Pat1_Dly_Count+1(D)
	move.l	a0,Pat1_Ptr_Dyn(D)
	ext	d0
                  add	d0,d0
	move	(a1,d0.w),d0
                  move.l	a2,a3
	add	d0,a3
	move.l	a3,Pat1_Frm_Ptr(D)
No_New_Frame1

	tst	Refresh_Frame(D)
	bne	.do
              	subq	#1,Pat2_Dly_Count(D)
	bne     No_New_Frame2
.do
	move.l	Pat2_Ptr_Dyn(D),a0
	move.b	(a0)+,d0
	bpl	.No_Seq_End
	move.l	Pat2_Ptr_Stat(D),a0
	move.b	(a0)+,d0		* d0 Curent Frame 2
.No_Seq_End
	move.b	(a0)+,Pat2_Dly_Count+1(D)
	move.l	a0,Pat2_Ptr_Dyn(D)
	ext	d0
                  add	d0,d0
	move	(a1,d0.w),d0
	add	d0,a2
	move.l	a2,Pat2_Frm_Ptr(D)
No_New_Frame2



* TRANSFER 1/2 OF CHAR IN BIT MAP
* -------------------------------


	lea	Back_Char_Info(D),a1
	move.l	a1,a2
	move	(a1)+,d0	* a1 Char info (mode) ptr
	add	d0,a2	* a2 Char info (offset) ptr
	move.l  Pat0_Frm_Ptr(D),d0
	move.l  Pat1_Frm_Ptr(D),d1
	move.l  Pat2_Frm_Ptr(D),d2
                  move.l	Cur_Back_Build(D),d3
	lea	Read_Table(D),a3
	add	Back_Config(D),a3	* Back config = config*240
	lea	Write_Table(D),a4
	lea	Back_Old_Char(D),D
	add	_Back_Old_Off,D
	tst	_Back_Phase
	beq	.Phase0
	lea	120(a3),a3
                  lea	60(a4),a4
	lea	120(D),D
.Phase0

	move.l	#$00000024,Bltamod(C)
	move.l	#-1,Bltafwm(C)

	moveq	#29,d7	* d7 Char Loop Counter
Char_Loop
	move	(a3)+,d4
	beq	.Frame0
	subq	#1,d4
	beq	.Frame1
                  move.l	d2,a0
	bra	.cont
.Frame0
	move.l	d0,a0
	bra	.cont
.Frame1
	move.l	d1,a0
.Cont
	add	(a3)+,a0	* a0 char address in frame
	move	(a4)+,d4
	ext.l	d4
	add.l	d3,d4
	move.l	d4,Bltdpt(C)	* Destination Ptr
	move	(a0),d4	* d4 char #
	cmp	(D)+,d4
	beq	.No_Blit
	move	d4,-2(D)
	move.b	(a1,d4.w),d5
	beq	.mode0
	subq.b	#1,d5
	beq	.mode1
	subq.b	#1,d5
	beq	.mode2
			* mode 3  bpl1=mem1  bpl2=0
	add	d4,d4
	move	(a2,d4.w),d4
                  and.l	#$ffff,d4
	add.l	#Back_Charset,d4
	move.l	d4,Bltapt(C)
	move.l	#$09f00000,Bltcon0(C)
	move	#2+64*32,Bltsize(C)
	WAIT_BLIT
	move.l	#$01000000,Bltcon0(C)
	move	#2+64*32,Bltsize(C)
	WAIT_BLIT
.No_Blit
                  dbra	d7,Char_Loop
	bra     Char_Loop_End
.Mode0			* mode 0  bpl1=mem1  bpl2=mem2
	add	d4,d4
	move	(a2,d4.w),d4
                  and.l	#$ffff,d4
	add.l	#Back_Charset,d4
	move.l	d4,Bltapt(C)
	move.l	#$09f00000,Bltcon0(C)
	move	#2+64*64,Bltsize(C)
	WAIT_BLIT
                  dbra	d7,Char_Loop
	bra	Char_Loop_End
.Mode1			* mode 1  bpl1=mem1  bpl2=mem1
	add	d4,d4
	move	(a2,d4.w),d4
                  and.l	#$ffff,d4
	add.l	#Back_Charset,d4
	move.l	d4,Bltapt(C)
 	move.l	#$09f00000,Bltcon0(C)
	move	#2+64*32,Bltsize(C)
	WAIT_BLIT
	move.l	d4,Bltapt(C)
 	move.l	#$09f00000,Bltcon0(C)
	move	#2+64*32,Bltsize(C)
	WAIT_BLIT
                  dbra	d7,Char_Loop
	bra	Char_Loop_End
.Mode2			* mode 2  bpl1=0     bpl2=mem1
	add	d4,d4
	move	(a2,d4.w),d4
                  and.l	#$ffff,d4
	add.l	#Back_Charset,d4
	move.l	d4,Bltapt(C)
	move.l	#$01000000,Bltcon0(C)
	move	#2+64*32,Bltsize(C)
	WAIT_BLIT
 	move.l	#$09f00000,Bltcon0(C)
	move	#2+64*32,Bltsize(C)
	WAIT_BLIT
                  dbra	d7,Char_Loop
Char_Loop_End

	lea	Rel_Start+32768,D



* TRANSFER 1/2 OF SKY
* -------------------


	tst     Back_Phase(D)
	beq	Sky_Phase0

	addq	#1,Sky_Count(D)

	IFNE	Asm_Level=5
	cmp	#10,Sky_Count(D)
	ELSEIF
	cmp	#1,Sky_Count(D)
	ENDC

	bne	.Cont
	clr	Sky_Count(D)
.Cont
                  lea	Sky_Dat,a0
	move	Sky_Count(D),d2
                  lsl	#3,d2
	lea	Sky_Anim_Table(D),a1
	move	(a1,d2.w),d1
	add	d1,a0
	move.l	#$fffe0002,Bltamod(C)
                  clr	Bltalwm(C)
	move    Back_Shift(D),d0
	eor	#%11111,d0
	move.l	Cur_Back_Build(D),a3	* a3 Dest Ptr
	add.l	#40*192*2,a3
	btst	#4,d0
	beq	.no_add
	addq.l	#2,a3
.No_Add
                  ror	#4,d0
	and	#%1111111111111110,d0
                  or	#%0000100111110000,d0
	move	d0,Bltcon0(C)
	move.l	a3,Bltdpt(C)
	move.l	a0,Bltapt(C)
	move	#19+64*40,Bltsize(C)
	WAIT_BLIT

	move	2(a1,d2.w),d1
                  lea	Sky_Dat,a0
	add	d1,a0
	move.l	a0,Bltapt(C)
	move	#19+64*40,Bltsize(C)
	WAIT_BLIT
Sky_Phase0
                  lea	Sky_Dat,a0
	move	Sky_Count(D),d2
                  lsl	#3,d2
	lea	Sky_Anim_Table(D),a1
	move	4(a1,d2.w),d1
	add	d1,a0
	move.l	#$fffe0002,Bltamod(C)
                  clr	Bltalwm(C)
	move    Back_Shift(D),d0
	eor	#%11111,d0
	move.l	Cur_Back_Build(D),a3	* a3 Dest Ptr
	add.l	#40*192*2+40*80,a3
	btst	#4,d0
	beq	.no_add
	addq.l	#2,a3
.No_Add
                  ror	#4,d0
	and	#%1111111111111110,d0
                  or	#%0000100111110000,d0
	move	d0,Bltcon0(C)
	move.l	a3,Bltdpt(C)
	move.l	a0,Bltapt(C)
	move	#19+64*40,Bltsize(C)
	WAIT_BLIT

	move	6(a1,d2.w),d1
                  lea	Sky_Dat,a0
	add	d1,a0
	move.l	a0,Bltapt(C)
	move	#19+64*40,Bltsize(C)
	WAIT_BLIT



* CHANGE OF PHASE
* ---------------


	eor	#1,Back_Phase(D)

Back_End



